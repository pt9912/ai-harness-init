# ADR-0095: Python-Skelett — Toolchain und Schicht-Auflösung

**Status:** Proposed

**Datum:** 2026-10-17

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4),
[`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren),
[`LH-FA-07`](../../../spec/lastenheft.md#lh-fa-07--arch-gate-baseline-emittieren),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[ADR-0094](0094-java-skelett-toolchain-und-schicht-aufloesung.md) (Vorbild),
[ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md),
[ADR-0008](0008-arch-achse-emittiertes-skelett.md), [ADR-0009](0009-hexslice-arch-realisierung.md),
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md); Gegenstand von
`slice-python-skelett` (Welle `welle-sprachprofile-java-python-csharp`)

**Schärft:** [`ARC-009`, `ARC-010`](../../../spec/architecture.md#1-komponenten-übersicht)
(Generator und Verdrahtung für die Sprache `python`).

**Verfeinert (nicht supersedet):** [ADR-0094](0094-java-skelett-toolchain-und-schicht-aufloesung.md)
und [ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) — Mechanik (Einzelmodul,
Image-Tag-Pin mit Knopf, Stage-Fragment, `fixed-root`-Auflösung, Union-Guard) gilt unverändert und wird
hier auf Python angewandt; [ADR-0008](0008-arch-achse-emittiertes-skelett.md),
[ADR-0009](0009-hexslice-arch-realisierung.md) bleiben unberührt.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR).

---

## Kontext

[`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) führt `python` in der
Sprachliste; ein Change Request ist nicht nötig. Offen sind Paket-Werkzeug, Image, Test/Lint/Typprüfung,
Layout-Menge, Schicht-Auflösung und Guard-Set. Die Gerüstung muss arch-invariant bleiben
([ADR-0008](0008-arch-achse-emittiertes-skelett.md)). Zwei Ausgangslagen sind gemessen, nicht
angenommen: Der gepinnte a-check (`grep -n 'DefaultArchImage  =' internal/emit/archgate.go` → `v0.23.2`)
kennt `python` (Messung 4, Fall 12: die Fehlermeldung zählt `cpp|csharp|go|java|kotlin|python|rust|typescript`
auf). Und der Guard-Boden des emittierten Ziels führt `pip pip3 pipx` schon heute, vor jedem
Sprach-Fragment (`grep -n '^BLOCKED=' internal/emit/templates/enforce/pretooluse-command-guard.sh`);
`python`, `python3` und die Werkzeug-Namen stehen weder dort noch in einem anderen Profil
(`sed -n '/^func blockedByLang/,/^}/p' internal/emit/enforce.go` listet go, cpp, kotlin, java).

## Entscheidung

