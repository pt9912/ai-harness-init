# Slice slice-101: Die offenen Norm-Postens bekommen einen Termin — eine vergebene Schärfung wird entschieden, nicht nur genannt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Durchgang über eine abgeschlossene Liste
von acht Postens; er ist einzeln lieferbar und wartet auf keinen zweiten Slice. **(2) Gemeinsames
Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3) Auslöser
reaktiv oder gewollt?** Reaktiv: drei vergebene Postens sind gemessen nicht eingelöst (§1). Kein
Fähigkeits-Sprung — das Werkzeug lernt nichts Neues, es geht um die Regeln, nach denen dieses Repo
arbeitet. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind die Hard Rules in
[`AGENTS.md`](../../../../AGENTS.md) und der Adaptions-Block in
[`harness/conventions.md`](../../../../harness/conventions.md) **dieses** Repos. Die `AGENTS.md`
eines emittierten Repos kommt aus der vendored Vorlage und nicht aus dieser Datei
(`git grep -c 'AGENTS.template.md' internal/emit/templates.go` → **2**: der Eintrag in der
Vorlagen-Liste und der Kommentar darüber, der den Namen als Bootstrap-Abhängigkeit ausweist;
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).
Was hier geschärft wird, geht **nicht** mit; wollte man es dort haben, wäre das ein eigener Schnitt
mit eigener Abwägung.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Regel, die einen Träger benennt, der nie eintrifft, sagt einen Mechanismus zu, der nicht läuft —
dieselbe Klasse eine Ebene über dem Gate, auf der Dogfood-Ebene),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel, an der fünf der acht Postens hängen;
der siebte hängt an [`AGENTS.md`](../../../../AGENTS.md) §3.7),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (alle acht **heben** eine Beleg-Anforderung an; eine
Anhebung braucht kein ADR — die Prüfung dieser Eigenschaft je Posten gehört in den Lauf),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (Hard Rules und
Adaptions-Block schreibt der Architect — dieser Slice liefert den Termin, nicht den Text),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — der Weg, den diese Postens genommen haben),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(einer der acht Postens ist ihre dritte Setzung; zugleich die Regel, nach der jede Zahl unten neben
ihrem Kommando steht),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Jeder Posten, den eine Closure an ein Norm-Artefakt dieses Repos vergeben hat, trägt einen
Ausgang — übernommen, anders gefasst, abgelehnt oder aufgeschoben —, und der Ausgang steht dort,
wo ihn der nächste Lauf findet.**

### Die Ausgangslage: drei vergebene Postens, kein bewegtes Artefakt

Drei Closure-Notizen unter `docs/plan/planning/done/` vergeben die Trägerschaft wörtlich an den
Architect (`git grep -l '^\*\*Träger: der Architect' -- 'docs/plan/planning/done/*.md' | wc -l` → **3**:
[slice-087](../done/slice-087-emittierte-doku-tische-init-invariant.md),
[slice-093](../done/slice-093-mutations-treiber-erreicht-full-smoke.md),
[slice-094](../done/slice-094-ein-programm-ein-einstiegspunkt.md)). Die Zahl ist eine
**Untergrenze**: ob eine weitere Notiz dasselbe in anderer Formulierung tut, ist ein Urteil und
kein Muster — genau die Unterscheidung, die
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
in ihrer eigenen Begründung für dieselbe Lage trifft.

**Keiner der drei Adressaten hat sich bewegt, und das ist mechanisch:**

| Adressat | Erwarteter Ausgang laut Notiz | Stand | Kommando |
|---|---|---|---|
| [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), dritte Setzung (*erst die Eigenschaft, dann das Kommando, dann die Zahl*) | drei Setzungen | **2** | `sed -n '/^### .* — Eine Zahl im Text steht neben dem Kommando/,/^### /p' harness/conventions.md \| grep -c '^- \*\*Setzung'` |
| [`AGENTS.md`](../../../../AGENTS.md) §3.6, Aufzählung der Zusage-Träger (*der Review-Report gehört dazu*) | fünf Träger | die Vierer-Zeile steht unverändert, Treffer **1** | `sed -n '/^### 3.6/,/^### 3.7/p' AGENTS.md \| grep -c 'Doc-Kommentar, Test-Name, DoD-Punkt, Commit-Message'` |
| [`AGENTS.md`](../../../../AGENTS.md) §3.6 insgesamt (Reichweite eines Rot-Kommandos) | ein bewegter Block | letzte Bewegung **2026-08-08** | `git log -L '/^### 3.6/,/^### 3.7/:AGENTS.md' --format='%h %ad' --date=short \| grep -E '^[0-9a-f]{7} ' \| head -1` |

