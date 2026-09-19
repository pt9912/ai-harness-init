# Ein ge-tagter/gepushter Stand trägt keinen Gates-Beleg

**Sub-Area:** * (gesamtes Repo)

Ein Release-Tag oder ein Push trägt für seinen Baum keinen Gates-Beleg: der
Nachweis (`.harness/state/gates-passed.diffsha`) ist lokaler, gitignorierter
Zustand, und ein ge-tagter/gepushter Stand reist ohne ihn — geschnitten und
veröffentlicht wird der Stand auf der Maschine, die den Beleg hält, nicht in
einem Artefakt, das mit ihm reist.