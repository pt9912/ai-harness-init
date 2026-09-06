# Slice slice-190: Der Bootstrap legt die Orte an, die seine eigenen emittierten Texte nennen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Die Closure-Bedingung wäre die Abschrift der DoD unten —
es gibt kein *Mehr*, das eine repo-weite Beobachtung über die DoD hinaus fordert
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).
Damit **nicht** in der Roadmap geführt.

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist der Skelett-Generator
[`internal/emit/`](../../../../internal/emit) und der Bestand, den er in ein
fremdes Ziel schreibt. Die `.d-check.yml` **dieses** Repos ist nicht berührt und
damit auch nicht [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md);
zwei Verträge, zwei Gründe.

**Bezug:** [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(die Struktur-Verzeichnisse und die Zusage *out-of-the-box gate-sicher* — der
Vertrag, gegen den dieser Slice misst),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(das gebootstrappte Ziel),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(die Gegenkraft: kein Gate über leerem oder falsch behauptetem Prüfbereich),
[`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche — ihr Geltungsbereich **ist**
dieser Bestand),
[`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
(welche Orte der Bootstrap anlegt — Festlegung 1 trägt `harness/conventions/`,
Festlegung 2 den Register-Ort, Festlegung 4 trägt `docs/plan/carveouts/done`
nicht),
[`ADR-0007`](../../adr/0007-bootstrap-phasen.md) (die Idempotenz-Klasse
*skip-if-present*, aus der die Reichweiten-Grenze folgt),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die Verzeichnis-Form des Beobachtungs-Registers, deren Ort hier entsteht),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes
Gegenbeispiel).

