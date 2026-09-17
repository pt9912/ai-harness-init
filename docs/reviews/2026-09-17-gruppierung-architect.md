# Architect-Verdikt zur Gruppierung der dreizehn Go-Slices (Stufe 1)

**Rolle:** Architect (Modul 8, Übergabe Planner → Architect: *Slice-Plan mit `LH-*`-Bezug* →
*ADR-Bezüge bestätigt oder Folge-ADR*).
**Datum:** 2026-09-17. **Autor:** ai-harness-init-Team (pt9912). **Modell:** `claude-opus-5[1m]`.

**Gegenstand:** Commit `a2a5e2ed` — sechs neue Pläne in `docs/plan/planning/open/`, die dreizehn
Pläne aus `next/` übernehmen, sowie die Nicht-Aufnahme von `slice-109`.

**Prüfgrundlage:** Baseline `v6.9.0`, namentlich `regelwerk/modul-05-planning-harness.md`
§Ein Slice, dessen Gegenstand ein anderer übernimmt und §Ziel-Form: Slice,
`regelwerk/modul-06-roadmap.md` §Wann Arbeit eine Welle braucht,
`regelwerk/modul-08-agentenrollen.md` §Rollen-Regeln; dazu
[`AGENTS.md`](../../AGENTS.md) §3.4/§3.6/§3.8, die genannten ADRs und der Adaptions-Block.