Dazu kommt der vierte Posten aus
[slice-100](../done/slice-100-vorlauf-nennt-den-grund.md): *ein Rot-Beleg gilt für den Eingriff,
den er wirklich gemacht hat — und was ein Eingriff bewegt, wird gemessen, nicht gelesen.* Er
adressiert dieselbe Regel und hat dieselbe Herkunft: eine Closure hat ihn formuliert, gemessen und
niemandem gegeben, der ihn ausführt.

**Und ein fünfter aus [slice-095](../done/slice-095-hook-aufschlag-gemessen.md):** *wo der
Gegenstand eine Zahl ist, tritt an die Stelle des rot gesehenen Gegenbeispiels die Frage nach der
Richtung — welche Vereinfachung der Methode verschöbe die Zahl auf die Seite, die die
Schlussfolgerung stützt, und tut sie es?* **Woran er als weiterer Posten erkannt ist:** er
adressiert dieselbe Regel wie die Postens zwei bis vier
([`AGENTS.md`](../../../../AGENTS.md) §3.6), er **hebt** wie sie eine Beleg-Anforderung an, und er
hat dieselbe Herkunft — eine Closure, die ihn formuliert, gemessen und niemandem gegeben hat.
Verschieden ist die **Achse**: jene drei handeln von einem Rot-Beleg (seine Träger · seine
Reichweite · sein Gegenstand), dieser vom Fall, in dem es **kein** Rot gibt und mit Grund keines
geben soll. Die Regel greift dort nicht — eine Feststellung über einen Messwert hat keine
Bruchstelle —, und danach verlangt nichts mehr einen Beleg zweiter Ordnung. Der gemessene Anlass:
die naheliegendste Verzerrung einer nachgebauten Latenz-Messung, das Weglassen der teuersten
Arbeit des gemessenen Programms, wurde geprüft und ausgeschlossen — an **43** von **47**
betroffenen Aufrufen einer 200er-Stichprobe
([Verifikation](../../../reviews/2026-08-25-slice-095-verify.md) §4.3). Diese Probe kam von
**einer** Rolle und stand in keinem Vorbericht; ohne Regel bleibt sie ein Zufall des Laufs.

**Und ein sechster aus
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md):** *der Text, mit dem ein Wächter
seinen Treffer begründet, ist Teil des Wächters — er wird ausschließlich im Rot ausgegeben, also
gehört zu „rot gesehen" das Lesen der Meldung und die Prüfung, ob ihre Begründung auf die Sache
zutrifft.* **Woran er als weiterer Posten erkannt ist:** er adressiert dieselbe Regel
([`AGENTS.md`](../../../../AGENTS.md) §3.6), er **hebt** wie die anderen eine Beleg-Anforderung an,
und er hat dieselbe Herkunft — eine Closure, die ihn formuliert, gemessen und niemandem gegeben hat.
Verschieden ist die **Achse**: die Postens zwei bis fünf handeln davon, **wer** einen Rot-Beleg
trägt, **wie weit** er reicht, **worüber** er geführt wird und in **welche Richtung** er fehlgehen
kann; dieser handelt von seiner **Ausgabe** — dem einzigen Artefakt des Wächters, das ein grüner
Lauf nie zu Gesicht bekommt. Der gemessene Anlass: eine neu geschriebene Fehlermeldung begründete
ihren Treffer mit einer Aussage über das Zielrepo, die dort nicht gilt — *unter diesen
Verzeichnissen lägen keine Dateien*; gemessen liegen dort sechs
(`b=$PWD/.harness/state/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null); find "$p/docs/plan/planning" "$p/docs/plan/adr" -type f | wc -l`
→ **6**). Der Wächter war richtig, seine Erklärung falsch, und gefunden hat es der Blick auf die
Ausgabe eines absichtlich roten Laufs — kein Gate: `make comment-claims` prüft, ob ein **genannter
Test existiert**, nicht ob eine Meldung zutrifft, und nimmt `_test.go` dauerhaft aus;
`make mutate` vergleicht die Ausgabe gegen `--- FAIL:` und den erwarteten Wächter-Namen, nie gegen
die Begründung daneben. **Die Fläche, mit ihrer Eigenschaft vor der Zahl** — *eine Zeichenkette, die
ein Wächter ausschließlich in seinem Fehlschlag-Zweig ausgibt*: **20** in einer einzigen neuen
Wächter-Datei (`grep -cE 't\.(Fatalf|Errorf|Fatal|Error)\(' internal/emit/agents_test.go`) und
**86** allein im Voll-E2E-Sensor (`grep -c 'FEHLER —' harness/tools/full-smoke.sh`), beide
mitwandernd. Keine davon liest ein grüner Lauf.

