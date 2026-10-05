# Slice slice-emittierte-archivierung-kennt-den-altbestand: Das Zielrepo bekommt den Schlüssel `altbestand` in Fragment, Command und E2E

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist, was das Werkzeug in ein Zielrepo schreibt
(Fragment und Command) und was den Emit-Text hält. Das Dogfood-Repo trägt dieselbe Fähigkeit über
seinen eigenen Command und sein `Makefile`; beide bleiben unberührt (§1).

**Bezug:** [`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (Festlegung 2 bis 5: der Schlüssel und die Untergrenze), [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (Festlegung 4 und 5: das Kommando im Ziel und sein Preis), [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (der Träger kommt per Tag). Auslöser: Auftrag des Auftraggebers, dasselbe Anliegen wie der Träger-Slice `slice-archive-welle-altbestand-hat-einen-schreibenden-pfad` („Hier geht es um das emittierte Teil").

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-05.

---

## 1. Ziel und Abgrenzung

**Ziel:** Ein gebootstrapptes Zielrepo nennt in `make archive-welle` und in seinem `close-welle`-Command den Schlüssel `altbestand` und die Untergrenze, an der er hängt, und ein Test hält diese Texte — heute nennt keine der emittierten Dateien den Schlüssel (`git grep -n -i 'altbestand' -- internal/emit/templates` → leer).

**Reihenfolge:** nach dem Träger-Slice `slice-archive-welle-altbestand-hat-einen-schreibenden-pfad` (Start-Trigger, §4), vor dem Release-Schnitt. Der emittierte Text wirkt erst, wenn das Zielrepo einen Träger mit dem schreibenden Pfad zieht: es pinnt ihn per Tag (`TRAEGER_TAG` in `internal/emit/templates/enforce/traeger.mk`, [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)). Bis dahin weist ein Träger den Schlüssel ohne `--vorschau` mit `[kein-schreib-pfad]` ab — der emittierte Text sagt das (L1), statt eine Fähigkeit zuzusagen, die der gepinnte Träger nicht hat.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Das Go-Unterkommando — Gegenstand des Träger-Slice `slice-archive-welle-altbestand-hat-einen-schreibenden-pfad` (Schicht-Abgrenzung: dieser Slice berührt keinen Produkt-Code unter `internal/archive/`).
- Version, `TRAEGER_TAG`, sha256-Pins und Release-Notiz (F4) — Release-Schnitt, eigener Vorgang; ohne neuen Tag gäbe es nichts, worauf der Pin zeigen könnte.
- Die Nutzerdoku (`docs/user/benutzerhandbuch.md`, Zeile `make archive-welle WELLE=<welle-id>`) — sie trägt nur den Ist-Zustand und wird im Release-Schnitt nachgezogen; vor dem Tag liefe ein Adopter mit dem gepinnten Träger in `[kein-schreib-pfad]`, die Doku sagte Falsches.
- Der Dogfood-Command `.claude/commands/close-welle.md` und `harness/sensors/archive-welle.md` §Grenze und §Sperren — der Command gehört dem Planner ([`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)), die Sensor-Doku dem Träger-Slice; beide folgen dem Vollzug, nicht diesem Slice (anderer Vorgang: Arbeit am Dogfood, nicht am Emit).
- Der Lauf des Schlüssels am gefetchten Release-Träger (E2E-Stufe `Konsumenten-Aufruf`) — der gepinnte Tag kennt den Schreibpfad nicht; erst der Release-Schnitt kann sie belegen.

## 2. Definition of Done

Liefer-Punkte:

