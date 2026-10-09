# Welle-Closure welle-kotlin-skelett — Audit-Vorlage und Steering-Loop-Übergabe (Schritte 2, 3a)

- **Rolle:** Planner · **an:** Architect (A, B), Auftraggeber (C) · **Bezug:**
  [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), Baseline-Regelwerk
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur und `modul-08-agentenrollen.md` §Rollen-Sequenz für
  eine Welle (`v6.17.0`)
- **Gemessen auf:** `3c8d76d9`; Fenster = seit der letzten Welle-Closure `d82ac7be`
  (Self-Close `welle-handbuch-zeigt-den-bestand`)
- **Schritt 1:** erledigt — Verifier-Beleg `2026-10-09-welle-kotlin-skelett-trigger.md`.
- **Die Closure hält hier an.** Schritte 3b, 3c, 4, 5, 6 laufen nach dem Verdikt zu A und B.

## Schritt 2 — vom Planner erledigt

- **Carveouts:** `CO-001` *Auflösung fällig*, Folge-Slices `slice-113` (`open/`) und `slice-141`
  (`next/`); `CO-002` permanent — beide unverändert, keine weiteren (`ls docs/plan/carveouts/`).
- **Bootstrap-aware Gates:** keines (`grep -n 'bootstrap-aware' Makefile *.mk` → leer). Neu im Fenster
  ist `freshness-kotlin`, ein Werkzeug, *„NICHT in gates"*.

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig (Architect)

`git diff --name-status d82ac7be HEAD -- docs/plan/adr harness/conventions harness/conventions.md AGENTS.md`
→ ADR-0062, ADR-0063, ADR-0088 geändert (je Accept), ADR-0089 und `MR-089` neu. `AGENTS.md`
unverändert; ihr einziger Auflösungs-Trigger lautet *permanent* (`grep -n 'Auflösungs-Trigger' AGENTS.md`).

