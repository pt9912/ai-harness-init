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
Festlegung 4; die Schritte, die `sync` allein trägt, bleiben beim Folge-Schnitt; die Exit-Klassen
lesen sich als die des Skripts, siehe die nächste Zeile),
[ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) (**Proposed** — die Klassen 0, 1 und 2 sind der Exit des **Skripts**; über `make` endet
jeder Fehlschlag mit Prozess-Exit 2, die Klasse steht dort als Ziffer in der Meldung von `make`
(`Error N`/`Fehler N`, der Wortlaut hängt an der Locale; die Meldung ist kein Vertrag), und
vertraglich trägt sie die letzte stderr-Zeile **des Skripts** `tap-<modus>: Exit <N>`, genau einmal,
bei Exit 1 und 2, nicht bei Exit 0 — sie ist locale- und positionsfrei; die Teil-Ablösung trifft
drei Stellen von [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md), deren Trigger 1 bindet fort, und die Datei selbst bleibt
unverändert),
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
**Skripts** ([ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)). Über `make` endet der Prozess bei jedem Fehlschlag mit Exit 2 (GNU Make
4.3); die Klasse des Skripts steht dort als Ziffer in der Meldung von `make`
(`make: *** … Error N`, in der deutschen Locale `Fehler N`) — ablesbar, aber kein Vertrag — und
vertraglich in der letzten stderr-Zeile **des Skripts** `tap-check: Exit <N>`. Gelesen wird die
Zeile selbst, nicht ihre Position: bei `make tap-check` aus dem Wurzelverzeichnis ist sie die
vorletzte Zeile der Ausgabe (ihr folgt die Meldung von `make`); unter `make -C <dir>` und unter einem
umschließenden `make` folgen weitere Zeilen. Lesend, im digest-gepinnten Transport-Bild, kein Gate.

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
Skripts, und über `make` trägt die Zeile des Skripts `tap-check: Exit <N>` die Klasse; die Ziffer in
der Meldung von `make` nennt sie ebenfalls, ihr Wortlaut hängt an der Locale und sie ist kein
Vertrag) · **die Exit-Zeile bei einem Signal an das Host-Skript** (etwa während des
`docker`-Aufrufs), **bei nicht beschreibbarem stderr und bei fehlendem oder unbekanntem Modus**
(erreichbar nur im Direktaufruf; die Ziele setzen den Modus fest) — dort ist sie weder zugesagt noch
verboten; ein Skript, das sie dort hält, bricht den Plan nicht, eines, das sie dort nicht hält, auch
nicht · **bei einem Signal auch die Klasse:** der Prozess endet mit 128 plus der Signalnummer und ohne
jede Ausgabe, ein solches Ende ist keine der drei Klassen · **die Klasse 1 bei nicht beschreibbarer
stderr des aufrufenden `docker`-Clients:** schreibt der Container auf diese stderr, endet der Client
mit Status 1 statt mit dem der Nutzlast, ein Formel-Unterschied endet als Klasse 2 — die sichere
Richtung, nie ein Unterschied, der keiner ist; zugesagt ist sie nicht (eine stderr, die im Container
nicht beschreibbar ist, ist eine andere Lage) · den lokalen Weg gegen die
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
  von `make` trennt die Klassen nicht (Liefer-Punkt 1), die Zeile des Skripts trägt sie und ist der
  Vertrag; die Ziffer in der Meldung von `make` ist keiner. Die Prozedur liest die Zeile, nicht ihre
  Position.
- **Der Status-Kanal zwischen Nutzlast und Host-Skript** (die Nutzlast meldet den Formel-Unterschied
  mit einem eigenen Status, das Host-Skript bildet ihn auf Klasse 1 ab) — *Bestand unterhalb der
  ADR:* er ist nicht Vertrag und steht in keiner DoD-Zeile. Skript-Kopf und Nutzlast-Kopf nennen ihn
  samt seiner Restmenge (ein `docker`-Aufruf, der selbst mit diesem Status endet, wird als
  Formel-Unterschied ohne Digests gemeldet) — das ist Implementer-Arbeit dieses Slice. Der
  `sync`-Schnitt zieht ihn mit, sobald er einen Status jenseits von 0, 2 und dem des Unterschieds
  oder ein Ergebnis einführt, das Klasse 1 aus einer anderen Quelle als dem Vergleich trägt
  (Re-Evaluierungs-Trigger 3 von
  [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)).
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

