# Verifikations-Report: slice-release-job-tap-nachzug-und-schritt-7-folgt — 2026-09-29

**Rolle:** Verifier, frischer Kontext · **Modell:** GLM (Z.ai) · **Datum:** 2026-09-29

**Gegenstand:** Diff `dfeaba69^..768474fd` (inkl. Plan-Anpassung `dfeaba69`), HEAD `768474fd`, Arbeitsbaum clean.

**Prüfgrundlage:** Slice-Plan `slice-release-job-tap-nachzug-und-schritt-7-folgt` §2 (DoD) · ADR-0064 (Accepted) · ADR-0066 (Accepted) · ADR-0073 (Proposed) · Review-Report vom 2026-09-29 (F-1 MEDIUM, F-2 LOW).

**Gate-Stempel:** `0894e8a185161ae45322782d4fa06f1769292581fb1996930adaefc4e2bf7c56` — `make gates` nicht neu gefahren; jede DoD-Aussage unten eigen gemessen.

> **Zitier-Form** (wie im Review-Report): **Kennung, nicht Adresse** — `slice-<Kennung>`, `make <target>`, Baseline-Stelle als Tag + Pfad in Inline-Code (`v6.13.0` · `regelwerk/modul-11-verification.md`). Dieser Report ist Lauf-Beleg und friert ein.

## Verdikte je Prüfpunkt

| # | Punkt | Verdikt |
|---|---|---|
| 1 | Job-Form `tap` (LP1), je Aufzählungs-Zeile gemessen | **bestätigt** |
| 2 | bats-Zähne: 10 Fälle an der Aufzählung; 2 repräsentative rot gesehen | **bestätigt** |
| 3 | Schritt 7 (LP2): Aussagen gegen Skript und Workflow gefahren | **bestätigt** |
| 4 | ADR-0073: Proposed, Supersedes-Umfang exakt zwei Gegenstände | **bestätigt** |
| 5 | Gate-Stempel == Working-Tree-Hash über HEAD | **bestätigt** |
| 6 | Review-Befunde F-1/F-2 aufgelöst | **bestätigt** |

## Punkt 1 — Job-Form: je Zeile der Aufzählung einzeln

Gemessen an `.github/workflows/release.yml` @ `768474fd` (Datei-Lektüre, Zeilen genannt):

| Zusage (LP1) | Messung |
|---|---|
| `needs: publish` | Zeile 200 ✓ |
| byte-gleiche `if`-Bedingung wie `publish` | `grep -n 'github.event_name' … \| cat -A` → Zeilen 130 und 201 zeichengleich: `if: github.event_name == 'push' && startsWith(github.ref, 'refs/tags/')` ✓ |
| kein `environment:` | im Job-Block (Zeilen 199–213) keine `environment:`-Zeile ✓ |
| Checkout mit `persist-credentials: false` | Zeilen 206–208 (`actions/checkout@…` mit `with: persist-credentials: false`) ✓ |
| `permissions: contents: read` | Zeilen 203–204; `contents: write` trägt nur `publish` ✓ |
| ein Schritt `run: make tap-nachzug`, ohne `${{` | Zeile 213, ohne Expansion, ohne Verzweigung (kein `case`/`$?`/`\|\| true`) ✓ |
| `TAP_TOKEN`/`TAG` nur im Step-`env` dieses Jobs | Zeilen 210–212 (`TAP_TOKEN: ${{ secrets.HOMEBREW_TAP_GITHUB_TOKEN }}`, `TAG: ${{ github.ref_name }}`) ✓ |
| keine Secret-Zuführung sonstwo | `grep -rn 'secrets\.' .github/workflows/` → genau ein Treffer: `release.yml:211` ✓; kein `env:` auf Workflow-Ebene (`grep -n '^env:'` → leer) und keines auf Job-Ebene (`grep -n '^    env:'` → leer) ✓ |
| kein Secret-Zugriff im `publish`-Job | `publish` nutzt `GH_TOKEN: ${{ github.token }}` (Zeile 157) — kein `secrets.`-Zugriff; das ist Bestand vor diesem Slice ✓ |
| `actionlint` grün | `make ci-lint` EXIT 0 (gepinntes Bild, keine Ausgabe) ✓ |

## Punkt 2 — bats-Zähne: 10 Fälle, zwei rot gesehen

`test/tap-nachzug.bats` trägt genau **10** Job-Form-Fälle (Zeilen 993, 1000, 1008, 1015, 1022, 1033, 1037, 1044, 1054, 1073 — `grep -c '^@test'`-Bereich der Job-Form), **je Aufzählungs-Zeile einer**: Job-Anlage + `needs` · if-Gleichheit · keine `environment`-Sperre · Checkout-Bindung · Rechte-Begrenzung · ein `run`-Schritt · Step-`env`-Zuführung · keine Expansion · Secret nur im Step-`env` · keine Verzweigung. Sie lesen die Workflow-Datei (`$WF`), nicht ihre eigene Nachbildung — der Zahn fährt die Verdrahtung des Aufrufers.

