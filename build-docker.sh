#!/bin/bash -eu

DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

BUILD_OPTS="$*"

DOCKER="docker"

PROJECTNAME='crankshaft'
BUILDSCRIPT="build-crankshaft-ng-full.sh"
# BUILDSCRIPT="build-crankshaft-ng-short.sh"

if ! ${DOCKER} ps >/dev/null 2>&1; then
	DOCKER="sudo docker"
fi
if ! ${DOCKER} ps >/dev/null; then
	echo "error connecting to docker:"
	${DOCKER} ps
	exit 1
fi

# Check that the file given (config) exists where we expect it to.
function check_file
{
	local myTmp0="${1}"	# Variable to check.
	local myTmp1=""		# Value of the variable to check.
	local myTmp2=""

	eval myTmp1='$'${myTmp0}

	# echo "DEBUG: myTmp0=>${myTmp0}<"
	# echo "DEBUG: myTmp1=>${myTmp1}<"

	# Ensure that the file is an absolute path
	if test -x /usr/bin/realpath; then
		myTmp2=$(realpath -s "${myTmp1}" || realpath "${myTmp1}")
		myTmp1="${myTmp2}"
	fi

	# echo "DEBUG: myTmp2=>${myTmp2}<"

	# Ensure that the confguration file is present
	if test -z "${myTmp1}"; then
		echo "File ${myTmp1} not found in ${DIR} or path provided not absolute."
		exit 1
	else
		eval ${myTmp0}="${myTmp1}"
		return 0
	fi
}

CONFIG_FILE=""
if [ -f "${DIR}/config" ]; then
	CONFIG_FILE="${DIR}/config"
fi

while getopts ":T:c:e:" flag
do
	case "${flag}" in
		T) # Hostname Tag/suffix
			HOST_SUFFIX="${OPTARG}"
			echo "Host suffix set to: >${HOST_SUFFIX}<"
			;;
		e) # Not fully implemented yet.
			EXTRA_CONFIG_FILE="${OPTARG}"
			echo "Including extra config file >${EXTRA_CONFIG_FILE}<"
			;;
		c) # Not fully implemented yet.
			CONFIG_FILE="${OPTARG}"
			echo "Including config file >${CONFIG_FILE}<"
			;;
		*)
			echo "We don't know what we got."
			;;
	esac
done

HOST_SUFFIX=${HOST_SUFFIX:-devel} ; export HOST_SUFFIX

check_file CONFIG_FILE
source "${CONFIG_FILE}"

# EXTRA_CONFIG_FILE="" ; export EXTRA_CONFIG_FILE
# check_file EXTRA_CONFIG_FILE
# [ ! -z "${EXTRA_CONFIG_FILE}" ] && source "${EXTRA_CONFIG_FILE}"

CONTAINER_NAME=${CONTAINER_NAME:-${PROJECTNAME}}
CONTINUE=${CONTINUE:-0}
PRESERVE_CONTAINER=${PRESERVE_CONTAINER:-0}

if [ -z "${IMG_NAME}" ]; then
	echo "IMG_NAME not set in 'config'" 1>&2
	echo 1>&2
exit 1
fi

# Ensure the Git Hash is recorded before entering the docker container
GIT_HASH=${GIT_HASH:-"$(git rev-parse HEAD)"}

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

${DOCKER} build -t ${PROJECTNAME} "${DIR}"
if [ "${CONTAINER_EXISTS}" != "" ]; then
	trap 'echo "got CTRL+C... please wait 5s" && ${DOCKER} stop -t 5 ${CONTAINER_NAME}_cont' SIGINT SIGTERM
	time ${DOCKER} run --rm --privileged \
		--volume "${CONFIG_FILE}":/config:ro \
		-e "GIT_HASH=${GIT_HASH}" \
		--volumes-from="${CONTAINER_NAME}" --name "${CONTAINER_NAME}_cont" \
		${PROJECTNAME} \
		bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
	cd /${PROJECTNAME}; ./build.sh ${BUILD_OPTS} &&
	rsync -av work/*/build.log deploy/" &
	wait "$!"
else
	trap 'echo "got CTRL+C... please wait 5s" && ${DOCKER} stop -t 5 ${CONTAINER_NAME}' SIGINT SIGTERM
	time ${DOCKER} run --name "${CONTAINER_NAME}" --privileged \
		--volume "${CONFIG_FILE}":/config:ro \
		-e "GIT_HASH=${GIT_HASH}" \
		${PROJECTNAME} \
		bash -e -o pipefail -c "dpkg-reconfigure qemu-user-static &&
	cd /${PROJECTNAME}; ./build.sh ${BUILD_OPTS} &&
	rsync -av work/*/build.log deploy/" &
	wait "$!"
fi
echo "copying results from deploy/"
${DOCKER} cp "${CONTAINER_NAME}":/${PROJECTNAME}/deploy .
ls -lah deploy

# cleanup
if [ "${PRESERVE_CONTAINER}" != "1" ]; then
	${DOCKER} rm -v "${CONTAINER_NAME}"
fi

echo "Done! Your image(s) should be in deploy/"
