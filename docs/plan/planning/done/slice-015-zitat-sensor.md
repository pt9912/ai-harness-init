# Slice slice-015: Zitat-Verifikation via d-check adoptieren (`codepaths.check-lines`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem die Datei liegt
(`open/` · `next/` · `in-progress/` · `done/`), Wechsel nur per `git mv` —
v3.1.0-Konvention (`modul-05`).

**Welle:** ohne Welle (Harness-Wartung). Einordnung *(Kontext, nicht normativ)*:
[roadmap](../in-progress/roadmap.md).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert), [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-17, **re-gescopet 2026-07-19.**

---

## 1. Ziel

Die Zeilenreferenz-Prüfung, die dieser Slice ursprünglich als lokalen bash-Sensor
`make cite-check` bauen wollte, ist **inzwischen von d-check nativ ausgeliefert** (Modul
`citations` + `codepaths.check-lines`, seit d-check **v0.50.0**, umgesetzt vom
d-check-internen `slice-079`). Damit ist der Eigenbau **abgelöst** — genau der Fall, den
§6 der Erstfassung vorausgesagt hat („ein Antrag auf ein ausgeliefertes Feature"). Statt
ein Skript zu bauen, das dupliziert, was das Gate-Tool schon kann, adoptiert dieser Slice
die Fähigkeit dort, wo sie ehrlich trägt:

- **d-check-Pin v0.46.0 → v0.50.0** (Digest dreifach belegt), Fragment `d-check.mk` frisch
  aus `d-check --print-mk` neu erzeugt und wie in [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) adaptiert; Pflicht-Trockenlauf
  belegt **0-Befund-Differenz** ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- **`codepaths.check-lines: true`** — ein **additives Property am bereits aktiven
  `codepaths`-Modul**, das im `docs-check` einen großen, **nicht-leeren** Korpus prüft
  (Inline-Code-Pfade unter `spec`/`docs`/`harness`). Es kostet heute nichts (Korpus-Messung
  s. §4), härtet aber automatisch, sobald die erste `datei:von-bis`-Zeilenreferenz in einem
  dauerhaften Dokument auftaucht. Das ist die [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)-Philosophie („Gate-*Anheben* →
  Steering-Loop") — **kein** neues Gate.

**Kernunterscheidung (der ganze Grund, warum es diesen Slice noch gibt).** Ein
**eigenständiges** `make cite-check`-Gate *oder* das eigenständige Modul `citations` würde
über einem **leeren Prüfbereich** grün melden (0 Zeilenreferenzen bzw. 0
`d-check:cite`-Direktiven) — nach der Definition dieses Repos ein **halluziniertes Gate**
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)), also genau die Falle, gegen die der Sensor gedacht war. `codepaths.check-lines`
ist etwas anderes: es reitet auf dem nicht-leeren Prüfbereich von `codepaths` und behauptet
**kein** eigenes Gate.

**Abgrenzung.** **Nicht** hier: das Modul `citations` (verbatim-Zitatvergleich gegen die
Quell-Spanne) — es feuert nur auf `<!-- d-check:cite … -->`-Direktiven, davon trägt das Repo
**null**; es zu aktivieren wäre ein nie feuerndes Gate. Es wird adoptiert, sobald ein realer
Zitat-Direktiven-Korpus existiert (eigener Slice, eigenes False-Positive-Risiko). **Nicht**
hier: ein neuer Gate-Eintrag in [`AGENTS.md`](../../../../AGENTS.md) §4 oder
[`harness/README.md`](../../../../harness/README.md) §Sensors — `check-lines` ist Teil von
`docs-check`, kein separates Target; ein neuer Gate-Name wäre die Behauptung, die
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) verbietet. **Nicht** hier: die Provenienz-Pflicht für freie Zahlen und
Prosa-Quantoren — mechanisch nicht entscheidbar, bleibt Review-Territorium.

## 2. Definition of Done

