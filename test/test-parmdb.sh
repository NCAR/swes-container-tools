#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc


#
# Note: all tests are run serially, and later ones depend on earlier ones
#

DEFINE_TEST "when PARM_DB not set, fail"
unset PARM_DB
RUN parmdb -pfoo=bar

if gotExpectedOutput --error --contains "PARM_DB must be set" ; then
    SUCCESS
else
    FAILURE
fi


DEFINE_TEST "when PARM_DB not a directory, fail"
PARM_DB=$TMPDIR/parmdb.d export PARM_DB
RUN parmdb -pfoo=bar

if gotExpectedOutput --error --contains "not a directory" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when PARM_DB valid and -g var, no output, no error"
mkdir ${PARM_DB} || exit 1
RUN parmdb -g var

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db empty -l names, no output, no error"
RUN parmdb -lnames

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db empty -l secrets, no output, no error"
RUN parmdb -lsecrets

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db empty -l value, no output, no error"
RUN parmdb -lvalue

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db empty -l allvalues, no output, no error"
RUN parmdb -lallvalues

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db empty -l puts, no output, no error"
RUN parmdb -lputs

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db empty -r echo hello, output contains hello"
RUN parmdb -r echo hello

if gotExpectedOutput --exact "hello" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -pfoo=bar, no output, no error"
RUN parmdb -p foo=bar

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has foo=bar, when -g foo, output is bar"
RUN parmdb -g foo

if gotExpectedOutput --exact bar ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has foo=bar, -lvalues returns foo='bar'"
RUN parmdb -lvalues

if gotExpectedOutput --exact "foo='bar'" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has foo=bar, -lnames returns foo"
RUN parmdb -lnames

if gotExpectedOutput --exact "foo" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has foo=bar, -lsecrets returns nothing"
RUN parmdb -lsecrets

if gotExpectedOutput --exact "" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -pfoo=baz -s, no output, no error"
RUN parmdb -p foo=baz -s

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has secret foo=baz, -lvalues, returns hidden val"
RUN parmdb -l values

if gotExpectedOutput --exact foo=- ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has secret foo=baz, -lallvalues, returns val"
RUN parmdb -l allvalues

if gotExpectedOutput --exact "foo='baz'" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has secret foo=baz, -lputs, returns val"
RUN parmdb -l puts

if gotExpectedOutput --exact "parmdb --secret --put=foo='baz'" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -pfoo=bat -c, no output, no error"
RUN parmdb -p foo=bat -c

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -pfoo=bar with constant foo, no output, warning"
RUN parmdb -p foo=bar

if gotExpectedOutput --error --contains "cannot be changed" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -c change attempted on constant, no change"
RUN parmdb -g foo

if gotExpectedOutput --exact "bat" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db has constant secret foo, -lnames returns foo"
RUN parmdb -lnames

if gotExpectedOutput --exact "foo" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when db constant secret foo, -lsecrets returns foo"
RUN parmdb -lsecrets

if gotExpectedOutput --exact "foo" ; then
    SUCCESS
else
    FAILURE
fi

cat >${TMPDIR}/init1.rc <<EOF
greeting=`echo hello`
 indent=test
pwd
EOF

DEFINE_TEST "when --init with rc file, no output no error"
RUN parmdb -i ${TMPDIR}/init1.rc

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when --init set greeting using backtics, greeting parm is set"
RUN parmdb -g greeting

if gotExpectedOutput --exact "hello" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when --init set indent with leading spaces, indent parm is set"
RUN parmdb -g indent

if gotExpectedOutput --exact "test" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when --init -c with rc file using backtics, no output no error"
RUN parmdb -i ${TMPDIR}/init1.rc -c

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -pgreeting=... against init constants, no output, warning"
RUN parmdb -pgreeting=hola

if gotExpectedOutput --error --contains "cannot be changed" ; then
    SUCCESS
else
    FAILURE
fi

cat >${TMPDIR}/loadfile1.rc <<'EOF'
#comment

var1=val1
 var2=val2
var3=val3\
 with a newline
EOF

DEFINE_TEST "when --load-file with file, no output no error"
RUN parmdb -f ${TMPDIR}/loadfile1.rc

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when --load-file set three undefined parms, nothing is set"
RUN parmdb -lnames

expected="foo
greeting
indent"
if gotExpectedOutput --exact "$expected" ; then
    SUCCESS
else
    FAILURE
fi

parmdb -p var1=init
parmdb -p var2=init
parmdb -p var3=init

DEFINE_TEST "when --load-file with file, no output no error"
RUN parmdb -f ${TMPDIR}/loadfile1.rc

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when --load-file set three defined parms, all are set"
RUN parmdb -lvalues
exp3='var3='\''val3
with a newline'
if gotExpectedOutput --contains "var1='val1'" &&
   gotExpectedOutput --contains "var2='val2'" &&
   gotExpectedOutput --contains "$exp3" ; then
    SUCCESS
else
    FAILURE
fi

var1=env1
var2=env2
var3=env3
var4=env4
export var1 var2 var3 var4

DEFINE_TEST "when --load-env, no output no error"
RUN parmdb -e

if noOutput && noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when --load-env set three defined parms, all are set"
RUN parmdb -lvalues

if gotExpectedOutput --contains "var1='env1'" &&
   gotExpectedOutput --contains "var2='env2'" &&
   gotExpectedOutput --contains "var3='env3'" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when --load-env set undefined parms, none are set"
RUN parmdb -gvar4

if noOutput ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -r printenv, all parms shown"
RUN parmdb -r printenv

if 
   gotExpectedOutput --contains "greeting=hello" &&
   gotExpectedOutput --contains "indent=test" &&
   gotExpectedOutput --contains "foo=bat" &&
   gotExpectedOutput --contains "var1=env1" &&
   gotExpectedOutput --contains "var2=env2" &&
   gotExpectedOutput --contains "var3=env3" ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when -l puts, output can recreate parmdb"
RUN parmdb -l puts
echo "#!/bin/sh" >$TMPDIR/cmds
cat $OUT >>$TMPDIR/cmds
chmod +x $TMPDIR/cmds
mkdir $TMPDIR/parmdb2.d
PARM_DB=$TMPDIR/parmdb2.d $TMPDIR/cmds

if
   fileEquals $TMPDIR/parmdb.d/foo      $TMPDIR/parmdb2.d/foo && \
   fileEquals $TMPDIR/parmdb.d/greeting $TMPDIR/parmdb2.d/greeting && \
   fileEquals $TMPDIR/parmdb.d/indent   $TMPDIR/parmdb2.d/indent && \
   fileEquals $TMPDIR/parmdb.d/var1     $TMPDIR/parmdb2.d/var1 && \
   fileEquals $TMPDIR/parmdb.d/var2     $TMPDIR/parmdb2.d/var2 && \
   fileEquals $TMPDIR/parmdb.d/var3     $TMPDIR/parmdb2.d/var3
then
    SUCCESS
else
    FAILURE
fi

. cleanup.rc
