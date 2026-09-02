# Slice 149: Welle-10 trägt ihre drei fehlenden Belege

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — seine drei Liefer-Punkte
sind Closure-Kriterien aus deren §3 (dritter Sensor, Trigger-Audit), die kein
anderes Mitglied trägt; ohne diesen Slice bliebe der Rest bei `/close-welle`
unvorbereitet.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Liefer-Punkt 1, `make full-smoke`). Die Liefer-Punkte 2 und 3 sind
Harness-Prozesspflichten aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wellen-Closure-Prozedur (Trigger-Audit, Beobachtungs-Register) ohne eigene
`LH-*`-Kennung.

**Berührte Spec-Stellen:** — Dieser Slice ändert keine Aussage der Spec; er
liefert Prozess-Belege für die Wellen-Closure.

**Verantwortlich:** Planner (pt9912). Modul 5 besetzt das Feld per Default mit
dem Rolleninhaber der **Implementer**-Rolle; keiner der drei Liefer-Punkte
dieses Slice ist Implementer-Arbeit. Das Feld sagt, **wer die Arbeit hält**,
nicht wer jeden Teilschritt ausführt — und gehalten wird sie nach der
Wellen-Closure-Rollentabelle aus Modul 8 vom Planner: er trägt Liefer-Punkt 2
(Schritt 2, Carveout-Zweig) und Liefer-Punkt 3 (Schritt 3a, Lese-/Schreib-Schritt
am Register) allein und ist bei Liefer-Punkt 1 der **Empfänger** des
Übergabe-Artefakts (Schritt 1: Verifier → Planner, repo-weiter
Verifikations-Beleg). Zwei Übergaben bleiben und wechseln den Halter nicht:
dieser Beleg, und — falls ein Re-Evaluierungs-Trigger feuert — das
Architect-Verdikt aus Liefer-Punkt 2, das eine Folge-ADR nach
[`AGENTS.md`](../../../../AGENTS.md) §3.8 ohnehin nur der Architect schreibt.
Die Abweichung vom Default trägt dieselbe Begründung wie bei
[slice-084](../done/slice-084-stichprobe-gegen-bestand.md) und
[slice-131](../done/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md):
der Liefergegenstand sind lebende Plan-Dateien, keine Code-Änderung.

**Autor:** Planner. **Datum:** 2026-08-31.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Welle-10 hat drei Closure-Voraussetzungen aus ihrem eigenen §3, die kein
geschnittenes Mitglied hält — dieser Slice liefert sie: den dritten Sensor
außerhalb der Gates (`make full-smoke`), den Trigger-Audit über die drei in
Modul 6 genannten Artefaktklassen (Carveouts, bootstrap-aware Gates, ADRs) und
die Registrierung zweier in dieser Planungsrunde gemessener Beobachtungen.**

Acht der vierzehn Mitglieder von welle-10 liegen heute nicht in `done/`
(`for s in 080 081 082 083 084 085 130 131 132 133 136 147 148 149; do ls
docs/plan/planning/*/slice-$s-*.md; done`) — dieser Slice hängt an keinem
davon: seine drei Liefer-Punkte sind unabhängig vom übrigen Wellen-Fortschritt
ausführbar. **Nicht Gegenstand dieses Slice** ist die inhaltliche Arbeit der
übrigen offenen Mitglieder
([slice-083](../done/slice-083-form-vergleich-pflichtfelder.md),
[slice-084](../done/slice-084-stichprobe-gegen-bestand.md),
[slice-085](../in-progress/slice-085-emittierte-ebene-zieht-nach.md),
[slice-131](../done/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md),
[slice-136](../open/slice-136-roadmap-traegt-die-ziel-form.md),
[slice-147](../done/slice-147-spezifikation-traegt-ihr-id-schema.md),
[slice-148](../done/slice-148-architecture-traegt-ihr-id-schema.md)) — jedes
davon hat seinen eigenen Träger und wird hier nicht gedoppelt. **Ebenfalls
nicht Gegenstand:** die eigentliche `welle-10-results.md` und der `git mv` der
Welle-Datei nach `done/` — Modul 6 setzt dafür voraus, dass **alle** Mitglieder
inklusive dieses Slice bereits in `done/` liegen (Schritt 3 der
Closure-Prozedur); das bleibt bei `/close-welle`, sobald der Rest geschlossen
ist.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) `make full-smoke` gefahren, Ausgang (Exit-Code + Kern-Zeile) in
      §7 dokumentiert** — der einzige der drei in
      [welle-10](../welle-10-re-baseline.md) §3 verlangten Sensoren, der laut
      `in-progress/roadmap.md` (Abschnitt *Aktuelle Welle*) noch nicht
      committet gemessen ist. `make smoke` und `make mutate` sind, falls ihr
      letzter grüner Lauf nicht mehr aktuell ist, hier erneut zu bestätigen —
      kein Wert wird übernommen, der nicht selbst gelaufen ist
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [x] **(2) Trigger-Audit der Welle durchgeführt** (Modul 6 Closure-Schritt 2,
      drei Artefaktklassen): jeder offene Carveout
      (`ls docs/plan/carveouts/CO-*.md`) auf seinen Auflösungs-Trigger geprüft
      und sein Ausgang bestätigt oder nachgetragen; jede bootstrap-aware
      Gate-Stufe geprüft (Bestand heute: keine —
      `grep -c bootstrap-aware harness/conventions.md` → **0**, Feststellung,
      kein Auslassen); jede der acht ADRs, die welle-10 selbst zitiert
      (`{ sed -n '13,90p' docs/plan/planning/in-progress/roadmap.md; cat
      docs/plan/planning/welle-10-re-baseline.md; } | grep -ohE
      'ADR-[0-9]{4}' | sort -u`), auf ihren Re-Evaluierungs-Trigger geprüft —
      mit Architect-Verdikt (Planner→Architect→Planner), falls einer feuert.
