# Slice slice-174: Ein gebootstrapptes Ziel erreicht die Wellen-Archivierung

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md). Die Welle trägt das
*Mehr* über dieser DoD: ihr Closure-Trigger fährt die neu emittierten Werkzeuge im gebootstrappten
Ziel einmal durch (`make full-smoke`) — einen Beleg, den kein Punkt dieser DoD führt
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-08`](../../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren)
(die emittierte Anleitung — der Adopter bekommt den Prozess, nicht nur die Gerüste),
[`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
(repo-spezifische Stellen bleiben adaptierbare Marker),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Kommando behaupten, das im Ziel nicht läuft),
[ADR-0007](../../adr/0007-bootstrap-phasen.md) (Phasen und Idempotenz-Klassen je emittiertem
Artefakt),
[ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5b
(der Träger liegt gitignored — ein frischer Klon des Adopter-Repos hat ihn nicht),
[ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (ein
Rollen-Anweisungssatz gehört der Rolle, die ihn ausführt).

**Berührte Spec-Stellen:** `—`.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-03.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Das gebootstrappte Ziel erreicht `archive-welle` — die Operation ist gezündet, nicht nur
beschrieben.**

Die Vorlagen für beide Stub-Arten liegen im Ziel bereits: der Bootstrap vendort den
Baseline-Baum, und darin stehen `archiv-stub-slice.template.md` und
`archiv-stub-welle.template.md`
(`ls .harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-*.template.md | wc -l`
→ **2**; kein Erwartungswert,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Was fehlt, ist der **Weg zum Ausführenden**.

**Der Anweisungssatz ist selbstkonsistent — offen ist die Zündung.** Er verlangt ein Werkzeug für
Schritt 4 *und* liefert den ehrlichen Ausgang mit: *„Hat dein Repo das Werkzeug nicht, ist die
Bedingung nicht eingetreten; **das** gehört als Feststellung in die Results-Notiz, nicht in einen
Handlauf."* An diesem Satz ist nichts zu reparieren. Was fehlt, ist die **Zündung**: der Träger führt
`archive-welle` als Unterkommando, es gibt aber **kein Make-Ziel** im Ziel und der Anweisungssatz
zeigt nicht auf den Träger.

**Das fertige Muster steht im Baum.**
[`internal/emit/templates/enforce/erfassung.mk`](../../../../internal/emit/templates/enforce/erfassung.mk)
Ziel `span-report` zeigt, wie ein
emittiertes Träger-Ziel aussieht: eine Variable auf den Trägerpfad, ein Versuch samt `.exe`-Endung
(Windows) und eine **Meldung**, wenn der Träger fehlt. Für `archive-welle` heißt das: **kein**
Prerequisite (`host-bin` hat im Ziel keinen Gegenstand — der Träger wird abgelegt, nicht gebaut),
**keine** neue Logik, und die zwei Sperren des Unterkommandos kommen mit dem Aufruf mit.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **Ein frisch gebootstrapptes Ziel erreicht `archive-welle`** — auf dem Weg, den Festlegung
      (d) aus [slice-172](../done/slice-172-adr-archivierung-als-unterkommando.md) wählt. Der Beleg
      ist `make full-smoke` und **nur** er, nicht `make gates`: das Unterkommando ist bewusst kein
      Gate, und kein Unit-Test des Repos fährt das Ziel. Derselbe Beleg-Typ, mit dem
      [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) die
      Erfassungsschicht im Ziel abgenommen hat. **Der Vorlauf war reich, der E2E fehlte** — das war
      der Anlass dieses Slice, und der Stand ist seither gezogen; keine Erwartungswerte
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2):

      ```sh
      ls internal/archive/*_test.go | wc -l                                   #  7 Go-Testdateien
      ls test/archiv-stub-vorlagen.bats test/unterkommando-kopplung.bats | wc -l  #  2 bats
      grep -l 'archive' test/mutations/*.sh | wc -l                           # 34 kuratierte Faelle
      grep -c 'archive' harness/tools/full-smoke.sh                           # 23 — der E2E nennt das Unterkommando
      ```
- [x] **Der emittierte `close-welle.md` zeigt auf den Träger**, und der ehrliche Ausgang für ein
      Repo ohne das Werkzeug bleibt **daneben** stehen. Die repo-spezifische Stelle, die der
      **adaptierbare** Marker trägt
      ([`LH-FA-02`](../../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)), ist
      der **Weg zum Träger**; der Ziel-**Name** `archive-welle` ist es nicht — er kommt aus einem
      tool-eigenen Fragment, das jeder Bootstrap kanonisch neu schreibt, und ein umbenanntes Ziel
      hält darum nicht.
- [x] **Fehlt der Träger im Ziel, sagt das Kommando das und färbt nichts rot** — der Fall aus
      [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5b
      (frischer Klon, gitignorierter Ablageort). Rot gesehen an genau diesem Fall: Träger
      entfernen, Kommando fahren, Ausgabe und Exit-Code lesen.
- [x] `make gates` grün.
- [x] Doku-Update: die Aufzählung emittierter Artefakte in
      [`harness/README.md`](../../../../harness/README.md) und
      [`README.md`](../../../../README.md), soweit sie durch diesen Slice wächst. **Nicht
      fällig:** keine der beiden Dateien führt eine Aufzählung emittierter Artefakte — der
      Bedingungsteil des Punktes ist nicht eingetreten, nicht unerfüllt:

      ```sh
      git grep -n 'harness/mk/\|commands/\|erfassung.mk\|archivierung.mk' -- README.md harness/README.md   # keine Ausgabe
      ```
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). **Hier nicht geprüft und nicht fällig:** dieses Repo führt Wellen, und dieser Slice ist Mitglied von [welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md) — die drei Paarungen trägt ihre Closure (§7).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/commands/close-welle.md` | update | Schritt 4 nennt das Kommando statt des Nicht-Eintritts |
| `internal/emit/` | update | nur falls Festlegung (d) einen eigenen Emissions-Schritt verlangt; die Vorlagen liegen über den vendored Baum schon im Ziel |
| `Makefile` (`full-smoke`) | update | der Beleg aus DoD (1) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`):
[slice-173](../done/slice-173-archive-welle-als-unterkommando.md) liegt in `done/` — vorher gibt es kein
Kommando, auf das der emittierte Anweisungssatz zeigen könnte, und ein Zeiger darauf wäre genau
die halluzinierte Zusage aus
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6).

