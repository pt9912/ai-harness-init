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
# haelt die zwei Fassungen der Kennungs-Menge zusammen (emittiert als Obermenge): die emittierte und die
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
# Alternative der Teil bis einschliesslich des ersten Bindestrichs.
klassen_muster() {
  patterns_von "$1" | sed 's/^\([^-]*-\)[^|]*$/\1/'
}

@test "kopplung: die Klassen-Aufzaehlung im Kopf ist die der Zeile patterns=" {
  local datei soll ist
  for datei in "$EMITTIERT" "$DOGFOOD"; do
    soll="$(klassen_kopf "$datei" | sort -u)"
    ist="$(klassen_muster "$datei" | sort -u)"
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

@test "gruen: jede der vier Kennungs-Klassen der Menge wird angenommen (slice als Nummer)" {
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

@test "gruen: ein benannter Slice (slice-<kennung>) wird angenommen, die Nummernform ebenso" {
  lauf 'Betreff mit Kennung\n\nBezug: slice-emittierte-commit-pruefung-erkennt-benannte-slices\n'
  [ "$status" -eq 0 ]
  lauf 'Betreff ohne Kennung\n\nBezug: slice-12\n'
  [ "$status" -eq 0 ]
  lauf 'slice-mv: slice-kennungs-erkennung.md  next/ -> in-progress/\n'
  [ "$status" -eq 0 ]
}

@test "rot: ein Wort ohne Kennung nach slice- und eine Message ohne jede Kennung bleiben abgelehnt" {
  lauf 'Betreff ohne Kennung\n\nBezug: slice- und slice_x und Slice-12\n'
  [ "$status" -eq 1 ]
}

@test "rot: ein Mittendrin-Wort ohne Trenner links von slice- ist keine Kennung" {
  lauf 'Betreff ohne Kennung\n\nBezug: noslice-foo und x_slice-bar und a-slice-baz\n'
  [ "$status" -eq 1 ]
  lauf 'noslice-foo\n'
  [ "$status" -eq 1 ]
}

@test "gruen: ein Trenner links von slice- genuegt (akzeptiertes Negativ: a slice-wise fix)" {
  lauf 'Betreff ohne Kennung\n\nBezug: (slice-foo) und `slice-bar`\n'
  [ "$status" -eq 0 ]
  # Mit Leerzeichen davor ist es ein Wort wie jedes andere; die Pruefung unterscheidet
  # Kennung und Prosa nicht, sie prueft Anwesenheit.
  lauf 'a slice-wise fix\n'
  [ "$status" -eq 0 ]
}

@test "kopplung: die emittierte Kennungs-Menge ist eine Obermenge der Dogfood-Menge" {
  local emittiert dogfood fehlt
  emittiert="$(patterns_von "$EMITTIERT" | sort)"
  dogfood="$(patterns_von "$DOGFOOD" | sort)"
  # EINE Richtung, emittiert ⊇ Dogfood: jedes Dogfood-Muster steht woertlich in der
  # emittierten Menge. Die emittierte Menge darf mehr fuehren (den benannten Slice);
  # die Gegenrichtung gilt nicht, weil die Emission der Dogfood-Fassung vorausgehen darf.
  fehlt="$(comm -13 <(printf '%s\n' "$emittiert") <(printf '%s\n' "$dogfood"))"
  if [ -n "$fehlt" ]; then
    echo "in der emittierten Menge fehlt: $(printf '%s' "$fehlt" | tr '\n' ' ')"
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

@test "kopplung: die Zeile named_slice= der zwei Fassungen ist dieselbe (genau eine je Datei)" {
  local datei n emittiert dogfood
  for datei in "$EMITTIERT" "$DOGFOOD"; do
    n="$(grep -c '^named_slice=' "$datei")"
    if [ "$n" -ne 1 ]; then
      echo "STORUNG: $datei traegt $n '^named_slice='-Zeilen statt einer"
      return 1
    fi
  done
  emittiert="$(sed -n 's/^named_slice=//p' "$EMITTIERT")"
  dogfood="$(sed -n 's/^named_slice=//p' "$DOGFOOD")"
  [ -n "$emittiert" ]
  if [ "$emittiert" != "$dogfood" ]; then
    echo "emittiert: $emittiert"
    echo "dogfood:   $dogfood"
    false
  fi
}

# urteil_beider <inhalt> — Exit der emittierten und der Dogfood-Pruefung ueber
# dieselbe Message, als "<emittiert> <dogfood>".
urteil_beider() {
  local e d
  printf '%b' "$1" > "$TMP/msg.txt"
  e=0; bash "$EMITTIERT" "$TMP/msg.txt" >/dev/null 2>&1 || e=$?
  d=0; bash "$DOGFOOD" "$TMP/msg.txt" >/dev/null 2>&1 || d=$?
  echo "$e $d"
}

@test "kopplung: beide Fassungen urteilen gleich ueber Namensform, Nummernform und die zwei Grenzfaelle" {
  # Namensform, Nummernform, ungleiche Strenge der Nummernform (kein Wortrand: noslice-12)
  # und das akzeptierte Negativ gehen durch; ein Mittendrin-Wort der Namensform nicht.
  [ "$(urteil_beider 'x\n\nBezug: slice-kennungs-erkennung-foo\n')" = "0 0" ]
  [ "$(urteil_beider 'x\n\nBezug: slice-174\n')" = "0 0" ]
  [ "$(urteil_beider 'noslice-12\n')" = "0 0" ]
  [ "$(urteil_beider 'a slice-wise fix\n')" = "0 0" ]
  [ "$(urteil_beider 'noslice-foo\n')" = "1 1" ]
  [ "$(urteil_beider 'Betreff ohne Kennung\n')" = "1 1" ]
}
