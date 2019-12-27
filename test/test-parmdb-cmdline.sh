#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

PARMDB="${TESTDIR}/parmdb-cmdline-fake.sh"

TEST_OPT_PROCESSING_MIN=1

test1="$PARMDB -g foo"
expected1="opt=g
optarg=foo"

test2="$PARMDB -gfoo"
expected2="opt=g
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

test15="$PARMDB --load-file=foo.rc"
expected15="opt=f
optarg=foo.rc"

test16="$PARMDB -f=foo.rc"
expected16="opt=f
optarg=foo.rc"

test17="$PARMDB -f foo.rc"
expected17="opt=f
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

test21="$PARMDB -lnames"
expected21="opt=l
optarg=names"

test22="$PARMDB -l names"
expected22="opt=l
optarg=names"

test23="$PARMDB --list"
expected23="opt=l
optarg=values"

test24="$PARMDB --list=names"
expected24="opt=l
optarg=names"

test25="$PARMDB -r foo"
expected25="opt=r
optarg=1"

test26="$PARMDB --run foo"
expected26="opt=r
optarg=1"

test27="$PARMDB -h"
expected27="opt=h
optarg=1"

test28="$PARMDB --help"
expected28="opt=h
optarg=1"

TEST_OPT_PROCESSING_MAX=28


TEST_COMMAND_LINE_MIN=29

test29="$PARMDB"
error29="is required"

test30="$PARMDB -gfoo -pbar"
error30="is allowed"

test31="$PARMDB -pbar -ifoo"
error31="is allowed"

test32="$PARMDB -ifoo -fbar"
error32="is allowed"

test33="$PARMDB -fbar -e"
error33="is allowed"

test34="$PARMDB -e -lnames"
error34="is allowed"

test35="$PARMDB -lnames -r"
error35="is allowed"

test36="$PARMDB -rh"
error36="is allowed"

test37="$PARMDB -lvalues"
expected37="l_opt=values"

test38="$PARMDB -lv"
expected38="l_opt=values"

test39="$PARMDB -lnames"
expected39="l_opt=names"

test40="$PARMDB -ln"
expected40="l_opt=names"

test41="$PARMDB -lsecrets"
expected41="l_opt=secrets"

test42="$PARMDB -ls"
expected42="l_opt=secrets"

test43="$PARMDB -lallvalues"
expected43="l_opt=allvalues"

test44="$PARMDB -la"
expected44="l_opt=allvalues"

test45="$PARMDB -lputs"
expected45="l_opt=puts"

test46="$PARMDB -lp"
expected46="l_opt=puts"

test47="$PARMDB -lbad"
error47="value must be one of"

test48="$PARMDB -gfoo -c"
error48="can only be used with"

test49="$PARMDB -ffoo -c"
error49="can only be used with"

test50="$PARMDB -ec"
error50="can only be used with"

test51="$PARMDB -lv -c"
error51="can only be used with"

test52="$PARMDB -rc"
error52="can only be used with"

test53="$PARMDB -gfoo -s"
error53="can only be used with"

test54="$PARMDB -ffoo -s"
error54="can only be used with"

test55="$PARMDB -es"
error55="can only be used with"

test56="$PARMDB -lv -s"
error56="can only be used with"

test57="$PARMDB -rs"
error57="can only be used with"

test58="$PARMDB -pfoo"
error58="requires an argument of the form"

test59="$PARMDB -pfoo.=val"
error59="does not specify a valid parameter name"

test60="$PARMDB -gfoo."
error60="does not specify a valid parameter name"

test61="$PARMDB --last=names"
error61="does not specify a valid parameter name"

TEST_COMMAND_LINE_MAX=61

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
    if [[ ":$test" = ":" ]] ; then
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
