# Review-Report: slice-kotlin-freshness — 2026-10-09

**Review-Art:** Code — gegen Plan + Konventionen.

**Gegenstand:** `db31ad13`

**Skill:** `.harness/skills/reviewer.md` @ `78381a2b` (Version 2.3.0)

**Modell:** claude-opus-5-5 · **Datum:** 2026-10-09

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis)*. Dieser Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link.

**Eingangs-Kontext:**

- `slice-kotlin-freshness` (Plan, §1–§4, §6)
- `ADR-0088` Festlegung 2
- `LH-FA-04`, `LH-QA-02`, `LH-QA-01`
- `MR-089`
- `AGENTS.md` §3 (insbesondere §3.5, §3.6, §3.7, §3.9)
- `v6.17.0` · `regelwerk/modul-09-implementierung.md` (Fortschreibung von §3)

---

## Findings

### LOW-1 — Die Meldung `aktuell` behauptet einen gemessenen latest-Tag, wo nur der Pin über der gelesenen Seite liegt

- `kategorie`: LOW
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6 (Zusage)
- `pfad`: `harness/tools/kotlin-freshness.sh:61` (Pin geht in `sort -V` ein), Meldungstext aus `harness/tools/component-freshness.sh:36`
- `befund`: Weil der Pin in die Kandidaten-Menge eingeht, liefert ein Pin über jedem Tag der
  gelesenen Seite `aktuell — gepinnt und latest sind beide <pin>`, auch wenn es ihn upstream nicht
  gibt: `KOTLIN_PINNED=9.8.7-jdk21 bash harness/tools/kotlin-freshness.sh` → `kotlin-gradle: aktuell
  — gepinnt und latest sind beide 9.8.7-jdk21.`, Exit 0. Der Skript-Kopf benennt das Verhalten,
  die Laufzeit-Ausgabe, die der Nachtlauf zeigt, sagt dagegen einen latest-Tag zu, den keine Quelle
  geliefert hat. Abweichung zu `cpp-freshness.sh`, das den Pin nicht einmischt und in diesem Fall
  `VERALTET` meldet.
- `verifizierbar`: ja — Kommando oben (Netz)
- `klasse`: Laufzeit-Meldung sagt mehr zu als die Eingabe, die sie erzeugt hat

### INFO-1 — Die Seiten-Grenze trägt heute, die Sortierung steht nur im Skript-Kopf

- `kategorie`: INFO
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §3.6
- `pfad`: `harness/tools/kotlin-freshness.sh:19`, `harness/README.md` Zeile `make freshness-kotlin`
- `befund`: Gemessen: `…/gradle/tags/?page_size=100&name=jdk21` → `"count":657`, `next` auf Seite 2;
  Seite 1 trägt die Kandidaten `8.14.6-jdk21` und `9.8.1-jdk21`, Seite 2 `8.14.5`, `9.6.0`–`9.8.0`.
  Der volle Lauf meldet `aktuell`, Exit 0. Ein neuerer Tag fiele nur dann von Seite 1, wenn ihn
  mehr als 100 jünger aktualisierte `jdk21`-Tags verdrängen; der Skript-Kopf nennt die Grenze samt
  Sortierung (`last_updated`), die Sensors-Zeile nennt „erste Seite“ ohne Sortierung. Zusammen mit
  LOW-1 wird ein solcher Fall `aktuell`.
- `verifizierbar`: ja — `curl` wie oben
- `klasse`: Seiten-Grenze einer Registry-Abfrage ohne Sortier-Angabe am Ort der Zusage

### INFO-2 — Zwei Geschwister-Werkzeuge, zwei Einordnungen

- `kategorie`: INFO
- `quelle`: Maintainability
- `pfad`: `.d-check.yml:182`, `harness/README.md` §Werkzeuge
- `befund`: `freshness-kotlin` steht in Gruppe (a) mit Zeile in §Werkzeuge, `freshness-cpp`,
  `-go`, `-golangci`, `-dcheck` in Gruppe (b) ohne Zeile, obwohl alle im selben Nachtlauf hängen.
  Die Zeile verlangt die DoD; beide Einordnungen sind in sich stimmig. Daneben steht in
  `harness/sensors/docs-check.md` „heute **40**“ neben einem Kommando, das jetzt 49 ausgibt (vorher
  48) — Bestand, vom Diff nicht berührt.
