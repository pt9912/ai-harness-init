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
#
# ZAEHLUNG: Fenster und Zitatgrenzen zaehlen Bytes, nicht Zeichen — das `awk` des
# bats-Images kennt keine Mehrbyte-Zeichen (ein Umlaut zaehlt doppelt, die 250 sind Bytes).
# Ein UTF-8-faehiges `awk` (Host) kuerzt `substr(rest, s + 3)` das Zitat um zwei Zeichen;
# der Sensor ist an das Image-`awk` gebunden und laeuft nur ueber `make test`.
#
# BELEGLAGE: Der Bestand traegt heute kein reales Zitat der Spezifikation; die einzige
# Fundstelle ist der Kommentar des Falls `503-spec-zitat-ohne-fundstelle`, der sich ueber
# seine `# files:`-Zeile selbst als Zitat der Spezifikation liest. Dass der Sensor ein
# Zitat erkennt und ein falsches faellt, belegt darum die Fixture des zweiten Tests,
# unabhaengig vom Bestand; der erste Test prueft den Bestand und meldet die Zahl der
# gefundenen Zitate, ohne sie zu verlangen (ein Bestand ohne Zitat ist zulaessig).

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

# ohne_fundstelle <spec-datei> <zitate-ausgabe> — je Zitat, das in der Spezifikation fehlt,
# eine Zeile "<datei>: <zitat>"; Zeilenumbruch und mehrfacher Leerraum der Spezifikation
# zaehlen als ein Leerzeichen.
ohne_fundstelle() {
  local flach zeile frag fehlt=""
  flach="$(tr '\n' ' ' <"$1" | tr -s ' \t' ' ')"
  while IFS= read -r zeile; do
    [ -n "$zeile" ] || continue
    frag="${zeile#*: }"
    grep -qF -- "$frag" <<<"$flach" || fehlt="$fehlt
$zeile"
  done <<<"$2"
  printf '%s' "$fehlt"
}

@test "jedes woertliche Zitat der Spezifikation in einem Kommentar steht in spec/spezifikation.md" {
  Z="$(cd "$REPO" && mapfile -t DATEIEN < <(find internal cmd test harness/tools -type f \( -name '*.go' -o -name '*.sh' -o -name '*.bats' -o -name '*.awk' \) | sort) && zitate "${DATEIEN[@]}")"
  echo "Zitate der Spezifikation im Bestand: $(grep -c . <<<"$Z" || true)"
  fehlt="$(ohne_fundstelle "$REPO/spec/spezifikation.md" "$Z")"
  [ -z "$fehlt" ] || { echo "Zitat(e) ohne Fundstelle in spec/spezifikation.md:$fehlt"; false; }
}

@test "der Sensor erkennt ein Zitat ueber zwei Kommentarzeilen, faellt ein falsches und ueberliest Kommentare ohne Dateinamen" {
  # Fixture: eine Spezifikation mit Zeilenumbruch im Satz und eine Quelldatei mit vier
  # Kommentaren — zwei Zitate mit Dateinamen (eines wahr ueber den Umbruch, eines falsch
  # durch Kleinschreibung), ein Zitat ohne den Namen der Spezifikation, ein Zitat hinter
  # einem Code-Zeilen-Abstand (neuer Block).
  printf '%s\n' 'Der Wert bleibt am' 'Pflichtfeld tool unterscheidbar.' >"$BATS_TEST_TMPDIR/spec.md"
  {
    printf '%s\n' '# spezifikation.md sagt: „Der Wert bleibt am' '# Pflichtfeld tool unterscheidbar".'
    printf '%s\n' 'x=1'
    printf '%s\n' '# spezifikation.md sagt: „der wert bleibt" (falsch geschrieben)'
    printf '%s\n' 'y=2'
    printf '%s\n' '# Ein Kommentar ohne den Namen: „kein Zitat der Spec".'
  } >"$BATS_TEST_TMPDIR/quelle.sh"
  Z="$(zitate "$BATS_TEST_TMPDIR/quelle.sh")"
  # Menge nicht leer: genau die zwei Zitate mit Dateinamen, das wahre ueber beide Zeilen.
  [ "$(grep -c . <<<"$Z")" -eq 2 ]
  grep -qF 'Der Wert bleibt am Pflichtfeld tool unterscheidbar' <<<"$Z"
  grep -qF 'der wert bleibt' <<<"$Z"
  ! grep -qF 'kein Zitat der Spec' <<<"$Z"
  # Verdikt: nur das falsche Zitat fehlt in der Spezifikation.
  fehlt="$(ohne_fundstelle "$BATS_TEST_TMPDIR/spec.md" "$Z")"
  [ "$(grep -c . <<<"$fehlt")" -eq 1 ]
  grep -qF 'der wert bleibt' <<<"$fehlt"
}