**Und ein siebter aus
[slice-098](../in-progress/slice-098-feldliste-ist-ausdruck-des-traegers.md):** *ein Kommentar, der
die **Kopplung** einer bewachten Menge beschreibt, ist eine stehende Anweisung an den, der diese
Menge erweitert — wer ihr ein Element hinzufügt, liest den Kommentar an der Stelle, die sie
bewacht, und kein Gate stellt ihn zu.* **Woran er als weiterer Posten erkannt ist:** er **hebt** wie
die sechs anderen eine Beleg-Anforderung an (und braucht darum kein ADR —
[`AGENTS.md`](../../../../AGENTS.md) §3.5), und er hat dieselbe Herkunft: eine Closure hat ihn
formuliert, gemessen und niemandem gegeben. **Verschieden ist die Regel**, an der er hängt: nicht
§3.6, sondern [`AGENTS.md`](../../../../AGENTS.md) §3.7 — dort ist **Kopplung** eine der fünf
Kommentar-Klassen, und dort steht, ein Kommentar schreibe *„an den, der die Stelle **ändert**"*.
Was §3.7 für das **Schreiben** eines solchen Kommentars sagt, sagt keine Regel für sein **Lesen**;
genau diese Hälfte fehlt. Der Posten ist damit die Kehrseite des sechsten: dort war der Text eines
Wächters nur im **Rot** sichtbar, hier nur im **Quelltext** — und beide Male hat ihn niemand
gelesen.

**Der gemessene Anlass.** `internal/emit/emitteddocs_test.go` trägt seit
[slice-087](../done/slice-087-emittierte-doku-tische-init-invariant.md) den Satz *„gedeckt sind die
… Emitter, die heute Dokumente schreiben … ein <nächster> fiele heraus, bis er hier steht"*.
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md) hat einen Dokumente schreibenden Emitter
hinzugefügt und die Stelle nicht angefasst: über die Datei liefen **genau zwei** Commits
(`git log --format='%h %ad %s' --date=short -- internal/emit/emitteddocs_test.go` → `b484e3a`
2026-08-25, der die Anweisung schrieb, und `b87b5f9` 2026-08-26, der ihr folgte), und der
Umsetzungs-Commit von slice-097 (`049b8a2`) ist keiner davon. Folgenlos blieb die Lücke, weil die
sechs neuen Vorlagen nur ein `make`-Ziel behaupten, das die Init-Phase wirklich schreibt
(`grep -ho 'make [a-z-]*' internal/emit/templates/agents/*.md | sort -u` → `make gates`) — ein
künftiger Anspruch wäre durch genau den Wächter nicht gefangen worden, der dafür existiert.
**Kein Gate hat es gemeldet:** `make comment-claims` nimmt `_test[.]go` dauerhaft aus
([slice-070](slice-070-comment-claims-pruefbereich.md) §1, dritte Verengung), und `make mutate`
prüft, ob ein gelisteter Wächter fällt, nie ob seine gedeckte Menge noch stimmt.

**Warum die Fläche hier eine Untergrenze ohne Muster ist.** Die Eigenschaft — *ein Kommentar, der
eine Anweisung an eine künftige Erweiterung der bewachten Menge trägt* — ist ein Urteil über Prosa.
Ein Muster darüber liefert
`git grep -nE '^[[:space:]]*(//|#).*(fiele heraus|faellt heraus|bis (er|sie|es) hier steht)' -- 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh'`
→ **2** Treffer, und davon ist **einer** eine Beschreibung statt einer Anweisung. Das Muster trennt
die Klasse also nicht einmal auf zwei Treffern — derselbe Grund, aus dem Weg (C) unten für **diesen**
Schnitt verworfen ist.

