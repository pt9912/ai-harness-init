# Welle 10 — Re-Baseline `v3.5.2` → `v5.12.0` — Closure-Notiz

**Welle:** welle-10-re-baseline
**Abschluss:** 2026-09-03
**Verantwortlich:** Planner

## Was wurde geliefert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — *was gelernt wurde*: geliefert · was
funktionierte · was anders lief. Mit ID-Bezug, wo es einen gibt.

**15 Mitglieder, alle in `done/`** — Reihenfolge wie im Plan
([welle-10-re-baseline.md](welle-10-re-baseline.md) §4):

- **Entscheidung und Vollzug:** [slice-080](slice-080-verweis-ueberlebt-tagwechsel.md)
  (ein Verweis in die Baseline überlebt den Tag-Wechsel, Ziel-Form aus
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md)) ·
  [slice-081](slice-081-baum-tauschen-pin-ziehen.md) (Baum getauscht, Pin
  gezogen).
- **Der Baum als Eingabe** — vier Slices, die der Schnitt nicht vorsah:
  [slice-133](slice-133-emittierter-baum-ohne-platzhalter-links.md) und
  [slice-130](slice-130-emitter-entscheidet-jedes-neue-template.md) (zusammen
  der Nachweis für [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)/[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
  im emittierten Repo) · [slice-131](slice-131-praesens-aussage-gegen-den-gepinnten-stand.md) ·
  [slice-132](slice-132-adaptions-block-ohne-totes-ziel.md).
- **Die drei Durchgänge der Ziel-Prozedur:**
  [slice-082](slice-082-adaptions-durchgang.md) (Adaptionen — jeder Eintrag der
  eingefrorenen Bezugsmenge [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)…[`MR-028`](../../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)
  mit Ausgang) · [slice-083](slice-083-form-vergleich-pflichtfelder.md) mit
  [slice-136](slice-136-roadmap-traegt-die-ziel-form.md),
  [slice-147](slice-147-spezifikation-traegt-ihr-id-schema.md) und
  [slice-148](slice-148-architecture-traegt-ihr-id-schema.md) (Form —
  Pflichtfelder in den Singleton-Artefakten) ·
  [slice-084](slice-084-stichprobe-gegen-bestand.md) (Stichprobe gegen den
  Bestand statt gegen das Delta).
- **Nachzug und Korrektur:** [slice-085](slice-085-emittierte-ebene-zieht-nach.md)
  (die emittierte Ebene) · [slice-149](slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md)
  (der trägerlose Rest der Prozedur: dritter Sensor, Trigger-Audit, Register) ·
  [slice-150](slice-150-drei-eintraege-tragen-den-adoptierten-stand.md) (zwei
  falsche Durchgang-1-Ausgänge korrigiert).

**Eine Vorbedingung dieser Closure ist kein Mitglied:**
[slice-154](slice-154-eingefrorene-adr-zeigt-auf-den-wellenplan.md) ist
**wellenlos** geschnitten und geschlossen. Er trägt
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
— ohne sie hielte der `git mv` dieser Welle-Datei nach `done/` eine Adresse in
der eingefrorenen [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md)
tot und `docs-check` dauerhaft rot.

## Was hat funktioniert?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3.

- **Das Closure-Kriterium hing an den Durchgängen, nicht am Pin.** *„Der Pin
  ist eine Zeile; die Durchgänge sind der Gegenstand"*
  ([welle-10-re-baseline.md](welle-10-re-baseline.md) §3) hat die Welle
  davor bewahrt, mit einem gesetzten `BASELINE_TAG` als fertig zu gelten.
- **Die eingefrorene Bezugsmenge machte Durchgang 1 abschließbar.** Ein
  Abdeckungs-Kriterium über `grep -c '^### MR-' harness/conventions.md` wäre per
  Konstruktion unerfüllbar: die Menge wächst mit jedem Architect-Lauf, den die
  Welle selbst auslöst.
- **Das Beobachtungs-Register trug den dritten Risiko-Ausgang real.** Ab
  [slice-137](slice-137-beobachtungs-register-bekommt-seinen-ort.md) gingen
  offene Risiken als Registerzeile ein statt als Folge-Slice in `open/` —
  sichtbar an [slice-149](slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md),
  dessen zwei offene Risiken [`BEO-010`](../observations.md) und
  [`BEO-011`](../observations.md) wurden.

## Was ging anders als geplant?

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — jede Zeile moeglichst mit der Konsequenz,
die daraus schon gezogen wurde (Folge-Slice, Spec-Version).

- **Die Welle wuchs von 6 auf 15 Mitglieder.** Ursache sind zwei benannte
  Klassen im Register: [`BEO-010`](../observations.md) (Re-Baseline ohne
  vorgeschalteten Inventur-Slice — die Form-Pflichten kommen einzeln als
  Nachzügler zurück) und [`BEO-011`](../observations.md) (Sprünge werden
  gesammelt statt einzeln adoptiert). Beide stehen unter der Schwelle und
  warten.
- **Ein Baseline-Sprung ist kein Pin-Wechsel, sondern ein Eingabe-Wechsel.**
  Der Plan inventarisierte den vendored Baum als Verweis-*Ziel*; er ist
  zugleich Test-Eingabe (`test/courseset-fixture.bats`) und Emissions-Kanal
  (`internal/fetch/baseline.go` `DefaultTag`). Der Tausch brach dadurch zwei
  Rang-1-Zusagen im emittierten Repo — behoben in
  [slice-133](slice-133-emittierter-baum-ohne-platzhalter-links.md) und
  [slice-130](slice-130-emitter-entscheidet-jedes-neue-template.md), nicht per
  Carveout.
- **Die CI war von [slice-081](slice-081-baum-tauschen-pin-ziehen.md) bis
  [slice-132](slice-132-adaptions-block-ohne-totes-ziel.md) kein Signal**, und
  der teuerste Posten war nicht das Rot, sondern der blinde Fleck darunter:
  `make mutate` bricht seinen Grün-Vorlauf fail-closed ab und lief in dieser
  Zeit über null Fälle.
- **Ein Delta-Durchgang findet weniger als ein Volltext-Durchgang.** Zwei
  Ausgänge aus [slice-082](slice-082-adaptions-durchgang.md) §9 waren gegen den
  adoptierten Stand falsch; gefunden hat sie der Form-Durchgang
  ([slice-083](slice-083-form-vergleich-pflichtfelder.md) §6), korrigiert
  [slice-150](slice-150-drei-eintraege-tragen-den-adoptierten-stand.md). Die
  Klasse zählt [`BEO-013`](../observations.md).
- **Der Blocker der Closure war die Closure selbst.** Der von Modul 6
  vorgeschriebene `git mv` dieser Welle-Datei nach `done/` macht eine Adresse in
  der nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen
  [`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) tot; er ist
  erst beim Closure-Versuch aufgefallen, nicht beim Schnitt. Ausgang:
  [slice-154](slice-154-eingefrorene-adr-zeigt-auf-den-wellenplan.md) mit
  [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
  dessen Festlegung 4 die Entscheidung künftig **vor** den Move zieht. Die
  Klasse führt [`BEO-017`](../observations.md) (1×, unter der Schwelle) — mit
  drei gemessenen Instanzen und einem geladenen vierten Mitglied.
- **Die Sensor-Belege mussten mehrfach neu gefahren werden**, weil sich der Baum
  zwischen Beleg und Closure bewegte (Reviewer- und Architect-Läufe an
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  und [`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)).
  Ein Gate-Stempel deckt einen Tree, keine Absicht.

