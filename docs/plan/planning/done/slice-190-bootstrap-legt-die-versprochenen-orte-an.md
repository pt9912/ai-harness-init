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

Die feste Liste in `structureGitkeeps()` trägt die Orte, die der Bootstrap
anlegt:

```sh
sed -n '/^func structureGitkeeps/,/^}/p' internal/emit/templates.go | grep -c '^\t\t"'   # 7
```

**Kein Erwartungswert**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit der Liste, und die Prosa daneben nennt sie
darum nicht.

Das Beobachtungs-Register und die `done/`-Ablage der Carveouts werden von
emittierten Dateien im Indikativ genannt und entstehen nicht.

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
[slice-073](../done/slice-073-emittierte-doc-gate-module.md), dessen
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

- [x] **(1) Der Bootstrap legt den einen Ort an, den Festlegung 1 trägt.**
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
- [x] **(2) Die zwei Fundstellen auf Orte, die der Bootstrap nicht anlegt,
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
- [x] **(3) Gemessen: `codepaths` über dem frischen Ziel meldet 6 → 3 Befunde,
  und die drei Rückstände sind namentlich die des Register-Orts.** Dieselbe
  Messreihe wie in §1, `--lang go` **und** sprachlos. **Der Rot-Nachweis ist der
  Vorher-Lauf**: derselbe Aufruf über dem heutigen Stand meldet **6**; ein
  Nachher-Lauf allein belegt nicht, dass die Änderung gewirkt hat
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6). **Die Zusage ist der
  Rückstand, nicht die Null** — wer hier *0 Befunde* schriebe, hätte eine Zahl
  zugesagt, die dieser Zuschnitt nicht erreichen kann, und der nächste Lauf
  senkte sie still ab.
- [x] `make gates` grün; `make full-smoke` grün (beide Bootstrap-Formen);
  `make mutate` grün über die CI.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). Dieses Repo führt Wellen-Betrieb; sie liegen damit bei der nächsten Welle-Closure (§7, Posten 3).

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
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) | **unverändert** | sein §6-Baum ist zusammenfassende Prosa und nennt kein Struktur-Verzeichnis einzeln; er wird von DoD (1) weder wahr noch falsch. Dass er in dieser Form Lücken **verdeckt**, ist ein eigener Liefer-Wert — [slice-191](../open/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md), §6 |
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
[slice-073](../done/slice-073-emittierte-doc-gate-module.md) in dieser Richtung — der
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
  und keine Vertragsänderung. — **Ausgang:** entfallen — gestrichen: die Frage ist beantwortet und
  kann nicht mehr eintreten.
  [`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) Festlegung 1 steht auf
  `Accepted` und trifft die Einordnung selbst; die Verifikation hat §3 gegen sie gehalten und
  Deckung festgestellt, und
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) ist unberührt geblieben
  (`git diff --stat 711d92cb^..HEAD -- spec/lastenheft.md` ist leer).
- **Der Register-Ort ist entschieden und liegt außerhalb dieses Schnitts.**
  Festlegung 2 legt `docs/plan/planning/observations/` beim Init an, und zwar mit
  einer tool-autorierten `README.md` statt einer `.gitkeep`; Festlegung 3 ordnet
  sie *skip-if-present* zu. Der Träger ist damit eine andere Herkunfts-Klasse als
  die `.gitkeep`-Liste aus DoD (1) und wäre hier der vierte Liefer-Punkt. **Der
  Schnitt, der ihn liefert, ist noch nicht geschnitten** — bis dahin bleiben
  seine drei Fundstellen stehen, und `codepaths` ist im Ziel keine Option. —
  **Ausgang:** eingetreten →
  [slice-194](../done/slice-194-bootstrap-legt-den-register-ort-an.md). Die drei Rückstände der
  Messreihe sind namentlich seine; der Schnitt ist mit dieser Closure gezogen und liegt in
  `open/`.
- **Für `docs/plan/carveouts/done/` gibt es keinen Anlege-Weg.** Festlegung 4
  trägt den Ort nicht; `carveout.template.md` schreibt an ihrer eigenen Zeile
  *„done/ entsteht erst bei erster Carveout-Auflösung"* und schaltet sie darum
  mit einem Marker stumm. Die Fundstelle aus `docs/plan/planning/README.md`
  bleibt damit stehen und braucht einen Ausgang (DoD 2); **welchen**, ist
  Umsetzung und steht hier nicht. Bleibt keiner, greift die Rückführung aus §4. —
  **Ausgang:** entfallen — gestrichen: ein Ausgang war da, die Rückführung ist nicht gezogen
  worden. Gewählt ist der Ignore-Marker in der Form, die `carveout.template.md` für denselben Ort
  selbst führt; die Verifikation hat ihn am emittierten Baum gegengelesen, und die Fundstelle ist
  aus der 6 → 3-Differenz verschwunden.
- **Der Beleg deckt das frische Ziel, nicht das gealterte.** `.d-check.yml` und
  der Struktur-Bestand sind *skip-if-present*
  ([`ADR-0007`](../../adr/0007-bootstrap-phasen.md)); ein bereits gebootstrapptes
  Repo bekommt nichts davon. Das ist die Idempotenz-Klasse, kein Versehen — aber
  die Lücke bleibt dort offen und gehört benannt statt vorausgesetzt. —
  **Ausgang:** weiter offen → Beobachtungs-Register,
  [`BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md)
  (mit dieser Closure angelegt, Beleg `evidence/slice-190.md`).
