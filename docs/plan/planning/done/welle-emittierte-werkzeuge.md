# Welle welle-emittierte-werkzeuge: Jede vorgeschriebene Operation hat im Ziel ein Werkzeug

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<Kennung>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug. Der klassen-nächste ist M3 (*durchsetzender,
phasierter Harness — Hooks + Command-Guard + Workflow-Anleitung emittiert*); er ist **erreicht**, sein
Trigger nennt [welle-04](welle-04-durchsetzung-und-emission.md) und
[welle-05](welle-05-bootstrap-phasen.md) und wird von dieser Welle nicht erneut gefahren — eine
Welle, die die Klasse einer erreichten Stufe fortsetzt, ist nicht ihr Beleg. M6
([`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)) ist die
Erfassungsschicht, eine andere Klasse. Ein eigener Meilenstein wird hier nicht geschnitten: Er endet
nach Modul 6 durch **externe** Bestätigung (Audit, Release, Kunde), und eine solche nennt kein
Kriterium dieser Welle — ihr stärkster Beleg ist ein repo-interner Smoke.

**Verantwortlich:** Planner. **Datum:** 2026-09-14.

---

## 1. Welle-Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht.

**Jede Operation, die der emittierte Anweisungssatz und das emittierte Regelwerk dem Ziel
vorschreiben, hat dort ein Werkzeug — oder einen Satz, der die Lücke benennt.**

Der Gegenstand liegt auf der **emittierten** Ebene, nicht im Dogfood: Was `ai-harness-init` in ein
fremdes Repo schreibt, wird gegen das gehalten, was es dort zu tun verlangt. Zwei Anforderungen
tragen ihn — [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)
(die Durchsetzungsschicht: Stop-Hook, Gate-Nachweis, Command-Guard) und
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
Anleitung: die Workflow-Commands). Wo eine Operation ohne Werkzeug bleibt, ist der Ausgang nach
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ein
**benannter Satz** — keine stillschweigende Zusage.

**Was das Ziel heute bekommt.** Gemessen am Emit-Baum, nicht am Prosa-Text: die Fragmente im
Fragment-Verzeichnis des Ziels (Vorlagen unter
[`internal/emit/templates/enforce/`](../../../../internal/emit/templates/enforce/) sowie der im Code
gebaute Doc-Gate-Block), dazu das sprachgebundene Fragment, die drei Hooks
`.claude/hooks/{stop-require-gates,pretooluse-command-guard,span-emit}.sh`
(`grep -c '\.sh", "\.claude/hooks/' internal/emit/enforce.go` → **3**), die `doc-*`-Familie aus dem
tool-generierten `d-check.mk`, und der **Träger** in `.harness/state/bin/ai-harness-init`, der
`archive-welle`, `span-report`, `vendor-baseline` und `add-lang` als Unterkommandos führt. Die Zahl
ist kein Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Lücke dieses Zuschnitts ist die fehlende Zündung, nicht der fehlende Ausweg.** Der emittierte
Anweisungssatz ist an mehreren Stellen **selbstkonsistent**: er verlangt ein Werkzeug *und* liefert
den ehrlichen Ausgang mit. Am deutlichsten in
[`internal/emit/templates/commands/close-welle.md`](../../../../internal/emit/templates/commands/close-welle.md)
Schritt 4: *„Die Operation gehört in ein Werkzeug, nicht in Handarbeit"* — gefolgt von *„Hat dein
Repo das Werkzeug nicht, ist die Bedingung nicht eingetreten; **das** gehört als Feststellung in die
Results-Notiz"*. Der Träger **kann** die Archivierung; im Ziel fehlt allein der Weg zu ihm: es gibt
kein Make-Ziel, und der Anweisungssatz zeigt nicht auf den Träger. Diese Unterscheidung ist
tragend — sie verlegt die Arbeit von *„den Satz durch ein Versprechen ersetzen"* auf *„die Zündung
legen"*, und sie hält die Feststellungs-Zeile unangetastet (§6).

**Der Zustand ist gemessen, nicht behauptet.** Für die vier Mitglieder trägt §4 je einen Satz; die
Messung, auf der die Auswahl ruht, ist die Zählung, was der emittierte Satz verlangt und was der
Emit-Baum dazu führt — namentlich:

```sh
git grep -c 'history-range-guard' -- internal/ | wc -l
git grep -c 'slice-mv'   -- internal/emit internal/gen | wc -l
git grep -c 'archive-welle' -- internal/emit internal/gen | wc -l
git grep -c 'commit-msg' -- internal/ | wc -l
```

**Die Messung trägt als Eigenschaft, nicht als Betrag** ([`MR-058`](../../../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
Setzung 2): Der schreibende Vorgang — diese Welle — **bewegt ihre eigene Bezugsmenge**, weil jedes
ihrer vier Mitglieder gerade in `internal/` schreibt. Was die vier Kommandos **zum Schnitt** zeigten:
*kein Ziel kannte den Vorlauf-Wächter, den Verweis-Nachzug, den Archivierungs-Träger oder den
Kennungs-Wächter* — das ist die Eigenschaft, auf der die Auswahl der vier Mitglieder ruht. Die vier
Beträge sind darum **nicht** angeführt: sie galten für den Stand vor dem ersten Mitglied und in
keinem Moment danach ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 — die Kommandos bleiben, sie sind der Weg zu der Eigenschaft; der Betrag fällt).

**Drei Klassen, und nur die erste wird gebaut.** *Klasse 1* — der emittierte Prozess schreibt die
Operation vor, das Ziel hat kein Werkzeug: ihre Mitglieder stehen in §4. *Klasse 2* — übertragbar,
aber **nicht** Mitglied: §6 führt sie mit je einer Begründung, damit sie nachholbar bleiben.
*Klasse 3* — nicht übertragbar, Gegenstand ist *diese* Emission: §6 nennt sie als **Klasse**.

## 2. Trigger (Welle startet)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Regeln — ein Trigger ist **beobachtbar** dann, wenn ein *anderer*
Mensch ohne Rückfrage sagen kann, ob er eingetreten ist; ein Datum darf erwähnt
werden, aber nie Trigger sein. Und der **Start**-Trigger ist **kein Ergebnis
dieser Welle**: Steht er in der Slice-Liste unten, ist er falsch platziert.

- **[welle-13](welle-13-regeln-bekommen-ihren-sensor.md) liegt in `done/`** — beobachtbar
  ohne Rückfrage: `ls docs/plan/planning/done/welle-13-*` führt Plan-Datei und Ergebnis-Notiz.
  **Tragend**, nicht ordnend: diese Welle berührt die Vorlagen unter
  [`internal/emit/templates/`](../../../../internal/emit/templates/) und die Fragmente, die daraus ins
  Ziel gehen, und `welle-13` bewegt die Gate-Konfiguration des Dogfoods selbst (Modul-Liste, `vcs`/`commits`)
  — die Fläche soll ruhen, während sie sich bewegt.
- Keine weitere Bedingung. **Die Welle war nie in der Vorschau *Nächste Wellen*** — sie ist hier
  geschnitten und eröffnet, nicht aus einem Kandidaten befördert; es gibt darum keine Vorschau-Zeile
  und keine Trigger-Verschiebung, die ihr Eintritt erzeugte.

## 3. Closure-Trigger (Welle schließt)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht — der Trigger muss das *Mehr* gegenüber den
einzelnen Slice-DoDs benennen; kann er das nicht, liegt keine Welle vor.

- **Entschieden und aufgeschrieben:** für **jede** Operation, die der emittierte Satz vorschreibt,
  steht an einem auflösbaren Ort, ob das Ziel sie ausführen kann — mit Kennung des Trägers oder als
  benannte Lücke. Das *Mehr* gegenüber jeder Slice-DoD: kein Mitglied führt die Vollständigkeit der
  Menge, jedes nur seinen Gegenstand.
- **`make full-smoke` fährt die neu emittierten Werkzeuge im gebootstrappten Ziel einmal durch.**
  Ein Werkzeug, das nur in [`internal/emit/`](../../../../internal/emit/) existiert und im Ziel nicht
  läuft, schließt die Welle nicht — die Zusage
  [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) ist repo-weit, und kein
  Mitglied trägt sie.
- Alle Slices dieser Welle liegen in `done/`.
- `make gates` grün.
- Closure-Notiz `welle-emittierte-werkzeuge-results.md` mit einem Steering-Loop-Eintrag
  (geschärfte Regel · neuer Sensor · benannte Spec-Lücke, Modul 5).
- Der **Lese-Schritt** über das Beobachtungs-Register ist gefahren: was 3× erreicht hat, hat seinen
  Ausgang.
- **Die zwei in §6 benannten Lücken stehen in der Ergebnis-Notiz.** Sie bleibt vollständig und
  flach, während die Zeitdokumente dieser Welle ins Archiv wandern — ohne diesen Schritt verschwände
  ein benannter Posten mit dem Archiv.

## 4. Slices in dieser Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine — der Zustand eines Slice ist sein
Lifecycle-Verzeichnis und wird hier **nicht** gespiegelt.

Mitglied ist, wer `**Welle:** welle-emittierte-werkzeuge` im Kopf trägt; diese Tabelle führt die
Mitglieder nach, sie vergibt sie nicht.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-vorlauf-waechter-geht-ins-ziel](slice-vorlauf-waechter-geht-ins-ziel.md) | Der Vorlauf-Wächter der zwei history-lesenden Targets geht ins Ziel | [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |
| [slice-lifecycle-move-geht-ins-ziel](slice-lifecycle-move-geht-ins-ziel.md) | Der Lifecycle-Move zieht seine Verweise im Ziel nach | [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) |
| [slice-174-archivierung-emittieren](slice-174-archivierung-emittieren.md) | Ein gebootstrapptes Ziel erreicht die Wellen-Archivierung | [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) |
| [slice-kennungs-waechter-geht-ins-ziel](slice-kennungs-waechter-geht-ins-ziel.md) | Der Traceability-Constraint bekommt im Ziel einen Träger | [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) |

**Ein Mitglied steht schon und wurde nicht neu geschnitten.**
[slice-174](slice-174-archivierung-emittieren.md) lag in `next/` und trägt denselben
Gegenstand; sein Kopf-Feld ist auf diese Welle gezogen, statt einen zweiten Slice daneben zu legen.
Sein Liefer-Punkt bleibt; seine Begründung ist gezogen — der emittierte Satz ist selbstkonsistent
(§1), offen ist die Zündung. **Das fertige Muster dafür steht im Baum**, es muss nicht erfunden
werden: [`internal/emit/templates/enforce/erfassung.mk`](../../../../internal/emit/templates/enforce/erfassung.mk)
Ziel `span-report` setzt eine Variable auf den Trägerpfad, probiert sie samt `.exe`-Endung und
**sagt es**, wenn der Träger fehlt. Für `archive-welle` heißt das: kein Prerequisite (der Dogfood
hängt dort `host-bin` an, und der Bau hat im Ziel keinen Gegenstand — der Träger wird abgelegt, nicht
gebaut), keine neue Logik, und die zwei Sperren des Unterkommandos kommen mit dem Aufruf mit.

## 5. Abhängigkeiten

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Struktur: fünf Abschnitte.

- **Wird blockiert von:** [welle-13](welle-13-regeln-bekommen-ihren-sensor.md) — der
  Start-Trigger in §2, tragend.
- **Blockiert:** nichts. Kein offener Slice nennt diese Welle als Vorbedingung.
- **Berührt, aber bindet nicht — die Dogfood-Zwillinge.** Vier offene Slices fassen dieselben
  Vorlagen auf der **Dogfood**-Seite an; die Mitglieder dieser Welle übernehmen ihr Ergebnis, statt
  es vorwegzunehmen:
  [slice-226](slice-226-implementer-anweisungssatz-zieht-nach.md) (der ausgeführte
  `implement-slice.md` gegen die Ziel-Fassung),
  [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md) (die zwei ausgeführten
  Wellen-Anweisungssätze gegen die Abschnitte, die die Roadmap führt),
  [slice-215](slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md) (der **Träger**
  des Commit-Kennungs-Wächters — er entscheidet den Kanal, den ein emittierter Wächter erben würde)
  und [slice-ortswechsel-zieht-sein-zustandsfeld-nach](../open/slice-ortswechsel-zieht-sein-zustandsfeld-nach.md)
  (die dritte Hälfte eines Ortswechsels: das bewachte Zustandsfeld).
- **Zwei Ebenen, zwei Verträge.** `slice-226` und `slice-215` schreiben **Dogfood**-Dateien; die
  Mitglieder dieser Welle schreiben **Emissions**-Vorlagen. Die zwei dürfen nicht auseinanderlaufen,
  und deshalb ist die Richtung eine: erst die ausgeführte Fassung, dann die emittierte.

## 6. Out-of-Scope für diese Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Eröffnung Schritt 1 — Out-of-Scope gehört zur
Zielsetzung: Was nicht ausdrücklich ausgeschlossen ist, dehnt die Welle, bis
der Closure-Trigger unerreichbar wird.

**Klasse 2 — übertragbar, aber kein Mitglied.** Je ein Satz, woran es scheitert oder wem es gehört:

- `*-freshness.sh` (`component`/`go`/`cpp`/`baseline`) — die Image-Pins und die zwei Upstream-Achsen
  sind eine Aussage über die **gepinnten Werkzeuge dieses Repos**; der Ziel-Fall hängt an
  [slice-090](../next/slice-090-freshness-audit-im-ziel.md), und ein zweiter Träger daneben wäre eine
  zweite Fassung derselben Achse.
- `mutate.sh` — der **Treiber** ist generisch, der **Fallsatz** ist eine Repo-Aussage: `test/mutations/`
  hängt an den Zähnen *dieses* Repos, und ein mitgelieferter Fallsatz behauptete Fälle, die es im
  Ziel nicht gibt ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- `comment-claims.sh` — er urteilt über Kommentare, deren Bestand das Ziel selbst erst schreibt, und
  ist an die Sensor-Namen dieses Repos gebunden; sein Prüfbereich ist offen
  ([slice-070](../open/slice-070-comment-claims-pruefbereich.md)).
- `sessionstart-inject-regelwerk.sh` — das Ziel vendort die Baseline ebenfalls, der Injektor ist damit
  **übertragbar**; er ist aber ein **Angebot an den Agenten**, keine Operation, die der emittierte
  Satz vorschreibt — die Mitgliedschaft dieses Zuschnitts entscheidet die Vorschrift, nicht die
  Übertragbarkeit.
- `hook-overhead.sh` — misst den Aufschlag je Tool-Call und ist damit eine Aussage über den
  **laufenden Agenten dieses Repos**; kein Wort des emittierten Satzes verlangt eine solche Messung
  vom Ziel.

**Klasse 3 — nicht übertragbar, Gegenstand ist *diese* Emission.** Der E2E-Smoke und seine
Helfer, die Betriebsmaschinerie um Träger, Span-Bestand und Artefakt-Kopie: sie prüfen *dieses* Repo
gegen den Baum, den *es* erzeugt. Ein Ziel kann sie nicht fahren — es hat kein zweites Ziel. Diese
Klasse wird als **Klasse** benannt und nicht einzeln aufgeführt; die Zugehörigkeit entscheidet der
Gegenstand („prüft den Emitter"), nicht der Dateiname.

**Die drei Slices am emittierten `d-check.yml`.** [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md),
[slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md) und
[slice-emittierte-gate-vorlage-traegt-targets-und-reviews](../open/slice-emittierte-gate-vorlage-traegt-targets-und-reviews.md)
entscheiden die **Modul-Liste** der emittierten Startkonfiguration. Das ist eine andere Fläche als
die der Mitglieder hier: diese entscheiden **Ziele und Wächter**, jene **Module**. Sie bleiben
wellenlos, und die Auswahl der Mitglieder kreuzt sie nicht.

**Die Feststellungs-Zeile in `close-welle.md` zu ändern.** Sie ist der ehrliche Ausgang für ein Repo
ohne das Werkzeug und bleibt wörtlich stehen; Gegenstand ist die **Zündung**, nicht der Satz. Sie zu
ersetzen wäre ein anderer Vorgang und nähme dem Adopter die Antwort, die das Regelwerk für eine
fehlende Fähigkeit vorsieht.

**Der Bestand.** Wellen, die vor dieser Eröffnung schlossen, werden nicht nachgerüstet; gebunden ist
die Emission, die geschrieben wird — dieselbe Linie, die Modul 6 für die Archivierung zieht.

**Der Nachzug des lokalen Anweisungssatzes — geprüft und ausgeschlossen, mit Kennung.**
[slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md) und
[slice-226](slice-226-implementer-anweisungssatz-zieht-nach.md) tragen ihn auf der
**Dogfood**-Seite; die Welle nimmt sie **nicht** auf, und das ist eine Entscheidung, kein
Übersehen. Ihr Gegenstand ist die **emittierte** Ebene, und ihr Closure-Trigger fährt die Werkzeuge
im Ziel — die zwei Slices fahren Texte. Die Prüfung, ob sie den Gegenstand deckten, ist gefahren:
Sie **tragen** (beide Fundstellen sind am Baum noch vorhanden), decken aber das **Paar** aus
ausgeführter und emittierter Fassung nicht; sie reparieren den lokalen Text gegen das Regelwerk.
**Die verbleibende Lücke wird darum benannt, nicht still gelassen:** kein Sensor hält den lokalen
Anweisungssatz gegen die emittierte Vorlage — sie sind zwei getrennte Artefakte, und keines nennt
das andere als Quelle. Ein Wächter darüber ist ein **eigener Vorgang** (ein Sensor über zwei
Textartefakte, nicht ein Werkzeug im Ziel) und gehört dem, der die Sensor-Landschaft schneidet; er
wird hier ausdrücklich **nicht** mitgeschnitten.

**Die zwei `close-welle.md` weichen in Schritt 2 auseinander — benannter Posten, ohne Kennung.**
Gemessen über die zwei Fassungen desselben Ablaufs:

| Schritt 2 | [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | [`internal/emit/templates/commands/close-welle.md`](../../../../internal/emit/templates/commands/close-welle.md) |
|---|---|---|
| Gegenstand | **Carveout-Audit** — eine Klasse | **Trigger-Audit der Welle** — drei Klassen |
| genannte Module | 5, 6, 7 | 4, 5, 6, 7, 13 |

Die lokale Fassung lässt **zwei der drei Trigger-Klassen weg**, die Modul 6 verlangt (*„Drei
Artefaktklassen tragen einen Trigger, alle drei werden geprüft"*) — namentlich den
Reifestufen-Zweig und den Entscheidungs-Zweig. Das ist **kein** Posten dieser Welle: die Welle
fährt Werkzeuge im Ziel; dieser Befund ist eine **Drift zwischen zwei Textartefakten** und eine
Unvollständigkeit gegen das Regelwerk. Er liegt auf derselben Fläche wie die zwei Slices darüber,
und **keiner von beiden trägt den Schritt**: [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md)
zieht die Roadmap-Abschnittsnamen nach, [slice-226](slice-226-implementer-anweisungssatz-zieht-nach.md)
die Plan-vor-Code-Blöcke. Eine **Kennung fehlt** — der Posten ist heute an keiner Datei; die Welle
schneidet dafür keinen vierten Slice, weil ein Nachzug über zwei Ebenen desselben Ablaufs ein
**eigener Vorgang** ist. Er wird hier benannt und geht über §3 in die Ergebnis-Notiz, damit er nicht
mit dem Wellen-Archiv verschwindet.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker für Steering-Loop-Regeln — dort die **Ruheort-Regel**: Die
beiden Zeiger unten sind so zu schreiben, wie sie vom Ruheort `done/` auflösen,
nicht vom Schreibort.

Ergebnis: die Ergebnis-Notiz [`welle-emittierte-werkzeuge-results.md`](welle-emittierte-werkzeuge-results.md)
— Geschwister im Ruheort `done/`. Zähler: das Beobachtungs-Register — eine Ebene über dem Ruheort,
wie es die Vorlage der Ergebnis-Notiz führt.

Der Zustand dieser Welle ist die Verzeichnis-Position, kein Status-Feld.