## Steering-Loop-Einträge

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 (hier stehen **nur** Beobachtungen, die im
Register 3× erreicht haben; jeder Eintrag nennt seine `BEO-<NNN>`) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (Feld
und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der Backticks; die
**Spec-Lücke** trägt statt `liegt in` ihre `LH-*`-ID — das ist kein Versehen).

**Drei Zeilen des Registers stehen bei ≥ 3×**, alle übrigen darunter
(`grep -oE '\| [0-9]+× \|' docs/plan/planning/observations.md | sort | uniq -c`
→ 11 × `1×`, 3 × `2×`, 2 × `4×`, 1 × `6×`; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Jede der drei bekommt hier ihren Lese-Schritt:

- **Der dritte Risiko-Ausgang bekam seinen Ort** — ein offenes Risiko wandert
  ins Beobachtungs-Register statt in einen Folge-Slice —
  liegt in `docs/plan/planning/observations.md` (`seit slice-137`), gespiegelt
  in den drei Anweisungssätzen unter `.claude/commands/`.
  Auslöser: `BEO-001` (slice-080, slice-081, slice-130, slice-132, slice-133,
  slice-138 — 6×). Die Verkörperung war beim Erstauftreten bereits vollzogen;
  dieser Lese-Schritt bestätigt sie, die Zeile bleibt stehen.
- **Norm-Artefakt ohne benannte schreibende Rolle** — Teil-Ausgang über drei
  Artefaktklassen, zwei davon entschieden: Command-Artefakte über
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (`Proposed`; Annahme trägt [slice-145](../next/slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md)),
  `.claude/agents/*.md` über
  [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
  (`Proposed`; Annahme trägt [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md));
  für die **Spec-Straten** benennt keine Quelle eine Rolle, Träger ist
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md).
  Kein `liegt in`: verkörpert ist noch nichts, beide ADRs stehen auf `Proposed`.
  Auslöser: `BEO-007` (slice-137, slice-144, slice-147, slice-148 — 4×).
- **Ein Fix korrigiert die Ableitung und lässt die Zusage daneben stehen** —
  Teil-Ausgang: für die Unterklasse *zitierter Abschnittsname* existiert der
  Sensor bereits (Modul `anchors` der [`.d-check.yml`](../../../../.d-check.yml)),
  sobald die Nennung als Anker-Link geschrieben ist; die Reparatur der zwei
  Wellen-Anweisungssätze trägt
  [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md).
  Kein neuer Sensor und kein `liegt in`: für jede Unterklasse, in der die Zusage
  kein Anker ist (Skript-Ausgabe, Testname, Prosa-Zahl), bleibt der Ausgang die
  Regel ohne Sensor
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum).
  Auslöser: `BEO-009` (slice-144, slice-131, slice-085, slice-136 — 4×).

