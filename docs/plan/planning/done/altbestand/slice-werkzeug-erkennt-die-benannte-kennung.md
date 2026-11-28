# Slice slice-werkzeug-erkennt-die-benannte-kennung: Verweis-Nachzug und Archiv-Stub erkennen eine benannte Slice-Kennung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Kennung:** Dieser Slice trägt die erste nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 vergebene **benannte** Kennung dieses Repos — ein freier Slug in lowercase-Kebab-Case,
ohne Nummer. Das ist keine Nebenbemerkung, sondern der Gegenstand: Er ist zugleich der erste Fall,
auf den die Grenze unten zutrifft.

**Welle:** ohne Welle. Sein Closure-Trigger würde die eigene DoD abschreiben; eine
Closure-Bedingung, die mehr beobachtet als die DoD-Punkte unten, gibt es nicht
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Nach
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)
steht wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind das Harness-Werkzeug und der Produkt-Code
**dieses** Repos. Die emittierte Ebene trägt dasselbe Muster als Vorlage und bleibt unberührt
(§1).

**Bezug:**
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (der Träger, dessen
Stub-Erzeugung die Kennung liest — Festlegung 3 bindet die Stub-Form an die vendored Vorlagen),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (die geltende Regel des
Verweis-Nachzugs; dieser Slice ändert **keine** ihrer fünf Festlegungen und keine Ausnahmeliste),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Werkzeug, das für eine Kennungsklasse stumm durchläuft, meldet Erfolg über einer Menge, die es
nicht gesehen hat),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
(die Deklaration, deren Abschnitt *Grenze* diese Arbeit benennt und ausdrücklich **nicht**
schließt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand sind ein
Harness-Werkzeug und eine interne Go-Funktion).

**Verantwortlich:** Implementer-Rolleninhaber dieses Laufs.

**Autor:** Planner. **Datum:** 2026-09-13.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein Slice mit **benannter** Kennung durchläuft den Lifecycle und die Archivierung, ohne
dass eine Ziffern-Bindung ihn übersieht — **genau zwei Stellen** tragen sie heute, und dieser
Slice nimmt beide:

| Stelle | heutige Bindung | was sie dadurch nicht sieht |
|---|---|---|
| [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh), `rewrite_outgoing_bare_in_file()` | ein `grep -ohE`-Muster, dessen Kennungs-Teil `slice-[0-9]` lautet | die **ausgehenden**, präfixlosen Geschwister-Ziele *innerhalb* einer bewegten Datei, wenn das Ziel einen Namen statt einer Nummer trägt |
| [`internal/archive/stub.go`](../../../../internal/archive/stub.go), `Hervorgegangen()` | `sliceRE`, ein `regexp.MustCompile` über `slice-[0-9]{3}` | eine benannte Folge-Slice-Kennung in der Closure-Notiz; der Archiv-Stub übernimmt sie nicht |

