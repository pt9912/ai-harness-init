# Slice slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme: Der d-check-Pin springt `v0.76.3` → `v0.77.0`, und die Instanz-Identitäts-Ausnahme wird verfügbar

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der
Digest-Pin ist die Reproduzierbarkeits-Zusage),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
grünes Gate sagt etwas über den Ausschnitt, den es prüft — dafür steht die Bilanz),
[`MR-061`](../../../../harness/conventions.md#mr-061) §Auflösungs-Trigger (bei jedem d-check-Release:
Pin, Fragment, Strenge-Bilanz), [`MR-063`](../../../../harness/conventions.md#mr-063) (Gegenmessung
je aktivem Modul), [`MR-066`](../../../../harness/conventions.md#mr-066) (der Vorgänger dieser
Pin-Linie und die drei Digest-Wege), [`MR-053`](../../../../harness/conventions.md#mr-053) (eine
Werkzeug-Aussage datiert ihren Messstand), [`MR-054`](../../../../harness/conventions.md#mr-054)
(was ins emittierte Gate geht), [`MR-010`](../../../../harness/conventions.md#mr-010) und
[`MR-062`](../../../../harness/conventions.md#mr-062) (Fragment-Re-Adaption und ihre Handgriffe).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-18.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der gepinnte d-check steht auf `v0.77.0` statt `v0.76.3`, an beiden gekoppelten Stellen
und mit belegtem Digest; das tool-generierte Fragment ist gegen eine frische `--print-mk`-Ausgabe
re-adaptiert, und die Strenge-Bilanz über die Spanne ist gezogen. Danach stellt das gepinnte Bild
die Instanz-Identitäts-Ausnahme `matrix.rules[].allow-if-same-id` bereit; benutzt wird sie hier
nicht.

**Herkunft:** Der Auftraggeber hat am 2026-09-18 den Release gemeldet. Der Sprung löst den
permanenten Auflösungs-Trigger von [`MR-061`](../../../../harness/conventions.md#mr-061) ein und
setzt die Pin-Linie von [`MR-066`](../../../../harness/conventions.md#mr-066) fort. Alles, was
dieser Plan über den neuen Stand sagt, stammt aus dem `CHANGELOG.md` des Klons des Werkzeugs und
aus den Kommandos des Plans.

**Werkzeug-Stand**, gelesen im `CHANGELOG.md` des Klons des Werkzeugs (nur lesend):

- **`v0.77.0`:** `matrix` bekommt eine **Instanz-Identitäts-Ausnahme für die Token-Form**. Mit
  `allow-if-same-id: true` auf einer Regel wird das bereits vorhandene `token`-Regex der
  beteiligten Klassen zweifach genutzt: wie gewohnt gegen den Fließtext (Fund-Erkennung) und
  zusätzlich gegen den repo-wurzel-relativen Pfad der **Quelldatei** (Instanz-Ermittlung). Trägt
  das Regex genau eine Capture-Gruppe und stimmen Quell- und Ziel-ID überein (getrimmt,
  case-sensitiv), fällt der Fund weg. Die Ausnahme wirkt **ausschließlich** auf die Token-Form von
  `matrix-forbidden`; Link-Referenzen und `matrix-inactive` sind unberührt.
- Die Zusage des Stands: **ohne den Schlüssel byte-identisches Verhalten**, kein neuer Grund-Code,
  kein Konfigurations-Bruch. Fail-closed am Config-Rand: `allow-if-same-id: true` auf einer Regel,
  deren beteiligte Klassen kein `token` mit genau einer Capture-Gruppe tragen, ist Exit 2.
- Das ist die Beschreibung des Werkzeugs. Ob sie am Quellstand des Bildes trägt und was sie an
  **unserem** Bestand bedeutet, misst L3 — nicht §1.

**Das Delta, gemessen** am lokalen Klon des Werkzeugs, nur lesend:

```sh
D=<maschinen-lokaler Klon des Werkzeugs>
git -C "$D" diff --numstat v0.76.3 v0.77.0 -- internal/hexagon/core/rules/
```

Die Ausgabe nennt genau zwei Dateien, `matrix.go` und `matrix_test.go`; keine Regeldatei eines
anderen Moduls bewegt sich. Außerhalb von `rules/` nennt
`git -C "$D" grep -ln 'allow-if-same-id' v0.77.0 -- internal/` zwei Quelldateien: den
Konfigurations-Parser und seinen Test. Die Zahlen stehen im Umsetzungs-Commit.

**Zählkommando** für die lebenden Werkzeug-Aussagen — ohne eingefrorene Artefakte und ohne den
Adaptions-Block, dessen Einträge ihren Stand datieren:

```sh
git grep -n 'v0\.76\.[13]' -- ':!docs/reviews' ':!docs/plan/planning/done' ':!harness/conventions' ':!harness/conventions.md' ':!.harness/baseline' ':!docs/plan/adr' ':!docs/plan/planning/observations' ':!docs/plan/carveouts'
```

Sein Ergebnis am Planungstag: jeder Treffer außerhalb der zwei Pin-Stellen nennt seinen
**Mess-Stand** (`gemessen am Stand v0.76.3`, `Gemessen gegen d-check v0.76.1`) — er ist datiert
([`MR-053`](../../../../harness/conventions.md#mr-053)) und wandert nicht mit dem Pin; falsch
machen kann ihn nur der Sprung selbst, und das prüft L3. Treffer in
[`AGENTS.md`](../../../../AGENTS.md) zöge der Architect nach (§3.8), in eigenem Commit. **Keine
Zahl dazu:** die Treffer wandern mit dem Baum.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **`allow-if-same-id` wird nicht gesetzt.** *Anderer Vorgang — und die Fähigkeit hat in diesem
  Repo keinen Gegenstand:* Die Dogfood-[`.d-check.yml`](../../../../.d-check.yml) führt überhaupt
  kein `token` (`grep -n 'token' .d-check.yml` → kein Treffer). Die emittierte Vorlage führt drei
  Token-Klassen — `grep -n 'token:' internal/emit/templates/d-check.yml` nennt neben seinen
  Kommentarzeilen genau `slice`, `welle` und `adaptionsblock` —, und die Quell-Klassen ihrer Regeln
  sind `spec-straten` mit der Pfad-Menge `spec/lastenheft.md`, `spec/spezifikation.md`,
  `spec/architecture.md` sowie `adr` mit `docs/plan/adr/[0-9]*.md`. Keiner dieser Pfade kann eine
  `slice-`/`welle-`/`MR-`-Kennung tragen, also gibt es keine Quelldatei, deren eigene Instanz-ID
  mit einer gefundenen Ziel-ID übereinstimmen könnte. Ein Opt-in ohne Objekt wäre eine Entscheidung,
  die niemand getroffen hat. Dazu kommt die Config-Grenze: Für die einzige inhaltlich nahe Regel
  (`spec-straten` → `adaptionsblock`) wäre der Schlüssel heute ein Exit-2-Fehler, weil die
  Quell-Klasse kein `token` mit Capture-Gruppe führt — ihn zu setzen hieße, den Spec-Straten ein
  Kennungs-Muster zu geben. Das ist ein eigener Vorgang mit eigener Begründung.
- **Kein Modul wird aktiviert, keine Regel der `.d-check.yml` geändert, und die emittierte
  Startkonfiguration bekommt den Schlüssel nicht.** *Schicht-Abgrenzung:* Der Sprung bringt laut
  Werkzeug-Beschreibung keinen neuen Grund-Code und kein Modul; was ins emittierte Gate geht,
  entscheidet [`MR-054`](../../../../harness/conventions.md#mr-054). Hier wandert nur der
  emittierte Default-Pin.
- **Keine ADR.** *Anderer Vorgang:* ADR-pflichtig ist eine Gate-Lockerung
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5); L3 trägt, dass keine eintritt. Eine ADR über eine
  nicht eingetretene Senkung wäre eine Entscheidung ohne Gegenstand.
- **Die lebenden Werkzeug-Aussagen mit älterem Mess-Stand werden nicht umgeschrieben** — die
  Treffer des Zählkommandos in [`AGENTS.md`](../../../../AGENTS.md), der
  [`.d-check.yml`](../../../../.d-check.yml), der CI-Workflow-Datei und unter `harness/sensors/`.
  *Bestand bleibt bewusst stehen:* Jeder nennt seinen Mess-Stand; er ist datiert, nicht überholt,
  und die Aussage, die er trägt, hält der Sprung — L3 misst das. Eine Umschrift ohne Fehlerrichtung
  wäre teurer als der Defekt.
- **`internal/emit/testdata/raw-print-mk.txt` bleibt.** *Bestand bleibt bewusst stehen:* Die
  Fixture ist eine eingefangene `--print-mk`-Ausgabe eines älteren Stands; keiner der zwei
  Kopplungs-Tests liest sie, und [`MR-063`](../../../../harness/conventions.md#mr-063) lässt sie
  stehen.
- **Der Objektspeicher des Arbeitsklons bleibt, wie er ist.** *Anderer Vorgang:* Die Gegenmessung
  läuft nach [`MR-063`](../../../../harness/conventions.md#mr-063) Setzung 2 an einer Wegwerf-Kopie.

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

- [x] **1 — Der Pin steht auf `v0.77.0`, an der ersten der zwei gekoppelten Stellen, mit belegtem
      Digest und re-adaptiertem Fragment.** *(erfüllt — `cb3bc567`: `d-check.mk:77-78` trägt Tag
      und Digest; drei Werte-Wege belegt, der lokale Weg an diesem Lauf wiederholt — §6, Risiko 1;
      Kopfkommentar nennt den Stand; Hunk-Zahl 6 / 5 Handgriffe getrennt, vom Review mit dem
      kanonischen Kommando gemessen; beide Kopplungs-diffs leer — §6, Risiko 6.)*
- [x] **2 — Der emittierte Default-Pin ist nachgezogen, und die Kopplung der zwei Stellen ist
      dabei nachgewiesen.** *(erfüllt — `internal/emit/emit.go:32-33` trägt dieselben Werte;
      `emit_test.go` über die Range unverändert; die Rot-Bedingung ist einmal gefahren — Rotation
      im Wegwerf-Klon, `make test` Exit 1 mit beiden Namen in der Fehlerklasse, Review-Report
      Negativbefunde.)*
- [x] **3 — Die Strenge-Bilanz über `v0.76.3..v0.77.0` ist gezogen: jedes aktive Modul hat eine
      Basis, die Symlinks stehen, und die neue Fähigkeit hat in beiden Konfigurationen dieses Repos
      keinen Gegenstand.** *(erfüllt — Bilanz im Umsetzungs-Commit `cb3bc567` und in
      [`MR-068`](../../../../harness/conventions.md#mr-068) §Gegenmessung; vom Verifier über vier
      Oberflächen unabhängig nachgefahren, beide Digests, Verteilung je Grund-Code zeilenweise
      identisch, Symlinks 10/10; Fähigkeit ohne Gegenstand — §6, Risiko 4.)*
- [x] `make gates` grün. *(gelaufen über `a1efbf79` und über den Kopf `f69148e4`; Exit 0.)*
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8). *(Runde 1,
      `cf0d947d`, Verdikt nicht merge-blockierend; F-2 vom Architect gezogen — `a1efbf79`.)*
- [x] Doku-Update: über L3 hinaus keines, solange die Gate-Namen gleich bleiben. Kommt ein Target
      hinzu, zieht L1 den Gate-Index nach. *(kein Target hinzugekommen;
      [`harness/README.md`](../../../../harness/README.md) über die Range unverändert —
      Verifikations-Report §1.)*
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag. *(§7 — gezählt, nicht verkörpert.)*
- [x] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei nicht.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert. *(Belege in zwei bestehenden Verzeichnissen — §7.)*
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen). *(alle sechs entfallen — §6.)*
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit). *(geprüft nach dem `git mv` — die Ergebnisse stehen in §7; Häkchen im eigenen Commit nach dem Move.)*

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | L1: Tag, Digest, re-adaptiertes Fragment, Kopfkommentar über den neuen Stand |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | L2: emittierter Default-Pin |
| `internal/emit/emit_test.go` (bestehend) | unverändert | L2: `TestDefaultImage_MatchesCanonical` und `TestDefaultDigest_MatchesCanonical` halten die Kopplung; die Rot-Bedingung ist einmal gefahren |
| `internal/emit/testdata/raw-print-mk.txt` | unverändert | §1: eingefangene `--print-mk`-Ausgabe eines älteren Stands; von keinem der zwei Kopplungs-Tests gelesen |
| [`Makefile`](../../../../Makefile) | unverändert, geprüft | L1: die zwei `--disable`-Listen tragen jeden Namen der `modules:`-Zeile; kein Modul kommt hinzu |
| Adaptions-Eintrag unter `harness/conventions/` samt Index-Zeile und der Zeile `d-check:` in §Baseline | neu / update | Übergabe an den Architect (§6, §3.8), eigener Commit; die Sprung-Liste der Zeile `d-check:` bekommt die neue Kennung |
| [`AGENTS.md`](../../../../AGENTS.md), [`.d-check.yml`](../../../../.d-check.yml), `.github/workflows/ci.yml`, `harness/sensors/` | unverändert, geprüft | L3: die Treffer des Zählkommandos aus §1 — jeder nennt seinen Mess-Stand |
| keine ADR | — | §1: der Sprung senkt nichts, also kein ADR-Gegenstand |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, und `v0.77.0` ist der neueste Release
des Werkzeugs, oder der Planner hat den Ziel-Tag in Titel und §1 nachgezogen (§6, Risiko 2).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die Bilanz fällt auf Senkung, oder das
  Fragment braucht einen neuen Handgriff. Dann ist der Sprung eine Entscheidung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 und wird neu geschnitten.
- `in-progress` → `open` (blockiert — Carveout?): Das Bild ist aus der Registry nicht abrufbar, oder
  sein Digest lässt sich auf den drei Wegen aus L1 nicht mit demselben Wert belegen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` grün, mit `v0.77.0` an beiden gekoppelten Stellen.
2. Die Bilanz aus L3 steht mit gelesener Ausgabe im Umsetzungs-Commit und im Adaptions-Eintrag, und
   der Eintrag hat seinen Review.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Der neue Digest lässt sich auf den drei Wegen nicht mit demselben Wert belegen** — der
   Registry-Pull scheitert, oder lokal liegt kein Bild der neuen Fassung. **Ausgang:** *entfallen*
   — Pull und `docker image inspect` nennen denselben Wert; die zwei Netzwege trägt die Message
   von `cb3bc567`, der lokale Weg ist an diesem Lauf wiederholt gefahren
   (`docker image inspect --format '{{json .RepoDigests}}' ghcr.io/pt9912/d-check:v0.77.0` →
   `sha256:3f84502b09af65246fff38b1c3893130050e50581943a0434da95bf68091e337`, derselbe Wert wie in
   [`d-check.mk`](../../../../d-check.mk)).
2. **Vor dem Start erscheint ein weiterer Release.** **Ausgang:** *entfallen* — der Slice begann
   am Tag des Releases, und kein weiterer Release ist seither erschienen
   (`git -C /Development/d-check ls-remote --tags origin` → höchster Tag `v0.77.0`, gemessen am
   2026-09-18 mit Netz; der Pin trägt genau diesen Tag).
3. **Die Bilanz fällt auf Senkung, obwohl der Stand „ohne den Schlüssel byte-identisches Verhalten"
   zusagt.** Dann ist die Werkzeug-Zusage an unserem Bestand falsch. **Ausgang:** *entfallen* —
   beide Befundmengen sind über vier Oberflächen gleich (0/0 · 59/59 · 78/78 · 137/137); die
   Bilanz ist vom Verifier unabhängig nachgefahren und steht im Umsetzungs-Commit (`cb3bc567`)
   wie im Adaptions-Eintrag ([`MR-068`](../../../../harness/conventions.md#mr-068) §Gegenmessung).
   Kein ADR-Gegenstand nach [`AGENTS.md`](../../../../AGENTS.md) §3.5.
4. **Die Fähigkeit hat doch einen Gegenstand** — eine Regel einer der zwei Konfigurationen hat eine
   Quell-Klasse, deren Pfad eine Ziel-Kennung tragen kann. **Ausgang:** *entfallen* — die
   Dogfood-[`.d-check.yml`](../../../../.d-check.yml) führt kein `token`
   (`grep -c 'token' .d-check.yml` → 0), die emittierte Vorlage führt genau drei Token-Klassen
   (`grep -n 'token:' internal/emit/templates/d-check.yml`), deren Quell-Klassen nur Pfad-Mengen
   ohne Kennungs-Form tragen, und der Schlüssel ist nicht gesetzt
   (`git grep -n 'allow-if-same-id' -- ':!docs/reviews' ':!docs/plan/planning' ':!harness/conventions*'`
   → kein Treffer).
5. **Der Adaptions-Eintrag wird mit dem Push unveränderlich, bevor der Review ihn liest**
   ([`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md)).
   **Ausgang:** *entfallen* — der Review hat den Eintrag gelesen (Runde 1, Verdikt nicht
   merge-blockierend), bevor er zu origin kam: die Push-Liste trägt den Eintrag zusammen mit dem
   Review-Report und der F-2-Ziehung im selben Zug, die zwei Zahlen-Anmerkungen des Verifiers sind
   in einem weiteren Push nachgetragen (`git reflog show origin/main` → `cb3bc567`, dann
   `a1efbf79` mit `3aec7e7d` + Review-Report + F-2-Ziehung, dann `f69148e4` mit den
   Nachträgen). Ein Folge-Eintrag nach [`MR-032`](../../../../harness/conventions.md#mr-032) ist
   nicht fällig.
6. **Ein Handgriff des Fragments kommt hinzu, oder ein Name der `--disable`-Listen ändert sich.**
   **Ausgang:** *entfallen* — beide Kopplungs-diffs sind an diesem Lauf leer (Exit 0; die
   Kommandos neben den Rezepten, [`Makefile`](../../../../Makefile) Kopplungs-Kommentare zu
   `doc-commits` und `regelwerk-check`), und die `modules:`-Zeile der Dogfood-Config trägt
   unverändert dieselbe Liste (`grep -m1 '^modules:' .d-check.yml`).

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8)

Ein Adaptions-Eintrag zum Sprung `v0.76.3` → `v0.77.0` nach dem Muster von
[`MR-066`](../../../../harness/conventions.md#mr-066), in der Form aus
[`MR-053`](../../../../harness/conventions.md#mr-053) und mit der Gegenmessung aus
[`MR-063`](../../../../harness/conventions.md#mr-063). Er trägt die Messungen aus L3 und datiert
seine Werkzeug-Aussagen.

**Vorgeschlagene Kennung: die nächste freie Nummer der aktiven Tabelle.** Gemessen ist die letzte
vergebene [`MR-067`](../../../../harness/conventions.md#mr-067)
(`ls harness/conventions/*.md | grep -oE 'MR-[0-9]{3}' | sort | tail -1`), die nächste freie also
**068**. Die Kennung selbst steht hier nicht als Token: das Doku-Gate verlangt für jede Kennung
dieser Klasse einen auflösenden Link ([`MR-001`](../../../../harness/conventions.md#mr-001)), und
ein Link auf einen noch nicht existierenden Eintrag wäre eine tote Adresse. Vergeben wird sie mit
dem Eintrag, vom Architect. Mit ihm gehen seine Index-Zeile und die Zeile `d-check:` in §Baseline,
deren Liste der Sprünge die neue Kennung bekommt. Eigener Commit, Rolle in der Message (§3.8) — und
der Eintrag bleibt **lokal bis zur Review-Runde**.

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

- **Was hat funktioniert:** Die Zerlegung — Sprung und Abgrenzung in einem Slice, der Abgrenzungs-Block
  hat den Umfang gehalten (kein `allow-if-same-id`, keine Regeländerung, keine ADR). Die Kopplung der
  zwei Pin-Stellen durch unveränderte Tests hat sich bewährt: der Review hat die Rotation real rot
  gefahren, der Verifier die Strenge-Bilanz über vier Oberflächen unabhängig nachgefahren — „keine
  Senkung" trägt damit an drei Kontexten, nicht nur am Eintrag.
- **Was ging anders als geplant:** Der Review fand die Pin-Kopplung ohne kuratierten Mutations-Fall
  (F-1, MEDIUM) — der Wächter trägt seine Zähne, aber sein Zahn ist nicht kuratiert. Der Verifier
  fand zwei Zahlen-Anmerkungen an den Adaptions-Eintrag (V-1/V-2), die der Architect nachgetragen
  hat. Beides sind Bestands-/Form-Posten, keine Defekte am Sprung.
- **Steering-Loop-Eintrag:** [`BEO-ALL/neuer-waechter-ohne-mutations-fall`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  ergänzt (vierte Fundstelle): Die Pin-Kopplung (`TestDefaultImage_MatchesCanonical`,
  `TestDefaultDigest_MatchesCanonical`) trägt ihre Zähne — die Rotation wurde am Wegwerf-Klon real
  rot gefahren —, aber keinen kuratierten Fall unter `test/mutations/`; der Fall ist Bestands-Posten
  der Mutations-Kuratierung und wird von [`slice-pin-kopplung-bekommt-ihren-mutations-fall`](../open/slice-pin-kopplung-bekommt-ihren-mutations-fall.md)
  geschrieben. Eine geschärfte Regel an `AGENTS.md` §3.6 trägt nicht: §3.6 sagt die Pflicht bereits
  (wer keinen Fall in `test/mutations/` hat, ist unbewacht), und der Bestand ist kein Arbeitsauftrag
  (Cutoff). Kein `liegt in`-Feld — der Eintrag ist gezählt, nicht verkörpert.
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme.md`
  in [`BEO-ALL/neuer-waechter-ohne-mutations-fall/`](../observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/observation.md)
  ergaenzt — Zaehler steht damit bei 11x (`ls docs/plan/planning/observations/BEO-ALL/neuer-waechter-ohne-mutations-fall/evidence/ | wc -l`).
  Nach dem `git mv` kommt ein zweiter Beleg desselben Vorgangs in
  [`BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/`](../observations/BEO-ALL/lifecycle-move-macht-ein-bewachtes-zustandsfeld-falsch/observation.md)
  dazu (der Ruhe-Marker fällt mit dem Move und wird im eigenen Commit danach gezogen) — derselbe
  Vorgang, zweite Beobachtung, je Beobachtung einmal gezählt.
- **Folge-Slices:** [`slice-pin-kopplung-bekommt-ihren-mutations-fall`](../open/slice-pin-kopplung-bekommt-ihren-mutations-fall.md)
  (Der Pin-Kopplungs-Wächter bekommt seinen kuratierten Mutations-Fall) — ist eine Datei in `open/`.
- **Risiken aus §6:** alle sechs *entfallen* — je Beleg in §6.
- **Drei Paarungen:** Anker — kein `liegt in`-Feld in dieser Notiz, die Paarung ist nicht
  ausgelöst · Folge-Slice — die eine genannte Kennung existiert als Datei im Planning-Lifecycle
  (`open/`) · Register — jede genannte Beobachtung existiert als Verzeichnis, und jedes
  Verzeichnis unter `BEO-ALL/` trägt nicht-leeres `evidence/`
  (`for d in docs/plan/planning/observations/BEO-ALL/*/; do [ -n "$(ls "$d/evidence" 2>/dev/null)" ] || echo "$d"; done`
  → zwei Verzeichnisse ohne Beleg:
  `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` und
  `planungs-bestand-waechst-schneller-als-er-abgebaut-wird`, beide Stand `offen` — derselbe Fund
  wie in `slice-135`; seine Lesart trägt
  `slice-beleglose-register-eintraege-bekommen-eine-lesart` (ist eine Datei in `open/`): ein
  Vorkommen ohne abgeschlossenen Vorgang bekommt keinen Beleg und bleibt benannt, nicht gezählt).
  Geprüft nach dem `git mv`.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `d-check.mk`, `internal/emit/` und der
Adaptions-Block unter `harness/conventions/`; alle liegen in `*` (gesamtes Repo).
`harness/tools/` (`TOOLS`) wird gelesen, nicht geändert; `.codex/` (`CODEX`) ist nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | 4 | geplant | L3: die Bilanz nennt je Aussage ihren Stand, und der Sprung bewegt ihn |
| [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) | 3 | geplant | §1: der Werkzeug-Stand stammt aus dem CHANGELOG; L3 misst am Bild |
| [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | 6 | geplant | die Quell-Differenz der Regeldateien ist eine Stellen-Messung; sie trägt nicht, dass kein Verhalten sich ändert — das trägt die Gegenmessung |
| [`senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`](../observations/BEO-ALL/senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens/observation.md) | 2 | offen | L3: die Bilanz vergleicht Befundmengen; der erwartete Gleichstand ist die Aussage dieses Slice |
| [`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md) | 2 | offen | §6, Risiko 5 |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
