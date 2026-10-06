# Freshness-Durchgang `v6.13.0` → `v6.16.0` — Übergabe-Artefakt der Implementation

Vorgang: `slice-sprung-auf-v6160-wird-vollzogen` (Liefer-Punkt 2 und Adress-Teil von Liefer-Punkt 1).
Übergabe an den Architect: Delta-Inventur je Release, die abgearbeitete Eintrags-Liste mit je einem
Ausgang als **Vorschlag** (Schreiben ist Architect-Arbeit, `AGENTS.md` §3.8), die Stichprobe, die
Werte für die §Baseline-Buchung und die Adress-Liste je Eigentümer. Regierende Fassung:
ADR-0078 (`Accepted`), Festlegungen 2–4.

## Werte für die Buchung (ADR-0031 Festlegung 2)

- Tag `v6.16.0`, Datum des Vollzugs 2026-10-06, Tausch-Commit `f39b62d9`.
- sha256 von `lab-regelwerk.zip`, am Asset gemessen, drei Quellen, ein Wert:
  `feb4d7444c92ec4d11fcf88035ce2eaef48da64ae990eb8bbcf44550a5e87063`
  (`curl -sL …/releases/download/v6.16.0/lab-regelwerk.zip | sha256sum`;
  `gh api repos/pt9912/ai-harness-course/releases/tags/v6.16.0 --jq '.assets[] | .name + " " + .digest'`;
  `gh release download v6.16.0 -R pt9912/ai-harness-course -p SHA256SUMS -O -`). Kontrolle: derselbe
  `curl`-Lauf gegen `v6.13.0` → `b5151e77…`, byte-gleich dem alten Pin.
- `make baseline-verify` → `baseline-verify: v6.16.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)`.
- `make regelwerk-check` → `d-check: 2298 Datei(en) geprüft, 0 Befund(e)`.
- `make baseline-freshness` vor dem Tausch → `latest: v6.16.0` (kein neuerer Tag; Re-Evaluierungs-Trigger 2 von ADR-0078 feuert nicht).

## Delta-Inventur je Release (Kurs-Klon, `git diff --numstat <a> <b> -- lab/regelwerk lab/templates`)

