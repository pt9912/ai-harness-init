# Verifikation — slice-d-check-pin-bringt-den-go-sicherheitsfix (d-check v0.86.1)

**Rolle:** Verifier (Modul 11), frischer Kontext. **Datum:** 2026-10-10.
**Gegenstand:** Slice-Plan in `in-progress/`, Stand `43091527` (Ziel v0.86.1); verifizierter
Code-Stand `4abafc4f`, Baum `cc5663a8`. Commits `144a2ad5`, `f652d6fb`, `724b63ff`, `53107f53`,
`4abafc4f`; Architect `eb6f1f1b` (MR-092); Reviews `4520ab1e`, `a79d72a9`, `cc5663a8`.
**Maßstab:** DoD §2, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`MR-063`](../../harness/conventions.md#mr-063), [`MR-089`](../../harness/conventions.md#mr-089).

**Urteil: Liefer-Punkte 1–3, Gate-Punkt und Review/Doku-Update bestätigt.** Offen sind allein die
Closure-Punkte des Planners und eine Plan-Lücke (README-Zeile ohne Plan-Zeile, unten).

## Mutations-Ergebnis vom CI-Branch

- `git fetch origin mutate/slice-d-check-pin-bringt-den-go-sicherheitsfix-4abafc4f && git show FETCH_HEAD:mutate-ergebnis.txt`
  → `gepruefter Commit: 4abafc4fd3ff364233ab9815650013309e223722` = verifizierter Commit;
  Basis `327cb33c`. Zehn Shards, je `Exit 0`; `Fallmenge: 46 (Slice: 46)`; alle 46 `ok`, darunter
  die neuen Fälle `666-emittierter-reviews-kommentar-nennt-alten-pin` und
  `667-emittierter-reviews-block-verliert-match-name`; Wanduhr 1051 s; `Urteil: gruen`.
- Gelöscht: `mutate/slice-d-check-pin-bringt-den-go-sicherheitsfix-4abafc4f` und
  `mutate/slice-d-check-pin-bringt-den-go-sicherheitsfix-f652d6fb`
  (`git push origin --delete …` → zweimal `[deleted]`). Danach
  `git ls-remote origin 'refs/heads/mutate/*'` → leer, Exit 0.

## Verdikte je DoD-Punkt

- **1 — d-check v0.86.1 an beiden Stellen: bestätigt.**
  `git diff 43091527 4abafc4f -- d-check.mk internal/emit/emit.go` → `DCHECK_IMAGE`/`DefaultImage`
  `ghcr.io/pt9912/d-check:v0.86.1`, `DCHECK_DIGEST`/`DefaultDigest`
  `sha256:3e0b9779a71e2fa942960e8b961428fba036455c535513d34a75bfb799ffce0e`.
  `docker buildx imagetools inspect ghcr.io/pt9912/d-check@sha256:3e0b9779…` → MediaType
  `application/vnd.oci.image.index.v1+json`, Manifeste linux/amd64 `1d3b0a2b…` und linux/arm64
  `01e31f8f…` — der Pin ist der Index-Digest. Mess-Kommando steht im Commit `4abafc4f`.
  **Rot-Beleg nachgefahren** an der realen Quelle: `git archive HEAD` in eine Kopie, dort
  `internal/emit/emit.go` auf `v0.84.0`/`sha256:e82ef2d2…` zurückgesetzt, `make test-go` → EXIT 2
  mit `TestDefaultDigest_MatchesCanonical` („… != kanonische Pin-Quelle "sha256:3e0b9779…" (Drift)“),
  `TestDefaultImage_MatchesCanonical` („… (Tag-Drift)“) und zusätzlich
  `TestDCheckConfig_ReviewsBleibtKommentarBlock` (Prosa nennt nicht den Pin aus `DefaultImage`).
  Die Meldung nennt die behauptete Ursache.
- **2 — Strenge-Bilanz v0.84.0 → v0.86.1: bestätigt (Stichprobe Stufen 1 und 2, Stufen 3–5 vom
  Implementer übernommen; der Reviewer hat sie in `cc5663a8` nachgeprüft).** In einer
  `git archive HEAD`-Kopie `$K`, `make -s -C "$K" docs-check DCHECK_DIGEST=<OLD|NEW>`:
  Stufe 1 → beide EXIT 0, `2662 Datei(en) geprüft, 0 Befund(e)`. Stufe 2
  (`sed 's/d-check:ignore/d-check:IGNORIERT-NICHT/g'` über `*.md -type f` außer
  `.harness/baseline/`; `find $K/.claude/rules -type l | wc -l` → 10) → beide EXIT 2, 97
  Befundzeilen, `60 codepath-missing`, `37 id-unlinked`; `diff` der sortierten Befundzeilen leer.
  Die Dateizahl liegt über den 2659 des Commits, weil der Baum seither gewachsen ist; der Vergleich
  läuft über denselben Baum. Dass `reviews` kein aktives Modul trifft, steht im Commit mit
  `grep -m1 '^modules:' .d-check.yml | grep -c reviews` → 0.
- **3 — Sicherheitsgrund am Image: bestätigt, arm64 selbst gemessen.**
  `docker create --platform linux/arm64 ghcr.io/pt9912/d-check@sha256:01e31f8f…` + `docker cp /d-check`,
  dann `docker run --rm --network none -v …:/x:ro golang@sha256:e0174e51… go version -m /x/d-check-arm64`
  → `go1.27.2`, `dep golang.org/x/net v0.60.0`, `build GOARCH=arm64`. amd64 hat der Reviewer gemessen.
- **`make gates` grün; `make full-smoke` EXIT 0: bestätigt.**
  `make full-smoke` → `EXIT=0`, Wanduhr **316 s**, 38 `OK —`-Zeilen; im Log läuft der d-check
  des Ziels als `d-check@sha256:3e0b9779…` (11 Aufrufe) — der emittierte Pin im Ziel. Lage nach
  MR-089: d-check-v0.86.1-Image lokal vorhanden (vor dem Lauf gezogen, `docker image ls --digests`),
  Build-Cache warm, kein Pull im Log (`grep -ciE 'pulling|Pull complete|Downloaded newer'` → 0);
  Varianten: Bootstrap `--lang go`, Handbuch-Baum sprachlos, `--lang go` und `--lang cpp`.
  Kalter Lauf ist *ungemessen*. `make gates`: am Ende dieses Laufs grün, vor dem Commit.
- **Review durchgeführt: bestätigt.** `docs/reviews/2026-10-09-slice-d-check-pin-bringt-den-go-sicherheitsfix.md`
  (`4520ab1e`, MEDIUM-1 behoben in `724b63ff`), Nachprüfung (`a79d72a9`), Nachprüfung 2
  (`cc5663a8`): freigegeben, 0 HIGH · 0 MEDIUM · 0 LOW · 3 INFO.
- **Doku-Update (Architect-Übergabe): bestätigt.** `eb6f1f1b` berührt allein
  `harness/conventions.md` und `harness/conventions/MR-092-…` (`git show --stat`), Rolle Architect in
  der Message. MR-092 trägt Index-Digest, Go-Fassung beider Plattformen, Bilanz, und nennt den
  MR-086-Trigger: „gilt unverändert … Sein Auflösungs-Trigger tritt“ an v0.86.1 nicht ein.
- **Closure-Notiz, Register, Risiko-Ausgänge, Paarungen: offen** — Planner-Arbeit
  (AGENTS.md §3.10), nicht Gegenstand dieser Verifikation. Reconciliation-Register: entfällt laut Plan.

## Plan gegen Code

- **Gebaut ohne Plan-Zeile:** `harness/README.md` (Zeile `doc-trace`/`doc-complete`, `f652d6fb`).
  Die Commit-Message sagt „der Planner traegt sie in §3 nach“; im Plan-Stand `43091527` steht sie
  in §3 nicht (`grep -n 'doc-complete\|doc-trace'` auf die Plan-Datei → kein Treffer). Die Zusage der
  Zeile ist belegt: `f652d6fb` misst `make doc-complete` EXIT 2 bei einer Waise, `d-check
  --require-complete` EXIT 1, am unveränderten Baum beide 0. **Für die Closure:** Planner trägt die
  Zeile in §3 nach oder vermerkt sie in §7 als Übergabe aus der vorigen Closure.
- `internal/emit/templates/d-check.yml`, `internal/emit/emit_test.go`, `test/mutations/666-…`,
  `667-…`: durch §3 gedeckt (die Zeilen legte `724b63ff` an, der Planner hat sie in `43091527`
  übernommen).
- Planzeilen ohne Code: keine. Die §1-Ausschlüsse (a-check-Pin, Opt-ins, `reviews`-Aktivierung)
  halten: `git diff 327cb33c HEAD --stat` berührt weder a-check-Pins noch `.d-check.yml`.

## Offen für Planner und Architect

- §6 Risiko *Mutate-Weg offen*: der CI-Weg hat das Ergebnis geliefert (46/46 grün, oben), damit ist
  ein Ausgang belegbar.
- §6 *Digest ohne Wächter* und *a-check mit Go 1.27.0*: unverändert offen, kein Befund dieser
  Verifikation.
- INFO-1 bis INFO-3 der Nachprüfung 2 bleiben offen; keines berührt eine DoD-Aussage.

**Negativbefunde:** kein Pin außerhalb der zwei gekoppelten Stellen geändert; keine Abweichung der
Befundzahlen zwischen alt und neu in der Stichprobe; keine Mutations-Lücke im CI-Lauf.
