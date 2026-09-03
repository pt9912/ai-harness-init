# ADR-0033: Der Träger der Wellen-Archivierung ist das Produkt-Binär — die Operation wird sein Unterkommando

**Status:** Proposed

**Datum:** 2026-09-03

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
emittierte Anleitung — sie verlangt die Commands, **nicht** das Werkzeug hinter ihrem Schritt 4;
daran hängt, dass Festlegung 4 eine Wahl ist und keine Vertragspflicht),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
benanntes Target läuft auf frischem Checkout — und fährt das, was daneben steht),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die gepinnten Bilder; der
gewählte Weg braucht eines weniger),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (das Zielrepo bleibt
über `bash + git + docker` geschlossen — die Grenze, an der zwei der verglichenen Wege scheitern),
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (*„Erstklassig auf allen
dreien ohne WSL2-Zwang"* — die Achse, auf der der Skript-Weg auf der emittierten Ebene schmaler ist
als der gewählte),
[ADR-0003](0003-go-native-binaries.md) (**Accepted** — native Binaries als Vertriebsform und der
ausdrückliche Verzicht auf ein eigenes OCI-Image als *Vertriebsmittel*),
[ADR-0004](0004-durchsetzungs-emission.md) (**Accepted** — die Laufzeit-Grenze, an der die
emittierte Mechanik in `bash`/`awk` gehalten wird),
[ADR-0005](0005-ziel-repo-distribution.md) (**Accepted** — das Zielrepo bekommt die **volle**
Baseline inklusive Templates; das ist die Quelle, aus der Festlegung 3 auch im Ziel schöpft),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — kein Bauschritt und keine Toolchain im Ziel
vor dessen Doc-Chain; der Grund, an dem der Modul-Weg scheitert),
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** — die Präzedenz:
Träger und Unterkommando, samt der Grenze in Festlegung 5, an der die Reichweite ins Ziel endet),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (**Accepted** — der emittierte
Anweisungssatz gehört der ausführenden Rolle; die Grenze, an der Festlegung 4 endet),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (**Accepted** — Festlegung 3,
*Kennung statt Adresse* im Artefakt, das unveränderlich wird; diese Entscheidung wendet sie auf
einen Zielbaum an, den jene nicht führt),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(die committet vendored Baseline — die Quelle der Stub-Vorlagen),
[`MR-041`](../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)
(Referenz statt Kopie für wiederkehrende Vorlagen — die Regel, die Festlegung 3 anwendet),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert; keine ist ein Erwartungswert)

**Schärft:** `—` — Prozess- und Werkzeug-Entscheidung ohne Spec-Stratum. Die Komponenten-Sicht
führt den **Bootstrap**, nicht die Unterkommandos des Trägers: sie nennt heute keines
(`grep -c 'span-emit\|span-report\|archive-welle' spec/architecture.md` → **0**), und ein drittes
bewegt darum keine `ARC-*`-Zeile. Das Technik-Stratum nennt Unterkommandos allein in seinem
Telemetrie-Abschnitt und über dessen Gegenstand. **Das Vertrags-Stratum ist nicht berührt:** keine
Festlegung bewegt eine Anforderung — siehe §Was der Vertrag hier nicht tut.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Was die Entscheidung auslöst

Die adoptierte Baseline `v5.18.0` schreibt in `modul-06-roadmap.md`
§Wellen-Closure-Prozedur (Modul 6), Schritt 4 die Archivierung der Zeitdokumente einer
geschlossenen Welle vor und sagt über ihren Träger einen Satz, verbatim: *„Ob das Archiv
vollständig ist, bezeugt nur der Archivierungs-Commit — deshalb gehört die Operation in ein
Werkzeug und nicht in Handarbeit."* **Welches** Werkzeug, sagt sie nicht.

