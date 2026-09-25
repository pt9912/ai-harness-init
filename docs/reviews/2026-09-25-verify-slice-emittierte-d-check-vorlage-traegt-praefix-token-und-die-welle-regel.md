# Verifier-Bericht: slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel — 2026-09-25

**Rolle:** Verifier (Modul 11) — „Bauen wir es richtig?" gegen Plan und DoD. Nicht die Frage des Validators, nicht die des
Reviewers. **Eingang:** DoD-Bestätigung und Sensor-Belege des Implementers; sie waren Behauptungen, keine Quellen. Code, Tests,
Zähne und Ziele sind selbst gelesen und gefahren.

**Gegenstand:** Slice `slice-emittierte-d-check-vorlage-traegt-praefix-token-und-die-welle-regel` (Kennung, nicht Pfad — der Plan
wandert mit dem Lifecycle). **Norm:** `ADR-0065` (`Accepted`); `LH-FA-01`, `LH-FA-03`, `LH-QA-01`, `LH-QA-02`; `MR-054`,
`MR-055`, `MR-063`, `MR-071`; `AGENTS.md` §3.6, §3.7, §3.9, §3.10, §3.11. **Stand:** Arbeitsbaum = `HEAD` (`06f883e3`), `git status`
sauber vor diesem Bericht. Working-Tree-Hash vor und nach meinen Läufen
`8221ba8bcfc81980c3416ae4caebd846300582b912cefc14a76db0ad8fb9a361` (`bash harness/tools/working-tree-hash.sh`), identisch mit dem
im Auftrag genannten Wert.

**Modell:** Sonnet 5 · **Datum:** 2026-09-25 · **Kein Selbst-Verifizieren:** frischer Kontext, kein Beteiligter an Bau oder Review.

**Nicht gefahren, mit Grund:** `make mutate` (verboten, Auftrag), `make full-smoke` als Ganzes (Auftrag: nur die Stufe; sie ist aus
`harness/tools/full-smoke.sh` Zeile `kf_docs_check` bis zum Aufruf `kennungs_form_im_ziel` herausgelöst und unverändert gefahren),
`make lint`. Kein Host-Go, kein `python3`; alle Sonden in Scratchpad-Kopien (`git archive HEAD`), Docker-Bauten der `build`- und der
`test`-Stage, gepinnter d-check per `make docs-check` in frisch gebootstrappten Zielen (`--network none`).

---

## 1. Verdikt

**Bestätigt** — mit einer benannten Einschränkung zum Mutations-Beleg (§4.7) und den in §7 aufgeführten Grenzen, die keine DoD-Punkte
verletzen. Kein DoD-Punkt ist unbelegt; die Zusagen, die breiter waren als ihr Sensor, sind im Plan bereits als *nicht belegt* / *Grenze*
geschnitten (Liefer-Punkt 3 (a)) und decken sich mit meinen Sonden.

| DoD-Punkt | Verdikt | Deckung (Kurzform) |
|---|---|---|
| LP1 Zell-Messung 22 = 3 · 9 · 1 · 6 · 3, zwei Stände, Grenzen der Messung | bestätigt | eigene Nachmessung §2; die zwei Grenzen stehen im Kommentar-Satz der Vorlage und sind an Sonden reproduziert |
| LP2 Vorlage: Token, Regel, `ids`, Klasse `adr`, Kommentar-Satz wörtlich, Go-Test der Menge | bestätigt | §3, §4.6 |
| LP3 (a) grüner Start je Sprache und Architektur, aus dem Träger abgeleitet | bestätigt | §4.4, §4.5 |
| LP3 (b) fünf rote Gegenbeispiele + Gegenprobe + Ausweg | bestätigt | §4.4 (Meldungen gelesen) |
| LP3 (c) Zähne 435–445 | bestätigt (443/444/445 mit Nachbeleg) | §4.6; 445 nur über Stufen-Sonde, §4.6 |
| `make gates` grün | bestätigt am Ende dieses Laufs | §6 |
| Doku-Update (Nutzerdoku gegen Ist-Stand; `e2e-abdeckung.md` erzeugt) | bestätigt | §5 |
| Review durchgeführt | bestätigt | zwei Reports unter `docs/reviews/` (Runde 1 und 2), keine HIGH-Restbefunde |
| Closure-Pflichten (Notiz, Register, Risiko-Ausgänge, Paarungen) | **nicht Gegenstand** | §7 des Plans ist leer; das schreibt der Planner (`AGENTS.md` §3.10) |

