# Slice slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo: Der Zielordner-Parameter richtet das Werkzeug auf ein Ziel-Repo

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
diese DoD — die neue Aufruf-Form, der zugenommene Unfall-Vektor und die
geprüfte Deckung sind Belege der Liefer-Punkte selbst; ein repo-weites Mehr
über sie hinaus existiert nicht.

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(der Init-Pfad ist der Bootstrap-Vorgang — der Zielordner ist seine
Auflösung von außen, statt über das Arbeitsverzeichnis),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 (der laut-Bruch deckt ein **unbekanntes** Unterkommando, nicht
das **fehlende** Argument — der Unfall-Vektor lag außerhalb seiner Deckung)
und Festlegung 3 (eigenes Fragment, eigenes Target, kein Prerequisite —
bleiben unberührt),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 3 (eigenes Fragment `traeger.mk` (im emittierten Ziel, eigener Target-Name) mit eigenem Target
`traeger-fetch`, kein Prerequisite — bleibt unberührt),
[Register-Beobachtung](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/observation.md)
`BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` (der Unfall, 1×,
offen);
Setzung des Auftraggebers vom 2026-09-19: die fehlende Zielordner-Form ist
Rauschen am Werkzeug und wird zur Fähigkeit; der leer-Argument-Schutz schließt
sich **durch das Feature**, nicht durch einen separaten Schutz-Slice — Prio 1
nach der laufenden Release-Closure, erster in der Kette.

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

**Ziel:** Das Werkzeug richtet sich von außen auf ein Ziel-Repo: Der
Init-Dispatch nimmt einen Zielordner entgegen — Flags vor dem ersten
Positionsargument, das Ziel als letztes Positionsargument
(`ai-harness-init [--lang …] <zielordner>`) — und löst sein Ziel aus dem
Argument, nicht aus dem Arbeitsverzeichnis. Ohne
Argument endet der Init-Pfad **laut mit dem Usage-Text, fail-closed** — kein
stiller Bootstrap-Lauf gegen das Repo, in dem er steht. Die zwei gemessenen
Belege des Anlasses: der Dispatch führt vier Fälle und keinen Default-Zweig
(`grep -c 'case "' cmd/ai-harness-init/main.go` → **4**), und die CWD-Zentralität
trägt das Ziel
(`grep -n 'os.Getwd\|run(os.Args' cmd/ai-harness-init/main.go` → Zeilen 572 und
582: `wd, err := os.Getwd()` vor `os.Exit(run(os.Args[1:], wd, src, …))`) — das
Arbeitsverzeichnis **ist** das Ziel, es gibt keine Form, das Werkzeug von
außen zu richten. Der Unfall-Vektor (Träger ohne Argument im
Repo-Wurzel-Verzeichnis) schließt sich durch dasselbe Feature: derselbe Defekt,
dieselbe Richtung, kein separater Schutz-Slice.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein separater Schutz-Slice für den leer-Argument-Fall** — **anderer
  Vorgang, integriert:** der Defekt des Unfalls (fehlendes Argument → stiller
  Init-Pfad) und die Fähigkeit (Zielordner) sind derselbe Dispatch-Griff; ein
  zweiter Slice für den Schutz würde die Oberfläche zweimal schneiden.
