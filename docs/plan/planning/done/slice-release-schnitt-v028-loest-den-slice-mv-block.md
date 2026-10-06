# Slice slice-release-schnitt-v028-loest-den-slice-mv-block: Der Release-Schnitt `v0.2.8` liefert `slice-mv` am exakten Namen und die emittierten Änderungen seit `v0.2.7` aus

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Die Closure-Bedingung — Tag veröffentlicht, CI und Tap-Kontrolle grün — ist
die DoD dieses Slice selbst (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht; dieselbe Einordnung wie
[`slice-release-schnitt-v027-liefert-den-altbestand-pfad`](../done/slice-release-schnitt-v027-liefert-den-altbestand-pfad.md)).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin trägt Version + sha256),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die sechs Assets),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 (Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (`SHA256SUMS` als Release-Asset),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (Tap-Nachzug),
[`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 5 (kein Release-Tag zwischen Sprung-Vollzug und dem Vorgang zum emittierten `targets`).
Auslöser: Auftrag des Auftraggebers — ein Adopter ist durch den `slice-mv`-Fehler blockiert; der Fix liegt in
[`slice-mv-findet-die-quelle-am-exakten-namen`](../done/slice-mv-findet-die-quelle-am-exakten-namen.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-06.

---

## 1. Ziel und Abgrenzung

**Ziel:** Das Release `v0.2.8` ist veröffentlicht und vollzogen gemeldet, **bevor** der Baseline-Sprung auf `v6.16.0` in Arbeit geht: Träger und emittierte Vorlagen tragen jeden Gegenstand, der seit `v0.2.7` in `internal/` gelandet ist, der Pin zeigt auf den geschnittenen Stand, und das Benutzerhandbuch beschreibt den Ist-Zustand.

**Gegenstände des Schnitts** — gemessen mit `git log --oneline v0.2.7..HEAD -- internal/ cmd/` (zwölf Commits, `cmd/` ohne Treffer), je Gegenstand der geschlossene Slice:

| Gegenstand (im Ziel sichtbar) | Commits | Slice |
|---|---|---|
| `make slice-mv` findet die Quelle zuerst am exakten Namen (`internal/emit/templates/enforce/slice-mv.sh`) | `a53632ba` | [`slice-mv-findet-die-quelle-am-exakten-namen`](../done/slice-mv-findet-die-quelle-am-exakten-namen.md) |
| emittierte `.d-check.yml` trägt `structure` mit der Zellenregel (Spalten Vertrag/Tut was unter §Sensors, ≤ 200 Zeichen) samt Kopfkommentar | `b81fbc47`, `0af61162` | [`slice-zellenlaenge-sensor-geht-ins-ziel`](../done/slice-zellenlaenge-sensor-geht-ins-ziel.md) |
| Bootstrap legt den Ordner `sensors/` unter `harness/` im Ziel an (mit `.gitkeep`) | `32892d91` | [`slice-sensors-ordner-entsteht-im-ziel`](../done/slice-sensors-ordner-entsteht-im-ziel.md) |
| emittierte Commands tragen die Platzhalter-Form `<Kennung>`, Wächter über alle Commands | `915022b8`, `0f536697` | [`slice-emittierte-commands-tragen-die-platzhalter-form-kennung`](../done/slice-emittierte-commands-tragen-die-platzhalter-form-kennung.md) |
| emittierte `commit-msg`-Prüfung erkennt benannte Slices (als eigenes Wort) | `2085fc00`, `c563d598` | [`slice-emittierte-commit-pruefung-erkennt-benannte-slices`](../done/slice-emittierte-commit-pruefung-erkennt-benannte-slices.md) |
| emittierter d-check-Default-Pin `v0.79.0` → `v0.81.0` → `v0.82.0`, Prosa zur leeren Range in `history-range-guard.sh` | `dd26964c`, `1ff70b83`, `6fb5058f` | [`slice-d-check-pin-macht-den-range-leerfall-laut`](../done/slice-d-check-pin-macht-den-range-leerfall-laut.md), [`slice-d-check-pin-nimmt-die-authority-liste`](../done/slice-d-check-pin-nimmt-die-authority-liste.md) |
| Go `1.27.1` und golangci-lint `v2.14.0` im Go-Skelett (`internal/gen/golang.go`) | `911f4a93` | [`slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140`](../done/slice-go-und-golangci-pin-ziehen-auf-127-1-und-v2140.md) |

**Versionswahl:** `v0.2.8` ist der Patch-Schritt nach `v0.2.7` (`git tag --sort=-creatordate | head -1`); die Tag-Wahl ist Entscheidung des Auftraggebers. Wählt er einen anderen, ersetzt der Implementer `v0.2.8` an allen Stellen von §3.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Weiterer Funktionsinhalt — Schnitt nach Lieferwert: ausgeliefert wird, was in `done/` liegt; jede Programm- oder Vorlagen-Änderung wäre ein anderer Slice, und der Verifier hielte den Tag-Baum nicht mehr gegen einen geprüften Stand.
- Der Baseline-Sprung auf `v6.16.0` — anderer Vorgang; nach [`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 5 liegt dieser Tag **vor** ihm, nicht in ihm.
- Betriebs-Kommandos des Ziels, die das Handbuch heute nicht nennt, außer `slice-mv` (etwa `hooks-install`) — Folge-Slice [`slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand`](../open/slice-191-benutzerhandbuch-zeigt-den-vollstaendigen-bestand.md) trägt die Vollständigkeit; hier nur, was dieser Release ändert.
- Ein Signier-Schritt für die Assets — Bestand bleibt bewusst stehen: [`releasing.md`](../../../user/releasing.md) §Grenze führt ihn.
- Eine Struktur-Entscheidung zum CI-Rennen gegen die Publikation — offene Beobachtung; der Schnitt fährt den operativen Ausgang (Re-Run), er entscheidet nichts.
- Anlage oder Rotation des Repo-Secrets `HOMEBREW_TAP_GITHUB_TOKEN` — außerhalb der Prozedur ([`releasing.md`](../../../user/releasing.md) Schritt 7); vom Auftraggeber als gesetzt bestätigt.

## 2. Definition of Done

Liefer-Punkte (drei):

- [x] **L1 — Tag-Baum vorbereitet und verifiziert** (Schritte 1 bis 4 der Prozedur). `TRAEGER_TAG` in `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in `test/traeger-fetch.bats` zeigen auf `v0.2.8`; `make release-artifacts DEST=dist TRAEGER_VERSION=v0.2.8` baut die sechs Binaries und `dist/SHA256SUMS`; `bash harness/tools/release-sums.sh verify dist` endet mit Exit 0; `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im `Makefile` tragen den Tag und die gemessenen Digests; `make gates` ist grün auf dem Commit, der den Tag tragen wird (Stempel deckungsgleich mit `bash harness/tools/working-tree-hash.sh`).
  - Rot (ohne Netz): ein Byte eines Assets in einer Kopie von `dist/` ändern — `release-sums.sh verify` endet mit Exit ≠ 0 und nennt die Datei; den Tag der Vorlage vom Tag im `Makefile` trennen — die Kopplung in `test/traeger-fetch.bats` färbt rot.
  - Rot an der realen Quelle: einen Digest im realen `Makefile` verfälschen und `bats test/traeger-fetch.bats` fahren. Färbt kein Fall, ist das die bekannte Lücke „realer `Makefile`-Digest ungebunden"; der Implementer benennt sie im Bericht, statt sie durch grüne Fixture-Fälle zu verdecken.
  - Rot für den Anlass: am gebauten Linux-amd64-Binary ein Ziel bootstrappen, darin zwei Slices anlegen, deren Namen Präfix voneinander sind, und `make slice-mv SLICE=<kürzerer> TO=next` fahren — der Lauf bewegt genau die exakte Datei; mit dem Binary von `v0.2.7` (`make traeger-fetch` vor dem Pin-Zug oder Release-Asset) zeigt derselbe Aufruf den Fehler des Adopters. Belegt, dass der Tag das Programm des Fixes trägt.
- [x] **L2 — Handbuch im Ist-Zustand** (`docs/user/benutzerhandbuch.md`, gemessen am 2026-10-06):
  - Stand: `grep -n 'v0\.2\.7' docs/user/benutzerhandbuch.md` → Zeilen `**Software-Stand:**` (zweimal) und „aktuell ausgeliefert wird" auf `v0.2.8`; die `v0.2.4`-Aussage in §Ein geschichtetes Grundgerüst wählen bleibt als Aussage über den damaligen Stand.
  - `slice-mv`: `grep -c 'slice-mv' docs/user/benutzerhandbuch.md` → `0`. §Betriebs-Operationen bekommt die Zeile `make slice-mv SLICE=slice-<Kennung> TO=<open|next|in-progress|done>` (Lifecycle-Wechsel samt Verweis-Nachzug, Quelle am exakten Namen, kein Träger nötig, kein Gate); die Zahlwörter „Vier Betriebs-Operationen" (Kopf), „zwei der vier" (§Das aufgesetzte Repository prüfen) und „Alle vier" (§Betriebs-Operationen) werden nachgezogen.
  - Zellenlänge und Sensors-Ordner: `grep -c -i 'zelle\|harness/sensors' docs/user/benutzerhandbuch.md` → `0`. §Zeilenenden und Kennungs-Form nennt den `structure`-Block der `.d-check.yml` (Zellen der Spalten Vertrag und Tut was unter `## Sensors (Feedback-Gates)` in `harness/README.md` ≤ 200 Zeichen, längere Prosa nach `harness/sensors/<target>.md`); der Baum in §Phase 1 nennt `harness/sensors/`.
  - Commit-Kennung: das Handbuch nennt die Kennungs-Menge der `commit-msg`-Prüfung nicht (`grep -n 'commit-msg' docs/user/benutzerhandbuch.md` → nur Datei- und Meldungs-Nennungen). §Zeilenenden und Kennungs-Form sagt, dass die Prüfung einen benannten Slice `slice-<name>` als eigenes Wort als Kennung annimmt.
  - Ohne Handbuch-Zeile (gemessen, nichts nachzuziehen): Platzhalter-Form der Commands, d-check-Pin und Go/golangci-Versionen — das Handbuch nennt keine dieser Versionen (`grep -n -E 'v0\.8[0-9]\.|1\.27|v2\.1[0-9]' docs/user/benutzerhandbuch.md` → leer).
  - Nur Ist-Zustand: keine Chronik, keine Prognose. Rot: `make docs-check` bei totem Link/Anker im geänderten Abschnitt; dass die Aussagen stimmen, hält kein Gate — der Reviewer liest sie gegen `slice-mv.mk`, `d-check.yml` und `commit-msg-traceability.sh` der Vorlagen am Tag-Baum.
- [x] **L3 — Veröffentlicht, belegt, gemeldet** (Schritte 5 bis 8). Erst `main` gepusht, dann der Tag `v0.2.8`, nachdem Reviewer und Verifier am Tag-Baum bestanden haben und ein erneuter `make gates` auf dem finalen Commit grün war; der Release trägt acht Assets (`gh release view v0.2.8 --json assets --jq '.assets | length'` → `8`); `make traeger-fetch` hält das veröffentlichte Asset gegen den Pin; `ci` an `main` und am Tag grün (nach der Publikation gefallene `full-smoke`-Jobs per `gh run rerun --failed`); der Job `tap` (Secret `HOMEBREW_TAP_GITHUB_TOKEN`) ist grün und `make tap-check TAG=v0.2.8` endet mit Exit 0, die Meldung trägt dessen Ausgabezeile; der Release-Text trägt Stand, Assets, Grenze und die Gegenstände aus §1.
  - Rot (Pin passt nicht zum Asset): ein verfälschter `TRAEGER_SHA256_*` lässt `make traeger-fetch` mit Exit ≠ 0 enden, bevor etwas abgelegt wird — nach der Publikation fahren und im Bericht belegen; bleibt er ungefahren, steht das als Lücke in §7.
  - Fällt der Job `tap`: `make tap-nachzug TAG=v0.2.8` mit `TAP_TOKEN` des Auftraggebers, danach `make tap-check`.

Gate-Läufe und Closure-Pflichten:

- [x] `make gates` grün (am Tag-Baum, siehe L1).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), Verifier-Bericht am Tag-Baum **vor** dem Tag-Push — kein Self-Review.
- [x] Doku-Update: Handbuch (L2); [`releasing.md`](../../../user/releasing.md) bleibt unverändert, solange die Prozedur trägt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag, vom Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/traeger.mk` (`TRAEGER_TAG`) | update | Schritt 1: Vorlage ist eingebettet; der Bau trägt sonst den Tag des Vorgängers |
| `test/traeger-fetch.bats` | update | Schritt 1: Tag-Wert der Fälle, Kopplungs-Fall bleibt scharf |
| `Makefile` (`TRAEGER_TAG`, sechs `TRAEGER_SHA256_*`) | update | Schritt 2: Pin zeigt im selben Commit auf den geschnittenen Stand ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `docs/user/benutzerhandbuch.md` | update | L2: Stand, `slice-mv`-Zeile, Zellenregel, Sensors-Ordner, Commit-Kennung |
| `dist/` (lokal, nicht committet) | neu | Schritt 1 und 3: Assets und `SHA256SUMS` |

Reihenfolge der Rollen:

1. **Implementer** — Schritte 1 bis 3 und L2: ein Commit mit Vorlage, Pin und Handbuch; **kein** Push, **kein** Tag.
2. **Reviewer** — Diff gegen diesen Plan und die Prozedur; liest die Handbuch-Aussagen gegen die Vorlagen am Tag-Baum.
3. **Verifier** — am Tag-Baum, vor dem Tag-Push: Digests eigenständig nachgerechnet, `make gates` frisch auf dem finalen Commit, bewusstes Brechen des realen Pins und das Anlass-Rot aus L1.
4. **Push und CI** (Implementer-Kontext, zweiter Lauf) — Schritte 5 bis 7, erst nach grünem Verifier-Bericht **und** grünem `make gates` auf dem dann finalen Commit (Report-Commits ändern den Baum nach dem Stempel). Reihenfolge: `main` zuerst, dann der Tag; `ci` fällt im `full-smoke` mit 404, solange der `release`-Lauf nicht publiziert hat — danach Re-Run. Der Tag-Push ist nach außen wirksam; der Auftrag des Auftraggebers deckt ihn.
5. **Planner-Closure** — nach Schritt 8 (Meldung), in eigenem Commit.

## 4. Trigger

**Start** (`next` → `in-progress`): alle Slices der Tabelle in §1 liegen in `done/` (`ls docs/plan/planning/done | grep -c -E 'slice-mv-findet-die-quelle-am-exakten-namen|zellenlaenge-sensor-geht-ins-ziel|sensors-ordner-entsteht-im-ziel|platzhalter-form-kennung|commit-pruefung-erkennt-benannte|range-leerfall-laut|nimmt-die-authority-liste|127-1-und-v2140'` → `8`), `git tag --sort=-creatordate | head -1` nennt `v0.2.7`, **und** kein Slice des Baseline-Sprungs auf `v6.16.0` liegt in `in-progress/`. **Bedingung aus [`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) Festlegung 5:** der Tag `v0.2.8` entsteht, bevor der Sprung-Slice in Arbeit geht — sonst läge ein Release-Tag im Intervall zwischen Sprung-Vollzug und dem Vorgang zum emittierten `targets`.