---

## 2. Liefer-Punkt 1 — die Zell-Zählung, nachgemessen

`R=.harness/baseline/v6.9.0/regelwerk; sed -n '/^| Dokument ↓/,/^| \*\*Roadmap/p' $R/grundlagen-referenz-richtung.md | grep -o '❌' | wc -l`
→ **22** (Zeilen: Vertrag 7, Technik 6, Sicht 5, ADR 3, Slice 1; alle übrigen Zeilen 0 — kein Erwartungswert). Zeilenweise Auszählung
der Tabelle bestätigt 7 + 6 + 5 + 3 + 1 = 22.

Zuordnung je Zelle gegen die eingebettete Vorlage (Stand nach der Änderung):

| Gruppe | Zellen | Regel oder Lücke |
|---|---|---|
| Rang innerhalb der Straten | 3 (Vertrag→Technik, Vertrag→Sicht, Technik→Sicht) | `direction: no-downward` auf `spec-straten` |
| Spalten ADR, Slice, Welle der drei Straten-Zeilen | 9 | `{from: spec-straten, to: adr\|slice\|welle}` |
| ADR → Welle | 1 | `{from: adr, to: welle}` (mit Zeilen-Marker als Ausweg) |
| nur `aussen` fängt | 6 (Carveout, Roadmap je Straten-Zeile) | `{from: spec-straten, to: aussen}` |
| Lücke (keine Regel) | 3 (ADR→Carveout, ADR→Roadmap, Slice→Roadmap) | keine |
| **Summe** | **22** | 3 + 9 + 1 + 6 + 3 |

**Vor der Änderung** (`git show 0abb97ac:internal/emit/templates/d-check.yml`: Regeln `spec-straten → adr|slice|adaptionsblock|aussen`,
`adr → slice|welle`; Ziffern-Token; keine Regel `spec-straten → welle`): 3 · 6 · 1 · 6 · **6** — die drei Welle-Zellen der Straten-Zeilen
liegen auf der Klasse `welle` (steht vor `aussen`) und hatten keine Regel. Nach der Änderung 3 · 9 · 1 · 6 · 3. Die Zählung der ADR
stimmt; **kein Widerspruch, kein Befund an den Architect.**

**Verhalten im Ziel, nicht nur Stelle** (`MR-055`: die Tabellenlesung trägt keine Aussage über das Verhalten) — Sonden in einem frisch
gebootstrappten Ziel, gepinnter d-check, Ausgabe gelesen:

| Sonde | Ergebnis |
|---|---|
| `spec/lastenheft.md` verlinkt `spezifikation.md` (Rang) | `matrix-downward … Rang 0 → 1 ist nicht erlaubt` (nur *eine* der drei Rang-Zellen sondiert; die zwei anderen teilen dieselbe `direction`-Zeile) |
| Spec verlinkt Carveout-Datei | `matrix-forbidden … spec-straten → aussen` |
| Spec verlinkt Roadmap-Datei | `matrix-forbidden … spec-straten → aussen` |
| Spec verlinkt Welle-Datei (Link-Form) | `matrix-forbidden … spec-straten → welle` |
| ADR → Carveout-Datei und ADR → Roadmap-Datei, Slice → Roadmap-Datei | `0 Befund(e)` — die drei Lücken sind real |

**Grenze der Messung** (im Plan verlangt): (i) `exclude-sections: [Geschichte]` gilt für alle Klassen zugleich; (ii) das bare `ADR-` ohne
Nummer fängt keine Regel — beide reproduziert, §4.3.

---

## 3. Liefer-Punkt 2 — die Vorlage

`git diff --name-status 0abb97ac..HEAD` ohne Plan- und Review-Dokumente: `docs/user/e2e-abdeckung.md`, `harness/tools/full-smoke.sh`,
`internal/emit/emit_test.go`, `internal/emit/templates/d-check.yml`, Fälle 435–445 — **genau** die Dateien des Plans (§3).

