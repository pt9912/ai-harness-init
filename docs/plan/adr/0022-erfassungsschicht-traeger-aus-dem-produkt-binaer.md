# ADR-0022: Die Erfassungsschicht geht ins Ziel — der Träger ist das laufende Produkt-Binär, Schreiber und Auswertung sind seine Unterkommandos

**Status:** Proposed

**Datum:** 2026-08-23

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (die
Anforderung, die diese Entscheidung auslöst — **Rang 1** der Source Precedence, und sie verlangt
den Träger samt Rollen-Typen, Schreiber **und** Auswertung ins Ziel),
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (die Init-Phase und
*out-of-the-box grün* — die Zusage, an der der Aufruf-Ort und die Nicht-Verdrahtung hängen),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Aufzählung der emittierten Durchsetzungs-Mechanik — sie wächst durch diese Entscheidung
**nicht**, weil
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Abgrenzung
sich selbst als additiv gegen sie stellt),
[`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) (die
emittierte Anleitung, die die Rollen-Sequenz im Ziel bereits fährt — ihr fehlte bisher nur der
Typ, unter dem eine Rolle startbar ist),
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) (das emittierte
Regelwerk, das die drei Observability-Blöcke als **Text** schon trägt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Zusage aus
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren): *„kann der
Träger nicht emittiert werden, wird begründet **nichts** abgelegt — kein Hook, der auf ein
fehlendes Programm zeigt"* — Festlegung 5 löst sie ein und benennt ihr Gegenbeispiel),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (*dieselbe Tool-Version →
derselbe Träger im Ziel* — bei Festlegung 1 eine Konstruktions-Eigenschaft, keine Zusicherung),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (*das Zielrepo
bleibt über `bash + git + docker` geschlossen* — die Grenze, an der drei der verglichenen Wege
scheitern),
[`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die Plattform-Matrix — der
gewählte Träger verdoppelt sie nicht, er **ist** sie),
[ADR-0003](0003-go-native-binaries.md) (**Accepted** — native Binaries als Vertriebsform und der
ausdrückliche Verzicht auf ein eigenes OCI-Image als *Vertriebsmittel*; der Grund, an dem der
Bild-Weg scheitert),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — die Phasen-Trennung und die
Idempotenz-Klassifikation; beide tragen Festlegung 4),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — die Erfassungs-Policy; ihre
**Festlegung 5** macht die Festlegungen 1–4 und 6 zum Adopter-Vertrag, sobald das **Ob** durch
einen Change Request entschieden ist, und genau das ist geschehen),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — *jede Bilanz aus diesen
Spans nennt ihren Nenner*; die Präzedenz, auf der die emittierte Auswertung steht),
[ADR-0013](0013-technik-stratum-als-zielort.md) (**Accepted** — das Gefäß folgt dem Gegenstand;
ihre Folgepflicht 3 fragt nach dem Zielort der Feldtabelle im Zielrepo, und Festlegung 7
beantwortet sie),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (**Accepted** — die Form der Regelwerks-Belege
unten: Tag, Dateiname, Abschnitt, Zitat),
[ADR-0020](0020-emittierte-modul-15-regeln.md) (**Accepted** — die abgelöste Entscheidung; ihr
Umfang steht unten),
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (**Accepted** — das **Zähler-Glied**
bleibt im Dogfood verschlossen; Festlegung 8 zieht daraus **nicht** dieselbe Folge für die
emittierte Ebene),
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
- **Folgepflicht 6** und die zweite Zeile ihrer Fitness Function (*je ein Wächter über der
  Abwesenheit von `.claude/agents/`, Span-Emitter und Token-Bericht im Ziel*) — sie ruhen auf den
  Festlegungen 1–3 und fallen mit ihnen. An ihre Stelle treten **Anwesenheits**-Wächter.

**Nicht revidiert, und darum ausdrücklich benannt:**

