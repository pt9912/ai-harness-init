# Übergaben fehlen im Slice-Plan

**Sub-Area:** `*` (gesamtes Repo)

Ein Slice-Plan sagt nicht jede Konsequenz seiner eigenen geplanten Änderung: Wege, die die
Änderung außerhalb ihres Codes erzwingt (Mutations-Probe über der lokalen Schwelle eines
Slice-Satzes, CI-Branch), und Folgen, die sie in angrenzenden Registern anrichtet
(Zähler im Adaptions-Block, Doku-Index), stehen an keiner Plan-Stelle — sie erscheinen
erst im Review als Plan-Defekt, und die Closure trägt sie als Übergabe nach.
