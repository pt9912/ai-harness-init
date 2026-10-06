# Review: slice-mv-findet-die-quelle-am-exakten-namen

**Rolle:** Reviewer (Modul 10, `.harness/skills/reviewer.md`) · **Datum:** 2026-10-06 ·
**Gegenstand:** Commits `a53632ba`, `5095089d`, `a6299336`, `d62620f1` · **Plan:** Slice
`slice-mv-findet-die-quelle-am-exakten-namen` (§1 samt Adopter-CR) · **Bezug:**
[`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand),
[`AGENTS.md`](../../AGENTS.md) §3.6/§3.7.

## Findings

### F-1 — HIGH — Herkunft im Kommentar, die in keinem Rang auflöst

- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.7 (Quellen-Klausel, Cutoff 2026-08-30)
- `pfad`: `test/slice-mv.bats:406-407`
- `befund`: Der neue Kommentar über `quelle_baum` sagt „Die Faelle tragen die Gegenproben des
  Adopter-CR (LH-QA-01)". „Adopter-CR" ist die Herkunft der Fälle, und die Quelle liegt nicht im
  Repo. Sie ist weder eine `LH-*`- oder `ADR-*`-Kennung noch ein `seit …`-Anker. Damit nennt der
  Kommentar eine Quelle, die keiner der neun Ränge deckt. Der Rest des Satzes ist eine Zusage
  und bleibt davon unberührt. Derselbe Herkunfts-Zusatz steht im Testnamen
  `test/slice-mv.bats:416`.
- `verifizierbar`: nein (`make comment-claims` liest nicht, worüber ein Kommentar spricht;
  [`AGENTS.md`](../../AGENTS.md) §3.7 „Ein Wächter existiert nicht")
- `klasse`: Herkunft im Kommentar ausserhalb der Anker-Formen

### F-2 — LOW — Anleitung zur Fehlerzeile `mehrdeutig` führt im Fall „exakter Name doppelt" ins Leere

- `quelle`: Maintainability ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6))
- `pfad`: `harness/sensors/slice-mv.md:263-265`
- `befund`: Die neu gefasste Zeile nennt zwei Ursachen und für beide die Abhilfe „die Kennung
  länger schreiben". Liegt derselbe exakte Name in zwei Verzeichnissen, trifft jede längere
  Angabe keine Datei mehr. Eine Verzeichnis-Angabe adressiert den Slice ebenfalls nicht: die
  Sonde `quelle_finden "$P" open/slice-a` endete mit `kein Slice`. Mit dem Werkzeug ist dieser
  Fall damit gar nicht lösbar, und die Anleitung schickt in einen Versuch, der nicht greifen
  kann.
- `verifizierbar`: ja (Sonde unten)
- `klasse`: Abhilfe einer Fehlermeldung trifft nicht jede genannte Ursache

### F-3 — INFO — `SLICE=<name>.md` fällt ohne exakten Treffer auf den Präfix zurück

- `quelle`: Plan §1, §6 Risiko (1)
- `pfad`: `harness/tools/slice-mv.sh:316` (`local name="${2%.md}"`), ebenso in der emittierten Fassung
- `befund`: Fehlt `slice-a.md`, liegt aber `slice-a-b.md` daneben, dann bewegt
  `SLICE=slice-a.md` den Slice `slice-a-b.md`, obwohl ein Dateiname angegeben wurde. Der Plan
  verlangt genau das (§1, „nur ohne exakten Treffer auf den Präfix-Glob"), und so verhielt es
  sich schon vorher. Notiert für den Ausgang von Risiko (1).
- `verifizierbar`: ja
- `klasse`: Präfix-Rückfall auch für eine Angabe in Dateinamen-Form

## Kommandos und Ausgaben

```text
make mutate MUTATE_CASES="525-slice-mv-quelle-ohne-exakten-zweig 526-slice-mv-quelle-praefix-ohne-grenze"
  -> ok 525 … quelle: exakter Name gewinnt gegen einen laengeren Praefix-Treffer rot
  -> ok 526 … quelle: ein Praefix trifft nur an der Bindestrich-Grenze rot
  -> 2 ok, 0 Befund(e)   (EXIT 0)

grep -cF 'f="$1/$d/$name.md"' harness/tools/slice-mv.sh            -> 1
grep -cF '*) muster="$name-" ;;' harness/tools/slice-mv.sh         -> 1
(sed beider Fälle in einer Kopie: diff zeigt je genau die eine beabsichtigte Zeile, 317 bzw. 331)

Gegenprobe, bats test/slice-mv.bats in einer git-archive-Kopie, gepinntes BATS_IMAGE:
  525 nur Dogfood:     not ok 23 (exakter Name), 24 (mehrdeutig / doppelt exakt), 27 (kopplung KERN)
  526 nur Dogfood:     not ok 25 (Grenze), 27 (kopplung KERN)
  525 beide Fassungen: not ok 23, 24      — die Semantik bindet ohne die Kopplung
  526 beide Fassungen: not ok 25          — der benannte Test bindet allein
```

Sonde `quelle_finden` (Dogfood-Fassung, Planning-Baum mit Leerzeichen im Pfad):
`slice-a`/`slice-a.md` → exakt · `slice-a-b` → exakt · `slice-*`, `slice-?`, `slice-[` → `kein
Slice` (kein Glob, das Glob-Zeichen wird literal gelesen) · `slice-[x]` → die literale Datei ·
`slice-q`/`slice-q-` mit zwei `slice-q-*` → `mehrdeutig` · `slice-sp ace` → `slice-sp ace-x.md` ·
`""`, `.md` → `kein Slice` (leeres `SLICE` fängt `main` schon vorher ab).

## Geprüft, ohne Befund

- **(a) `quelle_finden`:** Semantik nach Plan §1/CR in beiden Fassungen (Rumpf wortgleich).
  Gefahrene Formen: `.md`, Glob-Zeichen `*`/`?`/`[`, Leerzeichen im Pfad, leerer bzw. nur-`.md`-Name,
  doppelter exakter Name `open/`+`done/` → `mehrdeutig`. Die Nummern-Kurzformen
  `slice-001/-004/-022/-045` wechseln von `mehrdeutig` auf `kein Slice`. Nach der dokumentierten
  Grenze-Regel trifft das zu, und keine der beiden Meldungen bewegte einen Slice.
- **(b) Hilfe-Text, `harness/sensors/slice-mv.md`:** Bis auf F-2 beschreiben sie die Regel, die der
  Code hat.
- **(c) Fälle 525/526:** Beide sind über `make mutate` gefahren und rot im benannten Test, und das
  `sed`-Muster trifft im Quellbestand je genau einmal
  ([`MR-071`](../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
  Die Gegenprobe zeigt: Der mitgefärbte Kopplungsfall ist ein struktureller Nebeneffekt. Die
  benannten Tests binden die Semantik allein.
- **(d) full-smoke `slice_mv_im_ziel` (i):** Schritt (i) unterscheidet die alte von der neuen
  Fassung, denn mit beiden Dateien in `open/` meldete die alte `mehrdeutig`. Jedes Glied der
  Kurzbeschreibung hat einen Schritt (a)–(i). Die Stufen-Region (2001–2361) schließt den
  Command-Guard- und den Commands-Abschnitt ein. Die Deklaration nennt beide nicht, und vor der
  neuen Kopfzeile lagen sie ebenso undeklariert in der Region der Träger-Fetch-Stufe. Die
  Deklaration ist damit nicht zu weit. `make full-smoke` lief in diesem Review nicht.
- **(e) Kopplung:** `quelle_finden` steht in `KERN`. `funktions_rumpf` liest bis zur ersten `}` in
  Spalte 0, und das ist das Funktionsende. Den ganzen Rumpf hält Testfall 27, der unter der
  einseitigen Mutation rot wurde. Der Aufruf in `main` liegt ausserhalb von `KERN`. Ihn fährt die
  emittierte Seite in full-smoke (i).
- **§3.7 übrige Kommentare** (`quelle_finden`, Fall-Köpfe 525/526, full-smoke (i)): Zusage oder
  Sensor im Indikativ, ohne Befund.