- **Kein Re-Publish von `v0.2.1`** — **anderer Vorgang:** das Release bleibt,
  wie es geschnitten ist; der **nächste** Release-Schnitt trägt die Fähigkeit
  in seinem Stand. Ein Re-Publish würde die Tag-Kopplung
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2) für denselben Stand zweimal vollziehen.
- **Keine Emissions-Struktur-Änderung** — **Schicht-Abgrenzung:** die
  Vorlagen-Klassifikation bleibt; der Pin, das Fragment
  (`traeger.mk` (im emittierten Ziel, eigener Target-Name), [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  Festlegung 3) und die Target-Form bleiben, wo sie stehen. Bewegt die
  Ziel-Logik ein Fragment, ist das ein §6-Risiko mit eigenem Ausgang, kein
  stiller Griff.
- **Kein zweiter Fetch-Weg** — **Bestand bleibt bewusst stehen:** der Fetch
  (Digest statt Signatur, [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 1) bleibt, wie er steht; der Zielordner-Parameter rührt den
  Init-Dispatch, nicht den Fetch.
- **Die `add-lang`-Semantik bleibt unberührt** — **Bestand bleibt bewusst
  stehen:** `<pfad>` bei `add-lang` ist der Modul-Pfad (Mono-Repo,
  wiederholbar), nicht das Ziel; der neue Parameter benennt das Ziel-Repo und
  konkurrenziert ihn nicht.

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

- [x] **Liefer-Punkt 1 — Dispatch mit Zielordner:** Der Init-Dispatch nimmt
      einen Zielordner entgegen — Flags vor dem ersten Positionsargument, das
      Ziel als letztes Positionsargument (`ai-harness-init [--lang …]
      <zielordner>`), denn `flag` liest Flags nur vor dem ersten
      Positionsargument — und löst sein Ziel aus dem Argument; ohne Argument
      endet der Init-Pfad laut mit dem Usage-Text (fail-closed), ein
      Zielordner, der kein Git-Repo ist, bricht laut.
      Test: die Go-Stufe trägt das Verhalten — `TestZielordner_AusDemArgument`
      (Happy: Ziel-Repo gebootstrapped ohne CWD-Abhängigkeit),
      `TestRun_OhneZielordnerBrichtLaut` (argumentlos → Usage),
      `TestRun_KeinGitRepoZielBrichtLaut` (kein-Git-Repo-Ziel → laut);
      `test/zielordner.bats` trägt die Struktur-Deckung, sein Kopf schreibt
      die Deckungs-Teilung ausgeschrieben — der Unfall-Vektor liegt in der
      Go-Stufe `TestUnfallVektor_OhneArgumentImRepoWurzel`, nicht im
      bats-Lauf. Rote Gegenprobe: kehrt der leer-Argument-Zweig zum stillen
      Init-Pfad-Start zurück, färbt der Go-Fall der Leer-Sperre rot —
      gelistet als `test/mutations/377-init-argumentlos-stiller-init.sh`
      (expect `TestUnfallVektor_OhneArgumentImRepoWurzel`), gemessen am
      Aufruf, nicht geerbt aus der Unfall-Erinnerung.
      **Beleg:** Verifikations-Report, DoD L1 (Prozess-Messungen 1–3; rote
      Gegenprobe 377, eigene Messung).
- [x] **Liefer-Punkt 2 — der Unfall-Vektor ist zugenommen:** der Aufruf, der
      den Unfall fuhr (Träger ohne Argument, gestanden im Repo-Wurzel-
      Verzeichnis), endet ohne Schaden — laut, mit dem Usage-Text, ohne dass
      das stehende Repo angefasst wird. Test: die Go-Stufe
      `TestUnfallVektor_OhneArgumentImRepoWurzel` fährt den Vektor (Träger
      ohne Argument, Wurzel-Verzeichnis) und prüft: nichts geschrieben, laut
      gebrochen. Rote Gegenprobe: unter der geschwächten Zusicherung (bricht,
      aber schreibt) muss der zweite Unfall-Fall rot bleiben.
      **Beleg:** Verifikations-Report, DoD L2 (Messung 1 am realen Träger;
      377 rot — eigene Messung, 378 rot in der Gate-Umgebung der Runde 2,
      Grenze V-1 charakterisiert).
- [x] **Liefer-Punkt 3 — Deckung:** die vier Dispatch-Fälle
      (`span-emit`, `span-report`, `archive-welle`, `vendor-baseline`) bleiben
      unberührt — ihre Festlegungen
      ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
      und [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
      Festlegung 3: eigenes Fragment, eigenes Target, kein Prerequisite)
      bleiben —, und die Sperren-Lücke ist geschlossen: der Dispatch führt
      keinen Default-Zweig mehr, der still in den Init-Pfad fällt.
      Rote Gegenprobe: bindet eine Mutation einen der vier Fälle an das
      Zielordner-Verhalten, färbt der bestehende Fall dieses Unterkommandos
      rot (`make span-check` bzw. der bats-Deckungs-Fall) — die vier bleiben,
      wo sie waren, oder der Lauf bricht.
      **Beleg:** Verifikations-Report, DoD L3 (Vorher/Nachher-Lektüre des
      Switches, `git show 0acdf385^:cmd/ai-harness-init/main.go`; die
      konditionale Gegenprobe blieb ungefahren, weil ihr Auslöser nicht
      existiert — Grenze benannt).
- [x] `make gates` grün. **Beleg:** der Lauf des Verifikations-Reports am
      Kopf `4ce1aa9a` (übernommen); der Closure-Lauf dieser Sitzung
      bestätigt nach dem Move.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
      **Beleg:** Runde 1 (drei HIGH, gezogen) und Runde 2 (frei für
      Verifikation und Closure), beide unter `docs/reviews/`.
- [x] Doku-Update für die neue Aufruf-Form, falls ein öffentlicher Vertrag
      berührt ist (der Zielordner ist öffentliche Oberfläche). **Beleg:**
      `README.md:21` und 11 Handbuch-Stellen tragen die neue Form
      (Nachzug-Prüfung der Runde 2); die Spec trägt CR 0.22.0 (`4ce1aa9a`).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. **Beleg:** diese Datei §7.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen
      Brownfield-Bootstrap und führt die Register-Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschritten — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert. **Beleg:** drei Verzeichnisse neu angelegt (§7); für
      `BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` keine
      Beobachtung angefallen (§7).
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen). **Beleg:** §6, je genau ein Ausgang; §7 fasst zusammen.
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der
      nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).
      **Beleg:** Ergebnis in §7; der Paarungs-Lauf läuft nach dem `git mv`.

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `cmd/ai-harness-init/main.go` | update | Zielordner-Argument am Dispatch; ohne Argument Usage-Text, fail-closed; Ziel-Auflösung löst die CWD-Zentralität (Zeilen 572/582) ab |
| `test/zielordner.bats` | neu | Struktur-Deckung — nach Liefer-Punkt 1 und 3; das Verhalten liegt in der Go-Stufe, der Kopf des Files schreibt die Deckungs-Teilung ausgeschrieben: der Unfall-Vektor liegt in der Go-Stufe, rote Gegenproben am Aufruf gemessen |
| `TestUnfallVektor_OhneArgumentImRepoWurzel` (Go-Stufe, `cmd/ai-harness-init/`) | neu | der Unfall-Vektor als Go-Test — hermetisch am Aufruf (Liefer-Punkt 2) |
| `docs/user/benutzerhandbuch.md` | prüfen, kein Inhalt-Zwang | die Aufruf-Form ist öffentliche Oberfläche — Update nur an der Aufruf-Stelle, wenn der Vertrag sie trägt; der pausierte Nachzug nennt die Stellen neu (§6) |