**Und ein achter, ebenfalls aus
[slice-098](../in-progress/slice-098-feldliste-ist-ausdruck-des-traegers.md):** *ein Beleg deckt den
Baum, über dem er erhoben wurde — die Closure vergleicht ihn mit dem, der geschlossen wird, statt
die Gleichheit zu unterstellen.* **Woran er als weiterer Posten erkannt ist:** er **hebt** wie die
sieben anderen eine Beleg-Anforderung an, und er hat dieselbe Herkunft — eine Closure hat ihn
formuliert und gemessen. Verschieden ist die **Achse**: die Postens zwei bis fünf handeln von den
Trägern, der Reichweite, dem Gegenstand und der Richtung eines Rot-Belegs, der sechste von seiner
**Ausgabe**, der siebte von der **Anweisung im Quelltext**; dieser vom **Baum**, über dem der Beleg
erhoben wurde.

**Der gemessene Anlass.** Die Verifikation zu jenem Slice maß über **7** neuen Mutations-Fällen
(ihr eigenes Kommando, dort §1.1), committet wurden **8**
(`git show --name-only --format= b87b5f9 -- test/mutations/ | grep -c '^test/mutations/'` → **8**);
der achte war die **Behebung eines Befundes derselben Verifikation** und damit selbst nie durch eine
Verifikations-Rolle gegangen. Beide Zahlen standen im Repo nebeneinander — `ls -1 test/mutations/*.sh | wc -l`
liefert die des Baumes —, und **nichts** hielt sie gegeneinander. Ein Nachtrag hat die Lücke für
jenen Slice geschlossen; die Klasse bleibt.

**Was diesen Posten von den sieben anderen unterscheidet: er hat einen mechanischen Unterscheider,
und der existiert bereits.** Für `make gates` löst dieses Repo genau diese Frage inhaltsbasiert —
`bash harness/tools/working-tree-hash.sh` gegen `.harness/state/gates-passed.diffsha`
([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung));
für die teuren Sensoren und für die Verifikation gibt es nichts dergleichen, und ein Ziel, an das
ein Wächter darüber hängen könnte, existiert nicht: `grep -rn 'verify-closure-notes' Makefile harness/`
→ **leer**. Der **Ausgang** dieses Postens kann deshalb ein anderer sein als bei den übrigen — eine
Regel **plus** ein Sensor statt einer Regel allein. **Den Sensor entwirft dieser Posten nicht;** er
stellt fest, dass die Kosten dafür einmal gemessen gehören, bevor die Regel entscheidet.

### Was gemessen fehlt, ist der Termin — nicht die Zuständigkeit

Die Zuständigkeit steht seit dem 2026-08-09 fest
(`git log --format='%ad' --date=short -1 04dc5f3` → **2026-08-09**, der Commit, der
[`AGENTS.md`](../../../../AGENTS.md) §3.8 anlegt) und ist in
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 verankert: Hard
Rules und Adaptions-Block schreibt der Architect. Was den drei Postens fehlt, ist ein **Anlass zu
laufen**. Zwei von ihnen tragen einen Auflösungs-Trigger, der an ein Ereignis gebunden ist, das
nicht eingetreten ist (der nächste d-check-Pin-Sprung, `grep -c 'structure' .d-check.yml` über
**0** — heute **0**); der dritte trägt keinen. In diesem Repo entsteht ein Anlass durch einen
Schnitt: der Lifecycle bewegt Slices, nicht Nennungen.

**Was dieser Slice ausdrücklich nicht tut: den Regeltext vorentscheiden.** Er stellt her, dass
jeder der acht Postens **einzeln** entschieden wird, und benennt die vier zulässigen Ausgänge. Ob
eine Schärfung in die Regel wandert, anders gefasst wird oder mit Grund fällt, entscheidet der
Architect am Text — das ist
[`AGENTS.md`](../../../../AGENTS.md) §3.8, und ein Planner, der es vorwegnähme, verschöbe nur die
Stelle, an der die Regel unbelegt entsteht.

### Die Abwägung: drei Wege, einer gewählt

- **(A) Ein Durchgang, der jeden Posten einzeln entscheidet — gewählt.** Er ist der einzige Weg,
  der die gemessene Ursache trifft: die Postens sind formuliert und begründet, es fehlt der Lauf.
  Der Preis ist ein Slice; der Gewinn ist, dass die acht Schärfungen entweder gelten oder mit
  einem Grund nicht gelten, statt weiter in Zeitdokumenten zu stehen.
