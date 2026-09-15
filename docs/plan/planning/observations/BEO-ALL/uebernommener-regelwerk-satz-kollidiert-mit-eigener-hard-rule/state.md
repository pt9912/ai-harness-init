**Stand:** offen

Ein Wächter besteht nicht: Kein Modul aus `modules:` der
[`.d-check.yml`](../../../../../../.d-check.yml) hält einen übernommenen Satz gegen die Hard Rules
dieses Repos, und `make mutate` kennt dafür keine Fehlschlag-Form. Baubar ist auch kein Vergleich:
Ob ein Satz eine Handlung der falschen Rolle zuweist, ist ein Urteil über Bedeutung und kein Muster.
Träger sind der Lauf, der einen Regelwerk-Satz übernimmt, und der Review, der die Kollision liest.

**Grenze der Verkörperung, benannt.** Die Regel, die den Fall auflöst, existiert im Repo —
[`AGENTS.md`](../../../../../../AGENTS.md) §3.10 weist eine verschobene Out-of-Scope-Grenze als
Übergabe-Artefakt dem Planner zu —, sie steht aber **nicht an der Stelle**, an der der übernehmende
Lauf sie liest. Dieselbe Lücke stellt
[`AGENTS.md`](../../../../../../AGENTS.md) §3.8 für den eigenen Commit-Zuschnitt fest: Ein Gate
liest keine Rollen.
