#!/usr/bin/env bash
# files: internal/span/emit.go
# expect: TestSchemaDoc_JedesErfassteFeldStehtImAusdruck
# verify: test-go
#
# EIN PFLICHTFELD KOMMT ZUR ZEILE, DER AUSDRUCK WIRD NICHT NACHGEZOGEN.
#
# Genau die Fehlhandlung, gegen die es das Feldlisten-Dokument gibt: jemand erfasst ein
# Feld mehr, und die Liste im Ziel sagt es nicht. Danach erfasst das gebootstrappte Repo
# mehr, als es lesbar zusagt — die Drift zwischen erfasstem und dokumentiertem Feld, die
# ADR-0022 Festlegung 7 KONSTRUKTIV ausschliessen will statt per Regel zu verbieten.
#
# WARUM EIN NEUES FELD UND NICHT EIN GELOESCHTER EINTRAG: die realistische Bewegung ist,
# dass das Schema waechst. Ein geloeschter Eintrag traefe dieselbe Bruchstelle, waere aber
# der seltenere Weg dorthin.
#
# DER BACKTICK STEHT IN EINER VARIABLEN: in einfachen Anfuehrungszeichen liest der
# Shell-Lint ihn als beabsichtigte Kommando-Substitution, in doppelten waere er eine.
set -euo pipefail
bt='`'
sed -i "s@^\tStatus  *string  *${bt}json:\"status\"${bt}\$@&\n\tGeheim         string   ${bt}json:\"geheim\"${bt}@" internal/span/emit.go
