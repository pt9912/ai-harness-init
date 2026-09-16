# Slice slice-kennungs-erkennung-traegt-die-zugelassenen-formen: Jede Kennungs-Erkennung dieses Repos trägt die drei zugelassenen Formen

**Kennung:** benannt nach
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 — ein freier Slug in lowercase-Kebab-Case; die Kennung ist die, die
[`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 2 dem Befund gibt.

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt —
kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle entscheidet
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Er ist **kein** Mitglied
von [welle-emittierte-werkzeuge](../done/welle-emittierte-werkzeuge.md): deren vier Mitglieder lagen
bei ihrer Eröffnung fest; dieser Vorgang entstand aus dem Norm-Text, der ihre Sätze schließt. Die
Verweise auf die Welle in diesem Plan sind **Herkunft**, keine Mitgliedschaft.

**Ebene: Dogfood, nicht emittiert.** [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1
bindet die Werkzeuge **dieses** Repos; Setzung 4 nimmt die emittierte Ebene ausdrücklich aus — was ein
Zielrepo an Kennungs-Erkennung bekommt, entscheidet der Slice, der die Tool-Ebene entscheidet.

**Bezug:**
[`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1 bis 3 und 5 (**die Setzungen, deren
Vorgang dieser Slice ist** — Setzung 2 benennt ihn als Ort der Fundliste, Setzung 5 seine Frist),
[`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
Setzung 1 und 2 (die drei Formen und die Nummernform des Bestands),
[`AGENTS.md`](../../../../AGENTS.md) §3.6 (eine Zusage ist fertig, wenn benannt ist, was sie bricht —
hier: der rot gesehene Fall je Form),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (eine
Erkennung, die eine Form auslässt, behauptet eine Kennungs-Menge, die sie nicht führt),
[ADR-0053](../../adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md) (**Accepted** —
Festlegung 1 wählt den git-eigenen Träger, dessen Prüfung dieselbe Erkennung führt; die zwei
Gegenstände liegen aufeinander),
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl dieses Plans steht neben dem Kommando, das sie liefert).

**Berührte Spec-Stellen:** `—` (der Slice berührt keine Spec-Stelle; Gegenstand ist die Kennungs-
Erkennung der Werkzeuge dieses Repos).

**Verantwortlich:** Implementer. Der Liefergegenstand ist ein **Werkzeug-Zustand** — die Erkenntnis
liest eine Menge und zieht die Erkennungen nach; die Norm, gegen die sie urteilt, ist nicht seine und
steht in [`MR-059`](../../../../harness/conventions.md#mr-059).

**Autor:** Planner. **Datum:** 2026-09-15.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Jede Stelle der Dogfood-Werkzeuge, die eine Slice- oder Welle-Kennung erkennt, trägt jede der
drei zugelassenen Formen — die Fundliste steht im Vorgang, gemessen, mit einem rot gesehenen Fall je
Form.**

### Der Befund, und warum er eine Frist hat

[`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1 sagt die Eigenschaft zu, Setzung 2
sagt, **wo** ihr Befund steht (hier), Setzung 5 nennt die Frist: *der Nachzug ist fällig, bevor die
erste Kennung in einer Form aus Setzung 1 vergeben wird — bis dahin trägt dieser Vorgang den Befund,
und die Vergabe wartet auf ihn.*

**Wie weit die Erkennung heute reicht, ist mit einem Muster nicht messbar** — Setzung 3 sagt warum:
eine Alternative oder eine Zeichenklasse kann die Nummernform führen, ohne die Zeichenfolge
`slice-[0-9]` zu enthalten, und umgekehrt. Was ein `grep` liefert, ist darum eine **Orientierung**,
keine Fundliste:

```sh
grep -rnE 'slice-\\?\[0-9|slice-\\?d' harness/tools/*.sh .d-check.yml 2>/dev/null
```

Die Menge zu **lesen**, ist Liefer-Punkt (1) — nicht dieser Plan.

**Zwei Formen sind in Gebrauch, und eine ist es nicht.** Die **Nummernform** (`slice-174-…`) und der
**freie Slug** (`slice-lifecycle-move-geht-ins-ziel`) sind vergeben; die Form mit dem **Präfix eines
vorhandenen Ankers** (`slice-<Anker>-<Aspekt-slug>`) trägt heute nur Beispiel-Text. Der Befund betrifft
damit zuerst die zwei **gebrauchten** Formen — und er trifft einen Wächter, der im Commit-Pfad läuft:

```sh
git log --format='%s' | grep -c '^slice-mv:'
git log --format='%s' | grep '^slice-mv:' | grep -vcE 'ADR-[0-9]{4}|LH-[A-Z]{2}-[0-9]{2}|MR-[0-9]{3}|slice-[0-9]+'
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit jedem Lifecycle-Wechsel; tragend ist die Differenz: die zweite Zeile
zählt die Werkzeug-Commits, deren Betreff eine Kennung in einer **nicht** erkannten Form führt.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Die emittierte Ebene.** [`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 4 nimmt sie
  aus: die Erkennungen unter `internal/emit/templates/` gehören dem Vertrag gegenüber Zielrepos.
  *Schicht-Abgrenzung.*
- **Die vier Werkzeug-Commit-Messages.** Welche Form jede der vier Betreffzeilen trägt, ist der
  Gegenstand von [slice-werkzeug-commits-tragen-eine-kennung](../next/slice-werkzeug-commits-tragen-eine-kennung.md):
  er schreibt die **Nachricht**, dieser Slice die **Erkennung**, die sie liest. *Es wäre ein anderer
  Vorgang — die zwei Mengen sind disjunkt.*
- **Die Vergabe-Regel selbst.** Kein Wort von
  [`MR-057`](../../../../harness/conventions.md#mr-057--die-kennungs-form-für-neue-slices-und-wellen-ist-der-name-nicht-die-nummer)
  oder [`MR-059`](../../../../harness/conventions.md#mr-059) wird geändert; dieser Slice vollzieht
  eine Deklaration, er setzt keine. *Es wäre ein anderer Vorgang.*
- **Ein Kommando als Wächter.** Setzung 3 sagt, dass keines diese Eigenschaft messen kann; der
  rot gesehene Fall (DoD 2) ist darum ein Fall im Vorgang und keine neue Gate-Zeile.
  *Kein Sensor, wo keiner tragen kann.*

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

- [ ] **(1) Die Fundliste steht im Vorgang, gelesen statt gegreppt.** Jede Stelle der
      Dogfood-Werkzeuge, die eine Slice- oder Welle-Kennung erkennt, ist **namentlich** geführt, je
      Stelle mit den Formen, die sie trägt (Nummernform · freier Slug · Anker-Präfix-Form), und der
      Weg, auf dem die Menge gefunden wurde, ist als **Lesen** beschrieben
      ([`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 3).
- [ ] **(2) Jede genannte Stelle trägt jede Form, und je ausgelassener Form ist der Fall rot
      gesehen.** Der Beleg ist kein Gate, sondern die gefahrene Erkennung: eine Kennung der
      ausgelassenen Form geht durch den **unveränderten** Bestand (die Nummernform weiterhin), und
      die Form, die vorher fiel, fällt jetzt nicht mehr — mit gelesener Ausgabe. Für die
      Anker-Präfix-Form ist der Fall herstellbar, obwohl die Form noch nicht vergeben ist
      ([`AGENTS.md`](../../../../AGENTS.md) §3.6).
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: **das ist Liefer-Punkt (1)** — der Träger der Fundliste ist dieser Vorgang.
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
| [`harness/tools/`](../../../../harness/tools) | update | die Erkennungen der Dogfood-Werkzeuge — Fundliste aus Liefer-Punkt (1), Nachzug je Stelle |
| [`.d-check.yml`](../../../../.d-check.yml) | update | `commits.id-patterns` ist eine Erkennung dieses Repos und liegt im Prüfpfad des Gate-Laufs; sie wird gezogen, wenn Liefer-Punkt (1) sie führt |
| [`AGENTS.md`](../../../../AGENTS.md) §5, [`harness/README.md`](../../../../harness/README.md) §Traceability | update *(nur falls)* | nennt die Kennungs-Menge in Prosa; nur wenn die Lesung eine dort genannte Form nicht mehr trifft |
| `test/…` | neu | der rot gesehene Fall je Form (DoD 2) — als Fall im Vorgang, nicht als Gate-Zeile |

**Warum `.d-check.yml` hier steht, obwohl Setzung 3 ein Kommando ausschließt.** Die id-patterns sind
keine Messung, sondern eine **Erkennung**: sie entscheiden, welche Kennung ein Commit-Betreff trägt.
Sie zu ziehen ist kein Sensor-Bau, sondern derselbe Vollzug wie in den Werkzeugen.

**Eine Achtung beim Ziehen.** Ein Muster, das eine Form **hinzunimmt**, ist keine Senkung nach
[`AGENTS.md`](../../../../AGENTS.md) §3.5 — es führt aus, was Setzung 1 zusagt. Ein Muster, das eine
Form **fallen lässt** (etwa die Nummernform aus dem Bestand), wäre eine und ist nicht Gegenstand
dieses Slice.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): **`in-progress/` trägt keinen Slice** (WIP frei), der Slice ist
priorisiert (`Verantwortlich:` gesetzt), und **eine Kennung in einer Form aus
[`MR-059`](../../../../harness/conventions.md#mr-059) Setzung 1 soll vergeben werden** — Setzung 5
macht diesen Vorgang zur Vorbedingung der Vergabe. Beobachtbar ohne Rückfrage:

```sh
ls docs/plan/planning/in-progress/ | grep -c '^slice-'
grep -n '^\*\*Status:\*\*' docs/plan/adr/0053-traeger-der-commit-kennung-am-commit-und-am-agenten.md
```

**Reihenfolge:** unabhängig von jedem anderen offenen Slice; die Fläche — die Erkennungen dieses
Repos — fasst kein laufender Vorgang an.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Fundliste Stellen in **mehreren**
  Schichten zugleich führt (Werkzeug-Skripte, Gate-Config, Go-Code) und der Nachzug samt Rot-Beleg je
  Form nicht in einer Review-Sitzung prüfbar ist.
- `in-progress` → `open` (blockiert): wenn sich zeigt, dass eine genannte Stelle ihre Formen aus einer
  **anderen** Quelle bezieht (etwa aus dem gepinnten Werkzeug) und der Nachzug dort nicht ohne
  Entscheidung zu haben ist.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

**Zwei beobachtbare Kriterien:**

1. **Die Fundliste ist vollständig und als Lesung ausgewiesen** (DoD 1) — sie nennt die Stellen
   namentlich, und der Weg, auf dem sie gefunden wurden, ist beschrieben.
2. **Je Form liegt ein Rot-Beleg vor, der die behauptete Ursache trägt** (DoD 2) —
   [`AGENTS.md`](../../../../AGENTS.md) §3.6: nicht *irgendein* Rot, sondern das der ausgelassenen
   Form, und der unveränderte Bestand bleibt still.

**Lerneintrag:** die Form entscheidet die Closure. Wurde mit diesem Slice eine Regel verkörpert,
trägt der Eintrag `liegt in <Zielort>` und den Herkunfts-Anker `seit slice-<Kennung>`; folgt sie aus
[`MR-059`](../../../../harness/conventions.md#mr-059), trägt der Zielort bereits seine ID und braucht
keinen zweiten Anker.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **(1) Die Fundliste wird gegreppt und sieht vollständig aus.** Setzung 3 nennt genau diesen
  Fehlerweg: eine Trefferliste ist keine Fundliste. **Gegenmittel im Plan:** DoD (1) verlangt die
  Lesung ausdrücklich, §1 nennt das `grep` als Orientierung. — **Ausgang:** <…>
- **(2) Ein Muster wird gezogen und verliert dabei eine Form.** Ein Nachzug, der eine Alternative
  *ersetzt* statt sie zu erweitern, lässt die Nummernform des Bestands fallen und färbt die
  Werkzeug-Commits rot. **Gegenmittel im Plan:** §3 benennt die Richtung (hinzunehmen, nicht
  fallenlassen) und den unveränderten Bestand als grüne Gegenprobe (DoD 2). — **Ausgang:** <…>
- **(3) Die Frist aus Setzung 5 läuft weiter, während dieser Slice offen liegt.** Die Vergabe hängt
  an ihm; jede Kennung in einer Setzung-1-Form, die vorher vergeben wird, ist eine Vergabe gegen die
  Frist. **Gegenmittel im Plan:** §4 nennt die Bedingung als Start-Trigger. — **Ausgang:** <…>

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
`harness/tools/` (Kürzel `TOOLS`) für die Werkzeug-Skripte und `*` (Kürzel `ALL`) für
[`.d-check.yml`](../../../../.d-check.yml) und die zwei Prosa-Stellen. Beide erfüllen das
Inklusionskriterium.

**Vorgelagert — offene Beobachtungen sichten:** Das Register ist durchgegangen; gemessen
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2):

```sh
for s in lebendes-register-traegt-eine-ueberholte-fundliste benannte-luecke-ohne-ausgang abgeschaffte-kennung-in-unveraenderlichem-artefakt; do
  printf '%-52s %s\n' "$s" "$(ls docs/plan/planning/observations/BEO-ALL/$s/evidence/*.md | wc -l)"
done
```

**Keine Erwartungswerte** ([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2) — jeder Stand wandert mit der nächsten Closure. Alle drei stehen **unter** der Schwelle und
bleiben mit diesem Slice `offen`; keiner erreicht mit ihm erstmals 3×:

- **`lebendes-register-traegt-eine-ueberholte-fundliste`** — die Klasse, die diesen Slice umgibt:
  eine namentliche Fundmenge in einem lebenden Norm-Text veraltet, während die Menge wandert. Genau
  deshalb steht die Fundliste **im Vorgang** und nicht in
  [`MR-059`](../../../../harness/conventions.md#mr-059).
- **`benannte-luecke-ohne-ausgang`** — berührt als Form-Frage: dieser Slice trägt eine **benannte
  Lücke** als Gegenstand und muss sie an einem Zielort führen, nicht als Prosa.
- **`abgeschaffte-kennung-in-unveraenderlichem-artefakt`** — der Nachbar in der Sache: was geschieht,
  wenn eine Kennung ihre Form wechselt und ein eingefrorenes Artefakt die alte weiter nennt. Die
  Fundliste dieses Slice ist darum die der **jetzt** zugelassenen Formen.

**alle berührten Sub-Areas GF** — der Modus-Begründungsblock entfällt damit. `TOOLS` und `*` stehen
in der Modus-Deklaration als Greenfield: Doc führt, Code folgt, Graduation `n/a`.
