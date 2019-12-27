#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/../testlib/init.rc

re='[a-zA-Z0-9+/]'

DEFINE_TEST "given no arg, return 43-char rand string"
RUN random
if gotExpectedOutput --regex "^$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re$re\$" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "given arg 6, return 8-char rand string"
RUN random 6
if gotExpectedOutput --regex "^$re$re$re$re$re$re$re$re\$" ; then
    SUCCESS
else
    FAILURE
fi

. cleanup.rc
