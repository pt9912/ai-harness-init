# Slice slice-tap-nachzug-sync-schreibt-die-formel-ins-tap: Der Modus `sync` schreibt die Formel ins Tap, `make tap-nachzug` fährt ihn, und Schritt 7 ruft das Ziel

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — es gibt keine Closure-Bedingung, die von der DoD dieses
Slice verschieden ist, siehe Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6).

**Ebene: Dogfood, Werkzeug-Slice mit Doku-Umbau.** Gegenstand sind das Skript
`harness/tools/tap-nachzug.sh` samt Nutzlast, das `make`-Ziel `tap-nachzug`, ihre Fälle und der Schritt 7
der Prozedur `docs/user/releasing.md`; kein Workflow, keine Umgebung, kein Secret.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Reproduzierbarkeit — der Nachzug schreibt die Bytes des veröffentlichten Assets, und der Transport läuft im
digest-gepinnten Bild),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(der Host braucht über `git`, `docker`, `make` und `bash` hinaus nichts),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — Festlegung 1 (Ablauf, Tag als Eingabe), Festlegung 3 (Vorwärts-Schutz, Idempotenz, Schreiben,
Nachkontrolle), Festlegung 4 (Umgang mit dem Token im Werkzeug), Festlegung 5 (Docker-only, Aufteilung
Host/Bild), Folgepflicht 1 und 3),
[`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
(**Accepted** — die Klasse des Skripts und die Zeile `tap-sync: Exit <N>`; Folgepflicht 1 und 2, und der
Anlass seines dritten Re-Evaluierungs-Triggers),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
(Muster des Transports), [`ADR-0003`](../../adr/0003-go-native-binaries.md) (Docker-only).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-25.

---

## 1. Ziel und Abgrenzung


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein lokal ausführbares `make tap-nachzug TAG=<tag>` zieht die Formel des Tags ins Tap nach — mit
`TAP_TOKEN` in der Umgebung des Aufrufers schreibt es die Bytes des veröffentlichten Assets, nur vorwärts und
idempotent, und kontrolliert danach; ohne `TAP_TOKEN` endet es laut mit Exit 2 vor jedem Netz-Zugriff — und
Schritt 7 von [`docs/user/releasing.md`](../../../user/releasing.md) ruft dieses Ziel statt der Handarbeit.

**Zur Frage, ob [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
den Modus als einen lieferbaren Slice festlegt** (Urteil des Planners, gelesen an Festlegung 1, 3, 4 und 5
und an der Fitness Function): ja. Ablauf, Schritte b bis g, Exit-Klassen, Vorwärts-Schutz, Idempotenz,
Optimistik, die Aufteilung Host/Bild und der Umgang mit dem Token stehen fest; der Modus hat einen Träger,
der ohne den Release-Job lieferbar ist (das lokale Ziel ist der Nachhol- und Ausfallweg, Festlegung 1). Zwei
Stellen legt die ADR nicht ganz fest und stehen als offene Fragen in §6, nicht als Entscheidung in diesem
Plan: die Zuordnung der Antworten der Schnittstelle jenseits von *Anmeldung, Schutz, Konflikt* und die
Eigentums-Frage.

**Der Zustand, an dem der Schnitt hängt** (gemessen am 2026-09-25):

- **`sync` endet mit Exit 2.** `bash harness/tools/tap-nachzug.sh sync` nennt *„der Modus sync ist nicht
  implementiert"* und schreibt `tap-sync: Exit 2`; das Skript ruft allein `check` auf
  (`grep -n 'tap-nachzug.sh' Makefile`), und ein Ziel für den Nachzug gibt es nicht
  (`grep -nE '^[a-z-]*tap[a-z-]*:' Makefile` → `tap-check`).
- **Schritt 7 trägt die Handarbeit** und vier Aussagen, die mit dem Ziel altern: der Nachzug als *„Handgriff
  dieses Schritts"*, das *„einzige Tap-Ziel im Makefile"* (dasselbe Kommando), *„ein Nachzug von Hand hat diesen
  Schutz nicht"* (der Vorwärts-Schutz steht allein bei der Vorbedingung) und das Kommando
  `grep -ci version harness/tools/tap-nachzug.sh harness/tools/tap-nachzug-nutzlast.sh` samt dem Satz
  *„Bytes, keine Versionen"* — sobald `sync` die `version`-Zeile liest, liefert das Kommando mehr als `0`. Dass
  der Slice für `sync` den Schritt umbaut, steht in keinem Artefakt, das der Lauf von `sync` als Eingang liest,
  außer in dieser Datei; das Register führt die Klasse als
  [`BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md).
- **Die Kontrolle besteht, und ihre Bausteine tragen `sync`:** die Nutzlast liest Asset und Tap, hält den
  Status-10-Kanal, den Token-Header in einer Datei mit Modus 0600 und die Wiederholung des Lesens; das Skript
  trägt Tag-Form, Feldform, Vorab-Regel, Pin-Prüfung und die Exit-Zeile `tap-<modus>: Exit <N>`. `sync` wächst
  darauf, statt neu anzufangen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Release-Job `tap`, die Umgebung samt Tag-Regel und das Secret `TAP_TOKEN`** — **Folge-Schnitt nach
  diesem Slice, noch ohne Kennung und ohne Datei:** die Adresse ist dieser Punkt und
  [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Folgepflicht 2 (Job `tap` in `release.yml` samt `bats`-Fall über die Job-Form). Der Job ruft das Ziel dieses
  Slice und ist ohne es nicht lieferbar; ein Schnitt vor dem Bedarf plante einen toten Slice. **Anlage von
  Umgebung, Tag-Regel und Secret ist Handlung des Auftraggebers außerhalb des Repos**
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 4); kein Token und kein Secret steht in einem Artefakt dieses Repos. **Der Umbau von Schritt 7
  für den Job** (die Handlung wird der Job, das Ziel der lokale Ausfallweg, die Meldung des Schnitts hängt
  weiter an `tap-check`) ist Bedingung *jenes* Schnitts und steht hier, damit sie im Eingang des Laufs steht,
  der ihn anlegt; Träger ist der Planner-Lauf, der den Job-Slice schneidet.
