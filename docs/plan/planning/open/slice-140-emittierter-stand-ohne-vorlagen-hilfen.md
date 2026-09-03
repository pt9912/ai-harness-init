# Slice slice-140: Der emittierte Stand trägt keine Vorlagen-Hilfen mehr — Schritt 5 der Kopier-Prozedur läuft

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle (reaktiv). Die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, hier beantwortet: **(1) Bündel?** Nein — ein Slice über einer Emit-Regel, einzeln
lieferbar. **(2) Gemeinsames Closure-Kriterium?** Nein — jedes denkbare wäre die Abschrift seiner
eigenen DoD. **(3) Auslöser reaktiv oder gewollt?** Reaktiv: ein Review-Lauf hat einen Schritt der
Kopier-Prozedur benannt, den das Emit nicht ausführt. Kein Fähigkeits-Sprung — das Werkzeug lernt
nichts Neues, es tut den Schritt zu Ende, den es zur Hälfte tut. Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Ebene: emittiert, nicht Dogfood.** Gegenstand ist der Baum, den ein Bootstrap ablegt. Die
Guidance-Kommentare in `AGENTS.md`, `harness/conventions.md` oder `spec/lastenheft.md` **dieses**
Repos sind kein Gegenstand — sie stehen dort seit dem eigenen Bootstrap und sind gefüllt worden,
nicht emittiert.

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (was der Bootstrap ablegt,
ist ein Repo-File),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) (Singletons
werden *zu gestempelten `.md`-Zielen* — der Satz, an dem die halbe Ausführung hängt),
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
Command-Vorlagen tragen **adaptierbare Marker** — die Ausnahme, die dieser Slice **nicht**
anfassen darf),
[`LH-FA-09`](../../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (der vendored Baum
reist unverändert mit und ist ebenfalls keine Ausnahme, sondern gar kein Gegenstand),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`ADR-0005`](../../adr/0005-ziel-repo-distribution.md),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Regel nennt, was sie rot färbt),
[`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)
(der Vorlagen-Satz gehört dem Kurs — geändert wird das Emit, nie die Vorlage),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).

**Berührte Spec-Stellen:**
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) — der Satz
*„Singletons … werden zu gestempelten `.md`-Zielen"*. Der Verweis zeigt **aufwärts**: das
Lastenheft nennt diesen Slice nie.

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Was das Werkzeug emittiert, ist ein Repo-File und keine Vorlage — auch dort, wo die Hilfe im
HTML-Kommentar steht statt im Blockquote.**

Der Befund stammt aus dem Review-Durchgang zu
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md); dessen §6 verlangt
für jeden übergebenen Posten eine Slice-ID, und **dieser Slice ist sie** — für den
`StripHintBlock`-Posten und den `BEDIENHINWEIS`-Posten zugleich, weil beide dieselbe Ursache haben
(unten gemessen: jeder Bedienhinweis im emittierten Baum steht **in** einem HTML-Kommentar, nicht
daneben).

### Die Prozedur hat sechs Schritte, das Emit führt fünf davon

Der Set-Index des vendored Satzes schreibt vor, wie eine Vorlage zu einem Repo-File wird
(`sed -n '/^## Verwendung/,/^## /p' .harness/baseline/v5.18.0/templates/README.md`). Schritt 4
lautet *„Template-Hinweis-Block oben entfernen"*, Schritt 5 *„HTML-Kommentar-Hilfen entfernen
(`<!-- ... -->`) — **außer** `<!-- d-check:ignore … -->`-Marker"*. Beide Schritte sind im Baum
belegbar:

```sh
grep -c 'HTML-Kommentar-Hilfen entfernen' .harness/baseline/v5.18.0/templates/README.md  # -> 1
grep -c 'func StripHintBlock' internal/emit/templates.go                                 # -> 1  (Schritt 4)
grep -c 'd-check:ignore' internal/emit/templates.go                                      # -> 0  (Schritt 5 fehlt)
```

`StripHintBlock` trifft nur den Blockquote, der die Zeichenkette `Template-Hinweis` führt. Die
HTML-Kommentare bleiben stehen — und mit ihnen die Bedienhinweise, denn die stehen **in** einem
HTML-Kommentar, nicht daneben.

### Der Ist-Bestand, gemessen am emittierten Baum statt am Vorlagen-Satz

```sh
B=.harness/state/bin/ai-harness-init                 # aus `make host-bin`
P=$(mktemp -d); (cd "$P" && git init -q . && "$B" --name probe >/dev/null)
find "$P" -name '*.md' -not -path '*/.git/*' -not -path '*/.harness/baseline/*' -print0 \
  | xargs -0 grep -n '<!--' | grep -v 'd-check:ignore' > /tmp/rest.txt
wc -l    < /tmp/rest.txt                              # -> 55  Kommentar-Hilfen gesamt
grep -c  '/\.claude/'  /tmp/rest.txt                  # -> 10  ANPASSEN-Marker, sie BLEIBEN
grep -vc '/\.claude/'  /tmp/rest.txt                  # -> 45  aus dem vendored Satz, sie GEHEN
cut -d: -f1 /tmp/rest.txt | grep -v '/\.claude/' | sort -u | wc -l   # -> 10 Dateien
```

**Die Zahlen wandern** mit dem Vorlagen-Satz und mit dem Emitter und sind keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). **Die Trennlinie ist die Herkunft, nicht der Wortlaut:** die **10** unter `.claude/`
kommen aus dem eigenen Vorlagen-Satz `internal/emit/templates/` und tragen `ANPASSEN`-Marker, die
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
ausdrücklich verlangt (*„tragen repo-spezifische Stellen … als **adaptierbare** Marker"*); die
Kopier-Prozedur des Kurses spricht nicht über sie. Die **45** kommen aus dem vendored Satz, und für
sie gilt Schritt 5.

### Der schärfste Fall sagt es selbst

Der erste Bedienhinweis in der emittierten `observations.md` unter `docs/plan/planning/` lautet
wörtlich
*„BEDIENHINWEIS — keine Norm; faellt beim Kopieren weg (README.md §Verwendung, Schritt 5) und darf
deshalb nichts Tragendes halten."* Er fällt nicht weg. Ein Adopter liest in seinem eigenen Register
einen Satz, der seine eigene Abwesenheit behauptet — und darunter eine Muster-Tabelle mit
erfundenen `BEO-001`/`BEO-002`-Zeilen, gegen die derselbe Block warnt. Dieselbe Form steht im
emittierten `docs/plan/planning/in-progress/roadmap.md`
(`grep -rl 'BEDIENHINWEIS' "$P" | grep -v '/\.harness/baseline/'` → **2** Dateien).

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Kein emittiertes Dokument aus dem vendored Satz trägt noch eine Kommentar-Hilfe, und
      die zwei Ausnahmen sind gemessen unberührt.** Über den Baum aus §1: die
      `grep -vc '/\.claude/'`-Zeile fällt auf **0**, die `grep -c '/\.claude/'`-Zeile bleibt
      unverändert, und jeder `d-check:ignore`-Marker steht noch
      (`grep -rc 'd-check:ignore' "$P" --include='*.md' | grep -v ':0$'` liefert dieselbe Menge wie
      vorher). **Vorher-Nachher über dasselbe Kommando**, nicht gegen eine notierte Zahl.
- [ ] **(2) Ein `test/mutations/`-Fall färbt die Regel rot.** Ohne ihn ist (1) eine Zusage ohne
      Gegenbeispiel ([`AGENTS.md`](../../../../AGENTS.md) §3.6). Der Fall trifft die Stelle, die der
      Emitter wirklich benutzt — nicht eine im Test nachgebaute Verdrahtung.
- [ ] `make gates` bringt **keinen Befund hervor, der diesem Slice zuzurechnen ist** — Vorher-
      Nachher-Vergleich derselben Ausgabe, nicht „grün": der Lauf trägt fremde Posten mit eigenen
      Folge-Slices (§6). Dazu `make smoke` und `make full-smoke` über denselben Baum, weil der
      Gegenstand **emittiert** ist und `make gates` ihn nicht sieht (§6).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: das Repo hat keinen Brownfield-Bootstrap und führt keines; das Item
      entfällt mit diesem Grund, nicht still.
- [ ] Beobachtungs-Register fortgeschrieben: neue `BEO-<NNN>` oder Zähler +1 mit Beleg in
      [`observations.md`](../observations.md) — *keine Beobachtung angefallen* ist ebenfalls eine
      Antwort und wird in §7 notiert.
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
| `internal/emit/templates.go` | update | Schritt 5 der Kopier-Prozedur läuft im Emit-Pfad der Singletons — dort, wo `StripHintBlock` heute Schritt 4 tut; die `d-check:ignore`-Ausnahme steht in derselben Funktion, nicht in einer Liste daneben |
| `internal/emit/` (Test) | neu | die Regel wird über den **realen** Vorlagen-Satz gemessen, nicht über eine Fixture — die Grenze aus `.dockerignore` steht in §6 |
| `test/mutations/` | neu | ein Fall, der die Regel aushebelt und den Wächter rot färbt |
| `.harness/baseline/v5.12.0/templates/**` | **unverändert** | der Satz gehört dem Kurs ([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)) und liegt unveränderlich vendored; geändert wird das Emit, nie die Vorlage |
| `internal/emit/templates/**` | **unverändert** | der eigene Vorlagen-Satz; seine `ANPASSEN`-Marker sind nach [`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) gewollt und dürfen nicht mitfallen |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): [slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md)
liegt in `done/`. Der Grund ist **tragend, nicht ordnend**: jener Slice entscheidet, welche Vorlage
überhaupt emittiert wird, und der Prüfbereich dieses Slice ist genau die Ergebnis-Menge. Läuft er
davor, misst dieser Slice über einem Satz, den der andere noch verändert.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich zeigt, dass die Entfernung
  eines HTML-Kommentars in mindestens einer Vorlage die Markdown-Struktur um ihn herum ändert
  (Leerzeilen-Semantik, Tabellen-Fortsetzung) und der Slice damit zwei Gegenstände trägt — die
  Regel und ihre Struktur-Reparatur.
- `in-progress` → `open` (blockiert — Carveout?): wenn ein entfernter Kommentar tragenden Inhalt
  hält, der nirgendwo sonst steht. Dann ist die Frage *was gehört in den emittierten Stand* keine
  Emit-Frage mehr, sondern eine an die Vorlage — und die gehört dem Kurs.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **das Kommando aus §1 liefert über den frisch emittierten Baum
`0` Kommentar-Hilfen aus dem vendored Satz bei unveränderter `ANPASSEN`- und
`d-check:ignore`-Menge**, und **`make smoke` wie `make full-smoke` sind grün**. Dazu die
Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Ein HTML-Kommentar kann tragenden Inhalt halten.** Die Prozedur nennt eine einzige Ausnahme
  (`d-check:ignore`); ob sie die einzige **nötige** ist, sagt sie nicht. Ein Kommentar, der eine
  Struktur zusammenhält statt sie zu erklären, fiele mit. Die Bezugsmenge ist das Kommando aus §1,
  keine Zahl hier. — **Ausgang:** <entfallen: jede Fundstelle des Kommandos einzeln geprüft, keine
  trägt | eingetreten: CO-NNN mit benanntem Geltungsbereich>
- **Kein Ziel in `make gates` fährt den realen Vorlagen-Satz und die Emit-Regel zusammen.**
  `.dockerignore` führt `.harness`, die Go-Test-Stufe sieht den vendored Baum also nicht; der
  Nachweis hängt an `make smoke`/`make full-smoke`, und der zweite braucht Netz. — **Ausgang:**
  <entfallen: der Wächter läuft in `make gates` über einer Quelle, die die Stufe sieht |
  eingetreten: die Grenze steht am Wächter, und der Nachweis hängt an den zwei Sensoren außerhalb
  der Gates>
- **Die Herkunfts-Trennung ist heute ein Pfad-Präfix.** Dass die zu erhaltenden Marker unter
  `.claude/` liegen, ist eine Eigenschaft des heutigen Emit-Bestands, keine Zusage: kommt ein
  Dokument aus `internal/emit/templates/` außerhalb dieses Präfixes dazu, trennt das Präfix nicht
  mehr. Der Wächter muss an der **Quelle** unterscheiden, nicht am Zielpfad. — **Ausgang:**
  <entfallen: die Unterscheidung liegt am Emit-Pfad, nicht an einem Präfix | eingetreten:
  slice-NNN, sobald ein solches Dokument entsteht>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

Erst nach Abschluss füllen.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `internal/emit/` (eigener Zuschnitt, eigene
Tests, eigene Ziel-Form — drei von drei Achsen) und `test/` (eigener Zuschnitt, eigene
Werkzeugkette — zwei von drei). Beide erfüllen die Schwelle ≥ 2; keine ist zu grob geschnitten.

**Vorgelagert — offene Beobachtungen sichten:** die Sichtung ist **offen** — sie ist vor der
Bearbeitung gegen [`observations.md`](../observations.md) zu fahren, und ihr Ergebnis gehört ins
Kriterium *Evidenz-/Diskrepanz-Risiko* unten. Sie steht hier nicht als Ergebnis, weil der Stand des
Registers zwischen Schnitt und Bearbeitung wandert.

Alle berührten Sub-Areas GF: `internal/emit/` und `test/` gehören zum Greenfield-Bestand; der Modus
steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md). Der Modus-Begründungsblock entfällt
damit nach dem *Umfang*-Absatz oben.
