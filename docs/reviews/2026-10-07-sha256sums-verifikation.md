# Verifikation: slice-full-smoke-faehrt-den-adopter-pfad-ueber-sha256sums

**Datum:** 2026-10-07 · **Rolle:** Verifier (Modul 11) · **Gegenstand:** `edad1d00`, `ceb77d3d`, `96db3cc1`
gegen den Slice-Plan (Stand `48a91848`), [ADR-0059](../plan/adr/0059-sha256sums-reisen-als-release-asset-der-emit-pin-traegt-nur-den-tag.md)
Festlegung 1 und 3, [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit), [`AGENTS.md`](../../AGENTS.md) §3.6/§3.7.
Grundlage ist auch der [Review](2026-10-07-sha256sums-review.md). Seine Rot-Belege (556, 557, Gegenprobe zu 556,
404-Sonde) übernehme ich als vollständig gelesen und wiederhole sie nicht.

## Verdikte je Liefer-Punkt

- **LP1 Adopter-Kanal: bestätigt.** `klon_traeger_fetch` entfernt die sechs `TRAEGER_SHA256_*`. Abgeglichen mit
  `Makefile:46-53`, wo diese sechs neben `TRAEGER_TAG` und `TRAEGER_CARRIER` exportiert werden. Das Fragment
  `internal/emit/templates/enforce/traeger.mk:28` exportiert keinen Digest, also fällt das Payload mit leerem
  `TRAEGER_SHA256` in den Manifest-Zweig (`traeger-fetch.sh:124-133`). Das `expect:` von 556 entspricht der
  FEHLER-Zeile `full-smoke.sh:1949`. Rot-Beleg und Gegenprobe hat der Review gefahren.
- **LP2 Fall (c) über den Pin-Kanal: bestätigt.** (c) ruft `klon_traeger_fetch "$klon" "$ts_pin_var=$verdreht"`
  auf. `env -u` entfernt alle sechs Pins, und die Kommandozeilen-Zuweisung setzt nur den Pin der Host-Plattform.
  Die neue Prüfung verlangt `aus Pin`, und das Payload schreibt `(aus $quelle)`. Den Rot-Beleg (557) hat der Review gefahren.
- **LP3 Sicht und Kopf-Sätze: bestätigt.** Deklaration, `GRENZE` und der OK-Satz der Stufe nennen beide Kanäle
  sowie die Grenze, dass eine Abweichung nur im Pin-Kanal messbar ist. `docs/user/e2e-abdeckung.md` wurde
  neu erzeugt. Ihre Byte-Gleichheit hält `test/e2e-abdeckung.bats` in `make gates`. Die Kopfkommentare von
  553, 554, 556 und 557 nennen die Grenze ohne Zahl, wie die Plan-Korrektur verlangt (HIGH-1 behoben).
- **`make gates` grün: bestätigt**, gelaufen nach dem Commit dieses Berichts (siehe Übergabe).

## Pflichtlauf `make full-smoke`

`make full-smoke`: EXIT 0, 420 s. Die Zeilen von Stufe 5:

```text
full-smoke: Fetch im frischen Klon (golang): make traeger-fetch legt den Traeger aus dem gepinnten Release ab, ausfuehrbar, Digest vor der Ablage verifiziert — ohne Digest-Pin, gegen die SHA256SUMS des Release.
full-smoke: ohne den Traeger zu legen (golang): der verdrehte sha256-Pin der Host-Plattform schlaegt das Manifest, bricht den Fetch nach EINMAL Laden laut, nennt die Digest-Abweichung aus Pin, und der liegende Traeger bleibt unangetastet.
```

- (c): Die Zeile „aus Pin" ist durch die Prüfung auf `aus Pin` in der Skript-Ausgabe gedeckt.
- (b): Die Zeile behauptet den Manifest-Kanal, die Stufe misst ihn aber nicht an der Ausgabe. Das ist INFO-1
  des Reviews und steht als Risiko in §6. Getragen ist die Aussage durch 556 unter `make mutate`, nicht durch
  `make gates`. Das bestätige ich als Grenze, nicht als Befund.

## Plan gegen Code

- **Plan → Code:** Alle Zeilen aus §3 sind umgesetzt (full-smoke.sh, 2 Fälle neu, 553/554 geändert,
  e2e-abdeckung erzeugt).
- **Code → Plan:** `git diff edad1d00~1 96db3cc1 --stat -- internal/` ist leer. Produkt-Code, emittiertes Skript
  und Fragment sind also unverändert, wie §3 zusagt. Der geänderte OK-Satz am Ende von full-smoke.sh gehört zur
  Stufe und ist kein ungeplanter Bau.

## Offen für den Planner

- Die zwei Risiken aus §6 (`TRAEGER_CARRIER` wird weiter geerbt; Kanal-Grenze von (b)) brauchen bei der Closure je einen Ausgang.
