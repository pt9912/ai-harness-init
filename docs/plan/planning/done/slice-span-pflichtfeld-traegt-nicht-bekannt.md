# Slice slice-span-pflichtfeld-traegt-nicht-bekannt: Ein Pflichtfeld des Spans, dessen Wert die Quelle nicht liefert, bleibt Pflicht und trägt die Kennzeichnung *nicht bekannt*

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
[`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans),
[`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) (Festlegung 3, Zeile Welle 154;
Festlegung 4),
[`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) (Festlegung 3,
bestätigt durch [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4 Punkt 4),
[`ADR-0076`](../../adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md)
(Festlegung 1, teilweise abgelöst),
[`MR-076`](../../../../harness/conventions.md#mr-076),
[`MR-077`](../../../../harness/conventions.md#mr-077),
[`MR-075`](../../../../harness/conventions.md#mr-075).

**Berührte Spec-Stellen:** `SPEC-024`, `SPEC-055`, `SPEC-087`, `SPEC-010`, `SPEC-011`, `SPEC-012`
(`spezifikation.md §5`).

**Verantwortlich:** pt9912 (Implementer).

**Autor:** Planner. **Datum:** 2026-10-06.

---
## 1. Ziel und Abgrenzung

**Ziel:** `SPEC-024` (Cache-Status) ist `Pflicht`. Liefert die Payload die Zähler nicht, trägt der
Span die ausdrückliche Kennzeichnung *nicht bekannt* samt Nennung der Quelle — nicht `0`, nicht
`false`, nicht Abwesenheit (Baseline-Regelwerk `modul-15-observability.md` §Span-/Audit-Attribut-Regeln
am Tag `v6.16.0`, Welle 154). Die Draht-Form legt die Spezifikation fest
([`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4 Punkt 1); Erfassung
und Tests folgen. `SPEC-010`/`011`/`012` sind nach Festlegung 4 Punkt 3 eingeordnet: wo `""` *nicht
bekannt* heißt (`agent_role`, Lesevorschrift `SPEC-044`), steht das als Einordnung; wo `""` einen Wert
trägt (*kein Slice*, *kein Bezug*), bleibt er von *nicht bekannt* unterscheidbar.

