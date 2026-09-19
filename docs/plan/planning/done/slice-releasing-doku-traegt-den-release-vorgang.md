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

**Verantwortlich:** Implementer (pt9912)

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
[`benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md#systemanforderungen)),
und die Grenze: kein Signier-Schritt — die Datei sagt sie, sie baut sie nicht;
sie trägt
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)/[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
als ihren Grund, keine Handbuch-Adresse. Zwei Zeilen stehen als **harte Schritte der Prozedur**,
nicht als Box daneben: Gates am Tag-Baum vor dem Tag-Push; CI am Tag abwarten,
bevor der Schnitt vollzogen gemeldet wird.

**Die Klasse hinter den zwei Zeilen, mit ihren drei Fundstellen** — ein
ge-tagter/gepushter Stand trug keinen Gates-Beleg. Sie sind die Belegbasis des
Abschnitts in `releasing.md` (Liefer-Punkt 3), nicht Chronik im Prozedur-Text;
alle drei Fundstellen liegen im Vorgang des
[Register-Belegs](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md)
— ein Beleg, nicht drei:

1. Die roten Pushes nach dem ersten beim `v0.2.0`-Vorfall — der
   [Register-Beleg](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md)
   trägt die Zeile „der Zwischenstand wurde nicht zur Spitze eines geprüften
   Push".
2. Der Tag `v0.2.0` lag auf der beschädigten Baum-Fassung — derselbe Beleg,
   Abschnitt **Schaden**.
3. Der Tag `v0.2.1` liegt auf `28337be5`
   (`git rev-parse --short v0.2.1` → `28337be5`); am Tag-Baum fiel
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

- [x] **Liefer-Punkt 1 — Prozedur:** `releasing.md` existiert und
      trägt die Prozedur in der Form, die die Rang-6-Zuordnung trägt:
      Assets bauen (`make release-artifacts`), Digests messen, `SHA256SUMS`
      erzeugen und als siebtes Asset publizieren, Tag-Kopplung im selben
      Vorgang, Release-Text nach Stand-Form, Start-Prüfung auf allen sechs
      Dateien, die Grenze (kein Signier-Schritt) — und die zwei
      Disziplin-Zeilen als harte Schritte der Prozedur.
      Rote Gegenproben: fehlt ein Matrix-Asset, färbt
      `test/release-matrix.bats` rot (die Matrix ist die Zusage hinter der
      Asset-Bau-Zeile); fehlt die `SHA256SUMS` im Release, bricht der
      Ziel-Fetch laut ab — die Abweichungs-Klasse (SUMS vorhanden, Digest
      weicht ab) misst `test/traeger-fetch.bats:174`, dieselbe Zusage, die
      [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
      an den Fetch bindet; die Fehlt-Klasse (ein Release **ohne** SUMS-Asset,
      HTTP 404 auf die SUMS-URL) ist **benannte Lücke, nicht gemessen** — ihr
      Konstruktions-Weg wäre ein Release ohne SUMS-Asset, und ein solches
      trägt kein existierendes Release.
- [x] **Liefer-Punkt 2 — Verdrahtung:** die Datei ist adressierbar —
      [`harness/README.md`](../../../../README.md) §Source precedence führt
      Rang 6 als Verzeichnis `docs/user/` (Ziel-Form geprüft: keine
      Datei-Liste nötig); die Berührungs-Stellen im Handbuch sind als Adresse
      benannt, ohne es zu ändern. `make docs-check` grün.
      Rote Gegenprobe: verweist eine Datei auf `releasing.md`, bevor sie
      existiert, färbt `make docs-check` (Modul `links`) rot mit
      `target-missing` — die Mechanik, die jeden fehlenden Link in diesem
      Planungs-Tree bricht; die grüne Richtung wird von jedem Lauf dieses
      Plans belegt.
- [x] **Liefer-Punkt 3 — Belegbasis-Abschnitt:** `releasing.md` trägt einen
      Abschnitt, der die Klasse benennt — ein ge-tagter/gepushter Stand ohne
      Gates-Beleg — mit den drei Fundstellen als Anker (siehe §1), in der
      Zustandsform ([`AGENTS.md`](../../../../AGENTS.md) §3.7: Zustand und
      Beleg als auflösbarer Anker, keine Chronik); der Prozedur-Text selbst
      trägt sie nicht. Rote Gegenprobe: nennt der Abschnitt eine Fundstelle
      als Pfad oder Kennung, der nicht auflöst, färbt `make docs-check` rot —
      Grenze: die Zustandsform selbst ist keinem Sensor unterworfen; sie wird
      vom Review geprüft, nicht vom Gate.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update für die Release-Prozedur, falls ein öffentlicher Vertrag
      berührt ist (Liefer-Punkt 2).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der
      nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

**Belege der Häkchen (Closure):** die drei Liefer-Punkte — Verifikations-Report
([`docs/reviews/2026-09-19-slice-releasing-doku-traegt-den-release-vorgang-verifikation.md`](../../../../docs/reviews/2026-09-19-slice-releasing-doku-traegt-den-release-vorgang-verifikation.md),
je Abschnitt „Liefer-Punkt N …: erfüllt"); `make gates` grün — der
aufgezeichnete Lauf am Verifikations-Kopf `ce64c4a0` (Stop-Hook-Zustand) und
der Closure-Lauf dieser Closure (Working-Tree-Hash-Nachweis über
`make record-gates`); Review — der Report der Runde 1
([`docs/reviews/2026-09-19-slice-releasing-doku-traegt-den-release-vorgang-runde-1.md`](../../../../docs/reviews/2026-09-19-slice-releasing-doku-traegt-den-release-vorgang-runde-1.md)),
nicht merge-blockierend; die Closure-Häkchen darunter — §6 und §7 dieser
Datei.

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
  an den Positionen, die die Datei trägt: die erste als Schritt 4, vor dem
  Schritt, der Tag-Push **und** Asset-Publikation zusammen trägt (der
  tag-getriebene Lauf publiziert erst nach dem Push), die zweite vor der
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
  grün. — **Ausgang:** *weiter offen* → die Klasse ins
  [Beobachtungs-Register](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)
  (neu angelegt in diesem Vorgang, Stand *offen*, 1×, Beleg
  `evidence/slice-releasing-doku-traegt-den-release-vorgang.md`) — die Klasse
  „eine Prozedur-Zeile trägt die Disziplin, kein Sensor fängt ihren Bruch"
  steht unter der Schwelle; ein Wächter für die Schritt-Folge wäre Regel-Arbeit
  des Architects ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und bekommt seine
  Adresse im Lese-Schritt, wenn die Klasse die Schwelle erreicht.
- **Die Klasse ist dreimal gefallen und trägt keinen Register-Eintrag** — die
  Zählregel „ein Vorgang zählt einmal" verlangt die Fund→Vorgang-Zuordnung;
  sie ist im
  [Klassen-Beleg](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/slice-release-schnitt-koppelt-pin-und-fassung.md)
  entschieden: alle drei Fundstellen liegen im selben Vorgang — ein Beleg,
  nicht drei. — **Ausgang:** *entfallen* → die Zuordnung trägt der
  Klassen-Beleg; dieses Risiko ist planseitig überholt.
- **Die tragenden ADRs sind Proposed** — trägt die Datei die Festlegungen von
  [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  und [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md),
  kippt eine davon, driftet die Datei gegen ihren Grund. — **Ausgang:**
  *entfallen* → beide tragenden ADRs tragen `**Status:** Accepted` (gemessen
  je Datei, Zeile 3, mit `grep -m1 '^\*\*Status'
  docs/plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md
  docs/plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md`);
  die Befund-Lage, die dieses Risiko trug, besteht nicht mehr.
- **Der pausierte Handbuch-Nachzug verliert seine Adresse** — verschieben sich
  die Berührungs-Stellen im
  [`benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md), zeigt die
  Pause ins Leere. — **Ausgang:** *weiter offen* → die Adresse des pausierten
  Nachzugs ist §1 dieses Plans (Out-of-Scope, *Bestand bleibt bewusst
  stehen*); die aktuellen Berührungs-Stellen trägt `releasing.md` (Schritt 5,
  Start-Prüfung; Grenze mit ihrem ADR-Anker-Paar). Der Nachzug liegt nicht als
  Slice-Datei — eine Kennung für ihn wird nicht erfunden; er bekommt seine
  Adresse bei seiner eigenen Anlage.

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

