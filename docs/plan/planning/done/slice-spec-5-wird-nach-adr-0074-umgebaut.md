# Slice slice-spec-5-wird-nach-adr-0074-umgebaut: Der Fließtext von Spec §5 wird in einem Zug nach den Klassen der Entscheidung zu §5 umgebaut

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — keine Closure-Bedingung über die DoD hinaus (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Arbeits-Bezug),
[`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (`Accepted`: Klassen, Ort,
Spalte `Präzisiert`), [`ADR-0075`](../../adr/0075-begruendungen-zu-spec-5-sammel-adr.md) (`Accepted`: trägt die
Begründungen), [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (Zielort),
[`MR-075`](../../../../harness/conventions.md#mr-075) (Spalte `Präzisiert`),
[`MR-076`](../../../../harness/conventions.md#mr-076) und [`MR-077`](../../../../harness/conventions.md#mr-077)
(die zwei echten Abweichungen, Begründung dort),
[`AGENTS.md`](../../../../AGENTS.md) §3.6, §3.7, §3.11.

**Berührte Spec-Stellen:** [§3](../../../../spec/spezifikation.md#3-defaults-und-konstanten),
[§5](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder) (der ganze Fließtext, die Feldtabelle, die
Werkzeugtabelle; `SPEC-001` bis `SPEC-034` bleiben, neue Zeilen ab der nächsten freien Nummer),
[§Aufnahme-Regel](../../../../spec/spezifikation.md#aufnahme-regel), Kopf und §7 Historie. Der Verweis zeigt
aufwärts; die Spec nennt diesen Slice nie.

**Verantwortlich:** Implementer (pt9912). Ausführende Rolle: Implementer-Kontext — der Lauf schreibt **keinen**
Norm-Text: die Sätze stehen in den zwei ADRs und in den Adaptions-Einträgen; fehlt einer, ist das eine Übergabe
an den Planner, kein Schreibauftrag (§1, §6).

**Autor:** Planner. **Datum:** 2026-09-30.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der ganze Fließtext von Spec §5 steht nach den Klassen von
[`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md): Festlegungen als Tabellenzeilen
mit neuen `SPEC-<NNN>` und der Spalte `Präzisiert` in allen Tabellen, Zusicherungen als Zeilen mit `Sensor`,
Begründungen weg (die Sammel-ADR trägt sie), Messprotokolle weg, Prozess-Konventionen weg, die zwei echten
Abweichungen als Tabellenzeile und die vier übrigen als eine kurze Festlegung — und jeder Kommentar im Code, der
eine entfernte Passage beim Namen nannte, zeigt auf den neuen Ort.

**Ausgangslage, gemessen am Stand `85e5ab5b`** (keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025); die Datei wandert, der Lauf misst neu):

```sh
sed -n '4,/^## 7\. Historie/p' spec/spezifikation.md | grep -vc '^|'      # 682  Nicht-Tabellenzeilen
sed -n '4,/^## 7\. Historie/p' spec/spezifikation.md | grep -v '^|' | wc -c # 51194 Bytes
grep -oE '`Test[A-Za-z0-9_]+`|test/mutations/[0-9]+-[a-z0-9-]+\.sh' spec/spezifikation.md | sort -u | wc -l   # 50
git grep -nE 'spezifikation\.md' -- internal test cmd harness/tools | wc -l   # 49
```

Die Zuordnung je Einheit steht im Klassifikationsbericht (Zeitdokument
`docs/reviews/2026-09-30-slice-spec-5-fliesstext-wird-absatz-fuer-absatz-klassifiziert-klassifikation.md`:
Tabelle U01 bis U64 in §3, Zeiger-Inventar in §5, Zeilen 137 bis 718 der Spec am Stand des Berichts). Der Slice
**führt sie aus**, er entwirft sie nicht.

