# Verifikationsbericht: slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset — 2026-09-25

**Rolle:** Verifier (Modul 8/11) — Frage: *Bauen wir es richtig?* gegen Plan, DoD und ADR. Nicht die
Frage des Reviewers (Diff gegen Plan, ADR, Hard Rules) und nicht die des Validators.

**Gegenstand:** der Slice `slice-tap-check-haelt-die-formel-gegen-das-veroeffentlichte-asset` (Lifecycle
`in-progress`) am Stand `main` = `90be56c9`, Arbeitsbaum sauber. Reviewer-Reports Runde 1 bis 4 liegen vor
(Runde 4: kein HIGH/MEDIUM, 2 LOW, 3 INFO). Nichts gepusht. Der Slice ist **nicht** geschlossen; dieser
Bericht setzt kein DoD-Häkchen und ändert weder Slice noch Code noch ADR (`AGENTS.md` §3.10).

**Bezug:** `LH-QA-02` · `LH-QA-03` · `ADR-0064` (Accepted) · `ADR-0066` (Proposed, Constraint für die
Exit-Klassen) · `ADR-0058` · `MR-071` · `AGENTS.md` §3.6.

**Methode:** Reale Läufe gegen das Tap mit Netz an genau diesen Aufrufen, **ohne `TAP_TOKEN`**. Docker-
Läufe des Skripts mit realem `docker` und mit einem `docker`-Stub im `PATH`. Mutationen und Gegenproben in
einer `git archive`-Kopie von `HEAD` im Scratchpad, `bats` im gepinnten Bild (`--network none`), nie im
Repo-Baum. Kein Host-Go, kein `make mutate`, kein `TAP_TOKEN`.

---

## Gesamturteil

**Bestätigt.** Alle drei Liefer-Punkte sind an ihrer Zusage gedeckt; die Zähne, die ich selbst emuliert
habe, färben aus dem behaupteten Grund rot, und die Gegenproben belegen, dass die Zusicherung bindet. Der
reale Rot-Beleg (DoD 3 (b)) ist von mir selbst gefahren und stimmt Zeichen für Zeichen mit der Zusage
überein. **Keine DoD-Verletzung.** Zwei Punkte gehören dem Planner, keiner blockiert (Übergaben Ü-1, Ü-2):

- Ü-1: die Formulierung `make tap-check … → Exit 1` in der Fitness-Zeile der **Accepted** `ADR-0064` trifft
  über `make` nicht zu (Prozess-Exit 2); der Slice liest sie nach `ADR-0066`, die noch `Proposed` ist.
- Ü-2: der Beleg `mutate: 422 ok, 0 Befund(e)` gehört nach Lage der Commits zum aktuellen Baum, ist von mir
  aber nicht durch Neuberechnung des `make mutate`-Schlüssels bestätigt (Auftrag: kein zweiter Lauf).

---

## 1. Ist der Sensor gelaufen?

| Sensor | Ergebnis |
|---|---|
| `make gates` | am Ende dieses Laufs einmal gefahren, Ausgang unten (§8) |
| Stempel: `bash harness/tools/working-tree-hash.sh` gegen `.harness/state/gates-passed.diffsha` | beide `9308974eb29a…` — deckungsgleich am Anfang dieses Laufs (Stempel 00:48:37, letzter Commit 00:44:33) |
| `make mutate`-Beleg | Datei `.harness/state/mutate-passed.key` (01:25:19) und Log `mutate: 422 ok, 0 Befund(e)`; `ls test/mutations/*.sh \| wc -l` → **422** — die Zahl der Fälle ist die der Lauf-Zeile. Seit dem letzten Commit (`git log --since='2026-09-25 00:40'` nennt nur `90be56c9` und `37fd1e61`, beide 00:44:33) kam kein Commit hinzu, `git status --short` ist leer. **Nicht neu berechnet** (Ü-2). |
| `make test` / `make lint` / `make shell-lint` | nicht separat gefahren — `make gates` deckt sie; der `bats`-Lauf der Datei `test/tap-nachzug.bats` am unveränderten Baum in meiner Kopie: **37 Fälle grün, 0 `not ok`** |