| ADR / MR | Trigger | Planner-Lesart |
|---|---|---|
| [ADR-0088](../plan/adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) | 1 Sonde färbt nicht rot · 2 detekt/ktlint nicht grün · 3 Adopter verlangt `hexagonal`/Multi-Modul/KMP | **nicht eingetreten** — Gegenbeispiele rot (Trigger-Beleg, Stufen hexslice und Root); detekt 1.23.8 mit Kotlin 2.4.21 grün und rot (`slice-kotlin-flaches-skelett` §7); kein Adopter-Verlangen |
| [ADR-0089](../plan/adr/0089-span-dateien-sind-nur-fuer-den-eigentuemer-lesbar.md) | Lastenheft-Änderung · Adopter-Meldung zu `0600` | nicht eingetreten |
| [ADR-0063](../plan/adr/0063-das-werkzeug-sagt-seine-fassung.md) | 1 Bau ohne Injektion still | nicht eingetreten — `.harness/state/bin/ai-harness-init --version` meldet *„keine Fassung injiziert …"* laut |
| [`MR-089`](../../harness/conventions.md#mr-089) | ein Sensor misst die Laufzeit je Variante | nicht eingetreten (im Fenster angelegt) |
| [ADR-0062](../plan/adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md) | **2** *„die Klasse tritt ein weiteres Mal auf, obwohl der Träger steht"* | **eingetreten** — Accept `6309b1a9` (05:06), Fund-Commit `9d1b0837` (05:55, `spec/architecture.md` §Layout je Sprache mit Sätzen über `go`/`cpp`), Beleg `evidence/slice-kotlin-hexslice-mit-arch-gate.md`; `git merge-base --is-ancestor 6309b1a9 9d1b0837` → wahr |

**Verlangt zu ADR-0062 Trigger 2:** trägt der Ort? Der Trigger sagt *„die Trägerwahl ist der Befund"*.
Das Verdikt `2026-10-09-spec-architecture-architect-verdikt` hat den Fall an `slice-151` (`next/`)
verwiesen, der die schreibende Rolle für die Spec-Straten benennt — dann griffe Trigger 1 (eine Quelle
benennt die Rolle) und der Fall fiele aus dem Residuum. Verdikt: bestätigt mit `slice-151` als
Träger · Folge-ADR mit `Supersedes` · anderer Ausgang.

## B — Lese-Schritt 3a

`make register-ausgang` → `236 Eintraege, 67 ueber der Schwelle, 0 Befund(e)`. Im Fenster angelegt
(`git diff --name-status --diff-filter=A d82ac7be HEAD -- docs/plan/planning/observations`): 15 Belege
auf 14 Einträge, ein Eintrag neu. **Kein Eintrag mit ≥ 3 Belegen ohne Ausgang.**

**Lesart der 4×-Regel** (`modul-06` §Wellen-Closure-Prozedur, Schritt 3: *„Erreicht dieselbe
Fehlerklasse trotzdem ein viertes Mal die Schwelle …"*): wie im Verdikt zu
`welle-handbuch-zeigt-den-bestand` (*„2 von 3"* seit `MR-071`) zählt die Schwelle **erneut**, wenn
nach der Verkörperung drei weitere Vorgänge belegt sind. Liegt für die Klasse schon eine Antwort vor,
ist nach [ADR-0076](../plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md)
Festlegung 7 *„ein neuer Grund oder eine neue Möglichkeit"* der Trigger. Gezählt ist je Eintrag
`evidence/*.md`, deren Anlage-Commit nach dem Commit liegt, der den Stand auf *verkörpert* setzte
(`git merge-base --is-ancestor`). Die verkörpernde Slice selbst zählt nicht.

| Eintrag | Belege | Stand | nach Verkörperung | 4×-Regel |
|---|---|---|---|---|
| `kosten-einer-emittierten-pruefung-im-ziel-ungemessen` | 4 | verkörpert `MR-089` (im Fenster) | 1 (`slice-kotlin-root-bootstrap`) | **greift nicht** |
| `plan-abweichung-landet-im-commit-bericht-statt-im-plan` | 7 | verkörpert (Baseline `modul-09`), Antwort *kein Sensor möglich* | 3 — der dritte ist `slice-kotlin-freshness` | **greift jetzt erstmals**, siehe B-1 |
| `mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere` | 6 | verkörpert (Reviewer-Skill), Antwort *kein Sensor möglich* | 3 — der dritte ist `slice-kotlin-root-bootstrap` | **greift jetzt erstmals**, siehe B-2 |
| `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` | 13 | verkörpert `AGENTS.md` §3.6; Adress-Hälfte mit Sensor, Bedingungs-Hälfte offen beim Auftraggeber | 9 | greift (schon vor dieser Welle), siehe B-3 |
| `fremdes-rollen-artefakt-im-implementations-kontext` | 10 | verkörpert `AGENTS.md` §3.10, *„Der Wächter fehlt"* | 6 | greift (schon vor dieser Welle), siehe B-4 |
| `eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet` | 13 | verkörpert ADR-0062 (Accept im Fenster) | 1 | greift nicht — dafür ADR-0062 Trigger 2 (A) |
| `waechter-misst-die-fixture-statt-der-realen-quelle` | 7 | geplant `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` | — | geplanter Träger, siehe B-5 |
| `zusage-nennt-sensor-der-form-nicht-sieht` | 21 | geplant `slice-181` | — | geplanter Träger fängt es (Testkopf nennt eine Stufe, die die Variante nicht fährt) |
| `stellen-messung-als-eigenschaft-ausgegeben` | 8 | geplant `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` | — | geplanter Träger fängt es (Seiten-Grenze der Tag-Liste) |

Unter der Schwelle, offen, mit Beleg im Fenster: `spec-zeile-enger-als-der-code-den-sie-beschreibt` (2),
`strukturtest-sieht-den-import-alias-nicht` (2), `teilzeichenketten-suche-bindet-einen-pfad-nicht-an-seine-grenze`
(2), `zahl-in-commit-message-ohne-kommando` (2), neu
`emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache` (1).

**Verlangt je Zeile B-1 bis B-5:** *Sensor X* · *kein Sensor möglich, weil …* · *geplanter Träger fängt es*.

- **B-1 `plan-abweichung-…`:** die Begründung in `state.md` lautet *„ein Commit trägt keine
  Slice-Kennung"*. Für die Namens-Form trifft das nicht mehr zu: `db31ad13` (der Fund) trägt
  `slice-kotlin-freshness` in der Message (`git log -1 --format=%s db31ad13`). Planner-Lesart: neue
  Möglichkeit — ein Sensor, der die Dateien eines Commits mit Slice-Kennung gegen §3 des Plans hält, ist
  baubar, für den Nummern-Altbestand nicht. Verdikt: Sensor benennen oder begründen.
- **B-2 `mutations-fall-…`:** die Begründung schließt eine **Exklusivitäts**-Prüfung aus (legitimes
  Mitfärben über eine gemeinsame Senke). Der Kotlin-Fund ist die Gegenrichtung: der genannte Test färbt
  gar nicht, andere tragen den Fall (`t.Skip` im genannten Test, 626/627 bleiben rot). Planner-Lesart:
  die Prüfung *„der genannte Test steht unter den roten"* ist von der Begründung nicht gedeckt und
  scheint möglich. Verdikt: Sensor oder Begründung für diese Hälfte.
- **B-3 `emittierte-zusage-…`:** der Kotlin-Beleg ist die Kurzbeschreibung einer `full-smoke`-Stufe,
  die mehr zusagt, als der Lauf misst — genau der Fall, für den §3.6 *„Ein Wächter existiert nicht"*
  sagt. *Existiert nicht* ist keine Begründung, dass keiner möglich ist. Verdikt für diese Unterklasse.
- **B-4 `fremdes-rollen-…`:** `state.md` nennt die Grenze (*kein Gate liest Commits*), eine Antwort auf
  die 4×-Frage steht in keinem Verdikt der vorigen Wellen-Closures
  (`grep -l fremdes-rollen-artefakt docs/reviews/*verdikt* docs/reviews/*audit-vorlage*` → leer).
  Der Commit-Kennungs-Punkt aus B-1 gilt auch hier. Verdikt nötig.
- **B-5 `waechter-misst-die-fixture-…`:** der Kotlin-Beleg baut die Import-Auflösung eines
  **Fremd-Werkzeugs** (a-check) nach, keinen doppelt geführten Wert dieses Repos. Fängt der geplante
  Kopplungs-Sensor das, oder braucht die Unterklasse einen eigenen Ausgang?

## Paarungen der Welle-Slices (Planner, vorab)

Die vier Slice-Closures haben (a)/(b)/(c) nach ihrem Move gefahren (je §7 *„Paarungen geprüft am …"*).
Die Welle-Closure fährt sie in 3c erneut, samt der zweiten Hälfte von (c) über das ganze Register.

## C — Backlog-Lese-Schritt (Vorschläge, Entscheidung beim Auftraggeber)

`open/` 58, `next/` 6 (`ls … | wc -l`). Im Fenster: `slice-151` `open/` → `next/`;
`slice-mutations-anker-greift-in-den-gates` und `slice-ziel-traegt-keine-kennung-dieses-repos` neu in
`next/`. Gruppiert ist **nach Titel und Register-Bezug**; die Inhalte der nicht berührten Slices sind
nicht gelesen.

| Gruppe / Slice | Vorschlag | Grund |
|---|---|---|
| `slice-151-spec-straten-haben-eine-schreibende-rolle` | bestätigt, Priorität hoch | Träger für ADR-0062 Trigger 2 (A) und für `spec-zeile-enger-…` (`ARC-009`-Drift, an slice-151 übergeben) |
| `slice-181`, `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`, `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` | bestätigt | je ein neuer Beleg im Fenster; B-5 kann den Geltungsbereich des dritten ändern |
| Mutations-Gruppe: `slice-069`, `slice-119`, `slice-sync-waechter-tragen-mutations-faelle`, `slice-pin-kopplung-bekommt-ihren-mutations-fall`, `slice-der-mutations-lauf-ist-begrenzbar`, `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar` | prüfen, Konsolidierungs-Kandidat | dieselbe Sensor-Klasse (`make mutate`/`test/mutations/`); ein Sensor aus B-2 käme hinzu |
| Spezifikations-Gruppe: sieben `slice-festlegungen-*-ziehen-in-die-spezifikation` und `slice-hook-festlegungen-ziehen-in-die-spezifikation` | prüfen, ob `slice-hook-…` und `slice-festlegungen-waechter-und-hooks-…` denselben Gegenstand tragen | Titel überlappen; die übrigen sind eine Reihe je Werkzeug-Familie, bestätigt |
| `slice-113` / `slice-141` | bestätigt | `CO-001` *Auflösung fällig* |
| `emittiertes-gate-am-gemischten-root-…` (Register, 1) | Auftraggeber: Folge-Slice nach ADR-0076 Festlegung 7 Auslöser (2)? | `test-kotlin` am gemischten Root baut das Go-`Dockerfile`; Review MEDIUM-2, im Slice nicht behoben — ein emittiertes Gate prüft dort etwas anderes, als seine Hilfe sagt |

Nichts stillgelegt, nichts abgelehnt.

## D — Archivierung, Schritt 4

Kein `docs/plan/planning/done/*/archiv.zip` (`ls … 2>/dev/null | wc -l` → 0) — `[untergrenze]` sperrt
fail-closed wie bei den vier Vorgänger-Wellen; die Welle schließt ohne Schritt 4, als Feststellung in der
Ergebnisnotiz.

**Die Vorschau hängt nicht, sie rechnet.** `timeout 400 .harness/state/bin/ai-harness-init archive-welle
--vorschau welle-kotlin-skelett`: nach 75 s ohne Ausgabe ein Prozess, ~98 % CPU, kein Kind-Prozess
(`ps`, `pgrep -P`); `SIGQUIT` gibt den Stack: `archive.Vorschau` (`vorschau.go:47`) →
`VerweisFund` (`refs.go:145`) → `fundIn` (`refs.go:176`) → `ZaehlePraefix` (`refs.go:34`) →
`regexp.FindAllStringIndex`. `ZaehlePraefix` kompiliert je Aufruf einen regulären Ausdruck, und
`fundIn` ruft es je Datei × bewegtem Namen auf — im Stack 3545 Dateien (`0xdd9`) × 203 bewegte Namen
(`0xcb`). Die Laufzeit wächst damit mit dem Produkt aus Suchraum und `done/`-Bestand; die Vorschau
gibt bis zum Ende nichts aus. Kein Befund an der Sperr-Logik; ein Kandidat fürs Register
(Planner, 3c), kein Slice.
