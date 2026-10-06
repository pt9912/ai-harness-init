# Slice slice-emittierte-commit-pruefung-erkennt-benannte-slices: Die emittierte commit-msg-Prüfung erkennt benannte Slices und lässt die Nummernform grün

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt nur durch `git mv`.

**Welle:** ohne Welle — keine Closure-Bedingung, die mehr beobachtet als die DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist die Prüfung, die das Tool in ein Zielrepo schreibt
(`internal/emit/templates/enforce/commit-msg-traceability.sh`).

**Bezug:** [`LH-FA-06`](../../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (Durchsetzungsschicht emittieren),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine Zusage ohne Wächter ist behauptet),
[`MR-057`](../../../../harness/conventions.md#mr-057) (Kennungs-Form), [`MR-059`](../../../../harness/conventions.md#mr-059) (Setzung 4: die emittierte Ebene entscheidet der Vorgang der Tool-Ebene).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die Zeile `patterns=` der emittierten Prüfung nimmt einen Commit mit benannter Slice-Kennung
(`slice-<Kennung>`, Namens-Form) an und lässt die Nummernform des Bestands (`slice-12`) grün; ein Commit ohne
Kennung fällt weiter. Das ist die Übergabe aus dem Architect-Bericht `2026-10-06-architect-platzhalter-form.md`
(Verdikt 2): ein eigener Träger neben dem Platzhalter-Slice und neben der Dogfood-Erkennung.

**Schärfung, keine Senkung** ([`AGENTS.md`](../../../../AGENTS.md) §3.5): die Prüfung sagt „Kennung anwesend" zu und weist die
Kennungs-Form der Baseline heute zurück; die Schwelle (mindestens eine Kennung aus der Menge) bleibt. **Akzeptiertes Negativ:**
verlangt das Muster nur `slice-` plus Namenszeichen, geht `slice-based` im Fließtext durch — die Prüfung hält Anwesenheit, nicht
Wahrheit (GRENZE im Skriptkopf), und ein Wort nach `slice-` ist ebenso unaufgelöst wie `slice-9999`.

**Lage, nachgemessen:**

```sh
grep -n 'patterns=' internal/emit/templates/enforce/commit-msg-traceability.sh harness/tools/commit-msg-traceability.sh
grep -rl 'slice-\[0-9\]' internal test
```

- Beide Fassungen führen `(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+)`; ein benannter Slice trifft kein Muster.
- Die Mutations-Fälle mit dem Muster `slice-[0-9]+` (`342-kopplung-traeger-gewinnt-ein-muster.sh`, `316`, `317`) patchen **Dogfood**-Dateien
  (`harness/tools/…`, `internal/archive/stub.go`), keine emittierte; sie bleiben, solange die Dogfood-Fassung steht. Der Zahn
  dieses Slice ist ein neuer Fall an der emittierten Zeile (DoD 1).
- **Kopplung, die bricht:** `test/commit-msg-emission.bats` hält die Muster-Mengen der emittierten und der Dogfood-Fassung auf **Gleichheit**
  (Fall „die zwei bash-Fassungen der Kennungs-Menge sind einander gleich"). Sie ist die Stelle, die dieser Slice ändert (DoD 1).
- E2E: `make full-smoke` fährt im Ziel schon drei Läufe des Commit-Kennungs-Schritts (`rot`, `gruen` mit [`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), `umgehung`); ein Lauf mit benanntem Slice fehlt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Dogfood-Fassung (`harness/tools/commit-msg-traceability.sh`) und `commits.id-patterns` in `.d-check.yml`:** Folge-Slice
  `slice-kennungs-erkennung-traegt-die-zugelassenen-formen` (`open/`) trägt die Dogfood-Seite; seine Abgrenzung nennt die emittierte Ebene aus
  und bleibt wahr. Er nimmt die Sendung an: Dogfood-Erkennung ist sein Gegenstand.
- **Eine Prüfung auf Auflösung der Kennung:** ein anderer Vorgang (Werkzeug statt Muster); die Anwesenheits-Zusage reicht der Baseline
  und ist am Skriptkopf benannt.
- **Welle-Kennungen als Muster:** die Menge führt keine `welle-`-Klasse; sie wird hier nicht erweitert (Schärfung nur dort, wo die
  Baseline die Form vergibt und die Prüfung sie heute zurückweist: Slice-Kennung).
- **Nachzug in bestehende Ziele:** der Träger ist skip-if-present, die Prüfung wird bei jedem Lauf kanonisch neu geschrieben — ein Ziel
  mit eigenem Träger behält ihn. *(Eigentum des Adopters.)*

## 2. Definition of Done

- [ ] **(1) Die emittierte Zeile `patterns=` erkennt benannte Slices, und die Nummernform bleibt grün.** Das Muster nimmt `slice-<Kennung>`
      an; `slice-12` geht weiter durch; der Kopf-Kommentar führt die Klasse in der Aufzählung, die `test/commit-msg-emission.bats` gegen
      `patterns=` hält. Der Gleichheits-Fall wird zur **Obermengen-Aussage in der Richtung emittiert ⊇ Dogfood** (jedes Dogfood-Muster steht in der
      emittierten Menge); die Richtung Dogfood ⊇ emittiert entfällt bewusst und steht im Fall-Kommentar. Fälle in `test/commit-msg-emission.bats`:
      grün für benannten Slice, grün für `slice-12`, rot für Message ohne Kennung. **Zahn:** ein Fall in `test/mutations/` setzt die emittierte Zeile auf
      `slice-[0-9]+` zurück (`sed`-Anker gegen den Quell-Bestand gemessen, [`MR-071`](../../../../harness/conventions.md#mr-071)); erwartet rot: der Fall „benannter Slice". Ein
      zweiter Zahn streicht ein Dogfood-Muster aus der emittierten Menge; erwartet rot: der Obermengen-Fall. *Bricht, wenn:* die Zeile den benannten Slice
      nicht annimmt, die Nummernform verliert oder ein Dogfood-Muster fehlt.
- [ ] **(2) Im Ziel geht ein Commit mit benannter Kennung durch.** `make full-smoke` bekommt im Commit-Kennungs-Schritt einen vierten Lauf
      (Message mit `slice-<Kennung>`-Name, `make hooks-install` aktiv): er geht durch und der Commit entsteht. Nachgemessen vor dem Bau:
      `grep -n 'rot)\|gruen)\|umgehung)' harness/tools/full-smoke.sh`. *Bricht, wenn:* die Zeile im Ziel den Namen nicht annimmt (Zahn aus (1) fährt die
      emittierte Zeile; der E2E-Lauf belegt dieselbe Zeile im gebootstrappten Ziel).
- [ ] **(3) Die Abdeckungs-Aussage nennt, was der Lauf im Ziel misst** ([`AGENTS.md`](../../../../AGENTS.md) §3.6, Teilabdeckung). Die Stufen-Deklaration in
      `harness/tools/full-smoke.sh` und die erzeugte `docs/user/e2e-abdeckung.md` (`make e2e-abdeckung`) sagen: gemessen ist **ein** benannter Slice im
      Ziel; nicht gemessen sind andere Namens-Formen, das akzeptierte Negativ (`slice-based`) und Welle-Kennungen. Die Grenze steht am selben Ort. Benannte
      Lücke: kein Sensor liest die Kurzbeschreibung gegen den Körper der Stufe; Träger ist dieser Lauf und `test/e2e-abdeckung.bats`.

Standard (zählen nicht): `make gates` grün · `make mutate` für die neuen Fälle ohne Befund · Review-Report (kein Self-Review) · Closure-Notiz mit
Lerneintrag · Register fortgeschrieben · Risiko-Ausgänge · drei Paarungen.

## 3. Plan (vor Code)

| Datei | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/commit-msg-traceability.sh` | update | DoD (1): Zeile `patterns=`, Kopf-Aufzählung |
| `test/commit-msg-emission.bats` | update | DoD (1): Fälle benannt/Nummer/rot, Obermenge statt Gleichheit |
| `test/mutations/` | neu | DoD (1): zwei Zähne |
| `harness/tools/full-smoke.sh`, `docs/user/e2e-abdeckung.md` | update | DoD (2), (3): vierter Lauf, Teilabdeckung |

Zwei Schichten: Emissions-Vorlage (Shell) und ihre Tests/E2E.

## 4. Trigger

**Start** (`next` → `in-progress`): erfüllt — Architect-Bericht `2026-10-06-architect-platzhalter-form.md` benennt diesen Slice als Träger.

**Nachfolger:** nach seiner Closure startet `slice-kennungs-erkennung-traegt-die-zugelassenen-formen` (dessen Start-Bedingung).

**Rückführungen:**

- `in-progress` → `next`: die Messung findet weitere Stellen der emittierten Ebene mit dem Muster `slice-[0-9]+` — dann nach Fundort schneiden.
- `in-progress` → `open`: der Dogfood-Slice entscheidet die Muster-Menge vor diesem Slice anders (Kopplung neu zu schneiden).

## 5. Closure-Trigger

`make gates` grün; die zwei Zähne dieses Slice sind einmal rot gesehen (`make mutate` für die Fälle ohne Befund), der E2E-Lauf im Ziel grün.
Dazu ein Lerneintrag in einer der drei Formen.

## 6. Risiken und offene Punkte

- Der Dogfood-Slice nimmt ein Muster hinzu, das die emittierte Zeile nicht führt. — **Ausgang:** entfallen: der Obermengen-Fall färbt dann rot und
  benennt das Muster; die Kopplung bricht laut, nicht still.
- Das breitere Muster nimmt Fließtext-Wörter an. — **Ausgang:** entfallen: akzeptiertes Negativ der Anwesenheits-Prüfung, benannt in §1 und in der
  Abdeckungs-Aussage (DoD 3).

## 7. Closure-Notiz

*Wird bei der Closure gefüllt (Planner, [`AGENTS.md`](../../../../AGENTS.md) §3.10).*

- **Was hat funktioniert:**
- **Was ging anders als geplant:**
- **Steering-Loop-Eintrag:**
- **Beobachtungs-Register (`../observations/`):**
- **Folge-Slices:**
- **Risiken aus §6:**
- **Drei Paarungen:**

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, `ALL`): Emissions-Vorlage, Tests, E2E-Skript; Inklusionskriterium erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen; Treffer: `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` (hier fährt die
Emission die ältere Form), `BEO-ALL/commit-message-ohne-traceability-kennung`, `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`
(Teilabdeckung, DoD 3). Zähler-Stand je Eintrag: `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`.

### Sub-Area: `*` (gesamtes Repo)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — [`MR-057`](../../../../harness/conventions.md#mr-057), [`MR-059`](../../../../harness/conventions.md#mr-059); die Kopplungs-Fälle binden die Zeile.
- **Phase-Reife:** Phase 5.
- **Evidenz-/Diskrepanz-Risiko:** niedrig; Fundstellen gemessen (§1).
- **Reconciliation-Aufwand:** keiner.
