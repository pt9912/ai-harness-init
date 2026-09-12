# `make doc-tracked` — sagt, ob ein verlinktes Ziel im git-Index steht

## Vertrag

Advisory-Ziel (nicht in `make gates`), fährt d-check mit `--enable tracked` über den ganzen
Baum. Prüft, ob ein Markdown-Link auf eine Datei zeigt, die auf der Platte liegt, aber nicht im
git-Index steht — genau das, was auf einem frischen Klon fehlen würde.

## Grenze — was das Grün nicht abdeckt

**Was `doc-tracked` und `doc-structure` ohne eigenen `.d-check.yml`-Block wirklich prüfen**
(slice-217, Antwort auf [`welle-13`](../../docs/plan/planning/welle-13-regeln-bekommen-ihren-sensor.md)
§3): Jedes `docs?-*`-Ziel in [`d-check.mk`](../../d-check.mk) fällt in eine von vier Klassen,
**abgeleitet** aus Ziel-Zeile, Rezept-Zeile und der Frage, ob [`.d-check.yml`](../../.d-check.yml)
für das per `--enable` zugeschaltete Modul einen Top-Level-Block führt — kein Zielname steht
dafür hier aufgezählt:

```sh
awk '
  /^docs?-[a-z-]+:.*## /{z=$1; sub(":","",z); next}
  z && /^\t/ {
    m=""; for(i=1;i<=NF;i++) if($i=="--enable") m=$(i+1)
    if (m!="")            k = (system("grep -qE \"^" m ":\" .d-check.yml")==0 ? "B" : "C")
    else if ($0 ~ /--help/)      k="D"
    else if ($0 !~ /docker run/) k="D"
    else                         k="A"
    printf "%-14s %-10s %s\n", z, (m==""?"-":m), k; z=""
  }' d-check.mk
```

liefert **13** Zeilen (`grep -cE '^docs?-[a-z-]+:.*## ' d-check.mk`, kein Erwartungswert — wandert
mit [`d-check.mk`](../../d-check.mk)) in vier Klassen: **A** — kein `--enable`, fährt d-check über
dem ganzen Baum (`docs-check`, `doc-doctor`, `doc-repair`, `doc-trace`, `doc-complete`); **B** —
ein Modul ist zugeschaltet **und** [`.d-check.yml`](../../.d-check.yml) führt dafür einen
Top-Level-Block (`doc-immutable`/`vcs`, `doc-commits`/`commits`, `doc-planning`/`planning`,
`doc-targets`/`targets`); **C** — ein Modul ist zugeschaltet, **kein** Block dafür
(`doc-tracked`/`tracked`, `doc-structure`/`structure`); **D** — kein Docker-Lauf über dem Baum
(`doc-usage` fährt nur `--help`, `doc-help` grep't `$(MAKEFILE_LIST)`, kein Docker) — die Frage
nach einem Prüfbereich ist für D sinnlos, und das steht hier, statt stillschweigend zu fehlen.
`doc-commits` ist der eine B-Fall mit einer eigenen Geschichte: sein `commits:`-Block existiert,
das Ziel bricht trotzdem an jedem `--range`-Lauf ab — Beleg und Träger-Entscheidung stehen im
Sensor [`commit-msg-check`](commit-msg-check.md), hier nur der Zeiger.

**Die Gegenprobe je C-Ziel — und warum die zwei Antworten verschieden ausfallen.** Ein
`0 Befund(e)`-Lauf ist mit *aktiv und sauber* ebenso verträglich wie mit *inert*; ob ein Ziel ohne
Block wirklich nichts prüft, ist an einem eingesetzten Defekt zu messen, nicht an der Abwesenheit
eines Blocks allein. Gemessen an einer Kopie außerhalb des Repos, netzlos, Mount `:ro`, Digest aus
[`d-check.mk`](../../d-check.mk):

*`doc-tracked` — nicht inert.* Ein Markdown-Link auf eine Datei, die auf der Platte liegt, aber
nicht im git-Index steht (exakt das, was das Modul laut `--print-config` sucht: „fehlt auf jedem
frischen Klon"), wird gemeldet — **mit und ohne** `tracked:`-Block byte-gleich, weil der
eingebaute Default (`exempt-targets: []`) schon ohne Block gilt:

```sh
echo "Sonde" > docs/probe-untracked-ziel.md
printf '\n[Sonde](docs/probe-untracked-ziel.md)\n' >> README.md
docker run --rm --network none -v "$PWD":/repo:ro "$DCHECK_REF" --enable tracked --disable …
# ohne tracked:-Block:  README.md:101 … target-untracked …  ->  1145 Datei(en) geprüft, 1 Befund(e)
# mit `tracked: {exempt-targets: []}` ergänzt:  dieselbe Zeile  ->  1145 Datei(en) geprüft, 1 Befund(e)
```

**Die C-Klasse ist für `doc-tracked` eine rein syntaktische Aussage** (kein `tracked:`-Schlüssel in
[`.d-check.yml`](../../.d-check.yml)) — sie behauptet keinen fehlenden Prüfbereich: Das Modul braucht
für seine Kernfrage (git-Index-Status eines aufgelösten Ziels) keine Konfiguration über den
eingebauten Default hinaus.

## Bindung

Kuratiert in `exempt-targets` (`.d-check.yml` `targets:`-Block) — kein Gate-Versprechen. Siehe
auch [`make doc-structure`](doc-structure.md) für die inerte Gegenprobe derselben
Klassifikation.