**Ansatz als Liste, wo eine Zeile pro Datei nicht trägt:**

- Die CWD-Fall-Entscheidung ist **fail-closed**: fehlt das Argument, druckt der
  Init-Pfad den Usage-Text und bricht — er fällt **nicht** auf
  `os.Getwd()` zurück. Das ist derselbe Defekt, den die
  [Register-Beobachtung](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/observation.md)
  trägt, geschlossen durch die Fähigkeit; ein stiller Default-Zweig entsteht
  nicht neu.
- Die Ziel-Prüfung (kein Git-Repo → laut) teilt die Richtung des
  laut-Bruchs ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2): unbekannte Unterkommandos brechen laut, und nun auch ein
  Ziel, auf dem der Init-Pfad nicht laufen kann — beide Zweige melden, statt
  zu starten.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Implementer übernimmt, die laufende
Release-Closure ist abgeschlossen (Prio 1 danach), WIP-Limit frei.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Ziel-Auflösung
  wächst über den Init-Dispatch hinaus — bewegt sie ein emittiertes Fragment
  oder ändert die Aufruf-Semantik der vier Unterkommandos mit. Dann Deckung
  und Aufruf-Semantik als eigenen Posten schneiden.
- `in-progress` → `open` (blockiert — Carveout?): Die Emissions-Struktur
  gerät inhaltlich unter die Hand (Fragment-Bewegung, Vorlagen-Klassifikation)
  oder eine tragende Festlegung
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)/[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md))
  wird superseded, bevor der Dispatch gefasst ist.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD mit den roten Gegenproben der drei Liefer-Punkte belegt, und der
