# Slice slice-archivierung-erkennt-benannte-slices: Die Archivierung erkennt benannte Slices

**Kennung:** benannt nach [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 1.

**Lifecycle:** Der Zustand ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** [welle-adopter-weg-im-ziel](../welle-adopter-weg-im-ziel.md) — Closure verlangt `make gates` und `make full-smoke` grün auf demselben Commit, das *Mehr* über diese DoD.

**Bezug:** [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1 und 3 (Erkennung trägt die zugelassenen Formen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`AGENTS.md`](../../../../AGENTS.md) §3.6, [ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Altbestand), [ADR-0077](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md) (Slice-Closure-Archiv). Herkunft: Fund der Verifikation von `slice-kennungs-erkennung-traegt-die-zugelassenen-formen`, dort §7 Fundliste.

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** `internal/archive` liest die Kennung eines benannten Slice (`slice-<Kennung>`) wie die einer Nummer — Review-Reports werden eingesammelt, der Stub trägt seine Kennung und seinen Titel.

Der Fund (Lesung, nicht Grep): `SliceNummer` (`internal/archive/collect.go:101`, `^slice-([0-9]+[A-Za-z]*)`) liefert für einen benannten Slice `""`; `Reviews()` überspringt ihn (`nr == ""`), `sliceStub` setzt `<Kennung>` leer (`anwenden.go:269`), `kennungRE` (`stub.go:149`, `slice-[0-9]+…`) streift die Kennung nicht vom Titel. Das Review-Grep des Vorgänger-Slice fand es nicht, weil sein Muster `slice-\[0-9\]` die Zeile mit `([0-9]+` nicht trifft.

**Betroffen ist der Altbestand.** `archive-welle altbestand` ([ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 1) sammelt jeden flach in `done/` liegenden wellenlosen Slice: 114 benannte (`for f in docs/plan/planning/done/slice-[a-z]*.md; do grep -q '^\*\*Welle:\*\* ohne Welle' "$f" && echo "$f"; done | wc -l`, gelesen 2026-10-08; keine Erwartungswerte) neben den Nummern-Slices; weitere 9 benannte sind Welle-Mitglieder (dieselbe Schleife mit `||`). Ohne diesen Slice archiviert der Lauf ihre Reports **nicht** und schreibt Stubs ohne Kennung. **Dieser Slice ist Start-Bedingung des realen Altbestand-Laufs** und jeder Slice-Closure-Archivierung eines benannten Slice ([ADR-0077](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md)); die Vorschau (`archive-welle --vorschau`) darf vorher gelesen werden, der schreibende Lauf wartet.

**Ausdrücklich NICHT in diesem Slice:**

- **Der reale Altbestand-Lauf.** Anderer Vorgang (Werkzeug-Nutzung, Verweis-Nachzug über den Altbestand); er braucht diesen Slice, liefert ihn nicht.
- **Die Zuordnung eines Reports zu seinem Slice jenseits des Dateinamens.** Die Reports tragen die Kennung im Namen (`ls docs/reviews | grep -c 'slice-[a-z]'` → 179 von `ls docs/reviews | wc -l`); wo ein Report sie nicht trägt (der Review des Vorgängers heißt `…-dogfood-hook-benannte-slices-review.md`), bleibt er unzugeordnet — Bestand, bewusst: ein Inhalts-Lesen wäre ein anderer Vorgang mit eigener Fehlerklasse.
- **Die Anker-Präfix-Form** (`slice-ADR-…`, Großbuchstaben): in `stub.go:239` als Grenze benannt, noch nicht vergeben.
- **Die emittierte Ebene.** Das Unterkommando ist Produkt-Code; was Zielrepos bekommen, ändert sich nur über denselben Code — ein Zielrepo-Beleg ist nicht Gegenstand, die Schicht-Abgrenzung hält den Slice in `internal/archive`.

## 2. Definition of Done

- [x] **(1) `SliceNummer` und `ReviewTrifft` tragen die benannte Form.** Ein benannter Slice liefert seine Kennung; `ReviewTrifft` trifft die Reports mit voller Kennung und **nicht** die eines Slice, dessen Name sie als Präfix trägt — Mittel: Wortgrenze wie bei der Nummer **und** der Report gehört der längsten Lifecycle-Kennung, die er trägt. **Grenze:** fehlt der längere Slice im Lifecycle, zieht der kürzere dessen Reports mit (§7, §6 (2)). Die Nummernform des Bestands bleibt unverändert (`001`, `001a`).
- [x] **(2) Stub und Titel tragen die Kennung.** `sliceStub` setzt `<Kennung>` für benannte Slices, `TitelVon` streift `slice-<Kennung>` samt Trenner vom Titel.
- [x] **(3) Der Fall ist rot gesehen.** Test über benannte Slices (Reviews, Stub-Kennung, Titel) färbt rot gegen den Vorzustand und bleibt für die Nummernform grün; ein Mutations-Fall bindet `SliceNummer`. `archive-welle --vorschau altbestand` nennt danach die Reports der benannten Slices (gelesene Ausgabe).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [x] Doku-Update: [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md), falls es die Nummernform als Bedingung führt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register fortgeschrieben (kein Zähler wird gesetzt); keine Beobachtung angefallen ist ebenfalls eine Antwort.
- [x] Jedes Risiko aus §6 trägt einen Ausgang.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/collect.go` | update | `SliceNummer` und `ReviewTrifft`: benannte Form (DoD 1) |
| `internal/archive/stub.go`, `anwenden.go` | update | Titel und `<Kennung>` des Stubs (DoD 2) |
| `internal/archive/*_test.go`, `test/mutations/` | update/neu | Fall je Form, rot gesehen (DoD 3, [`AGENTS.md`](../../../../AGENTS.md) §3.6) |
| `internal/archive/collect.go` (`lifecycleKennungen`) | neu | Die Wortgrenze allein trennt `slice-foo-r2` (Runde) nicht von `slice-foo-bar` (anderer Name) — hinter einem Namen ist der Bindestrich beides. `ReviewTrifft` nimmt darum die Kennungen des Lifecycle als Vergleichsmenge, und ein Report gehört dem längsten Namen, den er trägt (DoD 1, Präfix-Hälfte) |
| `harness/sensors/archive-welle.md` | update | Die Zuordnungs-Regel steht bei den Grenzen der Einsammel-Regel |

## 4. Trigger

**Start** (`next` → `in-progress`): die Planung des Altbestand-Laufs oder die erste Slice-Closure-Archivierung eines benannten Slice steht an; `in-progress/` ist frei, `Verantwortlich:` gesetzt.

**Rückführungen:**

- `in-progress` → `next`: wenn die Zuordnung der Reports zu benannten Slices mehr verlangt als den Dateinamen (Inhalts-Lesen) — dann sind es zwei Slices.
- `in-progress` → `open`: wenn `archive-welle` die benannte Kennung an einer Stelle außerhalb von `internal/archive` liest und der Nachzug eine Entscheidung braucht.

## 5. Closure-Trigger

1. DoD 1 bis 3 belegt, die Vorschau des Altbestands nennt die Reports benannter Slices.
2. Der unveränderte Bestand der Nummernform bleibt grün (Unit-Tests von `internal/archive` über `make test`).

Lerneintrag: die Form entscheidet die Closure.

## 6. Risiken und offene Punkte

- **(1) Ein Report trägt die Kennung nicht im Namen** und bleibt auch nach dem Nachzug unzugeordnet — **Ausgang:** weiter offen → [`BEO-ALL/zuordnung-haengt-an-der-lage-statt-am-inhalt`](../observations/BEO-ALL/zuordnung-haengt-an-der-lage-statt-am-inhalt/observation.md) (bewusster Bestand nach §1; Zuordnung am Namen statt am Inhalt).
- **(2) Ein benannter Slice ist Präfix eines anderen** und zieht dessen Reports mit — gemessen kein Fall im Bestand (Namensliste `ls docs/plan/planning/{open,next,in-progress,done}/slice-*.md | sed 's#.*/##;s/\.md$//' | sort -u`, jeder Name gegen jeden anderen mit `index(n[j],n[i])==1`); Gegenmittel ist die Wortgrenze aus DoD 1 — **Ausgang:** weiter offen → [`BEO-ALL/zuordnung-haengt-an-der-lage-statt-am-inhalt`](../observations/BEO-ALL/zuordnung-haengt-an-der-lage-statt-am-inhalt/observation.md) (gehalten durch „längster Lifecycle-Name gewinnt", solange der längere Slice als Datei im Lifecycle liegt; fehlt er, zieht der kürzere dessen Reports mit — Verifikation, Fixture).

## 7. Closure-Notiz

- **Was hat funktioniert:** `SliceNummer`, `ReviewTrifft`, `sliceStub`, `TitelVon` tragen die benannte Form; Fälle 583–585 binden (Review: LOW-1/INFO-1 behoben in `759ed949`; Verifikation: DoD 1–3 bestätigt; `docs/reviews/2026-10-08-archivierung-benannte-slices-review.md`, `-verifikation.md`). Reale Quelle: `archive-welle --vorschau altbestand` alt `Review-Reports (ohne Stub): 170`, neu `325`.
- **Was ging anders als geplant:** DoD 1 nannte das Mittel (Wortgrenze), das die Eigenschaft nicht hält — `slice-foo-r2` und `slice-foo-bar` sind hinter `slice-foo` gleich geformt. Umgesetzt ist zusätzlich „längste Lifecycle-Kennung gewinnt" (Plan §3, Review INFO-2); der Planner hat DoD 1 auf das Gemessene gezogen, Mittel und Grenze stehen dort. Die drei Grenz-Fälle von `TestTitelVonLaesstDenNummernRestStehen` hat der Verifier per Hand-Mutation rot gesehen; kein Fall in `test/mutations/` nennt den Test.
- **Steering-Loop-Eintrag:** benannte Lücke, kein Sensor: die Zuordnung Report → Slice hängt am Dateinamen und an der Lifecycle-Lage des längeren Namens; kein Sensor hält sie gegen den Inhalt. Träger ist die gelesene Vorschau vor dem schreibenden Altbestand-Lauf (`archive-welle --vorschau altbestand`).
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-archivierung-erkennt-benannte-slices.md` in `BEO-ALL/zuordnung-haengt-an-der-lage-statt-am-inhalt/` (§6 (1) und (2), ein Vorgang) und in `BEO-ALL/neuer-waechter-ohne-mutations-fall/` (Grenz-Fälle ohne Mutations-Fall) ergänzt.
- **Folge-Slices:** keine.
- **Risiken aus §6:** (1) weiter offen → Register · (2) weiter offen → Register.
- **Drei Paarungen:** dieses Repo fährt Wellen — die Welle-Closure von `welle-adopter-weg-im-ziel` prüft sie erneut; die Slice-Closure fährt sie nach dem `git mv` selbst (Zeile unten).
- **Paarungen geprüft am 2026-10-08** (Planner, nach dem `git mv`): Anker — kein `liegt in`-Feld in §7; Folge-Slice — keiner genannt; Register — `BEO-ALL/zuordnung-haengt-an-der-lage-statt-am-inhalt` (2 Belege) und `BEO-ALL/neuer-waechter-ohne-mutations-fall` (17 Belege) existieren und tragen den eigenen Beleg (`ls …/evidence/*.md | wc -l`). Grün.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (Kürzel `ALL`, Go-Quelle `internal/archive`); erfüllt das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` trifft die Lücke (Fundmenge am Wortmuster statt an der Eigenschaft gesucht); Zähler: `ls docs/plan/planning/observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/evidence/*.md | wc -l` (keine Erwartungswerte). Die Fundliste dieses Slice liest `internal/archive` ganz.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt.

