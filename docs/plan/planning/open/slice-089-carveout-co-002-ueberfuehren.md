# Slice slice-089: Der Carveout endet in `done/`, und die Zeiger lesen das Verdikt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (reaktiver Nachzug einer Entscheidung) — gegen
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 geprüft, alle drei Fragen samt Antwort in §3. Er berührt den Plan von
[welle-09](../welle-09-modul-15-konformitaet.md), ist aber **kein Mitglied** — die Begründung steht
dort ebenfalls.

**Bezug:**
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) — die Entscheidung, deren
Folgepflichten dieser Slice vollzieht: Festlegung 5 schickt den Carveout nach `done/`, die
Konsequenzen verteilen fünf Pflichten auf drei Rollen. **Der Slice nennt die ADR; die ADR nennt
ihn nicht.**
[`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) — der Gegenstand: ein Carveout, dessen
Trigger nach der Messung nur noch im fremden Vertrag liegt und der damit *de facto* permanent ist.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) — der
fällige Mutations-Fall ist ein **Zahn**, kein neuer Gate-Name: er läuft in `make mutate`, nicht in
`make gates`, und behauptet nichts Neues.
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Move und Inhalt sind zwei Commits) und §3.7 (der
Kommentar im Hook beschreibt, was da ist).

**Autor:** Planner. **Datum:** 2026-08-22.

---

## 1. Ziel

**Nach diesem Slice gibt es für den Ausfall der Verbrauchs-Achse je Rolle genau einen Ort, und das
ist die ADR — der Carveout liegt in `done/`, und keine Stelle im Repo zeigt mehr auf eine Frage,
die entschieden ist.**

Ein Carveout sagt zu, temporär zu sein; seinen Trigger führt er als erreichbare Bedingung. Nach
der Messung ist der eine erreichbare Weg ausgefallen, und was bleibt, liegt im fremden Vertrag.
Ein Carveout, der so stehen bliebe, wäre die permanente Ausnahme, die behauptet, temporär zu sein
— genau die Doku-Drift, die Carveouts verhindern sollen. Die Entscheidung darüber ist gefallen;
dieser Slice **vollzieht** sie und schreibt sie nicht neu.

**Was er ausdrücklich NICHT tut: entscheiden.** Er ändert keine ADR, er formuliert keine neue
Begründung und er importiert das Verdikt nicht an einen zweiten Ort — *„ein zweiter Ort driftet"*
([`ADR-0012`](../../adr/0012-haupt-kontext-ohne-token-bilanz.md) Folgepflicht 1). Er zieht Zeiger,
verschiebt eine Datei und baut einen Zahn.

## 2. Definition of Done

Jeder Punkt nennt das Kommando, das ihn rot färbt — eine Zusage reicht nur so weit wie ihr Sensor
([slice-086](../in-progress/slice-086-vordergrund-per-updatedinput.md) §7).

- [ ] **(1) Der Carveout liegt in `done/`, mit dem Status aus Festlegung 5, und der Index führt ihn
      dort.** [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) trägt
      `Status: Permanent — übergeführt in ADR-<NNNN>` — die Nummer ist die der ADR aus dem
      Bezugs-Block —, ein aktuelles `Letzte Prüfung`-Datum und eine
      Geschichte-Zeile; [`docs/plan/carveouts/README.md`](../../carveouts/README.md) führt ihn unter
      **§Aufgelöst** statt unter §Aktiv. **Zwei Commits, in dieser Reihenfolge:** erst der Inhalt
      (Status, Datum, Geschichte, Index), dann der **reine** `git mv`
      ([`AGENTS.md`](../../../../AGENTS.md) §3.3) — das Zielverzeichnis
      `docs/plan/carveouts/done/` <!-- d-check:ignore (entsteht erst mit dieser Überführung) -->
      entsteht dabei zum ersten Mal.

      **Rot färbt ihn:** `ls docs/plan/carveouts/` zeigt `CO-002…` nicht mehr flach;
      `git show --raw -M <move-commit>` weist `R100` aus (Blob unverändert — sonst hat der Move
      Inhalt mitgenommen); `make docs-check` nach dem Move (alle Inbound-Links wandern mit, s. §5).
- [ ] **(2) Die sechs Zeiger auf den Carveout sind gezogen — und keiner von ihnen ist ein Link auf
      die ADR.** Fünf stehen in [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5
      (fünfter Punkt der Erfassungs-Liste, START-KONVENTION, Wächter-Absatz zu deren Bedingung 2,
      Abweichung 1, Abweichung 5), der sechste im Kopf von
      [`.claude/hooks/pretooluse-agent-guard.sh`](../../../../.claude/hooks/pretooluse-agent-guard.sh).
      Mit den Zeigern gehen die Sätze, die eine Messung als **ausstehend** führen: was bleibt, ist
      der Zustand im Indikativ.

      **Die Schranke steht im Weg und ist vorher zu lesen (§3, *Warum die Spec nicht auf die ADR
      zeigt*):** das Spec-Stratum darf nicht abwärts auf ADRs verweisen, und ein bares
      Kennungs-Token bricht die Link-Pflicht. Der Hook-Kommentar darf den ADR-Pfad nennen — er ist
      kein Spec-Stratum, und [`AGENTS.md`](../../../../AGENTS.md) §3.7 verlangt dort ohnehin, dass
      der Kommentar beschreibt, was da ist.

      **Rot färbt ihn:**
      `grep -n 'CO-002' spec/spezifikation.md .claude/hooks/pretooluse-agent-guard.sh` → **leer**,
      und `make docs-check` grün (die Matrix-Regel ist Teil davon).
- [ ] **(3) Der fällige Mutations-Fall existiert und färbt seinen Test rot.** Beschrieben als
      **Eigenschaft, nicht als Adresse**: ein Fall unter `test/mutations/`, der die Erfassung der
      Ergebnis-Werte für `Agent` **entfernt** und dabei `TestOnlyAgentToolGetsResponseValues` in
      [`internal/span/response_test.go`](../../../../internal/span/response_test.go) rot färbt. Der
      vorhandene Fall `test/mutations/133-span-werkzeugachse-geweitet.sh` trifft denselben Test aus
      der **anderen** Richtung (er weitet die Werkzeug-Achse) und deckt diese nicht.

      **Rot färbt ihn:** `make mutate` — ein Fall, dessen Mutation grün durchläuft, wird dort als
      Befund gemeldet. Ohne diesen Fall ist Festlegung 2 der ADR eine Absicht
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] `make gates` grün, `make mutate` ohne Befund.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

### Warum die Spec nicht auf die ADR zeigt — die Schranke, die diesen Nachzug formt

Die naheliegende Ausführung wäre, die fünf Spec-Stellen auf die ADR zu **verlinken**. Sie ist
versperrt, und zwar mechanisch:

- Das Doc-Gate führt eine **Referenz-Richtung** (SDP): `spec-straten` → `adr` ist **nicht erlaubt**
  ([`.d-check.yml`](../../../../.d-check.yml), `matrix.rules`). Ein Link von
  [`spec/spezifikation.md`](../../../../spec/spezifikation.md) auf die ADR färbt `make docs-check`
  rot.
- Die Kennungs-Regel ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids))
  verlangt für jedes `ADR-`-Token einen Link — **auch in Inline-Code**. Die Kennung dort bar zu
  nennen, ist also ebenfalls rot.
- **Gemessen, nicht angenommen:** `grep -n 'ADR-0' spec/spezifikation.md` liefert genau **einen**
  Treffer, und der steht in §7 Historie — dem einzigen Abschnitt, den `matrix.exclude-sections`
  ausnimmt. Die Spec hält die Richtung heute ein.

**Folge für DoD (2):** die fünf Stellen verlieren ihren Zeiger und behalten die **Aussage** — der
Ausfall im Indikativ, ohne Verweis auf das Artefakt, das ihn entschieden hat. Wer das Verdikt
sucht, findet es über den ADR-Index, nicht über einen Abwärts-Link. Das ist keine Verlegenheit,
sondern dieselbe Regel, aus der die Richtung stammt: das Vertrags-Stratum sagt, **was gilt**, nicht
**warum entschieden wurde**.

### Welle oder nicht — der Test aus [`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1

1. **Bündel?** Nein. Die fünf Folgepflichten sind **eine** Bewegung an einem Gegenstand: der
   Carveout wandert, seine Zeiger wandern mit, sein Audit-Eintrag entfällt, sein Zahn entsteht.
   Kein zweiter Slice muss mitlanden, damit die Aussage stimmt — im Gegenteil: getrennt gelandet,
   hinterließe jeder Teil einen Zwischenzustand, in dem eine Stelle auf ein abgeschlossenes
   Artefakt zeigt.
2. **Gemeinsames Closure-Kriterium?** Nein. Das Kriterium wäre *„kein Zeiger mehr auf den
   Carveout"* — und das ist DoD (2), nicht mehr.
3. **Auslöser reaktiv oder gewollt?** **Reaktiv.** Eine Entscheidung ist gefallen und das Repo
   hinkt ihr nach; wiederhergestellt wird Konsistenz, nicht eine neue Fähigkeit. Der fällige
   Mutations-Fall sieht wie ein Zuwachs aus, ist aber der Zahn zu einer **bestehenden** Zusage.

Dreimal *ohne Welle*. **Folge nach Setzung 2 und 3:** kein Roadmap-Eintrag, weder jetzt noch beim
Abschluss.

**Warum er trotzdem [welle-09](../welle-09-modul-15-konformitaet.md) berührt, ohne ihr Mitglied zu
sein.** Deren Slice-Liste führt ihn nicht, und ihr Closure-Kriterium wird durch ihn nicht wahr. Was
er dort ändert, ist der **Wert zweier Matrix-Zellen**, den der Welle-Plan ausdrücklich vom Zustand
des Carveouts abhängig macht: *Token-Attribution × Repo* (Hintergrund-Teil) und
*Cache-Counter × Repo* tragen danach **ADR-Verdikt** statt *deklariert* — ein Wert, den das
Vokabular jener Welle selbst führt. Dieselbe Bewegung nimmt dem Carveout-Audit ihres
Closure-Kriteriums einen von zwei Gegenständen: ein Audit, das weiter zwei aktive Carveouts prüft,
prüft eine Datei in `done/`. **Die Tool-Spalte ist nicht berührt** — sie ist entschieden, und der
Maßstab des Carveouts ist dort ausdrücklich nicht importiert.

### Berührte Dateien

| Datei / Komponente | Änderungs-Art | Wer schreibt | Begründung |
|---|---|---|---|
| [`CO-002`](../../carveouts/CO-002-token-achse-je-rolle.md) | update, **dann** `git mv` nach `done/` | Implementer | Status, `Letzte Prüfung`, Geschichte-Zeile; zwei Commits ([`AGENTS.md`](../../../../AGENTS.md) §3.3) |
| [`docs/plan/carveouts/README.md`](../../carveouts/README.md) | update | Implementer | §Aktiv verliert die Zeile, §Aufgelöst bekommt sie — der Index ist die Übersicht, nicht eine zweite Quelle |
| [`spec/spezifikation.md`](../../../../spec/spezifikation.md) | update (fünf Stellen in §5) | Spec-Eigentümer + Implementer | Zeiger raus, Aussage im Indikativ rein; keine ADR-Verlinkung (s. o.) |
| [`.claude/hooks/pretooluse-agent-guard.sh`](../../../../.claude/hooks/pretooluse-agent-guard.sh) | update (Kopf-Kommentar) | Implementer | ein Kommentar beschreibt, was da ist ([`AGENTS.md`](../../../../AGENTS.md) §3.7); hier darf der ADR-Pfad stehen |
| `test/mutations/` (ein neuer Fall) | neu | Implementer | der Zahn zu Festlegung 2; Eigenschaft in DoD (3), Nummer beim Anlegen die nächste freie |
| [welle-09](../welle-09-modul-15-konformitaet.md) | update (zwei Zell-Werte, Audit-Zeile) | **Planner** | der Wert *ADR-Verdikt* und der Audit-Gegenstand, der entfällt — Plan-Artefakt, eigene Rolle |
| [`docs/plan/adr/`](../../adr/) | **unverändert** | — | eine ADR ist ab *Accepted* immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4); dieser Slice vollzieht, er entscheidet nicht |

