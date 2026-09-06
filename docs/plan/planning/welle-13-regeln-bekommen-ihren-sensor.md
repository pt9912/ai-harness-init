# Welle welle-13: Fünf Regeln, die nur im Feedforward-Quadranten leben, bekommen ihren Sensor

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug. Die sechs bestehenden Meilensteine sind erreicht, und
M1–M6 tragen durchweg **Fähigkeiten des Werkzeugs**; diese Welle schließt eine **Qualitätslücke des
Dogfoods**. Einen Meilenstein dafür zu erfinden hieße, die Meilenstein-Achse umzudeuten, damit eine
Welle einen Eintrag bekommt.

**Verantwortlich:** Planner. **Datum:** 2026-08-28.

---

## 1. Welle-Ziel

**Fünf Regeln dieses Repos, die heute nur als Text existieren, tragen am Ende einen verdrahteten
Sensor — und keiner dieser Sensoren meldet grün, weil er nichts prüft.**

Die Welle ist der Schnitt-Vorschlag zu den Achsen **(1)–(4)** und **(6)** des Roadmap-Kandidaten
*Regeln ohne Feedback-Quadrant schließen*. Sie nimmt **nicht** den ganzen Kandidaten: dessen Achsen
(5), (7) und (8) sind Eigenbauten, (7) liegt außerhalb von git, und (1) ist bereits am 2026-07-28
nach [welle-09](welle-09-modul-15-konformitaet.md) eingefaltet worden. Was hier landet, ist die
Hälfte, die der Kandidat selbst als *„bereits bezahlt"* führt — vier Regelmodule im gepinnten
d-check-Image, dazu eine zweite Fähigkeit eines davon, die der Kandidat für einen Eigenbau hielt
(§6).

### Der Hebel, und wo er kleiner ist als angenommen

Der Kandidat sagt: *„Adoption heißt Trockenlauf + Config-Block + Verdrahtung, nicht Neubau."* Das
stimmt — und ist teurer, als der Satz klingt.

**Alle Zahlen dieses Abschnitts sind im Eröffnungs-Lauf gegen `v0.74.1` neu gefahren** — über einen
Klon außerhalb des Repos (Stand `8ed6952`), netzlos (`--network none`), Mount `:ro`, Image per
Digest `sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`. **Und sie sind
über demselben Baum zusätzlich gegen `v0.65.0` gefahren** (Digest `sha256:5ea03abe…41288`), den
Stand, gegen den die Erstfassung maß. Das trennt die zwei Ursachen, die eine bewegte Zahl haben
kann: **der Pin** und **der Baum**. Das Ergebnis steht vorweg, weil es die Lesart aller folgenden
Zahlen bestimmt: **keine einzige hat sich durch den Pin bewegt** — je Messung liefern beide Digests
denselben Befundstrom, `diff` der nach `cut -f1-3` sortierten Ausgaben ist leer. Jede Abweichung
gegenüber der Erstfassung geht damit auf den **Baum**, der seither `welle-14` und `welle-15`
aufgenommen hat.

1. **Alle vier Module sind ohne eigenen Config-Block nachweislich inert, und ihr `doc-*`-Ziel
   meldet dabei grün.** Nachweislich heißt: derselbe Baum trägt **mit** Config-Block Befunde und
   **ohne** ihn Exit 0. Der schärfste Beleg ist `targets`: mit einem angehängten Phantom-Gate in
   [`AGENTS.md`](../../../AGENTS.md) und **ohne** `targets:`-Block antwortet der Lauf
   `d-check: 834 Datei(en) geprüft, 0 Befund(e)`, Exit 0 — dasselbe gilt in derselben Lage für
   `planning`, `commits` und `vcs`. Derselbe Baum, dasselbe Phantom-Gate, **mit** `targets:`-Block:
   **24 Befunde** (21 × `gate-undocumented`, 3 × `gate-phantom` — die zwei bestehenden plus das
   eingesetzte), Exit 1.
   **Für `vcs` brauchte der Nachweis eine zweite Runde, und sie liegt vor.** Der Lauf blieb in
   **vier** Formen grün, auch **mit** Config-Block und über einer Range mit einer Kern-Änderung an
   einer `Accepted`-ADR — weil die Probe den Satz **ans Dateiende** hängte und damit in
   `## Geschichte`, den der Default-Block über `exclude-sections` aus dem Kern nimmt. Derselbe Satz
   in `## Entscheidung` meldet `core-drift-vcs`, Exit 1
   ([slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) §1 führt beide Läufe).
   **Damit ist keines der vier Module ohne Rot**, und der Carveout-Pfad aus §3 wird für `vcs` nicht
   gebraucht.