Wir wählen **ein Python-Einzelprojekt im `src`-Layout ohne Build-Backend, `pip` mit exakt gepinnten
Direkt-Werkzeugen, pytest als Test, ruff und mypy (strict) als Lint, Layouts `flat` und `hexslice`**.
Werkzeug- und Versionswahl, bei der mehrere Optionen gleichwertig tragen, hat der Auftraggeber
entschieden (Abschnitt „Entscheidungen des Auftraggebers"); die Festlegungen 1, 2, 3 und 6 tragen
diese Entscheidung unbedingt.

**1. Projekt-Form und Paket-Werkzeug.** Ein Projekt, Paket `app` unter `src/app/`, Tests unter
`tests/`. `pyproject.toml` trägt **nur Werkzeug-Konfiguration** (pytest, ruff, mypy), kein `[project]`
und kein Build-Backend: Das Gerüst läuft dann auf jedem Python, den der Knopf wählt, ohne gegen ein
`requires-python` zu driften (Messung 2: 3.13, 3.14 und 3.15 grün mit derselben Datei).
`requirements-dev.txt` führt die drei Direkt-Werkzeuge mit **exakten** Versionen; das Dockerfile
installiert sie per `pip install -r` im Bild-Build (Netz beim `docker build` des Ziels, wie
[ADR-0088](0088-kotlin-skelett-toolchain-und-schicht-aufloesung.md) Festlegung 2 — kein
Host-Python, [`AGENTS.md`](../../../AGENTS.md) §3.9). **Transitive Abhängigkeiten sind nicht
gepinnt** (Messung 2 zeigt die aufgelöste Menge): Ein statisch erzeugtes Skelett kann keinen
Lock-File mitführen, der zur Laufzeit des Ziels stimmt; ein Adopter friert selbst ein. Das ist das
akzeptierte Negativ gegenüber [`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit).

**2. Image und Pin.** Image `python:<tag>`, per **Tag** gepinnt (kein Digest im Gerüst, damit der
Knopf wirkt — dieselbe Form wie Kotlin und Java), Knopf `SKEL_PYTHON_VERSION` →
`gen.DefaultVersion("python")` mit eigener Konstante `DefaultPythonVersion`. Default:
**`3.14.8-slim`**. Gemessen ist, dass der Tag existiert, sein Digest, und dass das Gerüst auf
`3.13.16-slim`, `3.14.8-slim` und `3.15.0-slim` in allen drei Stages grün läuft (Messung 1, 2). Die
Make-Variable heißt `PYTHON_TAG` (kein Namenskonflikt mit `GRADLE_TAG` oder `JAVA_GRADLE_TAG`).
Eine Alpine-Variante ist nicht gemessen und nicht gewählt.

**3. Test, Lint, Typprüfung.** `test`/`lint`/`build` sind Dockerfile-Stages, gekoppelt an das
Code-Gate-Fragment wie bei go/cpp/kotlin/java; drei Targets, **kein viertes**: so greift die
Präzedenz-Erweiterung des gemischten Roots unverändert. `test` = `python -m pytest` (Konfiguration
`pythonpath = ["src"]`, `testpaths = ["tests"]`). `lint` = `ruff check .` **und** `ruff format
--check .` **und** `mypy` (`strict = true`, `files = ["src", "tests"]`, `mypy_path = "src"`) —
`lint` bündelt Stil und Typprüfung. `build` = `python -m compileall -q src` (Syntax-Prüfung; es gibt
kein Artefakt, weil kein Build-Backend). Ruff-Regeln `E`, `F`, `I`, `B`, dazu `TID` mit
`ban-relative-imports = "all"` (schließt die Lücke relativer Importe bei a-check, Festlegung 5).
**Gebunden** ist allein, dass `F` (`F401`, unbenutzter Import) und mypy-strict im `lint`-Rezept
stehen — die Fälle, die die Lint-Zeile der Fitness Function rot färben; der übrige Regel-Satz ist
Gerüst-Inhalt, und eine Config ohne `F` ließe die Zeile ungeprüft, statt zu brechen. Ein dritter Weg
(pylint, bandit, pyright) braucht eine Folge-ADR.

**4. Gate-Targets und Fragment-Form.** `harness/mk/<modul>.mk` wie bei Java: Root unscoped (`docker
build .`), Subdir modul-scoped (`test-<modul>` …, `docker build <pfad>`), gemischter Root mit
Präzedenz-Erweiterung ohne eigenes Rezept; `GATE_CHECKS += lint build test`. Kein neues Muster.

**5. Layouts und Schicht-Auflösung.** Diese ADR legt für `python` die Layouts `flat` und `hexslice`
fest; `hexagonal` legt sie nicht fest (Trigger 3). Welcher Slice `hexslice` liefert, ist
Zuschnitt des Planners (Layout-Slice); die Festlegung gilt unabhängig davon. Ein Layout steht in
`langArchs()` nur, wenn sein Renderer es rendert, sonst gibt `add-lang python … --arch hexslice`
Exit 2 statt eines stillen Gerüst-only-Skeletts; `flat` trägt kein Arch-Gate (kein Prüfbereich,
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Pfade nach
[ADR-0060](0060-adapter-und-ports-ordner-folgen-ihren-rollen-namen.md): `src/app/hexagon/{domain,application}/…`,
`src/app/adapters/{driving,driven}/…`, Composition Root `src/app/main.py`, Tests unter `tests/`.
Ports-Ordner und Kanten-Menge (sprach-abhängig, ADR-0060 Festlegung 4) entscheidet der Layout-Slice
nach dem Kotlin-Muster; die Kante `driven_adapters → ports_outbound` ist am Python-Fall gemessen
(Messung 4, Fall A) — nur über einer Vier-Schichten-Probe, nicht über dem vollen Skelett. a-check-Auflösung:
`languages: python: ["**/*.py"]`, `exclude: ["tests/**"]`,
`resolution: python: {mode: fixed-root, roots: ["src/app"], package_base: "app"}` — der Root endet im
`package_base`-Verzeichnis (Begründung: ADR-0088 Festlegung 4; Fall 3: Root `src` löst keinen Import
auf). Der Dateipfad ist das Modul; ein Paket-≠-Verzeichnis-Fall wie bei Java kann in Python nicht
entstehen. Gemessen erkannt: `from … import`, `import a.b.c`, `from a.b import modul`, `import *`,
Funktions-lokaler Import, mehrzeiliger Klammer-Import, Import unter `TYPE_CHECKING`,
`core-impurity`, `lateral-adapter` (Messung 4). **Nicht erkannt:** (a) ein **relativer Import**
(`from ...adapters.driven.store import Store` → `0 Befund(e)`, Hinweis „relativer Import — von diesem
Backend nicht extrahiert", EXIT=0, Fall 6) — vom Skelett über ruff `TID252` geschlossen, Messung 3;
(b) ein voll qualifizierter Name ohne Import (Fall 8) und (c) ein dynamischer Import
(`importlib.import_module`, Fall 14) — Grenzen von a-check am Pin, vom Skelett nicht schließbar.

**6. Guard.** `blockedByLang("python")`: `python python3 pytest ruff mypy uv uvx poetry`. `pip pip3
pipx` stehen **nicht** darin: der gebackene Boden führt sie, und die Union ist die eine Quelle (der
Boden ist in `make full-smoke` gemessen: `pip install x` blockt auch ohne Fragment). `uv`, `uvx`
und `poetry` stehen darin, obwohl das Gerüst sie nicht nutzt: der Guard blockt Host-Aufrufe, nicht
nur die genutzte Toolchain, und sie sind der naheliegende Host-Umweg an den verworfenen Alternativen
— dieselbe Linie wie `mvn`/`mvnw` neben Gradle in [ADR-0094](0094-java-skelett-toolchain-und-schicht-aufloesung.md).
`flake8` und `black` stehen nicht darin: sie sind verworfen, werden aber kein Host-Umweg des Gerüsts
(kein Folgeaufruf wie bei `uv` neben `pip`); ein Name im Set ist eine Zusage des Tests. Keine
Überschneidung mit go, cpp, kotlin, java; die Kopplung an `gen.SupportedLangs` hält der bestehende
Test, und die Union mit anderen Fragmenten ist unschädlich, weil der Guard die Menge als Union liest.

## Entscheidungen des Auftraggebers

Getroffen am 2026-10-17 und in Festlegung 1, 2, 3 und 6 getragen; die verworfenen Optionen stehen
mit ihrem Grund unter „Verglichene Alternativen".

- **Python-Version:** `3.14.8-slim`. Verworfen: `3.13.16-slim` und `3.15.0-slim`; alle drei laufen in
  allen Stages grün (Messung 2). Python hat keine LTS-Auszeichnung; der Tag ist ein Wert, der mit dem
  Pin wandert.
- **Paket-Werkzeug:** `pip` + `requirements-dev.txt`, kein `uv`.
- **Lint/Format:** `ruff` (check + format), nicht `flake8` + `black`.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — nichts tun (Python bleibt ungerendert) | kein Aufwand | [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) nennt Python; die Welle hätte keinen Gegenstand |
| B — `uv` als Paket-Werkzeug | schneller: 0,89 s gegen 4,35 s je Stage in einer Einzelmessung (Messung 5) | zweiter Pin; Lock-File-Vorteil nicht nutzbar (statisch nicht erzeugbar, Festlegung 1); nur Geschwindigkeit — vom Auftraggeber verworfen |
| C — poetry/hatch/setuptools als Backend (`pip install -e .[dev]`) | Paket-Metadaten, Entry-Points | `build-system.requires` ungepinnt oder Zusatz-Pin; `requires-python` driftet gegen den Knopf; nicht gemessen |
| D — Multi-Projekt je Schicht | Import-Grenze durch Paket-Grenze | Gerüstung arch-abhängig → bricht [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) AC *Arch-Achse*, nur mit CR |
| E — `unittest` statt pytest | keine Abhängigkeit | nicht gemessen; schwächere Ausgabe, kein `pythonpath`-Schalter |
| F — pyright statt mypy | schneller | braucht eine Node-Laufzeit im Bild; nicht gemessen |
| G — Alpine statt slim | kleineres Bild | nicht gemessen; musl gegenüber Binär-Wheels |
| H — zusätzlich `hexagonal` | volle Achse | ohne benannten Bedarf |
| J — `flake8` + `black` statt ruff | etabliert; grün gemessen (Messung 6) | zwei Pins; keine Entsprechung zu `TID252` im Basis-Satz (nicht gemessen); rot nicht gefahren — vom Auftraggeber verworfen |
| K — `3.13.16-slim` oder `3.15.0-slim` als Default | beide grün (Messung 2) | ältere bzw. gerade erschienene Linie; vom Auftraggeber nicht gewählt, über den Knopf weiter wählbar |
| **I — pip + `requirements-dev.txt`, pytest, ruff+mypy, flat+hexslice, `3.14.8-slim`** | gleiches Muster wie Java/Kotlin; a-check löst Python auf; Lint rot/grün gemessen; kein Build-Backend | transitive Abhängigkeiten ungepinnt; `lint` bündelt Stil und Typprüfung; Schicht-Grenze nur über a-check |

## Konsequenzen

- Positiv: Python dockt an die sprach-agnostischen Stellen an (Kompositions-Seam, Arch-Gate-Bedingung);
  keine Anforderung an a-check oder d-check.
- Negativ (akzeptiert): je Python-Stufe ein `docker build` mit `pip install` verlängert `make
  full-smoke`; der Zuwachs wird je Slice gemessen.
- Negativ (akzeptiert): transitive Abhängigkeiten sind ungepinnt (Festlegung 1); relative Importe
  schließt nur die Lint-Regel, nicht a-check; ein voll qualifizierter Name und ein dynamischer Import
  entgehen dem Arch-Gate (Festlegung 5).
- Negativ (akzeptiert): der Pin ist ein Tag. Kein Freshness-Lauf sieht den Python-Pin:
  `bash harness/tools/digest-freshness.sh --pins` führt go, golangci-lint, d-check und a-check, keinen
  Skelett-Pin; `make freshness-kotlin` liest allein die Kotlin-Konstante; die Versionen in
  `requirements-dev.txt` sieht gar kein Lauf. Ein Python-Freshness-Werkzeug ist nicht Gegenstand dieser
  ADR und hat keinen Nehmer: der Pin altert unbemerkt (akzeptiertes Negativ).
- Folgepflicht: `spec/architecture.md` (Layout je Sprache) für `hexslice` nachziehen — Träger ist der
  Layout-Slice (Planner); er trägt sie als DoD-Punkt, ebenso die Entscheidung von Ports-Ordnern und
  Kanten-Menge (Festlegung 5). Kein Sensor hält sie.
- Folgepflicht: die a-check-Zeile der Fitness Function hat ihren Träger (eine `make full-smoke`-Stufe
  mit rotem Domain→Adapter-Import) erst mit dem Layout-Slice; bis dahin ist sie Zusage.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| a-check (gepinnt) über dem Python-`hexslice`-Ziel | ein Import aus `app.hexagon.domain` nach `app.adapters` färbt a-check rot mit `core-impurity`, ein Import `driving → driven` mit `lateral-adapter`; beide rot gesehen am Probe-Projekt (Messung 4, Fälle 1, C), am gebootstrappten Ziel noch nicht. `app-impurity` und `wrong-direction` sind **nicht** gefahren: Zusage | `make full-smoke` (kein Gate), Stufe mit dem Layout-Slice |
| Code-Gate-Fragment ↔ Dockerfile | jedes Ziel `test`/`lint`/`build` des Python-Fragments hat seine Stage — Zusage eines eigenen Tests nach dem Muster `TestJavaCodeGateFragment_TargetsMatchStages`; Zusage, nicht Beleg | `make test` |
| Lint, Typprüfung, Test, Build rot | unbenutzter Import → `F401`, Format-Verstoß → `ruff format --check`, Typfehler → mypy `[return-value]`, falsche Assertion → pytest `FAILED`, Syntaxfehler → `compileall`; je Exit 1 des `docker build`, rot gesehen am Probe-Projekt (Messung 2) | `make gates` im Ziel |
| Relativer Import | `from . import main` färbt `lint` rot mit `TID252` (Messung 3); am gebootstrappten Ziel noch nicht | `make gates` im Ziel |
| Guard ↔ `gen.SupportedLangs` | ein Profil ohne `blockedByLang`-Eintrag färbt den bestehenden Kopplungs-Test rot; für `python` Zusage, Beleg entsteht mit dem Eintrag; dazu ein Test auf die Namen von Festlegung 6 nach dem Muster der Java-Namensprüfung in `internal/emit/enforce_test.go` | `make test` |

Lücke: kein Sensor hält die Probe-Messung gegen das emittierte Skelett — bis das Skelett existiert,
tragen die Zeilen Zusage statt Beleg ([`AGENTS.md`](../../../AGENTS.md) §3.6). Lücke:
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) verlangt Reproduzierbarkeit
gemessen als Vergleich zweier Bauten desselben Tags; kein Lauf vergleicht sie
(`BEO-ALL/cpp-skelett-erfuellt-die-messmethode-von-lh-qa-02-nicht`), das Python-Image erbt das, und
die ungepinnten transitiven Abhängigkeiten (Festlegung 1) verschärfen es.

## Messungen

Methode: Der Docker-Daemon sieht das Scratchpad nicht als Mount. Das Probe-Projekt (Messung 2)
baut mit `docker build <Kontext>`; a-check läuft über `docker create` + `docker cp <fixture>/. <id>:/src`
+ `docker start -a` aus einem gitignorierten Pfad unter `.harness/state/`; vor `docker cp` ein `chmod -R
a+rX` auf die Fixture, sonst endet a-check mit `open /src/.a-check.yml: permission denied`.

```text
1. $ docker buildx imagetools inspect python:3.14.8-slim  → sha256:a2b82f3c48559aa0a8446d9af49826b6e2b2016f4cd2afabfe6013ec53729170
   $ docker buildx imagetools inspect python:3.15.0-slim  → sha256:2da676046630d7bf14c6764ae1143dc7fa0377a53f94bf5a642f0b214aca5bce
   $ docker buildx imagetools inspect python:3.13.16-slim → sha256:70729b46c69b4f1e97c4822c1af3df53a1476cf5ddc6c087c0c10bc3a5678c2f
   $ docker buildx imagetools inspect ghcr.io/astral-sh/uv:0.13.1 → sha256:4a1f3666816dafadd20ceb71eac9a7d56d7ef30279f7d64048519ab901ada336
   (python:3.14-slim trägt denselben Digest wie 3.14.8-slim; Versionen: pip index versions →
    pytest 9.1.1, ruff 0.17.1, mypy 2.4.0, flake8 7.4.1, black 26.10.1, uv 0.13.1)
```

**2. Probe-Gerüst (vollständig).** Dateien:

```text
requirements-dev.txt   pytest==9.1.1 · ruff==0.17.1 · mypy==2.4.0   (je eine Zeile)
pyproject.toml         [tool.pytest.ini_options] pythonpath=["src"] testpaths=["tests"]
                       [tool.ruff] line-length=100 · [tool.ruff.lint] select=["E","F","I","B"]
                       [tool.mypy] strict=true mypy_path="src" files=["src","tests"]      (kein [project])
src/app/__init__.py    leer
src/app/main.py        """Command app."""; def greeting(name: str) -> str: return "Hallo, " + name;
                       def main() -> None: print(greeting("Welt")); if __name__=="__main__": main()
tests/test_main.py     from app.main import greeting; def test_greeting_nennt_den_namen() -> None:
                       assert greeting("Welt") == "Hallo, Welt"
Dockerfile             ARG PYTHON_TAG=3.14.8-slim
                       FROM python:${PYTHON_TAG} AS toolchain   (ENV PIP_DISABLE_PIP_VERSION_CHECK=1 PIP_NO_CACHE_DIR=1
                         PYTHONDONTWRITEBYTECODE=1; WORKDIR /src; COPY requirements-dev.txt .;
                         RUN pip install -r requirements-dev.txt; COPY . .)
                       FROM toolchain AS build  → RUN python -m compileall -q src
                       FROM toolchain AS test   → RUN python -m pytest
                       FROM toolchain AS lint   → RUN ruff check . && ruff format --check . && mypy
```

```text
   $ docker build --build-arg PYTHON_TAG=<T> --target build|test|lint .   (T = 3.13.16-slim, 3.14.8-slim, 3.15.0-slim)
   → alle neun Läufe grün (Probe ohne [project]-Block)
   aufgelöste Menge im lint-Image (pip freeze): ast_serialize==0.13.1 iniconfig==2.3.1 librt==0.16.0
     mypy==2.4.0 mypy_extensions==1.1.0 packaging==26.3 pathspec==1.1.1 pluggy==1.7.0 Pygments==2.21.0
     pytest==9.1.1 ruff==0.17.1 typing_extensions==4.16.0
   Rot (3.14.8-slim, je eine Änderung am Gerüst):
     `import os` am Anfang von main.py       → lint: F401 `os` imported but unused (dazu I001), exit code 1
     `x = [1,2,\n  3]` angehängt             → lint: `ruff format --check`: 1 file would be reformatted, exit 1
     `def bad() -> int: return "x"`          → lint: mypy `[return-value]`, Found 1 error, exit 1
     Erwartung "Falsch" statt "Hallo, Welt"  → test: FAILED test_greeting_nennt_den_namen, AssertionError
     `def broken(:` angehängt                → build: SyntaxError: invalid syntax, exit 1
3. Relativer Import: ruff `select` um "TID", `[tool.ruff.lint.flake8-tidy-imports] ban-relative-imports="all"`,
   src/app/rel.py = `from . import main` → lint: `TID252 Prefer absolute imports over relative imports`
   (dazu F401), exit 1.
```

**4.** a-check `ghcr.io/pt9912/a-check:v0.23.2`, vollständig. Basis-Fixture (Fälle 1 bis 14): leere
`__init__.py` in `src/app`, `adapters`, `adapters/driven`, `hexagon`, `hexagon/domain`;
`src/app/adapters/driven/store.py` = `class Store:\n    X = 1`; `src/app/hexagon/domain/greeting.py` =
`<Zeile 1: Import>` + `class Greeting:\n    pass`. `.a-check.yml`: `version: 1` · `languages: python:
["**/*.py"]` · `layers: domain {globs: [src/app/hexagon/domain/**], role: domain}, driven_adapters
{globs: [src/app/adapters/driven/**], role: adapter, direction: driven}` · `edges: [{from:
driven_adapters, to: domain}]` · `resolution: python: {mode: fixed-root, roots: [<R>], package_base:
"app"}`.

```text
Fall  R / Änderung                  Zeile 1 / Körper                                     Ausgabe                                  EXIT
1     src/app                       from app.adapters.driven.store import Store          core-impurity …greeting.py:1              1
2     kein resolution-Block         (wie 1)                                              0 Befund(e) + „0 von 1 Import-Symbolen"   0
3     src                           (wie 1)                                              0 Befund(e) + „0 von 1 Import-Symbolen"   0
4     src/app                       import app.adapters.driven.store                     core-impurity                             1
5     src/app                       from app.adapters.driven import store                core-impurity …app.adapters.driven        1
6     src/app                       from ...adapters.driven.store import Store           0 Befund(e) + „relativer Import … nicht extrahiert"  0
7     src/app                       from app.adapters.driven.store import *              core-impurity                             1
8     src/app                       Körper: s = app.adapters.driven.store.Store          0 Befund(e)                               0
9     src/app                       Import innerhalb einer Methode (Zeile 3)             core-impurity …greeting.py:3              1
10    src/app                       from … import (\n    Store,\n)                        core-impurity                             1
11    src/app                       store.py importiert domain.greeting.Greeting         0 Befund(e) (Kante driven_adapters→domain erlaubt)  0
12    src/app, Schlüssel `py`       (wie 1)                                              a-check: unbekannte Sprache "py" (cpp|…|python|…)  2
13    src/app                       Import unter `if TYPE_CHECKING:` (Zeile 3)           core-impurity                             1
14    src/app                       Körper: importlib.import_module("app.adapters.…")    0 Befund(e) + „0 von 1 Import-Symbolen"   0
```

Zweite Fixture (Fälle A bis E, Vier-Schichten-Probe): zusätzlich `src/app/hexagon/application/example/ports/outbound/notifier.py`
(`class Notifier(Protocol)`), `src/app/adapters/driving/cli.py` (`X = 1`), `src/app/main.py` (importiert
`greeting`); Schichten `domain`, `ports_outbound` (`role: port, direction: outbound`), `driving_adapters`,
`driven_adapters`; Kanten `ports_outbound→domain`, `driven_adapters→domain`,
`driven_adapters→ports_outbound`; `composition_root: ["src/app/main.py"]`; `exclude: ["tests/**"]`;
Root `src/app`.

```text
A  driven/store.py importiert ports.outbound.notifier.Notifier (erlaubte Kante)   0 Befund(e)                              EXIT=0
B  domain/greeting.py importiert ports.outbound.notifier.Notifier (keine Kante)   core-impurity                            EXIT=1
C  driving/cli.py importiert driven.store.Store (keine Kante)                      lateral-adapter                           EXIT=1
D  wie 1, aber ohne jede __init__.py                                               core-impurity                             EXIT=1
E  main.py (Composition Root) importiert driven.store und domain.greeting         0 Befund(e) (exempt)                      EXIT=0
```

```text
5. Installationszeit, python:3.14.8-slim, --no-cache, Einzelmessung je Werkzeug:
   pip install -r requirements-dev.txt                        → 4,35 s
   pip install uv==0.13.1, dann uv pip install --system -r …  → 0,89 s (nur der zweite Schritt)
6. flake8 7.4.1 + black 26.10.1 + mypy + pytest (isort ungenutzt): `flake8 --max-line-length 100 src tests &&
   black --check src tests && mypy && python -m pytest` auf demselben Gerüst → 1 passed, grün.
```

Nicht gemessen: ein `poetry`-/Backend-Lauf; `unittest`; pyright; Alpine; flake8+black rot; die Probe über
dem vollständigen `hexslice`-Skelett (nur Vier-Schichten-Probe); die Laufzeit der Python-Stufe in
`make full-smoke`. Das Probe-Gerüst liegt nicht als Datei im Repo; die Listen oben sind seine
vollständige Beschreibung.

## Re-Evaluierungs-Trigger

1. Das Gegenbeispiel aus der Fitness Function färbt am `hexslice`-Ziel nicht rot → zuerst die Config
   gegen a-check prüfen: meldet der Lauf „0 von N Import-Symbolen lösen auf", ist es ein Config-Fehler
   (Festlegung 5). Erst wenn eine Config, die Importe auflöst, grün bleibt → Anforderung an a-check.
2. `pytest`, `ruff` oder `mypy` laufen mit dem gepinnten Python-Tag und den gepinnten Versionen nicht
   grün, oder ein Pin-Zug an einer der drei Versionen färbt das Gerüst → Festlegung 2 und 3.
3. Ein Adopter verlangt `hexagonal` → Folge-ADR mit Pfaden und Auflösung; ein Build-Backend/Paket-
   Metadaten oder `uv`/`poetry` → Folge-ADR; Multi-Projekt → mit CR an
   [`LH-FA-04`](../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4).
4. Der a-check-Pin extrahiert relative Importe oder dynamische Importe, oder verschärft die Grenze →
   Festlegung 5 (die `TID252`-Regel entfiele dann nicht automatisch).
5. Ein Python-Freshness-Werkzeug entsteht → Konsequenz „Freshness" entfällt.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-10-17 | Proposed | `slice-python-skelett` |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0095` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
