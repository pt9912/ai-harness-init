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

- [ ] **(1) Über einem roten Ziel entsteht kein Stempel mehr, und das Gegenbeispiel ist vorher rot
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
- [ ] **(2) Jede Stelle, die die Zusage trägt, sagt, was der Code hält — und die Wege, die offen
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
- [ ] **(3) Die Kante hat einen Wächter, und der entsteht hier.** Ein Sensor prüft die Eigenschaft
      am **gelebten** `Makefile` — nicht an einer Nachbildung, die sich selbst misst —, und ein
      Fall in `test/mutations/` hebt sie auf und färbt genau diesen Sensor rot, mit `# expect:` auf
      seinen Namen. Vorbild eine Ebene weiter: `test/mutations/38-gen-aggregator-order-edge.sh`.
      Der Fall ist einmal durch `make mutate` gelaufen und meldet keinen BEFUND auf sich selbst;
      einen Einzelfall-Modus hat der Treiber nicht (`grep -c 'MUTATE_CASES' harness/tools/mutate.sh`
      → **0**), der Lauf geht also über die volle Fall-Menge.
- [ ] `make gates` bringt **keinen Befund hervor, der diesem Slice zuzurechnen ist** — der Lauf
      trägt zum Schnitt-Zeitpunkt zwei offene Carveouts
      ([`CO-004`](../../carveouts/CO-004-emitter-klassifikation-offen.md) auf `test`,
      [`CO-005`](../../carveouts/CO-005-adaptions-block-datierter-beleg.md) auf `docs-check`),
      beide fremde Posten mit eigenen Folge-Slices. Verlangt ist der Vorher-Nachher-Vergleich
      derselben Ausgabe.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — hier keiner: der emittierte
      Aggregator trägt die Kante bereits (Kopf, Absatz *Ebene*), und was dort offen bleibt, steht
      in §6.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap und führt keines; das Item
      entfällt.
- [ ] Beobachtungs-Register fortgeschrieben — **falls es zum
      Ausführungszeitpunkt existiert**; sein Träger ist
      [slice-137](../open/slice-137-beobachtungs-register-bekommt-seinen-ort.md), und die
      Reihenfolge der beiden ist frei. Existiert es nicht, wird genau das in §7 notiert, statt
      das Item stumm zu lassen.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure — dieses
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
[slice-130](../open/slice-130-emitter-entscheidet-jedes-neue-template.md), und das ist kein Vorzug,
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
  **Ausgang:** eingetreten (dann ist es der gewollte Zustand: kein Nachweis über rotem Baum, und
  die Meldung des Hooks sagt es) | entfallen, wenn `CO-005` vorher aufgelöst ist.
- **`-j` bricht die Reihenfolgen-Zusage, und die Kante ordnet nicht.** Eine Kante sagt *hängt ab
  von*, nicht *läuft danach*; unter Parallelität fällt die Zusage *„`baseline-verify` als ERSTER"*
  (`Makefile:296-298`). Gemessen ist, dass das Rezept die Parallelität sieht (`MAKEFLAGS` trägt
  `-j4 --jobserver-auth=…`, §1); **ungemessen** ist, ob die zehn Docker-Ziele dieses Repos
  parallel überhaupt tragen. — **Ausgang:** entfallen, wenn die gewählte Form die Reihenfolge unter
  seriellem `make` erhält **und** die Zusage genau das sagt | eingetreten: `-j` wird geschlossen
  oder die Zusage auf den seriellen Fall eingeschränkt.
- **Der Ergebnis-Nachweis bleibt ungebaut.** Keine der drei gemessenen Mechaniken liest, **ob** die
  Gates grün waren; das verlangte eine Quittung je Ziel. — **Ausgang:** weiter offen → Folge-Slice
  in `open/`, geschnitten bei der Closure dieses Slice, mit dem beobachtbaren Trigger *ein zweiter
  Stempel über rotem Lauf ist auf einem anderen Weg als `-k` entstanden* (davor wäre es Härtung
  ohne Auslöser, `modul-13-quality-gates.md` §Guard-Härtung).
- **Die emittierte Ebene trägt dieselben Restwege, aber keine Grenz-Zeile.** Ihre Kante ist da und
  bewacht (Kopf), ihre zwei Zusage-Stellen nennen `-i` und den direkten Aufruf nicht. Das ist
  dieselbe Klasse wie hier, nur eine Ebene weiter, und sie hat einen anderen Vertrag
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) und
  eigene Sensoren (`make smoke`, `make full-smoke`). — **Ausgang:** weiter offen → bei der Closure
  als Zeile in `open/` notiert, mit der Messung dieses Slice als Beleg; **nicht** hier mitgenommen,
  weil ein Slice über den eigenen `Makefile` sonst den emittierten Vertrag mitzöge.
- **Der Adaptions-Eintrag ist nicht Sache dieses Slice.** `modul-13-quality-gates.md`
  §Guard-Härtung verlangt, dass jede Härtung als neuer `MR-<NNN>` landet, der den vorherigen
  schärft — und [`AGENTS.md`](../../../../AGENTS.md) §3.8 gibt das Schreiben dem **Architect**, in
  einem eigenen Commit. Läuft dieser Slice ohne ihn, beschreibt der Adaptions-Block eine Mechanik,
  die so nicht mehr steht. — **Ausgang:** weiter offen → an den Architect gemeldet, Auslöser für
  seinen Lauf ist die Closure dieses Slice; die Bearbeitung hier hängt nicht daran (§5).
- **Der neue Zahn kann sich selbst messen.** Baut der Sensor die Kante nach, statt den gelebten
  `Makefile` zu lesen, misst er `make` und nicht dieses Repo — die Klasse, die der Treiber als
  BEFUND auf den eigenen Fall meldet. — **Ausgang:** entfallen, wenn der Sensor die Datei liest,
  die das Rezept fährt | eingetreten: `make mutate` meldet BEFUND auf den neuen Fall, und der Fall
  wird umgebaut statt entfernt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. Vor dem `git mv` nach done/; das letzte
DoD-Item in §2 prüft die nächste Welle-Closure. -->

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
