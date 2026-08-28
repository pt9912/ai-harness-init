# Slice slice-101: Die offenen Norm-Postens bekommen einen Termin — eine vergebene Schärfung wird entschieden, nicht nur genannt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Harness-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Durchgang über eine abgeschlossene Liste
von zwölf Postens; er ist einzeln lieferbar und wartet auf keinen zweiten Slice. **(2) Gemeinsames
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
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel, an der sechs der zwölf Postens hängen;
der siebte hängt an [`AGENTS.md`](../../../../AGENTS.md) §3.7, der neunte an keiner Hard Rule,
sondern an der Form des Slice-Plans, der zehnte am Adaptions-Block; der elfte hängt wieder an
§3.6, der zwölfte wieder am Adaptions-Block),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (zehn der zwölf **heben** eine Beleg-Anforderung an, der
neunte eine an die Plan-Form, der zehnte eine an die Erhebung einer Zahl; eine Anhebung braucht
kein ADR — die Prüfung dieser Eigenschaft je Posten gehört in den Lauf),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 und
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (Hard Rules und
Adaptions-Block schreibt der Architect — dieser Slice liefert den Termin, nicht den Text),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — der Weg, den diese Postens genommen haben),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(**drei** der zwölf Postens adressieren sie — der erste als dritte, der zehnte als weitere Setzung,
der zwölfte als Frage an ihren §Geltungsbereich;
zugleich die Regel, nach der jede Zahl unten neben ihrem Kommando steht),
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
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md), hier in der weiteren Fassung, die
[slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) gemessen hat:** *der Text, mit dem
ein Artefakt seinen Fall begründet, ist Teil dessen, was es zusagt — ein Wächter über seiner
**Anwesenheit** belegt die Zeichenkette, nicht die Ursache; zu „rot gesehen" gehört deshalb das
Lesen der Begründung und die Prüfung, ob sie auf den Zustand zutrifft, der sie ausgelöst hat.*
**Woran er als weiterer Posten erkannt ist:** er adressiert dieselbe Regel
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

**Warum dieser Posten heute weiter gefasst ist als bei seiner Formulierung — gemessen, nicht
umformuliert.** Seine erste Fassung setzte voraus, die Begründung werde *„ausschließlich im Rot"*
ausgegeben. Der Lauf zu [slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) hat **drei**
Instanzen derselben Klasse in **einem** Slice gefunden
(`grep -c '^### V-.*(MEDIUM)' docs/reviews/2026-08-26-slice-099-verify.md` → **3**, mitwandernd),
und **zwei** davon liegen im **grünen** Pfad: es sind Sätze, die das emittierte Produkt einem
Adopter über seinen eigenen Zustand sagt, und kein roter Lauf bringt sie je zu Gesicht. Die
Prämisse trennt die Klasse also nicht. Die zweite Hälfte der Weitung ist die Sensor-Form: für die
Sätze dieses Bestands existieren **Anwesenheits**-Wächter, und ein Anwesenheits-Wächter kann die
Begründung nicht prüfen — er belegt, dass die Zeichenkette da ist. Beispiel, gemessen: der Satz
*„ein erneuter Lauf des Werkzeugs legt ihn wieder ab"* hat einen Anwesenheits-Zahn
(`grep -n 'erneuter Lauf des Werkzeugs legt ihn wieder ab' harness/tools/full-smoke.sh` → **eine**
Zeile in der Prüfschleife) und **keinen** über seiner Wahrheit. Der Unterschied zwischen beiden ist
genau die Lücke, die dieser Posten schließen soll.

**Und ein siebter aus
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md):** *ein Kommentar, der
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
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md):** *ein Beleg deckt den
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

