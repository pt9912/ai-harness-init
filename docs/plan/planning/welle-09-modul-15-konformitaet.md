# Welle welle-09: Modul-15-Konformität — Regeln ohne Feedback-Quadrant schließen

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-09-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug (Konformitäts-Welle, keine Nutzer-Fähigkeit).

**Verantwortlich:** ai-harness-init-Team (pt9912). **Datum:** 2026-07-28.

---

## 1. Welle-Ziel

**Jeder der vier Regelblöcke von `modul-15-observability.md` trägt am Ende entweder einen
laufenden Sensor oder eine deklarierte Abweichung mit Auflösungs-Trigger — und nichts
dazwischen.** „Nichts dazwischen" ist der Kern: der heutige Zustand ist weder Umsetzung noch
Abweichung, sondern Schweigen.

Der Anlass ist ein **Nutzer-Befund** (2026-07-28), und er wiegt schwerer als ein einzelnes
fehlendes Modul: [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) erklärt
für das gesamte Repo *„keine inhaltlichen Adaptionen ggü. Baseline-Default"*. Modul 15 stellt
Regeln auf, kein `MR` deklariert eine Abweichung davon, und umgesetzt ist keiner seiner vier
Blöcke. Damit ist die Nicht-Umsetzung heute eine **nicht deklarierte Abweichung** — genau die
Klasse, die Modul 7 „permanenter Carveout, der lügt" nennt.

**Der Einstieg ist die Erfassung, nicht die Auswertung.** Modul 15 beschreibt einen Agentenlauf
als *Trace aus Spans — einen pro Tool-Call*. Diese Spans entstehen bei uns heute **nirgends**:
der `PreToolUse`-Guard sieht jeden Bash-Aufruf samt Argumenten, entscheidet und **vergisst ihn
sofort**. Genau dort setzt die Welle an — die Mechanik ist verdrahtet, es fehlt die Senke.

Die Welle **faltet den Roadmap-Kandidaten *Regeln ohne Feedback-Quadrant schließen* hinein**,
statt eine zweite Wahrheit danebenzustellen: dessen Achse (1) — die Gate-Tabellen in
[`AGENTS.md`](../../../AGENTS.md) §4 und [`harness/README.md`](../../../harness/README.md)
§Sensors werden von nichts gegen das [`Makefile`](../../../Makefile) gehalten — **ist**
Modul-15-Block-4.

## 2. Trigger (Welle startet)

- **Nutzer-Befund 2026-07-28**, mechanisch belegt: Modul 15 liegt seit `554cade`
  (2026-07-17, slice-011) im Repo und taucht seither in **vier** Commits auf — 011, 019, 043,
  049, allesamt Re-Vendor-Läufe, die es mitkopiert haben. Commits, die es inhaltlich behandeln:
  **0**. Commits mit „Observability"/„Telemetrie" im Betreff: **0**.
- **Warum es nie in den Blick kam** (die eigentliche Lücke, und sie ist größer als Modul 15):
  die Adoptions-Mechanik prüft bei jeder Re-Baseline das **Normativ-Delta** — so entstand
  [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler).
  Modul 15 war nie ein Delta; es kam am ersten Tag vollständig mit. **Delta-Prüfung sieht
  Änderungen, nie den Bestand** — kein Sensor meldet „adoptiert, aber nicht umgesetzt".
- slice-058 ist `done/`, `in-progress/` ist leer, `make gates`/`mutate`/`full-smoke` grün
  (green-before-extend).

## 3. Closure-Trigger (Welle schließt)

- Alle Slices dieser Welle in `done/`.
- **Je Regelblock von Modul 15 ein belegter Zustand** — Sensor *oder* deklarierte Abweichung
  (`MR-<NNN>` mit Geltungsbereich, Begründung, Auflösungs-Trigger). Der Nachweis ist eine
  Tabelle in `welle-09-results.md`, Block für Block, mit dem Kommando neben der Aussage.
- `make gates` und `make mutate` grün; jeder neue Wächter hat seinen `test/mutations/`-Fall
  ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- Carveout-Audit (Modul 7): [`CO-001`](../carveouts/CO-001-bats-shell-lint.md) geprüft, neue
  Carveouts dokumentiert oder begründet keine.
- Closure-Notiz in `welle-09-results.md` mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Nur der erste Slice ist geschnitten (cp-Disziplin — die übrigen bekommen ihre Datei per `cp`,
wenn sie an der Reihe sind; ein leeres `open/` ist ehrlicher als eine driftende Vorplanung).

