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

**Berührte Spec-Stellen:** `spec/lastenheft.md` §3 ([`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)), §4 ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) und §7 (Historie). Nachzugs-Übergabe der Verifikation: der
ursprüngliche Kopf nannte §4 nur mit [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/03; der Folgestellen-Nachzug
(CR 0.28.1) zog [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) und [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) in denselben Zustand (siehe §6,
Risiko-1-Ausgang). Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice
nie (Baseline-Regelwerk `grundlagen-referenz-richtung.md` §Referenz-Richtung
(SDP)).

**Verantwortlich:** pt9912

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Entscheidung des Auftraggebers vom 2026-11-27 (Docker-Daemon
bleibt aus; Labor und Produkt-Aktivierung laufen vollständig docker-los) ist
vertraglich verankert: [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) nennt docker als **Weg, nicht als Pflicht**
(die Bootstrap-Laufzeit braucht nur git; die Gates der emittierten Repos
führen je Werkzeug die gepinnte Version — Image-Pfad *oder* Tool-Pin über den
Laufzeit-Check), und [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) trägt die Reproduzierbarkeit je Weg (Image-Digest
bzw. Tool-Pin mit Inventar-Soll). Der CR-Eintrag steht in §7 Historie in der
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)-Form.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Release-Bau bleibt im gepinnten Image** — [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  nennt den Tool-Build unverändert docker-getrieben; CI-Runner tragen Docker
  ([ADR-0003](../../adr/0003-go-native-binaries.md) bleibt in diesem Punkt
  unangetastet). Der Dogfood-Läufer-Umbau ist
  [`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md).
- **Keine Spezifikations-Festlegung hier** — das Soll-Form-Wahl (Mischform,
  Inventar, `pinsync`) ist Architektur (Bestimmung in
  [`slice-adr-gates-laeufen-host-native`](../done/slice-adr-gates-laeufen-host-native.md));
  das Lastenheft nennt Anforderung und Messmethode, nicht Mechanik.
- **Keine Code-Änderung** — der CR ist ein Doku-Slice (Schicht-Abgrenzung);
  Läufer, Makefile, Workflows und Templates rührt er nicht.

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** CR-Eintrag in `spec/lastenheft.md` §7 Historie —
      Auftraggeber-Beschluss vom 2026-11-27 (docker-los) in der
      [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)-Form
      (Zeilen 0.28.0 und 0.28.1).
- [x] **Liefer-Punkt 2:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) neue Fassung — Bootstrap-Laufzeit
      braucht nur git; docker ist Weg, nicht Pflicht; emittierte Ziel-Repos
      bleiben make-getrieben und führen je Gate-Werkzeug die gepinnte Version.
- [x] **Liefer-Punkt 3:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) neue Fassung — Reproduzierbarkeit je
      Weg: Image-Digest (Image-Pfad) bzw. Tool-Pin mit Inventar-Soll
      (docker-los-Pfad); Messmethode nennt beide.
