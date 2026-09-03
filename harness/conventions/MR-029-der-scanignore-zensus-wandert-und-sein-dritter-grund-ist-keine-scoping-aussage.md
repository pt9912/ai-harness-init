# MR-029 — Der `scan.ignore`-Zensus wandert, und sein dritter Grund ist keine Scoping-Aussage

> **ÜBERHOLT: die Werkzeug-Aussage des Auflösungs-Triggers — *„Am heutigen Pin gibt es ihn nicht"* → [`MR-034`](../conventions.md#mr-034--das-geteilte-referenz-ventil-trägt-am-gepinnten-stand).** Die übrigen Setzungen dieses Eintrags gelten fort, Zensus und Aufnahme-Grenze eingeschlossen.

- **Datum:** 2026-08-28
- **Wirksamkeits-Anlass:** slice-081 — derselbe Lauf, der den Eintrag in `.d-check.yml` gesetzt
  hat ([`MR-028`](../conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt)).
- **Geltungsbereich:** `scan.ignore` in `.d-check.yml`, und **nur** dieser Posten von
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids). Dessen übrige
  Setzungen — die Modul-Aktivierung `matrix`/`spans`, `ids` mit `link-policy: always`, das
  `MR`-Pattern — bleiben unangetastet und gelten fort.
- **Ersetzt-Baseline-Regel:** keine — nach dem Wortlaut der Eintrags-Vorlage damit ein **Fork**,
  und der Weg des dritten Grundes ist genau der, den die Baseline vorsieht: ein Trigger, der
  ehrlich nie zu erreichen ist, führt nach
  [`modul-07-carveouts.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-07-carveouts.md#werkzeug-wahl)
  §Werkzeug-Wahl bei Diskrepanz auf *„**ADR (permanent)** … die Senkung ist
  Architekturentscheidung, kein Übergang"* — und dort liegt sie
  ([`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)). Zensus
  und Aufnahme-Grenze sind Zustand und Schranke, keine Setzung gegen eine Regel.
  **Was hier ausdrücklich nicht als ersetzte Regel gilt:** der Formcheck-Satz des
  [Freshness-Audits](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md#freshness-audit-der-vendored-baseline-schritt-2)
  — *„Ein toter Anker ist kein Ausgang, sondern ein Formfehler und wird zuerst repariert"* —
  spricht über den `Geltungsbereich` **eines Eintrags dieses Blocks** nach einem Baseline-Update,
  nicht über einen Markdown-Link in einer eingefrorenen ADR. Dasselbe Thema ist nicht dieselbe
  Pflicht. Gemessen am adoptierten Stand `v5.12.0`.
- **Löst auf:** die Zensus-Aussage aus
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) — *„`scan.ignore` führt
  heute vier Einträge, aus zwei Gründen"* samt der Klassifikation *„beide sind Scoping, keine
  Gate-Lockerung …"*. Jener Eintrag bleibt unangetastet; seine Zahl und seine Klassifikation sind
  ab hier überholt, und **hier** steht der geltende Stand.
