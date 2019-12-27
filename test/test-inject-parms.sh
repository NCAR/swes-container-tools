#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

mkdir $TMPDIR/in.d
outdir=$TMPDIR/out.d
infile1=$TMPDIR/in.d/infile1
cat >$infile1 <<'EOF'
first
$testvar
${testvar}
`parmdb -gtestvar`
last
EOF

PARM_DB=
export PARM_DB
DEFINE_TEST "when PARM_DB not set, error"
RUN $SCRIPTDIR/inject-parms $infile1 $outdir
if gotExpectedOutput --error --contains "PARM_DB must be set" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

PARM_DB=$TMPDIR/parmdb.d
export PARM_DB

DEFINE_TEST "when \$PARM_DB not a directory, error"
RUN $SCRIPTDIR/inject-parms $infile1 $outdir
if gotExpectedOutput --error --contains "not a directory" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

mkdir $PARM_DB

DEFINE_TEST "when no args, error"
RUN $SCRIPTDIR/inject-parms
if gotExpectedOutput --error --contains "arguments are required" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when one arg, error"
RUN $SCRIPTDIR/inject-parms foo
if gotExpectedOutput --error --contains "arguments are required" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when non-existent input file, error"
RUN $SCRIPTDIR/inject-parms $TMPDIR/nosuch $TMPDIR/out
if gotExpectedOutput --error --contains "no such file" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

mkdir $TMPDIR/dummy.d
touch $TMPDIR/dummy
DEFINE_TEST "when output file and input dir, error"
RUN $SCRIPTDIR/inject-parms $TMPDIR/dummy.d $TMPDIR/dummy
if gotExpectedOutput --error --contains "not allowed" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

cat >$TMPDIR/expected1 <<EOF
first



last
EOF

rm -f $outdir/infile1

DEFINE_TEST "when referenced parm not defined, empty strings injected"
RUN $SCRIPTDIR/inject-parms $infile1 $outdir
if noOutput && \
   noOutput --error && \
   fileEquals $outdir/infile1 $TMPDIR/expected1
then
    SUCCESS
else
    FAILURE
fi

parmdb -ptestvar=testval

cat >$TMPDIR/expected1 <<EOF
first
testval
testval
testval
last
EOF
rm -f $outdir/infile1

DEFINE_TEST "when referenced parm defined, value injected"
RUN $SCRIPTDIR/inject-parms $infile1 $outdir
if noOutput && \
   noOutput --error && \
   fileEquals $outdir/infile1 $TMPDIR/expected1
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when file already exists and no --force, error"
RUN $SCRIPTDIR/inject-parms $infile1 $outdir
if noOutput && \
   gotExpectedOutput --error --contains "file already exists"
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when file already exists and --force, no error"
RUN $SCRIPTDIR/inject-parms --force $infile1 $outdir
if noOutput && \
   noOutput --error && \
   fileEquals $outdir/infile1 $TMPDIR/expected1
then
    SUCCESS
else
    FAILURE
fi

infile2=$TMPDIR/in.d/infile2
expected2=$TMPDIR/expected2
cat >$infile2 <<'EOF'
first
\$testvar
\${testvar}
\`parmdb -gtestvar\`
last
EOF
cat >$expected2 <<'EOF'
first
$testvar
${testvar}
`parmdb -gtestvar`
last
EOF


DEFINE_TEST "when template file refs escaped, value not injected"
RUN $SCRIPTDIR/inject-parms $infile2 $outdir
if noOutput && \
   noOutput --error && \
   fileEquals $outdir/infile2 $expected2
then
    SUCCESS
else
    FAILURE
fi

. cleanup.rc
