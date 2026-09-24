# ADR-0065: Die emittierte Konfiguration folgt der Kennungs-Form des Regelwerks — Präfix-Token für Slice und Welle, die Welle-Regel der Spec-Straten, eine deklarierte Erweiterung für den Adaptions-Block und eine Commit-Menge in den Formen des Regelwerks

**Status:** Proposed

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
setzt in den Zeilen Vertrag, Technik und Sicht die Spalten ADR, Slice, Carveout, Welle und Roadmap auf ❌;
der maschinelle Gate-Text lautet *„enthält `ADR-` oder `slice-` → fail, ohne ausgenommene Sektion"*, und
die Baseline liefert *„bewusst nur die grep-Variante"* aus. `grundlagen-source-precedence.md` §Vergabe
setzt *„Welle- und Slice-Kennungen sind Namen, nicht Nummern"*, lässt das Vertrags-Präfix frei
(eine Kennung ohne und eine mit Bereichssegment sind beide wohlgeformt), nennt ADR und Carveout mit Bereichssegment
(`ADR-IDX-0004`, `CO-AUTH-002`) und verlangt *„Welche Form gilt, deklariert das Repo"*.

```sh
R=.harness/baseline/v6.9.0/regelwerk
grep -c 'enthält `ADR-` oder `slice-`' $R/grundlagen-referenz-richtung.md                      # 1
grep -c 'Welle- und Slice-Kennungen sind Namen, nicht Nummern' $R/grundlagen-source-precedence.md   # 1
grep -rniE 'adaptionsblock' .harness/baseline/v6.9.0 | wc -l                                        # 0
```

