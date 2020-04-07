#!/bin/sh
TESTDIR=`cd \`dirname $0\`; pwd`
TESTLIBDIR="${TESTDIR}/../testlib"
. ${TESTLIBDIR}/init.rc

mkdir $TMPDIR/test1.d $TMPDIR/test2.d
cat > $TMPDIR/test1.d/foo.bar1.key <<EOF
-----BEGIN PRIVATE KEY-----
key1key1key1key1key1key1key1key1key1key1key1key1key1key1key1key1
-----END PRIVATE KEY-----
EOF
cat > $TMPDIR/test1.d/foo.bar1.CA.crt <<EOF
-----BEGIN CERTIFICATE-----
CAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcr
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
CAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcr
-----END CERTIFICATE-----
EOF
cat > $TMPDIR/test1.d/foo.bar1.crt <<EOF
-----BEGIN CERTIFICATE-----
crtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtc
-----END CERTIFICATE-----
EOF
cat > $TMPDIR/test2.d/foo.bar2.key <<EOF
-----BEGIN PRIVATE KEY-----
key2key2key2key2key2key2key2key2key2key2key2key2key2key2key2key2
-----END PRIVATE KEY-----
EOF
cat > $TMPDIR/test2.d/foo.bar2.bundle.pem <<EOF
-----BEGIN CERTIFICATE-----
CAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcr
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
CAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcrtCAcr
-----END CERTIFICATE-----
-----BEGIN CERTIFICATE-----
crtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtcrtc
-----END CERTIFICATE-----
EOF

DEFINE_TEST "when key, crt, and .CA.crt files found, all are copied"
RUN load-certs $TMPDIR/test1.d $TMPDIR/testOut.d
if noOutput && \
   noOutput --error && \
   fileEquals $TMPDIR/testOut.d/private/foo.bar1.key $TMPDIR/test1.d/foo.bar1.key && \
   fileEquals $TMPDIR/testOut.d/certs/foo.bar1.crt $TMPDIR/test1.d/foo.bar1.crt && \
   fileEquals $TMPDIR/testOut.d/certs/foo.bar1.CA.crt $TMPDIR/test1.d/foo.bar1.CA.crt
then
    SUCCESS
else
    FAILURE
fi

rm -rf $TMPDIR/testOut.d

DEFINE_TEST "when key, bundle.pem files found, pem split and copied with key"
RUN load-certs $TMPDIR/test2.d $TMPDIR/testOut.d
if noOutput && \
   noOutput --error && \
   fileEquals $TMPDIR/testOut.d/private/foo.bar2.key $TMPDIR/test2.d/foo.bar2.key && \
   fileEquals $TMPDIR/testOut.d/certs/foo.bar2.crt $TMPDIR/test1.d/foo.bar1.crt && \
   fileEquals $TMPDIR/testOut.d/certs/foo.bar2.CA.crt $TMPDIR/test1.d/foo.bar1.CA.crt
then
    SUCCESS
else
    FAILURE
fi


. cleanup.rc
