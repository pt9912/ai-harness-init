# Slice slice-033: Workflow-Commands emittieren (`.claude/commands/`)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-04-durchsetzung-und-emission](../welle-04-durchsetzung-und-emission.md).

**Bezug:** [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md).

**Autor:** Claude (Pair-Session). **Datum:** 2026-07-22.

---

## 1. Ziel

Der Emit legt die **Agenten-Workflow-Commands** ins Zielrepo
(`.claude/commands/{implement-slice,plan-welle,close-welle}.md`) — die Slash-Command-*Anleitung*,
mit der ein Agent die Harness-Rollen fährt (Slice implementieren, Welle planen/schließen), geerdet
in den Regelwerk-Modulen. Als **Tool-als-Quelle** ([`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md), aus dem erprobten Dogfood + Kurs-Prozess-Modulen).
Damit erhält der Adopter den **Prozess**, nicht nur die Gerüste ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) — die repo-spezifischen
Stellen (Adaptions-/„MR-Block", Sprach-Toolchain) als **adaptierbare Marker** ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) zweiklassig),
nicht 1:1 hart. Letzter welle-04-Slice — danach ist die Emission (Durchsetzung + Anleitung) komplett.

## 2. Definition of Done

<!--
Was muss erfüllt sein, damit der Slice in done/ wandert?
Liste mit jeweils prüfbarem Kriterium.
-->

- [x] [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) Happy Path: der Emit legt `.claude/commands/{implement-slice,plan-welle,close-welle}.md` ins Ziel (Tool-als-Quelle, go:embed). Test belegt: emittiert.
- [x] [`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)/[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) adaptierbar: die repo-spezifische „Repo-lokale Adaptionen"-Sektion trägt einen **adaptierbaren Marker** (der Adopter passt sie an sein Repo an), nicht 1:1 ai-harness-init-hart. Test belegt: Marker vorhanden.
- [x] [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) kein-aus-dem-Nichts + keine toten Referenzen: die emittierte Fassung ist real erprobt (Dogfood) + kurs-geerdet; ai-harness-init-**interne** Referenzen, die im Ziel falsch wären (`make mutate`/`make smoke`/`test/mutations/`, konkrete Slice-Nummern, hart kodierte Sprach-Toolchain), sind genericisiert. Test belegt: kein `test/mutations`/`make mutate`/`ai-harness-init`-Leak.
- [x] `make full-smoke`/`make smoke` belegt die Commands real im Ziel (nicht nur behauptet).
- [x] `make gates` grün; `make mutate` deckt die neuen Wächter (rot gesehen).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

<!--
Welche Änderungen sind geplant? Datei- oder Komponenten-Ebene reicht.
Der Implementation-Agent erweitert diese Liste in seinem ersten Lauf.
-->

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/commands/{implement-slice,plan-welle,close-welle}.md` | neu | generische Command-Fassungen (aus dem Dogfood): „Repo-lokale Adaptionen"-Sektion als adaptierbarer Marker, ai-harness-init-interne Refs (make mutate/smoke, Slice-Nrn, Toolchain) genericisiert |
| `internal/emit/commands.go` | neu | `//go:embed all:templates/commands` + `Commands(targetDir, force)` + `CommandPaths()` — Muster `Enforce`, aber eigene Funktion ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) = Anleitung ≠ [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) = Durchsetzung); sprach-agnostisch (kein lang-Param) |
| `cmd/ai-harness-init/main.go` | update | Phase-3-Pre-Flight um `CommandPaths()`; Phase-4 `emit.Commands(...)` |
| `internal/emit/commands_test.go` | neu | 3 Commands emittiert; Adaptions-Marker vorhanden; kein interner Leak (test/mutations/make mutate/ai-harness-init/Slice-Nrn) |
| `harness/tools/smoke.sh` | update | Command-Präsenz im Ziel (positiver Vertreter) |
| `test/mutations/` | neu | rot färbender Wächter je neuer Zusage (§3.6) |

## 4. Trigger

<!--
Wann beginnt dieser Slice? (`next` → `in-progress`: Implementer beginnt.)
Beispiele: "Wenn Welle X done." / "Wenn Carveout CO-NN aufgelöst."

Auch die zwei Rückführungen vorab benennen — unter welcher Bedingung
geht dieser Slice zurück?
- `in-progress` → `next`: zu groß, zurück zur Zerlegung.
- `in-progress` → `open`: blockiert (Carveout? siehe Modul 7).
(kanonische Definition: [`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.0/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine))
-->

slice-032 in `done/` (die Durchsetzungsschicht ist emittiert). Letzter welle-04-Slice.

Rückführungen: `in-progress → next`, falls die Genericisierung der 3 Commands doch getrennte Schnitte trägt (z. B. ein Command braucht mehr Umbau als die anderen). `in-progress → open`, falls blockiert (Carveout, Modul 7).

## 5. Closure-Trigger

DoD vollständig + Review konform + Verifikation bestätigt + Closure-Notiz → nach `done/`. Danach ist die **Emission komplett** (Durchsetzung [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) + Anleitung [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)) → welle-04 ist closure-reif (`/close-welle welle-04`).

## 6. Risiken und offene Punkte

- **Wieviel genericisieren?** Vieles in den Commands referenziert Mechanik, die slice-030/031/032 **emittiert** haben (`make gates`, `record-gates`, d-check, `.harness/skills/reviewer.md`, `harness/conventions.md`, cp-aus-vendored) — im Ziel also **korrekt**. Nur die ai-harness-init-**internen** Refs sind zu fixen: `make mutate`/`make smoke`/`test/mutations/` (nicht emittiert), konkrete Slice-Nummern, hart kodierte Sprach-Toolchain. Grenze: den erprobten Prozess NICHT verwässern ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): kein aus-dem-Nichts) — nur tote/falsche Refs adaptierbar machen.
- **Adaptierbarer Marker vs. konkrete Hilfe.** [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) will die repo-spezifischen Stellen „nicht 1:1 hart". Ein bloßer Platzhalter verlöre die nützliche Konkretheit. Kompromiss: die „Repo-lokale Adaptionen"-Sektion trägt einen **ANPASSEN**-Marker + verweist auf die real emittierte Durchsetzung (Guard/Stop-Hook/d-check) als typische Default-Adaptionen — konkret, aber als „dein Repo" gerahmt.
- **CLAUDE.md-Referenz.** Die Commands sagen „CLAUDE.md lesen"; `CLAUDE.md` ist **autort** (nicht emittiert, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md)). Im Ziel existiert es erst, wenn der Adopter es schreibt — die Command-Anleitung bleibt gültig (sie sagt, es zu lesen), kein toter Pfad-Verweis in Inline-Code (sonst d-check-`codepath-missing` im Ziel — aber `.claude/**` wird vom Ziel-d-check nicht gescannt, also gate-neutral; per Smoke prüfen).
- **Sprach-Agnostik (Messbefund).** Die Commands sind der harness-Prozess — kein `--lang`-Zweig (wie slice-031s Mechanik). [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)s „je `--lang` parametriert" ist trivial erfüllt (Tool-als-Quelle + adaptierbare Marker; das einzige sprach-nahe Detail — die Guard-Toolchain — steht im adaptierbaren Marker, nicht hart). Kein `emit.Commands`-lang-Param.
- **Zielmengen-Kopplung.** cmd-Pre-Flight (Phase 3) + Emit (Phase 4) müssen dieselben 3 Command-Pfade sehen (Muster slice-028/031: sonst falsch-grün).

## 7. Closure-Notiz (nach `done/`)

**Abgeschlossen:** 2026-07-22. Review [KONFORM](../../../reviews/2026-07-22-slice-033-review.md)
(0 HIGH/MEDIUM, 1 LOW behoben, 1 INFO, 9 Negativbefunde), Verifikation bestätigt die DoD (getrennter
Kontext; `make gates` + `make mutate` **37/37** + `make full-smoke` selbst gefahren, dazu ein
**selbst gebootstrapptes Ziel** inspiziert — 3 Commands, ANPASSEN-Marker in jedem, kein Leak, der
harness-Prozess erhalten [Schritt-Parität 23/10/7, Rollen/Modul-Verweise/„frischer Kontext"], keine
Über-Genericisierung [`make gates`/`record-gates` konkret gelassen], CLAUDE.md im Ziel abwesend).

**Ergebnis:** Die Workflow-Commands (`.claude/commands/{implement-slice,plan-welle,close-welle}.md`)
sind als **Tool-als-Quelle** emittiert ([`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md), eigene Funktion `emit.Commands` — Anleitung ≠
Durchsetzung). **Damit ist die Emission komplett**: Durchsetzung ([`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), slice-030–032) +
Anleitung ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), dieser Slice) → **welle-04 ist closure-reif** (`/close-welle welle-04`).

**Steering-Loop-Einträge:**

- **Die vorherigen Emit-Slices machten die Genericisierung chirurgisch.** Vieles, was die Commands als
  „Repo-lokale Adaption" nennen (`make gates`, `record-gates`, Doc-Gate, Command-Guard,
  `.harness/skills/reviewer.md`, vendored Templates), hat slice-030–032 **real ins Ziel emittiert** —
  im gebootstrappten Repo also **korrekt**, nicht zu verwässern. Nur die ai-harness-init-**internen**
  Refs (Sensoren `make mutate`/`make smoke`/`test/mutations/`, die die Emission nicht mitliefert;
  konkrete Dogfood-Slice-Nummern; die hart kodierte Sprach-Toolchain) waren tot/falsch und wurden
  adaptierbar gemacht. Merke: „genericisieren" heißt nicht „alles Konkrete raus" — es heißt „tote
  Refs raus, wahre Refs stehen lassen". Über-Genericisierung ist derselbe Fehler wie Unter-.
- **Eine Mutation muss die Datei WIRKLICH ändern — der Sensor fing es.** Fall `37`s erster `sed`-Patch
  zielte auf einen im Template über zwei Zeilen umbrochenen String → er griff nicht, und `make mutate`
  meldete `BEFUND … Mutation hat nicht gegriffen … Patch veraltet?` (fail-closed-Bedingung 2). Ein
  wirkungsloser Patch hätte sonst wie „Wächter intakt" ausgesehen. Neu gezielt auf eine
  Einzeilenstelle. (Bonus: shellcheck `SC2016` fing danach Backticks im `sed`-Replacement — die
  Mutations-Skripte fahren durch shell-lint.)
- **Ein Literal-Set als Negativ-Wächter altert (Review-L-1).** `TestCommands_NoInternalLeak` prüfte
  Dogfood-Slice-Nummern erst als 4 Literale (`slice-027/030/031/032`) — eine künftig durchsickernde
  andere Nummer bliebe grün. Auf die **numerische Klasse** `slice-[0-9]{2,}` gehoben. Dieselbe Klasse
  wie „Wächter besteht, weil Fixture zufällig passt": die Frage muss die Eigenschaft treffen (jede
  konkrete Nummer), nicht eine Aufzählung bekannter Fälle.

**Folge-Slices / benannte `open/`-Kandidaten:** keine neuen aus slice-033. Für den **welle-04-Closure**
(nächster Schritt) offen: (a) git-Repo-Vorbedingung der emittierten `make gates` (INFO I-1, slice-031);
(b) welle-04 §4-Tabelle-Stale (CLAUDE.md noch als slice-031-Scope gelistet, [`ADR-0006`](../../../../docs/plan/adr/0006-durchsetzung-commands-tool-als-quelle.md) → autort).

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (`internal/emit/`, `cmd/`, `harness/tools/`, `test/` — siehe Kurs
Modul 5 §Worked Mini-Example): adoptierte Emit-Mechanik (auf slice-031/032 aufsetzend), tool-eigene
Quelle (die Commands sind der erprobte Dogfood-Prozess), niedriges Evidenz-/Diskrepanz-Risiko.
