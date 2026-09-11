# Slice slice-123: CI sieht die Historie — oder der Lauf fällt, statt grün zu melden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — der **erste** Slice und die
harte Kante zu [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md) und
[slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md).

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Workflows **dieses** Repos
([`.github/workflows/`](../../../../.github/workflows)). Was ein emittiertes Repo an
Checkout-Tiefe bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet — dort ist die Frage
auch nicht dieselbe, weil ein frisch gebootstrapptes Ziel keine Historie hat, über die ein Sensor
urteilen könnte.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (derselbe Baum liefert
lokal und in CI dasselbe Verdikt — hier steht genau das auf dem Spiel: lokal sieht ein
history-lesender Sensor die Historie, in CI nicht),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate, das grün meldet, weil sein Prüfbereich leer ist, senkt seine eigene Aussage),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (die
CI-Mechanik dieses Repos — sie ist der Ort dieser Änderung),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(Setzung 3 benennt die Klasse *blind und grün*, unter die ein Shallow-Clone-Sensor fällt),
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(die Restlücke, die dieses Repo mit *„CI ist dort das Netz"* benennt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Ein Sensor, der Historie liest, bekommt sie in CI auch — und wenn nicht, fällt der Lauf mit einer
Meldung, statt grün zu melden.**

### Der Anlass, gemessen

`grep -c 'fetch-depth' .github/workflows/ci.yml` → **0**, bei vier `actions/checkout`-Zeilen in
dieser Datei (`grep -c 'uses: actions/checkout' .github/workflows/ci.yml` → **4**; repo-weit über
`.github/workflows/*.yml` → **7**). Die Voreinstellung von `actions/checkout` ist Tiefe **1**.

**Was daraus folgt, ist nicht „der Sensor findet weniger", sondern „der Sensor findet nichts und
sagt es nicht" — aber nur in einer der beiden Formen, und die Unterscheidung ist der Kern dieses
Slice.** Gemessen in einem Klon der Tiefe 1
(`git clone --depth 1 file://<repo> <klon>`, `git log --oneline | wc -l` → **1**), netzlos, Mount
`:ro`, Image `v0.65.0` per Digest, Modul `vcs` mit gesetztem Config-Block:

| Range | Ergebnis |
|---|---|
| `--range HEAD~1..HEAD` (Basis nicht im Klon) | `d-check: error: Range-Basis "HEAD~1" nicht auflösbar: object not found`, **Exit 2** |
| `--range HEAD..HEAD` (auflösbar, leer) | `417 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| `--staged` ohne gestagte Änderung | `417 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |

**Das Werkzeug ist gegen die unauflösbare Basis fail-closed; blind und grün wird es über der
auflösbaren, aber leeren Range** — und genau die entsteht in CI, wenn ein Workflow die Basis aus
einem Push-Ereignis ableitet und auf einem flachen Klon nur einen Commit vorfindet. Das ist die
Klasse, die
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 3 benennt und die dieses Repo schon einmal bezahlt hat. **Der Wächter dieses Slice prüft
darum die Range, nicht die Klon-Tiefe:** eine Tiefen-Prüfung ließe den leeren Fall durch, und ein
`fetch-depth: 0` allein ist eine Zusage ohne Gegenbeispiel.

### Warum das ein eigener Slice ist und keine YAML-Zeile in zwei anderen

`fetch-depth: 0` ist der **billige** Teil. Der tragende ist die **Gegenrichtung**: ein Lauf, dem
die Historie fehlt, muss **fallen**. Ohne diese Hälfte ist die Zeile eine Zusage ohne
Gegenbeispiel — sie hält, solange niemand sie entfernt, und bricht still, sobald jemand es tut.
Diese Hälfte gehört genau **einmal** ins Repo und nicht zweimal in
[slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md) und
[slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md); läge sie in 126, hinge 127 an 126,
obwohl die zwei fachlich nichts miteinander zu tun haben.

**Und der Prüfbereich ist enger als „alle sieben Checkouts".** Volle Historie kostet Zeit; sie
gehört an die Jobs, deren Schritte Historie **lesen**, nicht an jeden Checkout des Repos. Welche
das sind, ist nach [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md) und
[slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md) bekannt — vor ihnen ist es eine
Entscheidung, und sie ist DoD (2).

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [x] **(1) Ein history-lesender Schritt, dessen Range nichts hergibt, fällt — statt grün zu
      melden.** Der Wächter prüft **vor** dem Modul-Lauf, dass die Range auflösbar **und nicht
      leer** ist, und nennt beim Rot, was fehlt (**Shallow-Grenzen**, angeforderte Range, Zahl der
      enthaltenen Commits) — **nicht** die Klon-Tiefe. Der Wächter urteilt über die Range und nicht
      über die Tiefe (§1); ein Label *Tiefe* über einer Shallow-Grenzen-Zahl nennt die falsche
      Einheit, und die Zusage nennt darum die Größe, die die Ausgabe wirklich trägt.
      **Rot:** in einem flachen Klon (`git clone --depth 1` gegen eine lokale Kopie) den Schritt
      mit einer **leeren** Range fahren → Exit ≠ 0 mit dieser Meldung. Ohne den Wächter meldet
      derselbe Lauf `0 Befund(e)`, Exit 0 (§1) — das ist das Gegenbeispiel, und es gehört einmal
      gesehen. Die unauflösbare Basis ist **nicht** der Fall: sie bricht schon ohne Wächter mit
      Exit 2 ab, und ein Wächter, der nur sie fängt, prüft eine Eigenschaft, die das Werkzeug
      bereits hält.
- [x] **(2) Die Checkouts, die Historie brauchen, tragen `fetch-depth: 0`, und die anderen nicht —
      mit der Begründung neben der Zeile.** Entschieden und aufgeschrieben ist, **welche** der
      sieben `actions/checkout`-Stellen betroffen sind und warum die übrigen bei Tiefe 1 bleiben.
      **Rot:** `make ci-lint` fällt bei fehlerhafter Workflow-Syntax — das hält die **Form** der
      Workflows, nicht die Zuordnung. Die Zuordnung ist eine Aussage über zwei Mengen und rot,
      sobald sie auseinanderfallen: die Schritte, die Historie lesen
      (`grep -rnE 'doc-immutable|doc-commits' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l`),
      gegen die Checkouts mit voller Tiefe
      (`grep -rn 'fetch-depth' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l`). Beide liefern
      heute **0** — **keine Erwartungswerte**, sie wandern mit den Workflows. **Das Kriterium ist
      damit über der leeren Menge wahr**, und das ist der Befund, nicht seine Umgehung: der Beleg
      dieses Slice ist die **Begründung** im Kopf von
      [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml), nicht ein CI-Lauf. Rot
      wird die Zuordnung, wenn die erste Zahl steigt und die zweite nicht mitgeht.
      **Ein Sensor dafür existiert nicht** — kein Modul der
      [`.d-check.yml`](../../../../.d-check.yml) liest Workflows, und `make ci-lint` prüft Syntax.
      Träger ist die Verifikation dieses Slice und der Lauf, der den ersten history-lesenden Schritt
      hinzufügt: eine **benannte Lücke**, keine zugesagte Abdeckung
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] **(3) Der Wächter hat seinen Zahn.** Ein `test/mutations/`-Fall entfernt die **Leer-Erkennung
      der Range** — nicht eine Tiefen-Prüfung, die der Wächter nicht führt (§1) — und färbt den
      benannten Test rot.
      **Rot:** `make mutate` meldet **BEFUND** auf genau diesen Fall, solange der Zahn nicht die
      Stelle trifft, die der Aufrufer benutzt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update | `fetch-depth: 0` an den Jobs, deren Schritte Historie lesen — welche das sind, entscheidet DoD (2) |
