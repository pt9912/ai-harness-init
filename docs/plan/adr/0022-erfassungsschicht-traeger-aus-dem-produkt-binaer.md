# ADR-0022: Die Erfassungsschicht geht ins Ziel — der Träger ist das laufende Produkt-Binär, Schreiber und Auswertung sind seine Unterkommandos

**Status:** Proposed

**Datum:** 2026-08-23

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die Anforderung, die diese Entscheidung auslöst — **Rang 1** der Source Precedence, 
und sie verlangt den Träger samt Rollen-Typen, Schreiber **und** Auswertung ins Ziel),
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (die Init-Phase und *out-of-the-box grün* — die Zusage, an der der Aufruf-Ort 
und die Nicht-Verdrahtung hängen),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die Aufzählung der emittierten Durchsetzungs-Mechanik — 
sie wächst durch diese Entscheidung **nicht**, weil [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Abgrenzung sich selbst als 
additiv gegen sie stellt), [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die emittierte Anleitung, die die Rollen-Sequenz im Ziel bereits fährt — 
ihr fehlte bisher nur der Typ, unter dem eine Rolle startbar ist), 
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das emittierte Regelwerk, das die drei Observability-Blöcke als **Text** schon trägt), 
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die Zusage aus [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren): *„kann der Träger nicht emittiert werden, wird begründet **nichts** abgelegt — 
kein Hook, der auf ein fehlendes Programm zeigt"* — Festlegung 5 löst sie ein und benennt ihr Gegenbeispiel),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (*dieselbe Tool-Version → derselbe Träger im Ziel* — bei Festlegung 1 eine Konstruktions-Eigenschaft, keine Zusicherung),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (*das Zielrepo bleibt über `bash + git + docker` geschlossen* — die Grenze, an der drei der verglichenen Wege
scheitern), [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die Plattform-Matrix — der gewählte Träger verdoppelt sie nicht, er **ist** sie),
[ADR-0003](0003-go-native-binaries.md) (**Accepted** — native Binaries als Vertriebsform und der
ausdrückliche Verzicht auf ein eigenes OCI-Image als *Vertriebsmittel*; der Grund, an dem der
Bild-Weg scheitert),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — die Phasen-Trennung und die
Idempotenz-Klassifikation; beide tragen Festlegung 4),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — die Erfassungs-Policy; ihre
**Festlegung 5** macht die Festlegungen 1–4 und 6 zum Adopter-Vertrag, sobald das **Ob** durch
einen Change Request entschieden ist, und genau das ist geschehen),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — *„Jede Token-Bilanz aus
diesen Spans ist eine Bilanz über SUBAGENTEN-Läufe und nennt ihren Nenner"*; die Präzedenz, auf
der die emittierte Auswertung steht),
[ADR-0013](0013-technik-stratum-als-zielort.md) (**Accepted** — das Gefäß folgt dem Gegenstand;
ihr Re-Evaluierungs-Trigger stellt die Frage nach dem Zielort der Feldtabelle im Zielrepo für den
Fall, dass Spans emittiert werden, und Festlegung 7 beantwortet sie — Folgepflicht 3 dort *„hält
die heutige Antwort fest, nicht die künftige"*),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (**Accepted** — die Form der Regelwerks-Belege
unten: Tag, Dateiname, Abschnitt, Zitat),
[ADR-0020](0020-emittierte-modul-15-regeln.md) (**Accepted** — die abgelöste Entscheidung; ihr
Umfang steht unten),
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (**Accepted** — das **Zähler-Glied**
bleibt ohne Quelle, und ihre **Folgepflicht 6** entscheidet den Fall, den diese Entscheidung
herbeiführt: *„Bekommt sie je einen, gilt diese Grenze dort unverändert — sie ist keine
Eigenschaft unseres Aufbaus, sondern der Mechanik — und gehört dort genannt, nicht stillschweigend
mitgeliefert."* Festlegung 8 löst sie ein und revidiert aus jener Entscheidung nichts),
[CO-002](../carveouts/CO-002-token-achse-je-rolle.md) (die Vorbedingung des Zähler-Glieds —
verwiesen, nicht abgeschrieben),
[`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)
(der inhaltsbasierte Gate-Nachweis, an dem der Ablageort des Bestands hängt — im Ziel wie hier),
[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (das
tool-generierte Fragment, das **verbatim** ins Ziel geht — die Konstruktion, die Festlegung 7
übernimmt),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(der Change Request, der das **Ob** entschieden hat),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche — Festlegung 5 wendet sie an, Festlegung 6 grenzt
sie ab)

**Revidiert (Teil-Supersede):** aus [ADR-0020](0020-emittierte-modul-15-regeln.md)

- **Festlegung 1** — *„Der Erfassungs-Block wird nicht emittiert, und die Abweichung ist
  permanent"* — **vollständig**. Ihr tragender Grund war die Phasen-Ordnung an **zwei**
  Wegen (*„Quelle plus Bauschritt zur Init-Zeit"* und *„Ein vorgebautes Binär je Zielplattform
  wäre eine neue Artefakt-Klasse mit eigener Distribution und eigener Plattform-Matrix"*); der
  gewählte Weg ist keiner von beiden, und der Vertrag hat den zweiten Einwand ohnehin abgeräumt.
- **Festlegung 2** — *„Die Rollen-Typen gehen nicht mit"* — **vollständig**. Ihre Bedingung
  steht in ihr selbst: *„Die Bedingung, die diese Zelle wieder öffnete, ist **die Emission des
  Erfassungs-Blocks**, gleich auf welchem der beiden dort verworfenen Wege"*.
- **Festlegung 3** — **nur ihr Erfassungs-Glied** (*„erfasst das Ziel überhaupt?"*) und der
  daraus gezogene Zellwert. Das **Zähler-Glied** wird **nicht** revidiert; es steht seit
  [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) auf eigenem, *Accepted* entschiedenem
  Grund. Was aus dem Bruch der Konjunktion folgt, entscheidet Festlegung 8 — und zwar
  **verschieden für den Träger und für die Zahl**.
- **Folgepflicht 6** und die zweite Zeile ihrer Fitness Function — sie verlangen je einen
  Wächter über der **Abwesenheit** von `.claude/agents/`, Span-Emitter und Token-Bericht im Ziel,
  ruhen auf den Festlegungen 1–3 und fallen mit ihnen. An ihre Stelle treten
  **Anwesenheits**-Wächter.

**Nicht revidiert, und darum ausdrücklich benannt:**

- **Festlegung 4 und Festlegung 5** (Doku-Konsistenz-Block, `targets:`-Konfiguration, advisory
  Träger) — unberührt, samt den Folgepflichten 2, 3 und 4.
- **Festlegung 6** (*„Die Erfassung wird auch nicht KONDITIONAL emittiert"*) — sie gilt
  **fort**, und ihr Befund **stützt** die unbedingte Emission, ohne sie zu tragen: der Prüfbereich
  der Telemetrie existiert *„in jedem Ziel"*, es gibt also keine strukturelle Bedingung, die Ziele
  trennt. Derselbe Satz schließt *„nur für manche"* in beide Richtungen aus. **Getragen** wird die
  Unbedingtheit von Festlegung 1 dieser Entscheidung (Geltungsbereich: jede Bootstrap-Variante) —
  eine eingefrorene Festlegung, die die Nicht-Emission nie getragen hat, trägt auch ihr Gegenteil
  nicht.
- **Folgepflicht 1** (*„der Beleg emittiert nichts, was der Dogfood nicht selbst fährt"*) — sie
  ist nicht abgelöst, sondern **bindet diese Entscheidung**; Festlegung 2 und Folgepflicht 1
  unten lösen sie ein.
- **Folgepflicht 5** (*„wird der Erfassungs-Block je emittiert, ist die Policy ein
  Adopter-Vertrag"*) — nicht revidiert, sondern **fällig**; Festlegung 6 und Festlegung 7 leisten
  sie.

**Aus [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) wird nichts revidiert — ihre
Folgepflicht 6 wird eingelöst.** Sie hat den Fall, den diese Entscheidung herbeiführt, selbst
entschieden: bekommt die emittierte Ebene je einen Emitter, gilt die Grenze dort *„unverändert"*
und gehört dort *„genannt, nicht stillschweigend mitgeliefert"*. Festlegung 8 nennt sie,
Festlegung 7 gibt ihr den stehenden Ort. Kein Satz jener Entscheidung wird umgestoßen, und keiner
wird für die emittierte Ebene abgeschwächt.

**Schärft:**
[`spec/spezifikation.md §5 Metriken und Tracing-Felder`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
— dort steht die Feldtabelle, deren Gegenstands-Satz heute ein Binär nennt, das mit Festlegung 2
in ein Unterkommando übergeht; und
[`architecture.md §5 Idempotenz, Fragment-Assembly und Resume`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
— dort steht die Emissions-Mechanik, die mit Festlegung 4 erstmals ein **ausführbares** Artefakt
ablegt. Aufwärts-Deklaration der Änderungskopplung: wer diese Entscheidung ändert, zieht von hier
beide Spec-Stellen nach. **Das Vertrags-Stratum ist nicht berührt:** keine Festlegung bewegt eine
Anforderung — sie setzen eine um, die
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) bereits
abnahmebindend führt.

---

## Kontext

### Was die Entscheidung auslöst

Das Observability-Modul der adoptierten Baseline `v3.5.2` führt vier Regelblöcke —
`modul-15-observability.md` trägt sie als die Abschnitte §Span-/Audit-Attribut-Regeln,
§Token-Attributions-Regeln, §Cache-Counter-Regeln und §Doku-Konsistenz-Drift-Regeln
(`grep -n '^### ' <regelwerk>/modul-15-observability.md` → sieben
Abschnitte, davon diese vier mit Regelblock-Charakter). Drei davon —
Span-/Audit-Attribute, Token-Attribution, Cache-Counter — gingen bis hierher **nicht** ins Ziel,
und ihre Zellen der Konformitäts-Matrix trugen *ADR-Verdikt*: permanent, in einer ADR entschieden,
ohne Auflösungs-Trigger. Der Vertrag verlangt heute das Gegenteil.
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) ist
abnahmebindend und steht auf **Rang 1** der Source Precedence, eine ADR auf Rang 4; die Frage ist
damit nicht mehr *ob*, sondern *wie*.

**Was die Re-Baseline an diesem Modul ändert — gemessen, nicht abgewartet.** Die vier Blöcke tragen
in der neueren Fassung unverändert: dieselben vier Abschnitte, dieselbe Reihenfolge. Zwei inhaltliche
Ergänzungen berühren diese Entscheidung, und beide sind hier benannt, damit die Migration sie nicht
erst entdeckt. **Erstens** stellt `v5.11.0` (`modul-15-observability.md`
§Span-/Audit-Attribut-Regeln) fest: *„Der Emissions-Pfad ist Repo-Entscheidung (Exporter,
Collector, Sampling, Aufbewahrung): Mitzunehmen ist das Schema, nicht das Setup."* Das trifft
diese Entscheidung an ihrer weitesten Stelle — sie gibt dem Ziel Träger, Ablageort **und**
Aufräum-Kommando. Der Widerspruch ist keiner: was das Regelwerk dem Adopter als **seine**
Entscheidung zuschreibt, schreibt
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) als Zusage des
**Werkzeugs** vor, und der Vertrag steht auf Rang 1. Das emittierte Setup ist darum ein
**Startwert**, den der Adopter ändern darf, keine Norm, die ihn bindet — und genau so ist das
Aufräum-Kommando gefasst: als Kommando ohne Automatik. **Zweitens** ersetzt dieselbe Fassung
(§Token-Attributions-Regeln) die feste Rollen-Aufzählung durch *„attribuiert wird damit auf
Kontexte, nicht auf Personen; die Rollen sind die aus Modul 8, festgelegt durch das gestartete
Rollen-Artefakt"* — das **stützt** Festlegung 3: der Rollen-Typ ist der Träger der Achse, und ohne
ihn bliebe sie leer. Beide Stellen sind gegen den Regelwerks-Spiegel des Tags gelesen, nicht gegen
die didaktische Kurs-Fassung.

Drei Sätze der Anforderung binden diese Entscheidung unmittelbar, verbatim:

> Die **Rollen-Typen** unter `.claude/agents/` sind Teil der Emission, nicht ihr Beiwerk — ohne
> sie bliebe das Pflichtfeld `agent.role` dauerhaft leer.

> **Neu ist die Artefakt-Klasse:** jene emittieren Text, diese einen ausführbaren Mechanismus,
> der im fremden Repo etwas *schreibt*. Der **Weg** der Emission ist nicht Gegenstand dieser
> Anforderung.

> **Leser:** Emittiert werden **Schreiber und Auswertung**. Die Auswertung nennt ihre
> **Abdeckung zuerst** und meldet damit ihre eigene Leere: solange keine Verbrauchs-Zähler
> ankommen, trägt sie keine Bilanz — und sagt das, statt eine zu erfinden.

Der mittlere Satz räumt genau den Einwand ab, an dem der zweite der zwei zuvor verworfenen Wege
scheiterte (*„wäre eine neue Artefakt-Klasse …"*): die Klasse ist genehmigt, der Weg ist offen.
Der erste und der dritte legen fest, **was** mitgeht — und der dritte löst die Konjunktion aus
Festlegung 3 der abgelösten Entscheidung selbst auf, indem er nicht eine Bilanz verlangt, sondern
eine Auswertung, die ihre Leere meldet.

Zwei **Re-Evaluierungs-Trigger** der abgelösten Entscheidung greifen, beide verbatim:

> **Wenn der Erfassungs-Block im Ziel entsteht** — auf welchem Weg auch immer *(feedforward — an
> einem frisch gebootstrappten Ziel ablesbar, das bei einem Tool-Call einen Span schreibt)*: dann
> hat die Rollen-Achse im Ziel einen Abnehmer, und Festlegung 2 ist neu zu entscheiden.

> **Wenn eine Folge-ADR eine der Festlegungen umstößt, auf denen die Ausgänge 3, 4 und 5 aus
> Festlegung 1 ruhen** …: der betroffene Ausgang öffnet sich, und die Abzählung ist neu zu führen.

Die Abzählung wird unten neu geführt — nicht, weil einer jener Ausgänge umgestoßen wäre, sondern
weil sie eine andere Frage stellte: *wie erfasst ein Ziel **ohne** Kompilat?* Diese Entscheidung
fragt: **wie kommt das Kompilat ins Ziel?**

### Die Abzählung der Wege — Kriterium zuerst, Mitglieder danach

Eine Zahl allein trägt hier nichts; das Kriterium trägt. Die Frage *„wie kommt ein ausführbarer
Mechanismus in ein fremdes Repo?"* zerfällt vollständig an **einer** Eigenschaft — der **Herkunft
des ausführbaren Bildes**. Es gibt genau vier Möglichkeiten, und jeder konkrete Weg fällt in genau
eine: das Bild **liegt schon vor**, es **entsteht im Ziel**, es wird **geholt**, oder es gibt
**keines**. Die Aufteilung ist erschöpfend, weil sie eine Existenz- und eine Ortsfrage kombiniert.

**Die Klassen sind erschöpfend, die Mitglieder sind es nie von selbst.** Eine Klasse sagt, wohin
ein Kandidat gehört, nicht dass alle gefunden sind — wer einen neuen nennt, ordnet ihn ein und
ergänzt die Zeile, statt das Kriterium zu bestreiten. Und die Herkunft ist **nicht** die einzige
Achse: die **Zeit**, zu der das Bild verfügbar sein muss, trennt Wege innerhalb derselben Klasse.
Ein Träger, der erst zur Hook-Zeit entsteht, stellt andere Fragen als einer, der zur Bootstrap-Zeit
abgelegt wird — die Spalte *Zeitpunkt* führt sie darum mit.

| Herkunft             | Weg                                                                                                        | Zeitpunkt | Ausgang                                                                                                                                           |
| -------------------- | ---------------------------------------------------------------------------------------------------------- | --- | ------------------------------------------------------------------------------------------------------------------------------------------------- |
| **liegt vor**        | das Produkt-Binär selbst (Selbst-Kopie, Unterkommandos)                                                    | Bootstrap | **gewählt** — Festlegung 1                                                                                                                        |
| **liegt vor**        | ein eigenes Emitter-Binär, ins Produkt-Binär eingebettet                                                   | Bootstrap | tragfähig, teurer — Alternative F                                                                                                                 |
| **liegt vor**        | das Produkt-Release als **Multi-Plattform-Archiv**: alle Plattform-Binaries in **einem** Asset, der Bootstrap wählt eines aus | Bootstrap | tragfähig; entkoppelt den Träger vom Bau, **nicht** von Annahme (a) — **Alternative H** |
| **liegt vor**        | ein Binär **committet** im Zielrepo                                                                        | zeitlos | bricht den gitignorierten Ablageort und bindet das Repo an eine Plattform — Alternative I |
| **entsteht im Ziel** | Quelle + Bauschritt mit einer Toolchain des Ziels                                                          | Bootstrap | scheitert an [ADR-0007](0007-bootstrap-phasen.md) und [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — Alternative B |
| **entsteht im Ziel** | Quelle mitliefern, Bau im gepinnten Image zur Bootstrap-Zeit                                               | Bootstrap | ein fremder Quellbaum samt Aktualisierungsweg im Ziel — Alternative C                                                                             |
| **wird geholt**      | Release-Asset über das Netz, **je Plattform ein eigenes**                                                  | Bootstrap | zweiter Vertriebskanal + Verfügbarkeits-Abhängigkeit — Alternative D                                                                              |
| **wird geholt**      | veröffentlichtes, digest-gepinntes OCI-Bild, `docker create`/`docker cp`                                   | Bootstrap | zweiter Vertriebskanal gegen [ADR-0003](0003-go-native-binaries.md); der Beleg liefe gegen ein fremdes Bild — Alternative E                       |
| **keines**           | handgeführter Scanner in vorhandener Laufzeit; oder warten, bis das Werkzeug seine Telemetrie selbst führt | — | gemessen gescheitert bzw. fremder Vertrag — Alternative A                                                                                         |
| **keines**           | `docker run` gegen ein gepinntes Image **je Hook-Aufruf**                                                  | **Hook** | die Schwelle aus [ADR-0011](0011-telemetrie-erfassung-policy.md) bindet je Aufruf statt einmalig — Alternative J |
| **keines**           | kein Artefakt im Ziel; der Hook ruft das Werkzeug aus `PATH`                                               | **Hook** | setzt eine Installation voraus, die kein Bootstrap herstellt — Alternative K |

**Der Mechanismus-Kandidat, der belegt existiert**, gehört in die dritte Klasse:
`harness/tools/artifact-copy.sh` holt ein gebautes Binär aus einem Container-Dateisystem auf den Host —
`cid="$(docker create "$img" true)"` · `trap 'docker rm -f "$cid" >/dev/null 2>&1' EXIT` ·
`docker cp "$cid:$src" "$destdir/$name"` (`sed -n '42,44p' harness/tools/artifact-copy.sh`). Er
ist erprobt und wird unten geprüft, nicht gesetzt — was ihm für die **emittierte** Ebene fehlt,
ist nicht die Mechanik, sondern das **Bild**: der Dogfood baut es aus seinem eigenen Quellbaum
(`docker build … --target span`), ein Adopter hat diesen Baum nicht.

### Was der Dogfood heute selbst fährt — gemessen

Die Frage aus Folgepflicht 1 der abgelösten Entscheidung ist zweiteilig, und die zwei Teile haben
verschiedene Antworten.

- **Die Erfassung: ja.** `grep -n '^gates:' Makefile` zeigt `span-emit-build` und `span-check` in
  der Prerequisite-Kette von `make gates`. Der Emitter wird bei **jedem** Gate-Lauf gebaut und
  danach mit einer synthetischen Payload gegen seinen gitignorierten Ablageort geprüft.
- **Ein Transport eines gebauten Binärs in den gitignorierten Zustands-Bereich: ja.**
  `grep -n 'artifact-copy' Makefile` nennt **drei** Aufrufstellen; die dritte liegt im Rezept von
  `span-emit-build`, also innerhalb von `make gates`.
- **Der Transport, den diese Entscheidung wählt: heute nicht.** Der Dogfood baut den Emitter als
  **eigenes** Binär aus einer eigenen Stage, und der Grund steht im `Dockerfile` verbatim:
  *„EIGENE Stage und EIGENES Binary, KEIN Subkommando von ai-harness-init: ob der EMITTIERTE
  Harness einen Emitter bekommt, entscheidet …"* — die Trennung existiert, um diese Entscheidung
  **nicht vorwegzunehmen**. Dieselbe Begründung steht bei der Auswertungs-Stage. Mit der
  Entscheidung entfällt ihr Anlass; Festlegung 2 zieht die Folge, und Folgepflicht 1 unten macht
  sie zur Schuld.

### Was im Ziel schon liegt und diese Entscheidung trägt

Gemessen am Emissions-Pfad, gelesen statt an einem frischen Ziel gefahren:

- **Der Ablageort existiert.** Die Durchsetzungs-Emission legt `.harness/.gitignore` mit dem
  Eintrag `state/` (`grep -n 'gitignore' internal/emit/enforce.go`,
  `cat internal/emit/templates/enforce/gitignore`). Damit ist die Auflage aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 3 — Ablage **außerhalb** des
  versionierten Baums — im Ziel bereits erfüllt, und der emittierte Gate-Nachweis (er listet mit
  `--exclude-standard`,
  [`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung))
  bleibt vom wachsenden Bestand unberührt. Beides ohne eine einzige neue Zeile.
