# ADR-0065: Die emittierte Konfiguration folgt der Kennungs-Form des Regelwerks — Präfix-Token für Slice und Welle, die Welle-Regel der Spec-Straten, eine deklarierte Erweiterung für den Adaptions-Block und eine Commit-Menge in den Formen des Regelwerks

**Status:** Accepted

**Datum:** 2026-09-24

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen),
[`LH-FA-03`](../../../spec/lastenheft.md#lh-fa-03--doc-gate-baseline-emittieren-f6-f7) (die emittierte `.d-check.yml`),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) (die emittierte Commit-Prüfung),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0007](0007-bootstrap-phasen.md) (Idempotenz-Klassen: `.d-check.yml` ist skip-if-present),
[ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) und
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) (Prüfung konvergent, Träger skip-if-present),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel) (Erprobung, grüner Start, rotes Gegenbeispiel),
[`MR-055`](../../../harness/conventions.md#mr-055--eine-stellen-messung-trägt-keine-folgerung-über-eine-eigenschaft) (eine Messung trägt die Stelle, die sie liest),
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) (die Namens-Form; ihre Grenze zur emittierten Ebene ist der Anlass),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)

**Schärft:** — (Prozess-ADR über den Inhalt zweier emittierter Dateien; keine Spec-Aussage ändert sich, die
Idempotenz-Klassen aus [ADR-0007](0007-bootstrap-phasen.md) bleiben, wie sie sind.)

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

Der Auftraggeber liefert das Regelwerk `v6.9.0` an Zielrepos; die emittierte `.d-check.yml` und die
emittierte Commit-Prüfung müssen zu ihm passen.
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
hat die Namens-Form für dieses Repo gesetzt und die emittierte Ebene ausdrücklich ausgenommen — wer sie
bewegt, ändert einen Vertrag gegenüber Zielrepos. Diese Entscheidung ist jener Vertrag.

**Die Quellen, gegen `v6.9.0` gemessen.** Die Matrix-Tabelle in `grundlagen-referenz-richtung.md`
setzt in den Zeilen Vertrag, Technik und Sicht die Spalten ADR, Slice, Carveout, Welle und Roadmap auf ❌.
Der maschinelle Gate-Text (§Prüfung, dort *„Maschineller Gate"*) lautet *„enthält `ADR-` oder `slice-` → fail,
ohne ausgenommene Sektion"*; er nennt `welle-` nicht, die Spalte Welle der Matrix tut es. Die Baseline liefert
*„bewusst nur die grep-Variante"* aus. `grundlagen-source-precedence.md` §ID-Schema als Klammer lässt das Vertrags-Präfix
frei (`HSM-FA-03` und `HSM-FA-IDX-003` sind beide wohlgeformt); §Vergabe setzt *„Welle- und Slice-Kennungen sind Namen,
nicht Nummern"*, nennt ADR und Carveout mit Bereichssegment (`ADR-IDX-0004`, `CO-AUTH-002`) und verlangt
*„Welche Form gilt, deklariert das Repo"*.

```sh
R=.harness/baseline/v6.9.0/regelwerk
grep -c 'enthält `ADR-` oder `slice-`' $R/grundlagen-referenz-richtung.md                              # 1
grep -c 'Welle- und Slice-Kennungen sind Namen, nicht Nummern' $R/grundlagen-source-precedence.md       # 1
sed -n '/^| Dokument ↓/,/^| \*\*Roadmap/p' $R/grundlagen-referenz-richtung.md | grep -o '❌' | wc -l    # 22
sed -n '/^| Dokument ↓/,/^| \*\*Roadmap/p' $R/grundlagen-referenz-richtung.md | grep -ciE 'adaptions-?block'   # 0
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Stand; die letzte trägt die Aussage: Die Matrix-Tabelle des Regelwerks
führt den Adaptions-Block **nicht** als Klasse. Gemessen am adoptierten Stand `v6.9.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).

**Das Regelwerk widerspricht sich an der Form.** Sein Text (§Vergabe) setzt die Namens-Form unabhängig von der
Schreiberzahl; seine Vorlagen führen `slice-\d{3}` (`.d-check.yml`, auskommentiert) und `slice-<KUERZEL>-NNN` samt
Bereichssegment bei mehreren Schreibern (`conventions.template.md`). Diese Entscheidung folgt dem Text und
deklariert das, was §Vergabe dem Repo überlässt; den Widerspruch im Regelwerk löst sie nicht auf.

**Die emittierte Vorlage, gemessen.**

| Stelle | Regelwerk | emittiert heute | Befund |
|---|---|---|---|
| Token Slice | `slice-` (Präfix), Namens-Form | `slice-\d{3}` | ein benannter Slice wird nie gefangen |
| Token Welle | Matrix-Spalte Welle ❌ | `welle-\d{2}` | dasselbe |
| Regel Spec-Straten → Welle | Matrix-Tabelle ❌ ×3 | fehlt | die Klasse steht vor `aussen`, also fängt sie `aussen` nicht |
| Adaptions-Block → Slice/Welle | keine Klasse in der Matrix-Tabelle | Klasse nur als Ziel von `spec-straten` | keine Regel mit dem Block als Quelle |
| Muster `ids` | Vertrags-Präfix frei, ADR/Carveout mit Segment | nur `ADR-\d{4}` aktiv; Vertrag und Carveout nicht | `ADR-IDX-0004` wird nicht als Kennung gelesen |
| Klasse `adr` | Bereichssegment im Dateinamen möglich | Glob `docs/plan/adr/[0-9]*.md` | eine Datei `IDX-0004-…` liegt außerhalb der Klasse |
| Commit-Menge | Traceability-Constraint: u. a. Requirement-ID, ADR-ID (Kennung im Commit) | `ADR-[0-9]{4}`, `LH-[A-Z]{2}-[0-9]{2}`, `MR-[0-9]{3}`, `slice-[0-9]+` | träfe weder `ADR-IDX-0004` noch `LH-FA-IDX-003` noch `CO-…` noch einen benannten Slice |

