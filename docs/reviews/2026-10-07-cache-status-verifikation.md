# Verifikation — Cache-Status trägt *nicht bekannt* (slice-span-pflichtfeld-traegt-nicht-bekannt)

**Gegenstand:** `91af2b67`, `9b05aba7`, `b0c73625` gegen den Plan (Schnitt `5b134ea5`, Cache-Status-Hälfte),
Review `docs/reviews/2026-10-07-cache-status-review.md`. **Rolle:** Verifier (Modul 11), frischer Kontext.
**Maßstab:** DoD §2 · `SPEC-024`/`055`/`076`/`077`/`087`/`011`/`012` · `LH-FA-13`, `LH-FA-15` ·
`modul-15-observability.md` am Tag `v6.16.0` (Welle 154) · `ADR-0078` Festlegung 4 · `AGENTS.md` §3.6.

**Summary:** DoD 1 bestätigt · DoD 2 **bedingt** · `make gates` bestätigt · Review bestätigt. 1 offener Punkt
mit Befund (V-1), 1 Rang-Frage an den Architect (V-2).

## Verdikte je DoD-Punkt

- **1 — Spezifikation: bestätigt.** `SPEC-024` `Pflicht`; `SPEC-087` nennt Draht-Form
  `nicht bekannt: <Quelle>` und Quelle `tool_response.usage`, Spalte *Präzisiert* = `LH-FA-13` (`MR-075`);
  `SPEC-055` heißt *Cache-Status (Quelle)*, keine Abweichung mehr; `SPEC-010` unverändert *leer heißt
  unbekannt* (Folge-Slice), `SPEC-011`/`012` ordnen `[]` als Wert ein. Kommando: `git show 91af2b67 b0c73625 -- spec/spezifikation.md`.
  Deckt sich mit `modul-15` Z. 34 (*„nicht `0`, nicht `false` … unter Nennung der Quelle"*) und
  `ADR-0078` Festlegung 4 Punkt 1/3. Vorbehalt V-2.
- **2 — Erfassung, Feldliste, Tests: bedingt.** Verhalten an allen drei Payload-Formen richtig, gemessen
  in einer Kopie (`git archive HEAD`, Sonden-Test, `make test-go`):
  - *usage fehlt* (`Agent` ohne `usage`, `Bash`, Fehlschlag): Kennzeichnung — vom Repo-Test gehalten.
  - *Zähler null*: Kennzeichnung, Lesen `null` → ohne Wert — vom Repo-Test gehalten (M-1 behoben).
  - *Zähler fehlt* (`usage` mit `input_tokens`, ohne Cache-Schlüssel): Kennzeichnung — **nur von meiner
    Sonde** gehalten, siehe V-1.
  - Lesen alter Spans: Zahl `7` → `7`, fehlendes Feld → ohne Wert, String `"kaputt"` → Zeile bleibt lesbar
    (Sonde grün).
  - Feldliste: `SchemaFields` per Reflexion, `TestSchemaFields_PflichtIstDieDrahtform` färbt unter 538
    (`cache_read_input_tokens gilt als Pflicht, fehlt aber …`).
- **`make gates` grün: bestätigt** — Lauf am Ende, Exit unten.
- **Review liegt vor: bestätigt** — `docs/reviews/2026-10-07-cache-status-review.md`; M-1, L-1, L-2 in
  `b0c73625` geschlossen (Rot-Belege unten), L-3 an den Planner.

## Rot-Belege (an der realen Quelle, Meldung gelesen)

```sh
make mutate MUTATE_CASES="536-… 537-… 538-… 539-…"   # 4 ok, 0 Befund(e), EXIT 0
# je Fall in Kopie angewandt + make test-go:
# 536 -> TestCacheStatusIsMarkedNotKnown/{Bash,Agent_ohne_usage,Agent_mit_usage_null}:
#        "\"cache_creation_input_tokens\":0" steht in der Span-Zeile          (Ursache richtig, L-2 behoben)
# 539 -> …/Agent_mit_usage_null: "…":0 steht in der Span-Zeile;
#        notknown_test.go:64: cache_read_input_tokens: null las sich als Wert 0  (M-1-Wächter)
# 538 -> TestCacheStatusIsMarkedNotKnown: "cache_read_input_tokens":"nicht bekannt: …" fehlt;
#        TestSchemaFields_PflichtIstDieDrahtform                                (L-1 behoben, expect stimmt)
```

## Befunde und offene Punkte

- **V-1 — Form *Zähler fehlt* ist unbewacht (`AGENTS.md` §3.6, Zusage breiter als Sensor).** `SPEC-087`
  sagt zu: *„Liefert die Quelle den Wert eines Cache-Zählers nicht"* → Kennzeichnung. Mutation in Kopie:
  `extractAgentResult` setzt beide Cache-Zähler auf `0`, sobald `usage` existiert. Ergebnis: **die
  Repo-Suite bleibt vollständig grün**; rot wird allein die Sonde
  (`"cache_creation_input_tokens":0" steht in der Span-Zeile`, Payload
  `{"usage":{"input_tokens":11,"output_tokens":2}}`). Der Fall `Agent mit usage null` deckt es nicht, weil
  `null` den Vorbelegungswert überschreibt. Heute verhält sich der Code richtig (Nullwert von `CacheCount`).
  Abhilfe: Teilfall *usage ohne Cache-Schlüssel* in `TestCacheStatusIsMarkedNotKnown` plus Mutations-Fall.
  Die DoD-Formulierung (*ohne `usage`* / *mit `usage`*) ist wörtlich erfüllt; die Spec-Zusage nicht belegt.
  → Planner: vor Closure nachziehen oder als Folge benennen.
- **V-2 — `SPEC-011`/`012` gegen `LH-FA-13` (Rang 1).** `LH-FA-13` *Leer heißt unbekannt* liest jeden
  leeren Pflichtwert als *unbekannt*; `SPEC-011`/`012` setzen `[]` als Wert *kein Slice*/*kein Bezug*.
  `LH-FA-13` *Korrelations-Achsen* („ohne Slice … leer und als leer erkennbar") stützt die Einordnung,
  `ADR-0078` Festlegung 4 Punkt 3 verlangt sie. Die zwei Kriterien in Rang 1 sagen nicht dasselbe; dazu
  liefert die Ableitung `[]` auch bei Lesefehler (Review L-3). → Architect: Rang-1-Lesart klären.
- **I — Feldliste/Träger auseinander bis Release** (Plan §6 Risiko 3, Review I-1): unverändert offen.

## Plan-vs-Code

- **Plan → Code:** alle Zeilen aus §3 umgesetzt (spec §5, `response.go`, `notknown.go`, `fieldlist.go`,
  Tests, Mutations-Fälle). `MR-076` steht noch — Architect-Schritt, nicht dieses Laufs.
- **Code → Plan:** nichts ohne Plan; Fall 539 und die `null`-Prüfung gehören zu Liefer-Punkt 2.
- **Emittierte Ebene:** `fieldlist.go`/`internal/emit` seit `9b05aba7` unberührt
  (`git log 9b05aba7..HEAD -- internal/span/fieldlist.go internal/emit` leer) — `make full-smoke` nicht gefahren.

## Negativbefunde

- Konsumenten: kein Leser summiert die Cache-Felder (Review (a), Stichprobe `git grep cache_read_input_tokens`
  außerhalb `internal`: nur ADR/Carveout-Text). `LH-FA-15`/`agent_role` unberührt, wie geschnitten.
- Kurs-Regel Welle 154: Kennzeichnung ist Zeichenkette mit Quelle, nie `0`/abwesend — erfüllt.

## Kommandos

```sh
make mutate MUTATE_CASES="536-span-cache-status-null-statt-kennzeichnung 537-span-cache-status-leer-statt-kennzeichnung 538-span-cache-status-fehlt 539-span-cache-zaehler-null-wird-null"
# Kopie: git archive HEAD | tar -x; Sonde internal/span/zz_verify_probe_test.go; make test-go
make gates   # EXIT 0
```