**Berührte Spec-Stellen:** `ARC-003` (Idempotente Ablage,
[`spec/architecture.md §1`](../../../../spec/architecture.md#1-komponenten-übersicht))
· Technik: `—`. Die Spezifikation führt für den emittierten Struktur-Bestand
keine Kennung; ihre Kennungen zählt

```sh
grep -oE 'SPEC-[0-9]+' spec/spezifikation.md | sort -u | wc -l   # 34
```

— keine davon nennt ihn, der Vertrag steht allein im Lastenheft.

**Verantwortlich:** Implementer (pt9912).

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-06.

---

## 1. Ziel

**Ein frisch gebootstrapptes Ziel trägt `harness/conventions/`** — den einen der
drei Orte, die sein eigener emittierter Text als vorhanden führt und den
[`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Festlegung 1 trägt. Die zwei anderen entstehen hier nicht:
`docs/plan/carveouts/done` trägt Festlegung 4 nicht, der Register-Ort ist
entschieden und liegt in einem eigenen Schnitt (§6). Ihre Fundstellen bleiben —
eine bekommt einen Ausgang statt einer Anlage, drei bleiben stehen.

Die feste Liste in `structureGitkeeps()` trägt heute sechs Einträge:

```sh
sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c '^\t\t"'   # 6
```

Drei weitere Orte werden von emittierten Dateien im Indikativ genannt und
entstehen nicht: das Beobachtungs-Register, das Eintrags-Verzeichnis des
Konventionsspeichers und die `done/`-Ablage der Carveouts.

**Gemessen am frischen Ziel**, nicht hergeleitet. Bootstrap in ein leeres
`git`-Repo (`ai-harness-init --lang go --name smoke`), dann der gepinnte d-check
netzlos mit `codepaths` über `roots: [spec, docs, harness]`:

```sh
docker run --rm --network none -v "$ziel:/repo:ro" \
  ghcr.io/pt9912/d-check@sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641
# 19 Datei(en) geprüft, 6 Befund(e) — alle codepath-missing
```

| Genannter Ort | genannt von | Fundstellen | in diesem Slice |
|---|---|---|---|
| `harness/conventions/` | emittierte `harness/conventions.md` | 2 | angelegt (DoD 1) — das trifft eine der zwei; die zweite ist der Vorlagen-Pfad unten (DoD 2) |
| `docs/plan/carveouts/done/` | emittierte `docs/plan/planning/README.md` | 1 | **nicht angelegt** (Festlegung 4) — Ausgang statt Anlage (DoD 2) |
| `docs/plan/planning/observations/` | drei emittierte Commands | 3 | **nein** — entschieden (Festlegung 2), eigener Schnitt (§6) |

**Zwei der sechs Fundstellen bekommen einen Ausgang statt einer Anlage.** Die
eine hat eine eigene Ursache und darum einen eigenen DoD-Punkt: die emittierte
`harness/conventions.md` nennt die Eintrags-Vorlage
`MR-NNN-titel.template.md` unter einem **baseline-relativen** Verzeichnis, das im
Ziel als repo-relatives gelesen wird. Sie liegt real unter
[`.harness/baseline/v6.0.0/templates/harness/conventions/`](../../../../.harness/baseline/v6.0.0/templates/harness/conventions/).
Der Satz stammt aus dem vendored Fremdtext (`conventions.template.md`); dieses
Repo hat ihn in seiner eigenen `harness/conventions.md` nicht, das emittierte
Ziel trägt ihn:

```sh
grep -c 'MR-NNN-titel.template.md' harness/conventions.md   # 0
```

Die andere ist die Nennung von `docs/plan/carveouts/done/` im emittierten
Planning-Index: Der Ort wird nicht angelegt, die Zeile bleibt stehen und braucht
denselben benannten Ausgang.

**Die Asymmetrie ist die des Gates, nicht der Zeile:** Der Dogfood fährt
`codepaths`, das Ziel fährt es nicht — derselbe Pfad fällt hier auf und dort
nicht.

**Was dieser Slice nicht ist, und was daraus folgt.** Er schaltet `codepaths` in
[`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml)
**nicht** ein. Welche Module ein Ziel bekommt, entscheidet
[slice-073](slice-073-emittierte-doc-gate-module.md), dessen
Nicht-Emissions-Trigger für `codepaths` lautet: *„die zwei Vorlagen-Stellen sind
emit-seitig neutralisiert oder upstream gefallen"*.

**Dieser Slice feuert den Trigger nicht — und das gehört gesagt, statt es zu
hoffen.** Nach DoD (1) und (2) bleiben **drei** Fundstellen stehen, alle aus dem
Register-Ort. Solange sie stehen, startet ein Ziel mit aktivem `codepaths`
rot, und das verböte
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3).
Die Reihenfolge ist damit: erst dieser Slice, dann der Schnitt, der den
Register-Ort liefert (§6), **dann** ist `codepaths` in slice-073 überhaupt eine
Frage. Drei Schnitte — der Bestand ist auch ohne die Modul-Liste falsch.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Der Bootstrap legt den einen Ort an, den Festlegung 1 trägt.**
  `structureGitkeeps()` bekommt `harness/conventions`; die drei Bedingungen sind
  dort je einzeln belegt, und der Commit nennt sie einzeln statt pauschal.
  **`docs/plan/carveouts/done` bleibt draußen** (Festlegung 4),
  **`docs/plan/planning/observations/` ebenfalls** — sein Träger ist eine
  `README.md` und keine `.gitkeep` (Festlegung 2), also ein eigener Schnitt (§6).
  **Der Zahn steht schon und wird
  nicht neu gebaut:** `TestTemplates_EmittierterBestandVollstaendig` vergleicht
  den **ganzen** emittierten Baum gegen eine `want`-Liste auf Mengengleichheit,
  und `test/mutations/28-gitkeep-fehlt.sh` ist der kuratierte Fall dazu. Der
  Rot-Nachweis fällt darum im Lauf selbst an: nach der Erweiterung von
  `structureGitkeeps()` ist der Test **rot**, bis `want` nachgezogen ist — diese
  rote Ausgabe wird gelesen und in §7 benannt, nicht übersprungen.
- [ ] **(2) Die zwei Fundstellen auf Orte, die der Bootstrap nicht anlegt,
  bekommen je einen benannten Ausgang.** Die eine ist der baseline-relative
  Vorlagen-Pfad in der emittierten `harness/conventions.md` — er nennt die
  Eintrags-Vorlage unter einem Verzeichnis, das im Ziel nichts trifft; sie liegt
  unter
  [`.harness/baseline/v6.0.0/templates/harness/conventions/`](../../../../.harness/baseline/v6.0.0/templates/harness/conventions/).
  Die andere ist `docs/plan/carveouts/done/` in der emittierten
  `docs/plan/planning/README.md`. Zulässig ist je **ein** Ausgang, ausdrücklich
  gewählt und begründet: den Pfad im emittierten Text auf den vendored Ort
  ausschreiben, die Zeile mit dem Marker stumm schalten, den die Baseline für
  dieselbe Klasse selbst setzt —

  ```sh
  grep -c 'd-check:ignore' \
    .harness/baseline/v6.0.0/templates/docs/plan/carveouts/carveout.template.md   # 1
  ```

  — oder die Nennung umformulieren. **Nicht** zulässig: den vendored Fremdtext
  ändern
  ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache))
  und **keinen** Ausgang wählen — dann bleibt die Fundstelle stehen, und DoD (3)
  fällt.
