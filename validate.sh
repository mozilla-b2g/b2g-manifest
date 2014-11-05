#!/bin/bash

echo "Installing mozharness..."
pwd
git clone https://github.com/mozilla/build-mozharness mozharness
mozharness/scripts/b2g_bumper.py -c travis-mozharness-config.py --no-check-treestatus

echo "Running CI tests..."
