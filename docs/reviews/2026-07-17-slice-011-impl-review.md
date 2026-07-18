# Review-Report: slice-011 Implementierung (Baseline-Vendoring) — 2026-07-17

**Review-Art:** Code — geprüft gegen Plan (slice-011 DoD) + Konventionen (Modul 9/10),
Hard Rules, LH-QA-01/02/03, MR-007.

**Gegenstand:** Commit `554cade` („slice-011: Baseline v3.1.0 committet vendoren …"),
die Implementierung des Slice. Nicht der vendored Baum selbst (derivativ, gate-exempt),
sondern die Mechanik: `harness/tools/baseline-verify.sh`, `sessionstart-inject-regelwerk.sh`,
`Makefile`, `test/sessionstart.bats`, `.gitignore`, `.d-check.yml`, `AGENTS.md`,
`CLAUDE.md`, `harness/README.md`, `harness/conventions.md`.

**Skill:** `.harness/skills/reviewer.md` @ 1.0.0 ·
**Modell:** claude-opus-4-8[1m] (Orchestrierung) + 3× claude-sonnet-5 (Linsen) ·
**Datum:** 2026-07-17

**Verfahren:** drei unabhängige Linsen — (a) Korrektheit der Shell-Mechanik,
(b) DoD-Abdeckung + Harness-Konformität, (c) Faktentreue. Diesmal mit **vollständigem
Eingangs-Kontext** (Lehre aus dem Plan-Review-Lauf, s. `docs/reviews/2026-07-17-slices-011-014-plan-review.md`
§Verdikt): allen Linsen wurde der **in-repo vendored `lab`-Baum** als Grundwahrheit
benannt, nicht die divergente `kurs/de`-Fassung. Der Zahlen-Widerspruch F1 wurde von
zwei Linsen unabhängig gefunden.

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde):

- slice-011 (Ziel + DoD + §6), `.harness/skills/reviewer.md`
- aktive ADRs: ADR-0003 (Docker-only), ADR-0004 (Emission)
- `LH-QA-01/02/03`, `AGENTS.md` §3 (Hard Rules), MR-007 + Historie-Marker an MR-004/006
- Grundwahrheit: `.harness/baseline/v3.1.0/{regelwerk,templates}/` (in-repo) + die v3.1.0/v3.0.0-ZIPs

---

## Findings

### F-1 — Zahlen-Widerspruch „15" vs. „12 eindeutige" (zwei Linsen)

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02 (Reproduzierbarkeit)
- `pfad`: `AGENTS.md` §1 (Regelwerks-Absatz)
- `befund`: `AGENTS.md` nannte „**15** `../templates/…`-Verweise", während MR-007 und
  slice-011 durchgängig „**12 eindeutige** Ziele, 0 tot" als gemessene Zahl führen. 15
  ist die rohe Grep-Treffer-Zahl ohne Dedup — exakt die Verwechslung, die schon der
  Plan-Review als MEDIUM markiert hatte und die dieser Slice auflösen sollte.
- `verifizierbar`: `grep -rhoP '\.\./templates/\S*?\.md' .harness/baseline/v3.1.0/regelwerk/ | sort -u | wc -l` → 12.
- **Behandlung: behoben** — `AGENTS.md` nennt jetzt „12 eindeutige Ziele, 0 tot" mit Verweis auf MR-007.

### F-2 — Veraltete Größenangabe „~4000 Zeilen / ~108k Token"

- `kategorie`: MEDIUM
- `quelle`: LH-QA-02
- `pfad`: `CLAUDE.md` (Regelwerks-Absatz), `AGENTS.md` §1
- `befund`: Beide nannten für den `regelwerk/`-Baum „~4000 Zeilen / ~108k Token" —
  gemessen sind es **2801 Zeilen / 170.522 Byte**. Die Zahl stammt aus der als HISTORIE
  eingefrorenen MR-004-Ära (212-KB-Monolith) und wurde unverändert mitgeführt, statt
  gegen den in demselben Commit vendorten Baum nachgemessen zu werden.
- `verifizierbar`: `cat .harness/baseline/v3.1.0/regelwerk/*.md | wc -lc` → 2801 / 170522.
- **Behandlung: behoben** — beide nennen jetzt „~2800 Zeilen / ~170 KB (gemessen)".
  Die Kernaussage „sprengt das 150k-Zeichen-Limit" bleibt wahr (170 KB > 150 k) und
  ist jetzt am gemessenen Wert verankert statt an einer geerbten Token-Schätzung.

### F-3 — Injektor: `$tag` im Warnpfad nicht JSON-escaped

