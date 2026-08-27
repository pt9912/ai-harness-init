# Slice slice-106: Jedes Rot der CI trägt einen Ausgang — und der Sensor sagt, ob der Baum rot ist oder die Leitung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Durchgang über eine abgeschlossene, gemessene
Menge von Fehlschlägen; er ist einzeln lieferbar, und seine Aussage stimmt ohne einen zweiten Slice.
Dass [slice-105](../next/slice-105-mutate-messen-dann-teilen.md) auf sein Ergebnis wartet, ist eine
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

### Der Bestand: elf rote Läufe, gemessen statt erinnert

**Das Fenster, mit seiner Eigenschaft vor der Zahl** — *ein Lauf des `ci`-Workflows, ausgelöst durch
`push`, den die GitHub-API heute noch führt*: **262** Läufe zwischen **2026-07-20T17:40:53Z** und
**2026-08-27T06:10:26Z**
(`gh run list --workflow=ci --limit 300 --json event,conclusion --jq '[.[]|select(.event=="push")]|length'`
und `gh run list --workflow=ci --limit 300 --json createdAt --jq '[.[].createdAt]|(min+"  bis  "+max)'`).
Ihre Ausgänge: **204** `success` · **47** `cancelled` · **11** `failure`
(`gh run list --workflow=ci --limit 300 --json event,conclusion --jq '[.[]|select(.event=="push")|.conclusion]|group_by(.)|map({k:.[0],n:length})'`).

**Keine dieser Zahlen ist ein Erwartungswert.** Sie wandern mit jedem Push, und die API hält ihr
Fenster nur begrenzt: Läufe vor dem 2026-07-20 sind nicht mehr abrufbar, ihre Protokolle also auch
nicht. Was hier gemessen wird, ist eine **Momentaufnahme über ein endliches Fenster** — und genau
das ist ein Grund, den Befund jetzt zu entscheiden statt später.

Die elf, jeder mit dem Job, der rot wurde
(`gh run view <run> --json jobs --jq '.jobs[]|select(.conclusion=="failure")|.name'`). **Zwölf
Zeilen für elf Läufe:** der Lauf `32981552921` trägt **zwei** rote Jobs, und sie gehören
verschiedenen Klassen an (dasselbe Kommando über diesen Lauf → `gates` und `mutate`). Die
Zuordnungs-Einheit ist damit der **Job**, nicht der Lauf — der Nenner der DoD zählt Läufe und ist
deshalb eine Untergrenze für die Zahl der Zeilen, nie eine Obergrenze.

| Zeitpunkt | Lauf | roter Job | die Zeile, die den Ausgang entscheidet |
|---|---|---|---|
| 2026-08-26T19:28 | `33005323228` | `gates` | `d-check: 403 Datei(en) geprüft, 1 Befund(e)`, der eine Befund `target-missing` auf einen Verweis nach `../../../../.harness/state/bin` <!-- d-check:ignore (verbatim gespiegelte Protokollzeile: der Befund IST, dass dieses Ziel gitignoriert ist; ein auflösbarer Pfad daraus machte das Zitat unwahr) --> aus einer `done/`-Notiz |
| 2026-08-26T18:46 | `33001548628` | `gates` | dieselbe Zeile, `d-check: 400 Datei(en) geprüft, 1 Befund(e)` |
| 2026-08-26T14:52 | `32981552921` | `mutate` | `mutate: BEFUND  169-feldliste-grenze-bestand-weg  rot, aber 'TestFeldliste_GrenzeUeberDenBestand' faellt nicht — falscher Grund`, zwei Zeilen darunter `unexpected status from HEAD request to https://registry-1.docker.io/v2/docker/dockerfile/manifests/1.7: 502 Bad Gateway` |
| 2026-08-26T14:38 | `32981552921` | `gates` | dieselbe Zeile, `d-check: 399 Datei(en) geprüft, 1 Befund(e)` |
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

**(K1) Eine ausgehende HTTP-Abhängigkeit antwortete non-2xx.** Drei Vorfälle, **zwei verschiedene
Hosts** und **drei verschiedene angeforderte Artefakte**: am 2026-08-25 die Docker-Registry beim
Auflösen des gepinnten `golang:1.27.0`
(`gh api repos/:owner/:repo/actions/jobs/97824094857/logs | grep -c '502 Bad Gateway'` → **4**
Zeilen), am 2026-07-28 der Release-Asset-Abruf des damaligen `baseline-fetch`
(`gh api repos/:owner/:repo/actions/jobs/90194069383/logs | grep -c '502 Bad Gateway'` → **0**, mit
`grep -c 'HTTP 502'` → **1** — dieselbe Sache in anderer Schreibweise, und genau daran hängt, dass
kein Muster über beide Vorfälle greift), und am 2026-08-26 dieselbe Registry beim Auflösen von
`docker/dockerfile:1.7` — diesmal **innerhalb von `make mutate`**
(`gh api repos/:owner/:repo/actions/jobs/98219369372/logs | grep -c '502 Bad Gateway'` → **1**).
**Getragen.**

