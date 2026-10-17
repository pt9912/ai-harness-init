# Slice slice-release-schnitt-v090-liefert-toolchain-pins-und-sperr-budget: Der Release-Schnitt `v0.9.0` liefert die Go-Toolchain, den Lint-Pin des Go-Skeletts und das Sperr-Budget des Span-Emitters

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Die Closure-Bedingung — Tag veröffentlicht, CI und Tap-Kontrolle grün — ist die DoD dieses
Slice selbst (Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht; dieselbe Einordnung wie
[`slice-release-schnitt-v080-liefert-die-baseline-v6181`](../done/slice-release-schnitt-v080-liefert-die-baseline-v6181.md)).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin trägt Version + sha256),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die sechs Assets),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 (Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (`SHA256SUMS` als Release-Asset),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (Tap-Nachzug).
Auslöser: Entscheidung des Auftraggebers vom 2026-10-17 — Release `v0.9.0` jetzt vorbereiten.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-17.

---


## 1. Ziel und Abgrenzung


**Ziel:** Das Release `v0.9.0` ist veröffentlicht und vollzogen gemeldet: die Binaries tragen die Go-Toolchain `1.27.2`, ein
gebootstrapptes Go-Ziel bekommt Go `1.27.2` und golangci-lint `v2.15.0`, der Span-Emitter trägt das Sperr-Budget 750, der Pin
zeigt auf den geschnittenen Stand, und das Benutzerhandbuch beschreibt den Ist-Zustand.

**Versionswahl:** `v0.9.0`; der vorige Tag ist `v0.8.0` (`git describe --tags --abbrev=0`). Die Wahl folgt dem Minor-Schritt
von [`releasing.md`](../../../user/releasing.md) §Versionsnummer — ein Pin-Sprung mit geänderter Emission (neue Pins in den emittierten Go-Dateien);
der Auftraggeber hat sie am 2026-10-17 entschieden.

**Namenswahl.** Die Kennung trägt die Version (`v090`), nicht die Pin-Stände. Begründung: die Version ist vor dem Start vom Auftraggeber
entschieden und `v0.8.0` ist der höchste Tag; ein Tag kann den Schnitt nicht überholen, bevor er läuft — der Fehlerfall der Beobachtung
([`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md),
1×) tritt für das Schnitt-Objekt nicht ein. Überholbar sind die Werkzeug-Stände (Go `1.27.2`, golangci-lint `v2.15.0`): sie stehen darum
**nicht** im Namen, sondern in §1 und im Release-Text. Die Form folgt den Vorgängern (`v070`, `v080`); die Beobachtung verlangt für den Release-Schnitt
keinen Namen ohne Versionsstand, sondern einen ohne überholbaren Werkzeug-Stand.

**Gegenstände des Schnitts:** gemessen mit `git log --oneline v0.8.0..HEAD -- internal/ cmd/`; am Stand `fca225c9` nennt die Menge vier Commits:

| Commit | Gegenstand | Gebaut / emittiert in |
|---|---|---|
| `ca2dd354` | Go `1.27.1` → `1.27.2` an allen Pin-Stellen (`DefaultGoVersion` in `internal/gen/golang.go`, `Dockerfile`, `Makefile`, Smoke-Skripte) | Binaries (Toolchain, `Dockerfile`); gebootstrappte Go-Ziele (Pin `1.27.2`) |
| `d198c4c8` | golangci-lint `v2.14.0` → `v2.15.0` (`golangciVersion` in `internal/gen/golang.go`) | gebootstrappte Go-Ziele (Lint im Go-Skelett) |
| `11f921a8`, `33ebb12c` | Sperr-Budget des Span-Emitters `lockTries` 200 → 750, Kommentar nennt Preis, fail-open-Ort und Grenze (`internal/span/emit.go`) | Binary (`span-emit`) |

**Der Release-Text führt als Gegenstand** (Maßstab: [`releasing.md`](../../../user/releasing.md) — was ein Ziel bekommt oder wie es sich verhält):

1. **Go-Toolchain `1.27.2`.** Sicherheits-Release laut go.dev („security fixes to the go command and crypto/tls, html/template, net/http, net/textproto, os"; Quelle `go.dev/doc/devel/release`, Eintrag vom 2026-10-08 — im Text zitieren; CVE-Nummern nennt die Seite nicht, der Text nennt keine). Die Binaries ab `v0.9.0` tragen sie; ein gebootstrapptes Go-Ziel bekommt den Pin `1.27.2`.
2. **golangci-lint `v2.15.0` im Go-Skelett.**
3. **Sperr-Budget des Span-Emitters: 750 Versuche.** Grenze im Text: die Ursache des Anlasses ist nicht reproduziert; der erste grüne `mutate`-Lauf auf `1a9f76ec` (9 von 10 Shards, Shard 7 grün) ist ein Hinweis, kein Wirkungsbeleg — Shard 7 war in der Vergangenheit unstet.

**Nicht Gegenstand des Release-Textes, ohne Slice-Arbeit:** der Mutations-Treiber nennt jedes `not ok` des roten Grün-Vorlaufs (`harness/tools/mutate.sh`, `test/mutate-driver.bats`) — Werkzeug im Repo, nicht im ausgelieferten Programm; Lastenheft `0.27.1` und die Zielbild-Umformulierungen der Spec, Mutations-Fall-Pflege, Doku-Slices, Register und Reviews — nichts davon ist im Binary oder in einer emittierten Datei. Der Implementer misst am Tag-Baum neu (`git log --oneline v0.8.0..HEAD -- internal/ cmd/`, `git diff --stat v0.8.0 HEAD -- internal/ cmd/ harness/tools test/`) und trägt jeden weiteren Commit mit seinem Slice in die Tabelle, bevor er ihn liefert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Weiterer Funktionsinhalt.** *Schnitt nach Lieferwert:* jede Programm- oder Vorlagen-Änderung wäre ein anderer Slice, und der Verifier hielte den Tag-Baum nicht mehr gegen einen geprüften Stand.
- **Ein Wirkungsbeleg für das Sperr-Budget.** *Anderer Vorgang:* die Ursache ist nicht reproduziert; ein Beleg bräuchte Reproduktion oder eine Läufe-Reihe und gehört in einen eigenen Slice, nicht in den Schnitt.
- **Ein Signier-Schritt für die Assets.** *Bestand bleibt bewusst stehen:* [`releasing.md`](../../../user/releasing.md) §Grenze führt ihn.
- **Anlage oder Rotation des Repo-Secrets `HOMEBREW_TAP_GITHUB_TOKEN`.** *Anderer Vorgang:* außerhalb der Prozedur
  ([`releasing.md`](../../../user/releasing.md) Schritt 7); Sache des Auftraggebers.


## 2. Definition of Done


Liefer-Punkte (drei):

- [ ] **L1 — Tag-Baum vorbereitet und verifiziert** (Schritte 1 bis 4 der Prozedur). `TRAEGER_TAG` in
      `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in `test/traeger-fetch.bats` zeigen auf `v0.9.0`;
      `make release-artifacts DEST=dist TRAEGER_VERSION=v0.9.0` baut die sechs Binaries und `dist/SHA256SUMS`;
      `bash harness/tools/release-sums.sh verify dist` endet mit Exit 0; `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im
      `Makefile` tragen den Tag und die gemessenen Digests; `make gates` ist grün auf dem Commit, der den Tag tragen wird.
  - Rot (ohne Netz): ein Byte eines Assets in einer Kopie von `dist/` ändern — `release-sums.sh verify` endet mit Exit ≠ 0 und
    nennt die Datei; den Tag der Vorlage vom Tag im `Makefile` trennen — die Kopplung in `test/traeger-fetch.bats` färbt rot.
  - Rot an der realen Quelle: einen Digest im realen `Makefile` verfälschen und `bats test/traeger-fetch.bats` fahren; färbt kein Fall,
    steht die bekannte Lücke („realer `Makefile`-Digest ungebunden") im Bericht, nicht verdeckt durch Fixture-Grün.
- [ ] **L2 — Handbuch im Ist-Zustand** (`docs/user/benutzerhandbuch.md`; Zeilen am Tag-Baum neu messen):
  - Stand: `grep -n 'v0\.8\.0' docs/user/benutzerhandbuch.md README.md` — am Stand `fca225c9` zwei Treffer, `**Software-Stand:**` (Zeile 3) und „aktuell ausgeliefert wird" (Zeile 81), beide auf `v0.9.0`; `README.md` trägt keinen.
  - Pins: `grep -nE '1\.27|golangci|v2\.1[0-9]' docs/user/benutzerhandbuch.md README.md` — am Stand `fca225c9` kein Treffer auf Go- oder Lint-Version (nur die Dateinamen `.golangci.yml`); der Implementer misst neu und zieht nur, was ein Ist-Zustand nennt. Wird die Bestand-Messung (L3) nicht leer, prüft er, ob die Beschreibung der zweiten Klasse im Handbuch (Abschnitt „Ein Repository erneut aufsetzen") noch trägt.
  - Nur Ist-Zustand: keine Chronik, keine Prognose. `make docs-check` rot bei totem Link/Anker; dass die Aussagen stimmen, hält kein Gate —
    der Reviewer liest sie gegen die Vorlagen am Tag-Baum.
- [ ] **L3 — Veröffentlicht, belegt, gemeldet** (Schritte 5 bis 8). Der Tag-Push ist ein eigener, benannter Schritt (**Schritt P** in §3)
  und braucht die ausdrückliche Freigabe des Auftraggebers; der Release trägt acht Assets
  (`gh release view v0.9.0 --json assets --jq '.assets | length'` → `8`); `make traeger-fetch` hält das veröffentlichte Asset gegen den Pin;
  `ci` an `main` und am Tag grün (gefallene `full-smoke`-Jobs nach abgeschlossener Publikation per `gh run rerun --failed`);
  Job `tap` grün und `make tap-check TAG=v0.9.0` Exit 0, die Meldung trägt dessen Ausgabezeile; der Release-Text trägt Stand, Assets, Grenze,
  die drei Gegenstände aus §1 mit der Grenze des Sperr-Budgets und, falls der Vergleich zweier frischer Emissionen den Inhalt einer Datei der zweiten Klasse ändert, den Abschnitt **Bestand**.
  - **Messaufgabe Bestand** ([`releasing.md`](../../../user/releasing.md) Schritt 5): Träger `v0.8.0` gegen Träger `v0.9.0`, je in ein frisches Git-Repository (`git init <alt>`, `git init <neu>`), über **sechs Optionssätze** — ohne `--lang` (dokument-only) · `--lang go` · `--lang go --arch hexagonal` · `--lang go --arch hexslice` · `--lang cpp` · `--lang kotlin` —, dann `diff -rq -x .git <alt> <neu>`, beschränkt auf die zweite Klasse. Erwartung, **nicht Ergebnis:** die Baseline bleibt `v6.18.1`, die Rollen-Anweisungen und Skills sollten gleich bleiben; die Go-Pins stehen aber im emittierten `Dockerfile` und in `go.mod`, und beide gehören laut Handbuch zur zweiten Klasse — der Vergleich mit `--lang go` kann also Pfade nennen. Der Vorgänger lief nur dokument-only (Grenze (3) seiner Closure); dieser Slice darf das nicht wiederholen. Der Implementer trägt die gemessenen Pfade mit Kommando in den Bericht; der Abschnitt entfällt nur bei leerem Ergebnis aller sechs Sätze.
  - Rot (Pin passt nicht zum Asset): ein verfälschter `TRAEGER_SHA256_*` lässt `make traeger-fetch` mit Exit ≠ 0 enden, bevor etwas
    abgelegt wird — nach der Publikation fahren und belegen; sonst steht es als Lücke in §7.
  - Fällt der Job `tap`: `make tap-nachzug TAG=v0.9.0` mit `TAP_TOKEN` des Auftraggebers, danach `make tap-check`.

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

1. **Implementer** — Schritte 1 bis 3 und L2: ein Commit mit Vorlage, Pin und Handbuch; **kein** Push, **kein** Tag. Die Bestand-Messung (L3) braucht den Träger `v0.8.0` (gepinntes Release, `make traeger-fetch` am alten Tag oder Bau am Tag-Baum `v0.8.0`) und den Träger dieses Baums.
2. **Reviewer** — Diff gegen diesen Plan und die Prozedur; liest die Handbuch-Aussagen gegen die Vorlagen am Tag-Baum.
3. **Verifier** — am Tag-Baum, vor dem Tag-Push: Digests eigenständig nachgerechnet, `make gates` frisch auf dem finalen Commit, bewusstes Brechen des realen Pins, Bestand-Messung eigenständig wiederholt.
4. **Schritt P — Push von `main` und Tag-Push** (Implementer-Kontext, zweiter Lauf; Schritte 5 bis 7 der Prozedur). Erst nach grünem
   Verifier-Bericht **und** grünem `make gates` auf dem dann finalen Commit. **Der Tag-Push ist nach außen wirksam und wird erst gefahren,
   wenn der Auftraggeber ihn ausdrücklich freigibt — die Entscheidung der Version ist keine Freigabe des Pushes.**
   `main` stand am Planungsstand `fca225c9` auf `origin`; die Commits dieses Schnitts gehen mit dem Tag nach der Freigabe, der Tag unmittelbar nach `main`: `make release-warten` trägt nur innerhalb seiner
   Grenze ([`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)).
   **Freigabe-Vermerk:** ausstehend.
5. **Planner-Closure** — nach Schritt 8 (Meldung), in eigenem Commit.


## 4. Trigger


**Start** (`next` → `in-progress`), Stand `fca225c9`: erfüllt — `ls docs/plan/planning/in-progress/` nennt nur die Roadmap; `git describe --tags --abbrev=0` nennt `v0.8.0`
(`git tag --sort=-v:refname | head -1` ebenso); Version `v0.9.0` vom Auftraggeber am 2026-10-17 entschieden; WIP-Limit frei. Der Freigabe-Vermerk für Schritt P (§3) bleibt „ausstehend".

**Rückführungen:**

- `in-progress` → `next`: ein Plattform-Bau bricht und verlangt eine Code-Änderung jenseits eines Build-Tags — sie wird eigener Slice, dieser bleibt reiner Schnitt.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar, oder der Auftraggeber zieht die Version oder die Freigabe des Tag-Pushs zurück.


## 5. Closure-Trigger


DoD vollständig, Verifier-Bericht am Tag-Baum ohne Blocker, `ci` an `main` und am Tag grün, `make tap-check TAG=v0.9.0` mit Exit 0, Meldung an den
Auftraggeber und Closure-Notiz mit Lerneintrag. Nicht Closure-Trigger: ein gepushter Tag allein.


## 6. Risiken und offene Punkte


Ausgänge setzt der Planner bei der Closure.

- Ein Plattform-Asset baut nicht — **Ausgang:** bei Closure.
- Der Gates-Beleg reist nicht mit dem Tag; Report-Commits ändern den Baum nach dem Stempel — **Ausgang:** bei Closure (Register, 1×)
  ([`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
- `ci` fällt im `full-smoke` mit 404, falls der `release`-Lauf nicht innerhalb der Grenze von `make release-warten` publiziert — **Ausgang:** bei Closure; Tag unmittelbar nach `main`
  ([`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)).
- Der reale `Makefile`-Digest ist ungebunden; den Pin gegen das Asset hält erst `make traeger-fetch` nach der Publikation — **Ausgang:** bei Closure (Register, 9×, Stand geplant)
  ([`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)).
- Der Bestand-Vergleich bleibt dokument-only und übersieht Pfade der zweiten Klasse in Go-Zielen (`Dockerfile`, `go.mod`) — **Ausgang:** bei Closure; die Messaufgabe in L3 verlangt sechs Optionssätze.
- Das Sperr-Budget 750 ist nicht als wirksam gemessen; ein grüner Shard 7 ist ein Hinweis — **Ausgang:** bei Closure; die Grenze steht im Release-Text (§1).
- Die Kennung trägt einen überholbaren Stand — **Ausgang:** bei Closure; die Namenswahl in §1 lässt die Werkzeug-Stände aus dem Namen und trägt nur die entschiedene Version
  ([`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md)).


## 7. Closure-Notiz


Wird vom Planner bei der Closure geschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.10).


## 8. Sub-Area-Prüfungen und Modus-Begründung


**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`): Pin-Stellen, Emissions-Vorlage und Nutzerdoku; die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register am Stand `fca225c9` durchgegangen, Zähler = `ls <eintrag>/evidence/*.md | wc -l`, gemessen am 2026-10-17:
- `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` — 4, Stand verkörpert; als Risiko und in Schritt P übernommen.
- `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg` — 1, offen; als Risiko übernommen.
- `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` — 9, Stand geplant (Träger `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`); als Risiko übernommen.
- `BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt` — 1, offen; Namenswahl in §1 entschieden, als Risiko übernommen.
- `BEO-ALL/push-auf-den-geschuetzten-hauptzweig-laeuft-ueber-die-regelumgehung` — 1, offen; betrifft Schritt P (Push von `main`), kein neuer Beleg vor dem Push.

**Modus-Begründung:** alle berührten Sub-Areas GF.

