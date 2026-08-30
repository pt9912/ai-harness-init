# Slice slice-138: Der Gate-Nachweis entsteht nicht über einem roten Lauf — und was ihn weiterhin schreiben lässt, steht neben der Zusage

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — an zwei Instrumenten gemessen, und beide antworten gleich.

**(1) Die Probe aus [slice-134](../open/slice-134-adr-index-traegt-die-ziel-form.md), von
[slice-137](../open/slice-137-beobachtungs-register-bekommt-seinen-ort.md) als zwei Konjunkte
geführt.** Das erste — *stammt der Befund aus dem Re-Baseline-Delta?* — lautet **nein**, und
zwar auf beiden Seiten des Mechanismus: der Träger ist älter als der Tausch
(`git log --diff-filter=A --format='%ad' --date=short -- harness/tools/record-gates.sh` →
**2026-06-14**, während [welle-10](../welle-10-re-baseline.md) am 2026-08-09 aufgesetzt wurde),
und die Regelwerk-Zeile, die ihn benennt, ist über den Tausch hinweg unverändert
(`diff <(git show b902b60^:.harness/baseline/v3.5.2/regelwerk/grundlagen-durchsetzungsschicht.md) .harness/baseline/v5.12.0/regelwerk/grundlagen-durchsetzungsschicht.md | grep -c 'record-gates'`
→ **0**). Das zweite — *belegt der Slice ein Closure-Kriterium von welle-10 §3, und braucht die
Welle ihn?* — lautet ebenfalls **nein**: keiner der drei Durchgänge dort hat einen Makefile-Rezept-
Zuschnitt zum Gegenstand.

