# Slice slice-release-schnitt-v071-liefert-die-baseline-v6181: Der Release-Schnitt `v0.7.1` liefert die Baseline `v6.18.1` im gebootstrappten Ziel

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

**Verantwortlich:** — (gesetzt beim Übergang `open` → `next`)

**Autor:** Planner. **Datum:** 2026-10-16.

---

## 1. Ziel und Abgrenzung

**Ziel:** Das Release `v0.7.1` ist veröffentlicht und vollzogen gemeldet: Träger und emittierte Vorlagen tragen den
Stand von [`slice-sprung-auf-v6181-wird-vollzogen`](../next/slice-sprung-auf-v6181-wird-vollzogen.md), der Pin zeigt auf den geschnittenen Stand,
und das Benutzerhandbuch beschreibt den Ist-Zustand.

**Versionswahl:** `v0.7.1`, **vom Auftraggeber gewählt** (2026-10-16); der vorige Tag ist `v0.7.0`
(`git tag --sort=-v:refname | head -1`). **Abweichung, benannt statt umgedeutet:** [`releasing.md`](../../../user/releasing.md)
§Versionsnummer zählt einen Sprung der adoptierten Baseline und eine geänderte emittierte Datei zu `minor`; `patch` ist
für einen Schnitt, der nur Fehler behebt. Dieser Schnitt trägt einen Baseline-Patch-Sprung ohne Regel-Änderung und emittierte
Vorlagen mit anderer Adress-Form. Die Tag-Wahl ist Entscheidung des Auftraggebers; wählt er `v0.8.0`, ersetzt der Implementer
`v0.7.1` an allen Stellen von §3 — und die Kennung dieses Slice nennt dann einen überholten Stand (§6).

**Gegenstände des Schnitts:** gemessen mit `git log --oneline v0.7.0..HEAD -- internal/ cmd/`; am Planungs-Stand `79801cd8`
ist die Menge leer, der Gegenstand ist allein der Sprung auf `v6.18.1` samt Emitter-Folge
([`slice-sprung-auf-v6181-wird-vollzogen`](../next/slice-sprung-auf-v6181-wird-vollzogen.md)). Der Implementer misst am Tag-Baum neu und trägt jeden
weiteren Commit mit seinem Slice in diese Tabelle, bevor er ihn liefert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Weiterer Funktionsinhalt.** *Schnitt nach Lieferwert:* jede Programm- oder Vorlagen-Änderung wäre ein anderer Slice, und der
  Verifier hielte den Tag-Baum nicht mehr gegen einen geprüften Stand.
- **Ein Signier-Schritt für die Assets.** *Bestand bleibt bewusst stehen:* [`releasing.md`](../../../user/releasing.md) §Grenze führt ihn.
- **Anlage oder Rotation des Repo-Secrets `HOMEBREW_TAP_GITHUB_TOKEN`.** *Anderer Vorgang:* außerhalb der Prozedur
  ([`releasing.md`](../../../user/releasing.md) Schritt 7); Sache des Auftraggebers.

## 2. Definition of Done

Liefer-Punkte (drei):

