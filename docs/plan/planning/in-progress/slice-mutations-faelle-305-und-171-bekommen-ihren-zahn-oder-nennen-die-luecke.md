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

**Verantwortlich:** Implementer (pt9912).

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

- [x] Fall 305: gemessen, ob die Datei-Anlage-Variante (ii) `make mutate-greift` besteht und die Mutation `FEHLER — Rollen-Typ fehlt` in `rollen_typen_im_ziel` rot färbt (gesehen über `make mutate-auswahl`/CI-Branch; `make full-smoke` läuft auf macOS nicht, nur `full-smoke-host`). Besteht sie, ist (ii) der Fall. Sonst (i) mit den Auflagen: Kopf von Fall 305 und der Kommentar an `rollen_typen_im_ziel` in `full-smoke.sh` sagen weder „kein anderer Fall deckt sie“ noch „Dieser Fall ist der Zahn“, sondern nennen die Lücke (Meldungs-Zweig durch keinen Fall rot gesehen; ein Defekt dort fällt vorher am Handbuch-Baum).
- [x] Fall 171: gemessen, ob das Muster vorliegt (Wortlaut der Fehlermeldung aus dem Lauf in §7); bei Vorliegen derselbe Ausgang wie 305 ((ii) wenn herstellbar, sonst (i) mit benannter Lücke), sonst unverändert mit Befund in §7.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/305-rollenachse-ziel-verliert-rolle-fullsmoke.sh` | update | (ii) Datei-Anlage oder (i) `# expect:` plus Kopf, der die Lücke nennt |
| `harness/tools/full-smoke.sh` | update (nur bei (i)) | Kommentar an `rollen_typen_im_ziel` nennt die Lücke statt „Zahn“ |
| `test/mutations/171-feldliste-ausserhalb-des-geprueften-bereichs.sh` | prüfen | Mess-Punkt, Änderung nur bei Befund |

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Planner; die Reihenfolge ist Slice `slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung` zuerst (WIP-Limit 1). Die Verdikte des Architect (§1) liegen als Bericht vor. **Erfüllter Zustand:** `slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung` liegt in `done/` (Beleg: `ls docs/plan/planning/done/slice-mutations-fall-111-haengt-an-den-test-der-branch-kennzeichnung.md`), `in-progress/` trägt danach nur `roadmap.md`, WIP-Limit frei.

**Rückführungen:**

- `in-progress` → `next` (zu groß): wenn die Messung zu 171 eine eigene Reparatur über eine zweite Stufe verlangt.
- `in-progress` → `open` (blockiert): wenn (i) und (ii) beide an einer Norm hängen — dann ist der Architect erneut zu fragen.

## 5. Closure-Trigger

DoD vollständig, `make mutate-auswahl` über den Branch zeigt 305 (und 171) aus dem benannten Grund rot — oder die Lücke steht benannt —, Review ohne blockierenden Befund, Closure-Notiz geschrieben.

## 6. Risiken und offene Punkte

- 305 lässt sich per `sed` nicht ohne Handbuch-Baum-Bruch herstellen — **Ausgang:** eingetreten (gemessen bestätigt, Architect-Bericht) → Variante (ii) per Datei-Anlage, sonst (i) mit benannter Lücke (DoD-Punkt 1). **Eingetreten, Ausgang getragen:** am Emissions-Code allein gemessen bestätigt (Kontrast-Lauf fällt am Handbuch-Baum); Variante (ii) gebaut, aber als Zwei-Dateien-Mutation (`726cdd93`), nicht als Datei-Anlage — kein Folge-Slice nötig.
- Die Docker-Tag-Kollision der Worker von `make mutate` (`ai-harness-init:test`, gemessen im Fünfer-Lauf des Falls 111) kann die Messung stören: ein Einzellauf (`MUTATE_CASES=<ein Fall>`) hat einen Worker und ist nicht betroffen, ein Lauf mit mehreren Fällen auf diesem Host ist betroffen; ob ein CI-Shard mehrere Worker auf einem Runner fährt, ist **ungemessen**. `make mutate-greift` läuft ohne Worker-Image. Die Messung zu 305 und 171 fährt darum je Fall einzeln; ein Ergebnis aus einem Mehrfach-Lauf mit fehlenden Fällen zählt nicht als Befund zum Fall — **Ausgang:** weiter offen → `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers` (Zähler unverändert). Die Messung lief je Fall einzeln; die Tag-Kollision trat nicht auf. Der einzige Docker-Fehler (Review INFO-2: `rpc error: code = Unavailable` im Einzellauf von 305, Wiederholung grün) hat eine andere Ursache und ist weder Beleg noch Befund zum Fall.
- 171 ist unmessbar auf macOS und nur über den CI-Branch zu sehen — **Ausgang:** entfallen — nicht eingetreten: der Wortlaut des alten Befunds steht in den CI-Logs der Läufe 38698945568, 38529836984 und 38376387942 (Shard 2), vom Verifier gelesen; lokal ist 171 über `SMOKE_ARTIFACT_TARGET=artifact-host` im Einzellauf messbar (`ok`), kein Branch-Lauf nötig.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-16

