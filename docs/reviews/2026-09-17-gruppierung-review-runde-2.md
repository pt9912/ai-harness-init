# Review der Gruppierung, zweiter Durchgang — `ADR-0057` nach der Einarbeitung — 0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO

**Rolle:** Reviewer · **Datum:** 2026-09-17 · **Geprüfter Stand:** `314c5b61` (HEAD, **lokal**),
Basis `22c8d67d` · **Gegenstand:** allein dieser Commit — `ADR-0057` nach Einarbeitung von R-1 und
R-2, samt Index-Zeile · **Review-Art:** Bestätigungsrunde derselben prüfenden Rolle nach
blockierendem Befund ([ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 2) · **Nicht Gegenstand:** R-3 und R-4 des ersten Durchgangs (sie betreffen das
Verdikt-Artefakt des Architects), die DoD-Abhakung und die sechs Gruppen-Pläne.

**Kennung dieser Runde:** `2026-09-17-gruppierung-review-runde-2` — das ist der Zeiger, den die
Accept-Zeile der §Geschichte nach
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1
nennt: Kennung, kein Pfad-Link, in der Form, die `ADR-0053`, `ADR-0055` und `ADR-0056` bereits
führen.

**Skill:** `.harness/skills/reviewer.md` @ `2.0.0` · **Modell:** `claude-opus-5[1m]`

---

## 1. R-1 — behoben

**Festlegung 1 führt die Singleton-Menge jetzt als vierte, positiv geführte Disposition im
Prüfbereich des Wächters**, und der Widerspruch der alten Fassung ist weg: Der Emitter behält
seinen `else`-Zweig, der Wächter leitet seine Sollmenge nicht mehr daraus ab. Die zwei Richtungen
sind benannt (Vollständigkeit, Disjunktheit), und die Disjunktheit hat den Grund, warum sie heute
unsichtbar ist, gleich dabei (`||` schließt kurz).

**Die drei Rot-Bedingungen sind am heutigen Dispatch herstellbar** — einzeln durchgespielt gegen
`internal/emit/templates.go` Zeile 355 (`isRecurring(…) || isDerivativeIndex(rel) ||
isBrownfieldOnly(rel) { continue }`) und Zeile 390 (Singleton-Zweig):

| Rot | Herstellbar? | Warum |
|---|---|---|
| **1** — Vorlage im geprüften Satz, in keiner der vier Mengen | **ja** | Die vierte Menge ist eine gepflegte Liste beim Wächter. Eine neue Vorlage im Satz steht dort nicht, fällt in keine Weiche und ist damit in **keiner** Menge — im Emitter wäre sie stumm ein Singleton. Genau die Differenz, die R-1 verlangt hat |
| **2** — ein Name der Singleton-Liste zusätzlich in `isRecurring` | **ja** | Der Wächter wertet jede Menge einzeln aus; die Vorlage steht dann in zwei Mengen. Im Dispatch bliebe es unsichtbar, weil `||` bei der ersten wahren Weiche abbricht |
| **3** — ein Name in `isRecurring` gegen einen anderen **aus dem Satz** getauscht | **ja, und zweifach** | Die herausgetauschte Vorlage steht danach in keiner Menge (**Vollständigkeit** fällt), die hereingetauschte in `isRecurring` **und** in der Singleton-Liste (**Disjunktheit** fällt). Die Kardinalität bleibt dabei gleich — ein Zähl-Test bliebe grün. Die Aussage *„fällt zweifach und nicht an einer Zahl"* **stimmt**, und sie ist genau der Punkt aus `AGENTS.md` §3.6 |

Die Einschränkung der Mutation auf *„einen anderen **aus dem Satz**"* ist dabei tragend und steht
im Text: Ein Fantasie-Name in der Weiche klassifiziert nichts, und die gemeinte Vorlage fiele dann
nur einfach (Vollständigkeit) — der Fall ist abgedeckt, nur nicht zweifach.

## 2. R-2 — behoben

**Festlegung 4 gibt der bestehenden Differenz einen Ausgang, der an keinem künftigen Akt hängt**,
und §Kontext sagt jetzt ausdrücklich, dass die Aussage **heute** unrichtig ist, *„ohne dass
irgendein Vorgang sie dazu gemacht hätte"*. Die Folgepflicht 2 ist entsprechend umgestellt: Für
`ADR-0020` folgt aus dem CR nichts mehr.

**Die Konstruktion trägt ohne Nachzug und ohne `Supersedes`** — geprüft an der Stelle selbst
(`docs/plan/adr/0020-emittierte-modul-15-regeln.md`, Zeile 528): Die Zahl steht in einer **Klammer
innerhalb der Begründung** zu Festlegung (e), und die Festlegung selbst nimmt den vendored Baum aus
dem geprüften Dokument-Satz — dieser Ausschluss ist von der Kardinalität unabhängig und gilt für
fünf wie für elf. Damit wird keine Festlegung abgelöst, und `Supersedes` hat kein Objekt
(`AGENTS.md` §3.4 bleibt unberührt). Dass die geltende Lesart **nur hier** steht und kein
Glossar-Eintrag daneben entsteht, ist die richtige Antwort auf die Drift-Frage — mit der
Einschränkung S-2.

## 3. Acceptance-Trigger und §Geschichte — formgerecht

Der Trigger steht als `###` unter `## Re-Evaluierungs-Trigger`, also unter der geschlossenen
`##`-Gliederung der Vorlage; er verlangt *„eine erneute Runde derselben prüfenden Rolle"* und
verwirft die Nachmessung des auflösenden Kontexts ausdrücklich — das ist
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
wörtlich angewandt. Dass er **jetzt** eingefügt wurde, während die Datei `Proposed` ist, ist der
Weg, den Festlegung 3 derselben ADR vorschreibt. Die Vorgabe, die Accept-Zeile nenne die Runde
*bei ihrer Kennung*, deckt Festlegung 1 (Kennung, nicht Pfad-Link, über beide Adress-Formen) und
entspricht der Form von `ADR-0053`, `ADR-0055` und `ADR-0056`.

**§Geschichte ist in Ordnung:** zwei Zeilen, die zweite nennt Ereignis (*Befunde der ersten Runde
eingearbeitet*, mit den drei berührten Stellen), den unveränderten Status und den Verweis als
Kennung statt als Pfad. Sie ist Zustand mit Beleg, keine Erzählung.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| S-1 | LOW | Die Vollständigkeit wird *„gegen den **in-scope**-Teil des vendored Satzes"* geprüft; was eine Vorlage in-scope macht, sagt die ADR nicht, und die §Grenze nennt nur die inhaltliche Grenze. Ein Wächter, der den Ausschnitt eng schneidet, ist grün über einer Teilmenge, und die Zusage liest sich über den ganzen Satz — die Lage, für die `modul-13-quality-gates.md` §Hard Rule verlangt, die Differenz **mit dem Kommando** zu benennen, das den Ausschnitt zeigt. Die Festlegung friert mit dem Accept ein, der Ausschnitt entsteht erst im Slice. | `modul-13-quality-gates.md` §Hard Rule (Doku-Disziplin), *Ein Gate ohne seine Grenze* · `AGENTS.md` §3.6 | `docs/plan/adr/0057-…md`, §Entscheidung Festlegung 1, erster Absatz, und §Fitness Function Zeile 1 | ja: zwei Wächter mit verschiedenem Ausschnitt sind beide grün | Bezugsmenge einer Vollständigkeits-Zusage benannt, nicht definiert |
| S-2 | INFO | Für dieselbe Klasse — die geltende Lesart einer überholten Aussage in einer `Accepted`-ADR — führt das Repo jetzt **zwei** Träger: das Glossar in `harness/conventions.md` (für die Slice-Nummer in `ADR-0011`) und, seit Festlegung 4, die ablösende ADR selbst. Welcher wann gilt, sagt keine Quelle. Heute driftet nichts, weil jede der zwei Aussagen genau einen Träger hat. Zuständig: Architect. | `harness/conventions.md` §Glossar als Präzedenz | `ADR-0057` §Entscheidung Festlegung 4 | nein | zwei Träger für eine Aussagen-Klasse ohne Zuordnungsregel |
| S-3 | INFO | Die Lead-Zeile von Festlegung 1 verschachtelt Fettung: `**Festlegung 1 — der Wächter führt **vier** Dispositionen …**`. Das innere Paar schließt das äußere; die Zeile rendert anders als die drei übrigen Festlegungen, und die Datei friert mit dem Accept ein. | Maintainability (Darstellung in einem einfrierenden Artefakt) | `docs/plan/adr/0057-…md:93` | ja: Render-Vergleich mit Festlegung 2 bis 4 | verschachtelte Fettung in einer Lead-Zeile |

Kein HIGH, kein MEDIUM. **Kein blockierender Befund.** Kein Rollen-Konflikt.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Widerspruchsfreiheit nach der Umschrift | geprüft, ohne Befund: *„in vier Festlegungen"*, die Re-Evaluierungs-Trigger auf *vier Mengen*, Option B und C in der Alternativen-Tabelle nachgezogen, und die alte Positiv-Konsequenz *„keine neue geführte Liste entsteht"* ist durch *„die stille Default-Stelle bekommt einen Zeugen"* ersetzt — die Liste steht jetzt korrekt als **Negativ**-Konsequenz da |
| Der Dispatch bleibt unberührt | geprüft, ohne Befund: die ADR verlangt ausdrücklich keinen Umbau am Emitter; alle drei Rot-Bedingungen kommen ohne einen aus |
| Zitat aus `ADR-0020` Festlegung (e) | geprüft, ohne Befund: *„Welcher Satz das ist, ist eine Regel und keine Aufzählung"* steht dort wörtlich (Zeile 515) und trägt den Präzedenz-Schluss |
| `AGENTS.md` §3.4 | geprüft, ohne Befund: `ADR-0020` wird nicht angefasst; Festlegung 4 setzt eine Lesart, statt eine Festlegung abzulösen |
| `AGENTS.md` §3.5 | geprüft, ohne Befund: die Umschrift **verschärft** (aus einer unerreichbaren Rot-Bedingung werden drei erreichbare) |
| `AGENTS.md` §3.8 / §3.11 | geprüft, ohne Befund: eigener Commit, nur ADR und ADR-Index, Rolle in der Message; Verweise auf Zeitdokumente stehen als Kennung, nicht als Pfad |
| `MR-025` | geprüft, ohne Befund: die Umschrift führt keine neue Zahl ein; die vier Kommandos in §Kontext stehen unverändert und sind im ersten Durchgang nachgemessen |
| Index-Zeile | geprüft, ohne Befund: `ADR-0040` in Bezug und Index gleichlautend ergänzt, Status weiter `Proposed` |
| Typo-Fall in einer Weiche | geprüft, ohne Befund: Ein Name ohne Vorlage im Satz klassifiziert nichts; die gemeinte Vorlage fällt dann an der Vollständigkeit, und der verbleibende Fall (Vorlage steht fälschlich in der Singleton-Liste) ist als inhaltliche Grenze ausdrücklich benannt |

## Summary

**0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO — kein blockierender Befund.** R-1 ist behoben: Die
Singleton-Menge ist vom `else`-Zweig zur vierten, positiv geführten Disposition geworden, und alle
drei Rot-Bedingungen sind am heutigen Dispatch herstellbar; Rot 3 fällt tatsächlich zweifach und
nicht an einer Zahl. R-2 ist behoben: Festlegung 4 gibt der bestehenden Differenz einen Ausgang,
der ohne Nachzug an `ADR-0020` und ohne `Supersedes` trägt. Keine neue wiederkehrende Klasse für
die Closure §7.

## Verdikt

**`ADR-0057` kann nach `Accepted`.** Diese Runde ist der Beleg, den der Acceptance-Trigger
verlangt: erneute Runde derselben prüfenden Rolle, frischer Kontext, kein blockierender Befund. Die
Accept-Zeile nennt sie bei der Kennung `2026-09-17-gruppierung-review-runde-2`.

S-1 gehört vor das Accept entschieden, wenn die Bezugsmenge in der ADR stehen soll — sie friert mit
ihr ein; er ist kein Block, weil der umsetzende Slice den Ausschnitt ohnehin festlegt und dort
geprüft wird. S-2 und S-3 sind Won't-Fix-fähig; S-3 ist vor dem Accept billiger als danach.

**Stufe 2 für Gruppe 4** wird mit dem Accept frei, sobald der Plan nach Auftrag 1 des
Architect-Verdikts nachgezogen ist. Die übrigen Gruppen stehen wie im ersten Durchgang.