- [ ] **(3) Gemessen: `codepaths` über dem frischen Ziel meldet 6 → 3 Befunde,
  und die drei Rückstände sind namentlich die des Register-Orts.** Dieselbe
  Messreihe wie in §1, `--lang go` **und** sprachlos. **Der Rot-Nachweis ist der
  Vorher-Lauf**: derselbe Aufruf über dem heutigen Stand meldet **6**; ein
  Nachher-Lauf allein belegt nicht, dass die Änderung gewirkt hat
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). **Die Zusage ist der
  Rückstand, nicht die Null** — wer hier *0 Befunde* schriebe, hätte eine Zahl
  zugesagt, die dieser Zuschnitt nicht erreichen kann, und der nächste Lauf
  senkte sie still ab.
- [ ] `make gates` grün; `make full-smoke` grün (beide Bootstrap-Formen);
  `make mutate` grün über die CI.
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
| `internal/emit/templates.go` (`structureGitkeeps`) | update | das eine Verzeichnis, das Festlegung 1 trägt; die Liste ist tool-definiert und quell-unabhängig, also wächst sie hier und nirgends sonst |
| `internal/emit/templates_test.go` (`want`-Liste) | update | der Mengen-Vergleich ist der Zahn; er wird nachgezogen, nicht aufgeweicht |
| die emittierte `harness/conventions.md` und `docs/plan/planning/README.md` | update | DoD (2) — je ein Ausgang für die Fundstelle; **nur** die emittierte Fassung, nicht der vendored Fremdtext |
| [`spec/lastenheft.md`](../../../../spec/lastenheft.md) | **unverändert** | siehe die Change-Request-Frage unten |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) | **unverändert** | sein §6-Baum ist zusammenfassende Prosa und nennt kein Struktur-Verzeichnis einzeln; er wird von DoD (1) weder wahr noch falsch. Dass er in dieser Form Lücken **verdeckt**, ist ein eigener Liefer-Wert — [slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md), §6 |
| `internal/emit/` — Emission der Register-`README.md` | **nicht in diesem Slice** | entschieden (Festlegung 2), eigener Schnitt — §6 |

