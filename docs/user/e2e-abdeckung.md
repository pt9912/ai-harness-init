# E2E-Abdeckung der Stufen des Voll-E2E

Erzeugt von `make e2e-abdeckung` aus den Deklarationen, die jede Stufe von
`harness/tools/full-smoke.sh` an sich selbst trägt. Diese Datei ist eine **stabile
Abdeckungs-Deklaration, kein Lauf-Beleg**: der Erzeuger liest den Quelltext der Stufen,
er führt den E2E nicht aus, und er schreibt sie nur bei inhaltlicher Abweichung. Sie
ändert sich mit den Deklarationen und mit dem Ort ihrer Quellen — eine Einfügung
oberhalb einer Stufe verschiebt deren Zeile in der Spalte `Ort`.

Die Spalten stehen in der Folge `Spec-Kennung`, `Kurzbeschreibung`, `Stufe`, `Ort`.
Die Spalte `Spec-Kennung` nennt die Anforderung, die diese Stufe trägt, als klickbaren
Verweis in `spec/lastenheft.md`; die Spalte `Kurzbeschreibung` trägt keine Kennung. Die
Spalte `Stufe` zählt die Stufen-Kopfzeilen in der Reihenfolge des Skripts — eine Stufe
eröffnet mit ihrer Ausgabe-Kopfzeile und reicht bis zur nächsten. Ob eine hier fehlende
Anforderung eine Lücke ist, urteilt der Leser gegen `spec/lastenheft.md`; ein
Waisen-Urteil fällt nicht hier.

| Spec-Kennung | Kurzbeschreibung | Stufe | Ort |
| --- | --- | --- | --- |
| [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) | Produkt-Traeger liegt auf dem Host; ohne ihn laeuft kein Ziel-Bootstrap | Stufe 1 | `harness/tools/full-smoke.sh:358` |
| [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) | Bootstrap in ein leeres Zielverzeichnis, sprachgebunden in einem Lauf | Stufe 2 | `harness/tools/full-smoke.sh:375` |
| [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-03`](../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-08`](../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`LH-FA-09`](../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren), [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) | Das gates des Ziels laeuft vollstaendig, nicht als stille Teilmenge | Stufe 3 | `harness/tools/full-smoke.sh:425` |
| [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) | Der frische Klon holt den Traeger per Fetch aus dem gepinnten Release — sha256 vor der Ablage verifiziert, Transport im gepinnten Bild, und der gefetchte Traeger fuehrt den Konsumenten-Aufruf (Vollzug) und den laut-Bruch | Stufe 4 | `harness/tools/full-smoke.sh:1537` |
| [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) | Dieselbe Harness ohne Sprachskelett; die zweite Bootstrap-Variante | Stufe 5 | `harness/tools/full-smoke.sh:2080` |
| [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Das sprachlose Ziel faehrt ein reines Doku-Gate, ohne Code-Gate | Stufe 6 | `harness/tools/full-smoke.sh:2094` |
| [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Zwei Sprachmodule in einem Ziel koexistieren, ihre Gates laufen beide | Stufe 7 | `harness/tools/full-smoke.sh:2155` |
| [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Eine zweite Sprache im selben Ziel, mit den realen C++-Gates | Stufe 8 | `harness/tools/full-smoke.sh:2199` |
| [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Das geschichtete Modul uebersetzt, lintet und traegt sein Arch-Gate | Stufe 9 | `harness/tools/full-smoke.sh:2259` |
| [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Dasselbe Schicht-Layout in der zweiten Sprache, mit Arch-Gate | Stufe 10 | `harness/tools/full-smoke.sh:2383` |
| [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Das geschichtete Modul am Repo-Root statt unter einem Modulpfad | Stufe 11 | `harness/tools/full-smoke.sh:2485` |
| [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) | Dasselbe am Root in der zweiten Sprache, mit gesetztem Image-Override | Stufe 12 | `harness/tools/full-smoke.sh:2528` |
| [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Ein zweites geschichtetes Modul; das Arch-Gate wird nicht doppelt eingebunden | Stufe 13 | `harness/tools/full-smoke.sh:2576` |
| [`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Ein drittes Layout mit eigenem Vokabular, seine zwei Regeln greifen | Stufe 14 | `harness/tools/full-smoke.sh:2624` |
| [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-05`](../../spec/lastenheft.md#lh-fa-05--root-readme-emittieren-f1-f2), [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) | Ein zweiter Lauf ueberschreibt Adopter-Inhalt nicht und heilt Doku-Drift | Stufe 15 | `harness/tools/full-smoke.sh:2751` |
| [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) | Ein belegter Pfad behaelt seinen Traeger, und der Lauf nennt ihn | Stufe 16 | `harness/tools/full-smoke.sh:2788` |
| [`LH-FA-06`](../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) | Die Aktivierung greift: ein Commit ohne Kennung faellt, einer mit geht durch | Stufe 17 | `harness/tools/full-smoke.sh:2814` |
| [`LH-FA-11`](../../spec/lastenheft.md#lh-fa-11--selbstprüfung-der-durchsetzungsschicht-emittieren), [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) | Das Ziel prueft seine eigene Durchsetzungsschicht auf einem frischen Klon seines Repos | Stufe 18 | `harness/tools/full-smoke.sh:3073` |
| [`LH-FA-12`](../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren), [`LH-FA-02`](../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) | Das Ziel erzeugt die Sicht ueber seine eigenen E2E-Stufen aus deren Deklarationen | Stufe 19 | `harness/tools/full-smoke.sh:3162` |
