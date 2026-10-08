# Welle-Closure welle-emittiertes-doc-gate — Audit-Vorlage und Steering-Loop-Übergabe (Schritte 2, 3a, 3b)

- **Rolle:** Planner · **an:** Architect (Abschnitte A, B) und Auftraggeber (Abschnitte C, D) ·
  **Bezug:** [`MR-054`](../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel),
  Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur und `modul-08-agentenrollen.md`
  §Rollen-Sequenz für eine Welle (`v6.17.0`)
- **Gemessen auf:** `8c23b2d8`; Fenster = seit der letzten Welle-Closure `25b49a93`
  (Ergebnisnotiz `welle-v021-faehigkeit`, 2026-09-23)
- **Schritt 1:** erledigt — Verifier-Beleg `2026-10-08-welle-emittiertes-doc-gate-trigger.md`.
- **Die Closure hält hier an.** Schritte 3c, 4, 5, 6 laufen nach den Verdikten aus A und B.

## Schritt 2 — vom Planner erledigt

- **Carveouts:** `CO-001` aktiv, Auflösung fällig, Ausgang **verlängert mit Folge-Slice**
  `slice-113` (liegt in `open/`) — unverändert seit dem letzten Audit. `CO-002` **permanent**,
  unverändert. Keine weiteren (`ls docs/plan/carveouts/`).
- **Bootstrap-aware Gates:** keines (`grep -n 'bootstrap-aware' Makefile *.mk` → leer).

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig (Architect)

Ereignisse im Fenster und die Trigger, die sie berühren könnten. Der Planner urteilt nicht, ob sie
gefeuert haben; Verdikt je Zeile: bestätigt · Folge-ADR (`supersedes`) · nicht gefeuert.