2. **Die Adoptions-Schuld ist real und je Modul verschieden** — jede Zahl aus dem Lauf des
   jeweiligen Moduls mit gesetztem Config-Block über den **unveränderten** Baum, beide Digests:
   `targets` → **23** (21 × `gate-undocumented`, 2 × `gate-phantom`);
   `planning` mit der Vorgabe-Überschrift → **1** (`planning-drift`, fail-closed: dieses Repo führt
   `## Offene Wellen`, nicht `## Aktuelle Welle`), mit den **echten** Überschriften dieses Repos
   (`heading: "## Offene Wellen"`, `marker: "Nichts in Arbeit"`) → **0**;
   `planning` mit der `waves`-Fähigkeit und `mode: many` → **4** (2 × `wave-drift`,
   2 × `wave-preview-exists`, je auf `welle-11` und `welle-13`);
   `commits` über `--range HEAD~20..HEAD` → **1** (`commit-untraceable`);
   `vcs` über dieselbe Range → **0**, und das ist hier die richtige Zahl: das Modul urteilt über
   Commits, nicht über einen Bestand;
   `planning` mit der `closure`-Fähigkeit → **0** über die **133** Slice-Notizen des Ruheorts
   (`ls docs/plan/planning/done/slice-*.md | wc -l`), **20** über alle **157** flachen Dateien
   dort (`ls docs/plan/planning/done/*.md | wc -l`; 12 × `closure-note-missing`,
   8 × `closure-note-thin`, §6).
   **Alle diese Zahlen hängen an ihrem Stand und sind keine Erwartungswerte**
   ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2; der erste Schritt jeder Umsetzung ist, sie neu zu fahren). **Zwei von ihnen sind
   eine Ansage an diese Welle selbst:** die vier `waves`-Befunde benennen genau die
   repo-eigene Abweichung, die [`roadmap.md`](in-progress/roadmap.md) unter *Offene Wellen*
   erklärt — eine Welle-Datei wird geschnitten, bevor ihr Start-Trigger eintritt. Die Eröffnung
   dieser Welle nimmt zwei davon weg; die zwei zu `welle-11` bleiben, bis deren Trigger eintritt.
   Ein Sensor nach [slice-125](done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) muss
   diese Abweichung tragen, sonst meldet er einen legitimen Zustand als Drift.
3. **Der Trockenlauf ist nicht geteilt.** Jedes Modul brauchte seinen eigenen Lauf mit seiner eigenen
   Config; der Pin-Trockenlauf aus
   [slice-187](done/slice-187-d-check-pin-v0741.md) fuhr die zu seiner Zeit sechs **aktiven** Module
   und sagt über die Kandidaten nichts. Genau deshalb liegt der Pin **nicht** in dieser Welle.