| Slice | Titel | Bezug |
|---|---|---|
| slice-059 | **Erfassung**: Spans per Agenten-Hook (Block 1) | [`MR-002`](../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) |
| slice-060 | **Auswertung**: Token-Bilanz je Rolle + getrennte Cache-Zähler (Blöcke 2–3) | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-061 | **Doku-Konsistenz**: behauptete Befehle existieren (Block 4) | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-062 | **Bestands-Prüfung**: welche Regelwerk-Abschnitte sind adoptiert, aber unumgesetzt? | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |

**Die Reihenfolge ist die Aussage.** Erst die **Erfassung**, dann die Auswertung: ohne Spans hat
die Token-Bilanz keine eigene Datenquelle, sondern nur das Transkript des Werkzeugs — das
außerhalb des Repos liegt, uns nicht gehört und **keine Korrelations-IDs trägt** (`agent.role`
steht dort als `general-purpose`, `slice.id` gar nicht; am 2026-07-28 gemessen). Und der
Erfassungsort existiert bereits: der `PreToolUse`-Guard sieht jeden Bash-Aufruf samt Argumenten
und behält **nichts** davon.

**Zu slice-060:** die Rohdaten sind real vorhanden — die Sitzungs-Transkripte tragen getrennte
Hit-/Miss-Zähler (`cache_read` vs. `cache_creation`, Hit-Rate 96,9 % am 2026-07-28 gemessen),
also genau die Trennung, auf der Modul 15 besteht. Das bequeme Argument „kein Gegenstand" ist
damit ausgeschlossen; offen ist die Zuordnung zur **Rolle**, nicht die Datenlage.

**Zu slice-062:** der Trigger-Befund aus §2 verallgemeinert. Wenn Delta-Prüfung den Bestand nie
sieht, ist Modul 15 vermutlich nicht der einzige Fall — und niemand weiß es, weil es nie
jemand geprüft hat. Erst messen, dann entscheiden, ob daraus ein Sensor wird.

## 5. Abhängigkeiten

- **Blockiert:** nichts. Diese Welle liefert Sensoren und Deklarationen, keine Nutzer-Fähigkeit;
  kein anderer Kandidat wartet auf sie.
- **Wird blockiert von:** nichts. Der Hebel ist bereits bezahlt — das gepinnte d-check-Image
  aktiviert **6 von 18** Modulen, und `targets` liegt als `make doc-targets` in
  [`d-check.mk`](../../../d-check.mk) fertig und unverdrahtet vor.

## 6. Out-of-Scope für diese Welle

- **Ein OTel-*Stack*** — Collector, Backend, Dashboard, Vendor-SDK. **Nicht** die Erfassung:
  die ist der Kern dieser Welle und passiert lokal als JSONL aus bash+awk
  ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): keine neue
  Abhängigkeit). Die Unterscheidung ist die Pointe — *Spans erfassen* und *einen
  Observability-Stack betreiben* sind zwei verschiedene Dinge, und nur das zweite ist hier
  Overhead. Für die Auswahl gilt Modul 15 selbst: *„Ein Attribut ohne Incident-Frage fliegt
  raus."*
- **Die emittierte Ebene — aufgeschoben, nicht erledigt.** Die Hooks **werden** ins Ziel-Repo
  emittiert (`internal/emit/templates/enforce/settings.json`), ein Span-Emitter wäre also
  emittierbar; und die emittierte `.d-check.yml` führt heute nur `[links, anchors]`. Beides zu
  ändern heißt, den **Adopter-Vertrag** zu ändern
  ([`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7)) — mit
  eigenem Beleg-Bedarf (out-of-the-box grün, Lehre aus slice-028) und eigener Entscheidung. Es
  gehört in einen Zuschnitt **nach** dieser Welle, nicht als Nebenprodukt der Dogfood-Wartung
  hinein.
- **Die übrigen Achsen des Roadmap-Kandidaten** (`vcs`/`commits`-Module, Closure-Notiz-Sensor,
  Release-Text-Check, DoD-Punkte-Zähler). Sie bleiben Kandidaten; diese Welle nimmt nur, was
  Modul-15-Konformität wirklich verlangt. Wer mehr hineinzieht, verliert das Closure-Kriterium.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-09-results.md. -->
