# ADR-0098: Die Auflösung von `CO-001` ist ein reiner Move mit Pfad-Nachzug — nur die zwei Links in einer `Accepted`-ADR bekommen ein namentliches Paar

**Status:** Proposed

**Datum:** 2026-10-21

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate mit
unbehebbarem Befund erzieht dazu, Rot zu überlesen),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) (Re-Evaluierungs-Trigger 1: die Auflösung von
`CO-001` wird *„in einer eigenen ADR"* entschieden — das ist sie; Festlegung 3 hält die Klasse an),
[ADR-0021](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Festlegung 5: *„der nächste Fall wird
einzeln entschieden, mit seiner eigenen Messung"*; zugleich die einzige betroffene `Accepted`-ADR),
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Festlegung 1: im Zeitdokument ersetzt
der Nachzug die Adresse; Festlegung 2: in der `Accepted`-ADR nichts; Festlegung 3: das namentliche
Paar, eingetragen vom Lauf des Moves),
[ADR-0070](0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) (unter
`docs/reviews/` nur die Link-Form),
[ADR-0092](0092-aufgeloeste-welle-zieht-per-move-nach-done-die-adresse-folgt-im-zeitdokument.md) (dieselbe
Form für einen Welle-Plan),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 4: die Entscheidung
vor dem Move),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl steht neben ihrem Kommando)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