| Release | Commits | Regelwerk (inhaltlich) | Vorlagen |
|---|---|---|---|
| `v6.14.0` | 3 | `modul-10` (7/2), `modul-15` (1/1) | `reviewer`, `closure-note-reviewer`, `review-report` |
| `v6.14.1` | 2 | `modul-10` (1/1: `BEO-<NNN>` → „Beobachtung") | `slice`, `welle-results`, `review-report`, `conventions` |
| `v6.15.0` | 2 | `grundlagen-begriffe` (1/1), `grundlagen-harness-dateien` (5/1), `grundlagen-referenz-richtung` (17/0), `modul-03` (4/1) | `NNNN-titel`, `adr/README`, `harness/README`, `gate`, `spezifikation` |
| `v6.16.0` | 5 | `grundlagen-begriffe` (1/0), `grundlagen-harness-dateien` (55/2), `modul-13` (11/3) | `AGENTS`, `harness/README`, `.d-check.yml`, `Makefile` |

Je Release dazu `regelwerk/README.md` (Stand-Zeile). Im vendorten Baum
(`git diff --no-index` zwischen beiden Bäumen) tragen alle übrigen Regelwerk-Dateien genau eine
geänderte Zeile — die `Quelle:`-Kommentarzeile mit dem Tag; inhaltlich geändert sind acht Dateien
(README, `grundlagen-begriffe`, `grundlagen-harness-dateien`, `grundlagen-referenz-richtung`,
`modul-03`, `modul-10`, `modul-13`, `modul-15`), wie ADR-0078 §Kontext.

Thematisch (Volltext-Lesung der geänderten Hunks am Tag `v6.16.0`):

- **v6.14.0 / v6.14.1 — Audit-Feld und Findings-Form.** `modul-15` §Span-/Audit-Attribut-Regeln:
  liefert die Quelle einen Wert nicht, ist das keine Abweichung — das Pflichtfeld bleibt Pflicht und
  ist als *nicht bekannt* gekennzeichnet, unter Nennung der Quelle. `modul-10`: kein Stil-Finding
  ohne Konventions-Anker, kein HIGH/MEDIUM ohne Failure-Szenario, `pfad` = Datei · Kurzzitat.
- **v6.15.0 — Werkzeug-Festlegungen in die Spezifikation.** `grundlagen-referenz-richtung`
  §Spec-Straten (neuer Absatz), `modul-03` (Ziel-Form Spezifikation um *Festlegungen der
  Harness-Werkzeuge*), `grundlagen-begriffe` (Zeile `harness/sensors/<target>.md`) und der letzte
  Hunk von `grundlagen-harness-dateien`: was ein Gate prüft und wie es an Randformen entscheidet,
  steht in der Spezifikation, nicht in Sensor-Datei, Skriptkopf oder gesperrter ADR.
- **v6.16.0 — Gate-Index mit Werkzeug-Teilen.** `grundlagen-harness-dateien` §harness/README.md als
  Einstiegspunkt (neuer Abschnitt *Ein Index, mehrere Eigentümer*), `modul-13` §Hard Rule
  (Doku-Disziplin), `grundlagen-begriffe` (Zeile `harness/mk/<werkzeug>.md`): Fragmente unter
  `harness/mk/` bringen ihren eigenen Index-Teil mit; der Sensor misst gegen die Vereinigung.

## Durchgang über die 77 aktiven Einträge — Ausgänge (Vorschlag)

`ls harness/conventions/*.md | wc -l` → 77. Frage je Eintrag (Prozedur-Abschnitt byte-gleich,
ADR-0078 §Stufe (a)/(b)): **Regelt eine der acht geänderten Regelwerk-Dateien das, wofür dieser
Eintrag angelegt wurde?** Lesereihenfolge: Kandidaten aus ADR-0078 Festlegung 3 zuerst, dann jeder
Eintrag, der eine der acht Dateien zitiert
(`grep -l '<datei>' harness/conventions/MR-*.md`), dann der Rest nach Gegenstand.

**A) Betroffen oder zitierend — geprüft:**

