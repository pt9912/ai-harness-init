#!/usr/bin/env bash
# files: internal/archive/collect.go
# expect: TestReviewTrifftBenanntePraefixGrenze
# verify: test-go
#
# Schaltet die Praefix-Grenze in ReviewTrifft ab: ein Name zieht dann die
# Reports eines laengeren Namens mit, der ihn vor einem Bindestrich traegt.
set -euo pipefail
sed -i 's/if strings.HasPrefix(o, nummer+"-") \&\& reviewTraegt(name, o) {/if false \&\& strings.HasPrefix(o, nummer+"-") \&\& reviewTraegt(name, o) {/' internal/archive/collect.go
