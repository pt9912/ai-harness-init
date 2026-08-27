# CO-003: `make mutate` hat keine Zeitschranke — ein hängender Worker färbt den Lauf nicht rot

**Status:** Aktiv.

**Datum angelegt:** 2026-08-27. **Letzte Prüfung:** 2026-08-27 (Audit in der Closure zu [slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) — Modul-7-Übergang *weiterhin aktiv*).

**Betroffenes Gate:** **keines — und das ist die erste Aussage dieses Carveouts.** Betroffen ist
`make mutate`: ein Nicht-Gate-Verify, das **nicht** in `make gates` läuft, aber pro Push als
eigener CI-Job fährt
([`MR-014`](../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)). Gesenkt
ist keine Gate-Schwelle. Offen ist eine **Zusage**: der dritte der drei Ausfall-Wege, die
[slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §2 DoD (3) nennt — *„ein
Shard, der abstürzt, **hängt** oder nichts meldet, färbt den Gesamtlauf rot"* —, hat kein rot
gesehenes Gegenbeispiel und kann keines haben, solange nichts rot wird
([`AGENTS.md`](../../../AGENTS.md) §3.6). Wer diesen Carveout mit
[CO-001](CO-001-bats-shell-lint.md) vergleicht, findet dort eine Gate-Konfiguration mit Ausnahme,
hier eine Zusage ohne Sensor.

**Geltungsbereich:** **eines** der drei in jener DoD genannten Worte. *Abstürzt* und *nichts
meldet* sind gedeckt und rot gesehen — der erste über den Abschluss-Marken-Zweig in `main()`, der
zweite über die drei Vollständigkeits-Achsen von `merge_report`; beide sind in der
[Verifikation](../../reviews/2026-08-27-slice-105-verify.md) §4.1/§4.2 an gefahrenen Läufen belegt.
Offen ist *hängt*, und der Stand ist seit dem Audit vom 2026-08-27 **geteilt**:

- **Gedeckt ist das Warten auf die Worker.** Ein hergestellter Hänger endet ohne Zutun von außen
  mit Exit ≠ 0 und benennt den Worker (Bedingung 2 unten, **erfüllt** — gefahren in der
  [Verifikation Runde 2 zu slice-117](../../reviews/2026-08-27-slice-117-verify-runde2.md) §2.1,
  Exit 1 nach 17,27 s), und die zweite, ältere Schranke ist nicht mehr unbewacht
  (`grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` → **2**, Bedingung 3 **erfüllt**, mitwandernd —
  [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2).
- **Offen ist der Ort, an dem es noch keine Worker gibt:** ein Hänger im **Vorwärmlauf vor dem
  Fork**. Dort bewacht `await_workers` nichts, und der Lauf endet nur durch Zutun von außen —
  gemessen Exit 137 nach 50,01 s, ohne Bericht (dieselbe Verifikation, §2.2). Träger ist
  [slice-118](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md).
- **Bedingung 1 unten misst ihren Gegenstand nicht, und das ist der Grund, aus dem dieser Carveout
  aktiv bleibt.** `grep -c 'timeout' harness/tools/mutate.sh` → **4** (mitwandernd; bei Anlage
  **0**), und alle vier Fundstellen sind **Kommentar** — die tragende Schranke nennt das Wort nie:
  `sed -n '/^await_workers()/,/^}/p' harness/tools/mutate.sh | grep -c 'timeout'` → **0**, dasselbe
  über `collect_workers` → **0**. `grep -c 'timeout-minutes' .github/workflows/ci.yml` → **0**
  (mitwandernd). Ein Haken auf dieser Zahl wäre ein grüner Beleg für eine andere Sache; die
  Bedingung zu ändern ist dieselbe Entscheidung wie der zweite Ausgang unten und gehört dem
  **Architect**.

Der Haken an DoD (3) des abgeschlossenen Slice steht deshalb weiterhin **nicht**, und dieser
Carveout ist der Grund, aus dem er trotzdem in `done/` liegt (Modul 5 §Closure-Regeln).

**Folge-Slice:**
[slice-118](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md) — er trägt den offenen Teil
(der Vorwärmlauf vor dem Fork). Den gedeckten Teil hat
[slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) geliefert: seine DoD (1)
ist der Auflösungs-Trigger unten, seine DoD (3) hat `QUEUE_LOCK_TRIES` bezahnt. Geschnitten hat den
ersten der Planner in der Closure zu
[slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md), den zweiten in der Closure zu
[slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md).

---

## Begründung

**Warum die Schranke nicht im selben Slice entstanden ist.** Sie ist keine vergessene Zeile,
sondern eine eigene Konstruktions-Entscheidung mit einer eigenen Messfrage: **wo** sie sitzt (um
`wait` oder um den Sensor-Lauf in `run_case`) und **wie hoch** sie bemessen ist. Eine Schranke, die
auf **20** Kernen großzügig ist (`nproc` → **20** auf dem Host, über den die Messreihe des Slice
läuft), ist auf dem CI-Runner mit vier vCPU eine Fehlschlag-Quelle ohne Befund — und ein Sensor,
der ohne Befund rot wird, ist genau die Klasse, gegen die
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) steht. Der
Unterschied ist gemessen und nicht geschätzt: derselbe Sensor über denselben **188** Fällen bei
N=4 kostet **2,80 s je Fall** auf dem Host und **6,74 s je Fall** im CI-Job (beide Zahlen mit ihren
Kommandos in
[slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §1). Die Zahl zu raten hätte
den Sensor beschädigt, den der Slice gerade repariert hat.

**Warum das Offene erträglich ist.** Die Richtung ist **nicht** *still grün*, und das ist der
Unterschied, der über blockierend und nicht-blockierend entscheidet. Ein hängender Lauf liefert
**kein** Ergebnis — also auch kein falsches; die Kern-Auflage des Slice (*„eine parallele Fassung,
die still grün meldet, entwertete jede Zusage"*) ist nicht verletzt. Der Preis ist Wartezeit und
ein liegenbleibendes Lock-Verzeichnis.

**Was die Zusage heute trägt, und was nicht.** In der CI beendet GitHubs Job-Voreinstellung den Job
nach 360 Minuten und meldet ihn als Fehlschlag — **dokumentierte Voreinstellung, von diesem Repo
nicht gemessen**, und sie steht ausdrücklich nicht im Workflow (`grep -c 'timeout-minutes'` oben).
Lokal trägt die Zusage **niemand**: zwei hergestellte Hänger endeten nur, weil ein Mensch sie
beendet hat ([Verifikation](../../reviews/2026-08-27-slice-105-verify.md) §4.3). Getragen wird sie
damit von der Umgebung des Laufs, nicht vom Treiber — und eine Zusage, die nur außerhalb ihres
Trägers gilt, ist nach [`AGENTS.md`](../../../AGENTS.md) §3.6 keine.

**Kein lebendes Artefakt behauptet heute mehr, als der Code hält** — nachgelesen, damit dieser
Carveout eine Lücke registriert und keine Lüge. Die zwei Orte, die `make mutate` beschreiben, sind
gelesen, nicht gegriffen: `harness/README.md` §Nicht-Gate-Verify trägt genau **eine** Fundstelle
des Wortes (`grep -o 'hängt' harness/README.md | wc -l` → **1**), und sie meint etwas anderes —
*„die Modi, deren Urteil an einem geteilten Docker-Tag hängt"*; der Kopf von
`harness/tools/mutate.sh` zählt seine Befund-Wege auf und sagt *„Ein Worker, der stirbt, und ein
Fall, den die Warteschlange nie ausgibt, sind beide ein Befund"* — der Hänger steht dort nicht.
**Die Zählung ist kein Vollständigkeits-Beleg**, sondern der Fundort einer Lesung; die Aussage
trägt das Lesen beider Stellen. Die einzige Stelle mit der weiteren Zusage ist die DoD des
abgeschlossenen Slice — ein Zeitdokument, und deshalb bleibt ihr Haken aus, statt dass ihr Text
nachträglich enger gefasst wird.

## Auflösungs-Trigger

**Ein hergestellter Hänger endet ohne Signal von außen rot.** Konkret, ohne Rückfrage
entscheidbar, drei Bedingungen — alle drei müssen gelten:

1. `grep -c 'timeout' harness/tools/mutate.sh` liefert **> 0**, und die Fundstelle ist die
   Schranke, die das Warten auf die Worker begrenzt (nicht der Warteschlangen-Mutex).
2. Ein Lauf über einer Kopie mit einem `make`-Stub, der für genau einen Fall nicht zurückkehrt,
   endet **ohne** `timeout` von außen mit Exit ≠ 0 und benennt den Worker.
3. `grep -rln 'QUEUE_LOCK_TRIES' test/ | wc -l` liefert **≥ 1** — die zweite, ältere Schranke ist
   dann nicht mehr die einzige unbewachte
   ([slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) DoD 3).

**Der zweite Ausgang, und er ist gleichwertig:** zeigt die Bemessungs-Frage aus
[slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §3 Frage B, dass jede
tragfähige Schranke auf einem langsamen Runner regelmäßig ohne Befund auslöst, kippt Modul-7-Frage 2
auf *Nein*: dann ist die Zusage *„hängt"* nicht temporär offen, sondern dauerhaft nicht zu halten,
und der Carveout gehört in eine ADR übergeführt (`Status: Permanent — übergeführt in ADR-<NNNN>`).
Über diesen Ausgang entscheidet der **Architect**, nicht der Folge-Slice.

## Geltungs-Konfiguration

Keine Gate-Konfiguration trägt eine Ausnahme für diesen Carveout — es gibt nichts auszunehmen. Was
es gibt, sind drei Stellen, an denen der offene Posten sichtbar ist:

| Datei | Zeile/Section | Wert |
|---|---|---|
| [`slice-105-mutate-messen-dann-teilen.md`](../planning/done/slice-105-mutate-messen-dann-teilen.md) | §2 DoD (3) | Haken **nicht** gesetzt; §7 nennt `CO-003` als Träger |
| [`slice-117-lauf-ohne-ende-faerbt-rot.md`](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) | §2 DoD (1) und (3) | der Auflösungs-Trigger als Abnahme-Kriterium |
| [`slice-118-vorwaermlauf-endet-von-selbst.md`](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md) | §2 DoD (1) | der offene Teil — der Vorwärmlauf vor dem Fork |

## Verifikation (nach Auflösung)

- [ ] Die drei Trigger-Bedingungen oben sind erfüllt, jede mit ihrem Kommando gefahren.
- [ ] `make gates` grün ohne Ausnahme, `make mutate` ohne Befund.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`). <!-- d-check:ignore (done/ entsteht erst bei erster Carveout-Auflösung) -->
- [ ] Folge-Slice [slice-118](../planning/open/slice-118-vorwaermlauf-endet-von-selbst.md) geschlossen oder explizit dokumentiert (der Vorgänger [slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) ist geschlossen — §7 dort).
- [ ] Folge-Slice [slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) geschlossen oder explizit dokumentiert.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-27 | Angelegt (Closure zu slice-105; DoD (3) für einen der drei Ausfall-Wege ohne rot gesehenes Gegenbeispiel) | [slice-105](../planning/done/slice-105-mutate-messen-dann-teilen.md) §7 |
| 2026-08-27 | Audit in der Closure zu slice-117 — Modul-7-Übergang *weiterhin aktiv*: Bedingung 2 und 3 erfüllt und gefahren, Bedingung 1 misst ihren Gegenstand nicht (vier Fundstellen, alle Kommentar), offen bleibt der Vorwärmlauf vor dem Fork. Trigger-Änderung an den Architect übergeben | [slice-117](../planning/in-progress/slice-117-lauf-ohne-ende-faerbt-rot.md) §7 |