- [x] `make gates` grün — **bedingt über den
      [Carveout CO-007](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md)**:
      die zwei CI-Störstellen sind vorgefunden (Lauf 45939443193, vorgängig;
      am HEAD-Stand wiederholt sich die Fork-Signatur im gates-Job, Lauf
      45944570095), der lokale Nachweis ist nicht herstellbar (Docker-Daemon
      aus). Trigger der Auflösung: Abschluss von welle-ohne-docker.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`../../../reviews/2026-11-27-slice-cr-lh-qa-02-03-ohne-docker.md`) —
      Rollenwechsel nach Schritt 8 des Minimal Agent Workflow (`AGENTS.md`
      §6), kein Self-Review (Modul 8).
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt (hier: `spec/` ist
      der Vertrag — die CR-Zeilen und die §4-Fassungen).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag (§7).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — zwei neue
      Einträge mit je einem Beleg (siehe §7).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (siehe §6 und §7).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft — Übergabe an die Welle-Closure
      (Welle-Betrieb).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/lastenheft.md` | update | §4: [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)/03 neue Fassung samt Messmethoden; §7: CR-Eintrag |
| [`docs/reviews/slice-cr-lh-qa-02-03-ohne-docker…`] | neu | Review-Report nach `.harness/skills/reviewer.md` |

## 4. Trigger

**Start** (`next` → `in-progress`): der Auftrag des Auftraggebers ist
eingetreten (dieser Slice liegt priorisiert in `next/`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als die drei
  Liefer-Punkte — etwa, wenn die neue [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)-Fassung eine vierte
  Anforderung (etwa Speicher-/Netz-Randbedingungen) nötig macht → re-slicen.
- `in-progress` → `open` (blockiert — Carveout?): Auftraggeber zieht die
  CR-Entscheidung zurück — dann entfällt der Gegenstand ganz.

## 5. Closure-Trigger

DoD (§2) vollständig und die §7-Historie-Zeile nennt Datum, Quelle und
Wirkung des CRs. Zusätzlich: Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die neue [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)-Fassung kollidiert mit [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)**
  (Docker Desktop auf macOS/Windows liefert die docker-CLI) — **Ausgang:**
  bei Closure zu bewerten; Kollision wäre ein ADR-Gegenstand des
  Architect-Slices, nicht eine stille Fassungs-Schärfung hier.
  **Ausgang (entfallen):** die Kollision trat nicht an — der CR 0.28.1
  desselben Slices zog [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
  (und [`LH-FA-07`](../../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren)) selbst auf die Gate-Weg-Fassung, nicht still (Historie-Zeile
  0.28.1, Review-Befund F-1/F-2); die Architektur-Festlegung (Soll-Form,
  Inventar, `pinsync`) bleibt beim Architect-Slice der Welle.
- **CI fährt `make gates` docker-los erst nach der Welle** — bis dahin
  bleibt die alte Fassung die laufende; der CR trägt das als Übergangs-Satz
  (Auftraggeber-Beschluss ≠ abgeschlossener Umbau).
  **Ausgang (eingetreten → Carveout):**
  [CO-007](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md)
  — beide CI-Störstellen vorgefunden; Trigger der Heilung: Abschluss von
  welle-ohne-docker, danach die CI-Heilung als eigener Zug.

## 7. Closure-Notiz

**Gegenstand:** offene §2-Zeile `make gates` grün — Vorbestand-Rotmenge der Gates-Kette, nicht in diesem Slice geliefert (Träger: die Gates-Posten der Welle).

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

- **Was hat funktioniert:** die
  [`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)-Form
  zweistufig — CR 0.28.0 trägt den Grundsatz (docker-los als Weg, nicht
  Pflicht), CR 0.28.1 den Folgestellen-Nachzug als Patch-Zeile. Der
  Review-Abgleich
  ([`../../../reviews/2026-11-27-slice-cr-lh-qa-02-03-ohne-docker.md`](../../../reviews/2026-11-27-slice-cr-lh-qa-02-03-ohne-docker.md))
  traf kein HIGH; die 4 MEDIUM wurden durch 0.28.1 gelöst. Die Verifikation
  (frischer Kontext) bestätigte die drei Liefer-Punkte, den [`MR-015`](../../../../harness/conventions/MR-015-change-request-bei-personalunion-von-auftraggeber-und-entwickler.md)/[`MR-042`](../../../../harness/conventions/MR-042-der-anlass-einer-lastenheft-aenderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz.md)-Formkörper
  und die Widerspruchsfreiheit. `make mutate-auswahl` lief docker-los mit
  Exit 0 ("kein Fall beruehrt — kein Lauf noetig").
- **Was ging anders als geplant:** die [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)-Kollision ging nicht über die
  geplante ADR-Route des Architect-Slices, sondern über die
  Folgestellen-Route im Slice selbst (CR 0.28.1; Ausgang in §6). Setzung-2-Korrektur
  ([`MR-042`](../../../../harness/conventions/MR-042-der-anlass-einer-lastenheft-aenderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz.md)):
  die 0.28.0-Historie-Zeile trug den Anlass an falschem Ort — sie bleibt
  Protokoll, die Korrektur ist als eigene Zeile dokumentiert, und der Anlass
  steht hier: **Auftraggeber-Beschluss 2026-11-27 — der Docker-Daemon bleibt
  aus; Labor- und Produkt-Aktivierung färben auf einen docker-los Gate-Weg.**
  Der CI-Nachweis der DoD-Zeile `make gates` ist nicht grün: beide Störstellen
  sind vorgefunden und tragen unter dem
  [Carveout CO-007](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md)
  (Trigger: Abschluss von welle-ohne-docker) — nicht unter stiller Duldung.
