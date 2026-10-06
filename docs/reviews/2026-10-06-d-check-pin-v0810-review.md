# Review — slice-d-check-pin-macht-den-range-leerfall-laut (d-check-Pin v0.81.0)

- **Rolle:** Reviewer (`.harness/skills/reviewer.md`), frischer Kontext
- **Gegenstand:** Implementer-Commits `dd26964c`, `0b89450c`, `1ff70b83`; Architect-Commit `7845860f`
  (`MR-079`, Kopf-Marken an `MR-066`/`MR-068`/`MR-073`, Index-Zeile)
- **Geprüft gegen:** Slice-Plan, `MR-032`, `MR-051`, `MR-025`, `MR-063`, `MR-065`, `MR-066`,
  `MR-068`, `MR-073`, `MR-079`, `AGENTS.md` §3.5–§3.8
- **Datum:** 2026-10-06

## Findings

### F-1 — MEDIUM — die Begründung des Retirement-Checks nennt im Dogfood eine Bindung, die es nicht gibt

- `quelle`: `MR-079` (Retirement-Check), `MR-007` Setzung 3
- `pfad`: `harness/conventions/MR-079-d-check-pin-v0810-vcs-bricht-ueber-leerer-range-ab.md` (Absatz *„`make history-range-guard` bleibt“*)
- `befund`: Der Eintrag sagt, der Wächter behalte seinen Gegenstand *„im Dogfood an `doc-commits`“*.
  Im Dogfood hängt der Wächter aber nur vor `adr-immutable` → `doc-immutable` (Modul `vcs`), also genau
  dort, wo der Grund laut Eintrag entfallen ist. `doc-commits` hat keine Wächter-Bindung und keinen
  CI-Aufrufer. Belege: `grep -nE 'history-range-guard' Makefile d-check.mk` → nur `Makefile:293/294/304`
  (`adr-immutable: history-range-guard doc-immutable`); `d-check.mk:115` `doc-commits:` ohne Vorbedingung;
  `grep -n doc-commits .github/workflows/*.yml` → kein Treffer. Das Urteil „bleibt“ trägt im
  emittierten Ziel (beide Targets gebunden, in `full-smoke` gemessen). Für das Dogfood steht es auf einer
  falschen Prämisse; als tragende Gründe bleiben dort der frühere Abbruch ohne Bild-Lauf und der
  `--staged`-Leerfall, und die nennt der Eintrag nicht.
- `verifizierbar`: ja (die zwei `grep` oben)
- `klasse`: Aussage über eine Bindung ohne Blick in die Verdrahtung

### F-2 — MEDIUM — die Zahlen der Strenge-Bilanz stehen weder im Eintrag noch in der Message neben einem Kommando

- `quelle`: `MR-025` Setzung 1, `MR-051` Setzung 1, `MR-063`
- `pfad`: `MR-079` (Tabelle *Strenge-Bilanz*, Zeile `hostpaths` 33 → 36); Message von `7845860f`
- `befund`: Der Eintrag verweist für seine Zahlen (2268/0, 73, 84, 20/0, 22/9, 33 → 36) auf die
  Commit-Message. `MR-051` Setzung 1 verlangt aber gerade dort das Kommando im Klartext, das genau diese
  Zahl ausgibt. Die Message nennt nur die Methode (*„netzlos, Kopie per git archive dd26964c“*) und die
  Werte. Damit fehlen die Sonden (13 Grund-Codes) und der Aufruf je Stufe. Die Zusage *„alle 9 Module mit
  Basis“* (`MR-063`) lässt sich aus keinem der beiden Träger nachfahren; anders als `MR-073` fehlt im
  Eintrag auch die Verteilung je Grund-Code.
- `verifizierbar`: nein (kein Gate liest Kommando-Nähe in Messages, `MR-051` §Grenze)
- `klasse`: Zahl-Beleg ohne Kommando

### F-3 — LOW — ein Kommentar zur leeren Range unter `vcs` beschreibt noch den alten Stand

- `quelle`: Plan §1 Ziel (*„jede lebende Aussage … auf den neuen Stand gezogen“*), `AGENTS.md` §3.7
- `pfad`: `Makefile:296-298`
- `befund`: Der Kopf von `adr-immutable` (das nur `vcs` fährt) sagt: *„eine aufloesbare, aber leere RANGE
  bricht hier ab statt "0 Befund(e)" zu melden“*. Unter `v0.81.0` meldet `vcs` dort ohne den Wächter
  nicht `0 Befund(e)`, sondern bricht mit `Range-Leerfall` ab. Gemessen am Tiefe-1-Klon des Dogfood:
  `make -f d-check.mk doc-immutable RANGE=HEAD..HEAD` → `Range-Leerfall …`, Exit 2. Der Grep des
  Plans (`leere[nr]? (Commit-)?Range`, Groß-/Kleinschreibung beachtet) trifft `leere RANGE` nicht. Die
  Stelle stand darum nicht in der Nachzugs-Menge, obwohl `Makefile` in §3 genannt ist.
- `verifizierbar`: ja (`git grep -n 'statt "0 Befund' Makefile`)
- `klasse`: Fundmenge per Muster ohne Formen-Probe

