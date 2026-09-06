# Review-Report: slice-123 (Runde 2) — 2026-09-06

**Review-Art:** Code — geprüft wird der Nacharbeits-Diff gegen **Slice-Plan + ADRs + Hard Rules**
(Modul 10 §Drei Review-Arten) und gegen die Findings der Runde 1. **Nicht** geprüft: die
DoD-Abhakung und die Closure-Notiz §7 — das ist Verifier- bzw. Planner-Arbeit in getrenntem
Kontext ([`AGENTS.md`](../../AGENTS.md) §3.10, Modul 11).

**Gegenstand:** `slice-123` · Nacharbeit in drei Commits auf `main` — `95c726f` (F-1/F-2/F-4/F-7),
`04c8f95` (F-3), `6d3132d` (F-5/F-6/F-8) · 6 Dateien, +125/−51
(`git diff --stat 95c726f^..6d3132d`). **Außerhalb des Gegenstands:** der
Commit `dab5028` liegt in derselben Strecke, trägt aber `ADR-0037` und den ADR-Index — eine
Architect-Arbeit ohne Bezug zu `slice-123`; er ist hier nicht geprüft.

**Skill:** `.harness/skills/reviewer.md` @ 1.7.0 (`278248f`) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-09-06

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- Slice-Plan `slice-123` (§1 Anlass-Messung · §2 DoD (1)–(3) · §3 Plan-Tabelle · §6 Risiken).
  Genannt als Kennung, nicht als Pfad: die Datei wandert beim Abschluss nach `done/`, und dieser
  Report friert ein ([`AGENTS.md`](../../AGENTS.md) §3.11).
- Vorherige Findings am gleichen Modul: **Runde 1**,
  [`2026-09-06-slice-123-history-range-guard-review.md`](2026-09-06-slice-123-history-range-guard-review.md)
  (F-1 HIGH · F-2…F-6 MEDIUM · F-7/F-8 LOW · F-9 INFO, Verdikt merge-blockierend) — dazu das
  Beobachtungs-Register [`BEO-ALL/`](../plan/planning/observations/README.md).