**Zweite Start-Bedingung — eingetreten:**
[ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) trägt `Status: Accepted`
(`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md`
→ **1**); sie bindet damit nach [`AGENTS.md`](../../../../AGENTS.md) §3.4, und ihre Festlegung 4
trägt den Gegenstand dieses Slice. Ihre Annahme war die Bedingung; sie ist eingelöst, nicht offen.

**Reihenfolge innerhalb von `next/`:** keine Kopplung an
[slice-073](../done/slice-073-emittierte-doc-gate-module.md) oder
[slice-140](../done/slice-140-emittierter-stand-ohne-vorlagen-hilfen.md). Die drei berühren
`internal/emit/` an getrennten Stellen — die Modul-Liste der emittierten Gate-Konfiguration, die
Kommentar-Hilfen der Singleton-Ausgabe und die Command-Vorlage samt Fragment; keine Reihenfolge
ist erzwungen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die **Erreichbarkeit** im Ziel eine
  eigene Abzählung verlangt — der Träger liegt gitignored, und ein frischer Klon hat ihn nicht.
  Das ist eine Träger-Frage und gehört zu
  [slice-172](../done/slice-172-adr-archivierung-als-unterkommando.md), nicht an die Emissionsstelle.
- `in-progress` → `open` (blockiert — Carveout?): wenn Festlegung (d) die Emission verneint —
  dann hat dieser Slice keinen Gegenstand.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; `make full-smoke` grün über beiden Zweigen aus DoD (1) und (3); `make gates`
