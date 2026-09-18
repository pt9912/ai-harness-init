# ADR-0058: Der Träger eines adoptierten Repos kommt per Fetch aus dem gepinnten Release — ein eigenes Target, kein Stempel

**Status:** Accepted

**Datum:** 2026-09-18

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (der Träger
entsteht heute allein im Bootstrap-Lauf; der Fetch macht ihn mit einem Kommando
nachholbar, ohne zweiten Bootstrap von außen),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Version +
sha256 gepinnt, fail-closed gekoppelt — dasselbe Muster wie Baseline- und
d-check-Pin),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (*„die
Laufzeit beim Bootstrap braucht nur git + docker"* — die Grenze, an der der
Transport-Weg unten entschieden wird),
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die
Plattform-Matrix der Release-Assets; der Fetch wählt das Asset seiner Plattform),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — Festlegung 4:
die Fähigkeit liegt, wo der Träger liegt, erreichbar über ein emittiertes
Nicht-Gate-Fragment, das nichts an `GATE_CHECKS` hängt und in keiner
Prerequisite-Kette steht; ihr Verhältnis zu dieser Entscheidung steht in
Festlegung 5),
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 5(b): der Träger liegt gitignored, ein frischer Klon hat ihn nicht; diese
Grenze bleibt, bis der Fetch oder ein Bootstrap-Lauf läuft),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — Festlegung 3: `harness/mk/*.mk`
ist tool-eigen und **konvergent**; die Klasse des neuen Fragments folgt dieser Wurzel,
bestätigt in [ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) Festlegung 1),
[ADR-0004](0004-durchsetzungs-emission.md) (**Accepted** — die emittierte Mechanik
liegt in `bash`/`awk`; der Fetch-Rezept-Kern fällt unter dieselbe Laufzeit-Grenze),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(dasselbe Pin-Muster: Netz nur bei dem einen Aufruf, kein Gate),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein
Erwartungswert)

**Schärft:** `—` — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum. Die
Komponenten-Sicht führt den Bootstrap und seine Phasen, nicht den
Wiederherstellungs-Weg eines gitignorierten Trägers; keine Festlegung unten bewegt
eine `ARC-*`-Zeile und keine Anforderung des Lastenhefts — die Setzung, die den
Gegenstand entscheidet, trägt der Auftraggeber (2026-09-18), nicht der Vertrag.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Was die Entscheidung auslöst

