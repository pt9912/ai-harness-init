# ADR-0099: Der Fast-Pfad von `make gates` überspringt über dem gedeckten Stempel-Paar und fährt sonst fail-closed voll

**Status:** Accepted

**Datum:** 2026-11-25

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein SKIP, der ein Verdikt behauptet, das kein Lauf trägt, ist der halluzinierte Gate eine Ebene
tiefer),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(dasselbe Stempel-Paar, dieselbe SKIP-Entscheidung — deterministisch und netzlos),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(Beleg statt Lauf; benannter Rest als Träger des Ausschalters — diese ADR nimmt die Regel auf,
Festlegung 6),
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(Festlegungen 1 und 3: das Urteil des Stop-Hooks und das Stempel-Paar — hier nicht geändert),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(der inhaltsbasierte Baum-Hash als gemeinsame Quelle der Wahrheit),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Richtung, hier als Prüfpunkt der Umsetzung gelesen),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)
(keine Abweichung, keine Pflicht eines Eintrags — §Konsequenzen),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Die SKIP-Bedingung des Gate-Einsprungs trägt keine
Spec-Stelle; die Ordnungskante `record-gates: <checks>`
([`spec/architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume))
bleibt von dieser Entscheidung unberührt, und der Konsum des Stempels durch den Stop-Hook
([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 1)
ebenso.

---

## Kontext

`make gates` baut über der Ordnungskante die vollen Checks und stempelt danach
(`record-gates` schreibt `.harness/state/gates-passed.diffsha` und `.harness/state/gates-passed.head`,
beide gitignored). Jeder Wiederhol-Lauf über unverändertem Baum wiederholt jeden Check, obwohl der
Stempel belegt, dass genau dieser Baum zuletzt vollständig grün war. Der Stop-Hook urteilt am
Turn-Ende bereits an denselben zwei Dateien
([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 1):
freilassend nur, wenn HEAD gleich geblieben ist, und deckt sonst auf den Inhalts-Hash.
`slice-gates-fastpfad-ueber-stempel` fragt, ob `gates` sich dieses Urteil zunutze macht.

**Die Deckungs-Lage ist hier eine andere als bei
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md).** Der Prüfgegenstand
des Gate-Laufs ist der Arbeitsbaum, und er hat keine zweite, abweichende Definitionsform wie dort
die Isolationskopie gegenüber dem Arbeitsbaum: Der Schlüssel im Stempel ist derselbe
Baum-Hash, den die Checks selbst gegenfahren (getrackte und untrackte Dateien,
[`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
Die Image-Inhalte der Checks sind transitiv im Schlüssel — die Image-Pins tragen Digests, die in
getrackten Dateien stehen
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4). Die
Deckungs-Aussage bedarf darum keiner Mengen-Messung nach dem Vorbild des ADR-0035-Kontexts;
was sie nicht deckt, ist derselbe benannte Rest wie dort (Festlegung 2).

**Die Design-Enge steckt im Plan:** ein Fast-Pfad *im Rezept von* `record-gates` bringt nichts —
`make` baut die Voraussetzungen zuerst, das Rezept liefert zuletzt; solange ein CHECK fehlt, ist
der Stempel ohnehin frisch, und der SKIP käme nie zum Zug. Der Fast-Pfad liegt darum **vor** der
Kante: `gates` wird selbst zum Rezept, das einen Wrapper startet (eine neue
Wrapper-Datei der Schicht [`harness/tools/`](../../../harness/tools/)), und der
Wrapper ruft bei Nicht-Deckung `make record-gates` auf.
Diese Form bricht die Deckungsgleichheit `make -n gates` ⟷ `make -n record-gates`, die
[`test/gate-nachweis-kante.bats`](../../../test/gate-nachweis-kante.bats) misst — der Wächter wird
im Slice mitgezogen und die Änderung einmal aus dem richtigen Grund rot gesehen
([`AGENTS.md`](../../../AGENTS.md) §3.6).

## Entscheidung

Wir wählen: **`gates` wird zum Rezept mit Wrapper; der SKIP greift nur über dem vollständig
gedeckten Stempel-Paar, fail-closed in jedem Zweifel, mit `GATES_FORCE=1` als Ausweich-Griff.**

**1. SKIP-Bedingung.** SKIP nur, wenn **beide** Stempel decken: `.harness/state/gates-passed.diffsha`
trägt den Hash, den [`harness/tools/working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh)
über den aktuellen Arbeitsbaum liefert, und `.harness/state/gates-passed.head` trägt die aufgelöste
SHA von HEAD, ermittelt mit demselben `head_wert` wie `record-gates.sh` und der Stop-Hook (Kopplung:
drei Fassungen gleich halten; der Wert `kein-commit` aus dem commitlos-Fall von
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 4 wird
wie eine SHA verglichen). Das ist exakt das Urteil, das der Stop-Hook am Turn-Ende bereits fällt
([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 1) — der
Fast-Pfad errichtet keinen zweiten Maßstab, sondern macht jenes Urteil zum Einsprungpunkt von
`gates`, auf derselben Grundlage, netzlos ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
Die Stempel-Dateien: verändert bleibt `record-gates` der **alleinige** Schreiber; der Fast-Pfad
schreibt nichts und löscht nichts.

**2. Benannter Rest.** Den Teil, den **kein** baum-abgeleiteter Schlüssel deckt, nennt die
SKIP-Meldung, nicht einen Vorbehalt daneben: der lokale Docker-Cache-Zustand und die Host-Werkzeuge
selbst (bash, tar, git, docker). Sie liegen außerhalb jedes Repo-Zustands; ein Cache-Zustand ist
keine Adresse und in keinem Schlüssel darstellbar
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4, dessen
Wortlaut-Präzedenz neben `§BELEG STATT LAUF` im Kopf von
[`harness/tools/mutate.sh`](../../../harness/tools/mutate.sh) — hier deckungsgleich in der Aussage,
nicht in Textform übernommen). Träger des Rests ist der Ausschalter zusammen mit der Meldung:
der SKIP nennt die gedeckte Lage und den Rest und behauptet **kein** Check-Ergebnis.

**3. Der Ausschalter heißt `GATES_FORCE`.** Name verbindlich: `GATES_FORCE=1` zwingt den vollen
Lauf auch über einem gedeckten Paar; jeder andere Wert und das Fehlen sagen nichts.
Er schließt sich an die bestehenden Ausschalter-Werte-Welten an —
`MUTATE_FORCE=1`
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 4),
`STOP_GATE_STRENG=1`
([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) Festlegung 6) —
und ist kein Komfort, sondern der Teil der Zusage, der den Rest aus Festlegung 2 behebbar hält.

**4. Fail-closed als Default.** Fehlender, unlesbarer, leerer oder gestutzter, nicht mehr
passender Stempel; HEAD nicht auflösbar; jeder Parser-Zweifel am Datumswert, am Hash-Wert oder an
den Zustands-Prüfungen — **voller Lauf** (`make record-gates`, dasselbe Rezept mit derselben
Kante). [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
liest sich als Prüfpunkt der Umsetzung: Der Fast-Pfad urteilt nie über das hinaus, was er sicher
lesen kann; was er nicht sicher lesen kann, ist ungedeckt und fährt voll.

**5. Was diese ADR nicht entscheidet.** bats-Sharding (Kalt-Pfad, andere Ursache — der frische
Klon hat keinen Stempel und fährt fail-closed voll), Kanten-Parallelisierung (`make -j`,
Ordnungskante an
[`spec/architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
unverändert), ein Stempel-Vorlauf im CI (Kalt-Pfad-Beleg, andere Entscheidung) und **jede**
Änderung an der Stempel-Form oder an ihrem Konsum durch den Stop-Hook (Schreiber- und Konsum-Satz
stehen in
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md), nicht hier).

