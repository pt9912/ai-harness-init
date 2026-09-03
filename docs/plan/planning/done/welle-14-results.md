# Welle 14 — Re-Baseline: der vendored Baum zieht auf `v5.18.0` — Closure-Notiz

**Welle:** welle-14-re-baseline
**Abschluss:** 2026-09-03
**Verantwortlich:** Planner

## Was wurde geliefert?

<!-- BEDIENHINWEIS: Ergebnis, nicht Taetigkeit. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — *was gelernt wurde*: geliefert · was
funktionierte · was anders lief. Mit ID-Bezug, wo es einen gibt.

- **Der Pin steht auf `v5.18.0`** — Baum getauscht, alle Pins gezogen
  ([slice-156](slice-156-baum-tauschen-pins-ziehen.md),
  [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
- **Der Form- und Regel-Diff `v5.12.0` → `v5.18.0` liegt als Katalog vor** — 21
  Positionen, jede mit Zuordnung und Ausgang
  ([slice-155](slice-155-inventur-vor-dem-schnitt.md) §9).
- **Adaptions-Durchgang gegen den neuen Stand, Delta *und* Volltext**
  ([slice-157](slice-157-adaptions-durchgang-v5180.md),
  [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)) — die
  Volltext-Hälfte stand als eigener DoD-Punkt, weil
  [`BEO-013`](../observations.md) genau die Fehlerrichtung *bleibt gültig statt
  gegenstandslos* führt.
- **Der Archivierungs-Schritt der Wellen-Closure ist entschieden**, und beide
  Fassungen der Anweisungssätze tragen die Sechs-Schritte-Form
  ([slice-158](slice-158-archivierungs-schritt.md),
  [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren),
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)).
- **Das Beobachtungs-Register trägt die Ziel-Form** — drei Ausgänge als
  geschlossene Menge und die Vorgangs-Beleg-Regel
  ([slice-159](slice-159-register-traegt-die-drei-ausgaenge.md),
  [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)).
- **Die Docker-Form ist gegen die Ziel-Fassung hermetisch geprüft**, Gate und
  Beleg sind getrennt
  ([slice-160](slice-160-docker-form-hermetisch-und-beleg.md),
  [`ADR-0003`](../../adr/0003-go-native-binaries.md)).
- **`harness/conventions.md` trägt die Ziel-Form ihres Kopfes** — Stand als
  Version, Kürzel-Spalte
  ([slice-161](slice-161-conventions-kopf-traegt-die-ziel-form.md)).
- **Die regierende Fassung des Sprungs ist entschieden** und der Ort einer
  künftigen Zielstand-Setzung benannt
  ([slice-163](slice-163-regierende-fassung-des-sprungs.md) →
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
  `Proposed`; Annahme-Träger siehe *Folge-Slices*).
- **Der Emitter klassifiziert die zwei neuen Archiv-Stub-Vorlagen**
  ([slice-164](slice-164-emitter-klassifiziert-die-zwei-neuen-vorlagen.md),
  [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)).
- **Die stummen `v5.12.0`-Nennungen im lebenden Bestand haben ihren Ausgang**
  ([slice-165](slice-165-praesens-aussagen-gegen-v5180.md) und, für die
  Architect-Hälfte in [`AGENTS.md`](../../../../AGENTS.md) §3.7,
  [slice-169](slice-169-agents-37-messstaende-gegen-v5180.md);
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)).

## Was hat funktioniert?

<!-- BEDIENHINWEIS: was du im naechsten Zyklus bewusst wieder so machen wuerdest. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3.

