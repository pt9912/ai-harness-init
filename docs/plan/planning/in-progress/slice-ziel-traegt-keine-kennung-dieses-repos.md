# Slice slice-ziel-traegt-keine-kennung-dieses-repos: Das Ziel trägt keine Kennung dieses Repos

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle — die Closure-Bedingung ist die DoD dieses Slice.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) ·
[`LH-FA-01`](../../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) ·
[ADR-0004](../../adr/0004-durchsetzungs-emission.md) ·
[ADR-0020](../../adr/0020-emittierte-modul-15-regeln.md) ·
[ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md).
Auslöser: Auftrag des Auftraggebers vom 2026-10-09 („in den emittierten Dateien werden unsere
Kennungen in den Kommentaren genannt — damit kann kein anderes Repo etwas anfangen“), nachgelegt
mit „schau dir die emittierten mk Dateien an“.

**Berührte Spec-Stellen:** [`spezifikation.md §5`](../../../../spec/spezifikation.md#5-metriken-und-tracing-felder)
— nur als Quelle der emittierten Feldliste; die Festlegungen selbst bleiben unverändert.

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-10-09.

---

## 1. Ziel und Abgrenzung

**Ziel:** Was das Werkzeug in ein Ziel schreibt oder dort ausgibt — emittierte Dateien samt der
adaptierten `--print-mk`-Fragmente, Hilfe, Fehlermeldungen und Commit-Messages des Trägers — nennt
keine Kennung und keinen Spec- oder Adaptions-Verweis dieses Repos oder eines Nachbar-Werkzeugs;
die Sache steht im Klartext, Verweise auf Artefakte des Ziels selbst bleiben.

**Gemessener Bestand** (Träger `.harness/state/bin/ai-harness-init`, Ziel a `--lang go --arch hexslice`,
Ziel b sprachlos plus `add-lang kotlin apps/kt --arch hexslice` und `add-lang cpp apps/cp`; beide
Ziele zeigen dieselben Fundstellen, unter `apps/` keine):

- eigener Text: `harness/erfassung-feldliste.md` <!-- d-check:ignore (Pfad im gebootstrappten Ziel) -->
  (fünf `Quelle: Spezifikation von ai-harness-init, §5 …`-Sätze und ein „Adaptions-Eintrag … von ai-harness-init“, aus `internal/span/fieldlist.go`) ·
  `harness/mk/traeger.mk` („Dogfood-Makefile fuehrt daneben die sechs Einzeldigests“, im Ziel <!-- d-check:ignore (Pfad im gebootstrappten Ziel) -->
  falsch) · `harness/mk/selbstpruefung.mk` und `tools/harness/selbstpruefung.sh` <!-- d-check:ignore (Pfad im gebootstrappten Ziel) -->
  (Default-Text mit einer Lastenheft-Kennung);
- adaptierter Fremdtext: `d-check.mk` trägt in den Hilfe-Kommentaren von zehn `doc-*`-Zielen die
  Anforderungs-Kennungen von d-check (`DC-FA-CLI-009` …, `make help` zeigt sie), `a-check.mk` Z. 9
  `(slice-082)` — beides verbatim aus `--print-mk` des gepinnten Werkzeugs (für a-check am
  gepinnten Image nachgemessen: `--print-mk` Z. 22), übernommen von `internal/emit/emit.go` bzw.
  `AdaptArchMK` in `internal/emit/archgate.go`;
- Meldungen des Trägers: `grep -rnE '(ADR-[0-9]{4}|MR-[0-9]{3}|LH-[A-Z]{2}-[0-9]{2}|SPEC-[0-9]{3})' --include=*.go cmd internal | grep -v _test.go | grep -vE '^\S+:[0-9]+:\s*//'`
  — darunter die Hilfe (Idempotenz-, Architektur- und Pin-Verweise), Fehlermeldungen mit
  Anforderungs-, Adaptions- und ADR-Klammern und der Commit-Suffix des Altbestands in
  `internal/archive/anwenden.go` (`kennungSuffix`); Treffer in Zeilenend-Kommentaren zählen nicht.

**Weg für den Fremdtext — festgelegt:** die **Adaption in diesem Repo** entfernt fremde
Werkzeug-Kennungen aus Kommentaren und Hilfetexten der beiden `--print-mk`-Ausgaben. Grund: der
Slice bleibt einzeln lieferbar und wartet nicht auf ein Fremd-Release; die Adaption besteht ohnehin
(`emit.go`, `AdaptArchMK`). Die Upstream-Bereinigung geht als Anforderungstext an den Auftraggeber;
greift sie später, wird die Entfernung hier zum No-op, nicht falsch.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- Kommentare im Go-Quellcode dieses Repos (auch Zeilenend-Kommentare wie in `templates.go`,
  `main.go` am Feld `baseline`) — Schicht-Abgrenzung: sie verlassen das Repo nicht; gemeint sind
  die Kommentare **in den emittierten Dateien**.
- Die Herkunftszeile „generiert/emittiert von ai-harness-init“ in den Köpfen emittierter Dateien —
  Bestand bleibt: sie nennt das Werkzeug, das im Ziel als Träger liegt, keine Kennung und keine Spec.
- Das Beispiel einer LH-Bindung für ein Determinismus-Gate in der emittierten `harness/conventions.md`
  — Bestand bleibt: es ist Text der vendored Vorlage (`conventions.template.md` Z. 172), kein Anker
  dieses Repos.
- Die Saat-Kennungen der Ziel-Vorlagen (Lastenheft-, Spezifikations- und Adaptions-Kennungen in `spec/` und
  `harness/conventions.md` des Ziels) und Platzhalter-Formen (`ADR-<NNNN>`, `LH-*`) — Bestand
  bleibt: sie lösen im Ziel auf bzw. sind keine Kennung.
- Eine Änderung an d-check oder a-check — anderer Vorgang: fremde Repos werden nicht angefasst; die
  Anforderung geht als Text an den Auftraggeber.
- Die Festlegungen in `spezifikation.md` §5 — Schicht-Abgrenzung: die Feldliste verliert ihre
  Quellen-Zeile, nicht ihre Kopplung an §5 (siehe §3).

## 2. Definition of Done

- [ ] **Emittierte Dateien** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
      Kein emittierter oder adaptierter Text (Ziel a und b wie in §1) nennt eine Kennung, Spec-Stelle
      oder einen Adaptions-Eintrag dieses Repos oder eine Anforderungs-/Slice-Kennung von d-check
      oder a-check; `traeger.mk` beschreibt das Ziel, nicht das Dogfood-Makefile. Die Kennung im
      Default-Text der Selbstprüfung bleibt nur, wenn sie auf die Saat-Anforderung **des Ziels**
      auflöst und das Muster seines `commit-msg`-Trägers trifft — der Grund steht dann in
      `erlaubteKennungen()`; sonst eine neutrale Form, die beides erfüllt.
- [ ] **Meldungen des Trägers** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
      Hilfe beider Unterkommandos, jede Fehlermeldung und jede Commit-Message, die der Träger im
      Ziel schreibt, tragen keine Kennung dieses Repos; das `grep`-Kommando aus §1 liefert 0
      Nicht-Kommentar-Treffer. Der Altbestand-Commit von `archive-welle` trifft im Ziel weiter ein
      Muster seines `commit-msg`-Trägers (sonst bricht er dort, s. §6).
- [ ] **Wächter** ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)):
      Die Kennungs-Prüfung liest zusätzlich (a) den `add-lang`-Pfad an einem Unterverzeichnis,
      (b) die Prosa-Form „von ai-harness-init“ mit Spec-, Festlegungs- oder Adaptions-Bezug (nicht
      die Herkunftszeile), (c) fremde Werkzeug-Kennungen der Form `DC-…`/`slice-NNN` in den
      adaptierten Fragmenten **über der realen `--print-mk`-Ausgabe** der gepinnten Images — in
      `make full-smoke` am gebootstrappten Ziel, wo der Go-Test nur die Fixture sieht —, (d) die
      Meldungen des Trägers über jeden im Test erreichbaren Fehlerpfad (Fehlertypen mit eigenem
      `Error()` direkt). Je Teil einmal rot gesehen; die Grenze steht im Kopf des Wächters (§3).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: `harness/README.md` bzw. Handbuch nur, falls sie eine der geänderten Meldungen
      zitieren.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `internal/span/fieldlist.go` | update | `Quelle:`-Sätze entfallen oder nennen die Sache; die Kopplung an §5 hält `internal/span/fieldlist_test.go` weiter, nun über eine Zuordnung im Test (Festlegung → Gegenstand), nicht über emittierten Text |