| MR | Zitiert / Gegenstand | Ausgang (Vorschlag) | Anlass |
|---|---|---|---|
| `MR-076` | `modul-15` §Audit-Span-Schema; Cache-Status `Optional` statt Pflicht | **widerspricht** — Übernahme vorgesehen, Rückbau erst nach der Umstellung | v6.14.0: genau der Fall (Quelle liefert den Wert nicht) ist jetzt keine Abweichung, das Feld bleibt Pflicht mit *nicht bekannt*. ADR-0078 Festlegung 4: der Eintrag bleibt aktiv, bis `slice-span-pflichtfeld-traegt-nicht-bekannt` umgestellt hat; dann hebt der Architect ihn auf |
| `MR-077` | `modul-15`; branch/commit statt PR-Nummer | bleibt gültig | Ersatzfeld, kein fehlender Wert (ADR-0078 Festlegung 3, Welle 154) |
| `MR-044`, `MR-021` | `modul-15`; ID-Spalte des Technik-Stratums, Span-Schema im Technik-Stratum | bleibt gültig | die Änderung betrifft den Leerwert eines Pflichtfelds, nicht Ort oder Form des Schemas |
| `MR-019` | `modul-03`, `grundlagen-referenz-richtung`, `modul-15`; Technik-Stratum als Rang 2 | bleibt gültig | v6.15.0 stärkt die Spezifikation als Ort (Werkzeug-Festlegungen) — bestätigt, verschiebt keinen Rang |
| `MR-075` | `modul-03` §Ziel-Form: Spezifikation; Spalte *Präzisiert* | bleibt gültig | v6.15.0 fügt §7 hinzu; der Eintrag gilt für jede künftige Festlegungs-Tabelle, also auch §7 (ADR-0078 Festlegung 3, Welle 158) |
| `MR-042` | `modul-03`, `grundlagen-referenz-richtung`; Anlass einer Lastenheft-Änderung | bleibt gültig | Historie wird in der Vorlage §8 statt §7 — Nummer, nicht Gegenstand; das Repo-Lastenheft ist keine Spezifikations-Instanz |
| `MR-001` | `grundlagen-referenz-richtung` §Referenz-Richtung (SDP) | bleibt gültig | der neue Absatz steht in §Spec-Straten; §SDP unverändert |
| `MR-010` | `modul-13` §Hard Rule; `d-check.mk` an der Wurzel | bleibt gültig | v6.16.0 regelt Fragmente unter `harness/mk/`; dieses Repo führt keines (`ls harness/mk` → Exit 2) — die Bedingung greift nicht |
| `MR-054`, `MR-080` | `modul-13` §Hard Rule; Modul-Aufnahme ins emittierte Doc-Gate, `authority` als Liste | bleibt gültig | die Vereinigungs-Regel ersetzt die drei Aufnahme-Kriterien nicht (ADR-0078 Festlegung 3, Welle 159); Träger `slice-targets-modul-im-emittierten-doc-gate` |
| `MR-011`, `MR-014`, `MR-024`, `MR-065` | `modul-13` §Hard Rule — zitiert *„Vorhanden ≠ behauptet"* bzw. *„Ein Gate ohne seine Grenze …"* | bleibt gültig | die zitierten Absätze sind unverändert; die Hunks fügen nur die Werkzeug-Teil-Klausel hinzu |
| `MR-002`, `MR-003`, `MR-056`, `MR-067` | `modul-13` andere Abschnitte (Guard-Härtung, Fitness Function) | bleibt gültig | Abschnitte ohne Hunk |
| `MR-005`, `MR-047` | `grundlagen-harness-dateien` Layout-Block; Ort `harness/tools/` | bleibt gültig | der Block bekommt die Zeile `harness/mk/`; `harness/tools/` unberührt |
| `MR-000`, `MR-009`, `MR-020`, `MR-029`, `MR-031`, `MR-032`, `MR-034`, `MR-038`, `MR-039`, `MR-045`, `MR-046`, `MR-053`, `MR-055` | `grundlagen-harness-dateien` §Konventionsspeicher bzw. §Was ein Kommentar trägt | bleibt gültig | beide Abschnitte ohne Hunk; die Hunks sitzen im Layout-Block, in §harness/README.md als Einstiegspunkt und im letzten Absatz zur Werkzeug-Grenze |
| `MR-025`, `MR-051` | `grundlagen-begriffe` (Zahl-Belege) | bleibt gültig | die Hunks ändern die Zeilen `harness/sensors/` und `harness/mk/` der Datei-Tabelle, nicht die zitierten Begriffe |

**B) Nicht betroffen — die übrigen Einträge:** keine der acht Dateien regelt ihren Gegenstand
(Vendor-Politik, d-check-Pins, Hooks, Archivierung, Kennungs-Form u. a.). **Kein Eintrag trägt
*gegenstandslos*, *teilweise überholt* oder *Bezug ist entfallen*; einer trägt *widerspricht*
(`MR-076`), mit dem in ADR-0078 Festlegung 4 schon entschiedenen Weg.** Ein Kandidat außerhalb von
Festlegung 3 ist nicht aufgetreten (Re-Evaluierungs-Trigger 3 feuert nicht).

Grenze: Teil B ist nach Gegenstand gelesen, nicht je Eintrag im Volltext; Teil A je Eintrag an der
zitierten Stelle.

**Stichprobe gegen den Bestand (`MR-076`):** `spec/spezifikation.md` §5, Zeile `SPEC-024`, führt
Cache-Status heute als `Optional` — der Widerspruch ist am Bestand sichtbar und wird mit dem
Folge-Slice aufgelöst, nicht in diesem Vorgang.

