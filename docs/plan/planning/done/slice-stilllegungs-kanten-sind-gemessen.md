# Slice slice-stilllegungs-kanten-sind-gemessen: Ob Werkzeug und Doku-Gate die Kanten `open → done` und `next → done` tragen, ist gemessen, und jede Lücke hat eine Adresse

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht fällt negativ aus: Die Messung hat keine Closure-Bedingung, die
mehr beobachtet als ihre DoD. Nach [`MR-037`](../../../../harness/conventions.md#mr-037) steht
wellenlose Arbeit nicht in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood.** Gegenstand sind zwei Werkzeuge dieses Repos — `make slice-mv` und
`make docs-check` mit dem gepinnten d-check — und die Sensor-Dateien, die ihre Grenzen führen. Was
ein emittiertes Repo bekommt, berührt der Slice nicht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (was
ein Werkzeug trägt, ist erst mit Messung eine Aussage),
[`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (§Was diese Festlegung
nicht tut: *„Ob die Planungs-Werkzeuge und das Doku-Gate diese Kanten tragen, ist hier nicht
gemessen."*),
[`ADR-0018`](../../adr/0018-ziel-fassung-regiert-die-migration.md) (Festlegung 2 — gemessen wird
gegen den Ist-Maßstab, und der ist nach dem Tausch `v6.9.0`),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (`make archive-welle`,
ausgeschlossen in §1),
[`MR-025`](../../../../harness/conventions.md#mr-025) und
[`MR-033`](../../../../harness/conventions.md#mr-033) (die Messung nennt ihr Kommando und den
Stand, gegen den sie läuft).

**Berührte Spec-Stellen:** — (der Slice misst Werkzeuge und schreibt Sensor-Dateien).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-16.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Für beide Kanten und beide Werkzeuge ist an einer Wegwerf-Kopie außerhalb des Repos
gemessen, ob `make slice-mv` den Übergang ausführt und seine Verweise nachzieht und ob
`make docs-check` einen so geschlossenen Slice in der Form der Ziel-Fassung grün lässt. Jede
Kante, die ein Werkzeug nicht trägt, hat eine Adresse, bevor ein Slice dieses Repos sie nimmt.

**Maßstab** ist der vendorte Stand `v6.9.0`: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ein Slice, dessen Gegenstand ein anderer übernimmt, und die Slice-Vorlage desselben Stands. Die
Liefer-Punkte der DoD bleiben leer, §7 trägt die Zeile `Gegenstand:`, und jedes Risiko hat einen
Ausgang. Der vendorte Baum führt diese Form erst nach `slice-sprung-auf-v690-wird-vollzogen`
(§4).

**Warum ein eigener Slice.** Im Sprung-Slice wäre die Messung ein vierter Liefer-Punkt, und sie
ist Arbeit am Werkzeug, nicht am Gegenstand. Als Risiko mit Ausgang käme sie zu spät: Ein Ausgang
fällt bei der Closure, die Messung muss aber vor der Gruppierung stehen, die der Auftraggeber an
den Sprung anschließt. Als eigener Slice hat sie eine Kennung, auf die der Sprung-Slice zeigt und
die Gruppierung warten kann.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Baum-Tausch.** *Ein anderer Slice übernimmt ihn:* `slice-sprung-auf-v690-wird-vollzogen`.
  Dieser Slice beginnt erst danach (§4).
- **Die Anwendung der Kanten, also die Gruppierung offener Slices.** *Anderer Vorgang:* Dieser
  Slice misst Werkzeuge, die Gruppierung arbeitet am Gegenstand und setzt diese Messung voraus.
  [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) entscheidet die Anwendung
  nicht.
- **Die Behebung einer gefundenen Lücke.** *Anderer Vorgang:* Eine Werkzeug-Änderung trägt eine
  eigene Zusage mit rot gesehenem Gegenbeispiel ([`AGENTS.md`](../../../../AGENTS.md) §3.6);
  Liefer-Punkt 3 gibt der Lücke eine Adresse. Liegt sie im gepinnten d-check, ist die Adresse
  eine Anforderung an dessen Repo — *Schicht-Abgrenzung*, das Werkzeug gehört nicht diesem Repo.
- **Ein Wächter, der die zwei Kanten dauerhaft hält.** *Ein Folge-Slice übernimmt ihn:*
  `slice-mv-kanten-nach-done-sind-bewacht`, im Dogfood und im gebootstrappten Ziel. Gesetzt vom
  Planner nach Review-Befund F-2. Die Messung aus Liefer-Punkt 3 ist darum eine Messung und keine
  bewachte Zusage. Vor der Gruppierung muss der Wächter nicht stehen, weil der Lauf, der die Kanten
  nimmt, je Wechsel Exit-Code, reinen Rename und `make docs-check` prüft. Die Begründung steht in
  §1 des Folge-Slice.
- **Die Stub-Zeile `Hervorgegangen:` in `make archive-welle`.** *Anderer Vorgang:* Die
  Ziel-Fassung verlangt sie, wenn eine Welle einen Geber archiviert, und dieses Repo hat noch
  keine Welle archiviert (`git ls-files 'docs/plan/planning/done/**/*.zip'` → leer, kein
  Erwartungswert). Vor der Gruppierung wird sie nicht gebraucht.
- **Die Entscheidung, ob dieses Repo die Kanten nimmt.** *Anderer Vorgang einer anderen Rolle:*
  Die Messung sagt, ob die Werkzeuge die Kanten tragen, nicht, ob sie genommen werden.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **1 — `make slice-mv` ist für beide Kanten gemessen.** Je ein Slice aus `open/` und einer
      aus `next/` gehen mit `TO=done`, auf einer Wegwerf-Kopie außerhalb des Repos, in der das
      Werkzeug committen darf. Festgehalten sind je Kante Exit-Code und Ausgabe, ob der Move rein
      bleibt, ob eingehende Verweise nachgezogen werden und ob ausgehende Verweise auf Geschwister
      im alten Verzeichnis ihr Präfix bekommen
      ([`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze).
      **Beide Kanten, nicht eine** (§8, `zusage-nennt-zwei-kanten-der-sensor-deckt-eine`).
      **Beleg:** [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze,
      Abschnitt *Kanten `open → done` und `next → done`*, gemessen am Stand `004335cc` des Skripts
      (`git log -1 --format=%h -- harness/tools/slice-mv.sh`). Jede Kante ist in zwei Kontexten
      gemessen, und die Werte stimmen überein (Verifikation vom 2026-09-17, §1 und §2).
- [x] **2 — `make docs-check` ist über einem Stand gemessen, in dem je Kante ein Slice in der
      Form der Ziel-Fassung in `done/` liegt:** leere Liefer-Punkte, §7 mit `Gegenstand:`,
      Risiken mit Ausgang. Gelesen ist jede Meldung samt Grund-Code, nicht nur der Exit —
      namentlich `closure-note-thin` und `closure-note-placeholder` der Fähigkeit `closure`
      ([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul
      `planning`). Dazu das Gegenbeispiel: derselbe Slice **ohne** `Gegenstand:`-Zeile. Meldet
      dann kein Modul, ist das eine Grenze und wird so benannt; die Ziel-Fassung sagt selbst, dass
      kein Link-Sensor die Kennung als Token prüft. Die Messung nennt den Digest des gepinnten
      d-check, gegen den sie läuft (§8, `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`).
      **Beleg:** [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)
      §Grenze, Abschnitt *Ein stillgelegter Slice in `done/`*, gemessen gegen den Digest
      `e31a372b…`, den `grep -n DCHECK_DIGEST d-check.mk` nennt. Das Gegenbeispiel ohne
      `Gegenstand:` bleibt still und steht als Lücke mit Adresse da. `closure-note-thin` und
      `closure-note-placeholder` sind rot gesehen und gelesen (Verifikation §1 und §2).
- [x] **3 — Jede Kante hat ihren Ausgang an dem Ort, den der nächste Lauf liest.** Trägt ein
      Werkzeug die Kante, steht das als gemessene Eigenschaft mit Kommando in seiner Sensor-Datei
      ([`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md),
      [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)). Trägt es sie
      nicht, steht dort die Grenze, und die Lücke hat eine Adresse: einen Folge-Slice in `open/`
      mit Kennung oder eine Anforderung an das d-check-Repo. Jede Zusage, die dabei in eine
      Sensor-Datei kommt, hat ein rot gesehenes Gegenbeispiel
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
      **Beleg:** Beide Dateien führen Messung, Grenze und Gegenbeispiel und sagen, dass kein
      Wächter sie hält. Die Adressen der Lücken sind `slice-mv-zieht-praefixlose-geschwister-verweise-nach`
      und `slice-risiko-ausgang-hat-einen-sensor` in `open/` sowie der eingehende Änderungswunsch
      im d-check-Repo (Commit `d8e30b7d` auf dessen Remote). Der Wächter hat die Adresse
      `slice-mv-kanten-nach-done-sind-bewacht`. Das Element Risiko-Ausgang ist mit `42f3a6d1`
      nachgetragen (Verifikations-Nachprüfung vom 2026-09-17, Punkte 1 und 2).
- [x] `make gates` grün über dem Liefer-Stand. **Beleg:** EXIT 0 über `28aaca3d` (Verifikation §1)
      und über dem Stand der Nacharbeit (Message von `cdda6cfd`). Die Closure-Commits deckt der
      Lauf, der nach ihnen fährt.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). **Beleg:** Review und
      Nachprüfung vom 2026-09-17, beide aus einem Reviewer-Kontext.
- [x] Doku-Update: über Liefer-Punkt 3 hinaus keines — die zwei Sensor-Dateien sind der Ort,
      an dem der Befund steht. **Beleg:** `git diff --stat cbb49bf2..28aaca3d` (Verifikation §1).
      Daneben änderte der Planner seinen Anweisungssatz `.claude/commands/plan-welle.md`
      (`dd330ee9`); einen öffentlichen Vertrag berührt das nicht.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| Wegwerf-Kopie außerhalb des Repos | neu, nicht committet | Messort; `make slice-mv` committet selbst und darf den Hauptzweig nicht treffen |
| [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) | update | Liefer-Punkt 3 |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) | update | Liefer-Punkt 3 |
| Folge-Slice je Lücke in `open/` | neu, nur bei Lücke | per `cp` aus der Vorlage |

**Kein Produkt- und kein Werkzeug-Code** (§1). **Keine Testdatei-Zeile**, solange keine Zusage
entsteht; schreibt Liefer-Punkt 3 eine in eine Sensor-Datei, ergänzt der Umsetzungs-Lauf ihren
Wächter und das rot gesehene Gegenbeispiel.

**Verfeinert nach der Messung.** Liefer-Punkt 3 schreibt Messungen, keine bewachten Zusagen: Beide
Sensor-Dateien führen ihre Tabelle mit Kommando und sagen, dass kein Wächter sie hält. Das rot
gesehene Gegenbeispiel steht je Datei daneben — der bloße `git mv` in
[`slice-mv.md`](../../../../harness/sensors/slice-mv.md), die auf einen Satz gekürzte §7 in
[`docs-check.md`](../../../../harness/sensors/docs-check.md). Ein Wächter, der die Kanten dauerhaft
hält, bräuchte `git` in der bats-Stufe oder einen Fall in `make full-smoke`; das ist ein eigener
Vorgang am Werkzeug (§1). Zwei Lücken bekommen eine Adresse, als Übergabe an den Planner: der
Folge-Slice `slice-mv-zieht-praefixlose-geschwister-verweise-nach` (Sub-Area `TOOLS`) und eine
Anforderung an das d-check-Repo (bedingte Pflichtzeile `Gegenstand:`). Der Wächter selbst hat
seine Adresse als dritte in §1 (`slice-mv-kanten-nach-done-sind-bewacht`, Planner-Entscheidung
nach Review-Befund F-2).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-sprung-auf-v690-wird-vollzogen` liegt in `done/`, und
`make baseline-verify` meldet `v6.9.0 OK` — erst dann führt der vendorte Baum den Maßstab. Dazu
WIP-Limit frei. Die Gruppierung, die der Auftraggeber an den Sprung anschließt, beginnt nicht vor
diesem Slice.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Messung braucht mehr als die zwei
  Werkzeuge, etwa weil ein Commit-Träger oder `make archive-welle` auf dem Pfad liegt. Dann wird
  je Werkzeug geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Die Messung lässt sich nicht netzlos an einer
  Kopie fahren, weil ein Werkzeug Zustand verlangt, den die Kopie nicht hat.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. Für jede der vier Paarungen aus Kante und Werkzeug steht in der Sensor-Datei das Kommando, der
   Exit-Code und die gelesene Meldung.
2. Jede Lücke hat eine Adresse, die auflöst: eine Datei in `open/` oder eine Anforderung im
   d-check-Repo.

**Lerneintrag** in einer der drei Formen, §7; die Form hängt am Ergebnis der Messung. **Die
Closure schreibt der Planner** ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Den Ausgang setzt die Closure. *Absehbar* nennt, welcher Ausgang unter welcher Bedingung eintritt.

1. **`make slice-mv` committet selbst.** Am Arbeitsbaum gefahren, legt die Messung echte Commits
   auf den Hauptzweig. *Absehbar:* entfallen, wenn sie an der Kopie läuft. — **Ausgang:
   entfallen.** Alle Messungen liefen an Wegwerf-Kopien, beim Implementer, im Review und in der
   Verifikation. Seit dem Claim trägt der Hauptzweig keinen weiteren Werkzeug-Commit
   (`git log --format=%s cbb49bf2..cdda6cfd | grep -c '^slice-mv:'` → 0).
2. **Grün ohne Gegenbeispiel sagt nichts.** Ein Modul, das die Form gar nicht liest, bleibt grün.
   *Absehbar:* entfallen mit dem Gegenbeispiel aus Liefer-Punkt 2. — **Ausgang: entfallen.** Das
   Gegenbeispiel ohne `Gegenstand:` ist gefahren und bleibt still; die Sensor-Datei führt es als
   Lücke mit Adresse. Rot gesehen sind `closure-note-thin` (§7 auf einen Satz gekürzt),
   `closure-note-placeholder` und der bloße `git mv` mit `target-missing` (Review, Eigene Messung;
   Verifikation §2). Still bleibt auch ein Risiko ohne Ausgang; die Datei führt es mit der Adresse
   `slice-risiko-ausgang-hat-einen-sensor`.
3. **Der gepinnte d-check wandert, bevor die Gruppierung läuft.** Dann gilt die Messung für einen
   anderen Stand. *Absehbar:* entfallen, wenn der Digest zwischen Messung und Gruppierung
   gleich bleibt; sonst eingetreten, Beleg in
   `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`. — **Ausgang: weiter offen.**
   Bis zur Closure hat sich der Pin nicht bewegt
   (`git log --format=%h 5655d3a0..cdda6cfd -- d-check.mk | wc -l` → 0). Die Gruppierung hat aber
   nicht begonnen, und bis dahin kann er wandern. Einen lauten Fall fängt Prüfung 3 aus
   `.claude/commands/plan-welle.md` §Einen Slice stilllegen, denn sie fährt `make docs-check` am
   geltenden Pin. Still bliebe ein neuer Stand, der eine gemessene Meldung nicht mehr gibt: Kein
   Schritt hält den Digest der Sensor-Datei gegen `DCHECK_DIGEST` in `d-check.mk`. Eingetreten ist
   das Risiko nicht. Der Beleg steht darum nicht in dem Eintrag, den der Plan für diesen Fall nennt,
   sondern in
   [`BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md).
4. **`make slice-mv` committet mit dem Slice-Namen**, und auf einem Klon mit aktiviertem
   `commit-msg`-Hook fällt dieser Commit ([`harness/README.md`](../../../../harness/README.md)
   §Traceability). Eine Kopie ohne `core.hooksPath` sieht das nicht. *Absehbar:* weiter offen,
   Adresse ist `slice-werkzeug-commits-tragen-eine-kennung`. — **Ausgang: weiter offen.** Der
   Claim-Commit `cbb49bf2` trägt keine Kennung und ging durch, weil dieser Klon `core.hooksPath`
   nicht setzt (`git config --get core.hooksPath` → Exit 1); den Move-Commit dieser Closure
   schreibt dasselbe Werkzeug. Der Beleg steht in
   [`BEO-ALL/commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md).
   Die Adresse `slice-werkzeug-commits-tragen-eine-kennung` ist in `next/`.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), am Stand
`cdda6cfd`. Maßstab sind Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md` §Closure- und
Lerneintrag-Regeln und `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, dort die Tabelle der
Träger im Repo ohne Wellen. Für fremde Repos gilt die Regel des Auftraggebers vom 2026-09-17: Dort
wird nichts committet oder gepusht.

- **Was hat funktioniert:**
  - Jede Kante ist in zwei Kontexten gemessen, beide Male an Wegwerf-Kopien: `open → done` beim
    Implementer und in der Verifikation, `next → done` beim Implementer und im Review. Die Werte
    stimmen überein (Verifikation §1).
  - Die Gegenbeispiele sind rot gesehen und die Meldungen gelesen (§6 Risiko 2). Was still bleibt,
    steht als Grenze mit Adresse in den Sensor-Dateien.
  - Beide Closure-Kriterien aus §5 sind erfüllt. Die vier Paarungen aus Kante und Werkzeug stehen
    mit Kommando, Exit-Code und gelesener Meldung in den zwei Sensor-Dateien. Jede Adresse löst
    auf: die Folge-Slices in `open/` und der eingehende Änderungswunsch im d-check-Repo, dessen
    Commit `d8e30b7d` auf dem Remote steht (`git -C <d-check-klon> branch -r --contains d8e30b7d`
    → `origin/main`, nur gelesen).
- **Was ging anders als geplant:**
  - **Die Wächter-Pflicht aus §3 entfiel im ausführenden Kontext** (Review F-2). Die Verfeinerung
    erklärte die Einträge zu Messungen. Den Ausschluss mit Adresse hat der Planner in §1 gesetzt
    (`d6bd222c`); damit ist der Plan geändert, nicht nur ergänzt.
  - **Die Grenze der präfixlosen Verweise stand zuerst an der falschen Größe** (Review F-1). Sie
    hängt am Geber, nicht an der Kante; die Sensor-Datei nennt sie jetzt für beide Kanten.
  - **Für den Risiko-Ausgang war Liefer-Punkt 3 im ersten Verifikations-Lauf offen**
    (Verifikation §3). Nachgetragen sind die Adresse `slice-risiko-ausgang-hat-einen-sensor`
    (`a1ae2e74`) und die Lage in der Sensor-Datei (`42f3a6d1`).
  - **Ein Anweisungssatz entstand im Vorgang, den §3 nicht vorsah:**
    `.claude/commands/plan-welle.md` §Einen Slice stilllegen (`dd330ee9`). Anlass waren
    Review-Nachprüfung N-1 und die Punkte 3 und 4 der Verifikation.
  - **Die Lücke im gepinnten d-check hatte zuerst keine auflösbare Adresse** (Review F-5). Dass der
    Commit auf dem Remote steht, hat erst die Verifikation festgestellt (§5 dort).
- **Steering-Loop-Eintrag:** **Geschärfte Regel.** Eine Stilllegung über `make slice-mv` nimmt die
  Kante nach `done/` je Slice einzeln. Nach jedem Wechsel laufen drei Prüfungen: Der Exit-Code ist
  0, der Move-Commit ist ein reiner Rename, und `make docs-check` meldet keinen Befund. Fällt eine
  Prüfung, hält die Serie an. Ob die `Gegenstand:`-Kennung auflöst, beurteilt der Lauf; einen
  Sensor dafür gibt es nicht. Die Regel steht in `.claude/commands/plan-welle.md` §Einen Slice
  stilllegen und gilt, bis `slice-mv-kanten-nach-done-sind-bewacht` geschlossen ist. **Kein
  `liegt in`-Feld:** Auslöser war keine Beobachtung über der Schwelle, sondern ein Befund dieses
  Vorgangs. Die Regel ist im Vorgang geschrieben und verifiziert (Verifikations-Nachprüfung,
  Punkte 3 und 4). Für den Rest gilt: Die Lücken der zwei Werkzeuge sind **benannt**, jede mit
  Adresse, und keine davon ist eine Spec-Lücke.
- **Beobachtungs-Register (`../observations/`):** Der Beleg heißt in jedem Fall
  `evidence/slice-stilllegungs-kanten-sind-gemessen.md`. Den Zähler liefert
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, die Zahl der Belege aus
  diesem Vorgang
  `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-stilllegungs-kanten-sind-gemessen.md | wc -l`
  (→ 8). Keine der Zahlen ist ein Erwartungswert.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | F-1 (wiederkehrende Klasse laut Review), Verifikation §3 | 1, neu | offen |
  | [`plan-bedingung-im-ausfuehrenden-kontext-umgedeutet`](../observations/BEO-ALL/plan-bedingung-im-ausfuehrenden-kontext-umgedeutet/observation.md) | F-2 | 1, neu | offen |
  | [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | F-3; §6 Risiko 3 | 1, neu | offen |
  | [`mess-rezept-setzt-unbenannte-host-konfiguration-voraus`](../observations/BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/observation.md) | F-4 | 1, neu | offen |
  | [`bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md) | N-1; zwei Hinweise der Verifikations-Nachprüfung | 1, neu | offen |
  | [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md) | F-5; Anforderung zum Risiko-Ausgang | 2 | offen |
  | [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md) | F-6; dritter Hinweis der Verifikations-Nachprüfung | 2 | offen |
  | [`commit-message-ohne-traceability-kennung`](../observations/BEO-ALL/commit-message-ohne-traceability-kennung/observation.md) | Claim `cbb49bf2`; §6 Risiko 4 | 4 | verkörpert |

  **Kein Eintrag erreicht mit diesem Slice zum ersten Mal 3×**, der Lese-Schritt hat also keinen
  Gegenstand. `commit-message-ohne-traceability-kennung` stand schon über der Schwelle. Der Fall
  tritt innerhalb seiner benannten Grenze wieder auf, der Werkzeug-Zeile der Reichweiten-Tabelle in
  [`harness/README.md`](../../../../harness/README.md) §Traceability, und der Ausgang bleibt.
  **Nicht getragen, mit Urteil:**
  - `zusage-nennt-zwei-kanten-der-sensor-deckt-eine`: Der Eintrag verlangt einen Sensor, der einen
    der zwei Zeitpunkte einer Regel nicht urteilt. Hier hält kein Wächter die Kanten, und beide
    Sensor-Dateien sagen das. Gemessen sind beide Lifecycle-Kanten, verfehlt war bei F-1 die Größe,
    an der das Ergebnis hängt. Den Fall trägt der neue Eintrag oben.
  - `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`: kein drittes Auftreten. Die
    Messung lief gegen den gepinnten Digest und nennt ihn, und der Review hat die
    Konfigurations-Vorlage desselben Bildes gelesen. Der offene Teil von Risiko 3 ist eine andere
    Frage.
  - `verweise-brechen-beim-ortswechsel`: Die gemessene Lücke ist die eingehende präfixlose Form, die
    der Eintrag als Grenze seiner Verkörperung schon nennt. Aufgetreten ist sie nur an Kopien.
  - `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch`: Claim und Closure ziehen den
    Ruhe-Marker in eigenen Commits mit, der Claim mit `5655d3a0`, die Closure mit dem Commit nach
    ihrem Move.
  - `uebergabe-an-andere-rolle-ohne-traeger-artefakt`: kein Beleg für die Frage an den Architect
    (unten). [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
    §Konsequenzen führt die Lücke selbst als offen, und das Register trägt ihr Auftreten. Die
    Frage hängt also nicht allein an dieser Notiz.
  - F-7 bekommt keinen Eintrag: Die Lücke hat mit `slice-risiko-ausgang-hat-einen-sensor` ihre
    Adresse.
- **Trigger-Audit** (wellenlos, bei der Slice-Closure):
  - **Carveout:** `CO-001` steht auf *Auflösung fällig*, die Adresse ist
    `slice-113-co-001-ist-faellig`. `CO-002` steht auf *permanent*. Dieser Slice berührt keine
    ihrer Bedingungen.
  - **Bootstrap-aware Gate:** keines vorhanden
    (`grep -n -i 'bootstrap-aware' Makefile *.mk harness/mk/*.mk` → kein Treffer).
  - **ADR:**
    - [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) §Was diese Festlegung
      nicht tut: Die Frage, ob Werkzeuge und Doku-Gate die Kanten tragen, ist jetzt gemessen. Die
      Antwort steht in [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md)
      und [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md), jeweils
      §Grenze. Die ADR bleibt, wie sie ist: Der Satz grenzt ab, was die Festlegung selbst
      entscheidet, und die ADR ist `Accepted` ([`AGENTS.md`](../../../../AGENTS.md) §3.4,
      Verifikation §6). Offen bleibt, ob das Repo die Kanten nimmt. Keiner ihrer vier
      Re-Evaluierungs-Trigger ist berührt.
    - [`ADR-0028`](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md): Der offene
      Teil von Festlegung 2, die Norm-Aussage ohne Original, ist getroffen (Übergabe unten).
      Keiner der vier Trigger feuert: `plan-welle.md` hat eine ausführende Rolle, und ihr Commit
      nennt sie.
    - [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md): nur als Ausschluss
      berührt, keiner ihrer Trigger.
    - [`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md): Vor dem Move
      nennt kein Report unter `docs/reviews/` den Pfad in `in-progress/`
      (`grep -rn 'in-progress/slice-stilllegungs' docs/reviews/` → kein Treffer). Ob der
      Nachzug-Commit einen Tree-Operanden umschreibt, liest die Closure nach dem Move.
- **Folge-Slices:**
  - `slice-mv-zieht-praefixlose-geschwister-verweise-nach` (`61be4d3a`): die präfixlosen Verweise
    aus unbewegten Geschwistern.
  - `slice-mv-kanten-nach-done-sind-bewacht` (`d6bd222c`): der dauerhafte Wächter beider Kanten.
  - `slice-risiko-ausgang-hat-einen-sensor` (`a1ae2e74`): Kein Modul prüft den Risiko-Ausgang.
  - `slice-werkzeug-commits-tragen-eine-kennung`, vorhanden in `next/`: Risiko 4.
  - **Adresse ohne Slice:** die bedingte Pflichtzeile `Gegenstand:` als eingehender
    Änderungswunsch im d-check-Repo (`d8e30b7d`). Die Anforderung zum Risiko-Ausgang liegt als
    Text beim Auftraggeber.
- **Übergaben:**
  - **An den Architect:** Wem gehört die Setzung „Urteil" in `.claude/commands/plan-welle.md`
    §Einen Slice stilllegen? Sie ist eine Norm-Aussage ohne Original, und
    [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 2
    nennt dafür keine Rolle. Der Architect entscheidet, ob sie so stehen bleibt und wem sie gehört.
    Er entscheidet auch, ob die Verneinung einer Baseline-Abweichung, die heute nur in der Message
    von `dd330ee9` steht, in eine Datei gehört. Einen Slice-Plan als Übergabe-Artefakt schneidet
    diese Closure nicht. Die Frage tragen die ADR, die sie als offen führt, und der Beleg im
    Register oben.
  - **An den Lauf, der die Gruppierung beginnt** (Hinweise der Verifikations-Nachprüfung):
    1. **Reihenfolge:** `slice-mv-zieht-praefixlose-geschwister-verweise-nach` schließt vor der
       Gruppierung. Das steht heute nur in Plan-Dateien. Ein früherer Start fällt an Prüfung 3 laut
       auf und hält die Serie an.
    2. **Reichweite:** Die drei Prüfungen binden nur einen Lauf, der `plan-welle.md` liest. Ob der
       Gruppierungs-Lauf diesen Anweisungssatz lädt, entscheidet der Planner beim Start.
    3. **Risiko 3:** Vor der Serie ist der Digest in der Sensor-Datei gegen `DCHECK_DIGEST` in
       `d-check.mk` zu halten.

    Getragen sind die drei Punkte von den Register-Einträgen
    `bedingung-ohne-traeger-im-lauf-den-sie-bindet` und
    `werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`. Beide liest §8 jeder
    Slice-Planung.
- **Risiken aus §6:** Jedes hat genau einen Ausgang: 1 und 2 sind entfallen, 3 und 4 bleiben weiter
  offen.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht
  (`ls docs/plan/planning/done/*.zip docs/plan/planning/done/*/archiv.zip 2>/dev/null | wc -l`
  → 0).
- **Drei Paarungen**, die die nächste Welle-Closure ebenfalls prüft (§2):
  - (a) Kein Gegenstand, denn diese Notiz führt kein `liegt in`-Feld.
  - (b) Getragen: Jeder genannte Folge-Slice existiert als Datei im Lifecycle.
  - (c) Getragen: Jede genannte Beobachtung existiert als Verzeichnis, und jedes trägt einen
    Beleg.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist **eine** Sub-Area: `*` (gesamtes Repo), mit
den zwei Sensor-Dateien unter `harness/sensors/`. `harness/tools/` (`TOOLS`) ist nicht berührt:
Das Skript hinter `make slice-mv` liegt dort, aber der Slice ändert kein Werkzeug (§1) — er
misst es. Behebt ein Folge-Slice eine Lücke, berührt **der** `TOOLS`. `.codex/` (`CODEX`) ist
nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, am gemergten Stand
(`git status -sb` meldet `## main...origin/main` ohne Vor- oder Nachlauf).
`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **121** Einträge, alle mit der
Sub-Area `*`; gesichtet ist nach Gegenstand. Zähler je Treffer:
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`; keine
Erwartungswerte.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| `lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch` | 20 | geplant, `slice-ortswechsel-zieht-sein-zustandsfeld-nach` | die neuen Kanten führen nicht über `in-progress/`; ob sie trotzdem ein bewachtes Zustandsfeld kippen, zeigt Liefer-Punkt 2 |
| `verweise-brechen-beim-ortswechsel` | 6 | verkörpert | die neue Kante ist ein Ortswechsel; Liefer-Punkt 1 misst den Nachzug |
| `zusage-nennt-zwei-kanten-der-sensor-deckt-eine` | 3 | verkörpert | Liefer-Punkt 1 und 2 messen beide Kanten |
| `slice-plan-umfang-waechst-ueber-umsetzung-hinaus` | 3 | geplant, `slice-plan-umfang-bleibt-beim-gegenstand` | dieser Plan |
| `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` | 2 | offen | dieser Slice ist die Messung; eine Aussage über den d-check ohne Digest wäre das dritte Auftreten |
| `gleichzeitig-laufender-slice-macht-adresse-tot` | 1 | offen | ein Geber, der nach `done/` geht, bewegt die Adresse, auf die andere Pläne zeigen |

**Keiner der Einträge erreicht mit diesem Slice zum ersten Mal 3×**;
`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand` nur dann, wenn Liefer-Punkt 2
den Digest nicht nennt.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF.**

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF, deklariert in [`harness/conventions.md`](../../../../harness/conventions.md)
  §Modus-Deklaration pro Sub-Area.
- **Konventionen-Dichte:** mittel. Beide Werkzeuge führen Vertrag und Grenze in ihrer
  Sensor-Datei; die neue Kante nennt keine davon.
- **Phase-Reife:** Phase 5 — beide Werkzeuge laufen im Betrieb
  ([`harness/README.md`](../../../../harness/README.md) §Sensors und §Werkzeuge).
- **Evidenz-/Diskrepanz-Risiko:** mittel. Die Diskrepanz, die die Messung sichtbar machen kann,
  ist genau die zwischen Ziel-Fassung und Werkzeug-Stand.
- **Reconciliation-Aufwand:** keiner — GF. Folge-Trigger ist jede Lücke aus Liefer-Punkt 3.