- [ ] **L1 — Fragment und Command.** `internal/emit/templates/enforce/archivierung.mk`: der Hilfetext des Ziels (die `##`-Zeile) nennt `WELLE=<welle-id>` und `WELLE=altbestand`; der Kopfkommentar nennt, dass der Schlüssel die wellenlosen Slices unter `done/altbestand/` archiviert und dass ein Träger ohne Schreibpfad ihn mit `[kein-schreib-pfad]` abweist. `internal/emit/templates/commands/close-welle.md` Schritt 4: ohne `done/*/archiv.zip` gilt `[untergrenze]`, der Altbestand-Lauf (`make archive-welle WELLE=altbestand`) kommt vor der ersten Wellen-Archivierung; der Satz nennt den Binärnamen nicht (`TestCommands_NoInternalLeak`).
- [ ] **L2 — Emit-Tests.** Go-Tests in `internal/emit` halten die Texte aus L1; je Zusage mindestens ein Fall in `test/mutations/`.
  - (1) Rot: den Schlüssel aus der `##`-Hilfezeile streichen, während er im Kopfkommentar bleibt — der Test liest die Hilfezeile des Ziels, nicht die Datei, sonst deckt der Kommentar die Mutation.
  - (2) Rot: `altbestand` oder `untergrenze` aus `close-welle.md` streichen — der Test fällt mit Dateinamen und fehlendem Begriff.
  - (3) Rot: den `[kein-schreib-pfad]`-Satz streichen — der Test fällt.
- [ ] **L3 — E2E-Stufe im Ziel.** `archivierung_im_ziel` in `harness/tools/full-smoke.sh` fährt `make archive-welle WELLE=altbestand` über dem schon angelegten wellenlosen Slice `slice-998-ohne-welle` des temporären Ziels und erwartet `archive-welle ok: altbestand` und `done/altbestand/archiv.zip`; die Stufen-Kopfzeile nennt die neue Aussage, `make e2e-abdeckung` ist nachgeführt.
  - Der Bestand der Stufe enthält schon einen Review-Report, der auf einen verschwindenden zeigt; der Aufbau muss `[haenger]` vor dem Altbestand-Lauf auflösen, sonst sperrt der Lauf (`haenger` bleibt unter dem Schlüssel Sperre).

Fahrbar ohne Docker-E2E und ohne realen Bestand: L1 und L2 vollständig (`make test`, `MUTATE_CASES=<Fälle> make mutate`; `internal/emit` ist ein Go-Test über den Emit-Text). Nicht fahrbar: L3 (`make full-smoke` braucht Docker) und jede Aussage über einen realen Bestand — ein Altbestand im gebootstrappten Ziel entsteht nicht von selbst, die Stufe baut ihn synthetisch. Die Lücken stehen in der Closure-Notiz, nicht verdeckt durch den Fixture-Erfolg (AGENTS.md §3.6):

- Der Text-Test (L2) hält den Wortlaut der Vorlage, nicht dass `make` im Ziel den Schlüssel an den Träger reicht; das misst allein L3 — kein Go-Test fährt `make`.
- L3 läuft gegen den Träger, den die Stufe aus dem Arbeitsbaum baut, nicht gegen den gepinnten Release-Träger; ob dessen Tag den Schreibpfad trägt, misst erst der Release-Schnitt.
- Rot-Beleg L3: den Schlüssel im `make`-Aufruf der Stufe vertippen (`WELLE=altbestandd`) — die Stufe muss mit der Ausgabe des Trägers rot werden, nicht an einer anderen Sperre.

