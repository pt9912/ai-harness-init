# Slice slice-201: Der Inline-Pfad in den vendored Baum bekommt einen Prüfer — oder eine benannte Grenze

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice ändert den Prüfbereich **eines** Gate-Moduls; sein Beleg ist ein
Sonden-Paar und ein grüner Gate-Lauf, und beides steht in seiner eigenen DoD (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
tragende Vertrag: ein Gate, dessen Vollständigkeits-Zeile über eine Fläche spricht, die es nicht
prüft, behauptet mehr als es trägt),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-**Anheben** ist ein Steering-Loop, kein ADR — [`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet
Senkungen),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)
(die `codepaths`-Ventile und ihre Wachstums-Klausel),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (sie deckt die
**Link**-Form in drei einfrierenden Bäumen; die Inline-Form in **lebenden** Artefakten deckt sie
ausdrücklich nicht),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Prüfbereichs-Frage einer emittierten Gate-Konfiguration ist eine andere Ebene und hier nicht
berührt)

**Berührte Spec-Stellen:** `—`. Der Prüfbereich eines Gate-Moduls ist in
[`spec/spezifikation.md`](../../../../spec/spezifikation.md) nicht festgelegt.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-07.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein toter Pfad in den vendored Baum, geschrieben als **Inline-Code** in einem **lebenden**
Artefakt, ist entweder ein Gate-Befund — oder die Grenze steht benannt an der Stelle, an der das
Gate seine Vollständigkeit behauptet. Beide Ausgänge sind zulässig; **kein Ausgang ist es nicht.**

**Der Befund und seine vermutete Ursache.** Ein erfundener Pfad **außerhalb** des Baseline-Baums
färbt `codepath-missing`, derselbe Pfad **im** Baseline-Baum nicht. Die Ursache steht vermutlich im
Prüfbereich und nicht in einem Ventil: `codepaths` liest `roots: [spec, docs, harness]`
(`grep -n 'roots:' .d-check.yml`), und `.harness` ist nicht `harness` — jeder Pfad unter
`.harness/`, `.claude/`, `internal/`, `cmd/` und `test/` liegt damit außerhalb. Die
`codepaths.ignore-refs`-Liste enthält keinen Baseline-Eintrag
(`awk '/^  ignore-refs:/{b=1;next} b&&/^[^ ]/{b=0} b' .d-check.yml`). **Das ist eine Lesart der
Konfiguration, keine Messung** — Liefer-Punkt 1 misst sie, statt sie zu übernehmen.

**Warum das teuer war.** Tote Baseline-Pfade in lebenden Artefakten sind in dieser Form dauerhaft
gate-unsichtbar; beim Sprung auf `v6.5.0` standen so sechs Falschaussagen in
[`harness/conventions.md`](../../../../harness/conventions.md), ohne dass ein Gate sie sah.
[slice-193](../done/slice-193-baum-tausch-v650-pins-ziehen.md) DoD 2 nennt dieselbe Grenze
vorab — *„Ein `.harness/baseline/…` in Inline-Code ohne Link-Klammer bleibt grün und ist als Pfad
in den Arbeitsbaum trotzdem tot"* — und behilft sich mit einem `git grep` als Beleg. Ein Beleg, den
jeder Lauf von Hand führen muss, ist kein Sensor.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die drei `ignore-refs`-Einträge für die einfrierenden Bäume.** Sie decken die **Link**-Form und
  sind eine eigene Entscheidung mit eigenem Wächter:
  [slice-197](../done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md), und diese Kennung
  nimmt den Punkt an. **Die zwei Vorgänge zeigen in verschiedene Richtungen** — jener schaltet
  stumm, dieser deckt auf; in einem Slice wäre am Ende nicht zu sagen, welche Hälfte welches
  Ergebnis erzeugt hat.
- **Der Prüfbereich außerhalb von `.harness/`.** Dieselbe `roots`-Lücke trifft `internal/`, `cmd/`
  und `test/` — und für die sagt die Konfiguration ausdrücklich *„folgen mit dem Go-Code (Phase 3)"*.
  Das ist eine **gestufte** Entscheidung mit eigenem Hochschalt-Trigger, kein Versehen; sie hier
  mitzunehmen hieße, eine Stufung ohne ihren Trigger aufzulösen.
- **Der Bestand toter Baseline-Pfade.** Findet die Messung welche, sind sie nachzuziehen — findet
  sie viele, ist das ein eigener Vorgang. Ein Slice, der zugleich den Prüfer baut und einen
  unbekannt großen Bestand räumt, hat keine Größe, die vorab feststeht.
- **Die emittierte Fassung der Gate-Konfiguration.** Was ein **Zielrepo** an Prüfbereich bekommt,
  ist eine andere Ebene mit eigenem Beleg (`make full-smoke`, nicht `make gates`) und eigener
  Default-Regel
  ([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Die Ursache ist gemessen, nicht gelesen.** Ein Sonden-Paar über einer Kopie **außerhalb**
      des Repos, gefahren mit dem in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest: ein
      erfundener Inline-Pfad in einem lebenden Artefakt **unter** `.harness/baseline/` und
      derselbe **außerhalb**. Der Lauf-Bericht nennt beide Ausgaben. Ergibt die Sonde eine andere
      Ursache als `roots` — etwa ein Ventil oder `scan.ignore` —, ist **das** der Befund, und §1 ist
      falsch gewesen; die Vermutung steht dort ausdrücklich als Vermutung.
- [x] **Der Ausgang ist gewählt und belegt: Prüfer oder benannte Grenze.**
      *Prüfer* heißt, `codepaths` erreicht `.harness/baseline/**` und der tote Inline-Pfad färbt rot
      — das ist ein **Gate-Anheben** und damit ein Steering-Loop, kein ADR
      ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids));
      der Bestand ist vorher zu messen, weil die Anhebung ihn sichtbar macht.
      *Benannte Grenze* heißt, [`harness/README.md`](../../../../harness/README.md) §Sensors sagt an
      der Stelle, an der `docs-check` seine Fläche beschreibt, **was es nicht sieht** — in derselben
      Form, in der es das für `make comment-claims` bereits tut. **Ein dritter Ausgang existiert
      nicht:** Wird weder geprüft noch benannt, bleibt eine Vollständigkeits-Zeile stehen, die mehr
      behauptet als sie trägt
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- [x] **Das Gegenbeispiel ist rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6), und **wovon**
      hängt vom Ausgang ab — der Lauf-Bericht nennt beides, Fall und gelesene Meldung.
      Beim *Prüfer*: ein toter Inline-Baseline-Pfad in einem lebenden Artefakt färbt `docs-check`
      rot, und ein **auflösender** bleibt grün — die Gegenprobe, ohne die der Prüfer auch
      pauschal röten könnte.
      Bei der *benannten Grenze*: die Grenze ist mit demselben Sonden-Paar aus Liefer-Punkt 1
      belegt, und der Text sagt sie als Lücke, nicht als Deckung. **Eine benannte Grenze ohne
      gemessenes Loch ist eine Behauptung** und erfüllt den Liefer-Punkt nicht.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update für [`harness/README.md`](../../../../harness/README.md) §Sensors falls
      öffentlicher Vertrag berührt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register fortgeschrieben, **falls dieser Slice einen Inventur-Fund auflöst** —
      Zeile mit Datum und auflösendem Artefakt nach *Aufgelöste Einträge* verschoben. **Entfällt
      hier:** Repos ohne Brownfield-Bootstrap haben die Datei nicht, und dieses führt sie nicht
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden). Der Pfad steht als
      **Kommando-Operand**, weil die vendored Vorlage ihn als blanken Inline-Code führt und
      `codepaths` ihn dann als fehlendes Ziel meldet — **genau das Modul, dessen Reichweite dieser
      Slice zum Gegenstand hat**, hier auf der Achse, auf der es greift.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`.d-check.yml`](../../../../.d-check.yml), Modul `codepaths` | update **oder nicht** | hängt am Ausgang aus Liefer-Punkt 2; die *benannte Grenze* fasst die Config nicht an |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update | beim Ausgang *Grenze* ihre Nennung, beim Ausgang *Prüfer* die Beschreibung der neuen Fläche |
| lebende Artefakte mit totem Inline-Baseline-Pfad | update | nur, falls die Messung welche findet; findet sie viele, greift §1 dritter Ausschluss |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`make gates` ist grün** — beobachtbar am Lauf selbst. Ein
Slice, der die Fläche eines Gates ändert, braucht einen grünen Ausgangsstand: Auf rotem Baum ist
nicht unterscheidbar, ob die neue Fläche rot färbt oder die alte. Diese Bedingung ist am Tag dieses
Plans **unerfüllt** (36 Befunde, `make docs-check`); der Slice wartet auf
[slice-197](../done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung aus Liefer-Punkt 1 einen
  Bestand toter Inline-Pfade zeigt, der nicht in einer Review-Sitzung prüfbar ist. Dann trennt der
  Schnitt die Fläche (Prüfer bzw. Grenze) vom Räumen des Bestands.
- `in-progress` → `open` (blockiert — Carveout?): wenn das Anheben eine Fläche aufdeckt, die aus
  einem **anderen** Grund rot ist als dem gesuchten — etwa weil `roots` mit `.harness` auch den
  vendored Fremd-Blob erfasst, den `scan.ignore` aus gutem Grund ausnimmt
  ([`AGENTS.md`](../../../../AGENTS.md) §3.7 §Geltungsbereich). Dann ist der rote Status auf einen
  Trigger zu schalten, nicht durch eine breitere Ausnahme zu ersetzen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. Das Sonden-Paar aus Liefer-Punkt 1 ist gefahren, und der Lauf-Bericht nennt beide Ausgaben —
   die Ursache steht damit gemessen da, gleich welcher Ausgang gewählt wurde.
2. Das Gegenbeispiel aus Liefer-Punkt 3 ist **rot gesehen**, mit gelesener Meldung, und
   `make gates` ist grün.

**Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).
Die Form hängt am Ausgang: *Prüfer* ergibt einen neuen Sensor, *Grenze* eine benannte Lücke. Beide
sind zulässige Lerneinträge; was **nicht** zulässig ist, ist ein Slice, der die Fläche unverändert
lässt und trotzdem eine geschärfte Regel meldet.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die vermutete Ursache ist falsch.** §1 liest `roots: [spec, docs, harness]` und schließt daraus
  auf den Prüfbereich; gelesen ist nicht gemessen, und die Klasse dafür heißt
  [`BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md)
  — **zitiert**, nicht umformuliert, damit das Register sie nicht als zwei Pfade zählt.
  Liefer-Punkt 1 ist genau deshalb eine Messung und keine Bestätigung — er darf die Vermutung
  widerlegen, ohne dass der Slice scheitert. — **Ausgang: entfallen.** Die Messung ist gefahren und
  von zwei weiteren Rollen unabhängig reproduziert; die Vermutung trägt, und die Kontrolle ohne
  `/baseline`-Segment schließt die zweite genannte Ursache aus. Ein Risiko *„gelesen statt
  gemessen"* kann an einer gefahrenen Messung nicht mehr eintreten.
- **Das Anheben deckt mehr auf als den gesuchten Fall.** `roots` ist keine Baseline-Achse, sondern
  eine Wurzel-Liste; wer `.harness` aufnimmt, nimmt `.harness/state/` und `.harness/skills/` mit.
  Wie groß der neue Prüfbereich ist, gehört **vor** die Änderung gemessen — sonst ist der Slice
  nicht in einer Review-Sitzung prüfbar, und das ist ein Abbruch-Kriterium, kein Ärgernis. —
  **Ausgang: eingetreten**, und die Messung trägt die Größenordnung:
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
  nimmt den Punkt an und trägt je Klasse eine eigene, gemessene Ausnahme statt der vierten Wurzel.
- **Der Ausgang *benannte Grenze* fühlt sich wie Arbeit an und ist eine Nicht-Änderung.** Genau
  darin liegt seine Gefahr: Ein Satz in
  [`harness/README.md`](../../../../harness/README.md) schließt kein Loch, er beschreibt es. Er ist
  trotzdem der richtige Ausgang, wenn das Anheben teurer ist als der Nutzen — aber er darf nicht als
  Deckung gelesen werden, und der Text hat das zu sagen. — **Ausgang: eingetreten**, eine Ebene
  tiefer als vorgezeichnet: Der Text sagt die Grenze als Lücke, seine Zusammenfassung der Fundmenge
  war jedoch zweimal stärker als die Fundmenge selbst. Die Adresse ist dieselbe —
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md),
  die die Grenze in einen Prüfer überführt.
- **Der Bestand wird durch das Anheben sichtbar und blockiert den eigenen Gate-Lauf.** Ein
  angehobenes Modul färbt rot, bevor der Bestand geräumt ist; die DoD-Zeile `make gates` grün hängt
  dann an Arbeit, die §1 ausschließt. Die Reihenfolge — erst messen, dann anheben — steht in
  Liefer-Punkt 2 und ist keine Empfehlung. — **Ausgang: entfallen.** Der gewählte Ausgang fasst
  [`.d-check.yml`](../../../../.d-check.yml) nicht an, gemessen über die drei Inhalts-Commits des
  Slice (`git show --pretty=format: --name-only f5189bba f99aca04 602eb7c0 | grep -c '\.d-check\.yml'`
  → **0**, Exit 1); ohne Anhebung gibt es keinen Bestand, der einen Gate-Lauf blockieren könnte.
  Für den Prüfer-Ausgang trägt slice-202 dasselbe Risiko in seinem eigenen §6.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Das Sonden-Paar mit **Kontrolle**. Zwei erfundene Pfade hätten die
  Diagnose gestützt und wären mit ihr auch dann grün geblieben, wenn die falsche Ursache benannt
  gewesen wäre; erst der dritte Pfad — innerhalb `.harness/`, **ohne** `/baseline`-Segment —
  trennt die zwei Kandidaten. Er ist der Grund, warum die Ursache heute `roots` heißt und nicht
  `scan.ignore`, und er hat einen Satz im lebenden Beobachtungs-Register widerlegt, statt ihn zu
  bestätigen. Hermetisch, netzlos, über dem gepinnten Digest, außerhalb des Arbeitsbaums — von
  zwei weiteren Rollen unabhängig nachgefahren mit demselben Ergebnis.
- **Was ging anders als geplant:** §1 kennt zwei Ausgänge und stellt den Bestand als Mengenfrage
  (*„findet sie welche … findet sie viele"*). Gemessen ist er eine **Klassenfrage**: Ein Pfad in
  den vendored Baum unter einem abgelösten Tag ist als Mess-Operand richtig und als Adresse tot;
  ein Pfad auf eine Datei, die das Werkzeug in jedes Zielrepo emittiert und die dieses Repo nicht
  führt, ist eine Dogfood-Lücke; ein Pfad auf eine nicht existierende Vorlage ist schlicht falsch.
  Ein Prüfer braucht darum je Klasse eine eigene Ausnahme, nicht eine vierte Wurzel — das ist der
  Zuschnitt von slice-202 und war in §1 so nicht vorgezeichnet. Zweitens: Die tragende Zahl des
  Absatzes und ihre Aufschlüsselung mussten je zweimal nachgezogen werden, beide Male gefunden von
  der jeweils übernächsten Rolle.
- **Steering-Loop-Eintrag:** Regel geschärft (Kandidat, **nicht** verkörpert): Eine Zahl, die den
  Baum beschreibt, **in dem sie steht**, ist eine selbstbezügliche Messung — das Kommando
  danebenzuhaben genügt nicht, es muss über dem Baum **nach** der Änderung gefahren sein, die es
  beschreibt.
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 verlangt genau das bereits (*„wer sie schreibt, hat es über dem Baum gefahren, von dem
  sie spricht"*); was fehlt, ist der Wächter und die Benennung des selbstbezüglichen Falls, in dem
  der schreibende Commit den Messgegenstand selbst bewegt. Auslöser:
  `BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` (slice-186, slice-200, slice-201 —
  3×). Verkörpern ist Architect-Arbeit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und gehört an den Lese-Schritt der nächsten
  Welle-Closure; dieser Eintrag ist damit **gezählt, nicht verkörpert**.
- **Beobachtungs-Register (`../observations/`):** acht `evidence/slice-201.md` ergänzt, Zähler
  als Dateizahl abgelesen
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, keine
  Erwartungswerte) — `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` **3×** ·
  `zusammenfassung-staerker-als-ihre-quelle` **3×** ·
  `fremdes-rollen-artefakt-im-implementations-kontext` **7×** ·
  `zusage-neben-geaenderter-ableitung-bleibt-stehen` **18×** ·
  `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` **5×** ·
  `gate-modul-erreicht-den-vendored-baum-nicht` **2×** ·
  `benannte-luecke-ohne-ausgang` **1×** (erster Beleg; der Eintrag stand ohne) ·
  `verweis-nachzug-schreibt-in-eingefrorenes-artefakt` **4×** (der Closure-Move selbst schreibt in
  den Review-Report dieses Slice). Die `state.md` von
  `gate-modul-erreicht-den-vendored-baum-nicht` trägt jetzt die gemessene Ableitung und slice-202
  als Adresse; ihre `observation.md` bleibt unverändert, sie ist ab Anlage unveränderlich.
  **Sechs der acht Einträge stehen bei der Schwelle oder darüber** — der Lese-Schritt gehört im
  Wellen-Betrieb der Welle-Closure, auch für Slices ohne Wellen-Zugehörigkeit
  (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht); diese Closure zählt,
  sie entscheidet nicht.
- **Folge-Slices:**
  [slice-202](../open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
  (Der tote Inline-Pfad unter `.harness/` bekommt seinen Prüfer) — ist eine Datei in `open/`.
- **Risiken aus §6:** vier Risiken, vier Ausgänge — zwei *entfallen* mit Begründung, zwei
  *eingetreten* mit slice-202 als Adresse; siehe §6.
- **Drei Paarungen:** nach dem `git mv` geprüft. **(a) Anker** — der Steering-Loop-Eintrag trägt
  kein Feld `liegt in`, die Paarung hat damit keinen Gegenstand (gezählt, nicht verkörpert).
  **(b) Folge-Slice** — slice-202 ist eine Datei im Lifecycle
  (`find docs/plan/planning -name 'slice-202-*.md'` → eine Zeile, in `open/`).
  **(c) Register** — jede zitierte Kennung löst auf; die zweite Hälfte *„jede Registerzeile trägt
  mindestens einen Beleg"* meldet **einen** Eintrag ohne `evidence/`:
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab`
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && basename "$d"; done`).
  Das ist **kein** Rückstand: Der Eintrag führt sein einziges Vorkommen unter *Benannt, nicht
  gezählt*, und ein Vorkommen ohne abgeschlossenen Vorgang bekommt nach Baseline-Regelwerk
  `modul-06-roadmap.md` §Das Beobachtungs-Register ausdrücklich keinen Beleg. Die maschinelle
  Hälfte der Paarung und diese Regel widersprechen einander für genau diese Klasse — benannt
  statt stillschweigend durchgewinkt.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area, `*` (`ALL`). Die
Gate-Konfiguration adressiert das ganze Repo; `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`)
sind als Pfade nicht berührt. **Der neue Prüfbereich ist keine neue Sub-Area** — er ändert, worüber
ein Modul urteilt, nicht die Reife-Achse eines Bereichs.

**Vorgelagert — offene Beobachtungen sichten:** Das Register unter
[`../observations/`](../observations/) ist durchgegangen; es führt **65** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert), alle unter
`BEO-ALL`. Diesen Vorgang betreffen — Zähler als Dateizahl unter `evidence/` abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`):

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `vollstaendigkeits-zusage-misst-falsche-ebene` | 1× | offen | **der Kern**: die Zeile `N Datei(en) geprüft` spricht über Dateien, das Loch liegt auf der Referenz-Ebene |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 1× | offen | §1 liest die Config und misst nicht — §6 erstes Risiko, und Liefer-Punkt 1 ist die Antwort darauf |
| `gate-flaeche-haengt-am-arbeitsbaum` | 1× | offen | dieselbe Frage eine Achse daneben: was ein Gate sieht, hängt an seiner Bereichs-Deklaration, nicht an seiner Zusage |
| `ausnahmeliste-nur-auf-form-geprueft` | 1× | offen | `roots` ist eine Einschluss-Liste und wird auf Berechtigung nie geprüft — dieselbe Klasse wie eine Ausnahmeliste |
| `benannte-luecke-ohne-ausgang` | 0× | offen | **gesichtet und hier relevant**: Der Ausgang *benannte Grenze* aus Liefer-Punkt 2 erzeugt genau eine solche Lücke — sie bekommt ihren Ausgang mit demselben Slice, nicht später |

**Kein Eintrag erreicht mit diesem Slice 3×**, vorausgesetzt die Closure legt ihre Belege so, wie §6
sie vorzeichnet. Der Eintrag bei 0× trägt heute kein `evidence/`-Verzeichnis; das ist der abgelesene
Stand und keine Auslassung
(`find docs/plan/planning/observations/BEO-ALL/benannte-luecke-ohne-ausgang -type f`). Alle
Bezeichnungen sind **zitiert**, nicht neu formuliert.

**Modus:** alle berührten Sub-Areas **GF** — der Begründungsblock entfällt damit nach der
Umfangs-Regel dieser Sektion.