| `harness/tools/` — ein neues Skript **oder** ein Schritt im Workflow | neu | der Tiefen-Wächter aus DoD (1). Präzedenz für die hermetische Bauart: [`harness/tools/component-freshness.sh`](../../../../harness/tools/component-freshness.sh) |
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Wächter fährt — **kein Gate** und in keiner Prerequisite-Kette (wie `slice-mv`/`archive-welle`/`span-report`/`hook-overhead`), darum bleibt [`AGENTS.md`](../../../../AGENTS.md) §4 (Quality-Gates-Tabelle) unberührt |
| `test/` | neu | der bats-Fall, den DoD (3) mit einem `test/mutations/`-Fall belegt |
| [`harness/README.md`](../../../../harness/README.md) | update | was der Wächter prüft und was **nicht** — der Harness-Einstieg ist der Ort dieser Aussage |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | Adaptions-Block ist Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8); berührt der Slice [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions), ist das eine Übergabe |
| [`.github/workflows/release.yml`](../../../../.github/workflows/release.yml) | **vermutlich unverändert** | die zwei Checkouts dort bauen Artefakte, sie lesen keine Historie — zu prüfen, nicht zu unterstellen |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md)
ist gestartet (ihr Trigger in §2 ist eingetreten) und das WIP-Limit ist frei.** Innerhalb der Welle
ist dieser Slice der erste; er wartet auf keinen anderen.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (2) lässt sich nicht entscheiden, weil noch kein history-lesender
  Schritt existiert — dann wird der Slice zu einer Entscheidung ohne Gegenstand. Er geht zurück und
  **hinter** [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md); die Kante dreht sich um.
  **Das ist der wahrscheinlichste Rückweg dieses Slice**, und er ist kein Fehler, sondern die
  Alternative, gegen die hier entschieden wurde.
