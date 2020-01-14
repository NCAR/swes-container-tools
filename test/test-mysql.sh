#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

# using $TESTDIR/mysql fake

DBLOGIN=dbuser
DBHOST=dbhost
DBPASSWORD=dbpassword
DBNAME=
MYSQL_DATABASE=db
export DBLOGIN DBHOST DBPASSWORD DBNAME MYSQL_DATABASE

DEFINE_TEST "when DBLOGIN missing, error"
DBLOGIN= export DBLOGIN
RUN $SCRIPTDIR/mysql
if gotExpectedOutput --error --contains " environment variables are missing" ; then
    SUCCESS
else
    FAILURE
fi
DBLOGIN=dbuser export DBLOGIN

DEFINE_TEST "when DBHOST missing, error"
DBHOST= export DBHOST
RUN $SCRIPTDIR/mysql
if gotExpectedOutput --error --contains " environment variables are missing" ; then
    SUCCESS
else
    FAILURE
fi
DBHOST=dbhost export DBHOST

DEFINE_TEST "when DBPASSWORD missing, error"
DBPASSWORD= export DBPASSWORD
RUN $SCRIPTDIR/mysql
if gotExpectedOutput --error --contains " environment variables are missing" ; then
    SUCCESS
else
    FAILURE
fi
DBPASSWORD=dbpassword export DBPASSWORD

DEFINE_TEST "when DBNAME and MYSQL_DATABASE missing, error"
MYSQL_DATABASE= export MYSQL_DATABASE
DBNAME= export DBNAME
RUN $SCRIPTDIR/mysql
if gotExpectedOutput --error --contains " environment variables are missing" ; then
    SUCCESS
else
    FAILURE
fi
MYSQL_DATABASE=db export MYSQL_DATABASE

DEFINE_TEST "when DBNAME and MYSQL_DATABASE missing, error"
MYSQL_DATABASE= export MYSQL_DATABASE
DBNAME= export DBNAME
RUN $SCRIPTDIR/mysql
if gotExpectedOutput --error --contains " environment variables are missing" ; then
    SUCCESS
else
    FAILURE
fi
MYSQL_DATABASE=db export MYSQL_DATABASE

DEFINE_TEST "when all required envvars set, no error"
RUN $SCRIPTDIR/mysql </dev/null
if noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when no error, mysql runs with expected args and cnf file"
RUN $SCRIPTDIR/mysql </dev/null
expected="[client]
user = $DBLOGIN
password = $DBPASSWORD
host = $DBHOST
sport = $DBPORT"
if gotExpectedOutput --regex "Args:.*--defaults-extra-file=.* db$" && \
   gotExpectedOutput --contains "[client]" && \
   gotExpectedOutput --contains "user = $DBLOGIN" && \
   gotExpectedOutput --contains "password = $DBPASSWORD" && \
   gotExpectedOutput --contains "host = $DBHOST" && \
   gotExpectedOutput --contains "port = $DBPORT"
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when MYSQL_DATABASE missing but DBNAME set, no error"
MYSQL_DATABASE= export MYSQL_DATABASE
DBNAME=db export DBNAME
RUN $SCRIPTDIR/mysql </dev/null
if noOutput --error ; then
    SUCCESS
else
    FAILURE
fi
MYSQL_DATABASE=db export MYSQL_DATABASE
DBNAME= export DBNAME

DEFINE_TEST "when required envvars are in parmdb, no error"
PARM_DB=$TMPDIR/parmdb export PARM_DB
mkdir $PARM_DB
for parm in DBLOGIN DBHOST DBPASSWORD DBNAME MYSQL_DATABASE ; do
    eval val="\"\$${parm}\""
    $SCRIPTDIR/parmdb --put=${parm}="${val}"
done
unset DBLOGIN DBHOST DBPASSWORD DBNAME MYSQL_DATABASE
RUN $SCRIPTDIR/mysql </dev/null
if noOutput --error ; then
    SUCCESS
else
    FAILURE
fi

. cleanup.rc
