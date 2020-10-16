#!/bin/bash -e

cat > /etc/crankshaft.date << EOF
${IMG_DATE}
EOF

cat > /etc/crankshaft.build << EOF
${GIT_HASH}
EOF

cat > /etc/crankshaft.branch << EOF
${GIT_BRANCH}
EOF