- **Der Hook-Anker existiert.** Die emittierte `.claude/settings.json` verdrahtet ihre Hooks über
  `"$CLAUDE_PROJECT_DIR"` — repo-relativ, also unabhängig davon, wo der Adopter sein Repo hat.
- **Die Rollen laufen im Ziel bereits.** Die emittierten Workflow-Commands führen die
  Rollen-Sequenz aus; was fehlt, ist der **Typ**, unter dem eine Rolle startbar ist. Die
  Zuordnung Typ → Rolle ist im Emitter eine notierte Sechser-Liste
  (`sed -n '182,189p' internal/span/emit.go`: `planner`, `architect`, `implementer`, `reviewer`,
  `verifier`, `validator`), und dieses Repo führt genau sechs Typ-Dateien
  (`ls -1 .claude/agents/ | wc -l` → **6**).
- **Kein emittiertes Artefakt liest das Verzeichnis.** `grep -rn "claude/agents" --include=*.go . | wc -l`
  → **0**. Die Zahl war der tragende Beleg der abgelösten Festlegung 2 und ist bis heute
  unverändert; mit dieser Entscheidung wird sie zum **Arbeitsauftrag** statt zum Argument.

### Annahmen, auf denen diese Entscheidung steht

Kippt eine, kippt die Entscheidung; alle vier stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Der Bootstrap-Host und die Plattform, auf der die Hooks laufen, sind derselbe Ort.
  Belegt ist davon **nur die erste Hälfte** — der Lauf des Produkt-Binärs belegt seine
  Lauffähigkeit dort, wo es gerade bootstrappt; die Identität beider Orte ist Annahme, nicht
  Beweis. Fällt sie (ein Bootstrap über eine Fernverbindung in ein Repo einer anderen Plattform),
  fällt der tragende Grund von Festlegung 1.