- **Was hat funktioniert:** DoD 1 bis 3 bestätigt
  ([Verifikation](../../../reviews/2026-10-16-slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke-verify.md),
  `ed76d044`). **Fall 305** ist ein Zwei-Dateien-Fall (`# files: internal/span/emit.go docs/user/benutzerhandbuch.md`):
  gekürzt werden `CanonicalRoles` und die Zeile `│       └── validator.md` im Baum von §6 des Handbuchs; der
  Handbuch-Baum bleibt grün, und es fällt allein `rollen_typen_im_ziel` mit `FEHLER — Rollen-Typ fehlt`. Kontrast: nur
  `emit.go` gekürzt → `FEHLER — Handbuch-Baum` vorgelagert. **Fall 171:** das Muster lag vor (Wortlaut in den CI-Logs
  der Läufe 38698945568, 38529836984, 38376387942, Shard 2: `FEHLER — Handbuch-Baum (dokument-only) … [harness/erfassung-feldliste.md]`);
  die Mutation hängt `harness/erfassung-feldliste.md` an `scan.ignore` der emittierten `.d-check.yml`, `# expect:` ist
  `laesst das docs-check des Ziels GRUEN`, und der Fall misst die Zusage aus ADR-0022 Festlegung 7 (GEPRÜFTER
  Bereich). Beide Einzelläufe `1 ok, 0 Befund(e)`; `make mutate-greift` 653 von 653; `make gates` Exit 0,
  Stempel == HEAD; `harness/tools/full-smoke.sh` und `harness/tools/mutate.sh` unverändert. Review (`fbf3225b`):
  0 HIGH, 0 MEDIUM, 2 LOW (Köpfe im Konjunktiv; danach im Implementer-Commit `d8e4cb5e` behoben), 2 INFO.
- **Was ging anders als geplant:** die Planannahme (Plan und Architect), (ii) sei für 305 am Emissions-Code **nicht
  herstellbar** und allein per Datei-Anlage möglich, ist am **Handbuch** widerlegt, nicht am Emissions-Code: der
  Emissions-Code allein bleibt unherstellbar (Kontrast-Lauf), herstellbar wird (ii), weil der Handbuch-Baum eine Zeile
  führt, die im Gleichschritt mitwandert. Der Fallback (i) und eine Änderung an `full-smoke.sh` blieben unnötig.
  `make mutate-auswahl` über den CI-Branch ist nicht gefahren (kein Push); gemessen ist über Einzelläufe lokal. Ein erster
  Einzellauf von 305 fiel an einem Docker/colima-Aussetzer, die Wiederholung war grün (Review INFO-2, nicht gezählt).
