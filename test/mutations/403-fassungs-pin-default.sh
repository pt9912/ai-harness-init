#!/usr/bin/env bash
# files: Makefile
# expect: TRAEGER_VERSION traegt keinen Default im Makefile
# verify: test-bats
#
# Fuehrt einen Default fuer TRAEGER_VERSION ein — den Pin-Stand des Makefiles,
# hier als Literal desselben Pins; die Referenz-Fassung
# `TRAEGER_VERSION ?= $(TRAEGER_TAG)` faellt an demselben Waechter. Damit
# injiziert jeder Bau — auch der Quell-Bau ohne Release-Kontext — die erfundene
# Zahl: der Pin-Wert ist der Stand des letzten Schnitts, nicht der des
# Bau-Moments, und der Fehlt-Fall ist unerreichbar (ADR-0063 Festlegung 1, die
# Haelfte "uebergeben, nicht Pin-Default").
set -euo pipefail
sed -i '/^TRAEGER_TAG ?= /a\TRAEGER_VERSION ?= v0.2.2' Makefile