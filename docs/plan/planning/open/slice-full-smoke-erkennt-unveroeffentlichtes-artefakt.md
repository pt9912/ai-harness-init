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
statt stiller Ausweichung). Anlass: Release-Schnitte `v0.3.0` und `v0.4.0` — der `ci`-Lauf am
Tag-Commit fiel im `full-smoke` an `make traeger-fetch` im frischen Klon mit
`curl: (22) The requested URL returned error: 404` und meldete *„AUSGANG BAUM … Keine der 4
gefuehrten Formen … steht in den 16 gelesenen Zeilen"*; lokal reproduziert.

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-07.

---

## 1. Ziel und Abgrenzung

**Ziel:** `harness/tools/full-smoke-ausgang.sh` ordnet die `curl`-Antwort eines nicht mit 2xx
beantworteten Asset-Abrufs (`curl: (22) The requested URL returned error: <code>`) dem Ausgang
LEITUNG zu und nennt im Beleg die Klasse *„Artefakt nicht veröffentlicht"*, statt den Fehlschlag
dem Baum zuzurechnen.

**Lage** (keine Erwartungswerte): `grep -n "^	'" harness/tools/full-smoke-ausgang.sh` nennt die
gefuehrten Muster, keines trifft eine `curl`-Zeile; `grep -n 'curl -fsSL' harness/tools/traeger-fetch.sh`
nennt die zwei Abrufe (Prüfsummen, Asset), deren Fehltext das ist.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Struktur-Entscheidung gegen das Rennen von `ci` und Publikation** (Wartezeit oder
  Workflow-Anordnung). *Anderer Vorgang:* sie trägt
  `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` und braucht eine Entscheidung;
  dieser Slice macht nur den Fehlschlag richtig lesbar, der Lauf bleibt rot.
- **Ein dritter Ausgang oder ein eigener Exit-Code.** *Bestand bleibt:* die zwei Ausgänge und der
  gemeinsame Exit-Code sind im Kopf von `full-smoke-ausgang.sh` gesetzt ([`AGENTS.md`](../../../../AGENTS.md)
  §3.5); die Klasse steht in der Beleg-Zeile unter LEITUNG.
- **Ein Ausweichen von `traeger-fetch` bei 404.** *Bestand bleibt:* [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2 verlangt den lauten Bruch.

## 2. Definition of Done

- [ ] **1 — Einordnung:** ein gemessenes Muster für den `curl`-Fehltext in
      `full-smoke-ausgang.sh`, mit Herkunft am Muster (CI-Log des `v0.4.0`-Schnitts) und
      Klassenname in der Beleg-Zeile; `test/full-smoke-ausgang.bats` trägt den Fall über dem
      **zitierten** Log-Ausschnitt (LEITUNG) und hält, dass ein Baum-Fehler mit `curl` im Text
      nicht zu LEITUNG wird. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6): ein Fall
      in `test/mutations/` nimmt das Muster weg, `make mutate MUTATE_CASES=…` meldet ihn gebunden.
- [ ] **2 — Reale Quelle:** ein Fall in `test/mutations/` (`verify: full-smoke`) zieht den im
      Ziel emittierten Träger-Pin auf einen nicht veröffentlichten Tag; der Lauf endet rot mit
      `AUSGANG LEITUNG` und der Klasse an der Stufe `make traeger-fetch im frischen Klon` — der
      Bruch an der realen Quelle, nicht nur am Ausschnitt.
- [ ] **3 — Doku:** [`docs/user/releasing.md`](../../../user/releasing.md) §Prozedur Schritt 6
      nennt, woran der 404-Fall im `ci`-Log zu erkennen ist (Ausgang und Klasse) — Ist-Zustand.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/full-smoke-ausgang.sh` | update | Muster, Herkunft, Klassenname in der Beleg-Zeile, Grenz-Absatz im Kopf (Liefer-Punkt 1) |
| `test/full-smoke-ausgang.bats` | update | zitierter Ausschnitt aus dem `ci`-Log `v0.4.0` (LEITUNG) und ein Baum-Fall mit `curl` im Text — [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| `test/mutations/` | neu | Muster weg (`verify: test-bats`); Pin auf unveröffentlichten Tag (`verify: full-smoke`, Liefer-Punkt 2) |
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
  `curl`-Text; der Einordner kann „nicht veröffentlicht" und „falsch gepinnt" nicht trennen.
  — **Ausgang:** offen bis zur Closure.
- **Der Mutations-Fall aus Liefer-Punkt 2 braucht Netz und einen vollen Lauf** — Preis wie bei
  `test/mutations/189-emittierter-pin-nicht-aufloesbar.sh`. — **Ausgang:** offen bis zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `TOOLS` (`harness/tools/full-smoke-ausgang.sh`)
und `*` (`test/`, `docs/user/releasing.md`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet
(`ls docs/plan/planning/observations/BEO-ALL/ | grep -i 'smoke\|ausgang\|release\|fetch\|klassif'`).
Treffer: `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` — Zähler-Stand
`ls docs/plan/planning/observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/evidence/ | wc -l`
→ 2; die Auftreten bei `v0.3.0` und `v0.4.0` tragen dort noch keinen Beleg. Dieser Slice löst die
Beobachtung nicht (§1), er macht ihr Symptom im `ci`-Log erkennbar; schreibt seine Closure einen
dritten Beleg, braucht die Struktur-Entscheidung einen eigenen Folge-Slice. Übrige Treffer der Suche
betreffen andere Klassen.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