- **Die Zusagen über die emittierte Modul-Liste stehen woanders und wandern
  nicht mit.** Sechs Einträge des Adaptions-Blocks nennen den emittierten
  Startzustand im Indikativ
  (`git grep -lF 'modules: [links, anchors]' -- 'harness/conventions/*.md' | wc -l`
  → **6**), und ihre Rümpfe sind append-only eingefroren; dazu eine
  Begründungs-Zeile in
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
  die [`AGENTS.md`](../../../../AGENTS.md) §3.4 sperrt. **Dieser Slice bewegt die
  Modul-Liste nicht** und löst die Klasse damit nicht aus — sie trifft
  [slice-073](../done/slice-073-emittierte-doc-gate-module.md), und dort gehört sie
  entschieden, nicht hier gelöst. Registriert als
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md).
  — **Ausgang:** weiter offen → Beobachtungs-Register, ebendort (Beleg `evidence/slice-190.md`
  mit dieser Closure ergänzt). Die Entscheidung über die Modul-Liste bleibt bei
  [slice-073](../done/slice-073-emittierte-doc-gate-module.md).
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
  [slice-191](../open/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md) in
  `open/`. Registriert als
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md),
  dessen `state.md` genau diese Unterklasse als *Zusage ohne Anker, Ausgang eine
  Regel ohne Sensor* führt. — **Ausgang:** eingetreten →
  [slice-191](../open/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md). Die
  Beschreibung ist zwischen `slice-182` und heute gealtert, ohne dass etwas rot wurde; der
  Folge-Slice ist eine Datei in `open/` und trägt beide Hälften — was der §6-Baum zeigt und welcher
  Wächter ihn hält.
