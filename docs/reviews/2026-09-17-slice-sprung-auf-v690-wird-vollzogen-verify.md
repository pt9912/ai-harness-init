# Verifikation `slice-sprung-auf-v690-wird-vollzogen`: DoD 1 und 3 erfüllt, DoD 2 im Repo nicht bestätigt

**Rolle:** Verifier · **Datum:** 2026-09-17 · **Geprüfter Stand:** `56a86a77`. Der Arbeitsbaum
war vor diesem Bericht sauber, und der Gate-Stempel stimmte mit dem Hash überein
(`cat .harness/state/gates-passed.diffsha` und `bash harness/tools/working-tree-hash.sh` geben
denselben Wert aus). Geprüft wurde die Kette `1aee7739..56a86a77`, 30 Commits
(`git rev-list --count 1aee7739..56a86a77`). **Verifikations-Art:** DoD- und ADR-Konformität
gegen den tatsächlichen Baum (Modul 11). Das ist kein Review.

**Eingang:**

- der Slice-Plan `slice-sprung-auf-v690-wird-vollzogen` §1 bis §8, Stand im Pfad `in-progress/`;
- [ADR-0056](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (`Accepted`),
  §Konsequenzen;
- das Architect-Verdikt zum Plan (`docs/reviews/2026-09-16-slice-sprung-auf-v690-wird-vollzogen-architect.md`);
- die zwei Review-Reports vom 2026-09-16 und vom 2026-09-17 (Nachprüfung). Sie sind gelesen,
  ihre Messungen sind nicht wiederholt.
- der Vorlagen-Bericht `docs/migrations/v6.9.0.md`;
- Baseline-Regelwerk `v6.9.0` · `regelwerk/modul-11-verification.md` §Bewusstes Brechen für
  DoD-Testbehauptungen.

**Maßstab** sind die Setzungen des Auftraggebers:

- Die Übernahme ist vollständig und delta-gebunden.
- Die Pflichtgliederung ist vollständig; ein bedingter Abschnitt steht nur da, wenn seine
  Bedingung zutrifft.
- Stoff zieht nur wörtlich und nur innerhalb derselben Datei um.
- Die Spec zeigt nicht nach außen.
- Die Planungs-README ist eine Singleton-Instanz.
- Der Folge-Slice für die fünf Instanzen ohne Delta ist
  `slice-gliederung-der-instanzen-ohne-vorlagen-delta`.

**Noch nicht fällig** sind die fünf unteren DoD-Zeilen: Closure-Notiz, Reconciliation,
Beobachtungs-Register, Risiko-Ausgänge und Paarungen. Sie gehören dem Planner.

> **Zitier-Form.** Für alles, was der Prozess bewegt, steht die Kennung statt der Adresse.
> Baseline-Stellen stehen als Tag + Pfad in Inline-Code. Zahlen stehen neben dem Kommando, das
> sie ausgibt ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).

---

## 1. Ergebnis je DoD-Punkt

| DoD | Ergebnis | Beleg (Abschnitt) |
|---|---|---|
| 1.1 vendored Baum | erfüllt | nur `v6.9.0` unter `.harness/baseline/`; `baseline-verify` meldet OK; die Herkunft aus dem Asset ist indirekt gestützt (§2) |
| 1.2 fünf Pin-Stellen | erfüllt | alle fünf tragen Tag und sha256 von `v6.9.0`; die drei Wächter wurden rot gesehen, und zwar aus dem richtigen Grund (§5) |
| 1.3 sieben Symlinks | erfüllt | `7` / `0` (§2) |
| 1.4 126 Markdown-Links | erfüllt | Link-Kommando aus Plan §1 → `0` (§2) |
| 1.5 108 Inline-Pfade | inhaltlich erfüllt, **Abzählung unvollständig** | 27 Rest-Treffer; 2 sind im Umsetzungs-Lauf benannt, **25 nicht** (§2, Befund V-2) |
| 2 Freshness-Review + Stichprobe | **im Repo nicht bestätigt** | Ergebnis steht nur als Sammelzeile in `0b7bcd2e`; die Stichprobe steht nirgends im Repo (§3, Befund V-1) |
| 3.1 eine Zeile je Vorlage | erfüllt | 25 = 10 + 5 + 9 + 1 (§4) |
| 3.2 Delta am vendorten Baum | erfüllt | fünf Vorlagen, jede mit Ausgang (§4) |
| 3.3 Vorlagen mit Delta | erfüllt | Planungs-README und Roadmap übernommen; Slice-Vorlage append-only mit Datum (§4) |
| 3.4 bestehende Instanzen | erfüllt | Ist-Maßstab ausgewiesen, drei Register-Zeilen berichtet, `observation` ausgenommen (§4) |
| `make gates` über dem Liefer-Stand | erfüllt | Der Stempel deckt `56a86a77`. Dazu der eigene Lauf nach diesem Bericht (§8). |
| Review durchgeführt | erfüllt | zwei Reports; `fabe5188` und `56a86a77` liegen nach beiden Läufen (§7, V-7) |
| Doku-Update `conventions.md`/`migration.md` | erfüllt | §Baseline trägt `v6.9.0`, *vollzogen*, Kurs-Welle 137; `migration.md` §1 und §4 bis §6 sind nachgezogen (§4) |
| untere fünf Zeilen | nicht fällig | Planner, Closure |

