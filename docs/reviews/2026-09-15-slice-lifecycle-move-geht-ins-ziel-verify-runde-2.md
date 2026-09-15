# Verifikation `slice-lifecycle-move-geht-ins-ziel` Runde 2 — der Doku-Punkt trägt

**Rolle:** Verifier · **Datum:** 2026-09-15 · **Geprüfter Stand:** `c6616447` (der Nachzug am
Doku-Punkt), mit der Planner-Korrektur `17793c49` davor — `git rev-parse HEAD` →
`c66164479ab023e9f850064578a4e84af41ac0f1`; `git status --porcelain` → keine Zeile, vor und nach
jeder Messung.

**Prüfgegenstand: genau der Nachzug am Doku-Punkt.** Der §2-Punkt gegen den **tatsächlichen**
Stand, dazu die drei Zusagen, die der Implementer ausdrücklich eingeschränkt hat, §3.6 und §3.7 an
der neuen Section — **nicht** der Plan gegen sich selbst (das war der Reviewer).

**Vorgeschichte, nicht neu gemessen.** Runde 1 (Kennung
`2026-09-15-slice-lifecycle-move-geht-ins-ziel-verify`) hat die drei Liefer-Punkte als tragend und
den Doku-Punkt als die einzige Verletzung befunden; der Planner hat den Punkt in `17793c49`
entschieden (*fällig*, Träger ist die Sensor-Prosa) und der Implementer ihn in `c6616447` gezogen.
Was Runde 1 als tragend befunden hat, prüfe ich **nicht** erneut — eine zweite Messung derselben
Sache ist keine zweite Meinung. Ich lese sie als Vorgeschichte und zitiere ihre Rot-Belege als
solche.

**An diesem Gegenstand nicht geschrieben (Negativ-Aussage).** Dieser Lauf hat an `harness/sensors/slice-mv.md`,
am Slice-Plan, an `internal/emit/**`, an `test/**` und an den zwei Review-Reports **nichts**
verfasst: kein Satz, kein Kommentar, kein Testfall, keine Mutation, kein Review-Befund. Er hat
gelesen, Sensoren gefahren und Sonden in `/tmp`-Kopien gelegt.

**Offengelegt — was dieser Lauf am Baum getan hat.** Alle Läufe mit Wirkung lagen in
`/tmp`-Kopien; am Repo ist **keine** Datei geändert worden:

- `/tmp/v2-ignore` (`git archive HEAD` des Repos): drei `make docs-check`-Läufe — Grundstand,
  Marker entfernt, Marker zurück.
- `/tmp/v2-konv` (dieselbe Kopie plus **ein** Sondentest unter `internal/emit/`): `make test-go`.
- `/tmp/v2-konv-mut` (Kopie davon, `Enforce` für die zwei `slice-mv`-Zielorte auf skip-if-present
  gepatcht): `make test-go` mit und ohne den Sondentest.

Im Repo selbst lief nur `make gates` (EXIT 0). Nach allen Läufen: `git status --porcelain` ohne
Zeile.

**Ausgenommener Gegenstand — nicht geprüft, mit Grund.** Die **Closure** (§7, Beobachtungs-Register,
die drei §6-Ausgänge, `git mv` — Planner-Arbeit nach [`AGENTS.md`](../../AGENTS.md) §3.10), der
offene Reviewer-Befund **F-7** ([`MR-057`](../../harness/conventions.md) §Grenze — beim Architect),
die Wellen-Closure und das vierte Wellen-Mitglied.

**Zitier-Form:** Kennung statt Adresse für alles, was der Prozess bewegt — der Slice, die drei
Reports zu diesem Gegenstand (ein Review-Report ist ein Zeitdokument, das die Wellen-Archivierung
einsammelt) und die Geschwister. Ortsfeste Code-Pfade stehen als Inline-Code, ortsfeste Ziele als
Link.

---

## Ergebnis in einer Tabelle

