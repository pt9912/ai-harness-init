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

**Berührte Spec-Stellen:** `SPEC-024`, `SPEC-055`, `SPEC-010`, `SPEC-011`, `SPEC-012`, `SPEC-044`
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
bekannt* heißt (`agent_role`, Lesevorschrift `SPEC-044`), dieselbe Kennzeichnung; wo `""` einen Wert
trägt (*kein Slice*, *kein Bezug*), bleibt er von *nicht bekannt* unterscheidbar.

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

## 2. Definition of Done

- [ ] **1 — Spezifikation:** `SPEC-024` steht auf `Pflicht`; eine Festlegungs-Zeile in §5 nennt die
      Draht-Form der Kennzeichnung *nicht bekannt* und wie die Quelle genannt wird, mit
      Bindungs-Spalte nach [`MR-075`](../../../../harness/conventions.md#mr-075); `SPEC-055` führt
      den Cache-Status nicht mehr als Abweichung; je Feld `SPEC-010`/`011`/`012` steht, ob `""`
      *nicht bekannt* heißt oder einen Wert trägt, und `SPEC-044` ist nachgezogen.
- [ ] **2 — Erfassung, Feldliste und Tests:** Ein Span aus einer Payload ohne `usage` trägt beim
      Cache-Status die Kennzeichnung, einer mit `usage` die Zähler; ein Span ohne erkennbare Rolle
      trägt sie bei `agent_role`, einer mit *kein Slice* bleibt davon unterscheidbar; die Feldliste
      (`span.FieldList`, emittiert verbatim) nennt beides. **Rot gesehen**
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6): die Erfassung lässt das Feld weg, schreibt `0`
      oder `""` — der benannte Test wird mit einer Meldung über genau dieses Feld rot; ein Fall in
      `test/mutations/` hält die Zusage ([`make mutate`](../../../../harness/sensors/mutate.md) mit
      `MUTATE_CASES`).
- [ ] **3 — Auswertung:** `make span-report` liest die Kennzeichnung bei `agent_role` wie `""` —
      der Lauf geht in den Sammelposten, keine Rolle *nicht bekannt* entsteht; Spans vor und nach der
      Umstellung landen im selben Posten. **Rot gesehen:** die Auswertung prüft nur `""` — der Test
      mit einem Span, der die Kennzeichnung trägt, wird rot.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Übergabe an den Architect: [`MR-076`](../../../../harness/conventions.md#mr-076) ist nach dem
      Umstellungs-Commit aufgehoben (Kopf und Zeiger,
      [`MR-020`](../../../../harness/conventions.md#mr-020)), eigener Architect-Commit — Bedingung
      der Closure.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — kein Brownfield-Bootstrap.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben, oder „keine Beobachtung" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen prüft die nächste Welle-Closure (das Repo fährt Wellen).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `spec/spezifikation.md` §5 | update | Liefer-Punkt 1 |
| `internal/span/response.go`, `internal/span/emit.go` (Rollen-Ableitung), `internal/span/fieldlist.go` | update | Kennzeichnung schreiben, Feldliste (Liefer-Punkt 2) |
| `internal/span/*_test.go` | update | Happy/Negative nach [`LH-FA-13`](../../../../spec/lastenheft.md#lh-fa-13--erfassungs-schema-der-spans), [`LH-FA-15`](../../../../spec/lastenheft.md#lh-fa-15--rolle-der-erfassung) |
| `internal/report/report.go` + Test | update | Liefer-Punkt 3 |
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

## 5. Closure-Trigger

1. `make gates` grün mit den Tests aus Liefer-Punkt 2 und 3; der Mutations-Fall läuft unter
   `make mutate` mit `MUTATE_CASES` und färbt seinen Wächter.
2. [`MR-076`](../../../../harness/conventions.md#mr-076) liegt unter `harness/conventions/done/`,
   und `grep -c "SPEC-024.*| Pflicht |" spec/spezifikation.md` → **1**.

**Lerneintrag** in einer der drei Formen, §7; die Closure schreibt der Planner
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 6. Risiken und offene Punkte

- **Bedeutung eines Span-Felds wechselt ohne Fassungs-Angabe** — `SPEC-024` und `agent_role` ändern
  ihre Draht-Form; Spans vor und nach der Umstellung stehen nebeneinander.
  `span-feld-bedeutung-wechselt-ohne-fassungs-angabe` steht bei
  2 Belegen; ein dritter ist eine Lücke mit
  eigenem Folge-Slice. — **Ausgang:** offen bis zur Closure.
- **Die Kennzeichnung wird als Wert gelesen** — ein Leser, der summiert, zählte sie beim
  Cache-Status als `0`; beim Cache-Status liest heute keiner, bei `agent_role` trägt Liefer-Punkt 3
  den einen Leser (§1). — **Ausgang:** offen bis zur Closure.
- **Feldliste und Träger eines Ziels auf verschiedenem Stand** — schreibt ein Werkzeug-Stand die
  Feldliste, dessen gepinnter Träger älter ist, sagt sie *Pflicht*, während der Träger das Feld
  noch weglässt; ob der Pin das zulässt, prüft der Implementer an `make traeger-fetch`. — **Ausgang:** offen bis zur Closure.

## 7. Closure-Notiz

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —

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

