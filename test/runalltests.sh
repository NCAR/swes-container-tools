#!/bin/sh
TESTS="
  test-echo-n.sh
  test-random.sh
  test-getTZ.sh
  test-versions.sh
  test-parse-semver.sh
  test-parmdb-cmdline.sh
  test-parmdb.sh
  test-mysql.sh
  test-check-mysql.sh
  test-inject-parms.sh
"
TESTDIR=`cd \`dirname $0\`; pwd`

nfailed=0
for t in ${TESTS} ; do
    $TESTDIR/$t
    rc=$?
    if [ $rc -gt 128 ] ; then
        rc=1
    fi
    nfailed=`expr $nfailed + $rc`
done
exit $nfailed
