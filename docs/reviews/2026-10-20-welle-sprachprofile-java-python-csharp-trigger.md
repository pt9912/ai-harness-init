# Verifikation: Closure-Trigger von welle-sprachprofile-java-python-csharp (Schritt 1)

**Rolle:** Verifier · **Datum:** 2026-10-20 · **Gegenstand:** Closure-Trigger aus
`docs/plan/planning/welle-sprachprofile-java-python-csharp.md` §3, Punkte 1–3 (Punkt 4, die
Closure-Notiz, ist Planner-Arbeit und nicht Gegenstand dieses Belegs) · Bezug
[`LH-FA-04`](../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-07`](../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren).

**Gemessener Commit:** `449eaeffa80c1e8f59fa857bfeb724c21ba6187b` (HEAD, `main`, gepusht;
Arbeitsbaum sauber vor und nach den Läufen). Gefahren in der Folge `make full-smoke-host`, dann
`make gates`, mit `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH`.

## Verdikte

- **Sechs Slices aus §4 in `done/` — bestätigt (gelesen).**
  `ls docs/plan/planning/done | grep -E '(java|python|csharp)'` nennt `slice-java-skelett.md`,
  `slice-java-hexslice-layout.md`, `slice-python-skelett.md`, `slice-python-hexslice-layout.md`,
  `slice-csharp-skelett.md`, `slice-csharp-hexslice-layout.md` (daneben zwei Slices außerhalb von §4).
- **`make gates` grün — bestätigt (gefahren).** Exit 0, 184 s; letzte Zeile
  `span-check: Traeger vorhanden, span-emit hat einen Span geschrieben, Ablageort git-ignoriert`.
- **`make full-smoke` grün mit den Stufen von Java, Python und C# neben Go, C++, Kotlin — bestätigt.**
  - **Gefahren:** `make full-smoke-host` (artifact-host, macOS-Host, Docker über colima, Image-Lage
    warm), Exit 0, 415 s Wandzeit; Schlusszeilen `full-smoke: OK — …` (zuletzt ZEILENENDEN IM
    KLON). Im Log: Java-Lint-Zahn, Python-Lint-Zähne F401 und TID252,
    `Python-Arch-Gate-Zaehne` mit `greeting.py:3: core-impurity: Kern importiert
    app.adapters.driven.notify.stdout_notifier` und `core-impurity: 1`, C#-Lint-Zahn IDE0005,
    C#-Build-Zahn CA1822, `C#-Arch-Gate-Zaehne` mit `Greeting.cs:1: core-impurity: Kern importiert
    App.Adapters.Driven.Notify` und `core-impurity: 1`, C#-port-locality-Zahn,
    `Java-Arch-Gate-Zaehne` mit `Greeting.java:4: core-impurity: …StdoutNotifier`; daneben die
    Stufen für Go, C++ und Kotlin (`core-impurity` je Sprache im Log).
  - **Gelesen (Linux-Beleg):** `gh run list --workflow ci --limit 5` — Lauf `39329990195`, `headSha`
    `449eaeff…`, success; Jobs `smoke`, `gates`, `adr-immutable`, `full-smoke` je success. Das Log
    des `full-smoke`-Jobs führt dieselben Stufen (add-lang java/python/csharp, Python-/C#-Arch-Zähne,
    `core-impurity: 1`, C#-port-locality). Zweiter Lauf auf `d5f25549…` ebenfalls success.
  - **Nicht gemessen:** kalte Lage; der lokale Lauf ist `-host`, nicht das Linux-`full-smoke`.
- **`docs/user/e2e-abdeckung.md` führt je Sprache eine `LH-FA-04`-Stufe mit der Sprache in der
  Kurzbeschreibung — bestätigt.** Gelesen gegen die Tabelle und gegen `harness/tools/full-smoke.sh`
  (Stufen-Kopfzeilen per `grep -nE '^echo "full-smoke: .*(java|python|csharp)'`):
  - Java: Stufe 15 (flat, `full-smoke.sh:2818`, Ort 2835) und Stufe 25 (hexslice mit Arch-Gate und
    core-impurity, `:3768`, Ort 3787).
  - Python: Stufe 16 (flat, `:2909`, Ort 2925) und Stufe 17 (hexslice, `:3020`, Ort 3044).
  - C#: Stufe 18 (flat, `:3103`, Ort 3120) und **Stufe 19 (hexslice mit Arch-Gate, core-impurity und
    port-locality, `:3233`, Ort 3257)**.
  - **Verweis aufgelöst:** Die Zeile zu C# Stufe 18 sagt „NICHT gemessen: hexslice und das Arch-Gate
    (misst die Stufe darunter)"; die Stufe darunter ist Stufe 19, im Skript vorhanden und im Lauf
    oben und im ci-Lauf rot-mit-`core-impurity` belegt. Keine Lücke. Die Spalte `Ort` zeigt auf eine
    Zeile im Körper der Stufe, nicht auf die Deklaration (`e2e-abdeckung.sh`, awk über die
    Stufen-Region); die Sicht ist durch `make gates` (Gleichheit der erzeugten Datei) gehalten.
  - **Grenzen, in den Kurzbeschreibungen am selben Ort genannt, hier nicht als Befund:** kein
    Root-Bootstrap und kein gemischter Root mit Java/Python/C#; Java/Python/C#-flat nur
    `--arch hexagonal` als Exit-2-Fall; die übrigen Richtungs-Regeln nicht gemessen. Der Trigger
    verlangt je Sprache mindestens die Messung von Stufe 14 (Kotlin flat); sie ist je Sprache
    erfüllt, `hexslice` ist über die jeweilige Stufe belegt.
- **Replay-Set:** im Repo keines (kein Replay-Gate, kein `test-replay`); der Replay-Teil der
  Kanonform aus Modul 6 entfällt und wird nicht als grün behauptet.
- **Release v0.10.0 (nur genannt, außerhalb der Welle, §6):** Tag-Commit `d5f25549…`; Workflows `ci`
  und `release` auf diesem Commit success (`gh run list --workflow ci|release`).

## Laufzeit (MR-089)

- `make full-smoke-host`: **415 s**, `make gates`: **184 s**; Lage warm (Images im lokalen Store),
  Host macOS/colima; Variante: voller E2E-Lauf mit allen Stufen. Ungemessen: kalte Lage.

## Befunde

- Keine. Offene Punkte für den Planner: keine aus diesem Schritt; Punkt 4 (Closure-Notiz) steht aus.

## Ergebnis

Closure-Trigger §3 Punkte 1–3 auf `449eaeff` **erfüllt**.
