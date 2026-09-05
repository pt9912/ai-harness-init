# Slice slice-142: Die Verweis-Form für eingefrorene Artefakte bekommt einen Wächter

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet. **Bündel?** Nein — ein Wächter, eine DoD, kein zweiter
Slice, auf den er wartet. **Gemeinsames Closure-Kriterium?** Nein — jedes wäre die Abschrift seiner
eigenen DoD. **Auslöser reaktiv oder gewollt?** Reaktiv: eine angenommene Festlegung hat heute
keinen Sensor, und die ADR sagt das über sich selbst (§1). Der Gegenstand stammt **nicht** aus dem
Re-Baseline-Delta und belegt kein Closure-Kriterium von
[welle-10](../done/welle-10-re-baseline.md) §3. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Festlegung ohne Wächter ist eine Zusage, die kein Lauf hält — dieselbe Klasse eine Ebene über dem
Gate), [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) (Festlegung 3 ist der
Gegenstand, Folgepflicht 3 der Auftrag),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (Festlegung 2 — *Eigenschaft statt
Adresse* —, die Regel, deren dritte Anwendung Festlegung 3 ist),
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (das Artefakt, das
den Bestand um sein jüngstes Mitglied vermehrt hat),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test oben),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (das Gegenbeispiel wird einmal rot gesehen) und §3.4 (der
Bestand ist eingefroren und wird darum ausgenommen, nicht geheilt).

**Berührte Spec-Stellen:** `—`. Der Slice baut einen Wächter über Doku-Artefakten und berührt
keine Spec-Stelle.

**Verantwortlich:** — bis zur Priorisierung. Der Liefergegenstand ist ein Wächter und liegt damit
bei der **Implementer**-Rolle, wie Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine es als Default vorsieht.

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ein Artefakt mit Status `Accepted`, das einen Pfad-Link in das Carveout-Verzeichnis trägt, färbt
ein Ziel aus `make gates` rot — außer es gehört zum extensional genannten Bestand.**

### Der Befund: eine angenommene Festlegung ohne Lauf, der sie hält

[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 3 setzt die Form:
*„Ein Artefakt, das unveränderlich wird, nennt einen Carveout bei der Kennung, nicht als
Pfad-Link."* Ihr Träger ist der **Accept-Übergang**, also ein Rollen-Wechsel, und die ADR benennt
das als Lücke — *„Festlegung 3 hat heute keinen Sensor"* und, in Folgepflicht 3, *„Ohne ihn bleibt
Festlegung 3 eine Zusage ohne Wächter"*.

**Der Grund, warum die Form nötig ist, ist eine Regel und keine Vorsicht.**
`modul-07-carveouts.md` schreibt für die Auflösung eines Carveouts den `git mv` nach `done/` vor.
Jeder Pfad-Link auf einen **aktiven** Carveout trägt sein Verfallsdatum damit eingebaut: das
Ereignis, das er oft ankündigt, bricht ihn. Steht er in einem `Accepted`-Artefakt, sperrt
[`AGENTS.md`](../../../../AGENTS.md) §3.4 die Reparatur, und der Befund bleibt stehen, bis eine
eigene Entscheidung ihn ausnimmt. **Genau das ist zweimal passiert** —
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) auf der Datei-Achse,
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) auf der Referenz-Achse — und ein
dritter Fall ist geladen (unten).

### Der Bestand ist benannt und geschlossen — hier erhoben, nicht abgeschrieben

```sh
git grep -coE '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' | awk -F: '{s+=$NF} END{print s}'   # 33  Vorkommen
git grep -lE  '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' | wc -l                            #  5  Dateien
git grep -lE  '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' \
  | xargs grep -L '^\*\*Status:\*\* Accepted' | wc -l                                                                      #  0  nicht eingefroren
```

Verteilt auf drei Ziele: `CO-001` **2**, `CO-002` **30**, `CO-005` **1**
(`for co in CO-001 CO-002 CO-005; do printf '%s ' "$co"; git grep -coE "\]\(\.\./carveouts/(done/)?$co-[^)]*\)" -- 'docs/plan/adr/[0-9]*.md' | awk -F: '{s+=$NF} END{print s+0}'; done`).
**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Bestand, und der ausführende Lauf erhebt sie neu. Tragend
ist, dass alle fünf Quelldateien `Accepted` und damit unerreichbar sind: der Bestand wird
**ausgenommen**, nicht geheilt.

### Die Falle liegt in der Gestalt der Ausnahme, nicht in ihrer Existenz

**Eine datei-weite Ausnahme wäre blind für genau den Fall, den der Wächter fangen soll.** `CO-001`
ist geladen — sein Status führt *„Auflösung fällig"* —, und seine Auflösung bewegt zwei Verweise
in [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md); dieselbe Datei könnte
morgen einen dritten bekommen, wenn jemand sie ergänzte. Wäre die Ausnahme *„diese fünf Dateien
sind ausgenommen"*, bliebe das unbemerkt. Eine Ausnahme, die **Datei und Zahl** nennt, fängt den
Zuwachs; welche Form es genau wird, entscheidet der Lauf, und die Anforderung an sie steht in
DoD (2).

