# Slice slice-lifecycle-move-schreibt-in-reports-nur-die-link-form: `make slice-mv` schreibt in `docs/reviews/` nur die Adresse hinter `](`

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — dieser Slice trägt keine Closure-Bedingung, die über seine
DoD hinaus etwas beobachtet, siehe Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:** [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
(`Accepted`; Festlegung 1 und Folgepflicht 1),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Festlegung 1, an einer Stelle geschnitten durch die erste ADR dieser Liste),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md),
[`ADR-0030`](../../adr/0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(der Prüfbereich des Doku-Gates bleibt, wie er ist).

**Berührte Spec-Stellen:** `—` — Prozess-ADR ohne Spec-Stratum: sie ändert die
Reichweite eines Werkzeugs, keine Spec-Aussage und keine Gate-Schwelle.
Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

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

**Ziel:** `make slice-mv` ersetzt beim Nachzug in einer Datei unter `docs/reviews/` die Adresse
nur dort, wo sie unmittelbar hinter `](` steht und bis zum schließenden `)` oder `#` reicht;
jede andere Pfad-Adresse in dieser Datei bleibt Byte für Byte, und in den übrigen Bäumen
ersetzt das Werkzeug wie bisher jede Form
([`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Festlegung 1). Die Erkennung ist syntaktisch, keine Span- oder Fence-Erkennung.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Nachzug von `archive-welle` (Go, `internal/archive`)** — ein Folge-Slice übernimmt ihn:
  `slice-archive-welle-schreibt-in-reports-nur-die-link-form`. Zweite Sprache, eigener Test und
  eigener Mutations-Fall; keiner der beiden Träger wartet auf den anderen, und beide zusammen
  sprengten das Größenmaß (§3, Größenurteil). Bis der zweite Träger folgt, gilt der Übergang aus
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  Festlegung 5 (eine von Hand wiederhergestellte Code-Span-Adresse bleibt zulässig).
- **Der Kopplungs-Test gegen `.d-check.yml`** — ein Folge-Slice übernimmt ihn:
  `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt`. Er hält eine
  Config-Zeile, keinen Träger, und folgt nach beiden Trägern: davor bewachte er eine Regel, die
  kein Träger führt.
- **Kontext-Erkennung im Träger (Span-Grenzen, Fence-Zustand)** — Alternative D″ ist in
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  abgelehnt: der Umbau wäre größer als die Regel, die er schützt. Das Link-Zitat im Code-Span wird
  mitersetzt; Trigger 6 der ADR hält, wann das neu zu bewerten ist.
- **Das Zitat im Code-Block und die Referenz-Definition `[name]: ziel`** — benannte Lücken der ADR
  (Trigger 6 und 7): der Bestand ist leer, und eine Zusage ohne rot gesehenes Gegenbeispiel wäre
  [`AGENTS.md`](../../../../AGENTS.md) §3.6 verletzt.
- **Der Nachzug in `docs/plan/planning/done/`** — bleibt in jeder Form
  ([`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  Festlegung 1 und 3);
  die Operand-Form dort ist die benannte Restungleichbehandlung, kein Gegenstand dieses Slice.
- **Die emittierte Fassung** (`internal/emit/templates/enforce/slice-mv.sh`) — die Form-Regel gilt
  für dieses Repo; was ein Zielrepo bekommt, entscheidet der Vorgang, der die Tool-Ebene
  entscheidet. Liegt die Regel in einer Funktion der Liste `KERN` aus `test/slice-mv.bats`, ist das
  eine Rückführung (§4), keine Erweiterung.
- **`.d-check.yml` und die Ausnahmeliste** — unberührt: `docs/reviews` wird **kein** Eintrag von
  `eingehend_ausgenommene_pfade()`, und es entsteht keine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5.
- **Bestand in Reports** — was frühere Nachzüge dort umgeschrieben haben, bleibt: Zeitdokument, und
  ein Nachziehen wäre ein eigener Vorgang.

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

- [x] **Liefer-Punkt 1 — die Form-Regel im Träger.** `harness/tools/slice-mv.sh` ersetzt in einer
      Datei unter `docs/reviews/` die Adresse nur hinter `](` (bis `)` oder `#`); jede andere
      Pfad-Adresse dort bleibt Byte für Byte. Der Kommentar an `eingehend_ausgenommene_pfade()`
      zitiert für den Nachzug
      [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
      statt des Abnahme-Kriteriums 1 von
      [`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md), das den Suchraum des
      Hänger-Wächters regelt. *Bricht, wenn:* die Form-Regel entfällt (die Adresse in Span, Operand,
      Block oder Fließtext ist umgeschrieben — Politik A der ADR), oder der Link-Nachzug dort
      entfällt (der Link ist tot — Politik B, an einem Move `+2` `target-missing` gemessen), oder
      der Träger nur den unmittelbaren Backtick-Kontext ausnimmt (er besteht den reinen Span-Fall
      und bricht Operand, Block und Fließtext).
- [x] **Liefer-Punkt 2 — die Tests, die sie halten.** In `test/slice-mv.bats` und — für die
      Verdrahtung in `main()`, die das bats-Image mangels `git` nicht fährt — im Echt-Test
      `cmd/ai-harness-init/slice_mv_echt_test.go`: (a) **eine** Datei unter `docs/reviews/` trägt
      einen Link auf den bewegten Slice und vier Nicht-Link-Formen (reiner Pfad-Span, Operand in
      einem Kommando-Span, Pfad im Code-Block, Pfad im Fließtext): der Link ist nachgezogen, die
      vier Formen sind Byte für Byte gleich. (b) Link-Syntax als Zitat in einem Code-Span wird
      mitersetzt — die Grenze ist gemessen. (c) In einer Datei unter `docs/plan/planning/done/`
      werden Link, reiner Pfad-Span und Operand weiter ersetzt. (d) Ein Mutations-Fall in
      `test/mutations/` färbt bei **beiden** Mutationen (Form-Regel entfällt · Link-Nachzug
      entfällt) je einen Fall rot und bindet beide Hälften einer Datei. *Bricht, wenn:* (a) ein Fall
      nur den reinen Span führt — der Regex-Träger, der nur den unmittelbaren Backtick-Kontext
      ausnimmt, bliebe grün; (b) ein Träger eine Kontext-Erkennung bekommt — der Fall fällt, und das
      ist Re-Evaluierungs-Trigger 6 der ADR, keine Umkehrung des Falls; (c) die Form-Regel auf
      einen zweiten Baum ausgedehnt wird; (d) ein Fall nur eine Hälfte bindet. Jedes dieser Rot ist
      einmal gesehen und in seiner Meldung gelesen
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [x] **Liefer-Punkt 3 — die Sensor-Doku.** `harness/sensors/slice-mv.md` nennt die Form-Regel in
      seiner Grenze, samt der zwei benannten Lücken (Code-Block-Zitat, Referenz-Definition).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
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
| `harness/tools/slice-mv.sh` | update | Liefer-Punkt 1: die Regel als eigene Funktion und ein Pfad-Zweig in `main()`; Kommentar an der Ausnahmeliste |
| `test/slice-mv.bats` | update | Liefer-Punkt 2 (a)–(c): Ersetzungs-Funktion direkt, Fälle nach den Fitness-Zeilen 1, 2 und 5 der ADR |
| `cmd/ai-harness-init/slice_mv_echt_test.go` | update | Liefer-Punkt 2: der Pfad-Zweig in `main()` an einem echten Scratch-Repo, wie der Skriptkopf es für `main()` nennt |
| `test/mutations/` | neu | Liefer-Punkt 2 (d): ein Fall, der beide Hälften einer Datei bindet; Anker gegen den Quell-Bestand gemessen ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)) |
| `harness/sensors/slice-mv.md` | update | Liefer-Punkt 3: Grenze |

- **Größenurteil.** Drei Liefer-Punkte, zwei Schichten (Werkzeug-Skript samt Tests, und die Doku
  dazu). Die Folgepflicht 1 der ADR fasst beide Träger und die Sensor-Docs in **einem** Slice; der
  Kopplungs-Test (Folgepflicht 4) käme als vierter Punkt hinzu und sprengte das Maß von drei. Auch
  ohne ihn trägt der Schnitt zwei Sprachen (Shell und Go), zwei Test-Ebenen (bats und Go-Test), zwei
  Mutations-Fälle und zwei Sensor-Docs und ist damit nicht in **einer** Review-Sitzung prüfbar; die
  Träger sind darum je ein Slice, ohne Reihenfolge untereinander, und der Kopplungs-Test ein dritter,
  der beiden folgt. Kein Schnitt nach Schichten: jeder der drei liefert für sich, was er zusagt.
- **Ansatz.** Je Träger eine Regel mit dem Anker `](` und ein Pfad-Zweig für Dateien unter
  `docs/reviews/`, keine Kontext-Erkennung. Ob die Regel in einer Funktion der Liste `KERN` liegt
  (dann zieht die emittierte Fassung mit, und der Slice ist zu groß — §4) oder daneben, entscheidet
  der Implementer und sagt es in seinem Bericht.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): der Slice ist priorisiert und sein Rolleninhaber gesetzt. Keine
Abhängigkeit von den zwei Geschwistern: `slice-archive-welle-schreibt-in-reports-nur-die-link-form`
und der Kopplungs-Slice laufen unabhängig.

**Adress-Messung vor dem Move** ([`AGENTS.md`](../../../../AGENTS.md) §3.11): kein Artefakt außerhalb
dieser Datei nennt sie als Pfad, weder mit `open/` als Code-Span noch als Markdown-Link; die
Geschwister und das Register nennen sie bei der Kennung
(`grep -rnI --exclude-dir=.git --exclude-dir=.harness -E 'slice-lifecycle-move-schreibt-in-reports-nur-die-link-form\.md|(open|next|in-progress|done)/slice-lifecycle-move-schreibt-in-reports-nur-die-link-form|\]\(slice-lifecycle-move-schreibt-in-reports-nur-die-link-form' . | grep -v 'planning/done/slice-lifecycle-move-schreibt-in-reports-nur-die-link-form.md' | wc -l`
→ **0**, gemessen 2026-09-26). Der Move hat damit keinen Verweis nachzuziehen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): die Regel liegt in einer Funktion der
  Liste `KERN` und die Kopplung in `test/slice-mv.bats` verlangt die emittierte Fassung
  nachzuziehen (`internal/emit/templates/enforce/slice-mv.sh` ist eine eigene Schicht, §1); oder
  der Echt-Test für `main()` lässt sich nicht in derselben Review-Sitzung prüfen.
- `in-progress` → `open` (blockiert): `codepaths.exempt-paths` nimmt `docs/reviews/**` nicht mehr
  aus (Re-Evaluierungs-Trigger 1 der ADR) — die Regel ist dann zu streichen, der Slice ist
  gegenstandslos und geht als Stilllegung nach `done/`; oder eine Folge-ADR ersetzt
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  vor der Closure.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Die Tests aus Liefer-Punkt 2 laufen in `make gates` grün, und die Rot-Belege der DoD sind je
   einmal gesehen; wo der Implementer-Bericht einen nicht führt, trägt der Verifier ihn nach
   (Baseline-Regelwerk `modul-11-verification.md` §Bewusstes Brechen für DoD-Testbehauptungen).
2. In einer Kopie von `git archive` außerhalb des Repos meldet `make docs-check` nach einem Move
   mit einem Report-Link und einem Report-Span-Verweis keinen `target-missing` mehr als vor dem
   Move (Politik D der ADR; das Rezept steht im Architect-Verdikt
   `2026-09-26-architect-verdikt-slice-mv-und-eingefrorene-adressen`).

Der Lerneintrag steht in §7 in einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Die Ausgänge sind bei der Closure gesetzt (Planner, 2026-09-26); die Belege stehen je Risiko daneben und in §7.

- **Der Anker des neuen Mutations-Falls liegt verschoben** — das `sed`-Muster trifft die Fassung
  der letzten Lektüre, nicht den Quell-Bestand
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
  **Ausgang: *entfallen*.** Die acht Anker der Fälle `459` bis `466` treffen im Quell-Bestand je genau eine
  Stelle (Festtext-Messung am Stand `7c4f8312`, `grep -cF` je Anker gegen `harness/tools/slice-mv.sh` → `1`), und
  der Verifier fuhr die acht Fälle im Teillauf (`13 ok, 0 Befund(e)`) und `462` und `465` einzeln bis zum roten
  Test mit gelesener Meldung.
- **Ein Regex-Träger besteht alle Fälle und bricht die Byte-Gleich-Zusage** — er nimmt nur den
  unmittelbaren Backtick-Kontext aus (Fitness-Zeile 1 der ADR, Gegenbeispiel). Der Fall mit vier
  Nicht-Link-Formen in **einer** Datei ist der Wächter dagegen. **Ausgang: *entfallen*.** Der Review färbte den
  Fall mit dieser Schwächung rot (Operand, Block und Fließtext werden umgeschrieben; der Verifier übernahm es
  aus dem Review, nachgefahren hat es keiner der beiden Folgeläufe); unter `459` färbt er rot, und die
  Gegenprobe des Verifiers (Byte-Gleichheitszeile entfernt, Mutation aktiv) wird grün — die Gleichheitszeile
  bindet.
- **Der Test fährt die Verdrahtung nicht:** das bats-Image führt kein `git`, ein Fall auf der
  Funktion bliebe über einem `main()` ohne Pfad-Zweig grün. **Ausgang: *entfallen*.** Der Echt-Test trifft den
  Zweig in `main()` selbst, und `462` (die Mutation, die den Zweig umgeht) färbt
  `TestSliceMvEchtSchreibtInReportsNurDieLinkForm` rot (Meldung `Report: nur der Link darf nachgezogen sein`,
  von Review und Verifier gelesen).
- **KERN-Kopplung und emittierte Fassung** — liegt die Regel in `KERN`, bricht
  `kopplung: die Funktionen der Liste KERN sind in beiden Fassungen wortgleich`. **Ausgang: *entfallen*.** Die
  Regel liegt daneben (`grep -n 'KERN=' test/slice-mv.bats` → Zeile 408 mit
  `re_escape rewrite_incoming_in_file rewrite_incoming_bare_in_file rewrite_outgoing_bare_in_file`), der
  Kopplungs-Fall ist grün (`1..23`, Verifier), und `git diff --stat bc96ec5a..7c4f8312 -- internal | wc -l` →
  `0`. Die spätere Härtung von `psed_i` liegt ebenfalls außerhalb von `KERN`, ändert aber den Rückgabewert der
  Funktionen in `KERN` — das ist kein Risiko dieses Plans, sondern eine Beobachtung (§7, Register).
- **Das Link-Zitat im Code-Span wird mitersetzt** — die Grenze der ADR, im Bestand inert
  (`Span 9 · Block 0`, `0` mit beweglichem Ziel, Kommando in der ADR, Stand des Accepts). **Ausgang: *weiter
  offen*** als benannte Grenze in der Sensor-Doku (die Span-Hälfte bindet der bats-Fall, der das Zitat als
  mitersetzt festhält); Träger ist Trigger 6 der ADR, kein Register-Eintrag, solange kein Move eine solche Zeile
  umschreibt; der Politik-D-Lauf des Verifiers am Move von `slice-071-bilanz-nennt-ihren-bestand` schrieb in
  `docs/reviews/` allein zwei Link-Ziele um.

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

Wird bei der Closure vom Planner geschrieben
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht vom Implementer; die Zeilen folgen der Vorlage.

Geschrieben von der Rolle Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10), nach Review und
Verifikation. Alle Kommandos gemessen am 2026-09-26 am Stand `7c4f8312`, keine Erwartungswerte
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

- **Was hat funktioniert:** Der Schnitt hielt: drei Liefer-Punkte, zwei Schichten, keine der beiden Rückführungen
  aus §4 ausgelöst (die Regel liegt außerhalb von `KERN`, der Echt-Test ist in einer Sitzung prüfbar). Der
  Verifier bestätigte Liefer-Punkt 1 bis 3 und den Closure-Trigger 2: an einem Move in einer Kopie von
  `git archive` außerhalb des Repos (`slice-071-bilanz-nennt-ihren-bestand`) schrieb `make slice-mv` in
  `docs/reviews/` genau zwei Zeilen um, beide Link-Ziele, und die fünf Nicht-Link-Vorkommen blieben Byte für
  Byte; `make docs-check` meldete vorher wie nachher `1974 Datei(en) geprüft, 0 Befund(e)`, kein `target-missing`.
  Die Fälle `459` bis `466` färben je den Test aus dem behaupteten Grund rot; fünf Gegenproben des Verifiers
  (Zusicherung entfernt, Mutation aktiv) wurden grün, die Zusicherungen binden also. Die bats-Fälle 12 bis 21, der
  Echt-Test der Härtung wurden gegen frühere Skript-Stände rot gesehen (Verifier: Vorzustand des Slice und Stand des
  Reviews).
  **Ergebnis-Fakten:** `grep -c '^@test' test/slice-mv.bats` → **23**;
  `ls test/mutations/*.sh | wc -l` → **454**;
  `git diff --shortstat bc96ec5a..7c4f8312 -- harness/tools/slice-mv.sh test cmd harness/sensors/slice-mv.md` →
  **13** Dateien, **599** Einfügungen, **26** Löschungen.
- **Was ging anders als geplant:** Der Review (Runde 1, Stand `83044cc4`; 0 HIGH, 0 MEDIUM, 1 LOW, 4 INFO) fand
  R-1: die Aufrufform `… || continue` schaltete `set -e` im Funktionsrumpf ab, und `psed_i` schrieb nach einem
  gescheiterten `sed` die leere Zwischendatei zurück (Datei 0 Byte). **Die Härtung von `psed_i` (`2e6e5684`) ist
  gebaut, nicht geplant:** weder §3 noch die DoD nennen sie. Der Verifier wertete sie als im Rahmen der DoD
  (Liefer-Punkt 1 sagt *„jede andere Pfad-Adresse bleibt Byte für Byte"*, und die Aufrufform des Slice brach das im
  Fehlerfall), **und der Planner schließt sich an** — mit dem Zusatz, den der Verifier benennt: sie ändert den
  Rückgabewert von `psed_i` und damit von **jedem** Aufrufer, in **allen** Bäumen (ein Nachzug in `done/` bricht bei
  Ausfall jetzt ab), also mehr als das Format der Reports. Gebaut, nicht geplant sind außerdem: `main()` wertet den
  Status aus, die Fälle `463` bis `465`, die bats-Fälle 19 bis 21, `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb`,
  der Fall `466` und ein bats-Fall für mehrere Links je Zeile (R-3), in der Sensor-Doku der Abschnitt zum Abbruch
  und der Rand Titel-Link und Spitzklammer-Form (R-2). **Wer was gelesen hat:** der Review las bis `83044cc4`;
  `2e6e5684`, `12727a25`, `cbaaee83`, `83d14458`, `31fe3217` und `52417dea` hat **kein Reviewer** gelesen, nur der
  Verifier (Stand `52417dea`) las und fuhr sie; die zwei letzten Wortlaut-Nachzüge (`e37b8e53`: Skriptkopf und
  Kommentare, V-1 und V-5; `7c4f8312`: Sensor-Doku) haben **weder ein Reviewer noch der Verifier** gelesen — der
  Implementer belegte sie mit den Gates und einer Emulation, und der Planner fuhr `make gates` grün über den Stand
  `7c4f8312` (Exit 0) und las dazu allein den Abschnitt der Sensor-Doku zu V-1. Eine Nachrunde ist nicht gelaufen
  und wird nicht behauptet; das Häkchen *Review durchgeführt* bestätigt Runde 1 samt gezogenen Findings.
  **Die emittierte Fassung führt die Regel bewusst nicht** (§1, Ausschluss; Review R-4): ein gebootstrapptes Ziel
  behält den Nachzug in jeder Form auch in Reports; kein Slice trägt die Entscheidung darüber, das ist benannt.
- **Mutate: Teilmessung, keine Gesamtaussage.** Real gefahren ist `make mutate MUTATE_JOBS=1 MUTATE_CASES='313 315 316 346 363-slice-mv 459 460 461 462 463 464 465 466'`
  (Verifier, Stand `52417dea`): `13 ok, 0 Befund(e)`, `TEILLAUF 13 von 454 — kein Beleg`; der Beleg-Slot
  `.harness/state/mutate-passed.key` war vorher wie nachher nicht vorhanden. Der Implementer fuhr nach eigener Angabe
  die Fälle mehrfach am jeweiligen Stand, von keiner anderen Rolle nachgefahren. Am Endstand `7c4f8312` gemessen
  ist allein der Anker jedes der acht neuen Fälle (Risiko 1, §6), nicht die Fälle selbst; die fünf Bestandsfälle
  `313`, `315`, `316`, `346` und `363-slice-mv` liefen am Stand des Verifiers. **Nicht gefahren:** ein voller
  `make mutate`; der Beleg-Slot von [`ADR-0035`](../../adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md)
  ist nicht geschrieben. Eine Aussage über das grüne Ganze trägt diese Closure nicht.
- **Nicht gemessen:** die dritte Klausel der Bricht-wenn-Liste (Träger nimmt nur den unmittelbaren Backtick-Kontext
  aus): der Review fuhr sie, der Verifier übernahm sie, der Planner fuhr sie nicht. Der Commit-Abbruch bei
  Ausfall der einzigen umgeschriebenen Datei (V-2, `git commit` scheitert an „nichts zu committen") ist aus dem Code
  abgeleitet, gefahren ist nur das Status-0-Verhalten samt falschem Zähler. Die emittierte Fassung ist gelesen,
  `make full-smoke` lief nicht. Der `mktemp … || return 2`-Zweig in `psed_i` ist nur gelesen; `|| return 2` in
  `rewrite_incoming_nach_baum` trägt keinen eigenen Zahn (V-4, Verifier: entfernt bleibt die Suite `1..23` grün,
  weil `[ "" -gt 0 ]` ebenfalls Status 2 liefert).
- **Benannte Grenze zu V-1 (Zusage je Datei, nicht je Lauf):** die Sensor-Doku sagt seit `7c4f8312`, der Abbruch
  gelte **je scheiternde Datei**; Dateien, die die Schleife vor dem Ausfall nachgezogen hat, bleiben
  umgeschrieben und ungestaged im Arbeitsbaum (`git restore .`), und der Ausfall an einer **späteren** Datei ist
  **nicht gebunden** — der Go-Test lässt jeden `sed -E` scheitern, also fällt schon die erste Datei; gefahren hat
  ihn allein der Verifier (Exit 2, ein Commit, elf getrackte Dateien geändert). Die Alternative, den Nachzug erst
  nach dem letzten Erfolg zu schreiben, ist ein Umbau des Codes und **Gegenstand einer Übergabe** an einen
  künftigen Lauf, keine Closure-Handlung und kein angelegter Slice (Register, unten).
- **Steering-Loop-Eintrag (Form: neuer Sensor).** Der Träger `make slice-mv` führt die Form-Regel des Nachzugs, und
  sie ist gemessen statt behauptet: die bats-Fälle 12 bis 21 in `test/slice-mv.bats`, der Echt-Test
  `TestSliceMvEchtSchreibtInReportsNurDieLinkForm` für die Verdrahtung in `main()` samt
  `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb` und die Mutations-Fälle `459` bis `466`, von denen `459`/`460`
  je eine Hälfte einer Datei binden, `461` den zweiten Baum, `462` die Verdrahtung, `463` bis `465` den Abbruch,
  `466` die Link-Grenze. **Kein Zielort-Feld und kein Herkunfts-Anker:** die Regel ist eine Setzung von
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) (`Accepted`) und trägt
  ihre eigene Kennung; sie entstand nicht aus einem 3×-Übertritt eines Eintrags, den dieser Slice verkörpert, und
  die Paarung (a) hätte nichts, gegen das sie prüft. **Grenze des Sensors, benannt:** das Zitat im Code-Block und die
  Referenz-Definition (Trigger 6 und 7 der ADR) bindet kein Fall; das Link-Zitat im Code-Span bindet Fall 16 als
  *„wird mitersetzt"*; der spätere Ausfall (V-1) ist ungebunden; ein Kopplungs-Test gegen `.d-check.yml` führt dieses
  Werkzeug noch nicht (der dritte Slice der Liste); die emittierte Fassung führt die Regel nicht.
- **Beobachtungs-Register (`../observations/`):** je Beleg `evidence/slice-lifecycle-move-schreibt-in-reports-nur-die-link-form.md`;
  Zähler gelesen mit `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`
  ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)).
  **Neu angelegt (1×, `offen`):**
  [`fehlerabbruch-durch-aufruf-im-oder-kontext-entwaffnet`](../observations/BEO-ALL/fehlerabbruch-durch-aufruf-im-oder-kontext-entwaffnet/observation.md)
  (R-1),
  [`abbruch-zusage-gilt-je-datei-und-nicht-je-lauf`](../observations/BEO-ALL/abbruch-zusage-gilt-je-datei-und-nicht-je-lauf/observation.md)
  (V-1) und
  [`haertung-eines-helfers-erreicht-nicht-alle-aufrufer`](../observations/BEO-ALL/haertung-eines-helfers-erreicht-nicht-alle-aufrufer/observation.md)
  (V-2 und V-3). **Ergänzt:**
  [`eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`](../observations/BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet/observation.md)
  (**11×**, Stand `geplant` unverändert; der Vorgang ist der Claim-Commit `9840d434`, der den Ruhe-Marker der Roadmap
  entfernte; der Planner stellt ihn mit dieser Closure wieder her). **Dieselbe Beobachtung? — je Kandidat begründet.**
  *V-1* nicht in
  [`doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst`](../observations/BEO-ALL/doku-zusage-nennt-den-test-dessen-fall-nur-einen-ausschnitt-misst/observation.md)
  (**2×**): dort fährt der genannte Fall nur einen Ausschnitt der Eigenschaft, hier misst der Go-Test die
  Eigenschaft je Datei genau und die **Zusage** ist für den Lauf zu weit — die Grenze liegt in der Zusage, nicht im
  Fall; die Zuordnung ist ein Urteil des Planners, und wer sie anders zieht, hebt den Zähler auf **3×** und löst den
  Lese-Schritt aus. *V-2/V-3* nicht in
  [`positive-meldung-im-fehlschlag-zweig`](../observations/BEO-ALL/positive-meldung-im-fehlschlag-zweig/observation.md)
  (**1×**): dort meldet eine **Auswertung** über unbrauchbarer Eingabe positiv, hier reicht eine Härtung ihren
  Status nicht an alle Aufrufer weiter. *V-4* (Rückgabe-Zweige ohne Zahn) ist keine Instanz von
  `zusicherung-ueber-der-leeren-menge-wahr` (dort eine Negation über einer selbst besorgten Menge, hier ein Status,
  den eine Nachbarzeile zufällig liefert) und keine von `zeichenmenge-mitglied-ohne-eigenen-zahn` (Mitglieder einer
  Zeichenmenge); benannt in der Beobachtung zu V-2/V-3 unter *Benannt, nicht gezählt*, nicht gezählt. *V-5* (Skriptkopf und
  Sensor-Doku sagen die Ränder verschieden, beide wahr) ist keine veraltete Zusage und keine Instanz von
  `zusage-neben-geaenderter-ableitung-bleibt-stehen`; *R-2* und *R-3* sind im Vorgang behoben und nicht
  gezählt. **Lese-Schritt:** mit diesem Slice erreicht **kein** Eintrag erstmals die Schwelle **3×**; der einzige
  Eintrag über der Schwelle, den der Slice berührt, ist `eigentums-frage-…` und trägt seinen Ausgang (`geplant`).
  Ein Verkörpern verlangte ein Norm-Artefakt des Architect; eine Übergabe entsteht daraus nicht.
- **Folge-Slices:** keiner neu. Ein Slice für V-2/V-3 (Härtung der `KERN`-Funktionen `rewrite_incoming_bare_in_file`
  und `rewrite_outgoing_bare_in_file` und/oder `psed_i` der emittierten Fassung) ließe sich mit drei Liefer-Punkten
  schneiden, aber nicht auf **einer** Ebene: die `KERN`-Kopplung verlangt beide Fassungen wortgleich, und die
  emittierte Fassung geht in gebootstrappte Ziele — das ist ein Vorgang der Tool-Ebene. Der Befund ist INFO, seine
  Vorbedingung eng (ein Ausfall des `sed`), die Klasse steht bei 1×; ein Slice je Befund ist das Muster, das das
  Register ersetzen soll. Die Beobachtung steht `offen` mit diesem Grund. Die zwei Geschwister
  `slice-archive-welle-schreibt-in-reports-nur-die-link-form` und
  `slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt` (beide `open/`) bleiben; ihre
  Zustandsaussagen zieht der Planner nach dem Move nach.
- **Risiken aus §6:** fünf, je ein Ausgang — *entfallen* mit Grund: die ersten vier (Anker, Regex-Träger,
  Verdrahtung, `KERN`-Kopplung); *weiter offen:* das Link-Zitat im Code-Span, als benannte Grenze der Sensor-Doku
  mit Träger Trigger 6 der ADR, kein Register-Eintrag. Keines ist *eingetreten*.
- **Adressen vor dem Move ([`AGENTS.md`](../../../../AGENTS.md) §3.11):** das Kommando aus §4 zählte außerhalb dieser
  Datei vor dem Anlegen der Register-Belege **0** Zeilen und am Move-Tag **3**: sein erster Zweig
  `<Kennung>\.md` trifft auch den Dateinamen eines Reports, und die drei neuen Evidence-Dateien nennen die zwei
  Reports in Code-Spans (`docs/reviews/2026-09-26-…-<Kennung>.md`). Das sind ortsfeste Report-Pfade, keine
  Lifecycle-Adresse: der Lifecycle-Zweig allein (`(open|next|in-progress|done)/<Kennung>` und `](<Kennung>`) trifft
  außerhalb dieser Datei **0** Zeilen (2026-09-26, am Stand nach dem Move). Kein eingefrorenes Artefakt nennt den
  Slice als Pfad; die Reports und das Register nennen die Kennung. Der Zweig `<Kennung>\.md` ist für einen Plan, den
  ein Register-Beleg oder ein Report bei seinem Report-Namen zitiert, zu breit; ein Nachzug daran gehört in eine
  Bearbeitung des Kommandos, nicht in diese Closure.
- **Der Move, gemessen (`make slice-mv` nach `done/`, 2026-09-26):** zwei Commits, der reine Move (`5eb95e9b`, keine
  Zeile geändert) und der Nachzug (`a1ec56e4`), der **genau eine** Datei mit **einer** Zeile änderte — diese Datei
  selbst (der Ausschluss-Pfad im Kommando aus §4). Weder ein Report noch eine ADR wurde berührt
  (`git diff --name-only 5eb95e9b^..HEAD -- docs/reviews docs/plan/adr | wc -l` → **0**). **Das ist die erste
  reale Anwendung der Regel nach dem Accept von
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md), und sie übt die
  Form-Regel nur im Negativen:** kein Report nannte die Adresse, es gab in `docs/reviews/` nichts umzuschreiben. Die
  positive Übung (zwei Link-Ziele umgeschrieben, fünf Nicht-Link-Vorkommen unverändert) bleibt die Messung des
  Verifiers an `slice-071-bilanz-nennt-ihren-bestand`. Frage 2 der Verdikt-Reihe (*was geschieht beim ersten realen
  Move?*) ist damit beantwortet: nichts Falsches, aber auch keine neue Evidenz für die Regel.
- **Drei Paarungen (nach dem Move geprüft, 2026-09-26):** (a) *Anker:* der Eintrag trägt kein Zielort-Feld (siehe
  *Steering-Loop-Eintrag*), es gibt nichts zu paaren — benannt, nicht als grün behauptet. (b) *Folge-Slice:* beide
  genannten Kennungen bestehen als Dateien in `open/`
  (`ls docs/plan/planning/open | grep -c -e '^slice-archive-welle-schreibt-in-reports-nur-die-link-form.md$' -e '^slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt.md$'`
  → **2**). (c) *Register, beide Hälften:* **Hälfte 1 getragen** — jede in §6 und §7 genannte Beobachtung besteht als
  Verzeichnis mit nicht leerem `evidence/` (neun geprüft; Zähler gelesen 2026-09-26: 1, 1, 1, 11, 2, 1, 3, 1, 32).
  **Register-Paarung (c), zweite Hälfte: 4 Verzeichnisse ohne Beleg, namentlich
  `ci-rennt-gegen-die-publikation-des-gepinnten-releases`,
  `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`,
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` und
  `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`; nicht als getragen behauptet**
  ([`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md) Festlegung 2;
  `for d in docs/plan/planning/observations/BEO-ALL/*/; do n=$(ls "$d"evidence/*.md 2>/dev/null | wc -l); [ "$n" -eq 0 ] && echo "$d"; done`
  → vier Namen). Sie bestanden vor diesem Slice, und keines wurde von ihm angelegt oder berührt
  (`git diff --name-only bc96ec5a..HEAD | grep -cE 'ci-rennt-gegen|cpp-skelett|einstiegs-datei-weicht|planungs-bestand-waechst'`
  → **0**); der Befund endet erst mit dem Beleg eines abgeschlossenen Vorgangs. **Das Häkchen der letzten DoD-Zeile ist
  mit dieser Ausnahme gesetzt:** das Repo führt Wellen-Betrieb, und das Häkchen sagt dort, dass die nächste
  Welle-Closure die Paarungen prüft, nicht, dass sie ganz getragen sind (`.d-check.yml`, Kommentar zur
  `structure`-Regel für `done/`); ungehakt färbte die Zeile `make docs-check` rot
  (`section-open-tasks-marker-missing`) und verlangte eine `Gegenstand:`-Zeile, die für einen gelieferten Slice
  falsch wäre. Die zweite Hälfte von (c) bleibt eine benannte Ausnahme und ist kein getragener Punkt.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind `harness/tools/` (Kürzel `TOOLS`) und `*`
(gesamtes Repo, für Test und Doku), beide so, wie die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) sie
führt; eine neue oder gröbere Sub-Area entsteht nicht. Die Schwelle von 2 aus 3 Achsen ist an
diesen zwei Einträgen nicht neu gemessen.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; drei Einträge tragen
den Gegenstand dieses Slice (Nachzug schreibt in ein eingefrorenes Artefakt). Der Zähler ist die
Zahl der Dateien unter dem `evidence/` des Eintrags (Stand 2026-09-26; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

```sh
for d in docs/plan/planning/observations/BEO-ALL/verweis-nachzug-*/; do echo "$(ls "$d"evidence/*.md | wc -l) $d"; done
# 2 …/verweis-nachzug-bricht-tree-operand/
# 6 …/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/
# 14 …/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/
```

[`verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
und
[`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md)
stehen über der Schwelle und sind `verkörpert` (Zielort:
[`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) neben
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)); mit diesem Slice tritt
keiner erstmals über 3×. [`verweis-nachzug-bricht-tree-operand`](../observations/BEO-ALL/verweis-nachzug-bricht-tree-operand/observation.md)
steht unter der Schwelle: Ein Tree-Operand `<sha>:<pfad>` steht nicht hinter `](` und bliebe in
`docs/reviews/` damit Byte für Byte — abgeleitet aus der Form-Regel, nicht gemessen. Trifft der
Vorgang dieses Slice eine der Klassen, legt die Closure den Beleg an.

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF.