## Adress-Übergabe je Eigentümer (Liefer-Punkt 1.4/1.5)

Gemessen nach dem Tausch über dem Pfad-Scope aus §1 des Plans:
`git grep -oE '\]\([^)]*\.harness/baseline/v6\.13\.0[^)]*\)' -- <PS> | wc -l` → **146** Links,
`` git grep -oE '`[^`]*\.harness/baseline/v6\.13\.0[^`]*`' -- <PS> | wc -l `` → **114**
Inline-Pfade (vor dem Implementer-Nachzug); `make docs-check` nach dem Implementer-Nachzug →
**138** Befunde, alle in den Dateien unten. Ersetzung jeweils `baseline/v6.13.0` →
`baseline/v6.16.0`; Tag-Nennungen `` `v6.13.0` `` nur, wo sie den adoptierten Stand meinen.

**Architect** (`AGENTS.md` §3.8, ADR-0024):

| Datei | Links | Inline | Anmerkung |
|---|---|---|---|
| `harness/conventions.md` | 29 | 5 | dazu §Baseline/§Adoptierte Konventions-Quellen (Buchung, Release-URL, `baseline-verify`-Ausgabe) |
| `harness/conventions/MR-*.md` (69 Dateien) | 103 | 14 | Adressen; Tag-Nennungen in Mess-Aussagen nach `MR-033` je Treffer urteilen |
| `harness/migration.md` | 0 | 39 | Instanz-Register auf `v6.16.0`-Pfade; Sprung-Zeile §1 |
| `AGENTS.md` | 0 | 4 | §1 Messwerte am neuen Baum: `cat …/regelwerk/*.md \| wc -c` → **384237**, `ls …/regelwerk/*.md \| wc -l` → **26**, `readlink …` → **7**; §3.6 `grep -rl 'make mutate'` → **0**, `grep -c 'sicherheits- oder korrektheitskritischen'` → **1** |
| `docs/plan/adr/README.md` | 0 | 0 | 2 Tag-Nennungen in Titel-Zeilen von ADR-0072/0078 — Inhalt, keine Adresse, bleibt |
| `docs/plan/adr/0061-…` (`Proposed`) | 1 | 0 | nicht eingefroren, Adresse nachziehen |
| `docs/plan/adr/0075-…` (`Accepted`) | 1 | 0 | Link bricht mit dem Tausch; Entscheidung des Architect: Pfad-Nachzug (`modul-04` §Nachzug ist keine Überschreibung) oder Ventil nach §3.5 |
| `docs/plan/adr/0076-…` (`Accepted`) | 2 | 0 | wie 0075 |
| `docs/plan/adr/0074-…`, `0077-…` (`Accepted`) | 0 | je 1 | Inline, gate-unsichtbar; eingefroren, bleibt |
| `docs/plan/adr/0072-…`, `0078-…` (`Accepted`) | 0 | 0 | Tag-Nennungen sind der Gegenstand der ADR, bleiben |

**Reviewer** (ADR-0028): `.harness/skills/reviewer.md` — 2 Links.

**Bleiben (datierte Mess-Aussage oder eingefroren):** `docs/migrations/v6.13.0.md` (33 Inline, der
Bericht des vorigen Sprungs); der eigene Plan in `in-progress/` (8 Nennungen, Mess-Kommandos über
den Ausgangs-Tag); drei Zeilen in `slice-gliederung-der-instanzen-ohne-vorlagen-delta.md`.

**Reihenfolge.** Der alte Baum ist im Tausch-Commit entfernt; ihn bis zum Nachzug liegen zu lassen
macht `make baseline-verify` rot (`harness/tools/baseline-verify.sh`: *„mehr als ein
<tag>-Verzeichnis"*), wie ADR-0039 §Kontext feststellt. Zwischen Tausch und Architect-/Reviewer-Nachzug
ist darum `make docs-check` rot (138 Befunde); alle Commits gehören in **einen** Push, dessen Spitze
der letzte Nachzug ist.
