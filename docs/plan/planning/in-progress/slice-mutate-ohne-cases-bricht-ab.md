# Slice slice-mutate-ohne-cases-bricht-ab: make mutate ohne MUTATE_CASES bricht ab

**Lifecycle:** Der Zustand dieser Datei ist das Verzeichnis, in dem sie
liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die von der DoD dieses
Slice verschieden ist: Der Guard ist auf den Treiber `harness/tools/mutate.sh`
und seinen Sensor-Text begrenzt; ein repo-weites Mehr (etwa ein Replay-Lauf)
fordert der Slice nicht (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6)).

**Bezug:** [LH-QA-01](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — `make mutate` ist als Werkzeug deklariert (`kein Gate`,
Bindung `AGENTS.md` §3.6); der Abbruch hält das Target ehrlich: Ohne Vorgabe
bricht es laut ab, statt still einen vollen Sweep zu starten.

**Berührte Spec-Stellen:** — (die Spec nennt `make mutate` nicht; die Bindung
liegt in `harness/README.md` §Sensors/§Werkzeuge und `AGENTS.md` §3.6.)

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner (pt9912). **Datum:** 2026-09-29.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `make mutate` bricht ab, wenn `MUTATE_CASES` nicht gesetzt ist —
bevor Grün-Vorlauf, Isolationskopie oder ein Fall laufen. Die Abbruch-Meldung
nennt die Auswege: gezielter Teillauf `MUTATE_CASES='<fall> …'`, der Vollsweep
als CI-Workflow (`gh workflow run mutate.yml`) und — als ausdrückliche
Zustimmung zum lokalen Vollauf — `MUTATE_FORCE=1`, der die Beleg-Mechanik nach
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) erhält (nur volle Läufe schreiben den Beleg-Slot). Der sharded
CI-Vollsweep bleibt unangetastet: der Workflow setzt `MUTATE_CASES` je Shard im
Step-Umfeld des `make mutate`-Aufrufs, und der Shard-Step bricht selbst schon
ab, wenn seine Zuteilung leer wäre — dort läuft `make mutate` nie ohne Vorgabe.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Der CI-Workflow `.github/workflows/mutate.yml` bleibt unverändert (Bestand
  bleibt bewusst stehen) — er ist der Träger des Vollsweeps auf der
  Kosten-Stufe Post-integration; der Guard schließt genau die lokale Lücke,
  die er offen lässt. Eine Änderung an ihm wäre ein anderer Vorgang.
- Die Teillauf-Prüfung in `select_cases` (leerer Wert, unbekannter, doppelt
  genannter Name) bleibt unverändert (Bestand bleibt bewusst stehen) — sie ist
  gebaut, dokumentiert und bewacht (`test/mutate-driver.bats`, Blöcke
  „Teillauf: MUTATE_CASES"); der Guard regelt nur den Zustand „nicht gesetzt".
- Beleg-Mechanik ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)) und `MUTATE_FORCE`-Semantik werden nicht umgebaut
  (Schicht-Abgrenzung) — der Slice ändert die Startbedingung des Treibers,
  nicht die Beleg-Mechanik; [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) steht auf `Proposed`, ihre Umgestaltung
  ist Gegenstand des Slice, den §6 R1 nennt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] Guard in `harness/tools/mutate.sh` (`main`, vor Grün-Vorlauf und
      Isolationskopie): `MUTATE_CASES` nicht gesetzt → Abbruch (Skript Exit 1,
      über `make mutate` Exit 2) mit Meldung, die `MUTATE_CASES='<fall> …'`,
      `gh workflow run mutate.yml` und `MUTATE_FORCE=1` nennt; gesetzt bleibt
      das heutige Verhalten.
- [ ] Wächter-Test in `test/mutate-driver.bats`: ein Block fährt den realen
      Rezept-Weg `make mutate` ohne `MUTATE_CASES` (per `timeout` begrenzt,
      damit der fehlende Guard als rot sichtbar wird statt als Vollauf) und
      bindet Exit sowie Meldung samt Ausweg-Texten; rotes Gegenbeispiel geführt
      (`AGENTS.md` §3.6): Guard entfernt → Block rot.
- [ ] Doku-Update: `harness/sensors/mutate.md` (§Sperren: neue Sperre;
      §Vertrag/§Teillauf: lokaler Vollauf nur noch mit `MUTATE_FORCE=1`) und
      die `make mutate`-Zeile in `harness/README.md` §Werkzeuge nennt den
      Abbruch.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für berührte öffentliche Verträge (siehe Liefer-Punkt 3).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der
      nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | Guard in `main` vor `select_cases`: „nicht gesetzt" per `${MUTATE_CASES+x}` erkennen („leer gesetzt" bleibt in der heutigen `select_cases`-Sperre); Meldung nennt die drei Auswege; der Kopfkommentar (§TEILLAUF) zieht nach |
| `test/mutate-driver.bats` | update | Wächter-Block über den realen Rezept-Weg (`make mutate`, per `timeout` begrenzt): Exit, Meldung, Ausweg-Texte; rotes Gegenbeispiel per entferntem Guard |
| `harness/sensors/mutate.md` | update | §Sperren neue Sperre; §Vertrag (Verhalten ohne `MUTATE_CASES`); §Teillauf: `MUTATE_FORCE=1` als Zustimmung zum lokalen Vollauf |
| `harness/README.md` | update | `make mutate`-Zeile in §Werkzeuge nennt den Abbruch — der Halbsatz, der sagt, was das Target stattdessen tut |

