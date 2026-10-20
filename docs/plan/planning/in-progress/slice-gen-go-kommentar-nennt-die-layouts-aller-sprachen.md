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

- [x] **L1 — Kommentar gleich Tabelle.** Der `STAND`-Block über `langArchs()` nennt je Sprache die Layouts, die `langArchs()` trägt
  (`go`: flat, hexslice, hexagonal; die übrigen fünf: flat, hexslice); der erste Satz „Heute tragen go … und cpp …" ist nicht mehr zutreffend
  und entfällt oder wird zum Zustand. Rot: eine Sprache aus der Tabelle nehmen und den Kommentar stehen lassen — der Lesende sieht die Differenz
  an `sed -n '/^func langArchs/,/^}/p' internal/gen/gen.go` gegen den Kommentar; ein Sensor existiert nicht, die Zusage hält die Lesung des Reviewers.
- [x] **L2 — Digests gemessen.** `make release-artifacts DEST=<vorher> TRAEGER_VERSION=v0.10.0` am Stand vor und `…DEST=<nachher>` am Stand nach der
  Änderung; `diff <vorher>/SHA256SUMS <nachher>/SHA256SUMS`. Das Ergebnis steht im Bericht, gleich oder verschieden, mit der Zeilenzahl-Differenz
  des Kommentars. Frage, die der Lauf beantwortet und die der Planner nicht gemessen hat: der Bau läuft mit `-buildvcs=false`, `-trimpath` und
  `-ldflags="-s -w …"` (`Dockerfile`), also commit-unabhängig; ob eine Kommentar-Änderung mit **anderer Zeilenzahl** die Zeilen-Tabelle des Binarys
  verschiebt und damit die Bytes, ist ungemessen. Der Pin im `Makefile` (`TRAEGER_TAG`, `TRAEGER_SHA256_*`) zeigt auf das veröffentlichte Asset von
  `v0.10.0`, nicht auf den Quellstand; er bleibt unverändert, auch wenn L2 verschiedene Digests zeigt — `TRAEGER_VERSION` ist nur die Fassungs-Injektion
  des Baus, der Lauf schreibt allein nach `DEST`.

Gate-Läufe und Closure-Pflichten:

- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), kein Self-Review.
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
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
  **Closure-Ausgang:** *entfallen* — die Byte-Änderung trat ein (alle sechs Digests verschieden), ihre Folge nicht: Der Pin zeigt auf das veröffentlichte Asset des Tags und
  ist am Tag-Stand exakt reproduzierbar (§7); am HEAD war er es schon vor der Änderung nicht (vier Commits mit Code seit dem Tag). Kein Folge-Slice, weil die Nutzerentscheidung
  (§4: Kommentar behalten, Pin bleibt) keinen verlangt; die Digests wandern mit dem nächsten Release-Schnitt.

## 7. Closure-Notiz

- **Was hat funktioniert:** L1 gelesen (Reviewer, Verifier): der `STAND`-Block über `langArchs()` nennt `go` mit flat, hexslice, hexagonal und die übrigen fünf mit
  flat, hexslice, gleich der Tabelle; Chronik und Slice-Nummern sind aus dem Block entfallen; ein Sensor hält den Kommentar nicht gegen die Tabelle (Grenze steht im
  Kommentar). L2 gefahren: der Kommentar (11 hinzu, 15 weg, netto −4 Zeilen) ändert **alle sechs** Zeilen von `SHA256SUMS`; ein zweiter Bau am selben Stand ist
  byte-gleich (Verifier). **Gemessene Eigenschaft, mit Grenze:** ein reiner Kommentar mit −4 Zeilen ändert die Bytes; die Ursache (Zeilentabelle des Binarys) ist eine
  Vermutung und **nicht isoliert**, die zeilenzahlgleiche Variante ist **ungemessen**. Reproduzierbar ist der **Tag-Stand**: ein Bau am Tag `v0.10.0` (Worktree auf dem Tag,
  `make release-artifacts TRAEGER_VERSION=v0.10.0`) trifft die sechs `TRAEGER_SHA256_*` im `Makefile` exakt (`comm`: 0 Abweichungen, 6 Digests); der HEAD war es
  schon vor diesem Slice nicht — `git log --oneline v0.10.0..HEAD -- internal | wc -l` nennt vier Commits mit Code. Damit ist der Zusatzbefund des Verifiers (Digests am
  Vorstand `d71e8cdd` ≠ Pin) erklärt; der Pin war nie kaputt. Mutations-Fälle mit Anker in `internal/gen/gen.go`: 13; CI-Probe auf
  `mutate/…-7cc9f961` (Nutzerfreigabe, danach gelöscht): 12 ok, einer ohne Ergebnis (445, Zeitschranke 900 s, s. u.), lokal rot gesehen — alle 13 belegt, 12 CI, 1 lokal.
  Review: kein HIGH, kein MEDIUM, 1 LOW, 2 INFO ([Report](../../../reviews/2026-10-20-slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen.md));
  Verifier: L1 bestätigt (gelesen), L2 bestätigt (gefahren) ([Report](../../../reviews/2026-10-20-slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen-verify.md)).
