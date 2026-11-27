#!/usr/bin/env bash
# files: internal/gen/golang.go
# expect: TestInventoryRows_SollTragtDieDogfoodForm
#
# Nimmt die Tag-Praefix-Streichung aus den golangci-lint-inventar-Zeile: das Soll
# steht dann in der Pin-Form (abgeleitet:v<…>) statt in der Version-Ausgabe-Form
# (abgeleitet:<…> ohne Praefix). Die exakte Pruefform vergleicht die Version-
# Ausgabe des Werkzeugs OHNE Praefix — im real gebootstrappten Ziel bleibt die
# Inventar-Zeile rot, selbst mit exakt gepinntem Werkzeug. Der Abgleich haelt die
# Lab-Fassung gegen die Emission und faerbt rot (F-9, verify).
#
# Grenze des Abgleichs: Text-Parity der zwei Inventar-Fassungen, nicht die
# Version-Ausgabe des Hosts — die traegt der reale Lauf (LP2), kein Waechter hier.
set -euo pipefail
sed -i 's/strings.TrimPrefix(golangciVersion, "v")/golangciVersion/' internal/gen/golang.go
