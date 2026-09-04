# MR-050 — Zwei Gate-Ziele fahren ohne `--no-cache-filter`, weil ihr Cache-Schlüssel den Prüfgegenstand deckt

- **Datum:** 2026-09-03
- **Wirksamkeits-Anlass:** slice-160 — die Docker-Form dieses Repos gegen die Ziel-Fassung.
- **Geltungsbereich:** die Rezepte `build` und `host-bin` im `Makefile` (beide in
  `record-gates`) sowie `compile` (kein Gate). Auf der **emittierten** Ebene dieselbe Lücke in
  `goMkFragmentTmpl`/`goScopedMkFragmentTmpl` (`lint`, `build`) und in
  `cppMkFragmentTmpl`/`cppScopedMkFragmentTmpl` (alle drei Ziele), beide in
  [`internal/gen/`](../../internal/gen/). **Nicht** `test-go`, `lint` und `release-artifacts`:
  die tragen den Griff (`grep -cE '^\t+docker build --no-cache-filter' Makefile` → **3**).
- **Ersetzt-Baseline-Regel:**
  [`modul-14-docker-harness.md`](../../.harness/baseline/v6.0.0/regelwerk/modul-14-docker-harness.md#der-prüflauf-ist-hermetisch--kein-mount)
  §Der Prüflauf ist hermetisch — kein Mount, Griff 1 der Tabelle *„Zwei Wege, die Prüfung
  auszulösen"*: `--no-cache-filter <stage>` an jedem Gate, dessen Gate-Stage selbst das Gate ist.
- **Adaption.** Der Griff steht dort, wo ein Cache-Treffer ein Urteil ersetzen könnte, und fehlt
  dort, wo der Cache-Schlüssel genau den Prüfgegenstand deckt.
- **Der Befund ist real, und er ist gemessen — nicht wegargumentiert.** Ein unveränderter
  Wiederholungslauf von `make build` führt die urteilende Schicht **nicht** aus:
  `#13 [build 2/2] RUN CGO_ENABLED=0 … go build …` → `CACHED`, insgesamt **7** gecachte
  Schichten. Das ist wörtlich, was der Abschnitt beschreibt — *„der Gate urteilt nicht, er
  erinnert sich"*. Zum Vergleich derselbe Lauf für `make lint`, das den Griff trägt: die fünf
  Schritte der `lint`-Stage laufen frisch, gecacht sind nur `deps`/`warm`.
- **Warum die Erinnerung hier trägt.** Der Cache-Schlüssel der Schicht darüber
  (`#9 [build 1/2] COPY . .`) ist der Inhalt des Build-Kontexts. Eine Quelländerung
  invalidiert ihn, und das ist einmal **rot gesehen**: mit einem Syntaxfehler in
  `internal/gen/gen.go` — ungespeichert, nur im Arbeitsbaum — bricht `make build` mit
  `internal/gen/gen.go:230:29: syntax error: unexpected name ist at end of statement`, Exit
  **2**. Die Meldung steht im Build-Log, weil kein Aufruf `-q` trägt
  (`grep -cE 'docker build[^#]* (-q|--quiet)( |$)' Makefile d-check.mk` → **0** in beiden) —
  Griff 2 desselben Abschnitts ist damit erfüllt. **Und der Baum bleibt unberührt:** `git status
  -s` nach dem roten Lauf ist leer.
- **Begründung.** Der Griff schützt gegen Eingaben, die **nicht** im Cache-Schlüssel stehen —
  der Abschnitt nennt als Anlass Werkzeuge, die ihre Abhängigkeiten beim Build ziehen (Maven,
  Gradle, NuGet). Die `build`-Stufe dieses Repos zieht nichts: `go.mod` führt keine
  `require`-Zeile (`grep -c '^require' go.mod` → **0**), `go.sum` existiert nicht, und
  `-trimpath` nimmt den Pfad als Eingabe heraus. Damit deckt der Inhalts-Schlüssel den
  vollständigen Prüfgegenstand, und der Griff kostete jeden Gate-Lauf eine volle Neuübersetzung
  gegen ein Risiko, das mit denselben Kommandos als abwesend gemessen ist. Wo diese Deckung
  **nicht** gilt, steht der Griff: `test-go` führt ihn zusammen mit `-count=1`, weil ein warmer
  Kompilat-Cache Tests mit `(cached)` überspränge; `lint` führt ihn, weil `golangci-lint` einen
  eigenen Cache mitbringt; `release-artifacts` führt ihn, weil ein Vergleich zweier Läufe sonst
  den Cache statt der Reproduzierbarkeit belegte.
- **Keine Erwartungswerte** ([`MR-025`](../conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2) — jede Zahl oben wandert mit dem Baum bzw. mit dem Zustand des lokalen
  Build-Caches; tragend ist die Richtung, nicht der Betrag.
- **Kein Wächter, und das gehört dazu.** Kein Modul aus `modules:` der
  [`.d-check.yml`](../../.d-check.yml) liest ein Make-Rezept (`grep -m1 '^modules:' .d-check.yml`
  führt `links, anchors, ids, matrix, codepaths, spans`), und `make mutate` kennt keine
  Fehlschlag-Form, in der ein fehlender Schalter rot wird. Träger ist der Auflösungs-Trigger
  unten, geprüft im Trigger-Audit der Closure.
- **Auflösungs-Trigger:** sobald die `build`-Stufe eine Eingabe zieht, die nicht im
  Build-Kontext liegt — eine `require`-Zeile in `go.mod`, ein `go.sum`, ein Netz-Zugriff in
  einer Stage. Dann deckt der Inhalts-Schlüssel den Prüfgegenstand nicht mehr, und der Griff
  gehört an `build` und `host-bin`; die Änderung ist je Rezept ein Wort. Für die emittierte
  Hälfte feuert derselbe Trigger, sobald ein Skelett-Gate seine Werkzeuge beim Build zieht — im
  C++-Skelett ist das bereits der Fall (`apt-get install` in der `toolchain`-Stufe), dort hängt
  die Deckung am `ubuntu`-Tag und nicht am Build-Kontext.
