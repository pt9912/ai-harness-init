# Slice slice-mutations-fall-entdeckt-den-vendored-tag: Ein Mutations-Fall entdeckt das Tag-Verzeichnis der Baseline, statt es zu nennen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Welle:** ohne Welle. Sein Closure-Trigger würde die eigene DoD abschreiben — das *Mehr*, an dem
sich eine Welle entscheidet, wäre hier ein repo-weiter Beleg über die DoD hinaus, und den trägt der
Slice selbst (`make gates` und `make mutate` stehen in seiner DoD). Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht; nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind der Mutations-Treiber und die Fall-Dateien
**dieses** Repos. Was ein emittiertes Repo an Mutations-Fällen bekommt, entscheidet der Slice, der
die Tool-Ebene entscheidet — nicht dieser (§1).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Sensor, der nicht mehr anläuft, ist die schärfste Form der behaupteten Deckung),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (derselbe Lauf über jedem
Baseline-Stand, ohne Nachzug von Hand),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(Tag-Politik: **ein Tag zur Zeit**, und der Tag-String steht in `BASELINE_TAG` und sonst nirgends in
der Mechanik),
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(die Gegenprobe: wo der Tag eine **Messung** datiert, gehört er genannt — Abgrenzung in §1),
[`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(die Bezugsmenge des Beleg-Schlüssels, die der Umbau nicht verschieben darf),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel, für die `make mutate` der Sensor ist),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — die fünf
Kopplungs-Absätze in §1).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist ein Nicht-Gate-Sensor
und seine Fall-Dateien. Die Erwähnung von `make mutate` in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 gilt der
Wächter-Spalte der Span-Tabelle und wird hier nicht angefasst.)

**Verantwortlich:** Implementer (pt9912). Jeder Liefergegenstand aus §3 ist Code, Test oder der
Vertragstext des Sensors, der beides fährt — kein Norm-Artefakt: Weder eine Hard Rule noch der
Adaptions-Block noch eine ADR wird berührt, die [`AGENTS.md`](../../../../AGENTS.md) §3.8 dem
Architect vorbehält. Der Anweisungssatz-Fall aus
[`ADR-0028`](../../../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
greift ebenfalls nicht: `harness/sensors/mutate.md` ist ein Sensor-Vertrag, kein
Rollen-Anweisungssatz. Trifft der Lauf auf die Rückführung aus §4 — die Bezugsmenge des
Beleg-Schlüssels aus
[`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
verschöbe sich —, ist das die Übergabe an den Architect und nicht eine Entscheidung dieses Laufs.

**Autor:** Planner. **Datum:** 2026-09-14.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein Mutations-Fall, der eine Datei im vendored Baum mutiert, **entdeckt** dessen
Tag-Verzeichnis, statt den Tag zu nennen — und eine Angabe, die ins Leere auflöst, bricht den
Treiber laut ab, mit dem Namen des Falls. `make mutate` läuft damit über jedem Baseline-Stand,
ohne dass ein Sprung ihn von Hand nachzieht.

**Der Befund, gegen den der Slice geschnitten ist.** Fünf Fälle nennen ein Tag-Verzeichnis, das
der Sprung auf `v6.8.0` ersetzt hat; die Adressen sind tot:

```sh
git grep -nE '^# files: \.harness/baseline/v[0-9]' -- test/mutations/   # 5 Zeilen, alle v6.7.2
ls .harness/baseline/                                                   # v6.8.0 — und nur der
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit dem Baum; tragend ist, dass die erste Menge nicht leer ist, während
die zweite den genannten Tag nicht führt.

**Warum entdecken und nicht nachziehen.** Der Nachzug ist dreimal gefahren worden und hat den
vierten Sprung nicht überlebt — `git log --oneline -3 -- test/mutations/244-*.sh` nennt slice-182
(*„Symlinks und die gekoppelten Mutations-Pfade ziehen"*), slice-193 (*„Adress-Nachzug über den
lebenden Bestand"*) und slice-223; der Plan von slice-223 nennt die Fälle nicht mehr, der Nachzug
lief dort schon nur im Commit. Die Politik, die den Nachzug überflüssig macht, steht längst und
wird von zwei Werkzeugen dieses Repos gefahren: `harness/tools/baseline-verify.sh` §Kopfkommentar
und `harness/tools/sessionstart-inject-regelwerk.sh` §Kopfkommentar sagen beide *„Das Verzeichnis
wird ENTDECKT, nicht geraten — so steht der Tag-String nur in `BASELINE_TAG` (Makefile) und
nirgends sonst in der Mechanik"*, und `test/courseset-fixture.bats` wendet sie auf genau denselben
Gegenstand an (`REAL="$(echo "$REPO"/.harness/baseline/*/templates)"`). Getragen wird sie von einer
Setzung, die ein **Gate** hält: `make baseline-verify` färbt bei mehr als einem `<tag>`-Verzeichnis
rot ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Die fünf Fälle sind die Ausnahme, die rät.

**Die zweite Hälfte ist eine Zusage, die ihre eigene Form nicht trifft.** Alle fünf Fälle tragen
einen Absatz *„KOPPLUNG beim Baseline-Tausch"*, der die Fehlschlag-Form benennt — der Fall ende an
seiner `tar`-Sicherung, *„daraus macht die Vollstaendigkeits-Schranke in `merge_report` einen
Befund. Laut, nicht still."* Der Lauf kommt dort nicht an: `harness/tools/mutate.sh` bildet den
Fingerabdruck über die **Vereinigung** aller `# files:`-Ziele (`mutation_targets`,
`target_fingerprint`) und bricht fail-closed ab, bevor der erste Fall läuft — die Meldung
*„Fingerabdruck der Mutations-Ziele nicht berechenbar"* nennt keine Datei. Die Zusage ist damit
nicht bloß veraltet, sondern zeigt beim Suchen an die falsche Stelle; sie wird **ersetzt**, nicht
ergänzt ([`AGENTS.md`](../../../../AGENTS.md) §3.7).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die zwei Mess-Aussagen in `internal/emit/templates.go`, die `v6.7.2` nennen** (die
  NUL-Byte-Probe und der `T=`-Block mit den drei Backtick-Proben). Sie tragen den Tag als
  **Mess-Stand**, nicht als Adresse — dort verlangt
  [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  ihn ausdrücklich, und eine Entdeckung an dieser Stelle wäre der Fehler, nicht die Abhilfe: Sie
  machte aus einer datierten Messung eine Aussage über einen Satz, gegen den niemand gemessen hat.
  Was sie brauchen, ist die **erneute Messung** gegen `v6.8.0`, die der Block selbst verlangt
  (*„JEDER Re-Baseline … muss sie gegen den NEUEN Satz erneut fahren"*) — ein anderer Gegenstand
  mit einem anderen Ausgang. Übernimmt: `slice-mess-aussagen-des-emitters-gegen-v680-messen`
  (Folge-Slice, bei der Closure in `open/` angelegt).
- **Die drei übrigen Tag-Nennungen in repo-eigenem Nicht-Markdown bleiben stehen** — sie sind
  keine Adressen, die auflösen müssen: das Referenz-Ventil `refs: [".harness/baseline/v3.5.2/…"]`
  in [`.d-check.yml`](../../../../.d-check.yml) deckt einen historisch richtigen Link in einem
  `MR`-Eintrag und ist als **nicht** aufzulösende Adresse deklariert (jedes weitere Paar wäre eine
  Senkung mit eigener ADR, [`AGENTS.md`](../../../../AGENTS.md) §3.5); der Link in
  `test/mutations/221-ignore-refs-restbreite.sh` ist ein **Payload**, den die Mutation erst
  erzeugt; die Tags in `internal/archive/scan_test.go` (`v1`, `v6.5.0`) sind Fixture-Werte, die
  nie existieren sollen. Ein Nachzug dort meldete später gegen Altbestand, den niemand entschieden
  hat.
- **Kein repo-weiter Wächter über tote Adressen in den vendored Baum.** Dieser Slice macht die
  fünf Fälle stand-unabhängig; ob ein Modul des Doku-Gates tote Adressen dorthin meldet, ist die
  Beobachtung `gate-modul-erreicht-den-vendored-baum-nicht` (3×) und liegt als
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md) geschnitten.
  Sie deckt diesen Fall ohnehin nicht — dort geht es um Inline-Code in Markdown, hier um einen
  Operanden in einer Shell-Datei.
- **Kein Produkt-Code und keine emittierte Vorlage.** Die Schicht-Abgrenzung ist beim Review sofort
  prüfbar: Der Diff berührt `harness/tools/mutate.sh`, `test/mutations/`, `test/mutate-driver.bats`
  und `harness/sensors/mutate.md` — nichts unter `internal/` oder `cmd/`.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

**Drei Liefer-Punkte** (die ersten drei); alles darunter ist pro Slice konstant.

- [ ] **(1) Die `# files:`-Angabe wird aufgelöst, nicht gelesen.** `harness/tools/mutate.sh` löst
      sie an **beiden** Stellen auf, die sie benutzen — `mutation_targets` (die Vereinigung für
      `target_fingerprint`) und `run_case` (`file_list` für `tar`/`sha256sum`) —, und die zwei
      Stellen benutzen dieselbe Funktion, nicht zwei Fassungen davon. Löst eine Angabe **nicht
      genau eine** existierende Datei auf, ist das ein Befund, der den **Fall** nennt; die Menge
      der Ziele bleibt nicht leer, ohne dass jemand es merkt
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
      **Rot gesehen**, aus dem benannten Grund: `test/mutate-driver.bats` trägt den Fall, und die
      Meldung ist gelesen, nicht nur der Exit-Code
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **(2) Kein Fall nennt einen Tag mehr, und alle fünf haben wieder Zähne.**
      `git grep -nE '^# files: \.harness/baseline/v[0-9]' -- test/mutations/` ist leer, und
      `MUTATE_FORCE=1 make mutate` läuft ohne Befund — `MUTATE_FORCE`, weil der Beleg-Übersprung aus
      [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
      sonst genau den Lauf überspringt, der die Aussage trägt. Damit ist belegt, dass jeder der
      fünf Fälle seinen benannten Wächter **gegen den `v6.8.0`-Vorlagensatz** rot färbt, nicht nur
      gegen den Satz, für den sein `sed`-Anker geschrieben wurde.
- [ ] **(3) Der neue Zahn steht als Fall, und die falsche Zusage ist weg.**
      `test/mutations/` trägt einen Fall, der die Schranke aus (1) rot färbt (`# verify: test-bats`
      gegen `test/mutate-driver.bats`) — ohne ihn wäre die Schranke selbst unbewacht, die Lage, die
      der Kopf von `mutate.sh` *„kuratiert heisst unvollstaendig"* nennt. In denselben fünf Fällen
      ist der Absatz *„KOPPLUNG beim Baseline-Tausch"* **ersetzt**: Er sagt heute eine
      Fehlschlag-Form zu (`merge_report`), die der Lauf nicht erreicht. `harness/sensors/mutate.md`
      §Grenze und der Kopf von `harness/tools/mutate.sh` nennen die Auflösungs-Form und was sie
      nicht deckt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) — der
      öffentliche Vertrag, den dieser Slice berührt, ist die **Form der `# files:`-Angabe**; sie
      ist die Schnittstelle zwischen Treiber und jedem künftigen Fall. Der Gate-Index in
      [`harness/README.md`](../../../../harness/README.md) §Werkzeuge bleibt unberührt: `make mutate`
      steht dort schon, und der Slice ändert weder Ziel noch Charakter.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo führt Wellen (`ls docs/plan/planning/*.md` nennt die offenen), also prüft sie die nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Eine Auflösungs-Funktion, von `mutation_targets` **und** `run_case` benutzt: aus der `# files:`-Angabe wird die Datei, die es gibt. Nicht genau ein Treffer → Befund mit Fall-Namen (DoD 1). Der Kopf bekommt die Auflösungs-Form und ihre Schranke; der Zähl-Befehl im Kommentar bei `belief_key` zählt danach **Muster**, nicht Pfade, und wird mitgezogen. |
| `harness/tools/mutate.sh` §BELEG | update | Die Bezugsmenge des Beleg-Schlüssels ist `isolation_key_files`, nicht `mutation_targets` ([`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)). Die Auflösung darf sie nicht verschieben; ob sie es tut, ist zu prüfen und nicht zu vermuten (§6). |
| `test/mutations/219-vorlagenhinweis-driftet-lautlos.sh`, `220-kopiere-satz-verstellt.sh`, `224-verbleib-satz-ohne-platzhalter.sh`, `244-archiv-stub-vorlage-platzhalter-umbenannt.sh`, `248-archiv-stub-vorlage-nur-eine-umbenannt.sh` | update | Je Datei zwei Adressen (`# files:`-Kopf und `sed`-Operand) auf die entdeckende Form; der Absatz *„KOPPLUNG beim Baseline-Tausch"* wird durch die geltende Zusage **ersetzt** (DoD 2 und 3). |
| `test/mutate-driver.bats` | update | Der Wächter zu DoD 1: eine Angabe, die auf **keine** und eine, die auf **mehr als eine** Datei auflöst, müssen den Treiber mit einer Meldung abbrechen lassen, die den Fall nennt. Negative-Tests; Happy-Pfad deckt der bestehende Fall-Satz. |
| `test/mutations/<neue-nr>-…sh` | neu | Der Zahn auf diesen Wächter (`# verify: test-bats`): Wird die Schranke entschärft, färbt der Fall rot. Ohne ihn wäre DoD 1 eine Zusage im Feedforward-Quadranten. |
| `harness/sensors/mutate.md` | update | §Grenze: die Auflösungs-Form und was sie **nicht** deckt — ein Fall, dessen Angabe auf die *falsche existierende* Datei auflöst, bleibt still grün (das ist `mutations-fall-zeigt-auf-falsche-datei`, §8). |

**Reihenfolge, und sie ist tragend.** Zuerst der Treiber samt Wächter und Zahn, dann die fünf
Fälle: Andersherum liefe `make mutate` nach dem ersten Schritt zwar wieder durch, und der Beleg
für die Schranke müsste über einem Baum entstehen, in dem keine Angabe sie mehr auslöst. Der rote
Beleg zu DoD 1 wird **vor** DoD 2 genommen.

**Ein Detail, das der erste Lauf entscheidet und nicht der Plan:** ob die Auflösung über ein Glob
(`.harness/baseline/*/templates/…`, die Form aus `test/courseset-fixture.bats`) oder über eine
Platzhalter-Ersetzung läuft. Beide erfüllen (1); der Plan setzt die **Eigenschaft** — genau ein
Treffer, sonst laut —, nicht das Mittel. Was er ausschließt: eine zweite Fassung des Tag-Strings
irgendwo im Repo ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Der Slice ist priorisiert, `Verantwortlich:` ist gesetzt, und
das WIP-Limit ist frei — `ls docs/plan/planning/in-progress/` nennt auf dem Hauptzweig keinen
Slice. Abhängigkeiten hat er keine: Der Gegenstand liegt vollständig in `harness/tools/` und
`test/`, und der vendored `v6.8.0`-Baum steht. Der `git mv` nach `in-progress/` landet auf dem
Hauptzweig, **vor** der Arbeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Auflösung verlangt an einer der
  beiden Stellen (`mutation_targets`, `run_case`) eine **zweite**, andersartige Schranke — etwa
  über die Reihenfolge der Treffer oder über eine Angabe mit mehreren Pfaden —, und die braucht
  ihren eigenen Wächter samt Zahn. Dann sind es vier Liefer-Punkte, und der Schnitt war falsch,
  nicht die DoD zu kurz.
- `in-progress` → `open` (blockiert — Carveout?): Die Auflösung verschiebt die Bezugsmenge des
  Beleg-Schlüssels aus
  [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md),
  und ob das zulässig ist, ist eine Entscheidung und keine Implementierung — sie gehört dem
  Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8), nicht diesem Lauf. Ebenso, wenn einer der
  fünf Fälle gegen den `v6.8.0`-Satz seinen Wächter aus einem **sachlichen** Grund nicht mehr rot
  färbt (§6, Risiko 1): Dann ist der Fall neu zu zielen, und das ist ein eigener Vorgang.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. `make gates` grün **und** `MUTATE_FORCE=1 make mutate` ohne Befund, beides auf demselben Stand —
   der `mutate`-Lauf erzwungen, damit nicht der Beleg aus
   [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   die Aussage vertritt, die dieser Slice schuldet. Die CI fährt beides auf frischem Klon
   ([`harness/README.md`](../../../../harness/README.md) §Safety and scope boundaries); ein grüner
   Push ist das Kriterium, nicht ein lokaler Lauf allein.
2. `git grep -nE '^# files: \.harness/baseline/v[0-9]' -- test/mutations/` ist leer, und der Befund
   zu DoD 1 ist **rot gesehen** mit gelesener Meldung: Die Ausgabe nennt den Fall, dessen Angabe
   nicht auflöst, und nicht bloß *„Fingerabdruck … nicht berechenbar"*. Der Beleg steht im
   Review-Report, nicht als Behauptung in der Closure-Notiz.

**Lerneintrag** (eine der drei Formen): *neuer Sensor* — die Schranke aus DoD 1 samt ihrem Fall in
`test/mutations/` und ihrem Wächter in `test/mutate-driver.bats`. Ob daneben eine **geschärfte
Regel** entsteht, entscheidet der Zähler-Stand der Beobachtung aus §8 bei der Closure; die
Verkörperung wäre Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und nicht Teil
dieses Slice.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Einer der fünf Fälle ist gegen den `v6.8.0`-Satz stumpf.** Die `sed`-Anker sind gegen `v6.7.2`
  geschrieben; ein Fall, der nach der Auflösung **trifft**, aber seinen Wächter nicht mehr rot
  färbt, ist die Klasse `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` (3×, §8).
  Gemessen ist heute nur die Vorbedingung — jeder Anker steht im `v6.8.0`-Satz und genau einmal
  (`grep -c 'Kopiere nach' .harness/baseline/v6.8.0/templates/AGENTS.template.md` → 1; ebenso für
  die drei Anker der Fälle 224/244/248 in den beiden `archiv-stub-*`-Vorlagen; **keine
  Erwartungswerte**). Vorhandensein ist nicht Zahn: Ob der benannte Wächter fällt, sagt erst der
  Lauf. — **Ausgang:** <bei Closure>
- **Die Auflösung verschiebt den Beleg-Schlüssel.**
  [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  bindet ihn an `isolation_key_files` und **nicht** an `mutation_targets`; wird die Auflösung an
  der falschen Stelle eingezogen, greift ein stehender Beleg über einem Baum, den niemand geprüft
  hat — ein stilles Grün in genau dem Sensor, der stilles Grün finden soll. — **Ausgang:** <bei Closure>
- **Die Auflösung trifft mehr als eine Datei.** Lägen zwei `<tag>`-Verzeichnisse, mutierte ein Fall
  beide, und der Wächter urteilte über eine Vereinigung. `make baseline-verify` verbietet den
  Zustand und läuft in `make gates` — aber `make mutate` fährt nicht in `make gates`, also gibt es
  keinen Lauf, in dem die Schranke des einen die des anderen deckt. Deshalb steht die Bedingung
  *genau ein Treffer* in DoD 1 und wird nicht aus `baseline-verify` gefolgert. — **Ausgang:** <bei Closure>
- **Der Slice hat `make mutate` rot vorgefunden und schuldet dafür keine Ausnahme — jeder andere
  Slice, der bis dahin schließt, schon.** Das ist die Beobachtung
  `roter-nicht-gate-sensor-ohne-instrument` (1×, §8): Der Standard-DoD-Punkt *„`make mutate` ohne
  Befund"* kennt keinen Ausgang für einen fremden Vorbefund, und ein Carveout bindet an ein Gate,
  das `mutate` nicht ist. Für **diesen** Slice ist der rote Lauf der Gegenstand und der Punkt
  erfüllbar; das Risiko liegt bei den Nachbarn. — **Ausgang:** <bei Closure>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit>

**Was die Closure im Register anzulegen hat, und warum es hier steht statt dort.** Eingetragen wird
bei der Slice-Closure (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register); der
Plan **nennt** den Eintrag, er legt ihn nicht an. Vorgesehen ist ein **neues** Verzeichnis —
`BEO-ALL/tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht/` —, weil keine der drei
benachbarten Klassen ihn trägt (§8): Ein **lebendes** repo-eigenes Artefakt adressiert eine Datei
im vendored Baum über deren Tag, und der vom Prozess vorgeschriebene Baum-Tausch macht die Adresse
tot. Zwei Dinge gehören in den Rumpf, weil ohne sie der nächste Lauf die falsche Abhilfe wählt:

- **Adresse und Messung brauchen entgegengesetzte Behandlung.** Eine Adresse muss über jedem Stand
  auflösen und darf den Tag darum nicht nennen; eine **Messung** datiert ihre Aussage und *muss*
  ihn nennen ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
  Ein pauschaler Nachzug über beide — der naheliegende Griff — fälschte jede Messung still.
- **Der Nachzug von Hand ist die Fehlerursache, nicht die Abhilfe.** Er ist dreimal gefahren
  (§1) und beim vierten Sprung ausgeblieben.

Beleg: `evidence/slice-mutations-fall-entdeckt-den-vendored-tag.md`. Ob die Klasse damit schon bei
1× steht oder ob ein früherer Vorgang sie trägt, entscheidet die Closure — ein Beleg wird
angelegt, ein Zähler nicht gesetzt.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Zwei berührte Sub-Areas, beide in der Modus-Deklaration
([`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area)
geführt, keine muss ausdifferenziert werden:

- **`harness/tools/`** (`TOOLS`) — der Mutations-Treiber. Inklusionskriterium erfüllt (≥ 2 von 3):
  eigene Ablage-Konvention (adoptierte Harness-Mechanik, Adaptions-Block), eigener Sensor-Satz
  (`make shell-lint`, `test/*.bats`), eigene Lauf-Umgebung (Host-`bash` im Container-Rezept statt
  Go-Stage).
- **`*` (gesamtes Repo)** (`ALL`) — die Fall-Dateien unter `test/` und der Sensor-Vertrag unter
  `harness/sensors/`. Beide tragen keine eigene Modus-Deklaration und fallen unter die
  repo-weite; `test/` als eigene Sub-Area zu führen wäre eine Neu-Deklaration und gehört nicht in
  einen Slice, der einen Sensor repariert.

**Vorgelagert — offene Beobachtungen sichten:** Das Register
([`../observations/`](../observations/README.md)) ist durchgegangen. Alle Einträge tragen die
Sub-Area `*`, Pfad-Berührung ist also keine Auswahl — gesichtet ist nach **Aussagen**-Berührung.
Sechs Treffer, jeder mit seinem Zähler-Stand; die Zahl ist die der Dateien unter `evidence/`
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`), **keine
Erwartungswerte**:

| Beobachtung | Stand | Berührung durch diesen Slice |
|---|---|---|
| [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) | 3× offen | **Direkt** — Risiko 1 in §6 ist genau diese Klasse: der `sed`-Anker trifft nach dem Baum-Tausch vielleicht nicht mehr. Der Slice erreicht **kein** viertes Auftreten, solange kein Fall wirklich entwaffnet ist; tritt es ein, ist es ein Beleg und die Rückführung `in-progress → open` greift (§4). |
| [`gate-modul-erreicht-den-vendored-baum-nicht`](../observations/BEO-ALL/gate-modul-erreicht-den-vendored-baum-nicht/observation.md) | 3× offen, Ausgang [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md) | **Nachbar, deckt nicht** — dort eine tote Adresse als Inline-Code in **Markdown**, die kein `codepaths`-Modul erreicht; hier ein Operand in einer **Shell-Datei**, den ein Sensor laut abbricht. `slice-202` nimmt diesen Fall nicht an, deshalb steht er in §1 als Ausschluss und nicht als Verweis. |
| [`mutations-fall-zeigt-auf-falsche-datei`](../observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/observation.md) | 2× offen | **Nachbar, deckt nicht** — dort zeigt der Fall auf eine **existierende** falsche Datei und bleibt still grün; hier auf gar keine, und der Lauf bricht ab. Der Slice schließt die Lücke **nicht**: Eine Angabe, die auf die falsche vorhandene Vorlage auflöst, bleibt auch danach stumm. Das gehört als Grenze in `harness/sensors/mutate.md` (DoD 3). |
| [`mutations-fall-ueberlebt-die-umbenennung-seines-waechters`](../observations/BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters/observation.md) | 2× offen | **Nachbar, im Lauf sichtbar** — bricht an der `# expect:`-Zeile statt an `# files:`. Fällt einer der fünf Fälle mit *„falscher Grund"* statt *„blieb GRUEN"*, ist das diese Klasse und nicht Risiko 1; die zwei Meldungen zu unterscheiden ist Teil des Laufs. |
| [`roter-nicht-gate-sensor-ohne-instrument`](../observations/BEO-ALL/roter-nicht-gate-sensor-ohne-instrument/observation.md) | 1× offen | **Direkt, für die Nachbarn** — `make mutate` steht seit dem Sprung rot, und jeder Slice, der vor diesem schließt, hat für den Standard-DoD-Punkt keinen Ausgang. Für diesen Slice ist der rote Lauf der Gegenstand; die Klasse trifft ihn nicht, sondern begründet seine **Dringlichkeit** (§6, Risiko 4). |
| [`folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`](../observations/BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht/observation.md) | 6× offen | **Nachbar, deckt nicht** — dort ein wartender **Plan** in `open/`, dessen Pflicht sich verschiebt; hier eine **lauffähige** Datei, deren Adresse stirbt. Teilt die Ursache (der Sprung hat keinen Träger für den Bestand), nicht den Gegenstand. |

**Keiner der sechs erreicht mit diesem Slice 3×**, und keiner nimmt den Befund aus §1 an — deshalb
ist der vorgesehene Register-Eintrag ein **neuer** (§7) und kein Beleg an einem vorhandenen.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind **GF** (`harness/tools/` und
`*` stehen so in der Modus-Deklaration); ein Begründungsblock je Sub-Area entfällt damit. Die
Richtung stimmt auch inhaltlich: Die Regel steht
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
und die zwei Werkzeug-Kopfkommentare), der Code folgt ihr an fünf Stellen noch nicht — Doc führt,
Code zieht nach.
