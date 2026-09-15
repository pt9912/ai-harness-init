# Verifikation `slice-215-commit-waechter-sieht-auch-die-ungetippten-commits` — drei Liefer-Punkte tragen, ein Zellen-Überclaim in der Reichweiten-Tabelle

**Rolle:** Verifier · **Datum:** 2026-09-15 · **Geprüfter Stand:** `f52e2e47` (`git status
--porcelain` leer) · **Prüfgegenstand:** §2 **Definition of Done gegen den tatsächlichen Stand**,
dazu §1, §3, §5, §6, §8 — **nicht** der Plan gegen sich selbst (das war der Reviewer) und **nicht**
die Closure (Planner, [`AGENTS.md`](../../AGENTS.md) §3.10) · **Modul 11** §Bewusstes Brechen.

**Prüfkette am Stand** — jeder Schritt ein eigener Kontext, kein Self-Verify:

| Schritt | Commit | Rolle |
|---|---|---|
| Umsetzung | `7ee36939` · `2557901e` · `9ab67fa0` | Implementer |
| Review (0 HIGH · 2 MEDIUM · 1 LOW · 2 INFO) | `670ef6f1` | Reviewer |
| Review-Nachzug F-2 (Kopplung als Mengen-Gleichheit) | `8a0538d3` | Implementer |
| Architect-Antwort auf §3/§4 (ADR-0053, `Proposed`) + §3-Zelle gezogen | `0f2409cc`, `90760f63` | Architect |
| die Werkzeug-Zeile der Reichweiten-Tabelle | `f52e2e47` | Implementer |

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an **keinem** der
sechs Commits, an keiner der acht Dateien des Umsetzungs-Diffs, an keinem Review-Befund, an keiner
ADR-0053-Zeile und an keiner Zelle der Reichweiten-Tabelle etwas verfasst. Er hat gelesen, Sensoren
gefahren und nichts am Gegenstand geändert.

**Offengelegt — was dieser Lauf am Baum getan hat.** Der Träger ist **nicht** in diesem Klon scharf
gestellt worden: `core.hooksPath` steht hier auf *nicht gesetzt*
(`git config --get core.hooksPath` → kein Treffer, EXIT 1), wie die Weisung es verlangt. Jede
Aktivierung ist an **`/tmp`-Kopien** und an einem echten **Wegwerf-Klon** gefahren worden
(`/tmp/verify215`, `/tmp/klon215b`, `/tmp/tooth215`, `/tmp/mut_341…`, `/tmp/mut_342…`), der
Arbeitsbaum war vor und nach jeder Messung leer. Ein voller `make mutate` wurde gestartet und nach
**32 von 328** Fällen abgebrochen (Rest-Unsicherheit §9); sein Lock ist mit dem Lauf verschwunden,
der Baum unverändert. Der Klon trug während des Laufs den Commit `f52e2e47` eines **parallelen**
Implementer-Laufs (die Werkzeug-Zeile) — er ist im geprüften Stand enthalten, weil `make gates` ihn
deckt.

**Ausgenommener Gegenstand — nicht geprüft, mit Grund.** Die **Closure** (§7, Register, §6-Ausgänge,
DoD-Häkchen, `git mv`) ist Planner-Arbeit. Der Kandidat `slice-werkzeug-commits-tragen-eine-kennung`
(ADR-0053 Festlegung 4) ist **nicht geschnitten** und nicht Gegenstand. `ADR-0052`/`ADR-0053` als
Architect-Artefakte (`Proposed`) ebenso wenig.

**Zitier-Form:** Kennung statt Adresse für alles, was der Prozess bewegt; der geprüfte Stand wird
über seinen **Commit** festgehalten, nicht über einen Lifecycle-Pfad.

---

## Ergebnis in einer Tabelle

| §2-Punkt | Verdikt |
|---|---|
| **DoD (1)** — Träger entschieden, jeder gemessenen Commit-Klasse ein Träger zugeordnet, frischer Klon entschieden | **erfüllt** (§3) |
| **DoD (2)** — Träger verdrahtet und **rot gesehen** an einer Klasse, die der PreToolUse strukturell nicht erreicht; Zahn trifft die Stelle des Aufrufers | **erfüllt** (§4) |
| **DoD (3)** — neue Reichweite **neben** der alten, was draußen bleibt benannt | **erfüllt** (§5) — mit dem Zellen-Befund **V-1** (§6) |
| `make gates` grün | **erfüllt** (§7) |
| `make mutate` ohne Befund | **erfüllt für den Fall dieses Slice** (Zahn einzeln, §4.2); der volle Lauf nicht abgeschlossen (§9) |
| Review nach Modul 10, Report unter `docs/reviews/` | **erfüllt** (§7) |
| Doku-Update (öffentlicher Vertrag berührt) | **erfüllt** (§5) |
| Closure-Notiz mit Lerneintrag | **nicht fällig** — Planner |
| Beobachtungs-Register fortgeschrieben | **nicht fällig** — Planner |
| Jedes Risiko aus §6 mit Ausgang | **nicht fällig** — Planner; §6 führt alle vier als *offen* |
| Die drei Paarungen | **nicht fällig** — Welle-Closure (Modul 6) |

