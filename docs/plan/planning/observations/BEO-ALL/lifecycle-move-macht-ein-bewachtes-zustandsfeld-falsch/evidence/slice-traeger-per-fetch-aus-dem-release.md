**Vorgang:** slice-traeger-per-fetch-aus-dem-release
**Fund:** Der Lifecycle-Move des Vorgangs (`in-progress/` → `done/`, Commit
`5de3bdf6`) kippte das bewachte Zustandsfeld: der Ruhe-Marker der Roadmap
stand nicht, solange `in-progress/` einen Slice trug (dieselbe Marke, die der
Claim-Übergang des Pin-Sprung-Slices fallen liess), und kehrt mit dem
Abschluss des Slices zurueck. Der Marker-Waechter des Doku-Gates haelt beide
Richtungen — fehlender Marker bei leerem `in-progress/` ist derselbe Defekt
wie ein stehengebliebener Marker bei beanspruchtem Slice.