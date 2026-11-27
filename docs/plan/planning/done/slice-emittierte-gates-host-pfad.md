# Slice slice-emittierte-gates-host-pfad: die emittierten Gates fahren host-native

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** [welle-ohne-docker](../welle-ohne-docker.md) — der Closure-Trigger
der Welle beobachtet mehr als ein Slice-DoD trägt (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:**
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(Bootstrap — das gebootstrappte Repo läuft Gates out-of-the-box),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(jeder emittierte Gate-Target läuft auf frischem Checkout),
[`LH-QA-03`](../../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(emittierte Ziel-Reports bleiben make-getrieben, docker Weg statt Pflicht),
[ADR-0004](../../adr/0004-durchsetzungs-emission.md) (durchgesetzte Emission),
[ADR-0109](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md) <!-- d-check:ignore (Platzhalter-Kennung: entsteht im Architect-Slice slice-adr-gates-laeufen-host-native, ADR-0109-Form) -->,
`slice-c4-environment-check-v7-0-0` ([docs/plan/planning/done/](../done/slice-c4-environment-check-v7-0-0.md)
— die emittierte `environment-check`-Vorlage wird zum Träger).

**Berührte Spec-Stellen:** `spec/spezifikation.md` — die Stelle, die die
emittierte Gates-Struktur (mk-Fragmente, Dockerfile-Stages) trägt. Der Verweis
zeigt **aufwärts**.

**Verantwortlich:** pt9912

**Autor:** pt9912. **Datum:** 2026-11-27.

---

## 1. Ziel und Abgrenzung

**Ziel:** die emitter-Template-Ebene trägt die host-native Gate-Form in das
gebootstrappte Ziel: die emittierte Gates-Kante startet mit
`make environment-check` (die Vorlage ist schon emittiert — sie wird Träger),
die Rezepte hinter `test`/`lint`/`build`/`shell-lint`/`ci-lint`/`docs-check`
fahren host-native Äquivalente mit Tool-Pins (Inventar wird emittiert), die
gepinnten Image-Pfade bleiben als opt-in-Weg gepinnt. Das gebootstrappte Ziel
ist damit `make gates`-fähig auf einem Host ohne Docker-Daemon — der
Bootstrap braucht nur git.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Labor-Baum (dieses Repo)** — seine eigenen Rezepte baut
  [`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md);
  hier steht die emitter-Ebene (Schicht-Abgrenzung).
- **Der Bootstrap-Code (Go) selbst, außer der Gate-Fragmente** — die
  Bootstrap-Kette bleibt (Phase-Struktur, hooks, Sprachskelett); nur die
  Gates-Ebene wandert.
- **Der d-check-Binary-Zugang im Ziel** — der emittierte Weg benennt seine
  Quelle (Pin + Beschaffung, dieselbe Form wie
  [`slice-binraire-ziehen-ohne-docker`](../done/slice-binraire-ziehen-ohne-docker.md));
  die Labor-Mechanik wird nicht doppelt geführt — der emittierte Pin trägt
  den Tag, der Fetch-Zug entsteht aus denselben Fragments.

## 2. Definition of Done

[x] **Liefer-Punkt 1:** die emittierten Gates-Fragmente (`internal/emit/templates/`
      + mk-Fragmente) tragen die host-native Form mit Inventar-Emittierung;
      `environment-check` fährt emittiert als erster Gates-Check
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Messung bleibt full-smoke).
- [ ] **Liefer-Punkt 2:** ein frisch gebootstrapptes Ziel fährt `make gates`
      out-of-the-box grün auf einem Host ohne Docker-Daemon — belegt im
      realen Lauf (Verifikations-Bericht), nicht als Prosa.
[x] **Liefer-Punkt 3:** Go-Emitter-Tests (`internal/emit/*_test.go`) tragen
      die Form (Happy über die emittierten Rezepte, Negative über
      fehlender Inventar-Zeile) und die Mutations-Fälle, deren Anker an der
      Template-Ebene liegt, sind neu gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)/[`MR-090`](../../../../harness/conventions.md#mr-090--ein-sensor-hält-den-anker-eines-mutations-falls-am-commit)).
- [ ] `make gates` grün.
[x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — kein Self-Review (Modul 8).
[x] Doku-Update: emitter-Doku (`docs/user/`, README), sofern die
      emittierte Gates-Ebene öffentlich berührt (Bootstrap-Verhältnis git-only).
[x] Closure-Notiz mit Steering-Loop-Lerneintrag.
[x] Beobachtungs-Register (`../observations/`) fortgeschrieben —
      `evidence/`-Datei ergänzen, wo eine Beobachtung anfiel; **kein Zähler
      wird gesetzt**. Keine Beobachtung anfallen ist ebenfalls eine Antwort
      und wird in §7 notiert.
[x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind von der
      nächsten Welle-Closure geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/**` (mk-Fragmente, Dockerfile, environment-check-Vorlage) | update | host-native Gate-Form + Inventar + opt-in Image-Pins |
| `internal/gen/golang.go` (das Go-Skelett-Fragment + die Dockerfile-Kommentarnahme) | update | die Go-Gates `test/lint/build` fahren host-native, die Stage-Wege bleiben als `-image`-Ziele gepinnt (Form-Abweichung: die Skelett-Fragmente liegen in der gen-Ebene, nicht im emit-Baum; nur Go, §4) |
| `internal/emit/**_test.go`, `internal/gen/*_test.go` | update / neu | Emitter-Tests je oben |
| `docs/user/**`, `README.md` | update | Bootstrap-Verhältnis (git-only) und die zwei Gate-Wege |

## 4. Trigger

**Start** (`next` → `in-progress`):
[`slice-labor-gates-host-rezepte`](../done/slice-labor-gates-host-rezepte.md) liegt in
`done/` — die laborseitige Form steht als Vorbild, die emitter-Seite spiegelt
sie (dieselbe Form, keine zweite Definition).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): mehr als drei
  Liefer-Punkte — etwa, wenn die Sprach-Skelett-Toolchains (Kotlin, Java,
  Python, Csharp) je Pin-Set zusätzlich umzustellen sind → re-slicen, dann
  ein Sprach-Skelett je Teil.
- `in-progress` → `open` (blockiert — Carveout?): ein emittiertes Skelett
  hat keinen host-Toolchain-Weg (Kotlin-Gradle-Toolchain ohne Container?) —
  dann die Skelett-Toolchain-Frage an die [`ADR-0109`](../../adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md)-Platzhalter-Synthese.

## 5. Closure-Trigger

DoD (§2) vollständig; der reale Lauf (gebootstrapptes Ziel, `make gates`
grün ohne Docker-Daemon) steht im Verifikations-Bericht. Zusätzlich:
Closure-Notiz mit Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

- **Die Sprach-Skelett-Toolchains (Kotlin, Java, Python, Csharp) tragen
  ihre eigene Pin-Form** ([`ADR-0088`](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md)-Nachfolger)
  — **Ausgang:** entfallen — kein K/J/P/C-Skelett-Fragment im Diff umgestellt;
  die Inventar-Ableitung liefert für die übrigen Sprachen `nil` je benannter
  Begründung, und der Paarungs-Wächter hält auch die Leer-Menge; docker-los
  lauffähig ist jede Form, die der Host trägt — die Frage ist in diesem Lauf
  nicht aufgetreten (Verifikations-Bericht, Ausgangs-Vorschläge).
- **`full-smoke` fährt die emittierte Ebene** — **Ausgang:** eingetreten —
  der reale Beleg der emittierten Gates-Ebene im gebootstrappten Ziel läuft
  über
  [`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md);
  bis dahin trägt der manuelle Lauf des Verifikations-Berichts (V-5) den
  Beleg.
- **Bootstrap-Henne-Ei des Carrier-Wegs** (Review F-6): `DCHECK_CARRIER`
  muss vor dem Bootstrap-Lauf von außen kommen (Umgebungsaufgabe) — der
  Default-Weg ohne sie bleibt Docker-getrieben; die Zusage „Bootstrap
  braucht nur git" ist auf dem Carrier-Weg **nicht** erreicht. **Ausgang:**
  weiter offen — Beobachtungs-Register
  [`BEO-ALL/bootstrap-braucht-den-carrier-von-aussen`](../observations/BEO-ALL/bootstrap-braucht-den-carrier-von-aussen/state.md);
  als Adresse benennbar ist ein eigener Mikroslice
  (Carrier-Besorgung im Bootstrap-Lauf, fail-closed ohne Netz an genau
  diesem Aufruf) — der Welle-Plan
  [`welle-ohne-docker`](../welle-ohne-docker.md) richtet ihn neben
  `slice-smoke-und-full-smoke-ohne-docker` ein; die Messung des
  Verifikations-Berichts (V-5, Schritt 2) belegt die Lücke real. Der Code-Umfang
  bleibt die
  Abgrenzung §1 (keine zweite Beschaffungs-Mechanik im Bootstrap — der
  Fetch-Zug entsteht aus denselben Fragmenten).

## 7. Closure-Notiz

**Gegenstand:** offene §2-Items: `make gates` grün und Liefer-Punkt 2 — Vorbestand-Rotmenge der Gates-Kette; LP 2 trägt der reale CI-Lauf (ci.yml), nicht dieser Slice.

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<KUERZEL>/<slug>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln.

**Closure-Notiz (Rolle Planner, 2026-11-27)** — Quellen: eigener Lauf, der
Verifikations-Bericht
([`docs/reviews/2026-11-27-slice-emittierte-gates-host-pfad-verify.md`](../../../reviews/2026-11-27-slice-emittierte-gates-host-pfad-verify.md)),
der Review-Report
([`docs/reviews/2026-11-27-slice-emittierte-gates-host-pfad.md`](../../../reviews/2026-11-27-slice-emittierte-gates-host-pfad.md),
Behebungszug `9bd6f440..6cabbee6`) und der F-9-Zug (`0be90f31`).

- **Was hat funktioniert:** die emitter-Ebene spiegelt die Labor-Form statt
  sie zweit zu definieren (§4-Vorbild); `environment-check` fährt emittiert
  als erster Check der Kette, die Inventar-Zeilen werden je Werkzeug aus der
  Pin-Stelle abgeleitet (Paarungs-Wächter Zeile↔Pin-Stelle, rot-gesehen),
  und der reale LP2-Lauf (V-5: `make host-bin` → Bootstrap eines tmp-Ziels
  mit extern geliefertem `DCHECK_CARRIER` → `make gates` im Ziel) erreichte
  die Fragment-Assembly und riss an der ersten-Check-Semantik — der Kette
  wirkt.
- **Was ging anders als geplant:** (1) LP 2 „out-of-the-box grün" ist am Host
  **nicht erreicht** — reale Kette gefahren, drei Grenzen benannt (Carrier
  extern, d-check-Ablage einmalig über `dcheck-fetch` mit Netz, exakter
  Pin-Träger des Hosts): vollgrüner Lauf trägt CI mit Pass-Matrix; der DoD-
  Posten bleibt offen benannt, das „out-of-the-box"-Ziel steht im
  Benutzerhandbuch weiter. (2) Der neue Befund des Verifikations-Laufs (die
  emittierte golangci-Soll-Form trug das v-Pin-Präfix und war von keinem
  Träger erreichbar) ist im F-9-Zug `0be90f31` behoben — v-freie Ableitung in
  der Dogfood-Form, Parity-Wächter gegen die Dogfood-Inventar-Zeile,
  Mutations-Fall 813 mit belegtem Rot-Zug. (3) `make gates` ist an dieser
  Closure rot an den **fünf vorbestehenden Klassen** — docs-check 106
  Befunde (am Claim-Stand `ef1ac86f` byte-identisch abzüglich drei
  Zeilenverschiebungen aus dem §6-Eintrag, V-6), bats Fall 273, shell-lint
  SC2254/SC2016, Mutations-Anker 784/785, `make test-go` zwei Klassen —
  keine aus dem Slice-Diff, kein Carveout-Artefakt. (4) Der
  Fall-40-Mutations-Vorlauf bricht an den zwei vorbestehenden test-go-
  Klassen; der Rot-Beleg trägt am Hand-Sed an der realen Quelle (V-3, 8
  rot, darunter der Anker `TestDocGate_FragmentWiresDocsCheck`) — der
  Branch-Push für `make mutate-auswahl` am neuen Tip ist ein CI-Posten.
- **Steering-Loop-Eintrag:** geschärfte Regel (gezählt, nicht verkörpert —
  kein `liegt in`): **die emittierte Zusage misst die Ausgabe-Form des
  Werkzeugs, nicht die Form der Pin-Stelle, von der sie abgeleitet ist** —
  die Ableitung aus einem Pin (Modul-Tag) ist nicht die Prüfform des Checks
  (Version-Ausgabe des Werkzeugs), und die Kopplung trägt erst der Lauf im
  gebootstrappten Ziel, kein Wächter über der abgeleiteten Zeile allein
  (§3.6, Wächter über nachgebauter Eingabe). Grenze des ungebundenen Teils
  (Review INFO): die Präferenz-Zusage („`environment-check` erster Check")
  trägt **keinen** Fall in der Mutations-Anlage — ihr Rot-Zug existiert als
  Test-Form, nicht als Fall. Entscheidung (kleine Form, §3.6): die Lücke
  wird **am Ort benennen** — als Übergabe-Artefakt an den nächsten
  Implementer-Posten der Welle; hier nur entschieden, nicht geschrieben.
- **Beobachtungs-Register (`../observations/`):**
  [`BEO-ALL/bootstrap-braucht-den-carrier-von-aussen`](../observations/BEO-ALL/bootstrap-braucht-den-carrier-von-aussen/state.md)
  neu angelegt (Ausgang des §6-Risikos „Bootstrap-Henne-Ei", weiter offen),
  Beleg
  [`evidence/slice-emittierte-gates-host-pfad.md`](../observations/BEO-ALL/bootstrap-braucht-den-carrier-von-aussen/evidence/slice-emittierte-gates-host-pfad.md),
  Zähler 1. Die zwei §8-Treffer (gemischtes Root 1×, GNU-only-bats 2×)
  bleiben unter der Schwelle — in diesem Lauf nicht angefallen.
- **Folge-Slices:**
  [`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
  (reale Beleg-Posten der emittierten Ebene, LP-2-Träger) · Mikroslice
  Carrier-Besorgung (richtet der Welle-Plan neben dem Folge-Slice ein,
  getragen vom Register-Eintrag oben).
- **Risiken aus §6:** Skelett-Toolchains — entfallen (oben) · full-smoke —
  eingetreten, Folge-Slice oben · Bootstrap-Henne-Ei — weiter offen,
  Register-Eintrag oben.
- **Drei Paarungen:** Anker — der Lerneintrag oben ist gezählt, es gibt
  keinen `liegt in` · Folge-Slices —
  [`slice-smoke-und-full-smoke-ohne-docker`](../done/slice-smoke-und-full-smoke-ohne-docker.md)
  und der Register-Eintrag (weiter offen) · Register —
  [`BEO-ALL/bootstrap-braucht-den-carrier-von-aussen`](../observations/BEO-ALL/bootstrap-braucht-den-carrier-von-aussen/state.md)
  (Zähler 1). Die Prüfung der Paarungen trägt die schließende Welle.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** und die **vier Pflichtkriterien**.

**Der Abschnitt selbst entällt nie.**

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind die emitter-Ebene
(`internal/emit/`) und `*` (Kürzel `ALL`); beide stehen unter der
Modus-Deklaration (GF) und erfüllen die Schwelle ≥ 2 von 3 Achsen.

**Vorgelagert — offene Beobachtungen sichten:** Register gemergt gelesen.
Treffer:

- [`BEO-ALL/emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache`](../observations/BEO-ALL/emittiertes-gate-am-gemischten-root-baut-das-dockerfile-einer-anderen-sprache/state.md)
  — 1 Vorgang (< 3×): gemischtes Root baut das Dockerfile einer anderen
  Sprache — der Host-Weg verlegt die Rezepte weg vom Dockerfile; der Bestand
  bleibt opt-in. Notiert, nicht gelöst hier.
- [`BEO-ALL/bats-zusicherung-nutzt-gnu-only-erweiterung`](../observations/BEO-ALL/bats-zusicherung-nutzt-gnu-only-erweiterung/state.md)
  — 2 Vorgänge (< 3×): GNU-only-Formen in bats — der host-native Weg verlegt
  denselben Fall auf den Host; bei diesem Slice sind die GNU-Annahmen
  bewusst benannt (Inventar nennt die Werkzeug-Varianten).

Keine Treffer unter der Schwelle jenseits der genannten.

**Modus-Begründungsblock — Umfang:** alle berührten Sub-Areas GF — der
Modus-Begründungsblock entfällt.