**Und ein neunter aus [slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) — der erste,
der nicht aus einer Formulierung, sondern aus einer Wiederholung kommt:** *die Plan-Tabelle §3
nennt, was ein Slice liefert; sie muss jede Datei nennen, die der Lauf **anlegt** oder **bewegt** —
auch den Träger, der beim Bauen als eigene Datei aus einer geplanten Zelle herausfällt, und die
bestehende gemeinsame Stelle, die ein neuer Wächter bewegen muss, um dort anzusetzen.* **Woran er
als weiterer Posten erkannt ist:** er
**hebt** wie die acht anderen eine Anforderung an ein Norm-Artefakt dieses Repos an, und er hat
dieselbe Herkunft — Closures, die ihn formuliert, gemessen und niemandem gegeben haben.
Verschieden ist der **Adressat**: die Postens zwei bis acht hängen an
[`AGENTS.md`](../../../../AGENTS.md) §3.6/§3.7, dieser an der **Form des Plans** — sein Ausgang ist
ein Eintrag im Adaptions-Block, nicht eine Schärfung einer Hard Rule.

**Der gemessene Anlass ist eine Dreier-Reihe, und genau die ist die Schwelle.** Modul 10
§Ziel-Form (Reviewer-Skill, Punkt *Pflege (Steering-Loop)*) verlangt wörtlich *„bei dreimaligem
gleichem Finding Klassifikation schärfen / Folge-ADR bzw. `AGENTS.md`-Update / Gate"*
(`grep -n 'dreimaligem gleichem Finding' .harness/baseline/v3.5.2/regelwerk/modul-10-review-harness.md`).
Die Reihe: [slice-097](../done/slice-097-rollen-typen-gehen-mit.md) sauber ·
[slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md) einmal (eine Datei) ·
[slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) erneut, diesmal **fünf** Dateien
außerhalb der Tabelle. Gemeinsam ist diesen dreien: es sind **Test-Infrastruktur-Umbauten**, die ein
neuer Wächter erzwingt — eine Signatur, die von `[]string` auf `map[string]string` wechselt, ein
extrahierter Helfer, eine re-verankerte Mutation.

**Die vierte Instanz hat die Fassung des Postens geweitet, und sie war der Gegenbeleg zu seiner
eigenen Begründung.** [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) ist
der erste danach geschnittene Slice mit einem neuen Wächter — genau die Messung, die DoD (2) unten
verlangt. Außerhalb seiner §3-Tabelle liegen **zwei** Dateien
(`git show --name-status --format= f959912 ae00252 | sort -u` → **9** Zeilen über **8** Dateien,
davon nennt §3 zwei nicht), und **keine** von beiden ist eine bewegte Bestandsstelle: beide sind
**neu angelegt**, und eine davon —
[`harness/tools/full-smoke-ausgang.sh`](../../../../harness/tools/full-smoke-ausgang.sh) — ist der
Träger der Sache selbst, aus der geplanten Zelle *„`full-smoke.sh` update"* herausgefallen. Die
erste Fassung des Postens hätte diesen Fall **nicht** gefangen; die Symptom-Klasse (*eine Datei im
Diff, keine Zeile in §3*) fängt ihn. Deshalb ist der Posten **geweitet**, nicht verdoppelt: ein
weiterer Posten mit demselben Adressaten, demselben Ausgang und demselben Kommando in DoD (2) wäre eine
Zweitfassung, die driftet.

**Warum eine Regel und kein Sensor — und diesmal ist die Antwort gemessen, nicht geschätzt.** Die
naheliegende Mechanik wäre, die Dateiliste eines Umsetzungs-Commits gegen die Pfade der §3-Tabelle
zu halten. Sie trägt nicht: die Zellen nennen **Komponenten**, nicht Dateien — von den fünf Zeilen
in [slice-099](../done/slice-099-leser-und-aufraeum-kommando.md) §3 ist genau **eine** ein
Dateipfad, die übrigen sind Verzeichnisse oder Verzeichnis-plus-Zweck. Ein Präfix-Vergleich wäre
für alle fünf ungenannten Dateien **grün** (sie liegen sämtlich unter `internal/emit` bzw.
`test/mutations/`), ein Vergleich auf exakte Pfade für fast jede Zeile **rot**. Das ist genau das
stille Grün, gegen das
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
geschrieben ist — ein Wächter, der grün ist, weil er die falsche Frage stellt.

