# Slice slice-adr-gates-laeufen-host-native: ADR — Gates und Lab-Läufer docker-los, §3.9-Passung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — der Closure-Trigger
der Welle beobachtet mehr als ein Slice-DoD trägt (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(docker wird Weg, nicht Pflicht — der CR-Träger:
[`slice-cr-lh-qa-02-03-ohne-docker`](../done/slice-cr-lh-qa-02-03-ohne-docker.md)),
[ADR-0003](../../adr/0003-go-native-binaries.md) (Tool-Build bleibt im
gepinnten Image; der Docker-only-Satz der Dogfood-Läufer wandert),
[ADR-0004](../../adr/0004-durchsetzung-emission.md) (durchgesetzte Emission der
Gates bleibt),
[ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)
(Prezedenz: Sprach-Skelett-Toolchain-Entscheidung als ADR-Form),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(vendored Baseline bleibt von der Docker-Frage unabhängig).

**Berührte Spec-Stellen:** `spec/lastenheft.md` §4 (LH-QA-03 — als Bezugs-Satz,
nicht als Quelle), `spec/architecture.md` §Komponenten (Gates-Sicht). Der
Verweis zeigt **aufwärts** (Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP)).

**Verantwortlich:** — *(Architect-Rolle: ADR + `AGENTS.md` §3.9 + Adaptions-Einträge;
Commit-Zuschnitt je `AGENTS.md` §3.8 — eigener Commit, nur Architect-Artefakte)*

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Architektur-Entscheidung hinter der Docker-los-Umstellung steht
an **einer** Quelle: `ADR-0109` entscheidet die Weg-Form (docker-los als
**Default** der Dogfood-Gates und Lab-Läufer; die gepinnten Image-Pfade
bleiben als **opt-in Weg** gepinnt und nicht gestrichen — [
`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) trägt
beide), die Soll-Form der Umgebungs-Zusage (**Mischform** nach Baseline-Regelwerk
`modul-14-docker-harness.md` §Der zweite Träger: ableiten, wo eine Pin-Stelle
existiert; Manifest je übriges Werkzeug; `pinsync` hält Stellen gegeneinander),
den Ausführungsort (Host + CI-Runner) und die §3.9-Passung. Der Adaptions-Block
trägt die Ergänzungen als `MR-<NNN>`-Einträge — die Adaption des Soll-Wegs ist
keine Baseline-Setzung (`modul-14-docker-harness.md`: *„Die Wahl ist eine
Adaption der Baseline und steht als `MR-<NNN>` in `harness/conventions.md`"*).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Makefile-, Skript-, Workflow-Code** — der Architect schreibt ADR und
  Norm-Artefakte (`AGENTS.md` §3.8); die Rezepte baut
  [`slice-labor-gates-host-rezepte`](slice-labor-gates-host-rezepte.md).
- **Kein Release-Bau-Wechsel** — der Tool-Build bleibt im gepinnten Image
  ([ADR-0003](../../adr/0003-go-native-binaries.md), CI-Runner tragen Docker).
- **Kein macOS-Tragungs-Beschluss als Gegenstand** — die ADR nennt die
  Grenze (Linux-Host-Annahme der Dogfood-Läufer,[`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)),
  entscheidet sie aber nicht; Träger wäre eine eigene Entscheidung.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** `ADR-0109` liegt `Accepted` vor — Weg-Form (docker-los
      Default, Image-Pfad opt-in), Soll-Form (Mischform, je Werkzeug eine
      Quelle), Ausführungsort (Host + CI), die Grenze je Weg, Konsequenzen je
      gestrichenem Weg mit Verweis; ADR-Index ergänzt.
- [ ] **Liefer-Punkt 2:** `AGENTS.md` §3.9 trägt die neue Fassung — die
      Dogfood-Läufer laufen host-native; docker ist Werkzeug-Weg, nicht
      Gate-Pflicht; der PreToolUse-Guard bleibt Stolperdraht (Befehlsposition),
      die direkte Toolchain-Position bleibt verboten, Rezepte über `make` sind
      der Weg.
