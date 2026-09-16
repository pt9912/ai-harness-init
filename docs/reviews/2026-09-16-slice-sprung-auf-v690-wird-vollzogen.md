# Review-Report: slice-sprung-auf-v690-wird-vollzogen — 2026-09-16

**Review-Art:** Code — geprüft wird der Diff gegen Plan, ADR, Hard Rules und die Setzungen des
Auftraggebers vom 2026-09-16 (Modul 10 §Drei Review-Arten).

**Gegenstand:** `git diff 1aee7739..44f5c034`, 20 Commits. **Vom Urteil ausgenommen:** `1b643a87`
(Adress-Nachzug der Skill-Datei). Diesen Commit hat der Reviewer selbst geschrieben. Die
Umbenennungen im vendored Baum sind nur über `make baseline-verify` geprüft, nicht inhaltlich.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 (Stand `1b643a87`) ·
**Modell:** claude-opus-5 · **Datum:** 2026-09-16

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext:**

- Plan `slice-sprung-auf-v690-wird-vollzogen`, Stand `44f5c034`, dazu das Architect-Verdikt zum
  Plan (`docs/reviews/2026-09-16-slice-sprung-auf-v690-wird-vollzogen-architect.md`)
- [ADR-0056](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (`Accepted`),
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegungen 2 und 4),
  ADR-0028, ADR-0031 (Festlegung 2)
- `LH-QA-01`, `LH-QA-02`, `LH-FA-09`
- `AGENTS.md` §3 (Hard Rules), dort §3.6, §3.7, §3.8, §3.10, §3.11
- `harness/migration.md` §4 bis §6; `MR-025`, `MR-032`, `MR-033`, `MR-039`, `MR-046`, `MR-051`
- `v6.9.0` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
  (Schritt 2); `v6.9.0` · `regelwerk/modul-03-spec.md` §Ziel-Form: Spezifikation;
  `v6.9.0` · `templates/harness/sensors/gate.template.md`
