# Verifikation: slice-targets-modul-im-emittierten-doc-gate

**Rolle:** Verifier (Modul 11) · **Datum:** 2026-10-07 · **Gegenstand:** Commits `2fec4763`,
`ccf163b9`, `2b93feca`, `9a36e370`, `63645fae`, `86d20906` gegen Slice-Plan (Stand `674126c5`),
ADR-0080 Festlegung 5 / Fitness 3, MR-054, LH-QA-01. Eingang: Review `2026-10-07-targets-review.md`,
Architect-Verdikt `2026-10-07-targets-architect-verdikt.md`.

**Summary:** Liefer-DoD 1–3 bestätigt, DoD 4 bestätigt (Lauf unten); ein Befund zur Zusage im
Plan-Text (V-1), ein Plan-vs-Code-Punkt (V-2). Rot-Belege an der realen Quelle (Vorlage
`internal/emit/templates/d-check.yml`) nachgetragen; Vorlage danach per `git checkout`
zurückgesetzt, Träger per `make host-bin` neu gebaut.

## Verdikte je DoD-Punkt

- **DoD 1 (Werkzeug-Teil, Link, `targets`-Block, MR-054) — bestätigt.**
  - Frisch emittiertes `--lang go`-Ziel (Träger `make host-bin` vom HEAD): `.d-check.yml` byte-gleich
    der Vorlage (`cmp` → gleich); `harness/mk/ai-harness-init.md` liegt, Kopf nennt Neu-Schreiben je
    Lauf; `harness/README.md:86` verlinkt `mk/ai-harness-init.md`. `makefiles: [Makefile,
    "harness/mk/*.mk", "*.mk"]`, kein `exempt-targets`; Kopfkommentar „siebte Position“ nennt den Block.
  - `add-lang` schreibt den Teil ebenfalls (`cmd/ai-harness-init/main.go:371`, `:589`).
  - MR-054 **Erprobung:** `grep -n '^modules:' .d-check.yml` → `29: … planning, targets, structure`.
    **Grüner Start:** `make docs-check` im Ziel → `d-check: 21 Datei(en) geprüft, 0 Befund(e)`.
    **Rotes Gegenbeispiel:** je Richtung, s. DoD 2.
- **DoD 2 (full-smoke, Gegenbeispiele, Fitness 3, Abdeckungs-Sicht) — bestätigt, mit V-1.**
  - `make full-smoke` → `rc=0`, 134 s; Stufe `targets_im_ziel` meldet grünen Start, beide
    Gegenbeispiele samt Gegenprobe und die Grenze (`mk/sub.mk` 0 Befunde, an der Wurzel rot).
  - Ziel direkt: `eigen-probe` in `repo.mk` → `repo.mk:23 eigen-probe gate-undocumented`.
  - **Rot-Beleg Fitness 3 an der Vorlage** (Stufen-Extrakt `targets_im_ziel` + Helfer unverändert
    aus `full-smoke.sh`, Scratchpad, je Mutation `make host-bin` und frisches Ziel):
    - `"*.mk"` → `d-check.mk` (ADR-Form „`repo.mk` aus `makefiles:` streichen“): grüner Start bleibt,
      Stufe rot mit `targets-Gegenbeispiel (undocumented): … meldet nicht [eigen-probe … gate-undocumented]
      (Exit 0 …)`, Ausgabe `0 Befund(e)` — die behauptete Ursache.
    - `"*.mk"` ersatzlos gestrichen (Plan-Form): s. V-1.
  - E2E-Abdeckungs-Sicht `docs/user/e2e-abdeckung.md:42` trägt die Stufe mit Grenze („NICHT gemessen:
    … cpp und --arch …“).
