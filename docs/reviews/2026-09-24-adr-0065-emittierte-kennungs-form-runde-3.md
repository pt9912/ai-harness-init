# Review-Report: ADR-0065 (emittierte Kennungs-Form folgt dem Regelwerk), Runde 3 — 2026-09-24

**Review-Art:** Design — kurze Nachrunde einer `Proposed`-ADR, nur das Neue seit Runde 2. Runde 1:
`docs/reviews/2026-09-24-adr-0065-emittierte-kennungs-form-runde-1.md`; Runde 2:
`docs/reviews/2026-09-24-adr-0065-emittierte-kennungs-form-runde-2.md` (annahmefähig; N-1 MEDIUM, N-2 bis N-5 LOW,
N-6 INFO). Beide unangetastet.

**Gegenstand:** `git diff 01f480fa e23919fe -- docs/plan/adr/0065-*.md` (Architect-Korrektur, 109 Einfügungen, 47
Löschungen) und der Link-Fix `8ff8cf88` (vier Kennungen als Anker-Link). Der Arbeitsbaum war zu Beginn sauber.

**Rolle:** Reviewer, frischer Kontext. Nichts aus der Selbstauskunft des Architects wurde ungeprüft übernommen;
jede Messung der ADR, die sich lesend fahren ließ, ist nachgefahren. Im Repo wurde nur diese Datei geschrieben.

## Gesamturteil

**Annahmefähig.** Kein HIGH, kein MEDIUM. Der einzige MEDIUM aus Runde 2 (N-1, Folgepflicht 2) ist behoben, und
zwar auf dem Weg, der keine neue Norm braucht: Der Accept-Commit fasst Status, Index und Geschichte-Zeile an und
sonst nichts. Der tragende Satz *„keine Aussage von `MR-057` fällt"* trägt am Original (§N-1-Prüfung). Diese Runde
findet **vier LOW** an der Begründung und der Messbarkeit einer Aussage; keiner betrifft die Substanz der sechs
Festlegungen.

**Acceptance-Trigger.** Wortlaut in der ADR (§Re-Evaluierungs-Trigger, Absatz *Acceptance-Trigger*): *„…wenn eine
Reviewer-Runde über die dann geltende Fassung sie gegen ADR-0007 (Festlegung 3), ADR-0053, ADR-0054 (Festlegung 1)
und MR-054 auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund an der Substanz der sechs
Festlegungen in `docs/reviews/` liegt. Ein blockierender Befund an der Darstellung … wird behoben und hindert die
Annahme nicht."* Diese Runde hat die Fassung `8ff8cf88` geprüft (ADR-0053 Festlegung 4 wörtlich, MR-054 und
ADR-0054 über die Runde-2-Belege, soweit unberührt); ihr Report führt keinen blockierenden Befund an der Substanz.
**Der Trigger ist erfüllt.** Die vier LOW gehören in den Kreis der Darstellung und hindern die Annahme nicht. Die
Annahme selbst bleibt beim Auftraggeber.

## Findings

### A-1 — LOW — Folgepflicht 2, drittes Begründungsglied: der Ausschluss von `docs/plan/adr/` trägt die Aussage nicht

