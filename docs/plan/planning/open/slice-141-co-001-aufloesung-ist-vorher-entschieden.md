# Slice slice-141: Die Auflösung von `CO-001` ist entschieden, bevor ihr Move eine eingefrorene Adresse bricht

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet. **Bündel?** Nein — ein Slice, eine Entscheidung, und er
wartet auf keinen zweiten. **Gemeinsames Closure-Kriterium?** Nein — jedes wäre die Abschrift
seiner eigenen DoD. **Auslöser reaktiv oder gewollt?** Reaktiv: ein Auflösungs-Trigger ist
eingetreten und sein Vollzug bricht zwei Adressen, die niemand heilen darf (§1). Der Gegenstand
stammt **nicht** aus dem Re-Baseline-Delta und belegt kein Closure-Kriterium von
[welle-10](../welle-10-re-baseline.md) §3; er gehört darum in keine Welle. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate, dessen einziger Befund unbehebbar ist, erzieht dazu, Rot zu überlesen — dieselbe Kehrseite
des halluzinierten Gates, die schon
[slice-132](../in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) getragen hat),
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (die Quelldatei der zwei
Verweise, und Festlegung 5, die den nächsten Fall ausdrücklich einzeln stellt),
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) (dieselbe Klasse, an
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) entschieden — sie
deckt diesen Fall **nicht**, und Festlegung 3 bindet die Verweis-Form für künftige Artefakte),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — *Eigenschaft statt
Adresse*),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test oben),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (das Artefakt ist eingefroren) und §3.8 (die
Entscheidung schreibt der Architect — dieser Slice ist geschnitten, nicht ausgeführt vom Planner).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt eine Architektur-Entscheidung und eine
Gate-Config-Frage, keine Spec-Stelle.

**Verantwortlich:** — bis zur Priorisierung. Der Liefergegenstand ist eine ADR, und die schreibt
nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 der **Architect**; das Feld weicht damit bei der
Priorisierung von der Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine nennt.

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Wenn [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) nach `carveouts/done/` wandert, ist
vorher entschieden, was mit den zwei Pfad-Links geschieht, die dieser Move in einem eingefrorenen
Artefakt bricht.**

### Der Befund: ein fälliger Carveout mit einer geladenen Adresse

**Der Trigger ist eingetreten, und der Carveout sagt es selbst.** Sein Status-Kopf führt
*„Aktiv — **Auflösung fällig**, nicht offen"*
(`grep -c 'Auflösung fällig' docs/plan/carveouts/CO-001-bats-shell-lint.md` → **1**), seine letzte
Prüfung ist der welle-12-Closure-Audit vom 2026-08-27, und sein Folge-Slice
[slice-113](slice-113-co-001-ist-faellig.md) liegt geschnitten in `open/`. Dessen DoD (3) macht
den Ausgang zur **Verzeichnis-Position**: der Carveout wandert per `git mv` nach `done/` — oder er
bekommt einen Trigger, der noch nicht eingetreten ist.

**Der Move bricht zwei Adressen, und ihre Quelldatei ist eingefroren.**
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) trägt zwei Pfad-Links auf
den **unaufgelösten** Ort:

```sh
grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md          # 1
grep -cE '\]\(\.\./carveouts/(done/)?CO-001[^)]*\)' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md  # 2
```

*Accepted* heißt nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren; die Reparatur im
Artefakt ist gesperrt, und zwar für beide naheliegenden Formen — Adresse nachziehen und Adresse
entfallen lassen. **Das ist Zeichen für Zeichen die Lage, die
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) an
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) entschieden hat**
— nur mit einem anderen Carveout, einer anderen Quelldatei und **zwei** Referenzen statt einer.

### Warum die Entscheidung vor den Move gehört, und warum sie nicht abgeschrieben wird

