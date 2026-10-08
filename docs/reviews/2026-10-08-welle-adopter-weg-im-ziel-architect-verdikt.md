# Welle-Closure welle-adopter-weg-im-ziel — Architect-Verdikt (Schritte 2 ADR-Zweig und 3b)

- **Rolle:** Architect · **an:** Planner · **Eingang:** `2026-10-08-welle-adopter-weg-im-ziel-audit-vorlage`,
  Abschnitte A, B, C1, C2 (C3 und D brauchen kein Verdikt) · **Bezug:**
  [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), Baseline-Regelwerk `v6.17.0`,
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 2 und 3
- **Gemessen auf:** `fd7b25f2`
- **Ergebnis:** keine Folge-ADR, kein neuer Slice. Ein Adaptions-Eintrag
  ([`MR-088`](../../harness/conventions.md#mr-088)) mit Kopf-Marke an `MR-048`. Kein Eintrag
  bekommt einen Anker `seit welle-adopter-weg-im-ziel`.

## A — Trigger-Audit, ADR- und Hard-Rule-Zweig

| ADR · Trigger | gefeuert | Verdikt |
|---|---|---|
| [ADR-0051](../plan/adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) T2 „ein Slice entscheidet die Adopter-Seite" | ja | **erledigt** durch [ADR-0086](../plan/adr/0086-erzeugtes-repo-bekommt-keine-eigentums-aussage-ueber-seinen-anweisungssatz.md) (Teil-Supersedes); die Marke steht in der Index-Zeile von ADR-0051 (`grep -n '0086' docs/plan/adr/README.md`). |
| [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) T1–T4 | nein | **bestätigt.** ADR-0086 beantwortet nur die *delegierte* Folgepflicht 3 (emittierte Ebene); kein Trigger von ADR-0028 nennt sie. T1 (Baseline benennt schreibende Rolle) ist am Stand `v6.17.0` nicht eingetreten (ADR-0086 §Kontext, `grep -rn 'Anweisungssatz' .harness/baseline/v6.17.0/regelwerk/*.md \| wc -l` → 0). Kein `supersedes`, die Festlegungen für dieses Repo bleiben unberührt. |
| [ADR-0048](../plan/adr/0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) Delegations-Klausel | — | delegiert nur; ADR-0086 Festlegung 4 lässt den Kern stehen. Bestätigt. |
| übrige ADRs | nein | im Fenster kein Pin-, Baseline- oder Release-Sprung (`git diff --name-status 83fe258e HEAD -- docs/plan/adr harness/conventions AGENTS.md Makefile d-check.mk internal/emit/emit.go .d-check.yml` → nur ADR-0086 und Index). |

**Hard Rules:** einziger Auflösungs-Trigger in [`AGENTS.md`](../../AGENTS.md) ist *permanent*
(§3.5). **Bestätigt**, keine Zeile zu entfernen.

## B — Verkörperung beim Wiederauftreten (3b)

| Eintrag | Verdikt | Begründung · Sensor |
|---|---|---|
| `plan-abweichung-landet-im-commit-bericht-statt-im-plan` | (iii) | Ein Commit trägt keine Slice-Kennung, kein Sensor ordnet seine Dateien der §3 eines Plans zu (Grenze steht schon in `state.md`). Träger bleibt der Plan-vs-Code-Diff des Verifiers. |
| `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` | (ii) → `slice-119-zusage-ohne-fall-wird-sichtbar` | wie im Vorgänger-Verdikt; der Slice zählt Zusagen ohne `test/mutations/`-Fall. |
| `neuer-waechter-ohne-mutations-fall` | (ii) → `slice-119-zusage-ohne-fall-wird-sichtbar` | dieselbe Klasse; 17 Belege machen den Slice zum dringlichsten der Gruppe — Priorität ist Planner-Sache. |
| `zusage-nennt-zwei-kanten-der-sensor-deckt-eine` | (ii) → `slice-069-zahn-bindet-zusicherung` | eine Kante ohne bindenden Fall wird am Treiber sichtbar. |

Beide Slices liegen in `open/`.

## C1 — `MR-048` nennt einen entfallenen Träger

Der Link auf `slice-146` löst auf (die Datei liegt in `done/`), falsch ist die Aussage *„die bleiben
dort offen"*. Den Rumpf eines angenommenen Eintrags ändert niemand; darum
[`MR-088`](../../harness/conventions.md#mr-088) als Nachfolger dieser Aussage und eine Kopf-Marke an
`MR-048` nach `MR-032`. `MR-088` hält den Stand nach der Auftraggeber-Entscheidung fest: beide
Regeln weder adoptiert noch als Abweichung deklariert, ohne Sensor; Auflösungs-Trigger ist ein
Slice, der eine Regel entscheidet, oder ein Replay-Manifest (Modul 12), dessen `image_hash`-Slot die
zweite Regel braucht.

## C2 — Ausgang der zwei „gestrichen, als Ablehnung"-Einträge

Keine neue Form: die geschlossene Menge trägt beide.

| Eintrag | Ausgang | Zielort · Begründung |
|---|---|---|
| `folge-slice-ueberlebt-baseline-sprung-mit-alter-pflicht` | **verkörpert** | Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3, *„Was den Bestand überlebt hat, bekommt denselben Lese-Schritt"* — jede Welle-Closure urteilt über jeden offenen Slice (bestätigt · entfallen · konsolidiert). Kein Herkunfts-Anker: die Baseline trägt ihre eigene Adresse ([ADR-0049](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 1). **Grenze:** der Schritt läuft bei der Welle-Closure, nicht beim Sprung; ein Plan bleibt bis zur nächsten Closure ungeprüft — akzeptiert, weil ein Sprung ohne nachfolgende Welle-Closure in diesem Repo nicht vorkommt. |
| `baseline-sprungweite-treibt-kosten` | **verkörpert** (i) | Zielort `Makefile:baseline-freshness`, nächtlich in `.github/workflows/upstream-drift.yml`: meldet jeden neueren Upstream-Tag, die Sprungweite ist damit an jedem Release sichtbar. Ob adoptiert wird, entscheidet der Auftraggeber; einen Rhythmus setzt das nicht. |

**Akzeptiertes Negativ, für künftige Läufe:** eine Ablehnung ohne Träger ist kein Ausgang. Lehnt der
Auftraggeber einen planenden Slice ab und trägt nichts anderes die Beobachtung, bleibt `state.md`
auf `offen` — nicht `gestrichen`, denn die Beobachtung kann weiter auftreten.

**Für den Planner:** (ii)-Zeilen → Ausgang *geplant* auf die Kennung; (i)/(iii) und C2 →
*verkörpert* mit der Begründung aus der Tabelle. `state.md` schreibt der Planner.
