# Review: slice-sprung-auf-v6181-wird-vollzogen

**Range:** `773bb9ec^` bis `18ad6af9` (Implementer `1d79137b`, `26ef8f20`, `75b8fd8c`, `8f6405a9`, `6a8e5c78`, `e10c2328`;
Architect `5f294fbd`, `2a44411b`, `c63d2f48`) · **Plan:** `slice-sprung-auf-v6181-wird-vollzogen` ·
**Regierende ADR:** ADR-0093 (Accepted), Bezug ADR-0091 · Reviewer-Skill (Stand HEAD)

**Summary:** 0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO — annahmereif.

## Findings

### LOW-1 — Nach dem Entfernen von Fall `577` trägt die Verdrahtung des Aufrufs `NeutralizeConventionsTemplateRef` nur noch eine Fixture

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6 (Fixture gegen reale Quelle, Lücke benennen), MR-071
- `pfad`: `test/mutations/577-…` (entfernt, `26ef8f20`); `internal/emit/templates_test.go` (`TestTemplates_ConventionsTemplateRefGateSafe`, Fixture mit dem Wortlaut der Kurs-Stände bis `v6.18.0`)
- `befund`: Die Entfernung ist begründet: Die Mutation löscht den Aufruf, der am Pin ein No-op ist; der Fall erwartete ein rotes Ziel und färbte nichts (Quelle: der Marker trifft am vendored `v6.18.1` 0-mal, am `v6.18.0`-Stand 1-mal, gemessen per `git show e10c2328^:…conventions.template.md | grep -c 'MR-NNN-titel.template'` → 1 gegen `grep` am heutigen Baum → die Zeile trägt das Präfix). Ein neuer Verankerungs-Anker an der realen Quelle ist nicht erreichbar, weil der Wirkungs-Pfad am Pin leer ist. Die Begründung steht aber nur in der Commit-Message von `26ef8f20` und in ADR-0093, nicht am Ort der Zusage: der Kommentar an `NeutralizeConventionsTemplateRef` sagt nicht, dass der Aufruf selbst am Pin ohne realen Wächter ist (nur die Fixture hält, dass er bei einem älteren `COURSE_TAG` wirkt). Wer `COURSE_TAG` auf einen alten Stand setzt und den Aufruf entfernt, wird nur von der Fixture gewarnt, nicht vom Ziel-Lauf.
- `verifizierbar`: ja (`git show 26ef8f20 --stat`; `sed -n 676,690p internal/emit/templates.go`)
- `klasse`: benannte Lücke nicht am Ort der Zusage

### INFO-1 — `conventionsPathRefOld:0` misst die Lage am realen Baum, unterscheidet aber „Präfix steht" nicht von „Satz entfällt"

- `kategorie`: INFO
- `quelle`: AGENTS.md §3.6 (Eigenschaft statt Implementierung)
- `pfad`: `test/neutralisierung-marker.bats:26-30`
- `befund`: Der Wächter liest die reale Quelle (`DefaultTag` aus `internal/fetch/baseline.go`, Vorlage im vendored Baum), nicht die Fixture, und ist rot, sobald der unpräfixierte Marker in der Vorlage wieder auftaucht — das ist die Eigenschaft („die Ersetzung ist am Pin ein No-op, weil die Adresse präfixiert ist" bzw. „kein unpräfixierter Pfad im Ziel"). Der Wert 0 wird auch erreicht, wenn die Vorlage den Satz ganz streicht; dann bliebe der Wächter grün. Das ist für die Eigenschaft „kein totes Inline-Code-Pfad im Ziel" folgenlos, und ADR-0093 Festlegung 2 benennt den Ende-zu-Ende-Beleg (`make full-smoke`) als Träger. Das behauptete Rot des Implementers (Präfix in `v6.18.1/templates/harness/conventions.template.md` entfernt → „1 Treffer … erwartet 0") habe ich **nicht** wiederholt: das Schreiben in den vendored Baum wurde vom Permission-System verweigert. Plausibel am Lesebefund (der Marker hat in `v6.18.0` genau 1 Treffer, in `v6.18.1` 0).
- `verifizierbar`: teilweise (Rot-Beleg des Implementers nicht nachgefahren)
- `klasse`: Wächter-Grenze

### INFO-2 — Das Freshness-Verdikt `c63d2f48` ist ein leerer Commit

