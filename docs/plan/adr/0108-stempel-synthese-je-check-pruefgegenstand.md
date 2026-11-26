# ADR-0108: Stempel-Synthese — je Check der Kante ein Prüfgegenstand-Schlüssel, der Fast-Pfad fährt nur die gedrifteten Checks, der Stop-Hook liest die Mischform

**Status:** Accepted

**Datum:** 2026-11-26

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der SKIP behauptet kein Verdikt, das der Schlüssel nicht deckt — das
Zulässigkeits-Kriterium,
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) Festlegung 2),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(derselbe je-Check-Schlüssel, dieselbe SKIP-Entscheidung — deterministisch und netzlos),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(der je-Check-Key entsteht aus dem, was der Host ohnehin trägt),
[ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
(Beleg statt Lauf: Beweisrichtung der Deckung, benannter Rest, fail-closed),
[ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md)
(der Tier-1-Fast-Pfad, dessen SKIP-Bedingung hier je Check verfeinert wird),
[ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
(der Stempelvertrag des Stop-Hooks — die HEAD-Kante bleibt, unverändert),
[ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
(die Hash-Ausnahme — die Fall-Files der
[ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) rotieren keinen Key),
[`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)
(das Deckungs-Kriterium),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Richtung),
[`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
/ [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)
(Anlage-Disziplin der zwei neuen Mutations-Fälle).

**Kennung:** `slice-gates-pruefgegenstand-stempel-v1` — die Tafel der Prüfgegenstände
mit je Bezugsmenge und Begründung trägt der Plan dieser Kennung (§3); Adressen in den
Planning-Lifecycle sind Kennungen ([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
Festlegung 3). Diese ADR ist das Übergabe-Artefakt vor dem Implementer-Zug (Start-Trigger
§4 des Plans; die Rollen-Sequenz trägt Baseline-Regelwerk `modul-08-agentenrollen.md`
§Rollen-Sequenz für einen Slice).
**Schärft:** — Prozess-ADR ohne Spec-Stratum. Der Fast-Pfad ist keine Spec-Stelle;
die Ordnungskante `record-gates: <checks>`
([`spec/architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume))
bleibt von dieser Entscheidung unberührt.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Der Tier-1-Fast-Pfad ([ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md))
SKIPpt über dem gedeckten Paar (Baum-Hash +
`.harness/state/gates-passed.diffsha`, HEAD-Stempel) — jeder Inhalts-Touch entwertet
den ganzen Nachweis und kostet den vollen Lauf. Ein reiner Doku-Commit fährt deshalb
**alle** Checks der Kante neu, obwohl nur `docs-check` einen Prüfgegenstand berührt;
dasselbe gilt spiegelbildlich für jeden Code-Commit. Die Kante trägt heute **zwölf**
Checks (`sed -n 's/^record-gates: //p' Makefile | wc -w` → **12**; kein
Erwartungswert), und jeder von ihnen urteilt über einen **Ausschnitt** des Baums —
exakt der Ausschnitt ist der Schlüssel, den der Tier-2 dem Fast-Pfad und dem
Stop-Hook an die Stelle des ganzen Nachweises setzt. Die Prüfgegenstand-Tafel mit je
Bezugsmenge und Begründung trägt der Plan der Kennung oben (§3, zwölf Zeilen); ein
Check **ohne** zeigbar deckbare Tafel-Zeile fährt voll (Festlegung 1) — die Tafel
trägt darum kein Verdikt, das einen Check still übergeht.

## Entscheidung

Wir wählen: **Je Check der Kante ein Prüfgegenstand-Schlüssel an genau einer
Definition und je Check ein Grün-Stempel; der Fast-Pfad fährt bei Teildrift genau die
gedrifteten Checks und SKIPpt über dem vollständig gedeckten Satz; der Stop-Hook
liest die Mischform; der benannte Rest, CI und die Kante bleiben unverändert.**
Fünf Festlegungen:

1. **Je Check sein Prüfgegenstand, je Check sein Schlüssel.** Der
   Schlüssel-Satzerzeuger (neue Datei der Schicht
   [`harness/tools/`](../../../harness/tools/); der Plan nennt `gates-keys.sh` als
   Platzhalter-Namen, der Name fällt im Implementer-Zug) trägt je Check der Kante
   **eine** deklarierte Bezugsmenge — die Tafel-Zeile des Plans — und berechnet daraus
   den Inhalt-Hash. Deckung wird **gezeigt**, nicht angenommen
   ([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 2, Beweisrichtung; Messrezept je Check im Kopf des Satzerzeugers). Ein
   Check ohne zeigbar deckbare Menge, mit unbekannter oder undefinierter Kennung, und
   jeder Satzerzeuger-Fehler → **voller** Lauf, kein SKIP
   ([`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)).
   Es bleibt **eine** Definition je Bezugsmenge: der Fast-Pfad und der Stop-Hook rufen
   denselben Satzerzeuger auf, statt eine zweite Form desselben Wortes zu pflegen —
   der Drift-Form aus
   [ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 3 entsteht hier nicht wieder.
2. **Ablage.** Je Check eine Stempel-Datei unter `.harness/state/` (nicht-committet,
   gitignored — dieselbe Klasse wie das
   [Stempel-Paar](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
   Festlegung 3). **Die zwei Gesamt-Dateien bleiben unangetastet:**
   `.harness/state/gates-passed.diffsha` und `.harness/state/gates-passed.head` tragen
   Format, Schreiber und Leser unverändert weiter
   ([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
   Festlegung 3 — die Datei hat weitere Leser, ein Formatwechsel bräche sie); die
   je-Check-Keys treten als Vergleichsgröße **daneben** in derselben Klasse, kein
   zweiter Träger desselben Nachweises entsteht. **Die
   [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)-Hash-Ausnahme
   braucht keinen Nachzug:** die je-Check-Keys liegen in `.harness/state/`, das
   gitignored ist und darum nie in der ls-files-Menge des
   [`working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh) lag; die
   committeten Fall-Files der
   [ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) liegen in dem
   von `HASH_AUSNMEN` getragenen Unterbaum `.harness/stamp/mutate` —
   **Record-Konsum rotiert keinen je-Check-Key und keine der zwei Gesamt-Dateien**
   (der Mutations-Fall unten hält beides).
3. **Die Kante bleibt, die SKIP-Bedingung wird fein.**
   `record-gates: <checks>` bleibt byte-gleich — Ziel, Reihenfolge und Wächter
   (Zusagen des Kanten-Wächters; die Mutations-Fälle 213/214 greifen weiter). Der
   volle Lauf **schreibt** je Check nach dessen grünem Exit seinen je-Check-Key;
   ein roter Check hinterlässt keinen und entwertet keinen stehenden Key
   ([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 5-Form auf die je-Check-Ebene). Der Fast-Pfad
   ([`harness/tools/gates-fast.sh`](../../../harness/tools/gates-fast.sh), Tier 2)
   SKIPpt nur über dem **vollständig** gedeckten je-Check-Satz (jeder Key vorhanden
   und deckend) und fährt bei Teildrift **genau die gedrifteten Checks**, danach
   jeweils deren Key. **`GATES_FORCE=1`** bleibt der Träger des benannten Rests
   (siehe Festlegung 4), Name und Werte-Welt unverändert
   ([ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) Festlegung 3);
   die SKIP-Meldung nennt den Rest. **Kein neues Make-Target** — der Schreiber bleibt
   `record-gates`, der SKIP-Anteil bleibt Wrapper. **CI läuft unverändert voll** —
   die Keys reisen nicht mit dem Klon (gitignored), der frische Klon fährt
   fail-closed voll ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)):
   dasselbe Verhältnis wie Tier-1.
4. **Der benannte Rest bleibt je Tier-1, auf die je-Check-Ebene gestellt.** Der lokale
   Docker-Cache-Zustand und die Host-Werkzeuge liegen außerhalb jedes
   baum-abgeleiteten Schlüssels
   ([ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) Festlegung 2,
   [ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
   Festlegung 4); je Check der Kante gilt dieselbe Antwort: die Image-Digests stehen
   in getrackten Dateien und sind damit transitiv im je-Check-Key der vier
   Image-fahrenden Checks (`lint`, `build`, `test`, `host-bin`), der
   Cache-**Zustand** bleibt keine Adresse
   ([`MR-050`](../../../harness/conventions.md#mr-050--zwei-gate-ziele-fahren-ohne---no-cache-filter-weil-ihr-cache-schlüssel-den-prüfgegenstand-deckt)).
   Jede je-Check-SKIP-Meldung nennt den Rest und behauptet kein Check-Ergebnis;
   `GATES_FORCE=1` ist sein behebender Träger, nicht seine Abschaffung.
5. **Stop-Hook: Mischform — die HEAD-Kante unverändert, die je-Check-Deckung
   daneben.** Die Zusagen der
   [ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
   bleiben: Commit-Bindung als Default (Festlegung 1), ein roter Lauf gibt nie frei
   (Festlegung 2), die Stempel-Form der zwei Gesamt-Dateien (Festlegung 3), der
   commitlos-Fall (Festlegung 4), fail-closed über Exit 2 (Festlegung 5),
   `stop_hook_active` und die zwei Schalter-Quellen (Festlegung 6). **Neu** ist das
   **zweite Block-Kriterium daneben:** ein Turn-Ende, das nach der HEAD-Kante über der
   Hash-Gleichheit freiginge, blockt zusätzlich, wenn ein je-Check-Key den
   Prüfgegenstand nicht deckt — die uncommittete Änderung, die heute zwischen
   Turn-Enden über HEAD-Gleichheit schlüpft, fällt dort auf, wo das zugehörige Gate
   sie liest. Fail-closed in beide Richtungen: fehlender oder unformaler Key und
   Satzerzeuger-Fehler blocken, statt freizugeben. **Ein Commit, der allein in der
   Hash-Ausnahme liegt** (Record-only, `.harness/stamp/mutate/`), blockt nicht:
   der
   [`working-tree-hash.sh`](../../../harness/tools/working-tree-hash.sh)-Wert wird
   von der Ausnahme nicht bewegt und kein je-Check-Key rotiert — derselbe
   „Hash gleich“-Zweig, den die
   [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
   Festlegung 2 trägt, jetzt auch über neuem HEAD lesbar. Der strenge Modus
   ([ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
   Festlegung 6) verlässt diese Mischform nicht: seine zwei Quellen zwingen dieselbe
   je-Check-Deckete, nicht einen zweiten Zustand.

**Was dieses ADR nicht trägt:** die emittierten Ziel-Vorlagen bekommen das
je-Check-Konzept nicht (Bestand bleibt bewusst stehen, dieselbe Grenze, die die
ADR-0103-Festlegung 4 für das Hash-Skript benannt hat — Plan Abgrenzung 2); den
Mutations-Treiber fasst es nicht an (Plan Abgrenzung 1; die Fall-Stempel-Form trägt
die [ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md)); einen zweiten
Träger des Handoff-Gate-Zustands führt es nicht (Plan Abgrenzung 3, Festlegung 2 und 5).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Tier-1 unverändertlassen | keine zweite Ablage, kein Satzerzeuger | ein reiner Doku-Commit fährt alle zwölf Checks neu, obwohl nur ein Check seinen Prüfgegenstand berührt — die Kosten bleiben an der Kante statt am Schlüssel (Plan §1) |
| B — der Schlüssel bleibt der Baum-Hash, aber SKIP je Check-Familie (etwa doku vs. code) | kein je-Check-Satzerzeuger, zwei Stämme reichen | die Familien reiten wieder auf Gruppen, die größer sind als der Prüfgegenstand — der SKIP behauptet Deckung, die der Schlüssel nicht trägt ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene tiefer); dieselbe Fassung der ADR-0035-Alternative B, je Check gestellt |
| C — der Stop-Hook liest nur den je-Check-Satz, die HEAD-Kante entfällt | einfache Block-Form | verlässt die Zusagen der ADR-0083 (Commit-Bindung, commitlos-Fall) und entwertet die zwei Gesamt-Dateien, deren Format weitere Leser trägt — die HEAD-Kante ist der Mechanismus, der bereits trägt und dessen Erweiterung hier die einzig neue Seite ist |
| **E — je-Check-Schlüssel + Mischform am Stop-Hook + fast je-Check (gewählt)** | der Fast-Pfad und der Block-Mechanismus lesen dieselbe Definition; CI, Kante und die zwei Gesamt-Dateien bleiben unverändert; der Rest bleibt benannt und behebbar | der Satzerzeuger ist ein drittes Lesen-Skript neben Tier-1-Stempel und Kante — je Check gezeigt werden muss, dass seine Bezugsmenge die Gelesen-Menge deckt; ohne zeigbare Deckung fährt der Check voll (fail-closed), der SKIP schrumpft mit der gezeigten Menge |

## Konsequenzen

- Positiv: ein Reiner Doku-Commit fährt nur `docs-check`; ein reines Code-Commit nur
  die Code-Checks; der Record-only-Commit fährt nichts; der Nachweis blockt feiner
  und bleibt dieselbe `.harness/state/`-Klasse; CI bleibt unverändert.
- Negativ: der benannte Rest aus Festlegung 4 bleibt bestehen — je Check
  konserviert der SKIP das Verdikt auch über Docker-Cache- und Host-Werkzeug-Zuständen,
  `GATES_FORCE=1` macht es behebbar, nicht abwesend. Der Stop-Hook kann ein Turn-Ende
  je Check früher blocken als Tier-1 (Hardening, `Festlegung 5`) — der erste Nach-Befund
  ist dafür der benannte Preis.
- **Kein Eintrag im Adaptions-Block**, nach der Lesart von
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage): der überspringende
  Fast-Pfad hat in der adoptierten Fassung kein Gegensück, von dem abgewichen werden
  könnte (Form der ADR-0099-Antwort, hier fortgesetzt), je-Check-Konzept keine
  Baseline-Fassung.
- Folgepflicht (Implementer-Zug, Tier-2): Wächter-Bestand und Mutations-Fälle unten
  im selben Zug; die Fitness-Messung je Check gegen den gelesenen Bestand
  (Mengen-Messung, kein angenommener Satz); der Fall-Beleg der
  ADR-0107-Fall-Form entfällt hier — die Fall-Form gehört dem Treiber-Zug
  ([ADR-0107](0107-die-mutations-record-granularitaet-ist-je-fall.md) Festlegung 5).

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| bats, [`test/gates-fastpfad.bats`](../../../test/gates-fastpfad.bats) (Tier-2-Fassung) | Happy: vollständig gedeckter je-Check-Satz → SKIP mit Rest-Meldung, kein Check fährt. Teildrift (zwei Keys driften) → genau diese zwei Checks fahren, die übrigen Stempel bleiben byte-gleich. Negative: Key fehlt · trägt einen fremden oder unformalen Wert · Satzerzeuger-Fehler · `GATES_FORCE=1` → voller Lauf | `make test` (in `make gates`) |
| bats, [`test/gate-nachweis-kante.bats`](../../../test/gate-nachweis-kante.bats) (Tier-2-Fassung) | `record-gates: <checks>` byte-gleich; Schreiber bleibt `record-gates`; je Check nach grünem Exit ein Key, die zwei Gesamt-Dateien unverändert | `make test` (in `make gates`) |
| Mutations-Fälle, [`test/mutations/` 212/213/214/637](../../../test/mutations/) | Die vier Bestands-Fälle greifen weiter; ihre `sed`-Anker werden gegen den Quell-Bestand erneut gemessen ([`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)) | `make mutate` |
| Mutations-Fälle, zwei neu (Plan Festlegung 6) | (a) drifted-Check läuft, ungeänderter Check fährt keinen Lauf und behält seinen Stempel byte-gleich · (b) Record-only-Commit rotiert keinen je-Check-Key und keine der zwei Gesamt-Dateien — Anlage je [`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand) / [`MR-090`](../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit) | `make mutate` |

**Was hier nicht behauptet wird:** der Rot-Beleg steht **nicht** in diesem ADR — die
Wächter entstehen erst im Implementer-Zug, und das Einweihungs-Kriterium des Plans
(§5, zwei reale Protokoll-Läufe) misst drei Klassen am realen Wächter
([`AGENTS.md`](../../../AGENTS.md) §3.6). **Was kein Wächter hält:** dass die
Tafel-Begründungen je Check **tragen** — ob die Bezugsmenge dem Gelesenen deckt, wird
im Implementer-Zug je Check gezeigt; mehrheit nicht-zeigbar → Rückführung §4 des Plans.
Auch der benannte Rest hat keine Fehlschlag-Form
([ADR-0035](0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
Festlegung 4-Form).

## Re-Evaluierungs-Trigger

Nicht permanent. Vier beobachtbare Bedingungen, jede einzeln auslösend:

1. **Ein Check tritt in die Kante ein, verlässt sie, oder der Satzerzeuger liest neu
   außerhalb der Tafel-Zeile** — dann ist die Deckung je Check neu zu zeigen, **bevor**
   der Fast-Pfad weiter greifen darf (Form der
   [ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) Trigger 1).
2. **SKIP und erzwungener voller Lauf liefern über demselben je-Check-Stand
   verschiedene Verdikte** (zwei Läufe, denselben Stand) — dann ist der Rest aus
   Festlegung 4 kein Rauschen, sondern ein Weg ins stille Grün, und die SKIP-Bedingung
   ist neu zu wägen; im Extremfall per Folge-ADR mit `Supersedes ADR-0108`
   (Form der
   [ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) Trigger 2).
3. **Die Format-/Ablage-Form der zwei Gesamt-Dateien oder der Konsum des Stop-Hooks
   ändert sich** — eine Folge-ADR zu
   [ADR-0083](0083-handoff-gate-bindet-an-den-commit-nicht-an-jedes-turn-ende.md)
   oder ein Formatwechsel an `.harness/state/gates-passed.*`. Dann ist der Tier-2 vor
   seiner nächsten Lieferung neu gegen die geänderte Form zu halten (Form der
   [ADR-0099](0099-gates-fastpfad-ueber-gedecktem-stempel-paar.md) Trigger 3).
4. **Der emittierte Baum gewinnt das je-Check-Konzept** — oder ein Adopter-Target
   braucht es: dann ist der Konzept-Nachzug in den
   [`internal/emit/templates/`](../../../internal/emit/templates/) eine eigene
   Entscheidung mit eigener Deckungs-Messung (Form der
   [ADR-0103](0103-mutations-records-nach-harness-stamp-mutate-und-die-hash-ausnahme.md)
   Festlegung 4-Rest).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-26 | **Accepted**; Architektur-Übergabe-Artefakt auf den Start-Trigger §4 des Plans der Kennung `slice-gates-pruefgegenstand-stempel-v1` (Implementer-Zug folgt), Annahme durch den Auftraggeber am 2026-11-26 | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
