# Slice slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen: Der Kommentar über `langArchs()` nennt die Layouts, die die Tabelle trägt

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Digests eines Release-Stands sind
reproduzierbar), [`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md) und
[`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) (die Layouts von `python` und `csharp`);
Regel: [`AGENTS.md`](../../../../AGENTS.md) §3.7.

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-19.

---

## 1. Ziel und Abgrenzung

**Ziel:** Der Kommentar `STAND` über `langArchs()` in `internal/gen/gen.go` nennt für `python` und `csharp` `flat` und `hexslice`, wie
die Tabelle darunter, und trägt keine Slice-Nummern als Erzählung; die Kommentar-Änderung ändert keinen der sechs Release-Digests,
oder der Slice nennt, warum sie es tut.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Ein Release.** *Anderer Vorgang:* der Kommentar reist im nächsten Release-Schnitt mit; ein Tag allein dafür wäre ein Schnitt ohne Lieferwert.
- **Eine Änderung an `langArchs()` selbst oder anderem Code in `internal/`.** *Schnitt nach Lieferwert:* die Tabelle ist richtig, der Kommentar
  falsch; jede Verhaltens-Änderung wäre ein anderer Slice.
- **Weitere Kommentare in `internal/`, die Nummern als Erzählung tragen.** *Bestand bleibt bewusst stehen:* [`AGENTS.md`](../../../../AGENTS.md) §3.7
  nennt den Bestand kein Arbeitsauftrag; nur der Block über `langArchs()` wird angefasst.

## 2. Definition of Done

Liefer-Punkte (zwei):

- [ ] **L1 — Kommentar gleich Tabelle.** Der `STAND`-Block über `langArchs()` nennt je Sprache die Layouts, die `langArchs()` trägt
  (`go`: flat, hexslice, hexagonal; die übrigen fünf: flat, hexslice); der erste Satz „Heute tragen go … und cpp …" ist nicht mehr zutreffend
  und entfällt oder wird zum Zustand. Rot: eine Sprache aus der Tabelle nehmen und den Kommentar stehen lassen — der Lesende sieht die Differenz
  an `sed -n '/^func langArchs/,/^}/p' internal/gen/gen.go` gegen den Kommentar; ein Sensor existiert nicht, die Zusage hält die Lesung des Reviewers.
- [ ] **L2 — Digests gemessen.** `make release-artifacts DEST=<vorher> TRAEGER_VERSION=v0.10.0` am Stand vor und `…DEST=<nachher>` am Stand nach der
  Änderung; `diff <vorher>/SHA256SUMS <nachher>/SHA256SUMS`. Das Ergebnis steht im Bericht, gleich oder verschieden, mit der Zeilenzahl-Differenz
  des Kommentars. Frage, die der Lauf beantwortet und die der Planner nicht gemessen hat: der Bau läuft mit `-buildvcs=false`, `-trimpath` und
  `-ldflags="-s -w …"` (`Dockerfile`), also commit-unabhängig; ob eine Kommentar-Änderung mit **anderer Zeilenzahl** die Zeilen-Tabelle des Binarys
  verschiebt und damit die Bytes, ist ungemessen. Der Pin im `Makefile` (`TRAEGER_TAG`, `TRAEGER_SHA256_*`) zeigt auf das veröffentlichte Asset von
  `v0.10.0`, nicht auf den Quellstand; er bleibt unverändert, auch wenn L2 verschiedene Digests zeigt — `TRAEGER_VERSION` ist nur die Fassungs-Injektion
  des Baus, der Lauf schreibt allein nach `DEST`.

Gate-Läufe und Closure-Pflichten:

- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/gen/gen.go` (Kommentar über `langArchs()`) | update | L1 |
| `dist/` (lokal, nicht committet) | neu | L2: zwei Bauten, ein Vergleich |

Vor der Änderung: `grep -l 'internal/gen/gen.go' test/mutations/*.sh` — ein Mutations-Fall, der eine Zeilennummer oder ein Kommentar-Muster in
dieser Datei verankert, wandert mit (`BEO-ALL/mutations-fall-an-zeilennummer-verankert`).

**Ansatz:** den Block mit gleicher Zeilenzahl umschreiben, wo es trägt; ändert sich die Zahl, misst L2 den Unterschied statt ihn zu vermuten.

## 4. Trigger

**Start** (`next` → `in-progress`): Priorisierung durch den Nutzer; WIP-Limit frei; `git describe --tags --abbrev=0` nennt `v0.10.0` oder jünger.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next`: L2 zeigt andere Digests, und der Nutzer will den Kommentar nicht in einem Release-Stand tragen, der die Pins ändert —
  die Entscheidung gehört dann vor die Änderung.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar.

## 5. Closure-Trigger

DoD vollständig, Review-Report liegt vor, Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Die Kommentar-Änderung ändert die Bytes der Binaries und macht die sechs Pins des gerade veröffentlichten Releases zu einem Stand, der nicht
  mehr aus dem Baum reproduzierbar ist — **Ausgang:** bei Closure aus L2 gesetzt — *entfallen*, wenn die Digests gleich sind, sonst *eingetreten* mit Folge-Slice.

## 7. Closure-Notiz

Wird vom Planner in frischem Kontext geschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`); die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register am Stand `d5f25549` durchgegangen: `BEO-ALL/mutations-fall-an-zeilennummer-verankert` trifft die
Anker-Frage (Prüfung in §3); sonst keine Treffer.

**Modus-Begründung:** alle berührten Sub-Areas GF.
