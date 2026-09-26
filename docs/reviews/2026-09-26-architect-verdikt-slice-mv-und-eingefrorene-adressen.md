# Architect-Verdikt: Ergebnis-Notiz als eingefrorenes Artefakt und die Ausnahmeliste von `make slice-mv` — 2026-09-26

**Rolle:** Architect (Modul 8). Frage: *Trägt die ADR-Lage die zwei offenen Fragen — und wo nicht, was ist zu entscheiden?* Kein Review und keine Verifikation; das Verdikt ist das **Übergabe-Artefakt** an Implementer, Planner und Reviewer.

**Gegenstand:** (1) Wie nennt eine Closure- oder Ergebnis-Notiz einen bewegten Träger? (2) Gehören `docs/reviews/**` und/oder `done/**` in `SLICE_MV_AUSGENOMMENE_PFADE`? HEAD `f8d33b38` bei Beginn des Laufs, Baum sauber.

**Ausgang:** eine neue ADR im Status `Proposed` — `ADR-0070` (Frage 2) —, dazu dieses Verdikt (Frage 1: **keine** neue Norm nötig). Kein Code, kein Test, kein Werkzeug, keine Slice-Datei, kein Register, kein Skill, keine `.d-check.yml`.

**Eigene Läufe:** vier Kopien von `git archive HEAD` außerhalb des Repos (Skript unten), je ein `make docs-check` im gepinnten Bild; zwei Sonden über den Bestand (Skript unten und je ein `git grep`/`awk`-Kommando im Text). Nichts davon hat das Repo verändert.

---

## Vorab: die zwei Fragen sind größtenteils schon entschieden

`ADR-0042` (`Accepted`, 2026-09-12) trägt den Titel *„Der Verweis-Nachzug ersetzt im Zeitdokument die Adresse und in der `Accepted`-ADR nichts"*. Festlegung 1 nennt **vier** Bäume — `docs/plan/planning/done/`, `docs/reviews/`, `docs/plan/carveouts/done/` und das eingefrorene Glied des Beobachtungs-Registers — und sagt *„Das ist entschieden, nicht geduldet"*; Festlegung 2 nimmt allein `docs/plan/adr/` aus; Festlegung 5 sagt, dass die Vorab-Messung nach §3.11 den Move bei einem Zeitdokument **nicht** anhält. Wer die zwei Fragen als offen führt, hat diese ADR nicht gelesen oder sie in `slice-mv.sh` nicht wiedergefunden — der Kommentar an der Ausnahmeliste zitiert `ADR-0033` Abnahme-Kriterium 1 statt `ADR-0042`, und der Planner-Commit `bd76d800` folgte ihm.

---

## Frage 1 — Ergebnis-Notiz: **keine neue Norm; Nachzug ist die entschiedene Antwort für den Bestand, die Kennung bleibt die Regel für das Neu-Schreiben**

**Neu-Schreiben** — geschlossen, wie im Auftrag: bewegliche Träger stehen im Zeitdokument bei der Kennung, ohne Pfad (`AGENTS.md` §3.11, `ADR-0030` Festlegung 3). Unverändert.

**Bestand, den ein Move berührt** — Nachzug durch das Werkzeug, und zwar in der Link-Form ohne Einschränkung im Baum `done/`. Quelle der Zuständigkeit: `ADR-0042` Festlegung 1 (Architect, `Accepted` vom Auftraggeber). Der Move `7b4d54f5` hat in der Ergebnis-Notiz zwei Link-Ziele von `../open/…` auf `../done/…` gesetzt — **das ist die Regel, kein Bruch**: der sichtbare Text (die Kennung) steht unverändert, die Aussage ist dieselbe. Was `§3.4` mit *immutable* meint, ist für die Zeitdokumente nach `ADR-0042` die Aussage und nicht das Byte; `§3.4` nennt nach seinem Wortlaut ADRs.

**Die drei Auswege des Auftrags, gemessen und gewogen:**

| Ausweg | Ergebnis | Grund |
|---|---|---|
| Restore + gezielte Ausnahme für `done/` | **verworfen** | der Restore erzeugt einen toten Link, und `make docs-check` färbt rot: Politik C in der Probe unten — **+15** `target-missing` an einem einzigen Move. Der Ausweg ist ein baum-weites `ignore-refs`, also eine **Senkung nach §3.5**, die `ADR-0042` Festlegung 1 gegen die vier namentlichen Ventile als *„um Größenordnungen mehr Blindheit"* gewogen hat |
| Kennungs-Umschreibung im selben Akt | **verworfen** | aus einem Zeiger wird Text — ein **Urteil je Fundstelle** über 527 Links in `done/`, das kein Match liefert, und es ändert die Aussage; `ADR-0042` Festlegung 4 verwirft es ausdrücklich |
| Nachzug durch das Werkzeug als benannte Ausnahme von der Immutabilität | **ist bereits Norm** | `ADR-0042` Festlegung 1; keine zweite Fassung nötig |

