#!/bin/bash -eu
DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BUILD_OPTS="$*"

DOCKER="docker"

if ! ${DOCKER} ps >/dev/null 2>&1; then
	DOCKER="sudo docker"
fi
if ! ${DOCKER} ps >/dev/null; then
	echo "error connecting to docker:"
	${DOCKER} ps
	exit 1
fi

CONFIG_FILE=""
if [ -f "${DIR}/config" ]; then
	CONFIG_FILE="${DIR}/config"
elif [ -f "${DIR}/../pi-gen-stages/config-template" ]; then
	# Fallback to the shared template so CI/local builds do not fail when a
	# local config copy is missing.
	CONFIG_FILE="${DIR}/../pi-gen-stages/config-template"
fi

while getopts "c:" flag
do
	case "${flag}" in
		c)
			CONFIG_FILE="${OPTARG}"
			;;
		*)
			;;
	esac
done

# Ensure that the configuration file is an absolute path
if test -x /usr/bin/realpath; then
	CONFIG_FILE=$(realpath -s "$CONFIG_FILE")
fi

# Ensure that the configuration file is present
if test -z "${CONFIG_FILE}"; then
	echo "Configuration file needs to be present at '${DIR}/config', '${DIR}/../pi-gen-stages/config-template', or passed via -c"
	exit 1
else
	# shellcheck disable=SC1090
	source "${CONFIG_FILE}"
fi

CONTAINER_NAME=${CONTAINER_NAME:-pigen_work}
CONTINUE=${CONTINUE:-0}
PRESERVE_CONTAINER=${PRESERVE_CONTAINER:-0}

if [ -z "${IMG_NAME}" ]; then
	echo "IMG_NAME not set in 'config'" 1>&2
	echo 1>&2
exit 1
fi

# Ensure the Git Hash is recorded before entering the docker container
GIT_HASH=${GIT_HASH:-"$(git rev-parse HEAD)"}
GIT_BRANCH=${GIT_BRANCH:-"$(git branch  --no-color  | grep -E '^\*')"}

CONTAINER_EXISTS=$(${DOCKER} ps -a --filter name="${CONTAINER_NAME}" -q)
CONTAINER_RUNNING=$(${DOCKER} ps --filter name="${CONTAINER_NAME}" -q)
if [ "${CONTAINER_RUNNING}" != "" ]; then
	echo "The build is already running in container ${CONTAINER_NAME}. Aborting."
	exit 1
fi
if [ "${CONTAINER_EXISTS}" != "" ] && [ "${CONTINUE}" != "1" ]; then
	echo "Container ${CONTAINER_NAME} already exists and you did not specify CONTINUE=1. Aborting."
	echo "You can delete the existing container like this:"
	echo "  ${DOCKER} rm -v ${CONTAINER_NAME}"
	exit 1
fi

# Modify original build-options to allow config file to be mounted in the docker container
BUILD_OPTS="$(echo "${BUILD_OPTS:-}" | sed -E 's@\-c\s?([^ ]+)@-c /config@')"

echo "=== DEBUG: Build Configuration ==="
echo "DIR: ${DIR}"
echo "CONFIG_FILE: ${CONFIG_FILE}"
echo "IMG_NAME: ${IMG_NAME}"
echo "CONTAINER_NAME: ${CONTAINER_NAME}"
echo "BUILD_OPTS: ${BUILD_OPTS}"
echo "DOCKER: ${DOCKER}"
echo "GIT_HASH: ${GIT_HASH}"
echo "GIT_BRANCH: ${GIT_BRANCH}"
echo "=================================="

echo "=== DEBUG: Building pi-gen Docker image ==="
BASE_IMAGE=debian:trixie
case "$(uname -m)" in
	x86_64|aarch64)
		BASE_IMAGE=i386/debian:trixie
		;;
