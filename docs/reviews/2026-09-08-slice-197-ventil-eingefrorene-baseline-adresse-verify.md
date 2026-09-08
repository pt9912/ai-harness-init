# Verifikations-Bericht — slice-197: Ventil für eingefrorene Baseline-Adressen, Wächter auf deklarierte Zahl

**Rolle:** Verifier · **Datum:** 2026-09-08

**Gegenstand:** [slice-197](../plan/planning/in-progress/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md)
(`in-progress/`), geprüft gegen seine DoD (§2) und
[ADR-0039](../plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (`Accepted`).
Vorlauf: [Review-Report vom 2026-09-08](2026-09-08-slice-197-ventil-eingefrorene-baseline-adresse-review.md)
(1 HIGH / 3 MEDIUM / 4 LOW / 2 INFO), Behebung in `d76cb1bd`. Dies ist der erste Kontext, der
gegen die DoD prüft — kein Self-Review.

**Geprüfter Stand:** `HEAD = d76cb1bd`, Arbeitsbaum sauber (`git status --porcelain` leer). Alle
Messungen dieses Berichts laufen zusätzlich zu, nicht anstelle der bereits im Review dokumentierten
Sonden — jede Zahl unten ist selbst erhoben, nicht aus dem Review übernommen.

---

## 1. Repo-weite Gates — selbst gemessen

- `make docs-check` → `d-check: 949 Datei(en) geprüft, 0 Befund(e)`.
- `make gates` → Exit `0`. Beide Zähne aus `test/ignore-refs-restbreite.bats` laufen darin `ok`
  (`ok 126 …vollstaendig und in bekannter Form gelesen`, `ok 127 …deckt genau die … deklarierte
  Anzahl`).

## 2. DoD Punkt für Punkt

| # | Zusage | Befund | Kommando |
|---|---|---|---|
| 1 | Drei `ignore-refs`-Einträge in Glob-Form, `in:` = `docs/reviews/**` / `docs/plan/planning/done/**` / `docs/plan/planning/observations/**`, alle mit `refs: [".harness/baseline/**"]` | **erfüllt** | `grep -A1 '^  - in:' .d-check.yml \| grep 'refs:'` — sieben Paare, die drei neuen tragen ausnahmslos denselben `refs`-Wert; kein vierter Baum, kein zweiter `refs`-Wert |
| 2 | Alle sieben Einträge deklarieren `# Deckung: N`, am Lauf-Tag gemessen | **erfüllt, Zahlen reproduziert** | bestehende vier: `1 · 1 · 0 · 1` (eigener Lauf des Festlegung-2-Kommandos, Achse exakter Dateiname); neue drei: `33 · 3 · 2` (eigener Lauf des zweiten Festlegung-2-Kommandos, Achse Präfix unter `.harness/baseline/*`) — beide decken sich mit den Config-Kommentaren |
| 3 | `test/ignore-refs-restbreite.bats` misst gegen die deklarierte Zahl statt gegen die Konstante 1, liest Glob-Form auf beiden Achsen, vier rot gesehene Gegenbeispiele | **erfüllt, alle vier unabhängig nachgefahren** (Details §3) | s. u. |
| 4 | `make gates` grün | **erfüllt** | s. §1 |
| 5 | Review durchgeführt, Report liegt vor | **erfüllt** | [Review-Report](2026-09-08-slice-197-ventil-eingefrorene-baseline-adresse-review.md) vorhanden, Rollenwechsel gewahrt |
| 6 | Doku-Update falls öffentlicher Vertrag berührt | **entfällt** | Slice-Kopf `Berührte Spec-Stellen: —`; Gate-Konfiguration und Wächter-Maßstab sind in `spec/spezifikation.md` nicht festgelegt — nachvollzogen, kein Vertrag berührt |
| 7–11 | Closure-Notiz, Reconciliation-Register, Beobachtungs-Register, Risiko-Ausgänge, drei Paarungen | **noch offen — Planner-Arbeit nach §3.10, nicht Gegenstand dieses Laufs** | Slice liegt in `in-progress/`; die Checkboxen sind unverändert unangehakt |

Punkte 7–11 sind zu diesem Zeitpunkt korrekt unerfüllt: Sie sind Closure-Schritte, die der Planner
in eigenem Kontext nach dieser Verifikation vollzieht (`AGENTS.md` §3.10, Modul 8
Rollen-Sequenz). Ihr Fehlen ist kein Befund gegen den Implementer.

## 3. Fünf Gegenbeispiele — unabhängig nachgefahren

Auf einer `tar`-Kopie des Repos außerhalb des Arbeitsbaums, Zähne einzeln über das gepinnte
`BATS_IMAGE` gefahren, danach je auf die Original-Config zurückgesetzt. Basislauf über der
unveränderten Kopie: beide Zähne `ok`.

| # | Mutation | Ergebnis | gelesene Detailzeile (eigener Lauf) |
|---|---|---|---|
| 1 | `# Deckung: 33`-Zeile am fünften Eintrag entfernt | **rot** | `docs/reviews/** -> .harness/baseline/**: keine Deckung-Deklaration (# Deckung: N fehlt am Eintrag)` |
| 2 | `33` → `34` | **rot** | `docs/reviews/** -> .harness/baseline/**: 33 aufloesende(r) Link(s), deklariert sind 34` |
| 3 | `33` → `32` | **rot** | `docs/reviews/** -> .harness/baseline/**: 33 aufloesende(r) Link(s), deklariert sind 32` |
| 4 | Null-Paar (`docs/plan/adr/0018-…`) `0` → `1` | **rot** | `docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md -> docs/plan/planning/welle-10-re-baseline.md: 0 aufloesende(r) Link(s), deklariert sind 1` |
| — | Kalibrierung: Null-Paar bleibt `0` | **grün** | beide Zähne `ok` |
| 5 | `refs:`-Zeile am fünften Eintrag gelöscht (kein `refs:` folgt) | **rot, erster Zahn** | `UNGELESEN\t- in: "docs/reviews/**" (kein refs: gefolgt)` |

Zusätzlich für Fall 5 die Vorher/Nachher-Gegenprobe: dieselbe Mutation gegen den Wächter-Stand aus
`e3905ccd` (vor der Behebung von MEDIUM-3) läuft **grün** auf beiden Zähnen — der Eintrag fiel
tatsächlich lautlos heraus, wie der Review es beschreibt. Mit dem Stand aus `d76cb1bd` derselbe
Eingriff: Zahn 1 wird rot. Beide Seiten dieses Vergleichs selbst gefahren, nicht übernommen.

Alle fünf Gegenbeispiele bestehen die Nachprüfung. Kein Abweichen von der im Review dokumentierten
Detailzeile.

## 4. Zahlen und Arithmetik — eigener Lauf

```
bestehende vier:  1 · 1 · 0 · 1
neue drei:       33 · 3 · 2
36 (gefallener Tag) + 1 (lebender Baum) + 1 (Inline-Code-Platzhalter) = 38 = 33 + 3 + 2
```

Alle Werte über den beiden Festlegung-2-Kommandos sowie den beiden Zusatz-Kommandos für die
Arithmetik am heutigen Baum reproduziert, nicht aus ADR-0039 oder dem Slice-Plan übernommen.

## 5. ADR-0039-Konformität

- **Festlegung 1** (drei Einträge, Glob-Form, `refs: [".harness/baseline/**"]`): erfüllt, wörtlich
  aus der Tabelle übernommen — bestätigt in §2 Punkt 1.
- **Festlegung 2** (Wächter misst gegen deklarierte Zahl, vier Bedingungen): erfüllt — alle vier
  Bedingungen sind je durch ein eigenes, hier reproduziertes Gegenbeispiel gedeckt (§3), inklusive
  der Deklaration `0` als Deklaration und nicht als fehlende.
- **Festlegung 3** (extensional geschlossen): erfüllt — sieben Einträge insgesamt, kein vierter
  Baum, kein zweiter `refs`-Wert (eigene Zählung `grep -c '^  - in:' .d-check.yml` → 7).

Kein Befund gegen die ADR-Konformität.

## 6. Plan-vs-Code-Diff

Der Plan (§3) sagt zwei berührte Dateien voraus: `.d-check.yml` (Konfiguration) und
`test/ignore-refs-restbreite.bats` (Wächter). Beide Commits des Liefer-Umfangs (`e3905ccd`,
`d76cb1bd`) berühren genau diese zwei Dateien und keine weitere. Der dritte Commit (`5632ee2b`)
ist eine mechanische Lifecycle-Folge (Ruhe-Marker-Entfernung), vom Plan nicht vorgesehen, aber im
Review als INFO-1 bereits eingeordnet (kein Verstoß, da `AGENTS.md` §3.10 dem Wortlaut nach nicht
einschlägig ist). Kein Code-Verhalten, das der Plan nicht ankündigt; keine Plan-Zusage ohne
Entsprechung im Code. Die im Plan §1 ausgeschlossenen vier Punkte (§3.11-Schärfung,
Glob-Verengung, tote Adresse in lebenden Artefakten, Code-Span-Achse) bleiben tatsächlich
unberührt — die Behebungs-Commits fassen keinen davon an.

## 7. Feststellung zu MEDIUM-1

**Frage:** Trägt die Einordnung des Implementers (Verengung der Zusage statt Erweiterung der
Zählung), und bleibt danach eine unter keiner Mutation rot werdende Zusage stehen?

**Nachgemessen:** Das Festlegung-2-Kommando aus ADR-0039, mit dem die Zahlen `33 · 3 · 2`
hergeleitet und im Slice-Plan sowie in der Config festgeschrieben sind, zählt einen Link auf das
bare Präfix-Verzeichnis (`.harness/baseline`, ohne weiteres Segment) **nicht** — die
Shell-Case-Prüfung `.harness/baseline/*` verlangt einen tatsächlichen Trenner nach dem Präfix, und
der aufgelöste Pfad `.harness/baseline` ohne Suffix erfüllt das Muster nicht. Das habe ich am realen
Fall aus `docs/plan/planning/done/slice-120-co-003-wird-vollzogen.md`
(Link `../../../../.harness/baseline`) eigenständig gegen `realpath` und die Case-Klausel geprüft:
das Muster trifft nicht.

**Feststellung:** Die Einordnung trägt. Hätte der Implementer `count_links_one` erweitert, um
bare Verzeichnis-Links mitzuzählen, wäre `docs/plan/planning/done/**` von der im (angenommenen,
nach §3.4 unveränderlichen) ADR-0039 gemessenen und in der DoD festgeschriebenen `3` auf `4`
gestiegen — eine Abweichung von der Herleitung, die Festlegung 2 der ADR bereits vollzogen hat,
und damit tatsächlich eine Architect-Frage, keine Implementer-Reparatur. Die gewählte Lösung
(Kommentar präzisieren statt Zählung erweitern) hält die DoD-Zahlen konsistent mit der ADR und
ist die im Rahmen dieses Slice korrekte Antwort.

**Zur zweiten Frage:** Nach der Korrektur bleibt eine Aussage im Kommentar stehen, die unter
keiner Mutation dieses Repos rot werden kann — dass ein bare Verzeichnis-Link und eine
Code-Span-Referenz von d-check über denselben Glob dennoch stumm geschaltet werden. Das ist aber
keine neu eingeführte, unbelegte Zusage: Für die Code-Span-Achse ist das bereits als benannte,
unbewachte Lücke in ADR-0030 Folgepflicht 2 geführt (dort ebenfalls ohne Sensor); für die
bare-Verzeichnis-Achse hat der Reviewer sie eigens per Sonde gegen den gepinnten d-check
gemessen (MEDIUM-1) und der Kategorie-Summary ordnet sie ausdrücklich der bereits bestehenden
Beobachtung `ausnahmeliste-nur-auf-form-geprueft` zu — dieselbe Route, über die auch das im
Slice-Plan §6 vierte Risiko läuft. Die verbleibende, nicht rot-testbare Aussage ist damit als
**Grenze benannt und über das Beobachtungs-Register geführt**, nicht als stillschweigend
erweiterte Reparatur präsentiert. Sie erfüllt exakt die im Auftrag genannte Bedingung „wenn ja,
gehört das benannt, nicht in eine Reparatur" — es ist benannt, an zwei Stellen (Config-Kommentar,
Review-Kategorie-Summary), und nicht als geschlossen ausgegeben.

