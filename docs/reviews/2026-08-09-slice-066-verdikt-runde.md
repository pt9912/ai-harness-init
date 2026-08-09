# Review-Report: slice-066 (Code, Verdikt-Runde) — 2026-08-09

**Review-Art:** **Code**, mit **eng gefasstem Auftrag**. Geprüft wird genau eine Frage: steht von
den vier blockierenden MEDIUM der Bestätigungsrunde
([`2026-08-09-slice-066-bestaetigungsrunde.md`](2026-08-09-slice-066-bestaetigungsrunde.md), 0/4/2/2,
**NICHT KONFORM**) noch etwas? Kein vierter Findings-Durchlauf über den gesamten Slice — was die
Vorrunden geprüft und aufgelöst haben, ist hier nicht erneut aufgerollt. **Nicht** geprüft: die
DoD-Abhakung (Modul 11, eigener Kontext, anderes Prüf-Artefakt).

**Gegenstand:** `b74df5d..d9a62ad`, vier Commits — `aba99a9` · `294091d` · `1094c11` · `d9a62ad`.
Selbst nachgezählt: `git diff --stat b74df5d..d9a62ad` = **12 Dateien, +884/−39**;
`git log --oneline` = vier Zeilen. Von den geprüften Artefakten liegen **zwei** in `cmd/`,
`internal/`, `spec/`, `test/` (`internal/report/report.go`) bzw. im `Makefile` — der Rest ist
`AGENTS.md`, `harness/conventions.md`, eine neue ADR und Plan-Artefakte, also derselbe Beifang,
der die Vorrunde blockierte.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-08-09

**Eingangs-Kontext:**

- Slice-Plan `docs/plan/planning/in-progress/slice-066-telemetrie-auswertung.md` (§5
  Closure-Trigger, §7 Closure-Notiz)
- [`AGENTS.md`](../../AGENTS.md) **§3.6** und **§3.7** als die beiden benannten Maßstäbe; §3.7
  gilt seit heute **mit Cutoff**, der Bestand ist ausdrücklich kein Arbeitsauftrag
- aktive ADRs: [`ADR-0003`](../plan/adr/0003-go-native-binaries.md),
  [`ADR-0011`](../plan/adr/0011-telemetrie-erfassung-policy.md),
  [`ADR-0014`](../plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) (Accepted, selbst
  gelesen); neu und **Proposed**:
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md)
- [`harness/conventions.md`](../../harness/conventions.md) `MR-000`, `MR-007`, `MR-015`,
  `MR-020`, `MR-022`, **`MR-023`**
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- Regelwerk `v3.5.2`: `README.md`, `modul-08-agentenrollen.md`, `modul-10-review-harness.md`,
  `grundlagen-konventionen.md`
- **vorherige Findings am gleichen Modul:** die vier Vorgänger-Reports unter `docs/reviews/`
- **Upstream-Referenz:** `/Development/KI/ai-harness-course`, gepinnt gelesen am Tag **`v5.3.0`**
  (`git show v5.3.0:<pfad>`), nicht am beweglichen HEAD

**Mess-Grundlage.** Jede Zahl unten ist in diesem Kontext selbst erhoben. Keine Zusicherung einer
Commit-Message und keine Aussage der Bestätigungsrunde ist übernommen worden. **Anders als die
Vorrunde sind `make gates` und `make mutate` hier real gefahren** — der Auftrag verlangt es
ausdrücklich, und die Vorrunde hatte beide mit Verweis auf die Rollen-Grenze ausgelassen.

---

## Läufe

| Lauf | Kommando | Ergebnis |
|---|---|---|
| Gates | `make gates` | **Exit 0.** `baseline-verify: v3.5.2 OK — 42 Dateien` · `d-check: 299 Datei(en) geprüft, 0 Befund(e)` · golangci-lint `0 issues.` · bats **150 ok / 0 not ok** (selbst gezählt: `grep -c '^ok '` = 150, `grep -c '^not ok'` = 0) · `comment-claims: 40 Datei(en) geprueft, 0 Befund(e)` · `record-gates` hat `.harness/state/gates-passed.diffsha` geschrieben |
| Mutationen | `make mutate` | **`145 ok, 0 Befund(e)`, Exit 0** über den Baum bei `d9a62ad`, Arbeitsbaum sauber (`git status --porcelain` = 0 Zeilen vor und nach dem Lauf) |

**Der Mutations-Lauf brauchte zwei Anläufe, und der erste gehört in den Bericht.** Anlauf 1 endete
mit `109 ok, 36 Befund(e)`, Exit 2. Jeder der 36 Befunde trägt die Form *„rot, aber 'X' faellt
nicht — falscher Grund"*, und **alle 36** nennen im mitgeführten Sensor-Auszug einen
DNS-Fehlschlag gegen Docker Hub (selbst ausgezählt: 36 von 36 BEFUND-Blöcken enthalten
`docker.io`/`registry-1`/`auth.docker.io` mit `no such host` bzw. `i/o timeout`). Es war also die
Umgebung dieses Laufs, nicht der Baum. **Der Treiber hat sich dabei richtig verhalten** — er ist
fail-closed gefallen und hat die Ursache mitgedruckt, statt die Fälle als bestanden zu zählen; das
ist der Gegenentwurf zum stillen Grün. Anlauf 2 mit erreichbarem Registry lieferte `145 ok,
0 Befund(e)`. Die Beobachtung, die daraus für den Baum folgt, steht als N4.