- `verifizierbar`: ja — `sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep -c '^    - '`
- `klasse`: Geschwister-Sensoren uneinheitlich im Gate-Index geführt

## Negativbefunde

- **Erweiterung von §3:** geprüft, ohne Befund — `v6.17.0` · `regelwerk/modul-09-implementierung.md`
  lässt den Implementer die Datei-Tabelle in §3 fortschreiben; die zwei Zeilen berühren weder DoD
  (§2) noch Abgrenzung (§1) noch Trigger (§4/§5), und der Nachtlauf-Aufruf folgt dem in §1
  genannten Vorbild `freshness-cpp`. Keine Verschiebung der Abnahme (§3.10).
- **`.d-check.yml` (§3.5):** geprüft, ohne Befund — der Kommentar zu Gruppe (a) nennt
  `freshness-kotlin`; Zählung nachgezählt: 25 Namen, davon 21 mit `## `-Hilfetext („NICHT in
  gates“), die vier ohne sind korrekt benannt. Der Eintrag schaltet kein Baum-Segment stumm.
- **Netz-Fetch-Pfad:** geprüft, ohne Befund über LOW-1/INFO-1 hinaus — bats-Kopf und Skript-Kopf
  sagen ausdrücklich, dass kein Test den Fetch fährt; die Sensors-Zeile sagt keine Testdeckung zu.
  Live gefahren: `make freshness-kotlin` → `aktuell`, Exit 0. Fetch-Fehler (`curl -f`) oder leere
  Seite enden über den leeren latest-Wert in Exit 2, nicht grün.
- **Gleichlauf mit cpp:** geprüft — gemeinsamer Vergleicher `component-freshness.sh --compare`,
  gleiche Exit-Klassen 0/1/2, Pin-Abbruch mit Exit 2 statt `${VAR:?}`; Abweichung allein im
  Pin-Einmischen (LOW-1) und im Pin-Lesen im Skript statt im Makefile.
- **Fälle 629–632:** gefahren — `make mutate MUTATE_CASES='629-kotlin-freshness-varianten-suffix
  630-kotlin-freshness-pin-zaehlt-nicht-mit 631-kotlin-freshness-pin-form-exit
  632-kotlin-freshness-pin-quelle'` → `mutate: 4 ok, 0 Befund(e)`. Gegenprobe in einem
  Scratch-Klon, je Mutation `make test-bats BATS_TARGET=test/kotlin-freshness.bats`: jeweils
  `not ok` = 1 (genau der in `# expect:` benannte Fall), `ok` = 6 — die Exklusivitäts-Aussage der
  Fall-Köpfe hält. Alle vier treffen das Skript, das das Makefile-Ziel aufruft.
- **Teil-Grenzen der Achsen-Regel:** geprüft — Varianten-Suffix (Fall 629), Kurz-Tag `10.0-jdk21`
  und anderes JDK `9.9.0-jdk25` (Fixture `FIX_FREMD`, im selben Test gebunden: beide überträfen
  `9.8.1` nach `sort -V`).
- **`ADR-0088` Festlegung 2:** geprüft, ohne Befund — Pin per Tag `gradle:<ver>-jdk<NN>`, gelesen aus
  `DefaultKotlinVersion`.
- **`MR-089`:** geprüft, ohne Befund — der Diff und die Commit-Message tragen keine Laufzeit-Aussage
  über einen Lauf im Ziel oder einen E2E-Lauf.
- **Hard Rules §3.2/§3.7/§3.9:** geprüft, ohne Befund — keine Inline-Suppression
  (`grep -c shellcheck` → 0 in Skript und bats), Kommentare tragen Zusage/Grenze/Kopplung, Docker-only
  bis auf `curl` im Netz-Werkzeug wie bei `cpp-freshness.sh`.

## Summary

0 HIGH · 0 MEDIUM · 1 LOW · 2 INFO — wiederkehrende Klasse: Laufzeit-Meldung sagt mehr zu als die
Eingabe, die sie erzeugt hat.

## Verdikt

Mergebar. LOW-1 ist vor Closure zu entscheiden (Meldung oder Pin-Einmischung), blockiert nicht.