- [x] **d-check-Pin v0.46.0 → v0.50.0.** `d-check.mk` frisch aus `d-check --print-mk`
      (v0.50.0) erzeugt und nach [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) re-adaptiert (`doc-check`→`docs-check` in Target
      **und** Hilfetext, `DCHECK_DIGEST` gepinnt, Kopfkommentar, `doc-help`-Grep auf
      `docs?-`). `DCHECK_DIGEST` **dreifach belegt** (lokaler RepoDigest ·
      d-check-Closure-Notiz/Release-Run · `imagetools`-Registry-Inspektion),
      [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).
- [x] **Emitter-Pin nachgezogen (Tier-1-Drift-Kopplung).** `internal/emit`s `DefaultImage`
      /`DefaultDigest` auf v0.50.0 — der go-test `TestDefaultImage/Digest_MatchesCanonical`
      koppelt den *emittierten* Pin an `d-check.mk` und färbte sonst rot. Die **emittierte**
      Starter-Config bleibt bewusst `modules: [links, anchors]` (codepaths dort auskommentiert
      → **kein** `check-lines`; frische Zielrepos haben noch keine roots,
      [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — Emitter ≠ Dogfood.
- [x] **Pflicht-Trockenlauf belegt** ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)-Muster, beide Läufe netzlos
      `--network none`): (a) v0.50.0 gegen unveränderte Config → **0-Befund-Differenz** zum
      v0.46.0-Stand (Pin-Sprung inert); (b) v0.50.0 mit `check-lines: true` → grün über dem
      realen Korpus, inkl. der real vorhandenen eingefrorenen Referenzen. Beide Ausgaben im
      Closure-Beleg.
