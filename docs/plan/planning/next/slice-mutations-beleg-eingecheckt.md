# Slice mutations-beleg-eingecheckt: Mutations-CI-Urteile landen eingecheckt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die mehr beobachtet,
als die DoDs dieses Slice belegen: der Beleg je Lauf wird vom Konsum-Schritt
geschrieben und ist seine eigene Lieferung, ein repo-weites Beleg-Mehr
(Replay, repo-weiter Verifikations-Beleg) steht nicht an
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht —
wellenlose Arbeit ist Baseline-Default,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst);
Präzedenz [`slice-d-check-sprung-v0930.md`](../done/slice-d-check-sprung-v0930.md)).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — die Farbungs-Hälfte
der Mutations-Zusage trägt der Lauf, ohne eingecheckten Beleg verfällt sie mit dem Job-Log ·
[`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt) — der CI-Branch, dessen Ergebnis-Datei dieser Slice einspeichert ·
[`MR-072`](../../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form) — die Ablage-Regel volle Kennung im Dateinamen ·
[`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) — der Isolations-Schlüssel und die
Grüenvorlauf-Festlegung der registrierten Klasse ·
[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) — der Log-Zugriff als Zahl-Beleg-Träger des Retro-Urteils.

**Berührte Spec-Stellen:** — (der Mutations-CI-Weg trägt seine Aussagen in
`harness/sensors/mutate.md` und den Workflows; die Spezifikation nennt ihn nicht).

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-11-25.

---

## 1. Ziel und Abgrenzung