**Sonde — wie viele eingefrorene Artefakte nennen heute bewegliche Träger als Pfad** (die Kommandos des Auftrags, `export LC_ALL=C`):

```sh
git grep -nE '\]\(\.\./(open|next|in-progress)/' -- docs/plan/planning/done docs/reviews docs/plan/adr | wc -l   # 523
git grep -nE '(open|next|in-progress)/slice-'    -- docs/plan/planning/done docs/reviews docs/plan/adr | wc -l   # 1159
```

Je Baum und Form, mit Auflösung gegen das Dateisystem (Skript `sonde.sh` unten; *lebend* heißt: das Ziel liegt heute in `open/`, `next/` oder `in-progress/` und kann noch wandern):

| Baum | Markdown-Link | davon lebend | Code-Span | davon lebend |
|---|---|---|---|---|
| `docs/plan/planning/done` | 527 | 527 | 59 | 12 |
| `docs/reviews` | 55 | 46 | 610 | 21 |
| `docs/plan/adr` | 0 | 0 | 1 | 0 |
| `docs/plan/carveouts/done` | 7 | 7 | 1 | 0 |
| `docs/plan/planning/observations` | 13 | 13 | 5 | 1 |

**Keine Erwartungswerte.** Zwei Lesarten: die **ADR-Hälfte ist leer** (Festlegung 2 hält sie); die Link-Form in `done/` ist die große, gate-geprüfte Klasse — dort ist der Nachzug **notwendig**. In `docs/reviews/` dominiert die Code-Span-Form (610 gegen 55), und die liest das Gate nicht — dort liegt die eigentliche Lücke (Frage 2).

**Das Neu-Schreiben trägt nur zum Teil — gemessen, und als akzeptiertes Negativ benannt.** Seit der Einführung von §3.11 (`05332d63`) haben Läufe Pfad-Links auf bewegliche Slices in Zeitdokumente **hineingeschrieben**:

```sh
git log --format='C %h' --invert-grep --grep='^slice-mv:' --grep='^archive-welle' 05332d63..HEAD -p -U0 \
    -- docs/plan/planning/done docs/reviews |
  awk '/^\+\+\+ /{f=$2} /^\+[^+]/ && /\]\([^)]*\/(open|next|in-progress)\/slice-/{ if (f ~ /docs\/reviews/) {r++} else {d++} }
       END{print "done " d+0 " Zeilen · reviews " r+0 " Zeilen"}'    # done 67 · reviews 81
```

Ich schlage **keine** zusätzliche Pflicht am Closure-Commit vor. Der Grund in einem Satz: Der Nachzug tut das kostenlos und gate-geprüft (unterbleibt er, ist `make docs-check` rot), und die Pflicht wäre ein Urteil je Link ohne Sensor. Der Schreiber-Verzicht bleibt die Empfehlung, die §3.11 formuliert; ein Lauf scheitert nicht daran. **Wenn der Auftraggeber die Pflicht doch will**, ist es eine kleine Norm-Änderung am Closure-Schritt des Planners (Messung vor dem `git mv`: `git grep -cE '\]\([^)]*/(open|next|in-progress)/' -- <geschlossene Datei>` → 0) und ein eigener Auftrag.

