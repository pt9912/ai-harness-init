# Slice slice-macos-als-host-plattform-wird-entschieden-und-vollzogen: macOS als Host-Plattform wird entschieden und vollzogen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** ohne Welle

**Bezug:** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Host braucht nur `git`, `docker`, GNU `make`), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Reproduzierbarkeit), `AGENTS.md` §3.9.

**Berührte Spec-Stellen:** — (die Aussage bleibt unter [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) und [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), Vertrag unverändert; Träger ist die Hard Rule `AGENTS.md` §3.9).

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-20.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Auftraggeber-Entscheidung **Option B** ist vollzogen: macOS ist ausdrücklich **nicht** getragene Host-Plattform der Host-Läufer (`make mutate`, `make mutate-auswahl`, `make mutate-greift`, `make full-smoke`). Linux ist der Host dieser Läufer, CI der Beleg-Ort. Die bekannten Umwege (GNU-`sed` im `PATH`, `make artifact-host` / `make full-smoke-host`) bleiben als dokumentierte Hilfen stehen — ohne Anspruch.

**Option A verworfen** (Auftraggeber): Läufer auf macOS reparieren (762 Fall-Skripte, mehrere Läufer) ist ein großer Eingriff ohne Mac-CI, der ungewacht bliebe; klein und ehrlich statt groß und unbelegt.

**Schichten:** Doku-/Harness-Texte, höchstens zwei, kein Produkt-Code.

**Wer schreibt was.**

- **Architect** (Übergabe-Artefakt dieses Plans; eigener Commit, nur Architect-Artefakte, Rolle in der Message, `AGENTS.md` §3.8): die Plattform-Aussage als Norm — eine Ergänzung der Hard Rule `AGENTS.md` §3.9 (Docker-only): Host der Host-Läufer ist Linux, macOS ist dafür nicht getragen, Beleg-Ort CI; dazu der Auflösungs-Trigger oder *permanent* (`modul-13-quality-gates.md` §Hard Rule). Ob dazu ein Eintrag im Adaptions-Block nötig ist (Ergänzung ohne Einschränkung der Baseline ist keine Adaption, vgl. [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage)), entscheidet der Architect. Der Commit liegt **vor** der Implementer-Arbeit, damit deren Texte auf eine vorhandene Norm zeigen.
- **Implementer** (Nicht-Norm-Texte; zeigt auf die Hard Rule, schreibt sie nicht ab): `harness/README.md` (Zeilen der betroffenen Targets in §Werkzeuge), `harness/sensors/mutate.md`, `harness/sensors/full-smoke.md`, und `docs/user/*`, soweit dort ein Host-Lauf dieser Läufer beschrieben ist (`grep -rn 'artifact-host\|full-smoke-host\|gnubin' docs/user harness/` nennt die Stellen). Inhalt: Linux als Host, CI als Beleg-Ort, Umwege als Hilfe ohne Anspruch.