| §2 DoD-Punkt | Verdikt |
|---|---|
| **Liefer-Punkt 1** — der emittierte Anweisungssatz nennt für Schritt 9 und 24 das Werkzeug, die repo-spezifischen Stellen bleiben adaptierbare Marker | **erfüllt** — Vorgeschichte, nicht neu gemessen (§1) |
| **Liefer-Punkt 2** — das Ziel führt das Werkzeug, beide Nachzug-Richtungen, reiner Move-Commit | **erfüllt** — Vorgeschichte, nicht neu gemessen (§1) |
| **Liefer-Punkt 3** — fehlende Voraussetzung bricht ab und committet nichts; die zwei Pfad-Ausnahmen als Repo-Politik markiert | **erfüllt** — Vorgeschichte, nicht neu gemessen (§1) |
| `make gates` grün | **erfüllt** über `c6616447` (§1.1) |
| Review durchgeführt, Report liegt vor | **erfüllt** — unverändert seit Runde 1 (zwei `Rolle Reviewer`-Commits, Runde 2 ohne blockierenden Befund) |
| **Doku-Update: die Sensor-Prosa führt die zweite Fassung samt Ort und Verdrahtung** | **erfüllt** (§2.1) — der Gegenstand dieser Runde |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **nicht fällig** — Planner ([`AGENTS.md`](../../AGENTS.md) §3.10) |
| Beobachtungs-Register fortgeschrieben | **nicht fällig** — Planner |
| Jedes Risiko aus §6 trägt einen Ausgang | **nicht fällig** — Planner; die drei Ausgangs-Platzhalter stehen unverändert |
| Die drei Paarungen sind getragen | **nicht fällig** — im Wellen-Repo die Welle-Closure |

**Verbleibende DoD-Verletzungen: keine.** Der Doku-Punkt, den Runde 1 als die eine Verletzung
gemeldet hat, ist mit `c6616447` erfüllt; die drei Liefer-Punkte trug Runde 1. Die vier unteren
Zeilen sind Planner-Arbeit und keine Lücke.

**Befunde eigener Klasse (Verifier, keine DoD-Verletzung): fünf**, alle INFO — §4.1 bis §4.5.

---

## 1. Ist der Sensor gelaufen?

Der Gegenstand dieser Runde ist **eine Markdown-Datei**: `git diff --numstat c6616447~1 c6616447 -- harness/sensors/slice-mv.md`
→ `54	0`. Die vier Liefer-Punkte liegen damit unberührt; der Sensor, dessen Prüfbereich sich
ändert, ist das **Doku-Gate**, und das läuft in `make gates`. Dazu treten drei Sonden, die die
Zusagen der neuen Section selbst betreffen (§1.2, §1.3).

### 1.1 `make gates` — **EXIT 0**

```sh
make gates        # EXIT 0
#  baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
#  d-check: 1438 Datei(en) geprüft, 0 Befund(e)
#  1..295 · 0 Zeilen `not ok` in der bats-Stufe
#  comment-claims: 62 Datei(en) geprueft, 0 Befund(e)
#  span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
```

**Keine Erwartungswerte** ([`MR-025`](../../harness/conventions.md) Setzung 2) — die Dateizahlen
wandern mit dem Baum; tragend sind die Nullen und das `OK`.

### 1.2 Die Zusage über den `d-check:ignore`-Marker — in **beiden** Richtungen gefahren

Der Implementer gibt an, der Inline-Marker am Fragment-Pfad sei einzeln belegt. In `/tmp/v2-ignore`
(`git archive HEAD`), drei Läufe über derselben Kopie:

```sh
# (1) Grundstand
make docs-check   # EXIT 0 · d-check: 1438 Datei(en) geprüft, 0 Befund(e)
# (2) Marker entfernt: `sed -i 's| <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->||'`
make docs-check   # EXIT 2 · d-check: 1438 Datei(en) geprüft, 1 Befund(e)
#   harness/sensors/slice-mv.md:46  harness/mk/slice-mv.mk  codepath-missing  Ziel des Inline-Code-Pfads existiert nicht
#   make: *** [d-check.mk:79: docs-check] Fehler 1
# (3) Marker zurück
make docs-check   # EXIT 0 · d-check: 1438 Datei(en) geprüft, 0 Befund(e)
```