- **Was hat funktioniert:** Die Prozedur steht am Ort des Vorgangs:
  `releasing.md` trägt die sieben Schritte samt der zwei Disziplin-Zeilen als
  harte Schritte (Schritte 4 und 6, in der Schritt-Folge, keine Box daneben),
  die Belegbasis benennt die Klasse „ein ge-tagter/gepushter Stand trägt
  keinen Gates-Beleg" mit den drei Fundstellen als Anker in der Zustandsform,
  und die Grenze (kein Signier-Schritt) trägt
  [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  und
  [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  als ihren Grund. Die drei Liefer-Punkte sind im Verifikations-Report Punkt
  für Punkt belegt, kein DoD-Bruch; das Review der Runde 1 ist nicht
  merge-blockierend.
- **Was ging anders als geplant:** Die Plan-Korrekturen trafen den Plan, nicht
  die Lieferung, und sind gezogen: die Fundstelle 3 des Plans verwechselte die
  Pin-Commit-Position `77471f53` mit der Tag-Position `28337be5`; die erste
  Disziplin-Position des Plans setzte eine Publikations-Reihenfolge voraus,
  die die Mechanik nicht führt — der tag-getriebene Lauf publiziert erst nach
  dem Push, die Datei hält die Semantik der Position (Schritt 4 vor Schritt
  5); die V-1-Gegenprobe stand als „gemessen … HTTP 404, curl-Exit 22" ohne
  auflösbaren Beleg und ist auf die gemessene Abweichungs-Klasse
  (`test/traeger-fetch.bats:174`) zurückgenommen — die Fehlt-Form steht als
  benannte Lücke, nicht gemessen; die Start-Prüfung adressiert den
  [`benutzerhandbuch.md`](../../../../docs/user/benutzerhandbuch.md)
  §Systemanforderungen. Die Grenz-Zeile der Belegbasis trug einen
  Abwesenheits-Halbsatz (F-1) — gezogen `ce64c4a0`.
- **Steering-Loop-Eintrag:** die benannte Spec-Lücke des Vorläufers
  `slice-release-schnitt-koppelt-pin-und-fassung` (dessen §7: der
  Release-Vorgang liegt in keinem Artefakt) ist mit der Lieferung geschlossen —
  der Vorgang liegt in `releasing.md`. Die Form, die die zwei
  Disziplin-Zeilen tragen (harte Schritte in der Schritt-Folge statt Box), ist
  die Lernform dieses Slices; würde aus ihr eine Regel — ein Wächter für die
  Schritt-Folge oder eine Vorlagen-Regel für Prozedur-Pläne —, wäre das
  Regel-Arbeit des Architects, nicht Closure
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8): die Klasse hängt am
  Beobachtungs-Register-Eintrag unten und bekommt ihren Ausgang im
  Lese-Schritt, wenn sie die Schwelle erreicht; bis dahin ist kein
  Folge-Vorgang geschnitten.
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)
  neu angelegt, Beleg
  `evidence/slice-releasing-doku-traegt-den-release-vorgang.md` — die Klasse
  „eine Prozedur-Zeile trägt die Disziplin, kein Sensor fängt ihren Bruch"
  trägt ihre Kennung (1×). Kein neuer Beleg für
  `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg` — die drei Fundstellen
  liegen im Vorgang `slice-release-schnitt-koppelt-pin-und-fassung`, derselbe
  Vorgang, der den bestehenden Beleg trägt (1×, unverändert); die zwei
  Übergaben des Laufs (V-1, die planseitigen INFO-Posten) sind planseitig
  gezogen und tragen keinen Eintrag. Lese-Schritt: kein Eintrag erreichte mit
  diesem Vorgang die 3×-Schwelle.