### F-4 — INFO — der neue Abbruch von `vcs` im flachen Klon über einer nicht leeren Range hat keinen Sensor, und die Doku sagt das nicht

- `quelle`: `AGENTS.md` §3.6, Plan §6 Risiko 1
- `pfad`: `harness/sensors/history-range-guard.md` (Absatz *„Der Anlass …“* unter der Tabelle), `harness/tools/full-smoke.sh` Schritt (d)
- `befund`: Schritt (d) läuft jetzt für beide Targets am vollständigen Klon. Das trägt: `vcs` meldet den
  Leerfall vor der Vorfahren-Prüfung, die Messung am flachen Klon hätte dieselbe Meldung ergeben. Ich
  habe das am Dogfood-Tiefe-1-Klon selbst gefahren: `doc-immutable` liefert `Range-Leerfall`,
  `doc-commits` liefert `Vorfahren nicht lesbar`. Was keine Stufe festhält, sind zwei Zeilen: die
  Tabellenzeile *flacher Klon* und das neue Verhalten von `vcs` im flachen Klon bei **nicht leerer**
  Range. Für das zweite habe ich am Tiefe-2-Klon `RANGE=HEAD~1..HEAD` gefahren: `v0.81.0` Exit 2,
  `v0.79.0` `0 Befund(e)`, Exit 0. Das ist genau die Lage aus Risiko 1 für emittierte Ziele. Die
  Sensor-Doku führt sie als Messung samt Handlungsfolge (`fetch-depth: 0`), sagt aber nicht, dass kein
  Wächter sie hält. `MR-079` §Grenze nennt nur, dass die `vcs`-Aussagen Einzelläufe sind. Für den
  Risiko-Ausgang beim Planner.
- `verifizierbar`: nein
- `klasse`: Werkzeug-Messung und gemessener Stand nicht zusammengehalten

## Gefahrene Kommandos

- `docker buildx imagetools inspect ghcr.io/pt9912/d-check:v0.81.0` → `Digest: sha256:c6e61342…c92e5`.
  Das ist gleich `d-check.mk` `DCHECK_DIGEST` und gleich `internal/emit/emit.go` `DefaultDigest`.
- `diff <(docker run … @<v0.79.0-digest> --print-mk) <(docker run … @<v0.81.0-digest> --print-mk)` →
  ein Hunk, `14c14` `DCHECK_IMAGE`. Das Hunk-Kommando aus dem Kopf von `d-check.mk` liefert `6`.
- Dogfood-Klone im Scratchpad, `make -f d-check.mk`:
  - Tiefe 1, `doc-immutable HEAD..HEAD`: `v0.81.0` `Range-Leerfall`, Exit 2; `v0.79.0` `0 Befund(e)`.
  - Tiefe 1, `doc-commits HEAD..HEAD`: `Vorfahren nicht lesbar`, Exit 2.
  - Tiefe 2, `doc-immutable HEAD~1..HEAD`: `v0.81.0` Exit 2; `v0.79.0` `0 Befund(e)`, Exit 0.
- `make mutate MUTATE_CASES=325-vorlauf-waechter-verliert-doc-immutable` → `1 ok, 0 Befund(e)`.
- `make gates`: ein Lauf am Ende über dem Baum mit diesem Report. Das Ergebnis steht in der
  Commit-Message dieses Reports.

## Geprüft, ohne Befund

- **(a) Pin:** Tag, Digest und `--print-mk`-Differenz sind selbst nachgemessen und stimmen an beiden
  gekoppelten Stellen. Kopfkommentar und Hunk-Kommando sind auf `v0.81.0` gezogen.
- **(b) L2:** `leerfall_laut_ohne_waechter` prüft Exit ≠ 0, die Meldung `Range-Leerfall` und das
  Ausbleiben des Modul-Laufs. `leere_range_vorbedingung` hält die aufgelöste, leere Range für beide
  Aufrufer. Der Wechsel auf den vollständigen Klon kostet keine Messung des Leerfalls, siehe F-4 für
  den Rest. `docs/user/e2e-abdeckung.md` ändert nur Zeilennummern, und keine Stufen-Deklaration
  behauptet „blind grün“ für `vcs`.
- **(c) Prosa:** `history-range-guard.md`/`.sh`, die emittierte Fassung, `enforce.go`, `ci.yml` und der
  Kopf von Fall 325 beschreiben den Stand unter `v0.81.0` im Indikativ und ohne Chronik. Die emittierte
  Datei sagt „des gepinnten d-check“ und nennt keine Werkzeug-Version. Ausnahme ist F-3.
- **(d) Kopf-Marken:** Der Diff von `7845860f` an `MR-066`/`MR-068`/`MR-073` besteht nur aus je einer
  Blockquote-Zeile direkt unter der Überschrift, in der Form von `MR-032` Setzung 1. Am Rumpf ist
  nichts geändert. `MR-065`-Angabe: vorhanden (*„kein Objektspeicher“*). §3.5: keine Senkung, die aktiven
  Module zeigen gleiche Mengen (Zahlen-Beleg siehe F-2). §3.8: der Commit berührt nur Architect-Artefakte
  und nennt die Rolle.
