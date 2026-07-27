# Review-Report: slice-056 — 2026-07-27

**Review-Art:** Code — geprüft wird der fertige Diff gegen **Plan + Konventionen**
(Modul 10 §Drei Review-Arten). Nicht geprüft: die DoD-Abhakung (Verifier, Modul 11).

**Gegenstand:** slice-056 (Ein Mutations-Fall fährt nur den Sensor, den er braucht),
Arbeitsbaum vor der Closure: `Makefile`, `harness/tools/mutate.sh`,
`test/mutate-driver.bats`, `test/mutations/97-mutate-sensorwahl.sh`.

**Skill:** `.harness/skills/reviewer.md` @ 1.4.0 · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5[1m] · **Datum:** 2026-07-27

**Grenze dieses Laufs:** kein frischer Kontext (Modul 8); jedes Finding trägt sein Kommando.

**Eingangs-Kontext:**

- Slice-Plan: `docs/plan/planning/in-progress/slice-056-mutate-laufzeit.md` (§2 DoD drei Punkte, §3 Ist-Messung, §6 Risiken)
- Berührte Verträge: [`AGENTS.md`](../../AGENTS.md) §3.6 (`make mutate` ist der Sensor zu dieser Regel — seine **Aussage** darf sich nicht ändern), [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6), [`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
- Vorherige Findings am gleichen Werkzeug: slice-026 (F-5 `verify`-Modi, F-6 Grün-Vorlauf, F-7 doppelte Köpfe), slice-047 (Host-Isolation), slice-055 (das `comment-claims`-Gate)

---

## Findings

### F-1 — Das eigene Gate meldete einen Fehlalarm auf eine Namens-Konvention

- `kategorie`: MEDIUM
- `quelle`: slice-055 §6 („der Gate prüft eine Form, keine Bedeutung") · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `harness/tools/comment-claims.sh` (Prüfung (b)), ausgelöst von `harness/tools/mutate.sh`
- `befund`: Der neue Kommentar erklärte das Auswahl-Muster mit einem **illustrativen** Testnamen. Der Existenz-Check las ihn als Sensor-Verweis und meldete `(erfundener Sensor) … — kein solcher Test im Repo`; `make gates` wurde rot. Der Check prüft **jeden** `Test[A-Z]…`-Token in einem Kommentar, auch wenn der Block gar keine Abdeckungs-Behauptung trägt — eine illustrative Namensform ist damit nicht von einer behaupteten Sensor-Nennung unterscheidbar.
- `verifizierbar`: ja — `make comment-claims` vor und nach der Umformulierung (Exit 1 → Exit 0).
- **Status:** eng aufgelöst — der Kommentar nennt jetzt das Muster („Präfix `Test` plus Großbuchstabe") statt eines Namens. **Die breite Lösung wurde bewusst nicht genommen:** den Existenz-Check auf Blöcke mit Behauptung einzuschränken wäre eine Gate-Lockerung und gehört nicht in einen Laufzeit-Slice. Kandidat für den bereits offenen slice-055-Backlog-Punkt zum Prüfbereich.

### F-2 — Eine Messung ging verloren, weil der Fix in einer gesperrten Datei lag

- `kategorie`: LOW
- `quelle`: Maintainability · `harness/tools/mutate.sh` (Isolations-Fingerprint)
- `pfad`: Ablauf, nicht Code
- `befund`: `make gates` war rot (F-1), der Fix lag in `mutate.sh` — einer Datei, die während eines `mutate`-Laufs nicht verändert werden darf (der Lauf meldete sonst „Isolation gebrochen"). Der laufende Nachher-Lauf musste abgebrochen und nach dem Fix wiederholt werden; ~10 Minuten Laufzeit verloren. **Kein Datenverlust** — es war noch keine Zeit ermittelt.
- `verifizierbar`: ja — die abgebrochene und die gültige Messung liegen als getrennte Läufe vor.
- **Status:** benannt, nicht behoben. Die Lehre — erst Gates grün, dann messen — steht in der Closure-Notiz.

### F-3 — Die DoD-Formulierung „weiterhin 92 ok" ist durch den eigenen Wächter überholt

- `kategorie`: LOW
- `quelle`: slice-056 DoD (2)
- `pfad`: `docs/plan/planning/in-progress/slice-056-mutate-laufzeit.md`
- `befund`: DoD (2) verlangt „weiterhin **92 ok / 0**" **und** einen Wächter auf die neue Auswahl. Beides zusammen ist nicht erfüllbar: der Wächter ist Fall 97, also läuft der Satz auf **93**. Dieselbe Klasse wie die „byte-identisch"-Formulierung in slice-053 — der DoD-Text ist älter als das, was er selbst verlangt.
- `verifizierbar`: ja — `make mutate` meldet `93 ok, 0 Befund(e)`; der fallweise Vergleich zeigt genau einen Unterschied (den neuen Fall).
- **Status:** in der Closure-Notiz aufgelöst; die **Substanz** von DoD (2) — kein alter Fall verliert seinen Wächter — ist belegt.

### F-4 — Die `expect`-Zeile ist jetzt Steuergröße, nicht nur Dokumentation

- `kategorie`: INFO
- `quelle`: Plan §6 (dort vorab benannt)
- `pfad`: `harness/tools/mutate.sh` (`narrow_sensor`)
- `befund`: Ein Tippfehler in `# expect:` verschiebt ab jetzt die Abdeckung, statt nur die Meldung zu verfälschen. Abgefedert durch die Fail-closed-Regel und vier Driver-Tests; ganz abstellen ließe es sich nur mit einer zweiten Metadaten-Zeile — die wieder driften könnte.
- `verifizierbar`: ja — die vier `narrow_sensor`-Fälle in `test/mutate-driver.bats`.

## Negativbefunde

- geprüft, ohne Befund: **`make test` unverändert in Bedeutung und Reihenfolge** — `test: test-bats test-go` fährt beide Stufen wie zuvor (bats zuerst); `gates` und CI rufen weiterhin `test`.
- geprüft, ohne Befund: **Fail-closed real** — `narrow_sensor` liefert für leere und mehrzeilige Erwartung `test` (beide Stufen); direkt gegen alle vier Formen gemessen.
- geprüft, ohne Befund: **Verteilung über die realen Fälle** — 60 × `test-go`, 31 × `test-bats`, 2 × eigener `verify`-Modus (`smoke`, `ci-lint`); die zwei behalten ihren Sensor unverändert.
- geprüft, ohne Befund: **Fehlschlag-Muster für die neuen Modi** — `failure_form` kennt beide; ohne sie fiele Bedingung 4 in den „rot aus falschem Grund"-Zustand (slice-026 F-1).
- geprüft, ohne Befund: **Grün-Vorlauf weiterhin tragend** — er läuft über `test` (beide Stufen) und deckt die verengten Sensoren mit ab.
- geprüft, ohne Befund: **kein neuer Host-Bedarf** ([`LH-QA-03`](../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) — reines bash/`case`, kein zusätzliches Werkzeug; `make shell-lint` Exit 0.
- geprüft, ohne Befund: **stale Kommentar mitgezogen** — der Hinweis „Ohne die Angabe fährt run_case nur `make test`" wäre nach dem Umbau falsch und wurde im selben Zug korrigiert.
- geprüft, ohne Befund: **Wächter für die neue Logik** — Fall 97 entschärft die Fail-closed-Regel und färbt den zugehörigen Driver-Test rot (im Lauf belegt).

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 2 |
| INFO | 1 |

## Verdikt

**Merge-blockierend:** nein — **nach Auflösung**. F-1 ist eng aufgelöst (Kommentar statt
Gate-Lockerung); F-2 und F-3 sind benannte Kosten bzw. eine überholte Plan-Formulierung, beide
in der Closure-Notiz; F-4 ist eine bewusst eingegangene Kopplung.

**Der Kern ist nicht die Zeit, sondern dass die Aussage steht:** `19m01s → 10m54s` (−43 %) ist
nur dann etwas wert, wenn kein Fall seinen Wächter verloren hat. Der fallweise Vergleich beider
Läufe zeigt genau **einen** Unterschied — den neu hinzugekommenen Fall 97.

**Übergabe:** Findings gehen an die Implementation. Der Report ersetzt keine
Verifikation — DoD-/Spec-Konformität prüft der Verifier separat (Modul 11).
