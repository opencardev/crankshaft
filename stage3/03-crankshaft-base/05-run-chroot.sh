#!/bin/bash -e

cat > /etc/crankshaft.date << EOF
${BUILDDATE}
EOF

cat > /etc/crankshaft.build << EOF
${BUILDHASH}
EOF

cat > /etc/crankshaft.branch << EOF
${BUILDBRANCH}
EOF