## 2. DoD-Punkte: Deckung und Beleg

### Liefer-Punkt 1 — das Werkzeug

| Zusage | Was deckt | Trägt es aus dem richtigen Grund? |
|---|---|---|
| Modus `check`; jeder andere Modus Exit 2 „nicht implementiert" | Fall `modus:` (`sync`, anderer Modus); Direktlauf des Skripts | ja — `sync` endet mit 2 und der Meldung, nicht mit 0 |
| Exit-Zeile `tap-<modus>: Exit <N>` genau einmal, letzte stderr-Zeile des Skripts, bei 0 fehlt sie | Fall `exit-zeile:` (sechs Exit-2-Herkünfte, Exit 1, zwei Exit-0), Zähne 427, 428, 432, 433 | ja, siehe §4 (Rot selbst gesehen) |
| Klasse 1 nur aus dem Vergleich; Status 1 des `docker`-Aufrufs ist Exit 2 | Fall `transport:` (Status 1, 3, 125, 127, 137, 143), Zahn 429 | ja, siehe §4; real bestätigt (§3.2) |
| POSIX-`sh`-Nutzlast als eigene Datei im digest-gepinnten Bild; Pin byte-gleich zu `TRAEGER_IMAGE` | Fall `nutzlast:` (nur Bestands-Programme), Fall `pin-kopplung:`, Zahn 417 | ja; die Nutzlast lief real im Bild (§3.1) |
| Ziel `make tap-check TAG=<tag>`, Rezept ohne make-Referenz auf den Tag | Fall `uebergabe ohne text:`; `Makefile` Rezeptzeile `@bash harness/tools/tap-nachzug.sh check` | ja |
| kein Gate | Fall `kein gate:`; `tap-check` steht nicht in `gates` und nicht in `record-gates` (`Makefile`, Zeilen der beiden Ziele gelesen) | ja |
| README-Zeile mit `kein Gate` und `exempt-targets` exakt | `harness/README.md` Zeile 84 (Bindung `kein Gate`), `.d-check.yml` Zeile 192 `- tap-check` (Listen-Eintrag, kein Glob); `make gates`-Modul `targets` | ja; die README-Zeile nennt die Exit-Zeile als Vertrag und die Ziffer von `make` als Nicht-Vertrag |
| Grenze der Zusage: Signal, nicht beschreibbare stderr, fehlender Modus | Skript-Kopf, Makefile-Kommentar, README-Zeile nennen sie; von mir gemessen (§3.2) | ja — die Grenzen sind wahr |

### Liefer-Punkt 2 — der hermetische Nachweis

Die Fälle laufen in `make test` ohne Netz und ohne Container-Start (Stubs für `docker`, `curl`, `sleep`, die
Nutzlast als echte Datei). Geprüft habe ich, dass jede Eigenschaft der DoD-Aufzählung einen Fall trägt: gleich
mit Nicht-ASCII und ohne Endzeilenumbruch · verschieden mit beiden Digests und der Zeile des **zweiten
Lesens** · Vorfall nachgestellt · Endzeilenumbruch-Unterschied · Tap unlesbar / Asset unlesbar / 404 ·
`docker`-Stub Status 1 und ≥ 3 · Cache-Fenster (erst alt/dann neu, beide alt, sofort gleich, 65 s Vorgabe) ·
`version`-Zeile in `check` kein Gegenstand · Vorab-Tag samt Kopplung an `release.yml` · Tag-Eingabe,
Tag-Form, Feldform · Übergabe ohne Text · Token · Pin. Ein Fall je Eigenschaft ist da. Die Rot-Belege dazu
stehen in §4.

### Liefer-Punkt 3 — Zähne und realer Rot-Beleg

