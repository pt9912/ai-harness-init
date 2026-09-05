# Slice slice-188: Der Archiv-Stub kennt die Kennungs-Form des Registers

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die über die DoD unten hinausgeht: der
Beleg ist ein Test, der die Eigenschaft misst, und `make gates`. Baseline-Regelwerk
`modul-06-roadmap.md` §Wann Arbeit eine Welle braucht (Modul 6).

**Bezug:**
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (der
Zahn, der die abgelöste Form festhält, ist ein grünes Gate über einer Zusage, die nicht mehr
gilt),
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (das Unterkommando, dessen
Stub-Feld hier repariert wird),
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
(die Kennungs-Gestalt `BEO-<KUERZEL>/<slug>`, die der Stub-Bau nicht kennt),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben ihrem Kommando).

**Berührte Spec-Stellen:** `—`. Der Slice repariert eine Kennungs-Erkennung; er schreibt keine
Spec-Stelle.

**Verantwortlich:** `—` bis zur Priorisierung.

**Autor:** Planner. **Datum:** 2026-09-05.

---

## 1. Ziel

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar.

**Das Stub-Feld `Hervorgegangen:` trägt die Beobachtung, die den Vorgang überlebt hat — und zwar
unter der Kennung, die das Register heute führt.**

`internal/archive/stub.go` erkennt die Kennung mit `BEO-[0-9]{3}` und baut daraus einen Link auf
die abgelöste Register-**Datei** — den Pfad nennt die Datei selbst, und er steht hier bewusst
nicht als auflösbarer Verweis. Beides ist die abgelöste Gestalt: Die fortlaufende Nummer gibt es nicht
mehr, die Kennung ist der Pfad `BEO-<KUERZEL>/<slug>`
([`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
Festlegung 3), und die einzelne Register-Datei ist ein Verzeichnis geworden.

**Die Fehlerrichtung ist die schlechtere von zweien: still, nicht laut.** Eine Closure-Notiz, die
`BEO-ALL/<slug>` nennt, fällt durch den Ausdruck **durch** — der Stub verliert die Zeile, statt
einen toten Link zu zeigen. Gemessen, **keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2):

```sh
grep -cE 'BEO-\[0-9\]\{3\}|observations\.md' internal/archive/stub.go   # 2 Stellen
printf 'BEO-ALL/zusage-x\n' | grep -cE 'BEO-[0-9]{3}'                   # 0 Treffer — faellt durch
ls docs/plan/planning/observations.md 2>/dev/null | wc -l               # 0 — Linkziel existiert nicht
```

**Der Zahn hält die abgelöste Form fest, statt die Eigenschaft zu messen.** `stub_test.go` und
`anwenden_test.go` erwarten wörtlich `[`BEO-009`](../../observations.md)`; beide sind grün und
sagen damit nichts mehr über die Zusage im Doc-Kommentar von `Hervorgegangen` aus
([`AGENTS.md`](../../../../AGENTS.md) §3.6 — ein Test, dessen Name eine Eigenschaft behauptet,
muss die Eigenschaft messen).

**Warum dieser Träger von drei Bezugsmengen unberührt blieb, und die Grenze ist gemessen.**
[slice-177](../done/slice-177-beobachtungs-register-verzeichnis-form.md) nahm die sechs
Anweisungssatz-Dateien, [slice-184](../done/slice-184-register-form-im-bestand-nachziehen.md) die
Form-Sprache in denselben, und
[slice-186](../done/slice-186-beobachtungs-kennungen-loesen-wieder-auf.md) misst über `'*.md'`. Go-Dateien
liegen in keiner der drei:

```sh
git grep -l 'BEO-[0-9]\|observations\.md' -- '*.go' | wc -l   # 3 Dateien, keine davon .md
```

**Was dieser Slice nicht entscheidet.** Ob die **Kommentar**-Zeilen außerhalb von `*.md`, die
dieselbe abgelöste Kennung oder Adresse nennen, nachgezogen werden — sie brechen nichts, und
[`AGENTS.md`](../../../../AGENTS.md) §3.7 bindet den Bestand ausdrücklich nicht. Sie sind hier
Abgrenzung, kein Liefergegenstand.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die vier Closure-Pflichten darunter zählen nicht mit.

- [ ] **`Hervorgegangen:` erkennt die heutige Kennung und baut einen Link, der auflöst.** Eine
      Closure-Notiz, die `BEO-<KUERZEL>/<slug>` nennt, erscheint im Stub; das Linkziel existiert
      im Arbeitsbaum. Ob die abgelöste dreistellige Form daneben erkannt bleibt, ist eine
      Entscheidung dieses Slice und wird im Doc-Kommentar der Funktion begründet — nicht
      stillschweigend getroffen.
- [ ] **Der Zahn misst die Eigenschaft, nicht die abgelöste Form.** Die Erwartung in
      `stub_test.go` und `anwenden_test.go` steht auf der heutigen Kennung, und das Gegenbeispiel
      ist **rot gesehen**: der Ausdruck auf die alte Form zurückgesetzt → Test fällt
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] `make gates` grün.
- [ ] Doku-Update: kein öffentlicher Vertrag berührt — das Unterkommando behält Aufruf und
      Ausgabeformat; ändert sich der Stub-Text für einen Adopter sichtbar, bekommt die
      Änderungshistorie von [`docs/user/benutzerhandbuch.md`](../../../user/benutzerhandbuch.md)
      ihre Zeile.
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
| `internal/archive/stub.go` | update | Kennungs-Erkennung und Link-Bau in `Hervorgegangen` |
| `internal/archive/stub_test.go` | update | der Zahn steht auf der heutigen Kennung |
| `internal/archive/anwenden_test.go` | update | dieselbe Erwartung auf der Aufrufer-Ebene |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): frei — der Gegenstand hängt an keinem anderen Slice. Die
Kennungs-Gestalt ist mit
[`ADR-0034`](../../adr/0034-register-verzeichnis-form-und-die-ortsfestigkeit-der-register-datei.md)
`Accepted` entschieden, und das Register führt sie bereits.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Erkennung nicht mit einem
  Ausdruck auskommt, weil `Hervorgegangen` die Kennung aus einem Markdown-Link statt aus dem
  blanken Text ziehen muss — dann trennt der Schnitt Erkennung und Link-Bau.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Entscheidung, ob die abgelöste
  dreistellige Form erkannt bleibt, eine Aussage über die **Archivierung des Altbestands**
  verlangt. Die ist heute von keiner Quelle dieses Repos getragen (Baseline-Regelwerk
  `modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4) und gehört nicht in einen
  Code-Slice.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; das Gegenbeispiel zu DoD 2 ist rot gesehen und im Closure-Eintrag benannt;
`make gates` grün; Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Der Ausdruck wird getauscht und die Zusage darüber bleibt stehen**
  ([`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)).
  Der Doc-Kommentar von `Hervorgegangen` sagt heute zu, jede Kennung werde als Anker-Link **neu
  gebaut**; nach dem Tausch gilt das nur für die Kennungen, die der neue Ausdruck trifft. —
  **Ausgang:** <…>
- **Die Bezugsmenge ist wieder ein `grep`**
  ([`BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)).
  Das Kommando in §1 findet `BEO-`; ein Ort, der die Kennung aus einer Variablen zusammensetzt
  oder unter anderem Namen führt, steht nicht darin. Der Slice sagt die getroffene Menge zu, nicht
  die vollständige. — **Ausgang:** <…>
- **Kein Gate sieht die Klasse.** Dass ein Stub eine Zeile **verliert**, ist kein rotes Modul,
  sondern eine fehlende Zeile in einer Datei, die erst bei der nächsten Archivierung entsteht. Der
  Träger ist der Test aus DoD 2 und sonst nichts
  ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): kein
  Gate behaupten, das nicht prüft). — **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Pfade getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register (`../observations/`):** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses Repo führt Wellen-Betrieb; sie prüft die nächste Welle-Closure —
  auch für einen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien** (Konventionen-Dichte ·
Phase-Reife · Evidenz-/Diskrepanz-Risiko · Reconciliation-Aufwand), vier und
nicht mehr.

