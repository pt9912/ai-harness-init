# Slice slice-062: Welche Modul-15-Regeln der emittierte Harness bekommt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-09](../welle-09-modul-15-konformitaet.md) — die **Tool**-Ebene,
Entscheidungsteil. Die Emission liefert `slice-063`; sie ist benannt, nicht geschnitten.

**Bezug:**
[`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
emittierte Durchsetzungs-Mechanik — **der Träger** der einen Emission, gemessen in §3),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte Doc-Gate-Baseline — geprüft und **nicht** der Träger, §3),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (das
Abhängigkeitsbudget, in dem die Emission bleibt: `bash + git + docker`, awk als POSIX-Basis),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) und
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (die Zusage
*out-of-the-box grün*, an der die **Form** von Block 4 hängt — §6),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (der
emittierte Stand ist gate-sicher),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(Setzung 1: die Entscheidung geht dem Slice voraus; Setzung 2/3: der Fußabdruck),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (die Phasen-Trennung, aus der die Begründung
der ersten Nicht-Emission stammt),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (die Erfassungs-Policy des Dogfood),
[`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) (die permanente Grenze der
Token-Achse),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (das Gefäß folgt dem Gegenstand —
der Grund, warum die Trigger **nicht** ins Lastenheft wandern),
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) (der Auflösungs-Trigger zweier
Zellen — verwiesen, nicht abgeschrieben).
Regelwerk-Quellen: `.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` (die vier
Regelblöcke) und `.harness/baseline/v3.5.2/regelwerk/modul-13-quality-gates.md`
(§Hard Rule Doku-Disziplin, die der emittierte Check durchsetzt).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-08-16.

---

## 1. Ziel

**Die Tool-Spalte der Modul-15-Matrix bekommt ihre vier Werte — je Nicht-Emission mit
beobachtbarem Auflösungs-Trigger, und mit dem Fußabdruck am Lastenheft, den der eine emittierte
Mechanismus im Adopter-Vertrag verlangt.**

**Die Entscheidung ist gefallen und geht diesem Slice voraus** (Auftraggeber, 2026-08-16;
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
Setzung 1). Dieser Slice **trifft** sie nicht — er schreibt sie in die zwei Gefäße, die sie
tragen können: eine **ADR** für Geltungsbereich, Begründung und Trigger, und einen **CR-Fußabdruck**
am Lastenheft für den Teil, der den Adopter-Vertrag bewegt. Was er zusätzlich leistet, ist die
Grenze: er benennt, was die ADR noch zu entscheiden hat, statt es unter die Entscheidung zu
schieben.

**Welche Zellen er füllt.** Die Matrix selbst entsteht in `welle-09-results.md`; hier stehen nur
die Zellen und der Wert, den dieser Slice ihnen festlegt:

| Zelle der Closure-Matrix | Wert, den dieser Slice festlegt |
|---|---|
| *Span-/Audit-Attribut-Regeln × Tool* (Block 1) — **zwei Abweichungen in einer Zelle**, darum je Abweichung ein Wert ([welle-09](../welle-09-modul-15-konformitaet.md) §3): (a) die **Erfassung**, (b) die **Rollen-Typen** unter `.claude/agents/`, denn `agent.role` ist ein Pflichtfeld genau dieses Blocks | (a) **nicht emittiert** mit Trigger T1 · (b) **nicht emittiert** mit Trigger T3 (§3) |
| *Token-Attribution × Tool* (Block 2) | **nicht emittiert**; Trigger ist der von [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) |
| *Cache-Counter × Tool* (Block 3) | **nicht emittiert**; **derselbe** Trigger, kein zweiter |
| *Doku-Konsistenz-Drift × Tool* (Block 4) | **emittiert** — der Wert ist hier **festgelegt**, nicht belegt: `emittiert` verlangt nach [welle-09](../welle-09-modul-15-konformitaet.md) §3 *im Ziel vorhanden **und dort rot gesehen***, und beide Richtungen liefert erst `slice-063` |

Die Frage, die [slice-060](../done/slice-060-rollen-achse.md) ausdrücklich hierher übergeben hat
(Frage B: gehen die Rollen-Typen in die Ziel-Repos mit?), ist damit beantwortet — **nein**, mit
Trigger. Ihr einziger belegter Zweck ist die Rollen-Achse der Telemetrie; ohne Erfassung im Ziel
hat sie dort keinen Abnehmer.