- **Eingefrorene Artefakte adressieren wandernde Lifecycle-Dateien als Pfad, und
  der Verweis-Nachzug beim Ortswechsel schreibt sie um.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.11 verlangt in einem Artefakt, das
  unveränderlich wird, die **Kennung** statt der Pfad-Adresse, und vor jedem
  vorgeschriebenen Ortswechsel eine Messung über beide Adress-Formen;
  `make slice-mv` ersetzt eingehende Verweise repo-weit außer
  `.harness/baseline/**` und nimmt weder `docs/reviews/**` noch
  `docs/plan/planning/done/**` aus. Die Menge über die einfrierenden Artefakte
  dieses Repos — ADR ab `Accepted` · Rollen-Report · Zeitdokument in `done/` —,
  ortsfeste Ziele wie die Roadmap ausgenommen:

  ```sh
  frozen() { { grep -l '^\*\*Status:\*\* Accepted' docs/plan/adr/[0-9]*.md
               ls docs/reviews/*.md docs/plan/planning/done/*.md; } ; }
  ortsfest='in-progress/roadmap\.md'
  frozen | wc -l                                                        # 486  Bezugsmenge
  frozen | xargs grep -ohE '\]\([^)]*planning/(open|next|in-progress|welle-)[^)]*\.md\)' | grep -vc "$ortsfest"   #  40  Markdown-Link
  frozen | xargs grep -ohE '`[^`]*planning/(open|next|in-progress|welle-)[^`]*\.md`'     | grep -vc "$ortsfest"   # 328  Code-Span
  ls docs/reviews/*.md | xargs grep -ohE '`[^`]*planning/(open|next|in-progress|welle-)[^`]*\.md`' | grep -vc "$ortsfest"   # 298
  ```

  **Keine Erwartungswerte**
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Für denselben Baum stehen zwei Antworten nebeneinander, und welche
  gilt, entscheidet die Adress-Form: `codepaths` nimmt `docs/reviews/**`
  datei-weit aus — die letzte Zahl ist der stumme Anteil der vorletzten —, `links`
  trägt gar keine Options-Sektion
  (`grep -cE '^(links|anchors):' .d-check.yml` → **0**), und dort greift
  stattdessen der Nachzug. Ein Referenz-Ventil ist für diese Breite keine Option:
  die vier Paare in [`.d-check.yml`](../../../../.d-check.yml) schneiden `in` und
  `refs` je auf **eine** benannte Datei, und jede Verbreiterung auf ein
  Verzeichnis ist eine eigene Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5. Die Frage ist damit eine Norm-Frage
  über Gate-Config und Hard Rule und gehört an den **Architect**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8), nicht in diesen Slice. —
  **Ausgang:** weiter offen → Beobachtungs-Register,
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  (mit dieser Closure angelegt, Beleg `evidence/slice-190.md`). Die zwei benachbarten Einträge
  decken den Fall nicht: dort bricht der Verweis bzw. stirbt die Adresse, hier bleibt sie gültig
  und das eingefrorene Artefakt wird geschrieben.
- **Der `next` → `in-progress`-Move schreibt zwei Artefakte, für die keine Quelle
  dieses Repos einen Träger nennt.** Er macht den vom Modul `planning` bewachten
  Ruhe-Marker der Roadmap falsch, und sein Commit trägt eine Traceability-ID
  ([`AGENTS.md`](../../../../AGENTS.md) §5); *welcher* Schritt den Marker
  ausgleicht und *welche* Kennung eine reine Planungs-Zustandsänderung trägt,
  steht in keinem Anweisungssatz und in keinem Werkzeug. Registriert als
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md).
  — **Ausgang:** weiter offen → Beobachtungs-Register, ebendort (Beleg `evidence/slice-190.md`
  mit dieser Closure ergänzt).
- **Der emittierte Text nennt die Eintrags-Vorlage ohne Adresse.** Der für die
  erste Fundstelle aus DoD (2) gewählte Ausgang entfernt die Pfad-Form; ein
  Adopter liest danach, *dass* eine Eintrags-Vorlage existiert, nicht *wo* sie
  liegt — real unter
  [`.harness/baseline/v6.0.0/templates/harness/conventions/`](../../../../.harness/baseline/v6.0.0/templates/harness/conventions/).
  Den tag-gebundenen Pfad auszuschreiben verlangt den Tag in der Signatur von
  `emit.Templates`; der Aufrufer führt ihn
  (`grep -c 'tag := envOr' cmd/ai-harness-init/main.go` → **1**), die Funktion
  nimmt ihn nicht entgegen. DoD (2) lässt alle drei Ausgänge zu, dieser
  eingeschlossen; ob dem Adopter die Adresse fehlt, ist damit nicht entschieden.
  — **Ausgang:** weiter offen → Beobachtungs-Register,
  [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
  (mit dieser Closure angelegt, Beleg `evidence/slice-190.md`).
- **Nicht in diesem Slice:** die emittierte Modul-Liste
  ([slice-073](../done/slice-073-emittierte-doc-gate-module.md)), der Handbuch-Baum
  ([slice-191](../open/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md)),
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

**Rolle:** Planner (Baseline-Regelwerk `modul-05-planning-harness.md` §Closure- und
Lerneintrag-Regeln). **Datum:** 2026-09-07. **Gegenstand:** die Commit-Kette von `711d92cb`
(Lifecycle-Übergang) bis `74dbbb83` (Verifikation).

**Woher die Zahlen unten stammen, und zwar getrennt.** Jede Zahl, die neben ihrem Kommando steht,
ist **in diesem Lauf** erhoben
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). **Zwei stehen ohne eigenes Kommando da und sind übernommen:** die **6** und die **3**
der Messreihe aus DoD (3). Sie sind nicht die des umsetzenden Laufs, sondern die der
**Verifikation**, die sie über einen eigenen `git worktree` unabhängig reproduziert hat
([`2026-09-07-slice-190-bootstrap-orte-verify.md`](../../../reviews/2026-09-07-slice-190-bootstrap-orte-verify.md));
diese Closure hat sie nicht ein drittes Mal gefahren. Ein dritter Lauf hätte die Zusage nicht
weiter belastet — er hätte dieselbe Messstelle ein drittes Mal abgelesen.