- `kategorie`: MEDIUM
- `quelle`: Maintainability (Korrektheit)
- `pfad`: `harness/tools/sessionstart-inject-regelwerk.sh` (vormals Zeile 49)
- `befund`: Der „Index fehlt"-Warnpfad bettete den entdeckten Tag-Verzeichnisnamen roh
  in das `additionalContext`-JSON ein — anders als der Erfolgspfad, der ihn durch
  `json-encode.awk` führt. Ein Tag-Name mit `"` oder `\` bricht das JSON. Realer Trigger
  gering (git-Tags enthalten selten solche Zeichen), aber eine echte Asymmetrie.
- `verifizierbar`: Tag-Verzeichnis `v9"evil` anlegen, Index weglassen, Skript-Ausgabe durch `python3 -m json.tool` — vor dem Fix `JSONDecodeError`.
- **Behandlung: behoben** — awk-Check vor die Index-Prüfung gezogen; der Warnpfad läuft
  jetzt über einen `warn_encoded`-Helfer. Mit adversarialem Tag-Namen als valides JSON verifiziert.

### F-4 — `baseline-verify` ohne Test (stärkster struktureller Fund)

- `kategorie`: MEDIUM
- `quelle`: LH-QA-01 (fehlende Negativtests bei neuem Gate)
- `pfad`: `harness/tools/baseline-verify.sh` (kein Test in `test/`)
- `befund`: Der neue `gates`-Prerequisite, dessen Kern-Eigenschaft (Vollständigkeits-Check
  zusätzlich zu `sha256sum -c`) der Commit als „real vorgeführt" bezeichnet, hatte **keinen**
  bats-Test. Ein späterer Rückbau auf reines `sha256sum -c` bliebe grün und keine
  Regression würde erkannt, bis eine manipulierte Baseline durchrutscht. Der analoge
  Injektor bekam im selben Commit vier Tests — der Verifier keinen.
- `verifizierbar`: `grep -rl baseline-verify test/` lieferte nichts.
- **Behandlung: behoben** — `test/baseline-verify.bats` mit 9 Fällen: sauber→grün,
  geänderte/gelöschte/getauschte/zusätzliche Datei→rot (inkl. explizitem Beleg, dass
  `sha256sum -c` bei der zusätzlichen Datei blind grün bleibt), fehlende SHA256SUMS,
  fehlende Baseline, zwei Tags, GNU-escapter Pfad. bats jetzt 47/47.

### F-5 — Falsch-Positiv bei GNU-escaptem Dateinamen

- `kategorie`: LOW
- `quelle`: Maintainability (Korrektheit)
- `pfad`: `harness/tools/baseline-verify.sh` (Vollständigkeits-Vergleich)
- `befund`: GNU `sha256sum` escapt Dateinamen mit Backslash/Newline (führender
  Backslash am Zeilenanfang). Der Vollständigkeits-Vergleich (`cut`/`find`) dekodiert
  das nicht und würde eine solche Datei fälschlich als abweichend melden — Rot ohne
  Manipulation. Kein aktueller Trigger (kein solcher Name im Baum).