- [x] **(3) Beobachtungs-Register (`../observations.md`) trägt die zwei in
      dieser Planungsrunde gemessenen Kandidaten** (§6) als neue
      `BEO-<NNN>`-Einträge mit Beleg `slice-149`.
- [x] `make gates` grün.
- [x] Doku-Update für einen öffentlichen Vertrag falls berührt — hier keiner:
      Gegenstand sind Prozess-Belege, keine Schnittstelle.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register — Repo hat keinen Brownfield-Bootstrap
      (`ls docs/plan/planning/reconciliation.md` → nicht vorhanden); das Item
      entfällt.
- [x] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/planning/observations.md` | update | zwei neue `BEO-<NNN>`-Einträge (Sub-Area `*`), Beleg `slice-149` |
| `docs/plan/carveouts/CO-001-bats-shell-lint.md` | update (Geschichte-Zeile) | Auflösungs-Trigger erneut abgefragt, Prüfdatum nachgetragen |
| `docs/plan/carveouts/CO-002-token-achse-je-rolle.md` | update (Geschichte-Zeile) | Status `Permanent` bestätigt, kein neuer Trigger |
| die acht per Kommando ermittelten ADR-Dateien unter `docs/plan/adr/` | prüfen, ggf. Geschichte-Zeile | Re-Evaluierungs-Trigger je ADR abgefragt; ein feuernder Trigger geht als Verdikt an den Architect, nicht in eine Datei-Änderung dieses Slice |
| — (kein Datei-Artefakt) | Messung | `make full-smoke` gegen den gepinnten Baum, Ausgang in §7 |
| diese Slice-Datei | update (§7) | Closure-Notiz vor dem `git mv` |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei. Keine fachliche
Vorbedingung: die drei Liefer-Punkte hängen an keinem anderen Mitglied von
welle-10 (§1). Einzige praktische Bedingung für Liefer-Punkt 1 ist ein ruhiger
Baum mit Netzzugriff (`make full-smoke` zieht gepinnte Images).

**Der Deckel ist gemessen, nicht überschlagen — und die zwei Lesarten von Modul 5
§Trigger je Lifecycle-Übergang und WIP-Limit laufen hier auseinander:**
`ls docs/plan/planning/in-progress/slice-*.md | wc -l` → **1**
([slice-084](../done/slice-084-stichprobe-gegen-bestand.md)).

1. **Wortlaut.** Der Deckel zählt „pro Mensch in der **Implementer**-Rolle,
   nicht pro Rolle". Die eine Datei in `in-progress/` trägt
   `Verantwortlich: Planner (pt9912)`
   (`grep -h -m1 '^\*\*Verantwortlich:\*\*' docs/plan/planning/in-progress/slice-*.md`),
   dieser Slice ebenso. Unter dem Wortlaut steht der Implementer-Stand auf
   **0**, und beide Slices liegen außerhalb der gezählten Menge.
2. **Zweck-Klausel.** *„wer mehrere Slices gleichzeitig in `in-progress/` hat,
   hat keine Lifecycle, sondern ein Buffet"* bindet an den **Menschen** ohne
   Rollen-Einschränkung und wäre durch denselben `pt9912` zweimal verletzt. Sie
   ist es nicht: slice-084 hat alle drei Liefer-Punkte **und** `make gates`
   abgehakt und offen allein seine Closure-Notiz
   (`grep -c '^- \[x\]'` → **4**, `grep -c '^- \[ \]'` → **1** über dieser
   Datei). Was danebensteht, ist kein zweiter *laufender* Arbeitskontext,
   sondern ein abgeschlossener, der auf seine Closure wartet — genau das, wovor
   die Klausel nicht warnt.

**Beide Lesarten sagen damit dasselbe: slice-084 blockiert diesen Slice nicht.**
Dass sie sich überhaupt trennen lassen, liegt daran, dass dieses Repo das Feld
`Verantwortlich:` regelmäßig mit Planner und Architect besetzt (Präzedenz im
Kopf) — für eine Besetzung, die der Deckel nicht kennt, ist er kein Wächter. Das
ist eine Feststellung dieses Slice und keine Norm-Änderung; wer sie zur Regel
machen will, geht über [`AGENTS.md`](../../../../AGENTS.md) §3.8.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der ADR-Zweig
  des Trigger-Audits (Liefer-Punkt 2) einen Verdikt mit eigenem
  Umsetzungs-Aufwand liefert (z. B. eine inhaltliche Folge-ADR statt einer
  reinen Bestätigung) — dann bleibt bei diesem Slice die Audit-Feststellung,
  die Umsetzung wird ein eigener Folge-Slice.
- `in-progress` → `open` (blockiert — Carveout?): wenn `make full-smoke` an
  einer Stelle scheitert, die außerhalb dieses Slice liegt (typisch: eine
  Lücke, die erst [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md),
  [slice-136](../open/slice-136-roadmap-traegt-die-ziel-form.md),
  [slice-147](../done/slice-147-spezifikation-traegt-ihr-id-schema.md),
  [slice-148](../done/slice-148-architecture-traegt-ihr-id-schema.md),
  [slice-085](../in-progress/slice-085-emittierte-ebene-zieht-nach.md) oder
  [slice-084](../done/slice-084-stichprobe-gegen-bestand.md) beheben)
  — dann zurück nach `open/` mit dem Fund als neuem Risiko oder Carveout.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig (drei Liefer-Punkte mit Beleg in §7) + `make gates` grün +
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Beobachtungs-Kandidat (a) — eine Re-Baseline eröffnet mit einem
  Inventur-Slice.** welle-10 ist mit 6 Slices geschnitten (`080`–`085`,
  `harness/conventions.md` §Baseline) und trägt mit diesem Slice 14
  Mitglieder
  (`awk '/^## 4\. Slices/,/^## 5\./' docs/plan/planning/welle-10-re-baseline.md
  | grep -c '^| slice-'`, nach Eintrag von slice-149) — 8 Nachzügler in drei
  Ursachen-Klassen: vendored Baum als Eingabe/Emissionskanal (130–133, vier),
  Singleton-Form-Pflichtfeld (136, 147, 148 und der zweite Schnitt von 083,
  vier; welle-10-re-baseline.md §4, Absätze *„ist der fünfte Nachzügler"* und
  *„147 und 148 sind kein Nachzügler wie 130–133/136"*), trägerloser
  Ziel-Prozedur-Rest (dieser Slice, einer). Ein vorgeschalteter Inventur-Slice
  — Form-Diff aller Singleton-Vorlagen alt/neu plus Trefferzahl je neuer
  Pflicht, als erster Liefer-Punkt vor dem Rest-Schnitt — hätte die vier der
  zweiten Klasse vorweggenommen, nicht die sieben der ersten und dritten. —
  **Ausgang:** **weiter offen** → Beobachtungs-Register,
  [`BEO-010`](../observations.md) (Sub-Area `*`, 1×, Beleg `slice-149`,
  angelegt unter DoD (3)). Kein Folge-Slice: der Eintrag steht bei 1× und
  wartet auf den Lese-Schritt, der bei 3× greift.
- **Beobachtungs-Kandidat (b) — jede Minor-Version wird adoptiert, nicht
  gesammelt.** Kostenreihe laut `harness/conventions.md` §Baseline: `v3.1.0`
  → 2 Slices (slice-011/012), `v3.5.0` → 1 (slice-019), `v3.5.1` → 1
  (slice-043), `v3.5.2` → 1 (slice-049); `v5.12.0` (dieser Sprung, welle-10)
  → 14 Mitglieder heute (Kommando oben). Der Unterschied ist die
  Sprungweite — zwei übersprungene Major-Versionen
  (welle-10-re-baseline.md §1) —, nicht der Prozess selbst. **Ob das über
  eine geschärfte Regel hinaus eine ADR verlangt, ist eine Einschätzung,
  keine Entscheidung dieses Slice:** es ist eine Norm-Aussage über den
  Adoptions-Rhythmus künftiger Baseline-Sprünge, verwandt mit der Frage, die
  [ADR-0018](../../adr/0018-ziel-fassung-regiert-die-migration.md) §Wer den
  Zielstand bewegt für den Einzelfall entscheidet — hier für die
  wiederkehrende Klasse. — **Ausgang:** **weiter offen** →
  Beobachtungs-Register, [`BEO-011`](../observations.md) (Sub-Area `*`, 1×,
  Beleg `slice-149`, angelegt unter DoD (3)). Der Eintrag führt den nächsten
  Fall bereits mit: `make baseline-freshness` meldet am 2026-09-01
  `gepinnt: v5.12.0` gegen `latest: v5.18.0` bei Exit 2 (beide Angaben wandern
  mit dem Upstream-Stand und sind keine Erwartungswerte,
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Ob daraus über eine geschärfte Regel hinaus eine ADR wird, bleibt
  Architect-Sache ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — die Übergabe zu
  Liefer-Punkt 2 hat sie nicht ausgelöst, weil dort kein
  Re-Evaluierungs-Trigger feuerte.
- **`make full-smoke` könnte einen Befund melden, der außerhalb dieses Slice
  liegt** — z. B. weil der emittierte Baum erst mit
  [slice-083](../done/slice-083-form-vergleich-pflichtfelder.md),
  [slice-136](../open/slice-136-roadmap-traegt-die-ziel-form.md),
  [slice-147](../done/slice-147-spezifikation-traegt-ihr-id-schema.md),
  [slice-148](../done/slice-148-architecture-traegt-ihr-id-schema.md) oder
  [slice-085](../in-progress/slice-085-emittierte-ebene-zieht-nach.md) vollständig
  konform wird. — **Ausgang:** **entfallen** → der Lauf endete Exit **0** ohne
  Befund (Kern-Zeile in §7, Liefer-Punkt 1). Keiner der fünf oben genannten
  Träger wurde gebraucht, und die Rückführung `in-progress` → `open` aus §4
  wurde nicht ausgelöst.
- **Der ADR-Zweig des Trigger-Audits könnte einen Re-Evaluierungs-Trigger
  feuern**, der eine Folge-ADR nötig macht — das bindet einen Architect-Lauf,
  den dieser Slice nicht selbst vorwegnehmen kann. — **Ausgang:** **entfallen**
  → alle acht ADRs des Audits (DoD (2)) sind auf ihren Re-Evaluierungs-Trigger
  geprüft, keiner feuert; damit kein Architect-Verdikt, keine Folge-ADR und
  keine Rückführung `in-progress` → `next` aus §4.
- **`Verantwortlich:` hat keinen sauberen Rolleninhaber.**
  Modul 5 definiert das Feld über die Implementer-Rolle; die drei
  Liefer-Punkte dieses Slice sind nach der Wellen-Closure-Rollentabelle aus
  Modul 8 Verifier-/Planner-/Architect-Arbeit. — **Ausgang:** **entfallen** →
  beim Übergang `open→next` entschieden, an der Stelle, die dieser Punkt dafür
  benannt hatte; das Feld steht seither auf `Planner (pt9912)` (Kopf dieser
  Datei, gesetzt im Priorisierungs-Commit `2c67711`).
  **Begründung:** Das Feld nennt den **Halter** der Arbeit, nicht
  den Ausführenden jedes Teilschritts; gehalten wird sie vom Planner, der zwei
  der drei Liefer-Punkte allein trägt und beim dritten Empfänger des
  Übergabe-Artefakts ist (Kopf, mit Präzedenz slice-084/slice-131). Die Lücke im
  **Wortlaut** von Modul 5 bleibt bestehen — sie ist aber keine Eigenschaft
  dieses Slice, sondern eine des Deckels und der Default-Besetzung, und steht
  als solche in §4.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Liefer-Punkt 1 — die drei Sensoren außerhalb der Gates** (Läufe vom
2026-09-01; die Zahlen wandern mit dem Baum und sind keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

1. **`make full-smoke` → Exit 0.** Kern-Zeile: `full-smoke: OK — frisch
   gebootstrapptes Repo faehrt make -j gates out-of-the-box gruen
   (lint/build/test + docs-check + baseline-verify via Fragment-Assembly,
   record-gates zuletzt), Exit 0 (LH-FA-01/LH-QA-01).` Das ist der Beleg, den
   [welle-10](../welle-10-re-baseline.md) §3 als dritten Sensor verlangt und
   der bis zu diesem Slice als einziger nicht committet gemessen war.
2. **`make smoke` → Exit 0**, `d-check: 20 Datei(en) geprueft, 0 Befund(e)`.
   Bestätigt statt übernommen ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
3. **`make mutate` → Exit 0**, `214 ok, 0 Befund(e)`, Vollständigkeit über
   alle 214 Fall-Dateien. Verlangt ist er in genau dieser Form und nicht als
   Exit-Code, weil ein Lauf mit rotem Grün-Vorlauf über **null** Fälle liefe
   (welle-10 §3).

**Closure-Kriterien (beobachtet, nicht behauptet):**

1. **DoD vollständig.** Alle Punkte aus §2 sind gehakt —
   `grep -c '^- \[ \]' docs/plan/planning/*/slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md`
   → **0** offene Punkte (der Glob trägt den Aufruf über den `git mv` hinweg).
2. **`make gates` grün** nach dem Commit dieser Closure-Notiz — der
   Stop-Hook-Stempel deckt den Arbeitsbaum.

- **Was hat funktioniert:** Der Schnitt trug seine eigene Behauptung. §1 sagte
  zu, die drei Liefer-Punkte hingen an keinem anderen Mitglied der Welle; sie
  liefen vollständig durch, während **7** andere Mitglieder weiter offen sind
  (`for s in 080 081 082 083 084 085 130 131 132 133 136 147 148 149; do ls
  docs/plan/planning/*/slice-$s-*.md; done | grep -v '/done/' | grep -vc
  'slice-149'`; die Zahl wandert mit dem Wellen-Fortschritt und ist kein
  Erwartungswert). Der Trigger-Audit fand seine drei
  Gegenstände über Kommandos statt über abgeschriebene Listen
  (`ls docs/plan/carveouts/CO-*.md` · `grep -c bootstrap-aware
  harness/conventions.md` · das `grep -ohE 'ADR-[0-9]{4}'` aus DoD (2)) — die
  Bezugsmenge jeder der drei Artefaktklassen ist damit zum Prüfzeitpunkt
  erhoben statt aus dem Plan übernommen. Und der dritte
  Risiko-Ausgang hatte diesmal einen Ort: beide Beobachtungen gingen ins
  Register, statt als Folge-Slice geschnitten zu werden — genau die Route, die
  [`BEO-001`](../observations.md) verkörpert hat.
- **Was ging anders als geplant:** Zwei Dinge. (1) `make mutate` war im ersten
  Lauf rot, und zwar ohne Fall-Befund: ein Docker-Hub-502 beim Image-Zug. Der
  Zweitlauf lief sauber. §4 führt die Netz-Bedingung nur als Startbedingung für
  `make full-smoke`; sie gilt für `make mutate` genauso, und ein Netz-Fehlschlag
  sieht in der Ausgabe zunächst aus wie ein Sensor-Rot. (2) Der Carveout-Zweig
  des Audits endete nicht bei *aufgelöst* oder *unverändert gültig*, sondern
  beim dritten Ausgang: [`CO-001`](../../carveouts/CO-001-bats-shell-lint.md)
  ist **verlängert mit Folge-Slice** — sein Trigger ist seit dem
  welle-12-Audit eingetreten und der Bestand wächst weiter
  (`git ls-files 'test/*.bats' | wc -l` → **20**). Damit bleibt ein offener
  Carveout auf dem Gate `shell-lint` stehen. Ob er unter das Welle-Kriterium
  *„`make gates` grün — und zwar ohne offenen Carveout auf einem Gate dieser
  Welle"* (welle-10 §3) fällt, entscheidet die Welle-Closure; dieser Slice
  stellt den Befund fest und legt ihn nicht aus.
- **Steering-Loop-Eintrag: zwei benannte Lücken, gezählt statt verkörpert.**
  (a) Eine Re-Baseline wird ohne vorgeschalteten Inventur-Slice eröffnet, und
  die Form-Pflichten der neuen Fassung kommen einzeln als Nachzügler zurück
  ([`BEO-010`](../observations.md), 1×). (b) Baseline-Sprünge werden gesammelt
  statt einzeln adoptiert, und die Kosten einer Re-Baseline wachsen mit der
  Sprungweite statt mit dem Prozess ([`BEO-011`](../observations.md), 1×).
  Keine der beiden ist mit diesem Slice verkörpert: beide stehen bei 1×, der
  Lese-Schritt greift bei 3×. (b) ist zusätzlich eine Norm-Aussage über den
  Adoptions-Rhythmus und damit Architect-Sache
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8) — ein Planner-Slice kann sie
  benennen, nicht schreiben.
- **Beobachtungs-Register (`../observations.md`):** zwei neue Kennungen —
  [`BEO-010`](../observations.md) (Sub-Area `*`, 1×, Beleg `slice-149`) und
  [`BEO-011`](../observations.md) (Sub-Area `*`, 1×, Beleg `slice-149`). Kein
  bestehender Eintrag wurde erhöht: keine der vorgefundenen Zeilen deckt eine
  der beiden Beobachtungen, und der Sichtungs-Schritt in §8 hat das vor dem
  Anlegen geprüft.
- **Folge-Slices:** keine neuen aus diesem Slice. Der Carveout-Ausgang
  *verlängert mit Folge-Slice* nennt zwei, die beide schon als Datei im
  Planning-Lifecycle liegen und nicht dieselbe Arbeit sind:
  [slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md)
  (`next/`) entscheidet **vorher** zwischen den zwei Techniken,
  [slice-113](../open/slice-113-co-001-ist-faellig.md) (`open/`) **führt aus**.
- **Risiken aus §6:** fünf benannt
  (`awk '/^## 6\. Risiken/,/^## 7\. Closure-Notiz/'
  docs/plan/planning/*/slice-149-welle-10-traegt-ihre-drei-fehlenden-belege.md
  | grep -c '^- \*\*'` → **5**), fünf mit genau einem Ausgang — zwei *weiter
  offen* ins Register (`BEO-010`, `BEO-011`), drei *entfallen* (grüner
  `full-smoke`-Lauf ohne Befund · kein feuernder ADR-Trigger ·
  `Verantwortlich:` beim Übergang `open→next` gesetzt), keines *eingetreten*.
- **Drei Paarungen:** hier **nicht** geprüft. Dieses Repo führt
  Wellen-Betrieb, und dieser Slice ist Mitglied von
  [welle-10](../welle-10-re-baseline.md); Modul 6 §Wellen-Closure-Prozedur legt
  die Paarungen (Anker · Folge-Slice · Register) auf Closure-Schritt 3c —
  **nach** dem `git mv` der Welle-Datei, weil sie die dort erst entstehenden
  Einträge prüfen —, und Modul 8 §Rollen-Sequenz für eine Welle weist denselben
  Schritt dem Planner-Kontext der Welle-Closure zu. Die DoD-Zeile in §2 führt
  genau diese Unterscheidung; die hier fällige Hälfte ist, die Prüfung dorthin
  zu übergeben, statt sie zu doppeln.

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind
`docs/plan/planning/`, `docs/plan/carveouts/` und `docs/plan/adr/`. Alle drei
fallen unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)
— **alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit
(Template-Kurzform).

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen
(`docs/plan/planning/observations.md`). Die Sub-Area-Spalte trägt nur `*` und
schließt damit jede Berührung ein ([`BEO-004`](../observations.md)); **kein
Eintrag erreicht mit diesem Slice 3×** — der höchste Stand (`BEO-001`, 6×) ist
bereits verkörpert, der zweithöchste (`BEO-003`, `BEO-007`, je 2×) wird von
diesem Slice weder erhöht noch berührt. Die zwei Einträge, die dieser Slice nach
DoD (3) selbst anlegt, stehen bei 1× und ändern daran nichts. Keine Lücke, die
einen eigenen Folge-Slice bräuchte. Die Zahl der Register-Zeilen steht hier
nicht: sie wächst mit jeder Closure und wäre ein Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); den Stand liefert
`grep -c '^| BEO-' docs/plan/planning/observations.md`.