**Ansatz:** Die Erkennung gehört in das Skript, nicht in das Make-Rezept —
dann bricht jeder Aufrufweg laut ab (Rezept wie Direktaufruf), und der
Wächter kann den Rezept-Weg fahren, den der Agent tatsächlich benutzt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Verantwortlich ist gesetzt
(Implementer, pt9912); keine Abhängigkeiten; WIP-Limit frei; der `git mv`
landet auf dem Hauptzweig, bevor die Arbeit beginnt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Der Wächter lässt
  sich auf dem realen Rezept-Weg nicht hermetisch fahren (der `timeout`-Griff
  greift nicht zuverlässig) und der Test müsste die Verdrahtung nachbauen —
  dann steht die Zahn-Disziplin (`AGENTS.md` §3.6: der Sensor, der die reale
  Quelle braucht) im Weg und der Slice wird neu geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Der CI-Workflow liefe
  entgegen der Messung in §6 R3 in den Guard — dann ist die Vorbedingung
  falsch, der Slice blockiert, bis der Workflow-Befund geklärt ist.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD komplett — Wächter-Test grün und rotes Gegenbeispiel geführt, Doku-Update
kommt —, `make gates` grün, Review-Report liegt unter `docs/reviews/`; Lerneintrag
in §7 geschrieben; danach `git mv` nach `done/`.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht. (Die Ausgänge stehen hier als Planung vorgesehen; zugewiesen wird bei
Closure.)

- Die `MUTATE_FORCE=1`-Ausnahme erhält die Beleg-Mechanik nach [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md), die
  auf `Proposed` steht; ändert sich die ADR, wandert der dritte Ausweg mit.
  — **Ausgang:** vorgesehen: weiter offen →
  `BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`
  (dort Stand `geplant`, Kennung
  `slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`);
  Zuweisung bei Closure.
- Der Wächter fährt den realen Rezept-Weg; fehlt der Guard, startet der Test
  den vollen Sweep — ohne Begrenzung hänge `make test` an einem langen Lauf.
  — **Ausgang:** vorgesehen: entfallen — der Test begrenzt den Aufruf per
  `timeout`, der fehlende Guard wird als Überschreitung plus fehlende Meldung
  rot; Zuweisung bei Closure.
- Der Guard bricht den sharded CI-Vollsweep. — **Ausgang:** vorgesehen:
  entfallen — der Workflow setzt `MUTATE_CASES` je Shard im Step-Umfeld des
  `make mutate`-Aufrufs und bricht im Shard-Step schon vor dessen Aufruf ab,
  wenn die Zuteilung leer wäre (`.github/workflows/mutate.yml`, gelesen am
  gemergten Stand 2026-09-29); Zuweisung bei Closure.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos.)*
- **Beobachtungs-Register (`../observations/`):** <… | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührte Sub-Areas: `*` (gesamtes Repo,
Kürzel `ALL`) und `harness/tools/` (Kürzel `TOOLS`) — beide stehen in der
Modus-Deklaration (`harness/conventions.md`); eine zu grobe Abgrenzung stellt
sich nicht, §3 nennt die Pfade einzeln.

**Vorgelagert — offene Beobachtungen sichten:** Register `BEO-ALL` durchgegangen
(Sub-Area aller Einträge ist `*` (gesamtes Repo); gemergter Stand 2026-09-29,
`grep -l '^\*\*Stand:\*\* offen' docs/plan/planning/observations/BEO-ALL/*/state.md | wc -l`
→ 148 offene Einträge). Drei Einträge berühren dieselbe Werkzeug-Fläche, keiner
wird durch diesen Slice getroffen — er ändert weder Shard-Verteilung noch
Matrix-Kosten noch die Beleg-Bezugsmenge:

- `BEO-ALL/mutate-shard-kosten-ungleich-verfehlt-zielkorridor` — Stand
  `offen`, Zähler 1×: Shard-Verteilung/Kosten des CI-Workflows; nicht berührt.
- `BEO-ALL/mutate-matrix-actions-minuten-bei-privatem-repo` — Stand `offen`,
  Zähler 1×: Matrix-Laufkosten bei privatem Repo; nicht berührt.
- `BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf` —
  Stand `geplant`, Zähler 3× (Ausgang zugewiesen): Beleg-Bezugsmenge; der
  Guard erhält die Mechanik via `MUTATE_FORCE=1` (§6 R1), die Beobachtung
  bleibt bei ihrem zugewiesenen Ausgang.

Zähler-Kommando:
`for s in mutate-shard-kosten-ungleich-verfehlt-zielkorridor mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf mutate-matrix-actions-minuten-bei-privatem-repo; do ls "docs/plan/planning/observations/BEO-ALL/$s/evidence/" | wc -l; done`
→ 1 · 3 · 1.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF — Neues Repo, Doc
führt, Code folgt (`harness/conventions.md` §Modus-Deklaration).
