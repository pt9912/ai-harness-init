# welle-06-freshness — Results-Notiz

**Welle:** [welle-06-freshness](welle-06-freshness.md). **Abschluss-Beleg statt Datum:** alle drei
Slices in `done/`, `make gates` Exit 0, `make mutate` 55 ok/0, jede Achse im nächtlichen
`upstream-drift`-Job verdrahtet, dieser Beleg-Text.

---

## 1. Geliefert

Der nächtliche `upstream-drift`-Job prüft seit dieser Welle **jede versions-gepinnte Komponente**
gegen ihr Upstream-Latest, nicht mehr nur den Regelwerk-Tag:

- **[slice-040](slice-040-freshness-generalisierung.md)** — die `releases/latest`-Mechanik von
  `baseline-freshness` verallgemeinert zu einem parametrierten, quellen-agnostischen Sensor
  `harness/tools/component-freshness.sh` (`name · pinned · releases-latest-url`); `baseline-freshness`
  wurde ein dünner Wrapper. Zwei GitHub-Achsen dazu: **golangci-lint** (`GOLANGCI_LINT_VERSION`) und
  **d-check** (`DCHECK_IMAGE`-Tag).
- **[slice-041](slice-041-go-version-freshness.md)** — **Go-Toolchain** als erste Sonderquelle
  (kein GitHub-`releases/latest`): Wrapper `go-freshness.sh`, Fetch `go.dev/VERSION?m=text` +
  Normalisierung (`go1.x.y` → `1.x.y`), Vergleicher wiederverwendet.
- **[slice-042](slice-042-cpp-ubuntu-tag-freshness.md)** — **C++/ubuntu-Base-Tag** als zweite
  Sonderquelle (Docker Hub): Wrapper `cpp-freshness.sh`, Fetch der ubuntu-Tags + **LTS-Extraktion**
  (höchstes gerades `NN.04`; Interims `23.04`/`25.04`/`.10` ausgefiltert), Pin aus `DefaultCppVersion`
  (`internal/gen/cpp.go`).

Ergebnis: eine neuere Version **irgendeiner** gepinnten Komponente färbt den Drift-Lauf rot
(read-only Meldung, kein Bump). **Real belegt** — der manuelle `workflow_dispatch`-Lauf meldete
`baseline-freshness` (v3.5.0→v3.5.1) und `freshness-go` (1.26.4→1.26.5) als VERALTET, während
golangci-lint/d-check grün blieben: der Sensor unterscheidet echt.