- **Was hat funktioniert: die Zusage war der Rückstand, nicht die Null.** DoD (3) hat den Wert
  zugesagt, den dieser Zuschnitt erreichen kann — **3** verbleibende Fundstellen, namentlich
  benannt —, statt der Null, die erst ein weiterer Schnitt liefert. Das hat zwei Dinge getragen,
  die sonst auseinanderfallen: Die Verifikation konnte die Zusage **unabhängig reproduzieren**,
  weil sie eine Zahl und eine Namensliste prüfte statt eines Erfolgs; und der offene Rest hatte
  beim Schneiden des Folge-Slice bereits seine Adresse. Eine zugesagte Null hätte der nächste Lauf
  still abgesenkt, und niemand hätte gesehen, an welcher Stelle.
  Ebenso getragen hat der **Rot-Nachweis als Vorher-Lauf**: derselbe Aufruf über dem Stand vor der
  Implementierung meldet **6**. Ohne ihn belegte der Nachher-Lauf nur einen Zustand, nicht eine
  Wirkung.
- **Was ging anders als geplant — die Deckungsfrage wurde an der falschen Gate-Config
  beantwortet.** Zwei neue Funktionsköpfe sagten zu, Wortlaut-Drift im vendored Fremdtext fange
  `make smoke` auf. Der dort ausgewertete Lauf ist das Doku-Gate **des emittierten Ziels**, und
  dessen Modul-Liste ist eine andere als die dieses Repos:

  ```sh
  grep -n '^modules:' .d-check.yml
  # modules: [links, anchors, ids, matrix, codepaths, spans, planning]
  grep -n '^modules:' internal/emit/templates/d-check.yml
  # modules: [links, anchors]
  ```

  **Keine Erwartungswerte.** Die zwei Defekte sind Inline-Code-Pfade, die allein `codepaths`
  liest — der benannte Auffang sieht genau die Form nicht, um die es geht. Der Fehler ist nicht
  Nachlässigkeit, sondern eine Ebenen-Verwechslung an einer Stelle, an der beide Ebenen dieselben
  Werkzeugnamen führen: Wer im Dogfood sitzt und fragt *„deckt ein Sensor das?"*, hat die
  Dogfood-Config vor sich und die Ziel-Config im Kopf.
