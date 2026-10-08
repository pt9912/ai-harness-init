# Welle-Closure welle-emittiertes-doc-gate — Architect-Verdikt (Schritte 2 ADR-Zweig und 3b)

- **Rolle:** Architect · **an:** Planner · **Eingang:** `2026-10-08-welle-emittiertes-doc-gate-audit-vorlage`,
  Abschnitte A und B (C und D sind Auftraggeber-Sache und hier nicht behandelt) ·
  **Bezug:** [`MR-054`](../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel),
  Baseline-Regelwerk `v6.17.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2 und 3
- **Gemessen auf:** `bdf6361b`
- **Ergebnis:** keine Folge-ADR, keine neue Regel. Kein Eintrag bekommt einen Anker
  `seit welle-emittiertes-doc-gate`.

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig

| ADR · Trigger | gefeuert | Verdikt |
|---|---|---|
| [ADR-0072](../plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md) „der nächste Sprung steht an" | ja | **bestätigt** — die Festlegung gilt nach ihrem eigenen Wortlaut nur für `v6.9.0 → v6.13.0`; der nächste Sprung hat neu gemessen ([ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)). Kein `supersedes`: nichts kippt, der Gegenstand ist verbraucht. |
| [ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) „der nächste Sprung steht an" | ja | **bestätigt** — ebenso, neu gemessen in [ADR-0082](../plan/adr/0082-ziel-fassung-regiert-den-sprung-v6170.md). |
| ADR-0078 T5 (Release vor dem Werkzeug-Teil des Gate-Index im Ziel) | nein | Werkzeug-Teil `2fec4763` (2026-10-07 05:53) ist Vorfahre von `v0.3.0` (09:54); `v0.2.8` (2026-10-06 17:55) trägt noch `v6.13.0` (`git ls-tree -d --name-only v0.2.8 .harness/baseline/` → `v6.13.0`) und liegt damit vor dem Intervall. Kein Release dazwischen. |
| [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) T1, [ADR-0077](../plan/adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md) T2, [ADR-0081](../plan/adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) T1 (Freshness `v6.17.0`) | nein | Das Delta `v6.16.0 → v6.17.0` ändert inhaltlich nur `modul-13-quality-gates.md` (Disjunktheit der `authority`-Teile); die übrigen Dateien ändern die Stand-Zeile. `git diff -U0 f9f082c5^:.harness/baseline/v6.16.0/regelwerk f9f082c5:.harness/baseline/v6.17.0/regelwerk` → keine Zeile zu Archivierung, *Träger im Repo ohne Wellen* oder *seit der letzten Closure*. |
| [ADR-0082](../plan/adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) T4 (d-check-Pin ändert die Wirkbedingungen des Schalters) | nein | `v0.83.0` ist der Pin, den die Entscheidung selbst einführt; `v0.84.0` ändert das Prüfverhalten nicht ([`MR-084`](../../harness/conventions.md#mr-084--d-check-pin-v0840-multi-arch-index-prüfverhalten-unverändert)). Die Pins `v0.79.0`–`v0.82.0` liegen vor der ADR (2026-10-07). |
| ADR-0082 T1 (nächster Sprung) | nicht festgestellt | `make baseline-freshness` läuft nur nächtlich (Netz); kein Auftrag nennt einen neuen Zielstand. |
| [ADR-0083](../plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md), [ADR-0084](../plan/adr/0084-reviewer-skills-im-ziel-skip-if-present.md), [ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md) (je 3×-Register-Trigger) | nein | kein Register-Verzeichnis dieses Gegenstands (Messung der Vorlage bestätigt). |

**Hard Rules:** einziger Auflösungs-Trigger in [`AGENTS.md`](../../AGENTS.md) ist *permanent*
(§3.5, `grep -n 'Auflösungs-Trigger' AGENTS.md`). **Bestätigt**, keine Zeile zu entfernen.

## B — Verkörperung beim Wiederauftreten (3b)

**Zählung geprüft.** Nachgemessen je Beleg: Add-Commit des Belegs gegen den ersten Commit, der
`verkörpert` in `state.md` schreibt, plus Abstammung. Die Spalte „danach" der Vorlage stimmt für 13
Zeilen. Zwei Abweichungen liegen in der Methode, nicht in der Vorlage:

- `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`: `-S'verkörpert'` liefert `3567a848`
  (2026-09-14) und damit 3. Die geltende Verkörperung ist aber [`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
  (`bd1ab107`, 2026-09-20). Danach liegt nur `slice-fall-406-trifft-die-umgebaute-zerlegung`; **1 ist
  richtig**.
- `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`: nach Commit-Zeit sind es 8. Einer
  davon ist der Beleg des verkörpernden Slice `slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst`
  selbst und damit kein Wiederauftreten. **7 ist richtig**.

**Grenze der Zählung:** Für fünf Einträge (`3567a848`, Welle-13-Closure) ist der erste
`verkörpert`-Commit das Datum, an dem das Feld erstmals in dieser Form stand. Eine frühere
Verkörperung würde mehr Belege nach hinten schieben. Die Spalte ist darum eine Untergrenze.
Kein Verdikt hängt daran.

