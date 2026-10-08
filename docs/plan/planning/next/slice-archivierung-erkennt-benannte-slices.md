# Slice slice-archivierung-erkennt-benannte-slices: Die Archivierung erkennt benannte Slices

**Kennung:** benannt nach [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) Setzung 1.

**Lifecycle:** Der Zustand ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** [welle-adopter-weg-im-ziel](../welle-adopter-weg-im-ziel.md) — Closure verlangt `make gates` und `make full-smoke` grün auf demselben Commit, das *Mehr* über diese DoD.

**Bezug:** [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1 und 3 (Erkennung trägt die zugelassenen Formen), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`AGENTS.md`](../../../../AGENTS.md) §3.6, [ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Altbestand), [ADR-0077](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md) (Slice-Closure-Archiv). Herkunft: Fund der Verifikation von `slice-kennungs-erkennung-traegt-die-zugelassenen-formen`, dort §7 Fundliste.

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** `internal/archive` liest die Kennung eines benannten Slice (`slice-<Kennung>`) wie die einer Nummer — Review-Reports werden eingesammelt, der Stub trägt seine Kennung und seinen Titel.

Der Fund (Lesung, nicht Grep): `SliceNummer` (`internal/archive/collect.go:101`, `^slice-([0-9]+[A-Za-z]*)`) liefert für einen benannten Slice `""`; `Reviews()` überspringt ihn (`nr == ""`), `sliceStub` setzt `<Kennung>` leer (`anwenden.go:269`), `kennungRE` (`stub.go:149`, `slice-[0-9]+…`) streift die Kennung nicht vom Titel. Das Review-Grep des Vorgänger-Slice fand es nicht, weil sein Muster `slice-\[0-9\]` die Zeile mit `([0-9]+` nicht trifft.

**Betroffen ist der Altbestand.** `archive-welle altbestand` ([ADR-0041](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) Festlegung 1) sammelt jeden flach in `done/` liegenden wellenlosen Slice: 80 benannte (`for f in docs/plan/planning/done/slice-[a-z]*.md; do grep -q '^\*\*Welle:\*\* ohne Welle' "$f" && echo "$f"; done | wc -l`; keine Erwartungswerte) neben den Nummern-Slices; weitere 7 benannte sind Welle-Mitglieder (dieselbe Schleife mit `||`). Ohne diesen Slice archiviert der Lauf ihre Reports **nicht** und schreibt Stubs ohne Kennung. **Dieser Slice ist Start-Bedingung des realen Altbestand-Laufs** und jeder Slice-Closure-Archivierung eines benannten Slice ([ADR-0077](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md)); die Vorschau (`archive-welle --vorschau`) darf vorher gelesen werden, der schreibende Lauf wartet.

**Ausdrücklich NICHT in diesem Slice:**

- **Der reale Altbestand-Lauf.** Anderer Vorgang (Werkzeug-Nutzung, Verweis-Nachzug in 80 Dateien); er braucht diesen Slice, liefert ihn nicht.
- **Die Zuordnung eines Reports zu seinem Slice jenseits des Dateinamens.** Die Reports tragen die Kennung im Namen (`ls docs/reviews | grep -c 'slice-[a-z]'` → 179 von `ls docs/reviews | wc -l`); wo ein Report sie nicht trägt (der Review des Vorgängers heißt `…-dogfood-hook-benannte-slices-review.md`), bleibt er unzugeordnet — Bestand, bewusst: ein Inhalts-Lesen wäre ein anderer Vorgang mit eigener Fehlerklasse.
- **Die Anker-Präfix-Form** (`slice-ADR-…`, Großbuchstaben): in `stub.go:239` als Grenze benannt, noch nicht vergeben.
- **Die emittierte Ebene.** Das Unterkommando ist Produkt-Code; was Zielrepos bekommen, ändert sich nur über denselben Code — ein Zielrepo-Beleg ist nicht Gegenstand, die Schicht-Abgrenzung hält den Slice in `internal/archive`.

## 2. Definition of Done

- [ ] **(1) `SliceNummer` und `ReviewTrifft` tragen die benannte Form.** Ein benannter Slice liefert seine Kennung; `ReviewTrifft` trifft die Reports mit voller Kennung und **nicht** die eines Slice, dessen Name sie als Präfix trägt (Wortgrenze wie bei der Nummer). Die Nummernform des Bestands bleibt unverändert (`001`, `001a`).
- [ ] **(2) Stub und Titel tragen die Kennung.** `sliceStub` setzt `<Kennung>` für benannte Slices, `TitelVon` streift `slice-<Kennung>` samt Trenner vom Titel.
- [ ] **(3) Der Fall ist rot gesehen.** Test über benannte Slices (Reviews, Stub-Kennung, Titel) färbt rot gegen den Vorzustand und bleibt für die Nummernform grün; ein Mutations-Fall bindet `SliceNummer`. `archive-welle --vorschau altbestand` nennt danach die Reports der benannten Slices (gelesene Ausgabe).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor.
- [ ] Doku-Update: [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md), falls es die Nummernform als Bedingung führt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben (kein Zähler wird gesetzt); keine Beobachtung angefallen ist ebenfalls eine Antwort.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang.
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/collect.go` | update | `SliceNummer` und `ReviewTrifft`: benannte Form (DoD 1) |
| `internal/archive/stub.go`, `anwenden.go` | update | Titel und `<Kennung>` des Stubs (DoD 2) |
| `internal/archive/*_test.go`, `test/mutations/` | update/neu | Fall je Form, rot gesehen (DoD 3, [`AGENTS.md`](../../../../AGENTS.md) §3.6) |

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

- **(1) Ein Report trägt die Kennung nicht im Namen** und bleibt auch nach dem Nachzug unzugeordnet — **Ausgang:** <…>
- **(2) Ein benannter Slice ist Präfix eines anderen** und zieht dessen Reports mit — gemessen kein Fall im Bestand (Namensliste `ls docs/plan/planning/{open,next,in-progress,done}/slice-*.md | sed 's#.*/##;s/\.md$//' | sort -u`, jeder Name gegen jeden anderen mit `index(n[j],n[i])==1`); Gegenmittel ist die Wortgrenze aus DoD 1 — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang>
- **Drei Paarungen:** <…>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (Kürzel `ALL`, Go-Quelle `internal/archive`); erfüllt das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge` trifft die Lücke (Fundmenge am Wortmuster statt an der Eigenschaft gesucht); Zähler: `ls docs/plan/planning/observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/evidence/*.md | wc -l` (keine Erwartungswerte). Die Fundliste dieses Slice liest `internal/archive` ganz.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt.

