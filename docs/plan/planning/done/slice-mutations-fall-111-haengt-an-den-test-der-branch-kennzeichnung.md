# Slice slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung: Mutations-Fall 111 hängt am Test der branch-Kennzeichnung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — reaktiv (ein Sensor hat gefeuert), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Zahn, der nicht aus dem behaupteten Grund fällt, ist ein stilles Grün), [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans), [`MR-071`](../../../../harness/conventions.md#mr-071), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** `SPEC-061` (Satz und Bindungs-Spalte), `SPEC-087` und `SPEC-014` (Bindungs-Spalte) in `spec/spezifikation.md`.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Mutations-Fall 111 trägt wieder einen Zahn über einer wahren Zusage: `branch` ist Pflichtfeld der Draht-Form und trägt ohne ableitbare Referenz die Kennzeichnung *nicht bekannt* (`SPEC-087`, `SPEC-014`); die Spec-Bindung von `SPEC-061` nennt `branch` nicht mehr als Fall von `omitempty`.

Anlass: der geplante CI-Lauf `mutate` vom 2026-10-16. Die Mutation hängt `omitempty` an `json:"branch"`; seit der Kennzeichnung liefert `gitRef()` nie einen leeren String, `TestMandatoryFieldsAlwaysPresent` kann für `branch` nicht mehr fallen, real fällt ein anderer Test der Feldliste.

**Entschieden (Architect-Bericht, ohne ADR, Carveout oder Spec-Änderung durch ihn):** `make mutate` ist kein Gate (`harness/README.md` §Werkzeuge), das Umhängen eines Falls senkt keine Schwelle nach `AGENTS.md` §3.5; es bleibt §3.6 (zugesagt wird, was ein Zahn hält). Die Spec-Bindung zieht dieser Slice nach: keine Quelle benennt eine schreibende Rolle für `spec/spezifikation.md`, bisher schrieb der Implementer sie im Slice mit.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Fälle 110 und 130.** Sie binden `tool_use_id` und `tool`, deren Mutation `TestMandatoryFieldsAlwaysPresent` weiter färbt; unberührter Bestand.
- **Fälle 305 und 171.** Anderer Gegenstand (E2E-Stufe, nicht Spec-Bindung): `slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke`.
- **Last-Flake und roter Grün-Vorlauf.** Anderer Vorgang, andere Schicht: `slice-span-sperre-haelt-den-test-unter-last`, `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log`.
- **Eine Mechanisierung „Fall bleibt aus dem behaupteten Grund rot“.** Anderer Werkzeug-Vorgang; Bestand bleibt bewusst stehen, andere Fälle werden hier nicht geprüft.
- **Die schreibende Rolle der Spec.** Anderer Vorgang: `slice-151-spec-straten-haben-eine-schreibende-rolle` in `next/`.

## 2. Definition of Done

- [x] Fall 111 umgehängt: `# expect:` trägt `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation` (`internal/span/fieldlist_test.go`), der Kopfkommentar nennt die heute wahre Eigenschaft (*branch ist Pflichtfeld der Draht-Form mit Kennzeichnung nicht bekannt*, `SPEC-087`/`SPEC-014`). Vor Annahme ist die Meldung gelesen und gezeigt, dass **nur** dieser Test fällt (kein zweiter, siehe §8); `make mutate-greift` grün.
- [x] Spec nachgezogen: in `SPEC-061` entfällt `branch` im Satz („an `tool_use_id`, an `branch` und an `tool`“) und die Zeile `111` der Bindungs-Spalte; Fall 111 und der Test stehen in der Bindung von `SPEC-087` bzw. `SPEC-014`. Eigener Implementer-Commit, die Spec-Stellen stehen im Kopf.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — das Repo fährt Wellen; sie prüft die nächste Welle-Closure, hier nach dem Move gelesen (§7).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/111-span-korrelationsfeld-verschwindet.sh` | update | `# expect:` und Kopfkommentar auf die wahre Eigenschaft ([`MR-071`](../../../../harness/conventions.md#mr-071)) |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update | `SPEC-061` ohne `branch`/111; Bindung von `SPEC-087`/`SPEC-014` |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; die Übergaben A1 (Fall 111) und A3 (Spec-Bindung) sind vom Architect entschieden, siehe §1.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Spec-Bindung mehr als die genannten drei Zeilen verlangt.
- `in-progress` → `open` (blockiert): wenn kein Test der Feldliste allein fällt — dann ist der Fall ohne Zahn und der Architect zu fragen (kein Umhängen auf einen von mehreren).

