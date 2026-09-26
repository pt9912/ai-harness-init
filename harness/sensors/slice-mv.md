# `make slice-mv` — Lifecycle-Wechsel eines Slice inklusive seiner Verweise

## Vertrag

`make slice-mv SLICE=slice-<Kennung> TO=<open|next|in-progress|done>` bewegt einen Slice-Plan per
`git mv` und zieht seine Verweise nach ([`AGENTS.md`](../../AGENTS.md) §3.3, Antwort auf
`BEO-ALL/verweise-brechen-beim-ortswechsel`) — kein Gate, in keiner Prerequisite-Kette: es
bewegt, es prüft nicht ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Es setzt zwei getrennte Commits (Hard Rule 3.3): zuerst der reine Move
(kein Byte Inhalt geändert), danach — nur falls Verweise anfielen — der Inhalts-Nachzug als
zweiter Commit.

### Im gebootstrappten Ziel — Vertrag

Dieselbe Logik reist als emittiertes Werkzeug mit: das Skript liegt im Ziel unter
`tools/harness/slice-mv.sh`, das Fragment daneben unter
`harness/mk/slice-mv.mk` <!-- d-check:ignore (der Pfad entsteht erst im gebootstrappten Ziel) -->,
das der Root-Aggregator des Ziels per `include harness/mk/*.mk` einbindet — dieselbe
Layout-Adaption wie hier ([`MR-005`](../conventions.md#mr-005--harness-tools-unter-harnesstools-layout-adaption)).
Die Command-Vorlage des Ziels (`.claude/commands/implement-slice.md`) nennt den Aufruf
`make slice-mv SLICE=… TO=…` an den zwei Stellen, an denen sie den Lifecycle-Wechsel
vorschreibt. [`make full-smoke`](full-smoke.md) fährt die Kette Aggregator → Fragment →
abgelegtes Skript → `git`: es ruft `make slice-mv` im gebootstrappten Ziel auf. Frei ist die
**Datei**, über die der Adopter das Fragment einbindet, der Ziel-Name `slice-mv` dagegen nicht —
er kommt aus dem tool-eigenen Fragment, das jeder Bootstrap kanonisch neu schreibt, eine
Umbenennung wäre damit nicht von Dauer. **Diese Neuschrift hält kein Wächter:** sie ruht auf der
Emission — der E2E legt das Fragment an seinem Ort an, die Idempotenz-Prüfung des Ziels driftet
aber allein `Makefile` und die Feldliste, nicht dieses Fragment. Den **Text** der Anleitung hält
`make test-go` fest (`TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen`), die **Wirkung** der
Kette misst `make full-smoke`.

**Beide Richtungen, und der Move bleibt rein.** Im Ziel zieht das Werkzeug eingehende Verweise auf
die bewegte Datei nach und präfixlose Geschwister-Ziele **innerhalb** der bewegten Datei; der
Move-Commit trägt keine Inhaltsänderung, und fiel keine Änderung an, bleibt es beim einen Commit.
Gemessen wird das an einem echten Move: `make full-smoke` stellt im Ziel die Nachbar-Datei mit
Präfix-Verweis und ein verbliebenes Geschwister im Ausgangsverzeichnis her und liest danach beide
Ziele, den Move-Commit ohne Inhaltsänderung (`git show --numstat` auf ihn) und den Nachzug als
getrennten zweiten Commit — über einem Slice ohne jeden Verweis, dass der zweite Commit ausfällt.

**Was Politik ist und was Mechanik.** Die Pfade, die der eingehende Nachzug ausnimmt, sind im Ziel
**setzbar**: die Variable `SLICE_MV_AUSGENOMMENE_PFADE` steht an beiden Orten mit einer Vorgabe, in
je einer Form — das Fragment als Make-Zuweisung (`?=`), das Skript als `${…:-…}` beim Auslesen —,
und das Fragment reicht den Wert als Umgebung an das Werkzeug durch. Die zwei Werte sind Politik
des jeweiligen Repos, nicht Mechanik des Werkzeugs — ein Adopter mit anderer Politik setzt die
Variable, statt das Skript zu ändern, und die Ausnahmen wirken über die Funktion, die das Werkzeug
ausliest, nicht über eine zweite Liste im Ersetzungs-Aufruf. `make test-go` hält Markierung und
Durchreichung fest (`TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert`,
`TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch`); die Wirkung der Vorgabe liest
`make full-smoke` im Ziel — eine Datei unter `docs/plan/adr/` behält ihren Verweis auf den alten
Ort ([`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 2).

## Grenze — was das Grün nicht abdeckt

Zwei Richtungen: **eingehend** ersetzt jede Präfix-Form eines Verweises **auf** die bewegte
Datei, repo-weit außer `.harness/baseline/**` (unveränderter Fremdtext) und `docs/plan/adr/**`
(eine `Accepted`-ADR bekommt keinen Byte-Nachzug —
[`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2) —
`docs/plan/planning/done/**` **und** `docs/reviews/**` sind **nicht** ausgenommen, ihre
Verweise sind reale, von `docs-check` geprüfte Links. In `done/` gilt der Nachzug in jeder Form;
unter `docs/reviews/**` ersetzt er die Adresse **nur als Ziel eines Markdown-Links**
(unmittelbar hinter `](`, bis `)` oder `#`) — ein Pfad im reinen Code-Span, als Operand in einem
Kommando, im Code-Block und im Fließtext bleibt Byte für Byte
([`ADR-0070`](../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Festlegung 1). Dazu ersetzt es **eingehend** den
präfixlosen Markdown-Link auf die bewegte Datei, auch mit Anker, in den getrackten Dateien, die flach
im Ausgangsverzeichnis liegen: er bekommt `../<neues-verzeichnis>/` vorangestellt, unter derselben
Ausnahmeliste. **Ausgehend** hängt präfixlosen Zielen
**innerhalb** der bewegten Datei, die einen im alten Verzeichnis verbliebenen
Geschwister-Slice referenzieren, `../<altes-verzeichnis>/` an — eine nummerierte Kennung
(`slice-NNN…`) trifft das Fundmuster ebenso wie eine benannte (`slice-<slug>`, ein Slug aus
Kleinbuchstaben, Ziffern und Bindestrich).

Fünf gemessene Grenzen (Skriptkopf `harness/tools/slice-mv.sh`): es zieht Pfade nach, keine
Zustandssätze; Welle-Plan-Dateien (Tiefenwechsel beim Closure-Move) bleiben außen vor; die
präfixlose Eingehend-Ersetzung erkennt allein den Markdown-Link in flachen Geschwistern und liest
kein Markdown — eine andere Schreibweise desselben Verweises (ein Link mit vorangestelltem Punkt-Segment,
ein Link in spitzen Klammern, eine Referenz-Definition) bleibt stehen, und steht die Link-Syntax
selbst mit genau diesem Namen in einem Code-Span oder Code-Block, wird sie mitersetzt; und die
zweite Namensform
aus [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — das Präfix eines vorhandenen Ankers (`LH-*`, `ADR-*`, `CO-*`), in diesem Repo
großgeschrieben — trifft die Zeichenklasse des Fundmusters nicht; und die Form-Regel unter
`docs/reviews/**` liest ebenfalls kein Markdown: Link-Syntax, die als Zitat in einem Code-Span
steht, wird mitersetzt. Diese Span-Hälfte bindet ein Fall in `test/slice-mv.bats`; für das Zitat
in einem Code-Block bindet kein Fall die Grenze, und die Referenz-Definition `[name]: ziel` ist
nicht Teil der Regel — beides benannte Lücken
([`ADR-0070`](../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Festlegung 1, Trigger 6 und 7). Ebenso außerhalb der Regel liegen ein Link mit Titel
(`](ziel "titel")`) und die Spitzklammer-Form (`](<ziel>)`): die Adresse endet dort nicht
unmittelbar an `)` oder `#`, der Nachzug lässt sie stehen — laut, nicht still: ein unterbliebener
Nachzug färbt `make docs-check` mit `target-missing` (gefahren an einem Report mit je einem Link
in den drei Formen, alle drei auf einen nicht vorhandenen Pfad). Die Regel besteht, solange `.d-check.yml` unter `codepaths`
`docs/reviews/**` ausnimmt (Trigger 1); ein Kopplungs-Test dafür führt dieses Werkzeug noch nicht.

**Die präfixlose Ersetzung ist ohne Repository gedeckt:** `test/slice-mv.bats` ruft sie in beiden
Fassungen auf und hält den ganzen Dateiinhalt einer Probe fest — die ersetzten Links, dazu
unverändert einen gleichnamigen Code-Span, einen Tree-Operanden, einen Präfix-Verweis und einen
längeren Namen mit demselben Anfang.
`test/mutations/363-slice-mv-eingehend-verliert-geschwister-ersetzung.sh` nimmt ihr das `sed` und
färbt diesen Fall rot. Welche Dateien `main()` ihr übergibt, fährt keine bats-Stufe; das misst die
Tabelle unter §Kanten.

**Die Form-Regel unter `docs/reviews/` ist in zwei Stufen gedeckt.** `test/slice-mv.bats` ruft
`rewrite_incoming_nach_baum` (den Zweig je Baum) und `rewrite_incoming_links_in_file` (die Regel
selbst) in der Dogfood-Fassung auf: eine Datei unter `docs/reviews/` mit dem Link und den vier
Nicht-Link-Formen (reiner Pfad-Span, Operand, Code-Block, Fließtext) hält den ganzen
Dateiinhalt fest, eine Datei unter `done/` denselben Bestand mit jeder Form nachgezogen.
`TestSliceMvEchtSchreibtInReportsNurDieLinkForm` (`make test-go`) fährt `main()` als echten Prozess
über dieselbe Probe. Die Fälle `test/mutations/459-slice-mv-reports-verlieren-die-form-regel.sh`
(Form-Regel entfällt), `460-slice-mv-reports-verlieren-den-link-nachzug.sh` (Link-Nachzug
entfällt), `461-slice-mv-form-regel-greift-in-done.sh` (Regel auf `done/` ausgedehnt) und
`462-slice-mv-main-umgeht-den-pfad-zweig.sh` (`main()` ruft den Zweig nicht) färben je den Test
rot, der ihn bindet; `466-slice-mv-link-regel-ueberquert-die-link-grenze.sh` färbt den Fall mit
mehreren Links in einer Zeile, den kein Fall mit einem Link je Zeile ersetzt.

**Scheitert die Ersetzung, bricht der Lauf ab und die Datei bleibt, wie sie war.** `psed_i` schreibt
nur zurück, wenn der `sed` gelungen ist, und endet bei einem Ausfall des `sed` oder des
Zurückschreibens mit Status 2 — explizit, nicht über `set -e`, das unter einem `||` im
Funktionsrumpf nicht gilt; `rewrite_incoming_nach_baum` reicht die 2 weiter, und `main()` bricht
darauf mit einer Meldung ab (der Move-Commit steht, der Nachzug ist nicht committet). Gedeckt ist
das in zwei Stufen: drei Fälle in `test/slice-mv.bats` lassen `sed` bzw. `cat` per PATH-Wrapper
scheitern und lesen Status und Dateiinhalt (das Image läuft als root, ein Dateimodus schiede als
Ausfall aus), und `TestSliceMvEchtBrichtBeiGescheiterterErsetzungAb` (`make test-go`) fährt
`main()` als echten Prozess. Die Fälle `463-slice-mv-psed-i-schreibt-nach-gescheitertem-sed.sh`,
`464-slice-mv-psed-i-verschweigt-ein-gescheitertes-zurueckschreiben.sh` und
`465-slice-mv-main-uebergeht-den-gescheiterten-nachzug.sh` in `test/mutations/` färben je den Test
rot, der es bindet. **Grenze:** die Zusage „Datei unverändert" gilt für den Ausfall des `sed`; bricht
das Zurückschreiben selbst mittendrin ab, ist die Datei nicht mehr, wie sie war. Die zwei
Ersetzungen `rewrite_incoming_bare_in_file` und `rewrite_outgoing_bare_in_file` reichen den Status
von `psed_i` nicht weiter — sie kürzen die Datei nicht mehr, melden aber Erfolg (gefahren für die
erste: Status 0, Zähler 1, Datei unverändert; für die zweite gelesen). Die emittierte Fassung
führt diese Härtung von `psed_i` nicht.

Details und Beleg stehen im Kopf von `harness/tools/slice-mv.sh`, Abschnitt BELEG.

### Kanten `open → done` und `next → done`

**Das Werkzeug führt beide Kanten aus, und die Form der Stilllegung liest es nicht.** `TO` prüft es
allein gegen die Lifecycle-Liste (`grep -n 'LIFECYCLE=' harness/tools/slice-mv.sh`); eine Sperre
für einen Übergang, der an `in-progress/` vorbeiführt, hat es nicht. Ob die Liefer-Punkte leer
sind und §7 die Zeile `Gegenstand:` trägt (`v6.9.0` ·
`.harness/baseline/v6.9.0/regelwerk/modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand
ein anderer übernimmt), prüft es nicht; den Inhalts-Commit vor dem Wechsel setzt der Aufrufer.

**Gemessen** am Blob `7e53bd7` von `harness/tools/slice-mv.sh`, dem Stand des Commits `7348e55c`
(`git rev-parse --short=7 7348e55c:harness/tools/slice-mv.sh`), an einer Kopie außerhalb des Repos ohne
`core.hooksPath`. Je Kante lief ein Slice, auf den Geschwister im Ausgangsverzeichnis präfixlos
verweisen und der daneben eingehende Präfix-Verweise trägt: aus `open/`
`slice-070-comment-claims-pruefbereich`, danach in derselben Kopie aus `next/`
`slice-103-traeger-waechter-decken-was-sie-sagen`. Einen Stilllegungs-Inhalt setzte die Kopie
nicht. Das Werkzeug committet selbst und braucht in der Kopie eine git-Identität; das Rezept setzt
sie lokal, damit es von keiner Host-Konfiguration abhängt:

```sh
git archive HEAD | tar -x -C <kopie>; cd <kopie>; git init -q
git config user.name <name>; git config user.email <adresse>   # lokal, nur in der Kopie
git add -A; git commit -qm basis
make slice-mv SLICE=<slice-in-open> TO=done; echo $?    # ebenso ein Slice aus next/
git show --numstat --format= -M HEAD~1                    # der Move-Commit
make docs-check
```

| Kante | Exit | Move-Commit | eingehend mit Präfix | ausgehend | präfixlos von Geschwistern |
|---|---|---|---|---|---|
| `open → done` | 0, `make` | reiner Rename, `0 0` | nachgezogen, im zweiten Commit | präfixlose Geschwister-Ziele tragen danach `../<altes-verzeichnis>/`, hier `open` | 6 Links in 5 Dateien nachgezogen, im zweiten Commit; kein `target-missing` |
| `next → done` | 0, `make` | reiner Rename, `0 0` | nachgezogen, im zweiten Commit | der Slice trägt kein präfixloses Ziel | 3 Links in 2 Dateien nachgezogen, im zweiten Commit; kein `target-missing` |

Die Link-Zahlen gibt das Werkzeug in seiner Zeile `eingehend:` aus; vor dem Wechsel zählt sie
`cat docs/plan/planning/<von>/*.md | grep -oE '\]\(<slice>\.md[)#]' | wc -l` — keine
Erwartungswerte. `make docs-check` blieb in der Kopie trotzdem rot (d-check Exit 1, `make` Exit 2),
mit einem einzigen Befund: `closure-note-thin` auf §7 des stillgelegten
`slice-070-comment-claims-pruefbereich`, dessen Stilllegungs-Inhalt die Kopie nicht setzt
([`docs-check.md`](docs-check.md) nennt, welche Form der Stilllegung das Modul liest).

**Rot gesehen, was der Nachzug trägt:** Derselbe `open → done`-Wechsel als bloßer `git mv` färbt
`make docs-check` an jedem eingehenden Präfix-Verweis und an den ausgehenden Zielen rot
(`target-missing`); über das Werkzeug fallen genau diese Befunde weg. Über den Blob `d1bda5b`
(`git rev-parse --short=7 0ea7e148:harness/tools/slice-mv.sh`), der
den präfixlosen Link nicht ersetzt, färbt dasselbe Paar Wechsel in einer zweiten Kopie genau die
präfixlosen Geschwister-Verweise rot: 6 × `target-missing` nach `open → done`, 9 nach dem
folgenden `next → done`. Die Kopien liefen ohne aktivierten `commit-msg`-Träger; was er mit den
zwei Commits des Werkzeugs tut, steht in [`harness/README.md`](../README.md) §Traceability.

**Wie viele präfixlose Verweise zwischen Geschwistern stehen,** zählt

```sh
P=docs/plan/planning; for d in open next; do n=0; for f in "$P/$d"/*.md; do
  for t in $(grep -ohE '\]\(slice-[0-9a-z][^)/#]*' "$f" | cut -c3-); do
    [ -f "$P/$d/$t" ] && n=$((n+1)); done; done; echo "$d: $n"; done
```

— kein Erwartungswert. Jeder davon bekommt beim Wechsel seines Ziels `../<neues-verzeichnis>/`
vorangestellt; welche Schreibweise die Ersetzung nicht erkennt, steht unter §Grenze.

**Kein Wächter hält die zwei Kanten.** `test/slice-mv.bats` ruft die Ersetzungs-Funktionen ohne
Repository auf. [`make full-smoke`](full-smoke.md) fährt im gebootstrappten Ziel den erfolgreichen
Wechsel mit `TO=next` und `TO=done` nur in den zwei Sperr-Fällen
(`grep -n 'slice-mv SLICE' harness/tools/full-smoke.sh`). Die Tabelle ist darum eine Messung und
keine bewachte Zusage: Wer `harness/tools/slice-mv.sh` ändert, misst sie neu;
ob sie zum Skript im Baum gehört, zeigt `git rev-parse --short=7 HEAD:harness/tools/slice-mv.sh` im
Vergleich mit dem Blob oben.

### Im gebootstrappten Ziel — Grenze

**Was die zwei Fassungen zusammenhält, und was nicht.** Gleich gehalten werden die
Funktionen der Liste `KERN` in `test/slice-mv.bats`: `make test-bats` vergleicht ihre Rümpfe zwischen
`harness/tools/slice-mv.sh` und der emittierten Fassung, weißraum-normalisiert — die eingehende
Ersetzung trifft damit im Ziel dieselben Präfix-Formen wie hier. Die Skript-Köpfe und alles
Übrige vergleicht er nicht — die zwei Dateien sind nicht als Ganzes gleich, und die Zusage gilt
den Ersetzungs-Regeln, nicht der Gleichheit. Die Form-Regel unter `docs/reviews/` liegt
außerhalb der Liste `KERN`: die emittierte Fassung führt sie nicht, ihr Nachzug ersetzt dort wie
zuvor jede Form (die Regel gilt für dieses Repo,
[`ADR-0070`](../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)). Die Zwei-Commit-Sequenz fährt diese Stufe nicht: der
Vergleich ruft die Funktionen ohne Repository auf, und der Ablauf mit `git` gehört ins Ziel, wo
`make full-smoke` ihn trägt. Gefahren wird die Kette über der `--lang-go`-Variante des
Bootstraps; dass Fragment und Skript auch sprachlos unter denselben Pfaden liegen, hält
`make test-go` (`TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette` für das Fragment,
`TestSliceMvWerkzeug_LiegtAusfuehrbarUndTraegtBeideRichtungen` für das Skript — beide über einen
Emit ohne Sprache).

## Ausgabe und Ausgänge

| Exit | Bedeutung |
|---|---|
| 0 | bewegt: `slice-mv ok: <datei>  <von>/ -> <nach>/`, darunter `Commit 1 (reiner Move)` und, nur wenn Verweise anfielen, `Commit 2 (Inhalt, …)` mit den zwei Zählern |
| 2 | eine Sperre griff; es ist nichts bewegt |

Die Tabelle nennt den Exit des Skripts. Scheitert nach dem `git mv` ein `git`-Schritt, etwa ein
Commit an einem Hook, endet das Skript mit dessen Exit (`set -euo pipefail`); der Move ist dann
schon ausgeführt. Über `make slice-mv` endet jeder Fehlschlag mit 2, eine Sperre ebenso wie ein
gescheiterter Commit — ob etwas bewegt ist, sagt dort nur die Meldung.

## Sperren

Alle vor dem ersten `git mv`; das Skript endet bei jeder mit 2, `make slice-mv` ebenso:

- Aufruf ohne `SLICE` oder `TO` → Aufruf-Hilfe → beide nennen.
- `slice-mv: Arbeitsbaum nicht sauber …` — das Skript committet selbst; eine unstaged oder gestagte
  Änderung landete sonst in einem seiner Commits → erst committen oder stashen.
- `slice-mv: '…' ist kein Lifecycle-Verzeichnis` → `open`, `next`, `in-progress` oder `done`.
- `slice-mv: '…' ist mehrdeutig` — die Angabe trifft zwei Dateien → die Kennung länger schreiben.
- `slice-mv: kein Slice '…' unter …` → die Kennung prüfen.
- `slice-mv: '…' liegt bereits in …/` → nichts zu tun.

### Im gebootstrappten Ziel — Sperren

**Fehlt eine Voraussetzung, bewegt es nichts.** Ein unsauberer Arbeitsbaum bricht den Aufruf vor
dem ersten `git mv` ab, mit einer Meldung, die den Fall nennt. Dieselbe Stufe stellt den Fall im
Ziel her und liest, dass der Aufruf ungleich null endet, den Grund nennt und die Datei an ihrem
alten Ort liegen lässt. Der zweite Fall dieser Klasse ist das fehlende Werkzeug: das Fragment
prüft seine Anwesenheit und bricht mit eigener Meldung ab, statt auf ein Programm zu zeigen, das
es nicht ablegt.

## Bindung

Kein Gate-Versprechen; Träger von [Modul 5](../../.harness/baseline/v6.9.0/regelwerk/modul-05-planning-harness.md#lifecycle-als-state-machine)
und `BEO-ALL/verweise-brechen-beim-ortswechsel`.
