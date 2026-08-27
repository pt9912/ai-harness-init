# Slice slice-106: Jedes Rot der CI trägt einen Ausgang — und der Sensor sagt, ob der Baum rot ist oder die Leitung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Durchgang über eine abgeschlossene, gemessene
Menge von Fehlschlägen; er ist einzeln lieferbar, und seine Aussage stimmt ohne einen zweiten Slice.
Dass [slice-105](slice-105-mutate-messen-dann-teilen.md) auf sein Ergebnis wartet, ist eine
**Abhängigkeit**, kein Bündel: ein Bündel verlangt, dass beide **zusammen** landen. **(2)
Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3)
Auslöser reaktiv oder gewollt?** Reaktiv: ein Sensor ist rot, und niemand besitzt das Rot. Kein
Fähigkeits-Sprung — die CI kann hinterher nichts, was sie vorher nicht konnte; sie sagt nur, welcher
Art ihr Rot ist. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: der Sensor ist Dogfood, der Fundort des Fehlschlags ist emittiert — und die Trennung
entscheidet, wohin die Antwort gehört.** `make full-smoke` geht in kein Zielrepo
(`grep -rl 'make full-smoke' internal/emit/templates/ | wc -l` → **0**). Das rot gewordene Ziel
dagegen lebt im **emittierten** tmp-Repo: `harness/mk/apps-hex.mk` <!-- d-check:ignore (Pfad im emittierten tmp-Repo, entsteht erst durch add-lang) --> existiert in diesem Repo nicht
(`ls -1 harness/mk/` → *Datei oder Verzeichnis nicht gefunden*, Exit 2) und wird von
`add-lang go apps/hex --arch hexslice` erzeugt
([`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh), Zeile 545). Was dieser
Slice liefert, liefert er darum im **Dogfood-Sensor**; was ein Adopter an derselben Unterscheidung
bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet — mit eigener Abwägung, nicht als
Nebenwirkung.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse, um die es geht, ist die Umkehrung: nicht ein Gate, das grün meldet, ohne zu prüfen, sondern
ein Gate, das rot meldet, ohne dass am Prüfgegenstand etwas rot ist — beide entwerten dieselbe
Aussage. Zugleich die Regel, an der die DoD ihre Rot-Kommandos misst: wo keines existiert, steht
das da),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (ein Sensor, dessen
Verdikt von der Erreichbarkeit eines fremden Hosts abhängt, liefert über derselben Fall-Menge zwei
Verdikte),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (*git mv + Inhaltsänderung = zwei Commits* — die Regel,
die eine der beiden getragenen Klassen **erzeugt**),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (jede Schwellen-Senkung ist ein ADR — die Frage, an der
ein Wiederhol-Versuch hängt),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (rot gesehenes Gegenbeispiel; und die Ausgabe des Wächters
ist Teil des Wächters, denn nur sie unterscheidet die beiden Fälle),
[`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only ist der Grund, aus dem dieser Lauf
überhaupt fremde Hosts befragt — die Abhängigkeit ist gewählt, nicht zugestoßen),
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1 (die Hard Rule §3.3
gehört dem Architect; dieser Slice weist ihre Wirkung aus, er ändert sie nicht),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (die CI
ruft nur `make`-Targets — eine Antwort im Workflow statt im Target wäre eine zweite Gate-Definition),
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(sie hat einen der beiden gemessenen 502-Fundorte ersatzlos beseitigt — der Beleg dafür, dass
*weniger Fetch-Punkte* eine reale Antwort auf diese Klasse ist),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando; die Mengen-Aussagen nennen ihre Eigenschaft vor der
Zahl),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-26.

---

## 1. Ziel

**Jeder rote CI-Lauf des Mess-Fensters trägt einen Ausgang — diagnostiziert · als
Umgebungs-Eigenschaft ausgewiesen · abgelehnt · aufgeschoben mit beobachtbarem Trigger —, und
dort, wo „Umgebung" der Ausgang ist, sagt der Sensor das selbst, statt es einem Leser zu
überlassen.**

Der Lieferwert ist nicht die Reparatur. Ein 502 einer fremden Registry ist nicht unser Baum, und
kein Schnitt macht ihn zu einem. Der Lieferwert ist, dass ein rotes `make full-smoke` von sich aus
sagt, welcher der beiden Fälle vorliegt.

### Der Bestand: acht rote Läufe, gemessen statt erinnert

