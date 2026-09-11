# Review — slice-126: Eine Commit-Message ohne Kennung wird rot, vor dem Commit

- **Rolle:** Reviewer · **Datum:** 2026-09-11 · **Runde:** 1
- **Prüfgegenstand:** `b8a20306..bd79e689` (die zwei Implementierungs-Commits nach dem
  `slice-mv` nach `in-progress/`) — 7 Dateien, 285 hinzugefügte Zeilen
  (`git diff b8a20306..HEAD --stat`, `git diff b8a20306..HEAD | grep -c '^+[^+]'`).
- **Plan:** [`slice-126`](../plan/planning/in-progress/slice-126-commit-message-traegt-eine-kennung.md)
- **Baum bei Review-Beginn:** `git status --porcelain` leer, HEAD `bd79e689`.
- **Kanonische Bezüge:**
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
  [`AGENTS.md`](../../AGENTS.md) §3.2, §3.5, §3.6, §3.7, §3.8, §5,
  [`ADR-0004`](../plan/adr/0004-durchsetzungs-emission.md),
  [`MR-002`](../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks),
  [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
- **Werkzeug-Sonden:** alle `docker run` gegen den in [`d-check.mk`](../../d-check.mk)
  gepinnten Digest `sha256:e31a372b…4641`, netzlos (`--network none`), Mount `:ro`,
  gegen einen Klon **außerhalb** des Repos. Kein `make gates`, kein `make mutate` gefahren.

---

## Findings

### HIGH-1 — Ein Kommentar trägt den Entstehungs-Vorgang statt der Stelle

- **kategorie:** HIGH
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.7
- **pfad:** `test/commit-msg-guard.bats:13-16`
- **befund:** Der Dateikopf enthält eine an sich selbst gerichtete Frage samt Antwort —
  `… ist am echten Repo demonstriert (Skriptkopf-BELEG unten in dieser Datei? nein: harness/README.md dokumentiert den Traeger; …)`.
  Das ist das Protokoll der Überlegung, die den Text erzeugt hat, und trägt keine der fünf
  Kommentar-Klassen (Zusage · Kopplung · Abgrenzung · Rang-Zeiger · Grenze). §3.7 bindet
  Skripte, und der Cutoff *„ab Einführung"* greift, weil der Kommentar heute geschrieben wurde.
- **verifizierbar:** nein — `make comment-claims` erreicht die Stelle nicht: sein Prüfbereich
  sind vier Pfad-Muster, `test/` liegt **dauerhaft** außerhalb
  ([`AGENTS.md`](../../AGENTS.md) §4). Kein anderes Modul liest Kommentar-Prosa.
- **klasse:** Kommentar protokolliert die eigene Entstehung

```sh
sed -n '13,16p' test/commit-msg-guard.bats
```

---

### MEDIUM-1 — Der gemessene Werkzeug-Defekt ist reproduziert, seine Ursache aber falsch benannt

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Messmethode),
  [`AGENTS.md`](../../AGENTS.md) §3.7 (Kommentar beschreibt, was da ist)
- **pfad:** [`.d-check.yml`](../../.d-check.yml):355-361 und
  [`harness/README.md`](../../harness/README.md):436
- **befund:** Beide Stellen nennen als Auslöser, dass `commits.id-patterns` eine **eigene,
  von den drei eingebauten Vorschlägen abweichende** Liste trägt. Gemessen ist die
  unterscheidende Größe eine andere: **jede nicht-leere** `id-patterns`-Liste bricht den
  `--range`-Lauf ab — auch die **verbatim** eingebauten drei Muster. Damit ist der im
  README genannte Ausweg *„der Verzicht auf `LH-*`/`MR-*` in `id-patterns`"* keine Option:
  eine verengte **explizite** Liste bricht genauso. Es funktioniert nur, den Schlüssel
  **leer** zu lassen oder ganz wegzulassen.