(a) Die 26 Fälle 409 bis 434 decken alle in der DoD aufgezählten Zähne: Vorab-Regel (409), Metadatum (410),
Wiederholung (411), Sofort-Gleich (412), Tag-Form (413, 421 bis 423), Feldform (414), Pin (415, 417), Token
als Argument (416), Exit-Zeile entfernt / falsche Klasse / bei Exit 0 / doppelt (427, 428, 432, 433),
Exit-Abbildung (429 Status 1 des `docker`-Aufrufs; 430 und 431 der `*)`-Arm in beiden Skripten). Dazu
Zähne, die die DoD nicht einzeln nennt (418 bis 420, 424 bis 426, 434).
(b) Der reale Rot-Beleg: von mir gefahren, §3.1.

## 3. Selbst gefahrene Belege

### 3.1 Realer Rot-Beleg (DoD 3 (b)) — Datum 2026-09-25, 01:47 (Ortszeit +0200), kein Token

Tap-Stand: `Formula/ai-harness-init.rb` am Kopf des Default-Branch trägt `version "0.2.3"`, sha256
`a5a1c165…da1f2` (aus der Ausgabe gelesen; der Beleg ist datiert und wandert mit jedem Schnitt).

```
TAG=v0.2.2 bash harness/tools/tap-nachzug.sh check      -> Skript-Exit 1, stdout leer, stderr:
tap-check: Formel-Unterschied — Tag v0.2.2, Asset sha256 9071e698…4089, Tap-Kopf sha256 a5a1c165…da1f2;
  erste abweichende Zeile (zweites Lesen) Zeile 11: Asset [  version "0.2.2"] | Tap [  version "0.2.3"]
tap-check: Exit 1                                       <- letzte stderr-Zeile des Skripts
make tap-check TAG=v0.2.2                               -> Prozess-Exit 2; Ausgabe: dieselben zwei Zeilen,
tap-check: Exit 1
make: *** [Makefile:493: tap-check] Fehler 1            <- Meldung von make (deutsche Locale), Skript-Zeile
                                                           ist die VORLETZTE Zeile
TAG=v0.2.3 (Skript und make)                            -> Exit 0, "tap-check: gleich — Tag v0.2.3, … sha256 a5a1c165…"
make tap-check TAG='v1.0.0$$(id)'                       -> Exit 2, "Tag-Form falsch: v1.0.0\$\(id\)", Exit 2,
                                                           keine Ausführung, kein Netz-Zugriff
make tap-check TAG=v1.0.0-rc.1                          -> Exit 0, "Vorab-Tag, Tap bleibt (v1.0.0-rc.1)"
```

Die Ausgabe ist gelesen: Exit 1 ist ein Formel-Unterschied (beide Digests, `version`-Zeile als erste
abweichende Zeile), kein Lesefehler; das Skript brauchte die 65 s der Wiederholung. Damit ist auch das
Risiko „die Stubs sind eine Fixture" für den Tag der Messung eingelöst: Weiterleitung des Asset-Downloads,
`Accept`-Kopf und Antwortform des Tap stimmen mit den Stubs überein.

