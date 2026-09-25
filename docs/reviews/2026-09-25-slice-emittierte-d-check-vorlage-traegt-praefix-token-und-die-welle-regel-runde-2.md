# Review-Report: slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel, Runde 2 — 2026-09-25

**Review-Art:** Code — Diff gegen Plan, ADR und Hard Rules (Modul 10). Nicht gegen die DoD (das ist der Verifier).

**Gegenstand:** `git diff 34f4b737..HEAD` — sechs Commits: `753820c4` und `ae6b6f7f` (Planner, Abnahme-Wortlaut),
`1686433e` (Kommentar-Satz in der Vorlage), `665d36a2` (R3: Eingrenzung der `link-policy`-Zusicherung, Fall 443),
`6b310792` (R2: Kommentar in `full-smoke.sh`), `0f6f46fd` (R4: Kombinationen des grünen Starts aus dem Träger abgeleitet,
erzeugte Abdeckungs-Sicht). `git diff --stat 34f4b737..HEAD` → 6 Dateien, 185 Zeilen hinzu, 19 entfernt: Slice-Plan,
`docs/user/e2e-abdeckung.md`, `harness/tools/full-smoke.sh`, `internal/emit/emit_test.go`,
`internal/emit/templates/d-check.yml`, Mutations-Fall 443.

**Vorlauf:** Runde 1 liegt unter `docs/reviews/2026-09-25-slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel.md`
(R1 bis R8). Der Implementer-Bericht lag nicht vor und war keine Quelle; Code, Tests und Sonden sind selbst gelesen und gefahren.

**Plan-Bezug:** Slice `slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel` (§1, §3, §6, §8) — Kennung, nicht
Pfad: der Plan wandert mit dem Lifecycle. **Constraint:** `ADR-0065` (`Accepted`); `LH-FA-01`, `LH-FA-03`, `LH-QA-01`, `LH-QA-02`;
`MR-054`, `MR-055`, `MR-071`; `AGENTS.md` §3.6, §3.7, §3.8, §3.10, §3.11.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (2026-09-13) · **Modell:** Sonnet 5 · **Datum:** 2026-09-25

**Eigene Sensor-Läufe dieses Laufs** (kein Host-Go, kein `make mutate`, Prüfgegenstand unberührt; alle Sonden in Scratchpad-Kopien
oder an Scratchpad-Zielen):

- `make docs-check` → `1885 Datei(en) geprüft, 0 Befund(e)`; `make comment-claims` → `76 Datei(en) geprueft, 0 Befund(e)`;
  `make e2e-abdeckung` → *„unverändert — docs/user/e2e-abdeckung.md (21 Stufen, 21 Deklarationen)"*, `git status --short` danach leer.
- `test/full-smoke-ausgang.bats` und `test/e2e-abdeckung.bats` im gepinnten bats-Image: 26 ok, 0 not ok.
  `git diff 34f4b737..HEAD --stat -- test/full-smoke-ausgang.bats` leer: nicht gelockert.
- **Stufe (a) der Kennungs-Form** aus `full-smoke.sh` herausgelöst (Zeilen von `kf_docs_check` bis vor die Position `local adr=`,
  samt `psed_i` und `einordnen`; die Funktion selbst unverändert) und gegen echte Träger und Shims gefahren — s. Tabelle unten.
- **Go-Test der Vorlage** in einer Scratchpad-Kopie (`git archive HEAD`, Test-Stage des Dockerfiles auf
  `go test ./internal/emit -run TestDCheckConfig -v` verengt, eigener Bild-Tag): unmutiert grün; Fälle 435, 438, 439, 443 und zwei
  Ad-hoc-Mutationen emuliert (Tabelle unten).
- **Kommentar-Satz** im Ziel geprüft: frisch gebootstrapptes Ziel, echter `docs-check` mit dem gepinnten d-check.
- **Nicht gefahren:** `make mutate` (verboten, Beleg hängt am Baum-Hash: Verifier); `make full-smoke` als Ganzes (lang; die Funktion
  ist ab dem Abschnitt `local adr=` nicht gefahren — die Stufe (b), ihre fünf Gegenbeispiele, ist Gegenstand von Runde 1 und im Diff
  dieser Runde unverändert); `make lint`/`make test-go` als Ganzes. `make gates` — siehe Ende.

