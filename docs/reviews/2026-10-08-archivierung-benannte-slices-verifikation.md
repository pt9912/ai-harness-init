# Verifikation: slice-archivierung-erkennt-benannte-slices — 2026-10-08

**Rolle:** Verifier (Modul 11) · **Gegenstand:** `fcc02cfd`, `cf6d2b78`, `759ed949` gegen Plan
§1–§3 und DoD §2 (Slice-Plan per Kennung, er wandert — [`AGENTS.md`](../../AGENTS.md) §3.11),
[`ADR-0033`](../plan/adr/0033-wellen-archivierung-als-unterkommando.md),
[`ADR-0041`](../plan/adr/0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md),
[`MR-057`](../../harness/conventions.md#mr-057) · **Eingang:** Review-Report
`2026-10-08-archivierung-benannte-slices-review.md` (Runde 1), Commit-Messages; DoD-Häkchen stehen
noch leer.

**Messort:** zwei Träger aus `make host-bin` (Docker-only) — **alt** am Stand `fcc02cfd~1`
(`internal/archive` zurückgesetzt, danach wiederhergestellt, Baum sauber), **neu** am Stand
`759ed949`; Lauf am realen Baum und in einer Scratch-Fixture (eigenes `git init`, kein Worktree).

## Verdikte je DoD-Punkt

- **(1) `SliceNummer`/`ReviewTrifft` tragen die benannte Form — bestätigt, mit benannter Grenze.**
  Die DoD verlangt die **Eigenschaft** „keine Fehlzuordnung bei Präfix-Namen“ und nennt als Mittel
  „Wortgrenze wie bei der Nummer“. Umgesetzt ist Wortgrenze (`reviewTraegt`, unverändert wie bei der
  Nummer) **plus** „längste Lifecycle-Kennung gewinnt“. Die Wortgrenze allein hielte die Eigenschaft
  nicht (`slice-foo-r2` und `slice-foo-bar` sind hinter `slice-foo` gleich geformt); die Umsetzung
  hält sie, soweit der längere Slice als Datei im Lifecycle liegt. Fixture (`done/slice-foo.md`
  wellenlos; Reports `slice-foo`, `slice-foo-r2`, `slice-foo-bar` ×2, `slice-foobar`):
  - `slice-foo-bar` und `slice-foobar` in `open/` → Vorschau alt `Review-Reports 0`, neu `2`;
    schreibender Lauf `archive-welle altbestand` (neu) → `archiv.zip` enthält genau
    `2026-01-01-slice-foo-review.md`, `2026-01-02-slice-foo-r2-review.md`; die drei fremden bleiben
    in `docs/reviews/`. Stub-Kopf `# slice-foo — Titel foo`.
  - `slice-foo-bar` **nicht** im Lifecycle → neu `4`: `slice-foo` zieht die zwei `foo-bar`-Reports
    mit. Das ist die in `collect.go` (GRENZE) und `harness/sensors/archive-welle.md` Punkt 5 benannte
    Grenze, keine Abweichung von der Zusage dort; die DoD-Zeile selbst nennt sie nicht.
  - Nummernform unverändert: 325 − 155 benannte = 170 = alter Stand (unten).
- **(2) Stub und Titel tragen die Kennung — bestätigt.** Fixture-Stub `# slice-foo — Titel foo`;
  `TitelVon` streift `slice-<name>` samt Trenner. Die Grenze ohne Trenner (`759ed949`) ist benannt
  und jetzt rot gesehen (unten).
- **(3) Rot gesehen — bestätigt.**
  - Reale Quelle, `archive-welle --vorschau altbestand` am realen Baum: alt `Review-Reports (ohne
    Stub): 170`, neu `325`; übrige Zeilen gleich (`wellenlos 198`, `fremd 107`, Verweise 289
    Dateien). Beide EXIT 3 (bekannte Verweis-Sperre, kein Befund dieses Slice).
  - Shell-Nachrechnung der 155 Zusatz-Reports (Wortgrenze + längster Name über 157
    Lifecycle-Namen, 114 benannte wellenlose `done/`-Slices) → 155, gleich der Differenz.
    Suffix-Verteilung hinter der Kennung (nach Abzug `-rN`/`-runde-N`): leer 106, `-verify` 22,
    `-verifikation` 10, `-review`/`-nachpruefung`/`-freshness` je 3, Rest Rollen-/Runden-Wörter —
    kein fremder Slice-Name. Stichprobe 8 von 155 (`shuf`, fester Seed) gelesen: jede trägt die
    Kennung ihres Slice vollständig (z. B. `…-slice-stilllegungs-form-hat-einen-waechter-runde-4.md`,
    `…-slice-das-werkzeug-sagt-seine-fassung-verify.md`).
  - Mutations-Fälle 583–585 (`make mutate`, 3 ok) und Gegenprobe hat der Review gefahren; nicht
    nachgefahren.
  - **Die drei Grenz-Fälle aus `759ed949`** (`TestTitelVonLaesstDenNummernRestStehen`) — nachgetragen:
    Mutation A `kennungRE` ohne `-`-Trenner (`(?::|—)`) → `make test-go` EXIT 2, rot u. a. mit
    `TitelVon("# slice-foo-bar Der Titel") = "slice-foo-bar Der Titel", want "bar Der Titel"` und
    `…slice-190-2… want "2 Der Titel"`. Mutation B Trenner optional (`(?::|—|-)?`) → EXIT 2, rot mit
    `TitelVon("# slice-190 Der Titel") = "Der Titel", want "slice-190 Der Titel"` (plus die zwei
    anderen). Alle drei Fälle sind damit rot gesehen, aus der behaupteten Ursache. Baum danach
    `git checkout`, sauber.
- **`make gates` grün — nicht selbst gefahren.** Dieser Lauf ändert nur diesen Bericht (Auftrag);
  Gate-Beleg steht beim Implementer/CI auf `759ed949`.
- **Review durchgeführt — bestätigt** (Report liegt, LOW-1/INFO-1 in `759ed949` adressiert).
- **Doku-Update `harness/sensors/archive-welle.md` — bestätigt** (Punkt 5 nennt Zuordnung über den
  Dateinamen und die Lifecycle-Bedingung).
- **Closure-Punkte (Notiz, Register, Risiko-Ausgänge, Paarungen)** — Planner-Arbeit, offen.

## Plan-vs-Code

- **Plan → Code:** jede Zeile aus §3 hat ihren Code; `anwenden.go` blieb unberührt — `sliceStub`
  liest die Kennung über `SliceNummer`, Fixture-Stub belegt die Wirkung.
- **Code → Plan:** `lifecycleKennungen` steht in §3, aber vom Implementer in `fcc02cfd`
  nachgetragen. DoD (1) blieb unverändert ([`AGENTS.md`](../../AGENTS.md) §3.10 nicht berührt).
- Negativbefund: kein weiteres Gebautes ohne Plan; der Rest von `stub.go` in `759ed949` ist
  Kommentar, keine Verhaltensänderung.

## Offene Punkte für den Planner

- **Risiko (2)** nennt als Gegenmittel noch „die Wortgrenze aus DoD 1“; getragen wird es von der
  Lifecycle-Vergleichsmenge, und es bleibt offen für einen Präfix-Slice ohne Datei im Lifecycle
  (Fixture-Fall oben). Beim Ausgang berücksichtigen.
- **§1** nennt 80 benannte wellenlose Slices; gemessen jetzt 114 (Zahl wandert, kein Erwartungswert).
- **Kein Mutations-Fall** bindet die drei Grenz-Fälle aus `759ed949`; rot gesehen ist er einmal
  (oben), gehalten wird er nicht von `make mutate`.