**Modul-11-Pflicht, eigen ausgeführt:** Bewusstes Brechen in einer **Kopie** der Workflow-Datei (`mktemp -d`-Baum mit `test/`, `harness/`, `.github/`, Makefile; Lauf im gepinnten bats-Bild, `--network none`), je Fall erst der **unveränderte Bestand** (muss schweigen), dann die Mutation. Kopie danach verworfen; der Bestand des Repos blieb unangetastet.

1. **Fall:** `uebergabe ohne text: der run-Text des Jobs tap enthaelt keine Expansion` — **Mutation:** `run:`-Zeile der Kopie auf `run: make tap-nachzug && echo "exp=${{ github.ref_name }}"` erweitert. **Unmutiert:** 3 ok, EXIT 0. **Mutiert:** `not ok 3 …` EXIT 1, Ausgabe gelesen, Begründung trifft genau die behauptete Ursache:
   > `der run-Text des Jobs tap expandiert — Tag und Token reisen im Step-env, nicht im run-Text`
2. **Fall:** `job-form: eine Secret-Zufuehrung gibt es nur im Step-env des Jobs tap` — **Mutation:** Job-`env:` (`    env:` unter `runs-on` des `tap`-Jobs) in die Kopie eingesetzt. **Unmutiert:** 1 ok, EXIT 0. **Mutiert:** `not ok 1 …` EXIT 1, Ausgabe gelesen:
   > `env auf Job-Ebene — das Secret reist nur im Step-env des Jobs tap`

Beide Rot-Meldungen sind die im bats-Fall `echo`-gebundenen Texte (bats-Zeilen 1050 bzw. 1064), nicht eine generische Fehlform. Die übrigen acht Fälle habe ich **nicht** selbst rot gesehen; ihre Rot-Bindung ist an der Struktur des je Fall fehlschlagenden Ausdrucks ablesbar (eine entfernte Zusage-Zeile lässt den positiven `grep` leer bzw. die Guard-`if` zuschlagen) — benannt, nicht gemessen.

## Punkt 3 — Schritt 7: jede Aussage gegen Skript und Workflow

Gemessen an `docs/user/releasing.md` @ `768474fd`, `harness/tools/tap-nachzug.sh`, `harness/tools/tap-nachzug-nutzlast.sh`, `release.yml`:

- **Regelweg:** „der Job `tap` … fährt `make tap-nachzug` am Tag-Commit — `TAG` reist im Step-`env` des Job-Schritts — und endet mit dem Exit des Ziels" (Zeilen 104–106) — deckungsgleich mit `release.yml:213` (`run: make tap-nachzug`, kein TAG-Argument) und `:212` (`TAG` im Step-`env`). Die Wiedergabe des Jobs ist die exakte Job-Form; die lokale Form `TAG=<tag>` ist dem Job nicht mehr untergeschrieben (F-2 gezogen).
- **Lokaler Ausfallweg unverändert:** „`make tap-nachzug TAG=<tag>` mit `TAP_TOKEN` in der Umgebung des Aufrufers … nennt die Prozedur keine ausführende Rolle" (Zeilen 121–123) — die Form von ADR-0073 Festlegung 3 ✓.
- **Beleg und Meldung:** `make tap-check TAG=<tag>` (Zeilen 168–170), Schritt 8 hängt die Meldung an ihn: „Die Meldung geht erst, wenn `make tap-check TAG=<tag>` (Schritt 7) mit Exit 0 endet" (Zeilen 251–253) ✓.
- **ADR-0073 neben der fortgeltenden Festlegung 4:** Zeilen 118–120 — „… Festlegung 4; den Ort des Zugangsgeheimnisses am Regelweg setzt ADR-0073 auf das Repo-Secret" ✓ (F-1 gezogen).
- **Meldungstexte verbatim gegen die Skriptquellen:** `TAP_TOKEN ist nicht gesetzt` (`tap-nachzug.sh:148`, Exit 2 vor jedem Netz-Zugriff — Prüfung an Zeile 147, vor dem docker-Aufruf; `fehler()` endet Exit 2, Nutzlast `:90–92`) · `Vorab-Tag, Tap bleibt` (`tap-nachzug.sh:156`) · `Formel-Unterschied … erste abweichende Zeile` (`tap-nachzug-nutzlast.sh:184`) · `Vorwärts-Schutz` (`:268`) · `Schreiben abgelehnt … Tap unverändert` für HTTP 401/403/409 (`:252–254`) · `Ausgang des Schreibens ungewiss … make tap-check TAG=` (`:255–256`) · `das Schreiben ist bereits erfolgt` (`:108`) · `gleich — Tag … sha256` (`:271`) · `nachgezogen — Tag … geschrieben und nachkontrolliert` (`:277`) · Wartezeit 65 s (`tap-nachzug.sh:67`, `TAP_WAIT="${TAP_WAIT:-65}"`) · Exit-Klassen 0/1/2 samt `make`-Mapping (Nutzlast-ZUSAGE `:11–18`; `tap-check`/`tap-nachzug`-Rezepte Makefile `:555–573` rufen das Skript). Die `tap-sync: Exit <N>`-Zeile als letzte stderr-Zeile bindet die Suite selbst (`test/tap-nachzug.bats:966–967`).

