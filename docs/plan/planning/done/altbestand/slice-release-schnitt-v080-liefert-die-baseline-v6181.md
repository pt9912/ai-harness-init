# Slice slice-release-schnitt-v080-liefert-die-baseline-v6181: Der Release-Schnitt `v0.8.0` liefert die Baseline `v6.18.1` im gebootstrappten Ziel

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
[`slice-release-schnitt-v070-liefert-kotlin-und-v6180`](../done/slice-release-schnitt-v070-liefert-kotlin-und-v6180.md)).

**Bezug:**
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin trägt Version + sha256),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die sechs Assets),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 (Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (`SHA256SUMS` als Release-Asset),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (Tap-Nachzug).
Auslöser: Auftrag des Auftraggebers vom 2026-10-16 — nach dem Sprung auf `v6.18.1` folgt ein Release.

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Das Release `v0.8.0` ist veröffentlicht und vollzogen gemeldet: Träger und emittierte Vorlagen tragen den
Stand von [`slice-sprung-auf-v6181-wird-vollzogen`](../done/slice-sprung-auf-v6181-wird-vollzogen.md), der Pin zeigt auf den geschnittenen Stand,
und das Benutzerhandbuch beschreibt den Ist-Zustand.

**Versionswahl:** `v0.8.0`; der vorige Tag ist `v0.7.0` (`git tag --sort=-v:refname | head -1`). Die Wahl folgt dem Minor-Schritt
von [`releasing.md`](../../../user/releasing.md) §Versionsnummer (Sprung der adoptierten Baseline und geänderte emittierte Dateien);
der Auftraggeber hat sie am 2026-10-16 entschieden.

**Gegenstände des Schnitts:** gemessen mit `git log --oneline v0.7.0..HEAD -- internal/ cmd/`; am Stand `a2800a86`
nennt die Menge zwei Commits (`1d79137b`, `26ef8f20`), beide aus
[`slice-sprung-auf-v6181-wird-vollzogen`](../done/slice-sprung-auf-v6181-wird-vollzogen.md): der Sprung auf `v6.18.1` samt Emitter-Folge. Der Implementer misst am Tag-Baum neu und trägt jeden
weiteren Commit mit seinem Slice in diese Tabelle, bevor er ihn liefert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Weiterer Funktionsinhalt.** *Schnitt nach Lieferwert:* jede Programm- oder Vorlagen-Änderung wäre ein anderer Slice, und der
  Verifier hielte den Tag-Baum nicht mehr gegen einen geprüften Stand.
- **Ein Signier-Schritt für die Assets.** *Bestand bleibt bewusst stehen:* [`releasing.md`](../../../user/releasing.md) §Grenze führt ihn.
- **Anlage oder Rotation des Repo-Secrets `HOMEBREW_TAP_GITHUB_TOKEN`.** *Anderer Vorgang:* außerhalb der Prozedur
  ([`releasing.md`](../../../user/releasing.md) Schritt 7); Sache des Auftraggebers.

## 2. Definition of Done

Liefer-Punkte (drei):

- [x] **L1 — Tag-Baum vorbereitet und verifiziert** (Schritte 1 bis 4 der Prozedur). `TRAEGER_TAG` in
      `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in `test/traeger-fetch.bats` zeigen auf `v0.8.0`;
      `make release-artifacts DEST=dist TRAEGER_VERSION=v0.8.0` baut die sechs Binaries und `dist/SHA256SUMS`;
      `bash harness/tools/release-sums.sh verify dist` endet mit Exit 0; `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im
      `Makefile` tragen den Tag und die gemessenen Digests; `make gates` ist grün auf dem Commit, der den Tag tragen wird.
  - Rot (ohne Netz): ein Byte eines Assets in einer Kopie von `dist/` ändern — `release-sums.sh verify` endet mit Exit ≠ 0 und
    nennt die Datei; den Tag der Vorlage vom Tag im `Makefile` trennen — die Kopplung in `test/traeger-fetch.bats` färbt rot.
  - Rot an der realen Quelle: einen Digest im realen `Makefile` verfälschen und `bats test/traeger-fetch.bats` fahren; färbt kein Fall,
    steht die bekannte Lücke („realer `Makefile`-Digest ungebunden") im Bericht, nicht verdeckt durch Fixture-Grün.
- [x] **L2 — Handbuch im Ist-Zustand** (`docs/user/benutzerhandbuch.md`; Zeilen am Tag-Baum neu messen):
  - Stand: `grep -n 'v0\.7\.0' docs/user/benutzerhandbuch.md` → `**Software-Stand:**` und „aktuell ausgeliefert wird" auf `v0.8.0`.
  - Baseline: `grep -n 'v6\.18\.0' docs/user/benutzerhandbuch.md README.md` — die Beispiel-Ausgabe des Bootstraps nennt die Baseline des Ziels; sie
    steht auf `v6.18.1`, sobald der Träger sie so ausgibt.
  - Weitere Versions-Pins: `grep -n -E 'v0\.8[0-9]|v0\.2[0-9]|v6\.1[0-9]' docs/user/benutzerhandbuch.md README.md` messen; nur ziehen, was ein Ist-Zustand nennt.
  - Nur Ist-Zustand: keine Chronik, keine Prognose. `make docs-check` rot bei totem Link/Anker; dass die Aussagen stimmen, hält kein Gate —
    der Reviewer liest sie gegen die Vorlagen am Tag-Baum.
- [x] **L3 — Veröffentlicht, belegt, gemeldet** (Schritte 5 bis 8). Der Tag-Push ist ein eigener, benannter Schritt (**Schritt P** in §3)
  und braucht die ausdrückliche Freigabe des Auftraggebers; der Release trägt acht Assets
  (`gh release view v0.8.0 --json assets --jq '.assets | length'` → `8`); `make traeger-fetch` hält das veröffentlichte Asset gegen den Pin;
  `ci` an `main` und am Tag grün (gefallene `full-smoke`-Jobs nach abgeschlossener Publikation per `gh run rerun --failed`);
  Job `tap` grün und `make tap-check TAG=v0.8.0` Exit 0, die Meldung trägt dessen Ausgabezeile; der Release-Text trägt Stand, Assets, Grenze,
  die Gegenstände aus §1 und, falls der Vergleich zweier frischer Emissionen (Träger `v0.7.0` gegen `v0.8.0`,
  [`releasing.md`](../../../user/releasing.md) Schritt 5) Dateien der zweiten Klasse ändert, den Abschnitt **Bestand**.
  - Rot (Pin passt nicht zum Asset): ein verfälschter `TRAEGER_SHA256_*` lässt `make traeger-fetch` mit Exit ≠ 0 enden, bevor etwas
    abgelegt wird — nach der Publikation fahren und belegen; sonst steht es als Lücke in §7.
  - Fällt der Job `tap`: `make tap-nachzug TAG=v0.8.0` mit `TAP_TOKEN` des Auftraggebers, danach `make tap-check`.

Gate-Läufe und Closure-Pflichten:

- [x] `make gates` grün am Tag-Baum (siehe L1).
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), Verifier-Bericht am Tag-Baum **vor** dem Tag-Push — kein Self-Review.
- [x] Doku-Update: Handbuch (L2); [`releasing.md`](../../../user/releasing.md) bleibt unverändert, solange die Prozedur trägt.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag, vom Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

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
4. **Schritt P — Push von `main` und Tag-Push** (Implementer-Kontext, zweiter Lauf; Schritte 5 bis 7 der Prozedur). Erst nach grünem
   Verifier-Bericht **und** grünem `make gates` auf dem dann finalen Commit. **Der Tag-Push ist nach außen wirksam und wird erst gefahren,
   wenn der Auftraggeber ihn ausdrücklich freigibt — die Entscheidung der Version ist keine Freigabe des Pushes; der Auftraggeber will vor dem Tag-Push noch einmal gefragt werden.**
   `main` und Tag gehen in einem Zug nach der Freigabe, der Tag unmittelbar nach `main`: `make release-warten` trägt nur innerhalb seiner
   Grenze ([`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)).
   **Freigabe-Vermerk:** 2026-10-16, Auftraggeber, Antwort „ja, pushen" auf die Frage „Darf ich `main` und den Tag `v0.8.0` pushen?" — gilt für `git push origin main` und den Tag `v0.8.0` und nichts darüber hinaus.
5. **Planner-Closure** — nach Schritt 8 (Meldung), in eigenem Commit.

## 4. Trigger

**Start** (`next` → `in-progress`), Stand `a2800a86`: erfüllt — [`slice-sprung-auf-v6181-wird-vollzogen`](../done/slice-sprung-auf-v6181-wird-vollzogen.md) liegt in `done/`;
`ls docs/plan/planning/in-progress/` nennt nur die Roadmap; `git tag --sort=-v:refname | head -1` nennt `v0.7.0`; Tag-Wahl `v0.8.0` vom Auftraggeber
am 2026-10-16 entschieden; WIP-Limit frei. Der Freigabe-Vermerk für Schritt P (§3) bleibt unberührt.

**Rückführungen:**

- `in-progress` → `next`: ein Plattform-Bau bricht und verlangt eine Code-Änderung jenseits eines Build-Tags — sie wird eigener Slice, dieser bleibt reiner Schnitt.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar, oder der Auftraggeber zieht die Freigabe des Tag-Pushs zurück.

## 5. Closure-Trigger

DoD vollständig, Verifier-Bericht am Tag-Baum ohne Blocker, `ci` an `main` und am Tag grün, `make tap-check TAG=v0.8.0` mit Exit 0, Meldung an den
Auftraggeber und Closure-Notiz mit Lerneintrag. Nicht Closure-Trigger: ein gepushter Tag allein.

## 6. Risiken und offene Punkte

- Ein Plattform-Asset baut nicht — **Ausgang: entfallen** — alle sechs Binaries bauten, der Release trägt acht Assets.
- Der Gates-Beleg reist nicht mit dem Tag; Report-Commits ändern den Baum nach dem Stempel — **Ausgang: weiter offen** (Register, Zähler 1×, kein neuer Beleg: `gates-passed.head` == Tag-Ziel `77e83395`, der Beleg reist trotzdem nicht mit dem Tag)
  ([`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
- `ci` fällt im `full-smoke` mit 404, falls der `release`-Lauf nicht innerhalb der Grenze von `make release-warten` publiziert — **Ausgang: entfallen** — `release`, `ci` am Tag und `ci` an `main` endeten `success`, kein Re-Run; Tag unmittelbar nach `main`
  ([`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)).
- Der reale `Makefile`-Digest ist ungebunden; den Pin gegen das Asset hält erst `make traeger-fetch` nach der Publikation — **Ausgang: weiter offen** (Register, 9×, Stand geplant; Träger `slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`; nur `darwin-arm64` nach der Publikation gegen das Asset gehalten)
  ([`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)).
- Die Kennung dieses Slice trägt den Tag, den der Schnitt selbst überholt, falls der Auftraggeber einen anderen wählt — **Ausgang: entfallen** — der Auftraggeber wählte `v0.8.0`, die Kennung nennt den geschnittenen Tag
  ([`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md)).

## 7. Closure-Notiz

- **Geliefert:** Release `v0.8.0` ([Release-Text](https://github.com/pt9912/ai-harness-init/releases/tag/v0.8.0): Stand, Assets, Bestand, Grenze, Gegenstände). `main` und Tag am 2026-10-16 gepusht (Freigabe §3); Tag annotiert, Objekt `deb5fbbf…`, Ziel `77e83395`; Run `release` [38867510343](https://github.com/pt9912/ai-harness-init/actions/runs/38867510343), `ci` am Tag [38867510267](https://github.com/pt9912/ai-harness-init/actions/runs/38867510267), `ci` an `main` [38867508511](https://github.com/pt9912/ai-harness-init/actions/runs/38867508511) alle `success`, kein Re-Run.
- **Was hat funktioniert:** acht Assets; `make traeger-fetch` (darwin-arm64) „Digest verifiziert"; Job `tap` `success`, `make tap-check TAG=v0.8.0` Exit 0: `tap-check: gleich — Tag v0.8.0, Tap-Kopf Formula/ai-harness-init.rb, sha256 a1aa285a4c58615614487935bef6f5c79feeca979864e82916404a0e71b46399`. Rot nach der Publikation: verfälschter `TRAEGER_SHA256_DARWIN_ARM64` (Umgebungsvariable) → „Digest-Abweichung … Der Traeger wird nicht abgelegt", Datei nicht angelegt. Review ohne HIGH/MEDIUM/LOW, 3 INFO ([Review](../../../reviews/2026-10-16-slice-release-schnitt-v080-liefert-die-baseline-v6181.md)); Verifikation am Tag-Baum: L1 und L2 bestätigt ([Verifikation](../../../reviews/2026-10-16-slice-release-schnitt-v080-liefert-die-baseline-v6181-verify.md)). `gates-passed.head` == Tag-Ziel `77e83395`.
- **Was ging anders als geplant:** nichts am Ablauf; der Warte-Schritt aus `make release-warten` trug, weil der Tag unmittelbar auf `main` folgte. Zwei Funde: (1) der Push von `main` lief über eine Regelumgehung des geschützten Zweigs (GitHub: „Bypassed rule violations … Cannot update this protected ref"); (2) das Rot an der realen Quelle fiel vor der Publikation aus (Verifikation F-1, Review INFO-1).
- **Steering-Loop-Eintrag:** benannte Grenzen, kein neuer Sensor und keine geschärfte Regel. (1) Der reale `Makefile`-Digest ist von keinem Test gebunden; nach der Publikation hielt nur `traeger-fetch` den Pin `darwin-arm64` gegen das Asset, die übrigen fünf Digests deckt allein die Bau-Reproduktion (Verifikation F-2: gleiche Digests belegen Reproduzierbarkeit, nicht Gleichheit mit dem CI-Asset). (2) Den Exit-Code des Rot-Belegs hat niemand am Prozess gelesen: belegt ist die `make`-Zeile „Error 1" und die nicht angelegte Datei, nicht der Exit von `make`. (3) Der Bestand-Vergleich (`v0.7.0` gegen `v0.8.0`) lief dokument-only, nicht mit `--lang`/`--arch`. (4) Ein `mutate`-Lauf auf `main` war bei der Prüfung ohne Ergebnis und gehört nicht zu diesem Schnitt. Träger von (1) ist der Lauf, der den Schnitt schreibt; den Sensor trägt der geplante Slice im Register.
- **Beobachtungs-Register (`../observations/`):** `evidence/slice-release-schnitt-v080-liefert-die-baseline-v6181.md` ergänzt in [`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md) (9×, Stand `geplant` unverändert); neu angelegt [`BEO-ALL/push-auf-den-geschuetzten-hauptzweig-laeuft-ueber-die-regelumgehung`](../observations/BEO-ALL/push-auf-den-geschuetzten-hauptzweig-laeuft-ueber-die-regelumgehung/observation.md), Beleg `evidence/slice-release-schnitt-v080-liefert-die-baseline-v6181.md` (1×, offen). Kein neuer Beleg in [`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md) (4×, verkörpert: die Regel trug), [`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md) (1×, offen) und [`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md) (1×, offen); der Tag deckt die Kennung. Kein Eintrag erreichte mit diesem Slice 3× neu: der einzige über der Schwelle ist `waechter-…` mit Ausgang `geplant`.
- **Folge-Slices:** keine neuen; [`slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor`](../done/slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor.md) bleibt der Träger des Ausgangs von `waechter-misst-die-fixture-statt-der-realen-quelle`.
- **Risiken aus §6:** jedes trägt seinen Ausgang am Risiko: 1 entfallen, 2 weiter offen (Register), 3 entfallen, 4 weiter offen (Register), 5 entfallen.
- **Drei Paarungen:** Paarungen geprüft am 2026-10-16 nach dem `git mv`: (a) kein `liegt in` in §7 — kein Gegenstand; (b) der genannte Folge-Slice liegt in `open/` (`ls docs/plan/planning/done/slice-doppelt-gefuehrte-werte-bekommen-ihren-kopplungs-sensor.md`); (c) die fünf genannten `BEO-ALL/…` existieren, `ls …/evidence/*.md | wc -l` → 4 · 1 · 1 · 1 · 9 (`sed -n "/^## 7/,/^## 8/p"` über §7, `grep -oE "BEO-ALL/[a-z0-9-]+"`); zweite Hälfte von (c) über das ganze Register: 2 Verzeichnisse ohne Beleg, namentlich `cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`, `einstiegs-datei-weicht-von-der-pflichtgliederung-ab` (Bestand, nicht dieser Slice; nicht als getragen behauptet).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`): Pin-Stellen, Emissions-Vorlage und Nutzerdoku; die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand (`79801cd8`) durchgegangen, Zähler = `ls <eintrag>/evidence/*.md | wc -l`, gemessen am 2026-10-16:
- `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` — 4, Stand verkörpert; als Risiko und in Schritt P übernommen.
- `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg` — 1, offen; als Risiko übernommen.
- `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` — 8, Stand geplant; als Risiko übernommen.
- `BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt` — 1, offen; als Risiko übernommen.
- `BEO-ALL/pin-digest-ohne-waechter` — Gegenstand sind Dockerfile-Digests und Wert-Fallbacks der Smoke-Skripte, nicht der Träger-Pin dieses Schnitts — gesichtet, kein Treffer.

**Stand bei der Closure (2026-10-16):** `ci-rennt-…` 4 · `ge-tagter-…` 1 · `waechter-misst-…` 9 · `kennung-traegt-…` 1 · neu `push-auf-den-geschuetzten-hauptzweig-…` 1 (`ls <eintrag>/evidence/*.md | wc -l`).

**Modus-Begründung:** alle berührten Sub-Areas GF.
