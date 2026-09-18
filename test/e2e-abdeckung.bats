#!/usr/bin/env bats
# e2e-abdeckung.bats — Zaehne fuer den Erzeuger der E2E-Abdeckungs-Tabelle
# (harness/tools/e2e-abdeckung.sh) und fuer die Form der Deklarationen, aus denen er
# liest.
#
# HERMETISCH: gefahren wird der Erzeuger ueber dem TEXT des geprueften Skripts und ueber
# KOPIEN davon — kein Docker, kein Netz, kein E2E. Die Kopien entstehen in
# BATS_TEST_TMPDIR; der gepruefte Baum wird angefasst, aber nicht veraendert.
#
# FUENF LAUFFORMEN, und jede traegt eine andere Zusage:
#   (1) HAPPY PATH ueber dem GEPRUEFTEN Skript: der Erzeuger rendert je Stufe eine Zeile,
#       und ein zweiter Lauf meldet unveraendert. Dieser Fall ist zugleich der Waechter
#       gegen die zweite Luecken-Richtung: nimmt eine Stufe ihre Deklaration weg, faellt
#       hier eine Zeile und der Fall wird rot — genau ihn faehrt
#       test/mutations/362-e2e-stufe-ohne-deklaration.sh.
#   (2) STUFE OHNE DEKLARATION — der Aufruf einer Stufe ist entfernt.
#   (3) DEKLARATION OHNE STUFE, in zwei Auspraegungen: die Zeile, die ein Anker nennt,
#       ist umgeschrieben (der Aufruf steht noch da), und ein Aufruf steht vor der ersten
#       Stufe.
#   (4) HALTER DER COMMITTETEN TABELLE: der Erzeuger faehrt ueber dem geprueften Skript,
#       und sein Ausgang wird byte-gleich gegen docs/user/e2e-abdeckung.md gehalten. Diese
#       Datei ist erzeugt und kein Gate-Target liest sie auf ihren Inhalt — die Verweise
#       an ihr prueft `make docs-check` —, darum traegt sie hier ihren Halter.
# Eine Richtung allein belegte nichts (AGENTS.md 3.6); gefahren werden beide.
#
# DIE AUSGANGSLAGE IST DER GEPRUEFTE BAUM, nicht eine Fixture. Jeder Fall belegt darum
# zuerst, dass seine eigene Mutation eingetreten ist — die Zaehlungen vor dem Lauf
# gehoeren zum Fall und nicht zur Umgebung.