Unfall-Vektor ist in der Go-Stufe `TestUnfallVektor_OhneArgumentImRepoWurzel`
gemessen (nicht geerbt): ohne Argument, im Repo-Wurzel-Verzeichnis, endet der
Aufruf laut und ohne Schaden.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Aufruf-Formen im gebootstrappten Ziel nennen den Träger ohne
  Zielordner** — die emittierten Anleitungen und Commands tragen die
  CWD-Annahme; nach dem Feature driftet ihre Zusage gegen die neue
  Dispatch-Form. Ausgang: weiter offen → Sichtung bei der Closure;
  eingetreten → Folge-Slice, der die Aufruf-Formen der Emission nachzieht.
  — **Ausgang:** *entfallen* — die Bedingung besteht nicht: die Emission
  ruft den Träger in der Init-Form 0×
  (`grep -rn 'ai-harness-init' internal/emit/templates/agents/
  internal/emit/templates/commands/` → leer); die Fragmente rufen ihn nur
  als Unterkommando (`SPAN_CARRIER`/`ARCHIV_CARRIER`/`TRAEGER_CARRIER`,
  `grep -rn 'TRAEGER_CARRIER' internal/emit/templates/ | grep -v '?='` →
  nur Fetch-/Ablage-Mechanik), und die Zielordner-Form betrifft allein den
  Init-Dispatch.
- **Das Handbuch nennt den Aufruf ohne Zielordner** — der pausierte
  Handbuch-Nachzug trägt die Adresse; die neue Aufruf-Form verschiebt die
  Berührungs-Stellen. Ausgang: weiter offen → der Nachzug-Slice nennt die
  neue Form an derselben Adresse.
  — **Ausgang:** *entfallen* — das Handbuch trägt die neue Form an 11
  Stellen (je `<zielordner>` am Ende, Flags davor, die gebrochene Form 0× —
  Nachzug-Prüfung der Review-Runde 2); die Adressen-Frage des pausierten
  Nachzugs trägt
  [`slice-releasing-doku-traegt-den-release-vorgang`](../in-progress/slice-releasing-doku-traegt-den-release-vorgang.md)
  in seinem eigenen §6.
- **Rest-Vektoren am Dispatch bleiben ungemessen** — der laut-Bruch deckt
  unbekannte Unterkommandos, die Usage-Deckung das fehlende Argument;
  falsch-positionierte Argumente und unbekannte Flags sind die nächsten
  Kandidaten derselben Klasse. Ausgang: weiter offen → Sichtung bei der
  Closure; erreicht die Klasse die Schwelle, weist §7.
  — **Ausgang:** *weiter offen* → Register —
  `BEO-ALL/rest-vektoren-am-dispatch-bleiben-ungemessen` (neu angelegt,
  Beleg `evidence/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md`);
  der Rest-Vektor ist nicht gemessen (Verifikations-Report, §Spec-Lücken:
  die Sperren decken Leer- und Mehrfach-Fall und das fehlende `.git`, nicht
  falsch positionierte Argumente und unbekannte Flags).