---

## R4-Mechanismus: Ableitung der Kombinationen aus den Fehlermeldungen des Trägers

Gefahren wird mit dem Träger `.harness/state/bin/ai-harness-init` (Meldungen gemessen: `unbekannte Sprache "kf-unbekannt"; verfuegbar: cpp, go` ·
`unbekannte Architektur "kf-unbekannt"; verfuegbar: flat, hexagonal, hexslice` · `cpp --arch hexagonal` →
`unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice`, je Exit 2; die Probe schreibt nichts ins Ziel außer `.git`).

| Sonde | Träger / Shim | Ergebnis der Stufe |
|---|---|---|
| unmutiert | echter Träger | 6 Kombinationen gefahren (sprachlos, cpp flat, cpp hexslice, go flat, go hexagonal, go hexslice), `cpp hexagonal` als „nicht getragen — kein Fall": dieselben Kombinationen, die der Plan nennt; Exit 0 |
| neue Kombination | Scratchpad-Träger, `langArchs()` um `cpp hexagonal` ergänzt (gebaut über `make host-bin` in Kopie mit eigenem Tag) | **7 Kombinationen**, `cpp hexagonal` grün (`0 Befund(e)`), ohne Änderung an `full-smoke.sh`; Exit 0 |
| Wortlaut geändert | Shim: `verfuegbar: ` → `verfuegbar sind: ` | **Exit 1**, Meldung nennt das Muster `'verfuegbar: '` und gibt beide Roh-Ausgaben aus (gelesen) |
| Exit 2 aus anderem Grund | Shim: `cpp --arch hexagonal` → `Fehler: irgendwas anderes kaputt`, Exit 2 | **Exit 1**, *„grüner Start (cpp hexagonal): der Bootstrap ist NICHT Exit 0 (Exit 2)"* — der Exit 2 wird nicht verschluckt, solange die Meldung nicht `unbekannte Architektur "<arch>"` trägt |
| Geistersprache | Shim nennt `rust` in der Sprachliste | **Exit 1** (`rust flat` Exit 2, andere Meldung) |
| Geisterarchitektur | Shim nennt `zzz` in der Architekturliste | Exit 0; `cpp zzz` und `go zzz` als „nicht getragen"; 6 Kombinationen wie unmutiert |
| Leerzeichen, Komma-Rest | Shim: `verfuegbar:  cpp ,go , ` | robust: `tr -d ' '` und `sed '/^$/d'` liefern dieselben Namen, Exit 0, 6 Kombinationen |
| Sprache ausgelassen (Format bleibt) | Shim: Sprachliste nur `go` | Exit 0, **4 Kombinationen**, cpp wird nicht gefahren — vom Plan als *„Nicht belegt"* benannt |
| Architektur ausgelassen (Format bleibt) | Shim: `hexslice` fehlt in der Liste | Exit 0, 4 Kombinationen — vom Plan als *„Nicht belegt"* benannt |
| **getragene Kombination als „nicht getragen" abgelehnt** | Shim: `go --arch flat` → `unbekannte Architektur "flat"; verfuegbar: hexagonal, hexslice`, Exit 2 | **Exit 0, 5 Kombinationen**, `go flat` als *„vom Traeger nicht getragen — kein Fall"* (N1) |

**(a) Muster oder Vertrag?** Der Wortlaut ist die Quelle der Stufe, und kein Test hält die *Formatierung* der Meldung
(`grep -rn 'verfuegbar: ' --include='*_test.go' internal cmd | wc -l` → 0, gemessen in diesem Lauf). Die Stufe ist dagegen
fail-closed (Wortlaut-Sonde: Exit 1 mit gelesener Meldung), und die Grenze steht im Plan (Liefer-Punkt 3 (a), §6) und als
Ausschluss. Das ist ein tragfähiges Muster, kein stilles Lesen eines Vertrags: getragen ist die **Umbenennung**; nicht getragen
sind die im Plan benannten Inhalts-Fälle und der eine, den der Plan nicht benennt (N1).

