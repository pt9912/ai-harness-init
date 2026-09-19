# Slice slice-releasing-doku-traegt-den-release-vorgang: `releasing.md` trägt den Release-Vorgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als
diese DoD — `make docs-check` grün und die Review-Prüfung der Prozedur-Form
sind Belege der Liefer-Punkte selbst; ein repo-weites Mehr über sie hinaus
existiert nicht.

**Bezug:**
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die Plattform-Matrix — die Prozedur baut die Assets über
`make release-artifacts`),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(der Tag trägt den Gates-Beleg seines Baums — genau das, was die Klasse der
drei Fundstellen vermisste),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 (die Tag-Kopplung: Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(`SHA256SUMS` reist als Release-Asset),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl in der neuen Datei trägt ihr Kommando im selben Absatz),
[Register-Beleg](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md)
(trägt zwei der drei Fundstellen der Klasse);
Setzung des Auftraggebers vom 2026-09-19: `releasing.md` trägt den
Release-Vorgang, der Release-Text einzelner Releases folgt der Stand-Form, und
die zwei Disziplin-Zeilen (Gates am Tag-Baum vor dem Tag-Push · CI am Tag
abwarten, bevor der Schnitt vollzogen gemeldet wird) sind harte Schritte der
Prozedur.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-19.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Release-Vorgang liegt in einem Artefakt: `releasing.md`
trägt die Prozedur des Release-Schnitts — Assets bauen (`make release-artifacts`,
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)), Digests
messen, `SHA256SUMS` erzeugen und als siebtes Asset publizieren
([`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)),
Tag-Kopplung im selben Vorgang
([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2), Release-Text nach Stand-Form (Zustand und Beleg als
auflösbarer Anker, keine Chronik), Start-Prüfung auf allen sechs Dateien
(die Zusagen des
[`benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) §Erstellung
eines Release), und die Grenze: kein Signier-Schritt — die Datei sagt sie,
sie baut sie nicht. Zwei Zeilen stehen als **harte Schritte der Prozedur**,
nicht als Box daneben: Gates am Tag-Baum vor dem Tag-Push; CI am Tag abwarten,
bevor der Schnitt vollzogen gemeldet wird.

**Die Klasse hinter den zwei Zeilen, mit ihren drei Fundstellen** — ein
ge-tagter/gepushter Stand trug keinen Gates-Beleg. Sie sind die Belegbasis des
Abschnitts in `releasing.md` (Liefer-Punkt 3), nicht Chronik im Prozedur-Text:

1. Die roten Pushes nach dem ersten beim `v0.2.0`-Vorfall — der
   [Register-Beleg](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md)
   trägt die Zeile „der Zwischenstand wurde nicht zur Spitze eines geprüften
   Push".
2. Der Tag `v0.2.0` lag auf der beschädigten Baum-Fassung — derselbe Beleg,
   Abschnitt **Schaden**.
3. Der Tag `v0.2.1` liegt auf `77471f53`
   (`git rev-parse --short v0.2.1` → `77471f53`); am Tag-Baum fiel
   `make docs-check` rot, der CI-Lauf am Tag-Commit bricht FAILURE, und der
   Release-Workflow blieb grün, weil er `docs-check` nicht fährt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Release-Text einzelner Releases** — **anderer Vorgang:** die
  Release-Notes sind veröffentlicht und liegen außerhalb des Repos;
  `releasing.md` trägt die Prozedur, nicht die Chronik einzelner Schnitte.