**Geprüft wurde der Plan gegen die ADR-Lage, nicht der Diff** — Code existiert zu keinem der sechs.
Alle Zahlen unten stehen neben dem Kommando, das sie liefert, und sind **keine Erwartungswerte**
([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

---

## 1. Verdikt je Slice

**Gruppe 1 — `slice-das-ziel-sagt-was-sein-vendored-baum-ist`: bestätigt.** Die Bezüge
[`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) und
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) sind vollständig
und treffen den Gegenstand; beide ADRs sind `Accepted`
(`grep -m1 '^\*\*Status:\*\*' docs/plan/adr/00{20,22}-*.md`), und der Plan setzt keinen Wert, den
sie nicht decken — die Zelle *geht mit, noch nicht umgesetzt* ist genau die Lesart, die
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) erlaubt. Offen
bleibt nicht der Bezug, sondern der Wellen-Zuschnitt (**B-4**).

**Gruppe 2 — `slice-waechter-der-erfassungsschicht-decken-was-sie-sagen`: bestätigt.** Bezug auf
[ADR-0022](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegungen 1
und 5 als gemessene Zusagen und auf [`AGENTS.md`](../../AGENTS.md) §3.6 ist richtig adressiert; die
Verdikt-Form *Fall oder ausgesprochene Grenze* liegt innerhalb von §3.6 und verschärft sie nicht
über die Regel hinaus. Keine ADR wird berührt, keine fehlt.

**Gruppe 3 — `slice-lifecycle-werkzeuge-tragen-die-kennung`: bestätigt.**
[ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 3 und
[ADR-0053](../plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
Festlegungen 1 und 4 tragen den Gegenstand; beide `Accepted`. Der Plan **widerspricht** keiner
davon — er löst ein, was
[ADR-0053](../plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4
als Adresse benennt. Der Ausschluss *„die Menge der zugelassenen Kennungs-Formen wird nicht
erweitert"* zeigt korrekt auf
[`MR-059`](../../harness/conventions.md#mr-059) und auf [`AGENTS.md`](../../AGENTS.md) §3.8
(Norm-Änderung ist Architect-Arbeit).

**Gruppe 4 — `slice-emitter-aussagen-ueber-den-vorlagensatz-sind-gedeckt`: nicht bestätigt, zwei
HIGH-Befunde, ein Folge-ADR-Vorschlag.** Die Bezüge auf
[`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) und
[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
stimmen; es fehlen zwei bindende ADR-Bezüge (**B-1**), und die Konstruktion des Change Requests
trägt in der Sache, aber nicht in der gewählten Form (**B-2**). Der Ausgang ist
[ADR-0057](../plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md), `Proposed`.

**Gruppe 5 — `slice-die-bilanz-sagt-worueber-sie-gerechnet-hat`: bestätigt im Bezug, beanstandet im
Zuschnitt (B-6).** [ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) und
[ADR-0012](../plan/adr/0012-haupt-kontext-ohne-token-bilanz.md) sind `Accepted` und treffen den
Gegenstand; die Kopf-Zeile *Berührte Spec-Stellen* nennt
[`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5 als
**gelesen** — das ist richtig und vollständig.

**Gruppe 6 — `slice-span-programm-nennt-das-programm`: bestätigt.**
[ADR-0011](../plan/adr/0011-telemetrie-erfassung-policy.md) trägt die fail-closed-Linie;
[`MR-019`](../../harness/conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence)
ist die richtige Adresse dafür, dass `SPEC-021`/`SPEC-031` ohne Vertragsänderung nachgezogen
werden. Der vierte Liefer-Punkt des Gebers — die **offene Eigentumsfrage** über das Technik-Stratum
— ist mitgenommen (`grep -n 'schreibende Rolle' …` trifft §1, DoD und §6 Risiko 4): Die Adresse
nimmt ihre Sendung vollständig an.

## 2. Befunde

**B-1 (HIGH) — Gruppe 4 verliert zwei bindende ADR-Bezüge, die der Geber führte.**
`slice-139-lastenheft-deckt-die-emit-disposition` nennt
[ADR-0005](../plan/adr/0005-ziel-repo-distribution.md) (*„die Entscheidung, aus der beide Aussagen
stammen"*) und [ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) (*„nennt dieselbe Menge
und ist `Accepted`, also immutabel"*). Der Nehmer nennt **keine** von beiden. Das ist nicht
Formalie: Die Begründung zu Festlegung (e) von
[ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) spricht von *„den fünf wiederkehrenden
Vorlagen"* (`grep -c 'die fünf wiederkehrenden Vorlagen' docs/plan/adr/0020-emittierte-modul-15-regeln.md`
→ **1**). Wer die Menge auf ihren heutigen Stand zieht, stellt diese Aussage in einer `Accepted`-ADR
still auf falsch, und überschrieben wird sie nicht ([`AGENTS.md`](../../AGENTS.md) §3.4). Ohne den
Bezug im Plan sieht das niemand vor dem Commit.

**B-2 (HIGH) — Gruppe 4: die CR-Konstruktion trägt in der Sache, nicht in der Form.** Richtig ist:
Die Aufzählung in Rang 1 darf nur der Auftraggeber bewegen, und der Plan schließt die
Lastenheft-Änderung korrekt aus. Falsch ist die Bindung: DoD 1 hält `emit.isRecurring`
**bidirektional gegen die Klammer in Rang 1**, und daraus folgt der Start-Trigger, der den **ganzen**
Slice an einen externen Akt hängt. Gemessen:

```sh
sed -n '/^### LH-FA-02/,/^### LH-FA-03/p' spec/lastenheft.md | tr '\n' ' ' \
  | grep -o 'Wiederkehrende\*\* Vorlagen ([^)]*)'     # 5 Glieder
awk '/^func isRecurring/,/^}/' internal/emit/templates.go \
  | grep -o '"[A-Za-z-]*\.template\.md"' | sort -u | wc -l   # 11
```

Zwei Kosten folgen daraus: Jede künftige Vorlagen-Art eines Baseline-Sprungs wird zur
**Vertragsänderung**, und der CR wird verlangt, bevor irgendjemand seine Gestalt vorgeschlagen hat.
[ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) Festlegung (e) hat für den
**benachbarten** Satz bereits anders entschieden — *„Welcher Satz das ist, ist eine Regel und keine
Aufzählung"* —, für die wiederkehrende Klasse fehlte die Entscheidung. Sie liegt jetzt als
[ADR-0057](../plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md) (`Proposed`)
vor: Der Wächter bindet die **Eigenschaft gegen den vendored Satz** (vollständig, disjunkt,
fail-closed), der CR bleibt Sache des Auftraggebers und ist **keine** Vorbedingung des
Eigenschafts-Wächters. Ein `Supersedes` ist nicht nötig — keine `Accepted`-ADR wird abgelöst, eine
Lücke wird gefüllt.

**B-3 (MEDIUM) — die Adresse `MR-015` ist überholt.** Gruppe 4 stützt die CR-Pflicht auf
[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler);
dessen Kopf trägt seit
[`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
die Marke *„ÜBERHOLT: dieser Eintrag, mit einer Ausnahme"* — fort bindet allein sein
**Cutoff-Absatz**. Die Sache ist unverändert richtig, nur steht sie heute in der adoptierten
Baseline (`grundlagen-source-precedence.md` §Spec-Stratifizierung) und im ablösenden Eintrag. Der
Geber führte denselben Bezug; der Befund ist geerbt, nicht neu.

**B-4 (MEDIUM) — welle-11 steht nach der Übernahme mit einem Mitglied da, und der Wellen-Test ist
neu zu stellen.** Die Wanderung der Wellen-Zugehörigkeit ist in Stufe 1 korrekt vollzogen: Alle
drei Geber führen `**Welle:** welle-11`
(`grep -m1 -H '^\*\*Welle:\*\*' docs/plan/planning/next/slice-09{0,1,2}-*.md`), und der Nehmer trägt
das Feld. Damit bündelt die Welle künftig **einen** Slice. Nach
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht liegt eine Welle nur vor, wenn ihr
Closure-Trigger **mehr** beobachtet, als die DoDs ihrer Slices belegen — `make gates` und
`make full-smoke` stehen in der DoD des Nehmers bereits; als *Mehr* bleiben das Carveout-Audit über
`docs/plan/carveouts/` und die Ergebnis-Notiz. Ob das trägt, ist eine **Planungs-Entscheidung**,
kein Architektur-Urteil: Sie ist zu treffen und zu notieren, bevor der Welle-Plan nachgezogen wird.
Fällt sie gegen die Welle, entfällt das Kopf-Feld des Nehmers und die Roadmap verliert ihre Zeile
unter *Offene Wellen*; fällt sie für die Welle, steht das *Mehr* in §3 des Welle-Plans.

**B-5 (MEDIUM) — die Abgrenzung zu `slice-109` trägt in der Sache, der Alleinstellungs-Grund nicht.**
Der tragende Grund ist richtig: Gegenstand von `slice-109` sind Aussagen des **Produkts** (Feldliste
und [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) §5), nicht
die Deckung der Wächter; seine Liefer-Punkte fallen mit denen von Gruppe 2 nicht zusammen, und
Gruppe 2 nennt ihn ausdrücklich als Adresse. Der **zweite** Grund — er schreibe als einziger §5 —
hält der Messung nicht stand: `slice-span-programm-nennt-das-programm` führt `SPEC-021` und
`SPEC-031` in §5 als *„werden nachgezogen"*, und weitere offene Pläne berühren dieselbe Sektion
(`grep -l 'spezifikation.md#5-metriken' docs/plan/planning/open/*.md`). Die Abgrenzung bleibt
gültig; ihre Begründung ist auf den ersten Grund zu verkürzen, und die **Gleichzeitigkeit** zweier
schreibender Zugriffe auf §5 gehört in beide Pläne als benannte Nachbarschaft.

**B-6 (MEDIUM) — Gruppe 5 ist keine Gruppierung, sondern eine Umbenennung.** Der Nehmer übernimmt
**einen** Geber, und seine drei Liefer-Punkte sind die drei von
`slice-071-bilanz-nennt-ihren-bestand`, bis in die Formulierung
(`grep -E '^- \[ \] \*\*\(' docs/plan/planning/{next/slice-071-bilanz-nennt-ihren-bestand,open/slice-die-bilanz-sagt-worueber-sie-gerechnet-hat}.md`).
Die Übernahme-Form ist dafür zulässig, aber sie kostet eine vollständige Stilllegung samt
Risiko-Ausgängen für einen Identitäts-Wechsel, den
[`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
nicht verlangt — dort behält *der Bestand seine Nummer*, und die Namens-Form gilt für **neu
vergebene** Kennungen. Zwei saubere Ausgänge: `slice-071` unangetastet in `next/` lassen und die
Gruppe streichen, **oder** in der Stilllegung benennen, was der Nehmer über den Geber hinaus führt.
Für Gruppe 6 gilt der Einwand **nicht** in dieser Schärfe — dort ist die DoD neu geschnitten
(vier Punkte des Gebers zu einem Liefer-Punkt mit Unterpunkten plus Doku-Update), und der
Gegenstand ist vollständig mitgenommen.

**B-7 (INFO) — die Übernahme-Form selbst ist regelkonform.** Alle sechs Pläne tragen `Übernimmt:`
in §1; alle dreizehn genannten Geber existieren und liegen in `next/`, also ungeschlossen
(`for s in …; do ls docs/plan/planning/*/$s*.md; done`). Keiner der Nehmer ist geschlossen, keiner
schließt einen übernommenen Punkt selbst aus. Die Größenregel ist überall gehalten: höchstens drei
Liefer-Punkte je Plan
(`for f in docs/plan/planning/open/slice-*.md; do grep -cE '^- \[ \] \*\*\([0-9]\)' $f; done`, für
Gruppe 6 ein Punkt mit Unterpunkten). Die Kennungen in `Übernimmt:` stehen als **Datei-Stamm**
(`slice-090-freshness-audit-im-ziel`), während der übrige Bestand dieselben Slices als `slice-090`
adressiert — beide lösen auf; die §7-Zeile `Gegenstand:` der Geber sollte **eine** Form konsequent
führen.

## 3. Auftrag an den Planner für Stufe 2

1. **Gruppe 4 vor der Stilllegung nachziehen** (B-1, B-2, B-3): Bezug um
   [ADR-0005](../plan/adr/0005-ziel-repo-distribution.md),
   [ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) und
   [ADR-0057](../plan/adr/0057-wiederkehrende-vorlagen-menge-bindet-als-eigenschaft.md) ergänzen;
   DoD 1 auf den Eigenschafts-Wächter stellen; den Start-Trigger vom CR lösen und den
   Aufzählungs-Nachzug als eigenen, CR-abhängigen Punkt oder Folge-Slice führen; das Risiko des
   Gebers zur `Accepted`-Zahl-Aussage in
   [ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) in §6 aufnehmen; `MR-015` durch
   [`MR-036`](../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)
   ersetzen. Bis dahin geht `slice-139` **nicht** nach `done/` — sein Risiko hätte keinen Ausgang.
2. **Welle-11 entscheiden, dann nachziehen** (B-4): Wellen-Test nach
   `modul-06-roadmap.md` stellen und die Antwort notieren. Bleibt die Welle, ersetzt in §4 des
   Welle-Plans **eine** Zeile die drei; §3 (*„erst wahr, wenn alle drei Slices liegen"*) und §5
   (*„Innerhalb der Welle: {090, 091} → 092"*) verlieren ihren Gegenstand und werden auf den neuen
   Zuschnitt gezogen; das Drift-Log der Roadmap bekommt seinen Eintrag *in einem anderen
   aufgegangen* mit Datum und Grund. Entfällt die Welle, entfällt zusätzlich das Kopf-Feld des
   Nehmers und der Zeiger unter *Offene Wellen*.
3. **Gruppe 5 entscheiden** (B-6): streichen oder den Mehrwert in der Stilllegung benennen.
4. **Die Nicht-Aufnahme von `slice-109` umformulieren** (B-5): den Alleinstellungs-Grund streichen,
   den Gegenstands-Grund behalten, die Nachbarschaft zu Gruppe 6 in beiden Plänen benennen.
5. **Bei jeder Stilllegung** die drei Bedingungen aus `modul-05-planning-harness.md` §Ein Slice,
   dessen Gegenstand ein anderer übernimmt vollständig abarbeiten: Liefer-Punkte leer, §7-Zeile
   `Gegenstand:` mit der Kennung des Nehmers, **jedes** Risiko des Gebers mit genau einem Ausgang —
   *eingetreten* mit der Kennung des Nehmers nur dort, wo der Nehmer das Risiko wirklich führt.

## 4. Grenze dieses Verdikts

Geprüft sind die Pläne, die genannten ADRs auf Status und Aussage, der Welle-Plan und die
Übernahme-Form. **Nicht** geprüft sind: die inhaltliche Angemessenheit jedes einzelnen
Liefer-Punkts, die Risiko-Vollständigkeit der Geber über die in §2 genannten Fälle hinaus, und die
Frage, ob die je drei Gruppen-Mitglieder in **einer** Review-Sitzung prüfbar sind — das ist eine
Größen-Frage, die erst der Diff beantwortet, und sie steht in allen sechs Plänen bereits als Risiko
mit Rückführung.
