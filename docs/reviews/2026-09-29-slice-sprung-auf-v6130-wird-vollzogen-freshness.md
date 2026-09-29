# Freshness-Durchgang `v6.9.0` → `v6.13.0` — Übergabe-Artefakt der Implementation

Vorgang: `slice-sprung-auf-v6130-wird-vollzogen` (Liefer-Punkt 2 des Plans). Übergabe an den
Architect: die Delta-Inventur je Release, die abgearbeitete Eintrags-Liste mit je einem Ausgang
(Schreiben ist Architect-Arbeit, `AGENTS.md` §3.8), das Ergebnis der Stichprobe und die Werte für
die §Baseline-Buchung. Regierende Fassung des Sprungs:
[ADR-0072](../plan/adr/0072-ziel-fassung-regiert-den-sprung-v6130.md) `Accepted`, Delta-Walkthrough
je Release (Festlegung 2); Delta-Basis `v6.9.0` (letzte Buchung = letzter Durchgang = zuletzt
vendorted Stand, ADR-0072 §Die Delta-Basis).

**Gemessene Werte für die Buchung** (ADR-0031 Festlegung 2, Drei-Teil-Form):

- Tag: `v6.13.0`, Datum des Vollzugs: 2026-09-29.
- sha256 des Release-Assets `lab-regelwerk.zip`, am Asset gemessen, drei Quellen, ein Wert:
  `b5151e77807e2affebb25cfab9be24b88cf43afc42c075db0b982a2ff1052b96`
  1. `curl -sL …/releases/download/v6.13.0/lab-regelwerk.zip | sha256sum` → der Wert; als
     Kontrolle derselbe Lauf gegen `v6.9.0` → `8a4e0aaf…`, byte-gleich dem bisherigen Pin.
  2. `gh api repos/pt9912/ai-harness-course/releases/tags/v6.13.0 --jq '.assets[].digest'`
     → `sha256:b5151e77…` (lab-regelwerk.zip).
  3. `gh release download v6.13.0 -R pt9912/ai-harness-course -p SHA256SUMS -O -` →
     `b5151e77…  lab-regelwerk.zip`.
- `make baseline-verify` nach dem Tausch → `baseline-verify: v6.13.0 OK — 54 Dateien
  (Integritaet + Vollstaendigkeit, netzlos)`.

## Achse und Range (im Klon K gemessen, feste Zahlen)

13 Welle-Commits; 27 Dateien (+313/−80); 0 neue, 0 entfallene Dateien — das Delta ist anpassend,
nicht strukturell. Release-Partition (aus ADR-0072 §Kontext, hier je Datei zugeordnet):

| Release | Wellen | Regelwerk (19) | Templates (8) |
|---|---|---|---|
| `v6.10.0` | 138–142 | README; `grundlagen-referenz-richtung`; `modul-00`, `-01`, `-03`, `-04`, `-05`, `-07`, `-09`, `-11`, `-12`, `-13` | `AGENTS.template`; `.d-check.yml`; `carveout.template`; `gate.template` |
| `v6.11.0` | 143–147 | README; `grundlagen-durchsetzungsschicht` (neu +16); `grundlagen-klassifikation`; `grundlagen-source-precedence`; `modul-02`, `-03`, `-06`, `-08` | `AGENTS.template`; `.d-check.yml`; `NNNN-titel.template`; `slice.template`; `conventions.template`; `lastenheft.template` |
| `v6.12.0` | 148–150 | README; `grundlagen-harness-dateien` (neu +14); `grundlagen-klassifikation`; `modul-05`, `-06`, `-08`, `-09` | `AGENTS.template` (+30/−11) |
| `v6.13.0` | 151–153 | `modul-04` (+33); `modul-06` (+11); README | — |

Thematische Zuordnung je Release (Lesung der Volltexte am Tag `v6.13.0`, geordnet nach der
Partition — ADR-0072 Festlegung 2):

- **v6.10.0 — Lesbarkeit und Abgrenzung.** Die Fehlannahmen-Listen von `modul-00`, `-01`, `-03`,
  `-04`, `-11`, `-12`, `-13` bekommen fette Gegenstands-Zitate vor unverändertem Regeltext (Form,
  kein Inhalt). Sachlich neu: Provenance-Historie nennt beim Vertrag den externen CR statt ADR/Slice
  (`grundlagen-referenz-richtung`); Validierung hat keine Station in der Artefaktkette (`modul-01`);
  User Story ist Slice-Klasse, kein Spec-Dokument (`modul-03`); die Größenregel zählt
  „**mehr als zwei** Schichten" statt „mehrere" (`modul-05` — Schwellen-Präzisierung der
  Slice-Größe); Carveout mit Schwelle nennt die ADR, die sie setzt, und die ADR-(permanent)-Ablage
  heißt `docs/plan/adr/<NNNN>-*.md` statt `docs/architecture/…` (`modul-07`); eine befristete
  Ausnahme für einen Teil ist Carveout, keine Senkung (`modul-09`).