- **DoD 3 (Grenzen am Ort der Emission, mit Tag) — bestätigt.**
  - Vorlagen-Kopf: Disjunktheit ungeprüft, Wurzel-`.mk` mitgelesen, Unterordner-`.mk` nicht,
    rekursiver Glob verworfen, `v6.16.0`/`v0.82.0`. Kopf des Werkzeug-Teils: Hand-Änderung geht
    verloren, Kurs `v6.16.0`, d-check `v0.82.0`.
  - **Rot-Beleg Unterordner-Grenzprobe an der Vorlage:** `"*.mk"` → `"**/*.mk"`. Volle Stufe: rot an
    der Selbstprüfung der Fitness-3-Gegenprobe (`die Schwaechung nimmt den Glob "*.mk" nicht aus
    makefiles:`), erreicht die Grenzprobe nicht. Stufe ohne Abschnitt (b) (nur für diesen Beleg):
    `targets-Grenze: eine eingebundene mk/sub.mk meldet etwas (Exit 2) — die benannte Grenze …
    stimmt nicht mehr`, Ursache `mk/sub.mk:1 sub-probe gate-undocumented` — die behauptete.
  - Nebenbefund: `"mk/*.mk"` ohne Treffer → `docs-check` Exit 2 schon am grünen Start; ein Glob
    ohne Treffer endet am Pin also wie eine fehlende Einzeldatei. `"*.mk"` trifft immer `d-check.mk`.
- **DoD 4 (`make gates`) — bestätigt:** Lauf am Ende dieser Verifikation, Exit 0 (Commit-Message
  nennt die Dauer).
- DoD 5–9 (Review, Closure, Register, Risiken, Paarungen): Planner-Sache, nicht verifiziert; Review
  liegt vor.

## Befunde

- **V-1 — Zusage im Plan breiter als ihr Messbares (Planner).** Plan §2: „`"*.mk"` aus `makefiles:`
  gestrichen ⇒ bleibt grün“. Gemessen an der Vorlage: ersatzlos gestrichen färbt das frische Ziel
  rot — `11 Befund(e)`, `gate-phantom` für die `d-check.mk`-Targets (`harness/README.md:63 docs-check`,
  `harness/mk/ai-harness-init.md:46 doc-complete` …); `eigen-probe` erscheint nicht. „Grün“ gilt nur
  in der Form, die die Stufe fährt und die ADR-0080 Fitness 3 nennt: `repo.mk` (allein) aus der
  Lese-Menge nehmen, `d-check.mk` bleibt. Der Kommentar der Stufe (`full-smoke.sh:3615f`, „ohne den
  Glob … bleibt dasselbe Target gruen“) teilt die Verkürzung; der Code ersetzt den Glob durch
  `d-check.mk`. Kein Verhaltensfehler, die Plan-Zeile ist zu präzisieren.
- **V-2 — Gebautes ohne Plan (Planner).** `86d20906` ändert den Kopfkommentar von
  `internal/emit/templates/enforce/repo.mk` (jedes Target braucht eine Zeile; Unterordner-Grenze).
  Plan §1 schließt „`repo.mk` selbst (… Startinhalt …)“ aus, §3 nennt die Datei nicht. Anlass sind
  Review F-1/F-3; Verhalten unverändert (nur Kommentar, skip-if-present). Plan-Nachzug oder
  Abgrenzung lockern — Entscheidung beim Planner.

## Negativbefunde

- Plan → Code: jede Zeile aus §3 hat ihren Diff (Vorlage, `werkzeugindex.go`, Handbuch-Klassentabelle
  `benutzerhandbuch.md:356` und Absatz `:522`, `full-smoke.sh`, Fälle 295/514, `emit_test.go`);
  §3 „kein Eintrag in `enforce.go`“ hält.
- Code → Plan: außer V-2 nur Begleitendes (Mutationsfälle 530/531, Lint-Zerlegung, `add-lang`-Aufruf,
  Erkenner-Angleich `63645fae`) — trägt bzw. bewacht Plan-Punkte.
- Nicht nachgefahren (Review lief sie): `make mutate` für 530/531/295, Disjunktheits-Probe.
