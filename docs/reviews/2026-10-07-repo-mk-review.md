# Review — slice-anwender-targets-leben-in-repo-mk

**Rolle:** Reviewer (`.harness/skills/reviewer.md`) · **Datum:** 2026-10-07 ·
**Gegenstand:** Commits `cbc4722b`, `4c0ce2c4`, `0354ca27`, `7a5dbdd3` gegen den Slice-Plan,
[ADR-0080](../plan/adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md),
ADR-0007, ADR-0054, `AGENTS.md` §3.6/§3.7.

**Summary:** 0 HIGH · 0 MEDIUM · 4 LOW · 0 INFO. Wiederkehrende Klasse: *Teilersetzung lässt eine
Nachbar-Aussage stehen, die der neue Zustand widerlegt* (L1, L2, L3).

## Findings

### L1 — Umbenannter Test behält Doku-Kommentar und Vorbedingung der alten Zusage

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.6
- `pfad`: `internal/emit/selbstpruefung_test.go:216-233`, `:270-289`
- `befund`: Der Kommentar nennt noch den alten Namen `…WirdVonKeinemLaufGeschrieben` und sagt
  zu, der Ort trage „nur, wenn kein Lauf des Werkzeugs ihn anfasst" und „GEPRUEFT SIND ALLE PFADE,
  DIE DIESES PAKET SCHREIBT"; der Rumpf vergleicht nur noch `konvergent`. `geschrieben` (mit
  `CommandPaths`/`AgentPaths`) wird gebaut, aber nur von der Leer-Vorbedingung gelesen, die damit
  eine Menge prüft, über die die Schleife nicht läuft.
- `verifizierbar`: nein
- `klasse`: Teilersetzung lässt widerlegte Nachbar-Aussage stehen

### L2 — Emittierter Kopf: „der eine Pfad" neben einem zweiten im selben Absatz

- `kategorie`: LOW
- `quelle`: AGENTS.md §3.7, ADR-0080 Festlegung 2
- `pfad`: `internal/emit/templates/enforce/selbstpruefung.mk:17-21`,
  `internal/emit/templates/enforce/selbstpruefung.sh:40-44`
- `befund`: Derselbe Absatz, der repo.mk als „nur angelegt, wo sie fehlt" nennt, schließt mit
  „Der Traeger unter .githooks/ ist der eine Pfad, den dieses Werkzeug an einen belegten Ort nicht
  schreibt" — im Ziel liest der Adopter zwei sich widersprechende Aussagen über die Klasse. In der
  `.mk` beginnt der Satz auf einer Zeile, die der Diff neu geschrieben hat (Cutoff §3.7 greift).
- `verifizierbar`: nein
- `klasse`: Teilersetzung lässt widerlegte Nachbar-Aussage stehen

### L3 — enforce.go: „der eine Eintrag mit SkipIfPresent" (Hinweis des Implementers bestätigt)

- `kategorie`: LOW
- `quelle`: Maintainability (Doku-Drift)
- `pfad`: `internal/emit/enforce.go:86-90`
- `befund`: Die Liste trägt `harness/sensors/.gitkeep` (Z. 163, Bestand) und jetzt `repo.mk`
  (Z. 168) mit `SkipIfPresent`; der Commit-Träger steht gar nicht in ihr (`commitmsg.go:58`). Die
  Kommentarzeilen selbst hat der Diff nicht berührt — nach dem Cutoff §3.7 kein Verstoß dieses
  Diffs, aber der Diff fügt der Liste, die der Satz beschreibt, einen zweiten Widerspruch hinzu.
- `verifizierbar`: nein
- `klasse`: Teilersetzung lässt widerlegte Nachbar-Aussage stehen

### L4 — Handbuch: „alle drei liegen mit LF im Repository" gilt für repo.mk nur beim Startinhalt

