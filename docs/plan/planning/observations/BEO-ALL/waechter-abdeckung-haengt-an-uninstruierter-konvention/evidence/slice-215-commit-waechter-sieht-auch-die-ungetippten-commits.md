**Vorgang:** slice-215-commit-waechter-sieht-auch-die-ungetippten-commits
**Fund:** Der Vorgang teilt die Klasse in zwei Hälften und schließt **eine** davon: Der neue
Träger am Commit braucht die Aufrufform überhaupt nicht — er liest die Message-Datei, die `git` ihm
übergibt, gleichgültig welcher Aufruf sie erzeugt hat
([`ADR-0053`](../../../../../../../docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
Festlegung 2, [`harness/README.md`](../../../../../../../harness/README.md#traceability)
§Traceability). Die zweite Hälfte — der PreToolUse-Kanal — hängt unverändert an der Konvention,
und **der Vorgang hat sie nicht geschrieben**: die vier Rollen-Anweisungssätze und der Reviewer-Skill
sind in seinem Diff nicht enthalten. Gemessen, **beide Zahlen ohne Erwartungswert**:

```sh
git diff --name-only 7ee36939^..dc392dd9 | grep -c '\.claude/agents/\|\.harness/skills/'   # 0
git grep -L 'Commit via Message-Datei' -- .claude/agents/*.md .harness/skills/*.md | wc -l  # 7
```

Die sieben sind **alle** Rollen-Anweisungssätze des Repos — sechs `.claude/agents/*.md` und der
eine Skill. Die Lücke ist damit nicht kleiner geworden, sondern **adressiert**: Sie steht als Zeile in
der Reichweiten-Tabelle des Einstiegs und nennt diesen Register-Eintrag als ihre Adresse. Die
rollen-gebundene Behebung bleibt fremdes Eigentum
([`ADR-0028`](../../../../../../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)),
die konventions-unabhängige ist für die Commit-Hälfte geleistet — genau die Aufteilung, die
`state.md` dieses Eintrags als Trägerschaft von slice-215 führt.
