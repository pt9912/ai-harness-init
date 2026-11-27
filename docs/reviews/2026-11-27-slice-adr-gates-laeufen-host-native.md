# Review-Report — slice-adr-gates-laeufen-host-native

**Datum:** 2026-11-27 · **Reviewer-Kontext:** frisch (Modul 8, kein Self-Review) ·
**Prüfumfang:** die drei Architect-Commits `525749b4` (ADR-0109 + ADR-Index),
`cdaf7d52` (`AGENTS.md` §3.9-Fassung), `daa4aad2` (`harness/conventions.md`
MR-098-Index-Zeile + Eintrags-Datei) — geprüft gegen Slice-Plan
(`docs/plan/planning/in-progress/slice-adr-gates-laeufen-host-native.md`), ADRs,
Hard Rules. **Nicht geprüft:** DoD-Abhakung (Verifier), Gates (Docker-Daemon aus —
Link-Prüfung manuell, das Netz ist CI auf dem Push), Commits unangetastet.

---

## Findings

### F-1 — LOW

- `kategorie`: LOW
- `quelle`: Maintainability (Link-Pflicht, [`MR-001`](../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)-Gegenstand)
- `pfad`: harness/conventions/MR-098-die-umgebungs-zusage-traegt-mischform-die-dogfood-gates-und-lab-laeufer-fahren-am-host.md:8,13,16,21,41,65
- `befund`: Sechs relative Links in der neuen Eintrags-Datei führen mit **einer**
  `../`-Stufe zu wenig und lösen aus `harness/conventions/` ins Falsche:
  `../docs/plan/adr/0109-…md` (Zeilen 8 und 65), `../harness/README.md` (13),
  `../docs/plan/adr/0003-go-native-binaries.md` (16), `../.harness/baseline/v7.0.0/regelwerk/modul-14-docker-harness.md`
  (21 und 41). Beleg: `cd harness/conventions && [ -e ../docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md ]`
  → BROKEN (ebenso `../.harness/baseline/…`, `../harness/README.md`); die
  bestehenden Einträge (z. B. MR-053, MR-097) verlinken Repo-Artefakte mit
  `../../…` (`grep -ho '](\.\.[^)]*)' MR-053*.md MR-097*.md` → `](../../AGENTS.md)`,
  `](../../test/…)`). Richtig wäre `../../docs/…`, `../../harness/README.md`,
  `../../.harness/…`.
- `verifizierbar`: ja — `make docs-check` (d-check-Link-Module) färbt das nach
  Aufhebung der Docker-Unterbrechung; hier manuell nachgefahren (Pfad-Existenzprobe).
- `klasse`: MR-Eintrags-Links in falscher Basis-Tiefe

### F-2 — INFO

- `kategorie`: INFO
- `quelle`: ADR-0109 (Folgestellen-Deklaration)
- `pfad`: harness/sensors/mutate.md:274; README.md:107
- `befund`: Die Sicht-Doku, die die alte §3.9-Fassung zitiert, ist bei HEAD
  bereits abweichend: `harness/sensors/mutate.md` nennt als Host-Bedarf
  „`git`, `docker` und GNU `make`" (die neue §3.9-Fassung nennt „`git`,
  GNU `make` und die Inventar-Werkzeuge der Gates"), und `README.md` behauptet
  „`make gates` läuft grün und Docker-only". ADR-0109 (Konsequenzen, „weitere
  Folgestellen") deklariert genau diese Klasse — „die Sicht-Doku, die die alte
  §3.9-Fassung zitiert (z. B. `harness/sensors/mutate.md`)" — als
  fort-treibbar ohne CR und übergibt sie an die Mechanik; damit kein
  Regelbruch, aber ein benannter Übergabestand, den die Closure §7 als Übergabe
  der Mechanik-Slices tragen sollte (Konkret-Zeilen oben).