| Position | Befund im Code |
|---|---|
| Token `slice-` auf Klasse `slice`, `welle-` auf Klasse `welle` | `token: 'slice-'` / `token: 'welle-'`; keine Ziffern-Form (`grep -c 'slice-\\d\|welle-\\d'` außerhalb der Klassenzeilen: der Go-Test `keine_ziffern_form` hält es) |
| Regel `{from: spec-straten, to: welle, allow: false}` | steht in `matrix.rules` |
| `ids`-Muster ADR segment-tolerant | `regex: 'ADR-([A-Z]+-)?\d{4}', target: docs/plan/adr/, link-policy: always` |
| Klasse `adr` mit Bereichs-Glob | `paths: ["docs/plan/adr/[0-9]*.md", "docs/plan/adr/[A-Z]*-[0-9]*.md"]`; `README.md` bleibt draußen (`exempt-paths`) |
| Kommentar-Satz direkt hinter dem `exclude-sections`-Absatz | Zeilen 40–46, **wörtlich** wie im Plan (Zeilenumbrüche ausgenommen, Wort für Wort abgeglichen), ASCII (`grep -nP '[^\x00-\x7F]'` trifft in 40–46 nichts), Zustandsform |
| Herkunfts-Kommentar in Zustandsform, keine Kennung dieses Repos | die einzige Repo-Kennung im Kopf (`LH-QA-01`, Zeile 4) ist Bestand von vor diesem Slice, nicht Teil des Diffs |
| Zusagen über das Ziel halten den Zweig des Emitters | Kommentar: „nur an einem freien Pfad geschrieben … behaelt seine Fassung" — Sonde: Ziel mit vorhandener `.d-check.yml` (`# adopter-eigen`) bleibt **byte-gleich** |

Der Kommentar-Satz sagt beide Grenzen als **Grenze** („faengt ihn nur der Reviewer", „faengt keine Regel"), nicht als Zusage — das
Kriterium „bricht, wenn er als Zusage formuliert" trifft nicht. Ausgeschlossenes nicht eingeschlichen: keine Regel mit
`adaptionsblock` als Quelle über die des Bestands hinaus (`spec-straten → adaptionsblock` steht schon in `0abb97ac`), keine
Marker-Neutralisierung, keine Änderung an `.d-check.yml` des Repos, `internal/emit/templates/enforce/`, `harness/conventions.md`,
`AGENTS.md`.

`git diff 34f4b737..HEAD -- internal/emit/templates/d-check.yml` (seit Review Runde 1): **allein die +7 Kommentarzeilen** (Satz).
Die Positionen sind seit Runde 1 unverändert.

---

## 4. Selbst gefahrene Sonden und Rot-Belege

### 4.3 Kommentar-Satz-Sonden im frisch gebootstrappten Ziel (Risiko „zwei benannte Blindflecke")

| Sonde | Ergebnis |
|---|---|
| `## Geschichte` mit `welle-x` und `slice-x` in `spec/spezifikation.md` | `d-check: 20 Datei(en) geprüft, 0 Befund(e)` — die Grenze ist real, der Satz sagt sie |
| dieselbe Zeile unter `## 7. Historie` | `spec/spezifikation.md:110 slice- matrix-forbidden … spec-straten → slice` und `welle-` — 2 Befunde |
| `Siehe ADR- und ADR-12` | `0 Befund(e)` — bares `ADR-` und zweistelliges `ADR-12` fangen nichts (Grenze real) |
| blankes `ADR-0019` im Fließtext der Spec | `id-unlinked  Kennung ohne Link auf ihre Definition` |
| Link auf eine ADR-Datei aus der Spec | `matrix-forbidden … spec-straten → adr` |
| Marker `<!-- d-check:status-provenance -->` hinter einem Welle-Namen in der Spec | `0 Befund(e)` — der Marker wirkt im Spec-Stratum mechanisch (Umgehen; nur der Reviewer fängt es, wie der Kommentar sagt) |

Damit trägt der Ausgang *entfallen* für das Risiko „zwei benannte Blindflecke" (§6 des Plans): der Kommentar-Satz steht in der
Vorlage, in vorgegebener Fassung, und die Sonde `## Geschichte` → kein Befund ist im Verifier-Lauf reproduziert.

### 4.4 Stufe `kennungs_form_im_ziel`, ungekürzt gegen den gebauten Träger (`.harness/state/bin/ai-harness-init`; sein `.d-check.yml` ist byte-gleich zur Vorlage)

