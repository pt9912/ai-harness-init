# ADR-0092: Der Plan einer aufgelösten Welle zieht per Move nach `done/` — die Adresse folgt im Zeitdokument, ein Referenz-Ventil entfällt

**Status:** Proposed

**Datum:** 2026-10-10

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 4: die Entscheidung
vor dem Move; Festlegung 2: die Aufnahme-Grenze der `ignore-refs`-Paare),
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Festlegung 1 und 2: im Zeitdokument
ersetzt der Nachzug die Adresse, in der `Accepted`-ADR nichts),
[ADR-0070](0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) (unter
`docs/reviews/` nur die Link-Form),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

**Abgrenzung — diese ADR supersedet keine.** Sie wendet
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) auf einen Fall an, den deren
Träger (`make slice-mv`, `make archive-welle`) nicht fahren, und schließt die Lücke *„wohin gehört
die Datei einer aufgelösten Welle"*, die kein Regelwerk-Satz beantwortet.

---

## Kontext

Eine aufgelöste Welle — ihr Gegenstand ging in einen anderen Slice auf, sie führt keinen Slice mehr —
hat keinen Closure-Trigger, der mehr beobachtet als die DoDs, und damit keine Ergebnis-Notiz. Offen
ist, wie ihr flacher Plan nach `done/` kommt, ohne dass der `git mv` Adressen tot macht
([`AGENTS.md`](../../../AGENTS.md) §3.11). Gemessen an einer Wegwerf-Kopie des Repos (`git clone`
in den Scratchpad, dort `git mv`, `make docs-check`; das Repo selbst blieb unberührt):

```sh
git grep -c 'welle-11-traeger-aussage' -- 'docs/plan/adr/*.md' 'docs/plan/planning/done' 'docs/reviews' | awk -F: '{s+=$NF} END{print s+0}'   # 40 Zeilen
git grep -ohE '\]\([^)]*welle-11-traeger-aussage[^)]*\)' -- 'docs/plan/adr/*.md' 'docs/plan/planning/done' 'docs/reviews' | wc -l           # 27 Links
git grep -lE  '\]\([^)]*welle-11-traeger-aussage[^)]*\)' -- 'docs/plan/adr/*.md' | wc -l                                                    #  0 in einer ADR
```