**6. Verhältnis zu
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) und
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md).**
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) (Beleg statt Lauf) nimmt
diese ADR auf: Ein Beleg-Übersprung ist keine Schwellen-Senkung (dessen Festlegung 1), und für den
Gate-Einsprung entfällt dessen engste Zusatzbelastung — der Schlüssel ist der **bereits
bestehende** Stempel, kein zweiter Beleg-Slot, weil Prüfgegenstand und Schlüssel definitionsgleich
am Baum hängen (kein zweites „Baum“-Wort, das gegen ein erstes driftet). Der Unterschied:
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) gilt einem Sensor, den
kein Gate fährt (`make mutate`); diese ADR gilt dem Gate-Einsprung selbst.
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) **schärft** diese
ADR nicht und wird von ihr nicht geschärft: beide konsumieren dieselbe Grundlage (Baum-Hash +
HEAD-Auflösung), und keiner ändert Schreiber oder Konsum des Stempels.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun | kein Aufwand, keine neue Zuständigkeits-Oberfläche | Wiederhol-Läufe über unverändertem Baum wiederholen jeden Check, obwohl ein vollständiger Beleg dasteht; der Zustand bleibt ungenutzt, wo er zulässig ist ([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 2) |
| B — Fast-Pfad *im Rezept von* `record-gates` | keine Änderung am `gates`-Target; die Deckungsgleichheit `make -n gates` ⟷ `make -n record-gates` bleibt | kein Objekt: `make` baut die Voraussetzungen zuerst, das Rezept läuft zuletzt — der SKIP stünde an der einen Stelle im Lauf, an der er nie zum Zug kommt, wenn ein SKIP nötig wäre |
| C — SKIP nur über `diffsha`, ohne `head` | einfachste Bedingung, ein Vergleich | der SKIP läge laxer als der Stop-Hook und wäre damit ein **zweiter** Maßstab über derselben Grundlage; [ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) verlangt für den Frei-Gang beides, und der Fast-Pfad sollte denselben Stand teilen, nicht einen günstigeren |
| D — SKIP nur über `head` | kein Hash-Lauf am Bestand | deckt eine Inhalts-Änderung, die die Checks nie urteilten — die falsche Aussage aus [ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 2, [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene tiefer |
| E — Fast-Pfad über einem **neuen**, eigenen Beleg-Schlüssel | unabhängig vom Stop-Hook-Stempel | unnötig: der Prüfgegenstand des Gate-Laufs ist der Baum, und es gibt dafür bereits einen gepflegten Schlüssel; ein zweiter wäre eine zweite gepflegte Definition desselben Wortes und driftet gegen die erste ([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 3) |
| **F — `gates` als Rezept mit Wrapper, SKIP über dem gedeckten Paar, fail-closed, `GATES_FORCE` (gewählt)** | dasselbe Urteil wie der Stop-Hook, kein neuer Schlüssel, keine zweite Schreibstelle; die Meldung benennt den Rest | ein einmaliger Zusatz-Lauf je geändertem Baum bleibt (der SKIP entwertet sich mit jedem Inhalts-Touch ohnehin); die Deckungsgleichheit `make -n gates` ⟷ `make -n record-gates` bricht, ihr Wächter wird mitgezogen und die Änderung einmal rot gesehen — bekannte Kosten, im Plan geführt |

## Konsequenzen

- Positiv: Wiederhol-Läufe über gedecktem Paar kosten den Wrapper und keinen Check; CI bleibt
  unverändert (frischer Klon: kein Stempel, fail-closed voller Lauf); Schreiber
  (`record-gates`), Ordnungskante und Stop-Hook-Konsum bleiben unverändert.
- Negativ: Der benannte Rest aus Festlegung 2 bleibt bestehen — ein SKIP konserviert das Verdikt
  des vollen Laufs auch über Docker-Cache- und Host-Werkzeug-Zuständen, die niemand adressiert;
  `GATES_FORCE=1` macht es behebbar, nicht abwesend.
- Negativ: Der SKIP ist eine Aussage über einen Ausschnitt (Baum + HEAD), nicht über die
  Vollständigkeit; dass die SKIP-Bedingung bei jedem künftigen Check im Kanten-Satz **Deckung**
  behält, halten die Re-Evaluierungs-Trigger unten, nicht ein Sensor.
- **Kein Eintrag im Adaptions-Block**, nach der Lesart von
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage): Eine Abweichung von der
  Baseline liegt nicht vor — der überspringende Lauf hat in der adoptierten Fassung kein
  Gegenstück, von dem abgewichen werden könnte; der inhaltsbasierte Nachweis ist deren eigene
  Design-Eigenschaft (`grundlagen-durchsetzungsschicht.md` §Vier Design-Eigenschaften: *Nachweis
  über Inhalt, nicht Diff*), hier **konsumiert** und nicht ersetzt, und der SKIP greift nicht in
  die Verdikt-Funktion der Checks ein
  ([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 1). Kommt
  das Konsistenz-Review zur entgegengesetzten Einsicht, ist der Eintrag ein eigener Folge-Schritt
  der Rollen-Sequenz Planner → Architect → Planner und entsteht nicht in diesem Zug.
- Folgepflicht: Die Fitness Function unten entsteht **im selben Slice** wie der Fast-Pfad — ein
  SKIP ohne sie wäre eine Absichtserklärung an der Stelle, an der das Gate sonst still grün wird.
- Folgepflicht (Implementer, derselbe Slice): die `make gates`-Zelle in
  [`harness/README.md`](../../../harness/README.md) §Sensors nennt den Fast-Pfad und trägt diese
  ADR als Bindung; die SKIP-Meldung nennt den benannten Rest.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, `test/gates-fastpfad.bats` (neu, hermetisch über Fixture-Makefiles wie der Kanten-Wächter, `--network none`) | **Happy:** gedecktes Paar (`diffsha` **und** `head`) → SKIP-Meldung mit benanntem Rest, Exit 0, kein Check fährt. **Negative:** Stempel fehlt · trägt fremden Hash · ist unlesbar · leer · `head` weicht ab · HEAD nicht auflösbar → voller Lauf (`make record-gates` fährt). **Boundary:** `GATES_FORCE=1` über dem gedeckten Paar → voller Lauf; jeder andere Wert des Schalters → SKIP. Dazu: der Fast-Pfad schreibt keinen Stempel | `make test` (in `make gates`) |
| bats, [`test/gate-nachweis-kante.bats`](../../../test/gate-nachweis-kante.bats) (mitgezogen) | Die Zusage der Kante bleibt, ihre Lesung ist an die Wrapper-Form angepasst: `record-gates: <checks>` byte-gleich, `gates` fährt ohne `record-gates` keinen Check, der Fast-Pfad liegt vor der Kante und schreibt nichts | `make test` (in `make gates`) |
| Mutations-Fälle, `test/mutations/` (zwei neue) | (1) SKIP greift ohne gedecktes Paar → der bats-Wächter wird rot am benannten Grund; der `sed`-Anker des Falls misst gegen den Quell-Bestand ([`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)). (2) Der Anker des Falls hängt am Commit ([`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)) | `make mutate` (lokale Ausführung befristet über `MUTATE_CASES`) |

**Was hier nicht behauptet wird:** der Rot-Beleg steht **nicht** in dieser ADR — die Wächter
entstehen erst im Slice, und das Gate-Einweihungs-Kriterium des Slices misst ihre drei Klassen am
realen Wächter
([`AGENTS.md`](../../../AGENTS.md) §3.6). **Was kein Wächter hält:** dass die SKIP-Bedingung bei
einem künftigen Check im Kanten-Satz Deckung behält; Träger sind die Re-Evaluierungs-Trigger,
geprüft im Trigger-Audit der Closure.

## Re-Evaluierungs-Trigger

Nicht permanent. Drei beobachtbare Bedingungen, jede einzeln auslösend:

1. **Ein Check tritt in den Kanten-Satz ein, dessen Prüfgegenstand der Baum-Hash strukturell
   nicht deckt** — etwa ein netz-bindender Check oder einer, der außerhalb des Arbeitsbaums liest
   (Rückführung des Slice-Plans). Dann ist die Deckung des Schlüssels neu zu zeigen, **bevor** der
   Fast-Pfad weiter greifen darf.
2. **SKIP und erzwungener voller Lauf liefern über demselben gedeckten Paar verschiedene
   Verdikte** (beobachtbar an zwei Läufen auf demselben Stand). Dann ist der benannte Rest aus
   Festlegung 2 kein Rauschen, sondern ein Weg ins stille Grün, und die SKIP-Bedingung ist
   neu zu wägen — im Extremfall per Folge-ADR mit `Supersedes ADR-0099`.
3. **Schreiber-Satz oder Konsum des Stempels ändern sich** — eine Folge-ADR zu
   [ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md) oder ein
   Formatwechsel an `.harness/state/gates-passed.diffsha`/`.head`. Dann ist der Fast-Pfad vor
   seiner nächsten Lieferung neu gegen das geänderte Paar zu halten.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-25 | **Accepted** | Architect-Verdikt auf den Start-Trigger des Slice `slice-gates-fastpfad-ueber-stempel` (Kennung ohne Adresse,
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3); Annahme durch
den Auftraggeber am 2026-11-25 |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0099` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
