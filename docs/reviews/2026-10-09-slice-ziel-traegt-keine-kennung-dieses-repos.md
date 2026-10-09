# Review-Report: slice-ziel-traegt-keine-kennung-dieses-repos — 2026-10-09

**Review-Art:** Code — gegen Plan + ADR + Konventionen.

**Gegenstand:** `e051aba6`, `3922608f`

**Skill:** `.harness/skills/reviewer.md` (Version 2.3.0)

**Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link.

**Eingangs-Kontext:**

- `slice-ziel-traegt-keine-kennung-dieses-repos` (Plan §1–§4, §6)
- `ADR-0090` (Accepted), `ADR-0053` Festlegung 4, `ADR-0065` Festlegung 4
- `LH-QA-01`
- `AGENTS.md` §3 (insbesondere §3.5, §3.6, §3.7)

**Summary:** 1 HIGH · 1 MEDIUM · 2 LOW · 2 INFO — blockiert. Klassen: Wächter-Grenze enger als
zuvor, ohne Benennung · Abschnittsnummer dieses Repos in einer Meldung im Ziel · Streich-Muster
trifft Nicht-Kennungen · Gegenprobe-Behauptung eines Falls widerlegt.

---

## Findings

### HIGH-1 — `kennungMuster` erkennt eine Kennung mit nachfolgendem Bindestrich nicht mehr

