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

**Verantwortlich:** —

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
Stand gemessen.

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

- [ ] **1 — Der Pin steht auf `v0.76.3`, an beiden gekoppelten Stellen und mit belegtem Digest;
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
      - Der Adaptions-Eintrag zum Sprung `v0.76.1` → `v0.76.3` steht (Übergabe an den Architect,
        §6) und trägt die Messungen aus DoD 2.
      - [`make full-smoke`](../../../../harness/sensors/full-smoke.md) bleibt grün, denn der
        emittierte Pin wandert mit.
      - **Rot:** Wer nur `d-check.mk` bewegt, bringt `make test` an
        `TestDefaultImage_MatchesCanonical` und `TestDefaultDigest_MatchesCanonical` zu Fall. Die
        Meldung ist gelesen.
- [ ] **2 — Die Strenge-Bilanz über `v0.76.1..v0.76.3` ist gezogen, und die zwei geänderten
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
- [ ] **3 — Die Grenzen und Neu-Prüf-Fälle von [`MR-061`](../../../../harness/conventions.md#mr-061),
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
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: über Liefer-Punkt 3 hinaus keines, solange die Gate-Namen gleich bleiben. Kommt ein Target hinzu, zieht Liefer-Punkt 1 den Gate-Index nach.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
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
| [`d-check.mk`](../../../../d-check.mk) | update | DoD 1: Pin, Digest, re-adaptiertes Fragment, Kopf über den neuen Stand |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | DoD 1: emittierter Default-Pin |
| [`Makefile`](../../../../Makefile) | prüfen | DoD 1: die zwei `--disable`-Listen nach Namen |
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
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 und wird neu geschnitten.
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
   Adaptions-Eintrag. — **Ausgang:** <eingetreten: CO-NNN / slice-<Kennung> | entfallen: Grund | weiter offen: Register>
2. **Vor dem Start erscheint ein weiterer Release.** *Absehbar:* entfallen, wenn der Slice vorher
   beginnt. Sonst zieht der Planner den Ziel-Tag in Titel und §1 nach, bevor der Slice beginnt; die
   Kennung nennt keinen Tag. — **Ausgang:** <eingetreten | entfallen: Grund | weiter offen: Register>
3. **Der Adaptions-Eintrag wird mit dem Push unveränderlich, bevor der Review ihn liest**
   ([`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md)).
   *Absehbar:* entfallen, wenn der Eintrag erst nach der letzten Review-Runde gepusht wird. —
   **Ausgang:** <eingetreten | entfallen: Grund | weiter offen: Register>
4. **Die Ziel-Messung läuft über den Vorlauf-Wächter und misst ihn statt des Werkzeugs.** Der
   Wächter bricht eine unauflösbare Range selbst ab; ein Rot über ihn belegt nichts über d-check.
   *Absehbar:* entfallen, wenn der Umsetzungs-Commit den Aufruf ohne Wächter nennt und dieselbe
   Stelle unter `v0.76.1` anders meldet. — **Ausgang:** <eingetreten | entfallen: Grund | weiter offen: Register>

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

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Steering-Loop-Eintrag:** offen bis zur Closure.
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure.
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.

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
