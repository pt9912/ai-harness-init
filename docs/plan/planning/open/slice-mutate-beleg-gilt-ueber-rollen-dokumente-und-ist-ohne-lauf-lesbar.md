# Slice slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar: Der `make mutate`-Beleg überlebt die Dokumente der Rollen und ist lesbar, ohne dass ein Lauf startet

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057) Setzung 1 — ein freier Slug in
lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt:
kein repo-weiter Beleg über die Slice-DoDs hinaus, kein Replay; damit fehlt das *Mehr*, an dem sich
eine Welle entscheidet (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).
Der Schwester-Slice
[slice-mutate-fall-filter-und-die-belegform-vereinigung](../in-progress/slice-mutate-fall-filter-und-die-belegform-vereinigung.md)
ist einzeln lieferbar und bildet mit diesem kein Bündel.

**Ebene: Dogfood, nicht emittiert.** `harness/tools/mutate.sh` ist Werkzeug **dieses** Repos
(`grep -rl 'mutate\.sh' internal | wc -l` → 0); kein Zielrepo bekommt es.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (der Beleg ist die Zusage *jeder gelistete Wächter färbt
rot*; sie gilt, solange der Schlüssel gilt — und ein Beleg, der für die Rolle, die ihn braucht,
schon verfallen ist, wird zur bloßen Aussage),
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) (**Proposed** —
Festlegung 3: die Bezugsmenge hat eine Definition, Ausnahmen sind deklariert, begründet und als
Rest gezählt; Trigger 1: ändert sich die Ausschluss-Menge, ist die Deckung neu zu zeigen — das ist
der Nachweis dieses Slice; die Annahme der ADR ist keine Bedingung des Slice),
[`MR-025`](../../../../harness/conventions.md#mr-025) (jede Zahl dieses Plans steht neben dem
Kommando, das sie liefert),
[`MR-071`](../../../../harness/conventions.md#mr-071) (die Fall-Anlage misst ihr `sed`-Muster gegen
den Quell-Bestand).

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist ein Werkzeug
dieses Repos).

**Verantwortlich:** —
<!-- BEDIENHINWEIS: Verantwortlich hält die Arbeit — der Rolleninhaber der
Implementer-Rolle, gesetzt beim Übergang open→next (Baseline-Regelwerk
modul-05-planning-harness.md §Lifecycle als State Machine). Der Autor schrieb
den Plan; zwei Felder, zwei Fragen. Kein Statuswert: der Zustand bleibt das
Verzeichnis. Kein Sensor prüft das Feld — es ist Deklaration. -->

**Autor:** Planner. **Datum:** 2026-09-25.

---

## 1. Ziel und Abgrenzung

<!-- BEDIENHINWEIS: Ziel = ein Satz, Liefer-Fokus, kein "wir machen
aufraeumen". Abgrenzung = je Punkt eine Begruendung, nicht nur eine Nennung:
ein Ausschluss ohne Grund ist eine Behauptung. Keine Mindestzahl — ein echter
Ausschluss ist besser als vier erfundene. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein Doku-Commit von Reviewer oder Verifier — der Bericht unter `docs/reviews/` —
entwertet den Beleg von `make mutate` nicht mehr, und eine Rolle, die wissen will, ob der Beleg am
Endstand gilt, fragt danach, ohne dass ein Lauf startet.

**Der Befund, an dem der Schnitt hängt.** Der Schlüssel des Belegs hängt an jeder Datei der
Isolationskopie außer dem Zustands-Bereich: `ISOLATION_EXCLUDES` in `harness/tools/mutate.sh` nennt
heute genau den Zustands-Bereich unter `.harness/`, `ISOLATION_KEY_EXEMPT` genau `.git`. Jeder Doku-Commit einer
nachfolgenden Rolle bewegt ihn, und der nächste Lauf fährt voll. Ein Lauf, der den Beleg nur
bestätigen will, löscht den Slot, bevor er endet — `clear_belief` steht in `main()` vor der
Isolation (`grep -n '^  clear_belief$' harness/tools/mutate.sh` → 1559; keine Erwartungswerte, die
Zeile wandert). Drei Vorgänge haben es belegt
(`ls docs/plan/planning/observations/BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/evidence | wc -l`
→ 3): die Beobachtung steht auf der Schwelle, und dieser Slice ist ihr Ausgang (§8).