- **(B) Die Postens weiter dem Architect nennen, mit besserem Auflösungs-Trigger.** Verworfen —
  die Form ist dreimal vergeben und nullmal eingelöst (§1). Ein vierter Trigger unterscheidet sich
  von den drei bisherigen nur durch seine Bedingung, nicht durch seine Wirkung.
- **(C) Einen Sensor bauen, der offene Postens meldet.** Verworfen für **diesen** Schnitt, und
  nicht wegen des Aufwands: die Menge *„Posten, dessen Träger sich nicht bewegt hat"* ist ein
  Urteil über Fließtext, kein Muster — ein Wächter darüber brauchte erst ein Kriterium. Das ist
  ein eigener Gegenstand mit eigener Abwägung, und er wird billiger, wenn erst einmal acht Postens
  ihren Ausgang haben und man sieht, welche Form die Ausgänge tatsächlich annehmen.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando einen Punkt rot färbt, steht das
dabei, statt sich hinter einem anderen zu verstecken.

- [ ] **(1) Jeder der acht Postens trägt genau einen von vier Ausgängen, und keiner bleibt
      „genannt".** Die vier Ausgänge: **übernommen** (die Regel trägt die Schärfung) ·
      **anders gefasst** (sie gilt, aber in anderer Formulierung oder an anderer Stelle) ·
      **abgelehnt** mit Grund · **aufgeschoben** mit einem Auflösungs-Trigger, der ein
      beobachtbares Ereignis nennt. Bei den ersten beiden steht der Ausgang im Norm-Artefakt
      selbst, bei den letzten beiden in §7 dieses Slice.
      **Kein Kommando färbt „jeder Posten hat einen Ausgang" rot, und das ist der Befund, keine
      Vertagung.** Die Menge der Postens ist ein Urteil über acht Closure-Notizen; das Kommando in
      §1 liefert die **Untergrenze**, nicht die Menge. Diese Hälfte trägt das Review. Was **je
      übernommenem Posten** rot färbt, steht in DoD (2).
- [ ] **(2) Was übernommen wird, ist am lebenden Artefakt messbar — je Posten ein Kommando, das
      heute den alten Wert liefert.** Die drei Kommandos und ihre heutigen Werte stehen in der
      Tabelle in §1; jeder **übernommene** Posten bewegt genau einen dieser Werte, und der neue
      Wert gehört mit seinem Kommando in die Closure-Notiz. Für den vierten, den fünften und den
      sechsten Posten ([slice-100](../done/slice-100-vorlauf-nennt-den-grund.md),
      [slice-095](../done/slice-095-hook-aufschlag-gemessen.md),
      [slice-097](../done/slice-097-rollen-typen-gehen-mit.md)) gilt dasselbe Kommando wie
      für den Reichweiten-Posten: der §3.6-Block bewegt sich oder nicht. Für den **siebten**
      ([slice-098](../in-progress/slice-098-feldliste-ist-ausdruck-des-traegers.md)) ist es ein
      anderer Block: `git log -L '/^### 3.7/,/^### 3.8/:AGENTS.md' --format='%h %ad' --date=short | grep -E '^[0-9a-f]{7} ' | head -1`
      — er hängt an §3.7, nicht an §3.6.
      Für den **achten** (ebenda) bewegt sich **keiner** der bisherigen Werte: er ist der erste
      Posten, dessen Ausgang ein neuer Eintrag im Adaptions-Block sein kann statt einer Änderung
      an §3.6/§3.7. Sein Kommando ist deshalb ein anderes —
      `grep -c '^### MR-' harness/conventions.md` → heute **26** —, und wenn er stattdessen in eine
      bestehende Regel wandert, gilt wieder das Kommando ihres Blocks.
      **Ein abgelehnter oder aufgeschobener Posten bewegt keinen Wert** — dann trägt DoD (1) ihn
      mit seinem Grund, und die Closure-Notiz sagt ausdrücklich, dass hier **nichts** gemessen
      wurde, statt das Ausbleiben als Erfolg zu lesen.