## 2. Definition of Done

- [ ] **(1) Eine ADR trägt die vier Werte der Tool-Spalte — Accepted, mit je einem beobachtbaren
  Auflösungs-Trigger je Nicht-Emission und mit der Form von Block 4.** Für jede der drei
  Nicht-Emissionen stehen die drei Angaben, die
  [welle-09](../welle-09-modul-15-konformitaet.md) §3 für den Wert *nicht emittiert* verlangt:
  **Geltungsbereich · Begründung · Auflösungs-Trigger**, und der Trigger ist eine am Bestand
  ablesbare Schwelle, keine Absicht (T1–T3 in §3). Der Trigger der Blöcke 2 und 3 wird
  **verwiesen**, nicht wiederholt: er ist der von
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md), und eine zweite Fassung wäre die
  zweite Wahrheit, die driftet. Für Block 4 entscheidet die ADR, ob der emittierte Check ein
  **Gate** im `make gates` des Ziels oder ein **Bericht** daneben ist — samt der Folge für den
  Beleg (ein Bericht färbt nichts rot und kann den Matrix-Wert *emittiert* nach der Definition
  in §3 der Welle nicht verdienen) und samt der Messung, die diese Frage aufwirft (§6).
  Ebenfalls in der ADR: die zwei Alternativen, die die Messung stellt — der bereits emittierte
  `doc-targets`-Weg und die konditionale Emission nach dem
  [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)-Muster
  (§6) —, und die Folgepflicht, dass `slice-063` nichts emittiert, was der Dogfood nicht selbst
  fährt.
- [ ] **(2) Der CR-Fußabdruck liegt als eigener Commit, und er bewegt genau eine Anforderung.**
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  Setzung 2/3: **ein** Commit, der **ausschließlich**
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) ändert (ablesbar an
  `git show --stat`), **vor** dem `open → in-progress`-Move von `slice-063`. Inhalt: Version-Bump
  (heute 0.18.0 → 0.19.0 — maßgeblich ist die Regel, nicht die Zahl: eine funktionale
  Anforderung wächst um eine emittierte Artefakt-Klasse, das ist Minor), **eine** Zeile in §7
  Historie mit dem annehmenden Akt in der Verweis-Spalte (`Nutzer-Entscheidung 2026-08-16`) und
  dem Anlass in der Änderungs-Spalte, und die geänderte Anforderung:
  [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) —
  gemessen als Träger in §3, nicht geraten. **Die drei Nicht-Emissionen gehen NICHT als negative
  Abnahmekriterien mit** (Begründung in §3); ihr Ort ist die ADR aus (1).
- [ ] `make gates` grün.
- [ ] Doku-Update für den berührten öffentlichen Vertrag — er ist berührt, und der CR aus (2)
  ist genau dieses Update.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Wer was schreibt

Vier schreibende Instanzen, getrennte Commits — die Trennung ist an `git log --stat` ablesbar,
nicht an der Prosa.