- **(b)** Der Zustands-Bereich des Ziels ist beschreibbar und bleibt gitignored. Fällt das, sind
  Ablageort **und** Träger-Ort neu zu wählen.
- **(c)** Der Aufschlag je Tool-Call bleibt unter der Schwelle aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) (*50 ms im Median*). **Hier nicht gemessen**,
  und ein Sensor darüber existiert nicht
  (`grep -niE 'latenz|latency|median|bench' Makefile d-check.mk` → leer, Exit 1). Die Messung
  steht als **Folgepflicht 9**; ihr Ausgang ist der Trennungs-Trigger.
- **(d)** Das Agenten-Werkzeug liest seine Hook-Konfiguration weiter aus einer Datei im Repo und
  startet Hook-Programme als eigene Prozesse. Fällt das, fällt die Verdrahtung, nicht die Policy.

## Entscheidung

**Wir wählen Weg G: der Träger ist das laufende Produkt-Binär.** Es wird beim Bootstrap in den
gitignorierten Zustands-Bereich des Ziels kopiert; Schreiber und Auswertung sind seine
Unterkommandos. Acht Festlegungen; die vier Zellen der Tool-Spalte tragen danach:

| Modul-15-Regelblock                                                | Wert der Tool-Zelle                                                                                                                                                                                              | Festlegung |
| ------------------------------------------------------------------ | ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ---------- |
| Span-/Audit-Attribute (die Erfassung samt ihrem Pflichtfeld Rolle) | **emittiert** — Schreiber und Rollen-Typen, Beleg geschuldet                                                                                                                                                     | 1, 3, 4, 5 |
| Token-Attribution                                                  | **emittiert** — als Auswertung, die ihre Abdeckung nennt; **keine** Bilanz zugesagt, und die Grenze aus [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) gilt im Ziel unverändert und wird dort genannt | 8          |
| Cache-Counter                                                      | **emittiert** — dieselbe Auswertung, dieselbe Abdeckungs-Aussage, dieselbe genannte Grenze                                                                                                                       | 8          |
| Doku-Konsistenz-Drift                                              | unverändert — [ADR-0020](0020-emittierte-modul-15-regeln.md) Festlegungen 4 und 5                                                                                                                                | —          |

**1. Der Träger ist das ausführbare Bild, dessen Lauffähigkeit auf dem Bootstrap-Host der Lauf
selbst belegt — das Produkt-Binär.** Geltungsbereich: die emittierte Ebene, jede
Bootstrap-Variante. Der Bootstrap kopiert es in den gitignorierten Zustands-Bereich des Ziels.
Vier Eigenschaften folgen daraus **konstruktiv**, nicht als Zusage:

- **Keine zweite Plattform-Matrix.** Der Träger *ist* die Matrix aus
  [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix). Jeder andere Weg muss die
  Plattform des Ziels erst herleiten, raten oder über einen zweiten Kanal treffen; hier liegt sie
  vor, weil das Bild gerade läuft.
- **Kein zweiter Vertriebskanal.** [ADR-0003](0003-go-native-binaries.md) hat die Vertriebsform
  entschieden und ein eigenes OCI-Image als *Vertriebsmittel* ausdrücklich verworfen; diese
  Entscheidung fügt keinen hinzu.
- **Kein Netz und kein Bauschritt zur Bootstrap-Zeit** für den Träger. Das Ziel bleibt über
  `bash + git + docker` geschlossen
  ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)).
- **[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) ist erfüllt, ohne dass
  jemand es zusichert.** *Dieselbe Tool-Version → derselbe Träger* ist bei einer Kopie eine
  Tautologie — und das ist hier ein Vorzug, kein Mangel: eine Eigenschaft, die niemand herstellen
  muss, kann auch niemand brechen.

**Was der Lauf belegt, und was er nicht belegt.** Belegt ist die Lauffähigkeit auf dem Host, der
den Bootstrap **ausführt**; mehr sagt ein laufendes Bild nicht. Gebraucht wird sie dort, wo die
**Hooks** laufen, und dass beides derselbe Ort ist, steht als **Annahme (a)** mit
Re-Evaluierungs-Trigger — nicht als Beweis. Die Lücke schließt auch
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) nicht: seine Messmethode sagt
für die drei Start-Smoke-Plattformen ausdrücklich, der Start-Smoke belege, *„dass das Binary auf
der Plattform läuft — nicht, dass ein Bootstrap dort durchläuft"*.

**Der tragende Grund ist der Preis, und das ist keine Verlegenheit.** Die vier Eigenschaften oben
wählen die **Herkunfts-Klasse**, nicht ihr Mitglied: Alternative F teilt sie vollständig. Zwischen
den beiden entscheidet allein, was jede kostet — und F kostet drei Dinge, die G nicht kostet. Ihre
Einbettung verlangt die Datei zur Übersetzungszeit **jeder** Stufe, also einen committeten
Platzhalter, der aussieht wie ein Träger und keiner ist;
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) verlangt Schreiber
**und** Auswertung, also zwei solcher Blobs; und der Produkt-Bau hinge am Emitter-Bau derselben
Plattform. G legt statt dessen nichts an, was es nicht ohnehin gibt. Was F dafür bietet — ein
Träger, der **konstruktiv** kein Repo bootstrappen kann —, ist der Gegenposten, und er ist unten
als Contra von G benannt.

**Was Annahme (a) trägt und was nicht.** Fällt sie, weil Bootstrap-Host und Hook-Plattform
auseinanderfallen, dann fällt sie für **F ebenso** — sein eingebettetes Binär hat dieselbe
Plattform-Bindung. Der Trigger unten sagt darum nicht *„dann F"*, sondern stellt die
Plattform-Frage neu; **der Weg, der sie ohne diese Annahme beantwortet, ist Alternative H**.

**Warum G und nicht H — und was H wirklich löst.** Alternative H trägt alle Plattform-Binaries in
**einem** Asset; damit hängt das abzulegende Bild nicht mehr am **Bau**, und ein Ziel könnte einen
Träger für eine andere Plattform bekommen als die des Bootstrap-Hosts. **Annahme (a) hebt das
allein nicht auf**, und diese Grenze ist der Kern: der Bootstrap kennt **seine** Plattform, nicht
die des Ziels. Wählt er nach der eigenen, steht er im Fehlerfall genau wie G; wählt er nach der des
Ziels, braucht er eine Angabe — eine neue Eingabe, die es heute nicht gibt und die
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) in keinem seiner
Akzeptanzkriterien kennt. H verschiebt die Frage von *„läuft das Bild hier?"* zu *„wer sagt, wofür
es abgelegt wird?"* — sie wird damit **stellbar**, nicht beantwortet.

Auch die Mechanik trägt weniger weit, als der Vergleich nahelegt. Vorhanden und gehärtet ist die
**Fetch- und Entpack-Sequenz** (`internal/fetch/baseline.go`: sha256-Pin vor dem Entpacken,
Größenschranke davor, typisierte Fehler); **nicht** vorhanden ist die Auswahl, auf die es H
ankäme — jene Sequenz holt ein **Text**-Bundle und entpackt seine Bäume unbedingt
(`grep -rnE 'GOOS|GOARCH|runtime\.|platform' internal/fetch/baseline.go` → leer, Exit 1). Was H
darüber hinaus kostet, liegt in der
**Vertriebsform**: der Release-Lauf lädt heute die nackten Binaries der
Plattform-Matrix hoch (`grep -n 'gh release upload .*dist' .github/workflows/release.yml` → eine
Zeile, `dist/*`; die Matrix selbst nennt `grep -n '^RELEASE_PLATFORMS' Makefile`), und der
Start-Smoke prüft je Plattform genau eine solche Datei. Ein Archiv verlangt beides neu — und lässt jeden
Adopter alle Binaries für eines laden, in einer Größe, die hier **ungemessen** ist.

