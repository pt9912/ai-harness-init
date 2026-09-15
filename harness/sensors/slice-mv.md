# `make slice-mv` — Lifecycle-Wechsel eines Slice inklusive seiner Verweise

## Vertrag

`make slice-mv SLICE=slice-<Kennung> TO=<open|next|in-progress|done>` bewegt einen Slice-Plan per
`git mv` und zieht seine Verweise nach ([`AGENTS.md`](../../AGENTS.md) §3.3, Antwort auf
`BEO-ALL/verweise-brechen-beim-ortswechsel`) — kein Gate, in keiner Prerequisite-Kette: es
bewegt, es prüft nicht ([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
Voraussetzung ist ein sauberer Arbeitsbaum — das Skript committet selbst und bricht sonst vor
dem ersten `git mv` ab. Es setzt zwei getrennte Commits (Hard Rule 3.3): zuerst der reine Move
(kein Byte Inhalt geändert), danach — nur falls Verweise anfielen — der Inhalts-Nachzug als
zweiter Commit.

## Grenze — was das Grün nicht abdeckt

Zwei Richtungen: **eingehend** ersetzt jede Präfix-Form eines Verweises **auf** die bewegte
Datei, repo-weit außer `.harness/baseline/**` (unveränderter Fremdtext) und `docs/plan/adr/**`
(eine `Accepted`-ADR bekommt keinen Byte-Nachzug —
[`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) Festlegung 2) —
`docs/plan/planning/done/**` **und** `docs/reviews/**` sind **nicht** ausgenommen, ihre
Verweise sind reale, von `docs-check` geprüfte Links. **Ausgehend** hängt präfixlosen Zielen
**innerhalb** der bewegten Datei, die einen im alten Verzeichnis verbliebenen
Geschwister-Slice referenzieren, `../<altes-verzeichnis>/` an — eine nummerierte Kennung
(`slice-NNN…`) trifft das Fundmuster ebenso wie eine benannte (`slice-<slug>`, ein Slug aus
Kleinbuchstaben, Ziffern und Bindestrich).

Vier gemessene Grenzen (Skriptkopf `harness/tools/slice-mv.sh`): es zieht Pfade nach, keine
Zustandssätze; Welle-Plan-Dateien (Tiefenwechsel beim Closure-Move) bleiben außen vor; eine
präfixlose Referenz **auf** die bewegte Datei aus einer *anderen*, unbewegten Datei erkennt es
nicht — ihr fehlt das Verzeichnis-Literal, an dem die Ersetzung ankert; und die zweite Namensform
aus [`MR-057`](../conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — das Präfix eines vorhandenen Ankers (`LH-*`, `ADR-*`, `CO-*`), in diesem Repo
großgeschrieben — trifft die Zeichenklasse des Fundmusters nicht.

Details und Beleg stehen im Kopf von `harness/tools/slice-mv.sh`, Abschnitt BELEG.

## Bindung

Kein Gate-Versprechen; Träger von [Modul 5](../../.harness/baseline/v6.8.0/regelwerk/modul-05-planning-harness.md#lifecycle-als-state-machine)
und `BEO-ALL/verweise-brechen-beim-ortswechsel`.

## Im gebootstrappten Ziel

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
er kommt aus dem tool-eigenen Fragment, das jeder Bootstrap kanonisch neu schreibt. Den **Text**
der Anleitung hält `make test-go` fest (`TestSliceMvAnleitung_NenntDasWerkzeugAnDenZweiStellen`),
die **Wirkung** der Kette misst `make full-smoke`.

**Beide Richtungen, und der Move bleibt rein.** Im Ziel zieht das Werkzeug eingehende Verweise auf
die bewegte Datei nach und präfixlose Geschwister-Ziele **innerhalb** der bewegten Datei; der
Move-Commit trägt keine Inhaltsänderung, und fiel keine Änderung an, bleibt es beim einen Commit.
Gemessen wird das an einem echten Move: `make full-smoke` stellt im Ziel die Nachbar-Datei mit
Präfix-Verweis und ein verbliebenes Geschwister im Ausgangsverzeichnis her und liest danach beide
Ziele, den Move-Commit ohne Inhaltsänderung (`git show --numstat` auf ihn) und den Nachzug als
getrennten zweiten Commit — über einem Slice ohne jeden Verweis, dass der zweite Commit ausfällt.

**Fehlt eine Voraussetzung, bewegt es nichts.** Ein unsauberer Arbeitsbaum bricht den Aufruf vor
dem ersten `git mv` ab, mit einer Meldung, die den Fall nennt. Dieselbe Stufe stellt den Fall im
Ziel her und liest, dass der Aufruf ungleich null endet, den Grund nennt und die Datei an ihrem
alten Ort liegen lässt. Der zweite Fall dieser Klasse ist das fehlende Werkzeug: das Fragment
prüft seine Anwesenheit und bricht mit eigener Meldung ab, statt auf ein Programm zu zeigen, das
es nicht ablegt.

**Was Politik ist und was Mechanik.** Die Pfade, die der eingehende Nachzug ausnimmt, sind im Ziel
**setzbar**: Skriptkopf und Fragment führen sie als `SLICE_MV_AUSGENOMMENE_PFADE` mit einer Vorgabe
(`?=`) und reichen den Wert als Umgebung an das Werkzeug durch. Die zwei Werte sind Politik des
jeweiligen Repos, nicht Mechanik des Werkzeugs — ein Adopter mit anderer Politik setzt die
Variable, statt das Skript zu ändern, und die Ausnahmen wirken über die Funktion, die das Werkzeug
ausliest, nicht über eine zweite Liste im Ersetzungs-Aufruf. `make test-go` hält Markierung und
Durchreichung fest (`TestSliceMvAusnahmen_SindAlsRepoPolitikMarkiert`,
`TestSliceMvFragment_ReichtDieAusnahmenAlsUmgebungDurch`); die Wirkung der Vorgabe liest
`make full-smoke` im Ziel — eine Datei unter `docs/plan/adr/` behält ihren Verweis auf den alten
Ort ([`ADR-0042`](../../docs/plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)
Festlegung 2).

**Was die zwei Fassungen zusammenhält, und was nicht.** Gleich gehalten werden die drei
Ersetzungs-Funktionen: `make test-bats` vergleicht ihre Rümpfe zwischen
`harness/tools/slice-mv.sh` und der emittierten Fassung, weißraum-normalisiert — die eingehende
Ersetzung trifft damit im Ziel dieselben Präfix-Formen wie hier. Die Skript-Köpfe und alles
Übrige vergleicht er nicht — die zwei Dateien sind nicht als Ganzes gleich, und die Zusage gilt
den Ersetzungs-Regeln, nicht der Gleichheit. Die Zwei-Commit-Sequenz fährt diese Stufe nicht: der
Vergleich ruft die Funktionen ohne Repository auf, und der Ablauf mit `git` gehört ins Ziel, wo
`make full-smoke` ihn trägt. Gefahren wird die Kette über der `--lang-go`-Variante des
Bootstraps; dass Fragment und Skript auch sprachlos unter denselben Pfaden liegen, hält
`make test-go` (`TestSliceMvFragment_LiegtImZielUndHaengtNichtAnDerGatesKette`).