## Punkt 4 — ADR-0073

- **Status `Proposed`** (Kopf, Zeile 3); Acceptance-Trigger benannt (Abschnitt „Der Acceptance-Trigger") ✓.
- **Supersedes-Umfang exakt zwei Gegenstände** (ADR-0073 Zeilen 28–41): die Ort-Klausel von Festlegung 4 samt Begründung und Anlage-Umfang, und die `environment:`-Erwartung in Folgepflicht 2 und der Fitness-Zeile *Job-Form* samt Vorbedingung; alles übrige bindet unverändert fort (Zeilen 43–50) ✓.
- **ADR-0064 vom Archite-Commit unberührt:** `git diff 07dad33e^..07dad33e --stat` → nur `docs/plan/adr/0073-…md` (neu, 234 Zeilen) und `docs/plan/adr/README.md` (+1); die 0064-Datei fehlt in der Liste — leer ✓.
- **Index ergänzt:** ADR-0073-Zeile im ADR-Index (`docs/plan/adr/README.md:80`, Status `Proposed`); die Revision-Notiz an der ADR-0064-Zeile steht zu Recht noch nicht — sie ist Folgepflicht 1 des **annehmenden** Laufs (ADR-0073 Folgepflicht 1: „eine `Proposed`-ADR revidiert noch nichts") ✓.
- **bats-Anker in der Lesart:** `test/tap-nachzug.bats:972` — „ADR-0064 Folgepflicht 2 **in der Lesart von ADR-0073** — Ort: Repo-Secret, keine Umgebung" ✓ (Architect-Commit `e5014aeb`).
- **ADR-0066 Trigger 1 — Verdikt „nicht eingetreten"** im Kontext (ADR-0073 Abschnitt „Sachstand"): `run: make tap-nachzug` ohne `case`, `$?`, `|| true` — ein Fall der Suite hält die Abwesenheit und färbt beim Eintritt rot (bats `:1073–1083`) ✓.

## Punkt 5 — Gate-Stempel

`cat .harness/state/gates-passed.diffsha` → `0894e8a185161ae45322782d4fa06f1769292581fb1996930adaefc4e2bf7c56`; `harness/tools/working-tree-hash.sh` über dem cleanen Arbeitsbaum → **dieselbe** Zeichenfolge; `git rev-parse --short HEAD` → `768474fd`, `git status --porcelain` → 0 Zeilen. Der Stempel deckt HEAD.

## Punkt 6 — Review-Befunde aufgelöst

- **F-1 (MEDIUM, ADR-Abweichung nur im Plan getragen)** → Archite-Verdikt als Folge-ADR: ADR-0073 (`07dad33e`) + bats-Kopf-Anker in der Lesart (`e5014aeb`) — beide Commits im Baum, Gegenstände oben geprüft ✓.
- **F-2 (LOW, Job-Form-Zuschreibung)** → `768474fd`: der Regelweg-Satz nennt `make tap-nachzug` ohne TAG-Argument und verweist TAG ins Step-`env`; der Commit berührt nur `docs/user/releasing.md` ✓.

## Verbleibende Lücken

1. **Kein Secret wirkt in einem Gate.** Die Job-Form-Zusage gilt auf das Gehaltene: die Fälle lesen die Datei, `make ci-lint` prüft die Syntax — ob das Repo-Secret so wirkt, wie der Job es voraussetzt, belegt erst der erste reale Tag-Lauf (Plan §5 benannt; ADR-0073 Re-Evaluierungs-Trigger beobachten ihn).
2. **2 von 10 Fällen rot gesehen — auf eigene Hand.** Die übrigen acht tragen ihre Rot-Bindung aus der Struktur des je Fall fehlschlagenden Ausdrucks; ein eigener Rot-Lauf je Fall liegt nicht vor (der Auftrag schneidet zwei repräsentative, die Grenze ist benannt statt durch einen Erfolgs-Stempel verdeckt).
3. **Kein Lauf am realen Tap** — ausdrücklich Out-of-Scope des Slices (§1); kein Beleg des Schreib-Pfads gegen die reale Schnittstelle.
4. **Planner-Closure nicht geprüft** — DoD-Häkchen, §7, Register (F-2 als 4. Instanz der Wiedergabe-Klasse — Ausgang weist der Lese-Schritt), Risiko-Ausgänge, `git mv`: Planner-Arbeit (AGENTS.md §3.10).
