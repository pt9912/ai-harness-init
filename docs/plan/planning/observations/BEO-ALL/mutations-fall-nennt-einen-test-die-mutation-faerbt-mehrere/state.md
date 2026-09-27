**Stand:** offen

Dritter Beleg mit diesem Slice
(`ls docs/plan/planning/observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/evidence/*.md | wc -l`
→ 3, gelesen 2026-09-27, keine Erwartung): `slice-fall-406-trifft-die-umgebaute-zerlegung`. Der
3×-Übertritt (Modul 6 §Das Beobachtungs-Register) ist mit diesem Beleg erreicht — der Lese-Schritt
(hier: diese Slice-Closure selbst, Repo ohne Wellen-Betrieb) erkennt ihn, weist aber keinen der
drei Ausgänge zu: Verkörperung ist eine Architect-Entscheidung
(`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3b — Planner → Architect →
Planner; ohne Wellen-Betrieb bindet dieselbe Übergabe, Anker `seit slice-<Kennung>` statt
`seit welle-<Kennung>`). **Übergabe an den Architect fällig:** entscheiden, ob die Klasse — eine
Mutation bindet mehr Tests, als ihr `# expect:`-Kopf nennt — einen Zielort bekommt (etwa eine
Zeile im Reviewer-Skill, die bei jedem neuen oder geänderten Mutations-Fall die volle
Bindungs-Menge gegen den Kopf prüft) oder als benannte Lücke verkörpert wird: `make mutate` prüft
nach eigener Aussage nur, ob der genannte Test in der roten Ausgabe steht
(`harness/tools/mutate.sh`), nicht seine Exklusivität — dieselbe Grenze, die drei der bisherigen
Belege dieser Klasse bereits einzeln festgestellt haben, ohne dass sie bisher normiert wurde.

Unterhalb der Schwelle war `offen` der Normalzustand; ab diesem Beleg ist es eine **zulässige,
vorübergehende** Lage bis zum nächsten Lese-Schritt mit Architect-Verdikt (README dieser Ablage,
§Ab 3× trägt `state.md` genau einen von drei Ausgängen).

**Vierter Beleg, Übergabe an den Architect unverändert fällig.** Ein weiterer abgeschlossener
Vorgang hat einen vierten Beleg angelegt
(`ls docs/plan/planning/observations/BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/evidence/*.md | wc -l`
→ 4, gelesen 2026-09-27, keine Erwartung): `slice-071-bilanz-nennt-ihren-bestand`. Die Klasse griff
hier prospektiv — Implementer und Verifier erkannten die fehlende Exklusivität von Mutations-Fall
495 selbst und werteten sie zutreffend als kein Finding (`make mutate` verlangt keine
Exklusivität, nur die Anwesenheit des genannten Fehlschlags) —, das ändert aber nichts an der seit
`slice-fall-406-trifft-die-umgebaute-zerlegung` offenen Übergabe: ob die Klasse einen Zielort
bekommt oder als benannte Lücke verkörpert wird, entscheidet weiterhin der Architect, nicht diese
Closure.
