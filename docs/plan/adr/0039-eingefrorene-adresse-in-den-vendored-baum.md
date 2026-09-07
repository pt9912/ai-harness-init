# ADR-0039: Die tote Adresse in den vendored Baum bekommt kein Ventil, sondern ein Instrument

**Status:** Proposed

**Datum:** 2026-09-07

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) (ihre zweite Architect-Folgepflicht
verlangt genau diese Entscheidung; sie ist mit der Annahme jener ADR fällig geworden und dort
ausdrücklich nicht getroffen),
[ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) (Festlegung 2 trägt den
Adress-Nachzug im lebenden Bestand; Festlegung 5 hat eine Ausnahme für Ziele **unter** dem
Baseline-Verzeichnis schon einmal geprüft und verworfen — diese Entscheidung hält jene Prüfung
gegen einen um zwei Größenordnungen gewachsenen Bestand),
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die vier `ignore-refs`-Paare; jedes extensional geschlossen, jedes mit der Klausel, dass ein
weiteres Paar eine eigene ADR braucht — diese Entscheidung erweitert keine dieser Grenzen),
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (die eine Datei-Ausnahme und
ihr Argument, dass ein unbehebbarer Befund dazu erzieht, Rot zu überlesen),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Form jedes Belegs in diesem Dokument),
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
(Setzung 4 — ein Tag zur Zeit; sie ist der gemessene Grund, warum die Koexistenz-Option heute
nicht offensteht),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl neben ihrem Kommando),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
(jede Baseline-Aussage nennt ihren Tag),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate behauptet nur, was es prüft — hier gegen die Versuchung, eine Ausnahme als Lösung
auszugeben),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie entscheidet über den Prüfumfang eines Gates und
über die Form einer Adresse, nicht über den Inhalt eines Spec-Dokuments.

**Kopplung:** [`.d-check.yml`](../../../.d-check.yml) bleibt von dieser Entscheidung **unberührt** —
das ist ihr Inhalt, nicht ihre Auslassung. Die Folgepflicht unten benennt die eine Stelle, an der
sie später eine Zeile bekommt, und die Hard Rule, die dafür zu schärfen ist.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

