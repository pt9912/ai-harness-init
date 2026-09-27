**Vorgang:** slice-fall-406-trifft-die-umgebaute-zerlegung
**Fund:** Der reparierte Mutations-Fall 406 (`# expect:` nennt
`TestCommandProgramNeverEmitsAssignmentValueFragments`) färbt unter Mutation zusätzlich
`TestCommandProgramNamesAProgramNotAnOperator` rot: Gegenprobe mit ausgeschriebener Polarität —
`t.Skip(...)` ausschließlich im benannten Test, Mutation weiterhin angewandt, `make test-go` bleibt
Exit 2, jetzt über `TestCommandProgramNamesAProgramNotAnOperator/A=b_SECRET_cmd_x` — bestätigt von
Reviewer (F-1) und Verifier (eigene, unabhängige Gegenprobe) je in ihrem eigenen Lauf. Derselbe
Fall war bereits Gegenstand des zweiten Belegs dieser Klasse
(`evidence/slice-program-feld-nennt-weder-operator-noch-wertfragment.md`, „Fälle 404 bis 407")
— der `sed`-Anker wechselte zwischenzeitlich (MR-071-Reparatur dieses Slice), die gebundene
Zwei-Test-Eigenschaft selbst blieb unverändert bestehen. Dritter Vorgang dieser Klasse,
3×-Übertritt.