- **(e) CI:** Der einzige history-lesende Job `adr-immutable` checkt mit `fetch-depth: 0` aus und hat
  den Wächter vorgeschaltet (`ci.yml:101-125`). `gates`/`smoke`/`full-smoke` fahren kein History-Ziel am
  CI-Klon, und `release.yml`/`upstream-drift.yml` führen kein `doc-immutable`/`doc-commits`. Die
  Verneinung des Architect trägt.
- **(f) Mutationen:** Fall 325 ist grün gefahren, sein Kopf beschreibt die Lage unter `v0.81.0` richtig.
  Für Pin und Stufe gibt es keinen Fall. Die Kopplung des Pins halten
  `TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` in `make test`, die Stufe hält
  `make full-smoke`. Die Digest-gegen-Tag-Lücke ist in `MR-079` §Grenze und Plan §6 benannt.

## Nachrunde

Gegenstand: Architect-Commit `2bc04f31` (`MR-079`, F-1/F-2) und Implementer-Commit `d90d016b`
(`Makefile`, F-3).

- **F-1 behoben.** Der Retirement-Check ist nach Ebene getrennt, die Dogfood-Bindung stimmt mit der
  Verdrahtung überein. Bei leerem Index (`git diff --cached --quiet` → Exit 0) nachgemessen:
  `make history-range-guard STAGED=1` → `--staged ohne gestagte Aenderung — nichts zu pruefen.`, Exit 0;
  `make doc-immutable STAGED=1` → `2270 Datei(en) geprüft, 0 Befund(e)`, Exit 0.
- **F-2 behoben.** Prüf-Bedingung, Kommandos, Sonden und Grund-Code-Verteilung stehen im Eintrag.
  Stufe 1 nach seinem Kommando nachgefahren (`git archive` + `make -C "$K" docs-check DCHECK_DIGEST=…`):
  `dd26964c` unter `v0.81.0` und, mit `d-check.mk` aus `dd26964c~1`, unter `v0.79.0` je
  `2268 Datei(en) geprüft, 0 Befund(e)`; Symlinks `10 / 10`. Am heutigen `HEAD` unter `v0.81.0`:
  2270 Dateien, 0 Befunde.
- **F-3 behoben.** Der Kommentar an `adr-immutable` (`Makefile:296-302`) beschreibt den Stand unter
  `v0.81.0`, die beiden Aussagen decken sich mit den Messungen oben und im ersten Teil.
- **Kopf-Marken:** `git diff --stat 7845860f HEAD -- harness/conventions/MR-06[68]* harness/conventions/MR-073*`
  ist leer; seit `7845860f~1` trägt der Diff je nur die eine Marken-Zeile.

### N-1 — LOW — die `hostpaths`-Zeile nennt einen falschen Fundort, und der Eintrag bewegt seine eigene Zahl

- `quelle`: `MR-025` Setzung 1, `MR-058`
- `pfad`: `MR-079`, Unterpunkt **`hostpaths`** (Zeile 111-113)
- `befund`: Die Zeile sagt 33 → 36 und *„Die drei neuen sind `~/…`-Formen in `docs/reviews/**`“*. Nach
  dem Kommando des Eintrags am heutigen Baum gefahren, `diff` der sortierten Befundzeilen alt/neu:
  `v0.79.0` 33, `v0.81.0` 37. Neu sind `docs/plan/planning/done/slice-081-baum-tauschen-pin-ziehen.md:459`,
  zwei Zeilen in `docs/reviews/2026-09-27-*` und `MR-079` Zeile 113 selbst (der `~/…` im eigenen
  Text). Damit liegt einer der drei vorherigen Funde nicht unter `docs/reviews/**`, und der Eintrag
  hebt seinen eigenen Messwert schon an seinem Commit von 36 auf 37. Die Bilanz trägt das nicht, weil
  `hostpaths` kein aktives Modul ist.
- `verifizierbar`: ja (das `docker run … --enable hostpaths` des Eintrags, je Digest)
- `klasse`: Messung, die ihr eigener Vorgang bewegt

### N-2 — LOW — der Auflösungs-Trigger verweist auf eine Aussage über `targets.makefiles`, die der Eintrag nicht mehr trägt

- `quelle`: `MR-079` Auflösungs-Trigger
- `pfad`: `MR-079` Zeile 168
- `befund`: `2bc04f31` streicht den Satz zu `targets.makefiles` (Globs, im Dogfood nicht gesetzt) aus
  *„Was sich bewegt“*. Der Trigger sagt weiter, *„die Aussage über `hostpaths`/`targets.makefiles`“*
  sei neu zu prüfen. `grep -n 'targets.makefiles' harness/conventions/MR-079-*.md` → nur Zeile 168.
  Der Trigger hat für `targets.makefiles` damit keinen Gegenstand im Eintrag.
- `verifizierbar`: ja (der `grep`)
- `klasse`: Kürzung ohne Nachzug des Verweises

`make gates`: ein Lauf am Ende über dem Baum mit dieser Nachrunde; das Ergebnis steht in der
Commit-Message.