Der Baum-Tausch `v6.0.0` → `v6.5.0` hat den vendored Pfad bewegt. Der lebende Bestand ist
nachgezogen ([ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2). Was
bleibt, sind Adressen in Artefakten, die niemand mehr anfassen darf.

### Der Bestand — 36 Adressen, 16 Dateien, drei Bäume

```sh
PS=( 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' )
git grep -oE '\]\([^)]*\.harness/baseline/v6\.0\.0/' -- "${PS[@]}" | wc -l   # 36 Adressen
git grep -lE '\]\([^)]*\.harness/baseline/v6\.0\.0/' -- "${PS[@]}" | wc -l   # 16 Dateien
```

**Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die 36 verteilen sich auf 32 in `docs/reviews/`, 3 in einem geschlossenen Slice unter
`docs/plan/planning/done/` und 1 in einer `observation.md` des Beobachtungs-Registers — dieselbe
Zahl meldet `make docs-check` als `target-missing`.

**Alle drei Bäume frieren ein, und die Ziel-Fassung nennt sie namentlich.** `v6.5.0`,
`grundlagen-harness-dateien.md`, §harness/README.md als Einstiegspunkt: *„Einfrierend sind die
**Zeitdokumente** — Review-Report, Closure-Notiz, Archiv-Stub, `Accepted`-ADR, geschlossener
Slice"*. Für die `observation.md` sagt es die Vorlage
`.harness/baseline/v6.5.0/templates/docs/plan/planning/observation.template.md` in ihrem
Bedienhinweis: *„observation.md          unveraenderlich ab Anlage"*. Keine der 36 ist reparierbar.

### Warum sie überhaupt entstehen durften — eine Lücke in §3.11

[`AGENTS.md`](../../../AGENTS.md) §3.11 verlangt die Kennung statt der Adresse für alles, *was der
Prozess bewegt*, und nimmt im selben Absatz aus: *„ein Verzeichnis, ein Glob, eine stehende Ablage
und eine Datei, die ihren Lifecycle bereits verlassen hat, sind ortsfest und bleiben als Pfad
zulässig."* Der vendored Baum **ist** ein Verzeichnis. Nach dem Wortlaut der Hard Rule war jede der
36 Adressen zulässig, als sie geschrieben wurde.

Die Ziel-Fassung führt genau diesen Fall als dritte Form derselben Regel — `v6.5.0`,
`grundlagen-harness-dateien.md`, §harness/README.md als Einstiegspunkt:

> Eine Stelle der vendored Baseline heißt Tag **und** Pfad in Inline-Code, nicht als Link. Der
> Vendoring-Pfad ist `<tag>`-gescopt, alte und neue Form liegen beim Bump also eine Weile
> nebeneinander — der Link bricht nicht sofort, sondern wenn das alte Verzeichnis fällt. Genau das
> macht ihn gefährlich: Er bricht nicht beim Bump, sondern später, in einem Artefakt, das niemand
> mehr anfasst.

Die Lücke ist damit nicht theoretisch: Sie ist der Erzeuger dieses Befund-Bestands, und sie
produziert ihn bei **jedem** Bump neu.

### Die Instrumenten-Lage, gemessen statt angenommen

Gemessen am gepinnten d-check (`DCHECK_IMAGE`/`DCHECK_DIGEST` in
[`d-check.mk`](../../../d-check.mk)) über einem synthetischen Sonden-Repo aus zwei eingefrorenen
und einem lebenden Artefakt mit derselben toten Adresse:

| Sonde | Form | Ergebnis |
|---|---|---|
| A | `in: "docs/reviews/**"`, exakter `refs`-Wert | Glob in `in:` **greift** — der lebende Befund bleibt |
| B | `in:` und `refs:` je Glob | beide **greifen** — der lebende Befund bleibt |
| C | `links: {exempt-paths: […]}` | `Exit 2` — `field exempt-paths not found` |
| D | Top-Level `exempt-paths` | `Exit 2` — `field exempt-paths not found` |
| F | Top-Level `ignore-refs` als blanke Glob-Liste (die Tombstone-Form von `codepaths`) | `Exit 2` — `cannot unmarshal !!str into configyaml.rawIgnoreRef` |
| G | zwei exakte `in`/`refs`-Paare | greift; der lebende Befund bleibt |

**Das Werkzeug kann mehr, als dieses Repo nutzt — aber der repo-eigene Wächter kann es nicht.**
`test/ignore-refs-restbreite.bats` läuft in `make gates` und hält jedes Paar gegen den Bestand:
`in:` muss eine **existierende Datei** sein (sonst `Quelldatei fehlt`) und ein Paar darf **höchstens
einen** Markdown-Link decken (sonst `$n aufloesende Links, hoechstens 1 ist gedeckt`). Die Sonden A,
B und F fallen damit an ihm, nicht am Werkzeug.

Und die exakte Paar-Form skaliert hier nicht:

```sh
# je (Datei, Ziel) die Zahl der aufloesenden Links, aus dem docs-check-Lauf
#   -> 24 eindeutige Paare, davon 6 mit mehr als einem Link (Maximum 4)
```

**6 der 24 Paare überschreiten die Kappung des Wächters.** Die Route Sonde G ist damit nicht
teuer, sondern **versperrt**: Sie verlangte zusätzlich eine Senkung an dem Wächter, dessen einziger
Zweck es ist, eine Ausnahme daran zu hindern, mehr stumm zu schalten als sie deklariert.

### Was `scan.ignore` kostet — und dass es nicht einmal reicht

```sh
git ls-files 'docs/reviews/*.md' | wc -l                                              # 299 Dateien
git grep -oE '\]\((\.\./)+[^)]+\)' -- 'docs/reviews/*.md' | grep -vc 'baseline/'       # 3887 repo-interne Links
```

**Keine Erwartungswerte.** Ein `scan.ignore` auf `docs/reviews/**` nähme 299 Dateien aus **allen**
Modulen und gäbe 3887 geprüfte repo-interne Verweise auf — und es macht das Gate trotzdem nicht
grün: Die 3 Befunde im geschlossenen Slice und der eine in der `observation.md` liegen außerhalb.
Grün würde erst ein `scan.ignore` über `docs/reviews/**`, `docs/plan/planning/done/**` und
`docs/plan/planning/observations/**`, also über dem halben Planungs- und dem ganzen Review-Korpus.
Das ist kein Ventil mehr, sondern das Abschalten des Gates über seinem größten Prüfbereich.

Dazu kommt eine benannte Kopplung: [`harness/README.md`](../../../harness/README.md) begründet den
Suchraum der Verweis-Vorprüfung von `archive-welle` damit, dass *„`docs/reviews/**` darin steht,
denn `links`/`anchors` prüfen die Zeitdokumente wie jede andere Datei"*. Ein `scan.ignore` machte
diesen Satz falsch.

### Die vierte Option — den alten Baum behalten — steht heute nicht offen

Die Ziel-Fassung sieht die Koexistenz vor (`v6.5.0`, `modul-02-harness-bootstrap.md`,
§Freshness-Audit der vendored Baseline (Schritt 2): *„Das alte Verzeichnis fällt erst, wenn der
Review durch ist."*), und dieser Sprung wird von ihr regiert
([ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md)). Zwei gemessene Gründe machen sie
trotzdem unzugänglich:

```sh
ls -d .harness/baseline/*/ | wc -l                                   # 1 — genau ein Tag im Baum
grep -c 'mehr als ein <tag>-Verzeichnis' harness/tools/baseline-verify.sh   # 1 — die Sperre
```

`make baseline-verify` läuft **in** `make gates` und bricht fail-closed ab, sobald ein zweites
`<tag>`-Verzeichnis liegt — so verlangt es
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 4 (*ein Tag zur Zeit*), und der SessionStart-Injektor trägt dieselbe Sperre. Den alten Baum
zurückzulegen tauschte 39 `target-missing` gegen ein rotes `baseline-verify`.

**Und selbst ohne die Sperre wäre es keine Lösung, sondern ein Aufschub:** Die 36 Adressen sterben
an dem Tag, an dem der Baum fällt — die Koexistenz verschiebt das Datum, nicht das Ereignis.

**Was hier trotzdem festzuhalten ist, weil es niemandem sonst gehört:** Der Baum ist gefallen,
bevor der Adaptions-Durchgang gegen `v6.5.0` geschnitten war, und die regierende Prozedur knüpft
sein Fallen an genau diesen Review. Ob
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 4 gegenüber der Koexistenz-Regel Bestand hat, ist einer der fünf Ausgänge des
Adaptions-Durchgangs und wird **hier nicht entschieden**.

### Acht Module tragen den Knopf, die zwei ohne ihn brauchen ihn am dringendsten

Das Startgerüst des gepinnten d-check (`--print-config`) führt `exempt-paths` unter `ids`,
`matrix`, `codepaths`, `diagrams`, `versions`, `structure`, `workflows` und `reviews`. `links` hat
eine Options-Sektion (`resolve-from`) **ohne** diesen Knopf, `anchors` hat gar keine. Genau diese
zwei Module sind es, die eine eingefrorene Adresse rot färben.

Der Befund ist damit keine Werkzeug-**Grenze**, sondern eine Werkzeug-**Lücke**: d-check ist ein
Nachbar-Repo desselben Auftraggebers, und eine fehlende Modul-Fähigkeit ist dort eine Anforderung,
kein Naturgesetz. `codepaths` hat den Knopf, und dieses Repo nutzt ihn für **denselben Baum** —
`exempt-paths: ["docs/reviews/**"]` mit der Begründung *„Zeitdokumente `docs/reviews/**` frieren
den Stand ihres Review-Laufs ein"*. Für die Inline-Code-Adresse ist die Frage also längst
entschieden; für die Markdown-Link-Adresse fehlt nur das Gefäß.

## Entscheidung

**Zwei Festlegungen.**

**1. Für diese 36 Adressen wird kein Referenz-Ventil eröffnet, und keine der vier bestehenden
Aufnahme-Grenzen wird erweitert.** Weder ein fünftes `ignore-refs`-Paar noch eine Verbreiterung
eines bestehenden noch ein `scan.ignore`-Eintrag. Tragend sind drei Messungen, nicht eine Haltung:
die Paar-Route ist am repo-eigenen Breiten-Wächter versperrt (6 von 24 Paaren überschreiten seine
Kappung), die `scan.ignore`-Route kostet 3887 Prüfungen über 299 Dateien **und** macht das Gate
nicht grün, und die Koexistenz-Route ist von
[`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
Setzung 4 versperrt und wäre ein Aufschub.

**2. Der fehlende Knopf ist der Gegenstand, nicht die Ausnahme: `links` und `anchors` bekommen
`exempt-paths`, wie es acht andere Module des Werkzeugs führen.** Bis er vorliegt, bleibt
`make docs-check` wegen dieser 36 Adressen rot, und dieses Rot ist **benannt, begrenzt und
gemessen** — es ist keine offene Frage, sondern eine wartende Zeile Konfiguration.

**Was diese Festlegung nicht tut.**

- **Kein `Supersedes`.** [ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
  [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) und
  [ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md) bleiben
  für ihr Paar unverändert wahr. Diese Entscheidung fügt keines hinzu und nimmt keines weg.
- **Sie ist keine Gate-Senkung, und darum steht sie hier trotzdem.**
  [`AGENTS.md`](../../../AGENTS.md) §3.5 verlangt für eine Senkung dieses Gefäß; eine begründete
  **Verweigerung** verlangt es nicht. Sie bekommt es, weil eine unaufgeschriebene Verweigerung bei
  jedem Bump neu verhandelt wird — dreimal in vier Sprüngen ist dieselbe Frage schon gestellt
  worden ([ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 5 hat sie
  einmal beantwortet, als der Bestand bei einer Adresse lag).
- **Sie entscheidet nichts über den vendored Baum.** Ob Koexistenz gilt und ob
  [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 4 Bestand hat, gehört in den Adaptions-Durchgang gegen `v6.5.0`.
- **Sie schreibt die Hard Rule nicht.** Die Schärfung von §3.11 ist eine Verschärfung und braucht
  nach [`AGENTS.md`](../../../AGENTS.md) §3.5 kein ADR-Gefäß; sie steht unten als Folgepflicht,
  damit sie nach dem Review dieser Entscheidung landet und nicht vor ihm.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — 24 exakte `ignore-refs`-Paare über 16 `in:`-Dateien | die einzige Form, die der Breiten-Wächter liest; macht das Gate sofort grün | 6 der 24 Paare decken mehr als einen Link und färben den Wächter rot — die Route verlangt also **zwei** gestapelte Senkungen. Dazu 16 permanente Konfigurationszeilen, die je ein Zeitdokument benennen, und vier ADR-Grenzen, die je *„eigene ADR"* fordern und hier gebündelt übergangen würden — genau das Versagensmuster, gegen das [`AGENTS.md`](../../../AGENTS.md) §3.11 geschrieben ist |
| B — `ignore-refs` mit Glob in `in:` und `refs:` | am Werkzeug gemessen wirksam (Sonden A/B), und der lebende Bestand bliebe rot — die Eigenschaft, auf die es ankommt | fällt am repo-eigenen Breiten-Wächter (`Quelldatei fehlt`), der `in:` als existierende Datei liest. Die Route setzte voraus, dass genau der Sensor umgebaut wird, der Ausnahmen ehrlich hält |
| C — `scan.ignore` auf die drei Bäume | eine Zeile je Baum, kein Wächter-Umbau | 299 Review-Dateien und 3887 repo-interne Link-Prüfungen fallen weg; die Begründung des `archive-welle`-Suchraums in [`harness/README.md`](../../../harness/README.md) wird falsch; und auf `docs/reviews/**` allein reicht es nicht — grün würde erst der Ausschluss des halben Planungs-Korpus |
| D — den alten Baum stehen lassen | die regierende Fassung sieht die Koexistenz vor, und der Baum ist vor dem Adaptions-Durchgang gefallen | `make baseline-verify` bricht fail-closed bei zwei `<tag>`-Verzeichnissen ab ([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache) Setzung 4), der SessionStart-Injektor ebenso: 39 `target-missing` gegen ein rotes Gate getauscht. Und selbst ohne die Sperre nur ein Aufschub — die Adressen sterben, wenn der Baum fällt. Die Frage, ob Setzung 4 Bestand hat, gehört in den Adaptions-Durchgang |
| E — das eingefrorene Artefakt doch anfassen | der Befund verschwindet an der Quelle | dann ist es kein Zeitdokument mehr ([`AGENTS.md`](../../../AGENTS.md) §3.4). Die Ziel-Fassung führt diesen Weg als einen von zweien und benennt seinen Preis: *„es doch anfassen — dann ist es kein Zeitdokument mehr"* |
| **F — gewählt: kein Ventil, sondern der fehlende Knopf als Anforderung, plus die Schärfung von §3.11 gegen die Neuentstehung** | trifft die Ursache zweimal — den Bestand über ein Instrument, das acht Module schon haben, und die Neuentstehung über die Regel, die sie erlaubt hat. Kostet keine ADR-Grenze, keinen Wächter-Umbau und keine Prüffläche. Nach der Schärfung wächst die Klasse nicht mehr: heute zeigt genau **1** eingefrorene Adresse in den *lebenden* Baum (`git grep -oE '\]\([^)]*\.harness/baseline/v6\.5\.0/' -- 'docs/reviews/**' 'docs/plan/planning/done/**' 'docs/plan/planning/observations/**' \| wc -l`, kein Erwartungswert) | `make docs-check` bleibt bis zum Knopf rot, und Rot ohne Handlungsmöglichkeit ist genau der Schaden, den [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) für **eine** Datei vermeiden wollte — hier für 36. Der Stop-Hook lässt keinen Abschluss zu, und CI ist blind, solange das gilt. Die Entscheidung nimmt diesen Preis bewusst, weil jede Alternative ihn woanders teurer bezahlt |

## Konsequenzen

- **Positiv:** Vier ADR-Grenzen bleiben unangetastet, und der Breiten-Wächter behält seine Zähne.
  Keine der 36 Adressen wird stumm geschaltet, ohne dass jemand sie einzeln entschieden hätte.
- **Positiv:** Der lebende Bestand bleibt vollständig geprüft. Die Sonden A/B/G zeigen, dass jede
  Ventil-Form die tote Adresse **im lebenden Artefakt** hätte mit stummschalten können, wenn sie
  breiter geschnitten worden wäre; hier ist sie es nicht.
- **Positiv:** Die Ursache ist benannt, nicht nur das Symptom. §3.11 hat eine Lücke, die bei jedem
  Bump denselben Bestand neu erzeugt; die Folgepflicht schließt sie.
- **Negativ, und es ist der Preis dieser Entscheidung:** `make docs-check` und damit `make gates`
  bleiben wegen dieser 36 Adressen rot. Der Stop-Hook lässt keinen Abschluss zu, und ein roter
  CI-Lauf sagt nichts mehr über neu eingebrachte Fehler. Wer in dieser Phase arbeitet, liest die
  Befundliste, statt dem Exit-Code zu trauen — dieselbe Lage wie in der roten Phase, die dieses
  Repo schon einmal durchgetragen hat.
- **Negativ:** Die Entscheidung ist auf ein Werkzeug angewiesen, das dieses Repo nicht baut. Liegt
  der Knopf nicht vor, bleibt sie ohne Vollzug — der erste Re-Evaluierungs-Trigger fängt das ab.
- **Negativ /
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6):**
  **Kein Sensor** hält Status und Adress-Form zusammen; dieselbe Lücke, die
  [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) für sich benennt. Träger
  bleiben der Accept-Übergang und der Lauf, der den Bump plant.
- **Folgepflicht (Architect), fällig mit der Annahme dieser ADR:**
  [`AGENTS.md`](../../../AGENTS.md) §3.11 bekommt die vendored-Baseline-Adresse als ausdrücklichen
  Fall — die Ausnahme *„ein Verzeichnis … ist ortsfest"* gilt nicht für ein `<tag>`-gescoptes
  Vendoring-Verzeichnis, das mit dem Bump ersetzt wird. Verschärfung, kein ADR-Gefäß
  ([`AGENTS.md`](../../../AGENTS.md) §3.5).
- **Folgepflicht (Architect), fällig mit dem Knopf:** ein `exempt-paths` unter `links` und
  `anchors` in [`.d-check.yml`](../../../.d-check.yml) auf die drei einfrierenden Bäume. Das ist
  eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 und bekommt ihre eigene ADR — diese hier
  entscheidet, dass sie **nicht** als `ignore-refs`-Paar gebaut wird, nicht, dass sie ohne Gefäß
  auskommt.
- **Folgepflicht (Planner/Implementer), unabhängig von dieser Entscheidung:** die drei toten
  Adressen in
  [`slice-114`](../planning/open/slice-114-jede-aussage-hat-einen-abschnitt.md) liegen in einem
  **lebenden** Slice-Plan und sind nach
  [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 2 nachzuziehen; sie
  gehören nicht zu den 36.
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut: keine** — und die Kandidaten sind einzeln geprüft, statt die Lücke zu verschweigen.

| Kandidat | Warum er die Regel nicht misst |
|---|---|
| `make docs-check` | meldet die 36 Adressen — genau das ist der Anlass. Dass sie **unbehebbar** sind, sieht es nicht: `links` kennt keinen Status |
| `test/ignore-refs-restbreite.bats` | misst die Breite **vorhandener** Paare. Dass keines hinzukommt, misst es ausdrücklich nicht — der Wächter sagt das über sich selbst |
| `make baseline-verify` | belegt, dass genau ein Tag vendored ist. Über Adressen in Artefakten sagt es nichts |
| `make comment-claims` | hat keine Markdown-Datei im Prüfbereich |

**Nicht mechanisierbar mit dem heutigen Werkzeug:** die Verbindung *Artefakt ist eingefroren* ↔
*seine Adresse darf nicht mehr nachgezogen werden*. Kein Modul aus `modules:` der
[`.d-check.yml`](../../../.d-check.yml) liest einen Status.

## Re-Evaluierungs-Trigger

- **Wenn `links`/`anchors` ein `exempt-paths` tragen** *(beobachtbar am `--print-config` des dann
  gepinnten d-check)*: Die zweite Folgepflicht wird fällig, und die Senkung bekommt ihre eigene ADR.
- **Wenn der nächste Baum-Tausch ansteht** *(feedforward, kein Gate meldet ihn)*: Die Zahl der
  eingefrorenen Adressen in den dann **alten** Baum ist vor dem Tausch zu messen — dieselbe Abfrage
  wie oben mit dem alten Tag. Ist sie größer als heute, hat die §3.11-Schärfung nicht getragen.
- **Wenn der Adaptions-Durchgang gegen `v6.5.0`
  [`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)
  Setzung 4 aufhebt** *(beobachtbar an einem Nachfolge-Eintrag im Adaptions-Block)*: Dann liegen
  zwei Bäume nebeneinander, die Adressen des alten leben wieder, und diese Entscheidung ist gegen
  die neue Lage neu zu halten — sie wird nicht gegenstandslos, sondern verschiebt sich auf den Tag,
  an dem der alte Baum fällt.
- **Wenn ein Ventil dieser Klasse ohne diese Entscheidung entsteht** *(beobachtbar an einem fünften
  Paar oder einem neuen `scan.ignore`-Eintrag in [`.d-check.yml`](../../../.d-check.yml))*: Dann ist
  Festlegung 1 gebrochen, und der Vorgang gehört zurück in dieses Gefäß.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-07 | **Proposed** | Architect-Lauf nach dem Adress-Nachzug im Adaptions-Block; löst die zweite Architect-Folgepflicht von [ADR-0038](0038-ziel-fassung-regiert-den-sprung-v650.md) ein |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0039` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
