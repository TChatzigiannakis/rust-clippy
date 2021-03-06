#!/usr/bin/bash

# Copyright 2014-2018 The Rust Project Developers. See the COPYRIGHT
# file at the top-level directory of this distribution and at
# http://rust-lang.org/COPYRIGHT.
#
# Licensed under the Apache License, Version 2.0 <LICENSE-APACHE or
# http://www.apache.org/licenses/LICENSE-2.0> or the MIT license
# <LICENSE-MIT or http://opensource.org/licenses/MIT>, at your
# option. This file may not be copied, modified, or distributed
# except according to those terms.


# This run `kcov` on Clippy. The coverage report will be at
# `./target/cov/index.html`.
# `compile-test` is special. `kcov` does not work directly on it so these files
# are compiled manually.

tests=$(find tests/ -maxdepth 1 -name '*.rs' ! -name compile-test.rs -exec basename {} .rs \;)
tmpdir=$(mktemp -d)

cargo test --no-run --verbose

for t in $tests; do
  kcov \
    --verify \
    --include-path="$(pwd)/src,$(pwd)/clippy_lints/src" \
    "$tmpdir/$t" \
    cargo test --test "$t"
done

for t in ./tests/compile-fail/*.rs; do
  kcov \
    --verify \
    --include-path="$(pwd)/src,$(pwd)/clippy_lints/src" \
    "$tmpdir/compile-fail-$(basename "$t")" \
    cargo run -- -L target/debug -L target/debug/deps -Z no-trans "$t"
done

for t in ./tests/run-pass/*.rs; do
  kcov \
    --verify \
    --include-path="$(pwd)/src,$(pwd)/clippy_lints/src" \
    "$tmpdir/run-pass-$(basename "$t")" \
    cargo run -- -L target/debug -L target/debug/deps -Z no-trans "$t"
done

kcov --verify --merge target/cov "$tmpdir"/*