Der Träger eines gebootstrappten Ziels liegt im gitignorierten Zustands-Bereich
(`.harness/state/bin/ai-harness-init`); ein frischer Klon hat ihn nicht
([ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(b)),
und [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 hält als
Wiederherstellungs-Weg den erneuten Tool-Lauf fest. Der Slice
`slice-traeger-per-fetch-aus-dem-release` trägt zwei Fragen an den Architect, die
diese Entscheidung beantwortet: **welches Release wird gepinnt, und wo steht der
Pin** — und **wo lebt der Fetch**. Die Richtung selbst — Fetch aus dem gepinnten
Release, gegen „Binary einchecken" und „Quelle emittieren" — ist die Setzung des
Auftraggebers vom 2026-09-18; diese Entscheidung formt sie aus.

### Die Fassungs-Lage, gemessen

Zwei Messungen tragen die Abwägung, beide neben ihrem Kommando:

- **Das Release `v0.1.1` trägt sechs Plattform-Assets** und ist der neueste Tag:

  ```sh
  gh release view v0.1.1 --json tagName,assets \
    --jq '{tag:.tagName,assets:(.assets|length)}'   # {"tag":"v0.1.1","assets":6}
  ```

- **Das Werkzeug kennt seine eigene Fassung nicht.** Der Einstiegspunkt führt kein
  `version`-Flag und keine Fassungs-Konstante — die `version`-Bezeichner dort
  lösen Toolchain-Pins je Sprache auf (`SKEL_<LANG>_VERSION`), nicht die Fassung
  des Werkzeugs selbst:

  ```sh
  grep -rcE '"version"|--version' cmd/ai-harness-init/main.go   # 0
  ```

Die Frage dahinter: Der Träger eines Ziels sollte zur Werkzeug-Fassung passen, die
das Ziel gebootstrapped hat. Ein Stempel-Entwurf — der Bootstrap-Lauf schreibt
seine eigene Fassung als Pin ins Ziel — setzt erstens eine Fassungs-Fläche am
Werkzeug voraus, die nicht existiert (Messung oben), und zweitens eine
Schreibstelle, die sie hält. Beide stehen zur Wahl nicht offen: Die Emission legt
das Ziel-Fragment **konvergent** ab (Wurzel `harness/mk/*.mk`,
[ADR-0007](0007-bootstrap-phasen.md) Festlegung 3) — ein Re-Lauf schreibt den
Pin-Default **kanonisch neu**. Ein in eine konvergente Datei gestempelter Wert
hätte keine Lebensdauer über den nächsten Re-Lauf hinaus; ihn daneben in einem
zweiten, adopter-eigenen Ort zu halten, wäre eine zweite Quelle für denselben
Zustand, die driftet.

### Die Fragment-Lage

Das Fragment der Wellen-Archivierung ist emittiert und trägt seinen Vertrag im
Kopf: `DER AUFRUF BEWEGT, LOESCHT UND COMMITTET IM VERSIONIERTEN BAUM DIESES
REPOS … Er laeuft nur auf ausdruecklichen Aufruf, nie nebenbei`
(`internal/emit/templates/enforce/archivierung.mk`). Sein Fehlt-Fall ist gemessen:
fehlt der Träger, sagt das Fragment das und endet erfolgreich
([ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 4); die
Stufe in [`make full-smoke`](../../../harness/sensors/full-smoke.md) misst genau
das am realen Ziel. Der Fetch führt eine **andere** Klasse aus: er lädt aus dem
Netz, verifiziert einen Digest und legt eine Datei in einem gitignorierten
Bereich — er berührt den versionierten Baum nicht. Und er bedient **alle**
Konsumenten des Trägers (`archive-welle`, `span-report`, `span-clean`,
`hook-overhead`), nicht einen.

### Die Transport-Lage

[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) hält
die Laufzeit auf `git + docker` und die emittierten Ziel-Repos auf
make/docker-getrieben. Ein Download braucht ein Transport-Werkzeug; auf dem Host
wäre `curl`/`wget` eine Abhängigkeit außerhalb dieser Menge. Im Ziel existiert der
Träger zum Zeitpunkt des Fetch **nicht** — der Download kann nicht vom Werkzeug
selbst gefahren werden, wie es der Baseline-Fetch tut (`internal/fetch` läuft im
Binär). Der Transport steht darum nicht frei.

## Entscheidung

**Wir pinnen `v0.1.1` als Release-Quelle des Fetch, führen den Pin kanonisch im
Dogfood-Makefile und als Default in der Emission, stempeln nicht, und geben dem
Fetch ein eigenes Target in einem eigenen Fragment — ohne Prerequisite.** Fünf
Festlegungen.

**1. Der Pin: `v0.1.1` samt sha256 je Asset, kanonisch im Dogfood-Makefile,
gespiegelt als Default in der Emission, fail-closed gekoppelt.** Der Pin folgt dem
Muster der drei bestehenden Pin-Stellen (`BASELINE_TAG`/`BASELINE_ZIP_SHA256` als
kanonisches Makefile-Paar, gespiegelt im Emitter, von einem Test der Klasse
`test/sources-pin.bats` gegen das Makefile-Paar gehalten): das Makefile führt
`TRAEGER_TAG ?= v0.1.1` und die sha256-Werte der sechs Assets, der emittierte
Fragment-Default führt dieselben Werte als überschreibbare Variablen, und ein Test
hält jede Stelle gegen die kanonische. `v0.1.1` trägt die sechs Assets der
Plattform-Matrix ([`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix),
Messung in §Kontext); der Fetch wählt das Asset seiner Plattform und verifiziert
seinen Digest **vor** der Ablage — eine Abweichung bricht ab, ohne den Träger zu
legen.

**2. Kein Stempel.** Das Werkzeug kennt seine Fassung nicht (Messung in §Kontext);
eine Stempel-Fläche am Werkzeug wäre neue öffentliche Oberfläche für einen Wert,
der in eine konvergente Datei geschrieben würde und den nächsten Re-Lauf nicht
überlebte. **Der Fassungs-Fit wird prozedural getragen:** der Release-Schnitt —
der wellenlose Folge-Posten, den der Slice-Plan als Voraussetzung benennt —
koppelt Pin und Werkzeug-Fassung im selben Commit; solange er das tut, führt ein
Ziel, das von einer Fassung gebootstrapped wurde, einen Pin, der zur jüngsten
Release-Fassung passt, und ein Re-Lauf heilt ihn auf die Fassung des letzten
Laufs. **Bricht die Kopplung, bricht der Aufruf am gepinnten Stand nicht laut.**
Der Unterkommando-switch des Trägers führt vier Fälle und keinen Default
(`grep -c 'case "' cmd/ai-harness-init/main.go` → 4; daß kein Default-Zweig folgt, trägt die Lektüre des Switches — Zeilen 558–570 — und kein Muster-Grep); ein Aufruf, dessen
Unterkommando der Träger nicht führt, fällt in den Init-Pfad statt mit einem
Fehler zu brechen. Der laut-Bruch ist die Zusage an den Release-Schnitt aus
Folgepflicht 3: er pinnt einen Stand, der die Sperren im Dispatch führt — erst
ab ihm bricht ein Fassungs-Bruch beim Aufruf mit einem Fehler statt still zu
starten.
**3. Der Fetch lebt in einem eigenen Fragment mit eigenem Target, ohne
Prerequisite.** Das Ziel bekommt `harness/mk/traeger.mk` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) --> — konvergent nach
[ADR-0007](0007-bootstrap-phasen.md) Festlegung 3, nichts an `GATE_CHECKS`, in
keiner Prerequisite-Kette — mit dem Target `traeger-fetch`; der Dogfood trägt
dasselbe Target in seinem Makefile, mit denselben Pin-Variablen. **Nicht** eine
Erweiterung von `archivierung.mk`: dessen Kopf trägt den Vertrag der Archivierung
(versionierter Baum, nur auf ausdrücklichen Aufruf, nie nebenbei), und ein Fetch
unter ihm würde einen zweiten Vertrag in einen Kopf schreiben, den der Re-Lauf
gemeinsam heilt — und läge beim falschen Eigentümer, denn der Fetch bedient alle
Konsumenten des Trägers, nicht die Archivierung allein. **Kein Prerequisite an
`archive-welle`** — weder im Ziel-Fragment noch im Dogfood-Makefile: ein
Prerequisite würde die gemessene Fehlt-Fall-Zusage still ändern („fehlt der
Träger, sagt das Fragment das und endet erfolgreich" — nach einem Prerequisite
würde derselbe Aufruf erst einen Netz-Download versuchen). Der Fetch steht auf
ausdrücklichen Aufruf wie jede Nicht-Gate-Mechanik dieser Klasse.

**4. Der Transport läuft im gepinnten Docker-Image, nicht auf dem Host.** Download
und Digest-Verifizierung laufen in einem Container mit gepinntem Image-Digest —
dieselbe Pin-Disciplin wie die übrigen Bilder des Repos. Damit bleibt
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) unberührt:
der Host braucht weiter nur `git`, `docker` und GNU `make`. Ein `curl`/`wget` auf
dem Host wäre eine vierte Abhängigkeit und würde die Anforderung brechen; im Bild
ist der Transport ein Werkzeug-Aufruf unter den gepinnten, wie jeder andere.

**5. Verhältnis zu [ADR-0033](0033-wellen-archivierung-als-unterkommando.md):
Schärfung, kein `Supersedes`.** Jene Festlegung 4 hält den Wiederherstellungs-Weg
als den erneuten Tool-Lauf fest; diese Entscheidung ergänzt **einen zweiten Weg am
gleichen Ort** — `make traeger-fetch` im Ziel — und lässt jede übrige Festlegung
dort in Kraft: die Fähigkeit liegt, wo der Träger liegt; das Fragment ist
Nicht-Gate-Mechanik; der fehlende Träger ist kein Fehler des Repos. Die Grenze aus
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(b)
bleibt mit derselben Reichweite: ein frischer Klon hat den Träger nicht, bis der
Fetch oder ein Bootstrap-Lauf läuft — der Fetch macht die Grenze mit einem
Kommando überwindbar, er hebt sie nicht auf.

## Verglichene Alternativen

Regeln dieser Sektion: **mindestens drei Optionen mit Pro/Contra** — „nichts tun"
ist eine davon (Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR)).

| Option | Pro | Contra |
|---|---|---|
| A — **Stempel: der Bootstrap-Lauf schreibt seine eigene Fassung als Pin** | der Fassungs-Fit wäre konstruktiv statt prozedural; der Träger trägt exakt die Fassung des bootstrapenden Werkzeugs | das Werkzeug kennt seine Fassung nicht (gemessen, §Kontext) — der Stempel erfordert zuerst eine neue Fassungs-Fläche am Werkzeug samt Release-Kopplung; der Stempel würde in eine **konvergente** Datei schreiben und den nächsten Re-Lauf nicht überleben; ein adopter-eigener Nebensortierer für den gestempelten Wert wäre eine zweite Quelle für denselben Zustand |
| B — **Fetch als Erweiterung von `archivierung.mk`, als Prerequisite an `archive-welle`** | ein Fragment weniger; der Fehlt-Fall des Trägers würde sich selbst heilen | der Kopf des Fragments trägt den Vertrag der Archivierung — ein zweiter Vertrag in demselben Kopf driftet beim nächsten Re-Lauf mit; ein Prerequisite ändert die **gemessene** Fehlt-Fall-Zusage still (Exit 0 mit Meldung wird zu einem Netz-Download-Versuch); der Fetch läge bei einem von vier Konsumenten statt beim Träger selbst |
| C — **Binary einchecken** (vom Auftraggeber verworfen) | kein Netz, kein Pin, kein Transport | ein Binär-Artefakt im versionierten Baum — Plattform-Matrix im Repo, Binär-Drift gegen die Quelle, und der Zustands-Bereich wäre genau damit zweitrangig; Setzung vom 2026-09-18 trifft die Richtung |
| D — **Quelle emittieren und im Ziel bauen** | der Träger wäre immer die Quelle, kein Fassungs-Drift | das Ziel kompiliert nicht ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): make/docker-getrieben, keine Sprachlaufzeit) — ein Bau-Schritt im Ziel wäre genau der, den [ADR-0007](0007-bootstrap-phasen.md) vor der Doc-Chain ausschließt, und [ADR-0003](0003-go-native-binaries.md) wählt native Binaries als Vertriebsform |
| E — **nichts tun: der Fehlt-Fall bleibt nur per erneuertem Bootstrap behebbar** | keine Änderung; der Bestand läuft | der Fehlt-Fall ist heute gemessen und benannt, aber nur durch einen Bootstrap-Lauf **von außen** behebbar — ein Adopter ohne das Werkzeug auf dem Host bleibt bei „die Bedingung ist nicht eingetreten", obwohl das Release die Fähigkeit längst trägt |
| **F — fester Pin im emittierten Fragment, eigenes Target, Transport im Bild (gewählt)** | der Fehlt-Fall wird mit einem Kommando behebbar; das Pin-Muster ist etabliert (drei Stellen fahren es); kein neues Vertriebsstück — das Release mit seinen sechs Assets existiert; [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) bleibt unberührt | der Fassungs-Fit ist prozedural getragen, nicht konstruktiv — zwischen zwei Releases liegt der Träger hinter der bootstrapenden Fassung (still startend am gepinnten Stand, Festlegung 2); ein weiterer Pin (Transport-Bild) kommt dazu; der Fetch braucht Netz an genau diesem Target |

## Konsequenzen

- **Positiv:** Ein frischer Klon eines adoptierten Repos holt den Träger mit einem
  Kommando nach — ohne zweiten Bootstrap-Lauf von außen, ohne Bau im Ziel. Der
  gemessene Fehlt-Fall bleibt unverändert bestehen und wird behebbar.
- **Positiv:** Das Pin-Muster der drei bestehenden Stellen trägt den vierten; kein
  neues Muster, keine neue Artefakt-Klasse, kein Vertriebskanal.
- **Negativ:** Der Fassungs-Fit hängt an der Release-Disziplin, nicht an einer
  Konstruktion. Der Träger kann hinter der Fassung liegen, die das Ziel
  gebootstrapped hat; bis zum Release-Schnitt fällt der Bruch still (Festlegung 2), und er fällt auf den Adopter.
- **Negativ:** Ein weiterer gepinnter Wert-Paar (Release-Tag + Digests) und ein
  gepinntes Transport-Bild — jede Freshness-Achse hat einen Pin mehr zu bewegen.
- **Negativ:** Das Target braucht Netz. Es ist kein Gate, hängt an keiner
  Prerequisite-Kette und läuft in keinem `make gates` — der Netz-Bedarf steht in
  seiner Doku-Zeile.
- **Folgepflicht 1 — die Pin-Kopplung wird von einem Test der Klasse
  `test/sources-pin.bats` gehalten.** Ein Sprung, der eine Stelle stehen lässt,
  färbt rot — dieselbe Kopplungs-Klasse wie die drei bestehenden Pin-Stellen.
- **Folgepflicht 2 — die Fehlt-Fall-Zusage wird im bats-Test gemessen**, nicht nur
  behauptet: Exit 0, nennt das Fehlende, schreibt nichts — und der Negative-Fall
  der Digest-Verifizierung bricht unter der geschwächten Zusicherung (Abweichung
  bricht, aber der Träger bleibt liegen) nicht grün.
- **Folgepflicht 3 — der Release-Schnitt wird als Folge-Posten geführt.** Er ist
  der Träger der Kopplung aus Festlegung 2; ohne ihn driftet der Pin von der
  Werkzeug-Fassung bei jedem Werkzeug-Fortschritt, der ein Unterkommando ändert.
- **Folgepflicht 4 — die Doku-Zeile trägt die Klasse und den Netz-Bedarf.**
  [`harness/README.md`](../../../harness/README.md) Werkzeuge-Tabelle: kein Gate,
  mit dem Halbsatz, was es stattdessen tut; die E2E-Stufe trägt Kopfzeile und
  Deklaration im Stufen-Muster des Erzeugers.
- **Folgepflicht 5 — der Fehlt-Fall des Trägers wird vom Fetch nicht angetastet.**
  Weder Prerequisite noch Automatismus: die Zusage „Exit 0, nennt das Fehlende,
  schreibt nichts" bleibt stehen; der Fetch ist der ausdrückliche Weg aus dem
  Zustand, den sie benennt.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make test` (bats) | **Pin-Kopplung:** jede Pin-Stelle (Makefile, Emitter-Default, Fragment-Default) trägt dieselben Werte; ein Test der Klasse `test/sources-pin.bats` hält sie gegen das kanonische Makefile-Paar — ein Sprung, der eine Stelle stehen lässt, färbt rot | `make test` |
| `make test` (bats) | **Digest fail-closed:** eine Digest-Abweichung bricht den Fetch ab, ohne den Träger zu legen; unter der geschwächten Zusicherung (Abweichung bricht, Träger bleibt liegen) bleibt der Negative-Fall rot | `make test` |
| `make test` (bats) | **Fehlt-Fall unverändert:** ohne Träger und ohne Fetch-Aufruf bleibt der Zustand Exit 0 mit Meldung, die das Fehlende nennt, und schreibt nichts — der Fetch ist kein Prerequisite und kein Automatismus | `make test` |
| `make full-smoke` | **E2E am realen Ziel:** frischer Klon ohne Träger → `traeger-fetch` → Digest verifiziert → `archive-welle` läuft; die Stufe trägt Kopfzeile und Deklaration und steht nach `make e2e-abdeckung` in der Sicht | `make full-smoke` |

## Re-Evaluierungs-Trigger

- **Wenn das Werkzeug eine Fassungs-Fläche bekommt** (ein `version`-Flag oder eine
  Fassungs-Konstante, die der Bootstrap-Lauf lesen kann), ist der Stempel aus
  Alternative A gegen diese Entscheidung neu zu wägen — der tragende Grund von
  Festlegung 2 entfiele.
- **Wenn ein Ziel einen Träger legt, der ein vom Fragment gerufenes Unterkommando
  nicht führt, bricht der Aufruf am gepinnten Stand still** (er startet den
  Init-Pfad — Festlegung 2). Trägt der laut-Bruch nach dem Release-Schnitt nicht —
  ein gepinnter Stand führt die Sperren im Dispatch nicht, oder ein Bruch fällt
  danach still —, ist der Release-Schnitt zu verschärfen oder der Fassungs-Fit konstruktiv zu bauen.
- **Wenn das Release keinen Signier-Schritt bekommt und ein Digest-Angriff zum
  Befund wird** (Feedforward — kein Sensor dieses Repos): der Fetch prüft den
  Digest, nicht die Signatur; die Grenze steht im Slice-Plan als Bestand und wird
  hier bestätigt, bis sie bricht.
- **Wenn [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
  die Host-Abhängigkeiten erweitert**, ist der Transport aus Festlegung 4 neu zu
  wägen — dann trägt ein Host-Werkzeug den Download billiger als ein Bild.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-18 | **Proposed** | Architect-Lauf zu `slice-traeger-per-fetch-aus-dem-release`. Die zwei Fragen des Slice-Plans entschieden: Pin `v0.1.1` kanonisch im Makefile und als Emissions-Default, kein Stempel (das Werkzeug kennt seine Fassung nicht — gemessen), eigenes Fragment `harness/mk/traeger.mk` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) --> mit eigenem Target `traeger-fetch` ohne Prerequisite, Transport im gepinnten Bild. Der Acceptance-Trigger steht unten |
| 2026-09-18 | Überarbeitet, weiter **Proposed** | Reviewer-Runde `2026-09-18-slice-traeger-per-fetch-aus-dem-release-runde-1.md` (Commit `2a7b6aae`), Verdikt zum Implementer-Diff *merge-blockierend nein*; zwei Befunde an dieser Datei im `Proposed`-Fenster behoben. **F-3 (MEDIUM):** Festlegung 2 und Re-Evaluierungs-Trigger 2 setzten einen laut-Bruch voraus, den der gepinnte Stand nicht trägt — der Unterkommando-switch des Trägers führt keinen Default, ein Aufruf ohne das Unterkommando startet den Init-Pfad; der laut-Bruch ist jetzt die Zusage an den Release-Schnitt (Folgepflicht 3), die Contra-Zelle der gewählten Alternative und die Konsequenzen tragen dieselbe Korrektur. **F-5 (LOW):** die Paraphrase von [ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 trug das Verbatim-Wort nicht — geglättet. **F-6 (INFO)** hängt an keinem Text dieser Datei. Den Accept-Übergang trägt nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 eine erneute Runde derselben prüfenden Rolle |
| 2026-09-18 | **Accepted** | Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 ist die Reviewer-Runde `2026-09-18-adr-0058-glaettung-nachrunde.md` — die Nachrunde zur Glättung trug F-3 und F-5 als behoben, die Bestätigungsrunde derselben prüfenden Rolle meldet READY FOR ACCEPT (Bullet-Zählung 4, Trigger 2 mit beiden Ausgängen, N-3-Lektüre-Kennzeichnung; Commit `9a586519`). **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0058`. |
**Acceptance-Trigger:** Diese Entscheidung wird `Accepted`, wenn eine
Reviewer-Runde sie gegen [ADR-0033](0033-wellen-archivierung-als-unterkommando.md),
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) und
[ADR-0007](0007-bootstrap-phasen.md) auf Konsistenz geprüft hat und ihr Report ohne
blockierenden Befund in `docs/reviews/` liegt — dieselbe Aufteilung wie in
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) §Der Acceptance-Trigger,
Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md).
Bis dahin ist sie ein Architect-Verdikt und als solches das Übergabe-Artefakt, das
der Implementer des Slices als Constraint liest.

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0058` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).