**DoD-Verletzung: keine.** Die drei slice-eigenen Liefer-Punkte tragen am Stand, die
Prozess-Punkte tragen oder sind noch nicht fällig.

**Befund eigener Klasse (Verifier, keine DoD-Verletzung):** **eine** Zelle der Reichweiten-Tabelle
ist in ihrer absoluten Form durch den Bestand widerlegt — *„heute trägt keine eine"* (§6, V-1). Der
Befund gehört dem Planner/Implementer, er verschiebt keine der drei Abnahmen.

---

## 1. Eingangs-Kontext und Anlass der Nachmessung

Der Slice verschiebt den **Träger** einer bestehenden Zusage
([`AGENTS.md`](../../AGENTS.md) §5, [`harness/README.md`](../../harness/README.md) §Traceability):
von einem Hook am **Agenten**-Kanal auf einen `git`-eigenen Hook am **Commit**, daneben bleibt der
Agenten-Kanal. Drei DoD-Punkte, jeder mit einem eigenen Rot-Kriterium, machen den Kern dieses Slice
aus — sie sind die Klasse, die nur die Verifikation fängt (Modul 11: *DoD-Verletzung ist keine
Review-Kategorie*).

---

## 2. Die gemessenen Commit-Klassen und ihre Träger (Eingang zu DoD (1))

Bevor die DoD-Punkte beurteilt werden, die Bezugsmenge: **welche** Klassen sind gemessen, und
welchen Träger ordnet die Tabelle jeder zu? Gemessen sind die Klassen in §1 (zwei Lücken) und in
ADR-0053 §Kontext (drei Klassen am Agenten-Kanal unerreichbar); die Tabelle in
[`harness/README.md`](../../harness/README.md) §Traceability führt sieben Zeilen:

| Commit-Klasse | PreToolUse-Kanal | `commit-msg`-Hook | Träger vorhanden? |
|---|---|---|---|
| `-F <datei>`, getippt | erreicht | erreicht | **ja** (beide) |
| `-m …`, getippt (ohne Konventions-Form) | nicht garantiert erreicht | erreicht | **ja** (Hook) |
| aus einem Repo-Werkzeug (`make slice-mv`, `archive-welle`) | strukturell nicht erreicht | erreicht *sobald Kennung* | **ja** (Hook) |
| außerhalb eines Claude-Code-Laufs | nicht erreicht | erreicht | **ja** (Hook) |
| Klon ohne `make hooks-install` | erreicht (`-F` in einem Agenten-Lauf) | nicht erreicht | **ja** (Kanal) |
| `--no-verify` | erreicht | umgangen | **ja** (Kanal) |
| `--amend` | erreicht (`-F`-Form) | erreicht (`$1`) | **ja** (beide) |

**Keine Klasse ohne Träger.** Jede der sieben hat mindestens einen, und die zwei Kanäle sind
ausdrücklich **nicht** austauschbar (ADR-0053 Festlegung 2: der eine liegt *vor*, der andere *an*
der Ausführung; im Normalpfad blockt genau einer). Das ist die Bezugsmenge, gegen die DoD (1) liest.

---

## 3. DoD (1) — der Träger ist entschieden, jede Klasse hat einen, der frische Klon ist entschieden

**Erfüllt.**

**Die Entscheidung steht und ist nicht die des ausführenden Kontexts.** ADR-0053
(`0f2409cc`, `Proposed`) trägt vier Festlegungen; die für DoD (1) tragende ist Festlegung 1:

> Der Träger der Klasse *Commit aus einem Repo-Werkzeug* — und der Klasse *Commit außerhalb eines
> Agenten-Laufs* — ist der git-eigene `commit-msg`-Hook. Er liegt versioniert unter
> `.githooks/commit-msg`, seine Prüfung unter `harness/tools/commit-msg-traceability.sh`, seine
> Aktivierung ist `git config core.hooksPath .githooks` über `make hooks-install`.