```sh
grep -nE "token: '(slice|welle)-" internal/emit/templates/d-check.yml        # Z. 53 und 54 tragen die Ziffern-Form
grep -n "^patterns=" internal/emit/templates/enforce/commit-msg-traceability.sh harness/tools/commit-msg-traceability.sh
```

Die Vorlage des Regelwerks (`.harness/baseline/v6.9.0/templates/.d-check.yml`) trägt `slice-\d{3}` auskommentiert.
Ihr Satz *„diese Datei bildet die dortige Setzung nur ab"* steht am Absatz über `exclude-sections`; er stützt
die Aussage über die Token nicht.

**Was der grüne Start trägt.** Die Positionen mit Präfix-Token (Festlegungen 1 und 2(a)) sind am frisch emittierten
Ziel grün: `cat spec/*.md | grep -cE '(slice|welle)-'` im Ziel → **0**. Messgegenstand ist der emittierte Bestand
eines sprach-agnostischen Laufs, nicht die Spec-Vorlagen des Regelwerks; die Ziele mit `--lang`/`--arch` misst der
Liefer-Punkt (ii) aus Festlegung 6. Über dem emittierten Adaptions-Block sind die Positionen es nicht:
`grep -cE '(slice|welle)-' harness/conventions.md` im Ziel → **5** Zeilen (vier aus den Platzhaltern der Vorlage
`conventions.template.md`, eine aus dem Werkzeug-Satz des Emitters mit `make slice-mv`). Herkunfts-Anker trägt der
emittierte Block keine: `grep -cE 'seit (slice|welle)-' harness/conventions.md` im Ziel → **0**.