**Die Wahl fällt auf G, solange die Annahme hält, und der Preis dafür steht in ihr:** kein Fall
ist bekannt, in dem Bootstrap-Host und Hook-Plattform auseinanderfallen. Tritt einer auf, ist H
der nächstliegende Ausgang — nicht weil er die Frage erledigt, sondern weil er sie **stellbar**
macht: er braucht dann eine Plattform-Angabe, und die zu entscheiden ist billiger als ein zweiter
Vertriebskanal. **Wer G für zu schmal hält, greift Annahme (a) an, nicht die
Alternativen-Tabelle.**

**Warum das die Phasen-Ordnung nicht invertiert — der Punkt, an dem die abgelöste Begründung
hing.** [ADR-0007](0007-bootstrap-phasen.md) verwirft, dem Ziel **Code vor seiner eigenen
Doc-Chain und vor seinem Sprach-ADR** zu geben; die Sprachwahl ist eine ADR-Entscheidung des
Adopters. Der Träger ist **nicht der Code des Ziels**: er wird dort nicht übersetzt, er verlangt
keine Toolchain, er trifft keine Sprach-Aussage, und er liegt außerhalb des versionierten Baums.
Nach dem Init hat das Ziel weiterhin kein Sprach-Fragment, kein Manifest und kein Skelett. Bewacht
ist davon **das erste Glied**: der Abwesenheits-Wächter in `internal/emit/enforce_test.go` prüft,
dass `EnforcePaths` kein `blocked/`-Fragment trägt und dass `Enforce` sprachlos keines anlegt. Für
Manifest und Skelett hält ihn nichts (`grep -rn 'go\.mod\|Skelett\|Manifest' internal/emit/*_test.go`
→ leer, Exit 1); dass beide ausbleiben, folgt aus der Konstruktion dieser Entscheidung und ist
keine gemessene Zusage. Was [ADR-0007](0007-bootstrap-phasen.md) verbietet, ist ein **Bauschritt** im Ziel; das ist
Alternative B, nicht dieser Weg.

