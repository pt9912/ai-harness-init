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
eingetreten und sein Vollzug bricht Adressen in 30 (gemessen, ADR-0098) teils eingefrorenen Quellen (§1). Der Gegenstand
stammt **nicht** aus dem Re-Baseline-Delta und belegt kein Closure-Kriterium von
[welle-10](../done/welle-10-re-baseline.md) §3; er gehört darum in keine Welle. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Gate, dessen einziger Befund unbehebbar ist, erzieht dazu, Rot zu überlesen — dieselbe Kehrseite
des halluzinierten Gates, die schon
[slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) getragen hat),
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (eine der eingefrorenen
Quellen, und Festlegung 5, die den nächsten Fall ausdrücklich einzeln stellt),
[`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) (die Annahme ist
Auftraggeber-Entscheidung),
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) (dieselbe Klasse, an
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) entschieden — sie
deckt diesen Fall **nicht**, und Festlegung 3 bindet die Verweis-Form für künftige Artefakte),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — *Eigenschaft statt
Adresse*),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test oben),
[`AGENTS.md`](../../../../AGENTS.md) §3.4 (das Artefakt ist eingefroren), §3.5 (jede Senkung eigene
ADR), §3.11 (Adressen in einfrierenden Artefakten, beide Formen) und §3.8 (die
Entscheidung schreibt der Architect — dieser Slice ist geschnitten, nicht ausgeführt vom Planner).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt eine Architektur-Entscheidung und eine
Gate-Config-Frage, keine Spec-Stelle.

**Verantwortlich:** Architect (pt9912). Der Liefergegenstand ist eine ADR, und die schreibt
nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 der **Architect**; das Feld weicht damit von der
Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine nennt.

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Wenn [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) nach `carveouts/done/` wandert, ist
vorher entschieden, was mit den Adressen geschieht, die dieser Move in 30 (gemessen, ADR-0098) teils eingefrorenen
Quellen bricht.** Der Gegenstand ist eine **Architect-Entscheidung** (ADR, §1 *Der Auftrag*); die
Annahme einer ADR ist Auftraggeber-Entscheidung
([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)).

**Zur Neuzerlegung zurückgestellt.** Der Slice bleibt in `next/` (kein Claim, kein Move). Die
Rückführungs-Bedingung aus §4 ist bei der Vorab-Messung **eingetreten**: der Befund ist eine
Häufung, kein Einzelfall mit zwei Verweisen. Die frühere Fassung dieses §1 und die Zahl „zwei" sind
durch den Messbefund unten ersetzt.

### Der Befund: ein fälliger Carveout mit einer geladenen Adresse

**Der Trigger ist eingetreten, und der Carveout sagt es selbst.** Sein Status-Kopf führt
*„Aktiv — **Auflösung fällig**, nicht offen"*
(`grep -c 'Auflösung fällig' docs/plan/carveouts/CO-001-bats-shell-lint.md` → **1**), seine letzte
Prüfung ist der welle-12-Closure-Audit vom 2026-08-27, und sein Folge-Slice
[slice-113](../open/slice-113-co-001-ist-faellig.md) liegt geschnitten in `open/`. Dessen DoD (3) macht
den Ausgang zur **Verzeichnis-Position**: der Carveout wandert per `git mv` nach `done/` — oder er
bekommt einen Trigger, der noch nicht eingetreten ist.

**Der Move bricht eine Häufung von Adressen, und ihre Quellen sind überwiegend eingefroren.**
Die Sonde (frischer Klon unter `.harness/state/sonde`, `git mv` von `CO-001` nach
`carveouts/done/`, dann `make docs-check`) misst: **2947 Dateien geprüft, 61 Befunde** — **60
Link-Befunde plus 1 Code-Pfad-Befund**, aus rund **40 Quellen**. Eingefroren sind darunter
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (*Accepted*, zwei Pfad-Links),
Zeitdokumente unter `docs/reviews/`, `docs/plan/planning/done/` (7 Slices und 14 Welle-Dateien)
und der aufgelöste Carveout CO-003. Die Befundliste stammt aus dieser Sonde; das Mess-Kommando
ist der Sonden-Lauf selbst (`make docs-check` im Klon nach dem `git mv`), nicht ein `grep` über
diesen Baum, und die Entscheidung wiederholt ihn mit eigener Ausgabe (DoD 2).

*Accepted* heißt nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefroren, und ein
Zeitdokument ist Chronik von Beruf; die Reparatur in der Quelle ist gesperrt, und zwar für beide
naheliegenden Formen — Adresse nachziehen und Adresse entfallen lassen. **Das ist die Klasse, die
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) an
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) für eine
einzelne Referenz entschieden hat** — hier als Häufung mit anderer Größenordnung. **Beide Adress-Formen**
sind betroffen, Markdown-Link **und** Code-Span (die 60 Links und der eine Code-Pfad fallen auf
verschiedene Module des Doku-Gates); die Entscheidung nach
[`AGENTS.md`](../../../../AGENTS.md) §3.11 misst über beide.

**„Drittes `ignore-refs`-Paar" ist veraltet.** Der Schlüssel führt inzwischen die Paare 1 bis 9
plus Baum-Globs; jeder weitere Eintrag ist nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 eine
eigene ADR (Senkung, Auftraggeber-Entscheidung). Die Messung der Paar-Zahl steht in der
Entscheidung neben ihrem Kommando (`grep -n 'ignore-refs' -A 40 .d-check.yml`), nicht hier.

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

**Die Reihenfolge ist tragend und nicht ordnend.** Läuft [slice-113](../open/slice-113-co-001-ist-faellig.md)
zuerst, entsteht mit seinem `git mv` ein `docs-check`-Befund in einem Artefakt, das niemand
anfassen darf — genau der Zustand, aus dem
[slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) das Repo gerade geholt hat, und
dann unter Zeitdruck statt in einem eigenen Lauf. Der Preis der falschen Reihenfolge ist nicht
Aufwand, sondern ein rotes Gate mit gesperrter Reparatur.

### Was dieser Slice nicht ist

Er ist **nicht** die Auflösung von [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) und
**nicht** die shellcheck-Arbeit an den bats-Dateien — beides trägt
[slice-113](../open/slice-113-co-001-ist-faellig.md), unverändert, und der bleibt hinter diesem Slice
(§4). Er wählt auch **nicht** vorab zwischen den Optionen unten; das tut der Architect.

### Der Auftrag an den Architect: vier Optionen, eine ADR

Die ADR wählt eine der folgenden Optionen oder begründet eine fünfte, je mit der Messung aus
DoD (2). **Die Aufzählung ist der Auftrag-Stand, keine Vollständigkeitsaussage.**

- **(a) `CO-001` bleibt ortsfest, mit neuem Trigger.** Kein Move, keine gebrochene Adresse. Offen:
  das widerspricht der Verzeichnis-Position als Zustand
  (Baseline-Regelwerk `modul-07-carveouts.md`) — ein fälliger Carveout bliebe im aktiven
  Verzeichnis.
- **(b) Link-Nachzug in allen änderbaren Dateien plus Ventil oder Glob für die eingefrorenen
  Quellen.** Eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5: eigene ADR,
  **Auftraggeber-Entscheidung**; ein Glob widerspricht der extensionalen Grenze von
  [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
  [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md).
- **(c) Eine ADR „Carveout-Adressen in eingefrorenen Artefakten stehen per Kennung"** —
  [`AGENTS.md`](../../../../AGENTS.md) §3.11 für Carveouts — **plus einmalige Behandlung des
  Bestands** (die 30 Quellen). Offen: wie der Bestand ohne Eingriff in eingefrorene Texte
  behandelt wird.
- **(d) `CO-001` nach `done/` verschieben und am alten Ort einen gekürzten Stub lassen** (Muster
  der Archiv-Stubs: hält Verweise gültig, ohne Ventil, keine Senkung). Offen: verwischt ein Stub
  im flachen `carveouts/` die Verzeichnis-Position als Zustand?

**Die Annahme der ADR ist Auftraggeber-Entscheidung**
([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)); der Architect
schlägt vor, er nimmt nicht an.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Die Entscheidung liegt in einem Artefakt ihrer schreibenden Rolle und ist extensional
      geschnitten.** Eine neue ADR (Architect,
      [`AGENTS.md`](../../../../AGENTS.md) §3.8) wählt eine der vier Optionen aus §1 (oder begründet eine
      fünfte) für die Häufung, nennt den Lauf, der sie setzt, und den Moment relativ zum `git mv`.
      Wo die Wahl ein Ventil ist, gilt die extensionale Grenze von
      [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
      [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md), und jeder weitere
      `ignore-refs`-Eintrag ist eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit
      eigener ADR. Die Annahme ist Auftraggeber-Entscheidung. **Ein Ergebnis, das nur in diesem
      Plan steht, erfüllt den Punkt nicht.**
- [x] **(2) Der Fall ist gemessen und nicht aus
      [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) übernommen.** In der
      Entscheidung stehen, je mit dem Kommando, das sie ausgibt: die Zahl der
      Befunde, die der Move erzeugt, getrennt nach **beiden Adress-Formen** (Markdown-Link und
      Code-Span), die Zahl und der Status der Quellen, und die Paar-Zahl des `ignore-refs`-Schlüssels
      — die Befunde an einer **Sonde**, nicht an einer Prognose: den `git mv` in einem frischen
      Klon außerhalb des Arbeitsbaums vollziehen, `make docs-check` fahren, die Befundliste
      zitieren (Stand der Vorab-Messung: 2947 Dateien, 61 Befunde). Dazu, wenn das
      Instrument ein Ventil ist, **beide Skopen je an einer roten Gegenprobe** und der Nachweis,
      dass die geprüfte Datei-Zahl sich nicht bewegt — zwei Läufe, ein Vergleich, kein gemerkter
      Wert.
- [x] **(3) [slice-113](../open/slice-113-co-001-ist-faellig.md) trägt die Entscheidung als
      Vorbedingung.** Sein §4-Start-Trigger nennt sie, und sein DoD-Punkt zum `git mv` verlangt
      danach `make docs-check` mit **0** Befunden. Damit hängt die Reihenfolge an einem Plan-Text,
      den der ausführende Lauf liest, statt an dieser Notiz. **Ein Wächter dafür existiert nicht**
      — kein Modul des Doku-Gates liest Lifecycle-Reihenfolgen —, und das steht hier, statt einen
      zu behaupten
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register fortgeschrieben: neue `BEO-<NNN>` oder Zähler +1 mit Beleg in
      [`observations/README.md`](../observations/README.md) — *keine Beobachtung angefallen* ist ebenfalls eine
      Antwort und wird in §7 notiert. Das Reconciliation-Register entfällt dauerhaft: dieses Repo
      hat keinen Brownfield-Bootstrap.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
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
| [`.d-check.yml`](../../../../.d-check.yml) | **nur, wenn das Instrument ein Ventil ist (Option b)**, durch den Implementer | die Config-Zeile folgt der Entscheidung, sie ersetzt sie nicht; Zeile **und** Config-Kommentar mit Zeiger auf die neue ADR, wie bei den bestehenden Paaren |
| änderbare Quellen mit Adresse auf `CO-001` | **nur nach Option b oder c**, durch den Implementer | Nachzug bzw. Kennungs-Form; die eingefrorenen Quellen bleiben unberührt |
| [slice-113](../open/slice-113-co-001-ist-faellig.md) | update, durch den Planner | die Vorbedingung aus DoD (3) — §4-Trigger und der `git mv`-Punkt |
| [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | **unangetastet** | *Accepted*, [`AGENTS.md`](../../../../AGENTS.md) §3.4; eine von 30 (gemessen, ADR-0098) teils eingefrorenen Quellen, ihre Adressen bleiben, wie sie sind |
| [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) | **unangetastet** | der Move gehört [slice-113](../open/slice-113-co-001-ist-faellig.md); dieser Slice entscheidet, er vollzieht nicht |

**Der Commit-Zuschnitt folgt aus den beteiligten Rollen.** Die ADR und ihre Index-Zeile liegen in
einem Architect-Commit, der ausschließlich Artefakte dieser Rolle berührt
([`AGENTS.md`](../../../../AGENTS.md) §3.8); ein etwaiger Config-Eintrag liegt in einem
Implementer-Commit; die Vorbedingung in [slice-113](../open/slice-113-co-001-ist-faellig.md) und die
Closure liegen in Planner-Commits.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit — der Slice ist ohne die
schreibende Rolle der ADR nicht ausführbar, und das ist die Bedingung aus DoD (1), keine
Formalie. **Zusätzlich:** [slice-113](../open/slice-113-co-001-ist-faellig.md) liegt **nicht** in
`in-progress/`; läuft er parallel, entsteht der Befund, den dieser Slice verhindern soll.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **eingetreten, vor dem Claim.** Die
  Sonde (§1) zeigt 61 Befunde aus 30 Quellen statt der zwei Verweise aus
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md): eine **Häufung**, und
  `modul-07-carveouts.md` §Werkzeug-Wahl führt bei Häufung ausdrücklich weg vom punktuellen
  Werkzeug. Der Slice ist daher in `next/` neu zerlegt (§1 *Der Auftrag*), nicht geclaimt.
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
zwei Verweise benennt (Annahme durch den Auftraggeber) — sichtbar in einem
Architect-Commit (`git log --stat`), nicht in diesem Plan. **Zweitens** trägt
[slice-113](../open/slice-113-co-001-ist-faellig.md) die Vorbedingung in seinem §4 und den
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
  Form dieses Risikos. — **Ausgang:** entfallen: [`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md) führt die Sonde (61 Befunde, 30 Dateien) und jede Zählung mit ihrem Kommando; die Review-Runde hat sie bestätigt.