Exit 0, ~11 s. Ausgabe (gekürzt auf die tragenden Zeilen):

```
gruener Start der Kennungs-Form (sprachlos | cpp flat | cpp hexslice | go flat | go hexagonal | go hexslice): docs-check '0 Befund(e)', Spec-Dateien ohne slice-/welle-.
Kennungs-Form (cpp hexagonal): vom Traeger nicht getragen (Exit 2, unbekannte Architektur, nicht in der Liste 'verfuegbar: ') — kein Fall.
Kennungs-Form: 6 Kombinationen gefahren
```

**Sechs Kombinationen, `cpp hexagonal` als nicht getragen** — wie erwartet.

Fünf rote Gegenbeispiele, Meldung je Regel gelesen (nicht irgendein Befund), je Gegenprobe (Position geschwächt → dasselbe Gegenbeispiel
grün) und der Ausweg:

| Gegenbeispiel | gelesene Meldung | Gegenprobe |
|---|---|---|
| Slice-Name in einer ADR | `0001-probe.md:7 slice- matrix-forbidden Token-Referenz adr → slice (slice-)` | Token in Ziffern-Form → grün |
| Welle-Name in einer ADR | `… adr → welle (welle-)` | Token in Ziffern-Form → grün |
| Welle-Name in einer Spec-Datei | `lastenheft.md:7 welle- matrix-forbidden … spec-straten → welle (welle-)` | Regel gestrichen → grün |
| `ADR-IDX-0004` blank | `lastenheft.md:7 ADR-IDX-0004 id-unlinked` | Muster ohne Segment → grün |
| Datei `IDX-0004-probe.md` unter `docs/plan/adr/` | `IDX-0004-probe.md:7 slice- matrix-forbidden … adr → slice` | Glob entfernt → grün |
| **Ausweg:** dieselbe ADR-Zeile mit Marker | `0 Befund(e)` für Slice- und Welle-Name zugleich | — |

### 4.5 R4/N1-Sonden der Ableitung (Scratchpad-Träger und Shims; Stufe unverändert)

| Sonde | Ergebnis |
|---|---|
| Träger aus einer Kopie gebaut, `"cpp": {archFlat, archHexslice, archHexagonal}` in `langArchs()` | Exit 0, **7 Kombinationen**, darunter `cpp hexagonal` grün — **ohne Änderung an `full-smoke.sh`** |
| Shim, der `verfuegbar: ` zu `verfuegbar sind: ` ändert | Exit 1, `FEHLER — Kennungs-Form: der Traeger nennt in seiner Fehlermeldung keine Sprachen oder keine Architekturen (Muster 'verfuegbar: ')` |
| Shim: `go --arch flat` → Exit 2, `unbekannte Architektur "flat"; verfuegbar: flat, hexagonal, hexslice` (N1) | Exit 1, `FEHLER — Kennungs-Form (go flat): der Traeger lehnt die Kombination … ab, obwohl seine Meldung die Architektur nicht als nicht getragen ausweist` |
| dieselbe Ablehnung mit leerer Liste | Exit 1 (gleiche Meldung) |
| Shim: Exit 2 mit fremdem Grund (`boom`) für `go hexagonal` | Exit 1, `gruener Start … (go hexagonal): der Bootstrap ist NICHT Exit 0 (Exit 2)` |
| Shim: dieselbe Ablehnung von `go flat`, Liste **ohne** `flat` (`hexagonal, hexslice`) | **Exit 0**, 5 Kombinationen, `go flat` als „nicht getragen — kein Fall" |

Die letzte Zeile **bestätigt die im Plan benannte Grenze:** eine in sich stimmige Fehlmeldung ohne die Architektur in der Liste bleibt
grün, die Kombination fehlt dann im Lauf. Sie ist aus der Meldung allein von einer echten Ablehnung nicht zu unterscheiden. Das Format
der Meldung (`verfuegbar: `) hält kein Test — der Plan sagt es (`Format ohne Halter`); Fall 445 hält nur den Marker der
Sprachliste (Rot bei Umbenennung), nicht eine in sich stimmige Fehlmeldung.

### 4.6 Go-Test und Zähne 435–445, in Scratchpad-Kopien emuliert