**Zwei Quellen verbieten die Übertragung, und beide sind angenommen.**
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) schließt ihren
`ignore-refs`-Schlüssel extensional auf **ein zusätzliches** Paar und sagt, jedes weitere Paar sei
eine neue Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 — *„auch dann, wenn es dieselbe
Bedingung erfüllt"*. Sie führt `CO-001` in ihrem Kontext als **geladen** und ausdrücklich als
nicht gedeckt. [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5
verlangt für den nächsten Fall dasselbe, von der anderen Seite: er wird *„einzeln entschieden"*,
*„mit seiner eigenen Messung"*. **Eine Entscheidung, die den Fall von 0027 abschriebe, verletzte
beide.**

**Die Reihenfolge ist tragend und nicht ordnend.** Läuft [slice-113](slice-113-co-001-ist-faellig.md)
zuerst, entsteht mit seinem `git mv` ein `docs-check`-Befund in einem Artefakt, das niemand
anfassen darf — genau der Zustand, aus dem
[slice-132](../in-progress/slice-132-adaptions-block-ohne-totes-ziel.md) das Repo gerade geholt hat, und
dann unter Zeitdruck statt in einem eigenen Lauf. Der Preis der falschen Reihenfolge ist nicht
Aufwand, sondern ein rotes Gate mit gesperrter Reparatur.

### Was dieser Slice nicht ist

Er ist **nicht** die Auflösung von [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) und
**nicht** die shellcheck-Arbeit an den bats-Dateien — beides trägt
[slice-113](slice-113-co-001-ist-faellig.md), unverändert. Und er entscheidet **nicht** im Voraus,
welches Instrument richtig ist: ein drittes `ignore-refs`-Paar, das Ziel-Ende aus
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5, oder ein
vierter Weg, den die Messung im Lauf zeigt. **Welche Menge die Kandidaten bilden, ist hier nicht
behauptet** — eine Aufzählung wäre eine Vollständigkeitsaussage über eine Menge, und die braucht
ihr Kommando wie eine Zahl.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Die Entscheidung liegt in einem Artefakt ihrer schreibenden Rolle und ist extensional
      geschnitten.** Eine neue ADR (Architect,
      [`AGENTS.md`](../../../../AGENTS.md) §3.8) benennt das Instrument für die zwei Verweise, den
      Lauf, der es setzt, und den Moment relativ zum `git mv`. **Extensional heißt: kein
      Verzeichnis-Glob** — dieselbe Grenze, die
      [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
      [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) je ziehen, und
      [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) verwirft das Glob in ihrer
      Alternativen-Zeile `F'` bereits mit Begründung. Fällt die Wahl auf ein `ignore-refs`-Paar,
      ist es die **dritte** Senkung unter demselben Schlüssel und löst
      [`AGENTS.md`](../../../../AGENTS.md) §3.5 erneut aus. **Ein Ergebnis, das nur in diesem Plan
      steht, erfüllt den Punkt nicht.**
- [ ] **(2) Der Fall ist gemessen und nicht aus
      [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) übernommen.** In der
      Entscheidung stehen, je mit dem Kommando, das sie ausgibt: die Zahl der Pfad-Links auf
      `CO-001` aus [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md), der
      Status jener Datei, und die Zahl der `docs-check`-Befunde, die der Move erzeugt — Letztere
      an einer **Sonde**, nicht an einer Prognose: den `git mv` in einer Kopie außerhalb des
      Arbeitsbaums vollziehen, `make docs-check` fahren, die Befundliste zitieren. Dazu, wenn das
      Instrument ein Ventil ist, **beide Skopen je an einer roten Gegenprobe** und der Nachweis,
      dass die geprüfte Datei-Zahl sich nicht bewegt — zwei Läufe, ein Vergleich, kein gemerkter
      Wert.
- [ ] **(3) [slice-113](slice-113-co-001-ist-faellig.md) trägt die Entscheidung als
      Vorbedingung.** Sein §4-Start-Trigger nennt sie, und sein DoD-Punkt zum `git mv` verlangt
      danach `make docs-check` mit **0** Befunden. Damit hängt die Reihenfolge an einem Plan-Text,
      den der ausführende Lauf liest, statt an dieser Notiz. **Ein Wächter dafür existiert nicht**
      — kein Modul des Doku-Gates liest Lifecycle-Reihenfolgen —, und das steht hier, statt einen
      zu behaupten
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-/Reconciliation-Register: das Repo führt keines von beiden; das Item entfällt
      mit diesem Grund und wird in §7 notiert, nicht still übergangen. Träger für das
      Beobachtungs-Register ist [slice-137](slice-137-beobachtungs-register-bekommt-seinen-ort.md);
      das Reconciliation-Register entfällt dauerhaft — dieses Repo hat keinen Brownfield-Bootstrap.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure, nicht
      dieser Slice — dieses Repo fährt Wellen-Betrieb, und das gilt auch für wellenlose Slices.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/` | **neu**, durch den Architect | der Liefergegenstand aus DoD (1); dazu die Zeile im ADR-Index, der derselben Rolle gehört ([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| [`.d-check.yml`](../../../../.d-check.yml) | **nur, wenn das Instrument ein Ventil ist**, durch den Implementer | die Config-Zeile folgt der Entscheidung, sie ersetzt sie nicht; Zeile **und** Config-Kommentar mit Zeiger auf die neue ADR, wie bei den zwei bestehenden Paaren |
| [slice-113](slice-113-co-001-ist-faellig.md) | update, durch den Planner | die Vorbedingung aus DoD (3) — §4-Trigger und der `git mv`-Punkt |
| [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | **unangetastet** | *Accepted*, [`AGENTS.md`](../../../../AGENTS.md) §3.4; die zwei Adressen bleiben, wie sie sind |
| [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) | **unangetastet** | der Move gehört [slice-113](slice-113-co-001-ist-faellig.md); dieser Slice entscheidet, er vollzieht nicht |

**Der Commit-Zuschnitt folgt aus den beteiligten Rollen.** Die ADR und ihre Index-Zeile liegen in
einem Architect-Commit, der ausschließlich Artefakte dieser Rolle berührt
([`AGENTS.md`](../../../../AGENTS.md) §3.8); ein etwaiger Config-Eintrag liegt in einem
Implementer-Commit; die Vorbedingung in [slice-113](slice-113-co-001-ist-faellig.md) und die
Closure liegen in Planner-Commits.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit — der Slice ist ohne die
schreibende Rolle der ADR nicht ausführbar, und das ist die Bedingung aus DoD (1), keine
Formalie. **Zusätzlich:** [slice-113](slice-113-co-001-ist-faellig.md) liegt **nicht** in
`in-progress/`; läuft er parallel, entsteht der Befund, den dieser Slice verhindern soll.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung aus DoD (2) zeigt, dass
  der Move mehr als die zwei Verweise aus
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) bricht. Dann ist der
  Gegenstand eine **Häufung** und kein Einzelfall, und `modul-07-carveouts.md` §Werkzeug-Wahl führt
  bei Häufung ausdrücklich weg vom punktuellen Werkzeug.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Entscheidung eine Frage an eine höher
  rangierte Quelle aufwirft — etwa, ob [`AGENTS.md`](../../../../AGENTS.md) §3.4 das **Artefakt**
  oder seine **Aussage** bindet. [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md)
  führt jene Frage als Alternative `G` und verwirft sie **für ihren Lauf**, nicht für immer; dass
  sie hier wiederkehrt, wäre kein Fehlschlag, sondern ein Befund mit eigenem Adressaten.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **erstens** eine ADR mit Status *Accepted*, die das Instrument für die
zwei Verweise benennt und ihren Geltungsbereich extensional schließt — sichtbar in einem
Architect-Commit (`git log --stat`), nicht in diesem Plan. **Zweitens** trägt
[slice-113](slice-113-co-001-ist-faellig.md) die Vorbedingung in seinem §4 und den
`docs-check`-Nachweis in seinem `git mv`-Punkt
(`grep -c 'slice-141' docs/plan/planning/*/slice-113-co-001-ist-faellig.md` → mindestens **1**).
Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Entscheidung wird abgeschrieben statt getroffen.**
  [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) liest sich wie eine Vorlage,
  und ihr Fall ist bis auf die Zahl der Referenzen derselbe. Genau davor warnen beide Quellen:
  jene ADR verlangt für ein drittes Paar eine eigene Entscheidung *„auch dann, wenn es dieselbe
  Bedingung erfüllt"*, und
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Festlegung 5 verlangt eine
  **eigene Messung**. Eine ADR, die kein Kommando über diesem Baum führt, ist die eingetretene
  Form dieses Risikos. — **Ausgang:** <entfallen: DoD (2) ist mit Kommandos über diesem Baum
  belegt, Sonde eingeschlossen | eingetreten: die Entscheidung zitiert fremde Zahlen und wird
  zurückgewiesen>
- **Die dritte Senkung unter demselben Schlüssel ist eine Kaskade, wenn niemand sie zählt.** Nach
  [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
  [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) wäre ein Ventil hier das dritte
  Paar. `modul-07-carveouts.md` führt eine **Häufung** ausdrücklich nicht in eine Kaskade, und drei
  Fälle derselben Klasse in kurzer Folge sind der Anlass, die Klasse an der Wurzel zu fragen statt
  am dritten Vertreter. — **Ausgang:** <entfallen: die Entscheidung wägt das Instrument gegen die
  Wurzel ab und begründet die Wahl | eingetreten: die Wurzel-Frage bekommt einen eigenen Schnitt>
- **Der Restbreite-Wächter deckt ein drittes Paar, aber nicht seine Berechtigung.**
  `test/ignore-refs-restbreite.bats` misst, dass ein Paar höchstens einen Markdown-Link seiner
  Quelldatei stumm schaltet — er läuft über die vollständige Paar-Liste und fasst jedes neue Paar
  vom ersten Lauf an. Dass ein Paar **existieren darf**, misst er nicht; das hängt an
  [`AGENTS.md`](../../../../AGENTS.md) §3.5, und der hat keinen Sensor. — **Ausgang:** <weiter
  offen: die Aufnahme-Grenze ist prozessual und bleibt es | entfallen: das gewählte Instrument ist
  kein Ventil>
- **Der Slice hängt an einer Rolle, nicht an einem Kommando.** Ohne Architect-Lauf ist DoD (1)
  nicht erreichbar, und ein Planner- oder Implementer-Lauf, der ihn trotzdem „erledigt", verstößt
  gegen [`AGENTS.md`](../../../../AGENTS.md) §3.8. — **Ausgang:** <entfallen: die Entscheidung ist
  in einem Architect-Commit sichtbar (`git log --stat`) | eingetreten: Rückführung nach §4>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `docs/plan/adr/`, `docs/plan/planning/` und —
nur im Ventil-Ausgang — die Gate-Config im Wurzelverzeichnis. Alle fallen unter den Eintrag `*`
(gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) —
**alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit nach dem
*Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** keine Treffer, und der Grund ist die fehlende
Datei, nicht ein leeres Register (`find docs/plan -iname '*observation*' | wc -l` → **0**). Der
Träger für seine Entstehung ist
[slice-137](slice-137-beobachtungs-register-bekommt-seinen-ort.md).