- **Die tragenden Festlegungen sind Proposed** — kippt
  [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  oder [`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
  in seinen Festlegungen 2/3, driftet der Dispatch-Entwurf gegen seinen Grund.
  Ausgang: weiter offen bis zum Accept; der Accept fällt mit der Closure des
  jeweiligen Slices.
  — **Ausgang:** *entfallen* — die Bedingung besteht nicht mehr: beide ADRs
  tragen `Accepted` (`grep -nE '^## Status|^\*\*Status'
  docs/plan/adr/0058-*.md docs/plan/adr/0059-*.md` → je `**Status:** Accepted`);
  der Accept fiel mit der Closure der jeweiligen Slices.

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

- **Was hat funktioniert:** Der Schnitt schließt zwei Zustände mit einem
  Griff: Der Dispatch nimmt den Zielordner entgegen (`fs.Parse` stoppt am
  ersten Positionsargument, drei Sperren vor `bootstrap()`), der
  argumentlose Aufruf endet laut mit dem Usage-Text (fail-closed) — der
  Unfall-Vektor ist am realen Träger gemessen (Verifikations-Report,
  Messung 1: Exit 2, stdout leer, das stehende Repo unverändert), und die
  roten Gegenproben sind rot gesehen (377 eigene Messung; 378 in der
  Gate-Umgebung der Runde 2). Die Deckungs-Teilung (Verhalten in der
  Go-Stufe, Struktur-Deckung im bats-Lauf) steht ausgeschrieben im Kopf von
  `test/zielordner.bats` — dieselbe Verortung trägt der Plan seit
  `a247fc89` (LP2, §3) und mit dieser Closure LP1 nach.
- **Was ging anders als geplant:** Der bats-File führt keinen Happy- und
  keinen Negative-Verhaltensfall — die Verortung im Plan-Text war halb
  überholt (Runde 1 F-4 zog LP2 und §3, LP1 blieb; V-2, hier gezogen). Der
  Diff berührt 11 Dateien gegen 3 in der §3-Tabelle — mechanische Folge der
  neuen Aufruf-Form, von Runde 1 F-8 und Runde 2 als keine Grenzverletzung
  eingestuft. Der 378-Zahn bindet nur in einer Umgebung mit Netz (V-1 —
  die Grenze trägt der gelistete Zahn selbst, `# verify: test-go`; in einer
  netzlosen test-Go-Umgebung schweigt der Verzeichnis-Zahn, während 377
  netzlos bindet). Commit `0acdf385` trägt die Rolle als „Rolle
  Implementation" statt „Rolle Implementer" (V-3) — Zeitdokument. Die Spec
  trug die alte Aufruf-Form — der CR `0.22.0` (Commit `4ce1aa9a`) zog
  Lastenheft und Architektur-Ablauf auf die tragende Form; der Anlass steht
  hier (Setzung des Auftraggebers vom 2026-09-19: die fehlende
  Zielordner-Form ist Rauschen am Werkzeug und wird zur Fähigkeit), die
  Historie des Lastenhefts trägt die Setzung
  ([`MR-042`](../../../../harness/conventions/MR-042-der-anlass-einer-lastenheft-aenderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz.md),
  [`MR-015`](../../../../harness/conventions/MR-015-change-request-bei-personalunion-von-auftraggeber-und-entwickler.md)).
  F-9 (LOW, Runde 2) bleibt mit Träger offen — Register unten.
- **Steering-Loop-Eintrag:** benannte Spec-Lücke — die Argument-Semantik
  des Init-Dispatch über die drei Sperren hinaus (ein einzelnes
  Positionsargument, das zufällig ein bestehendes Git-Repo benennt, wird als
  Zielordner gelesen; falsch positionierte Argumente und unbekannte Flags
  tragen keine Sperre) ist in keinem Spec-Stratum festgelegt — der
  Code-Kommentar dokumentiert die Abgrenzung, kein Test misst sie (gemessen:
  die Spec trägt die Usage-Form und die laut-Zusage des CR `0.22.0`, nicht
  die Rest-Vektoren). Ihre Adresse ist das Beobachtungs-Register
  (`BEO-ALL/rest-vektoren-am-dispatch-bleiben-ungemessen`, unten); eine
  Kennung im Vertrags-Stratum würde sie ein CR des Auftraggebers füllen —
  hier nicht vollzogen.
- **Beobachtungs-Register (`../observations/`):** drei Verzeichnisse neu
  angelegt, Beleg je
  `evidence/slice-zielordner-richtet-das-werkzeug-auf-ein-ziel-repo.md` —
  `BEO-ALL/rest-vektoren-am-dispatch-bleiben-ungemessen/` (Risiko-Ausgang
  §6, Risiko 3) · `BEO-ALL/dod-testzeile-verortet-verhalten-in-der-falschen-stufe/`
  (Finding-Klasse F-4/V-2, zwei Funde im selben Vorgang — ein Beleg) ·
  `BEO-ALL/redundanter-nachlauf-zustand-nach-vorverlagerung/` (F-9, Runde 2).
  Lese-Schritt:
  [`BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad`](../observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/observation.md)
  bleibt **offen** — der Zähler folgt aus den Dateien und ist unverändert
  (`ls docs/plan/planning/observations/BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad/evidence/ | wc -l`
  → 1), kein neuer Beleg: der Defekt trat in diesem Vorgang nicht wieder
  auf, er wurde behoben. *Verkörpert* scheidet aus: die Klasse bleibt über
  die Alt-Stände erreichbar — `v0.2.0`/`v0.1.1` und der aktuell gepinnte
  `v0.2.1` tragen die Fähigkeit nicht (kein Re-Publish, §1-Ausschluss), der
  laut-Bruch
  ([`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  Festlegung 2) deckt dort nur das unbekannte Unterkommando — und
  `cmd/ai-harness-init/main.go` trägt keinen Anker `seit slice-<Kennung>`;
  einen zu setzen wäre Produkt-Code. Kein Eintrag erreicht mit diesem
  Vorgang neu die 3×-Schwelle.
- **Folge-Slices:** keine — der Ausgang jedes offenen Punkts ist das
  Beobachtungs-Register (drei neue Einträge oben); die Verkörperung der
  F-4/V-2-Klasse als Plan-Form-Regel wäre Architektur-Arbeit
  ([`AGENTS.md`](../../../../AGENTS.md) §3.8) und wird erst ab 3× fällig
  (Lese-Schritt).
- **Risiken aus §6:** Risiko 1 *entfallen* (die Emission ruft den Träger in
  der Init-Form 0× — gemessen, siehe §6) · Risiko 2 *entfallen* (das
  Handbuch trägt die neue Form an 11 Stellen, gebrochene Form 0× —
  Nachzug-Prüfung der Runde 2) · Risiko 3 *weiter offen* → Register
  (`BEO-ALL/rest-vektoren-am-dispatch-bleiben-ungemessen`) · Risiko 4
  *entfallen* (beide ADRs tragen `Accepted`, gemessen) — siehe §6.
- **Drei Paarungen:** Anker — kein Eintrag in §7 trägt das Feld `liegt in`;
  die benannte Spec-Lücke trägt kein Zielort-Feld, die Paarung hat kein
  Objekt. · Folge-Slice — kein Folge-Slice genannt, die Paarung hat kein
  Objekt. · Register — die in §6 und §7 genannten Einträge existieren als
  Verzeichnisse, jedes trägt mindestens einen Beleg; geprüft im
  Paarungs-Lauf der Closure nach dem `git mv`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — der
Dispatch (`cmd/ai-harness-init/main.go`), der bats-Test und die Aufruf-Form
als öffentliche Oberfläche. Die Sub-Area erfüllt die Schwelle ≥ 2 von 3
Achsen (Inventur-Berührung: ja; mehrere Dateien: ja; Aussagen-Berührung: ja —
die Usage-Zusage und die vier-Fälle-Deckung). Sie ist nicht zu grob — die
Modus-Deklaration in `harness/conventions.md` führt `*` namentlich.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-19 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**146**), Verzeichnisse unter `BEO-ALL/`. Treffer für die Sub-Area:
`BEO-ALL/ohne-argument-startet-das-werkzeug-den-init-pfad` — **Zählerstand
1×**, Stand *offen*; ihr Beleg trägt den Unfall (fehlendes Argument → stiller
Init-Pfad, kein Default-Zweig, `v0.2.0`-Schaden). Dieser Slice gibt dem Muster
seinen Träger: derselbe Defekt, geschlossen durch die Fähigkeit — der Zähler
des Eintrags wird durch diesen Plan nicht hochgeschrieben; sein Beleg kommt
aus dem Unfall-Vorgang, der bereits eingetragen ist. Kein weiterer Eintrag
berührt die Sub-Area mit dieser Berührung; keiner erreicht 2×.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` steht in der
Modus-Deklaration als Greenfield); kein BF/Hybrid-Block.