| Rolle | Artefakt | Commit-Disziplin |
|---|---|---|
| **Planner** | diese Datei; der Nachzug in [welle-09](../welle-09-modul-15-konformitaet.md) §4 und in der [Roadmap](../in-progress/roadmap.md) | mit dem Schnitt |
| **Architect** | die ADR aus DoD (1) und der ADR-Index | **eigener** Commit, nur Artefakte der schreibenden Rolle, Rolle in der Message ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| **Auftraggeber (CR)** | [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **eigener** Commit, **nur** diese Datei, **vor** dem Move von `slice-063` |
| **Implementer** (`slice-063`) | Emitter, Vorlagen, `make full-smoke`-Zahn | berührt **weder** ADR **noch** Lastenheft |

**Weder die ADR noch dieser Slice ändern `LH-*` — sie referenzieren nur**
([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler),
adoptierter Wortlaut). Die Reihenfolge ist deshalb **ADR vor CR**, nicht umgekehrt: was die
geänderte Anforderung zusagt, hängt an der Form, die die ADR für Block 4 entscheidet.

### Welche `LH-*` die Entscheidung berührt — gemessen, nicht geraten

Zwei Anforderungen standen zur Wahl; gelesen wurden beide im **Volltext** — ihre Zeilenbereiche
nennt `grep -n '^### LH-' spec/lastenheft.md`.

- [`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
  **trägt den Check nicht.** Sie nennt genau zwei Artefakte (`.d-check.yml`, `d-check.mk`) und
  bindet weitere Gate-Tools an **eine Form**: je Tool sein eigenes `--print-mk`-Fragment
  ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)).
  Ein bash+awk-Check hat kein `--print-mk` und ist kein d-check-Modul. Die emittierte
  Modul-Liste von `.d-check.yml` ist ein **anderer** Schnitt und liegt bei
  [slice-073](slice-073-emittierte-doc-gate-module.md).
- [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
  **trägt ihn.** Sie zählt die emittierte Durchsetzungs-**Mechanik** auf (Stop-Hook,
  Gate-Nachweis-Mechanik, `.claude/settings.json`, `CLAUDE.md`, Reviewer-Skill, Command-Guard),
  bezieht ihre Quelle aus dem Tool selbst
  ([`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md)) und trägt in ihren
  Akzeptanzkriterien genau das Budget, in dem der Check bleibt: **bash + awk**, kein node/jq/OCI,
  und *„über `bash + git + docker` hinaus nichts"*. Der Konsistenz-Check ist dieselbe Klasse —
  tool-eigene, ausführbare Durchsetzung im Ziel. **Weil er die Aufzählung erweitert statt eine
  bestehende Bedingung zu erfüllen, ist er ein CR** und nicht die Anhebung, als die
  [slice-073](slice-073-emittierte-doc-gate-module.md) ihre Modul-Liste einordnet.
- [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) ist **erfüllt,
  nicht geändert** (awk ist POSIX-Basis, Docker bleibt außen vor);
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ist
  die Regel, die der Check im Ziel erstmals **mechanisch** durchsetzt, und zugleich die
  Gegenkraft, an der die Form von Block 4 hängt (§6).

