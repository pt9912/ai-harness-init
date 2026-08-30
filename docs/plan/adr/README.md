# ADR-Index — ai-harness-init

Architecture Decision Records im MADR-/Nygard-Stil. **Derivativ:** was eine
Entscheidung sagt, sagt ihre Datei; dieser Index zeigt auf sie.

| ADR | Titel | Status | Bezug |
|---|---|---|---|
| [ADR-0001](0001-skelett-distribution.md) | Distribution der Sprachskelette | Superseded by [ADR-0005](0005-ziel-repo-distribution.md) | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0002](0002-test-tooling-grenze.md) | Test-Tooling-Grenze (bats) gegenüber [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) | Superseded by [ADR-0003](0003-go-native-binaries.md) | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0003](0003-go-native-binaries.md) | Implementierungssprache Go + native-Binary-Distribution | Accepted | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0004](0004-durchsetzungs-emission.md) | Durchsetzungsschicht-Emission + Guard in bash/awk | Accepted (§Entscheidung 1 revidiert durch [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md)) | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| [ADR-0005](0005-ziel-repo-distribution.md) | Ziel-Repo-Distributionsmodell — Fetch (Kurs-SSoT) + deterministische Generierung | Accepted | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |
| [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md) | Durchsetzungsschicht + Workflow-Commands — Tool-als-Quelle statt Picker | Accepted | [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) |
| [ADR-0007](0007-bootstrap-phasen.md) | Bootstrap-Phasen — Sprache via ADR, idempotente Fragment-Emission | Accepted | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| [ADR-0008](0008-arch-achse-emittiertes-skelett.md) | Architektur-Achse (`--arch`) für das emittierte Skelett | Accepted | [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0009](0009-hexslice-arch-realisierung.md) | HexSlice als konkrete Realisierung der Architektur-Achse | Accepted | [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0010](0010-hexagonal-arch-realisierung.md) | Hexagonal als zweite Layout-Realisierung der Architektur-Achse | Accepted | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4), [`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| [ADR-0011](0011-telemetrie-erfassung-policy.md) | Telemetrie-Erfassung — Policy für Agenten-Spans | Accepted (§Konsequenzen — die Zielort-Setzungen der Folgepflichten 1 und 2 — revidiert durch [ADR-0013](0013-technik-stratum-als-zielort.md)) | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0004](0004-durchsetzungs-emission.md) |
| [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) | Der Haupt-Kontext bleibt ohne Token-Bilanz — die Abweichung ist permanent, nicht temporär | Accepted | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0011](0011-telemetrie-erfassung-policy.md) |
| [ADR-0013](0013-technik-stratum-als-zielort.md) | Fortschreibbare technische Festlegungen leben im Technik-Stratum, nicht im Adaptions-Block | Accepted | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [ADR-0011](0011-telemetrie-erfassung-policy.md) |
| [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) | Ein aufgehobener Eintrag des Adaptions-Blocks behält seinen Kopf, nicht seinen Rumpf | Accepted | [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen), [ADR-0013](0013-technik-stratum-als-zielort.md) |
| [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) | `AGENTS.md` §3 und der Adaptions-Block gehören dem Architect | Accepted | [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler), [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) |
| [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) | Ein Verweis auf das Regelwerk trägt Tag und Zitat, nicht den Pfad in den Arbeits-Cache | Accepted | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) |
| [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) | Der Doku-Gate lässt ein eingefrorenes ADR aus — namentlich, nicht als Klasse | Accepted | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) |
| [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) | Welche Regelwerks-Fassung die Re-Baseline-Migration regiert | Accepted | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) |
| [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) | Der Agent-Guard prüft die Aufrufform, nicht die Betriebsart | Accepted | [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), [ADR-0004](0004-durchsetzungs-emission.md) |
| [ADR-0020](0020-emittierte-modul-15-regeln.md) | Vom Observability-Modul geht nur die Doku-Konsistenz-Regel ins Ziel — als Konfiguration eines bereits mitgelieferten, advisory Trägers; die drei übrigen Blöcke bleiben permanent draußen | Accepted (§Entscheidung — Festlegungen 1 und 2 sowie das Erfassungs-Glied von Festlegung 3 — revidiert durch [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)) | [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7), [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0007](0007-bootstrap-phasen.md), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) |
| [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | Die Verbrauchs-Achse je Rolle bleibt ohne Quelle — der Ausfall ist permanent, nicht temporär | Accepted | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md), [ADR-0019](0019-agent-guard-prueft-die-aufrufform.md), [ADR-0020](0020-emittierte-modul-15-regeln.md) |
| [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) | Die Erfassungsschicht geht ins Ziel — der Träger ist das laufende Produkt-Binär, Schreiber und Auswertung sind seine Unterkommandos | Accepted | [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten), [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix), [ADR-0003](0003-go-native-binaries.md), [ADR-0007](0007-bootstrap-phasen.md), [ADR-0011](0011-telemetrie-erfassung-policy.md), [ADR-0020](0020-emittierte-modul-15-regeln.md), [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) |
| [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) | Der Verweis-Beschluss trägt über den Sprung, und Zeichenketten-Frische ist nicht sein Wächter | Accepted | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) |
| [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) | Ein derivatives Register gehört der Rolle, die sein Original schreibt | Accepted | [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |
| [ADR-0025](0025-register-mit-gemischten-originalen.md) | Ein Register mit gemischten Originalen hat keinen Eigentümer, aber jede seiner Änderungen eine Rolle | Proposed | [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md), [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md), [ADR-0016](0016-verweis-traegt-tag-und-zitat.md), [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) |

## Konventionen

- ADRs sind nach `Accepted` **immutable** ([`AGENTS.md`](../../../AGENTS.md)
  §3.4); eine Korrektur ist eine Folge-ADR mit `Supersedes`. Auch dieser Index
  bessert nicht nach, was in der Quelle nicht mehr änderbar ist.
- **`Titel` ist die `# `-Überschrift der verlinkten Datei**, ohne ihr
  `ADR-NNNN: `-Präfix und im Wortlaut unverändert — keine Zusammenfassung, keine
  Messung, kein Beleg. Enthält die Überschrift eine Kennung, wird sie in der
  Zelle verlinkt ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids));
  am Wortlaut ändert das nichts.
