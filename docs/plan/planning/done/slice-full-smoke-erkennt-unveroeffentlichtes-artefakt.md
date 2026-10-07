# Slice slice-full-smoke-erkennt-unveroeffentlichtes-artefakt: Der Einordner von full-smoke erkennt ein nicht veröffentlichtes Artefakt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice; Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (Festlegung 2: laut-Bruch
statt stiller Ausweichung). Anlass: Release-Schnitte `v0.3.0`, `v0.4.0` und `v0.5.0` — der
`ci`-Lauf am Tag-Commit fiel im ersten Versuch im `full-smoke` an `make traeger-fetch` im frischen
Klon mit `curl: (22) The requested URL returned error: 404` und meldete *„AUSGANG BAUM … Keine der 4
gefuehrten Formen … steht in den 16 (bzw. 18) gelesenen Zeilen"*. Gemessen an den Jobs
`112691251599`, `112729405107`, `112925525011`
(`gh api repos/pt9912/ai-harness-init/actions/jobs/<id>/logs | grep -nE 'curl: \(22\)|AUSGANG'`).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** pt9912 (Implementer)

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** `harness/tools/full-smoke-ausgang.sh` ordnet die `curl`-Antwort eines nicht mit 2xx
beantworteten Asset-Abrufs (`curl: (22) The requested URL returned error: <code>`) dem Ausgang
LEITUNG zu und nennt im Beleg die Klasse *„Release-Asset nicht abrufbar"*, statt den Fehlschlag
dem Baum zuzurechnen. **Grenze, im Kopf des Skripts zu nennen:** der Text trennt *nicht
veröffentlicht* nicht von *falsch gepinnt* — beide sind eine nicht mit 2xx beantwortete Anfrage,
dieselbe Lesart wie Muster (4) für einen nicht vergebenen Bild-Tag; die Klasse behauptet keine
Ursache. Gemeint ist allein `(22)`; ein anderer `curl`-Fehler (etwa `(23)`, Schreibfehler am Ziel)
bleibt BAUM.

**Lage** (keine Erwartungswerte): `grep -c "^	'" harness/tools/full-smoke-ausgang.sh` zählt die
gefuehrten Muster, keines trifft eine `curl`-Zeile; `grep -n 'curl -fsSL' harness/tools/traeger-fetch.sh`
nennt die zwei Abrufe (Prüfsummen, Asset), deren Fehltext das ist; der Ausschnitt, den `einordnen`
bekommt, trägt die `curl`-Zeile unverändert (`harness/tools/full-smoke.sh`, Stufe
`make traeger-fetch im frischen Klon`).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Struktur-Entscheidung gegen das Rennen von `ci` und Publikation** (Wartezeit oder
  Workflow-Anordnung). *Folge-Slice übernimmt es:* `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`
  — die Closure dieses Slice hebt `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`
  auf 3× (§8) und legt die Datei in `open/` an; dieser Slice macht nur den Fehlschlag richtig
  lesbar, der Lauf bleibt rot.
- **Ein dritter Ausgang oder ein eigener Exit-Code.** *Bestand bleibt:* die zwei Ausgänge und der
  gemeinsame Exit-Code sind im Kopf von `full-smoke-ausgang.sh` gesetzt ([`AGENTS.md`](../../../../AGENTS.md)
  §3.5); die Klasse steht in der Beleg-Zeile unter LEITUNG.
- **Ein Ausweichen von `traeger-fetch` bei 404.** *Bestand bleibt:* [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2 verlangt den lauten Bruch.

## 2. Definition of Done

- [x] **1 — Einordnung:** ein Muster für `curl: (22) The requested URL returned error: <code>` in
      `full-smoke-ausgang.sh`, mit Herkunft am Muster (die drei Jobs aus dem Kopf) und Klassenname
      in der Beleg-Zeile; `test/full-smoke-ausgang.bats` trägt den Fall über dem **zitierten**
      Ausschnitt aus Job `112925525011` (LEITUNG) und einen Baum-Fall mit `curl: (23)` im Text
      (BAUM). **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6), je Zusicherung ein Fall
      in `test/mutations/` (`verify: test-bats`), beide über `make mutate MUTATE_CASES=<nr>` als
      gebunden gemeldet: das Muster entfernt (LEITUNG-Fall rot) · das Muster auf jeden
      `curl: ([0-9]+)` geweitet (Baum-Fall rot).
- [x] **2 — Reale Quelle:** ein Fall in `test/mutations/` (`verify: full-smoke`, `files:
      internal/emit/templates/enforce/traeger.mk`) zieht den emittierten `TRAEGER_TAG` auf einen
      nicht veröffentlichten Tag; `make mutate MUTATE_CASES=<nr>` meldet ihn gebunden mit
      `AUSGANG LEITUNG` und der Klasse an der Stufe `make traeger-fetch im frischen Klon`.
      **Gegenprobe:** derselbe Fall über dem Stand ohne das Muster aus Punkt 1 erfüllt sein
      `expect` nicht (er endet in `AUSGANG BAUM`, wie in den drei Jobs) — der Bruch an der
      realen Quelle, nicht nur am Ausschnitt.
