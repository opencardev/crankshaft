#!/bin/bash

source /opt/crankshaft/crankshaft_system_env.sh

BASH_SCRIPT=/boot/crankshaft/startup.sh
PYTHON_SCRIPT=/boot/crankshaft/startup.py

if [ -f ${BASH_SCRIPT} ] ; then
    log_echo "User bash script starting..."
    /bin/bash ${BASH_SCRIPT} &
fi

if [ -f ${PYTHON_SCRIPT} ] ; then
    log_echo "User python script starting..."
    /usr/bin/python ${PYTHON_SCRIPT} &
fi

exit 0