**Abweichung von der Auftrags-Formulierung, nicht vom Plan:** `make tap-check TAG='v1.0.0$(id)'` (ohne
Verdopplung) endet ebenfalls mit Exit 2, aber **nicht** in der Formprüfung: make wertet `$(id)` als
(leere) make-Variable, das Skript bekommt `v1.0.0`, startet den Transport und endet an
`Asset nicht auffindbar … (HTTP 404)`. Das ist die vom Plan benannte Grenze („make wertet `TAG=…` samt
`$(shell …)` aus, bevor ein Skript läuft"); der Plan verlangt die Form `v1.0.0$$(id)` und die ist gedeckt.

### 3.2 Transport-Klassen mit realem `docker`

| Lage | Exit | Ausgabe |
|---|---|---|
| `DOCKER_HOST=tcp://127.0.0.1:9` (real) | 2 | `Cannot connect to the Docker daemon …`, dann `tap-check: der Transport im Bild endete ohne Ergebnis der Nutzlast (docker Exit 1) — das Ergebnis des Vergleichs ist unbekannt`, dann `tap-check: Exit 2` |
| Stub `docker` Status 1 / 3 / 125 / 127 / 137 / 143 | je 2 | Transport-Meldung mit dem Status, `tap-check: Exit 2` als letzte Zeile |
| Stub `docker` Status **10** | **1** | stdout und stderr außer der Zeile `tap-check: Exit 1` leer — **die im Skript-Kopf genannte Restmenge ist bestätigt**: ein `docker`-Aufruf, der selbst mit 10 endet, gilt als Formel-Unterschied, ohne Digests und ohne Meldung der Nutzlast |
| Signal (SIGTERM an das Skript während des `docker`-Aufrufs) | 143 | keine Ausgabe, keine Exit-Zeile — wie zugesagt-nicht-zugesagt im Kopf |
| stderr geschlossen (`2>&-`), Stub Status 3 | 2 | Exit bleibt 2, die Zeile fehlt — der Schreibfehler ändert den Exit nicht (Zusage des Kopfes über `melde`) |
| Repo-Pfad mit `:` (F-11), reales `docker` | 2 | `docker: invalid spec … too many colons`, Meldung des Skripts, Exit-Zeile — laut und in der sicheren Richtung (Klasse 2) |

### 3.3 Token-Zusage

- **Sonde (eigene Mutation):** in einer Kopie `-H "X-Debug: $TAP_TOKEN"` neben `-H @<Datei>` in die
  `curl`-Argumentliste der Nutzlast, `unset TAP_TOKEN` entfernt. Der Fall `token: ein Sentinel-Token steht in
  keiner Argumentliste …` wird **rot**, Meldung gelesen: `nirgends: grep Status 0 (0 = Fund, 2 = Fehler) für
  'TOKSENTINEL-9f3a71c2'; Fund in: …/curl.log` — die Ursache ist der Fund in der Argumentliste, nicht eine
  Nebenwirkung. **Gegenprobe:** wird nur die `nirgends`-Zeile aus dem Fall gelöscht, ist er **grün** — sie
  bindet, und keine andere Zeile deckt die Argumentliste.
- **Zahn 416** (`Authorization`-Variante) färbt denselben Fall an derselben Zeile rot.
- **Unverändert-Baum, nicht beschreibbares `TMPDIR`:** Zusatzfall in der Scratch-Kopie mit Sentinel-Token und
  `TMPDIR=/nonexistent-dir`: Exit 2, stderr `mktemp: No such file or directory` und `interner Fehler der
  Nutzlast (Exit 1)`, `tap-check: Exit 2`; das Token steht in keiner Ausgabe und in keinem Stub-Protokoll
  (beide Assertions grün, der Fall endet erst an meinem eigenen `false`). Kein echtes Token wurde je gesetzt.
- **Grenze, die im Plan steht:** `docker run -e TAP_TOKEN` reicht den Wert ohne Kommandozeilen-Text durch, das
  Token gegenüber dem Docker-Daemon ist ausgenommen.

## 4. Zähne 409 bis 434: Emulation, Rot, Gegenprobe

Jeder Fall wurde in einer Scratchpad-Kopie mit seinem Skript angewandt (`sed` trifft, Datei ändert sich), der
benannte `bats`-Fall im Bild gefahren. Die **Gegenprobe** schwächt die Zusicherung des Falls und mit an
gelassener Mutation muss er **grün** werden — grün heißt „bindet".

| Klasse | Fall | Rot, Meldung gelesen | Gegenprobe |
|---|---|---|---|
| Vorab-Regel | 409 (`*-*)` → `__nie__)`) | Fall `vorab-tag: Exit 0 …` rot an `[[ "$output" == *"Vorab-Tag, Tap bleibt"* ]]` (Zeile 267) | die drei Zusicherungen (Meldung, `docker_aufrufe`, `STUB_LOG_CURL`) aus der Schleife gelöscht → **grün**; sie binden |
| Vorab-Kopplung | Sonde: Regel in `release.yml` auf `*-rc*)` | Fall `vorab-tag: die Regel …` rot an `grep -cE "$muster" … -eq 1` (Zeile 277) — bricht laut, bleibt nicht still grün | — |
| Token | 416 und Sonde `X-Debug` | siehe §3.3 | siehe §3.3 |
| Exit-Klasse | 429 (Status 1 → `1 \| 10)`) | Fall `transport:` rot an `[ "$status" -eq 2 ]`, gelesen: `docker Status 1: Exit 1, stderr: tap-check: Exit 1` | Status 1 aus der Liste des Falls genommen → **grün** |
| Exit-Klasse | 430 (`*)`-Arm des Skripts), 428 | 430: Fall `interner fehler: … mit einem Status ab 3` rot an `[ "$status" -eq 2 ]`; 428: sechs Fälle rot | — |
| Exit-Zeile | 427 (entfernt) | Fall `exit-zeile:` rot an `[ "${stderr_lines[-1]}" = "tap-check: Exit 1" ]` (Zeile 456) | die Zeilen `stderr_lines[-1]` und `exit_zeilen … -eq 1` gelöscht → **grün**; sie binden |
| Exit-Zeile | 432 (bei Exit 0), 433 (doppelt) | je Fall `exit-zeile:` rot | — |
| Tag-Form | 413 (Formprüfung entfernt) | Fall `tag-eingabe:` rot an `[[ "$output" == *"Tag"* ]]` (Zeile 302), die Feldform-Stufe fängt den Tag mit Exit 2, aber ihre Meldung nennt „Tag" nicht | die beiden Assertions `*"Tag"*` und `Tag-Form falsch` gelöscht → **grün**; nur **eine** allein reicht nicht zur Gegenprobe (`Tag-Form falsch` gelöscht, `*"Tag"*` bleibt: weiter rot) — siehe V-2 |
| Feldform | 414 | Fall `feldform:` rot | — |
| Wiederholung | 411 | Fall `cache-fenster: erst alt …` rot an `[ "$status" -eq 0 ]` | — |
| Sofort-Gleich | 412 | Fall `cache-fenster: sofort gleich …` rot | — |
| Metadatum | 410 | Fall `vorab-tag: die Regel …` rot | — |
| Pin | 415, 417 | 415: Fall `pin: ein Bild ohne Digest …` rot an `[ "$status" -eq 2 ]`; 417: Fall `pin-kopplung:` rot | — |

**Die negative Assertion in Fall `transport:`** (kein dauerhafter Zahn auf den Wortlaut der `*)`-Meldung):
zwei eigene Sonden. (1) Meldung um `(Formel-Unterschied)` ergänzt → Fall rot an
`nirgends 'Formel-Unterschied' …` (Zeile 425), Meldung gelesen (`Fund in …/stderr-1`). (2) Die ganze `*)`-Meldung
ersetzt durch `docker Exit $rc: Formel-Unterschied nicht ausgeschlossen` → Fall rot, an der Positiv-
Assertion `Transport im Bild endete ohne Ergebnis der Nutzlast (docker Exit $s)` (Zeile 422). Die Negativ-
Assertion **bindet also**; ein eigener Zahn fehlt, das ist in §6 (Punkt 4) bewertet.

## 5. Abgrenzung und Kopplungen

- **Kein `sync`:** `bash harness/tools/tap-nachzug.sh sync` und jeder andere Modus enden mit Exit 2 (Meldung
  „nicht implementiert" bzw. Aufruf-Meldung); Fall `modus:` deckt es. Kein leerer Rumpf, der 0 meldet.
- **Kein Gate:** `tap-check` steht weder in `gates` noch in `record-gates` (Fall `kein gate:`), die README-
  Zeile trägt `kein Gate`, `.d-check.yml` `exempt-targets` führt `- tap-check` exakt; `.PHONY` trägt das Ziel.
- **Pin:** `TAP_IMAGE` und `TRAEGER_IMAGE` tragen denselben Digest `curlimages/curl@sha256:463eaf60…04b6`
  (beide Dateien gelesen); Kopplungsfall 24 und Zahn 417 (rot gesehen).
- **Vorab-Regel gleich der des `publish`-Jobs:** Kopplungsfall liest die Zeile aus `.github/workflows/
  release.yml` (Zeile 180) per Muster, fährt sie gegen sechs Tags und vergleicht mit dem Skript; er bricht,
  wenn die Form nicht genau einmal dasteht (rot gesehen, §4).
- **`make help`:** listet `tap-check` mit dem Hilfetext (`… — NICHT in gates`).
- **Größe:** drei Liefer-Punkte (Werkzeug, Fälle, Zähne samt realem Beleg); Schichten laut Plan
  Werkzeug und Test. Berührt sind zusätzlich Konfiguration und Doku (`Makefile`, `.d-check.yml`,
  `harness/README.md`) — im Plan als Teil von Liefer-Punkt 1 geführt. Der Plan nennt selbst (§6), dass der
  Slice größer als eine Review-Sitzung ist; vier Runden sind der Beleg. Keine DoD-Verletzung.

## 6. Plan-vs-Code-Diff

**Geplant und gebaut, ohne Abweichung:** Skript mit Modus-Argument, Nutzlast als eigene Datei, `check`-
Schritte a, c, e, Wiederholung nach `TAP_WAIT`, Exit-Zeile, Pin samt Kopplung, Token in Datei 0600 mit
`-H @Datei`, Ziel, README-Zeile, `exempt-targets`, Fälle, Zähne.

**Gebaut, im Plan nicht oder nur als Ausschluss/Grenze genannt — und ob es benannt ist:**

| Code | Plan | Bewertung |
|---|---|---|
| Status 10 als privater Kanal zwischen Nutzlast und Host-Skript samt Restmenge | §1 „Ausdrücklich NICHT": *Bestand unterhalb der ADR*, Skript- und Nutzlast-Kopf nennen ihn samt Restmenge | benannt; Restmenge von mir bestätigt (§3.2) |
| Exit-Zeile über `beende()` mit `EXIT`-Trap, `unterschied`-Flag; `melde()` mit `|| :` | DoD 1 verlangt die Zeile, nicht den Mechanismus; „nicht beschreibbare stderr: weder zugesagt noch verboten" | benannt. Der Kopf **sagt mehr zu** als der Plan („ein Schreibfehler auf stderr ändert den Exit nicht"); die Zusage hat Fall (`stderr nicht beschreibbar:`) und Zahn (434) und ist von mir bestätigt — ein Mehr, das gedeckt ist |
| Interne-Fehler-Abbildung der Nutzlast (`mktemp`, `cmp` Status 2, Kommando mit Status 1 oder ≥ 3 → 2) | DoD 2 („Kommando mit Status ≥ 3 → 2"), DoD 3 (`*)`-Arm beider Skripte) | benannt und gedeckt (Fälle `interner fehler:` ×5, Zähne 424 bis 426, 430, 431) |
| `TAP_WAIT` mit Nicht-Zahl → Exit 2 „keine Sekundenzahl" | Plan: „Wartezeit injizierbar" | gebaut, nicht geplant, harmlos (fail-closed). Kein Zahn, keine Zusage im Plan |
| Meldung des `docker`-Zweigs „ohne Ergebnis der Nutzlast … unbekannt" | DoD 1/2: Meldung „des Transports", nie 1 | benannt; Wortlaut vom Fall (positiv und negativ) gehalten, §4 |

**Geplant, nicht gebaut:** nichts gefunden. Die §1-Ausschlüsse (kein `sync`, kein Job, kein Prozedur-Schritt)
sind eingehalten (`git log --name-only --grep=tap-check` nennt außerhalb von Plan, Reviews und `test/mutations/` nur `harness/tools/`, `test/`,
`Makefile`, `.d-check.yml`, `harness/README.md`; dazu die Roadmap-Zeile aus F-9, §7).

**Widersprüche zu den ADRs — wie jetzt gefasst:**

- `ADR-0064` (Accepted, immutabel) sagt in der Fitness-Zeile *Rot-Beleg*: „`make tap-check` gegen … `v0.2.2` …
  → Exit 1". **Über `make` ist der Prozess-Exit 2** (GNU Make 4.3, von mir gemessen). Der Slice fasst das mit
  `ADR-0066` (**Proposed**): Klasse = Exit des **Skripts**, vertraglicher Träger über `make` die Zeile
  `tap-<modus>: Exit <N>`. Der Plan benennt die Lage ausdrücklich in §Bezug, §1 und DoD 3 (b). Bis zum Accept
  der `ADR-0066` liest der Slice eine Accepted-ADR anders als deren Wortlaut. **Übergabe Ü-1.** Die Umsetzung
  ist mit dem Wortlaut der `ADR-0066` konsistent (Exit-Zeile genau einmal, bei 0 nicht, Träger ist die Zeile).
- `ADR-0064` Festlegungen 1, 2, 5 und Schritt c/e: erfüllt (Formprüfung auf dem Host vor `docker`, Vergleich
  byte-genau über Dateien mit `cmp`, Wiederholung, Pin im gepinnten Bild). Festlegung 4 (Lese-Zweig: Token nie
  in Kommandozeile, nie in Ausgabe, `-H @Datei` mit Modus 0600): erfüllt, §3.3.

## 7. Die bekannten offenen Punkte — Bewertung, nicht Schließung

| Punkt | Berührt die DoD? | Bewertung |
|---|---|---|
| F-9 Roadmap-Marker (Rolle ohne Quelle): Implementer-Commit entfernt die Ruhe-Marker-Zeile der Roadmap | nein | keine DoD-Zeile nennt die Roadmap. Die Frage nach der schreibenden Rolle ist eine Architect-Frage (Reviewer-Report Runde 1). Die Zulässigkeit hängt an der `planning`-Regel des Doku-Gates, die den Marker gegen das Verzeichnis hält. **Übergabe Ü-3 (Hinweis)** |
| F-11 Mount-Pfad mit `:` | nein | von mir gemessen (§3.2): `docker`-Fehler 125, Exit 2, Exit-Zeile — laut, sichere Richtung. Kein falsches Grün, kein falsches Rot des Vergleichs. Portabilitäts-Grenze, keine Zusage des Plans |
| 46 `!`-Vorkommen in anderen `bats`-Dateien | nein | `test/tap-nachzug.bats` führt kein `!` an Fall-Mitte (`grep -n '^\s*! '` → keine Fundstelle); der Slice hat die Falle im eigenen Bestand mit `nirgends()` geschlossen. Der Fremdbestand ist kein Gegenstand dieses Slice |
| Kein dauerhafter Zahn auf den Wortlaut der `*)`-Meldung | nein (DoD 3 (a) listet ihn nicht) | die Negativ-Assertion **bindet** (§4, zwei Sonden rot). Ein Zahn in `test/mutations/` fehlt; gelistet heißt bewacht — dies ist die benannte „kuratiert ist unvollständig"-Grenze, kein DoD-Bruch |
| Status-10-Kanal als Restmenge | nein | im Plan als Bestand unterhalb der ADR benannt, im Skript-Kopf beschrieben und von mir bestätigt (§3.2). Ein Formel-Unterschied ohne Digests bei einem selbst mit 10 endenden `docker`-Aufruf ist die sichere Richtung nicht ganz (Klasse 1 aus einer anderen Quelle als dem Vergleich) — der Kopf sagt es ehrlich |
| `ADR-0066` noch `Proposed` | **ja, mittelbar** | DoD 1 und 3 (b) tragen Wortlaute der `ADR-0066`; §6 des Plans führt das Risiko mit Ausgang „offen bis Closure". Siehe Ü-1 |

**Verifier-Beobachtungen:**

- **V-1 (LOW):** Der Slice schließt mit `make mutate`-Beleg an einem Baum-Hash, den ich nicht neu berechnet
  habe (Auftrag). Die Lage der Commits stützt ihn, ein Restzweifel (Prüfgegenstand-Schlüssel anders als
  Stempel-Schlüssel) bleibt, bis die Closure den Beleg am dann aktuellen Baum sieht.
- **V-2 (INFO):** In Fall `tag-eingabe:` decken zwei Assertions dieselbe Ursache: das weite `*"Tag"*` (Zeile
  302) und das enge `*"Tag-Form falsch"*` (Schlusszeile). Zahn 413 wird bereits vom weiten gefangen; das enge
  trägt allein die Aussage „die Meldung nennt die Tag-Form". Kein Bruch — der Zahn färbt aus dem behaupteten
  Grund —, aber die Bindung der engen Assertion ist durch die weite verdeckt: würde eine Mutation die
  Formprüfung durch eine andere Meldung ersetzen, die ebenfalls „Tag" enthält, fiele nur die enge.
- **V-3 (INFO):** `make tap-check TAG='v1.0.0$(id)'` (einfacher `$`) endet nicht in der Formprüfung, sondern
  im Transport mit HTTP 404 am nicht vorhandenen Tag `v1.0.0` — bei einem real existierenden Tag würde der
  Vergleich laufen. Im Plan als Grenze benannt (make wertet vor dem Skript aus), keine Zusage berührt.

## 8. Übergaben an den Planner

- **Ü-1:** Vor oder mit der Closure entscheiden, wie die Lage der Wortlaut-Differenz zwischen `ADR-0064`
  (Accepted, „`make tap-check` → Exit 1") und `ADR-0066` (Proposed) geführt wird: Accept der `ADR-0066` ist
  Auftraggeber-Entscheidung; bis dahin steht das Risiko aus §6 ohne Ausgang „eingetreten/entfallen". Ändert
  sich bei dem Accept ein Wortlaut, ziehen Skript-Kopf, Makefile-Kommentar, README-Zeile, Fälle und Plan nach.
- **Ü-2:** Closure-Trigger 2 und der Lerneintrag brauchen den `make mutate`-Beleg **am Endstand**. Er liegt
  vor (`422 ok, 0 Befund(e)`); trägt der Planner Änderungen an Prüfgegenstand-Dateien ein (Plan-Datei ist es
  nicht), muss der Beleg neu genommen werden.
- **Ü-3 (Beobachtungs-Register):** (a) *ein Wächter ohne Zahn* — der Wortlaut der `*)`-Meldung des
  `docker`-Zweigs hängt allein an der Negativ-Assertion; Nachweis: §4, zwei Sonden. (b) *Zusage-Verdeckung
  durch Doppel-Assertion* (V-2). (c) F-9 bleibt eine Architect-Frage.
- **Ü-4 (Folge-Schnitt `sync`):** die drei Zusagen, die in `check` gelten und beim Schnitt erhalten bleiben
  müssen: Status-10-Kanal samt Restmenge (Re-Evaluierungs-Trigger 3 der `ADR-0066`), Exit-Zeile mit
  `tap-sync:`, Vergleich nur einmal im Code (Kopplung Schritt g).

## 9. Ausgang von `make gates`

Siehe die Antwort an den Auftraggeber; der Stempel wird nach Abschluss dieses Berichts erneuert. Am Anfang
dieses Laufs deckte der Stempel den Baum (§1); der Bericht selbst ist die einzige Änderung am Baum.