- **Steering-Loop-Eintrag:** drei Beobachtungen, keine verkörpert (kein `liegt in`).
  (i) Eine vorgelagerte Stufe fängt die Mutation ab, bevor sie die gemessene Stelle erreicht — die Mutation wird im
  Gleichschritt mit der Stufe geführt (hier: Handbuch im selben Fall); gezählt als zweiter Beleg der
  Klasse *neue Isolation entzahnt bestehende Wächter*, mit benannter Grenze in dem Beleg: die Ursache ist eine
  Prüfstufe, keine Isolation; wer die Klasse enger liest, zählt 1×. (ii) Der Kopf von Fall 171 nennt mit 614 einen
  Halter, den die rote Stelle nicht trägt (Verifikation F-1): zweiter Beleg der Klasse *Fall-Kopf nennt andere Ursache*.
  (iii) Der lokale Weg `SMOKE_ARTIFACT_TARGET=artifact-host` für `make mutate` steht in keiner Doku: dritter
  Beleg, **Lese-Schritt: Ausgang *geplant*** → `slice-mutate-doku-nennt-den-lokalen-weg-auf-macos`. Gegen einen Folge-Slice und
  gegen den Register-Weg abgewogen: die Doku-Pflege an `harness/sensors/mutate.md` ist Implementer-Arbeit und trägt mit dem
  Kopf-Satz zu 171 zwei Liefer-Punkte; weil der Zähler bei 3× steht, verlangt der Ausgang eine Kennung, kein Notiz-Satz.
  Dieser Abschluss schrieb keinen Produktionscode.
- **Beobachtungs-Register (`../observations/`):**
  - [`BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host`](../observations/BEO-ALL/lokaler-full-smoke-scheitert-auf-macos-host/observation.md):
    `evidence/slice-mutations-faelle-305-und-171-bekommen-ihren-zahn-oder-nennen-die-luecke.md` ergänzt — Zähler
    steht damit bei 3×; `state.md` trägt *geplant* mit der Kennung des Folge-Slice (`make register-ausgang`).
  - [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md):
    Beleg ergänzt — 2×, `offen`. **Ein Vorgang zählt einmal:** die Fälle 305 und 171 sind ein Beleg, nicht zwei.
  - [`BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle`](../observations/BEO-ALL/fall-kopf-nennt-andere-ursache-als-die-rote-stelle/observation.md):
    Beleg ergänzt — 2×, `offen`; der Kopf-Satz zu 171 wird im Folge-Slice nachgezogen.
  - Kein Beleg: `BEO-ALL/paralleler-mutate-lauf-verliert-das-image-eines-workers` — nicht aufgetreten.
  - Keine neue Beobachtung angelegt: alle drei Funde passten auf vorhandene Einträge.
- **F-1 und die Doku-Lücke, Entscheidung:** F-1 (INFO) ist Beleg 2 an `fall-kopf-nennt-andere-ursache-als-die-rote-stelle`;
  die undokumentierte Fahrbarkeit ist Beleg 3 an `lokaler-full-smoke-scheitert-auf-macos-host` mit Ausgang *geplant*;
  beide Korrekturen tragen sich im Folge-Slice, nicht in diesem (kein Produktionscode im Abschluss).
- **Folge-Slices:** `slice-mutate-doku-nennt-den-lokalen-weg-auf-macos` (Doku des Treibers + Kopf von Fall 171) — ist
  eine Datei in `open/`.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR-Re-Evaluierungs-Trigger: keiner berührt.
  Hard Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice` ist nicht gebaut, wie beim Vorgänger).
- **Risiken aus §6:** drei Zeilen, je ein Ausgang (eingetreten · weiter offen · entfallen).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührte Sub-Area `*` (gesamtes Repo, [`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area)); Schwelle erfüllt.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Treffer, jeweils als **Nähe**: [`BEO-ALL/neue-isolation-entzahnt-bestehende-waechter`](../observations/BEO-ALL/neue-isolation-entzahnt-bestehende-waechter/observation.md) (1, offen) — eine vorgelagerte Stufe (hier *Handbuch-Baum*) macht den Zahn stumm, ohne ihn anzufassen; ein zweiter Beleg wäre dieser Slice. [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md) (8, verkörpert). Ob 305/171 eine neue Beobachtung oder ein Beleg bestehender sind, ordnet die Closure zu; ein Eintrag erreicht mit diesem Slice nicht ungeprüft 3×.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF.
