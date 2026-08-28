# ADR-Index — ai-harness-init

Architecture Decision Records im MADR-/Nygard-Stil. **Derivativ:** was eine
Entscheidung sagt, sagt ihre Datei; dieser Index zeigt auf sie.

| ADR | Titel | Status | Bezug |
|---|---|---|---|
| [ADR-0001](0001-skelett-distribution.md) | Distribution der Sprachskelette | Superseded by [ADR-0005](0005-ziel-repo-distribution.md) | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0002](0002-test-tooling-grenze.md) | Test-Tooling-Grenze (bats) gegenüber [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) | Superseded by [ADR-0003](0003-go-native-binaries.md) | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0003](0003-go-native-binaries.md) | Implementierungssprache Go + native-Binary-Distribution | Accepted | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0004](0004-durchsetzungs-emission.md) | Durchsetzungsschicht-Emission + Guard in bash/awk | Accepted (§Entscheidung 1 — Picker-Herkunft — revidiert durch [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md); Guard-Bauart §2/§3 gilt fort) | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [ADR-0005](0005-ziel-repo-distribution.md) | Ziel-Repo-Distributionsmodell — Fetch (Kurs-SSoT) + deterministische Generierung | Accepted | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |
| [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md) | Durchsetzungsschicht + Workflow-Commands — Tool-als-Quelle statt Picker | Accepted | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| [ADR-0007](0007-bootstrap-phasen.md) | Bootstrap-Phasen — Sprache via ADR, idempotente Fragment-Emission | Accepted | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0008](0008-arch-achse-emittiertes-skelett.md) | Architektur-Achse (`--arch`) für das emittierte Skelett | Accepted (konkrete Layout-Realisierung verfeinert durch [ADR-0009](0009-hexslice-arch-realisierung.md); Mechanik gilt fort) | [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0009](0009-hexslice-arch-realisierung.md) | HexSlice als konkrete Realisierung der Architektur-Achse | Accepted | [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0010](0010-hexagonal-arch-realisierung.md) | Hexagonal als zweite Layout-Realisierung der Architektur-Achse | Accepted | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0011](0011-telemetrie-erfassung-policy.md) | Telemetrie-Erfassung — Policy für Agenten-Spans | Accepted (§Konsequenzen Folgepflichten 1 und 2 — die **Zielorte** von Span-Schema und Abweichungs-Begründung — revidiert durch [ADR-0013](0013-technik-stratum-als-zielort.md); das Kommentar-Verbot aus Folgepflicht 2, alle sechs Festlegungen, die Fitness Function und die Folgepflichten 3–5 gelten fort) | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0004](0004-durchsetzungs-emission.md) |
| [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) | Der Haupt-Kontext bleibt ohne Token-Bilanz — die Abweichung ist permanent, nicht temporär | Accepted | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0011](0011-telemetrie-erfassung-policy.md) |
| [ADR-0013](0013-technik-stratum-als-zielort.md) | Fortschreibbare technische Festlegungen leben im Technik-Stratum, nicht im Adaptions-Block | Accepted | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [ADR-0011](0011-telemetrie-erfassung-policy.md) |
| [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) | Ein aufgehobener Eintrag des Adaptions-Blocks behält seinen Kopf, nicht seinen Rumpf | Accepted | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [ADR-0013](0013-technik-stratum-als-zielort.md) |
| [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) | `AGENTS.md` §3 und der Adaptions-Block gehören dem Architect | Accepted | [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler), [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) |
| [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) | Ein Verweis auf das Regelwerk trägt Tag und Zitat, nicht den Pfad in den Arbeits-Cache | Accepted | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) |
| [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) | Der Doku-Gate lässt ein eingefrorenes ADR aus — namentlich, nicht als Klasse | Accepted | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) |
| [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) | Welche Regelwerks-Fassung die Re-Baseline-Migration regiert | Accepted | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) |
| [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) | Der Agent-Guard prüft die Aufrufform, nicht die Betriebsart | Accepted | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), [ADR-0004](0004-durchsetzungs-emission.md) |
| [ADR-0020](0020-emittierte-modul-15-regeln.md) | Vom Observability-Modul geht nur die Doku-Konsistenz-Regel ins Ziel — als Konfiguration eines bereits mitgelieferten, advisory Trägers; die drei übrigen Blöcke bleiben permanent draußen | Accepted (§Entscheidung Festlegungen 1 und 2 sowie das **Erfassungs-Glied** von Festlegung 3 — **revidiert** durch [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (*Accepted*, 2026-08-23). Festlegungen 4, 5 und 6, das **Zähler-Glied** von Festlegung 3 und die Folgepflichten 1–5 gelten fort — Festlegung 6 trägt seither die **unbedingte** statt der Nicht-Emission; mit den Festlegungen 1–3 gefallen sind Folgepflicht 6 und die zweite Zeile ihrer Fitness Function) | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0007](0007-bootstrap-phasen.md), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) |
| [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | Die Verbrauchs-Achse je Rolle bleibt ohne Quelle — der Ausfall ist permanent, nicht temporär | Accepted | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md), [ADR-0020](0020-emittierte-modul-15-regeln.md) |
| [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) | Die Erfassungsschicht geht ins Ziel — der Träger ist das laufende Produkt-Binär, Schreiber und Auswertung sind seine Unterkommandos | Accepted | [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), [ADR-0003](0003-go-native-binaries.md), [ADR-0007](0007-bootstrap-phasen.md), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0020](0020-emittierte-modul-15-regeln.md), [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) |
| [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) | Der Verweis-Beschluss trägt über den Sprung, und Zeichenketten-Frische ist nicht sein Wächter | Accepted | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) |