- **Folge-Slices:** keine — die zwei offenen Ausgänge tragen ihre Orte (der
  Register-Eintrag oben; die Adresse des pausierten Handbuch-Nachzugs steht in
  §1, Out-of-Scope), und keine Schwelle verlangt einen Folge-Slice.
- **Risiken aus §6:** die zwei Disziplin-Zeilen *weiter offen* → Register ·
  Fund→Vorgang-Zuordnung *entfallen* (Klassen-Beleg) · tragende ADRs
  *entfallen* (beide `**Status:** Accepted`) · pausierter Handbuch-Nachzug
  *weiter offen* → Adresse in §1 — siehe §6.
- **Drei Paarungen:** Anker — kein Eintrag in §7 trägt das Feld `liegt in`
  (die Spec-Lücke ist mit der Lieferung selbst geschlossen, ihre Adresse ist
  `releasing.md`, Liefer-Punkt 1); die Paarung hat kein Objekt. ·
  Folge-Slice — keine Kennung genannt; die Paarung hat kein Objekt. ·
  Register — die in §6 und §7 genannten Beobachtungen existieren als
  Verzeichnisse (`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`,
  `BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`,
  `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad`), jedes trägt
  mindestens einen Beleg; geprüft im Paarungs-Lauf der Closure nach dem
  `git mv`.

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
1×**; sein Beleg trägt alle drei Fundstellen der Klasse, die dieser Slice
in `releasing.md` benennt (ein Beleg, nicht drei — die Zuordnung trägt der
Klassen-Beleg) — derselbe Vorgang ist Beleg-Kontext, nicht
Beobachtungs-Klasse. `BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`
— **Zählerstand 1×**; angrenzend (eine Kennung trägt den Stand, den ein Release
überholt), aber nicht die fehlende-Gates-Beleg-Klasse. Kein Eintrag trägt die
Klasse selbst, und keiner erreicht mit dieser Berührung 2× — der Zähler wird
durch diesen Plan nicht hochgeschrieben; die Fund→Vorgang-Zuordnung der drei
Fundstellen trägt der Klassen-Beleg (§6, Ausgang *entfallen*).

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` steht in der
Modus-Deklaration als Greenfield); kein BF/Hybrid-Block.