```sh
git grep -nE 'slice-\[0-9\]' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Menge wandert mit dem Code.

**Dieser Slice nimmt die Sendung an.** Er ist die Adresse für die Grenze, die
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
als *„benannt, nicht geschlossen"* führt und deren Nachzug jener Eintrag ausdrücklich der
Implementer-Rolle und keinem Adaptions-Eintrag zuweist. Zwei Slices, die dieselben Dateien
berühren, nehmen sie **nicht** an und werden hier ausgeschlossen statt stillschweigend
vorausgesetzt (unten, Klasse *anderer Vorgang*).

### Der Umfang der Grenze ist gemessen und kleiner, als ihr Wortlaut nahelegt

[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
sagt, `make slice-mv` finde *„die Verweise auf einen benannten Slice nicht"*. Das trifft **eine**
der beiden Richtungen des Werkzeugs. Die **eingehende** Ersetzung ankert nicht an einer Ziffer,
sondern am Verzeichnis-Literal an einer Wortgrenze, und die **Quellen-Auflösung** in `main()` ist
ein Glob über den Lifecycle-Verzeichnissen:

```sh
sed -n '150,154p' harness/tools/slice-mv.sh    # rewrite_incoming_in_file: "$from/$esc_base", keine Ziffer
sed -n '197,200p' harness/tools/slice-mv.sh    # main(): "$PLANNING/$d/${SLICE%.md}"*.md, keine Ziffer
```

Ein benannter Slice lässt sich also **bewegen**, und die eingehenden Verweise auf ihn werden
nachgezogen; was ausfällt, ist die **ausgehende** Richtung und der Stub. Diese Präzisierung ist
Arbeit dieses Slice und gehört in seine Closure-Notiz: Eine Grenze, die breiter beschrieben ist,
als sie misst, lädt dazu ein, die Fähigkeit daneben ebenfalls für abwesend zu halten.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Keine Änderung an [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  und an keinem anderen angenommenen Adaptions-Eintrag.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.8,
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  und [`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)
  sperren das, und der Adaptions-Block gehört dem Architect. Ergibt die Messung oben, dass die
  Grenzen-Formulierung jenes Eintrags zu breit steht, ist das ein **Übergabe-Artefakt** an den
  Architect und kein Nachzug in diesem Diff. *Es wäre ein anderer Vorgang.*