- [ ] **Liefer-Punkt 3:** Adaptions-Einträge (`MR-<NNN>`) im
      [`harness/conventions.md`](../../../../harness/conventions.md)-Index +
      je eine Eintrags-Datei unter `harness/conventions/`: Soll-Form (Mischform)
      und Ausführungsort der Umgebungs-Zusage; der Index-Eintrag verweist die
      Sensoren-Zeile der [`harness/sensors/environment-check.md`](../../../../harness/sensors/environment-check.md)
      (die der Implementer-Slice baut) als Bindung.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt (ADR-Index).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/0109-…-gates-laeufen-docker-los.md` | neu | die Architektur-Entscheidung (Kontext, Entscheidung, Alternativen, Konsequenzen) |
| `docs/plan/adr/README.md` | update | ADR-Index ergänzt |
| `AGENTS.md` | update | §3.9-Fassung (Dogfood-Läufer host-native; docker Weg statt Pflicht); eigener Architect-Commit §3.8 |
| `harness/conventions.md`, `harness/conventions/MR-<NNN>…` | neu | Adaptions-Einträge je Adaption (Soll-Form, Ausführungsort) |

**Ansatz als Liste (ergänzt die Tabelle):**

- Der ADR-Kontext nennt die Entscheidung des Auftraggebers als
  CR-Bezug ([`slice-cr-lh-qa-02-03-ohne-docker`](../done/slice-cr-lh-qa-02-03-ohne-docker.md))
  und die [ADR-0003](../../adr/0003-go-native-binaries.md)-Grenze (Tool-Build
  bleibt docker-getrieben) — die zwei Wege leben nebeneinander, einer ist
  Pflicht, der andere opt-in.
- Der ADR entscheidet **nicht** die Implementations-Mechanik (Rezept-Texte,
  Inventar-Dateiform) — die steht in den Implementer-Slices, die ADR nennt
  nur die Begriffe (Tool-Pin, Inventar, Mischform, `pinsync`, erster Check).

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-cr-lh-qa-02-03-ohne-docker`](../done/slice-cr-lh-qa-02-03-ohne-docker.md)
liegt in `done/` — die Architektur-Entscheidung setzt auf der vertragsseitigen
Fassung auf (Rollen-Sequenz Modul 8: Architect-Zug nach Planner, vor
Implementation).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als die drei
  Liefer-Punkte — etwa, wenn die Mischform-Adaption einen zweiten
  Soll-Weg-Nachweis je Sub-Area braucht → re-slicen.
- `in-progress` → `open` (blockiert — Carveout?): die ADR-Abwägung zeigt,
  dass Mischform an einem Instrument des Inventars kein Soll tragen kann
  (etwa kein versionierbares `awk` am CI-Runner) — dann Carveout je
  [Modul 7](../../../../.harness/baseline/v7.0.0/regelwerk/modul-07-carveouts.md)
  und der Slice geht zurück, bis die Frage entschieden ist.

## 5. Closure-Trigger

DoD (§2) vollständig — `ADR-0109` ist `Accepted`, die §3.9-Fassung ist
committet, die Adaptions-Einträge stehen im Index. Zusätzlich: Closure-Notiz
mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **`pinsync` deckt ein Inventar-Werkzeug nicht** (Soll-Stelle ist nicht
  maschinen-lesbar und das Manifest drifet gegen die Pin-Stelle) —
  **Ausgang:** der ADR nennt je Werkzeug seine Soll-Quelle; wo keine Pin-Stelle
  existiert, trägt das Manifest den Wert selbst (Mischform,
  `modul-14-docker-harness.md` §Woher das Soll kommt); wachsene Abwägungen
  stehen in der ADR, nicht in einem zweiten Dokument.
- **§3.9-Änderung wird als Gate-Lockerung gelesen** — **Ausgang:** die
  Fassung nennt die Grenze (Befehlsposition bleibt verboten; die Rezepte
  laufen über `make`); der PreToolUse-Guard bleibt unverändert in Kraft.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <… | keine Beobachtung angefallen>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (gesamtes Repo,
Kürzel `ALL`) und die Norm-Artefakte `AGENTS.md`/`harness/conventions.md`
(Section `§3.8` schreibt sie als Architect-Artefakte); die Schwelle ≥ 2 von 3
Achsen ist erfüllt — Strukturregeln im Adaptions-Block, Phase-Reife Phase 5,
Evidenz-Risiko über die §3.9-Fassung (das Hard-Rule-Text und Guard-
Verdrahtung zusammen hält).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer für die berührten Aussagen:

- [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — 7 Vorgänge, Ausgang *verkörpert* auf `AGENTS.md` §3.9; der Auflösungs-Trigger
  bleibt unbefriedigt — dieser Slice ändert die Fassung desselben Absatzes,
  also wird dessen *Plattform-Sub-Set* (Linux-Host-Annahme) im neuen Text
  bewusst benannt, ohne den macOS-Trigger einzulösen. Bei Closure
  `evidence/`-Datei ergänzen.

Keine Treffer unter der Schwelle jenseits des genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
