# Slice slice-143: Der datei-weite Ausschluss weicht dem Referenz-Ventil, und der Satz, der ihn trug, fällt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — der Schnitt-Test aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1, alle drei Fragen beantwortet. **Bündel?** Nein — eine Entscheidung, eine Config-Zeile,
ein Kommentar; einzeln lieferbar. **Gemeinsames Closure-Kriterium?** Nein — jedes wäre die
Abschrift seiner eigenen DoD. **Auslöser reaktiv oder gewollt?** Reaktiv: eine Aussage über den
Doku-Gate ist gemessen falsch, und auf ihr steht eine Senkung, die breiter ist als nötig (§1).
**Der Gegenstand stammt nicht aus dem Re-Baseline-Delta**, obwohl er an ihm sichtbar wurde: die
Fähigkeit, um die es geht, liegt seit d-check `[0.49.0]` vor und ist von jedem Baseline-Stand
unabhängig. Er belegt darum kein Closure-Kriterium von [welle-10](../welle-10-re-baseline.md) §3.
Nach
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2 steht wellenlose Arbeit **nicht** in der Roadmap; ihr Zustand ist das Verzeichnis.

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
datei-weiter Ausschluss tauscht einen sichtbaren Befund gegen einen blinden Fleck — die Kehrseite
des halluzinierten Gates),
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) (die Entscheidung,
deren Kontext-Tabelle den gefallenen Satz trägt),
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) (die zwei bestehenden
Referenz-Ventile und ihre extensionale Aufnahme-Grenze),
[`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand)
(der Eintrag, der den geltenden Werkzeug-Stand hält),
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
(der Schnitt-Test oben),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (eine **Verschärfung** braucht kein ADR — die Frage ist
trotzdem eine Architektur-Frage, weil sie eine angenommene Entscheidung einengt) und §3.8 (die
schreibende Rolle).

**Berührte Spec-Stellen:** `—`. Der Slice bewegt eine Gate-Config und eine
Architektur-Entscheidung, keine Spec-Stelle.

**Verantwortlich:** — bis zur Priorisierung. Der tragende Liefergegenstand ist eine ADR, und die
schreibt nach [`AGENTS.md`](../../../../AGENTS.md) §3.8 der **Architect**; die Config-Zeile
gehört dem Implementer (§3).

**Autor:** Planner. **Datum:** 2026-08-30.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Die eine unbehebbare Referenz in
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) fällt aus der Prüfung, die Datei nicht
— und der Satz, mit dem der datei-weite Ausschluss begründet ist, steht nirgends mehr als
geltender.**

### Der Befund: eine Senkung, die auf einer falschen Aussage über das Werkzeug steht

[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) nimmt
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) **datei-weit** aus dem Doku-Gate. Ihre
Kontext-Tabelle trägt die Begründung, und die ist eine Aussage über eine Menge:

```sh
grep -c '^| \*\*`links`\*\* | \*\*keines\*\* | \*\*keines\*\* |'   docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md   # 1
grep -c '^| \*\*`anchors`\*\* | \*\*keines\*\* | \*\*keines\*\* |' docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md   # 1
```

Für `links` und `anchors` steht in **beiden** Ventil-Spalten *„keines"*. Derselbe Satz steht im
Config-Kommentar, der den Eintrag trägt: `sed -n '23,24p' .d-check.yml` gibt
*„…weil links und anchors keine Options-Sektion tragen — der referenz-weite Knopf existiert
nicht"*.

**Der Knopf existiert, und er ist älter als die Entscheidung, die ihn für abwesend erklärt.**
`ignore-refs` steht seit d-check `[0.49.0]` als querschnittlicher **Top-Level**-Schlüssel, den
`links`, `anchors` und `codepaths` gemeinsam honorieren;
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) hat gegen `v0.62.0`
gemessen. Gesucht worden war der **modul-lokale** `links.ignore-refs`, und aus seiner Abwesenheit
im `--print-config` wurde auf die fehlende **Fähigkeit** geschlossen — jene Ausgabe ist eine
kommentierte Beispiel-Config und keine Schema-Liste. Den geltenden Stand hält
[`MR-034`](../../../../harness/conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand);
zwei Ventile fahren am gepinnten `v0.65.0` produktiv
([`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md)).

### Was der Ausschluss kostet, und der Preis ist gemessen

Über eine Sonde erhoben — `scan.ignore` um den
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md)-Eintrag verkürzt, ein
`make docs-check`, danach zurückgenommen:

