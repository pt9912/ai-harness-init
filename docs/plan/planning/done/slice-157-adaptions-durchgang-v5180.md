# Slice slice-157: Adaptions-Durchgang gegen `v5.18.0` — Delta **und** Volltext

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-14](welle-14-re-baseline.md).

**Bezug:** [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 4: jeder
Eintrag bekommt seinen Ausgang **einzeln, mit eigenem Beleg**),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Architect (pt9912) — der Liefergegenstand ist der Adaptions-Speicher, den [`AGENTS.md`](../../../../AGENTS.md) §3.8 dieser Rolle zuweist.

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Jeder Eintrag des Adaptions-Blocks trägt einen der fünf Ausgänge gegen `v5.18.0`, mit eigenem
Beleg — und der Durchgang hält jeden Eintrag gegen den *Volltext* des Zielstands, nicht nur gegen
das Delta.** Die Volltext-Hälfte ist die Auflage aus `BEO-013` ([Register](../observations.md)):
ein Delta-Durchgang findet eine Deckung nicht, die ein Volltext-Durchgang fände, und die
Fehlerrichtung ist *bleibt gültig* statt *gegenstandslos*.

Der Katalog in [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9 nennt vier
Positionen, die hier zusammenlaufen: die `MR-<NNN>`-Glossarzeile, der umbenannte Abschnitt
§Referenz-Implementierung → §Das vollständige Artefakt-Set (er trägt die von
[`MR-005`](../../../../harness/conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)
ersetzte Regel und den von
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
zitierten Anker), die Mount-Freistellung des Gate-Fragments
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)) und
der Wegfall des `Status:`-Feldes in der Eintrags-Vorlage
([`MR-020`](../../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Inventar gegen Abdeckung:** die Bezugsmenge ist als Kommando ausgewiesen, und **jeder**
      Eintrag darin trägt genau einen der fünf Ausgänge mit eigenem Beleg. Keine Pauschale.
- [x] **Volltext-Hälfte belegt:** je Eintrag ist nicht nur das Delta, sondern der Zielstand-Text
      der ersetzten Regel gelesen; die vier Katalog-Positionen oben sind namentlich verbucht.
- [x] **Übergabe an den Architect benannt:** die Positionen, die keine `MR`-Antwort haben,
      sondern eine Hard-Rule-Nachbarschaft — die Push-Disziplin aus `grundlagen-traceability.md`
      (*„Beide Commits gehören in denselben Push"*) neben
      [`AGENTS.md`](../../../../AGENTS.md) §3.3 — stehen als Übergabe im Plan, nicht als
      Entscheidung.
- [x] `make gates` grün.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt — keiner berührt: der Adaptions-Speicher wächst um einen Eintrag, [`AGENTS.md`](../../../../AGENTS.md) und die Spec-Straten bleiben unverändert.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| dieser Plan, §9 | update | trägt das Durchgangs-Protokoll je Eintrag |
| `harness/conventions.md` | update | die Ausgänge — Architect, eigener Commit |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-156](../done/slice-156-baum-tauschen-pins-ziehen.md) liegt in
`done/` — der Ist-Maßstab ist `v5.18.0`, und die Trennung *Prozedur ≠ Ist-Maßstab*
([`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2) ist damit
aufgelöst.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Volltext-Hälfte über die
  Bezugsmenge hinaus nicht in einem Lauf zu tragen ist — dann wird der Durchgang nach
  Eintrags-Bereichen geteilt.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein Eintrag nur mit einer Entscheidung
  auflösbar ist, die eine eigene ADR verlangt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; jeder Eintrag der ausgewiesenen Bezugsmenge trägt einen Ausgang; Closure-Notiz
mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Achse 1 wird mit dem Kurzschluss beantwortet** — *„die Baseline behandelt jetzt dasselbe
  Thema"* statt *„der neue Text erfüllt genau die Pflicht, für die der Eintrag entstand"*; die
  Klasse liegt als `BEO-008` im [Register](../observations.md). — **Ausgang: weiter offen →
  Beobachtungs-Register.** Die Klasse ist in diesem Durchgang **nicht** aufgetreten: Jeder der
  47 Einträge trägt in §9 die Pflicht, an der er gemessen ist, nicht das Thema — der eine
  Nicht-*bleibt-gültig*-Ausgang ([`MR-005`](../../../../harness/conventions.md#mr-005)) hängt an drei Messungen über den Pfad selbst. `BEO-008`
  bleibt bei **1×**; ein ausgebliebenes Auftreten erhöht keinen Zähler.
- **Der Delta-Durchgang findet eine Deckung nicht** — `BEO-013`, die Auflage dieses Slice.
  — **Ausgang: weiter offen → Beobachtungs-Register.** Die Auflage ist gefahren (§9 §Methode:
  gelesen wird der Volltext des zitierten Abschnitts), und die Klasse ist nicht aufgetreten —
  kein Eintrag bekam *bleibt gültig*, wo der Zielstand seine Pflicht selbst führt. `BEO-013`
  bleibt bei **1×**. **Was der Durchgang stattdessen fand, ist die Spiegel-Klasse:** ein Muster
  über ein Zitat trifft den Satz nicht, der wörtlich dasteht — neu als `BEO-021`.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die Verzeichnis-Form macht den Durchgang mechanisch durchgehbar — je
  Eintrag eine Datei mit eigenem Feld `Ersetzt-Baseline-Regel`, statt einer 3000-Zeilen-Datei, aus
  der die Bezugsmenge erst herauszulesen wäre. Und die Einträge tragen ihre eigenen
  Mess-Kommandos: für die 24 Fork-Einträge ist der Zielstand-Test das Nachfahren des Kommandos,
  das der Eintrag selbst nennt.
- **Was ging anders als geplant:** Der Durchgang erwartete Ausgänge der Klasse *gegenstandslos*
  (so lief der Sprung auf `v5.12.0`, [`MR-036`](../../../../harness/conventions.md#mr-036) und
  [`MR-041`](../../../../harness/conventions.md#mr-041)). Gefunden wurde stattdessen genau ein
  Ausgang, und zwar der vierte: **Bezug entfallen**. Die Baseline hat die Frage nicht anders
  beantwortet, sondern fallen lassen — was den Träger der Setzung wechselt, nicht ihren Inhalt.
- **Steering-Loop-Eintrag:** Regel geschärft: *Ein `grep` über ein Zitat belegt nicht, dass der
  Satz fehlt* — gegen einen Baseline-Satz zählt der gelesene Abschnitt, nicht das Muster.
  Auslöser: `BEO-021` (slice-157 — 1×). *Gezählt, nicht verkörpert:* die Schwelle ist nicht
  erreicht, also entfällt das Feld `liegt in`.
- **Beobachtungs-Register (`../observations.md`):** neue `BEO-021` angelegt (`*` (gesamtes Repo),
  1×, Beleg slice-157); `BEO-003` auf **3×** erhöht, Beleg slice-157 ergänzt — der `open/` →
  `in-progress/`-Move dieses Slice brach den präfixlosen Verweis in
  [slice-165](../done/slice-165-praesens-aussagen-gegen-v5180.md), also genau die Hälfte, die
  `make slice-mv` als Grenze 3 offen führt. Der Lese-Schritt bei 3× steht in der Zeile: keine
  verkörperbare Regel, der Ausgang ist ein Werkzeug-Schnitt und damit Planner-Arbeit.
  `BEO-008` und `BEO-013` unverändert bei 1× (§6).
- **Folge-Slices:** keine geschnitten. Zwei Posten gehen ohne Kennung weiter, beide an den Planner:
  die zweite Ersetzungs-Regel für `make slice-mv` (`BEO-003`, Schwelle erreicht) und die
  Push-Disziplin aus §9 §Übergabe, die eine Hard-Rule-Frage ist. Eine Kennung hier behauptete eine
  Datei, die es nicht gibt.
- **Risiken aus §6:** beide mit Ausgang *weiter offen → Beobachtungs-Register* — siehe §6.
- **Drei Paarungen:** (a) **Anker** — kein Eintrag trägt `liegt in`, also kein Gegenstand;
  (b) **Folge-Slice** — keiner genannt, also kein Gegenstand; (c) **Register** — die vier hier
  zitierten Kennungen `BEO-003`, `BEO-008`, `BEO-013`, `BEO-021` haben je eine Zeile, und jede
  Zeile des Registers trägt mindestens einen Beleg
  (`awk -F'|' 'NR>1 && /^\| BEO-/ {if ($6 !~ /slice-/) print $2}' docs/plan/planning/observations.md`
  → leer). Geprüft **nach** dem `git mv` nach `done/`.
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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der Adaptions-Block
spricht über den ganzen Baum, und die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
führt für ihn keine engere.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-008` und `BEO-013` stehen als Risiken in §6;
`BEO-014` (Buchführungs-Anteil des Blocks) berührt den Gegenstand, ist aber per
[welle-14](welle-14-re-baseline.md) §6 ausgeschlossen. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.

## 9. Durchgangs-Protokoll je Eintrag

### Bezugsmenge

```sh
ls harness/conventions/*.md harness/conventions/done/*.md | wc -l   # 48 Einträge gesamt
ls harness/conventions/*.md | wc -l                                 # 44 aktiv
ls harness/conventions/done/*.md | wc -l                            #  4 aufgelöst (Verzeichnis-Position)
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wächst mit dem Block. **Einer der 48 ist das Ergebnis dieses Durchgangs** — [`MR-047`](../../../../harness/conventions.md#mr-047); geprüft sind die **47**, die er vorfand. **Die vier aufgelösten sind mitgeprüft**, weil eine
Verzeichnis-Position kein Beleg dafür ist, dass der Zielstand ihren Gegenstand noch trägt.

### Methode

Gelesen wird je Eintrag der **Volltext** des Abschnitts, den sein Pflichtfeld
`Ersetzt-Baseline-Regel` nennt, im Zielstand `v5.18.0` — nicht die Diff-Zeilen
(`BEO-013`, [Register](../observations.md)). Führt das Feld `keine` (Fork), steht dieselbe Frage
ohne Adresse: regelt der Zielstand den Gegenstand jetzt selbst? Die fünf Ausgänge stehen in
[`modul-02-harness-bootstrap.md`](../../../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
§Freshness-Audit der vendored Baseline (Schritt 2): **gegenstandslos · bleibt gültig · teilweise
überholt · Bezug entfallen · widerspricht**.

**Ein `grep` auf ein Zitat ist kein Volltext-Durchgang.** **Sieben** zitierte
Baseline-Sätze dieses Durchgangs geben als `grep -c` über das volle Zitat eine **0** und
stehen trotzdem wörtlich am Zielstand: In allen sieben trennt ein **Zeilenumbruch** das
Muster, in dreien liegt zusätzlich ein **Inline-Markup** innerhalb des Zitats (zweimal
fett, einmal kursiv). Sie verteilen sich auf fünf Dateien des vendored Baums —
`modul-02-harness-bootstrap.md` (drei), `modul-03-spec.md`, `modul-14-docker-harness.md`,
`grundlagen-source-precedence.md` und `grundlagen-harness-dateien.md`. Gelesen statt
gegrept steht jeder von ihnen da; ein Durchgang, der die **0** für sich nähme, verbuchte
*Bezug entfallen* statt *bleibt gültig*. Die Klasse liegt als `BEO-021` im
[Register](../observations.md).

### Ausgänge — Einträge `MR-000` bis `MR-021`

| MR | Ausgang | Beleg am Zielstand `v5.18.0` |
|---|---|---|
| [MR-000](../../../../harness/conventions.md#mr-000) | bleibt gültig | §Konventionsspeicher führt den Block unverändert als *„**Index** der Abweichungen ggü. Baseline … [`MR-000`](../../../../harness/conventions.md#mr-000) (Adoptions-Erklärung) plus je eine Tabellenzeile pro Adaption"* (`grep -c 'Adoptions-Erklärung) plus je eine Tabellenzeile pro Adaption' .harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md` → **1**); das Vertrags-Präfix bleibt frei (`grep -c "<PREFIX>-FA-<NN>" .harness/baseline/v5.18.0/regelwerk/grundlagen-source-precedence.md` → **2**, §ID-Schema als Klammer) |
| [MR-001](../../../../harness/conventions.md#mr-001) | bleibt gültig | §Referenz-Richtung (SDP) trägt die Sektions-Ausnahme wörtlich (`grep -c 'ohne ausgenommene Sektion' …/grundlagen-referenz-richtung.md` → **1**, dazu *„Über den Spec-Straten läuft der Check über das ganze Dokument"*) und die Reifestufen-Klausel (`grep -c 'anker-validierende Stufe ist eine Reifestufe darüber, kein Startwert' …` → **1**) |
| [MR-002](../../../../harness/conventions.md#mr-002) | bleibt gültig | Die im Eintrag offen gelassene Frage ist hier gemessen: §Das vollständige Artefakt-Set führt am Zielstand **fünf** Posten, und alle fünf liegen vor — `.claude/settings.json` · `.claude/hooks/*.sh` · `.claude/commands/*.md` · `harness/tools/working-tree-hash.sh` · `CLAUDE.md` (`ls`). Der Eintrag protokolliert weiter eine Übernahme, keine Abweichung |
| [MR-003](../../../../harness/conventions.md#mr-003) | bleibt gültig | Beide zitierten Sätze wörtlich: `grep -c 'Nachweis über Inhalt, nicht Diff' …/grundlagen-durchsetzungsschicht.md` → **1**; `grep -c 'rekursiv\*\* derselben Prüfung unterworfen' …/modul-13-quality-gates.md` → **1**; die Restlücke steht als §Grenzen — ehrlich benannt (*„dort ist **CI das Netz**"*) |
| [MR-004](../../../../harness/conventions.md#mr-004) | bleibt gültig | Die Lücke, über die die Injektor-Mechanik fort gilt, ist unverändert offen: `grep -rn 'SessionStart' .harness/baseline/v5.18.0/regelwerk/` ist **leer** — der Zielstand schreibt vor, dass das Regelwerk nicht ganz im Kontext steht (§Anmerkung zur vendored Baseline), nicht, **wodurch** ein Teil hineinkommt |
| [MR-005](../../../../harness/conventions.md#mr-005) | **Bezug entfallen** | Der Ort, von dem der Eintrag abweicht, existiert am Zielstand nicht mehr: `grep -rc 'tools/harness' .harness/baseline/v5.18.0/regelwerk/ .harness/baseline/v5.18.0/templates/` gibt **keine Nicht-Null-Zeile**, und §Verzeichniskonvention führt für ausführbare Harness-Tools **keinen** Ort (dort stehen `harness/README.md`, `harness/conventions.md`, `harness/conventions/`, `.harness/`). → Nachfolge-Eintrag [`MR-047`](../../../../harness/conventions.md#mr-047) |
| [MR-006](../../../../harness/conventions.md#mr-006) | bleibt gültig | §Anmerkung zur vendored Baseline (Schritt 2) verlangt unverändert das Nachschlagen pro Entscheidung (`grep -c 'ohne das ganze Regelwerk im Kontext zu halten' …/modul-02-harness-bootstrap.md` → **1**) — genau das, was der Eintrag zurückbaut |
| [MR-007](../../../../harness/conventions.md#mr-007) | bleibt gültig | Die ersetzte Koexistenz-Setzung steht wörtlich (`grep -c 'Das alte Verzeichnis fällt' …/modul-02-harness-bootstrap.md` → **1** (der Satz bricht nach *fällt* um)); Setzung 4 (ein Tag zur Zeit) tritt weiter an ihre Stelle |
| [MR-008](../../../../harness/conventions.md#mr-008) | bleibt gültig | Die Adaptions-Hälfte ist seit [`MR-041`](../../../../harness/conventions.md#mr-041) zurückgebaut (Kopf-Marke); der tragende Satz ist am Zielstand unverändert (`grep -c 'keine Blank-Kopie im Repo' …/modul-02-harness-bootstrap.md` → **1**). Die fortbindende Hälfte ist die [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)-Abgrenzung auf der emittierten Ebene, über die der Zielstand nichts sagt |
| [MR-009](../../../../harness/conventions.md#mr-009) | bleibt gültig | Die Digest-Regel steht wörtlich in §Multi-Stage-Build — *„Update = *bewusster* Commit, der nur die Digest-Zeile anhebt"* (gelesen, nicht gegrept: die Kursiv-Marker im Zitat lassen jedes Muster über den ganzen Satz scheitern); §Gate-Fragment `d-check.mk` existiert weiter; die zwei `codepaths`-Ventil-Achsen kennt das Startgerüst weiterhin nicht (`grep -n -e exempt-paths -e ignore-refs .harness/baseline/v5.18.0/templates/.d-check.yml` trifft **nur** die auskommentierte `versions`-Zeile) |
| [MR-010](../../../../harness/conventions.md#mr-010) | bleibt gültig | Beide Abweichungs-Punkte stehen unverändert gegen den Zielstand: er schreibt weiter `-include` (der Repo-Stand `include d-check.mk`, `grep -n 'd-check.mk' Makefile`) und *„Das Tool pflegt die Recipe-Form"*. **Der neue Absatz §Und das Fragment mountet fordert nichts nach:** er erlaubt die Mount-Form ausdrücklich, *„solange das Werkzeug nur liest"*, und verlangt eine `MR` allein im nicht gewählten Zweig (Fragment nicht einbinden). Jeder d-check-Lauf des Repos mountet read-only — `grep -c ':/repo:ro' d-check.mk` → **11**, `grep -c 'CURDIR):/repo"' d-check.mk` → **0** |
| [MR-011](../../../../harness/conventions.md#mr-011) | bleibt gültig | Die Messung des Eintrags trägt am Zielstand unverändert: `grep -rl -e check-lines -e citations .harness/baseline/v5.18.0/regelwerk/` ist **leer** (Exit 1); die Deckung des Verzichts steht weiter als *„Vorhanden ≠ behauptet"* in `modul-13-quality-gates.md` |
| [MR-012](../../../../harness/conventions.md#mr-012) | bleibt gültig | §Freshness-Audit führt `sources` weiter namentlich und als *„Netz-Operation, außerhalb der Gates"* (`grep -c 'Netz-Operation, außerhalb der Gates' …/modul-02-harness-bootstrap.md` → **1**) |
| [MR-013](../../../../harness/conventions.md#mr-013) | bleibt gültig | Dieselbe Stelle, dieselbe Grenze: `grep -c 'ersetzt die Release-Listen-Prüfung nicht' …/modul-02-harness-bootstrap.md` → **1**; zur **Ablage** des Hashes sagt der Zielstand weiterhin nichts — die Zwei-Pin-Kopplung füllt weiter eine Lücke |
| [MR-014](../../../../harness/conventions.md#mr-014) | bleibt gültig | Der Satz, den der Eintrag einlöst, steht wörtlich (`grep -c 'dort ist \*\*CI das Netz\*\*' …/grundlagen-durchsetzungsschicht.md` → **1**); einen CI-Aufbau schreibt der Zielstand weiter nicht vor |
| [MR-015](../../../../harness/conventions.md#mr-015) | bleibt gültig | §Spec-Stratifizierung trägt den Träger-Satz wörtlich — *„Der Träger ist dann der **Commit**: Ein angenommener Change Request ändert in einem eigenen Commit **ausschließlich** das Lastenheft und liegt **vor** dem Slice"* (gelesen, nicht gegrept: der Satz bricht zwischen *Der* und *Träger* um); der zitierte Grundsatz ebenso (`grep -c 'bewusst kein Harness-Konstrukt' …/grundlagen-source-precedence.md` → **1**). Der Rückbau ist mit [`MR-036`](../../../../harness/conventions.md#mr-036) verbucht, der Cutoff-Absatz bindet fort |
| [MR-017](../../../../harness/conventions.md#mr-017) | bleibt gültig | Die Ebenen-Begründung trägt weiter: `grep -rn 'Adopter' .harness/baseline/v5.18.0/regelwerk/` nennt Template-Schichtung, Reviewer-Skill, Baseline-Ablage, README und Bootstrap — **keinen** Emissions-Fall; fail-closed steht unverändert als Design-Eigenschaft 1 |
| [MR-019](../../../../harness/conventions.md#mr-019) | bleibt gültig | §Spec-Straten verlangt die Deklaration weiter nur für den anderen Fall (*„Ein Repo *kann* mit zwei Straten fahren. Dann ist das eine **Abweichung von der Baseline und wird als `MR-<NNN>` deklariert**"*) und hält *„Alle drei Straten sind obligatorisch"*; eine Pflichtgliederung für `spec/spezifikation.md` gibt es weiter nicht (§Ziel-Form: Spezifikation nennt Inhalts-Bereiche und operative Regeln, keine Abschnitts-Folge) |
| [MR-020](../../../../harness/conventions.md#mr-020) | bleibt gültig | Der ersetzte Satz steht wörtlich in §Konventionsspeicher (`grep -c 'Einträge werden nie überschrieben' …/grundlagen-harness-dateien.md` → **1**). **Die Verzeichnis-Form ändert daran nichts:** sie trägt den Zustand *aufgelöst*, nicht den Wegfall des Rumpfs — der Beleg liegt im Repo selbst, `wc -l harness/conventions/done/*.md` → je **4** Zeilen |
| [MR-021](../../../../harness/conventions.md#mr-021) | bleibt gültig | Die ersetzte Drei-Spalten-Form steht wörtlich (`grep -c 'liste jeden Attribut-Namen' …/modul-15-observability.md` → **1**); die vierte Spalte `Sensor` tritt weiter an ihre Stelle |

### Ausgänge — Einträge `MR-024` bis `MR-047`

| MR | Ausgang | Beleg am Zielstand `v5.18.0` |
|---|---|---|
| [MR-024](../../../../harness/conventions.md#mr-024) | bleibt gültig | Die Messung des Eintrags trägt unverändert: `grep -rl structure .harness/baseline/v5.18.0/regelwerk/` ist **leer** (Exit 1), das Modul bleibt verfügbar statt aktiviert (`grep -c structure .d-check.yml` → **0**); Digest-Regel und §Gate-Fragment stehen (siehe [`MR-009`](../../../../harness/conventions.md#mr-009) / [`MR-010`](../../../../harness/conventions.md#mr-010)) |
| [MR-025](../../../../harness/conventions.md#mr-025) | bleibt gültig | Der Zielstand führt weiterhin keine Regel über den Beleg einer Zahl in Prosa: `grep -rl Erwartungswert .harness/baseline/v5.18.0/regelwerk/` ist **leer** (Exit 1); die Klasse bleibt dem Begriff nach die **Harness-Lüge** in `grundlagen-begriffe.md` |
| [MR-026](../../../../harness/conventions.md#mr-026) | bleibt gültig | Der Zielstand vergibt für Hard Rules weiter keine Nummer: `grep -rn 'AGENTS.md §3' .harness/baseline/v5.18.0/regelwerk/` → **0** Zeilen; die eine Nennung bleibt das Form-Beispiel des Herkunfts-Ankers (`grep -c '### 3.3 <Hard Rule>' …/grundlagen-traceability.md` → **1**). **Der Auflösungs-Trigger ist gemessen und unverändert:** `comm -12 <(grep -E '^### 3\.' AGENTS.md \| sort) <(grep -E '^### 3\.' .harness/baseline/v5.18.0/templates/AGENTS.template.md \| sort) \| wc -l` → **2** (§3.3 und §3.7) — der zweite Treffer ist der schon mit [`MR-031`](../../../../harness/conventions.md#mr-031) verbuchte; die AGENTS-Vorlage steht nicht in der Änderungs-Menge des Sprungs |
| [MR-027](../../../../harness/conventions.md#mr-027) | bleibt gültig | Der Gegenstand gehört weiter dem Werkzeug: von den Marker-Nennungen des Regelwerks bleibt am Zielstand **eine** (`grep -rn 'd-check:ignore' .harness/baseline/v5.18.0/regelwerk/ \| wc -l` → **1**), und sie ist die Regel, dass gesetzte Marker das Adoptieren eines Templates überleben — über **Form** und **Lage** der Wirkung sagt sie nichts |
| [MR-028](../../../../harness/conventions.md#mr-028) | bleibt gültig | Der ersetzte Satz steht wörtlich in §Herkunfts-Anker: *„Der Adaptions-Block trägt das Muster bereits über sein Feld **Begründung**"*; die Form-Vorgabe *„ein Feld, kein Konstrukt"* ebenso |
| [MR-029](../../../../harness/conventions.md#mr-029) | bleibt gültig | Alle drei zitierten Sätze stehen: `grep -c 'die Senkung ist' …/modul-07-carveouts.md` → **1**, `grep -c 'Formfehler und wird zuerst repariert' …/modul-02-harness-bootstrap.md` → **1**, `grep -c 'Rückbau ist ein neuer Eintrag, kein Edit' …/modul-02-harness-bootstrap.md` → **1** |
| [MR-030](../../../../harness/conventions.md#mr-030) | bleibt gültig | Beide Messungen tragen am Zielstand: `grep -c 'participant I as Implementer' …/modul-08-agentenrollen.md` → **1**, `grep -rl implementer .harness/baseline/v5.18.0/regelwerk/ \| wc -l` → **0** |
| [MR-031](../../../../harness/conventions.md#mr-031) | bleibt gültig | Die Deckung, die der Eintrag feststellt, hält am neuen Tag: `grep -c '^### 3\.7 Ein Kommentar beschreibt, was da ist$' .harness/baseline/v5.18.0/templates/AGENTS.template.md` → **1** und `grep -c '^### Was ein Kommentar trägt — Code, Konfiguration, Skripte$' …/grundlagen-harness-dateien.md` → **1** |
| [MR-032](../../../../harness/conventions.md#mr-032) | bleibt gültig | Der ersetzte Satz steht wörtlich (`grep -c 'Status-Feld' …/grundlagen-harness-dateien.md` → **1**, umgebrochen nach *kein*). Sein Trigger ist von [`MR-046`](../../../../harness/conventions.md#mr-046) Verdikt 1 als **nicht** eingetreten verbucht — für die Teil-Ablösung trägt die Position den Zustand nicht |
| [MR-033](../../../../harness/conventions.md#mr-033) | bleibt gültig | Der Zielstand führt weiter keine Regel darüber, dass eine Baseline-Aussage ihren Mess-Tag nennt; der Eintrag ist eine Sachstands-Setzung ohne Baseline-Gegenstück |
| [MR-034](../../../../harness/conventions.md#mr-034) | bleibt gültig | Der Gegenstand ist ein Werkzeug-Stand, kein Baseline-Stand (`Ausgelöst durch Baseline-Stand: keiner`). Die Beobachtung, die den Eintrag trägt, gilt am Zielstand fort: die Eintrags-Vorlage kennt zu `Löst auf` weiterhin **nur** den Baseline-Stand als Auslöser (`grep -n 'Ausgelöst durch Baseline-Stand' .harness/baseline/v5.18.0/templates/harness/conventions/MR-NNN-titel.template.md` → **2** Zeilen, beide Baseline) |
| [MR-035](../../../../harness/conventions.md#mr-035) | bleibt gültig | Die drei Messungen wiederholt: `grep -c 'ohne das ganze Regelwerk im Kontext zu halten' …/regelwerk/README.md` → **1**, `grep -rl 'claude/rules' .harness/baseline/v5.18.0/ \| wc -l` → **0**, `grep -c 'Per-Lauf-Relevantes gehört verkörpert, nicht extern' …/modul-02-harness-bootstrap.md` → **1**. Der Mechanismus bleibt der Baseline unbekannt |
| [MR-036](../../../../harness/conventions.md#mr-036) | bleibt gültig | Der Absatz, dessen Deckung der Eintrag feststellt, steht am Zielstand (`grep -c 'Fallen Auftraggeber- und Entwickler-Rolle zusammen' …/grundlagen-source-precedence.md` → **1**) samt dem Träger-Satz; der Rückbau bleibt richtig |
| [MR-037](../../../../harness/conventions.md#mr-037) | bleibt gültig | Alle drei zitierten Sätze aus `modul-06-roadmap.md` stehen wörtlich: `grep -c 'Wellenlose Arbeit erscheint nicht in der Roadmap'` → **1**, `grep -c 'auch eine neue Fähigkeit kann ein einzelner Slice sein'` → **1**, `grep -c 'die mehr beobachtet, als die DoDs ihrer Slices schon'` → **1**. Die vier Änderungen des Moduls im Sprung liegen sämtlich im Register- und Archiv-Teil, nicht in §Wann Arbeit eine Welle braucht |
| [MR-038](../../../../harness/conventions.md#mr-038) | bleibt gültig | Die ersetzte Freshness-Audit-Eigenschaft steht wörtlich (`grep -c 'Rückbau ist ein neuer Eintrag, kein Edit' …/modul-02-harness-bootstrap.md` → **1**); ihr Auflösungs-Trigger — eine erneute Änderung dieser Eigenschaft — ist damit nicht eingetreten |
| [MR-039](../../../../harness/conventions.md#mr-039) | bleibt gültig | Beide zitierten Stellen stehen (`grep -c 'Einträge werden nie überschrieben'` → **1**, die Index-Zelle führt weiter *„**Index** der Abweichungen ggü. Baseline"*). Der Inline-Form-Trigger ist von [`MR-046`](../../../../harness/conventions.md#mr-046) Verdikt 2 einzeln abgearbeitet |
| [MR-040](../../../../harness/conventions.md#mr-040) | bleibt gültig | Die Lücke, die der Eintrag füllt, ist am Zielstand unverändert offen: der Freshness-Audit bindet die **Form** einer Instanz (`grep -c 'nicht rückwirkend umgeschrieben' …/modul-02-harness-bootstrap.md` → **1**) und führt keinen Ausgang für eine **Aussage über den vendored Baum**. Der Trigger — eine Änderung des Audits an dieser Stelle — ist nicht eingetreten |
| [MR-041](../../../../harness/conventions.md#mr-041) | bleibt gültig | Die Deckung, die den Rückbau trug, steht am Zielstand wörtlich (`grep -c 'keine Blank-Kopie im Repo' …/modul-02-harness-bootstrap.md` → **1**); §Anmerkung zum Instanziierungs-Zeitpunkt ist unverändert |
| [MR-042](../../../../harness/conventions.md#mr-042) | bleibt gültig | Beide tragenden Sätze stehen: `grep -c 'auslösenden Slice in der Historie nennt' …/modul-03-spec.md` → **1** und `grep -c 'Historie-Zeile ist ein Protokoll und wird nicht' …/modul-03-spec.md` → **1**; die Verweis-Spalten-Aussage ebenso (`grep -c 'die Verweis-Spalte nennt diesen Vorgang statt eines' …/grundlagen-source-precedence.md` → **1**) |
| [MR-043](../../../../harness/conventions.md#mr-043) | bleibt gültig | Der ersetzte Satz steht (§Herkunfts-Anker, *„über sein Feld Begründung"*); sein Trigger übernimmt die Bedingung von [`MR-032`](../../../../harness/conventions.md#mr-032) und ist nach [`MR-046`](../../../../harness/conventions.md#mr-046) Verdikt 3 nicht eingetreten |
| [MR-044](../../../../harness/conventions.md#mr-044) | bleibt gültig | Beide Regeln, die in derselben Tabelle zusammentreffen, stehen unverändert: `grep -c 'liste jeden Attribut-Namen' …/modul-15-observability.md` → **1** und die `ID`-Spalte der Ziel-Form (`grep -c '\| ID ' .harness/baseline/v5.18.0/templates/spec/spezifikation.template.md` → **4**). Der Trigger — das Observability-Modul nimmt die `ID`-Spalte auf — ist nicht eingetreten |
| [MR-045](../../../../harness/conventions.md#mr-045) | bleibt gültig | Gegen den Zielstand geschrieben und dort belegt: `grep -c 'Der \*\*Default\*\* ist die Verzeichnis-Form' …/grundlagen-harness-dateien.md` → **1** und `grep -c 'trägt die Index-Zeile den alten Überschriften-Slug \*\*zusätzlich\*\*' …` → **1** |
| [MR-046](../../../../harness/conventions.md#mr-046) | bleibt gültig | Ebenso gegen den Zielstand geschrieben (`Ausgelöst durch Baseline-Stand: v5.18.0`); die ersetzte Zelle steht (`grep -c 'Status-Feld' …/grundlagen-harness-dateien.md` → **1**) |
| [MR-047](../../../../harness/conventions.md#mr-047) | bleibt gültig | Der Eintrag entsteht in diesem Durchgang und trägt seine Messung selbst |

### Ausgänge — die vier aufgelösten Einträge in `conventions/done/`

Sie sind **mitgeprüft**, nicht übersprungen: eine Verzeichnis-Position belegt nicht, dass der
Zielstand den Gegenstand nicht wiederbelebt. Alle vier tragen nach
[`MR-020`](../../../../harness/conventions.md#mr-020) nur Kopf und Zeiger und damit **keine
Adaption**, an der ein Ausgang ansetzen könnte — der Ausgang liegt bei dem Eintrag, der sie
aufhob, und jeder der drei steht oben auf *bleibt gültig*.

| MR | aufgehoben durch | Prüfung |
|---|---|---|
| [MR-016](../../../../harness/conventions.md#mr-016) | [MR-037](../../../../harness/conventions.md#mr-037) | die drei `modul-06`-Sätze stehen — der Rückbau bleibt richtig |
| [MR-018](../../../../harness/conventions.md#mr-018) | [MR-021](../../../../harness/conventions.md#mr-021) | die Drei-Spalten-Form steht — der Zielort im Technik-Stratum bleibt |
| [MR-022](../../../../harness/conventions.md#mr-022) | [MR-031](../../../../harness/conventions.md#mr-031) | die AGENTS-Vorlage führt §3.7 weiter — der Vorgriff bleibt eingeholt |
| [MR-023](../../../../harness/conventions.md#mr-023) | [MR-031](../../../../harness/conventions.md#mr-031) | dieselbe Messung |

### Bilanz

| Ausgang | Zahl | Einträge |
|---|---|---|
| bleibt gültig | 43 | alle aktiven außer [`MR-005`](../../../../harness/conventions.md#mr-005), einschließlich des neuen [`MR-047`](../../../../harness/conventions.md#mr-047) |
| Bezug entfallen | 1 | [`MR-005`](../../../../harness/conventions.md#mr-005) → Nachfolge-Eintrag [`MR-047`](../../../../harness/conventions.md#mr-047), Kopf-Marke gesetzt |
| gegenstandslos · teilweise überholt · widerspricht | 0 | — |
| ohne Gegenstand (aufgelöst, `conventions/done/`) | 4 | [`MR-016`](../../../../harness/conventions.md#mr-016) · [`MR-018`](../../../../harness/conventions.md#mr-018) · [`MR-022`](../../../../harness/conventions.md#mr-022) · [`MR-023`](../../../../harness/conventions.md#mr-023) |

**Handzählung über die Spalte `Ausgang` der drei Tabellen oben; kein Kommando gibt genau sie aus**
([`MR-025`](../../../../harness/conventions.md#mr-025) Setzung 1). Die Bezugsmenge ist die des
Kommandos oben — jeder ihrer Einträge steht in genau einer Zeile, keiner ohne Ausgang.

### Die vier Katalog-Positionen aus [slice-155](../done/slice-155-inventur-vor-dem-schnitt.md) §9, namentlich verbucht

| Position | Verbuchung |
|---|---|
| **2** — neue Glossarzeile `MR-<NNN>` in `grundlagen-begriffe.md` | Ohne Ausgang in diesem Durchgang: Der Eintrag beschreibt die Verzeichnis-Form, und die ist per [welle-14](welle-14-re-baseline.md) §6 ausgeschlossen (`BEO-014`); sie ist mit [`MR-045`](../../../../harness/conventions.md#mr-045)/[`MR-046`](../../../../harness/conventions.md#mr-046) ohnehin bereits gefahren. Keine Adaption dieses Registers hängt an der Glossarzeile |
| **3** — §Referenz-Implementierung → §Das vollständige Artefakt-Set | **Der Ausgang dieses Durchgangs.** Für [`MR-005`](../../../../harness/conventions.md#mr-005) ist es *Bezug entfallen* → [`MR-047`](../../../../harness/conventions.md#mr-047); für [`MR-002`](../../../../harness/conventions.md#mr-002), das den umbenannten Anker zitiert, *bleibt gültig* — der Anker löst auf, und alle fünf Posten des Sets liegen vor |
| **8 (b)** — §Und das Fragment mountet | Keine Nachforderung an [`MR-010`](../../../../harness/conventions.md#mr-010): Der neue Absatz erlaubt die Mount-Form *„solange das Werkzeug nur liest"* und verlangt eine `MR` allein im Zweig *Fragment nicht einbinden*. Das Repo bindet ein und mountet read-only (`grep -c ':/repo:ro' d-check.mk` → **11**, `grep -c 'CURDIR):/repo"' d-check.mk` → **0**). Die Mount-Achse selbst trägt [slice-160](../done/slice-160-docker-form-hermetisch-und-beleg.md) |
| **21 (a)** — Wegfall des `Status:`-Feldes in der Eintrags-Vorlage | Keine Nachforderung an [`MR-020`](../../../../harness/conventions.md#mr-020) und **kein** neuer Eintrag: Die Ziel-Form hat das Feld verloren (`grep -c '^- \*\*Status:\*\*' .harness/baseline/v5.18.0/templates/harness/conventions/MR-NNN-titel.template.md` → **0**; am abgelösten Stand **1**, Tree-Operand `git show db83415^:.harness/baseline/v5.12.0/templates/harness/conventions/MR-NNN-titel.template.md`), und kein Eintrag dieses Registers führt es (`grep -l '^- \*\*Status:\*\*' harness/conventions/MR-*.md harness/conventions/done/MR-*.md \| wc -l` → **0**). Die Form deckt sich damit ohne Zutun; [`MR-020`](../../../../harness/conventions.md#mr-020)s Festlegung *„Akzeptiert" heißt committet* bindet als Auslöser-Bestimmung fort, für die der Zielstand keine Regel führt |
| **21 (b)** — der `Ersetzt-Baseline-Regel`-Link trägt Tiefe **und** Version, je mit eigenem Wächter | Die Tiefen-Hälfte ist gedeckt: `make docs-check` prüft die Existenz jedes Links, und die Pfad-Berichtigung nach dem `git mv` ist in §Herkunfts-Anker als Gegenrichtung der Ruheort-Regel benannt. Die Versions-Hälfte ist **unbewacht**: `grep -c versions .d-check.yml` → **0**. Kein Eintrag dieses Registers wird davon berührt; den Sensor baut [slice-162](../open/slice-162-versions-sensor-baseline-pins.md), **kein** Mitglied von [welle-14](welle-14-re-baseline.md) |

### Übergabe an den Architect — die Push-Disziplin

`grundlagen-traceability.md` §Herkunfts-Anker führt am Zielstand einen Absatz, der **keine
`MR`-Antwort** hat, sondern in der Nachbarschaft einer Hard Rule liegt:
*„**Beide Commits gehören in denselben Push.** Zwischen ihnen ist das Repo kurz rot; das ist
zulässig, solange dieser Zwischenstand nicht die **Spitze** eines Push wird."*

Er steht neben [`AGENTS.md`](../../../../AGENTS.md) §3.3 (*git mv + Inhaltsänderung = zwei
Commits*), die den **Zuschnitt** der zwei Commits regelt und über ihren **Push** nichts sagt. Die
Frage — ob §3.3 diesen Satz aufnimmt oder ob er ohne Träger bleibt — ist eine Hard-Rule-Änderung
und damit ein eigener Architect-Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.8); sie steht hier
als **Übergabe**, nicht als Entscheidung. **Gemessen dazu:** ein Wächter existiert nicht —
`grep -m1 '^modules:' .d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`, und
keines liest Commits oder Push-Spitzen. `make slice-mv` setzt die zwei Commits selbst, pusht aber
nicht.

### Was dieser Durchgang **nicht** trägt

Die Nennungen des abgelösten Tags in den Eintrags-Dateien sind **kein** Freshness-Audit-Ausgang,
sondern die Klasse aus
[`MR-040`](../../../../harness/conventions.md#mr-040) (drei Ausgänge für eine Präsens-Aussage über
den vendored Baum). Ihr Träger ist [slice-165](../done/slice-165-praesens-aussagen-gegen-v5180.md),
dessen §1 den Anteil dieses Registers ausdrücklich hierher verweist — die dortige Zahl ist am
Index-Stand vor der Verzeichnis-Form erhoben und beim Lauf neu zu messen:

```sh
git grep -n 'v5\.12\.0' -- 'harness/conventions.md' 'harness/conventions/' | grep -vc ']('
```

Sie hier mitzunehmen wäre ein vierter Liefer-Punkt an einem Slice mit drei
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Slice). Der Durchgang **prüft**
diese Nennungen, wo sie eine Messung tragen — jede Zeile der drei Tabellen oben ist gegen den
Zielstand neu gefahren —, und **ändert** keine.
