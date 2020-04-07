#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

PARMDB="${TESTDIR}/parmdb-cmdline-fake.sh"

TEST_OPT_PROCESSING_MIN=1

test1="$PARMDB -g foo"
expected1="opt=g
optarg=foo"

test2="$PARMDB -dgfoo"
expected2="opt=d
optarg=1
opt=g
optarg=foo"

test3="$PARMDB --get=foo"
expected3="opt=g
optarg=foo"

test4="$PARMDB --put=foo=bar"
expected4="opt=p
optarg=foo=bar"

test5="$PARMDB -p=foo=bar"
expected5="opt=p
optarg=foo=bar"

test6="$PARMDB -p foo=bar"
expected6="opt=p
optarg=foo=bar"

test7="$PARMDB --init=foo.rc"
expected7="opt=i
optarg=foo.rc"

test8="$PARMDB -i=foo.rc"
expected8="opt=i
optarg=foo.rc"

test9="$PARMDB -i foo.rc"
expected9="opt=i
optarg=foo.rc"

test10="$PARMDB -cs"
expected10="opt=c
optarg=1
opt=s
optarg=1"

test11="$PARMDB -sc"
expected11="opt=s
optarg=1
opt=c
optarg=1"

test12="$PARMDB -c -s"
expected12="opt=c
optarg=1
opt=s
optarg=1"

test13="$PARMDB --constant -s"
expected13="opt=c
optarg=1
opt=s
optarg=1"

test14="$PARMDB -c --secret"
expected14="opt=c
optarg=1
opt=s
optarg=1"

test15="$PARMDB --load-assignments=foo.rc"
expected15="opt=a
optarg=foo.rc"

test16="$PARMDB -a=foo.rc"
expected16="opt=a
optarg=foo.rc"

test17="$PARMDB -a foo.rc"
expected17="opt=a
optarg=foo.rc"

test18="$PARMDB -e"
expected18="opt=e
optarg=1"

test19="$PARMDB --load-env"
expected19="opt=e
optarg=1"

test20="$PARMDB -ce"
expected20="opt=c
optarg=1
opt=e
optarg=1"

test21="$PARMDB -f=foo"
expected21="opt=f
optarg=foo"

test22="$PARMDB --load-file=foo"
expected22="opt=f
optarg=foo"

test23="$PARMDB -lnames"
expected23="opt=l
optarg=names"

test24="$PARMDB -l names"
expected24="opt=l
optarg=names"

test25="$PARMDB --list"
expected25="opt=l
optarg=values"

test26="$PARMDB --list=names"
expected26="opt=l
optarg=names"

test27="$PARMDB -r foo"
expected27="opt=r
optarg=1"

test28="$PARMDB --run foo"
expected28="opt=r
optarg=1"

test29="$PARMDB -h"
expected29="opt=h
optarg=1"

test30="$PARMDB --help"
expected30="opt=h
optarg=1"

TEST_OPT_PROCESSING_MAX=30


TEST_COMMAND_LINE_MIN=31

test31="$PARMDB"
error31="is required"

test32="$PARMDB -gfoo -pbar"
error32="is allowed"

test33="$PARMDB -pbar -ifoo"
error33="is allowed"

test34="$PARMDB -ifoo -abar"
error34="is allowed"

test35="$PARMDB -abar -e"
error35="is allowed"

test36="$PARMDB -e -ffoo"
error36="is allowed"

test37="$PARMDB -ffoo -lnames"
error37="is allowed"

test38="$PARMDB -lnames -r"
error38="is allowed"

test39="$PARMDB -rh"
error39="is allowed"

test40="$PARMDB -lvalues"
expected40="l_opt=values"

test41="$PARMDB -lv"
expected41="l_opt=values"

test42="$PARMDB -lnames"
expected42="l_opt=names"

test43="$PARMDB -ln"
expected43="l_opt=names"

test44="$PARMDB -lsecrets"
expected44="l_opt=secrets"

test45="$PARMDB -ls"
expected45="l_opt=secrets"

test46="$PARMDB -lallvalues"
expected46="l_opt=allvalues"

test47="$PARMDB -la"
expected47="l_opt=allvalues"

test48="$PARMDB -lputs"
expected48="l_opt=puts"

test49="$PARMDB -lp"
expected49="l_opt=puts"

test50="$PARMDB -lbad"
error50="value must be one of"

test51="$PARMDB -gfoo -c"
error51="can only be used with"

test52="$PARMDB -afoo -c"
error52="can only be used with"

test53="$PARMDB -ec"
error53="can only be used with"

test54="$PARMDB -lv -c"
error54="can only be used with"

test55="$PARMDB -rc"
error55="can only be used with"

test56="$PARMDB -gfoo -s"
error56="can only be used with"

test57="$PARMDB -afoo -s"
error57="can only be used with"

test58="$PARMDB -es"
error58="can only be used with"

test59="$PARMDB -lv -s"
error59="can only be used with"

test60="$PARMDB -rs"
error60="can only be used with"

test61="$PARMDB -pfoo"
error61="requires an argument of the form"

test62="$PARMDB -pfoo.=val"
error62="does not specify a valid parameter name"

test63="$PARMDB -gfoo."
error63="does not specify a valid parameter name"

test64="$PARMDB --last=names"
error64="does not specify a valid parameter name"

test65="$PARMDB --env-default"
error65="can only be used with"

TEST_COMMAND_LINE_MAX=65

testnum=0
npassed=0
nfailed=0
while : ; do
    testnum=`expr $testnum + 1`
    if [ $testnum -ge $TEST_OPT_PROCESSING_MIN ] && \
       [ $testnum -le $TEST_OPT_PROCESSING_MAX ] ; then
        TEST_OPT_PROCESSING=y export TEST_OPT_PROCESSING
    else
        unset TEST_OPT_PROCESSING
    fi
    if [ $testnum -ge $TEST_COMMAND_LINE_MIN ] && \
       [ $testnum -le $TEST_COMMAND_LINE_MAX ] ; then
        TEST_COMMAND_LINE=y export TEST_COMMAND_LINE
    else
        unset TEST_COMMAND_LINE
    fi

    eval test="\"\$test${testnum}\""
    if [ ":$test" = ":" ] ; then
        break
    fi
    testdesc=`echo "${test}" | sed "s:$PARMDB:parmdb:"`
    DEFINE_TEST "Test cmdline $testdesc"
    eval expected="\"\$expected${testnum}\""
    if [ ":$expected" != ":" ] ; then
        RUN $test
        if gotExpectedOutput --exact "${expected}" ; then
            SUCCESS
        else
            FAILURE
        fi
        continue
    fi
    eval error="\"\$error${testnum}\""
    if [ ":$error" != ":" ] ; then
        RUN $test
        if gotExpectedOutput --error --contains "${expected}" ; then
            SUCCESS
        else
            FAILURE
        fi
        continue
    fi
    echo "  No assertions!" >>$REPORT
    FAILURE
done

. cleanup.rc