---

## Die vier blockierenden MEDIUM, einzeln nachgemessen

### B1 — Vier tragende Sätze der `Makefile`-Kürzung fehlen (MEDIUM) → **GEFALLEN**

**Kommando und Ausgabe** (je `grep -c <muster> Makefile`, am HEAD):

```
Logik liegt in               -> 3
shell-lint sie deckt         -> 2
Fetch und Vergleich          -> 1
ohne Netz testbar            -> 1
auf .sources                 -> 1
sechs --disable-Flags        -> 1
```

Alle vier Fundstellen der Vorrunde tragen wieder eine Aussage: `Makefile:109-111` (`smoke`),
`:147-149` (`baseline-verify`), `:159-161` (`regelwerk-check`), `:171-173` (`baseline-freshness`).
Gegen den Stand **vor** der Kürzung gehalten (`git diff edf739d^..HEAD -- Makefile`, nur
Kommentarzeilen) deckt sich der Inhalt je Fundstelle mit dem entfallenen Satz; die Fassung ist
umformuliert, nicht kopiert.

**Die tragende Zusage ist rot gesehen — von mir, nicht laut Commit-Message.** Der blockierende
Kern von B1 war die Kopplung an `baseline-verify`, weil dieses Ziel in `gates` läuft
(`Makefile:262`, selbst gelesen). Probe: eine Shellcheck-Verletzung in
`harness/tools/baseline-verify.sh` eingefügt, `make shell-lint`:

```
In harness/tools/baseline-verify.sh line 99:
if [ "$x" = ]; then echo probe; fi
   ^-- SC1073 (error): Couldn't parse this test expression. Fix to allow more checks.
             ^-- SC1072 (error): Unexpected . Fix any mentioned problems and try again.
make: *** [Makefile:127: shell-lint] Fehler 1
SHELL_LINT_EXIT=2
```

Probe zurückgenommen, `git status --porcelain` = 0 Zeilen. Die Kopplung hält:
`shell-lint`s Prüfbereich (`Makefile:128`) führt `harness/tools/*.sh`, der `Makefile`-Rezeptkörper
liegt außerhalb — genau das sagen die beiden wiederhergestellten Sätze.

**Restbeobachtung ohne Blockade:** der `regelwerk-check`-Satz trägt eine Klausel, die in der
Vorfassung nicht stand — siehe N1.

### B2 — Falschaussage über die Platzierung der Kommentar-Regel (MEDIUM) → **GEFALLEN**

**Die Klausel ist weg, gegen einen bekannten Treffer validiert.** Ein leeres `grep` belegt nichts,
solange das Muster nicht an einem bekannten Vorkommen geprüft ist:

```
$ git show b74df5d:AGENTS.md | grep -n 'nicht als Hard Rule'
140:Implementierungs-Modul referenziert, nicht als Hard Rule). Beides ist als

$ grep -rn 'nicht als Hard Rule' --include='*.md' .   # ohne docs/reviews/ und .harness/baseline/
(keine Ausgabe)
```

Das Muster greift also — und findet am HEAD in keinem lebenden Artefakt mehr etwas.

**Die Sachaussage habe ich selbst gegen den Upstream-Tag gemessen, nicht übernommen:**

```
$ git -C /Development/KI/ai-harness-course show v5.3.0:lab/templates/AGENTS.template.md | grep -n '^### 3\.'
...
150:### 3.7 Ein Kommentar beschreibt, was da ist

$ git -C … show v5.3.0:lab/regelwerk/grundlagen-harness-dateien.md | grep -n 'Hard Rule'
100:- **Hard Rule:** *Ein Kommentar beschreibt, was da ist.* Wer Herkunft nennt,
```

Upstream führt die Regel an derselben Stelle und ausdrücklich als Hard Rule. Die frühere
Abweichungs-Behauptung war falsch; ihre Aufhebung ist richtig.

