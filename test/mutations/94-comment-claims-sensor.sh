#!/usr/bin/env bash
# files: harness/tools/comment-claims.sh
# expect: Behauptung OHNE Sensor-Nennung
#
# Entschaerft den Gate: die Sensor-Erkennung matcht danach IMMER (block_sensor faellt auf
# 1, egal was im Kommentar steht). Eine Behauptung ohne jede Sensor-Nennung gilt dann als
# gedeckt — genau die Klasse, gegen die slice-055 gebaut ist (AGENTS.md 3.6). Der
# bats-Fall "Behauptung OHNE Sensor-Nennung: rot" faellt dadurch.
# Anker ohne Dollar-Verb (SC2016, Lehre aus slice-034): `~ sensor) block_sensor`
# kommt genau einmal vor.
set -euo pipefail
sed -i 's/if (.* ~ sensor) block_sensor = 1/block_sensor = 1/' harness/tools/comment-claims.sh
