# Slice slice-105: `make mutate` wird erst gemessen, dann geteilt — Zeit je Fall vor jeder Parallelität

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Sensor-Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — Messung und Teilung landen in **einem** Schnitt,
in dieser Reihenfolge; kein zweiter Slice muss mit ihm landen, damit die Aussage stimmt. **(2)
Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner eigenen DoD. **(3)
Auslöser reaktiv oder gewollt?** Reaktiv: eine **gemessene Laufzeit** ist der Anlass, keine neue
Fähigkeit. Der Treiber kann hinterher nichts, was er vorher nicht konnte — er sagt dieselbe Sache
schneller und sagt zusätzlich, wo seine Zeit liegt. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: Dogfood, nicht emittiert — gemessen, nicht behauptet.**
`grep -rln 'mutate' internal/emit/templates/ | wc -l` → **0**;
[`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) geht in kein Zielrepo. Was hier
entsteht, ändert am Adopter-Vertrag nichts.

**Bezug:**
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (`make mutate` **ist** der Feedback-Teil dieser Regel — er
prüft die Haltbarkeit der Zähne. Ein Sensor, der seine eigene Aussage verliert, nimmt jede darauf
gestützte Zusage mit),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse, gegen die die Auflage in §1 gerichtet ist: eine parallele Fassung, die einen Shard verliert
und **still grün** meldet, ist der behauptete Gate in Reinform — hier auf der Dogfood-Ebene,
weshalb die Anforderung als **Analogie** benannt und nicht als Bezug beansprucht wird),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (dieselbe Fall-Menge muss
dasselbe Verdikt liefern, gleich über wie viele Shards sie läuft),
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) (CI fährt
`make mutate` pro Push auf frischem Klon — die Laufzeit wird **je Push** bezahlt, und das ist der
Grund, aus dem sie überhaupt ein Gegenstand ist),
[`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks) (die
Sensor-Mechanik dieses Repos),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando und wandert mit ihrem Bestand),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(Verortung).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**`make mutate` sagt, wo seine Zeit liegt — je Fall und gruppiert nach Sensor —, und erst diese
Messung entscheidet, ob geteilt oder die Sensor-Stufe korrigiert wird.**

Der Umbau ist nicht der Lieferwert; die Aufschlüsselung ist es. Ohne sie ist jede Wahl zwischen
*Sharding* und *Tier-Korrektur* geraten.

### Was heute gemessen vorliegt — und was nicht

**Vorliegend, eigen erhoben** (jede Zahl mit ihrem Kommando, alle mitwandernd):

| Größe | Wert | Kommando |
|---|---|---|
| Fälle insgesamt | **157** | `ls -1 test/mutations/*.sh \| wc -l` |
| Fälle mit **eigenem** `# verify:`-Kopf | **8** | `grep -l '^# verify:' test/mutations/*.sh \| wc -l` |
| davon auf `full-smoke` | **2** | `grep -l '^# verify: full-smoke' test/mutations/*.sh \| wc -l` |
| Modi des Grün-Vorlaufs | **6** (`ci-lint`, `full-smoke`, `smoke`, `test`, `test-bats`, `test-go`) | `{ echo test; sed -n 's/^# verify: //p' test/mutations/*.sh; } \| LC_ALL=C sort -u` |
| Zeilen des Treibers | **566** | `wc -l < harness/tools/mutate.sh` |

**Die übrigen 149 Fälle bekommen ihren Sensor zur Laufzeit** aus dem `# expect:`-Kopf
(`narrow_sensor` in [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh): leer oder
mehrzeilig → `test`, `Test[A-Z]*` → `test-go`, sonst → `test-bats`). Die Abbildung ist **statisch
nachrechenbar**, und nachgerechnet ergibt sie die Fall-Verteilung: **115** `test-go` · **38**
`test-bats` · **2** `full-smoke` · **1** `smoke` · **1** `ci-lint` (Summe **157**; die Schleife über
`test/mutations/*.sh`, die je Fall den eigenen `# verify:`-Kopf nimmt und sonst `narrow_sensor`
nachbildet, steht in §3 als Ausgangspunkt der Messung).

