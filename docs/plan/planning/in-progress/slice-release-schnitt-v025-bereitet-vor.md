# Slice slice-release-schnitt-v025-bereitet-vor: Der Release-Schnitt `v0.2.5` wird vorbereitet — Assets, Pin und Gates am Tag-Baum, ohne Tag-Push

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
diese DoD — der geschnittene, lokal verifizierte Stand und der gezogene Pin
sind Belege der Liefer-Punkte selbst; ein repo-weites Mehr über sie hinaus
existiert nicht (dieselbe Einordnung wie
[`slice-release-schnitt-koppelt-pin-und-fassung`](../done/slice-release-schnitt-koppelt-pin-und-fassung.md),
der Formvorlage dieses Plans).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
(der Pin trägt Version + sha256, fail-closed gekoppelt),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix)
(die sechs Plattform-Assets),
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
(der gefetchte Träger — der Pin, den dieser Slice zieht, ist die Adresse, die
`make traeger-fetch` später auflöst),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
Festlegung 2 (der Release-Schnitt koppelt Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Folgepflicht 1 (die `SHA256SUMS` entsteht als Mechanik, nicht von Hand),
[`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) Festlegung 1
(`TRAEGER_VERSION` ist der Wert, den der Bau trägt).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912). Der Liefergegenstand ist ein
verifizierter, lokal release-bereiter Baum (Vorlage, Pin, Assets, Gates) —
keine Norm-Änderung, kein ADR.

**Autor:** Planner. **Datum:** 2026-09-28.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Die vier Vorbereitungs-Schritte der Release-Prozedur
([`releasing.md`](../../../user/releasing.md) §Prozedur, Schritte 1–4) laufen
für den Tag `v0.2.5` durch: die Vorlage zeigt auf den neuen Tag, die sechs
Plattform-Assets samt `SHA256SUMS` sind gebaut, die Assets sind gegen die
Prüfsummen verifiziert, der Pin (`TRAEGER_TAG` + sechs `TRAEGER_SHA256_*`)
zeigt im selben Commit auf den geschnittenen Stand, und `make gates` läuft
grün auf genau diesem Stand — bevor irgendetwas gepusht oder getaggt wird.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Tag-Push und Asset-Publikation** (Schritt 5 der Prozedur) — **anderer
  Vorgang, explizit ausgenommen:** `git push origin v0.2.5` löst die echte
  Veröffentlichung aus (Release-Workflow baut auf allen sechs Runnern und
  publiziert acht Assets). Das ist eine vom Auftraggeber gesondert
  freizugebende Handlung, keine Implementer-Arbeit — dieser Slice liefert den
  release-bereiten, lokal getesteten Baum, nicht die Veröffentlichung.
- **CI am Tag abwarten, Tap-Nachzug, Meldung des vollzogenen Schnitts**
  (Schritte 6–8) — **anderer Vorgang, folgt zeitlich:** alle drei setzen
  voraus, dass Schritt 5 bereits gelaufen ist (der Tag existiert, das
  Formel-Asset ist veröffentlicht); ohne Tag-Push haben sie kein Objekt.
- **Ein Signier-Schritt für die Assets** — **Bestand bleibt bewusst stehen:**
  [`releasing.md`](../../../user/releasing.md) §Grenze dokumentiert diese
  Grenze bereits (Prüfsummen, keine Signatur); ihr Re-Evaluierungs-Trigger
  steht in [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md)
  und wird von diesem Slice nicht gezogen.
- **Der Release-Notes-Text** (Titelzeile, Stand, Assets, Grenze — Teil von
  Schritt 5) — **anderer Vorgang:** er wird erst nach der Publikation gesetzt
  (`gh release edit`) und braucht den veröffentlichten Stand als Grundlage;
  vor Schritt 5 gibt es nichts zu beschreiben.

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

- [ ] **Liefer-Punkt 1 — Vorlage gesetzt, Assets gebaut:** `TRAEGER_TAG` in
      `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in
      `test/traeger-fetch.bats` zeigen auf `v0.2.5`
      ([`releasing.md`](../../../user/releasing.md) §Prozedur Schritt 1).
      `make release-artifacts DEST=dist TRAEGER_VERSION=v0.2.5` baut die
      sechs Plattform-Binaries
      ([`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix))
      und erzeugt `dist/SHA256SUMS`. Rote Gegenprobe: fehlt ein Asset der
      Matrix, färbt `test/release-matrix.bats` rot (dieselbe Klasse, mit der
      der Vorgänger-Slice den Matrix-Test bindet); baut eine Plattform nicht
      (Vorfall des Vorgänger-Schnitts: `syscall.Flock` ohne Build-Tag brach
      zwei der sechs Windows-Assets), bricht der `docker build`-Schritt des
      Rezepts selbst mit Exit ≠ 0. **Beleg:** `grep -n 'TRAEGER_TAG'
      internal/emit/templates/enforce/traeger.mk test/traeger-fetch.bats` →
      beide `v0.2.5`; `ls dist/` → sechs Binaries + `SHA256SUMS`.
- [ ] **Liefer-Punkt 2 — Assets verifiziert, Pin gezogen:**
      `bash harness/tools/release-sums.sh verify dist` hält die gebauten
      Assets gegen die im selben Lauf erzeugte `SHA256SUMS`
      ([`releasing.md`](../../../user/releasing.md) §Prozedur Schritt 3).
      Die sechs gemessenen Digests aus `dist/SHA256SUMS` werden zu
      `TRAEGER_TAG`/den sechs `TRAEGER_SHA256_*`-Werten im `Makefile`, fail-closed
      gekoppelt an den Fragment-Tag in `internal/emit/templates/enforce/traeger.mk`
      (Schritt 2). Rote Gegenprobe: weicht einer der sechs Digest-Pins vom
      Asset ab, bricht der Kopplungs-/Negative-Fall in
      `test/traeger-fetch.bats` (dieselbe Klasse wie beim Vorgänger-Slice,
      Fall 1); fehlt die `SHA256SUMS` oder weicht eine Zeile ab, bricht
      `release-sums.sh verify` selbst mit Exit ≠ 0, bevor der Pin gezogen
      wird. **Beleg:** `grep -nE '^TRAEGER_(TAG|SHA256)' Makefile` → alle
      sieben Werte auf `v0.2.5` bzw. dessen sechs Digests; Exit-Code von
      `release-sums.sh verify dist`.
- [ ] **Liefer-Punkt 3 — Gates am Tag-Baum:** `make gates` läuft grün auf
      genau dem Commit, der den Tag tragen wird — **vor** jedem Push
      ([`releasing.md`](../../../user/releasing.md) §Prozedur Schritt 4,
      §Belegbasis). Rote Gegenprobe: jeder rote Teil-Gate (`docs-check`,
      `test`, `lint`, `build`, `shell-lint`, `ci-lint`, `baseline-verify`,
      `span-check`) bricht `make gates` mit Exit ≠ 0 und benennt die
      Ursache in seiner eigenen Ausgabe. **Beleg:** `.harness/state/gates-passed.diffsha`
      deckungsgleich mit `bash harness/tools/working-tree-hash.sh` auf dem
      Pin-Commit (derselbe Nachweis-Mechanismus wie beim Stop-Hook).
- [ ] `make gates` grün. **Beleg:** wie Liefer-Punkt 3 — derselbe Lauf.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update, falls ein öffentlicher Vertrag berührt ist — dieser Slice
      ändert keinen; `releasing.md` selbst bleibt unverändert (die Prozedur
      ist bereits vollständig beschrieben, dieser Slice führt sie nur aus).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register (`../reconciliation.md`) fortgeschrieben,
      **falls** dieser Slice einen Inventur-Fund auflöst — entfällt: dieses
      Repo hat keinen Brownfield-Bootstrap und führt die Register-Datei
      nicht.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues
      Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen
      `evidence/`; **kein Zähler wird gesetzt**, er folgt aus den Dateien.
      Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen /
      weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im
      Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von
      der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/traeger.mk` (`TRAEGER_TAG`) | update | Schritt 1: die Vorlage ist im Binary eingebettet — ein Bau vor diesem Zug trägt den Tag des vorigen Schnitts |
| `test/traeger-fetch.bats` | update | Schritt 1: Tag-Wert der bats-Fälle auf `v0.2.5`, Kopplungs-Fall bleibt scharf |
| `Makefile` (`TRAEGER_TAG`, sechs `TRAEGER_SHA256_*`) | update | Schritt 2: Pin zeigt im selben Vorgang auf den geschnittenen Stand, fail-closed gekoppelt ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `dist/` (lokaler Bau-Output, nicht committet) | neu | Schritt 1+3: sechs Plattform-Binaries + `SHA256SUMS` aus `make release-artifacts`, verifiziert mit `release-sums.sh verify` |

**Kein Code-Diff jenseits der Pin-/Vorlage-Stellen.** Die 306+ Commits seit
`v0.2.4` (`git log --oneline v0.2.4..HEAD --no-merges | wc -l`) liegen bereits
auf `main`; dieser Slice liefert kein Feature und keinen Fix — er zieht Tag
und Pin auf den vorhandenen Stand und verifiziert ihn.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): WIP-Limit frei (`in-progress/` führt
aktuell nur `roadmap.md`, kein Slice), Verantwortlicher gesetzt, kein anderer
Release-Schnitt läuft parallel.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Die
  Plattform-Matrix-Brüche (Risiko 1) verlangen eine strukturelle Code-Änderung
  jenseits eines einzelnen Build-Tags (Beispiel des Vorgänger-Schnitts: eine
  neue je-OS-Datei für einen POSIX-Syscall) — dann wird die Code-Änderung ein
  eigener Slice, und dieser hier bleibt reiner Pin-Nachzug.
- `in-progress` → `open` (blockiert — Carveout?): Kein Docker-Build-Kanal
  erreichbar (Netz-Ausfall beim Pull der Build-Images), oder eine der sechs
  Plattform-Assets baut dauerhaft nicht und kein Fix ist in Reichweite dieses
  Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig mit roten Gegenproben der drei Liefer-Punkte belegt, und
`make gates` grün auf dem Commit, der den Pin-Nachzug trägt (Beleg:
`.harness/state/gates-passed.diffsha` deckungsgleich mit dem committeten
Stand). **Ausdrücklich NICHT Closure-Trigger:** ein gepushter Tag, ein
CI-Lauf am Tag oder ein Tap-Nachzug — die liegen außerhalb der DoD (§1).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Plattform-Matrix-Bau bricht.** Der Vorgänger-Schnitt (`v0.2.1`) brach am
  ersten Lauf an `syscall.Flock` ohne Build-Tag (zwei der sechs Windows-Assets
  bauten nicht) — seit `v0.2.4` sind plattformnahe Stellen erneut angefasst
  (Span-Erfassung, `program`-Feld hinter Navigationssegmenten/`cd`-Set,
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)), ohne dass ein
  Plattform-Bau dazwischen lief. — **Ausgang:** <eingetreten: der Bau bricht,
  ein plattformspezifischer Fix wird Teil dieses Slice oder ein Folge-Slice
  trägt ihn | entfallen: alle sechs Assets bauen im ersten Lauf>
- **CI-Race beim Merge des Pin-Commits auf `main`, bevor der Tag existiert.**
  Landet der Pin-Nachzug (Liefer-Punkt 2) auf `main`, bevor Schritt 5 (Tag-Push,
  außerhalb dieses Slice) gelaufen ist, fragt der `ci`-Lauf im `full-smoke`
  `traeger-fetch` gegen `v0.2.5` — noch unveröffentlicht — und fällt mit 404;
  bekannte Klasse
  [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)
  (bisher belegt an der Tag-Push-Form derselben Klasse, `v0.2.2`). — **Ausgang:**
  <weiter offen: die Struktur-Entscheidung der Beobachtung steht weiter aus,
  operativer Ausgang bleibt der Re-Run nach Schritt 5 | eingetreten: neues
  Auftreten wird als `evidence/`-Datei ergänzt>
- **Belegbasis-Lücke zwischen Slice-Closure und dem tatsächlichen, separat
  freigegebenen Tag-Push.** Der `make gates`-Beleg dieses Slice
  (`.harness/state/gates-passed.diffsha`) ist lokaler, gitignorierter
  Zustand und reist nicht mit dem Tag
  ([`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
  Landen zwischen dieser Closure und dem späteren Tag-Push weitere Commits auf
  `main`, ist der verifizierte Stand dieses Slice nicht mehr der Stand, den
  der Tag trägt. — **Ausgang:** <entfallen: Tag-Push erfolgt auf demselben
  Commit, den dieser Slice verifiziert hat | eingetreten: eine erneute
  `make gates`-Verifikation unmittelbar vor dem Tag-Push wird nötig, außerhalb
  der DoD dieses Slice>
- **d-check-Pin-Sprung (MR-073, `v0.77.0`→`v0.79.0`) liegt kurz vor diesem
  Slice.** Ein neues Modul oder eine neue `structure`-Bedingung könnte
  `docs-check` am Tag-Baum anders bewerten als beim letzten grünen Lauf. —
  **Ausgang:** <entfallen: `make gates` bleibt grün, keine neue Diskrepanz |
  eingetreten: Befund wird im laufenden Slice behoben>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

<!-- Erst nach Abschluss füllen. -->

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `*` (gesamtes Repo) — die
Pin-Stellen (`Makefile`, Emissions-Vorlage) — und `harness/tools/` —
`release-sums.sh` (Modus `verify`, unverändert genutzt). Beide erfüllen die
Schwelle ≥ 2 von 3 Achsen (Inventur-Berührung: ja; mehrere Dateien: ja;
Aussagen-Berührung: ja — der Pin-Stand). Keine der beiden ist zu grob — die
Modus-Deklaration in `harness/conventions.md` führt beide namentlich.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen am
2026-09-28 (`ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l` →
**201**), thematisch gefiltert auf Release/Tag/Pin/Träger. Drei Treffer mit
Bezug zu diesem Vorgang:
[`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)
(1×, *offen*) — als Risiko 3 übernommen;
[`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)
(benannt, nicht gezählt — kein Beleg, `state.md` nennt die Struktur-Entscheidung
noch offen; [`ADR-0069`](../../adr/0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)) —
als Risiko 2 übernommen;
[`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md)
(1×, *offen*) — betrifft die Kennung reaktiver Slices, die selbst einen
Werkzeug-Stand im Namen tragen; dieser Slice trägt keinen Stand in seiner
Kennung und ist kein Fall dieser Klasse, kein Ausgang berührt. Kein weiterer
Eintrag berührt die Sub-Areas mit dieser Berührung an der Schwelle.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF (`*` und
`harness/tools/` stehen in der Modus-Deklaration als Greenfield); kein
BF/Hybrid-Block.
