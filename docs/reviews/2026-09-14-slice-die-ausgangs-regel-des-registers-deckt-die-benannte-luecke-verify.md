# Verifikation `slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke` — die zwei Liefer-Punkte tragen, ein Zahlensatz des Plans nicht

**Rolle:** Verifier · **Datum:** 2026-09-14 · **Geprüfte Commits:** `7a2690a8` (ADR-0049 + Index +
Register-Regel) · `2d7ebb8e` (Slice-Plan auf seine Messungen gezogen) · `fae11c44`
(Konsistenzrunde) · `d16b2875` (Befunde eingearbeitet, `Accepted` vollzogen) · `e763ed11`
(`Verantwortlich:`-Satz auf seine Quelle gezogen) ·
**Plan:** `slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke` (Kennung, kein
Lifecycle-Pfad — §3.11) · **Review:** `2026-09-14-adr-0049-konsistenzrunde` (0 HIGH · 2 MEDIUM ·
4 LOW · 2 INFO) · **Prüfgegenstand:** §2 Definition of Done des Slice und die Quellen, auf die sie
sich beruft ([`ADR-0040`](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md),
[ADR-0034](../plan/adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md),
`grundlagen-traceability.md` §Herkunfts-Anker) — **nicht** Plan/ADR-Konsistenz, das ist
Reviewer-Sache (Modul 8).

**Kontext:** frisch — diese Sitzung hat an keinem der fünf Commits, an
[`ADR-0049`](../plan/adr/0049-ausgang-traegt-die-benannte-luecke.md), an
[`observations/README.md`](../plan/planning/observations/README.md) und am Slice-Plan **nichts
geschrieben**. Kein Self-Review.

**Zitier-Form** *(wie im Review-Report zu diesem Gegenstand)*: **Kennung, nicht Adresse** für alles,
was der Prozess bewegt — der Slice als `slice-<Kennung>`, der Review-Report als
`2026-09-14-adr-0049-konsistenzrunde`, eine Baseline-Stelle als Tag + Pfad in Inline-Code.
Ortsfeste Ziele (ADRs, das Register-`README.md`, `AGENTS.md`) bleiben als Link.

---

## 1. Ist der Sensor gelaufen?

`make gates` **selbst gefahren** (`AGENTS.md` §3.9: über `make`, nicht über den Host), zweimal:
einmal über den Stand **ohne** diesen Bericht, einmal danach als der aufgezeichnete Nachweis über
den Stand **mit** ihm. Erster Lauf:

```sh
make gates        # EXIT 0
# baseline-verify: v6.8.0 OK — 54 Dateien (Integritaet + Vollstaendigkeit, netzlos)
# d-check: 1362 Datei(en) geprueft, 0 Befund(e)
# comment-claims: 58 Datei(en) geprueft, 0 Befund(e)
# golangci-lint: 0 issues. · bats 1..280 ohne `not ok` · acht Go-Pakete `ok`
# span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert
```

