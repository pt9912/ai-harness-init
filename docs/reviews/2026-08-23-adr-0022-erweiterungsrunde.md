# ADR-0022 (Proposed) — Erweiterungsrunde

**Rolle:** Reviewer (Modul 10). **Datum:** 2026-08-23. **Lauf:** frischer Subagent (eigener
Kontext, nicht der Haupt-Kontext, der die Schlussrunde gefahren hat).

**Anlass — kein Nachzug, eine substanzielle Erweiterung.** Die Schlussrunde
(`2026-08-23-adr-0022-schlussrunde.md`) gab `9305c13` frei ("frei für die Annahme", 0/0/0/0).
Danach hat der Auftraggeber selbst einen Kandidaten nachgewiesen, den die Abzählung nicht führte
(Produkt-Release als Bündel). Nachgemessen fehlten **vier** Wege, nicht einer; sie sind jetzt als
Mitglieder und als Alternativen H/I/J/K eingetragen, dazu eine neue Spalte *Zeitpunkt*, ein
geänderter Vorspann, ein H-gegen-G-Abwägungsabsatz, eine neu gefasste Trigger-Zeile und zwei
vorweggenommene Regelwerks-Deltas. Die vorherige Freigabe ist damit **aufgehoben** — dies ist ein
Voll-Review des erweiterten Texts, keine Bestätigungsrunde.

**Gegenstand:** `4fcc141..bb65edd` — ein Commit
(`bb65edd Rolle Architect: ADR-0022 -- vier fehlende Wege, und einer davon loest die Annahme auf,
auf der die Wahl ruht`), eine Datei: `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`
(+123/−84, selbst gemessen: `git diff --stat 4fcc141..bb65edd` → genau diese Zahlen und genau
diese Datei). `git status --porcelain` → leer. Status im Kopf weiter `Proposed`.

**Formatter-Rauschen im Diff.** Ein Teil des Diffs stammt von einem Markdown-Formatter des
Auftraggebers (Zeilenumbruch neu gesetzt, Tabellen-Delimiter expandiert) — inhaltlich neutral,
selbst mit `--ignore-all-space` bestätigt (die Bezug-Liste bleibt wortgleich, nur anders
umbrochen). Nicht als Autoren-Absicht gewertet; siehe Frage 5 für die Pipe-Beschädigung, die
derselbe Lauf verursacht und die dieser Commit behebt.

## Eingangs-Kontext (die fünf Pflicht-Punkte plus Plan-Bezug)