## 8. Was offen bleibt

- Die fünf Closure-Schritte (DoD-Punkte 7–11) sind Planner-Arbeit und stehen noch aus — dieser
  Bericht ist ihre Voraussetzung, nicht ihr Ersatz.
- Der im Slice-Plan §6 erste Risiko (WIP-Limit/Reihenfolge mit dem parallel gehaltenen
  Baum-Tausch-Slice) hat sich zwischenzeitlich beobachtbar aufgelöst: Jener Slice liegt inzwischen
  in `done/`, `in-progress/` trägt neben der Roadmap nur noch slice-197. Das ist keine Aussage
  dieses Berichts über den Ausgang selbst — den setzt die Closure.
- Die übrigen vier Risiken aus §6 sowie die fünf im Plan §8 gesichteten Beobachtungen sind
  unverändert `offen`; ihre Ausgänge sind Closure-Entscheidungen und nicht Gegenstand dieser
  Verifikation.
- Dieser Bericht ist selbst eine neue Datei unter `docs/reviews/`. Er trägt **keinen**
  Markdown-Link in den vendored Baum (jede Nennung steht als Inline-Code oder Kennung); die
  Deklaration `33` bleibt nach dem Hinzufügen dieser Datei unverändert gültig — nachgemessen nach
  dem Schreiben, s. u.

## Verdikt

**DoD erfüllt, soweit sie in diesem Lifecycle-Stand erfüllbar ist.** Die drei Liefer-Punkte tragen,
alle fünf Gegenbeispiele (die vier der DoD plus das in der Behebung nachgezogene fünfte) sind
unabhängig rot gesehen, die Zahlen reproduzieren, `make gates` ist grün. ADR-0039 ist in allen drei
Festlegungen eingehalten. Der Plan beschreibt weiterhin, was der Code tut. MEDIUM-1s Auflösung
trägt in der Sache und ist als Grenze benannt statt verschwiegen. Kein Befund, der die
Closure blockiert; die Closure selbst ist Planner-Arbeit und noch nicht vollzogen.

**Gate-Lauf nach dem Schreiben dieses Berichts:** `make docs-check` → `950 Datei(en) geprüft,
0 Befund(e)` (eine Datei mehr als beim Review-Lauf: dieser Bericht). Die Deklaration `33` für
`docs/reviews/**` bleibt unverändert korrekt, weil dieser Bericht keinen Markdown-Link in den
vendored Baum trägt.
