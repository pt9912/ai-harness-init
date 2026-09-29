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

**Verantwortlich:** Implementer (pt9912).

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
  **Voraussetzung** (*„Token mit Schreibrecht"* — im Job trägt es das Repo-Secret im Step-`env`), der **Satz zur Rolle**
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

- **Anlage des Repo-Secrets `HOMEBREW_TAP_GITHUB_TOKEN`** — **Handlung des Auftraggebers außerhalb des Repos**
  ([`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
  Festlegung 4), vollzogen am 2026-09-29; auf eine GitHub-Umgebung samt Tag-Regel wird verzichtet — die
  Fadenkreuz-Bindung des Jobs tragen `needs: publish` und der Tag-Trigger des Workflows (Vorbild: die
  Release-Job-Kette des Nachbar-Repos d-migrate, als Quelle gelesen, nicht als Kennung zitiert). Kein Token-Wert
  steht in einem Artefakt dieses Repos; der Secret-Name lebt nur in der Workflow-Datei, als Step-`env`-Mapping auf
  `TAP_TOKEN`. Der Job ist ohne das Secret lieferbar (seine Bindung ist die Job-Form, nicht das Vorhandensein des
  Secrets); fehlt es, endet der erste Tag-Lauf laut (Schritt b).
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

- [x] **Liefer-Punkt 1 — der Job `tap` und sein `bats`-Fall:** *(Beleg: Verifier-Report
      [`../../../reviews/2026-09-29-slice-release-job-tap-nachzug-verify.md`](../../../reviews/2026-09-29-slice-release-job-tap-nachzug-verify.md),
      Punkte 1–2 — je Aufzählungs-Zeile gemessen, zwei Fälle rot gesehen, Ausgabe gelesen)*
      `.github/workflows/release.yml` trägt einen Job
      `tap` mit `needs: publish`, derselben `if`-Bedingung wie `publish` — ohne `environment:`; die
      Fadenkreuz-Bindung tragen `needs: publish` und der Tag-Trigger des Workflows —, Checkout des Tags mit
      `persist-credentials: false`, `permissions: contents: read` und einem Schritt `make tap-nachzug`; Tag und
      Secret-Zuführung stehen nur im Step-`env` des `tap`-Jobs (`TAP_TOKEN: ${{ secrets.HOMEBREW_TAP_GITHUB_TOKEN }}`,
      `TAG: ${{ github.ref_name }}`), das `run:` enthält kein `${{`, und eine Secret-Zuführung gibt es nur in
      diesem Step-`env` — kein `env` auf Workflow- oder Job-Ebene, kein Secret-Zugriff im `publish`-Job oder in
      einem weiteren Schritt. Die `bats`-Fälle über die Job-Form sind die Zeile *Job-Form* und
      die Zeile *Übergabe ohne Text* (Teil `run:`) der Fitness Function von
      [`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) — die
      Aufzählung ist die dieses Punktes, das `environment:` des ADR-Eintrags entfällt (§1); dort
      steht die Schwächung je Zeile: **je Zeile der Aufzählung einzeln entfernt bzw. das Secret in einem Job-`env`
      oder im `publish`-Job gesetzt färbt den zugehörigen Fall rot; jeder Fall wird einmal rot gesehen, die
      Ausgabe gelesen.**
      Ein Fall hält, dass der Schritt nicht auf die Klasse des Ziels verzweigt (kein `case`, kein `$?`-Vergleich,
      kein `|| true`). `make ci-lint` ist grün. **Zusage, auf das Gehaltene eingeschränkt:** ob das Repo-Secret
      so wirkt, wie der Job es voraussetzt, ist außerhalb des Repos
      und ohne Tag-Lauf nicht herstellbar; die Fälle lesen die Datei, und der erste Tag-Lauf ist der Beleg.
- [x] **Liefer-Punkt 2 — Schritt 7 folgt dem Job:** *(Beleg: Verifier-Report, Punkt 3 — jede Aussage gegen Skript
      und Workflow gefahren, Meldungstexte verbatim)* Schritt 7 von
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
- [x] `make gates` grün — Beleg: der Closure-Lauf nach dem `git mv` (gezeichneter Stempel in
      `.harness/state/gates-passed.diffsha`).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      ([`../../../reviews/2026-09-29-slice-release-job-tap-nachzug.md`](../../../reviews/2026-09-29-slice-release-job-tap-nachzug.md):
      F-1 MEDIUM, F-2 LOW, Verdikt nicht merge-blockierend; Auflösung bestätigt im Verifier-Report, Punkt 6)
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: Schritt 7 und 8 sind Liefer-Punkt 2; das Handbuch (Weg C) bleibt unberührt (§1), sein Wortlaut
      wird gegen den Ist-Zustand gelesen und in §7 vermerkt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag; sie trägt das Ergebnis der Frage von
      [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Trigger 1 (§1) — das
      Verdikt ist Architect-Arbeit, die Frage stellt der Planner.
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

**Start** (`next` → `in-progress`): `Verantwortlich:` gesetzt, WIP-Limit frei, und das Repo-Secret
`HOMEBREW_TAP_GITHUB_TOKEN` ist vom Auftraggeber angelegt (2026-09-29); auf eine Umgebung ist verzichtet. Die
Bestätigung ist eine Aussage des Auftraggebers im Auftrag und kein Artefakt; **kein Punkt der DoD stützt sich auf
sie** — die Bindung des Jobs ist die Job-Form, der Beleg des Zusammenspiels der erste Tag-Lauf.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Review hält beide Liefer-Punkte in einer Sitzung
  nicht für prüfbar. Eine Naht gibt es nicht — der Job ohne den Umbau der Prozedur lässt Schritt 7 falsch, der
  Umbau ohne den Job beschreibt einen Weg, den es nicht gibt —, darum geht der Slice als Ganzes zurück.
- `in-progress` → `open` (blockiert): das Secret fehlt.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

Zwei beobachtbare Kriterien: (1) `make test` ist grün mit den Fällen aus Liefer-Punkt 1 und `make ci-lint` grün,
und der Review-Report belegt je Zeile der Job-Form die Schwächung, die ihren Fall rot färbt, mit gelesener
Ausgabe. (2) `make docs-check` und `make gates` sind grün, und jede in Schritt 7 zitierte Klasse, Meldung und
Job-Form stimmt mit dem Skript und `release.yml` überein. Dazu der Lerneintrag in §7 in einer der drei Formen.
**Kein Kriterium sagt zu, dass der Job am realen Tag-Lauf gelingt** — dieser Beleg entsteht mit dem ersten
Tag-Lauf nach Anlage des Repo-Secrets und steht danach als Beobachtung im Register.

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

- **Der Job ist nur als Datei geprüft.** Die Fälle lesen `release.yml`, `make ci-lint` prüft die Syntax; kein
  Secret wirkt in einem Gate. **Ausgang: *weiter offen*** — ins Beobachtungs-Register:
  [`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md),
  Evidence-Datei `slice-release-job-tap-nachzug-und-schritt-7-folgt.md`; die Zusage bleibt auf das Gehaltene
  eingeschränkt ([`AGENTS.md`](../../../../AGENTS.md) §3.6), der erste Tag-Lauf ist der Beleg.
- **Der Job-Schritt verzweigt auf die Klasse des Ziels.** **Ausgang: *entfallen*** — der Fall hält es: der
  Job-Schritt verzweigt nicht (kein `case`, kein `$?`-Vergleich, kein `|| true`), ein Fall der Suite bindet die
  Abwesenheit und färbt beim Eintritt rot (Verifier-Report, Punkte 1 und 4);
  [`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Trigger 1 ist nicht
  eingetreten (Architect-Verdikt,
  [`ADR-0073`](../../adr/0073-der-ort-des-tap-zugangsgeheimnisses-ist-das-repo-secret.md)).
- **Der Slice ist für eine Review-Sitzung zu groß.** **Ausgang: *entfallen*** — der Review trägt beide
  Liefer-Punkte in einer Sitzung
  ([`../../../reviews/2026-09-29-slice-release-job-tap-nachzug.md`](../../../reviews/2026-09-29-slice-release-job-tap-nachzug.md):
  0 HIGH, Verdikt nicht merge-blockierend).

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

Wird bei der Closure geschrieben — von der Rolle Planner in frischem Kontext (AGENTS.md §3.10), nach Review und
Verifikation, in der Form der Regeln oben.

**Geliefert:** der Job `tap` in `.github/workflows/release.yml` in der Form von
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
Folgepflicht 2 in der Lesart von
[`ADR-0073`](../../adr/0073-der-ort-des-tap-zugangsgeheimnisses-ist-das-repo-secret.md) — Repo-Secret im
Step-`env`, keine Umgebung, die Fadenkreuz-Bindung tragen `needs: publish`
und der Tag-Trigger —, mit zehn `bats`-Fällen, je Aufzählungs-Zeile einer; und Schritt 7 von
[`docs/user/releasing.md`](../../../user/releasing.md) nennt den Job als Regelweg und
`make tap-nachzug TAG=<tag>` mit `TAP_TOKEN` in der Umgebung des Aufrufers als lokalen Ausfallweg, den Beleg
`make tap-check TAG=<tag>` (Schritt 8 hängt an ihm). Review
([`../../../reviews/2026-09-29-slice-release-job-tap-nachzug.md`](../../../reviews/2026-09-29-slice-release-job-tap-nachzug.md):
F-1 MEDIUM, F-2 LOW, Verdikt nicht merge-blockierend) und Verifikation
([`../../../reviews/2026-09-29-slice-release-job-tap-nachzug-verify.md`](../../../reviews/2026-09-29-slice-release-job-tap-nachzug-verify.md),
Commit `459ea58d`: alle Prüfpunkte bestätigt) liegen vor.

**Ergebnis der Frage von
[`ADR-0066`](../../adr/0066-exit-klassen-des-tap-werkzeugs-sind-die-des-skripts.md) Trigger 1
(Architect-Verdikt,
[`ADR-0073`](../../adr/0073-der-ort-des-tap-zugangsgeheimnisses-ist-das-repo-secret.md)):** nicht eingetreten —
der Job-Schritt verzweigt nicht auf die Klasse des Ziels;
jedes Nicht-Null ist ein roter Job, und ein Fall der Suite bindet die Abwesenheit.

**Was funktioniert hat:** §1 trug die alternden Aussagen als Adresse — der Lauf las Schritt 7 an seinem Start und
zog Handlung, Voraussetzung, Satz zur Rolle und die Grenze; LP2 verlangte, die Wiedergaben gegen Skript und
Workflow statt gegen diesen Plan zu fahren, und Review und Verifier haben genau das gefahren. Die Deckungslücke
(kein Gate hält `releasing.md` gegen die Quellen) war im Plan benannt, nicht verdeckt.

**Was anders lief:** die Abweichung von
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)
Festlegung 4 war im Plan begründet und test-gebunden, trug sie
aber kein lebendes Artefakt — das Fahrzeug der Abweichung von einer `Accepted`-ADR ist das Architect-Verdikt als
Folge-ADR (Klasse *ADR-Abweichung nur im Plan getragen*, Erstauftreten, Register-Eintrag unten), und es liegt als
[`ADR-0073`](../../adr/0073-der-ort-des-tap-zugangsgeheimnisses-ist-das-repo-secret.md) (`Proposed`,
Teil-Supersedes von
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md)) vor.

**Steering-Loop-Eintrag (Lerneintrag — geschärfte Regel):** Ein Wächter, der eine Datei liest und je Zusage-Zeile
einen Fall trägt (hier: zehn `bats`-Fälle über die Job-Form), bekommt seine Rot-Erfahrung als Hand-Nachweis
**je Fall**, solange kein Mutations-Fall die Klasse fährt — die strukturelle Ableitbarkeit der Rot-Bindung aus
dem Ausdruck ist eine benannte Lücke, kein Beleg. Zwei der zehn Fälle sind so rot gesehen; die Rot-Meldung ist
der im Fall gebundene Text, nicht eine generische Fehlform. Die Anlage eines `test/mutations/`-Falls je Klasse —
die offene Anlage-Frage von
[`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)
— ist der Träger, der den Hand-Nachweis auf den Einzelfall begrenzt. Die
Verkörperung ist Architect-Arbeit (AGENTS.md §3.8); der Eintrag ist gezählt, nicht verkörpert.

**Verbleibende Lücken mit Trägern:** (1) ob das Repo-Secret so wirkt, wie der Job es voraussetzt, belegt der
erste reale Tag-Lauf — Risiko-Ausgang *weiter offen* (§6); (2) der Schreib-Pfad gegen die reale
Tap-Schnittstelle bleibt ungefahren (§1, Out-of-Scope) — derselbe Tag-Lauf; (3) die Klasse
[`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
ist mit F-2 ein **viertes** Mal eingetreten — nach der Verkörperung (Zielort
`.claude/commands/implement-slice.md`, Punkt 17). Die Trägerschaft ist damit der Befund; die nächste Stufe ist
eine Hard Rule — Übergabe an den Architect, die Grenz-Zeile des Register-Eintrags trägt sie.

**Beobachtungs-Register (`../observations/`):**
`evidence/slice-release-job-tap-nachzug-und-schritt-7-folgt.md` ergänzt in
[`BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle`](../observations/BEO-ALL/prozedur-wiedergabe-eines-werkzeug-vertrags-reicht-weiter-als-die-quelle/observation.md)
— der Ausgang der Zeile steht (*verkörpert*); das Auftreten nach der Verkörperung löst die Eskalation ihrer
Grenz-Zeile aus (s. o.) · `evidence/slice-release-job-tap-nachzug-und-schritt-7-folgt.md` ergänzt in
[`BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel`](../observations/BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel/observation.md)
(Risiko-Ausgang *weiter offen*, §6) · neu angelegt:
[`BEO-ALL/adr-abweichung-nur-im-plan-getragen`](../observations/BEO-ALL/adr-abweichung-nur-im-plan-getragen/observation.md)
(Erstauftreten, `offen`). Keine weitere Beobachtung angefallen — die Summary-Zeile des Reviews führt genau zwei
Finding-Klassen, beide sind oben am Register.

**Handbuch, Weg C:** der Satz in
[`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md), die Formel „wird je Release-Schnitt aus
dem Formel-Asset desselben Schnitts nachgezogen", liest sich gegen den Ist-Zustand: der Job `tap` vollzieht den
Nachzug am Tag-Push, der Satz nennt keinen Mechanismus und bleibt wahr; der Beleg des Zusammenspiels ist der
erste Tag-Lauf. Das Handbuch bleibt unberührt.

**Risiken aus §6:** *weiter offen* (Job nur als Datei geprüft — ins Register) · *entfallen* (Verzweigung — der
Fall hält die Abwesenheit, Trigger 1 nicht eingetreten) · *entfallen* (Review-Umfang — eine Sitzung, 0 HIGH).

**Drei Paarungen:** Anker — diese Notiz trägt kein `liegt in`-Feld, der Lerneintrag ist gezählt, nicht
verkörpert; die Paarung hat keinen Gegenstand. Folge-Slice — keiner genannt. Register — die drei genannten
Einträge existieren mit nicht leerem `evidence/`.

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
