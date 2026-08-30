# Slice slice-132: Der Adaptions-Block trägt seinen datierten Beleg ohne totes Ziel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-10](../welle-10-re-baseline.md) — der Befund entsteht durch den Tausch und hält
ihr Closure-Kriterium *„`make gates` grün"* auf. Ihre Closure-Bedingung ist von dieser DoD
verschieden.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate, das strukturell rot bleibt, ist die Kehrseite des halluzinierten: es meldet, ohne dass
jemand handeln kann),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) (Festlegung 4 — *Adresse entfällt,
Text bleibt* — ist für **Zeitdokumente** geschrieben; dass ein append-only-Eintrag in einer
lebenden Datei keines ist, hält §1 fest),
[`ADR-0023`](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) (Festlegung 1 hält
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) gegen den Zielstand neu),
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (ihre Feststellung,
es gebe kein `links.ignore-refs`, ist gegen d-check `v0.62.0` gemessen und für den heutigen Pin
**nachgemessen**, nicht übernommen — §1),
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(der Eintrag, der den Beleg trägt),
[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
(der Eintrag, der ihn überholt und den Befund als dauerhaft ausweist),
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
(die Form, die den Rumpf des überholten Eintrags einfriert),
[`AGENTS.md`](../../../../AGENTS.md) §3.8 (den Adaptions-Block schreibt der Architect — dieser
Slice ist geschnitten, nicht ausgeführt vom Planner).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt ein Norm-Artefakt und eine Gate-Config-Frage,
keine Spec-Stelle.

**Verantwortlich:** Architect (pt9912) — der Liefergegenstand ist Norm-Text im Adaptions-Block,
und den schreibt nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 der Architect. Das Feld weicht
damit von der Default-Besetzung ab, die Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine nennt (*„den Rolleninhaber der Implementer-Rolle"*); Begründung und
Commit-Zuschnitt über beide beteiligten Rollen stehen in §3.

**Autor:** Planner. **Datum:** 2026-08-28.

---

## 1. Ziel


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Ein Eintrag des Adaptions-Blocks darf einen Beleg tragen, der auf einen abgelösten
Baseline-Stand datiert ist, ohne dass `make docs-check` dauerhaft rot bleibt.**

### Der Befund: ein Link, der bewusst nicht gezogen wurde, und ein Ventil, das ihn stummschaltet

[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
Punkt 2 hält fest, dass die Baseline die dritte Rolle *Implementation* nennt, während dieses Repo
den Bezeichner `implementer` führt. **Der Satz ist nur über den abgelösten Stand wahr** — gemessen
an derselben Zeile beider Bäume:

```
git show b902b60^:.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md | grep 'participant I as'
grep 'participant I as' .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md
```

→ `participant I as Implementation` gegen `participant I as Implementer`. Der Tag-Tausch zöge
den Link auf eine Quelle, die das Gegenteil der Aussage sagt: aus einem toten Link würde ein
falsches Zitat — genau die Verwandlung, die
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) in ihrer Option C verwirft. Der
Eintrag steht zugleich unter der Append-only-Regel des gepinnten Stands
(`grundlagen-harness-dateien.md` §harness/conventions.md als Konventionsspeicher:
*„Einträge werden nie überschrieben"*), sein **Text** ist also nicht verhandelbar.

**Die drei naheliegenden Auswege sind gemessen, nicht vermutet** — alle drei gegen den heutigen
Pin `v0.65.0`, nicht gegen den Stand, unter dem
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) entschieden hat.
**Der erste trägt**, und das ist gegen den Pin gemessen und mit zwei roten Gegenproben belegt:

| Ausweg | Messung | Ergebnis |
|---|---|---|
| **Top-Level `ignore-refs`** mit `in`/`refs`/`keep` | Sonde in [`.d-check.yml`](../../../../.d-check.yml): `in: "harness/conventions.md"`, `refs: [".harness/baseline/v3.5.2/**"]`, ein `make docs-check`, Sonde zurückgenommen | **trägt** — `468 Datei(en) geprüft, 0 Befund(e)` gegen `468 … 1 Befund(e)` ohne Sonde. **Die Dateizahl bleibt 468**: das Ventil sitzt auf der Referenz-Achse, nicht auf der Datei-Achse. Beide Skopen sind an einer roten Gegenprobe belegt — mit `in: "AGENTS.md"` und mit `refs: [".harness/baseline/v9.9.9/**"]` kehrt der Befund je zurück |
| Zeilen-Ventil `<!-- d-check:ignore -->` | Sonde in einer eigenen Plandatei: zwei gebrochene Links, einer mit Marker im echten HTML-Kommentar, ein `make docs-check`, Sonde zurückgenommen | **deckt `links` nicht** — beide Zeilen als `target-missing` gemeldet |
| `scan.ignore` auf die Datei | Config-Kommentar in [`.d-check.yml`](../../../../.d-check.yml): *„prunt den Abstieg"* | wirkt **datei-weit** — nähme den ganzen Konventionsspeicher aus dem Prüfbereich, mit allen Einträgen und deren Links; das ist eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und tauscht einen sichtbaren Befund gegen einen blinden Fleck |

**Das Ventil ist ein Release älter als der Pin, und der Name, unter dem man es sucht, ist nicht
der, unter dem es steht.** Der d-check-CHANGELOG führt es unter `[0.49.0] — 2026-07-18`:
*„das bisher modul-lokale `codepaths.ignore-refs` wird zur **querschnittlichen**
Top-Level-Fähigkeit, die `links`, `anchors` und `codepaths` gemeinsam honorieren"*, mit den
Feldern `in` (Glob auf die Quelldatei), `refs` (Globs auf das aufgelöste Ziel) und `keep`
(Ausnahmen, reihenfolge-unabhängig); der modul-lokale Schlüssel bleibt Alias
(`grep -n 'ignore-refs' /Development/d-check/CHANGELOG.md`, lokaler Klon — `0.49.0` liegt vor dem
Pin `v0.65.0`). **Wer unter `links:` nach `ignore-refs` sucht, findet nichts und schließt falsch:**
`--print-config` gibt eine kommentierte Beispiel-Config aus, keine Schema-Liste — Abwesenheit
darin ist keine Abwesenheit der Option. Dieselbe Klasse wie eine Trefferliste, die als
Vollständigkeitsaussage gelesen wird.

**Was das Ventil ist und was es nicht ist.** Es nimmt keine Datei aus dem Prüfbereich — die
Dateizahl bleibt bei 468 —, sondern schaltet **benannte Referenzen aus benannten Quelldateien**
stumm. Das ist trotzdem eine Lockerung auf der Referenz-Achse und damit eine Senkung nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5, die ihr eigenes Gefäß braucht; genau das hält der
Config-Kommentar zum bestehenden `scan.ignore`-Eintrag für seinen Fall schon fest
(*„Jeder weitere Eintrag ist eine neue Senkung nach AGENTS.md 3.5 und braucht seine eigene ADR"*).
Der Unterschied zu `scan.ignore` ist die **Reichweite**: dort fielen sämtliche Verweise der Datei
mit, hier fällt, was `in` **und** `refs` gemeinsam treffen — an zwei roten Gegenproben belegt.

### Drei Kandidaten — einer ist seit dem 2026-08-28 verstellt, einer ist gemessen verfügbar

**Die Entscheidung liegt bereits in einem Architect-Artefakt, und sie widerspricht dem Carveout.**
[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
steht seit `d72e6dd` (2026-08-28 19:01) im Block,
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) entstand mit `26aec2c`
(19:20) — beide Zeitstempel liefert `git log --format='%h %ci' -1 <ref>`. Der Carveout führt den
Befund als **temporär mit Auflösungs-Trigger**, der Eintrag als **dauerhaft**. Was der Eintrag
sagt, trifft beide Kandidaten unten:

- **Der Verweis ist eine datierte Aussage, kein Navigations-Zeiger.**
  [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  ordnet ihn wörtlich so ein und nimmt ihn damit aus
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 heraus, deren *„der
  Bump zieht ihn nach"* nur für Navigations-Zeiger gilt.
- **Festlegung 4 bleibt bei den Zeitdokumenten.**
  [`ADR-0023`](../../adr/0023-verweis-beschluss-traegt-ueber-den-sprung.md) Festlegung 1 hält
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegungen 1 bis 4 gegen den
  Zielstand `v5.12.0` neu und fasst die vierte als *„ein Verweis in einem Zeitdokument verliert
  seine Adresse, nicht seinen Text"*. Ein Inline-Eintrag in einer lebenden Datei ist keines —
  genau die Kollision, die
  [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  als *„unveränderliche Region in einer änderbaren Datei"* benennt und die
  [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) nach demselben Eintrag nicht kennt.
- **Der Rumpf ist eingefroren, und die Kopf-Marke steht schon.**
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1: *„der Rumpf bleibt wörtlich, kein Satz wird nachgezogen, keine Adresse getauscht"*.
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  trägt seit `c17a473` die Marke **ÜBERHOLT** auf Punkt 2 — und in genau diesem Punkt sitzt der
  Befund.
- **Die Folge steht dort ausgeschrieben:** *„Diese eine Zeile bleibt ein `target-missing`-Befund
  von `make docs-check` — in einem lebenden Artefakt, dauerhaft, ohne dass jemand sie richtig
  beheben kann."*

**Damit ist (a) verstellt, und DoD (1) ist zur Hälfte beantwortet.** Offen ist nicht mehr,
*welche* der zwei Festlegungen den Eintrag regiert — **keine von beiden**, solange der Block
inline läuft —, sondern ob dieses Repo bei dieser Antwort bleibt und was daraus für
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) folgt. Diese zweite Hälfte
gehört weiter dem Architect: eine Feststellung dieser Art bindet nur in einem seiner Artefakte,
und
[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
entscheidet über
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben),
nicht über den Carveout.

**Der Widerspruch zwischen den beiden löst sich mit (c) auf, statt entschieden zu werden — die
zwei Sätze sprechen über verschiedene Gegenstände.**
[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
sagt, der **Link** bleibe tot und dürfe nicht repariert werden; das bleibt unter (c) Wort für
Wort wahr, denn das Ventil ändert an
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
kein Zeichen. [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) sagt, der
**Befund** sei temporär; das wird unter (c) wahr. Was in
[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
nicht mehr trägt, ist der Halbsatz *„ohne dass jemand sie richtig beheben kann"* — er ist eine
Aussage über den Werkzeugstand, gegen dieselbe Lücke gemessen wie die Tabellenzeile oben.
**Rollenfrei wird DoD (2) dadurch nicht:** (c) ist eine Senkung nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 und braucht eine ADR. Der Slice hängt weiter an einem
Architect-Lauf — die Frage, an der er hängt, wechselt nur ihren Gegenstand, von *welche
Festlegung regiert den Eintrag* zu *ist diese Senkung zulässig und wie ist sie geschnitten*.

**(c) Das geschnittene Referenz-Ventil.** Ein Top-Level-`ignore-refs`-Eintrag in
[`.d-check.yml`](../../../../.d-check.yml), auf Quelldatei **und** Ziel-Glob geschnitten, nimmt
genau diese Referenz aus der Prüfung und lässt alle anderen Verweise derselben Datei stehen — die
Messung samt beider roter Gegenproben steht oben. Er beantwortet die Frage von (a) und (b)
**nicht**, er entkoppelt sie vom Gate: der Eintrag bleibt unverändert, der Umzug bleibt möglich,
und der Befund hört auf, ein dauerhaft rotes Gate zu erzeugen. Ob er gesetzt wird, wie eng `refs`
geschnitten ist und ob der Eintrag die `CO-005`-Kennung im Gate-Output trägt, wie
`modul-07-carveouts.md` §Geltungs-Konfiguration es verlangt, **entscheidet dieser Plan nicht** —
das ist die ADR aus DoD (1).

**(a) Die Adresse entfällt, der Text bleibt.** Der Markdown-Link wird zur reinen Nennung — genau
die Form, die [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 vorsieht:
*„der sichtbare Text bleibt Zeichen für Zeichen stehen, die tag-gepinnte Adresse entfällt … Kein
Satz ändert sich, keine Aussage wird nachgezogen."* Das wäre eine Zeile. **Die Zuordnung ist
dabei keine Formalie:** Festlegung 4 spricht von **Zeitdokumenten**, und derselbe ADR erlaubt in
Festlegung 2 den lokalen Pfad in `harness/conventions.md` ausdrücklich als
**Navigations-Zeiger** eines *lebenden* Artefakts. Ein append-only-Eintrag ist beides zugleich:
er steht in einer lebenden Datei und ist selbst eingefroren. Welche der zwei Festlegungen ihn
regiert, sagt die ADR nicht — der Adaptions-Block sagt es: **keine**. Wer (a) trotzdem fährt, hebt
eine Setzung auf; das geht nach
[`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
Setzung 1 nicht per Edit am Eintrag, sondern nur über einen Nachfolge-Eintrag.

**(b) Die Verzeichnis-Form.** Der adoptierte Stand `v5.12.0` nennt sie **Default** — *„Ein Eintrag
je Datei … ist der Auflösungs-Trigger eingetreten, wandert die Datei nach `conventions/done/`"* —, und dort
löst sich die Frage von selbst: der aufgelöste Eintrag liegt in einem `done/`-Verzeichnis und ist
damit **konstruktiv** ein Zeitdokument. Die Vorlage dafür liegt seit dem Tausch vendored
(`.harness/baseline/v5.12.0/templates/harness/conventions/MR-NNN-titel.template.md`), der Umzug
wäre also regelkonform per `cp`
([`MR-008`](../../../../harness/conventions.md#mr-008--ausfüll-templates-referenziert-statt-kopiert)).

**Was für (b) spricht, ist gemessen.** Der Konventionsspeicher misst am 2026-08-30 **2 125**
Zeilen bei **34** Einträgen (`wc -l harness/conventions.md`,
`grep -c '^### MR-' harness/conventions.md`); das Nachbar-Repo d-check fährt die Verzeichnis-Form
mit **32** Einträgen und einem Index von **184** Zeilen
(`wc -l /Development/d-check/harness/conventions.md`,
`ls /Development/d-check/harness/conventions/*.md | wc -l`, lokaler Klon). **Alle vier Zahlen
wandern mit ihrem Bestand und sind keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Die Reichweite ist gemessen — und sie ist nicht der Preis, für den sie gehalten wird.**
`git grep -oE 'conventions\.md#mr-[a-z0-9-]+' -- '*.md' | wc -l` zählt am 2026-08-30 **1 797**
Verweise, davon **632** in lebenden Artefakten (dieselbe Suche mit
`':!docs/reviews/**' ':!docs/plan/planning/done/**' ':!.harness/baseline/**'`) und **0** außerhalb
von Markdown (mit `-- ':!*.md'`). **Diese zwei wandern schneller als die vier oben, und das ist
gemessen statt vermutet:** innerhalb eines einzigen Planner-Laufs am 2026-08-28 lieferte dasselbe
Kommando nacheinander 1 585, 1 602, 1 607 und 1 608 — jeder geschnittene Slice, jeder
Review-Report und jeder parallele Lauf einer anderen Rolle bewegt sie, und `git grep` liest den
Arbeitsbaum. Wer sie zitiert, zitiert einen Zeitpunkt; wer sie prüft, fährt das Kommando neu
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1 verlangt die Messung über **diesem** Baum, Setzung 2 verbietet, sie als Erwartungswert
zu lesen).

**Auf einen neuen Pfad zöge der Umzug sie nicht.** Alle Treffer der Suche oben tragen die Form
`conventions.md#mr-<slug>` — Datei **plus Anker** —, und in der Verzeichnis-Form bleibt die Datei
als **Index** stehen. Das Nachbar-Repo hält seine Index-Zeilen genau dafür adressierbar:
`grep -c '<a id=' /Development/d-check/harness/conventions.md` → **55** explizite HTML-Anker,
je Zeile der alte lange Slug **und** die Kurzform `mr-NNN`. Dass der gepinnte d-check ein solches
`<a id="…"></a>` als Link-Ziel auflöst, ist unten an einer Sonde gemessen. Was der Umzug kostet,
ist damit eine Index-Zeile je Eintrag, nicht ein Verweis-Nachzug.
[welle-10](../welle-10-re-baseline.md) §6 stellt ihn trotzdem **out-of-scope**, und zwar mit
genau diesem Preis als Begründung — **die Messung ist ein Anlass, jene Grenze neu zu bewerten;
das ist ein Schnitt und kein Vollzug.**

**Eine Vorfrage, die bisher als ungeprüft galt, ist beantwortet.** Ob der Pin einen expliziten
HTML-Anker als Link-Ziel auflöst, hat
[slice-114](../open/slice-114-jede-aussage-hat-einen-abschnitt.md) §1 als offen benannt. Sonde in
einer eigenen Plandatei, danach zurückgenommen: ein Link auf ein `<a id="…"></a>` mit abweichendem
Überschriften-Text meldet **nichts**, ein erfundener Anker in derselben Datei meldet
`anchor-missing`. Der Anker-Mechanismus, mit dem das Nachbar-Repo seine Index-Zeilen adressierbar
hält, trägt also auch hier — die Verweise oben sind kein Ausschlussgrund für (b), sondern eine
Auflage an seine Ausführung.

### Was dieser Slice nicht ist

Er ist **nicht** der Umzug. Er entscheidet, ob der eine Beleg ohne Umzug tragfähig wird, und wenn
nein, übergibt er den Umzug als eigenen Schnitt mit eigenem Trigger — so, wie
[welle-10](../welle-10-re-baseline.md) §6 ihn vorsieht. Und er ist **nicht** der Ort, an dem ein
Planner-Lauf den Adaptions-Block schreibt: die Ausführung gehört dem Architect
([`AGENTS.md`](../../../../AGENTS.md) §3.8).

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Die Frage ist entschieden, und die Entscheidung liegt in einem Artefakt ihrer
      schreibenden Rolle.** Regiert Festlegung 2 oder Festlegung 4 von
      [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) einen append-only-Eintrag in
      einer lebenden Datei?
      [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
      antwortet **keine von beiden** (§1). Der Punkt ist damit nicht erledigt, sondern verlegt: zu
      erreichen ist, dass diese Antwort entweder als die geltende ausgewiesen wird — und dann
      [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) über (c) aufgelöst
      wird statt über den Eintrag — oder dass ein Nachfolge-Eintrag bzw. eine neue ADR anders
      entscheidet. **Fällt die Wahl auf (c), gehört in dasselbe Artefakt die Senkung**: ein
      `ignore-refs`-Eintrag lockert die Prüfung auf der Referenz-Achse und braucht nach
      [`AGENTS.md`](../../../../AGENTS.md) §3.5 eine ADR, samt Geltungsbereich und
      Auflösungs-Trigger. Weil
      [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) *Accepted* und damit
      unveränderlich ist ([`AGENTS.md`](../../../../AGENTS.md) §3.4) und der Block append-only
      läuft
      ([`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
      Setzung 1), ist der Ort in beiden Fällen ein **neues** Artefakt — beides Architect
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8). **Ein Ergebnis, das nur in diesem Plan steht,
      erfüllt den Punkt nicht.**
- [x] **(2) Der Befund ist fort, ohne dass der Prüfbereich geschrumpft ist.** `make docs-check`
      meldet die Zeile nicht mehr, **und die Dateizahl seiner Ausgabe ist dieselbe wie die eines
      zweiten Laufs ohne den neuen Config-Eintrag** — zwei Läufe, ein Vergleich, kein gemerkter
      Wert. Das ist das Maß, nicht ein leerer Config-Diff: ein Referenz-Ventil ändert die Config
      und lässt den Prüfbereich stehen, `scan.ignore` täte das Gegenteil. Gegengeprobt wird darum
      zweifach: `scan.ignore` in [`.d-check.yml`](../../../../.d-check.yml) trägt **keinen** neuen
      Eintrag (`git diff` auf die Config), und ein etwaiger `ignore-refs`-Eintrag trägt ein `in`
      **und** ein `refs`, die beide enger sind als die Datei — je eine rote Gegenprobe wie in §1.
      Ein Grün, das durch Ausblenden des Konventionsspeichers entstünde, verfehlt diesen Punkt
      ausdrücklich. **Rot färbt genau ein Kommando:** `make docs-check`.
- [x] **(3) Der Fall ist als Klasse behandelt, nicht als Einzelstück — und die Klasse wird mit
      dem Kommando erhoben, das sie trifft.** Es sind **zwei** Mengen, nicht eine: die
      **Nennungen** des abgelösten Baums (`grep -c 'v3\.5\.2' harness/conventions.md` → am
      2026-08-30 **14**) und davon die **Markdown-Links** in ihn
      (`grep -cE '\]\([^)]*v3\.5\.2[^)]*\)' harness/conventions.md` → **1**). Nur die zweite färbt
      `docs-check` rot: `codepaths.roots` in [`.d-check.yml`](../../../../.d-check.yml) sind
      `[spec, docs, harness]`, `.harness/…` liegt außerhalb, und der Lauf zeigt es — `468
      Datei(en) geprüft, 1 Befund(e)` bei 14 Nennungen. Beide Zahlen werden beim Lauf neu erhoben,
      nicht von hier übernommen
      ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2). Trifft die zweite Menge genau einen Eintrag, steht **das** dabei — dann ist die
      Klassen-Aussage eine über den Mechanismus und nicht über die Zahl.
- [x] `make gates` grün — **ohne** die Ausnahme aus
      [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md); der Carveout ist damit
      aufgelöst und seine Datei per `git mv` in `carveouts/done/`, die Index-Zeile umgehängt.
- [x] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-/Reconciliation-Register: das Repo führt keines von beiden; das Item entfällt
      mit diesem Grund und wird in §7 notiert, nicht still übergangen.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die
      [welle-10](../welle-10-re-baseline.md)-Closure, nicht dieser Slice.

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/conventions.md`](../../../../harness/conventions.md) | update **durch den Architect** | der Beleg in [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben) Punkt 2; Umfang hängt an der Entscheidung aus DoD (1). Der Planner schneidet, er schreibt nicht ([`AGENTS.md`](../../../../AGENTS.md) §3.8) |
| `docs/plan/adr/` | ggf. neu | eine ADR, falls die Entscheidung aus DoD (1) eine ist; [`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) selbst bleibt byte-gleich ([`AGENTS.md`](../../../../AGENTS.md) §3.4) |
| [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) | **auflösen** (`git mv` nach `done/`) | die Ausnahme fällt mit dem Befund |
| [`.d-check.yml`](../../../../.d-check.yml) | **kein `scan.ignore`-Eintrag**; bei Ausgang (c) ein Top-Level-`ignore-refs`-Eintrag | die Datei-Achse bleibt unberührt — das ist DoD (2) und keine Nebenbedingung. Die Referenz-Achse zu lockern ist eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und wandert mit ihrer ADR in Commit 1, nicht als Config-Beifang in einen anderen |
| Verzeichnis-Form des Adaptions-Blocks (ein Eintrag je Datei) | **nur bei Ausgang (b)**, und dann als eigener Schnitt | [welle-10](../welle-10-re-baseline.md) §6 stellt den Umzug out-of-scope. Sein dort genannter Preis — jede `MR-`Kennung auf einen neuen Pfad — ist in §1 gegen das Nachbar-Repo gemessen und trifft nicht zu: die Datei bleibt als Index, der Anker bleibt. Der Umfang bleibt und ist keine Fracht dieses Slice |

**Der Commit-Zuschnitt folgt aus zwei schreibenden Rollen, nicht aus einer Vorliebe.**
[`AGENTS.md`](../../../../AGENTS.md) §3.8 verlangt für die Änderung am Adaptions-Block einen
**eigenen Commit, der ausschließlich Artefakte derselben schreibenden Rolle berührt** und die
Rolle in seiner Message nennt. Den `git mv` und die Config-Updates weist Baseline-Regelwerk
`modul-07-carveouts.md` §Carveout-Audit-Slice dagegen dem **Implementer** zu und nennt die
Verteilung über drei Rollen *„Absicht, kein Defekt"*. Daraus vier Commits in dieser Reihenfolge:

1. **Architect — Inhalt:** [`harness/conventions.md`](../../../../harness/conventions.md), dazu
   eine neue ADR und deren Zeile im ADR-Index, falls DoD (1) eine erzeugt — der Index gehört
   derselben Rolle
   ([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)).
   Sonst nichts.
2. **Implementer — reiner `git mv`:**
   [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) nach
   `docs/plan/carveouts/done/` ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
3. **Implementer — Inhalt:** die Index-Zeile in `docs/plan/carveouts/README.md` von *Aktiv* auf
   *Aufgelöst*, dazu die eingehenden Verweise, die der Move bricht.
4. **Planner — Closure:** DoD-Haken und §7 in diesem Plan, danach der `git mv` nach `done/` als
   eigener Commit.

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit — der Slice ist ohne die
schreibende Rolle des Adaptions-Blocks nicht ausführbar, und das ist keine Formalie, sondern die
Bedingung aus DoD (1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Entscheidung auf **(b)** fällt.
  Der Umzug ist dann ein eigener Schnitt mit eigenem Trigger
  ([welle-10](../welle-10-re-baseline.md) §6), und dieser Slice zerfällt in *Entscheidung* und
  *Vollzug*. Die Bedingung ist vorab benannt und bleibt ein möglicher Ausgang; eine Aussage
  darüber, welcher der drei Kandidaten der *einzige* Weg zu DoD (2) sei, steht hier nicht — sie
  wäre eine Vollständigkeitsaussage über eine Menge, die §1 gerade um einen Kandidaten korrigiert
  hat.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Entscheidung aus DoD (1) nicht fällt,
  weil sie eine Frage an eine höher rangierte Quelle aufwirft. Dann bleibt
  [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) bestehen und bekommt eine
  nachgetragene *Letzte Prüfung* — kein stilles Weiterlaufen.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien aus **zwei** Läufen von `make docs-check` — einem mit dem
Config-Stand des Abschlusses, einem mit dem Stand davor: **der erste meldet die Zeile nicht
mehr**, und **beide melden dieselbe Dateizahl** — Grün ohne Schrumpfen des Prüfbereichs. Welche
Zahl das ist, sagt der Lauf; verglichen werden die zwei Ausgaben, nicht eine gemerkte Zahl.
Ein leerer Config-Diff ist als zweites Kriterium untauglich: das Referenz-Ventil aus
§1 ändert die Config und lässt den Prüfbereich stehen, `scan.ignore` wäre eine ähnlich kurze
Config-Zeile und nähme die Datei samt allen ihren Verweisen aus der Prüfung. Gemessen wird darum
das, was gemeint ist.
Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus §6 genau ein Ausgang;
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) liegt danach in
`carveouts/done/`.

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Zwei Config-Ventile sehen gleich billig aus und sind es nicht — die Verwechslung ist das
  Risiko.** Ein `scan.ignore`-Eintrag macht den Gate in einer Zeile grün und nimmt dafür jeden
  Eintrag des Blocks samt seinen Links aus dem Prüfbereich
  (`grep -c '^### MR-' harness/conventions.md` → am 2026-08-30 **34**); das ist der Ausweg, den
  DoD (2) ausdrücklich verbietet. Ein Top-Level-`ignore-refs`-Eintrag ist **eine andere Sache**:
  er lässt die Datei im Prüfbereich — die Dateizahl bewegt sich gegenüber einem Lauf ohne ihn
  nicht — und schaltet nur, was `in` und `refs`
  gemeinsam treffen. **Beide sind Senkungen nach [`AGENTS.md`](../../../../AGENTS.md) §3.5** und
  brauchen eine ADR — sie unterscheiden sich in der **Reichweite**, nicht im Gefäß. Wer das
  zusammenwirft, verbietet entweder zu viel oder erlaubt zu viel. — **Ausgang: entfallen.** Die
  Datei-Achse ist unberührt: über die ganze Slice-Spanne ist der Config-Diff rein additiv und
  bewegt die `scan.ignore`-Zeile nicht
  (`git diff --numstat 36e743c HEAD -- .d-check.yml` → **34** hinzugefügte, **0** entfernte
  Zeilen; `git diff 36e743c HEAD -- .d-check.yml | grep -cE '^[+-][[:space:]]*ignore: \['` → **0**).
  Der Prüfbereich steht mit und ohne die Ventile auf derselben Zahl — zwei Läufe über demselben
  Baum, `473 Datei(en) geprüft, 0 Befund(e)` gegen `473 Datei(en) geprüft, 2 Befund(e)`. Beide
  Paare tragen ihre ADR und beide Skopen je eine rote Gegenprobe
  ([`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md)).
- **Die Klasse kann größer sein als ihr heutiger Vertreter.** Trifft die Regel aus DoD (3) mehrere
  Einträge, ist der punktuelle Ausgang (a) nicht mehr angemessen — Modul 7 verweist bei
  **Häufung** ausdrücklich weg vom Einzelfall. — **Ausgang: entfallen** nach dem Kriterium, das
  dieser Punkt selbst setzt: die Erhebung aus DoD (3) findet genau **einen** Eintrag —
  `grep -cE '\]\([^)]*v3\.5\.2[^)]*\)' harness/conventions.md` → **1**, und
  `awk '/^### MR-/{e=$0} /\]\([^)]*v3\.5\.2[^)]*\)/{print e}' harness/conventions.md` nennt
  [`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  als den einen. **Die umgebende Klasse ist trotzdem gewachsen, und das gehört neben den Ausgang:**
  die tote Adresse in einem **eingefrorenen** Artefakt ist innerhalb dieses Slice ein zweites Mal
  aufgetreten, und der Top-Level-Block führt heute zwei Paare statt eines
  (`sed -n '/^ignore-refs:/,/^ids:/p' .d-check.yml | grep -c '^  - in:'` → **2**). Das zweite
  hängt nicht am Adaptions-Block, sondern an einer ADR, und trägt darum seine eigene Entscheidung
  ([`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md)) statt einer Rückführung
  dieses Slice.
- **Die Klasse *„Aussage über ein Werkzeug ist falsch"* ist eingetreten, und ihre Ursache ist
  nicht das Altern.** Die Feststellung *„es gibt kein `links.ignore-refs`"* sucht den
  **modul-lokalen** Schlüssel und schließt aus seiner Abwesenheit im `--print-config` auf die
  fehlende **Fähigkeit**; die Fähigkeit steht seit `[0.49.0]` unter einem Top-Level-Schlüssel
  (§1). Sie trägt
  [`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), die gegen
  `v0.62.0` gemessen hat, und den `scan.ignore`-Kommentar in
  [`.d-check.yml`](../../../../.d-check.yml) (*„der referenz-weite Knopf existiert nicht"*).
  **`0.49.0` ist eine kleinere Versionsnummer als `0.62.0`** — das ist Arithmetik über die
  CHANGELOG-Überschrift, **keine Messung** an jener ADR; ob ihre Folgerung dadurch fällt, ist hier
  nicht geprüft und gehört in einen eigenen Schnitt. — **Ausgang: eingetreten.** §1 trägt die
  korrigierte Messung, und der geltende Stand steht in einem Architect-Artefakt
  ([`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)).
  Der **Fremd**-Bestand — die Kontext-Tabelle von
  [`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md), die für `links`
  und `anchors` in beide Ventil-Spalten *„keines"* schreibt, und der `scan.ignore`-Kommentar in
  [`.d-check.yml`](../../../../.d-check.yml) mit demselben Satz — ist als Posten an die Roadmap
  gegangen und trägt seinen eigenen Schnitt
  ([slice-143](../open/slice-143-datei-weiter-ausschluss-weicht-dem-referenz-ventil.md)).
- **Der Slice hängt an einer Rolle, nicht an einem Kommando.** Ohne Architect-Lauf ist DoD (1)
  nicht erreichbar, und ein Planner- oder Implementer-Lauf, der ihn trotzdem „erledigt", verstößt
  gegen [`AGENTS.md`](../../../../AGENTS.md) §3.8. — **Ausgang: entfallen.** Die Entscheidung liegt
  in vier Architect-Commits, und jeder berührt ausschließlich Artefakte dieser Rolle —
  `git show --pretty=format: --name-only bc8ce8a 16acc05 2417f07 2db2cde | sort -u` nennt
  [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
  [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md), den ADR-Index und
  [`harness/conventions.md`](../../../../harness/conventions.md) und sonst nichts. Der Planner-Lauf
  hat weder den Adaptions-Block noch eine ADR geschrieben.
- **[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) und
  [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  sagen Gegenteiliges über denselben Befund, und der Carveout beziffert seinen Geltungsbereich mit
  einem Kommando, das eine andere Menge zählt.** Der Carveout führt ihn als temporär, der Eintrag
  als dauerhaft. §1 misst, dass die zwei Sätze verschiedene Gegenstände haben — **Link** gegen
  **Befund** — und mit (c) beide wahr sind; damit ist der Widerspruch aufgelöst und nicht
  entschieden. Was bleibt, ist der Halbsatz *„ohne dass jemand sie richtig beheben kann"* in
  einem Architect-Artefakt, das append-only läuft. Der Carveout ist ein Planner-Artefakt
  (Baseline-Regelwerk `modul-07-carveouts.md` §Carveout-Audit-Slice) und wird nicht vom
  Architect-Lauf mitgezogen. — **Ausgang: eingetreten, in beiden Hälften.** Der Halbsatz hat seinen
  Nachfolge-Eintrag bekommen, und ihn hat der Architect geschrieben:
  [`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
  löst ihn auf, [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
  trägt die Kopf-Marke darauf, und der Rumpf ist unangetastet — die Form aus
  [`MR-032`](../../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 1. Die Bezifferung ist ebenfalls behoben: der Geltungsbereich des Carveouts nennt heute
  `grep -cE '\]\([^)]*v3\.5\.2[^)]*\)' harness/conventions.md` → **1** — die Markdown-Links, die
  allein den Befund erzeugen — und weist die Nennungs-Zählung
  (`grep -c 'v3\.5\.2' harness/conventions.md` → **15**) ausdrücklich als die andere, größere Menge
  aus.

## 7. Closure-Notiz


Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner (Modul 5 §Closure- und Lerneintrag-Regeln). **Datum:** 2026-08-30.
**Gegenstand:** `HEAD` = `101b92f`, Arbeitsbaum sauber vor dem Beginn dieser Notiz. Die Kette,
zwölf Commits über vier Rollen-Zuschnitte:
`e592b70` (`open` → `next`, reiner Move) · `799357d` (Link-Abgleich) · `36e743c`
(`next` → `in-progress`, reiner Move) · `8a699fd` (Link-Abgleich) · `bc8ce8a` (Architect:
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) *Proposed* und
[`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand))
· `16acc05` (Architect: *Accepted*) · `29f91b5` (Implementer: erstes `ignore-refs`-Paar und der
Restbreite-Wächter) · `063ba66` (`CO-005` nach `carveouts/done/`, reiner Move) · `11e5328`
(Link-Abgleich, Status, Index-Zeile) · `2417f07` (Architect:
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) *Proposed*) · `2db2cde`
(Architect: *Accepted*) · `101b92f` (Implementer: zweites Paar).

Jede Zahl unten ist **in diesem Lauf** erhoben; die Zahlen aus Architect- und Implementer-Lauf
waren **Eingabe, kein Beleg**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 1). Sie unterscheiden sich von den dort zitierten, und der Grund ist harmlos: zwischen
jenen Läufen und diesem sind Dateien dazugekommen — `469` ist zu `473` geworden.

### DoD-Stand — die drei slice-eigenen Punkte, jeder mit dem Kommando, das ihn hier trägt

**(1) Die Frage ist entschieden, und die Entscheidung liegt in einem Artefakt ihrer schreibenden
Rolle — ERFÜLLT, und die Frage hat unterwegs ihren Gegenstand gewechselt.** Gefragt war, ob
[`ADR-0016`](../../adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung 2 oder Festlegung 4 einen
append-only-Eintrag in einer lebenden Datei regiert. Beantwortet ist stattdessen die Frage, die §1
an ihre Stelle gesetzt hat: *ist die Senkung zulässig und wie ist sie geschnitten*. Drei
Architect-Artefakte tragen die Antwort —
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) (*Accepted*,
autorisiert das erste namentlich geschnittene Paar als **Aufnahme-Grenze**),
[`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
(hebt die zwei Werkzeug-Sätze auf, die den Befund für unvermeidbar erklärt hatten) und
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) (*Accepted*, das zweite Paar plus
die Verweis-Form). Der Rollen-Zuschnitt ist an `git` ablesbar und nicht behauptet:
`git show --pretty=format: --name-only bc8ce8a 16acc05 2417f07 2db2cde | sort -u` liefert genau
vier Pfade — die zwei ADRs, den ADR-Index und
[`harness/conventions.md`](../../../../harness/conventions.md).

**(2) Der Befund ist fort, ohne dass der Prüfbereich geschrumpft ist — ERFÜLLT, an zwei Läufen
über demselben Baum.** Mit den Ventilen: `d-check: 473 Datei(en) geprüft, 0 Befund(e)`. Ohne sie —
Sonde, die den Top-Level-`ignore-refs`-Block entfernt, danach zurückgenommen und die Rücknahme mit
`git status --porcelain` als leer belegt: `d-check: 473 Datei(en) geprüft, 2 Befund(e)`, nämlich

```
docs/plan/adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md:309	../carveouts/CO-005-adaptions-block-datierter-beleg.md	target-missing
harness/conventions.md:1019	../.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md#rollen-sequenz-für-einen-slice	target-missing
```

**Dieselbe erste Zahl in beiden Läufen** — der Prüfbereich hat sich nicht bewegt, und die zwei
stummgeschalteten Referenzen sind namentlich die zwei, die die ADRs nennen. Die Gegenprobe auf der
Datei-Achse: über die ganze Slice-Spanne ist der Config-Diff rein additiv
(`git diff --numstat 36e743c HEAD -- .d-check.yml` → **34** hinzugefügt, **0** entfernt), und die
`scan.ignore`-Zeile ist unberührt
(`git diff 36e743c HEAD -- .d-check.yml | grep -cE '^[+-][[:space:]]*ignore: \['` → **0**).

**Die Restbreite der Ventile misst weder die Config noch `docs-check`, und dafür gibt es einen
Wächter in den Gates.** `test/ignore-refs-restbreite.bats` läuft als `ok 115` und `ok 116` in
`make gates` — *„der Top-Level-ignore-refs-Block wird vollstaendig und in bekannter Form gelesen"*
und *„jede Top-Level-ignore-refs-Ausnahme deckt hoechstens einen Markdown-Link ihrer Quelldatei"*.
Ohne ihn wäre ein zu breites Paar genauso grün wie ein enges.

**(3) Der Fall ist als Klasse behandelt, und die Klasse ist mit dem Kommando erhoben, das sie
trifft — ERFÜLLT; die zwei Zahlen sind hier neu erhoben.** Die **Nennungen** des abgelösten Baums:
`grep -c 'v3\.5\.2' harness/conventions.md` → **15**. Davon die **Markdown-Links** in ihn:
`grep -cE '\]\([^)]*v3\.5\.2[^)]*\)' harness/conventions.md` → **1**. Nur die zweite Menge färbt
`docs-check` rot, und der Sonden-Lauf oben zeigt es: **15** Nennungen, **1** Befund aus
`harness/conventions.md`. Die eine Link-Zeile ist `1019`, und sie sitzt in genau einem Eintrag —
`awk '/^### MR-/{e=$0} /\]\([^)]*v3\.5\.2[^)]*\)/{print e}' harness/conventions.md` nennt
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben).
**Damit ist die Klassen-Aussage eine über den Mechanismus und nicht über die Zahl**, wie der Punkt
es verlangt: `codepaths.roots` sind `[spec, docs, harness]`, `.harness/…` liegt außerhalb, und
darum bleiben vierzehn der fünfzehn Nennungen still. Wer die größere Zahl zum Geltungsbereich
machte, beschriebe eine Menge, die der Gate gar nicht sieht.

### Die vier Standard-Punkte

**`make gates` grün ohne die Ausnahme — ERFÜLLT, und es ist das erste Grün seit
[slice-081](../done/slice-081-baum-tauschen-pin-ziehen.md).** Selbst gefahren, Exit **0**:
`baseline-verify: v5.12.0 OK — 51 Dateien`, `d-check: 473 Datei(en) geprüft, 0 Befund(e)`,
`1..198` mit `grep -c 'not ok'` → **0** bei **198** grünen Fällen,
`comment-claims: 46 Datei(en) geprueft, 0 Befund(e)`,
`span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) liegt in
`carveouts/done/`, sein Status-Kopf sagt *Aufgelöst*, und die Index-Zeile führt ihn dort.

**Doku-Update — kein Trigger.** Über die ganze Slice-Spanne ist kein öffentlicher Vertrag berührt:
`git diff --name-only e592b70^ HEAD -- spec/ | wc -l` → **0**.
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) wird
eingelöst, nicht fortgeschrieben.

**Beobachtungs- und Reconciliation-Register — das Item entfällt, und hier steht der Grund statt
einer stillen Auslassung.** Eine `observations.md` unter `docs/plan/planning/` existiert nicht
(`ls docs/plan/planning/observations.md` → `Datei oder Verzeichnis nicht gefunden`). Der Wegfall
ist keine Nachlässigkeit, sondern der heutige Zustand des Repos, und er hat seit dem 2026-08-29
einen Träger: [slice-137](../done/slice-137-beobachtungs-register-bekommt-seinen-ort.md) legt das
Register an. Das Reconciliation-Register entfällt aus einem anderen und dauerhaften Grund: dieses
Repo hat keinen Brownfield-Bootstrap.

**Die drei Paarungen — nicht hier fällig.** Anker, Folge-Slice und Register prüft die
[welle-10](../welle-10-re-baseline.md)-Closure.

### Was funktionierte

**Die Rollen-Trennung hat den Slice getragen, und zwar an der Stelle, an der sie teuer aussah.**
Der Slice hing per Konstruktion an einem Architect-Lauf (§4), und genau dieser Lauf hat die
Prämisse geprüft, statt sie zu übernehmen: dass es für `links` keine Referenz-Ausnahme gebe, stand
als *„gemessen, nicht vermutet"* in diesem Plan und war falsch. Ein Lauf, der Schnitt und
Ausführung in einer Person hält, hätte die eigene Messung nicht gegengeprüft.

**Der Reparatur-Weg für die tote Adresse in einer eingefrorenen ADR wurde mit Quelle verworfen,
nicht mit Aufwand.** Zwei naheliegende Reparaturen — Adresse nachziehen, Adresse entfallen lassen
— sind je eine Byte-Änderung an einem nach [`AGENTS.md`](../../../../AGENTS.md) §3.4 eingefrorenen
Artefakt, und keine Quelle deckt sie.
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) führt sieben Optionen mit Pro und
Contra, bevor sie die achte wählt.

### Was ging anders als geplant

**Die tragende Prämisse fiel, und sie fiel an ihrem eigenen Instrument.** §1 führte drei Auswege
als gemessen und schloss, für `links` gebe es keine Referenz-Ausnahme. Am gepinnten `v0.65.0` gibt
es sie: `ignore-refs` steht seit d-check `[0.49.0]` als querschnittlicher **Top-Level**-Schlüssel,
den `links`, `anchors` und `codepaths` gemeinsam honorieren. Gesucht worden war der
**modul-lokale** `links.ignore-refs`, und aus seiner Abwesenheit im `--print-config` wurde auf die
fehlende Fähigkeit geschlossen — `--print-config` druckt eine kommentierte Beispiel-Config, keine
Schema-Liste. §1 trägt heute die korrigierte Messung; die Regel dazu steht unten.

**Der Widerspruch zwischen Carveout und Adaptions-Eintrag löste sich auf, statt entschieden zu
werden.**
[`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
spricht über den **Link** — er bleibt tot und wird nicht repariert —,
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) über den **Befund** — er
wurde temporär. Beide Sätze gelten gleichzeitig, und keiner musste zurückgenommen werden; was fiel,
war ein dritter Satz über das Werkzeug.

**Ein Abnahme-Kriterium war richtungsverkehrt und hätte den einzigen tragfähigen Weg
ausgeschlossen.** *„`git diff` auf `.d-check.yml` ist leer"* stand an vier Stellen als Beleg für
*„Prüfbereich nicht geschrumpft"*. Ein Referenz-Ventil **ändert** die Config und lässt den
Prüfbereich stehen; das Kriterium hätte dem Carveout seine eigene Auflösung verboten. Ersetzt ist
es durch den Vergleich zweier Läufe mit gleicher Dateizahl — das Maß, das misst, was gemeint ist.

**Der eigene `git mv` brach eine Adresse in einem eingefrorenen Artefakt.** `063ba66` bewegte
[`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md) nach `carveouts/done/`,
wie Modul 7 es vorschreibt, und traf damit die `Accepted`-Zeile von
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md), die einen
Pfad-Link auf den unaufgelösten Ort trug. Der Implementer-Lauf fand es, zog die Reparatur einmal
mit und nahm sie zurück ([`AGENTS.md`](../../../../AGENTS.md) §3.4/§3.8); der Architect-Lauf
verwarf beide Reparatur-Wege mit Quelle und schrieb
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md).

**Die Folgepflichten 1 und 2 aus
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) sind in diesen Slice gelaufen,
nicht in einen eigenen — und der Planner trägt das mit.** Der Architect hatte einen eigenen
Schnitt vorgeschlagen. Dagegen sprechen zwei Dinge, und sie sind stärker als die Trennschärfe eines
neuen Plans: das WIP-Limit ist **1** und war von diesem Slice belegt, und DoD (2) verlangt
wortwörtlich *„der Befund ist fort"* — bei zwei Befunden ist ein Slice, der einen davon
stehenlässt, nicht fertig, sondern halb. Ein eigener Schnitt hätte den Gegenstand von DoD (2)
geteilt und die Welle-Kante *„`make gates` grün"* an zwei Slices gehängt statt an einen.
**Folgepflicht 3 ist dagegen richtig ausgeschnitten** und steht unten als Folge-Slice: sie liefert
keinen Befund, sondern einen Wächter, und ihr Gegenstand ist der Zuwachs der Klasse, nicht ihr
heutiger Fall.

### Steering-Loop-Einträge

**Eintrag 1 — geschärfte Regel: eine Aussage *„das Werkzeug kann das nicht"* ist eine Behauptung
über eine Menge und braucht ihr Kommando wie eine Zahl.** Ein `--print-config`, eine `--help`, ein
`grep` über eine Doku sind **Trefferlisten**, keine Schema-Auskünfte; belastbar ist die **Sonde am
gepinnten Werkzeug plus rotes Gegenbeispiel**. Der Anlass ist gemessen und nicht erzählt: aus der
Abwesenheit von `links.ignore-refs` im `--print-config` wurde die Abwesenheit der **Fähigkeit**
gefolgert, obwohl sie seit `[0.49.0]` unter einem Top-Level-Schlüssel steht und bis `0.65.0` nicht
entfernt wurde. Diese eine Folgerung trug drei Dinge, die alle enger hätten ausfallen können: den
Carveout [`CO-005`](../../carveouts/done/CO-005-adaptions-block-datierter-beleg.md), die
Entscheidung [`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) samt
ihrem **datei-weiten** `scan.ignore`-Ausschluss, und den Config-Kommentar, der den Satz
weiterträgt. **Adressat: Architect** ([`AGENTS.md`](../../../../AGENTS.md) §3.6/§3.8) — die Regel
ist eine Verschärfung derselben Bauart wie *„keine Zusage ohne rot gesehenes Gegenbeispiel"* und
braucht darum kein ADR, aber einen Lauf der Rolle, die Hard Rules schreibt. **Gezählt, nicht
verkörpert:** dieser Lauf hat keinen Norm-Text geschrieben; das Feld `liegt in` entfällt darum
ersatzlos. Der Termin-Träger für Postens dieser Art ist
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md).

**Eintrag 2 — geschärfte Regel: ein Zeiger auf einen Ort, den der Prozess selbst bewegt, gehört
nicht in ein Artefakt, das unveränderlich wird.** Ein Pfad-Link auf einen **aktiven** Carveout
trägt sein Verfallsdatum eingebaut: Modul 7 schreibt für die Auflösung den `git mv` nach `done/`
vor, und genau das Ereignis, das der Link oft ankündigt, bricht ihn. Wer ihn in eine ADR schreibt,
die danach auf *Accepted* geht, erzeugt einen Befund, den niemand beheben darf. Die Regel ist
**verkörpert** — [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 3:
*„Ein Artefakt, das unveränderlich wird, nennt einen Carveout bei der Kennung, nicht als
Pfad-Link"*, mit dem Accept-Übergang als Träger und der ADR als eigenem ersten Anwendungsfall.
**liegt in `docs/plan/adr/0027-tote-adresse-in-eingefrorener-adr.md §Entscheidung`.**
**Was dieses Feld hier nicht leistet, gehört dazu:** der Sensor aus
`grundlagen-traceability.md` §Herkunfts-Anker prüft neben der Existenz des Zielorts auch, dass er
`seit slice-<NNN>` trägt; die ADR trägt das nicht, und sie darf es nicht nachtragen
([`AGENTS.md`](../../../../AGENTS.md) §3.4). Gebaut ist der Sensor in diesem Repo ohnehin nicht —
`.d-check.yml` führt `links, anchors, ids, matrix, codepaths, spans`, und keines davon paart Anker.
Die zweite Hälfte der Verkörperung — ein Wächter, der die Festlegung mechanisch hält — ist
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md)s eigene Folgepflicht 3 und steht
unten als Folge-Slice; die ADR sagt dazu selbst: *„Ohne ihn bleibt Festlegung 3 eine Zusage ohne
Wächter."*

**Eintrag 3 — geschärfte Regel: ein Abnahme-Kriterium prüft eine Zukunft; ein Proxy, der eine
Vergangenheit einfriert, kann das Ziel ausschließen, das er absichern soll.** Zweimal in diesem
Slice, in zwei Gestalten derselben Klasse. Erstens der leere Config-Diff: er sollte *„Prüfbereich
nicht geschrumpft"* belegen und hätte das Referenz-Ventil verboten, weil das die Config ändert und
den Prüfbereich stehen lässt. Zweitens eine feste Dateizahl: `468` war der Wert des Laufs, in dem
gemessen wurde, und wäre als Abnahme-Wert am nächsten hinzugefügten Dokument gefallen — dieser Lauf
zählt **473**. **Die Form, die trägt, steht in beiden Fällen daneben:** zwei Läufe über demselben
Baum vergleichen, nicht einen Lauf gegen einen gemerkten Wert; und den **Ziel-Zustand** prüfen
(*der Prüfbereich hat sich nicht bewegt*) statt eines **Stellvertreters** (*die Datei ist
unverändert*). **Adressat: Planner** — die Regel bindet, wer DoD-Punkte und Auflösungs-Trigger
schreibt, und sie ist die Verwandte der Lehre aus
[slice-138](../done/slice-138-nachweis-entsteht-nicht-ueber-rot.md) §7, die dieselbe Klasse an der
**Adresse** statt am **Wortlaut** eines Kommandos gefunden hat. **Gezählt, nicht verkörpert:** ihr
Ort wäre die Ziel-Form des Slice-Plans, und die ist Norm-Text; `liegt in` entfällt.

**Die Wiederholung ist der eigentliche Befund an diesen drei Einträgen.** Zwei von dreien enden
mit *gezählt, nicht verkörpert* und einem Zeiger auf
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), der seit zwölf Postens auf
seinen Lauf wartet — dieselbe Endung tragen die Closure-Notizen von
[slice-130](../done/slice-130-emitter-entscheidet-jedes-neue-template.md),
[slice-133](../done/slice-133-emittierter-baum-ohne-platzhalter-links.md) und
[slice-138](../done/slice-138-nachweis-entsteht-nicht-ueber-rot.md)
(`git grep -l 'gezählt, nicht verkörpert' -- 'docs/plan/planning/done/*.md' | wc -l` → **3**, und
diese Notiz ist die vierte). **Das ist kein Argument, den Eintrag zu unterlassen, sondern eines,
den Träger zu priorisieren** — und Priorisieren ist ein eigener Zug, kein Closure-Zug.

### Ausgänge — jeder Posten hat einen

| Posten | Herkunft | Ausgang |
|---|---|---|
| Für `links` gibt es keine Referenz-Ausnahme | §1, *„gemessen, nicht vermutet"* | **gefallen** — das Top-Level-`ignore-refs` trägt am gepinnten Stand; §1 und [`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand) tragen die korrigierte Messung |
| Der leere Config-Diff als Abnahme-Kriterium | §2 DoD (2), §5, §6, §3 | **ersetzt** durch den Vergleich zweier Läufe mit gleicher Dateizahl |
| Der Widerspruch `CO-005` ↔ [`MR-030`](../../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen) | §6, fünftes Risiko | **aufgelöst statt entschieden** — verschiedene Gegenstände; der eine gefallene Halbsatz hat seinen Nachfolge-Eintrag |
| Die tote Adresse in [`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md), erzeugt vom eigenen `git mv` | Implementer-Lauf | **ausgenommen, nicht repariert** — [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 1 und 2, Eintrag in `101b92f` |
| Festlegung 3 hat keinen Wächter | [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) Folgepflicht 3 | **Folge-Slice** [slice-142](../open/slice-142-verweis-form-vor-dem-einfrieren-hat-einen-waechter.md) |
| `CO-001` ist fällig, und seine Auflösung bricht zwei Verweise aus [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) §Kontext, ausdrücklich **nicht** gedeckt | **Folge-Slice** [slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) |
| [`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) und der `scan.ignore`-Kommentar tragen den gefallenen Werkzeug-Satz | §6, drittes Risiko | **Folge-Slice** [slice-143](../open/slice-143-datei-weiter-ausschluss-weicht-dem-referenz-ventil.md) |
| Zwei Steering-Loop-Regeln ohne Norm-Text | §7, Einträge 1 und 3 | **gezählt, nicht verkörpert** — Adressat Architect bzw. Planner, Termin-Träger [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md); dieser Lauf hat sie dort **nicht** eingetragen |

### Folge-Slices

Drei, alle **wellenlos** — keiner entsteht aus dem Baum-Tausch, alle drei aus der Mechanik der
Ausnahmen und der Carveout-Auflösung:
[slice-141](../next/slice-141-co-001-aufloesung-ist-vorher-entschieden.md) (die Entscheidung vor
dem Move, weil `CO-001` fällig ist und sein `git mv` zwei Verweise aus einer eingefrorenen ADR
bricht) · [slice-142](../open/slice-142-verweis-form-vor-dem-einfrieren-hat-einen-waechter.md)
(der Wächter zu [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 3) ·
[slice-143](../open/slice-143-datei-weiter-ausschluss-weicht-dem-referenz-ventil.md) (der
datei-weite Ausschluss weicht dem Referenz-Ventil, samt dem Config-Kommentar, der denselben Satz
trägt). Die Reihenfolge und ihr Kriterium stehen in den Plänen.

### Verifikation dieser Closure

`make docs-check` und `make gates` sind über dem Arbeitsbaum dieser Closure gefahren und oben
zitiert; die Sonde für den zweiten Lauf ist zurückgenommen, und die Rücknahme ist mit
`git status --porcelain` als leer belegt. **Was diese Closure nicht belegt:** einen Review-Durchgang
nach Modul 10 hat dieser Slice nicht gehabt. Was ihn ersetzt, sind die zwei unabhängigen
Rollen-Läufe, die je die Messung des vorigen umgestoßen haben — der Architect die Prämisse dieses
Plans, der Implementer die Adresse in
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md). Das ist die Grenze
dieser Closure und steht hier, weil sie sonst nirgends stünde.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist genau eine Sub-Area — `harness/`
(eigener Zuschnitt, eigene Ziel-Form, eigene schreibende Rolle: drei von drei Achsen).
`docs/plan/adr/` kommt nur bei Ausgang (a)/(b) mit **einer** neuen Datei hinzu und ist
keine eigene Berührung im Sinne der Schwelle.

**Vorgelagert — offene Beobachtungen sichten:** das Repo führt **kein**
Beobachtungs-Register; keine Treffer, und der Grund ist die fehlende Datei, nicht ein
leeres Register.

Alle berührten Sub-Areas GF: `harness/` gehört zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
Der Modus-Begründungsblock entfällt damit nach dem *Umfang*-Absatz oben.
