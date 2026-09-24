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

**Bezug:**
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die Plattform-Matrix — das Tap verteilt dieselben Assets),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Reproduzierbarkeit — die Kontrolle hält das Tap gegen das veröffentlichte
Asset, nicht gegen eine lokal erzeugte Kopie),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
(der Schnitt zieht den Pin im selben Vorgang — der Nachzug ist der nächste
Schritt desselben Vorgangs),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
(die Formel reist als Release-Asset; ihre Digests stammen aus der
`SHA256SUMS` desselben Schnitts).
Anlass: Beobachtung am Schnitt `v0.2.3` — das Tap stand nach der Publikation
noch auf `0.2.2`; der Auftraggeber hat den Nachzug von Hand gepusht.

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-24.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der Nachzug der Homebrew-Formel ins Tap ist ein benannter Schritt
der Release-Prozedur — die Meldung des vollzogenen Schnitts geht erst nach ihm —,
eine Kontrolle hält die Tap-Formel gegen das veröffentlichte Formel-Asset des
Tags, und ob der Nachzug Handarbeit bleibt oder ein Werkzeug wird, ist
entschieden, bevor die Prozedur ihn festschreibt.

**Befund, an dem der Schnitt hängt** (gemessen am 2026-09-24): Release `v0.2.3`
ist veröffentlicht, acht Assets, darunter die Formel `ai-harness-init.rb`
(gefüllt von `harness/tools/homebrew-formula-fill.sh`, aufgerufen in
`.github/workflows/release.yml`). Das Tap-Repo `pt9912/homebrew-ai-harness-init`
stand danach auf `0.2.2`; `brew` fand `0.2.3` nicht. Die Prozedur in
[`docs/user/releasing.md`](../../../user/releasing.md) hat für den Nachzug
keinen Schritt (Schritt 5 publiziert, Schritt 6 wartet auf die CI, Schritt 7
meldet — keiner nennt das Tap), das
[Handbuch](../../../user/benutzerhandbuch.md#weg-c--über-ein-homebrew-tap-macos-linux)
sagt dagegen, die Formel werde je Release-Schnitt nachgezogen.
[`slice-tap-verteilt-die-release-assets`](../done/slice-tap-verteilt-die-release-assets.md)
führt den Formel-Nachzug je Release als Liefer-Punkt 2; geliefert wurde die Formel
als Asset, für den Nachzug gibt es weder einen Schritt noch ein `make`-Ziel
(`grep -nE '^[a-z-]*tap[a-z-]*:' Makefile` → leer).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Das Tap-Repo und sein Bestand** (Datei `Formula/ai-harness-init.rb`, der
  Nachzug-Commit des Auftraggebers auf `0.2.3`) — **anderer Vorgang:** das Tap ist
  ein Repo des Auftraggebers mit Push von außen
  ([`slice-tap-verteilt-die-release-assets`](../done/slice-tap-verteilt-die-release-assets.md)
  §1); dieser Slice liest es zur Kontrolle und pusht nichts hinein.
- **Formel-Skeleton, Füll-Skript und Upload-Schritt im Release-Workflow** —
  **Bestand bleibt bewusst stehen:** die Formel im Asset ist korrekt gefüllt (der
  Auftraggeber hat sie byte-gleich zum Tap-Stand gefunden, die Digests gegen die
  `SHA256SUMS` gehalten), und die Füllung deckt `test/release-matrix.bats`. Der
  Befund liegt an der Prozedur, nicht am Asset.
- **Ein Nachzug aus dem Release-Lauf heraus** (Push ins Tap aus der CI) — **anderer
  Vorgang, und nicht ohne Verdikt:** der Release-Workflow trägt heute nur den
  Zugriff auf das eigene Repo (`permissions: contents: read`, im publish-Job
  `contents: write` mit `github.token`; `grep -nE 'secrets\.|token|permissions'
  .github/workflows/release.yml`); ein Push in ein zweites Repo braucht ein
  Zugangsgeheimnis, das der Workflow nicht kennt. Wählt der Architect diesen Weg
  (§6 Frage 1), entsteht dafür ein eigener Slice mit eigener Kennung — sie wird
  dann vergeben, vorher gibt es keine Adresse.
- **Nachzug für die Releases vor `v0.2.3`** — **Bestand bleibt bewusst stehen:** das
  Tap führt eine Formel, die auf den jüngsten Schnitt zeigt; ein älterer Stand
  wird von keinem Weg mehr ausgeliefert, den die Prozedur zusagt.
- **`slice-tap-verteilt-die-release-assets` in `done/`** — **Bestand bleibt bewusst
  stehen:** ein Zeitdokument wird nicht umgeschrieben; die Lücke ist Gegenstand
  dieses Slice und steht in dessen §7.
- **Die Versions-Zeile des Handbuchs und der Release-Text** — **anderer Vorgang:** sie
  gehören zum Release-Schnitt und nicht zur Prozedur-Doku; dieser Slice fasst das
  Handbuch nur an, wenn das Ergebnis von Liefer-Punkt 3 den Wortlaut von Weg C
  („je Release-Schnitt … nachgezogen") ändert.

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — der Nachzug ist ein Schritt der Prozedur:**
      [`docs/user/releasing.md`](../../../user/releasing.md) führt den Nachzug der
      Formel als eigenen Schritt nach der Publikation (Schritt 5), nennt Quelle
      (das veröffentlichte Formel-Asset desselben Tags, keine lokal gefüllte
      Kopie) und Voraussetzung (Push-Recht auf das Tap, Netz), und macht die
      Meldung des vollzogenen Schnitts (Schritt 7) von ihm abhängig. Jede
      Schritt-Nummer, die ein lebendes Artefakt nennt, stimmt nach dem Einfügen
      (§6 Frage 3). **Deckung, benannt:** kein Sensor hält die Schritt-Folge einer
      Prozedur — die Klasse trägt
      [`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md);
      die Zusage ist damit auf *die Prozedur nennt den Schritt und macht die
      Meldung von ihm abhängig* eingeschränkt, nicht auf *der Nachzug geschieht*.
- [ ] **Liefer-Punkt 2 — die Kontrolle „Tap-Formel == Release-Asset":** ein
      Vergleich, der die Formel am Default-Branch des Tap (über die
      GitHub-Schnittstelle gelesen, nicht aus einem lokalen Klon) byte-genau gegen
      das veröffentlichte Asset `ai-harness-init.rb` des Tags hält und bei
      Abweichung mit Exit ≠ 0 endet. Die Zusage ist *Byte-Gleichheit*, keine
      Aussage über Installierbarkeit (`brew install`); die Grenze steht im Text
      der Kontrolle. **Rot-Beleg vor Übernahme:** die Kontrolle gegen das Asset
      von `v0.2.2` und den heutigen Tap-Stand endet rot — der Vorfall-Zustand,
      ohne Push herstellbar —, gegen `v0.2.3` grün; der Lauf zeigt, dass die
      Abweichung als Formel-Unterschied gemeldet wird und nicht als Lesefehler
      (§3.6, Meldung lesen).
- [ ] **Liefer-Punkt 3 — die Entscheidung Handarbeit-mit-Kontrolle gegen Werkzeug
      ist gefallen und steht an einer Adresse:** als ADR (`Accepted`), oder — hält
      der Architect keine ADR für nötig — als benannte Setzung in `releasing.md`
      samt Grund. Die Entscheidung liegt **vor** dem Schreiben von Liefer-Punkt 1
      und 2 (§4 Start): sie bestimmt, ob der Schritt Handarbeit beschreibt oder ein
      Ziel aufruft und wo die Kontrolle lebt.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: der Wortlaut von Weg C im Handbuch ist gegen das Ergebnis geprüft
      und nur bei Abweichung nachgezogen (§1); ein `harness/README.md`-Eintrag
      entsteht nur, falls die Entscheidung ein `make`-Ziel einführt (§6 Frage 2).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. Erwartet sind Belege für die zwei in §8 benannten Einträge — ob sie zählen, urteilt die Closure.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `docs/user/releasing.md` | update | Liefer-Punkt 1: der Schritt, die Abhängigkeit der Meldung, die Kontrolle (Liefer-Punkt 2) im Text oder als Verweis auf ihr Ziel |
| ADR im Architect-Lauf (oder Setzung in `releasing.md`) | neu | Liefer-Punkt 3: die Entscheidung; Übergabe Planner → Architect, nicht Arbeit dieses Slice-Kontexts |
| `Makefile`, `harness/README.md`, ggf. ein Skript unter `harness/tools/` | nur bei Verdikt B oder C | nur falls die Kontrolle oder der Nachzug ein `make`-Ziel wird; dann Tabellenzeile in §Werkzeuge (`targets`-Modul, beide Richtungen) und ein `bats`-Fall mit rotem Gegenbeispiel |
| `docs/user/benutzerhandbuch.md` | nur bei Abweichung | Weg C nennt den Nachzug „je Release-Schnitt"; nachgezogen nur, wenn das Verdikt den Wortlaut ändert |

- **Reihenfolge:** Verdikt (Liefer-Punkt 3) → Kontrolle mit Rot-Beleg (Liefer-Punkt 2)
  → Prozedur-Schritt (Liefer-Punkt 1). Der Schritt nennt die Kontrolle als seinen
  Beleg, deshalb steht sie davor.
- **Kein Produktionscode** in der Variante A (Handarbeit-mit-Kontrolle als
  Kommando in der Prozedur); Code entsteht nur, wenn das Verdikt ein Ziel verlangt.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): das Verdikt des Architect zu §6 Frage 1 liegt
vor (Übergabe Planner → Architect → Planner, Baseline-Regelwerk
`modul-08-agentenrollen.md`), Implementer übernimmt, WIP-Limit frei. Ohne Verdikt
beschriebe Liefer-Punkt 1 einen Schritt, dessen Form (Handarbeit oder Aufruf)
noch nicht entschieden ist.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): das Verdikt wählt ein
  Werkzeug, das den Push ins Tap selbst fährt — Credential-Frage, Ziel, Test und
  Workflow-Änderung wachsen über drei Liefer-Punkte und zwei Schichten hinaus; dann
  bleibt in diesem Slice die Prozedur-Hälfte, das Werkzeug wird ein eigener Slice.
- `in-progress` → `open` (blockiert): das Verdikt steht aus, oder die Kontrolle
  findet den Tap-Stand nicht lesbar (Zugriff auf das Tap ohne Anmeldung nicht
  möglich) und die Lesbarkeit braucht eine Entscheidung des Auftraggebers.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) das Verdikt liegt an seiner Adresse, und die
Kontrolle endet gegen das `v0.2.2`-Asset rot und gegen das `v0.2.3`-Asset grün —
beide Läufe im Review-Report belegt; (2) `docs/user/releasing.md` nennt den Schritt,
und die Meldung des vollzogenen Schnitts hängt in seinem Text an ihm. Dazu der
Lerneintrag in §7 in einer der drei Formen. Kein DoD-Punkt sagt zu, dass der
Nachzug beim nächsten Schnitt geschieht — das trägt kein Sensor (Liefer-Punkt 1).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

**Offene Fragen — Übergabepunkt an den Architect (Liefer-Punkt 3).** Drei
Fragen sind zu beantworten, bevor der Slice startet oder beim Schreiben von
Liefer-Punkt 1 anfällt:

1. **Handarbeit-mit-Kontrolle oder Werkzeug? Braucht die Wahl eine ADR?** Drei
   Varianten liegen auf dem Tisch:
   - **A** — der Nachzug bleibt Handarbeit des Auftraggebers, die Kontrolle steht
     als Kommando in der Prozedur (kein `make`-Ziel, kein Code).
   - **B** — der Nachzug bleibt Handarbeit, die Kontrolle wird ein lesendes
     `make`-Ziel im gepinnten Bild (Netz, kein Push, kein Gate).
   - **C** — ein Werkzeug fährt den Nachzug selbst, als `make`-Ziel oder als Job im
     Release-Lauf.

   Für die Abwägung, gemessen und nicht vermutet: Handarbeit hat am Schnitt
   `v0.2.3` versagt, weil kein Schritt sie trug — das spricht für B oder C, wobei
   auch A den Schritt liefert, der fehlte. Der Tap ist ein fremdes Repo mit Push
   von außen: der Release-Workflow trägt heute nur `github.token` (nur das eigene
   Repo, `.github/workflows/release.yml` publish-Job), Variante C braucht ein
   Zugangsgeheimnis für ein zweites Repo — eine Vertrauensgrenze, die der Workflow
   heute nicht überschreitet. Docker-only
   ([`AGENTS.md`](../../../../AGENTS.md) §3.9): ein `make`-Ziel, das pusht, braucht
   Netz und Anmeldung im gepinnten Bild — die Host-Toolchain-Regel schließt den
   Host-`git push` nicht aus, sie verlangt nur, dass Checks und Builds über `make`
   laufen. **Die Frage, ob C eine ADR braucht, ist die erste Frage des Architect**
   (Zugangsgeheimnis im Release-Workflow und Schritt ins fremde Repo sind
   Entscheidungen, keine Planung).
2. **Falls B oder C:** die Zeile in
   [`harness/README.md`](../../../../harness/README.md) §Werkzeuge — das Modul
   `targets` hält beide Richtungen —, und der Schnitt, ob die Kontrolle Teil von
   `make gates` bleibt (nein — sie braucht Netz; `gates` läuft netzlos) oder
   getrennt steht.
3. **Nummerierung.** Ein Schritt nach Schritt 5 verschiebt die Nummern 6 und 7.
   `releasing.md` nennt seine Schritt-Nummern selbst (Schritt 1, 3, 5, 7 und
   „Schritte 4 und 6"), und die unveränderliche `observation.md` des Eintrags
   `prozedur-zeile-traegt-disziplin-ohne-sensor` nennt „Schritte 4 und 6". Vor dem
   Einfügen misst der Implementer über **beide** Adress-Formen
   (`grep -rnE 'Schritte? [0-9]' docs/ harness/ AGENTS.md`), welche Nennungen leben
   und welche eingefroren sind ([`AGENTS.md`](../../../../AGENTS.md) §3.11: die
   Entscheidung fällt vor dem Einfügen); ob der neue Schritt `5a` heißt oder die
   Folge umnummeriert wird, entscheidet dieses Ergebnis.

**Risiken:**

- **Der Nachzug wird trotz Schritt übersprungen** — die Prozedur nennt den Schritt,
  aber kein Gate hält die Folge; der Schnitt `v0.2.3` zeigt die Klasse (Schritt
  fehlt → Nachzug fehlt), der Ausgang mit Schritt zeigt sie noch nicht.
  **Ausgang:** weiter offen → `BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`
  (Zähler 1×, mit diesem Slice ein zweiter Beleg).
- **Die Kontrolle prüft weniger, als ihr Name sagt** — Gleichheit mit dem Asset
  sagt nichts über Installierbarkeit und nichts darüber, dass das Asset selbst
  richtig gefüllt ist. **Ausgang:** entfallen — die Zusage ist auf Byte-Gleichheit
  eingeschränkt und die Grenze steht im Text der Kontrolle (Liefer-Punkt 2); die
  Füllung des Assets deckt `test/release-matrix.bats`.
- **Handarbeit gegen vorhandene Fähigkeit** — die Füllung der Formel besteht als
  Code (`homebrew-formula-fill.sh`), ihr Einstieg ins Tap besteht nicht; ein Lauf
  baut den Nachzug von Hand nach, und niemand vergleicht ihn mit dem, was ein
  Träger erzeugt hätte. **Ausgang:** weiter offen →
  `BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut` (Zähler 2×;
  siehe §8, ob dieser Slice ihn auf 3× hebt).
- **Die Kontrolle liest einen veralteten Stand** — ein Cache zwischen Tap-Push und
  Lesen zeigt den alten Formel-Stand. **Ausgang:** entfallen — gelesen wird über
  die GitHub-Schnittstelle am Branch-Kopf und nicht über einen zwischengespeicherten
  Roh-Pfad (Liefer-Punkt 2); ein Fehlgriff zeigt sich als Rot der Kontrolle, nicht
  als stilles Grün.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) — die
Nutzer-Doku zum Release-Vorgang, im Fall eines Werkzeugs auch `Makefile` und
`harness/tools/`. Die Modus-Deklaration führt `*` und `harness/tools/` als eigene
Zeilen; beide erfüllen die Schwelle ≥ 2 von 3 Achsen, keine ist zu grob.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-24 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` zählt die
Verzeichnisse; Sub-Area aller Einträge ist `*`). Gesucht nach Release, Tap,
Homebrew, Formel und Publikation. **Treffer:**

- [`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)
  — Zähler **1×** (`ls docs/plan/planning/observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/evidence | wc -l`);
  der Nachzug-Schritt ist eine weitere Prozedur-Zeile ohne Sensor, ein zweiter Beleg
  bei der Closure. Unter der Schwelle.
- [`BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut`](../observations/BEO-ALL/vorhandene-faehigkeit-ohne-traeger-wird-von-hand-nachgebaut/observation.md)
  — Zähler **2×** (dieselbe Zählung). Der Fall ist nahe, aber nicht deckungsgleich:
  hier besteht die Füllung als Code, der Einstieg ins fremde Repo besteht nicht.
  Zählt die Closure ihn als dritten Beleg, erreicht der Eintrag mit diesem Slice
  **3×** und ist keine Notiz mehr, sondern eine Lücke mit eigenem Folge-Slice
  (Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der
  Modus-Begründung) — das Urteil *dieselbe Beobachtung?* fällt beim Schreiben des
  Belegs, nicht hier.
- Gesichtet, kein Treffer für diesen Gegenstand:
  `ci-rennt-gegen-die-publikation-des-gepinnten-releases` (Fetch gegen die
  Publikation, nicht Verteilung) und
  `kennung-traegt-den-stand-den-ein-release-ueberholt` (Kennungen, nicht
  Verteil-Wege). Ein Eintrag zur Tap-Verteilung selbst besteht nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF (`*` und `harness/tools/` stehen in der
Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md)
als Greenfield) — kein BF/Hybrid-Block.
