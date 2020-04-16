#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

DEFINE_TEST "when given no arguments, error"
RUN define-parms
if noOutput &&
    gotExpectedOutput --error --contains "expecting one or more file arguments"
then
    SUCCESS
else
    FAILURE
fi

RCFILE=$TMPDIR/foo.rc
touch $RCFILE

unset PARM_DB

DEFINE_TEST "when PARM_DB not set, error"
RUN define-parms $RCFILE
if noOutput &&
    gotExpectedOutput --error --contains "variable must be set"
then
    SUCCESS
else
    FAILURE
fi

PARM_DB=$TMPDIR/parmdb.d export PARM_DB
DEFINE_TEST "when \$PARM_DB not a directory, error"
RUN define-parms $RCFILE
if noOutput &&
    gotExpectedOutput --error --contains "does not identify a directory"
then
    SUCCESS
else
    FAILURE
fi

mkdir ${PARM_DB} || exit 1

DEFINE_TEST "when given empty file, no output, no error, no parms defined"
RUN define-parms $RCFILE
parmdb --list >>$OUT
if noOutput &&
   noOutput --error
then
    SUCCESS
else
    FAILURE
fi

cat >$RCFILE <<'EOF'
myfile=filea
const mydir=/tmp
param myfile=$mydir/$myfile
secret mysecret=foo
EOF

DEFINE_TEST "when given file with defs, no output, no error, parms defined"
RUN define-parms $RCFILE
parmdb --list >>$OUT
if noOutput --error &&
    gotExpectedOutput --contains "mydir='/tmp'" &&
    gotExpectedOutput --contains "myfile='/tmp/filea'" &&
    gotExpectedOutput --contains "mysecret=-"
then
    SUCCESS
else
    FAILURE
fi

. cleanup.rc
