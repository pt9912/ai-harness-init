**Vorgang:** slice-mutations-anker-greift-in-den-gates

**Fund:** Die Fälle 145 und 147 griffen nicht mehr: `ac429eec` (Filter `!span.IsNotKnown(s.AgentRole)` in `internal/report/report.go`) änderte die Ankerzeile, ohne die Fälle zu kennen. Der erste Lauf des Greift-Modus meldete beide auf HEAD (Review I-2); nachgezogen in `9fbc304c`.