**Abgrenzung — diese ADR supersedet keine.** Sie wendet [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
auf einen Carveout an und erfüllt den Trigger, den [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md)
für genau diesen Fall setzt. Sie nennt `CO-001` und seine Quellen bei der Kennung, nicht als
Pfad-Link ([`AGENTS.md`](../../../AGENTS.md) §3.11).

---

## Kontext

### Die Sonde

Der Move des Carveouts `CO-001` von `carveouts/` nach `carveouts/done/` ist fällig (sein Status-Kopf:
*Auflösung fällig*). Gemessen an einem frischen Klon außerhalb des Arbeitsbaums, `git mv`, dann
`make docs-check`:

```sh
git clone -q . .harness/state/sonde && cd .harness/state/sonde
git mv docs/plan/carveouts/CO-001-bats-shell-lint.md docs/plan/carveouts/done/
make docs-check > ../sonde.out
grep -E 'Datei\(en\)' ../sonde.out      # d-check: 2947 Datei(en) geprüft, 61 Befund(e)
grep -c 'target-missing' ../sonde.out                                    # 60  Markdown-Link
grep -c 'codepath-missing' ../sonde.out                                  # 1   Code-Span
grep -E 'target-missing|codepath-missing' ../sonde.out | cut -d: -f1 | sort -u | wc -l   # 30  Quelldateien
```

Die 61 Befunde nach Quelle und Status (Zählung je Datei: `… | cut -d: -f1 | sort | uniq -c`):

| Quelle | Dateien | Befunde | Status | Reparatur |
|---|---|---|---|---|
| `Accepted`-ADR ([`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md)) | 1 | 2 | nach §3.4 eingefroren | **keine zulässig** |
| `docs/reviews/` | 3 | 4 (alle Link-Form) | Zeitdokument | Nachzug, [ADR-0070](0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) |
| `docs/plan/planning/done/` | 19 | 25 (24 Link, 1 Code-Span) | Zeitdokument | Nachzug, [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) F1 |
| aufgelöster Carveout `CO-003` | 1 | 4 | Zeitdokument (`carveouts/done/`) | Nachzug, [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) F1 |
| lebend: Carveout-Index, `CO-002`, die bewegte `CO-001` selbst (12), zwei Slice-Pläne, die flache Welle-09-Datei | 6 | 26 | änderbar | Nachzug |

### Was die Slice-Planung noch nicht kannte

Der Schnitt nannte *„rund 40 überwiegend eingefrorene Quellen"* und las sie als gesperrt. Gemessen
sind es 30 Dateien, und **29 davon sind reparierbar**: [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 1 (nach dem Schnitt angenommen) hat entschieden, dass der Nachzug eines Prozess-Moves in
`docs/plan/planning/done/`, `docs/reviews/` und `docs/plan/carveouts/done/` die Pfad-Adresse ersetzt —
*„die Aussage ist danach dieselbe"*. Gesperrt bleibt allein die `Accepted`-ADR (Festlegung 2 dort):
zwei Links in [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md).

### Der Nachzug, gemessen — und das Paar mit beiden Skopen an einer roten Gegenprobe

Im selben Klon: der Pfad-Nachzug mit `sed` in den 29 Dateien (Carveout-Verzeichnis → `done/`;
in der bewegten Datei jedes `](../` → `](../../`; im Index und in `CO-002` die Geschwister-Form), dann
je ein `make docs-check`. Das Paar wurde im Klon in `.d-check.yml` eingetragen, danach der Klon
verworfen (Arbeitsbaum unberührt: `git status --short | wc -l` → 0).

| Zustand des Klons | `make docs-check` |
|---|---|
| nackter Move | `2947 Datei(en) geprüft, 61 Befund(e)` |
| plus Nachzug in 29 Dateien | `2947 Datei(en) geprüft, 2 Befund(e)` — beide in [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) |
| plus Paar (Festlegung 3) | `2947 Datei(en) geprüft, 0 Befund(e)` |
| Gegenprobe Quell-Skopus: `in` = eine andere ADR | `2947 Datei(en) geprüft, 2 Befund(e)` |
| Gegenprobe Ziel-Skopus: `refs` = der aufgelöste Ort (mit `done/`) | `2947 Datei(en) geprüft, 2 Befund(e)` |

Die geprüfte Datei-Zahl steht in allen fünf Läufen bei 2947: das Referenz-Ventil nimmt keine Datei aus
dem Prüfbereich.

### Die Paar-Zahl

```sh
awk '/^ignore-refs:/{f=1;next} f&&/^[^ #]/{f=0} f&&/^  - in:/' .d-check.yml | wc -l    # 9
```

Das neue Paar wäre das zehnte. Die neun bestehenden sind je extensional geschlossen
([ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md),
[ADR-0034](0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md),
[ADR-0079](0079-tote-adresse-in-den-vendored-baum-aus-zwei-accepted-adrs.md)).

### Der Rest ist leer, und er wächst nicht

```sh
git grep -cE '\]\(\.\./carveouts/CO-001-[^)]*\)' -- 'docs/plan/adr/[0-9]*.md'      # docs/plan/adr/0021-…md:2
git grep -lE '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' | xargs grep -L '^\*\*Status:\*\* Accepted' | wc -l   # 0
```

Eine `Accepted`-ADR bekommt keine zweite Referenz; Festlegung 3 von
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) verbietet ab dort den Pfad-Link auf einen
Carveout in jedem einfrierenden Artefakt. Die Restbreite des Paares ist strukturell null.

## Entscheidung

**Wir wählen G: reiner `git mv`, danach Pfad-Nachzug in allen änderbaren und Zeitdokument-Quellen,
und ein namentlich geschnittenes `ignore-refs`-Paar für die zwei Links in [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md).** Vier
Festlegungen.

**1. Der Carveout wandert per reinem `git mv` nach `carveouts/done/`.** Der Zustand ist die
Verzeichnis-Position (Baseline-Regelwerk `modul-07-carveouts.md` §Ziel-Form: Carveout, *„Auflösung
ist ein `git mv` nach `done/`"*). Kein Stub am alten Ort, kein neuer Trigger, kein Zurücknehmen —
Gründe in der Alternativen-Tabelle. Der Move liegt in einem eigenen Commit
([`AGENTS.md`](../../../AGENTS.md) §3.3) und **erst nach der Annahme dieser ADR**
([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4).

**2. Der Nachzug ist der zweite Commit und ersetzt die Pfad-Adresse in 29 Dateien** — nicht in
[`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md). Gebunden sind die Formen aus [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 1 und [ADR-0070](0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
(unter `docs/reviews/` nur die Link-Form; heute sind alle vier Befunde dort Link-Form). In der bewegten
Datei gilt die Ruheort-Regel (Pfade so, wie sie vom neuen Ort auflösen). Ein Werkzeug gibt es nicht —
`make slice-mv` bedient Slices —; der Nachzug ist Handarbeit, sein Maß `make docs-check`. Der Zustandssatz
neben einer Adresse (*„liegt in `carveouts/`"* in einem Report) bleibt stehen
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4); ein akzeptiertes Negativ,
das nicht wiederkehrt, weil die Quellen eingefroren sind.

**3. `.d-check.yml` bekommt genau ein weiteres Top-Level-`ignore-refs`-Paar, beide Skopen namentlich:**

```yaml
  # Deckung: 2
  - in: "docs/plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md"
    refs: ["docs/plan/carveouts/CO-001-bats-shell-lint.md"]
```

**und keinen weiteren.** Es ist eine **Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5** — der
Prüfbereich verliert zwei Links, die dieses Repo schreibt — und eine Auftraggeber-Entscheidung. Der
Config-Kommentar nennt seinen ganzen Gegenstand (die zwei Links in dieser einen ADR, Zeilen im Kontext
der Quelle) und zeigt auf diese ADR; `# Deckung: 2` hält `test/ignore-refs-restbreite.bats` in beide
Richtungen. Eingetragen wird es **vom Lauf, der den Move vollzieht, im Nachzug-Commit**, nicht vorher
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 3). Die Aufnahme-Grenze der
neun Vorgänger gilt unverändert: jeder zusätzliche Eintrag, jedes Glob, jede Verbreiterung ist eine
neue Senkung mit eigener ADR — auch bei gleicher Bedingung. Diese ADR erhöht die Zahl der Paare um
eins, nicht die der Entscheidungen, die ein elftes braucht.

**4. Die Reihenfolge ist Vorbedingung des ausführenden Slice, und der Beleg nennt, was angefasst wird.**
Move und Nachzug beginnen erst mit dem Status `Accepted` dieser ADR. Die Vorbedingung der Auflösung
selbst — Gate-Ausnahme zurückgenommen, `make gates` ohne sie grün (Status-Kopf von `CO-001`, Modul 7) —
trägt die DoD von `slice-113`; diese ADR setzt sie nicht außer Kraft. Der Nachweis ist `make docs-check`
mit **0** Befunden im Nachzug-Commit (Datei-Zahl 2947 in der Sonde; im Arbeitsbaum höher, weil diese Datei
mitzählt, kein Erwartungswert). Der Beleg des Move-Laufs nennt die angefassten Dateien — 29 im Nachzug plus `.d-check.yml`
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 5). Ein Wächter für die
Reihenfolge existiert nicht (kein Doku-Gate-Modul liest Lifecycle-Reihenfolgen, wie bei
[ADR-0092](0092-aufgeloeste-welle-zieht-per-move-nach-done-die-adresse-folgt-im-zeitdokument.md)); Träger ist der Plan-Text.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — `CO-001` bleibt ortsfest mit neuem Trigger | keine gebrochene Adresse, keine Senkung | der Trigger ist eingetreten; ein fälliger Carveout im aktiven Verzeichnis ist Modul 7s *„zweite Lüge"*. Den Zug für *aufgelöst* hat [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Alternative D bereits verworfen (Baseline-Abweichung, entschiede den Fall im Voraus) |
| B — Ventil/Glob für die eingefrorenen Quellen (`docs/reviews/**`, `done/**`, `carveouts/done/**`) | kein Nachzug nötig | Senkung über ~27 Dateien, die [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1 **reparieren** lässt; dort ausdrücklich verworfen (*„weniger prüfen"*). Ein `done/**`-Glob wächst mit jedem Slice-Closure |
| C — nur die Kennungs-ADR *„Carveout-Adressen in eingefrorenen Artefakten stehen per Kennung"* | — | existiert bereits: [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Festlegung 3 und [`AGENTS.md`](../../../AGENTS.md) §3.11. Sie bindet den Schreiber, heilt aber keinen Bestand; ohne Nachzug und Paar bleiben 61 Befunde |
| D — Stub am alten Ort (Muster der Archiv-Stubs) | alle 61 Adressen lösen auf, keine Senkung | der Archiv-Stub liegt in **demselben Zustand** wie sein Original (`done/`); ein Stub in `carveouts/` signalisiert *aktiv*, Modul 7 kennt ihn nicht (Baseline-Abweichung mit Adaptions-Eintrag, [`MR-046`](../../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht): die Position ist binär) — ein Dauer-Artefakt für **zwei** Links, die ein Paar billiger deckt. Bleibt die Rückfalloption, falls der Auftraggeber keine Senkung will |
| E — nackter Move, Rot stehen lassen | nichts zu tun | 61 Befunde, 59 davon reparierbar; ein Dauer-Rot ist kein Sensor ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |
| E2 — `scan.ignore` auf [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (Datei-Achse) | eine Zeile, ein bereits geführter Schlüssel | nimmt die **ganze Datei** aus dem Prüfbereich statt zwei Links (Datei-Zahl sinkt, [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Alternative E); von G dominiert |
| F — Nachzug auch in [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) | 0 Befunde ohne Senkung | Byte-Änderung an einer `Accepted`-ADR: [`AGENTS.md`](../../../AGENTS.md) §3.4, von [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 ausgenommen; die Einschränkung von §3.4 hat [ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) Alternative G verworfen. Ein Folge-ADR mit `supersedes` ändert den Wortlaut von [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) nicht |
| **G — gewählt: Move, Nachzug in 29 Dateien, ein Paar für [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md)** | 59 von 61 Befunden heilen statt zu schweigen; die Senkung ist die kleinste mögliche (zwei Links, strukturell null Restbreite, Datei-Zahl unverändert); nutzt entschiedene Regeln statt neuer Form | eine weitere Senkung nach §3.5, das zehnte Paar; Handarbeit am Nachzug; die Reihenfolge hält kein Sensor |

## Konsequenzen

- **Positiv:** `make docs-check` bleibt nach dem Move bei 0; die Zeitdokumente behalten ihre Aussage und
  bekommen die richtige Adresse; kein Baum verlässt den Prüfbereich.
- **Negativ:** ein weiteres Paar, dessen Aufnahme-Grenze nur prozessual hängt (§3.5 hat keinen Sensor).
- **Folgepflicht (Implementer von `slice-113`):** Move-Commit, Nachzug-Commit mit dem Paar samt
  Kommentar, danach `make docs-check` (0 Befunde, Datei-Zahl vor und nach dem Paar gleich) und
  `make test` (das Paar vom Restbreite-Wächter gedeckt; `Deckung: 3` einmal rot sehen,
  [`AGENTS.md`](../../../AGENTS.md) §3.6). Beide Commits in denselben Push.
- **Folgepflicht (Implementer von `slice-113`, derselbe Nachzug-Commit):** der Absatz *„GRENZE, keine
  Regel"* im Kopfkommentar des `ignore-refs`-Blocks von `.d-check.yml` zählt die geschlossene Menge der
  Paare auf und stimmt mit dem zehnten Paar nicht mehr; er wird um dieses Paar nachgezogen. Die Datei
  schreibt der Implementer, nicht diese ADR.
- **Folgepflicht (Planner):** `slice-113` nennt diese ADR als Vorbedingung (§4-Start-Trigger) und den
  `docs-check`-Nachweis im Move-Punkt; die Prämisse *„rund 40 überwiegend eingefrorene Quellen"* in
  `slice-141` und `slice-113` ist durch die Messung hier ersetzt.

**Entscheidungen des Auftraggebers.** (1) Annahme dieser ADR einschließlich der Senkung aus
Festlegung 3 (ein Paar, `Deckung: 2`) — Empfehlung: annehmen; es gibt keine Option ohne Senkung, die
weder Modul 7 noch §3.4 verletzt oder rot bleibt, außer D. (2) Falls (1) abgelehnt wird: D (Stub am
alten Ort samt Adaptions-Eintrag) statt des Paares — Empfehlung: nicht vorab; erst auf Ablehnung.

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links`, `codepaths` | nach Move, Nachzug und Paar 0 Befunde; der nackte Move ist rot (61), das Paar mit falschem `in` oder falschem `refs` ebenso (je 2, oben gemessen) | `make docs-check` |
| bats `test/ignore-refs-restbreite.bats` | jedes Paar deckt genau seine deklarierte Zahl Links (`Deckung: 2`) | `make test` (in `make gates`) |

**Lücke:** die Reihenfolge *Entscheidung vor Move* und die Commit-Trennung hält kein Sensor; ebenso
die Aufnahme-Grenze für ein elftes Paar (Hard Rule §3.5 ohne Sensor). **Ebenso hält kein Wächter den
Inhalt des Config-Kommentars:** `internal/ausnahmegrund` lässt ein Paar ohne Kommentar durch, dass der Kommentar
„den ganzen Gegenstand nennt", ist Zusage des Implementers und Prüfpunkt des Reviews. Der Restbreite-Wächter zählt nur
die Markdown-Link-Achse; [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) trägt keinen Code-Span auf den Pfad (`grep -c 'CO-001-bats' docs/plan/adr/0021-*.md` → 2, beide Link-Form).

## Re-Evaluierungs-Trigger

- **Wenn ein weiterer Carveout aufgelöst werden soll, auf den eine `Accepted`-ADR als Pfad-Link zeigt**
  (Bestand heute: `git grep -lE '\]\(\.\./carveouts/(done/)?CO-[0-9][^)]*\)' -- 'docs/plan/adr/[0-9]*.md' | xargs grep -l '^\*\*Status:\*\* Accepted' | wc -l` → 5 Dateien; `CO-001` ist
  durch diese ADR entschieden, `CO-002` ist ortsfest): dann ist das ein neuer Einzelfall mit eigener Entscheidung.
- **Wenn [`AGENTS.md`](../../../AGENTS.md) §3.4 eingeschränkt wird:** dann ist das Paar zurückzunehmen
  und der Nachzug in [`ADR-0021`](0021-verbrauchs-achse-je-rolle-ohne-quelle.md) nachzuholen.
- **Wenn die Baseline den `done/`-Move bei Auflösung nicht mehr verlangt:** dann fällt der Auslöser.
- **Wenn der gepinnte d-check das geteilte `ignore-refs` verliert:** dann kehren die zwei Befunde zurück.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-21 | Proposed | Architect-Lauf zu `slice-141`; die Annahme ist Auftraggeber-Entscheidung ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-NNNN` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
