# `make docs-check` — hält die Doku-Referenzen des Repos gegen d-check

## Vertrag

Prüft die gesamte Repo-Doku netzlos (`--network none`) mit dem in
[`d-check.mk`](../../d-check.mk) gepinnten `d-check` gegen
[`.d-check.yml`](../../.d-check.yml). Welche Module aktiv sind, nennt
`grep -n '^modules:' .d-check.yml`; keines davon liest Historie (gemessen am Stand `v0.76.1`:
[`AGENTS.md`](../../AGENTS.md) §3.8). Grün heißt: im Prüfbereich **dieser** Module ist kein
Befund offen, nicht mehr.

## Grenze — was das Grün nicht abdeckt

### Modul `planning`

**Was das Modul `planning` in `docs-check` deckt, und was nicht** (slice-125,
slice-offene-wellen-liste-hat-einen-waechter): `.d-check.yml` bindet `heading`/`marker` auf den
Abschnitt „## Offene Wellen" der Roadmap
([`docs/plan/planning/in-progress/roadmap.md`](../../docs/plan/planning/in-progress/roadmap.md)) und
hält damit die **Marker-Hälfte** — der Ruhe-Marker „Nichts in Arbeit." steht dort genau dann, wenn
[`docs/plan/planning/in-progress/`](../../docs/plan/planning/in-progress) keinen `slice-*.md` trägt;
ein Widerspruch färbt `docs-check` rot (Grund-Code `planning-drift`). Die **Listen-Hälfte** — die
Bijektion zwischen den Zeigern unter „Offene Wellen" und den flachen Welle-Dateien — hält seitdem
die `waves`-Fähigkeit desselben Moduls (`waves.dir: docs/plan/planning`, `waves.mode: many`; ohne
gesetztes `dir` bleibt die Fähigkeit inert und meldet in **beiden** Richtungen `0 Befund(e)`, ohne
etwas zu prüfen). Real gemessen (Docker-Trockenlauf gegen eine Kopie außerhalb des Repos, netzlos,
`-disable links` zur Isolation) deckt `wave-drift` **beide** Richtungen dieser Bijektion: ein
flaches Wellendokument ohne Zeiger *und* ein Zeiger ohne passendes flaches Dokument — Letzteres
unabhängig davon, ob der Link selbst auflöst (ein Zeiger auf eine tatsächlich existierende, aber
bereits geschlossene Datei unter `done/` färbt genauso `wave-drift`). Als Folge derselben
Aktivierung hält dieselbe Bijektion auch für „## Abgeschlossene Wellen" gegen die Ergebnisnotizen
im Ruheort `docs/plan/planning/done/` (`wave-unregistered`: Ergebnisnotiz ohne Registerzeile;
`wave-results-missing`: Registerzeile ohne Ergebnisnotiz). **Die reale Grenze liegt an der Spalte,
nicht am Abschnitt:** `waves` liest zusätzlich die **erste Spalte** der Vorschau-Tabelle „## Nächste
Wellen" — nennt sie eine Kennung, zu der bereits eine flache Datei existiert, meldet es
`wave-preview-exists` (vierter Grund-Code neben `wave-drift`/`wave-unregistered`/
`wave-results-missing`), **unabhängig davon, ob der Name dort verlinkt ist**. Fünf Lagen, real
gemessen (Docker-Trockenlauf gegen eine Kopie außerhalb des Repos, netzlos, `-disable links` zur
Isolation, derselbe Digest wie oben):

| Lage | Ergebnis |
|---|---|
| flache Datei + nur in Spalte 1 der Vorschau (kein Zeiger unter „Offene Wellen") | 2 Befunde (`wave-drift` + `wave-preview-exists`) |
| flache Datei + Zeiger unter „Offene Wellen" **und** verlinkt in Spalte 1 der Vorschau | 1 Befund (`wave-preview-exists`) |
| flache Datei + Zeiger unter „Offene Wellen" + **unverlinkter** Name in Spalte 1 | 1 Befund (`wave-preview-exists`) |
| flache Datei + Zeiger unter „Offene Wellen" + Nennung nur in Spalte 3 („Wichtigste Slices") | 0 Befunde |
| toter Vorschau-Zeiger `welle-88` ohne jede Datei | 0 Befunde |

Nur die letzten beiden Lagen bleiben `waves` unsichtbar: Eine Nennung in Spalte 3 liest keine
Fähigkeit des Moduls, und ein toter **Vorschau**-Zeiger ohne Datei fällt ausschließlich über das
Modul `links` (`target-missing`) — ein toter Zeiger unter „Offene Wellen" ohne Datei liegt bereits
in der oben beschriebenen Bijektion und fällt über `wave-drift`. Eine geschnittene Welle-Datei, die
nur in der Vorschau-Tabelle verlinkt steht und (noch) nicht unter „Offene Wellen", ist **kein**
blinder Fleck: Sie ist Lage 1 der Tabelle oben und meldet zwei Befunde. Das ist eine verbotene
Abweichung: [ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) legt
fest, dass die flache Datei mit der Eröffnung der Welle entsteht, nicht davor, und `waves` hält die
Kopplung *Datei ⟺ Zeiger* davon mit `wave-drift`/`wave-preview-exists` durch — dass die Kennung in
der Vorschau bis zur Eröffnung unverlinkt bleibt, deckt dagegen kein Modul dieses Gates, solange ein
gesetzter Link auflöst
([ADR-0046](../../docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md) §Fitness
Function). Die zweite
Fähigkeit desselben Moduls (`closure`, Struktur der Closure-Notizen) ist seit slice-129 aktiviert —
was sie deckt und was nicht, steht im eigenen Absatz unten. Eine **vierte** Fähigkeit desselben
Moduls (`observations`, Deckung zwischen zitierten Beobachtungs-Kennungen und ihrem Nachweis im
Register — additiv eine fünfte für den Verzeichnis-Modus dieser Ablage) ist ebenfalls verfügbar und
nicht aktiviert; anders als `closure` und `waves` trägt sie noch keinen eigenen Slice —
[`BEO-ALL/register-paarung-ohne-gate-modul`](../../docs/plan/planning/observations/BEO-ALL/register-paarung-ohne-gate-modul/observation.md)
führt die Lücke als offene Beobachtung, mit einer Drift-Log-Zeile in
[`roadmap.md`](../../docs/plan/planning/in-progress/roadmap.md) daneben.

