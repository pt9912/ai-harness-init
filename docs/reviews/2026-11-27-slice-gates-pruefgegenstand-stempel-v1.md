# Review 2026-11-27 — slice-gates-pruefgegenstand-stempel-v1 (Implementer-Zug, LP1)

**Prüfling:** `831e751f` (LP1: Messrezept je Check im Satzerzeuger-Kopf, Tafel-Korrekturen
baseline-verify/host-bin, Mutationsfall 804) · `72d1d364` (Tafel-Nachzug in der
Stop-Hook-Fixture) · `f5744d91` (Register-Eintrag `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf`).
Parallel-Zug `slice-ci-runner-ohne-docker` (u. a. `e4a15b63`, `857e635c`) ist **nicht** Gegenstand.
**Plan:** `docs/plan/planning/in-progress/slice-gates-pruefgegenstand-stempel-v1.md`.
**Sensor am Ende:** `make gates` — Exit 0 (Tier-2-Teildrift: `environment-check docs-check-host span-check`
fahren, Rest SKIP), Log `/tmp/rv-make-gates.log`.

**Plan §5-Lesart (vom Auftrag gefordert):** Die zwei Protokoll-Läufe stehen laut
Plan-§5 „im Verifikations-Bericht" — das ist das **Verifier→Planner**-Übergabe-Artefakt
(Baseline-Regelwerk `modul-08-agentenrollen.md`: Verifier→Planner:
DoD-/ADR-Konformitätsbericht + Plan-vs-Code-Diff). Die Lesart des Implementers
(Übergabe an den Verifier, keine Protokoll-Läufe im Implementer-Zug) **trägt** am
Plan-Text: §5 ist Closure-Trigger, sein Träger der Verifikations-Bericht, nicht der
Implementer-Report. Der Verifier führt sie aus (Empfehlung am Ende).

---

## Findings

### F-1 — HIGH

- **kategorie:** HIGH
- **quelle:** ADR-0035 Festlegung 2 (Zulässigkeits-Kriterium des SKIP) · ADR-0108
  Festlegungen 1/4 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (nach unten: die SKIP-Meldung behauptet den Rest geschlossen)
- **pfad:** `harness/tools/gates-keys.sh:148-157, 159-165, 167-175` (Mengen der Checks
  ohne `'./Makefile'`) gegen `Makefile:189` (lint), `:218` (build), `:151` (test-bats/test-go),
  `:506` (baseline-verify), `:406` (comment-claims), `:414` (register-ausgang), `:392` (shell-lint), `:875` (docs-check-host)