**Der dritte Vorfall teilt die Klasse an ihrem Sensor, nicht an ihrer Ursache.** DoD (2) bindet den
Ausgang *„als Umgebungs-Eigenschaft ausgewiesen"* an die Bedingung, dass **der Lauf es selbst
sagt**. Für `make full-smoke` ist das dieser Slice; `make mutate` sagt es nicht, und die zwei
Muster, die den Vorfall erkannt hätten, sind nachgemessen — dieselbe Protokolldatei durch
`grep -cE '(^|[[:space:]])> (\[internal\] load metadata for|resolve image config for )'` → **1**
und durch `grep -cE 'unexpected status from [A-Z]+ request to https?://'` → **1**, gegen
`grep -c 'einordnen\|full-smoke-ausgang' harness/tools/mutate.sh` → **0** (Exit 1). Nicht der
Einordner ist zu eng, sondern seine Reichweite: derselbe Ausfall trägt in `full-smoke` einen
Ausgang und in `mutate` keinen.

**(K2) Der reine Move-Commit lässt Verweise auf den alten Pfad zurück.** Drei Vorfälle, alle im
`gates`-Job, alle `target-missing`. **Getragen.**

**(K3) Der Sensor hat einen echten Defekt gefunden.** Fünf Vorfälle: die Kennungs-Link-Pflicht am
2026-07-23 (`LH-QA-01` bar im Text, `id-unlinked`), die fehlende C++-Gate-Ausführung nach <!-- d-check:ignore (dieselbe verbatim gespiegelte Kennung: der Befund IST ihre Unverlinktheit) -->
`add-lang cpp` am selben Tag, und am 2026-08-26 dreimal derselbe Verweis aus einer `done/`-Notiz
auf einen Pfad, den `git` ignoriert. **Nicht getragen** — Ausgang **abgelehnt**: das ist kein
Befund über die CI, sondern ihr Zweck. Ein Slice, der dies mitträgt, erklärte funktionierende
Sensoren zum Problem.

**Die drei vom 2026-08-26 tragen daneben eine zweite Beobachtung, und die ist kein Rot der CI,
sondern ein Grün auf dem Host.** Der Verweis ist getilgt (`git show --stat c4a0c03` → **1** Datei,
**1** Einfügung, **1** Löschung), das Rot damit erledigt. Was bleibt, ist die Bedingung, unter der
`make docs-check` ihn lokal **nicht** sah: das Ziel liegt im gitignorierten Zustands-Bereich und
existiert im Arbeitsbaum, sobald ein früherer Lauf ihn angelegt hat. Diese Hälfte ist **kein**
Gegenstand dieses Slice — sie betrifft den Prüfbereich des Doku-Gates, nicht die Ausgabe eines
Sensors — und hat einen eigenen Träger
([slice-116](../open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md)).

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

- [x] **(1) Jeder rote Lauf des Fensters trägt genau einen von vier Ausgängen, und die Klasse ist
      mit der Protokollzeile benannt, die sie entscheidet.** Die vier Ausgänge: **diagnostiziert**
      (Ursache benannt, mit Sensor oder Grenze) · **als Umgebungs-Eigenschaft ausgewiesen** (mit dem
      Beleg, nicht der Plausibilität) · **abgelehnt** mit Grund · **aufgeschoben** mit einem
      Auflösungs-Trigger, der ein beobachtbares Ereignis nennt. Dieselbe Ausgangs-Menge, die
      [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) für offene Norm-Postens setzt.
      **Kein Kommando färbt die Zuordnung rot, und das ist der Befund, keine Vertagung.** Welcher
      Klasse ein Fehlschlag angehört, ist ein Urteil über Protokolltext. Was **mechanisch** ist, ist
      der **Nenner**: liefert
      `gh run list --workflow=ci --limit 300 --json event,conclusion --jq '[.[]|select(.event=="push" and .conclusion=="failure")]|length'`
      zum Zeitpunkt des Laufs mehr Einträge, als die Liste in §1 führt, ist die Liste unvollständig.
      Auch dieser Nenner ist **kein Gate**: er braucht Netz und das Retentions-Fenster der API —
      dieselbe Begründung, aus der `make hook-overhead` eine Messung ist und kein Sensor. Diese
      Hälfte trägt das Review.
