#!/usr/bin/env bats
# stamp-records-mechanik.bats — Waechter am Konsum des Mutations-CI-Result-Files in
# Fall-Form (harness/tools/mutate.sh --stamp-records, ADR-0107 Festlegungen 1/2/3/5;
# slice-stamp-records-konsum-v1 LP 1/LP 2).
#
# HERMETISCH: das gepinnte bats-Image fuehrt weder `git` noch `make` — der Konsum ist
# eine reine Transformation (er urteilt nicht, der Exit meldet sie, ADR-0107 Festlegung
# 3) und loest Wurzel und Fall-Verzeichnis ueber `--wurzel` auf; die Fixtures tragen
# Fake-Fall-Dateien und ein nachgebautes `mutate-ergebnis.txt` in der Ergebnis-Fassung
# des Vorgangs (harness/tools/mutate-auswahl.sh, ergebnis_schreiben). Das reale
# Result-File-Form-Muster steht byte-genau an einer Stelle (ergebnis_schreiben); diese
# Suite haelt den Konsum an der Form, nicht am Aufruf des Vorgangs.
#
# ZUSAEGE (ADR-0107 Festlegung 1/3):
#   1. JEDEM Anhang geht die volle Pruefung voraus — jede fail-closed-Grenze
#      (fehlendes/leeres/unlesbares Result-File, doppelte Bestimmung in beiden Formen,
#      unbekannte/mehrdeutige Fall-Kennung) bricht mit `stamp-records: ABBRUCH`-Meldung
#      und faesst den Fall-File-Bestand NICHT an (auch .harness/stamp/mutate/ bleibt,
#      wie es war).
#   2. Der Happy-Lauf haengt je Fall genau eine Urteils-Zeile
#      `<datum> · commit <sha8> · form ok|befund[ · qualifikator infra|last] · run <id> attempt <n>`
#      an und schreibt je neuem Fall-File den Kopf mit Run, Attempt und geprueftem
#      Commit (MR-051-Form: je Zahl ein Kommando).
#   3. FeLHT-, UNERWARTET-Zeilen und Fall-Zeilen ohne Fall-Ergebnis werden nicht
#      angehaengt — kein Fall-File entsteht fuer sie.
#   4. Ein RETRY desselben Sweep-Ergebnisses mit neuer run-id haengt an (kein bruch);
#      die Doppelung desselben geprueften Commits ist am Kopf lesbar (Plan §6, Risiko 3).
#   5. JEDE fail-closed-Zweig-Form bricht eigen (Review F-2, Ergaenzung): zwei
#      'gepruefter Commit:'-Zeilen, keine Commit-Zeile, keine Fall-Urteil-Zeile,
#      zwei Kennungs-Formen auf dieselbe Fall-Datei, fehlendes Fall-Verzeichnis und
#      die Aufruf-Vorbedingungen (attempt-Nummer, qualifikator-Wert).
#
# WAS HIER NICHT GEMESSEN WIRD (Grenze, F-2-Form): die Anlagen-Tiefe — je neuem
# Zweig-Fall steht KEIN Mutations-Fall; die Anlagen-Form traegt allein die
# 810-Klasse (die fehlt/leer-Pruefung an der Meldung-Zusage). Ein Regress an den
# Zwoeg der Tests 11-17 bindet der Verhaltens-Zug, nicht die Anlage.

setup() {
	REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"
	MUT="$REPO/harness/tools/mutate.sh"
	[ -f "$MUT" ]
}

# baue_fixture setzt eine Mini-Wurzel auf: zwei Fake-Faelle unter test/mutations/,
# ein Result-File in der Ergebnis-Fassung des Vorgangs. $1: Unterverzeichnis.
baue_fixture() {
	FIX=$(mktemp -d "${TMPDIR:-/tmp}/stamp-records-XXXXXXXX")
	mkdir -p "$FIX/test/mutations"
	touch "$FIX/test/mutations/810-foo-bar.sh" "$FIX/test/mutations/811-bar.sh"
	Commitzeile="gepruefter Commit: 625cdef096cfeec27cda3f3fcfd9cbb0960b2212"
	Ergebnis="$FIX/mutate-ergebnis.txt"
	printf '%s\n' \
		'mutate-ergebnis: slice-fix' \
		"$Commitzeile" \
		'Shard 0: Exit 0, 10 s, Faelle: 810-foo-bar' \
		"ok       810-foo-bar   Shard 0" \
		"BEFUND   811-bar      Shard 1" \
		"FEHLT    900-kein-fall" \
		"UNERWARTET 901-fremd" \
		"BEFUND (kein Ergebnis im Log)   810-foo-bar   Shard 1" \
		'Fallmenge: 2 (Slice: 2)' \
		'Urteil: BEFUND' \
		> "$Ergebnis"
}

