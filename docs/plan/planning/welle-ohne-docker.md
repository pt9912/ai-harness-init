# Welle welle-ohne-docker: Gates und Lab-Läufer docker-los

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-ohne-docker-results.md`). Der Zustand ist die
Verzeichnis-Position — kein Status-Feld.

**Zielmeilenstein:** kein Meilenstein-Bezug (Betriebs-Welle: die Lab-Läufer
und die emittierten Gates, keine Nutzer-Fähigkeit).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-11-27.

---

## 1. Welle-Ziel

<!-- BEDIENHINWEIS: Eine Aussage, die sich an einem Lasttest oder
Akzeptanzkriterium spiegelt. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht.

**Der Mutations-Sensor und die Gates dieses Labors laufen vollständig ohne
Docker-Daemon — und der docker-lose Weg ist im Produkt angekommen:** die
emittierten Gates fahren host-native mit Tool-Pin, `make gates` fährt
out-of-the-box auf einem Host mit nur git + GNU-Basis-Werkzeugen, und ein
voller Mutations-Vollsweep über allen 316 Fällen endet im Bericht statt an
einer Umgebungssperre. Der Container-Weg (gepinnte Images) bleibt als opt-in
Weg gepinnt und ungestrichen — er ist Werkzeug, nicht Pflicht
([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
Die Umgebung docker-los ist **festgelegt und belegt** nach
Baseline-Regelwerk `modul-14-docker-harness.md` §Der zweite Träger: der
Tool-Pin legt fest, der Tool-/Versions-Check (`make environment-check`, erster
Check von `make gates`) belegt.

Zwischenzustände sind **geplant, nicht geduldet**: Bis der letzte Rezept-Slice
schließt, bleibt der Image-Pfad lauffähig unter Docker; der Stop-Hook und die
CI tragen die Übergangs-Mengen, die Slices ihrer selbst tragen. Ein Carveout
ist hier die falsche Antwort — genau wie in
[welle-baseline-sprung-v7-0-0](welle-baseline-sprung-v7-0-0.md) §1.

## 2. Trigger (Welle startet)

<!-- BEDIENHINWEIS: Was muss vorher passiert sein? -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Regeln — ein Trigger ist **beobachtbar** dann, wenn ein *anderer*
Mensch ohne Rückfrage sagen kann, ob er eingetreten ist; ein Datum darf erwähnt
werden, aber nie Trigger sein. Und der **Start**-Trigger ist **kein Ergebnis
dieser Welle**: Steht er in der Slice-Liste unten, ist er falsch platziert.

- **CR-Beschluss des Auftraggebers (2026-11-27):** der Docker-Daemon dieses
  Devhosts ist aus und bleibt für den Betrieb dieses Repos aus — ein
  `make mutate`- oder `make test`-Lauf endet heute an fehlendem Daemon statt
  an einem Fall; beobachtbar als `docker info` Exit ≠ 0 neben einem
  ungetragenen Gate-Lauf.
- **Die Entscheidung umfasst das Produkt:** der emittierte Harness bekommt
  denselben docker-losen Weg (Auftraggeber-Antwort 2026-11-27 auf die
  full-smoke-Vorfrage) — das Lastenheft wird fortgeschrieben, nicht nur der
  Dogfood.

## 3. Closure-Trigger (Welle schließt)

<!-- BEDIENHINWEIS: Aktion, nicht Termin. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht — der Trigger muss das *Mehr* gegenüber den
einzelnen Slice-DoDs benennen; kann er das nicht, liegt keine Welle vor.

- **Alle Slices der Welle (§4) liegen in `done/`.**
- **Der repo-weite Mutations-Beweis, kein Slice-DoD trägt ihn:** ein voller
  Vollsweep (`MUTATE_FORCE=1 make mutate`) über dem **ganzen** Fall-Satz
  (316 Fälle) läuft auf diesem Host **ohne Docker-Daemon** bis zum Bericht
  durch — `mutate: <n> ok, 0 Befund(e)` bzw. Beleg-Übersprung — und der
  rote-Negative über einer manipulierten Inventar-Zeile ist im selben
  Bericht protokolliert.
- **Der repo-weite CI-Beweis, kein Slice-DoD trägt ihn:** ein `ci.yml`-Lauf
  auf frischem Klon fährt `make gates` + `make smoke` + `make full-smoke`
  **ohne Docker-Daemon** grün (Runner-Setup liest den Inventar-Pin).
- **Beide Beweise stehen in der Ergebnis-Notiz**
  (`welle-ohne-docker-results.md`, Geschwister im Ruheort `done/`) — Closure läuft über `/close-welle`.

## 4. Slices in dieser Welle

<!-- BEDIENHINWEIS: keine Status-Spalte ergaenzen. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine — der Zustand eines Slice ist sein
Lifecycle-Verzeichnis und wird hier **nicht** gespiegelt.

Die Kennung ist ein **Link auf die Slice-Datei**; `<lifecycle>` ist das
Verzeichnis, in dem sie gerade liegt (`open`, `next`, `in-progress` oder `done`).
Der Pfad nennt den Ort, keinen Status — er wird beim Übergang des Slice wie jeder
andere Link nachgezogen, und ein Link-Check meldet das fehlende Ziel, wenn es
vergessen wird.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-cr-lh-qa-02-03-ohne-docker](done/slice-cr-lh-qa-02-03-ohne-docker.md) | CR — Lastenheft-Fortschreibung [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/03 | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) · [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [slice-adr-gates-laeufen-host-native](done/slice-adr-gates-laeufen-host-native.md) | ADR — Gates und Lab-Läufer docker-los, §3.9-Passung (Architect) | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [slice-environment-check-fuehrt-die-gates](done/slice-environment-check-fuehrt-die-gates.md) | Tool-/Versions-Check als erster Gate-Check | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [slice-binraire-ziehen-ohne-docker](done/slice-binraire-ziehen-ohne-docker.md) | Binär-Beschaffung ohne Docker (d-check, Träger) | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [slice-labor-gates-host-rezepte](done/slice-labor-gates-host-rezepte.md) | die Gate-Rezepte des Labors laufen host-native | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-waechter-umgebungs-robustheit](done/slice-waechter-umgebungs-robustheit.md) | die Wächter-Suite misst unabhängig von der Werkzeug-Umgebung des Laufs | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-emittierte-gates-host-pfad](done/slice-emittierte-gates-host-pfad.md) | die emittierten Gates fahren host-native | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) |
| [slice-mutate-treiber-host-modi](done/slice-mutate-treiber-host-modi.md) | der Mutations-Treiber fährt docker-los | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [slice-smoke-und-full-smoke-ohne-docker](done/slice-smoke-und-full-smoke-ohne-docker.md) | `smoke` und `full-smoke` laufen ohne Docker | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-full-smoke-gates-echt-gruen](next/slice-full-smoke-gates-echt-gruen.md) | Restmenge: `full-smoke` laeuft ohne Docker vollgruen | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [slice-ci-runner-ohne-docker](done/slice-ci-runner-ohne-docker.md) | CI auf frischem Klon — ohne Docker-Daemon | [`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) |
| [slice-doku-nachzug-ohne-docker](done/slice-doku-nachzug-ohne-docker.md) | Doku-Nachzug der docker-los-Form | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |

## 5. Abhängigkeiten

<!-- BEDIENHINWEIS: Falls jemand diese Welle aendert — was bricht? -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Roadmap-Struktur: fünf Abschnitte.

- **Blockiert nichts** — die offenen Wellen ([welle-09](welle-09-modul-15-konformitaet.md),
  [welle-baseline-sprung-v7-0-0](welle-baseline-sprung-v7-0-0.md)) und die
  wellenlosen `in-progress`-Slices benutzen die Image-Pfade als lauffähig;
  bis der jeweilige Rezept-Slice schließt (siehe §1). Parallele
  Implementer-Läufe folgen dem WIP-Limit je Lauf (Modul 5).
- **Wird blockiert von:** nichts — der Start-Trigger ist der CR-Beschluss
  (§2), er ist eingetreten. Die Binnen-Kanten stehen in den §4-Slice-Plänen
  (je §4 des Plans): CR → ADR → {environment-check, Binär-Zugang} →
  Labor-Rezepte → {emittierte Gates, mutate-Treiber, smoke/full-smoke} → CI →
  Doku-Nachzug als letzter.

## 6. Out-of-Scope für diese Welle

<!-- BEDIENHINWEIS: explizite Nicht-Inhalte, schuetzt vor Scope-Creep. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur, Eröffnung Schritt 1 — Out-of-Scope gehört zur
Zielsetzung: Was nicht ausdrücklich ausgeschlossen ist, dehnt die Welle, bis
der Closure-Trigger unerreichbar wird.

- **Der Release-Schnitt (Tag-Workflow, Tool-Build) bleibt docker-getrieben** —
  er läuft im gepinnten Image, CI-Runner tragen Docker
  ([ADR-0003](../adr/0003-go-native-binaries.md)); die Welle ändert ihn
  nicht ([LH-QA-03](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  nennt den Tool-Build unverändert).
- **Die gepinnten Image-Pfade entfallen nicht** — sie bleiben opt-in Weg und
  gepinnt ([LH-QA-02](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):
  docker-los wird der Pflicht-Pfad, der Image-Pfad bleibt Werkzeug. Ein
  Rückschritt wäre eine Senkung nach §3.5 und brauch eine neue ADR, kein
  Slice dieser Welle.
- **Die 316 Mutations-Fälle werden nicht umgeschrieben** — der Fall-Bestand
  bleibt; nur die Träger ihrer `# verify:`-Modi wandern (Fall-Anker gemessen
  je [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
- **Die Fall-Plattform-Matrix des Produkts** ([`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix))
  — Cross-Compile und Start-Smoke der sechs GOOS/GOARCH-Kombinationen bleiben,
  wie sie sind; nur der Träger des Voll-Smoke-Nachweises (linux/amd64) wechselt.
- **macOS- oder Windows-CI für die Host-Läufer** — die Tragung ist eine
  eigene Architektur-Entscheidung, nicht diese Welle. Der Bestand bleibt:
  [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  (7 Vorgänge, Ausgang *verkörpert*, Auflösungs-Trigger unbefriedigt).

## 7. Closure-Notiz

<!--
BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md §Verwendung,
Schritt 5) und darf deshalb nichts Tragendes halten.

- Erst nach Welle-Abschluss fuellen; nur die Nummer, nicht die volle Welle-ID.
- Ziel-Form der Ergebnis-Notiz: `wave-results.template.md` — Schwester-Vorlage
  im Template-Verzeichnis, kein Artefakt deines Repos. Sie ist von der
  Ruheort-Regel ausgenommen und faellt mit diesem Kommentar ohnehin weg.
-->

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-traceability.md`
§Herkunfts-Anker für Steering-Loop-Regeln — dort die **Ruheort-Regel**: Die
beiden Zeiger unten sind so zu schreiben, wie sie vom Ruheort `done/` auflösen,
nicht vom Schreibort.

Ergebnis: <Zeiger auf `wave-<Kennung>-results.md`, Geschwister im Ruheort `done/`>
Zähler: <Zeiger aufs Beobachtungs-Register, eine Ebene über dem Ruheort>
