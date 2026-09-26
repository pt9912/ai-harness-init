# Slice slice-release-job-tap-nachzug-und-schritt-7-folgt: Der Release-Job `tap` fährt den Nachzug, und Schritt 7 der Prozedur folgt ihm

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

**Ebene: Dogfood, CI-Workflow mit Doku-Umbau.** Gegenstand sind der Job `tap` in
`.github/workflows/release.yml`, sein `bats`-Fall über die Job-Form und Schritt 7 (und die Meldung in
Schritt 8) der Prozedur [`docs/user/releasing.md`](../../../user/releasing.md); kein Skript, keine Nutzlast,
keine Umgebung, kein Secret.

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(Reproduzierbarkeit — der Job fährt dasselbe Ziel wie der lokale Ausfallweg),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
(**Accepted** — Folgepflicht 2 (der Job), Folgepflicht 3 (die Prozedur), Festlegung 4 (Umgang mit dem Token),
§Fitness Function, Zeile *Job-Form*),
[`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md)
(**Accepted** — Re-Evaluierungs-Trigger 1: ein Aufrufer braucht die Klasse am Prozess-Exit),
[`ADR-0068`](../../adr/0068-der-nachzug-nennt-den-zustand-des-tap-nur-soweit-die-antwort-ihn-traegt.md)
(`Proposed` — der Job zeigt die Meldungen des Skripts; die Ablehnungs-Menge und die Meldung nach vollzogenem
Schreiben sind dort gesetzt),
[`MR-069`](../../../../harness/conventions.md#mr-069--ein-job-der-bewusst-nicht-auscheckt-trägt-seine-prüfung-inline)
und
[`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions)
(Form der Workflow-Jobs).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-26.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein Tag-Push zieht die Formel des Tags ohne Handgriff ins Tap nach — der Job `tap` in `release.yml`
fährt `make tap-nachzug` in der Form von
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
Folgepflicht 2 —, und Schritt 7 der Prozedur nennt den Job als Regelweg und das lokale Ziel als Ausfallweg.

**Bedingungen des Gebers, die dieser Slice trägt** (sie stehen hier, weil der Lauf, der ihn baut, diese Datei
liest und das Geber-Artefakt nach `done/` gewandert ist):

- **Der Umbau von Schritt 7.** Die Handlung des Schritts wird der Job, das Ziel `make tap-nachzug` der lokale
  Ausfallweg; die Meldung des vollzogenen Schnitts (Schritt 8) hängt weiter an `make tap-check TAG=<tag>` als
  unabhängigem Beleg.