### Wo der Wächter sitzt, ist offen — und die Werkzeug-Frage gehört gestellt, nicht beantwortet

`make comment-claims` scheidet aus: sein Prüfbereich sind vier Pfad-Muster über `*.go` und `*.sh`,
und keine Markdown-Datei liegt darin
([`AGENTS.md`](../../../../AGENTS.md) §4). Zwei Kandidaten bleiben, und beide sind zu messen statt
zu vermuten:

- **Ein bats-Fall in `make gates`**, wie `test/ignore-refs-restbreite.bats` ihn für die
  Restbreite der Ventile fährt. Er liest Dateien und `grep`t — die Mittel reichen sichtbar aus.
- **Ein d-check-Modul.** Das nächstliegende ist `matrix`: es kennt Pfad-Klassen, eine
  `from`/`to`-Regel und ein `status`-Feld. Ob es *Status der Quelldatei* × *Ziel-Glob* verbinden
  kann, ist **nicht gemessen** und darf hier nicht behauptet werden. d-check ist ein Nachbar-Repo
  desselben Auftraggebers; eine fehlende Modul-Fähigkeit ist dort eine **Anforderung**, keine
  Grenze. Wer diesen Ausweg verwirft, verwirft ihn mit einer Sonde am gepinnten Werkzeug — nicht
  mit einem `--print-config`, das eine Beispiel-Config druckt und keine Schema-Liste
  ([slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) §7, Steering-Loop-Eintrag 1).

### Was dieser Slice nicht ist

Er ist **nicht** die Heilung des Bestands — die 33 Vorkommen bleiben, wo sie sind
([`AGENTS.md`](../../../../AGENTS.md) §3.4). Und er ist **nicht** die Entscheidung über `CO-001`:
die trägt [slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md), und sie hat einen
anderen Gegenstand — dort geht es um zwei bereits geschriebene Adressen, hier um jede künftige.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Der Wächter liegt in `make gates` und misst die Eigenschaft, nicht eine
      Namensliste.** Geprüft wird das Paar *Status `Accepted` in der Quelldatei* × *Markdown-Link,
      dessen Ziel im Carveout-Verzeichnis liegt* — mit **und** ohne `done/`-Segment, denn beide
      Formen kommen im Bestand vor. Ein Wächter, der die drei heutigen Kennungen `CO-001`,
      `CO-002`, `CO-005` aufzählt, erfüllt den Punkt **nicht**: er wäre über `CO-006` blind. Er
      erzeugt **kein** neues Gate-Ziel und keinen neuen Gate-Namen, sondern läuft additiv an einer
      bestehenden Stufe
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [ ] **(2) Der heutige Bestand ist extensional ausgenommen, und die Ausnahme fängt Zuwachs in
      einer bereits gelisteten Datei.** Kein Glob über das ADR-Verzeichnis, keine Ausnahme, die
      eine Datei als Ganzes blind macht — die Liste nennt je Quelldatei, wie viele solcher Links
      erlaubt sind, und ein zusätzlicher färbt rot. Die Zahlen werden **beim Bau erhoben**, mit den
      Kommandos aus §1, nicht von dort übernommen
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 1). Die Ausnahme trägt am Ort ihren Grund und einen Zeiger auf
      [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md).
- [ ] **(3) Das Gegenbeispiel ist einmal rot gesehen, und sein Fall liegt in
      `test/mutations/`.** Rot färbt: ein Pfad-Link in das Carveout-Verzeichnis in einem
      `Accepted`-Artefakt, das nicht in der Ausnahme steht — **und** ein zusätzlicher Link in einem,
      das darin steht. Beide Richtungen einmal gefahren, beide Ausgaben zitiert
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Die Fehlermeldung nennt die Festlegung, gegen
      die verstoßen wurde, und den Ort, an dem die Ausnahme stünde.
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben: neue `BEO-<NNN>` oder Zähler +1 mit Beleg in
      [`observations/README.md`](../observations/README.md) — *keine Beobachtung angefallen* ist ebenfalls eine
      Antwort und wird in §7 notiert. Das Reconciliation-Register entfällt dauerhaft: dieses Repo
      hat keinen Brownfield-Bootstrap.
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
| `test/` | **neu** — ein bats-Fall, **oder** entfällt | der Ort aus §1, Kandidat 1; die Wahl fällt im Lauf und wird begründet |
| [`.d-check.yml`](../../../../.d-check.yml) | update — **nur**, wenn Kandidat 2 trägt | ein `matrix`-Regelpaar statt eines Eigenbaus; ob es die Status-Achse kennt, ist zu messen |
| `test/mutations/` | **neu** | der Fall aus DoD (3): der Wächter muss unter einer Mutation rot werden und bleibt sonst ungedeckt ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `docs/plan/adr/` | **unangetastet** | der Bestand ist eingefroren; der Slice nimmt aus, er heilt nicht |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): das WIP-Limit ist frei. Eine inhaltliche Vorbedingung hat
dieser Slice nicht — [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) ist
*Accepted*, und ihre Folgepflicht 3 ist damit fällig.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung zeigt, dass der
  Gegenstand bei d-check liegt und dessen `matrix`-Modul die Status-Achse **nicht** kennt. Dann
  zerfällt der Slice in *Grenze nennen* (die Anforderung an das Nachbar-Repo, hier) und *Grenze
  schließen* (dort), und die Trennung ist ein Schnitt, kein Ausweg.
