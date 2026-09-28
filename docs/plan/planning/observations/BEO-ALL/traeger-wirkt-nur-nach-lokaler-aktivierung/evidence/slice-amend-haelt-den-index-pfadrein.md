**Vorgang:** slice-amend-haelt-den-index-pfadrein

**Fund:** Der neue `.githooks/pre-commit`-Träger gegen `--amend` wirkt nur in einem Klon, der
`make hooks-install` gefahren hat, und wird von `--no-verify` umgangen (Risiko 1, Slice-Plan §6) —
dieselbe, am `commit-msg`-Träger bereits akzeptierte Grenze, jetzt am zweiten git-eigenen Hook
strukturell bestätigt statt neu entstanden.
