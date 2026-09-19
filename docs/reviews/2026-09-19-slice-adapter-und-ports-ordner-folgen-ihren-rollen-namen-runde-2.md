# Review-Report: slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen — 2026-09-19 (Runde 2)

**Review-Art:** Code — geprüft gegen den Slice-Plan und die ADRs (Modul 10 §Drei Review-Arten). Dieser Lauf ist zugleich die Konsistenz-Prüfung, die der Acceptance-Trigger von [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) verlangt.

**Gegenstand:** Commit `34c9e446` (8 Dateien) — der zweite Emissions-Teil nach der Referenz-Anpassung des Auftraggebers (a-check v0.20.0). Runde 1 (`docs/reviews/2026-09-19-slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen-runde-1.md`, Commit `f90a6c8c`) ist abgehandelt; ihre F-2/F-4 zieht dieser Commit nach (unten), F-1 trägt einen neuen Mess-Stand.

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
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

- Slice-Plan `slice-adapter-und-ports-ordner-folgen-ihren-rollen-namen` (`docs/plan/planning/in-progress/`, Stand `34c9e446` samt §3 Verfeinerung 3)
- [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) (Proposed, Re-Schnitt `929f288e` 16:49), [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) (Accepted, Festlegung 2 verbatim), [`ADR-0010`](../../docs/plan/adr/0010-hexagonal-arch-realisierung.md), [`ADR-0008`](../../docs/plan/adr/0008-arch-achse-emittiertes-skelett.md) (beide Accepted)
- [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `AGENTS.md` §3 (Hard Rules), `spec/architecture.md` (Rang 2), `docs/user/benutzerhandbuch.md` (Rang 6)
- Kanonische Referenz (fremdes Repo, nur gelesen, Kennung nicht zitiert): `lab/examples/go/.a-check.yml` und `lab/examples/kotlin/.a-check.yml` — Layer-, Kanten- und Abwesenheits-Form

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | HIGH | Die emittierte Arch-Gate-Config deckt die Referenz **exakt** — und konkurriert damit mit dem Wortlaut der [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md)-Festlegungen 3 und 4, die am Referenz-Stand **vor** der Anpassung geschnitten sind. Messung: die emittierte Go-Config trägt 6 Layer mit `direction:` auf Port- und Adapter-Schichten und Port-Globs, die am Richtungs-Segment enden, plus 6 Kanten-Zeilen (`app→domain`, `app→ports_inbound`, `app→ports_outbound`, `ports_outbound→domain`, `driving_adapters→ports_inbound`, `driven_adapters→domain`); die Referenz-Datei (v0.20.0, Kopf im fremden Beispiel) trägt dieselben 6 Layer, dieselbe `direction:`-Form, dieselben 6 Kanten und dieselben drei Abwesenheits-Gründe. Festlegung 4 bindet dagegen „fünf Kanten in der Referenz-Form“ über **einer** Ports-Schicht (`app→ports`, `ports→domain`), Festlegung 3 bindet „die Ports-Schicht kann keine Richtung tragen … die Port-Globs enden bewusst am `ports`-Segment … `port-direction-mismatch` inert — opt-in“ — und lehnt in §Verglichene Alternativen genau die Form (Ports als eigenständige gegrade Schichten) ab, die die Emission jetzt vollzieht. Die ADR-Begründung (der portScope-Strich) hat die Referenz-Anpassung selbst aufgelöst: die Referenz erklärt Richtung tragende Port-Globs seit v0.20.0 für lebendig. Zeitlinie (gemessen): ADR-Re-Schnitt `929f288e` 16:49, Implementer-Commit `34c9e446` 19:20 — dazwischen bewegte der Auftraggeber die Referenz; die Emission folgt ihr, der ADR-Text hinkt. Der ADR-Trigger 1 (Upstream-Nachzug wählt eine andere Form) hat gefeuert und ist im Emissions-Arm geschlossen; die normative Aufarbeitung ist als Übergabe deklariert (Plan §3 Verfeinerung 3), nicht still verengt. Der Accept-Übergang des ADR ist an diesem Befund blockiert (ihr eigener Trigger verlangt einen Report ohne blockierenden Befund). | [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) Festlegung 3 (:142-166) und 4 (:155-159) gegen die Referenz-Form (`lab/examples/go/.a-check.yml`, fremdes Repo, nur gelesen) und [`ADR-0009`](../../docs/plan/adr/0009-hexslice-arch-realisierung.md) Festlegung 2 (Accepted — die verbatim-Kanten-Menge bindet, bis [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md) `Accepted` ist) | `docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md:142-166` · `internal/gen/golang.go:557-589` | ja — kein Gate liest den ADR-Text; die Zählung ist mit `grep -c 'from:' <referenz>/.a-check.yml` → 6 gegen `grep -c 'from:'` auf der emittierten Config wiederholbar (Layer-Köpfe ebenso), der Accept-Lauf, der den Befund bestätigt, ist der Accept-Übergang selbst (Beleg: dieser Report) | ADR-Festlegungen konkurrieren um dieselbe Struktur |
| F-2 | MEDIUM | Das Handbuch nennt einen Layer, den die emittierte Config nicht mehr führt: `docs/user/benutzerhandbuch.md:298` weist den Adopter an, einen neuen Use-Case „je ein Eintrag unter `app` und, falls er eigene Ports hat, unter `ports`“ nachzutragen — emittiert sind `ports_inbound`/`ports_outbound` mit je `direction:`, ein Layer `ports` existiert nicht. Versagens-Szenario: ein Ziel-Adopter trägt nach dem Handbuch nach, sein Port-Eintrag landet unter einem nicht existierenden Layer, die Port-Dateien fallen unter keine Schicht (Loch im Prüfbereich) oder unter die falsche. `spec/architecture.md` (Rang 2) hat der Commit nachgezogen (`:170` — sechs Layer, sechs Kanten in Config-Form); das Handbuch (Rang 6) nicht — der DoD-Punkt „Doku-Update … das Skelett-Layout im Handbuch, falls er es nennt“ nennt es an `:276`/`:298`. Die `:276`-Stelle ist mit dem Commit wahr geworden (Runde-1 F-2 gelöst); `:298` trägt den Rest. | [`spec/architecture.md`](../../spec/architecture.md) (Rang 2) ist nachgezogen, `docs/user/benutzerhandbuch.md` (Rang 6) nicht; Slice-Plan §2 (DoD Doku-Update) | `docs/user/benutzerhandbuch.md:298` | ja — `grep -c '^  ports:$'` auf der emittierten Config → 0; ein Struktur-Sensor über die emittierte Layer-Menge würde es bestätigen (heute keiner) | Layer-Umbenennung zieht die Prosa-Terminologie nicht nach |
| F-3 | INFO | Der Pin-Kopplungs-Zahn hält den **Tag-String** und die Config-Form gegeneinander (beide Richtungen in diesem Lauf selbst gefahren), der **operative Pin** ist aber der Digest: das emittierte Fragment pinnt `Options.RunRef()` — Digest, wenn gesetzt (Kopfkommentar `internal/emit/archgate.go:33-38`). Kein Test bindet Digest↔Tag; die Bindung ruht auf der einmaligen Pull-Messung (Commit-Message; hier am lokalen Image nachgemessen — RepoDigest stimmt mit `DefaultArchDigest` überein). Versagens-Szenario: ein künftiger Pin-Sprung, der den Tag bewegt und den Digest stehen lässt, bleibt grün und bricht erst im ersten Gate-Lauf laut (unknown-key, Exit 2) — selbst-enthüllend, kein stilles Grün. | [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) | `internal/gen/archgate_test.go:233-252` · `internal/emit/archgate.go:22-25` | nein — kein Gate liest die Digest-Provenienz; das Versagens-Szenario bricht am ersten realen Gate-Lauf | Operativer Pin (Digest) ist nicht an den Tag gebunden |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Layer-/Kanten-Zählung gegen die Referenz (`lab/examples/go/.a-check.yml`, fremdes Repo, nur gelesen) | geprüft, ohne Befund — 6 Layer (`domain`, `ports_inbound`, `ports_outbound`, `app`, `driving_adapters`, `driven_adapters`), je `direction:` auf Port- und Adapter-Schichten, Port-Globs am Richtungs-Segment, 6 Kanten-Zeilen, drei bewusst abwesende Kanten mit Referenz-Grund als Kommentar — Übereinstimmung mit der emittierten Config in Namen, Form und Menge |
| C++-Zusatz-Kante `driven_adapters→ports_outbound` | geprüft, ohne Befund — die Nominal-Sprach-Referenz (`lab/examples/kotlin/.a-check.yml`, fremdes Repo, nur gelesen) trägt dieselbe Kante als Analog („the adapter names its port“); gebunden an `TestArchGateConfig_CppAllowsAdapterToPorts` (`internal/gen/cpp_test.go:273-284`), der zugleich die Go-**Abwesenheit** der Kante hält; die want-Map von `TestArchGateConfig_CppMatchesSkeleton` (:228-266) hält die split Port-Layer |
| Skelett-Vertrag (inbound-Port) | geprüft, ohne Befund — der Port trägt `Command`/`Result` und das `Greet`-Interface (`internal/gen/golang.go:249-276`), der Handler implementiert strukturell (`Handle(cmd inbound.Command) (inbound.Result, error)`, `:318`), der treibende Adapter hält `inbound.Greet` und nie die Slice (`:364-396`), der getriebene Adapter importiert nur die Domain (strukturelle Erfüllung, `:399-424`); `command.go`/`result.go` sind weg — die want-Maps beider Sprachen halten den File-Set in beide Richtungen (neue oder fehlende Datei färbt) |
| Compile-Nachweis | selbst gefahren — `TestGenerate_GoHexslice_Compiles` im grünen `make test-go`-Lauf (alle Pakete ok) |
| Rot-Probe (a) — alte direction-lose Ports-Schicht | selbst gefahren (Mutation in `internal/gen/golang.go`, Wegwerf-Änderung, zurückgenommen): `TestArchGateConfig_MatchesSkeleton` rot — „fällt unter Schicht „ports“, want „ports_inbound““ für alle drei Port-Dateien (`archgate_test.go:112`); derselbe Lauf meldet den Pin-Kopplungs-Test rot (Config ohne `direction: inbound`) — beide Zähne binden an dieselbe Form |
| Rot-Probe (b1) — Kante `driving_adapters→app` hinzugefügt | selbst gefahren: „Kante driving_adapters->app ist deklariert, wird aber von keinem Import des Skeletts gebraucht (Erlaubnis auf Vorrat)“ (`archgate_test.go:174`) |
| Rot-Probe (b2) — Kante `driving_adapters→ports_inbound` entfernt | selbst gefahren: „cli.go importiert … (ports_inbound), aber die Config deklariert keine Kante driving_adapters->ports_inbound — das emittierte Skelett waere im eigenen Gate rot“ (`archgate_test.go:168`) — der falsche-Kanten-Test fällt in **beiden** Richtungen |
| Rot-Probe (c) — Pin auf v0.15.0 | selbst gefahren: „DefaultArchImage = „ghcr.io/pt9912/a-check:v0.15.0“, want die Fassung, die direction auf Port-Schichten dekodiert“ (`archgate_test.go:235`) |
| Pin-Digest | selbst gemessen — `docker image inspect ghcr.io/pt9912/a-check:v0.20.0` → RepoDigest `sha256:e8208764b119c606c92f82722813386277a65b12812d23b6107ea7a14dc25da1` = `DefaultArchDigest` |
| Grün-Baseline | selbst gefahren — `make test-go`, alle Pakete ok (inkl. `internal/gen`) |
| spec/architecture.md (Runde-1 F-2 und F-4) | vom Commit nachgezogen — `:170` trägt sechs Layer/sechs Kanten in Config-Form samt C++-Zusatz-Kante, die C++-Prosa steht unter dem neuen Schicht-Namen |
| Runde-1 F-3 (Ordner-Segmente an die Rollen-Konstanten gebunden) | unverändert offen — Folgepflicht 6 des ADR, nicht Gegenstand dieses Diffs |
| Runde-1 F-6 (ADR-Index-Zeile doppelt) | unverändert offen — nicht Gegenstand dieses Diffs; Folgepflicht 2 bindet den ADR-0009-Index-Zusatz an den Accept-Übergang, der steht aus (kein vorzeitiger Zusatz) |
| Fremd-Kennungen | `git show 34c9e446 \| grep -c 'hexslice-architecture'` → 0 |
| Commit-Zuschnitt | geprüft, ohne Befund — ein Arbeits-Commit mit Kennung (`ADR-0060`); die Plan-Änderung ist die deklarierte Verfeinerung 3 (Übergabe an Review/Planner), die spec-Änderung ist Folgepflicht 3; keine Berührung von `AGENTS.md`/`harness/conventions*` (§3.8) |
| `make e2e-abdeckung` | selbst regeneriert — „unverändert … (19 Stufen, 19 Deklarationen)“; `harness/tools/full-smoke.sh` ist vom Commit nicht berührt |
| `make docs-check` | selbst gefahren — 1750 Datei(en) geprüft, 0 Befund(e) (Baum ohne diesen Report; der Gesamt-Lauf über dem Baum mit diesem Report ist Gegenstand des nächsten `make gates`) |
| `make gates` EXIT 0 · `make full-smoke` EXIT 0 (real, beide hexslice-Stufen unter dem v0.20.0-Image) | vom Auftraggeber-Kontext übernommen, in diesem Lauf nicht wiederholt (Call-Budget) |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** ADR-Festlegungen konkurrieren um dieselbe Struktur · Layer-Umbenennung zieht die Prosa-Terminologie nicht nach · operativer Pin (Digest) ist nicht an den Tag gebunden

## Verdikt

**Merge-blockierend:** ja — F-1, am **Accept-Übergang** von [`ADR-0060`](../../docs/plan/adr/0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md), nicht am Code-Diff. Der emittierte Stand ist die konsistente Hälfte: Er deckt die Referenz exakt (Layer für Layer, Kante für Kante, gemessen), die Skelett- und Pin-Zähne binden (alle vier Rot-Proben in diesem Lauf selbst gefahren und aus dem richtigen Grund rot). Konkurrierend ist der ADR-Text: Festlegung 4 („fünf Kanten“ über **einer** Ports-Schicht) und Festlegung 3 (Ports-Schicht ohne Richtung, Glob am `ports`-Segment, `port-direction-mismatch` inert) sind am Referenz-Stand **vor** der Anpassung geschnitten; die Emission vollzieht, was die Referenz seit v0.20.0 trägt — die Form, die der ADR als Option C verworfen hatte, deren Ablehnungs-Begründung (der portScope-Strich) die Referenz-Anpassung selbst aufgelöst hat. Da der Acceptance-Trigger einen Report ohne blockierenden Befund verlangt, ist der Accept blockiert, bis der Architect Festlegungen 3 und 4 gegen die v0.20.0-Referenz neu schneidet — die Option-C-Zeile in §Verglichene Alternativen mit ihnen. Der Re-Schnitt ist vor dem Accept legal (Proposed, kein `Supersedes` nötig); er zieht keinen weiteren ADR in den Re-Schnitt — ADR-0009 bindet bis zum Accept unverändert fort, und die Abweichung der Emission von ihm ist dieselbe, die ADR-0060 als Teil-Ablösung trägt.

**Ist der Weg zur Verifikation und Closure frei?** Für den **Slice**: ja. Kein neuer blockierender Code-Befund; die Skelett-, Config- und Pin-Zähne sind belegt, der Compile-Nachweis steht im grünen Lauf, die Spec ist nachgezogen, die Runde-1-Befunde F-2/F-4 sind aufgelöst, und der Festlegung-4-Konflikt ist im Plan §3 Verfeinerung 3 als Übergabe deklariert — der Verifier findet ihn am Plan-Text vor und kann ihn aus diesem Report beantwortet lesen. Für den **Accept** von ADR-0060: nein — er bleibt an F-1 hängen bis zum Architect-Re-Schnitt der Festlegungen 3/4.

**Übergabe:** F-1 geht an den Architect (Accept-Übergang blockiert bis zum Re-Schnitt; der Konflikt-Pfad nach Modul 8 läuft hier über den Architect, nicht über eine Herabstufung — der Implementer-Widerspruch „die Referenz trägt es“ ist mit der Messung dieses Laufs **bestätigt**, nicht abgewiesen). F-2 geht an den Implementer (Handbuch-Nachzug `:298`, derselbe Zug wie der Spec-Nachzug). F-3 ist INFO. Die **Finding-Klassen** gehen in die Slice-Closure §7 und von dort in den Zähler — die Klasse von F-2 trägt denselben Namen wie die Runde-1-Zeile (`Layer-Umbenennung zieht die Prosa-Terminologie nicht nach`, zweites Auftreten), die Closure entscheidet über das Hochschreiben. Dieser Report selbst ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen, und muss es nicht. Er ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).