- `kategorie`: HIGH (Stilles-Grün-Pfad / gelockerte Strenge eines Wächters in `make test`)
- `quelle`: `LH-QA-01`; `AGENTS.md` §3.5, §3.6
- `pfad`: `cmd/ai-harness-init/kennungen_test.go` (`kennungMuster`, `kennungenInText`)
- `befund`: Die neue Rechts-Grenze verwirft jeden Treffer, auf den `-` oder ein Buchstabe folgt.
  Grenz-Sonde über `siehe slice-082-foo` / `MR-077-statt-der` / `LH-QA-01-Bedingung`: das alte
  Muster (`\b…\b`) liefert `slice-082`, `MR-077`, `LH-QA-01`; das neue (`(^|[^A-Za-z0-9_-])…([^A-Za-z0-9_-]|$)`)
  liefert nichts. Genau diese Formen schreibt das Repo selbst (Dateinamen `MR-NNN-<titel>.md`,
  `slice-NNN-<name>.md`; Kommentare `internal/gen/arch.go:100` „LH-QA-01-Bedingung",
  `internal/gen/cpp.go:44` „slice-024-Klasse"). Landet eine davon in emittiertem Text oder einer
  Meldung, bleiben beide Wächter grün; der Kopf begründet die Rechts-Grenze nur mit `ADR-00012`
  und nennt diese Klasse nicht als Grenze. Am heutigen Bestand latent: ein real gebootstrapptes Ziel
  (`--lang go --arch hexslice` + `add-lang kotlin apps/kt --arch hexslice`) trägt unter dem alten
  Muster nur die Saat-Kennungen, `LH-FA-01` der Selbstprüfung und `LH-QA-01` aus der vendored
  Vorlage `harness/conventions.md` — keinen Treffer, den die Verengung verbirgt.
- `verifizierbar`: ja — `grep -oE` mit beiden Mustern über den drei Formen
- `klasse`: Wächter-Grenze enger als zuvor, ohne Benennung im Kopf

### MEDIUM-1 — Die Sperre `haenger` verweist im Ziel auf die falsche Hard Rule

- `kategorie`: MEDIUM (Abdeckungslücke des Plan-Ziels, DoD 2)
- `quelle`: `LH-QA-01`; Plan §1 Ziel („Meldungen des Trägers … keinen Spec- oder Adaptions-Verweis dieses Repos")
- `pfad`: `internal/archive/vorschau.go:129`
- `befund`: Die Meldung „… mit ADR nach AGENTS.md 3.5" meint die Regel *Gates nicht ohne ADR
  lockern* — §3.5 **dieses** Repos. In der emittierten `AGENTS.md` des Ziels ist §3.5 „ADRs sind
  nach `Accepted` immutable", die gemeinte Regel steht dort als §3.6 (gemessen am gebootstrappten
  Ziel, `grep -nE '^### 3\.' AGENTS.md`). Die Meldung schickt den Bediener im Ziel an die falsche
  Regel. Dieselbe Klasse hat `3922608f` für die Commit-Message (`AGENTS.md §3.3` → Klartext)
  behoben; diese Stelle blieb, und kein Wächter liest Abschnittsnummern.
- `verifizierbar`: nein — kein Sensor liest Abschnittsnummern in Meldungen
- `klasse`: Abschnittsnummer dieses Repos in einer Meldung im Ziel

### LOW-1 — `streicheFremdeKennungen` streicht auch Nicht-Kennungen wie `(UTF-8)`

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6 (Zusage im Kopf), Maintainability
- `pfad`: `internal/emit/emit.go` (`fremdeKennung`, `streicheFremdeKennungen`)
- `befund`: `[A-Z]{2,}(-[A-Z]+)*-[0-9]+` ist als ganzes Klammer-Element auch `UTF-8`, `ISO-8601`,
  `SHA-256`. Sonde (dieselben zwei Ersetzungen mit `sed -E`): `# Ausgabe als Text (UTF-8).` →
  `# Ausgabe als Text.`; `# Format (ISO-8601), Hash (SHA-256)` → `# Format, Hash`;
  `# Kodierung (Latin, UTF-8)` → `# Kodierung (Latin)`. Die Grenze im Kopf nennt nur, was stehen
  bleibt, nicht was fälschlich fällt; `full-smoke` (`fremde_kennungen_im_fragment`) sieht nur den
  Rest und meldet die Streichung nicht. Die realen `--print-mk`-Ausgaben der gepinnten Images
  (d-check v0.84.0, a-check v0.23.0) tragen heute keine solche Form; eine solche Klammer in einem
  künftigen Pin verlöre still ihren Inhalt. Die Gegenrichtung — `UTF-8` frei im Satz — färbt
  `full-smoke` rot mit der Meldung „Kennungen aus einem Register" (laut, aber irreführend).
- `verifizierbar`: ja — Sonde oben
- `klasse`: Streich-Muster trifft Nicht-Kennungen der gleichen Gestalt

### LOW-2 — Fall 641: die Gegenprobe-Behauptung hält nicht, die Mutation färbt auch einen zweiten Test

- `kategorie`: LOW
- `quelle`: `AGENTS.md` §3.6, §3.7
- `pfad`: `test/mutations/641-addlang-modul-fragment-traegt-kennung.sh` (Kopf, „Gegenprobe")
- `befund`: Gefahren als temporärer Fall (Mutation 641 + Variante `sprachlos-add-lang` entfernt,
  danach gelöscht): `make mutate` → `BEFUND … rot, aber 'TestEmittierteDateienTragenNurImZielAufloesendeKennungen'
  faellt nicht — falscher Grund`. Die Variante bindet also den benannten Test, die Suite bleibt aber
  rot: die Mutation schreibt `ADR-0009` in ein Go-Literal, das auch der Literal-Wächter liest
  (welcher Test rot blieb, wurde nicht einzeln gelesen). „ohne die Variante … bleibt der Fall grün"
  ist damit falsch, und der Fall zeigt nicht, was die Variante allein trägt (Text aus eingebetteten
  Vorlagen am Unterverzeichnis, den der Literal-Wächter nicht liest).
- `verifizierbar`: ja — `make mutate MUTATE_CASES=<Gegenprobe-Fall>`
- `klasse`: Mutations-Fall nennt einen Test, die Mutation färbt mehrere

### INFO-1 — `TestTraegerMeldungenTragenKeineKennung` liest Literale, nicht Konstanten

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6
- `pfad`: `cmd/ai-harness-init/kennungen_test.go` (`TestTraegerMeldungenTragenKeineKennung`, Kopf)
- `befund`: Der Kopf sagt „jede Zeichenketten-Konstante"; geprüft wird je `ast.BasicLit`. Ein
  Prosa-Verweis oder eine Kennung, die über zwei mit `+` verbundene Literale läuft — die Form, in der
  `ErrKennungFehlt` selbst geschrieben ist —, sieht er nicht; die GRENZE nennt nur Datei- und
  Laufzeit-Werte. Gelesen, nicht gefahren.
- `verifizierbar`: nein
- `klasse`: Grenzen-Aufzählung ohne Formen-Probe

### INFO-2 — `prosaVerweisMuster`: Punkt beendet den Satz auch in Dateinamen und Versionen

- `kategorie`: INFO
- `quelle`: `AGENTS.md` §3.6
- `pfad`: `cmd/ai-harness-init/kennungen_test.go` (`prosaVerweisMuster`)
- `befund`: `[^.]{0,160}` endet an jedem Punkt — „Festlegung in `spezifikation.md` von
  ai-harness-init" oder „Spezifikation (v0.6.0) von ai-harness-init" fallen durch;
  `\bdogfood` allein trifft jedes „Dogfood" im Ziel, auch ohne Bezug auf dieses Repo (laut).
  Am realen Ziel kein Treffer in beide Richtungen (`grep -rniI 'dogfood\|von ai-harness-init'`
  liefert nur Herkunftszeilen). Gelesen, nicht gefahren.
- `verifizierbar`: nein
- `klasse`: Grenzen-Aufzählung ohne Formen-Probe

---

## Geprüft, ohne Befund

- **ADR-0090:** Reihenfolge Sperre (Exit 3) → Vorschau (Exit 0) → Kennungs-Pflicht (Exit 2) in
  `archiveWelleLauf`; Pflicht in `Anwenden` vor dem ersten Schreibzugriff; `--kennung ""` gilt als
  fehlend; emittiertes `archivierung.mk` ohne Default, Dogfood-`Makefile` mit `ADR-0041` nur für
  `WELLE=altbestand`; Folgepflicht-Stellen (Hilfe, `close-welle.md`, `hooks-install.mk`,
  `harness/README.md` §Traceability, `harness/sensors/archive-welle.md`, `traegerAusnahmen` leer)
  nachgezogen. `full-smoke` (e0)/(e1): `core.hooksPath` nur um den (e1)-Lauf gesetzt und danach
  entfernt — gelesen, `make full-smoke` nicht gefahren.
- **ADR-0053 / ADR-0065:** keine zweite Fassung der Muster-Menge im Werkzeug; Welle-Commits ohne
  Kennung bleiben wie in ADR-0090 §Konsequenzen benannt.
- **Feldliste:** `festlegungenDerFeldliste` + `specAbschnitt == "5"` + die unveränderten
  `stehtJeweils`-Wendungen der Spec-Zeilen halten die Kopplung an §5; entfallen ist nur die Bindung
  an den Titel von `MR-077`, die im Ziel nicht auflöste.
- **Variante `sprachlos-add-lang`:** bindet — ohne sie wird `TestEmittierteDateienTragenNurImZielAufloesendeKennungen`
  unter Mutation 641 grün (LOW-2).
- **Mutationsfälle:** `make mutate MUTATE_CASES='640-… 641-… 646-…'` → `3 ok` (646 trifft die reale
  Reihenfolge in `archiveWelleLauf`). 638/639/642–645/647/648 gelesen; sie mutieren die genutzte
  Stelle, nicht einen Nachbau.
- **Reale Emission:** Ziel go/hexslice + `add-lang kotlin apps/kt`: `d-check.mk`/`a-check.mk` ohne
  `DC-…`/`AC-…`/`slice-NNN`; `traeger.mk`, `.d-check.yml` ohne Dogfood-Satz.
- **`docs/user/e2e-abdeckung.md`:** Ableitung, neu erzeugt; Gleichheit hält `test/e2e-abdeckung.bats`
  in `make gates`.
- **Hard Rules §3.3/§3.4/§3.8:** kein Move mit Inhalt, keine Accepted-ADR berührt, keine Norm-Datei
  im Implementer-Commit.
