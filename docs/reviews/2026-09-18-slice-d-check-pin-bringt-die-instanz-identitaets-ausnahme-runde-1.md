# Review-Report: slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme — 2026-09-18 (Runde 1)

**Review-Art:** Code — geprüft gegen den Slice-Plan (`slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme`), die Hard Rules (`AGENTS.md` §3), den Adaptions-Block und die Baseline-Form-Regeln.

**Gegenstand:** `cb3bc567` (Implementer: `d-check.mk`, `internal/emit/emit.go`) · `3aec7e7d` (Architect: Adaptions-Eintrag MR-068, Index-Zeile, §Baseline `d-check:`-Zeile)

**Skill:** `.harness/skills/reviewer.md` @ 2.0.0 ·
**Modell:** glm-5.3-flash (Claude Agent SDK) · **Datum:** 2026-09-18

**Eingangs-Kontext:**

- Slice-Plan `slice-d-check-pin-bringt-die-instanz-identitaets-ausnahme` (`docs/plan/planning/in-progress/`)
- `AGENTS.md` §3 (Hard Rules), §3.7/§3.8/§3.9
- `LH-QA-01`, `LH-QA-02` · `MR-010`, `MR-032`, `MR-051`, `MR-053`, `MR-054`, `MR-060`, `MR-062`, `MR-063`, `MR-065`, `MR-066`, `MR-067`
- `v6.9.0` · `regelwerk/modul-05-planning-harness.md`, `modul-08-agentenrollen.md`, `grundlagen-harness-dateien.md`, `grundlagen-traceability.md`

---

## Einzelentscheidung Kopf-Marken (Auftrag Punkt 5)

**Verdikt des Reviews: keine Kopf-Marken fällig — die Begründung des Architects trägt.**

Der Präzedenzfall sagt nicht, was er auf den ersten Blick sagt. Die Marken von MR-066 an MR-064/MR-065 und von MR-067 an MR-066 sind jeweils für **namentlich abgelöste Sätze** gesetzt, nicht als Pin-Ketten-Ritual:

- MR-066 begründet seine Marken an MR-064/MR-065 damit, dass „abgelöst wird nicht ein Messwert, sondern zweimal ein Satz, der **ohne Datum im Präsens** über den gepinnten spricht" — die `pack-`-Bedingung als Grenze bzw. der Wortlaut in MR-065 Setzung 2.
- MR-067 begründet seine Marke an MR-066 damit, dass „abgelöst wird … eine **Anleitung**" (der Aufbau-Satz von Messung 1).

