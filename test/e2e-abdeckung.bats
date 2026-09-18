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
  KOPFZEILE='| Spec-Kennung | Stufe | Ort | Kurzbeschreibung |'
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
}