Die Angabe **stimmt**, und sie stimmt in beiden Richtungen: ohne den Marker fällt der Lauf mit
Exit 2 an genau diesem Pfad, mit ihm ist er grün. Dass nur dieser eine der zwei genannten
Zielpfade einen Marker braucht, trägt die Config selbst — `codepaths.roots: [spec, docs, harness]`
in `.d-check.yml` prüft `harness/…` und `tools/…` nicht.

### 1.3 Die Zusage „kanonisch neu geschrieben“ — Träger geprüft, und die Grenze gemessen

Die neue Section sagt vom Fragment, es komme „aus dem tool-eigenen Fragment, das jeder Bootstrap
kanonisch neu schreibt“. Ob **ein** Sensor das trägt, ist eine Prüfung mit zwei Hälften; beide
gefahren in `/tmp/v2-konv` und `/tmp/v2-konv-mut`:

```sh
# (a) Gilt es überhaupt? Ein Sondentest driften die zwei Zielorte und lässt Enforce zum zweiten Mal laufen
make test-go      # EXIT 0 — alle Pakete ok, die Drift wird geheilt, der Modus mitgezogen (die Zusage ist WAHR)
# (b) Nimmt ein LISTED Sensor den Bruch wahr? Derselbe Sondentest, Enforce für die zwei slice-mv-Zielorte auf skip-if-present gepatcht
make test-go      # EXIT 2 — nur der Sondentest fällt: „harness/mk/slice-mv.mk wurde NICHT kanonisch neu geschrieben“, „tools/harness/slice-mv.sh …“
# (c) Und ohne den Sondentest, bei unveränderter Mutation?
make test-go      # EXIT 0 — kein listed Wächter fällt
```

Die zwei Ausgänge zusammen sind der Befund: die Aussage ist **wahr** und **unbewacht** — kein
Test, kein Mutationsfall und keine Stufe des E2E fällt, wenn das Fragment und das Werkzeug nicht
mehr kanonisch neu geschrieben werden. Die E2E-Idempotenz-Sektion driftet `README.md`, den
Rollen-Typ, das `Makefile` und die Feldliste (`harness/tools/full-smoke.sh`, Abschnitt
*Idempotenz*); die zwei `slice-mv`-Dateien sind nicht darunter. Dieselbe Lesung ergibt sich aus der
Go-Stufe: die einzige Konvergenz-Prüfung dort driftet `tools/harness/record-gates.sh`
(`TestEnforce_Convergent`), nicht die zwei Zielorte dieses Slice.

### 1.4 Was ich deshalb **nicht** erneut gefahren habe

`make full-smoke` ist **nicht** gelaufen. Sein Prüfgegenstand ist der emittierte Zielbaum;
`c6616447` ändert eine Markdown-Datei dieses Repos, die der E2E nicht liest. Runde 1 hat ihn über
dem Stand vor dem Nachzug mit **EXIT 0** gefahren und jede der drei Zusagen dort gelesen; eine
zweite Fahrt wäre eine zweite Messung desselben Gegenstands. Die Wirkungs-Zusagen der neuen Section
habe ich stattdessen **am E2E-Code** gelesen (Belegstellen unten), was für eine Section, die ihren
Träger nennt, die richtige Prüfung ist.

---

## 2. Deckt der Sensor die Zusage?

### 2.1 Der Doku-Punkt — **erfüllt**

Der Punkt verlangt: die Sensor-Prosa führt die **zweite** Fassung des Werkzeugs samt ihrem **Ort**
und ihrer **Verdrahtung**, und der Plan-Satz des Planner-Laufs verlangt vier Aussagen. Ich habe die
**neue Section vollständig gelesen** (nicht die Zusammenfassung des Implementers) — sie steht als
`## Im gebootstrappten Ziel` am Dateiende, die bestehenden Sections *Vertrag*, *Grenze* und
*Bindung* sind unverändert (`54	0` Zeilen, §1).