@test "stamp-records: ein fehlendes Result-File bricht fail-closed und fasst den Fall-File-Bestand nicht an" {
	baue_fixture
	run bash "$MUT" --stamp-records "$FIX/nicht-da.txt" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'Result-File fehlt', keine Ablage)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"stamp-records: ABBRUCH — Result-File fehlt"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: ein leeres Result-File bricht fail-closed und fasst den Fall-File-Bestand nicht an" {
	baue_fixture
	: > "$FIX/leer.txt"
	run bash "$MUT" --stamp-records "$FIX/leer.txt" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'Result-File ist leer', keine Ablage)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"stamp-records: ABBRUCH — Result-File ist leer"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: eine unlesbare Result-File-Zeile bricht mit der Zeile statt sie still durchzulassen" {
	baue_fixture
	sed -i 's/^ok       810-foo-bar   Shard 0$/ok 810-foo-bar Wobble 0/' "$Ergebnis"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'unlesbare Result-File-Zeile')"
	[ "$status" -ne 0 ]
	[[ "$output" == *"stamp-records: ABBRUCH — unlesbare Result-File-Zeile"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: derselbe Fall zweimal im Result-File ist eine doppelte Bestimmung und bricht" {
	baue_fixture
	sed -i 's/^BEFUND   811-bar      Shard 1$/ok       810-foo-bar   Shard 1/' "$Ergebnis"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'steht zweimal im Result-File')"
	[ "$status" -ne 0 ]
	[[ "$output" == *"steht zweimal im Result-File"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: eine unbekannte Fall-Kennung bricht und nennt den Fall" {
	baue_fixture
	sed -i 's/^ok       810-foo-bar   Shard 0$/ok       999-gib-es-nicht   Shard 0/' "$Ergebnis"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH, Fall-Kennung 999-gib-es-nicht)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"Fall-Kennung '999-gib-es-nicht'"* ]]
	[[ "$output" == *"kein Treffer"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: eine mehrdeutige Fall-Kennung bricht und nennt die Fundliste" {
	baue_fixture
	touch "$FIX/test/mutations/8-foo-bar.sh"
	sed -i 's/^ok       810-foo-bar   Shard 0$/ok       foo-bar   Shard 0/' "$Ergebnis"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'mehrdeutig', Fundliste)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"ist mehrdeutig"* ]]
	[[ "$output" == *"8-foo-bar"* ]] && [[ "$output" == *"810-foo-bar"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: das Paar (fall, run, attempt) im Fall-File bricht die Wiederholung, Bestand byte-gleich" {
	baue_fixture
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	[ "$status" -eq 0 ]
	vor="$(find "$FIX/.harness/stamp/mutate" -type f -exec sha256sum {} + | LC_ALL=C sort)"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH am Paar (fall, run, attempt))"
	[ "$status" -ne 0 ]
	[[ "$output" == *"steht bereits in"* ]]
	nach="$(find "$FIX/.harness/stamp/mutate" -type f -exec sha256sum {} + | LC_ALL=C sort)"
	[ "$vor" = "$nach" ]
	rm -rf "$FIX"
}

@test "stamp-records: der Happy-Lauf haengt je Fall eine Urteils-Zeile an und je neuem Fall-File den Kopf" {
	baue_fixture
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --qualifikator last --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: Exit 0, je Fall eine Zeile, Kopf je neuem File)"
	[ "$status" -eq 0 ]
	[ -f "$FIX/.harness/stamp/mutate/810-foo-bar.txt" ]
	[ -f "$FIX/.harness/stamp/mutate/811-bar.txt" ]
	# Kopf je neuem File: Run, Attempt und gepruefter Commit, MR-051-Form (je Zahl das Kommando).
	grep -q "^# Run 42, Attempt 1 — Argumente des Konsum-Laufs:" "$FIX/.harness/stamp/mutate/810-foo-bar.txt"
	grep -q "Gepruefter Commit 625cdef096cfeec27cda3f3fcfd9cbb0960b2212" "$FIX/.harness/stamp/mutate/810-foo-bar.txt"
	grep -q -- "--run 42 --attempt 1" "$FIX/.harness/stamp/mutate/810-foo-bar.txt"
	# Zeilen-Form je Fall (ADR-0107 Festlegung 1); der befund-Fall traegt den Qualifikator.
	grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} · commit 625cdef0 · form ok · run 42 attempt 1$' "$FIX/.harness/stamp/mutate/810-foo-bar.txt"
	grep -qE '^[0-9]{4}-[0-9]{2}-[0-9]{2} · commit 625cdef0 · form befund · qualifikator last · run 42 attempt 1$' "$FIX/.harness/stamp/mutate/811-bar.txt"
	# FEHLT/UNERWARTET/kein-Ergebnis: kein Fall-File fuer sie (ADR-0107 Festlegung 1).
	[ ! -f "$FIX/.harness/stamp/mutate/900-kein-fall.txt" ]
	[ ! -f "$FIX/.harness/stamp/mutate/901-fremd.txt" ]
	rm -rf "$FIX"
}