- [x] **3 — Doku:** [`docs/user/releasing.md`](../../../user/releasing.md) §Prozedur Schritt 6
      nennt, woran der 404-Fall im `ci`-Log zu erkennen ist (Ausgang und Klasse) — Ist-Zustand.
      **Ein Wächter existiert nicht:** kein Sensor liest den Satz gegen die Ausgabe des
      Einordners; Träger ist der Review.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke-ausgang.sh` | update | Muster, Herkunft, Klassenname in der Beleg-Zeile, Grenz-Absatz im Kopf (Liefer-Punkt 1) |
| `test/full-smoke-ausgang.bats` | update | zitierter Ausschnitt aus Job `112925525011` (LEITUNG) und ein Baum-Fall mit `curl: (23)` — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `test/mutations/` | neu | Muster weg und Muster geweitet (`verify: test-bats`); emittierter `TRAEGER_TAG` auf unveröffentlichten Tag (`verify: full-smoke`, Liefer-Punkt 2) |
| `docs/user/releasing.md` | update | Schritt 6 (Liefer-Punkt 3) |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; keine Abhängigkeit.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: der `curl`-Fehltext trägt im Ausschnitt, den `einordnen` bekommt, keine
  unterscheidbare Form (etwa weil `traeger-fetch` ihn umformt) — dann zuerst die Ausgabe des Abrufs
  schneiden.
- `in-progress` → `open`: das Muster trifft auch einen Fehlschlag, der dem Baum gehört (ein
  falsch geschriebener Pin im Ziel) — dann Übergabe an den Architect, ob die Klasse unter LEITUNG
  steht.

## 5. Closure-Trigger

1. `make gates` grün, beide Mutations-Fälle als gebunden gemeldet.
2. Die Beleg-Zeile mit der Klasse steht in der Ausgabe des roten `full-smoke`-Laufs aus
   Liefer-Punkt 2 (gelesen, nicht nur der Exit).

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Fremder 404 wird zu LEITUNG** — ein Abruf mit falsch gesetztem Pin im Ziel liefert denselben
  `curl`-Text; die Klasse trennt beides nicht (Grenze in §1). — **Ausgang:** entfallen — die Klasse
  behauptet keine Ursache (Grenze im Kopf von `full-smoke-ausgang.sh`), und ein falscher Pin-**Wert**
  im emittierten Fragment fällt vorher in `make gates` am Fall `pin-kopplung`; die Namens-Lücke daneben
  trägt `slice-full-smoke-misst-den-emittierten-traeger-pin`.
- **Der Mutations-Fall aus Liefer-Punkt 2 braucht Netz und einen fast vollen Lauf.** — **Ausgang:**
  entfallen — gemessen bricht der Lauf nach 24 s an der Stufe ab
  ([Verifikation](../../../reviews/2026-10-07-404-verifikation.md)).
- **Register erreicht 3×** — ein Beleg für die drei Schnitte (ein Vorgang zählt einmal). —
  **Ausgang:** eingetreten: `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** DoD 1–3 bestätigt; Rot-Beleg an der realen Quelle
  (`internal/emit/templates/enforce/traeger.mk`) mit der Klassen-Zeile gelesen, `make full-smoke`
  grün ([Verifikation](../../../reviews/2026-10-07-404-verifikation.md)). Review 0 HIGH/MEDIUM;
  F1 und F5 behoben in `2663b1e3` ([Review](../../../reviews/2026-10-07-404-review.md)).
- **Was ging anders als geplant:** Der Rückführungs-Trigger `in-progress → open` aus §4 ist der Form
  nach erfüllt (ein falsch gesetzter Pin liefert dasselbe `(22)`); Urteil: getragen von der im
  Skriptkopf benannten Grenze, keine Rückführung (Review F2). `curl`-Ausfälle ohne Antwort (`(6)`,
  `(28)`) bleiben BAUM, ihr Docker-Gegenstück LEITUNG — als Grenze hingenommen (Review F3).
- **Steering-Loop-Eintrag:** Lese-Schritt — `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`
  steht bei 3×, Ausgang *geplant* mit `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`.
  Benannte Sensor-Lücke (Review F4): kein Wächter liest den emittierten Träger-Pin unter
  Adopter-Bedingung — `make full-smoke` erbt `TRAEGER_TAG` aus dem Dogfood-Export, `pin_wert` greift
  per Präfix; gezählt, nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)
  Beleg `evidence/slice-full-smoke-erkennt-unveroeffentlichtes-artefakt.md` ergänzt — Zähler 3×,
  Stand *geplant*.
  [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  Beleg ergänzt (Stufe 5 der E2E-Sicht verschweigt den Dogfood-Pin), Stand unverändert.
- **Folge-Slices:** `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`,
  `slice-full-smoke-misst-den-emittierten-traeger-pin` — Dateien in `open/`.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR:
  [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) umgesetzt, kein
  Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `TOOLS` (`harness/tools/full-smoke-ausgang.sh`)
und `*` (`test/`, `docs/user/releasing.md`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`ls docs/plan/planning/observations/BEO-ALL/ | grep -i 'smoke\|ausgang\|release\|fetch\|klassif'`).
Treffer: `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` — Zähler-Stand
`ls docs/plan/planning/observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/evidence/ | wc -l`
→ 2; die Auftreten bei `v0.3.0`, `v0.4.0` und `v0.5.0` tragen dort noch keinen Beleg. Dieser Slice
löst die Beobachtung nicht (§1), er macht ihr Symptom im `ci`-Log erkennbar; seine Closure schreibt
den dritten Beleg (§6), damit braucht die Struktur-Entscheidung den Folge-Slice aus §1. Übrige
Treffer der Suche betreffen andere Klassen.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