- Aktive ADRs: [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  (Anweisungssatz-Eigentum), [`ADR-0003`](../plan/adr/0003-go-native-binaries.md) (Docker-only),
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) (Norm-Artefakt-Eigentum),
  [`ADR-0030`](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
  (eingefrorene Adresse auf den Planning-Lifecycle)
- Berührte `LH-*`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
- `MR`-Einträge: [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 3 (*blind und grün*),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- [`AGENTS.md`](../../AGENTS.md) Hard Rules — namentlich §3.3, §3.6, §3.7, §3.8, §3.10, §3.11

---

## Status der Findings aus Runde 1

Jede Zeile ist am Ist-Stand nachgemessen, nicht aus der Commit-Message übernommen.

| # | Kat. | Status | Beleg |
|---|---|---|---|
| F-1 | HIGH | **behoben** (alle sechs Stellen) | siehe unten, Stelle für Stelle |
| F-2 | MEDIUM | **behoben** | Label und Wert stimmen, an einem `--depth 5`-Klon gemessen; Folge-Befund N-3 |
| F-3 | MEDIUM | **behoben** | Verweis zeigt auf Schritt 25, Schritt 25 ist der Register-Schritt |
| F-4 | MEDIUM | **behoben** | explizite Meldung gemessen; Blindstelle in [`harness/README.md`](../../harness/README.md) benannt; Folge-Befunde N-2, N-4 |
| F-5 | MEDIUM | **behoben** | offene Norm-Frage in §6, nicht selbst entschieden; F-3-Korrektur bleibt |
| F-6 | MEDIUM | **inhaltlich behoben, Weg beanstandet** | DoD (2) ist ehrlich — aber im Implementations-Kontext umgeschrieben, N-1 |
| F-7 | LOW | **behoben** | fail-closed Exit 2 gemessen; Folge-Befund N-2 |
| F-8 | LOW | **behoben** | Plan-Tabelle begründet, warum §4 unberührt bleibt |
| F-9 | INFO | unverändert (Planner-Sache) | nicht Gegenstand dieses Laufs |

**F-1, sechs Stellen einzeln.** Alle sechs sind Zustandsbeschreibung im Indikativ; keine nennt
mehr eine Slice-Nummer, ein DoD-Kriterium oder den Slice-Plan als Design-Autorität.

| Stelle (Runde 1) | vorher | jetzt |
|---|---|---|
| `history-range-guard.sh:26–27` | „ohne die Trennung waere die Entscheidungslogik nicht hermetisch pruefbar" | „die Trennung macht `decide()` ueber `--decide <range> <count>` ohne `git`-Aufruf testbar" (`:26–27`) |
| `history-range-guard.sh:29–31` | „BELEG (echter flacher Klon, DoD (1) im Slice-Plan slice-123 …)" | „BELEG (echter flacher Klon), reproduziert mit …" (`:29–30`) |
| `history-range-guard.sh:41–43` | „genau der blinde Gruen-Fall, den DoD (1) verlangt, einmal rot zu sehen" | „die Klasse ‚blind und gruen' aus MR-007 Setzung 3" (`:40–41`) |
| `history-range-guard.sh:60–61` | „(Slice-Plan §1: ‚Der Waechter prueft die Range, nicht die Klon-Tiefe')" | „die Entscheidung selbst haengt an der Commit-Zahl der Range, nicht an diesem Wert: `decide()` bewertet ausschliesslich `count`" (`:69–73`) |
| `test/mutations/265-…:5` | „Entschaerft den Kern des Waechters (slice-123 DoD 1)" | „Entschaerft den Kern des Waechters" (`:5`) |
| `test/mutations/265-…:12–13` | „Ohne den Fixture-Test … bliebe das unbewacht" | „Der Fixture-Test … deckt genau diesen Zweig" (`:11–12`) |
| `test/history-range-guard.bats:3` | „(harness/tools/history-range-guard.sh, slice-123)" | „(harness/tools/history-range-guard.sh)" (`:3`) |

**Neue Stellen derselben Klasse durch die Nacharbeit selbst:** gemessen über alle addierten
Kommentarzeilen der drei Commits
(`git diff ee69247..6d3132d -- harness/tools/history-range-guard.sh test/history-range-guard.bats test/mutations/265-*.sh | grep -E '^\+#'`)
und einzeln gelesen — **keine**. Was die Musterprobe
(`grep -nE 'slice-[0-9]|Slice-Plan|DoD|waere|bliebe|gaebe|frueher' <die drei Dateien>`)
noch zeigt, sind zwei Treffer, und beide sind **kein** Finding: `history-range-guard.sh:139`
(„Fehlt jede gestagte Aenderung, gaebe es … nichts zu pruefen") ist ein Konjunktiv über einen
**Laufzeit-Zustand**, nicht über eine verworfene Alternative; `265-…:6` („sie muesste jetzt genau
EINEN Commit zaehlen") beschreibt die Wirkung **der Mutation**, also den Gegenstand der Datei.
Beide tragen die Klasse *Abgrenzung* bzw. *Zusage* aus [`AGENTS.md`](../../AGENTS.md) §3.7.

**F-2, selbst nachgemessen.** `git clone --depth 5 file:///Development/KI/ai-harness-init <klon>`
→ `git log --oneline | wc -l` = **5**, `wc -l < .git/shallow` = **1**, Ausgabe des Wächters:
`Shallow-Grenzen: 1`. Label und Wert stimmen jetzt überein; im vollen Checkout steht
`Shallow-Grenzen: voll (kein Shallow-Klon)`. `test/history-range-guard.bats:30` prüft die Zeile
wieder mit — **nur ihre Anwesenheit**, und der Kopf `:16–19` sagt genau das; die
Label-Zeichenkette ist damit gekoppelt, der Wert nicht.

**F-3, selbst nachgemessen.** `internal/emit/templates/commands/implement-slice.md:151` verweist
auf Schritt 25; Schritt 25 (`:153`) ist der Register-Schritt, Schritt 24 (`:143`) die Closure.
Beide Fassungen laufen lückenlos 1…25 (`grep -nE '^[0-9]+\. ' <datei>` → je 25 Einträge). Die
Fundmenge ist damit erschöpft: `grep -nE 'Schritt [0-9]+'` findet in der emittierten Datei sonst
nur Modul-Nummern (`:75`, `:90`, `:93`), in `.claude/commands/implement-slice.md` zusätzlich
„Schritt 9" (`:152`) — und Punkt 9 (`:55`) trägt dort die zitierte Hard-Rule-3.3-Begründung, der
Verweis löst also auf.

**F-4, selbst nachgemessen.** `make history-range-guard STAGED=1` gibt am sauberen Baum
`history-range-guard: --staged ohne gestagte Aenderung — nichts zu pruefen.` aus, Exit 0 — statt
der Null-Ausgabe aus Runde 1. Mit einer gestagten Änderung (im Wegwerf-Klon geprüft) bleibt die
Ausgabe leer, Exit 0; das ist in [`harness/README.md`](../../harness/README.md) `:73` als eigener
Satz benannt („`STAGED=1` prüft keine Range …, den Inhalt der gestagten Änderung prüft dann das
d-check-Modul selbst").

**F-7, selbst nachgemessen.** `--decide "HEAD..HEAD" abc` → Exit **2** mit
`liefert keine gueltige Commit-Zahl ('abc')`; `--decide "HEAD..HEAD"` (fehlendes drittes Argument)
ebenso. Der bats-Fall 123 hat Zähne: über einer Kopie ohne den `case`-Block
(`sed '/^  case "\$count" in$/,/^  esac$/d'`) liefert derselbe Aufruf Exit **0** und
`aufgeloest, abc Commit(s) — OK`.

**Der Zahn zu DoD (3) trägt weiter.** `test/mutations/265-…` über einer isolierten Kopie
angewandt: `--decide "HEAD..HEAD" 0` liefert danach Exit **0** statt 1 — der bats-Fall 119 fällt.
`grep -c 'count" -eq 0'` → **1** (die Zeile in `decide()`); `decide_staged` trägt eine andere
Variable und wird von der Ersetzung nicht getroffen.

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der
verbindlichen Single Source of Truth. Die Felder unten sind nur
**gespiegelt** (Bequemlichkeit beim Ausfüllen), nicht neu definiert; bei
Abweichung gilt der Skill bzw. dessen Quelle
Baseline-Regelwerk `modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill.

### N-1 — Die Nacharbeit schreibt das eigene Abnahmekriterium um, statt es zu übergeben

- `kategorie`: HIGH
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.10 (*„die ausführende Rolle schreibt ihr eigenes
  Abnahmekriterium nicht um"*) · Modul 8 §Konflikt-Pfad
- `pfad`: Slice-Plan `slice-123` §2 DoD (2), Zeilen 98–105 · Commit `6d3132d`
- `befund`: Der Commit `6d3132d` trägt das Rollen-Präfix `Rolle Implementation` und ersetzt die
  **Rot**-Klausel von DoD (2) — das Abnahmekriterium, gegen das die Verifikation diesen Slice
  prüft. Der Slice-Plan nennt in seinem Kopf `**Autor:** Planner` (`:32`); §3.10 führt „ein
  DoD-Punkt" namentlich als Übergabe-Artefakt an den Planner und nicht als Schritt der
  ausführenden Rolle. Die Ersetzung senkt die Zusage (aus *„die Zuordnung selbst ist rot, wenn
  ein Job … ohne `fetch-depth: 0` bleibt"* wird *„keinen realen CI-Rot-Nachweis"*), und sie ist
  im selben Lauf entstanden, der für F-5 ausdrücklich das Gegenteil tut — dort steht die
  Norm-Frage als offener Punkt in §6, „*wird hier nicht durch eine weitere Implementer-Auslegung
  entschieden*". Dieselbe Bewegung, kleiner, an der Plan-Tabelle §3 `:121`: die im Plan gesetzte
  Bedingung zu [`AGENTS.md`](../../AGENTS.md) §4 wurde durch die Begründung ersetzt, warum sie
  nicht gilt; §3.10 zählt die Plan-Tabelle **nicht** unter den drei gebundenen Artefakten, sie
  ist deshalb hier kein zweiter Hard-Rule-Verstoß, sondern derselbe Bewegungs-Typ.
- `verifizierbar`: nein — kein Modul der [`.d-check.yml`](../../.d-check.yml)
  (`links, anchors, ids, matrix, codepaths, spans`) liest Commits, und `make mutate` kennt keine
  Fehlschlag-Form für einen Commit-Zuschnitt; §3.10 stellt diese Lücke für sich selbst fest.
  Beobachtbar ist der Befund an `git show --stat 6d3132d` gegen das Feld `**Autor:** Planner`.
- `klasse`: Fremdes Rollen-Artefakt im Implementations-Kontext

### N-2 — Die fail-closed-Wache aus F-7 fehlt in der Funktion, die im selben Commit entstand

- `kategorie`: LOW
- `quelle`: Maintainability · [`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 3
- `pfad`: `harness/tools/history-range-guard.sh:112–117` (`decide_staged`), Eingang `:130–133`
- `befund`: `decide_staged()` bewertet mit `[ "$has_staged" -eq 0 ]` und hat keine
  Ganzzahl-Prüfung, die `decide()` im selben Commit bekam. Gemessen:
  `bash harness/tools/history-range-guard.sh --decide-staged` (ohne Wert) und
  `… --decide-staged abc` geben `[: : Ganzzahliger Ausdruck erwartet` auf stderr aus, führen
  **keine** Bewertung durch und enden mit **Exit 0**; `… --decide-staged 2` endet stumm mit Exit 0
  und wird wie „gestagte Änderung vorhanden" behandelt, obwohl der Vertrag in der Usage-Zeile
  `:135` und in [`harness/README.md`](../../harness/README.md) `:73` `<0|1>` lautet. Der
  produktive `--staged`-Pfad ist nicht betroffen (`:142–147` übergibt Literale), erreichbar ist
  der Zweig über denselben dokumentierten Fixture-Eingang wie in F-7.
- `verifizierbar`: nein — die zwei bats-Fälle 121/122 übergeben ausschließlich `0` und `1`, und
  kein Fall in `test/mutations/` trifft `decide_staged`.
- `klasse`: Positive Meldung im Fehlschlag-Zweig einer Auswertung

### N-3 — Die F-2-Korrektur ist an zwei benachbarten Zusagen nicht nachgezogen

- `kategorie`: LOW
- `quelle`: Maintainability · Slice-Plan `slice-123` §2 DoD (1)
- `pfad`: `test/history-range-guard.bats:26` · Slice-Plan `slice-123` §2 DoD (1), Zeile 90
- `befund`: Der Fix hat den Wert-Namen korrigiert und zwei Aussagen daneben stehen lassen. Der
  Name des ersten bats-Falls lautet weiter `… exit 1, LEER + Tiefe + Range + Advice`, während die
  Zusicherung darin seit demselben Commit `Shallow-Grenzen:` prüft (`:30`) und der Datei-Kopf
  `:16` erklärt, dass genau **nicht** die Tiefe gemeint ist — der Fall-Name erscheint so in jeder
  `make test-bats`-Ausgabe (`ok 119 …`). DoD (1) sagt zu, der Wächter „*nennt beim Rot, was fehlt
  (Tiefe, angeforderte Range, Zahl der enthaltenen Commits)*"; die Rot-Meldung nennt zwei der drei
  wörtlich und für das dritte eine Größe, die der Fix ausdrücklich von der Tiefe unterscheidet.
  Die Diagnose trägt sachlich weiter (der Leser erkennt den flachen Klon), das Wort der Zusage
  hat keinen Gegenpart mehr in der Ausgabe. DoD (3) trägt dasselbe Wort („*entfernt die
  Tiefen-Prüfung*") — das steht **vor** dieser Nacharbeit und ist ihr nicht zuzurechnen.
- `verifizierbar`: nein — kein Gate hält einen bats-Fall-Namen gegen seine Zusicherungen, und die
  DoD liest kein Modul des Doku-Gates.
- `klasse`: Zusage neben geänderter Ableitung bleibt stehen

### N-4 — Die README zitiert eine Meldung, die so nicht ausgegeben wird

- `kategorie`: LOW
- `quelle`: Maintainability · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `harness/README.md:73` · `harness/tools/history-range-guard.sh:115`
- `befund`: Die neue Passage zitiert die Meldung als Inline-Code
  `--staged ohne gestagte Änderung — nichts zu prüfen`; das Skript gibt
  `--staged ohne gestagte Aenderung — nichts zu pruefen.` aus (ASCII-Umschrift, abschließender
  Punkt) — gemessen mit `make history-range-guard STAGED=1 2>&1 | cat -A`. Wer die zitierte
  Zeichenkette in dem CI-Job sucht, den derselbe Absatz als noch fehlend beschreibt, findet sie
  nicht. Dieselbe Datei zitiert Lauf-Ausgaben sonst zeichengleich (`AUSGANG LEITUNG`,
  `0 Befund(e)`, `not ok N`), und [`harness/conventions.md`](../../harness/conventions.md)
  §Adoptierte Konventions-Quellen führt die `baseline-verify`-Zeile samt ihrer ASCII-Form.
- `verifizierbar`: nein — die Modul-Liste der [`.d-check.yml`](../../.d-check.yml) führt kein
  Zitat-Modul (`check-lines` ist hier nicht aktiviert), und `make comment-claims` nimmt jede
  Markdown-Datei dauerhaft aus seinem Prüfbereich.
- `klasse`: Zitierte Ausgabe weicht vom Literal ab

### N-5 — Die zwei neuen Zusagen ruhen allein auf bats, ohne Fall im Mutations-Satz

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 · [`harness/README.md`](../../harness/README.md)
  (*„wer keinen Fall in `test/mutations/` hat, ist unbewacht"*)
- `pfad`: `harness/tools/history-range-guard.sh:91–96` (fail-closed-Wache) und `:112–117`
  (`decide_staged`) · `test/mutations/`
- `befund`: Die Nacharbeit fügt zwei prüfbare Zusagen hinzu — die Ganzzahl-Wache und die
  Leerfall-Meldung — und deckt beide mit bats (Fälle 121–123, gemessen rot ohne die Wache). Ein
  Fall in `test/mutations/` besteht für keine von beiden:
  `ls test/mutations/*.sh | wc -l` → **251**, davon nennt genau einer diesen Wächter
  (`ls test/mutations/ | grep -c history` → 1), und der trifft `decide()`s Leer-Zweig. Die
  Annahme, dass die Haltbarkeit dieser zwei Zusagen allein am bats-Fall hängt und nicht am
  Mutations-Satz, steht in keinem Artefakt.
- `verifizierbar`: ja — `make mutate` meldet für die zwei Zweige nichts, weil es sie nicht führt;
  die Abwesenheit ist mit den zwei `ls`-Kommandos oben messbar.
- `klasse`: Neue Zusage ohne Fall im Mutations-Satz

### N-6 — Ein eingefrorenes Artefakt nennt den Slice-Plan als Pfad, und sein Move steht bevor

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.11 ·
  [`ADR-0030`](../plan/adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4
- `pfad`: [`2026-09-06-slice-123-history-range-guard-review.md`](2026-09-06-slice-123-history-range-guard-review.md)
  (Report der Runde 1, Abschnitt *Eingangs-Kontext*)
- `befund`: §3.11 verlangt vor einem vom Prozess vorgeschriebenen Ortswechsel eine Messung über
  beide Adress-Formen. Sie ist gefahren
  (`git grep -n -F 'slice-123-ci-sieht-die-historie.md' -- ':!.harness/baseline'`, 12 Fundstellen
  in 6 Dateien): elf liegen in lebenden Plan-Dateien, die `make slice-mv` beim Übergang nach
  `done/` mitzieht; **eine** liegt im Rollen-Report der Runde 1 und nennt den Plan als
  `../plan/planning/in-progress/…`-Link. Ein Rollen-Report ist nach §3.11 ein einfrierendes
  Artefakt; beim `git mv` nach `done/` bricht entweder der Link (`make docs-check` rot) oder der
  Verweis-Nachzug schreibt in ein eingefrorenes Artefakt — `docs/reviews/**` ist von der
  Eingehend-Ersetzung ausdrücklich **nicht** ausgenommen. Dieser Report nennt den Plan darum als
  Kennung. Der Befund liegt nicht im geprüften Diff; er ist datiert und wird beim Abschluss fällig.
- `verifizierbar`: ja — nach dem Move zeigt `make docs-check` den Bruch bzw. `git show` den
  Schreibzugriff auf das eingefrorene Artefakt; vorher ist er mit dem `git grep` oben messbar.
- `klasse`: Vorgeschriebener Ortswechsel macht Adresse tot

## Negativbefunde

- geprüft, ohne Befund: **Alle sechs F-1-Stellen und jede addierte Kommentarzeile der drei
  Commits** gegen [`AGENTS.md`](../../AGENTS.md) §3.7 — Tabelle oben, Stelle für Stelle. Die zwei
  verbliebenen Musterprobe-Treffer sind benannt und tragen je eine der fünf Kommentar-Klassen.
- geprüft, ohne Befund: **Der neue `BELEG --staged`-Block im Skriptkopf** (`:55–66`) — dieselbe
  Form wie der vorhandene `BELEG`-Block und wie `harness/tools/slice-mv.sh` §BELEG, die
  [`harness/README.md`](../../harness/README.md) als dauerhafte Form im Skriptkopf führt. Der
  Inhalt ist nachgefahren: leerer Index → Meldung + Exit 0, gestagte Änderung → keine Ausgabe +
  Exit 0, beides zeichengleich mit dem Transkript.
- geprüft, ohne Befund: **F-5 in beiden Hälften** — die Norm-Frage steht als offener Punkt in §6
  (`:171–177`), ohne ein Verdikt zu setzen, und die inhaltliche Korrektur aus F-3 steht
  unverändert. Der Kopf-Satz „Ebene: Dogfood, nicht emittiert" bleibt stehen; der Widerspruch ist
  damit **benannt** statt aufgelöst, was die von Modul 8 verlangte Übergabe-Form ist.
- geprüft, ohne Befund: **Das Anlegen eines neuen §6-Risikos durch den ausführenden Lauf** —
  [`AGENTS.md`](../../AGENTS.md) §3.10 bindet die **Ausgänge** der offenen Risiken (Closure), nicht
  das Notieren eines im Lauf entdeckten Risikos; Modul 5 führt das Risiko ausdrücklich als
  Originalinformation des Slice-Plans. Beanstandet ist in N-1 die DoD-Klausel, nicht dieser Eintrag.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.3 (Move und Inhalt getrennt)** — keiner
  der drei Commits bewegt eine Datei (`git diff --stat` weist ausschließlich Änderungen aus), und
  die Commit-Grenzen sind sauber: `04c8f95` und `6d3132d` berühren je genau eine Datei.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.9 (Docker-only)** — die Nacharbeit
  fügt keinen Aufruf einer Host-Toolchain hinzu; das Rezept fährt weiter `bash` und `git`, beide
  in §3.9 als Host-Voraussetzung geführt.
- geprüft, ohne Befund: **[`AGENTS.md`](../../AGENTS.md) §3.8 (Architect-Eigentum)** — weder
  `AGENTS.md` noch [`harness/conventions.md`](../../harness/conventions.md) noch eine Datei unter
  `harness/conventions/` liegt in den drei Commits.
- geprüft, ohne Befund: **[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)**
  — `gates: record-gates` ist unverändert, `record-gates` führt weiterhin
  `baseline-verify docs-check lint build test shell-lint ci-lint comment-claims host-bin span-check`
  (`grep -nE '^record-gates:' Makefile`), und `history-range-guard` steht in keiner
  Prerequisite-Kette. Die neue README-Passage sagt das unverändert selbst.
- geprüft, ohne Befund: **Die Kopplung von Mutations-Fall und bats-Fall** — die `# expect:`-Zeile
  (`history-range-guard: leere Range (0 Commits) -> exit 1`) ist unverändert und bleibt ein Präfix
  des bats-Fall-Namens; `narrow_sensor()` wählt weiter die bats-Stufe. N-3 beanstandet den Namen,
  nicht die Kopplung.
- geprüft, ohne Befund: **Gate-Läufe über diesem Stand** — `make gates` **EXIT 0** (ein Lauf, er
  zieht `baseline-verify`, `docs-check`, `lint`, `build`, `test`, `shell-lint`, `ci-lint`,
  `comment-claims`, `host-bin`, `span-check` und den Gate-Nachweis): `d-check: 838 Datei(en)
  geprüft, 0 Befund(e)` · `comment-claims: 56 Datei(en) geprueft, 0 Befund(e)` · bats `1..224`,
  224× `ok`, kein `not ok`, darunter die sechs Fälle 119–124 für diesen Wächter ·
  `baseline-verify: v6.0.0 OK — 53 Dateien`. `make mutate` ist **nicht** gefahren (Laufzeit); der
  Fall 265 ist stattdessen über einer isolierten Kopie nachgefahren, Ergebnis oben. Diese Zeile
  ist **kein** Verifikations-Beleg: die DoD-Bestätigung führt der Verifier in getrenntem Kontext
  (Modul 11).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 0 |
| LOW | 3 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Fremdes Rollen-Artefakt im Implementations-Kontext · Positive
Meldung im Fehlschlag-Zweig einer Auswertung · Zusage neben geänderter Ableitung bleibt stehen ·
Zitierte Ausgabe weicht vom Literal ab · Neue Zusage ohne Fall im Mutations-Satz ·
Vorgeschriebener Ortswechsel macht Adresse tot

**Vier dieser Klassen führt das Beobachtungs-Register bereits.** Der Zähler ist die Zahl der
Evidence-Dateien und steht neben seinem Kommando
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, gemessen am
2026-09-06, **keine Erwartungswerte**):

| Kennung | Zähler heute | Finding | Stand nach Eintrag |
|---|---|---|---|
| `BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext` | 4 | N-1 | 5 |
| `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` | 14 | N-3 | 15 |
| `BEO-ALL/vorgeschriebener-ortswechsel-macht-adresse-tot` | 3 | N-6 | 4 |
| `BEO-ALL/zaehler-label-nennt-falsche-einheit` | 2 | F-2 (Runde 1, behoben) | unverändert von diesem Lauf |

Die Bezeichnungen sind die des Registers und nicht neu formuliert — eine Umformulierung spaltet
die Klasse in zwei Pfade (Modul 6 §Das Beobachtungs-Register). Für die drei neuen Klassen —
*Positive Meldung im Fehlschlag-Zweig einer Auswertung* (schon in Runde 1 als F-7 vergeben),
*Zitierte Ausgabe weicht vom Literal ab*, *Neue Zusage ohne Fall im Mutations-Satz* — führt das
Register heute keinen Eintrag; die Zuordnung entsteht bei der Slice-Closure. **Runde 1 und
Runde 2 sind derselbe Vorgang:** ein Vorgang zählt einmal, auch wenn zwei Reports dieselbe Klasse
nennen.

**`BEO-ALL/fremdes-rollen-artefakt-im-implementations-kontext` ist bereits *verkörpert*** — sein
`state.md` nennt [`AGENTS.md`](../../AGENTS.md) §3.10 als Zielort und führt als eigene
Hinzufügung, „*dass eine Änderung am eigenen Abnahmekriterium ein Übergabe-Artefakt an den Planner
ist, kein Closure-Schritt*". N-1 ist damit kein neues Muster, sondern ein Auftreten gegen eine
Regel, die genau dafür geschrieben wurde.

## Verdikt

**Merge-blockierend:** ja — ein HIGH. Die drei Commits liegen bereits auf `main`; das Verdikt
richtet sich deshalb an die **Freigabe an den Verifier**, und die ist nicht erteilt.

**Die Code-Hälfte ist frei.** F-1 bis F-4, F-7 und F-8 sind am Ist-Stand nachgemessen behoben, die
Gates sind grün, der Mutations-Zahn trägt. Was in dieser Runde offen bleibt, sind drei LOW und
zwei INFO; keines davon blockiert, und N-5/N-6 sind ausdrücklich Hinweise für den Abschluss, keine
Mängel des Diffs.

**Blockierend ist allein N-1, und der Grund ist der Adressat des nächsten Schritts.** Der Verifier
prüft Code gegen **DoD und Spec**; die DoD (2), gegen die er prüfen würde, ist von der geprüften
Rolle selbst geschrieben. Damit fällt genau die Kontext-Trennung weg, für die die Verifikation
existiert (Modul 8 §Kernidee), und das ist kein Formfehler, sondern der Verlust des zweiten Blicks
vor einem Merge, der Artefakte einfriert. Der Weg dorthin läuft nach
[`AGENTS.md`](../../AGENTS.md) §3.10 über den **Planner** als Autor des Plans; wird dem
widersprochen, läuft der Vorgang nicht über eine Herabstufung dieses Findings, sondern über den
Konflikt-Pfad aus Modul 8 — Sequenz mit Übergabe-Artefakten, Verdikt des Architect als Artefakt,
und im Terminalfall als ADR.

**Was ausdrücklich nicht beanstandet ist:** dass die Nacharbeit F-6 inhaltlich richtig gelöst hat.
Die alte DoD-Klausel sagte einen Rot-Nachweis zu, den es nicht gibt; die neue sagt das offen. Der
Text ist besser geworden — nur nicht in dem Kontext, der ihn schreiben durfte. Derselbe Commit
zeigt für F-5, dass die richtige Form dem Lauf bekannt war.

**Übergabe:** Findings gehen an den Implementer (Rückkante
Review → Plan bei Plan-Defekt); die **Finding-Klassen** gehen zusätzlich
in die Slice-Closure §7 und von dort in den Zähler. Dieser Report selbst
ist ein **Lauf-Beleg** (Audit: dieser Diff, dieser Skill, dieses Modell,
dieses Verdikt) — er wird über Läufe hinweg nicht wieder gelesen, und
muss es nicht. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
