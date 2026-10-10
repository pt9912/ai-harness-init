# Slice slice-release-schnitt-v070-liefert-kotlin-und-v6180: Der Release-Schnitt `v0.7.0` liefert das Kotlin-Skelett, die Baseline `v6.18.0` und die Pin-Sprünge aus

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
[`slice-release-schnitt-v028-loest-den-slice-mv-block`](../done/slice-release-schnitt-v028-loest-den-slice-mv-block.md)).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin trägt Version + sha256),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die sechs Assets),
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (Sprachskelett),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 (Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (`SHA256SUMS` als Release-Asset),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (Tap-Nachzug),
[`ADR-0088`](../../adr/0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) (Kotlin-Skelett).
Auslöser: Freigabe des Auftraggebers vom 2026-10-10 — ein Release wird vorbereitet.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** Das Release `v0.7.0` ist veröffentlicht und vollzogen gemeldet: Träger und emittierte Vorlagen tragen jeden Gegenstand, der seit `v0.6.0` in `internal/` und `cmd/` gelandet ist, der Pin zeigt auf den geschnittenen Stand, und das Benutzerhandbuch beschreibt den Ist-Zustand.

**Versionswahl:** `v0.7.0`, Minor-Schritt nach `v0.6.0` (`git tag --sort=-v:refname | head -1` → `v0.6.0`). Nach [`releasing.md`](../../../user/releasing.md) §Versionsnummer steigt `minor`, wenn ein Ziel etwas Neues bekommt oder sich anders verhält: hier eine neue Option (`--lang kotlin`), ein Sprung der adoptierten Baseline (`v6.17.0` → `v6.18.0`) und Pin-Sprünge, die Gates im Ziel ändern (d-check `v0.84.0` → `v0.86.1`, a-check `v0.23.0` → `v0.23.2`). Die Tag-Wahl ist Entscheidung des Auftraggebers; wählt er einen anderen, ersetzt der Implementer `v0.7.0` an allen Stellen von §3.

**Gegenstände des Schnitts** — gemessen mit `git log --oneline v0.6.0..HEAD -- internal/ cmd/` (17 Commits an HEAD `8e1b1691`), je Gegenstand der geschlossene Slice:

| Gegenstand (im Ziel sichtbar) | Slice |
|---|---|
| `--lang kotlin` / `add-lang kotlin`: JVM-Gradle-Skelett flach, hexslice mit Arch-Gate, Root-Bootstrap (`internal/gen/kotlin.go`) | [`slice-kotlin-flaches-skelett`](../done/slice-kotlin-flaches-skelett.md), [`slice-kotlin-hexslice-mit-arch-gate`](../done/slice-kotlin-hexslice-mit-arch-gate.md), [`slice-kotlin-root-bootstrap`](../done/slice-kotlin-root-bootstrap.md) |
| Ziel trägt keine Kennung dieses Repos; `archive-welle` nimmt die Commit-Kennung vom Aufrufer (`KENNUNG=<K>`) | [`slice-ziel-traegt-keine-kennung-dieses-repos`](../done/slice-ziel-traegt-keine-kennung-dieses-repos.md) |
| Baseline `v6.18.0` im Ziel; emittierter `reviews`-Block trägt die vier neuen Schlüssel (als Kommentar-Block) | [`slice-sprung-auf-v6180-wird-vollzogen`](../done/slice-sprung-auf-v6180-wird-vollzogen.md) |
| emittierter d-check-Default-Pin `v0.84.0` → `v0.86.1` | [`slice-d-check-pin-bringt-den-go-sicherheitsfix`](../done/slice-d-check-pin-bringt-den-go-sicherheitsfix.md) |
| emittierter a-check-Default-Pin `v0.23.0` → `v0.23.2` | [`slice-a-check-pin-bringt-den-go-sicherheitsfix`](../done/slice-a-check-pin-bringt-den-go-sicherheitsfix.md) |

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Der Schwachstellen-Scan der gepinnten Bilder ([`slice-gepinnte-bilder-bekommen-einen-schwachstellen-scan`](../open/slice-gepinnte-bilder-bekommen-einen-schwachstellen-scan.md)) — kein Release-Blocker: er ändert weder Träger noch Vorlagen; ein Tag liefert, was in `done/` liegt.
- Die Mutations-Fall-Slices ([`slice-mutations-faelle-ueber-full-smoke-faerben-am-erwarteten-grund`](../open/slice-mutations-faelle-ueber-full-smoke-faerben-am-erwarteten-grund.md), [`slice-mutate-auswahl-liest-jeden-fall-einmal`](../open/slice-mutate-auswahl-liest-jeden-fall-einmal.md)) — Dogfood-Sensoren (`make mutate`, kein Gate), nicht im ausgelieferten Programm.
- Weiterer Funktionsinhalt — Schnitt nach Lieferwert: jede Programm- oder Vorlagen-Änderung wäre ein anderer Slice, und der Verifier hielte den Tag-Baum nicht mehr gegen einen geprüften Stand.
- Ein Signier-Schritt für die Assets — Bestand bleibt bewusst stehen: [`releasing.md`](../../../user/releasing.md) §Grenze führt ihn.
- Anlage oder Rotation des Repo-Secrets `HOMEBREW_TAP_GITHUB_TOKEN` — außerhalb der Prozedur ([`releasing.md`](../../../user/releasing.md) Schritt 7); Sache des Auftraggebers.

## 2. Definition of Done

Liefer-Punkte (drei):

- [ ] **L1 — Tag-Baum vorbereitet und verifiziert** (Schritte 1 bis 4 der Prozedur). `TRAEGER_TAG` in `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in `test/traeger-fetch.bats` zeigen auf `v0.7.0`; `make release-artifacts DEST=dist TRAEGER_VERSION=v0.7.0` baut die sechs Binaries und `dist/SHA256SUMS`; `bash harness/tools/release-sums.sh verify dist` endet mit Exit 0; `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im `Makefile` tragen den Tag und die gemessenen Digests; `make gates` ist grün auf dem Commit, der den Tag tragen wird.
  - Rot (ohne Netz): ein Byte eines Assets in einer Kopie von `dist/` ändern — `release-sums.sh verify` endet mit Exit ≠ 0 und nennt die Datei; den Tag der Vorlage vom Tag im `Makefile` trennen — die Kopplung in `test/traeger-fetch.bats` färbt rot.
  - Rot an der realen Quelle: einen Digest im realen `Makefile` verfälschen und `bats test/traeger-fetch.bats` fahren; färbt kein Fall, steht die bekannte Lücke („realer `Makefile`-Digest ungebunden") im Bericht, nicht verdeckt durch Fixture-Grün.
- [ ] **L2 — Handbuch im Ist-Zustand** (`docs/user/benutzerhandbuch.md`; Zeilennummern gemessen am 2026-10-10 an `8e1b1691`, der Implementer misst am Tag-Baum neu):
  - Stand: `grep -n 'v0\.6\.0' docs/user/benutzerhandbuch.md` → `**Software-Stand:**` (Zeile 3) und „aktuell ausgeliefert wird" (Zeile 81) auf `v0.7.0`.
  - Kotlin: `grep -c -i kotlin docs/user/benutzerhandbuch.md` → `0`. Die `--lang`-Tabelle (Zeile 459, heute „Unterstützt: `go`, `cpp`"), die `--arch`-Grenzen (Zeile 328, „beide Zielsprachen"), der Baum-Abschnitt der Sprachen (ab Zeile 638) und `SKEL_<SPRACHE>_VERSION` (Zeile 482) werden gegen `internal/gen/gen.go` (`SupportedLangs`) gemessen und nachgezogen; dazu die Toolchain-Voraussetzungen von Kotlin (Gradle/JDK), wo das Handbuch sie bei den anderen Sprachen nennt.
  - `KENNUNG` beim Altbestand-Lauf: die Zeile `make archive-welle` (Zeile 444) nennt `WELLE=altbestand KENNUNG=<K>` samt Pflicht (Quelle: `internal/emit/templates/enforce/archivierung.mk`).
  - Alte Ziele: ein Ziel, das bis `v0.5.0` aufgesetzt wurde, trägt in der skip-if-present-`.d-check.yml` noch Kennungen dieses Repos; das Handbuch sagt, dass ein erneuter Lauf die vorhandene Datei nicht ändert und welche Stellen von Hand zu bereinigen sind (Messung: `git diff v0.6.0 -- internal/emit/templates/d-check.yml` am Tag-Baum).
  - `reviews`-Absatz (Zeile 707, „Die Review-Report-Deckung ist nicht eingeschaltet") auf den Stand des Kommentar-Blocks der Vorlage mit Pin `v0.86.x` und den vier neuen Schlüsseln; die Aussage über die Wortfolge „unabhängiger Review" gegen die Vorlage prüfen.
  - Weitere Versions-Pins: `grep -n -E 'v0\.8[0-9]|v0\.2[0-9]|v6\.1[0-9]' docs/user/benutzerhandbuch.md README.md` messen und nur ziehen, was ein Ist-Zustand nennt.
  - Nur Ist-Zustand: keine Chronik, keine Prognose. `make docs-check` rot bei totem Link/Anker; dass die Aussagen stimmen, hält kein Gate — der Reviewer liest sie gegen die Vorlagen am Tag-Baum.
- [ ] **L3 — Veröffentlicht, belegt, gemeldet** (Schritte 5 bis 8). Der Tag-Push ist ein eigener, benannter Schritt (**Schritt P** in §3) und braucht die ausdrückliche Freigabe des Auftraggebers; der Release trägt acht Assets (`gh release view v0.7.0 --json assets --jq '.assets | length'` → `8`); `make traeger-fetch` hält das veröffentlichte Asset gegen den Pin; `ci` an `main` und am Tag grün (gefallene `full-smoke`-Jobs nach abgeschlossener Publikation per `gh run rerun --failed`); Job `tap` grün und `make tap-check TAG=v0.7.0` Exit 0, die Meldung trägt dessen Ausgabezeile; der Release-Text trägt Stand, Assets, Grenze, die Gegenstände aus §1 und, falls der Vergleich zweier frischer Emissionen (Träger `v0.6.0` gegen `v0.7.0`, [`releasing.md`](../../../user/releasing.md) Schritt 5) Dateien der zweiten Klasse ändert, den Abschnitt **Bestand**.
  - Rot (Pin passt nicht zum Asset): ein verfälschter `TRAEGER_SHA256_*` lässt `make traeger-fetch` mit Exit ≠ 0 enden, bevor etwas abgelegt wird — nach der Publikation fahren und belegen; sonst steht es als Lücke in §7.
  - Fällt der Job `tap`: `make tap-nachzug TAG=v0.7.0` mit `TAP_TOKEN` des Auftraggebers, danach `make tap-check`.

Gate-Läufe und Closure-Pflichten:

- [ ] `make gates` grün am Tag-Baum (siehe L1).
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
| `docs/user/benutzerhandbuch.md` | update | L2 |
| `dist/` (lokal, nicht committet) | neu | Schritt 1 und 3: Assets und `SHA256SUMS` |

Reihenfolge der Rollen:

1. **Implementer** — Schritte 1 bis 3 und L2: ein Commit mit Vorlage, Pin und Handbuch; **kein** Push, **kein** Tag.
2. **Reviewer** — Diff gegen diesen Plan und die Prozedur; liest die Handbuch-Aussagen gegen die Vorlagen am Tag-Baum.
3. **Verifier** — am Tag-Baum, vor dem Tag-Push: Digests eigenständig nachgerechnet, `make gates` frisch auf dem finalen Commit, bewusstes Brechen des realen Pins.
4. **Schritt P — Push von `main` und Tag-Push** (Implementer-Kontext, zweiter Lauf; Schritte 5 bis 7 der Prozedur). Erst nach grünem Verifier-Bericht **und** grünem `make gates` auf dem dann finalen Commit (Report-Commits ändern den Baum nach dem Stempel). Reihenfolge: `main` zuerst, dann der Tag. **Der Tag-Push ist nach außen wirksam und wird erst gefahren, wenn der Auftraggeber ihn ausdrücklich freigibt.** Freigabe-Vermerk: erteilt am 2026-10-10, Wortlaut des Auftraggebers: „ja tag push“; Tag `v0.7.0` (annotiert) auf `a6ed0813`.
5. **Planner-Closure** — nach Schritt 8 (Meldung), in eigenem Commit.

**Belege der Publikation** (gemessen am 2026-10-10, Tag `v0.7.0` auf `a6ed0813`):

- `gh release view v0.7.0 --json assets --jq '.assets | length'` → `8`.
- Release-Workflow Run `38065750258` (artifacts, 6× Start-Smoke, publish, tap): `success`.
- `make tap-check TAG=v0.7.0` → `tap-check: gleich — Tag v0.7.0, Tap-Kopf Formula/ai-harness-init.rb, sha256 6f7a1e417f8a6de963503e11648c1347187bce1242999286ca0245c13f4abdd6`.
- `make traeger-fetch` → `Traeger abgelegt (…/.harness/state/bin/ai-harness-init) — ai-harness-init-linux-amd64 aus Release v0.7.0, Digest verifiziert.` Rot an der Publikation: `make traeger-fetch TRAEGER_SHA256_LINUX_AMD64=<64 Nullen>` → `Digest-Abweichung — ist 91fe2ba5…3642, erwartet 0000… (aus Pin). Der Traeger wird nicht abgelegt.`, make-Exit 2, nichts abgelegt; der echte Pin stimmt mit dem Asset überein.
- `ci` an `a6ed0813`: Run `38060627055` (main, nach `gh run rerun --failed`) und Run `38065750227` (Tag `v0.7.0`): beide `completed`/`success`. Run `38059784584` (main, `6f7a392e`) steht auf `cancelled` (von der Nachfolge abgelöst).
- Release-Text gesetzt mit `gh release edit v0.7.0 --notes-file`: Titelzeile, Neu im gebootstrappten Ziel, Assets, **Bestand**, Grenze, Full Changelog. Der Vergleich zweier frischer Emissionen (`v0.6.0`-Träger gegen `v0.7.0`-Träger; dokument-only, `--lang go`, `--lang cpp`, `--lang go --arch hexslice`; `diff -rq -x .git`) ändert in der zweiten Klasse `.d-check.yml` (Kurs-URL `v6.17.0` → `v6.18.0`, Kommentare), `.claude/commands/close-welle.md` (`KENNUNG=<K>`), `AGENTS.md` und `harness/conventions.md` (Kurs-Stand).
- `--version` des veröffentlichten linux-amd64-Binaries → `v0.7.0` (v0.6.0-Binary: `v0.6.0`).

## 4. Trigger

**Start** (`next` → `in-progress`): kein Slice liegt in `in-progress/` (`ls docs/plan/planning/in-progress/` nennt nur die Roadmap), `git tag --sort=-v:refname | head -1` nennt `v0.6.0`, und der Auftraggeber hat den Schnitt freigegeben (Freigabe 2026-10-10). Für den Start gilt: die Gegenstände aus §1 liegen in `done/`.

**Rückführungen:**

- `in-progress` → `next`: ein Plattform-Bau bricht und verlangt eine Code-Änderung jenseits eines Build-Tags — sie wird eigener Slice, dieser bleibt reiner Schnitt.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar, oder der Auftraggeber zieht die Freigabe des Tag-Pushs zurück.

## 5. Closure-Trigger

DoD vollständig, Verifier-Bericht am Tag-Baum ohne Blocker, `ci` an `main` und am Tag grün, `make tap-check TAG=v0.7.0` mit Exit 0, Meldung an den Auftraggeber und Closure-Notiz mit Lerneintrag. Nicht Closure-Trigger: ein gepushter Tag allein.

## 6. Risiken und offene Punkte

- Ein Plattform-Asset baut nicht — **Ausgang:** entfallen, wenn alle sechs im ersten Lauf bauen; sonst eingetreten → Rückführung nach §4.
- Der Gates-Beleg reist nicht mit dem Tag; Report-Commits ändern den Baum nach dem Stempel — **Ausgang:** eingetreten, strukturell: erneuter `make gates` auf dem finalen Commit ist Teil von L3 ([`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
- `ci` fällt im `full-smoke` mit 404, falls der `release`-Lauf nicht innerhalb der Grenze von `make release-warten` publiziert — **Ausgang:** weiter offen: → [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md); operativ Re-Run.
- Der Job `tap` scheitert (Secret abgelaufen) — **Ausgang:** eingetreten → lokaler Ausfallweg mit `TAP_TOKEN`; sonst entfallen.
- Der reale `Makefile`-Digest ist ungebunden; den Pin gegen das Asset hält erst `make traeger-fetch` nach der Publikation — **Ausgang:** weiter offen: → [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md).
- Die Kennung dieses Slice trägt den Tag, den der Schnitt selbst überholt — **Ausgang:** weiter offen: → [`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md).

## 7. Closure-Notiz

Wird vom Planner bei der Closure geschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`): Pin-Stellen, Emissions-Vorlage und Nutzerdoku; die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register durchgegangen, Zähler = Zahl der Dateien unter `evidence/` (`ls <eintrag>/evidence | wc -l`), gemessen am 2026-10-10 an `8e1b1691`:
- [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md) — 3, Stand verkörpert (`make release-warten`); als Risiko 3 übernommen.
- [`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md) — 1, offen; als Risiko 2 übernommen.
- [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) — 7, Stand geplant; als Risiko 5 übernommen.
- [`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md) — 1, offen; als Risiko 6 übernommen.
- [`BEO-ALL/pin-digest-ohne-waechter`](../observations/BEO-ALL/pin-digest-ohne-waechter/observation.md) — 6, Stand geplant; Gegenstand sind Dockerfile-Digests und Wert-Fallbacks der Smoke-Skripte, nicht der Träger-Pin dieses Schnitts — gesichtet, kein Treffer für diesen Slice.

**Modus-Begründung:** alle berührten Sub-Areas GF.