- `in-progress` → `open`: `fetch-depth: 0` treibt die CI-Laufzeit über eine Grenze, die dieses Repo
  nicht zahlen will. Dann ist die Antwort nicht „weniger Tiefe", sondern eine andere Bezugsgröße
  (z. B. `fetch-depth` auf die Range-Länge statt 0), und das ist ein eigener Entwurf — als Carveout
  nach Modul 7 aufzuschreiben, nicht als Zusage in einen Workflow.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make ci-lint` grün,
`make mutate` ohne Befund, Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden
Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der Wächter kann sich selbst nicht beweisen, solange er allein steht.** Vor
  [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md) und
  [slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md) gibt es keinen produktiven Schritt,
  der Historie liest — sein Gegenbeispiel ist dann ein **konstruierter** flacher Klon und nicht ein
  echter CI-Lauf. Das ist zulässig (DoD (1) nennt genau diesen Lauf), aber es ist eine schwächere
  Deckung, und sie gehört in die Closure-Notiz statt in eine Erfolgsmeldung.
  **Ausgang: eingetreten → [slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md)**
  (nachrangig [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md)). Der Wächter
  steht ohne Aufrufer — `grep -rn 'history-range-guard' .github/workflows/ | wc -l` → **1**, und
  der eine Treffer ist die Kommentarzeile
  [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml)`:27`, kein `run:`-Schritt
  (keine Erwartungswerte). Träger der Auflösung ist DoD (3) von slice-127, das die Kopplung an
  diesen Slice wörtlich als eigenes Kriterium führt; dort entsteht der produktive Schritt, an dem
  das Gegenbeispiel nicht mehr konstruiert werden muss.
- **`fetch-depth: 0` ist eine Kosten-Entscheidung, die dieser Slice trifft, ohne sie zu messen.**
  Wie viel Zeit die volle Historie kostet, ist hier nicht erhoben; es steht als offener Punkt und
  gehört bei der Umsetzung mit einer Zahl neben ihrem Kommando beantwortet
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
  **Ausgang: entfallen** — die Prämisse ist nicht eingetreten. Der Slice setzt `fetch-depth: 0`
  nirgends: `grep -rn 'fetch-depth' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l` → **0**
  (kein Erwartungswert). Ohne gesetzte volle Tiefe gibt es keine Laufzeit zu messen, und eine
  gemessene Zahl über einer nicht getroffenen Entscheidung wäre eine Zahl ohne Gegenstand. Die
  Kosten-Frage entsteht mit dem ersten Checkout, der volle Tiefe bekommt; sie liegt dann bei dem
  Slice, der ihn setzt — DoD (2) von
  [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md) entscheidet ausdrücklich,
  „ob neben dem Vor-Commit-Lauf eine Range in CI läuft".
- **Der Guard-Präzedenzfall warnt vor Selbstüberschätzung.** Der PreToolUse-Guard benennt seine
  eigene Grenze (*„ein Stolperdraht, KEINE Sandbox"*); ein Tiefen-Wächter, der *„CI sieht die
  Historie"* zusagt, aber nur **einen** Job prüft, macht denselben Fehler eine Ebene höher. Was er
  abdeckt, muss er sagen.
  **Ausgang: entfallen** — die Bedingung ist erfüllt statt umgangen. Die Wächter-Beschreibung in
  [`harness/README.md`](../../../../harness/README.md) §Sensors nennt vier Grenzen ausdrücklich
  (kein Gate und in keiner Prerequisite-Kette · geprüft wird die Range, nicht die Klon-Tiefe · die
  unauflösbare Basis deckt er **nicht** zusätzlich · heute ohne Aufrufer), und der
  Verifikations-Lauf hat jede der vier einzeln gegen den Code gehalten. Der Wächter sagt damit,
  was er abdeckt; das Risiko war, dass er es nicht tut.
- **Ein zweiter Klient existiert nicht.** [`.codex/hooks.json`](../../../../.codex/hooks.json) führt
  allein den SessionStart-Injektor; ein Wächter, der nur in GitHub Actions greift, deckt CI und
  nicht den lokalen Lauf. Ob das reicht, ist zu benennen — hier ist es vertretbar, weil die
  **Blindheit** eine CI-Eigenschaft ist und lokal gar nicht auftritt.
  **Ausgang: entfallen** — der Wächter ist an keinen Klienten gebunden. Er läuft als `make`-Ziel
  (`make history-range-guard RANGE=… | STAGED=1`) und hängt an keinem Agenten-Hook;
  [`.codex/hooks.json`](../../../../.codex/hooks.json) führt unverändert allein den
  SessionStart-Injektor. Ein zweiter Klient bräuchte den Wächter nur, wenn er die CI-Blindheit
  teilte, und ein lokaler Klon ist nicht flach.
- **Offene Norm-Frage: Wer darf `internal/emit/templates/commands/*.md` ändern?**
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) entscheidet das für
  die emittierte Ebene ausdrücklich **nicht** (§Was hier NICHT entschieden ist), während dieser
  Slice-Kopf „Ebene: Dogfood, nicht emittiert" erklärt. Eine Nummern-Korrektur in
  `internal/emit/templates/commands/implement-slice.md` (sachlich richtig) ist im Diff dennoch
  enthalten. Die Frage bleibt für den Architect offen und wird hier nicht durch eine weitere
  Implementer-Auslegung entschieden.
  **Ausgang: weiter offen → [`BEO-ALL/anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md)**,
  Beleg `evidence/slice-123.md`. Geprüft statt angenommen:
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nimmt die
  emittierte Ebene in Folgepflicht 3 ausdrücklich aus und weist sie „dem Slice, der die Tool-Ebene
  entscheidet" zu; die jüngste Entscheidung
  [`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) berührt sie nicht — ihre
  vier Festlegungen betreffen die Struktur-Aufzählung des Bootstrap, keine Eigentums-Aussage
  (`grep -c '0028-anweisungssatz' docs/plan/adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md`
  → **0**, Exit 1). Die Frage ist damit weder aufgelöst noch entfallen; sie zählt weiter.
- **Die Zuordnung aus DoD (2) ist über der leeren Menge wahr.** Der erste Punkt oben betrifft die
  *Deckung* des Wächters, dieser die *Zuordnungs-Aussage* daneben: Kein Schritt liest heute Historie
  (`grep -rnE 'doc-immutable|doc-commits' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l` → **0**,
  kein Erwartungswert), also braucht keiner der sieben Checkouts volle Tiefe — und die Zusage „die
  anderen bleiben bei Tiefe 1" hält, ohne je rot werden zu können. Ihr Beleg ist die **Begründung**
  im Kopf von [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml); ein Sensor, der
  die zwei Mengen gegeneinander hält, existiert nicht. Der Punkt bleibt offen, bis
  [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md) oder
  [slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md) den ersten history-lesenden
  Schritt liefert, und braucht bei der Closure einen der drei Ausgänge.
  **Ausgang: eingetreten → [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md)**
  (nachrangig [slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md)). Beide Mengen
  stehen bei Closure unverändert auf null
  (`grep -rnE 'doc-immutable|doc-commits' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l` → **0**
  und `grep -rn 'fetch-depth' .github/workflows/ | grep -v ':[0-9]*:#' | wc -l` → **0**, keine
  Erwartungswerte), die Zuordnung bleibt also vakuos wahr. Materiell aufgefangen ist sie von
  DoD (2) in slice-126 — dort wird entschieden, ob eine Range in CI läuft; mit dem ersten
  history-lesenden Schritt hört die erste Zahl auf, null zu sein, und die Zuordnung wird zum
  ersten Mal rot färbbar.
- **Ein eingefrorener Rollen-Report nennt diesen Plan als Pfad, und der `git mv` nach `done/` steht
  bevor.** Der Report der ersten Review-Runde adressiert den Plan als
  `../plan/planning/in-progress/…`-Link; nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.11 ist ein Rollen-Report ein einfrierendes Artefakt, und
  `make slice-mv` nimmt [`docs/reviews/`](../../../reviews/) von der Eingehend-Ersetzung
  ausdrücklich **nicht** aus. Die Entscheidung — Verweis brechen lassen, nachziehen lassen oder den
  Report als Kennung umschreiben — gehört nach
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
  **vor** den Move und wird beim Abschluss fällig, nicht hier.
  **Ausgang: weiter offen → [`BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)**,
  Beleg `evidence/slice-123.md`. Die Entscheidung für **diesen** Move ist getroffen und steht in
  §7; offen bleibt die Klasse, denn getroffen wurde sie zum vierten Mal einzeln.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner. **Datum:** 2026-09-06.

**Geliefert.** Der Vorlauf-Wächter [`harness/tools/history-range-guard.sh`](../../../../harness/tools/history-range-guard.sh)
mit seinem Ziel `make history-range-guard` (kein Gate, in keiner Prerequisite-Kette), sieben
bats-Fälle (`grep -c '^@test' test/history-range-guard.bats` → **7**) und vier Mutations-Fälle
(`ls test/mutations/*history-range-guard*.sh | wc -l` → **4**), dazu die Checkout-Tiefen-Begründung
im Kopf der drei Workflow-Dateien und der Wächter-Absatz in
[`harness/README.md`](../../../../harness/README.md) §Sensors. Keine Erwartungswerte — beide Zahlen
wandern mit dem Bestand.

- **Was hat funktioniert:** Die Trennung von Entscheidung und `git`-Aufruf. `decide()`/
  `decide_staged()` sind über `--decide <range> <count>` bzw. `--decide-staged <0|1>` mit
  Fixture-Werten hermetisch prüfbar — das gepinnte `BATS_IMAGE` führt kein `git`, und ohne die
  Trennung hätte der Wächter dieselbe Deckungslücke wie `slice-mv` und `archive-welle`. Ebenso
  getragen hat der **Schnitt**: Die Gegenrichtung — ein Lauf ohne Historie muss *fallen* — liegt
  genau einmal im Repo, statt doppelt in slice-126 und slice-127; die zwei hängen jetzt an diesem
  Slice und nicht aneinander.
- **Was ging anders als geplant:** Drei Dinge, und keines davon lag am Wächter.
  **(a)** Der Slice brauchte zwei Review-Runden, eine Planner-Neufassung der DoD und eine
  Verifikation. Der Weg war teuer, weil das Rot-Kriterium von DoD (2) in seiner ersten Fassung
  über einer **leeren Menge** lief und deshalb nie rot werden konnte — beide Review-Runden haben
  das nicht gesehen, gefunden hat es erst der Planner-Lauf, der die DoD neu fasste. Ein
  Abnahmekriterium, das nichts messen kann, ist kein Kriterium; dass es zwei Prüf-Rollen passiert
  hat, ist der teuerste Einzelbefund dieses Slice.
  **(b)** Die Plan-Tabelle §3 ist gegenüber dem tatsächlichen Diff **unvollständig**: sie nennt
  weder [`.github/workflows/upstream-drift.yml`](../../../../.github/workflows/upstream-drift.yml)
  noch das Paar [`.claude/commands/implement-slice.md`](../../../../.claude/commands/implement-slice.md)
  / `internal/emit/templates/commands/implement-slice.md`, obwohl alle drei im Diff stehen. Der
  Verifikations-Lauf hat beides als nicht-blockierende Lücke benannt. Die Tabelle wird hier
  **nicht** nachträglich umgeschrieben: ein Plan beschreibt, was vorgesehen war, und ein
  rückwirkend an das Ergebnis angeglichener Plan hätte nie eine Lücke.
  **(c)** Der Verifikations-Report zählt „alle **acht** Einträge in §6"; §6 trägt **sieben**
  (`awk '/^## 6\. Risiken/,/^## 7\./' <diese Datei> | grep -c '^- \*\*'` → **7**, kein
  Erwartungswert), und seine eigene Tabelle listet sieben Zeilen. Der Report ist ein Rollen-Report
  und bleibt unangetastet; die Zahl, gegen die diese Closure ihre Ausgänge abzählt, ist die
  gemessene.
- **Steering-Loop-Eintrag:** *Neuer Sensor* — die Klasse **blind und grün** aus
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 3 hat für den Fall *auflösbare, aber leere Commit-Range* erstmals einen Wächter, und der
  Wächter hat seinen Zahn — liegt in `Makefile:history-range-guard`. Auslöser ist **kein**
  3×-Übertritt, sondern der Slice-Schnitt selbst; die Zeile trägt darum keine `BEO-`-Kennung.
  **Zweiter Eintrag, und er ist der unbequemere:** *benannte Lücke* — zwei der Klassen, die dieser
  Slice in den Zähler schickt, stehen im Register bereits als **verkörpert**
  ([`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md)
  → [`AGENTS.md`](../../../../AGENTS.md) §3.10 und
  [`vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md)
  → §3.11), und **beide** Sektionen stellen für sich selbst fest: *„Ein Wächter existiert nicht."*
  Die Regel stand, sie war lesbar, und sie ist trotzdem gebrochen worden. Der Lese-Schritt liest,
  was 3× erreicht hat; der Sichtungs-Schritt liest, was darunter steht — für einen Eintrag, der
  **oberhalb** der Schwelle steht und **schon einen Ausgang trägt**, ist keine Handlung definiert.
  Sein Zähler wächst weiter, und niemand sieht ihn wieder an. Das ist als eigene Beobachtung
  eingetragen (unten) und **hier nicht entschieden**: Die geschlossene Menge der drei Ausgänge
  steht in der Baseline (`modul-06-roadmap.md` §Das Beobachtungs-Register), eine repo-seitige
  Antwort wäre ein Architect-Artefakt.
- **Beobachtungs-Register (`../observations/`):** zehn Belege, alle als `evidence/slice-123.md` —
  ein Vorgang zählt einmal, auch wo zwei Review-Runden dieselbe Klasse nennen
  (`ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-123.md | wc -l` → **10**, kein
  Erwartungswert). Sieben gehen in bestehende Einträge, drei Verzeichnisse sind neu.
  Zähler-Stände nach dieser Closure, je selbst gemessen mit
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l` (keine
  Erwartungswerte):
  [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md) **5×** (N-1) ·
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) **15×** (N-3) ·
  [`vorgeschriebener-ortswechsel-macht-adresse-tot`](../observations/BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot/observation.md) **4×** (N-6) ·
  [`zaehler-label-nennt-falsche-einheit`](../observations/BEO-ALL/zaehler-label-nennt-falsche-einheit/observation.md) **3×** (F-2) ·
  [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md) **2×** (F-1) ·
  [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md) **2×** (F-6) ·
  [`anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md) **5×** (§6 Risiko 5).
  **Drei Verzeichnisse neu angelegt:**
  [`positive-meldung-im-fehlschlag-zweig`](../observations/BEO-ALL/positive-meldung-im-fehlschlag-zweig/observation.md) (F-7 und N-2 — zweimal im selben Slice, das zweite Mal in dem Commit, der das erste behob),
  [`zitierte-ausgabe-weicht-vom-literal-ab`](../observations/BEO-ALL/zitierte-ausgabe-weicht-vom-literal-ab/observation.md) (N-4) und
  [`beleg-nach-dem-ausgang-findet-keinen-leser`](../observations/BEO-ALL/beleg-nach-dem-ausgang-findet-keinen-leser/observation.md) (eigene Beobachtung dieser Closure, siehe Steering-Loop-Eintrag).
  **Eine Klasse bekommt bewusst keinen Eintrag:** *Neue Zusage ohne Fall im Mutations-Satz* (N-5,
  INFO). Die Regel steht bereits — [`AGENTS.md`](../../../../AGENTS.md) §3.6 weist die
  **Entstehung** neuer Zähne ausdrücklich der Pre-completion-Checkliste zu, nicht `make mutate` —,
  und der Slice hat sie befolgt: die drei Fälle 266–268 decken beide beanstandeten Zusagen. Eine
  Registerzeile zählte hier eine Regel, die funktioniert hat.
- **`zaehler-label-nennt-falsche-einheit` erreicht mit diesem Beleg 3× — der Lese-Schritt gehört
  nicht hierher.** Dieser Slice hängt an [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md);
  in einem Repo mit Wellen-Betrieb liest die **Welle-Closure**, was die Schwelle erreicht hat
  (Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register). `state.md` trägt darum
  weiter `offen` — zulässig und vorübergehend. **Übergabe an die Closure von welle-13:** der
  Eintrag ist ab jetzt fällig und braucht dort einen der drei Ausgänge.
- **Die Entscheidung vor dem Move** ([`AGENTS.md`](../../../../AGENTS.md) §3.11,
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4).
  Gemessen über beide Adress-Formen, am **eingefrorenen** Stand vor dieser Notiz — der Baum-Operand
  hält die Zahl fest, und ohne ihn zählte das Kommando sein eigenes Zitat in dieser Zeile mit:

  ```sh
  R=7c2256c
  git grep -n -F 'slice-123-ci-sieht-die-historie.md' $R -- ':!.harness/baseline' | wc -l   # 14
  git grep -l -F 'slice-123-ci-sieht-die-historie.md' $R -- ':!.harness/baseline' | wc -l   #  8
  git grep -n -F 'slice-123-ci-sieht-die-historie.md' $R -- 'docs/reviews'        | wc -l   #  3
  ```

  Also **14** Fundstellen in **8** Dateien, davon **3** in
  [`docs/reviews/`](../../../reviews/) — zwei tragen
  das Verzeichnis-Literal `in-progress/` und werden von der Eingehend-Ersetzung getroffen (Report
  der Runde 1, Verifikations-Report), die dritte ist ein Such-Literal ohne Verzeichnis-Segment im
  Report der Runde 2 und bleibt unberührt. **Entschieden: der Nachzug läuft, das Ventil nicht.**
  Drei Gründe, in dieser Reihenfolge. **(1)** Ein viertes namentlich geschnittenes
  `ignore-refs`-Paar ist nach
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 2
  („und keinen weiteren") eine neue Senkung mit eigener ADR — dieser Preis ist für eine Adresse,
  die nach dem Nachzug wieder auflöst, nicht angemessen. **(2)** Den Verweis brechen zu lassen ist
  keine Option: `make docs-check` würde rot, und ein rotes Gate ohne Carveout schließt keinen
  Slice. **(3)** Der Nachzug in [`docs/reviews/`](../../../reviews/) ist die **entschiedene**
  Bauart dieses Repos, nicht eine Umgehung: `harness/README.md` §Sensors führt aus, dass
  `docs/reviews/**` von der Eingehend-Ersetzung ausdrücklich **nicht** ausgenommen ist, weil seine
  Verweise reale, von `docs-check` geprüfte Links sind — und der Bestand bestätigt es
  (`git log --format='%H' --grep='^slice-mv: Verweise' -- docs/reviews/ | wc -l` → **27**
  Nachzug-Commits, `grep -rlF 'plan/planning/done/slice-' docs/reviews/ | wc -l` → **130** Reports
  mit einer `done/`-Adresse; keine Erwartungswerte). Was der Nachzug ändert, ist die **Adresse**,
  nicht die **Aussage** des Reports.
  **Was diese Entscheidung offen lässt, und es ist eine Norm-Frage:** §3.11 nennt einen
  Rollen-Report *einfrierend* und
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3
  bindet ihn ausdrücklich mit; zugleich schreibt `make slice-mv` planmäßig in ihn hinein. Ob eine
  mechanische Adress-Ersetzung eine *Berührung* im Sinne des Einfrierens ist, sagt keine Quelle
  über Rang 9 — [`harness/README.md`](../../../../harness/README.md) trägt heute die einzige
  Begründung. **Das ist eine Übergabe an den Architect**, nicht ein Urteil dieser Closure.
- **Folge-Slices:** [slice-126](../next/slice-126-commit-message-traegt-eine-kennung.md) und
  [slice-127](../done/slice-127-adr-immutabilitaet-hat-einen-sensor.md) — beide sind Dateien in
  `open/` und Mitglieder derselben Welle. Neu geschnitten wurde **keiner**: die zwei Risiken mit
  dem Ausgang *eingetreten* fallen auf DoD-Punkte, die diese zwei bereits führen (slice-127
  DoD (3) nennt die Kopplung an diesen Slice wörtlich, slice-126 DoD (2) entscheidet die Range in
  CI).
- **Risiken aus §6:** sieben, jedes mit genau einem Ausgang — **2× eingetreten** (Risiko 1 →
  slice-127, Risiko 6 → slice-126), **3× entfallen mit Begründung** (Risiko 2 Prämisse nicht
  eingetreten, Risiko 3 Bedingung erfüllt, Risiko 4 Wächter klient-unabhängig), **2× weiter offen
  ins Register** (Risiko 5 → `anweisungssatz-eigentum-ohne-quelle`, Risiko 7 →
  `vorgeschriebener-ortswechsel-macht-adresse-tot`).
- **Drei Paarungen:** **nicht hier** — dieser Slice gehört zu
  [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md), und im Repo mit Wellen-Betrieb prüft
  sie die Welle-Closure (Vorlagen-Item in §2). Vorgearbeitet ist die Register-Paarung insoweit,
  als jede oben genannte Beobachtung als Verzeichnis existiert und jede einen Beleg trägt.
- **Nachtrag nach dem Move — der Ruhe-Marker der Roadmap stand die ganze Laufzeit dieses Slice
  falsch, und niemand hat es gemerkt.** Beim Übergang `next → in-progress` blieb *„Nichts in
  Arbeit."* unter §Offene Wellen stehen, obwohl `in-progress/` einen beanspruchten Slice trug —
  genau der Defekt, den die Ziel-Form als *stehengebliebener Marker bei beanspruchtem Slice*
  führt. Gemessen am eingefrorenen Move-Commit, damit die Zahl fest ist:
  `git show 666bf14:docs/plan/planning/in-progress/roadmap.md | grep -c 'Nichts in Arbeit'` →
  **1**. Wahr geworden ist der Marker erst wieder durch diesen Abschluss, ohne dass ihn jemand
  angefasst hätte. **Kein Register-Eintrag, und der Grund ist derselbe wie bei N-5:** Die Lücke
  ist im Abschnitt selbst benannt, und ihr Träger steht mit
  [slice-125](../done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) als Datei in `open/`
  — mit dem Auftrag, für **beide** Hälften einen Sensor zu bauen. Was dieser Nachtrag beiträgt,
  ist der reale Beleg, dass die Marker-Hälfte ohne Sensor nicht bloß theoretisch driftet.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Workflows sind konventionell dicht — `make ci-lint` (actionlint) hält ihre Form, und
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) hält
ihre Absicht.
