# ADR-0020: Vom Observability-Modul geht nur die Doku-Konsistenz-Regel ins Ziel — als Konfiguration eines bereits mitgelieferten, advisory Trägers; die drei übrigen Blöcke bleiben permanent draußen

**Status:** Proposed

**Datum:** 2026-08-16

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die
emittierte Doc-Gate-Baseline — sie trägt den Träger von Festlegung 4 bereits, und ihre
Wachstums-Bedingung deckt dessen Konfiguration),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die
Aufzählung der emittierten Durchsetzungs-Mechanik samt ihrem Budget — sie wächst durch keine
Festlegung dieser Entscheidung),
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (*out-of-the-box grün* —
die Zusage, an der die Verdrahtungs-Frage von Festlegung 5 hängt),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (nichts
behaupten, was nicht läuft — die Regel, die der emittierte Träger durchsetzt, an der die
Rollen-Typen scheitern und die die emittierten Doku-Tische heute selbst verletzen),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (das
Abhängigkeitsbudget — es trägt die erste Nicht-Emission ausdrücklich **nicht**, s. Festlegung 1),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) (die
konditionale Gate-Emission, deren Muster Festlegung 6 prüft und verwirft),
[ADR-0003](0003-go-native-binaries.md) (**Accepted** — die kompilierte Form dieses Repos ist
selbst entschieden, nicht zufällig),
[ADR-0007](0007-bootstrap-phasen.md) (**Accepted** — die Phasen-Trennung und die
Idempotenz-Klassifikation; beide tragen Festlegung 1 und Festlegung 4),
[ADR-0011](0011-telemetrie-erfassung-policy.md) (**Accepted** — die Erfassungs-Policy des
Dogfood samt ihrer Werkzeug-Grenze **und ihrer Betriebsart**; Festlegung 6 dieser Quelle klemmt
den Emitter auf fail-open und entscheidet damit den Trichter aus Festlegung 1),
[ADR-0012](0012-haupt-kontext-ohne-token-bilanz.md) (**Accepted** — die permanente Grenze
derselben Achse und der erste *ADR-Verdikt*-Fall dieser Matrix; drei Zellen folgen ihm hier),
[ADR-0013](0013-technik-stratum-als-zielort.md) (**Accepted** — das Gefäß folgt dem Gegenstand;
ihr vierter Re-Evaluierungs-Trigger fragt genau die Frage, die Festlegung 1 beantwortet),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (**Accepted** — die Form der Regelwerks-Belege
unten: Tag, Dateiname, Abschnitt, Zitat),
[CO-002](../carveouts/CO-002-token-achse-je-rolle.md) (die Vorbedingung zweier Zellen —
verwiesen, nicht abgeschrieben; **kein** Auflösungs-Trigger dieser Entscheidung, s. Festlegung 3),
[`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop: die Klasse, in der die Konfiguration des Trägers liegt),
[`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (das
tool-generierte Gate-Fragment, in dem der Träger verbatim liegt),
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
(die Default-Regel für emittierte Prüfbereiche — Festlegung 4 wendet sie an, Festlegung 5 grenzt
sie ab)

**Nicht tragend, und darum ausdrücklich benannt:**
[ADR-0019](0019-agent-guard-prueft-die-aufrufform.md) steht auf *Proposed*. Diese Entscheidung
ruht an keiner Stelle auf ihr: was Festlegung 2 braucht — dass die emittierte Ebene keine
Agenten-Telemetrie führt und kein emittiertes Artefakt `.claude/agents/` liest —, ist unten
**hier** gemessen und steht **hier**. Wird jene Entscheidung verworfen oder neu geschnitten,
fällt aus dieser keine Aussage weg; es fällt ein Hinweis weg. Eine Folgepflicht-Nummer eines
noch nicht angenommenen Artefakts wird deshalb nirgends fortgeschrieben.

**Schärft:**
[`architecture.md §5 Idempotenz, Fragment-Assembly und Resume`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
— dort steht die Fragment-Assembly, an die Festlegung 4 die Konfiguration des Doc-Gates koppelt.
Aufwärts-Deklaration der Änderungskopplung: wer diese Entscheidung ändert, zieht von hier die
betroffene Spec-Stelle nach. **Das Vertrags-Stratum ist nicht berührt:** keine der sechs
Festlegungen bewegt eine Anforderung, und eine permanente Nicht-Umsetzung ist in einem
abnahmebindenden Stratum ein Widerspruch in sich ([ADR-0013](0013-technik-stratum-als-zielort.md):
das Gefäß folgt dem Gegenstand).

---

## Kontext

### Was entschieden ist, und was diese Entscheidung daran tut

Das Observability-Modul der adoptierten Baseline führt **vier** Regelblöcke — Span-/Audit-Attribute,
Token-Attribution, Cache-Counter, Doku-Konsistenz-Drift. Das Werkzeug emittiert das Regelwerk
**vollständig** ins Ziel; ein gebootstrapptes Repo bekommt damit alle vier Regeln und, bis hierher,
keinen einzigen Träger. Der Wellen-Plan der Modul-15-Konformität verlangt je Regelblock **und je
Ebene** einen belegten Zustand. Für die Tool-Spalte nennt er zwei eigene Werte, zu denen das
**ADR-Verdikt** als dritter tritt — permanent ist eine Eigenschaft der Abweichung, nicht der Ebene.
Alle drei lauten dort verbatim:

> **emittiert** — im Ziel vorhanden **und dort rot gesehen** (s. u.)
>
> **nicht emittiert** — begründete Entscheidung **mit Auflösungs-Trigger** — dieselbe Pflicht wie
> bei „deklariert"; eine Entscheidung, die sich ohne Trigger als temporär ausgibt, ist nach Modul 7
> die permanente Ausnahme, die lügt. Ist sie wirklich permanent, gehört sie in eine ADR und die
> Zelle trägt „ADR-Verdikt"
>
> **ADR-Verdikt** — die Abweichung ist **permanent** und in einer ADR entschieden —
> Geltungsbereich und Begründung wie bei „deklariert", aber **ohne Auflösungs-Trigger**: Modul 7
> §Werkzeug-Wahl lässt ihn auf dem ADR-Pfad wegfallen. An seiner Stelle nennt die Zelle die
> Re-Evaluierungs-Trigger der ADR, die niemand herbeiführt, sondern bemerkt.

**Die Sach-Entscheidung ist am 2026-08-16 vom Auftraggeber gefallen** (zwei Setzungen desselben
Tages): die Erfassung geht nicht mit, Block 4 bekommt kein neues Artefakt. Diese ADR **trifft** sie
nicht. Sie leistet vier Dinge: sie begründet die vier Werte, sie führt jede Nicht-Emission durch
den Trichter aus Modul 7 (beobachtbare Schwelle oder Absicht — wo keine Schwelle trägt, gehört die
Zelle auf *ADR-Verdikt*, und das ist eine Architektur- und keine Auftraggeber-Frage), sie
entscheidet die zwei Architektur-Fragen, die am Träger von Block 4 hängen, und sie entkräftet die
konditionale Emission, statt sie zu übergehen.

**Der Trichter ändert dabei die Dauer, nicht die Sache.** Er führt die drei Nicht-Emissionen auf
*permanent*: was der Auftraggeber als *„geht nicht mit"* gesetzt hat, heißt nach dieser Prüfung
*„geht nicht mit, bis ein fremder Vertrag sich ändert"* — und nicht *„vorerst nicht"*. Das ist
kein Zusatz zur Setzung, sondern ihre ehrliche Frist; die Alternative wäre der Trigger, der
Temporalität behauptet und sie nicht einlösen kann.

### Was heute im Ziel liegt — und was davon wirkt

Gemessen am Emissions-Pfad dieses Repos (2026-08-16, gelesen, nicht an einem frischen Ziel
gefahren):

- **Der Träger von Block 4 ist bereits da.** Das tool-generierte `d-check.mk` kommt aus
  `--print-mk` des gepinnten Doku-Gate-Images und trägt die advisory `doc-*`-Rezepte **verbatim**
  ([`MR-010`](../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)),
  darunter `doc-targets`, das Modul der Deklarations-Konsistenz Doku ↔ Build-Targets. Es kostet
  keine Anforderung und kein Budget: es liegt in einer Datei, die
  [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) ohnehin
  zusagt.
- **Er ist wirkungslos, nicht grün.** Das Modul wertet erst mit einem `targets:`-Block der
  Konfiguration aus; weder die emittierte noch die hiesige `.d-check.yml` führt einen. Die Sonde,
  die das zeigt — heutige Konfiguration `0 Befund(e)`/Exit 0, mit Block `2 Befund(e)` der Art
  `gate-phantom`/Exit 1 —, ist im Plan dieses Schnitts gefahren und dort niedergelegt; dieser
  Architect-Lauf hat sie **nicht** wiederholt.
- **Der Erfassungs-Mechanismus ist ein Kompilat.** `cmd/span-emit` wird per Docker für die
  Host-Plattform gebaut, landet im gitignorierten Zustands-Bereich und wird von `.claude/settings.json`
  gerufen. Emittiert wird davon **nichts**: der Emit-Pfad führt die Kurs-Vorlagen, die
  Durchsetzungs-Mechanik, die Workflow-Commands, die Gate-Fragmente und den Aggregator — keinen
  Span-Emitter und kein `.claude/agents/`.
- **Die Rollen-Achse hängt nicht am Verzeichnis, und emittiert wird es von niemandem gelesen.**
  `grep -rn "claude/agents" --include=*.go .` liefert **null** Treffer, und dieselbe Zeichenkette
  steht in **keiner** Emissions- und keiner vendored Vorlage (beides am 2026-08-16 in diesem Lauf
  gefahren). Die Zuordnung Typ → Rolle lebt in einer hart notierten Liste in
  `internal/span/emit.go`.

### Warum die Erfassung nicht ohne Kompilat läuft — die Messung, die den Trichter entscheidet

Der Mechanismus ist ein Kompilat, weil dieses Repo die **nicht** kompilierte Fassung gebaut und
nach Messung verworfen hat. Der Grund steht als Kopfkommentar in `internal/span/span.go`,
verbatim:

> WARUM GO UND NICHT bash+awk (slice-059, nach Messung): der Emitter ist FAIL-OPEN. Der
> PreToolUse-Guard darf bei Unsicherheit blocken und faengt damit jede Luecke seines
> handgefuehrten Scanners auf; die Telemetrie hat diese Kompensation nicht — sie verliert im
> Zweifel still ihre eigene Aussage. Genau das trat ein: die awk-Fassung erkannte `error` nur als
> Top-Level-String und meldete "ok" fuer einen fehlgeschlagenen Aufruf.

**Ein Verweis auf `harness/tools/extract-agent-call.awk` entkräftet diese Messung nicht.** Der
Extraktor liest zwar auch eine Hook-Payload, aber weder dieselbe noch unter derselben Betriebsart.
`.claude/settings.json` hängt ihn an **`PreToolUse`** (Matcher `Agent`); er nimmt **zwei skalare
Werte an einem festen Schlüsselpfad der Tiefe 2** und darf bei Zweifel `exit 3` liefern, worauf
der Guard verweigert — er ist **fail-closed**. Der Emitter hängt an
`PostToolUse`/`PostToolUseFailure`/`SubagentStart` (leerer Matcher) und liest sieben
Top-Level-Keys, `tool_input`, die Dauer, die **Rohlänge** von `tool_response`, neun Blattwerte
hinter einem zweistufigen Abstieg (`internal/span/response.go`) und ein `error`, das je nach
Werkzeug String, Objekt, Array, Zahl oder `null` ist. Der entscheidende Unterschied ist nicht die
Größe, sondern die **Betriebsart** — und die ist nicht wählbar, sondern *Accepted* entschieden
([ADR-0011](0011-telemetrie-erfassung-policy.md) §Entscheidung, verbatim):

> der Erfassungs-*Umfang* fail-closed (im Zweifel nichts erfassen), der Erfassungs-*Betrieb*
> fail-open (im Zweifel den Lauf nicht behindern)

Dieselbe Quelle klemmt in Festlegung 6 den Emitter mechanisch fest: *„Der Emitter gibt auf stdout
nichts aus"* und *„Sein Exit-Code ist hart auf 0 geklemmt"*. Ein Emitter, der nicht sprechen darf,
kann einen Parse-Zweifel nicht melden — er verliert ihn.

**Damit sind die Ausgänge abzählbar, und keiner steht in unserer Hand:**

1. **Handgeführter Scanner in einer vorhandenen Laufzeit.** Gemessen und gescheitert, und der
   Fehler ist nicht ein Implementierungsfehler, sondern die Kombination: die Lücken eines
   handgeführten Scanners sind **still**, und fail-open hat gegen Stille keine Kompensation.
2. **Den Emitter fail-closed machen.** Änderte
   [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 6, die *Accepted* ist, und hieße:
   die Telemetrie verweigert bei Parse-Zweifel den Tool-Call. Das ist die dort ausdrücklich
   verworfene Gegen-Entscheidung.
3. **Das Schema so verkleinern, dass kein polymorpher Wert bleibt.** Der polymorphe Wert ist
   `error` — also genau die Unterscheidung *gelungen/fehlgeschlagen*. Ohne sie meldet der Span
   `ok` für einen fehlgeschlagenen Aufruf; das ist die Kennzahl-Lüge, für die Option A unten
   verworfen ist. Ein kleineres Schema für das Ziel ist damit **kein** Ausweg: das Feld, das den
   Parser braucht, ist das einzige, das nicht wegfallen kann.
4. **Roh speichern, später auswerten.** Die Redaktion ist Teil der **Erfassung**, nicht der
   Auswertung: [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 2 stellt sicher, dass
   *„kein Byte fremden Inhalts"* ins Log wandert. Ein Hook, der die Payload ungelesen ablegt,
   schreibt genau dieses Byte.
5. **Eine vorhandene Laufzeit mit echtem Parser.** `docker` steht in
   [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 4 auf der erlaubten Seite, aber
   dieselbe Festlegung zieht die Grenze weiter: *„`docker` ist erlaubt, ein Container-Start pro
   Tool-Call ist es praktisch nicht"* — mit 300–700 ms je Aufruf beziffert. Jede Laufzeit
   darüber hinaus müsste ein Adopter **installieren** und ist dort ausgeschlossen.

Was übrig bleibt, sind **fremde Verträge**: das Agenten-Werkzeug führt seine Telemetrie selbst,
oder ein Hook-Ereignis liefert eine Form, die ohne eigenen Parser auskommt. Beides kann eintreten;
niemand von uns führt es herbei.

**Der Trichter (Modul 7) fällt damit auf den ADR-Pfad**
(`v3.5.2`, `modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz). Er führt **zwei sequenzielle**
Fragen, *„Granularität vor Temporalität"*, und beide sind hier zu beantworten.

- **Frage 1, verbatim:** *„Granularität — einzelne Diskrepanz oder Cluster? Cluster im selben
  Geltungsbereich (mehrere Ausnahmen auf denselben Pfad/dieselbe Sub-Area) oder systemisches
  „Code existiert vor Doku"-Muster → BF-Sub-Area-Markierung mit Graduation-Plan als
  Modus-Deklaration im Adaptions-Block von `harness/conventions.md` …; Frage 2 entfällt. Einzelne
  Diskrepanz → Frage 2."* **Sie leitet hier nicht auf die BF-Markierung**, und zwar aus zwei
  Gründen, die beide am Symptom hängen: das Symptom-Muster ist **invertiert** — hier existiert
  die *Doku* (das vollständig emittierte Regelwerk) vor dem Code, nicht der Code vor der Doku,
  und ein frisch gebootstrapptes Ziel ist der reinste Greenfield-Fall, den dieses Werkzeug
  erzeugen kann. Und der Träger passt nicht: der Adaptions-Block registriert Abweichungen
  **dieses** Repos von seiner adoptierten Baseline; die emittierte Ebene ist keine Sub-Area
  dieses Repos, sondern ein fremdes Repo, das wir nicht betreiben. Eine Modus-Deklaration dort
  hätte weder Geltungsbereich noch Graduation-Trigger.
- **Frage 2, verbatim:** *„Temporalität — Trigger ernst zu erreichen? Ja (absehbarer Aufwand,
  sinnvolles Verhältnis zum Nutzen) → Carveout (Ziel-Form oben). Nein („nichts davon werden wir
  in absehbarer Zeit tun") → permanent, übergeführt in eine ADR."* **Die Antwort ist Nein.** Die
  fünf Ausgänge oben sind entweder gemessen gescheitert, oder sie ändern eine *Accepted*-ADR,
  oder sie liegen bei einem fremden Vertrag. Dieselbe Prüfung mit demselben Maßstab hat dieses
  Repo an der Nachbar-Achse schon gefahren:
  [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) hält für seinen eigenen Fall fest, dass
  die Antwort *„kippt auf Nein"*, sobald **nur noch fremde Wege** übrig sind. Hier sind von
  Anfang an nur fremde Wege übrig.

Auf dem ADR-Pfad *„fällt [der Trigger] weg, Checkliste reduziert auf die Architektur-Folgen"* —
dieselbe Quelle, derselbe Abschnitt. An seine Stelle treten die Re-Evaluierungs-Trigger unten;
sie werden **bemerkt**, nicht herbeigeführt.

### Was das Werkzeug dem `targets:`-Block anbietet

Die Startkonfiguration des gepinnten Images führt den Block auskommentiert mit; der Wortlaut ist
verbatim (2026-08-16 aus dem gepinnten Image gedruckt, `--network none`):

```yaml
# targets:
#   makefiles: [Makefile]                        # Regelnamen-Quelle(n)
#   doc-tables: [AGENTS.md, harness/README.md]   # Dateien mit make-X-Tabellen (Richtung 1 ⇒ gate-phantom)
#   authority: AGENTS.md                         # Vollständigkeits-Quelle (Richtung 2 ⇒ gate-undocumented)
#   exempt-targets: []                           # Regelnamen EXAKT (kein Glob, anders als tracked) — Utility-Targets ohne Doku-Pflicht
```

Zwei Eigenschaften entscheiden Festlegung 4, und beide sind im Plan dieses Schnitts gemessen: das
Modul folgt `include` **nicht** (Targets aus einem eingebundenen Fragment gelten als Phantome, wenn
nur der Aggregator gelistet ist) und es nimmt **keine Globs** (`"*.mk"` endet fail-closed).

### Was die emittierten Doku-Tische behaupten — und was daraus folgt (in diesem Lauf gemessen)

Die zwei emittierten Doku-Vorlagen führen je eine Gate-Tabelle. Zusammen behaupten sie **20
Nennungen von 9 verschiedenen** `make`-Zielen: `arch-check`, `ci`, `coverage-gate`,
`coverage-gate-critical`, `fullbuild`, `gates`, `help`, `lint`, `test` (2026-08-16 ausgezählt).
**Zwei davon** — `gates` und `help` — schreibt die Init-Phase selbst. **Fünf** existieren in
*keiner* Bootstrap-Variante. **Zwei** — `lint` und `test` — existieren **nur** mit `--lang`, und
zwar im Code-Gate-Fragment `harness/mk/<lang>.mk`, das die Sprach-Phase schreibt
(`internal/gen/golang.go`) und das der Datei-Satz aus
Festlegung 4(a) bewusst **nicht** nennt. Der emittierte Doku-Tisch verletzt damit die Anweisung,
die im selben emittierten Dokument unmittelbar über ihm steht (*„Nur Befehle aufzählen, die im
Makefile existieren. Halluzinierte Gates sind die häufigste Form von Harness-Lüge"*) — das ist
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
Ebene weiter, unabhängig von dieser Entscheidung.

Sechs Sonden gegen das gepinnte Image, in einer Wegwerf-Kopie **außerhalb** dieses Repos, jeweils
nur das Modul `targets` (Nachbau der Emission aus `internal/emit/makefile.go`,
`internal/emit/baseline.go`, `internal/emit/emit.go`, `internal/emit/enforce.go`,
`internal/gen/golang.go`; `makefiles:` immer der Satz aus Festlegung 4(a)):

| Sonde | Doku-Tisch | Variante | Ergebnis |
|---|---|---|---|
| A | wie heute emittiert | `--lang go` | **13 Befunde**, Exit 1 — davon **4 falsch** (`lint`, `test`; sie existieren) |
| B | wie heute emittiert | sprachlos | **13 Befunde**, Exit 1 — alle wahr, **gleiche Zeilen wie A** |
| C | nur die 5 nirgends existierenden Ansprüche entfernt | `--lang go` | **4 Befunde**, Exit 1 — **alle vier falsch** |
| D | dieselbe Fassung wie C | sprachlos | **4 Befunde**, Exit 1 — alle wahr, **gleiche Zeilen wie C** |
| E | nur Init-invariante Ansprüche | `--lang go` | **0 Befunde**, Exit 0 |
| F | nur Init-invariante Ansprüche | sprachlos | **0 Befunde**, Exit 0 |

Drei Beobachtungen, die Festlegung 4 tragen. **Erstens:** eine wahre und eine falsche Meldung
sind an der Ausgabe **nicht unterscheidbar** (A gegen B, C gegen D) — der Adopter kann am Befund
nicht ablesen, dass er einer ist. **Zweitens:** die naheliegende Teil-Reparatur (nur entfernen,
was in *keiner* Variante existiert) erzeugt den Fehler erst — C ist zu 100 % falsch. **Drittens:**
`exempt-targets: [lint, test]` hilft nicht; dieselbe Sonde mit der Ausnahmeliste meldet unverändert
**4 Befunde**, Exit 1. Die Ausnahmeliste greift auf der Vollständigkeits-Richtung, nicht auf
Richtung 1 — gemessen, nicht vermutet.

**Was E und F zeigen, ist die Bedingung, unter der der Block trägt:** behauptet der emittierte
Doku-Tisch nur Ziele, die die **Init-Phase selbst** definiert, dann ist jede behauptete Regel in
einer **genannten** Datei definiert — in *jeder* Variante —, und ein ungenanntes Fragment späterer
Phasen kostet nichts. Das ist keine Reihenfolge-Empfehlung, sondern eine Invariante zwischen zwei
Mengen, die dasselbe Werkzeug schreibt.

### Annahmen, auf denen diese Entscheidung steht

Kippt eine, kippt die Entscheidung; alle drei stehen unten als Re-Evaluierungs-Trigger.

- **(a)** Die Erfassung braucht am Hook einen echten Parser, und die Betriebsart bleibt fail-open.
  Fällt das, fällt der tragende Grund von Festlegung 1 und Festlegung 2.
- **(b)** Das Modul `targets` liest weiter nur genannte Dateien, folgt keinem `include` und nimmt
  keine Globs. Fällt das, verliert Festlegung 4 ihre harte Bedingung und die Kopplung an die
  Fragment-Assembly fällt weg.
- **(c)** Die emittierte Konfiguration bleibt *skip-if-present*
  ([ADR-0007](0007-bootstrap-phasen.md) Festlegung 3). Fällt das, ist der Wachstums-Weg aus
  Festlegung 4 neu zu wählen.

## Entscheidung

**Wir wählen Option G: nur Block 4 geht mit, ohne neues Artefakt, und die drei übrigen Blöcke sind
permanente, in dieser ADR entschiedene Nicht-Emissionen.** Sechs Festlegungen; die vier Zellen der
Tool-Spalte tragen danach:

| Modul-15-Regelblock | Wert der Tool-Zelle | Festlegung |
|---|---|---|
| Span-/Audit-Attribute (die Erfassung samt ihrem Pflichtfeld Rolle) | **ADR-Verdikt** | 1 und 2 |
| Token-Attribution | **ADR-Verdikt** | 3 |
| Cache-Counter | **ADR-Verdikt** | 3 |
| Doku-Konsistenz-Drift | **emittiert** — beide Hälften geschuldet, Gegen-Ausgang benannt | 4 und 5 |

**1. Der Erfassungs-Block wird nicht emittiert, und die Abweichung ist permanent — die Zelle trägt
*ADR-Verdikt*. Der tragende Grund ist die Phasen-Ordnung, nicht das Abhängigkeitsbudget.**
Geltungsbereich: die emittierte Ebene, jede Bootstrap-Variante. Der Mechanismus ist ein
kompiliertes Binär; ihn zu emittieren hieße eines von zwei Dingen, und beide scheitern. **Quelle
plus Bauschritt zur Init-Zeit** gäbe dem Ziel **Code vor seiner eigenen Doc-Chain und vor seinem
Sprach-ADR** — genau die Inversion, gegen die [ADR-0007](0007-bootstrap-phasen.md) entschieden hat,
und sie legte die Sprache am Schritt 0 fest, nachdem dieselbe Entscheidung `--lang` gerade optional
gemacht hat. **Ein vorgebautes Binär je Zielplattform** wäre eine neue Artefakt-Klasse mit eigener
Distribution und eigener Plattform-Matrix und ließe die Aufzählung aus
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wachsen.
**Was den Grund ausdrücklich NICHT trägt:**
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten).
[ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 4 zieht die Grenze *„nicht zwischen
‚Shell' und ‚Sprache', sondern zwischen **vorhanden** und **zu installieren**"* und führt `docker`
auf der erlaubten Seite; das Budget allein verböte die Emission nicht. Wer sie später mit dem
Budget begründet, begründet sie falsch.

**Warum permanent und nicht vorerst — und was an die Stelle des Triggers tritt.** Die Schwelle,
die die Frage wieder öffnete, wäre *die Erfassung läuft ohne Kompilat*. Sie ist am Bestand dieses
Repos ablesbar, aber sie ist **nicht ernst zu erreichen**: die fünf Ausgänge oben sind gemessen
gescheitert, ändern eine *Accepted*-ADR oder liegen bei einem fremden Vertrag. Modul-7-Frage 2
fällt damit auf *Nein*, der Trigger fällt weg, und die Zelle trägt *ADR-Verdikt* — mit derselben
Begründungspflicht und ohne die Frist, die niemand einlösen könnte. **Und die Permanenz gilt der
heutigen Konstruktion, nicht der Zukunft:** ändert das Agenten-Werkzeug seinen Vertrag, ist das ein
**Re-Evaluierungs-Trigger** unten — bemerkt, nicht herbeigeführt. Tritt er ein, ist die Frage neu
zu stellen, und ihr Inhalt ist dann die **Policy** — Schema, Redaktion, Ablageort. Was
[ADR-0011](0011-telemetrie-erfassung-policy.md) für den Dogfood entschieden hat, ist damit nicht
automatisch ein Adopter-Vertrag.

**2. Die Rollen-Typen gehen nicht mit; auch das ist permanent.** Geltungsbereich: die sechs Dateien
unter `.claude/agents/`. Die Rolle ist ein Pflichtfeld genau des Erfassungs-Blocks; ohne Erfassung
im Ziel hat sie dort keinen Abnehmer. **Ohne Abnehmer wären sie eine Behauptung:** kein emittiertes
Artefakt liest das Verzeichnis (die zwei Null-Messungen oben), und ein Ziel ohne Span misst an
einem rollen-benannten Lauf nichts — das ist die Klasse, die
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine Ebene
höher verbietet. **Das Ziel bleibt darum nicht rollenlos:** die emittierte Ebene führt die
Workflow-Commands und den Reviewer-Skill; was die Typen hinzufügen, ist allein der
**rollen-benannte Span**, und genau der hat dort keine Senke.
**Die Zelle folgt Festlegung 1, und die Kopplung ist einseitig:** solange der Erfassungs-Block
nicht emittiert wird, hat die Rolle im Ziel keinen Abnehmer — und dass er nicht emittiert wird, ist
nach Festlegung 1 permanent. Die Bedingung, die diese Zelle wieder öffnete, ist **die Emission des
Erfassungs-Blocks**, gleich auf welchem der beiden dort verworfenen Wege; sie steht unten als
Re-Evaluierungs-Trigger und ist bewusst nicht an *einen* der Wege gebunden.

**3. Token-Attribution und Cache-Counter werden nicht emittiert; beide Zellen tragen
*ADR-Verdikt*.** Beide Blöcke hängen am selben Eingang wie die Repo-Seite: solange kein
Agenten-Span Zähler trägt, trüge auch ein emittierter Bericht nie eine Zahl. **Und sie hängen
zusätzlich an Festlegung 1:** ein Ziel, das nicht erfasst, hat nichts zu verrechnen. Die Bedingung
für eine Emission ist damit **konjunktiv** — Zähler *und* Erfassung im Ziel —, und ihr erstes
Glied ist nach Festlegung 1 permanent verschlossen. Eine Konjunktion mit einem permanent falschen
Glied ist keine Schwelle; sie als Auflösungs-Trigger zu führen, wäre die Frist, die nicht laufen
kann.

**Was [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) hier ist und was nicht.** Er ist die
**Vorbedingung** des zweiten Glieds und wird **verwiesen, nicht abgeschrieben** — eine zweite
Fassung derselben Schwelle wäre die zweite Wahrheit, die driftet. Er ist **kein Auflösungs-Trigger
dieser Zellen**, und das ist bewusst: ein Carveout hat nach Modul 7 genau **zwei** Ausgänge, und
**beide** enden in `done/` — *aufgelöst* per `git mv`, oder *permanent* und in eine Folge-ADR
überführt. Wer eine Zelle auf einen Carveout als offenen Trigger zeigen ließe, hätte spätestens
nach seiner Auflösung einen Verweis auf ein abgeschlossenes Artefakt und keine Auskunft darüber, ob
die Zelle offen oder erledigt ist. Hier zeigt die Zelle stattdessen auf die **Frage**, die er
stellt — *trägt ein `Agent`-Span wieder Rolle und Zähler?* —, und beide Ausgänge dieser Frage sind
unten Re-Evaluierungs-Trigger. Wo die Antwort steht, ist am Zustand ablesbar: im Carveout unter
`done/`, oder in der Folge-ADR, die ihn überführt.

**4. Der Doku-Konsistenz-Block wird emittiert, ohne neues Artefakt. Die Konfiguration nennt genau
den Datei-Satz, den die emittierende Phase selbst schreibt — und der emittierte Doku-Tisch
behauptet genau die Ziele, die dieselbe Phase definiert.** Träger ist das bereits mitgelieferte
`doc-targets`; neu ist **nur** seine Konfiguration. Fünf Teil-Festlegungen:

- **(a) `makefiles:` nennt die fünf Init-invarianten Dateien** — den Aggregator `Makefile`, das
  tool-generierte `d-check.mk` und die drei Init-Fragmente aus `harness/mk/*.mk` (`baseline.mk`,
  `doc-gate.mk`, `enforce.mk`). **Das Kriterium ist keine Liste, sondern eine Eigenschaft:** genannt
  wird, was die emittierende Phase selbst schreibt und was darum in **jeder** Variante dieser Phase
  existiert. Fragmente späterer Phasen — das Code-Gate-Fragment je Modul, das Arch-Gate-Fragment,
  `a-check.mk` — werden **nicht** genannt.
- **(b) Warum diese Grenze und keine andere: die zwei Fehlerbilder sind nicht gleich schwer.** Eine
  genannte Datei, die einer Variante fehlt, tötet das Modul fail-closed für diese Variante; eine
  ungenannte Makefile lässt es echte Targets als Phantome melden — **wenn** ein Doku-Tisch sie
  behauptet. **Existenz ist die harte Bedingung, Vollständigkeit die weiche** — und die fünf sind
  der **eindeutig größte** Satz, der die harte Bedingung in jeder Variante erfüllt. Genau so
  entscheidet
  [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  einen emittierten Prüfbereich: nach dem Fehlerbild, nicht nach vermuteter Präferenz — der zu enge
  Default wird laut und kostet eine Zeile in einer Datei, die dem Adopter gehört.
- **(c) Die weiche Bedingung wird zweigeteilt getragen, und die Teilung folgt der Urheberschaft.**
  **Was das Werkzeug schreibt, ist unsere Pflicht:** die emittierten Doku-Tische dürfen nur
  Init-invariante Ziele behaupten (Sonden E/F), und jede spätere Phase, die ein Ziel emittiert,
  emittiert **keinen** Doku-Anspruch darauf — sie kann ihn nicht decken, weil die Konfiguration
  nach Annahme (c) *skip-if-present* ist und der Block nach der Init-Phase **nicht mehr wachsen
  kann**. Diese Richtung ist **kein** Adopter-Belang und wird auch nicht als solcher geführt.
  **Was der Adopter schreibt, ist seine Pflicht:** trägt er ein eigenes Target ein und behauptet
  es in seinem Doku-Tisch, erweitert er `targets.makefiles:` um die Datei, die es definiert. Dafür
  führt die emittierte Konfiguration den Block mit einem Kopplungs-Kommentar, der die Regel und
  beide Fehlerbilder nennt — dieselbe Form, in der sie ihre `ids`- und `codepaths`-Blöcke schon
  auskommentiert mitführt, und die Form, die
  [`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) mit *„der
  Gate-Config wächst mit den Artefakten"* verlangt. **Eine tool-seitige Erweiterung ist
  ausgeschlossen:** die Konfiguration ist *skip-if-present*, und eine anhängende Sprach-Phase wäre
  der In-Place-Edit, den [ADR-0007](0007-bootstrap-phasen.md) für die Makefile verworfen hat
  (*„In-Place-Edit ist fragil + nicht idempotent (Re-Lauf/Reihenfolge-Drift)"*). Damit ist die
  Kopplung entschieden: sie ist **deklariert**, nicht automatisiert — aber sie ist auf der Seite
  deklariert, auf der sie entsteht. **Warum die Konfiguration dennoch hier steht und nicht im
  Steering-Loop:** sie ist ein Gate-*Anheben* und bräuchte für sich keine Entscheidung
  ([`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
  Zu entscheiden ist nicht das Anheben, sondern die **Kopplung**, die es erzeugt.
- **(d) `authority:` bleibt weg — Richtung 2 wird nicht emittiert.** Sie verlangte, dass **jeder**
  Regelname der genannten Makefiles im `AGENTS.md` des Ziels dokumentiert ist; allein `d-check.mk`
  führt die advisory `doc-*`-Rezepte, die bewusst **kein** Gate behaupten. Richtung 2 machte damit
  aus der Regel des Qualitäts-Moduls (`v3.5.2`, `modul-13-quality-gates.md` §Hard Rule
  (Doku-Disziplin): *„Vorhanden ≠ behauptet. Verboten ist ein behauptetes Gate ohne Deckung, nicht
  ein vorhandenes Target ohne Anspruch."*) einen Befund. Die Ausnahmeliste nähme nur **exakte**
  Namen und driftete mit jedem Pin-Sprung des Images. Das Observability-Modul selbst trennt die
  Richtungen nach Härte (`v3.5.2`, `modul-15-observability.md` §Doku-Konsistenz-Drift-Regeln: *„ein
  neu hinzugefügtes Target ohne AGENTS.md-Eintrag ist Vorwärts-Drift (Doku hinkt nach), andere Härte
  als behauptete Geister-Befehle."*), und die Hard Rule, die es mindestens verlangt, ist
  Richtung 1. `doc-tables:` nennt die zwei Dokumente, die dasselbe Modul nennt. **Der Verzicht ist
  zugleich das, was (c) tragfähig macht:** ohne Richtung 2 kostet ein Target aus einer späteren
  Phase — und ein Target des Adopters, das er noch nicht dokumentiert hat — **nichts**.
- **(e) Reihenfolge, und sie ist über alle Varianten quantifiziert:** der Block geht **nicht** mit,
  solange ein emittiertes Dokument ein `make`-Ziel behauptet, das in **irgendeiner** Variante der
  emittierenden Phase fehlt. *„Ein frisches Ziel"* wäre hier keine Größe — ohne `--lang` fehlen
  **sieben** der neun behaupteten Ziele, mit `--lang go` **fünf**, und die Sonden C/D zeigen, dass
  genau die Differenz den falschen Befund erzeugt: wer die Bedingung an *einer* Variante prüft,
  emittiert in die andere hinein. Erfüllt ist sie erst, wenn der emittierte Doku-Tisch nur noch
  Init-invariante Ziele behauptet; dann ist jede behauptete Regel in einer genannten Datei
  definiert, in jeder Variante, und der Träger schweigt out-of-the-box (Sonden E/F). Sonst benennt
  der erste Befund die Datei des Adopters, während die Ursache in unserer Emission liegt — und der
  Beleg der zweiten Richtung ginge im Grundrauschen unter.

**5. Ein advisory Träger verdient den Wert *emittiert*. Die Verdrahtung in `make gates` des Ziels
ist heute doppelt ausgeschlossen — und die Zelle trägt den Wert mit benanntem Gegen-Ausgang.**

- **(a) Der Wert verlangt zwei Dinge, und keines davon ist ein Gate-Lauf.** *„Im Ziel vorhanden und
  dort rot gesehen"* — `doc-targets` endet auf Befund mit Exit 1, und das ist rot, wer immer es
  fährt. *Rot gesehen* und *im Gate-Lauf* sind zweierlei. **Das unterscheidet den Fall vom
  einzigen Präzedenzfall derselben Welle**, in dem ein Kandidat in der Repo-Spalte ausgeschlossen
  wurde, weil *„ein Bericht kein Wächter"* sei: dort war der Grund nicht die Aufhängung, sondern
  dass der Kandidat **nichts rot färben kann** — er hat keinen Befund-Ausgang und keinen
  Exit-Code, der von null abweicht. `doc-targets` hat beides; er ist ein Wächter ohne Aufhängung,
  kein Bericht. Wer die zwei Fälle nebeneinanderlegt, liest an dieser Eigenschaft, warum dieselbe
  Frage einmal ausschließt und einmal nicht.
- **(b) So ist
  [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
  für einen advisory Träger zu lesen:** sein Geltungsbereich ist *„jeder Prüfbereich, dessen Schärfe
  wir für unbekannte Nutzer festlegen"*. Er entscheidet die **Schärfe eines emittierten
  Prüfbereichs** — und damit Festlegung 4(b) —, nicht den **Lebenszyklus seines Trägers**. Ihn auf
  die Verdrahtung auszudehnen, hieße *„laut falsch schlägt leise falsch"* von der Konfiguration auf
  die Aufhängung zu übertragen; das kollidierte mit der anderen Hälfte von
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) und mit
  *„Vorhanden ≠ behauptet"*, auf dem die Nicht-Gate-Verify-Klasse dieses Repos steht.
- **(c) Was advisory kostet, ist nicht der Wert, sondern eine Angabe — und sie wird vollständig
  gemacht.** Das Observability-Modul verlangt je Doku-Konsistenz-Regel fünf Felder, darunter eines,
  das hier eine Entscheidung braucht (`v3.5.2`, `modul-15-observability.md`
  §Doku-Konsistenz-Drift-Regeln: *„Lebenszyklus | ist das ein Pre-commit-Check, Pre-integration,
  oder Continuous"*). **Der Wert ist *Pre-integration***, und er wird mit seiner Lücke genannt: das
  emittierte Ziel liefert den **Aufruf** (`make doc-targets`), nicht die **Aufhängung** — es führt
  weder ein `verify:`-Target noch einen anderen Schritt, der die Regel von sich aus fährt (der
  Aggregator kennt `gates`, `help`, `record-gates`; die Fragmente steuern `baseline-verify`,
  `docs-check`, `record-gates` und — mit `--lang` — `lint`/`build`/`test` bei). Welcher
  Integrationsschritt sie fährt, entscheidet der Adopter; **wir behaupten sie nicht als seinen
  Gate-Lauf**. Warum sie nicht in `make gates` gehört, sagt das Verifikations-Modul von sich aus
  (`v3.5.2`, `modul-11-verification.md` §Fitness Function ohne Standard-Tool: *„eine DoD-/
  Closure-Frage hängt an `verify:` (nicht `make gates` — das ist für Code-Architektur-Fragen)"*);
  dass das genannte `verify:` im Ziel **fehlt**, ist die Lücke, nicht ein Gegenargument — sie steht
  unten als Re-Evaluierungs-Trigger.
- **(d) Die Verdrahtung ist nicht bloß ungewählt, sondern heute zweifach ausgeschlossen, und beide
  Gründe sind strukturell.** Ein frisches Ziel bekommt Dokumente, die Targets behaupten, die es
  nicht hat — ein verdrahteter Träger wäre out-of-the-box rot und bräche
  [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen). Und solange der
  Doku-Tisch Ziele behauptet, die erst eine spätere Phase definiert, ist der Datei-Satz aus
  Festlegung 4(a) für diese Variante unvollständig — ein verdrahteter Träger wäre rot für eine
  Variante, die wir selbst erzeugt haben. Beide Gründe sind behebbar, und die Behebung ist
  dieselbe wie in 4(e); beide stehen unten als Re-Evaluierungs-Trigger.
- **(e) Die Zelle trägt den Wert als Beschluss, und beide Hälften sind geschuldet.** *Vorhanden*
  ist der **Träger** heute, die **Regel** nicht — sie entsteht erst mit der Konfiguration, und die
  geht nach 4(e) noch nicht mit; *rot gesehen* ist sie ebenfalls nicht. Der Beleg gehört dem Slice,
  der ihn führt. **Gegen-Ausgang, damit ein gescheiterter Beleg keine leere Zelle hinterlässt:**
  lässt sich der eingebrachte Drift im Ziel nicht rot sehen, fällt die Zelle auf *nicht emittiert*,
  und ihr Auflösungs-Trigger ist dann Festlegung 4 dieser Entscheidung — der konfigurierte Träger,
  der rot werden kann. Dieser Trigger liegt, anders als die drei oben, **in unserer Hand**; deshalb
  ist er hier eine Schwelle und dort keine.

**6. Die Erfassung wird auch nicht KONDITIONAL emittiert. Das Muster der konditionalen
Gate-Emission kondiert auf der falschen Achse.**
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren) knüpft sein Gate
an die Existenz seines **eigenen Prüfbereichs** im Ziel — *„eine strukturelle Bedingung … keine
Liste von Architektur-Namen"*. **Der Prüfbereich der Telemetrie existiert in jedem Ziel:** ein
reines Doku-Ziel erzeugt Tool-Calls wie jedes andere. Damit ist der Gegenstand **entgegengesetzt**
— die konditionale Emission nimmt einem Ziel ein Gate, das **nichts zu prüfen** hätte; hier nähme
sie ihm einen Mechanismus, der **alles zu erfassen** hätte. Eine strukturelle Bedingung, die die
Ziele trennte, gibt es nicht; was übrig bleibt, ist die Bedingung *„das Ziel führt unsere
Sprache"*. Die schrumpft auf **einen Namen** — der Mechanismus braucht Go, nicht „eine Sprache",
und `gen.SupportedLangs()` führt `go` und `cpp` —, und damit ist sie exakt die Namensliste, die
dasselbe Lastenheft für Architekturen ausdrücklich verbietet, nur über Sprachen. **Der Preis wäre
zudem ein Vertrag, kein Handgriff:** die stärkste Fassung der Variante ließe ein `--lang go`-Ziel
den Emitter in seiner eigenen Sprach-Phase aus mitgeliefertem Quelltext bauen — dann wüchse die
Aufzählung aus
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) um einen
fremden Quellbaum samt Bauschritt und Aktualisierungsweg, und der Observability-Vertrag der
emittierten Ebene hinge an der Zielsprache. **Das Muster selbst ist nicht verworfen:** es bleibt
für jeden Observability-Belang verfügbar, dessen Prüfbereich im Ziel strukturell entscheidbar ist
— Block 4 ist der Fall, in dem es trägt, denn dort ist der Prüfbereich der Doku-Tisch, und der
existiert in jedem Ziel.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **alle vier Blöcke emittieren** (Span-Emitter, Rollen-Typen, Auswertung, Doku-Konsistenz) | das Ziel bekäme das Modul, das sein Regelwerk führt, vollständig | die Inversion aus [ADR-0007](0007-bootstrap-phasen.md) am Schritt 0; eine neue Artefakt-Klasse mit Sicherheitsfläche (redigierte Tool-Argumente) im Ziel; zwei Blöcke ohne jeden Eingang — ein Bericht, der nie eine Zahl trägt, ist die Gate-Lüge als Kennzahl |
| B — **gar nichts emittieren**, das Ziel bekommt das Regelwerk und keinen Träger | ein Handgriff weniger; keine Kopplung an die Fragment-Assembly | der Träger von Block 4 **liegt schon im Ziel** — ihn ungenutzt zu lassen, ist keine Entscheidung, sondern die Leere, die diese Welle schließen soll. Und der billigste der vier Blöcke bliebe der offene |
| C — **konditionale Erfassung** nach dem Muster der Arch-Gate-Emission | „gar nicht" wäre nicht die einzige Alternative zu „immer"; ein Ziel mit Skelett bekäme sie | der Prüfbereich existiert in **jedem** Ziel — es gibt keine strukturelle Bedingung, die trennt; übrig bleibt eine Namensliste über Sprachen, und der Observability-Vertrag hinge an der Zielsprache (Festlegung 6) |
| D — **Block 4 mit eigenem Artefakt** (ein Konsistenz-Skript in `bash`/`awk` im Ziel) | unabhängig vom Doku-Gate-Image und seiner Konfiguration | ein zweiter Träger neben dem mitgelieferten; die Aufzählung aus [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wüchse um eine Artefakt-Klasse — und damit entstünde eine Vertragsänderung, wo keine nötig ist |
| E — **Block 4 in `make gates` des Ziels verdrahten** | ein Gate schlägt einen Bericht, wo es tragen kann | heute doppelt ausgeschlossen: die emittierten Dokumente behaupten Targets, die ein frisches Ziel nicht hat, und der Datei-Satz der Konfiguration deckt sie in keiner Variante. Beides machte das Ziel out-of-the-box rot (Festlegung 5(d)) |
| F — **`nicht emittiert` mit Auflösungs-Trigger für die drei Blöcke** statt *ADR-Verdikt* | die Zellen sähen offen aus und versprächen eine Wiedervorlage | der Trigger wäre nicht ernst zu erreichen (fünf abgezählte Ausgänge, alle gemessen gescheitert, *Accepted*-ändernd oder fremd) — nach Modul 7 genau die permanente Ausnahme, die behauptet, temporär zu sein |
| **G — nur Block 4, ohne neues Artefakt, advisory; drei permanente Nicht-Emissionen (gewählt)** | der vorhandene Träger wird wirksam, ohne dass eine Anforderung wächst; jede Nicht-Emission nennt ihre Dauer ehrlich statt einer Frist, die niemand einlösen kann; die Kopplung an die Fragment-Assembly ist entschieden statt vertagt | drei von vier Blöcken bleiben im Ziel dauerhaft ohne Mechanismus, und das Ziel erfährt es nicht; die Emission von Block 4 wartet auf eine Vorarbeit, die diese Entscheidung nicht selbst leistet |

## Konsequenzen

- **Positiv:** die Tool-Spalte der Konformitäts-Matrix hat ihre vier Werte, und drei
  Nicht-Emissionen nennen ihre Dauer, statt eine Frist zu behaupten. Keine Anforderung wächst: kein
  Artefakt kommt hinzu, das Budget aus
  [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) bleibt unberührt, und
  die Aufzählung aus
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wächst nicht.
- **Negativ, und das ist der Preis:** ein gebootstrapptes Repo liest ein Regelwerk mit vier
  Observability-Blöcken und bekommt für drei davon **dauerhaft** keinen Mechanismus. **Und das
  Ziel erfährt es nicht:** eine Deklaration im Ziel wäre ein Artefakt, und genau das ist hier
  ausgeschlossen — die Grenze wird benannt, nicht geschlossen. Wer die Permanenz für zu weit hält,
  greift Festlegung 1 an, nicht die Formulierung: sie hängt an fünf abgezählten Ausgängen, und
  jeder einzelne ist widerlegbar.
- **Negativ:** der emittierte Träger ist nur so lange stimmig, wie jeder von einem emittierten
  Doku-Tisch behauptete Regelname in einer genannten Datei definiert ist. Auf der **Werkzeug**-Seite
  ist das eine Invariante, die jede spätere Emissions-Phase bindet (Festlegung 4(c)); auf der
  **Adopter**-Seite eine deklarierte Pflicht, die der Kopplungs-Kommentar in seiner eigenen Datei
  ausspricht. Bricht die erste, liest der Adopter einen Befund, der ein echtes Target ein Phantom
  nennt — und er kann ihn von einem wahren nicht unterscheiden (Sonden A/B und C/D).
- **Grenze, benannt statt behauptet: heute bewacht kein Sensor die drei Abwesenheiten — aber ein
  Sensor ist baubar.** Der einzige geschlossene Datei-Satz im Emit-Pfad ist der der Kurs-Vorlagen;
  die Durchsetzungs-Emission prüft **Enthaltensein**, keine Vollständigkeit, und `make full-smoke`
  prüft Anwesenheit und Inhalt **genannter** Artefakte. Eine geschlossene Liste des gesamten
  emittierten Datei-Satzes existiert nicht — für diese drei Aussagen braucht es sie aber auch
  nicht: `internal/emit/enforce_test.go` bewacht bereits eine **Abwesenheit** ohne jede Liste (nach
  `Enforce` ein `os.Stat` auf den Pfad des Sprach-Fragments, `t.Errorf`, wenn er existiert; dazu
  ein Enthaltensein-Test über der Pfadliste). Ein Wächter über *kein `.claude/agents/` im Ziel*,
  *kein Span-Emitter im Ziel*, *kein Token-Bericht im Ziel* hat exakt diese Gestalt. Er wird von
  dieser Entscheidung **nicht gebaut**; er ist Folgepflicht 6. Bis dahin tragen die drei
  Nicht-Emissionen ihre Verbindlichkeit aus dieser Entscheidung — Feedforward, kein Feedback.
- **Folgepflicht 1 — der Beleg emittiert nichts, was der Dogfood nicht selbst fährt.** Die
  Konfiguration aus Festlegung 4 ist auf **beiden** Ebenen dieselbe Frage: auch dieses Repo bindet
  sein `d-check.mk` per `include` ein und liefe in dasselbe fail-closed. Was ins Ziel geht, ist hier
  erprobt — die Reihenfolge *Erprobung → Entscheidung → Emission*, die derselbe Wellen-Plan zieht.
- **Folgepflicht 2 — die Reihenfolge aus Festlegung 4(e) bindet den emittierenden Schnitt, und ihre
  Vorarbeit ist ein eigener Gegenstand.** Der `targets:`-Block darf erst mitgehen, wenn kein
  emittiertes Dokument mehr ein `make`-Ziel behauptet, das in irgendeiner Variante der emittierenden
  Phase fehlt. Die Bedingung ist eine **Eigenschaft**, keine Adresse — und sie ist über **alle**
  Varianten zu prüfen, nicht an einer. **Übergabe an die Plan-Ebene, weil sie dort und nicht hier
  entschieden wird:** die Vorarbeit betrifft die emittierten Doku-Vorlagen, nicht die
  Doc-Gate-Konfiguration; sie ist damit ein anderer Gegenstand als der emittierende Schnitt und
  schuldet ihm zugleich seinen Eintritt. Wer die Welle schließt, hat eine Abhängigkeit auf ein
  Artefakt, das der Wellen-Plan heute nicht führt; sie gehört dort benannt. Sie besteht unabhängig
  von dieser Entscheidung: die behaupteten, nirgends existierenden Ziele verletzen
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) auch
  ohne jeden `targets:`-Block.
- **Folgepflicht 3 — [`architecture.md §5`](../../../spec/architecture.md#5-idempotenz-fragment-assembly-und-resume)
  nachziehen:** die Fragment-Assembly beschreibt heute den Aggregator und den Fragment-Drop, nicht
  die Kopplung, die Festlegung 4 an sie hängt. Der Nachzug gehört dem Eigentümer des Stratums, nicht
  dieser Entscheidung.
- **Folgepflicht 4 — der Kopplungs-Kommentar ist Teil des emittierten Blocks, nicht sein Beiwerk.**
  Geht der `targets:`-Block mit, geht er mit dem Kommentar mit, der die Adopter-Hälfte aus
  Festlegung 4(c) ausspricht: welches Fehlerbild entsteht, wenn eine Datei fehlt, und welches, wenn
  eine fehlt, die ein Doku-Tisch braucht. Ohne ihn ist die deklarierte Pflicht nirgends erklärt, wo
  sie anfällt.
- **Folgepflicht 5 — wird der Erfassungs-Block je emittiert, ist die Policy ein Adopter-Vertrag.**
  Dann sind Schema, Redaktion und Ablageort für ein fremdes Repo zu entscheiden, und die Frage aus
  [ADR-0013](0013-technik-stratum-als-zielort.md) Folgepflicht 3 (bekommt das Zielrepo die
  Feldtabelle in seinem Technik-Stratum?) wird fällig. Zugleich gehört dort **genannt**, dass die
  emittierte Ebene keinen Agent-Guard führt — die Rollen-Achse hinge sonst an einer Zuordnung, die
  im Ziel niemand prüft.
- **Folgepflicht 6 — die drei Abwesenheiten bekommen ihren Wächter.** Drei Tests nach `Bootstrap`
  im Muster von `internal/emit/enforce_test.go`, je einmal **rot gesehen**, indem die Abwesenheit
  probeweise aufgehoben wird. Geschuldet, nicht geliefert: diese Entscheidung stellt fest, dass der
  Sensor baubar ist, und baut ihn nicht.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `make full-smoke` | Im frisch gebootstrappten Ziel läuft `make gates` grün, **und** das emittierte `make doc-targets` meldet **null Befunde in beiden Bootstrap-Varianten** (sprachlos wie `--lang go` — Sonden E/F sind der Nachbau derselben Zusage außerhalb des Repos), **und** es meldet eine eingebrachte, targetlose `make`-Zeile als `gate-phantom` und schweigt nach ihrer Rücknahme — die zwei Richtungen, die die Welle für die Tool-Spalte verlangt, plus die Varianten-Klammer, ohne die ein falscher Befund von einem wahren nicht zu unterscheiden ist. **Geschuldet, nicht geliefert:** diese Entscheidung schreibt die Begründung, der Nachweis gehört dem Slice, der ihn führt — heute fährt der Voll-Smoke **eine** Variante | `make full-smoke` |
| `make test` | Für die drei permanenten Nicht-Emissionen je ein Wächter über der **Abwesenheit** im gebootstrappten Ziel — kein `.claude/agents/`, kein Span-Emitter, kein Token-Bericht —, gebaut wie der bestehende Abwesenheits-Wächter in `internal/emit/enforce_test.go` und je einmal rot gesehen. **Geschuldet, nicht geliefert** (Folgepflicht 6); bis dahin trägt die Verbindlichkeit diese Entscheidung, nicht ein Sensor | `make test`, `make mutate` |

## Re-Evaluierungs-Trigger

- **Wenn die Erfassung ohne eigenen Parser am Hook auskommt** *(feedforward — fremder Vertrag,
  bemerkt, nicht herbeigeführt: das Agenten-Werkzeug führt seine Telemetrie selbst, oder ein
  Hook-Ereignis liefert eine Form, die ohne Parser trägt)*: Annahme (a) fällt, Festlegung 1 ist neu
  zu prüfen, und mit ihr Festlegung 2. Die Folge-Entscheidung hat die Policy zu treffen, nicht bloß
  die Emission.
- **Wenn die Betriebsart des Emitters sich ändert** *(feedforward — eine Änderung an
  [ADR-0011](0011-telemetrie-erfassung-policy.md) Festlegung 6, also eine Folge-ADR, kein Sensor)*:
  fällt fail-open, fällt der zweite der fünf Ausgänge aus Festlegung 1, und die Abzählung ist neu
  zu führen.
- **Wenn der Erfassungs-Block im Ziel entsteht** — auf welchem Weg auch immer *(feedforward — an
  einem frisch gebootstrappten Ziel ablesbar, das bei einem Tool-Call einen Span schreibt)*: dann
  hat die Rollen-Achse im Ziel einen Abnehmer, und Festlegung 2 ist neu zu entscheiden. Der Trigger
  ist bewusst nicht an einen der zwei in Festlegung 1 verworfenen Wege gebunden.
- **Wenn die Frage hinter [CO-002](../carveouts/CO-002-token-achse-je-rolle.md) beantwortet ist**
  *(feedback — sie hat einen entscheidbaren Ausgang, und beide Ausgänge sind hier zu lesen)*: trägt
  ein `Agent`-Span wieder Rolle und Zähler, ist das **zweite** Glied der Konjunktion aus Festlegung
  3 offen — das erste bleibt es nach Festlegung 1, und beide Zellen bleiben, wo sie sind, bis auch
  jenes fällt. Trägt er sie nicht, ist die Vorbedingung selbst permanent, und Festlegung 3 steht auf
  zwei permanenten Gliedern statt auf einem.
- **Wenn das Modul `targets` einem `include` folgt oder Globs nimmt** *(feedforward — fremder
  Vertrag, sichtbar bei einem Pin-Sprung des Images)*: Annahme (b) fällt, Festlegung 4(a) verliert
  ihre harte Bedingung, und die Kopplung an die Fragment-Assembly entfällt samt der Adopter-Pflicht
  aus Festlegung 4(c).
- **Wenn beide Ausschlüsse aus Festlegung 5(d) gefallen sind** *(feedforward — an einem Zustand
  ablesbar: die emittierten Dokumente behaupten nur noch Init-invariante Ziele, womit beide
  Ausschlüsse zugleich fallen)*: dann ist die Verdrahtung des Trägers in `make gates` des Ziels neu
  zu entscheiden, und mit ihr die Aufhängung, die der Lebenszyklus-Wert aus Festlegung 5(c) heute
  offen nennt. Sie ist heute ausgeschlossen, nicht abgelehnt.
- **Wenn die emittierte Konfiguration ihre Idempotenz-Klasse wechselt** *(feedforward — eine
  Änderung an [ADR-0007](0007-bootstrap-phasen.md) Festlegung 3, kein Sensor)*: Annahme (c) fällt,
  der `targets:`-Block kann nach der Init-Phase wachsen, und die Werkzeug-Hälfte der Pflicht aus
  Festlegung 4(c) ist neu zu wählen — sie steht heute nur deshalb auf der Anspruchs-Seite, weil die
  Konfigurations-Seite eingefroren ist.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-16 | **Proposed** | Architect-Verdikt zu den zwei Auftraggeber-Setzungen desselben Tages: die Erfassung geht nicht mit, Block 4 bekommt kein neues Artefakt. Diese Entscheidung begründet sie, führt die drei Nicht-Emissionen durch den Trichter aus Modul 7 — er fällt auf *permanent*, weil die Schwelle *„Erfassung ohne Kompilat"* an fünf abgezählten Ausgängen scheitert —, entscheidet die Kopplung der Doku-Gate-Konfiguration an die Fragment-Assembly als Invariante zwischen Anspruchs- und Datei-Menge (sechs Sonden gegen das gepinnte Image) und entkräftet die konditionale Emission |