**Das Fenster, mit seiner Eigenschaft vor der Zahl** — *ein Lauf des `ci`-Workflows, ausgelöst durch
`push`, den die GitHub-API heute noch führt*: **254** Läufe zwischen **2026-07-20T17:40:53Z** und
**2026-08-25T21:38:54Z**
(`gh run list --workflow=ci --limit 300 --json event,conclusion --jq '[.[]|select(.event=="push")]|length'`
und `gh run list --workflow=ci --limit 300 --json createdAt --jq '[.[].createdAt]|(min+"  bis  "+max)'`).
Ihre Ausgänge: **201** `success` · **45** `cancelled` · **8** `failure`
(`gh run list --workflow=ci --limit 300 --json event,conclusion --jq '[.[]|select(.event=="push")|.conclusion]|group_by(.)|map({k:.[0],n:length})'`).

**Keine dieser Zahlen ist ein Erwartungswert.** Sie wandern mit jedem Push, und die API hält ihr
Fenster nur begrenzt: Läufe vor dem 2026-07-20 sind nicht mehr abrufbar, ihre Protokolle also auch
nicht. Was hier gemessen wird, ist eine **Momentaufnahme über ein endliches Fenster** — und genau
das ist ein Grund, den Befund jetzt zu entscheiden statt später.

Die acht, jeder mit dem Job, der rot wurde
(`gh run view <run> --json jobs --jq '.jobs[]|select(.conclusion=="failure")|.name'`):

| Zeitpunkt | Lauf | roter Job | die Zeile, die den Ausgang entscheidet |
|---|---|---|---|
| 2026-08-25T13:41 | `32854817497` | `full-smoke` | `unexpected status from HEAD request to https://registry-1.docker.io/…/golang/manifests/1.27.0: 502 Bad Gateway` |
| 2026-08-25T06:08 | `32815700451` | `mutate` | `ABBRUCH — make full-smoke ist schon ohne Mutation rot.` — **ohne** die Ausgabe des roten Modus |
| 2026-08-25T03:35 | `32805781361` | `gates` | `d-check: 368 Datei(en) geprüft, 19 Befund(e)`, alle `target-missing` |
| 2026-07-28T06:06 | `30333709206` | `full-smoke` | `Fehler: baseline-fetch v3.5.2: HTTP 502 (Asset lab-regelwerk.zip fehlt zur Version?)` |
| 2026-07-25T08:21 | `30150967789` | `gates` | `d-check: 171 Datei(en) geprüft, 5 Befund(e)`, alle `target-missing` |
| 2026-07-23T18:26 | `30033732875` | `full-smoke` | `FEHLER — make gates nach add-lang cpp ohne Beleg fuer: [apps/engine] [apps-engine:test]` |
| 2026-07-23T17:45 | `30030769879` | `gates` | `d-check: 144 Datei(en) geprüft, 1 Befund(e)`: `LH-QA-01  id-unlinked` <!-- d-check:ignore (verbatim gespiegelte Protokollzeile eines d-check-Laufs: der Befund IST die unverlinkte Kennung; ein Link daraus machte das Zitat unwahr) --> |
| 2026-07-22T05:01 | `29892629642` | `gates` | `d-check: 102 Datei(en) geprüft, 3 Befund(e)`, alle `target-missing` |

Die Zeilen stammen aus den Job-Protokollen, je Job über
`gh api repos/:owner/:repo/actions/jobs/<job>/logs`.

### Vier Klassen, nicht eine — und nicht drei

**(K1) Eine ausgehende HTTP-Abhängigkeit antwortete non-2xx.** Zwei Vorfälle, **zwei verschiedene
Hosts**: am 2026-08-25 die Docker-Registry beim Auflösen des gepinnten `golang:1.27.0`
(`gh api repos/:owner/:repo/actions/jobs/97824094857/logs | grep -c '502 Bad Gateway'` → **4**
Zeilen), am 2026-07-28 der Release-Asset-Abruf des damaligen `baseline-fetch`
(`gh api repos/:owner/:repo/actions/jobs/90194069383/logs | grep -c '502 Bad Gateway'` → **0**, mit
`grep -c 'HTTP 502'` → **1** — dieselbe Sache in anderer Schreibweise, und genau daran hängt, dass
kein Muster über beide Vorfälle greift). **Getragen.**

**(K2) Der reine Move-Commit lässt Verweise auf den alten Pfad zurück.** Drei Vorfälle, alle im
`gates`-Job, alle `target-missing`. **Getragen.**

**(K3) Der Sensor hat einen echten Defekt gefunden.** Zwei Vorfälle: die Kennungs-Link-Pflicht am
2026-07-23 (`LH-QA-01` bar im Text, `id-unlinked`) und die fehlende C++-Gate-Ausführung nach <!-- d-check:ignore (dieselbe verbatim gespiegelte Kennung: der Befund IST ihre Unverlinktheit) -->
`add-lang cpp` am selben Tag. **Nicht getragen** — Ausgang **abgelehnt**: das ist kein Befund über
die CI, sondern ihr Zweck. Ein Slice, der dies mitträgt, erklärte funktionierende Sensoren zum
Problem.