- `verifizierbar`: nein — kein Gate liest die Quoten-Fassungen gegen die neue
  Norm (Träger ist die Fortschreibung der Mechanik).
- `klasse`: Deklarierte Folgestellen-Dokumentation noch nicht nachgezogen

### F-3 — INFO

- `kategorie`: INFO
- `quelle`: ADR-0109 (Schärft-Zeile) · grundlagen-source-precedence (ADR schärft Sicht)
- `pfad`: docs/plan/adr/0109-gates-lauefer-docker-los-image-weg-opt-in.md:11; spec/architecture.md:105
- `befund`: Die `Schärft`-Zeile erklärt `ARC-012` (docker, „substituierbar:
  nein", Rolle „d-check-Image-Lauf (Gate) + Tool-Build-Image") für
  wegwahl-abhängig; die Zeile in `spec/architecture.md` steht unverändert, und
  die ADR deklariert den Nachzug ausdrücklich („fortschreibbar ohne CR, Träger
  ist das Doku-Update der Mechanik"; `ARC-013` bleibt korrekt unverändert —
  der Tool-Build-Anteil läuft weiter im gepinnten Image). Deklarierte
  Änderungskopplung („wer diese ADR ändert, zieht `ARC-012` … nach") — kein
  Befund gegen §3.4, aber Übergabestand wie F-2.
- `verifizierbar`: nein — kein Sensor hält die ADR gegen die ARC-Zeile.
- `klasse`: ARC-Baseline folgt der ADR-Schärfung erst mit der Mechanik

---

## Negativbefunde (geprüft, ohne Befund)

- **§3.8-Commit-Zuschnitt:** sauber. Jeder der drei Commits trägt ausschließlich
  Architect-Artefakte — `525749b4` nur `docs/plan/adr/0109-…md` + `docs/plan/adr/README.md`;
  `cdaf7d52` nur `AGENTS.md`; `daa4aad2` nur `harness/conventions.md` +
  `harness/conventions/MR-098-…md` (`git show --stat` je Commit). Keine Mischmenge,
  jede Message nennt die Rolle und die Slice-Kennung. Die zwei Plan-Datei-Änderungen
  im Range (`eba1e691..daa4aad2`) stammen aus den slice-mv-Commits (`b3dd778d`,
  `eba1e691` — reine Move-/Verweis-Commits mit `slice-mv:`-Präfix), nicht aus dem
  Architect-Satz.
- **§3.4 / Supersedes:** kein Festlegungs-Gegensatz gefunden — ADR-0109 lässt
  ADR-0003 unangetastet (Tool-Build bleibt Docker-Only im gepinnten Image;
  belegt `docs/plan/adr/0003-…md:33-36`), berührt ADR-0083/ADR-0108/ADR-0099
  (Stempel/Fast-Pfad) inhaltlich nicht, und MR-026/MR-037/MR-050 (Adresse,
  Wellenlos-Default, no-cache-filter) werden von keiner der fünf Festlegungen
  still überschrieben. Kein Supersedes fällig.
- **§3.5 (Gate-Lockerung):** keine Schwellen-Senkung im Makefile/Skript — die
  Norm-Fassung in `AGENTS.md` §3.9 ruht komplett auf ADR-0109 (§5), der
  Befehlspositions-Verbot, Falsch/Richtig-Block und der „Grenze des
  Feedback-Quadranten"-Absatz mit dem Guard-Bewusstseins-Zitat („Bewusst NICHT
  geprueft …") stehen unverändert.
- **Referenz-Richtung:** der ADR-Körper nennt den Slice nur in der
  `Geschichte`-Tabelle (Kontext, keine Entscheidung über den Plan); Spec-Bezüge
  sind Basizitäts-Verweise mit expliziter Kopplungs-Deklaration; kein
  Spec-Wachstum ohne CR (siehe F-3-Abgrenzung).
- **Zitate gegen die Baseline (v7.0.0, `modul-14-docker-harness.md`):** alle
  zitierten Anker und Satzstücke vorhanden — „Der zweite Träger" (Z176),
  „Woher das Soll kommt" (Z218), „Prüfform je Werkzeug" (Z237), „Inventar,
  Stufen, Kontext" (Z266), „Zwei Formen des Belegs" (Z96), „Pin legt fest, Check
  belegt" (Z178), „Die Wahl ist eine Adaption der Baseline und steht als
  `MR-<NNN>`" (Z234f.), „das Repo deklariert seine Wahl in derselben `MR-<NNN>`"
  (Z286f.).
- **Pin-Stellen-Probe:** `GO_VERSION` ist maschinen-lesbar gepinnt (Dockerfile:10,
  Makefile:14); `DCHECK_DIGEST` steht in `d-check.mk` — die MR-098-Zuweisung
  „d-check-Binary ohne Pin-Stelle" führt keinen Widerspruch ein: der Digest pinnt
  das Image (Image-Weg), nicht ein Host-Binary; die Pin-Stellen-Aufzählung in der
  Begründung nennt `DCHECK_DIGEST` als *Image*-Pin-Stelle, das d-check-Binary
  als Host-Manifest-Werkzeug.
- **Anker-Audit:** `mr-098--die-umgebungs-zusage-trägt-mischform-die-dogfood-gates-und-lab-läufer-fahren-am-host`
  in `harness/conventions.md` (Z196, beide Anker-Formen) — identisch mit den
  Links aus `AGENTS.md` §3.9, ADR-0109 (Festlegungen 2, 3, 6), ADR-Index-Zeile
  und MR-098-Eintrags-Kopf; `mr-015`, `mr-053`, `mr-097` lösen (grep über
  `id="…"`). LH-Anker LH-QA-02/03/04/01 und LH-FA-06/10/11/12 vorhanden; die
  vier Superset-Zitate stimmen mit dem Lastenheft überein (Z155, Z298f.,
  Z483, Z563f. — LH-FA-12 nur zeilenumgebrochen); `#7-historie` löst.
  Stichprobe gegen LH-QA-03-Body (Z581f.): „der Bootstrap braucht nur git …
  `docker` ist Weg, keine Pflicht" — deckt die ADR-0109- und §3.9-Paraphrase.
- **MR-015-Verbot:** keine `spec/lastenheft.md`-Änderung in den drei Commits
  (Range-Diff eba1e691..daa4aad2); die CR-Fassung 0.28.0/0.28.1 stand vorher
  (Slice slice-cr-lh-qa-02-03-ohne-docker, eigener Commit-Standort) — das AGENTS
  §3.9-Zitat „Bootstrap-Laufzeit braucht git; docker ist Weg, keine Pflicht"
  folgt der CR-Fassung. Kein Code-/Makefile-/Skript-Änderung unter den drei
  Commits.
- **Plan-Abweichung:** die Zusammenführung der zwei geplanten MR-Einträge ist
  doppelt benannt — in ADR-0109 Festlegung 6 im ADR mit Baseline-Bindung
  („in derselben `MR-<NNN>`"), im MR-098-Eintrag unter `Begründung`; die
  DoD-Liefer-Punkte 1–3 korrespondieren mit den drei Commits.
- **Kein halluziniertes Target:** ADR-0109 nennt nur existierende Targets
  (`make docs-check`, mit dem Vorbehalt „Paarung entsteht mit der
  Inventar-Anbindung") und **vermeidet** ausdrücklich ein benanntes
  `make environment-check` mit dem Verweis auf LH-QA-01.

## Sensors

- Manuelle Pfad-Existenzproben und Anchor-Greps (kommandos in den Findings) —
  kein Gate-Lauf möglich (Docker-Daemon aus); `make gates` bleibt dem CI-Lauf
  auf dem Push als schließendem Netz überlassen. Commits unangetastet, kein Push.
