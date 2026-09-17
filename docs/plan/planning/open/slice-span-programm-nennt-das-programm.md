# Slice slice-span-programm-nennt-das-programm: Das Feld `program` nennt das Programm, nicht das Navigations-Segment davor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht beobachtet keine Closure-Bedingung mehr, als diese DoD belegt.

**Bezug:**
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (*Accepted* — die fail-closed-Linie,
die pro Segment gilt und beim Segment-Wechsel mitgeht),
[`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
(das Technik-Stratum ist ohne Vertragsänderung fortschreibbar — das Lastenheft wird nicht
angefasst),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(Setzung 2 — der Bestand ist gitignored und maschinenlokal; die Probe gehört gefahren, nicht
zitiert).

**Berührte Spec-Stellen:**
[`SPEC-021`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) und
[`SPEC-031`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 —
beide beschreiben die heutige Mechanik wörtlich und werden nachgezogen.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `commandProgram()` in
[`internal/span/span.go`](../../../../internal/span/span.go) überspringt führende
**Navigations-Segmente** (`cd`, `set`), die durch `&&` oder `;` abgetrennt sind, und nimmt das
erste Token des nächsten Segments;
[`SPEC-021`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) und
[`SPEC-031`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) beschreiben danach,
was das Feld misst.

**Übernimmt:** — nichts. Die Übernahme von `slice-204-das-programm-feld-nennt-das-programm` ist
gestrichen.

### Die Übernahme ist gestrichen, der Gegenstand bleibt beim Geber

Eine Übernahme von **einem** Geber ist keine Gruppierung, sondern ein Identitäts-Wechsel. Verlangt
wird er von keiner Quelle:
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
setzt die Namens-Form für jede **neu vergebene** Kennung, *der Bestand behält seine Nummer*.
Bezahlt würde er mit einer vollständigen Stilllegung des Gebers — ein Ausgang für jedes seiner
Risiken, `Gegenstand:`-Zeile, Register-Beleg, Closure-Notiz, `git mv` —, also mit einem
Closure-Vorgang für einen Gegenstand, den derselbe Plan unverändert weiterträgt.

**Der Unterschied zum Geber ist die Darstellung, nicht der Schnitt.** Beide führen **einen**
Liefer-Punkt und begründen ihn gleich: Spec-Zeilen und Mutations-Fälle sind die Form derselben
Lieferung, nicht zusätzlicher Umfang. **Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
grep -cE '^\*\*Liefer-Punkt 1|^\*\*Ein Liefer-Punkt' \
  docs/plan/planning/next/slice-204-das-programm-feld-nennt-das-programm.md \
  docs/plan/planning/open/slice-span-programm-nennt-das-programm.md          # je 1
```

Eine Verschachtelung der Unterpunkte in Kontrollkästchen ist eine Umschrift am Plan; sie ist am
Geber selbst möglich, denn der liegt in `next/` und ist nicht eingefroren. Ein Identitäts-Wechsel
ist dafür nicht der Preis wert.

**Folge:** `slice-204-das-programm-feld-nennt-das-programm` bleibt unter seiner Kennung in `next/`
und führt den Gegenstand weiter — samt der Eigentumsfrage über das Technik-Stratum, die er in
seiner DoD benennt. **Dieser Plan wird in Stufe 2b stillgelegt** — `git mv` nach `done/`, §7 trägt
`Gegenstand: entfallen — der Gegenstand bleibt bei slice-204-das-programm-feld-nennt-das-programm`,
die Liefer-Punkte bleiben leer (Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice,
dessen Gegenstand ein anderer übernimmt, Wegfall-Hälfte). Gelöscht wird er nicht: Löschen machte
seine Kennung ununterscheidbar von einer, die es nie gab.

**Der Befund gehört gefahren, nicht zitiert.** Der Span-Bestand liegt gitignored und
maschinenlokal; eine Zahl aus einem fremden Lauf sagt über den eigenen nichts
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
cd .harness/state/spans
T=$(cat *.jsonl | grep -c '"tool":"Bash"')
K=$(cat *.jsonl | grep '"tool":"Bash"' | grep -coE '"program":"(cd|set|until|while|for|if)"')
echo "$T Bash-Spans, $K Konstrukt, $(( K * 100 / T ))%"
cat *.jsonl | grep '"tool":"Bash"' | grep -oE '"program":"[^"]*"' | cut -d'"' -f4 \
  | sort | uniq -c | sort -rn | head -5
```

[`SPEC-021`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) verspricht mit
`program` die Antwort auf *„Welches Programm lief?"*; solange das erste Token einer Zeile ein
Shell-Konstrukt ist, antwortet der Wert mit dem Konstrukt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Das Lastenheft wird nicht angefasst.** Das Technik-Stratum ist ohne Vertragsänderung
  fortschreibbar
  ([`MR-019`](../../../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence))
  — eine Vertragsänderung wäre ein **anderer Vorgang**.
- **Die fail-closed-Linie wird nicht gelockert.** `TOKEN=abc gh pr create` hinter einem
  Segment-Wechsel ergibt weiterhin **nichts**; wer das Segment wechselt, nimmt die Linie mit. Der
  **Bestand** dieser Zusage bleibt stehen, samt dem Wächter, der ihn hält.
- **Die Menge der Navigations-Segmente wird nicht über `cd` und `set` hinaus geöffnet.** Jede
  weitere Aufnahme ist eine eigene Entscheidung mit eigenem Gegenbeispiel — **anderer Vorgang**.
- **Die Eigentumsfrage über das Technik-Stratum wird benannt, nicht entschieden.** Für dieses
  Stratum benennt keine Quelle eine schreibende Rolle; die Adresse ist
  `slice-151-spec-straten-haben-eine-schreibende-rolle`, ein **Folge-Slice**. Eine aus
  Zweckmäßigkeit abgeleitete Rolle wäre genau der Befund, den er auflösen soll.

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

**Ein Liefer-Punkt.** Die Spec-Zeilen und die Mutations-Fälle sind die **Form** derselben
Lieferung, nicht zusätzlicher Umfang; jede Zeile mit dem Kommando, das sie **rot** färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **`commandProgram()` überspringt führende Navigations-Segmente.** Drei Gegenbeispiele, je
      einmal **rot gesehen**:
  - [ ] `cd /x && make gates` → `make`.
  - [ ] `cd /x && TOKEN=abc gh pr create` → **nichts**. Das ist das **wichtigste** Kriterium: Die
        fail-closed-Linie aus [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) gilt
        **pro Segment** — die Verbesserung darf nicht das Loch öffnen, das der heutige Code
        geschlossen hat.
  - [ ] `TestCommandProgramSkipsAssignments` bleibt **grün** — die bestehende Zusage wird nicht
        umgeschrieben, um die neue zu ermöglichen.
  - [ ] **`argc` trägt eine gesetzte Bedeutung:** Argumente des **gewählten Segments** statt der
        ganzen Zeile. Für `cd /x && make gates` ist `argc` `1`, nicht `4` — eine Setzung, die in
        der Spec-Zeile steht, sonst behauptet das Feld weiter etwas anderes, als es misst.
  - [ ] Ein Fall in [`test/mutations/`](../../../../test/mutations) trifft die **Segment**-Grenze,
        nicht nur den Happy Path; ohne ihn ist die Zusage unbewacht. **Rot:** `make mutate`.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] **Doku-Update — berührt ist das Technik-Stratum.**
      [`SPEC-021`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) und
      [`SPEC-031`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) beschreiben
      heute *„erstes Token nach übersprungenen `NAME=WERT`-Präfixen"* und wären danach falsch; sie
      werden nachgezogen. Der Lauf hält in §7 fest, dass für dieses Stratum **keine Quelle** eine
      schreibende Rolle benennt, und nennt `slice-151-spec-straten-haben-eine-schreibende-rolle` als
      deren Adresse — ohne daraus eine Zuständigkeit abzuleiten.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/span/span.go`](../../../../internal/span/span.go) | update | `commandProgram()` überspringt führende Navigations-Segmente; `argc` misst das gewählte Segment |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 | update | `SPEC-021` und `SPEC-031` beschreiben danach, was das Feld misst |
