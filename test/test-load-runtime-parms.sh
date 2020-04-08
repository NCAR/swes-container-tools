#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

unset PARM_DB SECRETS_DIR APPNAME
unset AWS_S3_BUCKET AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY \
      AWS_DEFAULT_REGION AWS_DEFAULT_OUTPUT

DEFINE_TEST "when PARM_DB not set, error"
RUN $SCRIPTDIR/load-runtime-parms
if gotExpectedOutput --error --contains "PARM_DB must be set" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

PARM_DB=$TMPDIR/parmdb.d export PARM_DB
mkdir -p $PARM_DB  || exit 1

DEFINE_TEST "when PARM_DB set, SECRETS_DIR and APPNAME not set, error"
RUN $SCRIPTDIR/load-runtime-parms
if gotExpectedOutput --error --contains "must be set" && \
   noOutput
then
    SUCCESS
else
    FAILURE
fi

mkdir -p $TMPDIR/secrets

SECRETS_DIR=$TMPDIR/secrets export SECRETS_DIR
APPNAME=test export APPNAME
DEFINE_TEST "when PARM_DB, SECRETS_DIR, APPNAME envvars set, no error"
RUN $SCRIPTDIR/load-runtime-parms
if noOutput &&
   noOutput --error
then
    SUCCESS
else
    FAILURE
fi

unset SECRETS_DIR APPNAME
parmdb --put=SECRETS_DIR=$TMPDIR/secrets
parmdb --put=APPNAME=test
DEFINE_TEST "when PARM_DB, SECRETS_DIR, APPNAME parms set, no error"
RUN $SCRIPTDIR/load-runtime-parms
if noOutput &&
   noOutput --error
then
    SUCCESS
else
    FAILURE
fi

SECRETS_DIR=$TMPDIR/secrets export SECRETS_DIR
APPNAME=test export APPNAME

DEFINE_TEST "Given parm value in environment, value is applied"
parmdb --put=var1=
var1=val1 export var1
RUN $SCRIPTDIR/load-runtime-parms
val=`parmdb --get=var1`
echo "var1=$val" >>$OUT
if noOutput --error &&
   gotExpectedOutput --contains "var1=val1"
then
    SUCCESS
else
    FAILURE
fi

AWS_S3_BUCKET="badval" export AWS_S3_BUCKET

DEFINE_TEST "Given invalid AWS_S3_BUCKET value, error"
RUN $SCRIPTDIR/load-runtime-parms
if noOutput &&
   gotExpectedOutput --error --contains "invalid AWS_S3_BUCKET value"
then
    SUCCESS
else
    FAILURE
fi

AWS_S3_BUCKET="s3://mybucket" export AWS_S3_BUCKET
DEFINE_TEST "Given valid AWS_S3_BUCKET but no creds, error"
RUN $SCRIPTDIR/load-runtime-parms
if noOutput &&
   gotExpectedOutput --error --contains "AWS_ACCESS_KEY_ID must be set" &&
   gotExpectedOutput --error --contains "AWS_SECRET_ACCESS_KEY must be set"
then
    SUCCESS
else
    FAILURE
fi


AWS_ACCESS_KEY_ID=test_id export AWS_ACCESS_KEY_ID
AWS_SECRET_ACCESS_KEY=test_key export AWS_SECRET_ACCESS_KEY
AWS_DEFAULT_REGION=test_region export AWS_DEFAULT_REGION
AWS_DEFAULT_OUTPUT=test_output export AWS_DEFAULT_OUTPUT

DEFINE_TEST "Given valid AWS parms, aws cli is called"
aws --init-test
RUN $SCRIPTDIR/load-runtime-parms
aws --show-test >>$OUT
if noOutput --error &&
   gotExpectedOutput --contains "aws s3 cp ${AWS_S3_BUCKET} ${SECRETS_DIR}/${APPNAME}/s3 --recursive"
then
    SUCCESS
else
    FAILURE
fi

unset AWS_S3_BUCKET
mkdir -p ${SECRETS_DIR}/${APPNAME}
echo "var2=val2" >${SECRETS_DIR}/test.cnf
echo "var3=val3" >>${SECRETS_DIR}/test.cnf
echo "var4=val4" >${SECRETS_DIR}/${APPNAME}/test.cnf
parmdb --put=var2=
parmdb --put=var3=
parmdb --put=var4=

DEFINE_TEST "Given .cnf files, all files are processed"
RUN $SCRIPTDIR/load-runtime-parms
val=`parmdb --get=var2`
echo "var2=$val" >>$OUT
val=`parmdb --get=var3`
echo "var3=$val" >>$OUT
val=`parmdb --get=var4`
echo "var4=$val" >>$OUT
if noOutput --error &&
   gotExpectedOutput --contains "var2=val2" &&
   gotExpectedOutput --contains "var3=val3" &&
   gotExpectedOutput --contains "var4=val4"
then
    SUCCESS
else
    FAILURE
fi

echo "val5" >${SECRETS_DIR}/var5
echo "val6" >${SECRETS_DIR}/${APPNAME}/var6
parmdb --put=var5=
parmdb --put=var6=

DEFINE_TEST "Given parm files, all files are processed"
RUN $SCRIPTDIR/load-runtime-parms
val=`parmdb --get=var5`
echo "var5=$val" >>$OUT
val=`parmdb --get=var6`
echo "var6=$val" >>$OUT
if noOutput --error &&
   gotExpectedOutput --contains "var5=val5" &&
   gotExpectedOutput --contains "var6=val6"
then
    SUCCESS
else
    FAILURE
fi


. cleanup.rc
