# Slice slice-verbrauchte-mutations-faelle-111-und-305-bekommen-ihren-zahn: Zwei verbrauchte Mutations-Fälle (111, 305) bekommen ihren Zahn zurück

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — reaktiv (ein Sensor hat gefeuert), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Zahn, der nicht aus dem behaupteten Grund fällt, ist ein stilles Grün), [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung), [`MR-071`](../../../../harness/conventions.md#mr-071), [`AGENTS.md`](../../../../AGENTS.md) §3.6 und §3.5.

**Berührte Spec-Stellen:** `SPEC-061` (Bindungs-Spalte nennt `TestMandatoryFieldsAlwaysPresent` auch für `branch`) — Zeiger auf den Architect, siehe §6.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jeder der zwei Mutations-Fälle, die der geplante CI-Lauf `mutate` deterministisch aus „falschem Grund“ rot färbt (111 und 305), trägt wieder einen Zahn über der Zusage, die er benennt — oder gibt ihn mit einem Verdikt des Architect ab; und für Fall 171 steht gemessen, ob er dasselbe Muster trägt.

Anlass: der Lauf `schedule` vom 2026-10-16, Shards mit Fall 111 und 305. Beide Fälle sind auf `HEAD` rot, der Sprung auf `v6.18.1` berührt sie nicht. **111:** die Mutation hängt `omitempty` an `json:"branch"`; seit der Kennzeichnung *nicht bekannt* liefert `gitRef()` nie einen leeren String, `TestMandatoryFieldsAlwaysPresent` kann nicht mehr fallen, real fällt ein anderer Test der Feldliste. **305:** die Mutation kürzt `CanonicalRoles` auf fünf Namen; `harness/tools/full-smoke.sh` fährt die Stufe *Handbuch-Baum* vor `rollen_typen_im_ziel`, die Mutation fällt dort und erreicht `FEHLER — Rollen-Typ fehlt` nie. Der Zahn über der Schleife `rollen_typen_im_ziel` ist ungedeckt. **171:** scheiterte an den Vortagen mit „falscher Grund“, vermutlich dasselbe Muster, **ungemessen**.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Norm-Text zur Zahn-Abgabe** (`AGENTS.md` §3.5/§3.6, ADR). Ob das Abhängen von 305 an `Handbuch-Baum` eine Senkung ist, entscheidet der Architect (Übergabe A1, §4); der Implementer schreibt keinen Norm-Text (`AGENTS.md` §3.8, Schicht-Abgrenzung).
- **Das Last-Flake (Shard 7) und der rote Grün-Vorlauf (Shard 2).** Anderer Vorgang, andere Schicht (Produktcode bzw. Treiber): `slice-span-sperre-haelt-den-test-unter-last`, `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log`.
- **Eine Mechanisierung „Fall bleibt aus dem behaupteten Grund rot“.** Kein Sensor liest den Grund gegen die Zusage; das ist ein anderer Werkzeug-Vorgang, kein Teil der Reparatur dreier Fälle. Bestand bleibt bewusst stehen: andere Fälle werden hier nicht geprüft.

## 2. Definition of Done

- [ ] Fall 111: `# expect:` und Kopfkommentar nennen den Test, der real und aus dem behaupteten Grund fällt (gelesene Meldung, nicht nur Rot); trägt kein Test den Grund, steht das als Verdikt des Architect (A1) statt als Umhängen.
- [ ] Fall 305: die Wahl (i) oder (ii) aus A1 ist vollzogen; bei (ii) färbt die Mutation `FEHLER — Rollen-Typ fehlt` in der Stufe `rollen_typen_im_ziel` rot, gesehen an `make mutate-auswahl` über einen CI-Branch (`make full-smoke` läuft auf macOS nicht, nur `full-smoke-host`).
- [ ] Fall 171: gemessen, ob das Muster vorliegt; Befund in §7 mit Wortlaut der Fehlermeldung aus dem CI-Log, bei Vorliegen derselbe Ausgang wie 305.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/111-span-korrelationsfeld-verschwindet.sh` | update | `# expect:` und Kopfkommentar auf den real fallenden Test ([`MR-071`](../../../../harness/conventions.md#mr-071)) |
| `test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh` | update | Wahl (i) `# expect:` oder (ii) Mutation, die den Handbuch-Baum grün lässt |
| `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh` | prüfen | Mess-Punkt, Änderung nur bei Befund |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner **und** das Verdikt des Architect zu A1 liegt als Artefakt vor (ADR, Carveout oder „keine ADR nötig“ mit Grund).

**Übergabe A1 an den Architect** (Quellen: `AGENTS.md` §3.5, §3.6, §3.11; `test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh`; `harness/tools/full-smoke.sh` Stufe *Handbuch-Baum* vor `rollen_typen_im_ziel`): Option (i) hängt `# expect:` auf *Handbuch-Baum* — der Fall bleibt grün, die Schleife `rollen_typen_im_ziel` hat dann **keinen** Zahn; ist das eine Senkung (ADR) oder ein Carveout mit Trigger und Folge-Slice? Option (ii) ändert die Mutation so, dass der Handbuch-Baum grün bleibt; kein Gate wird gelockert, die Wahl ist reine Fall-Pflege. Frage: ist (ii) vorzuziehen, und wenn (ii) mit `sed` nicht herstellbar ist — ist (i) ohne ADR zulässig? Dasselbe gilt für 111, falls kein Test den Grund trägt.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Messung zu 171 eine eigene Reparatur über eine zweite Stufe verlangt.
- `in-progress` → `open` (blockiert): wenn A1 nicht entschieden ist oder (ii) und (i) beide an einer Norm hängen.

## 5. Closure-Trigger

DoD vollständig, `make mutate-auswahl` über den Branch zeigt 111, 305 (und 171) aus dem benannten Grund rot, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- `SPEC-061` nennt für `branch` einen Wächter, der es nicht mehr trägt (der Test kann nicht fallen, solange `gitRef()` nie leer liefert) — **Ausgang:** weiter offen → Übergabe A3 an den Architect (Spec-Bindung nachziehen oder benannte Lücke); bei Closure entschieden.
- 305 lässt sich per `sed` nicht ohne Handbuch-Baum-Bruch herstellen — **Ausgang:** eingetreten wäre Option (i) mit A1-Verdikt; bis dahin offen, bei Closure aufzulösen.
- 171 ist unmessbar auf macOS und nur über den CI-Branch zu sehen — **Ausgang:** entfallen, sobald der Branch-Lauf den Wortlaut liefert (Messung ist Liefer-Punkt 3).

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer, jeweils als **Nähe**, nicht als gleiche Klasse: [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) (8 Belege, verkörpert) — dort greift der Patch nicht mehr, hier greift er und fällt aus falschem Grund; [`BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md) (8, verkörpert); [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md) (1, offen) — eine vorgelagerte Stufe (hier *Handbuch-Baum*) macht den Zahn stumm, ohne ihn anzufassen; ein zweiter Beleg wäre dieser Slice. Ob Fall 111 und 305 eine neue Beobachtung oder ein Beleg bestehender sind, ordnet die Closure zu; ein Eintrag erreicht mit diesem Slice nicht ungeprüft 3×.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