| Messung | Kommando | Wert |
|---|---|---|
| Link-Vorkommen in der ausgeschlossenen Datei | `grep -coE '\]\([^)]+\)' docs/plan/adr/0013-technik-stratum-als-zielort.md` | **27** |
| davon eindeutige Ziele | derselbe Strom durch `sort -u \| wc -l` | **12** |
| Befunde, wenn die Datei geprüft wird | `make docs-check`, Zeilen mit dem Datei-Präfix | **1** |
| geprüfte Datei-Zahl mit Ausschluss / ohne | `make docs-check`, erste Zahl | **+1** ohne |

**Der Ausschluss nimmt 27 Link-Vorkommen aus der Prüfung, um einen Befund stillzulegen.** Der eine
Befund ist `docs/plan/adr/0013-…:48 → ../../../.harness/baseline/v3.5.2/regelwerk/grundlagen-konventionen.md#…`
(Tree-Operand nach [slice-131](../open/slice-131-praesens-aussage-gegen-den-gepinnten-stand.md)
§1: byte-genaues Zitat einer Zeile aus dem `Accepted`-Artefakt
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) selbst, das §3.4 gegen Reparatur
sperrt — die Adresse bleibt `v3.5.2`, weil sie den eingefrorenen Bestand beschreibt, nicht den
heute ausgelieferten Baum)
— dieselbe Klasse wie die zwei bereits ausgenommenen Referenzen: ein Markdown-Link in den
abgelösten Baum, in einem `Accepted`-Artefakt, das
[`AGENTS.md`](../../../../AGENTS.md) §3.4 gegen jede Reparatur sperrt. **Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle vier Werte wandern mit dem Bestand und werden im Lauf neu erhoben.

### Es ist eine Verschärfung, und sie berührt trotzdem eine angenommene Entscheidung

`AGENTS.md` §3.5 regelt **Senkungen**. Hier wächst der Prüfbereich: eine Datei kommt zurück, 26
von 27 Link-Vorkommen werden wieder bewacht, und was fällt, ist genau eine Referenz. Ein ADR
verlangt die Regel dafür nicht. **Zwei Gründe sprechen trotzdem für eines**, und der Lauf wägt sie
gegen den dritten ab: [`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
ist *Accepted* und wird durch die Verengung ihres Gegenstands in ihrer Wirkung eingeschränkt —
ändern darf sie niemand, ablösen nur eine neue Entscheidung (§3.4); und ein drittes
`ignore-refs`-Paar überschreitet die **Aufnahme-Grenze**, die
[`ADR-0026`](../../adr/0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) und
[`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) je extensional gezogen haben —
*„auch dann, wenn es dieselbe Bedingung erfüllt"*. Der dritte Grund steht dagegen: eine ADR für
jede Config-Zeile macht das Instrument stumpf. **Die Abwägung gehört in den Lauf und in ein
Architect-Artefakt, nicht in diesen Plan.**

### Der Config-Kommentar gehört in denselben Schnitt, nicht in einen eigenen

`.d-check.yml` trägt den gefallenen Satz in den Zeilen, die den Ausschluss begründen. Wer den
Eintrag verengt und den Kommentar stehen lässt, hinterlässt eine Begründung, die ihren Gegenstand
nicht mehr beschreibt — und ein Kommentar beschreibt, was da ist
([`AGENTS.md`](../../../../AGENTS.md) §3.7). Ein eigener Schnitt dafür hätte keinen eigenen
Gegenstand.

### Was dieser Slice nicht ist

Er ist **nicht** die Reparatur des Links in
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) — das Artefakt bleibt byte-gleich. Er
ist **nicht** die Rücknahme von
[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md): jene bleibt stehen,
wie jede angenommene Entscheidung, und was sich ändert, ist der Mechanismus, mit dem ihr Zweck
erreicht wird. Und er ist **nicht** der Ort, an dem ein Planner-Lauf die ADR schreibt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **(1) Der Prüfbereich ist gewachsen, und zwar gemessen, nicht behauptet.** Zwei Läufe von
      `make docs-check` über demselben Baum — einer mit dem Config-Stand des Abschlusses, einer mit
      dem davor: **beide melden 0 Befunde**, und die **Datei-Zahl des ersten ist um eins größer**.
      Verglichen werden die zwei Ausgaben, nicht eine gemerkte Zahl; welche Zahl es ist, sagt der
      Lauf. Dazu, je an einer roten Gegenprobe, beide Skopen des neuen Ventils — ein anderes `in`
      und ein anderes `refs` bringen den Befund je zurück.