- `kategorie`: LOW
- `quelle`: LH-FA-01 (Handbuch-Zusage)
- `pfad`: `docs/user/benutzerhandbuch.md` §Zeilenenden und Kennungs-Form der Prüf-Konfiguration
- `befund`: Die Wurzel des Ziels trägt keine `.gitattributes` (`ls .gitattributes` im Ziel →
  „nicht gefunden"), der Startinhalt ist LF (`od -c repo.mk | grep -c '\\r'` → 0). `Makefile`
  und `d-check.mk` schreibt jeder Lauf neu; repo.mk schreibt der Lauf nur einmal — speichert ein
  Adopter sie mit CRLF bei `core.autocrlf=false`, liegt sie mit CRLF im Repository, und der Satz
  sagt LF zu.
- `verifizierbar`: nein
- `klasse`: Zusage über eine Adopter-Datei aus der Eigenschaft einer Werkzeug-Datei abgeleitet

## Kommandos und Ausgaben

Ziel: `make host-bin`; `git init -q ziel && ai-harness-init --name repo-mk ziel` im Scratchpad.

| Probe im Ziel | Ergebnis |
|---|---|
| `repo.mk` mit `SELBSTPRUEFUNG_GATE = make eigen`, `E2E_ABDECKUNG_QUELLE = x.sh` | beide überschreiben das `?=` der Fragmente |
| Fragment `FOO = frag` bzw. `FOO := frag`, repo.mk `FOO = repo` | `repo` (repo.mk gewinnt auch gegen `=`/`:=` eines Fragments); nur `override` im Fragment schlägt sie — kein emittiertes Fragment trägt `override` |
| repo.mk mit `?=` | Fragment-Wert bleibt — der Kopf von repo.mk verlangt `=`, zutreffend |
| nur `harness/mk/vorgaben.mk` (alter Ort) | Vorgabe wirkt weiter über den Glob; beide gesetzt → repo.mk gewinnt |
| `eigen-gate` (sleep 3) über `GATE_CHECKS +=`, `make -j gates` | rc=0, `EIGEN-GATE-ENDE` in der Ausgabe, Stempel geschrieben |
| zusätzliches `eigen-rot` (exit 1), Stempel vorher gelöscht | rc=2, `.harness/state/` ohne `gates-passed.diffsha` — record-gates läuft nicht |
| `make mutate MUTATE_CASES='527-… 528-… 529-…'` | `3 ok, 0 Befund(e)` |
| Gegenprobe 528 (`t.Skip` nur in `TestEnforce_IdempotenzKlasseJePfad`) | rot über `TestSelbstpruefung_DerGenannteVorgabeOrtWirdNieUeberschrieben` |
| Gegenprobe 529 (`t.Skip` nur im benannten Test) | `make test-go` grün — der benannte Test bindet allein |
| `make e2e-abdeckung`; `git status --short` | leer — Sicht byte-gleich |

## Geprüft, ohne Befund

- (a) Aggregator: `-include repo.mk` steht nach dem Glob und vor `record-gates: $(GATE_CHECKS)`;
  ein Gate aus repo.mk läuft vor dem Nachweis und blockt ihn bei Rot (gefahren); die Vorgabe-Aussagen
  der vier Vorlagen-Köpfe und des repo.mk-Kopfs sind wahr (gefahren, Tabelle oben).
- (b) Startinhalt: nur Kommentar, keine Werkzeug-Kennung, Klasse `SkipIfPresent`; ein Ziel mit
  `harness/mk/vorgaben.mk` bricht nicht, die Vorgabe wirkt weiter (gefahren).
- (c) 527/528/529 grün im Treiber; 528 färbt zusätzlich den Vorgabe-Ort-Test, der benannte Test
  bindet aber die Klasse von repo.mk unabhängig von `SelbstpruefungVorgabeOrt` — kein Befund; kein
  Fall-Kopf behauptet Exklusivität.
- (d) `repo_mk_im_ziel` misst, was die Deklaration sagt, die Teilabdeckung steht am selben Ort;
  Sicht byte-gleich; die Rot-Gegenprobe der Stufe (DoD) ist nicht gefahren — Verifier.
- (e) Handbuch: Hinweise, FAQ, Klassentabelle und Verzeichnisbaum stimmen mit dem Ziel überein
  (bis auf L4); keine Restnennung von `vorgaben.mk` außerhalb des Plans und Fall 529.
- (f) siehe L3.
