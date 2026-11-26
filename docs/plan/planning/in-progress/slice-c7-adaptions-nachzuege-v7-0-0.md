# Slice slice-c7-adaptions-nachzuege-v7-0-0: Adaption-Nachzüge — Terminologie, Stanze und CI-Nachheilung am Stand v7.0.0

**Lifecycle:** Der Zustand dieser Datei ist das Verzeichnis, in dem sie liegt
(`open/`, `next/`, `in-progress/`, `done/`); er wechselt nur durch `git mv`
(Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) —
deren Closure-Trigger trägt das Mehr über die DoD dieses Slice: die Gesamt-Gates
am neuen Stand, der Replay-Lauf `make full-smoke` und der Bestands-Lese-Schritt.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (adoptierter Stand `v7.0.0`) · Form-Bezüge: [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) · [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) · [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) · Tafel-Bezug: Delta-Tafel C7 in [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md) §4 · Übergabe-Quelle: [`slice-c5-vertrauensgrenzen-v7-0-0`](../done/slice-c5-vertrauensgrenzen-v7-0-0.md) §7 (die zwei Adressen namentlich).

**Berührte Spec-Stellen:** `—` — die Terminologie-/Stanze-Formen tragen ihr
Stratum aus dem Baseline-Regelwerk, Modul-14 §Umgebungs-Zusage — Anforderung
vor Träger, §Der zweite Träger, §Zwei Formen des Belegs beim Docker-Träger
(Pfad: `.harness/baseline/v7.0.0/regelwerk/modul-14-docker-harness.md`);
die Anforderungs-Seite steht in der `LH-QA`-ID des Felds Bezug.

**Verantwortlich:** pt9912

**Autor:** pt9912 (Planner-Lauf). **Datum:** 2026-11-26.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die C7-Cluster-Formen als **drei Sub-Züge** — je Sub-Zug sein eigener
Commit mit Rollen-Kennzeichnung, Fundlisten je Kommando ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form):

