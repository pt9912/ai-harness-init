#!/usr/bin/env bash
# files: internal/emit/enforce.go
# expect: TestBlockedFragment_PythonTraegtDieNamenDerAdr
#
# uv, uvx und poetry verschwinden aus dem blocked/python-Fragment -> der naheliegende
# Host-Umweg an den verworfenen Alternativen laeuft im Ziel ungehindert (ADR-0095 Festlegung 6).
# Das Fragment bleibt nicht-leer; der Kopplungs-Test ueber alle gen-Profile bleibt gruen.
set -euo pipefail
sed -i 's/ mypy uv uvx poetry\\n",$/ mypy\\n",/' internal/emit/enforce.go
