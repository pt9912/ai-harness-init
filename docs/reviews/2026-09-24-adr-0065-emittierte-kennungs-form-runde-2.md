# Review-Report: ADR-0065 (emittierte Kennungs-Form folgt dem Regelwerk), Runde 2 — 2026-09-24

**Review-Art:** Design — Nachrunde eines Design-Reviews einer `Proposed`-ADR gegen das Regelwerk `v6.9.0`
(Original, nicht Zusammenfassung), gegen `ADR-0007`, `ADR-0053`, `ADR-0054`, `MR-054`, `MR-032`, `MR-057`,
`AGENTS.md` §3.5/§3.6 und gegen den Baum. Das ist die erneute Runde der prüfenden Rolle, die `ADR-0040`
Festlegung 2 nach einer Runde mit Befunden als Beleg des Acceptance-Triggers verlangt. Runde 1:
`docs/reviews/2026-09-24-adr-0065-emittierte-kennungs-form-runde-1.md` (Commit `d9bcd0b5`), unangetastet.

**Gegenstand:** Commit `3ed32f2f` (Architect-Korrektur, lokal, nicht gepusht; Vorfassung `f1b3da6f`) —
`docs/plan/adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md` und `MR-057`; `git diff --stat d9bcd0b5 3ed32f2f`
nennt genau diese zwei Dateien (`git log f1b3da6f..3ed32f2f` enthält daneben den Runde-1-Report-Commit `d9bcd0b5`); der Arbeitsbaum ist sauber.

**Rolle:** Reviewer, frischer Kontext. Keine Selbstauskunft des Architects wurde ungeprüft übernommen; jede
Messung der ADR, die sich fahren ließ, ist nachgefahren (§Messungen).

**Belegt am HEAD:** `make host-bin` (HEAD `3ed32f2f`) baut ein Binär mit demselben sha256 wie das vorhandene
`.harness/state/bin/ai-harness-init` (`b8d5c9b9…f83b2`, vollständig
`b8d5c9b9500ad863657b3f58d95dc9e7777806a8a28274f3b88dfaab774f83b2`, vor und nach dem Bau gleich). Alle
Emit-Läufe fuhren dieses Binär in Scratchpad-Kopien; im Repo wurde nichts außer dieser Datei geschrieben.

## Gesamturteil

**Annahmefähig.** Kein HIGH, kein blockierender Befund an der Substanz der sechs Festlegungen. Von den vierzehn
Befunden der Runde 1 sind alle behoben oder ausdrücklich entschieden und ausgeschrieben (§Runde-1-Befunde).
Diese Runde findet **einen MEDIUM** — er betrifft die Folgepflicht 2 (die Form der Kopf-Marke am Accept-Commit),
nicht eine der sechs Festlegungen — und fünf LOW/INFO an der Menge, der Begründung und der Umsetzung.

**Acceptance-Trigger.** Der Wortlaut in der ADR: *„…ihr Report ohne blockierenden Befund an der Substanz der
sechs Festlegungen in `docs/reviews/` liegt. Ein blockierender Befund an der Darstellung … wird behoben und
hindert die Annahme nicht."* Diese Runde hat die dann geltende Fassung gegen `ADR-0007` (Festlegung 3),
`ADR-0053`, `ADR-0054` (Festlegung 1) und `MR-054` geprüft; ihr Report führt keinen blockierenden Befund an der
Substanz. **Der Trigger ist erfüllt.** N-1 (MEDIUM) gehört vor den Accept-Commit geklärt, hindert aber die
Annahme nach dem Wortlaut nicht: Er liegt an der Folgepflicht, nicht an einer Festlegung. Die Annahme selbst
bleibt beim Auftraggeber.

## Findings

### N-1 — MEDIUM — Folgepflicht 2: die Kopf-Marke mit einer ADR als Ziel hat keine Form, die `MR-032` lizenziert

- `kategorie`: MEDIUM · `quelle`: `MR-032` Setzung 1 und 3, `AGENTS.md` §3.8, ADR-0065 Folgepflicht 2
- `pfad`: `docs/plan/adr/0065-…md:264-273`; `harness/conventions/MR-032-…md` (Setzung 1: Form, Setzung 3:
  Wer setzt)
