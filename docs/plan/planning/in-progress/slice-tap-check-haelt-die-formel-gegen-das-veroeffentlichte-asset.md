# Slice slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset: `make tap-check` hält die Tap-Formel byte-genau gegen das Asset des Tags

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057) Setzung 1 — ein freier Slug in
lowercase-Kebab-Case.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — sein Closure-Trigger fordert nichts, was die DoD unten nicht schon
belegt: kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle
entscheidet (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Er ist
der erste Schnitt der Folgepflichten von
[ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md);
die Folge-Schnitte (§1) sind einzeln lieferbar und bilden kein Bündel mit gemeinsamer
Closure-Bedingung.

**Ebene: Dogfood, nicht emittiert.** Das Werkzeug ist ein `make`-Ziel **dieses** Repos; kein
Zielrepo bekommt es.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Kontrolle hält das
Tap gegen das **veröffentlichte** Asset, nicht gegen eine lokal erzeugte Kopie; das Transport-Bild
ist digest-gepinnt),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (der Host braucht
über `git`, `docker`, `make` und `bash` hinaus nichts),
[ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — die Festlegungen 1, 2 und 5, Schritt c der Festlegung 3 und der Lese-Zweig der
Festlegung 4; die Schritte, die `sync` allein trägt, bleiben beim Folge-Schnitt),
[ADR-0058](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) (**Accepted** —
Festlegung 4: Transport im gepinnten Bild, Netz nur an genau diesem Aufruf),
[ADR-0059](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(**Accepted** — die Formel reist als Asset des Schnitts; der Vergleich füllt sie nicht ein zweites
Mal),
[ADR-0063](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) (**Proposed** — nur soweit
[ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) sie trägt: die Kontrolle vergleicht Bytes, keine Versions-Strings),
[`MR-014`](../../../../harness/conventions.md#mr-014) Setzung 1 (eine Quelle je Check, versioniert),
[`MR-071`](../../../../harness/conventions.md#mr-071) (die Fall-Anlage misst den Anker gegen den
Quell-Bestand),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (jede Zusage nennt, was sie bricht, und wird einmal rot
gesehen),
[`MR-025`](../../../../harness/conventions.md#mr-025) (jede Zahl dieses Plans steht neben dem
Kommando, das sie liefert).
**Kein Bezug:** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) — der
Vertragstext führt kein Tap, und [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) übernimmt den Bezug ausdrücklich nicht.

**Berührte Spec-Stellen:** — (der Slice berührt keine Spec-Stelle; Gegenstand ist ein
Werkzeug dieses Repos).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-24.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** `make tap-check TAG=<tag>` hält `Formula/ai-harness-init.rb` am Kopf des Default-Branch
des Tap **byte-genau** gegen das veröffentlichte Asset `ai-harness-init.rb` des Tags und meldet das
Ergebnis in drei Exit-Klassen — 0 gleich (oder der benannte Nicht-Gegenstand Vorab-Tag), 1
Formel-Unterschied auch nach der Wiederholung des Lesens, 2 nicht ausführbar — der Exit des
**Skripts**. Über `make` endet der Prozess bei jedem Fehlschlag mit Exit 2 (GNU Make 4.3); die
Klasse des Skripts steht dann in dessen letzter stderr-Zeile `tap-check: Exit <N>`. Lesend, im
digest-gepinnten Transport-Bild, kein Gate.

**Der Befund, an dem der Schnitt hängt.** Am Schnitt `v0.2.3` stand das Tap nach der Publikation
noch auf `0.2.2`; der Auftraggeber hat den Nachzug von Hand gepusht. Es gibt weder ein Ziel noch ein
Skript, das die Formel des Tap gegen das Asset hält
(`grep -nE '^[a-z-]*tap[a-z-]*:' Makefile`, gemessen 2026-09-24). Die Kontrolle ist der Schritt
der ADR, der **ohne** Zugangsgeheimnis und ohne Schreibzugriff auskommt — und der einzige, den die
Release-Prozedur als vom Job unabhängigen Beleg braucht ([ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 6).

**Was von Folgepflicht 1 in diesem Slice liegt und was `sync` allein braucht** — gelesen an der
Ablauf-Tabelle, der Exit-Tabelle und der Fitness Function der ADR:

- **In diesem Slice (`check`):** Schritt a (Tag-Form und Feldform, auf dem Host, vor `docker`) ·
  Schritt c (Vorab-Tag → Exit 0 *„Vorab-Tag, Tap bleibt"*, ohne Netz-Zugriff) · Schritt e (Vergleich,
  bei Ungleichheit einmal Wiederholung des Lesens nach 65 s) · der Exit-Vertrag ohne die
  `sync`-Zeilen · die Pin-Prüfung samt Kopplung an `TRAEGER_IMAGE` · die Übergabe des Tags ohne
  Text. **Und, weil `check` es kann,** das Mitführen des Tokens beim Lesen, wenn `TAP_TOKEN` gesetzt
  ist (Festlegung 2, Absatz *Ziel*) samt der Regel *nie in einer Kommandozeile, nie in der Ausgabe*
  (Festlegung 4, Absatz *Umgang*): der Lese-Pfad braucht das Token nicht, führt es aber mit, sobald
  es da ist — die Sicherung gehört darum hierher und nicht erst zu `sync`.
- **Beim Folge-Schnitt (`sync`):** Schritt b (Fehlt-Nachweis) · Schritt d (Vorwärts-Schutz samt
  Feldform der `version`-Zeile) · Schritt f (Schreiben, optimistisch, Blob-Stand aus den
  Skalar-Feldern der Schnittstelle) · Schritt g (Nachkontrolle = `check` erneut) · das Ziel
  `make tap-nachzug`, seine README-Zeile und sein `exempt-targets`-Eintrag · die Fitness-Zeilen zu
  Idempotenz, Vorwärts-Schutz, `version`-Zeile in `sync`, Fehlt-Nachweis, Schreiben, Optimistik,
  Schreiben ohne Antwort, Nachkontrolle und *„`sync` wiederholt nicht"*.

**Zwei Trennungen, und sie sind verschieden.** *Im Ablauf* ist es einer
([ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
Festlegung 1): die Schritte b, d, f, g entfallen in `check`, die Reihenfolge der übrigen bleibt.
*Im Schnitt* ist es ein Skript mit Modus-Argument, in dem die `sync`-Schritte **fehlen**: `sync`
endet in diesem Slice mit Exit 2 und der Meldung, dass der Modus nicht implementiert ist — kein
leerer Rumpf, der 0 meldet. Der Folge-Schnitt ergänzt Schritte in demselben Skript und ruft für
Schritt g die Einheit auf, die hier Vergleich und Wiederholung führt. **Bricht, wenn** der Vergleich
zweimal existiert (einmal für `check`, einmal für die Nachkontrolle): dann deckt der Fall des
Vergleichs nur eine Kopie, und Schritt g wäre eine zweite Fassung derselben Entscheidung.

**Die Grenze der Zusage** ([ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Grenze, soweit sie `check` trifft). Die Kontrolle sagt zu:
*zum Zeitpunkt des Lesens hat die Formel am Kopf des Default-Branch dieselben Bytes wie das Asset
des Tags* — wobei die Schnittstelle einen Stand liefern kann, der bis zu 60 s alt ist. Sie sagt
**nicht** zu: Installierbarkeit (`brew install`, `brew audit`) · dass das Asset richtig gefüllt ist
(das hält die Füll-Prüfung in `test/release-matrix.bats`) · die übrigen Dateien des Tap und
irgendeinen Zustand nach dem Aufruf · Herkunft (es gibt keinen Signier-Schritt) · das Lese-Limit der
Schnittstelle (ein erschöpftes Limit endet als Skript-Exit 2, nie als 1) · **den Prozess-Exit von
`make`** (jeder Fehlschlag endet dort mit 2; der Exit-Vertrag der ADR gilt für den Ablauf des
Skripts, und über `make` trägt die Zeile `tap-check: Exit <N>` die Klasse) · den lokalen Weg gegen die
Auswertung des Aufrufers (make wertet `TAG=…` samt `$(shell …)` aus, bevor ein Skript läuft; die
Formprüfung schützt den Env-Weg der CI, nicht die Tastatur) · das Token gegenüber dem Docker-Daemon.
**Und der Schreib-Pfad am realen Tap ist nicht Gegenstand dieses Slice — er hat keinen.** Die
hermetischen Fälle fahren Stubs (eine Fixture); der reale Beleg dieses Slice ist der Lese-Zustand
(Liefer-Punkt 3), nicht ein Schreib-Lauf.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Modus `sync` und `make tap-nachzug`** — *ein Folge-Schnitt übernimmt es.* Seine Kennung wird
  vergeben, wenn dieser Slice in `done/` liegt: eine Kennung vor dem Slice, der sie führt, wäre keine
  Adresse (Baseline-Regelwerk `modul-05-planning-harness.md` §Regeln gegen typische Fehlannahmen).
  Einzeln lieferbar bleibt dieser Slice, weil `check` weder Token noch Schreibrecht braucht und der
  vom Job unabhängige Beleg der Prozedur allein trägt.
- **Der Release-Job `tap`, die Umgebung samt Tag-Regel und das Secret `TAP_TOKEN`**
  (Folgepflicht 2) — *ein Folge-Schnitt nach `sync` übernimmt es*, denn der Job ruft
  `make tap-nachzug`. Die Anlage von Umgebung, Regel und Secret ist Handlung des Auftraggebers
  außerhalb des Repos ([ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 4); dieser Slice hat keine Vorbedingung dieser Art.
- **Der Prozedur-Schritt in [`docs/user/releasing.md`](../../../user/releasing.md)** (Folgepflicht 3)
  **und der Wortlaut von Weg C im Handbuch** (Folgepflicht 5) — Adresse ist der offene Slice
  [slice-tap-nachzug-ist-schritt-der-release-prozedur](../open/slice-tap-nachzug-ist-schritt-der-release-prozedur.md).
  Er führt heute die Kontrolle als eigenen Liefer-Punkt 2 und das Verdikt als Liefer-Punkt 3; die
  Kontrolle liefert dieser Slice, das Verdikt trägt [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md). **Umgeschnitten wird er vom Planner,
  bevor er `next/` wird** — die Prozedur nennt `make tap-check` als ihren Beleg und kommt deshalb
  nach diesem Slice. **Übergabe an ihn, nicht Gegenstand hier:** der Wortlaut der Prozedur für den
  Formel-Unterschied ist *„`tap-check` rot mit der Zeile `tap-check: Exit 1`"* — der Prozess-Exit
  von `make` trennt die Klassen nicht (Liefer-Punkt 1), die Zeile trägt sie.
- **Der Bezug [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) der
  Tap-Verteilung in Workflow-Kopf und Prozedur** (Folgepflicht 6) — *es wäre ein anderer Vorgang:*
  ob das Tap eine Anforderung wird oder der Bezug entfällt, entscheidet der Auftraggeber außerhalb
  der ADR.
- **`harness/tools/traeger-fetch.sh` und sein `TRAEGER_IMAGE`** — *Bestand bleibt bewusst stehen:*
  das neue Skript trägt den Digest als eigene Vorgabe **byte-gleich**, und ein Fall hält beide
  Stellen gleich; ein Bild-Wechsel ist ein Wechsel an allen Stellen ([ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 5).
- **Formel-Skeleton, Füll-Skript und Upload-Schritt im Release-Workflow** — *Bestand bleibt bewusst
  stehen:* die Formel im Asset ist Gegenstand des Vergleichs, nicht seiner Änderung.
- **Ein Gate** — *Schicht-Abgrenzung:* `make tap-check` braucht Netz, ein Gate läuft netzlos
  ([ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) Festlegung 1); das Ziel steht weder in `gates` noch in `record-gates`.

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

- [ ] **Liefer-Punkt 1 — das Werkzeug.** Ein versioniertes Skript unter `harness/tools/` mit dem
      Modus `check` (jeder andere Modus endet mit Exit 2 und sagt, dass er nicht implementiert
      ist), der bei **jedem** Ende mit Exit ≠ 0 als letzte stderr-Zeile `tap-<modus>: Exit <N>`
      schreibt (`<N>` ist der Exit des Skripts; die Zeile trägt die Klasse, die der Prozess-Exit
      von `make` nicht trägt), und seiner POSIX-`sh`-Nutzlast als eigener Datei, die im digest-gepinnten Transport-Bild
      läuft (Pin-Prüfung wie in `traeger-fetch.sh`; der Digest steht als eigene Vorgabe **byte-gleich**
      zu `TRAEGER_IMAGE`); das Ziel `make tap-check TAG=<tag>` (das Rezept trägt keine
      make-Referenz auf den Tag, der Tag reist als Umgebungsvariable; **kein Gate** — nicht in
      `gates`, nicht in `record-gates`); die Zeile in `harness/README.md` §Werkzeuge mit `kein Gate`
      und der Eintrag in `targets.exempt-targets` der `.d-check.yml` (exakt, kein Glob) — ohne ihn
      färbt das Doku-Gate im ersten Lauf rot; Makefile-Kommentar und README-Zeile nennen die Zeile
      `tap-<modus>: Exit <N>` als Träger der Klasse, nicht make's locale-abhängige Meldung
      (`Error N`/`Fehler N`). Die Nutzlast ruft nur Programme des Bestands, den
      [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Lage im Bild gemessen hat (kein `jq`, kein `bash`, kein `git`, kein `gh`); ein
      Programm außerhalb ist eine Entscheidung (§4 Rückführung), keine Nebenwirkung.
- [ ] **Liefer-Punkt 2 — der hermetische Nachweis.** `bats`-Fälle in `make test`, ohne Netz und ohne
      Container: Stubs für Asset, Tap-Stand, `curl` und `docker`; Quellen und Wartezeit der
      Wiederholung sind injizierbar; die Nutzlast läuft als eigene Datei. **Jede Exit-Angabe der
      Fälle nennt den Exit des Skripts.** **Was die Fälle halten**
      (die Zeilen der Fitness Function der ADR, die `check` betreffen — je Eigenschaft, nicht je
      Nummer): die Exit-Zeile — bei Exit 1 und bei Exit 2 ist die **letzte** stderr-Zeile
      `tap-check: Exit 1` bzw. `tap-check: Exit 2`, bei Exit 0 fehlt sie; ein Fall wird rot, wenn
      sie fehlt oder die falsche Klasse nennt ·
      Vergleich: gleich → 0 mit Tag, Tap-Kopf und Digest (auch mit einem Nicht-ASCII-Byte und ohne Endzeilenumbruch) · verschieden auch nach der Wiederholung →
      1 mit beiden Digests und der ersten abweichenden Zeile **des zweiten Lesens** (dazu der
      Vorfall hermetisch nachgestellt: Asset von `v0.2.3` als Quelle, Bytes von `v0.2.2` als
      Tap-Stand) · Tap unlesbar, Asset unlesbar, Tap ohne Formel-Datei (404) → 2, nie 1, nie 0 ·
      Cache-Fenster: erst alt, dann neu → 0 mit zwei Lese-Aufrufen; beide Male alt → 1; sofort
      gleich → ein Lese-Aufruf ohne Wartezeit · die `version`-Zeile ist in `check` kein Gegenstand:
      Tap gleich Asset, mit einer `version`-Zeile außerhalb der Feldform → 0 · Vorab-Tag → 0 mit
      *„Vorab-Tag, Tap bleibt"*, ohne Netz-Zugriff, `v1.0.0-RC` und `v1.0.0-rc.1+x` Vorab,
      `v1.0.0+build-1` stabil, **die Tags aus dem `publish`-Job von `release.yml` gelesen**, und der
      Fall schlägt fehl, wenn er die Regel dort nicht findet (Folgepflicht 4) · Tag-Eingabe: im
      Env-Weg `v1.0.0$(touch${IFS}marker)` und `v1.0.0;x`, im lokalen Weg
      `make tap-check TAG='v1.0.0$$(id)'`, dazu die Feldform `v01.0.0`, `v1.0.08`, `v1.0.1234567890`
      und `v01.0.0-rc.1` → je Exit 2, Marker-Datei fehlt, **kein `docker`-Aufruf** · Übergabe ohne
      Text: die Rezeptzeilen von `tap-check` tragen weder `$(TAG)` noch `${TAG}` · Token: ein
      Sentinel-Token steht in **keiner** Argumentliste des `curl`-Stubs und in **keiner** Ausgabe
      (Erfolg wie abgelehnte Anmeldung beim Lesen), der Header liegt in einer Datei mit Modus 0600,
      die nach dem Lauf fehlt · Pin: ein Bild ohne Digest → 2 vor `docker`; der Digest des Skripts
      gleich dem von `traeger-fetch.sh`. **Wo ein Fall Exit 2 verspricht, prüft er auch die
      Meldung** (sie nennt die Ursache der Zusage, nicht einen Syntaxfehler der Shell). **Jeder
      Fall wird einmal unter der Schwächung rot gesehen, die die ADR in ihrer Fitness Function
      nennt, und die Ausgabe gelesen** ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] **Liefer-Punkt 3 — die Zähne und der reale Rot-Beleg.** (a) Je Zahn des `check` ein
      Mutations-Fall in `test/mutations/`, der den benannten `bats`-Fall aus dem behaupteten Grund
      rot färbt: Vorab-Regel, Abschneiden des Metadatums vor der Prüfung, Wiederholung des Lesens,
      Sofort-Gleich ohne Wartezeit, Tag-Formprüfung, Feldform, Pin-Prüfung, Token als Argument,
      Exit-Zeile (entfernt; falsche Klasse).
      Der `sed`-Anker jedes Falls ist am **heutigen** Quell-Bestand gemessen, nachdem das Skript
      existiert ([`MR-071`](../../../../harness/conventions.md#mr-071)). (b) **Der Rot-Beleg am
      realen Zustand, kein Gate:** `bash harness/tools/tap-nachzug.sh check` mit `TAG=v0.2.2`
      endet gegen den Tap-Kopf mit Skript-Exit 1 (nach der Wiederholung des Lesens) und der Meldung
      des Formel-Unterschieds — beide Digests, die erste abweichende Zeile ist die `version`-Zeile —,
      nicht mit Exit 2; über `make tap-check TAG=v0.2.2` endet der Prozess mit Exit 2, und die
      Klasse steht in der Skript-Zeile `tap-check: Exit 1` sowie in der make-Zeile `Error 1`
      (`Fehler 1` in der deutschen Locale). Gegen `v0.2.3` endet beides mit Exit 0. **Der Beleg ist
      datiert:** er gilt für den Tap-Stand am Tag der Messung und wandert mit jedem Schnitt — grün
      ist dann der Tag, den das Tap trägt. Die Ausgabe ist gelesen: Exit 1 ist ein
      Formel-Unterschied, nicht ein Lesefehler.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: [`harness/README.md`](../../../../harness/README.md) §Werkzeuge (Teil von
      Liefer-Punkt 1); das Handbuch und `docs/user/releasing.md` bleiben dem Prozedur-Slice (§1).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/tap-nachzug.sh` <!-- d-check:ignore (Datei entsteht mit diesem Slice) --> | neu | Liefer-Punkt 1: Modus-Argument, Schritte a, c, e, Exit-Vertrag, Pin-Vorgabe und Pin-Prüfung, `docker run` — Namen sind Vorschlag des Plans, der Implementer darf sie ändern |
| `harness/tools/tap-nachzug-nutzlast.sh` <!-- d-check:ignore (Datei entsteht mit diesem Slice) --> | neu | Liefer-Punkt 1: POSIX-`sh`-Nutzlast im Bild — Asset und Tap-Kopf holen, vergleichen, wiederholen; Header-Datei 0600 |
| `Makefile` | update | Liefer-Punkt 1: Ziel `tap-check` und sein Eintrag in `.PHONY` |
| `harness/README.md` | update | Liefer-Punkt 1: Zeile in §Werkzeuge mit `kein Gate` |
| `.d-check.yml` | update | Liefer-Punkt 1: `targets.exempt-targets` (exakt) |
| `test/tap-nachzug.bats` <!-- d-check:ignore (Datei entsteht mit diesem Slice) --> | neu | Liefer-Punkt 2: die hermetischen Fälle samt Kopplung an `TRAEGER_IMAGE` und an die Vorab-Regel des `publish`-Jobs |
| `test/mutations/` <!-- d-check:ignore (geplante Dateien) --> | neu | Liefer-Punkt 3: die Zähne; Nummern im Anschluss an die höchste **vergebene** (`ls -1 test/mutations/*.sh \| sed -n 's#.*/\([0-9]*\)-.*#\1#p' \| sort -n \| tail -1` → **408**, gemessen 2026-09-24, kein Erwartungswert) |

- **Reihenfolge:** Kern (Formprüfung, Vorab-Regel, Vergleich, Exit-Klassen) mit seinen Fällen →
  Nutzlast und Transport → Ziel und Bindungen → Zähne → realer Beleg. Die Schicht-Trennung des
  Skripts folgt der ADR: die Entscheidungen (Formprüfung, Vorab-Regel, Pin-Prüfung) laufen auf dem
  Host vor `docker`, Vergleich und Lesen im Bild.
- **Wie die Nutzlast ins Bild kommt** (Mount oder Standard-Eingabe) entscheidet der Implementer;
  Maßstab ist, dass sie **nirgends** den Token in eine Kommandozeile bringt und dass
  `make shell-lint` sie deckt (`harness/tools/*.sh` liegt im Prüfbereich des Rezepts).
- **Kein Produktionscode** im Sinn der Go-Emission: der Slice berührt weder `internal/` noch
  `cmd/`.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Implementer übernimmt, WIP-Limit frei; der `git mv` landet auf
dem Hauptzweig, vor der Arbeit. **Keine Vorbedingung des Auftraggebers:** weder Token noch Umgebung
noch Push-Recht — die braucht erst `sync` bzw. der Job. Die Vorbedingung im Repo ist
[ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
`Accepted` (seit 2026-09-24).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Skript, Nutzlast, Fälle und Zähne sind in
  **einer** Review-Sitzung nicht prüfbar — dann Schnitt entlang der Achse *Kern* (Formprüfung,
  Vorab-Regel, Vergleich, Exit-Klassen, mit Stubs) und *Transport* (Bild, Header-Datei, Ziel,
  Bindungen). Oder die Nutzlast braucht ein Programm außerhalb des Bestands, den die ADR im Bild
  gemessen hat: ein eigenes, gepinntes Bild ist eine Entscheidung des Architect, und der Slice hält
  an.
- `in-progress` → `open` (blockiert — Carveout?): das Tap ist anonym nicht mehr lesbar (privat oder
  geschützt — der Re-Evaluierungs-Trigger der ADR), oder der reale Rot-Beleg ist ohne Entscheidung
  des Auftraggebers nicht herstellbar.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make test` ist grün mit den Fällen aus Liefer-Punkt 2, und der
Bericht trägt den realen Rot-Beleg aus Liefer-Punkt 3 mit gelesener Meldung (Skript-Exit 1 und
Zeile `tap-check: Exit 1` gegen `v0.2.2`, Exit 0 gegen den Tag, den das Tap trägt); (2) `make gates` ist grün mit der README-Zeile und dem
`exempt-targets`-Eintrag (das Modul `targets` prüft beide Richtungen). Dazu der Lerneintrag in
einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Die Ausgänge setzt die Closure; bis dahin steht hinter jedem Risiko `Ausgang: offen bis Closure`.

- **Ein Byte, das die Shell nicht heil trägt, macht ein falsches Gleich oder Ungleich.** Endzeilenumbruch,
  Nicht-ASCII-Byte: ein Vergleich über eine Shell-Variable statt über Dateien verliert sie. Der Fall
  *gleich* trägt darum eine Formel mit Nicht-ASCII-Byte und ohne Endzeilenumbruch (Liefer-Punkt 2).
  — **Ausgang:** offen bis Closure.
- **Die Stubs sind eine Fixture.** Sie bilden `curl`, Kopfzeilen und Antwortform nach; ob das reale
  Tap und die Download-Adresse des Assets dieselbe Form liefern (Weiterleitung, `Accept`-Kopf,
  404-Form), hält allein der reale Beleg aus Liefer-Punkt 3 — und der gilt für den Zustand am Tag
  der Messung. — **Ausgang:** offen bis Closure.
- **Das Cache-Fenster der Schnittstelle** (`max-age=60`, [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Lage): dass ein Lesen nach einem
  Schreiben den Stand davor liefert, ist nicht beobachtet; ein falsches Ungleich kostet 65 s
  Wartezeit, nie ein falsches Gleich. Dieser Slice schreibt nie; das Fenster trifft ihn nur bei einem
  Aufruf kurz nach einem Nachzug des Auftraggebers. — **Ausgang:** offen bis Closure.
- **Das anonyme Lese-Limit.** Wiederholte Läufe des realen Belegs können es erschöpfen; das endet als
  Skript-Exit 2 *„Tap nicht lesbar"*, nie als 1 — ein Rot des Belegs aus diesem Grund ist kein Befund am
  Vergleich. — **Ausgang:** offen bis Closure.
- **Die Kopplung an die Vorab-Regel des `publish`-Jobs ist an dessen Textform gebunden.** Ändert sich
  die Form der Regel dort, muss der Fall laut brechen statt still grün zu bleiben (Liefer-Punkt 2:
  *„schlägt fehl, wenn er die Regel dort nicht findet"*). — **Ausgang:** offen bis Closure.
- **Der Slice ist größer als eine Review-Sitzung.** Zwei Schichten (Werkzeug, Test) und drei
  Liefer-Punkte; die Rückführung steht in §4. — **Ausgang:** offen bis Closure.

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

Leer bis zur Closure; sie schreibt der Planner im frischen Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10).

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `harness/tools/` (Kürzel `TOOLS`: das Skript,
die Nutzlast) und das gesamte Repo `*` (Kürzel `ALL`: `Makefile`, `harness/README.md`,
`.d-check.yml`, `test/`), beide in der
[Modus-Deklaration](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) geführt.
Die Deklaration kennt keine feinere Zerlegung des Rests; ob `*` die Schwelle von 2 aus 3 Achsen
erfüllt, ist die Frage der Deklaration und nicht dieses Slice — er liest sie als vorhandene (Urteil,
kein Sensor).

**Vorgelagert — offene Beobachtungen sichten:** Das Register
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **168**, gemessen 2026-09-24, kein
Erwartungswert) ist nach Verzeichnisname durchgegangen; Sub-Area ist überall `*`. Die Zähler-Stände
unten sind die Zahl der Dateien unter dem `evidence/` des Eintrags
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gemessen 2026-09-24). Treffer
nach Sachbezug:

- [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  — **2×**. Der Slice legt zwei Paare an: den Bild-Digest (Skript ↔ `traeger-fetch.sh`) und die
  Vorab-Regel (Skript ↔ `publish`-Job). Beide tragen einen vergleichenden Fall als Liefer-Punkt 2;
  fehlte einer, hebt dieser Slice den Zähler auf **3×** — dann ist der Eintrag eine Lücke und
  braucht einen eigenen Folge-Slice.
- [`waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)
  — **1×**. Die `bats`-Fälle fahren Stubs für die reale Schnittstelle; der reale Rot-Beleg
  (Liefer-Punkt 3) ist die benannte Gegenmaßnahme, gilt aber nur für den Zustand am Tag der Messung
  (§6).
- [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  — **13×**, `verkörpert`. Der Slice legt neue Zähne an; Liefer-Punkt 3 trägt die Fälle.

Andere Einträge nach Namenslesung nicht berührt (Urteil, kein Sensor).

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas sind GF** (`TOOLS` und `ALL` in der Modus-Deklaration): Der Slice
schreibt ein neues Werkzeug nach der ADR; er inventarisiert keinen Bestand.