**Umfang.** Der **Modus-Begründungsblock** unten ist Pflicht, sobald
mindestens eine berührte Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei
reinem GF genügt der Hinweis *"alle berührten Sub-Areas GF"*; bei reinem
Refactor ohne neue Sub-Area-Berührung entfällt er ganz. Die beiden
*Vorgelagert*-Blöcke entfallen nie.

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) — die einzige Sub-Area,
die die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) für
den Go-Baum führt.

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist
durchgegangen. **Jede** Zeile trägt `*` (gesamtes Repo) — die Spalte unterscheidet in diesem Repo
nichts. Drei Einträge berühren diesen Slice, keiner erreicht mit ihm 3× neu (Zähler = Zahl der
Dateien unter `evidence/`, gemessen mit
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, **keine
Erwartungswerte**):

- [`zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  (12×, **geplant**) — steht als Risiko 1 in §6; der Doc-Kommentar von `Hervorgegangen` ist genau
  diese Bauart.
- [`zusage-nennt-sensor-der-form-nicht-sieht`](../observations/BEO-ALL/zusage-nennt-sensor-der-form-nicht-sieht/observation.md)
  (7×, **geplant**) — steht als Risiko 2 in §6; dieser Slice **ist** der Ausgang ihres
  Go-Träger-Falls, nicht ihr achtes Auftreten.
- [`mutations-fall-zeigt-auf-falsche-datei`](../observations/BEO-ALL/mutations-fall-zeigt-auf-falsche-datei/observation.md)
  (2×) — bindet DoD 2: das Gegenbeispiel muss die Stelle treffen, die der Aufrufer benutzt, sonst
  misst der Test sich selbst.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Ziel-Form: Sub-Area-Modus-Begründung, Umfang).
`*` steht in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