- **verifizierbar:** ja — die Sonden unten; jede einzeln gegen den gepinnten Digest.
- **klasse:** Diagnose nennt eine Ursache, deren unterscheidende Variable nicht isoliert wurde

Sieben Sonden, alle `--range HEAD~20..HEAD`, `FLAGS` = die `doc-commits`-Flags aus
[`d-check.mk`](../../d-check.mk):

| # | `commits:`-Block | Ergebnis |
|---|---|---|
| A | wie committet (ADR-/LH-/MR-/slice-) | `error: Range-Basis-Vorfahren nicht lesbar: object not found`, **Exit 2** |
| B | Block ganz entfernt | `1124 Datei(en) geprüft, 0 Befund(e)`, **Exit 0** |
| C | eigene Liste `- '.'` → **0 Befunde** zu erwarten | dieselbe Fehlermeldung, **Exit 2** |
| D | eigene Liste `- 'ZZZKEINTREFFER'` → **20 Befunde** zu erwarten | dieselbe Fehlermeldung, **Exit 2** |
| E | `id-patterns: []` | `0 Befund(e)`, **Exit 0** |
| F | nur `exempt-pattern`, kein `id-patterns` | `0 Befund(e)`, **Exit 0** |
| **I** | **`id-patterns` == die drei eingebauten, verbatim** (`ADR-\d{4}`, `DC-(FA-[A-Z]+\|QA)-\d+`, `slice-\d+`) | dieselbe Fehlermeldung, **Exit 2** |

**C gegen D** widerlegt zugleich die naheliegende Alternativ-Erklärung *„der Abbruch hängt
am Entstehen eines Befundes"* — beide brechen ab. **I** ist der Beleg gegen die
dokumentierte Fassung: nicht die *Abweichung* von den Vorschlägen trägt, sondern die
*Anwesenheit* einer expliziten Liste.

```sh
D=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git clone -q --local --no-hardlinks . <kopie>
# je Sonde den commits:-Block in <kopie>/.d-check.yml setzen, dann:
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$D" \
  --enable commits --disable links --disable anchors --disable ids --disable matrix \
  --disable external --disable codepaths --disable spans --disable hostpaths \
  --disable diagrams --disable versions --disable pins --disable immutable --disable vcs \
  --disable planning --disable tracked --disable targets --disable citations \
  --disable sources --disable structure --disable workflows --disable reviews \
  --range HEAD~20..HEAD
```

**Zur gewählten Konsequenz** (`doc-commits` bleibt advisory, kein CI-Range-Job): sie
trägt — der Vor-Commit-Zweig ist gemessen funktionsfähig (unten, Negativbefund N-3), und
ein Range-Job wäre heute unbaubar. **Nicht** aufgenommen ist, dass d-check ein
Nachbar-Repo desselben Nutzers ist: eine defekte Modul-Fähigkeit ist dort eine
**Anforderung**, keine Werkzeug-Grenze. Ob dieser Slice sie aufnimmt, ist eine
Planungs-Frage; dass an keiner Stelle des Diffs steht, dass die Grenze **verschiebbar**
ist, macht sie im Text zu einer festen — das ist der Befund.

---

### MEDIUM-2 — Die Block-Begründung schreibt jeden Nicht-Null-Exit der fehlenden Kennung zu