**Die Change-Request-Frage ist beantwortet.**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
zählt die Struktur-Verzeichnisse auf: *„Lifecycle-Ordner, ADR-/Carveout-/
Reviews-Ordner"*. `docs/plan/carveouts/done` ist ein Carveout-Ordner und damit
gedeckt; `harness/conventions` ist **keiner der genannten**. Festlegung 1 liest
die Aufzählung als beispielhaft und macht die **Eigenschaft** maßgeblich: die
Aufnahme eines Ortes, der ihre drei Bedingungen erfüllt, **erfüllt**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3),
sie ändert den Vertrag nicht
([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
Gedeckt heißt dabei nicht angelegt: `docs/plan/carveouts/done` scheitert an der
ersten der drei Bedingungen (Festlegung 4) und bleibt draußen.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**`open` → `next`:** die Change-Request-Frage aus §3 ist beantwortet
([`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md)
Festlegung 1), `Verantwortlich:` ist gesetzt. Keine Abhängigkeit von
[slice-073](slice-073-emittierte-doc-gate-module.md) in dieser Richtung — der
Slice hier ist die Grundlage, nicht die Folge.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): falls die Nachmessung
  eine andere Zahl als **3** liefert. Nach oben heißt das, eine Ursache ist
  unerkannt; nach unten, die Messreihe in §1 hat einen Fall doppelt gezählt.
  Beides gehört zurück in den Schnitt, statt DoD (3) still auf „weniger als
  vorher" abzusenken.
- `in-progress` → `open` (blockiert — Carveout?): falls für eine der zwei
  Fundstellen aus DoD (2) kein Ausgang bleibt, der ohne Änderung am vendored
  Fremdtext auskommt. Dann liegt eine Entscheidung vor der Arbeit
  ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)),
  und die ist kein Schritt in diesem Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **(a)** der Vorher/Nachher-Lauf aus DoD (3) liegt
vor — derselbe netzlose d-check-Aufruf über demselben Bootstrap, **6** vorher und
**3** nachher, und die drei sind namentlich benannt; **(b)** `make gates` und
`make full-smoke` grün, `make mutate` grün über die CI.

Dazu: DoD vollständig; Review konform (Modul 10); Verifikation bestätigt
(Modul 11); jedes Risiko aus §6 mit Ausgang; Closure-Notiz mit
Steering-Loop-Lerneintrag; `git mv` nach `done/` als eigener Move-Commit. Den
Abschluss schreibt der **Planner** in frischem Kontext, nicht der Lauf, der die
Arbeit gebaut hat ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Change-Request-Frage aus §3 ist beantwortet.** Die Aufnahme eines Ortes,
  der die drei Bedingungen aus Festlegung 1 erfüllt, ist Erfüllung von
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  und keine Vertragsänderung. — **Ausgang:** <offen>
- **Der Register-Ort ist entschieden und liegt außerhalb dieses Schnitts.**
  Festlegung 2 legt `docs/plan/planning/observations/` beim Init an, und zwar mit
  einer tool-autorierten `README.md` statt einer `.gitkeep`; Festlegung 3 ordnet
  sie *skip-if-present* zu. Der Träger ist damit eine andere Herkunfts-Klasse als
  die `.gitkeep`-Liste aus DoD (1) und wäre hier der vierte Liefer-Punkt. **Der
  Schnitt, der ihn liefert, ist noch nicht geschnitten** — bis dahin bleiben
  seine drei Fundstellen stehen, und `codepaths` ist im Ziel keine Option. —
  **Ausgang:** <offen>
- **Für `docs/plan/carveouts/done/` gibt es keinen Anlege-Weg.** Festlegung 4
  trägt den Ort nicht; `carveout.template.md` schreibt an ihrer eigenen Zeile
  *„done/ entsteht erst bei erster Carveout-Auflösung"* und schaltet sie darum
  mit einem Marker stumm. Die Fundstelle aus `docs/plan/planning/README.md`
  bleibt damit stehen und braucht einen Ausgang (DoD 2); **welchen**, ist
  Umsetzung und steht hier nicht. Bleibt keiner, greift die Rückführung aus §4. —
  **Ausgang:** <offen>
- **Der Beleg deckt das frische Ziel, nicht das gealterte.** `.d-check.yml` und
  der Struktur-Bestand sind *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)); ein bereits gebootstrapptes
  Repo bekommt nichts davon. Das ist die Idempotenz-Klasse, kein Versehen — aber
  die Lücke bleibt dort offen und gehört benannt statt vorausgesetzt. —
  **Ausgang:** <offen>
- **Die Zusagen über die emittierte Modul-Liste stehen woanders und wandern
  nicht mit.** Sechs Einträge des Adaptions-Blocks nennen den emittierten
  Startzustand im Indikativ
  (`git grep -lF 'modules: [links, anchors]' -- 'harness/conventions/*.md' | wc -l`
  → **6**), und ihre Rümpfe sind append-only eingefroren; dazu eine
  Begründungs-Zeile in
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
  die [`AGENTS.md`](../../../../AGENTS.md) §3.4 sperrt. **Dieser Slice bewegt die
  Modul-Liste nicht** und löst die Klasse damit nicht aus — sie trifft
  [slice-073](slice-073-emittierte-doc-gate-module.md), und dort gehört sie
  entschieden, nicht hier gelöst. Registriert als
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
  — **Ausgang:** <offen>
- **Die Beschreibung des emittierten Bestands wird von keinem Sensor gehalten.**
  Der emittierte Baum hat mit `TestTemplates_EmittierterBestandVollstaendig` einen
  Mengen-Vergleich; die **Beschreibung** desselben Bestands in
  [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §6
  hat keinen — sie ist eine zweite, unbewachte Fassung derselben Aussage und
  altert lautlos, wie sie es zwischen `slice-182` und heute getan hat. **Dieser
  Slice baut den Sensor nicht**, und der Grund ist kein Zeitmangel: der §6-Baum
  nennt heute kein einziges Struktur-Verzeichnis einzeln, es gibt also nichts zu
  koppeln — erst muss entschieden werden, *was* er zeigt, dann kann ein Wächter
  ihn halten. Beides zusammen ist ein eigener Liefer-Wert und liegt als
  [slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md) in
  `open/`. Registriert als
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  dessen `state.md` genau diese Unterklasse als *Zusage ohne Anker, Ausgang eine
  Regel ohne Sensor* führt. — **Ausgang:** <offen>
- **Nicht in diesem Slice:** die emittierte Modul-Liste
  ([slice-073](slice-073-emittierte-doc-gate-module.md)), der Handbuch-Baum
  ([slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md)),
  der Register-Ort (Risiko 2), die `.d-check.yml` **dieses** Repos, jeder
  Migrationspfad für bereits gebootstrappte Repos, und jede Änderung am vendored
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
[`internal/emit/`](../../../../internal/emit) und [`test/`](../../../../test)
liegen darunter. Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt daneben `harness/tools/` und `.codex/`; **beide sind nicht berührt** —
keine Fundstelle aus §1 und keine Datei aus §3 liegt dort.

**Vorgelagert — offene Beobachtungen sichten:** Die Ablage
[`observations/`](../observations/README.md) ist durchgegangen; je Slug die Zahl
der `evidence/`-Dateien und die erste Zeile seiner `state.md`:

```sh
for s in emittierte-vorlagen-klassifikation-ohne-traeger \
         zusage-neben-geaenderter-ableitung-bleibt-stehen \
         zusage-ohne-herstellbares-gegenbeispiel \
         vollstaendigkeits-zusage-misst-falsche-ebene; do
  d="docs/plan/planning/observations/BEO-ALL/$s"
  echo "$s $(ls "$d/evidence" | wc -l)x $(head -1 "$d/state.md")"
done
# emittierte-vorlagen-klassifikation-ohne-traeger  2x  **Stand:** offen
# zusage-neben-geaenderter-ableitung-bleibt-stehen 16x **Stand:** geplant
# zusage-ohne-herstellbares-gegenbeispiel          2x  **Stand:** offen
# vollstaendigkeits-zusage-misst-falsche-ebene     1x  **Stand:** offen
```

Keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die vier Einträge des Kommandos berühren diesen Slice, weitere
Treffer: keine.

- [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  — **der Eintrag erreicht mit diesem Slice 3×.** Seine zwei Belege nennen genau
  diese Klasse: `slice-182` fand, dass für die mitemittierte
  `observations/README.md` keine Vorlage existiert; `slice-184`, dass kein
  Emissions-Pfad den Ort anlegt. Der dritte Beleg ist dieser Slice — die Klasse
  ist ein drittes Mal aufgetreten, diesmal für zwei **weitere** Orte. **Der
  Übertritt ist damit erreicht, und der Ausgang ist geteilt:** einen Ort legt
  DoD (1) an, zwei Fundstellen bekommen einen Ausgang statt einer Anlage
  (DoD 2), der Register-Ort liegt in einem eigenen, noch nicht geschnittenen
  Schnitt (§6, Risiko 2). Den Stand setzt der Lese-Schritt der Closure, nicht
  dieser Plan — und er wird für den offenen Teil einen Träger nennen müssen,
  sonst übersteht der Eintrag eine Closure ohne Ausgang.
- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **getroffen**, aber an einer Stelle, die dieser Slice nicht anfasst: der
  §6-Baum des Benutzerhandbuchs beschreibt einen Bestand, den `slice-182`
  verändert hat. Steht als Risiko in §6, Träger ist
  [slice-191](slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md).
  Die Zusagen über die emittierte **Modul-Liste** sind davon verschieden und hier
  nicht berührt — die Liste bewegt dieser Slice nicht.
- [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  — berührt, **nicht getroffen**: für beide Liefer-Punkte ist das Gegenbeispiel
  herstellbar und in DoD (1) und (3) benannt.
- [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  — berührt, weil DoD (3) eine Vollständigkeits-Zusage über eine Fundmenge
  trägt. **Nicht getroffen**, denn gemessen wird auf der Ebene der Fundstelle
  (sechs Zeilen, je Zeile eine Adresse), nicht auf Dateiebene.

**Alle berührten Sub-Areas GF.** Der Modus-Begründungsblock entfällt damit
(§Umfang oben); `*` steht in der Modus-Deklaration als Greenfield, und dieser
Slice führt keine neue Sub-Area ein.

**Ein Wort zum Umfang dieses Plans.** Er hält sich kurz, weil
[`slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
offen im Register steht: die Messreihe aus §1 ist als Kommando abgelegt, nicht
als Erzählung nachgezeichnet.