## Beobachtungs-Register (Zeiger)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register — der Zähler wird **nicht** hier gepflegt; diese
Sektion ist ein Zeiger und trägt keine Daten.

Der Zähler steht in [`../observations.md`](../observations.md).
Was in dieser Welle **3×** erreicht hat, steht oben unter
*Steering-Loop-Einträge*.

## Folge-Slices

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — **derivativ**: Diese Liste zeigt nur,
das Original ist die Slice-Datei. Jeder genannte Folge-Slice muss als Datei im
Planning-Lifecycle existieren; genannt ohne angelegt ist dieselbe Klasse wie
ein halluziniertes Gate.

**Aus dieser Closure** — alle drei **wellenlos**, kein Mitglied einer Welle:

- [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md) — für die zwei Spec-Straten benennt eine Quelle die schreibende Rolle (`open/`).
- [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md) — [`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md) durchläuft ihren Acceptance-Trigger (`open/`).
- [slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md) — die zwei Wellen-Anweisungssätze nennen die Abschnitte, die die Roadmap führt (`open/`).

**Aus den Closures der Mitglieder, noch nicht geschlossen** (je Zeile der
Mitglieds-Slice, der ihn nannte):

- [slice-073](../open/slice-073-emittierte-doc-gate-module.md) ← slice-085 · [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), [slice-142](../open/slice-142-verweis-form-vor-dem-einfrieren-hat-einen-waechter.md), [slice-143](../open/slice-143-datei-weiter-ausschluss-weicht-dem-referenz-ventil.md), [slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) ← slice-132 · [slice-114](../open/slice-114-jede-aussage-hat-einen-abschnitt.md) ← slice-081 · [slice-139](../open/slice-139-lastenheft-deckt-die-emit-disposition.md) ← slice-130 · [slice-146](../open/slice-146-modul-14-multi-stage-build-abweichungen-deklarieren.md) ← slice-084.

**Nicht aus dieser Welle**, obwohl von Mitgliedern zitiert:
[slice-090](../open/slice-090-freshness-audit-im-ziel.md) und
[slice-091](../open/slice-091-vendored-baum-ohne-anspruch.md) (Mitglieder von
[welle-11](../welle-11-traeger-aussage.md)) ·
[slice-112](../open/slice-112-replay-schritt-hat-keinen-referenten.md) ·
[slice-125](../open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md) ·
[slice-134](../open/slice-134-adr-index-traegt-die-ziel-form.md).

## Verifikation

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 1 — keine Behauptung ohne nachprüfbaren
Anker (Hash, Lauf, Zahl).

**Schritt 1 — Trigger.** Alle **15** Mitglieder liegen in `done/`
(`awk '/^## 4\. Slices/,/^## 5\./' docs/plan/planning/done/welle-10-re-baseline.md | grep -oE '^\| slice-[0-9]+'`
gegen `ls docs/plan/planning/done/`, je Kennung ein Treffer). Der Pin ist
vollzogen: `ls -d .harness/baseline/*/` nennt **ein** Verzeichnis. Die drei
Durchgänge tragen je ihren Beleg (082/150, 083/136/147/148, 084). Alle Zahlen
wandern mit dem Baum und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

Sensor-Läufe, je mit dem Baum, über dem sie liefen:

- **Stand `f602131`, unmittelbar vor dem Closure-Move:** `make gates` → Exit **0**,
  darin `baseline-verify: v5.12.0 OK — 51 Dateien (Integritaet + Vollstaendigkeit, netzlos)`
  und `d-check: 492 Datei(en) geprüft, 0 Befund(e)`.
- **Stand `7485be3` bzw. `88fb255`** — die drei Sensoren außerhalb der Gates:
  `make smoke` → Exit **0**, `smoke: OK — Bootstrap laeuft, Skelett verdrahtet +
  Go-Gates gruen, emittiertes docs-check 0 Befunde out-of-the-box` ·
  `make full-smoke` → Exit **0** mit 16 `full-smoke: OK`-Zeilen und 0
  `FEHLER`-Zeilen · `make mutate` → `mutate: 214 ok, 0 Befund(e)` mit der
  Vollständigkeits-Zeile über allen Fall-Dateien. Verlangt ist `mutate` in
  **dieser** Form und nicht als Exit-Code, weil ein Lauf mit rotem Grün-Vorlauf
  über null Fälle liefe und trotzdem grün aussähe.
- **Warum diese drei nicht erneut gefahren sind:** keine ihrer Eingaben hat sich
  seither bewegt. `git diff --name-only 7485be3..f602131 | grep -vcE '\.md$|^\.d-check\.yml$'`
  → **0** — der Änderungssatz ist Markdown plus die repo-eigene `.d-check.yml`,
  und die emittierte stammt aus `internal/emit/templates/d-check.yml`. Go-Code,
  `harness/tools/`, `test/mutations/` und die Emit-Vorlagen sind unberührt.
  Denselben Satz liefert [slice-149](slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md)
  §7 für seine eigenen Läufe vom 2026-09-01.

**Schritt 2 — Trigger-Audit**, drei Artefaktklassen, ausgeführt in
[slice-149](slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md) DoD (2):

- **Carveouts** (`ls docs/plan/carveouts/CO-*.md`):
  [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) **verlängert mit
  Folge-Slice** ([slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md)
  entscheidet vorher, [slice-113](../open/slice-113-co-001-ist-faellig.md) führt
  aus) · [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) **permanent**,
  betroffenes Gate: keines. Das Welle-Kriterium *„`make gates` grün ohne offenen
  Carveout auf einem Gate dieser Welle"* ist erfüllt: `CO-001` liegt auf
  `shell-lint`, hält es nicht rot, und `shell-lint` ist kein Gate, das diese
  Welle bewegt hat.
- **Bootstrap-aware Gates:** Bestand **keiner**
  (`grep -c bootstrap-aware harness/conventions.md` → **0**) — Feststellung,
  kein Auslassen.
- **ADRs:** die von Plan und Roadmap-Abschnitt zitierten auf ihren
  Re-Evaluierungs-Trigger geprüft, **keiner feuert**; damit kein
  Architect-Verdikt und keine Folge-ADR. Zusätzlich sichtbar wurde, dass zwei
  `Proposed`-ADRs keinen Träger für ihren Acceptance-Trigger hatten — Ausgang
  ist [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md).

**Schritt 3 — die drei Paarungen**, geprüft **nach** dem `git mv`:

- **(a) Anker-Paarung:** genau ein Steering-Loop-Eintrag trägt das Feld
  `liegt in` (`BEO-001` → `docs/plan/planning/observations.md`, `seit slice-137`);
  der Zielort existiert und trägt den Anker
  (`grep -c 'seit slice-137' docs/plan/planning/observations.md` → **1**). Die
  zwei anderen sind *gezählt, nicht verkörpert* und kein Gegenstand der Paarung.
- **(b) Folge-Slice-Paarung:** jeder oben genannte Folge-Slice existiert als
  Datei im Planning-Lifecycle (`ls` je Kennung über `open/ next/ in-progress/ done/`,
  16 Kennungen, 0 Fehlstellen).
- **(c) Register-Paarung:** jede hier zitierte `BEO-<NNN>` hat eine Zeile in
  [`../observations.md`](../observations.md), und jede Registerzeile trägt
  mindestens einen Beleg.

**Nach dem Closure-Move und dem Verweis-Nachzug:** `make docs-check` → Exit **0**,
`d-check: 493 Datei(en) geprüft, 0 Befund(e)`. Unmittelbar nach dem reinen Move,
vor dem Nachzug, waren es **221** Befunde, alle `target-missing` — das ist der
Umfang, den der Nachzug schließt, und zugleich der Beleg, dass das dritte
`ignore-refs`-Paar aus
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
trägt: der eine Befund in der eingefrorenen
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md), den
[slice-154](slice-154-eingefrorene-adr-zeigt-auf-den-wellenplan.md) §7 ohne die
Entscheidung gemessen hat, steht in keinem der beiden Läufe.
