# Slice slice-ci-wartet-die-publikation-des-gepinnten-releases-ab: Der `ci`-Lauf am Tag-Commit rennt nicht gegen die Publikation des gepinnten Release

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

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (Festlegung 2: laut-Bruch statt stiller Ausweichung), [ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md), [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions). Verdikt:
`docs/reviews/2026-10-08-ci-rennen-architect-verdikt.md`. Anlass:
`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` bei 3× (Ausgang *geplant*).

**Berührte Spec-Stellen:** `—`

**Verantwortlich:** pt9912

**Autor:** Planner. **Datum:** 2026-10-07, auf das Verdikt gezogen 2026-10-08.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der `ci`-Job `full-smoke` wartet vor `make full-smoke` begrenzt (höchstens 15 Minuten), bis
`SHA256SUMS` und das Linux-amd64-Asset von `TRAEGER_TAG` abrufbar sind; ein Tag-Push, dessen Commit
den Träger-Pin auf den eigenen Tag zieht, fällt damit nicht mehr vor der Publikation. Das Warten
urteilt nicht: nach der Grenze endet es mit Exit 0, und `full-smoke` bricht unverändert mit
`AUSGANG LEITUNG`.

**Lage** (keine Erwartungswerte):
`ls docs/plan/planning/observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/evidence/ | wc -l`
zählt die Belege; `grep -n 'full-smoke' .github/workflows/ci.yml` zeigt den Job.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **`traeger-fetch`, auch die emittierte Fassung.** *Bestand bleibt:* der Adopter hat kein Rennen,
  sein Pin zeigt auf ein veröffentlichtes Release (Verdikt Festlegung 4).
- **Ein Ausweichen auf eine andere Fassung oder ein Umordnen von Tag und Pin-Commit.** *Bestand
  bleibt:* [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2;
  im Verdikt verworfen (b, c, d).
- **Die Einordnung des 404 im Log.** *Bestand bleibt:* der Einordner von `full-smoke` ordnet ihn
  LEITUNG zu (`slice-full-smoke-erkennt-unveroeffentlichtes-artefakt`, in `done/`).
- **Der emittierte Träger-Pin unter Adopter-Bedingung.** *Anderer Vorgang:*
  `slice-full-smoke-misst-den-emittierten-traeger-pin`.

## 2. Definition of Done

- [x] **1 — Entscheidung:** Architect-Verdikt `docs/reviews/2026-10-08-ci-rennen-architect-verdikt.md`
      (keine ADR; Variante (a) im Workflow, Grenze 15 Minuten).
- [x] **2 — Umsetzung:** Skript unter `harness/tools/` (in `shell-lint`), Make-Target, Schritt vor
      `make full-smoke` im `ci`-Job, Zeile in [`harness/README.md`](../../../../harness/README.md)
      §Werkzeuge mit `kein Gate`; Abfrage über das gepinnte curl-Bild von `traeger-fetch`, kein
      Host-curl; Grenze per Variable verkürzbar. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md)
      §3.6) an der realen Quelle: `TRAEGER_TAG` auf einen nie veröffentlichten Tag, Grenze verkürzt —
      das Warten endet mit der Grenz-Zeile und Exit 0; gegen den gepinnten Tag endet es beim ersten
      Versuch. `make full-smoke` danach mit `AUSGANG LEITUNG` ist in diesem Slice nicht nachgemessen;
      das Warten ändert `full-smoke` nicht, die Klasse hält der Fall aus
      `slice-full-smoke-erkennt-unveroeffentlichtes-artefakt`. Ohne die README-Zeile **und** den
      Eintrag in `targets.exempt-targets` ist `make docs-check` (Modul `targets`) rot; eine allein
      trägt.