- `befund`: Die ADR schreibt vor, dass der Accept-Commit `MR-057` eine Kopf-Marke mit `ADR-0065` als Ziel gibt,
  und räumt ein, dass dafür kein Präzedenzfall besteht. `MR-032` Setzung 1 definiert das Ziel als *„die
  Anker-Adresse des ablösenden **Eintrags**"*, Setzung 3 lässt die Marke vom *„ablösende[n] Eintrag"* setzen;
  eine ADR ist keines von beidem (`grep -h '^> \*\*ÜBERHOLT' harness/conventions/*.md | grep -c 'ADR-'` → **0**,
  keine Marke des Bestands zeigt auf eine ADR). Der Accept-Commit müsste die Marke entweder außerhalb der Form
  schreiben, die der Architect selbst für Marken gesetzt hat, oder ein Eintrag müsste die Form vorher erweitern
  — dann ist „im selben Commit wie die Statuszeile" nicht haltbar. Die Zusage der ADR (Marke am Accept) hat
  damit keine Norm, die sie deckt; der Grund der Marke (*„Wer auf dem Vorgänger landet, erfährt sonst
  nichts"*, `MR-032` §Begründung) trifft dagegen zu.
- `verifizierbar`: nein — `make docs-check` prüft die Auflösung des Ziel-Links, nicht die Form der Marke
- `klasse`: Folgepflicht schreibt eine Norm-Form vor, die die zitierte Norm nicht führt

### N-2 — LOW — Muster 4 der Commit-Menge nimmt Struktur-IDs mit Bereichssegment an, die die Prosa „mit Absicht" ausschließt

- `kategorie`: LOW · `quelle`: `grundlagen-source-precedence.md` §ID-Schema als Klammer (*„Die Klammer trägt die
  Anforderungs-ID, nicht jede Kennung"*; *„Die Zählteile stehen hier ohne Bereichssegment"*), ADR-0065
  Festlegung 4
- `pfad`: `docs/plan/adr/0065-…md:183` (Muster 4), `:191-192`, `:194-198` (Annahme-/Ablehnungs-Liste)
- `befund`: Die ADR sagt, `SPEC-`, `ARC-`, `BEO-` und `RC-` fehlten *mit Absicht*, und lehnt `SPEC-042` ab.
  Muster 4 `[A-Z]{2,}-[A-Z-]*[A-Z]-[0-9]{2,3}` nimmt dieselben Klassen mit Bereichssegment an: gemessen (bash
  `[[ =~ ]]`, gleich im d-check-Image) `SPEC-FA-042`, `ARC-FA-042`, `BEO-ALL-001`, `RC-AB-12` → angenommen.
  Ebenso fehlt die Wortgrenze rechts (`HSM-FA-1234` und `CO-1234` treffen auf ihrem Präfix) und jede
  dreiteilige Fremd-Bezeichnung dieser Form (`EN-ISO-900`, `AES-CB-128`, `PR-A-12`) zählt. Die Grenze nennt nur
  `AES-CB-128` und die fehlende Wortgrenze links; die Annahme-/Ablehnungs-Liste prüft die Struktur-IDs nur in
  ihrer flachen Form, so dass die *„mit Absicht"* der Prosa an keinem Fall hängt.
- `verifizierbar`: ja — bats gegen die Prüfung mit `SPEC-FA-042` in der Ablehnungs-Liste zeigt, dass die Absicht
  nicht gehalten wird (oder die Prosa wird eingeschränkt)
- `klasse`: Prosa-Zusage über eine Menge, die das Muster an anderer Form nicht hält

### N-3 — LOW — Die Begründung von 2(b) nennt als Eigenschaft *„lässt sich nicht nachziehen"*; das Regelwerk führt für den Block das Gegenteil

- `kategorie`: LOW · `quelle`: `grundlagen-traceability.md` §Herkunfts-Anker (Ruheort-Regel, Gegenrichtung),
  `modul-05-planning-harness.md` (*„Die Kennung bleibt Adresse — einen Hop länger"*), ADR-0065 Festlegung 2(b)
- `pfad`: `docs/plan/adr/0065-…md:144-148`
- `befund`: Die ADR begründet die Erweiterung damit, ein Slice- oder Welle-Name in einem Eintrag sei *„eine
  Adresse in einem Artefakt, das sich nicht nachziehen lässt"*, und stützt das auf *„Einträge werden nie
  überschrieben"* (`grundlagen-harness-dateien.md`, Tabellenzeile Adaptions-Block; wörtlich vorhanden). Das
  Regelwerk sagt für **denselben** Block, dass der `git mv` einer Adaption *„die Pfad-Berichtigung nach sich
  [zieht], als eigener Commit nach dem Umzug"* (`grundlagen-traceability.md`, Ruheort-Regel, letzter Absatz), und
  führt eine Slice-Kennung als Namen, der beim Umzug **nicht** wandert (Kennung, nicht Pfad). Für die Namen, die
  2(b) fängt, ist damit kein Versagens-Szenario der genannten Art beschrieben: was rottet, ist ein Pfad, nicht
  der Name. Die ADR markiert das als Analogieschluss und trägt die Kosten (Trigger 2); die Auftraggeber-Setzung
  hält 2(b). Der Befund betrifft nur den Wortlaut der Begründung: die genannte Eigenschaft trägt für Pfade, nicht
  für Namen.
- `verifizierbar`: nein
- `klasse`: Begründung nennt eine Eigenschaft, die für den gefangenen Gegenstand nicht zutrifft

### N-4 — LOW — `welle-` stützt sich nicht auf die ID-Liste der Vorlage, auf die Festlegung 4 die Setzung zurückführt

- `kategorie`: LOW · `quelle`: `.harness/baseline/v6.9.0/templates/harness/conventions.template.md`
  (§MR-000, Feld Adaption), ADR-0065 Festlegung 4
- `pfad`: `docs/plan/adr/0065-…md:188-190`
- `befund`: *„`MR-`, `CO-`, `slice-` und `welle-` sind die Setzung dieses Werkzeugs … Sie stützt sich auf die
  ID-Liste der Vorlage `conventions.template.md`."* Die Liste (Zeilen 106–108) führt `CO-<NNN>`, `slice-<Kennung>`,
  `MR-<NNN>`; `welle-` steht dort nur als Dateifamilie in der Klammer zum Bereichssegment (`(ADR-*, CO-*, slice-*,
  welle-*)`, Z. 112), nicht als Kennung der Liste. Für `welle-` trägt die Herleitung damit die Matrix-Spalte (wie
  Festlegung 1 es sagt), nicht die Vorlagen-Liste.
- `verifizierbar`: ja — `sed -n 105,113p` der Vorlage
- `klasse`: Zuschreibung ans Regelwerk reicht weiter als die Stelle

### N-5 — LOW — Die Konsistenz gegen `ADR-0053` Festlegung 4 ist nicht ausgeschrieben: die Präfix-Menge wirkt für `slice-mv:` wie die Ausnahme, die dort als Senkung benannt ist

- `kategorie`: LOW · `quelle`: `ADR-0053` Festlegung 4 (*„Eine Ausnahme für die Werkzeug-Formen ist damit nicht
  ausgesprochen: eine Zeile, die `slice-mv:`-Messages von der Prüfung nimmt, wäre eine Senkung …"*),
  `AGENTS.md` §3.5, Acceptance-Trigger der ADR-0065
- `pfad`: `docs/plan/adr/0065-…md:194-200`, `:250-253`, `:288-300`
- `befund`: Die Messung stimmt (§Messungen), und die Fehl-Akzeptanz ist jetzt benannt, mit Alternative I und
  Trigger 5. Sie **hebt** sie aber nicht auf, sondern verschiebt sie: *alle* 608 Betreffzeilen `slice-mv:…`
  passieren die Menge über das **Präfix** `slice-m`, unabhängig davon, ob dahinter ein Slice-Name steht — der
  eine Betreff ohne Namen (`slice-mv: EINGEHEND zieht jetzt auch Adressen in docs/reviews nach`) gilt ebenso.
  „189 tragen eine Kennung" ist eine Aussage über den Bestand, nicht über die Prüfung. Dass ein Slice-Name eine
  Kennung im Sinn des Traceability-Constraints ist (dort: Requirement-ID, ADR-ID, Test/Gate/Demo,
  Dokumentations-Update; `AGENTS.md` §5 nennt Requirement- und ADR-IDs), sagt die Grenze mit *„im Sinn von
  §Vergabe"*, das die **Form** der Kennung regelt, nicht ob sie den Constraint erfüllt; die Menge trägt `slice-`
  bereits heute (`slice-[0-9]+`) als Setzung des Werkzeugs, und die ADR nennt sie so. Die Entscheidung ist
  damit vertretbar; ausgeschrieben fehlt, dass sie den Kandidaten aus `ADR-0053` Festlegung 4 (Form der
  Werkzeug-Messages) berührt und wie sie zu dessen Satz zur Ausnahme steht.
- `verifizierbar`: ja — ein bats-Fall `slice-mv: nur das Werkzeug` (ohne Slice-Name) zeigt die Annahme
- `klasse`: Präfix-Muster erweitert die Akzeptanz-Menge eines Anwesenheits-Gates (Wiederholung aus Runde 1, F-1)

### N-6 — INFO — Die bestehenden Mutations-Fälle auf der Prüfung hängen am heutigen Wortlaut der Menge

- `kategorie`: INFO · `quelle`: `MR-071` (die Fall-Anlage misst ihr `sed`-Muster gegen den Quell-Bestand),
  ADR-0065 §Fitness Function
- `pfad`: `test/mutations/342-kopplung-traeger-gewinnt-ein-muster.sh:18`,
  `test/mutations/340-…`, `347-…`, `354-…`, `355-…`, `356-kopf-klassen-weichen-von-patterns-ab.sh`
- `befund`: Fall 342 ersetzt `slice-\[0-9\]+)` in der `patterns=`-Zeile; die neue Zeile endet auf `welle-[a-z0-9])`,
  der Anker trifft nicht mehr. Fall 356 koppelt an die Klassen-Liste im Kopf der Prüfung (`{ADR-, LH-, MR-,
  slice-}`), die mit der neuen Menge wächst. Die Fitness Function nennt „je Muster einen Fall", nicht das
  Nachziehen der sechs vorhandenen Fälle. Umsetzungs-Hinweis für den Slice, kein Befund an den Festlegungen.
- `verifizierbar`: ja — `make mutate` (kein Gate; in dieser Runde nicht gefahren)
- `klasse`: Bestehende Zähne hängen am Wortlaut der Zeile, die die Entscheidung ändert

## Runde-1-Befunde

| Befund | Stand | Beleg dieser Runde |
|---|---|---|
| F-1 (Fehl-Akzeptanz `slice-mv`) | **behoben** (anders gelöst); Rest N-5 | Die Zahlen 608 / 190 / 189 / 476 / 475 reproduzieren exakt; der Nenner ist heute **3367** statt 3366 (ein Commit mehr im Log; Zahlen wandern, `MR-025`). Die Fehl-Akzeptanz steht in Grenze, Alternative I und Trigger 5 |
| F-2 (Festlegung 5 gegen 4) | **behoben** | Dogfood-Prüfung und `commits:`-Block ziehen mit; die Senkung nach `AGENTS.md` §3.5 ist in Festlegung 4 entschieden. Die neue Menge ist eine **Obermenge** der alten: über allen 3367 Betreffzeilen ohne Merge/Revert wird keine Zeile verloren (`0` von der alten Menge angenommene, von der neuen abgelehnte), **487** kommen hinzu (391 nur über `slice-`, 96 nur über `welle-`, 11 nur über `CO-`, **0** nur über ADR- oder Vertrags-Muster). `commits` steht nicht in `modules:` (`grep -n '^modules:' .d-check.yml` → neun Module ohne `commits`); die Kopplung trägt allein `test/commit-msg-hook.bats` |
| F-3 (Marker in Spec-Straten) | **behoben** (als Grenze) | am frischen Ziel: `slice-mv` in `spec/spezifikation.md` → 1 Befund, mit Marker am Zeilenende → 0; Grenze und Alternative C benennen das Umgehen |
| F-4 (Begründung 2(b)) | **behoben** mit Rest N-3 | *„Einträge werden nie überschrieben"* steht wörtlich (`grundlagen-harness-dateien.md` Z. 366); Analogieschluss markiert; Kosten gemessen: **6 Befunde in 5 Zeilen** ohne Neutralisierung, **0** mit Marker, ein zusätzlicher Anker (`seit slice-foo-bar` in einer `MR-001-x.md`) → **+1**, mit Marker 0; frisches Ziel: `grep -cE 'seit (slice\|welle)-' harness/conventions.md` → **0** |
| F-5 (blindes Instrument) | **behoben** | `adaptions-?block` in der Matrix-Tabelle → **0**, `❌` → **22** (`sed … \| grep -o '❌' \| wc -l`) |
| F-6 (Zuschreibungen) | **behoben** | freies Vertrags-Präfix: §ID-Schema (*„Das Vertrags-Präfix ist frei wählbar"*, `LH-FA-03` und `LH-FA-IDX-003` wohlgeformt); der Marker-Name steht in der Vorlage `.d-check.yml` (`grep -rl 'status-provenance' …/templates` → **1**, `…/regelwerk` → **0**); *„Der Autor markiert den zulässigen Zeiger in seiner Zeile"* (Z. 249) und *„die Ausnahme wird am Ort deklariert"* (Z. 248) wörtlich; *„Der Adaptions-Block trägt das Muster bereits über sein Feld Begründung"* wörtlich (Z. 81). Die ADR nennt in der Klammer `HSM-FA-03`/`HSM-FA-IDX-003`, das Regelwerk `LH-FA-03`/`LH-FA-IDX-003` — dieselbe Aussage mit anderem Beispiel-Präfix, kein Befund |
| F-7 (Messgegenstand) | **behoben** | frisches Ziel sprach-agnostisch und `--lang go --arch hexslice`: `cat spec/*.md \| grep -cE '(slice\|welle)-'` → **0** in beiden; `harness/conventions.md` → **5** Zeilen (124, 162, 167, 204, 212), `seit (slice\|welle)-` → **0** |
| F-8 (Trigger-Form) | **behoben** | Wortlaut *„ohne blockierenden Befund an der Substanz der sechs Festlegungen"* in der ADR (Z. 346) |
| F-9 (Kopf-Marke Proposed) | **behoben**; Rest N-1 | `git diff f1b3da6f 3ed32f2f -- harness/conventions/MR-057-…md` streicht genau die eine Zeile; `grep -rn 'ADR-0065' harness/` nennt keinen Verweis mehr; der ADR-Index trägt Zeile 0065 |
| F-10 (Ausschluss) | **behoben** | `git grep -lE 'slice-(\[0-9\]\|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'` → nur `harness/tools/commit-msg-traceability.sh` |
| F-11 (22 Zellen) | **behoben** | Ich zähle an der Matrix-Tabelle: Vertrag 7 + Technik 6 + Sicht 5 + ADR 3 + Slice 1 = **22**. Aufteilung der ADR: 3 (Rangfolge Vertrag→Technik, Vertrag→Sicht, Technik→Sicht) + 9 (Spalten ADR/Slice/Welle × drei Straten-Zeilen) + 1 (ADR→Welle) + 6 (Straten → Carveout/Roadmap, nur `aussen`, nur als Link) + 3 (ADR→Carveout, ADR→Roadmap, Slice→Roadmap) = 22. Das Bild der emittierten Vorlage stimmt (`aussen` hat nur `spec-straten` als Quelle) |
| F-12 (Menge als Liste) | **behoben** mit Rest N-2, N-4 | alle neun Annahmen, alle sieben Ablehnungen der ADR bestätigt (§Messungen); RE2-Verträglichkeit gemessen |
| F-13 (Nachzug-Vorbedingung) | **behoben** | Festlegung 5 nennt die Vorbedingung für 2(b) im bestehenden Ziel |
| F-14 (Vorbilder) | **behoben** mit Rest N-6 | `grep -l 'internal/emit/templates/d-check.yml' test/mutations/*.sh \| wc -l` → **11**; `295`, `297`, `298`, `372`, `374`, `375` existieren |

## Messungen (nachgefahren)

**(a) Commit-Menge, sechs Muster** — bash `[[ =~ ]]` mit `(ADR-[A-Z-]*[0-9]{4}|CO-[A-Z-]*[0-9]{3}|MR-[0-9]{3}|[A-Z]{2,}-[A-Z-]*[A-Z]-[0-9]{2,3}|slice-[a-z0-9]|welle-[a-z0-9])`,
je Zeichenfolge:

| Zeichenfolge | Ergebnis |
|---|---|
| `ADR-0004`, `ADR-IDX-0004`, `CO-AUTH-002`, `HSM-FA-03`, `HSM-FA-IDX-003`, `HSM-LESE-004`, `LH-QA-01`, `LH-FA-IDX-003`, `MR-057`, `slice-42`, `slice-mv-verweise`, `welle-cache-warmup`, `welle-1`, `slice-x` | angenommen (die neun der ADR-Liste bestätigt) |
| `ADR-4`, `SHA-256`, `UTF-8`, `ISO-8601`, `HTTP-200`, `RFC-7231`, `SPEC-042`, `slice-<Kennung>`, `slice-`, `welle-`, `Welle-1`, `Slice-mv`, `HSM-FA-3`, `HSM-lese-004`, `UTF-16-LE-01`, `CVE-2024-1234`, `GPT-4-TURBO-32` | abgelehnt |
| `slice-mv`, `anti-slice-mv` | angenommen (Präfix ohne Wortgrenze; von der Grenze benannt) |
| `SPEC-FA-042`, `ARC-FA-042`, `BEO-ALL-001`, `RC-AB-12`, `AES-CB-128`, `EN-ISO-9001`, `PR-A-12`, `CO-1234`, `HSM-FA-1234` | angenommen (N-2) |

Die Muster 1 bis 3 und 5 bis 6 sind einfache Präfix-Muster; Muster 4 überlappt Muster 1 und 2 für Kennungen mit
Segment (`ADR-IDX-0004`, `CO-AUTH-002` treffen auch Muster 4), das ändert die Menge nicht.

**Kopplung an `commits.id-patterns`:** Die sechs Muster stehen ohne verschachtelte Alternation nebeneinander.
`hook_patterns()` (`test/commit-msg-hook.bats:52-63`) trennt die Gruppe mit `tr '|' '\n'` und ersetzt `[0-9]` durch
`\d`; `config_patterns()` liest die Zeilen `- '…'` des `commits:`-Blocks. Beides verträgt die Menge (`{2,}`,
`[A-Z-]*` und `[0-9]{2,3}` enthalten kein `|` und kein Quote). **RE2 im Image gemessen:** in einem Scratchpad-Repo
mit der Menge als `commits.id-patterns` (`\d`-Dialekt) und `--commit-msg` im gepinnten d-check-Image
(`sha256:3f84502b…`) stimmen alle sechzehn geprüften Messages mit der bash-Fassung überein — die Zeichenketten
aus der Annahme-Liste passieren, `ADR-4`, `SHA-256`, `UTF-8`, `SPEC-042`, `ISO-8601`, `slice-`,
`slice-<Kennung>` und die Message ohne Kennung werden mit `commit-untraceable` abgelehnt. (Die Meldung des
Moduls nennt weiter *„DC-/ADR-/MR-/slice-ID"*, ein Werkzeug-Text, nicht Gegenstand der ADR.)

**Reale Betreffzeilen:** `git log --format=%s`, 3367 Zeilen ohne Merge/Revert (Bestand des HEAD). Alt-Menge →
Neu-Menge: keine Zeile verloren (Obermenge), 487 zusätzlich angenommen. Die 189 der ADR-Messung sind die
`slice-mv:`-Betreffe, die hinter dem Präfix einen Slice-Namen nennen; der eine übrige (`slice-mv: EINGEHEND …`)
gilt allein über das Wort. Nach dem Herausnehmen des Wortes `slice-mv` bleiben 486 von 487 angenommen.

**(b) Mitzieh-Entscheidung (Festlegung 4):** Eine Menge, die mehr Formen annimmt, ist eine Senkung der Strenge im
Sinn von `AGENTS.md` §3.5; die ADR benennt sie als solche und entscheidet sie (Bezug: die Formen, die `MR-057`
vorschreibt). Das trägt als ADR-Entscheidung, sobald sie `Accepted` ist. Es widerspricht weder dem Modul-Stand
(`commits` steht nicht in `modules:`) noch dem Bestand (Obermenge, keine verlorene Annahme). Die Begründung
deckt die Namen `slice-`/`welle-` (`MR-057`); für `CO-`, die Segment-Formen und das freie Vertrags-Präfix trägt
sie die Werkzeug-Setzung (siehe N-4).

**(c) Begründung 2(b):** siehe N-3; die Zwei-Fassungen-Kopplung (Alternative F: *„hält die zwei eingefrorenen
Artefaktklassen gleich"*) ist als eigene Zeile der Vergleichstabelle geführt.

**(d) 22 Zellen:** in der Tabelle F-11 oben.

**(e) Folgepflicht 2:** siehe N-1. Die ADR ist ehrlich darüber, dass kein Präzedenzfall besteht; die Form ist
nicht lizenziert.

**(f) Vertrags-Präfix `<PREFIX>(-[A-Z]+){1,2}-\d{2,3}`:** trägt `LH-FA-IDX-003` (zwei Segmente),
`HSM-FA-IDX-003`, `LH-QA-01`, `HSM-FA-03` und `HSM-LESE-004` (je ein Segment); `CO-([A-Z]+-)?\d{3}` trägt
`CO-AUTH-002` und `CO-002`. Als auskommentierter Vorschlag der Adopter-Setzung ist das ausreichend.

**(g) Grüner Start und Marker** — frisches Ziel (`--name demo`, Binär des HEAD) in `…/scratchpad/u1`; `make docs-check`
im gepinnten Image, `--network none`:

| Stand der `.d-check.yml` | Ergebnis |
|---|---|
| unverändert | `20 Datei(en) geprüft, 0 Befund(e)` |
| Token `slice-`/`welle-`, `spec-straten → welle`, `adaptionsblock → slice/welle` | **6 Befunde in 5 Zeilen**, alle `matrix-forbidden` mit der Regel `adaptionsblock → slice/welle` (Z. 124, 162, 167 ×2, 204, 212) |
| dieselbe Konfiguration, Marker `<!-- d-check:status-provenance -->` am Ende der 5 Zeilen | `0 Befund(e)` — der Marker wirkt mit dem Adaptions-Block als Quellklasse |
| + eine Datei `harness/conventions/MR-001-x.md` mit `seit slice-foo-bar` | 1 Befund (Regel `adaptionsblock → slice`), mit Marker 0 |
| + `slice-mv` in `spec/spezifikation.md` | 1 Befund (`spec-straten → slice`), mit Marker 0 |

`--lang go --arch hexslice`: `cat spec/*.md | grep -cE '(slice|welle)-'` → **0**, `seit (slice|welle)-` → **0**.
Nicht gemessen: das Rendering des Markers am Zeilenende einer Tabellenzeile (Z. 124 und 212 sind Tabellenzeilen);
mechanisch grün, sichtbar bleibt es dem Liefer-Punkt (ii).

## Geprüft, ohne Befund

- **Zitate am Original:** `grundlagen-referenz-richtung.md` (Gate-Text *„enthält `ADR-` oder `slice-` → fail, ohne
  ausgenommene Sektion"*, *„bewusst nur die grep-Variante"*, *„Mechanisierbar — über den umgekehrten Default"*,
  *„ehrlich gesetzt"*), `grundlagen-source-precedence.md` (§ID-Schema, §Vergabe: *„Welche Form gilt, deklariert
  das Repo"*, *„Welle- und Slice-Kennungen sind Namen, nicht Nummern"*), `grundlagen-traceability.md`
  (*„trägt das Muster bereits über sein Feld Begründung"*): wörtlich vorhanden; die drei in Runde 1 korrigierten
  Zuschreibungen (freies Präfix, Marker-Name, Herkunfts-Anker) stimmen jetzt mit den Stellen überein.
- **Matrix-Vorlage:** die emittierte Vorlage trägt `spec-straten → welle` heute nicht, `adr → slice/welle` mit
  Marker-Hinweis, `aussen` als letzte Klasse; die Klassen-Reihenfolge (First-Match) stützt die Aussage der ADR.
- **Beide Fassungen der Prüfung** (`internal/emit/templates/enforce/…` und `harness/tools/…`) tragen heute
  dieselbe `patterns=`-Zeile (`diff` leer).
- **Präfix als Obermenge der Ziffern-Form:** gemessen (F-2); die Nummern-Form bleibt gefangen.
- **`ADR-0007` Festlegung 3, `ADR-0054` Festlegung 1:** `.d-check.yml` und `harness/conventions.md` skip-if-present,
  Prüfung konvergent, Träger skip-if-present — die Reichweiten-Aussagen der ADR (Kontext, Festlegung 5) stimmen;
  die Nachzug-Vorbedingung ist genannt.
- **`MR-054`:** die Beleg-Pflicht (Zell-Messung als erster Liefer-Punkt, grüner Start je Sprache, Gegenbeispiel mit
  gelesener Meldung, Zahn je Muster) ist in Festlegung 6 vollständig; die sechs Muster sind je einzeln bindbar.
- **Ablage-Regeln:** die ADR trägt keine Slice-Kennung als Adresse, keine Pfad-Adresse auf ein wanderndes
  Artefakt (`AGENTS.md` §3.11); Zeilen mit Zahl tragen ihr Kommando (`MR-025`), der Tag `v6.9.0` steht (`MR-033`).
- **Schreib-Grenzen des Architect-Commits:** `git diff --stat d9bcd0b5 3ed32f2f` berührt nur die ADR und
  einen MR-Eintrag (Marke entfernt) — Architect-Artefakte, Rolle in der Message (`AGENTS.md` §3.8); der Runde-1-Report bleibt unverändert.
- **ADR-Index:** Zeile 0065, Status `Proposed`.

## Zeilen für den Steering-Loop-Zähler

- Folgepflicht schreibt eine Norm-Form vor, die die zitierte Norm nicht führt (N-1)
- Prosa-Zusage über eine Menge, die das Muster an anderer Form nicht hält (N-2)
- Begründung nennt eine Eigenschaft, die für den gefangenen Gegenstand nicht zutrifft (N-3)
- Zuschreibung ans Regelwerk reicht weiter als die Stelle (N-4)
- Präfix-Muster erweitert die Akzeptanz-Menge eines Anwesenheits-Gates (N-5; Wiederholung aus Runde 1, F-1)
- Bestehende Zähne hängen am Wortlaut der Zeile, die die Entscheidung ändert (N-6)

## Sensoren dieser Runde

`make host-bin` (sha256 gleich vor und nach dem Bau); Emit-Läufe des Binärs in Scratchpad-Kopien; `make
docs-check` am frischen Ziel im gepinnten d-check-Image (netzlos); `docker run … d-check --enable commits
--commit-msg` gegen die Menge; bash `[[ =~ ]]` und `grep -E` über `git log --format=%s`. Nicht gefahren:
`make mutate` (Auftrag), `make full-smoke`, `make test`. Der Bericht am Ende dieses Laufs nennt das Ergebnis von
`make gates` nach dem Commit.