- **Mutations-Fälle in `test/mutations/` für die Wächter von `sync`** (Vorwärts-Schutz, Gleichstands-Vergleich,
  Feldform-Prüfung der `version`-Zeile, Idempotenz-Zweig, Nachkontrolle, Optimistik-Stand, Fehlt-Nachweis; die
  letzte Zeile der Fitness Function von
  [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)) —
  **Folge-Schnitt, noch ohne Kennung und ohne Datei:** Größe. Der Schnitt trüge zu den `bats`-Fällen von
  Liefer-Punkt 1 einen zweiten Satz Fälle mit je eigener Anker-Messung
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand))
  und sprengte die Review-Sitzung. **Was das kostet, steht in §6:** die `bats`-Fälle binden die Zusagen und
  werden einzeln rot gesehen (§2), `make mutate` hält ihre **Haltbarkeit** — die Entstehung der Zähne hängt
  an der Pre-completion-Checkliste, nicht an `make mutate`
  ([`AGENTS.md`](../../../../AGENTS.md) §3.6, Absatz *Feedback*). Bis der Folge-Schnitt besteht, ist `sync`
  im Sinn dieses Absatzes **ungelistet**, nicht unbewacht.
- **Die Antwort auf die Frage, welche Rolle den Nachzug fährt** — **keine Quelle benennt sie** (§6 Frage 1):
  der Schritt setzt ein Token in der Umgebung des Aufrufers voraus und nennt keine Rolle. **Kein Lauf dieses
  Slice schreibt ins reale Tap:** die Fälle laufen gegen Stubs, der Rot-Beleg am realen Zustand ist lesend
  (§2, Liefer-Punkt 1); der erste reale Nachzug ist Handlung des Auftraggebers und Beleg des Schreib-Pfads
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  §Grenze).
- **Der Zahn dafür, dass `check` keine Version liest** — **geliefert von
  `slice-tap-check-liest-keine-version-ist-gebunden`** (in `done/`): ein `bats`-Fall in
  `test/tap-nachzug.bats` und der Mutations-Fall
  `test/mutations/452-tap-check-liest-versionen-bei-ungleichen-bytes.sh` für `check`; der Absatz *Grenze* in
  Schritt 7 trägt seither die zwei Fälle, die er bindet, und die Zahl neben
  `grep -c '^@test' test/tap-nachzug.bats`. Dieser Slice schreibt die vier alternden Aussagen um, **ändert die
  Aussagen über den Zahn nicht** und nimmt den Absatz an seinem Start in dem Stand, in dem er liegt (§3); fügt
  er Fälle hinzu, misst er die Zahl neu.
- **Das Handbuch, Weg C** — **anderer Vorgang:** die Nutzer-Doku trägt den Ist-Zustand, ihr Update gehört zum
  Release-Schnitt; *„je Release-Schnitt … nachgezogen"* wird mit dem Job wahr, nicht mit dem Ziel.