- **Was der Review beitrug** (dritte Quelle nach Baseline-Regelwerk `modul-05-planning-harness.md`
  §Closure- und Lerneintrag-Regeln):
  [`2026-09-06-slice-190-bootstrap-orte-review.md`](../../../reviews/2026-09-06-slice-190-bootstrap-orte-review.md)
  — **blockierend, 3 HIGH und 1 MEDIUM.** Die **Sache** des Slice hat er unabhängig getragen: die
  drei Bedingungen für `harness/conventions`, die zwei ausgeschlossenen Orte, der unberührte
  vendored Baum, die Wiring-Proben als Ausgabe-Eigenschaft statt Implementierungsdetail. Blockiert
  haben Aussagen **neben** der Sache. HIGH-1 (falsche Sensor-Zuschreibung), HIGH-2 (ein
  Code-Beleg, den sein eigenes abgedrucktes Kommando widerlegt) und MEDIUM-1 (zwei neue Wächter
  ohne kuratierten Mutations-Fall) sind aufgelöst; die zwei neuen Fälle sind einzeln rot gesehen.
  HIGH-3 betrifft einen bereits vollzogenen Move und ist eine Norm-Frage — er hat keinen Ausgang
  im Code, sondern einen im Register (§6). LOW-1 ist in `git` festgeschrieben und nicht mehr
  korrigierbar.
- **Der offene Punkt der Verifikation ist geschlossen, und zwar durch einen Lauf, nicht durch eine
  Auslegung.** Die DoD verlangt `make mutate` **über die CI**; der Lauf zum Planner-Commit war von
  einem späteren, slice-fremden Push verdrängt worden (`ci.yml` fährt
  `concurrency: cancel-in-progress: true`), sodass für jenen Stand kein abgeschlossener Lauf
  existierte. Der Lauf über dem Stand, auf dem diese Closure aufsetzt, ist vollständig grün:

  ```sh
  gh run view 34079012052 --json conclusion,jobs \
    -q '.conclusion, (.jobs[] | .name + ": " + .conclusion)'
  # success
  # smoke: success
  # mutate: success
  # gates: success
  # full-smoke: success
  ```

  Der Baum dieses Laufs enthält alle Commits des Slice. Die Zusage ist damit an ihrer eigenen
  Quelle belegt, und die zwei lokalen `mutate`-Läufe aus Umsetzung und Verifikation stehen daneben
  als das, was sie sind: übereinstimmende Vorbefunde, nicht der geschuldete Beleg.
