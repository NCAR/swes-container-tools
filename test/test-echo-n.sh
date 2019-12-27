#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

echo "hello" >$TMPFILE
echo "there" >>$TMPFILE
DEFINE_TEST "when \"echo hello\", final newline included"
RUN sh -c 'echo "hello" ; echo there'
if fileEquals ${OUT} ${TMPFILE} ; then
    SUCCESS
else
    FAILURE
fi

echo "hellothere" >$TMPFILE
DEFINE_TEST "when \"echo-n hello\", no final newline"
RUN sh -c 'echo-n "hello" ; echo there'
if fileEquals ${OUT} ${TMPFILE} ; then
    SUCCESS
else
    FAILURE
fi


. cleanup.rc