**Die Form der Aufhebung trägt.**
[`MR-023`](../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
hebt [`MR-022`](../../harness/conventions.md#mr-022--kommentar-regel-als-vorgriff-auf-eine-neuere-baseline)
**Punkt 2** auf und lässt dessen Rumpf stehen — das ist keine Bequemlichkeit, sondern
[`ADR-0014`](../plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a) im
Wortlaut: *„bei Teil-Aufhebung bleibt der Rumpf, weil sein Rest bindet"* (selbst gelesen,
`0014-…:73-75`). Der Diff ist rein additiv, selbst gemessen:
`git diff b74df5d..HEAD --numstat -- harness/conventions.md` → **60 / 0**, und
`git diff … | grep -c '^-[^-]'` → **0**. Punkt 1 und der Auflösungs-Trigger sind unberührt.

**Der Mess-Stand steht jetzt im Text** ([`AGENTS.md`](../../AGENTS.md):152-157: *„Gegen den Tag
`v5.3.0` gemessen (2026-08-09, lokaler Kurs-Klon)"*). Das ist die eigentliche Reparatur: die
Vorfassung war nicht falsch, weil jemand schlecht gelesen hätte, sondern weil eine Messung ohne
Versionsangabe niedergeschrieben wurde, während der Kurs weiterlief.

### B3 — Rollen-Eigentum an Norm-Artefakten, dritte Instanz (MEDIUM) → **GEFALLEN als Merge-Blocker; ein benannter Rest bleibt**

Das ist der einzige der vier Punkte, bei dem die Antwort nicht rein mechanisch ist. Der Auftrag
stellt die Frage ausdrücklich: bedient ein **Proposed**-Träger den Befund, oder vertagt er ihn?
Ich habe beide Hälften getrennt gemessen.

**Was bedient ist:**

1. **Der materialisierte Schaden ist repariert.** Das Failure-Szenario von B3 war nicht
   hypothetisch — es war B2, und B2 ist oben gegen `v5.3.0` als aufgelöst gemessen.
2. **Modul 10 §Pflege verlangt einen Träger, keinen vierten Befund.** Der Wortlaut, selbst
   gelesen (`modul-10-review-harness.md:70-71`): *„bei dreimaligem gleichem Finding /
   Klassifikation schärfen / Folge-ADR bzw. `AGENTS.md`-Update / Gate"*. Eine **Folge-ADR** ist
   der erstgenannte vorgesehene Weg, und sie liegt vor.
3. **Sie ist in der richtigen Rolle und im eigenen Commit entstanden.** `git show --stat 294091d`
   → genau **zwei** Dateien: `docs/plan/adr/0015-…md` und `docs/plan/adr/README.md`. Beide gehören
   nach Modul 8 §Rollen-Regeln dem Architect; kein Artefakt einer anderen Rolle liegt im Commit.
   Das ist die Trennung, deren Fehlen der Befund war.
4. **Ihre eigenen Messungen reproduzieren.** `git log --oneline -S'### 3.' -- AGENTS.md` liefert
   die drei genannten Commits (`d30db38`, `c0e9955`, `f7f086e`), selbst gefahren; die
   `v5.3.0`-Zeile ist oben unabhängig bestätigt.
5. **Der Proposed→Accepted-Pfad ist im Repo real geübt, keine Erfindung.** Unter `docs/reviews/`
   liegen `2026-07-28-adr-0011-proposed-review.md` und drei
   `2026-08-03-adr-0012-bestaetigungsrunde*.md` — ADR-0012 brauchte drei Runden bis zur Annahme.
   ADR-0015 betritt denselben, belegten Weg.

**Was vertagt ist — und das benenne ich, statt es wegzuschreiben:**

1. **Bis zur Annahme bindet nichts.** `grundlagen-konventionen.md:644` setzt den
   Acceptance-Trigger: *„Phase-Übergang via Sign-off (z. B. ADR Proposed → Accepted) …
   ADR-Review-Runde abgeschlossen → **bindend**"*. ADR-0015 Festlegung 3 setzt ihren Cutoff selbst
   auf *„ab dem Commit, der diese ADR annimmt"*, und Folgepflicht 1 (der Hard-Rule-Text in
   [`AGENTS.md`](../../AGENTS.md) §3) ist ausdrücklich auf die Annahme vertagt. Am HEAD führt §3
   **sieben** Hard Rules (`grep -n '^### 3\.' AGENTS.md`), §3.8 gibt es nicht. Eine vierte Instanz
   der Klasse bräche heute keine geschriebene Regel.
2. **Für die Annahme gibt es keinen lebenden Träger außer der Status-Spalte.** Selbst gemessen:
   `ADR-0015` wird außerhalb ihrer eigenen Datei von genau **zwei** Orten referenziert — dem
   ADR-Index und `slice-066` §7. `grep -rn 'Proposed'` über [`AGENTS.md`](../../AGENTS.md),
   `harness/`, `.claude/` und `docs/plan/planning/in-progress/` findet **keinen** Prozess-Schritt,
   der offene ADRs einsammelt. Mit dem Closure-Move wandert der zweite Zeiger nach `done/` — in
   genau den Bestand, den **dieser Slice selbst** als ungelesen ausgemessen hat (57 Lehr-Einträge
   in 32 Dateien, das Wort *Lerneintrag* nullmal in den vier sitzungsfesten Live-Artefakten).

**Einstufung.** Der Befund ist als Merge-Blocker gefallen, und die Abweichung vom Skill-Default
(*„HIGH und MEDIUM blockieren typischerweise"*) ist begründet: Modul 10 §Pflege benennt die
Folge-ADR als den vorgesehenen Träger und einen vierten Einzel-Befund ausdrücklich **nicht** als
den Weg; die Annahme einer ADR ist ein Sign-off-Akt, der weder in der DoD dieses Slice steht noch
in der Reichweite von Implementer oder Reviewer liegt; und kein Artefakt in `cmd/`, `internal/`,
`spec/`, `test/` ist berührt. Der Rest oben ist ein Vorgang **neben** slice-066, nicht in ihm — er
gehört in die Übergabe, nicht in eine Blockade.

### B4 — §3.7 ohne Geltungsbereich und Cutoff (MEDIUM) → **GEFALLEN**

Beides steht, selbst gelesen (`grep -n` gegen [`AGENTS.md`](../../AGENTS.md)):

```
136:**Geltungsbereich:** Code, Konfiguration und Skripte, **die dieses Repo besitzt**.
142:**Cutoff — ab Einführung, kein Nachrüsten.** Gebunden ist der Kommentar, der
```

Der Geltungsbereich nimmt `.harness/baseline/` aus und begründet das mit
[`MR-007`](../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
und der `scan.ignore`-Ausnahme des Doc-Gates. **Die zweite Begründung habe ich nachgeschlagen
statt geglaubt:** `.d-check.yml:6-10` trägt genau diesen Kommentar und diese Ausnahme
(*„committet vendored Baseline (MR-007) — externer, derivativer Inhalt, nicht repo-autoritativ;
vom Doc-Gate ausgenommen"*). Die Analogie trägt.

Der Cutoff bindet *„den Kommentar, der geschrieben oder geändert wird"* und stellt den Bestand
ausdrücklich frei, mit derselben Begründung wie
[`MR-015`](../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
— eine im Repo etablierte Konstruktion, keine Ad-hoc-Ausnahme. Damit ist die Frage entschieden,
die B4 offen fand: ein Agent, der `harness/tools/mutate.sh` anfasst, muss dessen Kopf **nicht**
umschreiben.

**Die Zahlen des Cutoff-Absatzes habe ich nachgerechnet** — Ergebnis in N2, kein Blocker.

---

## Die drei Nebenpunkte der Vorrunde

| # | Vorbefund | Status hier, mit Beleg |
|---|---|---|
| B5 | `slice-079` beziffert das Fall-Format mit 144 (LOW) | **gefallen.** Die Zahl ist durch eine Eigenschaft ersetzt: *„`# files:` und `# expect:` trägt **jeder** Fall … `# verify:` nur einzelne"*. Selbst gezählt: 145 Fälle, `# files:` **145/145**, `# expect:` **145/145**, `# verify:` **2**. Die Aussage ist wahr und driftet nicht mehr. Gleiche Behandlung in `slice-078` (*„Kein Fall … fasst `.claude/settings.json` an"* — selbst geprüft, 0 Treffer, Muster gegen den bekannten Treffer `32-enforce-settings-wires-guard.sh` validiert) und `slice-069` (134 → *„der gesamte Bestand"*) |
| B6 | Closure-Notiz zählt vier `span-report`-freie `Makefile`-Hunks statt drei (LOW) | **gefallen.** `slice-066-…:206` lautet jetzt *„Drei der fünf `Makefile`-Hunks"* |
| B7 | Rang-Zeiger auf die **verworfene** ADR-0011-Alternative D (INFO) | **gefallen.** `internal/report/report.go:5` nennt jetzt *„(ADR-0011 Festlegung 3)"*. Gegenprobe in der ADR: `0011-…:148` = *„Festlegung 3 — Spans liegen außerhalb des versionierten Baums"*. Der Zeiger trifft die geltende Festlegung |

**Der dritte Sachfehler (Mutations-Deckung der Closure-Notiz) ist behoben, und die neue Begründung
hält.** Die alte Fassung stützte die Gültigkeit ihres Mutations-Laufs auf eine leere Schnittmenge
der `# files:`-Ziele mit den seither geänderten Pfaden — die war nicht mehr leer. Die neue Fassung
argumentiert strukturell: *„**kein** Mutations-Fall trägt einen `docs/`-Pfad in seiner
`# files:`-Zeile"*. Selbst gemessen über alle 145 Fälle: **37** eindeutige `# files:`-Ziele,
davon **0** unter `docs/` (Muster `^docs/` gegen einen bekannten Pfad validiert). Die Aussage
trägt — und sie ist, anders als die Vorfassung, nicht an einen Zeitpunkt gebunden.

---

## Neue Befunde dieser Runde

Klar getrennt vom Obigen, mit eigener Einstufung. **Keiner davon blockiert**, und keiner kippt ein
Verdikt, das auf MEDIUM-Freiheit beruht.

### N1 — Der wiederhergestellte `regelwerk-check`-Satz trägt einen Konjunktiv über die verworfene Alternative; die Regel-Grenze dazu ist im Repo unentschieden

- `kategorie`: **LOW** — **nicht blockierend**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (*Falsch:* Konjunktiv über die verworfene
  Alternative) · Reviewer-Skill §Kontext-Eskalation (*Streit über eine Kategorisierung ⇒ Regel
  schärfen*)
- `pfad`: `Makefile:160-161`
- `befund`: Der Satz endet mit *„…, und ein zweiter Lauf ueber ihnen erzeugte nur
  Doppel-Befunde."* Beide möglichen Lesarten von *erzeugte* landen in einer der zwei
  §3.7-Falsch-Klassen: als Konjunktiv II beschreibt der Teilsatz, was die **verworfene** Variante
  produzieren würde; als Präteritum beschreibt er einen Lauf, den es nicht mehr gibt. Die
  Vorfassung des Satzes (`git show edf739d^:Makefile`) lautete *„Auf `sources` isoliert (die
  Doku-Module deckt docs-check ab)."* — rein indikativ; die Klausel ist mit der
  Wiederherstellung **neu** hinzugekommen, liegt also innerhalb des §3.7-Cutoffs.
- `warum trotzdem LOW und nicht MEDIUM`: Weil die Grenze der Regel im Repo nicht entschieden ist
  und ich sie hier nicht per Verdikt setze. Selbst gemessen —
  `grep -nE '^#.*(waere|entstuende|liefe|koennte|belegte|erzeugte|behauptete)' Makefile` liefert
  **acht** Fundstellen (`:29`, `:84-85`, `:161`, `:183`, `:216`, `:223-224`, `:236-237`); **sieben
  davon sind vorbestehend**, stammen aus `edf739d` oder davor, und die Bestätigungsrunde hat genau
  diesen Bereich als *„durchweg Indikativ …, kein Konjunktiv über eine verworfene Alternative"*
  freigegeben. Die achte allein zu verurteilen wäre inkonsistent. Was §3.7 verbietet, ist an
  seinem eigenen Beispiel ein Kommentar, dessen **Inhalt** die verworfene Alternative *ist*; ob es
  auch eine nachgestellte Begründungsklausel neben einer indikativen Kopplungsaussage trifft, sagt
  der Text nicht.
- `failure-szenario`: Ein Wartender sucht den historischen *„zweiten Lauf"* in `git` und findet
  ihn nicht — oder er verallgemeinert die Freigabe der Vorrunde und liest §3.7 als tolerant, bis
  ein späterer Lauf die sieben Altfundstellen als Bruch meldet. Der Schaden ist nicht die eine
  Klausel, sondern die unbestimmte Grenze.
- `verifizierbar`: **nein, kein Gate** — der `Makefile` liegt dauerhaft außerhalb des Prüfbereichs
  von `make comment-claims` ([`AGENTS.md`](../../AGENTS.md) §4). Der `grep` oben ist reproduzierbar.

### N2 — Die 212 des §3.7-Cutoffs reproduziert nur mit einer zweiten, dort nicht genannten Ausnahme; die 73 ist ohne genanntes Muster nicht exakt nachzählbar

- `kategorie`: **LOW** — **nicht blockierend**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (*die Zusage auf das einschränken, was der Baum
  hält*) · [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- `pfad`: `AGENTS.md:143-146`
- `befund`: Der Absatz schreibt *„von den **212** getrackten `*.go`/`*.sh`/`*.awk`/`Makefile`/
  `Dockerfile` **außerhalb von `internal/emit/templates/`** tragen **73** mindestens eine
  Kommentarzeile mit Befund-Kennung oder Herkunfts-Prosa"*. Mit **genau** der genannten Ausnahme
  gezählt: **213** (`go` 43 · `sh` 164 · `awk` 3 · `Makefile` 2 · `Dockerfile` 1). Die
  Differenz ist `.harness/baseline/v3.5.2/templates/Makefile` — die Datei fällt unter die
  Geltungsbereichs-Ausnahme des **vorhergehenden** Absatzes, die der Cutoff-Absatz nicht
  wiederholt. Mit beiden Ausnahmen: **212**, die Zahl stimmt. — Für die **73** nennt der Text kein
  Muster; drei plausible Rekonstruktionen liefern **62** (nur Befund-Kennungen), **68** (plus
  *frueher/früher*) und **125** (zusätzlich `slice-`). Die Größenordnung trägt die Aussage
  (*„ein Maßstab, der diesen Bestand mitprüfte, wäre dauerhaft rot"*) zweifelsfrei; die konkrete
  Ziffer ist nicht nachzählbar.
- `failure-szenario`: Wer den Cutoff-Absatz nachrechnet, prüft die erste Zahl, bekommt 213 statt
  212 und stellt danach auch die zweite in Frage — dieselbe Mechanik, die in der Vorrunde B5 und
  B6 erzeugt hat, nur eine Ebene weiter oben, nämlich in einer Hard Rule.
- `abgegrenzt`: Das **Datieren** der Zahl statt ihres Ersetzens ist hier richtig und nicht der
  Befund — an dieser Stelle *ist* die Ziffer das Beweismittel, wie bei den 57/32 des
  Steering-Loop-Eintrags.
- `verifizierbar`: **ja, ohne Gate** — `git ls-files` gefiltert auf die fünf Muster, einmal mit
  und einmal ohne `.harness/baseline/`.

### N3 — Die roadmap-Ersetzung „je ein knappes Dutzend Slice-IDs" trifft eine der beiden Dateien nicht

- `kategorie`: **LOW** — **nicht blockierend**
- `quelle`: Maintainability · [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage ≤ Baum)
- `pfad`: `docs/plan/planning/in-progress/roadmap.md:44` (Kandidat *Doku- und Sensor-Wartung*,
  Achse 2)
- `befund`: Die Vorfassung lautete *„neun Slice-IDs in `AGENTS.md`, sieben in `harness/README.md`,
  null in `CLAUDE.md`"*; sie ist durch *„nennen je ein knappes Dutzend Slice-IDs"* ersetzt worden.
  Selbst gezählt (`grep -o 'slice-[0-9][0-9]*' | sort -u | wc -l`): `AGENTS.md` **10** eindeutige
  / 13 Vorkommen, `harness/README.md` **7** / 7, `CLAUDE.md` **0**. Für `AGENTS.md` trägt die neue
  Formulierung, für `harness/README.md` nicht — sieben ist kein knappes Dutzend, und **sieben war
  in der Vorfassung richtig**. Die Ersetzung einer eingefrorenen Zahl durch eine Eigenschaft ist
  der richtige Zug; hier hat sie an einer von zwei Stellen Genauigkeit gekostet statt gewonnen.
  Die tragende Aussage des Satzes (*„die Asymmetrie ist der Befund, nicht ihr Betrag"*) bleibt
  richtig.
- `failure-szenario`: Wer den Kandidaten schneidet, misst nach und findet die Charakterisierung
  für eine der zwei Dateien falsch — dieselbe Vertrauensmechanik wie in N2.
- `verifizierbar`: **ja, ohne Gate** — der `grep -o … | sort -u | wc -l` oben.

### N4 — `make mutate` hängt an einer tag-gepinnten Build-Frontend-Referenz; sie ist die einzige unverdigestete Image-Referenz des Builds

- `kategorie`: **INFO** — **nicht blockierend**, und **nicht Gegenstand dieses Slice**
- `quelle`: [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ·
  [`ADR-0003`](../plan/adr/0003-go-native-binaries.md)
- `pfad`: `Dockerfile:1`
- `befund`: Beim Messen aufgefallen: `Dockerfile:1` lautet `# syntax=docker/dockerfile:1.7` — eine
  **Tag**-Referenz. Jede andere Image-Referenz des Builds ist per Digest gepinnt, selbst
  nachgesehen: alle sieben `FROM`-Zeilen (`golang@sha256:3aff66…`, `golangci-lint@sha256:5cceee…`,
  fünf abgeleitete Stages) sowie `BATS_IMAGE`, `SHELLCHECK_IMAGE`, `ACTIONLINT_IMAGE`
  (`Makefile:8-10`) und `DCHECK_REF`. Genau diese eine unverdigestete Referenz hat Anlauf 1 des
  Mutations-Laufs 36 Fälle gekostet.
- `failure-szenario`: Ein CI- oder Wartungs-Lauf ohne Registry-Erreichbarkeit meldet
  zweistellige Befundzahlen, die wie Regressionen aussehen und keine sind; wer die Detailzeilen
  nicht liest, sucht den Fehler im Code. Der Treiber druckt die Ursache mit — der Fall ist also
  diagnostizierbar, nur teuer.
- `abgegrenzt`: `make gates` ist davon **nicht** betroffen — es lief in derselben Umgebung Exit 0,
  weil sein Bau-Kontext bereits aufgelöst war; die Offline-Zusage von
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) gilt
  `gates`, und `mutate` ist Nicht-Gate-Verify. Der Punkt gehört einem Wartungs-Slice, nicht
  slice-066.
- `verifizierbar`: **ja, ohne Gate** — `head -1 Dockerfile` gegen `grep -nE '^FROM' Dockerfile`.

### N5 — `d9a62ad` trägt Implementer- und Planner-Artefakte in einem Commit; das ist die Wiederholung von B8 im Reparatur-Lauf selbst

- `kategorie`: **INFO** — **nicht blockierend**
- `quelle`: Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln · Vorrunden-Befund B8 (INFO) ·
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 3 (**Proposed**,
  Cutoff ab Annahme — **heute kein Verstoß**)
- `pfad`: Commit `d9a62ad` (`git show --stat`)
- `befund`: Derselbe Commit ändert `Makefile` und `internal/report/report.go` (Implementer) sowie
  `roadmap.md` und vier Slice-Dateien (Planner). Die Message trennt die Kontexte ausdrücklich
  (*„Implementer und Planner in getrennten Laeufen"*), der Baum tut es nicht. Von den vier
  Commits dieser Runde sind drei rollenrein (`aba99a9` Makefile + Report; `294091d` nur ADR-Datei
  und -Index; `1094c11` nur `AGENTS.md` und `conventions.md`) — der letzte nicht.
- `failure-szenario`: Ein späterer Rollen-Audit über `git log --format='%h %s' -- <pfad>` kann für
  keinen der beiden Änderungsteile belegen, aus welchem Kontext er stammt. Das ist genau die
  Eigenschaft, die ADR-0015 Festlegung 3 herstellen soll — sie ist in dem Lauf ausgeblieben, der
  die ADR schreibt, und liefert damit den ersten Datenpunkt zu ihrem
  Re-Evaluierungs-Trigger 1.
- `verifizierbar`: **nein, kein Gate** — der d-check-Modul `commits` ist in `.d-check.yml`
  `modules:` nicht aktiviert.

---

## Negativbefunde

- geprüft, ohne Befund: **`make gates`.** Exit 0, alle sieben Gate-Ausgaben oben zitiert, bats
  150 ok / 0 not ok, `record-gates` hat den Nachweis geschrieben.
- geprüft, ohne Befund: **`make mutate`.** `145 ok, 0 Befund(e)`, Exit 0 über den Baum bei
  `d9a62ad`. Der Wert der Commit-Message ist damit unabhängig bestätigt, nicht übernommen.
- geprüft, ohne Befund: **Arbeitsbaum unverändert.** `git status --porcelain` = 0 Zeilen vor und
  nach allen Läufen, einschließlich der zurückgenommenen `shell-lint`-Probe.
- geprüft, ohne Befund: **§3.7-Konformität aller in dieser Runde neu geschriebenen
  Kommentarzeilen.** Prüfbereich vollständig aufgezählt statt gestichprobt:
  `git diff b74df5d..HEAD -- Makefile internal/report/report.go | grep -E '^\+\s*(#|//)'` →
  **17 Zeilen**, einzeln gelesen. Sechzehn sind Indikativ über den Zustand und tragen Kopplung,
  Abgrenzung oder Rang-Zeiger; keine nennt eine Befund-Kennung, keine beschreibt abwesenden Text.
  Einzige Ausnahme: N1. Markdown-Artefakte (`AGENTS.md`, `conventions.md`, ADR, Pläne) liegen nach
  dem Geltungsbereich von §3.7 außerhalb.
- geprüft, ohne Befund: **§3.6 an der einzigen neuen Zusage dieser Runde.** Der
  wiederhergestellte `baseline-verify`-Satz sagt eine Kopplung zu; ihr Gegenbeispiel ist oben rot
  gesehen (`SHELL_LINT_EXIT=2`).
- geprüft, ohne Befund: **Hard Rule §3.4.** `git diff --name-only b74df5d..HEAD -- docs/plan/adr/`
  → zwei Dateien, beide **neu** bzw. eine Index-Zeile; **keine** Accepted-ADR ist geändert
  worden. Statuszeilen aller 15 ADRs selbst gelesen: 12 Accepted, 2 Superseded, 1 Proposed
  (ADR-0015). Der Slice referenziert keine superseded ADR.
- geprüft, ohne Befund: **Hard Rule §3.5.** Keine Modul-Aktivierung, keine Schwelle, kein
  `--disable`/`--enable` im Diff geändert; `regelwerk-check` trägt unverändert sechs
  `--disable`-Flags (selbst gezählt an `Makefile:163`), und der wiederhergestellte Satz beziffert
  sie korrekt.
- geprüft, ohne Befund: **Hard Rule §3.3.** `git log --diff-filter=R b74df5d..HEAD` → 0 Renames.
- geprüft, ohne Befund: **`ADR-0014`-Konformität der `MR-023`-Konstruktion.** Festlegung 2 (a)
  selbst gelesen; Teil-Aufhebung ⇒ Rumpf bleibt; der Diff ist mit 60/0 nachweislich rein additiv;
  `MR-023` steht unmittelbar hinter `MR-022`, der Zeiger liegt also **nicht** hunderte Zeilen
  unter dem, was er entwertet — der Contra-Punkt, den ADR-0014 gegen Option A führt, greift hier
  nicht.
- geprüft, ohne Befund: **Anker- und Link-Integrität der neuen Artefakte.** Der `d-check`-Lauf in
  `make gates` meldet über 299 Dateien 0 Befunde; er deckt die `MR-023`- und
  `ADR-0015`-Anker sowie die neuen Verweise aus `AGENTS.md` und dem Slice-Plan.
- geprüft, ohne Befund: **Deckungs-Argument der Closure-Notiz.** 37 eindeutige `# files:`-Ziele,
  0 unter `docs/`; die neue Begründung ist strukturell und nicht an einen Zeitpunkt gebunden.
- geprüft, ohne Befund: **die drei übrigen eingefrorenen Zahlen der Runde.** `slice-079` (145/145/2
  nachgezählt), `slice-078` (0 Treffer, Muster validiert), `slice-069` (Zahl entfernt).
- **nicht geprüft** (und deshalb nicht behauptet): (a) die DoD-Abhakung — Gegenstand der
  Verifikation. (b) Der gesamte Slice-Gegenstand jenseits der vier MEDIUM — der Auftrag ist eng
  gefasst; was die Bestätigungsrunde am 2026-08-09 als aufgelöst gemessen hat, ist hier nicht
  erneut aufgerollt. (c) Ob der gekürzte §3.7-Wortlaut die Upstream-Semantik **inhaltlich**
  vollständig trägt — geprüft ist Existenz und Platzierung, wie schon in der Vorrunde; die
  Textprüfung gehört in den Adaptions-Durchgang der Re-Baseline, und `MR-023` sagt das selbst.
  (d) ADR-0015 als **Proposed-Review** im Sinne von Modul 8 — dieser Report prüft sie als Träger
  eines Befundes, nicht als Entscheidung auf Annehmbarkeit.

## Kategorie-Summary

| Kategorie | Anzahl | davon blockierend |
|---|---|---|
| HIGH | 0 | 0 |
| MEDIUM | 0 | 0 |
| LOW | 3 (N1 · N2 · N3) | 0 |
| INFO | 2 (N4 · N5) | 0 |

Zum Vergleich: Bestätigungsrunde (2026-08-09) 0 / 4 / 2 / 2 mit vier Blockern; Erst-Review
(2026-08-08) 0 / 4 / 5 / 3.

## Verdikt

**KONFORM.** **Merge-blockierend: nein.** HIGH: keines. MEDIUM: keines.

**Alle vier blockierenden MEDIUM sind gefallen, jeder einzeln am Baum nachgemessen.** B1 mit fünf
`grep -c`-Läufen und einer rot gesehenen Probe; B2 mit einem gegen einen bekannten Treffer
validierten Muster und zwei `git show v5.3.0:`-Läufen gegen den Upstream; B4 mit zwei
`grep -n`-Läufen und der nachgeschlagenen `.d-check.yml`-Ausnahme; B3 mit der Trennung von
Schaden und Träger. Dazu sind B5, B6 und B7 aufgelöst und der dritte Sachfehler — die
Deckungs-Begründung der Closure-Notiz — durch eine strukturelle Aussage ersetzt, die ich
nachgezählt habe. **Beide Läufe sind hier real gefahren**, nicht referenziert: `make gates`
Exit 0, `make mutate` `145 ok, 0 Befund(e)`.

**Zu B3, weil es die einzige Ermessensfrage war.** Ein Proposed-Träger **bedient** die eine Hälfte
und **vertagt** die andere, und beide Hälften sind oben mit Belegen benannt. Bedient ist: der
materialisierte Schaden ist repariert, Modul 10 §Pflege nennt die Folge-ADR als den vorgesehenen
Träger, sie ist in der schreibenden Rolle und in einem rollenreinen Commit entstanden, ihre eigenen
Messungen reproduzieren, und der Annahme-Pfad ist im Repo zweimal real geübt. Vertagt ist: bis zur
Annahme bindet nichts, Folgepflicht 1 steht aus, und der Annahme-Schritt hat außer der Status-Spalte
des ADR-Index keinen lebenden Träger — der zweite Zeiger wandert mit der Closure nach `done/`.
**Das trägt keine Merge-Blockade**, und die Abweichung vom Skill-Default ist begründet: die Annahme
einer ADR steht in keiner DoD dieses Slice, liegt außerhalb der Reichweite von Implementer und
Reviewer, und Modul 10 verlangt an dieser Stelle ausdrücklich einen Träger statt eines vierten
Einzel-Findings. **Sie trägt aber eine Übergabe**, und die steht unten.

**Die Bilanz war schon in der Vorrunde grün, und sie ist es geblieben.** Von den vier
Reparatur-Commits berührt genau einer eine Datei unter `cmd/`, `internal/`, `spec/`, `test/` —
`internal/report/report.go`, und dort nur den Paket-Kommentar (B7). Der Auswerter selbst ist seit
`0f41911` unverändert und durch zehn Go-Tests und zehn Mutations-Fälle bewacht, die in meinem
eigenen Lauf sämtlich gegriffen haben.

**Was diese Runde über das Verfahren zeigt.** Drei der vier Punkte waren Sachfehler, nicht
Formfehler, und alle drei sind erst gefallen, als jemand **gegen eine benannte Version** gemessen
hat statt gegen den beweglichen Stand. Genau das ist jetzt in `AGENTS.md` §3.7 und `MR-023` als
Anforderung an eine Baseline-Aussage niedergeschrieben. Die drei LOW dieser Runde (N1, N2, N3)
sitzen alle in derselben Klasse — eine Zahl oder Formulierung, die weiter greift als ihre Messung
—, diesmal in den Reparaturen selbst. Das ist kein Grund zu blockieren; es ist ein Hinweis, dass
die Klasse mit der Regel noch nicht erledigt ist.

**Übergabe.**

- An den **Architect**: die Annahme von
  [`ADR-0015`](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) samt Folgepflicht 1
  (Hard-Rule-Text) braucht einen **lebenden** Träger, bevor `slice-066` nach `done/` zieht —
  sonst hängt der einzige inhaltliche Zeiger in einem geschlossenen Slice. N2 (die 212/73 des
  Cutoff-Absatzes) gehört demselben Eigentümer.
- An die **Implementation**: N1 (die Klausel in `Makefile:161`) — mit der Vorentscheidung, ob
  §3.7 auch nachgestellte Begründungsklauseln trifft; trifft sie sie, sind die sieben
  Altfundstellen aus N1 dieselbe Frage und **kein** Nachrüst-Auftrag (§3.7-Cutoff).
- An den **Planner**: N3 (`roadmap.md:44`).
- Ohne Nachzug: N4 und N5 sind Beobachtungen; N4 gehört einem Wartungs-Slice, N5 ist der erste
  Datenpunkt zu ADR-0015s Re-Evaluierungs-Trigger 1.

**Ist die Closure jetzt frei?** Der Closure-Trigger (§5) verlangt *„DoD vollständig; Review konform
(Modul 10) mit ausgestelltem Verdikt; Verifikation bestätigt (Modul 11); `make gates` und
`make mutate` grün"*. Drei dieser vier Bedingungen sind mit diesem Report erfüllt: das Verdikt ist
ausgestellt **und** lautet konform, und beide Läufe sind hier grün gemessen. Die DoD-Abhakung ist
nicht meine Rolle — sie hat der Verifier am 2026-08-08 bestätigt. Der Move nach `done/` und die
Closure-Notiz gehören dem Planner.

Dieser Report ersetzt keine Verifikation und überschreibt keinen Vorgänger; eine weitere Runde
bekäme eine neue Datei.