- **Ein Ventil für die Häufung ist eine Kaskade, wenn niemand sie zählt.** Der Schlüssel führt
  bereits die Paare 1 bis 9 plus Baum-Globs; jeder weitere Eintrag ist eine eigene ADR nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 und Auftraggeber-Entscheidung. `modul-07-carveouts.md`
  führt eine **Häufung** ausdrücklich nicht in eine Kaskade; die Optionen (c) und (d) in §1 fragen
  die Klasse an der Wurzel (§3.11). — **Ausgang:** entfallen: die ADR wägt die Optionen A bis G in ihrer Alternativen-Tabelle gegeneinander ab und begründet G.
- **Der Restbreite-Wächter deckt ein weiteres Paar, aber nicht seine Berechtigung — und eine
  Häufung nicht ohne Weiteres.**
  `test/ignore-refs-restbreite.bats` misst, dass ein Paar höchstens einen Markdown-Link seiner
  Quelldatei stumm schaltet — er läuft über die vollständige Paar-Liste und fasst jedes neue Paar
  vom ersten Lauf an. Für 30 Quellen mit teils mehreren Links passt ein Paar-Ventil nicht in
  diese Grenze. Dass ein Paar **existieren darf**, misst er nicht; das hängt an
  [`AGENTS.md`](../../../../AGENTS.md) §3.5, und der hat keinen Sensor. — **Ausgang:** weiter offen: die Aufnahme-Grenze ist prozessual und bleibt es, jetzt mit dem zehnten Paar — Register `BEO-ALL/ignore-refs-paar-aufnahme-hat-keinen-sensor`.