| `internal/emit/templates/enforce/traeger.mk` | update | Satz über das Dogfood-Makefile durch eine Aussage über das Ziel ersetzen |
| `internal/emit/templates/enforce/selbstpruefung.{mk,sh}` | prüfen / update | die Kennung im Default-Text nur mit Begründung in `erlaubteKennungen()` (DoD 1) |
| `internal/emit/emit.go`, `internal/emit/archgate.go` (`AdaptArchMK`) | update | fremde Werkzeug-Kennungen aus Kommentaren und `##`-Hilfetexten der `--print-mk`-Ausgaben entfernen |
| `cmd/ai-harness-init/main.go`, `vendor_baseline.go`, `internal/fetch/baseline.go`, `internal/emit/{enforce,emit,baumaussage}.go` | update | Kennung in Hilfe und Fehlermeldung durch die Sache ersetzen |
| `internal/archive/anwenden.go` (`kennungSuffix`) | update | Suffix trifft das Muster des Ziel-Trägers, ohne auf dieses Repo zu zeigen (§6) |
| `cmd/ai-harness-init/kennungen_test.go` | update | DoD 3 (a, b, d); Kopf nennt die Grenze |
| `harness/tools/full-smoke.sh` | update | DoD 3 (c): reale `--print-mk`-Adaption am gebootstrappten Ziel |
| `test/mutations/` | neu | je Wächter-Teil ein Fall (`make mutate`) |

