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

- [ ] **(1) Der Pin steht auf v0.65.0, dreifach belegt, und der emittierte Default zieht mit.**
      Digest gegen lokalen RepoDigest, `docker buildx imagetools inspect` und den Release-Body
      gehalten ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)); die vier
      Re-Adaptions-Handgriffe aus
      [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
      Setzung 1 sind ausgeführt.
      **Rot:** nur [`d-check.mk`](../../../../d-check.mk) bewegen und
      [`internal/emit/emit.go`](../../../../internal/emit/emit.go) stehen lassen → `make test` fällt
      an `TestDefaultDigest_MatchesCanonical` und `TestDefaultImage_MatchesCanonical`. Dieser Lauf
      gehört gesehen, nicht behauptet.
- [ ] **(2) Der Trockenlauf ist wiederholt und ausgewiesen — mit seiner Richtung.** Beleg im
      Umsetzungs-Commit: Datei- und Befundzahl beider Versionen über denselben Baum, dazu der Satz,
      was er **nicht** zeigt (Messung 1 gegen §1 letzter Absatz).
      **Rot:** `make docs-check` nach dem Pin meldet ≠ 0 Befunde — dann ist der Sprung nicht
      kostenlos und der Slice hat eine Bereinigung statt einer Zusage.
- [ ] **(3) Die zwei bewegten aktiven Module sind am Bestand geprüft, nicht am CHANGELOG geglaubt.**
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

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example). Ein Begründungsblock
entfällt: der Slice legt keine neue Sub-Area an und berührt keine in BF oder Hybrid. Das
Gate-Fragment ist konventionell dicht bis zur Vorschrift — es ist tool-generiert, und die vier
erlaubten Handgriffe stehen abgezählt in
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
Setzung 1.
