# Review-Report: slice-migration-hat-ein-instanz-register — 2026-09-13

**Review-Art:** Code-Review — der Diff gegen den Slice-Plan und gegen die sechs Sprung-ADRs, die
die Auflage des Auftraggebers als Beleg-Menge setzt. Kein Plan-Review (der Plan ist Gegenstand des
Vergleichs, nicht der Prüfung), keine Verifikation (DoD-Abhakung ist Verifier-Arbeit, Modul 11).

**Gegenstand:** Commit `f0d58786` — 2 Dateien, +171/−0: `harness/migration.md` (neu, 170 Zeilen)
und die Guides-Zeile in `harness/README.md`. Arbeitsbaum leer, `f0d58786` ist `HEAD` **und**
`origin/main`.

**Skill:** `.harness/skills/reviewer.md` @ Version 2.0.0 (Accepted) · <!-- d-check:ignore (Adopter-spezifischer Skill-Pfad, existiert im Ziel-Repo ggf. nicht) -->
**Modell:** claude-opus-5 · **Datum:** 2026-09-13

> **Zitier-Form** *(dieser Block bleibt stehen — er ist Norm, kein Ausfüll-Hinweis; die
> `<Platzhalter>` darin sind Formbeispiele)*. Dieser Report friert ein; was er zitiert, bewegt
> sich weiter. Deshalb: **Kennung, nicht Adresse** — `slice-<Kennung>` statt seines
> Lifecycle-Pfads, `make <target>` statt eines Links auf die Sensor-Datei, eine Baseline-Stelle
> als **Tag + Pfad in Inline-Code** statt als Link (`v<X.Y.Z>` · `regelwerk/<datei>.md`
> §<Abschnitt>). Der vendored Baum trägt genau einen Tag; der Sprung löscht den alten, und ein
> Link darauf färbt beim nächsten Bump ein Artefakt rot, das niemand mehr anfassen darf. Ein
> `pfad`-Feld auf den **geprüften Gegenstand** ist davon nicht betroffen — es zitiert den Stand
> des Laufs und darf ihn festhalten (`v6.7.2` ·
> `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2) —
> diese Zeile ist selbst ein Beispiel der Form).

**Eingangs-Kontext** (die Verträge, gegen die geprüft wurde — ohne diese Liste ist der Lauf nicht
reproduzierbar):

- Slice-Plan `slice-migration-hat-ein-instanz-register`, gelesen an seinem Lifecycle-Stand
  `in-progress/`
- die sechs Sprung-ADRs, jede im Volltext ihrer §Entscheidung:
  [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) (`Accepted`),
  [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) (**`Proposed`**),
  [ADR-0036](../plan/adr/0036-ziel-fassung-regiert-den-sprung-v600.md) (`Accepted`),
  [ADR-0038](../plan/adr/0038-ziel-fassung-regiert-den-sprung-v650.md) (`Accepted`),
  [ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) (`Accepted`, Festlegung 1
  teilweise abgelöst),
  [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) (`Accepted`)
- [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
  [`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)
- [`AGENTS.md`](../../AGENTS.md) §3 (Hard Rules), namentlich §3.1, §3.6, §3.7, §3.8, §3.9, §3.10,
  §3.11
