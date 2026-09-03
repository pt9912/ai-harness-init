# Slice slice-173: Der Vorschau-Zweig von `archive-welle` — was der Lauf über den Baum sagt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD unten; ein repo-weiter Beleg darüber
hinaus steht in keinem Kriterium (Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht,
[`MR-037`](../../../../harness/conventions.md#mr-037--wellenlose-arbeit-ist-jetzt-baseline-default-ihr-auslöser-test-ist-neu-gefasst)).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein benanntes Target läuft auf frischem Checkout),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(der Host braucht `git`, `docker` und `make`, sonst nichts),
[ADR-0003](../../adr/0003-go-native-binaries.md) (native Binaries als Vertriebsform),
[ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2
(Fähigkeiten sind Unterkommandos **desselben** Trägers, und der Dogfood fährt denselben
Einstiegspunkt),
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) (`Proposed` mit
Acceptance-Trigger — das Architect-Verdikt, das dieser Port als Constraint liest: Festlegung 1
der Träger, Festlegung 2 der Zeitpunkt der Ablösung, die drei Abnahme-Kriterien).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Implementer

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Der Träger sagt, was eine Archivierung täte — und schreibt dabei nichts.**

`ai-harness-init archive-welle --vorschau <welle>` prüft die zwei fail-closed-Bedingungen, sammelt
die Zeitdokumente der Welle in ihren drei Klassen ein und nennt den Blast-Radius: welche Dateien
einen Verweis auf etwas Bewegtes tragen. Das **Tun** — Move, Zip, Stub, Nachzug, zwei Commits —
und die Ablösung des Shell-Helfers liefert
[slice-175](../open/slice-175-archive-welle-schreibender-pfad.md).

**Warum das Festlegung 2 aus
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) nicht auslöst.** Jene beendet
den Zustand *zwei Fassungen derselben Operation nebeneinander* und verlangt, dass
`make archive-welle` auf genau einen Träger zeigt. Ein Zweig, der nichts schreibt, ist keine
zweite Fassung der Operation; das Target bleibt unverändert beim Shell-Helfer, und der ist bis
[slice-175](../open/slice-175-archive-welle-schreibender-pfad.md) sein einziger.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **`ai-harness-init archive-welle --vorschau <welle>` sagt, was die Archivierung täte** —
      Zweig im `main()`-Dispatch neben `span-emit`/`span-report`, Logik unter `internal/archive/`,
      je mit Go-Test: das **Einsammeln** in den drei Klassen (*mitglied* nach dem `Welle:`-Feld ·
      *wellenlos* seit der letzten Closure · *fremd*, bleibt liegen) samt der Suffix-Grenze der
      Report-Zuordnung (`slice-001` trifft `slice-001a` nicht) und dem Untergrenzen-Wächter (ohne
      ein bestehendes `done/*/archiv.zip` hat *seit der letzten Closure* keine beobachtbare
      Untergrenze — fail-closed statt raten), dazu der **Fund** der drei Verweis-Formen
      (eingehend `done/<datei>` · geschwister-relativ · aufsteigend `../<datei>`). Ohne
      `--vorschau` schreibt der Zweig nichts und nennt den Grund.
- [ ] **Die zwei lesenden Abnahme-Kriterien halten, je einmal rot gesehen** —
      [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) Abnahme-Kriterium 1
      (der Hänger-Wächter schließt `docs/reviews/**` **nicht** aus; rot zu sehen: den Suchraum um
      `docs/reviews/**` verengen) und die **lesende Hälfte** von Abnahme-Kriterium 2 (die
      Sauberkeits-Prüfung deckt **untrackte** Dateien; rot zu sehen: sie auf getrackte verengen).
      Die schreibende Hälfte von 2 und Kriterium 3 liefert
      [slice-175](../open/slice-175-archive-welle-schreibender-pfad.md); Folgepflicht 1 jener ADR
      ist über **beide** Slices erfüllt und in keinem allein.
- [ ] `make gates` grün.
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) nennt den Vorschau-Zweig,
      wie er erreicht wird (über den Träger aus `make host-bin`) und dass `make archive-welle`
      unverändert den Shell-Helfer fährt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations.md`) fortgeschrieben — neue `BEO-<NNN>` oder Zähler +1 mit Beleg; keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/archive/` | neu | Vorprüfung · Einsammeln · Verweis-Fund, je mit Go-Test — die lesenden Gegenstände des Vorbilds (`collect.go`, die Fund-Hälfte von `rewrite.go`) |
| `cmd/ai-harness-init/archive_welle.go` | neu | Dispatch-Zweig nach dem Muster von `span_emit.go` / `span_report.go` |
| `test/mutations/` | neu | je ein Zahn für die zwei Abnahme-Kriterien und die drei Einsammel-Klassen; die sieben Shell-Fälle bleiben, solange der Helfer der Träger ist |
| [`harness/README.md`](../../../../harness/README.md) | update | wie der Vorschau-Zweig erreicht wird, und dass `make archive-welle` unverändert bleibt |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-172](../done/slice-172-adr-archivierung-als-unterkommando.md)
liegt in `done/` — [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) steht als
Architect-Verdikt und ist das Constraint dieses Ports.

