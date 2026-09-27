# MR-073 — d-check-Pin v0.79.0 (Links-Lookahead und Referenz-Definitionen standardmäßig aktiv)

- **Datum:** 2026-09-27
- **Wirksamkeits-Anlass:** slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen.
- **Geltungsbereich:** `d-check.mk` (`DCHECK_IMAGE`/`DCHECK_DIGEST`, Kopfkommentar samt
  Zustandssatz und `--disable`-Listen), `internal/emit/emit.go` (emittierter Default-Pin); setzt
  [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
  fort. Dazu `harness/sensors/slice-mv.md` und `harness/sensors/archive-welle.md` — zwei Sätze,
  die eine Werkzeug-Grenze am gepinnten Digest beschrieben, die dieser Sprung real aufhebt (unten
  gemessen). **Nicht** §Baseline: Die Zeile `d-check:` jener Sektion ist mit
  [`MR-070`](../conventions.md#mr-070--die-baseline-trägt-den-pin-nicht-als-kopie--der-zustand-steht-am-ort-des-gegenstands)
  entfallen — der Zustand steht am Ort des Gegenstands (`d-check.mk` selbst), nicht als Kopie in
  dieser Sektion; dieser Eintrag zieht sie deshalb, anders als sein Vorgänger, nicht nach.
  **Nicht** die Modul-Liste der [`.d-check.yml`](../../.d-check.yml) und **nicht** die emittierte
  Startkonfiguration: Dieser Sprung aktiviert kein neues Modul und setzt keinen neuen
  Opt-in-Schlüssel — was ins emittierte Gate geht, setzt
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel).
  **Nicht** die Methode der Gegenmessung: Sie setzt
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen).
  **Nicht** die Angabe, die ein history-lesender Lauf trägt: Sie setzt
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1. **Nicht** die Reihenfolge einer Aufbau-Anleitung: Sie setzt
  [`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1.
- **Ausgelöst durch Baseline-Stand:** keiner. Ausgelöst hat den Sprung ein Werkzeug-Release, auf
  Anweisung des Auftraggebers vom 2026-09-27. Dieselbe Lage beschreibt
  [`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen).
