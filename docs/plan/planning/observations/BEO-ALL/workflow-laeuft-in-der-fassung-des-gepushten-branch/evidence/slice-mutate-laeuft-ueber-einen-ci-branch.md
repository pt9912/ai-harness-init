**Vorgang:** slice-mutate-laeuft-ueber-einen-ci-branch
**Fund:** `mutate-branch.yml` schreibt das Ergebnis mit `contents: write`; `main` ist ungeschützt (öffentliche API: `"protected": false`), die Grenze nennt [`MR-091`](../../../../../../../harness/conventions.md#mr-091) §Grenze (Risiko 1 des Slice, Ausgang *weiter offen*).
