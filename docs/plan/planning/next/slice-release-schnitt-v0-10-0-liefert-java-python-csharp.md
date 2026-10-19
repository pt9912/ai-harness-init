# Slice slice-release-schnitt-v0-10-0-liefert-java-python-csharp: Der Release-Schnitt `v0.10.0` liefert die Sprachprofile `java`, `python` und `csharp`

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
[`slice-release-schnitt-v090-liefert-toolchain-pins-und-sperr-budget`](../done/slice-release-schnitt-v090-liefert-toolchain-pins-und-sperr-budget.md)).

**Bezug:**
[`LH-FA-04`](../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) (die ausgelieferten Sprachen),
[`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (Pin trägt Version + sha256),
[`LH-QA-04`](../../../../spec/lastenheft.md#lh-qa-04--plattform-matrix) (die sechs Assets),
[`ADR-0058`](../../adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md) Festlegung 2 (Pin und Fassung im selben Vorgang),
[`ADR-0059`](../../adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) (`SHA256SUMS` als Release-Asset),
[`ADR-0064`](../../adr/0064-tap-nachzug-ein-skript-zwei-aufrufer-byte-kontrolle-gegen-das-asset.md) (Tap-Nachzug);
geliefert werden die Profile aus [`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md),
[`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md),
[`ADR-0096`](../../adr/0096-csharp-skelett-toolchain-und-schicht-aufloesung.md) und
[`ADR-0097`](../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md).

**Berührte Spec-Stellen:** —

**Verantwortlich:** dburkard

**Autor:** Planner. **Datum:** 2026-10-19.

---

## 1. Ziel und Abgrenzung

**Ziel:** Das Release `v0.10.0` ist veröffentlicht und vollzogen gemeldet: das Programm kennt `java`, `python` und `csharp` samt
`--arch hexslice`, der Pin zeigt auf den geschnittenen Stand, und das Benutzerhandbuch beschreibt den Ist-Zustand ohne Quellstand-Hinweis.

**Versionswahl (gesetzt):** `v0.10.0`; der vorige Tag ist `v0.9.0` (`git describe --tags --abbrev=0`). Der Nutzer hat die Nummer entschieden;
sie folgt dem Minor-Schritt von [`releasing.md`](../../../user/releasing.md) §Versionsnummer (neue Option-Werte und neue emittierte Dateien,
`patch` zurück auf `0`). Besonderheiten für `0.9.0` → `0.10.0`, an `releasing.md` gelesen:

- Der Minor-Teil ist zweistellig. Die Prozedur vergleicht an der einen Stelle, die Versionen ordnet, **numerisch je Feld**
  (Vorwärts-Schutz des Tap-Nachzugs, Schritt 7): `0.10.0` ist größer als `0.9.0`, der Nachzug läuft. Ein lexikalischer Vergleich ordnete falsch;
  der Schutz tut es nicht.
- Pin-Stellen sind die der Schritte 1 und 2: `TRAEGER_TAG` in `internal/emit/templates/enforce/traeger.mk`, der Tag-Wert in
  `test/traeger-fetch.bats`, `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im `Makefile`; `TRAEGER_VERSION=v0.10.0` am Bau.
- Das Handbuch trägt die Version an `**Software-Stand:**` (Zeile 3) und an „aktuell ausgeliefert wird" (Zeile 81); Tag und Handbuch ziehen im selben Schnitt.
- Kein Vorab-Tag: der Tap-Nachzug schreibt (Schritt 7). `releasing.md` nennt sonst keine Besonderheit für diesen Sprung.

**Namenswahl.** Die Kennung trägt die Version in der Kebab-Form `v0-10-0` — `v0100` wäre neben `v100` (1.0.0) mehrdeutig; die Vorgänger
(`v070`, `v090`) folgen dem Muster ohne Trenner, solange `minor` einstellig ist. Die Werkzeug-Stände stehen nicht im Namen (Beobachtung
`BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt`).

**Gegenstände des Schnitts:** `git log --oneline v0.9.0..HEAD -- internal/ cmd/` nennt am Stand `3886a1bc` 13 Commits; der Implementer misst am Tag-Baum
neu und trägt jeden Commit mit Gegenstand in eine Tabelle (Commit · Gegenstand · gebaut/emittiert in), bevor er liefert. Erwartung, nicht Ergebnis:

1. **Sprachprofile `java`, `python`, `csharp`** (`add-lang` und `--lang`), samt Toolchain-Pins je Sprache ([`ADR-0094`](../../adr/0094-java-skelett-toolchain-und-schicht-aufloesung.md) bis `0096`).
2. **`--arch hexslice` für alle sechs Sprachen** (Java, Python, C# neu; [`ADR-0095`](../../adr/0095-python-skelett-toolchain-und-schicht-aufloesung.md) bis `0097`); `--arch hexagonal` bleibt Go.
3. **Benutzerhandbuch:** sechs Sprachen, Sprachbäume, kein Quellstand-Hinweis mehr.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der Tag-Push, `git push origin main` und der Release-Lauf.** *Anderer Vorgang, nach außen wirksam:* der Nutzer gibt ihn ausdrücklich frei
  (Schritt P in §3); die Versionsentscheidung ist keine Freigabe. Dieser Slice nennt Vorbedingungen und Befehle, fährt sie nicht.
- **`slice-archiv-wird-nach-dem-schreiben-gelesen-und-geprueft`.** *Folge-Slice, Nutzerentscheidung:* er kommt nach dem Release; er ist der Träger
  seines Gegenstands und nimmt keinen Gegenstand dieses Schnitts auf.
- **Die Closure der Welle `welle-sprachprofile-java-python-csharp`.** *Anderer Vorgang:* sie hat eigene Closure-Schritte (Modul 6);
  der Schnitt liefert, was die Welle gebaut hat, und schließt sie nicht.
- **Neue Sprachen oder weiterer Funktionsinhalt.** *Schnitt nach Lieferwert:* jede Programm- oder Vorlagen-Änderung wäre ein anderer Slice,
  und der Verifier hielte den Tag-Baum nicht mehr gegen einen geprüften Stand.
- **Ein Signier-Schritt, Anlage oder Rotation des Tap-Tokens.** *Bestand bleibt bewusst stehen / anderer Vorgang:*
  [`releasing.md`](../../../user/releasing.md) §Grenze und Schritt 7 führen beides.

## 2. Definition of Done

Liefer-Punkte (drei):

- [ ] **L1 — Version gezogen, Tag-Baum vorbereitet und verifiziert** (Schritte 1 bis 4; Punkt (a) des Auftrags).
  `TRAEGER_TAG` in `internal/emit/templates/enforce/traeger.mk` und der Tag-Wert in `test/traeger-fetch.bats` zeigen auf `v0.10.0`;
  `make release-artifacts DEST=dist TRAEGER_VERSION=v0.10.0` baut sechs Binaries und `dist/SHA256SUMS`;
  `bash harness/tools/release-sums.sh verify dist` endet mit Exit 0; `TRAEGER_TAG` und die sechs `TRAEGER_SHA256_*` im `Makefile` tragen Tag und
  gemessene Digests; Handbuch: `**Software-Stand:**` und „aktuell ausgeliefert wird" auf `v0.10.0`, der **Quellstand-Hinweis** am Kopf und
  alle Verweise darauf entfernt (`grep -n 'Quellstand\|v0\.9\.0' docs/user/benutzerhandbuch.md` ohne Treffer, die ausgenommen, die den
  Vorgänger als Vorgänger nennen — Messung am Tag-Baum, Zeilen wandern); die Sprachaufzählungen (Kopf, `--lang`-Tabelle, Fehlermeldung zu
  unbekannter Sprache, `hexslice`-Grenzen) gegen den Tag-Baum geprüft: `ai-harness-init --lang <unbekannt>` des **gebauten** Binaries nennt dieselbe
  Liste wie das Handbuch (`BEO-ALL/handbuch-nennt-sprachen-die-der-download-nicht-kennt` trägt die Bedingung). `make gates` grün auf dem Commit,
  der den Tag tragen wird.
  - Rot: ein Byte eines Assets in einer Kopie von `dist/` ändern — `release-sums.sh verify` endet mit Exit ≠ 0 und nennt die Datei; den Tag
    der Vorlage vom Tag im `Makefile` trennen — die Kopplung in `test/traeger-fetch.bats` färbt rot; ein Digest im realen `Makefile` verfälscht,
    dann `bats test/traeger-fetch.bats` — färbt kein Fall, steht die bekannte Lücke („realer `Makefile`-Digest ungebunden") im Bericht.
- [ ] **L2 — Release-Text bereit** (Punkt (b); [`releasing.md`](../../../user/releasing.md) Schritt 5). Eine Datei außerhalb des Repos
  (Scratchpad des Laufs) mit Titelzeile, **Stand**, **Assets**, **Grenze**, den Gegenständen aus §1 und der Zeile *Full Changelog*; ein Changelog im Repo
  verlangt `releasing.md` nicht und entsteht nicht. Abschnitt **Bestand** nach der Messaufgabe der Prozedur: Träger `v0.9.0` gegen Träger `v0.10.0`,
  je frisches Git-Repository, über neun Optionssätze — ohne `--lang` · `--lang go` · `go --arch hexagonal` · `go --arch hexslice` · `--lang cpp` ·
  `--lang kotlin` · `--lang java` · `--lang python` · `--lang csharp` (die drei neuen kennt der Vorgänger-Träger nicht; ihr Ergebnis ist „Exit 2 beim
  Vorgänger", kein Diff) —, `diff -rq -x .git <alt> <neu>`, beschränkt auf die zweite Klasse; der Abschnitt entfällt nur bei leerem Ergebnis aller Sätze.
  Die Zusage nennt, was sie misst; Laufzeit-Aussagen nach [`MR-089`](../../../../harness/conventions.md#mr-089).
- [ ] **L3 — Veröffentlichung benannt, nicht gefahren** (Punkt (c)). §3 Schritt P nennt Vorbedingungen und Befehlsfolge, der Freigabe-Vermerk
  steht „ausstehend". Vorbedingungen: L1 und L2 erfüllt; Review- und Verifier-Bericht am Tag-Baum **vor** dem Push; `make gates` frisch auf dem finalen Commit;
  `main` und Tag gehen unmittelbar nacheinander (`make release-warten` trägt nur innerhalb seiner Grenze). Befehle (Nutzer-freigegeben):
  `git tag -a v0.10.0 <commit>`, `git push origin main`, `git push origin v0.10.0`; danach Schritte 6 bis 8 (CI am Tag, `make tap-check TAG=v0.10.0`,
  `gh release edit v0.10.0 --notes-file <datei>`, acht Assets).

Gate-Läufe und Closure-Pflichten:

- [ ] `make gates` grün am Tag-Baum (siehe L1).
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor (`.harness/skills/reviewer.md`), Verifier-Bericht am Tag-Baum **vor** dem Tag-Push — kein Self-Review.
- [ ] Doku-Update: Handbuch (L1); [`releasing.md`](../../../user/releasing.md) bleibt unverändert, solange die Prozedur trägt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag, vom Planner in frischem Kontext ([`AGENTS.md`](../../../../AGENTS.md) §3.10).
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben oder „keine Beobachtung angefallen" in §7.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/emit/templates/enforce/traeger.mk` (`TRAEGER_TAG`) | update | Schritt 1: Vorlage ist eingebettet |
| `test/traeger-fetch.bats` | update | Schritt 1: Tag-Wert der Fälle, Kopplung bleibt scharf |
| `Makefile` (`TRAEGER_TAG`, sechs `TRAEGER_SHA256_*`) | update | Schritt 2: Pin im selben Commit ([`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) |
| `docs/user/benutzerhandbuch.md` | update | L1: Version, Quellstand-Hinweis, Aufzählungen |
| `dist/` (lokal, nicht committet) | neu | Schritte 1 und 3 |

**Freshness und Pins.** `releasing.md` verlangt vor dem Schnitt keinen Freshness-Lauf; `make freshness-digest` und die `freshness-*`-Ziele sind
nur nächtlich (`upstream-drift.yml`) und nicht in `make gates`. Der Implementer fährt sie vor Schritt 1 einmal als Hinweis (Netz, read-only) und
nennt jeden Befund im Bericht; ein Befund ändert die Pins nicht in diesem Slice (anderer Slice, siehe §1), er steht im Release-Text unter **Grenze**,
wenn ein Image-Pin der neuen Skelette betroffen ist. Der Nutzer hat den Hinweis-Lauf gewollt (§6).

Reihenfolge der Rollen:

1. **Implementer** — L1 und L2: ein Commit mit Vorlage, Pin und Handbuch; **kein** Push, **kein** Tag.
2. **Reviewer** — Diff gegen Plan und Prozedur; liest die Handbuch-Aussagen gegen das gebaute Binary.
3. **Verifier** — am Tag-Baum vor dem Push: Digests nachgerechnet, `make gates` frisch, bewusstes Brechen des realen Pins, Bestand-Messung wiederholt.
4. **Schritt P — Push und Tag** (Schritte 5 bis 8), nur nach ausdrücklicher Freigabe des Nutzers und grünem Verifier-Bericht.
   **Freigabe-Vermerk:** ausstehend.
5. **Planner-Closure** nach Schritt 8, eigener Commit.

## 4. Trigger

**Start** (`next` → `in-progress`): `ls docs/plan/planning/in-progress/` nennt nur die Roadmap; `git describe --tags --abbrev=0` nennt `v0.9.0`;
WIP-Limit frei; Priorisierung durch den Nutzer.

**Rückführungen:**

- `in-progress` → `next`: ein Plattform-Bau bricht und verlangt eine Code-Änderung jenseits eines Build-Tags, oder der Tag-Baum trägt eine
  Programm-Änderung, die kein Gegenstand aus §1 ist — sie wird eigener Slice.
- `in-progress` → `open`: kein Docker-Build-Kanal erreichbar, oder der Nutzer zieht Version oder Freigabe zurück.

## 5. Closure-Trigger

DoD vollständig, Verifier-Bericht am Tag-Baum ohne Blocker, `ci` an `main` und am Tag grün, `make tap-check TAG=v0.10.0` mit Exit 0, Meldung an den
Nutzer und Closure-Notiz mit Lerneintrag. Nicht Closure-Trigger: ein gepushter Tag allein.

## 6. Risiken und offene Punkte

- Der Gates-Beleg reist nicht mit dem Tag; Report-Commits ändern den Baum nach dem Stempel — **Ausgang:** weiter offen → `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg` im Register (Ausgang bei Closure nach dem Lauf).
- `ci` fällt im `full-smoke` mit 404, wenn der Release-Lauf nicht innerhalb der Grenze von `make release-warten` publiziert — **Ausgang:** weiter offen → `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases` im Register.
- Der reale `Makefile`-Digest ist ungebunden, bis `make traeger-fetch` nach der Publikation läuft — **Ausgang:** weiter offen → `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle` im Register.
- Das Handbuch nennt nach dem Entfernen des Hinweises etwas, das das Binary nicht kann (Prosa der Sprachbäume ist ungehalten, `BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke`) — **Ausgang:** weiter offen → dieser Eintrag; der Reviewer liest die Prosa gegen das gebaute Binary.
- Ein Image-Pin der neuen Skelette ist beim Schnitt veraltet (Freshness nicht Teil der Prozedur) — **Ausgang:** weiter offen → Register, falls ein Befund anfällt; sonst entfallen mit dem Lauf als Beleg.
- Die Kennung trägt einen überholbaren Stand — **Ausgang:** entfallen; die Version ist vom Nutzer gesetzt, `v0.10.0` ist der höchste Tag nach dem Schnitt, Werkzeug-Stände stehen nicht im Namen.

Entschieden vom Nutzer: (1) Der Freshness-Hinweis-Lauf (`make freshness-digest` und die übrigen `freshness-*`-Ziele, Netz, nur Hinweis) läuft einmal vor Schritt 1; Befunde stehen im Bericht, Pins ändert er nicht. (2) Der Slice schließt erst nach der Tag-Freigabe des Nutzers und nach Schritt 8 von [`releasing.md`](../../../user/releasing.md), nicht bei „bereit zur Freigabe“; die Veröffentlichung ist Teil dieses Slice.

## 7. Closure-Notiz

Wird vom Planner in frischem Kontext geschrieben ([`AGENTS.md`](../../../../AGENTS.md) §3.10).

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, Kürzel `ALL`): Pin-Stellen, Emissions-Vorlage und Nutzerdoku; die Modus-Deklaration führt keine feinere Sub-Area dafür.

**Vorgelagert — offene Beobachtungen sichten:** Register am Stand `3886a1bc` durchgegangen, Zähler = `ls <eintrag>/evidence/*.md | wc -l`:
- `BEO-ALL/handbuch-nennt-sprachen-die-der-download-nicht-kennt` — 1, offen; trägt die Bedingung an diesen Schnitt, in L1 übernommen. Mit diesem Slice 2×.
- `BEO-ALL/handbuch-sprachbaum-ohne-sensor-in-full-smoke` — 3, Stand verkörpert; Grenze der Prosa als Risiko übernommen.
- `BEO-ALL/ge-tagter-stand-traegt-keinen-gates-beleg`, `BEO-ALL/ci-rennt-gegen-die-publikation-des-gepinnten-releases`, `BEO-ALL/waechter-misst-die-fixture-statt-der-realen-quelle`, `BEO-ALL/kennung-traegt-den-stand-den-ein-release-ueberholt` — als Risiken übernommen; Zähler beim Implementer neu zu messen.

**Modus-Begründung:** alle berührten Sub-Areas GF.