esac
echo "=== DEBUG: Using BASE_IMAGE=${BASE_IMAGE} ==="
${DOCKER} build --build-arg BASE_IMAGE="${BASE_IMAGE}" -t pi-gen "${DIR}"
echo "=== DEBUG: Docker build completed ===" 
if [ "${CONTAINER_EXISTS}" != "" ]; then
	echo "=== DEBUG: Container exists, running continuation ==="
	echo "=== DEBUG: Docker run command (continuation mode) ==="
	echo "CONTAINER_NAME: ${CONTAINER_NAME}"
	echo "CONFIG_FILE: ${CONFIG_FILE}"
	echo "Build command: cd /pi-gen; ./build.sh ${BUILD_OPTS}"
	echo "==========================================="
	trap 'echo "got CTRL+C... please wait 5s" && ${DOCKER} stop -t 5 ${CONTAINER_NAME}_cont' SIGINT SIGTERM
	time ${DOCKER} run --rm --privileged \
		--volume "${CONFIG_FILE}":/config:ro \
		-e "GIT_HASH=${GIT_HASH}" \
		-e "GIT_BRANCH=${GIT_BRANCH}" \
		--volumes-from="${CONTAINER_NAME}" --name "${CONTAINER_NAME}_cont" \
		pi-gen \
		bash -e -o pipefail -c "echo '=== Inside container ===' && pwd && ls -la /pi-gen/ && dpkg-reconfigure qemu-user-binfmt &&
	mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || true &&
	cd /pi-gen; echo '=== About to run ./build.sh ===' && ./build.sh ${BUILD_OPTS} &&
	echo '=== Build completed, syncing logs ===' && rsync -av work/*/build.log deploy/" &
	wait "$!"
else
	echo "=== DEBUG: No existing container, creating new ==="
	echo "=== DEBUG: Docker run command (new mode) ==="
	echo "CONTAINER_NAME: ${CONTAINER_NAME}"
	echo "CONFIG_FILE: ${CONFIG_FILE}"
	echo "Build command: cd /pi-gen; ./build.sh ${BUILD_OPTS}"
	echo "==========================================="
	trap 'echo "got CTRL+C... please wait 5s" && ${DOCKER} stop -t 5 ${CONTAINER_NAME}' SIGINT SIGTERM
	time ${DOCKER} run --name "${CONTAINER_NAME}" --privileged \
		--volume "${CONFIG_FILE}":/config:ro \
		-e "GIT_HASH=${GIT_HASH}" \
		-e "GIT_BRANCH=${GIT_BRANCH}" \
		pi-gen \
		bash -e -o pipefail -c "echo '=== Inside container ===' && pwd && ls -la /pi-gen/ && dpkg-reconfigure qemu-user-binfmt &&
	mount binfmt_misc -t binfmt_misc /proc/sys/fs/binfmt_misc || true &&
	cd /pi-gen; echo '=== About to run ./build.sh ===' && ./build.sh ${BUILD_OPTS} &&
	echo '=== Build completed, syncing logs ===' && rsync -av work/*/build.log deploy/" &
	wait "$!"
fi
echo "=== DEBUG: Copying results from deploy/ ==="
echo "CONTAINER_NAME: ${CONTAINER_NAME}"
${DOCKER} ps -a --filter name="${CONTAINER_NAME}" --format "table {{.Names}}\t{{.Status}}"
echo "=== DEBUG: Attempting to copy deploy/ from container ==="
${DOCKER} cp "${CONTAINER_NAME}":/pi-gen/deploy . || echo "=== DEBUG: Copy failed - deploy may not exist in container ==="
echo "=== DEBUG: Checking deploy directory ==="
if [ -d deploy ]; then
	echo "=== DEBUG: deploy/ directory exists locally ==="
	ls -lah deploy
	echo "=== DEBUG: Contents of deploy/ ==="
	find deploy -type f -exec ls -lh {} \;
else
	echo "=== DEBUG: ERROR - deploy/ directory NOT found locally ==="
	echo "=== DEBUG: Current directory contents ==="
	ls -la
fi

# cleanup
if [ "${PRESERVE_CONTAINER}" != "1" ]; then
	echo "=== DEBUG: Cleaning up container ==="
	${DOCKER} rm -v "${CONTAINER_NAME}" || echo "=== DEBUG: Container cleanup failed or already removed ==="
else
	echo "=== DEBUG: Preserving container (PRESERVE_CONTAINER=${PRESERVE_CONTAINER}) ==="
fi

echo "=== DEBUG: Build script completed ==="
echo "Done! Your image(s) should be in deploy/"