- [x] **(2) Der Ausgang „Umgebungs-Eigenschaft" wird nur getragen, wenn `make full-smoke` selbst
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
- [x] **(3) Das Rot des reinen Move-Commits ist als erwartete Eigenschaft ausgewiesen, mit dem
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

**Was dieser Slice freigibt.** [slice-105](../next/slice-105-mutate-messen-dann-teilen.md) macht seine
DoD (2) und (3) davon abhängig, dass der Befund an `make full-smoke` einen der vier Ausgänge trägt.
Genau das ist DoD (1) hier. Die Reihenfolge ist damit gerichtet, aber nicht verschränkt: dieser
Slice landet allein, [slice-105](../next/slice-105-mutate-messen-dann-teilen.md) danach.

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

**Was gilt.** Ein fehlgeschlagener Abschnitt von `make full-smoke` nennt in der Ausgabe des Laufs
seinen Ausgang: **LEITUNG**, wenn eine ausgehende Anfrage nach einem gepinnten Artefakt nicht mit
2xx beantwortet wurde — mit der Zeile, die das trägt, und der Nummer des Musters, das griff —,
sonst **BAUM**, mit der Zahl der gelesenen Zeilen und dem Satz *„wird zugerechnet"*. Beide Ausgänge
enden mit demselben Exit-Code; ein eigener wäre die Einladung zur Senkung, die
[`AGENTS.md`](../../../../AGENTS.md) §3.5 an ein ADR bindet. **Wofür die Unterscheidung gilt, steht
als Kriterium und nicht als Fundstellen-Liste da** — eingeordnet ist jeder Abschnitt, der ein Bild
anfordern kann —, und das Kriterium hat einen Wächter:
`grep -c '^@test' test/full-smoke-ausgang.bats` → **9**, davon zwei über der Abdeckung. Der Bestand
an Mutations-Fällen steht bei `ls -1 test/mutations/*.sh | wc -l` → **183**, die höchste vergebene
Nummer bei `ls -1 test/mutations/*.sh | sed -n 's#.*/\([0-9]*\)-.*#\1#p' | sort -n | tail -1` →
**190**. Alle drei Zahlen wandern mit ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Gleichung, die die Zusage trägt, über dem Baum dieser Closure selbst gefahren:**
`grep -cE '\|\| [a-z_0-9]+=\$\?$' harness/tools/full-smoke.sh` → **33** (A), dieselbe Liste durch
`grep -cE ' -n |span-clean|bash "\$wrapper"'` → **5** (B) und durch
`grep -c 'tmpbin/ai-harness-init'` → **6** (C), gegen
`grep -cE '^[[:space:]]*einordnen "' harness/tools/full-smoke.sh` → **24** (D). **33 − 5 − 6 = 22**
und **24 − 2 = 22**.

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1)–(3) erfüllt, mit gefahrenen Kommandos.** DoD (2) und (3) sind von der
   [Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) über beiden Rot-Zuständen
   bestätigt; DoD (1) fiel dort an seinem eigenen Nenner und ist mit dieser Closure geschlossen
   (nächster Absatz).
2. **Jeder rote Lauf des Fensters trägt seinen Ausgang samt entscheidender Protokollzeile.**
   Erfüllt über **elf** Läufe in **zwölf** Zeilen. §5 verlangt es für *„jeder der acht"* — die Zahl
   dort bleibt stehen, denn sie ist der Maßstab, und wer elf einordnet, hat acht eingeordnet.
3. **Der nicht auflösbare Pin ist einmal rot gesehen und hat den unterscheidenden Satz getragen.**
   Fremdbelegt: [Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) §3.1 gibt beide
   Meldungen wörtlich wieder, aus zwei selbst hergestellten Zuständen (R1 LEITUNG, R2 BAUM).
4. **Frage A, B und C sind beantwortet** — unten in dieser Notiz, nicht in §3. §5 verlangt sie
   *„im Plan"*; sie stehen damit in der Plan-Datei, aber in ihrem Closure-Abschnitt statt in einem
   Vor-Code-Abschnitt. Eine Vor-Code-Tabelle nachträglich mit dem Ergebnis zu füllen, machte aus
   einer offenen Frage eine erfundene Voraussicht.
5. **Die Beschreibung in [`harness/README.md`](../../../../harness/README.md) ist gezogen.** Der
   Nicht-Gate-Verify-Absatz trägt beide Ausgänge und dieselben vier Zählausdrücke wie der Sensor
   selbst; ein zweiter Satz daneben wäre die Drift-Konstruktion.
6. **Review konform (Modul 10).**
   [Code-Review](../../../reviews/2026-08-27-slice-106-review.md): *nicht formal frei*,
   `grep -c '^### F-' docs/reviews/2026-08-27-slice-106-review.md` → **4** (0 HIGH · 3 MEDIUM ·
   1 LOW). F-2 ist behoben, F-3 hat seit `ae00252` einen Wächter, F-1 und F-4 stehen unten als
   Delta.