| Ereignis im Fenster | ADR-Trigger |
|---|---|
| Sprünge `v6.13.0 → v6.16.0 → v6.17.0` | [ADR-0072](../plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md) und [ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) „der nächste Sprung steht an"; Freshness-Audit `v6.17.0` gegen [ADR-0033](../plan/adr/0033-wellen-archivierung-als-unterkommando.md) T1, [ADR-0077](../plan/adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md) T2, [ADR-0081](../plan/adr/0081-altbestand-grenze-aus-der-commit-abstammung.md) T1 |
| Releases `v0.3.0`–`v0.5.0` | [ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) T5 (Release vor dem Werkzeug-Teil des Gate-Index im Ziel) |
| d-check-Pins `v0.79.0 → v0.84.0` ([`MR-073`](../../harness/conventions.md#mr-073--d-check-pin-v0790-links-lookahead-und-referenz-definitionen-standardmäßig-aktiv) … [`MR-084`](../../harness/conventions.md#mr-084--d-check-pin-v0840-multi-arch-index-prüfverhalten-unverändert)) | [ADR-0082](../plan/adr/0082-ziel-fassung-regiert-den-sprung-v6170.md) T4 (Wirkbedingungen des `authority`-Schalters) |
| [ADR-0083](../plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md), [ADR-0084](../plan/adr/0084-reviewer-skills-im-ziel-skip-if-present.md), [ADR-0085](../plan/adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md) im Fenster angenommen | je ein 3×-Register-Trigger — kein Register-Verzeichnis dieses Gegenstands (`ls docs/plan/planning/observations/BEO-ALL/ \| grep -iE 'handoff\|skill-vorlage\|architect-zug'` → leer); vermutlich nicht gefeuert |

**Hard Rules:** `AGENTS.md` führt einen Auflösungs-Trigger, und er lautet *permanent*
(`grep -n 'Auflösungs-Trigger' AGENTS.md` → Zeile 110). Kein fälliger; Architect bestätigt.

## B — Lese-Schritt 3a und Verkörperungs-Frage 3b (Architect)

`make register-ausgang` → 0: jeder Eintrag über der Schwelle trägt einen Ausgang.

**Beleg ohne Auftreten entfernt (Planner):** `BEO-ALL/ausgang-nennt-traeger-der-nicht-traegt`,
Beleg `slice-register-ueber-der-schwelle-bekommt-seinen-waechter` — er hält die Grenze des neuen
Sensors fest, kein Auftreten der Klasse; nach `modul-06-roadmap.md` *„benannt, nicht gezählt"*
entfernt und in `state.md` benannt. Zähler 4 → 3, Ausgang *geplant* bleibt.

**Übertritt über 3× im Fenster** (Ausgang steht): `aenderung-nach-der-letzten-review-runde-bleibt-ungesehen`,
`amend-committet-fremde-index-eintraege-mit`, `baseline-sprungweite-treibt-kosten`,
`bedingung-ohne-traeger-im-lauf-den-sie-bindet`, `beleg-faehrt-den-behaupteten-pfad-nicht`,
`ci-rennt-gegen-die-publikation-des-gepinnten-releases`, `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`,
`geplanter-slice-wird-nie-gearbeitet`, `span-feld-bedeutung-wechselt-ohne-fassungs-angabe`,
`tag-tragende-adresse-ueberlebt-den-baseline-tausch-nicht`, `vollstaendigkeits-zusage-misst-falsche-ebene`,
`zusicherung-ueber-der-leeren-menge-wahr`, und die unten unter 3b genannten.

**3b — Wiederauftreten nach der Verkörperung** (Regelwerk: beim vierten Erreichen gilt die
Prosa-Form als ausgeschöpft; der Eintrag benennt einen mechanischen Sensor oder begründet, warum
keiner möglich ist). Kandidaten = Stand *verkörpert*, mit Belegen, die **nach** dem Commit der
Verkörperung angelegt wurden (Spalte „danach"; `git log --diff-filter=A` je Beleg gegen das Datum
von `git log -S'verkörpert' -- state.md`):

| Eintrag | Belege | danach | im Fenster |
|---|---|---|---|
| `kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle` | 20 | 11 | 4 |
| `neuer-waechter-ohne-mutations-fall` | 16 | 10 | 4 |
| `emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` | 11 | 7 | 9 |
| `abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` | 9 | 4 | 3 |
| `zahl-ohne-kommando-trifft-ihren-gegenstand-nicht` | 17 | 4 | 1 |
| `regel-rand-ohne-benannte-luecke` | 6 | 3 | 6 |
| `waechter-misst-die-fixture-statt-der-realen-quelle` | 6 | 3 | 5 |
| `verweis-nachzug-ersetzt-eine-historisch-richtige-adresse` | 6 | 2 | 1 |
| `zusage-im-doc-kommentar-ohne-zahn-fuer-eine-haelfte-der-regel` | 5 | 2 | 5 |
| `zusage-nennt-zwei-kanten-der-sensor-deckt-eine` | 5 | 2 | 1 |
| `mutations-fall-wird-von-berechtigter-aenderung-entwaffnet` | 6 | 1 | 1 |
| `prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle` | 4 | 1 | 4 |
| `uebergabe-an-andere-rolle-ohne-traeger-artefakt` | 7 | 1 | 1 |
| `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` | 5 | 1 | 5 |
| `zusage-ohne-herstellbares-gegenbeispiel` | 4 | 1 | 1 |

Die Spalte „danach" hängt an einer Datums-Heuristik, nicht an einer Zähl-Regel; ob ein Eintrag
schon einen Sensor als Zielort hat (etwa `mutations-fall-wird-…` mit
[`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)),
liest der Architect am Zielort. **Verlangt je Zeile:** *Prosa trägt — Sensor X* · *kein Sensor
möglich, weil …* · *Zielort ist bereits ein Sensor*. Ein neuer Eintrag mit Zielort `liegt in` und
Anker `seit welle-emittiertes-doc-gate` entsteht nur, wo das Verdikt eine Regel setzt.

## C — Bestands-Lese-Schritt (Auftraggeber)

Bestand: 72 in `open/`, 18 in `next/` (`ls docs/plan/planning/{open,next} | wc -l`); 14 der 18 sind
in der Vorschau der Roadmap einer Welle zugeordnet und bleiben außen vor. **Vorschläge, nichts ist
stillgelegt.** Je Gruppe: *konsolidieren* (Sammel-Slice übernimmt, `open|next → done`).

1. **Festlegungen ziehen in die Spezifikation** (9): `slice-festlegungen-{doku-gate,e2e-werkzeuge,history-waechter,lifecycle-werkzeuge,release-werkzeuge,telemetrie-werkzeuge,waechter-und-hooks}-…`, `slice-hook-festlegungen-ziehen-in-die-spezifikation`, `slice-079`.
2. **Mutations-Fälle und Zähne** (6): `slice-069`, `slice-119`, `slice-pin-kopplung-bekommt-ihren-mutations-fall`, `slice-sync-waechter-tragen-mutations-faelle`, `slice-der-mutations-lauf-ist-begrenzbar`, `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`.
3. **ADR-Bestätigungsrunden** (3): `slice-152`, `slice-171`, `slice-199`.
4. **`CO-001`** (2): `slice-113`, `slice-141`.
5. **Review-Report und Reviewer-Skill** (5): `slice-213`, `slice-214`, `slice-227`, `slice-reviewer-skill-zieht-die-findings-form-nach`, `slice-die-vorgangs-grenze-erreicht-den-reviewer-skill`.
6. **Prüfbereich des Dogfood-Doku-Gates** (6): `slice-116`, `slice-142`, `slice-143`, `slice-202`, `slice-208`, `slice-212`.
7. **Form des Adaptions-Blocks** (3): `slice-075`, `slice-168`, `slice-189`.
8. **Harness-Einstieg** (2): `slice-114`, `slice-218`.
9. **Werkzeug-Aussagen und Pins** (4): `slice-162`, `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`, `slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse`, `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`.
10. **Risiko- und Register-Ausgänge** (2): `slice-ausgang-auf-einen-folge-slice-prueft-dessen-dod`, `slice-risiko-ausgang-hat-einen-sensor`.
11. **Hook- und Lauf-Beobachtung** (4): `slice-074`, `slice-077`, `slice-078`, `slice-feldabdeckung-existenz-sensor`.
12. **Form von Prosa-Zusagen** (7): `slice-102`, `slice-209`, `slice-plan-umfang-bleibt-beim-gegenstand`, `slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle`, `slice-zaehler-label-nennt-seine-einheit`, `slice-zitat-pruefung-liest-statt-greppt`, `slice-praesens-aussage-in-einzufrierendem-artefakt-bekommt-eine-form`.

**Zu prüfen auf *entfallen*** (Gegenstand womöglich durch den Sprung `v6.17.0` oder geschlossene
Slices erledigt; ungelesen, kein Urteil): `slice-offene-plaene-gegen-den-neuen-stand`,
`slice-baseline-wird-je-release-adoptiert`, `slice-112`, `slice-101`, `slice-146`.
**Rest** (bestätigt vorgeschlagen, ohne Gruppe): die übrigen Dateien in `open/`.

## D — Archivierung, Schritt 4 (Auftraggeber)

`.harness/state/bin/ai-harness-init archive-welle --vorschau welle-emittiertes-doc-gate` → rc 3,
vier Sperren: `[ergebnisnotiz]` und `[kein-plan]` lösen Schritt 3c und 5; **`[untergrenze]`**
(184 wellenlose Slices flach in `done/`, kein `done/*/archiv.zip`) und **`[haenger]`** (Review-Reports,
auf die noch verwiesen wird) bleiben. Die Untergrenze entsteht erst mit dem Altbestand-Lauf
`archive-welle altbestand`
([ADR-0041](../plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md),
[ADR-0081](../plan/adr/0081-altbestand-grenze-aus-der-commit-abstammung.md)) — ein eigener Vorgang.
Ohne ihn schließt die Welle ohne Schritt 4, als Feststellung in der Ergebnisnotiz.
