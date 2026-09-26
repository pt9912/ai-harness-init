# Slice slice-form-regel-des-nachzugs-ist-an-die-codepaths-ausnahme-gekoppelt: Ein bats-Fall hält die Zeile unter `codepaths:` gegen die Form-Regel des Nachzugs

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle — dieser Slice trägt keine Closure-Bedingung, die über seine
DoD hinaus etwas beobachtet, siehe Baseline-Regelwerk `modul-06-roadmap.md`
§Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:** [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
(`Accepted`; Folgepflicht 4 und Fitness-Zeile 6),
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(ein Gate sagt nur über seinen Prüfbereich etwas; der Prüfbereich wird hier nicht verkleinert).

**Berührte Spec-Stellen:** `—` — Prozess-ADR ohne Spec-Stratum: sie ändert die
Reichweite eines Werkzeugs, keine Spec-Aussage und keine Gate-Schwelle.
Der Verweis zeigt **aufwärts**: Die Spec nennt diesen Slice nie
(Baseline-Regelwerk `grundlagen-referenz-richtung.md`
§Referenz-Richtung (SDP), `grundlagen-source-precedence.md` §ID-Schema als Klammer).

**Verantwortlich:** Implementer (pt9912).

**Autor:** Planner. **Datum:** 2026-09-26.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Ein bats-Fall im Stil von `test/sources-pin.bats` hält die Zeile
`exempt-paths: ["docs/reviews/**"]` unter `codepaths:` in `.d-check.yml` gegen die Form-Regel des
Nachzugs: Fällt die Zeile und die Form-Regel bleibt, färbt der Test rot
([`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
Folgepflicht 4, Fitness-Zeile 6). Die Form-Regel besteht nur, solange das Gate die Code-Span-Form in
`docs/reviews/**` nicht prüft; der Test macht diese Abhängigkeit zu einer Zusage zwischen zwei
Dateien.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Träger der Form-Regel** — zwei Folge-Slices übernehmen sie:
  `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` (`make slice-mv`) und
  `slice-archive-welle-schreibt-in-reports-nur-die-link-form` (`archive-welle`). Dieser Slice
  **folgt** beiden (§4): davor bewachte der Test eine Regel, die kein Träger führt.
- **Eine Änderung an `.d-check.yml`** — die Datei bleibt unberührt, die Kopplung steht im Test, nicht
  in einem Kommentar der Config; und die Entscheidung in
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md)
  Festlegung 2 ist ausdrücklich keine Senkung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5.
- **Die Wahrheit der Gate-Begründung** — der Test hält, dass die Zeile **da ist**, nicht dass
  `codepaths` einen Pfad-Span in einem Report tatsächlich nicht prüft; das wäre ein Lauf des
  Doku-Gates gegen eine konstruierte Probe, und die Aussage ist in der ADR als Messung geführt, für
  die kein Sensor existiert.
- **Die Gegenrichtung: ob die Form-Regel in den Trägern noch steht** — der Test hält die **Bedingung**
  (die Zeile), nicht die Implikation *Regel ⇒ Zeile*. Fällt die Zeile, färbt er rot, gleichgültig ob
  die Träger die Regel noch führen; das ist gewollt, denn dann greift Re-Evaluierungs-Trigger 1 der
  ADR (die Regel ist zu streichen, ein Folge-ADR-Vorgang), und ein grüner Test darüber wäre ein
  stilles Grün. Seine Meldung nennt deshalb die Zeile **und** den Trigger. Die Träger-Seite halten die
  Fälle in `test/slice-mv.bats` und in `internal/archive` (`docs/reviews` ist **nicht** in
  `eingehend_ausgenommene_pfade` in `harness/tools/slice-mv.sh` und nicht in `AusgenommenePfade()` in
  `internal/archive/scan.go` — Bestand, dort gebunden, kein Gegenstand dieses Slice).
- **Die emittierte Fassung** (`internal/emit/templates/enforce/slice-mv.sh`) — sie führt die Form-Regel
  nicht und liest ihre Ausnahmen aus `SLICE_MV_AUSGENOMMENE_PFADE`; der Test gilt dem Dogfood-Repo und
  wird nicht emittiert (Schicht-Abgrenzung; `harness/sensors/slice-mv.md` §Im gebootstrappten Ziel).
- **Trigger 2 der ADR (`links` bekommt für `docs/reviews/**` eine Ausnahme)** — die ADR verlangt
  dafür keinen Fall (Fitness-Zeile 6 nennt nur die `codepaths`-Zeile), und eine Zusage ohne rot
  gesehenes Gegenbeispiel wäre [`AGENTS.md`](../../../../AGENTS.md) §3.6 verletzt.

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

- [ ] **Liefer-Punkt 1 — der Kopplungs-Test.** Ein bats-Fall hält die Zeile
      `exempt-paths: ["docs/reviews/**"]` **unter `codepaths:`** in `.d-check.yml`; in dieser Datei
      tragen andere Blöcke `docs/reviews/**` in eigenen `exempt-paths`-Zeilen, und der Fall bindet
      allein die unter `codepaths:`. *Bricht, wenn:* die Zeile unter `codepaths:` entfällt und die
      Form-Regel bleibt — der Test färbt rot, und seine Meldung nennt die `codepaths`-Zeile
      (Rot ist gesehen **und** die Meldung gelesen, und sie nennt neben der Zeile den
      Re-Evaluierungs-Trigger 1 der ADR); eine andere `exempt-paths`-Zeile mit
      `docs/reviews/**` zu entfernen lässt ihn grün, ebenso das Entfernen oder Ändern der
      Kommentarzeile im Block — und die Zeile als **Kommentar** zu setzen statt zu entfernen färbt
      ihn rot.
- [ ] **Liefer-Punkt 2 — der Mutations-Fall, der ihn bindet.** Ein Fall in `test/mutations/` entfernt
      die Zeile unter `codepaths:` in einer Kopie und erwartet genau diesen Test rot. *Bricht, wenn:*
      der Fall auch bei einer Mutation rot bliebe, die eine **andere** Zeile trifft (dann deckt ein
      anderer Zweig ihn, und der Zahn ist unbewacht); Anker gegen den Quell-Bestand gemessen
      ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — neues Verzeichnis `BEO-<KUERZEL>/<slug>/` oder eine weitere Datei in dessen `evidence/`; **kein Zaehler wird gesetzt**, er folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7 notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne** Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| eine bats-Datei unter `test/` | neu | Liefer-Punkt 1: Kopplungs-Fall im Stil von `test/sources-pin.bats` (nur Datei-Vergleich, netzlos, läuft in `make gates`) |
| `test/mutations/` | neu | Liefer-Punkt 2: ein Fall, der die Zeile unter `codepaths:` entfernt; Anker gegen den Quell-Bestand gemessen |

- **Größenurteil.** Zwei Liefer-Punkte, eine Schicht (Test gegen Config). Der Schnitt trennt den
  Test von den Trägern, weil er eine Config-Zeile hält und keinen Träger-Code; die Begründung
  steht im Geschwister `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form`, §3.
- **Ansatz.** Der Fall liest den Abschnitt `codepaths:` der `.d-check.yml` und sucht die Zeile
  **darin**, nicht irgendwo in der Datei; die Kopplung wird im Kommentar des Tests als Kopplung
  genannt, mit
  [`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) als
  Rang-Zeiger.
- **Schicht und Lauf.** Ein bats-Fall in `test/` (Text gegen Text, kein Container-Aufruf, netzlos)
  läuft in `make test-bats`, damit in `make test` und `make gates`; eine Go-Test-Fassung entfällt,
  weil beide Seiten der Kopplung Text sind und die Go-Liste nicht Gegenstand ist (§1). Die Wahl der
  Abschnitts-Erkennung — Werkzeug und Muster — bleibt beim Implementer; gebunden ist, was sie liefern
  muss: nur Zeilen unter dem Top-Level-Schlüssel `codepaths:` bis zum nächsten Top-Level-Schlüssel
  (`vcs:` am Stand der Planung), **Kommentarzeilen ausgenommen**.
- **Gemessen am Baum (2026-09-26, keine Erwartungswerte).** Die Zielzeile steht genau einmal, mit
  zwei Zeichen Einrückung: `grep -c '^  exempt-paths: \["docs/reviews/\*\*"\]$' .d-check.yml` gibt 1
  aus. Vier weitere Zeilen der Datei tragen `exempt-paths` **und** `docs/reviews/**` — drei unter
  `ids` (mit `CHANGELOG.md`), eine unter `matrix` mit eigener Liste — und die **Kommentarzeile**
  darüber, im Block `codepaths:` selbst, nennt beide Wörter ebenfalls
  (`grep -n 'exempt-paths' .d-check.yml | grep 'reviews'` zählt sechs Zeilen). Ein Muster über die
  ganze Datei oder über den Block ohne Kommentar-Ausschluss bliebe bei entfernter Zeile grün.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): `slice-lifecycle-move-schreibt-in-reports-nur-die-link-form` **und**
`slice-archive-welle-schreibt-in-reports-nur-die-link-form` liegen in `done/`
(`ls docs/plan/planning/done | grep -c -e slice-lifecycle-move-schreibt-in-reports-nur-die-link-form -e slice-archive-welle-schreibt-in-reports-nur-die-link-form`
gibt 2 aus) — kein Ergebnis dieses Slice, also ein zulässiger Start-Trigger. Beide Träger liegen in `done/`; das Kommando gibt am 2026-09-26 **2** aus, der Trigger ist damit
eingetreten.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): der Fall lässt sich nicht an den Abschnitt
  `codepaths:` binden, ohne die `.d-check.yml` zu parsen — dann ist das ein Werkzeug-Bau, kein Test.
- `in-progress` → `open` (blockiert): `codepaths.exempt-paths` nimmt `docs/reviews/**` nicht mehr
  aus (Re-Evaluierungs-Trigger 1 der ADR) — die Form-Regel ist dann zu streichen und dieser Slice
  gegenstandslos, er geht als Stilllegung nach `done/`.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Der Kopplungs-Fall läuft in `make gates` grün, und der Rot-Beleg aus der DoD ist einmal gesehen
   und in seiner Meldung gelesen; wo der Implementer-Bericht ihn nicht führt, trägt der Verifier
   ihn nach (Baseline-Regelwerk `modul-11-verification.md` §Bewusstes Brechen für
   DoD-Testbehauptungen).
2. Der Mutations-Fall färbt genau diesen Test rot (`make mutate` fährt ihn; kein Gate).

Der Lerneintrag steht in §7 in einer der drei Formen.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

Die Ausgänge stehen als Vorschau da; gesetzt werden sie bei der Closure.

- **Der Test greift die falsche Zeile** — eine andere `exempt-paths`-Zeile mit `docs/reviews/**`
  (unter `ids`, `matrix` oder einem anderen Block) **oder die Kommentarzeile im Block `codepaths:`**
  hielte ihn grün, wenn die Zeile unter `codepaths:` entfällt.
  **Ausgang:** *entfallen*, wenn die Gegenprobe — die Zeile unter `codepaths:` entfernt — ihn rot
  färbt und eine andere Zeile entfernt ihn grün lässt; und die Schärfe ist gebunden, wenn der
  Test in einer Kopie **geschwächt** (Muster über die ganze Datei statt über den Block) bei
  **entfernter** Zeile **grün** bleibt — grün heißt hier: die Block-Bindung ist es, die ihn rot
  gefärbt hat, und der Mutations-Fall meldet an dieser Kopie `BEFUND`. Färbt er den geschwächten Test
  dagegen rot, deckt ein anderer Zweig ihn, und der Zahn ist unbewacht.
- **Der Anker des Mutations-Falls liegt verschoben**
  ([`MR-071`](../../../../harness/conventions.md#mr-071--die-fall-anlage-misst-ihre-sed-muster-gegen-den-quell-bestand)).
  **Ausgang:** *entfallen*, wenn der Anker gegen `.d-check.yml` am Stand der Implementation
  gemessen und der Fall an genau der behaupteten Mutation rot gesehen ist; sonst *eingetreten* und
  im Slice behoben.
- **Der Test bewacht eine Regel, die kein Träger führt** — folgt er den Trägern nicht (§4), ist er
  ein Zeiger ohne Gegenstand. **Ausgang:** *entfallen*, solange der Start-Trigger die zwei Träger
  verlangt.

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene `BEO-<NNN>` **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks). Ging der Gegenstand an einen anderen Slice oder entfiel er, trägt
diese Sektion die Zeile `Gegenstand:` mit Kennung oder Grund und jedes Risiko
aus §6 seinen Ausgang; die Liefer-Punkte der DoD bleiben leer
(`modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein anderer
übernimmt).

Wird bei der Closure vom Planner geschrieben
([`AGENTS.md`](../../../../AGENTS.md) §3.10), nicht vom Implementer; die Zeilen folgen der Vorlage.

- **Was hat funktioniert:** —
- **Was ging anders als geplant:** —
- **Steering-Loop-Eintrag:** —
- **Beobachtungs-Register (`../observations/`):** —
- **Folge-Slices:** —
- **Risiken aus §6:** —
- **Drei Paarungen:** —

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

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt ist `*` (gesamtes Repo), so, wie die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) sie
führt; eine neue oder gröbere Sub-Area entsteht nicht. Die Schwelle von 2 aus 3 Achsen ist an
diesem Eintrag nicht neu gemessen.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; der Gegenstand ist
die Kopplung einer Regel an eine Config-Zeile, und die Beobachtung, die ihn trägt, ist
[`verweis-nachzug-ersetzt-eine-historisch-richtige-adresse`](../observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/observation.md).
Ihr Zähler ist die Zahl der Dateien unter ihrem `evidence/` (Stand 2026-09-26; keine Erwartungswerte,
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)):

```sh
ls docs/plan/planning/observations/BEO-ALL/verweis-nachzug-ersetzt-eine-historisch-richtige-adresse/evidence/*.md | wc -l   # 6
```

Sie steht über der Schwelle und ist `verkörpert` (Zielort:
[`ADR-0070`](../../adr/0070-der-verweis-nachzug-schreibt-in-docs-reviews-nur-die-link-form.md) neben
[`ADR-0042`](../../adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md)); mit diesem Slice tritt
kein Eintrag erstmals über 3×. Ein Wächter für die Kopplung ist genau die Lücke, die ihr Stand als
Grenze der Verkörperung nennt; dieser Slice schließt sie.

Die übrigen Einträge der Sub-Area `*`, die dieselbe Fläche berühren, sind gelesen (Stand 2026-09-26,
Zähler wie oben je `ls …/<slug>/evidence/*.md | wc -l`, keine Erwartungswerte). Kein Eintrag erreicht
mit diesem Slice erstmals 3×:

| Eintrag | Zähler | Stand | Bezug zu diesem Slice |
|---|---|---|---|
| `ausnahmeliste-nur-auf-form-geprueft` | 4 | geplant (`slice-ausnahmeliste-bekommt-ihre-berechtigungs-pruefung`) | verwandt: der Test hält eine deklarierte Ausnahme gegen ihre Begründung, nur diese eine Zeile; die allgemeine Prüfung der Berechtigung ist dort, nicht hier |
| `gate-zusage-in-prosa-reicht-weiter-als-ihr-pruefumfang` | 2 | offen | trifft die Formulierung: der Test hält **die Zeile**, nicht die Wahrheit der Gate-Begründung — §1 nennt es, und Testname wie Kommentar tragen es ebenso |
| `zusage-mit-bats-bindung-ohne-eigenen-mutations-fall` | 4 | verkörpert (`AGENTS.md` §3.6) für die Klasse | Liefer-Punkt 2 ist genau der Fall, den die Klasse verlangt |
| `regel-rand-ohne-benannte-luecke` | 2 | offen | berührt die Sensor-Doku, nicht diesen Test |
| `kommentar-begruendet-die-gemeinsame-liste-nur-fuer-einen-ihrer-leser` | 1 | offen | betrifft `internal/archive/scan.go`; dieser Slice fasst die Datei nicht an, sein Zähler bewegt sich nicht |
| `nachzug-raender-am-doku-gate-ohne-melder-oder-ohne-nennung` | 1 | offen | betrifft die Referenz-Definition; kein Gegenstand hier (§1, Trigger 7 der ADR) |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

Alle berührten Sub-Areas GF.