7. **Verifikation (Modul 11).**
   [Bericht](../../../reviews/2026-08-27-slice-106-verify.md): *nicht frei, solange DoD (1) offen
   ist*, `grep -cE '^### 6\.[0-9]+ B-' docs/reviews/2026-08-27-slice-106-verify.md` → **8**
   Beobachtungen. B-1 ist mit dieser Closure erledigt, B-5 ist behoben, B-2/B-4/B-7 haben unten
   einen Träger, B-3 ist bis auf einen benannten Rest geschlossen, B-6 steht als Delta, B-8 hat
   einen eigenen Schnitt.
8. **`make gates` grün.** Eigener Lauf, Belege unten unter *Gates*.
9. **`git mv` nach `done/` als eigener Move-Commit** und **Closure-Notiz mit
   Steering-Loop-Eintrag** — diese Notiz; der Eintrag steht unten.

**Die Liste in §1 ist ein Register, kein Maßstab — deshalb ist sie ergänzt worden.**
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md) §7 hat die Grenze gezogen: eine
**Tatsachenbehauptung über die Welt** wird korrigiert, sobald sie widerlegt ist — sie war nie
Maßstab, sondern Begründung; ein **Abnahme-Kriterium samt seinem Rot-Kommando** wird nicht
korrigiert, sondern als Delta ausgewiesen. Die Liste ist das erste: sie behauptet, welche Läufe rot
waren, und diese Behauptung ist heute widerlegbar und widerlegt worden
(`gh run list --workflow=ci --limit 300 --json event,conclusion --jq '[.[]|select(.event=="push" and .conclusion=="failure")]|length'`
→ **11**). Sie ist zudem ausdrücklich als fortzuschreibend geschnitten — §3 sagt, ein neuer roter
Lauf werde **vor** der ersten Einordnung aufgenommen. Ergänzt sind vier Zeilen über drei Läufe; die
Fenster-Zahlen sind mit ihren Kommandos neu erhoben. **Nicht angepasst ist der Maßstab:** §2 lässt
sein Nenner-Kommando unverändert, §5 seine Acht. Ein Kriterium, das man am Ende an das Ergebnis
anpasst, hört auf, eines zu sein.

**Das Delta ist damit nicht die Zahl, sondern der Zeitpunkt.** §3 verlangt die Aufnahme **vor** der
ersten Einordnung; erfolgt ist sie bei der Closure. Der Grund ist benennbar und wiederholbar: die
Liste hat kein Kommando, das ihre Unvollständigkeit rot färbt — der Nenner ist eine Netz-Abfrage
über ein Retentions-Fenster und ausdrücklich kein Gate (§2). Wo nur eine Rolle nachzählt, zählt sie
am Ende nach. **Was daraus folgt, steht unten als Posten, nicht als Vorsatz.**

**Der Ausgang je Klasse, mit dem Grund.**

- **K1 — eine ausgehende HTTP-Abhängigkeit antwortete non-2xx (drei Vorfälle).** Zwei davon liegen
  in `make full-smoke`: Ausgang **als Umgebungs-Eigenschaft ausgewiesen**, und der Ausweis ist der
  Sensor selbst — das ist die Lieferung dieses Slice. Der Fetch-Punkt des Vorfalls vom 2026-07-28
  existiert nicht mehr
  ([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache);
  `git grep -c 'baseline-fetch' -- Makefile harness/` → leer, Exit 1). Der dritte liegt in
  `make mutate`: Ausgang **aufgeschoben**, und nicht ausgewiesen, weil DoD (2) den Ausweis an die
  Bedingung bindet, dass **der Lauf es selbst sagt** — `make mutate` sagt es nicht. **Der
  Auflösungs-Trigger, ohne Rückfrage entscheidbar:** der erste Fehlschlag in `make mutate`, der
  `AUSGANG LEITUNG` in seiner Ausgabe trägt; möglich wird er mit
  [slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md), für den dieser Vorfall der
  Anlass ist.
- **K2 — der reine Move-Commit lässt Verweise auf den alten Pfad zurück (drei Vorfälle).** Ausgang
  **als Eigenschaft ausgewiesen, mit entscheidbarem Kriterium**: jeder Befund nennt die verschobene
  Datei, als Ziel auf ihrem alten Pfad oder als Quelle in ihr selbst. Belegt an drei Läufen statt
  einem ([Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) §4) — und das Kriterium
  trennt gemessen auch nach unten: die drei roten `gates`-Läufe vom 2026-08-26 erfüllen es **nicht**
  und sind auch keine Move-Folge.