**Die Dateizahl ist hier absichtlich nicht die tragende Zeile.** Dieser Bericht liegt selbst im
Prüfbereich des Doku-Gates und bewegt die Zahl, die er nennen würde — dieselbe Klasse, die
[`MR-058`](../../harness/conventions.md#mr-058--eine-messung-die-ihr-eigener-vorgang-bewegt-wird-nach-dem-vorgang-genommen)
für eine Messung benennt, die ihr eigener Vorgang verschiebt. Tragend ist `0 Befund(e)`, und das
steht im aufgezeichneten Nachlauf ebenso (`git status --porcelain` vor dem Commit: nur dieser
Bericht).

Der Review-Report nennt für seinen Stand `1362`/`0` — beide Läufe stimmen darin überein.

## 2. Deckt der Sensor die Zusage?

### Liefer-Punkt (1) „Die Entscheidung steht und ist `Accepted`" — **erfüllt**

**Der Status steht:**

```sh
sed -n '3p' docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md     # **Status:** Accepted
grep -n '0049' docs/plan/adr/README.md | grep -o '| Accepted |'          # | Accepted |
```

Die Index-Zeile ist nachgezogen (derivativ, `ADR-0024`) — der Diff `d16b2875` zeigt `Proposed` →
`Accepted` als einzige Änderung an ihr.

**Der Beleg des Triggers ist an beiden Orten genannt** (`ADR-0040` Festlegung 1), als **Kennung**:

| Ort | Fundstelle | Wortlaut (Auszug) |
|---|---|---|
| §Geschichte, Zeile `Accepted` | `0049-…:343` | *„Beleg ist die Runde `2026-09-14-adr-0049-konsistenzrunde` in `docs/reviews/`"* |
| §Der Acceptance-Trigger | `0049-…:331` | *„**Eingelöst ist er durch die Runde `2026-09-14-adr-0049-konsistenzrunde`** (in `docs/reviews/`)"* |

`docs/reviews/` ist ein **Verzeichnis** und damit ortsfest — als Pfad zulässig (§3.11); die Runde
selbst steht als Kennung im Code-Span. Kein Markdown-Link auf einen Report:

```sh
grep -n 'reviews/' docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md
# 326, 331, 343 — drei Fundstellen, alle Inline-Code; `](` vor keiner
```

**Der Beleg ist real und trägt keinen blockierenden Befund.** Der Report
`2026-09-14-adr-0049-konsistenzrunde` liegt in `docs/reviews/`, seine Summary-Zeile lautet
`HIGH 0 · MEDIUM 2 · LOW 4 · INFO 2` und sein Verdikt beginnt *„Kein HIGH — der Beleg trägt"*. Die
drei Aussagen der ADR dazu sind **alle nachgemessen**:

```sh
grep -n '\*\*HIGH\*\*' .harness/skills/reviewer.md
# 39:**HIGH** (blockiert Merge) — eines der folgenden:
git log --oneline --all | grep -i 'NICHT BLOCKIEREND' | wc -l            # 7 (die Praxis des Repos)
```

Also: **HIGH = blockierend** ist die Kategorie des Reviewer-Skills, die Praxis des Repos hält es
ebenso — die Auslegung der ADR steht nicht auf einer Vermutung. Die Reihenfolge stimmt ebenfalls:
die Runde (`fae11c44`) liegt **vor** dem Umschlag (`d16b2875`), und die acht Befunde sind im
Rumpf nachweisbar eingearbeitet (Diff `7a2690a8..d16b2875`): MEDIUM-1 im `Bezug:`, MEDIUM-2 im
Trigger-Abschnitt, LOW-1 als `Baseline`-Absatz, LOW-2/LOW-3 als gekürzte `Proposed`-Zeile, LOW-4
am Nachbar-Repo-Kommentar, INFO-1 als sechster Re-Evaluierungs-Trigger, INFO-2 am §3.8-Verweis.

**Beide offenen Fragen sind beantwortet, mit Gegenposition und Auflösungs-Trigger:**
Festlegung 1/2 beantworten (a) — `verkörpert` trägt die benannte Lücke, ein vierter Ausgang
entsteht nicht; Festlegung 3 beantwortet (b) — der Lese-Schritt liest alle. §Verglichene
Alternativen führt **sechs** Optionen mit je Pro/Contra, darunter die zwei Gegenpositionen
(B vierter Ausgang, D verengter Lese-Gegenstand), beide ausdrücklich über [`AGENTS.md`](../../AGENTS.md)
§3.5 als Senkung verworfen; §Re-Evaluierungs-Trigger führt **sechs** Trigger, darunter einen, der
die Gegenposition aus §Kontext wachhält.

### Liefer-Punkt (2) „Die Regel steht an ihrem Ort und trägt ihren Herkunfts-Anker" — **erfüllt**

Gewählt wurde der **erste** der zwei Ausgänge: die nachgezogene Regel (nicht der Beleg-Satz).

**Der Ort trägt die Regel.** [`observations/README.md`](../plan/planning/observations/README.md)
ist der Regeltäger, den der Plan §3 dafür benennt. Die drei Festlegungen stehen dort vollständig —
nicht als zweite Fassung, sondern als die operative Kurzform derselben Entscheidung:

| ADR-Festlegung | in `observations/README.md` | Differenz |
|---|---|---|
| 1 — `verkörpert` trägt die benannte Lücke; Zielort ist ein Norm-Artefakt, kein Lauf; vierter Quellentyp `Baseline` | Tabellenzeile `verkörpert` (Z. 41, „Wann"/„Wohin") + Absatz Z. 45–53 | keine — dieselben vier Quellen, dieselbe Zielort-Bedingung |
| 2 — wo kein Zielort steht: `geplant`; kein vierter Ausgang | Absatz Z. 51–53 („Hat die Klasse keinen Zielort … Ein vierter Ausgang entsteht nicht") | keine |
| 3 — der Lese-Schritt liest alle Einträge über der Schwelle, zu seinem Zeitpunkt | Absatz Z. 55–59 | keine |

Keine der drei Stellen führt eine zweite Zahl oder eine zweite Menge. Die Fortschreibbarkeit ist
der Unterschied, den die Entscheidung selbst benennt: das `README.md` ist änderbar, die ADR ab
`Accepted` nicht — und **genau dafür trägt die ADR seit `d16b2875` einen sechsten
Re-Evaluierungs-Trigger** (Z. 311–316), der den Regeltäger beobachtet (INFO-1 des Reviews, damit
behoben). Ein Trigger ist kein Sensor — das steht in der ADR selbst; die Lücke ist damit benannt,
nicht geschlossen.

**Der Herkunfts-Anker trägt die verlangte Form** — `· seit slice-<Kennung>`, als **ein** Feld am
Ende des jeweiligen Satzes, zweimal:

```sh
grep -n 'seit slice-die-ausgangs-regel' docs/plan/planning/observations/README.md
# 53:· seit slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.
# 59:· seit slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.
```

Kennungs-Form nach `MR-057` (Name, keine Nummer) und Feld-Form nach
`grundlagen-traceability.md` §Herkunfts-Anker — kein Absatz, keine Klammer um den Grund.

### Die übrigen DoD-Punkte

| §2-Punkt | Urteil | Beleg |
|---|---|---|
| (1) Entscheidung steht, `Accepted` | **erfüllt** | oben — Status, Index, Beleg an beiden Orten, reale Runde ohne HIGH |
| (2) Regel am Ort mit Herkunfts-Anker | **erfüllt** | oben — drei Festlegungen im `README.md`, Anker zweimal in der Form |
| `make gates` grün | **erfüllt** | §1 — EXIT 0, `0 Befund(e)`, selbst gefahren |
| Review durchgeführt, Report liegt vor | **erfüllt** | `2026-09-14-adr-0049-konsistenzrunde` · andere Rolle, frischer Kontext, kein Self-Review |
| Doku-Update: Liefer-Punkt (2) **ist** dieses Item | **erfüllt** | derselbe Träger — das Register-`README.md` |
| Closure-Notiz mit Steering-Loop-Lerneintrag | **noch nicht fällig** | §7 des Plans trägt durchweg `<…>`; Planner-Arbeit (§3.10), läuft nach dieser Rolle |
| Beobachtungs-Register fortgeschrieben | **noch nicht fällig** | kein `evidence/`-Zuwachs in den fünf Commits — gehört hinter die Entscheidung (ADR Folgepflicht 3) |
| Jedes §6-Risiko trägt einen Ausgang | **noch nicht fällig** | §6 führt dreimal `<eingetreten / entfallen / weiter offen — bei Closure zu setzen>` |
| Die drei Paarungen | **noch nicht fällig** | Plan §2 stellt sie ausdrücklich der nächsten Welle-Closure anheim; Repo fährt Wellen-Betrieb |

## 3. Sagt der Plan, was der Artefakt tut?

Quelle dieses Abschnitts ist der **Diff der fünf Commits**, nicht der Bericht der Rollen:

```sh
for c in 7a2690a8 2d7ebb8e fae11c44 d16b2875 e763ed11; do git show --pretty=format: --name-only $c; done | sort -u
# docs/plan/adr/0049-ausgang-traegt-die-benannte-luecke.md
# docs/plan/adr/README.md
# docs/plan/planning/done/slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke.md
# docs/plan/planning/observations/README.md
# docs/reviews/2026-09-14-adr-0049-konsistenzrunde.md
```

**§1-Abgrenzung gehalten — in beiden Richtungen.** Kein Sensor, keine Gate-Änderung (`.d-check.yml`,
`Makefile`, `d-check.mk` unberührt), **kein** Nachzug der achtzehn Register-Ausgänge (keine der
`state.md`, kein `evidence/`-Zuwachs), keine Zeile in
[`harness/conventions.md`](../../harness/conventions.md), kein Eingriff in
`.harness/baseline/`, kein Produkt-Code. Das ist am Datei-Satz der fünf Commits gemessen und
stimmt mit dem Befund des Reviews überein, ohne ihn zu übernehmen.

**Gebaut-aber-nicht-geplant ist nichts** außer den zwei Artefakten, die die DoD selbst verlangt
(der Review-Report) und die der Planner für seine eigene Datei führt (`2d7ebb8e`, `e763ed11` —
den Plan zweimal auf seine Messungen bzw. seine Quelle gezogen). Umgekehrt fehlt keine der vier
Zeilen der §3-Plan-Tabelle: ADR, Register-`README.md` und ADR-Index sind da; die Zeile
`harness/conventions.md` stand dort ausdrücklich mit *(nur falls)* und ist **nicht** fällig
geworden — die ADR begründet das („Anwendungen des adoptierten Stands, kein Adaptions-Eintrag").

**Die Zahlen des §1 — alle neu gefahren, alle bestätigt:**

```sh
# 18 über der Schwelle und offen · 31 über der Schwelle · 114 Einträge gesamt
for d in docs/plan/planning/observations/BEO-*/*/; do
  n=$(ls "$d"evidence 2>/dev/null | wc -l)
  if [ "$n" -ge 3 ] && grep -q '^\*\*Stand:\*\* offen' "$d/state.md"; then echo "$n $d"; fi
done | sort -rn | wc -l                                                        #  18
for d in docs/plan/planning/observations/BEO-*/*/; do printf '%s\n' "$(ls "$d"evidence 2>/dev/null | wc -l)"; done | awk '$1 >= 3' | wc -l   #  31
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l                      # 114
# Heterogenität: 18 offen · 5 wörtlich "Träger ist der Lauf" · 14 mit Lücken-Aussage · 3 mit Slice-Kennung
# Stand-Verteilung: 6 geplant · 101 offen · 7 verkörpert · 0 gestrichen
# die zwei angenommenen `verkörpert`-Fälle: verweis-nachzug-… · vorgeschriebener-ortswechsel-…
# Nachbarzähler §1: 2 · 2 · 2 · 1        Wellen-Dateien: 3        welle-13-results.md: existiert nicht
```

Auch die vier Zahlen der Heterogenitäts-Zählung und die fünf der wörtlichen Lauf-Träger stimmen;
jede steht in §1 mit ihrem Kommando im selben Block. Die ADR-Variante derselben Messung
(`18 10 3` und `5`) ebenfalls. Beide Commits mit den drei Zahlen tragen sie mit ihrem Kommando
(`7a2690a8`: `# 18`, `# 10`; `d16b2875`: die `docs-check`-Zeile) — `MR-051` Setzung 1 ist gewahrt.

### Befund (eigene Klasse, **keine** DoD-Verletzung) — §8 fasst seine eigene Tabelle falsch zusammen

`slice-die-ausgangs-regel-des-registers-deckt-die-benannte-luecke` §8, letzter Absatz vor der
Modus-Begründung:

> **Keiner der zehn erreicht mit diesem Slice 3×** — vier stehen bei 1×, vier bei 2×, zwei bereits darüber.

Gemessen über **dieselben zehn** Kennungen der Tabelle eine Seite darüber:

```sh
for s in benannte-luecke-ohne-ausgang schwellen-uebertritt-ohne-zustaendige-rolle \
         beleg-nach-dem-ausgang-findet-keinen-leser ausgang-nennt-traeger-der-nicht-traegt \
         register-paarung-ohne-gate-modul registerzeile-ohne-traeger-spalte \
         ueberholter-offener-plan-ohne-genormten-ausgang unbelegter-register-eintrag-faellt-durch-die-paarung \
         sichtungs-schritt-zitiert-falschen-zaehler-stand zaehler-label-nennt-falsche-einheit; do
  ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l
done | awk '{if($1==1)a++; else if($1==2)b++; else c++} END{print a" bei 1x, "b" bei 2x, "c" darueber"}'
# 5 bei 1x, 3 bei 2x, 2 darueber
```

**Fünf** stehen bei 1× (`benannte-luecke-ohne-ausgang`, `register-paarung-ohne-gate-modul`,
`registerzeile-ohne-traeger-spalte`, `ueberholter-offener-plan-ohne-genormten-ausgang`,
`unbelegter-register-eintrag-faellt-durch-die-paarung`), **drei** bei 2×, zwei darüber — die
Tabelle des Abschnitts führt genau diese Zähler, die Prosa daneben widerspricht ihr. Der
tragende Satz des Absatzes („**Keiner der zehn erreicht mit diesem Slice 3×**") bleibt richtig,
auch wenn die Closure dieser Beobachtung einen Beleg hinzufügt: `benannte-luecke-ohne-ausgang`
stünde dann bei 2×. Die Folgerung (*kein eigener Folge-Slice aus der Sichtung*) trägt damit
unverändert — falsch ist allein die Verteilung, und sie steht ohne Kommando neben sich, das sie
ausgibt. Der Plan gehört dem Planner; sie gehört in die Closure gezogen (oder ausdrücklich als
verworfen notiert).

### §5 Closure-Trigger

1. **Der Lauf ist wiederholbar, die Zahl steht mit ihrem Kommando** — die Messung der `welle-15`
   liefert unverändert **10**, die drei §1-Kommandos unverändert **18 · 31 · 114**; `make gates`
   EXIT 0. Der entscheidende Betrag (`18`) steht in `7a2690a8` mit seinem Kommando. **Trägt** —
   die volle Ablage der drei Beträge in der Closure-Notiz ist Planner-Schritt.
2. **Gegenposition und Auflösungs-Trigger genannt** — §Verglichene Alternativen (sechs Optionen,
   die zwei Gegenpositionen ausdrücklich) und §Re-Evaluierungs-Trigger (sechs). **Erfüllt.**

### Modul 11 §Bewusstes Brechen — hier liegt **kein** solcher DoD-Punkt vor

Kein DoD-Punkt dieses Slice beruft sich auf einen **Test oder Sensor**: (1) beruft sich auf eine
Reviewer-Runde, (2) auf eine Norm-Aussage, `make gates` ist ein Gate-Lauf und keine Zusage über
eine Eigenschaft, die übrigen sind Artefakt-Existenz und Closure-Pflicht. Der Plan sagt das
zweimal ausdrücklich (§3: *„Kein Test-Eintrag, und das ist kein Vergessen"*; *„Und keine
Gate-Zusage"*), und die ADR §Fitness Function sagt *„Gebaut: keine"*, benennt drei Kandidaten
einzeln und trennt, was ein Sensor könnte (die zwei urteilsfreien Hälften) von dem, was Urteil
bleibt. **Kein fehlender Rot-Beleg, weil keine Testbehauptung existiert** — das ist die
Feststellung, nicht eine Lücke. Ein nachzutragender Beleg hätte hier kein Objekt.

### Der Herkunfts-Anker löst noch nicht auf — **normaler Zwischenstand, keine DoD-Verletzung**

Der Slice liegt in `in-progress/`; `seit slice-<Kennung>` löst nach
`grundlagen-traceability.md` §Herkunfts-Anker erst über `done/slice-<Kennung>.md` §7 auf. Dass
der Move der Closure-Schritt ist, sagt dieselbe Quelle (die Auflösung ist nach dem Archivieren
sogar zweistufig über den Stub), und die **Anker-Paarung läuft ausdrücklich nach dem `git mv`**
(Baseline `modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3c). Liefer-Punkt (2) verlangt
die **Form** des Ankers an der Regel — die steht; die Auflösung ist die Konsequenz einer Closure,
die nach dieser Rolle läuft (§3.10). Kein Befund.

## 4. Was ich nicht geprüft habe, und die Rest-Unsicherheit

- **Die achtzehn Register-Einträge selbst** — welche Ausgänge sie tragen. Das ist nach §1 und
  ADR Folgepflicht 3 ausdrücklich nicht Gegenstand dieses Slice (der Lese-Schritt der nächsten
  Welle-Closure und der Folge-Slice `slice-register-ueber-der-schwelle-bekommt-seinen-waechter`).
  Ich habe nur die Zähler und die `Stand:`-Zeilen gemessen.
- **Die Nachbar-Repos** `/Development/d-check` und `/Development/a-check` — Fremdquellen
  außerhalb dieses Repos; ich habe die zwei Kommandos der ADR nicht nachgefahren, sondern nur die
  Aussage geprüft, die die ADR aus ihnen zieht und die sie selbst als „abschreibbar ist die Form,
  nicht das Ergebnis" einordnet.
- **Der Wortlaut der zwei angenommenen `verkörpert`-Fälle** über die von der ADR gefahrene Sonde
  hinaus (Abschnitt *Grenze der Verkörperung, benannt*) — ich habe die Sonde reproduziert, nicht
  die vollen `state.md` gelesen.
- **`make mutate`, `make full-smoke`** und jede andere Zusage dieses Slice — nicht Teil seiner
  DoD, und der Sensor, den die Regel später bekommt, ist der Folge-Slice (§1 Abgrenzung).
- **Rest-Unsicherheit 1 (Norm-Frage, kein DoD-Objekt):** Die README trägt `· seit slice-<Kennung>`
  auf einer Regel, die die ADR §Konsequenzen als *„Anwendung des adoptierten Stands"* einordnet.
  `grundlagen-traceability.md` §Herkunfts-Anker setzt für seinen Gegenstand einen **engen
  Geltungsbereich** (*„Nur Regeln, die die 3×-Schwelle erreicht haben"*), und die
  Auslöser-Beobachtung `benannte-luecke-ohne-ausgang` steht bei **1×** (gemessen: ein
  `evidence/`-Eintrag). Liefer-Punkt (2) verlangt die Anker-Form ausdrücklich, und die ADR
  Folgepflicht 1 verlangt sie ebenso — der Anker ist damit **plangemäß**, nicht fehlerhaft; ob
  sein Geltungsbereich ihn deckt oder ob hier eine Regel ihren Träger nennt, die aus der
  Baseline-ID-Linie kommt, ist eine Norm-Frage und gehört dem Architect, nicht dieser Rolle.
  **Auf kein DoD-Urteil wirkt sie.**
- **Rest-Unsicherheit 2 (nur zur Kenntnis, nicht Gegenstand):** Die Tabellenzeile `verkörpert` in
  [`observations/README.md`](../plan/planning/observations/README.md) ist gegenüber dem
  abgeschriebenen Baseline-Wortlaut **erweitert**, nicht ersetzt (Diff `7a2690a8`: *„die Regel
  steht"* behält seinen Wortlaut, erhält einen Zusatz, und die Spalte „Wohin" wird präzisiert).
  Der Review hat die Einordnung *Auslegung, keine Senkung* entschieden; ich habe die Erweiterung
  am Diff gesehen und **nicht** neu bewertet — das wäre ein zweiter Review.

## Verdikt

**DoD erfüllt.** Beide Liefer-Punkte tragen wörtlich und nicht nur plausibel: `ADR-0049` steht auf
`Accepted`, ihr Accept-Übergang nennt den Beleg seines Triggers an **beiden** Orten als Kennung,
der Beleg existiert und verdiktet nach der Kategorie des Reviewer-Skills nicht blockierend
(0 HIGH), beide offenen Fragen sind mit Gegenposition und Auflösungs-Trigger beantwortet; die
Regel steht in [`observations/README.md`](../plan/planning/observations/README.md) mit dem
Herkunfts-Anker in der verlangten Form, inhaltsgleich mit den drei Festlegungen der ADR und ohne
zweite Zahl. Die §1-Abgrenzung ist über den Diff der fünf Commits gehalten — kein Sensor, keine
Gate-Änderung, kein Register-Nachzug, keine Zeile in `harness/conventions.md`, kein
Baseline-Eingriff. `make gates` selbst gefahren: EXIT 0.

**Keine DoD-Verletzung.** Kein DoD-Punkt beruft sich auf einen Test oder Sensor, darum gibt es
hier auch keinen nachzutragenden Rot-Beleg (Modul 11 §Bewusstes Brechen hat kein Objekt).

**Was der Planner abhaken darf:**

- (1) `Accepted` mit benanntem Beleg: **ja** — beide Orte, Kennung, Runde real und ohne HIGH.
- (2) Regel am Ort mit Herkunfts-Anker: **ja** — drei Festlegungen im Register-`README.md`,
  `· seit slice-<Kennung>` zweimal in der verlangten Form.
- `make gates` grün: **ja** — EXIT 0, davon `0 Befund(e)`.
- Review durchgeführt: **ja** — `2026-09-14-adr-0049-konsistenzrunde`, fremder Kontext.
- Doku-Update: **ja** — der Träger des Liefer-Punkts (2).

**Noch nicht fällig (Planner, nach dieser Rolle):** §7-Closure-Notiz mit Lerneintrag,
Register-Fortschreibung, die drei Ausgänge der §6-Risiken, die drei Paarungen (nächste
Welle-Closure), der `git mv` nach `done/`.

**Befund für die Closure** (§3, eigene Klasse — **keine** DoD-Verletzung): die Verteilungs-Angabe
in §8 des Plans (*„vier stehen bei 1×, vier bei 2×"*) hält nicht; gemessen sind es **5 / 3 / 2**,
und die Tabelle desselben Abschnitts führt die richtigen Zähler. Der tragende Satz des Absatzes
bleibt richtig.
