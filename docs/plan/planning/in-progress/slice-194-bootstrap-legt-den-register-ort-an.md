# Slice slice-194: Der Bootstrap legt den Register-Ort an

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die Closure-Bedingung wäre die Abschrift der DoD unten — es gibt kein
*Mehr*, das eine repo-weite Beobachtung über die DoD hinaus fordert (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Damit **nicht** in der Roadmap geführt.

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist der Skelett-Generator
[`internal/emit/`](../../../../internal/emit) und der Bestand, den er in ein fremdes Ziel schreibt.
Die Register-Ablage **dieses** Repos ist nicht berührt; zwei Verträge, zwei Gründe.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(die Struktur-Verzeichnisse und die Zusage *out-of-the-box gate-sicher*),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (das gebootstrappte Ziel),
[`LH-FA-03`](../../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)
(die tool-autorierte Herkunfts-Klasse, aus der die `README.md` stammt),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate über falsch behauptetem Prüfbereich),
[`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) (Festlegung 2 trägt den Ort
**und** seinen Träger, Festlegung 3 seine Idempotenz-Klasse),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(Festlegung 1 — die Ablage besteht aus `README.md` plus je Beobachtung einem Verzeichnis),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (die Klasse *skip-if-present*),
[`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md) (das Tool als Quelle einer
mitemittierten Datei ohne Baseline-Vorlage).

**Berührte Spec-Stellen:** `ARC-003` (Idempotente Ablage,
[`spec/architecture.md §1`](../../../../spec/architecture.md#1-komponenten-übersicht)) · Technik:
`—`. Die Spezifikation führt für den emittierten Struktur-Bestand keine Kennung; der Vertrag steht
allein im Lastenheft.

**Verantwortlich:** Implementer (pt9912).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-07.

---

## 1. Ziel

**Ein frisch gebootstrapptes Ziel trägt `docs/plan/planning/observations/` mit seiner
`README.md`** — den letzten der drei Orte, die sein eigener mitemittierter Text als vorhanden
führt. Die zwei anderen sind erledigt: `harness/conventions/` legt
[slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) an,
`docs/plan/carveouts/done/` trägt
[`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) Festlegung 4 nicht und hat
dort einen Ausgang statt einer Anlage bekommen.

**Der Träger ist eine Datei mit Inhalt, keine `.gitkeep`** — Festlegung 2 entscheidet das eigens,
weil drei mitemittierte Anweisungssätze namentlich auf den Ort zeigen — zwei davon auf
`observations/README.md`, einer auf das Verzeichnis — und weil
die Datei die Unterscheidung *nichts beobachtet* gegen *nie geführt* trägt, die ein `.gitkeep`
nicht tragen kann. Sie ist damit **nicht** template-abgeleitet: Der vendored Baum führt für sie
keine Vorlage, ihre Herkunfts-Klasse ist die tool-autorierte
([`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md)), und der emittierte Text
ist eine generische Fassung, nicht die repo-spezifische dieses Repos.

**Was dieser Slice erst möglich macht.** Solange die drei Fundstellen stehen, startet ein Ziel mit
aktivem `codepaths` rot, und das verböte
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3). Erst nach
diesem Slice ist der Nicht-Emissions-Trigger für `codepaths` in
[slice-073](../done/slice-073-emittierte-doc-gate-module.md) überhaupt eine Frage — dieser Slice
beantwortet sie **nicht**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Der Bootstrap legt `docs/plan/planning/observations/README.md` an.** Der Inhalt ist
  tool-autoriert und generisch — Ablage-Form, Schreib- und Lese-Rollen, Beleg-Form, die drei
  Ausgänge, und die Aussage, dass eine leere Ablage nur diese Datei trägt. Idempotenz-Klasse
  **`skip-if-present`** (Festlegung 3): ein vorhandenes Ziel-Exemplar wird nicht überschrieben.
  **Der Zahn steht schon:** `TestTemplates_EmittierterBestandVollstaendig` vergleicht den ganzen
  emittierten Baum gegen eine `want`-Liste auf Mengengleichheit und ist nach der Erweiterung rot,
  bis `want` nachgezogen ist — diese rote Ausgabe wird gelesen und in §7 benannt.