**Größenregel — bewusst verletzt, und begründet.** Der Slice hält die drei Liefer-Punkte, aber nicht die
Prüfbarkeit des Diffs in *einer* Review-Sitzung (Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form:
Slice; 682 Zeilen Fließtext, Kommando oben). Grund ist eine **Auftraggeber-Entscheidung**: *ein* Umbau, *ein*
Review, *eine* Verifikation, ohne Rückfragen, statt der Blöcke, die bisher geplant waren. Der Gegenstand trägt
das: mechanische Abarbeitung einer bereits gemessenen und klassifizierten Tabelle, die Entscheidungen stehen in
den zwei ADRs. Was es kostet, steht offen: Der Review kann nicht jeden Satz einzeln lesen; er prüft die Bilanzen
und Bruchproben (§2) und eine benannte Stichprobe, und der Bericht sagt, welche Sätze so geprüft sind. Eine
Ausnahme, kein Präzedenzfall; ihr Rückweg ist §4 (Teilung nach der Block-Reihenfolge der ADR).

**Übernimmt:** `slice-spec-tabellen-tragen-die-lh-bezug-spalte`,
`slice-spec-5-erfassung-aus-tool-response-steht-als-tabellenzeilen`. *(Beide werden mit diesem Plan stillgelegt,
ohne Lieferung — Baseline-Regelwerk `modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt. Ihre Bedingungen an den Umbau stehen in §2, §3, §4 und §6 dieses Plans; der Pilot-Zuschnitt des
zweiten entfällt, weil dieser Slice alle Blöcke trägt.)*

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Lastenheft-Edit, kein Change Request.** Die `Lücke`-Zeilen bleiben benannt (Empfehlung E2 der
  ADR, vom Auftraggeber übernommen); ihr Ausgang ist ein gebündelter Change Request nach
  [`MR-015`](../../../../harness/conventions.md#mr-015) — anderer Vorgang, anderer Autor. Adresse: die
  Closure dieses Slice legt den Auftrag in `open/` an, wenn `grep -c '| Lücke |' spec/spezifikation.md` nicht 0
  ist (§5).
- **Kein Norm-Text.** Weder ADR noch Adaptions-Eintrag noch `docs/user/rollen-laeufe.md` noch `AGENTS.md`
  (Architect bzw. Rolle des Originals, [`AGENTS.md`](../../../../AGENTS.md) §3.8). Fehlt in der Sammel-ADR eine
  Begründung oder in `rollen-laeufe.md` ein Satz der Prozess-Konvention, ist das eine benannte Lücke im Bericht
  des Laufs, keine Ergänzung — andernfalls schriebe der Implementer die Norm, die er ausführt.
- **Keine Verhaltensänderung an `internal/`, `test/`, `cmd/`, `harness/tools/`.** Es ändern sich Kommentare —
  Zeiger nach [`AGENTS.md`](../../../../AGENTS.md) §3.7, und der Kommentar am Test, wo nur der Fließtext die
  Zusage führte ([`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 12) —, keine Zeile Logik. Das Kommando in Liefer-Punkt 3 hält es.
- **Kein Umbau der emittierten Feldliste und der emittierten Vorlage.** Die Verfügbarkeits-Aussagen und die
  Aufbewahrung sind Tool-Ebene, Code und E2E: `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung`
  (`open/`; sein Start ist dieser Slice in `done/`).
- **Keine Änderung an `.d-check.yml`.** Eine Aufnahme in `exempt-paths` oder `ignore-refs` ist eine Senkung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5); schlägt der Lauf eine als Ortsentscheidung vor, ist das eine
  Übergabe an den Architect.