## 5. Closure-Trigger

DoD vollständig, `make mutate-greift` und ein lokaler Lauf des Falls 111 zeigen den benannten Test allein rot, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- Die Mutation färbt neben dem benannten Test einen zweiten — **Ausgang:** entfallen — nicht eingetreten: Verifier (vier Läufe) und Reviewer (Kopie, Gegenprobe `t.Skip`) sehen allein `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation` rot, `TestMandatoryFieldsAlwaysPresent` nie; kein Beleg für `BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`.
- `SPEC-061` nennt nach dem Nachzug `branch` nirgends mehr als `omitempty`-Fall, und `SPEC-087`/`SPEC-014` tragen die Bindung — **Ausgang:** entfallen — der Nachzug steht (`9f9985bd`): `SPEC-061` nennt `tool_use_id` und `tool`, die Bindung von `SPEC-014` trägt Test und Fall 111; Review (c) und Verifikation D2 bestätigen. `SPEC-087` führt keine Bindungs-Spalte, die Bindung liegt allein in `SPEC-014`.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-16

- **Was hat funktioniert:** DoD 1 bis 3 bestätigt
  ([Verifikation](../../../reviews/2026-10-16-slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung-verify.md),
  `21ca399b`): Fall 111 nennt `TestFeldliste_KennzeichnungNenntGenauDieFaelleDerSpezifikation`; in einer Kopie fällt
  unter der Mutation in vier Läufen **nur** dieser Test (`fieldlist_test.go:269`), `TestMandatoryFieldsAlwaysPresent`
  nie; `MUTATE_CASES=111-… make mutate` mehrfach einzeln `1 ok, 0 Befund(e)`; `make mutate-greift` 653 von 653;
  `make gates` Exit 0, Stempel == HEAD. Review
  ([Report](../../../reviews/2026-10-16-slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung.md),
  `0c0f351e`): 0 HIGH, 0 MEDIUM, 1 LOW, 2 INFO; die Gegenprobe (`t.Skip` im benannten Test, Mutation angewandt →
  Suite grün) zeigt, dass der Test allein bindet.
- **Grenzen, benannt:**
  - *Fünfer-Lauf nicht grün herstellbar.* `MUTATE_CASES='111 501 502 608 609' make mutate` endet auf diesem Host mit
    Exit 2 und 3 von 5 Ergebnissen (Worker-Status 3/3/3/1), allein und ohne parallele Agenten wiederholt. Die
    Wurzelursache ist am Log gelesen: der Grün-Vorlauf `make test-go` der Worker-Kopie bricht mit
    `No such image: sha256:…` (Error 125), weil die Worker dasselbe Tag `ai-harness-init:test` bauen und ein Worker
    das Image eines anderen verliert. Ob nur der lokale Image-Speicher oder auch CI betroffen ist, ist
    **ungemessen**; der CI-Shard-Fehler vom 2026-10-16 war ein anderer (`TestConcurrentEmittersGetDistinctSeq`).
    Über den Fünfer-Lauf wird nichts behauptet; getragen ist allein der Einzellauf von Fall 111.
  - *Der einmalige „falscher Grund“ für 111* im Fünfer-Lauf des Implementers ist weder reproduziert noch widerlegt;
    gezählt wird er nicht (benannt in `paralleler-mutate-lauf-verliert-das-image-eines-workers`).
  - *Reichweite des Zahns:* `gitRef()` liefert nie `""`, die Mutation ändert allein die Pflicht-Deklaration des
    Trägers, kein Draht-Verhalten; der Fall-Name `…verschwindet` reicht weiter als der Zahn (Review INFO-1).
  - *Spec-Bindung:* `SPEC-087` führt keine Bindungs-Spalte; die Bindung steht in `SPEC-014` (Verifikation F-1).
