#!/usr/bin/env bats
# e2e-abdeckung.bats — Zaehne fuer den Erzeuger der E2E-Abdeckungs-Tabelle
# (harness/tools/e2e-abdeckung.sh) und fuer die Form der Deklarationen, aus denen er
# liest.
#
# HERMETISCH: gefahren wird der Erzeuger ueber dem TEXT des geprueften Skripts und ueber
# KOPIEN davon — kein Docker, kein Netz, kein E2E. Die Kopien entstehen in
# BATS_TEST_TMPDIR; der gepruefte Baum wird angefasst, aber nicht veraendert.
#
# VIER LAUFFORMEN, und jede traegt eine andere Zusage:
#   (1) HAPPY PATH ueber dem GEPRUEFTEN Skript: der Erzeuger rendert je Stufe eine Zeile,
#       und ein zweiter Lauf meldet unveraendert. Dieser Fall ist zugleich der Waechter
#       gegen die zweite Luecken-Richtung: nimmt eine Stufe ihre Deklaration weg, faellt
#       hier eine Zeile und der Fall wird rot — genau ihn faehrt
#       test/mutations/362-e2e-stufe-ohne-deklaration.sh.
#   (2) STUFE OHNE DEKLARATION — der Aufruf einer Stufe ist entfernt.
#   (3) DEKLARATION OHNE STUFE, in zwei Auspraegungen: die Zeile, die ein Anker nennt,
#       ist umgeschrieben (der Aufruf steht noch da), und ein Aufruf steht vor der ersten
#       Stufe.
# Eine Richtung allein belegte nichts (AGENTS.md 3.6); gefahren werden beide.
#
# DIE AUSGANGSLAGE IST DER GEPRUEFTE BAUM, nicht eine Fixture. Jeder Fall belegt darum
# zuerst, dass seine eigene Mutation eingetreten ist — die Zaehlungen vor dem Lauf
# gehoeren zum Fall und nicht zur Umgebung.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  ERZEUGER="$REPO/harness/tools/e2e-abdeckung.sh"
  QUELLE="$REPO/harness/tools/full-smoke.sh"
  TMP="$BATS_TEST_TMPDIR"
  STUFEN_MUSTER='^echo "full-smoke: .* \.\.\."$'
  RUF_MUSTER='^[[:space:]]*e2e_abdeckung "'
}

stufen() { grep -cE "$STUFEN_MUSTER" "$1"; }
aufrufe() { grep -cE "$RUF_MUSTER" "$1"; }
zeilen() { grep -c '^| \[' "$1"; }

@test "happy path: der Erzeuger rendert je Stufe eine Zeile aus dem geprueften Skript, und der zweite Lauf meldet unveraendert" {
  run bash "$ERZEUGER" "$QUELLE" "$TMP/tabelle.md"
  [ "$status" -eq 0 ]
  [ -f "$TMP/tabelle.md" ]
  # Ein leerer Pruefbereich waere ein gruener Lauf ohne Aussage (LH-QA-01).
  [ "$(stufen "$QUELLE")" -ge 1 ]
  # Eine Zeile je Stufe — und keine mehr: die Deklarationen des geprueften Skripts.
  [ "$(zeilen "$TMP/tabelle.md")" -eq "$(stufen "$QUELLE")" ]
  # Je Zeile eine Kennung als Verweis in das Lastenheft; keine Zeile ohne.
  [ "$(grep -c 'lastenheft.md#' "$TMP/tabelle.md")" -eq "$(zeilen "$TMP/tabelle.md")" ]
  run bash "$ERZEUGER" "$QUELLE" "$TMP/tabelle.md"
  [ "$status" -eq 0 ]
  printf '%s' "$output" | grep -q 'unverändert'
}

@test "boundary: eine Stufe ohne Deklaration faerbt den Erzeuger rot" {
  cp "$QUELLE" "$TMP/kopie.sh"
  # Der Stufe mit dem Traeger-Anker ihre Deklaration nehmen. Der Anker steht in doppelten
  # Anfuehrungszeichen nur im dritten Argument des Aufrufs.
  grep -vF '"ADOPTER-EIGENER TRAEGER"' "$TMP/kopie.sh" >"$TMP/ohne.sh"
  # Die Mutation belegen, statt sie zu behaupten: die Stufen-Zahl bleibt, die Aufruf-Zahl
  # faellt um genau einen.
  [ "$(stufen "$TMP/ohne.sh")" -eq "$(stufen "$QUELLE")" ]
  [ "$(aufrufe "$TMP/ohne.sh")" -eq "$(( $(aufrufe "$QUELLE") - 1 ))" ]
  run bash "$ERZEUGER" "$TMP/ohne.sh" "$TMP/tabelle.md"
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -q 'Stufe ohne Deklaration'
  printf '%s' "$output" | grep -qF "$TMP/ohne.sh:"
}

@test "negativ: eine Deklaration ohne aufloesenden Anker faerbt den Erzeuger rot" {
  cp "$QUELLE" "$TMP/kopie.sh"
  # Die ZEILE umschreiben, aus der der Anker stammt — der Aufruf selbst bleibt stehen,
  # und sein drittes Argument traegt den Anker weiter.
  sed -i 's/2\. Lauf heilte die Makefile-Drift NICHT (/2. Lauf liess die Makefile-Drift stehen (/' "$TMP/kopie.sh"
  # Genau EIN Vorkommen bleibt: das im Aufruf. Faende die Anker-Suche es dort, waere sie
  # ueber jedem Anker still — dieser Fall ist ihr Zahn.
  [ "$(grep -cF '2. Lauf heilte die Makefile-Drift NICHT' "$TMP/kopie.sh")" -eq 1 ]
  run bash "$ERZEUGER" "$TMP/kopie.sh" "$TMP/tabelle.md"
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -q 'Deklaration ohne Stufe'
  printf '%s' "$output" | grep -qF "$TMP/kopie.sh:"
}

@test "negativ: ein Aufruf vor der ersten Stufen-Kopfzeile faerbt den Erzeuger rot" {
  {
    printf 'e2e_abdeckung "LH-FA-01" "steht ueber jeder Stufe" "kein Ort in einer Stufe"\n'
    cat "$QUELLE"
  } >"$TMP/kopie.sh"
  [ "$(aufrufe "$TMP/kopie.sh")" -eq "$(( $(aufrufe "$QUELLE") + 1 ))" ]
  run bash "$ERZEUGER" "$TMP/kopie.sh" "$TMP/tabelle.md"
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -q 'VOR der ersten Stufen-Kopfzeile'
}