- `kategorie`: INFO
- `quelle`: ADR-0093 Festlegung 1 (Verdikt „im Vollzug"), Plan A3
- `pfad`: `git show --stat c63d2f48` (keine Datei)
- `befund`: Das Verdikt über die elf Kandidaten (MR-008, -020, -026, -028, -029, -031, -034, -038, -045, -060, -072) steht nur in der Commit-Message; die Reihenfolge ist richtig (Verdikt `c63d2f48` vor dem Entfernen des alten Baums `e10c2328`, wie A3 und das Register `freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums` es verlangen). Als Übergabe-Artefakt ist es an `git log` auffindbar, an keiner Datei. Ob das trägt, ist Planner-/Verifier-Urteil.
- `verifizierbar`: ja
- `klasse`: Artefakt-Form

## Schwerpunkte, Negativbefund

- **(a) Fall 577:** siehe LOW-1; MR-071 verletzt der Fall nicht (Mutation ohne Wirkung am neuen Baum), keine weitere Referenz auf `577` in lebenden Artefakten außer Plan und ADR-0093 (`git grep -n 577`), `make mutate-greift` läuft in `make gates` grün.
- **(b) Wächter 0:** siehe INFO-1.
- **(c) welle-09-modul-15-konformitaet.md:** `git show 8f6405a9` — 3 Zeilen, ausschließlich `v6.18.0` → `v6.18.1` in drei Pfaden, kein Inhalt. Die Datei liegt flach im Planning-Baum und ist nicht eingefroren; §3.11 lässt in änderbaren Artefakten den Pfad stehen und den Move/Nachzug die Adresse ziehen. §3.10 nicht berührt (keine Closure). Zulässig; der Plan nennt „lebende Markdown-Artefakte mit Adresse … je Eigentümer ein Commit", die Commit-Message nennt die Rolle des Artefakts. Kein Befund.
- **(d) 8 Slice-Pläne (`6a8e5c78`):** 19 Zeilen +/−, alle Paare unterscheiden sich allein durch `v6.18.0`/`v6.18.1` in Pfaden und Kommandos (Diff gelesen). Kein Befund.
- **(e) §3.7:** Kommentare in `templates.go` (Zeile 679-686, NUL-Probe, Backtick-Probe), `templates_test.go`, `neutralisierung-marker.bats` sind Indikativ über den Ist-Zustand und nennen den Sensor; keine Befund-Kennung oder Slice-Nummer als Erzählung. Einzige Randlage: „der gepinnte Stand traegt ihn nicht mehr" (`templates_test.go:36`) liest sich leicht als Rückblick; Stil-Grenze, nicht gemeldet. Kein Befund.
- **(f) Commit-Zuschnitt:** Kein `git mv` mit Inhaltsänderung in der Range (§3.3; der einzige Move `5c962cc1` ist rein, 0 Zeilen). Architect-Artefakte (AGENTS.md, `harness/conventions.md`, `harness/conventions/MR-*.md`, `harness/migration.md`) liegen ausschließlich in `5f294fbd`, `2a44411b` (Rolle in der Message); die Implementer-Commits berühren keine davon (`git log --stat` je Commit gelesen), `harness/sensors/*` und `docs/user/` gehören dem Implementer. Keine `Accepted`-ADR im Diff verändert (§3.4; ADR-0093 liegt vor der Range). Der Abschluss (§3.10) ist nicht vorweggenommen: Plan unter `in-progress/`, `§7` ungeschrieben. Kein Befund.
- **Gegen ADR-0093/0091:** Tabelle `conventionsPathRefOld` bleibt unverändert, Emitter-Behandlung der Adressen unverändert (Festlegung 2), fünf Pins und Mess-Tag auf `v6.18.1` (Diff `Makefile`, `.d-check.yml`, `internal/fetch/baseline.go`, `internal/emit/baumaussage.go`), alter Baum entfernt (`ls .harness/baseline` → `v6.18.1`), `make baseline-verify` → `v6.18.1 OK — 54 Dateien`. Kein Befund.
- **Nicht gemessen:** `make full-smoke` (Ende-zu-Ende-Beleg zu ADR-0093 Festlegung 2) ist nicht in `make gates` und wurde von mir nicht gefahren; er ist Closure-Trigger 1 und Sache des Verifiers.

## Sensoren

- Anweisungssatz `.harness/skills/reviewer.md` auf `baseline/v6.18.1/` nachgezogen (Commit `18ad6af9`); `git grep -n 'baseline/v6\.18\.0' -- .harness/skills` leer.
- `make gates` am sauberen Baum von HEAD `18ad6af9` (vor diesem Report): EXIT 0; Stempel `.harness/state/gates-passed.head` == HEAD.
