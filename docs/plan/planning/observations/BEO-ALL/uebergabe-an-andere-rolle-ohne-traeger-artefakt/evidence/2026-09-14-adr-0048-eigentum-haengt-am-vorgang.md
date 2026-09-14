**Vorgang:** Review-Reports `docs/reviews/2026-09-14-adr-0048-konsistenzrunde-2.md` (MEDIUM-4) und
`docs/reviews/2026-09-14-adr-0048-konsistenzrunde-3.md` (INFO-2) — der Vorgang ist das Schreiben von
[ADR-0048](../../../../../adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) über seine
drei Konsistenzrunden. Zwei Funde, **eine** Gelegenheit.
**Fund:** Das gewählte Konflikt-Verdikt *„Lockerung legitim, aber undokumentiert"* trägt nach
Baseline-Regelwerk `modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz ein
**zweiteiliges** Übergabe-Artefakt — *„Folge-ADR + Erinnerungs-Slice in `next/`"*. Die Datei war der
erste Teil und nannte den zweiten zunächst gar nicht; nach der Schärfung nannte sie ihn als
Folgepflicht, und die Lage blieb dieselbe: `ls docs/plan/planning/next/` führte sechs Slices,
keinen zu diesem Vorgang, und drei weitere Folgepflichten standen *„fällig als eigener Vorgang"*
ohne Adresse.

**Der Sonderfall dieses Belegs:** Die Rollen-Grenze war dabei **korrekt** gezogen — der Architect
darf einen Planner-Slice nicht schneiden, und die Datei sagt das. Die Lücke liegt nicht bei der
Rolle, die übergibt, sondern zwischen den Rollen: Zwischen Nennen und Anlegen steht nichts. Der
Ausgang ist der Slice `slice-die-vorgangs-grenze-erreicht-den-reviewer-skill`, der dem einzigen
Posten ohne eigenen Moment eine Lifecycle-Adresse gibt; die drei übrigen haben in seinem §1 ihren
benannten Träger.
