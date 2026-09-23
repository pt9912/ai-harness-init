# Slice slice-das-werkzeug-sagt-seine-fassung: Das Werkzeug meldet die Fassung des geschnittenen Tags selbst — `ai-harness-init --version`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Ein einzelner Posten; sein Closure-Trigger beobachtet
nichts, was die DoD darunter nicht ohnehin belegt (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:** [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
(*Accepted* — Festlegung 2 verwarf die Fassungs-Fläche; ihr Re-Evaluierungs-Trigger 1 ist der
Anlass dieses Slice), [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) (*Proposed* —
die Neuwägung selbst: die Fassung reist per `ldflags` aus `TRAEGER_TAG` am Tag-Bau),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Digest und die
Fassung identifizieren denselben Schnitt; zwei Kanäle, [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 3).

**Berührte Spec-Stellen:** [`spec/spezifikation.md`](../../../../spec/spezifikation.md) — die
Fassungs-Angabe der Bedienoberfläche wird hier **nicht** geschrieben; berührt ist der
Release-Bau-Rezept-Bestand ([`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag)
Rezept-Form).

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-23.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice. **§1 nennt Ziel und Abgrenzung**; je Ausschluss eine
Begründung.

**Ziel:** `ai-harness-init --version` meldet die Fassung des geschnittenen Tags; die Fassung
wird im Release-Bau per `ldflags` aus `TRAEGER_TAG` injiziert. Ein Bau **ohne** Release-Injektion
(Quellstand) meldet den Fehlt-Fall laut statt einer leeren oder erfundenen Zahl — die Semantik
entscheidet [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 2.

**Warum der Anlass:** Der Auftraggeber mess am 2026-09-23 ohne brew und ohne `--version` keine
Möglichkeit, eine installierte Fassung zu erkennen (der Download-Weg bleibt fassungs-spurlos,
wenn die Datei bewegt wird). [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 verworfen die Fläche bewusst; der Re-Evaluierungs-Trigger 1 der ADR nennt den
Einbau eines `version`-Flags als den Anlass, den Stempel neu zu wägen — genau das ist eingetreten.

**Ausdrücklich NICHT in diesem Slice:**

- **Die Formel und die `SHA256SUMS` bleiben, wie sie sind.** Die zwei Kanäle
  ([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  Festlegung 3) ändern sich nicht — **Schicht-Abgrenzung**.
- **Kein Signier-Schritt.** Die Grenze steht in
  [`docs/user/releasing.md`](../../../../docs/user/releasing.md) §Grenze — **anderer Vorgang**.
- **Der Pin trägt weiter nur den Tag.** Der Zahn an der Selbstreferenz-Wand (der
  pin-kopplung-Test in `test/traeger-fetch.bats`) bewacht die **Pin**-Achse und bleibt; der
  Fassungs-Stempel im Binary ist die **Binary**-Achse, die
  [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) neu ordnet.
- **Kein zweiter Weg in die Formel-Nachzug-Form.** Die Formel liest die Fassung weiter aus dem
  Release (Festlegung 3 von [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**, jeder mit dem Kommando, das ihn
**rot** färbt ([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) `ai-harness-init --version` meldet die Fassung oder ihren Fehlt-Fall laut.** Mit
      Injektion: die Fassung des Tags, unter dem gebaut wurde ([`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 1). Ohne
      Injektion (Quell-Bau): der Fehlt-Fall in klarem Wortlaut, Exit 2 — nicht leer, nicht der
      Pin-Wert des Builds. Die Semantik bindet [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
      Festlegung 1 und 2.
      **Rot:** `test/mutations/` — der Fall ohne Injektion (das Werkzeug meldet den Fehlt-Fall)
      und der Fall mit abweichender Fassung.
- [ ] **(2) Der Release-Bau injiziert die Fassung.** `make release-artifacts` und die
      `artifact`-Ziele fahren den `ldflags`-Injektions-Schritt aus `TRAEGER_TAG`
      ([`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 1); die
      byte-identische Eigenschaft des Default-Pfads ([`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag))
      bleibt für denselben Tag bestehen (gleiche Injektion, gleiche Bytes).
      **Rot:** `make mutate` — die Injektion entfernt oder auf einen falschen Operanden
      gestellt → der Wächter fällt.
- [ ] **(3) Doku-Nachzug.** Das Handbuch trägt in Weg A, B und C, wie die Fassung erkannt wird
      (`--version` am Werkzeug; die Formel und der Digest gegen die `SHA256SUMS` bleiben die
      zwei Beleg-Wege neben dem Flag) — [`AGENTS.md`](../../../../AGENTS.md) §3.7
      (Ist-Zustand, keine Chronik).
      **Rot:** `make gates` — `docs-check` hält die Referenzen.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: der Weg-C-Abschnitt trägt die Fassungs-Erkennung (Liefer-Punkt 3); der
      Release-Text des nächsten Schnitts nennt das Flag — Vorbedingung (§4), nicht Gegenstand
      dieses Slice.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt
      die Datei *reconciliation.md* nicht (`ls docs/plan/planning/reconciliation.md`).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis
      `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zähler wird
      gesetzt**, er folgt aus den Dateien.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — dieses Repo führt
      Wellen-Betrieb; der Träger ist die nächste Welle-Closure.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — Pfad-Kandidaten für §8.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/`](../../../../internal/) (Dispatch/CLI-Ebene) | update | `--version`-Verarbeitung samt Fehlt-Fall-Meldung |
| [`Makefile`](../../../../Makefile) | update | `ldflags`-Injektion aus `TRAEGER_TAG` in `artifact`/`release-artifacts`/`host-bin` |
| [`test/mutations/`](../../../../test/mutations) | neu | zwei Fälle — Fassung fehlt, Fassung weicht ab |
| [`docs/user/benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) | update | Weg A/B/C: die Fassungs-Erkennung (Ist-Zustand) |

Reihenfolge: der Release-Bau zuerst (Liefer-Punkt 2) — er sagt, was die Injektion überhaupt
setzen kann; danach das Flag (Liefer-Punkt 1), danach der Handbuch-Nachzug (Liefer-Punkt 3).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
liegt angelegt (`Proposed`) und trägt die drei Festlegungen; WIP-Limit frei; Implementer
übernimmt.

**Rückführungen — vorab benennen:**

- `in-progress` → `next` (zu groß): [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
  wägt gegen [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2 zurück — ohne die Injektion ist der Gegenstand hinfällig, der Slice zerfällt.
- `in-progress` → `open` (blockiert — Carveout?): der `ldflags`-Weg bricht die byte-identische
  Eigenschaft des Default-Pfads ([`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag))
  — dann ist die Reproduzierbarkeits-Aussage selbst neu zu schneiden, nicht das Flag zu
  verweichlichen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln.

1. `make gates` ist grün, und `ai-harness-init --version` meldet über dem gepinnten Bau die
   Fassung aus `TRAEGER_TAG` (gemessen am Träger, nicht an einer Zahl im Plan).
2. Der Fehlt-Fall ist einmal laut gesehen (Bau ohne Injektion → klare Meldung, Exit ≠ 0 oder
   dokumentierter Ausgang — die Form trägt [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
   Festlegung 2).

Dazu ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

1. **Ein lokal gebautes Binary meldet den Pin-Stand, nicht den Quellstand.** *Absehbar:*
   entfallen — die Form trägt [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
   Festlegung 2: der Fehlt-Fall (Bau ohne Injektion) laut, die Injektion nur am Release-Bau;
   `make artifact` ohne gesetzten Kontext fällt in den Fehlt-Fall.
2. **Die Injektion bricht die byte-identische Eigenschaft des Default-Pfads.** *Absehbar:*
   entfallen — die Identität bleibt für denselben Injektions-Wert (der Pin-Wert ist je Bau
   gleich); der Zahn an [`MR-048`](../../../../harness/conventions.md#mr-048--der-reproduzierbarkeits-anker-ist-die-rezept-form-die-emittierten-skelette-pinnen-per-tag) bewacht weiter den Vergleich, [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md)
   Festlegung 3 trägt die Abgrenzung.
3. **Die Formel-Nachzug-Form liest die Fassung zweifach** (Formel `version`-Feld und Binary).
   *Absehbar:* entfallen — der Fetch und die Formel bleiben die zwei Kanäle
   ([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
   Festlegung 3), das Flag ist der dritte, belegende Ort.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register · `grundlagen-traceability.md` §Herkunfts-Anker.

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb — der Träger ist die nächste Welle-Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `internal/`, `test/mutations/` und
`docs/user/` — alle in `*`. Die berührte Sub-Area erfüllt das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge des Registers führen die Sub-Area
`*`; gesichtet ist nach Gegenstand. Kein Eintrag der berührten Gegenstände steht im Register.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).