- **Was ging anders als geplant:** (1) Die Rückführungs-Bedingung aus §4 (L2 zeigt andere Digests) trat ein; der Nutzer entschied: Kommentar behalten, kein
  Rückführen, `TRAEGER_TAG v0.10.0` und die sechs `TRAEGER_SHA256_*` bleiben unverändert (`git diff d71e8cdd..HEAD --stat -- Makefile` leer). (2) §6 setzte den Ausgang
  des Risikos auf „eingetreten mit Folge-Slice, wenn die Digests verschieden sind"; die Annahme dahinter (Pin am HEAD vor der Änderung reproduzierbar) trägt nicht
  (Review LOW, oben). Der Ausgang steht in §6 mit Begründung; das Abnahmekriterium wird nicht umgeschrieben. (3) Ein Fall der Mutations-Probe blieb ohne Ergebnis und
  wurde lokal nachgeholt.
- **Laufzeit ([`MR-089`](../../../../harness/conventions.md#mr-089)):** CI (`mutate-branch`, Linux-Runner, Image-Lage nicht erhoben): Fall 444 `full-smoke` 862 s im selben Lauf;
  Fall 445 ohne Ergebnis nach 900 s Stille. Lokal (Verifier, macOS-Host, Colima, `SMOKE_ARTIFACT_TARGET=artifact-host`, Rest warm): Fall 444 304 s plus 424 s
  Grün-Vorlauf. Fall 445 lokal rot gesehen (1 ok, 0 Befund(e)); seine Dauer ist nicht berichtet. Ungemessen: die Aufteilung der 862 s auf Vorlauf und Fall, kalter
  Cache der CI, jede Deutung der Differenz zwischen 304 s und 862 s. Keine Deutung.
- **Steering-Loop-Eintrag:** benannte Lücke, keine Spec-Lücke und nicht verkörpert (kein `liegt in`, kein 3×-Übertritt): Die Zeitschranke des Treibers (`STALL_SECONDS` 900 s,
  Herleitung im Kopf von `harness/tools/mutate.sh`: längste legitime Stille 148,97 s, CI 2,4× langsamer, „NICHT gedeckt: ein Fall, der langsamer als die Schranke, aber
  endlich ist. Heute gibt es keinen") trägt in der CI einen `full-smoke`-Fall nicht; ein Fall ohne Ergebnis an dieser Stelle ist kein roter Wächter. Ort:
  `BEO-ALL/mutate-zeitschranke-trifft-den-full-smoke-fall-in-der-ci` (1×, offen). Zweiter Teil, am Vorgang geschärft: ein Risiko, das Reproduzierbarkeit „aus dem Baum"
  zusagt, nennt den Bezugsstand — der Tag-Stand trägt die Pins, der HEAD nicht; die Messung am Tag ist der Beleg. Ort: Beleg im Register
  (`abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt`, verkörpert in [`AGENTS.md`](../../../../AGENTS.md) §3.10); ein Wächter existiert nicht.
- **Beobachtungs-Register (`../observations/`):** neu `BEO-ALL/mutate-zeitschranke-trifft-den-full-smoke-fall-in-der-ci` (1×, offen), Beleg
  `evidence/slice-gen-go-kommentar-nennt-die-layouts-aller-sprachen.md`; ergänzt `BEO-ALL/abnahme-kriterium-traegt-annahme-die-der-vorgang-widerlegt` (11×, verkörpert,
  `state.md` unverändert). Zitiert ohne Beleg, andere Ursache: `BEO-ALL/gruen-vorlauf-eines-mutate-workers-faellt-unter-runner-last` (roter Test unter Last, hier keiner),
  `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` (404, hier keiner), `BEO-ALL/mutations-fall-an-zeilennummer-verankert` (aus §8: alle 13 Anker liegen auf
  Code, drei gegen den neuen Stand gezählt, kein Auftreten).
- **Abgrenzung zu `slice-mutate-branch-worker-wartet-die-publikation-ab` (open):** dessen Gegenstand ist ein Warte-Schritt `make release-warten` vor dem Grün-Vorlauf des
  Workers gegen die 404-Klasse. Die Zeitschranke 900 s liegt in `harness/tools/mutate.sh`, ist ein anderer Ort mit anderer Ursache und nicht sein Gegenstand; sein Plan
  wird nicht angefasst. Ob sie ein eigener Slice wird, entscheidet die Schwelle des Registers (3×) oder der Nutzer.
- **Folge-Slices:** keiner. Die Nutzerentscheidung in §4 verlangt keinen; ein Slice nur um die Form des Plan-Ausgangs zu erfüllen hätte keinen Gegenstand.
- **Trigger-Audit dieser Closure:** `CO-001` und `CO-002` unberührt; kein bootstrap-aware Gate berührt; keine ADR mit Re-Evaluierungs-Trigger berührt; Hard Rules tragen
  *permanent* oder ihren Trigger unverändert. Nichts fällig durch diesen Slice.
- **Archivierung ([`MR-078`](../../../../harness/conventions.md#mr-078)):** nicht ausgeführt: `ls docs/plan/planning/done/*/archiv.zip` findet keines, `archive-welle` bricht an der
  Untergrenze; der Slice bleibt flach in `done/`.
- **Risiken aus §6:** das eine Risiko hat seinen Ausgang in §6.
- **Drei Paarungen:** —

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`); die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register am Stand `d5f25549` durchgegangen: `BEO-ALL/mutations-fall-an-zeilennummer-verankert` trifft die
Anker-Frage (Prüfung in §3); sonst keine Treffer.

**Modus-Begründung:** alle berührten Sub-Areas GF.