**Befunde der Klasse DoD-Verletzung: einer (V-1).** Er betrifft nicht die Arbeit, sondern ihren
Beleg: Das Ergebnis von Liefer-Punkt 2 hängt heute am Kontext des Aufrufers und nicht am Repo.

## 2. DoD 1 im Einzelnen

Die eigenen Messungen am Stand `56a86a77`:

```sh
ls .harness/baseline/                                                   # v6.9.0
grep -nE '^BASELINE_(TAG|ZIP_SHA256)' Makefile                          # v6.9.0 · 8a4e0aaf…ee55cce
grep -n 'lab-regelwerk' -A 1 .d-check.yml                               # …/download/v6.9.0/… · 8a4e0aaf…ee55cce
grep -nE 'Default(Tag|BaselineSHA256) *=' internal/fetch/baseline.go    # "v6.9.0" · "8a4e0aaf…ee55cce"
readlink .claude/rules/*.md | grep -c '\.harness/baseline/'             # 7
readlink .claude/rules/*.md | grep '\.harness/baseline/' | grep -vc 'baseline/v6\.9\.0/'   # 0
for l in .claude/rules/*.md; do test -e "$l" || echo "TOT: $l"; done    # keine Ausgabe
git grep -l 'v6\.8\.0' -- ':!*.md' ':!.harness/baseline'                # keine Ausgabe
```

Die Link- und Inline-Kommandos aus Plan §1 liefern über demselben Pathspec `0` Links und `27`
Inline-Pfade. **Der sha256 steht mit seinen drei Quell-Kommandos in der Message von
`63e0964e`**, ebenso `make regelwerk-check` → `0 Befund(e)`, EXIT 0. Dieser Lauf hat das Netz-Ziel
nicht gefahren und die Messung nicht wiederholt.

**Herkunft des Baums, indirekt gestützt (1.1).** `harness/conventions.md` hält fest, dass die Strecke Asset →
vendored Baum von keinem Sensor bewacht wird (§Adoptierte
Konventions-Quellen). Ein Vergleich mit dem Kurs-Klon am Tag unterscheidet eine Kopie aus dem
Klon von einem Stand aus dem Asset:

```sh
git -C "$K" archive v6.9.0 lab | tar -x -C "$T"
diff -r "$T/lab/templates" .harness/baseline/v6.9.0/templates   # 2 Zeilen: releases/latest/download → releases/download/v6.9.0
diff -r "$T/lab/regelwerk" .harness/baseline/v6.9.0/regelwerk | grep -E '^[<>]' | wc -l   # 54
```

- **In den Vorlagen** unterscheidet sich jeweils eine Zeile: der Asset-Link, den das Release
  auf den Tag stempelt.
- **Im Regelwerk** unterscheiden sich alle 26 Dateien, und jede Differenzzeile schreibt einen
  relativen Kurs-Link in eine URL mit Tag um. Das sind 26 `Quelle:`-Kommentare und in
  `README.md` zwei weitere Links.

Eine Hand-Kopie aus dem Klon trüge die relativen Links. Belegt ist damit die Herkunft aus einer
Release-Verpackung. Ob die Bytes genau dem Asset mit dem gepinnten sha256 entsprechen, ist damit
nicht belegt.

**Inline-Pfade (1.5): Die Zahl geht auf.** Am Ausgangsstand liefert das Inline-Kommando `109`
(`git grep -oE '<Muster>' 1aee7739 -- "${PS[@]}" | wc -l`); der Plan nennt 108, weil er sich
selbst vor der Tabellenzeile in §1 gezählt hat. Die Aufteilung je Datei
(`git grep -cE … 1aee7739 -- …`):

