# Slice slice-mutate-workflow-laeuft-in-parallelen-shards: Der `mutate`-Nacht-Workflow läuft als Matrix aus parallelen Shard-Jobs statt eines Einzel-Jobs

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD —
der reale grüne Matrix-Lauf ist Teil der DoD selbst, kein repo-weiter Beleg darüber hinaus.

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 (`make mutate` ist der Sensor zu dieser
Hard Rule; dieser Slice ändert nur seinen CI-**Träger**, nicht die Prüf-Semantik von
`harness/tools/mutate.sh`) · [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
(**ein** Workflow-File, keine zweite Gate-/Sensor-Definition — dieselbe „eine Quelle je
Check"-Disziplin, die `mutate.yml` selbst in seinem Kopfkommentar für die Trennung von
`upstream-drift.yml` zitiert). Keine `LH-*`-ID bindet diese CI-Betriebsfrage direkt; die
Reproduzierbarkeits-Disziplin, die `MUTATE_JOBS` bereits führt (fester Default statt `nproc`,
`harness/tools/mutate.sh` Kommentar um Zeile 199–202: „zwei Läufe auf zwei Maschinen in ihrer
Wanduhr nicht mehr vergleichbar"), gilt für die Shard-Zuteilung analog, ohne dass die Anforderung
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) wörtlich diesen Fall
beschreibt.

**Berührte Spec-Stellen:** —

**Verantwortlich:** — *(WIP-Limit Implementer ist aktuell durch
`slice-mutate-form-match-epipe-verwirft-treffer` in `in-progress/` belegt, Review läuft; dieser
Plan liegt darum direkt in `next/` und wandert nach dessen Abschluss weiter)*.

**Autor:** Planner. **Datum:** 2026-09-28.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `.github/workflows/mutate.yml` bekommt **einen** `mutate`-Job mit `strategy.matrix`
statt eines Einzel-Jobs; jeder Matrix-Job (Shard) fährt eine deterministisch, ohne `nproc`- oder
Laufzeit-Abhängigkeit zugeteilte, disjunkte Teilmenge der 484 Fall-Dateien
(`ls test/mutations/*.sh | wc -l` → 484) über `MUTATE_CASES`, `fail-fast: false`, damit die
gemessene Wall-Clock-Zeit eines vollen naechtlichen Laufs sinkt — heute ~1h45m–2h auf einer VM mit
intern `JOBS=4` (Kopfkommentar `mutate.yml`, gemessenes `49m54s` gilt einem anderen, inzwischen
verlassenen CI-Pfad und ist hier nicht die Referenz), Zielkorridor ~20–25 Minuten laut Auftrag.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Änderung der Prüf-Semantik von `harness/tools/mutate.sh` selbst** (Matcher, `failure_form()`,
  Beleg-Slot-Mechanik, `select_cases()`) — anderer Vorgang: Dieser Slice ändert, **wie viele**
  Runner den unveränderten Fall-Satz fahren, nicht **was** ein Fall prüft oder wie ein Treffer
  gewertet wird. Eine laufende Nachbar-Arbeit an genau dieser Datei
  (`slice-mutate-form-match-epipe-verwirft-treffer`, aktuell in Review) bleibt davon unberührt;
  dieser Slice baut auf ihrem Ergebnis auf, ohne es zu wiederholen.
- **Verschiebung von `mutate` in den Pro-Push-Gate-Pfad** (`make gates`/`ci.yml`) — Bestand bleibt
  bewusst stehen: Die Klassifikation der Baseline ordnet Mutationstests der Stufe
  **Post-integration** zu (`grundlagen-klassifikation.md` §Klassifikation), und der
  Kopfkommentar von `mutate.yml` begründet die Trennung vom Push-Pfad bereits mit einer echten
  Kostenmessung (`49m54s` von `49m58s` eines Pushes). Dieser Slice ändert **wie parallel**
  innerhalb des Post-integration-Laufs gefahren wird, nicht **wann**.
- **Der Beleg-Slot-Mechanismus** ([`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)) — Bestand bleibt stehen: Ein CI-Runner hält
  `.harness/state/` nicht über Läufe hinweg (frischer Checkout je Job), der Slot wirkt in CI
  schon heute nie; Sharding über `MUTATE_CASES` macht aus jedem Shard ohnehin einen **Teillauf**
  im Sinne von `harness/sensors/mutate.md` §Teillauf, der den Slot per Definition nie berührt —
  dieselbe Nicht-Berührung wie beim heutigen Voll-Lauf, nur jetzt strukturell statt zufällig.
- **Mehrere Workflow-Dateien statt einer Matrix** (`mutate.yml`, `mutate2.yml`, …) — wäre eine
  zweite Gate-/Sensor-Definition und driftet bei jeder neuen Fall-Datei zwischen mehreren Kopien;
  `harness/README.md` §Sensors trägt genau eine Zeile für `make mutate`, und das soll so bleiben
  (Begründung s. §Bezug,
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)-Geist).
- **Eine Reduktion der 484 Fall-Dateien selbst** (Deduplizieren, Zusammenlegen teurer Fälle) —
  wäre ein anderer Vorgang mit eigener Rechtfertigungslast gegen AGENTS.md §3.6; dieser Slice
  nimmt den Fall-Bestand als gegeben.

**Kein ADR nötig** — geprüft gegen `AGENTS.md` §3.5 (Gates nicht ohne ADR lockern): `make mutate`
ist explizit **kein Gate** (`harness/sensors/mutate.md` §Bindung: „kein Gate-Versprechen"),
unverändert nach diesem Slice. §3.5 bindet Schwellen-**Senkungen** an Gates; dieser Slice senkt
keine Prüf-Schwelle und lockert keine Strenge — er verteilt denselben, unveränderten Fall-Satz auf
mehr parallele Runner. Dieselbe Einordnung wie in
`slice-mutate-form-match-epipe-verwirft-treffer` §1 für die dortige Frage.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] `.github/workflows/mutate.yml` trägt **genau einen** `mutate`-Job mit `strategy.matrix`
      (kein zweites Workflow-File), `fail-fast: false` — Begründung im Workflow-Kommentar analog
      `release.yml` `start-smoke` („ein Bruch auf einem Shard soll die Befunde der übrigen nicht
      verdecken"). Die Shard-Zuteilung ist **deterministisch** (Round-Robin über die sortierten
      Fall-Namen unter `test/mutations/*.sh`, ohne `nproc`- oder Zeit-Abhängigkeit — derselbe
      Reproduzierbarkeits-Grundsatz wie beim festen `MUTATE_JOBS`-Default), wird in einem eigenen
      Workflow-Step **vor** `make mutate` berechnet und als `MUTATE_CASES` übergeben — `
      select_cases()` bricht fail-closed ab, falls ein berechneter Name nicht existiert
      (`harness/tools/mutate.sh`), das ist der eingebaute Rot-Beleg für eine falsche Zuteilung.
      Die Shard-Zahl ist eine **benannte, im Kommentar begründete Konstante** (kein Bezug auf
      `nproc` oder eine Laufzeitgröße; Startwert 5 nach der Herleitung 484 Fälle ÷ 5 ≈ Faktor 5
      gegenüber dem heutigen Einzel-Job, siehe §Ziel — der Implementer prüft nach dem ersten
      realen Lauf, ob die gemessene Wall-Clock-Zeit den Zielkorridor trifft, und passt die
      Konstante mit Begründung an, falls nicht). **Real geprüft:** ein `workflow_dispatch`-Lauf
      zeigt N parallele Jobs, jeder färbt seine Teilmenge grün, `make ci-lint` (Teil von
      `make gates`) findet die Matrix-Syntax syntax-clean, und die Vereinigung der pro Shard
      gemeldeten Fall-Namen deckt **alle** 484 Fälle **genau einmal** ab (kein Fall doppelt, kein
      Fall fehlend) — Nachweis über die Job-Logs des Laufs (`gh run view <run-id> --log` o. ä.).
- [ ] `harness/sensors/mutate.md` §Bindung und `harness/README.md` §Sensors/§Werkzeuge geprüft,
      ob sie den heutigen Einzel-Job-Zustand explizit nennen (Fundstellen zum Zeitpunkt dieses
      Plans: `harness/sensors/mutate.md` §Bindung — „Nacht-Job `mutate.yml`" +
      `49m54s`-Einzeljob-Zahl; `harness/README.md` §Werkzeuge-Zeile zu `make mutate` nennt aktuell
      keinen Job-Zustand, nur den Vertrag — real erneut prüfen, `grep -n 'Nacht-Job\|Job ' ...`),
      und, soweit betroffen, auf den neuen Ist-Zustand nachgezogen (mehrere parallele Shards statt
      eines Jobs), mit der real gemessenen Wall-Clock-Zeit des ersten echten Matrix-Laufs
      (Kommando daneben,
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert))
      statt der überholten Einzeljob-Zahl.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis
      `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zähler wird
      gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieser Slice ist
      wellenlos, darum hier geprüft, nicht von einer Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.github/workflows/mutate.yml` | update | Matrix-Strategie, Shard-Berechnungs-Step, `fail-fast: false`, benannte Shard-Konstante (AGENTS.md §3.6, [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) |
| `harness/sensors/mutate.md` | update, falls zutreffend | §Bindung nennt aktuell den Einzel-Job und dessen Kostenmessung — Nachzug auf N parallele Shards |
| `harness/README.md` | update, falls zutreffend | §Sensors/§Werkzeuge-Zeile zu `make mutate`, falls sie den Job-Zustand explizit trägt |

**Ansatz zur Shard-Zuteilung** (ergänzt die Tabelle, kein eigenes Artefakt): Ein Workflow-Step
vor `make mutate` liest die sortierten Basenamen unter `test/mutations/*.sh` (ohne `.sh`-Endung),
verteilt sie deterministisch per Index-Modulo auf `SHARD_COUNT`-viele Gruppen (z. B.
`awk -v n=$SHARD_COUNT -v i=${{ matrix.shard }} 'NR % n == i % n'` über die sortierte Liste — der
Implementer wählt die konkrete Realisierung, die Zusicherung ist: **jeder** Fall genau einer
Gruppe, keine Gruppe leer bei 484 Fällen und 5 Shards) und setzt das Ergebnis als `MUTATE_CASES`
für den anschließenden `make mutate`-Aufruf dieses Jobs.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit Implementer ist frei — sobald
`slice-mutate-form-match-epipe-verwirft-treffer` `done/` erreicht hat (Review läuft aktuell
parallel).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die deterministische Shard-Zuteilung
  erweist sich als eigenständiges, selbst zu testendes Skript/Werkzeug (nicht als kurzer
  Workflow-Step), das eine eigene Härtung (Fehlerfälle, leere Fall-Menge, Sonderzeichen in
  Namen) braucht — dann wird die Zuteilungs-Logik ein eigener Slice, dieser bleibt die reine
  Workflow-Verdrahtung.
- `in-progress` → `open` (blockiert — Carveout?): Ein realer `workflow_dispatch`-Lauf ist aus
  Infrastruktur-Gründen (Runner-Kontingent, Registry-Zeitüberschreitung über mehrere Shards
  hinweg) wiederholt nicht auswertbar, und auch ein zweiter/dritter Versuch behebt das nicht.

## 5. Closure-Trigger

DoD vollständig **und** ein realer, beobachteter Matrix-Lauf (per `workflow_dispatch` ausgelöst
oder der nächste nächtliche `schedule`-Lauf) zeigt N grüne parallele Jobs, die zusammen alle 484
Fälle genau einmal abdecken, **und** Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- Ungleiche Fall-Kosten pro `# verify:`-Klasse
  (`grep -rn 'verify:' test/mutations/*.sh | sed -E 's/^([^:]+):[0-9]+:# verify: (.*)$/\2/' | sort | uniq -c`
  → 19 Fälle `full-smoke`, 93 `test-go`, 67 `test-bats`, 1 `smoke`, 1 `ci-lint`, Rest ohne
  explizite Angabe — Stand dieses Plans, 2026-09-28) können bei reinem Index-Modulo-Round-Robin
  einzelne Shards ungleich belasten, wenn sich
  teure Fälle zufällig in einer Gruppe häufen, statt die Wall-Clock-Zeit gleichmäßig zu senken. —
  **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: →
  BEO-NNN im Register>
- Der gewählte Startwert der Shard-Konstante (5) trifft den Zielkorridor ~20–25 Minuten
  möglicherweise nicht beim ersten Versuch (Overhead durch Checkout/Image-Pull je Shard ist nicht
  im Vorfeld gemessen). — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund |
  weiter offen: → BEO-NNN im Register>
- Erhöhte Actions-Minuten (`gh repo view --json visibility` → `PUBLIC`, gemessen 2026-09-28, damit
  für dieses Repo kostenfrei) sind eine Randbedingung, die bei einem künftigen Wechsel auf ein
  privates Repo neu zu bewerten wäre — heute keine Blockade. — **Ausgang:** <eingetreten: CO-NNN /
  slice-<Kennung> | entfallen: Grund | weiter offen: → BEO-NNN im Register>
- Die Zuteilungs-Berechnung liest die Fall-Liste zum Checkout-Zeitpunkt jedes Jobs; landet
  zwischen dem Anlegen der Matrix (`SHARD_COUNT` als statischer Wert im YAML) und dem Lauf ein
  Commit, der Fall-Dateien hinzufügt/entfernt, bleibt die Zuteilung innerhalb **eines**
  Workflow-Laufs konsistent (derselbe Checkout für alle Shards desselben Runs), nur über
  Läufe hinweg ändert sich die Verteilung — kein Risiko für die Vollständigkeits-Zusicherung
  eines einzelnen Laufs, aber erwähnenswert für die Interpretation historischer Laufzeiten. —
  **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: →
  BEO-NNN im Register>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg
  `evidence/slice-mutate-workflow-laeuft-in-parallelen-shards.md` | `evidence/slice-…md` in
  `BEO-<KUERZEL>/<slug>/` ergänzt — Zähler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Die Modus-Deklaration
(`harness/conventions.md` §Modus-Deklaration pro Sub-Area) führt keine eigene Sub-Area für
`.github/workflows/`; der Slice berührt damit `* (gesamtes Repo)`, Kürzel `ALL`. Die Schwelle ist
für diese Sub-Area bereits deklariert erfüllt, keine Ausdifferenzierung nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register (`docs/plan/planning/observations/`)
durchgegangen (`grep -rli 'mutate' docs/plan/planning/observations/*/*/observation.md
docs/plan/planning/observations/*/*/state.md`, 2026-09-28). Treffer betreffen ausschließlich
mutate.sh-**interne** Fragen (u. a. `mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`,
`mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`, `sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt`)
— keiner davon adressiert die CI-**Parallelisierung** des Nacht-Workflows selbst. Für die konkrete
Frage dieses Slice (Matrix-Sharding eines CI-Workflows): **keine Treffer.**

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF (`ALL`) — der Hinweis genügt,
kein Begründungsblock nötig.