- **Ausgelöst durch:** [`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  §Konsequenzen, Folgepflicht 2 — fällig geworden mit dem Baseline-Stand `v5.12.0`, der den dort
  vorausgesetzten Tausch wirklich gefahren hat.
- **Adaption — der Zensus, mit dem Kommando, das ihn ausgibt.** `scan.ignore` führt **fünf**
  Einträge: `grep -m1 '^  ignore:' .d-check.yml | grep -o '"[^"]*"' | wc -l` → **5**. Sie stehen
  aus **drei** Gründen, und der dritte ist von anderer Klasse als die zwei davor:
  1. **Vendored Fremd-Dokumente** — dieses Repo *spiegelt* sie, statt sie zu schreiben:
     `.harness/baseline/**` ([`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache))
     und `docs/user/claude-hooks-referenz.md`. **Scoping:** der Prüfumfang schrumpft nicht um
     Bestand, den dieses Repo autoritativ schreibt.
  2. **Kein Fließtext** — `**/*.template.md` sind Ziel-Form-Vorlagen mit Platzhaltern statt
     Verweisen, `.tmp/**` ist Wegwerf-Bestand. **Scoping:** beide tragen keine Aussage, die
     veralten könnte.
  3. **Ein eingefrorenes, repo-autoritatives Artefakt** —
     `docs/plan/adr/0013-technik-stratum-als-zielort.md`. **Hier stimmt *Scoping* nicht mehr:**
     diese Datei schreibt das Repo selbst, und sie verlässt den Gate ganz, über alle aktiven
     Module. Der Eintrag ist eine **Senkung** nach [`AGENTS.md`](../../AGENTS.md) §3.5 und
     ausschließlich durch
     [`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
     autorisiert. Grund dort: die Datei trägt einen Markdown-Link in den vendored Baum unter dem
     abgelösten Tag, [`AGENTS.md`](../../AGENTS.md) §3.4 sperrt die Reparatur, und ein Befund, den
     niemand beheben darf, hält `make gates` dauerhaft rot
     ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) eine
     Ebene tiefer).
- **Die Aufnahme-Grenze, verbatim aus der Entscheidung, die sie setzt.**
  [`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  §Entscheidung: *„Das ist eine Aufnahme-Grenze, keine Aufnahme-Regel: jeder zusätzliche Eintrag
  ist eine neue Senkung und löst `AGENTS.md` §3.5 erneut aus — auch dann, wenn er dieselbe
  Bedingung erfüllt wie dieser."* Die Liste ist **extensional geschlossen**: Punkt 3 deckt genau
  eine namentlich genannte Datei, nicht ihre Klasse. Ein zweites eingefrorenes Artefakt mit
  gebrochenem Baseline-Link braucht eine eigene ADR.
- **Der Preis, selbst nachgefahren (2026-08-28).** Sonde über einer isolierten Kopie des
  Index-Baums außerhalb des Repos (`git ls-files -z | tar --null -T - -cf -`, entpackt in ein
  temporäres Verzeichnis), gepinntes Image, `--network none`, Mount `:ro`, einziger Unterschied
  der fünfte Eintrag: ohne ihn `d-check: 441 Datei(en) geprüft, 9 Befund(e)`, mit ihm
  `d-check: 440 Datei(en) geprüft, 8 Befund(e)`. **Tragend ist der Delta — je genau eins —, nicht
  das Absolutwert-Paar:** der Nenner ist der Markdown-Bestand des Repos und wandert mit ihm
  ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 2).
  Der eine erkaufte Befund ist der unbehebbare.
- **Warum ein neuer Eintrag und keine Korrektur in
  [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) — die Folgepflicht
  verlangt eine Wirkung, nicht einen Mechanismus.**
  [`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) nennt
  jenen Eintrag als den Ort, an dem Zahl, Klassifikation und Grenze zu lesen sein müssen. Die
  Append-only-Disziplin verbietet, sie *dort hinein* zu schreiben — und sie tut es am adoptierten
  Stand schärfer als am abgelösten. `v3.5.2` sagte *„keine nachträglichen inhaltlichen Änderungen
  an akzeptierten Einträgen — nur neue Einträge oder explizite Aufhebungen via neuen MR"*
  (`.harness/baseline/v3.5.2/templates/harness/conventions.template.md`, Kommentar über dem
  Adaptions-Block; die Zeile existiert am neuen Stand nicht mehr). `v5.12.0` sagt
  *„Einträge werden nie überschrieben"*
  ([`grundlagen-harness-dateien.md`](../../.harness/baseline/v5.18.0/regelwerk/grundlagen-harness-dateien.md#harnessconventionsmd-als-konventionsspeicher)
  §harness/conventions.md als Konventionsspeicher) und benennt diesen Fall eigens:
  *„Rückbau ist ein neuer Eintrag, kein Edit — eine aufgelöste `MR-<NNN>` wird nicht
  überschrieben, sondern bekommt einen Nachfolger, der sie auflöst und den Baseline-Stand nennt,
  der den Trigger gefeuert hat. Die alte Zeile ist die historisch korrekte Aussage über den
  damaligen Zustand"*
  ([`modul-02-harness-bootstrap.md`](../../.harness/baseline/v5.18.0/regelwerk/modul-02-harness-bootstrap.md)).
  Der Satz in [`MR-001`](../conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids) ist die
  richtige Aussage über den 13. Juni; ihn zu überschreiben löschte, **wann** die Klassifikation
  noch stimmte. **Dieses Repo hat den Fall bereits einmal so entschieden:**
  [`MR-021`](../conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
  lässt die Zahl *„zwei Abweichungen von der Vorlagen-Form"* in
  [`MR-019`](../conventions.md#mr-019--technik-stratum-als-rang-2-der-source-precedence) stehen und schreibt
  daneben, dass sie überholt ist. Die Folgepflicht ist damit **erfüllt, nicht umgangen** — nur
  der Ort ist der Nachfolger statt des Originals.
- **Wo der nächste Antragsteller die Grenze liest, steht sie zweimal.** Nicht nur hier, sondern
  im Kommentar über `scan.ignore` in `.d-check.yml` selbst — an der Stelle, an der ein sechster
  Eintrag entstünde. Das ist Absicht: ein Register wird gelesen, wenn man es sucht, ein
  Config-Kommentar, wenn man die Zeile anfasst.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der `.d-check.yml` hält die
  `scan.ignore`-Liste gegen die in ADRs autorisierten Einträge; [`AGENTS.md`](../../AGENTS.md) §3.5
  hat keinen Sensor. Das steht in
  [`ADR-0017`](../../docs/plan/adr/0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)
  §Fitness Function so und wird hier nicht anders behauptet
  ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Träger ist
  der Rollen-Wechsel vor der Änderung.
- **Auflösungs-Trigger:** Der Zensus wandert mit der Liste — ein sechster Eintrag ist ein eigener
  §3.5-Vorgang mit eigener ADR und löst diesen Eintrag ab. Die **Klassifikation** fällt neu an,
  sobald `links` einen referenz-weiten Ausschluss bekommt: dann ersetzt der präzise Knopf den
  datei-weiten Eintrag, Punkt 3 entfällt, und der Zensus steht wieder auf zwei Gründen. Am
  heutigen Pin gibt es ihn nicht, und auch der Zeilen-Marker ist keiner: eine Sonde außerhalb des
  Repos — eine Datei mit drei gebrochenen Links, einer ohne Marker, einer mit
  `<!-- d-check:ignore -->` auf derselben Zeile, einer mit dem Marker in der Zeile davor,
  `modules: [links, anchors]` — meldet **alle drei**
  (`d-check: 1 Datei(en) geprüft, 3 Befund(e)`). `d-check:ignore` deckt `links` **nicht**;
  [`MR-027`](../conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) misst ihn an `ids`
  und `codepaths`.