- [x] **(2) Gemessen: `codepaths` über dem frischen Ziel meldet 3 → 0 Befunde.** Dieselbe
  Messreihe wie in [slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) §1,
  netzlos über `roots: [spec, docs, harness]`, `--lang go` **und** sprachlos. **Der Rot-Nachweis
  ist der Vorher-Lauf** — derselbe Aufruf über dem heutigen Stand meldet **3**; ein Nachher-Lauf
  allein belegt nicht, dass die Änderung gewirkt hat
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Hier ist die Null die Zusage und nicht der
  Rückstand: alle drei Fundstellen zeigen auf denselben Ort.
- [x] `make gates` grün; `make full-smoke` grün (beide Bootstrap-Formen); `make mutate` grün.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
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
| `internal/emit/templates.go` | update | die tool-autorierte `README.md` als neuer Emissions-Eintrag; **nicht** `structureGitkeeps()` — deren Träger ist ein leeres `.gitkeep`, und Festlegung 2 entscheidet gegen diesen Träger |
| `internal/emit/templates_test.go` (`want`-Listen, eigener Skip-if-present-Zahn für den Register-Ort) | update | der Mengen-Vergleich ist der Zahn; er wird nachgezogen, nicht aufgeweicht. `TestTemplates_SkipIfPresent` deckt nur `spec/lastenheft.md` — der Register-Ort bekommt einen eigenen Zahn |
| `internal/emit/templates/observations/README.md` | update | zwei Textstellen gegen `modul-06-roadmap.md` §Das Beobachtungs-Register nachgezogen: der Ausgang `gestrichen` ist an die 3×-Schwelle nicht gebunden; die Kürzel-Spalte gilt unabhängig davon, ob der Adopter seine ADR-/Slice-Kennungen segmentiert |
| `internal/emit/templates/d-check.yml` | update, Modul-Liste **unverändert** | welche Module ein Ziel bekommt, entscheidet weiterhin [slice-073](../done/slice-073-emittierte-doc-gate-module.md) — dieser Slice räumt dessen Vorbedingung, er trifft die Entscheidung nicht. Die Begründung des abgeschalteten Moduls hatte die eigene Anlage der Datei nicht mehr getragen und ist gestrichen |
| `internal/emit/emit_test.go` | update | derselbe Kommentar trug dieselbe Begründung ein zweites Mal und ist gleich gestrichen |
| `harness/tools/smoke.sh` | update | die Stichprobe bekommt einen dritten Klassen-Vertreter (tool-autorierte Datei mit Inhalt, keine Baseline-Vorlage) neben Singleton und Struktur-`.gitkeep` |
| `test/mutations/299-observations-readme-fehlt.sh`, `test/mutations/300-observations-readme-clobbert.sh` | neu | rot färbende Mutationen für die Vollständigkeits- bzw. die Skip-if-present-Zusage |
| die Register-Ablage **dieses** Repos | **unverändert** | Dogfood-Ebene, anderer Vertrag |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**`open` → `next`:** keine offene Vorfrage —
[`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) Festlegung 2 ist
`Accepted` und entscheidet Ort **und** Träger; `Verantwortlich:` wird dabei gesetzt.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls der generische Text der
  `README.md` sich nicht schreiben lässt, ohne eine zweite Entscheidung über den emittierten
  Prozess zu treffen — dann sind es zwei Liefer-Werte, nicht einer.
- `in-progress` → `open` (blockiert — Carveout?): falls die Nachmessung eine andere Zahl als
  **0** liefert. Nach oben heißt das, eine Fundstelle hat eine zweite Ursache; das gehört zurück
  in den Schnitt, statt DoD (2) still auf „weniger als vorher" abzusenken.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** der Vorher/Nachher-Lauf aus DoD (2) liegt vor — derselbe
netzlose d-check-Aufruf über demselben Bootstrap, **3** vorher und **0** nachher; **(b)**
`make gates` und `make full-smoke` grün, `make mutate` grün.

Dazu: DoD vollständig; Review konform (Modul 10); Verifikation bestätigt (Modul 11); jedes Risiko
aus §6 mit Ausgang; Closure-Notiz mit Steering-Loop-Lerneintrag; `git mv` nach `done/` als eigener
Move-Commit. Den Abschluss schreibt der **Planner** in frischem Kontext, nicht der Lauf, der die
Arbeit gebaut hat ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die emittierte `README.md` ist eine zweite Fassung einer Aussage des Regelwerks.** Sie
  beschreibt die Ablage-Form, die `modul-06-roadmap.md` §Das Beobachtungs-Register normiert, und
  kann gegen sie driften, ohne dass etwas rot wird —
  [`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) benennt das in
  §Verglichene Alternativen als Preis der gewählten Option. Registriert als
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
  — **Ausgang:** **weiter offen** → Beleg `evidence/slice-194.md` im genannten Verzeichnis; der
  Zähler steht damit bei **20×**
  (`ls docs/plan/planning/observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/evidence | wc -l`,
  kein Erwartungswert). Der Beleg zählt **vier** Stellen als **eine** Gelegenheit — zwei
  Kommentar-Begründungen, ein Adaptions-Eintrag und ein `sed`-Anker in einem Mutations-Fall —,
  weil zwei Funde in *einem* Vorgang kein zweites Auftreten sind. Die vierte Stelle liegt in einer
  Unterklasse, die der Ausgang des Eintrags nicht erreicht; §7 nennt sie.
