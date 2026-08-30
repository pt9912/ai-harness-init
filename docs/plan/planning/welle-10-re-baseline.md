# Welle welle-10: Re-Baseline `v3.5.2` → `v5.12.0`

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-<NN>-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** kein Meilenstein-Bezug.

**Verantwortlich:** Planner. **Datum:** 2026-08-09.

---

## 1. Welle-Ziel

**Ziel-Zustand, nicht Ist-Zustand:** die adoptierte Baseline steht auf `v5.12.0`, **und jede
Aussage dieses Repos über sie ist gegen diesen Stand gemessen.** Der Pin ist davon der kleinste
Teil.

**Der Zielstand ist beweglich, und wen die Regel darüber bindet, ist entschieden.** Die Regel
gehört in den Plan, nicht in den Dateinamen — binden kann ein Plan aber nur, wen er adressiert.

**Adressiert sind die Rollen dieses Repos.** Ein Lauf hier bewegt den Zielstand nur, wenn in ihm
ein **gemessener Defekt** liegt, der eine Entscheidung dieses Repos berührt; **nicht**, weil ein
neuerer Tag existiert. `make baseline-freshness` ist damit ein Auslöser für einen Review, kein
Auftrag zum Nachziehen — wortgleich in der gepinnten wie in der Ziel-Fassung, je
`modul-02-harness-bootstrap.md` §*Freshness-Audit der vendored Baseline (Schritt 2)*: *„Ein neuer
Tag löst einen **Review** aus (Re-Vendoring mit eigenem Diff), keinen stillen Auto-Bump."*
(`for t in v3.5.2 v5.12.0; do git show $t:lab/regelwerk/modul-02-harness-bootstrap.md | grep -A1 'Ein neuer Tag löst einen'; done`
→ zweimal derselbe Zweizeiler, lokaler Kurs-Klon). Ohne diese
Grenze wäre der Zielstand ein Abonnement statt einer Entscheidung: jeder Kurs-Tag zöge einen
Plan-Umbau nach sich, und auch ein Tag, dessen Delta dieses Repo nicht berührt, bewegte ihn.

**Nicht adressiert ist der Auftraggeber.** Welche Fassung dieses Repo adoptieren *will*, ist keine
Ableitung aus einer Messung, sondern derselbe Akt wie die Adoption selbst; eine repo-interne Regel
kann ihn nicht binden, sondern nur **belegpflichtig** machen. Der Preis einer Setzung ist deshalb
kein Defekt, sondern ein Nachweis je Schritt — Aufpreis, berührte tragende Quellen, und ob eine
Messung dieses Plans dabei bricht. Adressierung und Begründung stehen in
[ADR-0018](../adr/0018-ziel-fassung-regiert-die-migration.md) §*Wer den Zielstand bewegt*; die
Nachweise der Setzungen führt dieselbe ADR (§*Der Zielstand ist … gezogen*). Dieser Plan doppelt
beides nicht — er trägt, was aus dem Zielstand für den Schnitt folgt.

**Ein solcher Defekt ist gemessen, und er trennt `v5.3.0` von `v5.3.1`.** Der
`regelwerk/`-Spiegel gibt `modul-08-agentenrollen.md` unter `v5.3.0` an vier Stellen
**paraphrasiert** statt quelltreu wieder und verliert dabei die Exklusivität (*„genau die
Artefaktklasse"*) und die Pointe des Abschnitts (*„meistens kein Skill"*); `v5.3.1` stellt den
Quelltext her. Getroffen sind wir, weil
[ADR-0015](../adr/0015-rollen-eigentum-an-norm-artefakten.md) ihr Rollen-Eigentum aus genau
diesem Modul herleitet — die Kurs-Regel dahinter lautet *Didaktik weglassen, Operatives quelltreu
übernehmen, nie paraphrasieren.* **Der Zielstand trägt die Reparatur weiter**, der gepinnte Baum
nicht: `for tag in v5.12.0 v3.5.2; do git grep -c 'genau die Artefaktklasse' $tag -- lab/regelwerk/modul-08-agentenrollen.md; done`
liefert **eine** Zeile (`v5.12.0:…:1`) und für `v3.5.2` keine; dasselbe mit *meistens kein Skill*
(lokaler Kurs-Klon).

