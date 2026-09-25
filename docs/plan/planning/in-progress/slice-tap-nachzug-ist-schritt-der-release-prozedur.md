# Slice slice-tap-nachzug-ist-schritt-der-release-prozedur: Der Tap-Nachzug ist ein Schritt der Release-Prozedur

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

**Ebene: Dogfood, Doku-Slice.** Gegenstand ist die Nutzer-Doku
`docs/user/releasing.md` dieses Repos; kein Produkt-Code, kein Skript, kein
`make`-Ziel, kein Workflow.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Reproduzierbarkeit — die Kontrolle hält das Tap gegen das veröffentlichte
Asset, nicht gegen eine lokal erzeugte Kopie),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — Festlegung 6 und Folgepflicht 3 tragen den Schritt; Festlegung 3 Schritt d den
Vorwärts-Schutz, den die Prozedur als Bedingung nennt),
[`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
(**Accepted** — die Ebene der Exit-Klassen und die Zeile `tap-check: Exit <N>`, deren Wortlaut die
Prozedur zitiert),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
(der Schnitt zieht den Pin im selben Vorgang; der Transport der Kontrolle ist sein Muster),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(die Formel reist als Release-Asset; ihre Digests stammen aus der `SHA256SUMS` desselben Schnitts).
**Kein Bezug:** [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) — der
Vertragstext führt kein Tap (`grep -ciwE 'tap|homebrew' spec/lastenheft.md` → **0**, gemessen
2026-09-25), und [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
übernimmt den Bezug nicht (§Bezug, Folgepflicht 6); der Bestand in `releasing.md` Schritt 5 nennt ihn
weiter, und dieser Slice trägt ihn nicht fort (§1).

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

**Ziel:** [`docs/user/releasing.md`](../../../user/releasing.md) führt den Nachzug der
Homebrew-Formel ins Tap als benannten Schritt der Prozedur, und die Meldung des vollzogenen Schnitts
hängt an seinem Beleg — `make tap-check TAG=<tag>` mit Exit 0. Der Schritt beschreibt den Zustand, der
besteht: der Nachzug ist Handarbeit (das Skript führt nur den Modus `check`; `sync` endet mit
Exit 2 *„nicht implementiert"*), die Kontrolle ist ein Werkzeug.

**Der Zustand, an dem der Schnitt hängt** (gemessen am 2026-09-25):

- **Die Formel reist als achtes Asset**, und in das Tap gelangt sie nicht von selbst: der Workflow
  trägt keinen Job dafür (`grep -nE '^  [a-z0-9-]+:$' .github/workflows/release.yml` nennt
  `artifacts`, `start-smoke`, `publish`), und es gibt kein Ziel für den Nachzug
  (`grep -nE '^[a-z-]*tap[a-z-]*:' Makefile` → allein `tap-check`).
- **Der Nachzug geschieht von Hand.** Die drei jüngsten Commits des Tap tragen die Form
  `Formula/ai-harness-init.rb <version> -- Formel-Nachzug aus dem Release-Asset (v<version>, vier
  Plattform-Digests gegen die SHA256SUMS desselben Releases)`
  (`git -C <Klon des Tap> log --format=%s -3`). [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 3 f verlangt von einem Nachzug allein, dass die Message den Tag nennt.
- **Die Prozedur nennt den Nachzug nicht.** Schritt 5 publiziert, Schritt 6 wartet auf die CI, Schritt 7
  meldet; keiner nennt das Tap (`grep -niE 'tap' docs/user/releasing.md` nennt nur die Zeilen zu
  Formel-Asset und Tap-Verteilung in Schritt 5). Das
  [Handbuch](../../../user/benutzerhandbuch.md#weg-c--über-ein-homebrew-tap-macos-linux) sagt dagegen,
  die Formel werde je Release-Schnitt nachgezogen.
- **Die Kontrolle besteht.** `make tap-check TAG=<tag>` hält die Formel am Kopf des Default-Branch
  des Tap byte-genau gegen das Asset des Tags
  ([`slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset`](../done/slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md)).
  Gemessen 2026-09-25 gegen den Tap-Stand `0.2.4`: `make tap-check TAG=v0.2.4` → Exit 0, Zeile
  `tap-check: gleich — Tag v0.2.4, Tap-Kopf Formula/ai-harness-init.rb, sha256 …`; `make tap-check
  TAG=v0.2.3` → nach der Wiederholung des Lesens (66 s) `tap-check: Formel-Unterschied — …` mit der
  ersten abweichenden Zeile 11 (`version "0.2.3"` gegen `version "0.2.4"`), letzte Zeile des Skripts
  `tap-check: Exit 1`, dahinter die Meldung von `make` (`make: *** [Makefile:493: tap-check]
  Fehler 1`). Der Beleg gilt für den Tap-Stand am Tag der Messung und wandert mit jedem Schnitt.
- **Die Richtung ist entschieden.** [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  (`Accepted`) wählt ein Werkzeug (Modus `sync`, Release-Job `tap`); bis es besteht, trägt die
  Prozedur die Handarbeit samt Kontrolle. Die Frage *Handarbeit oder Werkzeug* ist damit nicht mehr
  Gegenstand dieses Slice.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Modus `sync` und das Ziel für den Nachzug** — **Folge-Schnitt, noch ohne Kennung:** die
  Adresse ist die Zeile *Folge-Slices* (2) im §7 von
  [`slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset`](../done/slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset.md);
  er zieht drei Zusagen aus `check` mit (Status-10-Kanal, Exit-Zeile `tap-sync:`, ein Vergleich im
  Code). Die Kennung wird beim Schnitt vergeben — ein Schnitt vor dem Bedarf plante einen toten Slice, und
  seine Größe ist ungemessen (der Slice für `check` trug bei drei Liefer-Punkten vier
  Review-Runden).
- **Der Release-Job `tap`, die Umgebung samt Tag-Regel und das Secret `TAP_TOKEN`** —
  **Folge-Schnitt nach `sync`, nicht anlegbar:** der Job ruft das Ziel für `sync`
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Folgepflicht 2), das nicht besteht; ein Slice vor ihm wäre nicht einzeln lieferbar. Anlage von Umgebung
  und Secret ist Handlung des Auftraggebers außerhalb des Repos
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 4); kein Token und kein Secret steht in einem Artefakt dieses Repos.
- **Ein Nachzug ins Tap und jeder Schreibzugriff darauf** — **anderer Vorgang:** dieser Slice
  liefert Doku; der Rot-Beleg des Wortlauts ist lesend (`make tap-check`, kein Push). Das Tap ist ein
  Repo des Auftraggebers mit Push von außen.
- **Die Antwort auf die Frage, welche Rolle den Nachzug fährt** — **keine Quelle benennt sie**
  (§6 Frage 1): der Slice trägt die Frage mit Adresse und beantwortet sie nicht; der Schritt setzt
  ein Push-Recht voraus und nennt keine Rolle.
- **Der Bezug [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) in
  `releasing.md` Schritt 5** — **Bestand bleibt bewusst stehen:** ob das Tap eine Anforderung des
  Lastenhefts wird oder der Bezug entfällt, entscheidet der Auftraggeber
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Folgepflicht 6); der neue Schritt nennt ihn nicht.
- **`make traeger-fetch` als eigener Schritt der Prozedur** — **Bestand bleibt bewusst stehen:** die
  Prozedur nennt das Ziel `make traeger-fetch` allein in Schritt 2 als Beleg nach der Publikation
  (`grep -n 'make traeger-fetch' docs/user/releasing.md`); ihn zu einem Schritt zu machen ist eine andere
  Änderung an der Folge.
- **Formel-Skeleton, Füll-Skript und Upload-Schritt im Release-Workflow** — **Bestand bleibt bewusst
  stehen:** die Füllung deckt `test/release-matrix.bats`, und die Kontrolle hält das Tap gegen das
  Asset, nicht das Asset gegen die Füllung.
- **Das Handbuch** — **anderer Vorgang:** die Nutzer-Doku trägt den Ist-Zustand, ihr Update gehört zum
  Release-Schnitt. Dieser Slice fasst Weg C nur an, wenn die Messung in Liefer-Punkt 2 zeigt, dass
  *„je Release-Schnitt"* die Vorab-Tags falsch beschreibt (§2, Doku-Update).

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — der Nachzug ist ein Schritt der Prozedur, und die Meldung hängt an ihm:**
      [`docs/user/releasing.md`](../../../user/releasing.md) führt den Nachzug als **Schritt 7**, nach
      der Wartestelle für die CI (Schritt 6); die Meldung des vollzogenen Schnitts wird **Schritt 8**.
      Der Schritt nennt:
      - die **Quelle** — das veröffentlichte Formel-Asset desselben Tags, keine lokal gefüllte
        Kopie —, die **Handlung** (Asset holen, als `Formula/ai-harness-init.rb` ins Tap, ein Commit,
        dessen Message den Tag nennt, Push auf den Default-Branch) und die **Voraussetzung**
        (Push-Recht auf das Tap, Netz);
      - die **Vorbedingung des Vorwärts-Schutzes** — der Tag ist nicht älter als die
        `version`-Zeile der Formel am Tap-Kopf ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
        Festlegung 3 d als Maßstab); die Handarbeit hat diesen Schutz nicht, der Satz trägt ihn;
      - **keine Rolle** als Ausführende und keinen Pfad eines Nachbar-Klons als Voraussetzung (§6
        Frage 1);
      - dass **Schritt 8 an `tap-check` mit Exit 0 hängt** und die Meldung das Ergebnis als Beleg
        trägt (Stand-Form: Tag, Zeile des Skripts — keine Chronik).

      Jede Schritt-Nummer, die ein lebendes Artefakt nennt, stimmt nach dem Einfügen: die Setzung
      *nach Schritt 6* hält 1 bis 6 stabil und verschiebt nur die Nennung `(Schritt 7)` in Schritt 5
      (§3, Messung). **Rot, wenn:** eine Nennung auf den falschen Schritt zeigt oder Schritt 8 den
      Beleg nicht nennt; die Gegenprobe ist, die Nennung in Schritt 5 unverändert zu lassen — sie zeigt
      dann auf den Nachzug statt auf die Meldung, und der Review liest sie. **Deckung, benannt:** kein
      Sensor hält die Schritt-Folge einer Prozedur — die Klasse trägt
      [`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md);
      die Zusage ist auf *die Prozedur nennt den Schritt und macht die Meldung von ihm abhängig*
      eingeschränkt, nicht auf *der Nachzug geschieht*.