- [x] **Liefer-Punkt 1 — das Werkzeug.** Ein versioniertes Skript unter `harness/tools/` mit dem
      Modus `check` (jeder andere Modus endet mit Exit 2 und sagt, dass er nicht implementiert
      ist), der bei Exit 1 und bei Exit 2 **des Skripts** als letzte stderr-Zeile **des Skripts**
      `tap-<modus>: Exit <N>` schreibt, genau einmal, bei Exit 0 nicht (`<N>` ist der Exit des
      Skripts; die Zeile trägt die Klasse, die der Prozess-Exit von `make` nicht trägt; `<modus>`
      ist der Modus, mit dem das Skript aufgerufen wurde; über `make <ziel>` aus dem
      Wurzelverzeichnis folgt ihr die Meldung von `make`, unter `-C` oder einem umschließenden
      `make` weitere Zeilen — gelesen wird die Zeile, nicht ihre Position). **Grenze der Zusage:**
      bei einem Signal an das Host-Skript, bei nicht beschreibbarem stderr und bei fehlendem oder
      unbekanntem Modus ist die Zeile weder zugesagt noch verboten; der Plan verlangt dort nichts.
      Bei einem Signal ist auch die Klasse nicht zugesagt (der Prozess endet mit 128 plus der
      Signalnummer und ohne Ausgabe, keine der drei Klassen); der Plan verlangt dazu keine Härtung.
      Ist die stderr des aufrufenden `docker`-Clients nicht beschreibbar und schreibt der Container
      auf sie, kann ein Formel-Unterschied als Klasse 2 statt 1 enden (die sichere Richtung). Ein Exit **des `docker`-Aufrufs** mit Status 1 ist kein Formel-Unterschied
      (Klasse 1 kommt allein aus dem Vergleich der Nutzlast) und endet als Exit 2. Dazu die
      POSIX-`sh`-Nutzlast als eigener Datei, die im digest-gepinnten Transport-Bild
      läuft (Pin-Prüfung wie in `traeger-fetch.sh`; der Digest steht als eigene Vorgabe **byte-gleich**
      zu `TRAEGER_IMAGE`); das Ziel `make tap-check TAG=<tag>` (das Rezept trägt keine
      make-Referenz auf den Tag, der Tag reist als Umgebungsvariable; **kein Gate** — nicht in
      `gates`, nicht in `record-gates`); die Zeile in `harness/README.md` §Werkzeuge mit `kein Gate`
      und der Eintrag in `targets.exempt-targets` der `.d-check.yml` (exakt, kein Glob) — ohne ihn
      färbt das Doku-Gate im ersten Lauf rot; Makefile-Kommentar und README-Zeile nennen die Zeile
      `tap-<modus>: Exit <N>` als vertraglichen Träger der Klasse, nicht make's locale-abhängige Meldung
      (`Error N`/`Fehler N`, deren Ziffer die Klasse zwar nennt, aber kein Vertrag ist). Die Nutzlast ruft nur Programme des Bestands, den
      [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Lage im Bild gemessen hat (kein `jq`, kein `bash`, kein `git`, kein `gh`); ein
      Programm außerhalb ist eine Entscheidung (§4 Rückführung), keine Nebenwirkung.
- [x] **Liefer-Punkt 2 — der hermetische Nachweis.** `bats`-Fälle in `make test`, ohne Netz und ohne
      Container: Stubs für Asset, Tap-Stand, `curl` und `docker`; Quellen und Wartezeit der
      Wiederholung sind injizierbar; die Nutzlast läuft als eigene Datei. **Jede Exit-Angabe der
      Fälle nennt den Exit des Skripts** — die Fälle fahren das Skript ohne `make`. **Was die Fälle
      halten** (die Zeilen der Fitness Function der ADR, die `check` betreffen — je Eigenschaft,
      nicht je Nummer): die Exit-Zeile — bei Exit 1 und bei Exit 2 ist die **letzte** stderr-Zeile
      **des Skripts** `tap-check: Exit 1` bzw. `tap-check: Exit 2` und steht genau einmal, bei
      Exit 0 fehlt sie (Modus `sync`: `tap-sync: Exit 2`); ein Fall wird rot, wenn sie fehlt, die
      falsche Klasse nennt, bei Exit 0 erscheint oder doppelt steht ·
      Vergleich: gleich → 0 mit Tag, Tap-Kopf und Digest (auch mit einem Nicht-ASCII-Byte und ohne Endzeilenumbruch) · verschieden auch nach der Wiederholung →
      1 mit beiden Digests und der ersten abweichenden Zeile **des zweiten Lesens** (dazu der
      Vorfall hermetisch nachgestellt: Asset von `v0.2.3` als Quelle, Bytes von `v0.2.2` als
      Tap-Stand) · Tap unlesbar, Asset unlesbar, Tap ohne Formel-Datei (404) → 2, nie 1, nie 0; **ebenso ein `docker`-Stub, der mit Status 1
      endet** (der Daemon ist nicht erreichbar, die Nutzlast lief nicht) → 2 mit der Meldung des
      Transports, nie 1 — der Fall wird rot, wenn das Skript diesen Status als Formel-Unterschied
      meldet; und ein Kommando mit Status ≥ 3 (etwa 127) → 2, nie der Status durchgereicht ·
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
- [x] **Liefer-Punkt 3 — die Zähne und der reale Rot-Beleg.** (a) Je Zahn des `check` ein
      Mutations-Fall in `test/mutations/`, der den benannten `bats`-Fall aus dem behaupteten Grund
      rot färbt: Vorab-Regel, Abschneiden des Metadatums vor der Prüfung, Wiederholung des Lesens,
      Sofort-Gleich ohne Wartezeit, Tag-Formprüfung, Feldform, Pin-Prüfung, Token als Argument,
      Exit-Zeile (entfernt; falsche Klasse; auch bei Exit 0; doppelt), Exit-Abbildung (Status 1 des
      `docker`-Aufrufs als Formel-Unterschied gemeldet; der `*)`-Arm von `beende` in **beiden**
      Skripten, Status ≥ 3 nicht auf 2 abgebildet).
      Der `sed`-Anker jedes Falls ist am **heutigen** Quell-Bestand gemessen, nachdem das Skript
      existiert ([`MR-071`](../../../../harness/conventions.md#mr-071)). (b) **Der Rot-Beleg am
      realen Zustand, kein Gate:** `bash harness/tools/tap-nachzug.sh check` mit `TAG=v0.2.2`
      endet gegen den Tap-Kopf mit Skript-Exit 1 (nach der Wiederholung des Lesens) und der Meldung
      des Formel-Unterschieds — beide Digests, die erste abweichende Zeile ist die `version`-Zeile —,
      nicht mit Exit 2, und seine letzte stderr-Zeile ist `tap-check: Exit 1`; über
      `make tap-check TAG=v0.2.2` endet der Prozess mit Exit 2, die Klasse steht in der Zeile des
      Skripts `tap-check: Exit 1`, und ihr folgt die Meldung von `make` mit `Error 1` (`Fehler 1` in
      der deutschen Locale; die Ziffer ist kein Vertrag) — bei `make tap-check` aus dem
      Wurzelverzeichnis ist die Skript-Zeile die **vorletzte** Zeile der Ausgabe, nicht die letzte;
      gelesen wird die Zeile, nicht ihre Position. Gegen `v0.2.3` endet beides mit Exit 0. **Der Beleg ist
      datiert:** er gilt für den Tap-Stand am Tag der Messung und wandert mit jedem Schnitt — grün
      ist dann der Tag, den das Tap trägt. Die Ausgabe ist gelesen: Exit 1 ist ein
      Formel-Unterschied, nicht ein Lesefehler.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: [`harness/README.md`](../../../../harness/README.md) §Werkzeuge (Teil von
      Liefer-Punkt 1); das Handbuch und `docs/user/releasing.md` bleiben dem Prozedur-Slice (§1).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

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
`Accepted` (seit 2026-09-24); [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) (`Proposed`) ist der Constraint für die Ebene der
Exit-Klassen und den Träger der Klasse über `make`.

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
letzte stderr-Zeile des Skripts `tap-check: Exit 1` gegen `v0.2.2`, über `make` aus dem
Wurzelverzeichnis als vorletzte Zeile vor der Meldung von `make`; Exit 0 gegen den Tag, den das Tap
trägt); (2) `make gates` ist grün mit der README-Zeile und dem
`exempt-targets`-Eintrag (das Modul `targets` prüft beide Richtungen). Dazu der Lerneintrag in
einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Die Ausgänge stehen hinter jedem Risiko; die Beobachtungs-Verzeichnisse liegen unter
[`../observations/`](../observations).

- **Ein Byte, das die Shell nicht heil trägt, macht ein falsches Gleich oder Ungleich.** Endzeilenumbruch,
  Nicht-ASCII-Byte: ein Vergleich über eine Shell-Variable statt über Dateien verliert sie. Der Fall
  *gleich* trägt darum eine Formel mit Nicht-ASCII-Byte und ohne Endzeilenumbruch (Liefer-Punkt 2).
  — **Ausgang: entfallen.** Der Vergleich läuft über Dateien (`cmp`, `harness/tools/tap-nachzug-nutzlast.sh`),
  nicht über Variablen; der Fall *gleich* trägt die Bytes (Nicht-ASCII, ohne Endzeilenumbruch; Verifier §2),
  und zwei Zähne mutieren den Vergleichsweg: 419 (der Endzeilenumbruch geht verloren) und 425 (Status 2 von
  `cmp` gilt als Unterschied). Beide stehen im Lauf `422 ok`; der Bericht des Verifiers führt sie nicht
  einzeln auf.
- **Die Stubs sind eine Fixture.** Sie bilden `curl`, Kopfzeilen und Antwortform nach; ob das reale
  Tap und die Download-Adresse des Assets dieselbe Form liefern (Weiterleitung, `Accept`-Kopf,
  404-Form), hält allein der reale Beleg aus Liefer-Punkt 3 — und der gilt für den Zustand am Tag
  der Messung. — **Ausgang: weiter offen → Register**,
  [`waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md).
  Der reale Beleg vom 2026-09-25 (Tap `0.2.3`) bestätigt die Form für diesen Tag; er wandert mit jedem
  Schnitt.
- **Das Cache-Fenster der Schnittstelle** (`max-age=60`, [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) §Lage): dass ein Lesen nach einem
  Schreiben den Stand davor liefert, ist nicht beobachtet; ein falsches Ungleich kostet 65 s
  Wartezeit, nie ein falsches Gleich. Dieser Slice schreibt nie; das Fenster trifft ihn nur bei einem
  Aufruf kurz nach einem Nachzug des Auftraggebers. — **Ausgang: weiter offen → Register**, dieselbe
  Beobachtung, dieselbe Evidence-Datei: das Fenster ist eine Eigenschaft der realen Quelle, die nur
  eine Stub-Folge alt → neu nachstellt.
- **Das anonyme Lese-Limit.** Wiederholte Läufe des realen Belegs können es erschöpfen; das endet als
  Skript-Exit 2 *„Tap nicht lesbar"*, nie als 1 — ein Rot des Belegs aus diesem Grund ist kein Befund am
  Vergleich. — **Ausgang: weiter offen → Register**, dieselbe Beobachtung: die Klasse (Exit 2, nie 1) hält
  der Stub-Fall, die Antwort der realen Schnittstelle bei erschöpftem Limit ist nie beobachtet.
- **Die Kopplung an die Vorab-Regel des `publish`-Jobs ist an dessen Textform gebunden.** Ändert sich
  die Form der Regel dort, muss der Fall laut brechen statt still grün zu bleiben (Liefer-Punkt 2:
  *„schlägt fehl, wenn er die Regel dort nicht findet"*). — **Ausgang: entfallen.** Der Verifier ersetzte
  die Regel in `release.yml` durch `*-rc*)`: der Fall `vorab-tag: die Regel …` wurde rot an der Zählung
  der Regel-Zeile (Bericht §4) — er bricht laut. Der Zähler von
  [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  bleibt bei 2×: beide Paare (Bild-Digest, Vorab-Regel) tragen einen vergleichenden Fall.
- **[ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) steht auf `Proposed`.** Die Ebene der Exit-Klassen und der Wortlaut der Zeile
  `tap-<modus>: Exit <N>` binden erst mit dem Accept, einer Handlung des Auftraggebers. Ändert sich bei
  ihm ein Wortlaut, ziehen Skript-Kopf, Makefile-Kommentar, README-Zeile, Fälle und dieser Plan nach.
  — **Ausgang: weiter offen → Register**,
  [`bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md)
  (2×, `offen`). **Träger des Nachzugs:** heute hat er keinen Wächter; die Stellen stehen in der
  Evidence-Datei dieser Beobachtung, und der Umschnitt des Prozedur-Slice
  (`slice-tap-nachzug-ist-schritt-der-release-prozedur`, siehe §7 *Folge-Slices*) durch den Planner nimmt
  den Stand der Entscheidung als Prüfpunkt auf. Einen Nachzug führt der Implementer auf Auftrag des
  Planners aus (Modul 8, Übergabe Planner → Implementer).
- **Der Slice ist größer als eine Review-Sitzung.** Zwei Schichten (Werkzeug, Test) und drei
  Liefer-Punkte; die Rückführung steht in §4. — **Ausgang: entfallen.** Die Rückführung
  `in-progress → next` ist nicht eingetreten, die drei Liefer-Punkte hielten (Verifier §5: keine
  DoD-Verletzung). Gewachsen ist der Umfang **innerhalb** der Liefer-Punkte — Status-10-Kanal, Abbildung
  interner Fehler der Nutzlast, Zahlprüfung von `TAP_WAIT` (Verifier §6), vier Review-Runden —, kein
  vierter Liefer-Punkt.

## 7. Closure-Notiz

Geschrieben von der Rolle Planner in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach Review (Runde 1 bis 4) und Verifikation.

- **Was hat funktioniert:** Die Zähne trugen an den Stellen, an denen sie gefahren wurden. Der Review
  fand in Runde 1 zwei HIGH in der Suite selbst — das Token als zusätzliches Argument der
  Nutzlast ließ keinen Fall rot werden, weil eine Negation mitten im Fall wirkungslos ist — und in Runde 2
  einen HIGH, den kein Fall trug (ein Exit 1 des `docker`-Aufrufs selbst wurde als Formel-Unterschied
  gemeldet); Runde 4 endete ohne HIGH und MEDIUM. Der Verifier fuhr den realen Rot-Beleg selbst, die
  Transport-Klassen mit dem realen `docker` und die Token-Sonde; die Zähne 409 bis 434 wandte er nach seiner
  Aussage je in einer Scratchpad-Kopie an, die Tabelle des Berichts führt Meldung und Gegenprobe für die dort
  genannten Klassen (Bericht §3 und §4; grün heißt: die Zusicherung bindet).
- **Die Ebene, auf der der Exit-Vertrag gilt:** das **Skript**, nicht `make`
  ([ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md), `Proposed`). Über
  `make` endet jeder Fehlschlag mit Prozess-Exit 2 (GNU Make 4.3, vom Verifier gemessen); die Klasse trägt
  die letzte stderr-Zeile des Skripts `tap-check: Exit <N>`, genau einmal, bei Exit 1 und 2 — über
  `make tap-check` aus dem Wurzelverzeichnis die **vorletzte** Zeile, ihr folgt die Meldung von `make`.
  Gelesen wird die Zeile, nicht ihre Position.
- **Realer Rot-Beleg (Liefer-Punkt 3 (b)) — vom Verifier gefahren, datiert 2026-09-25, Tap `0.2.3`,
  ohne `TAP_TOKEN`** (Bericht §3.1): `TAG=v0.2.2 bash harness/tools/tap-nachzug.sh check` → Skript-Exit 1
  nach der Wiederholung des Lesens (65 s), Digest des Assets `9071e698…4089`, Digest des Tap-Kopfs
  `a5a1c165…da1f2`, erste abweichende Zeile des zweiten Lesens Zeile 11 (`version "0.2.2"` gegen
  `version "0.2.3"`), letzte stderr-Zeile `tap-check: Exit 1`. `make tap-check TAG=v0.2.2` → Prozess-Exit 2,
  die Zeile des Skripts als vorletzte Zeile, dahinter `make: *** [Makefile:493: tap-check] Fehler 1` (deutsche
  Locale; die Ziffer ist kein Vertrag). `v0.2.3` endet über Skript und `make` mit Exit 0. Die Ausgabe ist
  gelesen: Exit 1 ist ein Formel-Unterschied, kein Lesefehler. **Der Beleg gilt für den Tap-Stand am Tag der
  Messung** und wandert mit jedem Schnitt. `make tap-check TAG='v1.0.0$(id)'` (einfaches `$`) endet
  ebenfalls mit Exit 2, aber im Transport (Asset nicht auffindbar) statt in der Formprüfung: `make`
  wertet das Argument vor dem Skript aus — die im Plan benannte Grenze; die Form `v1.0.0$$(id)` endet in der
  Formprüfung (Bericht §3.1).
- **`make mutate` (Closure-Trigger 2 der Zähne):** Lauf-Zeile `mutate: 422 ok, 0 Befund(e)`, Kommando
  `make mutate`; die Fall-Zahl der Zeile ist die der Dateien (`ls test/mutations/*.sh | wc -l` → **422**,
  gemessen 2026-09-25), davon die Fälle dieses Slice `ls test/mutations/4{09..34}-*.sh | wc -l` → **26**.
  **Baum-Stand:** Commit `90be56c9` (00:44), Lauf laut Schlüsseldatei `.harness/state/mutate-passed.key` um
  01:25; zwischen beiden liegt kein Commit (`git log --format='%h %ad' --date=format:%H:%M -n 3` nennt
  `40c99693` 01:57, `90be56c9` 00:44, `37fd1e61` 00:44). Der Arbeitsbaum zum Zeitpunkt des Laufs ist nicht
  eigens belegt. **Nach dem Lauf sind nur der Verifikationsbericht und die Closure-Artefakte
  hinzugekommen:** `git diff --name-only 90be56c9..HEAD` → allein
  `docs/reviews/2026-09-25-verify-slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`,
  und `git diff --stat 90be56c9..HEAD -- harness test Makefile .d-check.yml` ist leer — kein Prüfgegenstand
  hat sich geändert, darum kein zweiter voller Lauf. Der Schlüssel selbst ist damit nicht neu berechnet
  (`isolation_key_files` in `harness/tools/mutate.sh` nimmt alles außer `.harness/state` und `.git`; der
  Bericht und diese Closure ändern ihn) — der Restzweifel des Verifiers (V-1, Ü-2) bleibt benannt und ist
  eine Beobachtung im Register.
- **Handoff-Zahlen, je mit ihrem Kommando** (gemessen 2026-09-25, keine Erwartungswerte):
  `grep -c '^@test' test/tap-nachzug.bats` → **37** Fälle (im Bild ohne Netz vom Verifier grün gefahren:
  0 `not ok`); `ls test/mutations/4{09..34}-*.sh | wc -l` → **26** Zähne;
  `ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` → **171** Verzeichnisse im Register.
- **Was ging anders als geplant — gebaut, aber nicht geplant.** Der Status-10-Kanal zwischen Nutzlast und
  Host-Skript samt seiner Restmenge (ein `docker`-Aufruf, der selbst mit 10 endet, gilt als Formel-Unterschied
  ohne Digests; vom Verifier gemessen, im Skript-Kopf und in §1 benannt), die Abbildung interner Fehler der
  Nutzlast auf Klasse 2 (`mktemp`, `cmp` mit Status 2, Kommando mit Status 1 oder ab 3) und die Zahlprüfung
  von `TAP_WAIT` (Verifier §6). Ursache: die Befunde der Runden 1 bis 3. Der Abnahme-Wortlaut wurde nach den
  Runden vom Planner nachgezogen (`bfae848f`, `0f6d569c`), nicht von der ausführenden Rolle
  ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Zähne über die Aufzählung der DoD hinaus: 418 bis 420, 424 bis
  426 und 434 (Verifier §2). Die Eingabe-Form der Plan-DoD für den lokalen Weg ist `v1.0.0$$(id)`; das einfache
  `$` fällt unter die benannte Grenze der Auswertung durch `make` (V-3, oben).
- **Zur Klausel *jeder Fall wird einmal unter der Schwächung rot gesehen* (Liefer-Punkt 2).** Getragen ist sie
  für die 26 Zähne (Lauf `422 ok`) und für die Sonden, die der Verifier zusätzlich fuhr (Token, Vorab-Kopplung,
  Negativ-Assertion des Transport-Falls, Tag-Form, Exit-Zeile, Bericht §4). **Nicht einzeln gegen die 37 Fälle
  abgezählt** ist, welche Fälle ohne Zahn und ohne Sonde des Verifiers bleiben; der Haken 2 stützt sich auf
  das Gesamturteil des Verifiers (*bestätigt, keine DoD-Verletzung*), nicht auf eine Liste je Fall.
- **`make gates` (Closure-Trigger 2):** Stempel `9308974eb29a…` am Stand `90be56c9` deckungsgleich
  (Verifier §1, `bash harness/tools/working-tree-hash.sh` gegen `.harness/state/gates-passed.diffsha`), Code
  seither unverändert (siehe oben); der Lauf über den Closure-Stand steht in der Übergabe an den
  Auftraggeber, nicht in dieser Datei.
- **Adressen vor dem Move (`AGENTS.md` §3.11):** kein eingefrorenes Artefakt nennt den Slice als Pfad —
  `git grep -nE 'in-progress/slice-tap-check|slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset\.md'`
  außerhalb der Plan-Datei selbst → kein Treffer (gemessen 2026-09-25); die Reviews und Berichte nennen die
  Kennung, keinen Pfad.
- **Steering-Loop-Eintrag (Form: benannte Spec-Lücke).** Die Fitness-Zeile *Rot-Beleg* der
  [ADR-0064](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  (`Accepted`) sagt für `make tap-check` gegen `v0.2.2` Exit 1 zu; über `make` endet der Prozess mit Exit 2.
  Die Lücke ist an ihrer Stelle benannt — in
  [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) (`Proposed`; Klasse gleich
  Exit des Skripts, Träger über `make` die Zeile des Skripts, Teil-Ablösung der drei betroffenen Stellen) und in
  Skript-Kopf, Makefile-Kommentar und README-Zeile. Dieser Lauf schreibt die ADR nicht um
  ([`AGENTS.md`](../../../../AGENTS.md) §3.4, §3.8); die Lücke bleibt eine Lücke, bis der Auftraggeber die
  ADR annimmt. Die Klasse dahinter — *eine Exit-Zusage für `make <ziel>`, am Skript gemessen* — steht als
  Beobachtung im Register
  ([`exit-zusage-aus-anderem-aufruf-abgeleitet`](../observations/BEO-ALL/exit-zusage-aus-anderem-aufruf-abgeleitet/observation.md),
  2×, `offen`). Kein `liegt in`: es wurde mit diesem Slice keine Regel an einem Zielort verkörpert.
- **Beobachtungs-Register (`../observations/`):** je Beleg
  `evidence/slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md`; Zähler gelesen am
  2026-09-25 mit `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  **Neu angelegt (je 1×, `offen`):**
  [`negation-mitten-im-bats-fall-ohne-wirkung`](../observations/BEO-ALL/negation-mitten-im-bats-fall-ohne-wirkung/observation.md)
  (Runde 1; der Bestand von 46 `!`-Zeilen in 15 anderen `bats`-Dateien ist **benannt, nicht gezählt** —
  wie viele davon mitten im Fall stehen und wirkungslos sind, ist nicht gemessen),
  [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  (der Wortlaut der `*)`-Meldung hängt allein an der Fall-Assertion; die Nachbarn
  `neuer-waechter-ohne-mutations-fall` und `zeichenmenge-mitglied-ohne-eigenen-zahn` decken die Ebene nicht) und
  [`weite-assertion-verdeckt-die-bindung-der-engen`](../observations/BEO-ALL/weite-assertion-verdeckt-die-bindung-der-engen/observation.md)
  (Verifier V-2). **Ergänzt, je eine Evidence-Datei:**
  [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  (der Ruhe-Marker der Roadmap; Zähler 4×, Stand `geplant` unverändert),
  [`waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)
  (Zähler 2×, `offen`; trägt die drei Risiken Fixture, Cache-Fenster und Lese-Limit als **eine**
  Gelegenheit),
  [`exit-zusage-aus-anderem-aufruf-abgeleitet`](../observations/BEO-ALL/exit-zusage-aus-anderem-aufruf-abgeleitet/observation.md)
  (2×, `offen`),
  [`mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf`](../observations/BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf/observation.md)
  (2×, `offen`) und
  [`bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md)
  (der Nachzug bei einem Accept von [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md); 2×, `offen`). **Nicht erhöht:**
  [`zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor`](../observations/BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor/observation.md)
  bleibt bei 2× — beide Paare tragen einen vergleichenden Fall (Kopplungsfälle `pin-kopplung:` und
  `vorab-tag: die Regel …`, Verifier §5) — und
  [`neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  (der Slice nennt seine Fälle 409 bis 434). **Lese-Schritt:** keine Beobachtung erreicht mit diesem Slice
  neu 3×; `eigentums-frage-…` steht über der Schwelle und trägt ihren Ausgang schon. **Keine Regel getragen
  haben** die Finding-Klassen der Review-Runden, die nirgends als Beobachtung stehen (etwa *Locale-abhängige
  Meldung als Zusage zitiert*, *Kommentar-Liste weicht vom Code ab*, *Prozess-Zustand im Plan-Fließtext
  überholt*): kein Eintrag ohne benannte Wiederkehr — sie bleiben in den Summary-Zeilen der Reports.
- **Folge-Slices:** *Adressen, keine Anlage in dieser Closure.*
  (1) `slice-tap-nachzug-ist-schritt-der-release-prozedur` (Datei in `open/`) — der Planner schneidet ihn um,
  bevor er `next/` wird: die Kontrolle liefert dieser Slice, der Prozedur-Wortlaut für den Formel-Unterschied
  ist *„`tap-check` rot mit der Zeile `tap-check: Exit 1`"* (die Zeile, nicht ihre Position), dazu
  `docs/user/releasing.md`; der Stand von [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) ist Prüfpunkt des Umschnitts (§6).
  (2) Der `sync`-Schnitt (Modus `sync`, `make tap-nachzug`) — **noch ohne Kennung und ohne Datei:** §1
  (*Ausdrücklich NICHT*, erster Punkt) ist seine Adresse; er zieht drei Zusagen aus `check` mit: den
  Status-10-Kanal samt Restmenge (Re-Evaluierungs-Trigger 3 von [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)), die Exit-Zeile mit `tap-sync:`
  und den Vergleich, der nur **einmal** im Code steht (Schritt g ist `check` erneut).
  (3) Der Job-Slice (Release-Job `tap`, Umgebung samt Tag-Regel, Secret `TAP_TOKEN`) — **noch ohne Kennung**,
  nach `sync`; Anlage von Umgebung und Secret ist Handlung des Auftraggebers (§1, zweiter Punkt).
  Die Frage nach der schreibenden Rolle des Ruhe-Markers ist keine Slice-Arbeit, sondern eine
  Architect-Frage; ihr Träger ist das Register (`eigentums-frage-…`).
- **Risiken aus §6:** sieben, je ein Ausgang — *entfallen* mit Grund: Byte-Treue, Vorab-Kopplung,
  Slice-Größe; *weiter offen → Register:* Fixture, Cache-Fenster und Lese-Limit
  (`waechter-misst-die-fixture-statt-der-realen-quelle`), [ADR-0066](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
  (`bedingung-ohne-traeger-im-lauf-den-sie-bindet`). Keines ist *eingetreten*.
- **Drei Paarungen:** Dieses Repo führt Wellen-Betrieb; sie prüft die nächste Welle-Closure — auch für
  diesen wellenlosen Slice (`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht, Tabelle *Träger im Repo
  ohne Wellen*). Der Slice trägt keinen Eintrag mit `liegt in` (Anker-Paarung ohne Gegenstand); der
  Folge-Slice mit Datei ist `slice-tap-nachzug-ist-schritt-der-release-prozedur`; jede genannte Beobachtung
  ist ein Verzeichnis mit nicht leerem `evidence/`.

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
