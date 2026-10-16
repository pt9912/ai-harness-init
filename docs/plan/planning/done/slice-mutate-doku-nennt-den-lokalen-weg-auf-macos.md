# Slice slice-mutate-doku-nennt-den-lokalen-weg-auf-macos: Die Treiber-Doku von `make mutate` nennt den lokalen Weg auf einem Nicht-Linux-Host

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — reaktiv (Register-Ausgang *geplant* bei 3×), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (ein Beleg ist wiederholbar, wenn sein Aufruf dasteht), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** —.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) nennt den Aufruf, mit dem ein `# verify: full-smoke`-Fall auf einem Nicht-Linux-Host lokal läuft (`SMOKE_ARTIFACT_TARGET=artifact-host`), samt seiner Grenze; der Kopf von Fall 171 nennt den richtigen Halter der Feldlisten-Ablage.

Anlass: der Ausgang *geplant* von `BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host` (3×). Die Fälle 305 und 171 wurden lokal nur über diese Variable gemessen; sie steht in keiner Doku (`grep -rn SMOKE_ARTIFACT_TARGET docs harness/README.md harness/sensors Makefile` trifft allein `Makefile`). Der Kopf von Fall 171 nennt „die Fälle 614 und 615“ als Halter der Stufe für die Feldlisten-Ablage; 614 mutiert `docs/plan/carveouts` (`.gitkeep`), nur Fall 615 die Feldliste (`internal/emit/enforce.go`) — beide halten dieselbe Stufe, 614 nicht für diesen Pfad (Verifikation zu Slice 305/171, F-1; Beleg für `BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein eigenes Make-Ziel `mutate-host` oder eine Änderung an `harness/tools/mutate.sh`.** Anderer Vorgang (Werkzeug statt Doku) und eine Entscheidung über den Treiber; die Doku beschreibt den vorhandenen Durchreich-Weg.
- **Die Docker-Tag-Kollision paralleler Worker.** Anderer Gegenstand: `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers`.
- **Weitere Köpfe.** Bestand bleibt bewusst stehen; gefasst wird allein der Kopf von Fall 171, den die Verifikation benannt hat.

## 2. Definition of Done

- [x] `harness/sensors/mutate.md` nennt den Aufruf `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=<voller Fallname> make mutate` für Fälle mit `# verify: full-smoke` auf einem Nicht-Linux-Host und seine Grenzen: nur Einzel-Fälle gemessen; `MUTATE_CASES` verlangt den vollen Fallnamen (mehrere Fälle durch Leerzeichen getrennt); der Grün-Vorlauf dauert je Fall Größenordnung 100–220 s (der Implementer belegt die Zahl am Aufruf); der Aufruf ist am Fall 305 einmal gefahren und sein Ausgang (`ok`) im Slice §7 genannt. **Bestätigt mit Grenze:** macOS mit Colima, Homebrew-`gnu-sed` im `PATH`, Einzel-Fälle; Fall 305 vom Verifier mit der Variable gefahren (`ok`), Fall 171 vom Implementer.
- [x] Der Kopf von `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh` nennt Fall 615 allein statt „614 und 615“ als Halter der Feldlisten-Ablage; `make mutate-greift` bleibt grün.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update für `harness/sensors/mutate.md` (öffentlicher Vertrag des Treibers berührt).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert; der Stand von `BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host` trägt den Beleg dieses Slice als Verkörperung.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/sensors/mutate.md` | update | der lokale Weg für `# verify: full-smoke`-Fälle auf Nicht-Linux-Hosts |
| `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh` | update | Kopf nennt 615 statt 614 |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; WIP-Limit frei. Reihenfolge nach `slice-span-sperre-haelt-den-test-unter-last`. **Erfüllter Zustand:** der Vorgänger `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log` liegt in `done/` (Beleg: `ls docs/plan/planning/done/slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log.md`), `in-progress/` trägt danach nur `roadmap.md` (`ls docs/plan/planning/in-progress/`), WIP-Limit frei; `Verantwortlich:` gesetzt.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Doku zusätzlich ein Werkzeug (Make-Ziel) verlangt.
- `in-progress` → `open` (blockiert): wenn der Aufruf auf dem Host auch in Einzelläufen nicht trägt — dann benennt der Slice die Grenze und gibt die Beobachtung zurück.

## 5. Closure-Trigger

DoD vollständig; der in der Doku genannte Aufruf ist einmal gefahren; Review ohne blockierenden Befund; Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Der genannte Aufruf trägt nur für Einzel-Fälle, nicht für einen Mehrfach-Lauf — **Ausgang:** weiter offen → `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers`.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-16

- **Was hat funktioniert:** Gebaut ist in `harness/sensors/mutate.md` der Abschnitt *Lokaler Weg für `# verify: full-smoke`-Fälle auf macOS*: der Aufruf `SMOKE_ARTIFACT_TARGET=artifact-host MUTATE_CASES=<voller Fallname> make mutate`, die Voraussetzung GNU-`sed` vor BSD-`sed` im `PATH` und die Grenzen; der Kopf von Fall 171 nennt Fall 615 allein (Mutation unverändert). Review (`df43234b`): 0 HIGH, 0 MEDIUM, 2 LOW, 2 INFO; beide LOW im Implementer-Commit `c1ef5472` behoben (Rahmen macOS mit Colima, Kollisions-Satz als übernommen statt gemessen). Verifikation (`…-verify`, HEAD `c1ef5472`): D1 eingeschränkt durch F-1 (MEDIUM), D2 bis D4 erfüllt; F-1 im Implementer-Commit `4cc462a4` behoben. **Gemessen:** Fall 305 vom Verifier mit der Variable gefahren: `ok 305-… -> FEHLER — Rollen-Typ fehlt rot`, 140 s Wanduhr (Grün-Vorlauf 110,9 s, Fall 9,4 s); ohne die Variable Abbruch nach 20 s, Exit 2, `cannot execute binary file: Exec format error` (Exit 126); `MUTATE_CASES` mit Komma meldet „unbekannter Fall“; Fall 171 vom Implementer gefahren (194 s, Grün-Vorlauf 157 s); `make mutate-greift` mit GNU-`sed` 653/653, ohne `653 Fälle, 7 greifen, 646 Befunde`; `make gates` grün, Stempel == HEAD.
- **Was ging anders als geplant:** **(1) D1 trägt mit Grenze:** der Aufruf-Block reproduzierte auf einem frischen macOS-Host zunächst nicht (F-1), weil der Implementer mit GNU-`sed` im `PATH` maß, ohne es zu nennen; BSD-`sed` bricht die Fall-Skripte. Der Abschnitt nennt es jetzt als Voraussetzung. Das Häkchen gilt für macOS mit Colima, Homebrew-`gnu-sed` (andere Installationswege ungemessen) und Einzel-Fälle. Die Zeile *„Mutations-Skript scheiterte … 0 ok, 1 Befund(e)“* für `make mutate` ist aus dem Verifier-Report übernommen, vom Implementer nicht selbst gemessen. **(2) Der Beleg-Fall:** der DoD nennt Fall 305, der Implementer fuhr 171; der Verifier fuhr 305 mit Variable (`ok`) — der DoD-Wortlaut ist damit durch dessen Lauf belegt, der Planner hat nicht wiederholt, und der ursprüngliche Befund „171 statt 305“ ist erledigt. **(3) Neuer Fund im Implementer-Lauf:** der Treiber braucht Bash ≥ 4 (`local -A`, Zeile ~910; mit der Bash 3.2 des Systems vor dem Homebrew-Bash bricht er dort); gemessen ist nur diese Zeile, `mutate.md` nennt die Voraussetzung nicht, und der Slice baut sie nicht ein (anderer Vorgang als die Doku des Weges). **Nicht belegt und so geführt:** Linux/arm64, Linux/amd64, Windows; Mehr-Fall-Läufe (Tag-Kollision übernommen, nicht neu gemessen); Fall 171 nicht vom Verifier gefahren; `make mutate-auswahl` und der CI-Branch nicht gefahren; andere GNU-`sed`-Installationswege; weitere Bash-4-Stellen. **Es gibt keinen Wächter für Doku-Aussagen dieser Art** — keine Prüfung liest den Aufruf des Abschnitts gegen Treiber oder `Makefile` (`mutate.md` sagt es selbst); Träger ist der Lauf, der schreibt.
- **Steering-Loop-Eintrag:** **geschärfte Regel nur als Beobachtung, mit benannter Grenze:** der Aufruf-Block trug eine Messumgebung (GNU-`sed` im `PATH`), die nicht Teil der Zusage war — dritter Beleg der Klasse `BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus` (`slice-stilllegungs-form-hat-einen-waechter`, `slice-stilllegungs-kanten-sind-gemessen`, `slice-mutate-doku-nennt-den-lokalen-weg-auf-macos` — 3×). Ausgang *geplant*, nicht verkörpert (kein Zielort-Feld): `slice-mess-rezept-nennt-seine-host-voraussetzungen`. **Kein Beleg** für `BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst` (bleibt 3×, geplant): dort nennt die Doku einen Test als Halter, den der Fall nur zum Teil misst; hier steht kein Test als Halter, der Fehler liegt in der Umgebung der Messung.
- **Beobachtungs-Register (`../observations/`):**
  - Beleg ergänzt: `evidence/slice-mutate-doku-nennt-den-lokalen-weg-auf-macos.md` in `BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/` — Zähler steht damit bei 3×; `state.md` trägt `geplant` mit der Kennung des Folge-Slice.
  - Neu: [`BEO-ALL/mutate-treiber-braucht-bash-4-und-bricht-auf-macos-bash-32`](../observations/BEO-ALL/mutate-treiber-braucht-bash-4-und-bricht-auf-macos-bash-32/observation.md) — 1 Beleg, `offen`. Kein bestehender Eintrag deckt den Gegenstand: `BEO-ALL/mutate-auswahl-paste-ohne-operand-bricht-auf-bsd` (1×) ist der Nachbar mit anderem Werkzeug und steht in der `observation.md`; ein Beleg dort wäre eine Umdeutung seiner unveränderlichen Identität, und ein Lese-Schritt kann beide später zusammenführen. Ein Vorgang zählt einmal: der GNU-`sed`-Fund und der Bash-Fund stehen je in ihrem Eintrag, nicht doppelt im selben.
  - Ausgang gesetzt: `BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host` von *geplant* auf **verkörpert** — Zielort `harness/sensors/mutate.md` §Lokaler Weg …, Herkunft `seit slice-mutate-doku-nennt-den-lokalen-weg-auf-macos`. Der Anker steht in `state.md`, **nicht** an der Überschrift des Zielorts (der Abschluss berührt die Sensor-Datei nicht, `AGENTS.md` §3.10), und die Closure-Notiz trägt kein `liegt in`: die Anker-Paarung hat hier nichts zu paaren. Verkörpert ist der Weg, nicht die Behebung; die Grenze steht in `state.md`. **Kein neuer Beleg** dort: dieser Slice löst die Beobachtung, er ist kein weiteres Auftreten; und BSD-`sed` ist eine andere Ursache als das Linux-Binary (die Ablage nennt sie im Absatz der GNU-Werkzeuge von `mutate.md`).
  - **Kein Beleg:** `BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle` (bleibt 2×, offen) — der Fund (Kopf Fall 171 nennt 614 und 615) steht schon als Beleg des Vorgängers `slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke`; dieser Slice behebt ihn, und ein Vorgang zählt einmal. Die Vorhersage in §8, er wäre der dritte Beleg, trifft nicht zu. `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers` (bleibt 1×) — nicht aufgetreten.
- **Folge-Slices:** `slice-mess-rezept-nennt-seine-host-voraussetzungen` (Architect-Verdikt zur Klasse) — ist eine Datei in `open/`. `slice-doku-zusage-nennt-den-test-nur-fuer-das-was-er-misst` bleibt in `open/`, nicht gestartet: er braucht ein Architect-Verdikt und die Priorisierung des Auftraggebers.
- **Risiken aus §6:** Mehr-Fall-Lauf nicht zugesagt — weiter offen → `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers` (der Slice hat ihn weder gefahren noch widerlegt).
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR-Re-Evaluierungs-Trigger: keiner berührt. Hard Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Drei Paarungen:** nach dem `git mv` (siehe unten).
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice` ist nicht gebaut).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer: [`BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md) (3×, geplant — dieser Slice); [`BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle`](../observations/BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle/observation.md) (2×, offen — dieser Slice wäre der dritte Beleg und löste den Lese-Schritt aus).

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