**Was `closure` (zweite Fähigkeit von `planning`) deckt, und was nicht** (slice-129):
[`.d-check.yml`](../../.d-check.yml) setzt `planning.closure.dir: docs/plan/planning/done` und hält
damit Abschnitt 7 (Closure-Notiz) jedes Kandidaten gegen die Fähigkeit des Moduls: kein Abschnitt,
der auf das Default-Muster `^#{2,3} .*Closure-Notiz` passt (`closure-note-missing`), mehrere
passende Überschriften ohne eindeutigen Abschnitt (`closure-note-ambiguous`, immer aktiv), weniger
als vier Satzenden außerhalb von Code (`closure-note-thin`, mit Datei und Zeile in der Meldung),
ein unausgefüllter `<feld>`-Platzhalter (`closure-note-placeholder`, Bedingung `placeholder: true`)
und eine deklarierte Floskel (`closure-note-boilerplate`, Bedingung `boilerplate: […]`). **Rot
gesehen, gegen eine Kopie außerhalb des Repos, netzlos, Mount `:ro`, derselbe Digest wie
`docs-check`:**

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git archive HEAD | tar -x -C <kopie>
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" \
  --enable planning --config /repo/.d-check.yml
# unveraendert:                 … 0 Befund(e)
# Abschnitt 7 einer done/-Datei auf einen Satz gekuerzt:
#   …/slice-001a-cli-skeleton.md:79  closure-note-thin  Closure-Notiz traegt 1 Satzende-Zeichen
#   ausserhalb von Code-Bloecken, verlangt sind 4
```

**Der Kandidaten-Filter bleibt der Modul-Default `slice-glob`** — `.d-check.yml` setzt kein eigenes
`glob:` — und trifft damit nur `slice-*.md`
(`ls docs/plan/planning/done/slice-*.md | wc -l`, kein Erwartungswert, wandert mit dem Bestand). Die
Welle-Ebene (`ls docs/plan/planning/done/welle-*.md | wc -l`) bleibt **absichtlich** außen vor: Die
Welle-Closure dieses Repos liegt auf zwei Dateien verteilt — dem flachen Welle-Plan und seiner
Ergebnisnotiz `done/welle-NN-results.md` —, das ist die Form, die
`modul-06-roadmap.md` §Wellen-Closure-Prozedur Schritt 3 selbst vorschreibt (*„Und die
Welle-Plan-Datei wandert per `git mv` von flach nach `done/`"*, dort neben der eigenen
Closure-Notiz). Der flache Welle-Plan trägt in seinem §7 nur den *Zeiger* auf die Ergebnisnotiz
(zwei Sätze, unter der Schwelle); die Ergebnisnotiz selbst führt ihre Closure-Aussage bei **8** der
**12** Wellen als **H1** (statt der vom Modul erwarteten H2/H3) — `grep -lE '^# .*[Cc]losure'
docs/plan/planning/done/welle-*-results.md | wc -l` → **8**. Die übrigen vier
(`welle-06`, `welle-07`, `welle-08`, `welle-12`) tragen als H1 *„… — Results-Notiz"* und führen das
Wort *Closure* in **keiner** Überschriften-Ebene (`grep -cE '^#{1,6} .*[Cc]losure'` → 0 je Datei) —
sie weichen damit auch von der vendored Ziel-Form ab
(`.harness/baseline/v6.9.0/templates/docs/plan/planning/welle-results.template.md:1`) und bleiben
eine benannte, nicht nachgezogene Abweichung, kein zweiter Grund für den engen Filter. Gegen eine
Kopie außerhalb des Repos, netzlos, mit `closure.glob: '*.md'`
probeweise geweitet
(`docker run --rm --network none -v <kopie>:/repo:ro ghcr.io/pt9912/d-check@<digest> --config /repo/.d-check.yml --enable planning`,
`<digest>` aus `d-check.mk`): **20** Befunde — **12** `closure-note-missing` (jede
`welle-NN-results.md`) und **8** `closure-note-thin` (acht der zwölf Welle-Pläne, ihr
§7-Zeiger). Kein Erwartungswert, beide Zahlen wandern mit dem Welle-Bestand — tragend ist die
**Zusammensetzung**: Beide Klassen entstehen überwiegend aus derselben Zwei-Datei-Form, nicht aus
fehlender Substanz; die vier H1-Abweichungen oben sind darin enthalten, aber keine eigene Ursache.
Der Filter bleibt eng, statt den Gate über eine Form rot zu färben, die diese Welle-Closure
absichtlich wählt.

`placeholder` bleibt aus derselben Zurückhaltung aus: eingeschaltet meldet der Basis-Lauf **einen**
`closure-note-placeholder`
(`docs/plan/planning/done/slice-087-emittierte-doku-tische-init-invariant.md:353`) — eine
Vorlagen-Syntax in escapten Backticks, deren ungerade Backtick-Zahl die Inline-Code-Paarung
verschiebt (eine Vorverarbeitungs-Grenze, die das Werkzeug selbst führt), kein unausgefüllter
Rumpf. Die Bedingung anzuschalten hieße, ein Zeitdokument zu ändern oder eine Ausnahme für eine
Datei zu setzen, die nichts falsch macht — beides schlechter als sie auszulassen.

**Der Lauf hängt am geteilten Durchsetzungspunkt `make gates`**, nicht an einem eigenen Profil. Das
Benutzerhandbuch des Werkzeugs legt für diese Fähigkeit ein eigenes `--config`-Profil nahe, damit
nicht jeder gewöhnliche Doc-Lauf die Closure-Notizen mitprüft. Dieses Repo hat **einen**
Durchsetzungspunkt (`docs-check` in `make gates`), und `closure` läuft im selben `planning`-Block
wie die Marker-Hälfte oben — ein zweites Profil wäre ein zweiter Ort, an dem dieselbe Modul-Config
driften kann, dieselbe Klasse, die [`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert)
für das Gate-Fragment schon einmal ausbuchstabiert hat. **Was das nicht leistet:** Jeder
`docs-check`-Lauf öffnet jetzt auch jede `slice-*.md`, die **flach** unter `done/` liegt, und prüft
ihre §7-Struktur — auch dann, wenn die Änderung, die den Lauf auslöst, mit `done/` nichts zu tun
hat; ein dediziertes Advisory-Target, das nur die Closure-Prüfung fährt, ohne die übrigen
aktiven Module, gibt es nicht.