Die §3-Zelle des Plans ist gezogen (§3 stand bis `0f2409cc` auf *„offen"*):

```sh
git show 0f2409cc -- docs/plan/planning/in-progress/slice-215-…md | grep -c '^[-+].*ADR-0053'   # 2
```

Damit ist der §4-Start-Trigger beantwortet — **als ADR**, die schwerere der zwei von §4 zugelassenen
Formen. Der Status `Proposed` ist der Normalzustand bis zum Accept-Übergang; er ist
Architect/Reviewer-Arbeit nach [`ADR-0040`](../../docs/plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
und kein DoD-Punkt dieses Slice.

**Der frische Klon, beide Hälften — am echten `git clone` gemessen, nicht am `cp -a`:**

```sh
git clone -q --no-hardlinks <repo> /tmp/klon215b && cd /tmp/klon215b
git config --get core.hooksPath                              # kein Treffer — die Option fehlt
ls -l .githooks/commit-msg | awk '{print $1}'                # -rwxrwxr-x  (Index-Modus 100755)
git commit -q --allow-empty -m 'ohne kennung im frischen klon'   # EXIT 0 — der Träger feuert NICHT
make hooks-install
git commit -q --allow-empty -m 'ohne kennung im frischen klon'
# commit-msg-traceability: keine Traceability-Kennung in der Commit-Message (AGENTS.md §5):
#             ohne kennung im frischen klon                            EXIT 1
```

**Der Träger reist, seine Aktivierung nicht** — genau wie ADR-0053 Festlegung 3 und
[`harness/README.md`](../../harness/README.md) §Traceability (Zeile 107 und der Absatz *„Wie der
Träger auf einen frischen Klon kommt"*) es sagen. Das Rot-Kriterium von DoD (1) lautet *„eine
Trägerschaft, die der frische Klon nicht herstellt"* — und der Klon **stellt sie her**: die Datei
liegt im Index mit `100755`, und `make hooks-install` ist der eine Schritt dazwischen
(`git`-Abhängigkeit, [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
Was der Klon **allein** nicht herstellt, ist die *Aktivierung*; das ist die bewusst gewählte
Eigenschaft (`core.hooksPath` ist lokale Konfiguration) und ist an beiden Enden benannt — kein
`.git/hooks/`-Pfad, den nur der lokale Baum kennt.

```sh
git ls-files -s .githooks/commit-msg      # 100755 … .githooks/commit-msg
```

---

## 4. DoD (2) — verdrahtet, rot gesehen an der strukturell unerreichten Klasse, Zahn am Aufrufer

**Erfüllt.**

### 4.1 Verdrahtung

Die Verdrahtung liegt im Repo, nicht in einer lokalen Konfiguration: `.githooks/commit-msg`
(`100755`, versioniert) · `harness/tools/commit-msg-traceability.sh` (bash+coreutils, kein Docker)
· `make hooks-install` (setzt `core.hooksPath`, mit `-x`-Probe gegen einen Hook ohne Ausführrecht)
· die Zeile in [`harness/README.md`](../../harness/README.md) §Traceability. **In diesem Klon ist
der Träger nicht aktiv** (`core.hooksPath` ungesetzt) — das ist die Weisung, nicht der Mangel: scharf
gestellt reißt er die Läufe der anderen Rollen (§3.6-Beleg im Review, `make slice-mv` bricht **nach**
dem `git mv`). Die Wirksamkeit ist darum an Kopien gefahren, jede Klasse einzeln.

### 4.2 Der Rot-Beleg, an der Klasse, die der PreToolUse strukturell nicht erreicht

Ein Commit **innerhalb** eines Skripts, ohne `-F` in der Aufrufzeile — dieselbe Form, die
`harness/tools/slice-mv.sh:234`/`:268` fährt:

```sh
bash /tmp/inner215.sh      # enthält: git commit -q --allow-empty -m "slice-mv: slice-mutations-…md  in-progress/ -> done/ (reiner Move)"
# commit-msg-traceability: keine Traceability-Kennung in der Commit-Message (AGENTS.md §5):
#             slice-mv: slice-mutations-…md  in-progress/ -> done/ (reiner Move)   EXIT 1
```

Und die Gegenprobe **derselben Klasse** mit Ziffern-Kennung — grün:

```sh
git commit -q --allow-empty -m "slice-mv: slice-215-commit-waechter.md  next/ -> in-progress/ (reiner Move)"   # EXIT 0
```

Dazu die vier Beträge des README-Blocks, **alle reproduziert** (Klon mit gesetztem `core.hooksPath`):

| Aufruf | Exit | wie dokumentiert |
|---|---|---|
| `git commit --allow-empty -m 'Betreff ohne jede Kennung'` | 1 | ja |
| `git commit --allow-empty -m 'Bezug: ADR-0004 und sonst nichts'` | 0 | ja |
| `git commit --allow-empty -m 'Merge branch main into feature'` | 0 | ja (Ausnahme) |
| `git commit --allow-empty --no-verify -m 'Betreff ohne jede Kennung'` | 0 | ja (Umgehung) |

**Beide Läufe (rot ohne Kennung, grün mit) stehen im Umsetzungs-Commit** `7ee36939` — der
Commit-Body trägt genau dieses Paar plus den Werkzeug-Klassen-Lauf
(`bash <nachbau>.sh` → `Exit 1 — die Klasse, die der PreToolUse-Kanal strukturell nicht sieht`).

### 4.3 Der Zahn `340` trifft die Stelle, die der Aufrufer benutzt

**Der Zahn mutiert die Datei, die der Aufrufer benutzt** — `.githooks/commit-msg` reicht die
Message-Datei per `exec bash "$here/../harness/tools/commit-msg-traceability.sh"` an genau diese
Datei weiter. Der Fall patcht deren **ausführende** Zeile (`patterns=` → `".*"`), nicht Prosa:

```sh
# /tmp/tooth215 — genauer sed des Falls 340
bash test/mutations/340-commit-msg-traeger-ohne-kennungs-pruefung.sh
grep -n '^patterns=' harness/tools/commit-msg-traceability.sh     # 58:patterns=".*"
docker run --rm --network none -v /tmp/tooth215:/code:ro -w /code <BATS_IMAGE> test/commit-msg-hook.bats
# not ok 1 traeger: Message ohne Kennung wird abgelehnt
# not ok 5 traeger: ein Betreff 'Merge' ohne Leerzeichen wird abgelehnt
# not ok 7 traeger: Kennung nur in einer Kommentarzeile genuegt nicht
# not ok 10 kopplung: Traeger und Config tragen dieselbe Muster-Menge
# not ok 13 kopplung: eine Kennung ausserhalb der Config-Liste wird abgelehnt     EXIT 1
```

**Die behauptete Ursache trägt.** Der `# expect:`-Name des Falls
(`traeger: Message ohne Kennung wird abgelehnt`) steht in der Fehlschlag-Ausgabe, und die
`failure_form test-bats` (`not ok [0-9]+`) trifft (5 Treffer) — `make mutate` würde für diesen Fall
**keinen** BEFUND melden. Die unveränderte Kopie derselben Datei ist grün: `1..13`, alle `ok`,
EXIT 0. **Der Zahn misst nicht sich selbst:** der bats-Fall fährt `bash "$HOOK"` über
`.githooks/commit-msg`, nicht das Skript direkt.

### 4.4 Der F-2-Nachzug: die Kopplung hält jetzt **beide** Richtungen, je mit eigenem Zahn

Der Review hatte gemessen, dass nur **eine** Richtung hielt (F-2 MEDIUM). Der Nachzug `8a0538d3`
ersetzt den Beleg-je-Config-Muster durch eine **Mengen-Gleichheit** (`test/commit-msg-hook.bats`
Fall 10) und stellt jeder Richtung einen eigenen Zahn daneben. Beide einzeln gefahren:

```sh
# 341 — die Config verliert ein Muster
sed -i "/^    - 'MR-/d" .d-check.yml
# not ok 10 kopplung: Traeger und Config tragen dieselbe Muster-Menge   EXIT 1
# 342 — der Träger gewinnt ein Muster dazu (BEO-[A-Z]+)
sed -i 's@slice-\[0-9\]+)@slice-[0-9]+|BEO-[A-Z]+)@' harness/tools/commit-msg-traceability.sh
# not ok 10 kopplung: Traeger und Config tragen dieselbe Muster-Menge   EXIT 1
```

Beide Nennungen stehen in der Fehlschlag-Ausgabe (`die Muster-Mengen weichen ab:`) — der jeweilige
`# expect:`-Name trifft. **F-2 ist damit gehalten, und die Zusage „in beide Richtungen" ist jetzt
durch je einen Rot-Beleg gedeckt.**

---

## 5. DoD (3) — die neue Reichweite neben der alten, was draußen bleibt benannt

**Erfüllt.**

- **Neben der alten:** die Tabelle
  ([`harness/README.md`](../../harness/README.md) §Traceability) trägt **zwei Spalten** —
  `pretooluse-commit-msg-guard.sh` und `.githooks/commit-msg` — je Commit-Klasse (§2), und **beide**
  Grenzen des git-Hooks stehen in ihr (`core.hooksPath` reist nicht · `--no-verify` umgeht).
- **Was draußen bleibt, ist benannt:** die Klasse *ohne `make hooks-install`* (Zeile 107), die
  Umgehung `--no-verify` (Zeile 108), und ein eigener Absatz *„Der Index ist kein Gegenstand dieser
  Tabelle"* (Zeilen 111-114) mit der Abhilfe `git commit --only`.
- **Die Konventions-Abhängigkeit aus §1 ist entschieden** (Zeilen 148-153): *„entfällt für eine
  Hälfte"* — der `commit-msg`-Hook braucht die Aufrufform nicht, der PreToolUse-Zusatz läuft in
  dieser Lücke weiter, mit dem Register-Eintrag `waechter-abdeckung-haengt-an-uninstruierter-konvention`
  als Adresse.

**Das Rot-Kriterium der DoD (3)** — *„eine Zusage im Text, für die der Lauf kein Gegenbeispiel
herstellen kann"* — **greift für keine Zeile**: die `erreicht`-Zellen sind über Rot/Grün-Paare
belegt (§4.2 und §8), die `nicht erreicht`/`umgangen`-Zellen über den Bestand (`core.hooksPath`
ungesetzt ⇒ der Hook feuert nicht; `--no-verify` ⇒ EXIT 0; `--amend` ⇒ der Hook feuert). **Eine**
Zelle trägt daneben eine **widerlegte** Teil-Aussage — sie ist Befund **V-1** (§6), nicht das
Rot-Kriterium.

---

## 6. Befunde eigener Klasse (Verifier, keine DoD-Verletzung)

### V-1 — die Zelle der Werkzeug-Klasse ist in ihrer absoluten Form durch den Bestand widerlegt

Die neue Zeile (von `f52e2e47`) sagt über die Werkzeug-Klasse:

> erreicht, sobald die Werkzeug-Message eine Kennung trägt — **heute trägt keine eine**, und der
> Commit bricht darum am Träger, statt zu greifen; Adresse für die Behebung:
> `slice-werkzeug-commits-tragen-eine-kennung`

**Gemessen trägt die Mehrheit der Werkzeug-Messages sehr wohl eine Kennung** — die Message führt den
Dateinamen, und der trägt bei jedem vor [`MR-057`](../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
angelegten Slice die Ziffern-Form:

```sh
RE='ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
git log --format='%s' | grep -c '^slice-mv:'                                 # 411
git log --format='%s' | grep '^slice-mv:' | grep -vcE "$RE"                  #  44
git log --format='%s' | grep '^slice-mv:' | head -3
# slice-mv: Verweise auf slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md nach in-progress/ nachgezogen …
# slice-mv: slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md  next/ -> in-progress/ (reiner Move)
# slice-mv: Verweise auf slice-226-implementer-anweisungssatz-zieht-nach.md nach done/ nachgezogen …
```

367 von 411 tragen eine Ziffern-Kennung, und die drei jüngsten **alle** — der Träger läßt sie darum
durch (an der Message-Form gemessen, §4.2: `slice-215-…` → EXIT 0). Der Satz *„heute trägt keine
eine"* ist in beiden Lesarten zu stark: als Aussage über die **resultierende Message** ist er falsch,
als Aussage über die **vier Message-Formen** (`slice-mv.sh:234`/`:268`,
`internal/archive/anwenden.go:107`/`:175`) müßte er *„die Formen tragen keine eigene Kennung"*
heißen — die ADR formuliert dieselbe Sache genau so und vorsichtiger
(*„Der Auslöser ist die Kennungs-Form, nicht das Werkzeug: die Message trägt den Dateinamen"*).

**Was es ist:** ein **Überclaim in der lebenden DoD-(3)-Zelle** — die Klasse, die der Slice in §8
selbst als sein Evidenz-Risiko führt (`zusage-nennt-sensor-der-form-nicht-sieht`, `12×` zum
Plan-Zeitpunkt, inzwischen `15×`). **Was es nicht ist:** kein DoD-Verletzung — DoD (3) verlangt die
Tabelle, die benannten Grenzen und die Entscheidung zur Konventions-Abhängigkeit; alle drei stehen.
Der Überclaim betrifft nur die Begründung **einer** Zelle. **Zu heilen beim Implementer/Planner**,
nicht hier.

---

## 7. `make gates`, der volle Lauf

```text
$ make gates
baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
d-check: 1430 Datei(en) geprüft, 0 Befund(e)
… 1..294 … (294 ok, 0 not ok)
comment-claims: 61 Datei(en) geprueft, 0 Befund(e)
span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
EXIT 0
```

**EXIT 0**, entscheidende Zeile der Schluss-Sensor `span-check`. Über **`f52e2e47`** gefahren, den
geprüften Stand (Log-Zeitstempel 10:49:25, Commit-Zeit 10:40:45); `git status --porcelain` danach
leer. Die Zahl `294` trägt die 13 Fälle des Hook-Files (Review-Stand: 293 über 11 Fälle — der
F-2-Nachzug hat zwei Fälle ergänzt). **Kein Erwartungswert.**

**Review nach Modul 10:** Report
`2026-09-15-slice-215-commit-waechter-sieht-auch-die-ungetippten-commits.md` liegt vor, Verdikt
*merge-blockierend: ja* (2 MEDIUM). Von den fünf Findings ist **F-2** am Gegenstand gezogen
(§4.4), **F-3/F-4** sind Doku-Zellen in derselben Reichweiten-Tabelle (mit `8a0538d3`/`f52e2e47`
nachgezogen), **F-1** hat seine Architektur-Antwort in ADR-0053 + der gezogenen §3-Zelle, und
**F-5** war ausdrücklich *„für den Verifier"* — er ist mit DoD (1) und (2) hier beantwortet
(*verdrahtet* heißt: die Verdrahtung liegt im Repo; die Aktivierung ist der eine benannte Schritt).

---

## 8. Modul 11 §Bewusstes Brechen — die Sensoren, die der Slice benennt

Der Slice beruft sich auf **drei** Sensoren. **Zwei davon hat dieser Lauf selbst gefahren** (den
Zahn und den Hook), den dritten (den Kopplungs-bats) über die Mengen-Gleichheit an beiden
Richtungen (§4.4).

| Sensor | Was er behauptet | Rot gesehen? | Meldung trägt die Ursache? |
|---|---|---|---|
| `.githooks/commit-msg` (der Träger selbst) | lehnt eine Message ohne Kennung ab, läßt eine mit durch, Merge/Revert ausgenommen, fail-closed ohne Datei | **ja**, an der Werkzeug-Klasse (§4.2) und an vier README-Beträgen | ja — `keine Traceability-Kennung …` mit dem Betreff |
| `test/commit-msg-hook.bats` (Kopplung) | Träger und Config tragen dieselbe Muster-Menge, in **beide** Richtungen | **ja**, je Richtung ein Rot-Beleg (§4.4) | ja — `die Muster-Mengen weichen ab` + beide Mengen |
| `test/mutations/340` (der Zahn) | entwaffnet die Kennungs-Prüfung; der bats-Fall fällt | **ja** — `not ok 1 traeger: Message ohne Kennung wird abgelehnt` (§4.3) | ja — der `# expect:`-Name steht in der Ausgabe, `failure_form test-bats` trifft |

**Der Zahn trifft die Stelle, die der Aufrufer benutzt** (§4.3): gepatcht ist die ausführende
`patterns=`-Zeile des Skripts, das `.githooks/commit-msg` per `exec` aufruft, und der bats-Fall fährt
den Aufruf **über den Hook**. Ein Zahn, der die Verdrahtung selbst nachbaut, wäre hier nicht
möglich: der Fall berührt keine Zeile der Verdrahtung.

---

## 9. Die Grenzen, die der Umsetzer benannt hat — geprüft

| Grenze (so behauptet) | Messung | Trägt? |
|---|---|---|
| kein Aktivierungsschritt ohne `make hooks-install` | frischer Klon ohne den Schritt: kennungsloser `-m`-Commit **EXIT 0**; danach **EXIT 1** (§3) | **ja** |
| `--no-verify` umgeht den Träger | `git commit --allow-empty --no-verify -m 'Betreff ohne jede Kennung'` → **EXIT 0** (§4.2) | **ja** |
| beide Träger prüfen die **Anwesenheit**, nie die **Wahrheit** einer Kennung | git-Hook: `Bezug: ADR-9999` → **EXIT 0**; `Bezug: MR-999 und slice-99999` → **EXIT 0**. Agenten-Kanal: `make commit-msg-check MSG=<ADR-9999>` → **EXIT 0** | **ja** |
| der **Index** sieht keiner (die `--amend`-Mitreise) | `git add fremd.txt; git commit --amend --no-edit` → der Commit trägt `fremd.txt` mit (`git show --stat HEAD`) | **ja** |
| der Träger feuert auch bei `--amend`/`--no-edit` | `git commit --amend --no-edit` auf kennungsloser Message → **EXIT 1** (§4.3-Lauf, Zeile 109 der Tabelle) | **ja** |

---

## 10. §1-Abgrenzung am Diff

Gegen die fünf Ausschlüsse aus §1, am Diff der Kette `7ee36939^..HEAD` (beide Richtungen):

```sh
git diff 7ee36939^..HEAD --name-only
```

- **`.claude/agents/*.md`, `.harness/skills/reviewer.md`** — **kein Treffer.** Die Konvention ist
  nicht geschrieben ([`ADR-0028`](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
  fremdes Eigentum).
- **`slice-121`** — **kein Treffer.** Die *Wahrheit* einer Kennung ist nicht berührt.
- **Die emittierte Ebene** (`internal/emit/…`) — **kein Treffer.**
- **`harness/tools/slice-mv.sh`, `internal/archive/anwenden.go`** — **kein Treffer.** Die
  Werkzeug-Formen sind als eigener Kandidat benannt (`slice-werkzeug-commits-tragen-eine-kennung`,
  ADR-0053 Festlegung 4) und **nicht geschnitten**:

  ```sh
  ls docs/plan/planning/*/slice-werkzeug-commits-tragen-eine-kennung.md   # kein Treffer
  ```

**Kein Zug an einem fremden Gegenstand.** Die zwei Commit-Formen der Werkzeuge brechen den scharf
gestellten Träger weiterhin **nach** dem `git mv` — das ist der benannte, noch offene Arm, und er
ist im Klon dieses Laufs **nicht** scharf gestellt (Begründung §4.1).

---

## 11. Plan-vs-Artefakt-Diff (beide Richtungen)

**Gebaut wie geplant** — jede §3-Zeile ist am Stand auffindbar:

| §3-Zeile | gebaut | Beleg |
|---|---|---|
| `docs/plan/adr/` **neu** — ADR-0053 (`Proposed`) | ja | `0f2409cc`, Index-Zeile in `docs/plan/adr/README.md` |
| `harness/tools/` **oder** `.githooks/` **neu** | ja, **beides** | `.githooks/commit-msg` + `harness/tools/commit-msg-traceability.sh` |
| `Makefile` **update** | ja | `hooks-install`, `shell-lint` + `comment-claims` um die neue Datei erweitert |
| `.claude/hooks/pretooluse-commit-msg-guard.sh` **bleibt** | ja | nicht im Diff |
| `test/` **neu** | ja | `test/commit-msg-hook.bats` (13 Fälle) |
| `test/mutations/` **neu** | ja | `340` (DoD (2)) + `341`/`342` (F-2, §4.4) |
| `harness/README.md` **update** | ja | §Traceability, Tabelle + drei Absätze |
| `.claude/agents/*.md` · `reviewer.md` **nicht durch diesen Slice** | ja | nicht im Diff |
| `slice-mv.sh` · `anwenden.go` **nicht durch diesen Slice** | ja | nicht im Diff |

**Gebaut, aber im §3 nicht als Zeile:**

- **`.d-check.yml`** — `hooks-install` in `targets.exempt-targets` und ein Kopplungs-Kommentar am
  `commits:`-Block. Die §3-Zeile *„ein neues behauptetes Ziel zieht `AGENTS.md` §4 und das Modul
  `targets` mit"* antizipiert das im Prosa-Text; die Zeile selbst nennt die Datei nicht. **Keine
  Schwellen-Senkung:** eine Zeile in `exempt-targets` hinzu, `modules:` unverändert (Review,
  Negativbefunde).
- **`harness/sensors/commit-msg-check.md`** — der Sensor des **bestehenden** Ziels
  `make commit-msg-check` nennt jetzt den zweiten Träger. Vom Standard-DoD-Punkt *„Doku-Update, falls
  ein öffentlicher Vertrag berührt ist"* gedeckt, nicht von einer §3-Zeile.

**Geplant, aber abweichend/überholt:** nichts. Die zwei Zeilen *„offen"* und *„update / entfällt"* des
`.claude/hooks/…`-Eintrags sind mit `0f2409cc` auf *„neu — ADR-0053"* bzw. *„bleibt"* gezogen — die
Architect-Antwort, keine stille Erweiterung.

**Die Form-Vorgabe aus §3** (das Nachbar-Repo-Muster „beschrieben, nicht verlinkt") **hält**: kein
maschinen-lokaler Pfad auf ein fremdes Checkout im Diff (`git diff 7ee36939^..HEAD | grep -nE '^\+'
| grep -E '/Development|/home/|/tmp/'` → kein Treffer).

---

## 12. Rest-Unsicherheit — was dieser Lauf **nicht** abgeschlossen hat

1. **Der volle `make mutate` ist nicht durchgelaufen.** Er wurde gestartet und nach **32 von 328**
   Fällen abgebrochen (`make mutate` fährt je Fall einen vollen Sensor-Lauf; der Baum ist unberührt,
   das Lock mit dem Lauf verschwunden). Belegt ist darum der **Zahn dieses Slice** — einzeln, am
   genauen `sed` des Falls, mit dem `# expect:`-Namen in der Fehlschlag-Ausgabe (§4.3) —, **nicht**
   ein vollständiges Mutations-Verdikt über den Baum. Der Rest ist: kein *anderer* Wächter dieser
   Kette ist in diesem Lauf auf Zähne geprüft.
2. **`make archive-welle` nicht als ganzer Lauf gefahren** — nur seine Message-Form (die Klasse ist
   heute `0` im Bestand, §Kontext ADR-0053). Ein realer Lauf setzt eine geschlossene Welle und
   einen Baum-Eingriff voraus.
3. **`make smoke` / `make full-smoke` und die emittierte Ebene** sind nach §1 ausgeschlossen und
   **nicht** gefahren.
4. **Die Aktivierung ist in keinem geteilten Baum gefahren** — nur in `/tmp`-Kopien und einem
   Wegwerf-Klon. Der Träger dieses Klons ist **nicht** scharf gestellt. Das ist die Weisung, und es
   ist zugleich die Grenze: der Rot-Beleg ist an der **Datei**-Verdrahtung gesehen, nicht an einem
   Commit **dieses** Klons.
5. **Der Baum bewegt sich unter parallelen Rollen.** Während dieses Laufs landete `f52e2e47`
   (Implementer, die Werkzeug-Zeile). Er ist im geprüften Stand und in der `make gates`-Zahl
   enthalten; ein **späterer** Commit nach `f52e2e47` ist von keiner Zusicherung dieses Berichts
   gedeckt.

---

## 13. Verdikt

**DoD-Verletzung: keine.** Alle drei slice-eigenen Liefer-Punkte tragen am Stand `f52e2e47`
(ADR-0053 mit vier Festlegungen und gezogener §3-Zelle · Träger verdrahtet, an der strukturell
unerreichten Werkzeug-Klasse rot gesehen und grün gegengeprobt, Zahn am Aufrufer mit tragender
Meldung · Reichweiten-Tabelle neben der alten, Grenzen und Konventions-Abhängigkeit benannt). Die
Prozess-Punkte tragen (`make gates` EXIT 0, Review-Report, Doku-Update) oder sind noch nicht fällig
(Closure, Register, §6-Ausgänge, die drei Paarungen — Planner).

**Ein Befund eigener Klasse, nicht blockierend:** **V-1** — die Zelle *„heute trägt keine eine"* der
Werkzeug-Klasse ist durch den Bestand widerlegt (367 von 411 `slice-mv`-Messages tragen eine
Ziffern-Kennung; die drei jüngsten alle). Er gehört dem Implementer/Planner und in die
Closure-Notiz, weil er die Zelle berührt, die DoD (3) trägt.

**Was der Reviewer gezogen hat und was hier bleibt.** Der Review hat den Diff, den Rot/Grün-Bestand
des Trägers, den frischen Klon und die Kopplung in beiden Richtungen gefahren; **F-5** hat er
ausdrücklich an die Verifikation übergeben — sie ist oben beantwortet (*verdrahtet* = die
Verdrahtung liegt im Repo, die Aktivierung ist der eine benannte Schritt). **Was hier neu ist:** der
frische Klon ist am echten `git clone` in **beiden** Hälften gemessen, der Zahn ist am genauen
`sed` einzeln gefahren und die `# expect:`-Nennung ist in der Fehlschlag-Ausgabe gelesen, die
F-2-Zähne sind je Richtung einzeln gefahren, und **V-1** ist gegen den Bestand gemessen.
