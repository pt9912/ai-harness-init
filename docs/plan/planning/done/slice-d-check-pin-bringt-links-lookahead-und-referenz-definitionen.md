# Slice slice-d-check-pin-bringt-links-lookahead-und-referenz-definitionen: Der d-check-Pin springt in EINEM Schritt `v0.77.0` → `v0.79.0`, und `links` prüft zwei neue Formen standardmäßig

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-02`](../../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit) (der
Digest-Pin ist die Reproduzierbarkeits-Zusage),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
grünes Gate sagt etwas über den Ausschnitt, den es prüft — und zwei Sensor-Dateien behaupten
heute eine Grenze des Gates, die dieser Sprung aufhebt),
[`MR-068`](../../../../harness/conventions.md#mr-068) (der Vorgänger dieser Pin-Linie),
[`MR-066`](../../../../harness/conventions.md#mr-066), [`MR-064`](../../../../harness/conventions.md#mr-064),
[`MR-061`](../../../../harness/conventions.md#mr-061) §Auflösungs-Trigger (bei jedem
d-check-Release: Pin, Fragment, Strenge-Bilanz), [`MR-063`](../../../../harness/conventions.md#mr-063)
(Gegenmessung je aktivem Modul), [`MR-053`](../../../../harness/conventions.md#mr-053) (eine
Werkzeug-Aussage datiert ihren Messstand), [`MR-054`](../../../../harness/conventions.md#mr-054)
(was ins emittierte Gate geht), [`MR-010`](../../../../harness/conventions.md#mr-010) und
[`MR-062`](../../../../harness/conventions.md#mr-062) (Fragment-Re-Adaption und ihre Handgriffe),
[`MR-067`](../../../../harness/conventions.md#mr-067) (Aufbau-Anleitung vor den Kommandos),
[`AGENTS.md`](../../../../AGENTS.md) §3.7 (Rang-Zeiger-Kommentare — zwei Sensor-Dateien
beschreiben eine Werkzeug-Grenze, die mit diesem Sprung entfällt).

**Berührte Spec-Stellen:** —

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-27.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Der gepinnte d-check steht auf `v0.79.0` statt `v0.77.0`, an beiden gekoppelten Stellen
(`d-check.mk`, `internal/emit/emit.go`) und mit belegtem Digest; das tool-generierte Fragment ist
gegen eine frische `--print-mk`-Ausgabe re-adaptiert, und ein neuer Adaptions-Eintrag trägt die
Strenge-Bilanz über die Spanne. Danach prüft das bereits aktive Modul `links` zwei zusätzliche
Formen **standardmäßig** (kein Opt-in-Schlüssel nötig): eine Zieladresse hinter genau einem
Zeilenumbruch nach `](` und Link-Referenz-Definitionen `[label]: ziel "titel"` unabhängig von ihrer
Verwendung. `make docs-check` steht nach dem Sprung grün über dem realen Bestand.

*(Fremde Kennungen — die Slice- und Entscheidungs-IDs des Werkzeugs selbst — sind Eingabe für diesen
Plan und werden hier nicht zitiert: Sie gehören zu keinem Rang dieses Repos und wären eine tote
Adresse für `ids`, das jede `ADR-\d{4}`-Form gegen unser eigenes `docs/plan/adr/` linkpflichtig macht.
Beschrieben wird die **Wirkung**, nicht die fremde Herkunfts-Kennung.)*

**Bewusste Abweichung vom eigenen Sprung-Muster.** [`MR-052`](../../../../harness/conventions.md#mr-052)
bis [`MR-068`](../../../../harness/conventions.md#mr-068) haben bislang jeden Release einzeln gepinnt
— eine Patch- oder Minor-Stufe je Eintrag. Dieser Slice springt **in einem Schritt** über zwei
Minor-Stände (`v0.78.0` wird nicht eigens gepinnt) auf Anweisung des Auftraggebers vom 2026-09-27
(explizite Zeitentscheidung, nicht das übliche Muster). Die Konsequenz: Die Werkzeug-Beschreibung
dieses Slice trägt **drei** Releases (`v0.77.0`→`v0.78.0`→`v0.79.0`), nicht eins, und die
Strenge-Bilanz misst über die volle Spanne `v0.77.0..v0.79.0`, nicht je Zwischenschritt.

**Herkunft:** Der Auftraggeber hat den Sprung am 2026-09-27 angewiesen. Der Sprung löst den
permanenten Auflösungs-Trigger von [`MR-061`](../../../../harness/conventions.md#mr-061) ein und
setzt die Pin-Linie von [`MR-068`](../../../../harness/conventions.md#mr-068) fort. Alles, was
dieser Plan über den neuen Stand sagt, stammt aus dem `CHANGELOG.md` des Klons des Werkzeugs
(`/Development/d-check`, nur lesend) und aus den Kommandos des Plans.

**Werkzeug-Stand**, gelesen im `CHANGELOG.md` des Klons (nur lesend,
`git -C /Development/d-check show v0.79.0:CHANGELOG.md | awk '/^## \[0\.79\.0\]/,/^## \[0\.76\.3\]/'`):

- **`v0.77.0`** (bereits gepinnt, unverändert Gegenstand dieses Sprungs): `matrix` bekommt
  `allow-if-same-id` — siehe [`MR-068`](../../../../harness/conventions.md#mr-068), hier nicht neu
  gemessen.
- **`v0.78.0`:** Neues, **opt-in** Modul `file` (Zeilen-/Byte-Obergrenzen einer ganzen Datei — der
  Titel seiner Spec-Anforderung im Werkzeug trägt den Zusatz „(opt-in)“). Nicht in `modules:`
  unserer `.d-check.yml`, keine Schwelle aktiviert. `structure` bekommt eine zwölfte, **per-Regel
  optionale** Bedingung `max-lines` — ein neuer Schlüssel innerhalb eines bereits aktiven Moduls,
  den unser `structure:`-Block nicht setzt: „Ohne den Schlüssel byte-identisches Verhalten“
  (dieselbe Form wie `allow-if-same-id` in [`MR-068`](../../../../harness/conventions.md#mr-068)).
  Dazu erkennt `--suggest-config ai-harness` jetzt zusätzlich `RB`-Kennungen — ein CLI-Modus, den
  dieses Repo nicht aufruft.
- **`v0.79.0`:** `links` (bereits aktiv, ohne Opt-in-Schalter) bekommt zwei zusätzliche,
  **standardmäßig aktive** Prüfungen:
  - Die Adress-Klammer `(…)` eines Links darf, wenn sie in der Zeile nicht schließt, um **genau
    eine** Folgezeile desselben Absatzes verlängert werden; die Linktext-Klammer `[…]` bleibt strikt
    zeilenlokal. Gilt für `links`, `links.resolve-from`, `anchors`, `matrix`, `external`, `tracked`
    — alle Module, die dieselbe Link-Extraktion teilen.
  - Eine Link-Referenz-Definition `[label]: ziel "titel"` wird unabhängig von ihrer Verwendung
    geprüft; ein totes Ziel meldet `target-missing` auf der Definitions-Zeile, mit demselben
    `ignore-refs`-Ventil wie ein Inline-Link. Gilt für fünf der sechs Module der gemeinsamen
    Extraktion (`anchors` behandelt Definitionen nicht — neuer Out-of-Scope-Satz dort).
  - Beide sind laut CHANGELOG „standardmäßig an“ — anders als `allow-if-same-id` (opt-in) oder
    `structure.max-lines` (opt-in) tragen sie **keinen** Konfigurationsschlüssel, den unsere
    `.d-check.yml` nicht setzt: Sie wirken auf jeden Lauf des bereits aktiven Moduls `links`.
- Das ist die Beschreibung des Werkzeugs. Ob sie am Quellstand des Bildes trägt und was sie an
  **unserem** Bestand bedeutet, misst L1–L2 — nicht §1.

**Kein Breaking Change gefunden.** `git -C /Development/d-check log v0.77.0..v0.79.0 --oneline`
enthält keinen Commit-Betreff mit „Breaking“/„migriert“/„entfernt“ außerhalb zweier interner
Korrektur-Ketten (der Zeilenumbruch-Lookahead und die Referenz-Definitions-Prüfung wurden je einmal
innerhalb derselben Werkzeug-Spanne nachgeschärft, nicht gegenüber `v0.77.0` zurückgenommen); keine
der acht neuen Entscheidungen des Werkzeugs trägt ein Pflichtfeld, das unsere `.d-check.yml` heute
nicht setzt, und kein bestehender Default-Wert ändert sich für ein Modul, das wir führen, außer den
zwei genannten `links`-Prüfungen.

**Eigener Fundgang gegen unseren Bestand (grep, kein Docker-Pull — Näherung, keine Messung mit dem
Parser):**

```sh
git grep -nE '\]\($' -- '*.md' ':!.harness/baseline'                      # 0 Treffer
git grep -nE '^ {0,3}\[[^]]+\]: ?\S' -- '*.md' ':!.harness/baseline'      # 0 Treffer
```

Beide Muster sind grobe Annäherungen an die zwei neuen Formen (echte Bracket-Balance und
Titel-Delimiter-Prüfung liest nur der Parser selbst) und liefern **keinen** Treffer außerhalb der
vendorten Baseline. Das senkt die Wahrscheinlichkeit, dass der Sprung `docs-check` sofort rot
färbt — es belegt es nicht: L2 misst real gegen den gepinnten Digest.

**Zwei Sensor-Dateien behaupten heute eine Grenze, die dieser Sprung aufhebt.**
[`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md) Zeile 97–101 und
[`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) Zeile 115/122–127
sagen wörtlich: Der Verweis-Nachzug unter `docs/reviews/` lässt ein Ziel hinter dem Zeilenumbruch und
eine Referenz-Definition stehen, „und `make docs-check` schweigt“/„meldet sie nicht“ — mit Bezug auf
[`ADR-0070`](../../../../docs/plan/adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md).
Diese Aussage ist am **gepinnten d-check gemessen** und wird mit `v0.79.0` falsch: Beide Formen
lösen jetzt (falls die Adresse nicht auflöst) `target-missing` aus. Die zitierte ADR selbst ist
`Accepted` und wird **nicht** angefasst (§3.4) — ihre Festlegung (der Nachzug schreibt nur die Link-Form) bleibt
unverändert wahr; nur die **Konsequenz am Gate**, die zwei Sensor-Dateien als derivative Prosa
beschreiben, ändert sich mit dem Werkzeug-Stand.

**Register-Sichtung (vorab):**
[`BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung`](../observations/BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung/observation.md)
(1×, Stand `offen`, unterhalb der Schwelle) benennt exakt die Referenz-Definitions-Hälfte: „ein
Wächter für die Referenz-Definition besteht nicht: das gepinnte Doku-Gate meldet sie nicht“. Dieser
Sprung macht diese Aussage falsch — ob die Beobachtung damit *gestrichen* werden kann (§Modul 6: ein
Ausgang ist auch unterhalb der Schwelle zulässig, sobald die Ursache wegfällt), ist eine Frage, die
der Verifier real gegen den gepinnten Digest belegt und die **Closure dieses Slice** entscheidet —
Closure ist Planner-Arbeit in frischem Kontext (§3.10), nicht Teil dieser Planung. Die zweite in der
Beobachtung genannte Form (Anker auf umgezogenen Stub, `anchor-missing`) ist von diesem Sprung nicht
berührt und bleibt offen.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Das Modul `file` wird nicht aktiviert, keine Schwelle gesetzt.** *Anderer Vorgang:* `file` ist
  laut Spec-Kürzel selbst als opt-in geführt; eine Aktivierung (welche Datei, welche Schwelle) ist
  eine eigene Entscheidung mit eigener Begründung, nicht Folge eines Pin-Sprungs.
- **`structure.max-lines` wird nicht gesetzt, kein bestehender `structure:`-Block bekommt den
  Schlüssel.** *Anderer Vorgang, dieselbe Begründung wie bei `allow-if-same-id` in
  [`MR-068`](../../../../harness/conventions.md#mr-068):* Ein Opt-in ohne Objekt (welcher Abschnitt,
  welche Schwelle) wäre eine Entscheidung, die niemand getroffen hat.
- **Kein Zwischen-Pin auf `v0.78.0`.** *Bewusste Abweichung, oben benannt:* Der Auftraggeber hat den
  Ein-Schritt-Sprung angewiesen; ein Zwischen-Eintrag würde das eigene Muster fortsetzen, das hier
  ausdrücklich nicht gilt.
- **`--suggest-config` wird an keiner Stelle dieses Repos aufgerufen oder verändert.** *Bestand
  bleibt bewusst stehen:* Das Repo nutzt diesen CLI-Modus nicht (kein Treffer in `Makefile` oder
  `d-check.mk`); die neue `RB`-Erkennung des CLI-Modus hat hier keinen Gegenstand.
- **Keine ADR.** *Anderer Vorgang:* ADR-pflichtig ist eine Gate-**Lockerung**
  ([`AGENTS.md`](../../../../AGENTS.md) §3.5); die zwei neuen `links`-Prüfungen sind eine
  **Verschärfung** (sie decken eine bisher stille Lücke, dieselbe Klasse wie `v0.76.3`/Messung 2 in
  [`MR-066`](../../../../harness/conventions.md#mr-066)) und brauchen darum nach §3.6 kein ADR.
- **Nicht Gegenstand dieses Slice: die zwei Grenzen aus [`MR-066`](../../../../harness/conventions.md#mr-066)**
  (Alternates, leere Range) **und die übrigen Grenzen aus [`MR-068`](../../../../harness/conventions.md#mr-068).**
  *Bestand bleibt bewusst stehen:* Sie sind an ihrem jeweiligen Werkzeug-Stand datiert und tragen
  fort, solange keine Messung dieses Sprungs sie widerlegt.

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste. Suchreihenfolge: Was übernimmt ein **Folge-Slice** (mit
Kennung — und die Kennung muss den Punkt auch annehmen)? Was bleibt als
**Bestand** bewusst stehen (mit Begründung)? Was wäre ein **anderer Vorgang**?
Welche **Schicht** rührt der Slice nicht an?

Was hier steht, ist die Grenze, an der ein wachsender Slice sich messen lässt:
Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

Drei Liefer-Punkte, jeder mit dem Kommando, das ihn rot färbt
([`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [x] **L1 — Der Pin steht auf `v0.79.0`, an beiden gekoppelten Stellen, mit belegtem Digest und
      re-adaptiertem Fragment.** *(Rot-Kommando: `TestDefaultImage_MatchesCanonical` und
      `TestDefaultDigest_MatchesCanonical` (`go test ./internal/emit/...` im gepinnten Image via
      `make test`) schlagen fehl, solange `d-check.mk` und `internal/emit/emit.go` auseinanderlaufen;
      Digest über die drei Wege aus [`MR-068`](../../../../harness/conventions.md#mr-068) belegt —
      Pull, `docker image inspect`, `docker manifest inspect`; Fragment-Diff
      `diff <(docker run --rm --network none ghcr.io/pt9912/d-check@<digest> --print-mk) d-check.mk`
      nach Hunks gezählt und im Adaptions-Eintrag dokumentiert.)*
- [x] **L2 — `make docs-check` ist grün über dem realen Bestand nach dem Sprung, und der
      Adaptions-Eintrag trägt die Strenge-Bilanz (jedes aktive Modul mit Basis) über die Spanne
      `v0.77.0..v0.79.0`.** *(Rot-Kommando: `docker run --rm --network none -v "$(pwd):/repo:ro"
      ghcr.io/pt9912/d-check@<v0.79.0-digest>` gegen den echten Baum — Exit ≠ 0 bei neuen Funden.
      Findet der Lauf echte, durch die zwei neuen links-Prüfungen neu gemeldete `target-missing` an bestehenden
      Dateien: entweder real beheben (Link korrigieren) **innerhalb dieses Slice**, falls die Menge
      klein bleibt, oder — falls sie den Slice sprengt — Rückführung `in-progress→next` nach §4, statt
      den Fund zu übergehen.)*
- [x] **L3 — Die zwei Sensor-Dateien (`harness/sensors/slice-mv.md`,
      `harness/sensors/archive-welle.md`) sind auf den neuen Ist-Zustand nachgezogen, falls die zwei
      Formen (Zeilenumbruch-Ziel, Referenz-Definition) jetzt tatsächlich gemeldet werden.**
      *(Rot-Kommando: derselbe Report-Test wie in
      [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) Zeile 122–126
      beschrieben — ein Report mit beiden Formen auf einen nicht vorhandenen Pfad, gegen den
      gepinnten `v0.79.0`-Digest gefahren; meldet er jetzt `target-missing`, sind die Sätze „`make
      docs-check` schweigt“/„meldet sie nicht“ falsch und werden korrigiert, mit dem neu gemessenen
      Befund als Beleg.)*
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [x] Doku-Update: über L2/L3 hinaus keines, solange die Gate-Namen gleich bleiben (kein neues
      Modul aktiviert).
- [x] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [x] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [x] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [x] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`d-check.mk`](../../../../d-check.mk) | update | L1: Tag, Digest, re-adaptiertes Fragment, Kopfkommentar über den neuen Stand |
| [`internal/emit/emit.go`](../../../../internal/emit/emit.go) | update | L1: emittierter Default-Pin |
| `internal/emit/emit_test.go` (bestehend) | unverändert | L1: `TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` halten die Kopplung |
| [`.d-check.yml`](../../../../.d-check.yml) | unverändert, geprüft | §1: kein neues Modul, kein neuer Schlüssel (`file`, `structure.max-lines` bewusst nicht gesetzt) |
| betroffene Markdown-Dateien mit echten neuen Funden (falls L2 welche findet) | update | L2: reale Korrektur, sonst Rückführung nach §4 |
| [`harness/sensors/slice-mv.md`](../../../../harness/sensors/slice-mv.md), [`harness/sensors/archive-welle.md`](../../../../harness/sensors/archive-welle.md) | update, falls L3 zutrifft | L3: die zwei „schweigt“/„meldet nicht“-Sätze auf den neuen Ist-Zustand |
| Adaptions-Eintrag unter `harness/conventions/` (nächste freie Nummer, gemessen: **073**, siehe §6) samt Index-Zeile und der Zeile `d-check:` in §Baseline | neu | Übergabe an den Architect (§6, §3.8), eigener Commit |
| `docs/plan/planning/observations/BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung/state.md` | ggf. update (Closure-Entscheidung, nicht Teil dieser Planung) | §1: die Referenz-Definitions-Hälfte der Beobachtung wird durch diesen Sprung ggf. gegenstandslos |
| keine ADR | — | §1: der Sprung ist eine Verschärfung, kein ADR-Gegenstand nach §3.6 |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei; dringend nach expliziter Anweisung des
Auftraggebers vom 2026-09-27 — kein `open→next`-Zeremoniell, direkte Anlage in `next/`.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): **L2 findet mehr echte, neue
  `target-missing`-Funde durch die zwei neuen links-Prüfungen als in einem Slice einzeln behebbar** (Signal, keine
  feste Zahl — Lehre aus `slice-204`: wenn die Korrekturmenge selbst schneidbar ist, gehört sie in
  einen eigenen Folge-Slice statt den Pin-Sprung aufzuhalten). Ebenso, wenn das Fragment beim
  Re-Adaptieren einen sechsten Handgriff braucht (neue Struktur, die
  [`MR-010`](../../../../harness/conventions.md#mr-010)/[`MR-062`](../../../../harness/conventions.md#mr-062)
  nicht mehr trägt).
- `in-progress` → `open` (blockiert — Carveout?): Das Bild ist aus der Registry nicht abrufbar, oder
  sein Digest lässt sich auf den drei Wegen nicht mit demselben Wert belegen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. `make gates` grün, mit `v0.79.0` an beiden gekoppelten Stellen.
2. Die Strenge-Bilanz aus L2 steht mit gelesener Ausgabe im Umsetzungs-Commit und im
   Adaptions-Eintrag, und der Eintrag hat seinen Review.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die zwei neuen `links`-Prüfungen melden neue `target-missing`-Funde an bestehenden Dateien, deren Menge einen
  Slice sprengt.** Der grepbasierte Vorab-Fundgang in §1 fand null Kandidaten, ist aber eine
  Näherung ohne echte Bracket-/Titel-Delimiter-Semantik. **Ausgang: entfallen** — L2 maß real 0 neue
  Funde (`make docs-check` gegen den unveränderten Bestand: Exit 0, 2069 Datei(en), 0 Befund(e); vom
  Implementer und unabhängig vom Reviewer bestätigt).
- **Die Strenge-Bilanz zeigt eine Senkung an einem der neun aktiven Module** (unwahrscheinlich,
  da beide neuen Prüfungen zusätzlich melden, nicht weniger — aber ungemessen bis L2 läuft).
  **Ausgang: entfallen** — die MR-063-Gegenmessung (9 von 9 aktiven Modulen) zeigt reine Erweiterung:
  byte-identische Befundmengen über beide Digests auf allen drei Stufen (Commit `77bf81f7`,
  bestätigt in der Reviewer-Nachrunde).
- **Der emittierte Default-Pin läuft dem Dogfood-Pin auseinander** (L1 vergessen an einer der zwei
  Stellen). **Ausgang: entfallen** — beide Stellen (`d-check.mk`, `internal/emit/emit.go`) im selben
  Commit `12f30003`; `TestDefaultImage_MatchesCanonical`/`TestDefaultDigest_MatchesCanonical` real
  rot/grün gefahren (Reviewer-Nachvollzug).
- **Vor dem Start erscheint ein weiterer Release.** **Ausgang: entfallen** — `v0.79.0` blieb der
  neueste Tag bis zum Start und bis zu dieser Closure
  (`git -C /Development/d-check for-each-ref --sort=-v:refname 'refs/tags/v0.*'` → `v0.79.0` an
  erster Stelle, erstellt 2026-09-27).
- **Die Beobachtung
  [`BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung`](../observations/BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung/observation.md)
  wird bei der Closure übersehen**, obwohl ihre Referenz-Definitions-Hälfte durch diesen Sprung
  ggf. gegenstandslos wird. **Ausgang: entfallen** — der Closure-Lauf hat sie real geprüft: die
  Referenz-Definitions-Hälfte ist mit `v0.79.0` nicht mehr ungeklärt (`state.md` entsprechend
  aktualisiert), die Anker-auf-Stub-Hälfte bleibt unberührt offen (§7).

### Übergabe an den Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8)

Ein Adaptions-Eintrag zum Sprung `v0.77.0` → `v0.79.0` nach dem Muster von
[`MR-068`](../../../../harness/conventions.md#mr-068), in der Form aus
[`MR-053`](../../../../harness/conventions.md#mr-053) und mit der Gegenmessung aus
[`MR-063`](../../../../harness/conventions.md#mr-063). Er trägt die Messungen aus L1/L2 und datiert
seine Werkzeug-Aussagen — **und benennt ausdrücklich, dass er drei Releases in einem Sprung
zusammenfasst** (bewusste Abweichung, §1), nicht nur einen wie seine Vorgänger.

**Vorgeschlagene Kennung: die nächste freie Nummer der aktiven Tabelle.** Gemessen ist die letzte
vergebene [`MR-072`](../../../../harness/conventions.md#mr-072)
(`ls harness/conventions/*.md | grep -oE 'MR-[0-9]{3}' | sort | tail -1`), die nächste freie also
**073**. Die Kennung selbst steht hier nicht als Token: das Doku-Gate verlangt für jede Kennung
dieser Klasse einen auflösenden Link ([`MR-001`](../../../../harness/conventions.md#mr-001)), und
ein Link auf einen noch nicht existierenden Eintrag wäre eine tote Adresse. Vergeben wird sie mit
dem Eintrag, vom Architect. Mit ihm gehen seine Index-Zeile und die Zeile `d-check:` in §Baseline,
deren Liste der Sprünge die neue Kennung bekommt. Eigener Commit, Rolle in der Message (§3.8) — und
der Eintrag bleibt **lokal bis zur Review-Runde**
([`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md)).

## 7. Closure-Notiz

**Was hat funktioniert:** Der Ein-Schritt-Sprung über drei Releases (statt des eigenen
Ein-Release-je-Eintrag-Musters) hat den vollen Werkzeug-Zustand in einem Adaptions-Eintrag
(`MR-073`) gebündelt, ohne dass die zwei ausgelassenen Releases (`v0.77.0` bereits gepinnt,
`v0.78.0` ohne Gegenstand) an Nachweisqualität verloren. Digest, Fragment-Diff und Kopplungstests
sind zweifach unabhängig belegt (Implementer und Reviewer), und die zwei betroffenen Sensor-Dateien
(`slice-mv.md`, `archive-welle.md`) sind auf den real gemessenen Ist-Zustand gezogen, mit
Vorher/Nachher-Gegenprobe gegen den alten Digest.

**Was ging anders als geplant:** Zwei Nachträge waren nötig, die beide vom Reviewer gefunden wurden,
nicht vor der Übergabe: (1) Der erste Umsetzungs-Commit trug nur eine Teilmessung der
MR-063-Strenge-Bilanz (2 von 9 Modulen) statt der vollständigen, wie sie das Vorgänger-Muster
(`MR-068`) selbst vorgibt — nachgetragen in einer zweiten Implementer-Runde (F-1). (2) Der
Adaptions-Eintrag behauptete, die Quell-Differenz bewege „nur" zwei Dateien, während ein
vollständiger `git diff --numstat` eine dritte (`anchors.go`, harmlose Ausnahme) zeigte — vom
Architect korrigiert, nachdem der Reviewer es in der Nachrunde selbst nachgefahren hatte (F-2).
Beide Nachträge trafen keine der zwei primären Closure-Trigger-Bedingungen inhaltlich (die
empirische Gegenmessung blieb in beiden Fällen unberührt), zeigen aber dasselbe Muster: eine
Vollständigkeits- oder Mengen-Aussage, die erst der Reviewer gegen das reale Kommando hält, statt
dass der schreibende Lauf es selbst tut. Zusätzlich lief bei der Behebung von F-2 ein
Rollen-Kollisions-Vorfall: Der Architect amendete den eigenen letzten Commit, traf dabei aber einen
zwischenzeitlich vom Reviewer gesetzten Commit (HEAD hatte sich zwischen Auftrag und Ausführung
bewegt) — am Reflog selbst entdeckt und vor dem Push per Reset und Neu-Commit repariert (siehe
Beobachtungs-Register unten).

**Steering-Loop-Eintrag:** **benannte Spec-Lücke, in drei Teilen — jeweils unterhalb der Schwelle,
kein neuer Zielort aus diesem Slice.**
1. Kein Wächter hält eine Werkzeug-Nachweispflicht (hier: MR-063-Vollständigkeit) vor dem Commit
   gegen das etablierte Vorgänger-Muster — Beobachtung
   `BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` (neu, 1×, offen).
2. Kein Wächter hält eine als abschließend formulierte Datei-Mengen-Aussage gegen den vollständigen
   `diff` — Beobachtung `BEO-ALL/quell-differenz-aussage-behauptet-menge-ohne-gegen-diff` (neu, 1×,
   offen).
3. `git commit --amend` committet den Index, nicht die Pfade des eigenen Vorgangs, und reißt einen
   zwischenzeitlich fremd gesetzten Commit mit — Beobachtung
   `BEO-ALL/amend-committet-fremde-index-eintraege-mit` erreicht mit diesem Slice ihren **dritten**
   Beleg. **3× erreicht → Ausgang `geplant`**: Kennung `slice-amend-haelt-den-index-pfadrein` (neu
   angelegt in `open/`), der die Disziplin oder den Hook baut, den `state.md` bisher als fehlend
   benannte. Zielort und schreibende Rolle bestätigt der Architect in diesem Folge-Slice (§3.8).

**Beobachtungs-Register (`../observations/`):**
- `BEO-ALL/strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit` — neu angelegt, 1×, offen
  (Beleg: dieser Slice, F-1).
- `BEO-ALL/quell-differenz-aussage-behauptet-menge-ohne-gegen-diff` — neu angelegt, 1×, offen (Beleg:
  dieser Slice, F-2).
- `BEO-ALL/amend-committet-fremde-index-eintraege-mit` — dritter Beleg (dieser Slice), 3× erreicht,
  Ausgang `geplant` → `slice-amend-haelt-den-index-pfadrein` (neu in `open/`).
- `BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung` — `state.md` fortgeschrieben,
  kein neuer Beleg (Resolution, keine Wiederholung): Die Referenz-Definitions-Hälfte ist mit
  `v0.79.0` nicht mehr ungeklärt (real gemessen, zweifach). Die Anker-auf-Stub-Hälfte bleibt von
  diesem Sprung unberührt und offen. Stand bleibt `offen` — die Beobachtung deckt beide Hälften
  gemeinsam, nur eine davon ist gegenstandslos geworden.
- Fünf weitere in §8 vorab gesichtete Einträge (`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`,
  `aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`,
  `stellen-messung-als-eigenschaft-ausgegeben`,
  `senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`,
  `norm-eintrag-friert-vor-seinem-review-ein`) waren als Kontext für die Sub-Area-Sichtung gelesen;
  dieser Slice hat ihre jeweilige Disziplin eingehalten (Werkzeug-Aussagen datiert, Bilanz zeigt
  echte Erweiterung statt Gleichstand, Eintrag lokal bis zum Review), ohne selbst einen neuen Beleg
  zu setzen.

**Risiko-Ausgänge (§6):** alle fünf **entfallen** — L2 maß 0 neue Funde; die Strenge-Bilanz zeigt
reine Erweiterung, keine Senkung; beide Pin-Stellen liefen im selben Commit; `v0.79.0` blieb bis zur
Closure der neueste Tag; die Register-Beobachtung wurde real geprüft statt übersehen.

**Folge-Slices:** `slice-amend-haelt-den-index-pfadrein` (neu, `open/`) — Verkörperung der
3×-Beobachtung zum Amend-Vorfall.

**Risiken aus §6:** alle fünf mit genau einem Ausgang — siehe §6 (alle **entfallen**).

**Drei Paarungen** (Repo ohne Wellen-Betrieb, geprüft nach dem `git mv`):
- **Anker:** kein `liegt in`-Feld in diesem §7 — nichts wurde mit diesem Slice verkörpert (der
  Amend-Befund geht als `geplant` in den Folge-Slice, nicht als `verkörpert` in einen Zielort).
  Nichts zu paaren.
- **Folge-Slice:** `slice-amend-haelt-den-index-pfadrein` existiert als Datei in `open/`.
- **Register:** alle vier genannten Beobachtungsverzeichnisse existieren
  (`strenge-bilanz-eines-pin-sprungs-fehlt-im-umsetzungs-commit`,
  `quell-differenz-aussage-behauptet-menge-ohne-gegen-diff`,
  `amend-committet-fremde-index-eintraege-mit`,
  `nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung`) und jedes trägt mindestens einen
  Beleg in `evidence/`.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan — sie hängen weder am Modus noch am Slice-Typ. Bedingt
ist allein der Modus-Begründungsblock am Ende; deshalb nennt der Titel beide
Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `d-check.mk`, `internal/emit/`, der
Adaptions-Block unter `harness/conventions/` und potenziell einzelne Markdown-Dateien (falls L2
reale Funde behebt); alle liegen in `*` (gesamtes Repo). `harness/sensors/` (Teil von `*`) wird
ggf. korrigiert (L3). `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`) sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| [`nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung`](../observations/BEO-ALL/nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung/observation.md) | 1 | offen | zentral: die Referenz-Definitions-Hälfte wird durch v0.79.0 ggf. gegenstandslos — Closure-Entscheidung, §1/§6 |
| [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) | 4 | geplant | L1/L2: jede Werkzeug-Aussage nennt ihren Stand, der Sprung bewegt ihn |
| [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) | 3 | geplant | §1: der Werkzeug-Stand stammt aus dem CHANGELOG; L2 misst am Bild |
| [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) | 6 | geplant | die Quell-Differenz der Regeldateien ist eine Stellen-Messung; die Gegenmessung in L2 trägt die eigentliche Aussage |
| [`senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens`](../observations/BEO-ALL/senkungs-pruefung-misst-die-menge-statt-des-gate-verhaltens/observation.md) | 2 | offen | L2: dieser Sprung ändert erstmals real Verhalten an einem aktiven Modul — die Bilanz kann hier nicht nur Gleichstand zeigen |
| [`norm-eintrag-friert-vor-seinem-review-ein`](../observations/BEO-ALL/norm-eintrag-friert-vor-seinem-review-ein/observation.md) | 2 | offen | §6, Übergabe an den Architect — Eintrag bleibt lokal bis zum Review |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