| Zustand der Kopie | `make docs-check` |
|---|---|
| nackter `git mv` | `2692 Datei(en) geprüft, 74 Befund(e)` — 43 in der bewegten Datei selbst, 4 in der Roadmap (3 `target-missing`, 1 `wave-drift`), **27** in 14 Zeitdokumenten (12 unter `done/`, 2 unter `docs/reviews/`), **0** in einer ADR |
| plus Pfad-Nachzug in den 14 Zeitdokumenten, Ruheort-Korrektur der Datei, Roadmap nachgezogen | `2692 Datei(en) geprüft, 0 Befund(e)`; `git status --short \| grep -c 'docs/plan/adr'` → 0 |
| flacher Stub am alten Ort, Roadmap-Zeile entfernt | `2693 Datei(en) geprüft, 1 Befund(e)` — `wave-drift`: das flache Dokument sei nicht gelistet |

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2). Die ADR-Hälfte der Klasse ist hier leer: die einzige
Nennung in einer `Accepted`-ADR ist der Code-Span eines Mess-Kommandos, und `codepaths` meldet ihn
nicht (die 74 Befunde nennen keine ADR). Die Zeitdokument-Hälfte, die [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
noch als gesperrt las, ist seit [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 1 entschieden: `done/` und `docs/reviews/` bekommen den Nachzug.

## Entscheidung

**Wir wählen D: reiner Move, danach Pfad-Nachzug im Zeitdokument — kein neues `ignore-refs`-Paar.**
Vier Festlegungen.

**1. Der Plan einer aufgelösten Welle wandert per reinem `git mv` von flach nach `done/`.** Der
Zustand ist die Verzeichnis-Position; `done/` heißt hier *keine Arbeit mehr*, nicht *geliefert* —
dieselbe Lesart wie bei der Stilllegung eines Slice (Baseline-Regelwerk `modul-05-planning-harness.md`
§Ein Slice, dessen Gegenstand ein anderer übernimmt). Es entsteht **keine** Ergebnis-Notiz, und
`make archive-welle` läuft nicht (seine Vorprüfung sperrt mit `ergebnisnotiz`); die Auflösung steht
als Umplanung im Drift-Log der Roadmap, nicht im Closure-Log.

**2. Der Nachzug ist ein eigener zweiter Commit** ([`AGENTS.md`](../../../AGENTS.md) §3.3) und
ersetzt die Pfad-Adresse in den Zeitdokumenten unter `docs/plan/planning/done/` und, in Link-Form,
unter `docs/reviews/` ([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1,
[ADR-0070](0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)). Eine
`Accepted`-ADR bekommt kein Byte (Festlegung 2 dort). Lebende Artefakte — die Roadmap, die
relativen Links der bewegten Datei selbst (Ruheort-Regel) — zieht der Planner im selben Commit nach.
Ein Werkzeug dafür gibt es nicht: `make slice-mv` lässt ein präfixloses `welle-`-Ziel unberührt
(`grep -n 'welle-' harness/tools/slice-mv.sh`), und `make archive-welle` bedient nur eine
geschlossene Welle mit Ergebnis-Notiz. Der Nachzug ist Handarbeit mit benannten Pfaden; sein Maß ist
`make docs-check` auf 0 Befunde.

**3. Kein `ignore-refs`-Paar.** Die 27 Links sind reparierbar; ein Paar nähme sie aus der Prüfung,
statt sie zu heilen, und wäre eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 ohne Gegenstand.

**4. Akzeptiertes Negativ: der Code-Span in der `Accepted`-ADR.** Er nennt einen Pfad, den der Move
tot macht, und bleibt stehen: er ist die Chronik einer Messung, kein Zeiger, das Doku-Gate meldet
ihn nicht, und ihn zu ändern wäre eine Byte-Änderung an einer eingefrorenen ADR. Das ist die Logik
von [ADR-0070](0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md), auf die ADR
angewandt; kein eigener Folgeträger, weil nichts wiederkehrt — die Quelle ist eingefroren und
bekommt keine zweite Nennung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — `ignore-refs`-Paare für den alten Pfad (`in:` die Zeitdokument-Bäume) | Move ohne zweiten Commit | Senkung nach §3.5; schaltet 27 **reparierbare** Links stumm, statt sie zu heilen; [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) hat das baum-weite Ventil für diese Bäume ausdrücklich verworfen; jedes Paar trägt eine `Deckung`-Deklaration und die Ausnahme müsste ihren ganzen Gegenstand nennen (§3.5, Wächter `internal/ausnahmegrund`) |
| B — Plan bleibt flach, die Roadmap nennt ihn „geschlossen" | kein Move, keine Nachzüge | Abweichung von Baseline-Regelwerk `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3 (Fork, ein `MR` schuldet sich); *Offene Wellen* ist derivativ und listet jede flache Datei — eine aufgelöste Welle bliebe dort dauerhaft „offen" (`wave-drift`, Zeile 2 der Tabelle), der Zustand wäre nicht mehr die Verzeichnis-Position |
| C — Stub am alten Ort | die alten Adressen lösen auf | der Stub ist eine flache Welle-Datei und verlangt den Listeneintrag (Tabelle, Zeile 3), also eine offene Welle; das Stub-Muster ([ADR-0033](0033-wellen-archivierung-als-unterkommando.md)) lässt den Stub am *neuen* Ort und räumt den alten; `make archive-welle` ist ohne Ergebnis-Notiz gesperrt, der Stub müsste von Hand entstehen und wäre ein Duplikat der Datei, die nach `done/` geht |
| E — nackter Move, Rot stehen lassen | nichts zu tun | 74 Befunde, davon 27 in Dokumenten, die reparieren zu dürfen [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) entschieden hat; ein Dauer-Rot ist kein Sensor ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| **D — Move, dann Nachzug im Zeitdokument** | kein neues Ventil, kein Fork; 0 Befunde gemessen; nutzt entschiedene Regeln | Handarbeit an 14 Zeitdokumenten; die Reihenfolge Move → Nachzug hält kein Sensor |

## Konsequenzen

- Positiv: der Prüfbereich schrumpft nicht; die Lücke aus dem Welle-Plan („wohin gehört die Datei
  einer aufgelösten Welle") hat eine Antwort.
- Negativ: der Nachzug ist Handarbeit; die Welle-Plan-Moves haben keinen Träger.
- Offen, hier nicht entschieden: der flache Plan einer anderen offenen Welle wird von einer
  `Accepted`-ADR als Markdown-Link adressiert (`git grep -n 'planning/welle-09-modul-15-konformitaet' -- docs/plan/adr`
  → zwei Zeilen: der Link in ADR-0011 und das Zitat der Sonde in ADR-0030). Schließt diese Welle, trifft Festlegung 2 dort auf [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
  Festlegung 2 und die Ventil-Frage stellt sich neu — mit eigener ADR nach [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
  Festlegung 4, vor dem Move.

**Entscheidungen des Auftraggebers.** (1) Annahme dieser ADR — Empfehlung: annehmen. (2) Ob die
Welle-Plan-Moves einen Träger bekommen — Empfehlung: nein; zwei Fälle in diesem Repo tragen kein
Werkzeug, und das Maß (`make docs-check` auf 0) sagt es bei jedem Lauf.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links`, `anchors`, `wave-drift` | nach Move und Nachzug 0 Befunde; der nackte Move ist rot (74, oben gemessen) | `make docs-check` |

**Lücke:** die Reihenfolge *Entscheidung vor Move* ([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
Festlegung 4) und die Commit-Trennung hält kein Sensor; Träger ist der Lauf, der den Move plant.

## Re-Evaluierungs-Trigger

Ein Werkzeug nimmt Welle-Plan-Moves an (`make slice-mv` oder `make archive-welle` bedienen ein
`welle-`-Ziel) · die Baseline schreibt für eine aufgelöste Welle eine Form vor · ein dritter
Welle-Plan-Move findet Nennungen in einer `Accepted`-ADR, die das Doku-Gate meldet.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-10 | Proposed | Architect-Lauf |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-NNNN` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