**Warum die drei Nicht-Emissionen NICHT als negative Abnahmekriterien ins Lastenheft gehen.**
Jede von ihnen trägt einen Auflösungs-Trigger; das Lastenheft ist das **vertraglich
abnahmebindende** Stratum, und eine Vertragsklausel auf Zeit ist ein Widerspruch in sich. Das
Gefäß folgt dem Gegenstand ([`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md)): eine
begründete, mit Trigger versehene Nicht-Umsetzung gehört in die ADR, die auch Trigger führen
darf. Der CR-Fußabdruck bleibt dadurch das, was
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
beschreibt: Bump, eine Historie-Zeile, die geänderte Anforderung.

### Die drei Auflösungs-Trigger

Jeder ist eine **Schwelle am Bestand**, keine Absicht — und jeder ist ohne Rückfrage beurteilbar.

**T1 — Block 1, Erfassung.** *Die Erfassung dieses Repos läuft ohne Kompilat:* `make span-check`
ist grün, ohne dass zuvor `make span-emit-build` gelaufen ist und ohne dass im gitignorierten
Zustandsbereich ein Binär liegt. Dann trägt die Erfassung dasselbe Budget wie der Command-Guard
([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren): bash+awk,
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)), und der Grund
der Nicht-Emission fällt: ein **sprachloses** Ziel bekäme keinen Code mehr, bevor seine eigene
Doc-Chain und sein Sprach-ADR ihn rechtfertigen — die Inversion, gegen die
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) entschieden hat.

**T2 — Blöcke 2 und 3.** Der Trigger ist der von
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md), und es gibt **keinen zweiten**.
Beide Blöcke hängen am selben Eingang wie die Repo-Seite: solange kein `Agent`-Span Zähler
trägt, trüge auch ein emittierter Bericht nie eine Zahl. **Ein zweiter, eigener Trigger wäre die
Stelle, an der die zwei Ebenen auseinanderlaufen** — darum steht hier der Verweis und nicht die
Schwelle. **Und der zweite Ausgang gehört mitgedacht:** fällt die Messung hinter
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) negativ aus und wird der Carveout in
eine Folge-ADR überführt, wechseln **diese beiden Zellen mit** — von *nicht emittiert* auf
**ADR-Verdikt**, denn permanent ist eine Eigenschaft der Abweichung, nicht der Ebene.

**T3 — die Rollen-Typen.** *Block 1 wird emittiert*, ablesbar am Ziel und nicht an einem
Vorsatz: ein frisch gebootstrapptes Ziel schreibt bei einem Tool-Call einen Span — die Form von
Beleg, die `make full-smoke` für die Tool-Ebene führt. Erst dann hat die Rollen-Achse im Ziel
einen Abnehmer, und erst dann ist zu entscheiden, ob die Typen aus `.claude/agents/` mitgehen.

### Dateien

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`docs/plan/adr/`](../../adr/) | neu | die ADR aus DoD (1) samt Index-Eintrag; Architect-Commit |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | update | der CR-Fußabdruck aus DoD (2); eigener Commit, nur diese Datei |
| `internal/emit/**`, `harness/tools/full-smoke.sh`, `test/mutations/` | **unverändert** | die Emission und ihr Zahn sind `slice-063`. Ein Slice, der entscheidet **und** emittiert, hätte den Beleg im selben Lauf wie die Entscheidung — genau die Trennung, die [welle-09](../welle-09-modul-15-konformitaet.md) mit *Erprobung → Entscheidung → Emission* zieht |

## 4. Trigger

**`open` → `next`:** die Auftraggeber-Entscheidung liegt vor (2026-08-16). Sie ist die
Eintritts-Bedingung, kein anderer Slice.

**Zwei Vorbedingungen, die dieser Slice ausdrücklich NICHT hat** — beide Fragen stellt
[welle-09](../welle-09-modul-15-konformitaet.md) an den Schnitt, hier stehen die Antworten:

1. **`slice-061` (Doku-Konsistenz im Repo) ist keine Eintritts-Bedingung für die
   *Entscheidung*** — wohl aber für die *Emission*. Die Erprobungs-Regel der Welle (*„ein
   Mechanismus, den wir ungeprüft emittieren, verstößt gegen die eigene Regel"*) bindet
   `slice-063`; die ADR trägt sie als Folgepflicht. Andernfalls wartete ein lieferbarer Slice auf
   den nächsten, was Modul 5 §Ziel-Form ausschließt.
2. **Die Korrektur von
   [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) ist keine
   Eintritts-Bedingung.** Die Begründung der ADR ruht auf dem **vendored Vorlagen-Wortlaut**
   (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, der die
   Baseline-Aussage auf Verzeichniskonvention, Lifecycle-Regeln, Carveout-Disziplin und
   ID-Schema eingrenzt) — der primären Quelle, netzlos zitierbar —, **nicht** auf unserer
   überzogenen Fassung. Damit ist die ADR von der Korrektur unabhängig; der Nebenbefund selbst
   bleibt bei `slice-064`, und er ist hier benannt statt vorausgesetzt.

**`next` → `in-progress`:** WIP-Limit — kein anderer Slice in `in-progress/`.

Rückführungen:

- `in-progress` → `next`: falls die ADR die Form von Block 4 nur zusammen mit einer Bereinigung
  der emittierten Behauptungs-Tabellen entscheiden kann (§6) und der CR dadurch mehr als eine
  Anforderung bewegt. Dann sind Entscheidung und Vertragsänderung zwei Schnitte, und der zweite
  hat eine eigene Messung.
- `in-progress` → `open`: falls
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) währenddessen negativ entschieden
  wird. Dann tragen zwei Zellen **ADR-Verdikt** statt *nicht emittiert*, und das ist eine andere
  ADR-Frage als die hier gestellte.

## 5. Closure-Trigger

DoD vollständig; die ADR **Accepted** nach Review (Modul 10) mit ausgestelltem Verdikt;
Verifikation bestätigt (Modul 11); `make gates` grün; der CR-Commit isoliert und vor dem
Move von `slice-063` — nachprüfbar mit
`git log --stat -- spec/lastenheft.md`; `git mv` nach `done/` (eigener Move-Commit);
Closure-Notiz mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Bericht oder Gate ist offen, und die Messung sagt, warum die ADR es entscheidet und nicht
  dieser Slice.** Der emittierte Bestand behauptet heute selbst Ziele, die er nicht hat —
  gemessen an den zwei Vorlagen, die ein Ziel bei Init bekommt (beide Kommandos über dieselben
  zwei Dateien `.harness/baseline/v3.5.2/templates/AGENTS.template.md` und
  `.harness/baseline/v3.5.2/templates/harness/README.template.md`:
  `grep -cE '^\|.*make ' …` → **7 + 8 = 15 Zeilen** in den beiden Gate-Tabellen,
  `grep -hoE 'make [a-z][a-z0-9-]*' … | sort -u` → **9 verschiedene Ziele**). Gegen das Ziel-Inventar
  gehalten, das die Emissions-Quellen erzeugen (`gates`, `help`, `record-gates`,
  `baseline-verify`, `docs-check` samt der `doc-*`-Advisories, mit `--lang go` zusätzlich
  `lint`/`build`/`test`), bleiben **fünf** Behauptungen ohne Ziel: `arch-check`,
  `coverage-gate`, `coverage-gate-critical`, `ci`, `fullbuild` — `arch-check` auch dann, wenn ein
  Arch-Gate emittiert wird, denn das Target heißt dort `a-check`. **Als Gate im `make gates` des
  Ziels startet der Check damit rot** und bricht die Zusage aus
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) /
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6);
  **als Bericht** kann die Zelle den Wert *emittiert* nach
  [welle-09](../welle-09-modul-15-konformitaet.md) §3 nicht verdienen (ein Bericht wird nie rot
  gesehen). Dagegen steht
  [`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed):
  *laut falsch schlägt leise falsch* — und diese Default-Regel ist selbst in einer ADR
  entschieden worden. Ein Kollisions-Fall zwischen einer Vertragszusage und einer Default-Regel
  ist eine Architektur-Frage, kein Schnitt-Detail; darum steht sie in DoD (1) und nicht als
  Planner-Setzung hier. **Die Zahl ist aus den Emissions-Quellen gerechnet, nicht an einem
  frischen Ziel gemessen** — die ADR misst sie an einem gebootstrappten tmp-Ziel nach, bevor sie
  auf ihr aufbaut.
- **Der Mechanismus existiert im Ziel schon einmal, und zwei Fassungen derselben Prüfung
  driften.** Das tool-generierte `d-check.mk` bringt `make doc-targets` mit — *Deklarations-
  Konsistenz Doku↔Build-Targets*, hermetisch, netzlos, ohne Range —, weil es verbatim aus
  `--print-mk` des gepinnten Images stammt (dieselbe Fassung wie im Dogfood-[`d-check.mk`](../../../../d-check.mk)).
  Es ist im Ziel vorhanden und an nichts gehängt. Die ADR schuldet damit den Vergleich, den
  [welle-09](../welle-09-modul-15-konformitaet.md) §4 als Frage (b) gestellt hat: bash+awk als
  neues Artefakt gegen eine Zeile in einer Datei, die es schon gibt. Fällt der Vergleich gegen
  die getroffene Wahl aus, ist das eine **neue Auftraggeber-Entscheidung**
  ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)),
  keine Slice-Entscheidung.
- **„Gar nicht" ist nicht die einzige Alternative zu „immer" — auch das schuldet die ADR.**
  [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) emittiert
  sein Gate **konditional**: nur ein Ziel, dessen Layout einen Prüfbereich trägt, bekommt es. Auf
  die Erfassung übertragen hieße das: ein Ziel **mit** Sprachskelett bekäme sie, ein sprachloses
  nicht. Die Begründung der Nicht-Emission spricht ausdrücklich vom **sprachlosen** Ziel; die
  ADR hat die konditionale Variante deshalb zu entkräften statt zu übergehen.
- **Der Beleg für Block 4 verlangt beide Richtungen, und keine davon liefert dieser Slice.**
  [welle-09](../welle-09-modul-15-konformitaet.md) §3: ein emittierter Mechanismus, der nie
  feuert, lässt `make full-smoke` ebenfalls grün. `slice-063` schuldet daher (a) das frisch
  gebootstrappte Ziel out-of-the-box grün **und** (b) einen im Ziel **rot gesehenen** Drift —
  eine behauptete Zeile, die kein Target hat, und die Rücknahme danach.
- **Nicht in diesem Slice:** die Emission selbst (`slice-063`), die Repo-Seite von Block 4
  (`slice-061`), die emittierte Modul-Liste von `.d-check.yml`
  ([slice-073](slice-073-emittierte-doc-gate-module.md) — sie nimmt `targets` ausdrücklich
  nicht), die Rechnung hinter [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md), und
  jede Migration für bereits gebootstrappte Ziele: die emittierten Konfigurationen sind
  *skip-if-present* ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)), ein bestehendes Ziel
  bekommt nichts davon.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `docs/plan/adr/` und
`spec/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
