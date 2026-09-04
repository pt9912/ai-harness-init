# ADR-0034: Das Beobachtungs-Register geht in die Verzeichnis-Form — ohne Index, mit einem vierten namentlichen Ventil, und die Register-Datei verliert ihre Ortsfestigkeit

**Status:** Accepted

**Datum:** 2026-09-04

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein Gate,
dessen Befund unbehebbar ist, erzieht dazu, Rot zu überlesen),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (die Ziel-Form kommt aus
einem auf einen Tag gepinnten Baum),
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) (Festlegung 4 — die
Entscheidung wandert vor den Move; Festlegung 2 — die Aufnahme-Grenze, die diese ADR erfüllt;
Festlegung 3 — der eine Wert, den diese ADR ersetzt),
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md) /
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) (die Kette, deren Aufnahme-Grenzen
unverändert fortbinden),
[ADR-0032](0032-eingefrorene-referenz-folgt-ihrem-rumpf.md) (die Form des wert-geschnittenen
Teil-Supersedes),
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (das eingefrorene Artefakt, das
die eine Adresse trägt),
[ADR-0018](0018-ziel-fassung-regiert-die-migration.md) (Festlegung 2 — vor dem Tausch ist der
adoptierte Stand der Ist-Maßstab),
[ADR-0016](0016-verweis-traegt-tag-und-zitat.md) (Festlegung 4 — die Zeitdokument-Klausel, die
hier den Bestand trägt),
[`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage) (eine Abweichung von der
Baseline schuldet einen Eintrag),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie senkt einen Gate-Prüfumfang, setzt eine
Ablage-Form und einen Commit-Zuschnitt, und sie ändert keine Spec-Aussage.

**Supersedes (Teil):** [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
§Entscheidung Festlegung 3, und dort **genau einen Wert** — den Listen-Eintrag *„die stehende
Register-Datei"* in der Aufzählung dessen, was ortsfest ist und als Pfad zulässig bleibt. Alles
andere jener Festlegung bindet unverändert fort: die Regel selbst (*ein Artefakt, das
unveränderlich wird, nennt ein Planning-Artefakt bei der Kennung, nicht als Pfad-Adresse*), ihre
Adress-Menge, ihr Träger (der Accept-Übergang) und die drei übrigen ortsfesten Klassen —
Verzeichnis, Glob, und eine Datei, die bereits in `done/` liegt. Die Festlegungen 1, 2 und 4 jener
ADR bleiben vollständig unberührt; namentlich gilt ihre Aufnahme-**Grenze** weiter, und diese ADR
ist die von ihr verlangte eigene Entscheidung.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md`
§Ziel-Form: ADR (MADR).

---

## Kontext

### Die Ziel-Form kennt keine Index-Datei

`v6.0.0` ersetzt das Beobachtungs-Register als Tabellen-Datei durch eine Verzeichnis-Ablage:
`observations/README.md` plus je Beobachtung ein Verzeichnis `BEO-<KUERZEL>/<slug>/` mit
`observation.md`, `state.md` und `evidence/<vorgangs-id>.md`. Der Zähler ist **abgeleitet** — die
Zahl der Evidence-Dateien —, und ein Feld, in das man ihn schreibt, existiert nicht mehr. Eine
Index-Datei neben dieser Ablage führt die Ziel-Form nicht.

Der Stand ist am vendored Baum des Nachbar-Repos gelesen, das den Sprung bereits vollzogen hat;
dieses Repo ist zum Zeitpunkt dieser Entscheidung noch auf den Vorgänger gepinnt:

```sh
sed -n '/^### Das Beobachtungs-Register/,/^### Wellen-Closure/p' \
  /Development/d-check/.harness/baseline/v6.0.0/regelwerk/modul-06-roadmap.md
ls .harness/baseline/            # v5.18.0 — der hier adoptierte Stand
```

Ein stehenbleibender Index wäre damit eine Abweichung und schuldete einen Eintrag im
Adaptions-Block ([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)). Er trüge
zudem genau das, was die Ziel-Form gerade abschafft: eine zweite Quelle für einen Zustand, den die
Ablage selbst schon trägt.

### Der Befund, an einer Sonde und nicht an einer Prognose

Der Umzug ist ein Fall von [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
Festlegung 4: Vor dem Move misst der bewegende Lauf, ob ein nach
[`AGENTS.md`](../../../AGENTS.md) §3.4 eingefrorenes Artefakt das Ziel als Pfad adressiert. Die
Sonde ist der probeweise vollzogene Wegfall der Datei, `make docs-check` darüber, danach
zurückgenommen — der Ausgangsstand meldet `588 Datei(en) geprüft, 0 Befund(e)`:

```
d-check: 587 Datei(en) geprüft, 355 Befund(e)
```

**355 Befunde über 75 verschiedene Dateien** — 263 `target-missing` (Markdown-Link, Modul `links`)
und 92 `codepath-missing` (Inline-Code, Modul `codepaths`). Die geprüfte Datei-Zahl fällt um genau
eins, und das ist die entfallene Datei selbst.

**Von diesen 75 Dateien ist genau eine eingefroren.** Das ist die Messung, die alles Weitere
trägt:

```
docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md:81	../planning/observations.md	target-missing
```

Kein zweiter Befund liegt in `docs/plan/adr/`. Die Quelldatei steht auf `Accepted`
(`grep -c '^\*\*Status:\*\* Accepted' docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md`
→ **1**); der Befund ist richtig und in ihr unbehebbar.

### Warum die übrigen 74 Dateien kein Ventil brauchen

Sie sind **änderbar**, und für jede der zwei Klassen steht die Reparatur schon geschrieben:

- **Lebende Artefakte** — offene und laufende Slice-Pläne, die Welle-Datei, die Planning-README,
  die Adaptions-Einträge, die Anweisungssätze, die Skill-Datei, die emittierten Vorlagen. Hier
  bleibt der Pfad der richtige Zeiger, und der Move zieht ihn nach; die Linie verläuft an der
  Änderbarkeit der Quelle ([ADR-0023](0023-verweis-beschluss-traegt-ueber-den-sprung.md)
  Festlegung 2, bestätigt in [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md)
  Festlegung 3).
- **Zeitdokumente** — die Dateien unter `docs/plan/planning/done/` und `docs/reviews/`. Für sie
  gilt [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4: *ein Verweis in einem
  Zeitdokument verliert seine Adresse, nicht seinen Text*. Der sichtbare Text bleibt Zeichen für
  Zeichen stehen, die Adresse entfällt, keine Aussage wird nachgezogen — *„Zeitdokumente sind
  nicht von §3.4 geschützt, geschützt ist ihre Aussage"*.

**Das ist der Unterschied zum Nachbar-Repo, und er ist der Grund, warum dessen Konfiguration hier
nicht übernehmbar ist.** Dort sind Zeitdokumente als Lauf-Belege behandelt, die nicht editiert
werden; deshalb brauchte der dortige Umzug **fünf** auf Verzeichnisse geschnittene Paare —
`done/**`, `docs/reviews/**`, `docs/plan/adr/**`, `harness/conventions/done/**` und ein
CR-Verzeichnis, das dieses Repo gar nicht führt. Dieses Repo hat für dieselbe Klasse eine
**Reparatur** statt einer Ausnahme, und darum bleibt von fünf Quell-Klassen genau eine übrig: die
angenommene ADR.

### Das Ventil, gemessen — beide Skopen an einer roten Gegenprobe

Sonde in [`.d-check.yml`](../../../.d-check.yml), je ein `make docs-check` über dem probeweise
entfallenen Register, danach zurückgenommen:

| Sonde | `in` | `refs` | Ergebnis |
|---|---|---|---|
| trägt | [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) | der Ort der Register-Datei, **aufgelöst** (Wortlaut in Festlegung 2) | `587 … 354 Befund(e)`, der Befund oben **fehlt** |
| Gegenprobe Quell-Skopus | [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) | wie oben | `587 … 355 Befund(e)`, der Befund **steht** |
| Gegenprobe Ziel-Skopus | [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) | die **geschriebene**, relative Form aus der Quelldatei | `587 … 355 Befund(e)`, der Befund **steht** |
| Gegenmessung Datei-Achse | — | `scan.ignore` um [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) erweitert | `586 … 354 Befund(e)` |

Die dritte Zeile misst eine Werkzeug-Eigenschaft, die bisher nur behauptet war: **`refs` trifft den
aufgelösten Pfad, nicht den geschriebenen.** Die vierte trägt dasselbe Kriterium wie in
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) — tragend ist der Unterschied
in der ersten Zahl, nicht ihr Betrag: Das Referenz-Ventil lässt sie bei 587, der datei-weite
Ausschluss senkt sie auf 586.

### Die Glob-Form kauft heute nichts und kostet morgen

Dieselbe Sonde mit dem Quell-Skopus als Verzeichnis-Glob, also in der Form des Nachbar-Repos:

```
d-check: 587 Datei(en) geprüft, 354 Befund(e)
```

**Dasselbe Ergebnis wie das namentlich geschnittene Paar.** Der Glob löst keinen Befund, den das
enge Paar stehen ließe — er ist kein Zugewinn, sondern nur eine breitere Quell-Menge:

```sh
ls docs/plan/adr/[0-9]*.md | wc -l                                    # 33  ADR-Dateien im Quell-Skopus
grep -L '^\*\*Status:\*\* Accepted' docs/plan/adr/[0-9]*.md | wc -l   #  6  davon noch änderbar
```

Sechs der 33 stehen **nicht** auf `Accepted`. Bei ihnen ist eine tote Adresse behebbar, und der
Glob nähme die Prüfung dort weg, wo die Reparatur erlaubt ist — dieselbe Widerlegung, die
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) ihrer Option F entgegengehalten
hat, hier eine Ebene enger. **Keine Erwartungswerte**
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

### Die Ortsfestigkeit, die [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) angenommen hat, gilt nicht mehr

Jene ADR hat das Register beim Erheben ihrer Klasse ausdrücklich als unbeweglich eingestuft und
daraus eine Erlaubnis abgeleitet: Die stehende Register-Datei stehe unter dem, was *ortsfest* ist
und darum als Pfad-Adresse auch in einem einfrierenden Artefakt zulässig bleibt. Die Annahme war
am adoptierten Stand richtig — dort ist das Register *eine stehende Datei an einem festen Ort* —
und der Sprung widerlegt sie: Die Datei entfällt. Die Erlaubnis ist damit ein Angebot an künftige
Schreiber, eine Adresse zu setzen, die der nächste vorgeschriebene Vorgang bricht. Sie fällt.

**Was an ihre Stelle tritt, ist keine Lücke.** Die Ablage der Ziel-Form ist ein Verzeichnis, und
Verzeichnisse sind in derselben Aufzählung ortsfest — auch je Beobachtung, denn *gestrichen heißt
nicht gelöscht*: Das Verzeichnis bleibt liegen und `state.md` trägt den Ausgang. Unbeweglich ist
nach dem Sprung also die **Ablage**, nicht die Datei.

### Das Kürzel-Segment ist keine Wahl mehr

Die Ziel-Form adressiert `BEO-<KUERZEL>/<slug>`, und das Kürzel wird *nachgeschlagen, nicht
erfunden* — aus der Modus-Deklaration in
[`harness/conventions.md`](../../../harness/conventions.md#modus-deklaration-pro-sub-area). Diese
Tabelle führt heute **keine** Kürzel-Spalte und begründet das gemessen: Die Spalte sei nur dort
verlangt, wo Kennungen ein Bereichssegment tragen, und dieses Repo zähle ohne Segment.

Diese Begründung ist am adoptierten Stand richtig und vom Sprung überholt. Die Ziel-Fassung sagt
den Fall ausdrücklich an:

> **Die Spalte ist nicht bedingt.** Sie war es, solange kein Kern-Artefakt ein Segment verlangte.
> Seit die Kennung einer Beobachtung der Pfad `BEO-<KUERZEL>/<slug>` **ist** …, trägt jedes Repo
> mindestens eine Kennungsklasse mit Segment; die Bedingung ist erfüllt, nicht aufgehoben.

Damit ist der *dritte Weg*, den der tragende Slice-Plan zu benennen statt zu unterstellen
verlangt, kein Ausweichen, sondern die Ziel-Form selbst: Die Spalte deklariert das Segment **der
Beobachtungs-Kennung** und sonst keiner. Sie sagt nichts über `ADR-NNNN` und `slice-NNN`, und der
Zählraum jener beiden Familien bleibt unberührt — gemessen weiterhin ohne Segment:

```sh
git grep -ohE '\b(ADR|CO|MR)-[A-Z]{2,}-[0-9]+|\bslice-[A-Z]{2,}-[0-9]+' -- '*.md' ':!.harness/baseline' | sort -u | wc -l   # 0
```

Tragend ist dabei nur eine Zeile der Tabelle: Alle Einträge des Registers führen dieselbe Sub-Area:

```sh
awk -F'|' '/^\| BEO-/{gsub(/^[ \t]+|[ \t]+$/,"",$4); print $4}' docs/plan/planning/observations.md | sort | uniq -c   # 29 × `*` (gesamtes Repo)
```

### Der Commit-Zuschnitt hat eine gemessene Antwort

[`AGENTS.md`](../../../AGENTS.md) §3.3 verlangt Move und Inhaltsänderung als zwei Commits, und
ihre Prämisse steht im Satz daneben: *sonst fällt die Rename-Detection unter die
Similarity-Schwelle*. Die Regel ist baseline-nativ, nicht repo-eigen
(`grep -c 'git mv + Inhaltsänderung = zwei Commits' .harness/baseline/v5.18.0/regelwerk/modul-09-implementierung.md`
→ **1**).

**Die Zwischenteilung ist hier gemessen, nicht geschätzt** — sie ist genau die Sonde oben: Ein
erster Commit, der die alte Datei entfernt, ohne dass die neue Ablage steht und die lebenden
Verweise umgehängt sind, ist der Zustand `587 Datei(en) geprüft, 355 Befund(e)` über 75 Dateien.
Er ist rot, und zwar nicht knapp. Eine grüne Zwischenteilung existiert für diesen Vorgang nicht.

Und die Prämisse der Regel trifft nicht zu: Aus **einer** Tabellen-Datei werden eine `README.md`
und je Beobachtung ein Verzeichnis mit drei Datei-Klassen. Es gibt kein Paar aus Quelle und Ziel,
dessen Ähnlichkeit eine Schwelle über- oder unterschreiten könnte — der Vorgang ist eine Zerlegung,
kein Move. **Behauptet wird das hier nicht**: Festlegung 4 unten macht die Abwesenheit des Renames
zu einer Messung, die der vollziehende Lauf vorlegt.

## Entscheidung

**Das Register läuft in der vollen Ziel-Form; die Index-Datei entfällt ersatzlos; die eine
eingefrorene Adresse bekommt ein viertes, namentlich geschnittenes Referenz-Ventil; das Kürzel ist
entschieden; und die Ortsfestigkeit der Register-Datei wird zurückgenommen.** Fünf Festlegungen.

**1. Die stehende Register-Datei entfällt, und keine Index-Datei tritt an ihre Stelle.**
Die Ablage ist die der Ziel-Fassung: ein Verzeichnis `observations` unter `docs/plan/planning/`
mit `README.md` und je Beobachtung einem Verzeichnis. Ein Index wäre eine Abweichung mit
Eintrags-Pflicht und trüge eine zweite Quelle für einen Zustand, den die Ablage schon trägt; die
Präzedenz des Adaptions-Blocks
([`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form))
trägt nicht auf diesen Fall, weil ihr Zielartefakt in der Pflichtgliederung der Baseline steht und
dieses nicht.

**2. [`.d-check.yml`](../../../.d-check.yml) bekommt genau ein viertes Top-Level-`ignore-refs`-Paar,
dessen beide Skopen je auf eine namentlich genannte Datei geschnitten sind** —

- `in: "docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md"`
- `refs: ["docs/plan/planning/observations.md"]`

**und keinen weiteren.** Der Wert von `refs` ist der **aufgelöste** Pfad; die geschriebene,
relative Form trägt nicht (Sonden-Tabelle, dritte Zeile).

Das ist eine Aufnahme-**Grenze**, keine Aufnahme-**Regel**: **jeder zusätzliche Eintrag, jedes
zusätzliche Glob in `in` oder `refs` und jede Verbreiterung eines der beiden auf ein Verzeichnis
ist eine neue Senkung und löst [`AGENTS.md`](../../../AGENTS.md) §3.5 erneut aus — auch dann, wenn
sie dieselbe Bedingung erfüllt wie diese.** Die Grenzen aus
[ADR-0026](0026-eingefrorene-referenz-referenz-weit-ausgenommen.md),
[ADR-0027](0027-tote-adresse-in-eingefrorener-adr.md) und
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) gelten unverändert weiter;
diese ADR erhöht die Zahl der Paare von drei auf vier und nicht die Zahl der Entscheidungen, die
ein fünftes braucht. **Die Glob-Form ist ausdrücklich nicht gewählt**, und der Grund ist gemessen:
Sie löst keinen Befund zusätzlich und weitet den Quell-Skopus auf 33 Dateien, davon sechs
änderbare.

Der Eintrag trägt im Config-Kommentar seine Begründung und einen Zeiger auf diese ADR — wie jede
Ventil-Zeile der Datei.

**Die übrigen 74 Dateien bekommen kein Ventil.** Lebende Artefakte werden nachgezogen;
Zeitdokumente verlieren die Adresse und behalten den Text
([ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4). Wer beim Vollzug feststellt, dass
eine dieser 74 doch nicht änderbar ist, hat einen **neuen** Fall und keine gedeckte Ausnahme.

**3. Die Modus-Deklaration bekommt eine Kürzel-Spalte, und sie deklariert das Segment der
Beobachtungs-Kennung — sonst keiner.** Die Werte, ab Vergabe unveränderlich:

| Sub-Area | Kürzel |
|---|---|
| `*` (gesamtes Repo) | `ALL` |
| `harness/tools/` | `TOOLS` |
| `.codex/` | `CODEX` |

Tragend für den Umzug ist allein `ALL`: Alle 29 Einträge führen `*` (Kommando im Kontext). Die
zwei übrigen entstehen mit derselben Spalte, weil die Ziel-Form sie je Sub-Area verlangt und eine
halb gefüllte Spalte die Nachschlage-Zusage bricht.

**Geschrieben wird die Spalte nicht von dieser ADR und nicht heute**, sondern von dem Lauf, der
den Umzug vollzieht — nach dem Baum-Tausch. Vorher ist der adoptierte Stand der Ist-Maßstab
([ADR-0018](0018-ziel-fassung-regiert-die-migration.md) Festlegung 2), und dessen Regel trägt die
heutige Leere der Spalte zu Recht. Der Absatz, der diese Leere begründet, wird im selben Zug
ersetzt; er ist dann falsch, nicht nur veraltet. **Das ist ein Architect-Commit**
([`AGENTS.md`](../../../AGENTS.md) §3.8) und liegt damit neben dem Migrations-Commit aus
Festlegung 4, nicht in ihm.

**4. Der Migrations-Commit ist einer — und der vollziehende Lauf legt die Messung vor, die das
trägt.** [`AGENTS.md`](../../../AGENTS.md) §3.3 greift nicht, weil ihr Gegenstand fehlt: Der
Vorgang ist eine Zerlegung ohne Move. Zwei Belege sind dafür beizubringen, und der erste steht
schon:

1. **Keine grüne Zwischenteilung** — gemessen als `587 Datei(en) geprüft, 355 Befund(e)` über 75
   Dateien für den Zustand *alte Datei fort, neue Ablage und Verweise noch nicht da*.
2. **Kein erkannter Rename** — `git diff-tree -r --name-status -M` über dem Migrations-Commit
   weist keine `R`-Zeile aus. Diese Messung ist **vorzulegen, nicht vorauszusetzen**: Weist sie
   doch einen Rename aus, trifft die Prämisse von §3.3 zu, und der Vorgang wird geteilt.

Die Erlaubnis deckt **ausschließlich** diesen einen Commit. Sie ist keine Blankovollmacht für
weitere Struktur-Umbauten; ein anderer Formatwechsel prüft erneut gegen die Zwei-Commit-Grundregel
und braucht, falls deren Prämisse ebenfalls fehlt, seine eigene Entscheidung.

**5. Die stehende Register-Datei ist nicht mehr ortsfest.** Der Listen-Eintrag aus
[ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 3 entfällt; ein
Artefakt, das unveränderlich wird, nennt das Beobachtungs-Register nicht mehr als Datei-Pfad.
Ortsfest und als Pfad zulässig sind nach dem Sprung die **Ablage** `observations` unter
`docs/plan/planning/` und die Verzeichnisse darin — letztere, weil ein gestrichener Eintrag liegen
bleibt. Die drei übrigen ortsfesten Klassen jener Festlegung — Verzeichnis, Glob, eine Datei in
`done/` — bleiben unverändert.

**Diese ADR wendet Festlegung 3 in ihrer neuen Fassung auf sich selbst an**: Sie nennt die Slices
des Vorgangs bei der Kennung und trägt keine bewegliche Pfad-Adresse in den Planning-Baum. Der
Wortlaut in Festlegung 2 ist die Ausnahme, die sich selbst erklärt — er ist der Gegenstand des
Config-Eintrags und steht dort als Zitat der Config, nicht als Zeiger; er ist in derselben Form
geschrieben, in der [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) ihren
Eintrag zitiert, und an derselben Sonde gemessen (Folgepflicht 3).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun, den Umzug nicht vollziehen | keine Senkung, keine Entscheidung | Die Ablage-Form ist eine **Pflicht** der Ziel-Fassung; sie nicht zu vollziehen ist eine Abweichung mit Eintrags-Pflicht und lässt den gemessenen Kollisions-Punkt bestehen: eine Datei, in die jede Closure schreibt. Und der Fall bliebe ungelöst, statt entschieden zu sein — [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 4 verlangt die Entscheidung **vor** dem Move, nicht ihr Ausbleiben |
| B — Index-Datei bleibt stehen, die Einträge wandern | keine Adresse stirbt, kein Ventil nötig, Präzedenz im eigenen Adaptions-Block ([`MR-045`](../../../harness/conventions.md#mr-045--der-adaptions-block-läuft-in-der-verzeichnis-form)) | Die Ziel-Form führt für dieses Register **keine** Index-Datei — die Abweichung schuldete einen Eintrag. Die Präzedenz trägt nicht: `harness/conventions.md` steht in der Pflichtgliederung der Baseline, dieses Register nicht. Und ein Index trüge entweder einen Zähler — die zweite Quelle, die die Ziel-Form gerade abschafft — oder er trüge ihn nicht und wäre eine Datei, die nichts sagt, was die Ablage nicht sagt |
| C — die Adresse in [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) nachziehen oder entfernen | zwei Zeichen, schließt den Befund dauerhaft | Byte-Änderung an einem §3.4-eingefrorenen Artefakt, von keiner Quelle gedeckt. [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 trägt sie **nicht**: Sie ist für Zeitdokumente geschrieben, und ihr Grund — *„Zeitdokumente sind nicht von §3.4 geschützt"* — ist bei einer ADR abwesend. Dieselbe Widerlegung wie in [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Option B/C |
| D — `scan.ignore` auf [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (Datei-Achse, wie [ADR-0017](0017-doku-gate-ausnahme-fuer-ein-eingefrorenes-adr.md)) | eine Zeile, ein bereits geführter Schlüssel | nimmt die **ganze Datei** aus der Prüfung statt der einen toten Referenz. Gemessen fällt die geprüfte Datei-Zahl von 587 auf **586** (Sonden-Tabelle), während das Referenz-Ventil sie stehen lässt — der Prüfbereich schrumpft, was das Referenz-Ventil gerade nicht tut |
| E — die fünf Verzeichnis-Globs des Nachbar-Repos übernehmen | eine erprobte, bereits im Betrieb laufende Konfiguration; deckte jeden künftigen Fall derselben Klasse mit | **Gemessen wertlos und zugleich teurer.** Der Glob löst `587 … 354` — **denselben** Wert wie das enge Paar, also keinen Befund zusätzlich —, weitet aber den Quell-Skopus auf 33 ADR-Dateien, davon sechs noch änderbare, wo die Reparatur erlaubt ist und unsichtbar würde. Vier der fünf Paare hätten hier ohnehin keinen Gegenstand: Zeitdokumente werden in diesem Repo nach [ADR-0016](0016-verweis-traegt-tag-und-zitat.md) Festlegung 4 **repariert**, und ein CR-Verzeichnis führt dieses Repo nicht. Und die Form ist von [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Festlegung 2 ausdrücklich ausgeschlossen — sie zu wählen hieße, eine Grenze zu senken, um eine Schreibarbeit zu sparen, die aus **einem** Paar besteht |
| **F — gewählt: volle Ziel-Form ohne Index, ein viertes namentliches Paar, Kürzel entschieden, Commit-Zuschnitt gemessen, Ortsfestigkeit zurückgenommen** | kleinstmöglicher Prüfbereichs-Verlust — die geprüfte Datei-Zahl bewegt sich durch das Ventil nicht, die Restbreite ist strukturell null; beide Skopen an einer roten Gegenprobe belegt; die Grenze aus [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) wird **erfüllt** statt umgangen; und die falsch gewordene Ortsfestigkeits-Erlaubnis fällt in derselben Entscheidung, die sie widerlegt, statt als Angebot an den nächsten Schreiber stehen zu bleiben | es ist die vierte Ausnahme unter demselben Schlüssel und die fünfte Gate-Senkung dieser Klasse. Der Kürzel-Wert ist ab Vergabe unveränderlich und wird hier für eine Ablage entschieden, die es noch nicht gibt. Und Festlegung 4 verschiebt ihre zweite Messung in den vollziehenden Lauf — vorgelegt ist sie erst dort |

## Konsequenzen

- **Positiv:** `make docs-check` bleibt nach dem Umzug grün, ohne dass ein eingefrorenes Artefakt
  angefasst wird und ohne dass eine Datei den Prüfbereich verlässt — die geprüfte Datei-Zahl steht
  vor und nach dem Eintrag auf demselben Wert.
- **Positiv:** Die Restbreite des Paares ist strukturell null: `in` ist nach §3.4 eingefroren und
  kann keine zweite Referenz bekommen.
- **Positiv:** Der Bestand ist **vollständig** aufgelöst und nicht nur der eingetretene Fall — 74
  der 75 Dateien haben eine Reparatur, eine hat ein Ventil. Ein geladenes zweites Mitglied bleibt
  nicht zurück.
- **Negativ:** [`AGENTS.md`](../../../AGENTS.md) §3.5 hat **keinen Sensor**. Die Schranke gegen ein
  fünftes Paar ist prozessual, wie bei jeder anderen Senkung dieses Repos.
- **Negativ:** Der Kürzel-Wert `ALL` wird vergeben, bevor eine zweite Sub-Area je eine Beobachtung
  trägt. Er ist danach unveränderlich; die Entscheidung nimmt das in Kauf, weil die Ziel-Form ohne
  Segment keinen Pfad hat.
- **Negativ:** Festlegung 4 deckt einen Commit, dessen Rename-Messung noch aussteht. Fällt sie
  anders aus als erwartet, ist die Erlaubnis gegenstandslos und der Vorgang zu teilen — das ist
  gewollt und der Grund, warum die Messung dort und nicht hier steht.
- **Folgepflicht 1 (der Lauf, der den Umzug vollzieht):** das vierte Paar in
  [`.d-check.yml`](../../../.d-check.yml) anlegen — **samt Config-Kommentar mit Begründung und
  Zeiger auf diese ADR** — und mit zwei `make docs-check`-Läufen belegen, dass der Befund ohne den
  Eintrag steht und mit ihm fällt, bei unveränderter geprüfter Datei-Zahl. `scan.ignore` und
  `codepaths.exempt-paths` bleiben unverändert.
- **Folgepflicht 2 (Architect, eigener Commit):** die Kürzel-Spalte und der Ersatz des Absatzes,
  der ihre Leere begründet, in
  [`harness/conventions.md`](../../../harness/conventions.md#modus-deklaration-pro-sub-area).
- **Folgepflicht 3 (benannte Lücke, nicht behauptete Deckung):** der Restbreite-Wächter
  `test/ignore-refs-restbreite.bats` liest **jedes** Paar des Top-Level-Blocks, misst aber
  ausweislich seines eigenen Kopfes nur die Inline-Markdown-Form `](ziel)`. Für dieses Paar ist die
  reale Breite genau **ein** Markdown-Link, und damit liegt es in seinem Messbereich — anders als
  das dritte Paar, dessen Code-Span-Achse er nicht sieht
  ([ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) Folgepflicht 2, unverändert
  offen). **Diese ADR behauptet keine Deckung, die über den Link hinausgeht**
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
- **Folgepflicht 4 (die Selbstanwendung, an einem rot gesehenen Gegenbeispiel):** Diese Datei
  zitiert den Ort der Register-Datei in Festlegung 2. Dass dieses Zitat nach dem Wegfall **keinen**
  Befund erzeugt, ist an derselben Sonde geprüft und nicht angenommen — und das Gegenbeispiel stand
  einmal rot: Eine frühere Fassung nannte den Ort in Festlegung 1 als blanken Pfad in einem
  Code-Span, und die Sonde meldete `356` statt `355` Befunde, den zusätzlichen in dieser Datei.
  **Die Form entscheidet, und der Unterschied ist gemessen:** Ein Code-Span, der nur den Pfad
  trägt, löst `codepaths` aus; derselbe Pfad als Wert innerhalb eines YAML-Fragments tut es nicht,
  und ein Vorkommen in einem umzäunten Block ebenso wenig. Wer die Zitat-Form ändert, prüft erneut.

## Fitness Function (falls maschinell prüfbar)

**Gebaut — und was es nach dieser Senkung noch prüft:**

| Tooling | Regel | Make-Target |
|---|---|---|
| d-check `links` + `anchors` + `codepaths` | jede Referenz aus [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) **außer** der einen ausgenommenen löst auf; jede Referenz **auf** die neue Ablage bleibt vollständig bewacht — der Eintrag wirkt auf der Ziel-Achse, nicht auf der Quell-Achse | `make docs-check` |
| bats, `test/ignore-refs-restbreite.bats` | der Top-Level-`ignore-refs`-Block wird vollständig und in bekannter Form gelesen; eine unbekannte Zeilenform färbt rot statt still zu bleiben. Für dieses Paar misst er zusätzlich die reale Restbreite, weil sie ein Markdown-Link ist | `make test` (in `make gates`) |

**Nicht gebaut, und hier ehrlich zu benennen — drei Stück.** **Festlegung 1** hat keinen Sensor:
Kein Modul prüft, ob neben der Ablage eine Index-Datei steht. **Festlegung 3** hat keinen: Kein
Modul des hier gepinnten Doku-Gates liest die Modus-Deklaration, und ob ein Beobachtungs-Pfad sein
Kürzel dort nachschlägt, prüft nichts. **Festlegung 4** hat keinen und ist die schwächste: Sie ist
eine Aussage über den Zuschnitt **eines Commits**, und kein Gate dieses Repos liest Commits —
dieselbe Lage, die [`AGENTS.md`](../../../AGENTS.md) §3.8 für sich selbst feststellt. Alle drei
liegen im Feedforward-Quadranten: benannt, nicht geschlossen.

## Re-Evaluierungs-Trigger

- **Wenn ein fünftes Paar gesetzt werden soll** *(am Vorgang ablesbar; §3.5 greift von selbst)*:
  dann ist zu prüfen, ob Festlegung 3 aus
  [ADR-0030](0030-eingefrorene-adresse-auf-den-planning-lifecycle.md) in ihrer neuen Fassung nicht
  getragen hat, ob deren Festlegung 4 übergangen wurde oder ob der Fall neu ist. Drei Diagnosen mit
  drei Antworten.
- **Wenn die Rename-Messung aus Festlegung 4 einen Rename ausweist** *(am Migrations-Commit
  ablesbar)*: dann trifft die Prämisse von §3.3 doch zu, die Ein-Commit-Erlaubnis ist
  gegenstandslos, und der Vorgang gehört geteilt.
- **Wenn eine zweite Sub-Area eine Beobachtung trägt** *(an der Ablage ablesbar)*: dann wird das
  zweite Kürzel aus Festlegung 3 erstmals benutzt, und seine Wahl ist an der ersten realen
  Benutzung zu prüfen — danach ist sie unveränderlich.
- **Wenn das gepinnte Doku-Gate ein Modul für die Verzeichnis-Ablage bekommt** *(am Pin ablesbar)*:
  dann ist zu prüfen, ob die maschinelle Hälfte der Register-Paarung über der neuen Ablage läuft;
  diese ADR verbucht sie **nicht** als vorhanden.
- **Wenn [`AGENTS.md`](../../../AGENTS.md) §3.4 eingeschränkt würde** *(am Text ablesbar)*: dann
  fällt die Voraussetzung des Ventils, der Befund wäre im Artefakt behebbar, und der Eintrag aus
  Festlegung 2 ist **zurückzunehmen**, nicht stillschweigend mitzuführen.
- **Wenn der gepinnte d-check das geteilte `ignore-refs` verlöre** *(feedforward — eine
  Werkzeug-Version, kein Sensor)*: dann fällt die Voraussetzung von Festlegung 2, und der Befund
  kehrt zurück.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-04 | **Proposed** | Architect-Entscheid zu dem Fall, den der bevorstehende Wechsel der Register-Ablage erzeugt. Sechs Läufe am gepinnten Stand tragen ihn: der probeweise Wegfall der Datei, das geschnittene Referenz-Ventil, seine zwei roten Gegenproben, die Gegenmessung auf der Datei-Achse und die Sonde, die der Glob-Form ihren Zugewinn abspricht. Die Klasse ist über **beide** Adress-Formen erhoben und über den **ganzen** Bestand — 75 Dateien, davon eine eingefroren |
| 2026-09-04 | **Accepted** | Die Gestalt aus Festlegung 1 — volle Ziel-Form, kein Index — ist die Entscheidung des Auftraggebers; die Festlegungen 2 bis 5 sind der Architect-Entscheid, der sie regelkonform trägt. Vollzogen in der Architect-Rolle ([`AGENTS.md`](../../../AGENTS.md) §3.8). **Ab hier bindet [`AGENTS.md`](../../../AGENTS.md) §3.4**: jede Korrektur ist eine Folge-ADR mit `Supersedes`. Festlegung 5 regiert diese Tabelle selbst — die Slices des Vorgangs stehen bei der Kennung, ohne bewegliche Pfad-Adresse |
