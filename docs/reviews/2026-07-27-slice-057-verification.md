# Verifier-Report slice-057 — Kompilat-Cache teilen, Test-Ergebnisse nicht

Rolle: **Verifier (Modul 11)**. Prüfgegenstand ist die **DoD-Behauptung**. Bei diesem Slice ist die
schärfste Frage nicht „ist es schneller", sondern: **läuft noch, was gemeldet wird?**

**Datum:** 2026-07-27. **Slice:** `docs/plan/planning/in-progress/slice-057-go-kompilat-cache.md`.

**Grenze:** kein frischer Kontext (Modul 8); kompensiert durch Kommandos. Alle Läufe allein auf dem
Docker-Daemon, `make gates` vorher grün — dieselben Bedingungen wie in slice-056.

## Was ich selbst erhoben habe

| DoD-Punkt | Kommando / Beleg | Ergebnis |
|---|---|---|
| (1) Übersetzung geteilt | `make test-go` dreimal | 9,8 s (Vorwärmen) → **3,1 s** → **3,1 s**; Baseline war 7,6 / 7,2 s |
| (1) Ergebnisse **nicht** geteilt | `(cached)`-Vorkommen im Testlauf | **0** in allen drei Läufen |
| (2) `-count=1` bewacht | Mutation **98** entfernt es | **rot gesehen** — `dockerfile: die test-Stufe erzwingt die Test-Ausfuehrung (-count=1)` fällt |
| (2) Wächter existieren | `make test` | zwei neue bats-Fälle grün (`-count=1` vorhanden; Vorwärm-Stufe vorhanden und vererbt) |
| (3) Vorher/Nachher | `time make mutate` | **10m54s → 7m18s** bei **94 ok / 0 Befunden** |
| Aussage unverändert | Fall-Liste des Laufs | einziger neuer Fall ist 98; alle übrigen färben denselben Wächter |
| Gates | `make gates` | Exit 0 — d-check grün, `comment-claims` 31/0, 0 `not ok` |

## DoD-Stand

**Bestätigt:** (1), (2), (3) sowie `make gates` und `make mutate`. **Offen:** Doku-Update und
Closure-Notiz — beides Teil des Abschlusses.

**Eine Abweichung, die der Verifier ausdrücklich festhält:** die DoD-Punkte (1) und (2) nennen als
Mittel den **Cache-Mount**. Geliefert ist eine **Vorwärm-Stufe**. Abgenommen wird gegen die
**Eigenschaft**, die beide Punkte beschreiben — *Übersetzung geteilt, Ergebnisse nicht* —, und die
ist belegt. Das Mittel wurde gewechselt, weil die Messreihe das geplante ausschloss; der Wechsel
kam aus einem Nutzer-Vorschlag, nicht aus einer stillen Umdeutung. Dieselbe Klasse wie in slice-053
(„byte-identisch") und slice-056 („weiterhin 92 ok"): **der Plan-Text ist älter als das Wissen.**
Er gehört nachgezogen, nicht umgedeutet.

## Zur Belastbarkeit der Messung

- Die Vorher-Zahl (**10m54s**) stammt aus slice-056 und wurde unter denselben Bedingungen erhoben.
- Der Nachher-Lauf trägt **einen Fall mehr** (94 statt 93) — der Vergleich ist also konservativ.
- Der Gewinn ist **nicht** durch übersprungene Arbeit erkauft: `(cached)` kommt nicht vor, und der
  Mutations-Lauf meldet unverändert jeden Wächter als rot gefärbt.

Über beide Laufzeit-Slices: **19m01s → 10m54s → 7m18s** (−62 %), bei 92 → 94 Fällen.

## Verdikt

**DoD bestätigt (alle prüfbaren Punkte).** Keine Rückkante zur Implementation. Der Sensor ist
erneut schneller geworden, ohne blinder zu werden — und die einzige neu entstandene Angriffsfläche
(`-count=1`) hat ihren Wächter im selben Zug bekommen.
