**Vorgang:** slice-ziel-traegt-keine-kennung-dieses-repos
**Fund:** Die emittierte `.d-check.yml` ist skip-if-present; Ziele, die mit `v0.1.0` bis `v0.5.0` gebootstrappt wurden, behalten darin Kennungen von ai-harness-init, und ein Re-Lauf erreicht sie nicht (Risiko R4 des Slice). Der Beleg des Slice misst an zwei frischen Bootstraps.
