# Verifikation — slice-d-check-pin-liest-fremde-packs-und-loest-jede-range

**Rolle:** Verifier (Modul 11). **Datum:** 2026-09-17. **Frischer Kontext**, kein Self-Verify.

**Gegenstand:** `docs/plan/planning/done/slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.md`,
Stand `93a0d10f`. **Grundlage:** DoD, Plan und die kanonischen Quellen — **nicht** die
Review-Reports.

**Geprüfter Umsetzungs-Stand:** `55c2e641`, `e171fea9`, `9f57c668`, `071803f0`, `59cc6eee`,
`b103adff`; Plan-Änderung `e4b44dd3`; Architect-Commits `66dcc433`, `51cad34c`.

## Verdikt je DoD-Punkt

| DoD | Verdikt | Tragender Beleg (eigener Lauf) |
|---|---|---|
| 1 — Pin, Fragment, Adaptions-Eintrag | **erfüllt** | Digest aus lokalem Bild, zwei Kopplungs-`diff` still, `--print-mk`-Diff 6 Hunks, `make full-smoke` Exit 0, Rot gesehen |
| 2 — Bilanz und vier Messungen | **erfüllt** | Messung 1 und Gegenprobe eigenständig reproduziert, Methode nach [`MR-063`](../../harness/conventions.md#mr-063) und Angabe nach [`MR-065`](../../harness/conventions.md#mr-065) vorhanden |
| 3 — Grenzen und Werkzeug-Aussagen | **erfüllt** | Zählkommando nennt keine Zeile mit `v0.76.1` als geltendem Stand; `history-range-guard.md` §Grenze an beiden Punkten nachgezogen und im Lauf bestätigt |
| `make gates` grün | **erfüllt** | eigener Lauf, Exit 0 |
| Review-Report liegt vor | **erfüllt** | zwei Runden unter `docs/reviews/` |
| Doku-Update | **erfüllt** | `make e2e-abdeckung` erzeugt die committete Datei byte-gleich |

Die Closure-Zeilen (Closure-Notiz, Register, Risiko-Ausgänge, Paarungen) sind nicht Gegenstand
dieser Prüfung; die Belege für die Risiko-Ausgänge stehen unten.

## DoD 1 — Pin, Fragment, Adaptions-Eintrag

**Pin an beiden gekoppelten Stellen, Digest belegt.** `d-check.mk` Zeile 75/76 und
`internal/emit/emit.go` Zeile 32/33 tragen `ghcr.io/pt9912/d-check:v0.76.3` und
`sha256:2f2f24601251d6b6c1dda13c4a847039a88abfd7e2de508d64180be97bfd2af0`. Netzloser Beleg aus dem
lokalen Bild:

```sh
docker image inspect ghcr.io/pt9912/d-check:v0.76.3 --format '{{join .RepoDigests "\n"}}'
# ghcr.io/pt9912/d-check@sha256:2f2f24601251d6b6c1dda13c4a847039a88abfd7e2de508d64180be97bfd2af0
```

**Die zwei `--disable`-Listen sind nach Namen gekoppelt.** Beide Kopplungs-Kommandos geben nichts
aus und enden mit 0 — das aus DoD 1 (`regelwerk-check` gegen die `modules:`-Zeile) und das aus dem
Makefile-Kopf (`doc-commits` gegen `commit-msg-check`). Die `modules:`-Zeile führt neun Namen,
`regelwerk-check` schaltet genau diese neun ab; `structure` ist mit `071803f0` nachgezogen.

**Handgriffe gegen eine frische `--print-mk`-Ausgabe.** Eigener Lauf über den gepinnten Digest,
netzlos:

```sh
diff <(docker run --rm --network none -v "$PWD:/repo:ro" \
        ghcr.io/pt9912/d-check@sha256:2f2f2460… --print-mk) d-check.mk | grep -c '^[0-9]'
# 6
```

Die sechs Hunks decken die fünf Handgriffe aus [`MR-010`](../../harness/conventions.md#mr-010)
Setzung 1 und [`MR-062`](../../harness/conventions.md#mr-062): adaptierter Kopf, `doc-check` →
`docs-check`, `DCHECK_DIGEST` gepinnt (frisch leer), `doc-help`s Grep auf `docs?-`, und die Marke
mit ihren zwei Hunks. `grep -c 'keinen eigenen Block' d-check.mk` → **3** und
`grep -c '^structure:' .d-check.yml` → **1** — beides wie im Eintrag behauptet, beides kein
Erwartungswert.

**Der Adaptions-Eintrag steht.** `MR-066` liegt als Datei in `harness/conventions/`, trägt seine
Index-Zeile mit beiden Ankern und ist in der Zeile `d-check:` des Abschnitts §Baseline genannt.

**`make full-smoke` grün, selbst gefahren:** Exit 0, keine einzige `full-smoke: FEHLER`-Zeile. Die
Stufe meldet beide Hälften mit ihrem Aufbau:

```
full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen
            (doc-immutable, flachen Klon) …
full-smoke: OHNE den Waechter meldet dasselbe Modul ueber derselben leeren Range gruen
            (doc-commits, vollstaendigen Klon) …
```

**Rot gesehen** ([`AGENTS.md`](../../AGENTS.md) §3.6). In einer Kopie im Scratchpad, nur
`d-check.mk` auf `v0.76.1` zurückgesetzt, `internal/emit/emit.go` unberührt (`git status --porcelain`
→ genau `M d-check.mk`), `make test-go` → Exit 2. Die **gelesene** Meldung:

```
--- FAIL: TestDefaultDigest_MatchesCanonical (0.00s)
    emit_test.go:73: emit.DefaultDigest "sha256:2f2f2460…" != kanonische Pin-Quelle
                     "sha256:1470ecdc…" (Drift)
--- FAIL: TestDefaultImage_MatchesCanonical (0.00s)
    emit_test.go:82: emit.DefaultImage "ghcr.io/pt9912/d-check:v0.76.3" != kanonische Quelle
                     "ghcr.io/pt9912/d-check:v0.76.1" (Tag-Drift)
```

Beide Meldungen nennen die behauptete Ursache — die Entkopplung der zwei Pin-Stellen —, nicht
irgendeine. Der Wächter greift aus dem richtigen Grund.

## DoD 2 — Bilanz und vier Messungen

**Methode nach [`MR-063`](../../harness/conventions.md#mr-063).** Der Eintrag führt alle
verlangten Stücke: Kopie per `git archive`, Marker-Entwertung nur in regulären Dateien mit der
Symlink-Kontrolle (**10** Symlinks vorher und nachher, **0** reguläre Dateien unter
`.claude/rules/`), je aktivem Modul eine Basis auf Nicht-Null-Befundmenge, beide Digests je mit dem
Fragment ihres Standes (`d-check.mk` aus `55c2e641^` für den alten Stand), Befundzeilen ab drei
Spalten. Die Basis deckt **neun** Module — `structure` über `section-open-tasks-marker-missing` und
`section-missing`, also eine Basis mehr als die Acht-Modul-Tabelle in
[`MR-063`](../../harness/conventions.md#mr-063). Die Befundmengen sind unter beiden Digests
identisch (`diff` leer, gleiche Codes mit gleichen Häufigkeiten, gleiche Spaltenzahl). Schluss
*keine Senkung* ist damit getragen; [`AGENTS.md`](../../AGENTS.md) §3.5 ist nicht berührt, weil
nichts aktiviert und keine Schwelle gesenkt wird.

**Angabe nach [`MR-065`](../../harness/conventions.md#mr-065) Setzung 1** steht bei jedem
history-lesenden Lauf: Pack-Namen, Alternates und lose Objekte zum Laufzeitpunkt.

**Messung 1 eigenständig reproduziert** — der Dogfood-Fall mit `loose-*.pack`. Aufbau und Angabe
meines Laufs:

```
ls .git/objects/pack/   -> loose-ddd93102….idx | .pack | .rev   (kein pack-*)
.git/objects/info/alternates -> Datei fehlt (keine Alternates)
git count-objects -v    -> count: 0 | in-pack: 26708 | packs: 1
git cat-file -t 8ae647cc -> commit
```

| Lauf | `v0.76.1` | `v0.76.3` |
|---|---|---|
| `make adr-immutable RANGE=8ae647cc~1..8ae647cc` | `error: Range-Basis "8ae647cc~1" nicht auflösbar: reference not found`, Exit 2 | `1621 Datei(en) geprüft, 0 Befund(e)`, Exit 0 |
| `make doc-commits RANGE=c414119b..ebb76b3d` | `error: Range-Basis "c414119b" nicht auflösbar: reference not found`, Exit 2 | 1 × `commit-untraceable` auf `7c1f228`, Exit 2 (Befund, kein Abbruch) |

Das ist die Tabelle des Eintrags, Zelle für Zelle. `in-pack: 26708` gegen die dort genannten
`26634` ist die erwartete Wanderung — der Eintrag erklärt beide Zahlen ausdrücklich zu
Nicht-Erwartungswerten.

**Gegenprobe reproduziert.** Dieselbe Kopie ohne die `.idx` ihres Packs: `git cat-file -t 8ae647cc`
→ `fatal: Not a valid object name 8ae647cc`, und `make doc-immutable RANGE=8ae647cc~1..8ae647cc`
unter `v0.76.3` bricht weiter mit derselben Meldung und Exit 2 ab. Der Abbruch bei einer wirklich
unauflösbaren Objekt-Menge steht.

**Messung 2, 3 und die Alternates-Messung** habe ich nicht selbst nachgefahren (Budget). Sie sind
im Eintrag mit Aufruf, Gegen-Stand und gelesener Ausgabe geführt; die für Risiko 4 entscheidende
Eigenschaft — der Aufruf läuft am Vorlauf-Wächter vorbei — steht dort ausdrücklich und ist an der
genannten Aufrufform ablesbar.

## DoD 3 — Grenzen und Werkzeug-Aussagen

**Das Zählkommando aus §1 des Plans** nennt zwölf Zeilen in vier Dateien. **Keine** davon führt
`v0.76.1` als geltenden Stand: jede ist entweder Mess-Operand eines Vergleichs
(`commit-msg-check.md`, `history-range-guard.md`, `doc-structure.md` Zeile 92) oder nennt Tag und
Digest der Messung (`docs-check.md`) oder datiert ausdrücklich
(`doc-structure.md` Zeile 38: *„der damals … gepinnte Digest; den lebenden Pin führt dieselbe
Datei"*). Das Rot-Kriterium von DoD 3 greift damit nicht;
[`MR-053`](../../harness/conventions.md#mr-053) Setzung 1 und 2 sind eingehalten.

**`harness/sensors/history-range-guard.md` §Grenze ist an beiden Punkten nachgezogen**, und beide
neuen Sätze stimmen an meinem eigenen Lauf:

- *Der Wächter fängt eine unauflösbare Basis selbst ab.* In einem Zwischenstand meines Aufbaus, in
  dem die Objekte fehlten, meldete er
  `history-range-guard: Range '8ae647cc~1..8ae647cc' ist NICHT aufloesbar (Basis fehlt im Klon?).`
  und beendete `make adr-immutable` mit 2, bevor ein Modul lief — genau wie der Text sagt, und
  damit ist die frühere Aussage *„deckt der Wächter nicht zusätzlich"* zu Recht gefallen.
- *Der Abbruch an Packs unter anderem Präfix ist am neuen Stand gemessen.* Bestätigt durch Messung
  1 oben.

**Für jeden Neu-Prüf-Fall steht im Eintrag, ob er eingetreten ist:** der Pack-Präfix-Fall aus
[`MR-064`](../../harness/conventions.md#mr-064) ist eingelöst und trägt seine Kopf-Marke; die
Alternates-Grenze aus [`MR-065`](../../harness/conventions.md#mr-065) ist am neuen Stand
nachgemessen und bleibt bestehen.

## `make gates`, Review, Doku

- **`make gates` grün**, eigener Lauf: Exit 0; `d-check: 1621 Datei(en) geprüft, 0 Befund(e)`,
  `baseline-verify: v6.9.0 OK — 54 Dateien`.
- **Review:** `docs/reviews/2026-09-17-slice-d-check-pin-liest-fremde-packs-und-loest-jede-range.md`
  und `…-runde-2.md` liegen vor.
- **Doku-Update:** `make e2e-abdeckung` erzeugt die committete `docs/user/e2e-abdeckung.md`
  unverändert (`git status --porcelain` danach leer). Gate-Namen sind gleich geblieben, der
  Gate-Index brauchte keinen Nachzug.

## Plan gegen Code

**Zwei berührte Dateien führt §3 nach der Plan-Änderung `e4b44dd3` nicht:**

| Datei | Commit | Änderung | Klasse |
|---|---|---|---|
| `.github/workflows/ci.yml` | `e171fea9` | Kopfkommentar: Messstand `v0.76.1` → `v0.76.3` | DoD 3 |
| `harness/sensors/doc-structure.md` | `e171fea9` | zwei Werkzeug-Aussagen datiert bzw. am neuen Stand gemessen | DoD 3 |

Beide fallen sachlich unter DoD 3 (*jede Werkzeug-Aussage mit `v0.76.1` als Messstand*), beide sind
reine Aussage-Nachzüge ohne Verhaltensänderung — aber die Tabelle in §3 nennt für DoD 3 nur
`history-range-guard.md`, `docs-check.md`, `commit-msg-check.md`, `.d-check.yml` und `AGENTS.md`.
Der Plan wurde mit `e4b44dd3` angefasst, ohne die zwei nachzutragen.

**Die Abgrenzung in §1 ist unverletzt.** Nachgemessen: kein Modul aktiviert und keine Regel der
`.d-check.yml` geändert (`e171fea9` berührt dort nur den Kommentar am `commits`-Block); die
emittierte Startkonfiguration bekommt keinen `vcs:`- oder `commits:`-Block; der Objektspeicher des
Arbeitsklons ist unberührt (alle Messungen laufen an Wegwerf-Kopien); die Alternates-Lücke ist
gemessen und datiert, nicht geschlossen; eine Regel für die Klasse *Werkzeug-Lücke* setzt der Slice
nicht.

## ADR-/MR-Konformität

| Quelle | Verdikt | Beleg |
|---|---|---|
| [`MR-010`](../../harness/conventions.md#mr-010) Setzung 1 | konform | Handgriffe im 6-Hunk-Diff belegt |
| [`MR-025`](../../harness/conventions.md#mr-025) | konform | jede Zahl in `MR-066` trägt ihr Kommando, Nicht-Erwartungswerte sind als solche ausgewiesen |
| [`MR-032`](../../harness/conventions.md#mr-032) | konform | Kopf-Marken an `MR-064` und `MR-065`, in derselben Änderung gesetzt; die Ausnahme aus Setzung 4 ist begründet verworfen |
| [`MR-046`](../../harness/conventions.md#mr-046) | konform | beide Dateien bleiben in `harness/conventions/`, `conventions/done/` unverändert bei vier Einträgen |
| [`MR-053`](../../harness/conventions.md#mr-053) | konform | `MR-066` nennt den Pin als Mess-Operand, nicht als Geltungs-Aussage; Verweis auf §Baseline als lebenden Ort |
| [`MR-060`](../../harness/conventions.md#mr-060) | konform | `MR-066` ist neu und trägt die Pflichtfelder; an `MR-064`/`MR-065` wird nichts nachgetragen |
| [`MR-062`](../../harness/conventions.md#mr-062) | konform | Marke vorhanden, ihre Menge gemessen |
| [`MR-063`](../../harness/conventions.md#mr-063) | konform | Methode vollständig angewandt, neun Basen, Symlinks stehen |
| [`MR-065`](../../harness/conventions.md#mr-065) Setzung 1 | konform | Angabe bei jedem history-lesenden Lauf |
| [`AGENTS.md`](../../AGENTS.md) §3.5 | nicht berührt | keine Aktivierung, keine Schwellen-Senkung |
| [`AGENTS.md`](../../AGENTS.md) §3.6 | konform | Rot gesehen und gelesen, siehe DoD 1 |
| [`AGENTS.md`](../../AGENTS.md) §3.8 | konform | `66dcc433` und `51cad34c` berühren nur Architect-Artefakte und nennen die Rolle |

## Befunde

**V-1 (MEDIUM) — Die Aufbau-Anleitung für Messung 1 in `MR-066` ist nicht literal reproduzierbar.**
Der Eintrag beschreibt den Aufbau als *„`git clone --no-local`, Pack per `git unpack-objects`
ausgepackt und entfernt, dann `git maintenance run --task=loose-objects`"*. Wörtlich ausgeführt
entsteht dieser Zustand **nicht**, und zwar aus zwei Gründen, die ich beide selbst getroffen habe:

1. `git unpack-objects` überspringt Objekte, die bereits im Objektspeicher liegen, und kennt in
   dieser git-Fassung kein `-f` (`usage: git unpack-objects [-n] [-q] [-r] [--strict]`). Das Pack
   muss **vor** dem Auspacken aus `.git/objects/pack/` heraus bewegt werden; sonst entsteht ein
   Klon mit `count: 0`, `in-pack: 0` — ganz ohne Objekte.
2. Ohne ein anschließendes `git prune-packed` bleiben die losen Objekte **neben** dem
   `loose-*.pack` liegen (`count: 26708`). In diesem Zustand liest auch `v0.76.1` die Range
   anstandslos — mein erster Gegen-Stand-Lauf meldete dort `0 Befund(e)`, Exit 0. Die tragende
   Eigenschaft des Aufbaus ist `count: 0`, und die nennt der Eintrag zwar in seiner Angabe, aber
   nicht als Schritt.

**Die Messung selbst ist damit nicht in Frage gestellt** — mit beiden ergänzten Schritten ist sie
Zelle für Zelle bestätigt. In Frage steht die **Nachvollziehbarkeit** des Belegs
([`LH-QA-02`](../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)), und sie wiegt hier schwerer
als sonst: Der Eintrag ist gepusht und append-only, seine Anleitung ist der einzige Träger des
Aufbaus, und ein späterer Sprung wiederholt die Messung nach genau diesem Text. Adresse für die
Behebung ist kein Nachschreiben des Rumpfs, sondern ein Satz im nächsten Pin-Eintrag oder ein
eigener Vorgang — die Entscheidung liegt beim Planner.

**V-2 (LOW) — Plan-vs-Code-Delta: zwei Dateien außerhalb von §3.** `.github/workflows/ci.yml` und
`harness/sensors/doc-structure.md` sind berührt, ohne in der Tabelle zu stehen (Einzelheiten oben).
Beide liegen inhaltlich in DoD 3 und verletzen keine Abgrenzung; der Befund ist die
**Unvollständigkeit des Plans**, nicht die Änderung. Da `e4b44dd3` den Plan ohnehin angefasst hat,
war der Nachtrag dort möglich.

**V-3 (INFO) — Zwei der vier Messungen sind unbestätigt geblieben.** Messung 2 (frisch emittiertes
Ziel), Messung 3 und die Alternates-Messung habe ich nicht selbst gefahren. Sie sind im Eintrag
vollständig mit Aufruf, Gegen-Stand und Ausgabe geführt; ich bestätige sie **nicht**, ich
widerspreche ihnen auch nicht. Wer sie braucht, fährt sie nach.

**Negativbefund:** Keine DoD-Verletzung. Kein Punkt der DoD ist behauptet und unbelegt; die drei
Liefer-Punkte sind an eigenen Läufen bestätigt.

## Belege für die Risiko-Ausgänge (§6)

| # | Risiko | Beleg aus dieser Verifikation | Ausgang, den der Beleg trägt |
|---|---|---|---|
| 1 | `loose-*.pack` an einer Kopie nicht herstellbar | eigener Aufbau erzeugt ihn: `loose-ddd93102….pack` mit passender `.idx`, `count: 0`, keine Alternates | **entfallen** — herstellbar; die Anleitung dazu trägt Befund V-1 |
| 2 | weiterer Release vor dem Start | `MR-066` nennt `v0.76.0`–`v0.76.3` am Klon des Werkzeugs; Titel und §1 führen `v0.76.3`, und der Pin steht dort. **Grenze:** ob upstream inzwischen ein `v0.76.4` liegt, habe ich nicht geprüft — das braucht den Werkzeug-Klon | **entfallen**, unter dieser Grenze |
| 3 | Norm-Eintrag friert vor seinem Review ein | `51cad34c` ändert `MR-066` und `MR-064` **nach** Review-Runde 1 (`60b4f42b`) und **vor** Runde 2 (`93a0d10f`); die Korrektur war also noch möglich | **entfallen** |
| 4 | Ziel-Messung misst den Wächter statt des Werkzeugs | `MR-066` Messung 2 nennt den Aufruf ausdrücklich am Wächter vorbei (`docker run` aus dem Rezept des Ziel-Fragments) und stellt `v0.76.1` mit `0 Befund(e)`, Exit 0 daneben — ein Wächter-Rot sähe an beiden Ständen gleich aus | **entfallen** |
| 5 | Klasse *blind und grün* an keinem Aufbau mehr herstellbar | `make full-smoke` Exit 0, und die Stufe nennt beide Aufbauten einzeln: `doc-immutable` am flachen, `doc-commits` am vollständigen Klon | **entfallen** |

Das Urteil über die Ausgänge fällt der Planner; hier stehen die Belege.

## Was diese Verifikation nicht abdeckt

- Die drei nicht nachgefahrenen Messungen aus V-3.
- Die Strenge-Bilanz am Quellstand des Werkzeugs: Ich habe die Quell-Differenz nicht selbst
  gelesen — `/Development/d-check` ist für diesen Lauf nur lesend und wurde nicht angefasst.
- Die Closure-Zeilen der DoD (Notiz, Register, Paarungen, Risiko-Ausgänge als Eintrag).
