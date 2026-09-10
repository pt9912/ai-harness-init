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

**Verantwortlich:** —

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
weil drei mitemittierte Anweisungssätze namentlich auf `observations/README.md` zeigen und weil
die Datei die Unterscheidung *nichts beobachtet* gegen *nie geführt* trägt, die ein `.gitkeep`
nicht tragen kann. Sie ist damit **nicht** template-abgeleitet: Der vendored Baum führt für sie
keine Vorlage, ihre Herkunfts-Klasse ist die tool-autorierte
([`ADR-0006`](../../adr/0006-durchsetzung-commands-tool-als-quelle.md)), und der emittierte Text
ist eine generische Fassung, nicht die repo-spezifische dieses Repos.

**Was dieser Slice erst möglich macht.** Solange die drei Fundstellen stehen, startet ein Ziel mit
aktivem `codepaths` rot, und das verböte
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3). Erst nach
diesem Slice ist der Nicht-Emissions-Trigger für `codepaths` in
[slice-073](../in-progress/slice-073-emittierte-doc-gate-module.md) überhaupt eine Frage — dieser Slice
beantwortet sie **nicht**.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Der Bootstrap legt `docs/plan/planning/observations/README.md` an.** Der Inhalt ist
  tool-autoriert und generisch — Ablage-Form, Schreib- und Lese-Rollen, Beleg-Form, die drei
  Ausgänge, und die Aussage, dass eine leere Ablage nur diese Datei trägt. Idempotenz-Klasse
  **`skip-if-present`** (Festlegung 3): ein vorhandenes Ziel-Exemplar wird nicht überschrieben.
  **Der Zahn steht schon:** `TestTemplates_EmittierterBestandVollstaendig` vergleicht den ganzen
  emittierten Baum gegen eine `want`-Liste auf Mengengleichheit und ist nach der Erweiterung rot,
  bis `want` nachgezogen ist — diese rote Ausgabe wird gelesen und in §7 benannt.
- [ ] **(2) Gemessen: `codepaths` über dem frischen Ziel meldet 3 → 0 Befunde.** Dieselbe
  Messreihe wie in [slice-190](../done/slice-190-bootstrap-legt-die-versprochenen-orte-an.md) §1,
  netzlos über `roots: [spec, docs, harness]`, `--lang go` **und** sprachlos. **Der Rot-Nachweis
  ist der Vorher-Lauf** — derselbe Aufruf über dem heutigen Stand meldet **3**; ein Nachher-Lauf
  allein belegt nicht, dass die Änderung gewirkt hat
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Hier ist die Null die Zusage und nicht der
  Rückstand: alle drei Fundstellen zeigen auf denselben Ort.
- [ ] `make gates` grün; `make full-smoke` grün (beide Bootstrap-Formen); `make mutate` grün.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates.go` | update | die tool-autorierte `README.md` als neuer Emissions-Eintrag; **nicht** `structureGitkeeps()` — deren Träger ist ein leeres `.gitkeep`, und Festlegung 2 entscheidet gegen diesen Träger |
| `internal/emit/templates_test.go` (`want`-Listen) | update | der Mengen-Vergleich ist der Zahn; er wird nachgezogen, nicht aufgeweicht |
| `internal/emit/templates/d-check.yml` | **unverändert** | welche Module ein Ziel bekommt, entscheidet [slice-073](../in-progress/slice-073-emittierte-doc-gate-module.md) — dieser Slice räumt dessen Vorbedingung, er trifft die Entscheidung nicht |
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
  — **Ausgang:** <offen>
- **Der Beleg deckt das frische Ziel, nicht das gealterte.** Die Anlage ist *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)); ein bereits gebootstrapptes Repo bekommt
  weder den Ort noch die Datei, und seine drei Fundstellen bleiben stehen. Registriert als
  [`BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md).
  — **Ausgang:** <offen>
- **Der Ausgang dieses Slice ist der ausschreibende, und das ist eine Wahl.** Die drei Fundstellen
  ließen sich auch stumm schalten oder umformulieren; hier entsteht stattdessen, worauf sie
  zeigen. Ob das Kriterium für diese Wahl irgendwo steht, ist damit nicht beantwortet — registriert
  als
  [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md).
  — **Ausgang:** <offen>
- **Nicht in diesem Slice:** die emittierte Modul-Liste
  ([slice-073](../in-progress/slice-073-emittierte-doc-gate-module.md)), die `.d-check.yml` **dieses** Repos,
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

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-NNN.md` | `evidence/slice-NNN.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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
  in §6; Träger der Klasse ist [slice-153](slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md).

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit (§Umfang oben); `*`
steht in der Modus-Deklaration als Greenfield, und dieser Slice führt keine neue Sub-Area ein.
