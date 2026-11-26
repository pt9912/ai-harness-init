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

- **Kein Turn-Gate und kein Stop-Hook-Stempel im Sinne von [`ADR-0083`](../../../../docs/plan/adr/0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)** —
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
  der Beleg liest dieselbe Form, nur aus docs/reviews/mutate/ statt von
  der Branch-Wurzel.
- **Keine Auslagerung des Belegs in den git-eigenen Isolations-Schlüssel** —
  [`ADR-0035`](../../../../docs/plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) trägt
  die Klassifikation grün/rot je Fall am `mutate-passed.key`, nicht die
  Ergebnis-Fassung; ein zweiter Träger desselben Urteils daneben driftet.
  Der Schlüssel bleibt, was er ist.

## 2. Definition of Done

- [x] ADR des Architects `Accepted` und abgelegt: der Form- und
      Träger-Beschluss — Ablageort `docs/reviews/mutate/`, Namensform mit
      voller Slice-Kennung, Konsum-Schritt-Sender (wer schreibt, woraus,
      in welchem Rollen-Übergang) — Übergabe Planner → Architect →
      Planner gemäß Modul 8, vor der Implementation (Vorgänger-Muster
      [`slice-d-check-sprung-v0930.md`](../done/slice-d-check-sprung-v0930.md));
      die offenen Architektur-Fragen aus §6 tragen dort ihre Antwort.
      → belegt: [`ADR-0102`](../../../../docs/plan/adr/0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md),
      Commit `f545a019`; Festlegungen 1–4 antworten die §6-Fragen (Granularität je
      Festlegung 2, Konsum-Reihenfolge je Festlegung 3, Kein-Wächter-Grenze je
      Festlegung 4).
- [x] Retro-Beleg für [`slice-d-check-sprung-v0930.md`](../done/slice-d-check-sprung-v0930.md)
      als Record-Dateien im festgelegten Ablageort committet:
      vier Dateien über drei Vorgänge (`slice-d-check-sprung-v0930` mit Grün- und
      befund-infra-Fassung je Commit `625cdef0`, Teil-Ernte `slice-c3-d-check-faecher-v7-0-0`
      und `slice-c7-adaptions-nachzuege-v7-0-0` je `3880063f` befund-last) —
      Plan-Korrektur: der Plan nannte zwei Dateien, die Teil-Ernte kam mit dem
      Claim-Zug des Tages hinzu · Commits `79757bc2` (Belege + Form-Zeile) und
      `1491d74f` (Kopf-Formen je ADR-0102 Festlegung 2: ein Urteil je Run, der
      zweite Versuch nur am Job-Log-Kanal belegt): die
      Ergebnis-Fassung des Grün-Laufs (`Urteil: gruen`, 82/82, Run
      45625795106, Attempt 3 — Quellnachweis über das `gh api`-Log-Kommando
      neben den `git show`-Bytes) und der BEFUND-Inhalt des zweiten Laufs
      (Run 45647457778) je Kopf mit Ausgabe-Kanal (Job-Log oder
      Branch-File) und Commit der Branch-Spitze — belegt Commit `79757bc2`
      (zwei Paar-Dateien) · `1491d74f` (Kopf-Nachzug je F-3, geheilt).
- [x] Form-Zeile in [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md)
      §CI-Branch ergänzt: der Konsum-Schritt nennt den Ablageort und die
      Grenze, dass kein Wächter die Ablage-Form hält (`AGENTS.md` §3.6 —
      benannt statt erfunden) — belegt Commit `79757bc2`, Nachzug der
      `MR-051`-Link-Form `7f466d0c`.
- [x] `make gates` grün — belegt Lauf mit Stempel auf `1491d74f`.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — belegt
      `docs/reviews/2026-11-25-slice-mutations-beleg-eingecheckt.md`, Commit
      `e98122d1`; HIGH 1 (F-1, geheilt `dd268ee1`), MEDIUM 1 (F-2 — Plan-Defekt,
      hier berichtigt), LOW 1 (F-3, geheilt `1491d74f`).