**Was das eigene Repo hält.** `.d-check.yml` dieses Repos führt weder die Klasse `welle` noch `adaptionsblock`
(`sed -n '/^matrix:/,/^codepaths:/p' .d-check.yml | grep -cE 'name: (welle|adaptionsblock)'` → **0**), und die
Klasse `slice` trägt kein `token:`. Der eigene Adaptions-Block nennt `slice-<x>` blank in
`grep -cE '(^|[^A-Za-z-])slice-[a-z0-9]' harness/conventions.md harness/conventions/*.md harness/conventions/done/*.md`
→ **113** Zeilen in **54** Dateien (Summe der Trefferzeilen, Dateien mit Treffer) — darunter die Wirksamkeits-Anlässe
nach [`MR-028`](../../../harness/conventions.md#mr-028--der-wirksamkeits-anlass-steht-im-eintrag-blank-statt-verlinkt),
die die Slice-Nummer blank *verlangen*. Der Bestand ist eingefroren
([`AGENTS.md`](../../../AGENTS.md) §3.4, Disziplin des Adaptions-Blocks). Das Lastenheft führt 10 Zeilen mit
`slice-`/`welle-` (`grep -cE '(slice|welle)-' spec/lastenheft.md`), eine davon im Text
(`grep -c 'slice-lokal' spec/lastenheft.md` → **1**), die übrigen in §7 Historie, die die eigene Konfiguration
ausnimmt. Ihr `commits:`-Block führt dieselbe Kennungs-Menge wie die Dogfood-Prüfung, und
`test/commit-msg-hook.bats` verlangt Mengen-Gleichheit beider; der Block wird nur von `make commit-msg-check`
gelesen, das `commits`-Modul steht nicht in `modules:` (`grep -n '^modules:' .d-check.yml`).

**Reichweite.** `.d-check.yml` wird nur an einem freien Pfad geschrieben
([ADR-0007](0007-bootstrap-phasen.md) Festlegung 3); ein zweiter Lauf am Ziel mit vorhandener Datei ist
still (an einem frisch emittierten Ziel gemessen: eine angehängte Adopter-Zeile blieb stehen, und der Lauf nannte die
Datei nicht). Dasselbe gilt für `harness/conventions.md`. Die Commit-**Prüfung** wird dagegen bei jedem Lauf
kanonisch neu geschrieben, der Träger nur an einem freien Pfad
([ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md)). Eine geänderte Vorlage erreicht also neue Ziele
über die Konfiguration und **alle** Ziele über die Prüfung.

## Entscheidung

Wir folgen dem Regelwerk `v6.9.0` in der emittierten Konfiguration an den Stellen, die es setzt, und
deklarieren die Stellen, an denen wir darüber hinausgehen.

**1. Die Token sind Präfixe, die Namens-Form ist die Voreinstellung.** Auf der Klasse `slice` steht `slice-`, auf der
Klasse `welle` steht `welle-`. `slice-` ist der Wortlaut des Gate-Satzes; `welle-` ist die Setzung dieser
Entscheidung aus der Matrix-Spalte Welle, nicht aus dem Gate-Text. Das Präfix ist eine Obermenge der Nummern-Form:
ein Ziel, das seine Slices nummeriert, bleibt gefangen, und ein Ziel darf die Nummern-Form behalten, wenn es sie in
seiner `harness/conventions.md` deklariert (§Vergabe). Die Vorlage führt keine Ziffern-Form mehr. Der Fehlalarm —
ein Wort wie `slice-mv` oder `slice-lokal` — ist **in Kauf genommen**; das Regelwerk sagt über ihn nichts, diese
Festlegung nimmt ihn nicht aus. Sein Ausweg ist je Klasse verschieden:
- **ADR und Adaptions-Block:** der Zeilen-Marker aus Festlegung 2.
- **Spec-Straten:** Umformulieren. Das Regelwerk kennt dort keine ausgenommene Sektion (§Prüfung: *„ohne
  ausgenommene Sektion"*). Der Marker `<!-- d-check:status-provenance -->` wirkt mechanisch auch in einer Spec-Zeile
  (`make docs-check` am frisch emittierten Ziel mit einer Spec-Zeile, die `slice-mv` und `welle-cache-warmup`
  nennt → `2 Befund(e)`, mit dem Marker am Zeilenende → `0 Befund(e)`; die Meldung des Gates empfiehlt ihn selbst).
  Dort ist er ein **Umgehen**, das nur der Reviewer fängt: das Regelwerk lässt dem Reviewer die Frage, ob eine
  Markierung *„ehrlich gesetzt"* ist (§Referenz-Richtung (SDP), Abschnitt *Mechanisierbar — über den umgekehrten
  Default*).

**2. Die Matrix.**
(a) Die Regel `{from: spec-straten, to: welle, allow: false}` tritt hinzu — die Matrix-Tabelle verlangt sie in
allen drei Straten-Zeilen.
(b) Die Regeln `{from: adaptionsblock, to: slice, allow: false}` und `{from: adaptionsblock, to: welle,
allow: false}` treten als **Erweiterung ohne Deckung im Text des Regelwerks** hinzu; die Matrix-Tabelle führt den
Adaptions-Block nicht, und das Regelwerk lässt ihn das Herkunfts-Anker-Muster tragen
(`grundlagen-traceability.md` §Herkunfts-Anker: *„Der Adaptions-Block trägt das Muster bereits über sein Feld
Begründung."*).
**Was 2(b) trägt, ist eine Analogie und sonst nichts.** Der Adaptions-Block ist wie eine ADR ein Norm-Artefakt
([`AGENTS.md`](../../../AGENTS.md) §3.8: *„beide sind normativ wie eine ADR, nur ohne deren Immutabilität"* — die Aussage steht im Briefing dieses
Repos, nicht im Regelwerk). Für die ADR-Zeile ordnet die Matrix Slice als Kontext, der nur zeigt, *„wo
verifiziert/entstanden, nie warum entschieden"*, und Welle mit ❌; dahinter stehen zwei der tragenden Regeln
(`grundlagen-referenz-richtung.md` §Referenz-Richtung (SDP), *„Tragende Regeln"*): *„Alles Richtung Slice oder zwischen
Slices ist Planungskontext, keine Spezifikation"* und *„Welle und Roadmap stehen außerhalb der normativen Klammer"*.
Eine Planungs-Kennung in einem Eintrag des Adaptions-Blocks ist dieselbe Kante, aus einem Norm-Artefakt hinaus in die
Planung; die Regeln halten die zwei Norm-Artefakte gleich. Die Ausnahme läuft über denselben Zeilen-Marker wie bei
`adr → slice/welle`; der Marker ist die Zeilen-Markierung des Werkzeugs für das, was das Regelwerk für die ADR-Zeile
verlangt: *„Der Autor markiert den zulässigen Zeiger in seiner Zeile"* (§Referenz-Richtung (SDP), *Mechanisierbar —
über den umgekehrten Default*; den Marker-Namen führt die Vorlage `.d-check.yml` der Baseline, nicht der Text des
Regelwerks: `grep -rl 'status-provenance' .harness/baseline/v6.9.0/regelwerk | wc -l` → **0**,
`grep -rl 'status-provenance' .harness/baseline/v6.9.0/templates | wc -l` → **1**). Für Ausnahmen gilt dort: *„die
Ausnahme wird am Ort deklariert"*.
**Was 2(b) nicht trägt, ist ein Wächter gegen tote Adressen.** Ein Slice- oder Welle-Name wandert beim Umzug nicht
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer übernimmt: *„Die Kennung bleibt Adresse —
einen Hop länger"*), und ein Pfad in einem Eintrag des Blocks lässt sich nachziehen
(`grundlagen-traceability.md` §Herkunfts-Anker, Ruheort-Regel, Gegenrichtung für den Adaptions-Eintrag:
*„Der `git mv` zieht die Pfad-Berichtigung nach sich, als eigener Commit nach dem Umzug. Der Wächter ist die
Existenzprüfung des Links."*). Die Regeln fangen den Namen, nicht das Rotten.
**Die Kosten stehen hier:** Jede Zeile mit `seit slice-<Kennung>` ist mit den zwei Regeln rot, bis sie den Marker
trägt — obwohl das Regelwerk dem Block dieses Muster zuschreibt. Ein frisch emittiertes Ziel trägt keine solche Zeile
(Kommando im Kontext); die Kosten fallen an, sobald ein Adopter dem Regelwerk folgt. Der Kommentar der Vorlage nennt
die Regeln als Erweiterung und sagt, warum und was sie kosten.
(c) **Bedingung, nicht Vorbehalt:** (b) geht erst in die Vorlage, wenn der grüne Start hält — am frisch
emittierten Ziel sind die Fundstellen im emittierten Adaptions-Block markiert oder umformuliert (die
Platzhalter-Zeilen der Vorlage über eine Neutralisierung nach dem Vorbild der bestehenden, den Satz des Emitters
im eigenen Text), und der Marker wirkt nachweislich mit dem Adaptions-Block als **Quell**klasse. Gelingt das
nicht mit dieser Menge an Eingriffen, bleiben die zwei Regeln aus; Festlegung 1 und 2(a) gelten unabhängig
davon, und der Grund steht dann im Kommentar der Vorlage.

**3. Klassen und Muster der Kennungs-Formen.** Das `ids`-Muster für ADR wird segment-tolerant
(`ADR-([A-Z]+-)?\d{4}`), die Klasse `adr` nimmt neben `[0-9]*.md` die Dateien mit Bereichs-Präfix auf
(`[A-Z]*-[0-9]*.md`; `README.md` bleibt draußen). Das Vertrags-Präfix und die Carveout-Kennung bleiben
Adopter-Setzung: die auskommentierten Vorschläge nennen die Formen des Regelwerks
(`<PREFIX>(-[A-Z]+){1,2}-\d{2,3}`, `CO-([A-Z]+-)?\d{3}`), das Werkzeug kennt das Präfix im frischen Ziel nicht.

**4. Die Commit-Menge bleibt in der Zeile `patterns=` und nimmt die Formen des Regelwerks auf.** Eine Quelle,
nicht gelesen aus der Doku-Gate-Konfiguration: die Prüfung läuft im Commit-Pfad mit bash und coreutils
([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)), und ein zweiter Parser mit
anderem Regex-Dialekt wäre eine zweite Fassung. Die Menge sind **sechs** POSIX-ERE-Muster in einer Gruppe; eine
Message trägt eine Kennung, wenn eines in einer Nicht-Kommentarzeile trifft:

```text
ADR-[A-Z-]*[0-9]{4}                 ADR-<NNNN>, mit und ohne Bereichssegment
CO-[A-Z-]*[0-9]{3}                  CO-<NNN>, mit und ohne Bereichssegment
MR-[0-9]{3}                         MR-<NNN>
[A-Z]{2,}-[A-Z-]*[A-Z]-[0-9]{2,3}   Vertrags-Kennung mit freiem Präfix und einem bis mehreren Segmenten
slice-[a-z0-9]                      Slice, Name oder Nummer
welle-[a-z0-9]                      Welle, Name oder Nummer
```

Die Muster für ADR und Vertrag folgen §ID-Schema und §Vergabe. `MR-`, `CO-`, `slice-` und `welle-` sind die
**Setzung dieses Werkzeugs**, nicht eine Ableitung aus dem Traceability-Constraint, der unter anderem Requirement-ID
und ADR-ID nennt. `MR-` und `slice-` stehen schon heute in der Menge; `CO-<NNN>`, `slice-<Kennung>` und `MR-<NNN>`
stehen in der ID-Liste der Vorlage `conventions.template.md` (Eintrag der Adoptions-Erklärung, Feld Adaption). `welle-` steht dort **nicht**
als Kennung dieser Liste, sondern nur als Dateifamilie in der Klammer zum Bereichssegment; es stützt sich auf die
Matrix-Spalte Welle (Festlegung 1) und den Namensraum aus §Vergabe (*„Welle- und Slice-Kennungen sind Namen, nicht
Nummern"*).
`SPEC-`, `ARC-`, `BEO-` und `RC-` führen kein eigenes Muster (*„Die Klammer trägt die Anforderungs-ID, nicht jede
Kennung"*, `grundlagen-source-precedence.md` §ID-Schema als Klammer). Ihre **flachen** Formen — die einzigen, die das
Regelwerk für sie führt (`SPEC-<NNN>`, `ARC-<NNN>` in §ID-Schema; `BEO-<NNN>`, `RC-<NNN>` in `conventions.template.md`,
dort mit der Aussage, `SPEC-*`/`ARC-*` zählten *„fortlaufend je Datei"* ohne Bereichssegment) — lehnt die Menge ab.
Eine Form mit Segment (`SPEC-FA-042`) führt das Regelwerk für sie nicht; sie ist von einer Vertrags-Kennung mit Segment
nicht zu unterscheiden, und ein Ausschluss wäre ein Lookahead, den weder POSIX-ERE noch der Dialekt des
`commits`-Moduls kennt: Die Menge nimmt sie an, und die Grenze sagt es. Ebenso trägt kein Muster eine Wortgrenze rechts
vom Zahlenteil. Sie ließe sich ohne Lookahead als optionaler Rest bis Zeilenende ausdrücken
(`ADR-[0-9]{4}([^0-9].*)?$`; gemessen mit `[[ =~ ]]`: nimmt `ADR-0004`, `ADR-0004: x` und `ADR-0004,x` an, lehnt
`ADR-00041` ab), und die Kopplung an `commits.id-patterns` verträgt diese Form: `hook_patterns` in
`test/commit-msg-hook.bats` trennt die Menge an jedem `|`, und die Gruppe enthält keines; ein `|` **in** einer Gruppe
(`([^0-9]|$)`) bräche die Kopplung. Die Menge führt sie trotzdem nicht: Trügen die vier Zahlen-Muster (ADR, CO, MR,
Vertrag) den Rest `([^0-9].*)?$`, lehnte sie von den neun Fehl-Akzeptanzen unten drei ab (`CO-1234`, `HSM-FA-1234`,
`EN-ISO-9001`, gemessen mit `[[ =~ ]]` über die so verlängerte Gruppe) und ließe sechs stehen, deren Zahlenteil dort
endet, wo er soll und die aus anderem Grund falsch sind (`SPEC-FA-042`, `BEO-ALL-001`, `RC-AB-12`, `AES-CB-128`,
`slice-mv`, `anti-slice-mv`). Der Gewinn ist klein gegen vier Muster mit Zeilenende-Anker und Rest; die Fehl-Akzeptanz
steht in der Grenze.

**Diese Liste ist die Wahrheit, die Prosa folgt ihr.** Gemessen mit `[[ =~ ]]` in bash über die Gruppe der sechs
Muster:

```sh
P='(ADR-[A-Z-]*[0-9]{4}|CO-[A-Z-]*[0-9]{3}|MR-[0-9]{3}|[A-Z]{2,}-[A-Z-]*[A-Z]-[0-9]{2,3}|slice-[a-z0-9]|welle-[a-z0-9])'
for s in <Zeichenfolge>...; do [[ "$s" =~ $P ]] && echo "angenommen $s" || echo "abgelehnt $s"; done
```

Sie **nimmt an:** `ADR-0004`, `ADR-IDX-0004`, `CO-AUTH-002`, `HSM-FA-03`, `HSM-FA-IDX-003`, `HSM-LESE-004`,
`LH-FA-BUILD-008`, `slice-42`, `slice-mv-verweise`, `welle-cache-warmup`. Sie **lehnt ab:** eine Message ohne Kennung,
`ADR-4`, `SHA-256`, `UTF-8`, die flachen Struktur-Formen `SPEC-042`, `ARC-042`, `RC-042` und `BEO-042`, den Platzhalter
`slice-<Kennung>` und eine Kennung nur in einer Kommentarzeile. Sie **nimmt an, obwohl keine Kennung gemeint ist**
(Fehl-Akzeptanz, gemessen, in der Grenze): `SPEC-FA-042`, `BEO-ALL-001`, `RC-AB-12`, `AES-CB-128`, `EN-ISO-9001`,
`CO-1234`, `HSM-FA-1234`, `slice-mv`, `anti-slice-mv`. Geprüft bleibt die **Anwesenheit**, nicht die Wahrheit. Ein Ziel
mit einer Klasse außerhalb der Menge setzt `HOOKS_DIR` auf sein eigenes Hook-Verzeichnis (Route der mitgelieferten
Prüfung, unverändert).

**Die Dogfood-Fassung zieht mit, samt dem `commits:`-Block der eigenen `.d-check.yml`** — die Kopplung fordert
Mengen-Gleichheit aller drei Fassungen (emittierte Prüfung, Dogfood-Prüfung, `commits.id-patterns` im `\d`-Dialekt).
Das ist eine **Senkung der Strenge** im Sinn von [`AGENTS.md`](../../../AGENTS.md) §3.5 — die Menge nimmt mehr
Formen an —, und diese Entscheidung ist ihr ADR: die zusätzlich angenommenen Formen sind die Kennungen, die
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
diesem Repo vorschreibt. Die Kopplungs-Tests bleiben Mengen-Gleichheit; sie werden auf die neue Menge geschnitten.

**5. Reichweite.** Neue Ziele bekommen Konfiguration und Prüfung; bestehende Ziele bekommen die **Prüfung** beim
nächsten Lauf und die Konfiguration **nicht**. Mit der Prüfung nimmt ein bestehendes Ziel mehr Formen an als
bisher; kein Wächter meldet es. Der Nachzug der Konfiguration ist Handarbeit des Adopters nach der Positions-Liste im
Herkunfts-Kommentar der Vorlage; ein Hinweis bei jedem Lauf wäre Rauschen, weil eine Adopter-Datei per Definition
abweicht (§Konsequenzen). **Die Liste nennt eine Vorbedingung für 2(b):** die `harness/conventions.md` eines
bestehenden Ziels ist skip-if-present, die Fundstellen der Vorlage und der Werkzeug-Satz stehen dort ohne Marker; wer
die zwei Regeln nachzieht, markiert diese Zeilen oder lässt die zwei Regeln weg — sonst ist sein Gate rot.
`harness/migration.md` ist nicht der Träger: es führt den Baseline-Sprung dieses Repos und nennt kein Zielrepo
(`grep -ci 'zielrepo' harness/migration.md` → **0**).
**Die eigene `.d-check.yml` dieses Repos zieht zur Hälfte mit:** der `commits:`-Block ja (Festlegung 4, wegen der
Kopplung); Klassen, Token und Regeln der Matrix und das `ids`-Muster **nicht** — die Klassen `welle`/`adaptionsblock`
und ein Token auf `slice` wären gegen das Lastenheft (10 Zeilen, Vertrags-Änderung nach dem Change-Request-Verfahren)
und gegen einen eingefrorenen Bestand (113 Zeilen) zu halten, ein eigener Vorgang mit eigener Entscheidung. Die
Vorlage ist damit **strenger als das eigene Repo, und das ist deklariert**: sie gilt für ein Ziel, das ohne Bestand
beginnt.

**6. Die Beleg-Pflicht der Lieferung.** Nach
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel):
(i) die Zell-für-Zell-Messung der emittierten Konfiguration gegen beide Regelwerk-Dateien, als **erster**
Liefer-Punkt — sie deckt alle 22 ❌-Zellen und nennt je Zelle ihre Regel oder ihre Lücke; (ii) der grüne Start der
emittierten Vorlage am frischen Ziel, sprach-agnostisch und je unterstützter Sprache; (iii) je Regel und je Muster
ein Gegenbeispiel, das im Ziel rot wird, **mit gelesener Meldung** (die Regel benannt, nicht irgendeine); (iv) je Zahn
der Commit-Prüfung ein Fall, der die Menge bindet — eine Mutation, die sie schwächt, färbt ihn rot. Eine
`full-smoke`-Stufe trägt ihre Kopfzeile, sonst fällt sie aus `make e2e-abdeckung`.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun | kein Vertrag gegenüber Zielrepos ändert sich | ein benannter Slice wird von Matrix und Commit-Prüfung nicht gesehen; die Vorlage widerspricht dem Regelwerk-Text (§Vergabe, Gate-Text) |
| B — Ziffern- **und** Namens-Muster nebeneinander (`slice-(\d{3}\|[a-z][a-z0-9-]*)`) | die Nummern-Form ist ausdrücklich benannt | dieselbe Menge wie das Präfix, komplizierter, und beim ersten Slug mit Ziffer am Anfang falsch |
| **C — Präfix (gewählt)** | Wortlaut des Gate-Satzes; deckt beide Formen; ein Muster | Fehlalarm bei Wörtern wie `slice-mv`; in den Spec-Straten ist der Marker ein Umgehen, das nur der Reviewer fängt |
| D — Adaptions-Block-Regeln ohne Marker | härteste Form | rot bei jedem Herkunfts-Anker, den das Regelwerk dem Block zuschreibt |
| E — Adaptions-Block-Regeln gar nicht | kein Eingriff in den emittierten Block; keine Neutralisierung, kein Nachzug-Rot; die Vorlage bleibt beim Regelwerk | der Block trägt, wie eine ADR, Planungs-Kennungen im Norm-Text; die Lücke bleibt |
| **F — mit Marker, unter der Bedingung 2(c) (gewählt)** | dieselbe Ausnahme-Form wie bei der ADR; hält die zwei Norm-Artefakte gleich (Analogie, kein Wächter gegen tote Adressen) | Erweiterung ohne Deckung im Text; der Marker je Herkunfts-Anker-Zeile; Eingriff in den emittierten Text; der Marker ist nicht Ziel-spezifisch |
| G — Commit-Menge aus `.d-check.yml` lesen | eine Deklaration für beide | zweiter Parser, anderer Regex-Dialekt, die Prüfung liest heute bewusst keine Doku-Gate-Konfiguration |
| H — Commit-Menge in einer Adopter-Datei | pro Ziel anpassbar | neue Artefaktklasse; die Route `HOOKS_DIR` deckt den Fall bereits |
| I — das Werkzeug-Wort `slice-mv` aus der Menge ausnehmen | ein Betreff, der nur das Werkzeug nennt, zählt nicht als Kennung | ERE und der `\d`-Dialekt des `commits`-Moduls kennen keinen Ausschluss: die Menge wäre eine verschachtelte Zeichen-Alternative statt eines Präfixes, die drei Fassungen gingen auseinander oder die Kopplung fiele; **gemessen trennt es einen Betreff von 3366** (Kommando in der Grenze) |
| J — beim Accept [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) markieren oder einen Adaptions-Eintrag schreiben, der seine Grenze zur emittierten Ebene ablöst | der Adaptions-Block trüge den Zustand der Entscheidung | die Marke nach [`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger) zeigt auf einen Eintrag, nicht auf eine ADR; ein Eintrag müsste eine Aussage ablösen, die nicht fällt (Folgepflicht 2) — Marke und Eintrag ohne Gegenstand, dazu ein weiterer Norm-Commit |

## Konsequenzen

- Positiv: die emittierte Ebene sagt dasselbe wie der adoptierte Regelwerk-Text; ein benannter Slice und eine
  Kennung mit Bereichssegment werden gefangen und nicht mehr abgewiesen; ein Ziel, das seine Kennungs-Form
  deklariert, bekommt eine Vorlage, die sie trägt. Ein Werkzeug-Commit, dessen Betreff den bewegten Slice nennt, trägt
  mit der Menge eine Kennung; die Zeile in `harness/README.md` §Traceability, die solche Commits als am Träger
  brechend beschreibt, gilt danach für sie nicht mehr.
- Negativ: der Fehlalarm des Präfixes (`slice-mv`) trifft Ziele; in den Spec-Straten hilft nur Umformulieren, und der
  Marker dort ist ein Umgehen. Die Commit-Menge nimmt eine Message an, die nur ein Werkzeug-Wort trägt. Ein
  bestehendes Ziel bekommt die Konfiguration nicht von selbst — es trägt die Differenz, bis der Adopter sie nachzieht,
  und es bekommt die weitere Akzeptanz der Prüfung; kein Wächter meldet beides. Die Regeln aus 2(b) kosten dem
  Adopter, der dem Regelwerk folgt, einen Marker je Herkunfts-Anker-Zeile.
- Folgepflicht 1 — **Liefer-Gegenstand:** die Konfigurations-Vorlage (Festlegungen 1, 2(a), 3), die Commit-Prüfung
  samt Dogfood-Fassung, `commits:`-Block und den Kopplungs-Tests (Festlegung 4) und die Erweiterung 2(b) mit
  Neutralisierung (hängt an den Token aus Festlegung 1). **Zur Commit-Prüfung gehört, was an ihrem heutigen Wortlaut
  hängt:** die Klassen-Liste im Kopfkommentar der Prüfung, die Beschreibung der Menge im Sensor-Text von
  `make commit-msg-check`, die Zeile zu Werkzeug-Commits in `harness/README.md` §Traceability und die Mutations-Fälle,
  deren Anker oder Erwartung am Wortlaut der `patterns=`-Zeile oder an der Klassen-Liste im Kopf der Prüfung hängen.
  Die Kandidaten liefert `grep -l 'commit-msg-traceability' test/mutations/*.sh` als Obermenge: sie nennt jeden Fall,
  der die Prüfung berührt, auch einen, dessen Anker von der Zeile unabhängig ist (ein `sed`, das `^patterns=.*$`
  ersetzt); welche am Wortlaut hängen, liest der Nachzug am Anker und an der Erwartung des Falls. Ein Fall, dessen
  Anker die neue Zeile nicht mehr trifft, bindet nichts, bis er nachgezogen ist
  ([`MR-071`](../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand));
  die Fälle werden über ihre Eigenschaft gefunden, nicht über eine Nummer. Die Baseline verlangt höchstens drei
  Liefer-Punkte je Slice; der Schnitt gehört dem Planner. Er gleicht dabei ab, was ein offener Vorgang zur Kennung in
  Werkzeug-Messages schon führt.
- Folgepflicht 2 — **der Adaptions-Block bleibt beim Accept unberührt.** Der Accept-Commit fasst Status, ADR-Index und
  die Geschichte-Zeile dieser Datei an, sonst nichts; [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) bekommt keine Kopf-Marke, und kein neuer Eintrag löst
  ihn ab. Der Grund liegt in den Regeln der Einträge selbst: Die Marke ist der Zustandsträger einer **abgelösten
  Aussage** und fällig, wenn ein späterer **Eintrag** eine Aussage namentlich ablöst
  ([`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 4); ihr Ziel ist die Anker-Adresse dieses Eintrags (Setzung 1); und die Instrumente Marke und Aufhebung
  nehmen `docs/plan/adr/` aus ihrem Geltungsbereich aus
  ([`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger),
  [`MR-020`](../../../harness/conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf),
  [`MR-046`](../../../harness/conventions.md#mr-046--die-verzeichnis-position-ist-binär-und-trägt-die-kopf-marke-nicht)).
  **Keine Aussage von [`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer) fällt:** sein Ausschluss der emittierten Ebene und sein Satz, was ein Zielrepo an
  Kennungs-Form bekomme, entscheide *„der Slice, der die Tool-Ebene entscheidet"*, sagen, dass der Eintrag diese Ebene
  nicht bindet und ein anderer Vorgang sie entscheidet; dieser Vorgang ist diese Entscheidung. Dasselbe sagt
  [`MR-059`](../../../harness/conventions.md#mr-059--jede-kennungs-erkennung-trägt-die-zugelassenen-formen-die-fundliste-steht-im-vorgang)
  Setzung 4. Die Grenze, die den Vertrag gegenüber Zielrepos nennt, ist bereits abgelöst. **Akzeptiertes Negativ:**
  der Eintrag nennt den Slice als entscheidenden Vorgang, die Entscheidung liegt hier und der Slice liefert sie — eine
  Wortlaut-Differenz, keine fallende Aussage; ein Leser des Eintrags wird durch sie zu keiner falschen Handlung geführt,
  weil die ADR im Index steht, und eine Marke, die keine Aussage überholt, bezeichnete einen Zustand, den es nicht gibt.
  Ändert eine spätere Entscheidung eine Aussage des Eintrags, gilt der Weg der Einträge
  ([`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
  Setzung 3), nicht diese Folgepflicht.

### Grenze

- **Der Marker ist nicht Ziel-spezifisch.** Die Matrix-Tabelle setzt ADR → Welle ❌ **ohne** Ausnahme; der Marker
  nimmt eine Zeile für Slice und Welle zugleich aus. Die Vorlage sagt es dort, wo sie den Marker nennt; ein
  Ziel-spezifischer Marker liegt beim Werkzeug d-check, nicht hier.
- **Der Marker in einem Spec-Stratum ist ein Umgehen** (Festlegung 1). Ihn fängt nur der Reviewer; die Vorlage kann
  ihn dort nicht ausschließen.
- **Nicht jede ❌-Zelle der Matrix hat eine Regel.** Von 22 Zellen decken drei die Rangfolge innerhalb der Straten
  (nicht Gegenstand), neun die Spalten ADR, Slice und Welle der drei Straten-Zeilen, eine ADR → Welle mit Marker. Sechs
  — Spec-Stratum → Carveout und → Roadmap — fängt nur `aussen`, und das nur als **Link**; eine blanke `CO-`-Kennung
  fängt niemand. Drei haben keine Regel: ADR → Carveout, ADR → Roadmap, Slice → Roadmap (`aussen` hat nur die Spec-Straten
  als Quelle, und die ADR-Zeile darf legitim in Code und `harness/` linken). Der Gate-Text des Regelwerks nennt nur
  `ADR-` und `slice-`; das ist hier nicht enger, und nicht weiter.
- **Die Commit-Prüfung prüft die Anwesenheit eines Kennungs-Musters, nicht die Wahrheit und nicht die Klasse.**
  Muster 4 nimmt jede Zeichenfolge der Form `<GROSSBUCHSTABEN>-<Segmente>-<zwei bis drei Ziffern>` an: eine
  Vertrags-Kennung mit Segment, aber ebenso `SPEC-FA-042` und `BEO-ALL-001` (Formen, die das Regelwerk für Struktur-IDs
  nicht führt) und Fremd-Bezeichnungen wie `AES-CB-128` und `EN-ISO-9001`. Kein Muster trägt eine Wortgrenze: der
  Zahlenteil endet nirgends (`CO-1234`, `HSM-FA-1234` treffen über die ersten Ziffern), und `slice-`/`welle-` treffen
  jedes Wort dieser Form, auch ohne Wortgrenze davor (`anti-slice-mv`).
- **Ein Betreff `slice-mv: …` passiert die Prüfung über das Präfix allein**, auch wenn hinter dem Doppelpunkt kein
  Slice-Name steht: die Menge unterscheidet das Werkzeug-Wort nicht vom Namen. Das ist keine Ausnahme-Zeile — die Form,
  die [ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4 als Senkung benennt (*„eine
  Zeile, die `slice-mv:`-Messages von der Prüfung nimmt, wäre eine Senkung der Durchsetzung"*) —, sie hat aber für
  diese Klasse dieselbe Wirkung: die Prüfung hält für `slice-mv:`-Betreffe keine Kennungs-Zusage; dass ein
  Werkzeug-Commit eine Kennung trägt, hängt für sie am Kandidaten aus ADR-0053 Festlegung 4, nicht an der Prüfung. **Diese
  Entscheidung ist die Senkung im Sinn von [`AGENTS.md`](../../../AGENTS.md) §3.5**, benannt statt umgangen; der
  Bestand ist Kontext, keine Aufhebung. Gemessen (Betreffzeilen, eine Obergrenze der Ablehnungen: die Prüfung liest
  auch den Rumpf): `git log --format=%s | grep -c '^slice-mv:'` → **608**; davon ohne Kennung nach der
  bisherigen Menge `git log --format=%s | grep '^slice-mv:' | grep -vcE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'` →
  **190**; davon nennen `git log --format=%s | grep '^slice-mv:' | grep -vE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+' | sed 's/^slice-mv://' | grep -cE 'slice-[a-z0-9]|welle-[a-z0-9]'` → **189** hinter dem
  Präfix den bewegten Slice; einer nennt keinen und gilt allein über das Wort. Wie viele Betreffzeilen erst das Wort
  `slice-mv` annimmt, zeigt der Unterschied zweier Läufe über alle Betreffzeilen ohne Merge/Revert, die die bisherige
  Menge ablehnt: mit dem Wort angenommen
  `git log --format=%s | grep -vE '^(Merge|Revert) ' | grep -vE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+' | grep -cE 'slice-[a-z0-9]|welle-[a-z0-9]'`
  → **476**; ohne das Wort (dasselbe mit `sed -E 's/(^|[^A-Za-z0-9-])slice-mv([^A-Za-z0-9-]|$)/\1\2/g'` vor dem
  letzten `grep`) → **475**; Nenner `git log --format=%s | grep -vcE '^(Merge|Revert) '` → **3366**. Die Ausnahme
  trennte **eine** Betreffzeile von 3366; das ist der Grund gegen Alternative I.
- **Die eigene Konfiguration bleibt hinter der Vorlage zurück**, und die Spec-Straten dieses Repos nehmen §7
  Historie aus, wo die Vorlage keine Sektion ausnimmt (Regelwerk: *„ohne ausgenommene Sektion"*). Beide
  Unterschiede sind benannt, nicht entschieden.
- **Nicht Gegenstand:** Umbenennung von Bestand; Werkzeug-Nachzüge, die eine Kennung nur in Ziffernform kennen —
  gemessen: `grep -n 'kennungRE = ' internal/archive/stub.go` nennt eine Titel-Kennung nur mit Ziffern hinter dem
  Präfix, und `git grep -lE 'slice-(\[0-9\]|\\d)' -- harness/tools internal cmd Makefile d-check.mk ':!internal/emit'`
  nennt heute nur die Prüfung selbst, die Festlegung 4 ändert; die Aktivierung des `ids`-Musters für das
  Vertrags-Präfix; die Regelwerk-Vorlage selbst (Kurs).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test über die eingebettete Vorlage | die Positionen der Festlegungen 1 bis 3 stehen in der Vorlage, die Ziffern-Form nicht | `make test` |
| bats über die emittierte Prüfung | die Annahme-/Ablehnungs-Liste aus Festlegung 4; die drei Fassungen (emittiert, Dogfood, `commits`-Block) bleiben mengengleich | `make test` |
| End-to-End im frischen Ziel | grüner Start; je Regel ein rotes Gegenbeispiel mit gelesener Meldung; die Prüfung an einem Commit | `make full-smoke` |
| Mutations-Fall je Zahn | Präfix, Regel `spec-straten → welle`, Marker-Ausnahme, je ein Muster der Commit-Menge; dazu die nachgezogenen Fälle auf der Prüfung (Folgepflicht 1) | `make mutate` (kein Gate) |

Vorbilder für die Anlage der Mutations-Fälle sind die, die die emittierte Matrix bereits angreifen
(`grep -l 'internal/emit/templates/d-check.yml' test/mutations/*.sh | wc -l` → **11**); `failure_form()` in
`harness/tools/mutate.sh` kennt für sie die Stufen `test`, `test-go`, `test-bats` und `full-smoke`. Je Fall ist die
Schwächung zu benennen, unter der das Gegenbeispiel grün würde (Präfix wieder in Ziffern-Form; Regel gestrichen; Marker
ohne Wirkung als Quellklasse; ein Muster der Menge ohne die Namens-Alternative).

Ein Wächter für die Konfigurations-Drift bestehender Ziele existiert nicht; benannt, nicht geschlossen.

## Re-Evaluierungs-Trigger

1. Ein künftiger Regelwerk-Stand führt den Adaptions-Block als Klasse der Matrix oder nimmt die Namens-Form
   zurück: dann entfällt die Erweiterung aus Festlegung 2(b) bzw. die Voreinstellung aus Festlegung 1, per
   Folge-ADR mit `Supersedes`.
2. Der Marker wirkt nicht mit dem Adaptions-Block als Quellklasse, der grüne Start braucht mehr Eingriffe
   als die in 2(c) genannten, oder ein Ziel meldet den Marker je Herkunfts-Anker-Zeile als Reibung: 2(b) fällt, die
   übrigen Festlegungen bleiben.
3. d-check führt einen Ziel-spezifischen Marker: die Grenze zu ADR → Welle schließt sich.
4. Ein Ziel meldet einen Fehlalarm, den weder Umformulieren noch Marker löst: die Frage, ob das Präfix ein
   engeres Muster braucht, wird neu gestellt.
5. Ein Ziel meldet einen Werkzeug-Commit, der nur durch das Werkzeug-Wort angenommen wurde: Alternative I wird neu
   gestellt.

**Acceptance-Trigger.** Diese Entscheidung steht auf `Proposed`. Sie wird `Accepted`, **wenn eine Reviewer-Runde über
die dann geltende Fassung sie gegen [ADR-0007](0007-bootstrap-phasen.md) (Festlegung 3),
[ADR-0053](0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md),
[ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md) (Festlegung 1) und
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel)
auf Konsistenz geprüft hat und ihr Report ohne blockierenden Befund an der Substanz der sechs Festlegungen in
`docs/reviews/` liegt.** Ein blockierender Befund an der Darstellung (Adressform, Zahl ohne Kommando) wird behoben und
hindert die Annahme nicht. Der Beleg ist eine Runde der prüfenden Rolle; die Nachmessung durch den Kontext, der einen
Befund aufgelöst hat, ist keine
([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2); die Accept-Zeile der
§Geschichte nennt ihn als **Kennung**, nicht als Pfad-Link (ebenda, Festlegung 1). **Die Annahme selbst ist die
Entscheidung des Auftraggebers.**

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-24 | Proposed | Architect-Lauf zum Auftrag des Auftraggebers, die emittierte Konfiguration dem Regelwerk `v6.9.0` anzugleichen |
| 2026-09-24 | **Accepted** | Beleg nach [ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 ist die Reviewer-Runde `2026-09-24-adr-0065-emittierte-kennungs-form-runde-3` — sie meldet annahmefähig, kein HIGH und kein MEDIUM, der MEDIUM der Runde 2 (Folgepflicht 2) behoben; die Annahme selbst hat der Auftraggeber am 2026-09-24 erteilt. Der Accept-Commit fasst nach Folgepflicht 2 den Adaptions-Block nicht an. **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4:** Korrekturen entstehen als Folge-ADR mit `Supersedes ADR-0065`. |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0065` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