**Nicht vorliegend: die Zeit.** `make mutate` braucht **1166,43** Sekunden für die **157** Fälle —
**fremdbelegt**, gemessen von der
[Verifikation zu slice-097](../../../reviews/2026-08-25-slice-097-verify.md) §1.1 mit
`/usr/bin/time -f 'MUTATE_SECONDS=%e' make mutate`, nicht von diesem Schnitt erhoben und ein
Maschinen- und Cache-Zustand, kein Erwartungswert. Was **fehlt**, ist die Aufschlüsselung: **Zeit je
Fall, gruppiert nach Sensor**.

**Fall-Verteilung und Zeit-Verteilung sind nicht dasselbe, und darin liegt der ganze Punkt.** Ein
`full-smoke`-Fall bootstrappt zwei tmp-Repos und fährt in jedem ein volles `make gates`; ein
`test-go`-Fall fährt einen Go-Testlauf. **2** von **157** Fällen können damit einen zweistelligen
Prozentsatz der Zeit tragen — oder einen vernachlässigbaren. Wer das nicht gemessen hat, weiß
nicht, ob Sharding (viele Fälle parallel) oder Tier-Korrektur (die teuren Fälle auf eine schmalere
Stufe ziehen) der größere Hebel ist, und baut die teurere Hälfte zuerst.

### Der Bauplan, soweit er gemessen ist

Aus [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) selbst gelesen:

- **Die Isolation existiert schon.** `prepare_isolation` kopiert den Baum per `tar` **außerhalb**
  des Repos (`--exclude=./.harness/state`), `require_isolated` bricht fail-closed ab, wenn `WORK`
  leer ist oder im Repo liegt. Eine zweite Kopie kostet dieselbe Mechanik, keine neue.
- **`run_case` ist unabhängig.** Sicherung → Mutation → Fingerabdruck-Prüfung, dass sie griff →
  `make $verify` → Abgleich gegen das Fehlschlag-Muster → `restore`. Zwischen zwei Fällen wandert
  kein Zustand; die Reihenfolge ist ohne Bedeutung.
- **Die Klippe ist `green_prerun`.** Er belegt: *der Sensor war grün, **bevor** mutiert wurde* —
  ohne ihn wäre ein rot gewordener Fall nicht von einem ohnehin roten Baum zu unterscheiden, und
  genau das sagt seine Abbruch-Meldung. Teilt man **nach Fall-Anzahl**, zahlt jeder Shard den
  Vorlauf für jeden Sensor, den seine Fälle brauchen — oder man glaubt ihn über Kopien hinweg,
  und dann ist die Aussage nur noch ungefähr richtig. **Nach Sensor teilen hält sie exakt:** ein
  Vorlauf je Shard, für genau dessen Sensor, in genau dessen Kopie. Die Zahl der Vorläufe bleibt
  dabei die heutige.
- **Docker ist die geteilte Ressource, und der Treiber weiß das bereits.** Sein `LOCK` in `main()`
  trägt genau diese Begründung: zwei Läufe *„bauen dieselben Docker-Image-Tags … und würden
  einander die Tags und den Build-Cache unter den Füßen wegziehen"*. Eine parallele Fassung, die
  den Bau **nicht einmal vor dem Fork** erledigt, tauscht Laufzeit gegen Tag-Rennen — der Lock ist
  die vorweggenommene Diagnose, nicht ein Hindernis.
- **Der Treiber verweigert schon heute das leere Set.** `main()` bricht ab, wenn `test/mutations/`
  leer ist: *„ein leeres Set ist kein gruener Lauf"*. Genau diese Eigenschaft muss auf **Shards**
  ausgedehnt werden — sonst entsteht sie neu, eine Ebene höher.

### Die Auflage, die nicht verhandelbar ist

**`make mutate` ist der Sensor der Sensoren.** Eine parallele Fassung, die still grün meldet, wäre
der schlimmste Fehler in diesem Repo: sie entwertete jede Zusage, die auf einem rot gesehenen
Gegenbeispiel ruht ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Daraus folgen zwei Bedingungen, und
sie stehen **vor** jeder Laufzeit-Aussage:

