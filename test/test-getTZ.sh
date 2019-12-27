#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/../testlib/init.rc

DEFINE_TEST "when given America/Denver, return MST7MDT"
RUN getTZ America/Denver
if gotExpectedOutput --exact "MST7MDT" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when given Foobar, return error"
RUN getTZ Foobar
if noOutput && \
   gotExpectedOutput --error --contains "no such" ; then
    SUCCESS
else
    FAILURE
fi

. cleanup.rc
