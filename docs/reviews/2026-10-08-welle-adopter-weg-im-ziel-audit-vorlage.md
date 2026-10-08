# Welle-Closure welle-adopter-weg-im-ziel — Audit-Vorlage und Steering-Loop-Übergabe (Schritte 2, 3a, 3b)

- **Rolle:** Planner · **an:** Architect (Abschnitte A, B, C) · **Bezug:**
  [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), Baseline-Regelwerk
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur und `modul-08-agentenrollen.md` §Rollen-Sequenz für
  eine Welle (`v6.17.0`)
- **Gemessen auf:** `6d333aad`; Fenster = seit der letzten Welle-Closure `83fe258e`
  (Self-Close `welle-emittiertes-doc-gate`)
- **Schritt 1:** erledigt — Verifier-Beleg `2026-10-08-welle-adopter-weg-im-ziel-trigger.md`.
- **Die Closure hält hier an.** Schritte 3c, 4, 5, 6 laufen nach dem Verdikt zu A–C.

## Schritt 2 — vom Planner erledigt

- **Carveouts:** `CO-001` verlängert mit Folge-Slice `slice-113` (in `open/`), `CO-002` permanent —
  beide unverändert seit dem letzten Audit; keine weiteren (`ls docs/plan/carveouts/`).
- **Bootstrap-aware Gates:** keines (`grep -n 'bootstrap-aware' Makefile *.mk` → leer).

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig (Architect)

Ereignisse im Fenster (`git diff --name-status 83fe258e HEAD -- docs/plan/adr harness/conventions
AGENTS.md Makefile d-check.mk internal/emit/emit.go .d-check.yml`):

| Ereignis im Fenster | Frage |
|---|---|
| [ADR-0086](../plan/adr/0086-erzeugtes-repo-bekommt-keine-eigentums-aussage-ueber-seinen-anweisungssatz.md) angenommen | berührt sie einen Trigger von [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (offene Festlegung zur Adopter-Seite)? |
| kein Pin-, Baseline- oder Release-Sprung; kein neuer oder geänderter `MR`; `AGENTS.md` unverändert | — vermutlich kein weiterer Trigger gefeuert |

**Hard Rules:** einziger Auflösungs-Trigger in `AGENTS.md` lautet *permanent*
(`grep -n 'Auflösungs-Trigger' AGENTS.md`); Architect bestätigt.

## B — Lese-Schritt 3a und Verkörperungs-Frage 3b (Architect)

`make register-ausgang` → `235 Eintraege, 66 ueber der Schwelle, 0 Befund(e)`. Im Fenster angelegte
Belege (`git diff --name-status --diff-filter=A 83fe258e HEAD -- docs/plan/planning/observations`):
sieben, kein Eintrag überschreitet damit erstmals 3× — **kein Eintrag über der Schwelle ohne Ausgang**.

**3b — Wiederauftreten nach Verkörperung bzw. bei geplantem Ausgang** (verlangt je Zeile: *Prosa
trägt — Sensor X* · *kein Sensor möglich, weil …* · *Zielort ist bereits ein Sensor* · *geplanter
Träger fängt es*):

| Eintrag | Belege | Stand | neuer Beleg |
|---|---|---|---|
| `plan-abweichung-landet-im-commit-bericht-statt-im-plan` | 5 | verkörpert (Baseline `modul-09` §Rücksprungkanten-Regeln, seit `525e36b7`) | `slice-zeilenenden-meldungstest-bindet-das-verzeichnis` |
| `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` | 6 | Prosa verkörpert (`AGENTS.md` §3.6), Sensor geplant `slice-119` | `slice-mv-kanten-nach-done-sind-bewacht` |
| `neuer-waechter-ohne-mutations-fall` | 17 | geplant `slice-119` | `slice-archivierung-erkennt-benannte-slices` |
| `zusage-nennt-zwei-kanten-der-sensor-deckt-eine` | 6 | geplant | `slice-aktivierung-reist-nicht-mit-dem-klon` |

## C — Reste aus der Closure welle-emittiertes-doc-gate (Architect)

1. **Toter Träger in [`MR-048`](../../harness/conventions.md#mr-048):** §Geltungsbereich nennt
   `slice-146` als Träger der zwei Regeln aus `regelwerk/modul-14-docker-harness.md`
   §Multi-Stage-Build; der Slice ist entfallen (liegt in `done/` mit `Gegenstand: entfallen`).
   Verlangt: Marke oder Folge-Eintrag nach
   [`MR-032`](../../harness/conventions.md#mr-032).
2. **Ausgang zweier Register-Einträge:** `BEO-ALL/folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht`
   und `BEO-ALL/baseline-sprungweite-treibt-kosten` stehen auf *gestrichen, als Ablehnung*; die
   Ziel-Form deckt *gestrichen* nur für eine Beobachtung, die nicht mehr auftreten kann — beide
   können. Verlangt: Ausgang aus der geschlossenen Menge (*verkörpert* · *geplant* mit Kennung ·
   *gestrichen* mit Wegfall-Grund) oder eine benannte Form für die Ablehnung; `state.md` schreibt
   danach der Planner.
3. **Erledigt (Planner, kein Verdikt nötig):** `slice-plan-umfang-bleibt-beim-gegenstand` §6 zeigt
   jetzt auf das bestehende `BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben` statt auf das nie
   angelegte `…/eine-stellen-messung-traegt-keine-folgerung-ueber-eine-eigenschaft`; Paarung (c)
   erste Hälfte damit grün.

## Paarungen der Welle-Slices (Planner, vorab)

(a) kein Eintrag der fünf §7 trägt `liegt in` als Feld. (b) jeder in §6/§7 genannte Slice existiert
im Lifecycle (`ls docs/plan/planning/*/<kennung>*.md`). (c) erste Hälfte grün; zweite Hälfte: 2
Verzeichnisse ohne Beleg, `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
`einstiegs-datei-weicht-von-der-pflichtgliederung-ab` — nicht als getragen behauptet.

## D — Archivierung, Schritt 4

`.harness/state/bin/ai-harness-init archive-welle --vorschau welle-adopter-weg-im-ziel` → rc 3
(127 s): `[unsauber]` (Messung bei offener Edit), `[ergebnisnotiz]` und `[kein-plan]` lösen Schritt
3c und 5; **`[untergrenze]`** (198 wellenlose Slices flach in `done/`, kein `done/*/archiv.zip`) und
**`[haenger]`** bleiben. Wie bei der Vorgänger-Welle (Auftraggeber-Freigabe vom 2026-10-08) schließt
die Welle ohne Schritt 4, als Feststellung in der Ergebnisnotiz; kein Verdikt nötig.
