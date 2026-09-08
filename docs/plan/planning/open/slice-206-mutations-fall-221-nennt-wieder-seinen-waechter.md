# Slice slice-206: Der Mutations-Fall `221` nennt wieder den Titel seines Wächters

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Der Slice repariert **eine** Zeile und belegt sie mit dem Lauf, der sie
prüft; ein Closure-Trigger darüber schriebe seine eigene DoD ab (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Ebene: Dogfood, nicht emittiert.** Gegenstand ist der Mutations-Satz **dieses** Repos unter
`test/mutations/`. Ein Zielrepo bekommt ihn nicht.

**Bezug:** [`AGENTS.md`](../../../../AGENTS.md) §3.6 — `make mutate` ist der Sensor dieser Hard
Rule, und ein Fall, dessen `# expect:`-Zeile ihren Wächter nicht mehr trifft, misst die
Haltbarkeit von dessen Zähnen nicht mehr;
[`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md) (`Accepted`,
Beleg statt Lauf — als **Constraint**: der Slice darf den Beleg-Mechanismus nicht umgehen, und er
darf ihm den Fund auch nicht anlasten; gemessen ist, dass ein roter Lauf keinen Beleg schreibt).

**Kein `LH-*` bindet, und das steht hier statt einer gedehnten Kennung.**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) fordert
wörtlich, dass jeder **emittierte** Gate-Target auf frischem Checkout läuft; `make mutate` ist
weder emittiert noch ein Gate ([`harness/README.md`](../../../../harness/README.md)
§Nicht-Gate-Verify). Die Bindung dieses Slice ist eine Hard Rule, kein Lastenheft-Posten.

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle).

**Verantwortlich:** — (bis zur Priorisierung).

**Autor:** Planner. **Datum:** 2026-09-08.

---

## 1. Ziel und Abgrenzung

**Ziel:** Die `# expect:`-Zeile von `test/mutations/221-ignore-refs-restbreite.sh` zitiert wieder
den Titel, den ihr Wächter heute trägt — und `make mutate` meldet über den vollen Satz
`0 Befund(e)` statt `1 Befund(e)` mit dem Grund *„falscher Grund"*.

Der Fund stammt aus dem Review zu `slice-127` und ist dort dreifach gemessen: Der Wächter unter
`221` **hat seine Zähne behalten** (die Mutation färbt ihn rot), der Treiber meldet die
Nichtübereinstimmung **fail-closed** statt still durchzuwinken, und es ist die **einzige** stale
Zeile des Satzes. Zu reparieren ist damit die Buchhaltung eines Falls, nicht ein Wächter und nicht
der Treiber. Am Baum abgelesen:

```sh
grep -n '# expect:' test/mutations/221-ignore-refs-restbreite.sh
#   …deckt hoechstens einen Markdown-Link ihrer Quelldatei
grep -n 'deckt genau die an ihr deklarierte' test/ignore-refs-restbreite.bats
#   …deckt genau die an ihr deklarierte Anzahl Markdown-Links
```

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Kopplungs-Wächter zwischen `# expect:`-Zeile und Wächter-Titel.** Das wäre ein neuer
  Sensor und damit Gate-*Anheben*, das nach
  [`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
  über den Steering Loop läuft. Die Klasse steht als
  [`BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters`](../observations/BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters/observation.md)
  bei **1×** und damit unter der Schwelle — ein Sensor jetzt nähme dem Zähler seinen Gegenstand,
  bevor er etwas gezeigt hat. *(Es wäre ein anderer Vorgang.)*
- **Keine Änderung an `test/ignore-refs-restbreite.bats` und an der Regel, die er hält.** Sein Rot
  ist gemessen intakt; wer den Wächter an seine alte Bezeichnung zurückdreht, repariert nicht die
  Buchhaltung, sondern verschiebt den Gegenstand — und macht die Schärfung rückgängig, die
  `slice-197` ausdrücklich vorgenommen hat. *(Bestand bleibt bewusst stehen.)*
- **Keine Durchsicht der übrigen `# expect:`-Zeilen.** Die Vollständigkeits-Messung über alle
  Fall-Dateien liegt vor und nennt genau eine stale Zeile; sie hier zu wiederholen prüfte eine
  Eigenschaft neu, die schon gemessen ist. Zeigt der Lauf in DoD (2) einen **zweiten** Befund, ist
  das der Gegenbeweis und gehört als eigener Vorgang aufgenommen, nicht in diesen Slice gezogen.
  *(Es wäre ein anderer Vorgang.)*
- **Kein Produkt-Code, keine ADR, kein `AGENTS.md` §3 und kein `harness/conventions*`.** Der Slice
  ändert eine Test-Fixture; die Norm-Artefakte gehören dem Architect
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8). *(Schicht-Abgrenzung.)*

## 2. Definition of Done

Zwei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3).

- [ ] **(1) Der Fall färbt seinen Wächter aus dem richtigen Grund rot.** Die `# expect:`-Zeile
      zitiert eine Zeichenkette, die in der Fehlschlag-Zeile des Wächters wirklich vorkommt.
      **Rot:** der Zustand vor dieser Änderung — `make mutate` meldet
      `BEFUND 221-ignore-refs-restbreite … rot, aber '<zitierter Titel>' faellt nicht — falscher
      Grund`. Er ist bereits rot gesehen (Review und Verifikation zu `slice-127`, unabhängig
      voneinander); der Slice muss ihn nicht erst herstellen, sondern zum Verschwinden bringen.
- [ ] **(2) Der volle Satz läuft ohne Befund.** **Rot:** `make mutate` meldet `≥ 1 Befund(e)`.
      **Gefahren wird der volle Satz, nicht der Einzelfall** — ein Lauf über `221` allein belegt
      diesen Punkt nicht, weil er über den Rest des Satzes nichts sagt; und `MUTATE_FORCE=1`
      gehört dazu, wenn ein Beleg aus einem früheren Lauf den Satz sonst überspringt
      ([`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · `make mutate` ohne Befund
(hier zugleich DoD (2) — der Slice **ist** die Reparatur dieses Punktes) · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `test/mutations/221-ignore-refs-restbreite.sh` | update | die `# expect:`-Zeile auf den heutigen Wächter-Titel ziehen — die einzige inhaltliche Änderung des Slice |
| `test/ignore-refs-restbreite.bats` | **prüfen, nicht ändern** | der Titel ist die Quelle, nach der sich die Fixture richtet; wer ihn anpasst, dreht die Richtung um |
| [`harness/README.md`](../../../../harness/README.md) | **prüfen** | trägt die Datei eine Aussage über den Fall-Satz, die durch die Reparatur falsch wird? Wenn nein, bleibt sie unangetastet |

## 4. Trigger

**Start** (`next` → `in-progress`): WIP-Limit frei; der `git mv` landet auf dem Hauptzweig **vor**
der Arbeit (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Lauf in DoD (2) meldet weitere
  Befunde derselben Klasse, sodass aus einer Zeile ein Durchgang über den Satz wird. Dann ist der
  Gegenstand eine Menge und nicht mehr ein Fall, und der Schnitt gehört neu gemacht.
- `in-progress` → `open` (blockiert — Carveout?): der volle Lauf ist im verfügbaren Zeitrahmen
  nicht durchzubringen, sodass DoD (2) unbelegbar bleibt. Der Punkt ohne Beleg abzuhaken wäre die
  Zusage ohne Gegenbeispiel, gegen die [`AGENTS.md`](../../../../AGENTS.md) §3.6 steht.

## 5. Closure-Trigger

DoD (1) und (2) erfüllt mit gefahrenen Kommandos, `make gates` grün, Review nach Modul 10 und
Verifikation nach Modul 11 ohne blockierenden Befund, Closure-Notiz in §7 mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Der belegende Lauf ist teuer und an keinen lokalen Auslöser gebunden.** Der volle Satz lief
  zuletzt rund 30 Minuten; genau deshalb blieb der Fund über mehrere Vorgänge unentdeckt. Ein Lauf,
  der aus Zeitgründen auf den Einzelfall zusammenschnurrt, belegt DoD (2) nicht.
- **Der Beleg-Mechanismus könnte den Satz überspringen.** Gemessen ist das Gegenteil — ein roter
  Lauf schreibt keinen Beleg, und die Bezugsmenge des Schlüssels enthält die geänderte Datei —,
  aber die Prüfung gehört in den Lauf und nicht in diese Zeile.
- **Der Wächter-Titel kann sich erneut bewegen, bevor dieser Slice läuft.** Dann repariert die
  Fixture gegen einen Stand, den der Baum nicht mehr trägt; der Titel ist unmittelbar vor der
  Änderung abzulesen, nicht aus diesem Plan zu übernehmen.

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`) aus
der Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md). Die zwei
engeren deklarierten Sub-Areas (`harness/tools/`, `.codex/`) sind nicht berührt: der Slice fasst
eine Datei unter `test/mutations/` an. Eine eigene Sub-Area für den Mutations-Satz zu erfinden,
verfehlte das Inklusionskriterium — sie trüge keine eigene Konventions-Linie.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, Zähler als Dateizahl
abgelesen (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`, **keine
Erwartungswerte**). Drei Treffer betreffen diesen Gegenstand:
[`mutations-fall-ueberlebt-die-umbenennung-seines-waechters`](../observations/BEO-ALL/mutations-fall-ueberlebt-die-umbenennung-seines-waechters/observation.md)
**1×** (die Klasse, die dieser Slice im Einzelfall behebt — der Zähler bleibt davon unberührt,
weil eine Reparatur kein Auftreten ist),
[`mutations-fall-zeigt-auf-falsche-datei`](../observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/observation.md)
**2×** (die Nachbarklasse mit entgegengesetzter Fehlerrichtung — still statt laut; sie ist hier
nicht berührt, steht aber unter der Schwelle und wandert mit) und
[`roter-nicht-gate-sensor-ohne-instrument`](../observations/BEO-ALL/roter-nicht-gate-sensor-ohne-instrument/observation.md)
**1×** (die Lage, aus der dieser Slice entstand: ein roter Nicht-Gate-Sensor ohne Form in der
Closure). **Keiner der drei erreicht mit diesem Slice 3×**, keiner ist damit eine Lücke; das
Evidenz-Risiko unten liest sie als Hinweis, nicht als Auflage.

**Modus-Begründungsblock:** entfällt — alle berührten Sub-Areas sind GF. `test/mutations/` liegt
innerhalb von `*` (ALL, Greenfield: Doc führt, Code folgt); der Slice legt keine neue Sub-Area an
und berührt keine in BF oder Hybrid.