- [ ] **(2) Die Entscheidung über den Instrument-Wechsel liegt in einem Artefakt ihrer
      schreibenden Rolle.** Die Abwägung aus §1 — Verschärfung ohne ADR-Pflicht gegen die
      Einschränkung einer *Accepted*-Entscheidung und die überschrittene Aufnahme-Grenze — ist
      **entschieden**, nicht offengelassen, und der Ausgang steht in einem Architect-Artefakt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.8): entweder eine neue ADR, oder ein begründeter
      Vermerk, warum keine nötig ist. **Ein Ergebnis, das nur in diesem Plan steht, erfüllt den
      Punkt nicht.**
- [ ] **(3) Der Config-Kommentar beschreibt den Eintrag, der dort steht.** Adressiert ist genau
      eine Datei — [`.d-check.yml`](../../../../.d-check.yml) —, und der Ziel-Zustand ist: der
      Kommentar am `scan.ignore`-Eintrag nennt dessen heutigen Umfang und seine Begründung, der
      Kommentar am neuen `ignore-refs`-Paar nennt seine und zeigt auf das Artefakt aus DoD (2).
      **Der Punkt ist über die Adresse und den Ziel-Zustand gefasst, nicht über den Wortlaut des
      Defekts** — ein Kriterium der Form *„die Zeichenkette X kommt nirgends mehr vor"* fände sich
      im Plan wieder, der X zitiert, und wäre nach korrekter Reparatur weiter rot.
      **[`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) bleibt
      byte-gleich** — sie ist *Accepted* ([`AGENTS.md`](../../../../AGENTS.md) §3.4), ihre
      Kontext-Tabelle ist die richtige Aussage über den Stand ihres Datums, und was heute gilt,
      steht im Artefakt aus DoD (2). **Welche lebenden Artefakte den gefallenen Satz sonst noch
      tragen, erhebt der Lauf neu**; beim Schnitt war es außer der Config keines, und die Zahl
      wandert ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
      Setzung 2).
- [ ] `make gates` grün.
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register fortgeschrieben: neue `BEO-<NNN>` oder Zähler +1 mit Beleg in
      [`observations.md`](../observations.md) — *keine Beobachtung angefallen* ist ebenfalls eine
      Antwort und wird in §7 notiert. Das Reconciliation-Register entfällt dauerhaft: dieses Repo
      hat keinen Brownfield-Bootstrap.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) prüft die nächste Welle-Closure, nicht
      dieser Slice — dieses Repo fährt Wellen-Betrieb, und das gilt auch für wellenlose Slices.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/plan/adr/` | **ggf. neu**, durch den Architect | der Ausgang aus DoD (2); dazu die Zeile im ADR-Index, der derselben Rolle gehört ([`ADR-0024`](../../adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| [`.d-check.yml`](../../../../.d-check.yml) | update, durch den Implementer | der `scan.ignore`-Eintrag verliert die Datei, der `ignore-refs`-Block bekommt ein Paar, und beide Kommentare beschreiben, was dort steht (DoD (3)) |
| [`ADR-0017`](../../adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) | **unangetastet** | *Accepted*, [`AGENTS.md`](../../../../AGENTS.md) §3.4 |
| [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) | **unangetastet** | dasselbe; der Slice nimmt die Referenz aus, er repariert sie nicht |

**Der Commit-Zuschnitt folgt den Rollen:** ein Architect-Commit für DoD (2), der ausschließlich
Artefakte dieser Rolle berührt ([`AGENTS.md`](../../../../AGENTS.md) §3.8), danach ein
Implementer-Commit für Config und Kommentar, zuletzt die Planner-Closure.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): ein Architect-Lauf steht bereit — die Abwägung aus DoD (2)
gehört seiner Rolle. Eine technische Vorbedingung hat der Slice nicht; das Ventil trägt am
gepinnten Stand, und zwei Paare fahren produktiv.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung aus DoD (1) mehr als
  eine unbehebbare Referenz in
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) findet. Dann ist der Gegenstand eine
  **Häufung** in einer Datei, ein Paar je Referenz wäre eine Kaskade, und die Frage nach der Wurzel
  — bindet [`AGENTS.md`](../../../../AGENTS.md) §3.4 das Artefakt oder seine Aussage? — bekommt
  ihren eigenen Schnitt.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Abwägung aus DoD (2) zu dem Ergebnis
  kommt, dass die Aufnahme-Grenze der zwei bestehenden Ventile den Fall gar nicht zulässt, ohne
  dass zuerst über die Grenze selbst entschieden wird. Dann steht eine Entscheidung über eine
  Entscheidung an, und die gehört vor diesen Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: **erstens** zwei Läufe von `make docs-check` über demselben Baum, die
**beide 0 Befunde** melden und deren Datei-Zahlen sich um **eins** unterscheiden — der Prüfbereich
ist gewachsen, und zwar um genau die Datei, die aus `scan.ignore` gefallen ist. **Zweitens** ein
Architect-Commit, der den Ausgang aus DoD (2) trägt und ausschließlich Artefakte dieser Rolle
berührt (`git log --stat`). Dazu die Closure-Notiz mit Steering-Loop-Lerneintrag und je Risiko aus
§6 genau ein Ausgang.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Verengung wird als Formalie behandelt, weil sie eine Verschärfung ist.**
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 verlangt für sie kein ADR, und daraus folgt leicht,
  dass sie keine Entscheidung braucht. Sie schränkt aber die Wirkung einer angenommenen ADR ein
  und überschreitet die extensionale Aufnahme-Grenze zweier weiterer — beides
  Architektur-Fragen. — **Ausgang:** <entfallen: DoD (2) ist in einem Architect-Artefakt
  beantwortet | eingetreten: die Config-Zeile steht ohne Entscheidung und wird zurückgenommen>
- **Das dritte Ventil-Paar ist eines zu viel, wenn niemand die Wurzel fragt.** Drei Paare für
  drei Instanzen derselben Klasse — *„eine tote Adresse in einem eingefrorenen Artefakt"* — sind
  eine Kaskade, und `modul-07-carveouts.md` führt eine Häufung ausdrücklich nicht in eine. Die
  Wurzel ist die Frage, die [`ADR-0027`](../../adr/0027-tote-adresse-in-eingefrorener-adr.md) als
  Alternative `G` benennt und für ihren Lauf verwirft. — **Ausgang:** <entfallen: die Entscheidung
  wägt gegen die Wurzel ab und begründet, warum das Instrument trotzdem passt | eingetreten: die
  Wurzel-Frage bekommt einen eigenen Schnitt>
- **Der Gewinn wird an der falschen Zahl gemessen.** *„26 Vorkommen kommen zurück in die
  Prüfung"* ist eine Aussage über Link-**Vorkommen**, nicht über Befunde: heute lösen sie alle
  auf, der Gewinn ist die künftige Wachsamkeit und nicht ein gefundener Fehler. Wer ihn als
  Fehlerzahl darstellt, verspricht etwas, das die Messung nicht hergibt. — **Ausgang:**
  <entfallen: die Closure-Notiz trennt Vorkommen von Befunden und nennt je das Kommando |
  eingetreten: die Aussage wird eingeschränkt>
- **Die Sonde misst über einem Baum, der sich bewegt hat.** Die vier Werte in §1 stammen aus einem
  Lauf am 2026-08-30; jede seither hinzugekommene Datei bewegt die Datei-Zahl, jeder Edit an
  [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) die Link-Zahl — Letzterer ist durch
  §3.4 zwar ausgeschlossen, Ersterer nicht. — **Ausgang:** <entfallen: alle vier Werte sind im
  Lauf neu erhoben und stehen je neben ihrem Kommando | eingetreten: die Zahlen aus §1 sind als
  Eingabe kenntlich und nicht als Beleg verwendet>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `docs/plan/adr/` und die Gate-Config im
Wurzelverzeichnis. Beide fallen unter den Eintrag `*` (gesamtes Repo) der Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) —
**alle berührten Sub-Areas GF**, der Modus-Begründungsblock entfällt damit nach dem
*Umfang*-Absatz oben.

**Vorgelagert — offene Beobachtungen sichten:** die Sichtung ist **offen** — sie ist vor der
Bearbeitung gegen [`observations.md`](../observations.md) zu fahren, und ihr Ergebnis gehört ins
Kriterium *Evidenz-/Diskrepanz-Risiko* unten. Sie steht hier nicht als Ergebnis, weil der Stand des
Registers zwischen Schnitt und Bearbeitung wandert.
