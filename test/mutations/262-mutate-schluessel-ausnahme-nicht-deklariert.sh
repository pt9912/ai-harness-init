#!/usr/bin/env bash
# files: harness/tools/mutate.sh
# expect: driver: jeder von prepare_isolation kopierte Pfad geht in den Schluessel ein oder steht in der Ausnahmeliste
#
# Nimmt isolation_key_files einen Pfad aus dem Schluessel, ohne ihn in
# ISOLATION_KEY_EXEMPT zu deklarieren: harness/tools/ landet weiter in der Kopie (die
# ISOLATION_EXCLUDES-Definition bleibt unberuehrt), faellt aber aus dem Schluessel heraus.
# Genau das ist der dritte, unzulaessige Fall aus ADR-0035 Festlegung 3 — ein Pfad, der
# weder im Schluessel noch in der deklarierten Ausnahmeliste steht.
#
# Anker ohne literales Dollar (SC2016, wie die uebrigen Faelle in diesem Verzeichnis):
# `kexcl[@]}" .` ist ohne das fuehrende `${` eindeutig dieselbe Zeile in isolation_key_files.
set -euo pipefail
sed -i 's|kexcl\[@\]}" \.|kexcl[@]}" --exclude=./harness/tools .|' harness/tools/mutate.sh