- **Grenze des Wächters, im Kopf zu nennen:** Klartext-Verweise ohne Marker („siehe unsere
  Spezifikation“) erkennt er nicht; die Namensform `slice-<name>` erkennt er nur, soweit sie
  gegen Werkzeug-Namen (`slice-mv`, `slice-lokal`) trennbar ist; Fehlerpfade, die kein Test
  erreicht, liest er nicht; ob eine Ziel-Kennung im Ziel **auflöst**, prüft er nur für die
  Ausnahme-Liste.
- **Skip-if-present-Altbestand (Messung):** `git grep -lE 'ADR-[0-9]{4}|MR-[0-9]{3}|LH-[A-Z]{2}-[0-9]{2}' <tag> -- internal/emit/templates`
  über `v0.1.0`…`v0.6.0` — Treffer bis `v0.5.0`, ab `v0.6.0` nur `enforce/selbstpruefung.{mk,sh}`.
  Davon skip-if-present: `.d-check.yml` (`emit.go`, `writeSkipIfPresent`), `v0.1.0`–`v0.5.0`; die
  übrigen Treffer sind konvergente Bausteine und werden beim erneuten Lauf neu geschrieben. Die
  `.githooks`-Vorlage trägt in keinem Tag einen Treffer. **Nicht gemessen:** Text, den der Träger
  aus Go-Konstanten emittiert (`internal/gen`, `internal/span/fieldlist.go`) — dort trennt `grep`
  Kommentar nicht von Nutzlast; der Implementer misst es am Ziel je Release-Träger oder benennt die
  Lücke in §7.
- **Was der Adopter dafür bekommt — festgelegt:** keine neue Laufzeit-Meldung in diesem Slice; der
  Hinweis (betroffene Pfade, Abhilfe: Diff gegen eine frische Emission) gehört in den Release-Schnitt,
  der das Handbuch nachzieht. Grund: eine skip-if-present-Datei gehört nach der Emission dem
  Adopter ([ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md)); die alte
  Kennung steht dort in Kommentaren und ändert kein Verhalten.

## 4. Trigger

**Start** (`next` → `in-progress`): `slice-kotlin-freshness` liegt nicht mehr in `in-progress/`
(WIP-Limit 1).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Wächter-Teil (c) über der realen
  `--print-mk`-Ausgabe passt nicht mit DoD 1–2 in eine Review-Sitzung — dann geht (c) in einen
  eigenen Slice.