Verfahren: `git archive HEAD` → Kopie; Mutations-Skript aus `test/mutations/` unverändert angewandt (die Anker trafen, sichtbar an der
Meldung); Test-Stage des Dockerfiles wie in `make test-go` (`--no-cache-filter test --target test`); Ausgabe gelesen. Unmutierte
Kopie: **alle Pakete `ok`** (Kontrolle).

| Fall | rot mit gelesener Meldung |
|---|---|
| 435 | `TestDCheckConfig_KennungsForm` `token_slice`: `die Klasse slice traegt nicht das Praefix-Token slice-: "… token: 'slice-\\d{3}'}"` |
| 436 | `token_welle`: `… token: 'welle-\\d{2}'` |
| 437 | `regel_spec_straten_welle`: `die matrix-Regel {from: spec-straten, to: welle, allow: false} fehlt` |
| 438 | `ids_muster_adr`: `["- {regex: 'ADR-\\d{4}', … link-policy: always}"]` |
| 439 | `adr_klasse_bereichs_praefix`: Klasse trägt nur `[0-9]*.md` |
| 440 | `keine_ziffern_form`: Ziffern-Form im Kommentar (`… Baseline-Vorlage slice-\\d{3}`) |
| 441 | `token_menge`: `4 Klassen tragen ein token: statt drei` |
| 442 | `regel_menge`: `die matrix fuehrt eine Regel ausserhalb der Liste: - {from: adr, to: aussen, allow: false}` |
| 443 | `TestDCheckConfig_EntschiedeneModulListe`: `das ADR-Muster von ids traegt nicht link-policy: always (Zeile: "… link-policy: never}")` |

**Gegenproben (grün heißt „bindet"):**

- **435:** die Zusicherung in `token_slice` auf `HasSuffix(…, "}")` geschwächt, Mutation 435 angewandt → Test **grün**. Die Zusicherung
  ist der Träger des Rots.
- **443:** die Zusicherung von der Zeile des `ids`-ADR-Musters (`idsADR`) auf die **ganze Datei** (`yml`) umgestellt, Mutation 443
  angewandt → Test **grün**, weil der Herkunfts-Kommentar `link-policy: always` ebenfalls nennt. Das ist die im Plan verlangte Gegenprobe:
  „nur im Kommentar" hält den Test nicht grün, und die Zeile allein ist es, die den Test rot färbt. (Ein erster Schwächungsversuch — den
  `if`-Block löschen — brach die Übersetzung `declared and not used: idsADR`, kein Beleg; der zweite ist der oben genannte.)

**Fall 444** (Traeger-Mutation `Available: append(archsForLang(lang), arch)`, Kopie, Träger gebaut, Stufe gegen ihn gefahren): Exit 1,
`FEHLER — Kennungs-Form (cpp hexagonal): der Traeger lehnt die Kombination mit Exit 2 und 'unbekannte Architektur' ab … Ausgabe: Fehler:
unbekannte Architektur "hexagonal"; verfuegbar: flat, hexslice, hexagonal`. Der `# expect:`-Text des Falls ist ein wörtlicher Ausschnitt
dieser Zeile. Gegenprobe ohne Mutation: Stufe grün (§4.4). Der Anker trifft eine Stelle (`grep -c 'Available: archsForLang(lang)}'
internal/gen/gen.go` → **1**).

**Fall 445** (`; verfuegbar sind: %s`, Kopie, Träger gebaut, Stufe gegen ihn gefahren): Exit 1, `FEHLER — Kennungs-Form: der Traeger nennt in
seiner Fehlermeldung keine Sprachen oder keine Architekturen (Muster 'verfuegbar: ') … Sprachen: [Fehler: unbekannte Sprache
"kf-unbekannt"; verfuegbar sind: cpp, go]`. Anker trifft eine Stelle (`grep -c '; verfuegbar: %s", e.Lang,' internal/gen/gen.go` → **1**).

**Bewertung 445:** Er ist im Plan als „über die Stufen-Sonde belegt" ausgewiesen, nicht über einen vollständigen `full-smoke`-Lauf. Meine
Sonde ist dieselbe Ebene. Dass ein vollständiger Lauf aus demselben Grund rot würde und nicht durch eine frühere Stufe, folgt aus dem
Text von `full-smoke.sh`: keine Stufe vor `kennungs_form_im_ziel` liest den Wortlaut von `unbekannte Sprache` oder `verfuegbar` (die einzige
frühere Zeile zu `unbekannte Architektur` prüft nur den Ausgang, Zeile 2427). Im `make mutate`-Log steht 445 zudem als `ok` (§4.7) —
das ist der Lauf-Beleg. Die Stufen-Sonde trägt den Fall; der Vollbeleg hängt an §4.7.