- **Der Beleg deckt das frische Ziel, nicht das gealterte.** Die Anlage ist *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)); ein bereits gebootstrapptes Repo bekommt
  weder den Ort noch die Datei, und seine drei Fundstellen bleiben stehen. Registriert als
  [`BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md).
  — **Ausgang:** **weiter offen** → Beleg `evidence/slice-194.md` im genannten Verzeichnis; der
  Zähler steht damit bei **2×**
  (`ls docs/plan/planning/observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/evidence | wc -l`,
  kein Erwartungswert) und bleibt unter der Schwelle.
- **Der Ausgang dieses Slice ist der ausschreibende, und das ist eine Wahl.** Die drei Fundstellen
  ließen sich auch stumm schalten oder umformulieren; hier entsteht stattdessen, worauf sie
  zeigen. Ob das Kriterium für diese Wahl irgendwo steht, ist damit nicht beantwortet — registriert
  als
  [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md).
  — **Ausgang:** **weiter offen** → Beleg `evidence/slice-194.md` im genannten Verzeichnis; der
  Zähler steht damit bei **3×**
  (`ls docs/plan/planning/observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/evidence | wc -l`,
  kein Erwartungswert) und erreicht die Schwelle. Den Ausgang des *Eintrags* weist der Lese-Schritt
  zu; er liegt in diesem Repo bei der Welle-Closure, und §7 nennt Stand und Grund.
- **Nicht in diesem Slice:** die emittierte Modul-Liste
  ([slice-073](../done/slice-073-emittierte-doc-gate-module.md)), die `.d-check.yml` **dieses** Repos,
  jeder Migrationspfad für bereits gebootstrappte Repos, und jede Änderung am vendored
  Baseline-Baum.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner (Baseline-Regelwerk `modul-05-planning-harness.md` §Closure- und
Lerneintrag-Regeln). **Datum:** 2026-09-11.

**Woher die Zahlen unten stammen, und zwar getrennt.** Diese Closure hat den Register-Bestand, die
Wellen-Lage, die Carveout-Lage und die drei Paarungen **selbst** erhoben; jede solche Zahl steht
neben dem Kommando, das sie liefert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). **Drei stehen ohne eigenes Kommando da und sind übernommen:** die **3** und die **0**
der Messreihe aus DoD (2) sowie die Fall-Zahl von `make mutate`. Sie sind die der **Verifikation**,
die die Messreihe über einen eigenen `git worktree` gegen beide Stände unabhängig reproduziert und
den Mutations-Satz über den CI-Lauf desselben Standes einzeln nachgelesen hat
([`2026-09-11-slice-194-bootstrap-legt-den-register-ort-an-verify.md`](../../../reviews/2026-09-11-slice-194-bootstrap-legt-den-register-ort-an-verify.md));
diese Closure hat sie nicht ein drittes Mal gefahren — ein dritter Lauf hätte dieselbe Messstelle
ein drittes Mal abgelesen.

- **Was hat funktioniert: der Rot-Nachweis war ein Vorher-Lauf, nicht ein Nachher-Zustand.** DoD (2)
  verlangt beide Zahlen derselben Messreihe, und erst das Paar belegt eine **Wirkung** statt eines
  Zustands ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Das hat zwei Dinge getragen: Die Verifikation
  konnte die Zusage an einem eigenen Baum-Stand unabhängig reproduzieren, weil sie zwei Zahlen und
  eine Namensliste prüfte statt eines Erfolgs; und die Null war belastbar zusagbar, weil alle drei
  Fundstellen auf **denselben** Ort zeigten — eine Eigenschaft, die vor der Arbeit messbar war.
  Ebenso getragen hat der **Mengen-Vergleich als Zahn**: Die Vollständigkeits-Zusage über den
  emittierten Baum wird rot, sobald ein Eintrag hinzukommt, und wurde nachgezogen statt aufgeweicht.
- **Was ging anders als geplant — die eigene Begründung des Ausschlusses fiel mit der Arbeit weg.**
  Die emittierte Gate-Konfiguration und ein Testkommentar begründeten ein abgeschaltetes Modul
  damit, dass der Register-Ort im frischen Ziel *fehle*. Derselbe Liefergegenstand legt ihn an. §3
  des Plans führt die Datei deshalb als `update` mit **unveränderter** Modul-Liste, was der
  ursprüngliche Schnitt nicht vorgesehen hatte; die Modul-Entscheidung selbst bleibt außerhalb
  (§1). Der Fehler ist nicht Nachlässigkeit, sondern eine Begründung, die neben ihrer eigenen
  Ableitung stehen blieb — dieselbe Klasse, die dieser Slice dreimal weiter unten noch trifft.
- **Was der Review beitrug** (dritte Quelle nach Baseline-Regelwerk `modul-05-planning-harness.md`
  §Closure- und Lerneintrag-Regeln): zwei Runden, beide blockierend, beide aufgelöst.
  [Runde 1](../../../reviews/2026-09-11-slice-194-bootstrap-legt-den-register-ort-an.md) (1 HIGH ·
  5 MEDIUM · 3 LOW · 2 INFO) trug die **Sache** unabhängig und blockierte an Aussagen *neben* der
  Sache; MEDIUM-2 hat die Idempotenz-Zusage von einer Behauptung zu einem eigenen Zahn gemacht,
  MEDIUM-3 und MEDIUM-5 haben den emittierten Text an zwei Stellen gegen den Regelwerks-Wortlaut
  gezogen.
  [Runde 2](../../../reviews/2026-09-11-slice-194-bootstrap-legt-den-register-ort-an-runde-2.md)
  (1 HIGH · 1 MEDIUM · 2 LOW) fand den Befund, der diese Closure trägt: Die Auflösung eines
  Befundes der Vorrunde entwaffnete den Mutations-Fall, der die Vollständigkeits-Zusage hält.
  Beide Runden nennen dieselbe wiederkehrende Klasse; sie steht im Register (§6, erster Ausgang).
- **Zwei Punkte bleiben benannt statt geschlossen.** Der emittierte Adopter-Text lässt an einer
  Stelle eine *Zeile* in einen Abschnitt wandern, den die Verzeichnis-Form der Ablage nicht führt —
  die Aussage ist richtig, ihr Träger trägt das Vokabular der abgelösten Form
  (Runde 2, LOW-1). Und die Alias-Zusage an der Emissions-Zeile nennt keinen Sensor und hat keinen
  (Runde 2, LOW-2): Sie steht **an** der Anweisung, die sie hält, und kann nicht wegdriften, ohne
  dass genau diese Zeile angefasst wird — der Reviewer nennt den fehlenden Zahn ausdrücklich eine
  Abwägung und keinen Befund. Beide Punkte hängen an keinem DoD-Punkt und sind hier keine
  Register-Belege, weil sie nicht die Klasse eines geführten Eintrags treffen.
- **Die Formfrage zu §3 ist entschieden: der Stand bleibt.** Der Bedienhinweis der Vorlage
  beauftragt die Erweiterung der Änderungs-Tabelle durch den ausführenden Lauf ausdrücklich; die
  Zeile trägt damit keinen Vorgang, sondern den Liefergegenstand. Die Verifikation hat den
  Plan-vs-Code-Diff gegen den **unverfälschten** Stand der Tabelle geführt und stellt fest, dass
  daraus keine Verifikationslücke folgt.
- **Trigger-Audit — ein Auflösungs-Trigger ist gefeuert und hat seinen Ausgang.** Die Position
  `codepaths` der emittierten Doc-Gate-Startkonfiguration stand mit dem Trigger *„die emittierte
  Prosa nennt keinen Ort mehr, den ein frisches Ziel nicht trägt"* zurück; der Ort wird emittiert,
  und die Messung aus DoD (2) ist genau dieser Nachweis. **Aktiviert wird deshalb nichts:** Von den
  drei Kriterien, die
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  Setzung 1 verlangt, trägt das dritte nicht —

  ```sh
  grep -m1 '^modules:' .d-check.yml                 # Kriterium 1 erfuellt: der Dogfood faehrt codepaths
  grep -c -i codepath harness/tools/full-smoke.sh   # 0 -- kein Gegenbeispiel faerbt im Ziel rot
  ```

  **Keine Erwartungswerte.** **Der Ausgang ist ein Folge-Slice mit Kennung, und er musste neu
  geschnitten werden:** Die naheliegende Adresse nimmt die Sendung nicht an —
  [slice-210](../open/slice-210-planning-modul-im-emittierten-doc-gate.md) schließt `codepaths` in
  §1 aus und begründet den Ausschluss mit genau dem Trigger, der eingetreten ist. Nach
  Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice ist ein Folge-Slice, der den
  verwiesenen Punkt selbst ausschließt, keine Adresse. Der Trigger geht darum an
  [slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md).
  **Die übrigen zwei Artefaktklassen des Audits:** Zwei Carveouts stehen
  (`ls docs/plan/carveouts/CO-*.md | wc -l` → **2**), beide mit gesetztem Ausgang und von diesem
  Slice nicht berührt; ein bootstrap-aware Gate führt der Dogfood nicht. Die ADR-Achse liegt beim
  Architect und ist von diesem Slice nicht bewegt.
- **Lese-Schritt — hier als Vorlauf, verbindlich bei der Welle-Closure.** Dieses Repo führt
  **Wellen-Betrieb** (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein Erwartungswert), und
  *wellenlos* ist nach Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht eine
  Eigenschaft des **Repos**, nicht des einzelnen Slice: Das Kopf-Feld `Welle:` dieses Plans sagt
  allein, dass er in kein Bündel gehört. Die Tabelle *Träger im Repo ohne Wellen* greift damit
  nicht; Lese-Schritt und Paarungen sind Schritte der Welle-Closure, die auch Slices ohne
  Wellen-Zugehörigkeit einsammelt. Der Vorlauf ist read-only gefahren:

  ```sh
  for d in docs/plan/planning/observations/BEO-ALL/*/; do
    n=$(ls "$d/evidence"/*.md 2>/dev/null | wc -l); s=$(head -1 "$d/state.md")
    [ "$n" -ge 3 ] && [ "$s" = "**Stand:** offen" ] && echo "$(basename $d) $n"
  done | wc -l      # 10 -- kein Erwartungswert
  ```

  **Zehn** Einträge stehen bei ≥ 3× und tragen `offen`. **Einen davon hebt dieser Slice über die
  Schwelle** —
  [`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
  erreicht mit seinem Beleg **3×**. Sein Ausgang wäre ein Kriterium, wann die Auskunft schwerer
  wiegt als der kürzere Weg; das ist Norm-Text, und der gehört dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). **Einen zweiten belegt er, ohne ihn zu heben** —
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  stand schon darüber. Die **acht übrigen** liegen thematisch außerhalb dieses Slice — über sie zu
  urteilen hieße, über fremde Gegenstände zu entscheiden. Alle zehn gehören damit an den
  Lese-Schritt der nächsten Welle-Closure, und sie sind hier benannt, damit er sie nicht suchen
  muss.
- **Steering-Loop-Eintrag — geschärfte Regel, gezählt:** *Ein Anker, der auf eine Ableitung zeigt,
  ist selbst eine Zusage — und ein `sed`-Muster in einem Mutations-Fall ist der Anker, den keine
  Prüfung des geänderten Codes sieht.* Wer die rechte Seite einer Zuweisung ändert, ändert das
  Ziel jedes Musters, das auf ihr ankert; der Fall wird dann grün, ohne noch etwas zu messen — der
  Treiber fängt das fail-closed ab, aber erst beim nächsten vollständigen Lauf, und der liegt hinter
  Review und Übergabe. Der Prüfschritt ist ein Kommando lang und gehört an die Änderung, nicht an
  den Lauf danach. Auslöser:
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (**20×**, Stand `geplant`/`slice-153`). *Gezählt, nicht verkörpert:* Die Regel ist hier
  formuliert, nicht geschrieben — ihr Zielort wäre ein Norm-Artefakt, und das gehört dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Das Feld `liegt in` entfällt darum. **Und die
  Unterklasse liegt außerhalb der genannten Kennung:** Deren Gegenstand sind Anker-Zusagen in den
  Anweisungssätzen, für die das Modul `anchors` bereits trägt; ein Muster in einem Mutations-Fall
  ist keine Anker-Form, die ein Doku-Modul sieht.
- **Steering-Loop-Eintrag — geschärfte Regel, gezählt:** *Der Annahme-Test für eine Adresse gilt
  auch dem Ausgang eines gefeuerten Triggers, nicht nur einem Out-of-Scope-Verweis.* Die
  Baseline formuliert ihn für §1 eines Slice-Plans — *„Ein Folge-Slice, der den verwiesenen Punkt
  selbst ausschließt oder vor dem verweisenden schließt, ist keine [Adresse]"*; derselbe Test
  entscheidet, ob ein bestehender Slice den Ausgang eines Triggers aufnehmen kann. Ohne ihn wäre
  der Trigger an eine Datei geheftet worden, die ihn in ihrem eigenen Abgrenzungs-Abschnitt
  ausschließt, und hätte formal einen Ausgang und materiell keinen. **Nicht als Beleg gebucht:**
  [`ausgang-nennt-traeger-der-nicht-traegt`](../observations/BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt/observation.md)
  beschreibt genau diesen Schaden, aber er ist nicht eingetreten — die Prüfung lief vor dem
  Eintragen, und der Zähler misst, was eingetreten ist. *Gezählt, nicht verkörpert*, aus demselben
  Grund wie oben.
- **Beobachtungs-Register (`../observations/`):** **vier** Belege, **kein** neues Verzeichnis. Jeder
  Zähler ist die Zahl der Dateien unter `evidence/`
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`) — keine Erwartungswerte,
  sie wandern mit dem Register:
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  **20×** — **ein** Beleg für **vier** Stellen, weil mehrere Funde in *einem* Vorgang eine
  Gelegenheit sind und nicht mehrere ·
  [`idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md)
  **2×** ·
  [`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
  **3×** — Schwelle erreicht, Ausgang beim Lese-Schritt oben ·
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  **10×** — der Closure-Move macht den Ruhe-Marker der Roadmap falsch, und `make slice-mv` trägt
  ihn nicht nach; der Ausgleich ist ein eigener Commit, und zwischen beiden ist `docs-check` rot.
  **Ein Stand ist fortgeschrieben, und kein Beleg gehört dazu:**
  [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  bleibt bei **3×** — dieser Slice ist seine Auflösung, kein Auftreten —, behält den Ausgang
  `geplant` und trägt als Kennung jetzt
  [slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md): Die Anwendung steht, die
  Wächter-Lücke, die seine `state.md` benennt, ist das im Ziel nicht laufende `codepaths`.
  **Geprüft und ausdrücklich *nicht* gebucht:**
  [`schwellen-uebertritt-ohne-zustaendige-rolle`](../observations/BEO-ALL/schwellen-uebertritt-ohne-zustaendige-rolle/observation.md)
  (**2×**) trifft den Fall nicht — sie beschreibt einen Ausgang, der *„eine Handlung verlangt, die
  der Rolle dieser Closure nicht zusteht"*; hier ist die Rolle der Planner, und das Schneiden eines
  Folge-Slice steht ihr offen.
- **Folge-Slices:**
  [slice-211](../open/slice-211-codepaths-im-emittierten-doc-gate.md) (Das Modul `codepaths` im
  emittierten Doc-Gate wird entschieden) — mit dieser Closure geschnitten, ist eine Datei in
  `open/`.
- **Risiken aus §6:** alle **drei** mit genau einem Ausgang, alle drei **weiter offen** ins
  Beobachtungs-Register. Kein Risiko ist eingetreten (kein Carveout, kein Folge-Slice als
  Risiko-Ausgang) und keines entfallen. Gemessen über dieser Datei:
  `grep -c 'Ausgang:\*\* <offen>'` → **0**.
- **Drei Paarungen:** verbindlich nicht hier — dieses Repo führt Wellen-Betrieb, und sie sind
  Schritt 3c der Welle-Closure (letzter DoD-Punkt). Als read-only-Vorlauf sind alle drei gefahren
  und tragen: **(a)** hat keinen Gegenstand — kein Steering-Loop-Eintrag dieser Sektion trägt das
  Pflichtfeld `liegt in <Zielort>`, beide sind gezählt und nicht verkörpert; **(b)** jede in dieser
  Datei genannte Slice-Kennung löst im Lifecycle auf, `slice-211` als Datei in `open/`; **(c)**
  jeder zitierte `BEO-ALL/<slug>` existiert im Register. Die zweite Hälfte von (c) hat **einen**
  Rückstand außerhalb dieses Slice: ein Verzeichnis führt kein `evidence/`
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do [ -d "$d/evidence" ] || echo "$d"; done | wc -l`
  → **1**, kein Erwartungswert). Es trägt einen *Benannt, nicht gezählt*-Abschnitt, ist also
  gewollt beleglos — die maschinelle Hälfte *jede Zeile trägt mindestens einen Beleg* trifft es
  trotzdem. Ob die Prüfung oder die Form nachzieht, entscheidet nicht diese Closure.
- **Was diese Closure nicht deckt.** Archiviert wird nicht: Das ist Schritt 4 derselben
  Welle-Closure, und `make archive-welle` ist auf diesen Bestand nicht anwendbar — die Sperre
  `untergrenze` steht (`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l` → **0**). Das
  ist eine Entscheidung, keine Auslassung. Alles **unter** der Schwelle liest diese Closure nicht;
  dafür ist der Sichtungs-Schritt der nächsten Slice-Planung zuständig (§8).

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) —
[`internal/emit/`](../../../../internal/emit) liegt darunter. Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt daneben `harness/tools/` und `.codex/`; **beide sind nicht berührt** — keine Datei aus §3
liegt dort.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl der
`evidence/`-Dateien und die erste Zeile seiner `state.md`:

```sh
for s in emittierte-vorlagen-klassifikation-ohne-traeger \
         idempotente-anlage-erreicht-den-bestand-nicht \
         gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse \
         zusage-neben-geaenderter-ableitung-bleibt-stehen; do
  d="docs/plan/planning/observations/BEO-ALL/$s"
  echo "$s $(ls "$d/evidence" | wc -l)x $(head -1 "$d/state.md")"
done
# emittierte-vorlagen-klassifikation-ohne-traeger      3x  **Stand:** offen
# idempotente-anlage-erreicht-den-bestand-nicht        1x  **Stand:** offen
# gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse  1x  **Stand:** offen
# zusage-neben-geaenderter-ableitung-bleibt-stehen    17x  **Stand:** geplant
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die vier Einträge des Kommandos berühren diesen Slice, weitere Treffer: keine.

- [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  — **steht über der Schwelle und ist der Grund für diesen Slice.** Dieser Slice räumt den
  Rest-Teil, den [slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) offen
  gelassen hat. Den Ausgang setzt der Lese-Schritt der nächsten Welle-Closure, nicht dieser Plan.
- [`idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md)
  — **getroffen**: Festlegung 3 ordnet die Anlage *skip-if-present* zu; steht als Risiko in §6.
- [`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
  — **berührt, in der günstigen Richtung**: Dieser Slice wählt für alle drei Fundstellen den
  ausschreibenden Ausgang. Dass die Wahl kein Kriterium hat, bleibt trotzdem offen; steht als
  Risiko in §6.
- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **getroffen**, in der Unterklasse *Zusage ohne Anker, Ausgang eine Regel ohne Sensor*: Die
  neue emittierte `README.md` ist eine zweite Fassung einer Regelwerks-Aussage. Steht als Risiko
  in §6; Träger der Klasse ist [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md).

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit (§Umfang oben); `*`
steht in der Modus-Deklaration als Greenfield, und dieser Slice führt keine neue Sub-Area ein.