- **Steering-Loop-Eintrag:** benannte Lücke, **nicht verkörpert** — kein
  `liegt in`, da in dieser Closure nichts verkörpert wurde: Die CR-Form des
  Lastenhefts lässt Folgestellen in anderen Spec-Stellen liegen; zum zweiten
  Vorgang geführt (Präzedenz 0.25.1 als Patch-Zeile — dort ohne abgeschlossenen
  Vorgang benannt, nicht gezählt), in diesem Slice durch den CR 0.28.1
  geheilt. Geführt im Register: [`../observations/BEO-ALL/cr-folgestellen-in-anderen-spec-stellen-bleiben-liegen/observation.md`](../observations/BEO-ALL/cr-folgestellen-in-anderen-spec-stellen-bleiben-liegen/observation.md).
  Bei der dritten Führung schneidet der Lese-Schritt den Träger; die Norm-Arbeit
  läge bei der Architect-Rolle (`AGENTS.md` §3.8).
- **Beobachtungs-Register (`../observations/`):** zwei neue Einträge, je ein
  Beleg (dieser Slice): [`../observations/BEO-ALL/gates-keys-fork-erschoepfung-bricht-den-ci-gates-lauf/observation.md`](../observations/BEO-ALL/gates-keys-fork-erschoepfung-bricht-den-ci-gates-lauf/observation.md)
  — CI-Job `gates` bricht an Fork-Erschöpfung, `docs-check` fährt nie; und
  [`../observations/BEO-ALL/cr-folgestellen-in-anderen-spec-stellen-bleiben-liegen/observation.md`](../observations/BEO-ALL/cr-folgestellen-in-anderen-spec-stellen-bleiben-liegen/observation.md)
  — siehe Lerneintrag. Kein bestehender Eintrag wurde getroffen; die zwei
  vorgelagert gesichteten (§8) bleiben unverändert.
- **Folge-Slices und Übergaben** (keine Slice-Datei von dieser Closure gelegt;
  die Welle schneidet):
  - F-5 aus dem Review (das `AGENTS.md`-§3.9-Zitat in der Spec trägt die alte
    Fassung) → [`slice-adr-gates-laeufen-host-native`](../done/slice-adr-gates-laeufen-host-native.md)
    (Architect-Slice der Welle).
  - Vier Superset-Sätze in `spec/lastenheft.md` (Zeilen 156, 298, 483, 563 —
    sie nennen `git + docker` als geschlossene Abhängigkeits-Menge) →
    derselbe Architect-Slice; Folgestellen beim Emittieren der docker-los-Mechanik
    in welle-ohne-docker.
  - Träger-Vertrags-Teil des `full-smoke`-Befunds →
    [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md).
  - Fork-Erschöpfung → Register-Zeile und Carveout-Zug (CO-007), kein eigener
    Eintrag in `open/` von dieser Closure.
  - Rest-Lücke Mutations-Bestand: kein Fall im Bestand führt
    `spec/lastenheft.md` (die Fall-`files:`-Zeilen über der Spec führen `spec/spezifikation.md`),
    das `mutate-auswahl`-Urteil beruht auf der leeren Schnittmenge — benannt,
    kein Bruch; ob ein Fall über das Lastenheft gebraucht wird, schneidet die
    Lese-Schritt-Ebene.
- **Risiken aus §6:** Risiko 1 ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)-Kollision) — **entfallen** mit Grund
  (CR 0.28.1, siehe §6). Risiko 2 (CI-Nachweis) — **eingetreten**, Ausgang
  Carveout CO-007 mit dem Trigger Abschluss von welle-ohne-docker.
- **Drei Paarungen:** Anker — keiner gesetzt (keine Verkörperung in dieser
  Closure, kein `liegt in`). Folge-Slice — die Übergaben oben benannt; die
  Adressen sind Slices der offenen Welle. Register — zwei Einträge mit je
  einem Beleg. Ergebnis der Prüfung: von der Welle-Closure zu fahren (Übergabe,
  siehe das leere Kästchen in §2).

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
speziell an [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Messmethode-Text berührt die Vendoring-Zusagen).

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen
(`docs/plan/planning/observations/`). Treffer für die berührten Aussagen:

- [`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`](../observations/BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht/state.md)
  — 1 Vorgang (< 3×); berührt die Messmethode von [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) — die neue
  Fassung nennt je Weg eine Messmethode, der Bestand bleibt.
- [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — 7 Vorgänge, Ausgang *verkörpert* (Zielort `AGENTS.md` §3.9 mit
  Auflösungs-Trigger „Auftraggeber entscheidet"); dieser CR ist **kein**
  macOS-Tragungs-Beschluss — der Trigger bleibt unbefriedigt, solange kein
  macOS-CI die Host-Läufer hält. In der neuen [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)-Fassung wird dies
  benannt, nicht gelöst.

Keine Treffer unter der Schwelle in den berührten Sub-Areas jenseits der
beiden genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