**Ziel:** Je Mutations-CI-Lauf
([`MR-091`](../../../../harness/conventions.md#mr-091--ab-neun-fällen-läuft-die-mutations-probe-eines-slice-über-einen-ci-branch-dessen-ergebnis-job-schreibt))
landet dessen Ergebnis-Fassung (`mutate-ergebnis.txt`) **eingespeichert und
getrackt** — Design-Vorschlag als Ausgangslage, der Architect verfeinert:
Ablageort `docs/reviews/mutate/`, Dateiname `<slice-kennung>-<sha8>.txt`
(volle Kennung im Dateinamen, wie die Review-Reports ihre Ablage-Regel
tragen, [`MR-072`](../../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form));
geschrieben vom **Konsum-Schritt** — der Verifier liest das Branch-File nach
[`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) §CI-Branch
(`git fetch` + `git show FETCH_HEAD:`) und committet es auf `main`, **bevor**
er den Branch räumt; der Workflow pusht nicht auf `main`. Der Branch-Bestand
bleibt unverändert. Im selben Zug der **Retro-Beleg** für den heute
abgeschlossenen Pin-Sprung [`slice-d-check-sprung-v0930.md`](../done/slice-d-check-sprung-v0930.md),
dessen `Urteil: gruen` 82/82 (Run 45625795106, Attempt 3) allein im
Job-Log steht und mit dessen Log-Verfall beleglos würde
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)):
das Log-Zugriffs-Kommando mit `gh api` steht als Zahl-Beleg daneben.

**Übernimmt:** eine Teil-Klasse der registrierten Infra-Klasse
`BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last` — der dritte Beleg
(s. §8). Keine Übernahme eines Slice-Gegenstands; die Zeile bleibt stehen,
weil der BEFUND-Beleg des zweiten Laufs genau diese Klasse belegt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Turn-Gate und kein Stop-Hook-Stempel im Sinne von ADR-0083** —
  ein anderer Vorgang: das Handoff-Gate bindet den Arbeitsbaum an einen
  grünen `make gates`-Lauf (Klasse: Commit-Bindung an den eigenen Zustand);
  hier geht es um den Lauf-Beleg eines CI-Werkzeugs über Branches hinweg.
  Eine zweite Quelle für denselben Zustand daneben wäre der Defekt, den
  die ADR abstellt.
- **Kein Workflow-Push auf `main`** — ein anderer Vorgang: allein der
  `ergebnis`-Job trägt `contents: write`, und das auf den CI-Branch. Ein
  Schreibrecht der CI auf `main` wäre eine eigene Policy-Entscheidung und
  würde den Konsum-Schritt doppeln, dessen Lese-Zug (`git fetch` +
  `git show`) ohnehin existiert.
- **Bestehende Branch-Formen bleiben unverändert** — Bestand bleibt bewusst
  stehen: die Ergebnisform an der Branch-Wurzel und der Tip-Skip für
  reine Ergebnis-Commits sind geprüft (git-Stub-Tests, Grenze im Kopf von
  [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md));
  der Beleg liest dieselbe Form, nur aus `docs/reviews/mutate/` statt von
  der Branch-Wurzel.
- **Keine Auslagerung des Belegs in den git-eigenen Isolations-Schlüssel** —
  [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) trägt
  die Klassifikation grün/rot je Fall am `mutate-passed.key`, nicht die
  Ergebnis-Fassung; ein zweiter Träger desselben Urteils daneben driftet.
  Der Schlüssel bleibt, was er ist.

## 2. Definition of Done

- [ ] ADR des Architects `Accepted` und abgelegt: der Form- und
      Träger-Beschluss — Ablageort `docs/reviews/mutate/`, Namensform mit
      voller Slice-Kennung, Konsum-Schritt-Sender (wer schreibt, woraus,
      in welchem Rollen-Übergang) — Übergabe Planner → Architect →
      Planner gemäß Modul 8, vor der Implementation (Vorgänger-Muster
      [`slice-d-check-sprung-v0930.md`](../done/slice-d-check-sprung-v0930.md));
      die offenen Architektur-Fragen aus §6 tragen dort ihre Antwort.
- [ ] Retro-Beleg für [`slice-d-check-sprung-v0930.md`](../done/slice-d-check-sprung-v0930.md)
      als zwei Dateien im festgelegten Ablageort committet: die
      Ergebnis-Fassung des Grün-Laufs (`Urteil: gruen`, 82/82, Run
      45625795106, Attempt 3 — Quellnachweis über das `gh api`-Log-Kommando
      neben den `git show`-Bytes) und der BEFUND-Inhalt des zweiten Laufs
      als Infra-Befund der Klasse `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`;
      je Datei nennt der Kopf seinen Ausgabe-Kanal (Job-Log oder
      Branch-File) und den Commit der Branch-Spitze.
- [ ] Form-Zeile in [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      §CI-Branch ergänzt: der Konsum-Schritt nennt den Ablageort und die
      Grenze, dass kein Wächter die Ablage-Form hält (`AGENTS.md` §3.6 —
      benannt statt erfunden).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für den Mutations-CI-Weg falls öffentlicher Vertrag berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — der
      BEFUND-Beleg des Retro-Laufs zählt die Klasse
      `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last` hoch; kein
      Zähler wird gesetzt, er folgt aus den Dateien.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen —
      im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen
      von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/NNNN-<titel>.md` | neu (Architect) | Form- und Träger-Beschluss des Beleg-Ablageorts; Aufgabeneinheit ist Übergabe P → A → P |
| `docs/reviews/mutate/slice-d-check-sprung-v0930-<sha8>.txt` (2 Dateien: Grün-Lauf, BEFUND-Lauf) | neu | der Retro-Beleg, aus dem Job-Log bzw. dem Branch-File entnommen, je Kopf mit Ausgabe-Kanal und Branch-Spitze |
| `docs/reviews/mutate/` als Verzeichnis | neu | der Ablageort selbst; `docs/reviews/**` ist bereits außerhalb des Doc-Gate-Scans (`.d-check.yml`, `exempt-paths`) |
| [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) §CI-Branch | update | die Form-Zeile: Ablageort + Wächter-Grenze, in der bestehenden Ergebnisform-Prosa |
| `../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/evidence/` | update | eine weitere Evidence-Datei je belegten Auftritt (BEFUND-Lauf) |

**Ansatz:** Der Konsum-Schritt wird ergänzt, nicht umgebaut — er existiert
bereits als Lese-Zug (Verifier liest einmal, gleicht den Commit ab, räumt
danach Branches des Slice), der Slice verschiebt nur den Zeitpunkt der
Räumung hinter den Committ des Belegs auf `main`. Die Zwei-Datei-Form des
Retro-Belegs ist Beispiel für die künftige Eine-Beleg-Form je Läufer-Fassung;
ob je Attempt oder je Urteil gespeichert wird, entscheidet die ADR (Risiko 3).

## 4. Trigger

**Start** (`next` → `in-progress`): die ADR des Architects ist `Accepted`
abgelegt und der Retro-Beleg-Zugriff ist bestätigt — das Job-Log
(Run 45625795106) liest sich, oder der Branch-File-Weg liefert
`mutate-ergebnis.txt` über `git show FETCH_HEAD:mutate-ergebnis.txt`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die ADR wächst um
  einen zweiten Träger (etwa ein Sensor über die Ablage-Form) — dann wird
  der Sensor-Festlegungs-Teil in einen eigenen Slice geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): das Job-Log von
  Run 45625795106 ist abgelaufen oder unlesbar **und** der Branch-File-Weg
  liefert die Grün-Fassung nicht — dann ist der Retro-Beleg (Liefer-Punkt 2)
  nicht mehr holbar; der Slice geht zurück, der Verfall trägt den
  Risiko-Ausgang `eingetreten`.

## 5. Closure-Trigger

DoD vollständig — ADR `Accepted`, die zwei Retro-Belege getrackt im
Ablageort committet, die Form-Zeile in
[`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) steht,
Review-Report liegt vor — **und** der Lerneintrag §7 nennt die Beobachtung
aus dem Konsum-Übergang. Beobachtbare Bedingung: die zwei Belege lösen über
`git log -- docs/reviews/mutate/` auf, und der nächste Mutations-CI-Lauf
kann seinen Beleg nach derselben Form ablegen.

## 6. Risiken und offene Punkte

- **Log-Verfall (~90 Tage, GitHub-Logs) für das `Urteil: gruen` von
  Run 45625795106** — dringlich: der Rückgriff auf den Retro-Beleg ist jetzt
  noch möglich. **Ausgang-Vorlage:** `entfallen`, sobald die zwei Retro-Belege
  committet sind (der Beleg liegt getrackt und datiert vor); bei Verfall
  vor der Entnahme → `eingetreten` mit Carveout, daß das Grün-Urteil des
  Sprungs beleglos bleibt und die Klasse der Wiederholung überlassen wird.
  **Entscheidet bei** Closure im Licht des Start-Triggers.
- **`ergebnis`-Job-Push bricht non-fast-forward — heute zweimal beobachtet**;
  der Konsum-Schritt dieses Slice liest das Branch-File **vor** der
  Räumung, hängt also nicht an einem Push-Fail-Zustand; das Risiko ist der
  Beleg-Rest des BEFUND-Laufs, falls sein File nur im Branch-History
  liegt. **Ausgang-Vorlage:** `weiter offen` → Register
  (`BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`), falls der
  BEFUND-Beleg nicht aus dem Branch-History holbar ist; sonst `entfallen`
  mit dem committeten BEFUND-Beleg als Grund.
- **Doppelte Belege je Würfel-Runde** — je Attempt oder je Urteil
  gespeichert? Open-Frage an den Architect (die BEFUND-Belege der
  Grüenvorlauf-Klasse sind Infra-Befunde ohne grün-Urteil, die
  Wiederholung des Laufs ohne Befund wäre Urteil-Wiederholung). **Ausgang-Vorlage:**
  `entfallen`: die ADR des Architects (Liefer-Punkt 1) trägt die Antwort;
  bis dahin gilt die Zwei-Beleg-Form des Retro-Belegs als Beispiel, nicht als Regel.

## 7. Closure-Notiz

*(wird bei der Closure gefüllt — vor dem `git mv` nach `done/`, das letzte
DoD-Item nach ihm)*

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist eine Sub-Area —
`*` (gesamtes Repo, Kürzel `ALL` aus
[`harness/conventions.md`](../../../../harness/conventions.md) §Modus-Deklaration:
`docs/reviews/` trägt in der Deklaration kein eigenes Kürzel, der Mutations-CI-Weg ist repo-übergreifend —
nichts Engeres existiert und zu grob ist `*` hier nicht, denn der Gegenstand
ist repo-übergreifend deklariert). Die drei Achsen: Konventions-Dichte
(die Ablage-Regel des Beleg-Ablageorts wird durch diesen Slice verankert),
Phase-Reife (Phase 4 — CI-Betrieb läuft, Belegmechanik entsteht),
Berührungs-Konkurrenz (keine dritte Achse, die eine Fein-Aufteilung trägt) —
Schwelle ≥ 2 von 3 erfüllt.

**Vorgelagert — offene Beobachtungen sichten** (Register
`../observations/` durchgegangen, gemergter Stand):

- Treffer: `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last` — **offen,
  Zähler steht bei 1** (unter der Schwelle). Dieser Slice liefert mit dem
  BEFUND-Beleg des Retro-Laufs den zweiten Auftritt — er hebt den Zähler auf
  2 und bleibt unter der Lücken-Schwelle; Evidenz-/Diskrepanz-Risiko
  dadurch erhöht (dieser Slice ist selbst der Beleg).
- Treffer verwandt, aber kein Gegenstand: `BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`
  — **gestrichen** (4 Beleg-Auftritte, Grund im `state.md`: kein Rollen-Lauf
  braucht den Beleg-Slot des lokalen Vollaufs mehr). Dieser Slice schreibt
  den CI-Beleg nach, nicht den lokalen Slot — Zitat statt Neuformulierung,
  damit das Register sie nicht als zweite Klasse trennt.
- Übrige `mutate-*`-Einträge betreffen Fall-Anlage, Treiber-, Runner- und
  Sharding-Klassen — keine Treffer, notiert.

**Modus-Begründungsblock:** alle berührten Sub-Areas sind GF
(`*` (gesamtes Repo) ist in der Modus-Deklaration GF, Doc führt) — der
Hinweis genügt, ein Block pro Sub-Area entfällt.
