# Slice slice-beleglose-register-eintraege-bekommen-eine-lesart: Ein Register-Eintrag ohne Vorgang bekommt eine der zwei Lesarten

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Gegenstand ist eine **Norm-Entscheidung** über die Form des Registers
und seine zwei Leser — es gibt kein *Mehr*, das über die DoD unten hinaus beobachtbar wäre
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap, auch nicht beim Abschluss.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Ablage dieses Repos und die Paarung (c)
seiner Wellen-Closure. Was ein emittiertes Repo an einer solchen Ablage bekommt, entscheidet der
Slice, der die Tool-Ebene entscheidet — die zwei Ebenen tragen verschiedene Verträge.

**Bezug:**
[`MR-059`](../../../../harness/conventions.md#mr-059)
— **nicht** als Gegenstand, sondern als **Nachbar** derselben Fläche: dort steht, wie ein Befund
über die Werkzeug-Ebene geführt wird, hier eine Norm-Frage über die Register-Form.

[`AGENTS.md`](../../../../AGENTS.md) §3.10 (die Closure ist der Ort, an dem ein Zustandsfeld
seinen Ausgang bekommt),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (die Rolle, der eine Norm-Aussage gehört),
[ADR-0034](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 3 — die Kennung **ist** der Pfad `BEO-<KUERZEL>/<slug>`; Festlegung 4 ist der
Migrations-Commit und trägt die Beleg-Regel nicht),
das Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (die Beleg-Regel *ein Vorgang zählt einmal — und was keinen hat, zählt gar nicht*;
die maschinelle Hälfte der Paarung (c)) und die
[Register-README](../observations/README.md) (Absatz *Ein Vorgang zählt einmal*),
[ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
(**Accepted** — die Entscheidung der Lesart-Frage, die dieser Slice trug),
[ADR-0049](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) (Festlegung 2 — hat eine Klasse
keinen Zielort, schneidet der Lese-Schritt einen Träger; das ist der Schnitt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Paarung, die über einem Bestand rot steht, den die eigene Beleg-Regel verbietet, ist ein Gate
gegen einen Widerspruch und keine Deckung),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben dem Kommando, das sie liefert).

**Berührte Spec-Stellen:** `—` (der Slice berührt keine Spec-Stelle; Gegenstand ist die Form des
Beobachtungs-Registers dieses Repos).

**Verantwortlich:** Architect. Der Liefergegenstand ist eine **normative** Entscheidung — welche der
zwei Lesarten trägt und wogegen die Register-Paarung urteilt. Wem das **Schreiben** gehört, sagt
Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln (*„ADR-Änderung: Architect schreibt;
Reviewer prüft auf Konsistenz"*); [`AGENTS.md`](../../../../AGENTS.md) §3.8 bindet die Hard Rules
und den Adaptions-Block und trägt hier nicht — der Ausgang ist keiner von beiden. Dieselbe
Zuschnitt-Wahl tragen
[slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke](../done/slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.md)
und [slice-183](../done/slice-183-ausloeser-der-wellenlosen-archivierung.md).

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Für den Fall *ein Vorkommen ohne abgeschlossenen Vorgang* ist entschieden und
aufgeschrieben, welche der zwei Lesarten trägt — und die Register-Paarung (c) urteilt seither gegen
die entschiedene Form statt gegen einen Widerspruch.**

### Der Befund

Zwei Regeln derselben Ablage treffen sich an einem Eintrag:

- Die **Paarung (c)** verlangt, dass *jedes Verzeichnis ein nicht leeres `evidence/` hat* — die
  maschinelle Hälfte der Register-Paarung (Baseline-Regelwerk `modul-06-roadmap.md`
  §Das Beobachtungs-Register).
- Die **Beleg-Regel** verbietet für ein Vorkommen **ohne** abgeschlossenen Vorgang genau diese
  Datei: *„Ein Vorkommen ohne abgeschlossenen Vorgang bekommt keine Datei unter `evidence/` und
  bewegt den Zähler nicht; es gehört trotzdem in `observation.md` unter ‚Benannt, nicht gezählt'"*
  — im Wortlaut von
  [`observations/README.md`](../observations/README.md).

Ein Eintrag, der allein aus einem Gespräch, einer Freigabe oder einer Code-Lektüre entsteht, kann
die Paarung darum **nicht** bestehen, solange kein Vorgang ihn trifft. Der Fall ist eingetreten und
steht benannt:

```sh
ls docs/plan/planning/observations/BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung/evidence/*.md | wc -l
```

**Kein Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit dem nächsten Vorgang, der den Eintrag trifft.

### Was der Slice entscheidet, und was er dafür nicht anfassen muß

**Zwei Lesarten stehen zur Wahl, und welche trägt, entscheidet dieser Slice** — nicht der Plan:

- **(a) *Benannt, nicht gezählt* ist ein Abschnitt innerhalb eines belegten Eintrags** — dann ist
  ein belegloses Verzeichnis eine **Form-Schuld**, und die Paarung darf es melden.
- **(b) *Benannt, nicht gezählt* ist ein eigenständiger Eintrag** — dann braucht die Paarung eine
  **Ausnahme** für ihn, und die Ausnahme braucht eine Form, die sie von einem vergessenen Beleg
  unterscheidbar macht.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Sensor und keine Gate-Änderung.** Ein Modul, das die Register-Paarung fährt, ist der
  Liefergegenstand von
  [slice-register-ueber-der-schwelle-bekommt-seinen-waechter](../next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md)
  und hängt an der Regel, die hier erst entsteht. Rollen-Trennung: wer die Norm entscheidet, baut
  ihren Wächter nicht im selben Kontext. *Es wäre ein anderer Vorgang.*
- **Kein Nachzug des Bestands.** Welche beleglosen Verzeichnisse es heute gibt, ist eine Messung,
  kein Auftrag; die Entscheidung bindet die Form, die geschrieben wird. *Bestand bleibt bewusst
  stehen.*
- **Keine Änderung an der Verzeichnis-Form des Registers** (drei Dateien, ein Verzeichnis je
  Beobachtung). Sie ist in
  [ADR-0034](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
  entschieden und trägt die Zählregel strukturell. *Es wäre ein anderer Vorgang.*
- **Keine Berührung der Ausgangs-Regel.** Welchen **Ausgang** ein Eintrag ab 3× trägt, ist in
  [ADR-0049](../../adr/0049-ausgang-traegt-die-benannte-luecke.md) entschieden und von diesem
  Befund nicht betroffen — hier steht die **Beleg**-Frage, nicht die Ausgangs-Frage.
  *Schicht-Abgrenzung.*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste.

Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

**Ein Liefer-Punkt:**

- [ ] **Die Entscheidung steht, sie ist `Accepted`, und sie nennt ihre Gegenposition.** Eine
      Antwort auf die Frage *welche Lesart trägt*, mit der verworfenen Alternative in §Verglichene
      Alternativen und [ADR-0040](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
      als Beleg des Accept-Übergangs. Ist die Antwort (b), gehört die **Ausnahme-Form** mit in die
      Entscheidung: woran ein Leser und die Paarung einen *benannt, nicht gezählt*-Eintrag von
      einem vergessenen Beleg unterscheiden. *Ist die Antwort (b), ist das eine Ausnahme an einer
      Prüfung und damit nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 ADR-pflichtig — genau der
      Träger, den dieser Punkt verlangt.*
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: **das ist Liefer-Punkt (1)** — der Träger der Regel ist die Register-Regel selbst.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — **kein Zähler wird gesetzt**, er
      folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne**
      Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für
      Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/<NNNN>-….md` | neu | Liefer-Punkt (1) — die Entscheidung; Kennung und Titel vergibt der Architect |
| [`docs/plan/planning/observations/README.md`](../observations/README.md) | update | der Ort, an dem dieses Repo die Register-Regel führt; die Beleg-Regel und die Paarungs-Hälfte stehen dort |
| [docs/plan/adr/README.md](../../adr/README.md) | update | der ADR-Index folgt der neuen ADR ([`AGENTS.md`](../../../../AGENTS.md) §5) |

**Kein Test-Eintrag, und das ist kein Vergessen.** Der Liefergegenstand ist eine **Regel** für zwei
inferentielle Leser; die maschinelle Hälfte ist ausdrücklich der Folge-Slice
([slice-register-ueber-der-schwelle-bekommt-seinen-waechter](../next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md)
trägt den Sensor über der Schwelle, die Paarung (c) selbst hat weiterhin kein Modul). Ein Test
daneben hielte den Regeltext gegen eine zweite Fassung seiner selbst.

**Und keine Gate-Zusage.** Dieser Slice darf in keinem Satz behaupten, die Paarung sei bewacht: kein
Modul aus `modules:` der [`.d-check.yml`](../../../../.d-check.yml) liest das Register, und die
Paarung wird von Hand gefahren.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice** (WIP frei) und der Slice ist
priorisiert (`Verantwortlich:` gesetzt). Beobachtbar ohne Rückfrage:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'
```

**Der Trigger ist kein Ergebnis dieses Slice.**

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Entscheidung die Paarung **und**
  die Beleg-Regel **und** die Verzeichnis-Form zusammen neu zu schneiden verlangt — dann ist das ein
  eigener Gegenstand und dieser Schnitt falsch.
- `in-progress` → `open` (blockiert): wenn sich zeigt, dass die Frage nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.8 einer anderen schreibenden Rolle gehört als der hier
  benannten.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Die Entscheidung ist `Accepted` und nennt eine Gegenposition** — eine ADR ohne
   Re-Evaluierungs-Trigger ist nach Baseline-Regelwerk `modul-04-adrs.md` unvollständig; ist der
   Ausgang *keine* ADR, trägt §7 den Grund und den Träger, der die Frage stattdessen hält.
2. **Die Register-Regel trägt die Antwort an ihrem Ort** — die Datei, die die Beleg-Regel führt,
   nennt die entschiedene Lesart samt Herkunfts-Anker (`seit slice-<Kennung>`, Baseline-Regelwerk
   `grundlagen-traceability.md` §Herkunfts-Anker).

**Lerneintrag:** die Form entscheidet die Closure. Wurde mit diesem Slice eine Regel verkörpert,
trägt der Eintrag `liegt in <Zielort>` und den Herkunfts-Anker `seit slice-<Kennung>`; folgt sie aus
dem Wortlaut der Baseline, trägt der Zielort bereits seine ID und braucht keinen zweiten Anker.
Die **Auslöser-Beobachtung** ist
[`BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung`](../observations/BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung/observation.md)
— sie ist zu **zitieren**, nicht neu zu formulieren.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Die Ausnahme wird zur stillen Senkung.** Fällt die Antwort auf (b), nimmt die Paarung einen
  Fall aus ihrer Prüfung — das ist eine Lockerung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 und braucht die ADR (Liefer-Punkt (1) verlangt sie
  ausdrücklich). **Gegenmittel im Plan:** die Antwort (b) ist ausdrücklich ADR-pflichtig. —
  **Ausgang: entfallen.** Die Antwort ist (a), nicht (b):
  [ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  wählt *„die Baseline gilt wörtlich, ein Verzeichnis ohne Beleg ist ein Befund der Paarung"* und
  schafft keine Ausnahme (Festlegung 2 — *„kennt keine Ausnahme"*); die Ausnahme-Form ist dort die
  verworfene Alternative B. Damit nimmt die Paarung keinen Fall aus ihrer Prüfung, es liegt keine
  Lockerung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 vor, und ein Adaptions-Eintrag entsteht
  nicht (§Konsequenzen derselben ADR).
- **(2) Die Entscheidung fällt am Wortlaut statt am Bestand.** Beide Lesarten hängen daran, wie viele
  Einträge heute ohne Beleg stehen; wer die Menge nicht misst, entscheidet über einen Bestand, den er
  nicht gesehen hat. **Gegenmittel im Plan:** §1 nennt das Kommando. —
  **Ausgang: entfallen.**
  [ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  §Kontext misst den Bestand mit Kommandos, bevor sie entscheidet: die Verzeichnisse ohne Beleg (Kommando und Namen in §7) und, ob die
  Überschrift *„Benannt, nicht gezählt"* ein beleglos-Merkmal trägt (sie trennt nicht: die Mehrzahl der
  Verzeichnisse, die sie tragen, hat Belege). Die Entscheidung fiel am Bestand, nicht am Wortlaut allein.
- **(3) Der Sensor über der Schwelle wird vor dieser Entscheidung gebaut.** Dann prüft er eine Form,
  die niemand entschieden hat, und die Ausnahme für (b) fehlt in ihm. **Gegenmittel im Plan:**
  [slice-register-ueber-der-schwelle-bekommt-seinen-waechter](../next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md)
  führt in §1 *„Keine Entscheidung über den Ausgang selbst"* und startet erst danach. —
  **Ausgang: entfallen.** Die Entscheidung liegt vor
  ([ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md),
  `Accepted`), und der Sensor ist nicht gebaut: der Wächter-Slice liegt in `next/`, `in-progress/`
  trägt keinen Slice (`ls docs/plan/planning/in-progress/ | grep -c '^slice-'` → 0; keine Erwartung).
  Was der Wächter nach der Entscheidung prüft, bindet dieselbe ADR: Folgepflicht 2 (er zählt Dateien `evidence/*.md`) und
  Re-Evaluierungs-Trigger 2 (der Bestand wird durch Belege getilgt, nicht durch eine Ausnahmeliste im
  Wächter).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Gegenstand:** entfallen: die Lesart der Beleg-Regel ist durch
  [ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  entschieden (mit Gegenposition in den Alternativen B, C, D, F und dem Beleg des Accept-Übergangs;
  die Register-README trägt sie).
- **Liefer-Punkte:** Der Liefer-Punkt der DoD bleibt leer, denn geliefert hat dieser Slice nichts.
  Leer bleiben auch der Gate-Lauf, der Review-Report und das Doku-Update, weil alle drei an einer
  Lieferung dieses Slice hängen; die Entscheidung trägt ihren eigenen Review (die Konsistenz-Runde
  und die Kurzrunde, die die ADR als Accept-Beleg nennt), die Register-README ihren eigenen
  Doku-Commit.
- **Was hat funktioniert:** Der Slice hielt die Lesart-Frage als benannte Adresse: neun Dateien in
  `done/` nennen seine Kennung als Träger der Entscheidung
  (`git grep -l -E 'slice-beleglose-register-eintraege-bekommen-eine-lesar[t]' -- docs/plan/planning/done | wc -l`
  → 9, keine Erwartung), und die Frage wurde nirgends stillschweigend mitentschieden. Die ADR nennt
  ihre Gegenposition, misst den Bestand mit Kommando und benennt, was sie nicht entscheidet.
- **Was ging anders als geplant:** Nicht dieser Slice hat die Entscheidung getragen, sondern ein
  Sammelauftrag an den Architect (Verdikt `2026-09-26-architect-verdikt-sammelauftrag-register-und-adr-0035`,
  Frage 4; Korrektur `2026-09-26-architect-verdikt-korrektur-adr-0035-0068-0069`, R-69-1). Der Slice
  durchlief `in-progress/` nicht, blieb in `open/` und verlor seinen Gegenstand. Die Anker-Regel des
  Slice-Kriteriums 2 (`seit slice-<Kennung>`) passt darum nicht: siehe nächster Punkt.
- **Steering-Loop-Eintrag (Form: geschärfte Regel).** Die Regel *„ein Verzeichnis ohne Beleg ist ein
  Befund der Paarung (c), keine Ausnahme; die zweite Hälfte von (c) gilt im Closure-Schritt über das
  ganze Register und nennt jedes beleglose Verzeichnis namentlich"* steht in
  [ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegungen 1 bis 4 und in der [Register-README](../observations/README.md) (die Absätze
  *Ein Verzeichnis ohne Beleg ist ein Befund der Register-Paarung (c)* und *Die zweite Hälfte von (c)*).
  **Das Feld `liegt in` ist nicht gesetzt**, weil der Zielort eine ADR ist: was aus einer ADR folgt, trägt
  deren Kennung als Herkunft und keinen Anker `seit slice-<Kennung>` (Baseline-Regelwerk
  `grundlagen-traceability.md` §Herkunfts-Anker, Geltungsbereich). Die Anker-Paarung (a) hat für diesen
  Eintrag darum keinen Gegenstand und wird hier **nicht** als getragen behauptet. Das Kriterium 2 aus §5
  ist in seinem ersten Teil erfüllt (die Datei, die die Beleg-Regel führt, nennt die Lesart), in seinem
  zweiten nicht in der geforderten Form (ein Anker `seit slice-<Kennung>` steht dort nicht, und für eine
  Regel aus einer ADR ist er die falsche Herkunft). Auslöser ist
  [`BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung`](../observations/BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung/observation.md)
  (`ls docs/plan/planning/observations/BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung/evidence/*.md | wc -l`
  → 3, keine Erwartung; Stand `verkörpert`). **Grenze:** ein Wächter existiert nicht — kein Modul der
  Doku-Gate-Konfiguration hält die zweite Hälfte von (c); Träger ist der Lauf, der die Paarung fährt.
- **Beobachtungs-Register:** keine Beobachtung angefallen. Dieser Abschluss trifft die Klasse nicht: er
  verwaltet die Beobachtung nur, und ein Vorgang, der das tut, ist nach Festlegung 3 der ADR kein
  Auftreten und legt keine Datei unter `evidence/` an. Kein Zähler wird gesetzt. Kein Register-Eintrag
  nennt diesen Slice als Träger mehr
  (`grep -rl 'slice-beleglose-register-eintraege-bekommen-eine-lesart' docs/plan/planning/observations | wc -l`
  → 0, keine Erwartung); der Ausgang der Auslöser-Beobachtung steht in deren `state.md`.
- **Folge-Slices:** keiner. Der Wächter-Slice
  [slice-register-ueber-der-schwelle-bekommt-seinen-waechter](../next/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md)
  ist ein Nachbar, kein Folge-Slice dieses Abschlusses; seine Zustandssätze zur ADR sind auf
  `Accepted` und `verkörpert` gezogen, DoD und Liefer-Punkte sind unberührt.
- **Risiken aus §6:** drei, je ein Ausgang — alle *entfallen* mit Begründung (§6): (1) die Antwort ist (a),
  eine Ausnahme entsteht nicht; (2) die Entscheidung misst den Bestand mit Kommando; (3) die
  Entscheidung liegt vor, der Sensor ist nicht gebaut. Keines ist *eingetreten*, keines *weiter offen*.
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** die Kennung dieses Slice steht in
  der ADR und in den Verdikten nicht als Pfad (`git grep -n 'slice-beleglose-register-eintraege-bekommen-eine-lesar[t]' -- docs/plan/adr | wc -l`
  → 0; in `docs/reviews/` nennt sie ein Verdikt als Kennung im Code-Span, ohne Pfad). **Ein eingefrorenes
  Artefakt nennt sie als Pfad:** die Ergebnis-Notiz `welle-emittierte-werkzeuge-results.md` in `done/`
  trägt zwei Markdown-Links mit dem Ziel in `open/`
  (`git grep -c -E 'open/slice-beleglose-register-eintraege-bekommen-eine-lesar[t]' -- docs` → 2 in dieser
  einen Datei; keine Erwartung). **Entscheidung vor dem Move:** der Nachzug des Werkzeugs zieht diese
  zwei Links mit, weil `done/**` nicht zu seinen Ausnahmen gehört und die Links von `docs-check`
  geprüft werden (`harness/sensors/slice-mv.md` §Grenze); ein Rückbau ließe zwei tote Links und ein
  rotes Doku-Gate. Die Frage dahinter — eine Ergebnis-Notiz nennt einen Träger, den der Prozess
  bewegt, als Pfad — ist benannt und an den Architect gemeldet, hier nicht entschieden.
- **Drei Paarungen** (nach dem Move gegen `done/` von Hand geprüft, 2026-09-26; ein Wächter dafür
  existiert nicht): **(a) Anker** — §7 trägt kein Feld `liegt in <Zielort>` (der Zielort ist eine ADR, siehe
  Steering-Loop-Eintrag); die Paarung hat für diesen Slice keinen Gegenstand und ist **nicht** als getragen
  behauptet. **(b) Folge-Slice** — keiner genannt; der Nachbar
  `slice-register-ueber-der-schwelle-bekommt-seinen-waechter` besteht als Datei im Planning-Lifecycle
  (`ls docs/plan/planning/*/slice-register-ueber-der-schwelle-bekommt-seinen-waechter.md`, Treffer in
  `next/`). **(c) Register, erste Hälfte** — die in §7 genannte Beobachtung
  `BEO-ALL/unbelegter-register-eintrag-faellt-durch-die-paarung` existiert als Verzeichnis und trägt ein
  nicht leeres `evidence/` (Kommando in §7 → 3). **(c) Register, zweite Hälfte: 4 Verzeichnisse ohne
  Beleg, namentlich `ci-rennt-gegen-die-publikation-des-gepinnten-releases`,
  `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet**
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`;
  das Register führt 180 Verzeichnisse, `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`;
  keine Erwartungswerte). Nennen ist keine Tilgung: der Befund endet mit dem Beleg eines abgeschlossenen
  Vorgangs, und die Stilllegung dieses Slice ist keiner. Die DoD-Zeile *„Die drei Paarungen … sind
  getragen"* bleibt darum **ungehakt**: wahr ist sie für (b) und die erste Hälfte von (c), nicht für
  (a) und nicht für die zweite Hälfte von (c).
- **Was der Move berührte:** neben der Datei selbst allein die zwei Links in der Ergebnis-Notiz
  `welle-emittierte-werkzeuge-results.md` (`git diff --name-status 857ee1f3..7b4d54f5` nennt den Rename dieser
  Datei und diese eine Ergebnis-Notiz; die Zeilen tauschen `../open/` gegen `../done/` im Link-Ziel).
  Keine ADR und kein Report unter `docs/reviews/` wurde berührt.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien**, vier und nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan. Bedingt ist allein der Modus-Begründungsblock am Ende; deshalb nennt der
Titel beide Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist **eine** Sub-Area: `*` (gesamtes Repo),
Kürzel `ALL`. Sie erfüllt das Inklusionskriterium (drei Achsen, Schwelle ≥ 2): die Register-Ablage
liegt repo-weit, ihre Regel steht in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area), und
ihre Leser sind die Rollen dieses Repos.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; **der Gegenstand
dieses Slice ist selbst ein Eintrag über der Schwelle** und trägt einen Ausgang
(`verkörpert`, Zielort
[ADR-0069](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)).
Drei Nachbarn derselben Fläche, gemessen
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2):

```sh
for s in register-paarung-ohne-gate-modul registerzeile-ohne-traeger-spalte unbelegter-register-eintrag-faellt-durch-die-paarung; do
  printf '%-52s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
done
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Keiner der drei erreicht
**mit** diesem Slice erstmals 3×, und keiner wird von ihm entschieden: `register-paarung-ohne-gate-modul`
zählt, dass die Paarung kein Modul hat (der Sensor-Slice, nicht dieser), `registerzeile-ohne-traeger-spalte`
eine fehlende Spalte in der Register-Form (Verzeichnis-Form, ausgeschlossen), und der dritte **ist**
dieser Slice.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit. `*` steht in der
Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
