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
- [ ] **2 — Umsetzung:** Skript unter `harness/tools/` (in `shell-lint`), Make-Target, Schritt vor
      `make full-smoke` im `ci`-Job, Zeile in [`harness/README.md`](../../../../harness/README.md)
      §Werkzeuge mit `kein Gate`; Abfrage über das gepinnte curl-Bild von `traeger-fetch`, kein
      Host-curl; Grenze per Variable verkürzbar. **Rot gesehen** ([`AGENTS.md`](../../../../AGENTS.md)
      §3.6) an der realen Quelle: `TRAEGER_TAG` auf einen nie veröffentlichten Tag, Grenze verkürzt —
      das Warten endet mit der Grenz-Zeile und Exit 0, `make full-smoke` danach mit `AUSGANG LEITUNG`;
      gegen den gepinnten Tag endet es beim ersten Versuch. Ohne die README-Zeile ist
      `make docs-check` (Modul `targets`) rot.
- [ ] **3 — Doku:** [`docs/user/releasing.md`](../../../user/releasing.md) §Prozedur Schritt 6 im
      Ist-Zustand: Re-Run nur noch bei überschrittener Grenze. Kein Sensor hält den Wortlaut; Träger
      ist der Review.
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
  Pin-Kopplung weiter sofort). — **Ausgang:** offen bis zur Closure.
- **Der Nachweis am Release-Schnitt steht erst nach dem nächsten Release** — `ci` am Tag-Commit im
  ersten Versuch grün. — **Ausgang:** offen bis zur Closure; dann *weiter offen* als Beleg-Erwartung
  an `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`, gelesen vom nächsten
  Release-Schnitt.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `*` (`.github/workflows/`, `docs/user/`) und
`TOOLS` (neues Warte-Skript unter `harness/tools/`); `CODEX` nicht.

**Vorgelagert — offene Beobachtungen sichten:** Treffer
`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` bei 3× — dieser Slice ist sein
Ausgang *geplant*.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

