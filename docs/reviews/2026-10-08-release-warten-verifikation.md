# Verifikation: `make release-warten` vor `make full-smoke` im `ci`-Job

**Rolle:** Verifier (Modul 11). **Datum:** 2026-10-08.
**Gegenstand:** `slice-ci-wartet-die-publikation-des-gepinnten-releases-ab`, Arbeit `37cd8662`,
`ae01d305`, `06f14fcf`; Review `docs/reviews/2026-10-08-release-warten-review.md`.
**Bezug:** [ADR-0058](../plan/adr/0058-traeger-per-fetch-aus-dem-gepinnten-release.md),
[`MR-014`](../../harness/conventions.md#mr-014--ci-auf-frischem-klon-github-actions),
[`AGENTS.md`](../../AGENTS.md) §3.6.

## Verdikte je Liefer-DoD-Punkt

- **2 — Umsetzung: bedingt.**
  - Skript, Target, `shell-lint`-Eintrag, `ci.yml`-Schritt vor `make full-smoke`, README-Zeile mit
    `kein Gate`, Transport im Bild von `traeger-fetch` (Pin dort gelesen), Grenze per Variable:
    im Code vorhanden — bestätigt.
  - Gepinnter Tag, real: `make release-warten` →
    `release-warten: Release v0.5.0 fuehrt SHA256SUMS und ai-harness-init-linux-amd64 — abrufbar beim Versuch 1 nach 1s.`,
    Exit 0, 1,1 s — bestätigt.
  - Nie veröffentlichter Tag, real:
    `TRAEGER_TAG=v0.0.0-nie-veroeffentlicht TRAEGER_WARTEN_GRENZE=20 TRAEGER_WARTEN_INTERVALL=5 make release-warten` →
    `… GRENZE ERREICHT — … nach 21s und 5 Versuch(en) nicht abrufbar (Grenze 20s); letzter Versuch: Exit 22, stderr: curl: (22) The requested URL returned error: 404; …`,
    Exit 0, 20,3 s. Die Ursache steht in der Zeile — bestätigt.
  - Die zweite Hälfte des Rot-Belegs (`make full-smoke` danach mit `AUSGANG LEITUNG`) wurde
    auftragsgemäß nicht gefahren; sie hängt am Einordner aus
    `slice-full-smoke-erkennt-unveroeffentlichtes-artefakt` und ist von diesem Lauf **nicht belegt**.
  - **Nicht bestätigt:** „Ohne die README-Zeile ist `make docs-check` (Modul `targets`) rot."
    README-Zeile entfernt → `make docs-check` Exit 0, `2448 Datei(en) geprüft, 0 Befund(e)`. Grund:
    `release-warten` steht zusätzlich in `targets.exempt-targets` (`.d-check.yml:214`). Rot wird es
    erst, wenn **beide** fehlen: Exit 2,
    `Makefile:551 release-warten gate-undocumented …`. Die Zusage ist breiter als ihr Sensor
    ([`AGENTS.md`](../../AGENTS.md) §3.6). Baum danach per `git checkout` zurückgesetzt.
- **3 — Doku: bestätigt.** `docs/user/releasing.md` Schritt 6 nennt Warte-Schritt, Grenze,
  Versuchs-Budget, Grenz-Zeile mit Ursache und den Re-Run nur bei überschrittener Grenze; deckt sich
  mit dem Skript. Kein Sensor, wie der DoD sagt.

## Review-Behebungen (Stichprobe, real)

- **F-1 Zeitlimit je Versuch:** zwei echte Hänger gefahren.
  - Nicht antwortender Host (Kopie des Skripts im Scratchpad, Basis `https://10.255.255.1/…`),
    Grenze 12 s: `… nach 12s und 1 Versuch(en) … Exit 124, stderr: curl: (28) Connection timed out after 12002 milliseconds`,
    Exit 0, 12,5 s.
  - Hängender Bild-Pull (Original-Skript, `TRAEGER_IMAGE=10.255.255.1:5000/x@sha256:0…`), Grenze 8 s:
    `… Exit 124, stderr: Unable to find image …`, Exit 0, 8,0 s; kein zurückgelassener Container.
  - Beide enden innerhalb der zugesagten 7 s nach der Grenze. Bestätigt.
- **F-2/F-4:** bats-Fälle für Exit 2 (Grenze, Intervall, Bild ohne Digest) und die Ursache in der
  Grenz-Zeile liegen in `test/release-warten.bats`; nicht eigens gebrochen.
- **F-3, Mutationsfall 563:** `MUTATE_CASES=563-release-warten-urteilt-an-der-grenze make mutate` →
  `ok … -> nach der Grenze Exit 0 mit der Grenz-Zeile rot`, `1 ok, 0 Befund(e)`, Exit 0. Rot wird
  der benannte Fall. (`MUTATE_CASES=563` allein bricht ab: der Name ist der volle Dateistamm.)

## `timeout-minutes: 45` gegen gemessene Dauern

- `gh run list --workflow ci.yml --limit 15` und `gh run view <id> --json jobs` (Job `full-smoke`,
  `completedAt − startedAt`): erfolgreiche Läufe am 2026-10-07 zwischen **233 s und 949 s**
  (Maximum Lauf `37671065316`).
- 900 s Warten + 949 s + 7 s Nachlauf ≈ 31 min; 45 min lassen rund 14 min Puffer — **plausibel**.
- **Befund (Zusage):** der `ci.yml`-Kommentar sagt, `full-smoke` lief am 2026-10-07 „4 bis 9
  Minuten". Gemessen sind es bis 15,8 Minuten an demselben Tag. Die Begründung des Werts stimmt
  damit nicht. Der Wert selbst trägt trotzdem.

## Plan gegen Code

- Plan → Code: alle vier Zeilen aus §3 sind umgesetzt.
- Code → Plan: gebaut, ohne dass §3 es nennt: `.d-check.yml` (`exempt-targets`),
  `test/release-warten.bats`, `test/mutations/563-…`, `ci.yml` `timeout-minutes` (folgt aus F-1).
  Alles folgt aus dem Gegenstand. Allein der `exempt-targets`-Eintrag verschiebt eine Zusage, siehe
  den nicht bestätigten Teil von Punkt 2.
- Out-of-Scope eingehalten: `harness/tools/traeger-fetch.sh` und das emittierte Fetch sind nicht
  berührt (`git show --stat` der drei Commits).

## Offen für den Planner

- Closure-Trigger 1, zweite Hälfte („`ci`-Lauf des Umsetzungs-Push, Warte-Schritt beim ersten
  Versuch, Job-ID in §7"): **nicht erfüllbar durch diesen Lauf**. Die Commits sind nicht gepusht;
  der Verifier pusht nicht.
- DoD 2: der Satz zum `docs-check`-Rot ist an der Lage falsch. Entweder den Satz auf „ohne
  README-Zeile **und** `exempt-targets`-Eintrag" einschränken, oder den Eintrag streichen, wenn die
  README-Zeile allein tragen soll. Das ist eine Abnahme-Frage (§3.10), keine Closure-Handlung.
- `AUSGANG LEITUNG` nach der Grenze ist von diesem Lauf nicht nachgemessen.
- Der Kommentar in `ci.yml` nennt eine falsche Dauer (4–9 min statt bis 15,8 min).

## Gate

`make gates` nach dem Commit dieses Berichts — siehe Übergabe an den Planner.
