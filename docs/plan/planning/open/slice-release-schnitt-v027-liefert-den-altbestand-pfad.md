# Slice slice-release-schnitt-v027-liefert-den-altbestand-pfad: Der Release-Schnitt `v0.2.7` liefert `archive-welle altbestand` im Träger und im emittierten Text aus

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Die Closure-Bedingung — Tag veröffentlicht, CI und Tap-Kontrolle grün — ist
die DoD dieses Slice selbst; ein repo-weites Mehr darüber hinaus gibt es nicht (Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht; dieselbe Einordnung wie
[`slice-release-schnitt-v025-bereitet-vor`](../done/slice-release-schnitt-v025-bereitet-vor.md)).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin trägt Version + sha256),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die sechs Assets),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 (Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (`SHA256SUMS` als Release-Asset),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (Tap-Nachzug),
[`ADR-0041`](../../adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (der Inhalt, den der Schnitt ausliefert).
Auslöser: Auftrag des Auftraggebers („für den emittierten Teil so schnell wie möglich ein neues Release").

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-10-05.

---

## 1. Ziel und Abgrenzung

**Ziel:** Das Release `v0.2.7` ist veröffentlicht und vollzogen gemeldet: Der Träger-Asset trägt den schreibenden Pfad von `archive-welle altbestand` ([`slice-archive-welle-altbestand-hat-einen-schreibenden-pfad`](../in-progress/slice-archive-welle-altbestand-hat-einen-schreibenden-pfad.md)), die emittierte Vorlage nennt den Schlüssel ([`slice-emittierte-archivierung-kennt-den-altbestand`](../open/slice-emittierte-archivierung-kennt-den-altbestand.md)), der Pin zeigt auf den geschnittenen Stand, und das Benutzerhandbuch beschreibt den Ist-Zustand.

**Versionswahl:** `v0.2.7` ist der Patch-Schritt nach `v0.2.6` (`git tag --sort=-creatordate | head -1`). Eine ausdrückliche Versionsregel trägt weder [`releasing.md`](../../../user/releasing.md) noch [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) oder [`ADR-0063`](../../adr/0063-das-werkzeug-sagt-seine-fassung.md) (`grep -n -i 'semver\|versionsregel' docs/user/releasing.md docs/plan/adr/0058* docs/plan/adr/0063*` → leer); die Tag-Wahl ist Entscheidung des Auftraggebers. Wählt er einen anderen Tag, ersetzt der Implementer `v0.2.7` an allen Stellen von §3.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Weiterer Funktionsinhalt — Schnitt nach Lieferwert: der Slice liefert aus, was beide Träger-Slices fertig haben; jede Änderung am Programm oder an Vorlagen wäre ein anderer Slice, und der Verifier hielte den Tag-Baum nicht mehr gegen einen geprüften Stand.
- `archive-slice` ([`ADR-0077`](../../adr/0077-wellenlose-slices-archivieren-bei-der-slice-closure.md), `Proposed`) — ohne angenommene ADR keine Adresse; der Altbestand-Lauf ist dessen Voraussetzung, nicht umgekehrt.
- Die Anwendung des Altbestand-Laufs auf den realen Bestand dieses Repos — anderer Vorgang (Arbeit am Bestand, nicht am Werkzeug); der Release macht den Lauf erst möglich.
- Ein Signier-Schritt für die Assets — Bestand bleibt bewusst stehen: [`releasing.md`](../../../user/releasing.md) §Grenze führt ihn, sein Trigger steht in [`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md).
- Eine Struktur-Entscheidung zum CI-Rennen gegen die Publikation — offene Beobachtung ([`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)); der Schnitt fährt den operativen Ausgang (Re-Run), er entscheidet nichts.
- Die Anlage oder Rotation des Repo-Secrets `HOMEBREW_TAP_GITHUB_TOKEN` — liegt nach [`releasing.md`](../../../user/releasing.md) Schritt 7 außerhalb der Prozedur.

## 2. Definition of Done

Liefer-Punkte (drei):

- [ ] **L1 — Tag-Baum vorbereitet und verifiziert** (Schritte 1 bis 4 der Prozedur). `TRAEGER_TAG` in `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in `test/traeger-fetch.bats` zeigen auf `v0.2.7`; `make release-artifacts DEST=dist TRAEGER_VERSION=v0.2.7` baut die sechs Binaries und `dist/SHA256SUMS`; `bash harness/tools/release-sums.sh verify dist` endet mit Exit 0; `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im `Makefile` tragen den Tag und die gemessenen Digests; `make gates` ist grün auf dem Commit, der den Tag tragen wird (Stempel `.harness/state/gates-passed.diffsha` deckungsgleich mit `bash harness/tools/working-tree-hash.sh`).
  - Rot (ohne Netz fahrbar): ein Byte eines Assets in einer Kopie von `dist/` ändern — `release-sums.sh verify` endet mit Exit ≠ 0 und nennt die Datei; den Tag in der Vorlage vom Tag im `Makefile` trennen — die Kopplung in `test/traeger-fetch.bats` färbt rot.
  - Rot an der realen Quelle: einen Digest im realen `Makefile` verfälschen und `bats test/traeger-fetch.bats` fahren. Färbt kein Fall, ist das die Lücke „Wächter misst die Fixture" ([`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)); der Implementer benennt sie im Bericht, statt sie durch grüne Fixture-Fälle zu verdecken. Ob der Pin zum Asset passt, belegt der Wächter nicht — das belegt erst `make traeger-fetch` nach der Publikation (L3).
- [ ] **L2 — Handbuch im Ist-Zustand.** `docs/user/benutzerhandbuch.md` nennt den ausgelieferten Stand und den Schlüssel: die Zeilen `**Software-Stand:**` und „aktuell ausgeliefert wird" (heute `v0.2.4`, obwohl `v0.2.5` und `v0.2.6` geschnitten sind: `grep -n 'v0\.2\.4' docs/user/benutzerhandbuch.md`) stehen auf `v0.2.7`, jede weitere Zeile mit `v0.2.4` ist geprüft und nachgezogen oder als Aussage über den damaligen Stand belassen; die Zeile `make archive-welle WELLE=<welle-id>` nennt `WELLE=altbestand` (wellenlose Slices unter `done/altbestand/`, Untergrenze vor der ersten Wellen-Archivierung). Das Handbuch trägt nur den Ist-Zustand: keine Chronik, keine Prognose.
  - Rot: `make docs-check` bricht bei totem Link/Anker im geänderten Abschnitt. Dass die Aussage stimmt, hält kein Gate — der Reviewer liest sie gegen den Usage-Text von `archive-welle` am Tag-Baum und gegen `archivierung.mk` der Vorlage.
- [ ] **L3 — Veröffentlicht, belegt, gemeldet** (Schritte 5 bis 8). Der Tag `v0.2.7` ist gepusht, nachdem Reviewer und Verifier am Tag-Baum bestanden haben und ein erneuter `make gates` auf dem finalen Commit grün war; der Release trägt acht Assets (`gh release view v0.2.7 --json assets --jq '.assets | length'` → `8`); `make traeger-fetch` hält das veröffentlichte Asset gegen den Pin; der `ci`-Lauf am Tag-Commit ist grün (gefallene `full-smoke`-Jobs nach der Publikation neu gestartet); `make tap-check TAG=v0.2.7` endet mit Exit 0, und die Meldung trägt dessen Ausgabezeile; der Release-Text trägt Stand, Assets, Grenze und die Änderungsbeschreibung (`gh release view v0.2.7 --json body --jq .body`).
  - Rot (Pin passt nicht zum Asset): ein verfälschter `TRAEGER_SHA256_*` im `Makefile` lässt `make traeger-fetch` mit Exit ≠ 0 und Digest-Abweichung enden, bevor etwas abgelegt wird; ein Tag, dessen Binary den Schlüssel nicht trägt, zeigt `archive-welle --vorschau altbestand` mit `[kein-schreib-pfad]` — der Beleg dafür, dass der Schnitt das Programm des Tags und nicht eine ältere Fassung trägt.
  - Nur mit Netz (und Docker) belegbar, deshalb nicht im lokalen Vorlauf: Schritte 5 bis 8 — `traeger-fetch`, Tag-Push, CI, `tap-check`. Nur mit Secret belegbar: der Job `tap` (Repo-Secret `HOMEBREW_TAP_GITHUB_TOKEN`, [`ADR-0073`](../../adr/0073-der-ort-des-tap-zugangsgeheimnisses-ist-das-repo-secret.md)); ob es gesetzt ist, ist offline nicht messbar. Fehlt es oder scheitert der Job, ist der Nachzug Handarbeit: `make tap-nachzug TAG=v0.2.7` mit `TAP_TOKEN` in der Umgebung des Aufrufers (Voraussetzung, die der Auftraggeber stellt), danach `make tap-check`.
  - Lücke, die bleibt: der Schreib-Pfad des Tap-Nachzugs ist gegen eine nachgebildete Schnittstelle geprüft; am realen Tap belegt ihn erst dieser Nachzug. Der Start-Smoke prüft, dass das Programm startet — nicht, dass `altbestand` auf einem realen Bestand richtig archiviert ([`releasing.md`](../../../user/releasing.md) §Prozedur Schritt 5).

Gate-Läufe und Closure-Pflichten:

- [ ] `make gates` grün (am Tag-Baum, siehe L1; Beleg nicht am Tag reisend, [`releasing.md`](../../../user/releasing.md) §Belegbasis).
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), Verifier-Bericht am Tag-Baum **vor** dem Tag-Push — kein Self-Review.
- [ ] Doku-Update: Handbuch (L2); [`releasing.md`](../../../user/releasing.md) bleibt unverändert, solange die Prozedur trägt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag, vom Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/traeger.mk` (`TRAEGER_TAG`) | update | Schritt 1: Vorlage ist eingebettet; der Bau trägt sonst den Tag des Vorgängers |
| `test/traeger-fetch.bats` | update | Schritt 1: Tag-Wert der Fälle, Kopplungs-Fall bleibt scharf |
| `Makefile` (`TRAEGER_TAG`, sechs `TRAEGER_SHA256_*`) | update | Schritt 2: Pin zeigt im selben Commit auf den geschnittenen Stand ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `docs/user/benutzerhandbuch.md` | update | L2: Stand und `archive-welle`-Zeile im Ist-Zustand |
| `dist/` (lokal, nicht committet) | neu | Schritt 1 und 3: Assets und `SHA256SUMS` |

Reihenfolge der Rollen:

1. **Implementer** — Schritte 1 bis 3 und L2, bis zur Tag-Vorlage: ein Commit mit Vorlage, Pin und Handbuch; **kein** Push, **kein** Tag.
2. **Reviewer** — Diff gegen diesen Plan und die Prozedur; liest die Handbuch-Aussage gegen den Träger.
3. **Verifier** — am Tag-Baum, bevor der Tag gepusht wird: Digests eigenständig nachgerechnet, `make gates` frisch auf dem finalen Commit, bewusstes Brechen des realen Pins (L1).
4. **Tag-Push und CI** (Implementer-Kontext, zweiter Lauf) — Schritte 5 bis 7, erst nach grünem Verifier-Bericht **und** grünem `make gates` auf dem dann finalen Commit (die Report-Commits ändern den Baum nach dem Stempel). Der Tag-Push veröffentlicht die Assets und ist nach außen wirksam; der Auftrag des Auftraggebers deckt ihn, ein anderer Anlass nicht. Push von `main` und Tag nicht gleichzeitig ohne die Erwartung, dass `ci` im `full-smoke` gegen die noch unveröffentlichte Publikation mit 404 fällt (Re-Run, Schritt 6).
5. **Planner-Closure** — nach Schritt 8 (Meldung), in eigenem Commit.

## 4. Trigger

**Start** (`next` → `in-progress`): beide Slices — [`slice-archive-welle-altbestand-hat-einen-schreibenden-pfad`](../in-progress/slice-archive-welle-altbestand-hat-einen-schreibenden-pfad.md) und [`slice-emittierte-archivierung-kennt-den-altbestand`](../open/slice-emittierte-archivierung-kennt-den-altbestand.md) — liegen in `done/` (beobachtbar: beide Dateien unter `docs/plan/planning/done/`, `ls docs/plan/planning/done | grep -c 'altbestand'` ≥ 2, und `git tag --sort=-creatordate | head -1` nennt noch `v0.2.6`). Sonst baute der Schnitt einen Träger ohne den Pfad oder eine Vorlage ohne den Text. `open → next` durch Priorisierung des Auftraggebers; `Verantwortlich:` wird dabei gesetzt.

**Rückführungen:**

- `in-progress` → `next`: ein Plattform-Bau bricht und verlangt eine Code-Änderung jenseits eines Build-Tags — sie wird eigener Slice, dieser bleibt reiner Schnitt.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar, oder einer der beiden Träger-Slices wird nach seiner Closure wieder geöffnet.

## 5. Closure-Trigger

DoD vollständig, Verifier-Bericht am Tag-Baum ohne Blocker, `ci` am Tag-Commit grün, `make tap-check TAG=v0.2.7` mit Exit 0 und Closure-Notiz mit Lerneintrag. Ausdrücklich nicht Closure-Trigger: ein gepushter Tag allein.

## 6. Risiken und offene Punkte

- Ein Plattform-Asset baut nicht (plattformnahe Stellen seit `v0.2.6` angefasst, kein Plattform-Bau dazwischen) — **Ausgang:** entfallen, wenn alle sechs im ersten Lauf bauen; sonst eingetreten → Rückführung nach §4.
- Der Gates-Beleg reist nicht mit dem Tag; Report-Commits ändern den Baum nach dem Stempel — **Ausgang:** eingetreten, strukturell: erneuter `make gates` auf dem finalen Commit vor dem Tag-Push ist Teil von L3 ([`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
- `ci` fällt im `full-smoke` mit 404, bis der Release-Lauf publiziert hat — **Ausgang:** weiter offen: → [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md); operativ Re-Run nach der Publikation.
- Der Job `tap` scheitert, weil das Repo-Secret fehlt oder das Token abgelaufen ist — **Ausgang:** eingetreten → lokaler Ausfallweg mit `TAP_TOKEN` des Auftraggebers; sonst entfallen. Offline nicht messbar.
- Der Pin-Wächter misst die Fixture, nicht den realen `Makefile`-Wert — **Ausgang:** weiter offen: → [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md), sofern der Rot-Versuch aus L1 keinen Fall färbt.
- Zwischen Schnitt und Handbuch-Update trägt das Handbuch eine Aussage, die der gepinnte Träger nicht deckt — **Ausgang:** entfallen: das Handbuch reist im Commit des Tag-Baums, der Ist-Zustand gilt ab der Publikation; die Meldung folgt erst danach.

## 7. Closure-Notiz

- **Was hat funktioniert:**
- **Was ging anders als geplant:**
- **Steering-Loop-Eintrag:**
- **Beobachtungs-Register (`../observations/`):**
- **Folge-Slices:**
- **Risiken aus §6:**
- **Drei Paarungen:**

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`): Pin-Stellen, Emissions-Vorlage und Nutzerdoku; die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen. Zähler = Zahl der Dateien unter `evidence/` (`ls <eintrag>/evidence | wc -l`), gemessen am 2026-10-05:
- [`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md) — 1; als Risiko 2 übernommen.
- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md) — 0, benannt, nicht gezählt; als Risiko 3 übernommen.
- [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) — 3, die Schwelle ist erreicht; ein weiterer Beleg aus diesem Schnitt zählt als vierter Vorgang, und gilt dann nach Baseline-Regelwerk `modul-06-roadmap.md` §Das Beobachtungs-Register die Prosa-Form als ausgeschöpft. Als Risiko 5 übernommen.
- [`BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht`](../observations/BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht/observation.md) — 4; das Fenster zwischen emittiertem Text und gepinntem Träger schließt dieser Schnitt, ein Beleg dafür ist in der Closure zu setzen.

alle berührten Sub-Areas GF
