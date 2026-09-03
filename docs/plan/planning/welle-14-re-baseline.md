# Welle welle-14: Re-Baseline — der vendored Baum zieht auf den nächsten Stand

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-<NN>-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld. **Geplante Wellen bekommen noch keine
Datei:** Sie stehen in der Roadmap unter *Nächste Wellen* und nirgends sonst —
zwei Positionen, nicht drei.

**Zielmeilenstein:** kein Meilenstein-Bezug — Harness-Wartung, keine Nutzer-Fähigkeit des
Werkzeugs.

**Verantwortlich:** Planner. **Datum:** 2026-09-03.

---

## 1. Welle-Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht.

**Regelwerk und Templates, nach denen dieses Repo arbeitet, stehen auf `v5.18.0` — und jede
Pflicht, die die neue Fassung mitbringt, hat einen verbuchten Ausgang, statt einzeln als Nachzügler
zurückzukommen.**

**Der Schnitt beginnt mit einer Inventur, nicht mit einer Schätzung.** Das ist die Lehre aus
[welle-10](done/welle-10-re-baseline.md), die als `BEO-010` im [Register](observations.md) liegt:
jene Welle schloss mit erheblich mehr Mitgliedern, als sie geschnitten hatte — beide Zahlen stehen
dort neben den Kommandos, die sie ausgeben. Wie viele Mitglieder diese Welle bekommt, beantwortet
[slice-155](done/slice-155-inventur-vor-dem-schnitt.md); vorher steht die Zahl nirgends.

