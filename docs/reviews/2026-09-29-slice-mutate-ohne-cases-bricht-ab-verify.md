# Verifier-Report: slice-mutate-ohne-cases-bricht-ab — 2026-09-29

**Rolle:** Verifier (Modul 11) — geprüft gegen DoD (§4 des Slice-Plans) und ADR-0035.
**Kette:** `9a60d52f..34887329` (Tip `34887329`, committet und gepusht). Arbeitsbaum clean.
**Eingangs-Kontext:** Slice-Plan (`docs/plan/planning/in-progress/slice-mutate-ohne-cases-bricht-ab.md`),
Review-Report `docs/reviews/2026-09-29-slice-mutate-ohne-cases-bricht-ab.md` (Commit `62fe669a`),
`AGENTS.md` §3.6/§3.7/§3.9, [ADR-0035](../plan/adr/0035-beleg-statt-lauf-und-die-bezugsmenge-des-schluessels.md).
Jede Behauptung unten ist eigener Lauf, nicht Implementer-Bericht.

---

## 1. DoD §4 — je Punkt

**Liefer-Punkt 1 — Guard in `harness/tools/mutate.sh`: BESTÄTIGT.**
Sperre steht in `main()` nach Lock-, JOBS-, STALL- und CASES_DIR-Prüfung, vor
`select_cases`, Entwertung und Isolationskopie (`harness/tools/mutate.sh:1669`, Erkennung
„nicht gesetzt" per `${MUTATE_CASES+x}` — genau die §3-Form). Meldung nennt alle drei
Auswege (`MUTATE_CASES='<fall> …'`, `gh workflow run mutate.yml`, `MUTATE_FORCE=1`);
Skript-Exit 1, über das Rezept (`Makefile:250`, kein `-`-Präfix, kein `|| true`) Exit 2.
Beleg-Kommando (reale Quelle, Repo-Wurzel, ohne Env):
`bash harness/tools/mutate.sh` →
`mutate: ABBRUCH — ohne MUTATE_CASES faehrt hier kein Vollauf.` + drei Ausweg-Zeilen,
EXIT=1, danach kein Lock-Residuum, Beleg-Slot unberührt (nicht angelegt).
**Abweichung zur Plan-Formulierung, siehe §4a dieses Reports: die Sperre hat eine
Beleg-Ausnahme.**

**Liefer-Punkt 2 — Wächter-Test in `test/mutate-driver.bats`: BESTÄTIGT.**
Block „driver: ohne MUTATE_CASES bricht der Lauf ab, bevor kopiert wird" fährt den realen
Rezept-Weg (Skript als eigener Prozess, `MUTATE_JOBS` in der Umgebung — die make-Ebene
selbst ist im Testkopf als Lücke benannt, Review F-3), per `timeout 60` begrenzt, bindet
Exit 1, Sperren-Meldung samt allen drei Ausweg-Texten, fehlende Isolationskopie
(mktemp-Probe im Protokoll) und byte-gleichen stehenden Beleg. Rotes Gegenbeispiel nicht
nur geführt, sondern **mechanisiert**: Mutations-Fall `500-mutate-vollauf-sperre-entfernt`
nimmt die Sperre per sed heraus; Beleg-Kommando
`make mutate MUTATE_CASES='500-mutate-vollauf-sperre-entfernt'` → `1 ok, 0 Befund(e)`
(101 s, Exit 0). Der ok-Stempel des Mutations-Sensors ist der Rot-Nachweis des Wächters.

**Liefer-Punkt 3 — Doku-Update: BESTÄTIGT.**
`harness/sensors/mutate.md`: neue ABRUCH-Zeile in der Sperren-Liste mit den drei Auswegen;
Absatz zum Abbruch in §Vertrag samt Beleg-Ausnahme (§Grenze); §Teillauf bindet den vollen
lokalen Lauf an `MUTATE_FORCE=1`; §Grenze trägt die F-3-Grenze „Sperre sitzt am Treiber,
nicht am Rezept". `harness/README.md` §Werkzeuge: die `make mutate`-Zeile nennt den
Abbruch, den lokalen Vollauf mit `MUTATE_FORCE=1` und den Nacht-Workflow.

**`make gates` grün: BESTÄTIGT.** Exit 0 über `34887329`; Kernzeilen: Go-Tests ok (8
Pakete, `-count=1`, gepinnte Images), shellcheck/actionlint ohne Ausgabe (clean),
`comment-claims: 79 Datei(en) geprueft, 0 Befund(e)`, Build-Stage `build 2/2` ok,
`span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.

**Review durchgeführt: BESTÄTIGT.** Report liegt unter `docs/reviews/`
(Commit `62fe669a`), zwei HIGH (F-1, F-2), ein INFO (F-3); Behebung in `34887329` —
Nachweise unten.

**Doku-Update berührte öffentliche Verträge: BESTÄTIGT** — mit Liefer-Punkt 3 identisch.

**Closure-Notiz §7 / Beobachtungs-Register / Risiko-Ausgänge §6 / drei Paarungen: OFFEN —
Planner-Aufgabe.** §7 der Plan-Datei steht noch in der Vorlage; die Zuweisung der
Risiko-Ausgänge und der `git mv` nach `done/` sind der Closure-Vorgang (AGENTS §3.10) und
kein Mangel des Implementations-Stands. Meine Zuordnungsvorschläge stehen in §5.

---

## 2. Review-Behebung — je Finding

**F-1 (HIGH, Sperre machte den Beleg-Übersprung zu totalem Code): BEHOBEN, BESTÄTIGT.**
Der Beleg-Übersprung (Exit 0 bei gültigem Beleg ohne Env, `mutate.sh:1652`) geht der
Sperre (Z. 1669) jetzt **voraus**; die Sperre fragt nur noch Laeufe, die wirklich fahren
würden. Real gefahren in **beide Richtungen** im gepinnten bats-Image
(`bats/bats@sha256:e8f18e0a…`, `--network none`, read-only Mount — dieselbe Rezept-Form
wie `make test-bats`):
`ok 1 driver: ohne MUTATE_CASES bricht der Lauf ab, bevor kopiert wird` (Sperren-Meldung,
Exit 1) · `ok 2 driver: ein gueltiger Beleg entlastet den Aufruf vor der Vollauf-Sperre`
(Exit 0, `Beleg fuer Pruefgegenstand` + `Kein Fall-Lauf`, keine Isolationskopie — der
Exit-0-Pfad ist wieder lebendig, ohne Env). Zusätzlich die reale Quelle an der Repo-Wurzel
(s. o., Sperren-Richtung).

**F-2 (HIGH, Fall 264 zahnlos): BEHOBEN, BESTÄTIGT.** Beleg-Kommando
`make mutate MUTATE_CASES='264-mutate-uebersprung-ohne-schluesselvergleich'` →
`mutate: 1 ok, 0 Befund(e)`, EXIT 0 (99 s). Der Wächter „driver: main() ueberspringt NUR
bei einem Beleg, der dem aktuellen Schluessel entspricht" färbt unter der Mutation wieder
rot; der reviewer-gemeldete Befund „blieb GRUEN — hat keine Zaehne mehr" ist behoben.
Die beiden Tests fahren wieder ohne `MUTATE_FORCE` und die Nicht-Übersprung-Aussage ist an
die Sperren-Meldung gebunden; der nächtliche `mutate.yml`-Sweep meldet 264 keinen Befund
mehr. Der neue Fall 500 deckt die Sperre selbst (s. o.) — die Lücke der F-2-Fassung
(„Wächter läuft über nachgebauter Eingabe") ist damit auch für den neuen Wächter
geschlossen.

**F-3 (INFO, Rezept-Zeile unbewacht): BENANNT, BESTÄTIGT.** `harness/sensors/mutate.md`
§Grenze trägt „Die Sperre sitzt am Treiber, nicht am Rezept" mit der genauen Lage (Rezept
setzt weder `MUTATE_CASES` noch `MUTATE_FORCE`; träte eines bei, disarmierte das die
Sperre lautlos); der Testkopf des Wächters nennt die make-Ebene als Abweichung des
Testwegs. Benannte Grenze, kein Wächter — wie im Review gefordert.

---

## 3. CI-Beleg

`gh run list --commit 34887329…` → **ci: completed / success** (Run `36542090692`,
4m40s, „Rolle Implementer: Review-Behebung slice-mutate-ohne-cases-bricht-ab …").
Der mutate-Workflow läuft nächtlich und ist nicht blockierend; die gezielten
Mutate-Läufe (264, 500) sind hier der Zahn-Beleg. Der R3-Nachweis ist am Workflow-Quelltext
selbst bestätigt: `MUTATE_CASES: ${{ steps.shard.outputs.cases }}` im Step-Umfeld des
`make mutate`-Aufrufs, der Shard-Step bricht bei leerer Zuteilung selbst mit Exit 1
**vor** dem Aufruf ab — der Guard trifft keinen Workflow-Lauf.

---

## 4. Plan-vs-Code-Diff

**Deckung.** Die Diff-Dateimenge (`git diff --name-only 9a60d52f..HEAD`) ist exakt die
§3-Menge (`mutate.sh`, `mutate-driver.bats`, `sensors/mutate.md`, `harness/README.md`) plus
Lifecycle-/Review-Begleitung in eigenen Commits (`f8a1fe80` reiner Move, `e46c6e76`
Ruhe-Marker in der Roadmap, `62fe669a` Review-Report). Nichts außerhalb §3 still mitgenommen.

**Unbeanstandete Abweichungen:**

- **(a) Beleg-Ausnahme vor der Sperre** — der Plan (§1 Ziel, DoD-Punkt 1) formuliert den
  Abbruch ohne Ausnahme; der Fix-Stand entlädt einen gültigen Beleg den Aufruf, **bevor**
  die Sperre fragt. Inhaltlich gerechtfertigt (Review F-1, ADR-0035, „Beleg statt Lauf"),
  dokumentiert in `harness/sensors/mutate.md` §Vertrag/§Grenze — aber die Plan-Datei nennt
  die Ausnahme nicht. Der Plan-Text beschreibt damit enger als der Code handelt. Das ist
  ein Übergabe-Artefakt an den Planner: Plan-Diff oder Vermerk bei Closure, keine
  Implementer- oder Verifier-Arbeit.
- **(b) Umfang über §3 hinaus durch die Review-Behebung:** zweiter Wächter-Block
  („ein gueltiger Beleg entlastet den Aufruf vor der Vollauf-Sperre"), Mutations-Fall 500,
  Umstellung dreier bestehender bats-Aufrufe auf `MUTATE_FORCE=1` und Umbau der zwei
  `# verify:`-Blöcke. Alles F-1/F-2-Fixierung, Assertion-Mengen an der geänderten Lage,
  vom Review-Befund gedeckt.
- **(c) Kopfkommentar (§TEILLAUF) zieht nach** — wie in §3 vorgesehen; Kommentar-Klassen
  Indikativ/Abgrenzung, Sensor-Name im Skript trifft den realen Testnamen (§3.7,
  comment-claims 0 Befunde stützt).

---

## 5. Verbleibende Risiken und Closure-Pflichten (an den Planner)

- **R1 (ADR-0035 `Proposed`, `MUTATE_FORCE`-Ausnahme):** Ausgang *weiter offen* →
  `BEO-ALL/mutate-beleg-verfaellt-mit-jedem-commit-und-jedem-nachsehen-lauf` — wie im Plan
  vorgesehen; die Beleg-Mechanik ist unverändert, der dritte Ausweg wandert mit einer
  ADR-Änderung.
- **R2 (Wächter hängt im Vollauf):** Ausgang *entfallen* — bestätigt: `timeout 60` begrenzt
  den Aufruf; das Entfallen des Guards ist mechanisiert als Fall 500 und dort rot gesehen.
- **R3 (Guard bricht den CI-Vollsweep):** Ausgang *entfallen* — bestätigt am
  Workflow-Quelltext (§3).
- **F-3-Grenze bleibt benannt-unbewacht:** die Rezept-Zeile liest kein Wächter; für die
  Closure als known gap halten, nicht als abgeschlossen verbuchen.
- **Offen im Lifecycle:** §7 Closure-Notiz (Lerneintrag — die Finding-Klassen des Reviews
  sind die Eingabe), Register-Eintrag oder „keine Beobachtung angefallen" (§8 dokumentiert
  die Sichtung; keine der drei geprüften Beobachtungen wird von diesem Slice getroffen),
  Risiko-Ausgänge zuweisen, drei Paarungen, `git mv` nach `done/` — Planner-Kontext,
  eigener Commit (AGENTS §3.10).