| `internal/span` (Wächter) | update | je ein Fall Happy/Boundary/Negative über der Segment-Grenze |
| [`test/mutations/`](../../../../test/mutations) | neu | der Fall trifft die Segment-Grenze, nicht den Happy Path |

**Optional: Ansatz als Liste, wenn eine Zeile pro Datei nicht trägt** — z. B.
eine Schnittstellenänderung über viele gleichrangige Dateien mit derselben
Begründung, oder ein Ansatz, der sich nicht auf eine Datei herunterbrechen
lässt. Ergänzt die Tabelle, ersetzt sie nicht:

- Die Segment-Zerlegung läuft **vor** der Zuweisungs-Prüfung, nicht danach: sonst entscheidet die
  Reihenfolge darüber, ob die fail-closed-Linie im gewählten Segment überhaupt noch greift.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit des Rolleninhabers ist frei, und der übernommene
Slice liegt in `done/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Segment-Zerlegung verlangt einen
  echten Shell-Parser statt einer Trennung an `&&` und `;`. Das ist ein anderer Gegenstand und
  wird eigens geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Die fail-closed-Linie lässt sich pro Segment
  nicht halten, ohne die bestehende Zusage umzuschreiben.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` ist grün, `make mutate` meldet **keinen** Befund, und
   `TestCommandProgramSkipsAssignments` ist unverändert grün.
