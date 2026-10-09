# ADR-0089: Span-Dateien sind nur für den Eigentümer lesbar — die Nicht-Zusage über den Bestand nennt den Modus

**Status:** Accepted

**Datum:** 2026-10-09

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang)
(Kriterium *Redaktion*, Lastenheft `0.26.0`),
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren),
[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (teilweise abgelöst, siehe
§Supersedes), [ADR-0011](0011-telemetrie-erfassung-policy.md),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

**Supersedes (Teil):** [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 6, Stück 3, die Wendung *„nicht zugriffsbeschränkt"*. Alles Übrige jener Festlegung gilt
fort — *gitignored*, *nicht verschlüsselt*, *Pfadnamen nicht als unkritisch zugesagt*.

---

## Kontext

[ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6 Stück 3 schreibt
ins Ziel den Satz, der Bestand sei *„nicht zugriffsbeschränkt"*. Der Träger hält es anders:

```text
$ grep -n 'O_APPEND, 0o600\|f.Chmod(0o600)' internal/span/emit.go
312:	f, err := os.OpenFile(file, os.O_CREATE|os.O_WRONLY|os.O_APPEND, 0o600)
318:		if err := f.Chmod(0o600); err != nil {
```

Das Verzeichnis bleibt `0755` (`grep -n 'MkdirAll(dir' internal/span/emit.go` → `0o755`, bewacht von
`TestSpanDirIsTraversable` mit Mutations-Fall `116-span-verzeichnis-modus`). Die emittierte
Feldliste sagt bereits den Ist-Zustand (`limitStore` in `internal/span/fieldlist.go`: *„Seine
Dateien entstehen **nur für den Eigentümer lesbar** (Modus 0600); das Verzeichnis selbst bleibt für
andere auflistbar"*). Der Auftraggeber hat den Widerspruch per Change Request am Lastenheft
entschieden (`0.26.0`, Kriterium *Redaktion*: *„seine Dateien sind nur für den Eigentümer lesbar,
das Verzeichnis bleibt für andere auflistbar"*). Die Accepted-ADR bleibt unverändert
([`AGENTS.md`](../../../AGENTS.md) §3.4); diese Datei löst die eine Wendung ab.

## Entscheidung

**1. Die Nicht-Zusage über den Bestand nennt den Modus.** Geltende Fassung von Festlegung 6 Stück 3:
der Bestand ist gitignored und **nicht verschlüsselt**; seine **Dateien** entstehen mit Modus
`0600`, nur für den Eigentümer lesbar, ein bestehender Strom mit weiterem Modus wird beim nächsten
Schreiben auf `0600` gezogen; das **Verzeichnis** bleibt für andere auflistbar; Pfadnamen sind nicht
als unkritisch zugesagt. Eine Zugriffs**kontrolle** über den Dateimodus hinaus (ACL, Verschlüsselung,
eigener Nutzer) ist nicht zugesagt.

**2. Kein Produkt-Code-Nachzug.** Träger und emittierte Feldliste sagen den Ist-Zustand schon. Unter
den Normtexten war die Wendung in [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
die einzige Stelle, die dagegen stand; ein Kommentar sagt sie noch — der Kopf des Mutations-Falls
`test/mutations/169-feldliste-grenze-bestand-weg.sh` (*„nicht zugriffsbeschraenkt"*). Er wird
nachgezogen (Konsequenzen, Folgepflicht).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Modus auf `0644` weiten, damit *„nicht zugriffsbeschränkt"* stimmt | ADR-0022 bliebe wörtlich wahr | lockert eine bestehende Schutz-Eigenschaft ohne Bedarf; Lastenheft `0.26.0` sagt das Gegenteil |
| **B — die Wendung ablösen, den Modus als Ist-Zustand nennen** | eine Wendung, kein Code; deckungsgleich mit Lastenheft und Feldliste | — |
| C — auch das Verzeichnis auf `0700` | engere Zusage | bricht `make docs-check` (Mutations-Fall `116-span-verzeichnis-modus` beschreibt genau diesen Fehlerfall) |

## Konsequenzen

- Positiv: Lastenheft, ADR-Lage, Träger und emittierte Feldliste sagen denselben Satz.
- Negativ (akzeptiert): `0600` hängt am Dateisystem; auf einem Dateisystem ohne POSIX-Modus (z. B.
  Windows ohne WSL) trägt die Zusage nicht weiter, als das Betriebssystem den Modus abbildet —
  dieselbe Grenze wie für jede andere Modus-Aussage des Werkzeugs; kein eigener Folge-Slice.
- Folgepflicht, fällig mit dem Accept: ADR-Index — die Zeile von
  [ADR-0022](0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) nennt diese Teil-Ablösung.
- Folgepflicht (Implementer), nicht fällig mit dem Accept: der Kopf von
  `test/mutations/169-feldliste-grenze-bestand-weg.sh` ersetzt *„nicht zugriffsbeschraenkt"* durch
  die geltende Fassung (Dateien `0600`, Verzeichnis auflistbar); der Fall selbst bleibt.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test `TestModeIsOwnerOnly` (`internal/span/span_test.go`) | ein neuer Span-Strom hat `0600`; ein auf `0644` gesetzter wird beim nächsten Schreiben zurückgezogen | `make test` |
| Go-Test `TestFeldliste_GrenzeUeberDenBestand` (`internal/emit/fieldlist_test.go`) | die emittierte Feldliste trägt *„nur für den Eigentümer lesbar"* | `make test` |

Rot gesehen am 2026-10-09 in einer Kopie (`OpenFile`-Modus `0o644`, Nachzieh-Bedingung entschärft),
`make test-go` → `--- FAIL: TestModeIsOwnerOnly … Modus = -rw-r--r--, erwartet 0600`, rc=2.
**Lücke:** `TestModeIsOwnerOnly` hält nur den Strom (`s<N>.jsonl`). Sequenz- und Sperr-Datei
entstehen ebenfalls mit `0600` (`writeOwnerOnly`, `OpenFile(path, …, 0o600)` in
`internal/span/emit.go`), sind aber **ungedeckt** — eine Mutation auf `0o644` bliebe grün. Kein Fall
in `test/mutations/` hält einen Datei-Modus; `make mutate` bewacht nur den Verzeichnis-Modus
(`116-span-verzeichnis-modus`). Akzeptiertes Negativ: die Modi sind Literalwerte je Datei,
der Strom-Zahn einmal rot gesehen; ein Test oder Fall lohnt erst, wenn ein Modus wieder bewegt wird.

## Re-Evaluierungs-Trigger

- Das Lastenheft ändert das Kriterium *Redaktion* erneut (Verschlüsselung oder Verzeichnis-Schutz
  zugesagt) → Festlegung 1 neu.
- Ein Adopter meldet, dass `0600` seinen Auswerte-Lauf unter einem anderen Nutzer bricht →
  Festlegung 1 gegen Alternative A neu wägen (mit CR).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-09 | Proposed | Change Request des Auftraggebers an [`LH-FA-14`](../../../spec/lastenheft.md#lh-fa-14--redaktion-und-erfassungs-umfang), Lastenheft `0.26.0` |
| 2026-10-09 | **Accepted** | Prüfung `2026-10-09-proposed-adrs-pruefung`, Review `2026-10-09-adr-runde-0088-0062-0063-0089` (annahmereif; LOW eingearbeitet in `c12c55a4`), Annahme durch den Auftraggeber am 2026-10-09 ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0089` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