## 4. Trigger

**`open` → `next`:** [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) ist
**Accepted**. Heute steht sie *Proposed* — und solange sie das tut, vollzöge dieser Slice eine
Entscheidung, die noch zur Debatte steht. Die Vorbedingung ist damit nicht ein Datum, sondern ein
Ereignis mit Beleg: **Review-Runden nach Modul 10 mit ausgestelltem Verdikt**, bis die
blockierende Menge leer ist; danach setzt der Architect den Status. **Prüfkommando:**
`grep -n '^\*\*Status:' docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md` und dieselbe
Angabe in [`docs/plan/adr/README.md`](../../adr/README.md) — beide müssen *Accepted* zeigen.
Dieser Slice ändert an der ADR nichts, auch nicht ihren Status.

**`next` → `in-progress`: WIP-Limit frei** — `ls docs/plan/planning/in-progress/` zeigt außer der
Roadmap keinen Slice.

Rückführungen:

- `in-progress` → `open`: die fünf Spec-Stellen lassen sich **nicht** ohne Verweis auf das Verdikt
  formulieren, weil eine von ihnen die Begründung mitträgt statt nur den Zustand. Dann ist zuerst
  zu entscheiden, was das Vertrags-Stratum an dieser Stelle überhaupt sagen soll — eine Frage an
  den Spec-Eigentümer, kein Nachzug.