**Und ein zehnter aus
[slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md):** *ein Kommando, das in
demselben Artefakt steht, dessen Bestand es misst, zählt seine eigene Erwähnung mit — die Zahl
gehört deshalb erhoben, **nachdem** das Kommando geschrieben ist, und mit genau der Fassung, die
dort steht.* **Woran er als weiterer Posten erkannt ist:** er **hebt** wie die neun anderen eine
Anforderung an ein Norm-Artefakt dieses Repos an (und braucht darum kein ADR —
[`AGENTS.md`](../../../../AGENTS.md) §3.5,
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
und er hat dieselbe Herkunft: eine Closure hat ihn formuliert, gemessen und niemandem gegeben.
**Verschieden ist die Achse, und sie ist neu in dieser Liste:** die Postens zwei bis acht handeln
von einem Rot-Beleg — seinen Trägern, seiner Reichweite, seinem Gegenstand, der Richtung seines
Fehlers, seiner Ausgabe, der Anweisung im Quelltext und dem Baum, über dem er erhoben wurde —, der
neunte von der Form der Plan-Tabelle. Keiner handelt von der **Rückwirkung des Messens auf das
Gemessene**. Sein Adressat ist damit derselbe wie beim ersten Posten:
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
und zwar als **weitere Setzung** — die Regel, die Zahl und Kommando in dasselbe Artefakt zwingt,
erzeugt die Fehlerquelle, die hier zu behandeln ist.

**Der gemessene Anlass.** Der Kopf von
[`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) trägt die Probe auf eine
Abdeckungs-Zusage als Gleichung; ihr letzter Term zählt die Einordnungen derselben Datei. Mit dem
Aufschreiben enthielt die Datei den gesuchten String ein zusätzliches Mal:
`grep -c 'einordnen "' harness/tools/full-smoke.sh` → **25** gegen eine Menge von **24**; die 25.
Fundstelle ist die Gleichung selbst (`grep -n 'einordnen "' harness/tools/full-smoke.sh | head -1`
→ Zeile **47**). Behoben ist es durch einen Anker
(`grep -cE '^[[:space:]]*einordnen "' harness/tools/full-smoke.sh` → **24**); gefunden hat es kein
Gate, sondern das erneute Fahren des Kommandos **nach** dem Schreiben. Beide Zahlen wandern mit der
Datei und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Fläche, mit ihrer Eigenschaft vor der Zahl.** Die Eigenschaft: *ein Kommando, dessen
Prüfbereich den Text enthält, der es zitiert*. **Zwei** Fundorte tragen sie mit Beleg — dieser und
der Watcher-Selbstmatch in [slice-045a](../done/slice-045a-hexslice-go-renderer.md)
(`grep -c 'Watcher-Selbstmatch' docs/plan/planning/done/slice-045a-hexslice-go-renderer.md` → **1**:
ein `pgrep -f`-Muster, das die eigene Prozesszeile traf und den Watcher nie terminieren ließ). Ein
dritter Fall — eine Fenster-Prüfung, die `make gates` in ihrer eigenen Kommandozeile traf — ist
berichtet, **ohne dass ein Kommando einen Fundort liefert**; das steht hier, statt ein ungefähr
passendes danebenzustellen
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). **Untergrenze, mit Absicht:** ob eine Zählung ihre eigene Erwähnung trifft, ist ein
Urteil über den Prüfbereich und kein Muster.

**Und ein elfter aus
[slice-105](../done/slice-105-mutate-messen-dann-teilen.md):** *eine Vollständigkeits-Zusage
misst die Menge, über die sie spricht, nicht den Behälter, in dem diese Menge liegt — wer „N von M"
schreibt, zählt N aus den Einträgen, die er wirklich gelesen hat, und M aus dem Bestand, gegen den
er zusagt.* **Woran er als weiterer Posten erkannt ist:** er adressiert dieselbe Regel wie die
Postens zwei bis sechs ([`AGENTS.md`](../../../../AGENTS.md) §3.6), er **hebt** wie sie eine
Beleg-Anforderung an (und braucht darum kein ADR — [`AGENTS.md`](../../../../AGENTS.md) §3.5), und
er hat dieselbe Herkunft: eine Closure hat ihn formuliert, gemessen und niemandem gegeben.
**Verschieden ist die Achse:** die Postens zwei bis acht handeln von einem Rot-Beleg — seinen
Trägern, seiner Reichweite, seinem Gegenstand, der Richtung seines Fehlers, seiner Ausgabe, der
Anweisung im Quelltext und dem Baum —, der neunte von der Form der Plan-Tabelle, der zehnte von der
Rückwirkung des Messens auf das Gemessene. Keiner handelt von der **Bezugsmenge**: davon, dass
zwischen dem, was ein Wächter zählt, und dem, worüber seine Zusage spricht, ein **Behälter** liegen
kann — eine Datei, ein Glob, ein Verzeichnis —, und dass ein Zähler über dem Behälter grün ist,
während die Menge darin unvollständig ist.

**Der gemessene Anlass, und er liegt im Sensor der Sensoren.** `merge_report` in
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) zählte einen Fall als bestanden,
sobald seine Statusdatei **existierte**; `report_times` nahm den Nenner seiner Bilanz aus demselben
Glob. Eine leere Statusdatei ergab damit die Zeile *„Vollstaendigkeit — 3 von 3 Fall-Dateien mit
Ergebnis, jede Fall-ID genau einmal gezogen"* über einer Bilanz, die darunter `n=2` summierte —
hergestellt und gemessen in der [Verifikation](../../../reviews/2026-08-27-slice-105-verify.md)
§2.5 und im [Code-Review](../../../reviews/2026-08-27-slice-105-review.md) F-1. **Kein Gate hat es
gemeldet, und der Sensor, dem es passierte, ist selbst ein Gate-Wächter:** `make mutate` war grün,
weil sein Mutations-Fall `191` den **Datei**-Pfad bewachte und nicht den Inhalt. Behoben ist es in
`0e76c77` (`status_line_valid` prüft die Zeile, `collect_status` ist die eine Quelle für beide
Leser) — die **Klasse** bleibt.

**Die Fläche, mit ihrer Eigenschaft vor der Zahl.** Die Eigenschaft: *ein Zähler, der seinen Wert
aus einem Behälter nimmt statt aus der Menge, über die die Zusage daneben spricht*. **Zwei**
Fundorte tragen sie mit Beleg, beide in derselben Datei und beide aus demselben Commit. Ein Muster
darüber liefert `grep -rn '\${#[a-z_]*\[@\]}' harness/tools/*.sh | wc -l` → **11** Treffer über
**3** Dateien (`grep -rln … | wc -l`) — die meisten davon sind Ober- oder Untergrenzen-Prüfungen
und gar keine Vollständigkeits-Nenner. **Das Muster trennt die Klasse also nicht**, und die zwei
Fundorte sind eine **Untergrenze mit Absicht**: ob ein Zähler den Behälter oder die Menge misst,
ist ein Urteil über den Zusammenhang von Zähler und Zusage, kein Muster — derselbe Grund, aus dem
Weg (C) unten für **diesen** Schnitt verworfen ist.

**Und ein zwölfter aus
[slice-128](../in-progress/slice-128-d-check-kopf-sagt-was-gilt.md):** *die Pflicht, eine Zahl
neben das Kommando zu stellen, das sie liefert, bindet nach ihrem eigenen Kommando nur **lebende
Markdown-Artefakte** — an einem Kommentar in Code oder Konfiguration greift sie nicht, auch dann
nicht, wenn eine Adaption genau diesen Kommentar als ihren Geltungsbereich führt.* **Woran er als
weiterer Posten erkannt ist:** er **hebt** wie die elf anderen eine Anforderung an ein
Norm-Artefakt dieses Repos an (und braucht darum kein ADR —
[`AGENTS.md`](../../../../AGENTS.md) §3.5,
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
und er hat dieselbe Herkunft: eine Closure hat ihn formuliert, gemessen und niemandem gegeben.
**Verschieden ist die Achse, und sie ist die einzige dieser Art:** die Postens zwei bis acht
handeln von einem Rot-Beleg — seinen Trägern, seiner Reichweite, seinem Gegenstand, der Richtung
seines Fehlers, seiner Ausgabe, der Anweisung im Quelltext und dem Baum —, der neunte von der Form
der Plan-Tabelle, der zehnte von der Rückwirkung des Messens auf das Gemessene, der elfte von der
Bezugsmenge. Alle handeln davon, **was** eine Regel verlangt; dieser davon, **wo** sie es verlangt.
Sein Adressat ist derselbe wie beim ersten und zehnten Posten:
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
hier aber am **§Geltungsbereich** statt an einer Setzung.

**Der gemessene Anlass, und er ist eine Fünfer-Reihe an einem Tag.** Fünf Stellen, an denen ein
Kommando neben einer Aussage steht und ihren Gegenstand nicht schneidet — vier davon in
[`d-check.mk`](../../../../d-check.mk) (ein Kommando mit Make-Syntax, das in einer Shell `1` bei
Exit 0 liefert; ein `git grep -c`, das je Datei zählt statt zu summieren; ein Zähler über Hunks
statt über Handgriffe) und eine in einem Slice-Plan (ein DoD-Rot-Kommando, das die Existenz eines
Eintrags misst, während die Zusage den Zeiger betrifft). Vier Rollen-Durchgänge über zwei Slices
haben sie gefunden, kein Gate. **Die Datei liegt außerhalb beider Prüfmengen** — gemessen:
`git ls-files '*.md' ':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**' | grep -c 'd-check.mk'`
→ **0** (der Geltungsbereich des Eintrags, dort per Kommando definiert) und
`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | grep -c 'd-check.mk'`
→ **0** (der Prüfbereich von `make comment-claims`) —, während
[`MR-027`](../../../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt)
denselben Kopfkommentar an **5** Stellen als Gegenstand führt
(`awk '/^### MR-027/,/^## Modus-Deklaration/' harness/conventions.md | grep -c 'd-check.mk'`) <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) -->.

**Die Fläche, mit ihrer Eigenschaft vor der Zahl.** Die Eigenschaft: *eine Kommentarzeile in einer
repo-eigenen Nicht-Markdown-Datei, die ein Kommando führt*. **Obergrenze, kein Erwartungswert**:
**214** Zeilen über **73** Dateien, ausgegeben von
`git grep -cE '^[[:space:]]*(#|//).*(git (grep|ls-files|show|log|diff)|grep -|docker run|make [a-z-]+|wc -l)' -- '*.go' '*.sh' '*.awk' '*Makefile' '*.mk' 'Dockerfile' ':!internal/emit/templates' ':!.harness/baseline' | awk -F: '{s+=$2} END{print "Zeilen="s" Dateien="NR}'`.
**Und die zwei mechanisch trennscharfsten Muster trennen die Klasse nicht** — das ist die Messung,
die Weg (C) auch für diesen Posten schließt:
`git grep -nE '^[[:space:]]*#.*\$\([A-Z_]+\)' -- '*Makefile' '*.mk' ':!.harness/baseline'` → **3**
Zeilen, davon **0** Instanzen (zwei Prosa-Nennungen, eine ist die Zeile, die den Fehler benennt);
`git grep -nE '^[[:space:]]*(#|//).*git grep -c' -- '*.go' '*.sh' '*Makefile' '*.mk' ':!.harness/baseline'`
→ **1** Zeile, und das ist das Gegenbeispiel im selben Kopf. Ein Wächter dieser Bauart stünde auf
dem Artefakt rot, das die Regel aufschreibt.

### Was gemessen fehlt, ist der Termin — nicht die Zuständigkeit

Die Zuständigkeit steht seit dem 2026-08-09 fest
(`git log --format='%ad' --date=short -1 04dc5f3` → **2026-08-09**, der Commit, der
[`AGENTS.md`](../../../../AGENTS.md) §3.8 anlegt) und ist in
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 verankert: Hard
Rules und Adaptions-Block schreibt der Architect. Was den drei Postens fehlt, ist ein **Anlass zu
laufen**. Zwei von ihnen tragen einen Auflösungs-Trigger, der an ein Ereignis gebunden ist; der
dritte trägt keinen. In diesem Repo entsteht ein Anlass durch einen Schnitt: der Lifecycle bewegt
Slices, nicht Nennungen.

**Eines der zwei Ereignisse ist inzwischen eingetreten, und der Posten hat sich trotzdem nicht
bewegt — das ist der schärfste Beleg für Weg (A) unten.**
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Auflösungs-Trigger ist der **einzige** nicht permanente Eintrag des Adaptions-Blocks
(`grep -c 'nicht permanent' harness/conventions.md` → **1**) und macht sich am
d-check-Pin-Sprung fällig. Der ist am 2026-08-28 mit
[slice-122](../done/slice-122-d-check-pin-v0650.md) gezogen worden
(`grep -n '^DCHECK_IMAGE' d-check.mk` → `v0.65.0`, `make freshness-dcheck` → Exit 0). **Der
Trigger benennt seinen eigenen Träger**, und der hat nicht getragen: *„der Slice, der den Pin
zieht, schlägt diesen Block ohnehin auf"* — er tat es nicht.
`git grep -c 'MR-025' 3ce4ea3 -- '*slice-122-*.md'` ist **leer**, Exit 1 <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) -->
über den Plan; `git log -1 --format=%B 3ce4ea3 | grep -c 'MR-025'` → **0** <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) -->
über die Umsetzungs-Message. Beide sind **an `3ce4ea3` festgemacht**: der Plan trägt seit seiner
Closure-Notiz den Eintrag selbst, ein Lauf über dem heutigen Baum fände sich also selbst.
Aufgefallen ist es einer **zweiten Rolle** (Modul 10,
[Review](../../../reviews/2026-08-28-slice-122-review.md) MEDIUM-2), nicht dem schreibenden Lauf.
Das zweite Ereignis steht weiter aus (`grep -c 'structure' .d-check.yml` → **0**). Damit ist Weg
(B) nicht mehr nur unbelegt, sondern **einmal gemessen widerlegt**: ein Auflösungs-Trigger, der
seinen Träger selbst benennt, ist gefeuert und hat nichts ausgelöst. Was er hinterlässt, ist eine
**fällige Entscheidung ohne Termin** — genau der Gegenstand dieses Slice.

**Was dieser Slice ausdrücklich nicht tut: den Regeltext vorentscheiden.** Er stellt her, dass
jeder der zwölf Postens **einzeln** entschieden wird, und benennt die vier zulässigen Ausgänge. Ob
eine Schärfung in die Regel wandert, anders gefasst wird oder mit Grund fällt, entscheidet der
Architect am Text — das ist
[`AGENTS.md`](../../../../AGENTS.md) §3.8, und ein Planner, der es vorwegnähme, verschöbe nur die
Stelle, an der die Regel unbelegt entsteht.

### Die Abwägung: drei Wege, einer gewählt

- **(A) Ein Durchgang, der jeden Posten einzeln entscheidet — gewählt.** Er ist der einzige Weg,
  der die gemessene Ursache trifft: die Postens sind formuliert und begründet, es fehlt der Lauf.
  Der Preis ist ein Slice; der Gewinn ist, dass die zwölf Schärfungen entweder gelten oder mit
  einem Grund nicht gelten, statt weiter in Zeitdokumenten zu stehen.
- **(B) Die Postens weiter dem Architect nennen, mit besserem Auflösungs-Trigger.** Verworfen —
  die Form ist dreimal vergeben und nullmal eingelöst (§1). Ein vierter Trigger unterscheidet sich
  von den drei bisherigen nur durch seine Bedingung, nicht durch seine Wirkung.
- **(C) Einen Sensor bauen, der offene Postens meldet.** Verworfen für **diesen** Schnitt, und
  nicht wegen des Aufwands: die Menge *„Posten, dessen Träger sich nicht bewegt hat"* ist ein
  Urteil über Fließtext, kein Muster — ein Wächter darüber brauchte erst ein Kriterium. Das ist
  ein eigener Gegenstand mit eigener Abwägung, und er wird billiger, wenn erst einmal zwölf Postens
  ihren Ausgang haben und man sieht, welche Form die Ausgänge tatsächlich annehmen.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). Wo kein Kommando einen Punkt rot färbt, steht das
dabei, statt sich hinter einem anderen zu verstecken.

- [ ] **(1) Jeder der zwölf Postens trägt genau einen von vier Ausgängen, und keiner bleibt
      „genannt".** Die vier Ausgänge: **übernommen** (die Regel trägt die Schärfung) ·
      **anders gefasst** (sie gilt, aber in anderer Formulierung oder an anderer Stelle) ·
      **abgelehnt** mit Grund · **aufgeschoben** mit einem Auflösungs-Trigger, der ein
      beobachtbares Ereignis nennt. Bei den ersten beiden steht der Ausgang im Norm-Artefakt
      selbst, bei den letzten beiden in §7 dieses Slice.
      **Kein Kommando färbt „jeder Posten hat einen Ausgang" rot, und das ist der Befund, keine
      Vertagung.** Die Menge der Postens ist ein Urteil über elf Closure-Notizen; das Kommando in
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
      ([slice-098](../done/slice-098-feldliste-ist-ausdruck-des-traegers.md)) ist es ein
      anderer Block: `git log -L '/^### 3.7/,/^### 3.8/:AGENTS.md' --format='%h %ad' --date=short | grep -E '^[0-9a-f]{7} ' | head -1`
      — er hängt an §3.7, nicht an §3.6.
      Für den **achten** (ebenda) bewegt sich **keiner** der bisherigen Werte: er ist der erste
      Posten, dessen Ausgang ein neuer Eintrag im Adaptions-Block sein kann statt einer Änderung
      an §3.6/§3.7. Sein Kommando ist deshalb ein anderes —
      `grep -c '^### MR-' harness/conventions.md` → heute **26** —, und wenn er stattdessen in eine
      bestehende Regel wandert, gilt wieder das Kommando ihres Blocks.
      Für den **neunten** ([slice-099](../done/slice-099-leser-und-aufraeum-kommando.md)) gilt
      dasselbe Kommando wie für den achten: sein Ausgang ist ein Eintrag im Adaptions-Block über
      die Form der Plan-Tabelle §3, keine Änderung an §3.6/§3.7. **Seine zweite Hälfte ist eine
      Messung am nächsten Slice, nicht am Norm-Text:** wird er übernommen, trägt der erste danach
      geschnittene Slice mit einem neuen Wächter eine §3-Zeile für jede Datei, die er anlegt oder
      bewegt. Diese Messung ist **einmal gefahren** und **rot** ausgegangen: in
      [slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md) fehlen zwei neu
      angelegte Dateien in der Tabelle (§1). Ein zweiter Slice nach der Übernahme misst, ob die
      Regel wirkt.
      Für den **zehnten** ([slice-106](../done/slice-106-rotes-ci-traegt-seinen-ausgang.md))
      gilt wieder das Kommando des ersten Postens
      (`sed -n '/^### .* — Eine Zahl im Text steht neben dem Kommando/,/^### /p' harness/conventions.md | grep -c '^- \*\*Setzung'`
      → heute **2**): sein Ausgang ist eine weitere Setzung in
      [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
      **Wird er zusammen mit dem ersten übernommen, bewegt sich derselbe Wert zweimal** — dann
      gehört in die Closure, **welche** Setzung welcher Posten ist, statt einer Zahl, die beide
      trägt.
      Für den **elften** ([slice-105](../done/slice-105-mutate-messen-dann-teilen.md)) gilt
      wieder das Kommando des Reichweiten-Postens: der §3.6-Block bewegt sich oder nicht. **Er
      trifft damit denselben Wert wie der zweite bis sechste** — auch hier gehört in die Closure,
      welche Bewegung welcher Posten ist, statt einer Zahl für sechs.
      Für den **zwölften** ([slice-128](../in-progress/slice-128-d-check-kopf-sagt-was-gilt.md))
      trägt der Setzungs-Zähler des ersten Postens **nicht**: sein Gegenstand ist der
      §Geltungsbereich, und der kann sich ändern, ohne dass eine Setzung hinzukommt. Sein Kommando
      ist deshalb die Bewegung des Blocks selbst —
      `git log -L '/^### MR-025/,/^### MR-026/:harness/conventions.md' --format='%h %ad' --date=short | grep -E '^[0-9a-f]{7} ' | head -1` <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf die Einträge) -->
      → heute `aa32e1f 2026-08-28`. **Landet er stattdessen als weitere Setzung**, bewegt er den
      Zähler des ersten und zehnten Postens; dann gehört in die Closure, welche Setzung welcher
      Posten ist.
      **Ein abgelehnter oder aufgeschobener Posten bewegt keinen Wert** — dann trägt DoD (1) ihn
      mit seinem Grund, und die Closure-Notiz sagt ausdrücklich, dass hier **nichts** gemessen
      wurde, statt das Ausbleiben als Erfolg zu lesen.
- [ ] **(3) Die Herkunfts-Notizen der zwölf Postens bleiben unangetastet.** `done/` ist Zeitdokument
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      §Geltungsbereich); ein Ausgang, der als Nachtrag in eine geschlossene Datei geschrieben
      wird, steht wieder an dem Ort, den kein Lauf aufschlägt — der Fehler, den dieser Slice
      behandelt, in seiner eigenen Ausführung wiederholt.
      **Rot:** `git diff --stat <basis> -- docs/plan/planning/done/` liefert eine nicht-leere
      Ausgabe; heute ist der Prüfbereich **58** Dateien mit einem Steering-Loop-Eintrag
      (`grep -rl 'Steering-Loop-Eintrag' docs/plan/planning/done/*.md | wc -l`).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`AGENTS.md`](../../../../AGENTS.md) | update, **soweit übernommen** | §3.6 trägt sechs der zwölf Postens, §3.7 den siebten, der achte ist offen zwischen Regel und Sensor, der neunte, der zehnte und der zwölfte gehören nicht hierher (Plan-Form, Erhebung einer Zahl bzw. Geltungsbereich → Adaptions-Block). Der Text ist Architect-Arbeit ([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1); dieser Slice liefert die Liste und den Termin |
| [`harness/conventions.md`](../../../../harness/conventions.md) | update, **soweit übernommen** | zwei weitere Setzungen von [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) (erster und zehnter Posten), ihr §Geltungsbereich (zwölfter) sowie der Ort des neunten (Form der Plan-Tabelle); derselbe Vorbehalt |
| `docs/plan/planning/done/` | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich). DoD (3) macht daraus eine Zusage mit eigenem Rot |
| `docs/plan/adr/` | **unverändert** | alle zwölf Postens **heben** eine Anforderung an (zehn eine Beleg-, der neunte eine an die Plan-Form, der zehnte eine an die Erhebung einer Zahl); eine Anhebung ist kein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5, [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)). Ergibt der Lauf, dass ein Posten in Wahrheit eine **Senkung** enthält, greift die Rückführung aus §4 |
| `test/mutations/` | **unverändert** | die Regeln liegen im Feedforward-Quadranten; [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) sagt das über sich selbst und misst, dass `make comment-claims` keine Markdown-Datei im Prüfbereich hat. Ein Wächter über Regeltext ist Weg (C) aus §1 und ein eigener Schnitt |
| [`.harness/baseline`](../../../../.harness/baseline) und die emittierte Ebene | **unverändert** | die emittierte `AGENTS.md` kommt aus der vendored Vorlage, nicht aus dieser Datei (Kopfzeile *Ebene*) |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Die Liste der Postens gehört an den Anfang des Laufs, nicht an sein Ende.** Sie steht in §1 mit
drei Kommandos und elf Herkunfts-Notizen (zwölf Postens, zwei davon aus derselben Notiz); wer sie erweitert, erweitert sie **vor** der ersten
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

**Ausdrücklich nicht Teil des Closure-Triggers: dass alle zwölf Postens übernommen werden.** Ein
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
- **Ein Durchgang, der zwölf Postens auf einmal entscheidet, kann sie einander angleichen.** Sechs
  hängen an derselben Regel, und die Versuchung ist, aus ihnen einen Satz zu machen. Sie sind
  verschieden: einer erweitert die **Träger** einer Zusage, einer ihre **Reichweite**, einer den
  **Gegenstand** ihres Nachweises, einer die **Richtung** seines Fehlers, einer die **Ausgabe** des
  Rot, einer die **Bezugsmenge**, über die eine Vollständigkeits-Zusage rechnet. Wer sie
  zusammenzieht, verliert genau die Unterscheidung, für die sechs Closures je einen Beleg geliefert
  haben.
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