**Auch nicht [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md).** Ihre Identität ist die
**Adoption** vierer gelieferter d-check-Module (*„Adoption heißt Trockenlauf + Config-Block +
Verdrahtung, nicht Neubau"*, §1); ihr §6 hält die **Eigenbauten** ausdrücklich draußen
(*„alle drei sind **Eigenbauten**, keine Adoption"*). Hier entsteht kein Config-Block zu einem
gelieferten Modul, sondern eine Ordnungskante im `Makefile` und ein Sensor darüber — dieselbe
Klasse, die welle-13 hinausführt.

**(2) Der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen.** **Bündel?** Nein — die Aussage *„kein Gate-Nachweis entsteht über
einem roten Lauf"* wird von diesem einen Slice wahr. **Gemeinsames Closure-Kriterium?** Nein —
eine Welle darum herum schriebe die DoD unten ab. **Auslöser reaktiv oder gewollt?** **Reaktiv**:
ein Lauf hat den Stempel über rotem Stand geschrieben; das ist ein Vorfall, keine neue Fähigkeit.
Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 erscheint wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist allein die
Verzeichnis-Position.

**Ebene: Dogfood, nicht emittiert — und die emittierte Ebene ist hier das Vorbild, nicht der
Gegenstand.** Der Aggregator, den das Werkzeug ins Ziel schreibt, hängt `record-gates` an die
akkumulierten Checks statt es hinter sie zu stellen
(`grep -nE '^(gates|record-gates):' internal/emit/makefile.go` → **2** Zeilen,
`gates: record-gates` und `record-gates: $(GATE_CHECKS)`), und diese Kante ist dort **bewacht**
(`test/mutations/38-gen-aggregator-order-edge.sh`, erwarteter Sensor `TestMakefile_HasOrderEdge`).
Der `Makefile` dieses Repos trägt beides nicht. Dieser Slice ändert an der emittierten Ebene
nichts; was dort offen bleibt, steht in §6 mit Ausgang.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel — die
Regel, gegen die der Befund läuft),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (ein Kommentar beschreibt, was da ist — zwei Kommentare
sagen mehr, als der Code hält),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (der Adaptions-Eintrag zur Härtung ist Architect-Arbeit;
dieser Slice schreibt kein Norm-Artefakt),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
(die Mechanik, auf die beide Kommentare zeigen),
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(die **eine** Restlücke, die deklariert ist — die Form, in der die übrigen zu deklarieren sind),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl in diesem Plan steht neben dem Kommando, das genau sie ausgibt);
dazu das Baseline-Regelwerk `grundlagen-durchsetzungsschicht.md` §Grenzen — ehrlich benannt
(*„Ein Gate, das so tut, als decke es mehr ab, als es tut, ist selbst eine Harness-Lüge"*) und
`modul-13-quality-gates.md` §Guard-Härtung (Auslöser, Landung als `MR-<NNN>`, Grenz-Zeile).

**Bewusst KEINE `LH-*`-Kennung**, und die naheliegende ist geprüft:
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
verlangt wörtlich *„Jeder **emittierte** Gate-Target läuft auf frischem Checkout"* — die andere
Ebene, und die ist hier gemessen in Ordnung (Kopf, Absatz *Ebene*). Gegenstand ist ein
Dogfood-Nachweis; Präzedenz ist
[slice-070](../open/slice-070-comment-claims-pruefbereich.md), das dieselbe Prüfung mit demselben
Ergebnis führt: leer und erkennbar statt gefüllt und falsch.

**Berührte Spec-Stellen:** — Dieser Slice berührt keine. Der Gate-Nachweis ist ein Artefakt der
Durchsetzungsschicht dieses Repos und steht in keinem der drei Spec-Straten; was das Werkzeug
kann, ändert sich nicht. Der Verweis zeigt ohnehin **aufwärts**: die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-08-29.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**`make gates` hinterlässt keinen Nachweis, wenn eines seiner Ziele rot war — und die Wege, die
ihn weiterhin schreiben, stehen als Grenze neben der Zusage, statt unbenannt zu bleiben.**

### Der Befund: die Zusage hängt an einer Reihenfolge, und ein Flag hebt sie auf

Zwei Kommentare sagen zu, dass der Stempel nur nach grünen Gates entsteht — `Makefile:298`
(*„record-gates als LETZTER — der Nachweis entsteht nur nach grünen Gates"*) und
`harness/tools/record-gates.sh:4` (*„Läuft als letzter gates-Prerequisite (nur bei grünen
Gates)"*). Das Skript prüft nichts: sein Rumpf misst vier Zeilen
(`grep -vcE '^\s*(#|$)' harness/tools/record-gates.sh` → **4**), und keine davon liest ein
Ergebnis. Getragen wird die Zusage allein davon, dass `make` beim ersten roten Ziel abbricht —
und genau das hebt `-k` auf.

**Der Vorfall.** Ein Lauf mit `-k` hinterließ `.harness/state/gates-passed.diffsha` mit einem
Hash, der den damaligen Arbeitsbaum deckte, während `docs-check` und `test-bats` rot waren; der
Stop-Hook vergleicht genau diesen Hash und gibt bei Übereinstimmung frei. **Dieser Lauf ist im
Repo nicht als Messung wiederholbar** — er erzeugte den Stempel, um den es geht. Gemessen wird
darum außerhalb, an zwei synthetischen `Makefile`n, die nur die Kantenform unterscheiden:

- **Flach** (die heutige Form — `record-gates` steht **neben** den Zielen):
  `d=$(mktemp -d); printf 'gates: rot record-gates\nrot:\n\t@exit 1\nrecord-gates:\n\t@echo STEMPEL\n' > "$d/Makefile"; make -C "$d" -k gates 2>&1 | grep -c STEMPEL`
  → **1**.
- **Mit Kante** (`record-gates` hängt **an** den Zielen):
  `d=$(mktemp -d); printf 'gates: record-gates\nrot:\n\t@exit 1\nrecord-gates: rot\n\t@echo STEMPEL\n' > "$d/Makefile"; make -C "$d" -k gates 2>&1 | grep -c STEMPEL`
  → **0**.

Beide Läufe enden mit Exit 2 — der Exit-Code war nie das Problem. Der Unterschied liegt darin,
dass `make` ein Ziel, dessen **Voraussetzung** gefallen ist, auch unter `-k` nicht baut
(*„Das Ziel `gates` wurde wegen Fehlern nicht neugemacht"*), während ein Ziel **neben** dem
gefallenen weiterläuft.

**Zwei Löcher, und nur eines ist neu.** Der Stop-Hook deklariert seine Restlücke selbst
(*„frischer Klon bzw. gelöschter `.harness`-State mit cleanem Tree wird freigegeben … CI ist dort
das Netz"*, wortgleich in
[`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
Das ist eine benannte Grenze und bleibt es. Das `-k`-Loch ist **nicht** deklariert; es ist eine
gebrochene Zusage. Die zwei werden nicht zusammengezogen.

### `-k` zu verbieten wäre die falsche Antwort — und die Kante nimmt es niemandem weg

`make gates` bricht fail-fast am ersten roten Ziel ab und verdeckt damit die übrigen; ohne `-k`
ist die Aussage *„genau diese Ziele sind rot, nichts darüber hinaus"* nicht zu treffen. Der Griff
ist gelebt, nicht hypothetisch:
`git grep -c 'make -k gates' -- docs/plan/ ':!*slice-138-*'` → **drei** Dateien
(`CO-004…:1`, `slice-081…:1`, `slice-133…:4`); dieser Plan ist ausgeschlossen, weil er den Griff
zitiert und sich sonst selbst mitzählte. In der roten Phase seit
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md) ist er der einzige Weg zum
vollständigen Bild.

**Die Kante lässt diesen Griff unangetastet.** Unter `-k` laufen alle Ziele weiter und melden
alle ihre Fehler; nur das Stempel-Rezept fällt weg, weil seine Voraussetzung gefallen ist. Was
verschwindet, ist nicht die Sicht, sondern die **Behauptung** über sie.

### Drei Mechaniken, drei Reichweiten — gemessen, nicht abgewogen

Der Slice entscheidet nicht vorab, welche Form gebaut wird; er liefert, was jede erreicht.
Gemessen mit demselben synthetischen Paar wie oben, und mit einem Rezept, das nur ausgibt, was es
sieht
(`printf 'gates: export GATE_RUN := 1\ngates: gruen record-gates\nrecord-gates: gruen\n\t@echo "MAKEFLAGS=[$${MAKEFLAGS-unset}] GATE_RUN=[$${GATE_RUN-unset}]"\ngruen:\n\t@true\n' > "$d/Makefile"`,
dann `make -C "$d" $f gates` je Flag):

1. **Ordnungskante** — `record-gates` hängt an den Gate-Zielen. Schließt `-k` (**0** statt **1**,
   oben) **und** ein `MAKEFLAGS=k` aus der Umgebung, schließt **nicht** `-i`
   (`--ignore-errors`): dort gilt das gefallene Ziel als gelungen, das Rezept läuft. Über eine
   Form, die die Ziel-Reihenfolge behält —
   `d=$(mktemp -d); printf 'gates: gruen rot record-gates\nrecord-gates: gruen rot\n\t@echo STEMPEL\ngruen:\n\t@echo g\nrot:\n\t@exit 1\n' > "$d/Makefile"; for f in -k -i; do make -C "$d" $f gates 2>&1 | grep -c STEMPEL; done`
   → **0**, dann **1**; und
   `MAKEFLAGS=k make -C "$d" gates 2>&1 | grep -c STEMPEL` → **0**.
2. **Das Rezept liest `MAKEFLAGS`** — sichtbar ist `[w]` ohne Flag, `[kw]` unter `-k`, `[iw]`
   unter `-i`, `[w -j4 --jobserver-auth=…]` unter `-j4`. Damit ist `-i` erreichbar. Beim direkten
   `make record-gates` steht dort nur `[w]` — für diesen Weg ist die Prüfung blind.
3. **Ziel-spezifische, exportierte Variable an `gates`** — im Rezept `GATE_RUN=[1]`, beim direkten
   `make record-gates` `GATE_RUN=[unset]`. Damit ist der direkte Aufruf erreichbar.

**Und was keine von ihnen kann:** das **Ergebnis** der anderen Ziele lesen. `make` gibt dem Rezept
keinen Ergebnis-Kanal; ein Skript kann prüfen, **wie** es gerufen wurde, nie, **ob** die Gates
grün waren. Ein echter Ergebnis-Nachweis verlangte je Ziel eine Quittung — heute **10** Ziele
(`sed -n 's/^gates: \(.*\) ##.*/\1/p' Makefile | tr ' ' '\n' | grep -vc '^record-gates$'`, ein
Betrag, der mit jedem neuen Gate wandert) und ein eigener Preis. Das ist ein anderer Slice; er
steht in §6 mit Ausgang, nicht in dieser DoD.

### Wie weit gehört gehärtet — die Grenze ist geliehen, nicht erfunden

Das Baseline-Regelwerk trennt beides. `modul-13-quality-gates.md` §Guard-Härtung: *„Auslöser ist
Beobachtung, nicht Bedrohungsmodell. Gehärtet wird gegen eine **dreimal beobachtete** Umgehung"*
— und `grundlagen-durchsetzungsschicht.md` §Grenzen — ehrlich benannt: *„Diese Grenzen zu
benennen ist Pflicht. Ein Gate, das so tut, als decke es mehr ab, als es tut, ist selbst eine
Harness-Lüge."*

Daraus folgt der Zuschnitt, und er ist nicht Geschmack:

- Der **beobachtete** Weg (`-k`) ist keine Härtung gegen eine gedachte Umgehung, sondern die
  **Reparatur einer geschriebenen Zusage**, die nicht hält. Sie braucht keine drei Vorfälle.
- Die **nicht beobachteten** Wege (`-i`, direkter Aufruf, `-j`) sind Härtungs-Kandidaten. Sie
  werden **deklariert**, nicht gebaut — in derselben Form, in der der Stop-Hook seine Restlücke
  schon führt. Baut ein Lauf sie trotzdem, ist das eine Härtung mit eigenem Auslöser und gehört in
  einen eigenen Zug.

### Die Wächter-Frage: gestellt, und die Antwort ist ein Neubau

**`make comment-claims` hätte diesen Fall nicht gefangen, und zwar zweifach.** Erstens liegt
`harness/tools/record-gates.sh` zwar im Prüfbereich, doch der Kommentar trägt kein
Behauptungs-Wort, an dem das Skript ansetzt:
`grep -cE 'garantiert|stellt sicher|bewacht|belegt|sorgt dafuer|sorgt dafür|verhindert' harness/tools/record-gates.sh`
→ **0**. Zweitens liegt der `Makefile` überhaupt nicht im Prüfbereich: das Rezept baut ihn aus
`git ls-files`-Mustern (`sed -n '141p' Makefile`), und keines von ihnen trifft die Repo-Wurzel
(`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | grep -c '^Makefile$'`
→ **0**, Exit 1). Ob der Prüfbereich enger ist, als die Vollständigkeits-
Zeile klingt, ist eine eigene Frage mit eigenem Träger:
[slice-070](../open/slice-070-comment-claims-pruefbereich.md).

**Und ein Sensor über der Kante existiert nicht.** Wer `record-gates` oder den Stop-Hook nennt,
tut es über die **emittierte** Ebene: `git grep -l -E 'record-gates|stop-require-gates' -- 'test/*.bats' '*_test.go'`
→ **4** Dateien, alle vier unter `internal/emit/` bzw. `internal/wire/`. Über den `Makefile`
dieses Repos urteilt keine Zeile. Die Antwort auf die Wächter-Frage ist deshalb **Sensor bauen**,
nicht *„bewusst kein Sensor"*: der Gegenstand ist eine Struktur-Eigenschaft einer getrackten
Datei, hermetisch prüfbar, und das Vorbild steht eine Ebene weiter
(`test/mutations/38-gen-aggregator-order-edge.sh` gegen `TestMakefile_HasOrderEdge`).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Über einem roten Ziel entsteht kein Stempel mehr, und das Gegenbeispiel ist vorher rot
      gesehen.** Verlangt ist die **Eigenschaft**, nicht eine Form: `make -k gates` über einem
      Baum mit mindestens einem roten Gate-Ziel lässt `.harness/state/gates-passed.diffsha`
      **unverändert** (Inhalt vor und nach dem Lauf verglichen, nicht der Zeitstempel), und
      derselbe Lauf meldet weiterhin **jedes** rote Ziel, nicht nur das erste. Die Reihenfolgen-
      Zusage aus `Makefile:296-298` — `baseline-verify` zuerst — gilt unter seriellem `make`
      unverändert oder wird in derselben Zeile auf das eingeschränkt, was die gewählte Form hält
      ([`AGENTS.md`](../../../../AGENTS.md) §3.7). **Rot gesehen** heißt: derselbe Lauf **vor** der
      Änderung schreibt den Stempel; die rote Vorbedingung liegt zum Schnitt-Zeitpunkt vor
      ([`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) hält `docs-check`
      rot), und wird sie vorher aufgelöst, stellt der Lauf sie synthetisch her.
- [x] **(2) Jede Stelle, die die Zusage trägt, sagt, was der Code hält — und die Wege, die offen
      bleiben, stehen dort mit.** Die Menge ist ein Kommando, keine Liste:
      `git grep -inE 'gruenen (Gates|Checks)|grünen (Gates|Checks)' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!*slice-138-*'`
      → heute **4** Fundorte, davon **2** im Dogfood (`Makefile`, `harness/tools/record-gates.sh`)
      und **2** in den emittierten Vorlagen; dieser Plan zitiert beide Dogfood-Stellen wörtlich
      und ist darum ausgeschlossen. **Gebunden sind die zwei im Dogfood.** Jeder der drei
      in §1 gemessenen, **nicht** geschlossenen Wege — `-i`, direkter `make record-gates`, `-j` —
      steht danach als Grenze neben der Zusage, in der Form, die
      [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
      für die deklarierte Restlücke schon führt. Kein „u. a.", keine Auswahl: entweder ein Weg ist
      geschlossen, oder er steht da.
      **Der Haken ruht nicht auf dem Kommando dieses Punktes:** es liefert heute **2**, beide
      emittiert, weil die Reparatur den zwei gebundenen Stellen die gesuchte Formulierung genommen
      hat. Womit er stattdessen gesetzt ist, steht in §7 (*Der Haken zu (2)*).
- [x] **(3) Die Kante hat einen Wächter, und der entsteht hier.** Ein Sensor prüft die Eigenschaft
      am **gelebten** `Makefile` — nicht an einer Nachbildung, die sich selbst misst —, und ein
      Fall in `test/mutations/` hebt sie auf und färbt genau diesen Sensor rot, mit `# expect:` auf
      seinen Namen. Vorbild eine Ebene weiter: `test/mutations/38-gen-aggregator-order-edge.sh`.
      Der Fall ist einmal durch `make mutate` gelaufen und meldet keinen BEFUND auf sich selbst;
      einen Einzelfall-Modus hat der Treiber nicht (`grep -c 'MUTATE_CASES' harness/tools/mutate.sh`
      → **0**), der Lauf geht also über die volle Fall-Menge.
      **Die letzten zwei Sätze sind nicht eingelöst, und der Haken behauptet sie nicht:** der
      `make mutate`-Lauf ist heute nicht herstellbar. Was ihn ersetzt, was der Ersatz **nicht**
      deckt und wer den Lauf trägt, steht in §7 (*Der Haken zu (3)*).
- [x] `make gates` bringt **keinen Befund hervor, der diesem Slice zuzurechnen ist** — der Lauf
      trägt zum Schnitt-Zeitpunkt zwei offene Carveouts
      ([`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md) auf `test`,
      [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) auf `docs-check`),
      beide fremde Posten mit eigenen Folge-Slices. Verlangt ist der Vorher-Nachher-Vergleich
      derselben Ausgabe.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist — hier keiner: der emittierte
      Aggregator trägt die Kante bereits (Kopf, Absatz *Ebene*), und was dort offen bleibt, steht
      in §6.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap und führt keines; das Item
      entfällt.
- [x] Beobachtungs-Register fortgeschrieben — **falls es zum
      Ausführungszeitpunkt existiert**; sein Träger ist
      [slice-137](../open/slice-137-beobachtungs-register-bekommt-seinen-ort.md), und die
      Reihenfolge der beiden ist frei. Existiert es nicht, wird genau das in §7 notiert, statt
      das Item stumm zu lassen.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure — dieses
      Repo fährt Wellen-Betrieb, und die liest auch Slices ohne Wellen-Zugehörigkeit.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `Makefile` — das `gates`-Ziel samt Reihenfolgen-Kommentar | update | die Kante entsteht dort, wo die Zusage steht; DoD (1) und die Hälfte von (2) |
| `harness/tools/record-gates.sh` — Kopf-Kommentar, ggf. Rumpf | update | die zweite Zusage-Stelle; ein Rumpf-Griff nur, wenn DoD (2) einen Weg als *geschlossen* statt *deklariert* entscheidet |
| ein bats-Fall unter `test/` | neu | der Sensor über der Eigenschaft — heute urteilt keine Zeile über den eigenen `Makefile` (§1) |
| ein Fall unter `test/mutations/` | neu | der Zahn zum Sensor; ohne ihn ist die Zusage aus DoD (1) unbewacht |

**Nicht in dieser Liste, und jedes mit Grund:**
[`harness/conventions.md`](../../../../harness/conventions.md) — eine Härtung landet als neuer
`MR-<NNN>` (`modul-13-quality-gates.md` §Guard-Härtung), und den schreibt nach
[`AGENTS.md`](../../../../AGENTS.md) §3.8 der **Architect** in einem eigenen Commit;
`internal/emit/**` — die emittierte Ebene trägt die Kante bereits und ist dort bewacht (Kopf),
eine Änderung an ihr zöge den emittierten Vertrag samt `make smoke`/`make full-smoke` in einen
Slice, dessen Gegenstand der eigene `Makefile` ist;
[`.claude/hooks/stop-require-gates.sh`](../../../../.claude/hooks/stop-require-gates.sh) — der
Hook arbeitet wie entworfen, er vergleicht einen Hash. Falsch ist, was ihm gereicht wird.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **das WIP-Limit ist frei**, also
`ls docs/plan/planning/in-progress/ | grep -c '^slice-'` → **0** — am 2026-08-29 ist das der
Ist-Stand. Eine **fachliche** Vorbedingung hat dieser Slice nicht.

**Priorität — er geht vor
[slice-130](../in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md), und das ist kein Vorzug,
sondern eine Reihung.** [welle-10](../welle-10-re-baseline.md) §4 führt slice-130 als nächsten
Posten. Drei Gründe, jeder nachprüfbar:

1. **Der Befund feuert in genau der Phase, in der das Repo steht.** Solange ein Gate rot ist,
   bricht `make gates` fail-fast ab und `-k` ist der einzige Weg zum vollständigen Bild — und
   jeder dieser Läufe schreibt heute einen Stempel über rotem Stand. Der Griff ist in dieser Phase
   belegt: `git grep -c 'make -k gates' -- docs/plan/ ':!*slice-138-*'` → drei Dateien, alle aus
   der Zeit seit [slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md).
2. **Alle drei Fundorte stammen aus der Arbeit am emittierten Baum** — slice-081,
   [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) und
   [`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md) —, und slice-130 liegt in
   derselben Ecke. Der nächste Lauf, der `-k` braucht, ist absehbar der, dessen Nachweis dann
   wieder nicht deckt.
3. **Der Nachweis ist die Voraussetzung jeder Closure, auch der von slice-130.** Ein Stempel, der
   Grün behauptet, wo Rot war, entwertet nicht diesen Slice, sondern jeden, der danach abgeschlossen
   wird.

**Kein Konflikt im Gegenstand:** dieser Slice fasst `Makefile`, `harness/tools/` und `test/` an,
slice-130 `internal/emit/`. Eine Kante gibt es doch, und sie ist klein und zeigt in dieselbe
Richtung: [welle-10](../welle-10-re-baseline.md) §3 verlangt `make mutate` mit der
Vollständigkeits-Zeile über **allen** Fall-Dateien — der neue Fall aus DoD (3) gehört dann dazu,
und ihn vor dieser Closure in den Bestand zu legen ist billiger, als ihn danach nachzureichen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): DoD (2) entscheidet einen der drei Wege
  als *zu schließen* statt *zu deklarieren*, und die Schließung verlangt Quittungen je Gate-Ziel
  (§1, letzter Absatz der Mechanik-Messung). Dann ist der Slice ein anderer und wird geteilt —
  Kante plus Grenz-Zeilen hier, Quittungs-Mechanik in einem Folge-Slice —, **nicht** gedehnt.
- `in-progress` → `open` (blockiert — Carveout?): der Architect entscheidet die Härtung anders,
  etwa dass die Grenz-Zeile vor dem Mechanismus zu setzen ist oder dass
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  in einer Form geschärft wird, die eine andere Kantenform verlangt. Dann ist die Frage nicht
  offen, sondern **anders** entschieden, und der Slice wird auf sie umgeschrieben.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make gates` ohne einen Befund, der diesem Slice zuzurechnen ist (Vergleich gegen
den Lauf davor); `make mutate` über der vollen Fall-Menge ohne BEFUND auf den neuen Fall;
Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben. Die Übergabe an den Architect (§6) ist
**benannt**, nicht erledigt — sie ist kein Closure-Kriterium, sonst hinge der Slice an einem
fremden Lauf.

**Drei der vier Kriterien sind erfüllt, das dritte nicht — und diese Closure läuft trotzdem.**
Der `make mutate`-Lauf ist heute nicht herstellbar; er hängt an
[`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md), also an genau dem fremden Lauf,
den der Satz oben von den Closure-Kriterien fernhalten wollte. Die Abweichung samt Ersatz,
Deckungsgrenze und Träger steht in §7 (*Der Haken zu (3)*); sie steht dort und nicht hier, weil ein
Kriterium, das man bei seiner eigenen Anwendung umschreibt, keines ist.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die rote Phase blockt danach jeden Stop, und das ist der Preis, nicht ein Nebeneffekt.**
  Solange [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) `docs-check` rot
  hält, entsteht **kein** gültiger Stempel mehr — heute entsteht er über `-k`. Der Loop-Guard des
  Hooks gibt beim zweiten Anlauf frei (*„Hat dieser Hook den Stop bereits einmal blockiert …, nicht
  erneut blockieren"*), der Preis ist also **eine** Blockade je Sitzung, kein Stillstand. Wer ihn
  nicht zahlen will, hat den Befund nicht behoben, sondern die Zusage zurückgenommen. —
  **Ausgang: eingetreten**, und zwar als der gewollte Zustand. Gemessen an `ef22f72`:
  `cat .harness/state/gates-passed.diffsha` → `a8b28b4e…`, `bash harness/tools/working-tree-hash.sh`
  → `c9b1d232…`. Der Stop-Hook vergleicht genau diese zwei und blockt. Der zweite Zweig
  (*entfallen*) ist damit ausgeschlossen: `CO-005` steht, und mein `make -k gates` über demselben
  Baum meldet `d-check: 462 Datei(en) geprüft, 1 Befund(e)` mit
  `harness/conventions.md:1019 … target-missing`. **Kein Carveout und kein Folge-Slice**: der
  Zustand ist die Lieferung dieses Slice, nicht sein Schaden.
- **`-j` bricht die Reihenfolgen-Zusage, und die Kante ordnet nicht.** Eine Kante sagt *hängt ab
  von*, nicht *läuft danach*; unter Parallelität fällt die Zusage *„`baseline-verify` als ERSTER"*
  (`Makefile:296-298`). Gemessen ist, dass das Rezept die Parallelität sieht (`MAKEFLAGS` trägt
  `-j4 --jobserver-auth=…`, §1); **ungemessen** ist, ob die zehn Docker-Ziele dieses Repos
  parallel überhaupt tragen. — **Ausgang: entfallen**, beide Hälften der vorformulierten Bedingung
  hier selbst gemessen. **Erste Hälfte:** der serielle Lauf erhält die Reihenfolge —
  `head -1` über dem Protokoll meines `make -k gates` ist
  `baseline-verify: v5.12.0 OK — 51 Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
  **Zweite Hälfte:** die Zusage sagt genau das und nicht mehr — `sed -n '/^# Die Reihenfolge/,+2p' Makefile`
  gibt drei Zeilen aus, und über ihre zweite und dritte läuft der Satz *„Serielles `make` baut sie in
  dieser Reihenfolge ab; `-j` tut es nicht."* Die **ungemessene**
  Frage — ob die zehn Docker-Ziele parallel tragen — ist mit dem Ausgang nicht beantwortet, sondern
  gegenstandslos geworden: die Zusage erhebt über den parallelen Fall keinen Anspruch mehr.
- **Der Ergebnis-Nachweis bleibt ungebaut.** Keine der drei gemessenen Mechaniken liest, **ob** die
  Gates grün waren; das verlangte eine Quittung je Ziel. — **Ausgang: weiter offen.** Bestätigt:
  `command grep -c 'record-gates.sh' <gates-k.log>` → **0** über meinem Lauf, und
  `harness/tools/record-gates.sh:6` sagt es seit diesem Slice selbst
  (*„DIESES SKRIPT LIEST KEIN ERGEBNIS und kann es nicht"*). **Der vorformulierte Ausgang verlangte
  den Schnitt bei dieser Closure; er ist hier nicht gezogen, und das ist eine Entscheidung mit
  Grund.** Erstens hat der genannte Trigger nicht gefeuert — ein zweiter Stempel über rotem Lauf auf
  einem anderen Weg als `-k` ist nicht beobachtet. Zweitens gebiert eine Closure-Notiz keinen
  Slice-Plan; der entsteht im Planungs-Lauf (Präzedenz
  [slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §7 *Übergabe*). Der
  Posten steht damit als benannter Planner-Posten in §7 (*Folge-Posten ohne Träger*, erster
  Eintrag), mit genau dem Trigger, den dieses Feld formuliert hat. Das Beobachtungs-Register, das
  Modul 5 für *weiter offen* vorsieht, existiert nicht — Träger
  [slice-137](../open/slice-137-beobachtungs-register-bekommt-seinen-ort.md).
- **Die emittierte Ebene trägt dieselben Restwege, aber keine Grenz-Zeile.** Ihre Kante ist da und
  bewacht (Kopf), ihre zwei Zusage-Stellen nennen `-i` und den direkten Aufruf nicht. Das ist
  dieselbe Klasse wie hier, nur eine Ebene weiter, und sie hat einen anderen Vertrag
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) und
  eigene Sensoren (`make smoke`, `make full-smoke`). — **Ausgang: weiter offen**, und der Bestand
  ist hier gemessen. Die Kante steht dort:
  `command grep -nE '^(gates|record-gates):' internal/emit/makefile.go` → **2** Zeilen
  (`gates: record-gates`, `record-gates: $(GATE_CHECKS)`). Die zwei Zusage-Stellen tragen
  unverändert die Formulierung, die dieser Slice im Dogfood zurückgenommen hat —
  `git grep -inE 'gruenen (Gates|Checks)|grünen (Gates|Checks)' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!*slice-138-*'`
  → **2**, beide unter `internal/emit/templates/enforce/`. Und eine Grenz-Zeile steht dort nicht:
  `command grep -cE '\-i\b|IGNORE|MAKEFLAGS' internal/emit/templates/enforce/enforce.mk internal/emit/templates/enforce/record-gates.sh`
  → je **0**. **Auch dieser Zweig wird hier nicht geschnitten**, aus demselben Grund wie beim Risiko
  darüber; er steht als benannter Planner-Posten in §7 (*Folge-Posten ohne Träger*, zweiter
  Eintrag). Was der vorformulierte Ausgang zugesagt hat — *die Messung dieses Slice als Beleg* —
  liegt damit vor; was fehlt, ist der Schnitt, und dass er fehlt, steht hier statt nirgends.
- **Der Adaptions-Eintrag ist nicht Sache dieses Slice.** `modul-13-quality-gates.md`
  §Guard-Härtung verlangt, dass jede Härtung als neuer `MR-<NNN>` landet, der den vorherigen
  schärft — und [`AGENTS.md`](../../../../AGENTS.md) §3.8 gibt das Schreiben dem **Architect**, in
  einem eigenen Commit. Läuft dieser Slice ohne ihn, beschreibt der Adaptions-Block eine Mechanik,
  die so nicht mehr steht. — **Ausgang: weiter offen**, an den Architect gemeldet (§7 *Übergabe*).
  **Die vorformulierte Begründung trifft nicht, und das ändert den Auftrag, nicht den Ausgang.**
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  §Adaption sagt *„`record-gates` als letzter `gates`-Prerequisite"*, und das bleibt
  buchstäblich wahr: `sed -n 's/^gates: \(.*\) ##.*/\1/p' Makefile` → `record-gates`, der einzige
  und damit letzte. Der Eintrag ist nicht **falsch**, sondern **unvollständig** — er benennt die
  Ordnungskante nicht, die die Zusage seit diesem Slice trägt, und ein Architect-Lauf, der die
  Übergabe wörtlich nähme, korrigierte einen Satz, der stimmt.
- **Der neue Zahn kann sich selbst messen.** Baut der Sensor die Kante nach, statt den gelebten
  `Makefile` zu lesen, misst er `make` und nicht dieses Repo — die Klasse, die der Treiber als
  BEFUND auf den eigenen Fall meldet. — **Ausgang: entfallen**, und der Beleg ist ein Lauf, keine
  Lektüre. `test/gate-nachweis-kante.bats:94-95` setzt `REPO="$(cd "$BATS_TEST_DIRNAME/.." && pwd)"`
  und `MK="$REPO/Makefile"`; entscheidend ist aber, dass eine Mutation am **gelebten** `Makefile`
  den Wächter kippt. Selbst gefahren über einem Klon von `ef22f72`: Fall `210` ändert genau **eine**
  Zeile (`git diff --stat` → `1 file changed, 1 insertion(+), 1 deletion(-)`, die `record-gates:`-
  Zeile), und `make test-bats` meldet `not ok 74 gate-nachweis: record-gates haengt an den Checks
  (Ordnungskante steht)` — zeichengleich mit der `# expect:`-Zeile des Falls. Der zweite Zweig
  (*eingetreten*) hätte einen `make mutate`-Lauf verlangt, den `CO-004` blockiert; er ist damit
  nicht **unentschieden**, sondern durch den Arm entschieden, den der Treiber selbst prüft.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-30.
**Gegenstand:** `HEAD` = `ef22f72` (`git rev-parse --short HEAD`), Arbeitsbaum sauber
(`git status --porcelain | wc -l` → **0**, vor wie nach jedem Lauf dieser Closure; die Änderung
dieses Zuges ist die erste). Die Kette: `b22f330` (Lifecycle-Move) · `07dc762` (Implementer) ·
`a25e33c` (Review 1) · `5a75f97` (Fix 1) · `02d3637` (Review 2) · `f275092` (Fix 2) · `d949090`
(Review 3) · `434d4fa` (Fix 3) · `d280f35` (Review 4) · `cb85f15` (Fix 4) · `ef22f72`
(Verifikation).

Jede Zahl unten ist **in diesem Lauf** erhoben; Umsetzung, Reviews und Verifikation waren
**Eingabe, kein Beleg**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Wo ich eine Messung **nicht** wiederholt habe, steht es dabei.

### DoD-Stand — die drei slice-eigenen Punkte

**(1) Über einem roten Ziel entsteht kein Stempel, das Gegenbeispiel ist rot gesehen — ERFÜLLT.**
`make -k gates` über `ef22f72` selbst gefahren: **Exit 2**, und der Stempel ist nicht angefasst —
nicht nur inhaltsgleich, sondern unberührt: `diff` gegen die vorher gesicherte Kopie ist leer, und
`stat -c '%y'` liefert vor wie nach `2026-08-29 18:15:36.269724363 +0200`. Das Rezept lief null Mal
(`command grep -c 'record-gates.sh' <log>` → **0**), und `make` sagt es selbst
(*„Das Ziel „gates" wurde wegen Fehlern nicht neugemacht."*). **`-k` behält seinen Zweck:**
`command grep -cE '^make(\[[0-9]+\])?: \*\*\* \[' <log>` → **2**, nämlich `d-check.mk:66: docs-check`
und `Makefile:55: test-bats` — nicht nur das erste. Alle zehn Checks haben gemeldet,
`baseline-verify: v5.12.0 OK — 51 Dateien` als **erste** Protokollzeile.

**Rot gesehen — selbst hergestellt, nicht übernommen.** Zwei Klone, `b22f330` gegen `ef22f72`, je
mit ihrem eigenen gelebten `Makefile`; `-o` schaltet die neun teuren Checks ab und lässt
`docs-check` real laufen und fallen:

| Klon | Kantenform | roter Check | Stempel danach |
|---|---|---|---|
| `b22f330` | `gates: <checks> record-gates` | `d-check: 457 Datei(en) geprüft, 1 Befund(e)`, Exit 2 | **existiert** (`caa656ff…`) |
| `ef22f72` | `gates: record-gates`, `record-gates: <checks>` | `d-check: 462 Datei(en) geprüft, 1 Befund(e)`, Exit 2 | **existiert nicht** |

Derselbe rote Check, dieselbe Aufruf-Zeile, einziger Unterschied die Kantenform. **Und der grüne
Pfad trägt weiter** — Positiv-Kontrolle über dem `ef22f72`-Klon mit allen zehn Checks als *alt*
markiert: **Exit 0**, Stempel geschrieben, Inhalt `c9b1d232…` — identisch mit
`bash harness/tools/working-tree-hash.sh` über dem Arbeitsbaum, was zugleich belegt, dass der Klon
inhaltlich der Arbeitsbaum ist.

Die DoD ließ für die Reihenfolgen-Zusage zwei Ausgänge; geliefert ist der zweite (Einschränkung in
derselben Zeile), und beide Hälften sind unter §6, Risiko 2 gemessen.

**(2) Jede tragende Stelle sagt, was der Code hält — ERFÜLLT im Gebundenen.**

#### Der Haken zu (2)

**Das Abhak-Kommando dieses DoD-Punktes erreicht seine eigenen gebundenen Stellen nicht mehr, und
das ist kein Defekt, sondern sein Erfolg in einer Form, die man nicht abhaken kann.** Selbst
gemessen, beide Stände:

- gegen `b22f330`:
  `git grep -inE 'gruenen (Gates|Checks)|grünen (Gates|Checks)' b22f330 -- ':!docs/reviews' ':!docs/plan/planning/done' ':!.harness/baseline' ':!*slice-138-*' | wc -l`
  → **4**. Die in der DoD zugesagte Menge **war** die tatsächliche.
- gegen `ef22f72`, dasselbe Kommando ohne Revision → **2**, und beide liegen unter
  `internal/emit/templates/enforce/` (`enforce.mk:7`, `record-gates.sh:4`) — also **beide
  emittiert, keine im Dogfood**.

Die zwei gebundenen Stellen sind aus der Menge ihres eigenen Finders gefallen, **weil** die
Reparatur ihnen die Formulierung genommen hat, die der Finder sucht. Wer den Haken mit diesem
Kommando setzt, sieht die Stellen nicht, die der Punkt bindet, und muss den Schluss von außen
mitbringen. Ich habe ihn deshalb **nicht** damit gesetzt, sondern mit einer Messung, die die
gebundene Menge über ihre **Adresse** und ihren **Ziel-Zustand** fasst statt über den Wortlaut des
Defekts:

```
for f in Makefile harness/tools/record-gates.sh; do
  printf '%s  zurueckgenommen=%s  GRENZE=%s\n' "$f" \
    "$(command grep -ciE '(nur )?(nach|bei) (gruenen|grünen) (Gates|Checks)' "$f")" \
    "$(command grep -c '^# GRENZE' "$f")"
done
```

→ `Makefile  zurueckgenommen=0  GRENZE=1` und
`harness/tools/record-gates.sh  zurueckgenommen=0  GRENZE=1`. Der Unterschied zum DoD-Kommando ist
nicht die Schärfe, sondern die **Unterscheidungskraft**: dieses hier fällt auseinander, wenn eine
der zwei Dateien verschwindet oder umbenannt wird, das DoD-Kommando bliebe auch dann stumm.

**Die drei Wege, die DoD (2) namentlich bindet, sind je einzeln nachgewiesen.**
`for w in 'make -i' 'make record-gates' 'make -j'; do command grep -cF "\`$w\`" Makefile; done` → **1**,
**1**, **1** — jeder steht an der Zusage-Stelle. Der mittlere steht dort als **geschlossen**, und
das ist die andere Hälfte der Plan-Disjunktion: `diff <(make -n gates) <(make -n record-gates)` ist
**leer** (Exit 0), von mir gefahren. Über die vier weiteren Mechanismen, die spätere Runden
hinzugenommen haben (`MAKEFLAGS=i`, `.IGNORE:`, das `-`-Rezept-Präfix, `-o`/`-W`), sagt DoD (2)
nichts; ihre Messungen habe ich **nicht** wiederholt — dafür ist der Bericht der Verifikation
Eingabe, und er hat sie wörtlich aus dem Wächter-Kopf extrahiert und gefahren.

**(3) Die Kante hat einen Wächter — ERFÜLLT in der Lieferung, offen in einer Teilzusage.**

#### Der Haken zu (3)

**Der Liefer-Teil ist eingelöst, und der tragende Arm ist von mir gefahren.** Der Wächter liegt
**in** `make gates`: mein Lauf führt ihn als `ok 74`–`ok 78` von `1..195`. Er liest den gelebten
`Makefile`, und der Beleg dafür ist ein Lauf, keine Lektüre — Fall `210` über einem Klon von
`ef22f72` ändert genau **eine** Zeile der Wurzel-Datei, und `make test-bats` meldet

```
not ok 74 gate-nachweis: record-gates haengt an den Checks (Ordnungskante steht)
```

zeichengleich mit der `# expect:`-Zeile des Falls; dazu `not ok 77` und `78` als benannte
Subsumtion und die zwei `CO-004`-Zeilen. Unmutiert sind alle fünf grün (mein Gate-Lauf über
denselben Inhalt). Die vier übrigen Fälle habe ich **nicht** neu gefahren; sie liegen ausführbar im
Treiber-Format vor (`git ls-files -s test/mutations/21[0-4]*.sh` → je `100755`), und ihr Rot ist
von der Verifikation unabhängig nachgestellt — für sie ist deren Protokoll **Eingabe**.

**Die Teilzusage ist nicht eingelöst, und der Haken behauptet sie nicht.** DoD (3) schließt mit
*„Der Fall ist einmal durch `make mutate` gelaufen und meldet keinen BEFUND auf sich selbst"*, §5
führt denselben Lauf als Closure-Kriterium. Er ist **heute nicht herstellbar**: `green_prerun`
fährt jeden benutzten Modus einmal und bricht fail-closed ab, solange einer rot ist
(*„mutate: ABBRUCH — make $m ist in der isolierten Kopie ohne Mutation rot"*), und `test-bats`
**ist** rot durch [`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md)
(`not ok 40`/`41` in meinem Lauf). Einen Einzelfall-Modus gibt es nicht:
`command grep -c 'MUTATE_CASES' harness/tools/mutate.sh` → **0**, Exit 1.

**Was der Ersatz deckt:** die vier Bedingungen, die `run_case` prüft — die Mutation greift, sie hat
die in `# files:` gelistete Datei geändert, der Sensor wird rot, und die **benannte** Zusage fällt —
plus den Grün-Bezug, den der Treiber sonst als Vorlauf herstellt. **Was er nicht deckt**, und das
gehört an dieselbe Stelle: die Isolations-Fingerabdruck-Prüfung mitten im Lauf, die
Doppelkopf-Erkennung als **Lauf** statt als Lektüre, und die Vollständigkeits-Bilanz über **alle**
Fall-Dateien. Die dritte ist ohnehin ein Wellen-Kriterium
([welle-10](../welle-10-re-baseline.md) §3).

**Träger des offenen Laufs ist
[slice-130](../in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md)** — der Folge-Slice von
`CO-004`; mit dessen Grün wird `make mutate` zum ersten Mal wieder fahrbar, und die fünf neuen Fälle
sind dann Teil seiner vollen Menge. Präzedenz für genau diesen Zuschnitt:
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §7, dort als *weiter
offen, mit Träger* geschlossen.

### Die sieben Standard-Punkte

**`make gates` ohne slice-eigenen Befund — ERFÜLLT.** Der Vorher-Nachher-Vergleich derselben
Ausgabe, beide Stände von mir gefahren:

| Ziel | `b22f330` | `ef22f72` | Zurechnung |
|---|---|---|---|
| `docs-check` | `457 Datei(en) geprüft, 1 Befund(e)` | `462 Datei(en) geprüft, 1 Befund(e)` | dieselbe Zeile: `harness/conventions.md:1019 … target-missing` = [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) |
| `test-bats` | `1..190`, `not ok 40`/`41` | `1..195`, `not ok 40`/`41` | dieselben zwei = [`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md); je `command grep -cE '^not ok '` → **2** |
| übrige acht | — | grün | — |

`command grep -cE '^not ok ' <log>` → **2**, keine dritte rote Zeile. Grün und selbst gesehen:
`baseline-verify: v5.12.0 OK — 51 Dateien`, `lint`, `build`, `test-go`, `shell-lint`, `ci-lint`,
`comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`, `host-bin`, `span-check`. Die Differenz **5**
in der bats-Zahl sind die fünf neuen Zusagen, alle grün. **`make gates` grün ist kein
Closure-Kriterium dieses Slice** — beide roten Ziele sind fremde, offene Carveouts mit eigenen
Folge-Slices.

**Doku-Update — ERFÜLLT, kein Trigger.** Kein öffentlicher Vertrag ist berührt:
`git diff --name-only b22f330..ef22f72 -- spec/ .harness/baseline/ | wc -l` → **0**. Der emittierte
Aggregator trägt die Kante seit je
(`command grep -nE '^(gates|record-gates):' internal/emit/makefile.go` → **2** Zeilen) und ist über
die ganze Kette unberührt.

**Closure-Notiz mit Steering-Loop-Lerneintrag — ERFÜLLT**, unten, zwei Einträge.

**Reconciliation-Register — entfällt**, dauerhaft und aus einem Grund außerhalb dieses Slice: das
Repo hat keinen Brownfield-Bootstrap.

**Beobachtungs-Register — es existiert nicht, und genau das verlangt die DoD hier zu notieren.**
`find docs/plan -iname '*observation*' -o -iname '*beobacht*'` liefert **einen** Treffer, und der ist
[slice-137](../open/slice-137-beobachtungs-register-bekommt-seinen-ort.md) — der Slice, der es erst
anlegt. Die Folge ist nicht bloß buchhalterisch: **beide** Lerneinträge unten und der *weiter
offen*-Ausgang aus §6 hätten dorthin gehört (Modul 5 §Offene Risiken · Modul 10 §Pflege), und
alle vier Review-Runden haben denselben Zähler vermisst. Sie stehen deshalb hier, wo sie ein
späterer Lauf nur findet, wenn er diesen Slice liest.

**Jedes Risiko aus §6 trägt einen Ausgang — ERFÜLLT**, sechs von sechs, je genau einer, jeder mit
seiner Messung in §6 selbst. Bilanz: **zwei entfallen**, **eines eingetreten**, **drei weiter
offen**.

**Die drei Paarungen — nicht hier fällig.** Dieses Repo fährt Wellen-Betrieb; Anker, Folge-Slice
und Register prüft die nächste Welle-Closure. Was sie von hier erbt, steht in einem Satz: **zwei**
Steering-Loop-Einträge ohne `liegt in` (gezählt, nicht verkörpert), **drei** *weiter offen*-Ausgänge
in §6 und **fünf** Folge-Posten ohne Träger (zwei davon sind dieselben zwei §6-Ausgänge), und
für alle ist die Ursache derselbe fehlende Zähler.

### Was funktionierte

**Die Mechanik war ab dem ersten Commit richtig und ist es geblieben.** Über vier Review-Runden hat
**kein** Befund die Ordnungskante selbst getroffen — gemessen: die Fix-Commits `f275092` und
`434d4fa` enthalten **0** Nicht-Kommentarzeilen, `cb85f15` ändert allein den Kommentar-Block
(`git show --stat cb85f15` → `Makefile | 13 +++---`), und `test/gate-nachweis-kante.bats` ist ab
`setup()` seit `5a75f97` unverändert. Was vier Runden gekostet hat, war ausschließlich der Text
**neben** der Mechanik.

**Die Wächter-Frage aus §1 hat sich als richtig gestellt erwiesen.** Der Plan hat sie mit *„Sensor
bauen"* beantwortet statt mit *„bewusst kein Sensor"*, und der gebaute sitzt **in** `make gates`
(`ok 74`–`ok 78`), liest die gelebte Datei und hat fünf Zähne. **Die Kommentar-Hälfte desselben
Slice hängt an keinem:** der `Makefile` liegt dauerhaft außerhalb von `make comment-claims`
(`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | command grep -c '^Makefile$'`
→ **0**, Exit 1), und für `harness/tools/record-gates.sh` sagt das Grün dieses Gates über den
gemeinten Sensor nichts (Folge-Posten 3). Die tragende Arbeit von vier Fix-Runden ruht damit auf
Rollen-Durchgängen.

### Was ging anders als geplant

**Fünf Mutations-Fälle statt „ein Fall", fünf Zusagen statt einer Eigenschaft.**
`git diff --name-only b22f330..ef22f72 -- 'test/mutations/*' | wc -l` → **5**,
`command grep -c '^@test ' test/gate-nachweis-kante.bats` → **5**. Die Abweichung ist
**regelgetrieben**: [`AGENTS.md`](../../../../AGENTS.md) §3.6 verlangt zu **jeder** Zusage die rot
färbende Mutation, und zwei der fünf Zusagen entstanden erst aus Review 1. Die ≤-3-Regel ist
unberührt — die DoD hat unverändert drei Liefer-Punkte. **Die Plan-Tabelle §3 bleibt unangetastet**:
sie heißt *„Plan (vor Code)"*, und ein nachgetragener Zusatz machte die fünf Zeitdokumente
unlesbar, die gegen genau diesen Text gemessen haben. Der Ort für die Abweichung ist dieser Absatz.

**Vier Fix-Runden, und der Ausschlag ist erst in der dritten gekippt.** Der Kommentar-Bestand über
die drei berührten Blöcke, je Commit:

```
for c in 07dc762 5a75f97 f275092 434d4fa cb85f15; do
  a=$(git show $c:Makefile | awk '/^# ORDNUNGSKANTE/,/^record-gates:/' | command grep '^#' | wc -c)
  b=$(git show $c:test/gate-nachweis-kante.bats | awk '/^setup\(\)/{exit} {print}' | command grep '^#' | wc -c)
  d=$(git show $c:harness/tools/record-gates.sh | awk '/^set -euo/{exit} {print}' | command grep '^#' | wc -c)
  printf '%s  %s\n' "$c" "$((a+b+d))"
done
```

→ **4775** → **8295** → **11173** → **9872** → **9969** Zeichen. Die ersten zwei Fix-Runden haben
Messungen **danebengestellt**, die dritte hat **gestrichen und eingeschränkt**, die vierte hat einen
Halbsatz getilgt und einen Vorbehalt gesetzt (netto **+97**). Nur die dritte hat den Bestand
gesenkt, und nur ab ihr haben die Gegenproben des nächsten Reviews den Text **bestätigt** statt
widerlegt. Das ist der Anlass des ersten Lerneintrags.

**Drei Vollständigkeitsaussagen stehen in geschriebenen Commit-Messages, jede um genau eins zu
weit** — [`AGENTS.md`](../../../../AGENTS.md) §3.6 bindet die Commit-Message ausdrücklich als
Zusage. Sie lassen sich ohne Historien-Umschrift nicht korrigieren; die Reviews haben ihren Ort
darum hierher gelegt. **Richtiggestellt, jede mit ihrem Kommando:**

1. `434d4fa` sagt *„zu allen drei Klassen Kommando und Ausgabe"*. Es sind **zwei von drei** — für
   den Aufruf an `make` vorbei steht im Wächter-Kopf ein Satz und kein Kommando. Der Kopf führt
   **30** Mess-Zeilen
   (`awk '/^setup\(\)/{exit} {print}' test/gate-nachweis-kante.bats | command grep -cE '^#   '`),
   und **0** davon nennen diesen Weg (dieselbe Ausgabe, dann
   `command grep -ciE 'vorbei|record-gates\.sh|bash harness'`, Exit 1).
2. `434d4fa` sagt *„alle sieben doppelt gefuehrten Aussagen sind im Makefile verschwunden"*. Es
   sind **sechs von sieben**; Paar (4) steht weiter in beiden Dateien —
   `command grep -c 'ohne Flag\|OHNE Flag' Makefile test/gate-nachweis-kante.bats` → je **1**.
   Die Sieben war zudem selbst eine Untermenge, keine Zählung.
3. Aus dem Haupt-Kontext, nicht vom Implementer: die Behauptung, der Grenz-Block schließe mit
   *„KEIN vierter Weg"* eine vollständige Menge ab. Real schreiben auch `.IGNORE:` und ein
   `-`-Rezept-Präfix den Stempel, **ohne Flag am Aufruf**. Der Satz ist seit `5a75f97` getilgt;
   die Aussage über ihn bleibt als das stehen, was sie war.

**Warum das hier steht und nicht als Folge-Slice:** ihr Träger ist eine geschriebene
Commit-Message. Ein Slice über sie hätte kein Artefakt zu ändern.

### Steering-Loop-Einträge — zwei, und warum nicht einer

Beide sind **geschärfte Regeln**. Sie teilen einen Mechanismus — *das Instrument wird am Befund
geeicht statt an der Eigenschaft* —, aber sie versagen in **entgegengesetzte** Richtungen und haben
**verschiedene Adressaten**; zu einer Regel verschmolzen wäre keiner der beiden Rollen mehr
gesagt, was sie tun soll. Deshalb zwei.

#### (I) Auf „die Aussage reicht weiter als ihr Beleg" antwortet man, indem man die Aussage einschränkt — nicht, indem man eine Messung danebenstellt

**Die Klasse:** Wird eine Grenz-, Beleg- oder Vollständigkeitsaussage als *weiter als ihr Beleg*
beanstandet, gibt es zwei Korrekturen. *Messung danebenstellen* schließt genau die Lücke, die der
Befund gezeigt hat, und lässt die nächstinnere Ebene ihre Einschränkung erben — die Klasse kehrt
eine Ebene tiefer wieder. *Aussage einschränken* macht den Satz an seinem eigenen Instrument
wahr und ist damit gegen die **noch nicht gefundene** Instanz robust.

**Der gemessene Anlass — vier Runden, vier Gestalten, eine Klasse.** Alle vier Review-Reports haben
sie als Steering-Loop-Signal geführt: gezählte Wege-Liste (`a25e33c`) → Beleg-Zeiger (`02d3637`) →
Instrument innerhalb eines Weges (`d949090`) → **Ort** der Messung, quer zu den drei anderen
(`d280f35`). Die ersten zwei Korrekturen waren additiv, die dritte subtraktiv-restriktiv — und die
Zahlen oben (*Was ging anders als geplant*) zeigen den Bruch: der Bestand fällt zum ersten Mal in
`434d4fa`, und die zwei Sonden des nächsten Reviews, die drei Runden lang Befunde erzeugt hätten,
**bestätigen** den Text.

**Warum das eine Regel ist und kein Sensor.** Ein Gate müsste beurteilen, ob eine Aussage weiter
reicht als das, was an ihrer Stelle steht — ein Urteil, kein Muster. Der nächstliegende Kandidat
liegt zudem dauerhaft daneben: `make comment-claims` prüft **vier** Pfad-Muster, und der `Makefile`,
in dem die Klasse dreimal saß, fällt unter keines
(`git ls-files 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh' | command grep -c '^Makefile$'`
→ **0**, Exit 1). Ein behaupteter Wächter wäre genau das stille Grün aus
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).

**Adressat und Grenze.** Der Regeltext gehörte an [`AGENTS.md`](../../../../AGENTS.md) §3.6 —
neben *„die Zusage auf das einschränken, was der Code hält"*, wo heute die Richtung der Korrektur
nicht steht — und damit dem **Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.8). **Dieser Lauf
hat ihn dort nicht eingetragen**; das Feld `liegt in` entfällt darum ersatzlos, der Eintrag ist
**gezählt, nicht verkörpert** (`grundlagen-traceability.md` §Herkunfts-Anker).

#### (II) Ein DoD-Punkt, der seine gebundene Menge über ein Kommando definiert, adressiert sie über den Ziel-Zustand oder über eine Adresse — nie über den Wortlaut des Defekts

**Die Klasse:** Ein Abhak-Kommando, das den **Wortlaut des Defekts** sucht, ist genau dann leer,
wenn der Punkt erfüllt ist — und ebenso leer, wenn die gebundene Stelle gelöscht, umbenannt oder
nie repariert, sondern nur umformuliert wurde. Es kann Erfolg von Verschwinden nicht unterscheiden.
Ein Kommando über den **Ziel-Zustand** (was nach der Reparatur dastehen muss) oder über die
**Adresse** (welche Dateien gebunden sind) kann es.

**Der gemessene Anlass.** DoD (2) dieses Slice hat seine Menge als Kommando statt als Liste
definiert — richtig so — und dabei den Defekt-Wortlaut gesucht: gegen `b22f330` **4** Fundorte
(2 Dogfood / 2 emittiert, wie zugesagt), gegen `ef22f72` **2**, beide emittiert. Die **korrekte**
Reparatur hat die zwei gebundenen Stellen aus der Menge ihres eigenen Finders herausgeschrieben. Die
Ersatz-Messung, mit der der Haken oben gesetzt ist, unterscheidet die zwei Fälle.

**Der zweite Teil derselben Klasse: das Instrument war auch als Beleg-Zeiger schon zu weit.**
Vier weitere Zahlen in §1/§2 dieses Plans stehen heute neben Kommandos, die sie nicht mehr ausgeben
— gemessen, jede einzeln:

| Stelle | im Plan | heute | Ursache |
|---|---|---|---|
| DoD (2), Fundorte | **4** (2 Dogfood / 2 emittiert) | **2**, beide emittiert | die Reparatur dieses Slice |
| §1, Ziele an `gates:` | **10** | **0** (Exit 1) | die Kante — dieselbe Zahl liefert heute `sed -n 's/^record-gates: \(.*\) ##.*/\1/p' Makefile \| tr ' ' '\n' \| command grep -vc '^record-gates$'` → **10** |
| §1, Behauptungs-Wörter in `record-gates.sh` | **0** | **1** (`verhindert`) | der neue Kopf dieses Slice |
| §1, Dateien mit `record-gates\|stop-require-gates` in Tests | **4** | **5** | der neue Wächter dieses Slice |

**Alle vier sind Folgen der Lieferung, keine Fehler** — und genau darum ist die Klasse gefährlich:
ein Plan, der seinen Befund misst, wird von seiner eigenen Reparatur überholt.

**Die Entscheidung: §1 bis §6 werden nicht nachgezogen, §7 trägt den Stand.** Drei Gründe, und der
erste allein trüge. **(a)** §1 ist die Beschreibung des **Befundes zum Schnitt-Zeitpunkt**; die
Zahlen auf HEAD zu ziehen hieße, den Befund zu löschen und den Plan sagen zu lassen, es habe nie
ein Problem gegeben. **(b)** Fünf Zeitdokumente — vier Review-Reports und die Verifikation — haben
gegen genau diesen Text gemessen; ein nachgetragener Zusatz macht sie unlesbar (Präzedenz
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §7). **(c)** Ein Planner,
der seinen Befundtext nachträglich so umschreibt, dass er die eigene Reparatur überlebt, begeht die
Klasse, die dieser Slice vier Runden lang bekämpft hat. **Der Preis ist benannt:** bis zum `git mv`
ist dieser Plan ein lebendes Artefakt und trägt Zahlen, die ihre Nachbar-Kommandos nicht ausgeben —
formal ein Verstoß gegen
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1. Die Tabelle oben ist die Wiedergutmachung an dem Ort, der jetzt geschrieben wird.

**Warum das eine Regel ist und kein Sensor.** Ob eine Zahl in einer Messwert-Rolle steht, ist ein
Urteil, kein Muster — dieselbe Absage, die
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Auflösungs-Trigger für sich selbst gemessen hat; kein Modul des Doku-Gates fährt einen Lauf.

**Adressat und Grenze — und hier liegt die eigentliche Beobachtung.** Der Regeltext gehört in die
**Ziel-Form des Slice-Plans**, also zum **Planner**; sein natürlicher Ort wäre das
`slice.template.md` der Baseline, und das ist committet vendored Fremd-Bestand
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)),
den dieses Repo spiegelt statt schreibt. Ein repo-eigener Ort für Planner-Ziel-Form existiert nicht,
und ihn zu erfinden ist kein Closure-Zug. **Der Eintrag ist damit ebenfalls gezählt, nicht
verkörpert**, `liegt in` entfällt.

**Was diese Klasse strukturell interessant macht:** sie war für **vier** Review-Runden unsichtbar
und nicht aus Nachlässigkeit. Der Reviewer misst den Diff gegen Plan und ADR — er sieht nicht, dass
das Kommando **des Plans** blind geworden ist. Erst die Verifikation, die die DoD-Kommandos
**fährt**, konnte es finden. Das ist eine Eigenschaft der Rollen-Kette, nicht eines Laufs.

### Ausgänge — jeder Posten hat einen, *„genannt"* ist keiner

| Posten | Herkunft | Ausgang |
|---|---|---|
| Grenz-Aufzählung behauptet *„KEIN vierter Weg"* | Review 1 `MEDIUM-1` | **erledigt** in `5a75f97` — das Zählwort ist getilgt, die Nicht-Abschluss-Aussage steht: `command grep -c 'Dass es keinen weiteren Weg gibt, steht hier NICHT' Makefile` → **1** |
| Der **Inhalt** der Kante ist unbewacht | Review 1 `MEDIUM-2` | **erledigt** in `5a75f97` — Zusage 4 plus Fall `213`; heute `ok 77` in meinem Gate-Lauf |
| Reihenfolgen-Zusage ohne Gegenbeispiel | Review 1 `MEDIUM-3` | **erledigt** in `5a75f97` — Zusage 5 plus Fall `214`; heute `ok 78` |
| Zwei Zusage-Stellen widersprechen sich über `-j` | Review 1 `LOW-1` | **erledigt** in `5a75f97` |
| Übergabe an den Architect ruht auf einer unzutreffenden Aussage über [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) | Review 1 `LOW-2` | **erledigt hier** — der Auftrag ist korrigiert (§6, Risiko 5: *unvollständig*, nicht *falsch*) |
| Beleg-Zeiger weiter als der Beleg (`-j`, `-W`) | Review 2 `MEDIUM-1` | **erledigt** in `f275092` |
| Muster enger als die Aussage · zweiter Bestand · Grenz-Kategorie · Verweis ohne Ziel | Review 2 `LOW-1`–`LOW-4` | **erledigt** in `f275092` |
| Instrument enger als die Aussage (drei Schreibweisen) | Review 3 `MEDIUM-1` | **erledigt** in `434d4fa` — und in Review 4 gegengeprobt: die drei Schreibweisen bestätigen den Text jetzt |
| Sieben Aussagen doppelt geführt | Review 3 `LOW-1` | **zu 6 von 7 erledigt** in `434d4fa`; Paar (4) steht, oben richtiggestellt |
| Aussage und Instrument treffen den **Ort** nicht | Review 4 `MEDIUM-1` | **erledigt** in `cb85f15` — die Begründung ist gestrichen, der Ort-Vorbehalt steht |
| Zwei Vollständigkeitsaussagen in Commit-Messages | Review 4 `MEDIUM-2`, `LOW-1` · Verifikation `V-3` | **richtiggestellt hier** (*Was ging anders als geplant*), nicht korrigierbar am Träger |
| Die Partition (a)/(b) trennt nicht nach ihrem eigenen Kriterium | Verifikation `V-4` | **entschieden: bleibt** — Review 4 hat die Schärfung mit Begründung verworfen (jede Fassung führte die gerade getilgte Ort-Behauptung wieder ein); die Deckungs-Aussage ist ganz nachgerechnet und hält |
| `make comment-claims` grün sagt für die neue Zusage nichts | Verifikation `V-5` | **weiter offen, ohne Träger** — unten, dritter Posten |
| Plan-Tabelle §3 bildet den Ist-Stand nicht ab | Verifikation `V-6` | **hier vermerkt**, §3 unangetastet (*Was ging anders als geplant*) |
| `make mutate` nicht herstellbar | Verifikation `V-1` | **entschieden: Haken mit benanntem Ersatz**, Lauf weiter offen mit Träger [slice-130](../in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) (*Der Haken zu (3)*) |
| Das Abhak-Kommando von DoD (2) erreicht seine gebundenen Stellen nicht mehr | Verifikation `V-2` | **entschieden: Ersatz-Messung statt Kommando, Plan-Text unangetastet** (*Der Haken zu (2)*, Lerneintrag II) |
| *„Bewacht sind beide Hälften"* ohne Vorbehalt | Review 4 `LOW-2` | **weiter offen, ohne Träger** — unten, vierter Posten |
| Struktur-Grenze der Kante hat nur im Slice-Plan ein Zuhause | Review 4 `INFO-1` | **weiter offen, ohne Träger** — unten, fünfter Posten; mit dem `git mv` wird der Plan zum Zeitdokument |

### Folge-Posten ohne Träger — fünf, benannt statt gelöst

Keiner ist hier geschnitten, und das ist eine Entscheidung: eine Closure-Notiz gebiert keinen
Slice-Plan; der entsteht im Planungs-Lauf (Präzedenz
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) §7). Sie stehen hier,
damit der nächste Planner-Lauf sie findet.

1. **Der Ergebnis-Nachweis** (§6, Risiko 3). Kein Rezept liest, **ob** die Gates grün waren; das
   verlangte eine Quittung je Ziel. Beobachtbarer Trigger, aus §6 übernommen: *ein zweiter Stempel
   über rotem Lauf ist auf einem anderen Weg als `-k` entstanden*. Davor wäre es Härtung ohne
   Auslöser (`modul-13-quality-gates.md` §Guard-Härtung).
2. **Die emittierte Ebene ohne Grenz-Zeile** (§6, Risiko 4). Ihre Kante steht und ist bewacht, ihre
   zwei Zusage-Stellen tragen unverändert die hier zurückgenommene Formulierung. Andere Ebene,
   anderer Vertrag ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
   andere Sensoren (`make smoke`, `make full-smoke`).
3. **Das `SENSOR`-Muster von `make comment-claims`.** Die Sensor-Nennung im neuen Kopf von
   `record-gates.sh` ist maschinell **nicht** an den gemeinten Sensor gebunden. Der Gate prüft den
   **Block**, nicht die Zeile (`harness/tools/comment-claims.sh:22`), und sein Muster ist weit —
   `command grep -n '^SENSOR=' harness/tools/comment-claims.sh` zeigt unter anderem
   `make [a-z][a-z-]*`. Erfüllt ist die Nennung damit schon vom `` `make gates` `` der Titel-Zeile
   (`command grep -n 'make gates' harness/tools/record-gates.sh` → Zeile **2**), und die steht dort
   seit der Anlage der Datei — `git log --follow --diff-filter=A --format='%ad %h' --date=short -- harness/tools/record-gates.sh`
   → `2026-06-13 f7576ca` (**ohne** `--follow` liefert dasselbe Kommando `2026-06-14 f87013a`, den
   reinen Move aus `tools/harness/`). Erst mit **allen** `SENSOR`-Treffern entfernt wird der Gate
   rot. [slice-070](../open/slice-070-comment-claims-pruefbereich.md) deckt es **nicht** — dort geht
   es um den Prüfbereich, hier um Granularität und Muster.
4. **Der Härtungs-Kandidat: `.IGNORE:` und das `-`-Rezept-Präfix strukturell schließen.** Beide
   leben **im `Makefile` selbst** und wären damit strukturell prüfbar, statt nur deklariert zu
   werden. Der Auslöser fehlt heute (`sed -n '/^ *\.IGNORE/p' Makefile d-check.mk | wc -l` → **0**,
   `sed -n '/^\t[@+-]*-/p' Makefile d-check.mk | wc -l` → **0**), und `modul-13-quality-gates.md`
   §Guard-Härtung verlangt eine **dreimal beobachtete** Umgehung.
5. **Die unbedingte Zusage *„Bewacht sind beide Hälften dieser Liste"*** (`Makefile`, neben der
   Kante) gegen den Wächter, der an seiner eigenen Stelle sagt, seine Erwartungsliste sei *„eine
   ZWEITE BUCHFUEHRUNG, kein unabhaengiger Beleg"*: wer beide zugleich ändert, kommt vorbei. Der
   Satz ist byte-unverändert seit `5a75f97` und damit älter als der Befund. **Und derselbe Zug
   trägt einen zweiten Posten:** mit dem `git mv` verliert die Struktur-Grenze der Kante (*sie
   bindet die Reihenfolge, nicht den Ausgang*) ihren letzten lebenden Ort — heute steht sie nur
   noch in diesem Plan.

### Übergabe an den Architect

**Gegenstand:**
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
§Adaption. Der Eintrag ist **nicht falsch, sondern unvollständig** — die Messung steht in §6,
Risiko 5. Er sagt *„`record-gates` als letzter `gates`-Prerequisite"*, und das bleibt wahr;
er benennt die **Ordnungskante** nicht, die die Zusage seit diesem Slice trägt, und ohne sie
beschreibt er eine Mechanik, deren tragendes Stück fehlt. Wer ihn wörtlich nimmt, korrigiert einen
Satz, der stimmt.

Dazu, aus dieser Closure: der Regeltext von **Lerneintrag (I)** gehörte an
[`AGENTS.md`](../../../../AGENTS.md) §3.6. Beides ist Architect-Arbeit in einem eigenen Commit
([`AGENTS.md`](../../../../AGENTS.md) §3.8) und **kein** Closure-Kriterium dieses Slice (§5).
**Was diese Übergabe nicht ist:** ein fertiger `MR-<NNN>`-Text.

### Verifikation dieser Closure

Gefahren und oben zitiert: `make -k gates` über `ef22f72` · `make -k -o … gates` über zwei Klonen
(`b22f330`, `ef22f72`) · `make … gates` als Positiv-Kontrolle · `make test-bats` über einem Klon
mit Fall `210` · `diff <(make -n gates) <(make -n record-gates)` · die Ersatz-Messung zu DoD (2) ·
die Bestands-Kommandos zu §6 und zu den vier Plan-Zahlen. **Nicht gefahren:** `make mutate` (Grund
oben) und die vier übrigen Mutations-Fälle (dafür ist die Verifikation Eingabe).

**Diese Notiz selbst ist gegen den Doku-Gate gehalten:** `make docs-check` über dem Baum dieser
Closure → `d-check: 462 Datei(en) geprüft, 1 Befund(e)`, und der eine ist
`harness/conventions.md:1019 … target-missing` =
[`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) — dieselbe Zahl und derselbe
Befund wie im Gate-Lauf über `ef22f72`. Der Text dieser Sektion bringt keinen zweiten hervor.

**Die Grenzen dieser Closure, weil sie sonst nirgends stünden.** Ein fünfter Review-Durchgang nach
Modul 10 hat **nicht** stattgefunden; was Review 4 blockierend fand, schließt `cb85f15` plus die
unabhängige Nachmessung der Verifikation. **Kein Posten dieser Closure ist als Slice geschnitten** —
fünf stehen als benannte Posten da, und ihr Register existiert nicht. Und der Plan trägt bis zum
`git mv` vier Zahlen, deren Nachbar-Kommandos sie nicht ausgeben; die Entscheidung dazu steht in
Lerneintrag (II), ihr Preis ist dort benannt.

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind der `Makefile` in der Wurzel,
`harness/tools/` und `test/`. Alle drei fallen unter den Eintrag `*` (gesamtes Repo) der
Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) —
**alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit. Eine eigene Sub-Area
für die Durchsetzungsschicht auszudifferenzieren wäre hier ohne Gegenstand: der Slice ändert eine
Abhängigkeitszeile und zwei Kommentare und legt einen Sensor daneben; er baut keine
Konventions-Dichte auf, die eine eigene Zeile in der Deklaration trüge.

**Vorgelagert — offene Beobachtungen sichten:** **keine Treffer**, und der Grund liegt außerhalb
dieses Slice: ein Beobachtungs-Register existiert im Repo nicht
(`find docs/plan -iname '*observation*' | wc -l` → **0**), sein Träger ist
[slice-137](../open/slice-137-beobachtungs-register-bekommt-seinen-ort.md). Läuft dieser Slice
nach jenem, wird die Sichtung nachgeholt und ihr Ergebnis in §7 notiert.