- **befund:** Für 8 der 12 Kanten-Checks sind die **Rezeptzeilen im Makefile**
  weder in der Tafel-Menge noch — entgegen der eigenen Zusage „Das Messrezept
  benennt den Rest je Zeile" (`gates-keys.sh:44`) — im Rest benannt; der Rest
  für `lint/build/test` ist im Messrezept-Kopf auf „Go-Toolchain- und bats-Fassung"
  geschlossen. Ändern die Rezeptzeilen sich (Flags, Pfad, Verdrahtung, z. B.
  `golangci-lint run ./...` → `run --no-cache ./...`), driften die je-Check-Keys
  dieser Checks nicht, und `make gates` SKIPpt über einer alten Urteils-Basis —
  ein Stilles-Grün-Pfad am SKIP selbst. Die SKIP-Meldung verstärkt das:
  `gates-fast.sh:89` nennt den Rest geschlossen („Docker-Cache-Zustand und Host-Werkzeuge"),
  obwohl Baum-Content ungedeckt bleibt. Zangengang: der in `831e751f` gesetzte
  Messrezept-Kopf kodifiziert diese Lesung selbst neu für `baseline-verify`,
  dessen neue Skript-Zeile die Rezeptzeile `Makefile:506` in keiner der zwei
  Hälften nennt — im selben Kopf ist die Linie je Check ungleich angewandt
  (`host-bin` und `span-check` tragen `'./Makefile'`, `lint/build/test/baseline-verify` usw. nicht).
  Grenze, ehrlich benannt: der Stop-Hook blockt am Turn-Ende über die Gesamt-Dateien
  (ADR-0108 Festlegung 2), CI fährt voll; der unzulässige SKIP ist ein
  lokaler Transient — er bleibt der Fast-Pfad-Vertrag und ist auf einem direkten
  `make gates`-Konsum real.
- **verifizierbar:** ja — Hand-Mutation an einer Rezeptzeile (z. B. `Makefile:189`),
  dann `bash harness/tools/gates-fast.sh`: SKIP statt voller Lauf. Kein Gate fängt es.
- **klasse:** „Je-Check-Schlüssel deckt die Rezeptzeilen der Kante nicht"

### F-2 — MEDIUM

- **kategorie:** MEDIUM
- **quelle:** ADR-0108 Festlegung 1 („die Tafel-Zeile des Plans" als
  **die** deklarierte Bezugsmenge) · Plan-Treue der Messmethode
- **pfad:** `docs/plan/planning/in-progress/slice-gates-pruefgegenstand-stempel-v1.md:245,255`
  (Tafel) gegen `harness/tools/gates-keys.sh:134-142,213-222`
- **befund:** Der Plan-§3-Tafel trägt für `baseline-verify` die Pin-Zeilen
  (`BASELINE_TAG`/`BASELINE_ZIP_SHA256`, `Makefile:33/42`, `.d-check.yml sources`;
  in der Implementation nur `internal/fetch/baseline.go`) und für `host-bin` die
  Verdrahtungs-Form ohne die Modul-Daten — die gefahrene Tafel ist an genau
  diesen zwei Zeilen eine andere; die Korrekturen des Codes sind am Wahrheitsgehalt
  gerechtfertigt (siehe Negativbefunde), aber die Plan-Datei wurde nie nachgezogen
  (letzter Plan-Commit `b4491b3d` vor der Implementation `413b6b50`). Die „eine
  Definition je Bezugsmenge" liegt damit gespalten in zwei Texten vor.
- **verifizierbar:** ja — Textvergleich Plan-Tafel vs. `tafel_menge` (Rezept-Wirklichkeitstest oben).
- **klasse:** „Tafel driftet vom Satzerzeuger" — Auflösung als Plan-Korrektur
  (Planner), kein stiller Bestand.

### F-3 — MEDIUM

- **kategorie:** MEDIUM
- **quelle:** Reviewer-Skill MEDIUM „Zusicherung über einer Menge, die leer sein kann"
  (seit slice-mutate-fall-filter-und-die-belegform-vereinigung) je [`AGENTS.md`](../../AGENTS.md) §3.6
- **pfad:** `test/mutations/804-gates-menge-skript-und-baubasis-entzaubert.sh:11-14`
  gegen `test/gates-keys.bats:122-139` und `harness/tools/gates-keys.sh:220`
- **befund:** Die `'./go.sum'`-Menge-Zeile trägt heute keinen Walk-Treffer
  (`ls go.sum` → fehlt), der Baubasis-Wächter überspringt sie mit
  `[ -f "$REPO/$form" ] || continue` (Bats:136), und der Fall-Header zählt
  `go.sum` unter die „entzauberten" Einträge — gemessen wird sie von keinem:
  eine Deletion **nur** der `go.sum`-Zeile lässt die Suite 9/9 grün (gemessen,
  Worktree-Probe). Der Wächter-Test benennt die Grenze selbst („go.sum liegt im
  Bestand NICHT vor … gemessen wird der Bestand, nicht seine Zukunft"); der
  Fall-Kopf beansprucht sie trotzdem als Messgegenstand. Eine Sonde im selben
  Test fehlt und ist am realen Walk nicht sauber anlegbar — die Lücke gehört am
  Fall-Kopf benannt statt über den Schwester-Treffer gegenglichen.
- **verifizierbar:** ja — Worktree: nur `/go\.sum/d` im `host-bin`-Bereich,
  `bats test/gates-keys.bats` → 9/9 grün.
- **klasse:** „Inerte Menge-Zeile zahlt auf den Fall-Kopf ein"

### F-4 — LOW

- **kategorie:** LOW
- **quelle:** Maintainability (Beleg-Text-Konsistenz)
- **pfad:** `docs/plan/planning/observations/BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf/evidence/slice-gates-pruefgegenstand-stempel-v1.md:21-23`
- **befund:** „die Lage wurde drei Mal gesehen (zwei 801-Teilläufe bei
  Stallschlanke 900 s und 2700 s, einer davon mit dem Zusatzbefund `host-baum`)"
  — die Aufzählung nennt zwei Teilläufe; der dritte Beleg-Zug bleibt unbenannt.
  Der Zähler im `state.md` zählt Beleg-Dateien (1) konsistent; ein Leser, der
  Sichtungen aus dem Beleg-Text zählt, liest drei ohne dritte Adresse.
- **verifizierbar:** nein (Beleg-Text) — Träger ist der nächste Beleg, der die
  dritte Sichtung nennen oder die Zahl korrigieren kann.
- **klasse:** „Zahl im Beleg über der Aufzählung"

## Geprüft, ohne Befund

- **LP1-Tafel-Korrekturen je Wahrheitsgehalt (baseline-verify):** trägt — das
  Gate-Rezept fährt `bash harness/tools/baseline-verify.sh` (`Makefile:506`); das
  Skript liest sich selbst ein, den vendored Baum und die `SHA256SUMS` **im
  Tag-Verzeichnis** (Kopf von `baseline-verify.sh`); die Wurzel-Stelle ist tot:
  `ls SHA256SUMS` → *No such file or directory*; der Baum-Glob deckt die echte
  Stelle — `bash harness/tools/gates-keys.sh menge baseline-verify | head -1` →
  `.harness/baseline/v7.0.0/SHA256SUMS`.
- **LP1-Tafel-Korrekturen je Wahrheitsgehalt (host-bin):** trägt — das Rezept
  kompiliert `go build ./cmd/ai-harness-init` samt internal-Importen und liest die
  Modul-Daten; `'./Makefile'` ist in der Menge (Rezeptzeile gedekt — siehe F-1 für
  die Checks, bei denen das fehlt); die `go.sum`-Zeile ist inert (F-3) und der
  Rest (uname, git) am Kopf benannt.
- **Mutationsfall 804 (MR-071/MR-090):** Anker am Quellbestand byte-genau —
  `/baseline-verify\.sh/d` trifft genau die eine Menge-Zeile (`grep -c`→ 1), der
  Region-Lauf löscht im `host-bin`-Bereich genau `go.mod`/`go.sum`/`internal/*.go`,
  die gleichlautenden lint/build/test-Zeilen und die Kommentarzeilen bleiben unberührt
  (Diff der Hand-Kopie: exakt 4 gelöschte Zeilen). Ein Zug je sed **rot gesehen**
  (Worktree + `bats test/gates-keys.bats`: Test 7 und Test 8 rot, Rest grün, keine
  leere Menge entstanden), danach zurück — ohne Rest im Baum
  (`git worktree remove --force`, `git worktree prune`).
- **`72d1d364` (Stop-Hook-Fixture):** Nachzug folgt der Tafel-Berichtigung
  byte-genau (`SHA256SUMS` → `harness/tools/baseline-verify.sh`); die behauptete
  Rot-Vor-Form (leere Menge für `baseline-verify` → record-gates.sh Exit 1,
  fail-closed MR-017) folgt am Skript; nach dem Nachzug grün (Go-Tests bestanden
  im `make gates`-Lauf).
- **`f5744d91` (Register-Eintrag):** Form stimmt — `BEO-ALL/<slug>/` mit
  `state.md` (**Stand:** offen, Zähler-Lesung) und `evidence/slice-<Kennung>.md`;
  Zähler 1 = `ls evidence | wc -l`. Die Behauptung greift am Quelle-Skript:
  `greift_main` liest `MUTATE_CASES` aus der Umgebung (`harness/tools/mutate.sh:943-944`),
  die teillauf-/greift-Wrapper-Fälle fahren mit dieser Umgebungs-Variablen; ein
  Teillauf exportiert sie in die bats-Suite (Grün-Vorlauf). Die Rot-Form der Fälle
  trägt der direkte `BATS_TARGET`-Lauf, wie der Beleg behauptet — **Fall 801
  selbst war kein Zug nötig** (unverändert in der Zange): sein sed-Anker trifft
  die Byte-Prüfung `[ "$ist" != "$sha" ]`, die behauptete Rot-Menge (Tests 1/2/7 =
  die drei Happy-Läufe, Negative 3/4 zufällig gleichwortlaut grün) hält an der
  Logik der Fall-Datei; das Leak-Wissen trägt der neue Register-Eintrag daneben, getrennt vom Fall.
- **Parallel-Commit-Zange:** je `git show --stat` — `831e751f` berührt
  `gates-keys.sh`/`test/gates-keys.bats`/`test/mutations/804-…`, `72d1d364`
  `stophook_test.go`, `f5744d91` Register + Slice-Plan; keine Parallel-Träger-Datei
  des ci-runner-Zugs in der eigenen Zange.
- **`make gates`** einmal am Ende: Exit 0, Tier-2-Teildrift-Form sauber
  (`environment-check docs-check-host span-check` fahren, Rest SKIP, Rest-Meldung
  wie im Vertrag).

## Empfehlungen an den Verifier

1. **LP2/§5:** die zwei Protokoll-Läufe im Verifikations-Bericht fahren —
   Tier-2-form über ADR-0108 Festlegung 3: (a) Stempel-Lauf, dann Doku-only-Commit
   (SKIP der nicht-Doku-Checks + `docs-check-host` läuft, SKIP-Meldung in derselben
   Ausgabe), Code-only-Commit (nur die Code-Checks), (b) Record-only-Commit
   (nur `.harness/stamp/**` — SKIP vollständig, kein Stempel rotiert). Die Keys
   sind über den Implementer-Zug frisch gestempelt.
2. **Fall 801:** direkt verifizieren, dass kein Zug am Fall nötig war — der
   Fall-Affekt (Leak) trägt im Register-Eintrag
   `BEO-ALL/mutate-cases-leakt-in-den-bats-gruen-vorlauf` (Zähler 1, unter der Schwelle).
3. **F-2** als Plan-Korrektur an den Planner übergeben (Tafel-Zeilen
   baseline-verify/host-bin in der Plan-Datei nachziehen); **F-1** ist ein
   Folge-Slice-Kandidat (je Check `'./Makefile'` in der Menge wie `host-bin`,
   oder Rezeptzeilen als benannter Rest je Zeile im Messrezept und in der
   SKIP-Meldung — Plan-Entscheidung mit Begründung, kein stiller Eintrag).

## Rollenwiderspruch

Keiner — kein Finding behauptet einen ADR-Verstoß des Implementers gegen eine
angeblich legitimierte Abweichung (Konflikt-Pfad Modul 8 entfällt); F-2 verläuft
als **Plan-Korrektur** (Architect→Planner-Übergabe: Plan-Diff), der Implementer
kann die Tafel-Berichtigung als Übergabe-Artefakt annehmen.
