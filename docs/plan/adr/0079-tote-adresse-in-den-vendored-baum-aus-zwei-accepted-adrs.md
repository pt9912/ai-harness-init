# ADR-0079: Die zwei `Accepted`-ADRs mit Adresse in den vendored Baum bekommen je ein Referenz-Paar — namentlich, baum-weit

**Status:** Proposed

**Datum:** 2026-10-06

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) (das baum-weite Ventil für drei
Zeitdokument-Bäume; Festlegung 3 verlangt für jeden weiteren Eintrag eine eigene ADR),
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (Festlegung 2: in einer
`Accepted`-ADR kein Byte, auch nicht an der Adresse),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) (Festlegung 3: Kennung statt Pfad im
einfrierenden Artefakt),
[ADR-0078](0078-ziel-fassung-regiert-den-sprung-v6160.md) (der Sprung, der die Adressen tötet),
[ADR-0075](0075-begruendungen-zu-spec-5-sammel-adr.md),
[ADR-0076](0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: Sie setzt eine Ausnahme in der Gate-Konfiguration.

## Kontext

Der Tausch auf `v6.16.0` entfernt den `v6.13.0`-Baum. Drei Markdown-Links in zwei
`Accepted`-ADRs zeigen hinein und fallen als `target-missing`:

```sh
git grep -c '\](\.\./\.\./\.\./\.harness/baseline/' -- docs/plan/adr/0075-*.md docs/plan/adr/0076-*.md
# docs/plan/adr/0075-begruendungen-zu-spec-5-sammel-adr.md:1
# docs/plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md:2
```

Beide Zeilen liegen im Kern (nicht unter `## Geschichte`). Ein Pfad-Nachzug ist darum doppelt
versperrt: [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 nimmt die
`Accepted`-ADR vom Nachzug aus, und `make adr-immutable` meldet jede Kern-Änderung. Das Baseline-Regelwerk
`modul-04-adrs.md` §Nachzug ist keine Überschreibung ließe die Adresse wandern; diese Lockerung
gegenüber [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) aufzunehmen, ist eine
eigene Frage (Option C unten) und nicht Gegenstand dieser Entscheidung.

Die Adressen hätten nach [`AGENTS.md`](../../../AGENTS.md) §3.11 nie entstehen dürfen: der vendored
Baum ist `<tag>`-gescopt und wandert mit jedem Sprung. Der Accept-Übergang hat das nicht gefangen;
kein Sensor hält Status und Adress-Form zusammen.

## Entscheidung

**1. Zwei Referenz-Paare, je eines pro Datei, extensional geschlossen.** `ignore-refs` in
`.d-check.yml` bekommt

- `in: "docs/plan/adr/0075-begruendungen-zu-spec-5-sammel-adr.md"`, `refs: [".harness/baseline/**"]`, `# Deckung: 1`
- `in: "docs/plan/adr/0076-ausgaenge-zu-spec-5-luecken-ebene-und-traeger-offener-saetze.md"`, `refs: [".harness/baseline/**"]`, `# Deckung: 2`

je mit Config-Kommentar und Zeiger auf diese ADR. Der `refs`-Wert ist baum-weit aus demselben Grund
wie in [ADR-0039](0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1: die
Eigenschaft ist *zeigt in ein `<tag>`-gescoptes Vendoring-Verzeichnis*, nicht *zeigt auf
`v6.13.0`* — ein tag-weiter Wert kostete bei jedem Sprung eine neue ADR. Die Restbreite ist
strukturell null: eine eingefrorene Datei bekommt keine zweite Referenz. Jeder weitere Eintrag
bleibt eine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5 mit eigener ADR.

**2. Die Konfigurations-Änderung ist Implementer-Arbeit**, diese Entscheidung ihr Constraint (wie
bei [ADR-0050](0050-geteiltes-ventil-ersetzt-die-datei-weite-ausnahme.md)).

**Akzeptiertes Negativ:** Die Ursache — eine `Accepted`-ADR mit Adresse in den vendored Baum —
bekommt keinen Sensor und keinen Folge-Slice. Der Bestand ist mit diesen zwei Dateien vollständig
(`git grep -l '\](\.\./\.\./\.\./\.harness/baseline/' -- 'docs/plan/adr/0*.md'` nennt nach dem
Nachzug außer der lebenden `Proposed`-ADR [ADR-0061](0061-review-report-bekommt-beim-archivieren-einen-stub.md) nur sie und [ADR-0013](0013-technik-stratum-als-zielort.md), die
[ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md) bereits trägt); Träger gegen
Neuzugang bleibt der Accept-Übergang nach §3.11. Tritt der Fall bei einem weiteren Sprung erneut
auf, ist das Re-Evaluierungs-Trigger 1.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — zwei exakte Paare, baum-weit (gewählt) | kleinste Breite, die trägt; hält über künftige Sprünge | zwei Konfig-Einträge mehr |
| B — ein Glob `in: docs/plan/adr/**` | ein Eintrag, deckt künftige Fälle | schaltet auch die Links der `Proposed`-ADRs stumm, die nachziehbar sind und deren Bruch ein echter Befund ist |
| C — Pfad-Nachzug nach `modul-04` §Nachzug ist keine Überschreibung | kein Ventil | verlangt eine Folge-ADR gegen [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 **und** eine Ausnahme im `vcs`-Kern-Vergleich, die das Werkzeug heute nicht führt — mehr Aufwand für drei Links |
| D — Links tot lassen | kein Aufwand | `make docs-check` bleibt dauerhaft rot ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) |

## Konsequenzen

- **Positiv:** `make docs-check` wird für diese drei Befunde grün, ohne einen Byte der zwei ADRs.
- **Negativ:** Die drei Links bleiben für Leser tot; ihr Text nennt das Modul weiterhin beim Namen.
- **Folgepflicht:** keine über Festlegung 2 hinaus.

## Fitness Function (falls maschinell prüfbar)

| Aussage | Sensor | Rot herstellbar durch |
|---|---|---|
| jedes Paar deckt genau die deklarierte Zahl | `test/ignore-refs-restbreite.bats` (in `make gates`) | `# Deckung: 1` am Paar von ADR-0076 statt 2 |
| die drei Links sind nicht mehr `target-missing` | `make docs-check` | Paar entfernen |

## Re-Evaluierungs-Trigger

1. Ein weiterer Sprung tötet eine Adresse in einer weiteren `Accepted`-ADR — dann ist die
   Ursache wiederkehrend, und ein Sensor am Accept-Übergang ist zu prüfen.
2. Option C wird für einen anderen Anlass entschieden — dann entfallen beide Paare.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-06 | **Proposed** | Architect-Lauf im Sprung `v6.13.0` → `v6.16.0`; offen für die Entscheidung des Auftraggebers |