- **Die Aussagen, die dabei altern** — der Lauf liest Schritt 7 an seinem Start
  (`grep -nE 'Handlung|Voraussetzung|Rolle|Grenze' docs/user/releasing.md`) und zieht jede, die der Job falsch
  macht: die **Handlung** (*„`make tap-nachzug TAG=<tag>` mit `TAP_TOKEN` in der Umgebung des Aufrufers"*), die
  **Voraussetzung** (*„Token mit Schreibrecht"* — im Job trägt es das Umgebungs-Secret), der **Satz zur Rolle**
  (*„die Prozedur nennt keine ausführende Rolle"*, sobald ein Workflow der Ausführende ist) und im Absatz
  *Grenze* das, was der Job an der Zusage über den Schreib-Pfad ändert. Der Satz dieses Absatzes über die
  Mutations-Fälle von `sync` gehört dem Slice `slice-sync-waechter-tragen-mutations-faelle`.
- **Die Frage von [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Trigger 1:**
  verzweigt der Job-Schritt auf die Klasse? Er soll es nicht — jedes Nicht-Null des Ziels ist ein roter Job —, und
  der `bats`-Fall über die Job-Form hält es (§2, Liefer-Punkt 1). Bleibt es dabei, ist der Trigger nicht
  eingetreten; verzweigt der Schritt, braucht der Aufrufer die Klasse am Prozess-Exit, und die Frage geht an den
  Architect.
- **Zwei kleine Wortlaute der Prozedur**, falls der Umbau die Stellen ohnehin berührt: der Vorab-Satz
  (*„Für einen Vorab-Tag entfällt der Nachzug"* — mit `sync` ohne `TAP_TOKEN` endet auch ein Vorab-Tag mit Exit 2,
  Schritt b geht Schritt c voraus) und die Form der Aussage über die Wächter (*„die `sync`-eigenen"*).

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Anlage der Umgebung samt Tag-Regel und des Secrets `TAP_TOKEN`** — **Handlung des Auftraggebers außerhalb des
  Repos**
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 4); kein Token und kein Secret steht in einem Artefakt dieses Repos. Der Job ist ohne sie lieferbar
  (seine Bindung ist die Job-Form, nicht das Vorhandensein des Secrets); ohne sie endet der erste Tag-Lauf laut
  (Schritt b).
- **Mutations-Fälle für die Wächter von `sync`** — **`slice-sync-waechter-tragen-mutations-faelle`** (`open/`): ein
  anderer Gegenstand (Skript und Nutzlast, nicht der Workflow), und er nimmt den Satz im Absatz *Grenze*, der die
  Fälle nennt.
- **Ein Lauf des Jobs am realen Tap** — **Handlung des Auftraggebers und Beleg des Schreib-Pfads**: dieser Slice
  schreibt nicht ins Tap; kein Lauf des Slice ruft `make tap-nachzug` mit einem Token auf.
- **Die Frage, welche Rolle den lokalen Ausfallweg fährt** — **keine Quelle benennt sie**; sie steht als Klasse im
  Register
  ([`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md),
  Ausgang *geplant*: [`ADR-0062`](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md),
  `Proposed`, zurückgestellt). Der Job nimmt der Prozedur die Handlung ab, nicht die Frage nach dem Ausfallweg.
- **Das Handbuch, Weg C** — **anderer Vorgang:** die Nutzer-Doku trägt den Ist-Zustand, ihr Update gehört zum
  Release-Schnitt; der Satz *„je Release-Schnitt … nachgezogen"* wird mit dem Job wahr und mit dem ersten
  Tag-Lauf belegt.
- **Der Bezug [`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) der Tap-Verteilung** —
  **Bestand bleibt bewusst stehen:** ob das Tap eine Anforderung des Lastenhefts wird, entscheidet der
  Auftraggeber
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Folgepflicht 6).

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [ ] **Liefer-Punkt 1 — der Job `tap` und sein `bats`-Fall:** `.github/workflows/release.yml` trägt einen Job
      `tap` mit `needs: publish`, derselben `if`-Bedingung wie `publish`, `environment:`, Checkout des Tags mit
      `persist-credentials: false`, `permissions: contents: read` und einem Schritt `make tap-nachzug`; Tag und
      Secret stehen nur im Step-`env`, das `run:` enthält kein `${{`, und `TAP_TOKEN` steht in keinem Workflow-
      oder Job-`env` und nicht im `publish`-Job. Die `bats`-Fälle über die Job-Form sind die Zeile *Job-Form* und
      die Zeile *Übergabe ohne Text* (Teil `run:`) der Fitness Function von
      [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) — dort
      stehen die Schwächungen: **je Zeile der Aufzählung einzeln entfernt bzw. das Secret in Job-`env` oder in
      `publish` gesetzt färbt den zugehörigen Fall rot; jeder Fall wird einmal rot gesehen, die Ausgabe gelesen.**
      Ein Fall hält, dass der Schritt nicht auf die Klasse des Ziels verzweigt (kein `case`, kein `$?`-Vergleich,
      kein `|| true`). `make ci-lint` ist grün. **Zusage, auf das Gehaltene eingeschränkt:** ob eine
      GitHub-Umgebung, ihre Tag-Regel und das Secret so wirken, wie der Job es voraussetzt, ist außerhalb des Repos
      und ohne Tag-Lauf nicht herstellbar; die Fälle lesen die Datei, und der erste Tag-Lauf ist der Beleg.
- [ ] **Liefer-Punkt 2 — Schritt 7 folgt dem Job:** Schritt 7 von
      [`docs/user/releasing.md`](../../../user/releasing.md) nennt den Job `tap` als Regelweg und
      `make tap-nachzug TAG=<tag>` mit `TAP_TOKEN` in der Umgebung des Aufrufers als lokalen Ausfallweg; der Beleg
      bleibt `make tap-check TAG=<tag>`, und die Meldung in Schritt 8 hängt an ihm. **Die Aussagen aus §1 sind
      gezogen:** Handlung, Voraussetzung, Satz zur Rolle, der Teil des Absatzes *Grenze*, den der Job berührt, und
      — wo die Stelle berührt wird — die zwei kleinen Wortlaute. Jede Wiedergabe von Klasse, Meldung oder Job-Form
      ist gegen das Skript und gegen `release.yml` gefahren, nicht gegen diesen Plan (die Klasse
      [`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
      steht in §8). Jede Schritt-Nummer, die ein lebendes Artefakt nennt, stimmt nach dem Umbau; die Nummern der
      Prozedur ändern sich nicht. **Rot, wenn:** eine der Aussagen nach dem Slice noch steht, die den Nachzug als
      Handlung des Aufrufers **statt** des Jobs führt, oder wenn eine zitierte Klasse oder Meldung nicht der
      Ausgabe des Skripts entspricht. **Deckung, benannt:** kein Test und kein Gate hält `releasing.md` gegen die
      Ausgabe des Skripts oder gegen `release.yml`; Träger sind der Review und der Verifier, der die Aussagen
      fährt
      ([`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: Schritt 7 und 8 sind Liefer-Punkt 2; das Handbuch (Weg C) bleibt unberührt (§1), sein Wortlaut
      wird gegen den Ist-Zustand gelesen und in §7 vermerkt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag; sie trägt das Ergebnis der Frage von
      [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Trigger 1 (§1) — das
      Verdikt ist Architect-Arbeit, die Frage stellt der Planner.
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
| `.github/workflows/release.yml` | update | Liefer-Punkt 1: der Job `tap` in der Form der Folgepflicht 2; er hält [`MR-014`](../../../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions) Setzung 1 (die Prüfung lebt im Repo, der Job ruft das Ziel) |
| ein `bats`-Fall über die Job-Form | neu | Liefer-Punkt 1: Ort nach dem Bestand (`grep -ln 'publish' test/*.bats`), je Zeile der Aufzählung ein Fall mit seiner Schwächung |
| `docs/user/releasing.md` | update | Liefer-Punkt 2: Schritt 7 (Regelweg und Ausfallweg, die Aussagen aus §1) und die Meldung in Schritt 8 |

- **Schichten: zwei.** CI-Workflow (Job und Fall) und Nutzer-Doku (Prozedur). Kein Skript, keine Umgebung, kein
  Secret.
- **Der Stand von Schritt 7 wird an der Basis gemessen, nicht aus diesem Plan übernommen:** die Wortlaute der
  Aussagen stehen hier als Beschreibung; der Lauf liest `docs/user/releasing.md` an seinem Start.
- **Nummern:** Schritt 7 bleibt Schritt 7; die Messung über beide Adress-Formen (Wort *„Schritt"* mit Ziffer,
  Anker auf die Schritt-Zeile) steht vor und nach dem Umbau
  ([`AGENTS.md`](../../../../AGENTS.md) §3.11).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Vor `open` → `next`** (Priorisierung, Entscheidung des Auftraggebers): der bewegende Lauf misst nach
[`AGENTS.md`](../../../../AGENTS.md) §3.11, ob ein eingefrorenes Artefakt diese Datei als Pfad nennt — über beide
Adress-Formen (Code-Span-Pfad und Markdown-Link). Der Befund am Tag des Schnitts steht im Commit, der die Datei
anlegt; die Kennung nennen die Closure-Notiz des Vorgängers und die Übergaben seiner Reports als Text.

**Start** (`next` → `in-progress`): `Verantwortlich:` gesetzt, WIP-Limit frei, und die Umgebung samt Tag-Regel und
das Secret `TAP_TOKEN` sind vom Auftraggeber angelegt. Die Bestätigung ist eine Aussage des Auftraggebers im
Auftrag und kein Artefakt; **kein Punkt der DoD stützt sich auf sie** — die Bindung des Jobs ist die Job-Form, der
Beleg des Zusammenspiels der erste Tag-Lauf.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Review hält beide Liefer-Punkte in einer Sitzung
  nicht für prüfbar. Eine Naht gibt es nicht — der Job ohne den Umbau der Prozedur lässt Schritt 7 falsch, der
  Umbau ohne den Job beschreibt einen Weg, den es nicht gibt —, darum geht der Slice als Ganzes zurück.
- `in-progress` → `open` (blockiert): die Umgebung oder das Secret fehlt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make test` ist grün mit den Fällen aus Liefer-Punkt 1 und `make ci-lint` grün,
und der Review-Report belegt je Zeile der Job-Form die Schwächung, die ihren Fall rot färbt, mit gelesener
Ausgabe. (2) `make docs-check` und `make gates` sind grün, und jede in Schritt 7 zitierte Klasse, Meldung und
Job-Form stimmt mit dem Skript und `release.yml` überein. Dazu der Lerneintrag in §7 in einer der drei Formen.
**Kein Kriterium sagt zu, dass der Job am realen Tag-Lauf gelingt** — dieser Beleg entsteht mit dem ersten
Tag-Lauf nach Anlage von Umgebung und Secret und steht danach als Beobachtung im Register.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

**Offene Fragen — jede mit Adresse, keine im Slice entschieden.**

1. **Welche Rolle fährt den lokalen Ausfallweg?** Keine Quelle benennt es; die Adresse ist
   [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
   und [`ADR-0062`](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md).
   Der Umbau von Schritt 7 nennt keine Rolle.

**Risiken:**

Kein Risiko trägt hier schon seinen Ausgang; er wird bei der Closure zugewiesen, die Kandidaten stehen dabei.

- **Der Job ist nur als Datei geprüft.** Die Fälle lesen `release.yml`, `make ci-lint` prüft die Syntax; keine
  Umgebung, Tag-Regel und kein Secret wirken in einem Gate. **Ausgang:** Kandidat *weiter offen* →
  [`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  (verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.6: die Zusage auf das einschränken, was der Code hält —
  Liefer-Punkt 1 tut es); der erste Tag-Lauf ist der Beleg.
- **Der Job-Schritt verzweigt auf die Klasse des Ziels.** **Ausgang:** *entfallen*, wenn der Fall es hält;
  *eingetreten* → Architect
  ([`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Trigger 1).
- **Der Slice ist für eine Review-Sitzung zu groß.** **Ausgang:** *eingetreten* → Rückführung nach `next/` (§4);
  *entfallen*, wenn der Review ihn in einer Sitzung trägt.

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

Wird bei der Closure geschrieben — von der Rolle Planner in frischem Kontext (AGENTS.md §3.10), nach Review und Verifikation, in der Form der Regeln oben.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo) für Workflow, Fall und Doku. Die
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) führt `*` als Greenfield; die
Schwelle ≥ 2 von 3 Achsen ist erfüllt, keine Zerlegung ist nötig.

**Vorgelagert — offene Beobachtungen sichten:** Register gelesen am 2026-09-26 auf dem lokalen Stand (nichts
gepusht; das Register ist beim Lesen so alt wie der letzte Merge). Sub-Area aller Einträge ist `*`. Die
Zähler-Stände sind die Zahl der Dateien unter dem `evidence/` des Eintrags, **einschließlich der Belege der
Closure des Vorgängers** (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`, gemessen
2026-09-26, keine Erwartungswerte). **Treffer:**

- [`BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet`](../observations/BEO-ALL/bedingung-ohne-traeger-im-lauf-den-sie-bindet/observation.md)
  — **3×**, verkörpert im Anweisungssatz der Planner-Rolle. Diese Datei ist die Instanz, an der die Zeile greift:
  die Bedingungen des Gebers stehen in §1, nicht in einem Bericht.
- [`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
  — **3×**, über der Schwelle; der Ausgang steht beim Architect. Liefer-Punkt 2 gibt wieder Klassen und Meldungen
  wieder — der Verifier fährt sie gegen Skript und Workflow; ein weiterer Fund wäre ein vierter Beleg.
- [`BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor`](../observations/BEO-ALL/prozedur-zeile-traegt-disziplin-ohne-sensor/observation.md)
  — **2×**, `offen`. Der umgebaute Schritt 7 ist wieder eine Prozedur-Zeile ohne Sensor; ein dritter Beleg
  brächte den Eintrag mit diesem Slice auf **3×** — dann keine Notiz mehr, sondern eine Lücke mit eigenem
  Folge-Slice (Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung).
- [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  — **32×**, Stand *geplant*. Der Umbau der Aussagen in §1 ist dieselbe Klasse an einer neuen Stelle.
- [`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
  — **3×**, verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.6. Der Job am realen Tag ist ihr Fall (§6).
- [`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  — über der Schwelle, Ausgang *geplant*
  ([`ADR-0062`](../../adr/0062-eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-nicht-beantwortet.md),
  `Proposed`); §6 Frage 1 trägt die Adresse, sie bewegt den Ausgang nicht.
- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/state.md)
  — **0×** Belege, `offen`; sein Zustandsfeld nennt `releasing.md` Schritt 6. Der Slice berührt die Nummer nicht.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF (`*` steht in der Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md) als Greenfield) — kein BF/Hybrid-Block.
