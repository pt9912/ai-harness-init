**Vorgang:** slice-sprung-auf-v680-wird-vollzogen
**Fund:** Der Start-Trigger von `slice-213` (`open/`) §4 belegt die Zusage *„der vendored Baum
führt die Vorlage in der neuen Fassung"* mit einem `ls` auf das abgelöste Tag-Segment
(`ls .harness/baseline/v6.7.2/templates/docs/reviews/review-report.template.md`). Nach dem Tausch
meldet das Kommando Exit 2, und der Trigger liest sich als *nicht erfüllt*, obwohl er es ist — die
Vorlage liegt unter dem neuen Tag am selben Pfad (`… v6.8.0 …`, Exit 0). Der Nachzug hat die Stelle
als datierte Mess-Aussage eingeordnet und stehen lassen; sie ist keine, sondern eine **lebende
Bedingung**. Gefunden hat es der Closure-Zug beim Zuweisen des Risiko-Ausgangs, kein Sensor: Die
Adresse steht als Inline-Code außerhalb von `codepaths.roots`
([`gate-modul-erreicht-den-vendored-baum-nicht`](../../gate-modul-erreicht-den-vendored-baum-nicht/observation.md)).