grün; Closure-Notiz mit Steering-Loop-Lerneintrag.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Ausweg der Erfassungsschicht trägt hier nicht.**
  [ADR-0022](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5b
  löst den fehlenden Träger mit einem committeten Wrapper, der **schweigt und erfolgreich endet**
  — richtig für einen fail-open-Beobachter. Die Archivierung schreibt Commits und löscht Dateien;
  Schweigen wäre dort der teurere Fehlerfall. DoD (3) verlangt darum eine **Meldung** ohne Rot,
  nicht Stille. — **Ausgang:** *entfallen* — DoD (3) trägt die Meldung: das emittierte
  Archivierungs-Fragment sagt den fehlenden Träger und endet mit 0; der Mutations-Fall, der die
  Zeile entfernt, färbt den E2E rot. Das fehlende Werkzeug wird also nicht still verschwiegen.
- **Der Gegenstand ist ein Rollen-Anweisungssatz, und dieser Slice ist Implementer-Arbeit.**
  [ADR-0028](../../adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) gibt
  `close-welle.md` der ausführenden Rolle — dem Planner; `BEO-ALL/anweisungssatz-eigentum-ohne-quelle` im
  [Register](../observations/README.md) (4×, geplant) führt die noch offenen Teile derselben Frage. Die
  **Text**-Hälfte von DoD (2) ist damit eine Übergabe, keine Implementer-Entscheidung. —
  **Ausgang:** *eingetreten* — sie ist eine Übergabe geblieben: den Ziel-Namen als tool-eigen zu
  benennen war Planner-Arbeit. Die Eigentums-Frage selbst ist mit
  [ADR-0051](../../adr/0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) entschieden,
  und die offene **Adopter-Seite** trägt der Folge-Slice
  [slice-adopter-seite-der-anweisungssatz-grenze](../next/slice-adopter-seite-der-anweisungssatz-grenze.md).
- **Ein Sensor des Ziels sieht die Stubs womöglich nicht mehr.** Der emittierte Anweisungssatz
  warnt selbst: was auf `done/*.md` keilt, sieht die Stubs eine Ebene tiefer nicht und bleibt
  grün, ohne noch etwas zu prüfen. Was die emittierte Gate-Konfiguration hier zusagt, ist zu
  prüfen, nicht anzunehmen. — **Ausgang:** *entfallen* — gemessen statt angenommen: die emittierte
  Gate-Konfiguration scannt ab `.` (`scan.roots: ["."]`), und ihre `slice`-Klasse greift über `**`
  auch `done/<welle-id>/slice-*.md` (`paths: ["docs/plan/planning/**/slice-*.md"]`); der emittierte
  Anweisungssatz nennt die Prüfung zusätzlich in Schritt 4.
- **Der Plan hält eine Frage offen, die die Entscheidung inzwischen beantwortet.** §3 führt den
  eigenen Emissions-Schritt als Bedingung (*„nur falls Festlegung (d) einen eigenen
  Emissions-Schritt verlangt"*), und die Rückführung `in-progress` → `open` rechnet mit ihrer
  Verneinung. [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4
  entscheidet sie: der Zielbaum bekommt ein Nicht-Gate-Fragment in seinem Fragment-Verzeichnis,
  gebaut wie das der Erfassungsschicht. Die Bezeichnung *Festlegung (d)* stammt aus dem
  Alternativen-Vergleich, nicht aus der Nummerierung der angenommenen Fassung. Der Lauf liest die
  Festlegung, nicht diese Plan-Zeile. — **Ausgang:** *entfallen* —
  [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4 beantwortet die
  Frage: der Zielbaum bekommt ein Nicht-Gate-Fragment in seinem Fragment-Verzeichnis. Die Bedingung
  in §3 ist damit **eingetreten**, die Verneinung der Rückführung gegenstandslos.
- **Ein Mess-Kommando nennt einen Baseline-Tag, den das Repo nicht führt.** §1 zählt die zwei
  Stub-Vorlagen unter `.harness/baseline/v5.18.0/`; vendored liegt allein der adoptierte Stand
  (`ls .harness/baseline/`). Das Kommando läuft so ins Leere, und kein Gate sagt es:
  `codepaths.roots` führt `[spec, docs, harness]`, ein Pfad unter `.harness` liegt außerhalb
  ([slice-201](../done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md)). — **Ausgang:**
  *entfallen* — die Adresse ist auf den adoptierten Stand nachgezogen und die Zählung neu gefahren:

  ```sh
  ls .harness/baseline/v6.8.0/templates/docs/plan/planning/archiv-stub-*.template.md | wc -l   # 2
  ```

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** **Das Muster lag im Baum, und die Emission hat es übernommen statt
  erfunden.** Das emittierte Fragment baut auf dem Ziel `span-report` der Erfassungsschicht auf:
  eine Variable auf den Trägerpfad, ein Versuch samt `.exe`-Endung, eine **Meldung** bei fehlendem
  Träger — **keine** neue Logik, und die zwei Sperren des Unterkommandos reisen mit dem Aufruf mit,
  weil das Fragment sie nicht nachbaut. **Zweitens trägt der E2E beide Zweige:** die Erreichbarkeit
  (`(a)+(b)`) und den fehlenden Träger (`(d)`), und der Rot-Beleg ist an genau diesem Fall gefahren
  (Träger beiseite, Ausgabe und Exit-Code gelesen). **Drittens hat die Namensachse einen eigenen
  Sensor bekommen:** der Unterkommando-Name reist als Zeichenkette vom Aufrufer in den Prozess, und
  `test/unterkommando-kopplung.bats` hält jetzt die Namen der drei Quellen gegen den Dispatch.
- **Was ging anders als geplant:** **Vier Dinge.** (1) Der DoD-Punkt 2 schrieb dem Adopter eine
  Freiheit zu — *„der Adopter darf das Target anders nennen"* —, die die Lieferung widerlegt: das
  Ziel kommt aus einem tool-eigenen, konvergent neu geschriebenen Fragment. Nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.10 zieht den Teilsatz der Planner; er ist gezogen, und der
  Punkt beschreibt jetzt den Zustand. (2) §8 hatte vorausgesagt, der Zähler der Klasse
  `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` bewege sich **nicht**; er hat sich
  bewegt — zwei Prosa-Zahlen (der Anlass-Block und die Grenz-Zeile des Archivierungs-Sensors) waren
  mit den späteren Commits überholt. (3) §3 nannte das `Makefile` als Träger des Belegs; geändert
  ist `harness/tools/full-smoke.sh`, das sein Rezept ruft — der Gegenstand stimmt, der Träger liegt
  eine Ebene tiefer. (4) Der E2E liest die **Wirkung** im Arbeitsbaum, nicht die zwei Commits, die
  der Träger selbst anlegt; sein Grün bleibt auch dann bestehen, wenn nur Dateien wandern. Die zwei
  Commits sind eine Grenze des Belegs, keine Zusage des Abschnitts.
- **Steering-Loop-Eintrag:** *Neuer Sensor* — `test/unterkommando-kopplung.bats` hält die
  Unterkommando-Namen, die die drei Quellen des Namens (`Makefile`, `.claude/settings.json`, das
  emittierte Archivierungs-Fragment) dem Träger geben, gegen den Dispatch in
  `cmd/ai-harness-init/main.go`: der Name reist als Zeichenkette, und vor diesem Vorgang verband
  nichts die Quellen mit dem Prozess. **Kein `liegt in`-Feld:** mit diesem Vorgang ist **keine**
  Regel dieses Repos verkörpert worden — der Sensor ist Liefergegenstand und keine Antwort auf einen
  3×-Schwellen-Übertritt. Der Eintrag ist gezählt, nicht verkörpert. Auslöser-Klasse:
  `BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` — sie erreicht mit diesem
  Vorgang **4×**; ihren Ausgang weist der Lese-Schritt zu.
- **Beobachtungs-Register (`../observations/`):** **Zwei neue Verzeichnisse, drei Belege an
  vorhandenen Einträgen.** Neu angelegt:
  [`BEO-ALL/adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt`](../observations/BEO-ALL/adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt/observation.md)
  — ein `ANPASSEN`-Marker lädt zu einer Änderung an einer Stelle ein, die die Emissions-Klasse des
  Artefakts nicht freigibt — und
  [`BEO-ALL/amend-committet-fremde-index-eintraege-mit`](../observations/BEO-ALL/amend-committet-fremde-index-eintraege-mit/observation.md)
  — `git commit --amend` committet den Index und reißt in einem Baum mit parallelen Schreibern einen
  fremden Commit mit. Beleg `evidence/slice-174-archivierung-emittieren.md` in
  [`BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
  (der DoD-Punkt 2), in
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (die zwei überholten Prosa-Zahlen) und in
  [`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  (der berührte emittierte Anweisungssatz neben der ausgeführten Fassung). **Kein Zähler wird
  gesetzt**, er folgt aus den Dateien — **keine Erwartungswerte**
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2):

  ```sh
  for s in abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt \
           zusage-neben-geaenderter-ableitung-bleibt-stehen \
           zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor \
           adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt \
           amend-committet-fremde-index-eintraege-mit; do
    printf '%-62s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
  done
  # abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt     4
  # zusage-neben-geaenderter-ableitung-bleibt-stehen               25
  # zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor      2
  # adaptions-marker-nennt-eine-stelle-die-emissions-klasse-nicht-haelt 1
  # amend-committet-fremde-index-eintraege-mit                     2
  ```

- **Folge-Slices:** [slice-adopter-seite-der-anweisungssatz-grenze](../next/slice-adopter-seite-der-anweisungssatz-grenze.md)
  (die Adopter-Seite der Anweisungssatz-Grenze) — ist eine Datei in `next/`, wellenlos.
- **Risiken aus §6:** fünf Punkte, je ein Ausgang — **viermal *entfallen*** (die Meldung ohne Rot
  trägt · die emittierte Gate-Konfiguration deckt die Stub-Ebene über `**` · die offene Plan-Frage
  ist mit [ADR-0033](../../adr/0033-wellen-archivierung-als-unterkommando.md) Festlegung 4
  beantwortet · die Tag-Adresse ist nachgezogen), **einmal *eingetreten*** (die Text-Hälfte blieb
  eine Übergabe; die offene Adopter-Seite trägt der Folge-Slice).
- **Drei Paarungen:** von der [welle-emittierte-werkzeuge](welle-emittierte-werkzeuge.md)-Closure
  getragen (dieser Slice ist ihr Mitglied), **hier nicht geprüft** — der §2-Schlußpunkt dieses Plans
  bleibt darum offen. Was sie vorfindet, ist gelegt: kein `liegt in`-Feld in §7 — nichts verkörpert,
  also keine Anker-Paarung; der eine Folge-Slice existiert als Datei in `next/`; und jede hier
  genannte Beobachtung existiert als Verzeichnis mit nicht leerem `evidence/`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — `internal/emit/` liegt
in keiner engeren Sub-Area der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area).
Die **emittierte** Ebene ist keine Sub-Area dieses Repos: sie ist ein anderer Vertrag, und die
Deklaration führt sie nicht.

**Vorgelagert — offene Beobachtungen sichten:** Zwei Treffer im [Register](../observations/README.md).
`BEO-ALL/anweisungssatz-eigentum-ohne-quelle` (4×, geplant — wer die Anweisungssätze schreiben darf, sagt keine Quelle) steht als
Risiko in §6. `BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen` (8×, geplant — eine geänderte Ableitung lässt die Zusage daneben stehen)
ist berührt: DoD (2) zieht **genau eine** solche Zusage nach, den Satz über das nicht vorhandene
Werkzeug; der Zähler bewegt sich damit nicht, weil dieser Slice die Klasse auflöst statt sie zu
beobachten. Weitere Treffer: keine.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit.
