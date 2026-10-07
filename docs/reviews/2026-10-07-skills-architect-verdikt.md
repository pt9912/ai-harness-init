# Architect-Verdikt zu M-2 — Ziel-Fälle in `make full-smoke` statt `make selbstpruefung`

**Rolleninhaber:** Architect (ai-harness-init-Team, pt9912) · **Bezug:**
[ADR-0084](../plan/adr/0084-reviewer-skills-im-ziel-skip-if-present.md) ·
**Eingang:** Review `2026-10-07-skills-review.md`, Finding M-2.

**Verdikt: ADR-0084 gilt unverändert; keine Folge-ADR.**

- Kriterium: Ändert sich eine Entscheidung oder nur das Werkzeug ihrer Messung? Nur das Werkzeug.
  Regel und Fälle der Fitness-Zeile 2 — Re-Lauf über gefülltem, unverändertem und fehlendem Skill —
  bleiben dieselben und werden am gebootstrappten Ziel mit dem echten Binär gemessen. Die Zeile
  nennt selbst `make full-smoke` als den Lauf, der sie fährt; ersetzt ist nur das Zwischenziel
  `make selbstpruefung`, dessen Skript keinen Bootstrap fährt
  (`grep -n 'ai-harness-init' internal/emit/templates/enforce/selbstpruefung.sh` → nur der
  Kopfkommentar) und den Re-Lauf darum nicht herstellen kann.
- Ein Adopter erwartet die Klasse nicht von seiner Selbstprüfung: §Entscheidung der ADR setzt keine
  Pflicht an das emittierte Skript, nur die Fitness-Zeile nennt es als Messort.
- **Akzeptiertes Negativ:** Die Fitness-Zeile 2 behält den Namen `make selbstpruefung`. Eine
  Folge-ADR lohnt nicht, weil der Messort ohne die ADR auffindbar bleibt: die Stufe
  *„Klasse der Reviewer-Skills"* in `harness/tools/full-smoke.sh` trägt eine Stufen-Deklaration und
  steht damit in [`docs/user/e2e-abdeckung.md`](../user/e2e-abdeckung.md) — dort sucht ein
  Retirement-Check die Messung, und dort findet er sie. Eine künftige Folge-ADR zu ADR-0084 (etwa
  über einen ihrer Re-Evaluierungs-Trigger) zieht den Namen mit.
- Offen für den Planner (AGENTS.md §3.10): keine Plan-Korrektur nötig; §1 des Slice-Plans trägt die
  Abweichung bereits, dieses Verdikt ist ihr Träger außerhalb des Plans.
