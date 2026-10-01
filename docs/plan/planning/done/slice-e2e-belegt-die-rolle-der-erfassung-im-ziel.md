# Slice slice-e2e-belegt-die-rolle-der-erfassung-im-ziel: Der E2E belegt, dass der emittierte Träger im Ziel die Rolle ableitet

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — der Closure-Trigger wäre die Abschrift der eigenen DoD.

**Bezug:** [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) (Scope), [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`LH-FA-12`](../../../../spec/lastenheft.md#lh-fa-12--e2e-abdeckungs-sicht-emittieren), [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md).

**Berührte Spec-Stellen:** [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) Akzeptanzkriterien *Rolle besetzt* und *Rolle wird abgeleitet* (erster Teil) · `spezifikation.md §5`.

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-01. **Auslöser:** Auftrag des Auftraggebers; Befund der Verifikation ([`2026-10-01-e2e-deklarationen-verifikation.md`](../../../reviews/2026-10-01-e2e-deklarationen-verifikation.md)) — [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) ist die einzige Waise der RTM (`make doc-trace`).

---

## 1. Ziel und Abgrenzung

**Ziel:** Eine Stufe des Voll-E2E gibt dem emittierten Wrapper im Ziel Hook-Payloads mit `agent_type` und liest die Span-Zeile des **abgelegten Trägers**: `agent_role` ist beim Namen eines emittierten Rollen-Typs besetzt, bei `general-purpose` und einem fremden Typ leer (unbekannt, nie rollenlos).

**Änderung gegenüber der Ausgangsidee.** Die Typ-Namen sind nicht fest verdrahtet, sondern kommen aus den im Ziel emittierten Rollen-Typ-Dateien (`name:` im Frontmatter): so hält der E2E die Kette *emittierter Rollen-Typ → Träger → Span-Rolle*, und eine Fixture-Liste im Skript kann von der Emission nicht abweichen. Ergänzt um `general-purpose` (der Wortlaut des Kriteriums nennt ihn). Ein eigener Stufen-Kopf entfällt: die Prüfung ist eine Funktion, die `traeger_im_ziel` nach `leser_und_aufraeumen_im_ziel` ruft (dort liegt der Wrapper, ein eigener Strom je Payload hält die Zeile des Pflichtfeld-Abgleichs unberührt); die Deklaration trägt die zwei Stufen, die `traeger_im_ziel` rufen.

**Benannte Grenze.** Ein synthetischer Payload belegt die Ableitung des Emitters im Ziel, nicht den echten Aufruf des Agenten-Werkzeugs: ob Claude Code beim Start eines Rollen-Typs `agent_type` so setzt, sieht kein E2E-Lauf (kein Claude-Code-Lauf im Ziel). Dasselbe gilt für das Kriterium *Lesevorschrift*.

**Ausdrücklich NICHT in diesem Slice:**

- Die Rolle eines gestarteten Subagenten aus dem Ergebnis des Laufs (`tool_response.agentType`, Kriterium *Rolle wird abgeleitet*, zweiter Teil) — dazu braucht es eine Agent-Werkzeug-Payload mit Ergebnis; `internal/span` deckt sie per Test, und der Schnitt bleibt bei ≤ 3 Liefer-Punkten.
- Die *Lesevorschrift* — sie bindet Auswerter, keinen Emitter; ihr Leser ist `make span-report` ([`LH-FA-17`](../../../../spec/lastenheft.md#lh-fa-17--auswertung-der-erfassung)).
- Die übrigen Deklarationen der Verifikation ([`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)/[`LH-FA-14`](../../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang), Stufe 18) — anderer Vorgang, in Auftrag des Auftraggebers bereits zurückgenommen.
- Produkt-Code in `internal/span` — die Ableitung bleibt unverändert; der Slice misst sie.

## 2. Definition of Done

- [x] Funktion `rolle_im_ziel` in `harness/tools/full-smoke.sh`, aus `traeger_im_ziel` gerufen (beide Bootstrap-Varianten): je emittiertem Rollen-Typ ein Payload, `agent_role` gleich dem Namen; `general-purpose` und ein fremder Typ ergeben `"agent_role":""` — Feld anwesend. Der FEHLER-Zweig nennt [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) und die Zeile.
- [x] Die zwei `e2e_abdeckung`-Deklarationen der Stufen, die `traeger_im_ziel` rufen, nennen [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung); `make e2e-abdeckung` hat [`docs/user/e2e-abdeckung.md`](../../../user/e2e-abdeckung.md) neu erzeugt; `make doc-trace` meldet keine Waise.
- [x] Rot gesehen, beide Seiten (AGENTS.md §3.6): (a) die Ableitung `RoleFromAgentType` im Emitter verfälscht (gibt stets `""` bzw. den Typ roh zurück) → `rolle_im_ziel` färbt rot mit [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) in der Meldung; (b) die Erwartung der Funktion umgekehrt (fremder Typ erwartet besetzt) → rot. Beleg im Wortlaut der Meldung (`docs/reviews/`-Bericht des Verifiers).
- [ ] `make gates` grün; Review; Closure-Notiz mit Lerneintrag; Beobachtungs-Register fortgeschrieben; jedes Risiko aus §6 trägt einen Ausgang; die drei Paarungen sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke.sh` | update | `rolle_im_ziel` (Typ-Namen aus `.claude/agents/*.md` des Ziels; Payload je Typ über den Wrapper wie in `traeger_im_ziel`, eigener `session_id` je Payload) und die zwei Deklarationen |
| `docs/user/e2e-abdeckung.md` | update (erzeugt) | `make e2e-abdeckung` — nicht von Hand |

**Isolierte Fahrt für das Gegenbeispiel (ohne den Docker-E2E).** Der Voll-E2E braucht Träger-Binary, Release-Netz und `make`-Fragmente im Ziel; die Stufe selbst ist so nicht rot zu fahren (Lücke, wie in der Verifikation für `traeger_im_ziel` benannt). Isoliert fahrbar: `rolle_im_ziel` aus einer Scratchpad-Kopie des Skripts, gegen ein nachgebautes Ziel mit den **emittierten** Rollen-Typ-Dateien und dem **emittierten** Wrapper, und dem **realen** Träger aus `make host-bin`. Für (a) wird `RoleFromAgentType` in `internal/span/emit.go` verfälscht, `make host-bin` baut neu, die Funktion fährt rot; danach Rücknahme und erneut grün. Nur der Träger ist hier real; Wrapper und Ziel sind nachgebaut — die Lücke zum vollen Ziel bleibt benannt (Fixture-Klasse, `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`).

## 4. Trigger

**Start** (`next` → `in-progress`): Auftraggeber priorisiert; `harness/tools/full-smoke.sh` liegt in keinem anderen `in-progress/`-Slice.

**Rückführungen:**

- `in-progress` → `next`: die Funktion verlangt mehr als einen Lauf-Aufruf des Wrappers je Payload-Klasse oder eine Änderung am Wrapper selbst.
- `in-progress` → `open`: der emittierte Träger setzt `agent_type` nur mit weiterem Payload-Feld (`agent_id`), das der E2E nicht kennt — Frage an den Architect.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Review- und Verifikationsbericht liegen vor, Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- Ein synthetischer `agent_type` weicht vom echten Hook-Payload ab (kein Claude-Code-Lauf) — **Ausgang:** weiter offen: Register `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (Beleg beim Schließen).
- Die Deklaration behauptet mehr als die Stufe misst (Verifikation: Stufen messen heute nur den Typ-Namen) — **Ausgang:** weiter offen: Register `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (Kurzbeschreibungen der Stufen 3 und 6 unverändert, `doc-trace` zeigt *E2E ok*; Folge-Slice `slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst`).
- Das Rot (a) setzt einen Träger-Neubau voraus, der in einer Sitzung den Arbeitsbaum verändert — **Ausgang:** entfallen: Rücknahme per `git checkout` vor `make gates`, der Stempel gilt nur für den Endstand.

## 7. Closure-Notiz

- **Zustand:** Liefer-Punkte 1 bis 3 bestätigt im Verifikationsbericht `docs/reviews/2026-10-01-e2e-rolle-verifikation.md` (beide Rot-Seiten vom Verifier selbst gefahren, `make doc-trace` 0 Waisen). DoD-Punkt 4 offen: kein Review-Bericht unter `docs/reviews/` (nur Verifikation); `make gates` im Bericht bestätigt.
- **Steering-Loop-Eintrag — neuer Sensor:** `rolle_im_ziel` hält die Kette *emittierter Rollen-Typ → abgelegter Träger → `agent_role`*. Gezählt, nicht verkörpert: die Funktion trägt keinen Herkunfts-Anker. Grenzen, benannt: gemessen ist nur die Ableitung im Emitter; Wrapper und Ziel sind in der isolierten Fahrt nachgebaut, die Stufe selbst lief nicht im Docker-E2E; nicht gemessen sind die Rolle aus `tool_response.agentType`, die Lesevorschrift und der echte `agent_type` des Agenten-Werkzeugs.
- **Review-Finding F1 (Verifikation):** die Deklaration der Stufen 3 und 6 deckt nur *Rolle besetzt* und *abgeleitet, erster Teil*, die Kurzbeschreibung sagt es nicht. Ausgang: Register und Folge-Slice (siehe Risiken).
- **Beobachtungs-Register:** `evidence/slice-e2e-belegt-die-rolle-der-erfassung-im-ziel.md` in [`emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) ergänzt, Zähler 3×; Ausgang *geplant* in dessen `state.md`.
- **Folge-Slices:** [`slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst`](../open/slice-emittierte-zusage-nennt-was-der-lauf-im-ziel-misst.md) — Datei in `open/`.
- **Risiken aus §6:** synthetischer `agent_type` — *weiter offen*, Register (Beleg oben). Teilabdeckung in der Deklaration — *weiter offen*, Register und Folge-Slice. Träger-Neubau — *entfallen*: Rücknahme per `git checkout`, Arbeitsbaum nach der Verifikation sauber.
- **Drei Paarungen:** nach dem `git mv` geprüft.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo, Kürzel `ALL`) mit `harness/tools/` (`TOOLS`); beide tragen Konventionen-Dichte und Berührung der Pfade, Schwelle ≥ 2 erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen (`docs/plan/planning/observations/`). Treffer: `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` (3 Belege unter `evidence/`) — der Slice ist deshalb mit isolierter Fahrt und benannter Lücke geschnitten; berührt der Slice sie, wäre ein vierter Beleg fällig, keine Neuschneidung. `BEO-ALL/dod-testzeile-verortet-verhalten-in-der-falschen-stufe` (2 Belege; wird mit diesem Slice nicht erreicht, wenn die Deklaration auf die messenden Stufen beschränkt bleibt). `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (2 Belege) — Berührung ja: erreicht mit diesem Slice 3×, wenn die Closure einen Beleg anlegt; dann braucht er einen eigenen Folge-Slice (Lese-Schritt der Closure).

alle berührten Sub-Areas GF.