- **K3 — der Sensor hat einen echten Defekt gefunden (fünf Vorfälle).** Ausgang **abgelehnt**: das
  ist kein Befund über die CI, sondern ihr Zweck. Die drei vom 2026-08-26 tragen daneben eine
  Beobachtung über einen **grünen** Lauf auf dem Host; sie ist nicht Gegenstand dieses Slice und hat
  einen eigenen Träger
  ([slice-116](../open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md)).
- **K4 — `mutate` bricht ab, weil `full-smoke` in der isolierten Kopie schon ohne Mutation rot war
  (ein Vorfall).** Ausgang **aufgeschoben**, unverändert. Der Trigger aus §4 ist **nicht**
  eingetreten: der `mutate`-Fehlschlag vom 2026-08-26 hat eine andere Form — dasselbe Protokoll
  durch `grep -c 'ABBRUCH'` → **0** (Exit 1) gegen `grep -c 'BEFUND'` → **1**. Ein Abbruch der in §4
  genannten Form ist im Fenster nicht wieder aufgetreten.

**Frage A, B und C — die Antworten, die der Lauf getroffen hat.**

- **A (woran erkennt der Sensor die nicht beantwortete Anfrage?)** An der Ausgabe des Bau-Werkzeugs,
  über **vier** Muster, und jedes steht neben dem Lauf, an dem es gemessen wurde
  (`sed -n '/^MUSTER=(/,/^)/p' harness/tools/full-smoke-ausgang.sh | grep -c "^\s*'"` → **4**). Die
  enge Form aus Weg (C) — die Bilder vorher holen — ist **nicht** gebaut: sie hätte den Fehlschlag
  an eine Stelle verlegt, die wir besitzen, aber sie deckt nur die Bilder ab, die dieser Baum kennt,
  und der Lauf fordert auch die des **emittierten** Repos an. Der Preis der gewählten Form steht in
  §6 und im Kopf des Einordners: ändert ein Bau-Werkzeug seinen Wortlaut, fällt die Einordnung auf
  BAUM zurück — rot bleibt rot, die Aussage wird unschärfer, nie beschönigender.
