# swes-container-tools

This repo contains ultra-portable Bourne-ish scripts that are designed to be
run within Docker containers to simplify and standardize common operations.
There are extensive unit tests for the scripts, and the current CircleCI
configuration runs the test suite on a number of different Linux distributions.

All scripts support the "--help" command-line flag for displaying help.

You can see a list of all current scripts and their help documentation on the
[wiki](https://github.com/NCAR/swes-container-tools/wiki).

The repo also contains an AWS cli zip file and portable `jq` binary. The
`install-tools` script will install the `aws` cli util and `jq` along with
the portable scripts.