- [x] **3 — Doku:** [`docs/user/releasing.md`](../../../user/releasing.md) §Prozedur Schritt 6 im
      Ist-Zustand: Re-Run nur noch bei überschrittener Grenze. Kein Sensor hält den Wortlaut; Träger
      ist der Review.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen); nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/` (neues Warte-Skript), `Makefile` (Target, `shell-lint`) | create / update | Liefer-Punkt 2 |
| `.github/workflows/ci.yml` | update | Schritt vor `make full-smoke` im Job `full-smoke` (Liefer-Punkt 2) |
| `harness/README.md` | update | §Werkzeuge-Zeile, `kein Gate` (Liefer-Punkt 2) |
| `docs/user/releasing.md` | update | Schritt 6 (Liefer-Punkt 3) |

## 4. Trigger

**Start** (`next` → `in-progress`): das Architect-Verdikt aus Liefer-Punkt 1 liegt vor; WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: der Umbau trägt mehr als eine Review-Sitzung — dann Skript/Workflow und
  Doku getrennt.
- `in-progress` → `open`: das gepinnte curl-Bild kann die Assets im `ci`-Job nicht abfragen, ohne
  eine Netz-Annahme, die [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
  widerspricht — Übergabe an den Architect.

## 5. Closure-Trigger

1. Der Rot-Beleg aus Liefer-Punkt 2 (nie veröffentlichter Tag → Grenz-Zeile, dann `AUSGANG LEITUNG`)
   und der `ci`-Lauf des Umsetzungs-Push, dessen Warte-Schritt beim ersten Versuch endet (Job-ID in §7).
2. `make gates` grün.

Der Beleg am nächsten Release-Schnitt (`ci` am Tag-Commit im ersten Versuch grün) ist kein
Closure-Kriterium; er steht als Risiko 2 in §6 und geht bei Closure ins Register.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Eine Wartezeit verdeckt einen falsch gesetzten Pin** — der laute Bruch kommt erst nach der
  Grenze. Im Verdikt als akzeptiertes Negativ hingenommen (`test/traeger-fetch.bats` hält die
  Pin-Kopplung weiter sofort). — **Ausgang:** entfallen — ein falscher Pin-Wert fällt in
  `make gates` an `test/traeger-fetch.bats` ohne Warten; die Grenze verzögert allein den Bruch im
  `ci`-Job, und das hält jeder Versuch mit seinem Zeitlimit auf höchstens Grenze plus Nachlauf
  ([Verifikation](../../../reviews/2026-10-08-release-warten-verifikation.md), F-1).
- **Der Nachweis am Release-Schnitt steht erst nach dem nächsten Release** — `ci` am Tag-Commit im
  ersten Versuch grün. — **Ausgang:** weiter offen — Beleg-Erwartung in
  [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md),
  gelesen vom nächsten Release-Schnitt.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-08

- **Was hat funktioniert:** Closure-Trigger 1: Rot-Beleg gegen `v0.0.0-nie-veroeffentlicht` (Grenz-Zeile
  mit `curl: (22) … 404`, Exit 0) und gepinnter Tag beim ersten Versuch
  ([Verifikation](../../../reviews/2026-10-08-release-warten-verifikation.md)); `ci`-Lauf des
  Umsetzungs-Push `37708662542`, Job `full-smoke` `113089053269` success, Log
  `… abrufbar beim Versuch 1 nach 9s.` Review: F-1/F-2 (MEDIUM) und F-3/F-4 (INFO) behoben in
  `ae01d305`, `06f14fcf` und Mutations-Fall 563
  ([Review](../../../reviews/2026-10-08-release-warten-review.md)).
- **Was ging anders als geplant:** DoD 2 behauptete ein `docs-check`-Rot allein ohne README-Zeile;
  der Eintrag in `targets.exempt-targets` trägt redundant, rot erst bei beiden — bei der Closure auf
  das Gemessene eingeschränkt, der Eintrag bleibt (wie bei `traeger-fetch`, `tap-check`). Der
  Kommentar am `timeout-minutes` nannte ungemessene Dauern, behoben in `0d0ed654`.
- **Steering-Loop-Eintrag:** Lese-Schritt —
  `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` von *geplant* auf *verkörpert* in
  `make release-warten` und dem Schritt davor im `ci`-Job; die Target-Zeile trägt den Anker
  `seit slice-ci-wartet-die-publikation-des-gepinnten-releases-ab` nicht, §7 führt darum kein Zielort-Feld.
  Benannte Sensor-Lücke: `BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`
  trifft zum zweiten Mal dieselbe Unterform (README-Zeile und `exempt-targets` als redundante Träger)
  trotz Verkörperung in [`AGENTS.md`](../../../../AGENTS.md) §3.10 — kein Sensor liest einen DoD-Satz
  „ohne X ist `docs-check` rot" gegen `targets.exempt-targets`; gezählt, nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md)
  Stand nachgezogen, kein neuer Beleg (das Rennen trat nicht auf).
  [`BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
  und
  [`BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  je ein Beleg ergänzt, Stand unverändert.
- **Folge-Slices:** keine.
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR:
  [ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 gehalten
  (das Warten urteilt nicht), kein Re-Evaluierungs-Trigger eingetreten. Hard Rules: keine.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-08** (nach dem Move): (a) *Anker*: §7 trägt kein Zielort-Feld,
  nichts zu prüfen. (b) *Folge-Slice*: keine genannt. (c) *Register*: die drei genannten Pfade
  existieren, `evidence/` trägt 3, 8 und 17 Dateien. Zweite Hälfte über das ganze Register:
  3 Verzeichnisse ohne Beleg, namentlich `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab`,
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (`.github/workflows/`, `docs/user/`) und
`TOOLS` (neues Warte-Skript unter `harness/tools/`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` bei 3× — dieser Slice ist sein
Ausgang *geplant*.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