- [ ] **(3) Die acht Herkunfts-Notizen bleiben unangetastet.** `done/` ist Zeitdokument
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      §Geltungsbereich); ein Ausgang, der als Nachtrag in eine geschlossene Datei geschrieben
      wird, steht wieder an dem Ort, den kein Lauf aufschlägt — der Fehler, den dieser Slice
      behandelt, in seiner eigenen Ausführung wiederholt.
      **Rot:** `git diff --stat <basis> -- docs/plan/planning/done/` liefert eine nicht-leere
      Ausgabe; heute ist der Prüfbereich **49** Dateien mit einem Steering-Loop-Eintrag
      (`grep -rl 'Steering-Loop-Eintrag' docs/plan/planning/done/*.md | wc -l`).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) | update, **soweit übernommen** | §3.6 trägt fünf der acht Postens, §3.7 den siebten, der achte ist offen zwischen Regel und Sensor. Der Text ist Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1); dieser Slice liefert die Liste und den Termin |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update, **soweit übernommen** | die dritte Setzung von [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert), derselbe Vorbehalt |
| `docs/plan/planning/done/` | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich). DoD (3) macht daraus eine Zusage mit eigenem Rot |
| `docs/plan/adr/` | **unverändert** | alle acht Postens **heben** eine Beleg-Anforderung an; eine Anhebung ist kein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5, [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)). Ergibt der Lauf, dass ein Posten in Wahrheit eine **Senkung** enthält, greift die Rückführung aus §4 |
| `test/mutations/` | **unverändert** | die Regeln liegen im Feedforward-Quadranten; [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) sagt das über sich selbst und misst, dass `make comment-claims` keine Markdown-Datei im Prüfbereich hat. Ein Wächter über Regeltext ist Weg (C) aus §1 und ein eigener Schnitt |
| [`.harness/baseline`](../../../../.harness/baseline) und die emittierte Ebene | **unverändert** | die emittierte `AGENTS.md` kommt aus der vendored Vorlage, nicht aus dieser Datei (Kopfzeile *Ebene*) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Die Liste der Postens gehört an den Anfang des Laufs, nicht an sein Ende.** Sie steht in §1 mit
drei Kommandos und acht Herkunfts-Notizen; wer sie erweitert, erweitert sie **vor** der ersten
Entscheidung und schreibt dazu, woran er den weiteren erkannt hat. Ein Posten, der während des
Laufs auftaucht und still mitentschieden wird, macht aus der abgeschlossenen Liste eine offene.

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit.** Der
Gegenstand liegt vollständig in diesem Repo, er berührt weder Code noch die emittierte Ebene und
hängt an keiner Welle. Er wartet insbesondere **nicht** auf den d-check-Pin-Sprung, an den zwei der
drei Postens ihren Auflösungs-Trigger gebunden hatten — genau diese Bindung ist der Grund, aus dem
sie liegen geblieben sind.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn sich beim Lesen zeigt, dass ein Posten nicht in die
  bestehende Regel passt, sondern eine eigene Setzung mit eigener Begründung verlangt. Dann sind
  es zwei Slices — einer für die, die dieselbe Regel tragen, und einer für den, der es nicht tut.
- **`in-progress` → `open` (blockiert):** wenn ein Posten bei genauem Hinsehen eine **Senkung**
  enthält statt einer Anhebung. Dann verlangt er ein ADR ([`AGENTS.md`](../../../../AGENTS.md)
  §3.5), und der Slice wartet darauf, statt die Regel am ADR vorbei zu ändern.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt; je übernommenem Posten der neue Wert mit seinem Kommando, je abgelehntem oder
aufgeschobenem der Grund; Review konform (Modul 10); Verifikation bestätigt (Modul 11);
`make gates` grün; `git mv` nach `done/` als eigener Move-Commit; Closure-Notiz mit
Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: dass alle acht Postens übernommen werden.** Ein
Durchgang, dessen Erfolgskriterium die Übernahme ist, kann nur noch übernehmen; die Ablehnung mit
Grund ist ein vollwertiger Ausgang, und ohne sie wäre die Entscheidung vorweggenommen.

## 6. Risiken und offene Punkte

- **Der Regeltext hat keinen Sensor, und dieser Slice baut ihm keinen.**
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  misst das über sich selbst: `make comment-claims` hat keine Markdown-Datei im Prüfbereich, und
  `make docs-check` prüft Form, nicht Aussage. Was hier grün wird, ist die **Form** — dass jeder
  Posten einen Ausgang trägt —, nicht die Güte der Regel.
