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

Kein Gate-Versprechen; Träger von [Modul 5](../../.harness/baseline/v6.7.2/regelwerk/modul-05-planning-harness.md#lifecycle-als-state-machine)
und `BEO-ALL/verweise-brechen-beim-ortswechsel`.