- `in-progress` → `open` (blockiert — Carveout?): wenn der Bestand sich zwischen Schnitt und Lauf
  so bewegt hat, dass die extensionale Ausnahme zur Verwaltungsaufgabe wird — mehr als eine
  Handvoll Zeilen, oder eine Datei, die laufend wächst. Dann ist die Ausnahme-Form falsch gewählt
  und die Frage geht zurück an den Schnitt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **erstens** `make gates` grün mit dem neuen Wächter in seiner
Ausgabe — der Fall ist in der Gate-Ausgabe namentlich sichtbar, nicht nur im Exit-Code.
**Zweitens** zwei zitierte rote Läufe aus DoD (3), je mit der Mutation, die sie erzeugt hat, und
je mit der Fehlermeldung, die der Wächter dabei ausgibt — gelesen, nicht nur gezählt. Dazu die
Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Wächter misst seine eigene Ausnahme statt der Eigenschaft.** Eine Prüfung, deren Liste
  gerade den heutigen Bestand abbildet, ist über jedem heutigen Baum grün und kann unter keiner
  Mutation rot werden, die den Bestand nicht anfasst — das stille Grün aus
  [`AGENTS.md`](../../../../AGENTS.md) §3.6. Deshalb verlangt DoD (3) **zwei** Richtungen: ein
  neues Artefakt **und** ein zusätzlicher Link in einem gelisteten. — **Ausgang:** <entfallen:
  beide Richtungen sind rot gesehen und zitiert | eingetreten: der Fall wird umgebaut, bis er
  beide fängt>
- **Die Status-Erkennung ist eine Zeichenkette und kein Feld.** `Accepted` steht als
  `**Status:** Accepted` im Kopf; eine ADR mit abweichender Schreibweise, mit Zusatz in derselben
  Zeile oder mit `Superseded` fiele durch oder würde falsch gefasst. Die Erkennung gehört
  gemessen — über **alle** ADR-Dateien, nicht über die fünf des Bestands. — **Ausgang:**
  <entfallen: die Erkennung ist über dem vollständigen ADR-Verzeichnis gefahren und ihre Trefferzahl
  steht mit ihrem Kommando in der Closure-Notiz | weiter offen: die abweichenden Formen sind
  benannt und tragen einen eigenen Posten>
- **Die Werkzeug-Frage wird mit einer Trefferliste beantwortet statt mit einer Sonde.** Ob
  d-checks `matrix`-Modul *Status der Quelle* × *Ziel-Glob* kann, entscheidet eine Sonde am
  gepinnten Werkzeug — nicht ein `--print-config` und nicht ein `grep` über eine Doku. Dieselbe
  Klasse hat in [slice-132](../done/slice-132-adaptions-block-ohne-totes-ziel.md) einen Carveout,
  eine ADR und einen datei-weiten Ausschluss getragen, die alle enger hätten ausfallen können. —
  **Ausgang:** <entfallen: die Wahl zwischen den zwei Orten steht mit ihrer Messung in der
  Closure-Notiz | eingetreten: die Entscheidung wird mit einer Sonde wiederholt>
- **Der Wächter fasst nur ADR-Dateien, die Festlegung spricht von mehr.** Festlegung 3 bindet
  *„jedes Artefakt, das nach Abschluss nicht mehr angefasst wird"* — ausdrücklich auch
  Rollen-Reports und Closure-Notizen. Der Bestand aus §1 ist über `docs/plan/adr/[0-9]*.md`
  erhoben; ein Wächter mit demselben Prüfbereich deckt die Festlegung nur zum Teil. Was er
  **nicht** deckt, gehört an den Wächter geschrieben, nicht in eine Zusage. — **Ausgang:**
  <entfallen: der Prüfbereich ist so weit wie die Festlegung | weiter offen: die Differenz steht
  am Wächter und trägt einen eigenen Posten>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `test/` und — nur im Ausgang „d-check-Modul" —
die Gate-Config im Wurzelverzeichnis. Beide fallen unter den Eintrag `*` (gesamtes Repo) der
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) —
**alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit nach dem
*Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** die Sichtung ist **offen** — sie ist vor der
Bearbeitung gegen [`observations/README.md`](../observations/README.md) zu fahren, und ihr Ergebnis gehört ins
Kriterium *Evidenz-/Diskrepanz-Risiko* unten. Sie steht hier nicht als Ergebnis, weil der Stand des
Registers zwischen Schnitt und Bearbeitung wandert.