**Die Schnitt-Achse ist *sagen* gegen *tun*, und die zwei Hälften sind gemessen** (keine
Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Am Shell-Helfer, über die Funktions-Spannen
(`awk '/^[a-z_0-9]+\(\) *\{/ { if(n) print n, NR-s; n=$1; sub(/\(\).*/,"",n); s=NR } END{ if(n) print n, NR-s }' harness/tools/archive-welle.sh`):
die **7** lesenden Funktionen tragen **97** Zeilen plus die Lesephase von `main()` (**126**,
`awk 'NR>=523 && NR<=648' harness/tools/archive-welle.sh | wc -l`), die **10** schreibenden
**189** plus die Schreibphase (**114**, `NR>=650 && NR<=763`); die drei `rewrite_*` (**52**)
verschmelzen Fund und Schreiben. Am Vorbild, das beide trennt:
`wc -l /Development/d-check/tools/archive-wave/{collect,rewrite,main}.go` → **474** für das Sagen
gegen `{archive,stub}.go` → **299** für das Tun, und `rewrite.go` trägt in **187** Zeilen genau
**1** schreibenden Aufruf
(`grep -c -E 'os\.WriteFile|os\.MkdirAll|os\.Rename|os\.Remove|\.Create\(' /Development/d-check/tools/archive-wave/rewrite.go`).
Keine der zwei Hälften erreicht die Vereinigung, an der die Rückführung gemessen wurde; **welche**
größer ist, hängt vom Maßstab ab — am Shell-Helfer das Tun, am Vorbild das Sagen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn der Verweis-**Fund** ohne den
  Schreibvorgang nicht prüfbar ist — dann endet dieser Slice beim Einsammeln und den zwei
  Wächtern, und der Fund geht zu
  [slice-175](../open/slice-175-archive-welle-schreibender-pfad.md).
- `in-progress` → `open` (blockiert — Carveout?): wenn
  [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) ihren Acceptance-Trigger
  nicht besteht (Reviewer-Runde mit blockierendem Befund) — dann steht die Träger-Wahl neu und
  dieser Slice hat keinen Gegenstand.

**Was die Achse *Port / Zusagen* nicht trägt**, und warum sie hier nicht steht: die drei
Abnahme-Kriterien sind für den **neuen** Träger geschuldet und können vor ihm nicht bestehen; am
Shell-Helfer sind sie seit [slice-170](../done/slice-170-archivierungs-werkzeug.md) erfüllt. Dazu
bindet Festlegung 2 der [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) die
Ablösung an *den Lauf, der das Unterkommando liefert* — „nicht davor und nicht danach". Ein
dritter Slice allein für die Ablösung ist damit ausgeschlossen; sie liegt bei
[slice-175](../open/slice-175-archive-welle-schreibender-pfad.md).

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; ein Vorschau-Lauf über eine geschlossene Welle dieses Repos ist gefahren und
seine vier Zahlen (mitglied · wellenlos · fremd · Reports) gegen die des Shell-Helfers gehalten —
er gibt dieselben aus, und eine Abweichung ist ein Befund, kein Rauschen; `make gates` grün;
Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein Port erbt die Grenzen des Vorbilds.** Dessen `README.md` §Grenzen nennt selbst, dass ein
  Verzeichnis-Präfix-Verweis aus einer **Nicht-Wurzel**-Datei still übersehen statt gemeldet wird
  — dieselbe Klasse, die `BEO-003` im [Register](../observations.md) als *eingehende Hälfte der
  präfixlosen Form* führt (5×, verkörpert in `make slice-mv` mit benannter Grenze). Der
  Verweis-**Fund** dieses Slice ist genau die Stelle, an der die Grenze sichtbar wird: was er
  nicht meldet, wandert ungesehen durch [slice-175](../open/slice-175-archive-welle-schreibender-pfad.md).
  — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im
  Register>
- **`unsauber_grund` ist die Funktion, die dieser Slice portiert, und sie trägt einen offenen
  LOW.** Sie zählt Zeilen aus `git status --porcelain` und nennt sie „Datei(en)", während eine
  Zeile ein untracktes Verzeichnis sein kann — die Klasse `BEO-026` im
  [Register](../observations.md) (1×, offen). Ein wortgleicher Port trägt sie weiter. —
  **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im
  Register>
- **Ein Reviewer kann den Vorschau-Zweig als zweite Fassung der Operation lesen** und Festlegung 2
  der [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) für ausgelöst halten —
  dann müsste dieser Lauf den Shell-Helfer entfernen, ohne dessen Schreib-Hälfte zu haben. Die
  Abgrenzung steht in §1 und hängt an einer prüfbaren Eigenschaft (der Zweig schreibt nicht,
  `make archive-welle` bleibt unverändert), nicht an einer Absicht. — **Ausgang:** <eingetreten:
  CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → BEO-NNN im Register>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<NNN>` (<slice-NNN>, <slice-MMM>, <slice-KKK> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations.md`):** <neue `BEO-<NNN>` angelegt (Sub-Area, 1×, Beleg slice-NNN) | `BEO-<NNN>` auf <N>× erhöht, Beleg slice-NNN ergänzt | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-NNN (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — `cmd/`, `internal/` und
`test/mutations/` liegen in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).
`harness/tools/` ist **nicht** mehr berührt: die Ablösung des Shell-Helfers liegt bei
[slice-175](../open/slice-175-archive-welle-schreibender-pfad.md).

**Vorgelagert — offene Beobachtungen sichten:** Drei Treffer im [Register](../observations.md).
`BEO-003` (5×, verkörpert in `make slice-mv` mit benannter Grenze) und `BEO-026` (1×, offen)
stehen als Risiko in §6. `BEO-016` (1×, offen — ein Slice-Plan trägt ein Vielfaches der Zeilenzahl
des Schwester-Repos für dieselbe Arbeitsklasse) ist durch den Re-Cut berührt und **kein** Risiko:
der Schnitt kürzt diesen Plan, statt ihn wachsen zu lassen. Keiner erreicht mit diesem Slice die
Schwelle neu. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