- **Die Entscheidung vor dem `git mv` nach `done/` — gemessen, dann getroffen.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.11 Absatz 2 verlangt vor einem vorgeschriebenen
  Ortswechsel die Messung über **beide** Adress-Formen, weil sie auf verschiedene Module des
  Doku-Gates fallen, und stellt die Entscheidung vor den Move. Über die einfrierenden Artefakte
  dieses Repos — ADR ab `Accepted` · Rollen-Report · Zeitdokument in `done/` —:

  ```sh
  datei='slice-190-bootstrap-legt-die-versprochenen-orte-an.md'
  frozen() { { grep -l '^\*\*Status:\*\* Accepted' docs/plan/adr/[0-9]*.md
               ls docs/reviews/*.md docs/plan/planning/done/*.md; } ; }
  frozen | wc -l                                        # 487  Bezugsmenge
  frozen | xargs grep -ln "]([^)]*$datei)"               # 2    Markdown-Link
  frozen | xargs grep -ln "\`[^\`]*$datei\`"             # 0    Code-Span
  ```

  **Keine Erwartungswerte.** Die zwei sind
  [`2026-09-06-adr-0037-konsistenz-review.md`](../../../reviews/2026-09-06-adr-0037-konsistenz-review.md)
  und
  [`2026-09-06-slice-123-history-range-guard-review.md`](../../../reviews/2026-09-06-slice-123-history-range-guard-review.md)
  — dieselben zwei, die der Review als HIGH-3 nennt.

  **Entschieden: der Nachzug läuft.** Von den drei Wegen ist nur einer heute gangbar. Den Nachzug
  für `docs/reviews/**` abzuschalten hieße, die Ausnahmeliste von `make slice-mv` zu ändern, und
  ein Referenz-Ventil je Datei zu setzen wäre eine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 — beides Norm-Arbeit am Werkzeug und an der
  Gate-Config, die dem **Architect** gehört (§3.8) und die genau der offene Punkt in §6 ist. Den
  Move zu unterlassen ist keine Option: der Zustand **ist** die Verzeichnis-Position. Bleibt der
  Nachzug, und er ist die kleinere Beschädigung — er hält die Verweise auflösbar, statt zwei
  eingefrorene Reports mit toten Adressen zurückzulassen. **Der Preis steht dabei und wird nicht
  weggeredet:** zwei nach §3.4 unveränderliche Artefakte werden byte-geändert, und im
  Konsistenz-Report steht danach erneut ein Link-Pfad neben einer Prosa-Angabe, die ihm
  widerspricht. Gebucht als
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md).
- **Was diese Closure nicht deckt — vier Posten, benannt statt still.** Dieses Repo führt
  **Wellen-Betrieb**, und *wellenlos* ist nach Baseline-Regelwerk `modul-06-roadmap.md` §Wann
  Arbeit eine Welle braucht eine Eigenschaft des **Repos**, nicht des einzelnen Slice — die eigene
  [`README.md`](../observations/README.md) des Registers sagt dasselbe für den Lese-Schritt
  ausdrücklich. Gemessen: `ls docs/plan/planning/welle-*.md | wc -l` → **3** (kein
  Erwartungswert). Die Tabelle *Träger im Repo ohne Wellen* greift hier also nicht.
  **(1) Der Lese-Schritt — für den einen Eintrag über der Schwelle hier, für den Rest dort.**
  [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  erreicht mit dem Beleg dieses Slice **3×**. Ihn `offen` liegen zu lassen, bis eine Welle
  schließt, wäre der write-only-Zustand, den `modul-06-roadmap.md` §Das Beobachtungs-Register
  ausschließt — *„Nicht zulässig ist ein Eintrag, der eine Closure ohne Ausgang übersteht"* —, und
  der Ausgang ist ohne Rollen-Grenzverletzung erreichbar. Gesetzt ist **`geplant`**, Kennung
  `slice-194`. *Verkörpert* wäre zu viel: Das Kriterium **steht** zwar, vom Architect als
  [`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) geschrieben — aber der
  Ausgang *verkörpert* verlangt einen Zielort, der den Herkunfts-Anker **trägt**, und ein ab
  `Accepted` unveränderliches Artefakt kann ihn nicht mehr aufnehmen
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Schritt 3b der Rollen-Sequenz
  (Planner → Architect → Planner) wird dabei nicht ausgelöst: Diese Closure **schreibt** keine
  Regel, sie erkennt den Übertritt und bucht.
  **Alles unter der Schwelle liest diese Closure nicht** — das ist der Sichtungs-Schritt der
  nächsten Slice-Planung (§8) bzw. der Lese-Schritt der nächsten Welle-Closure für alles, was
  später übertritt.
  **(2) Das Trigger-Audit ist gemessen, aber nicht eingetragen** — es ist Schritt 2 der
  Wellen-Closure. Zwei Carveouts (`ls docs/plan/carveouts/CO-*.md | wc -l` → **2**), beide mit
  gesetztem Ausgang: [CO-001](../../carveouts/CO-001-bats-shell-lint.md) aktiv mit eingetretenem
  Auflösungs-Trigger, Ausgang *verlängert mit Folge-Slice*;
  [CO-002](../../carveouts/CO-002-token-achse-je-rolle.md) permanent. Ein bootstrap-aware Gate
  führt der Dogfood nicht. Bei den ADRs ist der erste Re-Evaluierungs-Trigger von
  [`ADR-0036`](../../adr/0036-ziel-fassung-regiert-den-sprung-v600.md) gefeuert; die Antwort ist
  [`ADR-0038`](../../adr/0038-ziel-fassung-regiert-den-sprung-v650.md) und liegt beim Architect.
  **(3) Die drei Paarungen prüft die Welle-Closure** (letzter DoD-Punkt). Als Vorlauf sind sie
  hier trotzdem gefahren, weil sie read-only sind: **(a)** hat keinen Gegenstand — §7 trägt kein
  Pflichtfeld `liegt in <Zielort>`, der Steering-Loop-Eintrag ist gezählt und nicht verkörpert;
  **(b)** löst jede in dieser Datei genannte Slice-Kennung im Lifecycle auf, `slice-194` und
  `slice-191` als Dateien in `open/`; **(c)** findet jeden zitierten `BEO-ALL/<slug>` im Register.
  Die zweite Hälfte von (c) hat einen Rückstand **außerhalb** dieses Slice gefunden: zwei
  Verzeichnisse führen kein `evidence/`
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do [ -d "$d/evidence" ] || echo "$d"; done | wc -l`
  → **2**, kein Erwartungswert). Beide tragen einen *Benannt, nicht gezählt*-Abschnitt, sind also
  gewollt beleglos — die maschinelle Hälfte *jede Zeile trägt mindestens einen Beleg* trifft sie
  trotzdem. Ob die Prüfung oder die Form nachzieht, entscheidet nicht diese Closure.
  **Ein zweiter Rückstand aus demselben Vorlauf, und er wiegt schwerer:** zwei Einträge stehen bei
  **3×** und tragen weiter `offen` —

  ```sh
  for d in docs/plan/planning/observations/BEO-ALL/*/; do
    n=$(ls "$d/evidence"/*.md 2>/dev/null | wc -l); s=$(head -1 "$d/state.md")
    [ "$n" -ge 3 ] && [ "$s" = "**Stand:** offen" ] && echo "$(basename $d) $n"
  done
  # zaehler-label-nennt-falsche-einheit 3
  # zitat-grep-uebersieht-zeilenumbruch-und-markup 3
  ```

  **Keine Erwartungswerte.** Beide sind **nicht** von diesem Slice gehoben und liegen thematisch
  außerhalb; ihren Ausgang zu setzen hieße, über fremde Gegenstände zu urteilen. Sie stehen damit
  in genau dem Zustand, den `modul-06-roadmap.md` als unzulässig bezeichnet, und sind die
  Instanzen, an denen
  [`schwellen-uebertritt-ohne-zustaendige-rolle`](../observations/BEO-ALL/schwellen-uebertritt-ohne-zustaendige-rolle/observation.md)
  *(„die Zeile bleibt ohne Ausgang stehen und wird von der nächsten Closure geerbt")* real wird —
  hier benannt, damit die nächste Closure sie nicht suchen muss.
  **(4) Archiviert wird nicht.** Die Archivierung ist Schritt 4 derselben Wellen-Closure, und
  `make archive-welle` ist auf diesen Bestand ohnehin nicht anwendbar: die Sperren `untergrenze`
  (`ls docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l` → **0**) und `haenger` stehen.
  Kein `done/slice-190-archiv.zip` also, und das ist eine Entscheidung, keine Auslassung.
- **Steering-Loop-Eintrag — Schwellen-Übertritt, Ausgang `geplant`:** *Ob der Bootstrap einen Ort
  anlegt, entscheidet die **Eigenschaft** — nennt ein mitemittierter Text ihn für ein frisches Repo
  im Indikativ, entsteht er ohne den Bootstrap nicht, und erzeugt sein Anlegen keinen
  Platzhalter-Link —, nicht die Namensliste des Lastenhefts.* Auslöser:
  [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  (`slice-182`, `slice-184`, `slice-190` — 3×), Kennung `slice-194`.
  *Kein `liegt in`, und der Grund ist nicht Bequemlichkeit:* Das Kriterium **steht** — der
  Architect hat es als
  [`ADR-0037`](../../adr/0037-bootstrap-stellt-den-tag-0-zustand-her.md) geschrieben —, aber eine
  ADR ist eine Entscheidung und kein Zielort einer Verkörperung, und *verkörpert* verlangt einen
  Zielort, der den Herkunfts-Anker **trägt**; ein ab `Accepted` unveränderliches Artefakt kann ihn
  nicht mehr aufnehmen ([`AGENTS.md`](../../../../AGENTS.md) §3.4). Offen ist damit die Anwendung,
  und die trägt eine Kennung.
- **Steering-Loop-Eintrag — geschärfte Regel, gezählt:** *Wer in einem Dogfood-Artefakt einen Sensor als
  Auffang benennt, dessen Lauf im **emittierten Ziel** stattfindet, misst die Deckung an der
  Gate-Config des Ziels — nicht an der, die er vor sich hat.* Die zwei Konfigurationen sind
  verschiedene Dateien mit verschiedenen Modul-Listen, und die Werkzeugnamen sind auf beiden
  Ebenen dieselben; genau das macht die Verwechslung lautlos. Der Prüfschritt ist zwei Kommandos
  lang und steht oben. Auslöser:
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (**8×**, Stand `geplant`/`slice-181`). *Gezählt, nicht verkörpert:* Die Regel ist hier
  formuliert, nicht geschrieben — ihr Zielort wäre ein Norm-Artefakt, und das gehört dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Das Feld `liegt in` entfällt darum.
- **Beobachtungs-Register (`../observations/`):** **sieben** Belege, davon fünf aus dem Review;
  **drei** neue Verzeichnisse. Jeder Zähler ist die Zahl der Dateien unter `evidence/`
  (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`) — keine Erwartungswerte,
  sie wandern mit dem Register:
  [`emittierte-vorlagen-klassifikation-ohne-traeger`](../observations/BEO-ALL/emittierte-vorlagen-klassifikation-ohne-traeger/observation.md)
  **3×** — Schwelle erreicht, Stand mit dieser Closure von `offen` auf **geplant** gesetzt
  (Kennung `slice-194`; warum nicht *verkörpert*, und die Sensor-Grenze, stehen in seiner
  `state.md`) ·
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  **8×** (HIGH-1) ·
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  **17×** — **ein** Beleg für HIGH-2 und LOW-2 zusammen, weil zwei Funde in **einem** Vorgang eine
  Gelegenheit sind ·
  [`lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  **2×** (INFO-1) ·
  [`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  **1×**, neu (HIGH-3) — die zwei Nachbarn decken ihn nicht: dort bricht der Verweis bzw. stirbt
  die Adresse, hier bleibt sie gültig und das eingefrorene Artefakt wird geschrieben ·
  [`idempotente-anlage-erreicht-den-bestand-nicht`](../observations/BEO-ALL/idempotente-anlage-erreicht-den-bestand-nicht/observation.md)
  **1×**, neu (§6) ·
  [`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
  **1×**, neu (INFO-2).
  **Geprüft und ausdrücklich *nicht* gebucht:**
  [`schwellen-uebertritt-ohne-zustaendige-rolle`](../observations/BEO-ALL/schwellen-uebertritt-ohne-zustaendige-rolle/observation.md)
  (**2×**) beschreibt den Übertritt, dessen Ausgang *„eine Handlung verlangt, die der Rolle dieser
  Closure nicht zusteht"*, sodass *„die Zeile ohne Ausgang stehen bleibt und von der nächsten
  Closure geerbt wird"*. Genau das ist hier **nicht** eingetreten: Der Ausgang `geplant` mit
  Kennung stand der Planner-Rolle offen, und die Zeile wird nicht vererbt. Der Eintrag als dritte
  Instanz zu buchen hieße, die Beobachtung an der Frage festzumachen statt an ihrem Ausgang — der
  Zähler misst, was **eingetreten** ist.
- **Folge-Slices:**
  [slice-194](../done/slice-194-bootstrap-legt-den-register-ort-an.md) (Der Bootstrap legt den
  Register-Ort an) — mit dieser Closure geschnitten, ist eine Datei in `open/` ·
  [slice-191](../open/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md)
  (Benutzerhandbuch zeigt den vollständigen Bestand) — lag bereits in `open/`.
- **Risiken aus §6:** alle **neun** mit genau einem Ausgang — **2** eingetreten (Folge-Slice
  `slice-194` bzw. `slice-191`), **2** entfallen mit Begründung, **5** weiter offen ins
  Beobachtungs-Register. Gemessen: `grep -c 'Ausgang:\*\* <offen>'` über dieser Datei → **0**.
- **Drei Paarungen:** verbindlich nicht hier — dieses Repo führt Wellen-Betrieb, und sie sind Teil
  der Wellen-Closure (letzter DoD-Punkt). Als read-only-Vorlauf sind alle drei trotzdem gefahren
  und tragen; ihr Ergebnis und der eine Rückstand außerhalb dieses Slice stehen oben unter
  Posten (3).

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
  [slice-191](../open/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md).
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
