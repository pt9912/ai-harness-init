#!/usr/bin/env bats
# doc-block-marke-wiring.bats — leitet aus d-check.mk UND .d-check.yml ab, welche
# `docs?-*`-Ziele ein Modul per `--enable` zuschalten, fuer das `.d-check.yml` KEINEN
# eigenen Top-Level-Block fuehrt (die C-Klasse), und haelt die Bijektion in beiden
# Richtungen: {C-Ziele} == {Ziele mit der Marke im ##-Hilfetext} == {Ziele, deren LETZTE
# Rezept-Zeile ein tatsaechlich ausgebendes `@echo` mit der Marke ist}. Die C-Menge wird
# ABGELEITET (kein Zielname steht hier aufgezaehlt) — ein drittes Ziel ohne Config-Block
# faellt sonst durch dieselbe Auspraegung-statt-Eigenschaft-Luecke, die dieser Waechter
# schliesst. Die Ausgabe-Haelfte prueft POSITION UND FORM, nicht nur Anwesenheit: eine
# Marke, die eine Nachpflege vor den `docker run`-Aufruf setzt, faellt durch die Bijektion,
# weil dann die letzte Rezept-Zeile die Marke nicht mehr traegt; ebenso eine Marke, die
# zwar in der letzten Rezept-Zeile STEHT, aber nicht in einem `@echo`, das sie wirklich
# ausgibt — ein `@: '…'`-No-op oder ein an die `docker run`-Zeile angehaengter
# `#`-Kommentar tragen dieselbe Zeichenkette, ohne dass ein realer Lauf sie je ausgibt, und
# zaehlen darum nicht zur Ausgabe-Menge. Was dieser Waechter NICHT erreicht: Bricht
# `docker run` mit einem Befund ab (Exit != 0), stoppt `make` das Rezept vor dem `@echo` --
# die Marke bleibt in diesem Lauf aus. Das ist eine Grenze der Make-Rezept-Semantik, kein
# Lueckentest hier; die Zusage in harness/sensors/doc-structure.md nennt sie deshalb
# ausdruecklich.
#
# NETZLOS (nur Datei-Lesen), laeuft in `make gates` ueber `make test` -> `test-bats`.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  DCHECK_MK="$REPO/d-check.mk"
  YML="$REPO/.d-check.yml"
  MARKE='.d-check.yml fuehrt fuer dieses Modul keinen eigenen Block, siehe harness/sensors/doc-tracked.md bzw. harness/sensors/doc-structure.md'
}

# ziel_zeilen gibt je docs?-*-Ziel eine Zeile "name modul hilfetext-marke(0/1)
# ausgabe-marke(0/1)" aus. modul ist "-", wenn das Rezept kein --enable traegt.
# ausgabe-marke ist NICHT "irgendeine Rezept-Zeile traegt die Marke", sondern "die
# LETZTE Rezept-Zeile dieses Ziels ist ein `@echo`, das die Marke ausgibt" -- em wird
# bei JEDER Tab-Zeile neu gesetzt (nicht nur bei einem Treffer) und ueberlebt damit
# nur, wenn die zuletzt gelesene Zeile BEIDES ist: sie beginnt mit `@echo` (nicht mit
# `docker`, nicht mit `@:`, nicht mit `#`) UND sie traegt die Marke. Eine Nachpflege,
# die das `@echo` vor den `docker run`-Aufruf setzt, faellt so aus dem Bild; ebenso
# eine Marke, die zwar in der letzten Zeile steht, aber in einem No-op oder einem
# Kommentar statt in einem echten `@echo`.
ziel_zeilen() {
  awk -v marke="$MARKE" '
    function finish() { if (z != "") printf "%s %s %d %d\n", z, modul, hm, em }
    /^docs?-[a-z-]+:.*## / {
      finish()
      z = $1; sub(":$", "", z)
      modul = "-"
      hm = (index($0, marke) > 0) ? 1 : 0
      em = 0
      next
    }
    z && /^\t/ {
      if ($0 ~ /--enable/) {
        for (i = 1; i <= NF; i++) if ($i == "--enable") modul = $(i + 1)
      }
      echozeile = ($0 ~ /^\t@echo[ \t]/) ? 1 : 0
      em = (echozeile && index($0, marke) > 0) ? 1 : 0
      next
    }
    END { finish() }
  ' "$DCHECK_MK"
}

# c_ziele filtert die Zeilen aus ziel_zeilen auf die C-Klasse: ein Modul ist
# zugeschaltet UND .d-check.yml fuehrt fuer es keinen Top-Level-Block (Spalte 0).
c_ziele() {
  ziel_zeilen | while read -r name modul _hm _em; do
    [ "$modul" = "-" ] && continue
    grep -qE "^${modul}:" "$YML" && continue
    printf '%s\n' "$name"
  done | sort -u
}

marke_hilfetext_ziele() {
  ziel_zeilen | awk '$3 == 1 { print $1 }' | sort -u
}

marke_ausgabe_ziele() {
  ziel_zeilen | awk '$4 == 1 { print $1 }' | sort -u
}

@test "doc-*: C-Menge (kein .d-check.yml-Block) == Ziele mit Hilfetext-Marke == Ziele mit Ausgabe-Marke" {
  local c hilfetext ausgabe
  c="$(c_ziele)"
  hilfetext="$(marke_hilfetext_ziele)"
  ausgabe="$(marke_ausgabe_ziele)"
  diff <(echo "$c") <(echo "$hilfetext")
  diff <(echo "$c") <(echo "$ausgabe")
}

@test "die C-Menge ist nicht leer (sonst liefe die Bijektion ueber der leeren Menge)" {
  [ -n "$(c_ziele)" ]
}