**(K4) `mutate` bricht ab, weil `full-smoke` in der isolierten Kopie schon ohne Mutation rot war —
und der Grund steht in keinem Protokoll.** Ein Vorfall. **Getragen**, aber als **aufgeschoben mit
beobachtbarem Trigger** (§4).

### Wen der Fehlschlag vom 2026-08-25 getroffen hat, und wie oft

**Er traf das Go-Hexagonal-Modul, nicht das C++-Modul.** Rot wurden
`test-apps-hex` und `lint-apps-hex`
(`gh api repos/:owner/:repo/actions/jobs/97824094857/logs | grep -cE 'make\[1\]: \*\*\* \[harness/mk/apps-hex.mk'` → **2**);
das C++-Modul lief im **selben** Protokoll durch — **sechs** fertig gebaute Bilder
(`… | grep -c 'naming to docker.io/library/apps-cpphex'` → **6**), drei je emittiertem Repo.
Getroffen hat das gepinnte `golang:1.27.0`, nicht die C++-Kette über `ubuntu:26.04`.

**Über die Häufigkeit sagt der Bestand nichts, über die Ursache sagt er etwas.** *Sporadisch* und
*nichtdeterministisch* sind Aussagen über eine **Menge**; die Menge ist hier **ein** Vorfall im
Fenster, und das trägt keine Häufigkeits-Aussage. Was trägt, ist die benannte äußere Ursache samt
Gegenbeleg im selben Lauf: die Jobs `gates` und
`smoke` desselben Laufs lösten dasselbe gepinnte Bild ohne Fehler auf
(`gh api repos/:owner/:repo/actions/jobs/97824095031/logs | grep -c 'golang:1.27.0'` → **11**,
`… | grep -c '502 Bad Gateway'` → **0**; für den `smoke`-Job `97824095233` → **5** und **0**). Der
Pin ist auflösbar, der Baum ist nicht betroffen, und die Ursache lag außerhalb beider.

### Warum ein Vorfall in einem Fenster die Umgebungs-Aussage noch nicht trägt

Ein einzelner Vorfall mit passender Fehlermeldung ist ein starker Hinweis und eine dünne Menge.
**Tragfähig wird die Aussage nicht durch mehr Vorfälle, sondern durch die Exposition** — und die ist
messbar. **Die Eigenschaft vor der Zahl:** *eine Protokollzeile, die eine Manifest-Auflösung gegen
einen fremden Host meldet*: **90** in einem einzigen `make full-smoke`
(`gh api repos/:owner/:repo/actions/jobs/97824094857/logs | grep -c 'load metadata for'`), verteilt
auf **6** eindeutige externe Bild-Referenzen
(`… | grep -ohE '(docker\.io|ghcr\.io)/[a-zA-Z0-9._/-]+(:[a-zA-Z0-9._-]+|@sha256:[0-9a-f]+)' | grep -vE 'docker\.io/library/(app|apps-|ai-harness)' | sort -u | wc -l`),
dazu **70** `docker build`-Aufrufe (`… | grep -c '^docker build'`, nach Abtrennen des
Zeitstempel-Präfixes). Der Lauf ist rot, sobald **eine** dieser Anfragen non-2xx beantwortet wird.

