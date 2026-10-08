# ADR-0086: Ein erzeugtes Repo bekommt keine Eigentums-Aussage über seinen Anweisungssatz — die Regel führt der Adopter in seinem Konventionsspeicher

**Status:** Accepted

**Datum:** 2026-10-08

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (Boundary:
Adopter-Inhalt wird nicht überschrieben),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[ADR-0051](0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) (teilweise abgelöst,
siehe §Supersedes),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md),
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md),
[ADR-0084](0084-reviewer-skills-im-ziel-skip-if-present.md),
[ADR-0007](0007-bootstrap-phasen.md)

**Schärft:** [`ARC-006`](../../../spec/architecture.md#1-komponenten-übersicht) (Commands- und
Skills-Emitter: was er **nicht** schreibt — keine Eigentums-Aussage über die abgelegten Dateien).

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR);
`modul-08-agentenrollen.md` §Rollen-Regeln.

**Supersedes (Teil):** [ADR-0051](0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md),
und dort **genau einen Gegenstand** — die *delegierte Frage* in Festlegung 2 (zweiter Spiegelstrich
und der Satz *„Für das Ziel ist sie es nicht …"*) samt dem ersten Punkt von §Was diese Entscheidung
nicht tut. Festlegung 1 und die übrige Datei gelten fort.

---

## Kontext

[ADR-0051](0051-anweisungssatz-eigentum-traegt-ueber-die-emissionsgrenze.md) Festlegung 2 lässt
offen, ob ein **erzeugtes** Repo eine Eigentums-Aussage über seine Anweisungssatz-Artefakte bekommt;
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Folgepflicht 3 und
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) §Was diese Entscheidung nicht tut
delegieren dieselbe Frage. Ebene ist allein das **Ziel**; die Vorlagen dieses Repos ordnet
ADR-0051 Festlegung 1 zu.

Gemessen am Stand dieses Commits (keine Erwartungswerte,
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

```sh
git grep -l 'Dieser Command führt die' -- internal/emit/templates/commands/ | wc -l   # 3 — jede Vorlage nennt ihre ausführende Rolle
grep -rn 'Anweisungssatz' .harness/baseline/v6.17.0/regelwerk/*.md | wc -l            # 0
grep -rn 'claude/commands' .harness/baseline/v6.17.0/ | wc -l                         # 1 — Artefakt-Liste, ohne Rollen-Aussage
grep -c 'R aktualisiert Skill-Datei' .harness/baseline/v6.17.0/regelwerk/modul-08-agentenrollen.md   # 1
```

Jeder Ort, den ein Ziel für die Aussage böte, ist **skip-if-present** und gehört damit dem Adopter:
`.claude/commands/*.md` ([ADR-0007](0007-bootstrap-phasen.md) Festlegung 3),
`.harness/skills/*.md` ([ADR-0084](0084-reviewer-skills-im-ziel-skip-if-present.md)), `AGENTS.md`
und `harness/conventions.md` (Kurs-Vorlagen, eine Idempotenz-Klasse in `Templates`,
`internal/emit/templates.go`). Ein konvergentes, tool-eigenes Gefäß gibt es — das Fragment, das
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Festlegung 5 für einen Satz wählt —, es
ist aber **Mechanik**, keine Norm. Die adoptierte Baseline (`v6.17.0`) benennt für Command-Artefakte
keine schreibende Rolle. Für die Skill-Klasse trägt sie einen Satz — *„R aktualisiert Skill-Datei"*
(`modul-08-agentenrollen.md` §Konflikt-Pfad als Rollen-Sequenz) —, den
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) als Präzedenzfall für
`.harness/skills/reviewer.md` führt.

## Entscheidung

Wir wählen **D — keine Aussage**.

**1. Antwort.** Der Bootstrap schreibt in kein Artefakt des Ziels eine Eigentums-Aussage über dessen
Commands oder Reviewer-Skills — weder in die Instanzen noch in `AGENTS.md`,
`harness/conventions.md` oder ein Fragment. **Grund:** Wer welches Norm-Artefakt schreibt, ist
Rollen-Ordnung des **adoptierenden** Projekts. Eine Aussage dieses Repos wäre dort entweder ein
einmaliger Vorschlag in einer Datei, die dem Adopter gehört (ein Re-Lauf hält sie nicht), oder eine
Norm in einem tool-eigenen Mechanik-Gefäß. Für Commands liefert dafür weder Lastenheft noch Baseline
eine Quelle — sie reichte weiter als ihre Quelle. Für Skills liefert die Baseline sie bereits selbst:
der Skill-Satz aus §Kontext reist mit dem vendored Baum ins Ziel und bindet den Adopter dort über
seine eigene Baseline-Adoption; eine Aussage dieses Repos daneben wäre eine zweite Fassung, die
driftet. Was der Adopter darüber hinaus braucht, liegt bereits: jede Command-Vorlage nennt die
Rolle, die sie ausführt (Messung oben), und der Reviewer-Skill trägt seine Rolle im Namen.