Zwei Antworten liegen heute nebeneinander. Dieses Repo fährt die Operation als **Shell-Helfer**
unter `harness/tools/`, hinter dem Target `make archive-welle`. Das Nachbar-Repo `d-check` fährt
dieselbe Operation gegen dasselbe `docs/plan/planning/`-Layout als **eigenständiges Go-Modul** mit
eigenem `go.mod`, eigenem Dockerfile und eigenem Makefile. Eine dritte Antwort hat in diesem Repo
eine angenommene Präzedenz: [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
hat für die Erfassungsschicht Träger und Fähigkeit getrennt entschieden.

Solange die Frage offen ist, sagt der emittierte Anweisungssatz für Schritt 4 *„Hat dein Repo das
Werkzeug nicht, ist die Bedingung nicht eingetreten"*
(`grep -c 'ist die Bedingung nicht eingetreten' internal/emit/templates/commands/close-welle.md`
→ **1**) — und kein Ziel hat es.

**Das Nachbar-Repo steht in keinem Rang der Source Precedence.** Es trägt hier als **gemessenes
Vorbild** und als Beleg dafür, dass ein Weg gangbar ist — nicht als Begründung. Jede Aussage über
seinen Bestand unten steht neben dem Kommando, das sie liefert.

### Trägt die Präzedenz? — die Prüfung, nicht die Berufung

Drei Teile der Berufung auf [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
sind einzeln geprüft; **zwei tragen, einer trägt so nicht.**

- **Der Träger.** Jene Festlegung 1 sagt verbatim: *„Der Träger ist das ausführbare Bild, dessen
  Lauffähigkeit auf dem Bootstrap-Host der Lauf selbst belegt — das Produkt-Binär."* Sie ist
  umgesetzt: der Bootstrap legt das **laufende** Bild im gitignorierten Zustands-Bereich des Ziels
  ab (`grep -c 'carrierDir = ' internal/emit/enforce.go` → **1**, der Ablageort
  `.harness/state/bin`). **Trägt.**
- **Die Fähigkeit als Unterkommando.** Jene Festlegung 2 sagt verbatim: *„Schreiber und Auswertung
  sind Unterkommandos desselben Trägers — und der Dogfood fährt denselben Einstiegspunkt."* Auch
  sie ist umgesetzt (`grep -c 'case "span-' cmd/ai-harness-init/main.go` → **2**). **Trägt.**
- **„Jedes gebootstrappte Ziel bekommt sie."** **Trägt so nicht** — und die Korrektur steht in
  jener Entscheidung selbst. Festlegung 5(a): *„Kann der Träger nicht abgelegt werden, wird weder
  Träger noch Wrapper noch Hook-Eintrag geschrieben, der Bootstrap nennt den Grund und endet
  erfolgreich."* Festlegung 5(b): *„Er liegt gitignored — ein frischer Klon des Adopter-Repos hat
  ihn nicht, und ein Aufräum-Lauf kann ihn entfernen."* Die richtige Aussage ist ortsgebunden statt
  allquantifiziert: **die Fähigkeit liegt, wo der Träger liegt.** Festlegung 4 unten schreibt genau
  das und nicht mehr.

**Und die Abzählung überträgt sich nicht, wohl aber ihre Kopplung.** Jene Entscheidung zerlegt die
Frage *„wie kommt ein ausführbarer Mechanismus in ein fremdes Repo?"* an der **Herkunft des
ausführbaren Bildes** — ein Kriterium, das eine **Transport**-Frage beantwortet. Die Frage hier ist
zuerst eine andere: *welches Artefakt führt die Operation in dem Repo aus, in dem sie läuft?* Dort
liegt jeder Kandidat lokal vor, und die Transport-Frage ist leer. Das Kriterium unten ist deshalb
ein anderes.

Die zwei Fragen fallen trotzdem **nicht** auseinander, und das ist prüfbar: jedes Mitglied der
Abzählung unten fällt in genau eine Klasse jener Abzählung, und für zwei ihrer vier Klassen ist der
Ausgang dort bereits entschieden (deren Alternativen B und C für *„entsteht im Ziel"*, D und E für
*„wird geholt"*). Es sind darum **eine** Entscheidung und nicht zwei.

### Was der Vertrag hier nicht tut

[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) stand unter einer
Rang-1-Anforderung, die das *Ob* bereits entschieden hatte und nur das *Wie* offen ließ. **Hier
steht keine.**
[`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) verlangt
die drei Workflow-Commands als *Anleitung*; keines seiner Akzeptanzkriterien nennt ein Werkzeug
hinter einem ihrer Schritte. Die Emissions-Frage ist damit eine **Folge der Träger-Wahl**, keine
Vertragspflicht — und keine Festlegung unten dehnt eine Aufzählung des Lastenhefts. Ein Change
Request ist nicht fällig.

### Die Abzählung der Wege — Kriterium zuerst, Mitglieder danach

Das Kriterium ist die **Herkunft des ausführenden Artefakts**: *wird es gebaut, und wenn ja, von
wem in welches Vertriebsstück?* Die Aufteilung ist erschöpfend, weil sie eine Existenz- und eine
Eigentumsfrage kombiniert: entweder es gibt kein Artefakt; oder es gibt eines und wird nicht
übersetzt; oder es wird übersetzt — von uns in ein Vertriebsstück, das schon existiert, von uns in
ein neues, oder von jemand anderem.

**Die Klassen sind erschöpfend, die Mitglieder sind es nie von selbst.** Wer einen weiteren Weg
nennt, ordnet ihn ein und ergänzt die Zeile, statt das Kriterium zu bestreiten. Die dritte Spalte
führt die Achse, an der die Kopplung zu Festlegung 4 hängt: **wie ein Ziel den Weg erreichte**.

| Herkunft | Weg | Reichweite ins Ziel | Ausgang |
| --- | --- | --- | --- |
| **kein Artefakt** | die Operation bleibt Handarbeit | — | die Quelle schließt es selbst aus (*„gehört die Operation in ein Werkzeug und nicht in Handarbeit"*) — Alternative G |
| **kein Bau** | Skript in einer Laufzeit, die das Ziel ohnehin führt (`bash`) | als Text emittierbar — aber der zweite gepinnte Bild-Digest reiste mit | der heutige Stand — **Alternative B** |
| **kein Bau** | Skript in einer Laufzeit, die niemand zusagt (`python`, `node`, `perl`) | keine — [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) hält das Ziel auf `bash + git + docker` | scheitert am Vertrag — Alternative B′ |
| **bestehendes Vertriebsstück** | Unterkommando des Produkt-Binärs | liegt dort, wo der Träger liegt — kein neuer Schritt | **gewählt — Alternative A** |
| **neues Vertriebsstück** | zweites Binär im selben Go-Modul | zweite Selbst-Kopie oder zweiter Kanal | tragfähig, teurer — **Alternative C** |
| **neues Vertriebsstück** | eigenständiges Go-Modul mit eigenem `go.mod`, Bild und Makefile | Quellbaum + Bauschritt im Ziel | das gemessene Vorbild; scheitert an [ADR-0007](0007-bootstrap-phasen.md) — **Alternative D** |
| **neues Vertriebsstück** | eigenes OCI-Bild, das die Operation fährt | zweiter Vertriebskanal | gegen [ADR-0003](0003-go-native-binaries.md) — Alternative E |
| **fremder Bau** | das Werkzeug des Nachbar-Repos direkt aufrufen | keine | eine Verfügbarkeit, die niemand zusagt — Alternative F |

### Was heute gemessen ist

- **Der Shell-Weg ist an seiner tragenden Stelle unbewacht.** Sein Hauptpfad — Einsammeln, Move,
  Commit — braucht `git` und `docker`; das gepinnte bats-Bild führt beides nicht
  (`grep -n '^BATS_IMAGE' Makefile` nennt den Pin), und sein Test-Satz spricht im Kopf selbst aus,
  dass er den Hauptpfad auslässt und nur die reinen Funktionen über synthetischen Proben ruft.
  Automatisiert gedeckt sind diese Funktionen und **sieben** Mutations-Fälle über ihnen
  (`grep -l 'archive-welle' test/mutations/*.sh | wc -l`); der Beleg für die Operation selbst ist
  ein von Hand gefahrener Lauf über ein Scratch-Repo.
- **Der Shell-Weg trägt einen eigenen gepinnten Bild-Digest.** Von vier Pins des Makefile
  (`grep -cE '^[A-Z_]+_IMAGE \?=' Makefile` → **4**) existiert einer allein für das Packen des
  Archivs. Ein Go-Weg schreibt das Zip aus der Standardbibliothek und braucht ihn nicht.
- **Das Vorbild zerlegt die Operation in vier Gegenstände mit eigenen Tests.** Einsammeln,
  Verweis-Nachzug, Stub, Zip — dazu der Einstiegspunkt, zusammen fünf Testdateien
  (`ls /Development/d-check/tools/archive-wave/*_test.go | wc -l` → **5**). Das ist die Messung
  am Vorbild, nicht seine Übernahme als Begründung.
- **Die Stub-Vorlagen liegen im vendored Baum, an beiden Ebenen.** Zwei Dateien
  (`ls .harness/baseline/v5.18.0/templates/docs/plan/planning/archiv-stub-*.template.md | wc -l`
  → **2**), und das Zielrepo bekommt denselben Baum ([ADR-0005](0005-ziel-repo-distribution.md)).
- **Der Hänger-Fall ist keine Randlage.** Ein Wächter, der `docs/reviews/**` aus seinem Suchraum
  nähme, wäre für **68** Report-Dateien blind, die heute Ziel eines Links aus einem *anderen*
  Report sind:
  `for r in docs/reviews/*.md; do rb=$(basename "$r"); grep -rlF -e "]($rb)" docs/reviews/ | grep -v "^$r$"; done | sort -u | wc -l`.

### Annahmen, auf denen diese Entscheidung steht

Kippt eine, kippt die Entscheidung; beide stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Der Träger ist an dem Ort ausführbar, an dem archiviert wird — dieselbe Annahme, die
  [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) als ihre Annahme (a) führt,
  hier aber schwächer beansprucht: die Archivierung ist ein **bedienter** Vorgang zur Closure-Zeit,
  kein Hook je Tool-Call. Wer sie ruft, steht an dem Repo, das archiviert wird.
- **(b)** Das Ziel führt den vendored Baseline-Baum, aus dem die Stub-Form kommt. Fällt das, fällt
  Festlegung 3 im Ziel — nicht im Dogfood, der ihn committet hält
  ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)).

## Entscheidung

**Wir wählen Alternative A: der Träger der Wellen-Archivierung ist das Produkt-Binär, die Operation
sein Unterkommando.** Vier Festlegungen und drei Abnahme-Kriterien.

**1. Der Träger ist das Produkt-Binär; die Archivierung ist sein Unterkommando.** Geltungsbereich:
beide Ebenen — der Dogfood und jedes Ziel, das den Träger führt. `make archive-welle` fährt genau
diesen Einstiegspunkt.

**Der tragende Grund ist der Preis, und er ist dreiteilig — keiner der drei ist ein Beweis.**

- **Der Prüfbereich wächst.** Die vier Gegenstände der Operation — Einsammeln, Verweis-Nachzug,
  Stub, Zip — werden in Go über synthetischen Bäumen prüfbar, im selben gepinnten Bild und mit
  denselben Zielen, die das Repo ohnehin fährt (`make test`, `make lint`, `make mutate`); das
  gemessene Vorbild belegt, dass genau diese Zerlegung Tests trägt. **Was dabei nicht wandert,
  gehört genannt:** der `git`-berührende Teil bleibt außerhalb des Test-Bildes, wie er es beim
  Shell-Weg ist. Der Zugewinn ist die gedeckte Fläche, nicht ihre Vollständigkeit.
- **Ein gepinntes Bild entfällt.** Das Zip kommt aus der Standardbibliothek; der vierte Digest im
  Makefile verliert seinen Gegenstand. Jede Re-Baseline und jede Freshness-Achse hat danach einen
  Pin weniger zu bewegen ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
- **Die Reichweite ins Ziel kostet nichts.** Der Träger liegt dort bereits; ein Unterkommando von
  ihm ist dort, ohne dass ein Emissions-Schritt, ein Vertriebskanal oder eine zweite
  Plattform-Matrix entsteht. Alternative C bezahlte dafür ein zweites Release-Artefakt samt eigenem
  Start-Smoke, D und E einen Bauschritt bzw. einen Kanal, die [ADR-0007](0007-bootstrap-phasen.md)
  und [ADR-0003](0003-go-native-binaries.md) je ausgeschlossen haben.

**Was Alternative C dafür böte, ist der Gegenposten und steht in der Tabelle:** ein Träger, der
**konstruktiv** kein Repo bootstrappen und keine Telemetrie schreiben kann — die kleinste
Fähigkeitsfläche. Die Abwägung fällt wie in
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) zwischen deren G und F, und
aus demselben Grund: gleiche Eigenschaften, höherer Preis. **Neu und darum ausgesprochen ist die
Art der Fläche:** die Erfassung *schreibt* in einen gitignorierten Bereich, die Archivierung
schreibt in den **versionierten** Baum und löscht darin. Wer den Träger startet, hat ab dieser
Entscheidung ein Kommando, das ein fremdes Planning-Verzeichnis umschreibt. Das ist der Preis, und
er steht hier statt in einem Kommentar.

**2. Der Shell-Helfer wird mit dem Port abgelöst — nicht davor und nicht danach.** Solange kein
Unterkommando existiert, ist er der Träger und bleibt unangetastet. Der Lauf, der das
Unterkommando liefert, entfernt ihn samt seinem bats-Satz und lässt `make archive-welle` auf genau
einen Träger zeigen. Zwei Fassungen derselben Operation nebeneinander sind der Zustand, den diese
Festlegung beendet; ein Target, das die eine fährt, während die Doku die andere beschreibt, ist
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene
tiefer.

**Die Mutations-Fälle folgen dem Träger, sie fallen nicht mit ihm.** Ihr Gegenstand — die drei
Einsammel-Klassen, die Stub-Form, der Hänger-Suchraum, der untrackte Baum, der aufsteigende
Verweis — ist eine Eigenschaft der **Operation**, nicht des Skripts. Ein Zahn über einer gelöschten
Datei ist kein halber Wächter, sondern ein falscher; ein Zahn, der ersatzlos verschwindet, verengt
die bewachte Fläche still. Beides ist ausgeschlossen: jeder Fall wandert mit oder wird beim
Entfernen einzeln benannt.

**3. Die Stubs entstehen aus der vendored Vorlage, nicht aus einem im Code formatierten Text.**
Quelle sind die zwei Vorlagen unter `.harness/baseline/<tag>/templates/docs/plan/planning/`, die
die Baseline in `modul-06-roadmap.md` §Wellen-Closure-Prozedur (Modul 6) selbst als Ziel-Form
benennt. Das ist die Anwendung der Regel, die dieses Repo für **jedes** wiederkehrende Artefakt
führt — Referenz statt Kopie
([`MR-041`](../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) —
und keine Ausnahme für den Sonderfall *„das Werkzeug schreibt die Instanz statt eines Menschen"*.

**Zwei Folgen, beide gewollt.** Erstens folgt die Stub-Form dem **Baseline-Stand des archivierenden
Repos**, nicht dem Übersetzungsstand des Werkzeugs: ändert die Baseline die Form, zieht ein
Re-Baseline-Lauf sie nach, ohne dass ein Binär neu gebaut wird. Ein im Code formatierter Text wäre
eine zweite Fassung derselben Form und driftete mit der ersten Änderung — genau die Klasse, die das
Beobachtungs-Register als *geänderte Ableitung, stehengebliebene Zusage* führt. Zweitens **fällt
die Operation geschlossen aus**, wenn die Vorlage fehlt: sie rät keine Form. Das gilt im Ziel
ebenso, wo der Baum aus [ADR-0005](0005-ziel-repo-distribution.md) kommt.

**4. Die Fähigkeit geht ins Ziel — sie liegt, wo der Träger liegt, und ein eigener
Emissions-Schritt entsteht nicht.** Das ist die ortsgebundene Fassung aus §Trägt die Präzedenz,
nicht die allquantifizierte. Ein Ziel erreicht die Archivierung genau dann, wenn sein Bootstrap den
Träger abgelegt hat **und** niemand ihn seither entfernt hat; ein frischer Klon hat ihn nicht
([ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a) und 5(b)),
und wiederhergestellt wird er durch einen erneuten Tool-Lauf.

**Die Erfassungs-Antwort auf den fehlenden Träger trägt hier nicht.** Dort schweigt ein Wrapper und
endet erfolgreich — richtig für einen fail-open-Beobachter. Die Archivierung schreibt und löscht;
Schweigen wäre der teurere Fehlerfall. Fehlt der Träger, **sagt** das Kommando es und färbt nichts
rot. Ein ziel-seitiger Wächter über der Anwesenheit ist aus demselben Grund ausgeschlossen wie
dort: er machte jeden frischen Klon out-of-the-box rot.

**Was diese Festlegung nicht entscheidet:** den **Text** des emittierten Anweisungssatzes. Er ist
ein Rollen-Anweisungssatz und gehört nach
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) der ausführenden Rolle; diese
Entscheidung stellt die Erreichbarkeit her, sie schreibt den Satz nicht.

### Drei Abnahme-Kriterien, je mit dem Fall, an dem sie brechen

Sie sind am Shell-Weg **rot gesehen** worden und binden den Träger, nicht seine Sprache
([`AGENTS.md`](../../../AGENTS.md) §3.6).

1. **Der fail-closed-Wächter gegen einen lebenden Verweis auf einen zu löschenden Review-Report
   schließt `docs/reviews/**` nicht aus.** *Bricht, wenn:* ein Report, der **bleibt**, einen
   Report verlinkt, der ins Archiv geht — dann zeigt ein lebender Verweis ins Leere, und das Gate
   sieht es erst nach dem Commit. Der Suchraum ist nicht theoretisch: **68** Report-Dateien sind
   heute Ziel eines solchen Links (Kommando im Kontext).
2. **Die Sauberkeits-Prüfung deckt untrackte Dateien, und das Staging nennt explizite Pfade statt
   `-A`.** *Bricht, wenn:* eine untrackte Fremddatei im Baum liegt — dann trägt der
   Archivierungs-Commit fremden Inhalt, und die Zusage *„der Archivierungs-Commit bezeugt die
   Vollständigkeit"* ist gebrochen, ohne dass etwas rot wird.
3. **Ein Stub-Verweis der aufsteigenden Form (`../<datei>.md`) wird beim Folgelauf nachgezogen.**
   *Bricht, wenn:* eine zweite Welle archiviert wird und ein Stub der ersten auf ein Geschwister
   zeigt, das dabei eine Ebene tiefer wandert.

### Der Acceptance-Trigger

Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde sie gegen
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
[ADR-0003](0003-go-native-binaries.md) und [ADR-0007](0007-bootstrap-phasen.md) auf Konsistenz
geprüft hat und ihr Report ohne blockierenden Befund in `docs/reviews/` liegt** — die Aufteilung,
die das Baseline-Regelwerk `modul-08-agentenrollen.md` §Rollen-Regeln verbatim vorschreibt:
*„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz; Implementer liest als
Constraint"*. Bis dahin ist sie ein Architect-Verdikt und als solches das Übergabe-Artefakt, das
der Port als Constraint liest; sie ist nicht eingefroren
([`AGENTS.md`](../../../AGENTS.md) §3.4 bindet ab `Accepted`).

### Was diese Entscheidung an sich selbst anwendet

Sie nennt **keine** bewegliche Pfad-Adresse — weder auf ein Artefakt des Planning-Lifecycle noch
auf die Datei, die Festlegung 2 abschafft.
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3 bindet den
Planning-Baum; der Fall hier liegt eine Ebene daneben — ein Artefakt, das unveränderlich wird,
adressiert etwas, das die eigene Entscheidung entfernt. Der Ausgang ist gleich: die Eigenschaft
steht, die Adresse entfällt. **Der Zielbaum ist damit ein anderer, und das ist keine Ausweitung
jener Festlegung**, sondern dieselbe Form, einmal mehr angewandt.

## Verglichene Alternativen

| Option | Pro | Contra |
| --- | --- | --- |
| **A — Unterkommando des Produkt-Binärs (gewählt)** | die vier Gegenstände werden in den Zielen prüfbar, die das Repo ohnehin fährt; ein gepinntes Bild entfällt; die Reichweite ins Ziel entsteht ohne Emissions-Schritt, ohne Kanal und ohne zweite Plattform-Matrix; ein Einstiegspunkt, eine Lint-Config, ein Test-Runner; die Präzedenz aus [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2 ist erprobt (`grep -c 'case "span-' cmd/ai-harness-init/main.go` → **2**) | der abgelegte Träger bekommt ein Kommando, das den **versionierten** Baum eines fremden Repos umschreibt und darin löscht — eine größere Fähigkeitsfläche als der gitignorierte Schreiber von [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md); der `git`-berührende Teil bleibt außerhalb des Test-Bildes; zwei Review-Runden, ein bats-Satz und sieben Mutations-Fälle des Shell-Wegs werden retiriert |
| **B — Shell-Helfer je Dogfood-Repo (Status quo)** | existiert, ist zweimal reviewt und trägt sieben Mutations-Fälle (`grep -l 'archive-welle' test/mutations/*.sh \| wc -l`); als **Text** emittierbar, und `bash` steht in [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten); kein Wachstum des Produkt-Binärs | seine tragende Hälfte ist ungetestet — der Hauptpfad braucht `git` und `docker`, die das gepinnte bats-Bild nicht führt; er verlangt einen **eigenen** gepinnten Bild-Digest, der im Ziel unser Pin im fremden Repo wäre; auf der `windows`-Hälfte von [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) braucht er eine Shell, die *„ohne WSL2-Zwang"* nicht zugesagt ist |
| B′ — Skript in `python`/`node`/`perl` | mächtiger als `bash`, ohne Kompilat | verlangt eine Laufzeit, die [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) dem Ziel nicht zusagt — dieselbe Grenze, an der [ADR-0004](0004-durchsetzungs-emission.md) den Guard in bash/awk hält |
| **C — zweites Binär im selben Go-Modul** | dieselben Prüf- und Pin-Eigenschaften wie A; der Träger könnte **konstruktiv** kein Repo bootstrappen und keine Spans schreiben — die kleinste Fähigkeitsfläche | ein zweites Release-Artefakt mit eigenem Start-Smoke je Plattform ([`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)); ins Ziel käme es nur über eine zweite Selbst-Kopie oder einen zweiten Kanal, also über genau die Wege, die [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) für ihre Alternativen D und E verworfen hat. Gleiche Eigenschaften, höherer Preis |
| **D — eigenständiges Go-Modul (das gemessene Vorbild)** | portabel per Konstruktion: kein Import aus dem Repo, in dem es liegt, und das Verzeichnis ist in jedes Repo mit demselben Layout kopierbar; ein eigener Test je Gegenstand (`ls /Development/d-check/tools/archive-wave/*_test.go \| wc -l` → **5**) | ein zweites `go.mod`, ein zweites Bild und ein zweites Makefile — ein Bau- und Lint-Bereich, den die Gates dieses Repos nicht von selbst erreichen ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)); ins Ziel käme es als **fremder Quellbaum samt Bauschritt und Aktualisierungsweg** — das ist [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Alternative C, verworfen gegen [ADR-0007](0007-bootstrap-phasen.md) und [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) |
| E — eigenes OCI-Bild, das die Operation fährt | digest-gepinnt und damit reproduzierbar; der Transport-Mechanismus ist im Repo erprobt | verlangt genau das eigene OCI-Image als *Vertriebsmittel*, auf das [ADR-0003](0003-go-native-binaries.md) verzichtet hat, mit derselben Begründung, die dort steht |
| F — das Werkzeug des Nachbar-Repos direkt aufrufen | null Bau, null Pflege, sofort verfügbar | setzt einen Pfad außerhalb dieses Repos voraus, den kein Checkout herstellt und keine Quelle zusagt — auf der emittierten Ebene gar nichts; das Vorbild ist ein Beleg, keine Abhängigkeit |
| G — nichts tun: die Operation bleibt Handarbeit | kein Artefakt, keine Entscheidung | die adoptierte Baseline schließt es aus (*„gehört die Operation in ein Werkzeug und nicht in Handarbeit"*), und das Ziel bliebe bei *„die Bedingung ist nicht eingetreten"* |

## Konsequenzen

- **Positiv:** Die Operation liegt in der Sprache, dem Bild und den Zielen, die das Repo ohnehin
  fährt; ein gepinnter Bild-Digest entfällt; die emittierte Ebene bekommt die Fähigkeit ohne neuen
  Emissions-Schritt, ohne Vertriebskanal und ohne zweite Plattform-Matrix. Die Aufzählung aus
  [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) wächst
  nicht.
- **Negativ, und das ist der Preis:** der Träger trägt ab dann ein Kommando, das den versionierten
  Baum eines fremden Repos umschreibt und darin löscht. Alternative C schlösse das konstruktiv aus
  und kostet dafür ein zweites Release-Artefakt; die Abwägung steht in der Tabelle.
- **Negativ:** zwei Review-Runden, ein bats-Satz und sieben Mutations-Fälle des Shell-Wegs werden
  retiriert. Der **Gegenstand** der Zähne wandert mit (Festlegung 2); die Arbeit an ihrer
  Shell-Fassung ist verloren.
- **Grenze:** die Reichweite ins Ziel endet dort, wo der Träger endet — ein frischer Klon hat ihn
  nicht. Die Grenze ist **benannt, nicht geschlossen**, und sie ist keine Folge dieser
  Entscheidung, sondern die von
  [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(b), die hier
  weitergilt.
- **Grenze:** der `git`-berührende Teil der Operation bleibt außerhalb des Test-Bildes. Der
  Prüfbereich wächst um die vier reinen Gegenstände; er wird nicht vollständig.
- **Folgepflicht 1 — der Port liefert die drei Abnahme-Kriterien mit ihrem roten Gegenbeispiel.**
  Ohne sie ist der Träger gewechselt und die Zusage nicht.
- **Folgepflicht 2 — die Mutations-Fälle des Shell-Wegs wandern mit oder werden beim Entfernen
  einzeln benannt.** Ein stiller Verlust verengt die bewachte Fläche, ohne dass ein Gate es meldet.
- **Folgepflicht 3 — die Beschreibung des Targets wird mit dem Träger nachgezogen.** Sie steht in
  [`harness/README.md`](../../../harness/README.md) und nennt heute Eigenschaften des Shell-Wegs;
  wer den Träger tauscht und die Beschreibung stehen lässt, erzeugt genau die Klasse *geänderte
  Ableitung, stehengebliebene Zusage*, die das Beobachtungs-Register führt.
- **Folgepflicht 4 — der vierte Pin verlässt das Makefile mit seinem Gegenstand.** Ein gepinnter
  Digest ohne Aufrufer ist eine Zusage über ein Bild, das niemand fährt.
- **Folgepflicht 5 — der emittierte Anweisungssatz zeigt erst auf das Kommando, wenn es läuft.**
  Ein Zeiger davor wäre die halluzinierte Zusage aus
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6). Wer den
  Satz schreibt, entscheidet [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
  nicht diese ADR.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
| --- | --- | --- |
| `make test` · `make mutate` | **Ein Träger, ein Einstiegspunkt.** Der Dispatch des Produkt-Binärs führt den Archivierungs-Zweig, und ein vertauschter Zweig färbt rot — die Gestalt des bestehenden Routing-Zahns, der dieselbe Eigenschaft für die zwei Telemetrie-Unterkommandos hält. **Geschuldet, nicht geliefert** | `make test`, `make mutate` |
| `make test` · `make mutate` | **Abnahme-Kriterium 1.** Der Hänger-Wächter meldet einen lebenden Verweis auf einen zu löschenden Report. **Rot zu sehen ist:** `docs/reviews/**` aus dem Suchraum nehmen, dann muss der Wächter fallen. **Geschuldet, nicht geliefert** | `make test`, `make mutate` |
| `make test` · `make mutate` | **Abnahme-Kriterium 2.** Eine untrackte Fremddatei bricht den Lauf vor dem ersten Move, und das Staging nennt explizite Pfade. **Rot zu sehen ist:** die Sauberkeits-Prüfung auf getrackte Dateien verengen bzw. `-A` stagen. **Geschuldet, nicht geliefert** | `make test`, `make mutate` |
| `make test` · `make mutate` | **Abnahme-Kriterium 3.** Der aufsteigende Stub-Verweis wird beim Folgelauf nachgezogen. **Rot zu sehen ist:** die aufsteigende Ersetzungsrichtung entfernen. **Geschuldet, nicht geliefert** | `make test`, `make mutate` |
| `make test` | **Festlegung 3 — der Stub ist der Ausdruck der Vorlage.** Der geschriebene Stub ist aus der vendored Vorlage abgeleitet, und ohne sie schreibt die Operation **keinen**, sondern bricht ab. **Rot zu sehen ist:** die Vorlage im Prüfbaum entfernen — dann muss die Operation fallen statt eine Form zu erfinden. **Geschuldet, nicht geliefert** | `make test` |
| `make full-smoke` | **Festlegung 4 — ein frisch gebootstrapptes Ziel erreicht das Unterkommando** an dem Ort, an dem der Träger liegt; fehlt der Träger, **meldet** das Kommando es und färbt nichts rot. Für dieses Target führt der Mutations-Treiber ein Fehlschlag-Muster, der Fall ist also listbar (`sed -n 's/^# verify: //p' test/mutations/*.sh \| sort \| uniq -c` nennt die belegten Sensoren). **Geschuldet, nicht geliefert** | `make full-smoke` |
| — | **Nicht maschinell prüfbar, und darum hier ohne Zeile:** dass ein Adopter den Träger nach einem frischen Klon wiederherstellt. Das ist die Grenze aus [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(b); sie wird ausgesprochen, nicht bewacht | — |

## Re-Evaluierungs-Trigger

- **Wenn die Baseline die Archivierung aus der Wellen-Closure entfernt oder ihren Träger selbst
  benennt** *(feedforward — fremder Vertrag, sichtbar beim Freshness-Audit der nächsten
  Re-Baseline)*: der Gegenstand dieser Entscheidung wechselt oder entfällt.
- **Wenn ein Repo ohne Wellen-Betrieb die Archivierung braucht** *(feedforward — die Quelle sagt
  für diesen Fall selbst, die Frage bleibe offen)*: der **Auslöser** ist neu zu entscheiden, nicht
  der Träger. Diese Entscheidung sagt über ihn nichts.
- **Wenn der Träger an dem Ort nicht ausführbar ist, an dem archiviert wird** *(feedforward — an
  einem Ziel ablesbar, dessen abgelegtes Bild nicht startet)*: Annahme (a) fällt, und mit ihr die
  Grundlage von Festlegung 1 und 4. Die Plattform-Frage ist dann neu zu stellen; die Wege, die
  [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) für denselben Fall
  abgezählt hat, gelten unverändert.
- **Wenn ein Ziel den vendored Baseline-Baum nicht mehr führt** *(feedforward — eine Änderung an
  [ADR-0005](0005-ziel-repo-distribution.md))*: Annahme (b) fällt, und Festlegung 3 verliert im
  Ziel ihre Quelle. Im Dogfood bleibt sie unberührt.
- **Wenn die Fähigkeitsfläche des Trägers zum Befund wird** — etwa weil ein Adopter einen Träger
  fremder Herkunft startet *(feedforward — kein Sensor dieses Repos)*: Alternative C steht bereit
  und trägt dieselben Prüf- und Pin-Eigenschaften mit getrenntem Einstiegspunkt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-03 | **Proposed** | Architect-Lauf zu `slice-172`. Der Träger der Wellen-Archivierung war offen, während zwei Antworten nebeneinander liefen. Die Entscheidung prüft die Berufung auf [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) in drei Teilen statt sie zu übernehmen — zwei tragen, der dritte wird ortsgebunden korrigiert —, führt eine **eigene** Abzählung über die Herkunft des ausführenden Artefakts und wählt den Träger über den **Preis**, nicht über einen Beweis. Der Acceptance-Trigger steht in §Der Acceptance-Trigger |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0033` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
