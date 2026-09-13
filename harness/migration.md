# harness/migration.md — Instanz-Register und Report-Form für den nächsten Baseline-Sprung

## Zweck

Dieses Dokument leitet ab, es setzt nicht. Es hält zwei Dinge bereit: ein **Instanz-Register** —
je vendored Vorlage genau eine Zeile, welches Artefakt dieses Repos ihre Instanz ist, oder *keine
Instanz* mit Begründung — und die **Report-Form** für künftige `docs/migrations/<tag>.md`-Berichte <!-- d-check:ignore (geplante Ablage) -->
mit vier Ausgängen je Vorlage. Ein Report entsteht mit diesem Dokument nicht.

Jeder normative Punkt unten trägt die ADR, an der er belegt ist —
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md),
[ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md),
[ADR-0036](../docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md),
[ADR-0038](../docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md),
[ADR-0043](../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) und
[ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md). Was sich dort nicht
belegen lässt, steht in [§6 Offene Fragen](#6-offene-fragen) — benannt, nicht als Regel getarnt. Das
Dokument ist keine ADR und ersetzt keine der sechs Entscheidungen; es zitiert sie.

## 1. Regierende Fassung eines Sprungs

**Kriterium** ([ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 3):
Vor jedem künftigen Sprung wird gemessen, ob die **gepinnte** Fassung die Migrations-Prozedur
(den Freshness-Audit-Abschnitt der Baseline) führt. Führt sie ihn nicht, regiert die Ziel-Fassung
ohne neue Abwägung. Führen beide ihn, ist die Wahl offen und wird in jenem Sprung begründet
entschieden — eine allgemeine Regel *„es regiert stets die Ziel-Fassung"* besteht ausdrücklich
nicht.

**Prozedur ≠ Ist-Maßstab**
([ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 2): Bis der
vendored Baum getauscht ist, bleibt die gepinnte Fassung für **jede Konformitäts-Frage**
maßgeblich, unabhängig davon, welche Fassung die Prozedur des laufenden Sprungs stellt.

**Bisherige Anwendungen** — jede Zeile ist eine für ihren Sprung geschlossene Entscheidung, keine
löst die vorige ab:

| Sprung | Regierende Fassung | ADR |
|---|---|---|
| `v3.5.2` → `v5.12.0` | Ziel-Fassung `v5.12.0` | [ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 1 |
| `v5.12.0` → `v5.18.0` | Ziel-Fassung `v5.18.0` | [ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 1 |
| `v5.18.0` → `v6.0.0` | Ziel-Fassung `v6.0.0` | [ADR-0036](../docs/plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) |
| `v6.0.0` → `v6.5.0` | Ziel-Fassung `v6.5.0` | [ADR-0038](../docs/plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) |
| `v6.5.0` → `v6.7.1` (Ziel unerreichbar geworden, bevor ein Pin es trug) | Ziel-Fassung `v6.7.1` | [ADR-0043](../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 1, teilweise abgelöst durch [ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) |
| `v6.5.0` → `v6.7.2` (vollzogen) | Ziel-Fassung `v6.7.2` | [ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 1 |

Der aktuell vendored Stand ist `v6.7.2`
(`ls -1 .harness/baseline/` — kein Erwartungswert, wandert mit jedem Tausch); die
Zwei-Fassungen-Phase des letzten Sprungs ist geschlossen, und **kein** Ziel für einen siebten Sprung
ist gesetzt.

## 2. Ort und Form der Zielstand-Setzung

[ADR-0031](../docs/plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2:
Eine Zielstand-Setzung wird in [`harness/conventions.md`](conventions.md) §Baseline verbucht, in
der Re-Baseline-Aufzählung, mit einem geschlossenen Mindestumfang von **drei Teilen**, kein
vierter:

1. Ziel-Tag und Datum der Setzung bzw. ihres Vollzugs.
2. Der Slice, der den Delta-Nachweis führt, als Zeiger — der Nachweis selbst bleibt in jenem Slice.
3. Sonst nichts: kein Konformitäts-Urteil, keine Ausgangs-Liste, keine Begründung der Setzung.

Sie bekommt **keine eigene ADR**, keine Zeile in einer fremden §Geschichte und keinen zweiten
stehenden Ort. Wer den Zielstand bewegen darf, entscheidet diese Festlegung nicht — das bleibt
[ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Wer den Zielstand bewegt
vorbehalten (dem Auftraggeber).

## 3. Delta-Basis des Adaptions-Durchgangs

[ADR-0043](../docs/plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2, unverändert
angewendet durch
[ADR-0044](../docs/plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 2: Die
Delta-Basis der fünf Ausgänge des Adaptions-Durchgangs und der Stichproben-Komplementärmenge ist
**nicht** der zuletzt vendorte Stand, sondern der letzte Stand, für den
[`harness/conventions.md`](conventions.md) §Baseline einen Slice mit **gefülltem**
Delta-Nachweis-Feld ausweist. Fällt ein Durchgang aus, wächst die Basis weiter — die Regel
verhindert den Ausfall nicht, sie hält ihn nur sichtbar.

Gemessen am Stand dieses Dokuments trägt die letzte Zeile mit gefülltem Nachweis-Feld `v6.7.2`
(`grep -o '\*\*auf \`v[0-9.]*\`:\*\* [0-9-]*, Delta-Nachweis[^.;]*' harness/conventions.md` — die
Zeile mit `Delta-Nachweis in slice-224`, kein Erwartungswert). Für einen siebten Sprung wäre `v6.7.2`
damit die Basis, **solange** kein weiterer Durchgang zwischenzeitlich läuft.

## 4. Instanz-Register

Je Vorlage unter `.harness/baseline/v6.7.2/templates/` genau eine Zeile
(`find .harness/baseline/v6.7.2/templates -name '*.template.md' | wc -l` → **25**, kein
Erwartungswert — die Zahl wandert mit dem Tag). Die Zuordnung ist eine **Beobachtung am Bestand**,
keine ADR-Aussage: Die sechs Sprung-ADRs entscheiden über die regierende Fassung, nicht über die
Zuordnung Vorlage → Instanz (dazu [§6](#6-offene-fragen)).

| Vorlage | Instanz(en) in diesem Repo | Beleg / Begründung |
|---|---|---|
| `.harness/baseline/v6.7.2/templates/AGENTS.template.md` | [`AGENTS.md`](../AGENTS.md) | eine Instanz, Repo-Wurzel |
| `.harness/baseline/v6.7.2/templates/docs/plan/adr/NNNN-titel.template.md` | `docs/plan/adr/[0-9]*.md` | 46 Instanzen (`ls docs/plan/adr/[0-9]*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/docs/plan/adr/README.template.md` | [`docs/plan/adr/README.md`](../docs/plan/adr/README.md) | eine Instanz, derivativ ([ADR-0024](../docs/plan/adr/0024-derivatives-register-gehoert-der-rolle-seines-originals.md)) |
| `.harness/baseline/v6.7.2/templates/docs/plan/carveouts/carveout.template.md` | `docs/plan/carveouts/CO-*.md` (offen und `done/`) | 6 Instanzen (`ls docs/plan/carveouts/*.md docs/plan/carveouts/done/*.md 2>/dev/null \| grep -v README \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/docs/plan/carveouts/README.template.md` | `docs/plan/carveouts/README.md` | eine Instanz |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/archiv-stub-slice.template.md` | keine Instanz | dieses Repo hat noch keine Welle archiviert — `git ls-files 'docs/plan/planning/done/**/*.zip'` → leer (kein Erwartungswert); [`make archive-welle`](sensors/archive-welle.md) ist verdrahtet, aber gegen keine geschlossene Welle gelaufen |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/archiv-stub-welle.template.md` | keine Instanz | dieselbe Begründung wie die Zeile darüber — derselbe Vorgang erzeugt beide Stub-Arten gemeinsam |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/observation.template.md` | `docs/plan/planning/observations/BEO-*/**/observation.md` | 104 Instanzen (`find docs/plan/planning/observations -mindepth 2 -maxdepth 2 -type d \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/README.template.md` | `docs/plan/planning/README.md` | eine Instanz |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/reconciliation.template.md` | keine Instanz | Datei existiert nicht (`ls docs/plan/planning/reconciliation.md` → Exit 2, kein Erwartungswert); die berührte Sub-Area ist Greenfield und führt kein Reconciliation-Register |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/roadmap.template.md` | [`docs/plan/planning/in-progress/roadmap.md`](../docs/plan/planning/in-progress/roadmap.md) | eine Instanz |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/slice.template.md` | `docs/plan/planning/{open,next,in-progress,done}/slice-*.md` | 229 Instanzen (`find docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress docs/plan/planning/done -maxdepth 1 -iname 'slice-*.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/welle-results.template.md` | `docs/plan/planning/done/welle-*-results.md` | 12 Instanzen (`find docs/plan/planning/done -maxdepth 1 -iname 'welle-*-results.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/docs/plan/planning/welle.template.md` | `docs/plan/planning/welle-*.md` (offen) und `docs/plan/planning/done/welle-*.md` ohne `-results` | 15 Instanzen (3 offen + 12 in `done/`, `find docs/plan/planning -maxdepth 1 -iname 'welle-*.md' \| wc -l` und `find docs/plan/planning/done -maxdepth 1 -iname 'welle-*.md' ! -iname '*-results.md' \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/docs/reviews/review-report.template.md` | `docs/reviews/*.md` | 377 Instanzen (`ls docs/reviews/*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/harness/conventions/MR-NNN-titel.template.md` | `harness/conventions/MR-*.md` (aktiv und `done/`) | 59 Instanzen (55 aktiv + 4 `done/`, `ls harness/conventions/*.md \| wc -l` und `ls harness/conventions/done/*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/harness/conventions.template.md` | [`harness/conventions.md`](conventions.md) | eine Instanz, Index des Adaptions-Blocks |
| `.harness/baseline/v6.7.2/templates/harness/README.template.md` | [`harness/README.md`](README.md) | eine Instanz |
| `.harness/baseline/v6.7.2/templates/harness/sensors/gate.template.md` | `harness/sensors/*.md` | 15 Instanzen (`ls harness/sensors/*.md \| wc -l`, kein Erwartungswert) |
| `.harness/baseline/v6.7.2/templates/.harness/skills/closure-note-reviewer.template.md` | keine Instanz | dieses Repo führt bislang nur eine Skill-Datei (`ls .harness/skills/*.md \| wc -l` → **1**, kein Erwartungswert); Baseline-Regelwerk `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse verlangt diese Skill nur, wenn das Urteil inferential **und** aus keinem Artefakt ableitbar ist — bislang nicht eingetreten |
| `.harness/baseline/v6.7.2/templates/.harness/skills/reviewer.template.md` | [`.harness/skills/reviewer.md`](../.harness/skills/reviewer.md) | eine Instanz |
| `.harness/baseline/v6.7.2/templates/project-readme.template.md` | [`README.md`](../README.md) | eine Instanz, Repo-Wurzel |
| `.harness/baseline/v6.7.2/templates/spec/architecture.template.md` | [`spec/architecture.md`](../spec/architecture.md) | eine Instanz |
| `.harness/baseline/v6.7.2/templates/spec/lastenheft.template.md` | [`spec/lastenheft.md`](../spec/lastenheft.md) | eine Instanz |
| `.harness/baseline/v6.7.2/templates/spec/spezifikation.template.md` | [`spec/spezifikation.md`](../spec/spezifikation.md) | eine Instanz |

**Vollständigkeit** ist die Übereinstimmung der Zeilenzahl oben (25) mit
`find .harness/baseline/<tag>/templates -name '*.template.md' | wc -l`, `<tag>` aus
`grep -m1 '^BASELINE_TAG' Makefile` gelesen — nicht ein eingefrorenes Literal
([`MR-025`](conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2, [`MR-033`](conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
Eine Vorlage ohne Zeile ist der Befund, keine Auslassung.

## 5. Report-Form für `docs/migrations/<tag>.md`

<!-- d-check:ignore (geplante Ablage) -->
Ein künftiger Migrations-Report führt je Vorlage genau einen von **vier** Ausgängen — eine
geschlossene Menge, kein Freitext:

| Ausgang | Bedingung | Beleg-Art |
|---|---|---|
| **übernommen** | die neue Fassung der Vorlage ist in die Instanz(en) dieses Repos eingearbeitet | Commit-Hash |
| **schon erfüllt** | die Instanz(en) erfüllen die neue Fassung bereits, ohne Änderung | `diff`-Fundstelle (zeigt die Übereinstimmung) |
| **bewusst abweichend** | dieses Repo weicht von der neuen Fassung ab | `MR`-Kennung des tragenden Adaptions-Eintrags |
| **keine Instanz** | die Vorlage hat in diesem Repo keine Instanz (§4) | Begründung |

Report-Skelett je Vorlage:

| Vorlage | Instanz(en) | Ausgang | Beleg |
|---|---|---|---|
| `<Vorlagen-Pfad>` | `<Instanz-Pfad oder „—">` | übernommen / schon erfüllt / bewusst abweichend / keine Instanz | `<Commit-Hash / diff-Fundstelle / MR-Kennung / Begründung>` |

**Diese vier Ausgänge sind nicht die fünf Ausgänge des Adaptions-Durchgangs.** Der Freshness-Audit
der Baseline führt für den **Adaptions-Eintrag** (`MR-<NNN>`) fünf Ausgänge — *gegenstandslos ·
bleibt gültig · teilweise überholt · Bezug ist entfallen · widerspricht*
(zitiert in [ADR-0018](../docs/plan/adr/0018-ziel-fassung-regiert-die-migration.md) §Kontext). Die
vier hier gelten der **Vorlage** dieses Registers — zwei verschiedene Achsen, die nicht
ineinander übersetzt werden: dazu [§6](#6-offene-fragen).

## 6. Offene Fragen

- **Ob die sechs Sprung-ADRs eine Pflicht zum Führen des Instanz-Registers oder der Report-Form
  überhaupt tragen, ist gemessen offen.** Sie entscheiden über die regierende Fassung eines
  Sprungs, nicht nachweislich über die Zuordnung Vorlage → Instanz — sie nennen das Wort
  `templates` zwischen 0 und 16 Mal
  (`for f in 0018 0031 0036 0038 0043 0044; do grep -c templates docs/plan/adr/$f-*.md; done`, kein
  Erwartungswert), und eine bloße Nennung ist kein Beleg. §4 und §5 dieses Dokuments sind darum
  **keine** aus den sechs ADRs abgeleiteten Normen, sondern eine am Bestand gemessene Beobachtung
  bzw. eine Formvorgabe für einen künftigen Bericht.
- **Das Verhältnis der vier Report-Ausgänge zu den fünf Baseline-Ausgängen bleibt uneindeutig,
  solange niemand einen Durchgang gegen beide Mengen gleichzeitig fährt.** Sie messen
  unterschiedliche Gegenstände (Vorlage gegen Adaptions-Eintrag); ob ein künftiger Durchgang beide
  Register nebeneinander braucht oder eines das andere trägt, ist hier nicht entschieden.
- **Keine der sechs ADRs benennt, wer ein `docs/migrations/<tag>.md` schreibt oder wann.** <!-- d-check:ignore (geplante Ablage) -->
  Die Report-Form in §5 ist ohne einen solchen Anlass reine Vorbereitung.
- **Ob `harness/migration.md` selbst bei jedem Baseline-Sprung fortzuschreiben ist** (neue Vorlagen,
  entfallene Vorlagen, geänderte Instanz-Zuordnungen), sagt keine der sechs ADRs — sie sind
  Prozess-ADRs über die regierende Fassung, nicht über die Pflege dieses Dokuments.
