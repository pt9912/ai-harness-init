# ADR-0026: Der Doku-Gate nimmt eine eingefrorene Referenz aus — auf beiden Achsen namentlich, nicht datei-weit

**Status:** Accepted

**Datum:** 2026-08-30

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
der dauerhaft rot steht, ist so wenig wert wie einer, den es nicht gibt),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Tausch des
`<tag>`-gescopten Baums ist der Auslöser),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (die Voraussetzung: der Bestand wird nicht
geheilt), [ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) (hält jenen Beschluss
gegen den adoptierten Stand neu),
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (dieselbe Klasse auf der
Datei-Achse, und die Aufnahme-Grenze, an der sich diese hier misst),
[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(der Eintrag, der die ausgenommene Referenz trägt),
[`MR-030`](../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen)
(die Teil-Aufhebung, die den Verweis stehen lässt),
[`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
(die Append-only-Form, die den Rumpf einfriert),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie senkt einen Gate-Prüfumfang, sie ändert keine
Spec-Aussage.

**Abgrenzung gegen [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) — diese ADR
supersedet sie nicht.** Jene Entscheidung schließt die `scan.ignore`-Liste extensional auf eine
namentlich genannte Datei; dieser Eintrag steht unter einem **anderen Schlüssel** und lässt jene
Liste unberührt. Die Aufnahme-Grenze aus jener Entscheidung — *„jeder zusätzliche Eintrag ist eine
neue Senkung und löst [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus"* — wird von dieser ADR
**erfüllt**, nicht umgangen: sie ist das eigene Gefäß, das §3.5 verlangt. Was jene Entscheidung
über die **Werkzeug-Lage** feststellt, trägt diese ADR nicht fort; die Nachmessung steht im
Kontext, und was daraus für jene Entscheidung folgt, gehört in eine eigene.

---

## Kontext

### Der Befund, und warum ihn niemand im Artefakt beheben darf

Der Adaptions-Block in [`harness/conventions.md`](../../../harness/conventions.md) läuft **inline**
und **append-only**: ein akzeptierter Eintrag ist eine unveränderliche Region in einer änderbaren
Datei. Der Rumpf eines teil-abgelösten Eintrags bleibt wörtlich stehen
([`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
Setzung 1; [ADR-0014](0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (a) lässt ihn nur
bei **vollständiger** Aufhebung fallen).

[`MR-021`](../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
trägt in Punkt 2 einen Markdown-Link in den **abgelösten** Baseline-Baum. Der Satz um ihn herum
ist nur über jenen Stand wahr — die Baseline `v3.5.2` schrieb die dritte Rolle *Implementation*,
die adoptierte Baseline `v5.12.0` schreibt *Implementer*:

```sh
git show b902b60^:.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md | grep -c 'participant I as Implementation'   # 1
grep -c 'participant I as Implementer' .harness/baseline/v5.12.0/regelwerk/modul-08-agentenrollen.md                        # 1
```

Damit sind beide naheliegenden Reparaturen versperrt. Den **Tag zu ziehen** machte aus dem toten
Link ein falsches Zitat bei grünem Gate — von *laut* nach *stumm*, genau die Verwandlung, die
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 1 verwirft und
[ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md) gegen den adoptierten Stand neu
hält. Die **Adresse entfallen** zu lassen ist Festlegung 4 desselben Beschlusses, und die spricht
von Zeitdokumenten; ein append-only-Eintrag in einer lebenden Datei ist keines. Welche der beiden
Festlegungen ihn regiert, sagt
[`MR-030`](../../../harness/conventions.md#mr-030--der-rollen-name-der-baseline-und-der-bezeichner-fallen-zusammen):
**keine** — der Verweis ist eine datierte Aussage, kein Navigations-Zeiger.

Der Befund ist damit richtig und unbehebbar zugleich, und er ist heute der **einzige**:

```sh
make docs-check   # d-check: 469 Datei(en) geprüft, 1 Befund(e)
```

Ein Gate, dessen einziger Befund unbehebbar ist, ist kein Sensor mehr: es färbt jeden Lauf rot und
erzieht dazu, Rot zu überlesen — [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
eine Ebene tiefer.

### Die Klasse ist erhoben, und sie hat zwei Mitglieder

Rot färbt nicht die **Nennung** des abgelösten Tags, sondern der **Markdown-Link** in ihn:
`codepaths.roots` in [`.d-check.yml`](../../../.d-check.yml) sind `[spec, docs, harness]`, und
`.harness/…` liegt außerhalb. Beide Mengen, je mit ihrem Kommando:

```sh
grep -c 'v3\.5\.2' harness/conventions.md                                              # 15  Nennungen
grep -cE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' harness/conventions.md          #  1  Markdown-Link
git grep -oE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- '*.md' | wc -l           #  2  repo-weit
git grep -lE '\]\([^)]*\.harness/baseline/v3\.5\.2/[^)]*\)' -- '*.md' | wc -l           #  2  Dateien
```

**Ein grober Ausdruck über den Tag allein trifft eine andere Menge:**
`git grep -oE '\]\([^)]*v3\.5\.2[^)]*\)' -- '*.md' | wc -l` zählt auch Plan-Dateien, deren
**Dateiname** den Tag trägt. Die Zahlen oben sind darum über den vollen Pfad in den vendored Baum
erhoben. **Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — sie wandern mit dem Bestand.

Die zwei Mitglieder sind
[`harness/conventions.md`](../../../harness/conventions.md) und
[ADR-0013](0013-technik-stratum-als-zielort.md). Das zweite hat sein eigenes Gefäß
([ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)) und wird von dieser
Entscheidung **nicht** angefasst. Die Klasse ist also nicht groß, sondern klein und vollständig
bekannt — der Fall ist punktuell, nicht ein Cluster.

### Das Werkzeug trägt ein Ventil auf der Referenz-Achse — gemessen am gepinnten Stand

Der gepinnte d-check ist `ghcr.io/pt9912/d-check:v0.65.0`, Digest
`sha256:5ea03abe7918381c68203d8ac078a78d0d4ab91b5478e87c66b5a7b4fda41288`
([`d-check.mk`](../../../d-check.mk)). Er führt `ignore-refs` als **Top-Level**-Schlüssel, den
`links`, `anchors` und `codepaths` gemeinsam honorieren, mit `in` (Glob auf die Quelldatei), `refs`
(Globs auf das aufgelöste Ziel) und `keep`. Der Schlüssel ist **älter als der Pin** und wurde
zwischen seiner Einführung und ihm nicht entfernt:

```sh
grep -n '^## \[0\.49\.0\]' /Development/d-check/CHANGELOG.md                              # Release-Überschrift des Ventils
awk '/^## \[0\.65\.0\]/,/^## \[0\.49\.0\]/' /Development/d-check/CHANGELOG.md | grep -c '^### Removed'   # 0
```

**Der Name, unter dem man ihn sucht, ist nicht der, unter dem er steht.** Wer unter `links:` nach
`ignore-refs` sucht, findet nichts; `d-check --print-config` gibt eine kommentierte
Beispiel-Config aus, keine Schema-Liste, und Abwesenheit darin ist keine Abwesenheit der Option.
Die Fähigkeit steht querschnittlich, nicht modul-lokal — der modul-lokale
`codepaths.ignore-refs`, den dieses Repo seit
[`MR-009`](../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) fährt,
ist heute sein **Alias**.

**Das Ventil sitzt auf der Referenz-Achse, nicht auf der Datei-Achse — gemessen, mit beiden
Skopen an einer roten Gegenprobe.** Sonde in [`.d-check.yml`](../../../.d-check.yml), je ein
`make docs-check`, danach zurückgenommen (Arbeitsbaum sauber):

| Sonde | `in` | `refs` | Ergebnis |
|---|---|---|---|
| trägt | `harness/conventions.md` | `.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md` | `469 Datei(en) geprüft, 0 Befund(e)` |
| Gegenprobe Quell-Skopus | `AGENTS.md` | wie oben | `469 Datei(en) geprüft, 1 Befund(e)` |
| Gegenprobe Ziel-Skopus | `harness/conventions.md` | `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md` | `469 Datei(en) geprüft, 1 Befund(e)` |
| Gegenmessung Datei-Achse | — | `scan.ignore` um `harness/conventions.md` erweitert | `468 Datei(en) geprüft, 0 Befund(e)` |

**Tragend ist der Unterschied in der ersten Zahl, nicht ihr Betrag.** Das Referenz-Ventil lässt
sie bei 469 stehen, der datei-weite Ausschluss senkt sie auf 468 — der Nenner ist der
Markdown-Bestand des Repos und wandert mit ihm
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Genau daran ist die Wahl zwischen den beiden Ventilen ablesbar, ohne eine gemerkte
Zahl.

### Das Ventil ist trotzdem eine Senkung — nach dem Maßstab, den dieses Repo selbst führt

Der Prüfbereich schrumpft nicht um eine Datei, aber er schrumpft um eine **Referenz**, und die
schreibt dieses Repo autoritativ. Damit greift derselbe Test, mit dem
[`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage)
den dritten `scan.ignore`-Eintrag von den zwei Scoping-Einträgen trennt: *Scoping* ist ein
Ausschluss, der den Prüfumfang **nicht** um Bestand kürzt, den dieses Repo autoritativ schreibt —
und dieser tut es. Er ist eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 und braucht
darum eine ADR.

**Der Präzedenzfall aus
[`MR-009`](../../../harness/conventions.md#mr-009--d-check-pin-sprung-und-codepath-ventile) trägt
ihn nicht.** Jene fünf `ignore-refs`-Zeilen kamen **ohne** ADR in den Adaptions-Block, und der
Grund steht dort: sie ersetzten verstreute, breitere `d-check:ignore`-Zeilen-Marker durch zwei
zentrale, begründete Config-Zeilen — Gate-**Anheben**, für das
[`MR-001`](../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
den Steering-Loop und nicht die ADR vorsieht. Hier wird nichts Breiteres ersetzt: ein heute
vollständig sichtbarer, lebender Befund wird stummgeschaltet. Die Richtung ist umgekehrt, also
trägt die Ausnahme von der ADR-Pflicht nicht mit.

**Der Config-Kommentar zu `scan.ignore` in [`.d-check.yml`](../../../.d-check.yml) sagt dasselbe,
bindet hier aber nicht.** Er hält für seinen Schlüssel fest, jeder weitere Eintrag sei eine neue
Senkung mit eigener ADR. Ein Config-Kommentar steht in keinem Rang der Source Precedence
([`AGENTS.md`](../../../AGENTS.md) §2) und spricht überdies über einen anderen Schlüssel; er ist
hier **Bestätigung der gelebten Lesart, nicht ihr Grund**.

## Entscheidung

**Wir wählen Option E: [`.d-check.yml`](../../../.d-check.yml) bekommt genau einen
Top-Level-`ignore-refs`-Eintrag, dessen beide Skopen je auf eine namentlich genannte Datei
geschnitten sind** —

- `in: "harness/conventions.md"`
- `refs: [".harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md"]`

**und keinen weiteren.**

Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: **jeder zusätzliche Eintrag, jedes
zusätzliche Glob in `in` oder `refs` und jede Verbreiterung eines der beiden auf ein Verzeichnis
ist eine neue Senkung und löst [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus — auch dann, wenn
sie dieselbe Bedingung erfüllt wie diese.** Ein zweiter eingefrorener Eintrag mit gebrochenem
Baseline-Link braucht eine eigene Entscheidung; ein Baum-Glob statt der Zieldatei ebenso.

Der Unterschied ist der zwischen einer Schranke und einer Beobachtung. Ein Glob auf
`.harness/baseline/v3.5.2/**` autorisierte jeden künftigen Verweis derselben Quelldatei in
denselben Baum im Voraus und legte §3.5 still; die zwei namentlichen Dateien tun das nicht. Der
Boden hängt damit nicht an einer Prognose über die Sorgfalt künftiger Läufe, sondern an einer Hard
Rule, die bei jeder Verbreiterung erneut greift.

**Der Eintrag trägt im Config-Kommentar seine Begründung und einen Zeiger auf diese ADR** — wie
die bestehenden Ventil-Zeilen der Datei auch, von denen jede ihre Begründung im Kommentar führt.

**Was er nicht ist: das Gefäß eines Carveouts.** Die Ausnahme ist nicht temporär — sie steht,
solange der Adaptions-Block inline läuft. Ein Carveout mit einem Trigger, den niemand ernsthaft
terminiert, wäre der permanente Carveout, der lügt; Baseline-Regelwerk `modul-07-carveouts.md`
§Werkzeug-Wahl bei Diskrepanz führt genau diesen Fall in die ADR. Der Trigger, an dem die Ausnahme
wirklich hängt, steht unten und ist ein struktureller, kein terminierter.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — rot lassen und aussprechen | keine Senkung, keine Config-Änderung, maximale Ehrlichkeit | `make docs-check` bleibt dauerhaft rot, und der Befund ist heute der **einzige**: `make docs-check` meldet `469 Datei(en) geprüft, 1 Befund(e)`. Ein Dauer-Rot mit Zähler 1 ist kein Sensor mehr — jeder **echte** neue Befund erscheint als Zähler 2 in einem Lauf, den man ohnehin rot erwartet |
| B — `scan.ignore` auf [`harness/conventions.md`](../../../harness/conventions.md) | eine Zeile Config, sofort grün | nimmt den ganzen Konventionsspeicher über alle sechs Module aus der Prüfung: `grep -oE '\]\([^)]+\)' harness/conventions.md \| wc -l` → **376** Link-Vorkommen über **79** eindeutige Ziele, `grep -c '^### MR-' harness/conventions.md` → **35** Einträge. Gemessen fällt die geprüfte Datei-Zahl um genau eins (`468 … 0 Befund(e)` gegen `469 … 0` beim Referenz-Ventil) — der Prüfbereich schrumpft, was das Referenz-Ventil gerade nicht tut |
| C — den Verweis im Eintrag reparieren | keine Config-Änderung, keine Senkung | der Rumpf ist append-only eingefroren ([`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger) Setzung 1); Tag ziehen erzeugt ein falsches Zitat bei grünem Gate ([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 1), Adresse entfallen lassen ist für Zeitdokumente geschrieben (Festlegung 4) und trifft einen Eintrag in einer lebenden Datei nicht |
| D — den Adaptions-Block in die Verzeichnis-Form überführen | löst die Klasse **strukturell**: jeder Eintrag liegt in einer eigenen Datei, ein aufgelöster wandert nach `conventions/done/` und ist damit konstruktiv ein Zeitdokument, für das Festlegung 4 bereits gilt | ein Umbau von **2210** Zeilen und **35** Einträgen (`wc -l harness/conventions.md`, `grep -c '^### MR-' harness/conventions.md`) für einen einzigen Befund; er ist ein eigener Schnitt mit eigenem Trigger und lässt den Gate bis dahin rot. Diese ADR schließt ihn nicht aus — sie macht ihn bezahlbar, statt ihn zu erzwingen |
| E' — `ignore-refs` mit Baum-Glob `refs: [".harness/baseline/v3.5.2/**"]` | eine Zeile weniger Pflege, deckt jeden künftigen Verweis derselben Datei in denselben Baum | **intensional statt extensional**: autorisiert den zweiten Fall im Voraus und legt §3.5 still. Und der Vorteil ist keiner: der Glob nennt den **abgelösten** Tag; die nächste Re-Baseline erzeugt einen anderen abgelösten Tag, den er nicht deckt. Er kauft Blindheit für den heutigen Baum, keine Zukunftssicherheit |
| **E — gewählt: Top-Level-`ignore-refs`, `in` und `refs` je eine namentliche Datei** | kleinstmöglicher Prüfbereichs-Verlust für das Problem — die geprüfte Datei-Zahl bleibt unverändert, alle übrigen **375** Link-Vorkommen der Datei bleiben bewacht; die Grenze hängt an §3.5 statt an einer Prognose; beide Skopen sind an einer roten Gegenprobe belegt | die Ausnahme deckt **jede** Referenz aus dieser Quelldatei auf dieses Ziel, nicht nur die eine Zeile — heute ist das genau eine (`grep -cE '\]\([^)]*\.harness/baseline/v3\.5\.2/regelwerk/modul-08-agentenrollen\.md[^)]*\)' harness/conventions.md` → **1**), morgen könnte eine zweite still darunter verschwinden. Dagegen steht die Folgepflicht unten, nicht ein Versprechen |

## Konsequenzen

**Der Preis, gemessen — und er ist eine Referenz, keine Datei.** Aus der Prüfung fällt, was `in`
und `refs` **gemeinsam** treffen: Referenzen aus
[`harness/conventions.md`](../../../harness/conventions.md), deren aufgelöstes Ziel
`.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md` ist. Heute ist das genau eine:

```sh
grep -cE '\]\([^)]*\.harness/baseline/v3\.5\.2/regelwerk/modul-08-agentenrollen\.md[^)]*\)' harness/conventions.md   # 1
```

**Was bewacht bleibt, ebenfalls mit seinem Kommando:** die übrigen Link-Vorkommen derselben Datei
(`grep -oE '\]\([^)]+\)' harness/conventions.md | wc -l` → **376**, davon eines ausgenommen), alle
**79** eindeutigen Ziele bis auf dieses eine, jede eingehende Referenz **auf** die Datei, und jedes
Modul, das `ignore-refs` nicht honoriert. Der geteilte Schlüssel wirkt auf `links`, `anchors` und
`codepaths`; `ids`, `matrix` und `spans` sehen die Datei unverändert.

- **Positiv:** `make docs-check` wird grün, ohne dass ein append-only-Eintrag angefasst wird und
  ohne dass eine Datei den Prüfbereich verlässt. Die geprüfte Datei-Zahl steht vor und nach dem
  Eintrag auf demselben Wert.
- **Positiv:** Die Ausnahme kann nicht stillschweigend wachsen; jede Verbreiterung ist ein
  sichtbarer §3.5-Vorgang.
- **Negativ:** Eine zweite Referenz aus derselben Quelldatei auf dasselbe Ziel fiele mit aus der
  Prüfung. Diese Restbreite ist die Folge davon, dass das Ventil auf dem **aufgelösten Pfad**
  matcht und nicht auf der Zeile — sie ist erzwungen, nicht gewählt, und sie hat einen Wächter
  (Folgepflicht 2).
- **Negativ:** [`AGENTS.md`](../../../AGENTS.md) §3.5 selbst hat **keinen Sensor**. Die Schranke
  gegen einen zweiten Eintrag ist prozessual, wie bei jeder anderen Senkung dieses Repos.
- **Folgepflicht 1 (der Lauf, der den Eintrag setzt):** den Top-Level-`ignore-refs`-Eintrag in
  [`.d-check.yml`](../../../.d-check.yml) anlegen — **samt Config-Kommentar mit Begründung und
  Zeiger auf diese ADR** — und mit zwei `make docs-check`-Läufen belegen, dass die geprüfte
  Datei-Zahl vor und nach dem Eintrag dieselbe ist. `scan.ignore` bleibt dabei unverändert.
- **Folgepflicht 2 (derselbe Lauf):** den Wächter der Restbreite bauen — eine Prüfung, die rot
  wird, sobald [`harness/conventions.md`](../../../harness/conventions.md) **mehr als einen**
  Markdown-Link auf das ausgenommene Ziel trägt. Ihr Gegenbeispiel ist ein zweiter solcher Link;
  er muss einmal rot gesehen werden ([`AGENTS.md`](../../../AGENTS.md) §3.6). **Ohne ihn ist die
  Zusage „die Ausnahme deckt genau eine Referenz" unbelegt**, und diese ADR behauptet ihn nicht
  als vorhanden ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Folgepflicht 3 (Architect, im selben Commit wie diese ADR):** die Werkzeug-Aussage im
  Adaptions-Block nachführen. Zwei Einträge sagen dort, ein referenz-weites Ventil für `links`
  gebe es am gepinnten Stand nicht; der Block ist append-only, die Korrektur ist also ein
  Nachfolge-Eintrag mit Kopf-Marken auf beide Vorgänger
  ([`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzungen 1 und 3). **Die Gate-Config ändert diese ADR nicht — sie autorisiert sie.**

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es nach dieser Senkung noch prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` | jeder Markdown-Link aus [`harness/conventions.md`](../../../harness/conventions.md) **außer** dem einen ausgenommenen Ziel löst auf, Ziel und Anker — auch in den vendored Baum hinein | `make docs-check` |
| d-check `links` / `matrix` | Verweise **auf** die Datei bleiben vollständig bewacht; der Eintrag wirkt auf der Ziel-Achse, nicht auf der Quell-Achse | `make docs-check` |

**Nicht gebaut, und hier ehrlich zu benennen: die Breite dieser Ausnahme hat noch keinen Sensor.**
`make docs-check` meldet, dass alle **anderen** Referenzen auflösen; es meldet **nicht**, wie viele
Referenzen der Eintrag stumm schaltet — ein zu breiter Eintrag ist genauso grün wie ein enger. Der
Sensor dafür ist Folgepflicht 2 und ist mit dem Eintrag zusammen zu bauen, nicht danach. Ebenso
ohne Sensor ist die Grenze selbst: dass eine Verbreiterung eine neue ADR verlangt, ist eine
Hard-Rule-Aussage ([`AGENTS.md`](../../../AGENTS.md) §3.5) und wird von keinem Lauf geprüft.

## Re-Evaluierungs-Trigger

- **Wenn der Adaptions-Block in die Verzeichnis-Form wandert** *(am Verzeichnis der
  Einzel-Einträge unter harness/ ablesbar)*: dann liegt der Eintrag in einer eigenen Datei,
  wandert mit seinem Auflösungs-Trigger in das done-Verzeichnis daneben und ist konstruktiv ein
  Zeitdokument — für das [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 das
  Entfallen der Adresse bei stehenbleibendem Text bereits regelt. Die Ausnahme wird damit
  gegenstandslos und ist **zurückzunehmen**, nicht stillschweigend mitzuführen.
- **Wenn eine zweite Referenz aus derselben Quelldatei auf dasselbe Ziel entsteht** *(Folgepflicht
  2 färbt rot)*: dann deckt die Ausnahme etwas mit, das niemand entschieden hat. Zu entscheiden
  ist dann, ob die zweite Referenz zulässig ist oder ob die Ausnahme zu verengen ist — in einer
  eigenen ADR, nicht hier.
- **Wenn eine weitere Referenz ausgenommen werden soll** *(am Vorgang ablesbar; §3.5 greift von
  selbst)*: dann ist zu entscheiden, ob die Verweis-Regel aus
  [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) nicht getragen hat oder ob der Fall neu ist. Die
  nächste Re-Baseline erzeugt einen **anderen** abgelösten Tag; ein Eintrag für ihn ist von dieser
  Entscheidung nicht gedeckt.
- **Wenn der gepinnte d-check das geteilte `ignore-refs` verlöre** *(feedforward — eine
  Werkzeug-Version, kein Sensor; sichtbar wird sie, wer den CHANGELOG des neuen Pins gegen den
  alten liest)*: dann fällt die Voraussetzung dieser Entscheidung, und der Befund kehrt zurück.
  Ein Re-Pin prüft das mit demselben Trockenlauf, der ohnehin fällig ist.
- **Wenn [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) nicht mehr gilt** *(am Status ablesbar)*:
  dann fällt die Voraussetzung — wird der Bestand doch geheilt, gibt es keinen unbehebbaren Befund
  und keinen Grund für diese Senkung.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-30 | **Proposed** | Architect-Entscheid zur Gate-Lage nach der Re-Baseline. Vier Läufe am gepinnten Stand tragen sie: das geschnittene Referenz-Ventil, seine zwei roten Gegenproben und die Gegenmessung auf der Datei-Achse. Dass der Zeilen-Marker `d-check:ignore` das Modul `links` nicht deckt, ist hier **nicht** neu gemessen, sondern der Sonde in [`MR-029`](../../../harness/conventions.md#mr-029--der-scanignore-zensus-wandert-und-sein-dritter-grund-ist-keine-scoping-aussage) §Auflösungs-Trigger entnommen, die unter demselben Pin lief |
| 2026-08-30 | **Accepted** | Angenommen vom Auftraggeber. Der Slice geht damit in seine Implementer-Commits: der Config-Eintrag in [`.d-check.yml`](../../../.d-check.yml) samt Wächter der Restbreite, danach die Auflösung von [`CO-005`](../carveouts/CO-005-adaptions-block-datierter-beleg.md) |
