#!/usr/bin/env bats
# spec-zitate.bats — haelt jedes woertliche Zitat der Spezifikation in einem Kommentar
# gegen den Text von spec/spezifikation.md.
#
# Ein Kommentarblock ist eine Folge aufeinanderfolgender Zeilen, die mit `#` oder `//`
# beginnen; seine Zeilen werden zu einem Text verbunden. Steht der Name `spezifikation.md`
# hoechstens 250 Zeichen vor einem Zitat im selben Block, gilt das Zitat als Zitat der
# Spezifikation. Ein Zitat steht hinter einem Anfang U+201E; sein Ende ist das naechste
# U+201C oder ASCII-Anfuehrungszeichen, und es darf ueber Folgezeilen des Kommentars laufen.
# Es muss in der Spezifikation vorkommen, Zeilenumbruch und mehrfacher Leerraum zaehlen als
# ein Leerzeichen; Gross-/Kleinschreibung zaehlt.
#
# Gelesen werden `internal`, `cmd`, `test` und `harness/tools`. NICHT GEPRUEFT: ein Zitat in
# anderen Anfuehrungszeichen, ein Zitat, das weiter als 250 Zeichen hinter dem Dateinamen
# steht oder die Spezifikation nur ueber `SPEC-<NNN>` nennt, und der Sinn eines Zitats —
# nur sein Wortlaut. Netzlos, laeuft in `make test`. Docker-only (bats-Image).

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
}

# zitate <datei>... — je Zitat eine Zeile "<datei>: <zitat>".
zitate() {
  awk '
    function fertig(   rest, vor, win, s, e, l, a, frag) {
      rest = block; vor = ""
      while ((s = index(rest, "„")) > 0) {
        vor = vor substr(rest, 1, s - 1)
        win = substr(vor, (length(vor) > 250) ? length(vor) - 249 : 1)
        rest = substr(rest, s + 3)
        e = index(rest, "“"); l = 3
        a = index(rest, "\"")
        if (a > 0 && (e == 0 || a < e)) { e = a; l = 1 }
        if (e == 0) break
        frag = substr(rest, 1, e - 1)
        if (index(win, "spezifikation.md") > 0) {
          gsub(/[ \t]+/, " ", frag)
          print name ": " frag
        }
        vor = vor "„" substr(rest, 1, e + l - 1)
        rest = substr(rest, e + l)
      }
      block = ""
    }
    FNR == 1 { fertig() }
    /^[ \t]*(#|\/\/)/ {
      z = $0
      sub(/^[ \t]*(#|\/\/)[ \t]?/, "", z)
      block = block " " z
      name = FILENAME
      next
    }
    { fertig() }
    END { fertig() }
  ' "$@"
}

@test "jedes woertliche Zitat der Spezifikation in einem Kommentar steht in spec/spezifikation.md" {
  FLACH="$(tr '\n' ' ' <"$REPO/spec/spezifikation.md" | tr -s ' \t' ' ')"
  fehlt=""
  while IFS= read -r zeile; do
    [ -n "$zeile" ] || continue
    frag="${zeile#*: }"
    grep -qF -- "$frag" <<<"$FLACH" || fehlt="$fehlt
$zeile"
  done < <(cd "$REPO" && mapfile -t DATEIEN < <(find internal cmd test harness/tools -type f \( -name '*.go' -o -name '*.sh' -o -name '*.bats' -o -name '*.awk' \) | sort) && zitate "${DATEIEN[@]}")
  [ -z "$fehlt" ] || { echo "Zitat(e) ohne Fundstelle in spec/spezifikation.md:$fehlt"; false; }
}