- **v6.11.0 — Randbedingungen und Hard-Rule-Disziplin.** `LH-RB-<NN>` kommt als eigene
  Anforderungsreihe ins ID-Schema (`grundlagen-source-precedence`, `modul-02`, `modul-03`,
  Vorlagen); der Trigger-Audit bekommt eine **vierte** Klasse — Hard Rule mit Auflösungs-Trigger
  (`modul-06` wellenlose Tabelle + Welle-Closure Schritt 2, `modul-08`); neu sind zwei
  Verfallsformen *AGENTS.md-Wildwuchs* und *Guide-Datei-Wildwuchs* (`grundlagen-klassifikation`)
  und die Skelett-Regel: in Slash-Commands graduierte Regeln tragen Auflösungs-Trigger oder
  *permanent* (`grundlagen-durchsetzungsschicht`).
- **v6.12.0 — Bestand, WIP, Entropy.** Bestands-Lese-Schritt in der Welle-Closure: Slices in
  `open/`/`next/`, die eine Closure überstanden haben, werden erst gruppiert (konsolidiert /
  bestätigt / entfallen — `modul-06`); WIP-Limit gilt **pro Lauf**, `Verantwortlich:` trägt bei
  Parallel-Läufen Person und Zweig (`modul-05`, `modul-08`); der Index-plus-Datei-Schnitt
  (`harness/rules/<name>.md`) als Gegenmittel zum Guide-Datei-Wildwuchs
  (`grundlagen-harness-dateien`, `grundlagen-klassifikation`, `modul-09`).
- **v6.13.0 — ADR-Disziplin.** Neuer Abschnitt *Nachzug ist keine Überschreibung* in `modul-04`:
  Referenz-/Pfad-Nachzug und Template-Feld-Nachzug an `Accepted`-ADRs sind keine inhaltliche
  Überschreibung und brauchen keine Folge-ADR; neu die Fehlannahme, dass die Aufnahme eines
  bestehenden Wächters in `make gates` keinen eigenen ADR-Beleg braucht. `modul-06`: erreicht
  dieselbe Fehlerklasse ein **viertes** Mal die Schwelle, verlangt der neue Steering-Loop-Eintrag
  einen mechanischen Sensor oder die begründete Unmöglichkeit.

## Freshness-Durchgang über die 71 aktiven Einträge — Ausgänge (Vorschlag)

Frage je Eintrag (byte-gleicher Prozedur-Abschnitt): **Regelt eine der im Sprung geänderten
Regelwerks-Dateien das, wofür dieser Eintrag angelegt wurde?** Die 71 aktiven Einträge sind
abgearbeitet; geändert an der Grundgesamtheit ist nichts. **Kein Eintrag trägt *widerspricht*
oder *Bezug ist entfallen*; die Übernahme-Vorgabe (delta-gebunden, vollständig) bleibt unberührt.**

**A) Betroffen — geprüft mit Release-Attribution:**

| MR | Gegenstand | Ausgang (Vorschlag) | Anlass, Release |
|---|---|---|---|
| `MR-000` | Baseline-Aussage, ID-Schema ohne Segment für ADR/Slice | bleibt gültig | v6.11.0: `LH-RB-<NN>` erweitert die Vertrags-Reihe; die Aussage „kein Bereichssegment für ADR/Slice" ist davon nicht berührt. Stichprobe unten |
| `MR-002` | Gate-Nachweis-Mechanik | bleibt gültig | v6.13.0 `modul-04`: Gate-**Erweiterung** ist kein ADR-Anlass — regelt den Anlass, nicht die Nachweis-Mechanik (Working-Tree-Hash) des Eintrags |
| `MR-060` | Neues Pflichtfeld gilt für neue Einträge | bleibt gültig | v6.13.0 `modul-04` *Template-Feld-Nachzug*: die Baseline trägt dieselbe Doctrine jetzt selbst — der Eintrag bleibt, die Abweichung entfällt zum Gegenstand |
| `MR-057`/`MR-059` | Kennungs-Form: Name statt Nummer | bleibt gültig | v6.10.0/v6.11.0 Vorlagen-`.d-check.yml`: der slice-Token heißt jetzt `slice-[a-z0-9]+(-[a-z0-9]+)*` (Slug) — Upstream bestätigt die Setzung; am Wortlaut der Einträge ist nichts zu ändern |
| `MR-063` | Gegenmessung auf Nicht-Null-Basis | bleibt gültig | v6.13.0 `modul-04` (Gate-Erweiterung) ist die ADR-Anlass-Frage, nicht die Gegenmessungs-Pflicht des Eintrags |
| `MR-035`/`MR-056` | Auswahl im Auto-Kontext | bleibt gültig | v6.12.0 `modul-05`/`modul-06` (beide als Symlink in jedem Lauf): der neue Inhalt (WIP pro Lauf, Bestands-Lese-Schritt, Trigger-Audit 4. Klasse) berührt den Maßstab *Lauf-Berührung* nicht; ob die sechs geänderten Dateien künftig häufiger Lauf-berührend sind, ist Frage der Review, nicht des Maßstabs |