- `in-progress` → `next`: der fällige Mutations-Fall erweist sich als eigener Gegenstand (die
  Mutation trifft mehr als die Erfassung der Ergebnis-Werte, oder der Test hält sie nicht). Dann
  trennt ein Re-Schnitt den **Nachzug der Zeiger** vom **Zahn**; beide sind einzeln lieferbar und
  einzeln prüfbar.

## 5. Closure-Trigger

DoD vollständig; Review konform (Modul 10) mit ausgestelltem Verdikt; Verifikation (Modul 11)
bestätigt die DoD; `make gates` und `make mutate` grün; Closure-Notiz mit Steering-Loop-Eintrag.

**Der Link-Zug gehört zu BEIDEN Moves — und dieser Slice bewegt zwei Dateien.** Jeder `git mv` ist
ein eigener, reiner Move-Commit ([`AGENTS.md`](../../../../AGENTS.md) §3.3); **nach jedem** folgt
der Link-Reconciliation-Commit — beim Eintritts-Move dieser Plan-Datei (`open` → `next` →
`in-progress`), beim Move des Carveouts nach `docs/plan/carveouts/done/` <!-- d-check:ignore (entsteht erst mit dieser Überführung) -->
und beim eigenen Abgang nach `done/`. Betroffen sind die eigenen `../`-Links der bewegten Datei
**und** jeder eingehende Verweis. **Prüfkommando statt Erinnerung:** `make docs-check` nach jedem
Move; solange es rot ist, ist der Zug nicht fertig. Beim Carveout ist die eingehende Menge vorab
messbar: `grep -rln 'CO-002' --include='*.md' docs spec harness`.

