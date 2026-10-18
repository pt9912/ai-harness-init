# Review — slice-python-hexslice-layout

**Gegenstand:** Range `42611489..a4fc68be` (c069e697, 67f93340, e36469ef, a3f209a9, fb5f1c55, 20e4cb55, a4fc68be) zu
`slice-python-hexslice-layout`. **Geprüft gegen:** Slice-Plan, ADR-0095 (Accepted), ADR-0060, ADR-0094, `AGENTS.md` §3,
MR-071/MR-090. **Nicht geprüft:** DoD-Konformität (Verifier), eigene Laufzeitmessung (Verifier). **Rolle:** Reviewer, frischer Kontext.

## Findings

### HIGH

Keine.

### MEDIUM

Keine.

### LOW

**L-1 — Kopfkommentar begründet die Paket-Marker mit einer mypy-Zusage, die nur für den Wurzel-Marker gilt**
- `kategorie`: LOW · `quelle`: AGENTS.md §3.6/§3.7 (ungemessene Zusage im Kommentar) · `pfad`: `internal/gen/python_hexslice.go:8-9`
- `befund`: „Jedes Paket-Verzeichnis traegt eine leere `__init__.py`: mypy bildet den Modulnamen ueber sie." Probe am frischen
  Bootstrap (`--lang python --arch hexslice`, echtes `make lint`): mit allen Markern `rc=0`; nach Löschen aller Marker **außer**
  `src/app/__init__.py` weiter `Success: no issues found in 11 source files`, `rc=0`; erst ohne `src/app/__init__.py` bricht mypy mit
  `Source file found twice under different module names` (rc=2). mypy braucht nur den Wurzel-Marker; die übrigen Marker sind
  durch die Zusage nicht gedeckt und erzeugen den a-check-Hinweis aus L-2/I-1.
- `verifizierbar`: ja (Probe oben; kein Gate hält den Kommentar) · `klasse`: „Kommentar begründet Artefakt mit ungemessener Werkzeug-Eigenschaft"