- **Inventur vor dem Schnitt — die Lehre aus
  [welle-10](welle-10-re-baseline.md) hat getragen, und der Unterschied ist
  gemessen.** Diese Welle wurde mit **einem** Mitglied eröffnet (dem
  Inventur-Slice), stand nach dem Katalog bei **8** und schließt mit **11**;
  [welle-10](welle-10-re-baseline.md) wurde mit **6** geschnitten und schloss
  mit **15**. Nach dem Katalog kamen also **3** Mitglieder dazu statt **9**.
  Kommandos: `git log --format=%h --reverse -- docs/plan/planning/welle-14-re-baseline.md`
  und je Stand
  `git show <ref>:docs/plan/planning/welle-14-re-baseline.md | awk '/^## 4\. Slices/,/^## 5\./' | grep -c '^| \[slice-'`;
  für welle-10 dasselbe `awk`/`grep`-Paar auf
  `docs/plan/planning/done/welle-10-re-baseline.md`. Keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Der Katalog trug die Zuordnung, nicht nur die Zahl.** Acht der elf
  Mitglieder stehen seit [slice-155](slice-155-inventur-vor-dem-schnitt.md) §9
  mit Position, Träger und Ausgang; die Slice-Tabelle der Welle ist daraus
  geschnitten statt vorab geschätzt.
- **`make slice-mv` hat jeden Lifecycle-Wechsel selbst nachgezogen** — die
  Verkörperung von [`BEO-003`](../observations.md) hat in dieser Welle
  wiederholt gegriffen (`git log --oneline --grep='^slice-mv:'`). Wo sie *nicht*
  griff, war es die benannte Grenze und keine Überraschung: die eingehende
  Hälfte der präfixlosen Verweis-Form, zweimal von `make docs-check` als
  `target-missing` gemeldet und je Fundstelle repariert.

## Was ging anders als geplant?

<!-- BEDIENHINWEIS: Beobachtungen, keine Schuldzuweisung. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 — jede Zeile moeglichst mit der Konsequenz,
die daraus schon gezogen wurde (Folge-Slice, Spec-Version).

- **Die Annahme von
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  kostete fünf Reviewer-Runden und war der größte Zeitfresser in der Umgebung
  dieser Welle.** Gemessen an ihrer §Geschichte: **5** Runden-Reports
  (`grep -oE 'adr-0028-konsistenz-review[a-z0-9-]*\.md' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md | sort -u | wc -l`),
  davon **4** mit Verdikt *Konsistenz NICHT bestätigt*
  (`grep -c 'Konsistenz NICHT bestätigt' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`);
  keine Erwartungswerte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). **Der Träger war
  [slice-145](slice-145-adr-0028-acceptance-trigger-und-agents-zeiger.md) und
  ist wellenlos** — die Runden zählen nicht auf das Konto dieser Welle, aber
  [slice-158](slice-158-archivierungs-schritt.md) hing an ihrer Linie. Kein
  Befund traf die Entscheidung selbst: alle vier Runden fielen über die
  **Beleg-Form** (Tag am Zitat, Mess-Basis am Kommando, Report-Adresse statt
  Kennung). Die Konsequenz steht bereits als Regel —
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 3 (a)
  macht die Beleg-Form zur Vorbedingung des Accept-Übergangs —, und der Grund,
  warum sie im `Proposed`-Fenster so oft brach, liegt als
  [`BEO-024`](../observations.md) im Register: für eine Präsens-Aussage über ein
  repo-eigenes lebendes Artefakt in einem Text, der eingefroren wird, benennt
  keine Quelle eine Form.