setup() {
  REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
  ERZEUGER="$REPO/harness/tools/e2e-abdeckung.sh"
  QUELLE="$REPO/harness/tools/full-smoke.sh"
  TABELLE="$REPO/docs/user/e2e-abdeckung.md"
  TMP="$BATS_TEST_TMPDIR"
  STUFEN_MUSTER='^echo "full-smoke: .* \.\.\."$'
  RUF_MUSTER='^[[:space:]]*e2e_abdeckung "'
  # Dasselbe Stufen-Muster fuer ein ZIEL-Skript: dort traegt die Kopfzeile das
  # Praefix, das der Marker E2E_ABDECKUNG_PRAEFIX nennt.
  STUFEN_MUSTER_ZIEL='^echo "selbstpruefung: .* \.\.\."$'
  # Die Tabellen-Kopfzeile, die BEIDE Fassungen schreiben.
  KOPFZEILE='| Spec-Kennung | Kurzbeschreibung | Stufe | Ort |'
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

@test "halter: die committete Tabelle ist der aktuelle Ausgang des Erzeugers" {
  # Der Erzeuger schreibt den Pfad der QUELLE in die Spalte `Ort` und leitet den
  # Link-Prefix aus der TIEFE des Ziels ab. Byte-Gleichheit mit der committeten Datei ist
  # darum nur ueber derselben Aufrufform herstellbar: Quelle `harness/tools/full-smoke.sh`,
  # Ziel `docs/user/…`, beide relativ. Der Sandkasten stellt genau diese zwei Pfade her —
  # die Quelle als KOPIE des geprueften Skripts, die der Erzeuger als Text liest; der
  # gepruefte Baum wird gelesen, nicht geschrieben.
  mkdir -p "$TMP/sandkasten/harness/tools" "$TMP/sandkasten/docs/user"
  cp "$QUELLE" "$TMP/sandkasten/harness/tools/full-smoke.sh"
  cd "$TMP/sandkasten"
  run bash "$ERZEUGER" harness/tools/full-smoke.sh docs/user/tabelle.md
  [ "$status" -eq 0 ]
  run cmp -s docs/user/tabelle.md "$TABELLE"
  [ "$status" -eq 0 ]
}

# ---------------------------------------------------------------------------
# DIE EMITTIERTE FASSUNG. Gelesen wird die QUELLE der Emission
# (internal/emit/templates/enforce/e2e-abdeckung.sh), nicht eine Kopie: `Enforce`
# schreibt sie verbatim ins Ziel, und ein Zielbaum steht dieser Stufe nicht zur
# Verfuegung. Sie und der Erzeuger dieses Repos sind zwei Dateien mit demselben Zweck;
# eine einseitige Aenderung liesse die zwei Fassungen auseinanderlaufen — dagegen steht
# der Kopplungs-Fall am Ende.
#
# GEFAHREN WIRD UEBER EINER FIXTURE, nicht ueber dem geprueften Baum: die emittierte
# Fassung liest ein Skript des ZIELS, und das gibt es hier nicht. Die Fixture ist die
# kleinste Form, die der Erzeuger liest — eine Stufen-Kopfzeile, eine Deklaration, eine
# Zeile mit dem Anker.

emittiert() { printf '%s' "$REPO/internal/emit/templates/enforce/e2e-abdeckung.sh"; }

# fixture <verzeichnis> legt ein Ziel-Skelett an: ein E2E mit genau einer Stufe und
# eine Spec-Datei, deren Ueberschrift die deklarierte Kennung traegt.
fixture() {
  mkdir -p "$1/tools/harness" "$1/spec" "$1/docs/user"
  cat > "$1/tools/harness/mein-e2e.sh" <<'EOF'
#!/usr/bin/env bash
e2e_abdeckung() { echo "deklariert: $1"; }
echo "selbstpruefung: die eine Stufe dieser Fixture ..."
e2e_abdeckung "LH-FA-01" "was die eine Stufe belegt" "der Anker dieser Stufe"
echo "selbstpruefung: der Anker dieser Stufe steht auf einer eigenen Zeile"
EOF
  printf '### LH-FA-01 — Repo bootstrappen\n\nText.\n' > "$1/spec/lastenheft.md"
}

@test "emittiert: ueber einer Fixture entsteht je Stufe eine Zeile, mit Verweis in die Spec des Ziels" {
  fixture "$TMP/ziel"
  cd "$TMP/ziel"
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^| \[' docs/user/e2e-abdeckung.md)" -eq 1 ]
  # Der Verweis loest gegen die Ueberschrift der Spec-Datei auf, nicht gegen eine Liste.
  grep -qF '[`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)' docs/user/e2e-abdeckung.md
  # Der Ort zeigt auf die Zeile der STUFE, nicht auf die Deklaration.
  grep -qF '`tools/harness/mein-e2e.sh:5`' docs/user/e2e-abdeckung.md
}

@test "emittiert: null Stufen enden laut, mit Exit 1 und der Form, die eine Kopfzeile haben muss" {
  fixture "$TMP/leer"
  cd "$TMP/leer"
  # Die Mutation belegen, statt sie zu behaupten: das Skript traegt danach keine
  # Stufen-Kopfzeile mehr, aber es liegt.
  printf '#!/usr/bin/env bash\necho "selbstpruefung: eine Zeile ohne die drei Punkte"\n' > tools/harness/mein-e2e.sh
  [ -f tools/harness/mein-e2e.sh ]
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 1 ]
  # Rot allein genuegt nicht: die Meldung muss den Adopter zur Deklaration fuehren —
  # erwartete Kopfzeilen-Form, erwartete Deklaration, und die zwei Marker, mit denen er
  # ein E2E an anderer Stelle nennt.
  printf '%s' "$output" | grep -q 'null Stufen'
  printf '%s' "$output" | grep -qF 'echo "selbstpruefung: <was die Stufe tut> ..."'
  printf '%s' "$output" | grep -qF 'e2e_abdeckung "<Kennungen>"'
  printf '%s' "$output" | grep -qF 'E2E_ABDECKUNG_QUELLE=<pfad>'
  printf '%s' "$output" | grep -qF 'E2E_ABDECKUNG_PRAEFIX=<wort>'
  [ ! -f docs/user/e2e-abdeckung.md ]
}

@test "emittiert: eine Stufe ohne Deklaration faerbt die emittierte Fassung rot" {
  fixture "$TMP/ohne"
  cd "$TMP/ohne"
  grep -v '^e2e_abdeckung "' tools/harness/mein-e2e.sh > "$TMP/ohne.sh"
  mv "$TMP/ohne.sh" tools/harness/mein-e2e.sh
  # Die Mutation belegen: die Stufe bleibt, der Aufruf ist weg.
  [ "$(grep -cE "$STUFEN_MUSTER_ZIEL" tools/harness/mein-e2e.sh)" -eq 1 ]
  [ "$(grep -cE "$RUF_MUSTER" tools/harness/mein-e2e.sh)" -eq 0 ]
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'Stufe ohne Deklaration'
  printf '%s' "$output" | grep -qF 'tools/harness/mein-e2e.sh:'
}

@test "emittiert: eine Kennung ohne Ueberschrift steht als Code-Span, nicht als toter Link" {
  fixture "$TMP/ohnespec"
  cd "$TMP/ohnespec"
  rm spec/lastenheft.md
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  # Kein Verweis in eine Datei, die es nicht gibt — und die Zeile entsteht trotzdem.
  [ "$(grep -c '^| `LH-FA-01` |' docs/user/e2e-abdeckung.md)" -eq 1 ]
  [ "$(grep -c 'lastenheft.md#' docs/user/e2e-abdeckung.md)" -eq 0 ]
  # Still ist das nicht: der Lauf nennt die Kennung und den Marker, der die Datei nennt.
  printf '%s' "$output" | grep -qF 'als Code-Span ohne Verweis'
  printf '%s' "$output" | grep -qF 'E2E_ABDECKUNG_SPEC'
}

@test "kopplung: beide Fassungen schreiben dieselbe Tabellen-Kopfzeile und lesen dieselbe Deklarations-Form" {
  # Die Kopfzeile: in dieser Fassung steht sie im Kopf-Heredoc, in der emittierten in
  # einem echo. Verglichen wird die ZEICHENKETTE, nicht ihre Schreibweise.
  hier="$(grep -cF "$KOPFZEILE" "$ERZEUGER")"
  dort="$(grep -cF "$KOPFZEILE" "$(emittiert)")"
  [ "$hier" -eq 1 ]
  [ "$dort" -eq 1 ]
  # Die Deklarations-Form: beide erkennen denselben Aufruf, sonst liest die eine als
  # Deklaration, was die andere als gewoehnliche Zeile sieht.
  for datei in "$ERZEUGER" "$(emittiert)"; do
    [ "$(grep -c "^RUF_MUSTER='" "$datei")" -eq 1 ]
    [ "$(grep -c "^RUF_TEIL='" "$datei")" -eq 1 ]
  done
  [ "$(sed -n "s/^RUF_MUSTER=//p" "$ERZEUGER")" = "$(sed -n "s/^RUF_MUSTER=//p" "$(emittiert)")" ]
  [ "$(sed -n "s/^RUF_TEIL=//p" "$ERZEUGER")" = "$(sed -n "s/^RUF_TEIL=//p" "$(emittiert)")" ]
  # Die zwei Luecken-Richtungen heissen in beiden gleich — die Meldung ist das, woran
  # ein Adopter den Fall erkennt.
  for schluessel in 'Stufe ohne Deklaration' 'Deklaration ohne Stufe'; do
    grep -qF "$schluessel" "$ERZEUGER"
    grep -qF "$schluessel" "$(emittiert)"
  done

  # DIE ANKER-ABLEITUNG. Sie ist das Stueck, das LINKS in einen fremden Baum schreibt;
  # laeuft sie auseinander, schreibt eine der zwei Fassungen Verweise, die die andere
  # nicht schriebe. Verglichen werden die drei Zeichen-Mengen und die zwei Funktionen.
  for zeile in TYPOGRAFIE ANFUEHRUNGEN SATZZEICHEN; do
    [ "$(grep -c "^$zeile=" "$ERZEUGER")" -eq 1 ]
    [ "$(grep -c "^$zeile=" "$(emittiert)")" -eq 1 ]
    [ "$(sed -n "s/^$zeile=//p" "$ERZEUGER")" = "$(sed -n "s/^$zeile=//p" "$(emittiert)")" ]
  done
  # slug_sicher woertlich gleich: der Waechter, der einen unvollstaendig abgeleiteten
  # Anker erkennt, darf nicht in einer Fassung strenger sein als in der anderen.
  sed -n '/^slug_sicher() {/,/^}/p' "$ERZEUGER" > "$TMP/sicher-hier.txt"
  sed -n '/^slug_sicher() {/,/^}/p' "$(emittiert)" > "$TMP/sicher-dort.txt"
  [ "$(wc -l < "$TMP/sicher-hier.txt")" -ge 4 ]
  cmp -s "$TMP/sicher-hier.txt" "$TMP/sicher-dort.txt"

  # slug_fuer gleich BIS AUF DEN EINEN GEWOLLTEN UNTERSCHIED, und der wird hier benannt
  # statt verschwiegen: die emittierte Fassung traegt den Waechter `spec_da`, weil eine
  # fehlende Spec-Datei im Ziel kein Befund ist; unsere bricht davor schon ab, weil das
  # Lastenheft dieses Repos liegen muss. Genau diese eine Zeile wird herausgerechnet —
  # steht in der emittierten Fassung eine zweite Abweichung, faellt der Vergleich.
  sed -n '/^titel_fuer() {/,/^}/p' "$ERZEUGER" > "$TMP/slug-hier.txt"
  sed -n '/^titel_fuer() {/,/^}/p' "$(emittiert)" | grep -v 'spec_da' > "$TMP/slug-dort.txt"
  [ "$(grep -c 'spec_da' "$ERZEUGER")" -eq 0 ]
  [ "$(sed -n '/^titel_fuer() {/,/^}/p' "$(emittiert)" | grep -c 'spec_da')" -eq 1 ]
  [ "$(wc -l < "$TMP/slug-hier.txt")" -ge 9 ]
  cmp -s "$TMP/slug-hier.txt" "$TMP/slug-dort.txt"

  # slug_fuer und titel_rein woertlich gleich: die eine bildet ab, die andere entscheidet,
  # ob die Abbildung ueberhaupt gilt. Eine Fassung, die hier abweicht, schriebe Verweise,
  # die die andere nicht schriebe.
  for fn in slug_fuer titel_rein; do
    sed -n "/^$fn() {/,/^}/p" "$ERZEUGER" > "$TMP/$fn-hier.txt"
    sed -n "/^$fn() {/,/^}/p" "$(emittiert)" > "$TMP/$fn-dort.txt"
    [ "$(wc -l < "$TMP/$fn-hier.txt")" -ge 4 ]
    cmp -s "$TMP/$fn-hier.txt" "$TMP/$fn-dort.txt"
  done
}

@test "emittiert: die mitgelieferte Selbstpruefung traegt eine Stufe mit ihrer Deklaration, und die Zelle bleibt ohne geratene Kennung" {
  mkdir -p "$TMP/mit/tools/harness" "$TMP/mit/docs/user"
  cp "$REPO/internal/emit/templates/enforce/selbstpruefung.sh" "$TMP/mit/tools/harness/"
  cd "$TMP/mit"
  # Die Ausgangslage belegen: genau eine Stufe, genau eine Deklaration.
  [ "$(grep -cE "$STUFEN_MUSTER_ZIEL" tools/harness/selbstpruefung.sh)" -eq 1 ]
  [ "$(grep -cE "$RUF_MUSTER" tools/harness/selbstpruefung.sh)" -eq 1 ]
  run bash "$(emittiert)"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^| .* | Stufe [0-9]' docs/user/e2e-abdeckung.md)" -eq 1 ]
  # KEINE GERATENE KENNUNG: die Stufe kommt mit dem Werkzeug, die Anforderung gehoert dem
  # Ziel. Ein aufloesender Verweis waere hier die teurere Luege — er saehe richtig aus.
  [ "$(grep -c '^| — | .* | Stufe 1 | `tools/harness/selbstpruefung.sh:' docs/user/e2e-abdeckung.md)" -eq 1 ]
  [ "$(grep -c 'lastenheft.md#' docs/user/e2e-abdeckung.md)" -eq 0 ]
  printf '%s' "$output" | grep -qF 'deklariert keine Kennung'
}

@test "emittiert: der Selbstpruefung ihre Deklaration nehmen faerbt den Erzeuger rot" {
  mkdir -p "$TMP/ohnedekl/tools/harness" "$TMP/ohnedekl/docs/user"
  grep -v '^e2e_abdeckung "' "$REPO/internal/emit/templates/enforce/selbstpruefung.sh" \
    > "$TMP/ohnedekl/tools/harness/selbstpruefung.sh"
  cd "$TMP/ohnedekl"
  # Die Mutation belegen: die Stufe steht noch, der Aufruf ist weg.
  [ "$(grep -cE "$STUFEN_MUSTER_ZIEL" tools/harness/selbstpruefung.sh)" -eq 1 ]
  [ "$(grep -cE "$RUF_MUSTER" tools/harness/selbstpruefung.sh)" -eq 0 ]
  run bash "$(emittiert)"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'Stufe ohne Deklaration'
  [ ! -f docs/user/e2e-abdeckung.md ]
}

@test "emittiert: ein zweiter Lauf ohne geaenderte Deklaration schreibt die Sicht nicht neu und sagt es" {
  fixture "$TMP/zweitlauf"
  cd "$TMP/zweitlauf"
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  # GEMESSEN WIRD DER SCHREIB-ZEITSTEMPEL, nicht die Meldung: ein Schreiben setzt ihn neu.
  # Ein Fall, der nur die Meldung liest, bliebe gruen, wenn die Vorlage sie ausgibt UND
  # trotzdem schriebe. (Der Inode taugt nicht: er wird nach dem rm sofort wiederverwendet.)
  vorher="$(stat -c %y docs/user/e2e-abdeckung.md)"
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  nachher="$(stat -c %y docs/user/e2e-abdeckung.md)"
  [ "$vorher" = "$nachher" ]
  printf '%s' "$output" | grep -qF 'unveraendert'
  # GEGENPROBE: mit geaenderter Deklaration schreibt er sehr wohl — sonst waere die
  # Gleichheit oben die Eigenschaft einer Datei, die nie neu entsteht.
  sed -i 's@"was die eine Stufe belegt"@"was die eine Stufe nun belegt"@' tools/harness/mein-e2e.sh
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  [ "$(stat -c %y docs/user/e2e-abdeckung.md)" != "$nachher" ]
  printf '%s' "$output" | grep -qF 'geschrieben'
}

@test "emittiert: dem Quell-Skript seine einzige Stufen-Kopfzeile nehmen faerbt rot — die ANDERE Luecken-Richtung" {
  mkdir -p "$TMP/ohnestufe/tools/harness" "$TMP/ohnestufe/docs/user"
  grep -vE '^echo "selbstpruefung: .* \.\.\."$' "$REPO/internal/emit/templates/enforce/selbstpruefung.sh" \
    > "$TMP/ohnestufe/tools/harness/selbstpruefung.sh"
  cd "$TMP/ohnestufe"
  # Die Mutation belegen: die Deklaration steht noch, die Kopfzeile ist weg. Das ist die
  # Gegenrichtung zu "Stufe ohne Deklaration" — hier gibt es gar keine Stufe.
  [ "$(grep -cE "$STUFEN_MUSTER_ZIEL" tools/harness/selbstpruefung.sh)" -eq 0 ]
  [ "$(grep -cE "$RUF_MUSTER" tools/harness/selbstpruefung.sh)" -eq 1 ]
  run bash "$(emittiert)"
  [ "$status" -eq 1 ]
  printf '%s' "$output" | grep -q 'keine Stufen-Kopfzeile'
  printf '%s' "$output" | grep -q 'null Stufen'
  # Eine Sicht ueber null Stufen entsteht NICHT — ihr Gruen belegte eine Abdeckung, die
  # niemand deklariert hat (LH-QA-01).
  [ ! -f docs/user/e2e-abdeckung.md ]
}

@test "trennlinie: eine nicht aufloesende Kennung bricht UNSERE Fassung ab und gibt der emittierten einen Code-Span" {
  # DIE EINE GEWOLLTE DIFFERENZ DER ZWEI FASSUNGEN, in einem Fall belegt. Wer sie
  # angleicht, hebt eine Zusage auf: unsere urteilt ueber UNSER Lastenheft und darf einen
  # Link ohne Ziel nicht schreiben; die emittierte kennt die Spec des Ziels nicht und
  # macht aus einer unbekannten Kennung keinen Befund (LH-FA-12 §Benannte Grenze).
  fixture "$TMP/trenn"
  sed -i 's@"LH-FA-01"@"LH-ZZ-99"@' "$TMP/trenn/tools/harness/mein-e2e.sh"
  [ "$(grep -c 'LH-ZZ-99' "$TMP/trenn/tools/harness/mein-e2e.sh")" -eq 1 ]
  [ "$(grep -c 'LH-ZZ-99' "$TMP/trenn/spec/lastenheft.md")" -eq 0 ]

  # (a) DIE EMITTIERTE FASSUNG: Exit 0, Code-Span, kein Verweis.
  cd "$TMP/trenn"
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^| `LH-ZZ-99` |' docs/user/e2e-abdeckung.md)" -eq 1 ]
  [ "$(grep -c 'lastenheft.md#' docs/user/e2e-abdeckung.md)" -eq 0 ]

  # (b) UNSERE FASSUNG ueber derselben Lage: Abbruch, und der Grund nennt den Link ohne
  # Ziel. Gefahren wird sie mit unserem Stufen-Praefix, damit die Stufe fuer sie eine ist.
  sed -i 's@^echo "selbstpruefung: @echo "full-smoke: @' tools/harness/mein-e2e.sh
  run bash "$ERZEUGER" tools/harness/mein-e2e.sh docs/user/unsere.md
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -qF 'LH-ZZ-99'
  printf '%s' "$output" | grep -q 'Link ohne Ziel'
  [ ! -f docs/user/unsere.md ]
}

@test "emittiert: jeder der vier Marker lenkt den Lauf, gemessen an dem was entsteht" {
  mkdir -p "$TMP/marker/tools/harness" "$TMP/marker/anders" "$TMP/marker/sicht"
  cd "$TMP/marker"
  # Quelle und Praefix weichen beide von der Vorgabe ab: laeuft der Lauf ohne gesetzte
  # Marker, findet er gar nichts — das macht den Test der zwei Marker unabhaengig von der
  # Vorgabe.
  cat > anders/eigenes-e2e.sh <<'EOF'
#!/usr/bin/env bash
e2e_abdeckung() { :; }
echo "meinlauf: die eine Stufe des eigenen E2E ..."
e2e_abdeckung "RQ-7" "was das eigene E2E belegt" "der Anker des eigenen E2E"
echo "meinlauf: der Anker des eigenen E2E steht hier"
EOF
  printf '### RQ-7 — Eigene Anforderung\n' > anders/anforderungen.md
  run env E2E_ABDECKUNG_QUELLE=anders/eigenes-e2e.sh \
          E2E_ABDECKUNG_PRAEFIX=meinlauf \
          E2E_ABDECKUNG_SPEC=anders/anforderungen.md \
          E2E_ABDECKUNG_ZIEL=sicht/abdeckung.md \
          bash "$(emittiert)"
  [ "$status" -eq 0 ]
  # ZIEL: die Datei entsteht dort und nirgends sonst.
  [ -f sicht/abdeckung.md ]
  [ ! -f docs/user/e2e-abdeckung.md ]
  # QUELLE + PRAEFIX: die Stufe des genannten Skripts steht in der Sicht, mit seinem Pfad.
  [ "$(grep -c '| Stufe 1 | `anders/eigenes-e2e.sh:' sicht/abdeckung.md)" -eq 1 ]
  # SPEC: der Verweis loest gegen die GENANNTE Datei auf, nicht gegen eine Vorgabe.
  grep -qF '(../anders/anforderungen.md#rq-7--eigene-anforderung)' sicht/abdeckung.md
}

@test "anker: ein abgeleiteter Anker, der die Ueberschrift nicht trifft, wird nicht als Verweis geschrieben" {
  # DIE UEBERSCHRIFT AUS DEM BEFUND. Die Ableitung loescht eine AUFZAEHLUNG von Zeichen;
  # die Guillemets stehen nicht darin und blieben im Slug stehen, waehrend der
  # Markdown-Anker sie fallen laesst. Ohne den Waechter entsteht daraus ein Verweis bei
  # Exit 0 — und das Doku-Gate des Ziels faellt auf einer Datei, die dieses Werkzeug
  # selbst geschrieben hat.
  fixture "$TMP/anker"
  sed -i 's@"LH-FA-01"@"RQ-8"@' "$TMP/anker/tools/harness/mein-e2e.sh"
  printf '### RQ-8 — Zitat »Wert«\n\nText.\n' > "$TMP/anker/spec/lastenheft.md"
  cd "$TMP/anker"
  # Die Ausgangslage belegen: die Ueberschrift ist da, die Kennung loest also auf — der
  # Fall misst NICHT den Zweig "keine Ueberschrift".
  [ "$(grep -c '^### RQ-8 ' spec/lastenheft.md)" -eq 1 ]

  # (a) DIE EMITTIERTE FASSUNG: Code-Span statt Verweis, Exit 0, und der Lauf sagt warum.
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^| `RQ-8` |' docs/user/e2e-abdeckung.md)" -eq 1 ]
  [ "$(grep -c 'lastenheft.md#' docs/user/e2e-abdeckung.md)" -eq 0 ]
  printf '%s' "$output" | grep -qF 'nicht sicher abzuleiten'
  # Der Zaehler der Schluss-Zeile nennt sie: still ist der Fall nicht.
  printf '%s' "$output" | grep -qF '1 ohne Verweis'

  # (b) UNSERE FASSUNG ueber derselben Lage: Abbruch mit dem abgeleiteten Slug im Klartext.
  sed -i 's@^echo "selbstpruefung: @echo "full-smoke: @' tools/harness/mein-e2e.sh
  run bash "$ERZEUGER" tools/harness/mein-e2e.sh docs/user/unsere.md spec/lastenheft.md
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -qF 'nicht sicher abzuleiten'
  printf '%s' "$output" | grep -qF 'Link ohne Ziel'
  [ ! -f docs/user/unsere.md ]
}

@test "anker: eine Ueberschrift mit Inline-Syntax bekommt keinen Verweis — eine ohne bekommt ihn" {
  # DAS KRITERIUM SITZT AUF DER ROHZEILE, nicht auf dem Slug: der Anker entsteht aus dem
  # GERENDERTEN Text, die Ableitung liest die Rohzeile. Wo Markdown beim Rendern etwas
  # wegnimmt, geht sie mit LAUTER ERLAUBTEN ZEICHEN daneben — slug_sicher findet daran
  # nichts.
  #
  # DIE KLASSEN SIND GEMESSEN, nicht vermutet (Ziel-Repo, je eine Ueberschrift, danach
  # das Doku-Gate des Ziels ueber der geschriebenen Sicht): Link und Bild fallen mit
  # `anchor-missing`, Code-Span, Hervorhebung und HTML nicht. Die beiden Richtungen
  # stehen darum hier nebeneinander — HTML ist der PRUEFSTEIN gegen eine zu breite Regel.
  mkdir -p "$TMP/roh/tools/harness" "$TMP/roh/spec" "$TMP/roh/docs/user"
  cd "$TMP/roh"
  cat > tools/harness/mein-e2e.sh <<'EOF'
#!/usr/bin/env bash
e2e_abdeckung() { :; }
echo "selbstpruefung: eins ..."
e2e_abdeckung "RQ-1" "link" "eins"
echo "selbstpruefung: zwei ..."
e2e_abdeckung "RQ-2" "bild" "zwei"
echo "selbstpruefung: drei ..."
e2e_abdeckung "RQ-5" "html" "drei"
echo "selbstpruefung: vier ..."
e2e_abdeckung "RQ-6" "schlicht" "vier"
EOF
  {
    printf '### RQ-1 — [Zitat](../README.md) im Titel\n\nText.\n\n'
    printf '### RQ-2 — ![Bild](../README.md) im Titel\n\nText.\n\n'
    printf '### RQ-5 — HTML <sup>hoch</sup> im Titel\n\nText.\n\n'
    printf '### RQ-6 — schlicht und ohne Syntax\n\nText.\n'
  } > spec/lastenheft.md
  # Die Ausgangslage belegen: alle vier Ueberschriften liegen, jede Kennung loest auf.
  [ "$(grep -c '^### RQ-' spec/lastenheft.md)" -eq 4 ]

  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  # ROT-RICHTUNG: Link und Bild bekommen einen Code-Span, keinen Verweis.
  [ "$(grep -c '^| `RQ-1` |' docs/user/e2e-abdeckung.md)" -eq 1 ]
  [ "$(grep -c '^| `RQ-2` |' docs/user/e2e-abdeckung.md)" -eq 1 ]
  printf '%s' "$output" | grep -qF 'Markdown-Inline-Syntax'
  printf '%s' "$output" | grep -qF '2 ohne Verweis'
  # GRUEN-RICHTUNG, und sie ist die Haelfte, die eine zu breite Regel kaputtmacht:
  # HTML im Titel ist KEIN Treffer — das Doku-Gate leitet dort gleich ab.
  grep -qF '[`RQ-5`](../../spec/lastenheft.md#rq-5--html-suphochsup-im-titel)' docs/user/e2e-abdeckung.md
  grep -qF '[`RQ-6`](../../spec/lastenheft.md#rq-6--schlicht-und-ohne-syntax)' docs/user/e2e-abdeckung.md

  # UNSERE FASSUNG bricht ueber derselben Ueberschrift ab, statt den Code-Span zu setzen.
  sed -i 's@^echo "selbstpruefung: @echo "full-smoke: @' tools/harness/mein-e2e.sh
  run bash "$ERZEUGER" tools/harness/mein-e2e.sh docs/user/unsere.md spec/lastenheft.md
  [ "$status" -ne 0 ]
  printf '%s' "$output" | grep -qF 'Markdown-Inline-Syntax'
  printf '%s' "$output" | grep -qF 'Link ohne Ziel'
  [ ! -f docs/user/unsere.md ]
}
