# Review-Report: slice-c4-environment-check-v7-0-0 — 2026-11-25

**Review-Art:** Code-Review — gegen Plan + Konventionen (Modul 10 §Drei
Review-Arten); dazu Plan-Treue des Diffs über die Range.

**Gegenstand:** `slice-c4-environment-check-v7-0-0` — Range
`260d1565..a24c1d82` (Claim · Messtelle in `make smoke` +20/−1 ·
Ruhe-Marker-Nachzug).

**Skill:** `.harness/skills/reviewer.md` @ 2.3.0 ·
**Modell:** claude (glm-5.3-flash) · **Datum:** 2026-11-25

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein
> Ausfüll-Hinweis; die `<Platzhalter>` darin sind Formbeispiele)*. Dieser
> Report friert ein; was er zitiert, bewegt sich
> weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine
> Baseline-Stelle als **Tag + Pfad in Inline-Code** statt als Link
> (`v<X.Y.Z>` · `regelwerk/<datei>.md` §<Abschnitt>). Der vendored Baum trägt
> genau einen Tag; der Sprung löscht den alten, und ein Link darauf färbt beim
> nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein `pfad`-Feld
> auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den
> Stand des Laufs und darf ihn festhalten (`v<X.Y.Z>` ·
> `regelwerk/grundlagen-harness-dateien.md` §harness/README.md als
> Einstiegspunkt — diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne
diese Liste ist der Lauf nicht reproduzierbar):

- `slice-c4-environment-check-v7-0-0` (Plan, `in-progress/`)
- ADR-0057 (Singleton-Default der Vorlagen-Dispositons-Form)
- LH-QA-01 (keine halluzinierten Gates) · LH-QA-02 (Reproduzierbarkeit) · LH-FA-02
- MR-025 · MR-030 · MR-051 · MR-057 · MR-071 · MR-090 · MR-091
- `AGENTS.md` (Hard Rules, §3.6 und §3.7 im Sonderfokus)
- `v7.0.0` · `regelwerk/modul-10-review-harness.md` §Ziel-Form: Reviewer-Skill

---