**2. Ort, an dem der Adopter die Regel führt.** In **seinem** Konventionsspeicher — als Eintrag im
Adaptions-Block von `harness/conventions.md` oder als Hard Rule in seiner `AGENTS.md`. Beide legt
der Bootstrap nur an einem freien Pfad aus der vendored Kurs-Vorlage ab; ihren Inhalt schreibt der
Adopter. Ob er die Regel dieses Repos ([ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 1) übernimmt, ist seine Entscheidung.

**3. Geltungsbereich.** `.claude/commands/*.md` und `.harness/skills/*.md` im Ziel. **Nicht:**
`.claude/agents/*.md` ([ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Festlegung 3, [ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md) offen); nicht die
Vorlagen dieses Repos (ADR-0051 Festlegung 1); nicht der Gegenstand von
[ADR-0048](0048-eigentum-haengt-am-vorgang-nicht-an-der-datei.md) jenseits dieser Klasse. Die
Antwort ist für beide Artefaktklassen dieselbe; sie zerfällt nicht.

**4. Ablösung.** Die delegierte Frage aus ADR-0051 Festlegung 2 ist hiermit beantwortet (§Supersedes
oben). ADR-0028 Folgepflicht 3 und die Klausel der ADR-0048 delegieren nur und werden nicht
abgelöst; ihr Kern bleibt byte-gleich. Die Marke in der Index-Zeile von ADR-0051 setzt der
Accept-Übergang dieser ADR.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts entscheiden (Frage bleibt offen) | kein Aufwand | der nächste Lauf beantwortet sie faktisch (`BEO-ALL/eigentums-frage-ohne-quelle-wird-im-laufenden-vorgang-beantwortet`); ADR-0051 Re-Evaluierungs-Trigger 2 bleibt ohne Ausgang |
| B — Aussage in jede Command-/Skill-Vorlage | sichtbar am Artefakt | skip-if-present: erreicht nur frisch angelegte Dateien, ein Re-Lauf hält sie nicht; Norm ohne Quelle im Ziel; Arbeit am Werkzeug je Datei bei der ausführenden Rolle (ADR-0051 Festlegung 1) |
| C — Aussage in ein konvergentes, tool-eigenes Gefäß (Fragment oder Baum-Aussage) | ein Re-Lauf hält sie | setzt für Commands eine Rollen-Norm im fremden Repo, die weder Lastenheft noch Baseline trägt, und doppelt für Skills den Baseline-Satz; Mechanik-Gefäß für Norm-Text; neue Emission samt `full-smoke`-Stufe |
| **D — keine Aussage; der Adopter führt die Regel in seinem Konventionsspeicher** | kein Emissions-Aufwand; Eigentum bleibt dort, wo die Datei liegt; die ausführende Rolle steht schon in jeder Vorlage | ein Adopter, der die Regel will, schreibt sie selbst |

## Konsequenzen

- Positiv: die offene Hälfte der Grenze ist geschlossen, ohne Änderung unter `internal/emit/`.
- Negativ (akzeptiert): ein Ziel trägt keine Regel, wer seine Commands schreibt, bis der Adopter
  sie setzt; für Skills trägt es nur den Baseline-Satz.
- Folgepflicht: keine Emissionsänderung, kein Folge-Slice. Beim Accept: Marke in der Index-Zeile
  von ADR-0051.

## Fitness Function (falls maschinell prüfbar)

Lücke: Der Gegenstand ist eine **Abwesenheit** einer Norm-Aussage; kein Modul liest
Rollen-Zuordnungen, und ein Text-Grep auf ein Wort hielte die Formulierung, nicht die Eigenschaft
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Träger
ist diese Datei.

## Re-Evaluierungs-Trigger

- Ein künftiger Baseline-Stand benennt eine schreibende Rolle für Command-Artefakte oder verlangt
  für Command- oder Skill-Artefakte eine Eigentums-Aussage des erzeugenden Werkzeugs im Ziel — dann
  ist die Quelle da, und Option C neu zu prüfen. Beobachtet wird beim Baseline-Sprung durch Lesen
  der Rollen-Regeln in `modul-08-agentenrollen.md`; ein Wort-Grep hielte die Formulierung, nicht
  die Eigenschaft.
- Dieses Repo beginnt, ins Ziel eine ADR-Ablage oder eigene Adaptions-Einträge zu emittieren — dann
  existiert ein Ort, an dem es Eigentum regelt.
- Ein Adopter verlangt die Aussage per Change Request.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-08 | Proposed | `slice-adopter-seite-der-anweisungssatz-grenze` |
| 2026-10-08 | **Accepted** | Review `2026-10-08-adr-0086-review` (0 HIGH; MEDIUM und LOW eingearbeitet in `b1a8195d`), Annahme durch den Auftraggeber am 2026-10-08 ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0086` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