## Konventionen

- **Die Spalte `Titel` ist die `# `-Überschrift der verlinkten Datei**, ohne
  ihr `ADR-NNNN: `-Präfix und im Wortlaut unverändert. Sie trägt keine
  Zusammenfassung, keine Messung und keinen Beleg — was eine Entscheidung
  begründet, steht in ihr. Nachbauen:

  ```sh
  for f in docs/plan/adr/[0-9][0-9][0-9][0-9]-*.md; do
    sed -n '1s/^# ADR-[0-9]\{4\}: //p' "$f"
  done
  ```

  Steht in der Überschrift eine Kennung, wird sie in der Zelle verlinkt — die
  Link-Pflicht des `ids`-Moduls gilt auch hier; am Wortlaut ändert das nichts.
- **Die Spalte `Status` trägt einen Satz nur für die eine Aussage, die nirgends
  sonst stehen kann:** dass eine spätere ADR diese hier ganz oder in Teilen
  abgelöst hat. Eine `Accepted`-ADR kann das nicht nachtragen
  ([`AGENTS.md`](../../../AGENTS.md) §3.4) — der Vorwärts-Zeiger von der
  abgelösten zur ablösenden Entscheidung existiert nur hier. Genannt werden der
  **Umfang** der Revision und die revidierende ADR; begründet wird sie dort.
- **Die Spalte `Bezug` ist voll verlinkt und darum lang.** Jede Kennung ist
  linkpflichtig (`ids`, `link-policy: always` in `.d-check.yml`); diese Länge
  ist eine Gate-Folge, keine Formfrage.
- **Was in einer ADR nicht mehr geändert werden darf, wird hier nicht
  nachgebessert.** Eine Korrektur an einer `Accepted`-ADR ist eine Folge-ADR mit
  `Supersedes` ([`AGENTS.md`](../../../AGENTS.md) §3.4). Dieser Index ist die
  einzige Datei des Verzeichnisses, die §3.4 nicht einfriert; ohne diese Zeile
  sammelt sich in ihm, was die Regel in der Quelle verbietet.
- **Kein Gate hält diese Form.** Die in `.d-check.yml` aktivierten Module prüfen
  Verweise und Kennungen; keines vergleicht eine Tabellenzelle mit der
  Überschrift der Datei, auf die sie zeigt. Die Eigenschaft, die ein Wächter
  messen müsste, ist diese Gleichheit — nicht die Zellenlänge, die nur ihr
  Symptom ist.
