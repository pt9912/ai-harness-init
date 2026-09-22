#!/usr/bin/env bats
# commit-msg-emission.bats — Zaehne fuer den Commit-Kennungs-Waechter der
# EMITTIERTEN Ebene: die Pruefung, die der git-eigene Traeger des Zielrepos
# aufruft (internal/emit/templates/enforce/commit-msg-traceability.sh).
#
# WAS HIER GEMESSEN WIRD und was nicht: geprueft wird das URTEIL der emittierten
# Pruefung ueber eine Message-Datei — bash und coreutils, kein git, kein Docker,
# kein Zielrepo. Der Aufruf DURCH git (core.hooksPath), die Aktivierung per
# `make hooks-install` und die Umgehung `--no-verify` brauchen ein Repository und
# stehen darum in harness/tools/full-smoke.sh, an einem echten Commit-Versuch im
# gebootstrappten Ziel.
#
# Gelesen wird die QUELLE der Emission, nicht eine Kopie: `Enforce` schreibt sie
# verbatim ins Ziel (internal/emit/enforce.go), und ein Zielbaum steht dieser
# Stufe nicht zur Verfuegung.
#
# ZWEI GRUPPEN. Die erste faehrt das Urteil ueber eine Message-Datei. Die zweite
# haelt die zwei Fassungen der Kennungs-Menge zusammen: die emittierte und die
# dieses Repos (harness/tools/commit-msg-traceability.sh) — sie sind zwei
# Dateien mit demselben Zweck, und eine einseitige Aenderung liesse die zwei
# Traeger desselben Satzes auseinanderlaufen.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  EMITTIERT="$REPO/internal/emit/templates/enforce/commit-msg-traceability.sh"
  DOGFOOD="$REPO/harness/tools/commit-msg-traceability.sh"
  TMP="$(mktemp -d)"
}

teardown() {
  rm -rf "$TMP"
}

# lauf <inhalt> faehrt die emittierte Pruefung ueber eine Message-Datei und
# schreibt Ausgabe und Exit-Code in $status/$output (bats-eigene Variablen).
lauf() {
  printf '%b' "$1" > "$TMP/msg.txt"
  run bash "$EMITTIERT" "$TMP/msg.txt"
}

# patterns_von <datei> — die Kennungs-Menge einer bash-Fassung, je Muster eine
# Zeile ohne Klammern und Anfuehrungszeichen. Genau eine `^patterns=`-Zeile:
# gibt es sie nicht oder mehrfach, steht die Stoerung in der Ausgabe und der
# Vergleich faellt (fail-closed statt still gruen).
patterns_von() {
  local n zeile
  n="$(grep -c '^patterns=' "$1")"
  if [ "$n" -ne 1 ]; then
    echo "STORUNG: $1 traegt $n '^patterns='-Zeilen statt einer"
    return 1
  fi
  zeile="$(sed -n 's/^patterns=//p' "$1")"
  zeile="${zeile#\'}"; zeile="${zeile%\'}"
  zeile="${zeile#(}"; zeile="${zeile%)}"
  printf '%s\n' "$zeile" | tr '|' '\n' | sed '/^$/d'
}

@test "rot: eine Message ohne Kennung wird abgelehnt, mit Exit 1 und lesbarem Grund" {
  lauf 'Betreff ohne Kennung\n\nEin Rumpf ohne Kennung.\n'
  [ "$status" -eq 1 ]
  [[ "$output" == *"keine Traceability-Kennung"* ]]
  [[ "$output" == *"Betreff ohne Kennung"* ]]
}

# klassen_kopf <datei> — die Klassen-Aufzaehlung im ZUSAGE-Absatz des Kopfes, eine
# Klasse je Zeile. Der Absatz ist der einzige Ort der Datei mit geschweiften
# Klammern; die uebrigen sind Parameter-Expansionen des Codes.
klassen_kopf() {
  sed -n '/^# ZUSAGE\./,/^#$/p' "$1" \
    | sed -n 's/.*{\([^}]*\)}.*/\1/p' \
    | tr ',' '\n' | sed 's/^[[:space:]]*//; s/[[:space:]]*$//' | sed '/^$/d'
}

# klassen_muster <datei> — dieselben Klassen aus der Zeile `patterns=`: je
# Alternative der Teil bis einschliesslich des ersten Bindestrichs, dedupliziert
# — eine Klasse (z.B. "slice-") kann mehr als eine Alternative tragen (Nummer-
# UND Slug-Form, MR-059 Setzung 1), der Kopf nennt sie trotzdem nur einmal.
klassen_muster() {
  patterns_von "$1" | sed 's/^\([^-]*-\)[^|]*$/\1/' | sort -u
}

