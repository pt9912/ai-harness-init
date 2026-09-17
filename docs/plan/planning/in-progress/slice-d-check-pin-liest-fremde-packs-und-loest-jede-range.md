# Slice slice-d-check-pin-liest-fremde-packs-und-loest-jede-range: Der d-check-Pin steht auf `v0.76.3`, und die Range-Aussagen sind am neuen Stand gemessen

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der Pin ist
die Reproduzierbarkeits-Zusage des Doku-Gates),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (was
die Sensor-Dateien über den Range-Lauf sagen, trägt das Gate),
[`MR-061`](../../../../harness/conventions.md#mr-061) (bei jedem d-check-Release: Pin, Fragment,
Strenge-Bilanz), [`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung je aktivem
Modul), [`MR-064`](../../../../harness/conventions.md#mr-064) und
[`MR-065`](../../../../harness/conventions.md#mr-065) (je ein Neu-Prüf-Fall, der mit diesem Sprung
eintritt), [`MR-053`](../../../../harness/conventions.md#mr-053) (Werkzeug-Aussagen tragen ihren
Messstand).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der d-check-Pin steht auf `v0.76.3` statt `v0.76.1`, in
[`d-check.mk`](../../../../d-check.mk) und in
[`internal/emit/emit.go`](../../../../internal/emit/emit.go), mit belegtem Digest und einem
Adaptions-Eintrag zum Sprung. Was dieses Repo über den Range-Lauf des Werkzeugs sagt, ist am neuen
Stand gemessen — in den Sensor-Dateien, im Kommentar am `commits`-Block und in der E2E-Stufe, die
den blind-grünen Fall behauptet.

**Herkunft:** Trigger-Audit der Closure von `slice-stilllegungs-form-hat-einen-waechter`. Die zwei
Releases lösen den permanenten Trigger von
[`MR-061`](../../../../harness/conventions.md#mr-061) aus und den Neu-Prüf-Fall von
[`MR-064`](../../../../harness/conventions.md#mr-064) und
[`MR-065`](../../../../harness/conventions.md#mr-065), *d-check liest Packs unter fremdem Präfix*.

**Werkzeug-Stand**, gelesen im `CHANGELOG.md` des Werkzeug-Klons (nur lesend; die Tags nennt
`git -C <Klon des Werkzeugs> tag -l 'v0.76*'`):

- **`v0.76.2`:** `vcs` und jedes Modul am selben git-Port lesen Packs unter einem anderen
  Namens-Präfix als `pack-`, wenn die Datei ein gültiges Hash-Suffix und eine passende `.idx`
  trägt. Ein Pack ohne beides bleibt unsichtbar, und der Abbruch bei einer wirklich unauflösbaren
  Objekt-Menge bleibt.
- **`v0.76.3`:** `vcs` und `commits` lösen eine angegebene Range immer auf, auch ohne `vcs:`- bzw.
  `commits:`-Block in der Konfiguration. Eine unauflösbare Range bricht mit Exit 2 ab.
- Beide laut CHANGELOG ohne Konfigurations-Bruch und ohne neuen Grund-Code. Das ist die Aussage
  der Werkzeug-Dokumentation; ob sie am Quellstand des gepinnten Bildes trägt, misst DoD 2.

**Mitgabe aus der Planung.** [`harness/sensors/history-range-guard.md`](../../../../harness/sensors/history-range-guard.md)
§Grenze, erster Punkt, sagt, eine *unauflösbare* Basis decke der Wächter *„nicht zusätzlich"*,
weil d-check selbst mit Exit 2 abbreche. Das stimmt zweimal nicht:

- Der Wächter fängt den Fall selbst ab: `git rev-list --count` schlägt fehl, er meldet *„ist NICHT
  aufloesbar"* und endet mit 2 (`grep -n 'NICHT aufloesbar' harness/tools/history-range-guard.sh`).
- Die Begründung galt im Ziel ohne Klassen-Block bis `v0.76.2` nicht: Dort übersprang d-check die
  Auflösung der Range.

Der Punkt wird mit diesem Sprung nachgezogen (DoD 3), ebenso der Punkt derselben Liste, nach dem
`doc-commits` im Dogfood an Packs unter anderem Präfix abbricht.

**Zählkommando** für DoD 3, ohne eingefrorene Artefakte und ohne den Adaptions-Block, dessen
Einträge ihren Stand datieren:

```sh
git grep -n 'v0\.76\.1' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!harness/conventions' ':!harness/conventions.md' ':!.harness/baseline' ':!docs/plan/adr' \
  ':!docs/plan/planning/observations' ':!docs/plan/planning/*/slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.md'
```

Keine Zahl dazu: Die Treffer wandern mit dem Baum, und gemessen wird am Start. Treffer in
[`AGENTS.md`](../../../../AGENTS.md) zieht der Architect nach (§3.8), in eigenem Commit.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Alternates (`git clone --shared`).** *Bestand bleibt bewusst stehen:* Die Lücke steht als
  gemessene Grenze in [`MR-065`](../../../../harness/conventions.md#mr-065), und der Auftraggeber
  stellt dazu keinen weiteren Änderungswunsch an das Werkzeug. DoD 2 misst sie am neuen Stand nach
  und datiert sie; geschlossen wird sie hier nicht.
- **Die Regel, welche Adresse eine gemessene Werkzeug-Lücke bekommt.** *Ein anderer Slice
  übernimmt sie:* `slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse`. Dieser Slice löst
  nur die zwei Neu-Prüf-Sätze aus [`MR-064`](../../../../harness/conventions.md#mr-064) und
  [`MR-065`](../../../../harness/conventions.md#mr-065) für das Pack-Präfix ein; eine Regel für die
  Klasse setzt er nicht. Keiner der zwei Slices wartet auf den anderen.
- **Kein Modul wird aktiviert, keine Regel der `.d-check.yml` geändert.** *Anderer Vorgang:* Der
  Sprung bringt laut CHANGELOG keinen neuen Grund-Code. Eine Aktivierung wäre ein Steering-Loop nach
  [`MR-001`](../../../../harness/conventions.md#mr-001).
- **Die emittierte Startkonfiguration bekommt keinen `vcs:`- oder `commits:`-Block.**
  *Schicht-Abgrenzung:* Was ins emittierte Gate geht, entscheidet
  [`MR-054`](../../../../harness/conventions.md#mr-054). Hier wandert nur der emittierte
  Default-Pin, und DoD 2 misst, was das Werkzeug im Ziel jetzt selbst abbricht.
- **Der Objektspeicher des Arbeitsklons bleibt, wie er ist.** *Anderer Vorgang:* Die Messung am
  `loose-*.pack` läuft an einer Wegwerf-Kopie.

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

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **1 — Der Pin steht auf `v0.76.3`, an beiden gekoppelten Stellen und mit belegtem Digest;
      das Fragment ist re-adaptiert, und der Sprung hat seinen Adaptions-Eintrag.**
      - `DCHECK_IMAGE` und `DCHECK_DIGEST` in [`d-check.mk`](../../../../d-check.mk) sowie
        `DefaultImage` und `DefaultDigest` in
        [`internal/emit/emit.go`](../../../../internal/emit/emit.go) tragen denselben Tag und
        denselben Digest. Der Digest ist aus der Registry und aus dem lokalen Bild belegt, mit
        Kommando im Umsetzungs-Commit.
      - Die Handgriffe aus [`MR-010`](../../../../harness/conventions.md#mr-010) Setzung 1 und
        [`MR-062`](../../../../harness/conventions.md#mr-062) laufen gegen eine frische
        `--print-mk`-Ausgabe. Die zwei `--disable`-Listen im [`Makefile`](../../../../Makefile)
        sind nach Namen gegen Fragment und `modules:`-Zeile gehalten, wie beim letzten Sprung.
        Für `regelwerk-check` heißt das: seine Liste trägt **jeden** Namen der `modules:`-Zeile.
        Der Kommentar darüber behauptet diese Deckungsgleichheit, und sein Kopplungs-Kommando
        misst sie — es gibt nichts aus und endet mit 0:
        `diff <(grep -m1 '^modules:' .d-check.yml | sed 's/^modules:[[:space:]]*//; s/[][]//g' | tr ',' '\n' | tr -d ' ' | sort) <(sed -n '/^regelwerk-check:/{n;p}' Makefile | grep -oE -- '--disable [a-z-]+' | awk '{print $2}' | sort)`.
        `regelwerk-check` braucht Netz und läuft nicht in `make gates`; kein Gate hält diese Zeile,
        das Kommando ist ihr einziger Maßstab.
      - Der Adaptions-Eintrag zum Sprung `v0.76.1` → `v0.76.3` steht (Übergabe an den Architect,
        §6) und trägt die Messungen aus DoD 2.
      - [`make full-smoke`](../../../../harness/sensors/full-smoke.md) ist grün, und die Stufe
        `blind_gruen_ohne_waechter` in
        [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) sagt am
        gepinnten Stand, was sie misst. Der Anlass des Vorlauf-Wächters ist die **auflösbare, aber
        leere** Range (`git rev-list --count` → 0); der flache Klon der Stufe legt daneben eine
        **unauflösbare Basis** vor, und die nimmt `v0.76.3` dem Wächter ab —
        `make -C <flacher Klon> -f d-check.mk doc-commits RANGE=HEAD..HEAD` endet dort mit Exit 2
        statt mit `0 Befund(e)`, und `doc-immutable` am selben Aufbau nicht. **Ersatzlos entfällt
        die Stufe nicht:** Welcher Aufbau die Klasse *blind und grün* am gepinnten Stand noch
        trägt und an welchem Ziel, nennt der Umsetzungs-Commit; was die Stufe danach behauptet,
        steht in ihrem Kommentar und in ihrer `e2e_abdeckung`-Deklaration. Das Urteil darüber,
        was sie misst, liegt beim Implementer.
      - **Rot:** Wer nur `d-check.mk` bewegt, bringt `make test` an
        `TestDefaultImage_MatchesCanonical` und `TestDefaultDigest_MatchesCanonical` zu Fall. Die
        Meldung ist gelesen. Daneben: `make full-smoke` endet ungleich 0; oder das
        Kopplungs-Kommando oben nennt eine `<`- oder `>`-Zeile; oder eine Stufe behauptet weiter
        blindes Grün an einem Ziel, das am gepinnten Stand selbst mit Exit 2 abbricht.
- [x] **2 — Die Strenge-Bilanz über `v0.76.1..v0.76.3` ist gezogen, und die zwei geänderten
      Verhalten sind an diesem Repo und an einem frischen Ziel gemessen.**
      - **Bilanz** nach [`MR-063`](../../../../harness/conventions.md#mr-063): die Quell-Differenz
        der Regeldateien der aktiven Module und der Module, die ein Werkzeug dieses Repos außerhalb
        von `modules:` fährt; je aktivem Modul eine Gegenmessung auf Nicht-Null-Basis, beide
        Digests je mit dem Fragment ihres Standes. Die Symlinks im Baum bleiben stehen.
      - **Angabe** nach [`MR-065`](../../../../harness/conventions.md#mr-065) Setzung 1: Jeder
        history-lesende Lauf der Bilanz nennt zum Laufzeitpunkt Pack-Namen, Alternates und lose
        Objekte seines Klons.
      - **Dogfood:** An einer Wegwerf-Kopie, deren Range-Objekte in einem `loose-*.pack` mit
        passender `.idx` liegen, liefert `make adr-immutable RANGE=…` unter `v0.76.1` Exit 2 und
        unter `v0.76.3` Exit 0, beide mit gelesener Ausgabe. **Gegenprobe:** Dieselbe Kopie mit
        einem tatsächlich fehlenden Objekt der Range bricht unter `v0.76.3` weiter mit Exit 2 ab.
      - **Ziel:** In einem frisch emittierten Ziel ohne `vcs:`- und ohne `commits:`-Block meldet
        d-check eine unauflösbare Range unter `v0.76.3` selbst mit Exit 2, für `vcs` und für
        `commits`. Daneben steht, was `v0.76.1` an derselben Stelle meldet. **Die Messung läuft am
        Vorlauf-Wächter vorbei:** über das Rezept aus dem `d-check.mk` des Ziels oder `docker run`
        mit dessen Digest, nicht über ein Ziel, das `history-range-guard` vorschaltet.
      - **Alternates:** Der Fall aus [`MR-065`](../../../../harness/conventions.md#mr-065) ist
        unter `v0.76.3` nachgemessen und datiert.
      - Fällt die Bilanz auf **Senkung**, greift §4.
      - **Rot:** Die Befundmengen der Gegenmessung weichen ab; oder `v0.76.3` meldet am
        `loose-*.pack` Exit 2; oder die Gegenprobe meldet Exit 0; oder das Ziel meldet die
        unauflösbare Range unter `v0.76.3` mit Exit 0.
- [x] **3 — Die Grenzen und Neu-Prüf-Fälle von [`MR-061`](../../../../harness/conventions.md#mr-061),
      [`MR-064`](../../../../harness/conventions.md#mr-064) und
      [`MR-065`](../../../../harness/conventions.md#mr-065) sind geprüft, und jede
      Werkzeug-Aussage mit `v0.76.1` als Messstand ist am neuen Stand gemessen oder datiert**
      ([`MR-053`](../../../../harness/conventions.md#mr-053)).
      - Gemeint sind die Treffer des Zählkommandos aus §1, darunter
        [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md),
        [`harness/sensors/commit-msg-check.md`](../../../../harness/sensors/commit-msg-check.md)
        und der Kommentar am `commits`-Block der [`.d-check.yml`](../../../../.d-check.yml).
      - [`harness/sensors/history-range-guard.md`](../../../../harness/sensors/history-range-guard.md)
        §Grenze ist an beiden Punkten aus §1 nachgezogen: Der Wächter fängt eine unauflösbare
        Basis selbst ab, und der Abbruch an Packs unter anderem Präfix ist am neuen Stand gemessen.
      - Für jeden Neu-Prüf-Fall steht im Adaptions-Eintrag, ob er eingetreten ist und was die
        Messung dazu sagt.
      - **Rot:** Das Zählkommando aus §1 nennt eine Zeile, die `v0.76.1` als geltenden Stand
        ausgibt; oder `history-range-guard.md` §Grenze sagt weiter, der Wächter decke eine
        unauflösbare Basis nicht.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: über Liefer-Punkt 3 hinaus keines, solange die Gate-Namen gleich bleiben. Kommt ein Target hinzu, zieht Liefer-Punkt 1 den Gate-Index nach.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
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
| [`d-check.mk`](../../../../d-check.mk) | update | DoD 1: Pin, Digest, re-adaptiertes Fragment, Kopf über den neuen Stand |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | DoD 1: emittierter Default-Pin |
| [`Makefile`](../../../../Makefile) | update | DoD 1: die zwei `--disable`-Listen nach Namen — die Liste von `regelwerk-check` trägt jeden Namen der `modules:`-Zeile |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | DoD 1: die Stufe `blind_gruen_ohne_waechter` sagt am gepinnten Stand, was sie misst |
| [`docs/user/e2e-abdeckung.md`](../../../../docs/user/e2e-abdeckung.md), [`test/e2e-abdeckung.bats`](../../../../test/e2e-abdeckung.bats) | update, falls die `e2e_abdeckung`-Deklaration der Stufe sich ändert | DoD 1: die Datei entsteht mit `make e2e-abdeckung` aus den Stufen-Deklarationen, ihren Inhalt hält ein Fall in `make test` ([`harness/README.md`](../../../../harness/README.md) §Werkzeuge) |
| Adaptions-Eintrag unter `harness/conventions/` samt Index-Zeile | neu | DoD 1, DoD 3: Architect-Artefakt ([`AGENTS.md`](../../../../AGENTS.md) §3.8), eigener Commit |
| [`harness/sensors/history-range-guard.md`](../../../../harness/sensors/history-range-guard.md) | update | DoD 3: §Grenze, beide Punkte aus §1 |
| [`AGENTS.md`](../../../../AGENTS.md) | update, falls das Zählkommando trifft | DoD 3: Architect-Artefakt, eigener Commit (§3.8) |
| [`harness/sensors/docs-check.md`](../../../../harness/sensors/docs-check.md), [`harness/sensors/commit-msg-check.md`](../../../../harness/sensors/commit-msg-check.md), [`.d-check.yml`](../../../../.d-check.yml) (Kommentar) | update | DoD 3: Aussagen mit `v0.76.1` als Messstand |
| `internal/emit/emit_test.go` (bestehend) | unverändert | DoD 1: `TestDefaultImage_MatchesCanonical` und `TestDefaultDigest_MatchesCanonical` halten die Kopplung |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, und über `v0.76.3` hinaus ist kein
Release erschienen, oder der Planner hat den Ziel-Tag in Titel und §1 nachgezogen (§6, Risiko 2).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Bilanz fällt auf Senkung, oder das
  Fragment braucht einen neuen Handgriff. Dann ist der Sprung eine Entscheidung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 und wird neu geschnitten. Ebenso, wenn die E2E-Stufe
  aus DoD 1 mehr verlangt als eine Umschrift ihrer Aussage — dann wird der Stufen-Teil eigens
  geschnitten, statt in diesem Slice zu wachsen.
- `in-progress` → `open` (blockiert — Carveout?): Das Bild ist aus der Registry nicht abrufbar,
  oder sein Digest lässt sich nicht aus Registry und lokalem Bild zugleich belegen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` und `make full-smoke` sind grün, mit `v0.76.3` an beiden gekoppelten Stellen.
2. Die Messungen aus DoD 2 stehen mit gelesener Ausgabe im Umsetzungs-Commit und im
   Adaptions-Eintrag, und der Eintrag hat seinen Review.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der `loose-*.pack`-Zustand ist an einer Kopie nicht herstellbar.** *Absehbar:* entfallen,
   wenn eine Wegwerf-Kopie ihn zeigt; sonst eingetreten, und die Grenze steht datiert im
   Adaptions-Eintrag. — **Ausgang:** **entfallen** — die Lage ist an einer Wegwerf-Kopie
   hergestellt und von der Verifikation selbst gebaut: `loose-ddd93102….pack` mit passender `.idx`,
   `count: 0`, keine Alternates. Nicht herstellbar war die Lage **aus der Anleitung**, die der
   Eintrag dazu schreibt; das ist V-1 und hat seine Adresse in §7.
2. **Vor dem Start erscheint ein weiterer Release.** *Absehbar:* entfallen, wenn der Slice vorher
   beginnt. Sonst zieht der Planner den Ziel-Tag in Titel und §1 nach, bevor der Slice beginnt; die
   Kennung nennt keinen Tag. — **Ausgang:** **entfallen** — `v0.76.3` ist auch am Tag der Closure
   der neueste Release; der Ziel-Tag musste nicht nachgezogen werden
   (`gh release list -R pt9912/d-check --limit 5` nennt `v0.76.3` als `Latest`, in der Closure am
   2026-09-17 gefahren). Die Verifikation hatte diese Hälfte ausdrücklich offen gelassen.
3. **Der Adaptions-Eintrag wird mit dem Push unveränderlich, bevor der Review ihn liest**
   ([`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md)).
   *Absehbar:* entfallen, wenn der Eintrag erst nach der letzten Review-Runde gepusht wird. —
   **Ausgang:** **entfallen** — `51cad34c` änderte den Eintrag nach Review-Runde 1 (`60b4f42b`) und
   vor Runde 2 (`93a0d10f`); er war während seines Reviews noch änderbar, und die drei Befunde
   F-1, F-3 und F-4 sind vor dem Einfrieren behoben statt durch einen Folge-Eintrag geheilt.
4. **Die Ziel-Messung läuft über den Vorlauf-Wächter und misst ihn statt des Werkzeugs.** Der
   Wächter bricht eine unauflösbare Range selbst ab; ein Rot über ihn belegt nichts über d-check.
   *Absehbar:* entfallen, wenn der Umsetzungs-Commit den Aufruf ohne Wächter nennt und dieselbe
   Stelle unter `v0.76.1` anders meldet. — **Ausgang:** **entfallen** — Messung 2 nennt den Aufruf
   am Wächter vorbei (`docker run` aus dem Rezept des Ziel-Fragments) und stellt `v0.76.1` an
   derselben Stelle mit `0 Befund(e)`, Exit 0 daneben; ein Wächter-Rot sähe an beiden Ständen
   gleich aus.
5. **Die Klasse *blind und grün* ist am gepinnten Stand an keinem Aufbau mehr herstellbar, den
   diese Stufe fahren kann.** Dann trägt die Stufe keine Aussage mehr, und `make full-smoke` bleibt
   rot — der Sensor läuft laut [`harness/README.md`](../../../../harness/README.md) §Safety and
   scope boundaries bei jedem Push in der CI. *Absehbar:* entfallen, wenn `make full-smoke` mit
   einer benannten Stufen-Aussage grün endet. Sonst eingetreten: Rückführung nach §4 und
   Folge-Slice für den Stufen-Teil; ein Carveout trägt den roten Stand nur, wenn der Slice mit
   rotem `full-smoke` schließen soll. — **Ausgang:** **entfallen** — `make full-smoke` endet mit
   Exit 0, und die Stufe nennt beide Aufbauten einzeln: `doc-immutable` am flachen Klon,
   `doc-commits` am vollständigen. Die Klasse *blind und grün* ist damit an einem benannten Aufbau
   weiter herstellbar; die Rückführung nach §4 war nicht nötig.

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8)

Ein Adaptions-Eintrag zum Sprung `v0.76.1` → `v0.76.3` nach dem Muster von
[`MR-064`](../../../../harness/conventions.md#mr-064), in der Form aus
[`MR-053`](../../../../harness/conventions.md#mr-053), mit der Gegenmessung aus
[`MR-063`](../../../../harness/conventions.md#mr-063) und der Angabe aus
[`MR-065`](../../../../harness/conventions.md#mr-065). Er sagt, ob die Neu-Prüf-Fälle von
[`MR-064`](../../../../harness/conventions.md#mr-064) und
[`MR-065`](../../../../harness/conventions.md#mr-065) eingetreten sind, und datiert die
Alternates-Grenze.

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

Geschrieben vom Planner in eigenem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10). Eingang
sind die Review-Reports der Runden 1 bis 4 und der Verifikations-Report, alle vom 2026-09-17.
Maßstab sind Baseline-Regelwerk `v6.9.0` · `modul-05-planning-harness.md` §Closure- und
Lerneintrag-Regeln und `modul-06-roadmap.md` §Das Beobachtungs-Register.

- **Was hat funktioniert:**
  - **Die Bilanz des Sprungs ist an beiden Enden gemessen, nicht aus dem CHANGELOG übernommen.**
    Das geänderte Verhalten steht je Stand mit Aufruf, Gegen-Stand und gelesener Ausgabe da:
    am `loose-*.pack` einer Wegwerf-Kopie (`v0.76.1` Exit 2, `v0.76.3` Exit 0) und an einem frisch
    emittierten Ziel ohne `vcs:`- und ohne `commits:`-Block. Die Gegenprobe — ein wirklich
    fehlendes Objekt — bricht unter `v0.76.3` weiter ab; ohne sie wäre die Messung eine Aussage
    über Lockerung statt über Reichweite.
  - **Die Ziel-Messung lief am Vorlauf-Wächter vorbei**, wie §6 Risiko 4 es verlangt. Das war
    vorab benannt und ist im Eintrag am Aufruf ablesbar.
  - **Der Konflikt um die Anleitung lief über den Konflikt-Pfad, nicht über eine Umschrift.**
    Die Verifikation fand den Aufbau-Satz nicht nachfahrbar (V-1, MEDIUM); geheilt wurde er nicht
    durch Änderung des gepushten Eintrags, sondern durch
    [`MR-067`](../../../../harness/conventions.md#mr-067) — der Weg, den der append-only-Block
    vorsieht ([`MR-032`](../../../../harness/conventions.md#mr-032)).
  - **Die vier Review-Runden haben ihre eigenen Befunde weitergetragen:** F-1 bis F-5 behoben,
    H-1 behoben, H-2 aufgenommen; die Runden 2 bis 4 prüften jede Behebung mit einem selbst
    gefahrenen Kommando nach.
- **Was ging anders als geplant:**
  - **§3 nannte die Dateien für DoD 3 als Liste; zwei weitere trugen dieselbe Aussage**
    (Verifikation V-2): `.github/workflows/ci.yml` (Kopfkommentar mit Messstand) und
    `harness/sensors/doc-structure.md`. Beide fallen sachlich unter DoD 3 und verlassen die
    Abgrenzung in §1 nicht — die Verifikation hat das eigens nachgemessen. Der Plan-Änderungs-Commit
    `e4b44dd3` hätte sie nachtragen können; §3 bleibt, wie er ist, der Plan vor dem Code. Gezählt
    unten.
  - **Ein zweiter Adaptions-Eintrag war nicht vorgesehen.** §6 übergab **einen** Eintrag zum
    Sprung; entstanden sind zwei — [`MR-066`](../../../../harness/conventions.md#mr-066) für den
    Sprung und [`MR-067`](../../../../harness/conventions.md#mr-067) für die Aufbau-Anleitung, aus
    V-1. Der zweite ist die Lehre dieses Slice und steht unten als Lerneintrag.
  - **Runde 4 hat keinen eigenen Nachfolge-Review.** Sie gab die Closure frei und ließ drei INFO
    offen; ihre Routen stehen unten.
- **Entscheidungen zu den Übergaben:**
  - **Risiken aus §6:** alle fünf *entfallen*, jedes in der Closure gegen den Beleg der
    Verifikation gehalten (§6). Die Grenze bei Risiko 2 — *ob upstream ein `v0.76.4` liegt* — hat
    die Verifikation offen gelassen und die Closure geschlossen: sie hat die Release-Liste selbst
    gelesen.
  - **V-1 (MEDIUM):** beantwortet durch [`MR-067`](../../../../harness/conventions.md#mr-067),
    geschrieben vom Architect vor dieser Closure. Der Rumpf von
    [`MR-066`](../../../../harness/conventions.md#mr-066) bleibt unangetastet; die Anleitung ist
    abgelöst, die Messwerte gelten fort. Zusätzlich gezählt, unten.
  - **V-2 (LOW):** vermerkt, oben. Kein Nachtrag an §3 in dieser Closure — der Plan ist das
    Artefakt *vor* dem Code, und ein nachgetragener Plan behauptete Voraussicht, die es nicht gab.
    Die Klasse ist gezählt.
  - **V-3 (INFO):** steht als Grenze der Verifikation, nicht als Befund. Messung 2 (frisch
    emittiertes Ziel), Messung 3 und die Alternates-Messung sind vom Verifier **nicht**
    nachgefahren und auch nicht bestritten; getragen werden sie vom Umsetzungs-Commit und vom
    Eintrag, die beide Aufruf, Gegen-Stand und Ausgabe führen. Wer sie braucht, fährt sie nach —
    die Adresse ist [`MR-066`](../../../../harness/conventions.md#mr-066) Messung 2 und 3. Keine
    Klasse, kein Beleg.
  - **Die fünf offenen INFO-Befunde, je mit Route:**
    - **F-6** (zwei Anker desselben Ziels nebeneinander, dazu Feld-Namen als `§`-Abschnitte
      adressiert): **abgelehnt, mit Grund.** [`harness/conventions.md`](../../../../harness/conventions.md)
      §Adaptions-Block erklärt beide Anker für gültig; der Verweis löst auf, und das Doku-Gate
      sieht ihn grün. Die Redundanz kostet eine Zeile und keine Zusage. Wer die Stelle ohnehin
      anfasst, zieht sie nach; ein eigener Vorgang dafür wäre teurer als der Defekt.
    - **F-7** (der Bilanz-Schluss gibt dem mitgeänderten Ziel `tracked` kein eigenes Verdikt):
      **Register**, [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md).
    - **G-1** (Konjunktiv über die verworfene Alternative im Altbestand von `full-smoke.sh`):
      **abgelehnt, mit Grund.** [`AGENTS.md`](../../../../AGENTS.md) §3.7 bindet den Kommentar,
      der geschrieben oder geändert wird; der Bestand ist ausdrücklich kein Arbeitsauftrag, und
      wer die Zeile stehen lässt, bricht nichts. Die Klasse ist über F-2 gezählt — derselbe
      Vorgang zählt einmal.
    - **G-2** (*am Modul `vcs` nicht* ist an einem Aufbau gemessen): **Register**, derselbe
      Eintrag wie F-7.
    - **I-1** (die Anwesenheits-Zeile prüft ein Objekt, nicht die Range): **Register**, derselbe
      Eintrag wie F-7. Die Grenze dazu steht unten.
  - **H-1 und H-2** sind in diesem Vorgang beantwortet, nicht offen: H-1 durch Setzung 4 von
    [`MR-067`](../../../../harness/conventions.md#mr-067) (Cutoff ab dem Eintrag, Bestand kein
    Arbeitsauftrag), H-2 durch die dritte Zeile von Setzung 2, die Anwesenheit prüft. Urteile zur
    Zählung unten.
- **Steering-Loop-Eintrag:** **Geschärfte Regel.** Eine Aufbau-Anleitung in einem Eintrag des
  Adaptions-Blocks nennt **zuerst die Prüf-Bedingung**, gegen die der Aufbau vor der Messung
  gehalten wird, und **danach** die Kommandos, mit denen der schreibende Lauf sie erreicht hat —
  [`MR-067`](../../../../harness/conventions.md#mr-067) Setzung 1, mit der Bedingung für die
  Pack-Namens-Lage in Setzung 2 und dem Cutoff in Setzung 4.
  - **Ohne Anker-Feld.** Die Regel kommt aus einem Verifikations-Befund, nicht aus dem
    3×-Übertritt des Registers; `grundlagen-traceability.md` §Herkunfts-Anker bindet den Anker eng
    an die Schwelle, und `liegt in` steht deshalb hier nicht.
  - **Was sie zieht:** Der nächste Pin-Sprung misst nicht mehr gegen einen Kommando-Satz, sondern
    gegen eine Bedingung, die er vor der Messung prüfen kann — und ein Aufbau ohne Gegenstand
    (`count: 0` verletzt) fällt auf, bevor er ein Grün ohne Deckung erzeugt.
  - **Was sie nicht erreicht:** ihr Geltungsbereich ist der Adaptions-Block. Eine Aufbau-Anleitung
    in einer Sensor-Datei oder einem Slice-Plan trägt keine Regel; das ist der Grund, warum die
    Klasse daneben als Beobachtung zählt.
- **Beobachtungs-Register (`../observations/`):**
  - Der Beleg heißt in jedem Fall `evidence/slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.md`.
  - Den Zähler liefert `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, die
    Zahl der Belege aus diesem Vorgang
    `ls docs/plan/planning/observations/BEO-ALL/*/evidence/slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.md | wc -l`
    (→ 7). Keine der Zahlen ist ein Erwartungswert.
  - **Ein neues Verzeichnis**,
    [`aufbau-anleitung-stellt-die-gemessene-lage-nicht-her`](../observations/BEO-ALL/aufbau-anleitung-stellt-die-gemessene-lage-nicht-her/observation.md):
    Für V-1 trägt kein vorhandener Eintrag. Der nächste,
    [`mess-rezept-setzt-unbenannte-host-konfiguration-voraus`](../observations/BEO-ALL/mess-rezept-setzt-unbenannte-host-konfiguration-voraus/observation.md),
    bindet an eine **Einstellung des Hosts**, die das Rezept nicht nennt; hier ist der Host genannt
    (`git --version` → 2.43.0) und die Schritt-Folge unvollständig.

  | Eintrag | Quelle | Zähler | Stand |
  |---|---|---|---|
  | [`zitat-grep-uebersieht-zeilenumbruch-und-markup`](../observations/BEO-ALL/zitat-grep-uebersieht-zeilenumbruch-und-markup/observation.md) | Review F-1 | 4 | geplant |
  | [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md) | Review F-2; Runde 2, G-1 (Altbestand) | 15 | verkörpert |
  | [`umschrift-eines-zitats-aendert-die-aussage`](../observations/BEO-ALL/umschrift-eines-zitats-aendert-die-aussage/observation.md) | Review F-3 und F-4 | 2 | offen |
  | [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | Review F-7; Runde 2, G-2; Runde 4, I-1 | 6 | geplant |
  | [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md) | Verifikation V-2 | 28 | geplant |
  | [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md) | die Alternates-Lücke, unter `v0.76.3` nachgemessen (§1, Bestands-Ausschluss) | 4 | geplant |
  | [`aufbau-anleitung-stellt-die-gemessene-lage-nicht-her`](../observations/BEO-ALL/aufbau-anleitung-stellt-die-gemessene-lage-nicht-her/observation.md) | Verifikation V-1 | 1 | offen |

  **Lese-Schritt.** Kein Eintrag erreicht mit diesem Slice zum ersten Mal 3×:
  `zitat-grep-uebersieht-zeilenumbruch-und-markup` stand schon bei 3 und behält seinen Ausgang,
  die übrigen lagen darüber oder liegen darunter. Repo-weit trägt kein Eintrag mit mindestens drei
  Belegen den Stand `offen` — in der Closure gemessen, je Verzeichnis die Zahl der Belege gegen
  die erste Zeile der `state.md`. Kein `state.md` war deshalb zu ändern.

  **Zwei Ausgänge decken diesen Fall nur zum Teil, und das ist das Urteil der Closure:**

  - `stellen-messung-als-eigenschaft-ausgegeben` ist mit
    `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` geplant, und dessen Regel gilt dem
    lebenden Artefakt, das über das **Verhalten eines Werkzeugs** spricht. F-7 und G-2 liegen
    darin; **I-1 nicht** — dort reicht eine *Aufbau-Bedingung* weiter als ihre Prüfung. Ihre
    Antwort steht in [`MR-067`](../../../../harness/conventions.md#mr-067) Setzung 2, und zwar
    nur für diesen einen Aufbau.
  - `werkzeug-luecke-im-nachbar-repo-ohne-adresse` ist mit
    `slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse` geplant; bis dahin trägt jeder
    Sprung die Nachmessung der Alternates-Lücke, dieser eingeschlossen.

  **Nicht getragen, mit Urteil:**

  - **F-5** (Vorbelegung eines Beleg-Etiketts): behoben, bevor sie etwas behauptet hat — beide
    heutigen Aufrufe setzen das Argument, und die Funktion ist jetzt fail-closed. Es entstand
    keine falsche Beleg-Zeile; die Klasse *Beleg nennt einen Aufbau, den er nicht gefahren hat*
    ist damit nicht aufgetreten, sondern abgewendet.
  - **F-6:** abgelehnt, Grund oben. Kein Eintrag trägt „zwei gültige Anker nebeneinander", und
    einer dafür wäre eine Formalie ohne Fehlerrichtung.
  - **H-1** (eine neue Setzung nennt ihren Cutoff nicht): behoben in demselben Eintrag, durch
    Setzung 4. Die Frage *gilt eine neue Setzung rückwirkend?* ist für das Pflichtfeld bereits in
    [`MR-060`](../../../../harness/conventions.md#mr-060) entschieden und für die Setzung jetzt in
    [`MR-067`](../../../../harness/conventions.md#mr-067) Setzung 4; ein Register-Eintrag zählte
    eine Klasse, deren Antwort an beiden Hälften steht.
  - **H-2** (die Bedingung prüfte nur Abwesenheit): der nächste Eintrag,
    [`zusicherung-ueber-der-leeren-menge-wahr`](../observations/BEO-ALL/zusicherung-ueber-der-leeren-menge-wahr/observation.md),
    verlangt das stille Grün über der leeren Menge. Hier entsteht keines: Ein leerer Objektspeicher
    lässt den Lauf unter **beiden** Ständen abbrechen — das sagt [`MR-067`](../../../../harness/conventions.md#mr-067)
    Setzung 2 selbst. Die Zeile spricht eine Voraussetzung aus; ihr Fehlen scheiterte laut.
  - **V-3:** keine Klasse, siehe oben.
- **Trigger-Audit** (bei der Slice-Closure):
  - **Carveout:** `CO-001` steht auf *Aktiv — Auflösung fällig*, seine Adresse ist
    `slice-113-co-001-ist-faellig` in `open/`; `CO-002` steht auf *Permanent*. Dieser Slice berührt
    keine ihrer Bedingungen.
  - **Bootstrap-aware Gate:** keines (`grep -rn -i 'bootstrap-aware' Makefile *.mk` → kein
    Treffer).
  - **ADR:** [`ADR-0056`](../../adr/0056-ziel-fassung-regiert-den-sprung-v690.md) — kein Trigger
    eingetreten: Der Slice bewegt den Baseline-Zielstand nicht und springt nicht; er bewegt den
    Pin eines Werkzeugs.
  - **Adaptions-Einträge, die dieser Slice fährt:**
    - [`MR-061`](../../../../harness/conventions.md#mr-061), permanent (*bei jedem
      d-check-Release*): **eingelöst** für `v0.76.2` und `v0.76.3` — Pin, Fragment und
      Strenge-Bilanz sind in diesem Slice gefahren. Der Trigger bleibt permanent und feuert beim
      nächsten Release erneut.
    - [`MR-063`](../../../../harness/conventions.md#mr-063), permanent: **angewandt** — je aktivem
      Modul eine Gegenmessung auf Nicht-Null-Basis, neun Basen, Symlinks stehen (Verifikation
      §ADR-/MR-Konformität).
    - [`MR-064`](../../../../harness/conventions.md#mr-064) und
      [`MR-065`](../../../../harness/conventions.md#mr-065), beide permanent: Ihr Neu-Prüf-Fall
      *d-check liest Packs unter fremdem Präfix* ist **eingetreten und gemessen**; beide tragen
      ihre Kopf-Marke auf [`MR-066`](../../../../harness/conventions.md#mr-066) und bleiben aktiv
      in `harness/conventions/`. Die Alternates-Grenze aus
      [`MR-065`](../../../../harness/conventions.md#mr-065) ist nachgemessen und besteht fort.
    - [`MR-066`](../../../../harness/conventions.md#mr-066), permanent: neu; sein Trigger feuert
      erstmals beim nächsten d-check-Release.
    - [`MR-067`](../../../../harness/conventions.md#mr-067), permanent, *solange ein Eintrag dieses
      Blocks eine Lage herstellt*: neu; er bindet ab dem nächsten Eintrag mit Aufbau-Anleitung.
    - [`MR-062`](../../../../harness/conventions.md#mr-062): nicht eingetreten — die Marke stand
      beim Handgriff-Durchgang und ihre Menge ist nicht leer.
- **Folge-Slices:** **keiner neu.** Jeder offene Posten hat eine Adresse, die ihn annimmt:
  - `slice-werkzeug-luecke-im-nachbar-repo-bekommt-eine-adresse` (vorhanden, in `open/`) — die
    Alternates-Lücke und die Regel, welche Adresse eine gemessene Werkzeug-Lücke bekommt; genau
    der Punkt, den §1 an ihn abgegeben hat.
  - `slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle` (vorhanden, in `open/`) — F-7 und
    G-2 über den Register-Eintrag.
  - `slice-zitat-pruefung-liest-statt-greppt` (vorhanden, in `open/`) — F-1 über den
    Register-Eintrag; er schreibt, dass eine Zitat-Prüfung an der Quelle liest, statt über ein
    Muster zu suchen.
  - `slice-153-wellen-commands-nennen-die-roadmap-abschnitte` (vorhanden, in `open/`) — V-2 über
    den Register-Eintrag, dessen Ausgang dort nur die Anker-Unterklasse trägt; die übrigen
    Unterklassen bleiben *Regel ohne Sensor*.
  - Kein weiterer: F-6, G-1, H-1, H-2 und V-3 sind oben abgelehnt oder in diesem Vorgang
    beantwortet.
- **Risiken aus §6:** alle fünf haben genau einen Ausgang, *entfallen*.
- **Archiv:** keines. Dieses Repo archiviert bei einer Slice-Closure nicht.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `d-check.mk`, `internal/emit/`,
`harness/sensors/`, `harness/conventions/` und die `.d-check.yml`; alle liegen in `*`.
`harness/tools/` (`TOOLS`) wird gelesen, nicht geändert, und `.codex/` (`CODEX`) ist nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-luecke-im-nachbar-repo-ohne-adresse`](../observations/BEO-ALL/werkzeug-luecke-im-nachbar-repo-ohne-adresse/observation.md) | 3 | geplant | das Pack-Präfix hat mit `v0.76.2` eine Antwort im Werkzeug, die Alternates bleiben ein Beleg |
| [`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md) | 2 | offen | §6, Risiko 3 |
| [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) | 3 | geplant | der Werkzeug-Stand in §1 stammt aus dem CHANGELOG; DoD 2 misst am Bild |
| [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | 4 | geplant | DoD 3 |
| [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | 5 | geplant | die Messung am `loose-*.pack` ist eine Stelle; ob *jedes* fremde Präfix gelesen wird, sagt sie nicht |
| [`gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang`](../observations/BEO-ALL/gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang/observation.md) | 2 | offen | die Mitgabe aus §1: ein Prosa-Satz über den Abbruch, den das Werkzeug im Ziel nicht hielt |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