- [ ] **Liefer-Punkt 2 — der Beleg trägt Wortlaut und Grenze der Kontrolle:** der Schritt nennt
      `make tap-check TAG=<tag>` als Beleg und gibt die Klassen so wieder, wie das Skript sie
      liefert ([`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)):
      Exit des **Skripts** 0 gleich (oder Vorab-Tag: *„Vorab-Tag, Tap bleibt"* — für ihn entfällt der
      Nachzug), 1 Formel-Unterschied auch nach dem zweiten Lesen, 2 nicht ausführbar; über `make`
      endet jeder Fehlschlag mit Prozess-Exit 2, und die Klasse trägt die Zeile des Skripts
      `tap-check: Exit <N>` (bei Exit 1 und 2, genau einmal; gelesen wird die Zeile, nicht ihre
      Position). **Bei Ungleichheit wartet der Aufruf einmal 65 s** ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
      Festlegung 2): ein Exit 1 direkt nach dem Push ist erst nach dieser Wiederholung ein Befund.
      **Die Grenze steht im Text:** die Kontrolle sagt Byte-Gleichheit zum Zeitpunkt des Lesens zu, nicht
      dass `brew install` läuft (das Vertrauen des Fremd-Taps ist eine eigene Bedingung des Nutzers,
      das Handbuch nennt sie), nicht dass das Asset richtig gefüllt ist, keinen Zustand nach dem Aufruf,
      und sie hält den Vorwärts-Schutz nicht (gleich gegen einen älteren Tag ist ebenso Exit 0).
      **Rot, wenn:** ein zitierter Wortlaut nicht der Ausgabe des Skripts entspricht. **Rot-Beleg vor
      Übernahme:** der Lauf gegen einen Tag, dessen Formel nicht die des Tap ist, endet mit Exit 1, der
      Meldung des Unterschieds und der Zeile `tap-check: Exit 1` — gelesen wird die Ausgabe, nicht der
      Exit-Code; der Lauf gegen den Tag des Tap-Standes endet mit Exit 0. Was ein Fall
      am Wortlaut bindet, ist gemessen (`grep -n 'gleich' test/tap-nachzug.bats`): der Fall
      *„vergleich gleich"* prüft das Wort `gleich` in der Ausgabe (`*"gleich"*`), nicht die übrige Zeile.
      Die Prozedur zitiert darum die Klasse und das Wort, nicht die Digest-Zeile als Vertrag.
      **Deckung, benannt:** kein Test und kein Gate hält `releasing.md` gegen die Ausgabe des Skripts; ändert sich
      der Wortlaut, bleibt die Prozedur grün und falsch — Träger ist der Review dieses Slice.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: der Wortlaut von Weg C im Handbuch ist gegen den Schritt geprüft und nur bei
      Abweichung nachgezogen. Die Messung: der Satz sagt *„je Release-Schnitt … nachgezogen"*, der
      Schritt nimmt Vorab-Tags aus (*„Tap bleibt"*). Ob der Satz dadurch für Vorab-Tags falsch
      ist, urteilt der Implementer am veröffentlichten Bestand
      (`gh release list --json tagName,isPrerelease`); ein `harness/README.md`-Eintrag entsteht nicht — die
      Zeile für `make tap-check` besteht (`grep -n 'make tap-check' harness/README.md`).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. Erwartet sind Belege für die vier in §8 benannten Einträge — ob sie zählen, urteilt die Closure.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/user/releasing.md` | update | Liefer-Punkt 1 und 2: der Schritt 7, Schritt 8 als Meldung mit dem Beleg, die Nennung `(Schritt 7)` in Schritt 5 wird `(Schritt 8)`, Wortlaut und Grenze der Kontrolle |
| `docs/user/benutzerhandbuch.md` | nur bei Abweichung | Weg C nennt den Nachzug *„je Release-Schnitt"*; nachgezogen nur, wenn die Messung (§2, Doku-Update) es verlangt |

- **Die Nummerierung ist gemessen und gesetzt.** Nennungen einer Schritt-Nummer der Prozedur, die leben:
  in `releasing.md` `(Schritt 1)`, `Schritt 3`, `Schritt 5`, `(Schritt 7)` und *„Schritte 4 und 6"*
  (`grep -nE 'Schritte? [0-9]' docs/user/releasing.md`); in einem Zustandsfeld des Registers
  `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md` *„Schritt 6"*
  (`grep -rn 'releasing' docs/plan/planning/observations/BEO-ALL/*/state.md`). Eingefroren, weil
  unveränderlich, ist die `observation.md` von `prozedur-zeile-traegt-disziplin-ohne-sensor`
  (*„Schritte 4 und 6"*). Steht der neue Schritt **nach 6**, bleiben alle diese Nennungen wahr bis auf
  `(Schritt 7)`; ein Schritt **nach 5** verschöbe 6 und 7 und träfe zwei der genannten Stellen, davon
  eine im eingefrorenen Bestand. Beide Adress-Formen sind gemessen: das Wort *„Schritt"* mit Ziffer
  in Fließtext und Zustandsfeld; einen Anker auf die Schritt-Zeile führt kein lebendes Artefakt
  (`grep -rn 'releasing.md#' docs harness README.md | grep -vc 'slice-tap-nachzug-ist-schritt'` → **0**). Nach dem Einfügen misst der Implementer
  dieselben Kommandos erneut.
- **Reihenfolge:** Schritt 7 mit Handlung (Liefer-Punkt 1) → Wortlaut und Grenze aus einem realen
  Lauf (Liefer-Punkt 2, der Rot-Beleg geht der Übernahme des Wortlauts voraus) → Schritt 8 und die
  Nummern-Nachzüge.
- **Kein Produkt-Code, kein `make`-Ziel, kein Skript** in diesem Slice. Eine Zeile über ein Ziel für den
  Nachzug wäre eine Zusage über etwas, das nicht besteht (`AGENTS.md` §3.1).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Vor `open` → `next`** (Priorisierung, Entscheidung des Auftraggebers): der bewegende Lauf misst
nach [`AGENTS.md`](../../../../AGENTS.md) §3.11 und
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4, ob ein
eingefrorenes Artefakt diese Datei als Pfad nennt — über beide Adress-Formen. **Der Befund steht:** kein
Artefakt nennt sie als Pfad. Der Code-Span-Pfad und der Markdown-Link (`open/<Kennung>`,
`<Kennung>.md`, `](<Kennung>`) treffen im Repo außerhalb `.harness/baseline` und außer dieser Datei
nichts (`grep -rnI --exclude-dir=.git --exclude-dir=.harness -E 'slice-tap-nachzug-ist-schritt-der-release-prozedur\.md|open/slice-tap-nachzug-ist-schritt-der-release-prozedur|\]\(slice-tap-nachzug-ist-schritt-der-release-prozedur' . | grep -v 'planning/in-progress/slice-tap-nachzug-ist-schritt-der-release-prozedur.md' | wc -l`
→ **0**); die Kennung steht in zwei eingefrorenen Dateien als Text
(`grep -rlI --exclude-dir=.git --exclude-dir=.harness slice-tap-nachzug-ist-schritt-der-release-prozedur .`).
Der Link in `done/slice-tap-check-…` ist auf die Kennung reduziert; die Entscheidung liegt damit vor dem
Move (§6 Frage 2).

**Start** (`next` → `in-progress`): `Verantwortlich:` gesetzt, WIP-Limit frei, Frage 2 aus §6
entschieden. Der Stand der Entscheidungen, an denen die Arbeit hing, ist gemessen:
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) und
[`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) stehen auf
`Accepted` (`grep -nE '^\| \[ADR-006[46]\]' docs/plan/adr/README.md`); ein Verdikt des Architect ist
nicht mehr Startbedingung. Frage 1 aus §6 braucht **keine Antwort** zum Start — der Schritt nennt
keine Rolle.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Wortlaut der Kontrolle lässt sich nicht
  ohne eine Änderung am Skript oder am Ziel zitieren (etwa weil `make` die Zeile des Skripts nicht
  ausgibt) — die Änderung am Werkzeug ist ein anderer Vorgang und ein eigener Slice; in diesem bleibt die
  Prozedur-Hälfte.
- `in-progress` → `open` (blockiert): der Review verlangt eine Antwort auf Frage 1, bevor der Schritt
  geschrieben werden darf (etwa: eine Prozedur schreibt keine Handarbeit in ein fremdes Repo vor, solange
  die Eigentums-Frage offen ist) — dann geht die Frage an den Architect, nicht in diesen Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `docs/user/releasing.md` nennt den Schritt 7 und Schritt 8 hängt in
seinem Text an `tap-check` mit Exit 0; jede Nennung einer Schritt-Nummer in den unter §3 gemessenen
Artefakten zeigt auf den Schritt, den sie meint (`grep -nE 'Schritte? [0-9]' docs/user/releasing.md`
gegen die Schritt-Überschriften). (2) Die im Text zitierten Ausgaben stimmen mit einem realen Lauf: der
Review-Report belegt `make tap-check` gegen einen Tag, dessen Formel nicht die des Tap ist (Exit 1, die
Zeile `tap-check: Exit 1`), und gegen den Tag des Tap-Standes (Exit 0). Dazu der Lerneintrag in §7 in
einer der drei Formen. Kein DoD-Punkt sagt zu, dass der Nachzug beim nächsten Schnitt geschieht — das
trägt kein Sensor (Liefer-Punkt 1).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

**Offene Fragen — jede mit Adresse, keine im Slice entschieden.**

1. **Welche Rolle fährt den Nachzug?** Keine Quelle benennt es: die Prozedur nennt für ihre Schritte
   keine ausführende Rolle, und [`AGENTS.md`](../../../../AGENTS.md) §3.8 und §3.10 binden nur
   Norm-Artefakte und den Abschluss. Der Nachzug schreibt in ein Repo außerhalb dieses Baums. Eine
   Erlaubnis, die der Auftraggeber im laufenden Auftrag für das Tap ausspricht, ist eine Aussage
   dieses Auftrags und kein Artefakt; der Schritt und jeder DoD-Punkt stützen sich nicht auf sie. Das
   ist die Klasse
   [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
   (Stand dort: geplant — Kennung
   [`ADR-0062`](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md),
   `Proposed`). **Adresse der Frage:** dieser Eintrag und diese ADR; wird sie bei der Arbeit an diesem
   Slice faktisch beantwortet (etwa indem ein Lauf den Nachzug ausführt und die Prozedur seine Rolle
   übernimmt), ist das ein weiterer Beleg der Klasse und keine Entscheidung.
2. **Was geschieht mit dem Link in `done/slice-tap-check-…`, bevor der Slice nach `next/` geht?**
   Kandidaten: `make slice-mv` zieht den Verweis nach (ein Nachzug in ein eingefrorenes Zeitdokument —
   die Klasse
   [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)),
   oder die Adresse wird eine Kennung. Ein Paar in `ignore-refs` der [`.d-check.yml`](../../../../.d-check.yml)
   wäre eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und braucht eine ADR. **Übergabe an
   den Architect, wenn der bewegende Lauf keinen der ersten zwei Wege trägt.** **Entschieden:** der
   zweite Weg — die Adresse in `done/slice-tap-check-…` ist die Kennung, der Move zieht dort nichts nach
   (§4, Messung über beide Adress-Formen).

**Risiken:**

- **Der Nachzug wird trotz Schritt übersprungen** — die Prozedur nennt den Schritt, kein Gate hält die
  Folge. Was der Schritt leistet, ist ein zweiter Halt: die Meldung des Schnitts verlangt einen
  Beleg, der ohne Nachzug nicht entsteht (Exit 1). **Ausgang:** weiter offen →
  `BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor` (mit diesem Slice ein weiterer Beleg).
- **Die Kontrolle prüft weniger, als ihr Name sagt** — Byte-Gleichheit sagt nichts über
  Installierbarkeit, über die Füllung des Assets und über einen älteren Tag. **Ausgang:** entfallen — die
  Zusage ist auf Byte-Gleichheit eingeschränkt, und die Grenze steht im Text des Schritts
  (Liefer-Punkt 2).
- **Die Handarbeit ist ein Übergangszustand ohne Träger** — die Füllung der Formel besteht als
  Code, ihr Einstieg ins Tap besteht nicht, und bis `sync` und der Job stehen fährt ein Lauf den Nachzug
  von Hand nach. **Ausgang:** weiter offen →
  `BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut` (siehe §8, ob dieser Slice
  ihn auf 3× hebt; dann ist der Folge-Slice der `sync`-Schnitt).
- **Die Handarbeit hat keinen Vorwärts-Schutz** — ein Nachzug eines älteren Tags stellte das Tap auf
  eine Formel zurück, die kein zugesagter Weg mehr ausliefert, und `tap-check` gegen genau diesen Tag
  meldet Exit 0. Der Schutz steht im Werkzeug ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 3 d, nur `sync`) und im Schritt als Satz. **Ausgang:** weiter offen →
  `BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet` (siehe §8).
- **Die Kontrolle liest einen veralteten Stand** — die Schnittstelle nennt ein Cache-Fenster von 60 s.
  **Ausgang:** entfallen — das Skript wiederholt das Lesen bei Ungleichheit einmal nach 65 s
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 2), und der Schritt nennt die Wartezeit (Liefer-Punkt 2); ein Fehlgriff zeigt sich als Rot,
  nicht als stilles Grün.

## 7. Closure-Notiz

Wird bei der Closure vom Planner in frischem Kontext geschrieben
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht vom Lauf, der den Slice baut.

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

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** — (eine der drei Formen: geschärfte Regel · neuer
  Sensor · benannte Spec-Lücke; Kandidat: ein Träger für die Schritt-Folge einer
  Prozedur, siehe §6 Risiko 1)
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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo) — die Nutzer-Doku
zum Release-Vorgang. `harness/tools/`, `Makefile` und der Workflow sind nicht berührt. Die
Modus-Deklaration führt `*` als eigene Zeile; sie erfüllt die Schwelle ≥ 2 von 3 Achsen, keine
Zerlegung ist nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register gelesen am 2026-09-25
(`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` zählt die Verzeichnisse; Sub-Area aller
Einträge ist `*`). Gesucht nach Release, Tap, Homebrew, Formel, Prozedur, Publikation und
Eigentum. Die Zähler-Stände unten sind die Zahl der Dateien unter dem `evidence/` des Eintrags
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gemessen 2026-09-25, keine
Erwartungswerte). **Treffer:**

- [`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)
  — **1×**. Der Schritt ist eine weitere Prozedur-Zeile ohne Sensor; ein zweiter Beleg bei der
  Closure. Unter der Schwelle.
- [`BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md)
  — **2×**. Der Fall ist nahe, aber nicht deckungsgleich: die Füllung besteht als Code, der Einstieg
  ins fremde Repo besteht nicht, und die Richtung zu einem Träger ist entschieden
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)).
  Zählt die Closure ihn als dritten Beleg, erreicht der Eintrag mit diesem Slice **3×** und ist keine
  Notiz mehr, sondern eine Lücke mit eigenem Folge-Slice
  (Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung); der
  Folge-Slice ist dann der `sync`-Schnitt (§1). Das Urteil *dieselbe Beobachtung?* fällt beim
  Schreiben des Belegs, nicht hier.
- [`BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md)
  — **2×**, `offen`. Der Vorwärts-Schutz der Handarbeit steht als Bedingung in der ADR und, mit diesem
  Slice, als Satz in der Prozedur, die der Lauf liest; ein Träger im Lauf besteht damit nur als Text.
  Der Prüfpunkt des Umschnitts, den der Slice für `check` benennt — der Stand von
  [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) —, ist gelesen:
  `Accepted` (Kopf der Datei und `grep -n 'Exit-Klassen des Tap-Werkzeugs' docs/plan/adr/README.md`); die Zeile
  `make tap-check` in [`harness/README.md`](../../../../harness/README.md) trägt Ebene und Exit-Zeile
  dieser Fassung. Skript-Kopf und Makefile-Kommentar sind nicht abgeglichen — Urteil des Reviews.
  Ob die Berührung zählt, urteilt die Closure; erreicht der Eintrag 3×, ist der `sync`-Schnitt der
  Folge-Slice.
- [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  — **6×**, über der Schwelle, Ausgang *geplant* mit Kennung
  [`ADR-0062`](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md)
  (`Proposed`, zurückgestellt). Frage 1 in §6 ist ein weiterer möglicher Beleg; er bewegt den Ausgang
  nicht.
- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md)
  — **0×** Belege, `offen`; sein Zustandsfeld nennt `releasing.md` Schritt 6. Der Slice berührt die
  Nummer nicht (§3, Nummerierung); der Treffer ist ein Nachzug-Kandidat, kein Beleg.
- Gesichtet, kein Treffer für diesen Gegenstand:
  `ge-tagter-stand-traegt-keinen-gates-beleg` (Belegbasis-Abschnitt der Prozedur, unberührt) und
  `kennung-traegt-den-stand-den-ein-release-ueberholt` (Kennungen, nicht Verteil-Wege).

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF (`*` steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) als Greenfield) — kein
BF/Hybrid-Block.
