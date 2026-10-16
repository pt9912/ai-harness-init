# Slice slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke: Fälle 305 und 171 bekommen ihren Zahn zurück oder nennen die Lücke

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — reaktiv (ein Sensor hat gefeuert), keine Closure-Bedingung jenseits der DoD ([`MR-037`](../../../../harness/conventions.md#mr-037)).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Zahn, der nicht aus dem behaupteten Grund fällt, ist ein stilles Grün), [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung), [`MR-071`](../../../../harness/conventions.md#mr-071), [`AGENTS.md`](../../../../AGENTS.md) §3.6.

**Berührte Spec-Stellen:** —.

**Verantwortlich:** — bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Mutations-Fall 305 trägt wieder einen Zahn über der Schleife `rollen_typen_im_ziel` — oder die Lücke steht ehrlich benannt; für Fall 171 steht gemessen, ob er dasselbe Muster trägt, und er wird entsprechend behandelt.

Anlass: der geplante CI-Lauf `mutate` vom 2026-10-16. **305:** die Mutation kürzt `CanonicalRoles` auf fünf Namen; `harness/tools/full-smoke.sh` fährt die Stufe *Handbuch-Baum* (Zeile ~492) vor `rollen_typen_im_ziel` (~546); die Mutation fällt dort und erreicht `FEHLER — Rollen-Typ fehlt` nie. **171:** scheiterte an den Vortagen mit „falscher Grund“, vermutlich dasselbe Muster, **ungemessen**.

**Entschieden (Architect-Bericht, ohne ADR, Carveout oder Spec-Änderung durch ihn):** `make mutate` ist kein Gate (`harness/README.md` §Werkzeuge); Umhängen oder Pflege eines Falls senkt keine Schwelle nach `AGENTS.md` §3.5, es bleibt §3.6. Ein Carveout wäre falsch: nichts ist rot. **305, Variante (ii)** — eine Mutation, die den Handbuch-Baum grün lässt — ist per `sed` am Emissions-Code **nicht herstellbar** (der Handbuch-Baum führt jede Rollen-Datei einzeln); herstellbar ist allein eine Datei-Anlage: die Quelle `internal/emit/templates/agents/` trägt einen Typ, der im Handbuch nicht steht und im Ziel nicht emittiert wird (Präzedenz Fälle 194 und 309). Ob `make mutate-greift` das mit `# files:` zulässt, **misst der Implementer**. **Fallback (i):** `# expect:` auf `FEHLER — Handbuch-Baum` ohne ADR zulässig (kein Gate ändert sich; der zweite Zahn als Redundanz entfällt). **171:** gleiches Muster plausibel; (ii)-Kandidat: Pfad der Feldliste stehen lassen und die Emission der `.d-check.yml` des Ziels so mutieren, dass das Ziel-Doku-Gate die Feldliste nicht mehr prüft ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7) — Herstellbarkeit ungemessen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Fall 111 und die Spec-Bindung von `SPEC-061`.** Anderer Gegenstand (Go-Test, Spec-Zeile): `slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung`.
- **Last-Flake und roter Grün-Vorlauf.** Anderer Vorgang, andere Schicht: `slice-span-sperre-haelt-den-test-unter-last`, `slice-roter-gruen-vorlauf-des-mutate-treibers-zeigt-sein-log`.
- **Norm-Text, ADR oder Carveout zur Zahn-Abgabe.** Nicht nötig (siehe oben); der Implementer schreibt keinen Norm-Text (`AGENTS.md` §3.8).
- **Eine Mechanisierung „Fall bleibt aus dem behaupteten Grund rot“.** Anderer Werkzeug-Vorgang; Bestand bleibt bewusst stehen, andere Fälle werden hier nicht geprüft.

## 2. Definition of Done

- [ ] Fall 305: gemessen, ob die Datei-Anlage-Variante (ii) `make mutate-greift` besteht und die Mutation `FEHLER — Rollen-Typ fehlt` in `rollen_typen_im_ziel` rot färbt (gesehen über `make mutate-auswahl`/CI-Branch; `make full-smoke` läuft auf macOS nicht, nur `full-smoke-host`). Besteht sie, ist (ii) der Fall. Sonst (i) mit den Auflagen: Kopf von Fall 305 und der Kommentar an `rollen_typen_im_ziel` in `full-smoke.sh` sagen weder „kein anderer Fall deckt sie“ noch „Dieser Fall ist der Zahn“, sondern nennen die Lücke (Meldungs-Zweig durch keinen Fall rot gesehen; ein Defekt dort fällt vorher am Handbuch-Baum).
- [ ] Fall 171: gemessen, ob das Muster vorliegt (Wortlaut der Fehlermeldung aus dem Lauf in §7); bei Vorliegen derselbe Ausgang wie 305 ((ii) wenn herstellbar, sonst (i) mit benannter Lücke), sonst unverändert mit Befund in §7.
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
| `test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh` | update | (ii) Datei-Anlage oder (i) `# expect:` plus Kopf, der die Lücke nennt |
| `harness/tools/full-smoke.sh` | update (nur bei (i)) | Kommentar an `rollen_typen_im_ziel` nennt die Lücke statt „Zahn“ |
| `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh` | prüfen | Mess-Punkt, Änderung nur bei Befund |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; die Reihenfolge ist Slice `slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung` zuerst (WIP-Limit 1). Die Verdikte des Architect (§1) liegen als Bericht vor.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Messung zu 171 eine eigene Reparatur über eine zweite Stufe verlangt.
- `in-progress` → `open` (blockiert): wenn (i) und (ii) beide an einer Norm hängen — dann ist der Architect erneut zu fragen.

## 5. Closure-Trigger

DoD vollständig, `make mutate-auswahl` über den Branch zeigt 305 (und 171) aus dem benannten Grund rot — oder die Lücke steht benannt —, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- 305 lässt sich per `sed` nicht ohne Handbuch-Baum-Bruch herstellen — **Ausgang:** eingetreten (gemessen bestätigt, Architect-Bericht) → Variante (ii) per Datei-Anlage, sonst (i) mit benannter Lücke (DoD-Punkt 1).
- 171 ist unmessbar auf macOS und nur über den CI-Branch zu sehen — **Ausgang:** entfallen, sobald der Branch-Lauf den Wortlaut liefert (DoD-Punkt 2).

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer, jeweils als **Nähe**: [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md) (1, offen) — eine vorgelagerte Stufe (hier *Handbuch-Baum*) macht den Zahn stumm, ohne ihn anzufassen; ein zweiter Beleg wäre dieser Slice. [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) (8, verkörpert). Ob 305/171 eine neue Beobachtung oder ein Beleg bestehender sind, ordnet die Closure zu; ein Eintrag erreicht mit diesem Slice nicht ungeprüft 3×.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