- **Was ging anders als geplant:** nichts am Schnitt; die Prüfung des Falls lief über den Einzellauf statt über
  den Fünfer-Lauf, den der Host nicht liefert. `make mutate-auswahl` ist nicht über den CI-Branch gefahren (kein Push).
- **Steering-Loop-Eintrag:** drei Beobachtungen als **benannte Lücken** gezählt, keine verkörpert:
  (i) der Treiber von `make mutate` verliert unter Parallelität das Image eines Workers (Tag-Kollision);
  (ii) `mutate-auswahl.sh` bricht auf BSD-`paste` still (Verifikation F-3); (iii) der Kopf eines Falls nennt eine
  andere Ursache als die rote Stelle (LOW-1). **LOW-1 geht den Register-Weg, kein Folge-Slice:** ein Satz im Kopf von
  `test/mutations/111-…` ist Fall-Pflege ([`MR-071`](../../../../harness/conventions.md#mr-071)), kein Slice nach
  [Modul 5](../../../../.harness/baseline/v6.18.1/regelwerk/modul-05-planning-harness.md) (≤ 3 Liefer-Punkte, eine
  Review-Sitzung sind es, aber der Slice trüge keinen Lieferwert über den einen Satz hinaus); der Zähler steht bei 1×;
  wer den Fall anfasst, zieht den Satz nach. Dieser Abschluss schrieb keinen Produktionscode.
- **Beobachtungs-Register (`../observations/`):**
  - neu, je 1×, `offen`:
    [`BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers`](../observations/BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers/observation.md),
    [`BEO-ALL/mutate-auswahl-paste-ohne-operand-bricht-auf-bsd`](../observations/BEO-ALL/mutate-auswahl-paste-ohne-operand-bricht-auf-bsd/observation.md),
    [`BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle`](../observations/BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle/observation.md).
  - ein Beleg mehr:
    [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
    — eine berechtigte Änderung (die Kennzeichnung *nicht bekannt*) hat den Zahn des Falls 111 entwaffnet; Stand
    `verkörpert` ([`MR-071`](../../../../harness/conventions.md#mr-071)), unverändert.
  - Kein Beleg:
    [`BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
    — die Mutation färbt nur einen Test; und
    [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md)
    — keine Isolations-Änderung beteiligt.
  - Kein Eintrag ohne Ausgang erreicht 3×.
- **Folge-Slices:** keiner angelegt. Den Start-Trigger von
  `slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke` (dieser Slice in `done/`) erfüllt
  der Move.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR-Re-Evaluierungs-Trigger: keiner
  berührt. Hard Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice` ist nicht
  gebaut, wie beim Vorgänger).
- **Risiken aus §6:** beide Zeilen tragen ihren Ausgang (zweimal entfallen).
- **Paarungen geprüft am 2026-10-16** (nach dem Move):
  - (a) *Anker*: §7 trägt kein Feld `liegt in`
    (`sed -n '/^## 7/,/^## 8/p' <datei> | grep -c 'liegt in'` → 0); kein Gegenstand.
  - (b) *Folge-Slice*: `slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke` existiert in
    `open/` (`ls docs/plan/planning/open/<kennung>.md`).
  - (c) *Register*: die vier genannten Pfade existieren; ihre `evidence/` tragen 1, 1, 1 und 9 Dateien
    (`ls <verzeichnis>/evidence/*.md | wc -l`). Zweite Hälfte über das ganze Register: 2 Verzeichnisse ohne Beleg,
    namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht` und
    `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`; nicht als getragen behauptet
    ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
    Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer, jeweils als **Nähe**: [`BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md) (8 Belege, verkörpert) — dieselbe Klasse, wenn die Mutation mehrere Tests färbt; [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) (8, verkörpert). Ob Fall 111 eine neue Beobachtung oder ein Beleg bestehender ist, ordnet die Closure zu; ein Eintrag erreicht mit diesem Slice nicht ungeprüft 3×.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
