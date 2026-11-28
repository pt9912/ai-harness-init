# Review-Report: slice-release-bau-dockerlos-v1 — 2026-11-28

**Review-Art:** Code-Review — geprüft gegen den Slice-Plan + Konventionen
(Modul 10 §Drei Review-Arten); DoD/Spec-Konformität bleibt dem Verifier.

**Gegenstand:** Commits `e8af1378..3bceb869` auf main (Claim `e8af1378`,
LP a `746b2b6d`, LP b `43f8edac`, LP c `bdf5c6cd`, Zellen-Nachzug
`3bceb869`) · `slice-release-bau-dockerlos-v1` · Diff gegen HEAD `bf662609`

**Skill:** `.harness/skills/reviewer.md` @ v2.3.0 ·
**Modell:** claude (Subagent, Reviewer-Kontext) · **Datum:** 2026-11-28

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- `slice-release-bau-dockerlos-v1` (Plan-Dokument, Stand mit §3-Nachtrag aus LP c)
- ADR-0115 (Festlegungen 1–6), ADR-0109, ADR-0059 (Folgepflicht 1), ADR-0063
  (Festlegungen 1/2), ADR-0035 Festlegung 4
- `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`
- `MR-014` (Setzung 1), `MR-098` (Mischform), `MR-071`/`MR-090` (Anlage- und
  Anker-Disziplin der Mutations-Fälle)