- **Festlegung 4 und Festlegung 5** (Doku-Konsistenz-Block, `targets:`-Konfiguration, advisory
  Träger) — unberührt, samt den Folgepflichten 2, 3 und 4.
- **Festlegung 6** (*„Die Erfassung wird auch nicht KONDITIONAL emittiert"*) — sie gilt
  **fort** und trägt jetzt die **unbedingte** Emission: ihr Befund war, dass der Prüfbereich der
  Telemetrie *„in jedem Ziel"* existiert und es deshalb keine strukturelle Bedingung gibt, die
  Ziele trennt. Derselbe Satz schließt gestern *„nur für manche"* aus und heute ebenso.
- **Folgepflicht 1** (*„der Beleg emittiert nichts, was der Dogfood nicht selbst fährt"*) — sie
  ist nicht abgelöst, sondern **bindet diese Entscheidung**; Festlegung 2 und Folgepflicht 1
  unten lösen sie ein.
- **Folgepflicht 5** (*„wird der Erfassungs-Block je emittiert, ist die Policy ein
  Adopter-Vertrag"*) — nicht revidiert, sondern **fällig**; Festlegung 6 und Festlegung 7 leisten
  sie.

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

Das Observability-Modul der adoptierten Baseline führt vier Regelblöcke; drei davon —
Span-/Audit-Attribute, Token-Attribution, Cache-Counter — gingen bis hierher **nicht** ins Ziel,
und ihre Zellen der Konformitäts-Matrix trugen *ADR-Verdikt*: permanent, in einer ADR entschieden,
ohne Auflösungs-Trigger. Der Vertrag verlangt heute das Gegenteil.
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) ist
abnahmebindend und steht auf **Rang 1** der Source Precedence, eine ADR auf Rang 4; die Frage ist
damit nicht mehr, **ob** der Träger geht, sondern **wie**.

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
des ausführbaren Bildes zur Bootstrap-Zeit**. Es gibt genau vier Möglichkeiten, und jeder
konkrete Weg fällt in genau eine: das Bild **liegt schon vor**, es **entsteht im Ziel**, es wird
**geholt**, oder es gibt **keines**. Die Aufteilung ist erschöpfend, weil sie eine Existenz- und
eine Ortsfrage kombiniert; sie ist keine Liste, die altert.

| Herkunft | Weg | Ausgang |
|---|---|---|
| **liegt vor** | das Produkt-Binär selbst (Selbst-Kopie, Unterkommandos) | **gewählt** — Festlegung 1 |
| **liegt vor** | ein eigenes Emitter-Binär, ins Produkt-Binär eingebettet | tragfähig, teurer — Alternative F |
| **entsteht im Ziel** | Quelle + Bauschritt mit einer Toolchain des Ziels | scheitert an [ADR-0007](0007-bootstrap-phasen.md) und [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) — Alternative B |
| **entsteht im Ziel** | Quelle mitliefern, Bau im gepinnten Image zur Bootstrap-Zeit | ein fremder Quellbaum samt Aktualisierungsweg im Ziel — Alternative C |
| **wird geholt** | Release-Asset über das Netz | zweiter Vertriebskanal + Verfügbarkeits-Abhängigkeit — Alternative D |
| **wird geholt** | veröffentlichtes, digest-gepinntes OCI-Bild, `docker create`/`docker cp` | zweiter Vertriebskanal gegen [ADR-0003](0003-go-native-binaries.md); der Beleg liefe gegen ein fremdes Bild — Alternative E |
| **keines** | handgeführter Scanner in vorhandener Laufzeit; oder warten, bis das Werkzeug seine Telemetrie selbst führt | gemessen gescheitert bzw. fremder Vertrag — Alternative A |

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

- **(a)** Das Produkt-Binär läuft auf der Plattform, auf der auch der Hook läuft. Der Beweis ist
  sein eigener Lauf — es bootstrappt gerade. Fällt das (ein Bootstrap über eine Fernverbindung in
  ein Repo einer anderen Plattform), fällt der tragende Grund von Festlegung 1.
- **(b)** Der Zustands-Bereich des Ziels ist beschreibbar und bleibt gitignored. Fällt das, sind
  Ablageort **und** Träger-Ort neu zu wählen.
- **(c)** Der Aufschlag je Tool-Call bleibt unter der Schwelle aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) (*50 ms im Median*). **Hier nicht gemessen** —
  die Messung ist unten geschuldet, und ihr Ausgang ist der Trennungs-Trigger.
- **(d)** Das Agenten-Werkzeug liest seine Hook-Konfiguration weiter aus einer Datei im Repo und
  startet Hook-Programme als eigene Prozesse. Fällt das, fällt die Verdrahtung, nicht die Policy.

## Entscheidung

**Wir wählen Weg G: der Träger ist das laufende Produkt-Binär.** Es wird beim Bootstrap in den
gitignorierten Zustands-Bereich des Ziels kopiert; Schreiber und Auswertung sind seine
Unterkommandos. Acht Festlegungen; die vier Zellen der Tool-Spalte tragen danach:

| Modul-15-Regelblock | Wert der Tool-Zelle | Festlegung |
|---|---|---|
| Span-/Audit-Attribute (die Erfassung samt ihrem Pflichtfeld Rolle) | **emittiert** — Schreiber und Rollen-Typen, Beleg geschuldet | 1, 3, 4, 5 |
| Token-Attribution | **emittiert** — als Auswertung, die ihre Abdeckung nennt; **keine** Bilanz zugesagt | 8 |
| Cache-Counter | **emittiert** — dieselbe Auswertung, dieselbe Abdeckungs-Aussage | 8 |
| Doku-Konsistenz-Drift | unverändert — [ADR-0020](0020-emittierte-modul-15-regeln.md) Festlegungen 4 und 5 | — |

**1. Der Träger ist das ausführbare Bild, das zur Bootstrap-Zeit nachweislich auf der
Zielplattform läuft — das Produkt-Binär selbst.** Geltungsbereich: die emittierte Ebene, jede
Bootstrap-Variante. Der Bootstrap kopiert es in den gitignorierten Zustands-Bereich des Ziels.
Vier Eigenschaften folgen daraus **konstruktiv**, nicht als Zusage:

- **Keine zweite Plattform-Matrix.** Der Träger *ist* die Matrix aus
  [`LH-QA-04`](../../../spec/lastenheft.md#lh-qa-04--plattform-matrix). Jeder andere Weg muss die
  Plattform des Ziels erst herleiten oder raten; hier ist sie bewiesen, weil das Bild gerade
  läuft.
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

**Warum das die Phasen-Ordnung nicht invertiert — der Punkt, an dem die abgelöste Begründung
hing.** [ADR-0007](0007-bootstrap-phasen.md) verwirft, dem Ziel **Code vor seiner eigenen
Doc-Chain und vor seinem Sprach-ADR** zu geben; die Sprachwahl ist eine ADR-Entscheidung des
Adopters. Der Träger ist **nicht der Code des Ziels**: er wird dort nicht übersetzt, er verlangt
keine Toolchain, er trifft keine Sprach-Aussage, und er liegt außerhalb des versionierten Baums.
Nach dem Init hat das Ziel weiterhin kein Sprach-Fragment, kein Manifest und kein Skelett — die
Eigenschaft, die der bestehende Abwesenheits-Wächter in `internal/emit/enforce_test.go` bereits
hält. Was [ADR-0007](0007-bootstrap-phasen.md) verbietet, ist ein **Bauschritt** im Ziel; das ist
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

**Der Umbau schrumpft die Konstruktion, statt sie zu vergrößern:** zwei Bau-Stufen und ein
Make-Ziel entfallen, ein Programm bleibt. Die Auswertung wechselt dabei vom Container auf den
Host — im Ziel gibt es keine Bau-Stufe, aus der sie laufen könnte, und ein Adopter soll für einen
Bericht keinen Container starten müssen.

**3. Die Rollen-Typen gehen mit — generisch, Tool-als-Quelle, `skip-if-present`.**
Geltungsbereich: `.claude/agents/` im Ziel. Emittiert wird **nicht** die Kopie der sechs Dateien
dieses Repos: sie tragen dessen Slices, Konventionen und Befunde. Emittiert wird eine generische,
aus Dogfood und Kurs-Modul 8 abgeleitete Fassung — dieselbe Herkunftsklasse wie die
Durchsetzungs-Mechanik und die Workflow-Commands. Die **Idempotenz-Klasse folgt den Commands**
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

| Artefakt | Klasse | Warum |
|---|---|---|
| der Träger im gitignorierten Zustands-Bereich | **konvergent**, nie geprunt | reine tool-erzeugte Infrastruktur; ein Re-Lauf heilt Drift und zieht eine neue Tool-Version nach |
| der Hook-Wrapper unter `.claude/hooks/` | **konvergent** | dieselbe Klasse wie die übrigen Hook-Skripte in [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3 |
| `.claude/settings.json` | **konvergent** (unverändert) | tool-eigen; der Erfassungs-Block darin entsteht nur unter der Bedingung aus Festlegung 5 — ein Re-Lauf, der ihn nicht setzen kann, **entfernt** ihn, damit die Konfiguration die Wirklichkeit beschreibt |
| die Rollen-Typen unter `.claude/agents/` | **skip-if-present** | Adopter-adaptierter Text, Klasse wie die Commands (Festlegung 3) |
| die Feldliste im geprüften Doku-Bereich | **konvergent** | tool-generiert, verbatim abgelegt (Festlegung 7) |
| das Aufräum- und Berichts-Fragment im Gate-Fragment-Verzeichnis des Ziels | **konvergent** | tool-eigenes Gate-Fragment, Muster [`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) |

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
   Teil der Zusage"*). Das Ziel bekommt das Kommando und den Satz, dass sein Bestand ohne dessen
   Aufruf unbegrenzt wächst.
3. **Die ausgesprochene Nicht-Zusage über den Bestand.** Das Bedrohungsmodell jener Quelle ruht
   auf einer bekannten Vertrauensgrenze (*„Wer sie lesen kann, kann auch die Dateien lesen"*) —
   im fremden Repo gilt das nicht, und jene Quelle sagt es selbst als dritten Grund. Im Ziel wird
   daraus ein **geschriebener** Satz: der Bestand ist gitignored, nicht verschlüsselt, nicht
   zugriffsbeschränkt, und Pfadnamen sind nicht als unkritisch zugesagt.
4. **Die Rollen-Typen und die Auswertung.** Beide kommen in jener Quelle nicht vor; Festlegungen
   3 und 8.

**7. Die Feldliste lebt im Ziel als tool-generiertes Dokument im geprüften Doku-Bereich — nicht
im Technik-Stratum des Adopters.** Das beantwortet die offene Frage aus
[ADR-0013](0013-technik-stratum-als-zielort.md) Folgepflicht 3 mit **Nein**, und zwar aus dem
Grund jener Entscheidung selbst: das Gefäß folgt dem Gegenstand. Das Technik-Stratum des Ziels ist
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
Sie trägt zugleich, was die abgelöste Folgepflicht 5 dort **genannt** haben wollte: dass die
emittierte Ebene keinen Wächter über die Aufrufform des Agenten-Werkzeugs führt.

**8. Token-Attribution und Cache-Counter: das Erfassungs-Glied fällt, das Zähler-Glied nicht —
emittiert wird die Auswertung, nicht die Bilanz.** Die abgelöste Festlegung 3 hing an einer
Konjunktion. Die Glieder stehen heute verschieden:

- **Das Erfassungs-Glied** (*erfasst das Ziel überhaupt?*) ist mit Festlegung 1 **wahr**. Es ist
  damit revidiert, und mit ihm der Satz *„ein Ziel, das nicht erfasst, hat nichts zu verrechnen"*.
- **Das Zähler-Glied** (*trägt ein `Agent`-Span Rolle und Zähler?*) ist im Dogfood
  **verschlossen**, und zwar seit [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) auf
  eigenem, *Accepted* entschiedenem Grund statt als Vorbedingung eines Carveouts. Es wird hier
  **nicht** revidiert.
- **Die Folge für die emittierte Ebene ist aber nicht dieselbe, und das ist der Kern.**
  [ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) sagt selbst, die emittierte Ebene sei
  **nicht berührt**; ihre Permanenz ruht auf der committeten Berechtigungs-Lage **dieses** Repos.
  Was ein fremdes Repo an Zählern erhält, entscheidet dessen eigene Lage — wir wissen es nicht und
  dürfen es weder zusagen noch ausschließen.

**Daraus die Festlegung:** emittiert wird der **Leser**, nicht die **Zahl**. Die Auswertung nennt
ihre **Abdeckung zuerst** und meldet über einem Bestand ohne Zähler ihre Leere; sie behauptet
keine Bilanz. **Damit ist der Einwand entkräftet, mit dem die abgelöste Entscheidung die
Voll-Emission verwarf** (*„ein Bericht, der nie eine Zahl trägt, ist die Gate-Lüge als
Kennzahl"*): gelogen hätte ein Bericht, der eine Bilanz behauptet; ein Bericht, der seinen Nenner
und seine Abdeckung nennt, ist genau das Gegenteil — die Form, die
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) für den Dogfood erzwungen hat.

**Und die Auswertung wird im Ziel nicht verdrahtet.** Sie prüft nichts und färbt nichts rot; ein
Gate über ihr wäre eines über leerem Prüfbereich
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) — genau
die Einordnung, die dieses Repo für seinen eigenen Bericht schon trifft. Das Ziel bekommt das
Kommando, nicht die Aufhängung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **kein eigenes Kompilat**: handgeführter Scanner in einer vorhandenen Laufzeit, oder warten, bis das Werkzeug seine Telemetrie selbst führt | kein Artefakt, keine Distribution, keine Plattform-Frage | gemessen gescheitert und im Code begründet (`internal/span/span.go`, verbatim: *„die awk-Fassung erkannte `error` nur als Top-Level-String und meldete "ok" fuer einen fehlgeschlagenen Aufruf"*) — fail-open hat gegen die stille Lücke eines handgeführten Scanners keine Kompensation; und der fremde Vertrag ist kein Weg, sondern ein Warten, während [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) heute abnahmebindend ist |
| B — **Quelle + Bauschritt zur Init-Zeit**, Toolchain des Ziels | kein mitgeliefertes Binär; das Ziel baut, was es fährt | gibt dem Ziel Code und eine Toolchain vor seiner Doc-Chain und seinem Sprach-ADR — die Inversion, gegen die [ADR-0007](0007-bootstrap-phasen.md) entschieden hat; und [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) hält das Ziel auf `bash + git + docker` |
| C — **Quelle mitliefern, Bau im gepinnten Image** zur Bootstrap-Zeit | keine Host-Toolchain; die Plattform ist über die Bau-Schalter erreichbar | das Ziel bekäme einen **fremden Quellbaum samt Bauschritt und Aktualisierungsweg** — derselbe Preis, den die abgelöste Festlegung 6 für die konditionale Variante beziffert hat; dazu Bauzeit und Netz bei **jedem** Bootstrap |
| D — **Release-Asset über das Netz holen** | ein Artefakt je Plattform, unabhängig vom Produkt-Binär | zweiter Vertriebskanal samt Prüfsummen-Mechanik; eine Verfügbarkeits-Abhängigkeit im Bootstrap; und das Asset einer Version existiert nicht, bevor sie veröffentlicht ist — der Beleg liefe gegen ein fremdes |
| E — **veröffentlichtes, digest-gepinntes OCI-Bild** + `docker create`/`docker cp` | **der Mechanismus, den der Dogfood heute selbst fährt** (`harness/tools/artifact-copy.sh`, gerufen aus dem Rezept, das in `make gates` steht); digest-gepinnt und damit reproduzierbar | verlangt genau das **eigene OCI-Image als Vertriebsmittel**, auf das [ADR-0003](0003-go-native-binaries.md) verzichtet hat, mit derselben Begründung, die dort steht (*native Binaries sind bereits plattformübergreifend*); das Bild eines Standes kann **nicht** von dem Stand erzeugt werden, der es verbraucht — der Beleg prüfte einen fremden, früheren Träger, und *„was ins Ziel geht, ist hier erprobt"* hielte nicht; ob `docker create` über ein Bild fremder Architektur trägt, ist hier **ungemessen** |
| F — **eigenes Emitter-Binär, ins Produkt-Binär eingebettet** | dieselben vier Konstruktions-Eigenschaften wie G; der Träger kann **konstruktiv** kein Repo bootstrappen — die kleinste Fähigkeitsfläche | der Produkt-Bau hängt am Emitter-Bau derselben Plattform, und die Einbettung verlangt die Datei zur Übersetzungszeit **jeder** Stufe — also einen committeten Platzhalter, der aussieht wie ein Träger und keiner ist; [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) verlangt Schreiber **und** Auswertung, also zwei Blobs. Gleiche Eigenschaften, höherer Preis |
| **G — der Träger IST das Produkt-Binär: Selbst-Kopie in den gitignorierten Zustands-Bereich, Schreiber und Auswertung als Unterkommandos (gewählt)** | die Plattform ist bewiesen statt hergeleitet; kein zweiter Kanal, kein Netz, kein Bauschritt, keine zweite Matrix; [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) durch Konstruktion; der Dogfood kann **denselben** Einstiegspunkt fahren, womit Folgepflicht 1 der abgelösten Entscheidung eingelöst statt umgangen wird; die Konstruktion schrumpft um zwei Bau-Stufen | der Hook startet je Tool-Call das Produkt-Binär — die Schwelle aus [ADR-0011](0011-telemetrie-erfassung-policy.md) bindet und ist **hier nicht gemessen**; der abgelegte Träger trägt die Bootstrap-Fähigkeit mit sich, die Alternative F konstruktiv ausschlösse |

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
  *„nicht die Grenze zu erhöhen, sondern der Umfang zu senken"*), die **Messung ist geschuldet**,
  und ihr negativer Ausgang hat eine benannte Antwort: Alternative F trägt dieselben
  Eigenschaften mit getrenntem Einstiegspunkt.
- **Negativ:** der Träger liegt gitignored. Ein frischer Klon des Adopter-Repos hat ihn nicht und
  erfasst still nichts, bis jemand das Werkzeug erneut laufen lässt. Die Auswertung macht es
  sichtbar, ein Gate darf es nicht (Festlegung 5(c)) — **die Grenze ist benannt, nicht
  geschlossen**.
- **Negativ:** der abgelegte Träger kann ein Repo bootstrappen. Der Zugewinn eines konstruktiven
  Ausschlusses wäre gering — wer den Träger startet, hat das Binär ohnehin —, aber er ist **kein
  Nichts**, und die Abwägung steht in der Tabelle, nicht im Kommentar.
- **Grenze:** die Rollen-Achse im Ziel ruht auf den kanonischen Rollennamen und auf
  Adopter-Disziplin. Das ist keine Folge dieser Entscheidung, sondern die Grenze, die
  [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) selbst
  ausspricht; sie steht im emittierten Feldlisten-Dokument, damit sie dort steht, wo sie anfällt.
- **Folgepflicht 1 — der Dogfood zieht den Einstiegspunkt nach.** Emitter und Auswertung werden
  Unterkommandos, die zwei Bau-Stufen und das Bau-Ziel entfallen, die Hook-Konfiguration dieses
  Repos ruft denselben Einstiegspunkt wie das Ziel. Ohne diesen Nachzug emittierte der Beleg
  einen Einstiegspunkt, den der Dogfood nie ausführt.
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
- **Folgepflicht 5 — der Wellen-Plan der Träger-Aussage wird an zwei Stellen falsch.** Seine
  Träger-Tabelle führt für die Modul-15-Blöcke den Wert *„entschieden, permanent nicht emittiert"*,
  und sein Out-of-Scope begründet den Ausschluss der Modul-15-Emission mit einem Change Request,
  *„solange er offen ist"* — er ist angenommen. Das Nachziehen ist **Plan-Arbeit**, nicht Teil
  dieser Entscheidung.
- **Folgepflicht 6 — die drei Abwesenheits-Wächter der abgelösten Entscheidung werden
  Anwesenheits-Wächter.** Sie waren dort geschuldet und nicht geliefert; gebaut werden jetzt die
  umgekehrten. Ein Wächter, der eine Abwesenheit prüft, die es nicht mehr geben soll, ist kein
  halber Wächter, sondern ein falscher.
- **Folgepflicht 7 — der ADR-Index bekommt bei der Annahme die Teil-Revisions-Annotation** an der
  abgelösten Entscheidung, in der dort geübten Form. Bis dahin nennt der Index diese Entscheidung
  als *Proposed* und ihren Umfang; eine Revision, die noch nicht beschlossen ist, wird nicht als
  vollzogen ausgewiesen.
- **Folgepflicht 8 — die Kommentare, die die heutige Trennung begründen, beschreiben danach eine
  Konstruktion, die es nicht mehr gibt.** Sie nennen als Entscheidungs-Ort einen Plan-Schnitt; die
  Entscheidung ist hier gefallen, und wer die Stelle anfasst, zieht den Kommentar nach
  ([`AGENTS.md`](../../../AGENTS.md) §3.7).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make full-smoke` | **Der Träger schreibt im Ziel.** Im frisch gebootstrappten tmp-Repo erzeugt der abgelegte Träger aus einer synthetischen Payload einen Span, und `git check-ignore` im Ziel bestätigt dessen Ablageort — der Nachbau dessen, was `span-check` hier für den Dogfood leistet. **Geschuldet, nicht geliefert.** Die Klammer über **beide** Bootstrap-Varianten (sprachlos und mit Sprache) gehört dazu: die Erfassung ist sprach-agnostisch, ein Zahn in nur einer Variante belegte das nicht | `make full-smoke` |
| `make test` · `make mutate` | **Die Zusage aus [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), mit ihrem Gegenbeispiel.** Scheitert die Platzierung des Trägers, trägt die emittierte `.claude/settings.json` **keinen** Erfassungs-Hook, es liegt **kein** Wrapper, und der Bootstrap endet erfolgreich. **Rot zu sehen ist:** die Kopplung aufheben — den Hook-Eintrag unbedingt schreiben —, dann muss der Wächter fallen. Ohne dieses Rot ist die Zusage eine Absicht. **Geschuldet, nicht geliefert** | `make test`, `make mutate` |
| `make test` · `make mutate` | **Die fail-open-Konstruktion am neuen Einstiegspunkt.** Ein Träger, dessen innere Arbeit fehlschlägt, endet mit Exit 0 und leerem stdout — auch das seiner Kindprozesse; die Klemme zu entfernen färbt rot. Die Zähne existieren, sie hängen am alten Programm (Folgepflicht 2) | `make test`, `make mutate` |
| `make test` | **Die Anwesenheits-Wächter.** Nach dem Bootstrap liegen im Ziel Träger, Wrapper, Rollen-Typen und die Feldliste; die Prüfung hat die Gestalt des bestehenden Abwesenheits-Wächters in `internal/emit/enforce_test.go`, nur umgekehrt, und jede ist einmal rot zu sehen, indem das Artefakt probeweise weggelassen wird. **Geschuldet, nicht geliefert** (Folgepflicht 6) | `make test`, `make mutate` |
| `make test` | **Die Feldliste im Ziel ist der Ausdruck des Trägers.** Das emittierte Dokument ist byte-gleich mit dem, was der Träger über sein eigenes Schema ausgibt; ein Feld, das erfasst wird und dort fehlt, färbt rot. Damit ist die Drift konstruktiv ausgeschlossen statt per Regel verboten | `make test` |
| `make full-smoke` | **Die Auswertung meldet ihre Leere.** Über einem Bestand ohne Verbrauchs-Zähler nennt sie ihre Abdeckung und weist **keine** Bilanz aus; eine Ausgabe, die über leerem Bestand eine Zahl trägt, ist der Befund. **Geschuldet, nicht geliefert** | `make full-smoke` |
| — | **Nicht maschinell prüfbar, und darum hier ohne Zeile:** dass ein Adopter seine Rollen-Typen unter den kanonischen Namen führt. Das ist die Grenze aus [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Benannte Grenze; sie wird ausgesprochen, nicht bewacht | — |

## Re-Evaluierungs-Trigger

- **Wenn der Aufschlag je Tool-Call die Schwelle aus
  [ADR-0011](0011-telemetrie-erfassung-policy.md) reißt** *(feedback — eine Messung mit
  festgelegter Schwelle, kein Gefühl)*: Annahme (c) fällt. Die Antwort ist **nicht**, die Schwelle
  zu heben — jene Quelle sagt es selbst —, sondern den Umfang zu senken oder den Einstiegspunkt zu
  trennen; Alternative F steht dafür bereit und trägt dieselben vier Konstruktions-Eigenschaften.
- **Wenn ein Adopter-Bestand Verbrauchs-Zähler trägt** *(feedback — an der Ausgabe der emittierten
  Auswertung ablesbar)*: dann trägt sie eine Bilanz, und das widerspricht nichts — Festlegung 8
  sagt eine Abdeckung zu, keine Leere. Fällig wird dann die Frage, ob die emittierte Auswertung
  dieselbe Aufteilung des Sammelpostens braucht, die
  [ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) für den Dogfood entschieden hat.
- **Wenn das Agenten-Werkzeug seine Hook-Oberfläche oder seinen Konfigurations-Ort ändert**
  *(feedforward — fremder Vertrag, bemerkt, nicht herbeigeführt)*: Annahme (d) fällt. Auf der
  emittierten Ebene wiegt das schwerer als hier: ein fremdes Repo zieht erst nach, wenn jemand das
  Werkzeug dort erneut laufen lässt — die Konvergenz-Klasse aus Festlegung 4 ist der einzige Weg
  dorthin.
- **Wenn ein Bootstrap für eine andere Plattform ausgeführt wird als die, auf der die Hooks
  laufen** *(feedforward — an einem Ziel ablesbar, dessen Träger sich nicht ausführen lässt)*:
  Annahme (a) fällt, und mit ihr das tragende Argument von Festlegung 1. Dann ist die
  Plattform-Frage wieder zu stellen, und die Wege D, E und F werden verfügbar.
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

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-23 | **Proposed** | Architect-Verdikt zur angenommenen Anforderung [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Lastenheft 0.19.0): sie steht auf Rang 1 und verlangt, was die abgelöste Entscheidung als permanent ausgeschlossen hatte. Diese Entscheidung führt die Abzählung der Wege über ein Kriterium statt über eine Liste, wählt den Träger als das ausführbare Bild, dessen Zielplattform bewiesen statt hergeleitet ist, bindet Hook-Eintrag und Träger aneinander, löst die Konjunktion aus Festlegung 3 der abgelösten Entscheidung **getrennt für Träger und Zahl** auf und vollzieht den Adopter-Vertrag, den [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 5 für genau diesen Fall vorentschieden hat |
