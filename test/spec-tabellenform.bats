#!/usr/bin/env bats
# spec-tabellenform.bats — haelt die Tabellenform von spec/spezifikation.md gegen die
# Aufnahme-Regel der Spezifikation: jede Tabelle mit `SPEC`-Zeilen traegt `Praezisiert`
# als letzte Spalte, und keine `SPEC`-Zeile hat eine leere letzte Zelle.
#
# Eine Tabelle ist ein Block aufeinanderfolgender Zeilen, die mit `|` beginnen; ihre
# erste Zeile ist die Kopfzeile. Eine `SPEC`-Zeile ist eine Tabellenzeile, deren erste
# Zelle eine `SPEC`-Kennung in Backticks ist. Der Sensor liest die reale Datei, keine
# nachgebaute Tabelle. Ein Test misst die Spalte (Kopfzeilen), der andere die Zellen; ein
# Rot des einen laesst den anderen gruen, damit jeder seine eigene Zusage bindet.
#
# NICHT GEPRUEFT: der Inhalt der Zelle (Anker-Link oder `Luecke`) und dass ein Anker
# aufloest — das ist Sache des Doku-Gates (`make docs-check`). Netzlos, laeuft in
# `make test`. Docker-only (bats-Image).

setup() {
  SPEC="$BATS_TEST_DIRNAME/../spec/spezifikation.md"
}

# tabellen <datei> — je Tabelle eine Zeile "<hat-spec-zeile> <kopf-endet-auf-praezisiert>".
tabellen() {
  awk '
    function fertig() {
      if (offen) print hatspec, kopfpraez
      offen = 0
    }
    /^\|/ {
      if (!offen) {
        offen = 1; hatspec = 0
        kopfpraez = ($0 ~ /\| Präzisiert \|$/) ? 1 : 0
      }
      if ($0 ~ /^\| `SPEC-[0-9]+` \|/) hatspec = 1
      next
    }
    { fertig() }
    END { fertig() }
  ' "$1"
}

@test "jede Tabelle mit SPEC-Zeilen traegt Praezisiert als letzte Spalte und umgekehrt" {
  T="$(tabellen "$SPEC")"
  mit_spec="$(grep -c '^1 ' <<<"$T" || true)"
  mit_praez="$(grep -c ' 1$' <<<"$T" || true)"
  beides="$(grep -c '^1 1$' <<<"$T" || true)"
  # Selbst-Kalibrierung: ohne SPEC-Tabelle waeren alle drei Zahlen null und gleich.
  [ "$mit_spec" -ge 1 ]
  echo "Tabellen mit SPEC-Zeilen: $mit_spec; mit Praezisiert als letzter Kopf-Spalte: $mit_praez; beides: $beides"
  [ "$mit_spec" -eq "$mit_praez" ]
  [ "$mit_spec" -eq "$beides" ]
}

@test "keine SPEC-Zeile traegt eine leere letzte Zelle" {
  # Eine leere letzte Zelle endet auf `| |`; ein `\|` davor ist ein maskiertes Trennzeichen
  # im Zelltext und keine Zellgrenze.
  leer="$(awk '
    /^\| `SPEC-[0-9]+` \|/ {
      if (match($0, /\| *\|$/) && (RSTART == 1 || substr($0, RSTART - 1, 1) != "\\")) {
        z = $0; sub(/ \|.*/, "", z); print z
      }
    }' "$SPEC")"
  # Sonde ueber die geprueften Zeilen: dieselbe Zeilen-Regex wie oben im awk.
  n="$(grep -cE '^\| `SPEC-[0-9]+` \|' "$SPEC" || true)"
  [ "$n" -ge 1 ]
  [ -z "$leer" ] || { echo "SPEC-Zeile(n) mit leerer letzter Zelle: $leer"; false; }
}