**Keine Erwartungswerte** ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahlen wandern mit dem Stand; die dritte trägt die Aussage: Der Adaptions-Block kommt in
der Matrix des Regelwerks **nicht** als Klasse vor. Gemessen am adoptierten Stand `v6.9.0`
([`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).

**Die emittierte Vorlage, gemessen.**

| Stelle | Regelwerk-Text | emittiert heute | Befund |
|---|---|---|---|
| Token Slice | `slice-` (Präfix), Namens-Form | `slice-\d{3}` | ein benannter Slice wird nie gefangen |
| Token Welle | Matrix-Spalte Welle ❌ | `welle-\d{2}` | dasselbe |
| Regel Spec-Straten → Welle | Matrix-Tabelle ❌ ×3 | fehlt | die Klasse steht vor `aussen`, also fängt sie `aussen` nicht |
| Adaptions-Block → Slice/Welle | keine Klasse im Regelwerk | Klasse nur als Ziel von `spec-straten` | keine Regel mit dem Block als Quelle |
| Muster `ids` | Vertrags-Präfix frei, ADR/Carveout mit Segment | nur `ADR-\d{4}` aktiv; Vertrag und Carveout nicht | `ADR-IDX-0004` wird nicht als Kennung gelesen |
| Klasse `adr` | Bereichssegment im Dateinamen möglich | Glob `docs/plan/adr/[0-9]*.md` | eine Datei `IDX-0004-…` liegt außerhalb der Klasse |
| Commit-Menge | Kennung im Commit (Traceability-Constraint) | `ADR-[0-9]{4}`, `LH-[A-Z]{2}-[0-9]{2}`, `MR-[0-9]{3}`, `slice-[0-9]+` | träfe weder `ADR-IDX-0004` noch `LH-FA-IDX-003` noch `CO-…` noch einen benannten Slice |

```sh
grep -nE "token: '(slice|welle)-" internal/emit/templates/d-check.yml        # Z. 53 und 54 tragen die Ziffern-Form
grep -n "^patterns=" internal/emit/templates/enforce/commit-msg-traceability.sh harness/tools/commit-msg-traceability.sh
```

Die Vorlage des Regelwerks (`.harness/baseline/v6.9.0/templates/.d-check.yml`) trägt selbst noch
`slice-\d{3}` (auskommentiert); sie sagt von sich, sie *„bildet die dortige Setzung nur ab"*. Der Text gilt vor
der Vorlage, und die Ziffern-Form widerspricht §Vergabe.

**Was der grüne Start trägt.** Die vier Positionen mit Präfix-Token sind über den Spec-Vorlagen des
Regelwerks grün (`cat .harness/baseline/v6.9.0/templates/spec/*.md | grep -cE '(slice|welle)-'` → **0**).
Über dem emittierten Adaptions-Block sind sie es nicht: die Vorlage `conventions.template.md` trägt Platzhalter
(`slice-<Kennung>`, `slice-*`, `welle-*`), und der Emitter schreibt einen Werkzeug-Satz mit `make slice-mv`
dazu (`grep -cE '(slice|welle)-' .harness/baseline/v6.9.0/templates/harness/conventions.template.md` → **4**
Zeilen aus der Vorlage; eine fünfte stammt aus dem Text des Emitters). Kommando, das die Menge am frisch
emittierten Ziel liefert: `grep -cE '(slice|welle)-' harness/conventions.md` im Ziel.

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
ausnimmt.

**Reichweite.** `.d-check.yml` wird nur an einem freien Pfad geschrieben
([ADR-0007](0007-bootstrap-phasen.md) Festlegung 3); ein zweiter Lauf am Ziel mit vorhandener Datei ist
still (an einem frisch emittierten Ziel gemessen: eine angehängte Adopter-Zeile blieb stehen, und der Lauf nannte die Datei nicht). Die
Commit-**Prüfung** wird dagegen bei jedem Lauf kanonisch neu geschrieben, der Träger nur an einem freien
Pfad ([ADR-0054](0054-emittierter-commit-traeger-skip-if-present.md)). Eine geänderte Vorlage erreicht also
neue Ziele über die Konfiguration und **alle** Ziele über die Prüfung.

## Entscheidung

Wir folgen dem Regelwerk `v6.9.0` in der emittierten Konfiguration an den Stellen, die es setzt, und
deklarieren die eine Stelle, an der wir darüber hinausgehen.

**1. Die Token sind Präfixe, die Namens-Form ist die Voreinstellung.** Auf der Klasse `slice` steht `slice-`,
auf der Klasse `welle` steht `welle-` — wörtlich der Gate-Text. Das Präfix ist eine Obermenge der
Nummern-Form: ein Ziel, das seine Slices nummeriert, bleibt gefangen, und ein Ziel darf die Nummern-Form
behalten, wenn es sie in seiner `harness/conventions.md` deklariert (§Vergabe). Die Vorlage führt keine
Ziffern-Form mehr. Der Fehlalarm — ein Wort wie `slice-mv` oder `slice-lokal` — ist **in Kauf genommen**,
und sein Ausweg ist je Klasse verschieden: in den Spec-Straten gibt es **keinen** (das Regelwerk kennt dort
keine ausgenommene Sektion; das Wort wird umformuliert), in ADR und Adaptions-Block den Zeilen-Marker aus
Festlegung 2. Das Regelwerk sagt über den Fehlalarm nichts; diese Festlegung nimmt ihn nicht aus.

**2. Die Matrix.**
(a) Die Regel `{from: spec-straten, to: welle, allow: false}` tritt hinzu — die Matrix-Tabelle verlangt sie in
allen drei Straten-Zeilen.
(b) Die Regeln `{from: adaptionsblock, to: slice, allow: false}` und `{from: adaptionsblock, to: welle,
allow: false}` treten als **deklarierte Erweiterung** hinzu, nicht als Forderung des Regelwerks: der Block
ist nach [`AGENTS.md`](../../../AGENTS.md) §3.8 normativ wie eine ADR, nur ohne deren Immutabilität, und trägt
wie sie Kennungen, deren Ort der Prozess bewegt (§3.11). Ausnahmen laufen über denselben Zeilen-Marker
`<!-- d-check:status-provenance -->` wie bei `adr → slice/welle`; das Regelwerk erlaubt dem Block den
Herkunfts-Anker (`seit slice-<Kennung>`) ausdrücklich, und der Marker ist die Form, in der es die Ausnahme
für die ADR-Zeile führt (*„die Ausnahme wird am Ort deklariert"*). Der Kommentar der Vorlage nennt beides als
Erweiterung und sagt, warum.
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
(`<PREFIX>-[A-Z]{2}(-[A-Z]+)?-\d{2,3}`, `CO-([A-Z]+-)?\d{3}`), das Werkzeug kennt das Präfix im frischen Ziel nicht.

**4. Die Commit-Menge bleibt in der Zeile `patterns=` und nimmt die Formen des Regelwerks auf.** Eine Quelle,
nicht gelesen aus der Doku-Gate-Konfiguration: die Prüfung läuft im Commit-Pfad mit bash und coreutils
([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)), und ein zweiter Parser mit
anderem Regex-Dialekt wäre eine zweite Fassung. Die Menge trägt: `ADR-<NNNN>` und `CO-<NNN>` mit und ohne
Bereichssegment, `MR-<NNN>`, jede Vertrags-Kennung mit freiem Präfix (Großbuchstaben-Präfix, ein bis mehrere
Segmente, zwei bis vier Ziffern), und `slice-`/`welle-` mit Namen **oder** Nummer. Sie **nimmt an** `ADR-0004`,
`ADR-IDX-0004`, `HSM-FA-03`, `HSM-FA-IDX-003`, `CO-AUTH-002`, `slice-42`, `slice-mv-verweise`,
`welle-cache-warmup`; sie **lehnt ab** eine Message ohne Kennung, `ADR-4`, `SHA-256`, `UTF-8` und eine
Kennung nur in einer Kommentarzeile. Geprüft bleibt die **Anwesenheit**, nicht die Wahrheit. Ein Ziel mit einer
Klasse außerhalb der Menge setzt `HOOKS_DIR` auf sein eigenes Hook-Verzeichnis
(Route der mitgelieferten Prüfung, unverändert). Die Dogfood-Fassung zieht mit: die zwei Fassungen sind durch
Tests aneinander gekoppelt, und die Kopplung an `commits.id-patterns` der eigenen `.d-check.yml` hält die
dritte.

**5. Reichweite.** Neue Ziele bekommen Konfiguration und Prüfung; bestehende Ziele bekommen die **Prüfung** beim
nächsten Lauf und die Konfiguration **nicht**. Der Nachzug der Konfiguration ist Handarbeit des Adopters nach der
Positions-Liste im Herkunfts-Kommentar der Vorlage; ein Hinweis bei jedem Lauf wäre Rauschen, weil eine Adopter-Datei
per Definition abweicht (§Konsequenzen). `harness/migration.md` ist nicht der Träger: es führt den Baseline-Sprung
dieses Repos und nennt kein Zielrepo (`grep -ci 'zielrepo' harness/migration.md` → **0**). Die eigene
`.d-check.yml` dieses Repos zieht **nicht** mit: die Klassen `welle`/`adaptionsblock` und ein Token auf `slice` wären
gegen das Lastenheft (10 Zeilen, Vertrags-Änderung nach dem Change-Request-Verfahren) und gegen einen
eingefrorenen Bestand (113 Zeilen) zu halten — ein eigener Vorgang mit eigener Entscheidung. Die Vorlage ist damit
**strenger als das eigene Repo, und das ist deklariert**: sie gilt für ein Ziel, das ohne Bestand beginnt.

**6. Die Beleg-Pflicht der Lieferung.** Nach
[`MR-054`](../../../harness/conventions.md#mr-054--ein-modul-geht-ins-emittierte-doc-gate-nur-mit-erprobung-grünem-start-und-rotem-gegenbeispiel):
(i) die Zell-für-Zell-Messung der emittierten Konfiguration gegen beide Regelwerk-Dateien, als **erster**
Liefer-Punkt; (ii) der grüne Start der emittierten Vorlage am frischen Ziel; (iii) je Regel und je Muster ein
Gegenbeispiel, das im Ziel rot wird, **mit gelesener Meldung** (die Regel benannt, nicht irgendeine); (iv) je Zahn der
Commit-Prüfung ein Fall, der die Menge bindet — eine Mutation, die sie schwächt, färbt ihn rot.

**Kopf-Marke.** Der Eintrag
[`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
trägt eine Kopf-Marke nach
[`MR-032`](../../../harness/conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger)
auf den Satz seiner Grenze, die emittierte Ebene bleibe außen vor; seine Setzungen bleiben unberührt.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun | kein Vertrag gegenüber Zielrepos ändert sich | ein benannter Slice wird von Matrix und Commit-Prüfung nicht gesehen; die Vorlage widerspricht dem Regelwerk-Text (§Vergabe, Gate-Text) |
| B — Ziffern- **und** Namens-Muster nebeneinander (`slice-(\d{3}\|[a-z][a-z0-9-]*)`) | die Nummern-Form ist ausdrücklich benannt | dieselbe Menge wie das Präfix, komplizierter, und beim ersten Slug mit Ziffer am Anfang falsch |
| **C — Präfix (gewählt)** | wörtlich der Gate-Text; deckt beide Formen; ein Muster | Fehlalarm bei Wörtern wie `slice-mv` — in den Spec-Straten ohne Ausweg |
| D — Adaptions-Block-Regeln ohne Marker | härteste Form | rot bei jedem Herkunfts-Anker, den das Regelwerk erlaubt |
| E — Adaptions-Block-Regeln gar nicht | kein Eingriff in den emittierten Block | der Block trägt, wie eine ADR, eingefrorene Adressen; die Lücke bleibt |
| **F — mit Marker, unter der Bedingung 2(c) (gewählt)** | dieselbe Ausnahme-Form wie bei der ADR; Regelwerk-Erlaubnis bleibt gewahrt | Eingriff in den emittierten Text; der Marker ist nicht Ziel-spezifisch |
| G — Commit-Menge aus `.d-check.yml` lesen | eine Deklaration für beide | zweiter Parser, anderer Regex-Dialekt, die Prüfung liest heute bewusst keine Doku-Gate-Konfiguration |
| H — Commit-Menge in einer Adopter-Datei | pro Ziel anpassbar | neue Artefaktklasse; die Route `HOOKS_DIR` deckt den Fall bereits |

## Konsequenzen

- Positiv: die emittierte Ebene sagt dasselbe wie der adoptierte Regelwerk-Text; ein benannter Slice und eine
  Kennung mit Bereichssegment werden gefangen und nicht mehr abgewiesen; ein Ziel, das seine Kennungs-Form
  deklariert, bekommt eine Vorlage, die sie trägt.
- Negativ: der Fehlalarm des Präfixes (`slice-mv`) trifft Ziele; in den Spec-Straten hilft nur Umformulieren.
  Ein bestehendes Ziel bekommt die Konfiguration nicht von selbst — es trägt die Differenz, bis der Adopter sie
  nachzieht; kein Wächter meldet sie.
- Folgepflicht: ein Liefer-Punkt am Werkzeug (Vorlage, Neutralisierung, Commit-Prüfung samt Dogfood-Fassung); die
  Kopf-Marke am Adaptions-Eintrag zur Namens-Form trägt dieser Commit selbst.

### Grenze

- **Der Marker ist nicht Ziel-spezifisch.** Die Matrix-Tabelle setzt ADR → Welle ❌ **ohne** Ausnahme; der Marker
  nimmt eine Zeile für Slice und Welle zugleich aus. Die Vorlage sagt es dort, wo sie den Marker nennt; ein
  Ziel-spezifischer Marker liegt beim Werkzeug d-check, nicht hier.
- **Carveout und Roadmap** stehen in der Matrix-Tabelle als ❌, tragen aber keine Token-Klasse: ein Link in ein
  Spec-Stratum fängt `aussen`, eine blanke `CO-`-Kennung fängt niemand. Der Gate-Text des Regelwerks nennt nur
  `ADR-` und `slice-`; das ist hier nicht enger, und nicht weiter.
- **Die Commit-Prüfung prüft die Anwesenheit.** Ein freies Vertrags-Präfix nimmt jede Zeichenfolge dieser Form
  an; das ist die Grenze, die die Prüfung schon heute führt.
- **Die eigene Konfiguration bleibt hinter der Vorlage zurück**, und die Spec-Straten dieses Repos nehmen §7
  Historie aus, wo die Vorlage keine Sektion ausnimmt (Regelwerk: *„ohne ausgenommene Sektion"*). Beide
  Unterschiede sind benannt, nicht entschieden.
- **Nicht Gegenstand:** Umbenennung von Bestand; die Werkzeug-Nachzüge für benannte Slices in `slice-mv` und im
  Archiv-Stub dieses Repos
  ([`MR-057`](../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  §Grenze); die Aktivierung des `ids`-Musters für das Vertrags-Präfix; die Regelwerk-Vorlage selbst (Kurs).

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| Go-Test über die eingebettete Vorlage | die vier Positionen der Festlegungen 1 bis 3 stehen in der Vorlage, die Ziffern-Form nicht | `make test` |
| bats über die emittierte Prüfung | die Annahme-/Ablehnungs-Liste aus Festlegung 4; die zwei Fassungen und die `commits`-Kopplung bleiben gleich | `make test` |
| End-to-End im frischen Ziel | grüner Start; je Regel ein rotes Gegenbeispiel mit gelesener Meldung; die Prüfung an einem Commit | `make full-smoke` |
| Mutations-Fall je Zahn | Präfix, Regel `spec-straten → welle`, Marker-Ausnahme, Commit-Menge | `make mutate` (kein Gate) |

Ein Wächter für die Konfigurations-Drift bestehender Ziele existiert nicht; benannt, nicht geschlossen.

## Re-Evaluierungs-Trigger

1. Ein künftiger Regelwerk-Stand führt den Adaptions-Block als Klasse der Matrix oder nimmt die Namens-Form
   zurück: dann entfällt die Erweiterung aus Festlegung 2(b) bzw. die Voreinstellung aus Festlegung 1, per
   Folge-ADR mit `Supersedes`.
2. Der Marker wirkt nicht mit dem Adaptions-Block als Quellklasse, oder der grüne Start braucht mehr Eingriffe
   als die in 2(c) genannten: 2(b) fällt, die übrigen Festlegungen bleiben.
3. d-check führt einen Ziel-spezifischen Marker: die Grenze zu ADR → Welle schließt sich.
4. Ein Ziel meldet einen Fehlalarm, den weder Umformulieren noch Marker löst: die Frage, ob das Präfix ein
   engeres Muster braucht, wird neu gestellt.

**Acceptance-Trigger.** `Accepted` setzt der Auftraggeber nach einer Reviewer-Runde über Kontext und Festlegungen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-24 | Proposed | Architect-Lauf zum Auftrag des Auftraggebers, die emittierte Konfiguration dem Regelwerk `v6.9.0` anzugleichen |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0065` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
