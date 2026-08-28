# CO-003: `make mutate` hat keine Zeitschranke — ein hängender Worker färbt den Lauf nicht rot

**Status:** Aktiv — **Auflösung fällig**, nicht offen: der Auflösungs-Trigger ist eingetreten
(Letzte Prüfung unten), und der Vollzug ist als
[slice-120](../planning/in-progress/slice-120-co-003-wird-vollzogen.md) geschnitten. Die Datei liegt
weiter hier und nicht in `done/`, weil eine Auflösung erst gilt, wenn sie **vollzogen** ist —
`git mv`, Index und Link-Abgleich über die eingehenden Verweise. Dieser Rest liegt bei einer
anderen Rolle (Modul 7 §Carveout-Audit-Slice: *„Implementer führt `git mv` und Config-Updates
aus"*); die Übergabe steht unten. Dieselbe Lage trägt [CO-001](CO-001-bats-shell-lint.md) seit dem
2026-08-27.

**Datum angelegt:** 2026-08-27. **Letzte Prüfung:** 2026-08-28 (Architect-Entscheidung über den
Trigger, aus [slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) §7 übergeben.
Drei Ergebnisse: Bedingung 1 ist **gestrichen** — sie prüfte die Anwesenheit eines Wortes, während
ihr Gegenstand eine Eigenschaft ist (Begründung unten mit ihren Kommandos); die verbleibenden zwei
Bedingungen sind **eingetreten**; der zweite Ausgang ist **verneint** — der Trigger ist erreichbar
und erreicht, also bleibt CO-003 temporär und wandert nicht in eine ADR. Modul-7-Übergang:
*aufgelöst*, Vollzug ausstehend). **Vorherige Prüfung:** 2026-08-27 (Audit in der Closure zu
[slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) — Modul-7-Übergang *weiterhin
aktiv*).

**Betroffenes Gate:** **keines — und das ist die erste Aussage dieses Carveouts.** Betroffen ist
`make mutate`: ein Nicht-Gate-Verify, das **nicht** in `make gates` läuft, aber pro Push als
eigener CI-Job fährt
([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)). Gesenkt
ist keine Gate-Schwelle. Registriert war eine **Zusage** ohne rot gesehenes Gegenbeispiel: der
dritte der drei Ausfall-Wege, die
[slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §2 DoD (3) nennt. Wer diesen
Carveout mit [CO-001](CO-001-bats-shell-lint.md) vergleicht, findet dort eine Gate-Konfiguration
mit Ausnahme, hier eine Zusage ohne Sensor.

**Geltungsbereich:** **eines** der drei Worte, die jene DoD über einen **Shard** sagt — *„ein
Shard, der abstürzt, **hängt** oder nichts meldet, färbt den Gesamtlauf rot"*. *Abstürzt* und
*nichts meldet* waren schon bei der Anlage gedeckt und rot gesehen — der erste über den
Abschluss-Marken-Zweig in `main()`, der zweite über die drei Vollständigkeits-Achsen von
`merge_report`; beide sind in der
[Verifikation](../../reviews/2026-08-27-slice-105-verify.md) §4.1/§4.2 an gefahrenen Läufen belegt.
*Hängt* ist es seit dem 2026-08-27:

- **Ein hängender Worker färbt den Lauf rot, ohne Zutun von außen.** `await_workers` misst die
  **Stille** des Laufs, nicht die Lebendigkeit eines Prozesses: ein Worker protokolliert seinen Zug,
  **bevor** sein Grün-Vorlauf und sein Fall laufen (`worker_main`), und `progress_count` zählt Züge
  und Urteile. Vergehen `STALL_SECONDS`, ohne dass **irgendein** Worker zieht oder abschließt,
  endet der Lauf rot und benennt die noch laufenden Worker. Beide Hänger-Lagen eines Workers — im
  Fall und im eigenen Grün-Vorlauf — liegen damit in derselben Stille; ein Hänger färbt den Lauf
  rot, sobald die übrigen Worker fertig sind. **Rot gesehen ist die Fall-Lage** (Bedingung 1 unten,
  Exit 1 nach 17,27 s); die Vorlauf-Lage ist aus dem Mechanismus gelesen, nicht gefahren.
- **Die Schranke steht unter zwei Zähnen:** Fall `199` nimmt der Stille ihre Messgröße, Fall `202`
  nimmt dem Einsammeln die Verdrahtung. Die zweite, ältere Schranke — der Warteschlangen-Mutex — ist
  mit Fall `198` ebenfalls nicht mehr unbewacht (Bedingung 2 unten).
- **Der Vorwärmlauf vor dem Fork liegt außerhalb dieses Carveouts, und das ist eine Entscheidung
  mit Kriterium.** Das Subjekt jener DoD ist der **Shard**. Der Vorwärmlauf läuft, bevor der erste
  Worker existiert; ein Hänger dort ist kein Shard, der hängt, sondern der Treiber, der wartet.
  Maßgeblich für den Zuschnitt ist dieses Header-Feld — Modul 7 führt `Geltungsbereich` als eines
  der sechs Pflicht-Felder —, nicht der Titel der Datei. Der Rest hat seinen eigenen Träger
  ([slice-118](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md)) und ist **keine Zusage
  ohne Sensor**: kein lebendes Artefakt sagt, dass der Vorwärmlauf von selbst endet — der Treiber
  und [`harness/README.md`](../../../harness/README.md) sagen ausdrücklich das Gegenteil
  (`grep -c 'VORWAERMLAUF vor dem Fork' harness/tools/mutate.sh` → **1**,
  `grep -c 'Vorwärmlauf vor dem Fork' harness/README.md` → **1**). Eine benannte Lücke mit Träger
  ist ein `open/`-Slice, kein Carveout.

**Folge-Slice:** [slice-120](../planning/in-progress/slice-120-co-003-wird-vollzogen.md) — der
**Vollzug** der Auflösung: `git mv` nach `done/`, Index und Link-Abgleich in beide Richtungen
(§Übergabe unten). Sein Beginn-Trigger liest dieses Feld (dort §4), und darin liegt der Grund,
aus dem hier eine ID steht und keine Absichtserklärung: Modul 7 verlangt einen *„Folge-Slice mit
ID, der das Auflösen plant. Slice schlägt Memo."*

Zwei Slices stehen daneben, und keiner von beiden ist dieser:

- [slice-113](../planning/open/slice-113-co-001-ist-faellig.md) ist das **Muster**, nicht der
  Zwilling — derselbe Zug für [CO-001](CO-001-bats-shell-lint.md), aber mit **zwei** Ausgängen:
  seine DoD (3) führt *„Bei Auflösung"* und *„Bei Nicht-Auflösung"* nebeneinander, weil dort eine
  Technik-Wahl offen ist. Hier ist der Trigger entschieden, und es gibt einen Ausgang.
- [slice-118](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md) trägt den Hänger im
  Vorwärmlauf **vor** dem Fork — seit der Prüfung vom 2026-08-28 außerhalb des Geltungsbereichs,
  mit eigenem Träger, und er blockiert die Auflösung nicht.

Geschnitten hat den Vollzug der Planner (Modul 7 §Carveout-Audit-Slice: *„Planner identifiziert
die fälligen Carveouts"*); den Vorgänger-Schnitt
[slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md), der den Gegenstand geliefert
hat, ebenfalls.

---

## Begründung

**Warum die Schranke nicht im selben Slice entstanden ist.** Sie war keine vergessene Zeile,
sondern eine eigene Konstruktions-Entscheidung mit einer eigenen Messfrage: **wo** sie sitzt (um
`wait` oder um den Sensor-Lauf in `run_case`) und **wie hoch** sie bemessen ist. Eine Schranke, die
auf **20** Kernen großzügig ist (`nproc` → **20** auf dem Host, über den die Messreihe des Slice
läuft), ist auf dem CI-Runner mit vier vCPU eine Fehlschlag-Quelle ohne Befund — und ein Sensor,
der ohne Befund rot wird, ist genau die Klasse, gegen die
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht. Der
Unterschied ist gemessen und nicht geschätzt: derselbe Sensor über denselben **188** Fällen bei
N=4 kostet **2,80 s je Fall** auf dem Host und **6,74 s je Fall** im CI-Job (beide Zahlen mit ihren
Kommandos in [slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §1). Die Zahl zu
raten hätte den Sensor beschädigt, den der Slice gerade repariert hat.

**Was die Zusage heute trägt.** Sie hängt am **Treiber** und nicht mehr an der Umgebung des Laufs.
Die Schranke steht an **einer** Stelle (`grep -cE '^STALL_SECONDS=' harness/tools/mutate.sh` →
**1**) und hat keine zweite Vorgabe daneben (`grep -c 'MUTATE_STALL_SECONDS' Makefile` → **0**,
`grep -c 'timeout-minutes' .github/workflows/ci.yml` → **0**). Sie begrenzt **Stille**, nicht Dauer
— darum ist sie nicht je Modus zu bemessen, und ein langsamer Runner macht langsamen Fortschritt,
aber er macht welchen. Ihre Herleitung — längste *legitime* Stille mal Sicherheitsfaktor, mit den
Zahlen beider Rechnungen — steht in
[slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 Frage A/B und in der
[Verifikation Runde 2](../../reviews/2026-08-27-slice-117-verify-runde2.md) §2.6; sie sind Lesungen
aus gefahrenen Läufen, die kein Kommando dieses Baums wiederholt
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Was die Bemessung **nicht** deckt, steht dort ebenfalls: ein Fall, der langsamer als
die Schranke, aber endlich ist.

**Kein lebendes Artefakt behauptet mehr, als der Code hält** — nachgelesen, damit dieser Carveout
eine Lage registriert und keine Lüge. [`harness/README.md`](../../../harness/README.md)
§Nicht-Gate-Verify beschreibt die Schranke, ihre Stellschraube und ihre zwei Grenzen
(`grep -c 'MUTATE_STALL_SECONDS' harness/README.md` → **1**), und sein einziges *„hängt"*
(`grep -o 'hängt' harness/README.md | wc -l` → **1**) meint weiter etwas anderes — *„die Modi,
deren Urteil an einem geteilten Docker-Tag hängt"*. Der Kopf von `harness/tools/mutate.sh` zählt
zwei Befund-Wege auf (*„Ein Worker, der stirbt, und ein Fall, den die Warteschlange nie ausgibt"*)
und nennt den dritten nicht; der steht bei `STALL_SECONDS`. Das ist eine unvollständige Aufzählung,
keine falsche Zusage — wer die Zeile anfasst, zieht sie nach
([`AGENTS.md`](../../../AGENTS.md) §3.7 Cutoff). **Die Zählungen sind kein
Vollständigkeits-Beleg**, sondern die Fundorte einer Lesung; die Aussage trägt das Lesen beider
Stellen.

## Auflösungs-Trigger

**Ein hergestellter Hänger endet ohne Signal von außen rot.** Zwei Bedingungen, ohne Rückfrage
entscheidbar — **beide eingetreten**:

1. Ein Lauf über einer Kopie mit einem `make`-Stub, der für genau einen Fall nicht zurückkehrt,
   endet **ohne** `timeout` von außen mit Exit ≠ 0 und benennt den Worker.
   **Eingetreten.** Gefahren am 2026-08-27 in der
   [Verifikation Runde 2](../../reviews/2026-08-27-slice-117-verify-runde2.md) §2.1 — `EXIT=1`
   nach **17,27 s**, *„seit 10 s hat kein Worker einen Fall gezogen oder abgeschlossen — der Lauf
   steht. Noch laufend: Worker 2"*. Die Zahlen stammen aus jenem Lauf und aus keinem Kommando
   dieses Baums. Dass der Beleg für **diesen** Baum weiter gilt, ist gemessen statt angenommen:
   `for fn in await_workers collect_workers stop_workers; do diff <(git show 9b9866b:harness/tools/mutate.sh | sed -n "/^${fn}() {/,/^}/p") <(sed -n "/^${fn}() {/,/^}/p" harness/tools/mutate.sh); done`
   → **leere Ausgabe für alle drei**.
2. `grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` liefert **≥ 1** — die zweite, ältere Schranke ist
   dann nicht mehr die einzige unbewachte
   ([slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) DoD 3).
   **Eingetreten**, das Kommando liefert **2** (mitwandernd, ausdrücklich **kein** Erwartungswert —
   [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   Setzung 2). Die Zähne der Schranke selbst tragen die Fälle `199` und `202`, und jeder nennt
   einen bats-Titel, den es gibt:
   `for c in 199 202; do t="$(sed -n 's/^# expect: //p' test/mutations/$c-*.sh)"; grep -c "^@test \"$t\" {" test/mutate-driver.bats; done`
   → **1** und **1**.

**Warum hier keine Bedingung über dem Wort `timeout` steht.** Das Warten steht unter
`STALL_SECONDS`, und diese Schranke nennt das Wort nie:
`sed -n '/^await_workers()/,/^}/p' harness/tools/mutate.sh | grep -c 'timeout'` → **0**, dasselbe
über `collect_workers` → **0**. Eine Bedingung über der **Anwesenheit** des Wortes fällt darum in
beide Richtungen falsch aus, und beides ist gemessen: am ersten Umsetzungs-Commit der Reparatur
liefert `git show 6020941:harness/tools/mutate.sh | grep -c 'timeout'` → **0**, während dort die
Schranke bereits stand (`git show 6020941:harness/tools/mutate.sh | grep -cE '^STALL_SECONDS='` →
**1**) und der hergestellte Hänger von selbst rot wurde; an diesem Baum liefert
`grep -c 'timeout' harness/tools/mutate.sh` → **4** (mitwandernd), und `grep -n` zeigt alle vier als **Kommentar**
(Zeilen 630, 635, 922, 924), keinen in Befehlsposition. Eine Zahl, die falsch ist, wenn ihr
Gegenstand gilt, und richtig aus Rauschen, wenn er es nicht tut, ist keine Schwelle — sie zu
streichen senkt nichts. Was den Gegenstand misst, ist Bedingung 1: endet der hergestellte Hänger
ohne Zutun von außen rot, **gibt** es die Schranke, und sie ist die, die das Warten begrenzt.

**Der zweite Ausgang ist entschieden: er tritt nicht ein.** Er lautete — zeigt die Bemessungs-Frage
aus [slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 Frage B, dass jede
tragfähige Schranke auf einem langsamen Runner regelmäßig ohne Befund auslöst, ist die Zusage
*„hängt"* dauerhaft nicht zu halten und der Carveout gehört in eine ADR übergeführt. Frage B ist
beantwortet, und die Antwort ist gebaut: die Schranke bemisst **Stille** statt Wanduhr, ihr Wert
kommt aus der längsten legitimen Stille mal Sicherheitsfaktor, und ein langsamer Runner erzeugt
langsamen Fortschritt, keinen ausbleibenden. Modul-7-Frage 2 (*Trigger ernst zu erreichen?*) steht
damit auf **Ja** — erreicht, nicht nur erreichbar. **Kein ADR**, und auch aus dem zweiten Grund
nicht: die Änderung **hebt** eine Zusage an und senkt keine Schwelle
([`AGENTS.md`](../../../AGENTS.md) §3.5).

## Geltungs-Konfiguration

Keine Gate-Konfiguration trägt eine Ausnahme für diesen Carveout — es gibt nichts auszunehmen. Was
es gibt, sind drei Stellen, an denen der Posten sichtbar ist. Offen ist an keiner von ihnen noch
etwas; was der Vollzug dort anfasst, ist der Link auf diese Datei, nicht die Aussage der Zeile
(`for f in done/slice-105 done/slice-117 open/slice-118; do grep -c '](\([^)]*\)CO-003-mutate-ohne-zeitschranke\.md)' docs/plan/planning/$f-*.md; done`
→ **6**, **7** und **1**; mitwandernd, **kein** Erwartungswert):

| Datei | Zeile/Section | Wert |
|---|---|---|
| [`slice-105-mutate-messen-dann-teilen.md`](../planning/done/slice-105-mutate-messen-dann-teilen.md) | §2 DoD (3) | Haken **gesetzt** — `grep -c '^- \[x\] \*\*(3)' docs/plan/planning/done/slice-105-mutate-messen-dann-teilen.md` → **1**. Er steht seit dem 2026-08-28; *wodurch* und *wann* sagt der Punkt an Ort und Stelle, Kriteriumstext und Rot-Kommando unangetastet. Bis dahin trug `CO-003` das eine Wort, das offen war |
| [`slice-117-lauf-ohne-ende-faerbt-rot.md`](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) | §2 DoD (1) und (3) | der Auflösungs-Trigger als Abnahme-Kriterium; beide erfüllt (§7 dort) |
| [`slice-118-vorwaermlauf-endet-von-selbst.md`](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md) | §2 DoD (1) | der Vorwärmlauf vor dem Fork — **außerhalb** des Geltungsbereichs, eigener Träger |

## Übergabe — was die Auflösung vollzieht, und wer sie vollzieht

Modul 7 verteilt die Auflösung über drei Rollen, und das ist Absicht: *„Planner identifiziert die
fälligen Carveouts, Architect entscheidet bei ‚permanent' über die ADR-Überführung, Implementer
führt `git mv` und Config-Updates aus."* Der Architect-Teil ist mit dieser Prüfung erledigt, der
Planner-Teil seit dem 2026-08-28; offen ist allein der Implementer-Teil.

| An | Was | Warum nicht hier |
|---|---|---|
| **Planner** — **erledigt am 2026-08-28** | den Vollzug schneiden ([slice-120](../planning/in-progress/slice-120-co-003-wird-vollzogen.md); Muster: [slice-113](../planning/open/slice-113-co-001-ist-faellig.md) für [CO-001](CO-001-bats-shell-lint.md)) und über den Haken an [slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §2 DoD (3) entscheiden — er steht (§Geltungs-Konfiguration) | Schnitte und `docs/plan/planning/**` gehören dem Planner |
| **Implementer** | `git mv` nach `done/`, Index nachziehen, Link-Abgleich über die eingehenden Verweise — **9** Dateien (`grep -rln 'CO-003' --include='*.md' . \| grep -v '^./.harness' \| grep -v 'CO-003-mutate' \| wc -l`; mitwandernd, **kein** Erwartungswert), davon **4** unter `docs/plan/planning/` und **4** unter `docs/reviews/` (dieselbe Form über dem jeweiligen Pfad) | der Move ist ein eigener Commit ([`AGENTS.md`](../../../AGENTS.md) §3.3), und der Link-Abgleich fasst Dateien an, die anderen Rollen gehören |

## Verifikation (nach Auflösung)

- [x] Die Trigger-Bedingungen oben sind erfüllt, jede mit ihrem Kommando gefahren (2026-08-28).
- [ ] `make gates` grün ohne Ausnahme, `make mutate` ohne Befund — über dem Baum, der den Move trägt.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`). <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
- [ ] Der Index in [`README.md`](README.md) zieht mit.
- [x] Der Haken an [slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §2 DoD (3) ist gesetzt (2026-08-28; §Geltungs-Konfiguration nennt das Kommando) — die zweite Alternative dieses Punktes, die begründete Auslassung, entfällt damit.
- [x] Folge-Slice [slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) geschlossen (§7 dort).
- [x] [slice-118](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md) explizit dokumentiert — er trägt den Teil, der außerhalb des Geltungsbereichs liegt, und blockiert die Auflösung nicht.

**Warum vier Haken stehen und drei nicht — die Trennlinie ist der Ort.** Ein Punkt bekommt seinen
Haken, wenn seine Tatsache feststeht, nicht wenn die Datei umzieht; die Überschrift nennt den
**spätesten** Zeitpunkt, nicht den frühesten. Die drei offenen sind genau die, deren Wahrheit **am
Ort** hängt — sie sind erst über dem Baum wahr, der den Move trägt, und Modul 7
§Carveout-Audit-Slice weist diesen Zug dem Implementer zu (*„`git mv` und Config-Updates"*). Die
vier gesetzten hängen nicht am Ort: sie sind über diesem Baum wahr, und jede ihrer Tatsachen ist
oben belegt. Wer den Haken an
[slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) dennoch dem Vollzug
überließe, setzte ihn dort für eine Tatsache, die mit dem Move nichts zu tun hat — und die
Zähl-Bedingung, die ihn dazu brächte, zählt offene Punkte, statt ihre Tatsachen zu prüfen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-27 | Angelegt (Closure zu slice-105; DoD (3) für einen der drei Ausfall-Wege ohne rot gesehenes Gegenbeispiel) | [slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §7 |
| 2026-08-27 | Audit in der Closure zu slice-117 — Modul-7-Übergang *weiterhin aktiv*: Bedingung 2 und 3 erfüllt und gefahren, Bedingung 1 misst ihren Gegenstand nicht, offen bleibt der Vorwärmlauf vor dem Fork. Trigger-Änderung an den Architect übergeben | [slice-117](../planning/done/slice-117-lauf-ohne-ende-faerbt-rot.md) §7 |
| 2026-08-28 | Architect-Entscheidung: die Wort-Bedingung gestrichen (in beide Richtungen falsch, gemessen an zwei Ständen), der Geltungsbereich am Subjekt der DoD geschärft (*Shard*, nicht Vorwärmlauf), zweiter Ausgang verneint. Modul-7-Übergang **aufgelöst** — Trigger eingetreten, Vollzug ausstehend und übergeben | diese Datei, §Auflösungs-Trigger und §Übergabe |
| 2026-08-28 | Folge-Slice eingetragen: der Vollzug ist als [slice-120](../planning/in-progress/slice-120-co-003-wird-vollzogen.md) geschnitten, das Pflicht-Feld trägt seine ID. Der Haken an [slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §2 DoD (3) steht seit demselben Tag und ist in der Verifikations-Checkliste gesetzt — er hängt nicht am Ort dieser Datei und wartet darum nicht auf den Move | diese Datei, §Folge-Slice und §Verifikation |
