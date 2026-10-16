# ADR-0093: Die Ziel-Fassung regiert den Sprung `v6.18.0` → `v6.18.1` — die umgeschriebenen Vorlagen-Adressen bleiben im Emitter unverändert stehen

**Status:** Proposed

**Datum:** 2026-10-16

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0091](0091-ziel-fassung-regiert-den-sprung-v6180.md) (der vorige Sprung; Form und Prozedur
werden gelesen, nicht abgeschrieben — **kein** `supersedes`: sie ist auf ihren Sprung geschlossen),
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3,
[ADR-0043](0043-ziel-fassung-regiert-den-sprung-v671.md) (Präzedenz: auch ein Patch-Stand bekam seine Entscheidung),
[ADR-0037](0037-bootstrap-stellt-den-tag-0-zustand-her.md) (Herkunft der Neutralisierungen),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-FA-09`](../../../spec/lastenheft.md#lh-fa-09--regelwerk-emittieren)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie wählt die normative Quelle eines Vorgangs und
fällt das Emissions-Urteil zu einer Adress-Form der Vorlagen.

**Kopplung:** wie [ADR-0082](0082-ziel-fassung-regiert-den-sprung-v6170.md) §Kopplung; der
ADR-Index die Zeile dieser Datei mit diesem Commit.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

`v6.18.1` ist ein Patch. `K` ist ein leeres Verzeichnis, in das das Release-Asset entpackt ist; es
liegt außerhalb des Repos. Der vendored Baum von `v6.18.0` ist der Vergleich.

```sh
shasum -a 256 lab-regelwerk.zip      # c3a256ed971b27c15286588760add53770c52766054641cdf8487db6524bed31
diff -r .harness/baseline/v6.18.0/regelwerk "$K/regelwerk" | grep '^[<>]' | grep -vc 'Quelle:'   # 4  (README: zwei Kurs-URLs)
diff    .harness/baseline/v6.18.0/regelwerk/modul-02-harness-bootstrap.md "$K/regelwerk/modul-02-harness-bootstrap.md" | grep '^[<>]' | grep -vc 'Quelle:'   # 0
diff -r .harness/baseline/v6.18.0/templates "$K/templates" | grep -c '^[<>]'                       # 14  (5 Dateien)
```

Das Regelwerk ändert keine Regel und die Prozedur des Freshness-Audits (`modul-02`) ist unverändert.
Die Vorlagen ändern ihre Adress-Form: jeder Inline-Pfad auf eine `*.template.md`, die im Vorlagen-Baum
liegt, trägt jetzt das Präfix `.harness/baseline/<tag>/templates/` (fünf Treffer in vier Vorlagen:
Reviewer-Skill, Closure-Note-Reviewer, `harness/README.md`, Konventionsspeicher); die `AGENTS`-Vorlage
trägt nur den neuen Tag in der Release-URL. `<tag>` ist dort kein Versehen: die Vorlagen führen das
Literal schon in `v6.18.0` an zehn Stellen.

## Entscheidung

### Festlegung 1 — Ziel-Fassung `v6.18.1`, Übernahme vollständig

Es regiert `v6.18.1`, mit derselben Begründung wie [ADR-0091](0091-ziel-fassung-regiert-den-sprung-v6180.md)
Festlegung 1 (Prozedur unverändert, Tag-Klammer [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)).
Keine neue Abweichung. Warum trotzdem eine ADR: [ADR-0091](0091-ziel-fassung-regiert-den-sprung-v6180.md)
nennt ihren Sprung und ist geschlossen; [ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 3
verlangt je Sprung eine begründete Entscheidung, und `migration.md` §1 führt je Sprung eine Zeile mit
ihrer ADR. Die ADR ist kurz, weil das Delta keine Regel trägt; der Planner-Vorschlag „keine neue ADR"
trifft die Regel-Frage und ist dort richtig.

**Kandidaten** des Freshness-Verdikts (A3, vor dem Entfernen von `v6.18.0/`) sind die aktiven Einträge,
die eine der fünf geänderten Vorlagen nennen; das Urteil fällt im Vollzug:

```sh
grep -lE 'reviewer\.template|closure-note-reviewer\.template|README\.template|conventions\.template|AGENTS\.template|gate\.template|review-report\.template|slice\.template|MR-NNN-titel' harness/conventions/*.md
# -> MR-008, MR-020, MR-026, MR-028, MR-029, MR-031, MR-034, MR-038, MR-045, MR-060, MR-072
```

### Festlegung 2 — Emission: die umgeschriebenen Adressen bleiben stehen, die Neutralisierungs-Zeile bleibt

Der Emitter ändert für den Sprung **nichts an der Behandlung der Adressen**. Gemessen am Wortlaut:
`conventionsPathRefOld` trifft am neuen Baum nicht mehr (Marker ist der Satzteil mit der Adresse von `MR-NNN-titel.template.md` ohne Präfix;
die Vorlage trägt jetzt `.harness/baseline/<tag>/templates/harness/conventions/…`); die Ersetzung wird
zum No-op, und das ist richtig: ihr Zweck war, eine baseline-relative Adresse zu entfernen, die im Ziel
nichts trifft ([ADR-0037](0037-bootstrap-stellt-den-tag-0-zustand-her.md)). Die neue Adresse trifft im Ziel, weil der Bootstrap den Baum dort unter
`.harness/baseline/<tag>/` ablegt.

`codepaths` meldet die neuen Adressen nicht. Gemessen am Pin `v0.86.1` über den emittierten Roots
`[spec, docs, harness]`, mit den Vorlagen `harness/README.md` und `harness/conventions` aus `K` als Datei
`harness/README.md` bzw. `harness/conventions.md` in einem Scratch-Repo:

```sh
docker run --rm --network none -v "$PWD:/repo:ro" ghcr.io/pt9912/d-check@sha256:3e0b9779… --config .d-check.yml
# -> d-check: 2 Datei(en) geprüft, 3 Befund(e)   — alle drei Pfade, die das Scratch-Repo nicht führt
#    (harness/mk/, spec/lastenheft.md, harness/conventions/); keine Zeile nennt `.harness/baseline/<tag>/…`
# Gegenprobe: ein angehängtes `harness/gibts-nicht.md` -> 4 Befunde, codepath-missing auf genau diese Zeile
```

Grund: `.harness` ist keine `root`; ein Pfad ohne `root` am Anfang bleibt still (so benennt es der
Kommentar der emittierten `.d-check.yml` am Pin). Der Reviewer-Skill liegt unter `.harness/**`, das
`scan.ignore` ausnimmt. **Verworfen:** den Tag beim Emittieren einsetzen — der Pfad löste im Ziel
auf, aber der Emitter bekäme eine zweite Ersetzung über fünf Fundstellen, und der emittierte Skill
wiche vom Vorlagen-Text ab, den `skillMeldung` gegen den liegenden Skill hält ([ADR-0084](0084-reviewer-skills-im-ziel-skip-if-present.md)). Eine neue
Neutralisierungs-Zeile hätte keinen Gegenstand. Die Zeile `conventionsPathRefOld` bleibt in der
Tabelle: sie gilt älteren Kurs-Ständen (`COURSE_TAG`); am Pin trifft sie **0**-mal, die Erwartung in
`test/neutralisierung-marker.bats` wird von `1` auf `0` gesetzt — dieselbe Lesart wie bei
`roadmapDoneLink`.

**Folge für das Beobachtungs-Register:** kein drittes Auftreten von
`vendored-vorlage-nennt-pfad-den-das-adoptierende-repo-nicht-fuehrt`. Die Klasse ist ein Pfad, den das
adoptierende Repo nicht führt; die neue Adresse führt es. Der Eintrag bleibt bei 2, offen.

**Akzeptiertes Negativ:** die Messung ist `codepaths` über zwei der vier Vorlagen am Pin `v0.86.1`
mit einem Scratch-Repo, nicht der Lauf im frischen Ziel. Den Ende-zu-Ende-Beleg trägt der Vollzug
(`make full-smoke`); färbt er rot, gilt Rückführung (b) des Slice, und der Architect urteilt neu.

### Folge-Arbeit und Schnitt

| Vorgang | Inhalt | Träger |
|---|---|---|
| Sprung-Slice | Vendoring `v6.18.1`, Pins, Mess-Tag, Adressen; `conventionsPathRefOld:0` in `test/neutralisierung-marker.bats`; Prüfung, ob `test/mutations/577-conventions-neutralisierung-faellt-im-ziel-aus.sh` am neuen Baum noch einen Treffer hat (sonst Fall entfernen oder neu verankern, [`MR-071`](../../../harness/conventions.md#mr-071)) und ob `internal/emit/*_test.go` den alten Wortlaut als Fixture führen | `slice-sprung-auf-v6181-wird-vollzogen` |
| Buchung §Baseline, `migration.md` §1 (Zeile zitiert diese ADR), Freshness-Verdikt über Festlegung 1 | wie ADR-0091 | Architect, mit dem Vollzug (A3) |

Kein d-check-Pin-Eintrag: der Pin `v0.86.1` liegt schon.

### Acceptance-Trigger

`Accepted` auf Weisung des Auftraggebers ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 1), ohne Reviewer-Runde: die ADR führt keine Regel, nur ein Urteil mit Messung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| **A — gewählt: Adressen stehen lassen, Zeile bleibt, Erwartung 0** | kein Emitter-Code; die Adresse löst im Ziel auf | Messung am Scratch-Repo, E2E erst im Vollzug |
| B — Tag beim Emittieren einsetzen | Pfad ohne Literal `<tag>` | zweite Ersetzung über fünf Fundstellen; Skill weicht vom Vorlagen-Text ab ([ADR-0084](0084-reviewer-skills-im-ziel-skip-if-present.md)); löst ein Problem, das `codepaths` nicht meldet |
| C — neue Neutralisierungs-Zeile | — | kein Gegenstand: die neue Adresse ist nicht falsch |
| D — Zeile `conventionsPathRefOld` streichen | Tabelle ohne No-op | verliert die Deckung für `COURSE_TAG` auf älteren Ständen; ändert Tabelle, `…_EineTabelle`-Test und Fall `577` ohne Anlass |
| E — keine ADR | kein Dokument | `migration.md` §1 hätte keine Zeile mit Entscheidung; Präzedenz ADR-0043/0044 spricht dagegen |

## Konsequenzen

- **Positiv:** der Patch-Sprung hat eine Entscheidung und der Emitter keinen neuen Code.
- **Negativ:** der Wächter `conventionsPathRefOld` hält am Pin nur noch „trifft 0"; ob das Ziel die
  Vorlagen-Adresse lesen kann, hält allein `make full-smoke` (Lücke, unten).
- **Darüber hinaus ändert diese ADR keine Datei außer sich selbst und dem ADR-Index.**

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| bats `test/neutralisierung-marker.bats` | `conventionsPathRefOld` trifft die Vorlage am Pin genau 0-mal (Erwartung nach dem Sprung); ein Marker, der wieder trifft, färbt die Zeile rot | `make test` |

**Lücke:** dass das frische Ziel die `<tag>`-Adressen ohne `codepath-missing` startet, hält kein
eigener Wächter; gemessen ist es hier am Scratch-Repo, Träger ist `make full-smoke` im Vollzug.

## Re-Evaluierungs-Trigger

- **`make full-smoke` startet am `v6.18.1`-Stand rot** durch eine dieser Adressen: Festlegung 2 ist neu
  zu urteilen (Option B).
- **Ein d-check-Pin nimmt `.harness` in die `codepaths`-Roots oder meldet Pfade ohne Root:**
  Festlegung 2 ist am neuen Pin neu zu messen.
- **Der nächste Sprung steht an**, oder `make baseline-freshness` meldet vor dem Vollzug einen neueren Tag.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-16 | Proposed | Architect-Lauf, Übergaben A1/A2 des Sprung-Slice |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0093` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