- `in-progress` → `open` (blockiert — Carveout?): der Ersatz für den Commit-Suffix des Altbestands verlangt eine
  Entscheidung über die Kennungs-Menge des Ziel-Trägers
  ([ADR-0065](../../adr/0065-emittierte-kennungs-form-folgt-dem-regelwerk.md)) — Übergabe an den
  Architect.

## 5. Closure-Trigger

DoD vollständig; das `grep`-Kommando aus §1 und der erweiterte Wächter liefern über einem frisch
gebootstrappten Ziel (Variante a und b) keinen Treffer; Closure-Notiz mit Lerneintrag.

## 6. Risiken und offene Punkte

- Der Altbestand-Commit von `archive-welle` braucht im Ziel eine Kennung, die das Muster
  `(ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+)` des emittierten
  `commit-msg`-Trägers trifft; die einzige im frischen Ziel auflösende ist eine Saat-Kennung. Ohne
  Ersatz bricht der Commit dort — **Ausgang:** <eingetreten | entfallen | weiter offen>
- Die Quellen-Sätze der Feldliste sind heute die Kopplung, die `fieldlist_test.go` an §5 hält;
  fallen sie weg, ohne dass der Test die Kopplung anders trägt, driftet die Feldliste still von
  §5 — **Ausgang:** <…>
- Die Entfernung fremder Kennungen aus `--print-mk` greift über ein Muster; eine neue Form im
  nächsten Pin-Sprung von d-check oder a-check rutscht durch, bis der Wächter-Teil (c) sie zeigt —
  **Ausgang:** <…>
- Ziele, die mit `v0.5.0` oder früher gebootstrappt wurden, behalten in `.d-check.yml` unsere
  Kennungen (§3) — **Ausgang:** <…>

## 7. Closure-Notiz

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <Guide oder Sensor> <geschärft/ergänzt>: <was genau>
  — liegt in `<AGENTS.md §X | Makefile:<target> | .harness/skills/…>`.
  Auslöser: `BEO-<KUERZEL>/<slug>` (<slice-kennung-a>, <slice-kennung-b>, <slice-kennung-c> — 3×).
  *(Wurde mit diesem Slice nichts verkörpert — der Normalfall —, entfällt die
  Teil-Zeile `— liegt in …` ersatzlos. Der Eintrag ist dann gezählt, nicht
  verkörpert.)*
- **Beobachtungs-Register (`../observations/`):** <`BEO-<KUERZEL>/<slug>/` neu angelegt, Beleg `evidence/slice-<Kennung>.md` | `evidence/slice-<Kennung>.md` in `BEO-<KUERZEL>/<slug>/` ergaenzt — Zaehler steht damit bei <N>x | keine Beobachtung angefallen>
- **Folge-Slices:** <slice-<Kennung> (<Titel>) — ist eine Datei in `open/`>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** <nur im Repo ohne Wellen-Betrieb — Anker · Folge-Slice · Register, Ergebnis>

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist allein `*` (gesamtes Repo, `ALL`) — die
Modus-Deklaration in `harness/conventions.md` führt für `internal/`, `cmd/` und die emittierten
Vorlagen keine eigene Sub-Area.

**Vorgelagert — offene Beobachtungen sichten** (`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence | wc -l`):

- `BEO-ALL/laufzeit-meldung-traegt-im-ziel-nicht-aufloesende-kennung` — 1, offen; DoD 2 ist ihr
  Gegenstand.
- `BEO-ALL/namensform-kennung-in-emittierter-datei-ohne-sensor` — 1, offen; DoD 3 nennt die
  Namensform als Grenze.
- `BEO-ALL/emittierte-zusage-reicht-weiter-als-was-im-ziel-geschieht` — 13, verkörpert in
  `AGENTS.md` §3.6; berührt den Satz in `traeger.mk`, der das Dogfood statt das Ziel beschreibt.
- `BEO-ALL/emittierter-stand-laeuft-dem-dogfood-voraus` — 2, offen; nur sachverwandt
  (Skip-if-present-Altbestand), kein dritter Beleg aus diesem Slice absehbar.

Keiner erreicht mit diesem Slice 3×.

**Modus-Begründungsblock:** alle berührten Sub-Areas GF.