**Der Prüfbereich greift nicht rekursiv, und das ist heute folgenlos, morgen nicht mehr.**
`closure.dir` öffnet nur die Kandidaten **im genannten Verzeichnis selbst**; eine identische, dünne
Notiz in einem Unterverzeichnis erzeugt **keinen** Fund — gemessen an einem Sonden-Paar (dieselbe
`§7`-gekürzte Datei einmal flach unter `done/`, einmal unter einem synthetischen
`done/welle-99/`): flach `closure-note-thin`, tief **0** Treffer, in derselben Kopie außerhalb des
Repos. `done/` trägt heute keine Unterverzeichnisse (`find docs/plan/planning/done -mindepth 1
-maxdepth 1 -type d | wc -l` → 0), die Zusage ist also **heute** vollständig — die vom
Regelwerk (`.harness/baseline/v6.9.0/regelwerk/modul-06-roadmap.md` §Wellen-Closure-Prozedur
Schritt 4) **vor der ersten Archivierung** verlangte Geltungsbereichs-Prüfung gilt für diesen
Sensor als hiermit durchgeführt
und mit **benannter Grenze** beantwortet, statt stillschweigend zu bestehen: sobald ein
`make archive-welle`-Lauf (Werkzeug in Bau, [ADR-0033](../../docs/plan/adr/0033-wellen-archivierung-als-unterkommando.md))
Slice-Stubs in ein `done/<welle-id>/`-Unterverzeichnis bewegt, deckt dieser Sensor sie nicht mehr —
und die Stubs tragen nach der Ziel-Form ohnehin kein volles §7 mehr, sind also für `closure` kein
sinnvoller Kandidat. Wer `archive-welle` produktiv nimmt, zieht den Geltungsbereich hier nach
oder benennt an dieser Stelle, dass die Zusage ab dann nur für den flachen Bestand gilt.

### Ein stillgelegter Slice in `done/`

