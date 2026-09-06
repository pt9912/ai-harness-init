# Slice slice-123: CI sieht die Historie — oder der Lauf fällt, statt grün zu melden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — der **erste** Slice und die
harte Kante zu [slice-126](slice-126-commit-message-traegt-eine-kennung.md) und
[slice-127](slice-127-adr-immutabilitaet-hat-einen-sensor.md).

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
[slice-126](slice-126-commit-message-traegt-eine-kennung.md) und
[slice-127](slice-127-adr-immutabilitaet-hat-einen-sensor.md); läge sie in 126, hinge 127 an 126,
obwohl die zwei fachlich nichts miteinander zu tun haben.

**Und der Prüfbereich ist enger als „alle sieben Checkouts".** Volle Historie kostet Zeit; sie
gehört an die Jobs, deren Schritte Historie **lesen**, nicht an jeden Checkout des Repos. Welche
das sind, ist nach [slice-126](slice-126-commit-message-traegt-eine-kennung.md) und
[slice-127](slice-127-adr-immutabilitaet-hat-einen-sensor.md) bekannt — vor ihnen ist es eine
Entscheidung, und sie ist DoD (2).

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Ein history-lesender Schritt, dessen Range nichts hergibt, fällt — statt grün zu
      melden.** Der Wächter prüft **vor** dem Modul-Lauf, dass die Range auflösbar **und nicht
      leer** ist, und nennt beim Rot, was fehlt (Tiefe, angeforderte Range, Zahl der enthaltenen
      Commits).
      **Rot:** in einem flachen Klon (`git clone --depth 1` gegen eine lokale Kopie) den Schritt
      mit einer **leeren** Range fahren → Exit ≠ 0 mit dieser Meldung. Ohne den Wächter meldet
      derselbe Lauf `0 Befund(e)`, Exit 0 (§1) — das ist das Gegenbeispiel, und es gehört einmal
      gesehen. Die unauflösbare Basis ist **nicht** der Fall: sie bricht schon ohne Wächter mit
      Exit 2 ab, und ein Wächter, der nur sie fängt, prüft eine Eigenschaft, die das Werkzeug
      bereits hält.
- [ ] **(2) Die Checkouts, die Historie brauchen, tragen `fetch-depth: 0`, und die anderen nicht —
      mit der Begründung neben der Zeile.** Entschieden und aufgeschrieben ist, **welche** der
      sieben `actions/checkout`-Stellen betroffen sind und warum die übrigen bei Tiefe 1 bleiben.
      **Rot:** `make ci-lint` fällt bei fehlerhafter Workflow-Syntax; und die Zuordnung selbst ist
      rot, wenn ein Job mit einem history-lesenden Schritt ohne `fetch-depth: 0` bleibt — genau der
      Fall, den Punkt (1) dann in CI sichtbar macht.
- [ ] **(3) Der Wächter hat seinen Zahn.** Ein `test/mutations/`-Fall entfernt die Tiefen-Prüfung
      und färbt den benannten Test rot.
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
| [`Makefile`](../../../../Makefile) | update | das Ziel, das den Wächter fährt, falls er eines bekommt — dann zieht [`AGENTS.md`](../../../../AGENTS.md) §4 mit (öffentlicher Vertrag) |
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
  **hinter** [slice-126](slice-126-commit-message-traegt-eine-kennung.md); die Kante dreht sich um.
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
  [slice-126](slice-126-commit-message-traegt-eine-kennung.md) und
  [slice-127](slice-127-adr-immutabilitaet-hat-einen-sensor.md) gibt es keinen produktiven Schritt,
  der Historie liest — sein Gegenbeispiel ist dann ein **konstruierter** flacher Klon und nicht ein
  echter CI-Lauf. Das ist zulässig (DoD (1) nennt genau diesen Lauf), aber es ist eine schwächere
  Deckung, und sie gehört in die Closure-Notiz statt in eine Erfolgsmeldung.
- **`fetch-depth: 0` ist eine Kosten-Entscheidung, die dieser Slice trifft, ohne sie zu messen.**
  Wie viel Zeit die volle Historie kostet, ist hier nicht erhoben; es steht als offener Punkt und
  gehört bei der Umsetzung mit einer Zahl neben ihrem Kommando beantwortet
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
- **Der Guard-Präzedenzfall warnt vor Selbstüberschätzung.** Der PreToolUse-Guard benennt seine
  eigene Grenze (*„ein Stolperdraht, KEINE Sandbox"*); ein Tiefen-Wächter, der *„CI sieht die
  Historie"* zusagt, aber nur **einen** Job prüft, macht denselben Fehler eine Ebene höher. Was er
  abdeckt, muss er sagen.
- **Ein zweiter Klient existiert nicht.** [`.codex/hooks.json`](../../../../.codex/hooks.json) führt
  allein den SessionStart-Injektor; ein Wächter, der nur in GitHub Actions greift, deckt CI und
  nicht den lokalen Lauf. Ob das reicht, ist zu benennen — hier ist es vertretbar, weil die
  **Blindheit** eine CI-Eigenschaft ist und lokal gar nicht auftritt.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Die
Workflows sind konventionell dicht — `make ci-lint` (actionlint) hält ihre Form, und
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) hält
ihre Absicht.
