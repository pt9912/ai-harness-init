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

**Verantwortlich:** — bis zur Priorisierung.

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

- [ ] **1 — `make slice-mv` ist für beide Kanten gemessen.** Je ein Slice aus `open/` und einer
      aus `next/` gehen mit `TO=done`, auf einer Wegwerf-Kopie außerhalb des Repos, in der das
      Werkzeug committen darf. Festgehalten sind je Kante Exit-Code und Ausgabe, ob der Move rein
      bleibt, ob eingehende Verweise nachgezogen werden und ob ausgehende Verweise auf Geschwister
      im alten Verzeichnis ihr Präfix bekommen
      ([`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) §Grenze).
      **Beide Kanten, nicht eine** (§8, `zusage-nennt-zwei-kanten-der-sensor-deckt-eine`).
- [ ] **2 — `make docs-check` ist über einem Stand gemessen, in dem je Kante ein Slice in der
      Form der Ziel-Fassung in `done/` liegt:** leere Liefer-Punkte, §7 mit `Gegenstand:`,
      Risiken mit Ausgang. Gelesen ist jede Meldung samt Grund-Code, nicht nur der Exit —
      namentlich `closure-note-thin` und `closure-note-placeholder` der Fähigkeit `closure`
      ([`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md) §Modul
      `planning`). Dazu das Gegenbeispiel: derselbe Slice **ohne** `Gegenstand:`-Zeile. Meldet
      dann kein Modul, ist das eine Grenze und wird so benannt; die Ziel-Fassung sagt selbst, dass
      kein Link-Sensor die Kennung als Token prüft. Die Messung nennt den Digest des gepinnten
      d-check, gegen den sie läuft (§8, `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`).
- [ ] **3 — Jede Kante hat ihren Ausgang an dem Ort, den der nächste Lauf liest.** Trägt ein
      Werkzeug die Kante, steht das als gemessene Eigenschaft mit Kommando in seiner Sensor-Datei
      ([`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md),
      [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md)). Trägt es sie
      nicht, steht dort die Grenze, und die Lücke hat eine Adresse: einen Folge-Slice in `open/`
      mit Kennung oder eine Anforderung an das d-check-Repo. Jede Zusage, die dabei in eine
      Sensor-Datei kommt, hat ein rot gesehenes Gegenbeispiel
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] `make gates` grün über dem Liefer-Stand.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: über Liefer-Punkt 3 hinaus keines — die zwei Sensor-Dateien sind der Ort,
      an dem der Befund steht.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo fährt Wellen (`ls docs/plan/planning/welle-*.md`), sie werden deshalb von der nächsten Welle-Closure geprüft, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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
   auf den Hauptzweig. *Absehbar:* entfallen, wenn sie an der Kopie läuft.
2. **Grün ohne Gegenbeispiel sagt nichts.** Ein Modul, das die Form gar nicht liest, bleibt grün.
   *Absehbar:* entfallen mit dem Gegenbeispiel aus Liefer-Punkt 2.
3. **Der gepinnte d-check wandert, bevor die Gruppierung läuft.** Dann gilt die Messung für einen
   anderen Stand. *Absehbar:* entfallen, wenn der Digest zwischen Messung und Gruppierung
   gleich bleibt; sonst eingetreten, Beleg in
   `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`.
4. **`make slice-mv` committet mit dem Slice-Namen**, und auf einem Klon mit aktiviertem
   `commit-msg`-Hook fällt dieser Commit ([`harness/README.md`](../../../../harness/README.md)
   §Traceability). Eine Kopie ohne `core.hooksPath` sieht das nicht. *Absehbar:* weiter offen,
   Adresse ist `slice-werkzeug-commits-tragen-eine-kennung`.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Steering-Loop-Eintrag:** offen bis zur Closure; die Form hängt am Ergebnis der Messung (§5).
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure — je Lücke einer, sonst keiner (Liefer-Punkt 3).
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** entfällt hier — dieses Repo fährt Wellen (§2).

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