- **(a) Architect-Sub-Zug — CI-Nachheilung Architektur (rote Jobs `adr-immutable`
  des Laufs `d29be86c`):** der C2-Verweis-Zug `0a080df5` änderte eine Pfad-Zeile
  (`v6.18.1` → `v7.0.0`, Modul-13-Link der Bilanz-Zeile, Z. 134) **im Kern einer
  `Accepted`-ADR** `ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: der Status-Übergang entsteht im Architektur-Sub-Zug, LP1) --> —
  Heilung: **Kern-Revert** auf den Entstehungsstand `39f57f73` nur in dieser
  Pfad-Zeile, plus **Folge-ADR [`ADR-0101`](../../../../docs/plan/adr/0101-die-baseline-verweis-form-in-adrs.md) mit `supersedes`** für die korrigierte
  Verweis-Form der Baseline-Verweise in ADRs (Anker-Form: Inline-Code mit
  Pfad-Angabe statt Markdown-Link auf den rotierenden `.harness/baseline/<tag>/`-Baum),
  damit der nächste Sprung den ADR-Kern nicht mehr berührt; ADR-Index-Update
  ([`AGENTS.md`](../../../../AGENTS.md) §5). Commit-Form: `Rolle Architect: ADR-0101 …` für den Umzug der ADR-0101-Datei in den Index<!-- d-check:ignore (Form-Zitat der Commit-Message, kein Bestand) -->.
- **(b) Implementer-Sub-Zug — CI-Nachheilung Bestand (roter Job `full-smoke`)
  + C5-Übergaben:** [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md)
  — die Skelett-Zahl Z. 513 (`55` → `56`; am Plangrund gemessen:
  `find .harness/baseline -type f | wc -l` → **56**, keine Erwartungswert-Garantie,
  neu je Lauf), die Pfad-Prosa Z. 529 (`spec/spezifikation.md` → `specification.md`,
  die v7-Renamen-Form der Tafel) und die pin-datierten Stellen Z. 816/826
  (Review-F-4/F-5 der d-check-Slice-Linie); dazu die zwei C5-Übergabe-Adressen:
  (i) [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)
  Z. 106–107 — die `v5.12.0`-Pfadzitate der Reviewer-Skill-Messung (8 Fundstellen
  je F2-Kommando des C5-§7) in Messstand-Form je [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist);
  (ii) [`harness/migration.md`](../../../../harness/migration.md) Z. 140–144 —
  die `v6.18.1`-Instanz-Registerzeilen in der `v7.0.0`-Form der Register.
- **(c) Implementer-Sub-Zug — Terminologie-Neufassung Modul-14** (Umgebungs-Zusage
  / Träger / Pin / Check) an den benannten Dogfood-Stellen: [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
  (der Begriff heißt in der v7-Form `Träger der Umgebungs-Zusage` statt
  Reproduzierbarkeits-Anker), die [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)-Titel-/Begriff-Formen,
  die Inventur-Texte in [`internal/emit/baumaussage.go`](../../../../internal/emit/baumaussage.go)
  (Fuß-Texte der `tragerInventur`-Zellen; `InventurMessTag` steht je C1-Zug auf
  `v7.0.0`), die [`traeger-pins-check`](../../../../harness/sensors/traeger-pins-check.md)-/
  `freshness`-Doku-Formen; je veränderte Aussage der Test-Nachzug im selben Zug
  (Rot-Beleg je Zusage, Modul-11-Form). Fundlisten je Sub-Zug stehen in §7.

**[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)-Fundlisten-Form der C5-F2-Schreibweisen:** Pfad-Angaben in Fundlisten
stehen im fenced Block, nicht als Inline-Span (die C5-Form: blanke Kennung im
Span färbt, im fenced Block nicht).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **C6** — übernimmt seine Tafel-Kennung `slice-c6-agents-vorlage-v7-0-0` (die
  AGENTS.md §3.9-Docker-Form nebst dem Umgebungs-Mechanik-Satz). Klasse 1
  (Folge-Slice der Tafel); kein Zweitzug an dieselbe Stelle.
- **Die Verbreiterung eines `ignore-refs`-Eintrags der [`.d-check.yml`](../../../../.d-check.yml)** —
  Klasse 3 wie in C6: ADR-Pflicht (Formen [`ADR-0026`](../../../../docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md)/[`ADR-0039`](../../../../docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)), je Fundstelle der
  `d-check:ignore`-Kommentar.
- **Die übrigen `v6.18.1`-Fundstellen von [`harness/migration.md`](../../../../harness/migration.md)
  jenseits der Registerzeilen Z. 140–144** — Klasse 2: datierte Messung je
  [`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)
  (der Eintrag datiert seine Werkzeug-Aussage statt den lebenden Pin zu führen);
  nur die vom Review adressierten Registerzeilen ziehen.
- **Code-Verhalten jenseits der Inventur-Texte** — Klasse 3: der Emitter-Form-Zug
  trägt C6; hier nur der Fuß-Text der Inventur-Zellen und sein Test-Nachzug.

## 2. Definition of Done

Liefer-Punkte (drei; gezählt nach [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)):

- [x] **LP1 — Architektur-Form-Heilung (Architect-Sub-Zug):** `ADR-0100` <!-- d-check:ignore (Supersedes-Lineage: der Status-Übergang entsteht im Architektur-Sub-Zug, LP1) -->-Kern
  byte-genau am Entstehungsstand je Pfad-Zeile 134 (Revert), [`ADR-0101`](../../../../docs/plan/adr/)
  mit `supersedes` angenommen (Anker-Form der Baseline-Verweise in ADRs),
  ADR-Index-Update; Messung: `make adr-immutable` grün je Range ab `39f57f73`
  (der Wächter über der Kern-Form), `make docs-check` grün.
  **Beleg (Sub-Zug (a), `6d721a64` + `8243ead5`):** der Revert ist byte-gleich am
  Entstehungsstand (§7a-Diff leer), drei Ranges grün (`0a080df5^..HEAD`,
  `39f57f73^..HEAD`, `39f57f73..HEAD` → je `0 Befund(e)`), Gegenprobe über der
  roten Basis `97195c79..HEAD` → 1 Befund (`core-drift-vcs`, Z. 3) je §7a;
  der Rot-Beleg des zehnten Paars steht in §7a (F-1-Heilung, `612f8ec5`);
  `make docs-check` → 0 Befund(e).