2. Die drei Gegenbeispiele aus §2 sind je einmal mit gelesener Ausgabe rot gesehen; der Beleg steht
   im Umsetzungs-Commit.

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der Segment-Wechsel öffnet die fail-closed-Linie.** Ein Wert wie `TOKEN=abc` landete dann
   verbatim im Feld. *Absehbar:* entfallen, wenn das zweite Gegenbeispiel rot gesehen und danach
   von einem Wächter gehalten wird.
   — **Ausgang: entfallen.** Die Frage stirbt nicht mit diesem Plan:
   `slice-204-das-programm-feld-nennt-das-programm` führt sie unverändert als erstes Risiko seines
   §6 (*„Die Segment-Trennung öffnet die fail-closed-Lücke"*) und nennt das zweite Gegenbeispiel
   seiner DoD als den Wächter darüber. Dieser Plan fügt dem nichts hinzu, was mit ihm stürbe.
2. **Die bestehende Zusage wird umgeschrieben, um die neue zu ermöglichen.** *Absehbar:*
   entfallen, wenn `TestCommandProgramSkipsAssignments` unverändert grün bleibt.
   — **Ausgang: entfallen.** Die bestehende Zusage wird von diesem Plan nicht mehr angefasst; der
   Gegenstand liegt bei `slice-204-das-programm-feld-nennt-das-programm`, dessen zweites
   Gegenbeispiel genau diese Zusage hält.
3. **Die Trennung an `&&` und `;` trifft Zeichen in Anführungszeichen.** *Absehbar:* entfallen,
   wenn ein Negativ-Fall mit einem `&&` innerhalb eines Strings das gewählte Segment unverändert
   lässt; sonst Rückführung nach §4.
   — **Ausgang: entfallen.** Auch dieses Risiko führt der Gegenstands-Halter selbst:
   `slice-204-das-programm-feld-nennt-das-programm` §6, zweites Risiko — *„`&&` und `;` sind Text,
   nicht Struktur"* —, samt der Rückführung in seinem §4.
4. **Die Spec-Zeilen werden von einem Lauf geschrieben, für dessen Stratum keine Quelle eine
   schreibende Rolle benennt.** *Absehbar:* weiter offen, bis
   `slice-151-spec-straten-haben-eine-schreibende-rolle` die Frage beantwortet; dieser Slice
   benennt sie in §7 und leitet keine Zuständigkeit ab.
   — **Ausgang: entfallen.** Die offene Frage bleibt adressiert, ohne diesen Plan:
   `slice-204-das-programm-feld-nennt-das-programm` §6, viertes Risiko, nennt dieselbe Lücke und
   dieselbe Adresse [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md).
   Der Ausgang *weiter offen* wäre hier die zweite Fassung eines Postens, den ein lebender Plan
   bereits trägt.

## 7. Closure-Notiz

**Gegenstand:** entfallen: Die Gruppe ist gestrichen. Der Gegenstand bleibt bei
`slice-204-das-programm-feld-nennt-das-programm`, der ihn unverändert führt und nicht geschlossen
ist — übertragen war er nie (§1: `Übernimmt: — nichts`).

**Stillgelegt ohne Lieferung** — Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice,
dessen Gegenstand ein anderer übernimmt, Wegfall-Hälfte: *Entfällt der Gegenstand ganz, trägt die
Zeile statt einer Kennung den Grund.* Die Liefer-Punkte in §2 bleiben **leer**: Dieser Slice hat
nichts geliefert. `Verantwortlich:` bleibt stehen.

**Keine Adresse zeigt ins Leere.** Vor dem Move nannte nur diese Datei selbst ihre Kennung; nach
dem Move ist die Ausgabe über der lebenden Plan- und Norm-Fläche leer:

```sh
git grep -l 'slice-span-programm-nennt-das-programm' -- \
  'docs/plan/planning/open' 'docs/plan/planning/next' 'docs/plan/planning/in-progress' \
  'docs/plan/planning/*.md' 'docs/plan/adr' 'spec' 'harness' 'AGENTS.md' '.claude'
```

Geprüft ist das ausdrücklich auch am Gegenstands-Halter: Der Nachbarschafts-Absatz, den er in §1
bekam, nennt `slice-109-feldliste-jede-aussage-hat-ihre-quelle` und nicht diesen Plan — er
verliert mit dieser Closure keine Adresse.

**Wellenlos.** Der Kopf führt keine Welle; die Roadmap führt wellenlose Arbeit nicht
(`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht), und diese Closure trägt sie allein.

**Was hat funktioniert:** Jedes der vier Risiken hat einen Halter, und er ist **namentlich**
nachweisbar: `slice-204-das-programm-feld-nennt-das-programm` führt drei davon wörtlich in seinem
eigenen §6 und den vierten mit derselben Folge-Adresse. Ein Wegfall ist damit kein stilles
Vergessen — die Originalinformation liegt weiter in einem lebenden Plan, nicht nur in `done/`.

**Was ging anders als geplant:** Der Plan war **zu früh**, nicht zu spät — dieselbe Lage wie beim
Nachbarn derselben Gelegenheit. Er entstand im Schnitt der sechs Gruppen-Slices und wurde von den
Runden danach zurückgenommen, ohne je beansprucht worden zu sein.

**Steering-Loop-Eintrag:** **gezählt, nicht verkörpert** — kein Zielort, darum **kein**
`liegt in`-Feld (`grundlagen-traceability.md` §Herkunfts-Anker). Eine Regel schreibt dieser Lauf
nicht; der Beitrag ist der Register-Eintrag unten.

**Beobachtungs-Register** (`../observations/`): zitiert, nicht neu formuliert —
[`BEO-ALL/plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand`](../observations/BEO-ALL/plan-entsteht-vor-dem-verdikt-ueber-seinen-gegenstand/observation.md).
**Keine zweite Beleg-Datei:** Dieser Plan steht dort unter *Benannt, nicht gezählt*; er ist ein
Fund **derselben** Gelegenheit wie `slice-die-bilanz-sagt-worueber-sie-gerechnet-hat` — eine
Entscheidung hat beide zugleich zurückgenommen —, und der Zähler misst Wiederholung über Vorgänge
hinweg, nicht die Zahl der Funde (`modul-06-roadmap.md` §Das Beobachtungs-Register).

**Lese-Schritt** (Repo ohne Wellen-Betrieb, `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht): Kein Eintrag erreicht mit dieser Closure 3×, und kein Eintrag über der Schwelle steht
ohne Ausgang — dasselbe Kommando wie in
[`slice-090`](slice-090-freshness-audit-im-ziel.md) §7, Ausgabe leer.

**Die drei Paarungen.** (a) Anker-Paarung: kein Eintrag trägt `liegt in`, sie hat keinen
Gegenstand. (b) Folge-Slice-Paarung: kein Folge-Slice genannt — die vier Risiko-Ausgänge nennen
einen **Halter**, keinen Nachfolger. (c) Register-Paarung: die zitierte Beobachtung existiert als
Verzeichnis und trägt einen Beleg.

**Was diese Closure nicht trägt:** Review und Verifikation am Gegenstand — es gibt keinen Diff,
den sie prüfen könnten. Geprüft ist die **Form** der Stilllegung durch `make docs-check` (Modul
`structure`, `open-tasks-require-marker`) und der Gesamtstand durch `make gates`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/span/`, `spec/` und
`test/mutations/` — alle in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind nicht
berührt. Die berührte Sub-Area erfüllt das Inklusionskriterium; ausdifferenziert wird nichts.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die `state.md` des
Eintrags; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md) | 16 | verkörpert | §1 nennt die Probe als Kommando; der Bestand ist maschinenlokal |
| [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | 6 | geplant | die Probe misst einen Bestand, nicht das Verhalten aller Aufrufer |
| [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md) | 3 | verkörpert | DoD — drei Gegenbeispiele, je einmal rot gesehen |
| [`anweisungssatz-eigentum-ohne-quelle`](../observations/BEO-ALL/anweisungssatz-eigentum-ohne-quelle/observation.md) | 5 | geplant | §6 Risiko 4 — für das Technik-Stratum benennt keine Quelle eine schreibende Rolle |

Keiner der vier erreicht **mit diesem Slice** erstmals 3×; ein eigener Folge-Slice entsteht daraus
nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
