# Slice slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor: Doppelt geführte Werte bekommen ihren Kopplungs-Sensor

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese Datei liegt; er wechselt
nur durch `git mv` (Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine).

**Welle:** ohne Welle — reaktiv, ein Eintrag des Beobachtungs-Registers über der Schwelle; keine
Closure-Bedingung jenseits der DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`ADR-0049`](../../adr/0049-ausgang-traegt-die-benannte-luecke.md), [`ADR-0085`](../../adr/0085-slice-closure-mit-schwellen-uebertritt-ist-lese-schritt.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-08.

---

## 1. Ziel und Abgrenzung

**Ziel:** Jeder Wert, den das Repo an zwei Stellen führt, ist an einen Sensor gekoppelt, der die
zweite Stelle gegen die erste hält — ein Pin-Zug oder eine Fassungs-Änderung, die eine Stelle
vergisst, wird rot statt still grün.

**Ausdrücklich NICHT in diesem Slice:**

- Der Mutations-Fall für die vorhandene Pin-Kopplung — `slice-pin-kopplung-und-sync-tragen-ihre-mutations-faelle`
  trägt ihn; dort ist der Wächter vorhanden, hier fehlt er.
- Ein Pin-Zug selbst — anderer Vorgang; der Sensor misst die Kopplung, er bewegt keinen Wert.
- Paare über die drei unten genannten hinaus — Bestand bleibt bis zum nächsten Register-Beleg
  stehen; die Menge wächst nicht ohne Befund.

**Register-Ausgang, den dieser Slice zusätzlich trägt:**
[`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/state.md)
steht *geplant* auf diesem Slice. Eine Fixture, die einen realen Wert nachbaut, ist ein doppelt
geführter Wert; DoD (a) bricht dafür den **realen** Pin-Wert. Die Abgrenzung oben gilt weiter: neue
Paare kommen mit dem nächsten Register-Beleg, nicht mit diesem Ausgang.

## 2. Definition of Done

- [x] **(a) Fallbacks:** die wert-hardcodenden Fallbacks in `harness/tools/smoke.sh` und
      `harness/tools/full-smoke.sh` sind netzlos in `make gates` an den Pin gekoppelt; ein
      verfälschter **realer** Pin-Wert ist rot gesehen. **Bestätigt:** der Verifier fuhr beide
      Fallbacks auf 1.27.1 (`not ok` 4 und 5) und den Makefile-Pin auf 1.27.3 (beide rot).
- [x] **(b) Digest:** der `@sha256`-Digest jedes **tag-tragenden** Image-Pins (Liste im Kopf von
      `harness/tools/digest-freshness.sh`) wird nächtlich mit Netz gegen seinen Tag gehalten (wie
      `regelwerk-check`, nicht in `make gates`); ein verfälschter Digest ist rot gesehen.
      **Bestätigt mit Grenze, Wortlaut vom Planner angepasst (§7):** gegen die Registry gefahren
      sind `d-check`, `d-check (emit)` und `a-check (emit)`; `golang` und `golangci-lint` liefen in
      der Verifikation in ein anonymes Hub-429 (`FETCH-FEHLER`, kein Urteil), ihre Positivrichtung
      gegen die Registry ist **unbelegt**; die Exit-Abbildung der Hauptschleife ist über einen
      `docker`-Stub gegen die realen Pin-Dateien gebunden. Pins ohne Tag neben dem Digest sind
      nicht erfasst.
- [ ] **(c) Zwei Fassungen:** **ausgeschnitten, nicht geliefert** — der Rückführ-Trigger aus §4 ist
      eingetreten; geführt in `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`
      (§7).
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben, siehe §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `harness/tools/smoke.sh`, `harness/tools/full-smoke.sh` | update | Fallback liest den Pin oder wird gegen ihn geprüft (a) |
| `.github/workflows/upstream-drift.yml` + `make`-Ziel | update / neu | nächtliche Digest-Prüfung (b) |
| `test/*.bats` | neu | Fassungs-Vergleich der drei Paare (c), Pin-Kopplung (a) |
| `harness/README.md` §Sensors/§Werkzeuge | update | neue Ziele mit Bindung |

## 4. Trigger

**Start** (`next` → `in-progress`) — erfüllt: priorisiert, `Verantwortlich:` gesetzt; WIP-Limit 1 frei (`ls docs/plan/planning/in-progress/slice-*.md` nennt keinen); (b) ergänzt einen Schritt im Muster der vorhandenen `freshness-*`-Schritte von `upstream-drift.yml` (`grep -n freshness .github/workflows/upstream-drift.yml`), keine neue CI-Regime-Frage; Schichten: Werkzeug und Tests (a, c), CI-Workflow mit Makefile (b).

- `in-progress` → `next`: eines der drei Paare braucht mehr als eine benannte Abweichung — dann ist
  (c) ein eigener Slice.
- `in-progress` → `open`: (b) verlangt eine Workflow-Änderung, die eine Entscheidung des Architect
  zum CI-Regime braucht.

## 5. Closure-Trigger

DoD vollständig, `make gates` grün, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die erlaubten Abweichungen in (c) wachsen zu einer Ausnahmeliste, die den Vergleich aushöhlt —
  **Ausgang:** eingetreten → `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`
  (die Abweichungsmenge je Paar überstieg die eine benannte; das Risiko steht dort in §6).
- (b) hängt am Netz und an der Registry; ein Ausfall darf keinen Push blockieren — **Ausgang:** weiter
  offen → `BEO-ALL/anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse`. Ein Push bleibt
  unberührt (die Achse läuft nur in `upstream-drift.yml`, nicht in `make gates`); offen ist, dass ein
  Registry-Ausfall den Nacht-Lauf ohne Digest-Defekt rot färbt.

## 7. Closure-Notiz

Geschrieben vom Planner in eigenem Kontext bei der Closure ([`AGENTS.md`](../../../../AGENTS.md)
§3.10).
**Rolle:** Planner · **Datum:** 2026-10-17

- **Was hat funktioniert:** (a) und (b) sind geliefert. (a): `test/pin-fallbacks.bats` koppelt die
  Fallbacks in `smoke.sh` und `full-smoke.sh` netzlos an den Makefile-Pin. (b): `make freshness-digest`
  (`harness/tools/digest-freshness.sh`) hält den Digest jedes tag-tragenden Image-Pins gegen seinen Tag,
  eingehängt als Schritt in `upstream-drift.yml`, nicht in `make gates`. Review (`76202836`): 0 HIGH,
  1 MEDIUM, 4 INFO; das MEDIUM (F-1: die Exit-Abbildung der Hauptschleife war ungebunden) ist in den
  Implementer-Commits `084443f9` und `b3bb759c` behoben (bats-Fälle 7 bis 10 über einen `docker`-Stub
  gegen die realen Pin-Dateien, Mutations-Fälle 672 und 673). **Gemessen** (Verifikation, HEAD
  `b3bb759c`): Rot selbst gefahren — Fallback in `smoke.sh` und `full-smoke.sh` auf 1.27.1: `not ok` 4
  und 5; Makefile-Pin auf 1.27.3: beide rot; Hauptschleife: `1) befund=1` zu `1) :` färbt Fall 8 und 10,
  `exit "$fehler"` zu `exit 0` färbt Fall 9, `2) fehler=2` zu `2) :` färbt Fall 9; `make mutate-greift`
  659 von 659; `make gates` Exit 0, Stempel == HEAD. Gegen die Registry gefahren: `d-check` und
  `a-check (emit)` mit verfälschtem Digest `DIGEST WEICHT AB` (Exit 1), entfernter Digest „nicht lesbar
  — kein Urteil“ (Exit 2).
- **Was ging anders als geplant:** **(1) (c) ist ausgeschnitten, nicht geliefert.** Der Rückführ-Trigger
  aus §4 („braucht ein Paar mehr als eine benannte Abweichung“) ist eingetreten: Implementer, Reviewer
  und Verifier maßen die Paare unabhängig per `diff` ohne Kommentarzeilen — `history-range-guard` zwei
  Abweichungen (Test-Einstiege, Meldungstext), `stop-require-gates` eine, `record-gates` zwei,
  `close-welle` durchgehend (Vorlage mit ANPASSEN-Platzhaltern, ein bereinigter Vergleich ist dort nicht
  definiert). Der Planner hat die Abnahme in der Closure neu geschnitten: (c) steht in §2 offen, mit
  Verweis auf `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor` (drei
  Liefer-Punkte, `open/`); das Häkchen ist nicht gesetzt, und die Umdeutung steht hier, nicht still.
  **(2) Der Wortlaut von (b) ist angepasst.** Er lautete „jeder Image-Pin“, geliefert ist „jeder
  tag-tragende Image-Pin“ (Review F-5, Verifikation „eingeschränkt“). Begründung für Anpassen statt
  offenes Häkchen: für einen Pin ohne Tag neben dem Digest (bats, shellcheck, actionlint im `Makefile`;
  curl in `harness/tools/tap-nachzug.sh`, `harness/tools/traeger-fetch.sh` und der Vorlagen-Kopie)
  gibt es keinen zweiten geführten Wert, gegen den der Nacht-Lauf den Digest halten könnte — „gegen
  seinen Tag halten“ ist dort nicht definiert, die Zusage war für diese Pins nie erfüllbar, nicht
  verfehlt. Die Lücke ist nicht gestrichen: sie steht als Grenze im Kopf des Skripts und in
  `BEO-ALL/pin-digest-ohne-waechter`; die Vollständigkeit kuratierter Listen trägt die Zeile
  *Vollständigkeits-Wächter für kuratierte Listen* in *Nächste Wellen* der Roadmap, die Gleichheit der
  drei curl-Kopien (gleicher Digest-Präfix in den drei Dateien gelesen) ist eine andere Kopplung ohne
  Träger. Priorisiert ist nichts. **(3) Nicht belegt und so geführt:** der Nacht-Schritt ist nie gegen
  den GitHub-Runner gelaufen; die Positivrichtung gegen die Registry für `golang` und `golangci-lint`
  (die zwei Hub-Pins) ist unbelegt, weil ein anonymes Docker-Hub-429 den Lauf der Verifikation zu
  `FETCH-FEHLER` (Exit 2) machte; der konkrete Bruch (Digest `golang` 1.27.1 an Tag 1.27.2) war nicht
  fahrbar; wie oft der Runner anonym limitiert wird, ist ungemessen. Die Index-Zeile in
  `harness/README.md` nennt „tag-tragenden Image-Pins (Liste im Skriptkopf)“; der Halbsatz „Pins ohne Tag
  sind nicht erfasst“ ist wegen der Zellgrenze des Doku-Gates (260 Zeichen) aus der Zeile gefallen und
  steht nur im Skriptkopf unter GRENZE (Verifikation: tragfähig, aber dünn). **(4) Die Hauptschleife
  war bis zum Review ungebunden:** die Zusage „Exit 0/1/2“ trug allein der einmalige Handlauf; sie ist
  jetzt über einen Stub gebunden, das Gegenstück zur Registry bleibt allein `make freshness-digest`.
- **Steering-Loop-Eintrag:** **neuer Sensor (Fallbacks):** `test/pin-fallbacks.bats` koppelt die
  wert-hardcodenden Fallbacks in `smoke.sh` und `full-smoke.sh` an den Pin im `Makefile`, netzlos in
  `make gates` — liegt in `test/pin-fallbacks.bats`. Auslöser: `BEO-ALL/pin-digest-ohne-waechter`
  (8× — `slice-pin-d-check-v0840-und-a-check-v0230`, `slice-golangci-lint-pin-folgt-dem-freshness-drift`,
  `slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140` u. a.).
- **Steering-Loop-Eintrag:** **neuer Sensor (Digest):** `make freshness-digest` hält den `@sha256`-Digest
  jedes tag-tragenden Image-Pins gegen seinen Tag, nur nachts, nicht in `make gates` — liegt in
  `harness/tools/digest-freshness.sh`. Auslöser: `BEO-ALL/pin-digest-ohne-waechter` (8×).
  **Benannte Grenzen:** Pins ohne Tag nicht erfasst; Positivrichtung gegen die Registry für `golang` und
  `golangci-lint` unbelegt; Nacht-Schritt nie gegen den Runner gelaufen.
- **Beobachtungs-Register (`../observations/`):**
  - Neu: `BEO-ALL/anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse` — 1 Beleg
    (`evidence/slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor.md`), `offen`. Kein
    bestehender Eintrag nennt in seinem Titel ein Rate-Limit, eine Registry oder einen Nacht-Sensor
    als Ursache eines grundlos roten Laufs (Titel-Suche im Register; die Einträge selbst nicht einzeln
    gelesen). Reviewer (F-2) und Verifier sahen dasselbe im selben Vorgang: ein Beleg.
  - Ausgang gesetzt: `BEO-ALL/pin-digest-ohne-waechter` von *geplant* auf **verkörpert** (Zielorte
    `test/pin-fallbacks.bats` und `harness/tools/digest-freshness.sh`, Anker `seit slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`
    in beiden Dateien). Begründung: der Gegenstand der Beobachtung — der Digest der Dockerfile-Pins und die
    Fallbacks in `smoke.sh`/`full-smoke.sh` — ist gehalten; die Pins ohne Tag liegen außerhalb ihres
    Wortlauts und stehen als Grenze im `state.md`. Der Anker steht an den Dateien, nicht an der
    Target-Zeile im `Makefile` (der Abschluss berührt kein Werkzeug, §3.10); die Anker-Paarung prüft die
    zwei `liegt in` oben. **Kein neuer Beleg:** dieser Slice liefert die Beobachtung aus, er ist kein
    weiteres Auftreten.
  - Ausgang nachgeführt: `BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` bleibt
    *geplant*, die Kennung wandert auf `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`
    (5 Belege). Kein neuer Beleg: der Neuschnitt ist kein Auftreten.
  - Ausgang gesetzt: `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` von *geplant* auf
    **verkörpert**: der Zielort `AGENTS.md` §3.6 stand schon, der Slice baut keinen Sensor, der eine
    Fixture gegen ihre reale Quelle hält (dafür hält (a) den realen Pin-Wert, den der Verifier brach);
    die Grenze „kein Sensor möglich“ steht im `state.md`. **Kein neuer Beleg (10× bleibt):** der
    `docker`-Stub der Hauptschleife ist in `digest-freshness.sh` und der bats-Datei als Stellvertreter
    benannt, die Registry-Lücke ausdrücklich genannt — die benannte Lücke ist das Gegenteil des
    verdeckten Fixture-Erfolgs.
  - **Kein Beleg:** `BEO-ALL/zusage-ohne-herstellbares-gegenbeispiel` (4×, verkörpert) — die
    Regel ist hier richtig angewandt (Zusage auf das eingeschränkt, was der Bau hält, Lücke benannt),
    kein Auftreten. Für die Hauptschleife ohne Bindung bis zum Review (Zusage nur vom Handlauf getragen)
    deckt kein Eintrag den Gegenstand deutlich genug: `BEO-ALL/zusage-mit-bats-bindung-ohne-eigenen-mutations-fall`
    meint eine bats-gebundene Zusage ohne Mutations-Fall, hier fehlte jede Bindung — ein Auftreten, vom
    Review im selben Vorgang gefunden und behoben, **benannt, nicht gezählt**.
  - `make register-ausgang`: 0 Befunde (nach dem Nachtrag, siehe Drei Paarungen).
- **Folge-Slices:** `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor` ((c)
  ausgeschnitten, drei Liefer-Punkte) — ist eine Datei in `open/`, nicht gestartet.
- **Risiken aus §6:** (c)-Abweichungsmenge: eingetreten → `slice-zwei-fassungen-eines-waechters-bekommen-ihren-vergleichenden-sensor`;
  (b)-Registry: weiter offen → `BEO-ALL/anonymes-hub-rate-limit-faerbt-den-nacht-lauf-der-digest-achse`
  (Auflösungs-Prüfung: der erste Nacht-Lauf von `upstream-drift.yml` nach dem Push zeigt, ob die Hub-Pins
  `FETCH-FEHLER` liefern; ob am Workflow authentifiziert wird, entscheidet der Auftraggeber, nicht diese
  Closure).
- **Trigger-Audit:** Carveouts: keiner berührt. Bootstrap-aware Gates: keines. ADR-Re-Evaluierungs-Trigger:
  keiner berührt. Hard Rules: keine mit eingetretenem Auflösungs-Trigger.
- **Drei Paarungen:** — nach dem `git mv`.
- **Archivierung:** entfällt ([`MR-078`](../../../../harness/conventions.md#mr-078); `archive-slice` ist nicht gebaut).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** `*` (gesamtes Repo), Kürzel `ALL` — die einzige Sub-Area,
der das Register Beobachtungen zuordnet.

**Vorgelagert — offene Beobachtungen sichten:** `BEO-ALL/pin-digest-ohne-waechter` und
`BEO-ALL/zwei-fassungen-eines-waechters-ohne-vergleichenden-sensor` über der Schwelle, Stand
`geplant` auf diesen Slice; Nachbar `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` (dort ist
Abweichung zulässig, hier nicht).

**Stand bei der Closure:** `BEO-ALL/pin-digest-ohne-waechter` 8×, `zwei-fassungen-…` 5×, `waechter-misst-die-fixture-…` 10× — keine Zähler-Änderung durch diesen Slice (siehe §7).

Alle berührten Sub-Areas GF.