| Eintrag | danach | Verdikt | Begründung · Sensor |
|---|---|---|---|
| `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` | 11 | (ii) → `slice-070-comment-claims-pruefbereich` | Sensor: `make comment-claims` erkennt in Kommentaren die zwei zählbaren Klassen (Befund-Kennung, Slice-Kennung außerhalb der Form `seit slice-…`). [`AGENTS.md`](../../AGENTS.md) §3.7 nennt ihn baubar. Slice-070 ist der einzige offene Slice am selben Werkzeug. Der Planner nimmt den Posten in dessen §1 auf und prüft dabei die Größenregel. |
| `neuer-waechter-ohne-mutations-fall` | 10 | (ii) → `slice-119-zusage-ohne-fall-wird-sichtbar` | Der Slice zählt Wächter ohne `test/mutations/`-Fall. Das ist genau diese Klasse. |
| `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` | 7 | (i) | Für die Adress-Hälfte urteilen `internal/emit/baumaussage_test.go` (`make test`) und [`test/baum-inventur.bats`](../../test/baum-inventur.bats). Die Bedingungs-Hälfte (Gelingens-Zweig, skip-if-present, Melde-Kanal) bleibt eine benannte Lücke. Ein Sensor dafür wäre eine `full-smoke`-Stufe auf vorbelegtem Grund. Kein offener Slice trägt ihn, deshalb steht er unter *Offen* unten. |
| `abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` | 4 | (iii) | Ob ein Vorgang eine Annahme des Kriteriums widerlegt, ist ein Urteil über Bedeutung. Keine Form unterscheidet es. Träger bleibt die Übergabe nach §3.10. |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 4 | (iii) | Die Klasse hat ihr Kommando, aber es misst den falschen Gegenstand. Das Kommando zu fahren, beweist nicht, dass es den Gegenstand misst. Die Formhälfte (die Zahl steht ohne Kommando) wäre zählbar, ist aber nicht diese Klasse. |
| `regel-rand-ohne-benannte-luecke` | 3 | (ii) → `slice-181-grenzen-liste-vollstaendig-oder-fail-closed` | Der Slice verlangt, dass eine erkennende Regel ihre Grenze vollständig nennt oder bei unbekannter Form fail-closed wird. |
| `waechter-misst-die-fixture-statt-der-realen-quelle` | 3 | (ii) → `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor` | Eine Fixture, die einen realen Wert nachbaut, ist ein doppelt geführter Wert. Der Kopplungs-Sensor hält sie gegen die Quelle. |
| `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` | 2 | (i) | Das Nachzug-Werkzeug setzt [ADR-0070](../plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) Festlegung 1 um. Gehalten wird das von `internal/archive/refs_test.go` und `cmd/ai-harness-init/slice_mv_echt_test.go` (`make test`). Die drei übrigen Formen aus [ADR-0042](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 5 bleiben dort als Grenze benannt. |
| `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel` | 2 | (ii) → `slice-069-zahn-bindet-zusicherung` | Der Slice bindet einen Mutations-Fall an die genannte Zusicherung und nicht nur an einen Wächter-Namen. Bei einer mehrteiligen Regel braucht jeder Teil damit einen eigenen bindenden Fall. |
| `zusage-nennt-zwei-kanten-der-sensor-deckt-eine` | 2 | (ii) → `slice-069-zahn-bindet-zusicherung` | Gleicher Mechanismus: Eine Kante ohne bindenden Fall wird am Treiber sichtbar. |
| `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` | 1 | (i) | `make mutate` (Nacht-Workflow) meldet einen entwaffneten Fall als Befund. Genau so entstehen die Belege. Der eigene Auslöser von MR-071 steht bei 1 von 3. |
| `prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle` | 1 | (iii) | Ob eine Wiedergabe weiter geht als ihre Quelle, ist ein Vergleich von Aussagen. Ein Link-Sensor prüft die Auflösbarkeit, nicht die Aussage. |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 1 | (iii) | Die fehlende Übergabe ist eine Abwesenheit ohne Form. Die Folge-Slice-Paarung prüft nur genannte Übergaben. |
| `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` | 1 | (ii) → `slice-119-zusage-ohne-fall-wird-sichtbar` | Klasse wie `neuer-waechter-ohne-mutations-fall`. Die Instanz `sync` bleibt bei `slice-sync-waechter-tragen-mutations-faelle`. |
| `zusage-ohne-herstellbares-gegenbeispiel` | 1 | (iii) | Ohne herstellbares Gegenbeispiel gibt es keine Mutation, die rot färben könnte. Die Regel schränkt die Zusage ein, ein Sensor wäre selbst eine Zusage ohne Gegenbeispiel. |

**Für den Planner:** Die (ii)-Zeilen sind der Ausgang *geplant* auf die genannte Kennung. Die
(i)- und (iii)-Zeilen bleiben *verkörpert*, mit der Begründung aus der Tabelle in `state.md`.
`state.md` schreibt der Planner.

**Akzeptiertes Negativ:** (iii) gilt für fünf Klassen, die nur ein Urteil über Bedeutung prüfen
kann. Ein weiteres Auftreten öffnet die Frage nicht neu, solange keine Form gefunden ist, die sie
trennt.

## Offen — an den Auftraggeber

- **Bedingungs-Hälfte von `emittierte-zusage-…`** (9 Belege im Fenster): Der Sensor ist benannt
  (`full-smoke`-Stufe auf vorbelegtem Grund, je Bedingungs-Zweig), aber kein bestehender Slice
  trägt ihn. Es gibt zwei Optionen: einem Slice aus Gruppe C zuordnen, oder die Lücke als
  akzeptiertes Negativ stehen lassen. **Empfehlung:** zuordnen. Die Klasse ist im Fenster am
  häufigsten aufgetreten.
- **`slice-070` als Träger des §3.7-Sensors:** Das gilt nur, wenn der Planner die Übernahme
  annimmt. Lehnt er sie ab, steht der Posten ebenfalls hier.