- `kategorie`: LOW · `quelle`: `MR-032`, `MR-020`, `MR-046` (je `Geltungsbereich`), ADR-0065 Folgepflicht 2
- `pfad`: `docs/plan/adr/0065-…md:306-311` (Absatz „Der Grund liegt in den Regeln der Einträge selbst")
- `befund`: Die ADR nennt drei Gründe, warum der Accept-Commit `MR-057` nicht markiert: Marke ist an einen
  ablösenden **Eintrag** gebunden (`MR-032` Setzung 4), ihr Ziel ist die Anker-Adresse eines Eintrags (Setzung 1),
  *„und die Instrumente Marke und Aufhebung nehmen `docs/plan/adr/` aus ihrem Geltungsbereich aus"*. Die ersten
  beiden tragen (Wortlaut geprüft). Das dritte Glied stimmt buchstäblich — `MR-032`: *„Nicht `docs/plan/adr/` — dort
  gilt `AGENTS.md` §3.4 unverändert"*, `MR-020`/`MR-046` gleich — betrifft aber die Frage, ob eine **ADR selbst** eine
  Marke bekommt (§3.4, immutabel), nicht die, ob eine ADR als **ablösender** Vorgang einen Eintrag markieren darf.
  Für die letztere Frage sagt es nichts; als dritter Grund gelesen, behauptet es mehr, als die drei Einträge sagen.
- `verifizierbar`: ja — `grep -n 'docs/plan/adr' harness/conventions/MR-032-*.md harness/conventions/MR-020-*.md harness/conventions/MR-046-*.md`
- `klasse`: Zitat trägt eine Nachbar-Aussage, nicht die behauptete

### A-2 — LOW — „Die Grenze, die den Vertrag gegenüber Zielrepos nennt, ist bereits abgelöst": die Marke am Eintrag ist enger als die Ablösung

- `kategorie`: LOW · `quelle`: `MR-057` (zweite `ÜBERHOLT`-Zeile, Feld `Grenze`), `MR-059` (`Geltungsbereich`, Setzung 4)
- `pfad`: `docs/plan/adr/0065-…md:314-318`; `harness/conventions/MR-057-…md:3-4, 100-108`
- `befund`: Der Satz stimmt in der Sache: `MR-059` löst *„das Feld `Grenze` von MR-057 — die einzige Stelle"* ab, und
  seine Setzung 4 sagt, ein Zielrepo-Vertrag *„wird von dem Vorgang entschieden, der die Tool-Ebene entscheidet"*.
  Die Marke am Kopf von `MR-057` benennt dagegen nur *„die namentliche Fundmenge samt ihrem Kommando im Feld
  `Grenze`"*; der Satz *„wer es bewegt, ändert einen Vertrag gegenüber Zielrepos"* steht im Rumpf ohne Marke, und
  ein Leser des Eintrags erfährt von der Ablösung dieses Satzes nur über `MR-059`. Die ADR stützt ihr *„bereits
  abgelöst"* auf die Ablösung durch `MR-059`, nicht auf die Marke — das ist zulässig; der Satz *„Die Grenze, die den Vertrag gegenüber Zielrepos nennt, ist bereits
  abgelöst"* liest sich aber, als decke die Marke ihn, und sie deckt nur die Fundmenge.
  Widerspruch zu ADR-0065 entsteht daraus nicht: der Satz sagt, dass ein anderer Vorgang die Ebene entscheidet.
- `verifizierbar`: ja — `sed -n 3,4p harness/conventions/MR-057-*.md` gegen `sed -n 12,20p harness/conventions/MR-059-*.md`
- `klasse`: Zuschreibung reicht weiter als die Stelle

### A-3 — LOW — „Eine Wortgrenze rechts bräuchte ein verschachteltes `|`": gemessen nicht zwingend

- `kategorie`: LOW · `quelle`: ADR-0065 Festlegung 4, `test/commit-msg-hook.bats` (`hook_patterns`)
- `pfad`: `docs/plan/adr/0065-…md:212-215`
- `befund`: Die ADR sagt, eine Wortgrenze rechts vom Zahlenteil *„bräuchte eine Alternative im Muster
  (`([^0-9]|$)`)"*. Gemessen in bash (`[[ =~ ]]`, ERE): `ADR-[0-9]{4}([^0-9].*)?$` nimmt `ADR-0004`, `ADR-0004: x`,
  `ADR-0004,x` an und lehnt `ADR-00041` ab — ohne `|`. Die Form verlangt, dass das Muster bis Zeilenende trägt
  (`$`, je Zeile), sie ist also nicht kostenlos, und `hook_patterns` (trennt an **jedem** `|` mit `tr '|' '\n'`,
  Zeile 62, und streift die äußere Klammer) verträgt sie. Was die ADR entscheidet — die Menge nimmt
  `HSM-FA-1234` an, die Grenze sagt es — bleibt tragfähig; die Begründung *„bräche sie"* ist für die genannte
  Form richtig, für die Aufgabe „Wortgrenze rechts" nicht ausschließlich. Die Aussage zum Lookahead (*„den weder
  POSIX-ERE noch der Dialekt des `commits`-Moduls kennt"*) betrifft den **Ausschluss** einer Klasse und ist von
  dieser Messung nicht berührt.
- `verifizierbar`: ja — `P='ADR-[0-9]{4}([^0-9].*)?$'; [[ "ADR-00041" =~ $P ]]` → Exit 1
- `klasse`: Unmöglichkeits-Aussage über ein Muster, die ein Gegenbeispiel hat

### A-4 — LOW — Folgepflicht 1: die Zahl neben dem Kommando misst eine andere Menge als der Satz, an dem sie steht

- `kategorie`: LOW · `quelle`: `MR-025` (Zahl steht neben dem Kommando, das genau sie liefert), `MR-071`, ADR-0065
  Folgepflicht 1
- `pfad`: `docs/plan/adr/0065-…md:293-300`
- `befund`: Der Satz spricht von den Mutations-Fällen, *„die die `patterns=`-Zeile oder die Klassen-Liste an ihrem
  Wortlaut verankern"*; das Kommando `grep -l 'commit-msg-traceability' test/mutations/*.sh | wc -l` liefert **6**
  (stimmt), zählt aber alle Fälle, die die Prüfung berühren. Gelesen: `342` (`slice-\[0-9\]+)` in der Zeile) und `356`
  (Klassen-Liste `{ADR-, LH-, MR-, slice-}`) verankern am Wortlaut, `355` an einem Meldungs-Text; `340` und `347`
  ersetzen `^patterns=.*$` (robust gegen die neue Zeile), `354` ist die Agenten-Kanal-Pfadliste und hängt an keinem
  von beiden. Die Zahl 6 ist eine Obergrenze der Menge des Satzes, nicht diese Menge. Die ADR hält das offen
  (*„die Zahl wandert"*; *„über ihre Eigenschaft gefunden, nicht über eine Nummer"*); die Stellen für den
  Nachzug (Klassen-Liste im Kopf, `harness/sensors/commit-msg-check.md` Zeilen 10-11, die Zeile in
  `harness/README.md` §Traceability) stimmen dagegen.
- `verifizierbar`: ja — `make mutate` nach der Umsetzung zeigt, welche Fälle ihren Anker verlieren
- `klasse`: Zahl neben einem Kommando, das eine Obermenge des behaupteten Gegenstands misst

## Prüfung der Schwerpunkte des Auftrags

### N-1 (Runde 2) — Option (ii), Folgepflicht 2: Trägt der Satz? — **ja**

- **`MR-057` am Original.** `Geltungsbereich`: *„**Nicht** die emittierte Ebene: Was ein Zielrepo an Kennungs-Form
  bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet."* `Grenze` (Rumpf, Zeilen 105-108): *„Die emittierte
  Ebene ist von dieser Grenze getrennt und bleibt außen vor … wer es bewegt, ändert einen Vertrag gegenüber
  Zielrepos."* Beide Sätze sagen, dass der Eintrag die emittierte Ebene **nicht bindet** und ein anderer Vorgang sie
  entscheidet; ADR-0065 ist dieser Vorgang. Eine Aussage von `MR-057` fällt dadurch nicht — nichts in
  `Geltungsbereich`, den Setzungen 1 bis 3 oder `Auflösungs-Trigger` behauptet etwas über die emittierte Form.
- **`MR-059` Setzung 4** (Zeilen 88-93): *„Was ein Zielrepo an Kennungs-Erkennung bekommt, ist ein Vertrag
  gegenüber Zielrepos und wird von dem Vorgang entschieden, der die Tool-Ebene entscheidet"* — dasselbe, in der
  Ablösung des Grenze-Felds. ADR-0065 ist mit `MR-059` Setzung 4 konsistent. Der Auflösungs-Trigger dort
  (*„Setzung 4 fällt mit der Vertrags-Grenze gegenüber Zielrepos"*) tritt nicht ein: die ADR legt einen
  Ziel-Default fest, ändert die Vertrags-Grenze aber nicht (das Ziel überschreibt über `HOOKS_DIR`).
- **Bleibt der Block still veraltet?** Nein, im Sinn von `MR-032` §Begründung (*„Wer auf dem Vorgänger landet,
  erfährt sonst nichts"*): der Leser von `MR-057` erfährt *„die emittierte Ebene entscheidet ein anderer
  Vorgang"* und wird nicht zu einer falschen Handlung geführt; ADR-0065 steht im ADR-Index. Die datierten
  Zählungen zur emittierten Vorlage in `MR-057` (`… | wc -l → 3`) und in `MR-068` sind Momentaufnahmen mit Kommando,
  die die Umsetzung bewegt; `MR-053` führt die Regel für datierte Werkzeug-Aussagen. Restunschärfe: A-2.
- **„Wortlaut-Differenz" zutreffend gelesen?** Ja. Der Eintrag sagt *„der Slice, der die Tool-Ebene entscheidet"*;
  die Entscheidung liegt in ADR-0065, der Slice liefert sie. Dieselbe Formel steht in `AGENTS.md` (§3.7, §3.8, §3.10),
  `MR-025`, `MR-031`, `MR-033`, `MR-035` als Kürzel für den Vorgang, der die Tool-Ebene entscheidet, nicht als
  Aussage über eine Kennungs-Klasse.
- **Ist Folgepflicht 2 im Accept-Commit ohne weitere Norm ausführbar?** Ja: Status-Zeile, ADR-Index
  (`docs/plan/adr/README.md`, Architect nach ADR-0024) und Geschichte-Zeile; kein Adaptions-Block-Commit im Sinn von
  `AGENTS.md` §3.8 entsteht. Der Accept-Commit bleibt ein reiner Architect-Commit.
- **Beleg am Baum:** `grep -h '^> \*\*ÜBERHOLT' harness/conventions/*.md | grep -c 'ADR-'` → **0** — keine Marke des
  Bestands zeigt auf eine ADR. Das stützt die ADR: ohne Präzedenzfall wäre die Marke in Runde 2 eine Form ohne Norm
  gewesen; Option (ii) vermeidet sie.
- **Alternative J** steht in der Vergleichstabelle (Zeile mit Zielen Marke und Eintrag, beide mit ihrem Nachteil);
  ihr Nachteil-Satz ist zutreffend (die Marke zeigte auf einen Eintrag, nicht auf eine ADR; ein Eintrag müsste eine
  Aussage ablösen, die nicht fällt).

### 2(b) neu begründet — Zitate am Original

| Zitat der ADR | Quelle | Befund |
|---|---|---|
| *„beide sind normativ wie eine ADR, nur ohne deren Immutabilität"* | `AGENTS.md` §3.8 | wörtlich (`grep -c -F` → 1); als Aussage des Briefings gekennzeichnet |
| *„wo verifiziert/entstanden, nie warum entschieden"* | `grundlagen-referenz-richtung.md` Zeile 36, ADR-Zeile der Matrix | wörtlich (dort fett: **wo** / **warum**) |
| *„Alles Richtung Slice oder zwischen Slices ist Planungskontext, keine Spezifikation"* | dieselbe Datei, *Tragende Regeln* 1 (Z. 160-161) | wörtlich |
| *„Welle und Roadmap stehen außerhalb der normativen Klammer"* | dieselbe, *Tragende Regeln* 4 (Z. 169) | wörtlich |
| *„Der Autor markiert den zulässigen Zeiger in seiner Zeile"*, *„die Ausnahme wird am Ort deklariert"* | dieselbe, §Mechanisierbar | wörtlich (`grep -c` je 1) |
| *„Die Kennung bleibt Adresse — einen Hop länger"* | `modul-05-planning-harness.md` | wörtlich; die Stelle spricht vom geschlossenen Slice und seinem Nachnehmer, dass der Name nicht wandert, folgt aus ihr und der Kennung-statt-Adresse-Regel |
| *„Der `git mv` zieht die Pfad-Berichtigung nach sich, als eigener Commit nach dem Umzug. Der Wächter ist die Existenzprüfung des Links."* | `grundlagen-traceability.md` §Herkunfts-Anker, Ruheort-Regel, Gegenrichtung | wörtlich (bei Zeilenumbruch; auf eine Zeile normalisiert) |
| *„Der Adaptions-Block trägt das Muster bereits über sein Feld *Begründung*."* | `grundlagen-traceability.md` §Herkunfts-Anker | wörtlich |

**Kein Rotten-Anspruch mehr:** die ADR schreibt jetzt aus, was 2(b) **nicht** trägt (*„ein Wächter gegen tote
Adressen"*), und trägt die Analogie zur ADR-Zeile allein. Damit ist N-3 aus Runde 2 behoben.

### Festlegung 4 — Prosa gegen Liste, sechs Muster gegen die Messung

Gemessen mit `[[ =~ ]]` über die Gruppe `(ADR-[A-Z-]*[0-9]{4}|CO-[A-Z-]*[0-9]{3}|MR-[0-9]{3}|[A-Z]{2,}-[A-Z-]*[A-Z]-[0-9]{2,3}|slice-[a-z0-9]|welle-[a-z0-9])`,
wörtlich aus der ADR:

| Klasse der ADR-Liste | Zeichenfolgen | Ergebnis |
|---|---|---|
| nimmt an (zehn) | `ADR-0004`, `ADR-IDX-0004`, `CO-AUTH-002`, `HSM-FA-03`, `HSM-FA-IDX-003`, `HSM-LESE-004`, `LH-FA-BUILD-008`, `slice-42`, `slice-mv-verweise`, `welle-cache-warmup` | alle angenommen |
| lehnt ab (zehn) | ohne Kennung, `ADR-4`, `SHA-256`, `UTF-8`, `SPEC-042`, `ARC-042`, `RC-042`, `BEO-042`, `slice-<Kennung>` | alle abgelehnt (die zehnte Form der ADR, eine Kennung nur in einer Kommentarzeile, ist eine Eigenschaft der Prüfung, nicht des Musters) |
| nimmt an, obwohl keine Kennung gemeint (neun) | `SPEC-FA-042`, `BEO-ALL-001`, `RC-AB-12`, `AES-CB-128`, `EN-ISO-9001`, `CO-1234`, `HSM-FA-1234`, `slice-mv`, `anti-slice-mv` | alle angenommen |

Damit sind N-2 (Fehl-Akzeptanz mit Segment) und die Prosa-gegen-Liste-Lage aus Runde 2 behoben; die Rubrik ist
vollständig gegen die Muster gemessen. Zu den Aussagen über ERE/RE2: der **Lookahead**-Satz stimmt (weder POSIX-ERE
noch RE2 führen einen Lookahead); der **Wortgrenze**-Satz siehe A-3. `hook_patterns` (`test/commit-msg-hook.bats:52-63`)
trennt tatsächlich an jedem `|` (`tr '|' '\n'`, Z. 62) und streift nur die äußere Klammer — ein verschachteltes `|`
bräche die Kopplung wie behauptet.

### Grenze zu `slice-mv:` gegen ADR-0053 Festlegung 4

Das Zitat der ADR — *„eine Zeile, die `slice-mv:`-Messages von der Prüfung nimmt, wäre eine Senkung der Durchsetzung"* —
steht wörtlich in `docs/plan/adr/0053-…md` Zeile 248 (§Kandidat, Festlegung 4; dort *„eine Zeile … wäre eine
**Senkung** der Durchsetzung (`AGENTS.md` §3.5)"*). Die ADR nennt die Konsequenz ehrlich: keine Ausnahme-Zeile,
aber *„dieselbe Wirkung"* für die Klasse; sie erklärt die Entscheidung zur Senkung im Sinn von §3.5. Die Bestands-
Messung reproduziert: `git log --format=%s | grep -c '^slice-mv:'` → **608**, ohne Kennung nach der bisherigen Menge
→ **190**, mit `slice-`/`welle-` hinter dem Präfix → **189** (der eine übrige: `slice-mv: EINGEHEND zieht jetzt
auch Adressen in docs/reviews nach`). N-5 aus Runde 2 ist damit behoben.

### Folgepflicht 1

Stellen geprüft: Klassen-Liste im Kopfkommentar (`harness/tools/commit-msg-traceability.sh` Z. 5-6:
`{ADR-, LH-, MR-, slice-}`) ✓; Sensor-Text (`harness/sensors/commit-msg-check.md` Z. 10-11 nennt die alte Menge) ✓;
die Zeile zu Werkzeug-Commits in `harness/README.md` §Traceability (mit dem Kommando *44 von 411*) ✓; Mutations-Fälle
(A-4). N-6 aus Runde 2 ist behoben; die Zahl misst nicht genau den Satz.

### Fehlerklasse „das Regelwerk sagt …" und Ablage-Regeln

- Jede Aussage der Form „das Regelwerk sagt/verlangt" in den geänderten Absätzen trägt die Stelle wörtlich (Tabelle
  oben); `welle-` ist jetzt korrekt auf die Matrix-Spalte und §Vergabe gestützt, nicht auf die ID-Liste der Vorlage
  (die Vorlage führt `welle-*` nur als Dateifamilie, Z. 112; `SPEC-<NNN>`/`ARC-<NNN>`/`BEO-<NNN>`/`RC-<NNN>` in Z. 106-107
  flach). N-4 aus Runde 2 ist damit behoben.
- Pflichtgliederung: `## Kontext / Entscheidung / Verglichene Alternativen / Konsequenzen / Fitness Function /
  Re-Evaluierungs-Trigger / Geschichte`; `### Grenze` steht unter `## Konsequenzen`; kein `## Grenze`.
- §3.7/§3.11: keine Slice-Kennung als Adresse in der ADR (`grep` auf `slice-<wort>-<wort>` außerhalb `slice-mv` → keine
  Fundstelle); der Link-Fix `8ff8cf88` ändert nur Anker-Formen der `MR-057`-Erwähnungen und den Text
  „Eintrag der Adoptions-Erklärung"; `make gates` (Doku-Gate `ids`) fährt die Auflösung.
- `MR-025`: die neuen Zahlen (608/190/189, 6, 11) tragen ihr Kommando; 6 siehe A-4.

## Runde-2-Befunde

| Befund | Stand |
|---|---|
| N-1 (MEDIUM, Folgepflicht 2, Marke ohne Form) | **behoben** — Option (ii), Alternative J, Folgepflicht 2 umformuliert |
| N-2 (Struktur-IDs mit Segment angenommen) | **behoben** — Rubrik neun Fälle, Grenze schreibt sie aus |
| N-3 (Begründung 2(b), Rotten) | **behoben** — Analogie und Nicht-Träger getrennt ausgeschrieben |
| N-4 (`welle-` nicht in der ID-Liste) | **behoben** |
| N-5 (Konsistenz zu ADR-0053 F4) | **behoben** — ausgeschrieben, Senkung benannt |
| N-6 (Mutations-Fälle hängen am Wortlaut) | **behoben** in der Folgepflicht 1; Rest A-4 |

## Geprüft, ohne Befund

- **Alternative J / Folgepflicht 2 gegen `MR-032` Setzung 1, 3, 4:** Wortlaut der Zitate stimmt; *„Ändert eine spätere
  Entscheidung eine Aussage des Eintrags, gilt der Weg der Einträge (Setzung 3)"* ist die Setzung.
- **Bestands-Messungen der Grenze (608/190/189):** reproduziert am HEAD.
- **Neue Muster-Zählungen der Liste:** alle 10 + 8 + 9 Fälle einzeln gemessen (Tabelle oben).
- **Wirkung auf `MR-054` / `MR-017` / `MR-068`:** keine Aussage dort trifft die Kennungs-Menge oder die
  Adaptions-Block-Regeln; `MR-068` führt eine datierte Zählung der emittierten Vorlage (Momentaufnahme, `MR-053`).
- **Rollen-Grenzen:** der Architect-Commit `e23919fe` berührt nur die ADR; `8ff8cf88` ebenso; kein Adaptions-Block-
  Commit (`AGENTS.md` §3.8).

## Zeilen für den Steering-Loop-Zähler

- Zitat trägt eine Nachbar-Aussage, nicht die behauptete (A-1)
- Zuschreibung reicht weiter als die Stelle (A-2; Wiederholung aus Runde 2, N-4)
- Unmöglichkeits-Aussage über ein Muster, die ein Gegenbeispiel hat (A-3)
- Zahl neben einem Kommando, das eine Obermenge des behaupteten Gegenstands misst (A-4)

## Sensoren dieser Runde

`git diff`/`git show` über die zwei Commits; bash `[[ =~ ]]` über die Muster-Gruppe (27 Zeichenfolgen) und über das
Gegenbeispiel aus A-3; `git log --format=%s` mit `grep -c` (Bestand); `grep -F` gegen die vendorte Baseline, `AGENTS.md`
und die Einträge `MR-020`, `MR-032`, `MR-046`, `MR-057`, `MR-059`. Nicht gefahren: `make mutate` (Auftrag),
`make full-smoke`, `make test`. Das Ergebnis von `make gates` nach beiden Commits steht im Bericht am Ende des Laufs.
