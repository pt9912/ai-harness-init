# Slice slice-098: Die Feldliste im Ziel ist der Ausdruck des Trägers und führt ihre Grenzen stehend

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
[`/kurs/de/02-planung/modul-05-planning-harness.md` §Lifecycle als State Machine](https://github.com/pt9912/ai-harness-course/blob/v3.5.2/kurs/de/02-planung/modul-05-planning-harness.md#lifecycle-als-state-machine).

**Welle:** [welle-12](../welle-12-erfassungsschicht-emittieren.md) — er läuft nach
[slice-096](../done/slice-096-traeger-liegt-im-ziel.md), weil das Dokument **aus** dem Träger erzeugt wird
und seinen Emissions-Zweig teilt. Er hängt **nicht** an
[slice-099](../open/slice-099-leser-und-aufraeum-kommando.md).

**Bezug:**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (§Redaktion:
*„Erfasst wird ausschließlich, was in einer geschlossenen, im Zielrepo lesbaren Feldliste steht"*,
samt der ausgesprochenen Nicht-Zusage über Pfadnamen und den Bestand; und §Benannte Grenze, deren
stehender Ort dieses Dokument ist),
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (**Accepted** —
Festlegung 7 wählt den Zielort und die Erzeugungsart, Festlegung 6 Stück 1 und 3 nennen die zwei
Stücke, die jene Quelle offenließ, Festlegung 8 den zweiten Grenz-Satz; Festlegung 5(a) ordnet das
Dokument dem Zweig des Trägers zu),
[`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) (**Accepted** — *das Gefäß folgt dem
Gegenstand*; ihr Re-Evaluierungs-Trigger stellt die Frage nach dem Zielort der Feldtabelle im
Zielrepo, und Festlegung 7 der obigen Entscheidung beantwortet sie mit **Nein**: nicht ins
Technik-Stratum des Adopters),
[`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) (**Accepted** — ihre
Folgepflicht 6 verlangt, dass die Grenze im Ziel *„genannt, nicht stillschweigend mitgeliefert"*
wird; dieses Dokument ist ihr **stehender** Ort, der auch dann trägt, wenn niemand die Auswertung
ruft),
[`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) (**Accepted** — ihre Festlegung 2 legt
die Redaktion zur Erfassungs-Zeit fest: von Argument-Werten wandert eine **Ableitung**, nie der
Inhalt; die Feldliste ist die lesbare Fassung davon),
[`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert) (die
Konstruktion, die Festlegung 7 übernimmt: tool-generiert, **verbatim** ins Ziel),
[`MR-021`](../../../../harness/conventions.md#mr-021--das-span-schema-zieht-ins-technik-stratum-sein-eintrag-wird-aufgehoben)
(die Präzedenz auf **unserer** Ebene: das Span-Schema lebt im Technik-Stratum dieses Repos — im
Ziel gibt es kein Stratum, das uns gehört, und genau daraus folgt der andere Ort).

**Autor:** Planner. **Datum:** 2026-08-25.

---

## 1. Ziel

**Das gebootstrappte Zielrepo führt im geprüften Bereich seiner Doku ein tool-erzeugtes Dokument,
das byte-gleich mit dem ist, was der Träger über sein eigenes Schema ausgibt — und das die Grenzen
stehend nennt, die kein Sensor hält.**

**Warum aus dem Träger erzeugt und nicht von Hand gepflegt.** Damit ist Drift zwischen **erfasstem**
und **dokumentiertem** Feld **konstruktiv** ausgeschlossen statt per Regel verboten: ein Feld, das
erfasst wird und dort fehlt, kann es nicht geben, weil beide aus derselben Quelle kommen. Dieselbe
Konstruktion trägt schon das Doc-Gate-Fragment verbatim ins Ziel
([`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert)).

**Warum in den geprüften Doku-Bereich und nicht unter `.harness/**` und nicht ins Technik-Stratum
des Adopters.** Der Baum unter `.harness/**` ist derivativer, nicht repo-autoritativer Inhalt, und
die emittierte `.d-check.yml` nimmt ihn aus. Die Feldliste dagegen ist eine **Aussage an den
Adopter** — sie gehört dorthin, wo sein Doku-Gate sie liest. Das Technik-Stratum wiederum ist
`skip-if-present` und gehört ihm: eine Tabelle, die wir dort hineinschrieben, könnte ein Re-Lauf
nie nachziehen und driftete mit der ersten Schema-Änderung. Der Zielort ist stattdessen ein
**tool-eigenes, konvergentes** Dokument.

**Die zwei Grenz-Sätze sind der zweite Gegenstand, nicht ein Anhang.** Das Dokument nennt (i), dass
die emittierte Ebene **keinen Wächter über die Aufrufform des Agenten-Werkzeugs** führt — die
Rollen-Achse ruht dort auf Adopter-Disziplin —, und (ii), dass die **Verbrauchs-Zähler aus der
Mechanik des Agenten-Werkzeugs nicht kommen** und kein Lauf des Adopters sie herbeiführt. Beide
gehören hierher, **weil sie auch dann gelten, wenn niemand die Auswertung ruft**. Eine
Abdeckungs-Zeile im Bericht meldet einen **Zustand**; erst der stehende Satz nennt die **Grenze**.

**Ein dritter Satz gehört fachlich dazu, und sein Ort ist hier gewählt, nicht vorgefunden.**
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Redaktion sagt
ausdrücklich, **nicht** zugesagt sei, dass Pfadnamen unkritisch sind und dass der Bestand geschützt
ist — er ist gitignored, nicht verschlüsselt, nicht zugriffsbeschränkt.
[`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) verlangt diesen
Satz (Festlegung 6 Stück 3: *„Im Ziel wird daraus ein **geschriebener** Satz"*), benennt ihm aber
**keinen** stehenden Ort. Dieser Slice wählt ihn: dasselbe Dokument, das die Feldliste führt, denn
die Nicht-Zusage ist die Kehrseite genau dieser Liste — wer liest, *was* erfasst wird, muss dort
lesen, *wie wenig* darüber zugesagt ist. Die Wahl ist eine Plan-Entscheidung und steht als solche
hier.

## 2. Definition of Done

Drei slice-eigene Punkte, jeder mit dem Kommando, das ihn **rot** färbt (Modul 5 §Ziel-Form: ≤ 3;
[`AGENTS.md`](../../../../AGENTS.md) §3.6).

- [ ] **(1) Das emittierte Dokument ist byte-gleich mit dem, was der Träger über sein eigenes
      Schema ausgibt.** Ein Feld, das erfasst wird und dort fehlt, färbt rot; ein Eintrag, den der
      Träger nicht erfasst, ebenso. Damit ist die Drift konstruktiv ausgeschlossen statt per Regel
      verboten.
      **Rot:** `make test` — ein Go-Wächter hält das emittierte Dokument gegen die Schema-Ausgabe
      des Trägers; dazu ein `test/mutations/`-Fall mit `# verify: test-go`, der ein Pflichtfeld
      erfasst, ohne den Ausdruck nachzuziehen, und das Rot erwartet. Ein Sensor darüber existiert
      heute nicht (`grep -rln 'Feldliste' internal/emit/*.go` → leer, Exit 1).
- [ ] **(2) Das Dokument führt seine drei Sätze stehend — fehlt einer, färbt es rot.**
      **Der Sensor misst die Adresse (eine Datei), der Gegenstand sind Aussagen — darum die
      Aussagen-Menge, aufgezählt und mit ihrer Richtung.** Die Eigenschaft: *ein Satz, der eine
      Grenze der emittierten Ebene nennt, die kein Sensor hält und die auch ohne Aufruf der
      Auswertung gilt.*
      **(a)** Die emittierte Ebene führt **keinen** Wächter über die Aufrufform des
      Agenten-Werkzeugs — Richtung: die Rollen-Achse ruht dort auf **Adopter-Disziplin**; benennt
      er seine Typen um, bleibt `agent.role` leer, und leer heißt *unbekannt*, nie *rollenlos*.
      Quelle: [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
      Festlegung 7 nennt ihn als geschuldet.
      **(b)** Die **Verbrauchs-Zähler kommen aus der Mechanik des Agenten-Werkzeugs nicht** —
      Richtung: das ist keine Eigenschaft unseres Aufbaus, und **kein Lauf des Adopters** führt sie
      herbei. Quelle: [`ADR-0021`](../../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md)
      Folgepflicht 6, hier eingelöst statt weitergereicht.
      **(c)** Über den **Bestand** ist nichts zugesagt — Richtung: er ist gitignored, **nicht**
      verschlüsselt und **nicht** zugriffsbeschränkt, und Pfadnamen sind **nicht** als unkritisch
      zugesagt. Quelle:
      [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
      §Redaktion und
      [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6
      Stück 3 — **ohne** benannten stehenden Ort; dieser Slice wählt ihn (§1).
      **Rot:** `make test` und `make mutate` — ein Go-Wächter je Satz; der `test/mutations/`-Fall
      (`# verify: test-go`) nimmt einen heraus und erwartet das Rot.
- [ ] **(3) Das Dokument teilt den Zweig des Trägers und liegt im geprüften Bereich der
      Ziel-Doku.** Es entsteht mit dem Träger; scheitert dessen Ablage, entsteht es **nicht** — ein
      unbedingt formulierter Wächter fiele im Zweig aus Festlegung 5(a) und stünde gegen die Zusage
      aus [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) DoD (2). Es liegt **nicht** unter
      `.harness/**`, das die emittierte `.d-check.yml` ausnimmt, sondern dort, wo das Doku-Gate des
      Ziels es liest — und es hält dieses Gate.
      **Rot:** `make full-smoke` über beide Bootstrap-Varianten — das gebootstrappte Ziel fährt sein
      **eigenes** `make gates` über dem Dokument, und der Fehlerzweig zeigt seine Abwesenheit. Dazu
      ein `test/mutations/`-Fall mit `# verify: full-smoke`; der Treiber führt den Modus
      (`sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE '^[[:space:]]+[a-z*-]+\)'`
      → **7** Arme, mitwandernd).

Standard-Punkte der Vorlage (nicht slice-eigen): `make gates` grün · Doku-Update, falls ein
öffentlicher Vertrag berührt ist · Closure-Notiz mit Steering-Loop-Lerneintrag.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`internal/span`](../../../../internal/span) — eine Ausgabe des eigenen Schemas | neu | Festlegung 7: das Dokument wird **aus dem Träger erzeugt**, nicht von Hand gepflegt; nur so ist Drift konstruktiv ausgeschlossen |
| [`internal/emit`](../../../../internal/emit) — Ablage des erzeugten Dokuments im geprüften Doku-Bereich des Ziels, im Zweig des Trägers | neu | Festlegung 7 und 5(a); Muster [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert): tool-generiert, verbatim, konvergent |
| [`internal/emit`](../../../../internal/emit) — Go-Wächter: Ausdruck ↔ Dokument, die drei Sätze, der bedingte Anwesenheits-Wächter | neu | DoD (1)–(3); ein Sensor über der Feldliste existiert heute nicht (`grep -rln 'Feldliste' internal/emit/*.go` → leer, Exit 1) |
| [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) | update | DoD (3): das eigene `make gates` des Ziels über dem Dokument, beide Varianten, beide Zweige |
| `test/mutations/` — je ein Fall für DoD (1), (2) und (3) <!-- d-check:ignore (geplante Dateien) --> | neu | [`AGENTS.md`](../../../../AGENTS.md) §3.6: wer keinen Fall hat, gilt als unbewacht |

## 4. Trigger

**`open` → `next`:** [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) liegt in `done/` — erst dann
gibt es einen Träger, aus dem das Dokument erzeugt wird, und einen Zweig, den es teilen kann.
Beobachtbar ohne Rückfrage: die Plan-Datei liegt in `done/`. **`next` → `in-progress`:** WIP-Limit
frei. **Nicht Trigger:** [slice-099](../open/slice-099-leser-und-aufraeum-kommando.md) — die beiden hängen
nicht aneinander und dürfen parallel laufen.

**Rückführungen, vorab benannt.** `in-progress` → `next`, wenn das Dokument mehr trägt als Feldliste
und Grenz-Sätze — etwa eine Betriebsanleitung; dann ist es zwei Gegenstände in einer Datei und
zerfällt nach Leser, nicht nach Abschnitt. `in-progress` → `open`, wenn der geprüfte Doku-Bereich
des Ziels das Dokument nicht aufnehmen kann, ohne das Gate eines frischen Ziels rot zu färben —
dann steht eine Entscheidung über den Zielort aus, und die gehört vor den Architect. Beide
Bedingungen sind Eigenschaften, keine Adressen.

## 5. Closure-Trigger

DoD (1)–(3) erfüllt mit gefahrenen Kommandos, `make gates` grün, `make full-smoke` grün über beide
Varianten und beide Zweige, `make mutate` grün mit den neuen Fällen, Closure-Notiz in §7 mit
Steering-Loop-Eintrag.

## 6. Risiken und offene Punkte

- **Byte-Gleichheit ist eine harte Zusage und bricht leicht aus dem falschen Grund.** Zeilenenden,
  abschließende Leerzeilen und die Sortierung der Felder gehören zur Gleichheit. Wer den Vergleich
  auf „enthält alle Felder" abschwächt, hat den konstruktiven Ausschluss der Drift wieder auf eine
  Regel zurückgestuft — genau das, was Festlegung 7 vermeiden wollte.
- **Der dritte Grenz-Satz hat keinen Rückhalt in der Entscheidung, nur in der Anforderung.** Sätze
  (a) und (b) benennt
  [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 7 als
  stehend; Satz (c) verlangt Festlegung 6 Stück 3 als *geschrieben*, **ohne** Ort. Die Wahl dieses
  Dokuments ist eine Plan-Entscheidung (§1) und kein Zitat. Wer sie umstößt, schuldet einen anderen
  stehenden Ort — nicht das Streichen des Satzes, denn
  [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) verlangt ihn
  auf Rang 1.
- **Bewacht ist die Anwesenheit der Sätze, nicht ihre Wahrheit.** Ein Wächter über einem Satz prüft,
  dass er dasteht; ob die emittierte Ebene wirklich keinen Agent-Guard führt, prüft er nicht. Diese
  Richtung bleibt offen und ist es bewusst — ein Sensor darüber wäre einer über einem fremden
  Vertrag.
- **Das Dokument liegt im geprüften Bereich und wird damit zum Gate-Gegenstand des Adopters.** Ein
  toter Verweis darin färbt sein `make gates` rot, und er kann ihn nicht heilen: das Dokument ist
  **konvergent**, ein Re-Lauf setzt es zurück. Es darf darum keine relativen Verweise tragen, die
  nur in diesem Repo aufgehen — dieselbe Falle wie bei den Rollen-Typen
  ([slice-097](../done/slice-097-rollen-typen-gehen-mit.md) DoD 3), hier aber schärfer, weil die
  `skip-if-present`-Ausweichmöglichkeit fehlt.
- **Ein frischer Klon hat den Träger nicht, aber das Dokument schon.** Es ist committet, er ist
  gitignored. Der Leser findet dann eine Feldliste über einer Erfassung, die gerade nicht läuft —
  das ist **richtig** (die Liste sagt, was erfasst *würde*), aber es ist erklärungsbedürftig, und
  die Erklärung gehört in dasselbe Dokument.

## 7. Closure-Notiz (nach `done/`)

**Was gilt.** Ein frisch gebootstrapptes Zielrepo führt unter `harness/erfassung-feldliste.md` ein <!-- d-check:ignore (Pfad im Zielrepo, nicht in diesem) -->
werkzeug-erzeugtes Dokument von **89** Zeilen, das **32** Feld-Zeilen und **drei** stehende
Grenz-Sätze trägt. Gemessen an einem Ziel, das dieser Lauf selbst gebootstrappt hat — der Träger
dafür ist der laufende (`make artifact DEST=<scratch>/bin`, Docker-only; `sha256sum` über ihm und
über [`.harness/state/bin/ai-harness-init`](../../../../.harness/state/bin) → **derselbe** Wert,
`56ce658b97c6405a60a1…`):

```
b=$PWD/.harness/state/bin/ai-harness-init; p=$(mktemp -d); (cd "$p" && "$b" --name probe >/dev/null)
d="$p/harness/erfassung-feldliste.md"; wc -l <"$d"; grep -c '^| `' "$d"
sed -n '/^## Grenzen/,$p' "$d" | grep -c '^\*\*'
grep -cE 'slice-[0-9]|MR-[0-9]|ADR-[0-9]|docs/plan' "$d"; grep -c '](' "$d"
```

→ **89**, **32**, **3**, **0**, **0**. Die letzten zwei Nullen sind die Zusage, die das Dokument
tragbar macht: es nennt **keine** Kennung, **keinen** Plan-Pfad und **keinen** Markdown-Verweis, der
nur in diesem Repo aufgeht — ein toter Link darin färbte das Doku-Gate des Adopters rot, und heilen
könnte er ihn nicht. **Und es ist konvergent, hier selbst gesehen:** eine angehängte Zeile bewegt
den `sha256sum` von `b4fb7e732d69c86e…` auf `e751fefe1656039f…`, ein zweiter Init-Lauf (**EXIT 0**)
setzt ihn auf `b4fb7e732d69c86e…` zurück, und `grep -c 'Adopter-Notiz' "$d"` → **0**. Alle Zahlen
wandern mit ihrem Bestand und sind **kein** Erwartungswert
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2).

**Der Closure-Trigger aus §5, Kriterium für Kriterium.**

1. **DoD (1)–(3) erfüllt, mit gefahrenen Kommandos.** Bestätigt in der
   [Verifikation](../../../reviews/2026-08-26-slice-098-verify.md) §2.1–§2.3, deren zehn Rot-Sonden
   auf Kopien außerhalb des Repos und an einem eigens gebootstrappten Probe-Ziel liefen —
   **fremdbelegt**, nicht von dieser Rolle. DoD (3) trägt ein ausgewiesenes Delta, s. unten.
2. **`make gates` grün.** Eigener Lauf, Belege unten unter *Gates*.
3. **`make full-smoke` grün über beide Varianten und beide Zweige.** **Fremdbelegt** für die
   Varianten — zweimal: Lauf L2 der Verifikation (**EXIT=0**) über dem Baum **ohne** den achten
   Fall, und Lauf M1 ihres Nachtrags (**EXIT=0**, **83 s**, `grep -cE 'full-smoke: FEHLER'` → **0**)
   über dem Baum **mit** ihm; erst der zweite deckt den erweiterten Idempotenz-Block. Für die
   **Zweige** bleibt es das Delta unten: der Fehlerzweig läuft dort nicht.
4. **`make mutate` grün mit den neuen Fällen.** **Fremdbelegt** (§1.1, Lauf L3) — über **164**
   Fällen; der geschlossene Baum trägt `ls -1 test/mutations/*.sh | wc -l` → **165**. Der
   **165.** Fall ist einzeln gefahren statt im Verbund (Nachtrag M2: Mutation auf einer Kopie wie
   der Treiber sie baut, `make test-go` **EXIT=2** in **7 s**, volle FAIL-Liste **genau einer**) —
   mit ausgeschriebener Begründung, welche der fünf Treiber-Bedingungen das deckt und welche
   offenbleibt. Was offenbleibt, schließt der nächste volle Lauf, und der ist an der
   Wellen-Closure fällig.
5. **Review konform (Modul 10).** [Code-Review](../../../reviews/2026-08-26-slice-098-review.md):
   *nicht frei*, `grep -c '^### F-' docs/reviews/2026-08-26-slice-098-review.md` → **4** (0 HIGH im
   Diff · 2 MEDIUM · 2 LOW), dazu zwei Befunde außerhalb des Diffs. Jeder der vier trägt unten
   einen Ausgang.
6. **Verifikation (Modul 11).** [Bericht](../../../reviews/2026-08-26-slice-098-verify.md):
   `grep -c '^### V-' docs/reviews/2026-08-26-slice-098-verify.md` → **12**, drei davon MEDIUM,
   keiner blockierend; dazu ein **Nachtrag** über dem achten Fall,
   `grep -c '^#### N-' docs/reviews/2026-08-26-slice-098-verify.md` → **4** (ein MEDIUM, zwei LOW,
   ein INFO), Urteil **GEDECKT**. Die zwölf und die vier tragen unten ihren Ausgang.
7. **Closure-Notiz mit Steering-Loop-Eintrag.** Diese Notiz; der Eintrag steht unten.

**Drei Plan-vs-Code-Deltas — benannt, nicht geglättet.**

- **(1) [`internal/emit/emitteddocs_test.go`](../../../../internal/emit/emitteddocs_test.go) ist im
  Diff und steht in keiner Zeile von §3.** `git show --name-only --format= b87b5f9 | grep -c emitteddocs_test`
  → **1**. Die Zelle fehlt, aber die Änderung ist **richtig und war fällig**: der Kommentar über
  `TestEmittierteDokumente_NurInitInvarianteZiele` trägt seit
  [slice-087](../done/slice-087-emittierte-doku-tische-init-invariant.md) eine **stehende
  Anweisung**; ihr Wortlaut heute:
  `grep -n 'fiele heraus, bis er hier steht' internal/emit/emitteddocs_test.go` → *„ein SECHSTER
  fiele heraus, bis er hier steht"* — die Ordnungszahl wandert mit der gedeckten Menge, die
  Anweisung nicht. Und
  [slice-097](../done/slice-097-rollen-typen-gehen-mit.md) hat einen Dokumente schreibenden Emitter
  hinzugefügt, ohne sie zu befolgen. Gemessen: über die Datei liefen **genau zwei** Commits
  (`git log --format='%h %ad %s' --date=short -- internal/emit/emitteddocs_test.go` → `b484e3a`
  2026-08-25 und `b87b5f9` 2026-08-26), und der Umsetzungs-Commit von slice-097 (`049b8a2`) ist
  keiner davon. Dieser Slice hat die Lücke geschlossen und beide Emitter eingetragen. **Das Delta
  ist die fehlende §3-Zelle, nicht die Änderung** — wer §3 als Schnittfläche liest, verpasst die
  Datei, an der dieser Slice eine fremde Schuld beglichen hat.
- **(2) DoD (3)s benanntes Rot-Kommando ist nicht gefahren worden.** Der Punkt nennt
  `make full-smoke` … *„und der Fehlerzweig zeigt seine Abwesenheit"*; hergestellt wird der
  Fehlerzweig dort nicht. Gemessen ist die **Sache** — im Go-Wächter
  `TestFeldliste_KeineFeldlisteOhneTraeger`, im Fall `170` und zusätzlich am gebootstrappten Ziel
  (Verifikation §1.2, Z7). **Das Kriterium bleibt stehen, das Delta steht hier** (die Grenze dafür
  unten).
- **(3) Der Plan sieht „je ein Fall für DoD (1), (2) und (3)" vor; gebaut sind acht.**
  `git show --name-only --format= b87b5f9 -- test/mutations/ | grep -c '^test/mutations/'` → **8**.
  **Sieben davon sind kein Delta der Sache, sondern die Auflösung der Zusagen in ihre
  Bruchstellen** — und die ist richtig: eine Zusage mit drei Gliedern (DoD (2)) hat drei
  Bruchstellen, eine mit zwei Richtungen (DoD (1)) zwei, eine mit zwei Hälften (DoD (3)) zwei. Ein
  Fall je DoD-Punkt hätte je zwei Glieder unbewacht gelassen; dass die Verifikation für 167/168/169
  je **genau einen** roten Test gemessen hat, ist der Beleg, dass die Auflösung trägt und nicht
  bloß vervielfältigt. **Der achte Fall ist das Delta, und er liegt anders — die Naht läuft nicht
  zwischen sieben und acht Fällen, sondern zwischen §2 und §3.** Fall `172` und
  `TestFeldliste_Konvergent` bewachen die Zusage *„Ein erneuter Lauf des Werkzeugs schreibt diese
  Datei kanonisch neu"* — eine Zusage, die das **Dokument über sich selbst** an den Adopter macht.
  **Kein DoD-Punkt trägt sie:**
  `sed -n '/^## 2. Definition of Done/,/^## 3. Plan/p' <diese Datei> | grep -cEi 'konvergent|erneuter Lauf|kanonisch neu'`
  → **0**. §3 nennt *konvergent* dagegen sehr wohl — genau **einmal**
  (`sed -n '/^## 3. Plan/,/^## 4. Trigger/p' <diese Datei> | grep -cEi 'konvergent'` → **1**), und
  zwar in der [`internal/emit`](../../../../internal/emit)-Zeile als **Bauart**, im Muster von
  [`MR-010`](../../../../harness/conventions.md#mr-010--d-check-gate-fragment-tool-generiert). **Die
  Konstruktion stand im Plan, die Zusage darüber und ihr Maßstab nicht** — der Weg vom einen zum
  anderen führte über keinen Plan-Punkt. Dass sie heute einen Wächter, einen Fall und einen Zahn im
  Voll-E2E-Sensor hat, ist die richtige Antwort; der Befund ist, dass eine adopter-gerichtete Zusage
  in ein emittiertes Artefakt geraten konnte, ohne durch die DoD zu gehen. **Genau dafür ist die
  Grenze aus Modul 5 da:** wer eine vierte Zusage hat, hat entweder einen vierten DoD-Punkt (und
  damit einen falschen Schnitt) oder eine Zusage ohne Maßstab.

**Der Zahn dieses achten Falls ist inzwischen belegt — und der Befund darüber ist zur Hälfte
erledigt.** Er war es beim Schreiben dieser Notiz nicht: die
[Verifikation](../../../reviews/2026-08-26-slice-098-verify.md) hatte über **7** neuen Fällen
gemessen, committet sind **8** (Kommando oben), und der Unterschied war genau dieser Zusatz —
`TestFeldliste_Konvergent`, Fall `172` und der erweiterte Idempotenz-Block in
[`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) (ab
`grep -n 'ein ZWEITER Init-Lauf ist IDEMPOTENT' harness/tools/full-smoke.sh` → Zeile **987**), also
die Behebung eines Befundes **derselben** Verifikation. Ein Nachtrag in frischem Kontext hat ihn
geschlossen und **beide Hälften des Rot selbst gesehen** (§Nachtrag, **fremdbelegt**): `make test-go`
über der Mutation **EXIT=2** mit **genau einem** roten Test, `make test-bats` über derselben
Mutation **grün** (**153** ok — die Stufenwahl ist damit in beide Richtungen gemessen, nicht
geraten), `make full-smoke` mutiert **EXIT=2** mit **genau einer** `FEHLER`-Zeile und unmutiert
**EXIT=0** in **83 s**. **Urteil dort: GEDECKT.** Für diesen Slice decken sich verifizierter und
geschlossener Baum.

**Offen bleibt die Klasse, und sie hatte keinen Träger:** nichts vergleicht den Bestand, über dem
ein Beleg erhoben wurde, mit dem, der geschlossen wird. Die zwei Zahlen standen im Repo nebeneinander
— die Verifikation nennt ihre Fall-Zahl ohnehin mit Kommando, `ls -1 test/mutations/*.sh | wc -l`
liefert die des Baumes —, und niemand hat sie gehalten. Der Closure-Trigger aus §5 fragt nach
*„`make mutate` grün mit den neuen Fällen"*, nicht danach, ob der **gemessene** Bestand der
**geschlossene** ist. Für `make gates` löst dieses Repo genau das seit langem mechanisch
([`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung):
inhaltsbasierter Stempel, `bash harness/tools/working-tree-hash.sh` gegen
`.harness/state/gates-passed.diffsha`); für die teuren Sensoren und für die Verifikation gibt es
nichts dergleichen. Der Posten steht unten mit Träger.

**Was am Plan korrigiert wurde, was bewusst stehen blieb, und wo die Grenze zwischen beidem läuft.**

Mit dem Zug nach `done/` wird diese Datei zum **Zeitdokument**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
§Geltungsbereich); eine Korrektur ist danach keine mehr, sondern ein Eingriff in die Geschichte.
Also entscheidet diese Closure, und sie sagt, was sie getan hat.

- **Korrigiert: die Tatsachenbehauptung, der Fehlerzweig sei außerhalb von Go nicht herstellbar.**
  Sie ist **widerlegt**, nicht präzisiert: die Verifikation hat den Zweig mit dem **Ziel-Binär**
  hergestellt — `.harness/state/bin` als Datei anlegen, dann Init — und dabei **EXIT 0**, den
  genannten Grund, keinen Wrapper, keinen Hook-Eintrag und keine Feldliste gesehen (§1.2, Z7;
  **fremdbelegt**). *„Nicht herstellbar"* ist eine Aussage über eine **Menge** und braucht denselben
  Beleg wie eine Zahl. **Richtig bleibt allein die schwächere Fassung:**
  [`harness/tools/full-smoke.sh`](../../../../harness/tools/full-smoke.sh) stellt den Zweig **heute**
  nicht her — sein einziger „ohne Träger"-Schritt nimmt einen bereits abgelegten Träger nachträglich
  beiseite —, und [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) hat für denselben Zweig
  dieselbe Stufe gewählt. Das ist ein Präzedenzfall für die **Wahl**, kein Beleg für
  **Unmöglichkeit**.
- **Nicht korrigiert: das Rot-Kommando von DoD (3).** Es nennt weiterhin `make full-smoke` für den
  Fehlerzweig. Eine DoD, die man am Ende an das Gebaute anpasst, hört auf, ein Maßstab zu sein; ein
  Rot-Rezept, das im Lauf nicht gefahren wurde, ist ein **Befund über den Schnitt**, und wer ihn
  wegschreibt, tilgt nur die Spur.
- **Die Grenze zwischen beiden Fällen, unverändert seit
  [slice-097](../done/slice-097-rollen-typen-gehen-mit.md) §7 und hier zum ersten Mal angewandt:**
  eine **Tatsachenbehauptung über die Welt** wird korrigiert, sobald sie widerlegt ist — sie war nie
  Maßstab, sondern Begründung. Ein **Abnahme-Kriterium samt seinem Rot-Kommando** wird nicht
  korrigiert, sondern als Delta ausgewiesen — es *ist* der Maßstab, an dem der Lauf gemessen wurde.
  Punkt (2) oben enthält beides, und die zwei Hälften stehen darum getrennt.
- **Nicht angefasst: der Code.** Vier Befunde liegen in Dateien, die der Planner nicht schreibt —
  die zweite Fassung der Incident-Fragen, die unrichtige Zutat im dritten Grenz-Satz und der vierte
  Fundort der Rollen-Namen in [`internal/span`](../../../../internal/span), dazu die acht Wächter
  ohne Fall in den zwei `_test.go` und in `test/mutations/`. Alle vier stehen unten mit Träger.

**Was der Slice nicht deckt — die Grenzen, die er für sich selbst zieht.**

- **Bewacht ist die Anwesenheit der drei Sätze, nicht ihre Wahrheit.** §6 hat das vorab gesagt, und
  es hat sich als richtig und als teuer erwiesen: eine der drei Aussagen ist am Ziel **gemessen
  unrichtig** (der Zusatz über die Lesbarkeit des Bestands, s. unten). Ein Wächter über der Wahrheit
  der ersten beiden Sätze wäre einer über einem fremden Vertrag — über der **dritten** wäre er
  keiner, denn den Modus setzt unser eigener Träger. Diese Unterscheidung fehlte im Plan.
- **Die Ortszusage gilt der emittierten Konfiguration, nicht der des Adopters.** `.d-check.yml` ist
  `skip-if-present`: legt er vor dem Bootstrap eine eigene hin oder ändert er die emittierte — genau
  wofür die Klasse gewählt ist —, gilt sein `scan.ignore`, und *„liegt im geprüften Bereich"* ist
  eine Aussage über **seine** Konfiguration, die niemand hält. Der Go-Wächter misst korrekt die
  **emittierte** Config und sagt das auch; **im Dokument steht es nicht**, und im Plan stand es
  ebenfalls nicht.
- **Das Dokument ist im Ziel ein Waise.** Nichts verweist auf es — selbst gemessen am Probe-Ziel
  von oben:
  `grep -rl "erfassung-feldliste" "$p" --include='*.md' --include='Makefile' --include='*.mk' --include='*.yml' | wc -l`
  → **0**; nicht einmal das Dokument nennt seinen eigenen Pfad. Und sein einziger Handlungssatz
  nennt das Werkzeug nicht, dessen Lauf ihn ausführt. Beides folgt aus richtigen Entscheidungen — kein Markdown-Verweis wegen der
  Gate-Sicherheit, kein `make`-Ziel wegen
  [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) —, aber
  die Folge stand nirgends. Ihr Ort ist
  [slice-099](../open/slice-099-leser-und-aufraeum-kommando.md), wo Leser und Aufräum-Kommando
  zusammenkommen.
- **Der Abgleich im Voll-E2E-Sensor deckt die geschriebene Zeile, nicht die Tabelle.** Die
  synthetische Nutzlast ist ein Kommando-Aufruf; sie bringt **17** der **32** Feldnamen in den
  Vergleich (Verifikation §6, V-12, **fremdbelegt**). Die Meldung behauptet nichts anderes — sie
  sagt *„der geschriebenen Span-Zeile"* —, aber *„deckt die Zeile"* wird leicht als *„deckt die
  Tabelle"* gelesen.

**Steering-Loop-Eintrag — geschärfte Regel.**

**Ein Kommentar, der die Kopplung einer bewachten Menge beschreibt, ist eine stehende Anweisung an
den, der diese Menge erweitert. Wer ihr ein Element hinzufügt, liest den Kommentar an der Stelle,
die sie bewacht — kein Gate stellt ihn zu.**

**Warum diese und nicht die andere Lehre dieses Laufs.** Zur Wahl stand der widerlegte Satz
*„nicht herstellbar"*; er ist oben als **Korrektur** eingelöst und deckt sich in der Klasse mit dem
fünften Posten von [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) (eine
Aussage über eine Menge braucht denselben Beleg wie eine Zahl). Der Kommentar-Posten ist neu, und
er ist die **Kehrseite** der gestrigen Lehre: dort war der Text eines Wächters nur im **Rot**
sichtbar, hier ist er nur im **Quelltext** sichtbar — und beide Male hat ihn niemand gelesen. Zwei
Sichtbarkeits-Lücken desselben Artefakts sind ein Muster, kein Zufall.

**Und die gestrige Lehre hat in diesem Lauf ihre erste live gemessene Instanz bekommen** — nicht
als Analogie, sondern an einem hergestellten Zustand: der Idempotenz-Zahn im Voll-E2E-Sensor
begründet seinen Treffer mit *„konvergent verletzt"*, während der Code sich nach DoD (3) **richtig**
verhalten hat und die Feldliste ohne abgelegten Träger zu Recht nicht neu schrieb. Die **Go**-Hälfte
desselben Zusatzes hat die Abtrennung (`notice.Len() != 0` → eigene Meldung), die **E2E**-Hälfte
nicht; die Asymmetrie liegt damit **innerhalb** eines Delta, nicht zwischen zwei Slices. Dass der
sechste Posten von [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) damit binnen
eines Tages einen zweiten, unabhängig gefundenen Beleg trägt, ist ein Argument für seinen Termin,
nicht gegen seine Formulierung.

**Der gemessene Anlass.** Der Satz stand seit
[slice-087](../done/slice-087-emittierte-doku-tische-init-invariant.md) unverändert da;
[slice-097](../done/slice-097-rollen-typen-gehen-mit.md) hat einen vierten Dokumente schreibenden
Emitter hinzugefügt und ihn nicht befolgt; **kein Gate** hat es gemeldet. Die zwei Commits über der
Datei sind oben gezählt. Folgenlos blieb die Lücke nur, weil die sechs neuen Vorlagen genau ein
`make`-Ziel behaupten, das die Init-Phase wirklich schreibt
(`grep -ho 'make [a-z-]*' internal/emit/templates/agents/*.md | sort -u` → `make gates`) — ein
künftiger Anspruch wäre durch genau den Wächter nicht gefangen worden, der dafür existiert.

**Warum eine Regel und kein Sensor.** Die Eigenschaft — *ein Kommentar, der eine Anweisung an eine
künftige Erweiterung der bewachten Menge trägt* — ist ein Urteil über Prosa. Ein Muster darüber
liefert
`git grep -nE '^[[:space:]]*(//|#).*(fiele heraus|faellt heraus|bis (er|sie|es) hier steht)' -- 'internal/*.go' 'internal/**/*.go' 'cmd/**/*.go' 'harness/tools/*.sh' '.claude/hooks/*.sh'`
→ **2** Treffer, davon ist **einer** eine Beschreibung statt einer Anweisung: das Muster trennt die
Klasse nicht einmal auf zwei Treffern. Und die zwei Gates, die in der Nähe stehen, können es
bauartbedingt nicht: `make comment-claims` nimmt `_test[.]go` dauerhaft aus
([slice-070](../open/slice-070-comment-claims-pruefbereich.md) §1, dritte Verengung), und
`make mutate` prüft, ob ein gelisteter Wächter fällt — nie, ob seine gedeckte **Menge** noch stimmt.

**Der Regeltext wird hier nicht vorentschieden**; er entsteht im Architect-Lauf
([`AGENTS.md`](../../../../AGENTS.md) §3.8). Diese Notiz liefert die Formulierung, den Anlass und
die Messung.

**Träger: [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) — als siebter
Posten, ausdrücklich nicht *„der Architect"*.** Er ist dort eingetragen, mit dem Merkmal, an dem er
als weiterer Posten erkannt ist: er **hebt** wie die sechs anderen eine Beleg-Anforderung an und hat
dieselbe Herkunft — eine Closure, die ihn formuliert, gemessen und niemandem gegeben hat.
Verschieden ist die **Regel**: er hängt an [`AGENTS.md`](../../../../AGENTS.md) **§3.7**, wo
*Kopplung* eine der fünf Kommentar-Klassen ist und wo steht, ein Kommentar schreibe *„an den, der
die Stelle **ändert**"*. Was §3.7 für das **Schreiben** sagt, sagt keine Regel für das **Lesen**;
genau diese Hälfte fehlt.

**Offen, mit Träger.** Jeder Befund aus Review und Verifikation trägt einen Ausgang — eigener
Schnitt, vorhandener Träger oder Ablehnung mit Grund. *„Genannt"* ist seit
[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md) keiner.

| Posten | Träger |
|---|---|
| `span.SchemaNotes()` ist eine zweite, von Hand geschriebene Ausfertigung der Incident-Fragen, die [`spec/spezifikation.md`](../../../../spec/spezifikation.md) §5 schon trägt — die Feldnamen-**Mengen** sind deckungsgleich (**32** gegen **26** Zeilen mit **6** Doppel-Feldern), der **Wortlaut** divergiert bereits, und [`ADR-0013`](../../adr/0013-technik-stratum-als-zielort.md) Festlegung 1 macht §5 zum Rang-2-Zielort derselben Tatsache | **[slice-109](../open/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md)** — neu geschnitten, DoD (1) |
| Der Satz *„wer dieses Arbeitsverzeichnis lesen kann, liest ihn"* steht gegen gemessene **755**/**600** und stammt **nicht** aus [`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren); er behauptet mehr Offenheit, als besteht — fail-closed, aber unrichtig, und in einem fremden Repo | **[slice-109](../open/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md)** — neu geschnitten, DoD (2). Dieselbe Datei, dieselbe Frage: woher kommt dieser Satz? |
| Die echte Span-Zeile trägt `"sha256_16"`, während [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 6 *„ohne Inhalts-Hash"* sagt und [`ADR-0011`](../../adr/0011-telemetrie-erfassung-policy.md) Festlegung 2 eine Ebenen-Unterscheidung annimmt, die der Code nicht kennt (`grep -c "Ebene" internal/span/emit.go` → **0**) | **[slice-107](../open/slice-107-inhalts-hash-traegt-eine-entscheidung.md)** — neu geschnitten. Der **Termin** für den Architect, nicht der Entscheidungstext: ADRs sind ab *Accepted* immutabel ([`AGENTS.md`](../../../../AGENTS.md) §3.4), also ist die Korrektur eine neue Entscheidung, und die schreibt der Architect ([`ADR-0015`](../../adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1) |
| Acht der fünfzehn neuen Go-Wächter haben keinen Fall in `test/mutations/`; vier davon hat die Verifikation erstmals rot gesehen, vier keiner. Nach [`AGENTS.md`](../../../../AGENTS.md) §3.6 gilt, wer keinen Fall hat, als unbewacht | **[slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md)** — neu geschnitten. **Nicht** [slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md): jener ist der Durchgang über die Wächter der **Träger-Ablage** ([`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1 und 5); hier geht es um die des **Dokuments** (Festlegung 7). Gleiche Form, anderer Vertrag |
| Die sechs kanonischen Rollen-Namen stehen an **vier** Produktions-Fundorten, und der vierte wird als **erster ins Ziel emittiert** | **[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md)** — nachgezogen: §1 beziffert jetzt vier, die Tabelle führt den neuen Fundort, §3 bekommt seine Zeile und **Frage C** (in welcher Form er ableitet — er ändert die Bytes einer Adopter-Datei). Die Kriterien sind **unverändert**: DoD (1) verlangt weiterhin die Zahl **1** |
| `comment-claims` kippt seinen Roh-String-Zustand an jeder Zeile mit ungerader Backtick-Zahl — über dem eigenen Prüfbereich **11** Dateien mit **121** solchen Zeilen, drei davon Shell-Dateien ohne jeden Go-Roh-String, und **2** Zusage-Zeilen werden heute übersprungen | **[slice-070](../open/slice-070-comment-claims-pruefbereich.md)** — aufgenommen als **vierte Verengung** in §1, gebunden in DoD (1) und mit der Ist-Messung in §3. Er ist der Träger für die Defekte genau dieser Datei und führte schon drei; ein eigener Schnitt schriebe dieselbe Meldezeile ein zweites Mal um |
| `full-smoke.sh`s `FELDLISTE_REL` dupliziert `emit.FieldListPath` | **kein Träger, und das ist entschieden** — s. die Begründung unten |
| Die Ortszusage gilt der **emittierten** `.d-check.yml`; eine eigene Adopter-Config hebt sie auf. Im Code benannt, im Dokument nicht | **[slice-109](../open/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md)** — es ist dieselbe Frage wie beim dritten Grenz-Satz: sagt das Dokument, was gilt? Der Satz gehört in denselben Durchgang, weil er dieselbe Datei und dieselbe Leserichtung betrifft |
| `feldliste_im_ziel` begründet den Treffer *„Datei fehlt"* mit *„liegt nicht im geprüften Bereich"* — für Fall 171 trifft das zu, für den zweiten Treffer derselben Bedingung (das Dokument entsteht gar nicht) nicht | **zwei Träger, weil es zwei Sachen sind.** Die **Klasse** — eine Begründung, die nur einen ihrer Treffer erklärt — liegt bei [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), sechstem Posten; er **ist** diese Klasse, wörtlich. Die **konkrete Meldung** liegt bei [slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md) als §3-Zelle: jener Slice sieht genau diese Zähne rot, und ein Posten ohne Ort in einer Plan-Tabelle bleibt in diesem Repo gemessen wirkungslos |
| Der Idempotenz-Zahn im Voll-E2E-Sensor liest vom zweiten Init-Lauf **nur** den Exit-Code, und der ist im Fehlerzweig **0**; seine Meldung nennt dann *„konvergent verletzt"*, obwohl der Code sich nach DoD (3) **richtig** verhalten hat. Der Zustand ist mit dem Ziel-Binär hergestellt worden, der Unterscheider ist gemessen (`grep -c 'Erfassungsschicht nicht abgelegt'` → **0** grün · **0** mutiert · **1** Grenzfall) | **[slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md)** als §3-Zelle, zusammen mit der Meldung eine Zeile höher — dieselbe Datei, dieselben Zähne, dieselbe Frage. **Nicht [slice-103](../open/slice-103-traeger-waechter-decken-was-sie-sagen.md):** dessen Gegenstand sind Assertions in [`internal/emit/enforce_test.go`](../../../../internal/emit/enforce_test.go) über [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1 und 5; hier liegt eine Shell-Meldung über Festlegung 7. Anderer Vertrag, andere Datei — ihn aufzunehmen verschöbe seinen Gegenstand. Die **Klasse** trägt weiterhin [slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md), sechster Posten; dies ist ihre erste **live gemessene** Instanz |
| Dieselbe Hälfte misst *„die Marke ist weg"*, nicht *„der kanonische Stand"* — die Go-Hälfte lehnt genau diesen Kurzschluss im Kommentar ab und hält ihn (`== span.FieldList()`), das OK-Echo bietet dem Leser aber die stärkere Aussage an | **[slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md)**, dieselbe §3-Zelle. Kein Loch in der Zusage — das Paar trägt sie zusammen —, sondern eine **Ungleichheit der zwei Hälften**, und der Preis ihrer Behebung ist eine Kopie vor der Drift plus ein `cmp` danach |
| Die beidseitige Kopplung zwischen Wächter und Fall (`_test.go` nennt den Fall, der Fall nennt den Treiber) ist heute wahr, aber unbewacht: `make comment-claims` nimmt `_test[.]go` dauerhaft aus | **[slice-070](../open/slice-070-comment-claims-pruefbereich.md)** — **vorhandener Träger, ohne Nachzug.** Die dritte Verengung in seinem §1 **ist** dieser Ausschluss; eine weitere Instanz derselben Verengung ändert seinen Schnitt nicht und macht seine DoD nicht schärfer. Ein Posten, der einen Träger nur bestätigt, gehört gezählt, nicht eingetragen |
| Das emittierte Dokument trägt **zwei** Sätze mit *„erneuter Lauf"*: der eine ist die bewachte Konvergenz-Zusage, der andere sagt konditional etwas über die **Wiederablage des Trägers** und liegt damit im Vertrag von [`ADR-0022`](../../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 1/5 | **kein Posten, und das ist entschieden** — der zweite Satz ist wahr, konditional formuliert und von den Wächtern aus [slice-096](../done/slice-096-traeger-liegt-im-ziel.md) gedeckt. Was daraus folgt, ist eine **Präzision**, kein Befund: sie steht in [slice-109](../open/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) §6, damit der Lauf, der an diesen Sätzen arbeitet, sie nicht zusammenzieht |
| Nichts vergleicht den Bestand, über dem ein Beleg erhoben wurde, mit dem, der geschlossen wird — für `make gates` löst [`MR-003`](../../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung) genau das seit langem inhaltsbasiert, für die teuren Sensoren und die Verifikation gibt es nichts dergleichen | **[slice-101](../open/slice-101-norm-postens-bekommen-einen-termin.md)** — als **achter Posten**, dort eingetragen. **Kein eigener Schnitt:** sein Ergebnis wäre Norm-Text über Belege, und genau dafür existiert jener Durchgang; ein zweiter Slice derselben Form verdoppelte den Termin-Mechanismus. **Kein `verify-closure-notes`-Target, an das ein Sensor hängen könnte:** `grep -rn 'verify-closure-notes' Makefile harness/` → **leer** |

**Die eine Ablehnung, mit Grund: `FELDLISTE_REL` bleibt ein Literal.** Drei Gründe, keiner davon
Aufwand. **Erstens** hält das Literal die Eigenschaft nicht, um die es geht:
*„liegt im geprüften Bereich"* misst `TestFeldliste_LiegtImGeprueftenBereich` gegen die
**emittierte** `.d-check.yml` und die Konstante — nicht gegen einen abgeschriebenen Pfad.
**Zweitens** wäre eine Ableitung aus dem Binär genau die Zirkularität, die
[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md) §Die Grenze für die Test-Tabelle
ausschließt: der Sensor fragte das Programm, wohin es geschrieben hat, und prüfte dann, dass es dort
liegt. Für die Rollen-Namen gibt es einen zweiten, unabhängigen Baum
(`internal/emit/templates/agents/`), aus dem abgeleitet werden **kann**; für diesen Pfad gibt es
keinen. Das Literal ist die **zweite Aussage**, und sie hat Zähne: Fall `171` ändert eine Seite und
färbt rot. **Drittens** verschöbe eine Aufnahme in
[slice-104](../open/slice-104-rollen-namen-haben-eine-quelle.md) dessen Gegenstand vom *Satz der
sechs Namen* auf *jeden Wert, den der Sensor abschreibt* — ein anderer Schnitt mit einer anderen
Messung. **Was offen bleibt und hier steht:** ändert jemand beide Literale im Gleichschritt auf
einen anderen Pfad im geprüften Bereich, bleibt alles grün. Das ist bei einem vertragshaltenden
Literal der gewollte Fall, kein Loch.

**Folge-Slices: drei neue `open/`-Einträge.**
[slice-107](../open/slice-107-inhalts-hash-traegt-eine-entscheidung.md) (der Widerspruch über den
Inhalts-Hash bekommt einen Ausgang),
[slice-108](../open/slice-108-feldlisten-waechter-tragen-ihren-fall.md) (die acht Wächter ohne Fall)
und [slice-109](../open/slice-109-feldliste-jede-aussage-hat-ihre-quelle.md) (jede Aussage der
Feldliste hat ihre Quelle). **Alle drei sind wellenlos** — die drei Fragen aus
[`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 1 sind in ihren Kopfzeilen einzeln beantwortet, und keiner füllt oder leert eine Zelle der
Abdeckungs-Tabelle von [welle-12](../welle-12-erfassungsschicht-emittieren.md): die Zeilen
*„Redaktion"* und *„Benannte Grenze"* sind mit diesem Slice geliefert, und
[`LH-FA-10`](../../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) nennt den
Fingerabdruck selbst, sodass auch
[slice-107](../open/slice-107-inhalts-hash-traegt-eine-entscheidung.md) das Kriterium in jedem
seiner Ausgänge erfüllt lässt. Die Roadmap bekommt daher keinen Eintrag
([`MR-016`](../../../../harness/conventions.md#mr-016--welle-oder-nicht-und-wo-wellenlose-arbeit-geführt-wird)
Setzung 2).

**Die Welle bekommt keinen Fortschritts-Eintrag.** Der Zustand jedes Slice ist sein
Lifecycle-Verzeichnis; §4 der Welle sagt es, und die Roadmap sagt es noch einmal. Offen bleibt allein
[slice-099](../open/slice-099-leser-und-aufraeum-kommando.md).

**Gates.** Eigener Lauf über dem Baum, den diese Closure hinterlässt — Notiz, die drei neuen Slices
und die vier nachgezogenen Pläne eingerechnet, und über dem Verifikations-Nachtrag: `make gates`
**EXIT=0**, `baseline-verify: v3.5.2 OK — 42 Dateien`,
`d-check: 399 Datei(en) geprüft, 0 Befund(e)`, golangci-lint `0 issues.`, bats
`grep -c '^ok '` → **153** und `grep -c '^not ok'` → **0**,
`comment-claims: 44 Datei(en) geprueft, 0 Befund(e)`, `span-check` grün; danach sind
`bash harness/tools/working-tree-hash.sh` und `.harness/state/gates-passed.diffsha` byte-gleich. Die
Dateizahl des Doku-Gates wandert mit dem Markdown-Bestand und ist **kein** Erwartungswert. Die zwei
teuren Sensoren stehen oben als **fremdbelegt** — `make full-smoke` zweimal, davon einmal über
einem Baum mit dem achten Fall; `make mutate` über einem Baum ohne ihn, ergänzt um den Einzellauf
des achten.

## 8. Sub-Area-Modus-Begründung

Alle berührten Sub-Areas GF (siehe Kurs Modul 5 §Worked Mini-Example): `internal/span/`,
`internal/emit/`, `harness/tools/` und `test/` gehören zum Greenfield-Bestand; der Modus steht in
der Modus-Deklaration von [`harness/conventions.md`](../../../../harness/conventions.md).
