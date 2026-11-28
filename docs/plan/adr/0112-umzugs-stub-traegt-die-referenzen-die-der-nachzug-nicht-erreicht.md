# ADR-0112: Ein Umzugs-Stub bleibt am flachen Pfad eines bewegten Slices, wenn der Nachzug ihn nicht erreicht — die Referenz aus der ADR-Klasse löst weiter auf

**Status:** Accepted

**Datum:** 2026-11-28

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0061](0061-review-report-bekommt-beim-archivieren-einen-stub.md) (**Accepted** — die
Mechanik, die hier verallgemeinert wird: Stub am unveränderten Pfad statt ersatzlosem Löschen;
Festlegung 1 liefert die Formel *„ein eingehender Verweis löst weiter auf"*, die diese Entscheidung
auf eine fünfte Klasse anwendet),
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) (**Accepted** — Festlegung 1 erlaubt
den Nachzug in Zeitdokumente, Festlegung 2 nimmt [`docs/plan/adr`](../adr) daraus aus und Festlegung
3 trägt die zwei benannten Paare an ADR-0016; alle drei bleiben unverändert, kein `Supersedes`),
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md) (**Accepted** — die drei
Abnahme-Kriterien bleiben; Kriterium 1 (*„der fail-closed-Wächter schließt `docs/reviews/**`
nicht aus"*) bekommt mit dieser Entscheidung einen lebenden Gegenstand wieder),
[ADR-0041](0041-wellenloser-altbestand-geht-in-ein-sammel-archiv.md) (**Accepted** — der
Schlüssel, über dessen Ablage diese Messungen laufen),
[ADR-0111](0111-ci-stempel-eingecheckt-committed-je-check-keys.md) (**Accepted** — Nachbarschaft,
kein Berührungspunkt: diese Entscheidung berührt weder Stempel, Fast-Pfad noch CI),
[`MR-072`](../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form)
(die Adaption zur Report-Klasse — unverändert; diese Entscheidung erzeugt **keinen** neuen
MR-Eintrag, weil sie keine Baseline-Regel abweicht: die Umzugs-Mechanik ist
[ADR-0033](0033-wellen-archivierung-als-unterkommando.md)/[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md)-Fassung
dieses Repos),
[`AGENTS.md`](../../../AGENTS.md) §3.4 (die ADR-Klasse bleibt unanfassbar — der Grund, warum ein
Stub und kein Nachzug trägt), §3.5 (kein neues `ignore-refs`-Paar — die Stub-Alternative braucht
keine Senkung),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (kein Gate
dieses Repos hält einen Zeitdokument-Inhalt gegen die Adressen, die er nennt)

**Schärft:** — Prozess-ADR ohne Spec-Stratum. Sie ordnet die Stub-Formen der
Archivierungs-Operation, nicht eine Anforderung oder technische Festlegung.

---

## Kontext

Die Verbreiterung der Stub-Form auf die übrigen Hänger-Klassen wurde GO gegeben gegen eine
Klassen-Tabelle aus dem Altbestand-Vorschau-Lauf **vor** der ADR-0061-Umsetzung
(`ae6e6fbd`-Form: Report→Report 43 · Evidence 42 · `Accepted`-ADR 11 · Closure-Notizen/Carveouts 6
· `open/` 5 — alle fünf Klassen als **Report-Ziel**-Anteil von 107 Fundstellen). Am Ist (HEAD
`a23e4a06`) trägt diese Tabelle nicht mehr; die Nachmessung:

```sh
.harness/state/bin/ai-harness-init archive-welle --vorschau altbestand
#   wellenlos (seit der letzten Closure): 239 · Review-Reports (mit Stub): 399
#   Verweise: 315 Datei(en) betroffen (1015 Fundstelle(n)) — docs/plan/adr: 0
#   Sperren: keine — der schreibende Lauf liefe.
```

`Vorschau` übergibt dem Haenger-Wächter seit der ADR-0061-Implementierung `ziele=nil`
([`internal/archive/vorschau.go`](../../../internal/archive/vorschau.go)): nichts verschwindet
ersatzlos — jeder Report überlebt als Stub an unveränderter Adresse, und die 1015 Fundstellen der
fünf Bäume der Tabelle ziehen im Verweis-Nachzug (Zeitdokumente erlaubt nach
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 1). **Die 64 Rest-Fundstellen
der Auftrags-Tabelle sind an allen fünf Bäumen gelöst** — die Stub-Deckung der Report-Klasse reicht
aus den Quellen heraus, weil das Ziel nicht verschwindet: Akzeptiertes Negativ, die Prämisse
beschreibt den Stand vor dem Implementations-Slice.

**Der reale Rest trägt eine andere Ziel-Klasse.** Der Nachzug nimmt `docs/plan/adr` aus (Festlegung
2), die Haenger-Ziele sind leer, und kein `ignore-refs`-Paar deckt eine neue Stelle: Ein Verweis aus
einer `Accepted`-ADR auf eine bewegte Datei bricht nach dem Move laut — und kein Träger des Ist
deckt ihn:

```sh
while IFS= read -r b; do grep -coF "$b" "$f"; done   # Containment je ADR-Datei
# 0016: 2 (Code-Span, gedeckt je ADR-0042 Festlegung 3) · 0061: 1 · 0071: 2
# 0100: 2 · 0062: 3 (Evidence-Kopien) · 0102: 2 (Kennungs-Zitat)
```

Die Link-Form auf flaches `done/` ist an drei Dateien bestätigt: ADR-0061 Zeile 50
(`slice-216`), ADR-0071 Zeilen 49 und 132 (`slice-109`), ADR-0100 Zeilen 36 und 120
(`slice-d-check-sprung-v0930`) — 5 Fundstellen in 3 Dateien, nach dem Move tote Adressen in
Artefakten, die niemand überschreibt ([`AGENTS.md`](../../../AGENTS.md) §3.4).

## Entscheidung

**Wir wählen: Für genau die bewegten Slices, die ein Nachzug-nicht-erreichter Baum referenziert,
schreibt der Lauf einen Umzugs-Stub an der flachen Pfad-Adresse. Vier Festlegungen.** Zwei
Abweichungen vom Auftragsentwurf stehen damit in dieser Datei: die Verbreiterung gilt der
**Umzugs-Klasse** (Referenz aus `docs/plan/adr` auf eine bewegte Datei) statt der Report-Ziel-Klassen
der Tabelle (gemessen gelöst), und die Grenze läuft über das **Suchraum-Differenzial**, nicht über
eine Klassen-Liste der Quellen.

**1. Der Umzugs-Stub liegt an der ALTEN Adresse, die Ziel-Klasse ist die bewegte Datei.** Kriterium,
mechanisch an der Containment-Form des Haenger-Wächters: ein Basename aus
`b.Verschwindend()`, der in einer Datei aus `Suchraum(…)\SuchraumNachzug(…)` steht — heute allein
`docs/plan/adr`; entsteht ein vierter ausgenommener Baum, trägt das Kriterium ihn ohne neue
Entscheidung. Für jeden so referenzierten Umzug schreibt der Lauf einen Stub an
`done/<base>`, statt die Adresse leer fallen zu lassen. Damit gilt die Formel von
[ADR-0061](0061-review-report-bekommt-beim-archivieren-einen-stub.md) Festlegung 1 über alle
beteiligten Klassen hinweg: **ein eingehender Verweis auf eine bewegte Datei löst nach dem Lauf
weiter auf, gleich aus welchem Baum** — ohne Nachzug in die ADR-Klasse, ohne `ignore-refs`-Paar,
keine Senkung nach [`AGENTS.md`](../../../AGENTS.md) §3.5.

**2. Die Stub-Form: Umzugs-Zeiger statt Archiv-Zeiger.** Identität (H1), Umzugs-Zeiger auf die neue
Arbeitsbaum-Adresse (`done/<wave-id>/…` bzw. `done/altbestand/…`), Zustand (`Archiviert mit: <der
Schlüssel>`); der Volltext liegt byte-genau an der neuen Adresse — nicht nur im Zip. Die Vorlage
entsteht repo-eigen als Nachbar der Report-Vorlage,
`docs/plan/planning/archive-stub-umzug.template.md` (Form von <!-- d-check:ignore (Platzhalter-Pfad: die Vorlage entsteht im Implementer-Zug dieser Entscheidung) -->
[ADR-0061](0061-review-report-bekommt-beim-archivieren-einen-stub.md) Festlegung 2). `FormOK`
bekommt die Umzugs-Variante (Zuzugs-Zeiger statt `> **ARCHIVIERT**`-Zip-Zeiger — ein Stub mit
Umzugs-Zeiger und vollem Text wäre der Umzug, der nicht stattfand), und `ZuStagen` führt die neuen
Pfade — die Staging-Aufzählung bleibt explizit
([ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Abnahme-Kriterium 2,
[`internal/archive/anwenden.go`](../../../internal/archive/anwenden.go) `ZuStagen`).

**3. Die Vorschau nennt die Klasse; die Sperre bleibt auf ihrer Rolle.** `Vorschau` übergibt die
referenzierten Umzugs-Basenamen als Haenger-Ziele und meldet sie in einer Funde-Zeile je verweisender
Datei — damit ist im Vorher-Bericht sichtbar, was der Nachzug nicht erreicht und der Stub trägt. Die
`[haenger]`-Sperre behält ihre Rolle für ersatzlos gelöschte Klassen
([ADR-0033](0033-wellen-archivierung-als-unterkommando.md) Abnahme-Kriterium 1) und bleibt für diese
Klasse leer, weil der Lauf sie selbst trägt — fail-closed bleibt, weil die Funde-Zeile die Stub-Menge
als Pflicht vor den zwei Commits stellt: Ohne Stub-Mechanik im Werkzeug bricht der schreibende Lauf
an der Sperre.

**4. Was diese Entscheidung nicht tut.** Die drei Gegenformen aus
[ADR-0061](0061-review-report-bekommt-beim-archivieren-einen-stub.md) Festlegung 4 /
[ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 4 gelten für den
Umzugs-Stub unverändert — Zustandssatz neben der Adresse, Operand im Mess-Kommando, Abschnitts-Anker
auf einen gekürzten Stub; kein Sensor, Träger bleibt der Lauf, der schreibt. Die zwei
`ignore-refs`-Paare an ADR-0016 bleiben (ihr Rückbau wäre eine Schärfung ohne eigenen Träger; ihre
Restbreite fällt mit den Stubs, nicht durch sie). Kein Nachzug in die ADR-Klasse
([ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 unverändert), kein
`Supersedes` einer Accepted-ADR, kein emittiertes Ziel (Geltungsbereich dieses Repos), und die
Report-Ziel-Klassen der Auftrags-Tabelle bekommen keinen eigenen Stub-Apparat — gemessen gelöst,
Funde-Zeile oben.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun: die Umzüge fahren auf heutiger Form | kein Code, kein Artefakt | 5 tote Adressen in 3 `Accepted`-ADRs nach dem ersten Altbestand-Lauf; Reparatur unmöglich (§3.4), Reparatur per Paar eine Senkung je Stelle — die Warteschlange, die [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) §Kontext bereits einmal abgelöst hat, in einer neuen Klassen-Mischung |
| B — `ignore-refs`-Paare je ADR-Stelle (Muster [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 3) | der bekannte Mechanismus, kein Archiv-Eingriff | drei bis fünf neue Paare = drei bis fünf blind geschnittene Referenzen und je eine Senkung nach §3.5 mit eigener Begründungslast; die Adresse bleibt tot — der Leser-Bruch bleibt ungelöst, nur das Gate schweigt |
| C — Nachzug in die ADR-Klasse weiten | Ein Mechanismus, überall derselbe | verboten: [`AGENTS.md`](../../../AGENTS.md) §3.4; [ADR-0042](0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2 steht und trägt — keine Option, nur als Abwägung geführt |
| D — Umzugs-Stub für ALLE 239 Umzüge | kein Kriterium zu halten, jede künftige Referenz von innen heraus gedeckt | 234 zusätzliche Stub-Dateien ohne Konsumenten im Arbeitsbaum — das Negative aus [ADR-0061](0061-review-report-bekommt-beim-archivieren-einen-stub.md) §Konsequenzen (*„der Baumbestand behält so viele Dateien, wie er je hatte"*) auf die ganze Umzugsfläche gestreckt; das Differenzial-Kriterium kostet eine Messung, die das Werkzeug ohnehin führt |
| **E — Umzugs-Stub je referenziertem Umzug (gewählt)** | Kleinste Flächen-Änderung, die die Referenz trägt; dieselbe Mechanik wie ADR-0061, fünfte Klasse; keine Senkung, kein ADR-Write | Der Stub-Overhead wächst mit neuen ADR-Verweisen auf Slices — die Klasse ist messbar (Funde-Zeile), der Preis klein; drei Gegenformen bleiben offen (Festlegung 4) |

## Fitness Function

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test (`internal/archive`) | Ein Umzug mit ausgenommen-Baum-Referenz hinterlässt einen Stub an der flachen Adresse; ohne Referenz keinen; der Stub trägt Umzugs-Zeiger und Zustand, `ZuStagen` führt ihn | `make test` |
| d-check (`links`) | Ein ADR-Verweis auf einen umgezogenen Slice löst nach dem Lauf an der alten Adresse weiter auf | `make docs-check-host` |
| Go-Test (`internal/archive` `--vorschau`) | Die Funde-Zeile nennt je verweisende ADR-Datei die umzogene Ziel-Datei; ohne ausgenommene-Baum-Referenz ist die Zeile leer (ausgeschrieben) | `make test` |
| — | Die drei Gegenformen aus Festlegung 4 — kein Sensor | — |

## Re-Evaluierungs-Trigger

1. **Wenn eine Stub-Menge je Lauf über 50 Umzüge wächst** (Messung an der Funde-Zeile): dann trift
   das Differenzial die Umzugsfläche breiter als eine Urteils-Grenze, und die Variante D (alle
   Umzüge) ist gegen die Fläche neu zu wägen.
2. **Wenn die adoptierte Baseline eine eigene Form für umgezogene Zeitdokumente oder einen
   flachen Alt-Rest führt**: Re-Baseline-Lauf, ob die vendored Form die repo-eigene Vorlage ablöst
   (Form des [`MR-041`](../../../harness/conventions.md#mr-041--die-referenz-statt-kopie-setzung-für-ausfüll-templates-steht-jetzt-in-der-adoptierten-baseline)-Prinzips).
3. **Wenn ein Anker-Link auf einen Umzugs-Stub entsteht** (die dritte Gegenform real): Preis der
   Entscheidung neu beziffern, Form von
   [ADR-0061](0061-review-report-bekommt-beim-archivieren-einen-stub.md) Re-Evaluierungs-Trigger 1.
4. **Wenn ein Verweis aus einem Baum steht, den kein Suchraum dieses Pakets liest** (untracked,
   Symlink-Ziel): der Träger bleibt der Lauf, der ihn schreibt — das ist die Grenze der Deklaration
   ([`internal/archive/scan.go`](../../../internal/archive/scan.go) §`lies`), benannt, nicht
   geschlossen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-11-28 | **Accepted** | Architektur-Übergabe-Artefakt auf die Auftraggeber-Entscheidung vom 2026-11-28 (*„Verbreiterung der Stub-Form auf die übrigen Hänger-Klassen — die Rest-Zielgruppe des Altbestand-Ablage-Laufs"*). Die zwei Abweichungen vom Auftragsentwurf stehen im Kopf von §Entscheidung: die Ziel-Klasse ist die Umzugs-Referenz aus der ADR-Klasse (die Report-Ziel-Klassen der Tabelle sind am Ist gelöst, Messung §Kontext) und die Grenze läuft über das Suchraum-Differenzial statt über eine Klassen-Liste; beide sind Architektur-Form-Entscheidungen innerhalb des Auftrags, gemessen vor dem Schreiben |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0112` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