**Schnitt.** Dieser Slice liefert die Cache-Status-Hälfte, die
[`MR-076`](../../../../harness/conventions.md#mr-076) trägt. Die `agent_role`-Hälfte verlangt eine
Änderung von [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) (Kriterium
*Rolle wird abgeleitet*: das Feld bleibt bei `general-purpose` und im Haupt-Kontext leer) und geht an
den Folge-Slice (Ausschluss unten).

**Lage** (Arbeitsbaum dieses Plans, keine Erwartungswerte):

```sh
grep -E '^\| `SPEC-024`' spec/spezifikation.md | grep -c '| Optional |'           # 1
git grep -l 'cache_creation_input_tokens' -- internal ':!*_test.go'              # internal/span/fieldlist.go, internal/span/response.go
git grep -n 's.AgentRole != ""' -- internal/report                               # report.go: leere Rolle -> Sammelposten
```

**Leser.** Den Cache-Status liest die Auswertung (`make span-report`) nicht. `agent_role` liest
sie: eine leere Rolle geht in den Sammelposten (`internal/report/report.go`, `SPEC-044`) — trägt das
Feld künftig die Kennzeichnung, muss die Auswertung sie wie `""` lesen, sonst wird *nicht bekannt*
eine eigene Rolle.

**Emittierte Ebene.** Betroffen, ohne eigenen Liefer-Punkt: die emittierte Feldliste
(Zielpfad `FieldListPath`) wird verbatim aus `span.FieldList` geschrieben
(`internal/emit/fieldlist.go`) und zieht die Änderung an `internal/span/fieldlist.go` konstruktiv
nach; der emittierte Hook `span-emit.sh` ruft den Träger, der die Erfassung mit dem nächsten
Release ins Ziel bringt (`make traeger-fetch`, gepinnt). Kein emittierter Text daneben nennt die
Draht-Form.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Aufhebung von [`MR-076`](../../../../harness/conventions.md#mr-076).** *Anderer Vorgang
  einer anderen Rolle:* Der Architect hebt den Eintrag erst **nach** dem Umstellungs-Commit auf, in
  eigenem Commit ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4 Punkt 2; [`AGENTS.md`](../../../../AGENTS.md) §3.8). Dieser
  Slice liefert ihm das Übergabe-Artefakt (§2).
- **[`MR-077`](../../../../harness/conventions.md#mr-077) (branch/commit statt PR-Nummer).**
  *Bestand bleibt stehen:* ein Ersatzfeld, kein fehlender Wert ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 3).
- **`SPEC-022` `spawned_role` und die Draht-Form aus `SPEC-083`.** *Bestand bleibt stehen:* `Optional`,
  keine Pflicht des Minimums (Festlegung 4 Punkt 3); seine Abwesenheit sagt *kein Subagent*.
- **Kein Umschreiben vorhandener Spans.** *Bestand bleibt stehen:* der Span-Bestand ist lokal und
  nicht versioniert.
- **Verfügbarkeit und Aufbewahrung der emittierten Feldliste.** *Folge-Slice übernimmt es:*
  `slice-emittierte-feldliste-traegt-verfuegbarkeit-und-aufbewahrung`; hier zieht die Feldliste
  nur den Inhalt nach, der aus `span.FieldList` kommt.
- **Ein Release des Trägers.** *Anderer Vorgang:* der Release-Schnitt.
- **Die Kennzeichnung bei `agent_role`, `SPEC-010`/`SPEC-043`/`SPEC-044` und die Auswertung
  (`make span-report`).** *Folge-Slice übernimmt es:* `slice-agent-role-traegt-nicht-bekannt`
  (`open/`), Start-Trigger ist der Entscheid des Auftraggebers über den Change Request zu
  [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung)
  ([`MR-015`](../../../../harness/conventions.md#mr-015),
  [`MR-036`](../../../../harness/conventions.md#mr-036)). Bis dahin bleibt das Feld leer, und
  `SPEC-043` trägt *(Abweichung 3)*.

## 2. Definition of Done

- [x] **1 — Spezifikation:** `SPEC-024` steht auf `Pflicht`; eine Festlegungs-Zeile in §5 nennt die
      Draht-Form der Kennzeichnung *nicht bekannt* und wie die Quelle genannt wird, mit
      Bindungs-Spalte nach [`MR-075`](../../../../harness/conventions.md#mr-075); `SPEC-055` führt
      den Cache-Status nicht mehr als Abweichung; je Feld `SPEC-010`/`011`/`012` steht, ob `""`
      *nicht bekannt* heißt oder einen Wert trägt.
- [x] **2 — Erfassung, Feldliste und Tests:** Ein Span aus einer Payload ohne `usage` trägt beim
      Cache-Status die Kennzeichnung, einer mit `usage` die Zähler; die Feldliste
      (`span.FieldList`, emittiert verbatim) nennt sie. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Erfassung lässt das Feld weg, schreibt `0`
      oder `""` — der benannte Test wird mit einer Meldung über genau dieses Feld rot; ein Fall in
      `test/mutations/` hält die Zusage ([`make mutate`](../../../../harness/sensors/mutate.md) mit
      `MUTATE_CASES`).
- [x] `make gates` grün ([Verifikation](../../../reviews/2026-10-07-cache-status-verifikation.md); nach `06f7c614` EXIT 0).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Übergabe an den Architect (abgehakt mit verschobenem Kriterium, §7 Planner-Entscheidung): [`MR-076`](../../../../harness/conventions.md#mr-076) ist nach dem
      Umstellungs-Commit aufgehoben (Kopf und Zeiger,
      [`MR-020`](../../../../harness/conventions.md#mr-020)), eigener Architect-Commit — Bedingung
      der Closure.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen); nach dem Move gefahren, §7.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §5 | update | Liefer-Punkt 1 |
| `internal/span/response.go`, `internal/span/notknown.go`, `internal/span/fieldlist.go` | update | Kennzeichnung schreiben, Feldliste (Liefer-Punkt 2) |
| `internal/span/*_test.go` | update | Happy/Negative nach [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans) |
| `test/mutations/<NNN>-…sh` | neu | Mutations-Fall für Liefer-Punkt 2 |

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-sprung-auf-v6160-wird-vollzogen` liegt in `done/` — die
Quelle der Kennzeichnung (`modul-15` am Tag `v6.16.0`) ist dann vendored, und
[`MR-076`](../../../../harness/conventions.md#mr-076) ist durch den Durchgang nicht vorzeitig
aufgehoben. WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: die Einordnung von `SPEC-011`/`012` verlangt mehr als eine Spec-Zeile —
  etwa einen Umbau der Slice- oder Bezugs-Ableitung —, oder ein weiterer Leser von `agent_role`
  außer `internal/report` taucht auf; dann wird das ein eigener Slice.
- `in-progress` → `open`: Die Draht-Form kollidiert mit einer `Accepted`-Festlegung (etwa
  [`ADR-0074`](../../adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) oder `SPEC-083`),
  oder die Quelle ist für einen Lauf nicht benennbar — Übergabe an den Architect.

**Keine Rückführung trotz Blocker.** Die `agent_role`-Hälfte kollidiert mit
[`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) (Rang 1), nicht mit einer
ADR — die Bedingung `in-progress → open` trifft sie nicht, und der Slice bleibt ohne sie lieferbar.
Sie verlässt den Slice per Plan-Änderung an `slice-agent-role-traegt-nicht-bekannt` (§1); der Rest
bleibt in `in-progress/`.

## 5. Closure-Trigger

1. `make gates` grün mit den Tests aus Liefer-Punkt 2; der Mutations-Fall läuft unter
   `make mutate` mit `MUTATE_CASES` und färbt seinen Wächter.
2. [`MR-076`](../../../../harness/conventions.md#mr-076) liegt unter `harness/conventions/done/`,
   und `grep -c "SPEC-024.*| Pflicht |" spec/spezifikation.md` → **1**.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Bedeutung eines Span-Felds wechselt ohne Fassungs-Angabe** — `SPEC-024` ändert seine Draht-Form;
  Spans vor und nach der Umstellung stehen nebeneinander.
  `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` steht bei
  2 Belegen; ein dritter ist eine Lücke mit
  eigenem Folge-Slice. — **Ausgang:** weiter offen → Register: `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` erreicht mit diesem Slice 3×, den Ausgang weist der Lese-Schritt der nächsten Welle-Closure zu.
- **Die Kennzeichnung wird als Wert gelesen** — ein Leser, der summiert, zählte sie beim
  Cache-Status als `0`; beim Cache-Status liest heute keiner. — **Ausgang:** entfallen — die Kennzeichnung ist eine Zeichenkette (`SPEC-087`), ein summierender Leser kann sie nicht als `0` lesen, und den Cache-Status liest keiner; der Leser von `agent_role` liegt bei `slice-agent-role-traegt-nicht-bekannt`.
- **Feldliste und Träger eines Ziels auf verschiedenem Stand** — gemessen: je Release-Tag stimmen
  Feldliste und Träger überein; ein Werkzeug von unveröffentlichtem `main` schreibt die Feldliste mit
  *Pflicht*, während `make traeger-fetch` den gepinnten Träger `v0.2.8` holt, der das Feld weglässt.
  Der nächste Release (`v0.3.0`) schließt die Lücke. — **Ausgang:** weiter offen → Register: Beleg in `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` (Review I-1 bestätigt die Lage); die Lücke schließt der Release `v0.3.0`, Träger ist der Release-Schnitt.
- **Die Kurs-Regel gilt hier nur verengt** — `SPEC-087` bindet die Kennzeichnung allein an die
  Cache-Zähler; `agent_role` bleibt leer, `SPEC-043` trägt weiter *(Abweichung 3)* gegen
  `modul-15` am Tag `v6.16.0`. — **Ausgang:** eingetreten → Folge-Slice
  `slice-agent-role-traegt-nicht-bekannt` (§1).

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
**Rolle:** Planner · **Datum:** 2026-10-07

- **Was hat funktioniert:** `SPEC-024` steht auf `Pflicht`, `SPEC-087` nennt die Draht-Form
  `nicht bekannt: <Quelle>`; Umstellung `91af2b67`. Fünf Mutations-Fälle (536–540) halten die Zusage,
  je rot gesehen mit gelesener Meldung
  ([Verifikation](../../../reviews/2026-10-07-cache-status-verifikation.md) §Rot-Belege). Review:
  0 HIGH, M-1/L-1/L-2 behoben in `b0c73625`
  ([Review](../../../reviews/2026-10-07-cache-status-review.md)).
- **Was ging anders als geplant:** Die DoD nannte die Eingaben *ohne `usage`* und *mit `usage`*;
  `SPEC-087` sagt für jeden nicht gelieferten Zähler zu. Der Fall *`usage` ohne Cache-Schlüssel* war
  unbewacht (Verifikation V-1) und ist in `06f7c614` nachgezogen (Test-Teilfall, Fall 540, `make gates`
  EXIT 0). Damit ist DoD 2 bestätigt, nicht mehr bedingt.
- **Planner-Entscheidung — `SPEC-055` (Hinweis des Implementer):** Die Aufzählung in `SPEC-055` nennt
  *`usage` ohne Cache-Schlüssel* nicht. Kein DoD-Mangel: DoD 1 verlangt, dass `SPEC-055` den
  Cache-Status nicht mehr als Abweichung führt, und die allgemeine Regel `SPEC-087` trägt den Fall samt
  Wächter. Die Präzisierung geht an `slice-agent-role-traegt-nicht-bekannt` (§1 Punkt 3), der `SPEC-087`
  ohnehin weitet.
- **Planner-Entscheidung — verschobenes Abnahmekriterium (DoD 5, Closure-Trigger 2 erste Hälfte):**
  Abgehakt ist die **erteilte Übergabe** an den Architect. Die Aufhebung von
  [`MR-076`](../../../../harness/conventions.md#mr-076) ist Folgepflicht in eigenem Architect-Commit
  nach dieser Closure ([ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 4
  Punkt 2 bindet sie an den Umstellungs-Commit, nicht an die Closure). Bis dahin führt der
  Adaptions-Block eine Abweichung, die nicht mehr besteht. Kein Sensor hält das, Träger ist der
  Architect-Lauf. Die zweite Hälfte von Closure-Trigger 2 hält:
  `grep -c "SPEC-024.*| Pflicht |" spec/spezifikation.md` → **1**. Der DoD-Wortlaut bleibt stehen.
- **Übergaben an `slice-agent-role-traegt-nicht-bekannt` (`open/`, §1/§6):** Verifikation V-2
  (Rang-1-Lesart von [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans)
  *Leer heißt unbekannt* gegen `SPEC-011`/`012`) und Review L-3 (`references()` liefert `[]` auch bei
  unlesbarer Slice-Datei). Beide gehören in den Change Request zu
  [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung).
- **Steering-Loop-Eintrag:** *Geschärfte Regel*. Ein DoD-Rot-Punkt nennt die Fallmenge der
  Spec-Zusage, die er liefert, nicht eine Auswahl ihrer Eingaben. Ein Feld `liegt in` gibt es nicht,
  weil mit diesem Slice nichts verkörpert ist. Die Klasse zählt im Register (unten).
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/dod-rot-punkt-nennt-eingaben-enger-als-die-spec-zusage`](../observations/BEO-ALL/dod-rot-punkt-nennt-eingaben-enger-als-die-spec-zusage/observation.md)
  neu (1×);
  [`BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe`](../observations/BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/observation.md)
  erreicht **3×**;
  [`BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere`](../observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/observation.md)
  (Review L-1) steht bei 5×; [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md)
  (Risiko 3, Review I-1) trägt einen weiteren Beleg und bleibt verkörpert. Die zwei offenen Einträge über der Schwelle bleiben `offen`; den Ausgang weist der
  Lese-Schritt der nächsten Welle-Closure zu, denn das Repo fährt Wellen. Review M-1 (toleranter
  Zahl-Parser liest `null` als `0`) und L-2 (Meldung nennt fremde Ursache) sind behoben und benannt,
  nicht gezählt.
- **Folge-Slices:** keiner neu; Adresse der Übergaben ist `slice-agent-role-traegt-nicht-bekannt`
  (`open/`).
- **Trigger-Audit:** Carveouts: keiner neu und keiner berührt. Bootstrap-aware Gates: keines berührt.
  ADR: [ADR-0078](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) `Accepted`, Festlegung 4
  Punkt 2 offen beim Architect (oben). Hard Rules: keine mit Auflösungs-Trigger aus diesem Vorgang.
- **Risiken aus §6:** Jede Zeile in §6 trägt ihren Ausgang.
- **Paarungen geprüft am 2026-10-07** (nach dem Move): (a) *Anker*: §7 trägt kein Feld `liegt in`,
  es gibt nichts zu prüfen. (b) *Folge-Slice*: `slice-agent-role-traegt-nicht-bekannt` liegt in
  `open/` (`ls docs/plan/planning/next/slice-agent-role-traegt-nicht-bekannt.md`). (c) *Register*: Die
  vier zitierten Pfade existieren, `evidence/` trägt 1, 7, 5 und 3 Dateien. Zweite Hälfte über das
  ganze Register: 3 Verzeichnisse ohne Beleg, namentlich
  `BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab` und
  `BEO-ALL/planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; sie gelten nicht als getragen
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
  Festlegung 2).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — `internal/span/` und
`spec/` liegen in keiner engeren deklarierten Sub-Area; `TOOLS` und `CODEX` sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand gesichtet, nach
Gegenstand; Zähler `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`:
`span-feld-bedeutung-wechselt-ohne-fassungs-angabe` —
2 (§6). Kein weiterer Treffer zum
Erfassungs-Schema.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).

