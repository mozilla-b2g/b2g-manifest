#!/bin/bash

# See https://travis-ci.org/mozilla-b2g/b2g-manifest

# This script is run by travis for the CI of b2g-manifest.
# It is designed to catch problems that would otherwise only
# be found when b2g bumper bot runs in production, that
# potentially can cause tree closures.

# It installs and runs b2g bumper locally, without committing
# nor pushing back to hg, to check that repos referenced exist
# and are readable, referenced heads/tags exist, and that they
# are correctly mirrored on git.mozilla.org.

# Gaia is excluded from testing, since access to cruncher is
# required to map hg sha to git sha, whereas these tests are
# more concerned with invalid repos/branches/tags getting
# added to a manifest.

set -xve
B2G_MANIFEST_DIR="$(pwd)"
cd ..

echo "Installing mozharness..."
echo "Current directory: '$(pwd)'"
git clone https://github.com/mozilla/build-mozharness mozharness
echo "Installing tools..."
git clone https://github.com/mozilla/build-tools tools

echo "Installing repo..."
curl https://storage.googleapis.com/git-repo-downloads/repo > ./repo && chmod a+x ./repo
echo "Configuring Git for Repo ..."
git config --global user.email "mozilla-b2g@github.com"
git config --global user.name "Mozilla B2G"
git config --global color.ui false

# Create a config file with the correct location for gittool.py
# to be added to list of configs to be passed to mozharness...

GITTOOL_PATH="$(find "$(pwd)/tools" -name gittool.py)"
cat << EOF > "${B2G_MANIFEST_DIR}/travis-mozharness-config.py"
config = {
    "exes": {
        "gittool.py": ["${GITTOOL_PATH}"],
    },
    "git_ref_cache": "$(pwd)/git_ref_cache.json",
}
EOF

# rather than use mozharness to checkout b2g-manifest, use the one checked out by travis already...
mkdir build
ln -s "${B2G_MANIFEST_DIR}" build/manifests

echo "Running repo init..."

if [ "${TRAVIS_PULL_REQUEST}" != "false" ]; then
    ORIGIN_REPO=$(git --git-dir ./b2g-manifest/.git/ config --get remote.origin.url)
    for xml in $(find ./b2g-manifest -type f -name "*.xml" | grep -v -E "base-.*\.xml");
    do
        xml_file=$(basename "${xml}")
        echo "Checking XML: ${xml_file}"
        rm -rf repodir && mkdir repodir
        pushd repodir
            ../repo init --no-repo-verify \
                         -u ${ORIGIN_REPO} \
                         -b refs/pull/${TRAVIS_PULL_REQUEST}/head \
                         -m ${xml_file}
        popd
    done;
else
    echo "Not a PR: ${TRAVIS_PULL_REQUEST}"
fi;

echo "Running b2g bumper..."

# Bug 1267261 - Decommission b2g bumper

echo "All b2g bumper steps succeeded!"