| Gefordert | Steht in der Section | Träger, den die Section nennt |
|---|---|---|
| mitreisendes Werkzeug + Fragment + Aggregator-Include | Skript unter `tools/harness/slice-mv.sh`, Fragment unter `harness/mk/slice-mv.mk`, eingebunden per `include harness/mk/*.mk` | `make test-go` (`TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette`, `TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen`), `make full-smoke` (Fragment liegt, Skript ausführbar, Aufruf erreichbar) |
| beide Nachzug-Richtungen **und** der reine Move-Commit | eingehend auf die bewegte Datei, ausgehend präfixlose Geschwister **innerhalb** der Datei; Move-Commit ohne Inhaltsänderung, ohne Änderung bleibt es beim einen | `make full-smoke`: Kette Aggregator → Fragment → abgelegtes Skript → `git`, `git show --numstat` auf den Move-Commit |
| die Voraussetzung bricht ab und bewegt nichts | unsauberer Arbeitsbaum bricht vor dem ersten `git mv` ab und nennt den Fall; zweiter Fall derselben Klasse ist das fehlende Werkzeug | `make full-smoke` (zwei Zweige derselben Stufe) |
| die zwei Pfad-Ausnahmen sind **setzbar** und als REPO-POLITIK markiert, nicht Politik des Werkzeugs | „im Ziel **setzbar**“, Variable mit Vorgabe, Durchreichung als Umgebung, „Politik des jeweiligen Repos, nicht Mechanik des Werkzeugs“ | `make test-go` (`TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert`, `TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch`), `make full-smoke` für die Wirkung der Vorgabe |

**Jede der vier Aussagen steht im Text und nennt ihren Träger** — keine steht als bloße Behauptung
da. Die Angaben sind zudem **am Artefakt nachgelesen**, nicht übernommen:

- `include harness/mk/*.mk` steht im emittierten Aggregator (`grep -n 'include harness/mk' internal/emit/makefile.go` → Zeile 27), und `make slice-mv` ist im Ziel nur erreichbar, weil der Glob das Fragment zieht.
- Die Voraussetzungs-Meldung steht in `main()` **vor** dem `git mv` (`internal/emit/templates/enforce/slice-mv.sh`), die zwei Bindungspunkte der Ersetzung ebenso.
- Der E2E fährt wirklich, was die Section zusagt: die Nachbar-Datei mit Präfix-Verweis, das
  verbliebene Geschwister, die ADR unter `docs/plan/adr/`, den unsauberen Arbeitsbaum und das
  beiseitegelegte Werkzeug (`harness/tools/full-smoke.sh`, Abschnitte (b), (c), (d), (e), (g), (h)).

**Die zweite Hälfte des Punktes, und sie ist eine Wort-Falle.** Der Satz endet mit „sie beschreibt
allein die Fassung dieses Repos“. Als **Anforderung** gelesen wäre er mit dem Nachzug verletzt —
die Datei beschreibt jetzt **beide** Fassungen; als **Beschreibung des Vorzustands** gelesen (und
so trägt ihn die Begründung des Planner-Laufs: die Prosa nennt allein die Fassung dieses Repos, „ohne
zu sagen, dass sie im Ziel setzbar sind“) trägt er unverändert. Ich entscheide den Punkt über seine
**erste** Hälfte und melde die zwei Lesarten als Befund eigener Klasse (§4.1) — die Entscheidung
über den Wortlaut gehört dem Planner, die ausführende Rolle schreibt ihr Abnahmekriterium nicht um
([`AGENTS.md`](../../AGENTS.md) §3.10).

### 2.2 Die drei Einschränkungen des Implementers — **in beide Richtungen** geprüft

**(a) Die Nennung des Aufrufs in der Command-Vorlage hält `make test-go`, nicht `make full-smoke`.**
Die Einschränkung ist **richtig**: `TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen` liest die
emittierte Anleitung selbst (`emit.CommandFile(".claude/commands/implement-slice.md")`), zerlegt sie
in Schritte und prüft Schritt 9 und Schritt 24 auf den Aufruf **im Text** (nicht im Kommentar
daneben); der E2E prüft die Nennung nicht. Der *genannte* Träger ist damit der richtige.
**Eine Präzisierung, kein Fehler:** „der E2E liest die Vorlage nicht“ steht **nur in der
Commit-Message**; der Satz der Section („Den **Text** der Anleitung hält `make test-go` fest … die
**Wirkung** der Kette misst `make full-smoke`“) ist exakt. Der E2E berührt die Commands sehr wohl —
ihre **Existenz** und die Abwesenheit repo-interner Referenzen (`harness/tools/full-smoke.sh`,
Zeile 1593-1601) —, nur nicht diese Zusage. Als Grenze notiert (§4.2).