**2. Schreiber und Auswertung sind Unterkommandos desselben Trägers — und der Dogfood fährt
denselben Einstiegspunkt.**
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) verlangt beide;
ein Träger trägt beide, ohne dass ein zweites Artefakt entsteht. Der Dogfood zieht nach: die
eigenen Emitter- und Auswertungs-Binaries werden zu Unterkommandos desselben Programms, und der
Hook dieses Repos ruft denselben Einstiegspunkt wie der des Ziels. **Das ist die Einlösung von
Folgepflicht 1 der abgelösten Entscheidung, nicht ihre Umgehung:** ohne den Nachzug emittierte
der Beleg einen Einstiegspunkt, den der Dogfood nie ausführt — und der Einstiegspunkt trägt genau
die zwei Eigenschaften, die [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 6 nicht
verhandelbar nennt (*„Der Emitter gibt auf stdout nichts aus"*, *„Sein Exit-Code ist hart auf 0
geklemmt"*). Ein unerprobter Einstiegspunkt ist genau die Stelle, an der eine fail-open-Zusage
still bricht.

**Der Umbau schrumpft die Konstruktion, statt sie zu vergrößern:** die **zwei** Bau-Stufen des
getrennten Wegs entfallen (`grep -nE '^FROM .* AS (span|report)$' Dockerfile` → zwei Zeilen), und
das Bau-Ziel, das den Emitter heute aus einer eigenen Stage auf den Host holt, verliert seinen
Gegenstand (`grep -c '^span-emit-build:' Makefile` → **1**). Ein Programm bleibt. Die Auswertung
wechselt dabei vom Container auf den Host — im Ziel gibt es keine Bau-Stufe, aus der sie laufen
könnte, und ein Adopter soll für einen Bericht keinen Container starten müssen.

**3. Die Rollen-Typen gehen mit — generisch, Tool-als-Quelle, `skip-if-present`.**
Geltungsbereich: `.claude/agents/` im Ziel. Emittiert wird **nicht** die Kopie der sechs Dateien
dieses Repos: sie tragen dessen Slices, Konventionen und Befunde. Emittiert wird eine generische,
aus Dogfood und Regelwerk abgeleitete Fassung — dieselbe Herkunftsklasse wie die
Durchsetzungs-Mechanik und die Workflow-Commands. Dass eine solche Fassung überhaupt möglich ist,
sagt das Regelwerk selbst (`v3.5.2`, `modul-08-agentenrollen.md` §Rollen-Regeln): *„Rollen-Trennung
ist Kontext-Trennung, nicht Personen-Trennung. Eine Person kann mehrere Rollen spielen — aber nicht
im selben Kontextfenster, sonst wiederholen sich blinde Flecken."* Ein Rollen-Typ trägt danach
einen **Kontext-Zuschnitt**, keinen Repo-Inhalt; genau das macht die generische Fassung tragfähig
und die Kopie unserer sechs Dateien falsch. Die **Idempotenz-Klasse folgt den Commands**
(`skip-if-present`, [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3): ein Rollen-Typ ist ein
Text, den der Adopter an sein Repo anpasst; ein Re-Lauf, der ihn zurücksetzte, wäre derselbe
Clobber, den jene Entscheidung für die Commands ausgeschlossen hat.

**Die Kopplung wird benannt, nicht geschlossen.** Der Träger füllt `agent.role` genau dann, wenn
der Agenten-Typ eine der sechs kanonischen Rollen **nennt**; benennt der Adopter seine Typen um,
bleibt das Feld **leer**, und leer heißt *unbekannt*, nie *rollenlos*
([`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren): *„leer heißt
**unbekannt**, nie rollenlos"*). Das ist keine Nachlässigkeit, sondern dieselbe Grenze, die die
Anforderung selbst ausspricht: *„Die emittierte Ebene führt keinen Wächter über die Aufrufform des
Agenten-Werkzeugs; die Rollen-Achse ruht dort auf Adopter-Disziplin."* Die emittierte Auswertung
macht die Folge sichtbar, indem sie den Sammelposten ausweist — der Weg, den
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) für den Dogfood schon geht.

**Die emittierten Typ-Dateien sind gate-sicher zu halten.** Die emittierte `.d-check.yml` fährt
`modules: [links, anchors]` über `roots: ["."]`; ein toter relativer Verweis in einer Typ-Datei
färbt das `make gates` eines frischen Ziels rot und bräche
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen).

**4. Der Aufruf-Ort ist die Init-Phase, und zwar die Emission der Durchsetzungs-Mechanik.**
Geltungsbereich: [ADR-0007](0007-bootstrap-phasen.md) Festlegung 1. Die Erfassung ist
**sprach-agnostisch** — sie beobachtet Werkzeug-Aufrufe, und die entstehen in jedem Ziel; sie
gehört damit in dieselbe Phase wie Guard, Stop-Hook und Gate-Nachweis, mit denen sie sich die
Hook-Konfiguration teilt. Der Ort ist nicht Bequemlichkeit: Träger, Wrapper und Hook-Eintrag sind
**eine** Entscheidung (Festlegung 5), und drei Emissionsstellen für einen Vertrag wären drei
Stellen, an denen er zerfällt. Die Idempotenz-Klassen je Artefakt:

| Artefakt                                                                  | Klasse                       | Warum                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                        |
| ------------------------------------------------------------------------- | ---------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| der Träger im gitignorierten Zustands-Bereich                             | **konvergent**, nie geprunt  | reine tool-erzeugte Infrastruktur; ein Re-Lauf heilt Drift und zieht eine neue Tool-Version nach                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| der Hook-Wrapper unter `.claude/hooks/`                                   | **konvergent**               | dieselbe Klasse wie die übrigen Hook-Skripte in [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
| `.claude/settings.json`                                                   | **konvergent** (unverändert) | tool-eigen; der Erfassungs-Block darin entsteht nur unter der Bedingung aus Festlegung 5 — ein Re-Lauf, der ihn nicht setzen kann, **entfernt** ihn, damit die Konfiguration die Wirklichkeit beschreibt. **Neu an der Klasse, und darum ausgesprochen:** der kanonische Inhalt hängt hier erstmals an einem **Laufzeit-Ausgang**; zwei Läufe derselben Tool-Version erzeugen verschiedene Bytes, wenn die Ablage des Trägers beim einen gelingt und beim anderen nicht. Das ist gewollt — es trägt die [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Zusage aus Festlegung 5 —, und [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) bindet die Bytes damit an dieselbe Tool-Version **und** denselben Ausgang, nicht an die Version allein |
| die Rollen-Typen unter `.claude/agents/`                                  | **skip-if-present**          | Adopter-adaptierter Text, Klasse wie die Commands (Festlegung 3)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| die Feldliste im geprüften Doku-Bereich                                   | **konvergent**               | tool-generiert, verbatim abgelegt (Festlegung 7)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                             |
| das Aufräum- und Berichts-Fragment im Gate-Fragment-Verzeichnis des Ziels | **konvergent**               | tool-eigenes Gate-Fragment, Muster [`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |

**Ein Nebeneffekt auf die nicht revidierte Festlegung 4 der abgelösten Entscheidung, benannt statt
übersehen:** deren `targets:`-Datei-Satz nennt die Init-invarianten Dateien namentlich und sagt
dazu ausdrücklich, *„Das Kriterium ist keine Liste, sondern eine Eigenschaft"* — genannt wird, was
die emittierende Phase selbst schreibt. Kommt mit dieser Entscheidung ein **weiteres**
Init-invariantes Fragment hinzu, gehört es nach diesem Kriterium in den Satz. Wer die dort
genannten Namen abschreibt statt das Kriterium anzuwenden, erzeugt genau den Befund, den jene
Entscheidung an Sonden gegen das gepinnte Image vermessen hat. Umgekehrt darf ein emittierter
Doku-Tisch die neuen Ziele nennen — sie sind Init-invariant.

**5. Der Hook zeigt auf einen mitgelieferten Wrapper, und der Hook-Eintrag entsteht nur mit dem
Träger.** Zwei Fehlerbilder sind zu trennen, und sie haben verschiedene Adressaten.

- **(a) Die Emission scheitert.** Kann der Träger nicht abgelegt werden, wird **weder** Träger
  **noch** Wrapper **noch** Hook-Eintrag geschrieben, der Bootstrap nennt den Grund und endet
  erfolgreich; das Ziel ist ohne Erfassung vollständig und sein `make gates` grün. Das ist die
  Zusage aus
  [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) wörtlich, und
  ihr **Gegenbeispiel ist benannt**: wird die Kopplung aufgehoben und der Hook-Eintrag
  unbedingt geschrieben, muss der Wächter rot werden. Ohne dieses Rot wäre die Zusage eine
  Absicht ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **(b) Der Träger fehlt später.** Er liegt gitignored — ein **frischer Klon des Adopter-Repos
  hat ihn nicht**, und ein Aufräum-Lauf kann ihn entfernen. Zeigte die Konfiguration direkt auf
  ihn, wäre genau das *„ein Hook, der auf ein fehlendes Programm zeigt"*, nur zeitversetzt.
  Deshalb nennt die Konfiguration einen **committeten Wrapper**, und der schweigt und endet
  erfolgreich, wenn der Träger fehlt — die Betriebsart, die
  [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 6 ohnehin verlangt.
  **Der Preis wird ausgesprochen:** ein Ziel kann dann still nichts erfassen. Sichtbar wird das
  **beim Leser**, nicht beim Schreiber — dieselbe Konstruktion, mit der jene Entscheidung schon
  den verlorenen Span sichtbar macht (Folgepflicht 4 dort: *„der Verlust wird beim LESER sichtbar,
  nicht beim Schreiber"*). Die Auswertung nennt ihre Abdeckung zuerst; ein leerer Bestand meldet
  sich als leer.
- **(c) Ein Ziel-seitiger Wächter über der Anwesenheit des Trägers ist ausgeschlossen, nicht
  vergessen.** Er machte jeden frischen Klon out-of-the-box rot und bräche
  [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen). Wiederhergestellt wird
  der Träger durch einen erneuten Tool-Lauf — der Checkpoint ist das Repo selbst
  ([ADR-0007](0007-bootstrap-phasen.md) Festlegung 5), und ein Re-Lauf ist idempotent. Der
  Wächter, den dieses Repo für **sich** führt (`span-check` in `make gates`), bleibt dort und geht
  **nicht** mit; hier heilt ihn ein Bau, im Ziel könnte ihn nichts heilen.
  [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  entscheidet die **Schärfe** emittierter Prüfbereiche, nicht die **Aufhängung** eines Trägers —
  dieselbe Abgrenzung, die die abgelöste Entscheidung für ihren advisory Träger gezogen hat.

**6. Der Adopter-Vertrag: die Policy gilt unverändert, und vier Stücke sind eigenständig.**
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 5 hat den Fall vorentschieden,
verbatim: *„**Wird emittiert, gelten die Festlegungen 1–4 und 6 unverändert**"* — geschlossenes
Schema mit fail-closed Default für unbekannte Werkzeuge, **abgeleitete** Argument-Werte **ohne**
Inhalts-Hash, Ablage außerhalb des versionierten Baums mit restriktivem Modus und Strom je
(Sitzung, Agent), keine zu installierende Laufzeit, fail-open im Betrieb mit sprech-unfähigem
Emitter. Das **Ob** hat der Change Request entschieden; damit ist der Satz eingelöst, und der Satz
der abgelösten Entscheidung — *„Was [ADR-0011](0011-telemetrie-erfassung-policy.md) für den
Dogfood entschieden hat, ist damit nicht automatisch ein Adopter-Vertrag"* — bleibt richtig und
ist hier **ausdrücklich** vollzogen statt unterstellt.

Vier Stücke entscheidet jene Quelle **nicht**, und sie stehen darum hier:

1. **Die Lesbarkeit der Feldliste im Zielrepo.** Jene Festlegung 1 verwies auf ein
   Struktur-Artefakt **dieses** Repos; im Ziel gibt es keines, das uns gehört. Festlegung 7.
2. **Das Aufräum-Kommando als Vertrag statt als Betriebsgewohnheit.** Jene Festlegung 3 nennt
   *„ein `make`-Ziel, kein Automatismus"* für den Dogfood;
   [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) macht daraus
   eine **Zusage** samt ausgesprochener **Nicht**-Zusage (*„Eine automatische Rotation ist nicht
   Teil der Zusage — ein Löschpfad in einem fail-open-Hook über fremden Daten wäre der teurere
   Fehlerfall."*). Das Ziel bekommt das Kommando und den Satz, dass sein Bestand ohne dessen
   Aufruf unbegrenzt wächst.
3. **Die ausgesprochene Nicht-Zusage über den Bestand.** Das Bedrohungsmodell jener Quelle ruht
   auf einer bekannten Vertrauensgrenze (*„Wer sie lesen kann, kann auch die Dateien lesen"*) —
   im fremden Repo gilt das nicht, und jene Quelle sagt es selbst als dritten Grund. Im Ziel wird
   daraus ein **geschriebener** Satz: der Bestand ist gitignored, nicht verschlüsselt, nicht
   zugriffsbeschränkt, und Pfadnamen sind nicht als unkritisch zugesagt.
4. **Die Rollen-Typen und die Auswertung.** Beide kommen in jener Quelle nicht vor; Festlegungen
   3 und 8.

**7. Die Feldliste lebt im Ziel als tool-generiertes Dokument im geprüften Doku-Bereich — nicht
im Technik-Stratum des Adopters.** Das beantwortet mit **Nein** die Frage, die
[ADR-0013](0013-technik-stratum-als-zielort.md) in ihrem Re-Evaluierungs-Trigger für genau diesen
Fall offengelassen hat — *„Wenn Spans emittiert werden … dann ist zu entscheiden, ob das Zielrepo
die Feldtabelle in seinem Technik-Stratum mitbekommt"* —, und zwar aus dem Grund jener
Entscheidung selbst: das Gefäß folgt dem Gegenstand. Das Technik-Stratum des Ziels ist
`skip-if-present` und gehört dem Adopter — eine Tabelle, die wir dort hineinschrieben, könnte ein
Re-Lauf nie nachziehen und driftete mit der ersten Schema-Änderung. Der Zielort ist stattdessen
ein **tool-eigenes, konvergentes** Dokument, und es wird **aus dem Träger erzeugt**, nicht von
Hand gepflegt — dieselbe Konstruktion, mit der das Doc-Gate-Fragment verbatim aus dem Werkzeug ins
Ziel geht
([`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)). Damit
ist Drift zwischen erfasstem und dokumentiertem Feld **konstruktiv** ausgeschlossen statt per
Regel verboten. Es liegt im vom Doku-Gate des Ziels **geprüften** Bereich (nicht unter
`.harness/**`, das die emittierte `.d-check.yml` ausnimmt): der Baum dort ist derivativer,
nicht repo-autoritativer Inhalt, die Feldliste dagegen ist eine **Aussage an den Adopter**.
Sie trägt zugleich die zwei Grenzen, die dort **genannt** gehören und die kein Sensor hält: dass
die emittierte Ebene keinen Wächter über die Aufrufform des Agenten-Werkzeugs führt — das verlangt
die abgelöste Folgepflicht 5 (*„Zugleich gehört dort genannt, dass die emittierte Ebene keinen
Agent-Guard führt"*) —, und dass die Verbrauchs-Zähler aus der Mechanik des Agenten-Werkzeugs
nicht kommen, was
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 verlangt und Festlegung 8
ausführt. Beide gehören hierher, weil sie auch dann gelten, wenn niemand die Auswertung ruft.

**8. Token-Attribution und Cache-Counter: das Erfassungs-Glied fällt, das Zähler-Glied nicht —
emittiert wird die Auswertung, nicht die Bilanz.** Die abgelöste Festlegung 3 hing an einer
Konjunktion. Die Glieder stehen heute verschieden:

- **Das Erfassungs-Glied** (*erfasst das Ziel überhaupt?*) ist mit Festlegung 1 **wahr**. Es ist
  damit revidiert, und mit ihm der Satz *„ein Ziel, das nicht erfasst, hat nichts zu verrechnen"*.
- **Das Zähler-Glied** (*trägt ein `Agent`-Span Rolle und Zähler?*) ist **verschlossen**, und
  zwar seit [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) auf eigenem, *Accepted*
  entschiedenem Grund statt als Vorbedingung eines Carveouts. Entschieden ist es dort für den
  Dogfood; sein Grund hängt nicht am Dogfood. Es wird hier **nicht** revidiert.
- **Die Grenze gilt im Ziel unverändert, und sie gehört dort genannt — das ist der Kern.**
  [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 hat genau den Fall
  vorentschieden, den diese Entscheidung herbeiführt: *„Bekommt sie je einen, gilt diese Grenze
  dort unverändert — sie ist keine Eigenschaft unseres Aufbaus, sondern der Mechanik — und gehört
  dort genannt, nicht stillschweigend mitgeliefert."* Der tragende Grund jener Entscheidung liegt
  im **fremden Vertrag**: sie zählt die zwei verbliebenen Wege dort ab und stellt fest, *„Kein
  Aufwand dieses Repos bringt eines von beiden herbei."* Das Agenten-Werkzeug ist auf der
  emittierten Ebene dasselbe; trägt ein Adopter-Bestand Verbrauchs-Zähler, dann trägt einer jener
  zwei fremden Wege — und das ist die Richtung, auf die es ankommt, denn sie macht eine
  Folge-Entscheidung fällig. **Die Rückrichtung gilt nicht ohne Zusatz:** jene Entscheidung knüpft
  jeden der zwei Wege an eine weitere Bedingung — eine Vordergrund-Form *„wirkt nur, wenn jemand
  sie liest"*, und ein Ereignis muss verdrahtet sein —, und ob ein Adopter sie erfüllt, entscheidet
  er, nicht diese ADR. Gemeinsam ist beiden Ebenen allein die **Mechanik**, aus der die Zähler
  kommen müssten; mehr braucht die Aussage nicht, und mehr behauptet sie nicht. Diese Entscheidung
  sagt darum über einen Adopter **nichts** zu, was jene nicht schon über die Mechanik gesagt hat,
  und sie revidiert daran nichts.

**Daraus die Festlegung:** emittiert wird der **Leser**, nicht die **Zahl**. Die Auswertung nennt
ihre **Abdeckung zuerst** und meldet über einem Bestand ohne Zähler ihre Leere; sie behauptet
keine Bilanz. **Damit ist der Einwand entkräftet, mit dem die abgelöste Entscheidung die
Voll-Emission verwarf** (*„ein Bericht, der nie eine Zahl trägt, ist die Gate-Lüge als
Kennzahl"*): gelogen hätte ein Bericht, der eine Bilanz behauptet; ein Bericht, der seinen Nenner
und seine Abdeckung nennt, ist genau das Gegenteil — die Form, die
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) für den Dogfood erzwungen hat.

**Eine leere Bilanz ist noch keine genannte Grenze — deshalb zwei Orte statt einem.** Eine
Abdeckungs-Zeile über einem Bestand ohne Zähler meldet einen **Zustand** und lässt offen, ob er
morgen anders ist; die Folgepflicht verlangt die **Grenze**: dass die Zähler an der Mechanik des
Agenten-Werkzeugs hängen und kein Lauf des Adopters sie herbeiführt. Sie wird darum an zwei Orten
gesagt — (i) von der Auswertung selbst, die dort, wo sie ihre Leere meldet, deren **Grund** nennt
und ihn von einem bloß leeren Bestand unterscheidet, und (ii) vom emittierten
Feldlisten-Dokument aus Festlegung 7, das sie **stehend** führt, auch wenn niemand die Auswertung
ruft. Die Einlösung von [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6
ist damit ein **Ergebnis** dieser Entscheidung, kein Nebenprodukt ihrer Ausgabe-Form.

**Und die Auswertung wird im Ziel nicht verdrahtet.** Sie prüft nichts und färbt nichts rot; ein
Gate über ihr wäre eines über leerem Prüfbereich
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — genau
die Einordnung, die dieses Repo für seinen eigenen Bericht schon trifft. Das Ziel bekommt das
Kommando, nicht die Aufhängung.

## Verglichene Alternativen

| Option                                                                                                                                               | Pro                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                       | Contra                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                              |
| ---------------------------------------------------------------------------------------------------------------------------------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| A — **kein eigenes Kompilat**: handgeführter Scanner in einer vorhandenen Laufzeit, oder warten, bis das Werkzeug seine Telemetrie selbst führt      | kein Artefakt, keine Distribution, keine Plattform-Frage                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | gemessen gescheitert und im Code begründet (`internal/span/span.go`, verbatim: *„die awk-Fassung erkannte `error` nur als Top-Level-String und meldete "ok" fuer einen fehlgeschlagenen Aufruf"*) — fail-open hat gegen die stille Lücke eines handgeführten Scanners keine Kompensation; und der fremde Vertrag ist kein Weg, sondern ein Warten, während [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) heute abnahmebindend ist                                                |
| B — **Quelle + Bauschritt zur Init-Zeit**, Toolchain des Ziels                                                                                       | kein mitgeliefertes Binär; das Ziel baut, was es fährt                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | gibt dem Ziel Code und eine Toolchain vor seiner Doc-Chain und seinem Sprach-ADR — die Inversion, gegen die [ADR-0007](0007-bootstrap-phasen.md) entschieden hat; und [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) hält das Ziel auf `bash + git + docker`                                                                                                                                                                                                                           |
| C — **Quelle mitliefern, Bau im gepinnten Image** zur Bootstrap-Zeit                                                                                 | keine Host-Toolchain; die Plattform ist über die Bau-Schalter erreichbar                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | das Ziel bekäme einen **fremden Quellbaum samt Bauschritt und Aktualisierungsweg** — derselbe Preis, den die abgelöste Festlegung 6 für die konditionale Variante beziffert hat; dazu Bauzeit und Netz bei **jedem** Bootstrap                                                                                                                                                                                                                                                                                      |
| D — **Release-Asset über das Netz holen**                                                                                                            | ein Artefakt je Plattform, unabhängig vom Produkt-Binär                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   | zweiter Vertriebskanal samt Prüfsummen-Mechanik; eine Verfügbarkeits-Abhängigkeit im Bootstrap; und das Asset einer Version existiert nicht, bevor sie veröffentlicht ist — der Beleg liefe gegen ein fremdes                                                                                                                                                                                                                                                                                                       |
| E — **veröffentlichtes, digest-gepinntes OCI-Bild** + `docker create`/`docker cp`                                                                    | **der Mechanismus, den der Dogfood heute selbst fährt** (`harness/tools/artifact-copy.sh`, gerufen aus dem Rezept, das in `make gates` steht); digest-gepinnt und damit reproduzierbar                                                                                                                                                                                                                                                                                                                                                                                                                    | verlangt genau das **eigene OCI-Image als Vertriebsmittel**, auf das [ADR-0003](0003-go-native-binaries.md) verzichtet hat, mit derselben Begründung, die dort steht (*native Binaries sind bereits plattformübergreifend*); das Bild eines Standes kann **nicht** von dem Stand erzeugt werden, der es verbraucht — der Beleg prüfte einen fremden, früheren Träger, und *„was ins Ziel geht, ist hier erprobt"* hielte nicht; ob `docker create` über ein Bild fremder Architektur trägt, ist hier **ungemessen** |
| F — **eigenes Emitter-Binär, ins Produkt-Binär eingebettet**                                                                                         | dieselben vier Konstruktions-Eigenschaften wie G; der Träger kann **konstruktiv** kein Repo bootstrappen — die kleinste Fähigkeitsfläche                                                                                                                                                                                                                                                                                                                                                                                                                                                                  | der Produkt-Bau hängt am Emitter-Bau derselben Plattform, und die Einbettung verlangt die Datei zur Übersetzungszeit **jeder** Stufe — also einen committeten Platzhalter, der aussieht wie ein Träger und keiner ist; [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) verlangt Schreiber **und** Auswertung, also zwei Blobs. Gleiche Eigenschaften, höherer Preis                                                                                                                |
| **G — der Träger IST das Produkt-Binär: Selbst-Kopie in den gitignorierten Zustands-Bereich, Schreiber und Auswertung als Unterkommandos (gewählt)** | die Plattform des Bootstrap-Hosts liegt vor, statt hergeleitet, geraten oder über einen zweiten Kanal getroffen zu werden (die Identität mit der Hook-Plattform ist Annahme (a), nicht Beweis); kein zweiter Kanal, kein Netz, kein Bauschritt, keine zweite Matrix; [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) durch Konstruktion; der Dogfood kann **denselben** Einstiegspunkt fahren, womit Folgepflicht 1 der abgelösten Entscheidung eingelöst statt umgangen wird; die Konstruktion schrumpft um die zwei Bau-Stufen des getrennten Wegs (`grep -nE '^FROM .* AS (span\|report)$' Dockerfile` → zwei Zeilen)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                | der Hook startet je Tool-Call das Produkt-Binär — die Schwelle aus [ADR-0011](0011-telemetrie-erfassung-policy.md) bindet und ist **hier nicht gemessen**; der abgelegte Träger trägt die Bootstrap-Fähigkeit mit sich, die Alternative F konstruktiv ausschlösse |
| **H — das Produkt-Release als Multi-Plattform-Archiv**: ein Asset trägt alle Plattform-Binaries, der Bootstrap wählt eines aus und legt es ab | der Träger hängt nicht mehr am **Bau**: das abzulegende Bild muss nicht das laufende sein, und ein Ziel kann einen Träger für eine **andere** Plattform bekommen als die des Bootstrap-Hosts — vorausgesetzt, jemand nennt sie; kein committeter Platzhalter wie bei F, kein Bauschritt, keine zweite Plattform-Matrix — das Archiv **ist** sie; die Fetch- und Entpack-Sequenz ist im Produkt vorhanden und gehärtet (`internal/fetch/baseline.go`: sha256-Pin **vor** dem Entpacken, Größenschranke davor, typisierte Fehler, die [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) und [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) im Text nennen), und ein Archiv liest die Standardbibliothek, nicht `unzip` | **die Auswahl selbst existiert nicht** — jene Sequenz holt ein **Text**-Bundle und entpackt seine Bäume unbedingt; Plattform-Logik trägt sie keine (`grep -rnE 'GOOS\|GOARCH\|runtime\.\|platform' internal/fetch/baseline.go` → leer, Exit 1). **Und sie löst Annahme (a) nicht von selbst:** wählt der Bootstrap nach seiner **eigenen** Plattform, steht er im Fehlerfall wie G; wählt er nach der des Ziels, braucht er eine Angabe, die heute niemand macht — eine neue Eingabe, keine Kleinigkeit. Dazu ändert sich die **Release-Form**: heute lädt der Lauf die nackten Binaries der Matrix hoch (`grep -n 'gh release upload .*dist' .github/workflows/release.yml` → eine Zeile) und der Start-Smoke prüft je Plattform genau eine solche Datei; ein Adopter lüde alle für eines, in **ungemessener** Größe |
| **I — ein Binär committet im Zielrepo** | zeitlos verfügbar, auch im frischen Klon — genau die Lücke, die G, F und H offen lassen | bricht den gitignorierten Ablageort, den [ADR-0011](0011-telemetrie-erfassung-policy.md) für den Bestand entschieden hat, und bindet ein Doku-Repo an **eine** Plattform; ein Binär im versionierten Baum ist zudem kein Artefakt, das ein Re-Lauf konvergent nachziehen kann |
| **J — `docker run` gegen ein gepinntes Image je Hook-Aufruf** | kein Artefakt im Ziel; der Träger altert nicht, weil er nicht liegt | die Schwelle aus [ADR-0011](0011-telemetrie-erfassung-policy.md) bindet dann **je Aufruf** statt einmalig, und ein Container-Start je Tool-Call liegt erkennbar darüber; dazu ein Netz- oder Cache-Zustand im Hook-Pfad, gegen den [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) das Ziel netzlos hält |
| **K — kein Artefakt im Ziel; der Hook ruft das Werkzeug aus `PATH`** | nichts wird abgelegt, nichts altert, der Adopter pflegt eine Installation, die er ohnehin hat | setzt eine Installation voraus, die **kein Bootstrap herstellt** — ein frischer Klon auf einer fremden Maschine erfasst still nichts, und der Hook zeigt auf ein Programm, dessen Anwesenheit niemand zusagt ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |

## Konsequenzen

- **Positiv:** [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) ist
  ohne neuen Vertriebskanal, ohne Netz und ohne Bauschritt im Ziel erfüllbar; die Aufzählung aus
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wächst
  nicht, die Plattform-Matrix aus
  [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) auch nicht. Die
  Rollen-Achse bekommt im Ziel ihren Abnehmer, und die Konstruktion dieses Repos wird **kleiner**
  statt größer.
- **Negativ, und das ist der Preis:** der Hook startet je Tool-Call ein größeres Programm. Die
  Schwelle steht fest ([ADR-0011](0011-telemetrie-erfassung-policy.md): *50 ms im Median*, und
  *„nicht die Grenze zu erhöhen, sondern der Umfang zu senken"*), die Messung steht als
  **Folgepflicht 9**, und ihr negativer Ausgang hat eine benannte Antwort: Alternative F trägt
  dieselben Eigenschaften mit getrenntem Einstiegspunkt.
- **Negativ:** der Träger liegt gitignored. Ein frischer Klon des Adopter-Repos hat ihn nicht und
  erfasst still nichts, bis jemand das Werkzeug erneut laufen lässt. Die Auswertung macht es
  sichtbar, ein Gate darf es nicht (Festlegung 5(c)) — **die Grenze ist benannt, nicht
  geschlossen**.
- **Negativ:** der abgelegte Träger kann ein Repo bootstrappen. Der Zugewinn eines konstruktiven
  Ausschlusses wäre gering — wer den Träger startet, hat das Binär ohnehin —, aber er ist **kein
  Nichts**, und die Abwägung steht in der Tabelle, nicht im Kommentar.
- **Grenze:** die Verbrauchs-Zähler kommen im Ziel so wenig an wie hier, und der Grund liegt in
  der **Mechanik** des Agenten-Werkzeugs, nicht in unserem Aufbau
  ([ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md)). Die emittierte Auswertung trägt
  darum einen Leser ohne Zahl — und sagt, warum. Das ist keine Folge dieser Entscheidung, sondern
  eine Feststellung jener, die hier eingelöst statt weitergereicht wird.
- **Grenze:** die Rollen-Achse im Ziel ruht auf den kanonischen Rollennamen und auf
  Adopter-Disziplin. Das ist keine Folge dieser Entscheidung, sondern die Grenze, die
  [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) selbst
  ausspricht; sie steht im emittierten Feldlisten-Dokument, damit sie dort steht, wo sie anfällt.
- **Folgepflicht 1 — der Dogfood zieht den Einstiegspunkt nach.** Emitter und Auswertung werden
  Unterkommandos, die zwei Bau-Stufen des getrennten Wegs entfallen
  (`grep -nE '^FROM .* AS (span|report)$' Dockerfile` → zwei Zeilen) und mit ihnen der Gegenstand
  des Bau-Ziels (`grep -c '^span-emit-build:' Makefile` → **1**), die Hook-Konfiguration dieses
  Repos ruft denselben Einstiegspunkt wie das Ziel. Ohne diesen Nachzug emittierte der Beleg
  einen Einstiegspunkt, den der Dogfood nie ausführt. **Die Reihenfolge ist gegenüber
  [ADR-0020](0020-emittierte-modul-15-regeln.md) Folgepflicht 1 in ihren ersten zwei Gliedern
  umgekehrt, und das ist benannt statt übersehen:** dort steht *„Erprobung → Entscheidung →
  Emission"*, hier fällt die Entscheidung vor der Erprobung. Gebunden ist von jener Folgepflicht
  die **Emission** (*„der Beleg emittiert nichts, was der Dogfood nicht selbst fährt"*), und die
  kommt nach diesem Nachzug — die Sache ist eingelöst, die Abfolge der ersten zwei Glieder nicht.
- **Folgepflicht 2 — die Mutations-Fälle folgen dem Einstiegspunkt.** Die Zähne aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) (Klemme entfernt ⇒ rot; stdout gebrochen ⇒ rot)
  hängen heute am alten Programm. Wandern sie nicht mit, ist die fail-open-Konstruktion genau an
  der Stelle unbewacht, an der ein fremdes Repo sie ausführt.
- **Folgepflicht 3 — [`spec/spezifikation.md §5`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
  nachziehen:** ihr Gegenstands-Satz nennt das Binär, das mit Festlegung 2 verschwindet. Der
  Nachzug gehört dem Eigentümer des Stratums.
- **Folgepflicht 4 — [`architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
  nachziehen:** die Emissions-Mechanik legt erstmals ein **ausführbares** Artefakt ab, und die
  Klassen-Tabelle bekommt eine Zeile außerhalb des versionierten Baums.
- **Folgepflicht 5 — der Wellen-Plan der Träger-Aussage wird falsch, und zwar als Eigenschaft, nicht
  an einer Adresse.** Betroffen ist **jede** Zeile, die einen Wert *„entschieden, permanent nicht
  emittiert"* aus einer hier revidierten Festlegung ableitet — das sind die Modul-15-Blöcke aus
  Festlegung 1 **und** die Rollen-Trennung aus Festlegung 2, die Festlegung 3 dieser Entscheidung
  umkehrt —, und **jede** Stelle, die den Ausschluss der Modul-15-Emission mit einem Change Request
  begründet, *„solange er offen ist"*; er ist angenommen. Das Kommando, das die Menge heute zeigt:
  `grep -niE 'permanent nicht emittiert|solange er offen ist' docs/plan/planning/welle-11-traeger-aussage.md`
  — die Trefferzahl wandert mit dem Plan und ist **kein** Erwartungswert
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Das Nachziehen ist **Plan-Arbeit**, nicht Teil dieser Entscheidung.
- **Folgepflicht 6 — die drei Abwesenheits-Wächter der abgelösten Entscheidung werden
  Anwesenheits-Wächter.** Sie waren dort geschuldet und nicht geliefert; gebaut werden jetzt die
  umgekehrten. Ein Wächter, der eine Abwesenheit prüft, die es nicht mehr geben soll, ist kein
  halber Wächter, sondern ein falscher.
- **Folgepflicht 7 — der ADR-Index bekommt bei der Annahme die Teil-Revisions-Annotation** an der
  abgelösten Entscheidung, in der dort geübten Form. Bis dahin nennt der Index diese Entscheidung
  als *Proposed* und ihren Umfang; eine Revision, die noch nicht beschlossen ist, wird nicht als
  vollzogen ausgewiesen. **Betroffen ist jede Index-Zeile, deren Zusammenfassung eine hier
  revidierte Aussage trägt** — auch die der Entscheidung, die den emittierten Fall vorentschieden
  hat: ihre Zeile schließt heute mit *„Die emittierte Ebene ist nicht berührt"* und zeigt für den
  Grund auf eine Entscheidung, die nach der Annahme in drei Festlegungen revidiert ist. Der Index
  ist ein **lebendes** Artefakt; dort kostet der Nachzug eine Zeile, keine Folge-ADR.
- **Folgepflicht 8 — die Kommentare, die die heutige Trennung begründen, beschreiben danach eine
  Konstruktion, die es nicht mehr gibt.** Betroffen ist **jede** Stelle, die die getrennten
  Bau-Stufen begründet, nicht nur die, die einen Plan-Schnitt als Entscheidungs-Ort nennt: die
  Begründung an der Auswertungs-Stufe nennt keinen und trägt zusätzlich einen Satz, den
  Festlegung 2 eigenständig falsch macht — die Auswertung wechselt auf den Host und bekommt im
  Ziel genau einen Leser. Wer die Folgepflicht über ein Erkennungsmerkmal statt über die
  Eigenschaft abarbeitet, findet die zweite Stelle nicht. Die Entscheidung ist hier gefallen, und
  wer die Stelle anfasst, zieht den Kommentar nach ([`AGENTS.md`](../../../AGENTS.md) §3.7).
- **Folgepflicht 9 — der Aufschlag je Tool-Call wird gemessen, bevor die Schwelle als gehalten
  gilt.** Annahme (c) ist ungemessen, und ein Trennungs-Trigger ohne Messung feuert nie.
  Geschuldet ist eine Messung des **Medians** des Hook-Aufschlags über einen realen Lauf, gegen
  die Schwelle aus [ADR-0011](0011-telemetrie-erfassung-policy.md) gehalten und gegen den heutigen
  getrennten Emitter als Vergleichspunkt — mit ihrem **Kommando im Text**, damit sie nachgefahren
  werden kann ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
  Ein Sensor dafür existiert nicht
  (`grep -niE 'latenz|latency|median|bench' Makefile d-check.mk` → leer, Exit 1); solange er
  fehlt, trägt die Verbindlichkeit diese Entscheidung, nicht ein Gate — und **keine**
  Fitness-Function-Zeile nennt ihn, weil eine Zeile über einem nicht existierenden Target genau
  der halluzinierte Gate wäre, den
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  ausschließt. Fällt die Messung negativ aus, ist die Antwort Alternative F, nicht eine höhere
  Schwelle.

## Fitness Function (falls maschinell prüfbar)

**Eine Grenze gilt für jede Zeile unten, deren Target ausschließlich `make full-smoke` ist —
unabhängig davon, welche Zusage sie trägt.** Der Mutations-Treiber dieses Repos erreicht dieses
Target nicht: `failure_form` in `harness/tools/mutate.sh` führt Fehlschlag-Muster für `test`,
`test-go`, `test-bats`, `smoke` und `ci-lint` und bricht sonst mit *„unbekanntes `# verify:`"* ab
(Bestand: `sed -n 's/^# verify: //p' test/mutations/*.sh | sort | uniq -c` → je einmal `ci-lint`
und `smoke`; für `make smoke` wurde dieselbe Lücke einmal ausdrücklich geschlossen, für
`full-smoke` nicht). Wer eine solche Zeile einlöst, schuldet darum **beides**: den Wächter und ein
Fehlschlag-Muster für `full-smoke` — sonst bleibt ihr Fall ungelistet, und ungelistet heißt nach
[`AGENTS.md`](../../../AGENTS.md) §3.6 unbewacht. Zeilen, die an `make test` · `make mutate`
hängen, sind davon nicht berührt.

| Tooling                     | Regel                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | Make-Target                |
| --------------------------- | --------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- | -------------------------- |
| `make full-smoke`           | **Der Träger schreibt im Ziel.** Im frisch gebootstrappten tmp-Repo erzeugt der abgelegte Träger aus einer synthetischen Payload einen Span, und `git check-ignore` im Ziel bestätigt dessen Ablageort — der Nachbau dessen, was `span-check` hier für den Dogfood leistet. **Geschuldet, nicht geliefert.** Die Klammer über **beide** Bootstrap-Varianten (sprachlos und mit Sprache) gehört dazu: die Erfassung ist sprach-agnostisch, ein Zahn in nur einer Variante belegte das nicht                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `make full-smoke`          |
| `make test` · `make mutate` | **Die Zusage aus [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), mit ihrem Gegenbeispiel.** Scheitert die Platzierung des Trägers, trägt die emittierte `.claude/settings.json` **keinen** Erfassungs-Hook, es liegt **kein** Wrapper, und der Bootstrap endet erfolgreich. **Rot zu sehen ist:** die Kopplung aufheben — den Hook-Eintrag unbedingt schreiben —, dann muss der Wächter fallen. Ohne dieses Rot ist die Zusage eine Absicht. **Geschuldet, nicht geliefert**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                               | `make test`, `make mutate` |
| `make test` · `make mutate` | **Die fail-open-Konstruktion am neuen Einstiegspunkt.** Ein Träger, dessen innere Arbeit fehlschlägt, endet mit Exit 0 und leerem stdout — auch das seiner Kindprozesse; die Klemme zu entfernen färbt rot. Die Zähne existieren, sie hängen am alten Programm (Folgepflicht 2)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | `make test`, `make mutate` |
| `make test`                 | **Die Anwesenheits-Wächter — im Zweig, in dem die Emission gelingt.** Nach einem Bootstrap, dessen Träger-Platzierung durchläuft, liegen im Ziel Träger, Wrapper, Rollen-Typen und die Feldliste; die Prüfung hat die Gestalt des bestehenden Abwesenheits-Wächters in `internal/emit/enforce_test.go`, nur umgekehrt, und jede ist einmal rot zu sehen, indem das Artefakt probeweise weggelassen wird. **Die Bedingung gehört in den Wächter, nicht in seinen Namen:** im Zweig aus Festlegung 5(a) fehlen Träger, Wrapper und Hook-Eintrag zulässig, und ein unbedingt formulierter Anwesenheits-Wächter fiele dort — gegen die Zeile darüber, die genau dieses Ausbleiben zusagt. Die **Feldliste** entsteht mit dem Träger (Festlegung 7 erzeugt sie aus ihm) und teilt darum seinen Zweig. **Geschuldet, nicht geliefert** (Folgepflicht 6)                                                                                                                                                                                                   | `make test`, `make mutate` |
| `make test`                 | **Die Feldliste im Ziel ist der Ausdruck des Trägers.** Das emittierte Dokument ist byte-gleich mit dem, was der Träger über sein eigenes Schema ausgibt; ein Feld, das erfasst wird und dort fehlt, färbt rot. Damit ist die Drift konstruktiv ausgeschlossen statt per Regel verboten. **Geschuldet, nicht geliefert** — das Dokument entsteht erst mit Festlegung 7, und ein Sensor darüber existiert nicht (`grep -rln 'Feldliste' internal/emit/*.go` → leer, Exit 1)                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                          | `make test`                |
| `make full-smoke`           | **Die Auswertung meldet ihre Leere — und nennt die Grenze, nicht nur den Zustand.** Über einem Bestand ohne Verbrauchs-Zähler nennt sie ihre Abdeckung, weist **keine** Bilanz aus und sagt, dass die Zähler an der Mechanik des Agenten-Werkzeugs hängen; eine Ausgabe, die über leerem Bestand eine Zahl trägt, ist der Befund — und ebenso eine, die die Leere ohne ihren Grund meldet. **Rot zu sehen ist:** den Grund-Satz aus der Ausgabe nehmen, dann muss der Wächter fallen; ohne dieses Rot ist die Einlösung von [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 eine Absicht ([`AGENTS.md`](../../../AGENTS.md) §3.6) — und für dieses Target gilt die Grenze über der Tabelle. **Der stehende Nenn-Ort der Zeile darunter hängt dagegen an `make test` · `make mutate` und ist ohne jene Vorarbeit erreichbar; diese Asymmetrie ist der Grund, warum die Grenze aus [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 zwei Orte hat und nicht einen.** **Geschuldet, nicht geliefert** | `make full-smoke`          |
| `make test` · `make mutate` | **Das Feldlisten-Dokument führt seine zwei Grenzen stehend.** Es nennt, dass die emittierte Ebene keinen Wächter über die Aufrufform des Agenten-Werkzeugs führt und dass die Verbrauchs-Zähler aus der Mechanik nicht kommen (Festlegung 7); fehlt einer der zwei Sätze im emittierten Dokument, färbt der Wächter rot. Das ist der Ort, der auch dann trägt, wenn niemand die Auswertung ruft. **Geschuldet, nicht geliefert**                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                    | `make test`, `make mutate` |
| —                           | **Nicht maschinell prüfbar, und darum hier ohne Zeile:** dass ein Adopter seine Rollen-Typen unter den kanonischen Namen führt. Das ist die Grenze aus [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Benannte Grenze; sie wird ausgesprochen, nicht bewacht                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                     | —                          |

## Re-Evaluierungs-Trigger

- **Wenn der Aufschlag je Tool-Call die Schwelle aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) reißt** *(feedforward, bis ein Slice den Sensor
  baut — dieselbe Einordnung, die jene Quelle für dieselbe Schwelle führt; heute existiert kein
  Sensor: `grep -niE 'latenz|latency|median|bench' Makefile d-check.mk` → leer, Exit 1)*:
  Annahme (c) fällt. **Wer es merkt:** die Messung aus Folgepflicht 9 — ohne sie merkt es niemand,
  und der Trigger feuert nie. Die Antwort ist **nicht**, die Schwelle zu heben — jene Quelle sagt
  es selbst —, sondern den Umfang zu senken oder den Einstiegspunkt zu trennen; Alternative F
  steht dafür bereit und trägt dieselben vier Konstruktions-Eigenschaften.
- **Wenn ein Adopter-Bestand Verbrauchs-Zähler trägt** *(feedforward — fremder Vertrag, kein
  Sensor dieses Repos; sichtbar wird es, wer die emittierte Auswertung ruft und ihre
  Abdeckungs-Zeile liest)*: dann hat einer der zwei Wege im fremden Vertrag getragen, die
  [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) abgezählt hat — und weil die Mechanik
  auf beiden Ebenen dieselbe ist, ist damit deren erster bzw. zweiter Re-Evaluierungs-Trigger
  ausgelöst, für den Dogfood wie für das Ziel. Fällig ist dann **zuerst** die Wiederaufnahme jener
  Entscheidung durch eine Folge-ADR — sie ist *Accepted* und wird nicht nachgebessert
  ([`AGENTS.md`](../../../AGENTS.md) §3.4) —, **dann** der Nachzug der zwei Orte, an denen
  Festlegung 8 die Grenze nennt, weil sie damit falsch geworden wäre, und **erst dann** die Frage,
  ob die emittierte Auswertung dieselbe Aufteilung des Sammelpostens braucht, die
  [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) für den Dogfood entschieden hat.
- **Wenn das Agenten-Werkzeug seine Hook-Oberfläche oder seinen Konfigurations-Ort ändert**
  *(feedforward — fremder Vertrag, bemerkt, nicht herbeigeführt)*: Annahme (d) fällt. Auf der
  emittierten Ebene wiegt das schwerer als hier: ein fremdes Repo zieht erst nach, wenn jemand das
  Werkzeug dort erneut laufen lässt — die Konvergenz-Klasse aus Festlegung 4 ist der einzige Weg
  dorthin.
- **Wenn ein Bootstrap für eine andere Plattform ausgeführt wird als die, auf der die Hooks
  laufen** *(feedforward — an einem Ziel ablesbar, dessen Träger sich nicht ausführen lässt)*:
  Annahme (a) fällt, und mit ihr die Grundlage, auf der Festlegung 1 ruht — der Bootstrap-Host
  sagt dann nichts mehr über die Hook-Plattform. Sie fällt für die Wege der ersten
  Herkunfts-Klasse, die **eine** Plattform mitbringen — Alternative F eingeschlossen, **Alternative
  H ausgenommen**, denn die trägt alle und wählt. Der Preis-Vergleich, der zwischen ihnen
  entschied, ist damit gegenstandslos. Die Plattform-Frage ist neu zu stellen; **H** ist der
  nächstliegende Weg, weil er sie stellbar macht — er verlangt dann eine Plattform-Angabe, die
  heute niemand macht. D und E bleiben daneben verfügbar und tragen jeweils ihren eigenen Einwand
  aus der Alternativen-Tabelle.
- **Wenn der Zustands-Bereich des Ziels nicht mehr gitignored oder nicht beschreibbar ist**
  *(feedforward — eine Änderung an der emittierten Durchsetzung, kein Sensor)*: Annahme (b) fällt;
  Träger-Ort und Ablageort sind gemeinsam neu zu wählen, weil sonst jeder Span den Gate-Nachweis
  des Ziels verschiebt.
- **Wenn die Idempotenz-Klasse der emittierten Hook-Konfiguration wechselt**
  *(feedforward — eine Änderung an [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3)*: dann kann
  der Erfassungs-Block darin nicht mehr konvergent nachgezogen werden, und Festlegung 5 verliert
  ihren Mechanismus — die Kopplung zwischen Träger und Hook-Eintrag wäre nur noch beim ersten Lauf
  wahr.
- **Wenn das Modul der Rollen-Typen im Agenten-Werkzeug wegfällt oder seine Namen anders
  auflöst** *(feedforward — fremder Vertrag)*: Festlegung 3 verliert ihren Abnehmer, und die Zelle
  der Span-/Audit-Attribute ist für die Rollen-Achse neu zu bewerten — nicht für die Erfassung
  selbst.

## Geschichte

| Datum      | Ereignis     | Verweis                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                  |
| ---------- | ------------ | ------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------ |
| 2026-08-23 | **Proposed** | Architect-Verdikt zur angenommenen Anforderung [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Lastenheft 0.19.0): sie steht auf Rang 1 und verlangt, was die abgelöste Entscheidung als permanent ausgeschlossen hatte. Diese Entscheidung führt die Abzählung der Wege über ein Kriterium statt über eine Liste, wählt den Träger als das ausführbare Bild, dessen Lauffähigkeit auf dem Bootstrap-Host der Lauf selbst belegt — die Identität dieses Hosts mit der Hook-Plattform steht als Annahme mit Trigger, nicht als Beweis —, bindet Hook-Eintrag und Träger aneinander, löst die Konjunktion aus Festlegung 3 der abgelösten Entscheidung **getrennt für Träger und Zahl** auf und vollzieht den Adopter-Vertrag, den [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 5 für genau diesen Fall vorentschieden hat |