## Findings

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | INFO | Die zweite Messtelle in `make smoke` (Gate-Neutralität des emittierten Singletons) trägt im Bericht dieses Laufs keinen eigenen Rot-Beleg: die von Hand gefahrene Mutation an `emit.inScope` färbte allein die **Existenz**-Messtelle rot („smoke 3/5 fehlt-Meldung"); die Messtelle selbst wurde als Werkzeug nicht gebrochen. Ihr Rot-Pfad ist real und greifbar — die Ausgangs-Vorlage trägt die Nennung nachweislich (`grep -c 'make environment-check' .harness/baseline/v7.0.0/templates/harness/sensors/environment-check.template.md` → **1**), eine misslungene Neutralisierung würde sie im emittierten Kopiertext stehen lassen und der `grep` der Messtelle fände sie. Der Mechanismus darunter ist auf Unit-Ebene gebunden (`test/mutations/153-ziel-anspruch-nicht-neutralisiert.sh` → `TestEmittierteDokumente_NurInitInvarianteZiele`), aber über einer Anspruchs-Fixture, nicht über der realen v7.0.0-Vorlage. | [`AGENTS.md`](../../AGENTS.md) §3.6 | `harness/tools/smoke.sh:93` · `grep -q 'make environment-check' "$tmprepo/harness/sensors/environment-check.md"` | ja — der Verifier fährt die Hand-Mutation am Real-Träger (`internal/emit/templates.go` `planTemplates`, der `NeutralizeMakeClaims`-Aufruf im Singleton-Pfad) und `make smoke`; erwartet rot an dieser Messtelle | „Rot-Beleg einer neuen Smoke-Messtelle nur hinter der ersten von zwei Prüfungen" |

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| Messtelle in `make smoke` — **Existenz**-Prüfung (Vorlagen-Liste + Kopiere-Satz der Vorlage im vendored Ziel-Baum) | geprüft, ohne Befund — der Rot-Beleg fährt die reale Quelle (Hand-Mutation an `emit.inScope`, kein Stub, kein Fixture); die Meldungs-Form („3/5 … fehlt") deckt sich mit der Stellenlage im Skript |
| Messtelle-Form — Zusage **und** Grenze am selben Ort („Gemessen ist hier die Existenz des Skeletts und dessen Gate-Neutralität — NICHT ein Check im Verhalten") | geprüft, ohne Befund — trägt R2/LP2 am Messtellen-Ort, nicht als `E2E ok`-Aussage; MR-051-formal tragen die Zahlen der Commit-Message ihr Kommando („smoke 3/5 …" nennt `smoke`, „0 Befunde" nennt `docs-check`) |
| Kommentar-Form der Messtelle (`harness/tools/smoke.sh:79-96`) | geprüft, ohne Befund — Zusage/Kopplung/Grenze, Zustands-Präsens, Kennung statt Chronik; Herkunfts-Anker (`LH-QA-02` · `seit slice-c4-environment-check-v7-0-0`) an Ort |
| Substring-Form der Neutralitäts-Messtelle (`grep -q 'make environment-check'` ohne Grenze am Wort) | geprüft, ohne Befund — ein fremder Wert (`environment-check-<x>`) färbt in die **fail-closed**-Richtung rot (ebenfalls ein Anspruch auf ein nicht geschriebenes Ziel, LH-QA-01); kein stilles Grün |
| Emissions-Weg (`internal/emit/templates.go`): `inScope`-Regel-Form + Singleton-Default in `planTemplates`, Weichen `isRecurring`/`isDerivativeIndex`/`isBrownfieldOnly` treffen die Vorlage nicht | geprüft, ohne Befund — Walk-Form ist die reale Emission, kein Code-Zug nötig; Fixtur (`internal/emit/templates_test.go` Dispositons-Form + Ziel-Menge „exakt 25 in-scope" in `make smoke`-Nachbar-Fixture) trägt die Form an der richtigen Stelle (Fixtur, nicht Smoke) |
| Zugehörigkeits-Wortlaut der Emitter-Verankerung — Fixtur trägt die Dispositions-Aussage, Smoke trägt die Existenz-/Neutralitäts-Verifikation | geprüft, ohne Befund — Ort je Aussage passend zur Plan-Tabelle (§3) |
| Realer-Vertreter-Form: beide neuen Prüfungen laufen an `$tmprepo` **nach** dem echten Bootstrap (Schritt 1–2 des Smokes), an geholter Baseline und emittierter Kopie | geprüft, ohne Befund |
| Titel-Neutralisierungs-Ankerung: „kein `make environment-check`-Anspruch … (NeutralizeMakeClaims)" | geprüft, ohne Befund — zutreffende Anker-Form ist der Mechanismus-Name (`NeutralizeMakeClaims`, ADR-konform im Bestand `internal/emit/templates.go:419-422` mit LH-QA-01); **keine** MR-030-Berührung — MR-030 trägt die Rollen-Namen/Bezeichner-Aussage, nicht den Make-Claim |
| `mutate-auswahl` lokal, 1 Fall (`668-pin-fallback-smoke-veraltet`) | geprüft, ohne Befund — MR-091 Setzung 1: bis 8 Fälle lokal legitim, 1 ≤ 8; Fall 668 ist Bestand (Anlage-Pflichten aus MR-071 binden nicht), sein sed-Anker (`GO_VERSION="${GO_VERSION:-…}"`) ist vom Diff unberührt, `mutate-greift` grün über `make gates`; kein Anlage-Anker-Pflicht-Nachzug |
| `d-check:ignore`-Bedarf | geprüft, ohne Befund — der Befund trat nicht auf: der Baseline-Zug ist durch `scan.ignore` (`**/*.template.md` und `.harness/baseline/**` in `.d-check.yml`) ausgenommen; das Targets-Modul misst Makefile/`d-check.mk`/`AGENTS.md`/`harness/README.md`, nicht `harness/tools/smoke.sh`; `make docs-check` grün (0 Befund) |
| Ruhe-Marker (`docs/plan/planning/in-progress/roadmap.md`, Nachzug-Zug) | geprüft, ohne Befund — Marker entfernt, genau dann wenn `in-progress/` einen Slice trägt; Form wie beim Nachzug des c3-Zugs (Form c75c82ef) |
| Dogfood-Nicht-Anlage (`harness/sensors/environment-check.md` im Dogfood-Baum, `harness/README.md` §Sensors) | geprüft, ohne Befund — der Range-Diff berührt die Datei nicht; der Plan-Weche (kein Skript → keine Index-Zeile → kein behauptetes Gate, LH-QA-01) bleibt durch den Zug unangetastet |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 0 |
| LOW | 0 |
| INFO | 1 |

**Finding-Klassen dieses Laufs:** „Rot-Beleg einer neuen Smoke-Messtelle nur
hinter der ersten von zwei Prüfungen"

## Verdikt

**Merge-blockierend:** nein — nur ein INFO-Finding ohne Blockwirkung; die
Übergaben des Planes (Messtelle, Nicht-Kopie-Weche, Gate-Neutralität,
Dogfood-Ablage) tragen die geprüften Formen.

**Übergabe:** F-1 geht an den Verifier (Rot-Nachtrag der zweiten Messtelle
gehört in dessen Prüf-Menge oder in die Grenz-Zeile der Closure-Notiz, falls
der Nachzug unvernünftig teuer bleibt); die Finding-Klasse geht zusätzlich in
die Slice-Closure §7 und von dort in den Zähler. Dieser Report selbst ist ein
Lauf-Beleg — er wird über Läufe hinweg nicht wieder gelesen und muss es nicht;
DoD-/Spec-Konformität prüft die Verifikation separat (Modul 11).