- [x] Doku-Update für den Mutations-CI-Weg — belegt die Form-Zeile in
      `harness/sensors/mutate.md` §CI-Branch (Commits `79757bc2`/`7f466d0c`).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag — §7 dieses Commits.
- [x] Beobachtungs-Register (`../observations/`) — Plan-Korrektur je F-2:
      der BEFUND-Beleg zitiert die Klasse
      `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`, statt sie zu
      zählen — der Fund teilt seinen Vorgang (`slice-d-check-sprung-v0930`)
      mit der bestehenden Evidence-Datei („ein Vorgang zählt einmal");
      keine dritte Evidence-Datei, kein Zähler gesetzt.
- [x] Jedes Risiko aus §6 trägt einen Ausgang — §7 dieses Commits.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen —
      im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen
      von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/NNNN-<titel>.md` | neu (Architect) | Form- und Träger-Beschluss des Beleg-Ablageorts; Aufgabeneinheit ist Übergabe P → A → P |
| `docs/reviews/mutate/slice-d-check-sprung-v0930-<sha8>.txt` (2 Dateien: Grün-Lauf, BEFUND-Lauf) | neu | der Retro-Beleg, aus dem Job-Log bzw. dem Branch-File entnommen, je Kopf mit Ausgabe-Kanal und Branch-Spitze |
| `docs/reviews/mutate/` als Verzeichnis | neu | der Ablageort selbst; `docs/reviews/**` ist bereits außerhalb des Doc-Gate-Scans (`.d-check.yml`, `exempt-paths`); der `d-check:ignore`-Marker der Plan-Vorlage ist mit der realen Existenz des Pfads entfernt |
| [`harness/sensors/mutate.md`](../../../../harness/sensors/mutate.md) §CI-Branch | update | die Form-Zeile: Ablageort + Wächter-Grenze, in der bestehenden Ergebnisform-Prosa |
| `../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/evidence/` | — | keine zweite Evidence-Datei — Plan-Korrektur je F-2: der BEFUND-Fund teilt seinen Vorgang (`slice-d-check-sprung-v0930`) mit der bestehenden Beleg-Datei; Zitat statt Zählung |

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
  **Ausgang:** `entfallen` — der Beleg ist entnommen:
  `docs/reviews/mutate/slice-d-check-sprung-v0930-625cdef0-gruen.txt` aus dem
  Job-Log von Run 45625795106 (Attempt 3), committet `79757bc2` vor dem
  Verfall; der Kopf trägt Lesekommando und Entnahme-Stand je ADR-0102
  Festlegung 2.
- **`ergebnis`-Job-Push bricht non-fast-forward — heute zweimal beobachtet**;
  der Konsum-Schritt dieses Slice liest das Branch-File **vor** der
  Räumung, hängt also nicht an einem Push-Fail-Zustand; das Risiko ist der
  Beleg-Rest des BEFUND-Laufs, falls sein File nur im Branch-History
  liegt. **Ausgang-Vorlage:** `weiter offen` → Register
  (`BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`), falls der
  BEFUND-Beleg nicht aus dem Branch-History holbar ist; sonst `entfallen`
  mit dem committeten BEFUND-Beleg als Grund.
  **Ausgang:** `entfallen` — der Branch-File-Kanal war gelesen, bevor
  geräumt wurde; der BEFUND-Beleg (und die zwei Teil-Ernten der
  befund-last-Klasse) liegen committet (`79757bc2`), die Köpfe nennen
  Ausgabe-Kanal, Lesekommando und Entnahme-Stand; Räumung nach dem
  Konsum-Schritt (Festlegung 3), `git ls-remote origin 'refs/heads/mutate/*'` → leer.
- **Doppelte Belege je Würfel-Runde** — je Attempt oder je Urteil
  gespeichert? Open-Frage an den Architect (die BEFUND-Belege der
  Grüenvorlauf-Klasse sind Infra-Befunde ohne grün-Urteil, die
  Wiederholung des Laufs ohne Befund wäre Urteil-Wiederholung). **Ausgang-Vorlage:**
  `entfallen`: die ADR des Architects (Liefer-Punkt 1) trägt die Antwort;
  bis dahin gilt die Zwei-Beleg-Form des Retro-Belegs als Beispiel, nicht als Regel.
  **Ausgang:** `entfallen` — [`ADR-0102`](../../../../docs/plan/adr/0102-mutations-ci-ergebnisse-tragen-als-eingecheckte-beleg-datei.md)
  trägt die Antwort: Festlegung 2 (ein Urteil je Run; je Kopf die
  Versuchs-Angabe — der zweite Versuch ist nur am Job-Log-Kanal belegt) und
  Festlegung 4; die Record-Datei trägt die Ergebnis-Fassung, nicht je
  Versuch.
- **3×-Schwelle der Klasse `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last`** —
  nachgetragen je Review F-2: der Plan rechnete für den BEFUND-Fund eine
  Zähler-Erhöhung 1→2 (§8); der Fund teilt seinen Vorgang
  (`slice-d-check-sprung-v0930`) mit der bestehenden Evidence-Datei — ein
  Vorgang zählt einmal, der Zähler bleibt aus den Dateien bei 2. **Ausgang:**
  `entfallen` — die Phantom-Zählung ist berichtigt (Plan-Korrektur §2/§3/§8);
  die Klasse steht bei 2 Belegen über zwei Vorgängen, `Stand: offen`, unter
  der 3×-Schwelle; keine dritte Evidence-Datei angelegt.

## 7. Closure-Notiz

*(gefüllt vor dem `git mv` nach `done/`; das letzte DoD-Item — die drei
Paarungen — trägt der Commit nach dem `git mv`.)*

- **Was hat funktioniert:** Der Konsum-Schritt las den Beleg, **bevor** er
  Branch räumte, und committet ihn ein, bevor der Job-Log-Verfall greift —
  vier Record-Dateien (`slice-d-check-sprung-v0930` Grün + befund-infra;
  `slice-c3-d-check-faecher-v7-0-0` und `slice-c7-adaptions-nachzuege-v7-0-0`
  befund-last) lösen über `git log -- docs/reviews/mutate/` nach ADR-0102
  Festlegung 1 auf; der Kopf je Datei trägt Ausgabe-Kanal, Lesekommando,
  Entnahme-Stand und Versuchs-Angabe je Festlegung 2 (Commit `1491d74f`
  trägt den F-3-Nachzug). ADR-0102 antwortete die drei offenen
  Architektur-Fragen der §6 vor der Implementation.
- **Was ging anders als geplant:** Die Plan-§8-Formel rechnete für den
  BEFUND-Fund einen Zähler-Auftritt 1→2 und plante eine zweite
  Evidence-Datei; die Klasse stehe in Wirklichkeit bei 2 (Belege je
  Vorgang: `slice-d-check-sprung-v0930`, `slice-baseline-vendorung-v7-0-0`),
  und der Fund teilt seinen Vorgang mit der bestehenden Evidence — je
  Review F-2 (Plan-Defekt, hier berichtigt: Zitat statt Zählung) berichtigt.
  Des Weiteren: der Umfang wuchs von zwei geplanten Beleg-Dateien auf vier
  über drei Vorgänge (die Teil-Ernte der befund-last-Klasse kam mit dem
  Claim-Zug des Tages hinzu, Commits `45769037551`/`45769040893` am
  Job-Log-Kanal); der `ergebnis`-Job-Push bricht non-fast-forward
  zweimal (R2, Ausgang unten); die ADR-0102-›Geschichte‹-Zeile trug einen
  Lifecycle-Pfad-Link auf diesen Slice — berichtigt auf Kennungs-Form
  (`dd268ee1`, §3.4-konform außerhalb des Kerns, je F-1).
- **Steering-Loop-Eintrag:** Form-Zeile des Konsum-Schritts geschärft
  (Guide, `harness/sensors/mutate.md` §CI-Branch): **Mutations-Run-Urteile
  tragen als eingecheckte Record-Datei-Kette in `docs/reviews/mutate/`**
  (`<slice-kennung>-<sha8>-[gruen|befund-infra|befund-last].txt`), Konsum-
  Reihenfolge lesen → committen → dann räumen; je ADR-0102-Fassung ein
  Urteil je Run, kein Wächter hält die Ablage-Form (benannt, `AGENTS.md`
  §3.6). Kein `liegt in`-Feld: die Verkörperung lag im Architect-Zug
  (`f545a019` ADR, `79757bc2` Form-Zeile) vor diesem Closure-Zug, nicht am
  Register-3×-Weg — die Anker-Paarung hat hier darum kein Objekt.
  Plan-§8-Korrektur-Kette: Plan-Formel rechnete 1→2 (F-2) → berichtigt auf
  Zitat-Form; keine Register-Neuanlage, kein Zähler-Spiel.
- **Beobachtungs-Register (`../observations/`):**
  `BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/` zitiert statt
  zählt — der BEFUND-Fund (Run 45647457778) ist Teil-Ernte eines Vorgangs,
  den die Evidence-Datei `evidence/slice-d-check-sprung-v0930.md` bereits
  trägt („ein Vorgang zählt einmal“); keine dritte Evidence-Datei. Zähler-
  Ist 2 (je Datei ein Vorgang), `Stand: offen`, unter der 3×-Schwelle.
- **Folge-Slices:** keine.
- **Risiken aus §6:** Log-Verfall → `entfallen` (Beleg entnommen vor dem
  Verfall, `79757bc2`) · non-fast-forward-Push → `entfallen`
  (Branch-File-Kanal gelesen vor der Räumung, Beleg committet) ·
  Doppelte-Belege-Granularität → `entfallen` (ADR-0102 Festlegung 2/4:
  ein Urteil je Run) · 3×-Schwelle-Lage → `entfallen` (F-2-korrigiert:
  Fund zitiert statt zählt, Zähler-Ist 2, Stand `offen`).
- **Drei Paarungen:** Anker — kein Eintrag der §7 trägt das `liegt in`-Feld
  (die Verkörperung kam aus Plan/ADR, nicht über den Register-3×-Weg; die
  Lage steht oben) → kein Prüfling · Folge-Slice — keine genannte Kennung
  → kein Prüfling · Register —
  [`BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/`](../observations/BEO-ALL/mutations-ci-gruenvorlauf-bricht-unter-last/observation.md)
  existiert als Verzeichnis, und die in §7 genannte Zeile trägt zwei
  Belege (`evidence/slice-d-check-sprung-v0930.md`,
  `evidence/slice-baseline-vendorung-v7-0-0.md`) → grün · geprüft im
  Commit nach dem `git mv` nach `done/`.

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
  *Korrektur zur Closure (Review F-2):* diese Formel war eine
  Phantom-Zählung — der Fund teilt seinen Vorgang
  (`slice-d-check-sprung-v0930`) mit der bestehenden Evidence-Datei, ein
  Vorgang zählt einmal. Der Zähler-Ist ist 2 über zwei Vorgänge
  (`evidence/slice-d-check-sprung-v0930.md`,
  `evidence/slice-baseline-vendorung-v7-0-0.md` — die zweite hebe die
  Baseline-Vendorung-Closure `9e48f1f6`, beim Plan-Schnitt `722e119b` noch
  nicht gemergt), der Fund zitiert statt zählt; keine dritte
  Evidence-Datei.
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