- **Die Menge der Postens ist ein Urteil, keine Messung.** Das Kommando in §1 liefert die
  Untergrenze über eine Formulierung. Wer eine weitere Notiz derselben Klasse findet, hat recht und
  nicht das Kommando; §3 sagt, wann sie noch aufgenommen werden kann.
- **Ein Durchgang, der acht Postens auf einmal entscheidet, kann sie einander angleichen.** Fünf
  hängen an derselben Regel, und die Versuchung ist, aus ihnen einen Satz zu machen. Sie sind
  verschieden: einer erweitert die **Träger** einer Zusage, einer ihre **Reichweite**, einer den
  **Gegenstand** ihres Nachweises, einer die **Richtung** seines Fehlers, einer die **Ausgabe** des
  Rot. Wer sie zusammenzieht, verliert genau die Unterscheidung, für die fünf Closures je einen
  Beleg geliefert haben.
- **Der Slice kann seine eigene Lehre wiederholen.** Sein Ergebnis ist Regeltext, und Regeltext
  ohne Träger ist der Befund, den er behandelt. Die Closure-Notiz gehört deshalb daraufhin gelesen,
  ob sie einen weiteren Posten vergibt — und wenn ja, an wen.
- **`make gates` deckt den Gegenstand nur formal.** Der Doku-Gate prüft Kennungen, Anker und Pfade;
  eine falsch geschärfte Regel wäre grün. Das ist keine Lücke dieses Slice, sondern die Grenze der
  Ebene, auf der er arbeitet.

## 7. Closure-Notiz (nach `done/`)

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

**Status:** Pflicht-Sektion bei mindestens einer berührten Sub-Area
in BF oder Hybrid. Bei reinem GF genügt der Hinweis
*"alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked
Mini-Example)"*. Optional bei reinem Refactor ohne neue
Sub-Area-Berührung. Die vier Pflichtkriterien (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand)
stehen in
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Worked Mini-Example](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#worked-mini-example-bootstrap-modus-pro-sub-area-für-einen-slice-begründen).

### Sub-Area: Norm-Artefakte dieses Repos (Hard Rules + Adaptions-Block)

Eine Sub-Area, kein zweiter Block: berührt sind [`AGENTS.md`](../../../../AGENTS.md) §3.6 und
[`harness/conventions.md`](../../../../harness/conventions.md)
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
— zwei Dateien, ein Eigentümer, eine Regel-Ebene
([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1).

- **Modus:** GF. Beide Artefakte sind in diesem Repo entstanden und wurden von Anfang an gegen den
  Kurs geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch — der Gegenstand **ist** die Konvention. Vier Setzungen greifen
  ineinander: die Eigentums-Regel ([`AGENTS.md`](../../../../AGENTS.md) §3.8), die
  Senkungs-Schranke ([`AGENTS.md`](../../../../AGENTS.md) §3.5), *„Gate-Anheben →
  Steering-Loop"* ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids))
  und der Geltungsbereich von
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  der `done/` als Zeitdokument ausnimmt und damit DoD (3) trägt.
- **Phase-Reife:** Phase 5 (Betrieb). Die Regeln laufen seit Monaten, werden von den Rollen
  gelesen und von den Reviews zitiert. Was fehlt, ist nicht Reife, sondern der Rückweg vom
  gemessenen Befund in die Regel.
- **Evidenz-/Diskrepanz-Risiko:** niedrig und gemessen — der Ist-Stand jedes Adressaten hängt an
  einem Kommando (§1, Tabelle). Das Restrisiko ist kein Mess-, sondern ein Urteils-Risiko: die
  **Menge** der Postens ist nicht mechanisch, und §6 führt sie als solche.
- **Reconciliation-Aufwand:** gering, aber nicht null. Wer §3.6 anfasst, berührt eine Regel, auf
  die viele lebende Artefakte zeigen (`git grep -c '§3.6' -- '*.md' ':(exclude)docs/reviews'
  ':(exclude)docs/plan/planning/done' | wc -l` → **41** Dateien). Sie zeigen auf die **Regel**,
  nicht auf einen Wortlaut; eine Anhebung bricht keine von ihnen, und der Doku-Gate prüft den
  Anker, nicht den Satz. Graduation-Trigger entfällt; die Sub-Area ist bereits GF.