4. **Zwei der vier sind in CI blind.** `grep -c 'fetch-depth' .github/workflows/ci.yml` → **0** bei
   **4** `actions/checkout`-Zeilen (`grep -c 'actions/checkout' .github/workflows/ci.yml`).
   Voreinstellung ist Tiefe **1**; ein history-lesendes Modul wäre dort **blind und grün** — die
   stille-Grün-Klasse aus
   [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
   Setzung 3.

### Warum das eine Welle ist und keine Reihe von Wartungs-Slices

Gegen [`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen beantwortet:

1. **Bündel?** **Ja.** Die Aussage *„die gemessenen Regeln ohne Feedback-Quadrant sind geschlossen"*
   wird von keinem einzelnen Slice wahr; jeder deckt genau eine Achse, und die Klasse ist die
   Einheit, in der sie gemessen wurde (sechsmal an einem Tag, Drift-Log 2026-07-26).
2. **Gemeinsames Closure-Kriterium?** **Ja**, und es unterscheidet sich von jeder Einzel-DoD: **kein
   `doc-*`-Ziel dieses Repos meldet mehr grün über einem Modul ohne Config-Block, ohne das zu
   sagen.** Das ist erst wahr, wenn alle vier Blöcke stehen **und** die verbleibenden sieben Ziele
   ihre Inertheit ausweisen — eine Aussage über die **Menge** der Ziele, die kein Slice allein
   trifft (§3).
3. **Auslöser reaktiv oder gewollt?** **Gewollt.** Kein Sensor hat gefeuert und kein Pin ist
   veraltet; hier wird eine Fähigkeit erworben, die das Repo bisher nicht hatte — Frage 3 nennt
   genau das als Wellen-Kriterium, *„auch wenn es zunächst nach einem Slice aussieht"*.

### Offene Beobachtungen gesichtet (Eröffnungs-Schritt 2)

Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Eröffnung Schritt 2: Das
Register `docs/plan/planning/observations/` wird vor dem Schnitt durchgegangen; betrifft ein
Eintrag die Sub-Areas dieser Welle, gehört er in die Slice-Planung, und bei **3×** als eigener
Slice. **Keine Treffer sind ebenfalls eine Antwort und werden notiert.** Der Block steht hier und
nicht als eigener `## 8`-Abschnitt: Die Ziel-Form
[`welle.template.md`](../../../.harness/baseline/v6.0.0/templates/docs/plan/planning/welle.template.md)
führt **sieben** Abschnitte, und ein achter wäre eine Abweichung, die einen Eintrag im
Adaptions-Block bräuchte
([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)) — den schreibt der Architect,
nicht dieser Lauf.

Gesichtet ist der **gemergte** Stand: **52** Verzeichnisse
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`, kein Erwartungswert). Die Sub-Areas
dieser Welle sind die Doc-Gate-Modulfläche, das Paar Roadmap ↔ Lifecycle-Verzeichnis und die
Closure-Notiz-Pflicht; alle drei fallen unter die eine deklarierte Sub-Area `*` dieses Repos
(`harness/conventions.md` §Modus-Deklaration). **Sechs Einträge berühren sie**, je mit ihrem
Zähler-Stand aus `ls <eintrag>/evidence/*.md | wc -l`:

| Beobachtung | Stand | berührt |
|---|---|---|
| [`zusage-nennt-sensor-der-form-nicht-sieht`](observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md) | **7×**, *geplant* (`slice-181`) | jeden Sensor, den diese Welle verdrahtet — der Ausgang ist **vergeben**, die Schwelle bereits überschritten |
| [`register-paarung-ohne-gate-modul`](observations/BEO-ALL/register-paarung-ohne-gate-modul/observation.md) | **1×**, offen | [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md); die Tatsachen-Basis hat sich bewegt (§6) |
| [`zusage-ohne-herstellbares-gegenbeispiel`](observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md) | **1×**, offen | §3, Bedingung *einmal rot gesehen* — der Carveout-Zweig dort **ist** die Antwort auf diesen Fall |
| [`gruen-aussage-ohne-herkunft`](observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md) | **1×**, offen | das Welle-Ziel selbst: *kein Sensor meldet grün, weil er nichts prüft* |
| [`closure-kriterium-ohne-erreichbare-messstelle`](observations/BEO-ALL/closure-kriterium-ohne-erreichbare-messstelle/observation.md) | **1×**, offen | das welle-eigene Kriterium in §3 |
| [`vollstaendigkeits-zusage-misst-falsche-ebene`](observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md) | **1×**, offen | die Aufzählung *„vollständig, nicht beispielhaft"* in §6 |

**Was daraus folgt, ist nichts — und das ist die Antwort, nicht ihr Fehlen.** Kein Eintrag erreicht
**durch diese Welle** die Schwelle: Fünf stehen bei 1×, und der sechste steht bei 7× mit bereits
zugewiesenem Ausgang. Ein eigener Folge-Slice wird damit von der Sichtung **nicht** ausgelöst.
Ihren Ort haben die fünf offenen trotzdem: Sie sind Risiken der Slices, die sie berührt — die
Spalte oben nennt ihn —, und dort werden sie beim jeweiligen Slice-Schnitt aufgenommen, nicht hier.

## 2. Trigger (Welle startet)

- **[slice-122](done/slice-122-d-check-pin-v0650.md) liegt in `done/`.** Beobachtbar ohne Rückfrage:
  `ls docs/plan/planning/done/slice-122-*.md`. Der Grund ist **tragend, nicht ordnend** — die
  Adoptions-Entscheidungen dieser Welle werden gegen das Verhalten eines Moduls getroffen, und das
  Verhalten hängt an der Version. Eine Config gegen ein Image zu schneiden, das im selben Zug
  ausgetauscht wird, hieße, sie zweimal zu schneiden. **Vom dritten Trigger unten ist dieser
  überholt und bleibt trotzdem stehen:** er ist eingetreten, und die Kette der Pin-Sprünge, gegen
  die diese Welle misst, beginnt bei ihm.
- **[welle-14](done/welle-14-re-baseline.md) liegt in `done/`.** Der Grund ist **tragend**, nicht bloß
  ordnend: Zwei Slices dieser Welle bauen Sensoren auf Formen, die jener Sprung bewegt — der
  Roadmap-/Verzeichnis-Wächter ([slice-125](done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md))
  und der Closure-Notiz-Sensor ([slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md)). Die
  Ziel-Fassung schiebt der Wellen-Closure einen Schritt ein, der die Zeitdokumente einer Welle nach
  `done/<welle-id>/` archiviert und an ihrer Stelle Stubs lässt (`v5.18.0`, `modul-06-roadmap.md`,
  §Wellen-Closure-Prozedur, Schritt 4); damit ändert sich, was `done/` enthält und was eine
  Closure-Notiz ist. Es ist derselbe Grund wie beim Pin darüber: eine Config gegen ein Artefakt zu
  schneiden, das im selben Zug ausgetauscht wird.
- **[slice-187](done/slice-187-d-check-pin-v0741.md) liegt in `done/`.** Beobachtbar ohne
  Rückfrage: `ls docs/plan/planning/done/slice-187-*.md`. Der Grund ist **tragend** und derselbe wie
  beim Pin darüber, nur eine Version weiter: Der Slice zieht den d-check-Pin von `v0.65.0` — dem
  Stand, gegen den die Erstfassung dieser Welle maß — auf `v0.74.1`, und die Fläche, über die diese
  Welle entscheidet, wächst dabei. Die Modulzahl steigt von **20** auf **22**
  (`workflows`, `reviews` neu; gemessen über
  `--print-config`, dann `grep -m1 '^# Verfügbar:' | tr ',' '\n' | wc -l`, je Digest — keine
  Erwartungswerte), und `planning` bekommt eine **vierte** Fähigkeit `observations` (§6). Eine
  Config gegen `v0.65.0` zu schneiden hieße, sie gegen ein Image zu schneiden, das nicht mehr
  gepinnt ist.

**Die Auflage, die dieser dritte Trigger trug, ist mit diesem Eröffnungs-Lauf eingelöst.** §1 und
§6 sind vollständig gegen `v0.74.1` neu gefahren, und die zwei bis dahin ungemessenen Fähigkeiten
— `reviews` und `planning.observations` — sind darin aufgenommen (§6). Die Aufzählung der nicht
adoptierten Module ist von **zehn** auf **zwölf** nachgezogen; sie war mit der Landung von
`slice-187` zur Untergrenze geworden. **Die Trigger-Liste ist damit geschlossen: alle drei
Bedingungen sind eingetreten**, und die Welle steht ab hier unter *Offene Wellen* der
[`roadmap.md`](in-progress/roadmap.md).

## 3. Closure-Trigger (Welle schließt)

- Alle sechs Slices liegen in `done/`.
- `make gates` grün — **mit** den neu aufgenommenen Modulen in der Modul-Liste, nicht daneben.
- **Jedes neu verdrahtete Modul ist einmal rot gesehen worden**, mit dem Kommando, das es rot
  färbt, im jeweiligen Umsetzungs-Commit ([`AGENTS.md`](../../../AGENTS.md) §3.6). **Ein Modul, für
  das kein Rot herstellbar ist, wird nicht verdrahtet, sondern als Carveout geführt** (Modul 7) —
  die Welle darf mit einem dokumentierten Carveout schließen, nie mit einem still grünen Modul.
- **Das welle-eigene Kriterium, das keine Slice-DoD abschreibt:** für **jedes** der zwölf
  `docs?-*`-Ziele in [`d-check.mk`](../../../d-check.mk) ist entschieden und aufgeschrieben, ob es
  einen Prüfbereich hat — und die Ziele, die weiterhin ohne Config-Block laufen, **sagen das in
  ihrer eigenen Ausgabe oder ihrem Hilfetext**. Heute melden sie „0 Befund(e)" und meinen „nichts
  geprüft"; nach der Welle darf das nicht mehr vorkommen, ohne benannt zu sein
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- Closure-Notiz in `done/welle-13-results.md` mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

<!-- Zustand jedes Slice = sein Lifecycle-Verzeichnis (open/next/in-progress/
done), hier NICHT gespiegelt — eine Status-Spalte driftete gegen die
Verzeichnisse (dieselbe zweite Wahrheit, die beim Slice retired wurde). -->

| Slice | Titel | Bezug |
|---|---|---|
| [slice-123](done/slice-123-ci-sieht-die-historie.md) | CI sieht die Historie — oder der Lauf fällt, statt grün zu melden | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [slice-124](open/slice-124-gate-tabelle-hat-einen-waechter.md) | Die Gate-Tabellen werden gegen das Makefile gehalten (Modul `targets`, Achse 1) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-125](done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) | Roadmap und Lifecycle-Verzeichnis widersprechen sich nicht mehr still (Modul `planning`, Achse 4) | [`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) |
| [slice-126](open/slice-126-commit-message-traegt-eine-kennung.md) | Eine Commit-Message ohne Kennung wird rot, und zwar vor dem Commit (Modul `commits`, Achse 3) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) | Hard Rule 3.4 bekommt ihren Sensor (Modul `vcs`, Achse 2) | [`AGENTS.md`](../../../AGENTS.md) §3.4 |
| [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md) | Die Closure-Notiz-Pflicht bekommt ihren Sensor (Modul `planning`, zweite Fähigkeit, Achse 6) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

**Die Reihenfolge ist nicht beliebig, eine Kante ist hart und eine ist ein Ausschluss.**
[slice-123](done/slice-123-ci-sieht-die-historie.md) geht **[slice-126](open/slice-126-commit-message-traegt-eine-kennung.md)
und [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) voraus**: beide lesen
Historie, und ohne die Range-Entscheidung aus 123 wären sie in CI blind und grün — ein fail-open
Sensor ist schlechter als keiner, weil er eine Zusage trägt. Die drei hermetischen
([slice-124](open/slice-124-gate-tabelle-hat-einen-waechter.md),
[slice-125](done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md),
[slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md)) hängen an nichts und können zuerst
laufen. **Nicht gleichzeitig laufen dürfen 125 und 129:** beide konfigurieren dasselbe Modul in
demselben Schlüsselbaum — die Reihenfolge ist frei, die Parallelität nicht.

**Warum sechs und nicht drei.** Der Roadmap-Kandidat schätzt *„zwei bis drei Slices"*. Die
Schätzung ist von vor der Messung: sie unterstellt, Adoption sei je Modul eine Config-Zeile. §1
Messung 2 zeigt vier verschiedene Adoptions-Schulden mit vier verschiedenen Entscheidungen, dazu
kommt die zweite Fähigkeit von `planning` (§6, Achse 6), und Modul 5 §Ziel-Form deckelt einen Slice
bei **drei** eigenen DoD-Punkten. Zwei Module in einen Slice zu legen ergäbe sechs — *„der Schnitt
ist falsch"*, nicht *„die DoD ist länger"*.

## 5. Abhängigkeiten

- **Wird blockiert von:** [slice-122](done/slice-122-d-check-pin-v0650.md) (Pin, tragend) und
  [welle-10](done/welle-10-re-baseline.md) (WIP, ordnend) — beide mit ihrer Begründung in §2.
- **Blockiert:** nichts. [welle-11](welle-11-traeger-aussage.md) hängt an
  [welle-10](done/welle-10-re-baseline.md), nicht an dieser Welle; die Reihung ist damit
  welle-10 → welle-11 **und** welle-10 → welle-13, ohne Kante zwischen 11 und 13.
- **Berührt, aber bindet nicht:** [slice-121](open/slice-121-commit-message-nennt-was-es-gibt.md)
  liegt **außerhalb** dieser Welle und bekommt aus
  [slice-126](open/slice-126-commit-message-traegt-eine-kennung.md) seinen **Träger**, nicht seine
  Eigenschaft (Begründung dort in §1).

## 6. Out-of-Scope für diese Welle

- **Die Achsen (5), (7) und (8) des Roadmap-Kandidaten.** (5) Co-Change um
  [`spec/lastenheft.md`](../../../spec/lastenheft.md), (7) veröffentlichte Artefakte außerhalb von
  git, (8) der DoD-Punkte-Zähler — alle drei sind **Eigenbauten**, keine Adoption. Sie bleiben als
  Kandidaten-Zeile in der Roadmap stehen.
- **Achse (6) ist es nicht — sie ist hier drin.** Die Closure-Notiz-Pflicht galt als vierter
  Eigenbau; das gepinnte Image liefert sie als **zweite Fähigkeit** des Moduls `planning` (opt-in
  über `closure.dir`), mit fünf eigenen Grund-Codes: `closure-note-missing`, `-thin`,
  `-boilerplate`, `-placeholder`, `-ambiguous`. Damit ist sie dieselbe Klasse wie die vier
  gemessenen Achsen — Trockenlauf, Config-Block, Verdrahtung — und liegt als
  [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md) in dieser Welle. **Ihre
  Adoptions-Schuld ist die kleinste der Welle und die Messung dazu die kürzeste:** über den
  **133** Slice-Notizen in [`done/`](done) (`ls docs/plan/planning/done/slice-*.md | wc -l`) meldet
  der Lauf `0 Befund(e)`, Exit 0, und dieselbe Kopie mit **einer** auf einen Satz gekürzten Notiz
  meldet **1** × `closure-note-thin` — die Null ist gemessen, nicht leer. Über der **Welle**-Ebene
  (`glob: '*.md'`, alle **157** flachen Dateien dort,
  `ls docs/plan/planning/done/*.md | wc -l`) sind es **20** Befunde
  (12 × `closure-note-missing`, 8 × `closure-note-thin`), und die sind eine Struktur-Aussage
  über unsere zweiteilige Wellen-Closure, kein Rückstand (Einzelheiten in slice-129 §1).
  **Der Pin hat an dieser Fähigkeit nichts bewegt:** beide Digests liefern über demselben Baum
  dieselben 20 Befunde in derselben Verteilung; die Bewegung gegenüber der Erstfassung
  (0/86 und 16/104) geht ganz auf den gewachsenen Ruheort.
  **Draußen bleibt von Achse (6) die Skill-Datei** `.harness/skills/closure-note-reviewer.md`
  (`ls .harness/skills/ | wc -l` → **1**, während
  `grep -c 'closure-note-reviewer' internal/emit/templates.go` → **1** sie in jedes Ziel-Repo
  emittiert) — eine Dogfood-Lücke ohne Gate-Charakter; sie bleibt beim Kandidaten.
- **`planning.observations` — die vierte Fähigkeit desselben Moduls, neu in der Spanne, und sie
  bleibt trotzdem draußen.** Sie prüft die **Register-Deckung**: eine zitierte Kennung `<pfad>`
  gilt als nachgewiesen, wenn `<dir>/<pfad>/observation.md` existiert — genau die maschinelle
  Hälfte der Register-Paarung (c), die Baseline-Regelwerk `modul-06-roadmap.md` verlangt, und genau
  die Verzeichnis-Form, auf die [welle-15](done/welle-15-re-baseline.md) dieses Register umgestellt
  hat. **Sie steht in keiner `--print-config`-Ausgabe** — der `diff` der zwei Ausgaben führt sie
  nicht, und der `planning`-Block ist zwischen den Digests unverändert. Ihre Existenz ist deshalb
  **am Verhalten** belegt, nicht am Hilfetext, und der Beleg ist ein Paar: `planning.QUATSCH.dir`
  bricht mit `field QUATSCH not found`, Exit 2 — `planning.observations.dir` läuft durch. Unter
  `v0.65.0` bricht derselbe Block mit `field observations not found`, Exit 2; sie ist also wirklich
  neu. Angenommen werden `dir`, `dirs` und `pattern` (ein ungültiges `pattern` ist Exit 2, ein
  unlesbares `dirs`-Verzeichnis ein Befund — beides gefahren).
  **Ihre Adoptions-Schuld über diesem Baum ist null, und die Null ist rot gegengeprüft.** Mit
  `dir: docs/plan/planning/observations`, `dirs: [docs/plan/planning]` und
  `pattern: 'BEO-[A-Z]+/[a-z0-9-]+'` meldet der Lauf `0 Befund(e)`, Exit 0; eine erfundene Kennung
  in einer `done/`-Notiz meldet **1** × `observation-unregistered`, Exit 1.
  **Zwei Vorgaben taugen für dieses Repo nicht**, und beide erklären, warum die Fähigkeit ohne
  Zutun stumm bleibt: `dirs` zeigt vorgabegemäß auf das Register selbst statt auf die zitierenden
  Pläne, und `pattern` sucht vorgabegemäß die abgeschaffte Nummernform, nicht den Pfad.
  **Und eine dritte Grenze ist gemessen und wiegt schwerer:** Das Modul trennt *Zitat* von
  *Beispiel*. Gezählt werden Prosa und Linktext — beide färben rot, mit Backticks im Linktext wie
  ohne; **blankes Inline-Code ohne Link färbt nicht**. Der Bestand liegt aber überwiegend in dieser
  stummen Form: ``git grep -ohE '\[`BEO-[A-Z]+/[a-z0-9-]+`\]\(' -- '*.md' ':!.harness/baseline' | wc -l``
  → **87** gedeckte Vorkommen gegen
  ``git grep -ohE '`BEO-[A-Z]+/[a-z0-9-]+`' -- '*.md' ':!.harness/baseline' | wc -l`` → **155**
  Inline-Code-Vorkommen insgesamt (keine Erwartungswerte). Die Deckung ist also **echt**, aber
  **schmaler als der Bestand** — wer sie aktiviert, sagt das dazu, sonst entsteht die
  Vollständigkeits-Zusage, die
  [`vollstaendigkeits-zusage-misst-falsche-ebene`](observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  beschreibt.
  **Warum sie trotzdem draußen bleibt:** Sie ist keine der gemessenen Achsen des Kandidaten, aus
  denen diese Welle ihre Identität nimmt, und sie wäre ein **dritter** Slice im selben
  `planning`-Schlüsselbaum neben [slice-125](done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)
  und [slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md) — die §4 unten schon nicht
  gleichzeitig laufen lässt. **Eine Slice-Kennung steht hier deshalb nicht**; sie behauptete eine
  Datei, die es nicht gibt
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Was
  dieser Eröffnungs-Lauf hinterlässt, ist die **Messung**, die den Aktivierungs-Schnitt billig
  macht, und die Feststellung, dass
  [`register-paarung-ohne-gate-modul`](observations/BEO-ALL/register-paarung-ohne-gate-modul/observation.md)
  in seiner `state.md` bereits denselben Sachverhalt trägt — unabhängig hier nachgemessen und
  bestätigt, samt dem dort benannten Punkt, dass `--print-config` die Frage nicht beantwortet.
- **Die zwölf nicht adoptierten Module des Images — vollständig aufgezählt, nicht beispielhaft.**
  Das gepinnte Image führt **22** verfügbare Module
  (`--print-config`, dann `grep -m1 '^# Verfügbar:' | tr ',' '\n' | wc -l`),
  [`.d-check.yml`](../../../.d-check.yml) aktiviert **sieben**
  (`grep -m1 '^modules:' .d-check.yml | tr ',' '\n' | wc -l`), diese Welle nimmt **vier** (§4),
  von denen `planning` mit [slice-125](done/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)
  bereits in der Sieben steht — **zwölf** bleiben draußen. Eine Liste, die nur einen Teil davon nennt, gibt eine Auswahl als
  Vollzähligkeit aus; darum stehen hier alle zwölf. **Zwei davon sind mit `slice-187` neu
  hinzugekommen** und unten eigens gemessen, weil die Erstfassung sie nicht kennen konnte.

  **Fünf liegen neben den gemessenen sechs Regeln:** `tracked`, `structure`, `citations`,
  `sources`, `external`. `tracked` ist der interessanteste Grenzfall — es berührt
  [slice-116](open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md); die Klärung gehört
  dorthin und nicht hierher (§1 dieses Slice misst die Frage, diese Welle nicht).

  **Zwei sind mit dem Pin-Sprung neu — beide gemessen, und ihre Nullen sind ungleich viel wert:**

  - **`workflows`** (21., seit `[0.67.0]`) prüft die `uses:`-Referenzen der CI-Workflows auf
    SHA-Pinnung und Rechte-Deklaration. Ohne `dir:`-Block `0 Befund(e)`, Exit 0 — inert wie die
    vier Kandidaten der Welle. **Mit** `dir: .github/workflows` ebenfalls **0**, und diese Null ist
    **rot gegengeprüft**: ein einzelnes `actions/checkout@<40-stelliger-SHA>` auf `@v4` gedreht
    meldet `1 Befund`, `uses-pin-missing`, Exit 1. Das Modul hat hier also Zähne und findet nichts
    — der Bestand ist gepinnt. **S-Kandidat**, kein Wellen-Mitglied: keine der gemessenen Achsen,
    keine Adoptions-Schuld, und die Welle-Identität sind die Achsen des Kandidaten.
  - **`reviews`** (22., seit `[0.73.0]`) prüft die Kante *Code → Review*: ein DoD-Haken, dessen
    Zeile „Review" nennt, verlangt einen Report unter `reviews-dir` mit derselben `slice-<NNN>`-
    Kennung. Mit `done-dir`/`reviews-dir` gesetzt: **0 Befund(e)**, Exit 0. **Diese Null ist
    ausdrücklich nicht verifiziert, und das ist der Befund.** Zwei Gegenproben blieben grün: ein
    erfundener `done/`-Slice mit angehängtem Review-Haken und ohne Report, und — schärfer — der
    **echte** Fall `slice-009`, der in seiner `## 2. Definition of Done` einen Haken mit dem Wort
    „Re-Review" trägt, während `ls docs/reviews/ | grep -c 'slice-009'` **0** liefert.
    `grep -lE '^\s*[-*]\s*\[[ x]\].*Review' docs/plan/planning/done/slice-*.md | wc -l` → **5**
    Kandidaten insgesamt, bei **278** Reports (`ls docs/reviews/*.md | wc -l`). Warum das Modul
    schweigt, ist **nicht** gemessen — seine Kandidaten-Regel ist damit unverstanden, und eine
    Aktivierung auf dieser Grundlage wäre genau das stille Grün, gegen das diese Welle steht
    ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
    Daneben steht eine Form-Frage: Dieses Repo führt seine Review-Zusage überwiegend als **Prosa**
    in §5 *Closure-Trigger*, nicht als DoD-Haken — das Modul sähe sie auch dann nicht, wenn seine
    Regel verstanden wäre. **Eigener Kandidat**, kein Wellen-Mitglied; die Klärung gehört in den
    Aktivierungs-Schnitt.

  **Die anderen fünf bleiben mit gemessenem Grund draußen** — Klon außerhalb des Repos (Stand
  `8ed6952`), netzlos, Mount `:ro`, je ein Lauf `--enable <modul>` über den unveränderten Baum,
  **unter beiden Digests**; keiner der fünf bewegt sich durch den Pin, die Zahlen unten gelten für
  `v0.65.0` und `v0.74.1` gleichermaßen:

  - **`hostpaths` — das einzige der fünf, das heute rot führe, und sein Preis ist gestiegen.** Ohne
    jeden Config-Block: `834 Datei(en) geprüft, 73 Befund(e)`, Exit 1, alle `hostpath-forbidden`,
    über **40** Dateien. **Der Pin hat daran nichts bewegt; der Baum hat es** — die Erstfassung maß
    **22** über 14 Dateien.
    **Und die Verteilung ist die eigentliche Nachricht, nicht die Zahl.** Damals lagen *alle*
    Befunde in `docs/reviews/**`, also in Zeitdokumenten; heute nicht mehr —
    `33` in `docs/plan/planning/done`, `30` in `docs/reviews`, `4` in `docs/plan/planning/open`,
    `3` in `harness/conventions`, `2` in `docs/plan/adr`, `1` in `docs/plan/carveouts/done`
    (Befund-Zeilen nach Verzeichnis ausgezählt). **Damit stehen sechs Befunde in lebenden,
    repo-eigenen Artefakten** — im Adaptions-Block und in zwei ADRs —, und vier weitere in offenen
    Plänen. Ausnehmen lässt sich das Modul nicht: es kennt laut `--print-config` allein `prefixes`,
    kein `exempt-paths`, und der Zeilen-Marker greift nicht.
    **Der Ausweg der Erstfassung ist damit versperrt:** `scan.ignore` auf `docs/reviews/**` deckte
    nur noch **30** der **73** und ließe die Befunde in ADRs und im Adaptions-Block stehen — es war
    schon damals eine Senkung und damit eine ADR
    ([`AGENTS.md`](../../../AGENTS.md) §3.5, s. den nächsten Punkt), jetzt ist es zusätzlich keine
    Lösung mehr. Ein Modul, das rot führt, dessen Adoption an einer Senkung hängt **und** dessen
    Befunde in nach §3.4 eingefrorenen ADRs liegen, ist ein **eigener Kandidat** mit eigener
    Entscheidung, kein Mitglied einer Welle, deren Identität die gemessenen Achsen des Kandidaten
    sind.
  - **`versions` — gemessen und als Wächter verworfen, nicht aufgeschoben.** Ohne Block
    `0 Befund(e)`, unter beiden Digests neu gefahren. **Die Zahlen mit Block und die Sonde darunter
    stammen aus der Erstfassung und sind hier _nicht_ neu gefahren** — sie tragen die Entscheidung
    trotzdem, weil diese an einer **Eigenschaft** des Moduls hängt (es liest Markdown) und nicht an
    einem Bestandswert; wer sie doch bewegen will, fährt sie neu. Mit einem Block auf den
    d-check-Pin (`pin-pattern` auf
    `ghcr\.io/pt9912/d-check:(v…)`, `current-from` auf einen eigens angelegten Markdown-Span) und
    den vom Tool vorgeschlagenen Zeitdokument-Ausnahmen ebenfalls **0**; ohne die Ausnahmen **19**,
    davon **1** in `done/` und **18** in `docs/reviews/**` — keiner in einem lebenden Artefakt.
    Entscheidend ist die Sonde: den gelebten Pin in [`d-check.mk`](../../../d-check.mk) auf
    `v0.11.0` gedreht → **`0 Befund(e)`**; dieselbe Zahl zusätzlich in
    [`AGENTS.md`](../../../AGENTS.md) → **1 Befund**, `version-stale`. Das Modul liest Markdown und
    ist damit **blind für die Datei, die den Pin trägt**; es hält Zweitfassungen gegen eine
    Markdown-Autorität. Eine solche Autorität neu anzulegen verschöbe die unbewachte Kante, statt
    sie zu schließen.
    **Der zweite Gegenstand — der Baseline-Tag — ist entschieden, und zwar dagegen.**
    [ADR-0023](../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 3 verwirft das
    Modul als Wächter der **stillen Hälfte** jenes Verweis-Bestands, den
    [slice-080](done/slice-080-verweis-ueberlebt-tagwechsel.md) misst: das Modul urteilt
    über **Zeichenketten-Frische, nicht über Verweis-Auflösung** — ein Link **ins Leere** unter
    dem aktuellen Tag lässt es schweigen, eine Nennung, die niemand auflösen soll, färbt es rot —,
    es trennt Adresse, datierte Aussage und Operand nicht, und der autoritative Pin steht in einer
    Zeile, die es nicht liest (`grep -c '^BASELINE_TAG' Makefile` → **1**, kein Markdown).
    **Es wird darum auch nicht als Kandidat geführt**
    ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — ein
    Modul, das die falsche Eigenschaft misst, ist kein Wächter im Wartestand. Was die Entscheidung
    hinterlässt, ist kein Slice, sondern ein **Kriterium**: ein Sensor über einem `<tag>`-gescopten
    Bestand wird nur adoptiert, wenn er die drei Klassen an je einem Ist-Beleg trennt. Bestand,
    Kommandos und Status der Entscheidung stehen in der ADR und im
    [ADR-Index](../adr/README.md), nicht zusätzlich hier.
  - **`pins` und `immutable` — der Gegenstand muss erst geschrieben werden.** Beide melden ohne
    Block `0 Befund(e)`, und das ist keine Config-Lücke, sondern eine leere Marker-Menge:
    `git grep -l 'dpin: sha256:' -- '*.md' ':!.harness/baseline' ':!docs/plan/planning' ':!docs/reviews' | wc -l`
    → **0**, dasselbe mit `'immutable: sha256:'` → **0**. Adoption hieße, Marker von Hand zu
    setzen — dieselbe Eigenbau-Klasse wie die Achsen (5), (7) und (8) oben, nur mit geliefertem
    Prüfer.
    **Die zwei Ausschlüsse im Kommando sind nicht Bequemlichkeit, sondern die Korrektur eines
    Messfehlers der Erstfassung**: Ohne sie findet die Suche **sich selbst** — der Satz, der den
    Marker benennt, enthält ihn. Über den ganzen Baum gezählt liefert dieselbe Suche heute **1**
    bzw. **2** Dateien, und alle Treffer sind Sätze *über* den Marker in genau diesem Absatz und in
    [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) §6 — kein einziger ist einer
    ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert):
    ein Kommando neben einer Zahl belegt sie erst, wenn es den Gegenstand schneidet).
    **`immutable` bleibt als benannter Ausweichpfad geführt:** ein absichtlich falscher
    `immutable: sha256:0000…`-Marker auf einer Accepted-ADR meldet **`core-drift`** — das
    hermetische Geschwister derselben Zusage, die
    [slice-127](open/slice-127-adr-immutabilitaet-hat-einen-sensor.md) über `vcs` trägt. Gebraucht
    wird es dort nicht: das Rot über die Range ist hergestellt (Messung 1). Der Hinweis steht in
    slice-127 §6 und ändert dessen Zuschnitt nicht.
  - **`diagrams` — bewacht eine Kennung.** Ohne Block `0 Befund(e)`; mit `fences: [mermaid]` und
    einem Muster auf die vierstellige ADR-Kennung (`regex`, **nicht** `pattern` — der falsche
    Schlüssel bricht fail-closed mit Exit 2) ebenfalls **0**, und die Kontrolle färbt rot: die eine
    ADR-Kennung im Fence von [`roadmap.md`](in-progress/roadmap.md) auf eine nicht vergebene Nummer
    gedreht → **1 Befund**, `diagram-id-undefined`, unter **beiden** Digests. Eine Zeilennummer
    steht hier bewusst nicht: Der Fence wandert mit jeder Roadmap-Änderung, und diese Eröffnung ist
    eine.
    Gegenstand ist **genau eine** Kennung in **einem** der **vier** mermaid-Fences dieses Repos
    (`git grep -c 'mermaid$' -- '*.md' ':!.harness/baseline'` → `roadmap.md:1`, `architecture.md:3`);
    `defined-in` muss zudem eine **Datei** sein — ein Verzeichnis quittiert das Tool mit
    `diagrams.patterns[0].defined-in ist keine Datei`, der Wächter liefe also gegen den ADR-Index
    statt gegen die ADR-Dateien. Kein Bündel-Bezug und kein Schuldenstand: S-Kandidat für die
    Doc-Gate-Härtungs-Zeile der Roadmap.
- **Jede Senkung einer bestehenden Schwelle.** Diese Welle **hebt** nur
  ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids):
  Anheben → Steering-Loop). Stellt sich in einem Slice heraus, dass die Adoption nur durch eine
  Lockerung woanders grün wird, ist das ein ADR und damit ein Rückführungs-Grund, kein Zwischenschritt.
- **Der Pin selbst** ([slice-122](done/slice-122-d-check-pin-v0650.md)) — Trigger, nicht Mitglied.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf done/welle-13-results.md. -->