Das ist die Umgebungs-Eigenschaft — nicht *„manchmal ist die Registry kaputt"*, sondern *„dieser
Sensor stellt je Lauf neunzig Anfragen an fremde Hosts und macht jede einzelne zur Bedingung seines
Grüns"*. **Und sie ist nicht schicksalhaft:**
[`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
hat einen der beiden gemessenen Fetch-Punkte ersatzlos entfernt — `baseline-fetch` existiert im
Sensor-Pfad nicht mehr (`git grep -c 'baseline-fetch' -- Makefile harness/` → leer, Exit 1); das
emittierte Repo bekommt die Baseline heute vendored, was das Protokoll desselben Laufs **4**-mal
mitschreibt (`… | grep -c 'Baseline v3.5.2 vendored'`). Die Klasse schrumpft, wenn Fetch-Punkte
verschwinden — das ist die eine belastbare Antwort auf sie.

### Warum das Rot des Move-Commits erwartet ist — und warum das trotzdem ein Befund ist

[`AGENTS.md`](../../../../AGENTS.md) §3.3 verlangt, Move und Inhaltsänderung **getrennt** zu
committen. Damit steht zwischen beiden Commits notwendig ein Zustand, in dem eingehende Verweise auf
den alten Pfad zeigen. Am Lauf `32805781361` ist das vollständig ablesbar: **19** Befunde, **alle**
`target-missing`, **alle** mit `slice-087` in der Zeile — **16** als Ziel auf dem alten Pfad
(`open/slice-087-…`), **3** als Quelle in der verschobenen Datei selbst
(`gh api repos/:owner/:repo/actions/jobs/97675536312/logs | grep 'target-missing' | grep -c 'slice-087'`
→ **19**; dieselbe Pipeline mit `grep -c 'open/slice-087'` → **16** und `grep -c 'next/slice-087'` →
**3**).

**Die Eigenschaft vor der Zahl** — *ein Commit, dessen Message „reiner Move" nennt und der unter
`docs/plan/planning/` umbenennt*: **104**; davon zeigt an ihrer eigenen Revision noch mindestens ein
anderes getracktes Markdown-Dokument auf den alten Pfad: **73**
(Schleife über `git log --format=%H --grep='reiner Move'`, je Commit die Umbenennungspaare aus
`git show --name-status --find-renames`, dazu `git grep -l -F "<alt-verzeichnis>/<dateiname>" <commit> -- '*.md'`
ohne die verschobene Datei selbst). **Obergrenze, mit Absicht:** gezählt sind
**Text-Vorkommen** des alten Pfads, nicht d-check-Befunde — ein Vorkommen außerhalb eines Links oder
in einer vom Gate ausgenommenen Datei zählt mit, ohne rot zu färben.

**Und trotzdem sieht dieses Rot fast niemand.** Die CI läuft auf dem **gepushten Kopf**, nicht auf
jedem Commit: seit dem 2026-07-20 stehen **832** Commits
(`git log --since=2026-07-20 --format=%H | wc -l`) gegen **254** push-Läufe; von den **78**
Move-Commits desselben Zeitraums (`git log --since=2026-07-20 --format=%H --grep='reiner Move' | wc -l`)
haben **67** überhaupt keinen eigenen Lauf
(`comm -23 <(git log --since=2026-07-20 --format=%H --grep='reiner Move' | sort) <(<lauf-shas> | sort) | wc -l`,
wobei `<lauf-shas>` die `headSha`-Liste der 254 push-Läufe ist). **Das ist die eigentliche
Schwierigkeit:** ein Rot, das gleichmäßig aufträte, wäre als Muster erkennbar; dieses tritt in **11
von 78** Fällen auf und sieht dann exakt wie ein echter Defekt aus.

### Die Abwägung: vier Wege, zwei gewählt

- **(A) Den Sensor sagen lassen, welcher Fall vorliegt — gewählt.** Er trifft die gemessene Ursache
  der Verwechselbarkeit: der Unterschied zwischen *„der Baum ist rot"* und *„eine Leitung antwortete
  nicht"* steht heute ausschließlich im Protokoll und in keinem Exit-Code — und das Protokoll misst
  **6700** Zeilen
  (`gh api repos/:owner/:repo/actions/jobs/97824094857/logs | wc -l`). Der Preis ist eine
  Verzweigung im Dogfood-Sensor; der Gewinn ist, dass der nächste Vorfall ohne Archäologie
  einzuordnen ist.
- **(B) Das Move-Rot als Eigenschaft ausweisen, mit einem entscheidbaren Kriterium — gewählt.** Der
  Beleg oben liefert es mechanisch: **jeder** Befund des Laufs nennt die verschobene Datei, als Ziel
  auf dem alten Pfad oder als Quelle. Ein Befund, der das nicht tut, ist kein Move-Folgeschaden.
  Damit ist die Klasse ohne Urteil entscheidbar.
- **(C) Einen Wiederhol-Versuch einbauen.** Verworfen in der pauschalen Form, und zwar aus
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 heraus: ein Wiederholen des **Ziels** bei beliebigem
  Exit ≠ 0 ändert die Aussage des Sensors von *„dieser Baum ist grün"* zu *„dieser Baum ist in
  mindestens einem von N Versuchen grün"* — das ist eine **Schwellen-Senkung** und damit
  ADR-pflichtig, nicht eine Skript-Änderung. Sie träfe ausgerechnet die Fehlerklasse, die dieses
  Repo am teuersten bezahlt: einen echten, nur manchmal auftretenden Defekt. **Nicht** verworfen ist
  die enge Form: die gepinnten Bilder **vor** dem Sensorlauf holen und **am Holen** scheitern statt
  am Bauen. Sie senkt nichts — derselbe Ausfall bleibt rot —, sie verschiebt nur, **wo** das Rot
  entsteht, und trennt damit die zwei Fälle an der Quelle. Ob sie zu (A) hinzukommt, entscheidet der
  Lauf; ADR-pflichtig ist sie nicht, weil kein Lauf durch sie grün wird, der vorher rot war.
- **(D) `AGENTS.md` §3.3 ändern, damit der Move-Commit kein Rot mehr erzeugt.** Verworfen, und nicht
  aus Aufwandsgründen: die Hard Rules schreibt der Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8,
  [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). Ein Planner, der
  die Regel umschriebe, um ihre Wirkung loszuwerden, verschöbe nur die Stelle, an der die
  Entscheidung unbelegt fällt. Was dieser Slice liefert, ist der **Beleg** — die Regel bleibt, wo
  sie ist.

## 2. Definition of Done

Drei slice-eigene Punkte (Modul 5 §Ziel-Form: ≤ 3). Wo kein Kommando einen Punkt rot färbt, steht
das dabei und wird begründet, statt ein Kommando zu erfinden
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) gilt auch
für Plan-Texte).

- [ ] **(1) Jeder rote Lauf des Fensters trägt genau einen von vier Ausgängen, und die Klasse ist
      mit der Protokollzeile benannt, die sie entscheidet.** Die vier Ausgänge: **diagnostiziert**
      (Ursache benannt, mit Sensor oder Grenze) · **als Umgebungs-Eigenschaft ausgewiesen** (mit dem
      Beleg, nicht der Plausibilität) · **abgelehnt** mit Grund · **aufgeschoben** mit einem
      Auflösungs-Trigger, der ein beobachtbares Ereignis nennt. Dieselbe Ausgangs-Menge, die
      [slice-101](slice-101-norm-postens-bekommen-einen-termin.md) für offene Norm-Postens setzt.
      **Kein Kommando färbt die Zuordnung rot, und das ist der Befund, keine Vertagung.** Welcher
      Klasse ein Fehlschlag angehört, ist ein Urteil über Protokolltext. Was **mechanisch** ist, ist
      der **Nenner**: liefert
      `gh run list --workflow=ci --limit 300 --json event,conclusion --jq '[.[]|select(.event=="push" and .conclusion=="failure")]|length'`
      zum Zeitpunkt des Laufs mehr Einträge, als die Liste in §1 führt, ist die Liste unvollständig.
      Auch dieser Nenner ist **kein Gate**: er braucht Netz und das Retentions-Fenster der API —
      dieselbe Begründung, aus der `make hook-overhead` eine Messung ist und kein Sensor. Diese
      Hälfte trägt das Review.
- [ ] **(2) Der Ausgang „Umgebungs-Eigenschaft" wird nur getragen, wenn `make full-smoke` selbst
      sagt, welcher Fall vorliegt.** Der Lauf unterscheidet in seiner **eigenen Ausgabe** *„eine
      ausgehende Anfrage nach einem gepinnten Artefakt wurde nicht mit 2xx beantwortet"* von *„der
      geprüfte Baum ist rot"*. Bis er das tut, bleibt K1 **aufgeschoben**, nicht ausgewiesen: eine
      Umgebungs-Aussage, die nur ein Mensch aus dem Protokoll liest, ist beim nächsten Mal wieder
      keine.
      **Rot:** ein Lauf, dessen gepinntes Bild nicht auflösbar ist — nachgestellt über die
      überschreibbare Pin-Variable (`grep -n '^GO_VERSION' Makefile` → Zeile **15**,
      `GO_VERSION ?= 1.27.0`; sie erreicht den Sensor,
      `grep -n 'GO_VERSION' harness/tools/full-smoke.sh` → Zeilen **21** und **141**) — muss
      **weiterhin mit Exit ≠ 0 enden** und den unterscheidenden Satz tragen. Ein Lauf, der dadurch
      grün würde, wäre die Senkung, die [`AGENTS.md`](../../../../AGENTS.md) §3.5 an ein ADR bindet.
      **Vor dem Anspruch auf Vollständigkeit zu prüfen:** diese Variable trifft den
      Host-Artefakt-Bau, nicht den Bau im emittierten Repo, an dem der gemessene Vorfall hing —
      welche der **90** Manifest-Auflösungen die Unterscheidung abdeckt, gehört gemessen, nicht
      angenommen.
- [ ] **(3) Das Rot des reinen Move-Commits ist als erwartete Eigenschaft ausgewiesen, mit dem
      Kriterium, das es von einem echten Defekt trennt.** Das Kriterium: **jeder** Befund des Laufs
      nennt die verschobene Datei — als Ziel auf ihrem alten Pfad oder als Quelle in ihr selbst.
      Nennt ein Befund etwas anderes, ist das Rot **nicht** strukturell und geht in Klasse K3.
      **Rot:** die Gegenprobe über dem belegten Lauf —
      `gh api repos/:owner/:repo/actions/jobs/97675536312/logs | grep -c 'target-missing'` → **19**
      gegen dieselbe Pipeline mit zusätzlichem `| grep -c 'slice-087'` → **19**. Weichen die zwei
      Zahlen voneinander ab, trägt die Einordnung nicht. **Was hier ausdrücklich nicht behauptet
      wird:** dass jedes Move-Rot dieses Kriterium erfüllt — belegt ist **ein** Lauf, und die
      Obergrenze aus §1 (**73** von **104**) zählt Text-Vorkommen, keine Befunde.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | Träger von DoD (2): der Lauf unterscheidet in seiner eigenen Ausgabe die nicht beantwortete Anfrage nach einem gepinnten Artefakt vom roten Baum. Der Sensor ist Dogfood (Kopfzeile *Ebene*), also gehört die Verzweigung hierher und nicht in ein emittiertes Fragment |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | der Zahn zu DoD (2): eine Mutation, die die Unterscheidung entfernt, muss den Sensor rot färben. Nummern im Anschluss an die höchste **vergebene**, nicht an die Anzahl — beide gehen auseinander: `ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1` → **171**, bei `ls -1 test/mutations/*.sh \| wc -l` → **164** Dateien (2026-08-26). Beide wandern mit dem Bestand und sind keine Erwartungswerte — beim Anlegen neu zu erheben |
| [`harness/README.md`](../../../../harness/README.md) | update | dort steht, was `make full-smoke` aussagt. Nach DoD (2) sagt er zwei Dinge statt einem, und der Satz wird **gezogen**, nicht danebengestellt |
| [`AGENTS.md`](../../../../AGENTS.md) | **unverändert** | §3.3 erzeugt K2, §3.5 entscheidet über den Wiederhol-Versuch — beide gehören dem Architect ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1). Berührt wäre höchstens §4, die Gate-Beschreibung; ob sie es ist, entscheidet sich an der Ausgabe, nicht vorab |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | **unverändert** | die CI ruft ausschließlich `make`-Targets ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)). Ein `continue-on-error` oder ein Wiederhol-Schritt im Workflow wäre eine zweite Definition dessen, was ein Gate ist — und zugleich die Senkung aus Weg (C) |
| [`docs/plan/adr`](../../adr) | **unverändert**, mit einer benannten Ausnahme | (A) und (B) senken keine Schwelle: derselbe Ausfall bleibt rot, nur seine Ausgabe wird genauer. Ergibt der Lauf, dass die tragfähige Antwort ein **pauschaler** Wiederhol-Versuch ist, ist das eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 — dann greift die Rückführung aus §4 |
| [`internal/`](../../../../internal) und die emittierte Ebene | **unverändert** | die Unterscheidung wandert nicht mit; was ein Adopter davon bekommt, ist ein eigener Schnitt mit eigener Abwägung (Kopfzeile *Ebene*) |
| [`docs/plan/planning/done/`](../done) | **unverändert** | Zeitdokumente ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) §Geltungsbereich); die acht Fehlschläge werden hier eingeordnet, nicht dort nachgetragen |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Die Liste der roten Läufe gehört an den Anfang des Laufs, nicht an sein Ende.** Sie steht in §1
mit acht Zeilen und ihren Kommandos. Das Fenster wandert: ein neuer roter Lauf zwischen Schnitt und
Ausführung wird **vor** der ersten Einordnung aufgenommen, mit der Protokollzeile, die seine Klasse
entscheidet. Ein Fehlschlag, der während des Laufs auftaucht und still mitentschieden wird, macht
aus der abgeschlossenen Liste eine offene.

**Vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Woran erkennt der Sensor die nicht beantwortete Anfrage?** An der Ausgabe des Bau-Werkzeugs (Zeichenketten wie `unexpected status from HEAD request`) oder daran, dass er die gepinnten Bilder **vor** dem Lauf selbst holt und dort scheitert | Die erste Form liest fremden Text und bricht, wenn er sich ändert; die zweite verlagert den Fehlschlag an eine Stelle, die wir besitzen, kostet aber einen Vorlauf. Die zweite ist die enge Form aus Weg (C) in §1 — sie senkt nichts, weil derselbe Ausfall rot bleibt |
| B | **Deckt die Unterscheidung alle Fetch-Punkte oder einen?** | **90** Manifest-Auflösungen je Lauf (§1) über **6** externe Bild-Referenzen, dazu zwei `apt`-Hosts der C++-Kette (`http://archive.ubuntu.com`, `http://security.ubuntu.com`, aus demselben Protokoll). Eine Unterscheidung, die nur den Host-Artefakt-Bau abdeckt, trägt die Aussage aus DoD (2) nicht — sie muss sagen, wofür sie gilt |
| C | **Bekommt K2 einen Sensor oder eine Feststellung?** | Ein Wächter über *„jeder Befund nennt die verschobene Datei"* wäre baubar, aber sein Prüfgegenstand ist ein CI-Protokoll, das keine `make`-Stufe kennt. Bis das entschieden ist, ist K2 eine ausgewiesene Eigenschaft mit Kriterium — und das ist ein vollwertiger Ausgang, kein halber |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): nichts blockiert ihn außer dem WIP-Limit.** Der
Gegenstand liegt vollständig in diesem Repo, er berührt die emittierte Ebene nicht und hängt an
keiner Welle. Die Messungen aus §1 sind gefahren; was fehlt, ist die Entscheidung und ihr Träger im
Sensor.

**Was dieser Slice freigibt.** [slice-105](slice-105-mutate-messen-dann-teilen.md) macht seine
DoD (2) und (3) davon abhängig, dass der Befund an `make full-smoke` einen der vier Ausgänge trägt.
Genau das ist DoD (1) hier. Die Reihenfolge ist damit gerichtet, aber nicht verschränkt: dieser
Slice landet allein, [slice-105](slice-105-mutate-messen-dann-teilen.md) danach.

**Der aufgeschobene Ausgang und sein beobachtbarer Trigger — K4.** Der `mutate`-Fehlschlag vom
2026-08-25T06:08 bleibt ohne Ursache, weil der Treiber die Ausgabe des roten Vorlaufs an dieser
Revision verworfen hat. Die Lücke ist geschlossen: seit `241db77`
(`git log --format='%h %ad %s' --date=iso -S 'prepare_prerun_log' -- harness/tools/mutate.sh` →
**2026-08-25 11:21:50 +0200**, also **nach** dem Fehlschlag) druckt der Abbruch die letzten Zeilen
des roten Modus. **Der Trigger, ohne Rückfrage entscheidbar:** der nächste Abbruch der Form
`mutate: ABBRUCH — make <modus> ist in der isolierten Kopie ohne Mutation rot.` trägt seine
Begründung im Protokoll; dann — und erst dann — ist K4 einer der drei anderen Ausgänge. Ihn heute zu
diagnostizieren hieße, die plausibelste Ursache für die gemessene auszugeben.

Die zwei Rückführungen, vorab benannt:

- **`in-progress` → `next` (zu groß):** wenn Frage B ergibt, dass eine tragfähige Unterscheidung
  jeden der **90** Fetch-Punkte einzeln behandeln muss. Dann sind es zwei Slices — einer, der die
  Einordnung liefert (DoD 1 und 3), und einer, der den Sensor umbaut.
- **`in-progress` → `open` (blockiert):** wenn sich zeigt, dass die einzige tragfähige Antwort ein
  **pauschaler** Wiederhol-Versuch ist. Das ist eine Schwellen-Senkung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5) und verlangt ein ADR; der Slice wartet darauf, statt
  die Senkung im Skript zu verstecken.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; jeder der acht roten Läufe trägt seinen Ausgang samt
entscheidender Protokollzeile; der nicht auflösbare Pin ist **einmal rot gesehen** und hat den
unterscheidenden Satz getragen; Frage A, B und C sind mit ihrer Begründung im Plan beantwortet; die
Beschreibung in [`harness/README.md`](../../../../harness/README.md) ist gezogen; Review konform
(Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün; `git mv` nach `done/` als eigener
Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag in einer der drei Formen (geschärfte Regel ·
neuer Sensor · benannte Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: dass die CI danach grün ist.** Ein Kriterium, das
grüne Läufe verlangt, kann nur noch durch Unterdrücken erfüllt werden — genau die Senkung, die
Weg (C) verwirft. Was zählt, ist die **Einordnung** und die **Unterscheidbarkeit**, nicht die
Farbe des nächsten Laufs.

**Ebenfalls nicht Teil: dass alle vier Klassen denselben Ausgang bekommen.** K3 geht als
**abgelehnt** aus, und das ist kein Rest — es ist die Feststellung, dass zwei der acht Roten
funktionierende Sensoren waren.

## 6. Risiken und offene Punkte

- **Das Mess-Fenster wandert und schließt sich.** Die acht Läufe stehen in §1 mit ihren
  Protokollzeilen, weil die Protokolle heute abrufbar sind; das Fenster beginnt am
  **2026-07-20T17:40:53Z**, und was davor liegt, ist verloren. Wer die Liste nachprüft, prüft eine
  **Momentaufnahme** nach, keine Historie — und findet gegebenenfalls weniger, nicht mehr.
- **Eine Unterscheidung, die fremde Fehlertexte liest, altert mit ihnen.** `unexpected status from
  HEAD request` ist die Formulierung eines Bau-Werkzeugs, nicht unsere. Ändert sie sich, fällt der
  Sensor in den unspezifischen Fall zurück — das ist der sichere Ausgang (rot bleibt rot), aber die
  Aussage aus DoD (2) ist dann still weg. Frage A hängt daran.
- **Die Umgebungs-Aussage kann zur Ausrede werden.** Ist erst einmal benannt, dass ein Rot
  „die Leitung" sein kann, ist die Versuchung groß, jedes unbequeme Rot dort einzuordnen. Deshalb
  verlangt DoD (2) die Unterscheidung **im Sensor** und nicht im Kopf des Lesenden, und deshalb
  bleibt der Exit-Code in beiden Fällen ungleich null.
- **K2 ist gemessen, aber nur an einem Lauf vollständig belegt.** Die **73** von **104** aus §1 sind
  eine Obergrenze über Text-Vorkommen; dass jedes dieser Vorkommen ein d-check-Befund wäre, ist
  nicht gemessen und wird nicht behauptet. Wer das Kriterium aus DoD (3) verallgemeinert, braucht
  einen zweiten belegten Lauf.
- **Der Slice kann seine eigene Lehre verfehlen.** Sein Gegenstand ist die Ausgabe eines Wächters —
  das einzige Artefakt, das ein grüner Lauf nie zu Gesicht bekommt. Wird die neue Unterscheidung
  eingebaut, ohne ihre Meldung **im Rot gelesen** zu haben, entsteht genau die Klasse, gegen die
  dieser Schnitt gerichtet ist: eine Begründung, die auf ihren eigenen Treffer nicht zutrifft.
- **`make gates` deckt den Gegenstand nicht.** Der Doku-Gate prüft Kennungen, Anker und Pfade; keine
  Stufe von `make gates` liest ein CI-Protokoll. Was hier grün wird, ist die **Form** des Plans —
  die Einordnung selbst trägt das Review.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Jede hier aufgeführte Sub-Area
muss das Inklusionskriterium erfüllen (drei Achsen, Schwelle ≥ 2; siehe
[`/kurs/de/grundlagen/konventionen.md` §Was ist eine Sub-Area?](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/grundlagen/konventionen.md#was-ist-eine-sub-area)).
Zu grobe Sub-Areas (*"Backend"*) vorher ausdifferenzieren — sonst trägt
der Begründungsblock mehrere Modi vermischt.

### Sub-Area: Voll-E2E-Sensor (`harness/tools/full-smoke.sh` + seine Fall-Ebene)

Eine Sub-Area, kein zweiter Block: ein Skript, seine Mutations-Fälle und die Beschreibung, die es
in [`harness/README.md`](../../../../harness/README.md) trägt — ein Gegenstand, eine Frage. Die CI-Zeile
ist Aufrufer, keine eigene Sub-Area; das emittierte Repo ist **Prüfgegenstand** des Sensors und
liegt außerhalb (Kopfzeile *Ebene*).

- **Modus:** GF. Der Sensor ist in diesem Repo entstanden (slice-024) und seither gegen den Kurs
  geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.5 entscheidet über den
  Wiederhol-Versuch, §3.6 über den Rot-Beleg,
  [`ADR-0003`](../../adr/0003-go-native-binaries.md) begründet, warum der Lauf überhaupt fremde
  Hosts befragt,
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) bindet
  seinen Auslöser, und
  [`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  ist der Beleg, dass Fetch-Punkte entfernbar sind.
- **Phase-Reife:** Phase 5 (Betrieb). Der Sensor läuft pro Push, emittiert mehrere Repos und fährt
  in ihnen den zusammengeführten `make gates`; seine Fehlermeldungen sind ausgeschrieben
  (`grep -c 'FEHLER —' harness/tools/full-smoke.sh` → **93**). Was fehlt, ist nicht Reife, sondern
  die Unterscheidung zwischen seinem Prüfgegenstand und seiner Leitung.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für den Bestand (aus Protokollen und dem Skript gelesen,
  §1), **offen für die Abdeckung** — welcher der **90** Fetch-Punkte die neue Unterscheidung
  wirklich trägt, ist Frage B und gehört gemessen, bevor DoD (2) als erfüllt gilt.
- **Reconciliation-Aufwand:** gering. Berührt sind ein Skript, ein bis zwei Mutations-Fälle und ein
  Absatz in [`harness/README.md`](../../../../harness/README.md). Wer die Beschreibung anfasst,
  zieht den bestehenden Satz nach, statt einen zweiten danebenzustellen. Graduation-Trigger
  entfällt; die Sub-Area ist bereits GF.
