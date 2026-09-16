# Slice slice-werkzeug-commits-tragen-eine-kennung: Die vier Commit-Messages der eigenen Werkzeuge tragen eine Kennung

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case; die Kennung ist die, die
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4 dem
Kandidaten gibt.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt —
kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle entscheidet
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Er ist **kein** Mitglied
von [welle-emittierte-werkzeuge](../done/welle-emittierte-werkzeuge.md); der Verweis dort ist
**Herkunft** — der Kanal, den dieser Vorgang bedient, wurde in der Welle entschieden.

**Bezug:**
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) (**Accepted** —
Festlegung 1 wählt den git-eigenen `commit-msg`-Träger, Festlegung 4 übergibt genau diesen Vorgang
an den Planner und gibt ihm damit seine Adresse; mit ihrem Accept-Übergang bindet sie nach
[ADR-0040](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md), und der
Start-Trigger unten ist damit eingetreten),
[`AGENTS.md`](../../../../AGENTS.md) §5 und [`harness/README.md`](../../../../harness/README.md#traceability)
§Traceability (die Zusage, die dieser Slice in ihren Gegenstand zieht),
[`AGENTS.md`](../../../../AGENTS.md) §3.3 (Move und Inhalt sind zwei Commits — die Werkzeuge führen
genau diesen Schnitt, und ihre Message ist der Ort, an dem er sichtbar wird),
[`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1 bis 4 (welche Formen eine Erkennung
tragen muss — die Bedingung, unter der eine Kennung in der Message überhaupt **gesehen** wird),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Träger, auf dem die Werkzeuge des eigenen Prozesses fallen, trägt seine Klasse nicht),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben dem Kommando, das sie liefert).

**Berührte Spec-Stellen:** `—` (der Slice berührt keine Spec-Stelle; Gegenstand sind vier
Betreffzeilen, die dieses Repo selbst baut).

**Verantwortlich:** Implementer (pt9912). Der Liefergegenstand ist ein **Werkzeug-Zustand** — vier Stellen
bilden ihre Message und tragen künftig eine Kennung; die Norm, gegen die das geschieht, steht in
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) und
[`AGENTS.md`](../../../../AGENTS.md) §5.

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Die vier Stellen, die als einzige in diesem Repo einen Commit aus einem Werkzeug heraus
bilden, tragen in ihrer Betreffzeile eine Kennung — und der Träger aus
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 1
bricht nicht mehr an den Commits, die dieses Repo bei jedem Lifecycle-Wechsel selbst fährt.**

### Der Befund

Vier Stellen bilden ihre Message mit `-m` **innerhalb** des Werkzeugs und ohne Kennung —
namentlich geführt in
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4. Ein
Träger, auf dem die Werkzeuge des eigenen Prozesses fallen, trägt seine Klasse nicht: er bricht
`make slice-mv` **nach** dem `git mv` und hinterlässt einen gestagten Rename ohne Commit, in einem
Aufruf, den jede Rolle bei jedem Lifecycle-Wechsel fährt. Die Größe ist gemessen:

```sh
git log --format='%s' | grep -c '^slice-mv:'
git log --format='%s' | grep '^slice-mv:' | grep -vcE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit jedem Lifecycle-Wechsel; tragend ist die Differenz. Die zweite Zeile
zählt die Werkzeug-Commits, die heute **keine** Kennung führen, die ein Muster aus
`.d-check.yml` (`commits.id-patterns`) sieht. Dass dieselbe Menge auch davon abhängt, welche
**Formen** eine Erkennung trägt, ist der Nachbar-Gegenstand — siehe unten.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die Kennungs-Erkennung.** Welche Formen die Werkzeuge dieses Repos erkennen, ist der Gegenstand
  von [slice-kennungs-erkennung-traegt-die-zugelassenen-formen](../open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md);
  dieser Slice schreibt die **Nachricht**, jener die **Erkennung**, die sie liest. *Es wäre ein
  anderer Vorgang.* Der Start-Trigger unten nennt die Reihenfolge.
- **Eine Ausnahme für die Werkzeug-Formen.** Eine Zeile, die `slice-mv:`-Messages von der Prüfung
  nimmt, wäre eine **Senkung** der Durchsetzung nach
  [`AGENTS.md`](../../../../AGENTS.md) §3.5 und höhlte die Klasse aus, für die der Träger gewählt ist
  ([ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4).
  *Bestand bleibt bewusst stehen — hier ist der Bestand die Klasse selbst.*
- **Der Kanal selbst.** Daß der git-eigene Hook der Träger ist und der PreToolUse-Kanal daneben
  bleibt, ist in [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md)
  Festlegung 1 und 2 entschieden; dieser Slice setzt den Träger voraus. *Es wäre ein anderer Vorgang.*
- **Die emittierte Ebene.** Was ein Zielrepo an Commit-Trägern bekommt, ist der Gegenstand von
  [ADR-0054](../../adr/0054-emittierter-commit-traeger-skip-if-present.md) und des Vorgangs, den sie
  führt. *Schicht-Abgrenzung.*

**Keine Mindestzahl.** Ein Slice mit *einem* echten Ausschluss ist besser als
einer mit vier erfundenen; die vier Klassen sind ein Suchraster, keine
Ausfüll-Liste.

Wer später etwas mitnimmt, das hier ausgeschlossen war, hat den Plan
**geändert**, nicht nur ergänzt.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die Closure-Pflichten darunter zählen nicht mit.

**Zwei Liefer-Punkte:**

- [ ] **(1) Die vier Messages tragen eine Kennung, und jede trägt die richtige.** Je Stelle steht
      die Kennung des Vorgangs, den der Commit abschließt — beim Lifecycle-Move die des bewegten
      Slice, beim Verweis-Nachzug dieselbe, bei den zwei Archiv-Commits die der Welle. Die **Form**
      ist eine, die die Erkennung dieses Repos trägt
      ([`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1); eine Form, die kein Muster
      sieht, erfüllte den Punkt nicht.
- [ ] **(2) Der Rot-Fall ist gesehen, und der Grund trägt.** Vor dem Fix — und **nach**
      `make hooks-install` — endet ein `make slice-mv` am Träger und hinterlässt einen gestagten
      Rename ohne Commit; die **gelesene** Meldung nennt den Grund. Nach dem Fix läuft derselbe
      Aufruf durch, und der Commit trägt die Kennung im Betreff
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6: das Rot muß die behauptete Ursache tragen, nicht
      irgendeine). Der Beleg steht mit seinem Kommando im Umsetzungs-Commit.
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: die Prosa, die den Träger und seine zwei Grenzen führt
      ([`harness/README.md`](../../../../harness/README.md#traceability) §Traceability), nennt die
      Werkzeug-Klasse nicht mehr als **offen**, sobald sie es nicht mehr ist.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Beobachtungs-Register (`../observations/`) fortgeschrieben — **kein Zähler wird gesetzt**, er
      folgt aus den Dateien. Keine Beobachtung angefallen ist ebenfalls eine Antwort und wird in §7
      notiert.
- [ ] Jedes Risiko aus §6 trägt einen Ausgang (eingetreten / entfallen / weiter offen).
- [ ] Die drei Paarungen (Anker · Folge-Slice · Register) sind getragen — im Repo **ohne**
      Wellen-Betrieb hier geprüft, im Repo **mit** Wellen von der nächsten Welle-Closure (auch für
      Slices ohne Wellen-Zugehörigkeit).

## 3. Plan (vor Code)

Regeln dieser Sektion: Baseline-Regelwerk `grundlagen-bootstrap.md`
§Was ist eine Sub-Area? — diese Liste liefert die **Pfad-Kandidaten** für §8,
nicht die Antwort: Pfad-Berührung ist nicht hinreichend, und eine
Aussagen-Berührung steht hier gar nicht.

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| [`harness/tools/slice-mv.sh`](../../../../harness/tools/slice-mv.sh) | update | zwei Stellen bilden ihre Message selbst: der reine Move und der Verweis-Nachzug (Liefer-Punkt 1) |
| `internal/archive/anwenden.go` | update | zwei Stellen bilden ihre Message selbst: der reine Move und der Inhalts-Commit (Liefer-Punkt 1) |
| [`harness/README.md`](../../../../harness/README.md#traceability) §Traceability | update | die Reichweiten-Tabelle führt die Werkzeug-Klasse als offen — sie wird gezogen (DoD *Doku-Update*) |
| `test/…` + `test/mutations/*` | neu | der Rot-Fall aus Liefer-Punkt (2) samt gelistetem Zahn, der ihn rot färbt ([`AGENTS.md`](../../../../AGENTS.md) §3.6) |

**Der Gegenstand ist entschieden, nicht gesucht.** Kanal, Träger und die Zugehörigkeit der
Werkzeug-Klasse stehen in
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 1 und 4
— je Zahl mit dem Kommando, das sie liefert. Dieser Plan wiederholt sie **nicht** (§3.7: die Abwägung
steht in der ADR) und fügt **keine** zweite Fassung derselben Messung hinzu.

**Die Reihenfolge zum Nachbarn ist sachlich, nicht ordnend.** Eine Kennung in einer Form, die kein
Muster sieht, macht den Commit weiterhin rot — der Fix wäre dann nicht sichtbar. Darum steht der
Nachbar im Start-Trigger (§4).

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **
[slice-kennungs-erkennung-traegt-die-zugelassenen-formen](../open/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md)
liegt in `done/`** — die Erkennung trägt die Form, in der die Kennung geschrieben wird —, **
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) ist `Accepted`**
(sonst wird eine Setzung vollzogen, die niemand ausgesprochen hat,
[ADR-0040](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)), der Slice ist
priorisiert und das WIP-Limit frei. Beobachtbar ohne Rückfrage:

```sh
ls docs/plan/planning/done/slice-kennungs-erkennung-traegt-die-zugelassenen-formen.md
grep -n '^\*\*Status:\*\*' docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md
```

**Reihenfolge:** hinter dem Nachbarn; im Übrigen unabhängig. Die zwei Flächen — die vier Messages
hier, die Erkennungen dort — sind disjunkt.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich zeigt, daß die zwei Go-Stellen
  und die zwei Shell-Stellen **eine gemeinsame Quelle** für die Message brauchen (etwa einen
  gemeinsamen Bau der Betreffzeile) — dann ist das ein eigener Schnitt und dieser zu klein.
- `in-progress` → `open` (blockiert): wenn die Kennung des bewegten Vorgangs in der Message nicht
  verfügbar ist, ohne den Aufruf-Vertrag von `make slice-mv` oder `make archive-welle` zu ändern —
  dann gehört erst diese Entscheidung, und sie gehört dem Architect.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Der Rot-Fall ist am Träger gesehen und der Grün-Fall am selben Aufruf** (DoD 2) — beide mit
   **gelesener** Ausgabe und mit ihrem Kommando im Umsetzungs-Commit.
2. **Kein Werkzeug-Commit dieses Repos fällt mehr am Träger** — die zwei Kommandos aus §1 liefern
   danach eine Differenz von **null**; die Zahl steht mit ihrem Kommando im Commit
   ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
   Setzung 1), und `make gates` meldet Exit 0.

**Lerneintrag:** die Form entscheidet die Closure. Wurde mit diesem Slice eine Regel verkörpert,
trägt der Eintrag `liegt in <Zielort>` und den Herkunfts-Anker `seit slice-<Kennung>`; folgt sie aus
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md), trägt der Zielort
bereits seine ID und braucht keinen zweiten Anker.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Der Fix wird grün gemessen, ohne den Träger zu aktivieren.** Ohne `make hooks-install` ist
  `core.hooksPath` nicht gesetzt, und derselbe Aufruf läuft **vor** dem Fix durch — der Rot-Beleg
  wäre dann nicht herstellbar. **Gegenmittel im Plan:** Liefer-Punkt (2) nennt die Aktivierung als
  Teil des Belegs. — **Ausgang:** <…>
- **(2) Die Kennung wird in einer Form geschrieben, die die Erkennung nicht trägt.** Dann bleibt der
  Commit rot, obwohl er eine Kennung führt — die Klasse, die
  [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1 zusagt. **Gegenmittel im Plan:**
  §4 bindet den Start an den Nachbarn. — **Ausgang:** <…>
- **(3) Die Message wird zur zweiten Fassung einer Kennungs-Regel.** Wer die Form der Betreffzeile
  an einer Stelle festlegt, an der sie nicht hingehört, erzeugt eine zweite Quelle für
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer).
  **Gegenmittel im Plan:** die Form wird **gelesen**, nicht entschieden;
  [ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) Festlegung 4
  nimmt die Form-Wahl ausdrücklich als eigenen Gegenstand. — **Ausgang:** <…>

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

- **Was hat funktioniert:** <…>
- **Was ging anders als geplant:** <…>
- **Steering-Loop-Eintrag:** <…>
- **Beobachtungs-Register:** <…>
- **Folge-Slices:** <…>
- **Risiken aus §6:** <jedes mit genau einem Ausgang — siehe §6>
- **Drei Paarungen:** dieses **Repo** fährt Wellen — Anker, Folge-Slice und Register prüft die
  nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

## 8. Sub-Area-Prüfungen und Modus-Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Sub-Area-Modus-Begründung — dort die **zwei vorgelagerten
Schritte** (sie stehen in jedem Slice-Plan, unabhängig von Modus und
Slice-Typ) und die **vier Pflichtkriterien**, vier und nicht mehr.

**Der Abschnitt selbst entfällt nie.** Die zwei vorgelagerten Prüfungen laufen
in **jedem** Slice-Plan. Bedingt ist allein der Modus-Begründungsblock am Ende; deshalb nennt der
Titel beide Hälften.

**Vorgelagert — Sub-Area-Wahl prüfen:** berührt sind **zwei** Sub-Areas, beide in der
Modus-Deklaration von
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area):
`harness/tools/` (Kürzel `TOOLS`) für das Shell-Werkzeug und `*` (Kürzel `ALL`) für die zwei
Go-Stellen und die Prosa. Beide erfüllen das Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; der Eintrag, der
diesen Gegenstand führt, steht **über** der Schwelle und trägt inzwischen einen Ausgang
(`verkörpert`) — er ist der Auslöser dieser Entscheidung, nicht ihr Gegenstand:

```sh
for s in commit-message-ohne-traceability-kennung waechter-abdeckung-haengt-an-uninstruierter-konvention; do
  printf '%-52s %s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)" "$(grep -m1 '^\*\*Stand:\*\*' docs/plan/planning/observations/BEO-ALL/$s/state.md)"
done
```

**Keine Erwartungswerte** — beide Stände wandern mit der nächsten Closure. **Keiner** erreicht mit
diesem Slice erstmals 3×; der erste trägt seinen Ausgang bereits, der zweite steht unter der
Schwelle.

- **`commit-message-ohne-traceability-kennung`** — der Auslöser. Seine Grenze nennt diese
  Werkzeug-Klasse als **offene Hälfte**; dieser Slice ist ihr Träger.
- **`waechter-abdeckung-haengt-an-uninstruierter-konvention`** — berührt als Nachbar: die Reichweite
  eines Wächters hängt an einem Schritt, den der Anweisungssatz nicht durchgängig nennt. Genau die
  Aktivierung (`make hooks-install`) ist der Schritt, an dem Liefer-Punkt (2) hängt.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit. `TOOLS` und `*` stehen
in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