- **`Status` spiegelt das Kopffeld `Status:` der verlinkten Datei, im Wortlaut** —
  ein Zustand aus dem Vokabular der Vorlage (`Proposed` · `Accepted` ·
  `Deprecated` · `Superseded by ADR-NNNN`), kein Satz. Enthält er eine Kennung,
  wird sie in der Zelle verlinkt ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
- **Einen Zusatz trägt die Zelle nur, wo eine `Accepted`-ADR ihn anordnet** — denn
  ihre eigene spätere Teil-Revision kann sie nicht nachtragen. Angeordnet ist er
  von [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md) für
  [ADR-0004](0004-durchsetzungs-emission.md), von
  [ADR-0013](0013-technik-stratum-als-zielort.md) für
  [ADR-0011](0011-telemetrie-erfassung-policy.md) und von
  [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
  (Folgepflicht 7) für [ADR-0020](0020-emittierte-modul-15-regeln.md); welche ADRs
  anordnen, zeigt
  `git grep -l 'Revidiert (Teil-Supersede)' -- 'docs/plan/adr/0*.md'`. Den Zweck
  nennt die anordnende ADR, bei [ADR-0006](0006-durchsetzung-commands-tool-als-quelle.md)
  als *„so kann kein Slice die revidierte Picker-Stanza als aktiv zitieren"*.
- **Der Zusatz nennt den Umfang der Revision und die revidierende ADR — sonst
  nichts.** Was **fort**gilt, benennt die revidierende ADR selbst; hier stünde es
  ein zweites Mal, und zwei Fassungen derselben Aussage driften auseinander.
- **Eine Verfeinerung ist keine Revision und steht nicht in dieser Spalte.**
  [ADR-0009](0009-hexslice-arch-realisierung.md) hält im Kopffeld
  `Verfeinert (nicht supersedet):` fest, dass die Mechanik von
  [ADR-0008](0008-arch-achse-emittiertes-skelett.md) *„unverändert"* gilt. Dort ist
  nichts abgelöst, also ist auch nichts zu warnen.
- **`Bezug` ist voll verlinkt und darum lang** — Kennungen sind linkpflichtig
  ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
- **Kein Sensor hält die Titel- und die Status-Regel.** Keines der in
  `.d-check.yml` aktivierten Module (`links, anchors, ids, matrix, codepaths,
  spans`) vergleicht eine Zelle mit der `# `-Überschrift oder einem Kopffeld der
  Datei, auf die sie zeigt, und kein `make`-Ziel tut es. Eine Schranke auf die
  Zellenlänge misst etwas anderes: kurz ist nicht gleich. Wer eine Überschrift
  oder ein `Status:`-Kopffeld ändert, zieht die Zelle von Hand nach.
