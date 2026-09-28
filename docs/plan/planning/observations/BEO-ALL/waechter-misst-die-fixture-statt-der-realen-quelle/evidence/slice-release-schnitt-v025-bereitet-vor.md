**Vorgang:** slice-release-schnitt-v025-bereitet-vor
**Fund:** Der Kopplungs- und die Dogfood-Fälle in `test/traeger-fetch.bats` prüfen die
DoD-behauptete Eigenschaft „ein falscher Digest-Pin im `Makefile` bricht den Test" nicht gegen den
realen Pin-Wert. Der Fall „pin-kopplung" (Zeile 116–130) prüft für jeden der sechs
`TRAEGER_SHA256_*`-Werte nur *Präsenz* und *Länge* (`[ -n "$mk" ]`, `[ "${#mk}" -eq 64 ]`), nie den
Wert selbst. Die Dogfood-Happy-/Negative-Fälle (Zeilen 163ff.) injizieren ihren eigenen
synthetischen Digest per `env TRAEGER_SHA256_LINUX_AMD64=…` direkt an das Skript — der reale
`Makefile`-Wert wird dabei überschrieben, nie gelesen. Verifier-Gegenprobe (Modul 11 „Bewusstes
Brechen"): ein testweise verfälschter realer `Makefile`-Pin-Wert lief unter allen zehn bats-Fällen
grün durch — ein Tippfehler im tatsächlichen Release-Pin liefe unentdeckt durch `make gates`. Die
Skript-Logik selbst ist tragfähig (fail-closed bei irgendeiner Digest-Abweichung, generisch geprüft
und vom Verifier eigenständig per `sha256sum` gegen `dist/SHA256SUMS` bestätigt) — die Lücke ist,
dass kein Lauf in `make gates` den *realen* Pin-Wert gegen eine unabhängige Quelle hält. Eingetragen
als Verifier-Finding V-1 (MEDIUM, kein Blocker) dieses Slice.
