# Slice slice-baseline-vendorung-v7-0-0: Baseline-Sprung auf v7.0.0 — Vendorierung + Pin-Kopplung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) —
deren Closure-Trigger trägt das Mehr über die DoD dieses Slice: Gesamt-Gates am
neuen Stand, der Replay `make full-smoke` und der Bestands-Lese-Schritt.

**Bezug:** [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(Vendorierung committet vendored, netzlos), [`ADR-0059`](../../../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(das Release trägt `SHA256SUMS` als Asset; der Pin-Hash ist der ZIP-Hash —
Mechanik-Abgrenzung), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).

**Berührte Spec-Stellen:** `—` — der Baseline-Pin steht im Repro-Anker
(`Makefile`-Paar) und im Adaptions-Block, nicht im Spec-Stratum.

**Verantwortlich:** `—` bis zur Priorisierung (Baseline-Regelwerk
`modul-05-planning-harness.md` §Lifecycle als State Machine).

**Autor:** Planner (ai-harness-init-Team, pt9912). **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks.

**Ziel:** `make vendor-baseline` legt den committet vendored Baum aus dem
`v7.0.0`-Release-Asset an (`SHA256SUMS` frisch erzeugt), `make baseline-verify`
hält ihn (Integrität + Vollständigkeit, netzlos), und die **fünf Pin-Stellen**
ziehen fail-closed gekoppelt mit. Der Baum wird hier gewechselt, nicht
angepasst.

**Erwartbare Befundlage — bewusst geplant, kein Carveout.** Der `make gates`-
Lauf nach dem Zug ist erwartbar **rot**: Delta-Befunde unter dem neuen
Regelwerk. Ihre Heilung trägt [`slice-baseline-delta-lesung-v7-0-0`](../done/slice-baseline-delta-lesung-v7-0-0.md)
und die daraus geschnittenen Cluster-Slices — **in derselben Welle**. Eine
Carveout-Fassung wäre hier die falsche Antwort: der Zwischenzustand ist
geplant, nicht geduldet. Die DoD hält die grüne Teil-Achse fest
(`baseline-verify`, Pin-Kopplung) und schuldet die dokumentierte Befundlage
als Übergabe-Artefakt.

**Ausdrücklich NICHT in diesem Slice:**

- **Die Delta-Adaption** (geschärfte Regeln, MR-Text, Anpassung des Bestands an
  das neue Regelwerk) — übernimmt [`slice-baseline-delta-lesung-v7-0-0`](../done/slice-baseline-delta-lesung-v7-0-0.md)
  samt der daraus geschnittenen Cluster-Slices; der Lesungs-Slice liest
  denselben neuen Baum und nimmt die Sendung an (Klasse 1).
- **Die Template-Renames und Kennungs-Forms** (die 7 Umbenennungen der
  `templates/`-Bäume, die Platzhalter `welle-`→`wave-` und
  `archiv.zip`→`archive.zip`, die Kennungs-Formen des emittierten Bestands) —
  übernimmt der Cluster C2 der Delta-Tafel (Zeilvorschlag
  `slice-c2-template-renames-und-kennungs-formen-v7-0-0`,
  [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) §4; die
  Slice-Datei entsteht beim Schnitt — Klasse 1, Adresse über die Tafel-Zeile).
- **Der d-check-Pin-Sprung (v0.93.0)** — wellenloser nebellaufender Slice: die
  Werkzeug-Fassung (`d-check.mk`-Pin, [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Mechanik)
  ist ein anderer Vorgang und berührt den Regelwerk-Baum nicht (Klasse 3).
- **Das `make full-smoke`-Replay am neuen Stand** — Closure-Trigger der Welle
  (§3 der Welle-Datei); es deckt erst über der geschlossenen Adaption und wäre
  hier verfrüht grün (Klasse 1 über die Welle-Datei).

## 2. Definition of Done

- [x] **(1) `make baseline-verify` → OK am neuen Stand:** `.harness/baseline/<tag>/`
      committet vendored, `SHA256SUMS` frisch erzeugt (Integrität +
      Vollständigkeit, netzlos) — [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache).
- [x] **(2) Die fünf Pin-Stellen fail-closed gekoppelt gezogen:**
      `BASELINE_TAG`/`BASELINE_ZIP_SHA256` im [`Makefile`](../../../../Makefile),
      das `sources`-Paar in [`.d-check.yml`](../../../../.d-check.yml),
      `DefaultTag`/`DefaultBaselineSHA256` in
      [`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go);
      die Kopplungs-Gruppe (`test/sources-pin.bats`, `TestDefaultTag_MatchesBaseline`,
      `TestDefaultBaselineSHA256_MatchesMakefile`) grün.
- [x] **(3) Der `make gates`-Lauf nach dem Zug ist ausgeführt und seine
      Befundlage in §7 dokumentiert** (erwartbar rot — Übergabe-Artefakt an
      den Lesungs-Slice), statt still geduldet oder mit Carveout verklebt.
- [x] Doku-Update: [`harness/conventions.md`](../../../../harness/conventions.md)
      §Baseline trägt den neuen `Stand:` (Zustandsfeld, Datum-Zeile daneben).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — weiteres
      Verzeichnis oder weitere Datei in `evidence/`; kein Zähler wird gesetzt,
      er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine
      Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste
      Welle-Closure — hier die [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md)-Closure.

**Belege der Häkchen (Closure 2026-11-25, Planner in eigenem Kontext,
[`AGENTS.md`](../../../../AGENTS.md) §3.10):**

- *(1) Baseline-Verify:* Commit `7afa252c` (vendored Baum
  `.harness/baseline/v7.0.0/`, `SHA256SUMS` frisch erzeugt — 55 Zeilen,
  Baum-Form getrennt von der Asset-Form, [`ADR-0059`](../../../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md));
  Review „Vendored Baum — geprüft, ohne Befund“.
- *(2) Pin-Stellen:* Commit `51649824` (vier Stellen identisch `v7.0.0` /
  `34a7866d…0e`, fail-closed gekoppelt); Review „Pin-Kopplung“ und
  „Pin-Beleg gegen Publikation“ — Release-`SHA256SUMS` von Tag `v7.0.0`
  je Asset-Name mit dem [`Makefile`](../../../../Makefile)-Pin gepaart; die
  Kopplungs-Gruppe grün (§7-Tabelle — `go test ./...` und
  `test-bats` ohne `sources-pin`-Befunde).
- *(3) Gates-Lauf / Befundlage:* `make -k baseline-verify … span-check`,
  2026-11-25, am Stand der drei Implementer-Commits — Tabelle in §7; die
  145 Verweis-Befunde sind die geplante rote Fläche (C2), der
  `planning-drift` entfällt mit dem `git mv` (Paarungen-Commit).
- *Doku-Update:* Commit `1477e06c` — `Stand:` als Version, Datum-Zeile
  daneben; Review „§Baseline — geprüft, ohne Befund“.
- *Review:* [`docs/reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md`](../../../../docs/reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md)
  (Commit `eba40817`) — Verdikt blockierend wegen F-1; geheilt durch die
  §7-Berichtigung (`4f0bbd35` — F-1/F-2/F-5/F-6 · `fbd75827` — F-4),
  geschrieben in Planner-Kontext, vor dem `git mv`.
- *Mutations-CI-Belege:* 0 Fall-Urteile in allen drei Läufen —
  **unurteilbar bis C2 (`test-bats`-Heilung)**; die Grenze trägt §7
  (Lern-Eintrag), der kollektive CI-Sweep nach der Heilung hängt an der
  Welle. Kein Mutations-DoD-Punkt dieses Slices behauptet ein Urteil —
  die Pflicht ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
  Setzung 1) ist im geplanten roten Zwischenstand strukturiert
  unerfüllbar; die Kollision entscheidet die Welle.
- *Verifier-Turn:* entfällt — die Verifikation der DoD-Punkte trägt die
  Session-Verifikation, Stand im Übergabe-Bericht der Session; die Grenze
  steht hier benannt, nicht durch einen Sensor verdeckt (Fassung wie beim
  Vorgänger).
- *Closure-Notiz / Register / Risiken:* §6–§7 dieser Datei (dieser
  Inhalt-Commit); Register-Beleg neu angelegt im selben Zug. Die drei
  Paarungen folgen im Paarungen-Commit nach dem `git mv` (Ergebnis §7).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`Makefile`](../../../../Makefile) | update | `BASELINE_TAG`/`BASELINE_ZIP_SHA256` — die kanonische Pin-Quelle |
| [`internal/fetch/baseline.go`](../../../../internal/fetch/baseline.go) | update | `DefaultTag`/`DefaultBaselineSHA256` — fail-closed gekoppelt |
| [`.d-check.yml`](../../../../.d-check.yml) | update | `sources`-Paar an den neuen Stand |
| `.harness/baseline/<tag>/` | neu | committet vendored Baum aus dem Release-Asset (`make vendor-baseline`), `SHA256SUMS` frisch — [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) |
| `.harness/baseline/v6.18.1/` | update (Abtritt) | der alte Baum wandert mit dem Sprung ab |
| `.claude/rules/*.md` (7 Baseline-Zeiger) | update (nachgetragen — Nachlieferung) | die 7 Zeiger hingen am abgetretenen `v6.18.1`-Baum und brachen den CI-Vorlauf der Mutations-Probe deterministisch (`sha256sum … No such file or directory` → `Schlüssel nicht berechenbar`); die Pflicht, die den CI-Beleg urteilbar macht, ist die Probe vor der Verifikation ([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt) Setzung 1) — der Zugehörigkeits-Anker der Fälle bleibt an [`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update | §Baseline: `Stand:`-Zeile an den neuen Tag |
| [`internal/emit/baumaussage.go`](../../../../internal/emit/baumaussage.go) | update | `InventurMessTag` an die `v7.0.0`-Form — die Inventur-Zuordnung trägt sonst den abgelösten Stand ([`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)) |
| [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml) | prüfung | die Baseline-Pin-Zeile der emittierten Konfig, falls sie geführt wird — verifizieren, dann an den neuen Tag ziehen |
| [`internal/emit/templates/baseline-verify.sh`](../../../../internal/emit/templates/baseline-verify.sh) | prüfung (erwartet keine Änderung) | tag-agnostisch verifiziert: `<tag>`-Politik mit keinem Pin-Wert im Skript — eine Änderung nur, wenn der neue Baum sie verlangt |
| `test/sources-pin.bats` | prüfung (erwartet keine Änderung) | die Kopplungs-Fälle lesen die fail-closed gepinnte Quelle — der Sprung tritt die Quelle an, die Fälle bleiben byte-gleich; geprüft ohne Befund (Review „Pin-Kopplung"), nicht geändert — Berichtigung der vorherigen `update`-Fassung (Review F-5) |

**Ansatz:** Die fünf Pin-Stellen ziehen in **einem** Zug — einzeln würde die
fail-closed-Kopplung (die einen Teil der Stellen rot färbt, solange einer
abweicht) jeden Zwischenstand rot setzen. `make vendor-baseline` braucht Netz
an genau diesem Aufruf; die Tag-Achse (`BASELINE_TAG`) und der
`SHA256SUMS`-Mechanismus des Release-Assets laufen getrennt
([`ADR-0059`](../../../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Start-Trigger der
[`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md) ist
eingetreten (`slice-gates-fastpfad-ueber-stempel` liegt in `done/`) **und** der
Slice ist mit gesetztem `Verantwortlich:`-Feld priorisiert.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Zug greift über
  die fünf Pin-Stellen und den Baum-Tausch hinaus (etwa die Pin-Formeln der
  Tool-Köpfe oder die Skript-Mechanik von `make vendor-baseline` brauchen
  Änderung).
- `in-progress` → `open` (blockiert — Carveout?): das Release-Asset ist nicht
  erreichbar oder sein sha256 lässt sich gegen die Pin-Form nicht holen — erst
  Reproduktion, dann Carveout-Frage.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt, Review-Report unter `docs/reviews/`, Closure-Notiz mit
Lerneintrag — und die **Befundlage des erwartbar roten Voll-Gate-Laufs** aus
DoD (3) steht in §7 als Übergabe-Artefakt; der Lesungs-Slice trägt sie als
Eingabe.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **`make baseline-freshness` meldet nach dem Abtritt des alten Baums ein
  anderes Verdikt** (nächtliche Achse, nicht Pin-Kopplung). — **Ausgang:**
  **weiter offen** — die Beobachtung
  [`BEO-ALL/freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums`](../observations/BEO-ALL/freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums/observation.md)
  trägt den Ausgang im Register weiter (Stand: offen, 1 Beleg); ihr
  Beleg-Zug ist der nächtliche Lauf nach dem Abtritt, nicht die DoD dieses
  Slices.
- **Die Pin-Achsen des Release werden verwechselt** — ZIP-Hash
  (`BASELINE_ZIP_SHA256`) und das als Asset reisende `SHA256SUMS` sind zwei
  Sätze ([`ADR-0059`](../../../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)). —
  **Ausgang:** **weiter offen** — die Lesung trägt die Zuordnung in der
  Delta-Tafel ([`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md)
  §4); der Beleg dieses Slices trennt die zwei Formen getrennt ab
  (`7afa252c`: Baum-`SHA256SUMS` frisch erzeugt, Asset-`SHA256SUMS` vom Tag
  — Review „Vendored Baum“/„Pin-Beleg gegen Publikation“), der Lese-Schritt
  der Welle-Closure liest die Ausgangs-Zeile erneut.
- **Die Inventur-Aussage trägt den Stand** — bleibt `InventurMessTag` in
  [`internal/emit/baumaussage.go`](../../../../internal/emit/baumaussage.go) auf
  `v6.18.1` stehen, feuert [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  über die emittierte Inventur-Messung. — **Ausgang:** **entfallen**
  (geheilt) — `InventurMessTag = "v7.0.0"` zog mit `1477e06c` in derselben
  Lieferung (Review „Emissions-Kanten — geprüft, ohne Befund“: die
  emittierte [`internal/emit/templates/d-check.yml`](../../../../internal/emit/templates/d-check.yml)
  führt keine Baseline-Pin-Zeile, `grep` leer); die zwei Kopplungs-Tests
  ([`test/sources-pin.bats`](../../../../test/sources-pin.bats),
  `TestDefaultTag_MatchesBaseline`, `TestDefaultBaselineSHA256_MatchesMakefile`)
  und `TestInventurMessTag_IstDerGefetchteStand` sind grün am neuen Stand
  (§7-Tabelle) — [`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
  feuert nicht.

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen; die Befundlage des roten Voll-Gate-Laufs (DoD 3)
steht hier als Übergabe-Artefakt, bevor der git mv nach done/ liegt. -->

**Befundlage des Voll-Gate-Laufs (DoD 3) — Übergabe-Artefakt an den
Lesung-Bestand und die Cluster-Slices.** `make gates` rot (Exit 2); der erste
gefallene Check stoppt die serielle Kante, die übrigen Checks einzeln gemessen
(`make -k`), alle am Stand der drei Implementer-Commits `51649824`/`7afa252c`/`1477e06c`
(Messung `make -k baseline-verify … span-check`, 2026-11-25):

| Check | Zustand | Befundlage |
|---|---|---|
| `baseline-verify` | grün | `v7.0.0 OK — 55 Dateien (Integritaet + Vollstaendigkeit, netzlos)` |
| `docs-check` | rot | `2986 Datei(en) geprüft, 146 Befund(e)` — **145 × `target-missing`** (Verweise in den abgetretenen `.harness/baseline/v6.18.1/`-Baum: Einträge unter `harness/conventions/`, `harness/sensors/`, `.harness/skills/reviewer.md` u. a.) + **1 × `planning-drift`** (Ruhe-Marker „Nichts in Arbeit." in [`roadmap.md`](../in-progress/roadmap.md) bei belegtem `in-progress/`) |
| `lint` / `build` / `test` (go) | grün | `golangci-lint`, Dockerfile-`build`-Stage, `go test ./...` — alle `ok` |
| `test-bats` | rot | 8 Fälle über zwei Fall-Klassen: **17/19/20** (Stub-Vorlagen: `archiv-stub-*`/`welle-results`-Namen in `templates/` des vendored Baums — die Rename-Paare des v7-Zugs) und **105–108** (Template-Fixture `courseSet`/Inventare, die den realen Vorlagen-Satz abbilden) — Heilung im Cluster C2; Fall **288** (Mutations-Fingerabdruck über den Baum) |
| `shell-lint` / `ci-lint` | grün | shellcheck / actionlint ohne Meldung |
| `comment-claims` | grün | `101 Datei(en) geprueft, 0 Befund(e)` |
| `register-ausgang` | grün | `281 Eintraege, 81 ueber der Schwelle, 0 Befund(e)` |
| `mutate-greift` | rot | `775 Fall/Faelle, 772 greifen, 3 Befund(e)` — Fälle **224**, **244**, **248**: `# files:`-Muster auf `archiv-stub-*.template.md` lösen gegen den Bestand nicht (die neuen Namen heißen `archive-stub-*` und `wave-*`) — Re-Anker im Cluster C2 |
| `host-bin` / `span-check` | grün | Träger gebaut; `span-emit` schreibt, Ablageort git-ignoriert |

Zu den zwei Resten, die der Lauf nicht trägt: die 7 Baseline-Zeiger unter
`.claude/rules/` zeigen auf den abgetretenen `v6.18.1`-Baum (Symlink-Smoke
Exit 1, 7 Befunde; Retargeting ist Out-of-Scope, Cluster C2/C7) und
`internal/emit/templates.go` führt `v6.18.1` in zwei Kommentar-/Rezept-Stellen
(Zeilen 1056–1057, 1135 — C2-Kennungs-Form-Zug).

**Nachlieferung — Reste 1 geheilt (Retargeting).** Die 7 Baseline-Zeiger wurden
auf `v7.0.0` umgehängt (je Zielpfad vorher einzeln per `test -f` geprüft — alle
7 Regel-Dateien tragen unter `v7.0.0` denselben Namen, kein Umbenennen);
Commit `e8b7e822`. Geheilt sind damit: der Symlink-Smoke-Befund (7 Befunde →
0) und die `sha256sum`-Hälfte des CI-Vorlauf-Tods der Mutations-Probe
(Fingerabdruck über die Zeiger-Ziele berechnet wieder; Working-Tree-Hash
fehlerfrei). **Der CI-Vorlauf bricht weiter** — an den Fall-Ankern 224/244/248
(`# files: …archiv-stub-*.template.md` löst gegen den `v7.0.0`-Baum nicht, Exit
2 in 2–3 s je Shard; CI-Run 45661467791, `mutate-ergebnis.txt` am
nachgelieferten Stand `060e7e87` konsumiert — Urteil „BEFUND (kein Ergebnis im
Log)" über alle 62 Fälle, Wanduhr 205 s —, beide `mutate/**`-Branches danach
geräumt): dieselben drei Fälle, die `mutate-greift` lokal meldet, keine neue
Befundklasse. **Nachlieferung 2 — die drei Anker re-angekert**
([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand):
die
Anlage misst ihr sed-Muster gegen den Quell-Bestand; je Fall nur Namens-Anteile
gepasst — `archiv-stub-*`→`archive-stub-*`, `<welle-id>`→`<wave-id>`,
`archiv.zip`→`archive.zip`): Commit `88f85db3`, Beleg
`make mutate-greift` → `775 Fall/Faelle, 775 greifen, 0 Befund(e)`;
`test-bats`-Fall 288 (Mutations-Fingerabdruck) damit mitgeheilt (8 → 7
Befunde). **CI-Probe dritter Lauf (Run 45666751330, geprüfter Commit
`6a80cf3d`) — Berichtigung** ([`docs/reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md`](../../../../docs/reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md),
Commit `eba40817` — Findings F-1/F-2, Beleg-Methode zu F-1/F-2): die
Shard-Artefakte des Laufs tragen **nicht** die vorher hier stehende Fassung
(„alle 11 Shards success mit echten Fall-Läufen", „die Ergebnis-Aggregation
liest die Shard-Belege erneut leer"), sondern ihr Gegenteil: **zehn**
Shard-Jobs (0–9, nicht elf), **alle** mit `rc=2` und **keiner**
`mutate: ok`-Zeile; je Shard brechen die vier Worker fail-closed im
**Grün-Vorlauf** ab (`ABBRUCH — make test-bats ist in SEINER Kopie ohne
Mutation rot`), die Vorlauf-Logs führen die sieben geplant-roten
C2-Fixtur-Fälle **17/19/20/105–108** an. **Kein Fall lief, kein Fall
urteilt — 0 Fall-Urteile in allen drei CI-Läufen** (`45655913161`,
`45661467791`, `45666751330`). Der `ergebnis`-Schritt („Urteil: BEFUND" über
„kein Ergebnis im Log" aller 65) las die Shard-Logs damit **richtig** — eine
Aggregations-Lese-Lücke existiert in diesem Beleg **nicht**; der an dieser
Stelle vorher genannte „Treiber-/Workflow-Zug" hat keinen Gegenstand und
entfällt. Der reale Träger vor jedem Fall-Urteil ist die **geplante rote
Fläche C2**: solange `test-bats` die Fixtur-Fälle 17/19/20/105–108 trägt,
bricht der Grün-Vorlauf je Shard-Kopie fail-closed und macht die Probe —
alle 65 Fälle, auch die re-angekerten **224/244/248** — **unurteilbar bis
C2 (`test-bats`-Heilung)**; der lokale Beleg `make mutate-greift` →
`775 Fall/Faelle, 775 greifen` hält ([`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
§Grenze) den Anker-Treffer, nicht das Wächter-Rot.
`mutate-ergebnis.txt` konsumiert,
Branch `mutate/…-6a80cf3d` geräumt. Die Reste-2-Stelle
(`internal/emit/templates.go`, Zeilen 1056–1057, 1135) und der übrige
C2-Fixture-Satz (17, 19, 20, 105–108) unverändert. Die 145 Verweis-Befunde des
Doc-Gate bleiben die geplante rote Fläche (Cluster C2).

**Closure-Notiz (Planner, 2026-11-25, eigener Kontext —
[`AGENTS.md`](../../../../AGENTS.md) §3.10).** Regeln dieser Sektion:
Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register ·
`modul-05-planning-harness.md` §Closure- und Lerneintrag-Regeln.

- **Was hat funktioniert:** die Vendorung zog in einem Zug — vendored Baum
  (`7afa252c`), fünf Pin-Stellen fail-closed gekoppelt (`51649824`),
  §Baseline-Stand (`1477e06c`); der erwartbar rote Voll-Gate-Lauf lief mit
  Check-Einzelsbilanz (Tabelle oben) und blieb als geplante rote Fläche
  (145 Verweis-Befunde + sieben C2-Fixtur-Fälle) an den Lesungs-Bestand
  adressierbar; der Review bestätigt Pin-Kopplung, Baum-Abtritt und
  Retargeting ohne Befund.
- **Was ging anders als geplant:** die drei Mutations-CI-Läufe — 1. Lauf
  Vorlauf-Tod an den dangelnden Zeigern (geheilt `e8b7e822`), 2. Lauf
  Exit 2 an den drei Fall-Ankern (geheilt `88f85db3`), 3. Lauf
  Grün-Vorlauf-Abbruch an der geplant roten `test-bats`-Fläche — 0
  Fall-Urteile in allen dreien; die erste Lesart des 3. Laufs (Aggregation
  liest leer) war falsch und ist im Absatz oben berichtigt
  (`4f0bbd35`/`fbd75827`). [`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
  Setzung 1 ist in diesem Zwischenstand strukturiert unerfüllbar.
- **Lern-Eintrag (Steering-Loop, gezählt, nicht verkörpert — kein
  `liegt in`-Feld):** die **geplante rote `test-bats`-Fläche bricht den
  Grün-Vorlauf der CI-Mutations-Proben** — ein Wellen-Slice kann seine
  Mutations-Belege nicht bekommen, solange die Fläche im selben
  Zwischenstand rot trägt; die zwei Normen (Probe vor Verifikation,
  [`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt)
  Setzung 1 · geplante rote Fläche) kollidieren, und die Kollision
  entscheidet die Welle, nicht dieser Slice. Träger der Ausnahme: der
  **kollektive CI-Sweep nach der Heilung** — die Anker der 65 Fälle zielen
  auf den Bestand ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)),
  nicht auf den Rerun; die Setzung trägt der **Lese-Schritt der
  [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md)-Closure**,
  den Fall-Beleg neben dem ADR-Beleg ([`ADR-0059`](../../../../docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md))
  desselben Zugs. Kennung der Befunde: die drei Runs `45655913161` ·
  `45661467791` · `45666751330` samt den Vorlauf-Log-Befundzeilen
  (`ABBRUCH — make test-bats ist in SEINER Kopie ohne Mutation rot`,
  Fixtur-Fälle 17/19/20/105–108) — Beleg-Anker ist der
  [`docs/reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md`](../../../../docs/reviews/2026-11-25-slice-baseline-vendorung-v7-0-0.md)-Report
  (Shard-Artefakte des 3. Laufs, `gh run download 45666751330`, Retention
  3 Tage).
- **Review-Findings — Klassen (Übergabe des Reports, [§3.6](../../../../AGENTS.md)
  der recurring-class-Route):** `Übergabe-Artefakt behauptet
  Lauf-Ergebnisse, die der Beleg nicht trägt` (F-1 — durch die
  Berichtigung dieses Zugs geheilt) · `Folge-Adresse ohne Gegenstand`
  (F-2 — Zeiger entfallen) · `Zusage trägt Anker-Treffer statt
  Wächter-Rot als Beleg` (F-3 — unurteilbar bis C2, oben benannt) ·
  `Neue Gate-Befundzeile außerhalb der geplanten roten Fläche` (F-4 —
  `fbd75827`) · `Plan-Zeile ohne Code-Entsprechung, unkorrigiert` (F-5 —
  `4f0bbd35`) · `Sendung am Nachbar-Eintrag begründet` (F-6 —
  `4f0bbd35`).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`](../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/observation.md)
  — Beleg `evidence/slice-baseline-vendorung-v7-0-0.md` ergänzt (Zähler
  2×, Stand: offen, unter der Schwelle). Zuordnungs-Urteil: Ergänzung
  statt Eigen-Eintrag — beide Belege teilen die Klasse (die Vorlauf-Schicht
  verliert, bevor ein Fall urteilt); die zwei Unter-Klassen
  (infrastrukturelle Last · geplante rote Fläche) stehen in der Beleg-Datei
  neben der Grenze.
- **Archivierung:** entfällt hier — der Slice gehört der
  [`welle-baseline-sprung-v7-0-0`](../welle-baseline-sprung-v7-0-0.md); deren
  Closure archiviert ihre Zeitdokumente als Schritt 4 ihrer Prozedur
  ([`MR-078`](../../../../harness/conventions.md#mr-078--wellenlose-slices-werden-bei-der-eigenen-closure-archiviert)
  trägt die wellenlose Hälfte, nicht diese Zugehörigkeit); kein
  `archive-slice`-Zeiger (wie beim Vorgänger-Slice bewusst nicht
  vollzogen).
- **Folge-Slices:** keiner aus diesem Slice — der kollektive CI-Sweep nach
  der C2-Heilung hängt an der Welle (oben); ein Zeiger auf einen
  nicht-geschnittenen C2-Slice würde ins Leere zeigen
  (Review-F-2-Form).
- **Risiken aus §6:** jede Zeile trägt einen Ausgang — siehe §6.
- **Drei Paarungen (geprüft am 2026-11-25, nach dem `git mv`):**
  - *(a) Anker:* §7 trägt kein `liegt in`-Feld — der Lern-Eintrag ist
    gezählt, nicht verkörpert; kein Gegenstand. Die Setzung (kollektiver
    CI-Sweep) hängt an der Welle-Closure, nicht an einem verkörperten
    Zielort — ebenfalls kein Gegenstand der Paarung; die Grenze trägt §7.
  - *(b) Folge-Slice:* §7 nennt keine Folge-Slice-Kennung. §1 nennt als
    übernehmende Adresse
    [`slice-baseline-delta-lesung-v7-0-0.md`](slice-baseline-delta-lesung-v7-0-0.md)
    — liegt als Datei im Lifecycle (`done/`) — und die C2-Zeile der
    Welle-Tafel; die Slice-Datei des C2 entsteht beim Schnitt, die Adresse
    zeigt auf die Tafel-Zeile statt auf eine nicht existierende Datei
    (Review-F-2-Form). Grün.
  - *(c) Register:* die im Risiko-Ausgang und in §7 genannten Beobachtungen
    existieren als Verzeichnis und tragen je mindestens einen Beleg —
    [`BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`](../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/observation.md)
    (2 Belege, offen, unter der Schwelle, [`state.md`](../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/state.md)),
    [`BEO-ALL/freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums`](../observations/BEO-ALL/freshness-verdikt-faellt-nach-dem-entfernen-des-alten-baums/observation.md)
    (1 Beleg). Grün.
- **Ruhe-Marker:** [`roadmap.md`](../in-progress/roadmap.md) §Offene Wellen —
  `in-progress/` trägt nach dem `git mv` nur ihr `roadmap.md`, der Marker
  „Nichts in Arbeit.“ trifft den Zustand; der `planning-drift`-Befund
  entfällt mit diesem Commit — geplant war er als rote Fläche, belegt in
  der ersten Gates-Tabelle.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `.harness/baseline/`
(vendor-Baum), `Makefile`/`internal/fetch/` (Pin-Kopplung) und
`harness/conventions.md`; alle fallen unter den Eintrag `*` (gesamtes Repo) der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) —
die Schwellwert-Prüfung trägt der Eintrag, weiter ausdifferenzieren ist hier
nicht nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register `BEO-ALL`
durchgegangen. Treffer: [`BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin`](../observations/BEO-ALL/vendored-baum-entsteht-aus-anderer-quelle-als-sein-pin/observation.md)
(1×, offen — die Quellen-Achse der Lücke wird hier nicht neu berührt, der
Asset-Lauf folgt dem Pin), [`BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung`](../observations/BEO-ALL/pin-sprung-feuert-adr-trigger-ohne-nennung/observation.md)
(1×, offen — Träger bleibt das Trigger-Audit der Closure),
[`BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar`](../observations/BEO-ALL/pin-sprung-macht-test-eingabe-gleich-default-die-zusage-unsichtbar/observation.md)
(1×, offen — Träger ist die Mutations-CI-Probe dieses Slice),
[`BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit`](../observations/BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit/observation.md)
(1×, offen — die [`MR-063`](../../../../harness/conventions.md#mr-063--die-gegenmessung-eines-d-check-sprungs-gibt-jedem-aktiven-modul-eine-basis-und-lässt-die-symlinks-stehen)-Gegenmessung
liegt mit dem Umsetzungs-Commit), [`BEO-ALL/adaptions-achse-1-kurzschluss`](../observations/BEO-ALL/adaptions-achse-1-kurzschluss/observation.md)
(1×, offen — hier wird der Baum gewechselt, nicht adaptiert). Keine Berührung
erreicht die Schwelle mit diesem Slice.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — entfällt nach dem
Umfang-Absatz der Vorlage.