- Setzungen des Auftraggebers vom 2026-09-16, Nr. 1 bis 5 (Maßstab, nicht Gegenstand)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Inhalt ist umgezogen, obwohl die Erlaubnis nur Sperren-Stoff abdeckt. `e26ee898` (Architect) verlegt den Absatz „Auswerter (slice-060)" aus der Modus-Deklaration in ein neues `## Glossar (optional)` und schreibt ihn dabei um. `42276db5` (Implementer) verschiebt in `full-smoke.md` den Absatz „Die Stufen-Menge hängt an einer Textform" innerhalb von `Grenze` nach oben und hängt die zwei LEITUNG/BAUM-Absätze von `Grenze` nach `Ausgabe` um. | Setzung 2 des Auftraggebers („Kein Inhaltsumzug"); `harness/migration.md` §5 a | `harness/conventions.md:305-309`; `harness/sensors/full-smoke.md:41`, `:48-55` | nein — kein Gate liest, ob Text umzieht; `git show e26ee898 42276db5` zeigt es | Inhaltsumzug beim Angleichen der Gliederung |
| F-2 | MEDIUM | Der neue Regelsatz zum Sammelposten lässt „dem auslösenden Slice zugeschlagen" als Weg zu. 17 Zeilen davor schließt dieselbe Spezifikation genau diesen Weg aus („Sie scheidet aus, weil sie die falsche Größe liefert"). Vor `b3dbb770` stand hier ein Zitat der Optionen, die das Modul anbietet, und keine eigene Regel. | Spec-Treue (Technik-Stratum, Rang 2); Maintainability | `spec/spezifikation.md:466-467` gegen `:449-453` | nein — kein Gate liest den Inhalt der Spec | Umschrift eines Zitats in eine eigene Regel ändert die Aussage |
| F-3 | MEDIUM | Der Vorlagen-Bericht gibt fünf einmaligen Vorlagen (carveouts/README, harness/README, project-readme, architecture, spezifikation) keinen der vier Ausgänge, sondern „nicht Gegenstand dieses Sprungs". `harness/migration.md` §5 a verlangt eine geschlossene Menge und nimmt nur die Zeilen aus §6 aus. Den sprungbezogenen Ausschluss wegen der delta-gebundenen Übernahme führt §5 a nicht. | `harness/migration.md` §5 a (Architect); Setzung 1 des Auftraggebers | `docs/migrations/v6.9.0.md:42`, `:72-75`, `:170`; `harness/migration.md:199-201`, `:233-240` | nein — der Report ist kein Gate-Gegenstand | Ausgang außerhalb der geschlossenen Menge |
| F-4 | MEDIUM | Die neuen Exit-Aussagen gelten für den Skript-Aufruf, nicht für `make <target>`. Das Rezept meldet jeden Fehlschlag mit 2. In `slice-mv.md` heißt 2 „eine Sperre griff; es ist nichts bewegt", obwohl auch ein Commit, der nach `git mv` scheitert, über `make` mit 2 endet. Der Bericht behauptet für `vendor-baseline`: „über `make` endet der Lauf mit 0 oder 1". `history-range-guard.md` nennt für den `make`-Fall Exit 1. | `AGENTS.md` §3.6 (Zusage ohne gesehenes Gegenbeispiel); Maintainability | `harness/sensors/slice-mv.md:41-44`; `harness/sensors/history-range-guard.md:53-55`; `docs/migrations/v6.9.0.md:147` | ja — `make history-range-guard; echo $?` → 2 (das Skript direkt → 1); `make slice-mv; echo $?` → 2 | Exit-Zusage für `make` aus dem Skript-Aufruf abgeleitet |
| F-5 | LOW | Nach dem Entfernen der Links verweisen mehrere Sätze auf „das Modul", ohne dass noch ein Bezug dasteht. Der Absatz der Abweichungen verlangt selbst, die Regel zu nennen, von der abgewichen wird. Dieselben Aussagen zeigen weiter nach außen, nur ohne Adresse. | Maintainability; Setzung 3 des Auftraggebers (überschneidet sich mit dem noch nicht angelegten Matrix-Slice) | `spec/spezifikation.md:362-364`, `:388`, `:391`, `:449`, `:453` | nein | Teil-Entfernung eines Verweises lässt Rückbezüge ohne Ziel |
| F-6 | LOW | Die Spezifikation wurde am 2026-09-16 inhaltlich geändert: zwei Herkunfts-Sätze gestrichen, der Regelsatz zum Sammelposten neu gefasst. §7 Historie hat dafür keine Zeile, die letzte Zeile trägt 2026-09-02. | `v6.9.0` · `regelwerk/modul-03-spec.md` §Ziel-Form: Spezifikation („trägt ihre Änderungen in der Historie; die letzte Zeile ist das Datum") | `spec/spezifikation.md:735-743` | nein | Spec-Änderung ohne Historie-Zeile |
| F-7 | LOW | `### Im gebootstrappten Ziel` hängt unter `## Bindung`, weil der Abschnitt dort stand, nicht weil sein Inhalt passt; der Bericht sagt das selbst. Der Inhalt ist überwiegend Vertrag und Grenze des emittierten Werkzeugs. Die Vorlage nennt für `Bindung` nur die Kennung. Setzung 2 verlangt zugleich den „passenden" Abschnitt und verbietet den Umzug; für diesen Fall ist das ein Zielkonflikt. | `harness/migration.md:211` („im passenden Vorlagen-Abschnitt"); `v6.9.0` · `templates/harness/sensors/gate.template.md` §Bindung | `harness/sensors/slice-mv.md:63`; `harness/sensors/history-range-guard.md:61`; `docs/migrations/v6.9.0.md:149-150` | nein | Unterabschnitt nach Lage statt nach Inhalt zugeordnet |
| F-8 | LOW | Zwei Commit-Messages nennen Messwerte ohne das Kommando, das sie liefert. `5ea9a75d`: „in 12 der 15 Dateien fehlt `## Sperren`, in 12 fehlt `## Ausgabe und Ausgaenge`"; nachgemessen ist die erste Zahl richtig. `42276db5`: „13 von 15 gleich". | `MR-051` Setzung 1 | Commit-Messages `5ea9a75d`, `42276db5` | nein — gepusht, keine Prüfung vor dem Commit | Zahl in der Commit-Message ohne Kommando |
| F-9 | INFO | `vendor-baseline.md` §Sperren nennt den Abbruch ohne Repo-Wurzel nicht, obwohl das Werkzeug ihn als Laufzeit-Fehler führt. Der Bericht wertet die Datei als *schon erfüllt*, weil sein Kriterium nur Überschriften vergleicht, nicht die Vollständigkeit eines Abschnitts. Die Lücke ist dem Auftraggeber bekannt. | `v6.9.0` · `templates/harness/sensors/gate.template.md` §Sperren | `harness/sensors/vendor-baseline.md:33-38`; `cmd/ai-harness-init/vendor_baseline.go:59` | nein | Gliederungs-Kriterium misst die Vollständigkeit eines Abschnitts nicht |
| F-10 | INFO | An den Verifier: Das Übergabe-Artefakt aus DoD 2 (je Eintrag ein Ausgang, dazu das Ergebnis der Stichprobe) liegt nur als Sammelzeile in `0b7bcd2e` vor („Alle uebrigen 55 … bleibt gueltig"). Die in §1 des Plans an den Architect gerichtete Frage zu `MR-035`/`MR-056` beantwortet keine Einzelbegründung. Der Auto-Kontext wächst dabei von 113031 auf 119270 Zeichen, siehe den Nachzug in `MR-056` Setzung 4. | Verifier (Modul 11) | `harness/conventions/MR-056-die-auswahl-im-auto-kontext-haengt-an-der-lauf-beruehrung.md:80-84` | — | Einzel-Ausgang nur als Sammelzeile belegt |
| F-11 | INFO | In der Planungs-README übernimmt `c5d48b45` die Zeilen `next/` und `in-progress/` ohne Delta, so wie Plan-DoD 3.3 und Setzung 4 es verlangen. Die Zeilen „Regeln dieser Sektion" lässt derselbe Commit weg, „weil das Delta sie nicht berührt". Innerhalb einer Instanz gelten damit zwei Maßstäbe, und der Diff folgt dabei dem Plan. Adressat: Planner und Architect. | Setzung 1 und 4 des Auftraggebers | `docs/plan/planning/README.md:14-16` | — | Maßstab innerhalb einer Instanz uneinheitlich |
| F-12 | INFO | `MR-039` trägt jetzt zwei ÜBERHOLT-Marken. Die erste sagt „Setzung 1, 2 und 3 gelten fort", die zweite überholt Setzung 1 und 2. Das entspricht `MR-032` Setzung 1: eine gesetzte Marke wird nicht umgeschrieben, weitere Zeilen sind frei. Wer nur die erste Zeile liest, liest den überholten Stand. | `MR-032` Setzung 1 | `harness/conventions/MR-039-ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines.md:3-5` | — | Kopf-Marken widersprechen sich in der Lesereihenfolge |

### Belege zu den Findings

- **F-1.** Die erlaubte Wanderung (Sperren-Stoff nach `## Sperren`) ist in `slice-mv.md`
  eingehalten; siehe die Negativbefunde. `full-smoke.md`: Der Diff von `42276db5` entfernt den
  Stufen-Menge-Absatz am Ende von `Grenze` und setzt ihn direkt unter die Überschrift. Die
  Überschrift `## Ausgabe und Ausgänge` steht jetzt vor „Sein Grün sagt das eine, sein Rot sagt
  zwei Dinge". Inhaltlich weist die Vorlage diesen Stoff dem Abschnitt `Ausgabe` zu
  (*„Unterscheidet der Lauf Fehlschlag-Ursachen …"*); der Befund betrifft die Erlaubnis, nicht
  die Passung. `conventions.md`: Der Glossar-Abschnitt ist in der Vorlage als bedingt
  gekennzeichnet und hätte fehlen dürfen. Der Absatz hätte als `###` in der Modus-Deklaration
  bleiben können.
- **F-2.** Vorher, an Zeile 467 alter Zählung: *„… verlangt an dieser Stelle wörtlich:
  „… entscheide begründet, wie du ihn aufteilst (anteilig nach Tool-Calls? dem auslösenden Slice
  zugeschlagen?)""*. Nachher an Zeile 466: *„Ein Span ohne Rollen-Tag (Sammelposten) wird
  begründet aufgeteilt — anteilig nach Tool-Calls oder dem auslösenden Slice zugeschlagen."*
  Zeile 449: *„Das Modul bietet zwei Regeln an; die zweite schlägt den Sammelposten dem
  **auslösenden Slice** zu. Sie scheidet aus …"*.
- **F-4.** Gemessen am Stand `44f5c034`: `make history-range-guard` → 2,
  `bash harness/tools/history-range-guard.sh ""` → 1, `make slice-mv` → 2. In
  `harness/tools/slice-mv.sh` folgt der Commit (Zeile 234) auf `git mv` (Zeile 229). Die Sätze in
  `docs-check.md`, `doc-tracked.md` und `adr-immutable.md` beschreiben das Verhalten von `make`
  richtig (*„`make` meldet den Exit als `Fehler <n>` und endet selbst mit 2"*). In den drei
  genannten Stellen fehlt diese Angabe oder steht falsch. Die Zeile in `vendor-baseline` trägt
  das Verdikt *Ausgabe entfällt* trotzdem, denn 0 und 2 sind ebenfalls nur grün und rot.
- **F-6.** `grep -n '^| 2026' spec/spezifikation.md | tail -1` → Zeile mit `2026-09-02`.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| vendored Baum (Umbenennungen) | `make baseline-verify` → `baseline-verify: v6.9.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`; geprüft, ohne Befund |
| fünf Pin-Stellen (`Makefile`, `.d-check.yml`, `internal/fetch/baseline.go`) | Diff von `63e0964e`: Tag und sha256 an allen fünf Stellen gleich; die drei Wächter laufen in `make gates` mit; geprüft, ohne Befund |
| `.claude/rules/`-Symlinks | `readlink .claude/rules/*.md \| grep '\.harness/baseline/' \| grep -vc 'baseline/v6\.9\.0/'` → 0; geprüft, ohne Befund |
| Commit-Zuschnitt je Rolle (`AGENTS.md` §3.8, §3.10) | `git show --stat` über alle 19 fremden Commits. Architect-Commits berühren nur `AGENTS.md`, `harness/conventions.md`, `harness/conventions/`, `harness/migration.md`. Planner-Commits berühren nur die Roadmap und einen neuen Plan in `open/`. Implementer-Commits berühren weder ein Architect-Artefakt noch eine Closure. Keine ADR ist berührt. Geprüft, ohne Befund |
| `58f2156f` (`--amend --only`) | eine Datei (`harness/migration.md`), der Diff liegt nur in §5 a und passt zur Message; nichts Fremdes darin; geprüft, ohne Befund |
| `MR-060` gegen `v6.9.0` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit | Das Zitat trägt: die Klasse `MR` steht jetzt in der Append-only-Aufzählung, die Nacharbeit gilt nur für Singletons. Die zwei Kommandos liefern am Stand `1` bzw. `0`. Pflichtfelder der Vorlage einschließlich `Löst auf` und `Ausgelöst durch Baseline-Stand` sind vorhanden, ebenso die Index-Zeile mit beiden Ankern. Geprüft, ohne Befund |
| Kopf-Marke an `MR-039` gegen `MR-032`/`MR-046` | wird im selben Commit gesetzt wie der ablösende Eintrag (Setzung 3); die alte Marke bleibt wörtlich (Setzung 1); der Eintrag bleibt aktiv, weil Setzung 3 fortgilt. Geprüft, ohne Befund, nur INFO F-12 |
| Zahlen in `AGENTS.md` und `MR-056` nach dem Nachzug | am Baum nachgemessen: 362419 · 26 · 1 · 3 · 0 · 3 · 1 (`AGENTS.md`); 119270 · 25622 · 27,4 % (`MR-056`); geprüft, ohne Befund |
| Zusatzklassen-Deklaration in `harness/conventions.md` | Kommandos gefahren: 30 Zeilen; 7 · 0 · 4 · 2 · 5 · 1 · 19 · 1; Rest 0. Geprüft, ohne Befund |
| `spec/spezifikation.md`: gestrichene Ordnungszahl „dritte" (SPEC-013, SPEC-014) | Vorher nannten **beide** Zeilen sich „die dritte Korrelations-Achse"; die Ordnungszahl war schon in sich widersprüchlich. Ohne sie ändert sich an Pflicht, Quelle und Wächter der Zeilen nichts. Geprüft, ohne Befund |
| `spec/spezifikation.md`: übrige Außenverweise und MR-Nennungen | laut Auftrag Gegenstand des Matrix-Slice; nicht bewertet |
| `docs/migrations/v6.9.0.md`: Form und Zahlen | Delta-Kommando liefert fünf Zeilen; Buchstabe a 15 = 25 − 9 − 1; 4 übernommen · 4 schon erfüllt · 2 keine Instanz · 0 bewusst abweichend; der Ist-Maßstab-Abschnitt ist als solcher gekennzeichnet und nennt ADR-0056 Trigger 3; der Slice steht als Kennung ohne Link da. Geprüft, ohne Befund, bis auf F-3 und F-4 |
| Sperren-Stichprobe (Datei:Zeile gegen Werkzeug) | `slice-mv.sh`: alle Sperren-Meldungen mit Exit 2 vor `git mv` (Zeilen 188–225). `span_report.go:53`. `mutate.sh`: ABBRUCH-Meldungen. `hook-overhead.sh`: drei BEFUND-Sperren mit Exit 1 (Zeilen 101–184). `comment-claims.sh:85` überspringt Nicht-Dateien. `full-smoke.sh`: vor Zeile 257 nur Funktionsdefinitionen, als Stichprobe über die Zeilen 20–50 und 150–257. Geprüft, ohne Befund außer F-4 und F-9 |
| `slice-mv.md`: Satz zur sauberen Arbeitskopie | von `Vertrag` nach `Sperren`, fällt unter die Erlaubnis; inhaltlich erhalten („vor dem ersten `git mv`") und erweitert. Geprüft, ohne Befund |
| `hook-overhead.md`: Schwelle | Die Datei sagt selbst, dass der Exit die Schwelle nicht durchsetzt; das ist deklariert. Geprüft, ohne Befund |
| Planungs-README und Roadmap | `c5d48b45`: die drei Zeilen sind wortgleich mit der Vorlage, `### Beobachtungs-Register` bleibt an seiner Stelle. `76e84171`: nur das Delta übernommen. Geprüft, ohne Befund außer INFO F-11 |
| Folge-Slice `slice-gliederung-der-instanzen-ohne-vorlagen-delta` (`8ee9b1f2`) | Planner-Commit; die `##`-Gliederung ist gleich der von `slice.template.md` in `v6.9.0`; der Kopf trägt die neue Form (append-only ab dem Sprung-Datum); der Gegenstand nimmt die fünf Instanzen aus F-3 an. Geprüft, ohne Befund |
| `AGENTS.md` §3.7 (Chronik) | `git diff 1aee7739 44f5c034` über den lebenden Bestand, Suche nach `früher\|bisher\|stand bis\|umgezogen\|zuvor\|Review-Befund\|hier und heute` → kein Treffer. Die Zustandszellen „(vollzogen)" und „gesetzt und am selben Tag vollzogen" nennen einen Zustand. Geprüft, ohne Befund |
| `AGENTS.md` §3.11 und `MR-033` | Der Bericht nennt den Slice bei seiner Kennung. `MR-060` misst über den Commit `63e0964e^` (Tree-Operand). Datierte Messungen gegen `v6.8.0` sind laut `a12a75ae` bewusst stehen geblieben (Plan §1). Geprüft, ohne Befund |
| `AGENTS.md` §3.4, §3.5 | keine ADR im Diff; `.d-check.yml` ändert nur das `sources`-Paar. Geprüft, ohne Befund |
| Traceability der Commit-Messages | alle 19 fremden Commits nennen eine `ADR-`-Kennung (bei `63e0964e` und `a12a75ae` im Rumpf). Geprüft, ohne Befund |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 4 |
| LOW | 4 |
| INFO | 4 |

**Finding-Klassen dieses Laufs:** Inhaltsumzug beim Angleichen der Gliederung · Umschrift eines
Zitats in eine eigene Regel ändert die Aussage · Ausgang außerhalb der geschlossenen Menge ·
Exit-Zusage für `make` aus dem Skript-Aufruf abgeleitet · Teil-Entfernung eines Verweises lässt
Rückbezüge ohne Ziel · Spec-Änderung ohne Historie-Zeile · Unterabschnitt nach Lage statt nach
Inhalt zugeordnet · Zahl in der Commit-Message ohne Kommando

## Verdikt

**Kein HIGH; vier MEDIUM sind vor der Closure zu klären.**

**Merge-blockierend:** nein für den Stand, der schon gepusht ist. Ja für die Planner-Closure. Kein
Befund verletzt eine ADR, eine Hard Rule im Sinn der HIGH-Liste oder ein Gate. Die vier MEDIUM
betreffen aber Maßstäbe, die diesen Slice abnehmen:

- F-1 und F-3 betreffen die Setzungen des Auftraggebers und `harness/migration.md` §5 a. F-3 und
  F-7 sind Norm-Fragen an den Architect.
- F-2 und F-4 sind Aussagen im Technik-Stratum bzw. in Sensor-Verträgen, die gemessen nicht
  tragen.

**Übergabe:**

- F-1 (Implementer-Teil), F-2, F-4, F-5, F-6 und F-8 gehen an den Implementer.
- F-1 (Architect-Teil), F-3 und F-7 gehen an den Architect.
- F-10 geht an den Verifier.
- F-11 geht an Planner und Architect.

Die Finding-Klassen gehen in die Slice-Closure §7. Dieser Report ist ein Lauf-Beleg und ersetzt
keine Verifikation gegen DoD und Spec.