- [x] **LP2 — Bestands-Nachzüge (Implementer-Sub-Zug):** die benannten Stellen
  des benutzerhandbuchs (Z. 513, 529, 816/826), [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)-Z. 106–107 und
  migration.md-Z. 140–144 je Fundstellen-Form; Fundliste je Kommando in §7;
  `make docs-check` grün; CI-Klasse (`full-smoke`-Befund) am Welle-Closure-Replay
  belegt.
  **Beleg (Sub-Zug (b), `b3a646c5`; R3-Trail `78d0a0c4`/`a807b933` + `7c750972`):**
  Z. 513 (`56` am `find`-Kommando je §7b), Z. 529 (Zielform `specification.md`),
  Z. 816/826 (Pin `v0.93.0`), [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline)-Z. 106–107 und
  migration.md-Z. 140–144 je Fundstellen-Form (Rest-Fundliste §7b); die drei
  voll-smoke-Funde des R3-Trails stehen in §7b (Baum-Zeile, matrix-downward-Probe,
  `"$(WAVE)"`-Rezept-Zeile nebst Wächter); der `full-smoke`-Lauf färbt bis zur
  Traeger-Fetch-Stufe grün — deren Rest ist der *weiter offen*-Ausgang am Register
  [`BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe`](../observations/BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe/observation.md).
- [x] **LP3 — Terminologie-Formen Modul-14 (Implementer-Sub-Zug):** die
  benannten Stellen — [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)/[`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr) (Begriff/Titel-Formen), baumaussage.go
  Inventur-Texte, traeger-pins-check/freshness-Doku — in der v7-Termini-Form;
  je geänderte Code-Text-Zelle ihr Test-Mitziehen; `make test` (Go-Anteil) grün.
  **Beleg (Sub-Zug (c), `46dfb1b1`):** [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
  trägt die drei Zellen + Terminologie-Merk (Anker-Slug unverändert,
  Review-Urteil 4), [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr)
  trägt keine solche Zelle (Kommando je §7c → 0), baumaussage.go
  0-Fund-Zeilen je §7c (korrigierte Fundliste), `InventurMessTag` auf `v7.0.0`
  je §7c; kein Code-Text-Zug, kein Test-Nachzug (R2: *entfallen*); `make test`
  (Go-Anteil) grün — der gates-Stempel deckt `cf8e88a3`, hinter dem Sub-Zug.

## 4. Trigger

**Start (`open` → `next`, `next` → `in-progress`):**
[`slice-c5-vertrauensgrenzen-v7-0-0`](../done/slice-c5-vertrauensgrenzen-v7-0-0.md)
liegt in `done/` — beobachtbar am Verzeichnis; die Delta-Tafel §4 der [`welle-baseline-sprung-v7-0-0.md`](../welle-baseline-sprung-v7-0-0.md)
trägt C7 als geordneten Vorschlag. `open→next` setzt den Verantwortlichen.
Der Implementer übernimmt.

**Rückführungen — vorab benennen:**
- **`in-progress` → `next` (zu groß / Schnitt falsch):** der Nachzugs-Katalog
  sprengt die drei Liefer-Punkte (die Terminologie-Zeilen laufen über die
  benannten Stellen hinaus oder je Fund verlangt eine Umsetzung, die §1
  ausgeschlossen hat) — dann zurück; die Fundliste bleibt, die Zeilen zerlegen
  sich (Terminologie-Zug erster Trennhieb, CI-Nachheilung bleibt).
- **`in-progress` → `open` (Blocker):** der Kern-Revert scheitert an der
  Wächter-Range (`make adr-immutable` über der Range `39f57f73..d29be86c` hält
  eine zweite Zeile, die `0a080df5` trug) — Blocker mit Carveout-Frage (Modul 7);
  die Fundliste des Diffs ist der Beleg.

## 5. Closure-Trigger

LP1–LP3 je geleistet (Messungen oben); je §6-Risiko ein Ausgang, Lern-Eintrag
in §7, Fundlisten je Sub-Zug.

## 6. Risiken und offene Punkte

- **R1 — der Revert liest in einer inzwischen gewanderten Umgebung:** nach dem
  Revert verweist die Z. 134 auf den `v6.18.1`-Baum, der Bestand daneben auf
  `v7.0.0`.
  **Ausgang (Planner 2026-11-26):** *entfallen* — keine zweite Kern-Zeile (der
  Revert ist byte-gleich am Entstehungsstand, §7a-Diff leer; die Fundliste des
  Diffs trägt die 0); [`ADR-0101`](../../../../docs/plan/adr/0101-die-baseline-verweis-form-in-adrs.md) trägt die Anker-Form und die
  beiden Stande; der `adr-immutable`-Übergang liest *einmal rot über der Basis*
  (`97195c79..HEAD` → `core-drift-vcs` an Z. 3, der Status-Zeile), *danach
  grün* — je §7a-Wortlaut.
- **R2 — Inventur-Texte an Tests hängend:** die Zellen der
  [`internal/emit/baumaussage.go`](../../../../internal/emit/baumaussage.go)
  halten Wächter (`TestTraegerInventur_…`).
  **Ausgang (Planner 2026-11-26):** *entfallen* — kein Code-Text-Zug an den
  Inventur-Zellen (0-Fund-Zeilen je Kommando, §7c in der korrigierten Form je
  F-7), damit kein Test-Nachzug nötig (die Modul-11-Form verlangt ihn je
  geänderter Code-Text-Aussage — keine wurde geändert); die Träger-/Begriffs-Formen
  sitzen im [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)-Terminologie-Merk (`46dfb1b1`).
- **R3 — die Fundstellen der zwei C5-Adressen sind größer als die Übergaben
  nennen** ([`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline): 8 Fundstellen je F2-Kommando; migration.md: 41 je F3 — nur
  5 ziehen): der Zug findet Nachzugs-Zeilen, die keine Übergabe nannte.
  **Ausgang (Planner 2026-11-26):** *entfallen* — die Übergabenzahl hält:
  [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) 8 je F2 (zwei gezogen, sechs Rest-datiert je Fundliste §7b),
  migration.md 41 je F3 (fünf gezogen, 36 Rest-datiert je Fundliste). Der
  R3-Trail trägt die drei voll-smoke-Funde jenseits der Übergaben in §7b —
  *eingetreten*, je Fund Absatz in der Fundliste, Umsetzung `78d0a0c4`/
  `a807b933`/`7c750972` im selben Zug, M-Schätzung nicht gesprengt → keine
  Rückführung nach §4; der Traeger-Fetch-Rest ist der *weiter offen*-Ausgang
  am Register [`BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe`](../observations/BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe/observation.md)
  (Ausgang trägt die Welle-Closure + der Release-Schnitt).