**Zum Restore `bd76d800`.** Der Ausgang war richtig, die Begründung nicht: `AGENTS.md` §3.11 bindet den Schreiber und den Lauf, der einen Move **plant** — ein Verbot für den Nachzug steht dort nicht; und `ADR-0033` Abnahme-Kriterium 1 regelt den **Suchraum des Hänger-Wächters** (verbatim: *„Der fail-closed-Wächter gegen einen lebenden Verweis auf einen zu löschenden Review-Report schließt `docs/reviews/**` nicht aus"*), nicht den Nachzug. Der Restore war zulässig, weil die betroffene Zeile ein Code-Span in einem Baum ist, den `codepaths.exempt-paths` ausnimmt (Politik D unten: gate-neutral). Für einen **Link** wäre er ein rotes Gate.

---

## Frage 2 — Ausnahmeliste: **weder `done/**` noch `docs/reviews/**` als Baum; stattdessen eine Form-Regel für `docs/reviews/**`** (`ADR-0070`, `Proposed`)

**Was `ADR-0033` Abnahme-Kriterium 1 wörtlich verlangt:** *„Der fail-closed-Wächter gegen einen lebenden Verweis auf einen zu löschenden Review-Report schließt `docs/reviews/**` nicht aus. Bricht, wenn: ein Report, der **bleibt**, einen Report verlinkt, der ins Archiv geht."* Es trägt Gate-Wirkung für den **Wächter** (Suchraum-Größe), nicht für die Ausnahmeliste des Nachzugs. Eine Ausnahme im Nachzug wäre dafür weder Senkung noch Präzisierung, sondern **eine andere Frage** — die Antwort ist `ADR-0042` Festlegung 1. Die Senkung kommt an einer anderen Stelle: wer den Baum aus dem Nachzug nimmt, muss die toten Links stumm schalten, und das ist §3.5.

**Vier Politiken, an demselben Move gemessen** (Rezept unten; Kopie von `git archive HEAD`, ein Slice `next → in-progress`, auf den zwei Link-Zeilen und weitere Code-Span-Zeilen in Reports und sechzehn Zeilen in `done/` zeigen). Alle vier tragen denselben **einen** Befund (`planning-drift`, vom Zustand `in-progress/` ohne Roadmap-Marker); tragend ist die Differenz:

| Politik | `Befund(e)` gesamt | `target-missing` | Code-Span-Zeilen in Reports geändert | geprüfte Dateien |
|---|---|---|---|---|
| A — heute | 1 | 0 | **ja** (5 Zeilen mit Backtick) | 1964 |
| B — `docs/reviews` ganz ausgenommen | 3 | **2** | nein (0) | 1964 |
| C — `done` ganz ausgenommen | 16 | **15** | ja | 1964 |
| **D — `docs/reviews` nur Link-Form** | 1 | **0** | **nein** (1 Zeile mit Backtick, ein Link mit Code-Span als Linktext) | 1964 |

Vor der Bewegung steht die Kopie bei `d-check: 1964 Datei(en) geprüft, 0 Befund(e)` (Zeile *pristine* im Erstlauf des Skripts).

**Verdikt je Pfad:**

- **`done/**` ganz ausnehmen: nein.** Politik C, **+15** tote Links an einem Move; dort prüft `codepaths` beide Formen (`exempt-paths` nennt allein `docs/reviews/**`), der Nachzug hält das Gate. Kosten der Gegenwahl: ein baum-weites `ignore-refs` — Senkung nach §3.5, mit eigener ADR, für 527 Links.
- **`docs/reviews/**` ganz ausnehmen: nein.** Politik B, **+2** tote Links; die Reports werden zum Zeitpunkt des Moves zitiert (55 Links, 46 auf lebende Träger). Dieselbe Senkung.
- **`docs/reviews/**` nur in der Link-Form nachziehen: ja — `ADR-0070`.** Politik D: dieselbe Befund-Zahl wie A, die Tatsache in der Code-Span-Zeile bleibt stehen. Die Trennlinie ist im Repo schon gezogen: `codepaths.exempt-paths: ["docs/reviews/**"]` mit dem Kommentar *„Lifecycle-Pfade darin veralten per Definition"* — das Gate liest die Code-Span-Form dort nicht, und der Nachzug tat dort bisher, was das Gate nicht verlangte. **Keine Senkung:** `.d-check.yml` bleibt unberührt, die Zahl der geprüften Dateien bewegt sich nicht (letzte Spalte).

**Warum das ein Folge-ADR ist und kein Verdikt:** Es ändert die **Reichweite** von `ADR-0042` Festlegung 1 für einen Baum (*„ersetzt die Pfad-Adresse"* wird zu *„ersetzt die Adresse in Link-Form"*). `Accepted`-ADRs überschreibt niemand (`AGENTS.md` §3.4); der Weg ist `Supersedes (Teil)` auf **einen Wert**, wie `ADR-0034` es an `ADR-0030` vorgemacht hat. `ADR-0033` bleibt unberührt — die ADR liest sein Kriterium, sie ändert es nicht.

**Kosten der Gegenwahl, in einem Satz je Wahl:** *A (nichts tun)* — ein Restore von Hand je Move und Report, ohne Sensor und mit einer Begründung, die auf einen Wächter statt auf den Nachzug zeigt. *B/C* — eine Senkung nach §3.5 für den Gewinn, zwei Zeichen pro Link nicht zu ersetzen. *Kennungs-Umschreibung* — ein Urteil je Fundstelle. *Beide Träger* müssen die Regel tragen: `make slice-mv` **und** `archive-welle` (Nachzug in `internal/archive`), sonst hält die Regel nur für einen der zwei Wege, die einen Report schreiben können.

---

## Übergaben

**Implementer (ein Slice, drei Liefer-Punkte; der Planner schneidet ihn):**
1. `harness/tools/slice-mv.sh`: in einer Datei unter `docs/reviews/` nur die Link-Form nachziehen (Inline `](ziel)`, Referenz-Definition `[name]: ziel`); Code-Span, Code-Block und Fließtext bleiben Byte für Byte. Der Kommentar an der Ausnahmeliste zitiert `ADR-0033` Abnahme-Kriterium 1 für den Nachzug — auf `ADR-0042` Festlegung 1 in der Fassung von `ADR-0070` umstellen. Fall in `test/slice-mv.bats`: **beide** Hälften in **einer** Datei (Link nachgezogen, Code-Span byte-gleich). Die emittierte Fassung: gilt für dieses Repo; ob die Erkennung in `KERN` liegt (dann zieht das Ziel mit) oder außerhalb, sagt der Bericht.
2. `archive-welle` (`internal/archive`, Nachzug-Zweig): dasselbe Verhalten, Go-Test, Mutations-Fall in `test/mutations/`. Der Hänger-Wächter behält seinen vollen Suchraum (`ADR-0033` Abnahme-Kriterium 1) und wird nicht angefasst.
3. `harness/sensors/slice-mv.md` (§Grenze: *„`docs/reviews/**` … nicht ausgenommen"* wird zur Form-Regel) und `harness/sensors/archive-welle.md`.
- **Rot zu sehen** (`AGENTS.md` §3.6): Form-Regel entfernen → Code-Span umgeschrieben (Politik A); Link-Nachzug in `docs/reviews/` entfernen → `make docs-check` rot (Politik B, **+2**); Regel auf `done/` ausdehnen → Code-Span dort bleibt stehen, `codepaths` rot.

**Planner:** (a) den Slice zu Folgepflicht 1 schneiden (Kennung, kein Pfad); (b) **nach dem Accept** den Register-Stand der Beobachtung *„der Nachzug ersetzt eine historisch richtige Adresse"* für den Baum `docs/reviews/` auf diese Entscheidung setzen — das Register gehört ihm; (c) die Übergabe *„gehört `docs/reviews/**` in die Ausnahmeliste?"* aus dem geschlossenen Slice zur LF-Zeilenenden-Frage ist mit diesem Verdikt beantwortet und braucht keinen Eingriff in den geschlossenen Slice.

**Reviewer:** `ADR-0070` gegen `ADR-0042`, `ADR-0033`, `ADR-0030` auf Konsistenz — die drei Bezüge aus dem Acceptance-Trigger. Zu prüfen: dass Festlegung 1 nur den **einen** Wert von `ADR-0042` Festlegung 1 schneidet, dass die Tabelle der vier Politiken aus dem Skript unten wiederholbar ist, dass die Zusage *„keine Senkung"* an der Zahl der geprüften Dateien hängt.

**Auftraggeber — was angenommen werden muss:**
1. Die Reviewer-Runde zu `ADR-0070` und danach der Accept-Vollzug (Architect-Rolle, Beleg als Kennung nach `ADR-0040`). Bis dahin gilt `ADR-0042` unverändert. Beim Accept trägt der ADR-Index bei der Zeile von `ADR-0042` die Teil-Revision nach dem Muster der Zeile von `ADR-0030` — sie steht jetzt nicht dort, weil sie vor dem Accept eine unwahre Zustandsaussage wäre.
2. **Akzeptiertes Negativ 1:** Code-Span-Adressen in `docs/reviews/**` sterben nach einem Move **still** (kein Gate sieht sie). Das ist der Zustand, den die Config schon heute für den Baum deklariert.
3. **Akzeptiertes Negativ 2:** Der Schreiber-Verzicht auf Pfad-Links in Zeitdokumenten hält nicht vollständig (67 Zeilen in `done/`, 81 in Reports seit §3.11), und der Nachzug ist das Netz; keine neue Pflicht am Closure-Commit. Wer sie will, sagt es.
4. **Akzeptiertes Negativ 3:** Die Kopplung zwischen der Form-Regel und `codepaths.exempt-paths` hält kein Test (Re-Evaluierungs-Trigger 1 der ADR).
5. **Nicht gemessen, und der Grund:** Die Code-Span-Form in `done/**` unter `codepaths` — die Probe zeigt sie für den gewählten Slice nicht (dort steht der Slice nur in Reports als Code-Span); sie ist aus der Config gelesen (`exempt-paths` nennt allein `docs/reviews/**`), nicht gefahren, und die Entscheidung ändert `done/` nicht.
6. **Grenzen der Probe:** Politik D ist per `sed` auf Politik B nachgebildet, nicht durch Werkzeug-Code erzeugt; der Move ging `next → in-progress`, nicht nach `done/`, weil `make docs-check` einen ohne Stilllegungs-Inhalt nach `done/` bewegten Slice mit `closure-note-thin` rot färbt (`harness/sensors/slice-mv.md`, §Kanten). Die Differenzen der Politiken bleiben davon unberührt.

---

## Sonden

### `sonde.sh` — bewegliche Pfad-Adressen je Baum und Form

```sh
export LC_ALL=C
P=docs/plan/planning
for tree in "$P/done" docs/reviews docs/plan/adr docs/plan/carveouts/done "$P/observations"; do
  lt=0; ll=0; ct=0; cl=0
  while IFS=: read -r f n m; do
    t=${m#\](}; t=${t%)}; t=${t%%#*}
    q=$(realpath -m --relative-to=. "$(dirname "$f")/$t")
    lt=$((lt+1))
    case "$q" in "$P"/open/*|"$P"/next/*|"$P"/in-progress/*) [ -f "$q" ] && ll=$((ll+1));; esac
  done < <(git grep -noE '\]\([^)#]*/(open|next|in-progress)/[^)#]*\)' -- "$tree")
  while IFS=: read -r f n m; do
    ct=$((ct+1))
    tok=$(printf '%s' "$m" | grep -oE '(docs/plan/planning/)?(open|next|in-progress)/slice-[^` )]*' | head -1)
    case "$tok" in
      docs/*) [ -f "$tok" ] && cl=$((cl+1));;
      *) q="$P/$tok"; [ -f "$q" ] && cl=$((cl+1));;
    esac
  done < <(git grep -noE '`[^`]*(open|next|in-progress)/slice-[^`]*`' -- "$tree")
  printf '%-34s Link: %4d (lebend %3d) | Code-Span: %4d (lebend %3d)\n' "$tree" "$lt" "$ll" "$ct" "$cl"
done
```

### `probe.sh` — vier Politiken an einem Move (je Kopie außerhalb des Repos)

```sh
export LC_ALL=C
S=<scratch>/probe; SL=<slice-in-next-mit-Links-in-Reports>; TOD=in-progress
mk() {  # $1=Name, $2=zusaetzliche Ausnahme (Pathspec) oder leer
  d="$S/$1"; mkdir -p "$d"
  (cd <repo> && git archive HEAD) | tar -x -C "$d"; cd "$d" || exit 2
  git init -q; git config user.name probe; git config user.email probe@example.invalid
  [ -n "$2" ] && sed -i "s#printf '%s\\\\n' ':!.harness/baseline' ':!docs/plan/adr'#printf '%s\\\\n' ':!.harness/baseline' ':!docs/plan/adr' $2#" harness/tools/slice-mv.sh
  git add -A; git commit -qm basis; BASE=$(git rev-parse HEAD)
}
# je Kopie: make slice-mv SLICE=$SL TO=$TOD, dann make docs-check und
#   git diff -U0 "$BASE" HEAD -- docs/reviews | grep -E '^\+[^+]' | grep -c '`'      # Code-Span-Zeilen
mk a                          # A
mk b "':!docs/reviews'"       # B
mk c "':!docs/plan/planning/done'"   # C
mk d "':!docs/reviews'"       # D: wie B, danach in docs/reviews per sed nur das Link-Ziel von next/ auf in-progress/ setzen
```

Die Ausnahmeliste des Dogfood-Skripts ist eine feste Zeile in `eingehend_ausgenommene_pfade`; die Variable `SLICE_MV_AUSGENOMMENE_PFADE` gilt nur im emittierten Werkzeug — darum stellt die Kopie die Politik durch eine Änderung an dieser Zeile her, und der erste Lauf des Skripts (mit der Variable) hat das durch vier gleiche Ergebnisse gezeigt.