**Was die Reparatur kostete, ist gemessen.** Im vendored Ausschnitt ändert `v5.3.0` → `v5.3.1`
**7 Dateien um +14/−13 Zeilen**
(`git diff --shortstat v5.3.0 v5.3.1 -- lab/regelwerk lab/templates`, lokaler Kurs-Klon);
die Dateizahl bleibt **26 + 25 = 51**, auch am Zielstand
(`for d in lab/regelwerk lab/templates; do git ls-tree -r --name-only v5.12.0 -- $d | wc -l; done`
→ **26 25**). **Keine Messung dieses Plans bricht bis zum Zielstand** — nachgewiesen an ihren zwei
Trägern, nicht durch Wiederholung: `modul-07-carveouts.md`, Träger der Zitat-Probe aus §6 von
[slice-081](done/slice-081-baum-tauschen-pin-ziehen.md), ist zwischen `v5.3.0` und `v5.12.0`
byte-gleich, `modul-15-observability.md`, Träger der Kanten-Messung aus §2, zwischen `v5.3.1`
und `v5.12.0` (`git diff --name-only v5.3.0 v5.12.0 -- lab/regelwerk/modul-07-carveouts.md`
und `git diff --name-only v5.3.1 v5.12.0 -- lab/regelwerk/modul-15-observability.md` → beide
leer). `modul-08-agentenrollen.md` wächst dagegen weiter — **6** Hunks von `v5.3.1` zum Zielstand
(`git diff v5.3.1 v5.12.0 -- lab/regelwerk/modul-08-agentenrollen.md | grep -c '^@@'`); was davon
den Adaptions-Durchgang trifft, entscheidet [slice-082](open/slice-082-adaptions-durchgang.md).

Der Sprung ist **strukturell, nicht additiv**. Zwischen gepinnt und Ziel liegen **20** Releases mit
zwei Major-Bumps über drei Major-Serien
(`git tag --sort=v:refname | awk '/^v3\.5\.2$/{f=1;next} f{print} /^v5\.12\.0$/{exit}' | wc -l`,
lokaler Kurs-Klon); das Regelwerk wächst von 21 auf 26 Dateien, aber die Rechnung ist `−3 +8` —
je ein `comm` über die Basenamen beider Tags, `-23` für die entfallenen, `-13` für die neuen
(`comm -23 <(git ls-tree -r --name-only v3.5.2 -- lab/regelwerk | xargs -n1 basename | sort) <(git ls-tree -r --name-only v5.12.0 -- lab/regelwerk | xargs -n1 basename | sort) | wc -l`
→ **3**, mit `-13` → **8**):

- `grundlagen-konventionen.md` **zerfällt in sechs** Grundlagen-Dateien (`-begriffe`,
  `-bootstrap`, `-harness-dateien`, `-referenz-richtung`, `-source-precedence`, `-traceability`),
- `modul-03-lastenheft` → `modul-03-spec`, `modul-04-architektur-adrs` → `modul-04-adrs`,
- die Templates wachsen 21 → 25 (neu: `observations`, `reconciliation`, `welle-results`, und ein
  Eintrags-Template für den Adaptions-Block).

