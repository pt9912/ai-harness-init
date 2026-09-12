# Slice slice-217: Jedes `doc-*`-Ziel sagt, ob es einen Prüfbereich hat — und ein Wächter leitet die Menge ab, statt sie zu pflegen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md). Der Slice trägt das
**welle-eigene** Closure-Kriterium aus §3 jenes Plans — jenes, das keine Slice-DoD abschreibt.
Die Zugehörigkeit ist damit nach Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht gegeben: Die Welle beobachtet neben diesem Slice weiteres, was
seine DoD nicht belegt — `make gates` grün **mit** den neu aufgenommenen Modulen, die Lage aller
übrigen Slices in `done/` und das einmal rot gesehene Rot je verdrahtetem Modul. **Dieses
Kopf-Feld ist die maschinen-tragende Aussage** der Zugehörigkeit: `make archive-welle` sammelt
nach ihm ein, nicht nach der Tabelle in §4 des Welle-Plans.

**Ebene: Dogfood, nicht emittiert.** Gegenstand sind das Gate-Fragment
[`d-check.mk`](../../../../d-check.mk) und der Harness-Einstieg
[`harness/README.md`](../../../../harness/README.md) **dieses** Repos. Was ein emittiertes Repo an
`doc-*`-Zielen und an Aussagen über ihren Prüfbereich bekommt, entscheidet
[`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
und der Slice, der die Tool-Ebene entscheidet — nicht dieser (§1, Abgrenzung).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (die
Klasse in Reinform: ein Ziel, das `0 Befund(e)` meldet und dabei nichts geprüft hat, ist die
stille Hälfte des halluzinierten Gates),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (jede Messung unten
läuft gegen den in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest, netzlos, Mount `:ro`),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (die Zusage *„jedes Ziel ohne Prüfbereich sagt es"* ist
erst fertig, wenn sie einmal rot gesehen wurde — §2 DoD (3) nennt die drei Lagen),
[`AGENTS.md`](../../../../AGENTS.md) §3.1 (der Gate-Config wächst mit den Artefakten),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(*„Gate-Anheben → Steering-Loop"* — dieser Slice **hebt** und braucht darum kein ADR;
[`AGENTS.md`](../../../../AGENTS.md) §3.5 bindet Senkungen),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (das
Gate-Fragment ist tool-generiert und trägt einen abgezählten Adopter-Kopf — jeder Handgriff daran
ist einer mehr, §3),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das genau sie liefert; keine ist ein Erwartungswert),
[`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)
(warum aus `0 Befund(e)` an einer Stelle nicht folgt, dass das Ziel inert ist — §1 *Die Null muss
gegengeprüft werden*).

**Berührte Spec-Stellen:** `—`. Der Slice berührt keine Spec-Stelle; Gegenstand sind ein
Gate-Fragment, ein Harness-Einstiegs-Absatz und ein Test.

**Verantwortlich:** Implementer (pt9912). Der Liefergegenstand ist Gate-Konfiguration, Doku und
ein Test — die Default-Besetzung, die Baseline-Regelwerk `modul-05-planning-harness.md`
§Lifecycle als State Machine für den Übergang `open→next` vorsieht.

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Jedes `docs?-*`-Ziel in [`d-check.mk`](../../../../d-check.mk) ist einer benannten Klasse
zugeordnet und diese Zuordnung steht geschrieben; die Ziele, die weiterhin ohne Config-Block
laufen, sagen das in ihrem Hilfetext **und** in ihrer eigenen Ausgabe; und ein Wächter **leitet**
die Menge dieser Ziele aus [`d-check.mk`](../../../../d-check.mk) und
[`.d-check.yml`](../../../../.d-check.yml) ab, statt sie zu pflegen.**

Der Lieferwert ist nicht die Beschriftung zweier Rezepte. Er ist, dass ein Mensch, der `make
doc-structure` tippt und `0 Befund(e)` liest, nicht mehr glauben muss, etwas sei geprüft worden —
und dass das **auch für das dritte solche Ziel gilt, das noch niemand geschrieben hat**.

### Die Ursache: der Generator ist config-blind

`doc-tracked` und `doc-structure` stehen nicht in [`d-check.mk`](../../../../d-check.mk), weil
jemand sie gewählt hätte. Die Datei ist *„Abgeleitet aus `d-check --print-mk`"* (ihre erste Zeile),
und der Generator gibt **je Modul ein Ziel** aus, ohne die Konfiguration anzusehen — gemessen an
einer Kopie außerhalb des Repos, netzlos, Digest aus [`d-check.mk`](../../../../d-check.mk):

```sh
D=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
docker run --rm --network none "ghcr.io/pt9912/d-check@$D" --print-mk \
  | grep -cE '^docs?-[a-z-]*:'                                                      # 13
docker run --rm --network none -v "$PWD":/repo:ro "ghcr.io/pt9912/d-check@$D" \
  --print-mk --config /repo/.d-check.yml | grep -cE '^docs?-[a-z-]*:'               # 13
# und die beiden Ausgaben sind Byte für Byte gleich:
diff <(docker run --rm --network none "ghcr.io/pt9912/d-check@$D" --print-mk) \
     <(docker run --rm --network none -v "$PWD":/repo:ro "ghcr.io/pt9912/d-check@$D" \
         --print-mk --config /repo/.d-check.yml) && echo identisch
```

**Das verschiebt die Diagnose.** Die zwei C-Ziele sind kein vergessener Hilfetext, sondern die
Folge einer Erzeugungs-Regel, die die Konfiguration nicht liest — und sie **kämen bei der nächsten
Regenerierung in der alten Form zurück**. Jede Aussage, die dieser Slice in
[`d-check.mk`](../../../../d-check.mk) schreibt, muss deshalb als **Nachpflege** erkennbar sein
und nicht als Generat-Text, der sie überschreibt (§3, §6).

### Die Bezugsmenge, abgeleitet statt aufgezählt

Ein einziges Kommando bildet die Klassen. Es ist zugleich die Vorlage der Ableitung, die der
Wächter aus DoD (3) hermetisch nachbaut — Ziel-Zeile aus
[`d-check.mk`](../../../../d-check.mk), Rezept-Zeile darunter, `--enable`-Modul, und die Frage, ob
[`.d-check.yml`](../../../../.d-check.yml) für dieses Modul einen Top-Level-Block führt:

```sh
awk '
  /^docs?-[a-z-]+:.*## /{z=$1; sub(":","",z); next}
  z && /^\t/ {
    m=""; for(i=1;i<=NF;i++) if($i=="--enable") m=$(i+1)
    if (m!="")            k = (system("grep -qE \"^" m ":\" .d-check.yml")==0 ? "B" : "C")
    else if ($0 ~ /--help/)      k="D"
    else if ($0 !~ /docker run/) k="D"
    else                         k="A"
    printf "%-14s %-10s %s\n", z, (m==""?"-":m), k; z=""
  }' d-check.mk
```