**B) Nicht betroffen — 65 Einträge:** alle übrigen. Gemeinsamer Befund der Lesung: Keine der
19 geänderten Regelwerk-Dateien regelt, wofür sie angelegt wurden — ihre Gegenstände (Vendor-Politik
`MR-007`, Doc-Gate-Schärfung `MR-001`, d-check-Pins `MR-009`…`MR-068`-Familie, Kommentar- und
Zahl-Belege `MR-025`/`MR-033`/`MR-051`, Archivierung `MR-072`, Hooks `MR-074`, i. d. R. Werkzeug-,
Form- oder Prozess-Setzungen) kommen in keinem der vier Release-Abschnitte vor. Die fünf Ausgänge
bleiben unverändert; *bewusst abweichend* entfällt im Instanz-Durchgang (delta-gebunden), und es
gibt keinen Eintrag, dessen Delta-Ausgang zu tragen wäre.

**Stichprobe gegen den Bestand (`MR-000`):** die Aussage „keine ADR-/Slice-Kennung mit
Bereichs-Segment" bleibt gemessen wahr —
`git grep -ohE '\b(ADR|CO|MR)-[A-Z]{2,}-[0-9]+|\bslice-[A-Z]{2,}-[0-9]+' -- '*.md' ':!.harness/baseline' | sort -u | wc -l`
→ **0**. Die einzige neue Kennungs-Reihe des Deltas (`LH-RB-*`) ist eine Vertrags-Reihe und
berührt die Deklaration nicht; das Repo führt keine `LH-RB-*`-Anforderung
(`spec/lastenheft.md` trägt nur `LH-FA-*`/`LH-QA-*`).

## Adress-Bestand des Tauschs (§1 des Plans, gemessen)

Vor dem Tausch: **133** Markdown-Links (`git grep -oE '\]\([^)]*\.harness/baseline/v6\.9\.0[^)]*\)'
-- <PS>` → 133) und **111** Inline-Code-Pfade (`…`[^`]*\.harness/baseline/v6\.9\.0[^`]*`…` → 111)
über dem Pfad-Scope des Plans. Urteile je Treffer-Klasse:

- **Adresse, nachgezogen im Implementations-Kontext:** die Links in `harness/sensors/slice-mv.md`,
  `harness/sensors/archive-welle.md`, `docs/plan/planning/{next/slice-114,open/slice-213,
  open/slice-214,adr/0061}`, die Inline-Adressen in `harness/sensors/docs-check.md`,
  `docs/plan/planning/open|next/*` (6 Dateien), `.claude/agents/implementer.md`,
  `.claude/commands/implement-slice.md` — die Ziele existieren am neuen Tag, die zitierten
  Abschnitte sind delta-unverändert.
- **Adresse, Architekt-/Reviewer-Kontext (Übergabe):** `harness/conventions.md` (25 Links, 4
  Inline), die `harness/conventions/MR-*.md` (~60 Links, ~10 Inline), `harness/migration.md`
  (39 Inline — das Instanz-Register wechselt auf die `v6.13.0`-Pfade),
  `.harness/skills/reviewer.md` (2 Links).
- **Datierte Mess-Aussage, bleibt (`MR-033`):** `docs/migrations/v6.9.0.md` (31 Inline — der
  Bericht des vorigen Sprungs; Muster: `docs/migrations/v6.8.0.md` trägt 28 `v6.8.0`-Nennungen und
  wurde beim letzten Sprung nicht nachgezogen); `internal/emit/templates.go`-Kommentare **bleiben
  nicht** — ihre beiden Kommandos sind Re-Proben („gilt für den jeweils aktuellen Satz") und sind
  auf `v6.13.0` nachgezogen, beide Proben neu gelaufen und leer; die drei
  `.d-check.yml`-Kommentare `(v6.9.0 · modul-05 …)` nennen den Stand der Regel-Übernahme — datiert,
  bleiben; `internal/emit/baumaussage.go`-Kommentar: Träger-Text ohne Tag.
- **Eingefroren (`AGENTS.md` §3.4), bleibt:** `docs/plan/adr/0065` (3 Inline, `Accepted`),
  `docs/plan/adr/0069` (1 Inline, `Accepted` — die `sed`-Probe zitiert den Stand, gegen den sie
  gemessen war; die Datei trägt keinen Link in den Baum, gemessen über
  `grep -o '](\.[^)]*\.harness/baseline'` je ADR). Der einzige Baseline-**Link** einer ADR neben
  `ADR-0013` (steht seit mehreren Sprüngen auf `v3.5.2` und ist heute grün) steht in
  `docs/plan/adr/0061` (`Proposed`, nicht eingefroren) — er ist Adresse und ist auf `v6.13.0`
  nachgezogen.