- `verifizierbar`: Zeile mit führendem `\` an SHA256SUMS anhängen → vor dem Fix „weicht ab"-Meldung statt gezielter Diagnose.
- **Behandlung: behoben** — Format-Vorbedingung: `baseline-verify` bricht bei einem
  escapten SHA256SUMS-Eintrag **laut** ab (vor jedem Urteil), statt still falsch-positiv
  zu werden. Ehrlich „kann ich nicht" statt still „alles gut". Als Test fixiert.

### F-6 — Tote Konfigurationsvariable `BASELINE_DIR`

- `kategorie`: LOW
- `quelle`: Maintainability
- `pfad`: `Makefile` (vormals `BASELINE_DIR ?= …`)
- `befund`: Definiert, aber von keinem Target/Skript/`.d-check.yml` gelesen — beide
  Skripte entdecken das `<tag>`-Verzeichnis per Glob. Ein `make gates BASELINE_DIR=…`
  wäre ein stiller No-op.
- `verifizierbar`: `grep -rn BASELINE_DIR .` zeigte nur die Definitionszeile.
- **Behandlung: behoben** — Variable entfernt, durch einen Kommentar ersetzt, der die
  Glob-Entdeckung erklärt.

### F-7 — Diagnosequalität bei Permission-Fehler (unguarded Zuweisung)

- `kategorie`: LOW
- `quelle`: Maintainability
- `pfad`: `harness/tools/baseline-verify.sh` (`listed=`/`actual=`)
- `befund`: Die Zuweisungen sind unguarded; schlägt `find` an einem
  Permission-denied-Unterverzeichnis fehl, bricht `set -e` vor der gezielten Diagnose
  ab. Exit-Code bleibt 1 (kein stilles Grün), aber statt der „Dateibestand weicht ab"-Meldung
  erscheint nur die rohe `find: Permission denied`-Zeile.
- `verifizierbar`: `chmod 000` auf ein Unterverzeichnis, dann `bash -x baseline-verify.sh`.
- **Behandlung: akzeptiert, nicht behoben** — LOW, der finale Exit bleibt korrekt rot
  (kein stilles Grün). Auf einem committeten, lesbaren Baum nicht auslösbar; eine
  Härtung stünde im Missverhältnis zum Ertrag. Bewusst als Restrisiko geführt.

## Negativbefunde (geprüft, ohne Befund)

- **Kein stiller Grün-Pfad in `baseline-verify`:** Alle vier Manipulations-Gegenbeispiele
  (zusätzliche Datei in Unterverzeichnis, delete+add gleicher Zahl, leere Datei, Name mit
  Leerzeichen) erzeugen rot — vier separate mktemp-Läufe, jetzt als bats fixiert.
- **Glob-Entdeckung:** 0 → Fehler (fail-safe), 1 → OK, >1 → Fehler (Setzung erzwungen);
  reguläre Datei bzw. verstecktes Verzeichnis neben dem Tag-Dir werden korrekt ignoriert.
- **Harness-Lüge / DoD 7:** Kein Rest von „gitignored"/„regelwerk-fetch"/„wortgleich"/
  „kein committeter Fremd-Blob" außerhalb der HISTORIE-Blöcke; die Treffer in den Skripten
  sind korrekte Negationen („es gibt kein `make regelwerk-fetch` mehr").
- **Hard Rule §3.3:** `git show --stat 440ca8b` = reiner `git mv` (100 %) vor dem
  Content-Commit — sauber getrennt. **§3.4:** keine ADR unter `docs/plan/adr/` verändert.
  **§3.5:** `baseline-verify` ist Gate-Erweiterung, keine Lockerung — keine ADR-Pflicht.
- **LH-QA-02/03:** `BASELINE_ZIP_SHA256` als alleiniger, benutzter Provenienz-Anker;
  `unzip` aus der Mechanik entfernt, `curl` nur in `regelwerk-check` (Maintenance).
  ZIP-sha256 `bd90c721…0220` byte-genau gegen das ZIP bestätigt.
- **MR-007-Konsistenz:** alle vier Setzungen wörtlich; MR-004/006 als HISTORIE markiert,
  nicht überschrieben; d-check (inkl. `ids link-policy: always`) 0 Befunde.
- **Baseline-Zähldaten:** 42 Dateien (21+21), SHA256SUMS 42 Einträge (enthält sich nicht
  selbst), 12 eindeutige Verweis-Ziele in den `templates`-Baum (0 tot), ~241 KB — alle gegen den in-repo
  Baum bestätigt. „genau ein `v3.1.0` in Mechanik-Dateien" (`Makefile:18`) bestätigt.
- **Frischer Klon, netzlos:** Baseline präsent, `baseline-verify` grün, `regelwerk-fetch`
  existiert nicht mehr, die Verweise in den `templates`-Baum lösen auf (LH-QA-01-Messmethode, im Slice-Bau vorgeführt).

## Nicht verifizierbar (Grenze des Laufs)

- Release-Zeitstempel „v3.1.0 … 03:54 UTC, neun Stunden nach v3.0.0" (Slice §6) — keine
  lokale Quelle für GitHub-Timestamps; im Slice-Bau separat per API bestätigt.
- Verhalten von `regelwerk-check` unter tatsächlichem v1.2.0-Pin — v1.2.0-ZIP nicht mehr
  lokal; indirekt über die alte `REGELWERK_URL` im git-Verlauf gestützt.

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 4 |
| LOW | 3 |
| INFO | 0 |

## Verdikt

**Merge-blockierend:** nein. Kein HIGH — die Kernmechanik (Provenienz-Pin,
Integritäts- + Vollständigkeits-Check, netzlos, Glob-Entdeckung, Historie-Marker) trägt
und ist gegen den in-repo Baum belegt. Alle vier MEDIUM und zwei der drei LOW sind
**behoben**; F-7 (LOW) ist als Restrisiko bewusst geführt.

**Bemerkenswert:** Der stärkste Fund (F-4) war eine **Test**-Lücke, kein Bug — der
Verifier funktionierte, aber ohne Regressions-Schutz. Der neue `baseline-verify.bats`
schließt genau das und macht den Vollständigkeits-Check (das Herz des Slice) gate-gebunden.
Zwei der Fixes deckten Portabilitätsfehler auf, die nur im busybox-basierten bats-Image
auftraten (`sha256sum --quiet` GNU-only), nicht auf dem Host — der Test hat also sofort
etwas gefangen, das der Host-Lauf nie gezeigt hätte.

**Steering-Loop-Eintrag:** Die Klasse „behauptete statt gemessene Zahlen" trat erneut auf
(F-1, F-2) — aber diesmal **schwächer und gefangen**: der Plan-Review hatte F-1 schon
markiert, die Implementierung präzisierte MR-007/Slice, ließ aber `AGENTS.md` stehen. Das
bestätigt den im vorigen Report benannten Sensor-Bedarf (slice-015): kein Gate prüft
Prosa-Zahlen, und Sorgfalt allein schließt die Lücke nicht. Neuer, konkreter Lerneintrag:
**Reports zitieren Slices per ID, nicht per Lifecycle-Pfad** — der Plan-Review wurde durch
den `next→in-progress`-Move rückwirkend rot (Frozen-Doc-Falle); dieser Report vermeidet das.

**Übergabe:** Findings sind im Working Tree verarbeitet (Rückkante Review → Implementation).
Der Report ersetzt keine Verifikation — die DoD-/Spec-Konformität ist durch die echten
Gate-Läufe belegt (baseline-verify OK, d-check 35/0, bats 47/47, shellcheck clean).