- **Der Bezug [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) der Tap-Verteilung in
  `releasing.md` Schritt 5** — **Bestand bleibt bewusst stehen:** ob das Tap eine Anforderung des Lastenhefts
  wird oder der Bezug entfällt, entscheidet der Auftraggeber
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Folgepflicht 6).
- **Ein zweites Tap, weitere Dateien im Tap und der Erstbestand eines Tap ohne Formel-Datei** — **Bestand
  bleibt bewusst stehen:** die Grenze der ADR (*„ein Tap ohne Formel-Datei"*, Re-Evaluierungs-Trigger *„weitere
  Datei"*); der Nachzug schreibt nur über eine vorhandene Datei.

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Liefer-Punkt 1 — der Modus `sync` in Skript und Nutzlast:** `harness/tools/tap-nachzug.sh sync` läuft die
      Schritte b bis g von
      [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
      Festlegung 3 in der Aufteilung von Festlegung 5 (Host: Eingaben, Tag-Form, Feldform, Pin, Schritt b,
      Vorab-Regel, `docker run`; Bild: Feldform der `version`-Zeile, Vorwärts-Schutz, Vergleich, Schreiben,
      Nachkontrolle) und trägt Exit-Klassen und Zeile nach
      [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) (`tap-sync: Exit <N>`,
      bei Exit 1 und 2 genau einmal, bei Exit 0 nicht). Die `bats`-Fälle in `test/tap-nachzug.bats` sind die
      Zeilen der Fitness Function von
      [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md), die
      `sync` betreffen — die ADR ist die Quelle, dieser Plan schreibt keine zweite Tabelle: Tap ohne Formel-Datei
      → Exit 2 ohne Schreibzugriff · `sync` wiederholt das Lesen bis zum Schreiben nicht · Idempotenz (gleich →
      kein Schreibaufruf) · Vorwärts-Schutz nach Tap-Stand (kleiner → 2, größer und **Gleichstand** →
      schreibt, numerisch je Feld) · Lesbarkeit der `version`-Zeile (fehlt, mehrfach, außerhalb der Feldform →
      Exit 2, Meldung nennt die Zeile, nie `0.0.0`) · Fehlt-Nachweis (kein `TAP_TOKEN` → Exit 2 vor jedem
      Netz-Zugriff, Meldung nennt `make tap-nachzug`, vor der Vorab-Regel) · Vorab-Tag in `sync` (Exit 0,
      *„Vorab-Tag, Tap bleibt"*, ohne Netz) · Token nie in einer Kommandozeile und nie in der Ausgabe (Sentinel;
      Erfolg, Konflikt, Ablehnung; Kopfdatei Modus 0600, nach dem Lauf entfernt) · die geschriebenen Bytes sind
      die des Assets (Endzeilenumbruch, Nicht-ASCII-Byte) · optimistisch gegen den Blob-Stand der verglichenen
      Bytes, Konflikt → Exit 2 ohne zweiten Versuch · Schreiben ohne Antwort → Exit 2 mit *„Ausgang ungewiss"*
      und `make tap-check`, nicht *„unverändert"* · Nachkontrolle (Ungleich auch im Wiederholungslesen → Exit 1).
      **Je Fall die Schwächung, die ihn rot färbt (die Fitness Function der ADR nennt sie je Zeile); jeder Fall wird einmal rot
      gesehen, die Ausgabe gelesen; wo eine Zusage Exit 2 verspricht, prüft der Fall auch die Meldung.** Die
      Commit-Message des Nachzugs nennt den Tag und sagt nur zu, was das Werkzeug tut (Herkunft: das Asset des
      Tags) — keine Aussage über eine Digest-Prüfung, die es nicht führt. **Zusage, auf das Gehaltene
      eingeschränkt:** der Schreib-Pfad am **realen** Tap ist ohne Schreibzugriff auf ein Fremd-Repo nicht
      herstellbar; die Fälle fahren ihn gegen eine nachgebildete Schnittstelle, und der erste reale Nachzug des
      Auftraggebers ist sein Beleg (§Grenze der ADR) — nichts in diesem Slice behauptet ihn als bewiesen.
      **Rot-Beleg am realen Zustand, lesend (kein Gate):** `env -u TAP_TOKEN make tap-nachzug TAG=<Tag des Tap>`
      endet mit Prozess-Exit 2, die Ausgabe nennt das Ziel als Ausfallweg und trägt `tap-sync: Exit 2`, ohne
      dass ein Container startete; `make tap-check TAG=<Tag des Tap>` endet weiter mit Exit 0.
- [x] **Liefer-Punkt 2 — das Ziel `make tap-nachzug` und seine drei Träger:** das Rezept im `Makefile` ruft
      `bash harness/tools/tap-nachzug.sh sync` ohne make-Referenz auf den Tag und auf das Token (beide reisen als
      Umgebungsvariable; `make` selbst exportiert `TAG` von der Kommandozeile), steht in keiner
      Prerequisite-Kette und nicht in `gates` und `record-gates`, und sein Kommentar nennt Netz, Token und die
      Ebene der Klassen nach
      [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Folgepflicht 1. Die
      Zeile `make tap-nachzug` in [`harness/README.md`](../../../../harness/README.md) §Werkzeuge trägt `kein Gate`
      und die Bindung, und `targets.exempt-targets` der [`.d-check.yml`](../../../../.d-check.yml) führt das Ziel
      exakt (kein Glob). Ein `bats`-Fall liest die Rezeptzeilen von `tap-nachzug` (kein `$(TAG)`, kein `${TAG}`).
      **Rot, wenn:** die README-Zeile **und** der Eintrag fehlen — `make docs-check` färbt sich dann (`targets`,
      Meldung `gate-undocumented`); die Gegenprobe ist, beide testweise zu entfernen und die Meldung zu lesen. Jeder
      Träger allein lässt das Gate grün, weil Zeile und Eintrag einander als Deklaration genügen; dass jeder
      einzeln steht, halten der Review und der Verifier, kein Sensor. `make gates` fährt das Ziel **nicht**.
- [x] **Liefer-Punkt 3 — der Umbau von Schritt 7 in `docs/user/releasing.md`:** die Handlung des Schritts ist der
      Aufruf `make tap-nachzug TAG=<tag>` mit `TAP_TOKEN` in der Umgebung des Aufrufers (Anlage und Ablage des
      Tokens sind Handlung des Auftraggebers außerhalb der Prozedur; **keine Rolle** als Ausführende, §6
      Frage 1); der Beleg bleibt `make tap-check TAG=<tag>`. **Die vier Aussagen, die mit `sync` falsch
      werden, sind gezogen:** der Nachzug ist kein *„Handgriff dieses Schritts"* mehr; *„das einzige Tap-Ziel im
      Makefile ist `tap-check`"* (`grep -nE '^[a-z-]*tap[a-z-]*:' Makefile` nennt zwei Ziele) ist gestrichen oder
      wahr; der Vorwärts-Schutz steht als Eigenschaft des Werkzeugs (Exit 2 vor dem Schreibzugriff, Zeile
      `tap-sync: Exit 2`) statt als Vorbedingung, die *„der Satz trägt"*; und das Kommando
      `grep -ci version …` samt *„Bytes, keine Versionen"* ist ersetzt — es liefert mit `sync` mehr als `0`.
      Die Klassen von `tap-sync` (0, 1 Nachkontrolle ungleich, 2 nicht ausführbar einschließlich
      Vorwärts-Schutz, Ablehnung und *„Ausgang ungewiss"*) stehen so, wie das Skript sie liefert; jede
      Wiedergabe ist gegen das Skript gefahren, nicht gegen diesen Plan (die Klasse
      [`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
      steht bei 2×). Jede Schritt-Nummer, die ein lebendes Artefakt nennt, stimmt nach dem Umbau; die
      Nummern der Prozedur ändern sich nicht (Schritt 7 bleibt Schritt 7). **Rot, wenn:** eine der vier
      Aussagen nach dem Slice noch steht (`grep -n 'Handgriff' docs/user/releasing.md`, das Kommando
      `grep -ci version …` in Schritt 7, *„einzige Tap-Ziel"*) oder wenn eine zitierte Klasse oder Meldung nicht
      der Ausgabe des Skripts entspricht. **Deckung, benannt:** kein Test und kein Gate hält `releasing.md` gegen
      die Ausgabe des Skripts; Träger sind der Review und der Verifier, der die Aussagen fährt
      ([`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: die README-Zeile und der Umbau von Schritt 7 sind Liefer-Punkt 2 und 3; das Handbuch
      (Weg C) bleibt unberührt (§1), sein Wortlaut wird gegen den Ist-Zustand gelesen und in §7 vermerkt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag; sie trägt das **Trigger-Audit der ADR-Klasse** für
      [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) (dritter
      Re-Evaluierungs-Trigger: entsteht mit `sync` ein Ergebnis der Nutzlast außerhalb von *gleich*,
      *Unterschied*, *nicht ausführbar*, oder liest ein zweiter Aufrufer die Klasse aus der Nutzlast statt aus
      dem Skript?) — das Verdikt ist Architect-Arbeit, die Frage stellt der Planner.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. Erwartet: Belege für die in §8 benannten Einträge — ob sie zählen, urteilt die Closure.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)


Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/tap-nachzug.sh` | update | Liefer-Punkt 1: der Modus `sync` statt Exit 2; Schritt b (Token vorhanden) vor der Vorab-Regel und vor jedem Netz-Zugriff; Kopfkommentar zieht (Modus, Exit-Klassen, Grenze) |
| `harness/tools/tap-nachzug-nutzlast.sh` | update | Liefer-Punkt 1: Feldform der `version`-Zeile, Vorwärts-Schutz, Schreiben (Base64 ohne Umbruch, Blob-Stand der verglichenen Bytes, Kopfdatei 0600), Nachkontrolle, Unterscheidung *abgelehnt* gegen *Ausgang ungewiss* |
| `test/tap-nachzug.bats` | update | Liefer-Punkt 1 und 2: die Fälle aus Liefer-Punkt 1 gegen den `curl`-Stub (er lernt den Schreibaufruf, zählt Lese- und Schreibaufrufe, zeichnet Argumentliste und mitgesandten Stand auf); der Textfall über die Rezeptzeilen von `tap-nachzug` |
| `Makefile` | update | Liefer-Punkt 2: das Ziel `tap-nachzug` neben `tap-check`, mit Kommentar |
| `harness/README.md` | update | Liefer-Punkt 2: die Zeile `make tap-nachzug` (§Werkzeuge, `kein Gate`) |
| `.d-check.yml` | update | Liefer-Punkt 2: `targets.exempt-targets` um `tap-nachzug` (exakt) |
| `docs/user/releasing.md` | update | Liefer-Punkt 3: Schritt 7 — Handlung, Vorbedingung, die vier alternden Aussagen, Klassen von `tap-sync` |

- **Schichten: zwei.** Werkzeug (Skript, Nutzlast, Ziel, Fälle, README-Zeile, Gate-Config) und Nutzer-Doku
  (Prozedur). Kein Workflow, keine Umgebung, kein Secret.
- **Der Stand von Schritt 7 wird an der Basis gemessen, nicht aus diesem Plan übernommen:** die Wortlaute der
  vier Aussagen stehen hier als Beschreibung; der Implementer liest `docs/user/releasing.md` an seinem Start
  (`grep -nE 'Handgriff|einzige Tap-Ziel|grep -ci version|Vorwärts-Schutz' docs/user/releasing.md`) und nimmt
  den Absatz *Grenze* in dem Stand, in dem er liegt — er trägt seit `slice-tap-check-liest-keine-version-ist-gebunden`
  zwei Fälle mit ihren Namen und die Zahl neben `grep -c '^@test' test/tap-nachzug.bats`, und der Umbau baut darauf auf.
- **Nummern:** Schritt 7 bleibt Schritt 7; die Nennungen einer Schritt-Nummer in `releasing.md`
  (`grep -nE 'Schritte? [0-9]' docs/user/releasing.md`) und im Zustandsfeld von
  `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` bleiben wahr. Die Messung über beide Adress-Formen
  (Wort *„Schritt"* mit Ziffer, Anker auf die Schritt-Zeile) wiederholt der Implementer nach dem Umbau.
- **Transport:** das Bild ist das digest-gepinnte von `make traeger-fetch`; die Nutzlast ruft nur Programme
  des gemessenen Bestands (`curl`, `base64` mit `-w`, `cmp`, `sha256sum`, `sha1sum`, `sed`, `awk`, `wc`, `grep`,
  `mktemp`, `sleep`, Builtins) — die Sonde `command -v <Programm>` im Bild ist der Beleg, wenn eines dazukommt
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 5).

## 4. Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Vor `open` → `next`** (Priorisierung, Entscheidung des Auftraggebers): der bewegende Lauf misst nach
[`AGENTS.md`](../../../../AGENTS.md) §3.11 und
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4, ob ein
eingefrorenes Artefakt diese Datei als Pfad nennt — über beide Adress-Formen (Code-Span-Pfad und
Markdown-Link). Der Befund am Tag des Schnitts: kein Artefakt nennt sie
(`grep -rnI --exclude-dir=.git --exclude-dir=.harness -E 'slice-tap-nachzug-sync-schreibt-die-formel-ins-tap\.md|open/slice-tap-nachzug-sync-schreibt-die-formel-ins-tap|\]\(slice-tap-nachzug-sync-schreibt-die-formel-ins-tap' . | grep -v 'planning/done/slice-tap-nachzug-sync-schreibt-die-formel-ins-tap.md' | wc -l`
→ **0**, gemessen 2026-09-25; vor dem Move erneut: **1**). Der eine Treffer ist ein Verzeichnis-Glob
(`ls docs/plan/planning/*/slice-tap-nachzug-sync-schreibt-die-formel-ins-tap.md`) in der Closure-Notiz des
Vorgänger-Slice in `done/`: er ist an kein Lifecycle-Verzeichnis gebunden, bleibt nach dem Move wahr und wird vom
Werkzeug nicht ersetzt; die übrigen Nennungen der Kennung in `done/`, `docs/reviews/**` und dem Register sind Text
ohne Pfad-Adresse. Kein eingefrorenes Artefakt nennt die Datei mit ihrem Ort `open/` als Pfad.

**Start** (`next` → `in-progress`): `Verantwortlich:` gesetzt, WIP-Limit frei, §6 Frage 2 (Antworten der
Schnittstelle jenseits von *Anmeldung, Schutz, Konflikt*) vom Architect beantwortet **oder** vom Implementer
im Bericht mit der sicheren Richtung (*Ausgang ungewiss* und `make tap-check`) zugeordnet und dem Review
vorgelegt. Frage 1 braucht **keine Antwort** zum Start — der Schritt nennt keine Rolle, und kein Lauf schreibt
ins reale Tap. Der Stand der Entscheidungen ist gemessen:
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) und
[`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) stehen auf `Accepted`
(`grep -nE '^\| \[ADR-006[46]\]' docs/plan/adr/README.md`).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Review hält Liefer-Punkt 1 in einer Sitzung
  nicht für prüfbar — der Vorgänger-Slice für `check` trug bei drei Liefer-Punkten vier Review-Runden, und
  `sync` trägt mehr Zusagen als `check`. **Die Naht** liegt zwischen den Schritten b bis e (Token, Vorab-Regel,
  Vorwärts-Schutz, Vergleich — nie ein Schreibaufruf) und f bis g (Schreiben, Optimistik, *Ausgang ungewiss*,
  Nachkontrolle). Die erste Hälfte allein ist **nicht lieferbar** (ein `sync`, das nie schreibt, hat keinen
  Lieferwert), darum wird sie hier nicht vorab geschnitten; sie ist die Rückführung, wenn die Größe sich
  zeigt, und der Rest geht als Folge-Slice mit Kennung an den Planner zurück.
- `in-progress` → `open` (blockiert): §6 Frage 2 bleibt unbeantwortet und der Implementer trägt keine Zuordnung
  (der Schreib-Ausgang wäre erfunden) — dann geht die Frage an den Architect, nicht in diesen Slice.

## 5. Closure-Trigger


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make test` ist grün mit den Fällen aus Liefer-Punkt 1 und 2, und der
Review-Report belegt je Zusage die Schwächung, die ihren Fall rot färbt, mit gelesener Ausgabe; der Lauf
`env -u TAP_TOKEN make tap-nachzug TAG=<Tag des Tap>` endet mit Prozess-Exit 2, der Zeile `tap-sync: Exit 2` und
ohne Container-Start. (2) `make docs-check` und `make gates` sind grün, und die vier Aussagen aus §1 stehen
in `docs/user/releasing.md` nicht mehr (`grep -n 'Handgriff' docs/user/releasing.md`; das Kommando
`grep -ci version …` steht in Schritt 7 nicht mehr als Beleg der Eigenschaft); jede in Schritt 7 zitierte
Klasse oder Meldung stimmt mit einem Lauf des Skripts überein. Dazu der Lerneintrag in §7 in einer der drei
Formen. **Kein Kriterium sagt zu, dass der Nachzug am realen Tap gelingt** — dieser Beleg entsteht mit dem
ersten realen Nachzug des Auftraggebers und steht danach als Beobachtung im Register.

## 6. Risiken und offene Punkte


Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

**Offene Fragen — jede mit Adresse, keine im Slice entschieden.**

1. **Welche Rolle fährt den Nachzug?** Keine Quelle benennt es: die Prozedur nennt für ihre Schritte keine
   ausführende Rolle, und [`AGENTS.md`](../../../../AGENTS.md) §3.8 und §3.10 binden nur Norm-Artefakte und den
   Abschluss. Der Nachzug schreibt in ein Repo außerhalb dieses Baums und braucht ein Token, das der
   Auftraggeber hält. Eine Erlaubnis, die der Auftraggeber im laufenden Auftrag ausspricht, ist eine Aussage
   dieses Auftrags und kein Artefakt; Schritt 7 und jeder DoD-Punkt stützen sich nicht auf sie. Das ist die
   Klasse
   [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
   (Stand dort: geplant — Kennung
   [`ADR-0062`](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md),
   `Proposed`, zurückgestellt). **Adresse der Frage:** dieser Eintrag und diese ADR. Führt ein Lauf den
   realen Nachzug faktisch aus und übernimmt die Prozedur seine Rolle, ist das ein weiterer Beleg der Klasse
   und keine Entscheidung. Der Implementer dieses Slice führt ihn nicht aus.
2. **Wie ordnet `sync` Antworten der Schnittstelle beim Schreiben zu, die weder *Anmeldung*, *Schutz des
   Branches* noch *Konflikt* sind?** Die ADR sagt: ausdrücklich abgelehnt (Anmeldung, Schutz, Konflikt) →
   Exit 2 und *„Tap unverändert"*; ohne Antwort (Zeitüberschreitung, Verbindungsabbruch nach dem Senden) →
   Exit 2 und *„Ausgang ungewiss"*. Eine Antwort mit einem Serverfehler oder einem anderen Erfolgscode ist
   keines von beidem. **Adresse:**
   [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
   Festlegung 3, Absatz nach Schritt g. **Übergabe an den Architect**, wenn der Implementer keine Zuordnung
   aus der ADR liest. Der Plan legt sie nicht fest; als Ausgangslage für die Klärung: *„Tap unverändert"* sagt
   das Werkzeug nur, wo die Schnittstelle es ausdrücklich abgelehnt hat — jede andere Antwort endet in
   *„Ausgang ungewiss"*, die sichere Richtung, denn diese Meldung nennt `make tap-check`.
   **Stand der Closure:** vom Architect beantwortet — die Zuordnung des Codes (200 → Nachkontrolle; 401, 403 und 409
   → *„Tap unverändert"*; alles andere und keine Antwort → *„Ausgang ungewiss"*) steht als **Setzung** in
   [`ADR-0068`](../../adr/0068-der-nachzug-nennt-den-zustand-des-tap-nur-soweit-die-antwort-ihn-traegt.md)
   (`Proposed`; die Annahme der ADR steht beim Auftraggeber, der Slice wartete nicht darauf).
   **Frage 1 bleibt unbeantwortet** — ihre Adresse ist unverändert.

**Risiken:**

Jedes Risiko trägt einen Ausgang, zugewiesen bei der Closure am 2026-09-26; keines ist *eingetreten*.

- **Der Slice ist für eine Review-Sitzung zu groß** — drei Liefer-Punkte, zwei Schichten, aber das Gewicht liegt
  in Liefer-Punkt 1. **Ausgang:** *entfallen* — der Review trug den Diff in einer Runde (0 HIGH, 1 MEDIUM, 3 LOW,
  3 INFO), und der Verifier fand kein Anzeichen für einen Rückgang nach `next/`. Vorbehalt: die drei Commits
  nach dem Review hat nur der Verifier gelesen (§7).
- **Der Schreib-Pfad ist nur gegen eine nachgebildete Schnittstelle geprüft.** Ein Stub bildet Antwortform und
  Statuscodes nach; ob das reale Tap dieselbe Form liefert, misst allein ein realer Nachzug. **Ausgang:** *weiter
  offen* →
  [`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  (verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.6: die Zusage auf das einschränken, was der Code hält —
  Liefer-Punkt 1 und der Absatz *Handlung* in Schritt 7 tun es); der erste reale Nachzug ist der Beleg, nicht
  dieser Slice. Das Register führt keinen neuen Beleg: kein Vorgang brach die Regel.
- **`sync` bleibt ohne Mutations-Fälle, bis der Folge-Schnitt (§1) besteht.** Die Zähne sind `bats`-Fälle, einmal
  rot gesehen; ihre Haltbarkeit hält kein `make mutate`. **Ausgang:** *weiter offen* →
  [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  — mit diesem Slice **3×** (Beleg angelegt, Zähler in §7), Stand *geplant*: der Folge-Schnitt ist als Datei
  angelegt (`slice-sync-waechter-tragen-mutations-faelle`).
- **Ein Lauf schreibt ins reale Tap, bevor die Eigentums-Frage beantwortet ist** — etwa der Verifier, der den
  Schreib-Pfad *real* belegen will. **Ausgang:** *entfallen* — kein Lauf hat es getan: der Verifier las das Tap
  (`make tap-check`) und rief `make tap-nachzug` ohne Token auf (Exit 2 vor jedem Netz-Zugriff), der Implementer
  und der Reviewer schrieben nicht. §2 führt den Schreib-Pfad als Handlung des Auftraggebers.
- **Schritt 7 wird mit dem Job-Schnitt erneut falsch**, wenn dessen Umbau (§1, erster Punkt) nicht im Eingang
  des Laufs steht, der den Job-Slice schneidet. **Ausgang:** *weiter offen* →
  [`BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md)
  — die Adresse hat jetzt eine Datei: `slice-release-job-tap-nachzug-und-schritt-7-folgt` (`open/`) trägt die
  Bedingungen in seinem §1; der Eintrag ist mit dieser Closure im Anweisungssatz der Planner-Rolle verkörpert,
  und ein Sensor besteht nicht (Grenze im `state.md` des Eintrags).

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

Geschrieben von der Rolle Planner in frischem Kontext
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach Review und Verifikation und nach dem Verdikt des Architect.

- **Was hat funktioniert:** Der Schnitt hielt: drei Liefer-Punkte, zwei Schichten, ein Review in einer Runde
  (0 HIGH, 1 MEDIUM, 3 LOW, 3 INFO) und eine Verifikation ohne HIGH. Der Verifier fuhr am 2026-09-26 den Rot-Beleg
  am realen Zustand, lesend: `env -u TAP_TOKEN make tap-nachzug TAG=v0.2.4` endete mit Prozess-Exit 2, nannte den
  Ausfallweg und trug `tap-sync: Exit 2` genau einmal; `make tap-check TAG=v0.2.4` endete mit Exit 0, und
  `make tap-check TAG=v0.2.3` mit Exit 1 (erste abweichende Zeile die `version`-Zeile). Dass kein Container
  startete, ist aus der Reihenfolge im Skript geschlossen und durch die Schwächung *„Token-Nachweis am Host
  entfernt"* belegt; ein Container-Zähler am realen Lauf wurde nicht gemessen. **Ergebnis-Fakten** (gemessen
  2026-09-26, keine Erwartungswerte): `grep -c '^@test' test/tap-nachzug.bats` → **53**;
  `git diff --shortstat 3256c64d..c45140c1` → **11** Dateien, **844** Einfügungen, **98** Löschungen;
  `grep -ln sync test/mutations/*.sh | wc -l` → **0**. Der Schreib-Pfad am realen Tap ist **nicht** gefahren und
  nirgends als bewiesen behauptet: die Fälle laufen gegen einen `curl`-Stub, der erste reale Nachzug des
  Auftraggebers ist sein Beleg.
- **Was ging anders als geplant:** Der Review las den Commit `bced82b9` und fand R-1 (MEDIUM: der Header am
  Schreibaufruf war ungebunden, eine Schwächung überlebte), R-2 (die Meldung nach einem vollzogenen Schreiben mit
  unlesbarem Tap), R-3 (Wortzähler-Begründung), R-4 (Konjunktiv im Kommentar) und drei INFO. Der Implementer zog
  R-1, R-2 und R-4 in `bb583255`, den Anker von Fall 418 in `0d057bbe` und R-2, R-3 und R-6a in `c45140c1`.
  **Diese drei Commits hat kein Reviewer gelesen; nur der Verifier** las und fuhr sie (16 Schwächungen und vier
  Gegenproben in Scratchpad-Kopien). Eine zweite Reviewer-Runde ist nicht gelaufen und wird nicht behauptet; das
  Häkchen *Review durchgeführt* bestätigt die Runde 1 mit ihren gezogenen Findings. **`make mutate` ist nicht als
  Ganzes gefahren:** gemessen ist eine Teilmenge — die 27 Bestandsfälle, die `tap-nachzug` berühren, je einzeln am
  HEAD-Stand emuliert, alle färben mit ihrem `# expect:`-Text; **kein** `sync`-eigener Fall besteht (0 Dateien,
  siehe oben), und ein Beleg-Slot ist nicht geschrieben. `make full-smoke` ist nicht gemessen.
- **Planner-Korrektur an der Abnahme (Liefer-Punkt 2).** Die DoD sagte *„`make docs-check` färbt sich in beiden
  Fällen"*. Der Verifier maß in vier Kopien (V-1): Eintrag allein entfernt → Exit 0; README-Zeile allein entfernt →
  Exit 0; beides → Exit 2 mit `gate-undocumented`. Die Zusage war breiter als der Sensor, und der Code war richtig.
  Die ausführende Rolle schreibt ihr Abnahmekriterium nicht um; der Planner hat den Wortlaut **auf das Gemessene**
  gesetzt (das Gate färbt sich, wenn **beide** Träger fehlen; jeder einzeln steht durch Review und Verifier, kein
  Sensor bindet ihn) und das Häkchen danach gesetzt. Die Aussage in Folgepflicht 1 von
  [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  (*„ohne Eintrag färbt das Doku-Gate im ersten Lauf rot"*) bleibt: der Architect hält sie für die Begründung der
  Pflicht, nicht für eine Zusage, die ein Lauf trägt — ein akzeptiertes Negativ, kein Folge-ADR.
- **Doku-Update — Handbuch Weg C bleibt unverändert.** Der Satz *„je Release-Schnitt … nachgezogen"* ist mit dem
  Ziel nur als Handlung des Aufrufers wahr; mit dem Job als Regelweg wird er wahr
  (`slice-release-job-tap-nachzug-und-schritt-7-folgt`, angelegt), belegt erst mit dem ersten Tag-Lauf. Ein Träger
  dafür besteht nicht — das Handbuch-Update gehört zum Release-Schnitt.
- **Steering-Loop-Eintrag (Form: geschärfte Regel).** Die Bedingung, dass der Umbau einer Aussage im Eingang des
  Laufs steht, der ihn auslöst, steht als Zeile im Anweisungssatz der Planner-Rolle, geschrieben vom Planner nach
  dem Verdikt des Architect (Frage 4); Original ist das Baseline-Regelwerk `modul-05-planning-harness.md`
  §Ziel-Form: Slice, §1 Klasse 1. liegt in `.claude/commands/plan-welle.md §Slices bereitstellen`
  · seit slice-tap-nachzug-sync-schreibt-die-formel-ins-tap. **Grenze:** ein Wächter existiert nicht — die Zeile
  ist Feedforward; **kein Wächter hält `docs/user/releasing.md` gegen die Ausgabe des Skripts** (R-3, V-2 und V-3
  fanden nur der Review und der Verifier). Tritt die Klasse nach der Zeile erneut ein, ist die Trägerschaft der
  Befund und die Hard Rule der nächste Schritt (Architect, `AGENTS.md` §3.8). **Zusätzlich benannt, nicht
  geschrieben:** die Norm-Lücke zu R-2 und R-5 (die Meldung nach einem vollzogenen Schreiben, die Ablehnungs-Menge)
  hat der Architect als Setzung in
  [`ADR-0068`](../../adr/0068-der-nachzug-nennt-den-zustand-des-tap-nur-soweit-die-antwort-ihn-traegt.md)
  formuliert — **`Proposed`**; die Annahme steht beim Auftraggeber nach einer Reviewer-Runde, und dieser Abschluss
  stützt sich nicht auf sie.
- **Trigger-Audit der ADR-Klasse (dritter Re-Evaluierungs-Trigger von
  [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)):** **nicht eingetreten** —
  Verdikt des Architect vom 2026-09-26 zu diesem Slice (Kennung `architect-verdikt-slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`,
  Frage 1). Die Nutzlast beendet mit genau drei Status (0, 10, 2; `grep -nE 'exit (0|10|2)\b|beende 2' harness/tools/tap-nachzug-nutzlast.sh`),
  die neuen Ausgänge von `sync` sind Status 2 mit eigener Meldung, und der einzige produktive Leser der Nutzlast ist
  `harness/tools/tap-nachzug.sh`. Trigger 1 derselben ADR (*„ein Aufrufer braucht die Klasse am Prozess-Exit"*) hat
  mit dem Release-Job einen neuen möglichen Anlass; die Frage steht im Eingang des Laufs, der den Job schneidet
  (§1 des Slice `slice-release-job-tap-nachzug-und-schritt-7-folgt`). Carveouts und Reifestufen berührt der Slice
  nicht.
- **Beobachtungs-Register (`../observations/`):** je Beleg
  `evidence/slice-tap-nachzug-sync-schreibt-die-formel-ins-tap.md`; Zähler gelesen am 2026-09-26 mit
  `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  **Ergänzt:**
  [`prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
  (R-3, V-3; **3×**),
  [`zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  (die `sync`-eigenen Zusagen; **3×**),
  [`abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`](../observations/BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt/observation.md)
  (V-1; **7×**, verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.10) und
  [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  (der Ruhe-Marker im Claim-Commit `5effdc6f`; **9×**, Stand `geplant` unverändert; §6 Frage 1 ist **kein**
  Beleg). **Neu angelegt (1×, `offen`):**
  [`zusage-ueber-jeden-aufruf-bindet-nicht-den-aufruf-der-sie-traegt`](../observations/BEO-ALL/zusage-ueber-jeden-aufruf-bindet-nicht-den-aufruf-der-sie-traegt/observation.md)
  (R-1: die Assertion über *jede* Kopfdatei ließ die Schwächung am Schreibaufruf überleben). **Nicht gezählt:**
  [`weite-assertion-verdeckt-die-bindung-der-engen`](../observations/BEO-ALL/weite-assertion-verdeckt-die-bindung-der-engen/observation.md)
  (**1×**; dort färbt die weite Assertion die Mutation, hier färbte nichts),
  [`prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)
  (**2×**; kein Schritt wurde übersprungen, und die Wortlaut-Funde zählen unter *prozedur-wiedergabe* — dieselbe
  Fund-Menge unter zwei Namen wäre ein künstlicher dritter Beleg),
  [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (**32×**; die vier Aussagen wurden im selben Slice gezogen, ein Fix ließ keine stehen) und
  [`zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  (der Schreib-Pfad ist auf das Gehaltene eingeschränkt, die Regel wurde nicht gebrochen). Die Vorkommen
  R-2 und R-5 sind durch den Architect in
  [`ADR-0068`](../../adr/0068-der-nachzug-nennt-den-zustand-des-tap-nur-soweit-die-antwort-ihn-traegt.md) gefasst und
  führen keinen eigenen Eintrag.
  **Lese-Schritt:** mit diesem Slice erreichen **drei** Einträge die Schwelle **3×**.
  `bedingung-ohne-traeger-im-lauf-den-sie-bindet` (3× seit dem Vorgänger-Slice) bekommt den Ausgang
  *verkörpert* — Zielort `.claude/commands/plan-welle.md`, Anker `seit slice-tap-nachzug-sync-schreibt-die-formel-ins-tap`,
  Grenze *„Ein Wächter existiert nicht"* im `state.md`. `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` bekommt
  *geplant* mit der Kennung `slice-sync-waechter-tragen-mutations-faelle` — **für die Instanz**; ob das die Klasse
  trägt oder eine Regel verlangt, ist Übergabe an den Architect. `prozedur-wiedergabe-…` bleibt `offen` über der
  Schwelle: `geplant` braucht einen Slice, der die Regel oder den Sensor schreibt (keiner besteht), `verkörpert` ein
  Norm-Artefakt des Architect; Übergabe. `eigentums-frage-…` trägt ihren Ausgang schon.
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** kein eingefrorenes Artefakt nennt den
  Slice als Pfad. Das Kommando aus §4 trifft außerhalb dieser Datei eine Zeile in `done/`
  (`grep -rnI --exclude-dir=.git --exclude-dir=.harness -E 'slice-tap-nachzug-sync-schreibt-die-formel-ins-tap\.md|(open|next|in-progress)/slice-tap-nachzug-sync-schreibt-die-formel-ins-tap|\]\(slice-tap-nachzug-sync-schreibt-die-formel-ins-tap' . | grep -v 'planning/done/slice-tap-nachzug-sync-schreibt-die-formel-ins-tap.md' | wc -l`
  → **1**, gemessen 2026-09-26): der Verzeichnis-Glob in der Closure-Notiz des Vorgängers, der an kein
  Lifecycle-Verzeichnis gebunden ist. Reports, Verdikt und ADR nennen die Kennung ohne Pfad.
- **Folge-Slices:** zwei, beide als Datei in `open/` angelegt (Kennungen, keine Pfade): `slice-release-job-tap-nachzug-und-schritt-7-folgt`
  (der Job `tap` samt Umbau von Schritt 7, den Bedingungen des Gebers und der Frage von Trigger 1; **Umgebung und
  Secret `TAP_TOKEN` bleiben Handlung des Auftraggebers** und sind Start-Bedingung dort) und
  `slice-sync-waechter-tragen-mutations-faelle` (die `sync`-eigenen Zähne und der Absatz *Grenze*). **Verantwortlich**
  ist offen; der Auftraggeber priorisiert.
- **Vermerke aus Review und Verifikation:** V-2 (*„die Wächter von `sync`"* meint die `sync`-eigenen; gemeinsame
  Wächter färben `sync`-Fälle mit) geht an den Mutations-Slice (Liefer-Punkt 3); V-3 (der Vorab-Satz gilt ohne
  `TAP_TOKEN` nicht) und R-6b (der Satz *„die Prozedur nennt keine ausführende Rolle"* spricht über die eigene
  Abwesenheit) gehen an den Job-Slice (§1); R-6c ist V-3; R-6a ist gezogen.
- **Übergaben:** *An den Architect:* (1) trägt `geplant` für `zusage-mit-bats-bindung-…` die Instanz allein, oder
  braucht die Klasse eine Regel; (2) der Ausgang für `prozedur-wiedergabe-…` (3×); (3) die Reviewer-Runde für
  [`ADR-0068`](../../adr/0068-der-nachzug-nennt-den-zustand-des-tap-nur-soweit-die-antwort-ihn-traegt.md) vor der
  Annahme. *An den Auftraggeber:* der Accept von
  [`ADR-0068`](../../adr/0068-der-nachzug-nennt-den-zustand-des-tap-nur-soweit-die-antwort-ihn-traegt.md); der erste reale Nachzug samt gelesener Ausgabe (Beleg
  des Schreib-Pfads und der Setzung); Umgebung und Secret, sobald der Job-Slice priorisiert wird.
- **Risiken aus §6:** fünf, je ein Ausgang — *entfallen* mit Grund: die Größe (der Review trug den Diff in einer
  Runde), ein Schreiben ins reale Tap (kein Lauf hat es getan); *weiter offen → Register:* der Schreib-Pfad nur
  gegen eine nachgebildete Schnittstelle (`zusage-ohne-herstellbares-gegenbeispiel`), `sync` ohne Mutations-Fälle
  (`zusage-mit-bats-bindung-…`, mit einer Folge-Slice-Datei) und Schritt 7 beim Job-Schnitt
  (`bedingung-ohne-traeger-…`, mit der Datei des Job-Slice). Keines ist *eingetreten*.
- **Drei Paarungen:** folgen nach dem Move; ihr Ergebnis steht unten.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) für Doku und Fälle, dazu
`harness/tools/` (Skript und Nutzlast). Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md) führt beide als eigene Zeilen (`*`, `harness/tools/`),
beide Greenfield; beide erfüllen die Schwelle ≥ 2 von 3 Achsen, keine Zerlegung ist nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register gelesen am 2026-09-25 und vor dem Move am 2026-09-26 erneut auf dem
lokalen Stand (nichts gepusht; das Register ist beim Lesen so alt wie der letzte Merge). Sub-Area
aller Einträge ist `*`. Die Zähler-Stände sind die Zahl der Dateien unter dem `evidence/` des Eintrags
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gemessen 2026-09-26, keine
Erwartungswerte). Gesucht nach Tap, Release, Prozedur, Eigentum, Zusage, Bedingung, Stub, Token. **Treffer:**

- [`BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md)
  — **3×**, `offen`, über der Schwelle. Der Umbau von Schritt 7 (die vier alternden Aussagen) ist ihre Instanz;
  dieser Plan trägt ihn als Liefer-Punkt 3 in seinem Eingang. Dass eine Instanz einen Träger hat, ist kein
  Ausgang der Klasse; Stand und Übergabe stehen in `state.md` des Eintrags.
- [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  — **8×**, über der Schwelle, Ausgang *geplant* mit Kennung
  [`ADR-0062`](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)
  (`Proposed`, zurückgestellt). §6 Frage 1 trägt die Adresse; sie bewegt den Ausgang nicht.
- [`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)
  — **2×**, `offen`. Der umgebaute Schritt 7 ist wieder eine Prozedur-Zeile ohne Sensor; ein dritter Beleg
  brächte den Eintrag mit diesem Slice auf **3×** — dann keine Notiz mehr, sondern eine Lücke mit eigenem
  Folge-Slice (Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung).
- [`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
  — **2×**, `offen`. Liefer-Punkt 3 gibt die Klassen von `tap-sync` wieder; ein weiterer Fund brächte den
  Eintrag mit diesem Slice auf **3×**. Der Verifier fährt die Aussagen gegen das Skript.
- [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **32×**, Stand *geplant* (Kennung `slice-153`). Der Umbau der vier Aussagen ist dieselbe Klasse an einer
  neuen Stelle; kein neuer Beleg, solange kein Fix sie hat stehen lassen (§7 entscheidet).
- [`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  — **3×**, verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.6. Der Schreib-Pfad am realen Tap ist ihr Fall
  (§6, Risiko 2).
- [`BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`](../observations/BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall/observation.md)
  — **2×**, `offen`; §6, Risiko 3. Unter der Schwelle.
- [`BEO-ALL/exit-zusage-aus-anderem-aufruf-abgeleitet`](../observations/BEO-ALL/exit-zusage-aus-anderem-aufruf-abgeleitet/observation.md)
  — **2×**, `offen`. Die Exit-Zusagen von `sync` stehen für den Direktaufruf und für `make` verschieden
  (Prozess-Exit 2 über `make`); Liefer-Punkt 3 nennt die Ebene, wo er einen Exit nennt.
- [`BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md)
  — **2×**, `offen`. Nachbar: der Slice liefert den Träger, den die Handarbeit heute nachbaut; ein Beleg entsteht
  hier nicht.
- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md)
  — **0×** Belege, `offen`; sein Zustandsfeld nennt `releasing.md` Schritt 6. Der Slice berührt die Nummer
  nicht (§3, Nummern).
- Gesichtet, kein Treffer für diesen Gegenstand: `negation-mitten-im-bats-fall-ohne-wirkung` (**1×**; die Regel
  gilt für die neuen Fälle: keine Negation mitten im Fall), `doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`
  (**2×**, gemessen 2026-09-26 nach dem Abschluss des Nachbar-Slice `slice-tap-check-liest-keine-version-ist-gebunden`, der den zweiten Beleg trug).

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF (`*` und `harness/tools/` stehen in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) als Greenfield) — kein BF/Hybrid-Block.


