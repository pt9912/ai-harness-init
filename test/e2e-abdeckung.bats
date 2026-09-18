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

@test "emittiert: ueber einer Fixture entsteht je Stufe eine Zeile — und kein einziger Verweis" {
  fixture "$TMP/ziel"
  cd "$TMP/ziel"
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^| .* | Stufe [0-9]' docs/user/e2e-abdeckung.md)" -eq 1 ]
  # DIE KENNUNG STEHT ALS CODE-SPAN — auch hier, wo die Ueberschrift laege und ein Anker
  # abzuleiten waere. Die ausgelieferte Fassung leitet keinen ab: sie kennt das Doku-Gate
  # des Ziels nicht und kann eine Nachbildung darum weder kalibrieren noch halten.
  [ "$(grep -c '^| `LH-FA-01` |' docs/user/e2e-abdeckung.md)" -eq 1 ]
  [ "$(grep -c '](' docs/user/e2e-abdeckung.md)" -eq 0 ]
  # Der Ort zeigt auf die Zeile der STUFE, nicht auf die Deklaration.
  grep -qF '`tools/harness/mein-e2e.sh:5`' docs/user/e2e-abdeckung.md
  # Die Spec-Datei bleibt im Kopf genannt: sie ist der Massstab des LESERS.
  grep -qF 'spec/lastenheft.md' docs/user/e2e-abdeckung.md
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

@test "emittiert: eine fehlende Spec-Datei bricht nicht ab — die Sicht entsteht, und Lauf und Kopf sagen, dass ihr Massstab fehlt" {
  # DIE SPEC-DATEI IST DER MASSSTAB DES LESERS, nicht die Quelle eines Ankers — gelesen
  # wird sie nicht mehr. Fehlt sie, entsteht die Sicht vollstaendig; STILL darf das nicht
  # bleiben, denn ihr Kopf nennt die Datei weiter. Eine Sicht, die auf nichts zeigt und
  # das verschweigt, behauptet Pruefbarkeit, die niemand einloesen kann.
  fixture "$TMP/mitspec"
  cd "$TMP/mitspec"
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh E2E_ABDECKUNG_ZIEL=docs/user/a.md bash "$(emittiert)"
  [ "$status" -eq 0 ]
  # Mit Spec-Datei sagt der Lauf dazu nichts, und der Kopf traegt den Fehl-Hinweis nicht.
  ! printf '%s' "$output" | grep -qF 'die Spec-Datei liegt nicht'
  [ "$(grep -c 'liegt in diesem Repo derzeit' docs/user/a.md)" -eq 0 ]

  # Die Mutation belegen: die Datei ist weg, der Marker zeigt unveraendert auf sie.
  rm spec/lastenheft.md
  [ ! -f spec/lastenheft.md ]
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh E2E_ABDECKUNG_ZIEL=docs/user/b.md bash "$(emittiert)"
  [ "$status" -eq 0 ]
  # (1) DER LAUF SAGT ES — und nennt den Marker, ueber den der Adopter die Datei benennt.
  printf '%s' "$output" | grep -qF 'die Spec-Datei liegt nicht: spec/lastenheft.md'
  printf '%s' "$output" | grep -qF 'E2E_ABDECKUNG_SPEC'
  # (2) DIE SICHT SAGT ES AUCH — sie wird ohne den Lauf gelesen.
  [ "$(grep -c 'liegt in diesem Repo derzeit' docs/user/b.md)" -eq 1 ]
  # (3) UND SIE IST TROTZDEM VOLLSTAENDIG: dieselbe Zeile, dieselbe Code-Span-Form.
  [ "$(grep -c '^| `LH-FA-01` |' docs/user/b.md)" -eq 1 ]
  [ "$(grep -c '](' docs/user/b.md)" -eq 0 ]
  [ "$(grep -c '^| .* | Stufe [0-9]' docs/user/b.md)" -eq "$(grep -c '^| .* | Stufe [0-9]' docs/user/a.md)" ]
}

@test "kopplung: die zwei Fassungen teilen die Form und trennen sich in EINER Sache — dem Verweis" {
  # GETEILT: die Tabellen-Kopfzeile, die Deklarations-Form und die zwei Luecken-Richtungen.
  # Laeuft eines davon auseinander, liest die eine Fassung als Deklaration, was die andere
  # als gewoehnliche Zeile sieht, oder die zwei Sichten sind nicht mehr dieselbe Tabelle.
  hier="$(grep -cF "$KOPFZEILE" "$ERZEUGER")"
  dort="$(grep -cF "$KOPFZEILE" "$(emittiert)")"
  [ "$hier" -eq 1 ]
  [ "$dort" -eq 1 ]
  for datei in "$ERZEUGER" "$(emittiert)"; do
    [ "$(grep -c "^RUF_MUSTER='" "$datei")" -eq 1 ]
    [ "$(grep -c "^RUF_TEIL='" "$datei")" -eq 1 ]
  done
  [ "$(sed -n "s/^RUF_MUSTER=//p" "$ERZEUGER")" = "$(sed -n "s/^RUF_MUSTER=//p" "$(emittiert)")" ]
  [ "$(sed -n "s/^RUF_TEIL=//p" "$ERZEUGER")" = "$(sed -n "s/^RUF_TEIL=//p" "$(emittiert)")" ]
  for schluessel in 'Stufe ohne Deklaration' 'Deklaration ohne Stufe'; do
    grep -qF "$schluessel" "$ERZEUGER"
    grep -qF "$schluessel" "$(emittiert)"
  done

  # GETRENNT, UND ZWAR GEMESSEN STATT UNTERSTELLT: die Anker-Ableitung ist KEIN geteiltes
  # Stueck. Sie bildet das Verhalten eines Doku-Gates nach, und das ist nur dort zu
  # verantworten, wo dieses Gate laeuft — hier haelt `make docs-check` in `make gates` den
  # Ausgang dieses Erzeugers, im Ziel gibt es keinen solchen Traeger. Die ausgelieferte
  # Fassung fuehrt darum KEINE der Ableitungs-Stellen; ein Nachzug, der sie doch mitnaehme,
  # faellt hier.
  for stelle in 'slug_fuer' 'slug_sicher' 'titel_rein' 'titel_fuer' 'TYPOGRAFIE' 'SATZZEICHEN' 'ANFUEHRUNGEN'; do
    [ "$(grep -c "$stelle" "$ERZEUGER")" -ge 1 ]
    [ "$(grep -c "$stelle" "$(emittiert)")" -eq 0 ]
  done
  # Und sie baut auch keinen Link zusammen: kein Markdown-Verweis im Ausgabe-Pfad.
  [ "$(grep -c '](' "$(emittiert)")" -eq 0 ]
  [ "$(grep -c '](' "$ERZEUGER")" -ge 1 ]
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

@test "trennlinie: die ausgelieferte Fassung schreibt nie einen Verweis, unsere immer einen aufloesenden" {
  # DIE EINE GEWOLLTE DIFFERENZ, in einem Fall belegt. Wer sie angleicht, hebt eine Zusage
  # auf: unsere Fassung urteilt ueber UNSER Lastenheft, und ihr Ausgang steht unter
  # `make docs-check`; die ausgelieferte kennt das Gate ihres Ziels nicht und behauptet
  # darum keinen Anker.
  fixture "$TMP/trenn"
  cd "$TMP/trenn"

  # (a) DIE AUSGELIEFERTE FASSUNG: Code-Span, obwohl die Ueberschrift auflosen WUERDE.
  run env E2E_ABDECKUNG_QUELLE=tools/harness/mein-e2e.sh bash "$(emittiert)"
  [ "$status" -eq 0 ]
  [ "$(grep -c '^| `LH-FA-01` |' docs/user/e2e-abdeckung.md)" -eq 1 ]
  [ "$(grep -c '](' docs/user/e2e-abdeckung.md)" -eq 0 ]

  # (b) UNSERE FASSUNG ueber derselben Lage: ein Verweis, und er loest gegen die
  # Ueberschrift auf.
  sed -i 's@^echo "selbstpruefung: @echo "full-smoke: @' tools/harness/mein-e2e.sh
  run bash "$ERZEUGER" tools/harness/mein-e2e.sh docs/user/unsere.md spec/lastenheft.md
  [ "$status" -eq 0 ]
  grep -qF '[`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)' docs/user/unsere.md
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
  # SPEC: die GENANNTE Datei steht im Kopf der Sicht als Massstab des Lesers — und die
  # Vorgabe steht nicht daneben. Das ist die Wirkung, die der Marker seit dem Wegfall der
  # Verweise hat; gemessen an dem, was entsteht.
  [ "$(grep -c 'anders/anforderungen.md' sicht/abdeckung.md)" -ge 1 ]
  [ "$(grep -c 'spec/lastenheft.md' sicht/abdeckung.md)" -eq 0 ]
}

@test "anker (unsere Fassung): Inline-Syntax, unbekanntes Zeichen und Whitespace bekommen keinen Verweis — schlichte Ueberschriften bekommen ihn" {
  # DREI LAGEN, IN DENEN DIE ROHZEILE NICHT IHR EIGENER GERENDERTER TEXT IST, und die
  # vierte, in der sie es ist. Gemessen wurde die Klasse je Lage gegen `make docs-check`;
  # gehalten wird sie hier und, fuer den realen Bestand, vom Doku-Gate ueber
  # docs/user/e2e-abdeckung.md.
  mkdir -p "$TMP/roh/tools/harness" "$TMP/roh/spec" "$TMP/roh/docs/user"
  cd "$TMP/roh"
  {
    printf '### RQ-A — [Zitat](../README.md) im Titel\n\nText.\n\n'
    printf '### RQ-B — Zitat »Wert«\n\nText.\n\n'
    printf '### RQ-C — Titel mit Leerzeichen   \n\nText.\n\n'
    printf '### RQ-D — schlicht und ohne Syntax\n\nText.\n'
  } > spec/lastenheft.md
  [ "$(grep -c '^### RQ-' spec/lastenheft.md)" -eq 4 ]

  # GRUEN: die zwei Lagen, die tragen — und RQ-C ist die, an der der Trim haengt.
  cat > tools/harness/gruen.sh <<'EOF'
#!/usr/bin/env bash
e2e_abdeckung() { :; }
echo "full-smoke: eins ..."
e2e_abdeckung "RQ-C" "whitespace" "eins"
echo "full-smoke: zwei ..."
e2e_abdeckung "RQ-D" "schlicht" "zwei"
EOF
  run bash "$ERZEUGER" tools/harness/gruen.sh docs/user/gruen.md spec/lastenheft.md
  [ "$status" -eq 0 ]
  grep -qF '(../../spec/lastenheft.md#rq-c--titel-mit-leerzeichen)' docs/user/gruen.md
  grep -qF '(../../spec/lastenheft.md#rq-d--schlicht-und-ohne-syntax)' docs/user/gruen.md

  # ROT, je Lage einzeln — und jede mit IHRER Begruendung, nicht irgendeiner.
  for fall in A:Markdown-Inline-Syntax B:"nicht sicher abzuleiten"; do
    k="RQ-${fall%%:*}"
    grund="${fall#*:}"
    cat > tools/harness/rot.sh <<EOF
#!/usr/bin/env bash
e2e_abdeckung() { :; }
echo "full-smoke: eins ..."
e2e_abdeckung "$k" "rot" "eins"
EOF
    run bash "$ERZEUGER" tools/harness/rot.sh docs/user/rot.md spec/lastenheft.md
    [ "$status" -ne 0 ]
    printf '%s' "$output" | grep -qF "$grund"
    printf '%s' "$output" | grep -qF 'Link ohne Ziel'
    [ ! -f docs/user/rot.md ]
  done
}
