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
[ADR-0004](../../adr/0004-durchsetzungs-emission.md) (durchgesetzte Emission der
Gates bleibt),
[ADR-0088](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)
(Prezedenz: Sprach-Skelett-Toolchain-Entscheidung als ADR-Form),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(vendored Baseline bleibt von der Docker-Frage unabhängig).

**Berührte Spec-Stellen:** `spec/lastenheft.md` §4 ([`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — als Bezugs-Satz,
nicht als Quelle), `spec/architecture.md` §Komponenten (Gates-Sicht). Der
Verweis zeigt **aufwärts** (Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP)).

**Verantwortlich:** pt9912 *(Architect-Rolle: ADR + `AGENTS.md` §3.9 + Adaptions-Einträge;
Commit-Zuschnitt je `AGENTS.md` §3.8 — eigener Commit, nur Architect-Artefakte)*

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die Architektur-Entscheidung hinter der Docker-los-Umstellung steht
an **einer** Quelle: [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) entscheidet die Weg-Form (docker-los als
**Default** der Dogfood-Gates und Lab-Läufer; die gepinnten Image-Pfade
bleiben als **opt-in Weg** gepinnt und nicht gestrichen —
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) trägt
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
  [`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md).
- **Kein Release-Bau-Wechsel** — der Tool-Build bleibt im gepinnten Image
  ([ADR-0003](../../adr/0003-go-native-binaries.md), CI-Runner tragen Docker).
- **Kein macOS-Tragungs-Beschluss als Gegenstand** — die ADR nennt die
  Grenze (Linux-Host-Annahme der Dogfood-Läufer,[`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)),
  entscheidet sie aber nicht; Träger wäre eine eigene Entscheidung.

## 2. Definition of Done

- [x] **Liefer-Punkt 1:** [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) liegt `Accepted` vor — Weg-Form (docker-los
      Default, Image-Pfad opt-in), Soll-Form (Mischform, je Werkzeug eine
      Quelle), Ausführungsort (Host + CI), die Grenze je Weg, Konsequenzen je
      gestrichenem Weg mit Verweis; ADR-Index ergänzt —
      `525749b4` (ADR und Index-Eintrag in einem Commit).
- [x] **Liefer-Punkt 2:** `AGENTS.md` §3.9 trägt die neue Fassung — host-native
      als Pflicht-Weg, Image-Weg opt-in; der PreToolUse-Guard und das
      Befehlspositions-Verbot bleiben in Kraft — `cdaf7d52` (Fassung),
      Link-Nachzug `815bee43` (F-1).
- [x] **Liefer-Punkt 3:** Adaptions-Einträge im
      [`harness/conventions.md`](../../../../harness/conventions.md)-Index +
      Eintrags-Datei unter `harness/conventions/` als [`MR-098`](../../../../harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md): Soll-Form
      (Mischform) und Ausführungsort in **einem** Eintrag
      (Plan-Abweichung, siehe §7) — `daa4aad2`. Der Index-Eintrag verweist die
      Sensoren-Zeile der [`harness/sensors/environment-check.md`](../../../../harness/sensors/environment-check.md)
      als Bindung; ihr Träger-Slice bleibt
      [slice-labor-gates-host-rezepte](../done/slice-labor-gates-host-rezepte.md).
- [x] `make gates` grün — lokal nicht herstellbar (Docker-Daemon aus); die
      CI-Jobs `gates`/`full-smoke` sind rot **vorgefunden** vorgängig — bedingt
      über [CO-007](../../carveouts/CO-007-ci-rot-vorgefunden-gates-und-full-smoke.md),
      Trigger = Abschluss der [Welle](../welle-ohne-docker.md); der Nachweis
      der Architektur liegt im CI-Lauf der gepushten Commits
      (`mutate-auswahl` Exit 0 — kein Fall berührt).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`cd5681ef`) — kein HIGH/MEDIUM; F-1 (LOW) ging an den Architect zurück
      und ist mit `815bee43` gelöst; zwei Folgestellen als INFO deklariert
      (Rest-Übergaben, §7). Kein Self-Review (Modul 8).
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt — ADR-Index ergänzt
      (`525749b4`); die vier Superset-Sätze des Lastenhefts trägt
      CR 0.28.2 (`94b3de1a`), nicht dieser Slice.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag (§7).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/slice-adr-gates-laeufen-host-native.md` ergänzt in
      [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md);
      keine weitere Beobachtung angefallen (§7); **kein Zähler gesetzt**.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen) — siehe §7.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
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

DoD (§2) vollständig — [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) ist `Accepted`, die §3.9-Fassung ist
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

**Gegenstand:** offene §2-Zeile `make gates` grün — Vorbestand-Rotmenge der Gates-Kette, nicht in diesem Slice geliefert (Träger: die Gates-Posten der Welle).

- **Was hat funktioniert:** die Rollen-Sequenz ohne Widerspruch — Architect-Zug
  (`525749b4` ADR + Index, `cdaf7d52` `AGENTS.md` §3.9, `daa4aad2` [`MR-098`](../../../../harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md),
  `815bee43` F-1-Links), Review
  ([`../../../reviews/2026-11-27-slice-adr-gates-laeufen-host-native.md`](../../../reviews/2026-11-27-slice-adr-gates-laeufen-host-native.md),
  kein HIGH/MEDIUM), Verifikation — alle drei Liefer-Punkte bestätigt,
  `make mutate-auswahl` Exit 0 („0 Fall/Faelle — kein Fall beruehrt“), kein
  Produktcode im Diff. Der Commit-Zuschnitt nach §3.8 hielt: Architect-Artefakte
  in Architect-Commits, das Lastenheft trägt der CR, diese Closure ist ein
  eigener Planner-Commit (nur Closure-Artefakte, Rolle in der Message).
- **Was ging anders als geplant:**
  1. Ein statt zwei MR-Einträge: der Plan (§3) bestellte Soll-Form und
     Ausführungsort als zwei Adaptionen; Baseline-Regelwerk
     `modul-14-docker-harness.md` §Der zweite Träger bindet beide in dieselbe
     MR — `daa4aad2` liefert sie als einen Eintrag [`MR-098`](../../../../harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md), die Abweichung
     ist im Eintrag benannt. Die Zusammenschaltung ist die tragende: Ausführungsort
     und Soll-Form sind dieselbe Aussage über dieselben Werkzeuge.
  2. **ADR-Zustands-Nachzug:** [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) §Konsequenzen trägt den Stand
     „die vier Superset-Sätze lesen außen-stehend als `git + docker`-Fassung;
     keine CR-Zeile angelegt — Übergabe an die Planung des Umbaus“. Seit
     `94b3de1a` (CR 0.28.2 — von [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) selbst ausgelöst) sind die Sätze
     auf die Gate-Weg-Fassung umgeschrieben; der in der ADR beschriebene
     Zustand ist überholt. Die ADR ist `Accepted` und eingefroren (§3.4),
     der Nachzug ist nicht in-place: die Auflösung trägt diese Zeile — die
     CR-Zeile 0.28.2 verweist selbst auf [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) als Ursprung —, nichts an
     der ADR geändert, keine Folge-ADR.
  3. F-1 (Review, LOW): sechs relative Links der [`MR-098`](../../../../harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md)-Eintrags-Datei um
     die fehlende `../`-Stufe gehoben (`815bee43`) — nach der Review-Runde,
     daher erst vom Verifikations-Lauf gesehen; kein Produktcode im Diff.
- **Steering-Loop-Eintrag:** benannte Folgestellen, **nicht verkörpert** — kein
  `liegt in`. Die Soll-Form-in-einer-MR-Zusammenschaltung ist als [`MR-098`](../../../../harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md)
  verkörpert, folgt aber keinem Beobachtungs-Muster: sie ist die Ausführung
  der [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)-Weg-Form unter der modul-14-Bindung, ohne Vorgänger im
  Register. Lerneintrag in der Form **benannte Spec-Stelle mit Träger**:
  [`ARC-012`](../../../../spec/architecture.md) — die Sicht sagt docker
  „substituierbar: nein“ und liest sich seit [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) überholt;
  [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  trägt die CR-Fassung 0.28.2, die Stelle ist ohne CR fortschreibbar und ihr
  Träger ist das Doku-Update der Mechanik ([`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) §Konsequenzen). Derselbe
  Nachzug gilt für die Sicht-Doku, die die alte §3.9-Fassung zitiert
  ([`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
  Host-Bedarf „git, docker und GNU make“, `harness/README.md` Docker-only-Satz)
  — Träger [slice-doku-nachzug-ohne-docker](../done/slice-doku-nachzug-ohne-docker.md)
  (§1 führt beide Sicht-Doku-Zeilen).
- **Beobachtungs-Register (`../observations/`):** ein bestehender Eintrag
  getroffen:
  [`BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer`](../observations/BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer/state.md)
  — `evidence/slice-adr-gates-laeufen-host-native.md` ergänzt; der §8
  gesichtete Umstand (derselbe §3.9-Absatz neu geschrieben, ohne den
  macOS-Trigger einzulösen) ist belegt. Zähler folgt aus den Dateien (jetzt
  8 Beleg-Dateien) — kein Zähler gesetzt. Keine weitere Beobachtung angefallen.
- **Folge-Slices:** keine aus diesem Slice angelegt — die zwei Folgestellen
  stehen als INFO im Review-Report, die Träger in der Welle:
  [slice-doku-nachzug-ohne-docker](../done/slice-doku-nachzug-ohne-docker.md)
  (Sicht-Doku-Zeilen, siehe Lerneintrag); [`ARC-012`](../../../../spec/architecture.md)
  — die Verifier-Übergabe nennt
  [slice-emittierte-gates-host-pfad](../done/slice-emittierte-gates-host-pfad.md)
  bzw. [slice-doku-nachzug-ohne-docker](../done/slice-doku-nachzug-ohne-docker.md),
  keines der beiden führt die Stelle heute in seinem §1 — die konkrete
  Zuordnung trägt die Welle-Closure (Lese-Schritt); notfalls per Übernahme
  (`Übernimmt:`).
- **Risiken aus §6** (je genau ein Ausgang):
  - „`pinsync` deckt ein Inventar-Werkzeug nicht“ — **entfallen** als Risiko
    dieser Setzung: die ADR nennt je Werkzeug seine Soll-Quelle; wo keine
    Pin-Stelle existiert, trägt das Manifest den Wert selbst (Mischform); die
    Adaption steht als [`MR-098`](../../../../harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md) mit den Soll-Herkünften je Werkzeug (Ableiten
    an `GO_VERSION` und den Image-Digests, Manifest je übriges Werkzeug mit
    Grund). Dass die Maschine die Stellen hält, ist Aufgabe des
    `pinsync`-Moduls mit den Mechanik-Slices — kein Risiko dieser Setzung mehr.
  - „§3.9-Änderung wird als Gate-Lockerung gelesen“ — **entfallen** mit Grund:
    die Fassung nennt die Grenze (Befehlsposition und direkte Toolchain-Position
    bleiben verboten, Rezepte über `make` sind der Weg); der PreToolUse-Guard
    bleibt unverändert in Kraft (`cdaf7d52`), und der Review-Report hebt keinen
    Lockerungs-Befund (`cd5681ef`).
- **Drei Paarungen:** Anker — keiner gesetzt (nichts verkörpert, kein
  `liegt in`); Folge-Slice — die Übergaben oben, keine neue Kennung aus dieser
  Closure; Register — ein bestehender Eintrag mit einem Beleg ergänzt, Klasse
  bleibt *verkörpert*, kein Schwellen-Übertritt. Ergebnis: die Prüfung fährt
  die Welle-Closure (das Paarungen-Kästchen der DoD bleibt offen).

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