## 6. Risiken und offene Punkte

- **Der Nachzug erzeugt leicht einen zweiten Ort für das Verdikt.** Wer beim Ziehen der fünf
  Spec-Stellen die Begründung mitschreibt, hat die ADR abgeschrieben — und zwei Fassungen
  driften. Die Probe ist eine Frage an den Satz: sagt er, **was gilt**, oder sagt er, **warum**?
  Das Zweite gehört nicht ins Vertrags-Stratum.
- **Der Move ohne Inhalt und der Inhalt ohne Move sind zwei Commits, und die Reihenfolge ist nicht
  beliebig.** Erst der Inhalt, dann der Move: ein Move-Commit, der den Blob mitändert, fällt unter
  die Similarity-Schwelle, und die Rename-Detection verliert die Spur, die dieser Slice gerade
  lesbar machen soll.
- **Das Carveout-Audit hängt an einem Closure-Kriterium einer fremden Welle.** Nach diesem Slice
  ist dessen Wortlaut (*beide* Carveouts prüfen) nicht mehr erfüllbar, wie er dasteht. Der
  Planner-Anteil zieht ihn mit; wer nur den Carveout bewegt, hinterlässt ein Kriterium, das auf
  eine Datei in `done/` zeigt.
- **`test/mutations/` ist kein Gate.** Der neue Fall läuft in `make mutate`, nicht in
  `make gates`; er behauptet keinen neuen Wächter, sondern prüft die Zähne eines vorhandenen
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
  `make mutate` läuft pro Push in CI
  ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)).
- **Nicht in diesem Slice:** jede Änderung an
  [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) selbst (immutabel ab
  *Accepted*), die Erlaubnis-Frage zum Transkript als Quelle (Auftraggeber) und der Geltungsbereich
  von [`AGENTS.md`](../../../../AGENTS.md) §3.7 für verbatim abgelegten Skript-Text (Architect,
  eigener Lauf).

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example):
[`docs/plan/carveouts/`](../../carveouts/), das Technik-Stratum
([`spec/spezifikation.md`](../../../../spec/spezifikation.md)), `.claude/hooks/` und
`test/mutations/` gehören zum Greenfield-Bestand; der Modus steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md).