Gate-Läufe und Closure-Pflichten:

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Doku-Update: `docs/user/e2e-abdeckung.md` neu erzeugt (L3); die Nutzerdoku bleibt dem Release-Schnitt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen, von der nächsten Welle-Closure auch für diesen wellenlosen Slice.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/archivierung.mk` | update | Hilfezeile und Kopfkommentar nennen den Schlüssel (L1) |
| `internal/emit/templates/commands/close-welle.md` | update | Untergrenze und Altbestand-Lauf vor der ersten Wellen-Archivierung (L1); `implement-slice.md` beschreibt die Closure nicht für die Archivierung und bleibt (Zeile zu `make archive-welle` betrifft nur die Commit-Kennung) |
| `internal/emit/archivierung_test.go`, `internal/emit/commands_test.go` | update | Texttests nach L2 (1)–(3) |
| `test/mutations/` | neu | je ein Fall pro Zusage aus L2; Anker gegen den Quell-Bestand messen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)) |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | Stufe `archivierung_im_ziel` und erzeugte Abdeckungs-Sicht (L3) |

## 4. Trigger

**Start** (`next` → `in-progress`): der Träger-Slice `slice-archive-welle-altbestand-hat-einen-schreibenden-pfad` liegt in `done/`; erst dann baut die Stufe aus L3 einen Träger, der den Schlüssel schreibt. `open → next` durch Priorisierung des Auftraggebers.

**Rückführungen:**

- `in-progress` → `next`: die Stufe braucht einen Eingriff in `internal/archive/` (dann ist der Schnitt falsch).
- `in-progress` → `open`: der Träger-Slice ändert Schlüssel, Meldung oder Sperren, an denen L1 bis L3 hängen.

## 5. Closure-Trigger

DoD vollständig, Review-Report ohne blockierenden Befund, Closure-Notiz mit Lerneintrag; `make gates` grün auf dem Stand des Abschlusses. Der Release-Schnitt (F4) folgt als eigener Vorgang: er hebt `TRAEGER_TAG` samt Digests, zieht das Benutzerhandbuch nach und macht den emittierten Text wirksam.

## 6. Risiken und offene Punkte

- Zwischen diesem Slice und dem Release-Schnitt nennt die Emission einen Schlüssel, den der gepinnte Träger nur als Vorschau kennt — **Ausgang:** weiter offen: → [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) (Milderung: der Text nennt `[kein-schreib-pfad]`, L1)
- Die Stufe baut ihren Altbestand synthetisch und trifft das Zielrepo eines Adopters mit gewachsenem Bestand nicht — **Ausgang:** weiter offen: → [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)
- Der Träger-Slice ändert die Ausgabe-Zeile `archive-welle ok: altbestand`, auf die L3 prüft — **Ausgang:** entfallen, solange der Träger-Slice nicht ändert; geschieht es, ist es eingetreten und führt `in-progress` → `open` (§4)

## 7. Closure-Notiz

- **Was hat funktioniert:**
- **Was ging anders als geplant:**
- **Steering-Loop-Eintrag:**
- **Beobachtungs-Register (`../observations/`):**
- **Folge-Slices:** Release-Schnitt (F4) — eigener Vorgang, noch keine Datei
- **Risiken aus §6:**
- **Drei Paarungen:**

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`); die Modus-Deklaration führt keine feinere Sub-Area für `internal/emit/`.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer (Zähler = Zahl der Dateien unter `evidence/` des Eintrags, `ls <eintrag>/evidence | wc -l`; Stand je `state.md`):
- [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) (Dogfood-gegen-emittiert; berührt über das Fenster zwischen Slice und Release),
- [`BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus`](../observations/BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus/observation.md) (offen; hier läuft der Dogfood-Command dem Emit voraus, nicht umgekehrt, die Richtung ist die ungewächterte),
- [`BEO-ALL/anweisungssatz-nachzug-ohne-waechter`](../observations/BEO-ALL/anweisungssatz-nachzug-ohne-waechter/observation.md) (der Command-Text wird von Hand nachgezogen; L2 (2) wächtert den Begriff, nicht die Abschrift),
- [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md), [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md), [`BEO-ALL/mutations-fall-deckt-den-lauten-statt-den-stillen-pfad`](../observations/BEO-ALL/mutations-fall-deckt-den-lauten-statt-den-stillen-pfad/observation.md) (die DoD verlangt Fälle; der Fall zu L2 (1) muss die Hilfezeile treffen, nicht den Kommentar daneben).
Der Slice hebt keinen Eintrag mit Sicherheit auf 3×; ein Beleg ist erst in der Closure zu setzen.

alle berührten Sub-Areas GF