@test "kopplung: die Klassen-Aufzaehlung im Kopf ist die der Zeile patterns=" {
  local datei soll ist
  for datei in "$EMITTIERT" "$DOGFOOD"; do
    soll="$(klassen_kopf "$datei" | sort)"
    ist="$(klassen_muster "$datei" | sort)"
    # Ein leeres `soll` ist kein Durchgang: der Kopf traegt dann keine Aufzaehlung,
    # die diese Ableitung liest — fail-closed statt still gruen.
    if [ -z "$soll" ] || [ "$soll" != "$ist" ]; then
      echo "STORUNG: $datei — Klassen im Kopf: [$(printf '%s' "$soll" | tr '\n' ' ')] / in patterns=: [$(printf '%s' "$ist" | tr '\n' ' ')]"
      return 1
    fi
  done
}

@test "rot: der Grund nennt den Ort der Menge und zaehlt sie nicht selbst auf" {
  lauf 'Betreff ohne Kennung\n'
  [ "$status" -eq 1 ]
  # Die Menge steht in der Zeile `patterns=`; der Grund zeigt dorthin ...
  [[ "$output" == *'patterns='* ]]
  # ... und fuehrt sie nicht als zweite Fassung: keine Kennungs-Klasse der Menge
  # steht in der Ausgabe. Als Muster steht die Menge allein in `patterns=`.
  [[ "$output" != *'ADR-'* ]]
  [[ "$output" != *'LH-'* ]]
  [[ "$output" != *'MR-'* ]]
  [[ "$output" != *'slice-'* ]]
}

@test "gruen: jede der vier Kennungs-Klassen der Menge wird angenommen" {
  local k
  for k in 'ADR-0053' 'LH-FA-01' 'MR-057' 'slice-126'; do
    lauf "Betreff mit Kennung\n\nBezug: $k\n"
    [ "$status" -eq 0 ]
  done
}

@test "gruen: die Kennung darf im Rumpf stehen (der Betreff traegt keine)" {
  lauf 'Betreff ohne Kennung\n\nBezug: ADR-0053\n'
  [ "$status" -eq 0 ]
}

@test "gruen: die Merge-/Revert-Ausnahme greift auf den Betreff" {
  lauf 'Merge branch main into feature\n'
  [ "$status" -eq 0 ]
  lauf 'Revert "Betreff ohne Kennung"\n'
  [ "$status" -eq 0 ]
}

@test "rot: eine Kennung in einer Kommentarzeile zaehlt nicht" {
  lauf '# Bezug: ADR-0053\nBetreff ohne Kennung\n'
  [ "$status" -eq 1 ]
}

@test "fail-closed: fehlende Datei und fehlender Aufruf enden mit Exit 2, nicht mit 0" {
  run bash "$EMITTIERT"
  [ "$status" -eq 2 ]
  [[ "$output" == *"keine Message-Datei uebergeben"* ]]
  run bash "$EMITTIERT" "$TMP/gibt-es-nicht.txt"
  [ "$status" -eq 2 ]
  [[ "$output" == *"nicht lesbar"* ]]
}

@test "kopplung: die zwei bash-Fassungen der Kennungs-Menge sind einander gleich" {
  local emittiert dogfood
  emittiert="$(patterns_von "$EMITTIERT" | sort)"
  dogfood="$(patterns_von "$DOGFOOD" | sort)"
  # BEIDE Richtungen, und als Mengen-Gleichheit statt als Beleg je Muster: die
  # Richtung emittiert->dogfood allein waere blind fuer ein Muster, das nur die
  # Emissions-Vorlage gewann.
  if [ "$emittiert" != "$dogfood" ]; then
    echo "emittiert: $(printf '%s' "$emittiert" | tr '\n' ' ')"
    echo "dogfood:   $(printf '%s' "$dogfood" | tr '\n' ' ')"
    false
  fi
}

@test "kopplung: die Betreff-Ausnahme der zwei Fassungen ist dieselbe" {
  local emittiert dogfood
  emittiert="$(sed -n 's/^exempt=//p' "$EMITTIERT")"
  dogfood="$(sed -n 's/^exempt=//p' "$DOGFOOD")"
  [ -n "$emittiert" ]
  [ "$emittiert" = "$dogfood" ]
}