**(b) Lücken der Ableitung.** Eine Sprache ohne `langArchs()`-Eintrag: alle ihre Kombinationen enden mit Exit 2
`unbekannte Architektur`, keine läuft grün, die Endprüfung der Stufe (`getragen` gegen die Sprachliste) schlägt mit Exit 1 an —
gemessen am Quelltext (`archSupported` verneint jede Architektur einer Sprache ohne Eintrag), nicht mit einem Shim. Eine
Architektur, die nur eine Sprache trägt, ist die Kombination `cpp hexagonal` heute (Exit 2, nicht getragen — gewollt). Ein Name,
den die Meldung auslässt: benannt (Plan „Nicht belegt"). Die getragene Kombination, die der Träger irrig ablehnt: N1.

**(c) Exit 2 aus anderem Grund:** gemessen, Exit 1. Die Abgrenzung hängt an der Zeichenfolge `unbekannte Architektur "<arch>"`;
ein anderer Exit 2 ohne sie fällt durch.

**(d) `set -e`, Pipelines, Zerlegung:** `lang_out`/`arch_out` mit `|| true`; `kf_liste` ist eine Pipeline aus `sed -n`, `tr`, `tr`, `sed`
(unter `pipefail` kein Fehlschlag, wenn `sed -n` nichts ausgibt: leere Namen enden im Guard mit Exit 1, gemessen über die
Wortlaut-Sonde); leere Namen, Leerzeichen, Komma-Reste: Sonde „Leerzeichen"; Klammern und Anführungszeichen kommen in den Namen
nicht vor (`%q` steht vor dem Semikolon, `.*verfuegbar: ` löscht es). Zwei Zeilen mit `verfuegbar: ` in einer Ausgabe würden
ihre Listen vereinigen: heute gibt der Träger eine.

**(e) Sonden nachgefahren:** alle drei des Auftrags (Scratchpad-Träger mit `cpp hexagonal`, Shim gegen `verfuegbar: `, unmutiert).

**Neuer Plan-Wortlaut (`ae6b6f7f`):** Die Aussagen zu `SupportedLangs()` (aus `profiles()`, `internal/gen/gen.go`) und
`SupportedArchs()` (Union aus `langArchs()`, definiert in `internal/gen/arch.go`, nicht in `gen.go`; der Plan sagt „in
`internal/gen/`") stimmen. Das Gegenbeispiel *„bricht, wenn eine getragene Sprache/Architektur in den zwei Meldungen fehlt …"* wird
vom Code **nicht** rot gefärbt (Sonden „ausgelassen"): der Satz ist die Bedingung, unter der die Zusage falsch wird, und der Plan
sagt das selbst (*„dann sagt die Stufe mehr, als sie misst"*; *„Nicht belegt"*). Das ist ehrlich benannt, aber keine Zusage, die
bricht — der Verifier liest ihn als Grenze. Die beiden „Belegt"-Aussagen (eine Kombination mehr; Shim → Exit 1) sind reproduziert.
Nicht benannt ist der Fall aus N1.

## Emulierte Zähne (Go-Test der Vorlage)

| Fall / Sonde | Mutation | roter Test im Bild |
|---|---|---|
| unmutiert | — | `TestDCheckConfig_EntschiedeneModulListe`, `_KennungsForm` (alle Unterfälle), `keine_ziffern_form`: PASS |
| 443 | `link-policy: always` → `never` auf der ADR-Zeile von `ids` | `--- FAIL: TestDCheckConfig_EntschiedeneModulListe`, Meldung *„das ADR-Muster von ids traegt nicht link-policy: always (Zeile: …link-policy: never})"*; der Kommentar der Vorlage trägt den Ausdruck weiter (Ausgabe des Tests zeigt beide Kommentarzeilen) — Gegenprobe: die Zusicherung wird nicht mehr von der Datei-weiten Zeichenfolge erfüllt |
| 435 | Slice-Token in Ziffern-Form | `KennungsForm/token_slice` |
| 438 | `ids`-Muster ohne Segment | `KennungsForm/ids_muster_adr` (Meldung *„ids traegt nicht genau das segment-tolerante ADR-Muster"*) |
| 439 | Glob ohne Bereichs-Präfix | `KennungsForm/adr_klasse_bereichs_praefix` |
| Sonde: `link-policy` von der ADR-Zeile entfernt | `, link-policy: always}` → `}` | `EntschiedeneModulListe` rot (Zeile ohne Ausdruck) |
| Sonde: ADR-Zeile umformatiert (Doppelquotes) | Anführungszeichen statt `'…'` | `EntschiedeneModulListe` rot mit `(Zeile: "")` — **nicht** still grün: die nicht gefundene Zeile ist ein Fehlschlag |

Der `sed`-Anker von 443 ändert die Datei im heutigen Bestand (`diff` gegen `HEAD` zeigt genau die Zeile). Die Eingrenzung in
`emit_test.go` liest den `ids:`-Block über die Spalte 0 (`line[0] != ' ' && != '#'`) und die letzte Zeile `- {regex: 'ADR-`;
eine Umformatierung der Vorlage macht die Zusicherung rot, nicht leer-grün.

## Kommentar-Satz der Vorlage (`1686433e`)

Im Ziel geprüft (frisch gebootstrapptes Ziel, gepinnter d-check, Ausgangslage `0 Befund(e)`):

| Sonde | Ergebnis | Aussage des Satzes |
|---|---|---|
| `## Geschichte` in `spec/lastenheft.md` mit `slice-abc`, `welle-x`, `ADR-` und `ADR-12` | `0 Befund(e)` | „nimmt dort Slice- und Welle-Token aus" — stimmt; „bares `ADR-` faengt keine Regel" — stimmt |
| dieselben Token unter dem Abschnitt `## 7. Historie` (Ende der Datei) | 2 Befunde, `matrix-forbidden spec-straten → slice`/`→ welle` | „ihre Ueberschrift ist 7. Historie" — stimmt, und der Abschnitt nimmt nichts aus |
| bares `Siehe ADR- und ADR-12 hier.` außerhalb von `Geschichte` | `0 Befund(e)` | stimmt |
| `grep -n '^## ' spec/lastenheft.md` im Ziel | Überschriften bis `## 7. Historie`, keine `Geschichte` | stimmt |
| `grep -rn 'ADR-[^0-9]' spec/*.md` im Ziel | Treffer als Wort (`ADR-Rückzeiger`, `ADR- und kein Slice-Verweis`, `ADR-Bezüge`) | „steht als Wort in den emittierten Spec-Vorlagen" — stimmt |
| das Ziel führt die Rolle Reviewer (`.claude/agents/reviewer.md`, `.harness/skills/reviewer.md`) | ja | „faengt ihn nur der Reviewer" — nichts anderes im Ziel fängt es (die Sonde blieb `0 Befund(e)`); die Aussage nennt nichts, was nicht stimmt |

Zustandsform und Indikativ (§3.7): keine verworfene Alternative, kein abwesender Text, keine Kennung dieses Repos;
`git diff 34f4b737..HEAD -- internal/emit/templates/d-check.yml | grep '^+' | grep -P '[^\x00-\x7F]'` → leer (ASCII wie der Bestand).
Die Vorlage ist sonst unverändert: der Diff zeigt allein die sieben Kommentarzeilen. Die beiden Sätze sind Grenze, nicht Zusage; der
zweite (`ADR-`) steht im Absatz über `exclude-sections`, ohne mit ihm zusammenzuhängen — Lesbarkeit, kein Befund.

## Größe und Abgrenzung

- Kein Adaptions-Eintrag, keine Hard-Rule-Änderung (`git diff --stat 34f4b737..HEAD -- harness/conventions.md harness/conventions AGENTS.md .harness` leer).
- Vorlage außerhalb des Kommentar-Satzes unverändert; `test/full-smoke-ausgang.bats` unverändert und grün.
- Rollen: `753820c4` und `ae6b6f7f` nennen die Rolle Planner und berühren allein den Slice-Plan; die vier Implementer-Commits nennen
  die Rolle und berühren Vorlage-Kommentar, Test und Fall, `full-smoke.sh` samt erzeugter Sicht. Kein Closure-Schritt, kein
  Lifecycle-Wechsel (§3.10). Der Planner ändert den Abnahme-Wortlaut *nach* der Implementierung — das ist die Rolle, die ihn schreiben
  darf; der Wortlaut nennt die Grenzen als Grenzen.
- `git diff 34f4b737..HEAD | grep -cE 'shellcheck disable|nolint'` → 0.
- Register-Fallen (Plan §8) an den neuen Fällen: `!` mitten im Fall — der Diff legt keinen bats-Fall an, die Stufe führt kein `!`;
  weite Assertion verdeckt die enge — die Prüfung der Stufe ist eng (`grep -qF` auf `unbekannte Architektur "<arch>"`, Endprüfung je
  Sprache über `grep -qF " $sprache "` auf die Wortliste); Zusage nur über Fall-Assertion ohne Zahn — 443 bindet die `link-policy`-
  Position (s. o.); die Zusage der Ableitung hat Sonden, keinen Fall in `test/mutations/` (INFO N3).

## Status der Runde-1-Befunde

| ID (Runde 1) | Status | Beleg dieses Laufs |
|---|---|---|
| R1 MEDIUM (`exclude-sections` nimmt `Geschichte` in Spec-Dateien aus) | **als Grenze getragen** | Kommentar-Satz steht, stimmt gegen die Vorlage (Sonden oben); Ausschluss im Plan benennt die Grenze und ihre Ursache (nur auf der Ebene der `matrix` setzbar). Der Widerspruch zum Wortlaut von `ADR-0065` (§Festlegung 1 *„Spec-Straten: Umformulieren … keine ausgenommene Sektion"*) ist damit **benannt, nicht entschieden**; die Entscheidung (Folge-ADR, oder Grenze annehmen) bleibt beim Architect, im Plan §6 als *„offen bis Closure"*. Kein Befund am Diff |
| R2 LOW (Kommentar in `full-smoke.sh` grundlos umformuliert) | **behoben** | `git diff 0abb97ac..HEAD -- harness/tools/full-smoke.sh` → zwei Hunks, beide gehören der Stufe (Variable `tmprepo_kf` und die Stufe); der Kommentar (a2) hat wieder den Wortlaut von `0abb97ac` (`den ein gebootstrapptes Repo`, Zeile 3557) |
| R3 LOW (`Contains` über die ganze Datei trifft den Kommentar) | **behoben** | 443 emuliert: Test rot aus dem behaupteten Grund; Kommentar-Vorkommen halten den Test nicht grün; Umformatierung und Entfernen färben rot statt leer-grün |
| R4 LOW (Kombinationen hartverdrahtet) | **behoben, mit neuem Befund N1** | Ableitung folgt der Quelle (7 Kombinationen mit `cpp hexagonal`), Wortlaut-Sonde Exit 1; ein Restfall (N1) |
| R5 INFO (Positions-Liste des Herkunfts-Kommentars ohne Träger) | unverändert | Planner beim Closure-Urteil |
| R6 INFO (bares `ADR-` fängt keine Regel) | **als Grenze getragen** | Kommentar-Satz, Sonde `Siehe ADR- und ADR-12` → 0 Befunde |
| R7 INFO (Ausweg-Fall ohne Vorlagen-Zahn) | unverändert | — |
| R8 INFO (Ruhe-Marker der Roadmap) | unverändert | bekannte Form |

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| N1 | MEDIUM | Die Ableitung wertet **jede** Kombination als „nicht getragen — kein Fall", die mit Exit 2 und `unbekannte Architektur "<arch>"` endet. Eine Kombination, die der Träger trägt und irrig ablehnt, ist von einer nicht getragenen nicht zu unterscheiden: Shim, der `go --arch flat` mit Exit 2 und `unbekannte Architektur "flat"; verfuegbar: hexagonal, hexslice` ablehnt → Stufe Exit 0 mit 5 Kombinationen, `go flat` als *„kein Fall"*. Die feste Liste der Vorgänger-Fassung hätte an dieser Stelle Exit 1 gemeldet. Die Meldung des Trägers nennt in `verfuegbar:` die von der Sprache getragenen Architekturen; die abgelehnte steht in einer echten Ablehnung dort nicht, in der irrigen schon (bei `cpp hexagonal` heute: `verfuegbar: flat, hexslice`). Die Stufe vergleicht das nicht. Der Plan benennt in *„Nicht belegt"* zwei Auslassungs-Fälle und nicht diesen; die Zusage der Stufenüberschrift und der Abdeckungs-Sicht (*„je Sprache und Architektur"*) und die DoD-Formulierung *„vom Träger nicht getragen"* tragen ihn nicht. Ob die Go-Tests des Trägers dieselbe Regression im Träger fangen, ist nicht gemessen; die E2E-Stufe fängt sie nicht. | `AGENTS.md` §3.6 (Zusage auf das einschränken, was der Code hält) · `ADR-0065` Festlegung 6 · Modul 13 (Stilles Grün über einem nicht geprüften Ausschnitt) | `harness/tools/full-smoke.sh:2977` bis `2980` | ja — Shim-Sonde oben | Kein-Fall-Zweig einer Ableitung nicht gegen die eigene Quelle gehalten |
| N2 | INFO | Die Grenze im Plan (*„kein Vertrag hält ihn"*) trifft die **Formatierung** der Meldung. Der **Inhalt** der Listen ist gehalten: `gen_test.go:246` (`cpp,go`), `hexslice_test.go:98` (`flat,hexagonal,hexslice`), `hexagonal_test.go:264` (`flat,hexslice`) prüfen `Available` der Fehlertypen; `Error()` setzt sie mit `strings.Join` in die Meldung (`internal/gen/gen.go`). Ein Namen-Auslassen bei gleichem Format braucht damit eine Änderung an der Formatierung selbst, nicht nur an einer Liste. Der Plan stellt die Lücke gröber dar, als sie ist; kein Mangel. | Maintainability | `internal/gen/gen.go:33-49`, `internal/gen/*_test.go` | ja — `grep -rn 'Available' --include='*_test.go' internal cmd` | Grenze im Plan gröber als gemessen |
| N3 | INFO | Die Zusage der Ableitung (neue Sprache oder Architektur wird ohne Änderung der Stufe gefahren; Wortlaut-Änderung → Exit 1) hat Sonden des Implementers und dieses Laufs, aber keinen Fall in `test/mutations/`; `make mutate` führt für `full-smoke` ein Muster (`full-smoke: FEHLER`), der Plan überträgt die Wiederholung dem Verifier. Kein Widerspruch zum Plan (Liefer-Punkt 3 (c) verlangt Fälle für die Vorlage, nicht für die Ableitung); die Zusage ist bis dahin nicht über die Zeit bewacht. | `AGENTS.md` §3.6 (Feedback: gelistet heißt bewacht) | `harness/tools/full-smoke.sh:2937-3010` | nein — kein Fall führt sie | Zusage der E2E-Ableitung ohne dauerhaften Zahn |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **R3-Umsetzung:** 443 bindet die Position, Meldung gelesen, Gegenprobe (Kommentar behält `link-policy: always`, Test bleibt rot); Zeilenfindung robust (nicht gefundene Zeile → Fehlschlag mit `(Zeile: "")`); Test-Kommentar spricht nur von den acht Fällen 435 bis 442 (Unterfall je Fall) | geprüft, ohne Befund |
| **R3: emulierte Fälle 435, 438, 439** in der Scratchpad-Kopie: je der im `# expect:` genannte Unterfall rot | geprüft, ohne Befund |
| **R2:** Kommentar (a2) wiederhergestellt, Diff der Stufe gegen `0abb97ac` nur Stufe und Verzeichnisvariable | geprüft, ohne Befund |
| **Kommentar-Satz:** jede Aussage gegen die Vorlage im Ziel gemessen; Zustandsform; ASCII; keine Repo-Kennung in einer ins Ziel emittierten Datei; Vorlage sonst unverändert | geprüft, ohne Befund |
| **R4 — Robustheit von `set -e`, Zerlegung, Leerzeichen, Exit 2 aus anderem Grund, Geistersprache, Wortlaut** | geprüft, ohne Befund (Grenzen: N1, N2) |
| **Abdeckungs-Sicht:** `make e2e-abdeckung` erzeugt die committete Datei byte-gleich; nur die Zeilennummern der Stufen 16 bis 21 sind nachgezogen | geprüft, ohne Befund |
| **Wächter-Ehrlichkeit `test/full-smoke-ausgang.bats`:** unverändert, 26 ok; die Änderung an `full-smoke.sh` fügt keine `einordnen`-Zeile hinzu | geprüft, ohne Befund |
| **Reichweite/Abgrenzung:** kein Adaptions-Eintrag, keine Hard-Rule-Änderung, Träger (`cmd/`, `internal/gen/`) unberührt — der Träger-seitige Vertrag ist im Plan ausgeschlossen und nicht geliefert | geprüft, ohne Befund |
| **Rollen-Grenzen (§3.8, §3.10):** Commits nennen ihre Rolle, Zuschnitt je Rolle sauber, kein Closure | geprüft, ohne Befund |
| **Lint-Suppression (§3.2):** 0 Treffer im Diff | geprüft, ohne Befund |
| **§3.11:** dieser Report und die Diff-Texte nennen Slices und Wellen bei der Kennung, keine Pfad-Adresse eines bewegten Artefakts im Text des Plans (Ausschluss-Punkte, §6) | geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Kein-Fall-Zweig einer Ableitung nicht gegen die eigene Quelle gehalten · Grenze im Plan gröber als
gemessen · Zusage der E2E-Ableitung ohne dauerhaften Zahn

## Verdikt

**Kein Merge-Blocker.** R2 und R3 sind behoben (Sonden selbst gefahren), R1 und R6 sind als Grenze getragen (der Kommentar-Satz
stimmt in jeder Aussage gegen das Ziel), R4 ist in seiner Absicht behoben: die Kombinationen folgen dem Träger, und der Wortlaut-Bruch
endet mit Exit 1 statt mit weniger Kombinationen. Die Korrektur hat einen neuen Fehler eingeführt (N1, MEDIUM): der
„kein Fall"-Zweig verschluckt eine getragene Kombination, die der Träger irrig mit derselben Meldung ablehnt — die frühere feste
Liste hätte sie gefangen.

**Übergabe:**

- **N1 → Implementer** (Zweig in `full-smoke.sh`; der Plan ist Sache des Planners, weil seine „Nicht belegt"-Liste den Fall nicht
  führt). Vor dem Merge zu klären; die Grenze im Plan oder die Prüfung ändert sich, ob das im Slice oder als benannte Grenze steht,
  entscheidet der Planner.
- **N2, N3 → Planner** (beim Closure-Urteil, im Register `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`; N3 als
  Kandidat für einen Fall, wenn die Kosten von `make mutate` für `full-smoke` das tragen).
- **R1 → Architect** bleibt offen (Folge-ADR oder Annahme der Grenze), ohne Bezug zum Diff dieser Runde.
- Die **Finding-Klassen** gehen in die Slice-Closure §7. Dieser Report ersetzt keine Verifikation: DoD-Konformität, `make mutate` und
  den Lauf von `make full-smoke` als Ganzes prüft der Verifier.