@test "stamp-records: ein Retry mit neuer run-id haengt an; der gepruefte Commit steht im Kopf (Plan §6, Risiko 3)" {
	baue_fixture
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	[ "$status" -eq 0 ]
	kopf="$(head -1 "$FIX/.harness/stamp/mutate/810-foo-bar.txt")"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 43 --attempt 1 --wurzel "$FIX"
	echo "exit=$status (Zusage: Exit 0 — die Doppelung desselben geprueften Commits ist am Kopf lesbar, kein bruch am neuen Paar)"
	[ "$status" -eq 0 ]
	grep -q "Gepruefter Commit 625cdef096cfeec27cda3f3fcfd9cbb0960b2212" "$FIX/.harness/stamp/mutate/810-foo-bar.txt"
	[ -n "$kopf" ]
	rm -rf "$FIX"
}

@test "stamp-records: die umbenannte Fall-Quelle loest nicht mehr auf und bricht, die Geschichte bleibt an der alten Adresse" {
	# Plan §6, Risiko 2: die Fall-Kennung einer gestempelten Datei loest nach dem
	# Umbenennen ihrer Mutations-Datei nicht mehr — die Grenze ist erwartbar fail-closed
	# (die Meldung nennt den Fall) und die gestempelte Geschichte bleibt lesbar.
	baue_fixture
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	[ "$status" -eq 0 ]
	geschichte="$(cat "$FIX/.harness/stamp/mutate/810-foo-bar.txt")"
	mv "$FIX/test/mutations/810-foo-bar.sh" "$FIX/test/mutations/900-neu.sh"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 43 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH, Fall-Kennung 810-foo-bar unbekannt)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"Fall-Kennung '810-foo-bar'"* ]]
	[ "$geschichte" = "$(cat "$FIX/.harness/stamp/mutate/810-foo-bar.txt")" ]
	rm -rf "$FIX"
}

@test "stamp-records: zwei 'gepruefter Commit:'-Zeilen sind eine doppelte Bestimmung" {
	baue_fixture
	sed -i "2a gepruefter Commit: 1111111111111111111111111111111111111111" "$Ergebnis"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'zwei gepruefter Commit-Zeilen', keine Ablage)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"zwei 'gepruefter Commit:'-Zeilen"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: ein Result-File ohne 'gepruefter Commit:'-Zeile bricht" {
	baue_fixture
	sed -i '/^gepruefter Commit: /d' "$Ergebnis"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'traegt keine gepruefter Commit-Zeile', keine Ablage)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"traegt keine 'gepruefter Commit:'-Zeile"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: ein Result-File ohne Fall-Urteil-Zeile bricht (nur FEHLT ist kein Anhang)" {
	# Der reale Vorgang kann diese Fassung schreiben (ergebnis_schreiben): jeder
	# Shard ohne Beleg laesst alle Faelle als FEHLT stehen — kein Fall-Urteil,
	# kein Anhang, und der Konsum bricht statt still anzuhängen.
	baue_fixture
	grep -vE '^(ok|BEFUND)' "$Ergebnis" > "$FIX/ohne-faelle.txt"
	run bash "$MUT" --stamp-records "$FIX/ohne-faelle.txt" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'traegt keine Fall-Urteil-Zeile', keine Ablage)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"traegt keine Fall-Urteil-Zeile"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: zwei Kennungs-Formen, die auf dieselbe Fall-Datei loesen, sind eine doppelte Bestimmung" {
	# Die Aufloesungs-Doppelung: '810-foo-bar' (voller Name) und 'foo-bar'
	# (Slug-Form) loesen auf dieselbe Datei — über ein bearbeitetes Result-File
	# erreichbar, das der Konsum laut liest.
	baue_fixture
	sed -i 's/^BEFUND   811-bar      Shard 1$/ok       foo-bar       Shard 1/' "$Ergebnis"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'loesen beide auf 810-foo-bar')"
	[ "$status" -ne 0 ]
	[[ "$output" == *"loesen beide auf"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: ein fehlendes Fall-Verzeichnis bricht" {
	baue_fixture
	rm -rf "$FIX/test/mutations"
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'kein Fall-Verzeichnis')"
	[ "$status" -ne 0 ]
	[[ "$output" == *"kein Fall-Verzeichnis"* ]]
	rm -rf "$FIX"
}

@test "stamp-records: --attempt 0 ist keine Attempt-Nummer" {
	baue_fixture
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 0 --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'keine positive Attempt-Nummer', keine Ablage)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"--attempt ist keine positive Attempt-Nummer"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}

@test "stamp-records: ein unbekannter --qualifikator-Wert bricht" {
	baue_fixture
	run bash "$MUT" --stamp-records "$Ergebnis" --run 42 --attempt 1 --qualifikator beides --wurzel "$FIX"
	echo "exit=$status Meldung=[$output] (Zusage: ABBRUCH 'qualifikator ist infra|last', keine Ablage)"
	[ "$status" -ne 0 ]
	[[ "$output" == *"--qualifikator ist infra|last"* ]]
	[ ! -d "$FIX/.harness/stamp/mutate" ]
	rm -rf "$FIX"
}