**L-2 — Mehrere Aussagen: ein Paket-Marker mit Import „sähe das Arch-Gate nicht" — a-check meldet ihn, wenn er in eine Schicht importiert**
- `kategorie`: LOW · `quelle`: AGENTS.md §3.6/§3.7 · `pfad`: `internal/gen/python_hexslice.go:253-255` (Config-Kommentar „…ist sie ungeprueft,
  bis eine Schicht sie deckt"), `internal/gen/python_hexslice_test.go:67-70`, `test/mutations/732-python-hexslice-init-nicht-leer.sh:5-6`
  („das Arch-Gate saehe ihn nicht")
- `befund`: Probe (echtes a-check im Probe-Projekt): `src/app/hexagon/__init__.py` mit `from app.adapters.driven.notify.stdout_notifier import …`
  → `wrong-direction: (ohne Schicht) -> driven_adapters`, `gesamt: 1 Befund(e)`, Exit 1 (`make a-check` rc=2); ebenso bei Import in Zeile 2. Ungeprüft bleibt der
  Marker nur, wenn sein Import auf eine selbst schichtlose Datei zeigt oder nicht auflöst. Die drei Stellen sagen pauschal „nicht gesehen";
  die Schutzwirkung der leeren Marker ist damit schmaler als behauptet. Die Abdeckungs-Zeile nennt „Importe in den Paket-Markern" unter NICHT gemessen — dort ist
  die Aussage zutreffend (nicht gemessen), aber mit der Klammer „(liegen in keiner Schicht)" gelesen als „ungeprüft".
- `verifizierbar`: ja · `klasse`: „Kommentar behauptet Gate-Blindheit, die Realquelle widerlegt"

### INFO

**I-1 — a-check-Hinweis „6 gescannte Datei(en) liegen in keiner Schicht" (Abweichung 1 des Implementers): kein Defekt, Entscheidung beim Architect.**
Gemessen am Probe-Bootstrap: `gesamt: 0 Befund(e)`, Hinweis mit sechs Dateien (`src/app/__init__.py`, `adapters/`, `hexagon/`, `application/`,
`application/example/`, `application/example/ports/` — alle leer), Exit 0. Kein stilles Grün im Sinne der HIGH-Liste: der Hinweis erscheint bei jedem
Lauf in der Ausgabe von `make gates` und `make a-check`, die sechs Dateien sind leer (`TestPythonHexslice_InitsLeer`, Fall 732 rot), ein
Marker mit Import in eine Schicht fällt (siehe L-2), und der Config-Kopfkommentar nennt die Lage. Das Gate fällt am Hinweis nicht
(Exit 0), das ist a-check-Verhalten. `exclude` mit `**/__init__.py` ist eine Config-Änderung gegen den Wortlaut von ADR-0095
Festlegung 4 (`exclude: ["tests/**"]`); sie gehört dem Architect (Folge-ADR oder Nachtrag), nicht dem Implementer — dass die
Config exakt nach ADR blieb, ist richtig. Die Ursache der Hinweis-Zeilen ist L-1: nur der Wurzel-Marker ist technisch gefordert.

**I-2 — Fall 742 pinnt die Ursache nicht** (Register `full-smoke-fall-expect-pinnt-nicht-die-ursache`, wiederkehrend wie Java-Fall 727).
`# expect:` ist „make gates nach add-lang python --arch hexslice ist NICHT Exit 0"; die Meldung der Stufe ist dieselbe bei jedem roten Gate
(ruff, mypy, pytest, a-check). Der Fall-Kopf behauptet `wrong-direction`. Die Mutation ändert nur die Kante (741 belegt im Text-Test, dass genau sie fehlt),
`make mutate` liest die Ursache nicht. Rot gesehen, Ursache nicht gelesen. 739 und 740 pinnen dagegen die Ursache (Meldung nennt `core-impurity`
an der Domain-Datei bzw. „loest aber keinen Import auf").

**I-3 — Fall 690: Endform und `TestGenerateArch_PythonOhneHexagonal`.** Die Planner-Annahme „gegenstandslos" war falsch, der Implementer hat sie durch die
Endform widerlegt: Der Fall hält jetzt `hexagonal` ohne Renderer (`sed` auf `"python": {archFlat, archHexslice},` → `…, archHexagonal}`), `expect`
`TestGenerateArch_PythonOhneHexagonal`; Anker greift am realen Quelltext, Fall ok, Test prüft `UnknownArchError` mit `Available = flat,hexslice` und leerem Verzeichnis. Gegenprobe
`t.Skip` im benannten Test: Suite bleibt rot durch `TestRun_AddLangPythonHexagonalIstExit2` (cmd; derselbe Quell-Anker, struktureller Nebeneffekt, kein Befund).
Die Abnahme-Seite („Plan-Annahme widerlegt") liegt beim Planner/Verifier; Plan §3 trägt noch den Wortlaut „wird gegenstandslos".

**I-4 — Rollenfrage `spec/architecture.md` und `README.md`: zulässig, dieselbe Linie wie beim Java-Slice (dort I-4).** `AGENTS.md` §3.8 bindet nur Hard Rules und
Adaptions-Block; ADR-0095 benennt den Slice als Träger, der Plan führt den Nachzug. Inhalt sachlich richtig gegen Code und Config (Verzeichnisse `src/app/…`, Composition Root
`src/app/main.py`, `tests/` als `exclude`, `resolution`-Block, Kanten-Menge der Vererbung, TID252 schließt den relativen Import), Zielbild ohne Zeit- oder Liefersätze. README-Zeile stimmt.

**I-5 — Laufzeit-Messreihe (a4fc68be, leerer Commit).** Plausibel: Stufe 9/9 s; die Gesamtdifferenz 17–30 s übersteigt die Stufenzeit, aber die Python-hexslice-Module
laufen auch in den späteren `make gates` über das gemeinsame `tmprepo_doc` mit (wie beim Java-Slice, I-3 dort) und der Streubereich der Gesamtdauer ist mit 25 s angegeben; die Message
nennt das selbst „kein Beleg fuer sich". Eigene Messung: Verifier.

## Negativbefund — geprüft, ohne Befund

- **AGENTS.md §3.3 (neu):** `git show --stat -M c069e697` → `rename test/mutations/{690-python-hexslice-ohne-renderer.sh => 690-python-hexagonal-ohne-renderer.sh} (100%)`, reiner Move;
  67f93340 ändert nur `690-python-hexagonal-ohne-renderer.sh` (4+/4−); `git diff -M --summary 42611489..a4fc68be` führt keinen weiteren Rename, und kein anderer Commit der Range mischt Rename und Inhalt.
- **(a) Geteilte Helfer / Java-Verhalten:** `archConfigResolution` ist wortgleich zum gelöschten Java-Klon (Regex `languages:`/`resolution:`/`mode`/`roots`/`package_base`, nur der Sprachname als Parameter);
  `assertGlobsMatchSkeleton` mit leerer Variadik verhält sich für Java unverändert. Java-Fälle 719–723, 726, 728–730 einzeln sequentiell (`MUTATE_JOBS=1`, GNU-sed-PATH): alle ok. Gegenprobe `t.Skip`
  (Mutation angewandt, benannter Test stumm, `make test-go`): 720 `TestArchGateConfig_JavaResolution` → grün (bindet allein); Python 734 (`…PythonResolution`), 741 (`…PythonEdgesMatchSkeleton`),
  731 (`…FileSet`) → je grün (binden allein); keine Java-Zähne verloren.
- **(b) Fälle 731–747:** 731–738, 741, 743–747 einzeln im Teillauf: alle 24 gewählten Fälle `ok` (sed-Anker greifen an realen Quelltext, der benannte Test wird aus dem behaupteten Grund rot).
  Lauf-Zähne `SMOKE_ARTIFACT_TARGET=artifact-host`, je einzeln: 739 ok (Meldung „rot, aber nicht mit core-impurity an der Domain-Datei"), 740 ok („loest aber keinen Import auf"), 742 ok (siehe I-2).
- **(c) a-check-Config/Skelett gegen ADR-0095 Festl. 4/5:** `languages python ["**/*.py"]`, `fixed-root`, `roots ["src/app"]` (endet im `package_base`), `package_base "app"`, `exclude ["tests/**"]`, `composition_root
  ["src/app/main.py"]`, sieben Kanten inkl. `driven_adapters → ports_outbound`, `typing.Protocol`-Ports, Adapter erben explizit, nur absolute Importe; `EdgesMatchSkeleton` prüft beide Richtungen
  (741 streicht, 747 ergänzt: beide rot). Realquelle gefahren: frischer Bootstrap `--lang python --arch hexslice`, echtes a-check → `0 Befund(e)`, Exit 0; `hexagonal` → Exit 2
  (`TestRun_AddLangPythonHexagonalIstExit2`, `verfuegbar: flat, hexslice`, kein `apps/py`).
- **(e) „Paket gleich Verzeichnis entfällt in Python":** stimmt mit ADR-0095 („ein Paket-≠-Verzeichnis-Fall wie bei Java kann in Python nicht entstehen") und dem Skelett; Ausnahme nur L-1/L-2 oben.
- **(f) full-smoke-Stufe / `e2e-abdeckung.md`:** Stufe prüft Dateien, `make gates`, Beleg-Marker, Abwesenheit „Import-Symbolen", roten Fall (`greeting.py:3: core-impurity`) und Gegenprobe; Kurzbeschreibung nennt
  Gemessenes und NICHT Gemessenes am selben Ort (Fund nur L-2-Klammer); die Python-flat-Stufe prüft `--arch hexagonal` mit Exit 2 und ohne Artefakt.
- **(g)** siehe I-4. **§3.2 / §3.5 / §3.9:** keine Suppression, keine Gate-Lockerung (a-check-Config nach ADR, Gate-Menge wächst), keine Host-Toolchain im Diff. **§3.7-Kommentare:** außer L-1/L-2 tragen sie Zusage, Kopplung oder Grenze.

## Sensor-Läufe

- `PATH=/opt/homebrew/opt/gnu-sed/libexec/gnubin:$PATH make gates` → `EXIT=0` (alle Stufen bis `span-check`). Arbeitsbaum nach den Bruchproben sauber; Probe-Projekt und Logs unter `.harness/state/` gelöscht.
- Budget: ~30 Tool-Calls.
