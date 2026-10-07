# Review: slice-full-smoke-faehrt-den-adopter-pfad-ueber-sha256sums

**Datum:** 2026-10-07 · **Rolle:** Reviewer (`.harness/skills/reviewer.md`) · **Gegenstand:** `edad1d00`, `ceb77d3d`
gegen den Slice-Plan (Stand `de3fde05`), [ADR-0058](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
[ADR-0059](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md) Festlegung 1 und 3,
[`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7, `MR-071`.

**Summary:** 1 HIGH · 0 MEDIUM · 0 LOW · 1 INFO. Klassen: *Messprotokoll eines Laufs im Kommentar* (HIGH-1),
*Erfolgs-Meldung nennt einen Kanal, den die Ausgabe nicht trägt* (INFO-1).

## Findings

### HIGH-1 — Laufzeit-Messwerte als Kommentar

- `kategorie`: HIGH · `quelle`: `AGENTS.md` §3.7 (Hard Rule) · `verifizierbar`: nein (kein Sensor liest den Inhalt eines Kommentars)
- `pfad`: `test/mutations/553-ausgang-unveroeffentlichter-traeger-tag.sh:22`,
  `554-traeger-tag-im-fragment-umbenannt-full-smoke.sh:13`, `556-traeger-fetch-manifest-adresse-gebrochen.sh:15`,
  `557-traeger-fetch-pin-uebergangen.sh:13`
- `befund`: Die vier Kommentare tragen die Zeitwerte **eines** `make mutate`-Laufs (`DAUER: 23.77 s … gegen
  148.31 s …`) als Beleg für den Satz „bricht an der Träger-Stufe ab, lange vor dem Ende". Das ist das
  Protokoll eines Laufs, das §3.7 als Falsch-Form nennt. Der Satz danach (Abbruch an der Stufe) ist eine
  Grenze, die Zahlen dagegen gehören zu keiner der fünf Klassen. Failure-Szenario, gemessen: Die Läufe dieses
  Reviews ergaben `24.14 s` (556), `19.11 s` (557) und einen Grün-Vorlauf von `140.86 s` bzw. `318.54 s`
  statt der kommentierten `25.67` / `27.31` / `148.31`. Der Leser hält also eine Messung von Maschine und
  Netz für eine Eigenschaft des Falls, und nichts zieht sie nach. Liefer-Punkt 3 des Plans bestellt diese
  Zahl. Die Hard Rule geht dem Plan vor (Konflikt-Pfad nach Modul 8, Planner/Architect), herabgestuft wird nicht.
- `klasse`: Messprotokoll eines Laufs im Kommentar

### INFO-1 — (b) misst den Kanal nicht an der eigenen Ausgabe

- `kategorie`: INFO · `quelle`: `AGENTS.md` §3.6 · `verifizierbar`: ja (`make mutate`, Fall 556)
- `pfad`: `harness/tools/full-smoke.sh:1954` (Prüfung `Digest verifiziert`), `:1964` (Echo „gegen die SHA256SUMS des Release")
- `befund`: Die Erfolgsmeldung des Skripts ist in beiden Kanälen gleich (Sonde unten, Läufe A und B), und (b)
  prüft nur `Digest verifiziert`. Dass (b) den Manifest-Kanal fährt, hält allein Fall 556 unter `make mutate`,
  also nicht in `make gates`. Der Echo der Stufe behauptet den Kanal, die Stufe selbst misst ihn nicht.
  Getragen ist die Aussage trotzdem, wie die Gegenprobe zeigt.
- `klasse`: Erfolgs-Meldung nennt einen Kanal, den die Ausgabe nicht trägt

## Belege

**Fall 556 — die 404 rührt vom Manifest-Abruf.** Das emittierte `traeger-fetch.sh` lief als Scratch-Kopie
mit angewandter Mutation (`/SHA256SUMS"` → `/SHA256SUMSX"`) und `TRAEGER_TAG=v0.5.0`:

```text
A (ohne Pin):               curl: (22) The requested URL returned error: 404   rc=22, nichts abgelegt
B (nur Host-Pin):           traeger-fetch: Traeger abgelegt (…) — ai-harness-init-linux-amd64 aus Release v0.5.0, Digest verifiziert.   rc=0
C (HTTP im gepinnten Bild): SHA256SUMS 200 · SHA256SUMSX 404 · ai-harness-init-linux-amd64 200
```

Im Pin-Kanal holt dieselbe mutierte Datei das Asset fehlerfrei. Die einzige Adresse, die 404 liefert, ist `SHA256SUMSX`.

**Die Fälle selbst gefahren:**
`make mutate MUTATE_CASES='556-traeger-fetch-manifest-adresse-gebrochen 557-traeger-fetch-pin-uebergangen'` →
`ok 556 -> make traeger-fetch endet im frischen Klon mit Exit rot` ·
`ok 557 -> der verdrehte sha256-Pin endete mit 0 rot` · `2 ok, 0 Befund(e)`, Exit 0.

**Gegenprobe (bindet 556 an `env -u`?):** Die drei `-u TRAEGER_SHA256_*`-Zeilen in `klon_traeger_fetch`
wurden im Baum entfernt, dann `make mutate MUTATE_CASES='556-traeger-fetch-manifest-adresse-gebrochen'` →
`BEFUND 556-… make full-smoke blieb GRUEN — 'make traeger-fetch endet im frischen Klon mit Exit' hat keine Zaehne mehr`.
Danach `git checkout -- harness/tools/full-smoke.sh`, und `git status --short` ist leer.

**Gates:** `make gates` nach dem Report-Commit, siehe Übergabe an den Aufrufer.

## Negativbefund

- (a) `klon_traeger_fetch` entfernt alle sechs Pins, abgeglichen mit `Makefile:46-53`. Dass (b) damit den
  Manifest-Kanal fährt, belegen 556 und die Gegenprobe, nicht die Meldung (INFO-1).
- (c) `aus Pin`: Der Payload schreibt `(aus Pin)` bzw. `(aus SHA256SUMS)`, gesetzt wird allein der Host-Pin
  (`ts_pin_var`, `full-smoke.sh:1888-1902`), und 557 bindet den Vorrang (ADR-0059 Festlegung 3). Ohne Befund.
- `MR-071`: Beide `sed`-Anker treffen den Quell-Bestand genau einmal (`grep -c` je 1, bei 557 über `[$]`). Ohne Befund.
- (e) Deklaration, `GRENZE` und Fall-Kommentare nennen beide Kanäle und die Grenze (eine Abweichung ist nur im
  Pin-Kanal messbar). Die byte-gleiche `docs/user/e2e-abdeckung.md` hält `make gates` über `test/e2e-abdeckung.bats`. Ohne Befund.
- ADR-0058/0059: Emittiertes Skript und Fragment sind unverändert (Plan §3), Produkt-Code ist nicht berührt. Ohne Befund.