- **Kein Parser-Umbau des Existenz-Sensors.** `slice-feldabdeckung-existenz-sensor` (`open/`) liest die neue Form
  nach [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 8; dieser Slice hält nur Kopfzeilen-Präfix und Spalte 2 (Liefer-Punkt 1).
- **Die schreibende Rolle von §5 bleibt offen**
  (`slice-151-spec-straten-haben-eine-schreibende-rolle`, `open/`) — darum Implementer-Kontext wie bisher.
- **Bestand außerhalb der Umbau-Blöcke bleibt:** die Spalte `Begründung` in §3 (Höhe eines Werts) und Messsätze
  in Zellen werden nicht rückwirkend geräumt; wer sie ohnehin anfasst, zieht sie nach.

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

- [x] **Liefer-Punkt 1 — Zeilen und Spalte.** *(bedingt bestätigt, Einschränkung in §7)* Jede Festlegung des Fließtexts (Klasse `a`) steht als Tabellenzeile
      mit `SPEC-<NNN>` ab der nächsten freien Nummer (`grep -oE 'SPEC-[0-9]+' spec/spezifikation.md | sort -u | tail -1`),
      nie neu vergeben; die Spalte `Präzisiert` steht **als letzte** in allen Tabellen mit `SPEC-`-Zeilen (§3,
      Feldtabelle, Werkzeugtabelle, die neue Zusicherungs-Tabelle, §6 falls dort Zeilen stehen) — Wert ist ein
      Anker-Link ins Lastenheft oder `Lücke`. Abweichung 1 und 2 sind je **eine Tabellenzeile** (Begründung steht
      in [`MR-076`](../../../../harness/conventions.md#mr-076) und
      [`MR-077`](../../../../harness/conventions.md#mr-077); die Spec zeigt nicht dorthin), Abweichung 3, 4, 5, 6
      sind **eine kurze Festlegung** (das Feld ist `Pflicht`, der Wert ist unbekannt, wenn die Quelle ihn nicht
      liefert; 4: Aufbewahrung, `make span-clean`). Jede Zusicherung der „Bewacht"-Prosa ist eine Zeile mit `Sensor`
      (ohne Wächter ein Strich); **vorab** misst der Implementer je Zusicherung, ob ein Test oder Fall sie in Namen
      oder Kommentar trägt — sonst geht die Zuordnung als Kommentar an den Test. Aufnahme-Regel folgt den Klassen und
      der Spalte; Kopf „Letzte Änderung" und **eine** Zeile in §7 Historie in der Form der vorhandenen.
      **Rot gesehen, an der realen Quelle:**
      (a) Wächter-Bilanz, Vorher aus `git show 85e5ab5b:spec/spezifikation.md`, Nachher aus der Arbeitskopie:
      `comm -3` der zwei `sort -u`-Mengen des Kommandos aus §1 ist bis auf benannte Verlagerungen leer — einen Namen
      aus einer neuen Zeile streichen, die Differenz ist nicht leer;
      (b) `grep -cE '^\| ID \|.*\| Präzisiert \|$' spec/spezifikation.md` ist mindestens 3 — die Spalte in einer
      Tabelle weglassen, der Wert fällt ([`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Fitness, Zeile 5; `anchors` meldet es nicht: benannte Lücke);
      (c) Sensor-Tabellenlesung: `grep -c '^| ID | Feld | Pflicht | Incident-Frage | Sensor |' spec/spezifikation.md`
      ist 1 — die Spalte vorn einfügen, der Wert ist 0 ([`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 8; die Feldtabelle trägt nur Felder);
      (d) eine **geleerte** `Präzisiert`-Zelle: ob ein Gate sie meldet, wird gefahren und im Bericht festgehalten;
      bleibt es grün, ist das eine benannte Lücke und der Lerneintrag ein Sensor-Vorschlag;
      (e) ein Link mit erfundenem Anker in einer neuen Zelle → `make docs-check` meldet ihn (`anchors`).
- [x] **Liefer-Punkt 2 — die Prosa entfällt.** *(bedingt bestätigt, Einschränkung in §7)* Begründungen ([`ADR-0075`](../../adr/0075-begruendungen-zu-spec-5-sammel-adr.md) trägt sie: je entfernter Begründung prüft
      der Lauf, dass sie in der Tabelle der Sammel-ADR steht, sonst Lücke im Bericht), Messprotokolle (git hält
      sie; nur mit Konsument nach `docs/reviews/`, [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 4), Prozess-Konventionen
      (`START-KONVENTION`-Block; `docs/user/rollen-laeufe.md` trägt sie — Satz-für-Satz-Abgleich im Bericht) und
      die „Bewacht"-Prosa sind aus §5 entfernt. Die Spec zeigt nicht abwärts. **Messkommandos, vorher/nachher:**
      Messkommando der Sammel-ADR (Kernsätze im Fließtext; Anker `SPEC-034`, der Lauf passt ihn an die letzte
      Tabellenzeile an) → **6 vorher, 0 nachher**; Datumszeilen im Fließtext
      (`sed -n '4,/^## 7\. Historie/p' spec/spezifikation.md | grep -cE '20[0-9]{2}-[0-9]{2}-[0-9]{2}'`) → 0, trifft die
      Kopfzeile „Letzte Änderung", nennt der Bericht das; Test- oder Fallnamen im Fließtext
      (`awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' spec/spezifikation.md | grep -v '^|' | grep -cE 'test/|_test\.go|Fall [0-9]+|\.bats'`)
      → 0; `grep -c 'Abweichung [1-6]' spec/spezifikation.md` hat nur Treffer, die Festlegung 10 als erhaltenen
      Namen begründet (vorher 17, gemessen mit `grep -rn 'Abweichung [1-6]' docs/plan/adr`); `grep -c 'START-KONVENTION'
      spec/spezifikation.md` → 0 (die Empfehlung E3 ist übernommen; widerspricht der ADR-Text, ist das eine Übergabe
      an den Architect). **Byte-/Zeilen-Bilanz je Klasse** (`a` bis `e` nach Bericht §2): Fließtext vorher/nachher
      (Kommando in §1) und je Klasse der neue Ort — Spec-Zeile · Sammel-ADR · `docs/user/` · git · entfallen; ein
      Rest ohne Ort ist benannt. **Rot gesehen:** einen Kernsatz zurück in den Fließtext → das Messkommando ≥ 1;
      eine nackte ADR-Kennung in eine neue Zeile → `make docs-check` rot (`ids`); ein Link auf eine
      Entscheidungs-Datei in die Spec → rot (`matrix`, Klasse `spec-straten`) — jeweils die Meldung gelesen und
      zurückgenommen.
- [x] **Liefer-Punkt 3 — Zeiger-Nachzug.** *(bedingt bestätigt, Einschränkung in §7)* Jede Stelle des Zeiger-Inventars (Bericht §5), die eine entfernte
      Passage beim Namen nennt, zeigt auf die neue `SPEC-<NNN>`, eine unveränderte Überschrift oder — für die
      Prozess-Konvention — auf `docs/user/rollen-laeufe.md`. Vorab misst der Lauf je entfernter Passage
      `grep -rn '<Passagen-Name>' docs/plan/adr` und hält den Namen als Text in der Zeile fest, die die Aussage
      übernimmt ([`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 10); entfällt die Aussage, steht die Lücke im Bericht. **Nur Kommentare:**
      `git diff -U0 -- internal test cmd harness/tools | grep -E '^[+-][^+-]' | grep -vE '^[+-][[:space:]]*(//|#)'`
      ist leer — eine Logikzeile ändern, das Kommando listet sie. **Zeiger-Kommando:**
      `git grep -nE 'spezifikation\.md' -- internal test cmd harness/tools` lässt keinen Kommentar auf eine entfernte
      Formulierung stehen (Rot gesehen: ein Zeiger auf eine entfernte Formulierung wird gelistet; die Grenze
      benennt [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md): kein Test bricht, der Sensor ist das Inventar). Dass ein **Satz seine Bedeutung behält**,
      hält kein Sensor; der Review prüft Vorher/Nachher an einer benannten Stichprobe.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die Handbuch-Sicht (`docs/user/`) nennt keine Spalte und keinen entfernten Abschnitt von §5;
      Prüfung `grep -rn 'spezifikation' docs/user | wc -l` steht im Bericht, ein Treffer auf Entferntes wird
      nachgezogen (`rollen-laeufe.md` nur lesen, §1).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` | update | Liefer-Punkte 1 und 2: Zeilen, Spalte `Präzisiert`, Prosa entfällt, Aufnahme-Regel, Kopf, §7 |
| Kommentare in `internal/`, `test/`, `test/mutations/`, `harness/tools/` | update | Liefer-Punkt 3 und Kommentar am Test bei Wächter-Zuordnung — nur Kommentarzeilen |
| `docs/user/rollen-laeufe.md` | keine (lesen) | Abgleich der Prozess-Konvention; Lücke → Bericht |

- **Reihenfolge im Lauf:** (1) Zeiger-Inventar und Passagen-Namen lesen und messen; (2) je Zusicherung messen, wo der
  Wächter die Zusage trägt; (3) Zeilen und Spalte schreiben; (4) Prosa entfernen, Bilanzen fahren; (5) Zeiger
  nachziehen; (6) Bruchproben, `make docs-check`, `make gates`.
- **Bedingungen der zwei stillgelegten Geber, die dieser Plan trägt:** die Zellenzahl je Tabelle ist einheitlich,
  Pipes im Zellinhalt sind `\|`-maskiert (`SPEC-031` trägt schon solche); eigener Stoff wird `###` unter dem
  passenden Abschnitt, die oberste `##`-Ebene bleibt die der Vorlage (der `structure`-Block der `.d-check.yml`
  ist bei der Planung nicht gelesen — der Lauf liest ihn vor dem ersten Edit); die Zeile in §7 Historie ist
  Pflicht; die Wächter-Nennungen bleiben in Summe erhalten (Liefer-Punkt 1 a).
- **Reichweite der Klassen:** die Zuordnung je Einheit ist Urteil, kein Sensor
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6); bei einer Einheit, die der Bericht als Grenzfall führt, gilt die
  Zuordnungsregel der ADR (Festlegung 2), nicht ein neues Urteil des Laufs.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): beobachtbar erfüllt — die zwei ADRs sind `Accepted`, die Adaptions-Einträge
[`MR-075`](../../../../harness/conventions.md#mr-075), [`MR-076`](../../../../harness/conventions.md#mr-076),
[`MR-077`](../../../../harness/conventions.md#mr-077) stehen, und `docs/user/rollen-laeufe.md` liegt. Der
Architect-Slice `slice-spec-aufnahme-regel-traegt-klassen-ort-und-lh-bezug` liegt noch in `in-progress/`; sein
Gegenstand (die Entscheidung) ist mit den zwei ADRs geliefert, ein zweiter Rolleninhaber hält ihn, das
WIP-Limit ist pro Rolleninhaber gemessen und bleibt gewahrt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Diff in **einer** Review-Sitzung auch mit
  Bilanzen und Stichprobe nicht prüfbar ist — dann Teilung nach der Block-Reihenfolge der ADR (Wächter-Liste ·
  Abweichungen 2 bis 6 · Abweichung 1 samt Splitting-Regel · Start-Konvention), Entscheidung beim Planner.
- `in-progress` → `open` (blockiert — Carveout?): wenn eine Norm fehlt oder widerspricht — Begründung nicht in der
  Sammel-ADR, Prozess-Satz nicht in `rollen-laeufe.md`, Kollision mit dem Existenz-Sensor (Festlegung 8), eine
  Klasse, die die Zuordnungsregel nicht entscheidet — Übergabe an den Architect, der Umbau schreibt nichts ins
  Leere.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) Wächter-Bilanz, Messkommandos und Zeiger-Kommando ohne unbenannte Differenz,
`make docs-check` ohne Befund, die Bruchproben und die Meldungen ihrer Rot-Fälle stehen im Report; (2) `make gates`
grün mit Stempel, der den Arbeitsbaum deckt. Dazu der Lerneintrag (Kandidaten: *neuer Sensor* Bindungs-Bilanz oder
Bilanz gegen `git show`; *geschärfte Regel* für den Rezept-Ablauf; *benannte Spec-Lücke* für nicht gehaltene
`Präzisiert`-Zellen).

**Closure-Pflicht des Planners über die DoD hinaus:** (a) ist `grep -c '| Lücke |' spec/spezifikation.md` nicht 0,
legt der Planner den gebündelten Change-Request-Auftrag (E2, [`MR-015`](../../../../harness/conventions.md#mr-015))
in `open/` an, per `cp` aus dem Template; (b) ein Slice für Fallen, die der Umbau als benannte Lücke an den
Architect übergab; (c) der Slice `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung` wird
priorisiert (sein Trigger ist diese Closure). Den Abschluss schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht der Lauf, der den Umbau trägt.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Satz ändert beim Umbau seine Bedeutung**, und kein Sensor liest den Wortlaut. — **Ausgang: eingetreten** — Review F-1, F-2, F-3 und F-5
  sind im Lauf behoben (vom Verifier gegen den Ist-Text geprüft); der Rest (`SPEC-040`, Schema-Aussage ohne Belegklasse) geht an
  `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau`.
- **Ein Kommentar-Zeiger bleibt auf einer entfernten Passage stehen** (49 Stellen, Kommando in §1). — **Ausgang: eingetreten** —
  `test/mutations/131-span-werkzeugname-leer.sh` Zeilen 9 bis 11; Folge-Slice `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau`, Register
  `BEO-ALL/zeiger-kommando-faengt-zitat-entfernten-wortlauts-nicht`.
- **Die Zeilen werden so lang wie `SPEC-031`**, statt den Fließtext zu ersetzen. — **Ausgang: entfallen** — `awk 'length($0)>1500{print NR": "length($0)}' spec/spezifikation.md`
  nennt eine Zeile (146, nach dem Implementer-Bericht die von `SPEC-031`); alle übrigen liegen darunter.
- **Kein Lastenheft-Element für viele Zeilen** — mehr als die Hälfte als `Lücke` wäre ein Befund für den Architect. — **Ausgang: entfallen** — 19 von 86 Zeilen
  (Kommandos in §7), unter der Hälfte; die Ebenen-Frage zu einem Teil der 19 trägt `slice-spec-5-entscheidungen-nach-dem-umbau`.
- **Die Spalte `Präzisiert` bleibt Dekoration**, weil kein Sensor sie hält (Rot-Probe (d)). — **Ausgang: eingetreten** — die Schranke „mindestens 3" hat bei fünf Tabellen keinen Zahn
  und eine geleerte Zelle bleibt grün; Folge-Slice `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau` (Liefer-Punkt 1), Register `BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf`.
- **Der Tabellenparser von `slice-feldabdeckung-existenz-sensor` bricht an der neuen Spalte oder an der Zusicherungs-Tabelle.** — **Ausgang: weiter offen** — Register
  `BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`; die Bedingung steht im Plan des Parsers, der Parser ist ungebaut.
- **Der Diff ist in einer Review-Sitzung nicht prüfbar** (die bewusst verletzte Größenregel, §1). — **Ausgang: entfallen** — der Review hat alle 86 Zeilen gelesen, der Verifier 13 gegen den
  Vorher-Text; Bilanzen und Bruchproben trugen (Verifikation, Abschnitte 2.1 und 2.4).
- **Die Kernsätze der Sammel-ADR sind eine Auswahl**, kein Vollständigkeits-Sensor. — **Ausgang: weiter offen** — Register `BEO-ALL/vollstaendigkeits-kommando-prueft-summe-statt-zuordnung`.

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

**Geliefert:** der Fließtext von Spec §5 steht nach den Klassen von [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md): Festlegungen und Zusicherungen als Tabellenzeilen, Spalte `Präzisiert`
in fünf Tabellen, Begründungen, Messprotokolle und Prozess-Konventionen entfernt, Kommentar-Zeiger nachgezogen. Gemessen im Verifikationsbericht (`docs/reviews/2026-09-30-slice-spec-aufnahme-regel-und-umbau-verifikation.md`, Abschnitt 2.1); zwei
Zahlen dieser Closure, selbst gefahren:

```sh
grep -oE '`SPEC-[0-9]+`' spec/spezifikation.md | sort -u | wc -l   # 86
grep -c '| Lücke |' spec/spezifikation.md                              # 19
```

**Verifikation:** Verdikt **bedingt bestätigt** (derselbe Bericht); der Review liegt vor (kein HIGH; Nachbesserung gegen den Ist-Text geprüft). Die Wächter-Bilanz hat keine
unbenannte Differenz; die fünf verlangten Rot-Fälle hat der Verifier selbst gesehen.

**Einschränkungen (Häkchen gesetzt, bedingt):**

- **Liefer-Punkt 1:** Die Schranke „mindestens 3" der `Präzisiert`-Zählung hat bei fünf Tabellen keinen Zahn (Spalte in einer Tabelle streichen: 5 auf 4, grün); die geleerte
  Zelle bleibt grün, benannte Lücke der ADR. Beides → `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau`.
- **Liefer-Punkt 2:** `START-KONVENTION` steht mit 0 gegen Fitness-Zeile 13 von [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (verlangt den Wert vor dem Umbau); die Prozess-Zustände U14 und U38 und zwei
  Begründungen der Sammel-ADR haben keinen Träger → `slice-spec-5-entscheidungen-nach-dem-umbau`.
- **Liefer-Punkt 3:** `test/mutations/131-span-werkzeugname-leer.sh` Zeilen 9 bis 11 zitiert einen entfernten Wortlaut, den das Zeiger-Kommando nicht fasst →
  `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau`.
- **Grenzen der Prüfung:** der Nur-Kommentar-Diff ist rot nur in der Implementer-Probe gesehen (vom Reviewer nachvollzogen, vom Verifier nicht wiederholt); der Sinnerhalt ist
  eine Stichprobe (13 von 86 Zeilen beim Verifier, alle 86 im Review); die Klassen-Zuordnung je Einheit ist Urteil ohne Sensor. Die Festlegungen 9, 10, 13 und 14 von [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) und
  ihre Immutabilität sind nicht rot gesehen.
- **19 Zeilen mit `Lücke`:** ein gebündelter Change Request nach [`MR-015`](../../../../harness/conventions.md#mr-015) ist **nicht** angelegt (Abweichung von §5 (a)
  dieses Plans): ob [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) einen Teil der Zeilen als Präzisierung trägt, ist eine Ebenen-Entscheidung des Architect, und der Auftrag entsteht erst nach ihr — `slice-spec-5-entscheidungen-nach-dem-umbau`.

**Lebende Adressen:** `slice-074-agent-vor-aufruf-protokoll`, `slice-077-verlorener-lauf-sichtbar` und `slice-078-verdrahtung-hat-waechter` (alle in `open/`) zeigen auf
`SPEC-039`, `SPEC-041` und `SPEC-086`. Der Start-Trigger von `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung` (dieser Slice in `done/`) ist mit dem Abschluss erfüllt;
sein Plan nennt ihn schon so und bleibt unverändert.

**Register:** neu `BEO-ALL/zeiger-kommando-faengt-zitat-entfernten-wortlauts-nicht` und `BEO-ALL/sensor-schranke-wird-durch-tabellenwachstum-unscharf` (je ein Beleg dieses Vorgangs, `offen`);
ein weiterer Beleg für `BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben` (`SPEC-040`); `BEO-ALL/geplanter-slice-wird-nie-gearbeitet` hat mit der Stilllegung der zwei Geber
(`slice-spec-tabellen-tragen-die-lh-bezug-spalte`, `slice-spec-5-erfassung-aus-tool-response-steht-als-tabellenzeilen`) 3× erreicht; der Lese-Schritt setzt `geplant` mit
`slice-spec-5-entscheidungen-nach-dem-umbau` — die Regel ist damit **zugewiesen, nicht beschlossen**. Der zweite Geber steht als Fund derselben Gelegenheit da und bewegt den Zähler nicht.

**Folge-Slices** (nur Pläne in `open/`, nicht ausgeführt): `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau` (Übergaben B-2, B-3, B-4, A-6),
`slice-spec-5-entscheidungen-nach-dem-umbau` (Übergaben A-1 bis A-5, A-7); Übergabe A-8 steht als Bedingung im Plan von `slice-feldabdeckung-existenz-sensor`.

**Lerneintrag (neuer Sensor):** ein Sensor, der die Tabellenform von Spec §5 in allen Tabellen hält (Zahl der Kopfzeilen mit `Präzisiert` gleich Zahl der Tabellen mit `SPEC`-Zeilen, keine leere
letzte Zelle), statt der Schranke „mindestens 3", die mit dem Wachstum der Tabellen unscharf wurde. Träger ist `slice-spec-5-tabellen-sensor-und-zeiger-nach-dem-umbau`; ein Zielort steht noch nicht,
darum kein `liegt in`. Daneben eine geschärfte Regel als Auftrag an denselben Slice: ein Zeiger-Kommando fasst auch Zitate entfernten Wortlauts.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist die Sub-Area `*` (gesamtes Repo, Kürzel `ALL`, Modus
Greenfield laut Modus-Deklaration in `harness/conventions.md`). Die Deklaration führt für `spec/` keine feinere
Sub-Area, und alle Beobachtungen des Registers tragen diese eine; die Schwelle ≥ 2 von 3 Achsen lässt sich damit
nicht feiner prüfen, als die Deklaration es zulässt — benannt, nicht gelöst.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, gemergter Stand; Zähler = Dateien unter
`evidence/` (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`). Treffer am Gegenstand
„Spec-Text, Messungen, Kopplung an Code, Zeiger auf eine Passage":

- [`spec-aenderung-ohne-historie-zeile`](../observations/BEO-ALL/spec-aenderung-ohne-historie-zeile/observation.md)
  — 1×, offen (Zeile in §7 Historie: Liefer-Punkt 1).
- [`spec-zeile-enger-als-der-code-den-sie-beschreibt`](../observations/BEO-ALL/spec-zeile-enger-als-der-code-den-sie-beschreibt/observation.md)
  — 1×, offen.
- [`festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten`](../observations/BEO-ALL/festlegung-und-ihr-rumpf-nennen-verschiedene-reichweiten/observation.md)
  — 1×, offen.
- [`feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor`](../observations/BEO-ALL/feldnotiz-traeger-und-spec-koennen-in-der-kernaussage-abweichen-ohne-sensor/observation.md)
  — 1×, offen; sein Existenz-Sensor ist `slice-feldabdeckung-existenz-sensor` (`open/`).
- [`abgeschaffte-kennung-in-unveraenderlichem-artefakt`](../observations/BEO-ALL/abgeschaffte-kennung-in-unveraenderlichem-artefakt/observation.md)
  — 1×, offen; [`rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet`](../observations/BEO-ALL/rang-zeiger-nennt-eine-festlegung-deren-zweifelsregel-anders-entscheidet/observation.md)
  — 1×, offen (beide betreffen den Zeiger-Nachzug, Liefer-Punkt 3).
- [`span-feld-bedeutung-wechselt-ohne-fassungs-angabe`](../observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/observation.md)
  — 2×, offen: **ein Beleg aus diesem Slice hebt ihn auf 3×**; dann ist er eine Lücke mit Ausgang.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  — 19×, geplant; berührt die Spalte `Sensor` und die Rot-Probe (d).
- [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md)
  — 6×, geplant; berührt die „gemessen am …"-Sätze des Fließtexts.
- [`mess-zusage-trifft-das-eigene-zitat`](../observations/BEO-ALL/mess-zusage-trifft-das-eigene-zitat/observation.md)
  — 5×, verkörpert ([`MR-058`](../../../../harness/conventions.md#mr-058)).
- [`geplanter-slice-wird-nie-gearbeitet`](../observations/BEO-ALL/geplanter-slice-wird-nie-gearbeitet/observation.md)
  — 2×, offen: die zwei Geber dieses Plans sind die Gelegenheit, die mit ihrer Stilllegung als Beleg angelegt wird
  (Zähler dann 3×; Ausgang beim Lese-Schritt der Stilllegung, dort benannt).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
