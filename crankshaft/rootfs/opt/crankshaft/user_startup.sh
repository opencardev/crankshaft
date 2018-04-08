#!/bin/bash

BASH_SCRIPT=/boot/crankshaft/startup.sh
PYTHON_SCRIPT=/boot/crankshaft/startup.py

if [ -f ${BASH_SCRIPT} ] ; then
	/bin/bash ${BASH_SCRIPT}
fi

if [ -f ${PYTHON_SCRIPT} ] ; then
	/usr/bin/python ${PYTHON_SCRIPT}
fi

exit 0
