#!/bin/sh
# Wrapper script for testing ../lib/parmdb-getopts.rc ../lib/parmdb-cmdline.rc
TESTDIR=`cd \`dirname $0\`; pwd`
SCRIPTDIR=`dirname $TESTDIR`

. $SCRIPTDIR/lib/parmdb-getopts.rc
if [ ":$TEST_OPT_PROCESSING" != ":" ] ; then
    exit 0
fi
. $SCRIPTDIR/lib/parmdb-cmdline.rc
if [ ":$TEST_COMMAND_LINE" != ":" ] ; then
    exit 0
fi

exit 0