**Was gemessen ist.** Die Ziel-Fassung (`v6.9.0` ·
`.harness/baseline/v6.9.0/regelwerk/modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand
ein anderer übernimmt) legt einen Slice, dessen Gegenstand ein anderer übernimmt oder der
entfällt, ohne Lieferung nach `done/`: Die Liefer-Punkte der DoD bleiben leer, §7 trägt die Zeile
`Gegenstand:`, und jedes Risiko hat einen Ausgang. Gemessen gegen d-check `v0.76.1`
`@sha256:1470ecdcaa686a5ef4513dee9b0ae522586f54b87d568b06fc6b5b2741b633b3`, an einer Kopie außerhalb
des Repos, netzlos, über allen Modulen der `.d-check.yml`: je ein Slice über die Kante
`open → done` (Gegenstand *übernommen von*) und über `next → done` (Gegenstand *entfallen*),
der Stilllegungs-Inhalt vor dem Wechsel committet. Gelesen ist jede Meldung, die den stillgelegten
Slice betrifft:

```sh
git archive HEAD | tar -x -C <kopie>    # Inhalt committen, dann make slice-mv … TO=done
make -C <kopie> docs-check              # je Lage die Datei in der Kopie ändern und neu fahren
```

| Lage im stillgelegten Slice | Meldung zu diesem Slice |
|---|---|
| Ziel-Form vollständig | keine |
| §7 auf einen Satz gekürzt | `closure-note-thin` auf seiner §7-Überschrift |
| die Zeile `Gegenstand:` fehlt | `section-open-tasks-marker-missing` auf der §2-Überschrift (§Modul `structure`) |
| `Gegenstand:` nennt eine Kennung, die es nicht gibt | keine |
| ein Liefer-Punkt abgehakt | keine |
| ein Risiko aus §6 ohne Ausgang | keine |
| `Gegenstand:` als unausgefüllter Vorlagen-Platzhalter | keine: `placeholder` ist aus (§Modul `planning`), und `structure` nimmt die Zeile als Marke (§Modul `structure`) |
| derselbe Platzhalter, `placeholder: true` in der Kopie | `closure-note-placeholder` auf der Zeile (`<Grund>`) |

Die zwei Zeilen zur Zeile `Gegenstand:` ohne `placeholder: true` gelten für die Modul-Liste mit
`structure` und sind dort gemessen (§Modul `structure`, Lagen V1 und V3). Die übrigen Zeilen gelten
für die Modul-Liste ohne `structure` und sind mit ihm nicht neu gemessen.

Die Kopie trägt eine lokale git-Identität, wie in [`slice-mv.md`](slice-mv.md) §Kanten. Für die
Lage *ein Risiko aus §6 ohne Ausgang* ist in der Kopie die §7-Zeile `- **Risiken aus §6:**` des
stillgelegten Slice auf `Risiko 1 eingetreten` gekürzt; Risiko 2 bis 5 stehen danach ohne Ausgang.
Danach läuft `make -C <kopie> docs-check`. Ein stillgelegter Slice, dessen §7 die Zeile gar nicht
trägt, meldet `section-open-tasks-marker-missing` (§Modul `structure`, Lage V1).

Aus den Geschwister-Dateien bleibt nach dem Wechsel kein Befund stehen, soweit ihre präfixlosen
Verweise auf den stillgelegten Slice die Form tragen, die `make slice-mv` erkennt: den Markdown-Link
in einer Datei, die flach im Ausgangsverzeichnis liegt (Skriptkopf `harness/tools/slice-mv.sh`,
Grenze 3; [`slice-mv.md`](slice-mv.md) §Grenze, an beiden Kanten gemessen unter §Kanten). Eine
andere Schreibweise desselben Verweises bleibt stehen und färbt den Lauf mit `target-missing` rot;
unter open/, next/ und in-progress/ zählt sie

```sh
git grep -hE '\]\(\./slice-|\]\(<slice-|^\[[^]]*\]: *slice-' -- docs/plan/planning/open docs/plan/planning/next docs/plan/planning/in-progress | wc -l   # 0
```

— kein Erwartungswert. `planning-drift` meldet keine der zwei Kanten, weil beide
`in-progress/` nicht berühren.

**Was daraus folgt.** `closure` liest den stillgelegten Slice wie jeden anderen in `done/`; das
Gegenbeispiel in Zeile 2 färbt rot. Die Ziel-Fassung nennt es urteilsfrei, dass die Zeile
`Gegenstand:` eine Kennung oder einen Grund trägt. Davon hält `structure` die **Anwesenheit** der
Zeile: Trägt §2 offene Punkte und §7 keine Zeile in Marken-Form, färbt der Slice den Lauf rot
(§Modul `structure`). **Was** die Zeile trägt, hält kein aktives Modul; der unausgefüllte
Platzhalter bleibt grün (Tabelle). Ebenso urteilsfrei nennt die Ziel-Fassung, dass jedes Risiko
aus §6 einen Ausgang trägt, und auch das prüft kein aktives Modul (Tabelle, Lage *ein Risiko aus §6
ohne Ausgang*). Diese Lücke betrifft jede Closure, nicht nur die Stilllegung; ihre Adresse ist der
Folge-Slice `slice-risiko-ausgang-hat-einen-sensor`. Zwei Punkte sind dagegen Grenzen und keine
Lücken: Ob die genannte Kennung auflöst, lässt die Ziel-Fassung selbst als Urteil oder eigenen
Sensor offen, und dieses Repo wählt das Urteil — Setzung des Planners vom 2026-09-17 in
[`.claude/commands/plan-welle.md`](../../.claude/commands/plan-welle.md) §Einen Slice stilllegen.
Ob ein abgehakter Punkt ein Liefer-Punkt ist, bleibt Urteil.

**Kein Wächter hält die Tabelle.** Sie ist eine Messung gegen den genannten Digest; wandert der Pin
in `d-check.mk`, gilt sie für den alten Stand, bis jemand neu misst.

### Modul `structure`

**Was es hält.** [`.d-check.yml`](../../.d-check.yml) führt `structure` in `modules:` und einen
`structure`-Block mit einer Regel: Über jedem Slice-Plan flach in `done/` zählt sie die offenen
Task-Items im Abschnitt `## 2. Definition of Done` (`max-open-tasks: 0`). Trägt er welche, verlangt
`open-tasks-require-marker` im Abschnitt `## 7. Closure-Notiz` (mit oder ohne Zusatz) eine Zeile
in Marken-Form `**Gegenstand:**`. Fehlt sie, meldet die Regel **einen**
`section-open-tasks-marker-missing` auf der §2-Überschrift; die vierte Spalte trägt den `hint` der
Regel. Offene Items außerhalb von §2 zählen nicht, und eine Marke außerhalb von §7 zählt nicht.
Ein regulär gelieferter Slice trägt in `done/` keine offenen Items
(`.harness/baseline/v6.9.0/regelwerk/modul-05-planning-harness.md` §Lifecycle als State Machine:
die DoD-Häkchen sind Bedingung für `done/`; §Ein Slice, dessen Gegenstand ein anderer übernimmt:
die einzige Ausnahme sind die Liefer-Punkte eines stillgelegten Slice). **Das gilt auch für die
letzte DoD-Zeile der Vorlage**, *„Die drei Paarungen … sind getragen"*: Dieselbe Stelle zählt die
Paarungen zu den Closure-Pflichten, die *„wie bei jeder Closure"* abgehakt werden. Im Repo mit
Wellen-Betrieb sagt das Häkchen, dass die nächste Welle-Closure die Paarungen prüft. Sie liest
auch Slices ohne Wellen-Zugehörigkeit (`v6.9.0` · `modul-06-roadmap.md` §Wann Arbeit eine Welle
braucht). Das Häkchen sagt nicht, dass die Paarungen schon geprüft sind. Die Zeile *„**nach** dem
`git mv`"* in `modul-06` steht in der Tabelle für das Repo **ohne** Wellen. Sie regelt, wann
abgehakt wird, nicht ob. Trägt ein gelieferter Slice doch ein offenes Item, färbt er dieselbe
Regel rot, und der `hint` nennt beide Auswege.

**Der Prüfbereich und seine Grenze.** Gemessen gegen d-check `v0.76.1`
`@sha256:1470ecdcaa686a5ef4513dee9b0ae522586f54b87d568b06fc6b5b2741b633b3`. Alle Zahlen wandern mit
dem Bestand und sind **keine Erwartungswerte**:

```sh
ls docs/plan/planning/done/slice-*.md | wc -l                             # 177 Kandidaten
grep -lE '^\s*[-*] \[ \]' docs/plan/planning/done/*.md | wc -l            #  31 mit offenen Items
for f in $(grep -lE '^\s*[-*] \[ \]' docs/plan/planning/done/*.md); do
  awk '/^```/{c=!c} !c&&/^## /{h=$0} !c&&/^[[:space:]]*[-*] \[ \]/{print h}' "$f"
done | sort -u                                                           # nur "## 2. Definition of Done"
sed -n '/^structure:/,/^# targets/p' .d-check.yml | grep -c '^      - "docs/plan/planning/done/'   # 30 ausgenommen
```

Von den 31 Plänen mit offenen Items tragen 30 keine Marke in §7. Sie stehen namentlich in
`exempt-paths`, sind Zeitdokumente und bleiben unverändert. Der 31. ist der stillgelegte
[`slice-135`](../../docs/plan/planning/done/slice-135-d-check-pin-v0661.md). Er trägt
`- **Gegenstand:** entfallen: …` in §7, liegt im Prüfbereich und bleibt ohne Befund. Ohne
Ausnahmeliste meldet derselbe Lauf 30 Befunde, und ihre Dateien sind genau die 30 der Liste. Ein
Glob über die Kennungs-Form nähme mehr aus: Nummerierte Slices liegen auch dort, woher künftige
Stilllegungen kommen:

```sh
ls docs/plan/planning/open/slice-[0-9]*.md docs/plan/planning/next/slice-[0-9]*.md | wc -l   # 65
```

**Rot gesehen, gegen eine Kopie des Arbeitsbaums außerhalb des Repos, netzlos, derselbe Digest.**
Der stillgelegte Slice ist ein Slice-Plan aus `in-progress/` mit leeren DoD-Punkten, dessen §7
keine Zeile in Marken-Form trägt. Er liegt als `done/slice-sonde-stilllegung.md` in der Kopie und
steht nicht in `exempt-paths`. Der reguläre Slice ist ein Plan aus `done/`, dessen DoD-Punkte alle
abgehakt sind. Je Lage beginnt eine frische Kopie:

```sh
git archive HEAD | tar -x -C <kopie>      # dazu die geänderten Dateien des Arbeitsbaums
cp <plan> <kopie>/docs/plan/planning/done/slice-sonde-stilllegung.md
make -C <kopie> docs-check                # je Lage die Datei oder .d-check.yml in der Kopie ändern
```

| Lage | Meldung |
|---|---|
| V0 Bestand unverändert | keine, `1601 Datei(en) geprüft, 0 Befund(e)` |
| V1 stillgelegt, §7 ohne `Gegenstand:` | `section-open-tasks-marker-missing` auf der §2-Überschrift |
| V2 stillgelegt, `- **Gegenstand:** entfallen: …` in §7 | keine |
| V3 stillgelegt, die Platzhalter-Zeile der Vorlage in §7 | keine |
| V4 stillgelegt, `Gegenstand:` in §2 statt §7 | `section-open-tasks-marker-missing` |
| V5 wie V2, ein Liefer-Punkt abgehakt | keine |
| V6 alle DoD-Punkte abgehakt, ohne `Gegenstand:` | keine |
| V7 regulär, ein offenes Item in §6 | keine |
| V8 regulär, ein offenes Item in §2 | `section-open-tasks-marker-missing` |
| V9 wie V1, `structure` aus `modules:` genommen | keine |
| V10 regulär, §2-Überschrift als `## 2. Definition of Done (Sonde)` | `section-missing` auf Zeile 1; die vierte Spalte trägt den `hint` |
| M1 `open-tasks-require-marker` und `-section` entfernt | 5 × `section-tasks-open` in `slice-135` |
| M2 nur `open-tasks-require-marker-section` entfernt | `section-open-tasks-marker-missing` in `slice-135` |
| M3 `structure`-Block und Aktivierung entfernt | `docs-check` ohne Befund; `test/doc-block-marke-wiring.bats` Fall 1 rot |

Die Meldung in V1 lautet, Spalten durch Tabulatoren getrennt:

```text
docs/plan/planning/done/slice-sonde-stilllegung.md:89	docs/plan/planning/done/slice-*.md :: ^## 2\. Definition of Done$	section-open-tasks-marker-missing	offene DoD-Punkte in done/ — geliefert: abhaken; stillgelegt: §7 trägt **Gegenstand:** mit Kennung oder Grund
```

**Grenzen.**

- **Die Marke ist eine Form, kein Inhalt.** Eine Zeile in Marken-Form in §7 genügt, auch der
  unausgefüllte Platzhalter der Vorlage (V3). Dasselbe gilt für eine `**Gegenstand:**`-Zeile, die
  in §7 etwas anderes meint; am Zeilenanfang tragen sie
  `grep -lE '^(- )?\*\*Gegenstand:\*\*' docs/plan/planning/done/slice-*.md | wc -l` → 9 Pläne.
  Keiner davon trägt offene Items außer `slice-135`.
- **Eine einzelne DoD-Zeile lässt sich nicht ausnehmen.** `tasks-ignore-pattern` wirkt nur auf
  `max-tasks`. Mit `max-tasks: 1000` und `tasks-ignore-pattern: '^Die drei Paarungen'` meldet die
  Regel ohne Ausnahmeliste weiter 30 Befunde, gemessen mit `--enable structure` allein. Die Zeile
  *„Die drei Paarungen … sind getragen"* steht in
  `grep -lE '^\s*- \[ \] Die drei Paarungen' docs/plan/planning/done/slice-*.md | wc -l` → 7 Plänen
  offen. Alle sieben stehen in `exempt-paths`. Ein künftiger regulärer Slice, der sie offen lässt,
  ist Lage V8. Das Rot folgt der Quelle (*Was es hält*): Die Baseline sieht für diese Zeile keine
  Ausnahme vor, das Werkzeug muss also keine bieten.
- **Der Glob ist flach.** Ein Stub unter `done/<welle-id>/` liegt außerhalb. Trifft die Regel keine
  Datei mehr, meldet sie `section-missing`.
- **Der `hint` passt nicht zu jedem Grund-Code der Regel.** Trägt ein Plan die §2-Überschrift in
  anderer Form, meldet die Regel `section-missing`, und die vierte Spalte ist der `hint` (Lage V10).
  Keiner seiner zwei Auswege behebt diesen Befund; die Ursache ist die Überschrift. Heute weicht
  kein Plan ab: `grep -L '^## 2\. Definition of Done$' docs/plan/planning/done/slice-*.md | wc -l`
  → 0, kein Erwartungswert.
- **Die Aktivierung hält kein Gate außerhalb von `docs-check`.** `make mutate` lässt einen Fall nur
  für eine Stufe zu, für die `failure_form()` ein Fehlschlag-Muster führt
  (`sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh`); für `make docs-check` führt es
  keines. M1 und M2 sind darum einmalige Belege und kein Fall unter `test/mutations/`.
  M3 fällt in `make test`, weil `doc-structure` dann wieder in die Menge fällt, die
  [`test/doc-block-marke-wiring.bats`](../../test/doc-block-marke-wiring.bats) aus beiden Dateien
  ableitet. Für V9 schlägt kein Wächter an.

**Das emittierte Gate bekommt die Regel nicht.** Die drei Kriterien aus
[`MR-054`](../conventions.md#mr-054) sind gemessen an einem Ziel, das
`ai-harness-init --lang go --name probe` in einem leeren git-Repo außerhalb dieses Repos erzeugt,
mit dem Träger aus `make host-bin`:

1. **Der Dogfood fährt das Modul:** erfüllt, `grep -m1 '^modules:' .d-check.yml` nennt `structure`.
2. **Grün über dem frisch emittierten Bestand:** nicht erfüllt. `done/` trägt in diesem Ziel nur
   `.gitkeep`. Mit `structure` in `modules:` und der Regel ohne `exempt-paths` meldet der Lauf über
   der `.d-check.yml` des Ziels `section-missing` mit dem Grund *„Regel trifft keine Datei (auch
   nach Abzug von exempt-paths) — das Gate liefe leer"*.
3. **Rot im Ziel:** nicht erfüllt. `harness/tools/full-smoke.sh` trägt keinen Zahn dafür, und
   [`MR-055`](../conventions.md#mr-055) Setzung 3 wertet diese Lage als nicht erfüllt. Von Hand ist
   das Rot gesehen: Eine Kopie der Vorlage `slice.template.md` in
   `done/` bleibt grün, denn die Vorlage trägt in §7 die Zeile
   `- **Gegenstand:** <übernommen von … | entfallen: <Grund>>`. Ohne diese Zeile meldet der Lauf
   `section-open-tasks-marker-missing`. Den fehlenden Zahn zeigt
   `grep -ciE 'structure|open-tasks' harness/tools/full-smoke.sh` → 0.

Kriterium 2 trägt die Entscheidung; Kriterium 3 ist unabhängig davon nicht erfüllt. Die
emittierte Vorlage `internal/emit/templates/d-check.yml` bleibt ohne `structure`
(`grep -c 'structure' internal/emit/templates/d-check.yml` → 0). Nach
[`MR-055`](../conventions.md#mr-055) gilt die Messung für dieses eine Ziel. Neu zu messen ist
Kriterium 2, sobald ein frisch emittiertes Ziel eine Datei trägt, die die Regel trifft.

### Modul `targets`

**Was das Modul `targets` in `docs-check` deckt, und was nicht:** `.d-check.yml` hält zwei
Richtungen zwischen den Makefile-Rezepten (`makefiles: [Makefile, d-check.mk]`) und den
Gate-Tabellen der Doku. **Vollständigkeit** (`gate-undocumented`) prüft gegen genau **eine**
`authority`-Datei — `harness/README.md` als **Ganzes**, nicht nur ihren §Sensors-Abschnitt: das
Schema des Moduls kennt kein Heading-Scoping (`d-check --print-config` zeigt im `targets`-Block
keinen Abschnitts-Schlüssel) und keine Liste (eine zweite Datei in `authority` bricht mit einem
Typfehler); `AGENTS.md` §4 trägt dazu Regel und Zeiger, keine eigene Tabelle
(``grep -cE '^\| `make ' ../../AGENTS.md`` → **0**). Eine `make X`-Tabellenzeile in der
„Werkzeuge (kein Gate)"-Tabelle deckt die Vollständigkeits-Richtung damit ebenso wie eine
Sensors-Tabellenzeile — den engeren §Sensors-Scope hält allein der repo-lokale Wächter
`test/targets-modul-wiring.bats`, nicht dieses Modul; die daraus folgende Senkung und ihre
Kompensation stehen in
[`ADR-0045`](../../docs/plan/adr/0045-authority-wechsel-senkt-eine-richtung.md) Festlegung 1/2.
**Phantom** (`gate-phantom`) prüft
beide `doc-tables`-Dateien (`AGENTS.md`, `harness/README.md`) in die Gegenrichtung: eine
`make X`-**Tabellenzeile** ohne passendes Rezept färbt rot. Beide Richtungen greifen nur an
**Tabellenzeilen** — eine Erwähnung in Fließtext, Aufzählung oder Code-Block bleibt für das
Modul unsichtbar. Ein halluziniertes Ziel in Prosa bleibt damit außerhalb dieses
Prüfbereichs — dieselbe Lücke, die
[`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) offen lässt.

Jedes Rezept aus `makefiles`, das keine `make X`-Zeile in der `authority`-Datei trägt, steht
entweder dort **oder** kuratiert (exakte Namen, kein Glob) in `exempt-targets` — heute **37**
(`sed -n '/^targets:/,/^ignore-refs:/p' ../../.d-check.yml | grep -c '^    - '`), in zwei
Gruppen: Nicht-Gate-Verifies (jeweils mit eigenem Sensor-Eintrag in der Tabelle „Werkzeuge
(kein Gate)" von [`harness/README.md`](../README.md#sensors-feedback-gates)) und reine
Utility-/Advisory-Ziele ohne Prosa-Erwähnung, deren einzige Dokumentation ihr eigener `## `-
Hilfetext ist (`help`, `test-bats`, `test-go`, `artifact`, `release-artifacts`, `compile`,
`freshness-golangci`, `freshness-dcheck`, `freshness-go`, `freshness-cpp`, `doc-trace`,
`doc-complete`, `doc-doctor`, `doc-repair`, `doc-planning`, `doc-targets`, `doc-usage`,
`doc-help`, `doc-immutable`, `doc-commits`). Kein Gate-Versprechen ist der gemeinsame Grund
für beide Gruppen — die `exempt-targets`-Zeile sagt nur, dass keins dieser Rezepte eine
`make X`-Tabellenzeile in der `authority`-Datei braucht.

### Modul `codepaths`

**Was `codepaths` an toten Pfaden in den vendored Baum nicht sieht**
([slice-201](../../docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md)):
`codepaths.roots: [spec, docs, harness]` ist eine Liste von Wurzel-**Präfixen** — ein
Inline-Code-Pfad wird nur existenzgeprüft, wenn er mit einem dieser drei Strings oder mit
`./`/`../` beginnt. Ein Pfad unter `.harness/baseline/` beginnt mit `.harness`, nicht mit
`harness`, und liegt damit außerhalb dieser Liste: ein erfundener Dateiname dort bleibt stumm,
derselbe erfundene Dateiname unter `harness/` färbt `codepath-missing` — gemessen an einem
hermetischen Sonden-Paar über dem in [`d-check.mk`](../../d-check.mk) gepinnten Digest. Ein toter
Inline-Baseline-Pfad in einem **lebenden** Artefakt (etwa
[`harness/conventions.md`](../conventions.md)) bleibt darum dauerhaft gate-unsichtbar.

**Die naheliegende Reparatur — `.harness` als vierten Präfix aufnehmen — ist gemessen und
verworfen, nicht übersehen:**

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)   # v0.74.1 zum Zeitpunkt dieser Messung
git clone --local --no-hardlinks . /tmp/probe-fresh    # keine .harness/state/, wie ein frischer Klon
sed -i 's/roots: \[spec, docs, harness\]/roots: [spec, docs, harness, .harness]/' /tmp/probe-fresh/.d-check.yml
docker run --rm --network none -v /tmp/probe-fresh:/repo:ro "ghcr.io/pt9912/d-check@${DIGEST}" \
  | tee /tmp/lauf.txt | grep -c codepath-missing   # 128 -- kein Erwartungswert, wandert mit dem Bestand;
                                                     # gemessen über demselben Baum, der diesen Absatz enthält
```

**128** zusätzliche Befunde — wie jede Zahl unten aus derselben Kommando-Kette gewonnen und
darum ebenso **kein Erwartungswert**, sondern derselbe wandernde Bestand. **102 davon** liegen in
drei Klassen, die kein Bug sind:
content-gefrorene Verweise auf abgelöste Baseline-Tags in den einzelnen
`harness/conventions/`-Einträgen (append-only seit
[`MR-020`](../conventions.md#mr-020--aufgehobener-eintrag-behält-kopf-und-zeiger-statt-rumpf)/[`MR-032`](../conventions.md#mr-032--ein-überholter-eintrag-trägt-eine-kopf-marke-auf-seinen-nachfolger))
und in denselben Tag-Ständen zitierenden, nach [`AGENTS.md`](../../AGENTS.md) §3.4 eingefrorenen ADRs
· Pfade eines abgelösten Mechanismus (unter `.harness/cache/`, abgelöst von
[`MR-007`](../conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)) · der
gitignorierte Laufzeit-Ort `.harness/state/`, den [`spec/architecture.md`](../../spec/architecture.md)
und [`spec/spezifikation.md`](../../spec/spezifikation.md#5-metriken-und-tracing-felder) als
kanonische Adresse führen, obwohl er auf einem frischen Checkout nicht existiert:

```sh
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 ~ /^\.harness\/(baseline|state|cache)/' | wc -l   # 102
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 !~ /^\.harness\/(baseline|state|cache)/' | wc -l  #  26
```

Ein Prüfer, der nur den gesuchten Fall trifft — einen toten Pfad unter dem **aktuellen**
Baseline-Tag in einem lebenden Artefakt —, bräuchte für jede dieser drei Klassen eine eigene,
gemessene Ausnahme: dieselbe Apparatur, die
[`ADR-0039`](../../docs/plan/adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) für die
**Link**-Form von genau drei einfrierenden Bäumen gebaut hat, hier aber zusätzlich für eine
vierte, nicht einfrierende Klasse (gitignorierte Laufzeit-Pfade in kanonischen Spec-Dokumenten).
Das ist außerhalb des Umfangs eines einzelnen Slice und bleibt eine **benannte Lücke**: ein toter
Inline-Pfad unter `.harness/baseline/` in einem lebenden Artefakt bleibt gate-unsichtbar, bis
[slice-202](../../docs/plan/planning/open/slice-202-der-tote-inline-pfad-unter-harness-bekommt-seinen-pruefer.md)
diese Ausnahme-Klassen einzeln trägt.

**Die 102 sind nicht die ganze Entlastung.** Unter den 30 Treffern, deren Ziel mit
`.harness/baseline/` beginnt —

```sh
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 ~ /^\.harness\/baseline\//' | wc -l   # 30
```

— liegen nicht alle in `harness/conventions/` oder einer eingefrorenen ADR:

```sh
grep codepath-missing /tmp/lauf.txt | awk -F'\t' '$2 ~ /^\.harness\/baseline\//{split($1,a,":"); print a[1]}' \
  | grep -vE '^(harness/conventions/|docs/plan/adr/)' | sort -u
```

Unter den 30 zählt der Rest **sechs** Fundstellen, nicht null: fünf tragen einen
`.harness/baseline/<abgelöster Tag>/…`-Pfad in einem offenen Slice-Plan bzw. einem Welle-Plan; eine
sechste — außerhalb der `.harness/baseline/`-Form, aber derselben Klasse *toter Pfad in einem
lebenden Artefakt* — verweist aus einer Skill-Datei auf eine eigene, nicht existierende Vorlage.
(Zwei weitere Treffer derselben Filterzeile sind **kein** Bug: der Beleg-Pfad, den dieser Absatz
selbst zu Testzwecken erfindet, und ein `$(BASELINE_TAG)`-Platzhalter in einer Rezept-Beschreibung
im Sensor [`vendor-baseline`](vendor-baseline.md) — beide sind erkennbar kein Tag-Literal.) Das ist wörtlich der oben
benannte tragende Fall — kein Rauschen.

**Dieselben sechs sind nicht der ganze Rest der 26** — jene Filterzeile trifft nur, wessen Ziel mit
`.harness/baseline/` beginnt. Im **gesamten** Rest von 26 liegen sechs weitere Treffer mit
demselben Ziel — einer im Repo nicht existierenden Skill-Datei (`ls .harness/skills/` → nur
`reviewer.md`) —, in der laufenden Roadmap, zwei offenen Slice-Plänen und drei flachen, offenen
Welle-Plänen:

```sh
grep codepath-missing /tmp/lauf.txt \
  | awk -F'\t' '$2 == ".harness/skills/closure-note-reviewer.md"' \
  | grep -vE 'done/|docs/plan/adr/' | wc -l   # 6 -- kein Erwartungswert, wandert mit dem Bestand
```

Zusammen mit den sechs oben sind es **zwölf**, nicht sechs:

```sh
grep codepath-missing /tmp/lauf.txt \
  | grep -v '^docs/plan/planning/done/' | grep -v '^docs/plan/adr/' | grep -v '/evidence/' \
  | grep -v '^harness/conventions/' | awk -F'\t' '$2 !~ /^\.harness\/(state|cache)/' \
  | grep -v 'does-not-exist-201' | grep -v '\$(BASELINE_TAG)' | wc -l   # 12
```

Beide Gruppen bleiben hier **ungezogen und benannt**, statt in diesem Slice mitgenommen zu werden:
Die zwölf Fundstellen liegen in mindestens vier verschiedenen Eigentums-Bereichen (offene
Slice-Pläne, flache Welle-Pläne, die laufende Roadmap, eine nach
[ADR-0028](../../docs/plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
Reviewer-eigene Skill-Datei), und ein Nachzug in einem einzelnen Implementations-Lauf griffe über
mehrere Rollen-Grenzen hinweg — genau der Fall, den
[slice-201](../../docs/plan/planning/done/slice-201-codepaths-erreicht-den-vendored-baum-nicht.md)
§1 mit *„findet sie viele, ist das ein eigener Vorgang"* für den Gesamtbestand vorwegnimmt, hier
schon bei zwölf Fundstellen, weil die Eigentums-Grenze und nicht die Stückzahl den Ausschlag gibt.

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | kein Befund im Prüfbereich der aktiven Module |
| 1 | mindestens ein Befund; je Befund eine Zeile *Datei:Zeile · Ziel · Befund-Art · Grund* |
| 2 | Nutzungs- oder Umgebungsfehler, gemeldet als `d-check: error: …`; kein Befund ist erhoben |

Die Vollständigkeits-Zeile `N Datei(en) geprüft, M Befund(e)` erscheint bei 0 und 1 und spricht
über den Prüfbereich (§Grenze), nicht über das Repo. `make` meldet den Exit als `Fehler <n>` und
endet selbst mit 2.

## Sperren

- `d-check: error: …` — die `.d-check.yml` ist ungültig; jeder Konfigurationsfehler bricht vor dem
  Scan ab, ohne Vollständigkeits-Zeile, mit Exit 2 → die Konfiguration berichtigen.

## Bindung

[`MR-010`](../conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (Gate-Fragment
tool-generiert); Bestandteil von `make gates`.
