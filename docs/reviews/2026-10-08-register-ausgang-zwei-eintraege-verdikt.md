# Architect-Verdikt: Register-Ausgang für zwei Einträge über der Schwelle — 2026-10-08

**Rolle:** Architect (Modul 8, Welle-Closure Schritt 3b) · **Bezug:**
[ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md),
[ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md) · **Anlass:** `make register-ausgang`
meldet beide Einträge mit drei Belegen und Stand `offen`. `state.md` schreibt der Planner; dieses
Verdikt ist sein Übergabe-Artefakt. Auftraggeber-Vorgabe: kein neuer Slice.

## 1. `BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger` — **verkörpert**

**Zielort:** der `codepaths`-Block der emittierten Gate-Vorlage `internal/emit/templates/d-check.yml`
(Modul in `modules:` des Ziels), gehalten vom Zahn in `make full-smoke` und den Mutations-Fällen
`573`–`578`; Träger-Kennung [`MR-087`](../../harness/conventions.md#mr-087) (Einlösung von
[`MR-054`](../../harness/conventions.md#mr-054) Setzung 3).

**Begründung.** Alle drei Belege (`slice-182`, `slice-184`, `slice-190`) sind derselbe Fall: ein
mitemittierter Text führt einen **Ort**, den das frische Ziel nicht trägt. Genau das färbt das
Doku-Gate jedes gebootstrappten Ziels jetzt mit `codepath-missing` rot. **Kein
`seit`-Anker:** der Sensor folgt aus einem Adaptions-Eintrag und trägt damit dessen ID
(`grundlagen-traceability.md` §Herkunfts-Anker, *Geltungsbereich — eng*).

**Akzeptierte Negative.** (a) Die *Aussagen-Hälfte* (eine emittierte Eigenschafts-Zusage ohne Pfad)
gehört nicht zur Klasse dieses Eintrags, die an Orten hängt. Sie ist die Klasse von
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` und zählt dort weiter. (b) Der
Fall `slice-184` lag in der Nutzerdoku *dieses* Repos, nicht im Ziel. Den Ort legt der Bootstrap
inzwischen an (`slice-194` in `done/`). Ein Einzelfall ohne Wiederholung, dafür kein eigener Träger.

## 2. `BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` — **geplant**

**Kennung:** `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` (in `open/`), dort Regel 3
*Messstelle*: Eine Messung an einer Stelle wird nicht als Eigenschaft des Ganzen ausgegeben.

**Begründung.** Ein Prosa-Satz „Gate X meldet Zustand Y" ist eine Werkzeug-Aussage in einem lebenden
Artefakt. Sein Fehler ist genau die Ausschnitt-Achse von Regel 3: ein Modul-Prüfumfang (eine Spalte,
ein Prüfbereich) wird als Eigenschaft des ganzen Bereichs gelesen. Der Slice nimmt die Klasse an.
Sein Geltungsbereich umfasst ausdrücklich jedes lebende Artefakt, und sein Ausschluss „kein Sensor"
deckt sich mit der Lage, die `observation.md` beschreibt: Kein Modul hält Prosa gegen einen
Prüfumfang. Die Baseline führt die Regel bereits (`modul-13-quality-gates.md` §Hard Rule, *Ein Gate
ohne seine Grenze behauptet ebenfalls zu viel*). Der Slice schreibt sie nicht ab. Er verankert die
Repo-Form für Werkzeug-Aussagen.

**Mitgabe an den Planner.** Bei der Fortschreibung ergänzt der Planner die Belege-Liste in §1 des
Slice um diesen Eintrag (Regel 3). Erst damit führt die Adresse den Gegenstand namentlich.

**Akzeptiertes Negativ.** Die emittierte Hälfte des Belegs `slice-211-…` (Kopfkommentar der
emittierten Vorlage) schließt der Slice per Schicht-Abgrenzung aus. Sie zählt unter
`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`, nicht hier.

**Negativbefunde:** Für keinen der beiden Einträge ist *gestrichen* begründbar: Beide Klassen können
wieder auftreten, die erste wird jedoch rot gemeldet.
