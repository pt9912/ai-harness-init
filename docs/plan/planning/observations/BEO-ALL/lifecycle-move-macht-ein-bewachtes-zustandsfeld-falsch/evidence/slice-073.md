**Vorgang:** slice-073
**Fund:** Beide Lifecycle-Übergänge dieses Slice haben den Ruhe-Marker der Roadmap bewegt, und
zwar in beide Richtungen. Der Übergang `next` → `in-progress` machte
[`in-progress/`](../../../../in-progress) beansprucht und den Marker *„Nichts in Arbeit."* damit
falsch — er musste im selben Zug entfernt werden. Der Closure-Move macht dasselbe Verzeichnis
wieder slice-frei und den fehlenden Marker damit falsch; er muss zurück.

Das Modul `planning` hält genau diese Invariante (Grund-Code `planning-drift`), und `make slice-mv`
trägt sie nicht: Es zieht Pfade nach, keine Zustandssätze. Zwischen dem Move-Commit und dem
Marker-Commit ist `make docs-check` deshalb rot — eine Lücke, die aus der Trennung von Move und
Inhalt ([`AGENTS.md`](../../../../../../../AGENTS.md) §3.3) folgt und nicht aus einem Versäumnis.
