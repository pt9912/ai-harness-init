# Slice slice-122: Der d-check-Pin zieht auf v0.65.0 — und die Strenge-Bilanz kommt diesmal nicht vom Trockenlauf

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** ohne Welle (Wartung, reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1: **(1) Bündel?** Nein — ein Pin, eine Bilanz. **(2) Gemeinsames Closure-Kriterium?** Nein.
**(3) Auslöser reaktiv oder gewollt?** **Reaktiv**, und Frage 3 nennt genau diesen Fall wörtlich
(*„Pin ist veraltet → reaktiv, ohne Welle"*). Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Warum dieser Slice nicht in [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) liegt,
obwohl er ihr Trigger ist.** Die Welle adoptiert vier Regelmodule desselben Werkzeugs, und es liegt
nahe, den Pin als ihren ersten Slice zu führen. Dagegen stehen zwei gemessene Gründe. **Erstens**
teilen Pin und Modul-Adoption den Trockenlauf **nicht** — die naheliegende Annahme ist am Bestand
widerlegt: der Pin-Trockenlauf fährt die sechs aktiven Module über unveränderter Config und
antwortet `425 Datei(en) geprüft, 0 Befund(e)`; jedes der vier Kandidaten-Module ist **ohne eigenen
Config-Block inert** und braucht seinen eigenen Lauf mit eigener Config
([welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §1, dort gemessen). Ein gemeinsamer Beleg
existiert also nicht, nur ein gemeinsames Werkzeug. **Zweitens** ist der Pin eine **Wartungspflicht
mit eigenem Auflösungs-Trigger**
([`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
§Auflösungs-Trigger: *„bei d-check-Release … neu pinnen und die Strenge-Bilanz über die neue Spanne
neu ziehen"*); sie an eine Fähigkeits-Entscheidung zu hängen hieße, eine fällige Wartung auf einen
Entwurf warten zu lassen.

**Ebene: Dogfood und emittiert zugleich — und das ist keine Ausnahme, sondern die Kopplung.** Der
lebende Pin steht in [`d-check.mk`](../../../../d-check.mk); daran gekoppelt steht der
**emittierte** Default in [`internal/emit/emit.go`](../../../../internal/emit/emit.go), und zwei
go-Tests halten beide zusammen. Die emittierte **Modul-Liste** bleibt unberührt
([`MR-017`](../../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)) —
dieser Slice bewegt eine Versions-Referenz, keine Prüfbereichs-Entscheidung.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Digest-Pin ist die
Reproduzierbarkeits-Zusage; ein Tag allein ist keine),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Target-Aufzählung aus
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 2 ist an den Re-Pin gebunden — sie wächst mit dem Tool, die Aufzählung nur von Hand),
[`MR-009`](../../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) (der
Auflösungs-Trigger, der diesen Slice auslöst, und das Muster *„Trockenlauf vor dem Pin, Pflicht und
belegt"*),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (die
vier Handgriffe der Re-Adaption des tool-generierten Fragments),
[`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) (der
Vorgänger-Sprung und die Warnung, die dieser Slice ernst nimmt: der Trockenlauf beantwortet die
§3.5-Frage **nicht**),
[`MR-012`](../../../../harness/conventions.md#mr-012--d-check-pin-v0511-sources-verfügbar) (dieselbe
Linie, ein Sprung früher),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (Senkung ⇒ ADR — die Frage, die dieser Slice beantworten
muss, statt sie am grünen Trockenlauf vorbeizuwinken),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel).

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel

**Der gepinnte d-check steht auf `v0.65.0`, und die Frage, ob der Sprung an einem aktiven Modul
Strenge senkt, ist an der Quell-Differenz beantwortet — nicht am grünen Trockenlauf und nicht an
der CHANGELOG-Aufzählung.**

### Der Anlass, gemessen

`make freshness-dcheck` meldet (Exit 1): `gepinnt: v0.62.0`, `latest: v0.65.0`. Heute steht in
[`d-check.mk`](../../../../d-check.mk) `DCHECK_IMAGE ?= ghcr.io/pt9912/d-check:v0.62.0` mit
`DCHECK_DIGEST ?= sha256:3996a593…`.

### Fünf Messungen, jede neben ihrem Kommando

Alle gegen eine **Kopie außerhalb des Repos** gefahren, Stand `1f5741f`, netzlos (`--network none`),
Mount `:ro`; die Kopie liegt im Wegwerf-Bereich und ist kein Artefakt dieses Slice.

1. **Der Trockenlauf vor dem Pin ist grün und byte-gleich.** v0.62.0 (gepinnter Digest) und v0.65.0
   (`sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288`) über denselben
   unveränderten Baum mit unveränderter [`.d-check.yml`](../../../../.d-check.yml):
   beide `d-check: 425 Datei(en) geprüft, 0 Befund(e)`, Exit 0; `diff` der zwei Ausgaben ist leer.
2. **Das Fragment ändert sich in genau einer Zeile.** `--print-mk` beider Versionen, verglichen:
   die einzige inhaltliche Differenz ist `DCHECK_IMAGE ?= …:v0.62.0` → `…:v0.65.0`.
   `grep -cE '^docs?-[a-z-]+:' <fragment>` → **12** in beiden. Die Target-Aufzählung in
   [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   Setzung 2 bleibt damit inhaltlich stehen — sie ist trotzdem **abzugleichen**, weil ihr
   Auflösungs-Trigger das verlangt und nicht ihr Ergebnis.
3. **Und hier endet die Ähnlichkeit mit
   [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar).**
   Über die Vorgänger-Spanne waren die Regeldateien der aktiven Module unbewegt. Diesmal nicht:
   `git diff --numstat v0.62.0..v0.65.0 -- internal/hexagon/core/rules/<datei>` am lokalen
   d-check-Klon liefert `codepaths.go` **+28/−6** und `ids.go` **+35/−11** — **zwei aktive Module,
   beide mit entfernten Zeilen**. Daneben bewegt sich geteilte Vorverarbeitung, aus der alle
   aktiven Module lesen: `markdown.go` **+15/−5**, `sections.go` **+41/−1**, `run.go` **+30/−19**.
   Die übrigen aktiven Regeldateien (`links.go`, `anchors.go`, `matrix.go`, `spans.go`) bewegen
   **keine** Zeile.
4. **Der CHANGELOG nennt die Ursache, und sie trifft genau diese zwei Module.** d-checks slice-162
   (`[0.64.0]`) macht den Zeilen-Marker `d-check:ignore` **innerhalb von Inline-Code unwirksam**,
   slice-159 (ebenda) verlangt für ihn die **HTML-Kommentar-Form** — beides ausdrücklich nur für
   `codepaths` und `ids`, beides upstream als *„monoton verengend"* deklariert. Die Fläche in
   diesem Repo:
   `git grep -n 'd-check:ignore' -- ':!.harness/baseline' | wc -l` → **234** Zeilen. Dieselbe
   Ausgabe weitergereicht an `grep -c '<!--'` → **172** in HTML-Kommentar-Form; weitergereicht an
   einen Zähler über der in Backticks gesetzten Schreibweise des Markers → **44** in Inline-Code.
   Messung 1 sagt, dass **keine** davon einen Befund freilegt; die Zahl sagt, dass die Fläche real
   ist und der Beleg gebraucht wird.
5. **Der Pin ist nicht nur Wartung.** d-checks slice-166 (`[0.65.0]`) behebt **vierzehn** behebbare
   HIGH-CVEs im ausgelieferten Image (neun `golang.org/x/crypto`, vier `golang.org/x/net`, eine
   `go-git`). Das ist ein Grund **für** den Sprung, der unabhängig von der Freshness-Zeile trägt —
   und er steht hier, weil er sonst nirgends stünde: kein Gate dieses Repos scannt das gepinnte
   Fremd-Image.

### Was der Trockenlauf trägt, und was nicht

Er trägt **eine** Richtung: über diesem Korpus entsteht kein neuer Befund. In der Gegenrichtung ist
er über einer 0-Befund-Basis **informationsleer** — `425/0` bleibt `425/0`, ob eine Befundklasse
weggefallen ist oder nicht. Genau deshalb hängt DoD (3) an einer konstruierten Gegenprobe und nicht
an diesem Lauf.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [x] **(1) Der Pin steht auf v0.65.0, dreifach belegt, und der emittierte Default zieht mit.**
      Digest gegen lokalen RepoDigest, `docker buildx imagetools inspect` und den Release-Body
      gehalten ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); die vier
      Re-Adaptions-Handgriffe aus
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
      Setzung 1 sind ausgeführt.
      **Rot:** nur [`d-check.mk`](../../../../d-check.mk) bewegen und
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) stehen lassen → `make test` fällt
      an `TestDefaultDigest_MatchesCanonical` und `TestDefaultImage_MatchesCanonical`. Dieser Lauf
      gehört gesehen, nicht behauptet.
- [x] **(2) Der Trockenlauf ist wiederholt und ausgewiesen — mit seiner Richtung.** Beleg im
      Umsetzungs-Commit: Datei- und Befundzahl beider Versionen über denselben Baum, dazu der Satz,
      was er **nicht** zeigt (Messung 1 gegen §1 letzter Absatz).
      **Rot:** `make docs-check` nach dem Pin meldet ≠ 0 Befunde — dann ist der Sprung nicht
      kostenlos und der Slice hat eine Bereinigung statt einer Zusage.
- [x] **(3) Die zwei bewegten aktiven Module sind am Bestand geprüft, nicht am CHANGELOG geglaubt.**
      Für die Marker-Semantik von `codepaths`/`ids` liegt eine **konstruierte Gegenprobe** vor.
      **Rot:** eine Datei mit einem `d-check:ignore` in Inline-Code (bzw. in barer Form), die einen
      sonst sicheren Befund trägt — unter v0.62.0 unterdrückt, unter v0.65.0 **nicht** mehr. Färbt
      die Probe unter beiden Versionen gleich, ist die Verengung nicht belegt und die Bilanz trägt
      nicht; die Frage aus [`AGENTS.md`](../../../../AGENTS.md) §3.5 bleibt dann offen, statt als
      beantwortet zu gelten.

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund ·
Doku-Update, falls ein öffentlicher Vertrag berührt ist · Closure-Notiz mit
Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | der lebende Pin: `DCHECK_IMAGE` + `DCHECK_DIGEST`, dazu der adaptierte Kopfkommentar (Handgriff 3 aus [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) Setzung 1) |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | `DefaultImage`/`DefaultDigest`; die zwei go-Tests koppeln beide Stellen und färben DoD (1) rot |
| [`Makefile`](../../../../Makefile) | update | das Tag-Beispiel im Kommentar über `DCHECK_TAG` — dieselbe Stelle, die [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar) beim Vorgänger-Sprung nachzog |
| [`harness/conventions.md`](../../../../harness/conventions.md) | **nicht durch diesen Slice** | der Adaptions-Block ist Architect-Eigentum ([`AGENTS.md`](../../../../AGENTS.md) §3.8). Der neue MR-Eintrag und die §Baseline-Version entstehen im Architect-Lauf; dieser Slice liefert die **Messungen** als Übergabe-Artefakt |
| [`.d-check.yml`](../../../../.d-check.yml) | **unverändert** | der Pin bewegt keine Modul-Liste. Wer hier etwas ändern will, ändert einen Prüfbereich — das ist [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md), nicht dieser Slice |

## 4. Trigger

**Beginn (`open` → `next` → `in-progress`): `make freshness-dcheck` ist rot und das WIP-Limit ist
frei.** Beides ist heute erfüllt; der Slice wartet auf nichts.

**Rückführungen, vorab benannt:**

- `in-progress` → `next`: DoD (3) zeigt, dass die Marker-Verengung im Bestand **doch** einen
  wirksamen Marker trifft. Dann ist der Pin eine Sache und die Marker-Bereinigung eine zweite —
  zwei Schnitte, kein vierter DoD-Punkt.
- `in-progress` → `open`: die Strenge-Bilanz findet an `codepaths` oder `ids` eine **Senkung**. Dann
  verlangt [`AGENTS.md`](../../../../AGENTS.md) §3.5 einen ADR, und der schreibt der Architect —
  der Slice blockiert an einer fremden Rolle und geht zurück, statt die ADR nebenbei mitzunehmen.

## 5. Closure-Trigger

DoD (1) bis (3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make mutate` ohne Befund,
`make freshness-dcheck` grün, Review nach Modul 10 und Verifikation nach Modul 11 ohne blockierenden
Befund, Closure-Notiz in §7 mit Steering-Loop-Eintrag und der Übergabe an den Architect (§3, Zeile
[`harness/conventions.md`](../../../../harness/conventions.md)).

## 6. Risiken und offene Punkte

- **Der grüne Trockenlauf ist die verführerischste Zahl dieses Slice.** `425/0` gegen `425/0` liest
  sich wie ein Freispruch und ist keiner: über einer 0-Befund-Basis erzeugt eine **weggefallene**
  Befundklasse dieselbe Ausgabe wie eine unveränderte. Das steht schon in
  [`MR-024`](../../../../harness/conventions.md#mr-024--d-check-pin-v0620-structure-verfügbar)
  (*„Was dieser Lauf trägt — und was nicht"*), und die Versuchung ist diesmal größer, weil zwei
  aktive Regeldateien Zeilen **verloren** haben.
- **Die CHANGELOG-Aufzählung darf die Bilanz nicht tragen.** Upstream weist sie selbst als
  unvollständig aus (`[0.58.0]`: *„Diese Aufzählung ist offen"* — in drei Review-Runden dreimal
  unvollständig gewesen). Sie ist bestätigend; tragend ist die Quell-Differenz aus §1 Messung 3.
- **Der lokale d-check-Klon ist kein Artefakt dieses Repos.** Die Bilanz ist gegen ihn
  reproduzierbar, nicht gegen ein Gate — kein Modul dieses Repos vergleicht Befundklassen zweier
  d-check-Versionen. Wer den Klon nicht hat, kann DoD (3) nicht nachvollziehen; die konstruierte
  Gegenprobe ist deshalb der Teil, der **ohne** ihn reicht.
- **Der CVE-Befund ist ein Hinweis auf eine Lücke, die dieser Slice nicht schließt.** Vierzehn HIGH
  im gepinnten Fremd-Image, und kein Sensor dieses Repos hätte sie gemeldet. Das ist eine eigene
  Klasse (Freshness sagt *„neuer Tag da"*, nicht *„der gepinnte ist verwundbar"*) und gehört als
  Kandidat notiert, nicht hier erledigt.

## 7. Closure-Notiz (nach `done/`)

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-28.
**Gegenstand:** HEAD `be6348c`, fünf Commits: `2ea9412`/`a813969` (Lifecycle-Moves, je 0 Zeilen),
`c323735` (Link-Abgleich), `3ce4ea3` (der Pin), `be6348c` (die Korrektur).

Jede Zahl unten ist in diesem Lauf erhoben; die Zahlen aus Umsetzung, Review und Verifikation
waren **Eingabe, kein Beleg**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1).

### DoD-Stand — drei Punkte, jeder mit dem Kommando, das ihn hier trug

**(1) Der Pin steht auf v0.65.0, dreifach belegt, und der emittierte Default zieht mit —
ERFÜLLT.** Zwei der drei Digest-Beine selbst gefahren:
`docker image inspect --format '{{index .RepoDigests 0}}' ghcr.io/pt9912/d-check:v0.65.0` und
`docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.65.0` liefern beide
`sha256:5ea03abe…41288`; das dritte (Release-Body) liegt zweifach unabhängig vor
([Review](../../../reviews/2026-08-28-slice-122-review.md) §Prüfung der übergebenen Behauptungen,
[Verifikation](../../../reviews/2026-08-28-slice-122-verify.md) §2). Die zwei gekoppelten Stellen
tragen ihn zeichengleich: `grep -n '^DCHECK_IMAGE\|^DCHECK_DIGEST' d-check.mk` → Zeilen **32/33**,
`grep -n 'DefaultImage\s*=\|DefaultDigest\s*=' internal/emit/emit.go` → Zeilen **33/34**. Die vier
Handgriffe aus
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1 sind gegen eine **frische** Tool-Ausgabe abgezählt, nicht gegen die Erinnerung:
`docker run --rm --network none <v0.65.0-digest> --print-mk` in eine Datei, dann
`diff <frisch> d-check.mk | grep -c '^[0-9]'` → **4** Hunks.
**Das Rot ist nicht von mir hergestellt** — es ist Modul-11-Arbeit und dort mit Exit 2 und genau
den zwei zugesagten `--- FAIL:`-Zeilen belegt
([Verifikation](../../../reviews/2026-08-28-slice-122-verify.md) §2).

**(2) Der Trockenlauf ist wiederholt und ausgewiesen — mit seiner Richtung — ERFÜLLT, auf zwei
Commits verteilt.** Das Rot des Punktes (`make docs-check` meldet nach dem Pin ≠ 0) ist grün:
`make docs-check` endet mit `0 Befund(e)`, Exit 0. **Die Dateizahl derselben Zeile ist hier
ausdrücklich kein Erwartungswert** — sie wächst mit jedem Dokument, das dieser Lauf anlegt
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Der zugesagte Satz
*„was er nicht zeigt"* stand in `3ce4ea3` allerdings über die **Modul-Reichweite**, während der
Punkt auf §1 letzter Absatz zeigt — die Informationsleere über einer 0-Befund-Basis
([Verifikation](../../../reviews/2026-08-28-slice-122-verify.md) V-4). Geschlossen ist die Lücke
erst mit `be6348c`, und zwar durch eine Messung statt durch einen Satz (siehe (3) unten). Der
Punkt trägt damit, aber nicht in einem Zug.

**(3) Die zwei bewegten aktiven Module sind am Bestand geprüft — ERFÜLLT.** Bei Review und
Verifikation stand er auf *blockierend* bzw. *teilweise*; beide fanden **unabhängig** dieselbe
falsche Zeile. Ich habe die Gegenprobe **neu gebaut**, statt die Korrektur zu übernehmen:
synthetischer Baum außerhalb des Repos, `modules: [ids, codepaths]`, je vier Marker-Lagen über
einem toten Inline-Code-Pfad (`codepaths`) **und** über einer unverlinkten `MR-…`-Kennung (`ids`),
beide Digests netzlos mit `:ro`.

| Lage | `codepaths` v0.62.0 | `codepaths` v0.65.0 | `ids` v0.62.0 | `ids` v0.65.0 |
|---|---|---|---|---|
| `<!-- d-check:ignore -->`, echter HTML-Kommentar | unterdrückt | unterdrückt | unterdrückt | unterdrückt |
| blanke Prosa, Marker ohne Kommentar | unterdrückt | **meldet** | unterdrückt | **meldet** |
| Kommentar-Form in Inline-Code eingeschlossen | unterdrückt | **meldet** | unterdrückt | **meldet** |
| ohne Marker (Kontrolle) | meldet | meldet | meldet | meldet |

Summen: `3 Datei(en) geprüft, 2 Befund(e)` gegen `3 Datei(en) geprüft, 6 Befund(e)`, beide Exit 1;
die Befundmenge von v0.62.0 ist **echte Teilmenge** der von v0.65.0. Die Kontrollzeilen färben
unter beiden Versionen — der Aufbau misst also seinen Gegenstand und nicht seine eigene
Untauglichkeit. **Damit ist die Verengung in beiden Achsen und für beide bewegten Module belegt:
Form** (echter HTML-Kommentar) **und Lage** (nicht in Inline-Code). Die zweite Achse ist die
schärfere — sie entwertet jede Schreibweise außerhalb eines HTML-Kommentars.

**Die Gegenrichtung, auf einer Nicht-Null-Basis.** Kopie aus `git archive be6348c` außerhalb des
Repos, alle Marker in getracktem Markdown außerhalb der vendored Baseline entwertet, dann beide
Digests: **beide** melden `434 Datei(en) geprüft, 26 Befund(e)`, `diff` der sortierten Ausgaben
**leer**, Klassen `awk -F'\t' '{print $NF}' | sort | uniq -c` → **15** `codepath-missing`, **11**
`id-unlinked`. Dasselbe Vorgehen auf `3ce4ea3` liefert `432 Datei(en) geprüft, 26 Befund(e)`.
**Tragend sind die 26 und die leere `diff`-Ausgabe**, nicht die Dateizahl — die trennt nur die zwei
Commits und wächst mit dem Baum. Der Sprung ändert an keinem aktiven Modul etwas — **in keiner
Richtung**, und über
einer Basis, auf der ein Wegfall sichtbar geworden wäre. Die §3.5-Frage aus
[`AGENTS.md`](../../../../AGENTS.md) ist damit beantwortet: **Anheben, keine Senkung, kein ADR
fällig** ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids):
Anheben → Steering-Loop).

### Was funktionierte, und was anders lief

**Die Rollen-Trennung hat genau das getan, wofür sie existiert.** Zwei Kontexte fanden ohne
Kenntnis voneinander dieselbe falsche Zeile, dieselbe fehlende `ids`-Messung und dieselbe
stehengebliebene §Baseline-Zeile. Der schreibende Lauf fand keine davon.

**Anders lief die Beleglage, nicht der Pin.** `3ce4ea3` trug **zwei** Tatsachenbehauptungen, die
ihrer eigenen Messung nicht standhielten: die als *„bar"* ausgewiesene Gegenproben-Zeile trug in
Wahrheit die Kommentar-Form (die Form-Achse war damit in **keiner** Richtung gemessen), und die
Begründung *„kostet nichts, weil wir keinen solchen Marker führen"* ist am Bestand falsch —
`grep -rn 'd-check:ignore' --include='*.md' . | grep -v '.harness/baseline'` nach `wc -l` → **242**
Zeilen, derselbe Strom nach `grep -c '<!--[^>]*d-check:ignore'` → **171**, also **71** nicht in
Kommentar-Form. Die Schlussfolgerung hielt, der Grund nicht. **Der Pin selbst war zu keinem
Zeitpunkt strittig.**

**Eine Rückführung nach §4 wurde nicht ausgelöst**, und beide Bedingungen sind gemessen statt
angenommen: die Verengung trifft im Bestand keinen wirksamen Marker (Strip-Lauf, identische
Befundmenge), und an `codepaths`/`ids` liegt keine Senkung vor (Gegenprobe, beide Achsen
verengend).

### Steering-Loop-Eintrag — **benannte Spec-Lücke**, und der Träger steht daneben

**Die Lücke.** Für die Klasse *„eine Tatsachenbehauptung in einer Commit-Message, die ihrer
eigenen Messung nicht standhält"* trägt in diesem Repo **keine Regel und kein Sensor** die
Wahrheits-Achse. Zwei benachbarte Schnitte decken je eine andere Achse derselben Zeichenkette und
**schließen die Wahrheits-Achse ausdrücklich aus**:
[slice-121](../open/slice-121-commit-message-nennt-was-es-gibt.md) §1 prüft, ob ein Hex-Token ein
Objekt dieses Repos bezeichnet, und sagt über den Rest *„nicht mechanisierbar … Die restliche
Klasse trägt kein Sensor, sondern die Norm"*;
[slice-126](../open/slice-126-commit-message-traegt-eine-kennung.md) DoD (3) verlangt vom Träger
die Aussage, er prüfe *„nicht die Wahrheit der Aussagen, nur die Anwesenheit einer Kennung"*.
**Beide falschen Zeilen aus `3ce4ea3` tragen weder einen Hash noch eine fehlende Kennung** — sie
sind inhaltlich falsch und passierten beide Nachbarn ungehindert.

**Die Fläche, mit ihrer Eigenschaft vor der Zahl.** Die Eigenschaft: *ein Satz in einer Message,
der eine Messung als Beleg ausweist, die er nicht gefahren hat*. Obergrenze der Fläche:
**649** von **1070** Messages führen ein Kommando oder eine Mess-Form (`git rev-list --count HEAD`
für den Nenner; für den Zähler je Commit
`git log -1 --format=%B "$c" | grep -qE '(grep -|git (grep|show|log|diff|ls-files)|docker run|make [a-z-]+|wc -l|→)'`,
gezählt die Treffer). Mechanische **Untergrenze** der gemeldeten Instanzen:
`grep -h '^- \*\*pfad:\*\*.*[Mm]essage' docs/reviews/*.md | wc -l` → **5** Befunde über **5**
Reports (`grep -l … | wc -l`). Beide Zahlen sind bewusst keine Verstoß-Zahl: ob ein Satz seine
Messung trägt, ist ein **Urteil**, kein Muster — und ein Muster, das es behauptete, wäre genau der
Wächter, der unter keiner Mutation rot wird ([`AGENTS.md`](../../../../AGENTS.md) §3.6
Falsch-Beispiel 1).

**Warum hier kein dritter Slice steht.** Ein Sensor über der Wahrheits-Achse ist zweimal
unabhängig als nicht mechanisierbar gemessen worden (siehe oben); ein dritter Schnitt wäre die
reflexhafte Antwort und lieferte einen dauerhaft grünen Wächter. Was fehlt, ist nicht ein Sensor,
sondern ein **Termin** für die Norm-Seite.

**Der Träger, und er ist nicht diese Notiz.**
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) existiert genau dafür: jeder
Posten an ein Norm-Artefakt bekommt einen Ausgang. Dieser Lauf hat ihm eine **gemessene
Widerlegung** mitgegeben, die seine Abwägung entscheidet — der einzige nicht permanente
Auflösungs-Trigger des Adaptions-Blocks
(`grep -c 'nicht permanent' harness/conventions.md` → **1**) hat **heute gefeuert** und seinen
selbst benannten Träger nicht bewegt:
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Auflösungs-Trigger sagt *„der Slice, der den Pin zieht, schlägt diesen Block ohnehin auf"*, und
er tat es nicht: `git grep -c 'MR-025' 3ce4ea3 -- '*slice-122-*.md'` ist **leer**, Exit 1 <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) -->
(Gegenprobe mit einer Kennung, die dort steht: dasselbe über `MR-024` → **5**) <!-- d-check:ignore (zitiertes Kommando-Argument, kein Verweis) -->, und
`git log -1 --format=%B 3ce4ea3 | grep -c 'MR-025'` → **0** <!-- d-check:ignore (zitiertes Kommando, kein Verweis auf den Eintrag) -->.
Die Messung ist **an `3ce4ea3` festgemacht**, nicht am heutigen Baum — diese Notiz nennt den
Eintrag selbst und würde ihre eigene Suche fündig machen. Damit ist Weg (B) jenes Slice —
*„weiter nennen, mit besserem Trigger"* — nicht mehr nur unbelegt, sondern einmal **gemessen
widerlegt**. Der Eintrag steht dort, wo ihn der nächste Lauf aufschlägt, statt in einem
Zeitdokument.

### Ausgänge — jeder offene Posten hat einen, *„genannt"* ist keiner

| Posten | Herkunft | Ausgang |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) §Baseline sagt weiter `Image v0.62.0` | Review MEDIUM-3, Verifikation V-6 | **Architect-Übergabe** unten, samt korrigierter Zwei-Achsen-Tabelle; zusätzlich als Posten in [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) verankert |
| Rang-Zeiger `d-check.mk:2` nennt keinen Eintrag für `v0.65.0` | Review LOW-1 | **[slice-128](../in-progress/slice-128-d-check-kopf-sagt-was-gilt.md)** DoD (1) — mit dem Beginn-Trigger *„der Eintrag existiert"*; echte Reihenfolge-Abhängigkeit |
| Die Dateizahl `432` im Kopf von `d-check.mk` misst den Baum, nicht den Kopf (heute **434**) | dieser Lauf | **[slice-128](../in-progress/slice-128-d-check-kopf-sagt-was-gilt.md)** DoD (2) |
| Kopf-Aussagen zu `sources` und zur Neu-Erzeugung sagen weniger als der Baum tut | Review INFO-2 | **[slice-128](../in-progress/slice-128-d-check-kopf-sagt-was-gilt.md)** DoD (3) — derselbe Kommentarblock, ein Lauf |
| [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)-Entscheidung ist fällig | Review MEDIUM-2 | **Architect-Übergabe** unten (Vorfragen hier neu gemessen) + [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) als Termin-Träger |
| `TestDefaultDigest_MatchesCanonical`/`TestDefaultImage_MatchesCanonical` ohne Fall in `test/mutations/` | Review MEDIUM-4, Verifikation V-8 | **[slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md)**, dessen Bezugsmenge dieser Lauf um die Go-Stufe erweitert hat — **kein** eigener Schnitt, Begründung unten |
| `ids` hatte keine Richtungs-Messung | Review MEDIUM-1, Verifikation V-5 | **erledigt** — hier neu gemessen, Tabelle in DoD (3) |
| DoD (2) nannte eine andere Grenze als der Commit | Verifikation V-4 | **erledigt** — der Strip-Lauf oben schließt sie auf Nicht-Null-Basis |
| *„vier Handgriffe schrumpfen auf einen"* misst die Tool-Ausgabe, nicht die Handgriffe | Verifikation V-1 | **eingefroren** — die Aussage steht nur in der gepushten Message `3ce4ea3`; kein lebendes Artefakt trägt sie (`grep -c 'Handgriffe' d-check.mk` → **0**). Sie zählt als Instanz zum Steering-Loop-Eintrag oben |
| Fixture `internal/emit/testdata/raw-print-mk.txt` friert v0.46.0 ein (**64** Zeilen gegen heute **68**, `wc -l < internal/emit/testdata/raw-print-mk.txt` und `docker run --rm --network none <digest> --print-mk \| wc -l`) | Review INFO-1 | **Architect-Übergabe** unten — der Auflösungs-Trigger von [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) nennt sie nicht; das ist eine Norm-Frage, kein Code-Befund (`AdaptMK` bricht auf allen vier Handgriffen hart ab) |

**Warum der fehlende Mutations-Fall kein eigener Schnitt ist.** Ein einzeln nachgereichter Fall
schlösse **eine** Stelle. Die Lücke ist aber eine Bezugsmengen-Frage, und
[slice-119](../open/slice-119-zusage-ohne-fall-wird-sichtbar.md) besitzt sie bereits — nur maß
seine Fläche **allein bats-Titel**, während `make mutate` seine Fälle über `# expect:` an beide
Stufen bindet. Über der Go-Stufe gerechnet: `git grep -h '^func Test' -- '*_test.go' | sed 's/^func \(Test[A-Za-z0-9_]*\).*/\1/' | sort -u | wc -l`
→ **226** Funktionen, davon ohne Fall (`comm -23` gegen die `# expect:`-Ziele) → **117** — und die
zwei Kopplungstests sind zwei davon. Ein zweiter Schnitt daneben wäre eine **zweite Fassung
derselben Frage**, die driftet; die Erweiterung ist deshalb in jenen Plan gewandert, nicht in
einen neuen.

### Übergabe an den Architect (§3.8 — vier Posten, keiner davon hier geschrieben)

1. **Der fünfte Pin-Ort steht falsch.** `sed -n '14p' harness/conventions.md` sagt
   *„d-check: Image v0.62.0"*, `sed -n '32p' d-check.mk` sagt `v0.65.0`. **Kein Gate zeigt
   darauf** — `modules:` führt sechs Namen, `versions`/`pins` sind nicht darunter
   (`grep -c 'versions\|pins' .d-check.yml` → **0**). Der Handlauf ist dieses `sed`.
2. **Der neue Eintrag zum `v0.65.0`-Sprung erbt sonst eine falsche Zeile.** Was er tragen muss,
   ist die **Zwei-Achsen**-Tabelle aus DoD (3) oben — Form *und* Lage —, nicht die Fassung aus
   `3ce4ea3`. Beleg an der Quelle statt am Verhalten: `ids.go` führt ab `v0.65.0` in `markerLines`
   beide Bedingungen (`stripInlineCodeByLine` für die Lage, `commentMarkerRe` für die Form), und
   `codepaths.go` konsumiert dieselbe Funktion — daher reagieren beide Module identisch, wie
   gemessen. Dazu gehört die Richtungs-Aussage: **Anheben, keine Senkung**, mit dem Strip-Lauf als
   Beleg (beide Versionen `26 Befund(e)`, identische Menge).
3. **[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
   ist fällig — eine Entscheidung, keine Erinnerung, und es sind drei.** Beide Vorfragen in
   diesem Lauf neu gemessen und beide **unverändert**: Weg (b) bleibt zu, denn kein d-check-Modul
   fährt einen Lauf —
   `git -C <d-check-klon> grep -ln 'os/exec' v0.65.0 -- 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' ':!*_test.go'`
   ist leer (Exit 1); und die *„früher fällig"*-Bedingung ist nicht eingetreten
   (`grep -c 'structure' .d-check.yml` → **0**). Die Entscheidung ist damit billig und liegt
   zwischen (a) eigener hermetischer Prüfer und (c) bewusster Permanenz. **Dieser Lauf liefert ihr
   eine frische Instanz derselben Klasse**: die `432` im Kopf von
   [`d-check.mk`](../../../../d-check.mk) ist an dem Commit, der sie einführt, bereits **434**.
4. **[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
   §Auflösungs-Trigger nennt die Fixture nicht.** Sie veraltet mit jedem Pin still (Zeilen-Zahlen
   in der Tabelle oben). Kein Code-Befund; eine Frage an den Trigger-Text.

**Was diese Übergabe nicht ist.** Kein Formulierungsvorschlag für einen Norm-Text — die Messungen
sind das Übergabe-Artefakt, der Regeltext entsteht im Architect-Lauf
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

### Verifikation dieser Closure

`make gates` grün über dem Arbeitsbaum dieser Closure (Ausgabe im Closure-Commit).
`make mutate` **nicht** in diesem Lauf gefahren: das vorliegende Protokoll lief über `3ce4ea3` mit
`198 ok, 0 Befund(e)`, `MUTATE_SECONDS=768.40`; seither bewegt kein Commit dieses Slice eine
Code-Datei — `git diff --name-only 3ce4ea3..HEAD` führt `d-check.mk` (Kommentarblock) und zwei
Berichte unter `docs/reviews/`. **Ein zweiter Review-Durchgang nach Modul 10 hat nicht
stattgefunden**; was den blockierenden `HIGH-1` schließt, ist `be6348c` **plus** die hier neu
gebaute Gegenprobe — eine dritte, unabhängige Messung derselben Eigenschaft. Das ist die Grenze
dieser Closure, und sie steht hier, weil sie sonst nirgends stünde.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Das
Gate-Fragment ist konventionell dicht bis zur Vorschrift — es ist tool-generiert, und die vier
erlaubten Handgriffe stehen abgezählt in
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1.