- **Ersetzt-Baseline-Regel:** keine. Nach dem Wortlaut der Eintrags-Vorlage ist der Eintrag damit
  ein **Fork**, aus demselben Grund wie
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv),
  [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab),
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  und
  [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand):
  ein Pin-Sprung, der eine Fähigkeit verfügbar oder wirksam macht, tritt an keine Baseline-Stelle.
  Das Verdikt steht nach
  [`MR-039`](../conventions.md#mr-039--ein-fehlendes-pflichtfeld-wird-nachgetragen-ein-retirierter-eintrag-bekommt-keines)
  Setzung 3 in diesem Feld.
- **Drei Releases in einem Sprung — bewusste Abweichung vom eigenen Muster.**
  [`MR-052`](../conventions.md#mr-052--d-check-pin-v0741-zwei-module-verfügbar-vierte-ausgabe-spalte)
  bis
  [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
  haben je einen Release gepinnt — eine Patch- oder Minor-Stufe je Eintrag. Dieser Eintrag fasst
  **drei** zusammen: `v0.77.0` (bereits gepinnt, Gegenstand von
  [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand),
  hier nicht neu gemessen) → `v0.78.0` (kein eigener Pin-Eintrag) → `v0.79.0` (der neue Pin).
  Auslöser ist eine explizite Zeitentscheidung des Auftraggebers vom 2026-09-27, kein neues
  Prinzip: Ein künftiger Sprung ohne diese Anweisung kehrt zum Ein-Release-je-Eintrag-Muster
  zurück.
- **Adaption.** Das gepinnte d-check-Image springt **v0.77.0 → v0.79.0**. Der Digest
  `sha256:b4b8756b40d3dcd2670a3f83526cb5e5d727d1a850571f73be31edba248abb40` ist auf den drei Wegen
  aus
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  mit demselben Wert belegt — vom Implementer (`12f30003`) und unabhängig vom Reviewer erneut:
  - Pull: `docker pull ghcr.io/pt9912/d-check:v0.79.0`, Zeile `Digest:`;
  - lokaler RepoDigest:
    `docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.79.0`;
  - Manifest: `docker manifest inspect -v ghcr.io/pt9912/d-check:v0.79.0`, Feld
    `Descriptor.digest`.

  Der **lebende** Pin steht in `d-check.mk` und, daran gekoppelt, in `internal/emit/emit.go`
  ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)).
  Hier steht, wogegen er belegt ist und welchen Sprung er gemacht hat.
- **Zwei Releases liegen zwischen den zwei gepinnten Ständen.** Am lokalen Klon des Werkzeugs
  (`D`):

  ```sh
  git -C "$D" for-each-ref --sort=v:refname \
    --format='%(refname:short) %(creatordate:short)' 'refs/tags/v0.7[89]*'
  ```

  nennt `v0.78.0` und `v0.79.0`. **Keine Erwartungswerte**
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Zweck — drei Releases, nur eines mit Gegenstand.** Beschreibung aus dem CHANGELOG des Klons
  (Fremdquelle):
  - **`v0.77.0`** (Instanz-Identitäts-Ausnahme `allow-if-same-id` für `matrix`): unverändert
    Gegenstand von
    [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand),
    hier nicht erneut gemessen.
  - **`v0.78.0`:** neues, **opt-in** Modul `file` (Zeilen-/Byte-Obergrenzen einer ganzen Datei),
    nicht in `modules:` unserer `.d-check.yml` — kein Gegenstand. `structure` bekommt einen
    zwölften, per-Regel **optionalen** Schlüssel `max-lines`, den unser `structure:`-Block nicht
    setzt — byte-identisches Verhalten ohne den Schlüssel, dieselbe Form wie `allow-if-same-id`
    in
    [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand).
    `--suggest-config ai-harness` erkennt zusätzlich `RB`-Kennungen — ein CLI-Modus, den dieses
    Repo nicht aufruft.
  - **`v0.79.0`:** `links` (bereits aktiv, ohne Opt-in-Schalter) bekommt zwei **standardmäßig
    aktive** Prüfungen — kein Konfigurationsschlüssel, den unsere `.d-check.yml` nicht setzt,
    wirkt auf jeden Lauf des Moduls:
    - eine Adress-Klammer `(…)`, die in ihrer Zeile nicht schließt, darf um genau eine Folgezeile
      desselben Absatzes verlängert werden (Linktext-Klammer `[…]` bleibt strikt zeilenlokal) —
      gilt für `links`, `links.resolve-from`, `anchors`, `matrix`, `external`, `tracked`;
    - eine Link-Referenz-Definition `[label]: ziel "titel"` wird unabhängig von ihrer Verwendung
      geprüft, ein totes Ziel meldet `target-missing` auf der Definitions-Zeile — gilt für fünf
      der sechs Module der gemeinsamen Link-Extraktion (`anchors` behandelt Definitionen nicht).
  - **Kein Breaking Change:** `git -C "$D" log v0.77.0..v0.79.0 --oneline` trägt keinen
    Commit-Betreff mit „Breaking“/„migriert“/„entfernt“ außerhalb zweier interner
    Nachschärfungs-Ketten an denselben zwei `v0.79.0`-Prüfungen (nicht gegenüber `v0.77.0`
    zurückgenommen).
- **Das Fragment: sechs Hunks, fünf Handgriffe unverändert — die sechsfache `--disable
  file`-Ergänzung ist keiner.**
  - Adaption:
    `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@sha256:b4b8756b40d3dcd2670a3f83526cb5e5d727d1a850571f73be31edba248abb40 --print-mk) d-check.mk | grep -c '^[0-9]'`
    ergibt **6** — vom Implementer (`12f30003`) und unabhängig vom Reviewer gemessen, dieselbe
    Zahl wie beim Vorgänger-Sprung
    ([`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)).
  - Die fünf Anker aus
    [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
    §Auflösungs-Trigger treffen die `v0.79.0`-Ausgabe je einmal; die Menge des fünften Handgriffs
    ([`MR-062`](../conventions.md#mr-062--ein-fragment-ziel-ohne-eigenen-config-block-trägt-eine-marke--der-fünfte-handgriff))
    ist unverändert. Sechs Ein-Modul-Recipes bekommen zusätzlich `--disable file` — **kein
    sechster Handgriff**: Die rohe `--print-mk`-Ausgabe von `v0.79.0` liefert diese Ergänzung
    bereits selbst (das Tool disabled für diese Recipes automatisch jedes ihm bekannte, nicht
    aktivierte opt-in-Modul; `file` ist seit `v0.78.0` eines davon). Es gibt keine Entscheidung
    „aktivieren oder deaktivieren“ — nur Wachstum des tool-generierten Anteils, am Diff
    strukturell nachweisbar (Review-Nachvollzug des Umsetzungs-Commits).
- **Strenge-Bilanz: neun von neun aktiven Modulen mit Basis, keine Senkung.** Die Messung steht
  im Commit `21afa8ba`
  ([`MR-051`](../conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)),
  die Werte hier sind von dort übernommen. Gegenmessung nach
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)
  Setzung 2, netzlos, an einer `git archive HEAD`-Kopie ohne Objektspeicher — die Angabe nach
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1 lautet: kein Objektspeicher, keine Packs, keine Alternates, keine losen Objekte. Die
  Kopie für `v0.77.0` trägt `d-check.mk` aus `12f30003~1`, die für `v0.79.0` aus `12f30003`/HEAD.
  Symlinks als Kontrolle: 10 von 10 unter `.claude/rules/` erhalten, 0 reguläre nach der
  Marker-Entwertung.

  Sonde je Modul (vier neu in diesem Nachtrag, fünf zuvor einzeln belegt und hier
  zusammengeführt):

  | Modul | Sonde | Grund-Code |
  |---|---|---|
  | `matrix` | Link `spec/architecture.md` → eine ADR (verbotene Referenz-Richtung `spec-straten` → `adr`); Link `done/slice-werkzeug-erkennt-die-benannte-kennung.md` → eine ersetzte ADR (superseded) — konkrete Kennungen im Commit `21afa8ba` | `matrix-forbidden`, `matrix-inactive` |
  | `spans` | Opener klebt an Text; verschachtelter Link im Linktext; offene Fence am Dateiende | `span-unclosed`, `span-nested-link`, `fence-unclosed` |
  | `planning` | Ruhe-Marker unter *Offene Wellen*, während `in-progress/` einen Slice trägt | `planning-drift` |
  | `targets` | `make`-Zeile in `harness/README.md` ohne Makefile-Rezept | `gate-phantom` |
  | `links` | totes Linkziel; Repo-Escape-Link | `target-missing`, `repo-escape` |
  | `anchors` | Link auf `AGENTS.md` mit erfundenem Anker | `anchor-missing` |
  | `structure` | `done/`-Slice ohne „## 2. Definition of Done“; dünne Closure-Notiz | `section-missing`, `closure-note-thin` |
  | `codepaths`, `ids` | Marker-Entwertungs-Stufe allein (Stufe 2) | `codepath-missing`, `id-unlinked` |

  | Stufe | `v0.77.0` | `v0.79.0` | `diff` voll |
  |---|---|---|---|
  | unverändert | 2070 Dateien, 0 Befunde | 2070 Dateien, 0 Befunde | leer |
  | Marker entwertet | 2070 Dateien, 73 Befunde (36 `codepath-missing`, 37 `id-unlinked`) | 2070 Dateien, 73 Befunde, dieselben | leer |
  | zusätzlich alle neun Sonden | 2074 Dateien, 88 Befunde | 2074 Dateien, 88 Befunde, dieselben | leer |

  **Die Dateizahl ist kein Erwartungswert; tragend ist die 0 der ersten Stufe und die Gleichheit
  der Befundmengen** — volle Zeilen und Verteilung je Grund-Code sind über beide Digests
  identisch: `anchor-missing` 1, `closure-note-thin` 1, `codepath-missing` 36, `fence-unclosed` 1,
  `gate-phantom` 1, `id-unlinked` 40, `matrix-forbidden` 1, `matrix-inactive` 1, `planning-drift`
  1, `repo-escape` 1, `section-missing` 1, `span-nested-link` 1, `span-unclosed` 1,
  `target-missing` 1.

  Damit hat jedes der **neun** aktiven Module (`links`, `anchors`, `ids`, `matrix`, `codepaths`,
  `spans`, `planning`, `targets`, `structure` — `grep -m1 '^modules:' .d-check.yml`) eine Basis.
  **Schluss: keine Senkung** an einem der neun aktiven Module.

  **Quell-Differenz bestätigt den Schluss — mit einer Ergänzung gegenüber Commit `21afa8ba`.**
  An den neun aktiven Modulen bewegt sich zwischen `v0.77.0` und `v0.79.0` `markdown.go` (die
  geteilte Link-Extraktion — Lookahead und Referenz-Definitions-Fund, der Gegenstand dieses
  Sprungs), `structure.go` (+27, der neue opt-in-Schlüssel `max-lines`, den unser
  `structure:`-Block nicht setzt) und `anchors.go` (+3/-0: ein Skip für Referenz-Definitionen —
  dieselbe in §1 des Slice-Plans bereits benannte Ausnahme, dass `anchors` Referenz-Definitionen
  nicht behandelt, keine neue Prüfung); `file.go`/`file_test.go`/`run.go` gehören zum inaktiven
  Modul `file`, `pins.go`/`sources.go` sind keines unserer neun. Die Ergänzung ist inhaltlich
  harmlos und von der Strenge-Bilanz oben unberührt: Die `anchors`-Sonde deckt `anchor-missing`
  auf einem Inline-Link, nicht auf einer Referenz-Definition, und der Skip betrifft nur
  Definitionen — der gemessene Gleichstand bleibt unangetastet.
- **Emitter-Pin gekoppelt.** `TestDefaultImage_MatchesCanonical` und
  `TestDefaultDigest_MatchesCanonical` lesen `d-check.mk`; die Rot-Bedingung ist zweimal gefahren
  — vom Implementer (`12f30003`, Pin nur in `d-check.mk` bewegt → `make test` Exit 2 mit beiden
  Namen) und unabhängig vom Reviewer (Digest verstellt → `TestDefaultDigest_MatchesCanonical` rot
  mit „Drift“; Tag verstellt → `TestDefaultImage_MatchesCanonical` rot mit „Tag-Drift“;
  zurückgesetzt → grün). Die emittierte Startkonfiguration bleibt unverändert
  (`grep -m1 'modules:' internal/emit/templates/d-check.yml` →
  `modules: [links, anchors, ids, matrix, spans]`), und
  [`MR-054`](../conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
  ist nicht berührt. `grep -m1 '^modules:' .d-check.yml` nennt unverändert neun Module.
- **Die zwei Werkzeug-Grenzen, die dieser Sprung real aufhebt — Beleg statt Vorher-Aussage.** Zwei
  Sensor-Dateien (`harness/sensors/slice-mv.md`, `harness/sensors/archive-welle.md`) beschrieben
  am gepinnten `v0.77.0`, dass der Verweis-Nachzug unter `docs/reviews/` ein Ziel hinter dem
  Zeilenumbruch und eine Referenz-Definition stehen lässt und `make docs-check` schweigt — mit
  Bezug auf
  [`ADR-0070`](../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md),
  die selbst unangetastet bleibt (§3.4; ihre Festlegung, dass der Nachzug nur die Link-Form
  schreibt, ist von diesem Sprung nicht berührt — nur die **Konsequenz am Gate** ändert sich).
  Real gegen `v0.79.0` gemessen (Implementer, `0c6ea92c`, und unabhängig der Reviewer mit
  zusätzlicher Vorher/Nachher-Gegenprobe gegen `v0.77.0`): Beide Formen lösen jetzt
  `target-missing` aus, die alte Aussage „schweigt“ ist an `v0.77.0` weiter korrekt und an
  `v0.79.0` falsch. Die zwei Sätze sind auf den neuen Ist-Zustand gezogen.
- **Kein ADR nötig ([`AGENTS.md`](../../AGENTS.md) §3.5).** Die Träger stehen in der
  Strenge-Bilanz oben:
  - Die zwei bewegten Regeldateien tragen einen opt-in-Schlüssel (`structure.max-lines`), der
    ohne ihn byte-identisch bleibt, und eine standardmäßig aktive Erweiterung (`links`), die
    zusätzlich meldet statt Meldungen wegzulassen — eine **Verschärfung**, keine Senkung, und
    Verschärfungen sind nach [`AGENTS.md`](../../AGENTS.md) §3.6 kein ADR-Gegenstand.
  - Auf den datei-scannenden Pfaden sind die Befunde aller neun Module gleich, und jedes hat eine
    eigene Basis (Strenge-Bilanz oben).
  - Die neue Fähigkeit aus `v0.78.0` (`file`, `structure.max-lines`) hat in diesem Repo keinen
    Gegenstand; der Schlüssel wird nicht gesetzt.
- **Was der Sprung ausdrücklich nicht setzt und nicht löst.**
  - Das Modul `file` wird nicht aktiviert, `structure.max-lines` wird nicht gesetzt,
    `--suggest-config` wird nicht aufgerufen — ein Opt-in ohne Objekt wäre eine Entscheidung, die
    niemand getroffen hat (dieselbe Begründung wie `allow-if-same-id` in
    [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)).
  - Die zwei Lücken aus
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
    (Alternates, leere Range) und die übrigen Grenzen aus
    [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
    (Instanz-Identitäts-Ausnahme am Bestand ungemessen, VCS-Port nicht gefahren) stehen
    unverändert — kein Träger dieses Sprungs bewegt sie.
- **Grenze.**
  - **Die Gegenmessung fährt den VCS-Port nicht.** Sie läuft über einer `git archive`-Kopie ohne
    `.git`; die Angabe nach
    [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
    Setzung 1 trägt sie je Lauf (oben).
  - **Der Eintrag ist eine datierte Momentaufnahme**
    ([`MR-053`](../conventions.md#mr-053--ein-eintrag-datiert-seine-werkzeug-aussage-statt-den-lebenden-pin-zu-führen)):
    Jede Werkzeug-Aussage nennt `v0.77.0` oder `v0.79.0` als Mess-Operand.
  - **Die Sonde für `citation-out-of-range` blieb in dieser Bilanz stumm** — `codepaths` trägt
    seine Basis hier allein über `codepath-missing` aus der Marker-Entwertungs-Stufe; eine eigene
    Sonde für `citation-out-of-range` lief in diesem Nachtrag nicht.
- **Begründung.**
  - Der Digest ist die Reproduzierbarkeits-Zusage
    ([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)). Der Sprung macht zwei
    standardmäßig aktive `links`-Prüfungen wirksam, ohne ein Modul zu aktivieren oder einen
    Opt-in-Schlüssel zu setzen; er hebt zugleich zwei Werkzeug-Grenzen auf, die zwei
    Sensor-Dateien bislang beschrieben.
  - **Keine Kopf-Marke an
    [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)**
    (und damit auch nicht neu an
    [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst),
    [`MR-064`](../conventions.md#mr-064--d-check-pin-v0761-vcs-bricht-bei-unlesbarem-unterbaum-ab)
    oder
    [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)).
    Fällig wäre sie nach
    [`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
    Setzung 1, wenn dieser Eintrag eine Aussage **namentlich** ablöste. Nichts wird abgelöst: Die
    Aussagen von
    [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
    sind eine datierte Momentaufnahme über `v0.77.0`, und die Pin-Kette ist genau der Fall von
    Setzung 4 dort — ein Pin-Eintrag datiert einen Sprung, er löst keine Aussage ab.
- **Auflösungs-Trigger:** permanent. Bei jedem d-check-Release ist `--print-mk` neu zu erzeugen
  und der Digest neu zu pinnen
  ([`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
  §Auflösungs-Trigger). Die Strenge-Bilanz läuft an den drei Stellen aus dem Auflösungs-Trigger
  von
  [`MR-061`](../conventions.md#mr-061--d-check-pin-v0760-ein-modul-und-eine-structure-bedingung-verfügbar-beide-nicht-aktiv);
  die Gegenmessung folgt
  [`MR-063`](../conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen),
  die Angabe je history-lesendem Lauf
  [`MR-065`](../conventions.md#mr-065--ein-history-lesender-lauf-einer-d-check-bilanz-nennt-woher-sein-klon-die-objekte-liest)
  Setzung 1, die Prüf-Bedingung einer herzustellenden Lage
  [`MR-067`](../conventions.md#mr-067--eine-aufbau-anleitung-nennt-ihre-prüf-bedingung-vor-ihren-kommandos)
  Setzung 1. **Neu zu prüfen** ist die Aussage über `file` und `structure.max-lines`, sobald eines
  der beiden in diesem Repo einen Gegenstand bekommt (Modul aktiviert bzw. Schlüssel gesetzt).
  Die zwei Lücken aus
  [`MR-066`](../conventions.md#mr-066--d-check-pin-v0763-packs-unter-fremdem-präfix-lesbar-range-immer-aufgelöst)
  und die übrigen Grenzen aus
  [`MR-068`](../conventions.md#mr-068--d-check-pin-v0770-instanz-identitäts-ausnahme-verfügbar-ohne-gegenstand)
  tragen ihre eigenen Auflösungs-Trigger fort.