- **Option (d) verwischt die Verzeichnis-Position als Zustand.** Ein Stub im flachen `carveouts/`
  könnte als aktiver Carveout gelesen werden; kein Sensor trennt Stub und Carveout dort. —
  **Ausgang:** entfallen: die ADR wählt D nicht und führt es als Rückfalloption, weil die Verzeichnis-Position binär ist.
- **Der Slice hängt an einer Rolle, nicht an einem Kommando.** Ohne Architect-Lauf ist DoD (1)
  nicht erreichbar, und ein Planner- oder Implementer-Lauf, der ihn trotzdem „erledigt", verstößt
  gegen [`AGENTS.md`](../../../../AGENTS.md) §3.8. — **Ausgang:** entfallen: die Entscheidung liegt in den Architect-Commits `ba622589`, `b44b9637` und `a5ee6205` (`git log --stat`, Rolle in der Message).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Gegenstand: geliefert.** Die Entscheidung liegt in
[`ADR-0098`](../../adr/0098-co-001-aufloesung-reiner-move-nachzug-und-ein-namentliches-paar-fuer-adr-0021.md)
(`Accepted` am 2026-10-21, Architect-Commits `ba622589`, `b44b9637`, `a5ee6205`). Weg nach `done/` ist
`in-progress → done` mit nachgeholtem Claim (WIP war frei): `open|next → done` verlangt einen Gegenstand,
den ein anderer Slice übernimmt oder der entfällt, und dieser Slice hat seinen Gegenstand geliefert.

