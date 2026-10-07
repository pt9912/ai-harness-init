# Architect-Verdikt zu F-2 — `makefiles:` mit Glob statt Einzeldatei `repo.mk`

**Rolleninhaber:** Architect (ai-harness-init-Team, pt9912) · **Bezug:**
[ADR-0080](../plan/adr/0080-anwender-targets-leben-in-repo-mk-ausserhalb-von-harness-mk.md),
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
**Eingang:** Review `2026-10-07-targets-review.md`, Finding F-2.

**Verdikt: ADR-0080 trägt den Glob; keine Folge-ADR.**

- Festlegung 2 setzt Klasse und Startinhalt von `repo.mk`. Der Satz „braucht … keinen Glob" ist
  eine Folgerung, gebunden an eine dort ausdrücklich als ungemessen markierte Annahme; er verbietet
  keinen Glob. Festlegung 3 und Fitness 2 lassen `repo.mk` fehlen — die ADR selbst verlangt damit
  eine Konfiguration, die eine fehlende `repo.mk` übersteht. Festlegung 5 verlangt, dass `repo.mk`
  in `makefiles:` gelesen wird; `"*.mk"` leistet das.
- Fitness 3 gilt sinngemäß: das Rot entsteht durch Streichen von `"*.mk"` aus `makefiles:`.
- **Akzeptiertes Negativ:** Der Text von Festlegung 2 behält die überholte Prämisse. Eine Folge-ADR
  lohnt nicht, weil ein Rückfall auf die Einzeldatei nicht still bliebe: Fitness 2 (`make gates`
  ohne `repo.mk` in `make full-smoke`) würde mit dem Exit 2 des Moduls `targets` rot. Den Grund
  trägt der Kopfkommentar der emittierten `.d-check.yml` samt seinen Grenzen (Wurzel-`.mk` wird
  mitgelesen, Unterordner-`.mk` nicht, rekursiver Glob verworfen).
- Offen für den Planner (AGENTS.md §3.10): Slice-Plan §1/§3 nennen noch die Einzeldatei; die
  Angleichung ist Plan-Korrektur, keine Architektur-Frage.