**Verengt wird durch Ausschluss aus der Kopie, nicht durch eine Ausnahme im Schlüssel.** Was die
Kopie nicht trägt, kann kein Fall lesen, und der Grün-Vorlauf färbt jedes Lesen laut rot. Ein Eintrag
in `ISOLATION_KEY_EXEMPT` ließe den Baum in der Kopie und machte den Schlüssel blind dafür — die
Deckungslücke, die
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 2
verbietet. Die drei Kandidaten sind `docs/reviews` und `docs/plan/planning/done` (Zeitdokumente,
[`AGENTS.md`](../../../../AGENTS.md) §3.7) sowie `docs/plan/planning/observations` (ein lebendes
Register; sein Kandidaten-Status hängt allein daran, ob ein Sensor es liest). Getrackte Dateien je
Baum: `git ls-files docs/reviews | wc -l` → 547, `git ls-files docs/plan/planning/done | wc -l` →
248, `git ls-files docs/plan/planning/observations | wc -l` → 819 (keine Erwartungswerte).
`docs/plan/planning/` pauschal ist kein Kandidat: `test/planning-modul-wiring.bats` liest
`docs/plan/planning/in-progress/roadmap.md` (`grep -n 'in-progress/roadmap.md' test/planning-modul-wiring.bats`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Fall-Filter und die Regel, wann zwei Läufe zusammen Aussage sind** — *ein Folge-Slice
  übernimmt es:*
  [slice-mutate-fall-filter-und-die-belegform-vereinigung](../in-progress/slice-mutate-fall-filter-und-die-belegform-vereinigung.md)
  führt Filter und Vereinigung; er ist einzeln lieferbar und braucht nichts aus diesem Slice.
- **Ein Auto-Retry** — *es wäre eine Änderung des Verdikts, kein Ausgang:* ein Retry-Muster, das
  einen roten Fall wiederholt, verdeckt den echten Befund, und eine Muster-Liste hat keine Zähne, die
  sie bewachen. Keine Adresse; wer es will, führt eine Entscheidung herbei.
- **Ein kumulativer Teil-Beleg** (mehrere Teil-Läufe schreiben gemeinsam den Slot) — *verstieße gegen
  die Fitness-Zeile* „ein Lauf mit Befund hinterlässt keinen Beleg" von
  [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) und wäre eine
  neue Entscheidung des Architects (Folge-ADR); der Schwester-Slice schließt ihn ausdrücklich aus.
- **Ein Fall-Schlüssel** (je Fall ein eigener Schlüssel über die Dateien, die dieser Fall liest) —
  *die Deckung ist nicht gezeigt:* ein Fall-Sensor liest den Baum, und ein Schlüssel über weniger als
  das Gelesene ist die falsche Aussage, die
  [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 2
  benennt.
- **`harness/tools/working-tree-hash.sh`** — *es wäre ein anderer Vorgang:* der Gate-Nachweis ist
  eine zweite, für einen anderen Zweck gepflegte Definition desselben Wortes und als Schlüssel nach
  [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 3
  nicht zulässig.
- **Verengung um Pfade, die ein Sensor liest** — *Bestand bleibt bewusst stehen:*
  `docs/plan/planning/in-progress/roadmap.md` bleibt im Schlüssel, ebenso jede andere Datei, für die
  die Deckung nicht zu zeigen ist. Dasselbe gilt für die Slice-Dateien in `in-progress/`: die Closure
  des Planners (Notiz, `git mv` nach `done/`) und eine Welle-Closure (`roadmap.md`) bewegen den
  Schlüssel weiterhin. Der Beleg wird von Implementer, Reviewer und Verifier gebraucht; der Planner
  liest den Verifikationsbericht, nicht den Slot.
- **`MUTATE_FORCE` und der Docker-Cache-Rest** — *Bestand bleibt:* die Deckung, die kein
  baum-abgeleiteter Schlüssel liefert
  ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4),
  ändert sich mit einer kleineren Kopie nicht.
- **Die Annahme von [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)**
  — *anderer Vorgang:* ob die Entscheidung `Accepted` wird, entscheidet der Auftraggeber; der Slice
  wendet Festlegung 3 und Trigger 1 an, gleich in welchem Status sie stehen.

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

<!-- BEDIENHINWEIS: je Zeile ein pruefbares Kriterium. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei Liefer-Punkte; jedes Gegenbeispiel steht beim Punkt, den es bewacht, und ist **rot zu sehen**,
mit gelesener Meldung ([`AGENTS.md`](../../../../AGENTS.md) §3.6), nicht nur als Name im Bericht.

- [ ] **Liefer-Punkt 1 — die Bezugsmenge des Schlüssels verengt sich um Zeitdokumente.** Die
      Kandidaten `docs/reviews`, `docs/plan/planning/done` und
      `docs/plan/planning/observations` werden **je einzeln** in `ISOLATION_EXCLUDES` aufgenommen
      (`harness/tools/mutate.sh`; **nicht** in `ISOLATION_KEY_EXEMPT`), und jeder steht dort nur,
      wenn ein voller Lauf über die reduzierte Kopie in allen fünf Modi grün ist — die Modi nennt
      `grep -h '^# verify:' test/mutations/*.sh | sort -u`: `ci-lint`, `full-smoke`, `smoke`,
      `test-bats`, `test-go` (kein Erwartungswert). Ein Kandidat, dessen Lauf rot wird, bleibt draußen,
      und der Kommentar (Punkt 3) nennt den Sensor, der ihn liest. Der bestehende Fall
      *jeder von `prepare_isolation` kopierte Pfad geht in den Schlüssel ein oder steht in der
      Ausnahmeliste* (`test/mutate-driver.bats`) bleibt grün, ohne geändert zu werden — er rechnet
      beide Mengen aus der Definition, die der Lauf benutzt. **Gegenbeispiele:** (a) ein Fall in
      `test/mutate-driver.bats`: eine Änderung in einem ausgeschlossenen Baum lässt `isolation_key`
      gleich, eine Änderung unter `docs/user/` lässt ihn wechseln; die Mutation *Eintrag aus
      `ISOLATION_EXCLUDES` entfernen* färbt den ersten Fall rot. (b) Die Deckung ist strukturell zu
      zeigen: eine Wegwerf-Probe, die eine Datei im ausgeschlossenen Baum liest, färbt den
      Grün-Vorlauf rot — die Meldung wird gelesen und nennt die fehlende Datei, nicht irgendeinen
      Fehler. (c) Ein Fall in `test/mutations/` bewacht die Ausschluss-Liste (Anlage nach
      [`MR-071`](../../../../harness/conventions.md#mr-071): das `sed`-Muster gegen den Quell-Bestand
      gemessen). (d) Ein voller `make mutate`-Lauf am Endstand ist grün und belegt den Punkt.
- [ ] **Liefer-Punkt 2 — die Beleg-Prüfung ohne Lauf.** Ein Schalter am bestehenden `make mutate`
      (den Namen wählt der Implementer; **kein neues Target** — es zöge Index-Zeile und
      `exempt-targets` nach sich, ohne dass sich der Vertrag des Sensors ändert) beantwortet, ob der
      Beleg für den **aktuellen** Schlüssel gilt: Exit 0 mit dem Beleg-Stand in der Meldung, Exit 1
      *gilt nicht* mit dem Grund (kein Slot · Schlüssel weicht ab · Schlüssel nicht berechenbar). Er
      fährt **keinen** Fall, kein Worker startet, und der Beleg-Slot bleibt byte-gleich — die Prüfung
      ruft weder `clear_belief` noch `write_belief`. Über `make` endet der Exit 1 des Skripts mit dem
      Prozess-Exit 2 (`harness/sensors/mutate.md` §Ausgabe und Ausgänge); die Rolle liest die
      Meldung, nicht die Ziffer. **Gegenbeispiele:** (e) ein Fall in `test/mutate-driver.bats` je
      Schlüssel-Treffer und Schlüssel-Abweichung: Exit 0 bzw. 1, und der Slot ist danach unverändert;
      die Mutation *die Prüfung ruft `clear_belief`* färbt beide rot; die Mutation *die Prüfung
      meldet ohne Vergleich „gilt"* färbt den Abweichungs-Fall rot. (f) Ein Fall, der belegt, dass kein
      Fall-Lauf startet (die Mutation *der Schalter fällt in den vollen Lauf durch* färbt ihn rot;
      wie der Fall den Fall-Satz austauscht, ist Sache des Implementers).
- [ ] **Liefer-Punkt 3 — die Aussage steht dort, wo ein Änderer sie liest.** Der Kommentar an
      `ISOLATION_EXCLUDES` in `harness/tools/mutate.sh` und der Abschnitt *Grenze* in
      `harness/sensors/mutate.md` nennen die ausgeschlossenen Bäume, die Regel *Verengung ist Ausschluss
      aus der Kopie, nicht Ausnahme im Schlüssel*, die Beleg-Prüfung und das, was übrig bleibt: ein
      Commit, der eine von einem Sensor gelesene Datei ändert — `docs/plan/planning/in-progress/roadmap.md`,
      eine Slice-Datei in `in-progress/` —, entwertet den Beleg weiterhin. Der Kommentar trägt den
      Herkunfts-Anker `· seit slice-mutate-beleg-gilt-ueber-rollen-dokumente-und-ist-ohne-lauf-lesbar`
      (wellenlos) und beschreibt die Stelle im Indikativ, ohne Chronik
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7). **Gegenbeispiel:** (g) `make comment-claims` und
      `make docs-check` bleiben grün; ein Kommentar, der einen Sensor nennt, der nicht existiert,
      färbt `comment-claims` rot.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

<!-- BEDIENHINWEIS: Datei- oder Komponenten-Ebene reicht; der
Implementer-Agent erweitert die Liste in seinem ersten Lauf, inklusive
einer Testdatei-Zeile mit der Akzeptanzkriterien-ID in `Begründung`
(Modul 9 §Minimal Agent Workflow). -->

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/mutate.sh` | update | `ISOLATION_EXCLUDES` um die Kandidaten; der Schalter der Beleg-Prüfung; Kommentar mit Anker (Punkte 1–3) |
| `test/mutate-driver.bats` | update | Schlüssel-Fälle (a) und Prüf-Fälle (e), (f); der Fall zu Kopie und Ausnahmeliste bleibt unverändert |
| `test/mutations/` | neu | ein Fall, der die Ausschluss-Liste bewacht (c) |
| `harness/sensors/mutate.md` | update | Abschnitt *Grenze*: Bäume, Regel, Prüfung, Rest (Punkt 3) |
| `Makefile` | nur falls nötig | das Rezept `mutate` reicht heute allein `MUTATE_JOBS` explizit durch; ob der Schalter das Skript über `make mutate` erreicht, belegt der Implementer an einem Aufruf |

Ansatz als Liste:

- Zuerst messen, dann eintragen: ein voller Lauf über die Kopie **ohne** die drei Bäume ist der
  Startpunkt; wird er rot, trennt der Implementer die Kandidaten und lässt den aus, dessen Sensor
  liest (die Meldung des Grün-Vorlaufs nennt ihn).
- Der Schalter liest denselben `isolation_key()` und denselben `$BELIEF` wie der Übersprung in
  `main()`; eine zweite Berechnung wäre eine zweite Definition des Schlüssels
  ([ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 3).

## 4. Trigger

<!-- BEDIENHINWEIS: Beispiele — "Wenn Welle X done." / "Wenn Carveout CO-NN
aufgeloest." -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Auftraggeber priorisiert (`open → next`) und setzt
`Verantwortlich:`; kein anderer Slice liegt in `in-progress/` (WIP-Limit). Keine Vorbedingung aus
einem anderen Slice; die Annahme von
[ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) ist keine.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Beleg-Prüfung braucht mehr als eine
  Verzweigung am Kopf von `main()` **und** eine zweite Berechnung des Schlüssels — dann ist sie ein
  eigener Slice, und die Verengung trägt allein; oder die Einzelbelege der Kandidaten sprengen eine
  Review-Sitzung.
- `in-progress` → `open` (blockiert): der Architect verdiktet bei der Annahme von
  [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md), dass eine
  Verengung um ein Zeitdokument Festlegung 3 widerspricht — dann ist der Plan zu ändern, nicht
  weiterzubauen.

## 5. Closure-Trigger

<!-- BEDIENHINWEIS: z.B. "DoD vollstaendig + PR gemerged + Closure-Notiz
geschrieben." -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die Gegenbeispiele (a) bis (g) sind rot gesehen; ein voller `make mutate`-Lauf am
Endstand ist grün; Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben. **Der Lerneintrag hat
seine Form schon:** die Regel *Verengung der Bezugsmenge ist Ausschluss aus der Kopie, nicht Ausnahme
im Schlüssel* ist die geschärfte Regel, `liegt in` `harness/tools/mutate.sh`, Auslöser die
Beobachtung `BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf` (3×); ihr
Stand wechselt bei der Closure von `geplant` auf `verkörpert`.

## 6. Risiken und offene Punkte

<!-- BEDIENHINWEIS: Was koennte schief gehen? Welche Carveouts entstehen
ggf.? Die drei Ausgaenge stehen als Form in der Zeile darunter. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **R1 — in der Kopie fehlen getrackte Dateien, und ein Sensor mit git-Sicht wird rot.** Der
  Grün-Vorlauf zeigt es laut; die Kopie trägt `.git` unverändert (`ci-lint` braucht es), und die
  Kandidaten fehlen dort als Arbeitsbaum-Dateien, nicht als Objekte. — **Ausgang:** offen, wird bei
  Closure verbucht.
- **R2 — die Kandidatenliste schrumpft.** Liest ein Sensor `done/` oder `observations/`, bleibt allein
  `docs/reviews`; das reicht für die Berichte von Reviewer und Verifier. Schrumpft sie auf null (ein
  Sensor liest auch `docs/reviews`), trägt der Slice nur die Beleg-Prüfung und hat sein Ziel
  verfehlt — das ist ein Rückführungsgrund, kein stiller Rest. — **Ausgang:** offen, wird bei
  Closure verbucht.
- **R3 — ein Commit, der eine gelesene Datei ändert, entwertet den Beleg weiterhin:** die Closure des
  Planners (Slice-Datei in `in-progress/`), `docs/plan/planning/in-progress/roadmap.md` bei einer
  Welle-Closure. Akzeptiert (§1, Abgrenzung); Punkt 3 nennt es im Sensor-Doc, damit die Rolle es
  liest, statt es an einem Verfall zu entdecken. — **Ausgang:** offen, wird bei Closure verbucht.
- **R4 — die Laufzeit der Belege.** Ein voller Lauf über die Kopie kostet Stunden-Bruchteile
  (`make mutate MUTATE_JOBS=8` → 1822 s an einem Endstand, aus dem Beleg des Vorgangs
  `slice-program-feld-nennt-weder-operator-noch-wertfragment`); je Kandidat ein eigener Lauf wären
  drei. Ein Lauf über alle drei zugleich ist der Startpunkt, Einzelläufe sind bei Rot fällig — das
  ist ein Vorschlag des Planners, keine Deckungsaussage: ein Kandidat gilt erst, wenn ein Lauf mit
  ihm in `ISOLATION_EXCLUDES` grün war. — **Ausgang:** offen, wird bei Closure verbucht.
- **R5 — [ADR-0035](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) steht auf
  `Proposed`.** Ändert der Architect bei der Annahme Festlegung 3 oder Trigger 1, ist der Plan
  nachzuziehen. — **Ausgang:** offen, wird bei Closure verbucht.

## 7. Closure-Notiz

<!-- BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md
§Verwendung, Schritt 5) und darf deshalb nichts Tragendes halten. Reihenfolge:
diese Sektion vor dem `git mv` nach done/ fuellen — einzige Ausnahme ist das
letzte DoD-Item in §2 (die Paarungen suchen in `done/`, also nach dem `git mv`).
Im Repo ohne Wellen-Betrieb braucht die Closure dadurch drei Commits: Inhalt,
`git mv`, Haekchen — das folgt aus der Hard Rule, es widerspricht ihr nicht. -->

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
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
- **Gegenstand:** <übernommen von `slice-<Kennung>` | entfallen: <Grund>>
  *(nur beim Ausgang ohne Arbeit; sonst Zeile löschen)*
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `harness/tools/` (`TOOLS`, `mutate.sh`) und
`*` (`ALL`: `test/`, `harness/sensors/`); beide führt die
[Modus-Deklaration](../../../../harness/conventions.md#modus-deklaration-pro-sub-area), beide sind
GF. Keine neue und keine zu grobe Sub-Area.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`); alle Beobachtungen führen die
Sub-Area `*`. Treffer, Zähler-Stand je `ls <Verzeichnis>/evidence | wc -l`:
`BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf` **3** — die Schwelle ist
erreicht, dieser Slice ist der Ausgang (`geplant`, bei Closure `verkörpert`; übrig bleibt ein Commit,
der eine gelesene Datei ändert) ·
`BEO-ALL/baum-hash-deckt-nicht-jeden-pruefgegenstand` **1** — die Gegenrichtung (der Schlüssel deckt
zu wenig); dieser Slice verengt den Schlüssel und zeigt die Deckung je Kandidat, statt sie
anzunehmen, und bewegt den Zähler nicht ·
`BEO-ALL/ausnahmeliste-nur-auf-form-geprueft` **4**, Ausgang `geplant` bei einem anderen Träger — sie
trifft `ISOLATION_KEY_EXEMPT`; dieser Slice trägt nichts dorthin (die Verengung geht über
`ISOLATION_EXCLUDES`) ·
`BEO-ALL/sensor-lauf-endet-rot-an-der-infrastruktur-bevor-der-fall-urteilt` **1** — Gegenstand des
Schwester-Slices, hier nicht berührt.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
