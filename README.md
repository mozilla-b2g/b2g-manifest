#b2g-manifest

Please make sure to test your changes in a personal fork, before merging. It is
imperative that travis tests pass before merging changes back, since broken
travis tests implies that b2g bumper will break in production.

# Branching
If you create a new branch in b2g-manifest, it is *critical* that you update
`run_travis_tests.sh` so that it invokes b2g bumper using the correct
mozharness config file(s) for your new branch. See comments in
`run_travis_tests.sh` for more details.

[![Build Status](https://secure.travis-ci.org/mozilla-b2g/b2g-manifest.png)](http://travis-ci.org/mozilla-b2g/b2g-manifest)