- **B (deckt die Unterscheidung alle Fetch-Punkte oder einen?)** Sie deckt sie als **Kriterium**,
  nicht als Liste: eingeordnet ist jeder Abschnitt, der ein Bild anfordern kann, und die Probe
  darauf ist die Gleichung oben. Ausdrücklich **nicht** gedeckt sind die Paketquellen der C++-Kette
  — ein `apt`-Paket ist kein gepinntes Artefakt und fällt in den BAUM-Ausgang; das steht im Kopf des
  Einordners. Die Rückführung aus §4 (*„jeder der 90 Fetch-Punkte einzeln"*) ist damit **nicht**
  gezogen worden, und der Grund ist der Wechsel der Bezugsgröße: 90 Auflösungen liegen hinter 22
  eingeordneten Abschnitten.
- **C (bekommt K2 einen Sensor oder eine Feststellung?)** Eine **Feststellung mit Kriterium**. Ein
  Wächter darüber hätte ein CI-Protokoll als Prüfgegenstand, das keine `make`-Stufe kennt; das
  Kriterium dagegen ist ohne Urteil entscheidbar und hat sich an vier Läufen bewährt — an drei nach
  oben, an dreien nach unten.

**Vier Plan-vs-Code-Deltas — benannt, nicht geglättet.**

- **(1) Das Rot-Kommando von DoD (2) misst nichts, und es bleibt stehen.**
  `make build GO_VERSION=9.99.9-gibt-es-nicht` → **EXIT=0** in **1,30 s** (eigener Lauf; die vierte
  unabhängige Messung nach Implementer, Review und Verifikation). Der Grund steht in der Ausgabe des
  Laufs selbst: `grep -n '^FROM golang:' Dockerfile` → Zeile **14**, und dort steht der Digest hinter
  dem Tag — der Tag-Text wandert durch und entscheidet nichts. Wirksam ist die Variable über das
  **emittierte** Fragment (`grep -n 'FROM golang:' internal/gen/golang.go` → Zeile **882**, ohne
  Digest, mit Begründung im Code), und genau dort setzt `test/mutations/189` an. **Die Bedingung ist
  erfüllt, ihr Kommando nicht** — und das Kommando wird nicht nachgezogen: es ist Teil des Maßstabs,
  an dem der Lauf gemessen wurde.
- **(2) Zwei neue Artefakte fehlen in der §3-Tabelle:**
  [`harness/tools/full-smoke-ausgang.sh`](../../../../harness/tools/full-smoke-ausgang.sh) und
  `test/full-smoke-ausgang.bats`.
  `git show --name-status --format= f959912 ae00252 | sort -u` führt **9** Zeilen über **8**
  Dateien; §3 nennt für zwei davon keine Zelle. Die Tabelle wird **nicht** ergänzt — sie ist die
  Vor-Code-Aussage, und ein nachträglicher Eintrag machte aus einer Auslassung eine Voraussicht.
- **(3) Die Fragen A/B/C sind im Code beantwortet worden, nicht im Plan.** Ihre Antworten stehen
  oben in dieser Notiz; §3 bleibt unverändert.
- **(4) Die nicht-mechanische Hälfte von DoD (1) hat nicht der Träger getragen, den der Plan
  benennt.** §2 sagt *„Diese Hälfte trägt das Review"*; das Review vom 2026-08-27 ist ein
  **Code**-Review gegen den Diff und hat den Nenner nicht erhoben. Gefunden hat die Lücke die
  Verifikation, eingeordnet hat sie diese Closure. Der Plan hat damit einer Rolle eine Aufgabe
  gegeben, die außerhalb ihres Gegenstands liegt — ein Befund über den **Schnitt**, nicht über die
  Rolle.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Die Einordnung reicht so weit wie ihr Aufrufer.** `make mutate` fordert dieselben Bilder an und
  ruft den Einordner nicht (`grep -c 'einordnen\|full-smoke-ausgang' harness/tools/mutate.sh` → **0**,
  Exit 1). Gemessen ist, dass der Ausfall vom 2026-08-26 dort als *Befund über einen Wächter*
  erschien, den es nicht gab.
- **LEITUNG trägt seine Grenze nicht in der Meldung, BAUM tut es.** Der Kopf des Einordners schreibt
  für BAUM aus, was der Ausgang **nicht** sagt (`grep -c 'WAS DER BAUM-AUSGANG NICHT SAGT' harness/tools/full-smoke-ausgang.sh`
  → **1**); eine entsprechende Zeile für LEITUNG gibt es nicht (dieselbe Datei durch
  `grep -c 'WAS DER LEITUNG-AUSGANG NICHT SAGT'` → **0**, Exit 1). Der einzige End-zu-Ende-Beleg der
  Unterscheidung ist ausgerechnet ein Baum-Defekt: `test/mutations/189` schreibt einen nicht
  vergebenen Tag in das emittierte Fragment, und der Sensor sagt LEITUNG. Der Satz ist nicht falsch
  — er beobachtet, dass die Anfrage nicht mit 2xx beantwortet wurde —, aber ein selbst gesetzter,
  nicht auflösbarer Pin liest sich für den nächsten Leser als Registry-Aussetzer.
- **Der Abdeckungs-Wächter misst Anwesenheit, nicht Identität.** Selbst gemessen auf einer
  isolierten Kopie außerhalb des Repos: eine Zeile umgeschrieben, sodass eine Einordnung die Ausgabe
  eines **anderen** Abschnitts übergibt (`einordnen "make -j gates im Ziel (--lang go)"` bekommt
  `$artefakt_out` statt `$gates_out`) — `make test-bats` **EXIT=0**, `make shell-lint` **EXIT=0**,
  `make comment-claims` `46 Datei(en) geprueft, 0 Befund(e)`. Dieselbe Kopie mit der **entfernten**
  Zeile fällt dagegen sofort und lesbar: `not ok 71 … 22 make-Stufen geprueft, ohne Einordnung:
  [Zeile 217]` und `not ok 72 … A=33 B=5 C=6 D=23 -> A-B-C=22 gegen D-2=21`. Der Wächter deckt
  **beide** Drift-Richtungen der Menge und **keine** Drift innerhalb eines Abschnitts.
- **Was CI grün meldet, sagt nichts über die Fläche daneben.** Kein Kriterium dieses Slice verlangt,
  dass die CI danach grün ist (§5); erfüllt ist die **Einordnung**, nicht die Farbe.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Ein Kommando, das in demselben Artefakt steht, dessen Bestand es misst, zählt seine eigene
Erwähnung mit. Die Zahl gehört deshalb erhoben, **nachdem** das Kommando geschrieben ist, und mit
genau der Fassung, die dort steht — die Reihenfolge *Kommando schreiben, dann messen* ist keine
Sorgfalt, sondern die Bedingung, unter der die Zahl überhaupt gilt.**

**Der gemessene Anlass.** Der Kopf von
[`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) trägt die Probe auf die
Abdeckungs-Zusage als Gleichung; ihr letzter Term ist eine Zählung der Einordnungen in derselben
Datei. Mit dem Aufschreiben der Gleichung enthielt die Datei den gesuchten String ein zusätzliches
Mal: `grep -c 'einordnen "' harness/tools/full-smoke.sh` → **25**, während die Menge, über die die
Zusage spricht, **24** Elemente hat — die 25. Fundstelle ist Zeile **47**, die Gleichung selbst
(`grep -n 'einordnen "' harness/tools/full-smoke.sh | head -1`). Behoben ist es durch einen Anker:
`grep -cE '^[[:space:]]*einordnen "' harness/tools/full-smoke.sh` → **24**, weil die Kommentarzeile
mit `#` beginnt. Gefunden hat es kein Gate, sondern das erneute Fahren des Kommandos **nach** dem
Schreiben.

**Warum das nicht der Einzelfall ist, mit der Menge vor der Zahl.** Die Eigenschaft: *ein Kommando,
dessen Prüfbereich den Text enthält, der es zitiert*. **Zwei** Fundorte tragen sie mit Beleg —
dieser hier und der Watcher-Selbstmatch in
[slice-045a](../done/slice-045a-hexslice-go-renderer.md) §7
(`grep -c 'Watcher-Selbstmatch' docs/plan/planning/done/slice-045a-hexslice-go-renderer.md` → **1**:
ein `pgrep -f`-Muster, das die eigene Prozesszeile traf und den Watcher nie terminieren ließ). Ein
dritter Fall — eine Fenster-Prüfung, die `make gates` in ihrer eigenen Kommandozeile traf — ist aus
der Übergabe berichtet; **für ihn liefert kein Kommando einen Fundort**, und das steht hier, statt
ein ungefähr passendes danebenzustellen
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). **Untergrenze, mit Absicht:** ob eine Zählung ihre eigene Erwähnung trifft, ist ein
Urteil über den Prüfbereich und kein Muster.

**Warum ausgerechnet dieser Eintrag, und nicht die zwei anderen Kandidaten.** Der Implementer hat
ein **drittes** Rot gefahren, das niemand verlangt hatte — den zweiten Meldungs-Zweig seiner
Gleichung, mit der Begründung, eine nie im Rot gelesene Fehlermeldung sei genau die Klasse dieses
Slice. Das ist die Anwendung des **sechsten** Postens von
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) auf einen frisch geschriebenen
Wächter und damit ein **Beleg**, dass jener Posten trägt — kein neuer Lerneintrag, sondern das
Gegenteil eines fehlenden Trägers. Der Selbsttreffer dagegen hat in der Postens-Liste **keine**
Achse: die Postens zwei bis acht handeln von den Trägern eines Rot-Belegs, seiner Reichweite, seinem
Gegenstand, der Richtung seines Fehlers, seiner Ausgabe, der Anweisung im Quelltext und dem Baum,
über dem er erhoben wurde; der neunte von der Form der Plan-Tabelle. Keiner handelt von der
**Rückwirkung des Messens auf das Gemessene** — und die entsteht hier nicht zufällig, sondern durch
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 selbst, die Zahl und Kommando in dasselbe Artefakt zwingt. Eine Regel, die ihre eigene
Fehlerquelle erzeugt, gehört um deren Behandlung ergänzt.