MR-032 Setzung 4 nimmt die d-check-Pin-Kette ausdrücklich aus: „Nicht fällig, wo ein Eintrag von vornherein eine datierte Momentaufnahme ist … die d-check-Pin-Kette ist dieser Fall." MR-068 löst keinen Satz von MR-066 namentlich ab: die zwei Lücken (Alternates, leere Range) stehen laut Eintrag unverändert — Träger Quell-Differenz und byte-identischer Befundbestand —, und die Pin-Aussagen von MR-066 sind datierte Momentaufnahmen. Beide Vorgänger haben Marken genau dann gesetzt, wenn Setzung 1/3 sie verlangte; MR-068 steht in keinem dieser Fälle. Die Setzung 4 und der Präzedenz widersprechen sich hier nicht — der Architect hat die richtige Hälfte gelesen.

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | MEDIUM | Die Pin-Kopplung (`TestDefaultImage_MatchesCanonical`, `TestDefaultDigest_MatchesCanonical`) hat keinen Fall unter `test/mutations/` (`grep -rln 'DefaultImage\|DefaultDigest\|DCHECK_DIGEST\|DCHECK_IMAGE' test/mutations/` → kein Treffer; der bestehende Fall `01-baseline-pin-kopplung.sh` deckt die Baseline-Pins, nicht den d-check-Pin). Der Wächter trägt seine Zähne — die Rotation wurde in diesem Lauf real rot gefahren (s. Negativbefunde) —, aber sein Zahn ist nicht kuratiert und fällt beim nächsten Eingriff niemandem mehr auf. | `AGENTS.md` §3.6 | `internal/emit/emit_test.go:110-127`, `test/mutations/` | ja — `make mutate` (nightly) bzw. ein neuer Fall in `test/mutations/`, der die Pin-Zeile in `d-check.mk` allein bewegt | neuer-waechter-ohne-mutations-fall |
| F-2 | LOW | Die Sprung-Liste in §Baseline endet auf „…`MR-064` **und** `MR-066` **und** `MR-068`" — zwei „und" statt Komma vor dem letzten Glied; der Anhang hat das Listen-Schema der Zeile gebrochen. | Maintainability | `harness/conventions.md:22-23` | ja — `sed -n '21,24p' harness/conventions.md` | aufzaehlungs-drift-beim-anhaengen-einer-sprung-liste |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Pin-Stellen-Konsistenz (L1/L2) | geprüft, ohne Befund — `d-check.mk` und `internal/emit/emit.go` tragen denselben Tag `v0.77.0` und denselben Digest; `emit_test.go` ist über die Range unverändert (`git diff --stat cb3bc567^ 3aec7e7d -- internal/emit/emit_test.go` → leer) |
| Rot-Bedingung der Kopplung (Auftrag Punkt 1) | geprüft, ohne Befund — Rotation selbst gefahren: Wegwerf-Kopie von `3aec7e7d` per `git archive`, darin nur `d-check.mk` auf den alten Stand gesetzt, `make test-go` → Exit 1, `internal/emit` FAIL; sichtbar in der Ausgabe `TestDefaultImage_MatchesCanonical … (Tag-Drift)`; dass auch `TestDefaultDigest_MatchesCanonical` fällt, trägt der Test-Lesebefund — beide Tests lesen `d-check.mk` als kanonische Quelle (`emit_test.go:111,123`), der Digest-Test vergleicht gegen denselben alten Wert. Beide Testnamen stehen in der Fehlerklasse der Rotation |
| Kopfkommentar-Zustandssatz (Auftrag Punkt 2) | geprüft, ohne Befund — die Zahl stimmt und ist mit dem **kanonischen** Kommando gemessen: `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@sha256:3f84…337 --print-mk) d-check.mk \| grep -c '^[0-9]'` → 6 (Regelfall); dieselbe Form gegen die alte `d-check.mk` (Fragment mit ungleichem Tag) → 5. Auch der Mechanismus stimmt: der erste Veränderungsmarker des 5er-Diffs ist `1,15c1,76` — Kopf- und Pin-Block liegen in **einem** Zug. §3.7: der Satz beschreibt die Stelle im Indikativ (Zusage/Grenze), keine Chronik |
| Strenge-Bilanz (Auftrag Punkt 3) | geprüft, ohne Befund im erreichbaren Umfang — `grep -m1 '^modules:' .d-check.yml` → genau **9** Module (`links, anchors, ids, matrix, codepaths, spans, planning, targets, structure`); die im Eintrag genannte Verteilung je Grund-Code summiert auf die genannten 78 Befunde (17 Codes, Summe 78). **Nicht** neu gemessen: die Gegenmessung selbst (Stufen 1–3, Sonden, Symlinks) wurde nicht wiederholt; ihr Beleg bleibt die Commit-Message von `cb3bc567` (MR-051) und der Eintrag |
| Fremd-Kennungen (Auftrag Punkt 4) | geprüft, ohne Befund — `git show cb3bc567 3aec7e7d \| grep -inE 'a-check\|AUS-[0-9]\|CR-[0-9]+\|#[0-9]+\|issue\|pull/[0-9]\|/Development/'` → kein Treffer. Der Eintrag paraphrasiert den Anlass des Werkzeug-CHANGELOGs als Klasse („eine Quelldatei zitiert die eigene Instanz eines Ziels") ohne Adressen |
| Quell-Differenz am Werkzeug-Klon | geprüft, ohne Befund — am maschinen-lokalen Klon `/Development/d-check` (nur lesend): `git -C "$D" diff --numstat v0.76.3 v0.77.0 -- internal/hexagon/core/rules/` → genau `matrix.go` 61/10 und `matrix_test.go` 71/0; `git -C "$D" grep -ln 'allow-if-same-id' v0.77.0 -- internal/` außerhalb `rules/` → genau `configyaml.go` und `configyaml_test.go` |
| Neue Fähigkeit ohne Gegenstand | geprüft, ohne Befund — Dogfood-`.d-check.yml` ohne `token`; emittierte Vorlage: 3 Token-Klassen (`slice`, `welle`, `adaptionsblock`) und 4 Token-Form-Regeln (Kommandos aus dem Eintrag nachgefahren, beide Werte bestätigt); Quell-Pfade der Regeln können keine Ziel-Kennung tragen; Schlüssel wird nicht gesetzt |
| Architekt-Zahlen (Auftrag Punkt 7) | geprüft, ohne Befund — 5 Hunks (`diff <(git show cb3bc567^:d-check.mk) d-check.mk \| grep -c '^[0-9]'` → 5) und 4 Token-Form-Regeln (Kommando im Eintrag, nachgefahren) — beide tragen ihr Kommando im Eintrag und stimmen; numstat 8/6 bestätigt (`git show --numstat --format= cb3bc567 -- d-check.mk`) |
| MR-053 / MR-060 / MR-067 / MR-051 / MR-065 (Auftrag Punkt 6) | geprüft, ohne Befund — Werkzeug-Aussagen durchgängig mit Mess-Operand `v0.76.3`/`v0.77.0` datiert (MR-053); Feldliste vollständig gegen Template und Block-Praxis, inkl. `Wirksamkeits-Anlass` blank statt verlinkt (MR-060, MR-028); Prüf-Bedingung der Gegenmessung vor ihren Kommandos (MR-067); Messwerte an `cb3bc567` gebunden, die die Commit-Message trägt (MR-051); Angabe je history-lesendem Lauf als „kein Objektspeicher, keine Packs, keine Alternates, keine lose Objekte" hergeleitet (MR-065) |
| Makefile-Kopplung | geprüft, ohne Befund — beide `--disable`-Kopplungs-diffs (doc-commits, regelwerk-check) leer (Exit 0); emittierte `modules:` unverändert `[links, anchors, ids, matrix, spans]` |
| §3.7-Zählblock / AGENTS.md unberührt (Auftrag Punkt 9) | geprüft, ohne Befund — die beiden Kommentar-Muster-Zählungen über den §3.7-Pathspec sind an `cb3bc567^` und `3aec7e7d` identisch (64 bzw. 477 Zeilen); `d-check.mk` matcht keinen Glob des Pathspec, die Pin-Zeilen in `emit.go` sind keine Kommentar-Zeilen — die Begründung des Architects stimmt an beiden Stellen |
| §3.8-Commit-Zuschnitt | geprüft, ohne Befund — `git show --stat 3aec7e7d`: nur `harness/conventions.md` und die Eintrags-Datei; Rolle in der Message; `cb3bc567` nur die zwei Pin-Stellen. Keine Suppression-Zeile in beiden Commits (§3.2); alle Mess-Kommandos dieses Laufs Docker-only (§3.9) |
| Verweise | geprüft, ohne Befund — `make docs-check` war über `3aec7e7d` grün (Auftraggeber-Angabe, vom Review nicht wiederholt); die Zahl 1696 gegen 1695 aus der Implementer-Message reconciliert sich durch die eine zwischen den Commits hinzgekommene Eintrags-Datei |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 1 |
| INFO | 0 |

**Finding-Klassen dieses Laufs:** neuer-waechter-ohne-mutations-fall · aufzaehlungs-drift-beim-anhaengen-einer-sprung-liste

## Verdikt

**Merge-blockierend: nein.** Begründung der Abweichung von der Typik (MEDIUM blockiert typischerweise): F-1 betrifft nicht die Korrektheit dieses Diffs — der Wächter wurde in diesem Lauf real auf Rot gemessen, seine Zähne stehen; fehlt ist der kuratierte Mutations-Fall, der die Zähne über künftige Eingriffe hinweg listet. Das ist ein Bestands-Posten für die Slice-Closure §7 (Klasse in den Zähler) und einen vom Planner zu schneidenden Fall-Slice bzw. Register-Ausgang, kein Defekt am Sprung selbst. F-2 ist eine Zeile in einem noch nicht gepushten Architect-Commit und kann vor dem Push gezogen werden.

**Übergabe:** Findings an den Implementer (F-1: Fall in `test/mutations/` oder bewusster Register-Eintrag; F-2: Komma-Ziehung vor dem Push durch den Architect). Die Finding-Klassen gehen in die Slice-Closure §7. Dieser Report ist Lauf-Beleg; DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).