# swes-container-tools

This repo contains ultra-portable Bourne-ish scripts that are designed to be
run within Docker containers to simplify and standardize common operations.
There are extensive unit tests for the scripts, and the current CircleCI
configuration runs the test suite on a number of different Linux distributions.

All scripts support the "--help" command-line flag for displaying help.

You can see a list of all current scripts and their help documentation on the
[wiki](https://github.com/NCAR/swes-container-tools/wiki).

The repo also contains an AWS cli zip file. The `install-tools` script will
install the `aws` cli utility along with the portable scripts. (Note: this
distro of `aws` won't actually run under alpine.)

The recommended way to make the tools in this repo available in a Docker image
is to include the following in the Dockerfile:

```
ADD https://api.github.com/repos/NCAR/swes-container-tools/git/refs/heads/master swes-container-tools-version.json
RUN cd /usr/local ; \
    git clone https://github.com/NCAR/swes-container-tools.git ; \
    swes-container-tools/install-tools /usr/local/bin
```

The `ADD` commands will invalidate the docker build cache if the repo has
been updated since the last build. The `RUN` command will install the tools.