## 7. Closure-Notiz

**Fundlisten der drei Sub-Züge (Implementer, Übergabe-Belege je Kommando, [`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form, gelesen am Stand `46dfb1b1`, 2026-11-26):**

- **(a) Architect-Sub-Zug** — der Kern-Drift ist eine Zeile, byte-genau der Rest am Entstehungsstand:
  ```sh
  diff <(git show 39f57f73:docs/plan/adr/0100-die-gegenmessung-schrumpft-auf-die-einheimische-flaeche.md | sed -n '134p') <(sed -n '134p' docs/plan/adr/0100-die-gegenmessung-schrumpft-auf-die-einheimische-flaeche.md)
  # leer — byte-gleich am Entstehungsstand
  ```
  `make adr-immutable RANGE=0a080df5^..HEAD` → `0 Befund(e)`, `RANGE=39f57f73^..HEAD` → `0 Befund(e)`, `RANGE=39f57f73..HEAD` → `0 Befund(e)`. Gegenprobe über der roten Basis: `RANGE=97195c79..HEAD` → `1 Befund` — `core-drift-vcs` an Z. 3, der Status-Zeile; der Übergang `Accepted` → `Superseded by` zählt dort als Kern-Differenz, solange die Basis die rote Spitze trägt. Die Referenz-Form der Superseded-ADR heißt Inline-Code plus je-Fundstellen-Marker (Vorbild: [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md) `Supersedes`-Feld) — der Zeilen-Marker schaltet das Modul `matrix` nicht stumm (Fund: [`MR-030`](../../../../harness/conventions/MR-030-der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen.md) §Feld). `make docs-check` je Commit → `0 Befund(e)`.
  **Rot-Beleg des zehnten `ignore-refs`-Paars** (Review F-1; Isolationskopie `git archive HEAD`, Grün-Vorlauf über dem Bestand `ok 1`/`ok 2`, je [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)-Form die Meldung erst nach der Kopie):
  ```sh
  KOPIE=$(mktemp -d "/tmp/c7f1probe.XXXX")
  git archive HEAD | tar -x -C "$KOPIE"
  sed -i '410s/# Deckung: 1/# Deckung: 2/' "$KOPIE/.d-check.yml"
  docker run --rm --network none -v "$KOPIE":/repo:ro -w /repo \
    bats/bats@sha256:e8f18e0acd4ea933bf019130b85033be75e8ce081db299e93578de83d7874e33 \
    test/ignore-refs-restbreite.bats
  # docs/plan/adr/0100-die-gegenmessung-schrumpft-auf-die-einheimische-flaeche.md -> .harness/baseline/**: 1 aufloesende(r) Link(s), deklariert sind 2
  ```
  der Lauf endet rot mit genau dieser Befund-Zeile (gemessen am Stand `cf8e88a3`, 2026-11-26); die Kopie wurde nach dem Lauf entfernt, kein Rest im Baum.
  **Übergabe:** der erste Push nach der Heilung färbt den `adr-immutable`-Job einmal (`core-drift-vcs` an der Status-Zeile Z. 3, über der Basis der roten Spitze), der darauffolgende Lauf geht grün — die Datei verlässt mit der `Superseded by`-Status-Form die `immutable-when: Accepted`-Klasse des vcs-Blocks.
  **Übergabe F-3 (Review, LOW, [`AGENTS.md`](../../../../AGENTS.md) §3.4-Form):** [`ADR-0101`](../../../../docs/plan/adr/0101-die-baseline-verweis-form-in-adrs.md) trägt im Kern zweimal den Verweis „Festlegung 2“ (Kontext-Terminal über der toten Adresse, Konsequenzen-Negativ-Bullet) — die ADR trägt keine nummerierte Festlegung; der verwiesene Inhalt steht als Konsequenzen-Bullet. Die Kern-Zeilen bleiben unverändert (der Nachzug darf nicht); die Berichtigung trägt die `## Geschichte`-Zeile der ADR, und die nachgelagerte Stelle des Paar-Kommentars in der `.d-check.yml` zeigt auf das Konsequenzen-Bullet. Die Commit-Meldung `8243ead5` (die Betreff-Zeilen nennen die zwei ADR-Kennungen verlinkt als Bezugs-Historie) ist eingefrorene Historie und wird nicht nachbearbeitet.
- **(b) Implementer-Sub-Zug** —
  ```sh
  find .harness/baseline -type f | wc -l                        # 56
  ls .harness/baseline/v7.0.0/templates/spec/                   # specification.template.md
  grep -n 'DCHECK_IMAGE' d-check.mk                             # v0.93.0
  grep -c 'Kommentar trägt keine' .harness/baseline/v7.0.0/templates/.harness/skills/reviewer.template.md   # 1
  grep -c 'Zustandsfeld trägt Chronik' .harness/baseline/v7.0.0/templates/.harness/skills/reviewer.template.md # 1
  ```
  Rest-Fundstellen unter der Schwelle, datiert geblieben ([`MR-053`](../../../../harness/conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)-Form): [`MR-031`](../../../../harness/conventions.md#mr-031--die-kommentar-regel-steht-in-der-adoptierten-baseline) sechs weitere `v5.12.0`-Zeilen (F2: 38, 40, 42, 56, 86, 87), `harness/migration.md` 36 weitere `v6.18.1`-Fundstellen (F3: Registerzeilen Z. 121–139, 145, Vorlagen-Zuordnung, Streu-Zeilen).
- **R3 — der Lauf fand einen Nachzugs-Fund, den keine Übergabe nannte (*eingetreten*):** `make full-smoke` (Handbuch-Baum-Stufe, [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)) meldete *„vom Lauf angelegt, im Handbuch nicht genannt: harness/sensors/environment-check.md"* — der C4-Emit führt die Vorlage als gestempeltes Singleton im frischen Ziel ([`internal/emit/templates.go`](../../../../internal/emit/templates.go), `inScope`; Zähler in [`internal/emit/templates_test.go`](../../../../internal/emit/templates_test.go) Z. 309). Umsetzung im Zug: Baum-Zeile im Paragraf 6 nachgezogen und die Klassen-Aufzählung um die Vorlagendatei erweitert (Beleg `make smoke`, Pfad im Smoke-Ziel); Pflicht in der M-Schätzung, keine Rückführung (§4).
- **R3 weiter — zwei weitere nicht übergebene Funde des `full-smoke`-Laufs (*eingetreten*):** (i) die matrix-downward-Probe von [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) schrieb den Link hart auf die v6-Form `spezifikation.md` — rot aus falschem Grund (`target-missing` neben `matrix-downward`); der Link trägt jetzt die Zielfassung `specification.md`. (ii) die Rezept-Zeile des emittierten Archivierungs-Fragments reichte den Träger-Aufruf mit dem entstellten Schlüssel weiter (`harness/tools/full-smoke.sh`, Abschnitt Archivierung im Ziel: drei Sperren statt der geplanten zwei) — zurück auf `"$(WAVE)"` ([`ADR-0090`](../../../../docs/plan/adr/0090-altbestand-commit-traegt-die-kennung-des-aufrufers.md)), Wächter neu (`TestArchivierungFragment_RezeptRuftMitWaveKeying`), Rot-Beleg am mutate-once (`"$(WELLE)"` → `FAIL internal/emit`).
- **R3-Übergabe — der Rest, den dieser Zug nicht trägt (*weiter offen*):** die Traeger-Fetch-Stufe von `make full-smoke` bricht mit dem aus `TRAEGER_TAG` `v0.10.0` gefetchten Träger an der `[untergrenze]`-Sperre (Vorschau: Mitglieder 1, wellenlos 1 — der Klon führt nur `slice-997` mit `Welle:` welle-fetch; die Meldung des gefetchten Trägers schreibt `archiv.zip`, die Quelle `archive.zip`). Die zwei Hälften: der gefetchte Träger steht hinter der emitted-Fragment-Erwartung zurück, oder die Stufe erwartet die Vollsatz-Formen in einer Lage, die der Pin nicht führt — die Entscheidung (pin ziehen, Stufe schärfen, Release-Schnitt) ist Planner/Architect-Arbeit; der Vorschau-Wortlaut trägt die Beleg-Datei der Beobachtung [`BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe`](../observations/BEO-ALL/gefetchter-traeger-sperrt-die-archivierungs-stufe/evidence/slice-c7-adaptions-nachzuege-v7-0-0.md). Die übrigen Stufen des Laufs färbten bis zu dieser Stelle grün.
- **(c) Terminologie-Sub-Zug** — korrigierte 0-Fund-Zeilen je Kommando (Review F-7; der frühere Befehl hatte `[MR-051](../../../../harness/conventions.md#mr-051-der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)`-Form mit einem Operanden, den dieses Repo nicht trägt):
  ```sh
  grep -l 'Reproduzierbarkeits\|Zwei Formen' internal/emit/*.go | wc -l    # 0
  grep -rn 'Reproduzierbarkeits-Anker' harness/sensors/                    # 0 Treffer
  grep -rn 'Zwei Formen des'       harness/sensors/                        # 0 Treffer
  ```
  der weitere Treffer der früheren Weite — `harness/sensors/commit-msg-check.md:47` („Zwei Formen erkennt der Matcher nicht…") — gehört der Matcher-Form des Commit-Aufrufs und trägt die Modul-14-Träger-Terminologie nicht; das Verzeichnis „harness/mk“ entsteht erst im gebootstrappten Ziel und kommt in keiner Dogfood-Messung als Operand vor. Die Schlussfolgerung trägt weiter: Kein Code-Text-Zug, damit kein Test-Nachzug (R2: *entfallen*). Die Träger-/Begriffs-Formen sitzen in [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag) (drei Zellen + Terminologie-Merk) und im Index-Ausschnitt; [`MR-047`](../../../../harness/conventions.md#mr-047--der-ort-der-ausführbaren-harness-tools-ist-keine-abweichung-mehr) trägt keine solche Zelle (das Kommando `grep 'Anker\|Repro'` über die Datei desselben Falls → **0**). InventurMessTag steht je C1-Zug auf `v7.0.0` (`grep -n 'const InventurMessTag' internal/emit/baumaussage.go`).

**Lern-Einträge (geschärfte Regeln, `· seit slice-c7-adaptions-nachzuege-v7-0-0`; kein `liegt in`-Feld — gezählt, nicht verkörpert):**

- **(a) Der Rot-Beleg eines Wächters trägt das Übergabe-Artefakt, nicht die
  Commit-Meldung** — die Klasse liest die C5-Fassung *Übergabe-Beleg steht nur
  im Neben-Kontext* ([`BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt`](../observations/BEO-ALL/uebergabe-an-andere-rolle-ohne-traeger-artefakt/observation.md);
  zweites Auftreten, Beleg `evidence/slice-c7-adaptions-nachzuege-v7-0-0.md`):
  der Rot-Lauf des zehnten `ignore-refs`-Paars (Restbreite-Befund, §7a oben)
  trug zuerst allein die Meldung von `8243ead5`; die Heilung trägt §7a
  (`612f8ec5`).
- **(b) Rezept-Nachziehung am Emissions-Interface, zweites Auftreten** — die
  Rezept-Zeile des emittierten Archivierungs-Fragments reichte den Träger-Aufruf
  mit dem entstellten Keying-Schlüssel weiter; gezählt unter
  [`BEO-ALL/interface-formzug-ohne-rezept-nachziehung`](../observations/BEO-ALL/interface-formzug-ohne-rezept-nachziehung/observation.md)
  (Beleg `evidence/slice-c7-adaptions-nachzuege-v7-0-0.md`); Heilung `7c750972`,
  Wächter `TestArchivierungFragment_RezeptRuftMitWaveKeying` samt Rot-Beleg je
  §7b (R3-Trail, *eingetreten*).

## 8. Sub-Area-Prüfungen und Modus-Begründung

Beide vorgelagerten Prüfungen vor dem Block:

1. **Sub-Area-Wahl prüfen:** die berührte Sub-Area ist `*` (gesamtes Repo) —
   der Zug ist eine Stand-/Terminologie-Linie über Konventionsspeicher, Bestands-
   Doku und eine Emitter-Fuß-Text; kein Pfad-Ensemble; Kürzel `ALL` (Modus-Deklaration
   [`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration pro Sub-Area). Schwelle erfüllt.
2. **Offene Beobachtungen sichten:** das
   [Register](../observations/) trägt zu dieser Linie — Terminologie-Stanza,
   Handbuch-Zahl-/-Pfad-Formen, ADR-Verweis-Form — **keine** direkte Beobachtung
   (Sichtung: `grep -rl -i -e terminolog -e benutzerhandbuch -e umgebung
   docs/plan/planning/observations/`, gelesen auf dem Hauptzweig, 2026-11-26;
   die Treffer betreffen Nachbar-Klassen: den Doc-Kommentar-Zahn der
   `slice-191`-Basis und den Image-Pin-Guard). **Keine Treffer sind ebenfalls
   eine Antwort** — Zähler-Stand `—`. Die CI-Befunde selbst sind
   Wellen-Risiken (§6), keine Register-Zähler: ein Auftreten, kein Muster.

**Modus-Begründung:** alle berührten Sub-Areas GF — der Zug übernimmt
Stand- und Terminologie-Formen der Vorlage, kein Bestands-Rückbau; Phase-Reife
Phase 3 (Pfad: `.harness/baseline/v7.0.0/regelwerk/modul-02-harness-bootstrap.md`);
Evidenz-/Diskrepanz-Risiko niedrig (Fundlisten je Kommando gegen den Zug-Stand,
keine Inventur-Spaltung); Reconciliation-Aufwand kein — keine Carveout-Anlage,
Graduation-Trigger entfällt (GF).
