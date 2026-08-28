# Slice slice-112: Modul 6 Schritt 1 nennt einen Sensor, den dieses Repo nicht hat — die gelebte Fassung bekommt ihren Ort

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — der Gegenstand ist **ein** Schritt **eines**
Moduls und die zwei Dateien, die ihn heute abweichend ausschreiben; der Slice ist einzeln lieferbar
und wartet auf keinen zweiten. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre
die Abschrift seiner eigenen DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: die Closure von
[welle-12](../done/welle-12-erfassungsschicht-emittieren.md) hat den Schritt gelesen und seinen
Sensor nicht gefunden. Kein Fähigkeits-Sprung — das Werkzeug lernt nichts Neues, es geht um die
Regeln, nach denen dieses Repo seine Wellen schließt. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood **und** emittiert — und das ist der Grund, warum der Slice nicht klein ist.** Die
abweichende Fassung des Schritts steht in **zwei** Dateien, und eine davon geht ins Ziel:
`git grep -ln 'Trigger prüfen' -- ':!.harness/baseline'` → **4** Dateien, davon zwei lebende
Anleitungen ([`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) und
[`internal/emit/templates/commands/close-welle.md`](../../../../internal/emit/templates/commands/close-welle.md))
und zwei Zeitdokumente. Was hier entschieden wird, entscheidet damit auch, was jedes gebootstrappte
Repo als Wellen-Closure-Anleitung bekommt
([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Prozess-Schritt, der einen Sensor als Bedingung nennt, den es nicht gibt, sagt einen Mechanismus
zu, der nicht läuft — dieselbe Klasse eine Ebene über dem Gate),
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) (*„keine inhaltlichen
Adaptionen ggü. Baseline-Default"* — die Aussage, die durch die gelebte Fassung berührt ist),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (Adaptions-Block
schreibt der Architect — dieser Slice liefert die Messung und den Termin, nicht den Text),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(die Richtung der Änderung entscheidet über das Werkzeug),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(der vendored Baum, gegen den gemessen wird),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-27.

---

## 1. Ziel

**Der Schritt, mit dem dieses Repo seine Wellen schließt, nennt nur Sensoren, die es hat — und
die Abweichung von der Baseline-Fassung steht dort, wo Abweichungen dieses Repos stehen.**

### Die Ausgangslage: ein genannter Sensor ohne Referenten

Modul 6 §Wellen-Closure-Prozedur setzt in Schritt 1 als beobachtbare Closure-Bedingung: *„Alle
Slices der Welle liegen in `done/`, `make gates` und der Replay-Lauf sind grün."* §Regeln gegen
typische Fehlannahmen wiederholt es (*„Gegen ‚Welle = Sprint'"*). Der Begriff steht dort
`grep -ci replay .harness/baseline/v3.5.2/regelwerk/modul-06-roadmap.md` → **5** mal.

**Diesen Lauf gibt es hier nicht — gemessen über fünf unabhängige Achsen, nicht vermutet:**

| Achse | Kommando | Wert |
|---|---|---|
| ein `make`-Ziel | `grep -cE '^[a-zA-Z0-9_.-]*(replay\|eval)[a-zA-Z0-9_.-]*:' Makefile` | **0** |
| das Layout aus Modul 12 (`evals/golden/welle-NN-baseline/`) | `git ls-files 'evals/**' \| wc -l` | **0** |
| das Vokabular des Moduls außerhalb des vendored Baums (`manifest.yaml`, `must_include`, `must_not_include`, `Drift-Rate`, `golden`) | `git grep -lE 'manifest\.yaml\|must_include\|must_not_include\|Drift-Rate\|golden' -- ':!.harness/baseline' ':!docs/plan/planning' \| wc -l` | **0** |
| eine Closure-Notiz vor dieser Welle, die ihn als Beleg führt | `grep -lie replay docs/plan/planning/done/welle-0*-results.md \| wc -l` | **0** von `ls -1 docs/plan/planning/done/welle-0*-results.md \| wc -l` → **8** |
| eine Welle-Plan-Datei, die ihn in ihre Closure-Kriterien aufnimmt | `ls -1 docs/plan/planning/welle-*.md docs/plan/planning/done/welle-*.md \| grep -v results \| xargs grep -lie replay \| wc -l` | **0** von `… \| grep -v results \| wc -l` → **12** |

Übrig bleiben **zwei** lebende repo-eigene Fundorte
(`git grep -il replay -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning' | wc -l`
→ **2**): der Planungs-Command dieses Repos und seine emittierte Fassung, und dort steht der
Begriff als **Beispiel** für einen beobachtbaren Trigger (*„… ‚Replay grün'). ‚Sobald wir Zeit
haben' scheitert daran."*) — nicht als adoptierter Mechanismus. Das ist dieselbe Lesart, die
Modul 6 §Roadmap-Regeln selbst anlegt, wo der Replay mit `z. B.` eingeführt wird; Schritt 1
schreibt ihn indikativ.

**Warum `docs/plan/planning/` in den beiden Wort-Suchen ausgenommen ist, statt es zu verschweigen:**
dieser Slice und die Closure, die ihn geschnitten hat, **besprechen** den Begriff und das Vokabular
des Moduls — eine Suche nach einer Formulierung wird im zitierenden Dokument fündig, und ein Plan,
der über einen fehlenden Mechanismus schreibt, ist kein Fundort dieses Mechanismus. Die drei
übrigen Achsen brauchen die Ausnahme nicht: sie fragen nach einem `make`-Ziel, einem Verzeichnis
und nach Belegen in einer abgeschlossenen Datei-Menge — nicht nach einem Wort im Fließtext.

**Modul 12 handelt von Agenten-Läufen, nicht von Gate-Läufen.** Seine Kernidee — *„Ohne Replay ist
jeder Agenten-Lauf ein einmaliges Experiment"* — und seine Pflichtfelder (`model.version`,
`model.seed`, `inputs_ref`, `runtime.image_hash`, `recorded_at`), seine Erwartungsformen
(`must_include` · `must_not_include` · `tool_calls`-Zähler) und seine Drift-Rate beschreiben die
Wiederholung eines **Modell**-Laufs gegen ein Golden Set. Keine dieser Größen hat in diesem Repo
einen Träger.

### Was hier verwechselbar ist, und warum es nicht dasselbe ist

[`harness/tools/hook-overhead.sh`](../../../../harness/tools/hook-overhead.sh) *spielt eine reale
Folge von Tool-Calls aus dem Span-Bestand nach* — und ist **kein** Replay im Sinne von Modul 12.
Der Unterschied liegt am Gegenstand, nicht an der Ähnlichkeit: nachgespielt wird die **Eingabe**,
gemessen wird die **Wanduhr-Zeit des Trägers**. Es gibt kein Modell, keinen Seed, kein Golden Set,
keine Erwartung und keine Drift-Rate; das Skript nennt sich im eigenen Kopf *„eine Messung, kein
Gate"*, und sein Ziel steht in keiner Prerequisite-Kette
(`sed -n '/^gates:/p' Makefile | grep -c 'hook-overhead'` → **0**). Ein Sensor, der die Latenz
eines Programms misst, beantwortet die Frage aus Modul 12 nicht — *hat das Modell wiederholt, was
im Golden Set steht?* — und kann sie auch bei besserem Willen nicht beantworten.

**Was [welle-12](../done/welle-12-erfassungsschicht-emittieren.md) daran geändert hat:** sie hat
den **Rohstoff** ins Ziel gebracht, nicht den Mechanismus. Ein gebootstrapptes Repo führt seit ihr
einen eigenen Span-Bestand mit Rollen-Achse. Das ist die Menge, aus der ein Golden Set gezogen
würde — es ersetzt es nicht.

### Was Schritt 1 hier tatsächlich trägt, und wo es steht

[`harness/README.md`](../../../../harness/README.md) §Nicht-Gate-Verify weist `make smoke`,
`make full-smoke` und `make mutate` ausdrücklich an *„DoD-Verify/CI/**Wellen-Closure**"* zu und
begründet, warum sie nicht in `make gates` liegen. Die Welle-Plan-Dateien nehmen genau das in ihre
§3 auf. Die zwei lebenden Anleitungen schreiben Schritt 1 entsprechend um — **ohne den Replay**
(`git grep -ci replay -- .claude/commands/close-welle.md internal/emit/templates/commands/close-welle.md`
→ kein Treffer, Exit 1) und mit *„die welle-spezifischen Closure-Kriterien aus der Welle-Datei §3
sind erfüllt (z. B. ein benannter Smoke)"* an seiner Stelle.

**Die Fassung wird also gelebt, geschrieben und emittiert — und ist nirgends deklariert.** Der
Adaptions-Block nennt vier Module
(`sed -n '/^## Adaptions-Block$/,/^## Modus-Deklaration/p' harness/conventions.md | grep -oE 'Modul [0-9]+' | sort -u | tr '\n' ' '`
→ `Modul 2 Modul 5 Modul 6 Modul 7`), **keines davon Modul 12**, und die vier Modul-6-Nennungen
liegen sämtlich in
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(*Welle oder nicht*), also an einem anderen Gegenstand. Zugleich sagt
[`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage) *„keine inhaltlichen
Adaptionen ggü. Baseline-Default"*. Alle Zahlen wandern mit ihrem Bestand und sind **kein**
Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Lage ist genau die, aus der
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
selbst entstand** — dort *„21 von 56 Slices lang gelebte, aber undeklarierte Praxis"*. Der
Unterschied: hier ist die undeklarierte Praxis zusätzlich in eine **emittierte** Anleitung
geschrieben.

### Der zweite Befund, eine Ebene darüber: die Klasse wiederholt sich

Ein vendored Modul ohne Umsetzung ist in diesem Repo **kein Einzelfall**. Modul 15 war der erste
gemessene Fall und bekam dafür eine eigene Welle
([welle-09](../welle-09-modul-15-konformitaet.md), geschnitten 2026-07-28); der Drift-Log der
Roadmap nennt zu jenem Eintrag die mechanische Ursache: *„die Adoptions-Prüfung sieht bei jeder
Re-Baseline nur das **Delta**, nie den **Bestand** — kein Sensor meldet ‚adoptiert, aber nicht
umgesetzt'"*. Modul 12 ist der **zweite** Fall derselben Klasse, gefunden auf demselben Weg (ein
Mensch beziehungsweise ein Lauf liest den Modultext), nicht von einem Sensor. Ob daraus ein
eigener Gegenstand folgt, entscheidet dieser Slice **nicht** — er benennt ihn, damit die zweite
Instanz nicht als Einzelfall verbucht wird.

### Die Abwägung: drei Wege, einer gewählt

- **(A) Messen, die zwei Ausgänge vorlegen, den Architect entscheiden lassen — gewählt.** Er ist
  der einzige Weg, der die Rollen-Grenze hält: ob eine Abweichung von der Baseline **besteht**,
  ist eine Architektur-Frage ([`AGENTS.md`](../../../../AGENTS.md) §3.8), und der Adaptions-Block
  ist ihr Register. Der Preis ist ein Slice; der Gewinn ist, dass der Schritt entweder deklariert
  gilt oder mit Grund anders ausfällt, statt weiter in zwei Anleitungen zu stehen, von denen eine
  ausgeliefert wird.
- **(B) Den Satz in den zwei Command-Dateien still an die Baseline angleichen.** Verworfen — er
  benennte dann einen Sensor, den kein Lauf fahren kann; jede künftige Closure stünde vor derselben
  Frage, und die Anleitung im Ziel wäre für den Adopter ebenso unerfüllbar
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **(C) Modul 12 in diesem Schnitt adoptieren.** Verworfen für **diesen** Slice, nicht als Sache:
  ein Golden Set mit Happy · Boundary · Negative, gepinnter Modellversion und Drift-Rate ist ein
  eigener Gegenstand mit eigener Abwägung und eigenem Aufwand — und er beantwortet die hier offene
  Frage auch dann nicht sofort, weil bis zu seinem Bestehen jede Welle nach der heutigen Fassung
  schließt. Er ist Ausgang (2) unten und gehört, wenn gewählt, auf die Roadmap.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando einen Punkt rot färbt, steht das
dabei, statt sich hinter einem anderen zu verstecken.

- [ ] **(1) Der Ausgang ist entschieden und an einem Kommando ablesbar — genau einer von zweien.**
      **Ausgang (1) — die Abweichung wird deklariert:** der Adaptions-Block trägt einen Eintrag,
      der Modul 6 Schritt 1 nennt und sagt, welche Sensoren ihn hier tragen.
      **Rot heute:** `sed -n '/^## Adaptions-Block$/,/^## Modus-Deklaration/p' harness/conventions.md | grep -c 'Modul 12'`
      → **0**, gehalten gegen den Nenner `grep -c '^### MR-' harness/conventions.md` — der Block
      ist nicht leer, und **keiner** seiner Einträge nennt Modul 12. Der Nenner **wandert** und
      steht deshalb als Kommando, nicht als Zahl
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2): ein neuer Eintrag über einen fremden Gegenstand darf diesen DoD-Punkt nicht
      bewegen.
      **Ausgang (2) — Modul 12 wird als adoptiert-aber-nicht-umgesetzt geführt:** die Roadmap
      bekommt den Gegenstand als Kandidat oder Welle mit beobachtbarem Trigger.
      **Rot heute:** `grep -ci 'modul 12\|replay' docs/plan/planning/in-progress/roadmap.md` → **0**.
      Die zwei schließen einander nicht aus; **beide auszulassen** ist der Zustand, den dieser
      Slice beendet.
- [ ] **(2) Die zwei lebenden Anleitungen sagen dasselbe wie der gewählte Ausgang — je Ebene
      geprüft, nicht je Datei angenommen.** Heute stehen sie inhaltsgleich
      (`diff <(sed -n '/Schritt 1 — Trigger prüfen/,/behaupte sie nicht/p' .claude/commands/close-welle.md) <(sed -n '/Schritt 1 — Trigger prüfen/,/behaupte sie nicht/p' internal/emit/templates/commands/close-welle.md) | wc -l`
      → **0** Unterschiede). Bewegt sich die Dogfood-Fassung, bewegt sich die emittierte mit —
      **oder** der Slice sagt aus, warum sie es ausdrücklich nicht tut (verschiedene Verträge:
      hier ein Repo, dort jedes Ziel).
      **Rot:** dasselbe `diff` liefert eine nicht-leere Ausgabe, ohne dass §7 einen Grund nennt.
- [ ] **(3) Der vendored Baum bleibt unangetastet.** Er ist auf beiden Ebenen byte-verifiziert;
      wer dort schriebe, färbte `make baseline-verify` rot
      ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
      Eine Abweichung wird **neben** der Baseline deklariert, nie in ihr — sonst ist beim nächsten
      Re-Baseline-Sprung die Deklaration weg und die Praxis wieder undeklariert.
      **Rot:** `make baseline-verify`.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update, **nur bei Ausgang (1)** | Adaptions-Block, Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1); dieser Slice liefert Messung und Termin, nicht den Text. Ein eigener Commit, nur Architect-Artefakte, Rolle in der Message |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | update, **nur bei Ausgang (2)** | ein Kandidat oder eine Welle mit beobachtbarem Trigger. **Nicht** für diesen wellenlosen Slice selbst ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2) |
| [`.claude/commands/close-welle.md`](../../../../.claude/commands/close-welle.md) | update, **soweit der Ausgang es verlangt** | die Dogfood-Anleitung; heute trägt sie den Satz ohne Deklaration dahinter |
| [`internal/emit/templates/commands/close-welle.md`](../../../../internal/emit/templates/commands/close-welle.md) | update, **soweit der Ausgang es verlangt** | die emittierte Fassung ([`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)). Zwei Verträge, eine Entscheidung — die Ebene wird je Datei benannt |
| [`docs/plan/adr/`](../../adr/) | **unverändert**, außer der Ausgang senkt etwas | eine Deklaration, die die gelebte Praxis beschreibt, hebt und senkt keine Schwelle ([`AGENTS.md`](../../../../AGENTS.md) §3.5, [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)). Ergibt der Lauf, dass Ausgang (1) in Wahrheit eine **Senkung** ist — der Replay entfällt ersatzlos —, greift die Rückführung aus §4 |
| [`.harness/baseline`](../../../../.harness/baseline) | **unverändert** | DoD (3) |
| `docs/plan/planning/done/`, `docs/reviews/` | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich) |
| `test/mutations/` | **unverändert** | der Gegenstand ist Regeltext; `make comment-claims` hat keine Markdown-Datei im Prüfbereich, und ein Wächter über Prozess-Prosa ist ein eigener Gegenstand |

**Die Messung gehört an den Anfang des Laufs, nicht an sein Ende.** Sie steht in §1 mit sieben
Kommandos; wer sie erweitert, erweitert sie **vor** der Entscheidung und schreibt dazu, woran er
die weitere Achse erkannt hat.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit.** Der
Gegenstand ist vollständig gemessen; es fehlt der Lauf, der entscheidet. **Er ist jedoch nicht
dringlich in dem Sinne, dass er eine Welle aufhielte** — die heutige Fassung schließt Wellen
auditierbar, sie ist nur nicht deklariert.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: der Lauf stellt fest, dass die Entscheidung **beide** Ausgänge braucht
  und Ausgang (2) einen eigenen Zuschnitt hat — dann Re-Slice, nicht Ausdehnung.
- `in-progress` → `open`: der Architect entscheidet, dass die Frage erst nach der Re-Baseline
  ([welle-10](../welle-10-re-baseline.md)) zu beantworten ist, weil die Ziel-Fassung des Moduls
  den Schritt anders schreibt. Dann ist der Auflösungs-Trigger *welle-10 liegt in `done/`* und
  gehört hierher, nicht in ein Memo.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt, `make gates` grün, Review nach Modul 10 und Verifikation nach Modul 11
ohne blockierenden Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag. **Der Slice ist nicht
geschlossen, solange nur die Messung vorliegt** — genau das ist der Zustand, aus dem er entstand.

## 6. Risiken und offene Punkte

- **Der Slice kann sich in eine Modul-Konformitäts-Inventur ausdehnen.** Der zweite Befund aus §1
  legt es nahe: wenn Modul 12 der zweite Fall ist, sind die übrigen fünfzehn ungeprüft. Das ist
  ein eigener Gegenstand; hier bleibt er ein benannter Befund, und die Rückführung `→ next` steht
  dafür in §4.
- **Ausgang (1) kann als Baseline-Kritik gelesen werden.** Ist er nicht: Modul 6 §Roadmap-Regeln
  führt den Replay selbst mit `z. B.` ein. Was deklariert wird, ist die **Konkretisierung** der
  Closure-Kriterien dieses Repos, nicht die Aufhebung einer Regel.
- **Kein Sensor hält den Ausgang.** Weder `make docs-check` noch `make mutate` liest Prozess-Prosa;
  Träger ist der Rollen-Wechsel vor der Änderung, nicht ein Gate danach — dieselbe Lage wie bei
  [`AGENTS.md`](../../../../AGENTS.md) §3.8 selbst, die es über sich ausspricht.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Begründung, weil der Slice
ein Norm-Artefakt berührt:

### Sub-Area: Norm-Artefakte dieses Repos (Adaptions-Block + Wellen-Closure-Anleitung)

- **Modus:** GF
- **Konventionen-Dichte:** hoch — der Adaptions-Block führt
  seine Einträge (`grep -c '^### MR-' harness/conventions.md` — der Wert wandert und steht darum
  als Kommando, [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) sämtlich in einheitlicher Form (Datum ·
  Geltungsbereich · Adaption · Begründung · Auflösungs-Trigger); die Anleitung folgt der
  Fünf-Schritte-Form aus Modul 6.
- **Phase-Reife:** Phase 2 (Planung) — der Gegenstand ist die Closure-Prozedur selbst, und sie
  hat neun Wellen geschlossen (`ls -1 docs/plan/planning/done/welle-*-results.md | wc -l` → **9**;
  mitwandernd).
- **Evidenz-/Diskrepanz-Risiko:** niedrig — die Diskrepanz ist in §1 vollständig ausgemessen; es
  gibt keinen unbekannten Bestand, der beim Anfassen sichtbar würde.
- **Reconciliation-Aufwand:** S. Ein Eintrag beziehungsweise eine Roadmap-Zeile plus der Nachzug in
  zwei Anleitungen. Graduation entfällt (kein BF).