- **Das Handbuch wird nicht umgeschrieben** — **Bestand bleibt bewusst
  stehen:** der Nachzug des
  [`benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md) auf die
  Prozedur-Ebene ist ein eigener, pausierter Vorgang; dieser Slice benennt die
  Berührungs-Stellen (Download-Weg, Start-Prüfung, Grenze) als Adresse, ohne
  sie anzufassen.
- **Die Mechanik wird nicht geändert** — **Schicht-Abgrenzung:** das
  `release-artifacts`-Rezept und die
  [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)-Mechanik
  stehen, wie sie heute gelten; die Datei trägt die Prozedur, die sie fahren.
  Kein Produkt-Code, kein Makefile-Rezept in diesem Slice.
- **Kein Signier-Schritt** — **Bestand bleibt bewusst stehen:** das Handbuch
  nennt die Grenze („der Release-Lauf hat keinen Signier-Schritt");
  `releasing.md` dokumentiert sie, sie hebt sie nicht auf.

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

- [ ] **Liefer-Punkt 1 — Prozedur:** `releasing.md` existiert und
      trägt die Prozedur in der Form, die die Rang-6-Zuordnung trägt:
      Assets bauen (`make release-artifacts`), Digests messen, `SHA256SUMS`
      erzeugen und als siebtes Asset publizieren, Tag-Kopplung im selben
      Vorgang, Release-Text nach Stand-Form, Start-Prüfung auf allen sechs
      Dateien, die Grenze (kein Signier-Schritt) — und die zwei
      Disziplin-Zeilen als harte Schritte der Prozedur.
      Rote Gegenproben: fehlt ein Matrix-Asset, färbt
      `test/release-matrix.bats` rot (die Matrix ist die Zusage hinter der
      Asset-Bau-Zeile); fehlt die `SHA256SUMS` im Release, bricht der
      Ziel-Fetch laut ab (gemessen am Ziel-Fetch: HTTP 404, curl-Exit 22 —
      dieselbe Zusage, die [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
      an den Fetch bindet).
- [ ] **Liefer-Punkt 2 — Verdrahtung:** die Datei ist adressierbar —
      [`harness/README.md`](../../../../README.md) §Source precedence führt
      Rang 6 als Verzeichnis `docs/user/` (Ziel-Form geprüft: keine
      Datei-Liste nötig); die Berührungs-Stellen im Handbuch sind als Adresse
      benannt, ohne es zu ändern. `make docs-check` grün.
      Rote Gegenprobe: verweist eine Datei auf `releasing.md`, bevor sie
      existiert, färbt `make docs-check` (Modul `links`) rot mit
      `target-missing` — die Mechanik, die jeden fehlenden Link in diesem
      Planungs-Tree bricht; die grüne Richtung wird von jedem Lauf dieses
      Plans belegt.
- [ ] **Liefer-Punkt 3 — Belegbasis-Abschnitt:** `releasing.md` trägt einen
      Abschnitt, der die Klasse benennt — ein ge-tagter/gepushter Stand ohne
      Gates-Beleg — mit den drei Fundstellen als Anker (siehe §1), in der
      Zustandsform ([`AGENTS.md`](../../../../AGENTS.md) §3.7: Zustand und
      Beleg als auflösbarer Anker, keine Chronik); der Prozedur-Text selbst
      trägt sie nicht. Rote Gegenprobe: nennt der Abschnitt eine Fundstelle
      als Pfad oder Kennung, der nicht auflöst, färbt `make docs-check` rot —
      Grenze: die Zustandsform selbst ist keinem Sensor unterworfen; sie wird
      vom Review geprüft, nicht vom Gate.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update für die Release-Prozedur, falls ein öffentlicher Vertrag
      berührt ist (Liefer-Punkt 2).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschritten — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der
      nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `releasing.md` | neu | die Prozedur (Liefer-Punkt 1) samt Belegbasis-Abschnitt (Liefer-Punkt 3) — Rang 6, Operations/Releasing |
| `harness/README.md` | prüfen, kein Inhalt-Zwang | Liefer-Punkt 2 — die Rang-6-Zeile trägt das Verzeichnis bereits; eine Änderung nur, falls die Ziel-Form eine trägt, die sie nicht hat |

**Ansatz als Liste, wo eine Zeile pro Datei nicht trägt:**

- Die zwei Disziplin-Zeilen stehen **in der Schritt-Folge** der Prozedur —
  zwischen Asset-Publikation und Tag-Push, und zwischen Tag-Push und der
  Meldung des vollzogenen Schnitts — nicht als Hinweis-Box daneben; ein
  Schritt, der übersprungen werden kann, ist keine Disziplin-Zeile.
- Die Start-Prüfung übernimmt die Zusagen des Handbuchs (auf allen sechs
  Dateien), aber auf der Prozedur-Ebene: das Handbuch sagt dem Nutzer, was er
  vorfindet; `releasing.md` sagt dem Schnitt, was er vor dem Tag-Push prüft.
- Keine Zahlen in der Prozedur ohne das Kommando, das sie liefert
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert));
  die Belegbasis-Abschnitts-Fundstellen tragen ihre Anker, nicht ihre
  Entstehung.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Prozedur-Zeilen
  brauchen mehr als die zwei Disziplin-Zeilen an Mechanik-Änderung — etwa ein
  `release-artifacts`-Rezept-Griff oder eine CI-Anpassung. Dann die Mechanik
  als eigenen wellenlosen Posten schneiden; dieser Slice bleibt Doku.
- `in-progress` → `open` (blockiert — Carveout?): Eine der zwei tragenden
  ADRs ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
  [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md))
  wird vor der Datei-Fassung zurückgezogen oder superseded — die Prozedur
  hätte keinen tragenden Grund mehr.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD mit den roten Gegenproben der drei Liefer-Punkte belegt, `make docs-check`
grün, und das Review bestätigt die Zustandsform des Belegbasis-Abschnitts
(Anker statt Chronik) sowie die Schritt-Position der zwei Disziplin-Zeilen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die zwei Disziplin-Zeilen sind Prozedur ohne Sensor** — kein Gate hält
  sie; ein Release-Lauf kann beide überspringen, und die Datei wäre trotzdem
  grün. Ausgang: weiter offen → Sichtung bei der Closure; erreicht die Klasse
  dabei die Schwelle, weist §7 (Folge-Slice: ein Sensor, der den Tag gegen den
  Gates-Beleg hält, oder Carveout).
- **Die Klasse ist dreimal gefallen und trägt keinen Register-Eintrag** — die
  Zählregel „ein Vorgang zählt einmal" verlangt die Fund→Vorgang-Zuordnung
  (Fundstellen 1 und 2 liegen im Vorgang des
  [Register-Belegs](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md),
  Fundstelle 3 im `v0.2.1`-Schnitt); dieser Slice plant die Zuordnung nicht.
  Ausgang: weiter offen → Sichtung bei der Closure.
- **Die tragenden ADRs sind Proposed** — trägt die Datei die Festlegungen von
  [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  und [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
  kippt eine davon, driftet die Datei gegen ihren Grund. Ausgang: weiter offen
  bis zum Accept; der Accept fällt mit der Closure des jeweiligen Slices.
- **Der pausierte Handbuch-Nachzug verliert seine Adresse** — verschieben sich
  die Berührungs-Stellen im
  [`benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md), zeigt die
  Pause ins Leere. Ausgang: weiter offen → der Nachzug-Slice nennt die Stellen
  neu; bis dahin trägt Liefer-Punkt 2 die aktuelle Adresse.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu
  angelegt, Beleg `evidence/slice-releasing-doku-traegt-den-release-vorgang.md` |
  `evidence/slice-releasing-doku-traegt-den-release-vorgang.md` in
  `BEO-<KUERZEL>/<slug>/` ergänzt — Zähler steht damit bei <N>x | keine
  Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** Anker · Folge-Slice · Register, Ergebnis

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die
neue Rang-6-Datei, eine Prüf-Berührung an
[`harness/README.md`](../../../../README.md) und die Belegbasis über
Register-Beleg und Tag-Anker. Die Sub-Area erfüllt die Schwelle ≥ 2 von 3
Achsen (Inventur-Berührung: ja; mehrere Dateien: ja; Aussagen-Berührung: ja —
die Source-precedence-Tabelle und die Release-Zusagen). Sie ist nicht zu grob —
die Modus-Deklaration in `harness/conventions.md` führt `*` namentlich.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-19 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**146**), Verzeichnisse unter `BEO-ALL/`. Treffer für die Sub-Area:
`BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` — **Zählerstand
1×**; sein Beleg trägt zwei der drei Fundstellen der Klasse, die dieser Slice
in `releasing.md` benennt — derselbe Vorgang ist Beleg-Kontext, nicht
Beobachtungs-Klasse. `BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`
— **Zählerstand 1×**; angrenzend (eine Kennung trägt den Stand, den ein Release
überholt), aber nicht die fehlende-Gates-Beleg-Klasse. Kein Eintrag trägt die
Klasse selbst, und keiner erreicht mit dieser Berührung 2× — der Zähler wird
durch diesen Plan nicht hochgeschrieben; die Fund→Vorgang-Zuordnung der drei
Fundstellen steht als Risiko in §6.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` steht in der
Modus-Deklaration als Greenfield); kein BF/Hybrid-Block.