Am Stand dieses Schnitts (2026-09-12) liefert es **13** Zeilen
(`grep -cE '^docs?-[a-z-]+:.*## ' d-check.mk`) in vier Klassen — **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2), jede Zahl wandert mit [`d-check.mk`](../../../../d-check.mk):

| Klasse | Ziele | Prüfbereich |
|---|---|---|
| **A** — kein `--enable`, fährt das Werkzeug über dem Baum | `docs-check`, `doc-doctor`, `doc-repair` (Befund-Satz) · `doc-trace`, `doc-complete` (RTM-Modus) | ja — die Modul-Liste aus `modules:` bzw. die Matrix |
| **B** — opt-in-Modul **mit** Top-Level-Block | `doc-planning`, `doc-targets` (Modul zusätzlich in `modules:`) · `doc-immutable`, `doc-commits` (nur über das eigene Rezept) | ja — der Block ist der Prüfbereich |
| **C** — opt-in-Modul **ohne** Top-Level-Block | `doc-tracked`, `doc-structure` | **das ist der Gegenstand dieses Slice** |
| **D** — fährt kein Modul über dem Repo | `doc-usage` (`--help`) · `doc-help` (`grep` über `MAKEFILE_LIST`, kein Docker) | die Frage ist sinnlos — und **auch das gehört gesagt** |

**Die Unterteilung innerhalb von A und B trägt der Text, nicht die Ableitung.** Das Kommando oben
kennt nur *hat `--enable`* und *hat einen Block*; ob ein A-Ziel den Befund-Satz oder die RTM
fährt und ob ein B-Modul zusätzlich in `modules:` steht, liest es nicht. Das ist Absicht: Der
Wächter aus DoD (3) braucht **allein die C-Menge**, und jede Unterscheidung, die er nicht braucht,
wäre eine, die er falsch treffen kann.

**`doc-commits` ist der eine B-Fall mit einer eigenen Geschichte, und sie wird hier nicht neu
erzählt.** Das Ziel ist am gepinnten Stand gemessen defekt — jeder `--range`-Lauf bricht ab,
solange `commits.id-patterns` nicht leer ist, und mit leerer Liste prüft es nichts. Beleg,
Reproduktion und Träger-Entscheidung stehen in
[`harness/README.md`](../../../../harness/README.md) §Sensors und im `commits:`-Kopfkommentar von
[`.d-check.yml`](../../../../.d-check.yml); der Deckungs-Absatz aus DoD (1) **zeigt darauf** und
schreibt es nicht ab. Für die Marke aus DoD (2) ist es kein Kandidat: Es hat einen Block, und es
meldet kein stilles `0 Befund(e)`, sondern bricht laut ab.

### Die Null muss gegengeprüft werden, sonst ist die Klassifikation selbst eine Behauptung