- **Der Baseline-Tausch fiel mitten in eine laufende ADR-Konsistenzprüfung**, und
  ein Tag-Tausch allein trug nicht: `v5.18.0` hat der Wellen-Closure einen
  sechsten Schritt gegeben, also musste ein wörtliches Zitat in Festlegung 1
  nachgezogen werden statt nur ein Pfad. Dieselbe Klasse traf die
  Anweisungssätze selbst (*„fünf Schritte"* gegen sechs) und liegt als achter
  Beleg von [`BEO-009`](../observations.md) im Register.
- **Drei Mitglieder kamen nach dem Katalog dazu**
  ([slice-164](slice-164-emitter-klassifiziert-die-zwei-neuen-vorlagen.md),
  [slice-165](slice-165-praesens-aussagen-gegen-v5180.md),
  [slice-169](slice-169-agents-37-messstaende-gegen-v5180.md)) — **das ist kein
  drittes Auftreten von [`BEO-010`](../observations.md).** Jene Zeile beschreibt
  eine Re-Baseline, die *ohne vorgeschalteten Inventur-Slice* eröffnet wird;
  diese Welle hatte ihn, und die drei Zugänge stammen nicht aus einer Lücke des
  Katalogs, sondern aus dem **Tausch selbst** (beide in
  [slice-156](slice-156-baum-tauschen-pins-ziehen.md) gemessen; 169 ist die
  Architect-Hälfte von 165 nach [`AGENTS.md`](../../../../AGENTS.md) §3.8). Der
  Zähler bleibt bei **2×**; die Frage, die jene Zeile ausdrücklich *„ihrer
  Closure"* übergibt, ist hiermit beantwortet.
- **Eine geschnittene Datei war schon bei der Eröffnung strittig:**
  [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) ist ein
  Sensor-Neubau, den §6 der Welle ausschließt, und zugleich ein Folge-Slice aus
  einem Wellen-Mitglied, für den DoD 5 von
  [slice-155](slice-155-inventur-vor-dem-schnitt.md) eine Zeile in der
  Slice-Tabelle verlangte. Der Einzelfall ist aufgelöst (kein Mitglied, in
  `open/` verbucht), die Klasse nicht — sie liegt als
  [`BEO-018`](../observations.md) im Register.

## Steering-Loop-Einträge

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 3 (hier stehen **nur** Beobachtungen, die im
Register 3× erreicht haben; jeder Eintrag nennt seine `BEO-<NNN>`) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (Feld
und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der Backticks; die
**Spec-Lücke** trägt statt `liegt in` ihre `LH-*`-ID — das ist kein Versehen).

**Fünf Zeilen des Registers stehen bei ≥ 3×**, alle übrigen darunter
(`grep -oE '\| [0-9]+× \|' docs/plan/planning/observations.md | sort | uniq -c`
→ 14 × `1×`, 5 × `2×`, 1 × `3×`, 2 × `4×`, 1 × `6×`, 1 × `8×`; keine
Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). **Jede der fünf trägt bereits einen der drei Ausgänge** — keine
stand beim Lese-Schritt auf `offen`, also entstand hier keine neue
Verkörperung und keine Übergabe an den Architect. Zwei davon
(`BEO-003`, `BEO-014`) haben die Schwelle **seit
[welle-10](welle-10-re-baseline.md) neu** überschritten:

- **Der dritte Risiko-Ausgang bekam seinen Ort** — ein offenes Risiko wandert
  ins Beobachtungs-Register statt in einen Folge-Slice —
  liegt in `docs/plan/planning/observations.md` (`seit slice-137`), gespiegelt
  in den drei Anweisungssätzen unter `.claude/commands/`.
  Auslöser: `BEO-001` (slice-080, slice-081, slice-130, slice-132, slice-133,
  slice-138 — 6×). Verkörpert beim Erstauftreten; dieser Lese-Schritt bestätigt
  sie unverändert.
- **Der Lifecycle-Move zieht seine Verweise selbst nach** — neu über der
  Schwelle (bei der Closure von [welle-10](welle-10-re-baseline.md) noch 2×,
  jetzt 4× durch `slice-157` und `slice-161`) —
  liegt in `Makefile:slice-mv` (`· seit slice-144`), Skript
  `harness/tools/slice-mv.sh`.
  Auslöser: `BEO-003` (slice-137, slice-144, slice-157, slice-161 — 4×).
  Die Verkörperung stand vor dem Übertritt; **neu ist ihre Grenze**, die beide
  Belege dieser Welle getroffen haben: die *eingehende* Hälfte der präfixlosen
  Verweis-Form ist nicht gedeckt, weil ihr das Verzeichnis-Literal fehlt, an dem
  die Ersetzung ankert. Die Registerzeile führt sie benannt und gemessen; eine
  Folge-Slice-Kennung steht dort bewusst nicht, sie behauptete eine Datei, die
  es nicht gibt.
- **Norm-Artefakt ohne benannte schreibende Rolle** — Ausgang weiter
  **geplant**, und ein Teil ist seit der letzten Closure geschlossen:
  [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  steht jetzt auf `Accepted` (Command-Artefakte gehören der ausführenden Rolle).
  Offen bleiben `.claude/agents/*.md`
  ([`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md),
  `Proposed`; Träger [slice-152](../open/slice-152-adr-0029-acceptance-trigger.md))
  und die **Spec-Straten** (Träger
  [slice-151](../open/slice-151-spec-straten-haben-eine-schreibende-rolle.md)).
  Kein `liegt in`: die Zeile schließt erst, wenn auch diese zwei eine
  **angenommene** Quelle haben.
  Auslöser: `BEO-007` (slice-137, slice-144, slice-147, slice-148 — 4×).
- **Ein Fix korrigiert die Ableitung und lässt die Zusage daneben stehen** —
  Ausgang weiter **geplant**
  ([slice-153](../open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md)),
  Zähler in dieser Welle von 4× auf **8×** gestiegen (`slice-159`, `slice-165`,
  `slice-169`, `slice-158`). Kein neuer Sensor und kein `liegt in`: für die
  Unterklasse *zitierter Abschnittsname* deckt das Modul `anchors` der
  [`.d-check.yml`](../../../../.d-check.yml) den Fall, sobald die Nennung ein
  Anker-Link ist; für jede Unterklasse, in der die Zusage **kein** Anker ist
  (Skript-Ausgabe, Testname, Prosa-Zahl, Schritt-Zahl in einem Anweisungssatz),
  bleibt der Ausgang die Regel ohne Sensor
  [`MR-040`](../../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum).
  Der Anstieg um vier Belege in einer Welle ist selbst der Befund: die Klasse
  wächst schneller als ihr Träger.
  Auslöser: `BEO-009` (slice-144, slice-131, slice-085, slice-136, slice-159,
  slice-165, slice-169, slice-158 — 8×).
- **Ein Teil des Adaptions-Blocks beschreibt Buchführung statt Abweichung** —
  neu über der Schwelle, Ausgang **geplant**
  ([slice-168](../open/slice-168-adaptions-eintraege-trennen-abweichung-von-buchfuehrung.md)).
  Kein `liegt in`: am Ende dieser Zeile steht keine verkörperbare Regel, sondern
  ein **Schnitt über den Inhalt** von sechs Einträgen — den macht der Planner,
  das Verdikt je Eintrag schreibt der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der Ausgang ist in §6 dieser
  Welle ausdrücklich außerhalb ihres Umfangs gehalten.
  Auslöser: `BEO-014` (slice-150, slice-166, slice-167 — 3×).

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

- [slice-171](../open/slice-171-adr-0031-acceptance-trigger.md) — Annahme-Träger
  für [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md).
  Geschnitten aus der ausdrücklichen *Offenen Übergabe an den Planner* in
  [slice-163](slice-163-regierende-fassung-des-sprungs.md) §7 und aus dem
  Trigger-Audit unten.
- [slice-170](../done/slice-170-archivierungs-werkzeug.md) — das
  Archivierungs-Werkzeug der Wellen-Closure, hervorgegangen aus
  [slice-158](slice-158-archivierungs-schritt.md); es trägt die Start-Bedingung
  von Schritt 4 (siehe *Archivierung* unten).
- [slice-162](../open/slice-162-versions-sensor-baseline-pins.md) — Versions-Sensor
  gegen Tag-Drift der Baseline-Pins; die Linie trägt
  [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md), nicht diese Welle.
- [slice-168](../open/slice-168-adaptions-eintraege-trennen-abweichung-von-buchfuehrung.md)
  — der `geplant`-Ausgang von [`BEO-014`](../observations.md); von §6 dieser
  Welle ausdrücklich ausgeschlossen.

## Verifikation

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Schritt 1 — keine Behauptung ohne nachprüfbaren
Anker (Hash, Lauf, Zahl).

Die fünf Closure-Kriterien aus §3 der Welle-Datei, jedes einzeln gefahren:

- **Alle Slices dieser Welle liegen in `done/`** — 11 von 11
  (`for s in 155 156 157 158 159 160 161 163 164 165 169; do ls docs/plan/planning/done/slice-$s-*.md; done | wc -l`
  → **11**). Kein Slice trägt `Welle: welle-14` außerhalb dieser Liste
  (`git grep -l 'welle-14' -- 'docs/plan/planning/done/slice-*.md'` gegen das
  `**Welle:**`-Feld je Treffer).
- **`make gates` grün** — EXIT 0 über den Stand vor dem Self-Close-Commit; nach
  dem Commit erneut bestätigt (der Stempel des Stop-Hooks hängt am Tree).
- **`make full-smoke` grün** — EXIT 0. Das ist das *Mehr* dieser Welle: der
  Lauf steht **nicht** im CI-pro-Push-Satz
  ([`harness/README.md`](../../../../harness/README.md) §Sensors) und ist
  zugleich der, an dem der letzte Baum-Tausch brach.
- **Der Pin ist vollzogen** — `make baseline-verify` meldet
  `v5.18.0 OK — 53 Dateien (Integritaet + Vollstaendigkeit, netzlos)`, und
  §Baseline von
  [`harness/conventions.md`](../../../../harness/conventions.md#baseline) nennt
  denselben Tag (`**Stand:** v5.18.0`).
- **Closure-Notiz geschrieben** — diese Datei.

**Trigger-Audit (Schritt 2), alle drei Artefaktklassen:**

- **Carveouts — 2 aktive Dateien, keine offene Schwelle ohne Ausgang**
  (`ls docs/plan/carveouts/CO-*.md | wc -l` → **2**).
  [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) (Gate `shell-lint`):
  Trigger **weiterhin eingetreten**, Ausgang unverändert *verlängert mit
  Folge-Slice* ([slice-113](../open/slice-113-co-001-ist-faellig.md)). Diese
  Welle hat den Bestand nicht bewegt — sie fügte **keine** `.bats`-Datei hinzu
  (`git log --diff-filter=A --name-only -- 'test/*.bats'`: der jüngste Zugang
  stammt aus `slice-144`, vor dieser Welle); Stand heute **20** Dateien
  (`ls test/*.bats | wc -l`), **7** davon mit Verzweigung oder Schleife
  (`grep -lcE '^\s*(if|for|while|case) ' test/*.bats | wc -l`). Keine
  Erwartungswerte.
  [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md): *permanent*,
  übergeführt in [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
  — es gibt keine Schwelle mehr, die wieder eintreten könnte.
  **Kein stilles rotes Gate:** `make gates` ist mit beiden Carveouts an Ort und
  Stelle grün.
- **Bootstrap-aware Gates** — keine Reifestufe dieser Welle stand zum
  Hochschalten an; die Stufung von [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md)
  ist oben behandelt und hängt an `slice-113`, nicht an dieser Closure.
- **ADRs mit Re-Evaluierungs-Trigger** — **3** ADRs stehen auf `Proposed`
  (`grep -l '^\*\*Status:\*\* Proposed' docs/plan/adr/0*.md | wc -l` → **3**).
  Zwei tragen einen benannten Annahme-Träger
  ([`ADR-0029`](../../adr/0029-agenten-typkarten-derivativ-gemischte-originale.md)
  → `slice-152`; [`ADR-0025`](../../adr/0025-register-mit-gemischten-originalen.md)
  → DoD 2 desselben Slice). **Die dritte hatte keinen** —
  [`ADR-0031`](../../adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md)
  aus [slice-163](slice-163-regierende-fassung-des-sprungs.md), dessen §7 das
  Schneiden ausdrücklich dem Planner übergibt. Der Audit hat sie aufgenommen und
  den Träger geschnitten:
  [slice-171](../open/slice-171-adr-0031-acceptance-trigger.md). *Ein Trigger
  ohne Wächter ist eine Absichtserklärung mit Verfallsdatum.*
  Ein zweiter Befund derselben ADR ist an `slice-171` DoD (2) weitergegeben:
  ihr vierter Re-Evaluierungs-Trigger nennt als beobachtbaren Anlass die
  Verzeichnis-Form des Adaptions-Blocks — die **steht** seit `slice-166`
  ([`MR-045`](../../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form))
  —, während seine Bedingung (*„§Baseline verlässt seinen Ort"*) **nicht**
  eingetreten ist (`grep -c '^## Baseline' harness/conventions.md` → **1**).
  Anlass eingetreten, Bedingung offen: dieselbe Fehlerrichtung, die
  [`BEO-020`](../observations.md) führt.

**Archivierung (Schritt 4) — nicht ausgeführt, Start-Bedingung nicht
eingetreten.** Der Schritt verlangt in diesem Repo, dass das
Archivierungs-Werkzeug vorliegt;
[slice-170](../done/slice-170-archivierungs-werkzeug.md) liegt in `open/`, nicht
in `done/` (`ls docs/plan/planning/open/slice-170-*.md`). Diese Welle schließt
deshalb **ohne** Schritt 4 — das ist die im Anweisungssatz vorgesehene
Feststellung und kein Mangel. Von Hand archiviert niemand: die Vollständigkeit
des Archivs bezeugt allein der Archivierungs-Commit, und der Move bräche
dieselben Verweis-Formen wie ein Lifecycle-Wechsel, die `make slice-mv` nur für
die vier Lifecycle-Verzeichnisse nachzieht, nicht eine Ebene tiefer. Die
Zeitdokumente dieser Welle bleiben damit flach in `done/`; der Altbestand ist
nach `v5.18.0`, `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4
ohnehin freigestellt.

**Die drei Paarungen (Ende Schritt 3):**

- **(a) Anker-Paarung** — zwei Einträge oben tragen ein `liegt in`, beide
  Zielorte existieren und tragen ihren Herkunfts-Anker:
  `docs/plan/planning/observations.md` (`seit slice-137`, in der `BEO-001`-Zeile)
  und `Makefile:slice-mv` (`grep -n '· seit slice-144' Makefile` → **1** Treffer,
  Zeile 294, im Kommentarblock des Targets). Die drei übrigen Einträge tragen
  **kein** `liegt in` und sind damit *gezählt, nicht verkörpert* — kein
  Gegenstand der Paarung.
- **(b) Folge-Slice-Paarung** — alle vier genannten Folge-Slices existieren im
  Planning-Lifecycle
  (`for s in 170 171 162 168; do ls docs/plan/planning/*/slice-$s-*.md; done`
  → vier Treffer, alle in `open/`).
- **(c) Register-Paarung** — jede oben zitierte `BEO-<NNN>` hat eine Zeile in
  [`../observations.md`](../observations.md) (`BEO-001`, `BEO-003`, `BEO-007`,
  `BEO-009`, `BEO-010`, `BEO-013`, `BEO-014`, `BEO-018`, `BEO-020`, `BEO-024`),
  und jede Registerzeile trägt mindestens einen Beleg
  (`grep -c '^| BEO-' docs/plan/planning/observations.md` gegen die Belege-Spalte;
  keine Zeile ist leer). Die Umkehrung *„jede Zeile ist irgendwo zitiert"* wird
  nach Modul 6 nicht geprüft.