**Rückführungen:**

- `in-progress` → `next`: ein Plattform-Bau bricht und verlangt eine Code-Änderung jenseits eines Build-Tags — sie wird eigener Slice, dieser bleibt reiner Schnitt.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar; oder der Sprung-Slice geht vor dem Tag in Arbeit — dann entscheidet der Auftraggeber zwischen Release nach dem `targets`-Vorgang und dem Intervall als Grenze in der Release-Notiz ([`ADR-0078`](../../adr/0078-ziel-fassung-regiert-den-sprung-v6160.md) §Re-Evaluierungs-Trigger).

## 5. Closure-Trigger

DoD vollständig, Verifier-Bericht am Tag-Baum ohne Blocker, `ci` an `main` und am Tag grün, `make tap-check TAG=v0.2.8` mit Exit 0, Meldung an den Auftraggeber (Adopter entsperrt) und Closure-Notiz mit Lerneintrag. Nicht Closure-Trigger: ein gepushter Tag allein.

## 6. Risiken und offene Punkte

- Ein Plattform-Asset baut nicht — **Ausgang:** entfallen, wenn alle sechs im ersten Lauf bauen; sonst eingetreten → Rückführung nach §4.
- Der Gates-Beleg reist nicht mit dem Tag; Report-Commits ändern den Baum nach dem Stempel — **Ausgang:** eingetreten, strukturell: erneuter `make gates` auf dem finalen Commit ist Teil von L3 ([`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
- `ci` fällt im `full-smoke` mit 404, bis der `release`-Lauf publiziert hat — **Ausgang:** weiter offen: → [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md); operativ `main` zuerst, dann Tag, Re-Run.
- Der Job `tap` scheitert (Secret abgelaufen) — **Ausgang:** eingetreten → lokaler Ausfallweg mit `TAP_TOKEN`; sonst entfallen.
- Der reale `Makefile`-Digest ist ungebunden; kein Fixture-Fall misst ihn, den Pin gegen das Asset hält erst `make traeger-fetch` nach der Publikation — **Ausgang:** bekannte Lücke; zählt als Beleg zu [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md), sofern der Rot-Versuch aus L1 keinen Fall färbt.
- Der Sprung-Slice geht vor dem Tag in Arbeit — **Ausgang:** eingetreten → Rückführung nach §4; sonst entfallen.

## 7. Closure-Notiz

- **Was hat funktioniert:** Tag `v0.2.8` liegt am Commit `6167b374` (main, dann Tag gepusht; Gates-Stempel deckungsgleich mit `bash harness/tools/working-tree-hash.sh` am sauberen Baum); der `release`-Lauf ist grün samt Job `tap`; der Release trägt 8 Assets (`gh release view v0.2.8 --json assets --jq '.assets | length'` → `8`); `make traeger-fetch` Exit 0 („Digest verifiziert", Release `v0.2.8`); Rot: `make traeger-fetch TRAEGER_SHA256_LINUX_AMD64=000…` Exit 2 „Digest-Abweichung"; `make tap-check TAG=v0.2.8` Exit 0 („gleich"); Release-Text per `gh release edit` gesetzt; `ci` auf main und Tag grün nach `gh run rerun --failed` (`gh run list`). Review ohne HIGH/MEDIUM, F-1/F-3 behoben; Verifikation: L1 und L2 bestätigt (`docs/reviews/2026-10-06-release-v028-review.md`, `-verifikation.md`).
- **Was ging anders als geplant:** `ci` auf main und Tag fiel zunächst im `full-smoke` (`traeger-fetch` im frischen Klon vor der Publikation); operativer Ausgang war der Re-Run (Risiko 3).
- **Steering-Loop-Eintrag:** benannte Lücke, kein neuer Sensor: der reale `Makefile`-Digest ist von keinem Fall in `test/traeger-fetch.bats` gebunden; den Pin gegen das Asset hält allein `make traeger-fetch` nach der Publikation, dessen Rot-Seite hier gefahren ist. Träger bleibt der Lauf, der den Schnitt schreibt.
- **Beobachtungs-Register (`../observations/`):** Evidence-Datei zu [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) (realer Pin ungebunden, Verifikation); Evidence-Datei zu [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md) (Stand bleibt `offen`). [`BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht`](../observations/BEO-ALL/werkzeug-zelle-traegt-einen-ist-stand-der-vom-ausgelieferten-abweicht/observation.md): Review-F-1 ist derselbe Fund wie der vorhandene Beleg, kein weiteres Auftreten; der `traeger-fetch`-Fall ist behoben, der `artifact-host`-Fall steht — Stand `offen`, in `state.md` nachgezogen.
- **Folge-Slices:** keine.
- **Risiken aus §6:** alle sechs tragen ihren Ausgang am Risiko; bestätigt: 1 entfallen (sechs Binaries gebaut), 2 eingetreten (strukturell; `make gates` am finalen Commit grün), 3 weiter offen (Register), 4 entfallen (Job `tap` grün), 5 weiter offen (Register), 6 entfallen.
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`): Pin-Stellen, Emissions-Vorlage und Nutzerdoku; die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Zähler = Zahl der Dateien unter `evidence/` (`ls <eintrag>/evidence | wc -l`), gemessen am 2026-10-06:
- [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md) — 3, Stand `offen`. Gegenstand sind Dockerfile-`@sha256`-Digests und Wert-Fallbacks der Smoke-Skripte, nicht der Träger-Pin dieses Schnitts. Ob dieser Release einen Ausgang braucht, ist Lese-Schritt der Welle-Closure; hier nur gesichtet.
- [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) — 5, verkörpert; als Risiko 5 übernommen.
- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md) — 1; als Risiko 3 übernommen.
- [`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md) — 1; als Risiko 2 übernommen.
- [`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md) — 1; die Kennung dieses Slice trägt den Tag, der Release überholt ihn mit seinem eigenen Vollzug nicht.
- [`BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung`](../observations/BEO-ALL/zeilen-adressen-im-handbuch-wandern-mit-umstrukturierung/observation.md) — 1; L2 adressiert Abschnitte, nicht Zeilen.

alle berührten Sub-Areas GF