| Gruppe | Treffer | Verbleib |
|---|---|---|
| Implementer (`a12a75ae`) | 11 | 9 nachgezogen, **2 benannt stehen gelassen**: dieser Plan in §1, `slice-der-mutations-lauf-ist-begrenzbar` |
| Architect (`f599169f`, `31ba5903`) | 68 = 13 + 3 + 8 + 44 | nachgezogen bzw. als Buchung gesetzt |
| `spec/spezifikation.md` (`072c330c`) | 5 | entfernt (Setzung: die Spec zeigt nicht nach außen) |
| `docs/migrations/v6.8.0.md` | **25** | stehen geblieben, **in keinem Commit der Kette benannt oder gezählt** |

**V-2.** DoD 1.5 verlangt: *„der Rest steht im Umsetzungs-Lauf benannt und abgezählt daneben"*.
Für die 25 Treffer in `docs/migrations/v6.8.0.md` fehlt das. Inhaltlich ist das Stehenlassen
richtig. Die Treffer sind Tabellen- und Listenzeilen des Berichts zum Sprung auf `v6.8.0`, etwa
Zeile 22 zu `AGENTS.template.md` oder die
Ausnahme-Liste in den Zeilen 64 bis 67. Ihr Gegenstand ist der damalige Baum, sie sind keine
Adressen ([`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)).
Zählkommando:

```sh
I='`[^`]*\.harness/baseline/v6\.8\.0[^`]*`'              # Inline-Muster aus Plan §1
git grep -oE "$I" -- docs/migrations/v6.8.0.md | wc -l   # 25
```

**Adressat: Planner**, als Nachtrag in §7 mit diesem Bericht als Beleg. Vor der Closure
ist keine weitere Handlung nötig.

**V-3 — die Zusage in DoD 1 ist breiter als ihre Sensoren.** Der Satz *„ein halb getauschtes Repo
ist rot"* hält nur für einen Teil der Fälle; Gegenbeispiel C in §5 lief grün. `make gates` färbt
rot, wenn **eine** der fünf Pin-Stellen von den übrigen abweicht (Mutationen A und B) oder wenn
ein Markdown-Link auf einen fehlenden Baum zeigt. Grün bleibt `make gates` dagegen in diesen
Fällen:

- **Alle fünf Pins stehen auf dem alten Tag, der Baum auf dem neuen.** `baseline-verify.sh`
  ermittelt den Tag aus dem Verzeichnis (`harness/tools/baseline-verify.sh:50`) und vergleicht
  ihn nicht mit `BASELINE_TAG`.
- **Ein Symlink zeigt ins Leere.** `baseline-verify` prüft das nicht, wie `MR-056` selbst
  festhält.
- **Ein Inline-Pfad ist veraltet.** Diese Lücke ist im Plan deklariert.

Der erste Fall gehört zur unbewachten Hälfte der Provenienz-Kette, die
`harness/conventions.md` §Adoptierte Konventions-Quellen ausweist (*„Asset → vendored Baum hält
nichts"*). Die Norm verschweigt also nichts, der DoD-Satz sagt aber mehr, als gemessen ist.
Den Zustand selbst belegen die direkten Messungen oben, nicht die Gates. **Adressat: Planner.**
§7 soll den Satz nicht als bestätigt übernehmen und die Grenze benennen.

## 3. DoD 2 und F-10: Was fehlt und wohin es gehört

**Stand im Repo.**

- `0b7bcd2e` trägt den einzigen gesetzten Ausgang: `MR-039` *widerspricht* und wird durch
  `MR-060` übernommen, mit Kopf-Marke. Für den Rest steht dort nur die Zeile *„Alle uebrigen 55
  Eintraege: bleibt gueltig."*
- Die Stichprobe steht an keiner Stelle im Repo. Gesucht wurde mit
  `git grep -n 'Stichprobe' -- harness docs/migrations docs/plan/planning/in-progress`; die
  Treffer außerhalb dieses Plans betreffen andere Gegenstände.
- Plan §7 steht auf *„offen bis zur Closure"*.
- Das Übergabe-Artefakt des Implementations-Laufs, das die DoD nennt, gibt es nicht. Den
  Durchgang hat der Architect selbst gefahren, wie ADR-0056 §Konsequenzen es ihm zuweist.

**Kann die DoD das als erfüllt tragen?** Nein, nicht im heutigen Zustand. Die DoD verlangt
zweierlei:

- *„die abgearbeitete Liste mit je einem Ausgang, das Ergebnis der Stichprobe"* als
  Übergabe-Artefakt;
- *„das Ergebnis steht in §7"*.

Den zweiten Teil schreibt der Planner bei der Closure. Er braucht dafür aber eine Quelle im Repo.
Ein Bericht an den Orchestrator ist kein Übergabe-Artefakt, denn nach Modul 8 gibt es ohne
Artefakt keinen Rollenwechsel. Der Planner müsste sonst ein Urteil des Architects aus dem
Kontext des Aufrufers abschreiben.

Eine Sammelzeile trägt *je einen Ausgang* nur als Behauptung. Dass die Liste abgearbeitet ist,
zeigt sie nicht. Ein mechanischer Kandidaten-Filter macht die Lücke greifbar:

```sh
git grep -lE 'modul-0[256]-' 0b7bcd2e^ -- 'harness/conventions/MR-*.md' | wc -l               # 20
git ls-tree --name-only 0b7bcd2e^ harness/conventions/ | grep -c '/MR-[0-9]*-.*\.md$'        # 56
```

Zwanzig der 56 Einträge nennen eine der drei geänderten Modul-Dateien beim Namen: `MR-004`,
`006`, `007`, `008`, `009`, `010`, `012`, `013`, `024`, `027`, `029`, `035`, `037`, `038`, `040`,
`041`, `047`, `051`, `052` und `053`. Der Filter ersetzt nicht das Lesen des Volltexts, den die
DoD verlangt. Er benennt aber die Einträge, bei denen die Sammelzeile am wenigsten trägt.

**Die Frage an `MR-035`/`MR-056`.** Die Antwort, die der Architect laut Auftrag an den
Orchestrator gegeben hat, lautet: *„Die Baseline kennt `.claude/rules` nicht, der
Auswahl-Maßstab ist nicht berührt."* Nachgemessen gibt
`grep -rl 'claude/rules' .harness/baseline/v6.9.0/ | wc -l` → `0` aus. Das beantwortet die
Freshness-Frage, aber zwei Dinge fehlen:

1. **Der Auflösungs-Trigger beider Einträge nennt den Tag-Bump selbst.** `MR-035` sagt *„Ein
   Tag-Bump zieht die vier Symlinks nach oder entfernt sie; welches von beidem, ist ein neuer
   Eintrag nach Setzung 2"*. `MR-056` sagt dasselbe für sieben Zeiger. Der Trigger hat mit
   `63e0964e` gefeuert, und einen neuen Eintrag gibt es nicht. Nach dem Wortlaut von Setzung 2
   (*„ein Eintrag mehr oder weniger ist ein neuer Eintrag"*) ist das vertretbar, weil die Menge
   gleich geblieben ist (`7` → `7`). Diese Begründung steht aber nirgends. Der Vorgänger-Sprung
   (`8403bbd8`) hat es genauso gehandhabt; eine Präzedenz ist jedoch keine Norm.
2. **Der Betrag, den der Auftraggeber angenommen hat, hat sich bewegt.** `MR-056` Setzung 4
   sagt, der Aufschlag sei *„mit dem Betrag am Stand `v6.7.2`"* genannt und angenommen worden.
   `f599169f` zieht die Zahlen nach: 113031 → 119270 Zeichen und 29,3 % → 27,4 % (Kommandos
   stehen in `MR-056` Setzung 4). Der Auflösungs-Trigger lässt die Beträge mitwandern.
   Ausgesprochen ist aber nicht, dass die Annahme den neuen Betrag deckt oder dass er dem
   Auftraggeber neu genannt wurde.

**Die Stichprobe.** Laut Auftrag hat der Architect `v6.9.0` · `regelwerk/modul-07-carveouts.md`
§Ziel-Form: Carveout gewählt. Das Modul liegt außerhalb des Deltas und damit in der
Komplementärmenge nach `harness/migration.md` §3. Von fünf Regeln hält der Bestand vier. Der
Fund ist, dass `CO-001` im `shell-lint`-Rezept nicht genannt wird.

Der Architect hat `slice-113` als *mögliche* Adresse genannt. **Nachgeprüft trägt die Adresse:**
§1 von `slice-113` führt unter *„Ein zweiter Befund aus demselben Audit, hier mitgenommen"*
genau den fehlenden Verweis *„Verweis ‚CO-001'"* im Kommentar des `shell-lint`-Rezepts
(`git grep -n 'CO-001' -- 'docs/plan/planning/**/slice-113-*.md'`). Der Ausgang lässt
sich also fest setzen: *bekannt, adressiert an `slice-113`*. Offen bleibt, ob die Aussage von
`MR-000` mit diesem Fund hält. Dieses Urteil gehört dem Architect.

**Was fehlt und wohin:**

| # | Was | Wohin | Adressat |
|---|---|---|---|
| a | das Ergebnis des Durchgangs als Datei: Grundgesamtheit 56 mit Kommando; `MR-039` → *widerspricht* → `MR-060`; 55 × *bleibt gültig*, für die zwanzig Kandidaten oben je ein Satz | Architect-Bericht unter `docs/reviews/`, in der Form des Plan-Verdikts `…-architect.md` | **Architect**, vor der Closure |
| b | die Einzelbegründung zu `MR-035`/`MR-056`: Freshness (`0` Treffer), Umgang mit dem gefeuerten Auflösungs-Trigger (Menge unverändert, Setzung 2 greift nicht) und der gewachsene Betrag | derselbe Bericht | **Architect**, vor der Closure |
| c | die Stichprobe: Regel, 4 von 5, Fund, Ausgang *adressiert an `slice-113`*, Urteil über `MR-000` | derselbe Bericht | **Architect**, vor der Closure |
| d | Übertrag von a bis c in Plan §7, Zeile *„Freshness-Durchgang und Stichprobe"*, mit Kennung des Berichts | Plan §7 | **Planner**, Closure |

## 4. DoD 3 im Einzelnen

- **3.1:** Der Bericht führt je Vorlage eine Zeile. Das sind zehn Zeilen in der Tabelle a, fünf
  unter *nicht Gegenstand*, neun unter b und eine ausgenommene, zusammen 25
  (`find .harness/baseline/v6.9.0/templates -name '*.template.md' | wc -l`). Die Zuordnung folgt
  `harness/migration.md` §4 (`3c566c9a`, nach dem Tausch-Commit).
- **3.2:** Gemessen ist das Delta zwischen `63e0964e^` und `63e0964e`, fünf Vorlagen. Die Stat
  von `63e0964e` zeigt genau diese fünf mit Änderungszeilen: README, roadmap, slice, conventions
  und AGENTS; `AGENTS` erscheint in der Stat unter dem gekürzten Pfad. Jede trägt einen Ausgang.
  **Risiko 2 ist damit entfallen**: gemessen wurde am vendorten Baum, und die zwei zusätzlichen
  Vorlagen haben einen Ausgang.
- **3.3:** Die Planungs-README ist *übernommen*. Die Zeilen `next/`, `in-progress/` und `done/`
  stimmen wörtlich mit der Vorlage überein, geprüft mit `grep` in beiden Dateien. Die Roadmap ist
  *übernommen*, die Prosa trägt *„Slice in einem anderen aufgegangen"* (Zeilenumbruch nach
  „einem", `76e84171`). Die Slice-Vorlage steht auf *append-only* mit dem Datum 2026-09-16 und
  dem Hinweis *Form geändert*.
- **3.4:** Der Abschnitt ist als *„Ist-Maßstab, kein Schritt der Prozedur"* ausgewiesen und nennt
  ADR-0056 Trigger 3. `welle-results` und `MR-NNN-titel` stehen unter b und bleiben unverändert;
  `gate` steht unter a, mit fünfzehn Dateien und je einem Ausgang. `observation` ist nach §6
  ausgenommen. Die fünf Instanzen ohne Delta haben die Adresse
  `slice-gliederung-der-instanzen-ohne-vorlagen-delta`, die Datei liegt in `open/`.
- **Doku-Update:** `harness/conventions.md` §Baseline trägt `Stand: v6.9.0`, *Kurs-Welle 137 ·
  2026-09-16* und die Adoptions-Zeile *„auf `v6.9.0`: 2026-09-16, Delta-Nachweis in …"*.
  Außerdem steht dort *„gesetzt und am selben Tag vollzogen"*. §Adoptierte Konventions-Quellen
  trägt die URL mit `tree/v6.9.0` und die Ausgabe von `baseline-verify` mit `v6.9.0`.
  `harness/migration.md` §1 führt den Sprung als *(vollzogen)* mit Zeiger auf den Bericht.

## 5. Bewusstes Brechen (eigene Messungen an Wegwerf-Kopien)

Die Kopien entstanden mit `git archive HEAD | tar -x` im Scratch-Verzeichnis der Sitzung, der
Arbeitsbaum blieb unberührt. Als Mutation dient der Vorzustand selbst: Tag `v6.8.0` und
sha256 `2c55e6d1…dc6c7`, der Wert aus `git show 63e0964e^:Makefile`.

| Kopie | Mutation (der Fix fehlt …) | Sensor | Ergebnis |
|---|---|---|---|
| A | … an den vier gekoppelten Stellen, das Makefile-Paar ist neu | `test/sources-pin.bats` im gepinnten bats-Image | **rot**, beide Fälle: `[ "$yml_sha" = "$mk_sha" ]' failed` (Z. 22) und `grep -q "/$mk_tag/"' failed` (Z. 28); EXIT 1 |
| A | dieselbe | Go-`test`-Stage (Docker) | **rot**, EXIT 1: `fetch.DefaultTag "v6.8.0" != Makefile BASELINE_TAG "v6.9.0" (Drift bei Re-Baseline)` · `fetch.DefaultBaselineSHA256 "2c55…" != Makefile BASELINE_ZIP_SHA256 "8a4e…" (Drift bei Re-Baseline)`. Einzige `FAIL`-Paketzeile: `internal/fetch` |
| B | … allein am kanonischen Makefile-Paar | `test/sources-pin.bats` | **rot**, dieselben zwei Fälle; EXIT 1 |
| B | dieselbe | `make baseline-verify` | **grün**: `v6.9.0 OK — 54 Dateien` (siehe V-3) |
| C | … an allen fünf Stellen, der Baum ist neu | `test/sources-pin.bats`, `make baseline-verify` | **grün**, beide; EXIT 0 (siehe V-3) |
| Kontrolle | keine (`56a86a77`) | `test/sources-pin.bats` | grün, EXIT 0 |

**Was das trägt.** Jeder der drei Wächter wird rot, wenn seine Stelle stehen bleibt. Die Meldung
nennt dabei genau die Stelle und die Ursache, nämlich eine Drift gegen das Makefile-Paar. Das
gilt in beide Richtungen, gesehen an A und B. Die Go-Hälfte von B ist nicht eigens gelaufen: Beide
Tests vergleichen auf Gleichheit mit dem Makefile-Wert (`internal/fetch/fetch_test.go:15`,
`internal/fetch/baseline_test.go:274`), und das ist symmetrisch. Die Zusage aus Plan §3 (*„färben
rot, wenn eine der fünf Stellen stehen bleibt"*) ist damit bestätigt. Die weitere Zusage aus
DoD 1 ist es nicht; siehe V-3.

## 6. Plan-vs-Code-Diff

**Geplant und vorhanden:**

- alle Zeilen der §3-Tabelle;
- der Nachzug je Eigentümer in eigenen, rollen-benannten Commits: Implementer `a12a75ae`,
  Reviewer `1b643a87`, Architect `f599169f`, Planner `76e84171`;
- die Register-Zuordnung als Architect-Commit nach dem Tausch (`3c566c9a`);
- Tausch und Nachzug im selben Push;
- `MR-060` als Ausgang *widerspricht*, gedeckt durch die Zeile *„neu / Kopf-Marke"*.

**Geliefert, nicht (so) geplant:**

- **V-4 — die Instanz-Gruppe `gate` (vierzehn Sensor-Dateien übernommen, mit `## Sperren` und
  `## Ausgabe und Ausgänge`).** Rückführung (b) aus §4 greift, wenn die Umschrift unter
  Buchstabe a *„über die zwei Einzel-Instanzen hinaus"* reicht. Sie legt dann fest: *„entscheidet
  er [der Auftraggeber] zwischen Folge-Slice und Carveout; der Slice wartet."* Die Bedingung ist
  eingetreten. Ausgeführt wurde ein dritter Weg: Die Umschrift wurde im Slice übernommen. Er
  stützt sich auf die Setzung *Pflichtgliederung vollständig*, die `harness/migration.md` §5 a als
  Lesart des Auftraggebers vom 2026-09-16 führt. Dass diese Gruppe **in diesem Slice** umgeschrieben
  wird statt in einem Folge-Slice, steht als Entscheidung nirgends im Repo. **Risiko 3 ist
  eingetreten.** **Adressat: Planner.** In §7 gehören der Ausgang von Risiko 3, die Abweichung
  von Rückführung (b) unter *„Was ging anders als geplant"* und die Quelle der Entscheidung.
- **`harness/conventions.md`: `## Zusatzklassen-Deklaration für Sensors-Bindung` und
  `## Glossar (optional)` (`e26ee898`, `5bf97553`).** Die Vorlage hat ein Delta nur im vendorten
  Baum; der Plan kannte zwei einmalige Vorlagen mit Delta, nicht drei. Das ist durch Risiko 2
  gedeckt: gemessen und mit Ausgang versehen.
- **`harness/migration.md` §5 a** hat neuen Norm-Inhalt bekommen (`3c566c9a`, `58f2156f`,
  `267d380a`, `fabe5188`): das Gliederungs-Kriterium, bedingte Abschnitte und den Ausschluss der
  Vorlagen ohne Delta für diesen Sprung. §3 nennt für die Datei nur *„tag-tragende Pfade und
  Register-Zuordnung"*.
- **`spec/spezifikation.md`** wurde geändert (`072c330c`, `b3dbb770`, `fcb88b9b`): Links nach
  außen entfernt, zwei Herkunfts-Sätze gestrichen, der Satz zum Sammelposten neu gefasst und eine
  Historie-Zeile vom 2026-09-17 ergänzt. Das Kopf-Feld *„Berührte Spec-Stellen: —"* sagt, keine
  Spec-Stelle werde normativ berührt. **Adressat: Planner.** Der Punkt gehört in §7.
- **Folge-Slice `slice-gliederung-der-instanzen-ohne-vorlagen-delta`** (`8ee9b1f2`) nach der
  Setzung des Auftraggebers. Er ist Rückführung (b) mit dem Ausgang Folge-Slice und damit
  plankonform.
- **V-5 — Die Setzung vom 2026-09-17** lautet: *Stoff zieht nur wörtlich und nur innerhalb
  derselben Datei um.* Sie steht allein im Nachprüfungs-Report, also in einem Zeitdokument ohne
  Rang. `harness/migration.md` §5 a führt die Lesart vom 2026-09-16, diese Setzung aber nicht
  (`grep -n 'wörtlich\|2026-09-17' harness/migration.md` findet keine passende Zeile). Die
  Einstufung von F-1 als *behoben* und die Aussage *„wörtlich verteilt"* im Vorlagen-Bericht
  hängen an ihr. **Adressat: Architect.** Die Setzung gehört neben die Lesart in §5 a. Sie
  verschiebt die Abnahme nicht, ist aber vor der Closure empfohlen.

**Geplant, aber fehlt:**

- das Übergabe-Artefakt aus Liefer-Punkt 2 (V-1, §3);
- die Abzählung der 25 Rest-Treffer (V-2).

## 7. ADR-0056: Konformität

| Folgepflicht / Regel | Befund |
|---|---|
| Architect, mit dem Tausch: Register-Zeilen §4 bis §6 gegen `v6.9.0` prüfen | `3c566c9a` nach `63e0964e` und vor dem Instanz-Durchgang (`c5d48b45` ff.) — konform |
| Architect, im Durchgang: Freshness-Review, *„nimmt kein Ergebnis vorweg"* | gefahren (`0b7bcd2e`); das Ergebnis ist nur als Sammelzeile belegt (V-1) |
| Planner, vor dem Vollzug: Baum-Tausch und Instanz-Durchgang | `31ba5903` bucht Stand, Datum und Pins und hält den Vollzugs-Vermerk ausdrücklich zurück. `44f5c034` bucht *vollzogen*, sobald `docs/migrations/v6.9.0.md` vorliegt — Reihenfolge konform |
| Vollzug nach ADR-0031 Festlegung 2 | Zeile *„auf `v6.9.0`: 2026-09-16, Delta-Nachweis in …"* — konform |
| Vorgabe *vollständig*, *bewusst abweichend* entfällt | Kein Ausgang trägt *bewusst abweichend*; `MR-039` tritt zurück — konform |
| Ist-Maßstab-Kennzeichnung (Plan 3.4, ADR-0018 Festlegung 2) | ausgewiesen, Trigger 3 genannt — konform |

**V-6 (INFO).** `44f5c034` prüft als Bedingung, dass die Report-*Datei* existiert, nicht dass der
Durchgang abgeschlossen ist. Nach der Buchung haben `42a2164e`, `3b84a873`, `952aed15` und
`56a86a77` den Instanz-Durchgang noch verändert: `vendor-baseline.md` wechselte von *schon
erfüllt* zu *übernommen*, und zwei Dateien wurden neu verteilt. Die gebuchten Fakten (Tag, Datum,
ADR) berührt das nicht.

**V-7 (INFO).** `fabe5188` (N-2) und `56a86a77` (N-1, N-3) liegen nach beiden Review-Läufen. Als
DoD-relevante Fakten habe ich nachgesehen:

- Die `###`-Überschriften in `slice-mv.md` und `history-range-guard.md` sind jetzt eindeutig
  (*— Vertrag / — Grenze / — Sperren*, `grep -n '^### '`).
- §5 nimmt *„die Absätze … allein für den Sprung"* im Plural aus.
- Der Befund-Satz des Berichts nennt dreizehn plus `vendor-baseline.md`.

Ein Review dieser zwei Commits ist das nicht.

## 8. Offengelegt

**Was dieser Lauf am Baum getan hat:**

- drei Wegwerf-Kopien und ein Archiv des Kurs-Klons im Scratch-Verzeichnis der Sitzung;
- ein Docker-Image `verify-mut-a:test`, das nach dem Lauf entfernt wurde;
- diese Datei;
- nach dem Schreiben `make docs-check` und `make gates`; Commit mit `--only`.

**Nicht gefahren:**

- `make regelwerk-check` (Netz); der Beleg ist die Message von `63e0964e`;
- `make mutate`; `test/mutations/01-baseline-pin-kopplung.sh` hält die sha-Hälfte dauerhaft;
- `make full-smoke`.

**Nicht geprüft:**

- ob die Bytes des Baums dem Asset entsprechen (§2);
- der Inhalt der vierzehn Sensor-Umschriften über die Nachprüfung hinaus.

## 9. Verdikt

**DoD nicht erfüllt, ein Punkt ist offen: Liefer-Punkt 2 ist im Repo nicht belegt (V-1).** Die
Arbeit dahinter ist gemacht; nur ihr Ergebnis steht nicht im Repo.

**Liefer-Punkt 1 ist erfüllt.** Der Bestand ist direkt gemessen, und die drei Pin-Wächter sind
aus dem richtigen Grund rot gesehen. Bei der Closure ist die Abzählung nachzutragen (V-2), und der
DoD-Satz über das halb getauschte Repo darf nicht als bestätigt übernommen werden (V-3).

**Liefer-Punkt 3 ist erfüllt**, samt Ist-Maßstab und Folge-Slice.

**Vor der Closure muss geschehen:**

1. **Architect:** das Ergebnis der Freshness-Review als Datei unter `docs/reviews/` ablegen,
   mit den Posten a bis c aus §3. Dazu gehören die Einzelbegründung zu `MR-035`/`MR-056` (samt
   gefeuertem Auflösungs-Trigger und gewachsenem Betrag), die Stichprobe mit dem Ausgang
   *adressiert an `slice-113`* und das Urteil über `MR-000`.
2. **Architect** (empfohlen, keine Abnahme-Bedingung): die Setzung vom 2026-09-17 in
   `harness/migration.md` §5 a buchen (V-5).

**In der Closure (Planner):**

1. Plan §7 *Freshness-Durchgang und Stichprobe* aus dem Architect-Artefakt schreiben (§3 d).
2. Die 25 Rest-Treffer in `docs/migrations/v6.8.0.md` als benannt stehen gelassen nachtragen
   (V-2).
3. Die Grenze der Zusage *„halb getauscht ist rot"* benennen (V-3).
4. Risiko 3 als *eingetreten* führen und in *„Was ging anders"* die Abweichung von Rückführung (b)
   samt Quelle der Entscheidung festhalten (V-4). Ebenso die Spec-Änderung trotz *„Berührte
   Spec-Stellen: —"*.
5. Risiko 2: *entfallen* (§4). Risiko 1: *entfallen*, je Treffer geurteilt, bis auf die Lücke
   V-2 in der Abzählung.
6. Die Finding-Klassen beider Reviews übernehmen, dazu F-8 als Beobachtung.

**Übergabe:** an den **Planner** und den **Architect**, mit diesem Bericht als Beleg.
