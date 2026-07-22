# welle-04 — Closure-Notiz (Ergebnisse)

**Welle:** [welle-04-durchsetzung-und-emission](welle-04-durchsetzung-und-emission.md). **Meilenstein:** kein formaler (trägt zum künftigen „vollständiger Harness inkl. Durchsetzung"-Zustand bei; die Tabelle kennt bisher M1/M2).
**Abschluss:** 2026-07-22 (beobachtbarer Trigger, kein Kalendertag).

Lerneintrag zur Wellen-Closure (Modul 6, Schritt 3): *was gelernt wurde*, nicht nur *dass sie weg ist*.

---

## 1. Geliefert

Die **`.claude/`-Schicht ist vollständig emittiert** — der Adopter erhält nicht nur Gerüste + Sensoren, sondern die **Durchsetzung** ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren)) und die **Prozess-Anleitung** ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)), als **Tool-als-Quelle** ([`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)):

- [slice-030](slice-030-durchsetzung-skills-emit.md): der `.harness/skills/`-Emit-Pfad geöffnet — Reviewer-/Closure-Skill als Singleton emittiert (bleibt **Fetch**). De-riskender erster Schritt.
- [slice-031](slice-031-durchsetzung-mechanik-emit.md): die Durchsetzungs-**Mechanik** (Gate-Nachweis `record-gates` + `working-tree-hash` + Stop-Hook + `.claude/settings.json` + `.harness/.gitignore`), `gates: record-gates` als letztes Prerequisite ins Ziel-Makefile verdrahtet. Tool-als-Quelle, sprach-agnostisch.
- [slice-032](slice-032-command-guard-emit.md): der **Command-Guard** (`.claude/hooks/pretooluse-command-guard.sh` bash+awk, [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) + awk-Extraktor + `PreToolUse` in `.claude/settings.json`; **BLOCKED-Set je `--lang`** (`blockedSet`, an `gen.SupportedLangs()` gekoppelt). → [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) komplett.
- [slice-033](slice-033-workflow-commands-emit.md): die **Workflow-Commands** (`.claude/commands/{implement-slice,plan-welle,close-welle}.md`), repo-spezifische Stellen als adaptierbare Marker ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)/[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)). → Anleitung komplett.

## 2. Was funktionierte

- **Der Präzedenz-Hebel entsperrte die ganze Welle.** Beim Planen schien Cluster A upstream-blockiert (die Picker-Quelle fehlt im Kurs-Template-Satz). Die Nutzer-Korrektur — der [`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4)-Präzedenzfall (Skelett Picker→Generator via [`ADR-0005`](../../../../docs/plan/adr/0005-ziel-repo-distribution.md)) — führte zu [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) (Picker→Tool-als-Quelle). „Quelle fehlt upstream" war **nicht** das Ende.
- **Der Proposed-first-Review-Zyklus für [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) fing 6 MEDIUM vor dem immutable Accept-Lock** (u. a.: `CLAUDE.md` ist ein Briefing → **autort**, nicht tool-generiert; Split-Kriterium zweiteilig Natur UND Verfügbarkeit).
- **Die getrennt-Kontext-Rollenkette trug 4×.** Jeder Slice: Implementation → unabhängiger Reviewer (frischer Kontext) → unabhängiger Verifier (fährt die Sensoren selbst) → Planner-Closure. Der Verifier bootstrappte je ein **echtes Ziel** und inspizierte das Emittierte real (nicht den Unit-TempDir).
- **`make full-smoke` wuchs mit der Emission mit** und misst jetzt: out-of-the-box `make gates` grün, der geschlossene Gate-Nachweis-Kreis, das Guard-Verhalten (`go build` geblockt / `make test` durch).

## 3. Was anders lief

- **Messen-zuerst korrigierte „je `--lang`" zu sprach-agnostisch.** [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)/Welle-Ziel formulierten „je `--lang` parametriert" pauschal; die Messung zeigte: die **Mechanik** (slice-031) und die **Commands** (slice-033) sind reiner, sprach-agnostischer Prozess/Infrastruktur — **nur** das Guard-BLOCKED-Set (slice-032) ist je Sprache. Kein `--lang`-Zweig gebaut, wo keiner nötig ist.
- **Ein Selbst-Blockade-Bug wurde vor dem Code gefangen** (slice-031): der `record-gates`-Stempel hätte ohne `.harness/.gitignore(state/)` in den `working-tree-hash` gezählt → der Stop-Hook blockte sich selbst. Der emittierte Nachweis musste seine eigene Voraussetzung mit-emittieren.
- **Die settings.json-Grenze wanderte** (slice-031→032): Stop-only → beide Hooks. Test, smoke-Negativprobe und Mutation wurden **umgeschrieben** (nicht danebengestellt) — sonst der Selbstwiderspruch aus slice-030.

## 4. Steering-Loop-Einträge (wellen-übergreifend)

- **Ein emittierter Mechanismus muss seine Voraussetzung mit-emittieren.** `.harness/.gitignore(state/)` ist Korrektheit, nicht Kosmetik. Neuer Sensor: `full-smoke` **misst** den geschlossenen Nachweis-Kreis (git-initialisiert das Ziel dafür).
- **Emittierte Artefakte tragen keine Quell-Repo-Identität.** Zweimal durchgerutscht + vom Review gefangen: der Werkzeugname `ai-harness-init` im emittierten Guard (slice-032 L-2) und interne Sensor-/Slice-Refs in den Commands (slice-033). Merke: generischen Emit-Text gegen Quell-Namen, ADR-/MR-Nummern und tote Refs scrubben — aber nur die **toten**; was die Emission real mitliefert (`make gates`, `record-gates`, d-check), bleibt konkret. Über-Genericisierung = derselbe Fehler wie Unter-.
- **Negativ-Wächter über eine numerische/behaviorale Klasse, nicht über ein Literal-Set.** Der node/jq-Wort-Grep (slice-032) schlug am erklärenden Kommentar fehl → positiv `awk -f` + behavioraler full-smoke. Der Slice-Nr-Leak-Grep (slice-033 L-1) prüfte 4 Literale → auf `slice-[0-9]{2,}` gehoben. Dieselbe Klasse wie „Wächter besteht, weil Fixture zufällig passt".
- **Eine Mutation muss die Datei WIRKLICH ändern** (slice-033): ein `sed` auf einen zeilen-umbrochenen String griff nicht — `make mutate` meldete fail-closed „Mutation hat nicht gegriffen". Der Sensor bewacht auch sich selbst.

## 5. Folge-Slices (benannte `open/`-Kandidaten, Backlog)

- **git-Repo-Vorbedingung der emittierten `make gates`** (slice-031/032-INFO I-1): `record-gates` startet mit `git rev-parse` — ein Bootstrap in ein noch nicht git-initialisiertes Verzeichnis röte `make gates` am `record-gates`-Schritt trotz grüner lint/build/test/docs-check. Trifft realistische Adopter (bestehende git-Repos) nicht, ist aber im Ziel undokumentiert. Kandidat: eine Zeile im emittierten README oder ein optionales Bootstrap-`git init`. **Entscheidung Closure: als Backlog-Folgepunkt benannt, nicht jetzt geschnitten** (cp-Disziplin — keine aktive Welle; green-before-extend).
- **`architecture.md`-Nachzug — jetzt erweitert** (bekannter Backlog-Punkt, welle-04 §6): `architecture.md` nennt den Enforce-Emitter, aber **noch nicht** den Commands-/Anleitung-Emitter (slice-033), und die „je `--lang`"-Prosa am Enforce-Emitter ist gegen den Messbefund (nur Guard je Sprache) zu schärfen. Doku-Reconciliation, eigener Slice.
- **Weitere Sprach-BLOCKED-Sets über `go` hinaus** ([`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nennt sechs) — folgen mit den `gen`-Profilen; der `blockedByLang`-Test hält den Bezug wach.

## 6. Verifikation (Belege, Modul 6 Schritt 1 — real, nicht behauptet)

- **Alle vier Slices in `done/`:** slice-030/031/032/033 (`ls docs/plan/planning/done/`).
- **`make gates` grün**, Stempel `.harness/state/gates-passed.diffsha` == `working-tree-hash.sh` (STAMP-MATCH).
- **`make full-smoke` grün:** frisch gebootstrapptes Ziel fährt `make gates` out-of-the-box grün (Ziel-d-check 12 Dateien/0 Befunde), Gate-Nachweis-Kreis geschlossen, Command-Guard blockt `go build` / lässt `make test` durch (bash+awk, [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)/[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **`make mutate` grün:** 37/37, 0 Befunde (die welle-04-Wächter 31–37 rot gesehen).
- **Carveout-Audit ([Modul 7](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-07-carveouts.md)):** ein offener Carveout, dokumentiert — [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md) (shell-lint deckt die `.bats`-Dateien nicht ab; technische Grenze, trigger-gebunden, **von welle-04 nicht berührt**). Kein stilles rotes Gate.
