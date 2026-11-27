# Slice slice-cr-lh-qa-02-03-ohne-docker: CR — Lastenheft-Fortschreibung LH-QA-02/03 (Ziele docker-los)

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — der Closure-Trigger
der Welle (voller Mutations-Vollauf docker-los **und** `make gates` grün auf
einem Runner ohne Docker-Daemon) beobachtet mehr als ein Slice-DoD trägt
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Reproduzierbarkeit — die Fassung wandert auf die zwei Wege),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(Mindest-Abhängigkeiten — docker wird Weg, nicht Pflicht),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(Messmethode „make gates grün out-of-the-box" gilt unverändert),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(Form des CR-Eintrags bei Personalunion),
[ADR-0003](../../adr/0003-go-native-binaries.md)
(natives Binary bleiben; der *Tool-Build* im gepinnten Image bleibt unberührt).

**Berührte Spec-Stellen:** `spec/lastenheft.md` §4 (LH-QA-02, LH-QA-03) und
§7 (Historie). Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP)).

**Verantwortlich:** —

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Entscheidung des Auftraggebers vom 2026-11-27 (Docker-Daemon
bleibt aus; Labor und Produkt-Aktivierung laufen vollständig docker-los) ist
vertraglich verankert: `LH-QA-03` nennt docker als **Weg, nicht als Pflicht**
(die Bootstrap-Laufzeit braucht nur git; die Gates der emittierten Repos
führen je Werkzeug die gepinnte Version — Image-Pfad *oder* Tool-Pin über den
Laufzeit-Check), und `LH-QA-02` trägt die Reproduzierbarkeit je Weg (Image-Digest
bzw. Tool-Pin mit Inventar-Soll). Der CR-Eintrag steht in §7 Historie in der
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)-Form.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Release-Bau bleibt im gepinnten Image** — [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  nennt den Tool-Build unverändert docker-getrieben; CI-Runner tragen Docker
  ([ADR-0003](../../adr/0003-go-native-binaries.md) bleibt in diesem Punkt
  unangetastet). Der Dogfood-Läufer-Umbau ist
  [`slice-labor-gates-host-rezepte`](slice-labor-gates-host-rezepte.md).
- **Keine Spezifikations-Festlegung hier** — das Soll-Form-Wahl (Mischform,
  Inventar, `pinsync`) ist Architektur (Bestimmung in
  [`slice-adr-gates-laeufen-host-native`](slice-adr-gates-laeufen-host-native.md));
  das Lastenheft nennt Anforderung und Messmethode, nicht Mechanik.
- **Keine Code-Änderung** — der CR ist ein Doku-Slice (Schicht-Abgrenzung);
  Läufer, Makefile, Workflows und Templates rührt er nicht.

## 2. Definition of Done

- [ ] **Liefer-Punkt 1:** CR-Eintrag in `spec/lastenheft.md` §7 Historie —
      Auftraggeber-Beschluss vom 2026-11-27 (docker-los) in der
      [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)-Form.
- [ ] **Liefer-Punkt 2:** `LH-QA-03` neue Fassung — Bootstrap-Laufzeit
      braucht nur git; docker ist Weg, nicht Pflicht; emittierte Ziel-Repos
      bleiben make-getrieben und führen je Gate-Werkzeug die gepinnte Version.
- [ ] **Liefer-Punkt 3:** `LH-QA-02` neue Fassung — Reproduzierbarkeit je
      Weg: Image-Digest (Image-Pfad) bzw. Tool-Pin mit Inventar-Soll
      (docker-los-Pfad); Messmethode nennt beide.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt (hier: `spec/` ist
      der Vertrag).
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
| `spec/lastenheft.md` | update | §4: LH-QA-02/03 neue Fassung samt Messmethoden; §7: CR-Eintrag |
| [`docs/reviews/slice-cr-lh-qa-02-03-ohne-docker…`] | neu | Review-Report nach `.harness/skills/reviewer.md` |

## 4. Trigger

**Start** (`next` → `in-progress`): der Auftrag des Auftraggebers ist
eingetreten (dieser Slice liegt priorisiert in `next/`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als die drei
  Liefer-Punkte — etwa, wenn die neue LH-QA-03-Fassung eine vierte
  Anforderung (etwa Speicher-/Netz-Randbedingungen) nötig macht → re-slicen.
- `in-progress` → `open` (blockiert — Carveout?): Auftraggeber zieht die
  CR-Entscheidung zurück — dann entfällt der Gegenstand ganz.

## 5. Closure-Trigger

DoD (§2) vollständig und die §7-Historie-Zeile nennt Datum, Quelle und
Wirkung des CRs. Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die neue LH-QA-03-Fassung kollidiert mit [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)**
  (Docker Desktop auf macOS/Windows liefert die docker-CLI) — **Ausgang:**
  bei Closure zu bewerten; Kollision wäre ein ADR-Gegenstand des
  Architect-Slices, nicht eine stille Fassungs-Schärfung hier.
- **CI fährt `make gates` docker-los erst nach der Welle** — bis dahin
  bleibt die alte Fassung die laufende; der CR trägt das als Übergangs-Satz
  (Auftraggeber-Beschluss ≠ abgeschlossener Umbau).

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
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (gesamtes Repo,
Kürzel `ALL`) mit der Modus-Deklaration (`harness/conventions.md`
§Modus-Deklaration pro Sub-Area); die Schwelle ≥ 2 von 3 Achsen ist erfüllt —
Strukturregeln im Adaptions-Block, Phase-Reife Phase 5, Evidenz-Risiko
speziell an LH-QA-02 (der Messmethode-Text berührt die Vendoring-Zusagen).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(`docs/plan/planning/observations/`). Treffer für die berührten Aussagen:

- [`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`](../observations/BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht/state.md)
  — 1 Vorgang (< 3×); berührt die Messmethode von LH-QA-02 — die neue
  Fassung nennt je Weg eine Messmethode, der Bestand bleibt.
- [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — 7 Vorgänge, Ausgang *verkörpert* (Zielort `AGENTS.md` §3.9 mit
  Auflösungs-Trigger „Auftraggeber entscheidet"); dieser CR ist **kein**
  macOS-Tragungs-Beschluss — der Trigger bleibt unbefriedigt, solange kein
  macOS-CI die Host-Läufer hält. In der neuen LH-QA-03-Fassung wird dies
  benannt, nicht gelöst.

Keine Treffer unter der Schwelle in den berührten Sub-Areas jenseits der
beiden genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