**(b) „die Datei wird bei jedem Bootstrap kanonisch neu geschrieben“ ist gestrichen.**
Die Einschränkung ist **richtig** in ihrer Richtung (keine Stufe driftet `tools/harness/slice-mv.sh`,
§1.3 gelesen) — und sie ist **zu schmal**: dieselbe Aussage steht für das **Fragment** weiter in der
Section und ist ebenso unbewacht (§1.3 (c), §4.3). Der jetzt genannte Träger („die Setzbarkeit der
Variable trägt die Aussage allein“) trägt die **Politik-Aussage**: dass ein Adopter setzt statt zu
editieren, hängt nicht daran, *dass* das Skript überschrieben wird — die zwei Go-Wächter halten
Markierung und Durchreichung, der E2E die Wirkung der Vorgabe.

**(c) „jede Präfix-Form“ steht jetzt beim Rumpf-Vergleich der bats-Stufe.**
Die Einschränkung ist **richtig**, und sie ist an der Vorlage gemessen: der E2E fährt im Ziel
**eine** Präfix-Form — die Nachbar-Datei trägt `[slice-smoke-move](../open/slice-smoke-move.md)`
(`grep -n 'slice-smoke-move.md' harness/tools/full-smoke.sh` → die Fixture-Zeile; ein zweites
Vorkommen mit anderer Tiefe gibt es dort nicht). Der genannte Träger ist der richtige und der
**stärkere**: `test/slice-mv.bats` vergleicht die **Rümpfe** der drei Ersetzungs-Funktionen beider
Fassungen weißraum-normalisiert und hält damit die *Regel*, nicht eine Formenliste — der E2E könnte
das nicht leisten, auch mit mehr Formen nicht. Dass dieser Vergleich Zähne hat, ist rot gelesen
(Mutationsfall `346` fällt ihn über einer einseitig entfernten Entscheidung; Review-Runde 2).

### 2.3 §3.6 — was rot gesehen ist, und was nicht

| Zusage der neuen Section | Was passieren müsste, damit sie bricht | Rot gesehen |
|---|---|---|
| das Fragment liegt im Ziel und hängt an keiner Gate-Kette | Fragment aus `enforceFiles()` oder an `GATE_CHECKS` | `343` (Review-Runde 1) |
| das Werkzeug liegt ausführbar und trägt beide Richtungen | Werkzeug-Eintrag entfernt | `344` (Verifikation Runde 1) |
| die Anleitung nennt den Aufruf an den zwei Stellen | `make slice-mv` → `git mv` in der Vorlage | `345` (Verifikation Runde 1) |
| die zwei Ersetzungs-Regeln sind in beiden Fassungen gleich | einseitig entfernte Entscheidung in der emittierten Fassung | `346` (Review-Runde 2) — der **einzige** Rot-Beleg, der die emittierte Fassung selbst trifft |
| Markierung und Durchreichung der Ausnahmen | Marker/Variable in Fragment oder Kopf entfernt | rot **gelesen**, aber **ohne Fall im Set** (`make mutate` würde es nicht melden — N-2, Runde 1 §5.1) |
| die Wirkung der Vorgabe im Ziel (ADR bleibt unberührt) | Ausnahmezweig in `main()` von der Liste getrennt | `315` (`TestSliceMvEchtUebergehtAcceptedADRBeimNachzug`) |
| der `d-check:ignore`-Marker am Fragment-Pfad | Marker entfernt | **dieser Lauf**, beide Richtungen (§1.2) |
| „jeder Bootstrap schreibt das Fragment kanonisch neu“ | Fragment/Werkzeug auf skip-if-present | **nicht** rot gesehen und von keinem listed Sensor wahrgenommen (§1.3) — Grenze, §4.3 |