**Träger: [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) — als zehnter Posten,
ausdrücklich nicht *„der Architect"*.** Jener Slice ist für diese Klasse geschnitten, trägt seinen
Termin selbst und verlangt in §3, dass ein weiterer Posten **vor** der ersten Entscheidung
aufgenommen wird und dabei steht, woran er erkannt ist. Er ist dort eingetragen; **der Regeltext
wird hier nicht vorentschieden**, er entsteht im Architect-Lauf
([`AGENTS.md`](../../../../AGENTS.md) §3.8,
[`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1).

**Der neunte Posten von [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) ist
geschärft, nicht verdoppelt.** Er verlangte bisher, die Plan-Tabelle §3 nenne auch die *bestehende
gemeinsame Stelle*, die ein neuer Wächter bewegen muss. Delta (2) oben ist die **vierte** Instanz
derselben Symptom-Klasse und die **erste**, die der Posten in seiner bisherigen Fassung nicht fängt:
die zwei fehlenden Dateien sind **neu angelegt**, keine bewegte Bestandsstelle — und die eine von
ihnen ist der Träger der Sache selbst. Ein zehnter Posten für denselben Adressaten (die Form des
Plans), denselben Ausgang (ein Eintrag im Adaptions-Block) und dasselbe Kommando in dessen DoD (2)
wäre eine Zweitfassung, die driftet; geschärft ist deshalb der vorhandene.

**Offen, mit Träger.**

| Posten | Träger |
|---|---|
| `make mutate` fordert dieselben gepinnten Bilder an und ruft den Einordner nicht; der Ausfall vom 2026-08-26 erschien dort als Befund über einen Wächter, den es nicht gab | **[slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md)** — Anlass, DoD (1) und der aufgeschobene K1-Ausgang |
| LEITUNG trägt seine Grenze nirgends, BAUM trägt sie in der Meldung; der einzige End-zu-Ende-Beleg der Unterscheidung ist ein Baum-Defekt | **[slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md)** — dieselbe Datei, dieselbe Frage |
| Der Abdeckungs-Wächter prüft, **dass** eingeordnet wird, nicht **welche** Ausgabe; eine falsch verdrahtete Zeile lässt drei Sensoren grün (oben gemessen) | **[slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md)** — die Prüfschleife liegt fertig in der [Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) §3.3 |
| `make docs-check` sieht einen Verweis auf einen gitignorierten Pfad lokal nicht, sobald ein früherer Lauf das Ziel angelegt hat; drei der elf roten Läufe gehen darauf zurück | **[slice-116](../open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md)** |
| Die Menge des Abdeckungs-Kriteriums altert an einer Stelle, die das Kriterium nicht sieht: eine künftige **bare** `make`-Zeile unter `set -e` läge außerhalb von A, forderte ein Bild an und ließe die Gleichung unverändert wahr | **[slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md)** — als §3-Zelle des Wächters, der ohnehin angefasst wird; heute ist die Lücke leer, **fremdbelegt** über alle `make `-Zeilen des Sensors ([Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) §3.3: keine ausführende ohne eigenen Exit-Code) |
| Ein Kommando, das seine eigene Erwähnung mitzählt | **[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md)** — der Steering-Loop-Eintrag oben, dort als zehnter Posten eingetragen |
| Die Plan-Tabelle §3 nennt auch die Dateien, die der Lauf **neu anlegt** | **[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md)** — der neunte Posten, dort geschärft |
| Die Vollständigkeit der Ausgangs-Liste hat kein Kommando, das sie rot färbt — der Nenner braucht Netz und ein Retentions-Fenster | **kein Träger, und das ist entschieden** — §2 sagt es selbst, und ein Gate über einer fremden API wäre eines, das ohne Befund rot wird ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| Ob ein Adopter dieselbe Unterscheidung bekommt | **kein Träger, und das ist entschieden** — der Sensor geht in kein Zielrepo (Kopfzeile *Ebene*); was die emittierte Ebene bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet |

**Folge-Slices: zwei neue `open/`-Einträge.**
[slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md) (jeder Sensor, der gepinnte
Bilder anfordert, nennt seinen Ausgang — und der Wächter misst, welche Ausgabe eingeordnet wird) und
[slice-116](../open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md) (der Doku-Gate
urteilt über den getrackten Bestand, nicht über die Rückstände eines früheren Laufs). **Beide sind
wellenlos** — die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 sind in ihren Kopfzeilen einzeln beantwortet; die Roadmap bekommt daher keinen Eintrag
(ebenda Setzung 2/3).

**Was [slice-105](../next/slice-105-mutate-messen-dann-teilen.md) damit bekommt.** Seine DoD (2) und
(3) hängen daran, dass der Befund an `make full-smoke` einen der vier Ausgänge trägt. Er trägt zwei:
**ausgewiesen** für den Teil, der in `full-smoke` liegt, **aufgeschoben** für den Teil, der in
`mutate` liegt. Die Sperre ist damit gelöst; welche Reihenfolge zwischen
[slice-105](../next/slice-105-mutate-messen-dann-teilen.md) und
[slice-115](../open/slice-115-jeder-sensor-sagt-seinen-ausgang.md) sinnvoll ist, entscheidet nicht
diese Notiz — beide fassen `harness/tools/mutate.sh` an, und das ist eine Beobachtung, keine
Reihenfolge.

**Gates.** Eigener Lauf über dem Baum, den diese Closure hinterlässt — Notiz, Listen-Ergänzung, die
Schärfung in [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) und die zwei
geschnittenen Slices eingerechnet: `make gates` **EXIT=0**,
`baseline-verify: v3.5.2 OK — 42 Dateien`, `d-check: 411 Datei(en) geprüft, 0 Befund(e)`,
golangci-lint `0 issues.`, bats `grep -c '^ok '` → **162** und `grep -c '^not ok'` → **0**,
`comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün; danach sind
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` byte-gleich. Die
Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2); jede weitere Zeile an dieser Notiz verschiebt den Stempel, und der Lauf, der ihn wieder
bindet, gehört zu ihr. **Fremdbelegt** und ausdrücklich nicht von dieser Rolle erhoben: `make
full-smoke` (**EXIT=0**, 88,10 s) und `make mutate` (**183 ok, 0 Befund(e)**) — die zwei teuren
Sensoren stehen in der [Verifikation](../../../reviews/2026-08-27-slice-106-verify.md) §1.1 und in
der Message von `ae00252`.

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