- **Keine Umbenennung bestehender `slice-<NNN>`/`welle-<NN>`-Kennungen.**
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  Setzung 2 setzt den Cutoff und schließt einen Nachrüst-Auftrag aus; der Bestand steht in
  Commit-Messages, in Beleg-Dateien des Beobachtungs-Registers und in `Accepted`-ADRs, für die es
  keine Antwort gäbe ([`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.11). *Bestand bleibt bewusst
  stehen.*
- **Keine Änderung an der emittierten Ebene.** Dasselbe Ziffern-Muster steht als Vorlage unter
  `internal/emit/` (`git grep -lE 'slice-(\[0-9\]|\\d)' -- internal/emit | wc -l`), und wer es
  bewegt, ändert einen Vertrag gegenüber Zielrepos. Was ein Zielrepo an Kennungs-Form bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet. *Schicht-Abgrenzung* — beim Review sofort
  prüfbar am Pathspec des Diffs.
- **Keine Änderung an der `BEO-`-Kennungs-Erkennung im Stub.** `beoRE` in derselben Datei bindet
  `BEO-[0-9]{3}` und ist die abgeschaffte Register-Kennungsform; sie übernimmt
  [slice-188](../done/slice-188-archiv-stub-kennt-die-register-verzeichnis-form.md). Dieser Slice
  fasst **nur** `sliceRE` an, damit beide Diffs disjunkt bleiben. *Folge-Slice übernimmt es* —
  und `slice-188` nimmt die Sendung an, weil sein Gegenstand genau diese Kennungsklasse ist.
- **Keine Erweiterung der Ausnahmeliste des Verweis-Nachzugs.**
  [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 sagt
  *„keiner bekommt einen weiteren ausgenommenen Baum"*; eine dritte Adresse wäre eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 mit eigener Entscheidung. *Bestand bleibt bewusst
  stehen.*
- **Kein Wächter über die Kennungs-Form selbst.**
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  stellt fest, dass kein Modul der [`.d-check.yml`](../../../../.d-check.yml) eine Slice-Kennung
  führt und ein Verstoß gegen Setzung 1 nichts rot färbt. Dieser Slice macht das Werkzeug
  **tolerant**, er macht die Form nicht **erzwungen**; ein solcher Sensor wäre eine
  Gate-Erweiterung mit eigener Erprobung. *Es wäre ein anderer Vorgang.*
- **Keine Erkennung der zweiten Namensform aus
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  Setzung 1** — das Präfix eines vorhandenen Ankers (`LH-*`, `ADR-*`, `CO-*`); die Anker dieses
  Repos sind großgeschrieben (`.d-check.yml` `ids`-Muster `ADR-\d{4}`, `LH-[A-Z]{2}-\d{2}`,
  `MR-\d{3}`), und beide Fundmuster dieses Slice binden auf `[a-z0-9]`. Eine Erkennung dieser Form
  müsste die Anker-Präfixe selbst kennen — sonst träfe sie beliebigen großgeschriebenen
  Fließtext —, das ist ein Muster-Entwurf für sich und größer als die drei Liefer-Punkte in §2.
  Die Lücke steht als vierte Grenze in `harness/tools/slice-mv.sh` §GRENZEN, in
  [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) und am Funktionskopf
  von `sliceRE` in `internal/archive/stub.go`. *Es wäre ein anderer Vorgang.*

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei slice-eigene Punkte.

- [x] **1 — `rewrite_outgoing_bare_in_file()` sieht die benannte Kennung.** Das Muster in
      [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh) trifft ein
      präfixloses `](slice-<name>.md)` ebenso wie `](slice-<NNN>-….md)`, ohne die Teilstring-Falle
      aufzureißen, die `test/slice-mv.bats` heute deckt (`slice-13` steckt in `slice-130`). **Rot
      gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein bats-Fall, der über dem heutigen
      Muster fällt und über dem neuen grün wird — die Zusage ist erst fertig, wenn benannt ist,
      was passieren müsste, damit sie bricht.
- [x] **2 — `Hervorgegangen()` übernimmt die benannte Kennung in den Archiv-Stub.** `sliceRE` in
      [`internal/archive/stub.go`](../../../../internal/archive/stub.go) trifft sie, der Stub baut
      ihren Anker-Link wie für eine nummerierte (`TestHervorgegangenBautAnkerLinks` bleibt grün),
      und ein Go-Test deckt den benannten Fall. **Rot gesehen** wie oben.
- [x] **3 — Je ein Fall in [`test/mutations/`](../../../../test/mutations/).** Beide Wächter aus
      Punkt 1 und 2 haben einen kuratierten *(Mutation → erwartet rot färbender Test)*-Fall, und
      `make mutate` meldet für keinen von beiden einen BEFUND. Ohne ihn ist der neue Wächter
      **ungelistet** und damit unbewacht — Register-Stand der Klasse
      `neuer-waechter-ohne-mutations-fall`: **5×**
      (`ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/*.md | wc -l`,
      kein Erwartungswert).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: der Skriptkopf von
      [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh) §GRENZEN und die Zeile
      zu [`make slice-mv`](../../../../harness/sensors/slice-mv.md) in
      [`harness/README.md`](../../../../harness/README.md) sagen, was das Werkzeug nach diesem
      Slice trägt — ein öffentlicher Vertrag im Sinne des Minimal Agent Workflow.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh) | update | `rewrite_outgoing_bare_in_file()` — Muster und Skriptkopf §GRENZEN |
| [`internal/archive/stub.go`](../../../../internal/archive/stub.go) | update | `sliceRE` in `Hervorgegangen()`; `beoRE` bleibt unberührt (§1) |
| [`test/slice-mv.bats`](../../../../test/slice-mv.bats) | update | Happy (benannt) · Boundary (Teilstring `slice-13`/`slice-130`) · Negative (kein `slice-`-Ziel) — nach DoD-Punkt 1 |
| `internal/archive/stub_test.go` | update | Happy (benannte Folge-Slice-Kennung) · Boundary (gemischte Liste benannt + nummeriert) — nach DoD-Punkt 2 |
| [`test/mutations/`](../../../../test/mutations/) | neu | je ein Fall pro Wächter — nach DoD-Punkt 3 |
| [`harness/README.md`](../../../../harness/README.md), [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) | update | der Vertrag des Werkzeugs sagt, was es nach diesem Slice sieht |

**Was hier bewusst fehlt:** eine Zeile für `internal/emit/` und für
[`harness/conventions/`](../../../../harness/conventions/) — beide sind in §1 mit Begründung
ausgeschlossen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Die Arbeit ist **fällig, seit die erste benannte Kennung
vergeben ist** — und das ist die dieses Slice selbst. Beobachtbar ohne Rückfrage:

```sh
ls docs/plan/planning/*/slice-[a-z]*.md | wc -l   # > 0 heisst: eine benannte Kennung ist im Lifecycle
```

**Kein Erwartungswert**, und **kein Ergebnis dieses Slice** im Sinne der Trigger-Disziplin: Die
Zahl steht in keiner DoD-Zeile von §2, und sie war schon > 0, bevor dieser Slice begann — die
Datei, die du liest, hat sie dorthin gebracht. Dass ein Slice seine eigene Fälligkeit belegt, ist
hier kein Zirkel, sondern der Befund: Der Nachzug war **vor** der ersten benannten Kennung fällig
und ist es nicht geworden.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Wenn die Muster-Änderung in
  `internal/archive/stub.go` weitere Aufrufer sichtbar macht, die dieselbe Kennung lesen — dann
  wird der Go-Teil ein eigener Slice und dieser behält das Skript. Konkrete Schwelle: mehr als die
  eine Funktion `Hervorgegangen()` im Diff.
- `in-progress` → `open` (blockiert — Carveout?): Wenn ein toleranteres Muster einen bestehenden
  Wächter rot färbt, dessen rote Stelle außerhalb dieses Slice liegt — etwa die Teilstring-Fälle in
  [`test/slice-mv.bats`](../../../../test/slice-mv.bats) oder ein Mutations-Fall, der über das
  gelockerte Muster nicht mehr rot wird. Eine Lockerung, die einen vorhandenen Zahn entwaffnet,
  ist keine Lösung, sondern die Klasse
  `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` (Register-Stand **3×**,
  `ls docs/plan/planning/observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/evidence/*.md | wc -l`).

**Ausgang der ersten Rückführung — sie hat gefeuert, gezogen wird sie nicht.** Beide Hälften der
Bedingung treffen zu: `SlicePfadRelativ()` ist ein zweiter Leser derselben Kennung, sichtbar
geworden durch die Muster-Änderung, und der Diff trägt drei Funktionen neben `Hervorgegangen()`:

```sh
git diff 6c3ea3a9^..004335cc -- internal/archive/stub.go \
  | grep -oE '^[+-]func [A-Za-z]+' | sed 's/^[+-]//' | sort -u | wc -l   # 3
```

Die Schwelle misst aber nicht die Eigenschaft, die sie bewacht. *Zu groß* ist im
Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice über drei Kriterien
bestimmt — mehr als drei Liefer-Punkte, mehr als zwei berührte Schichten, nicht in einer
Review-Sitzung prüfbar —, und keines davon zählt Funktionen in einem Diff. Alle drei sind
eingehalten: drei Liefer-Punkte (§2), zwei Schichten (§8), je eine Review-Sitzung pro Runde. Die
drei Funktionen sind **ein** Leser (`SlicePfadRelativ`) und zwei aus ihm herausgezogene Hilfen;
der Umfang des Slice ist durch sie nicht gewachsen, und ein Schnitt entlang Skript gegen Go wäre
ein Schicht-Schnitt, den dieselbe Sektion untersagt.

Der Wortlaut der Bedingung bleibt oben stehen — er ist der Maßstab, an dem diese Entscheidung
prüfbar ist. Was aus der falschen Schwelle folgt, steht als Beobachtung im Register (§7).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `git grep -nE 'slice-\[0-9\]' -- harness/tools internal cmd
Makefile d-check.mk ':!internal/emit'` liefert keine Zeile mehr, `make gates` und `make mutate`
sind grün. (2) Der Review-Report zu diesem Slice liegt unter `docs/reviews/` und trägt keinen
blockierenden Befund. Dazu der Lerneintrag in §7 und für jedes Risiko aus §6 ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein toleranteres Muster trifft mehr, als es soll.** `slice-[0-9]` ist eng, `slice-[a-z0-9-]`
  ist es nicht: Ein präfixloses `](slice-mv.sh)` oder ein Fließtext-`slice-mv` fiele darunter. Die
  Boundary-Fälle in §3 sind die vorab benannte Antwort. — **Ausgang: entfallen.** Die gefürchtete
  Folge — ein Verweis wird falsch umgehängt, ein Stub trägt einen toten Link — kann in keinem der
  beiden Träger eintreten, weil keiner am **Muster** entscheidet, sondern an der **Existenz eines
  Ziels**: `rewrite_outgoing_bare_in_file()` hängt nur um, wenn die Datei im Herkunfts-Verzeichnis
  liegt (`sed -n '177p' harness/tools/slice-mv.sh` → `[ -f "$PLANNING/$from/$t" ] || continue`),
  und `Hervorgegangen()` schreibt einen **baren** Token statt eines Links, sobald
  `SlicePfadRelativ()` leer liefert — dieser Zweig ist älter als der Slice
  (`git show 6c3ea3a9^:internal/archive/stub.go | grep -c 'teile = append(teile, id)'` → 1). Die
  Weitung ändert, welche Tokens an dieses Tor kommen, nicht, was es durchlässt. Was bleibt — ein
  Fließtext-Token ist von einer echten Kennung ohne auflösbare Datei nicht zu unterscheiden —
  steht als gemessene Grenze am Kopf von `Hervorgegangen()` und ist keine Folge der Weitung.
- **Der Lifecycle-Move dieses Slice bewegt Adressen, die anderswo bewacht sind.** Register-Stand
  der Klasse `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: **14×**
  (`ls docs/plan/planning/observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/evidence/*.md | wc -l`)
  — der größte Zähler des Registers, und dieser Slice ist der erste, dessen eigene Kennung das
  Werkzeug in der ausgehenden Richtung nicht sieht. — **Ausgang: weiter offen → Beobachtungs-Register**
  ([`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)).
  Eingetreten ist es: Der Zustandssatz *In Arbeit:* der Roadmap nennt diesen Slice, und
  `make slice-mv` zieht nach eigener Zusage Pfade nach, keine Zustandssätze (Grenze 1 seines
  Skriptkopfs); der Verweis derselben Zeile ist präfixlos und fällt zusätzlich unter Grenze 3.
  Beides gleicht diese Closure von Hand aus, ein Träger dafür besteht weiterhin nicht.
- **Die Grenzen-Formulierung in
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  steht breiter, als die Messung in §1 trägt.** Sie zu berichtigen ist Architect-Arbeit und in §1
  ausgeschlossen; bleibt sie stehen, liest der nächste Lauf eine abwesende Fähigkeit, die es gibt.
  Das ist ein Übergabe-Artefakt, kein Diff-Posten. — **Ausgang: weiter offen → Beobachtungs-Register**
  ([`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md)).
  Die Übergabe ist ausgesprochen und ohne Träger: Für den Weg zum Architect nennt
  Baseline-Regelwerk `modul-08-agentenrollen.md` §Die neun Übergaben kein eigenes Artefakt, und
  einen Folge-Slice schneidet diese Closure nicht. Der Zähler trägt sie.
- **`make mutate` läuft lange.** Der Lauf über das kuratierte Set ist der teuerste Sensor dieses
  Repos; DoD-Punkt 3 hängt an ihm. — **Ausgang: entfallen.** DoD-Punkt 3 fragt, ob **diese** Fälle
  ihren `expect:`-Test rot färben, und das ist je Fall einzeln entscheidbar: 316, 317 und 318 sind
  einzeln angewandt und am genannten Wächter rot gesehen (Commit `004335cc`, nachgemessen in
  Review-Runde 2). Der Punkt hängt damit nicht am vollen Lauf. Der volle Lauf bleibt
  Closure-Kriterium (§5) und hat seinen Pro-Push-Auslöser in der CI
  ([`harness/README.md`](../../../../harness/README.md) §Safety and scope boundaries).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-13

- **Was hat funktioniert:** Die **erste Hälfte** der Rückführungs-Bedingung aus §4 — *weitere
  Leser derselben Kennung* — hat gearbeitet: Sie hat `SlicePfadRelativ()` sichtbar gemacht, und
  daraus wurde HIGH-1 der ersten Review-Runde. Ohne sie wäre der Slice mit einer Funktion grün
  geworden, die eine benannte Kennung an keiner ihrer vier Lagen auflöst. Der Schnitt selbst hat
  gehalten: drei Liefer-Punkte, zwei Schichten, je eine Review-Sitzung pro Runde. Und für jeden
  neuen Wächter steht ein kuratierter Mutations-Fall — die Klasse
  [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (**5×**, `ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/*.md | wc -l`)
  hat hier keinen Beleg bekommen.
- **Was ging anders als geplant:** §1 zählte **zwei** Stellen mit Ziffern-Bindung; es waren drei.
  `SlicePfadRelativ()` band die Kennungsform nicht über ein Muster, sondern über die **Dateiform**
  — jede Kennung musste einen Titel-Suffix tragen, eine benannte trägt keinen, die Funktion lieferte
  für sie `""`. Das Fundkommando in §1 konnte das nicht sehen: Es sucht die Zeichenfolge
  `slice-[0-9]`, und ein Glob `slice-<x>-*.md` enthält sie nicht. Ein Muster-Fundkommando findet
  Muster, keine Bindungen anderer Art — das ist die Grenze dieses Belegs, nicht sein Versagen.
  Daneben zwei Rollen-Befunde, die beide der Planner entschieden hat: die Rückführung aus §4 (der
  Ausgang steht dort) und ein vierter Out-of-Scope-Punkt, den der Implementations-Commit in §1
  schrieb. Der Planner nimmt die Grenze **an**: Sie nimmt nichts weg, was §2 zusagt — die zweite
  Namensform stand in keinem der drei Liefer-Punkte —, ihre Klassifikation (*es wäre ein anderer
  Vorgang*) trägt, und sie ist an vier Stellen gemessen. Gegenstand ist nicht ihr Inhalt, sondern
  die Rolle, die sie schrieb ([`AGENTS.md`](../../../../AGENTS.md) §3.10); der Beleg liegt im
  Register.
- **Steering-Loop-Eintrag:** *neuer Sensor.* Die Kennungs-Toleranz beider Träger ist ab jetzt
  bewacht, und zwar in beide Richtungen: `test/mutations/316-slice-mv-ausgehend-verliert-benannte-kennung.sh`
  (Skript), `317-stub-slicere-verliert-benannte-kennung.sh` (Stub) und
  `318-stub-slicere-alternativen-reihenfolge.sh` für die tragende Alternativen-Reihenfolge, die
  Go-`regexp` leftmost-first auflöst. Vorher sah **kein** Wächter dieses Repos eine benannte
  Kennung. Ein `liegt in`-Feld steht hier nicht: Verkörpert wird beim Lese-Schritt, und dieses
  Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`) — er gehört der Welle-Closure.
- **Beobachtungs-Register (`../observations/`):** sechs Belege, je einer je Klasse; ein Vorgang
  zählt je Klasse einmal. Der letzte entsteht **nach** dieser Notiz — er ist ein Befund des
  Lifecycle-Move, und der läuft erst, wenn die Notiz steht.

  | Beobachtung (`BEO-ALL/<slug>`) | was dieser Vorgang beisteuert |
  |---|---|
  | [`fremdes-rollen-artefakt-im-implementations-kontext`](../observations/BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext/observation.md) | der vierte Out-of-Scope-Punkt, geschrieben im Implementations-Commit |
  | [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md) | der Zustandssatz *In Arbeit:* der Roadmap, den kein Werkzeug nachzieht |
  | [`uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md) | drei Übergaben an andere Rollen ohne angelegtes Träger-Artefakt |
  | [`korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge`](../observations/BEO-ALL/korrektur-trifft-den-fundort-statt-die-gemessene-fundmenge/observation.md) | die `slice-NNN`-Notation, dreimal gezogen, an zwei weiteren Stellen stehen geblieben |
  | [`rueckfuehrungs-schwelle-misst-nicht-die-eigenschaft-die-sie-bewacht`](../observations/BEO-ALL/rueckfuehrungs-schwelle-misst-nicht-die-eigenschaft-die-sie-bewacht/observation.md) | **neu angelegt** — die Schwelle aus §4 zählte Funktionen in einem Diff statt der drei Größen-Kriterien |
  | [`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md) | drei Pfadangaben in den Review-Reports, darunter ein zitierter Messwert, vom Nachzug des Move ersetzt |

  ```sh
  ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l   # 101 nach dieser Closure
  ```

  **Kein Erwartungswert** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Übergaben an andere Rollen — drei, keine mit eigenem Träger-Artefakt.** (1) An den
  **Architect**: Die Grenzen-Formulierung in
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  steht breiter, als §1 misst — die **eingehende** Richtung und die Quellen-Auflösung des
  Werkzeugs arbeiten für eine benannte Kennung. (2) Dieselbe Notations-Aussage `SLICE=<slice-NNN>`
  steht unverändert in `Makefile:340` (die `make help`-Zeile) und in
  `harness/tools/slice-mv.sh:170`; beide sind in diesem Abschluss nicht berührt. (3) Ebenfalls in
  `harness/tools/slice-mv.sh`: Grenze 3 seines Skriptkopfs nennt `BEO-003` — eine Kennungsform,
  die das Register nicht mehr führt (`ls -d docs/plan/planning/observations/BEO-[0-9]* 2>/dev/null | wc -l`
  → 0).
- **Folge-Slices:** keine. Keiner der Ausgänge in §6 lautet *eingetreten*, und die drei Übergaben
  oben tragen der Zähler und das Register, nicht ein geschnittener Slice.
- **Risiken aus §6:** vier, jedes mit genau einem Ausgang — zweimal *entfallen* (mit Begründung),
  zweimal *weiter offen → Beobachtungs-Register*. Kein Risiko steht ohne Ausgang.
- **Gemessen, und was nicht:** `make gates` EXIT 0 auf `847c6566`; das Fundkommando aus §5 liefert
  keine Zeile (`git grep -nE 'slice-\[0-9\]' -- harness/tools internal cmd Makefile d-check.mk
  ':!internal/emit'`, EXIT 1); zwei Review-Reports unter `docs/reviews/`, der zweite ohne
  blockierenden Sach-Befund. **Nicht** in diesem Kontext gefahren: der volle `make mutate`-Lauf —
  gemessen sind die drei neuen Fälle einzeln, nicht das kuratierte Set als Ganzes.
- **Der Move dieses Slice ist die erste Probe am eigenen Werk** — die erste benannte Kennung, die
  den Lifecycle mit `make slice-mv` verlässt. Gemeldet: `eingehend: 3 Datei(en) mit Verweisen
  nachgezogen · ausgehend: 0`, zwei Commits, EXIT 0. Die **0** ist richtig und nicht stumm: Die
  bewegte Datei trägt kein präfixloses Geschwister-Ziel — ihr einziger Slice-Verweis nennt
  `../open/` mit Präfix. Der Inhalts-Commit ändert fünf Zeilen in drei Dateien
  (`git show --stat 25d739b3`): **zwei** tragen einen Link, der auflösen muss, **drei** eine
  Pfadangabe über einen vergangenen Aufenthalt (Register-Zeile oben). Der präfixlose Verweis der
  Roadmap bleibt unberührt — Grenze 3 des Skriptkopfs, gemessen statt vermutet.
- **Drei Paarungen:** Repo **mit** Wellen-Betrieb — geprüft von der nächsten Welle-Closure, auch
  für diesen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind **zwei** Sub-Areas, beide deklariert in
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area:
`harness/tools/` (Kürzel `TOOLS`) und `*` (gesamtes Repo, Kürzel `ALL`, für den Go-Anteil unter
`internal/`). `TOOLS` erfüllt die Schwelle ≥ 2 von 3 Achsen: eigener Prüfbereich (`shell-lint`,
`comment-claims`, `test/slice-mv.bats`) und eigene Fehlermodi (stiller Nicht-Nachzug). `CODEX` ist
geprüft und **nicht** berührt — keine Aussage über `.codex/` ändert sich.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist am gemergten Stand durchgegangen
— **100** Verzeichnisse (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, **kein
Erwartungswert**); alle führen dieselbe Sub-Area `*`, die Sichtung ist damit vollständig. **Fünf
Treffer** berühren diesen Slice:

| Beobachtung (`BEO-ALL/<slug>`) | Zähler | Stand |
|---|---|---|
| `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` | 14× | offen |
| `neuer-waechter-ohne-mutations-fall` | 5× | offen |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 4× | offen |
| `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` | 3× | offen |
| `zusage-nennt-sensor-der-form-nicht-sieht` | 14× | geplant |

```sh
for s in lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch neuer-waechter-ohne-mutations-fall \
         uebergabe-an-andere-rolle-ohne-traeger-artefakt \
         mutations-fall-wird-von-berechtigter-aenderung-entwaffnet \
         zusage-nennt-sensor-der-form-nicht-sieht; do
  printf '%s %s\n' "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$s"
done
```

**Vier stehen über der Schwelle**, alle **vor** diesem Slice und nicht durch ihn; der Lese-Schritt,
der ihnen einen Ausgang zuweist, gehört der Welle-Closure und nicht dieser Planung. Der vierte
trifft diesen Schnitt unmittelbar: `uebergabe-an-andere-rolle-ohne-traeger-artefakt` ist die
Klasse, deren vierter Beleg **diese** Arbeit ohne Adresse war — dieser Slice ist die Adresse.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas sind Greenfield; der Block trägt
zwei Sub-Areas.

### Sub-Area: `harness/tools/` (Kürzel `TOOLS`)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — der Ort ist in
  [`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
  und [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)
  geregelt, der Vertrag des Werkzeugs steht in
  [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md), und der Skriptkopf
  führt seine drei Grenzen selbst auf.
- **Phase-Reife:** Phase 4 — das Skript ist getestet (`test/slice-mv.bats`, ein Go-Test über einen
  echten Scratch-Klon) und hat einen Mutations-Fall
  (`test/mutations/315-slice-mv-main-verliert-ausnahmeliste.sh`); was fehlt, ist die Deckung genau
  der Richtung, die dieser Slice anfasst.
- **Evidenz-/Diskrepanz-Risiko:** mittel — die tragende Diskrepanz ist **Vertrag gegen Verhalten**:
  Der Skriptkopf zählt drei Grenzen auf, und
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  beschreibt eine vierte breiter, als sie misst (§1). `zusage-nennt-sensor-der-form-nicht-sieht`
  (14×) ist genau diese Klasse.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund. Graduation entfällt (n/a bei GF).

### Sub-Area: `*` (gesamtes Repo, Kürzel `ALL`)

- **Modus:** GF
- **Konventionen-Dichte:** sehr hoch — 55 aktive Einträge
  (`ls harness/conventions/MR-*.md | wc -l`, kein Erwartungswert) plus die Hard Rules in
  [`AGENTS.md`](../../../../AGENTS.md) §3; für den Go-Anteil binden
  [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) und
  [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md).
- **Phase-Reife:** Phase 5 — `internal/archive/` läuft in `make test`, `make lint` und `make mutate`
  und hat einen dokumentierten Vertrag in
  [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md).
- **Evidenz-/Diskrepanz-Risiko:** mittel — der Stub ist noch **nie** über einem echten Archiv
  gelaufen (`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l` → 0, kein
  Erwartungswert); geprüft ist er über Tests, nicht über Bestand. Eine Kennungs-Erkennung, die
  eine Klasse übersieht, fiele erst beim ersten Archivierungs-Lauf auf.
- **Reconciliation-Aufwand:** keiner — GF, kein Inventur-Fund. Graduation entfällt (n/a bei GF).