**Zwei Grenzen bleiben benannt stehen** und sind keine Verletzung, sondern das, was §3.6 zu
benennen verlangt: die Aussage „kanonisch neu geschrieben“ hat keinen Wächter (§4.3), und die zwei
Ausnahme-Wächter haben keinen Fall im Mutations-Set (N-2, Vorgeschichte). Dass die
Voraussetzungs-Zweige des E2E je einzeln rot gelesen sind, trifft für den Zweig „ohne Werkzeug“
zu (Review-Runde 2 §6); für den Zweig „unsauberer Arbeitsbaum“ ist die Zusage im Werkzeug vor dem
`git mv` gebaut und in jedem E2E-Lauf **gefahren**, ihre eigene rote Richtung aber nicht
vorgeführt — dieselbe Klasse, kleinere Folgen.

### 2.4 §3.7 — beschreibt die Section die Stelle oder ihren Vorgang?

**Kein Verstoß.** Die neue Section trägt **keine** Befund-Kennung, **keine** Slice-Nummer, **kein**
Lauf-Protokoll (kein Perfekt an ein Datum gebunden, kein „hier und heute“), **kein** „was bisher
fehlte“ und **keine** Ziffer außer den Kennungen `MR-005` und `ADR-0042`. Die Zahlwörter („die zwei
Stellen“, „die drei Ersetzungs-Funktionen“, „beide Richtungen“) sind Aufzählungen im Fließtext und
damit von [`MR-025`](../../harness/conventions.md) Setzung 1 nicht gebunden; die einzige Stelle mit
Messwert-Charakter nennt ihr Kommando (`` `git show --numstat` `` auf den Move-Commit).

Zwei Sätze stehen nah an der Grenze und bleiben innerhalb: „Gemessen wird das an einem echten
Move …“ und „Gefahren wird die Kette über der `--lang-go`-Variante“ beschreiben **den Sensor, der
die Zusage hält** — und ein Sensor-Name gehört zur Zusage (§3.6), das Protokoll seines Laufs
nicht; ein Protokoll ist es nicht.

**Geltungsbereich, der Vollständigkeit halber:** §3.7 bindet seinem Wortlaut nach Code,
Konfiguration, Skripte und die Zustandsfelder lebender Register; die neue Section ist ein lebendes
Markdown-Artefakt, für das die Nachbarn [`MR-025`](../../harness/conventions.md) und
[`MR-033`](../../harness/conventions.md) greifen. Ich melde das geprüfte Ergebnis und nicht mehr:
die drei Klassen, nach denen der Auftrag fragt, sind nicht darin, und die Baseline-Aussage-Klausel
hat kein Objekt (die Section spricht über kein Baseline-Artefakt).

---

## 3. Sagt der Plan, was der Code tut?

Nichts zu melden, und das ist hier das Ergebnis: `c6616447` ändert **eine** Datei —
`harness/sensors/slice-mv.md`, `54	0` Zeilen (§1). §3 des Plans nennt für diesen Nachzug keine
Zeile (der Punkt ist ein §2-DoD-Punkt), der Diff trägt keine Datei, die §3 nicht schon deckt, und
keine Zeile aus §1 (Abgrenzung) ist berührt. Die zwei Zusätze, die in den Plan-Satz des
Planner-Laufs eingezogen wurden (*Ort* und *Verdrahtung*), stehen beide in der Section (§2.1).

---

## 4. Befunde eigener Klasse (Verifier — **keine** DoD-Verletzung)

Alle fünf sind INFO. Keiner ist eine DoD-Verletzung; vier sind Wort- bzw. Träger-Präzisierungen an
der neuen Section, einer betrifft den DoD-Satz selbst.

### 4.1 V-4 (INFO) — der DoD-Satz trägt zwei Lesarten, und die zweite ist mit dem Nachzug verletzt

`slice-lifecycle-move-geht-ins-ziel` §2 endet mit „sie beschreibt allein die Fassung dieses
Repos“. Wörtlich als Anforderung gelesen ist das mit `c6616447` **falsch geworden** — die Datei
beschreibt beide Fassungen, das war der Zweck des Nachzugs; als Beschreibung des Vorzustands
gelesen (so trägt es die Begründung in `17793c49`) ist es unverändert wahr. Die erste Lesart macht
den Punkt praktisch unerfüllbar, weil jede Lieferung ihn verletzt. **Benannt, nicht entschieden:**
den Wortlaut zieht der Planner bei der Closure; ich habe den Punkt über seine operative erste
Hälfte als erfüllt gelesen (§2.1).