**Nebenlieferungen (Wartung, während der Welle):** CI-Split
[`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) (Pro-Push-Gates) +
`upstream-drift.yml` (Netz-Sensoren, `schedule` + **`workflow_dispatch`** = manuell startbar);
`actions/checkout` v4.2.2 → v5.1.0 (Node-20-Deprecation behoben); Go-Toolchain-Bump 1.26.4 → 1.26.5
(löst die `freshness-go`-Drift auf). Alle unter [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)/[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)-Nachträgen dokumentiert.

## 2. Was funktionierte

- **Das Sonderquellen-Muster trug dreimal.** Der quellen-agnostische Vergleicher (`--compare` aus
  slice-040) blieb über GitHub-, go.dev- und Docker-Hub-Quellen unverändert; je Achse war nur der
  Fetch neu. Die netz-berührende neue Logik lebt je hinter einem **hermetischen Sub-Kommando**
  (`--compare` / `--normalize` / `--latest-lts`) — offline mit Fixtures testbar und mutations-bewachbar,
  ohne je das Netz zu treffen ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) offline-grün, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) bash+curl ohne jq).
- **Ist-Messung vor Code verhinderte Fehlschnitte.** Für Go wurde die untaugliche
  `golang/go`-GitHub-Achse verworfen (Redirect auf `.../releases`); für ubuntu die LTS-Regel
  (gerades Jahr) live belegt — beide vor der ersten Zeile Code.
- **`make mutate` fing echte Regressionen** — nicht nur die neuen Wächter (46–50 rot gesehen),
  sondern den Go-Bump-Nachhall (Mutation 18, s. u.).

## 3. Was anders lief als geplant

- **Go-Bump-Nachhall.** Der 1.26.4→1.26.5-Bump lief nur gegen `make gates`; die wert-hardcodende
  Mutation 18 veraltete still und flog erst im nächsten `make mutate`-Lauf (slice-042) als BEFUND auf.
  Generisch re-verankert (`[0-9.]*`-Match, überlebt künftige Bumps).
- **Doppel-Fund bei slice-042.** Review (MEDIUM-1) **und** Verifier (DoD-3) fanden unabhängig
  denselben Defekt: der Leer-Pin-Pfad nutzte `${CPP_PINNED:?}` (Exit 1 = VERALTET-Klasse), während der
  vom Slice **neu** hinzugefügte Header-Satz Exit 2 zusagte. Gefixt (expliziter Check → Exit 2 + Test +
  Mutation 50).

## 4. Steering-Loop-Einträge

1. **Ein NEU verschärfter Contract-Kommentar liefert im selben Zug Code + Test + Mutation.** Die
   §3.6-Klasse „Zusage weiter als Abdeckung" trat auf, wo ein Header **mehr** versprach als die
   Schwester-Datei. Wer einen Exit-Code-/Verhaltens-Kommentar erweitert, hält ihn sofort mit einer
   rot gesehenen Gegenprobe fest.
2. **Ein Wert-/Pin-Bump zieht `make mutate` nach, nicht nur `make gates`.** `gates` enthält `mutate`
   bewusst nicht (es mutiert den Baum); wert-hardcodende Mutationen wandern sonst still aus der
   Deckung. Gehört in die Pre-completion jedes Bumps.
3. **Netz-berührende Schicht hinter ein hermetisches Sub-Kommando** — das Muster (slice-040
   `--compare`) verallgemeinert auf jede Sonderquelle (`--normalize`, `--latest-lts`) und ist der
   Grund, warum ein Netz-Sensor offline gate-bar bleibt.
4. **Der PreToolUse-Guard scannt den ganzen Command-String inkl. Heredoc-Inhalt** — Commit-Messages
   mit Tool-Tokens (`go`, `pip`, …) per Write-Tool in eine Datei, nie als Bash-Heredoc (mehrfach real
   geblockt).

## 5. Folge-Slices / offene Punkte

- **Keine neuen `open/`-Einträge.** Die von den Sensoren **gemeldete** Drift ist bewusst
  out-of-scope (die Welle *erkennt*, sie *löst* nicht auf): der **Baseline-Bump v3.5.1**
  ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) und der **ubuntu-LTS-Bump 24.04→26.04** bleiben separate, bewusste Operationen. Der
  Go-Bump (1.26.5) wurde in dieser Sitzung bereits eingelöst.
- **Gate-Images-Achse** (actionlint/shellcheck/bats) bleibt offen: digest-only gepinnt, ohne
  Versions-String kein Tag-Vergleich (welle §6) — eine spätere Achse nach Tag-Annotation.

## 6. Verifikation (die Belege aus Schritt 1)

- `make gates` → **Exit 0** (nach dem Self-Close-Commit erneut bestätigt).
- `make mutate` → **55 ok / 0 Befunde**; die welle-eigenen Wächter 46 (component-freshness),
  47/48 (go-freshness), 49/50 (cpp-freshness) je rot gesehen; Mutation 18 nach dem Go-Bump generisch
  re-verankert.
- **Nachtlauf verdrahtet** ([`upstream-drift.yml`](../../../../.github/workflows/upstream-drift.yml)):
  `regelwerk-check` · `baseline-freshness` · `freshness-golangci` · `freshness-dcheck` ·
  `freshness-go` · `freshness-cpp`, jeder mit `if: '!cancelled()'`; **nicht** in `make gates`.
- **Carveout-Audit:** [CO-001](../../carveouts/CO-001-bats-shell-lint.md) unverändert gültig
  (permanente shellcheck/bats-Werkzeuggrenze); welle-06 fügte drei `.bats`-Dateien unter denselben
  Glob-Ausschluss hinzu — re-dated. **0 sonstige offene Carveouts.**