- `AGENTS.md` §3 (Hard Rules)

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | LOW | Die Plan-Spalte nennt `docs/user/releasing.md` Zeilen 164/290 als Bau-Züge; die Umsetzung ließ sie stehen — korrekt (Zeile ~164 trägt den Transport-Zug der `make release-warten`-Abfrage im gepinnten Bild des Fetch, Zeile ~290 die Exit-Klassen des `tap-nachzug`-Transports, kein Bau-Zug), aber die Plan-Zeile trägt die Berichtigung nicht. | Plan §3 vs Abschnitt | `docs/user/releasing.md` · „der Schritt fragt im gepinnten Bild des Fetch … ab" | ja — Lektüre der zwei Abschnitte gegen die DoD-c-Messung | Plan-Zeilenzuordnung Bau/Transport wandert nicht nach |
| F-2 | INFO | Die `make mutate MUTATE_CASES=`…`-Umgebung leakt in den isolierten Gruen-Vorlauf: der lokale Teillauf des Falls `836-release-bau-ldflags-injektion-entzogen` bricht im Vorlauf an `test/mutate-driver.bats` Fall 427 (`MUTATE_CASES nennt einen unbekannten Fall: '836-…'` über der 427-Fixture), noch vor der Rot-Messung — kein Zahn-Beweis lokal, die kuratierte Rot-Form verbleibt beim CI-Branch-Vorbehalt. | Maintainability | `test/mutate-driver.bats` · Fall 427, Lauf-Beleg `/tmp/rev-probe-2026-11-28/mutate-836.log` | ja — der CI-Branch-Lauf (`mutate/<kennung>-<sha8>`) liefert den Rot-Beleg | Gruen-Vorlauf bricht an Umgebungs-Leak vor der Rot-Messung |
| F-3 | INFO | Der MR-014-Text-Wächter über der YAML (`sed 's/#.*$//'` vor dem Docker-/Inline-Scan) entkomgt der Quoted-Hash-Form: „docker build" hinter einem `#` in einem quoted `run:`-Wert wird mit dem Kommentar abgeschnitten (Formen-Probe Form 2, gefahren auf Kopie unter /tmp). Die Grenze nennt der Testkopf nicht; die Konsequenz trägt der reale CI-Dispatch-Lauf, kein lokaler Sensor. | AGENTS.md §3.6 · MR-014 Setzung 1 | `test/release-host-bau.bats:116` · Formen-Probe: 5 Formen gefahren, Form 2 entkomgt | nein — kein Sensor fährt diese Text-Form | Grenzform eines Text-Wächters unbenannt (Quoted-Hash entkommt dem Kommentarstrich) |
| F-4 | INFO | Die Bau-Form-Zusage (`CGO_ENABLED=0`, `-trimpath`) im Makefile-Kommentar wird nur am Rezept-Text gebunden (Tafel-Koppel-Test); die byte-identische-Zweitlauf-Zusage bindet sie nicht (zwei Läufe desselben Baums auf demselben Host bleiben auch ohne `-trimpath` identisch), und der Kommentar nennt die Grenze nicht. | AGENTS.md §3.6 | `Makefile:651` · Kommentarblock über dem Target | nein — kein Sensor misst die Pfad-Freiheit des Binaries | Bau-Form-Zusage nur am Rezept-Text gebunden (-trimpath) |
| F-5 | LOW | Die Formel-Teillauf-Ablage (`elif`-Zweig „Teillauf ohne die vier brew-Plattformen … die Formel entfaellt im DEST") ist von keinem Test befahren: die no-tag-Form fährt den `-z`-Zweig, der Ziel-Mengen-Test den Count-Bruch; die Form `RELEASE_PLATFORMS=linux/amd64 TRAEGER_VERSION=x` (eine brew-Plattform mit Wert) erreicht den Zweig in der Suite nicht. Die Zusage „meldet den Fehlt statt den Lauf zu brechen" (Plan §3-Nachtrag) bleibt ungebunden. | AGENTS.md §3.6 · Plan §3 | `Makefile:674` | ja — eine bats-Form über einen Ein-Plattform-Lauf mit gesetzter `TRAEGER_VERSION` würde den Zweig fahren | Teillauf-Ablage der Formel-Stufe ohne bindenden Fall |
| F-6 | LOW | Der artifacts-Job-Kommentar nennt „der Tag, den der Pin-Zug vor dem Bau gesetzt hat"; die Stelle enthält keinen Pin-Zug vor dem Bau — der Wert kommt aus `github.ref_type == 'tag'` und der Schritt selbst ruft nur das Target. Der Satz beschreibt einen Vorgang, der an dieser Stelle nicht liegt. | AGENTS.md §3.7 | `.github/workflows/release.yml:69` | nein — kein Gate liest Kommentar-Vorgänge | Kommentar nennt einen Vorgang, der an der Stelle nicht liegt (importierter Pin-Zug) |
| F-7 | INFO | LP-Reihenfolge: der LP-a-Commit (`746b2b6d`) trägt den MR-014-YML-Test, dessen Soll-Form erst der LP-b-Commit (`43f8edac`) herstellt — am LP-a-Stand trägt release.yml `make release-artifacts-host` null Mal (`git show 746b2b6d:.github/workflows/release.yml \| grep -c` → 0), der Teil-Baum färbt test-bats rot. Zwischens-Zug innerhalb des zusammen gepushten Zweigs, Tip grün. | Maintainability | `test/release-host-bau.bats:116` · LP a/b | ja — `make test` am LP-a-Stand | Wächter landet im Commit vor seinem Soll (Teil-Baum rot zwischen LP a und b) |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Plan-vs-Diff LP a (Festlegung-1-Form: Target über `RELEASE_PLATFORMS`-Tafel, `for p in`, `CGO_ENABLED=0`/`GOOS`/`GOARCH`/`-trimpath`, Windows-`.exe` am Ext-Mechanismus, Fassungs-Injektion je `$(if $(TRAEGER_VERSION))`, `release-sums.sh generate` am selben Ort, ADR-0059 Folgepflicht 1) | geprüft, ohne Befund — der Sechs-Satz bleibt am `test/release-matrix.bats`-Bestand (Zusage 1/2), wie im Plan §3 „Bestand, bewusst unberührt" deklariert |
| Wächter-Form LP a (`test/release-host-bau.bats`: byte-identischer Zweitlauf über echtes `go build`, `--version`-Fehlt-Fall Exit 2 mit realer Meldung `keine Fassung injiziert`, kein Stub; Fehlt-Fall im DEST über `release-sums.sh verify`; Ziel-Mengen-Zeile; Tafel-Koppel-Test) | geprüft, ohne Befund — realer Bau, kein Fixtures-Grün; die `# files:`/`# expect:`-Anker der drei neuen Fälle greifen an der Tafel-, ldflags- und Step-Zeile des heutigen Bestands (MR-071), `mutate-greift` grün im je-Check-Stempel-Satz des `make gates`-Laufs — SKIP über gedecktem Satz, 12 Keys |
| Mutations-Exklusivität (Fälle 835/836/837) | teilweise gefahren — Fall 836 lokal angefahren, brach (F-2) im Gruen-Vorlauf an Vorbestand 427, keine Rot-Aussage; 835/837 gelesen, nicht gefahren: die `# expect:`-Zeichenketten sind echte Teilketten der Wächter-Namen (`release: die Plattform-Liste deckt GENAU …`; `release-host: der artifacts-Job ruft das Host-Target …`); der Rot-Beleg verbleibt beim CI-Vorbehalt wie gehandhabt |
| Plan-vs-Diff LP b (artifacts-Job ruft nur `make release-artifacts-host`; `make ci-runner-setup` + PATH-Zug statt Inlines; Kopfkommentar-Grenze in der Entfallen-Fassung; Formel-Fill ohne YAML-Inline) | geprüft, ohne Befund — keine zweite Version-Stelle, kein Docker-Zug im Step-Körper |
| Plan-vs-Diff LP c (Zellen in host-Form; opt-in Weg je ADR-0109-Fassung) | geprüft, ohne Befund |
| MR-014 Setzung 1 (CI ruft ausschließlich make-Ziele) / MR-003-Verdrahtung (`workflow_dispatch:`-Trigger vorhanden, publish-Condition tag-gebunden, artifacts bedingungslos) | geprüft, ohne Befund |
| MR-098 (Go-Install aus der Pin-Stelle: `ci-runner-setup` liest die Inventar-Zeile, Soll abgeleitet, pinsync hält sie gegen `GO_VERSION = 1.27.4`) | geprüft, ohne Befund |
| DoD-c-Messung `grep -n 'docker-getrieben\|Docker-only' harness/README.md harness/sensors/artifact-host.md docs/user/releasing.md` | gefahren → 0 Treffer; build-Zelle trägt die `make build-image`-Kopplung wieder (Zellen-Nachzug `3bceb869`, Fall-660-Klasse) |
| DoD-c-Nachzug laut Handoff (releasing.md ~164/290) | gefahren → Transport-Züge, kein Bau-Zug (F-1 dokumentiert die Plan-Angabe); Bau-Züge am selben Ort trägt LP c in der host-Form |
| Laufzeit-Bemerkung (MR-025: eine Zahl braucht ihr Kommando daneben) | `grep` über Makefile/release-host-bau.bats/release.yml/artifact-host.md/releasing.md/README nach `Laufzeit\|Sekunden\|Minuten\|dauert` → 0 Treffer; keine Zahl, MR-025 nicht berührt |
| ADR-0115-Folgepflicht „AGENTS.md §3.9-Textzüge" (Festlegung 6, Konsequenzen) | geprüft, ohne Befund — der Bestand nennt den Release-Bau in AGENTS.md nicht (`grep -n 'Release-Bau' AGENTS.md` → 0, Bestätigung der Plan-Ausschluss-Messung); die Enumeration findet keinen Gegenstand |
| §3.7 Kommentar-Klassen (Makefile-Target-Block, bats-Kopf, yml-Kopfkommentar, artifact-host.md-Absatz) | geprüft, eine Ausnahme als F-6; Zustands-/Chronik-Formen: keine im Diff |
| Commit-Zuschnitt (e8af1378 nur `Verantwortlich:`-Feld; LP a nur Makefile+2 Fälle+neuer Wächter; LP b nur release.yml+ci-runner-Wächter+837; LP c nur Doku-Zellen+Plan-§3-Nachtrag; Nachzug nur README-Zelle) | geprüft, ohne Befund — jeder Commit berührt nur seine Plan-Zeile; keine Architect-Artefakte in Implementer-Commits (§3.8 nicht berührt) |
| Handoff-Vorabstand 1 (`make mutate-auswahl` fahrbar?) | gefahren → `mutate-auswahl: 124 Fall/Faelle über 1b2667be37b5..HEAD (Schwelle 8 lokal)`, Exit 10 (CI-Branch-Anweisung `mutate/slice-release-bau-dockerlos-v1-bf662609`); die drei Fälle 835/836/837 stehen in der Fallmenge; lokaler Rot-Lauf nicht fahrbar, Vorbehalt bestätigt |
| Handoff-Vorabstand 2 (workflow_dispatch-Beleg) | formal verdrahtet (Trigger + Job-Form), reale Beleg bleibt CI; keine zusätzliche lokale Aussage behauptet der Diff |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 3 |
| INFO | 4 |

**Finding-Klassen dieses Laufs:** Plan-Zeilenzuordnung Bau/Transport wandert nicht nach · Gruen-Vorlauf bricht an Umgebungs-Leak vor der Rot-Messung · Grenzform eines Text-Wächters unbenannt (Quoted-Hash entkommt dem Kommentarstrich) · Bau-Form-Zusage nur am Rezept-Text gebunden (-trimpath) · Teillauf-Ablage der Formel-Stufe ohne bindenden Fall · Kommentar nennt einen Vorgang, der an der Stelle nicht liegt (importierter Pin-Zug) · Wächter landet im Commit vor seinem Soll (Teil-Baum rot zwischen LP a und b)

**Verlaufs-Belege dieses Laufs:** `make gates` → Exit 0, SKIP über gedecktem je-Check-Satz (12 Keys: environment-check, baseline-verify, docs-check-host, lint, build, test, shell-lint, ci-lint, comment-claims, register-ausgang, mutate-greift, host-bin, span-check); benannter Rest je ADR-0108 Festlegung 4. `make mutate-auswahl SLICE=slice-release-bau-dockerlos-v1` → 124 Fälle, Exit 10. Formen-Probe des MR-014-Guards: 5 Formen auf Kopien unter `/tmp/rev-probe-2026-11-28/`, kein Rest im Baum.

## Verdikt

**Merge-blockierend:** nein — keine HIGH-, keine MEDIUM-Befunde. Der Diff
trägt die Festlegungen 1–6 je Plan; die zwei offen bleibenden Belege (Rot-Beleg
der drei Mutations-Fälle, reale workflow_dispatch-Kette) sind der
CI-Vorbehalt des Handoffs und formal verdrahtet, nicht still geblieben.

**Übergabe:** Findings an den Implementer; die Finding-Klassen gehen in die
Slice-Closure §7 und von dort in den Zähler. Dieser Report ist Lauf-Beleg.