### 4.2 V-5 (INFO) — die Commit-Message sagt mehr, als gemessen ist

„der E2E liest die Vorlage nicht“ (Message von `c6616447`) ist zu breit: `make full-smoke` liest
`.claude/commands/implement-slice.md` sehr wohl — es prüft ihre **Existenz** und dass im ganzen
Commands-Verzeichnis keine repo-interne Referenz steht (`harness/tools/full-smoke.sh`, Zeile
1593-1601; beide Zusicherungen würden bei einer entfernten Vorlage fallen). Nicht gelesen wird dort
allein die **Nennung** des Aufrufs — genau die Zusage, für die die Einschränkung gedacht ist. Der
**Satz der Section ist exakt**; betroffen ist nur der Bericht.

### 4.3 V-6 (INFO) — dieselbe Aussage ist für das Fragment stehen geblieben, obwohl sie ebenso unbewacht ist

Die Section streicht die kanonische Neuschrift für das **Skript** und behält sie für das
**Fragment** („er kommt aus dem tool-eigenen Fragment, das jeder Bootstrap kanonisch neu
schreibt“). Gemessen (§1.3): die Aussage ist **wahr** (der zweite `Enforce` heilt die Drift, den
Modus mitgezogen — Sondentest grün über unverändertem Baum) und **unbewacht** (derselbe Sondentest
ist das einzige, was fällt, wenn `Enforce` die zwei Zielorte auf skip-if-present schaltet; ohne ihn
bleibt `make test-go` über allen Paketen grün, EXIT 0). Beide Hälften derselben Aussage tragen
denselben Deckungsgrad — die eine wurde eingeschränkt, die andere steht ohne benannte Grenze. Nach
§3.6 ist das zu **benennen**: entweder erhält das Fragment dieselbe Einschränkung, oder die Grenze
steht an der Stelle, und der Träger ist der `--lang-go`-Zweig des E2E (der die Fragment-Datei
anlegt, aber nicht gegen Drift prüft).

### 4.4 V-7 (INFO) — `?=` wird dem Skriptkopf zugeschrieben, es steht nur im Fragment

Die Section sagt, „Skriptkopf und Fragment führen sie als `SLICE_MV_AUSGENOMMENE_PFADE` mit einer
Vorgabe (`?=`)“. Die `?=`-Form ist Make-Syntax und steht im **Fragment**; das Skript liest die
Variable mit `${SLICE_MV_AUSGENOMMENE_PFADE:-…}`. Dass **beide** Orte die Variable und eine Vorgabe
führen, stimmt — die Form ist je eine andere, und der Satz nennt eine für zwei. Die
Durchreichungs-Achse ist davon nicht berührt (sie hat ihren Wächter, §2.2 (b)).

### 4.5 V-8 (INFO) — die `sprachlos`-Hälfte nennt einen Wächter, der nur ihre halbe Aussage liest

„dass Fragment und Skript auch sprachlos unter denselben Pfaden liegen, hält `make test-go`
(`TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette`)“ — der **Befehl** hält beides, der
**genannte** Test liest nur das Fragment. Das Skript liegt für denselben sprachlosen Emit im
Nachbartest derselben Stufe (`TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen`, beide
über `emit.Enforce`). Ein Leser, der nur den genannten Fall prüft, hält die Skript-Hälfte für
unbewacht.

**Nicht gemeldet, mit Grund:** die zwei Zitate auf [`MR-005`](../../harness/conventions.md) — eines
in der neuen Section, eines wortgleich im Schwester-Abschnitt `harness/sensors/history-range-guard.md`
(`grep -rn 'MR-005' harness/sensors/*.md` → zwei Zeilen). Der Eintrag trägt eine Kopf-Marke auf
[`MR-047`](../../harness/conventions.md), die genau die *Abweichungs*-Aussage auflöst, während die
Layout-Setzung selbst fortbindet — das Zitat löst also auf, der zitierte **Begriff** („Adaption“)
nennt aber die aufgelöste Hälfte. Weil beide Sections dieselbe Form führen, ist es eine Klasse des
Wells und kein Fundort dieses Nachzugs; ich benenne es hier und nicht als Befund.

