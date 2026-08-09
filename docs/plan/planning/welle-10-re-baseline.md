# Welle welle-10: Re-Baseline `v3.5.2` → `v5.3.1`

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** Planner. **Datum:** 2026-08-09.

---

## 1. Welle-Ziel

Die adoptierte Baseline steht auf `v5.3.1`, **und jede Aussage dieses Repos über sie ist gegen
diesen Stand gemessen.** Der Pin ist davon der kleinste Teil.

**Der Zielstand ist beweglich, aber nicht beliebig** — und die Regel dafür gehört in den Plan,
nicht in den Dateinamen. Er wandert, wenn in ihm ein **gemessener Defekt** liegt, der eine
Entscheidung dieses Repos berührt; **nicht**, weil ein neuerer Tag existiert. *„Immer das
Neueste"* wäre kein Kriterium, sondern ein Abonnement: jeder Kurs-Tag zöge einen Plan-Umbau nach
sich, und der Zielstand hörte auf, eine Entscheidung zu sein. Ein Tag, dessen Delta dieses Repo
nicht berührt, bewegt ihn also nicht.

Für `v5.3.1` trifft beides zu. Der `regelwerk/`-Spiegel gibt `modul-08-agentenrollen.md` unter
`v5.3.0` an vier Stellen **paraphrasiert** statt quelltreu wieder und verliert dabei die
Exklusivität (*„genau die Artefaktklasse"*) und die Pointe des Abschnitts (*„meistens kein
Skill"*); `v5.3.1` stellt den Quelltext her. Getroffen sind wir, weil
[ADR-0015](../adr/0015-rollen-eigentum-an-norm-artefakten.md) ihr Rollen-Eigentum aus genau
diesem Modul herleitet — die Kurs-Regel dahinter lautet *Didaktik weglassen, Operatives quelltreu
übernehmen, nie paraphrasieren.*

**Was der Wechsel kostet, ist gemessen.** Im vendored Ausschnitt ändert `v5.3.0` → `v5.3.1`
**7 Dateien um +14/−13 Zeilen**
(`git diff --shortstat v5.3.0 v5.3.1 -- lab/regelwerk lab/templates`, lokaler Kurs-Klon);
die Dateizahl bleibt **26 + 25 = 51**. Der Roh-Diff über `lab/` zählt **80** Dateien und geht
glatt auf: **73** entfallen auf `lab/example`, das dieses Repo nicht vendort, die übrigen **7**
sind die oben genannten. **Keine Messung dieses Plans bricht:**
`modul-07-carveouts.md` — Träger der Zitat-Probe aus §6 von
[slice-081](open/slice-081-baum-tauschen-pin-ziehen.md) — ist zwischen beiden Tags byte-gleich,
und der einzige Hunk in `modul-08` liegt außerhalb des Closure-Schritts 3b.

Der Sprung ist **strukturell, nicht additiv**. Elf Releases, zwei Major-Bumps über drei
Major-Serien; das Regelwerk wächst von 21 auf 26 Dateien, aber die Rechnung ist `−3 +8` (gemessen
gegen einen lokalen Kurs-Klon, `git ls-tree -r --name-only <tag> lab/regelwerk | wc -l`):

- `grundlagen-konventionen.md` **zerfällt in sechs** Grundlagen-Dateien (`-begriffe`,
  `-bootstrap`, `-harness-dateien`, `-referenz-richtung`, `-source-precedence`, `-traceability`),
- `modul-03-lastenheft` → `modul-03-spec`, `modul-04-architektur-adrs` → `modul-04-adrs`,
- die Templates wachsen 21 → 25 (neu: `observations`, `reconciliation`, `welle-results`, und ein
  Eintrags-Template für den Adaptions-Block).

Damit verschwinden Pfade, auf die dieses Repo **34-mal aus 9 lebenden Artefakten** zeigt —
13-mal aus [`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder),
11-mal aus [`harness/conventions.md`](../../../harness/conventions.md#mr-000--baseline-aussage),
der Rest aus vier ADRs und drei Plan-Dateien. Gemessen mit
`git grep -o "\.harness/baseline/v3\.5\.2/[^ )]*" -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`
(Zeitdokumente ausgenommen — sie bleiben stehen, §6).

**Festlegung — die Migration läuft nach der Prozedur der Ziel-Fassung** (`v5.3.1`, Modul 2
§*Freshness-Audit der vendored Baseline*), nicht nach der gepinnten. Drei Gründe, und der erste
trägt allein: die gepinnte `v3.5.2` **beschreibt diesen Fall nicht** — sie nennt drei
Eigenschaften des Audits und keinen Adaptions-Durchgang, während die Ziel-Fassung sieben
Eigenschaften und für den Durchgang **fünf Ausgänge** setzt. Der `v3.5.2` zu folgen hieße daher
nicht, einer älteren Regel zu folgen, sondern gar keiner. Zweitens ist die Ziel-Prozedur die
einzige, die den Fall überhaupt kennt. Drittens ist sie auf einen Befund **aus diesem Repo**
entstanden — die Klasse „adoptiert, aber nie umgesetzt", die den Trigger von
[welle-09](welle-09-modul-15-konformitaet.md) stellte.

**Die Grenze dieser Festlegung gehört dazu:** sie gilt für die *Prozedur der Migration*, nicht
für den Ist-Zustand. Bis der Baum getauscht ist, ist `v3.5.2` die adoptierte Baseline und bleibt
für jede Konformitäts-Frage maßgeblich — dieser Plan entsteht darum per `cp` aus deren
`welle.template.md`, nicht aus der neuen. Wer das umdreht, misst den Ist-Zustand an einer
Fassung, die dieses Repo nicht adoptiert hat.

## 2. Trigger (Welle startet)

- **`make baseline-freshness` meldet VERALTET** — der Sensor ist in jedem Lauf seiner sichtbaren
  Historie rot, der älteste vom 2026-07-24; gepinnt ist `v3.5.2`, upstream steht `v5.3.1`. Der
  Auslöser ist damit beobachtbar und real eingetreten, nicht angesetzt.
- **[welle-09](welle-09-modul-15-konformitaet.md) liegt in `done/`.** Ihr Closure-Kriterium misst
  gegen **Modul 15 in der `v3.5.2`-Fassung**; ein Tausch während der Welle zöge ihr die Messlatte
  unter den Füßen weg. Die Reihenfolge steht aus Ordnungs-, nicht aus Risiko-Gründen: das Delta
  jenes Moduls ist gemessen (`git diff v3.5.2 v5.3.1 -- lab/regelwerk/modul-15-observability.md`
  → +7/−2 Zeilen in zwei Absätzen) und **bestätigt** beide Ergebnisse jener Welle — die
  Token-Attribution rechnet upstream ausdrücklich „auf Kontexte, nicht auf Personen", und die
  Rollen sind die aus Modul 8, „festgelegt durch das gestartete Rollen-Artefakt".

## 3. Closure-Trigger (Welle schließt)

Die Welle schließt, wenn **die drei Durchgänge der Ziel-Prozedur je einen Beleg tragen** — nicht,
wenn der Pin sitzt. Der Pin ist eine Zeile; die Durchgänge sind der Gegenstand.

- **Alle Slices dieser Welle in `done/`.**
- **Der Pin ist vollzogen:** `.harness/baseline/v5.3.1/` ist das **einzige** `<tag>`-Verzeichnis
  ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache):
  ein Tag zur Zeit), `make baseline-verify` grün über **51** statt 42 Dateien (26 Regelwerk + 25
  Templates).
- **Durchgang 1 — Adaptionen:** jeder der **24** Einträge von
  [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) bis
  [`MR-023`](../../../harness/conventions.md#mr-023--die-platzierung-der-kommentar-regel-ist-keine-abweichung)
  trägt genau einen
  der fünf Ausgänge mit Beleg. Vollständigkeit heißt hier **Inventar gegen Abdeckung**
  (`grep -c '^### MR-' harness/conventions.md` als Nenner), nicht „die auffälligen" — dieselbe
  Lücke, an der die Roadmap zwei kuratierte Listen führt.
- **Durchgang 2 — Form:** die Referenz-Form ist gegen die alte gehalten und die Pflichtfelder der
  neuen Gliederung stehen in den Singleton-Artefakten.
- **Durchgang 3 — Stichprobe gegen den Bestand:** ein Abschnitt **ohne** Delta ist geprüft und
  sein Ausgang verbucht. Er läuft unabhängig vom Ergebnis der Tag-Frage.
- **`make gates` grün** *und* die drei Sensoren außerhalb der Gates — `make smoke`,
  `make full-smoke`, `make mutate`. Sie gehören hier ins Kriterium, weil der Tag der
  **Emissions-Kanal** ist (`internal/fetch/baseline.go` `DefaultTag`): ein frisch gebootstrapptes
  Zielrepo zieht genau diesen Baum ([`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)).