1. **Der zusammengeführte Bericht belegt, dass er jeden Fall gefahren hat** — die berichtete
   Fall-Zahl gegen `ls -1 test/mutations/*.sh | wc -l`, fail-closed bei Abweichung.
2. **Ein absichtlich kaputter Shard ist einmal rot gesehen worden**, bevor die parallele Fassung
   als Sensor gilt. Ein Shard, der abstürzt, hängt oder nichts meldet, muss den Gesamtlauf **rot**
   färben — nicht ihn verkürzen.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6). **Der erste ist die Messung, nicht der Umbau** — er
liegt vor den anderen beiden, und die Reihenfolge ist Teil der Zusage.

- [ ] **(1) Der Lauf schlüsselt seine Zeit auf: je Fall, gruppiert nach Sensor — und er nennt
      seinen Nenner.** Die Ausgabe trägt je Fall eine Dauer und je Sensor eine Summe samt Anteil an
      der Gesamtzeit; die Zahl der aufgeschlüsselten Fälle steht neben der Zahl der Fälle auf der
      Platte.
      **Rot:** der Lauf selbst — weicht die Summe der aufgeschlüsselten Fälle von
      `ls -1 test/mutations/*.sh | wc -l` ab, bricht er ab, statt eine unvollständige Bilanz
      auszugeben. Dazu ein `test/mutations/`-Fall, der die Aufschlüsselung um einen Fall kürzt.
- [ ] **(2) Geteilt wird nach Sensor, und der Grün-Vorlauf bleibt exakt.** Je Shard **ein** Vorlauf,
      für genau dessen Sensor, in genau dessen Kopie; das Docker-Bild entsteht **einmal vor** dem
      Fork. Kein Shard glaubt einer fremden Kopie ihr Grün.
      **Rot:** ein Shard, dessen Sensor in seiner eigenen Kopie **ohne** Mutation rot ist, bricht
      ab und sagt es — nachgestellt, indem in der Kopie eines Shards der Sensor vorab rot gemacht
      wird. Der Gesamtlauf darf das nicht als Befund eines Falls ausgeben.
