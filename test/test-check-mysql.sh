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

ERROR_SIM_MARKER=$TMPDIR/mysql-error-sim

touch $ERROR_SIM_MARKER

DEFINE_TEST "when mysql returns error, non-zero retval, no output"
RUN $SCRIPTDIR/check-mysql </dev/null
if gotExpectedOutput --retval --regex "^[^0]" && \
   noOutput && \
   noOutput --error 
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when mysql returns error, check-mysql -v return error, error output"
RUN $SCRIPTDIR/check-mysql -v </dev/null
if gotExpectedOutput --error --contains "Simulated error" ; then
    SUCCESS
else
    FAILURE
fi

rm $ERROR_SIM_MARKER

DEFINE_TEST "when mysql returns 0, 0 retval, no output"
RUN $SCRIPTDIR/check-mysql </dev/null
if gotExpectedOutput --retval --regex "^0" && \
   noOutput && \
   noOutput --error 
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when mysql returns 0, check-mysql -v has 0 retval, no output"
RUN $SCRIPTDIR/check-mysql -v </dev/null
if gotExpectedOutput --retval --exact "0" && \
   noOutput && \
   noOutput --error 
then
    SUCCESS
else
    FAILURE
fi

SLEEP_SECS=1 export SLEEP_SECS
DEFINE_TEST "when mysql returns 0, check-mysql -w 3 returns 0, no output"
RUN $SCRIPTDIR/check-mysql -v -w3 </dev/null
if gotExpectedOutput --retval --exact "0" && \
   noOutput && \
   noOutput --error 
then
    SUCCESS
else
    FAILURE
fi

touch $ERROR_SIM_MARKER
DEFINE_TEST "when mysql returns err, check-mysql -w 3 returns err after 3 sec"
starttime=`date +%s`
RUN $SCRIPTDIR/check-mysql -w3 </dev/null
endtime=`date +%s`
elapsed=`expr $endtime - $starttime`
if gotExpectedOutput --retval --regex "^[^0]" && \
   noOutput && \
   noOutput --error && \
   [ $elapsed -ge 3 ]
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when mysql returns err, check-mysql -vw 3 returns err output after 3 sec"
starttime=`date +%s`
RUN $SCRIPTDIR/check-mysql -vw3 </dev/null
endtime=`date +%s`
elapsed=`expr $endtime - $starttime`
if gotExpectedOutput --retval --regex "^[^0]" && \
   noOutput && \
   gotExpectedOutput --error --contains "Simulated error" && \
   [ $elapsed -ge 3 ]
then
    SUCCESS
else
    FAILURE
fi

DEFINE_TEST "when mysql returns err for 1 sec, check-mysql -w 3 returns 0 before 3 s"
starttime=`date +%s`
(sleep 1 ; rm $ERROR_SIM_MARKER) &
RUN $SCRIPTDIR/check-mysql -w3 </dev/null
endtime=`date +%s`
elapsed=`expr $endtime - $starttime`
if gotExpectedOutput --retval --contains "0" && \
   noOutput && \
   noOutput --error && \
   [ $elapsed -lt 3 ]
then
    SUCCESS
else
    FAILURE
fi

. cleanup.rc
