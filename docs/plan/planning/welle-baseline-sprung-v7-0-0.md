# Welle <welle-id>: <Titel>

**Lifecycle:** Diese Datei entsteht bei der **Eröffnung** der Welle und liegt
flach unter `docs/plan/planning/`; bei Closure wandert sie per `git mv` nach
`done/` (neben ihre `welle-baseline-sprung-v7-0-0-results.md`). Der Zustand ist
die Verzeichnis-Position — kein Status-Feld.

**Zielmeilenstein:** kein Meilenstein-Bezug (Betriebs-Welle: der adoptierte Stand, keine Nutzer-Fähigkeit).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-11-25.

---

## 1. Welle-Ziel

**Der adoptierte Baseline-Stand wandert `v6.18.1` → `v7.0.0` — committet vendored
([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Form),
alle fünf Pin-Stellen fail-closed gekoppelt gezogen, und am Ende trägt der
Bestand die Delta-Adaption über der Adaptions-Block-Form; `make gates` ist grün.**

Der Sprung ist ein **Major** — der Delta-Umfang ist zu diesem Zeitpunkt nicht
geschätzt, und die Welle schneidet ihn deshalb nicht vorab: Ein Slice
vendorisiert, der zweite liest den neuen Baum gegen den Bestand und erzeugt
Befunde mit Schätzung; die **Cluster-Slices der Adaption** werden aus der Lesung
geschnitten und hier in §4 nachgetragen ([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form
auch für sie). Zwischen dem Vendorier-Slice und der geschlossenen Adaption ist
der Voll-Gate-Lauf **erwartbar rot** — Befund-Zustand unter dem neuen
Regelwerk, geheilt von den Folgeslices **derselben Welle**, nicht mit Carveout
verklebt (ein Carveout wäre hier die falsche Antwort: der Zwischenzustand ist
geplant, nicht geduldet).

**Warum eine Welle.** Es gibt eine Closure-Bedingung, die mehr beobachtet, als
die DoDs ihrer Slices schon belegen (`modul-06-roadmap.md` §Wann Arbeit eine
Welle braucht): `make gates` grün ist hier eine Aussage über den **Gesamt-Baum
nach allen Delta-Änderungen**, nicht über den Ausschnitt eines Slices; der
Replay-Lauf `make full-smoke` über ein frisch gebootstrapptes Ziel am neuen
Stand belegt die emittierte Ebene, die keine einzelne DoD trägt; und der
Bestands-Lese-Schritt liest die offenen Slices unter `open/` gegen die
geschlossene Welle. Keiner dieser drei Belege steht in einer einzelnen DoD.

## 2. Trigger (Welle startet)

- **Start-Trigger: der Slice `slice-gates-fastpfad-ueber-stempel` liegt in `done/`.**
  Beobachtbar: [`slice-gates-fastpfad-ueber-stempel`](done/slice-gates-fastpfad-ueber-stempel.md)
  führt `ls docs/plan/planning/in-progress/` nicht mehr — er liegt in `done/`.
  Er liegt in keiner
  Slice-Liste dieser Welle — er ist kein Ergebnis
  derselben. Zum Eröffnungs-Moment (Datum oben) liegt er noch in
  `in-progress/`: die Eröffnung folgt dem **Auftrag des
  Auftraggebers**, der sie vor dem Slice-Abschluss entschieden hat; die Slices
  dieser Welle übernehmen die Arbeit erst nach seinem Eintreten (ihr §4-Trigger).

## 3. Closure-Trigger (Welle schließt)

- Alle Slices dieser Welle (§4) in `done/`.
- `make gates` grün — über dem **Gesamt-Baum am neuen Stand** , nach der
  geschlossenen Delta-Adaption; die Zwischen-Rots aus §1 sind sie nicht.
- `make full-smoke` grün — der Replay des emittierten Bootstrap: das frisch
  gebootstrappte Ziel bootstrapt out-of-the-box am neuen Baseline-Stand
  ([`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)); der
  Lauf ist der Beleg, den der Vendorier-Slice allein nicht trägt.
- Closure-Notiz in `welle-baseline-sprung-v7-0-0-results.md` mit
  Steering-Loop-Eintrag; der **Bestands-Lese-Schritt** der Welle-Closure liest
  die bestehenden offenen Slices unter `open/`, die diese Closure
  unverändert übersteht (Modul 6 §Wellen-Closure-Prozedur, Schritt 3).

## 4. Slices in dieser Welle

| Slice | Titel | Bezug |
|---|---|---|
| [`slice-baseline-delta-lesung-v7-0-0`](open/slice-baseline-delta-lesung-v7-0-0.md) | Delta-Lesung mit Schätzung | [`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist), [`MR-037`](../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst) |
| [`slice-baseline-vendorung-v7-0-0`](open/slice-baseline-vendorung-v7-0-0.md) | Vendorierung + Pin-Kopplung | [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |

**Reihenfolge (umgestellt am 2026-11-25 — Drift-Log-Eintrag in der
[`roadmap.md`](in-progress/roadmap.md)).** Die Delta-Lesung lief als read-only
Auftraggeber-Auftrag **vor** der Vendorung und ohne Artefakt; ihr Plan
[`slice-baseline-delta-lesung-v7-0-0`](open/slice-baseline-delta-lesung-v7-0-0.md)
schließt über den Geber-Weg nach `done/` (ohne Liefer-Punkte — §7 seines Plans).
Der nächste Arbeitsstand der Welle ist die Vendorung
([`slice-baseline-vendorung-v7-0-0`](open/slice-baseline-vendorung-v7-0-0.md) —
Cluster C1 der Tafel unten). Die Cluster-Slices C2–C7 werden aus der Tafel
geschnitten: ihre Kennungen stehen dort als geordneter Vorschlag, und bis zu
ihrem Schnitt liegt von ihnen keine Slice-Datei vor.

### Delta-Tafel (Les-Stand `v7.0.0`)

**Geführt von** [`slice-baseline-delta-lesung-v7-0-0`](open/slice-baseline-delta-lesung-v7-0-0.md) —
gelesen am 2026-11-25 gegen den Arbeitsbestand der Lesung (Entfaltung des
`v7.0.0`-Release-Assets neben dem `v6.18.1`-Spiegel, beides read-only unter
/tmp). **ZIP-Layout-Verdict: stabil** — gleicher Asset-Name, gleiche Bäume
(`regelwerk/`, `templates/`); der Vendor-Zug braucht keinen neuen
Entfaltungs-Handgriff, nur den neuen Pin.

**Datei-Matrix** über `diff -rq /tmp/ai-course-v618-read/extracted
/tmp/ai-course-v7-read/extracted` (53 Diff-Zeilen — Zahl am Kommando,
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)):
**38 geändert**, **7 umbenannt** (Paare unter `templates/`:
`spezifikation→specification`, `NNNN-titel→NNNN-title`, `welle→wave`,
`welle-results→wave-results`, `archiv-stub-slice→archive-stub-slice`,
`archiv-stub-welle→archive-stub-wave`, `MR-NNN-titel→MR-NNN-title`), **1 neu**
(`templates/harness/sensors/environment-check.template.md`), **0 netto
gelöscht** (7 `Only in` auf der `v6.18.1`-Seite sind die Rename-Paarhälften,
8 auf der `v7`-Seite die 7 Partner + die Neuanlage). **Keine
Hard-Rule-Kollision benannt:** die Lesung trat keine der
[`AGENTS.md`](../../../AGENTS.md) §3-Linien an; keine ist auch eine Antwort.

**Cluster — geordnete Vorschlag.** Je Zeile trägt der Ausgang eine
Cluster-Slice-Kennung ([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Form):
die Slice-Datei wird **beim Schnitt** aus der Zeile angelegt, bis dahin ist die
Kennung Vorschlag; C1 trägt der Bestand. Die S/M/L-Ordner sind **Schätzung**
(deklariert als solche — kein live-Kommando trägt sie); die Reihenfolge folgt
der Adaption-Ebene.

| # | Cluster | Gegenstand | S/M/L (Schätzung) | Ein-Satz-Begründung | betroffene Emissions-Dateien | Ausgang |
|---|---|---|---|---|---|---|
| C1 | Tag-Kern | Vendorung `v7.0.0` + Pin-Kopplung: [`BASELINE_TAG`](../../../Makefile)/`BASELINE_ZIP_SHA256`, das `sources`-Paar in [`.d-check.yml`](../../../.d-check.yml), `DefaultTag`/`DefaultBaselineSHA256` in [`internal/fetch/baseline.go`](../../../internal/fetch/baseline.go), `InventurMessTag` (C1-Emissions-Kante im Vendor-Slice §3), frische `SHA256SUMS`-Form | M | der Zug ist der Umfang, nicht der Baum: fünf Pin-Stellen in einem Zug, der Baum selbst wird gewechselt, nicht angepasst | [`Makefile`](../../../Makefile), [`internal/fetch/baseline.go`](../../../internal/fetch/baseline.go), [`internal/emit/baumaussage.go`](../../../internal/emit/baumaussage.go), [`test/sources-pin.bats`](../../../test/sources-pin.bats) | [`slice-baseline-vendorung-v7-0-0`](open/slice-baseline-vendorung-v7-0-0.md) (Bestand) |
| C2 | Template-Renames + Kennungs-Form | die 7 Template-Renames (die Norm „Dateinamen sind englisch", `grundlagen-harness-dateien.md`), die Platzhalter `welle-`→`wave-` und `archiv.zip`→`archive.zip`, die Kennungs- und Verweis-Formen des emittierten Bestands ziehen nach | L | der Renames-Zug greift über die Dateinamen hinaus — jede emittierte Skeleton-Referenz auf die Vorlagen-Namen liest die alte Form | [`internal/emit/templates.go`](../../../internal/emit/templates.go) (Vorlagen-Namen `welle-results.template.md`/`MR-NNN-titel.template.md`/`NNNN-titel.template.md`), [`internal/emit/emit.go`](../../../internal/emit/emit.go) (`fremdeKennung` `welle-[0-9]+`, `roadmapDoneLink`), emittierte Skeleton-Referenzen unter `docs/plan/planning/` | `slice-c2-template-renames-und-kennungs-formen-v7-0-0` (Vorschlag; Slice-Datei entsteht beim Schnitt) |
| C3 | d-check-Fächer | emittierte Doc-Gate-Konfig am neuen Regelwerk-Stand: `worktrees`-Ignore, kommentierte Standard-Blöcke `planning` und `pinsync`, `planning` verlangt d-check ≥ `v0.91.0` (hier `v0.93.0`) | L | die Konfig-Klassen ziehen je Modul einzeln, und die emittierte Startkonfiguration muss den neuen Stand decken, ohne ihr Modul-Set still zu erweitern ([`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)) | [`internal/emit/templates/d-check.yml`](../../../internal/emit/templates/d-check.yml), [`.d-check.yml`](../../../.d-check.yml) | `slice-c3-d-check-faecher-v7-0-0` (Vorschlag; Slice-Datei entsteht beim Schnitt) |
| C4 | environment-check | die neue Vorlage `templates/harness/sensors/environment-check.template.md` — Neuanlage im Baum, sie kommt mit dem C1-Zug mit | M | das neue Environment-Skript verlangt die Adaption, ob das emittierte Skelett es führt — hier wird entschieden, nicht still ausgespart | kein Pfad unter [`internal/emit/templates/`](../../../internal/emit/templates/) führt `harness/sensors/` (Verifikations-Aussage); die Adaption entscheidet über eine Sensor-Zeile | `slice-c4-environment-check-v7-0-0` (Vorschlag; Slice-Datei entsteht beim Schnitt) |
| C5 | Vertrauensgrenzen | die Texte am neuen Stand, die Vertrauensgrenzen tragen — `architecture` §6, Modul-14-Umbau (Umgebungs-Zusage, Träger, Tool-Pin-Check), Modul-04 (Bedrohung/Grenze/Ausgang) | M | die Texte kommen als Baum mit (C1) und berühren die Referenz-Achse des Bestands — Anker und Verweise, keine Umsetzung | Referenz-Achse: [`.d-check.yml`](../../../.d-check.yml)-Anker-Deckung, [`harness/conventions/`](../../../harness/conventions.md)-Eintragsverweise; kein direkter Skeleton-Griff benannt | `slice-c5-vertrauensgrenzen-v7-0-0` (Vorschlag; Slice-Datei entsteht beim Schnitt) |
| C6 | AGENTS-Vorlage | der AGENTS-Block der Vorlagen (`AGENTS.template.md`) — Docker-Betrieb und Parallele Läufe als übernommener Norm-Satz gegen die eigene §3.9-Lage | M | der Sockel-Norm-Text wird übernommen, wo das Skelett ihn emittiert — kein Regel-Bau, eine Referenz-Adaption | [`internal/emit/templates/agents/`](../../../internal/emit/templates/agents/) | `slice-c6-agents-vorlage-v7-0-0` (Vorschlag; Slice-Datei entsteht beim Schnitt) |
| C7 | Adaption-Nachzüge | die Terminologie und Nachzüge am Adaptions-Block — [`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) feuert (die Inventur- und Stand-Aussagen tragen den neuen Tag), die Nachzüge [`MR-030`](../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen), [`MR-048`](../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag), [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer), [`MR-059`](../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang), [`MR-078`](../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert) sind fällig | M | der Stand-Text zieht in die Aussagen des Konventionsspeichers, nicht in den Code | [`harness/conventions.md`](../../../harness/conventions.md) und die zitierten Eintrags-Dateien | `slice-c7-adaptions-nachzuege-v7-0-0` (Vorschlag; Slice-Datei entsteht beim Schnitt) |

**Zahlen-Belege** ([`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung),
keine Erwartungswerte): die 53 Diff-Zeilen und ihre Aufteilung —
`diff -rq /tmp/ai-course-v618-read/extracted /tmp/ai-course-v7-read/extracted`,
`grep -c '^Files'`, `grep -c '^Only in …v618'`/`…v7`; der ZIP-Hash —
`sha256sum /tmp/ai-course-v7-read/lab-regelwerk.zip`. Die S/M/L-Ordner tragen
kein Kommando — Schätzung.

## 5. Abhängigkeiten

- **Blockiert:** nichts. Die offene Welle
  [`welle-09`](welle-09-modul-15-konformitaet.md) führt einen getrennten
  Gegenstand (Modul-15-Konformität); beide Wellen stehen getrennt.
- **Wird blockiert von:** dem Start-Trigger (§2); werkzeugseitig von der
  Verfügbarkeit des `v7.0.0`-Release-Assets — `make vendor-baseline` braucht
  Netz an genau diesem Aufruf ( [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Form).

## 6. Out-of-Scope für diese Welle

- **Der d-check-Pin-Sprung (v0.93.0)** — er läuft als **wellenloser Slice
  daneben**, nicht hier: die Werkzeug-Fassung ist ein anderer Vorgang
  (d-check-Mechanik `d-check.mk`-Pin, [`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)/[`MR-012`](../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar)-Linie)
  und berührt den Adoptierungs-Gegenstand dieser Welle — den Regelwerk-Baum —
  nicht.
- **Änderungen am emittierten Werkzeug-Verhalten, die nicht aus dem v7-Delta
  folgen** — ein anderer Vorgang: sie gehen aus einzelnen Befund-Arten hervor
  (Futter für einzelne Slices, kein Welle-Gegenstand); die Welle nimmt nur, was
  das Delta verlangt.
- **Das Bestands-Audit der offenen Slices unter `open/`** — es liegt
  an einem **anderen Punkt**: beim Lese-Schritt der **Welle-Closure** (Modul 6
  §Wellen-Closure-Prozedur, Schritt 3 — *„Was den Bestand überlebt hat, bekommt
  denselben Lese-Schritt"*). Hier ausdrücklich dorthin gelegt, nicht still
  fallen gelassen.
- **CI-Workflow-Änderungen** — kein eigener Gegenstand: die CI ruft
  ausschließlich `make`-Targets ([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)) und
  folgt den Gates, sie führt sie nicht. Nur falls das v7-Delta sie verlangt,
  wird sie ein Befund der Lesung — kein eigener Slice vor der Lesung.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen; Verweis auf
welle-baseline-sprung-v7-0-0-results.md (Geschwister im Ruheort done/) und das
Beobachtungs-Register (eine Ebene über dem Ruheort). -->