---

## Was dieser Lauf nicht prüfen konnte

- **`make full-smoke` ist nicht gefahren** — Begründung in §1.4: sein Gegenstand (der emittierte
  Baum) ist von einer Markdown-Änderung nicht berührt, und Runde 1 hat ihn über demselben Code
  grün gefahren. Die Wirkungs-Zusagen habe ich am E2E-Code gelesen.
- **Die Mutation der §1.3-Sonde ist nur über `make test-go` gefahren.** Ob die E2E-Idempotenz-Sektion
  die zwei `slice-mv`-Dateien ebenfalls nicht driftet, ist **gelesen** (sie driftet `README.md`,
  Rollen-Typ, `Makefile`, Feldliste) und nicht unter der Mutation gefahren.
- **Die „setzbar“-Zusage in der Form „ein anderer Wert kommt an“** ist nicht von einem listed Sensor
  gefahren: die zwei Go-Wächter prüfen Text, der E2E die Wirkung der **Vorgabe**. Am echten Fragment
  gemessen hat sie die Review-Runde 2 (§5 der Messungen dort) — ein Lauf-Beleg, den ich als solchen
  zitiere und nicht wiederhole.
- **Die roten Richtungen des E2E-Zweigs „unsauberer Arbeitsbaum“** (§2.3, letzte Zeile) sind nicht
  vorgeführt; gefahren ist der Fall selbst in jedem E2E-Lauf.
- **Die Kontext-Trennung der zwei Review-Läufe** (Modul 8) — kein Sensor dieses Repos liest sie.
- **Die Closure** — §7, Register, die drei §6-Ausgänge, der `git mv`: Planner. Die drei
  Ausgangs-Platzhalter des §6 stehen unverändert im Plan.
- **F-7** ([`MR-057`](../../harness/conventions.md) §Grenze) und die Wellen-Closure samt viertem
  Mitglied: nicht Gegenstand.

## Verdikt

**Der Doku-Punkt trägt — und mit ihm ist die letzte der Runde-1-Verletzungen geschlossen.** Die neue
Section `## Im gebootstrappten Ziel` führt die zweite Fassung des Werkzeugs samt ihrem Ort, ihrer
Verdrahtung und allen vier Aussagen, die der Plan-Satz und die Planner-Entscheidung verlangen; jede
davon nennt den Sensor, der sie hält, und ich habe die Angaben am Artefakt nachgelesen statt sie zu
übernehmen (§2.1). `make gates` ist **EXIT 0** über `c6616447` (§1.1).

**Die drei Einschränkungen des Implementers sind alle drei richtig in ihrer Richtung**, und die
genannten Träger sind die richtigen (§2.2): die Command-Nennung hält `make test-go` (der E2E hält
sie nicht), das Skript wird von keiner Stufe gedriftet, und die Präfix-Formen-Breite hängt am
Rumpf-Vergleich der bats-Stufe, weil der E2E im Ziel **eine** Form fährt. Zwei davon sind an der
Vorlage gemessen, nicht geglaubt.

**§3.6:** die Angabe des Implementers zum `d-check:ignore`-Marker ist in **beiden** Richtungen
bestätigt (ohne Marker EXIT 2 mit `codepath-missing` an genau diesem Pfad, mit ihm grün, §1.2).
**Eine Grenze bleibt:** die Aussage „jeder Bootstrap schreibt das Fragment kanonisch neu“ ist wahr
und unbewacht — gemessen mit einer Sonde in `/tmp`, die der einzige rote Punkt ist (§1.3, V-6).
**§3.7: kein Verstoß** — keine Befund-Kennung, keine Slice-Nummer, kein Lauf-Protokoll, keine
Ziffer ohne Kommando (§2.4).

**Verbleibende DoD-Verletzungen: keine.** Die offenen Punkte sind Planner-Arbeit (Closure) bzw.
liegen beim Architect (F-7). Die fünf Befunde dieser Runde sind INFO und keine Verletzung — vier
Präzisierungen an der Section, einer am DoD-Wortlaut (§4).

Dieser Report ist ein **Lauf-Beleg** — er wird über Läufe hinweg nicht wieder gelesen und ersetzt
keine Closure (Modul 11).