**Weitere Fälle:** 436, 438, 440, 442 (oben, rot aus dem behaupteten Grund) — für 437, 439, 441 gilt dasselbe. Die Fälle 440–442 stehen
nicht in der Aufzählung von Liefer-Punkt 3 (c), tragen aber die Zusagen aus Liefer-Punkt 2 („die Menge der Token und der Regeln, die
Ziffern-Form nirgends") — **gebaut, im Plan als Zähne der LP2-Zusage geführt, kein Scope-Zuwachs.** Der Go-Test führt sie in seinem
Doc-Kommentar mit Datei-Namen.

### 4.7 `make mutate`-Beleg — ehrlich gelesen

Ich habe `make mutate` nicht gestartet. Nachgeprüft:

- **(a) Vereinigung neu abgeleitet:** `grep -E '^mutate: ok +' <log> | sed -E 's/^mutate: ok +([0-9.]+ s +)?//' | awk '{print $1}' | sort -u`
  je Log (Kopf-Zeitangabe `9.82 s` bei den `full-smoke`-Fällen abgefangen): Lauf 1 **425**, Lauf 2 **432**, Vereinigung **433**;
  `ls test/mutations/*.sh | wc -l` → **433**; `comm` in beide Richtungen: **kein** fehlender, **kein** überzähliger Fall. Die Fälle
  435–445 stehen alle als `ok` (Lauf 2, Fall 441 auch in Lauf 1).
- **(b) Ursache der neun Befunde:** Lauf 1: acht Befunde (105, 236–242), in acht Blöcken dieselbe Zeile
  `ERROR: failed to build: failed to solve: DeadlineExceeded: failed to resolve source metadata for docker.io/docker/dockerfile:1.7 …
  net/http: timeout` (8 Timeout-Zeilen bei 8 Befunden) — **Registry-Timeout beim Bau, das Urteil des Falls wurde nie erreicht**. Lauf 2:
  ein Befund (212) mit `docker: Error response from daemon: container is marked for removal and cannot be started` (Docker-Daemon,
  Test-Stage `bats`, Exit 125). Beide Ursachen liegen außerhalb des Codes; keine ist ein falscher Grund in einem Fall. Jeder der neun
  Fälle ist im jeweils anderen Lauf `ok`.
- **(c) Baum-Hash unverändert:** `8221ba8b…9a361` heute, gleich dem im Auftrag genannten Wert vor und nach beiden Läufen; `git status`
  sauber; letzter Commit vor den Läufen 06:12 (Planner, nur Plan), Logs 06:54 und 07:35. (Den Hash *zwischen* den Läufen kann ich
  nicht nachmessen, nur den heutigen; die Lauf-Zeitstempel liegen nach dem letzten Commit.)
- **(d) Hängen die neun an den geänderten Dateien?** `git diff --stat 0abb97ac..HEAD -- internal cmd Makefile` → **zwei** Dateien:
  `internal/emit/emit_test.go` und `internal/emit/templates/d-check.yml`. Die Fälle 105 (Hexagonal-Glob des Arch-Gates), 236–242
  (`archive-welle`), 212 (`gate-nachweis`) mutieren nichts davon und laufen mit dem Grund `docker build`/`docker run`, nicht mit dem
  Wächter-Inhalt; sie sind im anderen Lauf über demselben Baum `ok`. **Die Vereinigung ist damit als Beleg tragfähig.**
- **Der dritte Lauf** (`mutate-slice2c.log`) ist mit `ABGEBROCHEN, keine vollstaendige Messung` beschriftet (62 von 433 Ergebnissen,
  drei Befunde nur der Vollständigkeits-/Zeitbilanz) und trägt nichts — weder Beleg noch Gegenbeleg.

**Ehrliche Einordnung:** Beleg aus **zwei Läufen**, kein einzelner grüner Lauf. Ein einzelner grüner `make mutate` würde zusätzlich
zeigen, was die Vereinigung nicht kann: dass alle 433 Fälle **in einem** Lauf hintereinander rot werden (keine Wechselwirkung zwischen
parallelen Workern, die im Einzellauf nur zufällig zuträfe), er schriebe den Beleg-Slot der Mutations-Bilanz (ADR-0035, wie im Auftrag benannt), den die Vereinigung nicht schreibt, und er
lieferte die vollständige Zeit-Bilanz (`zeit-bilanz` fordert 433 Dauern). Alle drei sind Eigenschaften des **Laufs**, nicht der
Zähne. Für die Frage dieses Slice (bindet jeder Zahn aus dem richtigen Grund?) reicht die Vereinigung; ob der Planner den
Beleg-Slot für die Closure braucht, entscheidet er (Übergabe, §8).

---

## 5. Abgrenzung und DoD-Kopplungen

- **Größe/Schichten:** drei Liefer-Punkte, zwei Schichten (Emission: `internal/emit/`; Test/E2E: `full-smoke.sh`, `test/mutations/`,
  erzeugte `docs/user/e2e-abdeckung.md`). Die Fälle 444/445 mutieren `internal/gen/gen.go` **nur in der Mutationskopie**; der Träger
  bleibt im Bestand unberührt (`git diff 0abb97ac..HEAD -- internal/gen cmd` leer).
- **`make e2e-abdeckung`:** `unverändert — docs/user/e2e-abdeckung.md (21 Stufen, 21 Deklarationen)`, `git status` danach sauber. Die
  Stufe trägt Kopfzeile und Deklaration (`e2e_abdeckung "LH-FA-01 LH-FA-03 LH-QA-01" …`).
- **`test/full-smoke-ausgang.bats`:** in `git diff 0abb97ac..HEAD --name-status` nicht enthalten — nicht gelockert.
- **Nutzerdoku:** `grep -rn 'slice-\\d\|welle-\\d' docs/user README.md | wc -l` → 0; das Handbuch nennt `.d-check.yml` nur als Baum-Zeile
  (`benutzerhandbuch.md:456`) — keine Ist-Änderung, kein Nachzug nötig.
- **Keine Hard-Rule-Änderung, kein Adaptions-Eintrag, keine Änderung an der eigenen `.d-check.yml`:** `git diff --name-status` zeigt
  keine der Dateien (`AGENTS.md`, `harness/conventions*`, `.d-check.yml`).
- **`skip-if-present` der Vorlage:** Verhalten bestätigt (§3), aber **ohne eigenen Mutations-Fall** für die Datei `.d-check.yml` — nur die
  generischen Fälle 50/51 halten den Mechanismus. Die Zusage des Kommentars ist auf den Zweig des Emitters gebunden (ADR-0007
  Festlegung 3) und nicht breiter; das ist kein DoD-Bruch.

---

## 6. `make gates`

Einmal am Ende dieses Laufs über dem Baum inklusive dieses Berichts; Ausgang steht in der Übergabe-Meldung an den Aufrufer
(`make record-gates` stempelt den Baum-Hash; der Stop-Hook liest ihn).

---

## 7. Bekannte offene Punkte — bewertet, nicht geschlossen

| Punkt | Berührt die DoD? | Bewertung |
|---|---|---|
| **R1** `exclude-sections` global | nein | Grenze, im Kommentar-Satz benannt; Sonde `## Geschichte` → 0 Befunde reproduziert. Die je Klasse setzbare Ausnahme ist eine Anforderung an ein fremdes Repo und Handlung des Auftraggebers. |
| **R6** bares `ADR-` | nein | Grenze im Kommentar; Sonde 0 Befunde. `MR-054` lässt die Aufnahme als Muster nicht zu. |
| Marker im Spec-Stratum als Umgehen | nein | mechanisch wirksam (Sonde 0 Befunde), im Kommentar als „Umgehen, das nur der Reviewer faengt" benannt; kein Sensor fängt es. |
| `skip-if-present` ohne eigenen Fall für die Datei | nein (die Zusage ist auf den Zweig gebunden) | Verhalten bestätigt; Wächter der Datei-Klasse ist generisch (50/51). Kandidat für das Beobachtungs-Register, nicht für diesen Slice. |
| Meldungs-Wortlaut ohne Halter | nein (Plan schneidet es als Grenze) | Sonde bestätigt: eine in sich stimmige Fehlmeldung des Trägers bleibt grün, die Kombination fehlt im Lauf. Ein Träger-seitiger Vertrag ist Entscheidung des Architect. |
| Format der Liste von `go` ohne Halter | nein | dieselbe Grenze; die Listeninhalte von Sprachen/Union/`cpp` halten Go-Tests, die von `go` nicht. |
| Mutations-Beleg aus zwei Läufen | **berührt die Closure, nicht die Zähne** | §4.7. |
| Zell-Messung nur an zwei Stellen (`MR-055`) | nein | Verhalten an je einer Sonde je Zellgruppe nachgemessen (§2); nicht jede der 22 Zellen einzeln. |

---

## 8. Plan-vs-Code-Diff

**Geplant und gebaut:** alle Positionen aus LP2, die Stufe mit Kopfzeile und Deklaration, Fälle 435–439 und 443 aus LP3 (c), Fälle 444/445 als
Zähne der zwei Zusagen der Stufe, erzeugte Abdeckungs-Sicht, Go-Test der Menge.

**Gebaut, nicht (wörtlich) aufgezählt:** Fälle 440–442 (Zähne der LP2-Zusage „Menge, Ziffern-Form nirgends") — durch den Doc-Kommentar des
Go-Tests und §3.6 gedeckt; die Aufzählung in LP3 (c) nennt sie nicht. **Empfehlung:** die Aufzählung im Plan enthält sie ohnehin über „Fälle
435 bis 442" im Go-Test-Kommentar; der Planner kann sie in §7 bei der Closure erwähnen. Kein Rückfall in den Plan.

**Geplant, nicht gebaut:** nichts. Die Ausschlüsse (Commit-Prüfung, Adaptions-Block-Regeln 2(b), Marker-Neutralisierung, eigene
`.d-check.yml`, Nachzug bestehender Ziele, Träger-Vertrag, Regelwerk) sind eingehalten (`git diff --name-status`).

## 9. Übergaben an den Planner

1. **Verdikt bestätigt.** Closure (§7, Risiko-Ausgänge §6, Beobachtungs-Register, Paarungen, `git mv`) ist Planner-Arbeit im eigenen
   Commit (`AGENTS.md` §3.10).
2. **Risiko-Ausgänge, soweit meine Belege reichen:** „zwei benannte Blindflecke" → *entfallen* möglich (Satz steht, Sonde
   reproduziert); „Kombinationen weichen ab" und „Wortlaut ohne Halter" → die Sonden aus §4.5; das zweite bleibt als Grenze
   *weiter offen* bzw. *eingetreten* (Träger-Vertrag: Entscheidung des Architect) — Urteil der Closure. „Ein Zahn deckt einen anderen
   Zweig" → Gegenproben 435 und 443 zeigen die Bindung; für alle Fälle 435–445 keine Klasse dieser Art gefunden.
3. **Mutations-Beleg:** Vereinigung zweier Läufe (§4.7). Ob die Closure den einzelnen grünen Lauf (Beleg-Slot) verlangt, entscheidet der
   Planner; wird er verlangt, ist das ein neuer Lauf über einem Baum, der diesen Bericht bereits enthält.
4. **Beobachtungs-Register:** möglicher Eintrag *„skip-if-present einer Vorlage ohne eigenen Fall für die Datei"* (nur generische Fälle
   50/51) — Urteil der Closure; ein dritter Treffer der drei in §8 des Plans genannten Klassen (Negation, weite Assertion, Zusage ohne
   Fall) ist in meinen Läufen **nicht** aufgetreten (die zwei Gegenproben zeigten die Bindung; ein Schwächungsversuch scheiterte an der
   Übersetzung, kein Wächter-Mangel).
5. **Nachzug der Aufzählung** in LP3 (c) um 440–442 nur, falls der Planner sie dort führen will — kein Muss.

## 10. Selbstauskunft

Grenzen dieses Berichts: Die 22 Zellen sind an je einer Sonde je Gruppe nachgemessen, nicht einzeln; der Hash zwischen den Mutate-Läufen ist
nicht nachmessbar; Fall 445 nur über die Stufe (nicht über `make full-smoke` als Ganzes); der Zustand nach Lauf ist ein Scratchpad-Bestand
(`v/`, `z1`, `z2`), außerhalb des Repos.