- [ ] **(3) Der zusammengeführte Bericht ist vollständig oder rot — nie still grün.** Die berichtete
      Fall-Zahl steht gegen `ls -1 test/mutations/*.sh | wc -l`; ein Shard, der abstürzt, hängt oder
      nichts meldet, färbt den Gesamtlauf rot.
      **Rot:** ein absichtlich kaputter Shard, **einmal gefahren und rot gesehen** — die Bedingung
      aus §1, ohne die die parallele Fassung nicht als Sensor gilt. Dazu ein `test/mutations/`-Fall,
      der die Zusammenführung um einen Shard bringt.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/mutate.sh`](../../../../harness/tools/mutate.sh) | update | Zeitnahme je Fall und Bilanz je Sensor (DoD 1); danach die Teilung (DoD 2) und die Zusammenführung mit Vollständigkeits-Nachweis (DoD 3). **Der `LOCK` in `main()` wird nicht entfernt, sondern verstanden:** seine Begründung ist die geteilte Docker-Ressource, und die verschwindet durch Parallelität nicht — sie wird zur Bedingung *„Bild einmal vor dem Fork"* |
| [`Makefile`](../../../../Makefile) | update, **falls** Frage B so ausgeht | nur wenn die Shard-Zahl von außen gesetzt werden soll. Ein Ziel ohne Vorgabe muss weiter laufen und dasselbe Verdikt liefern ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) | update | der Treiber hat bereits eine bats-Ebene über seinen Funktionen (sie sourct die Datei); die neuen Funktionen — Zeitnahme, Shard-Bildung, Zusammenführung — gehören dorthin, nicht in einen zweiten Sensor |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | die drei Zähne aus DoD (1)–(3); Nummern im Anschluss an die höchste vergebene (`ls -1 test/mutations/*.sh \| wc -l` → **157**, beim Anlegen neu auszuzählen) |
| [`.github/workflows/ci.yml`](../../../../.github/workflows/ci.yml) | update, **falls** Frage C so ausgeht | die CI ruft ausschließlich `make`-Targets ([`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)); eine zweite Gate-Definition im Workflow wäre der Defekt, nicht die Lösung |
| [`harness/README.md`](../../../../harness/README.md) und [`AGENTS.md`](../../../../AGENTS.md) | update | beide beschreiben `make mutate` als **einen** Lauf gegen **eine** isolierte Kopie. Nach diesem Slice ist das falsch, und der Satz wird gezogen, nicht danebengestellt. **Der Hard-Rules-Block und der Adaptions-Block bleiben unberührt** — sie gehören dem Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8, [`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1); berührt ist §4, die Gate-Beschreibung |
| [`docs/plan/adr`](../../adr) | **unverändert** | die Änderung **hebt** keine Schwelle und senkt keine: dieselbe Fall-Menge, dasselbe Verdikt, andere Anordnung. Zeigt der Lauf, dass die Aussage des Grün-Vorlaufs schwächer wird, ist das eine **Senkung** und braucht ein ADR ([`AGENTS.md`](../../../../AGENTS.md) §3.5) — dann greift die Rückführung aus §4 |
| [`docs/plan/planning/in-progress/roadmap.md`](../in-progress/roadmap.md) | **unverändert** | wellenlose Arbeit wird dort nicht geführt ([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3) |

**Der Ausgangspunkt der Messung steht hier, nicht im Lauf.** Die statische Sensor-Zuordnung je Fall
ist heute schon berechenbar — je Fall der eigene `# verify:`-Kopf, sonst die Nachbildung von
`narrow_sensor` über dem `# expect:`-Kopf; das Ergebnis (115 · 38 · 2 · 1 · 1) steht in §1. Was
DoD (1) hinzufügt, ist die **Dauer**. Wer die Aufschlüsselung baut, prüft zuerst, ob seine
Laufzeit-Zuordnung mit dieser statischen übereinstimmt; tut sie es nicht, ist eine der beiden
falsch, und das ist ein Befund vor jeder Teilung.

**Offen, vor dem Code zu entscheiden:**

| # | Frage | Warum sie den Schnitt entscheidet |
|---|---|---|
| A | **Wird innerhalb eines Sensors weiter geteilt?** | Nach Sensor allein ergibt Shards von **115** und von **1** — die Teilung wäre exakt und **unausgewogen**; der größte Shard bestimmte die Laufzeit weiter. Eine zweite Ebene *innerhalb* eines Sensors kostet je Unter-Shard einen weiteren Vorlauf **desselben** Sensors — die Aussage bleibt exakt, der Preis ist zählbar. Ob er sich lohnt, sagt die Messung aus DoD (1) und **nur** sie |
| B | **Woher kommt die Shard-Zahl?** | Fest im Skript, aus einer `make`-Variablen oder aus der Kern-Zahl der Maschine. Eine Vorgabe von außen macht das Ergebnis von der Umgebung abhängig — dann muss DoD (3) auch für die Ein-Shard-Einstellung gelten, sonst gibt es eine Konfiguration, in der der Sensor nie vollständig geprüft wurde |
| C | **Fährt die CI dieselbe Aufteilung wie ein lokaler Lauf?** | Vier Runner mit je einem Kern verhalten sich anders als ein Host. Zwei Aufteilungen heißen zwei Verhalten und damit zwei Sensoren — [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) verlangt dasselbe Verdikt, nicht dieselbe Laufzeit; die Frage ist, wo die Grenze zwischen beidem gezogen wird |

## 4. Trigger

**Beginn (`open` → `next`): nichts blockiert die Messung.** DoD (1) fügt dem Treiber Zeitnahme und
Bilanz hinzu und ändert an seiner Anordnung nichts; sie ist ohne Vorbedingung lieferbar, und sie ist
der Grund, aus dem dieser Slice existiert.

### Die Reihenfolge-Bedingung — sie steht hier, nicht als Nebensatz

**DoD (2) und (3) beginnen erst, wenn der offene Nichtdeterminismus in `make full-smoke` einen
Ausgang hat.** Der Befund: `full-smoke` fällt in der CI **sporadisch** im hexagonalen C++-Modul,
während es im Grün-Vorlauf **desselben** Laufs grün ist. Er ist heute undiagnostiziert.

**Warum das die Reihenfolge bestimmt und nicht bloß unangenehm ist.** Parallelität ist die zweite
Quelle nichtdeterministischen Verhaltens in genau diesem Werkzeug. Zieht man sie hinein, bevor die
erste erklärt ist, ist der nächste sporadische Fehlschlag nicht mehr zuordenbar: er kann aus dem
C++-Modul kommen oder aus einem Shard-Rennen, und beide Hypothesen kosten dann je einen eigenen
Diagnose-Lauf über einem Sensor, der über **20** Minuten braucht. Ein Sensor, dessen Fehlschläge
niemand mehr zuordnen kann, wird abgeschaltet oder ignoriert — beides ist teurer als das Warten.

**Beobachtbar, ohne Rückfrage entscheidbar: der Befund trägt einen der vier Ausgänge** —
**diagnostiziert** (Ursache benannt, mit Sensor oder Grenze) · **als Umgebungs-Eigenschaft
ausgewiesen** (nicht der Baum, sondern der Runner; mit dem Beleg dafür) · **abgelehnt** mit Grund ·
**aufgeschoben** mit einem Auflösungs-Trigger, der ein beobachtbares Ereignis nennt. Dieselbe
Ausgangs-Menge, die [slice-101](slice-101-norm-postens-bekommen-einen-termin.md) für offene Postens
setzt — und aus demselben Grund: *„genannt"* ist keiner davon.

**Ist die Bedingung beim Erreichen von DoD (1) nicht erfüllt, greift `in-progress` → `next`:** der
Slice wird in Messung und Teilung zerschnitten, die Messung landet in `done/`, die Teilung wartet.
Das ist die reguläre Rückführung, kein Scheitern — und sie ist der Grund, warum die Messung als
**erster** DoD-Punkt steht und nicht als Vorarbeit im Fließtext.

**Die zweite Rückführung, `in-progress` → `open` (blockiert):** wenn sich zeigt, dass eine tragfähige
Teilung die Aussage des Grün-Vorlaufs **schwächen** müsste — etwa weil sie ihn über Kopien hinweg
glauben muss. Das ist eine Schwellen-**Senkung** und braucht ein ADR
([`AGENTS.md`](../../../../AGENTS.md) §3.5); der Slice wartet darauf, statt die Schwäche im Skript
zu verstecken.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos; die Aufschlüsselung liegt vor und ihr Nenner steht
neben `ls -1 test/mutations/*.sh | wc -l`; der absichtlich kaputte Shard ist **einmal rot gesehen**;
Frage A, B und C sind mit ihrer Begründung im Plan beantwortet; `make mutate` liefert über der
vollen Fall-Menge dasselbe Verdikt wie die serielle Fassung; die Beschreibungen in
[`harness/README.md`](../../../../harness/README.md) und [`AGENTS.md`](../../../../AGENTS.md) §4 sind
gezogen; Review konform (Modul 10); Verifikation bestätigt (Modul 11); `make gates` grün; `git mv`
nach `done/` als eigener Move-Commit; Closure-Notiz mit Steering-Loop-Eintrag in einer der drei
Formen (geschärfte Regel · neuer Sensor · benannte Spec-Lücke).

**Ausdrücklich nicht Teil des Closure-Triggers: eine Laufzeit-Schwelle.** Eine Zahl als Kriterium
wäre auf einem geteilten Runner rot ohne Befund und grün ohne Deckung — dieselbe Begründung, aus
der `make hook-overhead` eine Messung ist und kein Gate
([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Was
zählt, ist die **Aufschlüsselung** und die **Vollständigkeit**, nicht die erreichte Sekundenzahl.

## 6. Risiken und offene Punkte

- **Der teuerste Fehler ist eine parallele Fassung, die still grün meldet.** Sie entwertete jede
  Zusage, die auf einem rot gesehenen Gegenbeispiel ruht. Deshalb steht der absichtlich kaputte
  Shard in DoD (3) und nicht in einer Risiko-Zeile: er ist Abnahme-Bedingung, kein Vorsatz.
- **Teilung nach Sensor ist exakt, aber unausgewogen.** **115** von **157** Fällen fahren `test-go`;
  ein Shard mit 115 Fällen bestimmt die Laufzeit weiter. Frage A hängt daran, und die Antwort darf
  nicht vor der Messung fallen — sonst baut der Slice die zweite Ebene für einen Hebel, den es
  vielleicht nicht gibt.
- **Der Grün-Vorlauf kann leise ungenau werden.** Sobald ein Shard das Grün eines anderen
  übernimmt, sagt der Sensor nicht mehr, was seine Abbruch-Meldung behauptet. Das ist keine
  Optimierung, sondern eine Senkung — §4 führt sie als Blocker, nicht als Abwägung.
- **Zwei Nichtdeterminismus-Quellen in einem Werkzeug sind nicht additiv, sondern multiplikativ in
  der Diagnose.** Das ist der ganze Inhalt der Reihenfolge-Bedingung; sie hier zu wiederholen wäre
  eine zweite Fassung, die driftet — sie steht in §4.
- **Der Treiber wird länger, und seine Sensor-Ebene ist bats.** `wc -l < harness/tools/mutate.sh` →
  **566** heute. Wächst er deutlich, ohne dass
  [`test/mutate-driver.bats`](../../../../test/mutate-driver.bats) mitwächst, entsteht genau die
  Klasse, gegen die dieses Werkzeug gerichtet ist: ein Wächter ohne Wächter.
- **Die Zeit-Aufschlüsselung ist eine Messung, kein Sensor.** Sie prüft nichts und färbt nichts rot
  — außer ihrer eigenen Vollständigkeit (DoD 1). Ein Gate über Sekundenwerten stünde auf geteilter
  Hardware, und das ist keine Lücke dieses Schnitts, sondern die Grenze der Ebene.

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

### Sub-Area: Mutations-Treiber (`harness/tools/` + seine bats-Ebene)

Eine Sub-Area, kein zweiter Block: ein Skript, sein Sensor und sein Fall-Verzeichnis — ein
Gegenstand, eine Frage. Die berührten `make`-Ziele und die CI-Zeile sind Aufrufer, keine eigene
Sub-Area.

- **Modus:** GF. Der Treiber ist in diesem Repo entstanden (slice-026) und seither gegen den Kurs
  geführt; es gibt keinen vorgefundenen Bestand, gegen den zu inventarisieren wäre.
- **Konventionen-Dichte:** hoch. [`AGENTS.md`](../../../../AGENTS.md) §3.6 definiert, wofür der
  Treiber da ist, §3.5 bindet die Frage *Anhebung oder Senkung*,
  [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) bindet
  seinen Auslöser, und
  [`MR-002`](../../../../harness/conventions.md#mr-002--gate-nachweis-mechanik-und-claude-hooks)
  seine Einbettung in die Sensor-Mechanik.
- **Phase-Reife:** Phase 5 (Betrieb). Der Treiber läuft pro Push, über **157** Fällen, mit
  Isolation, Lock und fünf fail-closed Bedingungen. Was fehlt, ist nicht Reife, sondern Sichtbarkeit
  seiner eigenen Kosten.
- **Evidenz-/Diskrepanz-Risiko:** niedrig für die Struktur (aus dem Skript gelesen, §1), **offen für
  die Zeit** — und das ist der Gegenstand. Ein zweites Risiko liegt daneben: die statische
  Sensor-Zuordnung (§1) und die Laufzeit-Zuordnung müssen übereinstimmen; tun sie es nicht, ist die
  Diskrepanz ein Befund vor der Teilung, keine Randnotiz.
- **Reconciliation-Aufwand:** gering für DoD (1), **nicht abschätzbar vor der Messung** für DoD (2)
  und (3) — genau darum steht die Messung zuerst und die Rückführung `in-progress` → `next` in §4
  bereit. Graduation-Trigger entfällt; die Sub-Area ist bereits GF.
