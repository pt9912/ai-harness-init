# MR-037 — Wellenlose Arbeit ist jetzt Baseline-Default, ihr Auslöser-Test ist neu gefasst

- **Datum:** 2026-08-31
- **Wirksamkeits-Anlass:** slice-082 — Adaptions-Durchgang von welle-10, Achse 1.
- **Geltungsbereich:** [`MR-016`](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  vollständig (Setzungen 1–3, Ist-Messung, Durchsetzung-Beobachtung).
- **Löst auf:** [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) vollständig. Die adoptierte Baseline `v5.12.0` regelt "Welle oder nicht"
  und "wo wellenlose Arbeit steht" jetzt selbst, mit einem engeren Kriterium an genau der
  Stelle, an der [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) zu weit ging.
- **Ausgelöst durch Baseline-Stand:** `v5.12.0`.
- **Ersetzt-Baseline-Regel:**
  [`modul-06-roadmap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-06-roadmap.md)
  §Wann Arbeit eine Welle braucht und §Wellenlos heißt nicht wächterlos.
- **Was jetzt Baseline-Default ist (gegenstandslos).** [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 2/3 — wellenlose Arbeit
  erscheint nicht in der Roadmap, ein geschlossener wellenloser Slice hinterlässt dort keine
  Spur, sein Zustand ist die Verzeichnis-Position — steht wörtlich in der neuen Fassung:
  *„Wellenlose Arbeit erscheint nicht in der Roadmap — weder beim Start noch beim Abschluss.
  Ihr Zustand ist die Verzeichnis-Position … Ein Eintrag daneben wäre eine zweite Quelle für
  denselben Zustand, und die altert"* und *„Die Belege eines geschlossenen wellenlosen Slice
  stehen in seiner Datei und in git; das Closure-Log der Roadmap ist für Wellen."* Was [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  als eigene Repo-Adaption begründen musste, begründet die Baseline jetzt selbst.
- **Was widersprach, und was übernommen wird (widerspricht → übernehmen).** [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) Setzung 1,
  dritte Frage, entschied: *„Auslöser reaktiv oder gewollt? … 'Wir wollen eine neue Fähigkeit'
  → gewollt, Welle — auch wenn es zunächst nach einem Slice aussieht."* Die neue Fassung
  widerspricht dem ausdrücklich: *„Wellenlose Arbeit … typisch für Reaktives … aber nicht
  darauf beschränkt: auch eine neue Fähigkeit kann ein einzelner Slice sein."* Das eigene
  Register dieses Repos stützt die Baseline gegen die eigene alte Regel: Die drei von [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  selbst genannten Gegenbeispiele (slice-027, slice-039, slice-048) waren *„fast immer
  nachgeschnitten"* — sie wurden erst zu Wellen, als sich ein Bündel zeigte, nicht weil
  "gewollt" allein schon eine Welle verlangte. Statt die widerlegte Regel zu verteidigen,
  übernimmt dieser Eintrag das engere Baseline-Kriterium: *„Eine Welle liegt vor, wenn es eine
  beobachtbare Closure-Bedingung gibt, die mehr beobachtet, als die DoDs ihrer Slices schon
  belegen."* Bündel und ein eigenes Closure-Kriterium bleiben die tragenden Fragen ([MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
  Frage 1/2 decken sich mit der neuen Fassung); die dritte Frage (reaktiv/gewollt) entfällt als
  eigenständiges Kriterium.
- **Was nicht anderswo steht, und wo es jetzt lebt.** Die "Durchsetzung"-Beobachtung aus
  [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) (d-checks Modul `planning` liegt im Bild, ist aber an keinen Trigger gehängt) ist
  **ersatzlos** im Sinn von
  [ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (b) —
  nicht weil sie falsch wäre, sondern weil sie seit dem 2026-08-28-Eintrag der
  Roadmap-Drift-Tabelle (welle-13-Kandidat *„Regeln ohne Feedback-Quadrant schließen"*) an
  einem aktuelleren, genaueren Ort weitergeführt wird.
- **Ausgang:** gegenstandslos (Setzung 2/3) und widerspricht → übernehmen (Setzung 1, Frage 3)
  führen zusammen zum Rückbau derselben Aussage. Da nichts vom Rumpf mehr eigenständig bindet
  (die einzige verbleibende Aussage ist oben umgezogen), ist dies eine **vollständige
  Aufhebung** ([`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)):
  Nummer, Überschrift wörtlich, Datum und die `Aufgehoben durch`-Zeile bleiben, der Rumpf fällt
  in einem eigenen, additionsfreien Commit ([`AGENTS.md`](../../AGENTS.md) §3.3,
  [ADR-0014](../../docs/plan/adr/0014-aufgehobener-eintrag-kopf-statt-rumpf.md) Festlegung 2 (c)).
- **Achse 2 — eigener Bedarf.** [MR-016](../conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird) trug keinen numerischen Auflösungs-Trigger außer
  *„permanent"* mit der Bedingung *„Setzung 2/3 fallen, sobald Modul 6 selbst einen Ort für
  wellenlose Arbeit vorsieht"* — genau das ist eingetreten (siehe oben); der eigene Bedarf ist
  damit durch den Baseline-Bezug erschöpft, kein separater Achse-2-Befund bleibt offen.
- **Auflösungs-Trigger:** permanent als Sachstands-Feststellung.