[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §3 stellt über die C-Ziele fest:
*„Heute melden sie ‚0 Befund(e)' und meinen ‚nichts geprüft'"*. Die zweite Hälfte des Satzes
trägt diese Zeile aber **nicht**: `0 Befund(e)` ist mit *aktiv und sauber* ebenso verträglich wie
mit *inert*
([`MR-055`](../../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft)).
**Der erste Schritt der Umsetzung ist darum, `make doc-structure` und `make doc-tracked` selbst zu
fahren** — dieser Plan zitiert die Welle, er misst nicht an ihrer Stelle.

Die Methode steht schon in [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §1 Messung 1
und wird hier **nachgeholt**, nicht erfunden: derselbe Baum mit einem **eingesetzten Defekt** —
einem, den das Modul melden *müsste*, wenn es liefe — einmal ohne und einmal mit Config-Block.
Bleibt er ohne Block stumm und meldet mit Block, ist die Inertheit belegt. Dass diese Gegenprobe
schiefgehen kann, hat dieselbe Welle an `vcs` vorgeführt: Dort blieb der Lauf grün, weil der
Defekt an einer vom Block ausgenommenen Stelle saß.

**Der dritte Ausgang ist ausdrücklich erlaubt:** Lässt sich für ein C-Ziel kein Defekt
konstruieren, weil die Kandidaten-Regel des Moduls unverstanden ist — die Lage, die
[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §6 für `reviews` beschreibt —, lautet die
ehrliche Einordnung *„Kandidaten-Regel unverstanden"* und **nicht** *„ohne Prüfbereich"*. Eine
Klassifikation, die den Unterschied verschweigt, wäre dasselbe stille Grün eine Ebene höher.

### Was die Marke behauptet — und was sie bewusst nicht behauptet

Die Marke aus DoD (2) nennt die **ableitbare Tatsache**: `.d-check.yml` führt keinen
`<modul>:`-Block für das Modul, das dieses Rezept mit `--enable` zuschaltet. Sie nennt **nicht**
das Verhalten (*„inert"*, *„nichts geprüft"*) — das steht im Deckungs-Absatz aus DoD (1), wo es
seine Messung bei sich tragen kann.

Der Grund ist die Prüfbarkeit: Der Wächter aus DoD (3) kann die Tatsache messen; das Verhalten
kann er nicht. Behauptete die Marke das Verhalten, trüge sie eine Zusage, die ihr eigener Wächter
nicht hält — genau die Klasse, die
[`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
führt. So gebaut kann die Marke nur an **einer** Stelle falsch werden, nämlich wenn ein Block
hinzukommt — und genau dort schlägt der Wächter in seiner zweiten Richtung an.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Ziel bekommt einen Prüfbereich.** Für `structure` übernimmt es
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md): dessen DoD (2)
  schreibt einen `structure:`-Block mit zwei Form-Regeln und nimmt `structure` in `modules:` auf —
  eine Adresse, die die Sendung annimmt. *(Folge-Slice mit Kennung.)*
- **`tracked` bekommt hier keinen Block und keine Folge-Kennung.** Eine Adresse steht dafür nicht
  zur Verfügung: [slice-116](../open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md)
  ist der Slice, den [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §6 als Berührung
  nennt, aber sein Text führt das Modul nicht — `grep -c 'tracked'` über seine Datei liefert
  **0**. Ihm hier eine Pflicht zuzuschreiben, die er nicht trägt, wäre eine Adresse, die die
  Sendung ablehnt. Die Aktivierung von `tracked` ist damit ein **anderer Vorgang** mit eigener
  Abwägung; dieser Slice stellt fest, dass sie aussteht. *(Anderer Vorgang.)*
- **Kein Modul wird in `modules:` aufgenommen und keines herausgenommen.** Das wäre eine Änderung
  am Durchsetzungspunkt `docs-check` und damit an dem, was `make gates` prüft — eine
  Gate-Bewegung, die ihre eigene Messung und ihren eigenen Schnitt braucht
  ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)).
  *(Anderer Vorgang.)*
- **Kein Ziel wird aus [`d-check.mk`](../../../../d-check.mk) entfernt, und die Generator-Lücke
  wird nicht geschlossen.** Die Ursache der C-Klasse liegt darin, dass `--print-mk` je Modul ein
  Ziel ausgibt, ohne die Konfiguration zu lesen (§1). Sie zu schließen hieße, im Nachbar-Repo
  `/Development/d-check` zu arbeiten — ein anderer Vorgang in einem anderen Baum, über den dieser
  Slice nicht entscheidet; ein Ziel hier zu löschen wäre die Umkehrung: der Adopter nähme dem
  Generat Zeilen weg und vergrößerte das Nachpflege-Delta, statt es zu benennen. Beide Hälften
  stehen als **benannte Lücke** in §6. *(Anderer Vorgang.)*
- **Keine Aussage über das, was das Werkzeug in ein Zielrepo emittiert.** Die Modul-Zusammensetzung
  des emittierten Doc-Gates entscheidet
  [`MR-054`](../../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel);
  ein emittiertes Repo hat andere `doc-*`-Ziele und andere Blöcke. *(Schicht-Abgrenzung.)*
- **Kein Produkt-Code.** Der Slice berührt `internal/` und `cmd/` nicht; er ändert Doku, ein
  Gate-Fragment und einen Test. Das ist beim Review in einem `git diff --stat` prüfbar.
  *(Schicht-Abgrenzung.)*
- **Die Datei [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) wird nicht angefasst** — weder
  ihre §4-Tabelle um eine siebte Zeile noch die zwei Zahlen in §3. Sie trägt dort *„Alle sechs
  Slices liegen in `done/`"* und *„für jedes der zwölf `docs?-*`-Ziele"*; heute zählt
  `grep -cE '^docs?-[a-z-]+:.*## ' d-check.mk` **13**, und mit diesem Slice wären es sieben
  Mitglieder. **Beide Zahlen sind Bestandswerte in einem Abnahmekriterium, und beide gehören in
  denselben Zug korrigiert** — den Closure-Lauf der Welle, der §3 und §4 ohnehin liest. Eine davon
  jetzt zu bewegen machte die andere falsch, und ein Abnahmekriterium umzuschreiben, während man
  den Slice schneidet, der es erfüllt, ist genau die Bewegung, die
  [`AGENTS.md`](../../../../AGENTS.md) §3.10 als Übergabe-Artefakt statt als Closure-Schritt
  führt. **Operativ kostet das nichts:** Die maschinen-tragende Aussage der Zugehörigkeit ist das
  Kopf-Feld `Welle:` dieses Plans, nicht die Tabelle — `make archive-welle` sammelt nach dem Feld
  ein. Das Kriterium selbst lautet *„für jedes"* und wird über die **gemessene** Menge erfüllt,
  nicht über die zitierte Zahl. *(Bestand bleibt bewusst stehen.)*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **(1) Jedes `docs?-*`-Ziel ist klassifiziert, und die C-Klasse ist an einem eingesetzten
      Defekt gemessen.** **Der Ort ist ein anderer als hier vorgeschrieben:** Der Deckungs-Absatz
      liegt in [`harness/sensors/doc-tracked.md`](../../../../harness/sensors/doc-tracked.md)
      (vier Klassen, Ableitungs-Regel, `doc-commits`-Zeiger, Gegenprobe `doc-tracked`) und in
      [`harness/sensors/doc-structure.md`](../../../../harness/sensors/doc-structure.md)
      (Gegenprobe `doc-structure`, Marken-Semantik, Ausgabe-Grenze);
      [`harness/README.md`](../../../../harness/README.md) §Sensors führt beide als Tabellenzeile.
      Die Verlagerung ist die Ziel-Form, die
      [slice-114](../in-progress/slice-114-jede-aussage-hat-einen-abschnitt.md) hergestellt hat, während dieser
      Slice lief — der Inhalt der Zusage ist unverändert, nur ihre Datei. Beide Gegenproben sind
      am eingesetzten Defekt gefahren und verbatim abgedruckt: `doc-tracked` **nicht inert**
      (`target-untracked` mit **und** ohne Block, byte-gleich), `doc-structure` **inert**
      (0 Befunde ohne, 100 mit Block). Der dritte Ausgang *„Kandidaten-Regel unverstanden"* war
      für kein C-Ziel nötig. Der ursprüngliche Wortlaut folgt.
      Ein Deckungs-Absatz in
      [`harness/README.md`](../../../../harness/README.md) §Sensors — in der Form der dortigen
      *„Was … deckt, und was nicht"*-Absätze — führt alle vier Klassen aus §1 samt der
      Ableitungs-Regel und ordnet **jedes** Ziel ein, die D-Klasse ausdrücklich als *„die Frage
      ist sinnlos, und hier steht warum"*. Für jedes C-Ziel steht daneben die **Gegenprobe**:
      derselbe Baum mit einem eingesetzten Defekt, einmal ohne und einmal mit Config-Block,
      Kommando und Ausgabe beider Läufe im Umsetzungs-Commit. Lässt sich für ein C-Ziel kein
      Defekt konstruieren, steht dort *„Kandidaten-Regel unverstanden"* statt *„ohne
      Prüfbereich"* (§1). `doc-commits` wird **verwiesen**, nicht abgeschrieben.
- [x] **(2) Jedes C-Ziel trägt die Marke — im Hilfetext und in seiner eigenen Ausgabe.** Die Marke
      ist **ein** deklariertes Literal, es steht im `##`-Hilfetext des Rezepts in
      [`d-check.mk`](../../../../d-check.mk) (und damit in `make doc-help`) **und** als letzte
      Zeile, die der Lauf selbst ausgibt — nach der `0 Befund(e)`-Zeile, damit sie die letzte
      bleibt, die ein Mensch liest. Sie nennt die **ableitbare Tatsache** (`.d-check.yml` führt
      keinen `<modul>:`-Block) und zeigt auf den Absatz aus (1); sie behauptet kein Verhalten
      (§1). Das Literal enthält kein `## ` — sonst zerschneidet die `sed`-Zeile von `doc-help` es.
      **Und sie ist als Nachpflege deklariert**: Der Adopter-Kopf von
      [`d-check.mk`](../../../../d-check.mk) führt sie als weiteren **nummerierten Handgriff**
      neben den bestehenden vier, seine Überschrift (*„NEU-ERZEUGUNG: VIER Handgriffe"*) ist
      mitgezogen, und die Hunk-Zahl daneben ist mit dem dort stehenden `diff`-Kommando **neu
      gemessen**. Ohne diesen Eintrag nähme die nächste Regenerierung die Marke stillschweigend
      mit (§3, §6).
- [x] **(3) Ein Wächter hält die Bijektion, abgeleitet, in beiden Richtungen — und ein
      Mutations-Fall nimmt ihm die Zähne.** Eine neue `test/*.bats`-Datei bildet die Menge der
      C-Ziele aus [`d-check.mk`](../../../../d-check.mk) und
      [`.d-check.yml`](../../../../.d-check.yml) **ab** (kein aufgezähltes Ziel im Testtext) und
      hält `{C-Ziele} == {Ziele mit Marke im Hilfetext} == {Ziele mit Marke in der Ausgabe}`. Sie
      läuft über `make test-bats` in `make gates` und braucht weder Docker-Lauf noch Netz. Dazu
      ein Fall unter `test/mutations/`, der ein **drittes**, neues C-Ziel ohne Marke in
      [`d-check.mk`](../../../../d-check.mk) einsetzt — die Ausprägung-statt-Eigenschaft-Falle in
      Reinform — und dessen `# expect:`-Zeile diesen bats-Fall nennt (Antwort auf
      [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)).
      **Rot gesehen in drei eingesetzten Lagen**, jede mit Kommando und Ausgabe im
      Umsetzungs-Commit: *(a)* ein drittes C-Ziel ohne Marke · *(b)* die Marke an einem
      bestehenden C-Ziel entfernt · *(c)* ein `structure:`-Block in
      [`.d-check.yml`](../../../../.d-check.yml) ergänzt, während die Marke stehen bleibt — die
      Gegenrichtung, und genau die Lage, die
      [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) herstellt.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [x] Doku-Update: der Deckungs-Absatz aus (1) **ist** das Doku-Update; ein öffentlicher Vertrag
      ist nicht berührt. Keine neue `make`-Tabellenzeile fällt an — der Slice legt kein
      `make`-Ziel an, und `doc-tracked`/`doc-structure` stehen bereits in `targets.exempt-targets`
      (`sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -cE '^    - doc-(tracked|structure)$'`
      → **2**).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

### Der Träger der Aussage — und warum beide Hälften

[welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §3 lässt die Wahl: *„in ihrer eigenen
Ausgabe **oder** ihrem Hilfetext"*. Dieser Slice nimmt **beide**, und der Grund ist je Hälfte ein
anderer:

- **Die eigene Ausgabe** ist die Stelle, an der der Schaden entsteht. Wer `make doc-structure`
  tippt, liest `0 Befund(e)` und sonst nichts; ein Hilfetext, den er nicht aufgerufen hat,
  erreicht ihn nicht.
- **Der `##`-Hilfetext** ist die Stelle, an der die Aussage **ohne Docker-Lauf** prüfbar ist — und
  damit die einzige, an der ein Wächter in `make gates` sie halten kann. Er läuft zudem in `make
  doc-help` mit, der Liste, die das Repo selbst als Dokumentation dieser Ziele führt
  ([`harness/README.md`](../../../../harness/README.md) §Sensors).
- **[`harness/README.md`](../../../../harness/README.md) kommt hinzu, ersetzt aber keine der
  zwei.** Die Welle nennt Ausgabe und Hilfetext; ein Absatz im Harness-Einstieg allein erfüllte
  sie nicht. Er trägt das, wofür in einer Zeile kein Platz ist: die vier Klassen, die Ableitung,
  die Gegenprobe je C-Ziel und den Zeiger auf `doc-commits`.

**Beide Hälften liegen in derselben Datei**, und das ist der Grund, warum ein hermetischer
Wächter genügt: Hilfetext und Rezept-Zeile sind Text in
[`d-check.mk`](../../../../d-check.mk); die Ausgabe-Hälfte wird an der Zeile geprüft, die sie
erzeugt, nicht an einem Lauf.

**Der rohe Generat-Text taugt als Träger nicht — der Adopter-Kopf ist es.** Beide Hälften liegen
in einer generierten Datei (§1 *Die Ursache*); eine Regenerierung nähme sie mit. Der Schutz
dagegen **existiert bereits** und wird hier benutzt statt erfunden: Der Adopter-Kopf von
[`d-check.mk`](../../../../d-check.mk) führt die Nachpflege als **nummerierte Liste** und stellt
das `diff`-Kommando daneben, dessen Hunk-Zahl mit der Zahl der Handgriffe zusammenfällt. Heute
sind es vier —

```sh
D=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
diff <(docker run --rm --network none "ghcr.io/pt9912/d-check@$D" --print-mk) d-check.mk \
  | grep -c '^[0-9]'          # 4 — kein Erwartungswert, wandert mit jedem Handgriff
wc -l < d-check.mk            # 120   (Generat: 76, dieselbe Kette ohne diff)
```

— und die Marke wird zu Handgriff **5**. Diese Liste ist die Stelle, an der die Aussage eine
Regenerierung überlebt: Wer regeneriert, liest sie ab und trägt sie erneut ein.
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) deckt
die Nachpflege als bestehende Praxis; neu ist allein ihr Gegenstand.

### Reihenfolge — messen, dann schreiben

1. **Gegenprobe je C-Ziel fahren** (DoD 1). Sie entscheidet den Wortlaut des Deckungs-Absatzes
   und ob ein Ziel als *ohne Prüfbereich* oder als *Kandidaten-Regel unverstanden* eingeordnet
   wird. Vor ihr steht der Wortlaut nicht fest.
2. **Marke setzen** (DoD 2) — erst danach, weil das Literal auf den Absatz zeigt.
3. **Wächter und Mutations-Fall** (DoD 3), zuletzt: Er misst, was in 1 und 2 entstanden ist.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | DoD (2): Marke im `##`-Hilfetext von `doc-tracked` und `doc-structure`, dieselbe Marke als letzte Ausgabe-Zeile ihrer Rezepte, und — weil die Datei ein Generat ist — als **nummerierter Handgriff** im Adopter-Kopf samt mitgezogener Überschrift und neu gemessener Hunk-Zahl |
| [`harness/README.md`](../../../../harness/README.md) | update | DoD (1): Deckungs-Absatz in §Sensors — vier Klassen, Ableitungs-Regel, Gegenprobe je C-Ziel, Zeiger auf den `doc-commits`-Absatz weiter unten in derselben Datei |
| `test/<name>.bats` (neu) | neu | DoD (3): die abgeleitete Bijektion; `make test-bats` fährt `test/`, eine Registrierung entfällt |
| `test/mutations/<NNN>-<name>.sh` (neu) | neu | DoD (3): setzt ein drittes C-Ziel ohne Marke ein; `# files:` nennt `d-check.mk`, `# expect:` den bats-Fall |
| [`.d-check.yml`](../../../../.d-check.yml) | **unberührt** | Der Slice gibt keinem Modul einen Block und ändert `modules:` nicht (§1, Abgrenzung). Die Datei wird **gelesen** — sie ist die eine Hälfte der Ableitung — und nicht geschrieben. |

**Die nächste freie Fall-Nummer unter `test/mutations/` wird beim Anlegen gezogen, nicht hier
gesetzt:** `ls test/mutations/*.sh | grep -oE '/[0-9]+' | tr -d / | sort -n | tail -1` nennt die
höchste vergebene; zwischen diesem Schnitt und der Umsetzung kann sie wandern.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei — beobachtbar ohne Rückfrage:
`ls docs/plan/planning/in-progress/slice-*.md` findet nichts. Eine inhaltliche Vorbedingung
besteht **nicht**: Der Slice hängt an keinem anderen, weil er die Menge der C-Ziele **ableitet**
statt sie vorauszusetzen — er läuft vor wie nach
[slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md), nur mit anderem
Ergebnis (§6).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Ausgabe-Hälfte aus DoD (2) lässt
  sich am Text von [`d-check.mk`](../../../../d-check.mk) **nicht** prüfen und verlangt einen
  zweiten, lauf-gestützten Wächter. Dann sind es zwei Sensoren mit zwei Prüfbereichen und zwei
  Gegenbeispiel-Sätzen — der Schnitt ist falsch, nicht die DoD zu kurz.
- `in-progress` → `open` (blockiert — Carveout?): Die Gegenprobe aus DoD (1) fällt für **beide**
  C-Ziele so aus, dass keines als *ohne Prüfbereich* einzuordnen ist — etwa weil beide Module
  eingebaute Vorgaben tragen oder weil beide Kandidaten-Regeln unverstanden bleiben. Dann ist die
  C-Menge leer, der Wächter aus DoD (3) hätte einen leeren Prüfbereich
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  und die Frage, was ein Ziel ohne Prüfbereich überhaupt ist, gehört neu entschieden.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Drei beobachtbare Kriterien, jedes ohne Rückfrage entscheidbar:

1. **Die Ableitung und die Marken decken sich**, gemessen am Repo selbst: Das Kommando aus §1
   liefert die C-Menge, und jedes Ziel darin trägt die Marke im Hilfetext (`make doc-help` führt
   sie) und in der Ausgabe-Zeile seines Rezepts. Kein Ziel außerhalb der C-Menge trägt sie.
2. **`make gates` ist grün** und enthält den neuen bats-Fall — `make test-bats` fährt `test/`, der
   Fall ist also mitgelaufen und nicht bloß vorhanden.
3. **Die drei Rot-Lagen aus DoD (3) stehen mit Kommando und Ausgabe im Umsetzungs-Commit**, und
   `make mutate` zieht den neuen Fall unter `test/mutations/` ohne Befund.

Dazu ein **Lerneintrag** in einer der drei Formen (geschärfte Regel · neuer Sensor · benannte
Spec-Lücke). Ein unabhängiger Review liegt vor (§2).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die C-Menge schrumpft während der Umsetzung.** Landet
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) vorher, trägt
  [`.d-check.yml`](../../../../.d-check.yml) einen `structure:`-Block, und `doc-structure` fällt
  aus der C-Menge. Der Wächter trägt das, weil er ableitet; **der Deckungs-Absatz und die Marke
  tun es nicht** — beide müssten dann für ein Ziel weniger geschrieben werden. Bleibt nur
  `doc-tracked` übrig, ist der Prüfbereich einelementig, aber nicht leer; wird er leer, greift die
  Rückführung aus §4. — **Ausgang: entfallen.**
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) liegt beim Abschluss
  weiter in `open/`, und [`.d-check.yml`](../../../../.d-check.yml) führt keinen `structure:`-Block
  (`grep -nE '^structure:' .d-check.yml` → Exit 1). Die C-Menge ist zweielementig geblieben —
  `doc-tracked`, `doc-structure` —, Deckungs-Absatz und Marke sind für beide geschrieben. Mit
  diesem Abschluss ist das Umsetzungs-Fenster zu, in dem das Risiko eintreten konnte. Der Fall
  **nach** slice-213 ist nicht offen, sondern bewacht: Lage *(c)* der Rot-Sätze setzt genau ihn und
  färbt rot, damit die dann falsche Marke nicht stehen bleibt
- **Die Ableitung sieht nur `--enable`.** Ein künftiges Ziel, das ein Modul auf anderem Weg
  zuschaltet — eigene `--config`-Datei, ein per Vorgabe aktives Modul —, fällt aus der
  Bezugsmenge, ohne dass ein Lauf davon spricht. Der Wächter wäre dann grün über einer Menge, die
  den Fall nicht enthält. — **Ausgang: weiter offen → Beobachtungs-Register,
  [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (jetzt **13×**, `evidence/slice-217.md`).** Die Zusage nennt die Menge *„die C-Klasse"* und
  definiert sie als *Modul zugeschaltet, kein Block dafür*; gemessen wird der engere Ausschnitt
  *per `--enable` zugeschaltet*. Heute ist die Verengung folgenlos — jedes der **13** Ziele
  (`grep -cE '^docs?-[a-z-]+:.*## ' d-check.mk`) schaltet sein Modul per `--enable` zu —, und
  **benannt ist sie nirgends**: weder im Kopf des Wächters noch neben der Zusage. Sie geht darum
  als Fund in denselben Beleg wie die zwei Ausgabe-Funde; ein Vorgang zählt einmal
- **Die Block-Frage misst Anwesenheit, nicht Wirksamkeit.** `grep -qE "^<modul>:"` sagt, dass ein
  Schlüssel dasteht — nicht, dass er das Modul aktiviert. Ein Block, dem der
  Aktivierungs-Schlüssel fehlt, gälte als Prüfbereich. Dieselbe Grenze trägt heute schon
  `test/mutations/285-closure-dir-entfernt.sh` für `closure.dir`, und sie ist dort mit einem
  eigenen Fall bewacht statt in die Ableitung gezogen. — **Ausgang: weiter offen →
  Beobachtungs-Register,
  [`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (derselbe Beleg `evidence/slice-217.md`, kein zweiter — zwei Funde im selben Vorgang sind eine
  Gelegenheit).** Es ist dieselbe Klasse wie das Risiko darüber, an der anderen Hälfte derselben
  Ableitung: Die Zusage sagt *Prüfbereich*, gemessen wird *Schlüssel vorhanden*. Heute folgenlos —
  jeder Top-Level-Block in [`.d-check.yml`](../../../../.d-check.yml) trägt seinen
  Aktivierungs-Schlüssel —, und ebenfalls nirgends benannt
- **Die Ausgabe-Hälfte hängt am Exit-Code.** Steht die Hinweis-Zeile hinter dem `docker run`,
  läuft sie bei einem Abbruch nicht — und ein Abbruch ist genau der Fall, in dem das Ziel etwas zu
  melden hatte. Das ist verträglich (wer abbricht, meldet kein stilles Grün), aber es ist eine
  Grenze und gehört benannt statt verschwiegen. — **Ausgang: entfallen.** Die Grenze steht an
  **beiden** Trägern und im Indikativ: in
  [`harness/sensors/doc-structure.md`](../../../../harness/sensors/doc-structure.md) unmittelbar
  unter der Zusage, die sie einschränkt (*„Die Ausgabe-Hälfte gilt nur für einen Lauf ohne
  Befund"*, mit `doc-tracked` als dem erreichbaren Fall), und im Kopf von
  [`test/doc-block-marke-wiring.bats`](../../../../test/doc-block-marke-wiring.bats)
  (*„Was dieser Waechter NICHT erreicht"*). Das Risiko lautete auf *verschwiegen*, nicht auf
  *vorhanden*; verschwiegen ist sie nicht mehr
- **Die Regenerierungs-Falle.** [`d-check.mk`](../../../../d-check.mk) ist ein Generat, und der
  Generator ist config-blind (§1) — eine Neu-Erzeugung schreibt beide Hälften der Marke weg. Der
  Schutz ist der nummerierte Handgriff im Adopter-Kopf, und er ist **eine Leseanweisung, kein
  Sensor**: Wer regeneriert, ohne die Liste abzuarbeiten, verliert die Aussage still, und der
  Wächter aus DoD (3) meldet das erst beim nächsten `make gates` — also nach dem Vorgang, nicht
  währenddessen. Dazu die Zahlen-Hälfte: Die Hunk-Zahl im Kopf steht neben dem `diff`-Kommando;
  wer sie stehen lässt, hinterlässt die Klasse, die
  [`BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  führt (Stand beim Schnitt: **5×**,
  `ls docs/plan/planning/observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/evidence/*.md | wc -l`).
  — **Ausgang: eingetreten.** Die Zahlen-Hälfte trat im Umsetzungs-Commit ein: Der Kopf schrieb
  *„FUENF Handgriffe"* fort, das danebenstehende `diff … | grep -c '^[0-9]'` liefert **8** — Zahl
  und Kommando zählten zwei Gegenstände (Handgriffe gegen Hunks). Aufgelöst in der Nacharbeit; der
  Kopf nennt jetzt beide Zahlen mit ihrem Bezug, und der Abschluss hat den Wert unabhängig
  nachgefahren (**8**, Hunk-Köpfe `1,13c1,64 · 15c66 · 26,27c77,78 · 59c110 · 60a112 · 67c119 ·
  68a121 · 75,76c128,129`). **Kein Folge-Slice und kein Carveout:** Der Rest, den die eingetretene
  Hälfte hinterließe, ist keiner — die Zahl ist heute richtig, und die Regenerierungs-Hälfte ist
  gedeckt, nur spät: Wer die Liste nicht abarbeitet, verliert die Marke, und der Wächter aus
  DoD (3) färbt beim nächsten `make gates` rot. Das Auftreten ist als
  [`BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  gezählt (jetzt **6×**, `evidence/slice-217.md`)
- **Die Abhilfe liegt upstream und ist hier nur benannt.** Dass `--print-mk` die Konfiguration
  nicht liest, ist keine feste Werkzeug-Grenze: `d-check` ist ein Nachbar-Repo desselben Nutzers
  (`/Development/d-check`), und eine hier gemessene Generator-Lücke ist dort eine **Anforderung**.
  Solange sie offen ist, trägt dieses Repo die Nachpflege — und trüge sie auch dann noch, wenn
  ein künftiger Generator die Ziele config-abhängig ausgäbe, bis der Pin nachzieht. Der Punkt
  steht als Lücke im Plan und **nicht** als Kennung: Eine Slice-Kennung dieses Repos behauptete
  eine Datei, die es nicht gibt
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)),
  und über das Nachbar-Repo entscheidet dieser Slice nicht. — **Ausgang: weiter offen →
  Beobachtungs-Register,
  [`BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md)
  (neu, **1×**, `evidence/slice-217.md`).** Die drei Ausgänge sind eine geschlossene Menge, und
  *eingetreten* wie *entfallen* sind hier beide falsch: Die Lücke ist am Abschluss-Tag erneut
  gemessen (13 Ziele mit wie ohne `--config`, Ausgabe byte-gleich) und besteht fort; die lokale
  Folge ist getragen, die Ursache nicht. Der Eintrag hängt sie an den Zähler, statt einen zweiten
  Mechanismus zu erfinden — er führt daneben den zweiten gemessenen Fall derselben Klasse, das am
  gepinnten Stand unbedienbare `make doc-commits`, als *benannt, nicht gezählt*
- **Der neue Wächter kann von einer berechtigten Änderung entwaffnet werden.** Nimmt ein späterer
  Slice die Marke aus einem Rezept, weil das Ziel einen Block bekommen hat, bleibt der
  Mutations-Fall aus DoD (3) formal grün — er setzt ein *drittes* Ziel ein und hängt nicht an den
  heutigen zwei. Das ist die gewollte Bauart, aber die Nachbarklasse
  [`BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  (Stand beim Schnitt: **3×**,
  `ls docs/plan/planning/observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/evidence/*.md | wc -l`)
  ist genau hier zu prüfen. — **Ausgang: entfallen**, und zwar gemessen statt begründet. Der
  Abschluss hat die Welt **nach**
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) an einer Kopie
  außerhalb des Repos hergestellt — `structure:`-Block in
  [`.d-check.yml`](../../../../.d-check.yml) ergänzt, Marke bei `doc-structure` in Hilfetext und
  Ausgabe entfernt — und darüber zweimal gefahren: ohne Mutation grün, mit
  `test/mutations/309-drittes-c-ziel-ohne-marke.sh` rot. Die berechtigte Änderung entwaffnet den
  Fall also nicht; er hängt an einem selbst eingesetzten dritten Ziel und nicht an den heutigen
  zwei. Der Register-Eintrag bleibt bei **3×** unberührt — ein Beleg für ein Auftreten, das es hier
  nicht gab, wäre eine falsche Erhöhung

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** Die **Ableitung statt Aufzählung**. Der Wächter zählt keinen Zielnamen
  auf, und das ist nicht bloß sauber, sondern gemessen tragend: `test/mutations/309` setzt ein
  *drittes* C-Ziel ein und färbt ihn rot, und derselbe Fall beißt auch über einer Kopie, in der
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) bereits stattgefunden
  hat (§6 Risiko 7). Ebenso getragen hat die Auflage aus §1, die **Null gegenzuprüfen** statt sie
  zu deuten: Die zwei C-Ziele fielen verschieden aus — `doc-structure` ist am eingesetzten Defekt
  inert, `doc-tracked` **nicht** —, und ohne die Gegenprobe hätte der Deckungs-Absatz für beide
  dasselbe behauptet. Die Marke trägt darum die ableitbare **Tatsache** und nicht das Verhalten;
  so kann sie nur an der einen Stelle falsch werden, an der der Wächter in seiner zweiten Richtung
  anschlägt.
- **Was ging anders als geplant:** Drei Dinge. **Erstens** hat ein gleichzeitig laufender Slice der
  Marke die Adresse weggezogen: Der Umsetzungs-Commit legte den Deckungs-Absatz in
  [`harness/README.md`](../../../../harness/README.md) an und zeigte darauf; sechs Commits später
  brachte [slice-114](../in-progress/slice-114-jede-aussage-hat-einen-abschnitt.md) dieselbe Datei auf die
  Ziel-Form und lagerte die Sensor-Prosa nach `harness/sensors/` aus. Kein Gate sprach davon — die
  Adresse ist Prosa in einem Makefile-Fragment —, gefunden hat es die zweite Review-Runde. Der
  Deckungs-Absatz aus DoD (1) liegt seither dort, wo die Ziel-Form ihn haben will, und die Marke
  zeigt auf die zwei Sensor-Dateien. **Zweitens** brauchte die Ausgabe-Hälfte zwei Runden, weil der
  Wächter zweimal hintereinander eine schwächere Eigenschaft maß als die Zusage daneben: erst
  Anwesenheit statt Position, dann Position ohne Form. **Drittens** trägt
  [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) §3 über die C-Ziele eine Aussage, die die
  Messung dieses Slice widerlegt — *„Heute melden sie ‚0 Befund(e)' und meinen ‚nichts geprüft'"*
  gilt für `doc-structure`, nicht für `doc-tracked`. Das ist ein Übergabe-Artefakt an den
  Closure-Lauf der Welle, kein Closure-Schritt dieses Slice
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
- **Steering-Loop-Eintrag:** *neuer Sensor.*
  [`test/doc-block-marke-wiring.bats`](../../../../test/doc-block-marke-wiring.bats) hält
  `{C-Ziele} == {Hilfetext-Marke} == {Ausgabe-Marke}` in beiden Richtungen, hermetisch (kein
  Docker, kein Netz) und über `make test-bats` in `make gates`; die C-Menge leitet er aus
  [`d-check.mk`](../../../../d-check.mk) und [`.d-check.yml`](../../../../.d-check.yml) ab.
  `test/mutations/309-drittes-c-ziel-ohne-marke.sh` nimmt ihm die Zähne. Ein Feld `liegt in` steht
  hier **nicht**: Verkörpert ist ein Sensor, keine Regel an einem Zielort, und der Herkunfts-Anker
  für eine über die Schwelle getretene Beobachtung wird von der Welle-Closure vergeben, nicht hier
  (Lese-Schritt, s. u.).
- **Beobachtungs-Register (`../observations/`):** Vier Belege, zwei davon in neuen Verzeichnissen —
  kein Zähler ist gesetzt, er folgt aus den Dateien.
  [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  (jetzt **6×**) ·
  [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (jetzt **13×**, drei Funde in einem Beleg — ein Vorgang zählt einmal) ·
  [`gleichzeitig-laufender-slice-macht-adresse-tot`](../observations/BEO-ALL/gleichzeitig-laufender-slice-macht-adresse-tot/observation.md)
  (neu, **1×**) ·
  [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md)
  (neu, **1×**). **Der Lese-Schritt gehört nicht hierher:** Dieses Repo fährt Wellen-Betrieb
  (`ls docs/plan/planning/welle-*.md | wc -l` → **3**, kein Erwartungswert), und *wellenlos* ist
  nach Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht eine Eigenschaft
  des **Repos**, nicht des einzelnen Slice. Diese Closure hat darum **gezählt und eingetragen und
  keinem Eintrag einen Ausgang zugewiesen**. Gemessen ist dabei: **kein** Eintrag tritt durch
  diesen Slice über die Schwelle — die drei, die §8 bei 2× als Kandidaten führte
  (`gruen-aussage-ohne-herkunft`, `vollstaendigkeits-zusage-misst-falsche-ebene`,
  `zusage-ohne-herstellbares-gegenbeispiel`), haben von hier keinen Beleg bekommen, weil keine der
  drei Klassen auftrat. Ein Folge-Slice aus einem 3×-Übertritt fällt damit nicht an.
- **Folge-Slices:** keiner geschnitten, und je Kandidat steht der Grund. Die Marke bei
  `doc-structure` wird fällig, sobald
  [slice-213](../open/slice-213-review-report-laeuft-in-der-tabellen-form.md) den `structure:`-Block
  schreibt — das braucht keinen eigenen Slice, weil der Wächter dann rot färbt und die Arbeit dort
  anfällt, wo sie entsteht. **`tracked` bekommt weiterhin keine Adresse, und das bleibt so:** Die
  Gegenprobe hat gezeigt, dass das Modul für seine Kernfrage keinen Block braucht — ein Slice, der
  ihm einen gäbe, hätte keinen gemessenen Anlass, und
  [slice-116](../open/slice-116-doku-gate-urteilt-ueber-den-getrackten-bestand.md) führt das Modul
  nicht (`grep -c 'tracked'` über seine Datei → **0**). Was aussteht, ist die **Aktivierung** von
  `tracked` in `modules:`, und die ist eine Gate-Bewegung mit eigener Messung
  ([`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)),
  kein Nachtrag zu diesem Slice. Die Generator-Lücke im Nachbar-Repo bekommt aus demselben Grund
  keine Kennung und stattdessen einen Register-Eintrag (§6).
- **Risiken aus §6:** alle sieben mit genau einem Ausgang — dreimal *entfallen* (C-Menge
  geschrumpft · Exit-Code-Grenze verschwiegen · Mutations-Fall entwaffnet), dreimal *weiter offen →
  Register* (nur `--enable` · Block-Anwesenheit statt -Wirksamkeit · Abhilfe upstream), einmal
  *eingetreten* (die Kopf-Zahl des Adopter-Kopfs, in der Nacharbeit aufgelöst).
- **Drei Paarungen:** dieses **Repo** fährt Wellen, und dieser Slice gehört zu
  [welle-13](../welle-13-regeln-bekommen-ihren-sensor.md) — Anker, Folge-Slice und Register prüft
  deren Closure. Die mechanisch entscheidbaren Hälften sind hier trotzdem gefahren, damit die
  Welle-Closure keinen Rest vorfindet, den dieser Slice hinterlassen hat: **(a) Anker** — kein
  Eintrag dieser Notiz trägt das Feld `liegt in`, die Paarung hat für diesen Slice keinen
  Gegenstand; **(b) Folge-Slice** — keiner genannt, der eine Datei behaupten könnte, außer den
  bestehenden Kennungen `slice-213` und `slice-116`, die beide in `open/` liegen; **(c) Register**
  — die vier zitierten Beobachtungs-Pfade lösen auf, und jedes der vier Verzeichnisse trägt
  mindestens eine Datei unter `evidence/`. **Ein Rest bleibt und gehört nicht diesem Slice:** Das
  Register führt ein Verzeichnis mit leerem `evidence/`
  ([`einstiegs-datei-weicht-von-der-pflichtgliederung-ab`](../observations/BEO-ALL/einstiegs-datei-weicht-von-der-pflichtgliederung-ab/observation.md)),
  das die zweite Hälfte von (c) verletzt; es stammt aus einem anderen Lauf und ist damit ein
  Übergabe-Artefakt an die Welle-Closure.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `d-check.mk` (Projektwurzel),
[`harness/README.md`](../../../../harness/README.md) und `test/`. Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) führt
`*` (`ALL`), `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`). Keiner der drei Pfade liegt in den
zwei engeren — die Berührung ist `*` (`ALL`). **`harness/tools/` ist ausdrücklich nicht berührt:**
Der Wächter aus DoD (3) entsteht als `test/*.bats` und nicht als Skript unter `harness/tools/`,
weil `make test-bats` das Verzeichnis `test/` als Ganzes fährt und damit weder ein neues
`make`-Ziel noch eine Gate-Tabellen-Zeile noch ein `exempt-targets`-Eintrag anfällt.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist
vollständig durchgegangen; jede Beobachtung dieses Repos trägt die Sub-Area `*` (gesamtes Repo).
Die Stände sind **gemessen**
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2 — ein Zähler-Stand ist eine datierte Messung, kein Wert im Text), Stand 2026-09-12:

```sh
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l   # 94  (kein Erwartungswert)
cd docs/plan/planning/observations/BEO-ALL
for d in zusage-neben-geaenderter-ableitung-bleibt-stehen \
         zusage-nennt-sensor-der-form-nicht-sieht \
         zahl-ohne-kommando-trifft-ihren-gegenstand-nicht \
         neuer-waechter-ohne-mutations-fall \
         mutations-fall-wird-von-berechtigter-aenderung-entwaffnet \
         gruen-aussage-ohne-herkunft \
         vollstaendigkeits-zusage-misst-falsche-ebene \
         zusage-ohne-herstellbares-gegenbeispiel \
         closure-kriterium-ohne-erreichbare-messstelle; do
  printf '%2s  %s\n' "$(ls $d/evidence/*.md | wc -l)" "$d"; done
# 22  zusage-neben-geaenderter-ableitung-bleibt-stehen
# 12  zusage-nennt-sensor-der-form-nicht-sieht
#  5  zahl-ohne-kommando-trifft-ihren-gegenstand-nicht
#  4  neuer-waechter-ohne-mutations-fall
#  3  mutations-fall-wird-von-berechtigter-aenderung-entwaffnet
#  2  gruen-aussage-ohne-herkunft
#  2  vollstaendigkeits-zusage-misst-falsche-ebene
#  2  zusage-ohne-herstellbares-gegenbeispiel
#  1  closure-kriterium-ohne-erreichbare-messstelle
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. **Neun berühren diesen
Slice**, und sie zerfallen in zwei Gruppen mit verschiedener Folge:

**Über der Schwelle, Ausgang bereits vergeben oder offen — sie binden den Entwurf, lösen aber
keinen Folge-Slice aus:**

- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (**22×**, `geplant`) — die Klasse in Reinform: Die Marke aus DoD (2) *ist* eine Zusage neben
  einer Ableitung, und wenn ein Block hinzukommt, bleibt sie stehen. **Genau darum hat der Wächter
  aus DoD (3) zwei Richtungen**; Lage *(c)* der Rot-Sätze ist diese Beobachtung, hergestellt.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (**12×**, `geplant`) — sie trägt die Entscheidung aus §1, dass die Marke die **Tatsache** nennt
  und nicht das Verhalten: Eine Marke, die *„nichts geprüft"* behauptete, nennte eine Eigenschaft,
  die ihr eigener Wächter nicht misst.
- [`zahl-ohne-kommando-trifft-ihren-gegenstand-nicht`](../observations/BEO-ALL/zahl-ohne-kommando-trifft-ihren-gegenstand-nicht/observation.md)
  (**5×**, `offen`) — Risiko 5 in §6: der abgezählte Adopter-Kopf von `d-check.mk`.
- [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (**4×**, `offen`) — DoD (3) verlangt den Fall unter `test/mutations/` ausdrücklich; ohne ihn
  wäre dieser Slice der fünfte Beleg.
- [`mutations-fall-wird-von-berechtigter-aenderung-entwaffnet`](../observations/BEO-ALL/mutations-fall-wird-von-berechtigter-aenderung-entwaffnet/observation.md)
  (**3×**, `offen`) — Risiko 6 in §6; der Fall setzt darum ein **drittes** Ziel ein statt an den
  heutigen zwei zu hängen.

**Unter der Schwelle bei 2× — und hier liegt eine Ansage an die Umsetzung:** Fällt in diesem Slice
ein belegbares Auftreten einer dieser drei an, erreicht der Eintrag **mit ihm** 3× und ist keine
Notiz mehr, sondern eine Lücke mit eigenem Folge-Slice (Baseline-Regelwerk
`modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung).

- [`gruen-aussage-ohne-herkunft`](../observations/BEO-ALL/gruen-aussage-ohne-herkunft/observation.md)
  (**2×**, `offen`) — das Welle-Ziel selbst; die Gegenprobe aus DoD (1) ist der Versuch, es hier
  **nicht** zu wiederholen.
- [`vollstaendigkeits-zusage-misst-falsche-ebene`](../observations/BEO-ALL/vollstaendigkeits-zusage-misst-falsche-ebene/observation.md)
  (**2×**, `offen`) — der Deckungs-Absatz sagt *„jedes Ziel"* und misst die Ziele in `d-check.mk`,
  nicht die Module des Bildes; wer die zwei Ebenen verwechselt, erzeugt diese Klasse.
- [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  (**2×**, `offen`) — die Lage, in der die Gegenprobe für ein C-Ziel kein Rot hergibt; §1 gibt ihr
  darum den dritten Ausgang *„Kandidaten-Regel unverstanden"*.

**Eine neunte steht bei 1×:**
[`closure-kriterium-ohne-erreichbare-messstelle`](../observations/BEO-ALL/closure-kriterium-ohne-erreichbare-messstelle/observation.md)
(**1×**, `offen`) — sie betrifft das welle-eigene Kriterium, das dieser Slice erfüllt; er ist die
Messstelle, die es erreichbar macht.

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF; ein Begründungsblock entfällt
damit. Die Sub-Area `*` (`ALL`) ist in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) als
**Greenfield** deklariert: Doc führt, Code folgt, Graduation `n/a`.
