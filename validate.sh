#!/bin/bash -euxv

echo "Installing mozharness..."
B2GBUMPER_DIR="$(pwd)"
cd ..
echo "Current directory: '$(pwd)'"
git clone -b bug1091084 https://github.com/petemoore/build-mozharness mozharness
echo "Installing tools..."
git clone https://github.com/mozilla/build-tools tools

HGTOOL_PATH="$(find "$(pwd)/tools" -name hgtool.py)"
GITTOOL_PATH="$(find "$(pwd)/tools" -name gittool.py)"

function replace {
    local file="${1}"
    local tokenname="${2}"
    local replacestring="${3}"
    # don't use sed -i so we can test on mac
    mv "${file}" "${file}.orig"
    cat "${file}.orig" | sed "s*${tokenname}*${replacestring}*g" > "${file}"
    rm "${file}.orig"
}

# update references to hgtool.py and gittool.py to correct locations...
replace "${B2GBUMPER_DIR}/travis-mozharness-config.py" HGTOOL "${HGTOOL_PATH}"
replace "${B2GBUMPER_DIR}/travis-mozharness-config.py" GITTOOL "${HGTOOL_PATH}"

mozharness/scripts/b2g_bumper.py -c "${B2GBUMPER_DIR}/travis-mozharness-config.py" --no-check-treestatus

echo "Running CI tests..."