**Verhältnis zum Lastenheft.** [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (Bootstrap-Laufzeit braucht nur git + docker) und [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (Produkt-Binary erstklassig auf linux/macos/windows) betreffen das **Produkt**; die Aussage hier betrifft die **Dogfood-Läufer dieses Repos** und bleibt darunter. Der Vertrag ändert sich nicht, kein Change Request ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)/[`MR-036`](../../../../harness/conventions.md#mr-036--die-change-request-regel-bei-personalunion-steht-jetzt-in-der-adoptierten-baseline)). Die Doku-Texte benennen die Trennung (Produkt-Binary läuft auf macOS, die Host-Läufer des Dogfoods nicht), damit [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) nicht als widersprochen gelesen wird.

**Ausdrücklich NICHT in diesem Slice:**

- Reparatur der Läufer auf macOS (Option A) — verworfen, siehe oben.
- Eine ADR: die Aussage nimmt einen Anspruch zurück statt ein Gate zu senken (`AGENTS.md` §3.5); ob der Auftraggeber dennoch eine ADR will, ist offen und seine Entscheidung ([`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)), kein Teil dieses Plans.
- Mount-Verzögerung und Host-Konfiguration (`BEO-ALL/bind-mount-sicht-auf-umgeschriebene-dateien-ist-unter-macos-verzoegert`, `BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus`) — anderer Mechanismus, eigener Eintrag.

## 2. Definition of Done

- [x] Die Plattform-Aussage steht als Norm in `AGENTS.md` §3.9 (Architect-Commit, vor der Implementer-Arbeit).
- [x] Linux-als-Host, CI-als-Beleg-Ort und die Umwege-ohne-Anspruch stehen in `harness/README.md`, `harness/sensors/mutate.md`, `harness/sensors/full-smoke.md` und den betroffenen `docs/user/*`; die Trennung von Produkt-Binary ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)) und Dogfood-Läufern steht dabei.
- [x] `make gates` grün — lokal bestätigt; der Beleg-Ort im Sinne der Norm, CI auf frischem Klon, liegt nach dem Push (§7).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — geprüft nach dem `git mv` (§7).

Closure (Planner, §3.10): Review und Verifikation durchgeführt; Closure-Notiz §7 mit Steering-Loop-Lerneintrag und der Zeile `Entscheidung: B`; Beobachtungs-Register `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` auf *verkörpert* (Zielort `AGENTS.md` §3.9); die drei Paarungen getragen.

## 3. Plan (vor Code)

Der Implementer erweitert den Plan um die Dateiliste nach dem Architect-Commit; Reihenfolge: Architect-Norm, dann die Doku-Stellen, dann Gates.

Dateiliste (Fundstellen: `git grep -nE 'macOS|Darwin|BSD|artifact-host|full-smoke-host|gnu-sed' -- harness/ docs/user/ README.md`):

- `harness/README.md`: Bindung-Zellen der Zeilen `make mutate`, `make mutate-auswahl`, `make mutate-greift`, `make full-smoke`, `make artifact-host`, `make full-smoke-host`.
- `harness/sensors/mutate.md`, `harness/sensors/full-smoke.md`, `harness/sensors/artifact-host.md`: je ein Absatz.
- `docs/user/*`: unverändert — keine Stelle bietet einen macOS-Lauf der vier Läufer als Beleg an; `docs/user/benutzerhandbuch.md` nennt den vollständigen Durchlauf bereits auf Linux/Intel-AMD, macOS nur für das Programm.

## 4. Trigger

**Start** (`next` → `in-progress`): die Auftraggeber-Entscheidung liegt vor (B, entschieden).

- `in-progress` → `next`: der Architect verlangt eine ADR oder einen Change Request — dann zurück, bis der Auftraggeber entschieden hat.
- `in-progress` → `open`: die Entscheidung wird zurückgenommen.

## 5. Closure-Trigger

DoD vollständig, Closure-Notiz mit Lerneintrag geschrieben, Register-Ausgang auf *verkörpert* mit Zielort.

## 6. Risiken und offene Punkte

- Eine Plattform-Aussage ohne Wächter: kein Sensor hält die Doku-Zeilen gegen die Läufer — **Ausgang:** weiter offen: → `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` im Register

## 7. Closure-Notiz

- **Entscheidung: B** (Auftraggeber): macOS ist nicht getragene Host-Plattform der Host-Läufer; Linux ist ihr Host, CI der Beleg-Ort. Option A (Läufer auf macOS reparieren) verworfen: ein großer Eingriff über 762 Fall-Skripte und mehrere Läufer ohne Mac-CI, der ungewacht bliebe; klein und ehrlich statt groß und unbelegt.
- **Was hat funktioniert:** Norm vor der Arbeit: `AGENTS.md` §3.9 trägt den Absatz (Architect-Commit `2634a855`, kein `MR` — Ergänzung ohne Einschränkung der Baseline, [`MR-000`](../../../../harness/conventions.md#mr-000); keine ADR — kein Gate gesenkt, `AGENTS.md` §3.5; kein Change Request — die Aussage liegt unter [`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) und [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)). Die Doku-Stellen zeigen auf die Norm (`harness/README.md`, `harness/sensors/mutate.md`, `full-smoke.md`, `artifact-host.md`); `docs/user/*` blieb unverändert, weil keine Stelle einen macOS-Lauf der vier Läufer als Beleg anbietet. Review: 0 HIGH, 0 MEDIUM, 1 LOW (`artifact-host.md` nannte eine Plattform-Liste als vorgesehenen Einsatz, behoben in `da389393`), 3 INFO ([Report](../../../reviews/2026-10-20-slice-macos-als-host-plattform-wird-entschieden-und-vollzogen.md)). Verifier: DoD 1 und 2 bestätigt, DoD 3 lokal bestätigt ([Report](../../../reviews/2026-10-20-slice-macos-als-host-plattform-wird-entschieden-und-vollzogen-verify.md)).
- **Was ging anders als geplant:** die Makefile-Hilfezeile von `artifact-host` und der Kommentar darüber nennen Nicht-Linux-Hosts als Einsatz und stehen in Spannung zur Norm; sie liegen außerhalb der Dateiliste in §3 und gehen als Folge-Slice weiter (unten).
- **DoD 3 und der CI-Beleg:** `make gates` ist lokal grün (Stempel auf dem Stand der Closure). Dass die Norm den Beleg-Ort **CI auf frischem Klon** nennt, heißt: dieser Beleg steht aus, solange nichts gepusht ist. Es liegt hier **kein** CI-Lauf vor, und diese Notiz behauptet keinen; den CI-Lauf nach dem Push liest der Hauptkontext und liefert ihn nach.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** keine neue Laufzeit- oder Kosten-Aussage; die einzige Zahl, 762 Fall-Skripte, steht neben ihrem Kommando in `test/mutations/` und ist der Zähler des Plans.
- **Steering-Loop-Eintrag:** **geschärfte Regel** — der Absatz zu den Host-Läufern in `AGENTS.md` §3.9 ergänzt: Host der Läufer ist Linux, macOS nicht getragen, Umwege ohne Anspruch, mit Auflösungs-Trigger (nicht *permanent*) — liegt in `AGENTS.md §3.9`. Auslöser: `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` (7 Vorgänge, Ausgang *verkörpert*, `state.md` nachgezogen; die vier Einzel-Einträge behalten ihren Verweis). **Benannte Lücke:** der Absatz ist eine Deklaration ohne Sensor; kein Test weist einen Läufer auf einem Nicht-Linux-Host ab oder hält die Doku-Zeilen gegen die Norm, ein rotes Gegenbeispiel gibt es nicht. Träger ist die Doku der Läufer, die auf die Norm zeigt.
- **Trigger-Audit dieser Closure:** der neue Absatz in `AGENTS.md` §3.9 trägt den Auflösungs-Trigger *macOS wird getragen, sobald eine macOS-CI die Läufer hält oder der Auftraggeber es entscheidet; dann entfällt der Absatz als DoD-Punkt des auslösenden Slice* — **nicht eingetreten**: keine macOS-CI, keine Entscheidung. `CO-001` und `CO-002` unberührt; kein bootstrap-aware Gate berührt; keine ADR mit Re-Evaluierungs-Trigger berührt; die übrigen Hard Rules tragen *permanent* oder ihren Trigger unverändert. Nichts fällig.
- **Rückbau-Fundstellen:** entfällt der Absatz, sind die Doku-Texte mit `git grep -nE 'Host Linux, macOS nicht getragen|Hilfe ohne Anspruch' -- harness/ docs/ ':!docs/reviews'` auffindbar (heute `harness/README.md`, `harness/sensors/artifact-host.md`, `mutate.md`, `full-smoke.md`; die Norm nennt keine Rückbau-Liste, das Kommando liefert sie). Gemessen am Stand dieser Closure, kein Erwartungswert.
- **Beobachtungs-Register (`../observations/`):** `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` auf *verkörpert* fortgeschrieben, kein neuer Beleg; keine weitere Beobachtung angefallen.
- **Folge-Slices:** `slice-makefile-hilfe-artifact-host-nennt-keine-nicht-linux-hosts` (Hilfezeile und Kommentar von `artifact-host` im `Makefile`) — ist eine Datei in `open/`.
- **Archivierung ([`MR-078`](../../../../harness/conventions.md#mr-078)):** nicht ausgeführt: `ls docs/plan/planning/done/*/archiv.zip` findet keines, `archive-welle` bricht an der Untergrenze (`[untergrenze]`); der Slice bleibt flach in `done/`. Ob `[haenger]` zusätzlich greift, ist nicht gemessen.
- **Risiken aus §6:** das eine Risiko (*Plattform-Aussage ohne Wächter*) hat seinen Ausgang in §6, *weiter offen*; `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` trägt den Stand als *verkörpert* mit der benannten Grenze, die Lücke bleibt damit benannt statt geschlossen.
- **Drei Paarungen:** werden nach dem `git mv` geprüft, Ergebnis im Commit danach.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), eine Sub-Area, GF.

**Vorgelagert — offene Beobachtungen sichten:** Treffer `BEO-ALL/host-werkzeug-variante-auf-macos-bricht-die-host-laeufer` (7 Vorgänge, über der Schwelle, Ausgang *geplant* auf diesen Slice) und die vier Einzel-Einträge.

Alle berührten Sub-Areas GF.