**DoD-Verdikt.** (1) erfüllt — die ADR wählt G (reiner Move, Nachzug in 29 Quellen, ein namentliches
Paar für `ADR-0021`), nennt den ausführenden Lauf (Implementer von slice-113) und den Moment (Move erst
nach der Annahme, Nachzug im zweiten Commit). (2) erfüllt — Sonde und alle Zählungen stehen mit ihrem
Kommando in der ADR (§Kontext), beide Skopen des Paares je an einer roten Gegenprobe; die Review-Runde
`2026-10-21-adr-0098-review` fand 0 HIGH und 0 MEDIUM. (3) erfüllt —
`grep -c 'ADR-0098' docs/plan/planning/open/slice-113-co-001-ist-faellig.md` → **4**; sein §4 nennt die
Vorbedingung, sein DoD (3) den `docs-check`-Nachweis. Ein Verifier-Lauf fand für diesen Slice nicht statt;
die Prüfung der drei Punkte ist die des Planners mit den genannten Kommandos.

**Prämisse ersetzt.** *„Rund 40 überwiegend eingefrorene Quellen"* war eine Schätzung; gemessen sind es 30
Dateien, 29 reparierbar, weil die Nachzug-Regel für Zeitdokumente erst nach dem Schnitt entschieden wurde.

**Steering-Loop-Eintrag (benannte Lücke).** Kein Sensor liest die Reihenfolge *Entscheidung vor Move*;
Träger ist der Plan-Text (slice-113 §4, ADR-0098 Festlegung 4), Gegenstück
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6). Eine Prämisse
über Zahl und Status von Quellen ist Prognose, bis eine Sonde sie misst.

**Beobachtungs-Register.** Neu:
[`BEO-ALL/ignore-refs-paar-aufnahme-hat-keinen-sensor`](../observations/BEO-ALL/ignore-refs-paar-aufnahme-hat-keinen-sensor/observation.md),
ein Beleg (Ausgang des dritten Risikos aus §6).

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

**Vorgelagert — offene Beobachtungen sichten:** die Sichtung ist **offen** — sie ist vor der
Bearbeitung gegen [`observations/README.md`](../observations/README.md) zu fahren, und ihr Ergebnis gehört ins
Kriterium *Evidenz-/Diskrepanz-Risiko* unten. Sie steht hier nicht als Ergebnis, weil der Stand des
Registers zwischen Schnitt und Bearbeitung wandert.
