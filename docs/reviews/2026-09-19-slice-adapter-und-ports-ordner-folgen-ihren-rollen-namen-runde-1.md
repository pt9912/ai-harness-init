# Review-Report: slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen — 2026-09-19 (Runde 1)

**Review-Art:** Code — geprüft gegen den Slice-Plan und die ADRs (Modul 10 §Drei Review-Arten). Dieser Lauf ist zugleich die Konsistenz-Prüfung, die der Acceptance-Trigger von [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) verlangt.

**Gegenstand:** Diff `15cb681c..ea8556e4` — drei Commits: `366c8837` (Arbeit), `6c880bb7` (full-smoke-Nachzug), `ea8556e4` (Kommentar-Nachzug); ADR-Commit `585daf4f` liegt vor der Range und wurde als Eingabe geprüft.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** glm-5.3-flash (Claude Agent SDK, Typ `reviewer`) · **Datum:** 2026-09-19

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

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- Slice-Plan `slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen` (`docs/plan/planning/in-progress/`, Stand im Arbeits-Commit `366c8837` samt §3-Verfeinerungen)
- [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) (Proposed — Gegenstand des Accept-Übergangs), [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) (Accepted, Festlegung 2 verbatim), [`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md), [`ADR-0008`](../../docs/plan/adr/0008-arch-achse-emittiertes-skelett.md) (beide Accepted, über ADR-0060 zitiert)
- [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `AGENTS.md` §3 (Hard Rules), `spec/architecture.md` (Rang 2), `docs/user/benutzerhandbuch.md`
- Kanonische Referenz (fremdes Repo, nur gelesen, Kennung nicht zitiert): `lab/examples/go` — Skelett-Datei-Menge, Imports des treibenden Adapters, `.a-check.yml`-Kantenblock

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | ADR-0060 Festlegung 2 bindet den CLI-Use-Case-Port als inbound — von der treibenden Seite konsumiert, „Die Gliederung existiert dann im Baum, nicht im Kommentar" —, während Festlegung 4 die fünf Kanten aus ADR-0009 verbatim fortbindet (adapters→app erlaubt, adapters→ports abwesend). Beides zusammen ist für das Skelett unerfüllbar: ein materialisierter inbound-Port verlangt die fehlende Kante (so auch die Übergabe in Plan §3 Verfeinerung 1); die kanonische Referenz löst denselben Konflikt in der **Gegenrichtung** (`.a-check.yml` deklariert `driving_adapters→ports`, „the CLI speaks the slices' inbound ports", und `driving_adapters -> app` „deliberately not declared"; der treibende Adapter importiert ausschließlich `ports/inbound`, nie die Slices). Der emittierte Stand (beide Ports outbound, CLI importiert die Use-Case direkt) ist konsistent zu ADR-0009 und zur outbound-Hälfte von Festlegung 2, nicht zur Text-Fassung der inbound-Hälfte; der Accept-Übergang von ADR-0060 ist an diesem Befund blockiert (ihr eigener Trigger verlangt einen Report ohne blockierenden Befund). Plan §2 Liefer-Punkt 2 trägt denselben Text („der CLI-Adapter-Port inbound") und braucht denselben Re-Schnitt bei der Closure — die Abweichung ist als Übergabe deklariert, nicht still verengt. | [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) Festlegung 2/4 gegen [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) (Accepted) Festlegung 2; [`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md) Festlegung 1 (Trigger gefeuert, Neubewertung in ADR-0060 Festlegung 3) | `docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md:108-115` (Festlegung 2), `:129-133` (Festlegung 4); Plan §2 `:133-136` | ja — kein Gate; der Gate-Lauf, der es bestätigt, ist der Accept-Übergang des ADR selbst (Beleg: dieser Report); der Referenz-Beleg ist mit `grep -n 'from: driving_adapters' <referenz>/.a-check.yml` wiederholbar | ADR-Festlegungen konkurrieren um dieselbe Struktur (Ports-Achse inbound vs Kanten-Bindung) |
| F-2 | MEDIUM | Die Doku beschreibt die volle Ports-Gliederung („`ports` (gegliedert nach `inbound`/`outbound`)“ bzw. „mit eigenen `ports/`, gegliedert nach `inbound`/`outbound`“), der Renderer legt aber nur `ports/outbound/` — ein Bootstrap nach der Doku findet die inbound-Hälfte nicht. Dieselbe Lücke wie F-1 auf der Doku-Oberfläche; die inbound-Hälfte steht außerhalb des Baums nur in Glob-Scope-Kommentar, Plan-§2-Text und ADR-Text. | [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) Folgepflicht 3; `spec/architecture.md` (Source Precedence Rang 2) | `spec/architecture.md:170` · `docs/user/benutzerhandbuch.md:276` | ja — ein Bootstrap mit `--arch hexslice` legt `ports/outbound/` an und keine `ports/inbound/`; ein Struktur-Sensor über die emittierte Datei-Menge würde es bestätigen (heute keiner) | emittierte Zusage reicht weiter als was im Ziel geschieht |
| F-3 | MEDIUM | Die Aussage, die Ordner-Namen und die Arch-Gate-Zuordnung „lesen dieselben Konstanten" (Plan §3 Ansatz, DoD Liefer-Punkt 1; ADR-0060 Kontext), ist weder Code noch Test getragen: die hexslice-Pfade und Layer-Namen stehen als Literale, und kein Test bindet sie an die arch.go-Rollen-Konstanten (`hexagonal-driving`/`hexagonal-driven`, arch.go:50/:54 — deren einzige Leser sind die Case-Labels des hexagonal-Renderers). Der Re-Evaluierungs-Trigger 3 des ADR (Rollen-Namen ändern sich → Ordner folgen) hat keinen Wächter, der den Drift sichtbar macht. | Slice-Plan §2/§3; [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) Kontext + Re-Evaluierungs-Trigger 3 | `internal/gen/golang.go:70-85` (goRole-Pfade), `internal/gen/arch.go:50,54` | ja — ein Test, der die Ordner-Segmente gegen die arch.go-Konstanten bindet, würde es bestätigen; heute existiert er nicht | Zusage ohne Träger — Konstanten-Bezug behauptet, nicht gebunden |
| F-4 | LOW | Die Prosa zur sprach-abhängigen Kanten-Menge nennt die C++-Abweichung unter dem alten Schicht-Term `adapters→ports`; die emittierten Configs nennen sie `driven→ports` (hexslice wie hexagonal). Terminologie-Drift nach der Layer-Umbenennung. | Maintainability (Doku-Drift); `spec/architecture.md` ist Rang 2 | `spec/architecture.md:217` | nein — `make docs-check` prüft Referenzen, nicht Terminologie; ein Terminologie-Sensor existiert nicht | Layer-Umbenennung zieht die Prosa-Terminologie nicht nach |
| F-5 | LOW | Derselbe Glob-Scope-Kommentar steht in zwei Stimmungen: `cpp.go` im Indikativ („verengt den Bereich und laesst die Regel still inert"), `golang.go` im Irrealis über die verworfene Alternative („verengte den Bereich … und liesse die Regel still inert"). Die Indikativ-Variante ist die getragene Form. | `AGENTS.md` §3.7 | `internal/gen/golang.go:538-540` · `internal/gen/cpp.go:510-511` | nein — kein Gate liest Kommentar-Stimmung | Kommentar-Variante in Irrealis über die verworfene Alternative |
| F-6 | LOW | Der ADR-Index führt ADR-0060 doppelt (Zeilen 66 und 68, ADR-0059 dazwischen) — aus dem ADR-Commit `585daf4f` vor dieser Range, nicht aus dem geprüften Diff. `make docs-check` hält die Tabelle nicht gegen Duplikate und blieb grün. | Maintainability (Index-Disziplin) | `docs/plan/adr/README.md:66,68` | ja — ein Dedup-Check der Index-Tabelle würde es bestätigen; das `matrix`-Modul des Doku-Gates hält die Zeilen nicht gegen Duplikate | Index-Zeile doppelt, kein Sensor hält die Tabelle gegen Duplikate |
| F-7 | INFO | Mess-Stand Fremd-Kennungen: der geprüfte Diff trägt **0** Vorkommen von `hexslice-architecture` (`git diff 15cb681c..ea8556e4 \| grep -c 'hexslice-architecture'` → 0); repo-weit tragen **6** Bestand-Dateien die Referenz-Kennung (`grep -rln 'hexslice-architecture' --exclude-dir=.git .` → `spec/lastenheft.md`, `ADR-0009`, zwei Zeitdokumente, zwei Review-Reports) — der Auftrag nannte 0 ohne Messbereich; die Altbestand-Vorkommen liegen in eingefrorenen bzw. älteren Artefakten und sind durch die Setzung *„Fremdes Repo: lesen, nicht zitieren"* nicht nachrüstpflichtig. | [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) | — | ja — beide Kommandos stehen im Befund | Fremd-Kennung im Bestand, Messbereich der Aussage enger als ihre Formulierung |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Skeleton-Achsen beider Renderer gegen die Referenz (`lab/examples/go`): driving/driven-Adapter, Ports-Gliederung, Typen/Tiefe, Composition Root, Schicht-Tests | geprüft, ohne Befund am Diff — beide Renderer tragen dieselben Achsen; die reduzierte Form (ein Use-Case, eine Area) ist die ADR-0009-getragene Skelett-Reduktion; die ports-inbound-Differenz zur Referenz ist Gegenstand von F-1, kein neuer Befund am Diff |
| Ports-Gliederung im C++-Renderer (Pfade, Namespaces, Include-Guards, Handler-Aliase, Main- und Test-Imports, Konstanten) | geprüft, ohne Befund — konsistent auf `ports/outbound` |
| Arch-Gate-Config beider Sprachen (Port-Globs enden am `ports`-Segment, `composition_root`, Kanten-Kommentare in Config-Form) | geprüft, ohne Befund |
| Rot-Probe (c) — alter breiter Glob `internal/adapters/**` | selbst gefahren (Wegwerf-Klon, `make test-go`): EXIT 2, `archgate_test.go:111` meldet „fällt unter Schicht „adapters", want „driven"" (und want „driving") — rot aus dem richtigen Grund |
| Rot-Probe (a) — Skeleton legt einen `inbound`-Adapter an | selbst gefahren (Wegwerf-Klon): EXIT 2 — FileSet-Test rot (exakter Satz-Vergleich) und archgate rot mit „fällt unter KEINE Schicht (Loch im Prüfbereich)", „erwartete Skelett-Datei … fehlt", „Glob … ist für KEINE generierte Datei der spezifischste (Gate über leerem Bereich, LH-QA-01)" und „Kante driving->app … (Erlaubnis auf Vorrat)" — die Zähne binden |
| Rot-Probe (b) — flacher Port | nicht selbst gefahren; die beiden gefahrenen Proben färben dieselben exakten Satz-Vergleiche, die auch diesen Fall tragen — benannt, nicht belegt |
| §3.7 der Skelett- und Renderer-Kommentare (Adapter-Vokabeln: kein `Inbound-Adapter`/`Outbound-Adapter`-Rest, `Outbound-Port` im Port-Kommentar korrekt, `ports/inbound` nur im Glob-Scope-Kommentar) | geprüft, ohne Befund |
| `make full-smoke` | selbst gefahren, EXIT 0 — beide hexslice-Stufen (Go und C++) mit Arch-Gate-Zähnen im Lauf; die cpphex-Stufe prüft den Area-Port an der neuen Stelle (`harness/tools/full-smoke.sh:2374`, im Fix-Commit `6c880bb7` nachgezogen) |
| `make e2e-abdeckung` | regeneriert — unverändert gemessen („19 Stufen, 19 Deklarationen"), die `full-smoke`-Änderungen berühren keine Stufen-Deklaration |
| Commit-Zuschnitt | geprüft, ohne Befund — Arbeit (`366c8837`) · full-smoke-Nachzug (`6c880bb7`) · Kommentar (`ea8556e4`), je eigener Gegenstand; der Kommentar-Commit nennt die Import-Richtungen in Config-Form (Indikativ, beschreibt die Stelle) |
| ADR-0009-Index-Zeile | kein vorzeitiger Supersedes-Zusatz — ADR-0060 Festlegung 6 bindet den Zusatz an den Accept-Übergang, der steht noch aus |
| `make gates` (Gesamt-Lauf über dem Baum mit diesem Report) | grün, EXIT 0 — Go-Tests, Lint, Build, docs-check, shell-lint, baseline-verify, comment-claims (Lauf-Beleg im Record) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 2 |
| LOW | 3 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** ADR-Festlegungen konkurrieren um dieselbe Struktur (Ports-Achse inbound vs Kanten-Bindung) · emittierte Zusage reicht weiter als was im Ziel geschieht · Zusage ohne Träger — Konstanten-Bezug behauptet, nicht gebunden · Layer-Umbenennung zieht die Prosa-Terminologie nicht nach · Kommentar-Variante in Irrealis über die verworfene Alternative · Index-Zeile doppelt, kein Sensor hält die Tabelle gegen Duplikate

## Verdikt

**Merge-blockierend:** ja — F-1 (HIGH). Der blockierende Defekt ist nicht der Code-Diff: der emittierte Stand ist die konsistente Hälfte (konform zu ADR-0009 verbatim und zur outbound-Hälfte von ADR-0060 Festlegung 2, die Abweichung von Festlegung 2 als Übergabe deklariert, nicht still). Blockiert ist der **Accept-Übergang von ADR-0060** — sein eigener Trigger verlangt einen Report ohne blockierenden Befund; dieser Report trägt einen. Die Konflikt-Sequenz (Modul 8) läuft über den Architect: ADR-0060 ist Proposed, eine Korrektur der Festlegungen 2/4 ist vor dem Accept legal und braucht kein `Supersedes`; zu entscheiden ist, ob die inbound-Hälfte aus der Festlegung 2 auf die Ports-Achse der Referenz verwiesen wird (Abstand nach Trigger 1 schließen oder benennen) oder ob die Kanten-Menge der Referenz (driving→ports, kein driving→app) nachgezogen wird — der zweite Weg zöge ADR-0009 Festlegung 2 und ADR-0010 Festlegung 3 in denselben Re-Schnitt. Danach ziehen spec (`:170`), Handbuch (`:276`) und Plan §2 nach, und der Accept geht gegen einen neuen Review-Lauf.

**Übergabe:** Findings gehen an den Implementer (Rückkante Review → Plan bei Plan-Defekt — hier: Plan §2); F-1 und F-2 sind zugleich die Blockade-Meldung an den Architect für den Accept-Übergang; die **Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den Zähler — die Klasse von F-2 trägt denselben Namen wie die bestehende Registerzeile (`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`), die Closure entscheidet über das Hochschreiben. Dieser Report selbst ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen, und muss es nicht. Der Report ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext); der Verifier wird am DoD-Text von Plan §2 denselben Konflikt wie F-1 vorfinden und kann ihn aus diesem Report beantwortet lesen.