- [ ] **L1 — Tag-Baum vorbereitet und verifiziert** (Schritte 1 bis 4 der Prozedur). `TRAEGER_TAG` in
      `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in `test/traeger-fetch.bats` zeigen auf `v0.7.1`;
      `make release-artifacts DEST=dist TRAEGER_VERSION=v0.7.1` baut die sechs Binaries und `dist/SHA256SUMS`;
      `bash harness/tools/release-sums.sh verify dist` endet mit Exit 0; `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im
      `Makefile` tragen den Tag und die gemessenen Digests; `make gates` ist grün auf dem Commit, der den Tag tragen wird.
  - Rot (ohne Netz): ein Byte eines Assets in einer Kopie von `dist/` ändern — `release-sums.sh verify` endet mit Exit ≠ 0 und
    nennt die Datei; den Tag der Vorlage vom Tag im `Makefile` trennen — die Kopplung in `test/traeger-fetch.bats` färbt rot.
  - Rot an der realen Quelle: einen Digest im realen `Makefile` verfälschen und `bats test/traeger-fetch.bats` fahren; färbt kein Fall,
    steht die bekannte Lücke („realer `Makefile`-Digest ungebunden") im Bericht, nicht verdeckt durch Fixture-Grün.
- [ ] **L2 — Handbuch im Ist-Zustand** (`docs/user/benutzerhandbuch.md`; Zeilen am Tag-Baum neu messen):
  - Stand: `grep -n 'v0\.7\.0' docs/user/benutzerhandbuch.md` → `**Software-Stand:**` und „aktuell ausgeliefert wird" auf `v0.7.1`.
  - Baseline: `grep -n 'v6\.18\.0' docs/user/benutzerhandbuch.md README.md` — die Beispiel-Ausgabe des Bootstraps nennt die Baseline des Ziels; sie
    steht auf `v6.18.1`, sobald der Träger sie so ausgibt.
  - Weitere Versions-Pins: `grep -n -E 'v0\.8[0-9]|v0\.2[0-9]|v6\.1[0-9]' docs/user/benutzerhandbuch.md README.md` messen; nur ziehen, was ein Ist-Zustand nennt.
  - Nur Ist-Zustand: keine Chronik, keine Prognose. `make docs-check` rot bei totem Link/Anker; dass die Aussagen stimmen, hält kein Gate —
    der Reviewer liest sie gegen die Vorlagen am Tag-Baum.
- [ ] **L3 — Veröffentlicht, belegt, gemeldet** (Schritte 5 bis 8). Der Tag-Push ist ein eigener, benannter Schritt (**Schritt P** in §3)
  und braucht die ausdrückliche Freigabe des Auftraggebers; der Release trägt acht Assets
  (`gh release view v0.7.1 --json assets --jq '.assets | length'` → `8`); `make traeger-fetch` hält das veröffentlichte Asset gegen den Pin;
  `ci` an `main` und am Tag grün (gefallene `full-smoke`-Jobs nach abgeschlossener Publikation per `gh run rerun --failed`);
  Job `tap` grün und `make tap-check TAG=v0.7.1` Exit 0, die Meldung trägt dessen Ausgabezeile; der Release-Text trägt Stand, Assets, Grenze,
  die Gegenstände aus §1 und, falls der Vergleich zweier frischer Emissionen (Träger `v0.7.0` gegen `v0.7.1`,
  [`releasing.md`](../../../user/releasing.md) Schritt 5) Dateien der zweiten Klasse ändert, den Abschnitt **Bestand**.
  - Rot (Pin passt nicht zum Asset): ein verfälschter `TRAEGER_SHA256_*` lässt `make traeger-fetch` mit Exit ≠ 0 enden, bevor etwas
    abgelegt wird — nach der Publikation fahren und belegen; sonst steht es als Lücke in §7.
  - Fällt der Job `tap`: `make tap-nachzug TAG=v0.7.1` mit `TAP_TOKEN` des Auftraggebers, danach `make tap-check`.

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
4. **Schritt P — Push von `main` und Tag-Push** (Implementer-Kontext, zweiter Lauf; Schritte 5 bis 7 der Prozedur). Erst nach grünem
   Verifier-Bericht **und** grünem `make gates` auf dem dann finalen Commit. **Der Tag-Push ist nach außen wirksam und wird erst gefahren,
   wenn der Auftraggeber ihn ausdrücklich freigibt — der Auftraggeber hat `v0.7.1` gewählt und will vor dem Tag-Push noch einmal gefragt werden.**
   `main` und Tag gehen in einem Zug nach der Freigabe, der Tag unmittelbar nach `main`: `make release-warten` trägt nur innerhalb seiner
   Grenze ([`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)).
   **Freigabe-Vermerk:** ausstehend — der Implementer trägt hier Datum und Wortlaut der Freigabe ein, bevor er pusht.
5. **Planner-Closure** — nach Schritt 8 (Meldung), in eigenem Commit.

## 4. Trigger

**Start** (`next` → `in-progress`): [`slice-sprung-auf-v6181-wird-vollzogen`](../next/slice-sprung-auf-v6181-wird-vollzogen.md) liegt in `done/`; kein Slice liegt in `in-progress/`
(`ls docs/plan/planning/in-progress/` nennt nur die Roadmap); `git tag --sort=-v:refname | head -1` nennt `v0.7.0`; der Auftraggeber bestätigt die
Tag-Wahl `v0.7.1`; WIP-Limit frei.

**Rückführungen:**

- `in-progress` → `next`: ein Plattform-Bau bricht und verlangt eine Code-Änderung jenseits eines Build-Tags — sie wird eigener Slice, dieser bleibt reiner Schnitt.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar, oder der Auftraggeber zieht die Freigabe des Tag-Pushs zurück.

## 5. Closure-Trigger

DoD vollständig, Verifier-Bericht am Tag-Baum ohne Blocker, `ci` an `main` und am Tag grün, `make tap-check TAG=v0.7.1` mit Exit 0, Meldung an den
Auftraggeber und Closure-Notiz mit Lerneintrag. Nicht Closure-Trigger: ein gepushter Tag allein.

## 6. Risiken und offene Punkte

- Ein Plattform-Asset baut nicht — **Ausgang:** bei der Closure.
- Die Tag-Wahl `patch` weicht vom Wortlaut von [`releasing.md`](../../../user/releasing.md) ab; ein Adopter liest `v0.7.1` als reine Fehlerbehebung —
  **Ausgang:** bei der Closure; die Entscheidung des Auftraggebers steht in §1.
- Der Gates-Beleg reist nicht mit dem Tag; Report-Commits ändern den Baum nach dem Stempel — **Ausgang:** bei der Closure
  ([`BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`](../observations/BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg/observation.md)).
- `ci` fällt im `full-smoke` mit 404, falls der `release`-Lauf nicht innerhalb der Grenze von `make release-warten` publiziert — **Ausgang:** bei der Closure
  ([`BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`](../observations/BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases/observation.md)).
- Der reale `Makefile`-Digest ist ungebunden; den Pin gegen das Asset hält erst `make traeger-fetch` nach der Publikation — **Ausgang:** bei der Closure
  ([`BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`](../observations/BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle/observation.md)).
- Die Kennung dieses Slice trägt den Tag, den der Schnitt selbst überholt, falls der Auftraggeber einen anderen wählt — **Ausgang:** bei der Closure
  ([`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`](../observations/BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt/observation.md)).

## 7. Closure-Notiz

Wird vom Planner bei der Closure in frischem Kontext geschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`): Pin-Stellen, Emissions-Vorlage und Nutzerdoku; die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register am gemergten Stand (`79801cd8`) durchgegangen, Zähler = `ls <eintrag>/evidence/*.md | wc -l`, gemessen am 2026-10-16:
- `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` — 4, Stand verkörpert; als Risiko und in Schritt P übernommen.
- `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg` — 1, offen; als Risiko übernommen.
- `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` — 8, Stand geplant; als Risiko übernommen.
- `BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt` — 1, offen; als Risiko übernommen.
- `BEO-ALL/pin-digest-ohne-waechter` — Gegenstand sind Dockerfile-Digests und Wert-Fallbacks der Smoke-Skripte, nicht der Träger-Pin dieses Schnitts — gesichtet, kein Treffer.

**Modus-Begründung:** alle berührten Sub-Areas GF.