- [x] **`.d-check.yml`** trägt `codepaths.check-lines: true` mit begründendem Kommentar
      (additive Härtung, nicht-leerer Prüfbereich via `codepaths` — kein eigenständiges
      Gate, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). **Keine** neue Exemption spekulativ gesetzt (Trockenlauf grün;
      Frozen-Doc-Drift einem konkreten Fall überlassen — [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) „belegter Bedarf").
- [x] **`harness/conventions.md`** §Baseline auf v0.50.0 aktualisiert + neuer Eintrag
      [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines) (Pin-Sprung + `check-lines`-Adoption + `citations`-Aufschub, mit
      Trockenlauf-Beleg).
- [x] **Kein** Eigenbau-Artefakt: `harness/tools/cite-check.sh` <!-- d-check:ignore (verworfener Ansatz — wird NICHT gebaut; durch d-check v0.50.0 abgeloest, s. §1) --> und
      `test/cite-check.bats` werden **nicht** angelegt (durch das Werkzeug abgelöst).
- [x] `make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `d-check.mk` | update (neu erzeugt) | v0.50.0-Fragment aus `--print-mk` + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption; `DCHECK_DIGEST` neu gepinnt. Einzige inhaltliche Fragment-Differenz zu v0.46.0: die fünf fokussierten advisory-Recipes gewinnen je `--disable citations` (18. Modul neu). |
| `.d-check.yml` (`codepaths`) | update | `check-lines: true` — additive Härtung, kein neues Gate |
| `internal/emit/emit.go` | update | `DefaultImage`/`DefaultDigest` → v0.50.0 (Tier-1-Drift-Test koppelt den emittierten Pin an `d-check.mk`) |
| `harness/conventions.md` | update | §Baseline v0.50.0 + neuer [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines) |

**Nicht** berührt: [`AGENTS.md`](../../../../AGENTS.md) §4 / [`harness/README.md`](../../../../harness/README.md) §Sensors (kein neuer Gate-Name);
kein `harness/tools/cite-check.sh` <!-- d-check:ignore (verworfener Ansatz, s. DoD) -->, kein `test/cite-check.bats` (Eigenbau entfällt).

## 4. Trigger

**Der ursprüngliche Trigger ist erfüllt bzw. gegenstandslos geworden — beide Achsen belegt:**

1. **Werkzeug-Achse (erfüllt).** d-check ≥ v0.50.0 ist verfügbar und liefert die
   Zeilenreferenz-Prüfung nativ (`codepaths.check-lines`, Modul `citations`). Vorher (Pin
   v0.46.0) existierte die Fähigkeit nicht — der Eigenbau war die einzige Option, und die
   scheiterte an der Korpus-Achse.
2. **Korpus-Achse (unverändert leer — und genau deshalb `check-lines` statt Eigenbau-Gate).**
   Zeilenreferenzen in **dauerhaften** Dokumenten:
   ```
   grep -rhoE '[A-Za-z0-9._/-]+\.(md|yml|sh|awk):[0-9]+(-[0-9]+)?' \
     AGENTS.md CLAUDE.md harness/ spec/ docs/plan/adr/ | wc -l
   ```
   → **0** (gemessen 2026-07-19, unverändert seit 2026-07-17). Alle real vorhandenen
   Inline-Code-Zeilenreferenzen liegen in `docs/plan/planning/done/` — **eingefrorene
   Zeitdokumente**. Deshalb wäre ein *eigenständiges* Zitat-Gate ein Grün über Leerraum;
   `check-lines` dagegen prüft mit, ohne etwas zu behaupten, was nicht da ist.

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation bestätigt DoD + Closure-Notiz → nach `done/`.

## 6. Risiken und offene Punkte

- **Lineage — als Beleg aufbewahrt, nicht gelöscht.** Die Erstfassung dieses Slice
  (2026-07-17) war **bewusst blockiert**: Ihre Prämisse — die vendored Baseline erzeuge einen
  Korpus von Zeilenzitaten auf einen Fremdbaum, der still verrottet — wurde am selben Tag
  **widerlegt** (0 Zeilenreferenzen in dauerhaften Docs). Diese Messung gilt weiter (§4) und
  ist der Grund, weshalb hier **`check-lines`** (additiv, reitet auf `codepaths`) adoptiert
  wird und **nicht** ein eigenständiges `cite-check`-Gate gebaut. Die Fehleinschätzung von
  damals („stärkstes Argument" vor der Messung) bleibt dokumentiert: Die Klasse
  *behauptete-statt-gemessene-Zahl* überlebt jede Sorgfalt — sie braucht einen Sensor, aber
  einen, der auf echtem Prüfbereich sitzt.
- **`check-lines` fängt nur Existenz + Bereich, nicht verbatim.** `datei:173-176` bleibt grün,
  solange die Zieldatei ≥ 176 Zeilen hat — auch wenn die **falsche** Zeile getroffen ist. Den
  verbatim-Fall (Zitattext gegen die Spanne) fängt erst das Modul `citations`; das ist
  bewusst aufgeschoben (§1 Abgrenzung: 0 `d-check:cite`-Direktiven → nie feuerndes Gate).
- **Frozen-Doc-Drift (gemessen, nicht spekulativ behandelt).** Von den real vorhandenen
  Inline-Code-Zeilenreferenzen (alle in `docs/plan/planning/done/`) werden nach
  `codepaths.roots` genau zwei tatsächlich zeilen-geprüft; beide bestehen heute
  (`docs/plan/planning/README.md:26` → 36 Zeilen; `harness/conventions.md:18` → 481 Zeilen).
  Schrumpft ein Ziel künftig unter die referenzierte Zeile, färbte eine eingefrorene
  done/-Referenz rot. Das ist **dieselbe Klasse**, für die `docs/reviews/**` schon heute
  `codepaths`-exempt ist ([`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile)) — aber `done/`-Slices sind es **nicht** und werden
  schon jetzt existenz-geprüft. Eine *spekulative* `done/**`-Exemption wäre die breite,
  unbelegte Liste, vor der [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) warnt. **Setzung:** keine neue Exemption; tritt der
  konkrete Fall ein, wird er dann mit belegtem Bedarf behandelt (gezielter Marker oder
  Exemption).
- **Verhältnis zum d-check-Release.** d-check hat eine eigene Uhr; v0.50.0 ist der aktuell
  gezogene Stand. Der Pin bleibt digest-fest ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); ein späterer d-check-Release ist
  ein eigener Trockenlauf-und-Pin-Vorgang ([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger), nicht dieser Slice.

## 7. Closure-Notiz (nach `done/`)

**Geliefert (2026-07-19).** d-check-Pin **v0.46.0 → v0.50.0** (Digest dreifach belegt),
`d-check.mk` frisch aus `--print-mk` + [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)-Adaption, `codepaths.check-lines: true` als
additive Härtung am aktiven `codepaths` (kein neues Gate), Emitter-Pin (`internal/emit`)
nachgezogen, neuer [`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines). Der ursprünglich geplante Eigenbau-Sensor
`cite-check.sh` <!-- d-check:ignore (verworfener Ansatz, nie gebaut — durch d-check v0.50.0 abgeloest) --> entfiel — durch das Werkzeug abgelöst.

**Rollenkette (Modul 8, je frischer Kontext).** Reviewer (Modul 10): **nicht merge-blockierend**,
0 HIGH/MEDIUM (`docs/reviews/2026-07-19-slice-015-review.md`). Verifier (Modul 11): **alle DoD
CONFIRMED, 0 VIOLATED** (`docs/reviews/2026-07-19-slice-015-verify.md`), inkl. selbst gefahrenem
`make gates` (Exit 0) und Zähne-Beweis (`citation-out-of-range` feuert real, grün auf gültig).
Beide bestätigten den dreifach belegten Digest und die faithful `--print-mk`-Regeneration unabhängig.

**Steering-Loop-Lerneintrag (geschärfte Regel — Pin-Bump-Prozedur).** Ein d-check-Pin-Sprung hat
**drei** Kopplungspunkte, nicht zwei: (1) `d-check.mk`-Pin, (2) `harness/conventions.md` §Baseline,
(3) `internal/emit`s `DefaultImage`/`DefaultDigest` — der **emittierte** Pin, per Tier-1-Drift-Test
an `d-check.mk` gekoppelt. Der re-gescopte Plan listete anfangs nur (1)+(2); der Drift-Test fing
(3) (rot → Plan-Defekt-Rücksprung, Modul 9). **Regel für künftige Pin-Bumps** (ergänzt
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) §Auflösungs-Trigger): `internal/emit` von Anfang an in den Scope nehmen.

**Zweite Lehre (Trigger-Disziplin, Modul 6 validiert).** Die Erstfassung war bewusst **blockiert**
(Prämisse widerlegt). Aufgelöst wurde der Slice nicht durch Erzwingen des Eigenbaus, sondern durch
**Adoption einer upstream gereiften Fähigkeit** (d-check v0.50.0) — der Block war korrekt, das Warten
hat einen Duplikat-Sensor erspart ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).

**Selbst-Anwendung (Ironie als Beleg).** Der Verifier fand zwei veraltete Zahlen in den eigenen
Artefakten dieses Zuges ([`MR-011`](../../../../harness/conventions.md#mr-011--zitat-verifikation-via-d-check-adoptiert-check-lines)-Dateizahl, §6-Zeilenzahl — beide durch spätere Edits gewandert);
sie wurden korrigiert. Genau die Klasse, gegen die dieser Slice `check-lines` adoptiert — hier vom
Verifier gefangen, weil `check-lines` nur `datei:zeile` prüft, nicht freie Prosa-Zahlen (§6, zweiter
Punkt). Der Befund schärft die Abgrenzung, statt sie zu entkräften.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe
[Kurs Modul 5](https://github.com/pt9912/ai-harness-course/blob/v3.1.0/kurs/de/02-planung/modul-05-planning-harness.md)):
`.d-check.yml`/`d-check.mk` (Gate-Config) und die Doku teilen die adoptierte
Harness-Mechanik ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids), [`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile), [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)); GF (Doc führt).
