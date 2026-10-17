#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_PythonTraegtDieNamenDerAdr
#
# pip wird in das blocked/python-Fragment aufgenommen -> der Name steht doppelt, im gebackenen
# Guard-Boden und im Fragment; die Union ist die eine Quelle (ADR-0095 Festlegung 6).
set -euo pipefail
sed -i 's/"python python3 pytest/"pip python python3 pytest/' internal/emit/enforce.go
