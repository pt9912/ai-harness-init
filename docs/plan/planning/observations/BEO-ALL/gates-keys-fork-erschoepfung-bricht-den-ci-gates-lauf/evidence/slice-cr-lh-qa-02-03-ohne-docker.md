**Vorgang:** slice-cr-lh-qa-02-03-ohne-docker
**Fund:** CI-Lauf 45944570095 (gates-Job 140326215480, Commit-Stand des
Slice-Handoff): `fork: retry: Resource temporarily unavailable` 6× in
`harness/tools/gates-keys.sh`, danach `make: *** [Makefile:743: gates]
Terminated` — dieselbe Signatur wie im vorgefundenen Lauf 45939443193. Die
Ausnahme trägt der Carveout CO-007 (Trigger: Abschluss von welle-ohne-docker);
der Befund trägt gegen `slice-gates-pruefgegenstand-stempel-v1`.
