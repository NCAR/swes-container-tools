#!/bin/sh
TESTS="
  test-echo-n.sh
  test-random.sh
  test-getTZ.sh
  test-parmdb-cmdline.sh
  test-parmdb.sh
  test-parmdb.sh
  test-define-parms.sh
  test-mysql.sh
  test-check-mysql.sh
  test-inject-parms.sh
  test-load-certs.sh
  test-load-runtime-parms.sh
"
TESTDIR=`cd \`dirname $0\`; pwd`

nfailed=0
for t in ${TESTS} ; do
    echo "Running $t..."
    $TESTDIR/$t
    rc=$?
    if [ $rc -gt 128 ] ; then
        rc=1
    fi
    nfailed=`expr $nfailed + $rc`
    echo
done
exit $nfailed