- **kategorie:** MEDIUM
- **quelle:** Maintainability (Wächter-Meldung als Teil des Wächters),
  [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- **pfad:** `.claude/hooks/pretooluse-commit-msg-guard.sh:86-90`
- **befund:** Die Bedingung ist `[ "$check_rc" -ne 0 ]`, die Begründung ein fester Satz.
  Scheitert die Prüf-Instanz aus einem **anderen** Grund als einer fehlenden Kennung —
  Bild nicht lokal und kein Netz, Docker nicht verfügbar, d-check-Aufruf-Fehler (Exit 2) —,
  blockt der Hook mit der Behauptung, die Message trage keine Kennung, **obwohl sie eine
  trägt**. Der Autor liest die Begründung, ergänzt eine zweite Kennung und wird erneut
  geblockt; die Meldung zeigt von der Ursache weg.
  Der Nachbar-Guard macht es an genau dieser Stelle anders: seine Begründung nennt
  **beide** Ursachen (*„On parse doubt the guard fails closed."*,
  `.claude/hooks/pretooluse-command-guard.sh:34-41`).
- **verifizierbar:** ja — zwei Läufe, beide unten.
- **klasse:** Wächter-Begründung nennt eine Ursache, die Bedingung deckt mehrere

```sh
# (1) reale Prüf-Instanz, gültige Kennung, unauflösbares Bild:
printf 'Rolle Reviewer: Bericht zu slice-126 -- traegt eine Kennung\n' > /tmp/m.txt
make commit-msg-check MSG=/tmp/m.txt DCHECK_DIGEST=sha256:00…00
#   -> "Run 'docker run --help' for more information"; Fehler 125; EXIT=2

# (2) derselbe Exit durch den Hook:
printf '#!/usr/bin/env bash\nexit 125\n' > /tmp/stub.sh; chmod +x /tmp/stub.sh
PRETOOLUSE_COMMIT_MSG_CHECKER=/tmp/stub.sh \
  bash .claude/hooks/pretooluse-commit-msg-guard.sh <<<'{"tool_input":{"command":"git commit -F /tmp/m.txt"}}'
#   -> {"decision":"block","reason":"Commit-Message-Datei /tmp/m.txt traegt keine
#       Traceability-Kennung (ADR-/LH-/MR-/slice-) -- siehe: make commit-msg-check MSG=/tmp/m.txt"}
```

---

### MEDIUM-3 — „spiegelt **jeden** `git commit … -F <datei> …`-Aufruf" ist gemessen zu weit

- **kategorie:** MEDIUM
- **quelle:** [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  (was der Sensor nicht sieht, gehört benannt), Slice-Plan §6 (*„was er nicht deckt, gehört
  in dieselbe Zeile wie das, was er deckt"*)
- **pfad:** [`harness/README.md`](../../harness/README.md):434
- **befund:** Der Satz sagt *„jeden … -F <datei> …-Aufruf"* und nennt als Entkommende genau
  **zwei** Formen (`-m` und `-F -`) — das liest sich als geschlossene Liste. Gemessen
  entkommen mindestens **vier weitere**, darunter der **in Anführungszeichen gesetzte
  Pfad**, also die idiomatische Schreibweise für einen Variablen-Pfad. Der Skriptkopf
  hedget mit *„kein Anspruch auf Vollstaendigkeit"*; die README-Zeile, die der Leser
  zuerst findet, tut es nicht.
- **verifizierbar:** ja — der `--match`-Modus des Hooks ist genau dafür da.
- **klasse:** Ausnahme-Aufzählung liest sich geschlossen, ist gemessen offen

```sh
for c in 'git commit -F .git/MSG' 'git commit -F "$msgfile"' "git commit -F '/tmp/a b.txt'" \
         'git commit --file=.git/MSG' 'git commit --file .git/MSG' 'git commit -qF .git/MSG' \
         'git commit -a -F .git/MSG' 'git commit -F .git/MSG && echo ok'; do
  printf '%-40s rc=%s\n' "$c" "$(bash .claude/hooks/pretooluse-commit-msg-guard.sh --match "$c" >/dev/null 2>&1; echo $?)"
done
# erkannt (rc=0): -F <pfad> · -a -F <pfad> · … && echo ok
# NICHT erkannt (rc=1): -F "$msgfile" · -F '/tmp/a b.txt' · --file=… · --file … · -qF …
```

**Der Beleg ist dieser Review-Lauf selbst.** Der Commit, der diesen Report ablegt, wurde in
der dokumentierten Konvention gesetzt — `git commit -F <datei>` — und der Hook hat ihn
**nicht gesehen**, weil der Pfad aus einer Variablen kam und deshalb in Anführungszeichen
stand. Der Wächter greift damit ausgerechnet dort nicht, wo ein Lauf den Pfad
programmatisch bildet, also im Regelfall:

```sh
bash .claude/hooks/pretooluse-commit-msg-guard.sh --match 'git commit -F "$SCR/commitmsg.txt" -q'
#   -> exit 1, keine Ausgabe (nicht erkannt)
bash .claude/hooks/pretooluse-commit-msg-guard.sh --match 'git commit -F /tmp/x/commitmsg.txt -q'
#   -> /tmp/x/commitmsg.txt, exit 0 (erkannt)
```

**Vorschlag zur Formulierung** (Über-Zusage streichen): `jeden` → die Form ohne
Anführungszeichen benennen, und die Aufzählung als Beispiele kennzeichnen statt als Liste.

---

### MEDIUM-4 — Der Träger hängt an einer Konvention, die 4 von 6 Rollen-Anweisungssätze nicht nennen

- **kategorie:** MEDIUM
- **quelle:** Slice-Plan §1 (*„färbt rot, bevor der Commit steht"* — ohne Einschränkung auf
  eine Aufrufform), [`ADR-0028`](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
- **pfad:** `.claude/agents/{architect,reviewer,validator,verifier}.md`,
  `.harness/skills/reviewer.md`
- **befund:** Die Abdeckung des Hooks ist vollständig davon abhängig, dass ein Lauf die
  Konvention *Commit via Message-Datei* befolgt. Getragen wird sie von **3** Dateien
  (`.claude/commands/*.md`); **4 von 6** `.claude/agents/*.md` nennen weder die Commit-Form
  noch zeigen sie auf `commands/`, und `.harness/skills/reviewer.md` ebenfalls nicht. Ein
  Subagenten-Lauf, der zum Committen beauftragt wird (dieser Review-Lauf ist einer), hat in
  seinem Anweisungssatz keinen Grund, `-F` statt `-m` zu wählen — dann greift der Wächter
  nie, und weder Lauf noch Repo bemerken es.
- **verifizierbar:** nein — kein Gate liest Rollen-Anweisungssätze auf diese Eigenschaft.
- **klasse:** Sensor-Abdeckung hängt an einer Konvention ohne durchgängigen Träger

```sh
git grep -c 'Commit via Message-Datei' -- .claude/ .harness/   # 3 Treffer, alle in .claude/commands/
for f in .claude/agents/*.md .harness/skills/reviewer.md; do
  printf '%-40s commit:%s commands/:%s\n' "${f##*/}" "$(grep -ci commit "$f")" "$(grep -c 'commands/' "$f")"
done   # architect/reviewer/validator/verifier: 0 und 0
```

---

### MEDIUM-5 — Vier Zahlen ohne das Kommando, das genau sie liefert, keine als „kein Erwartungswert" gekennzeichnet

- **kategorie:** MEDIUM
- **quelle:** [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 1 und Setzung 2
- **pfad:** [`harness/README.md`](../../harness/README.md):436
- **befund:** Der Absatz nennt **239 von 2098**, dazu **3** (letzte 50) und **0** (letzte 20).
  Danebensteht **ein** Kommando, und es liefert genau **eine** davon (239). Für `2098`, `3`
  und `0` steht keines (Setzung 1). Alle vier wandern mit jedem Commit, keine ist als
  **kein Erwartungswert** gekennzeichnet (Setzung 2) — `2098` ist bereits heute falsch:
  gemessen **2103**. `harness/README.md` liegt im Geltungsbereich von `MR-025`
  (lebendes, repo-eigenes Markdown-Artefakt).
- **verifizierbar:** nein — kein Modul des Doku-Gates prüft Zahl-Belege.
- **klasse:** Zahl ohne das Kommando, das genau sie liefert

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+|^(Merge |Revert )'
git log --format='%s' | grep -vcE "$RE"       # 239  (der im Text genannte Wert, trägt)
git log --format='%s' | wc -l                 # 2103 (im Text: 2098)
git log --format='%s' -50 | grep -vcE "$RE"   # 3    (trägt, kein Kommando daneben)
git log --format='%s' -20 | grep -vcE "$RE"   # 0    (trägt, kein Kommando daneben)
```

---

### LOW-1 — `make doc-commits` ist seit diesem Commit unbedienbar, ein älterer Absatz beschreibt es weiter als lauffähig

- **kategorie:** LOW
- **quelle:** Maintainability (Doku-Drift)
- **pfad:** [`harness/README.md`](../../harness/README.md), Absatz zu
  `make history-range-guard`
- **befund:** Jener Absatz führt `doc-commits` als history-lesendes Ziel, dem
  `history-range-guard` als Vorlauf-Wächter vorangeht. Mit dem neuen `commits:`-Block
  bricht `make doc-commits RANGE=<beliebig>` **immer** mit Exit 2 ab (Sonde A oben) — der
  Vorlauf-Wächter bewacht damit ein Ziel, das nicht mehr läuft. Der neue Absatz sagt
  *„bleibt darum advisory und ungenutzt für diese Zusage"*, was schwächer ist als
  *unbedienbar*.
- **verifizierbar:** ja — Sonde A.
- **klasse:** Ein Ziel wird durch eine Config-Änderung inoperabel, ohne dass sein
  Bestands-Absatz mitzieht

---

### INFO-1 — 14,5 % der Commits dieses Repos entstehen unterhalb der Hook-Ebene

- **kategorie:** INFO
- **quelle:** Maintainability
- **pfad:** `harness/tools/slice-mv.sh:193,227`; `cmd/ai-harness-init/archive_welle.go:202`
- **befund:** Beide Werkzeuge committen mit `git commit -q -m` **innerhalb** von Skript
  bzw. Binär. Der Bash-Tool-Aufruf lautet `make slice-mv …` / `make archive-welle …`, und
  der Extraktor findet darin kein `git commit` — diese Commits sind für den Hook
  strukturell unerreichbar, unabhängig von jeder Regex-Verbesserung. Praktisch folgenlos
  (die Messages tragen die Slice-Kennung by construction — 1 von 304 ohne), aber es ist die
  größte einzelne Nicht-Agenten-Commit-Klasse und im Diff nirgends benannt.
- **verifizierbar:** ja.
- **klasse:** Commit-Erzeuger unterhalb der Ebene, an der der Wächter hängt

```sh
git log --format='%s' | wc -l                            # 2103
git log --format='%s' | grep -cE '^slice-mv: '           # 304  (14,5 %)
git log --format='%s' -50 | grep -cE '^(slice-mv|archive-welle): '   # 20 von 50
# keine Erwartungswerte — beide wandern mit dem Bestand
```

---

## Negativbefunde (geprüft, ohne Befund)

- **N-1 — Verdrahtung des Hooks.** `.claude/settings.json` führt ihn als **zweiten**
  Eintrag im `"Bash"`-Matcher neben `pretooluse-command-guard.sh`; die Ausgabeform
  `{"decision":"block","reason":…}` ist die des Nachbar-Guards, kein neuer Vertrag.
  Reihenfolge und Matcher korrekt.
- **N-2 — Mutations-Fall 307.** Trifft die Stelle, die der Aufrufer benutzt (die reale
  Hook-Datei, die `settings.json` verdrahtet), und trifft **genau eine** Zeile
  (`grep -cF 'if [ "$check_rc" -ne 0 ]; then' …` → `1`; das `sed` angewandt ändert
  ausschließlich Zeile 86). `# expect:` wird vom Treiber zur **Stufen-Verengung** benutzt
  (`harness/tools/mutate.sh:847`, `narrow_sensor`), nicht als Einzeltest-Zusage — die
  bats-Stufe ist die richtige, und die invertierte Bedingung lässt
  `hook: Pruef-Instanz FAIL … -> BLOCK` fallen. Der SC2016-Nachzug in `bd79e689` ist
  korrekt: doppelte Anführungszeichen, keine Inline-Suppression
  ([`AGENTS.md`](../../AGENTS.md) §3.2).
- **N-3 — „Anwesenheit, nicht Wahrheit".** Selbst nachgemessen gegen den gepinnten Digest:
  `Behebt 0f8d1a1 aus slice-1` → **Exit 0**, obwohl `git cat-file -t 0f8d1a1` →
  `Not a valid object name`. Und beide Verdikte des Vor-Commit-Zweigs tragen: Message ohne
  Kennung → `commit-untraceable`, Exit 1; mit Kennung → Exit 0. Die Grenze steht an drei
  Orten, an denen ein Leser sie findet (README-Absatz, Makefile-Kommentar, Skriptkopf), und
  sie sagt, was gemessen ist.
- **N-4 — Kein Regress am laufenden CI-Job `adr-immutable`.** Der `vcs`/`doc-immutable`-Lauf
  mit **exakt** seinen Flags über `--range HEAD~20..HEAD` meldet mit **und** ohne den neuen
  `commits:`-Block `1124 Datei(en) geprüft, 0 Befund(e)`, Exit 0. Der Defekt aus MEDIUM-1
  ist auf das `commits`-Modul beschränkt.
- **N-5 — `exempt-targets`.** `commit-msg-check` ist in Gruppe (a) aufgenommen und erfüllt
  die engere Formulierung: es trägt einen eigenen `## `-Hilfetext mit *„NICHT in gates"*
  (`Makefile:188`) **und** ist in `harness/README.md` namentlich genannt. Die Buchführung
  im Kommentar stimmt mechanisch: 17 Namen in der Liste, 4 ausdrücklich als
  hilfetext-los ausgenommen, `13 von 17` trägt. Die Begründung (*`MSG` variiert pro
  Aufruf → kein hermetischer Prüfbereich*) steht an Ort und Stelle, im Makefile-Kommentar
  und im README. `test/targets-modul-wiring.bats` hält die Exaktheit. Keine
  Schwellen-Senkung nach [`AGENTS.md`](../../AGENTS.md) §3.5 — die Liste wächst um ein
  Nicht-Gate, sie lockert keinen Maßstab.
- **N-6 — Cutoff.** Die Entscheidung *rein prospektiv, kein historischer Cutoff-Zeitpunkt*
  trägt: der Hook sieht strukturell nur den werdenden Commit. Ich habe den Diff nach einer
  Zusage durchsucht, die mehr behauptet (ein Range-Lauf, ein Gate-Anspruch, eine Aussage
  über den Bestand) — keine gefunden; `commits` steht nicht in `modules:`, und
  `commit-msg-check` steht in keiner Prerequisite-Kette
  (`grep -n 'commit-msg-check' Makefile` → nur `.PHONY`, Kommentar, Regel).
  Einzige Schwäche ist die Zahl-Form, siehe MEDIUM-5.
- **N-7 — Auflage des Auftraggebers (keine Chronik, keine Forensik, keine Slices
  referenzieren), gemessen über die 285 hinzugefügten Zeilen.** **Null** Referenzen auf
  einen Slice als Vorgang: der einzige `slice-`Treffer ist das Muster `slice-\d+` bzw. die
  Beispiel-Message `slice-1` in der Dokumentation der `id-patterns`. **Null** Treffer für
  `Review-Befund`, `Runde N`, `früher`, `ursprünglich`, `hier stand`. Ein Grenzfall bleibt
  stehen — *„Rot gesehen … — beide Läufe stehen im Umsetzungs-Commit"*
  (`harness/README.md`:432): Lauf-Protokoll im Perfekt plus Herkunft als Nebensatz. §3.7
  bindet Markdown-Prosa **nicht** (Geltungsbereich: Code, Konfiguration, Skripte und
  Zustandsfelder lebender Register), darum kein Finding — benannt, weil es die Form ist,
  die §3.7 für Kommentare ausdrücklich verwirft.
- **N-8 — [`AGENTS.md`](../../AGENTS.md) §3.8.** Die Implementierungs-Commits berühren
  weder `AGENTS.md` noch `harness/conventions.md`
  (`git diff --name-only 73067ebc~1..HEAD | grep -cE '^(AGENTS\.md|harness/conventions)'` → `0`).
  Kein Architect-Artefakt im Implementations-Kontext.
- **N-9 — `docs-check` unabhängig nachgemessen.** Eine eigene Sonde gegen den gepinnten
  Digest über einem Klon außerhalb des Repos: `1124 Datei(en) geprüft, 0 Befund(e)`,
  Exit 0. Die neuen README-Links und Anker lösen auf.
- **N-10 — Nicht geprüft, weil nicht meine Rolle:** die DoD-Abhakung, der Gate-Lauf-Nachweis
  (`gates` EXIT 0, bats 264/264, `comment-claims` 58/0) und `make mutate` — ich habe keines
  davon gefahren. Das ist die Verifikation (Modul 11), getrennter Kontext.

---

## Kategorie-Summary

| Kategorie | Anzahl | Klassen |
|---|---|---|
| HIGH | 1 | Kommentar protokolliert die eigene Entstehung |
| MEDIUM | 5 | Diagnose ohne isolierte Variable · Wächter-Begründung nennt eine von mehreren Ursachen · Ausnahme-Aufzählung liest sich geschlossen · Sensor-Abdeckung ohne durchgängigen Konventions-Träger · Zahl ohne ihr Kommando |
| LOW | 1 | Ziel durch Config-Änderung inoperabel, Bestands-Absatz zieht nicht mit |
| INFO | 1 | Commit-Erzeuger unterhalb der Wächter-Ebene |

**Wiederkehrende Klasse für die Closure-Notiz §7:** *Eine Aussage über eine gemessene
Eigenschaft nennt die Ursache, ohne die unterscheidende Variable isoliert zu haben*
(MEDIUM-1, MEDIUM-3 in der Aufzählungs-Hälfte) — zweimal in diesem Diff, beide Male so,
dass ein nachfolgender Lauf auf eine Option baut, die nicht existiert.

---

## Verdikt

**Blockierender Befund: ja.**

Der Kern des Slice trägt: der Vor-Commit-Zweig ist gemessen funktionsfähig in beiden
Verdikten, die Verdrahtung ist korrekt, der Mutations-Zahn sitzt an der Stelle, die der
Aufrufer benutzt, `adr-immutable` ist nicht regressiert, und die Grenze *Anwesenheit statt
Wahrheit* ist an drei Orten richtig benannt. Die gewählte Konsequenz beim Range-Lauf ist
die richtige.

Blockierend sind HIGH-1 (Hard Rule §3.7, kein Gate fängt es) und von den MEDIUMs
insbesondere MEDIUM-1: die dokumentierte Ursache des Werkzeug-Defekts ist gemessen falsch,
und der dort genannte Ausweg existiert nicht — der nächste Lauf, der den CI-Range-Job
aufnimmt, würde daran scheitern. MEDIUM-2 und MEDIUM-3 sind Über-Zusagen im Wortlaut, beide
durch Umformulierung heilbar; MEDIUM-4 und MEDIUM-5 sind benennbar, ohne den Slice zu
dehnen.

**Übergabe an den Verifier: noch nicht.** Zurück an die Implementation; danach ist eine
zweite Review-Runde nötig, weil MEDIUM-1 eine Text-Korrektur an zwei Fundorten verlangt,
deren Richtigkeit selbst wieder gemessen sein muss.
