#!/bin/sh
# Wrapper script for testing ../parmdb-getopts.rc ../parmdb-cmdline.rc
TESTDIR=`cd \`dirname $0\`; pwd`
SCRIPTDIR=`dirname $TESTDIR`

. $SCRIPTDIR/.parmdb-getopts.rc
if [ ":$TEST_OPT_PROCESSING" != ":" ] ; then
    exit 0
fi
. $SCRIPTDIR/.parmdb-cmdline.rc
if [ ":$TEST_COMMAND_LINE" != ":" ] ; then
    exit 0
fi

exit 0