Damit verschwinden Pfade, auf die dieses Repo aus **lebenden** Artefakten zeigt. **Ihre Menge
wandert mit jedem Schnitt und ist kein Erwartungswert**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2): am 2026-08-27 sind es **56** Nennungen in **14** Dateien, die schwersten
[`harness/conventions.md`](../../../harness/conventions.md#mr-000--baseline-aussage) (14) und
[`spec/spezifikation.md`](../../../spec/spezifikation.md#5-metriken-und-tracing-felder) (13).
Gemessen mit
`git grep -o "\.harness/baseline/v3\.5\.2/[^ )]*" -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`,
für die Nennungen mit `| wc -l`, für die Dateien mit `| cut -d: -f1 | sort -u | wc -l`, für die
Aufschlüsselung mit `| cut -d: -f1 | sort | uniq -c | sort -rn` (Zeitdokumente ausgenommen — sie
bleiben stehen, §6).

**Welche Regelwerks-Fassung diese Migration regiert, entscheidet nicht dieser Plan.** Es
entscheidet [ADR-0018](../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 1; dort
stehen die Wahl, ihre Begründung und ihre vier Grenzen. **Plan-Sache ist allein die Folge:** die
drei Durchgänge des Closure-Kriteriums (§3) und der Zuschnitt der Slices 082–084 sind aus
Eigenschaften der dort gewählten Prozedur gebaut und haben außerhalb von ihr keine Quelle. Fällt
die Wahl anders aus, fällt dieser Schnitt mit ihr.

**Was daraus für diesen Plan folgt:** bis der Baum getauscht ist, bleibt `v3.5.2` die adoptierte
Baseline und für jede Konformitäts-Frage maßgeblich
([ADR-0018](../adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2) — dieser Plan
entsteht darum per `cp` aus deren `welle.template.md`, nicht aus der neuen.

## 2. Trigger (Welle startet)

- **`make baseline-freshness` meldet VERALTET** — der Sensor ist in jedem Lauf seiner sichtbaren
  Historie rot, der älteste vom 2026-07-24; am 2026-08-27 meldet er `gepinnt: v3.5.2` und
  `latest: v5.12.0` (`make baseline-freshness`; die `latest`-Angabe **wandert** mit jedem Release
  und ist kein Erwartungswert,
  [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Der Auslöser ist damit beobachtbar und real eingetreten, nicht angesetzt. Was er
  auslöst, ist ein Review, kein Nachziehen des Zielstands (§1).
- **Auf [welle-09](welle-09-modul-15-konformitaet.md) wartet diese Welle nicht, und der Grund
  steht an der Stelle der Kante statt nur im Drift-Log.** Die Kante schützte die Messlatte jener
  Welle: ihr Closure-Kriterium misst gegen `modul-15-observability.md`, und ein Tausch während der
  Welle zöge ihr diesen Text unter den Füßen weg. **Drei Messungen nehmen dem Schutz seinen
  Gegenstand** (lokaler Kurs-Klon):

  1. **Das Delta trifft zwei der vier Regelblöcke.**
     `git diff --shortstat v3.5.2 v5.12.0 -- lab/regelwerk/modul-15-observability.md` → **+7/−2**
     in **einem** Hunk (dasselbe Kommando ohne `--shortstat`, `| grep -c '^@@'` → **1**). Je Block
     gehalten, liegt die Änderung in §Span-/Audit-Attribut-Regeln und §Token-Attributions-Regeln;
     §Cache-Counter-Regeln und §Doku-Konsistenz-Drift-Regeln sind byte-gleich:
     `for b in 'Span-/Audit-Attribut-Regeln' 'Token-Attributions-Regeln' 'Cache-Counter-Regeln' 'Doku-Konsistenz-Drift-Regeln'; do for t in v3.5.2 v5.12.0; do git show "$t:lab/regelwerk/modul-15-observability.md" | awk -v h="### $b" '$0==h{f=1;next} /^### /{f=0} f' > "/tmp/blk-$t"; done; printf '%s: ' "$b"; diff -q /tmp/blk-v3.5.2 /tmp/blk-v5.12.0 >/dev/null && echo gleich || echo GEAENDERT; done`
     → vier Zeilen, die ersten beiden `GEAENDERT`, die letzten beiden `gleich`.
  2. **Keine Zelle der 4 × 2-Matrix jener Welle bewegt sich durch den Tausch** — je geändertem
     Block gezeigt, nicht über die Zahl behauptet. **Block 2** verliert die feste
     Rollen-Aufzählung zugunsten von *„attribuiert wird damit auf **Kontexte**, nicht auf
     Personen; die Rollen sind die aus Modul 8, festgelegt durch das gestartete
     Rollen-Artefakt"*; kein lebendes Artefakt dieses Repos zitiert die entfallene Aufzählung
     (`git grep -c 'Planner · Architect · Implementer · Reviewer · Verifier' -- ':!.harness/baseline' ':!docs/reviews' ':!docs/plan/planning/done'`
     → kein Treffer), es hängt also keine Messung an ihr, und der Ersatz benennt genau den Träger,
     den jene Welle gebaut hat. **Block 1** bekommt eine **neue** Regel: *„Der Emissions-Pfad ist
     Repo-Entscheidung (Exporter, Collector, Sampling, Aufbewahrung): Mitzunehmen ist das
     **Schema**, nicht das Setup."* Sie bestätigt kein Ergebnis jener Welle — sie stützt deren
     **Grenze**: §6 dort stellt den Observability-*Stack* out-of-scope und trug das bislang allein
     auf [`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) Festlegung 4.
  3. **Der Ziel-Text ist bereits gemessene Grundlage einer angenommenen Entscheidung dieses
     Repos.** [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) aus der
     geschlossenen [welle-12](done/welle-12-erfassungsschicht-emittieren.md) liest **beide**
     geänderten Stellen verbatim
     (`grep -c 'Emissions-Pfad ist Repo-Entscheidung\|Kontexte, nicht auf Personen' docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`
     → **2**) und löst sie auf: die Block-1-Regel als Scheinwiderspruch, den
     [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) auf Rang 1
     der Source Precedence entscheidet, die Block-2-Fassung als **Stütze** ihrer Festlegung 3.
     Der Teil des neuen Textes, der dieses Repo berührt, ist damit **vor** dem Tausch gelesen und
     entschieden — nicht durch ihn. Eine Kante, die jene Welle vor genau diesem Text schützen
     soll, schützt sie vor einem Stand, gegen den hier bereits entschieden wurde.

  **Was die Kante nicht war: eine Aussage über den Fortschritt jener Welle.** Deren Closure hängt
  an drei Mitgliedern ohne Datei (`ls docs/plan/planning/*/ | grep -cE '^slice-(061|063|064)-'`
  → **0**), und keines von ihnen berührt den vendored Baum. Der Tausch nimmt ihr nichts und gibt
  ihr nichts; er läuft an ihr vorbei. Was er ihr **schuldet** — eine benannte Mess-Grundlage —
  steht in [welle-09](welle-09-modul-15-konformitaet.md) §1.

## 3. Closure-Trigger (Welle schließt)

Die Welle schließt, wenn **die drei Durchgänge der Ziel-Prozedur je einen Beleg tragen** — nicht,
wenn der Pin sitzt. Der Pin ist eine Zeile; die Durchgänge sind der Gegenstand.

- **Alle Slices dieser Welle in `done/`.**
- **Der Pin ist vollzogen:** `.harness/baseline/v5.12.0/` ist das **einzige** `<tag>`-Verzeichnis
  ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache):
  ein Tag zur Zeit), `make baseline-verify` grün über **51** statt 42 Dateien (26 Regelwerk + 25
  Templates) — heute meldet dasselbe Ziel `v3.5.2 OK — 42 Dateien` (`make baseline-verify`), die
  51 sind der Bestand des Ziel-Tags (§1).
- **Durchgang 1 — Adaptionen:** **jeder** Eintrag des Adaptions-Blocks trägt genau einen der fünf
  Ausgänge mit Beleg, **und jeder Auflösungs-Trigger ist abgefragt** (*„Ein Trigger, den niemand
  abfragt, ist kein Wächter."*). Vollständigkeit heißt hier **Inventar gegen Abdeckung**, nicht
  „die auffälligen" — dieselbe Lücke, an der die Roadmap zwei kuratierte Listen führt. **Die
  Bezugsmenge ist ein Kommando, keine Zahl**, weil sie mit jedem neuen Eintrag wandert
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2): `grep -c '^### MR-' harness/conventions.md` → am 2026-08-27 **27**, davon mit
  Auflösungs-Trigger `grep -c '^- \*\*Auflösungs-Trigger' harness/conventions.md` → **26**.
- **Durchgang 2 — Form:** die Referenz-Form ist gegen die alte gehalten und die Pflichtfelder der
  neuen Gliederung stehen in den Singleton-Artefakten.
- **Durchgang 3 — Stichprobe gegen den Bestand:** ein Abschnitt **ohne** Delta ist geprüft und
  sein Ausgang verbucht. Er läuft unabhängig vom Ergebnis der Tag-Frage.
- **`make gates` grün — und zwar ohne offenen Carveout auf einem Gate dieser Welle.** Der Zusatz
  ist nicht kosmetisch: zwischen [slice-081](done/slice-081-baum-tauschen-pin-ziehen.md) und
  [slice-130](in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) trägt
  [`CO-004`](../carveouts/CO-004-emitter-klassifikation-offen.md) zwei rote bats-Fälle auf einem
  Trigger. Ein Welle-Grün, das diesen Carveout mitzählte, hieße *„grün, außer wo wir nicht
  hinsehen"*. Die Welle schließt erst, wenn er in `carveouts/done/` liegt.
- **Die drei Sensoren außerhalb der Gates** — `make smoke`, `make full-smoke`, `make mutate`. Die
  ersten beiden gehören hier ins Kriterium, weil der Tag der **Emissions-Kanal** ist
  (`internal/fetch/baseline.go` `DefaultTag`): ein frisch gebootstrapptes Zielrepo zieht genau
  diesen Baum ([`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)). **Beim
  dritten ist der Grund ein anderer, und er ist der Grund, warum er hier steht und nicht bloß
  mitläuft:** `make mutate` fährt vor der ersten Mutation je Sensor-Modus einen Grün-Vorlauf und
  bricht den Worker fail-closed ab, wenn der Modus schon ohne Mutation rot ist. Solange einer der
  beiden anderen rot ist, misst er deshalb **nichts** — nicht weniger, sondern null Fälle —, und
  ein grüner Lauf hier ist zugleich der Beleg, dass diese Kopplung wieder aufgelöst ist. Verlangt
  ist er darum in der Form, die er selbst ausgibt: `mutate: N ok, 0 Befund(e)` **mit** der
  Vollständigkeits-Zeile über **allen** Fall-Dateien, nicht ein Exit-Code.
- **Closure-Notiz `welle-10-results.md`** mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Der Zustand jedes Slice ist sein Lifecycle-Verzeichnis, hier nicht gespiegelt.

Die Reihenfolge ist tragend: **080 entscheidet, 081 vollzieht, 133, 130, 131 und 132 räumen ab, was
der Vollzug an gebrochenen Zusagen und unbeantworteten Fragen hinterlässt, 082–084 sind die drei
Durchgänge der Prozedur, 085 zieht die emittierte Ebene nach.** 080 liegt vor 081, weil der Tausch
sonst an einer Frage vorbeiläuft, die er selbst aufwirft. **133 liegt vor 130**, weil dessen
Nachweis über beide Ursachen zugleich läuft und ohne 133 unter keiner korrekten Ausführung grün
werden kann.

| Slice | Titel | Bezug |
|---|---|---|
| slice-080 | Ein Verweis in die vendored Baseline überlebt den Tag-Wechsel | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| slice-081 | Baum tauschen, Pin ziehen, Verweise nachziehen | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| slice-133 | Der emittierte Baum trägt keine Platzhalter-Links | [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) |
| slice-130 | Der Emitter entscheidet über jedes neue Template | [`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3) |
| slice-131 | Eine Präsens-Aussage über die Baseline ist gegen den gepinnten Stand gemessen | [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) |
| slice-132 | Der Adaptions-Block trägt seinen datierten Beleg ohne totes Ziel | [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) |
| slice-082 | Adaptions-Durchgang: jeder Eintrag bekommt seinen Ausgang | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-083 | Form-Vergleich: Pflichtfelder und umbenannte Sektionen | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-136 | Die Roadmap trägt die Ziel-Form (Singleton, den 083 nicht führt) | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-084 | Stichprobe gegen den Bestand, nicht gegen das Delta | [`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) |
| slice-085 | Die emittierte Ebene zieht nach | [`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren) |

**136 ist der fünfte Nachzügler, und sein Grund ist ein anderer als der der vier davor: nicht eine
übersehene Eingabe, sondern ein übersehenes Artefakt.** Durchgang 2 oben verlangt die Pflichtfelder
der neuen Gliederung **in den Singleton-Artefakten**; die extensionale Menge in
[slice-083](open/slice-083-form-vergleich-pflichtfelder.md) §2 führt die Roadmap nicht
(`grep -c 'roadmap' docs/plan/planning/open/slice-083-form-vergleich-pflichtfelder.md` → **0**),
obwohl sie eines ist und ihre Ziel-Form im getauschten Baum den ersten Abschnitt umbenannt hat. Der
Slice hängt an keinem anderen der Welle und läuft in beliebiger Reihenfolge; er trägt eine
Vorbedingung außerhalb — [slice-125](open/slice-125-roadmap-und-verzeichnis-stimmen-ueberein.md)
misst gegen die Sektion, die er umbenennt.

**130, 131, 132 und 133 sind beim Schnitt der Welle nicht vorgesehen gewesen, und der Grund gehört
an diese Stelle statt in eine Fußnote: der Plan hat den vendored Baum als Verweis-**Ziel**
inventarisiert, nicht als **Eingabe** — und den Verweis als Adresse, nicht als Träger einer
Aussage.** `make test` liest den Inhalt des Baums (`test/courseset-fixture.bats`), die Verweise auf
ihn tragen neben der Adresse ein Zitat oder eine daraus gezogene Zahl, und einer von ihnen ist nur
über den **abgelösten** Stand wahr und darf deshalb gar nicht gezogen werden. Nichts davon fällt
unter „Pin" oder „Verweis nachziehen". Alle vier hängen am getauschten Baum und an nichts sonst.
Sie stehen vor 082, weil ein Adaptions-Durchgang über einem Bestand, dessen Zahlen noch gegen den
alten Baum gemessen sind, seine eigene Grundlage nicht kennt.

**Die Lücke hat eine dritte Ebene, und sie ist die teuerste: der Baum ist auch die Eingabe des
Emissions-Kanals.** `internal/fetch/baseline.go` `DefaultTag` zeigt nach dem Tausch auf den neuen
Satz, und damit wechselt ohne eine Zeile in `internal/emit/`, was ein frisch gebootstrapptes
Zielrepo bekommt. Gemessen: `make smoke` meldet am Stand `26aec2c`
`23 Datei(en) geprüft, 10 Befund(e)`, über dem Vor-Tausch-Stand
(`T=$(mktemp -d); git archive c6cc56f | tar -x -C "$T"; cd "$T" && make smoke`)
`19 Datei(en) geprüft, 0 Befund(e)` bei Exit 0 — **keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Gebrochen sind
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) und
[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3), beide Rang 1.
**Das trägt kein Carveout, sondern zwei Slices:** eine Rang-1-Zusage wird nicht ausgenommen — ein
Carveout steht in keinem Rang und dürfte nach `grundlagen-source-precedence.md` §Vollständigkeit
verweisen, ausführen und ausbuchstabieren, aber nichts festlegen —, und der Trichter aus
`modul-07-carveouts.md` §Werkzeug-Wahl führt bei dieser Häufung ohnehin nicht auf Carveout. **8**
Befunde hat [slice-133](done/slice-133-emittierter-baum-ohne-platzhalter-links.md)
weggenommen (Platzhalter-Links, sieben davon in drei schon vorher emittierten Singletons), **2**
trägt [slice-130](in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) (sie lösen sich mit
der Klassen-Entscheidung). Die Aufteilung ist je Befund an seiner Vorlagen-Zeile erhoben, nicht
über die Summe geschlossen; die Tabelle steht in slice-133 §1. **Der Schnitt rechnete mit sieben
und zwei bis drei**, weil er nach Ursachen teilte; die gebaute Neutralisierung trägt die
Platzhalter-**Form** und kennt keine Namen, also nahm sie einen Befund der zweiten Ursache mit.
Dasselbe Kommando über dem Stand `66459c7`: `make smoke` → `23 Datei(en) geprüft, 2 Befund(e)`,
gleicher Nenner. Der **Entscheidungs**-Gegenstand von slice-130 ist unberührt — die Klassen-Weichen
sind über die ganze slice-133-Kette unangetastet
(`git diff 3ea5ae2^ 66459c7 -- internal/emit/templates.go | grep -cE '^[+-][^+-].*func (inScope|isRecurring|isDerivativeIndex)'`
→ **0**).

**Zwei Carveouts halten den Zwischenzustand der Gates sichtbar statt still:**
[`CO-004`](../carveouts/CO-004-emitter-klassifikation-offen.md) (Gate `test`, Folge-Slice 130) und
[`CO-005`](../carveouts/CO-005-adaptions-block-datierter-beleg.md) (Gate `docs-check`, Folge-Slice
132). Beide sind extensional geschlossen, und **keiner** von beiden deckt den Vertragsbruch oben —
`CO-004` grenzt das in seinem Kopf ausdrücklich ab. Der zweite hat **keine**
Gate-Konfiguration, weil das Modul `links` am Pin `v0.65.0` keine Referenz-Ausnahme kennt; dort
bleibt der Gate rot, und der Carveout ist der einzige Träger der Begründung. Beim ersten ist die
Nennung im Gate-Output **möglich, aber nicht gesetzt** (`git grep -c 'CO-004' -- test/ .d-check.yml
Makefile` → kein Treffer) — ein offener Posten, den slice-081 §2 DoD (4) als solchen führt.

**Die Reihenfolge hat einen Preis, und er heißt: ab 081 ist die CI kein Signal — für drei ihrer
Jobs bis 130, für den vierten bis 132.** Der Workflow fährt vier Jobs
(`awk '/^jobs:/{f=1;next} f&&/^  [a-z][a-z-]*:$/{n++} END{print n}' .github/workflows/ci.yml` →
am 2026-08-29 **4**: `gates`, `smoke`, `full-smoke`, `mutate`), und alle vier hängen an **einer**
Ursachenkette. Wer welchen zurückgibt, ist keine Schätzung, sondern steht in den Trägern: `smoke`
und `full-smoke` an [slice-133](done/slice-133-emittierter-baum-ohne-platzhalter-links.md) **und**
[slice-130](in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) (8 + 2 Befunde); `mutate`
an denselben zwei, weil sein Grün-Vorlauf genau diese Modi fährt; `make gates` an
[slice-130](in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md)
([`CO-004`](../carveouts/CO-004-emitter-klassifikation-offen.md)) **und**
[slice-132](open/slice-132-adaptions-block-ohne-totes-ziel.md)
([`CO-005`](../carveouts/CO-005-adaptions-block-datierter-beleg.md)). Der teuerste Posten dabei
ist nicht das Rot, sondern der blinde Fleck darunter: `mutate` läuft in diesem Fenster über
**null** Fälle, die Haltbarkeits-Prüfung der **gelisteten** Wächter aus
[`AGENTS.md`](../../../AGENTS.md) §3.6 findet also nicht statt.

**Mit [slice-133](done/slice-133-emittierter-baum-ohne-platzhalter-links.md) ist keiner der
vier Jobs zurück, und dieser Satz steht hier, weil sein Abschluss sonst falsch gelesen wird.**
`make full-smoke` am Stand `66459c7` endet mit Exit **2** und
`full-smoke: FEHLER — make gates im emittierten Repo ist NICHT Exit 0 (LH-FA-01 Happy-Path
verletzt)`. Der Lauf erreicht das Zielrepo — die Netz-Bedingung war erfüllt, der Treiber ordnet
den Fehlschlag selbst zu (`AUSGANG BAUM`) — und fällt dort an genau **einem** Teil-Ziel
(`make full-smoke 2>&1 | grep -cE '^make\[1\]: \*\*\* \['` → **1**, `docs-check`), mit den zwei
Befunden, die [slice-130](in-progress/slice-130-emitter-entscheidet-jedes-neue-template.md) trägt.
**[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) ist damit weiterhin
gebrochen; die Closure dieser Welle darf slice-133 nicht als Beleg für den Happy Path führen** —
eingelöst wird er erst mit slice-130 DoD (3), das den gemeinsamen Nachweis über beide Ursachen
führt.

**Ein Zwischenziel, das `main` früher grün zurückgibt, wird hier nicht geschnitten — und der
Grund ist der Rang, nicht der Aufwand.** Der kürzeste Weg zu einem grünen `make gates` liefe über
[slice-132](open/slice-132-adaptions-block-ohne-totes-ziel.md) **vor** 133 und 130: er ist von
beiden unabhängig (§5). Er brächte aber ein grünes Gate, während der Bruch von
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)/[`LH-FA-02`](../../../spec/lastenheft.md#lh-fa-02--zweiklassige-template-ablage-f3)
— Rang 1 — länger offen stünde, und genau das Grün wäre die Farbe, die den Bruch nicht sieht (er
liegt außerhalb der Gates, deshalb steht er in §3 eigens). Kürzer als *133 → 130* ist kein Weg zu
haben: die Kante ist tragend, nicht ordnend (§5). Die Reihenfolge bleibt damit, wie sie oben
steht; **was sich ändert, ist nur, dass der Preis benannt ist statt unterstellt.**

**Wer im roten Fenster liest, ist damit ebenfalls benannt:** nicht die CI — sie ist rot, egal was
sich bewegt —, sondern der **DoD-Verify** von 133 und 130, der beide Läufe je Befund hält, und
das Closure-Kriterium dieser Welle (§3). Ein Regressions-Signal aus dem Fenster gibt es nicht;
das ist eine Lücke mit Träger, keine mit Sensor.

**130 ist nicht der aus [slice-085](open/slice-085-emittierte-ebene-zieht-nach.md)
herausgeschnittene Teil.** Dessen Plan führt `internal/emit/templates/commands/`, die übrigen
emittierten Vorlagen und den Reviewer-Skill — den **Text** der emittierten Artefakte. Welche
Vorlagen überhaupt emittiert werden, steht dort an keiner Stelle; 130 füllt eine Lücke, statt 085
zu teilen. 085 bleibt unverändert und behält seinen Trigger.

**Die vierte und fünfte Eigenschaft der Ziel-Prozedur sind auf 082/083 verteilt, nicht
zusammengelegt** — der Adaptions-Durchgang fragt *„regelt die neue Fassung das, wofür dieser
Eintrag angelegt wurde?"*, der Form-Vergleich fragt *„hat sich die Gestalt der Artefakte
geändert?"*. Zwei Fragen, zwei Review-Sitzungen. 082 läuft zuerst, weil ein Eintrag, der
gegenstandslos wird, kein neues Pflichtfeld mehr braucht.

## 5. Abhängigkeiten

- **Wird blockiert von:** nichts. Die Kante aus
  [welle-09](welle-09-modul-15-konformitaet.md) besteht nicht mehr; die Messungen, die sie
  aufheben, stehen in §2. Der Trigger dieser Welle ist damit allein der Freshness-Sensor, und der
  ist real eingetreten.
- **Blockiert:** jeden Slice **außerhalb** dieser Welle, der den vendored Baum zitiert. **Wer das
  ist, sagt ein Kommando, keine Liste hier** — die Menge wandert mit jedem Schnitt, und eine
  Aufzählung im Plan altert zwischen Schnitt und Ausführung
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2):
  `git grep -l '\.harness/baseline/v3\.5\.2/' -- docs/plan/planning/open docs/plan/planning/next`.
  Von den Treffern ist **einer** ausdrücklich nicht gemeint:
  [slice-083](open/slice-083-form-vergleich-pflichtfelder.md) liegt **in** dieser Welle und nennt
  den alten Tag als Tree-Operanden der Vor-Tausch-Seite, nicht als Zeiger auf einen Baum, der
  stehen bleiben müsste. Der Rest ist vor dieser Welle fällig oder auf den neuen Tag zu ziehen —
  entschieden wird das je Treffer beim Lauf, nicht hier.
- **Innerhalb der Welle:** 080 → 081 → {133 → 130, 131, 132} → {082 → 083, 084} → 085. 084 hängt
  nur am getauschten Baum, nicht am Adaptions-Durchgang: sein Gegenstand ist der Bestand, nicht die
  Änderung. 131 und 132 hängen ebenso nur am getauschten Baum und sind von den übrigen unabhängig;
  ihre Reihenfolge entscheidet, wer das WIP-Limit zuerst bekommt, nicht der Plan. **133 → 130 ist
  dagegen tragend, nicht ordnend:** DoD (3) von 130 führt den Nachweis über **beide** Ursachen des
  Vertragsbruchs, und über einem Baum, in dem die Platzhalter-Befunde noch stehen, kann er
  auch bei vier richtig entschiedenen Vorlagen nicht grün werden. 132 verlangt zusätzlich einen
  **Architect**-Lauf: seine Liefer-Punkte liegen in dessen Artefakten.

## 6. Out-of-Scope für diese Welle

- **Die Verzeichnis-Form des Adaptions-Blocks** — ein Eintrag je Datei in einem
  `conventions`-Verzeichnis, aufgelöste in dessen `done/`. Die Ziel-Baseline nennt sie
  **Default**, die Form selbst aber ausdrücklich **Wahl**; die Einzeldatei bleibt damit konform
  und schuldet keinen `MR`-Eintrag. Der Grund, den die Baseline für den Default nennt, trifft hier
  trotzdem zu — `wc -l harness/conventions.md` → am 2026-08-27 **1402** Zeilen, die jeder
  Agentenlauf liest, mit wachsendem Anteil aufgelöster Einträge; die Zahl **wächst** mit jedem
  Eintrag und ist kein Erwartungswert
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Das ist ein Roadmap-Kandidat mit eigenem Trigger, keine
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