- [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
  [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist),
  [`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum),
  [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung),
  [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
- `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline
  (Schritt 2) — die Prozedur, die [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md)
  Festlegung 1 für den vollzogenen Sprung als regierend setzt
- vorherige Findings am gleichen Gegenstand:
  [ADR-0046-Konsistenzrunde](2026-09-13-adr-0046-konsistenzrunde.md) und
  [slice-offene-wellen-liste-hat-einen-waechter, Runde 2](2026-09-13-slice-offene-wellen-liste-hat-einen-waechter-r2.md)
  (dort N-8: eine vermutete Über-die-Quelle-hinaus-Aussage, die sich am Wortlaut **auflöste** —
  dasselbe Prüfmuster ist hier auf jeden normativen Satz angewandt)

**Rollen-Grenze:** Dieser Lauf ändert am Gegenstand nichts. Alle Sonden sind lesend; kein
Gate-Lauf, keine Docker-Stufe ([`AGENTS.md`](../../AGENTS.md) §3.9 — `make gates`, `make mutate`
und alle Docker-Ziele fährt der Auftraggeber).

---

## Findings

Jedes Finding folgt dem **§Output-Schema des Reviewer-Skills** — der verbindlichen Single Source
of Truth. Die Spalten unten sind nur **gespiegelt**, nicht neu definiert; bei Abweichung gilt der
Skill bzw. dessen Quelle `v6.7.2` · `regelwerk/modul-10-review-harness.md`
§Ziel-Form: Reviewer-Skill.

| ID | Kategorie | Befund | Quelle | Pfad | Verifizierbar | Klasse |
|---|---|---|---|---|---|---|
| F-1 | **HIGH** | §5 sagt von seinen vier Ausgängen *„eine geschlossene Menge, kein Freitext"*; die Append-only-Logik der wiederkehrenden Vorlagen fällt in keinen der vier — für sie ist *übernommen* das, was die regierende Prozedur gerade untersagt, *schon erfüllt* falsch, *bewusst abweichend* ohne `MR` und *keine Instanz* falsch. Betroffen sind **9** der 25 Zeilen mit **863** der gebuchten Instanzen. | [`AGENTS.md`](../../AGENTS.md) §3.6 · `v6.7.2` · `regelwerk/modul-02-harness-bootstrap.md` §Freshness-Audit der vendored Baseline (Schritt 2), Eigenschaft *Der Review vergleicht auch die Form* · [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4, die dieselbe Klausel wörtlich zitiert | `harness/migration.md:129-137` | **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) hält eine Ausgangs-Menge gegen die Prozedur; `make mutate` kennt keine Fehlschlag-Form dafür | Geschlossene Menge ohne Gegenbeispiel deklariert |
| F-2 | **MEDIUM** | §2 gibt [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) Festlegung 2 als geltende Form wieder und §1 führt deren Festlegung 1 in einer Tabelle, deren Vorspann *„jede Zeile ist eine für ihren Sprung geschlossene Entscheidung"* sagt; die ADR steht seit 2026-09-03 auf **`Proposed`** und ist nach ihrem eigenen Schlusssatz nicht eingefroren. Der Status steht an keiner der beiden Stellen. | [`AGENTS.md`](../../AGENTS.md) §3.4 (bindet ab `Accepted` — hier also *nicht*) · [ADR-0031](../plan/adr/0031-regierende-fassung-und-ort-der-zielstand-setzung.md) §Geschichte | `harness/migration.md:34-35,40,53-65` | **nein** — `vcs.head-allow` prüft die Statuszeile der ADR selbst, nicht eine Wiedergabe in einem anderen Artefakt | Nicht eingefrorene Entscheidung als geschlossene wiedergegeben |
| F-3 | **MEDIUM** | §3 gibt [ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 als *„die Regel verhindert den Ausfall nicht, sie hält ihn nur sichtbar"* wieder; die Festlegung sagt an derselben Stelle *„Sie erlaubt **nicht**, einen Durchgang auszulassen"*. Aus einem Verbot wird eine Beschreibung. | [ADR-0043](../plan/adr/0043-ziel-fassung-regiert-den-sprung-v671.md) Festlegung 2 · `v6.7.2` · `regelwerk/modul-08-agentenrollen.md` §Rollen-Regeln (*„niemals stillschweigend einer ADR widersprechen"*) | `harness/migration.md:75-76` | **nein** — kein Sensor hält eine Wiedergabe gegen ihre Quelle | ADR-Prohibition in der Wiedergabe zur Beschreibung abgeschwächt |
| F-4 | **MEDIUM** | Die Zeile zu `review-report.template.md` bucht **377** Instanzen über `docs/reviews/*.md`. Die DoD dieses Slice verlangt einen Review-Report ebendort; der schreibende Vorgang bewegt damit seine eigene Bezugsmenge, und gemessen ist der Stand **vor** dem Vorgang. | [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) Setzung 2 und Setzung 3 (*„der Zusatz machte aus einem falschen Betrag einen falschen Betrag mit Disclaimer"*) | `harness/migration.md:107` | **nein** — [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) §Kein Wächter stellt die Lücke für genau diesen Fall selbst fest | Messung vor dem Vorgang genommen, den sie selbst bewegt |
| F-5 | **MEDIUM** | Zwei Präsens-Aussagen über die Baseline nennen den Stand nicht, an dem nachgesehen wurde: *„Der Freshness-Audit der Baseline führt … fünf Ausgänge"* (§5) und *„Baseline-Regelwerk `modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse verlangt diese Skill nur, wenn …"* (§4). Beide sind am vendored `v6.7.2` **inhaltlich wahr**; der Mess-Tag fehlt. | [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) Setzung 1 (*„ein Satz ohne Tag erfüllt sie nicht"*) | `harness/migration.md:112,145-148` | **nein** — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Mess-Tags in Prosa | Baseline-Aussage ohne Mess-Tag |
| F-6 | **MEDIUM** | Die fünf Ausgangs-Namen in §5 sind mit *„zitiert in [ADR-0018] §Kontext"* belegt. §Kontext nennt dort die **Zahl** *fünf Ausgängen*, aber keinen der fünf Namen; die Namen stehen in §Entscheidung Festlegung 4. Wer dem Zeiger folgt, findet in §Kontext *gegenstandslos* nur als Suchwort einer Gegenprobe mit **0** Treffern. | [ADR-0018](../plan/adr/0018-ziel-fassung-regiert-die-migration.md) Festlegung 4 · DoD-Punkt (3) des Slice-Plans (*„nennt den Sprung-ADR, an dem er belegt ist"*) | `harness/migration.md:148` | **nein** — `anchors` prüft Markdown-Anker, nicht die Abschnitts-Angabe in Prosa | Beleg-Zeiger landet im falschen Abschnitt seiner Quelle |
| F-7 | **MEDIUM** | Die Commit-Message führt *„25 vendored Vorlagen"* und *„vier davon keine Instanz"* als Belege des Gelieferten, ohne das Kommando zu nennen, das genau sie ausgibt. Der Commit ist gepusht (`origin/main` == `f0d58786`) und damit unveränderlich. | [`MR-051`](../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung) Setzung 1 | Commit-Message `f0d58786`, Absatz 1 | **nein** — `make commit-msg-check` prüft die Traceability-Kennung, keine Zahl | Messwert in der Commit-Message ohne Kommando |
| F-8 | **LOW** | Der Vorspann der Tabelle in §1 sagt *„keine löst die vorige ab"*; die vorletzte Zeile derselben Tabelle sagt *„teilweise abgelöst durch ADR-0044"*. Die Aussage ist im Sachgehalt richtig (die Wahl bleibt für ihren Sprung wahr), im Wortlaut von der Zeile darunter widerlegt. | [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) §Was der Teil-Supersede umfasst | `harness/migration.md:34-35,43` | **nein** | Pauschale im Vorspann von der eigenen Tabellenzeile widerlegt |
| F-9 | **LOW** | Zeile 128 trägt einen `d-check:ignore`-Marker auf einer eigenen Zeile ohne Inline-Code-Pfad. Der Marker wirkt zeilengenau (`markers[pl.no]` in `codepaths.go` des gepinnten `v0.74.1`), unterdrückt hier also nichts; die Überschrift Zeile 126, die er offenbar decken soll, nimmt `codepaths` ohnehin als ATX-Heading aus. | [`MR-027`](../../harness/conventions.md#mr-027--d-check-pin-v0650-ignore-marker-in-zwei-achsen-verengt) (Form und Lage des Markers) · [`AGENTS.md`](../../AGENTS.md) §3.7 | `harness/migration.md:128` | **ja, in einer Richtung** — `make docs-check` bliebe auch ohne diesen Marker grün | Suppression ohne Gegenstand |
| F-10 | **LOW** | Die Beleg-Art des Ausgangs *schon erfüllt* ist *„`diff`-Fundstelle (zeigt die Übereinstimmung)"*. Ein `diff` gibt Unterschiede aus; bei Übereinstimmung hat er keine Fundstelle, auf die gezeigt werden könnte. | Maintainability · DoD-Punkt (2) des Slice-Plans (*„je Ausgang seine Beleg-Art"*) | `harness/migration.md:135` | **nein** | Beleg-Art benennt ein Werkzeug, das den Beleg nicht liefern kann |
| F-11 | **LOW** | §4 markiert seinen Nicht-ADR-Status an seinem Kopf (*„Die Zuordnung ist eine Beobachtung am Bestand, keine ADR-Aussage"*), §5 nicht. Der einzige Zeiger aus §5 nach §6 steht am Abschnitts-Ende und hängt an einer anderen Frage (vier gegen fünf Ausgänge), nicht an der fehlenden Deckung von §5 selbst. | Auflage des Auftraggebers, wiedergegeben in §1 des Slice-Plans und in DoD-Punkt (3) | `harness/migration.md:126-150` | **nein** | Deckungs-Marke asymmetrisch zwischen zwei gleichartigen Abschnitten |
| F-12 | **INFO** | §3 nennt [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 2 *„unverändert angewendet"*. Jene Festlegung nennt sich selbst *„eine **Anwendung**, keine zweite Fassung der Leseregel"* und benennt im selben Absatz, *„was sie hinzufügt"* — die Antwort darauf, ob ein bewegter Zielstand die Basis mitzieht. | [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 2 | `harness/migration.md:69-71` | **nein** | Zusatz einer zitierten Festlegung in der Wiedergabe eingeebnet |
| F-13 | **INFO** | *„kein Ziel für einen siebten Sprung ist gesetzt"* ist eine Existenz-Aussage über den Bestand ohne Kommando, obwohl §2 desselben Dokuments den Buchungs-Ort benennt, an dem sie prüfbar wäre. Sie ist am Stand dieses Laufs **wahr**. | [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) Setzung 1 (dem Geist nach; die Setzung bindet Zahlen, nicht Existenz-Aussagen) | `harness/migration.md:48-49` | **nein** | Mengen-Aussage ohne Kommando |

### Belege zu F-1 und F-4

```sh
# F-1 — Zeilen des Registers mit mehr als einer Instanz, und die Summe ihrer Instanzen
sed -n '93,117p' harness/migration.md | grep -cE '\| [0-9]+ Instanzen'                       # 9
sed -n '93,117p' harness/migration.md | grep -oE '\| [0-9]+ Instanzen' \
  | grep -oE '[0-9]+' | paste -sd+ | bc                                                      # 863
grep -c 'gilt die Append-only-Logik' .harness/baseline/v6.7.2/regelwerk/modul-02-harness-bootstrap.md   # 1

# F-4 — Stand der Bezugsmenge vor und am Commit
git ls-tree -r --name-only f0d58786 docs/reviews/ | grep -c '\.md$'                          # 377
```

Alle vier Zahlen sind **keine Erwartungswerte** — sie wandern mit dem Baum. Die `863` ist die
Summe der im Register gebuchten Beträge, nicht eine unabhängige Zählung des Bestands; die
Einzelbeträge sind unten in den Negativbefunden gegen ihre eigenen Kommandos gehalten.

## Negativbefunde

| Bereich | Ergebnis |
|---|---|
| **Instanz-Register, Vollständigkeit** — nicht Stichprobe, sondern Bijektion: die 25 `Vorlage`-Zellen gegen `find .harness/baseline/v6.7.2/templates -name '*.template.md'`, beide sortiert und `diff`-verglichen | geprüft, ohne Befund — **25/25 identisch**, keine Vorlage ohne Zeile, keine Zeile ohne Vorlage, keine Dublette |
| **Instanz-Register, die 9 Zeilen mit Mengen-Angabe** — jedes der Kommandos in der Beleg-Zelle gefahren: ADR **46**, Carveout **6**, Observation **104**, Slice **229**, welle-results **12**, welle offen **3** + `done/` **12** = **15**, Review **377**, `MR` **55**+**4**=**59**, Sensor **15** | geprüft, ohne Befund — **jede Zahl stimmt mit der Ausgabe ihres eigenen Kommandos überein**; einzige Einschränkung ist F-4, das den *Zeitpunkt* der 377 betrifft, nicht ihren Betrag |
| **Instanz-Register, die 12 Zeilen mit genau einer Instanz** — Existenz jedes genannten Artefakts einzeln geprüft (`AGENTS.md`, `docs/plan/adr/README.md`, `docs/plan/carveouts/README.md`, `docs/plan/planning/README.md`, Roadmap, `harness/conventions.md`, `harness/README.md`, Reviewer-Skill, `README.md`, drei `spec/`-Dateien) | geprüft, ohne Befund — alle vorhanden, alle Zuordnungen inhaltlich und nicht nur namensähnlich (stichprobenhaft am Template-Kopf gegengelesen, z. B. `gate.template.md` → *„Kopiere nach `harness/sensors/<target>.md`"*) |
| **Die vier `keine Instanz`-Begründungen, einzeln nachgefahren** | geprüft, ohne Befund — (1)+(2) Archiv-Stubs: kein `.zip` im Planning-Baum, kein `done/<welle-id>/`-Unterverzeichnis, `archive-welle` steht im `Makefile` und ist in `harness/README.md` §Werkzeuge als *kein Gate* geführt; (3) `reconciliation.md` fehlt (Exit 2) und die berührte Sub-Area ist in `harness/conventions.md` §Modus-Deklaration als Greenfield deklariert; (4) `ls .harness/skills/*.md` → **1**, und das Kriterium aus `v6.7.2` · `regelwerk/modul-08-agentenrollen.md` §Welche Rolle braucht welche Artefaktklasse ist am Bestand nicht eingetreten |
| **Normative Sätze gegen ihre ADR** — **36** Aussagen aus §1–§5 einzeln aufgeschlüsselt und jede gegen die zitierte §Entscheidung gehalten, nicht nur die mit ADR-Kennung daneben | geprüft — **30 tragen wörtlich**, 6 sind Findings (F-1, F-2, F-3, F-6, F-8, F-12). Namentlich tragen: §1 Kriterium und beide Zweige (ADR-0018 Festlegung 3), die Absage an *„es regiert stets die Ziel-Fassung"* (in allen sechs ADRs bestätigt), *Prozedur ≠ Ist-Maßstab* (ADR-0018 Festlegung 2 — die Verallgemeinerung von `v3.5.2` auf *die gepinnte Fassung* wird von der Festlegungs-Überschrift *„Die Wahl gilt für die Prozedur, nicht für den Ist-Zustand"* getragen), alle sechs Tabellenzeilen mit ihrer Festlegungs-Nummer (ADR-0036 und ADR-0038 tragen je genau **eine** Festlegung und werden korrekt ohne Nummer zitiert), die fünf Teile von §2, die Leseregel und ihre Messung in §3 |
| **Sprung-ADR-Status** — alle sechs Statuszeilen und die Status-Zellen des ADR-Index gelesen | geprüft — fünf `Accepted`, **eine `Proposed`** (F-2). Keine superseded ADR referenziert; die Teil-Ablösung von ADR-0043 Festlegung 1 ist im Index-Zusatz verbucht und in §1 der geprüften Datei korrekt als solche benannt |
| **[`AGENTS.md`](../../AGENTS.md) §3.8 — schreibt die Datei eine neue Norm?** | geprüft, ohne Befund — kein Hard-Rule-Text, kein `MR`-Eintrag, keine ADR; `git show --stat f0d58786` zeigt zwei Dateien, weder [`AGENTS.md`](../../AGENTS.md) noch [`harness/conventions.md`](../../harness/conventions.md) noch `harness/conventions/` noch `docs/plan/adr/` sind berührt. Die Formvorgabe in §5 ist normativ **für einen künftigen Bericht**; §3.8 spricht über andere Norm-Artefakte ausdrücklich **nicht** (*„wo keine Quelle sie benennt, bleibt die Frage offen"*), und keine Quelle weist `harness/migration.md` einer schreibenden Rolle zu. Kein §3.8-Befund — die inhaltliche Deckungs-Frage trägt F-1 |
| **[`AGENTS.md`](../../AGENTS.md) §3.1 / [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)** | geprüft, ohne Befund — die neue Guides-Zeile in `harness/README.md` behauptet **kein** Target; sie steht in der Feedforward-Tabelle, nicht in §Sensors. Das einzige im Diff genannte Target ist `archive-welle`, es existiert im `Makefile` und steht in `targets.exempt-targets`. `targets.doc-tables` führt `AGENTS.md` und `harness/README.md` — die neue Datei liegt nicht darin, behauptet aber auch nichts, was dort stehen müsste |
| **Out-of-Scope-Treue gegen §1 des Slice-Plans, alle sechs Punkte** | geprüft, ohne Befund — kein `docs/migrations/`-Report und kein Durchgang gegen einen siebten Tag (das Verzeichnis existiert nicht), kein rückwirkender Report, keine ADR und kein `MR`, kein Sensor und kein `.d-check.yml`-Modul, keine Änderung an `harness/conventions.md` §Baseline, kein Produkt-Code (`internal/`, `cmd/`, `harness/tools/`, `internal/emit/templates/` unberührt) |
| **[`AGENTS.md`](../../AGENTS.md) §3.10 — Commit-Zuschnitt** | geprüft, ohne Befund — der Commit berührt **kein** Planungs- oder Closure-Artefakt. Die DoD-Häkchen des Slice-Plans stehen unverändert auf `- [ ]`, die Risiko-Ausgänge in §6 auf ihrem Platzhalter, §7 leer, `docs/plan/planning/observations/` unberührt, kein `git mv`. Die Rolle steht in der Message (*„Rolle Implementer"*) |
| **[`AGENTS.md`](../../AGENTS.md) §3.7 — Kommentar- und Zustandsfeld-Regel** | geprüft, ohne Befund an der Quellen-Klausel — die Datei trägt **keine** Befund-Kennung, keine Slice-Nummer als Erzählung und kein Lauf-Protokoll. Die zwei `slice-`-Treffer sind (a) der zitierte Inhalt des Delta-Nachweis-Feldes und (b) ein Glob; beide sind auflösbare Felder, keine Chronik. Die Zustands-Zellen der Tabelle in §1 tragen Zustand und ADR-Anker, keinen Verlauf. Der einzige Kommentar-Befund ist F-9, und er betrifft die Lage eines Markers, nicht seine Klasse |
| **[`AGENTS.md`](../../AGENTS.md) §3.11 — Adressform** | geprüft, ohne Befund — `harness/migration.md` ist ein **lebendes** Artefakt, kein einfrierendes; für es bleibt der Pfad der richtige Zeiger. Die genannten Planning-Adressen sind Globs über den ganzen Lifecycle bzw. ortsfeste Ablagen, keine Einzel-Adresse, die der Prozess bewegt |
| **Verweis-Integrität** — alle **18** verschiedenen Link-Ziele der neuen Datei einzeln gegen das Dateisystem gehalten, dazu die zwei `conventions.md`-Anker und der interne Anker `#6-offene-fragen` | geprüft, ohne Befund — 18/18 vorhanden, beide `MR`-Anker als `id="…"` in `harness/conventions.md` belegt, der interne Anker deckt sich mit der Überschrift `## 6. Offene Fragen` |
| **[`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert) — Zahl neben ihrem Kommando** | geprüft, ohne Befund über die Form — **jede** Zahl der Datei steht neben einem Kommando und trägt die Kennzeichnung *kein Erwartungswert*; jedes dieser Kommandos ist in diesem Lauf gefahren und liefert genau den genannten Betrag. F-4 betrifft nicht die Form, sondern den Zeitpunkt, und fällt darum unter [`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen) statt hierunter |
| **[`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist) — Tag-Nennung, Gegenrichtung** | geprüft — die **25** Vorlagen-Pfade, der Kopf von §4 und die Vollständigkeits-Klausel nennen `v6.7.2` bzw. lesen `<tag>` aus `BASELINE_TAG`; das ist die Ziel-Form. Der Befund F-5 betrifft genau die zwei Stellen, an denen ein Satz **statt** eines Pfades die Aussage trägt |
| **[`MR-040`](../../harness/conventions.md#mr-040--drei-ausgänge-für-eine-präsens-aussage-über-den-vendored-baum)** | geprüft, ohne Befund — der Eintrag bindet den **Re-Baseline-Durchgang** und nicht den Schreibzeitpunkt; er wird beim nächsten Tausch fällig. Zu vermerken bleibt, dass er dann **25** Präsens-Adressen in dieser einen Datei zu bedienen hat — das ist der Ausgang *nachgemessen*, keine Abweichung |
| **Inhaltliche Gegenprobe der zwei Baseline-Aussagen aus F-5 am vendored `v6.7.2`** | geprüft — **beide wahr**: `regelwerk/modul-02-harness-bootstrap.md` führt die *fünf Ausgänge* weiterhin, und `regelwerk/modul-08-agentenrollen.md` führt das Skill-Kriterium *„inferential **und** aus keinem Artefakt ableitbar"*. F-5 ist ein Form-, kein Sachbefund |
| **Commit-Hygiene** | geprüft, ohne Befund — keine Attributions-Zeile (kein `Co-Authored-By`, kein `Claude-Session`), Traceability erfüllt (`LH-QA-01`, `LH-QA-02`), Rolle genannt. Der einzige Message-Befund ist F-7 |
| **Zeilenzahl gegen Kommando (Closure-Kriterium 1 des Plans)** | geprüft, ohne Befund — die Tabelle in §4 trägt **25** Datenzeilen, `find … \| wc -l` → **25**, `grep -m1 '^BASELINE_TAG' Makefile` → `v6.7.2`, `ls -1 .harness/baseline/` → `v6.7.2`. Die Übereinstimmung besteht; ob sie damit als DoD-Punkt abgehakt werden darf, entscheidet der Verifier |

### Ausdrücklich **nicht** geprüft

| Bereich | Grund |
|---|---|
| `make gates`, `make docs-check`, `make mutate`, jedes Docker-Ziel | [`AGENTS.md`](../../AGENTS.md) §3.9 und ausdrückliche Auflage des Auftraggebers — er fährt sie. Alle Aussagen dieses Reports über Gate-Verhalten sind **Lesungen der Konfiguration und der gepinnten Werkzeug-Quelle**, kein Lauf |
| DoD-Abhakung, Risiko-Ausgänge §6, Closure-Notiz §7 | Verifier- bzw. Planner-Arbeit (`v6.7.2` · `regelwerk/modul-11-verification.md`; [`AGENTS.md`](../../AGENTS.md) §3.10) |
| Die sechs Sprung-ADRs **als Entscheidungen** | Gegenstand ist ihre Wiedergabe, nicht ihre Güte. Fünf sind `Accepted` und damit nach [`AGENTS.md`](../../AGENTS.md) §3.4 eingefroren; ADR-0031 hat ihre eigene Konsistenzrunde, die dieser Lauf nicht ersetzt |
| Ob `codepaths` die **Glob**-Formen der Instanz-Spalte (`docs/plan/adr/[0-9]*.md`, `{open,next,…}`) als Pfad-Anspruch liest | verlangt einen Gate-Lauf. Die Marker-Lage (F-9) ist dagegen an der Quelle des gepinnten `v0.74.1` gelesen und braucht keinen |

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 1 |
| MEDIUM | 6 |
| LOW | 4 |
| INFO | 2 |

**Finding-Klassen dieses Laufs:** Geschlossene Menge ohne Gegenbeispiel deklariert · Nicht
eingefrorene Entscheidung als geschlossene wiedergegeben · ADR-Prohibition in der Wiedergabe zur
Beschreibung abgeschwächt · Messung vor dem Vorgang genommen, den sie selbst bewegt ·
Baseline-Aussage ohne Mess-Tag · Beleg-Zeiger landet im falschen Abschnitt seiner Quelle ·
Messwert in der Commit-Message ohne Kommando · Pauschale im Vorspann von der eigenen Tabellenzeile
widerlegt · Suppression ohne Gegenstand · Beleg-Art benennt ein Werkzeug, das den Beleg nicht
liefern kann · Deckungs-Marke asymmetrisch zwischen zwei gleichartigen Abschnitten · Zusatz einer
zitierten Festlegung in der Wiedergabe eingeebnet · Mengen-Aussage ohne Kommando

**Hinweis an die Slice-Closure, nicht an den Implementer:** Die Klasse hinter F-5 ist im
Sichtungs-Schritt §8 des Plans bereits mit **2×** geführt. Ob dieser Lauf der dritte Beleg ist und
welcher Ausgang daraus folgt, entscheidet der Lese-Schritt — Planner-Arbeit, nicht die dieses
Reports.

## Verdikt

**Merge-blockierend: ja.**

Blockierend ist **F-1**: §5 gibt eine Zusage über eine geschlossene Menge ab, deren Gegenbeispiel
nicht nur denkbar, sondern in der Prozedur steht, die
[ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md) Festlegung 1 für den
vollzogenen Sprung als regierend setzt — und es trifft die Mehrheit der Register-Masse. Der erste
reale Migrations-Report müsste für `slice.template.md`, `NNNN-titel.template.md` und
`review-report.template.md` einen Ausgang eintragen, der für sie falsch ist; das ist ein stilles
Grün auf dem Papier, bevor das Papier zum ersten Mal benutzt wird.

**F-2, F-3, F-5 und F-6** blockieren nach der Regel des Reviewer-Skills ebenfalls und sind vor dem
Merge zu klären: Alle vier betreffen die **eine** Eigenschaft, für die dieses Dokument existiert —
dass jeder Satz an seiner Quelle hängt.

**F-4** blockiert nach derselben Regel, ist aber ein Zeitpunkt-Befund und in der Sache mit einem
Satz zu erledigen. **F-7** ist nach dem Push nicht mehr behebbar; er geht ausschließlich in den
Steering-Loop-Zähler und blockiert diesen Merge ausdrücklich **nicht** — eine Abweichung von der
Merge-Regel, die hier begründet statt still entschieden wird.

**Was dagegen ausdrücklich trägt:** Das Instanz-Register ist die stärkste Hälfte dieses Diffs. Es
ist **vollständig** (25/25 in beide Richtungen), **jede** seiner Mengen-Angaben stimmt mit dem
Kommando daneben überein, **jede** der vier `keine Instanz`-Begründungen hält der Nachprüfung
stand, und die Zuordnungen sind sachlich und nicht namensähnlich. Die Auflage des Auftraggebers
ist an **30 von 36** normativen Sätzen eingelöst, und §4 benennt seine eigene fehlende ADR-Deckung
von sich aus — das ist genau die Ehrlichkeit, die die Auflage verlangt. Die Befunde liegen nicht
im Register, sondern in §5 und in der Wiedergabe von vier ADR-Stellen.

**Übergabe:** Findings gehen an den Implementer; die **Finding-Klassen** gehen zusätzlich in die
Slice-Closure §7 und von dort in den Zähler. Dieser Report ist ein **Lauf-Beleg** (Audit: dieser
Diff, dieser Skill, dieses Modell, dieses Verdikt) und wird über Läufe hinweg nicht wieder
gelesen. Er ersetzt keine Verifikation — DoD-/Spec-Konformität prüft der Verifier separat
(Modul 11; anderes Prüf-Artefakt, anderer Eingabe-Kontext).