**Wer den Zielstand bewegt, entscheidet diese Datei nicht:**
[`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt*. Welche
Fassung die Migrations-Prozedur dieses Sprungs stellt, ist gemessen
([slice-155](done/slice-155-inventur-vor-dem-schnitt.md) §9 — beide Fassungen führen sie, der
Abschnitt ist byte-gleich) und liegt zur Entscheidung beim Architect:
[slice-163](done/slice-163-regierende-fassung-des-sprungs.md).

## 2. Trigger (Welle startet)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Regeln — ein Trigger ist **beobachtbar** dann, wenn ein *anderer*
Mensch ohne Rückfrage sagen kann, ob er eingetreten ist; ein Datum darf erwähnt
werden, aber nie Trigger sein. Und der **Start**-Trigger ist **kein Ergebnis
dieser Welle**: Steht er in der Slice-Liste unten, ist er falsch platziert.

- **`make baseline-freshness` meldet VERALTET.** Gefahren am 2026-09-03: `gepinnt: v5.12.0`,
  `latest: v5.18.0`, Exit ≠ 0. Beide Angaben wandern mit dem Upstream-Stand und sind keine
  Erwartungswerte
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — beobachtbar ist der Ausgang des Kommandos, nicht die Zahl.
- **[welle-10](done/welle-10-re-baseline.md) liegt in `done/`.** Beobachtbar ohne Rückfrage: die
  Plan-Datei liegt neben ihrer Ergebnis-Notiz. Der Grund ist **ordnend**: Der Sprung geht vom
  adoptierten Stand `v5.12.0` aus, und den hat jene Welle gesetzt.

## 3. Closure-Trigger (Welle schließt)

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht — der Trigger muss das *Mehr* gegenüber den
einzelnen Slice-DoDs benennen; kann er das nicht, liegt keine Welle vor.

- Alle Slices dieser Welle liegen in `done/`.
- `make gates` grün.
- `make full-smoke` grün.
- Der Pin ist vollzogen: `make baseline-verify` meldet `v5.18.0 OK`, und §Baseline von
  [`harness/conventions.md`](../../../harness/conventions.md) nennt denselben Tag.
- Closure-Notiz geschrieben.

**Das *Mehr* sind die zwei repo-weiten Läufe** — sie stehen in keiner einzelnen Slice-DoD, weil
keine einzelne Slice-DoD über den ganzen Baum urteilt.

**Warum genau ein Sensor außerhalb der Gates und nicht vier wie in
[welle-10](done/welle-10-re-baseline.md) §3.** `make smoke` und `make mutate` fährt die CI pro
Push auf frischem Klon ([`harness/README.md`](../../../harness/README.md) §Sensors, CI-Absatz);
`make full-smoke` steht dort **nicht** — und es ist zugleich der Lauf, an dem der letzte
Baum-Tausch brach ([slice-133](done/slice-133-emittierter-baum-ohne-platzhalter-links.md),
unsichtbar für `make gates`). Ein Kriterium, das ein bereits mechanisch ausgelöstes Ziel
wiederholt, beobachtet nichts Zusätzliches.

## 4. Slices in dieser Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine — der Zustand eines Slice ist sein
Lifecycle-Verzeichnis und wird hier **nicht** gespiegelt.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-155](done/slice-155-inventur-vor-dem-schnitt.md) | Inventur vor dem Schnitt — der Form- und Regel-Diff `v5.12.0` → `v5.18.0` | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md) |
| [slice-156](done/slice-156-baum-tauschen-pins-ziehen.md) | Der vendored Baum zieht auf `v5.18.0` — Tausch und Pins | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| [slice-157](done/slice-157-adaptions-durchgang-v5180.md) | Adaptions-Durchgang gegen `v5.18.0` — Delta **und** Volltext | [`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md), [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| [slice-158](in-progress/slice-158-archivierungs-schritt.md) | Der Archivierungs-Schritt der Wellen-Closure — Entscheidung und Sechs-Schritte-Form | [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`ADR-0028`](../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) |
| [slice-159](done/slice-159-register-traegt-die-drei-ausgaenge.md) | Das Beobachtungs-Register trägt die Ziel-Form — drei Ausgänge und die Vorgangs-Beleg-Regel | [`MR-016`](../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird), [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| [slice-160](done/slice-160-docker-form-hermetisch-und-beleg.md) | Die Docker-Form gegen die Ziel-Fassung — hermetischer Prüflauf und die Trennung Gate/Beleg | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0003`](../adr/0003-go-native-binaries.md) |
| [slice-161](done/slice-161-conventions-kopf-traegt-die-ziel-form.md) | `harness/conventions.md` trägt die Ziel-Form ihres Kopfes — Stand als Version, Kürzel-Spalte | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage), [`ADR-0015`](../adr/0015-rollen-eigentum-an-norm-artefakten.md) |
| [slice-163](done/slice-163-regierende-fassung-des-sprungs.md) | Die regierende Fassung des Sprungs — und wo eine Zielstand-Setzung künftig steht | [`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md), [`ADR-0015`](../adr/0015-rollen-eigentum-an-norm-artefakten.md) |
| [slice-164](done/slice-164-emitter-klassifiziert-die-zwei-neuen-vorlagen.md) | Der Emitter klassifiziert die zwei neuen Archiv-Stub-Vorlagen | [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-165](done/slice-165-praesens-aussagen-gegen-v5180.md) | Die stummen `v5.12.0`-Nennungen bekommen ihren Ausgang | [`MR-040`](../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [slice-169](done/slice-169-agents-37-messstaende-gegen-v5180.md) | Die vier Mess-Stände in `AGENTS.md` §3.7 stehen gegen `v5.18.0` | [`MR-040`](../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum), [`AGENTS.md`](../../../AGENTS.md) §3.8 |

**Zeile 11 ist die Rollen-Hälfte von Zeile 10:** die vier Nennungen in
[`AGENTS.md`](../../../AGENTS.md) §3.7 sind gemessen, aber §3 dieser Datei ist Hard Rule und
gehört dem **Architect**. Ein eigener Slice statt eines Nachzugs im Planner-Lauf ist genau der
Zuschnitt, den [`AGENTS.md`](../../../AGENTS.md) §3.8 verlangt.

**Die Zeilen 9 und 10 folgen nicht aus dem Katalog, sondern aus dem Tausch selbst** — beide sind
in [slice-156](done/slice-156-baum-tauschen-pins-ziehen.md) gemessen: der neue Satz bricht
`test/courseset-fixture.bats` an drei Fällen (164), und die stummen Nennungen des abgelösten Tags
im lebenden Bestand haben ihren
[`MR-040`](../../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)-Ausgang
noch nicht (165). Der Katalog ordnet **Positionen** einen Träger zu; eine Position hat mehrere
Konsumenten, und diese zwei hatten keinen.

**Die Zeilen 2–8 stehen seit dem Katalog** in
[slice-155](done/slice-155-inventur-vor-dem-schnitt.md) §9 — 21 gemessene Positionen, jede
mit Zuordnung und Ausgang. Bei der Eröffnung fehlten sie, und das war der Zuschnitt und nicht sein
Mangel: `BEO-010` ([Register](observations.md)) verlangt, dass der Form-Diff vollständig vorliegt,
**bevor** der Rest geschnitten wird; eine vorab geschätzte Mitglieder-Zahl war beim letzten Mal
genau der Fehler. Die Umplanung trägt das Drift-Log der [Roadmap](in-progress/roadmap.md).

**Ein weiterer Slice ist aus demselben Katalog hervorgegangen und hier bewusst kein Mitglied:**
[slice-162](open/slice-162-versions-sensor-baseline-pins.md) (Versions-Sensor gegen Tag-Drift der
Baseline-Pins) ist ein **Sensor-Neubau**, den §6 ausschließt; die Linie trägt
[welle-13](welle-13-regeln-bekommen-ihren-sensor.md). Er liegt in `open/` und ist damit verbucht,
ohne die Welle zu dehnen. Dass die Slice-Tabelle einer Welle und ihre Out-of-Scope-Liste über
dieselbe neue Datei Verschiedenes sagen, liegt als `BEO-018` im [Register](observations.md).

**Aus demselben Grund kein Mitglied:**
[slice-168](open/slice-168-adaptions-eintraege-trennen-abweichung-von-buchfuehrung.md) (die
Adaptions-Einträge trennen Abweichung von Buchführung). Er ist der *geplant*-Ausgang von `BEO-014`
im [Register](observations.md), und `BEO-014` ist genau der Eintrag, den §6 unten ausschließt.

**Kein Mitglied, und nicht aus dem Katalog:**
[slice-170](open/slice-170-archivierungs-werkzeug.md) (das Archivierungs-Werkzeug der
Wellen-Closure) geht aus der Closure von
[slice-158](in-progress/slice-158-archivierungs-schritt.md) hervor und trägt dessen
Start-Bedingung. Ein Werkzeug-Bau ist nicht der Gegenstand dieser Welle, und ihr Closure-Trigger
verlangt ihn nicht. Was das für ihre eigene Archivierung heißt, steht in Schritt 4 des
Anweisungssatzes: Ist die Bedingung bei der Closure nicht eingetreten, ist **das** die
Feststellung in der Ergebnis-Notiz.

## 5. Abhängigkeiten

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Struktur: fünf Abschnitte.

- **Blockiert: [welle-11](welle-11-traeger-aussage.md).** Jede Messung jener Welle läuft über den
  vendored Baum, und diese Welle tauscht genau ihn — derselbe Grund, mit dem ihre §2 bisher die
  Kante zu [welle-10](done/welle-10-re-baseline.md) trug. Ihr Gegenstand bewegt sich dabei real:
  `modul-02-harness-bootstrap.md` ändert sich in diesem Sprung erneut, und der Freshness-Audit ist
  das Thema von [slice-090](open/slice-090-freshness-audit-im-ziel.md).
- **Blockiert: [welle-13](welle-13-regeln-bekommen-ihren-sensor.md).** Zwei ihrer Slices bauen
  Sensoren auf Formen, die dieser Sprung bewegt: der Roadmap-/Verzeichnis-Wächter
  ([slice-125](open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)) und der
  Closure-Notiz-Sensor ([slice-129](open/slice-129-closure-notiz-hat-einen-sensor.md)). Die
  Ziel-Fassung schiebt der Wellen-Closure einen Schritt ein, der die Zeitdokumente einer Welle nach
  `done/<welle-id>/` archiviert und an ihrer Stelle Stubs lässt (`v5.18.0`,
  `modul-06-roadmap.md`, §Wellen-Closure-Prozedur, Schritt 4) — damit ändert sich, was `done/`
  überhaupt enthält. Eine Config gegen ein Artefakt zu schneiden, das im selben Zug getauscht wird,
  ist der Grund, mit dem jene §2 bereits ihre erste Kante trägt.
- **Wird blockiert von: keiner.** [welle-09](welle-09-modul-15-konformitaet.md) läuft eigenständig
  weiter: `modul-15-*` steht nicht im Delta dieses Sprungs
  (`git diff --name-only v5.12.0 v5.18.0 -- lab/regelwerk` am lokalen Kurs-Klon).
- **Die Übergabe an den Architect hat einen Träger:** die regierende Fassung dieses Sprungs ist
  gemessen ([slice-155](done/slice-155-inventur-vor-dem-schnitt.md) §9 — beide Fassungen
  führen die Prozedur, also greift der zweite Fall von
  [`ADR-0018`](../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3) und wird in
  [slice-163](done/slice-163-regierende-fassung-des-sprungs.md) entschieden. Sie blockierte die
  **Eröffnung** nicht — ein Diff-Katalog ist eine Messung und fällt kein Konformitäts-Urteil —,
  und sie blockiert den ersten Durchgang, der eines fällt: darum liegt `slice-163` vor
  [slice-157](done/slice-157-adaptions-durchgang-v5180.md),
  [slice-160](done/slice-160-docker-form-hermetisch-und-beleg.md) und
  [slice-161](done/slice-161-conventions-kopf-traegt-die-ziel-form.md).

## 6. Out-of-Scope für diese Welle

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Eröffnung Schritt 1 — Out-of-Scope gehört zur
Zielsetzung: Was nicht ausdrücklich ausgeschlossen ist, dehnt die Welle, bis
der Closure-Trigger unerreichbar wird.

- **Der Umbau des Adaptions-Blocks in die Verzeichnis-Form** — eine Index-Zeile plus eine Datei je
  Eintrag, statt des Inline-Blocks in
  [`harness/conventions.md`](../../../harness/conventions.md).
  [welle-10](done/welle-10-re-baseline.md) §6 schloss ihn schon aus; er liegt als `BEO-014` im
  [Register](observations.md) und bleibt ein eigener, ungeschnittener Vorgang. Dass die neue
  Fassung die Eintrags-Vorlage anfasst, zieht ihn nicht herein.
- **Die Archivierung des Altbestands** — der geschlossenen Wellen, die vor dieser Adoption
  schlossen. Die Ziel-Fassung stellt sie ausdrücklich frei (`v5.18.0`, `modul-06-roadmap.md`,
  §Wellen-Closure-Prozedur, Schritt 4: *„Kein Zwang zum Nachrüsten — und kein Verbot: Wellen, die
  vor der Einführung schlossen, müssen nicht archiviert werden; ein Repo bleibt ohne das konform."*).
  Ob und ab wann die **laufende** Regel hier gilt, ist eine Position des Katalogs.
- **Sensor-Neubauten** — sie tragen [welle-13](welle-13-regeln-bekommen-ihren-sensor.md).
- **Der d-check-Pin** ([slice-135](open/slice-135-d-check-pin-v0661.md)) — eigene Linie, eigener
  Trigger; er hängt an keiner Baseline-Version.
- **Jede Senkung einer bestehenden Schwelle.** Wird ein Gate nur durch eine Lockerung grün, ist das
  ein ADR ([`AGENTS.md`](../../../AGENTS.md) §3.5) und ein Rückführungs-Grund, kein Zwischenschritt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker für Steering-Loop-Regeln — dort die **Ruheort-Regel**: Die
beiden Zeiger unten sind so zu schreiben, wie sie vom Ruheort `done/` auflösen,
nicht vom Schreibort.

<!-- Erst bei der Closure gefüllt: Ergebnis-Notiz als Geschwister im Ruheort, Zähler eine Ebene
darüber. Beide Zeiger entstehen dort, weil sie vom Schreibort aus ins Leere zeigen. -->