1. **Diff/Commit-Range:** `4fcc141..bb65edd`, ein Commit, eine Datei (oben gemessen).
2. **Betroffene Anforderungen:** [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
   (Rang 1), `LH-FA-01`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`, `LH-QA-04`.
3. **Referenzierte aktive ADRs:** `ADR-0003`, `ADR-0007`, `ADR-0011`, `ADR-0016`, `ADR-0020`,
   `ADR-0021` — alle *Accepted*; `ADR-0020`/`ADR-0021` byte-identisch zum Vorzustand geprüft
   (§3.4).
4. **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.4 (Immutabilität), §3.6 (kein Halluzinat /
   gelistet heißt bewacht), §3.7 (keine Review-Geschichte im Artefakt), §3.8
   (Architect-Commit); [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert).
5. **Vorherige Findings am gleichen Modul:** die vier Vorrunden (1 HIGH/2 MEDIUM/5 LOW/4 INFO →
   0/0/0/0 in der Schlussrunde). Keines der dort geschlossenen Findings wird hier neu aufgerollt
   — der neue Text an anderer Stelle wird eigenständig geprüft.
6. **Plan-Bezug:** keiner — der Gegenstand ist eine Entscheidung, kein Slice.

## Selbst gefahren — Kommando und Ergebnis

| Kommando | Ergebnis |
|---|---|
| `git diff --stat 4fcc141..bb65edd` | `123  84  docs/plan/adr/0022-…md` — genau eine Datei |
| `git diff --name-status 4fcc141..bb65edd` | `M` auf genau eine Datei unter `docs/plan/adr/**` — §3.8 |
| `git diff --stat 4fcc141..bb65edd -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` | leer, Exit 0 — §3.4 hält |
| `git status --porcelain` | leer |
| `grep -niE 'slice-[0-9]\|welle-[0-9]'` über die Datei | ein Treffer, ein Dateipfad innerhalb eines Kommandos (Folgepflicht 5), keine Slice-ID als Anker |
| Zeilen der Abzählungs- und der Alternativen-Tabelle einzeln gezählt | je **11** Datenzeilen (Header+Trenner+11 = 13 matched) — deckt die Commit-Behauptung "elf Zeilen in beiden Tabellen" |
| `grep -n '\.harness/baseline' docs/plan/adr/0022-*.md` | leer, Exit 1 — kein lokaler Baseline-Präfix mehr in der Datei (ADR-0016 Festlegung 2) |
| `grep -n 'archive/zip' internal/fetch/baseline.go` | eine Zeile — Zitat der ADR trifft zu |
| `grep -n 'gh release upload .*dist' .github/workflows/release.yml` | eine Zeile, `dist/*` — Zitat trifft zu |
| `grep -n '^RELEASE_PLATFORMS' Makefile` | 6 Plattformen — deckt die "sechs Binaries"-Behauptung von H |
| `grep -n '^### ' .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` | 7 Abschnitte — deckt die "sieben"-Behauptung |
| Python-Script: alle Backtick-Spans mit `\|` je Tabellen-/Prosa-Zeile gezählt, OLD (4fcc141) vs. NEW (bb65edd) | OLD: **1** Tabellenzeilen-Treffer (unescaped, Zeile 564, G-Zeile), **10** Prosa-Treffer; NEW: **1** Tabellenzeilen-Treffer (escaped, Zeile 597), **10** Prosa-Treffer — deckt die "genau eine Stelle"-Behauptung exakt |
| Verbatim-Gegenprobe (`grep -qF` als Here-String) beider Regelwerks-Zitate gegen `/Development/KI/ai-harness-course/lab/regelwerk/modul-15-observability.md` | beide `FOUND` |
| `git -C /Development/KI/ai-harness-course describe --tags` / `diff v5.11.0..HEAD --stat` | `v5.11.0-1-g5f47950`; einziger Zusatz-Commit ändert nur `docs/roadmap.md` — `modul-15-observability.md` bei HEAD byte-identisch zu `v5.11.0` |
| `grep -rn "GOOS\|GOARCH\|runtime\.\|platform" internal/fetch/baseline.go` | leer, Exit 1 — **keine** Plattform-Auswahl-Logik im heutigen Fetch-Code |
| `make docs-check` | `d-check: 355 Datei(en) geprüft, 0 Befund(e)` |
| `make gates` | Exit 0; `grep -c '^ok '` → **143**; `grep -c '^not ok '` → **0**; letzte Zeile `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert` |
| Suche nach weiteren Distributions-Wegen (`internal/emit/`, `.github/workflows/release.yml`, `docker push`/Registry, Installer-Skript, Go-Toolchain-Install) | kein Treffer außerhalb der bereits erfassten A–K — siehe Negativbefund zu Frage 6 |

---

## Findings

### MEDIUM-1 — H "löst Annahme (a) auf": die Behauptung verschiebt die fehlende Information, statt sie zu beseitigen

**Quelle:** ADR-0022 selbst (Kern-Behauptung zu Alternative H, mehrfach: Members-Tabelle "es löst
Annahme (a) auf", Abwägungsabsatz "sie braucht Annahme (a) nicht", Trigger-Zeile "der Weg, der sie
ohne die Annahme beantwortet, ist H").

**Pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:206` (Members-Zeile),
`:341` (Abwägungsabsatz), `:754-757` (Trigger-Zeile).

**Befund:** Annahme (a) fällt laut ADR genau dann, wenn ein Bootstrap "über eine Fernverbindung in
ein Repo einer anderen Plattform" läuft — der Bootstrap-Prozess läuft dann auf einem anderen Host
als dem, auf dem später die Hooks ausgeführt werden. H schlägt vor: der Bootstrap "wählt das für
das Ziel passende [Binary]" aus einem Multi-Plattform-Archiv "aus". Nirgends im Text steht, **auf
welcher Grundlage** der Bootstrap-Prozess — der ja selbst nur auf seinem eigenen, potenziell
falschen Host läuft — die Plattform des *entfernten* Ziels kennt. Nutzt die Auswahl weiterhin
`runtime.GOOS`/`runtime.GOARCH` des laufenden Prozesses (wie G es implizit tut), wählt H exakt
dasselbe Binary wie G und bietet für den Annahme-(a)-Fall **keinen** Vorteil. Löst H das Problem
stattdessen durch eine **explizite** Eingabe (z. B. ein `--target-platform`-Flag), dann hat H
Annahme (a) nicht "aufgelöst", sondern durch eine neue, unbenannte Voraussetzung ersetzt: dass der
Bootstrap-Operator die Ziel-Plattform anderweitig kennt und mitteilt. Beide Lesarten widerlegen die
Formulierung "löst Annahme (a) auf" als Tatsachenbehauptung; keine der beiden wird im Text
unterschieden oder auch nur erwähnt. Damit steht die tragende Behauptung, die laut Commit-Message
H zum "schwerwiegenden" Weg macht und die die neu gefasste Trigger-Zeile als *den* benannten
Ausgang für den Annahme-(a)-Fall benennt, ohne den Mechanismus, der sie tragen müsste.

**Verifizierbar:** nein (Text-Argumentation, kein Gate). Prüfbar durch erneutes Lesen der
Passage mit der Frage "woher kennt der Bootstrap-Prozess die Ziel-Plattform, wenn nicht von sich
selbst?" — die Antwort fehlt an allen drei Fundorten.

### MEDIUM-2 — H "kein neuer Mechanismus": der belegte Code liefert einen Text-Fetch ohne Plattform-Auswahl, nicht den Träger-Mechanismus

**Quelle:** `internal/fetch/baseline.go` (gemessen), gegen die ADR-Behauptung gehalten.

**Pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:343-353`
("Ihre Mechanik ist keine neue…"), `:598` (Members-Zeile Pro-Spalte "kein neuer Mechanismus…").

**Befund:** `internal/fetch/baseline.go` holt tatsächlich ein Zip-Asset mit sha256-Pin **vor** dem
Entpacken, Größenschranke **vor** dem Pin, und typisierten Fehlern, die `LH-QA-02`
(`SHA256Mismatch`) und `LH-QA-03` (`AssetTooLargeError`) im Fehlertext nennen — das ist selbst am
Code verifiziert und korrekt zitiert. Aber: (1) das geholte Asset ist `lab-regelwerk.zip`, ein
**Text-Bundle** aus einem fremden Repo (`ai-harness-course`), nicht ein Binary-Release dieses
Produkts; (2) `unpackTrees` entpackt **unbedingt beide** Bäume (`regelwerk`, `templates`) — es
existiert **keine** Zeile, die nach `GOOS`/`GOARCH`/Plattform selektiert oder einen einzelnen
Archiv-Eintrag statt des gesamten Inhalts auswählt (`grep -rn "GOOS|GOARCH|runtime\.|platform"
internal/fetch/baseline.go` → leer, Exit 1). Die für H eigentlich neue Fähigkeit — aus einem
Mehr-Plattform-Archiv **einen** passenden Eintrag zu wählen und nur den zu entpacken — existiert im
Code nicht. Der Haupttext ("Was H kostet, liegt nicht in der Mechanik, sondern in der
Vertriebsform") verschweigt das vollständig; die Alternativen-Tabelle deutet es immerhin an ("die
Auswahl-Mechanik auf einem Windows-Ziel [ist] ungemessen"), aber beide Stellen zusammen ergeben
eine widersprüchliche Aussage: an der einen Stelle "kein neuer Mechanismus", an der anderen ist der
entscheidende Teilmechanismus offen unmessen/ungebaut. Das Fetch-Verify-Unpack-Skelett ist beleg
bar wiederverwendbar; die Behauptung "keine neue Mechanik" für H als Ganzes ist es nicht.

**Verifizierbar:** ja — `grep -rn "GOOS|GOARCH|runtime\.|platform" internal/fetch/baseline.go`
bestätigt die Abwesenheit reproduzierbar.

### MEDIUM-3 — J zitiert `LH-FA-01` für eine Behauptung, die dessen Akzeptanzkriterien nicht tragen; das ADR selbst nutzt für dieselbe Aussagenklasse an anderer Stelle `LH-QA-03`

**Quelle:** [`LH-FA-01`](../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) (drei
Akzeptanzkriterien: Happy Path Init, Happy Path One-Shot, Boundary/Idempotenz — keines davon
adressiert Netz-/Cache-Zustand zur **Hook**-Laufzeit).

**Pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:600` (J-Zeile:
"dazu ein Netz- oder Cache-Zustand im Hook-Pfad, den [`LH-FA-01`] nicht zusagt").

**Befund:** `LH-FA-01`s Akzeptanzkriterien sprechen ausschließlich über die **Init/Bootstrap-Phase**
(`make gates` grün, Idempotenz eines zweiten Laufs) — nichts davon behandelt, was während eines
späteren **Hook-Aufrufs** an Netz-/Cache-Zustand vorausgesetzt werden darf. Die Formulierung "den
LH-FA-01 nicht zusagt" ist damit trivial wahr für praktisch jede beliebige Behauptung (LH-FA-01
sagt über Hook-Laufzeit-Zustand gar nichts zu — weder dafür noch dagegen) und trägt die Aussage
nicht so, wie es ein Zitat mit Textanker sonst tut. Für exakt dieselbe Aussagenklasse — "kein
Netz … zur Bootstrap-/Betriebszeit" — verwendet dasselbe ADR an anderer, unveränderter Stelle den
präziseren Anker: *„Kein Netz und kein Bauschritt zur Bootstrap-Zeit für den Träger. Das Ziel
bleibt über `bash + git + docker` geschlossen ([`LH-QA-03`])."* (Festlegung 1, unverändert seit der
Schlussrunde). Die J-Zeile hätte konsistent denselben Anker (`LH-QA-03`, dessen Messmethode
ausdrücklich *„für seine Gates braucht es nach dem Bootstrap kein Netz"* sagt) statt `LH-FA-01`
verwenden können; so bleibt der Beleg an dieser einen Stelle unter dem sonst im Dokument
durchgehaltenen Zitat-Standard.

**Verifizierbar:** nein (Text-Präzisionsfrage). Prüfbar durch Gegenlesen von `LH-FA-01`s drei
Akzeptanzkriterien gegen die zitierte Behauptung.

### MEDIUM-4 — Index-Zeile `docs/plan/adr/README.md` ist nach dieser Änderung sachlich veraltet, entgegen etabliertem Nachzieh-Präzedenzfall

**Quelle:** `docs/plan/adr/README.md:30` (ADR-0022-Zeile, von `4fcc141..bb65edd` **nicht**
berührt).

**Pfad:** `docs/plan/adr/README.md:30` vs. `docs/plan/adr/0022-…:749-757`.

**Befund:** Die Index-Zeile sagt noch wörtlich: *„Fällt die Annahme, fällt sie für **F ebenso**,
und der Trigger macht **D, E und F** verfügbar, statt auf eine von ihnen zu zeigen."* Der aktuelle
ADR-Text sagt das Gegenteil an genau dieser Stelle: *„Sie fällt für die Wege der ersten
Herkunfts-Klasse, die **eine** Plattform mitbringen — Alternative F eingeschlossen, **Alternative H
ausgenommen**… und der Weg, der sie ohne die Annahme beantwortet, ist **H**; D und E bleiben
daneben verfügbar."* Das ist keine bloße Umformulierung, sondern ein Sachunterschied: der Index
behauptet, der Trigger zeige auf **keine** bestimmte Alternative — der aktuelle Text zeigt explizit
auf H. Es gibt einen unmittelbaren Präzedenzfall im selben Repo: Commit `5ac9146` ("zweiter
Nachzug") hat genau diese Index-Zeile zuletzt aktualisiert, als sich exakt dieser Trigger-Satz
änderte (`D, E und F` wurde dort erst eingeführt). Diese Runde hat den gleichen Satz erneut
geändert, aber den Nachzug nicht wiederholt — die Index-Zeile bleibt beim Stand vor der
H/I/J/K-Erweiterung stehen, obwohl `docs/plan/adr/README.md` in diesem Repo laut wiederholter
Selbstbeschreibung ("Der Index ist ein **lebendes** Artefakt") und laut eigenem Präzedenzfall
mitgezogen werden soll.

**Verifizierbar:** nein (Konsistenzprüfung zwischen zwei Markdown-Artefakten, kein Gate deckt
sie). Prüfbar durch Seite-an-Seite-Lesen der beiden Sätze.

### LOW-1 — J's Latenz-Kostenaussage bleibt unmarkiert, während vergleichbare Größenordnungs-Behauptungen im selben Dokument als `ungemessen` gekennzeichnet werden

**Quelle:** Interne Konsistenz des Dokuments (H: Archivgröße "ungemessen"; G: Aufschlag je
Tool-Call "hier nicht gemessen", Folgepflicht 9).

**Pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:600` (J-Zeile:
"ein Container-Start je Tool-Call liegt erkennbar darüber").

**Befund:** J behauptet, ein `docker run` je Hook-Aufruf liege "erkennbar" über der 50-ms-Median-
Schwelle aus ADR-0011 — plausibel, aber ohne Messung und ohne das `ungemessen`-Etikett, das das
Dokument für vergleichbare unbelegte Größenordnungs-Aussagen sonst konsequent vergibt (H's
Archivgröße, H's Windows-Auswahl-Mechanik, G's eigener Aufschlag als Folgepflicht 9). Kein
Failure-Szenario außer optischer Inkonsistenz im sonst durchgehaltenen Belegstandard.

**Verifizierbar:** nein.

### INFO-1 — Alternative I begründet ihren Contra-Punkt per Analogie zu ADR-0011 Festlegung 3, nicht per direktem Normzitat

**Quelle:** [ADR-0011](../../docs/plan/adr/0011-telemetrie-erfassung-policy.md) Festlegung 3
(regelt die Ablage des Span-**Bestands**, nicht die Ablage des Emitter-**Binärs**).

**Pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:599` (I-Zeile:
"bricht den gitignorierten Ablageort, den [ADR-0011] für den Bestand entschieden hat").

**Befund:** Die Formulierung benennt korrekt, dass ADR-0011 Festlegung 3 wörtlich den **Bestand**
(die Span-Daten) betrifft, nicht die Platzierung eines Trägers/Binärs — und zieht daraus per
Analogie ("dasselbe Prinzip sollte für den Träger gelten") einen Contra-Punkt für I. Das ist in
sich schlüssig, aber eine Analogie, kein direktes Normzitat; an einer Stelle, an der dieses
Dokument sonst sehr genau zwischen Zitat und Ableitung trennt, wäre die explizite Kennzeichnung
"per Analogie" eine kleine Präzisionsgewinn gewesen. Kein Fehler, keine Handlungsempfehlung nötig
— dokumentationswürdige Beobachtung.

**Verifizierbar:** nein.

---

## Negativbefunde (geprüft, ohne Befund)

- **Frage 1 — I/J/K korrekt eingeordnet und (bis auf MEDIUM-3) an ihrer Quelle belegt.** I gegen
  ADR-0011 Festlegung 3 (gitignorierter Ablageort, selbst gelesen) — belegt, Contra per Analogie
  (INFO-1). J gegen die 50-ms-Median-Schwelle aus ADR-0011 (`Aufschlag je Tool-Call 50 ms im
  Median`, selbst gelesen) — belegt; der zweite Halbsatz (`LH-FA-01`) trägt nicht (MEDIUM-3). K
  gegen `LH-QA-01`/`LH-FA-10` — direkt belegt: `LH-FA-10`s eigenes Akzeptanzkriterium
  *„kann der Träger nicht emittiert werden, wird begründet **nichts** abgelegt — kein Hook, der
  auf ein fehlendes Programm zeigt"* verweist selbst auf `LH-QA-01`, exakt die Formulierung, die
  K's Contra-Spalte aufgreift.
- **Frage 4 — beide Regelwerks-Zitate verbatim bestätigt, Tag-Stand des Klons verifiziert.**
  Beide Zitate mit `grep -qF` als Here-String gegen `/Development/KI/ai-harness-course/lab/regelwerk/modul-15-observability.md`
  bestätigt (`FOUND`). Klon-Stand `v5.11.0-1-g5f47950`; der einzige Commit über dem Tag ändert nur
  `docs/roadmap.md` — `modul-15-observability.md` ist bei `HEAD` byte-identisch zu `v5.11.0`, das
  ADR-Zitat auf diesen Tag also korrekt gepinnt. Die inhaltliche Auflösung (LH-FA-10 Rang 1
  schreibt dem Werkzeug vor, was das Regelwerk dem Adopter zuschreibt) trägt: LH-FA-10 verlangt im
  Akzeptanzkriterium *„Aufbewahrung"* ausdrücklich ein Aufräum-Kommando vom **Werkzeug**; das
  emittierte Setup bleibt danach änderbarer Startwert, keine bindende Adopter-Norm — kein
  Widerspruch zur Regelwerks-Aussage *„Mitzunehmen ist das Schema, nicht das Setup"*, da beide über
  verschiedene Akteure (Werkzeug vs. Adopter) sprechen.
- **Frage 5 — "genau eine Stelle" gemessen bestätigt.** Eigenes Python-Skript über alle
  Backtick-Code-Spans mit `|` je Zeile, getrennt nach Tabellenzeile (Zeile beginnt mit `|`) vs.
  Prosa, für OLD (`4fcc141`) und NEW (`bb65edd`): OLD → genau 1 Tabellenzeilen-Treffer
  (unescaped, Zeile 564, die G-Zeile mit `grep -nE '^FROM .* AS (span|report)$' Dockerfile`), 10
  Prosa-Treffer; NEW → derselbe eine Tabellenzeilen-Treffer jetzt escaped (`(span\|report)`), die
  10 Prosa-Treffer unverändert (korrekt unescaped belassen, da dort keine Tabellenzellen-Grenze
  betroffen ist). Die anderen zwei Prosa-Vorkommen desselben Grep-Strings (§2-Absatz,
  Folgepflicht 1) waren nie in einer Tabelle und folglich nie betroffen. Alle anderen
  grep-zitierten Kommandos, die im neuen Text auftauchen (`archive/zip`, `gh release upload …
  dist`, `RELEASE_PLATFORMS`, `<regelwerk>/modul-15-observability.md` §-Zählung), wurden selbst
  nachgefahren und liefern, was der Text behauptet.
- **§3.4 — `ADR-0020` und `ADR-0021` byte-identisch zum Vorzustand.** `git diff --stat
  4fcc141..bb65edd -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` → leer.
- **§3.8 — nur ein Architect-Artefakt.** `git diff --name-status` → `M` auf genau eine Datei
  unter `docs/plan/adr/**`; Commit-Message beginnt mit *„Rolle Architect:"*.
- **Keine Slice-/Wellen-IDs als normativer Anker.** Ein Treffer, ein Dateipfad innerhalb eines
  Kommandos in Folgepflicht 5, keine Slice-ID als Entscheidungs-Anker.
- **`MR-025` — die "elf Zeilen"-Behauptung der Commit-Message selbst nachgezählt.** Beide Tabellen
  (Abzählung, Alternativen) tragen je 11 Datenzeilen — bestätigt.
- **Keine lokalen Baseline-Präfixe mehr in Regelwerks-Belegen.** `grep -n '\.harness/baseline'
  docs/plan/adr/0022-*.md` → leer, Exit 1. Der einzige vormals vorhandene Präfix (§Kontext,
  `<regelwerk>`-Ersetzung) ist entfernt; kein weiterer gefunden.
- **Keine Review-Geschichte im ADR-Text (§3.7).** `grep -niE 'runde|HIGH-[0-9]|MEDIUM-[0-9]|LOW-[0-9]|INFO-[0-9]|hier stand'`
  über die Datei → leer, Exit 1.
- **`make gates` und `make docs-check` — selbst gefahren, beide grün, nichts aus der
  Commit-Message übernommen.** `make docs-check` → `355 Datei(en) geprüft, 0 Befund(e)`. `make
  gates` → Exit 0, 143 `ok`, 0 `not ok`, letzte Zeile bestätigt den Emitter-Bau und
  `span-check`.
- **Frage 6 — keine weitere, unerfasste Herkunftsklasse eines ausführbaren Trägers gefunden.**
  Durchsucht: `internal/emit/*.go` (kein Code berührt Span/Träger/Telemetrie — die Fitness-Zeilen
  sind tatsächlich "geschuldet, nicht geliefert"); `internal/fetch/` (nur `baseline.go`, Text-Fetch,
  s. o.); `.github/workflows/release.yml` und `make release-artifacts` (baut alle sechs Binaries
  per `docker build --target build` + `harness/tools/artifact-copy.sh`, lädt sie als **nackte**
  Dateien hoch — kein Docker-Push, keine Registry, kein OCI-Image-Publish); kein Installer-Skript
  (`curl … | sh`), kein `go install`-Pfad, kein Homebrew/Choco/Scoop-Verweis im Repo. Ergebnis:
  kein zusätzlicher, unklassifizierter Weg gefunden — dies ist ein **belegter Negativbefund**,
  keine Lücke der Suche.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 4 |
| LOW | 1 |
| INFO | 1 |

## Verdikt

**Blockiert.** Vier MEDIUM-Findings stehen offen, drei davon an Stellen, die die ADR selbst als
tragend ausweist:

- **MEDIUM-1** trifft die **Kern-Behauptung**, die H laut Commit-Message zum "schwerwiegenden" Weg
  macht ("löst Annahme (a) auf") — die Behauptung hält der Nachfrage nicht stand, wie der
  Bootstrap-Prozess im genau beschriebenen Auslöse-Szenario (Fernverbindung, andere Plattform) die
  Ziel-Plattform überhaupt kennt.
- **MEDIUM-2** zeigt, dass die begleitende "kein neuer Mechanismus"-Behauptung nur für den
  Fetch-Verify-Unpack-Teil zutrifft, nicht für die eigentlich neue Fähigkeit (Plattform-Auswahl aus
  einem Mehr-Plattform-Archiv), die im Code schlicht nicht existiert.
- **MEDIUM-4** ist eine unmittelbare Konsequenz: die Trigger-Zeile im ADR-Text und die
  (unberührte) Index-Zeile in `docs/plan/adr/README.md` widersprechen sich jetzt sachlich, obwohl
  ein Präzedenzfall im selben Repo (`5ac9146`) zeigt, dass genau diese Zeile bei genau dieser Art
  Änderung mitgezogen werden soll.
- **MEDIUM-3** ist die kleinste der vier, aber ein echter Zitat-Präzisionsfehler in einem
  Dokument, das an jeder anderen Stelle sehr genau zitiert.

Frage 2 und Frage 3 aus dem Auftrag sind damit die tragenden Befunde dieser Runde: die
Kern-Behauptung zu H trägt nicht, wie sie dasteht, und die Index-Zeile ist dadurch (Frage 3)
nachweislich falsch geworden. Die übrigen Prüfungen (Fragen 1, 4, 5, 6, alle stehenden Prüfungen)
sind sauber — kein HIGH, keine Gate-Verletzung, keine Immutabilitäts-Verletzung, keine Verweis-Form-
Verletzung nach ADR-0016, `make gates`/`make docs-check` grün.

**Übergabe:** Die Behebung gehört dem Architect. Sie berührt voraussichtlich nur die H-Passagen
(Members-Zeile, Abwägungsabsatz, Trigger-Zeile — entweder den Auswahl-Mechanismus benennen oder die
Formulierung von "löst auf" auf "verschiebt in eine explizite Eingabe" abschwächen), die J-Zeile
(Anker auf `LH-QA-03` statt `LH-FA-01`) und die README-Index-Zeile
(Nachzug wie in `5ac9146`). G als gewählter Weg selbst ist von keinem der vier MEDIUM-Findings
betroffen — die Entscheidung für G bleibt in sich tragfähig, unabhängig davon, ob H's Beschreibung
nachgeschärft wird. Dieser Report ersetzt keine Verifikation — DoD-Abhakung und Gate-Lauf-
Bestätigung für einen etwaigen Umsetzungs-Slice bleiben Sache des Verifiers (Modul 11, getrennter
Kontext).