- **Closure-Notiz `welle-10-results.md`** mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Der Zustand jedes Slice ist sein Lifecycle-Verzeichnis, hier nicht gespiegelt.

Die Reihenfolge ist tragend: **080 entscheidet, 081 vollzieht, 082–084 sind die drei Durchgänge
der Prozedur, 085 zieht die emittierte Ebene nach.** 080 liegt vor 081, weil der Tausch sonst an
einer Frage vorbeiläuft, die er selbst aufwirft.

| Slice | Titel | Bezug |
|---|---|---|
| slice-080 | Ein Verweis in die vendored Baseline überlebt den Tag-Wechsel | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| slice-081 | Baum tauschen, Pin ziehen, Verweise nachziehen | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| slice-082 | Adaptions-Durchgang: jeder Eintrag bekommt seinen Ausgang | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-083 | Form-Vergleich: Pflichtfelder und umbenannte Sektionen | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-084 | Stichprobe gegen den Bestand, nicht gegen das Delta | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-085 | Die emittierte Ebene zieht nach | [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |

**Die vierte und fünfte Eigenschaft der Ziel-Prozedur sind auf 082/083 verteilt, nicht
zusammengelegt** — der Adaptions-Durchgang fragt *„regelt die neue Fassung das, wofür dieser
Eintrag angelegt wurde?"*, der Form-Vergleich fragt *„hat sich die Gestalt der Artefakte
geändert?"*. Zwei Fragen, zwei Review-Sitzungen. 082 läuft zuerst, weil ein Eintrag, der
gegenstandslos wird, kein neues Pflichtfeld mehr braucht.

## 5. Abhängigkeiten

- **Wird blockiert von:** [welle-09](welle-09-modul-15-konformitaet.md) — sie misst gegen Modul 15
  in der gepinnten Fassung (§2).
- **Blockiert:** jeden Slice **außerhalb** dieser Welle, der den vendored Baum zitiert. Heute ist
  das genau einer ([slice-071](open/slice-071-cache-zaehler-getrennt.md)); er gehört zu welle-09
  und ist damit ohnehin vor dieser Welle fällig. Das Kommando
  `git grep -l '\.harness/baseline/v3\.5\.2/' -- docs/plan/planning/open docs/plan/planning/next`
  nennt daneben [slice-083](open/slice-083-form-vergleich-pflichtfelder.md) — der liegt **in**
  dieser Welle und nennt den alten Tag als Tree-Operanden der Vor-Tausch-Seite, nicht als Zeiger
  auf einen Baum, der stehen bleiben müsste.
- **Innerhalb der Welle:** 080 → 081 → {082 → 083, 084} → 085. 084 hängt nur am getauschten Baum,
  nicht am Adaptions-Durchgang: sein Gegenstand ist der Bestand, nicht die Änderung.

## 6. Out-of-Scope für diese Welle

- **Die Verzeichnis-Form des Adaptions-Blocks** — ein Eintrag je Datei in einem
  `conventions`-Verzeichnis, aufgelöste in dessen `done/`. Die Ziel-Baseline nennt sie
  **Default**, die Form selbst aber ausdrücklich **Wahl**; die Einzeldatei bleibt damit konform
  und schuldet keinen `MR`-Eintrag. Der Grund, den die Baseline für den Default nennt, trifft hier
  trotzdem zu — `wc -l harness/conventions.md` → **1124** Zeilen, die jeder Agentenlauf liest, mit
  wachsendem Anteil aufgelöster Einträge. Das ist ein Roadmap-Kandidat mit eigenem Trigger, keine
  Fracht dieser Welle: der Umzug zöge **jede** `MR-`Kennung des Repos auf einen neuen Pfad, und
  die sind nach [`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  linkpflichtig.
- **Zeitdokumente** unter `docs/reviews/**` und `docs/plan/planning/done/**`. Die drei
  verschwindenden Regelwerk-Dateinamen kommen dort in **13** Dateien vor; sie sind die historisch
  richtige Aussage über ihren Stand und werden nicht nachgezogen.
- **Die Umsetzung neuer Regelwerk-Inhalte.** Diese Welle stellt fest, *ob* ein Delta dieses Repo
  trifft, und wo es das tut, **deklariert** sie oder setzt um, was in einer Sitzung geht. Ein
  Delta, das eigene Arbeit verlangt, wird als Slice in `open/` notiert — sonst wächst die Welle
  auf die Größe des Deltas und verliert ihr Closure-Kriterium. Das ist dieselbe Grenze, die die
  Stichprobe der Ziel-Prozedur zieht („ein Abschnitt pro Audit, rotierend — keine Vollinventur").
- **Ein Sensor für die Adoptions-Lücke** („adoptiert, aber nie umgesetzt"). Er wäre die Antwort
  auf den Trigger von [welle-09](welle-09-modul-15-konformitaet.md), und die Stichprobe aus 084
  ist sein manueller Vorläufer. Ob er baubar ist, ist ungemessen.

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-10-results.md. -->

