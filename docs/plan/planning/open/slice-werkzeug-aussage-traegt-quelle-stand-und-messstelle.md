# Slice slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle: Eine Aussage über ein Werkzeug trägt ihre Quelle, ihren Stand und ihre Messstelle, auch außerhalb des Adaptions-Blocks

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.
Übernimmt ein anderer Slice den Gegenstand oder entfällt er, geht diese Datei
aus `open/` oder `next/` nach `done/` — §7 nennt in der Zeile `Gegenstand:`
Kennung oder Grund, die Liefer-Punkte der DoD bleiben leer
(§Ein Slice, dessen Gegenstand ein anderer übernimmt).

**Welle:** ohne Welle. Nach dem Test aus Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit
eine Welle braucht beobachtet keine Closure-Bedingung mehr als diese DoD.

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(eine Werkzeug-Aussage, die am Stand nicht deckt, ist dieselbe Klasse eine Ebene tiefer,
[`AGENTS.md`](../../../../AGENTS.md) §3.1),
[`MR-053`](../../../../harness/conventions.md#mr-053) (ein Eintrag datiert seine Werkzeug-Aussage),
[`MR-055`](../../../../harness/conventions.md#mr-055) (eine Stellen-Messung trägt keine Folgerung
über eine Eigenschaft).

**Berührte Spec-Stellen:** —

**Verantwortlich:** —

**Autor:** Planner. **Datum:** 2026-09-17.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel:** Drei Regeln über Aussagen zum Verhalten eines Werkzeugs stehen an einem Norm-Artefakt,
und zwar für jedes lebende Artefakt, nicht nur für die Einträge des Adaptions-Blocks. Wo eine der
drei unbewacht bleibt, steht das dort benannt.

1. **Quelle:** Eine Aussage über das gepinnte Werkzeug ist am Quellstand des gepinnten Bildes
   gelesen und nicht aus seiner Dokumentation übernommen.
2. **Stand:** Eine Werkzeug-Messung nennt den Stand, an dem sie gilt. Ein Lauf, der sich auf sie
   stützt, hält diesen Stand gegen den, den er fährt.
3. **Messstelle:** Eine Messung an einer Stelle wird nicht als Eigenschaft des Ganzen
   ausgegeben, zu dem die Stelle gehört.

**Warum ein Slice für drei Regeln.** Alle drei betreffen dieselbe Artefaktklasse, die
Werkzeug-Aussage in einem lebenden Artefakt. Sie haben dieselbe Lücke:
[`MR-053`](../../../../harness/conventions.md#mr-053) setzt die Schreib-Hälfte von Regel 2 und
[`MR-055`](../../../../harness/conventions.md#mr-055) setzt Regel 3, beide aber nur für Einträge
des Adaptions-Blocks. Für Sensor-Dateien, Slice-Pläne und Kommentare setzt keine Quelle etwas,
und Regel 1 hat gar keinen Zielort. Und alle drei brauchen dasselbe Verdikt des Architect zu
Zielort und schreibender Rolle.

**Belege**, je 3× erreicht mit `slice-d-check-pin-bringt-die-stilllegungs-bedingung`:

- [`aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand`](../observations/BEO-ALL/aussage-ueber-das-gepinnte-werkzeug-ohne-blick-in-seinen-stand/observation.md) (Regel 1)
- [`werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md) (Regel 2)
- [`stellen-messung-als-eigenschaft-ausgegeben`](../observations/BEO-ALL/stellen-messung-als-eigenschaft-ausgegeben/observation.md) (Regel 3)

Den Zähler liefert `ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`; keine
Zahl ist ein Erwartungswert.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Kein Sensor.** *Anderer Vorgang:* Ob eine Aussage an ihrem Stand deckt oder nur an einer
  Stelle gemessen ist, ist ein Urteil. Kein Modul aus `modules:` der
  [`.d-check.yml`](../../../../.d-check.yml) liest eine Prosa-Aussage gegen ein Fremd-Bild. Ein
  Sensor für einen zählbaren Teil wäre ein eigener Slice, nachdem die Regel steht.
- **Der Bestand wird nicht nachgezogen.** *Bestand bleibt bewusst stehen:* Gebunden ist die
  Aussage, die geschrieben oder geändert wird. Dieselbe Begründung trägt den Cutoff in
  [`AGENTS.md`](../../../../AGENTS.md) §3.7.
- **[`MR-053`](../../../../harness/conventions.md#mr-053) und
  [`MR-055`](../../../../harness/conventions.md#mr-055) werden nicht umgeschrieben.** *Anderer
  Vorgang:* Der Adaptions-Block ist append-only. Ob die Erweiterung ein neuer Eintrag oder eine
  Hard Rule wird, entscheidet der Architect ([`AGENTS.md`](../../../../AGENTS.md) §3.8).
- **Die Zusammenfassung eines referenzierten Artefakts.** *Ein Folge-Slice übernimmt es:*
  `slice-zusammenfassung-bleibt-innerhalb-ihrer-quelle`. Dort ist die Quelle ein Artefakt des
  Repos, hier das Verhalten eines Werkzeugs.
- **Die emittierte Ebene.** *Schicht-Abgrenzung:* Was ein emittiertes Repo an Regeln bekommt,
  entscheidet der Slice, der die Tool-Ebene entscheidet.

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

Drei Liefer-Punkte, einer je Regel. Für jeden gilt dasselbe:

- Zielort und schreibende Rolle stammen aus dem Verdikt des Architect.
- Die Regel steht dort mit Geltungsbereich und benannter Bewachung oder benannter fehlender
  Bewachung.
- Die `state.md` des Registereintrags trägt `verkörpert`, mit Zielort und dem Herkunfts-Anker
  `seit slice-werkzeug-aussage-traegt-quelle-stand-und-messstelle`.
- **Rot:** Ein `grep -c` über dem Regelsatz am genannten Zielort liefert 0, oder die `state.md`
  nennt keinen Zielort.

- [ ] **1 — Regel 1 (Quelle) steht.**
- [ ] **2 — Regel 2 (Stand) steht, mit beiden Hälften.** Die Schreib-Hälfte gilt über den
      Adaptions-Block hinaus. Die Lese-Hälfte nennt den Lauf, der den Stand gegen den gefahrenen
      hält.
- [ ] **3 — Regel 3 (Messstelle) steht über den Adaptions-Block hinaus.**
- [ ] `make gates` grün.
- [ ] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow (`AGENTS.md` §6), kein Self-Review (Modul 8).
- [ ] Doku-Update: keines über die drei Liefer-Punkte hinaus; kein öffentlicher Vertrag ist berührt.
- [ ] Closure-Notiz mit Steering-Loop-Lerneintrag.
- [ ] Reconciliation-Register: entfällt — dieses Repo hat keinen Brownfield-Bootstrap und führt die Datei *reconciliation.md* nicht.
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
| der Zielort aus dem Verdikt: [`AGENTS.md`](../../../../AGENTS.md) §3 oder ein Eintrag unter [`harness/conventions/`](../../../../harness/conventions/) | update oder neu | die drei Regeln (DoD 1–3), geschrieben vom Architect |
| die drei `state.md` der Belege aus §1 | update | Ausgang `verkörpert` mit Zielort und Anker (DoD 1–3) |

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): Das WIP-Limit ist frei, und das Verdikt des Architect zu
Zielort und schreibender Rolle liegt als Artefakt vor (Baseline-Regelwerk
`modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 3b).

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): Das Verdikt setzt für eine der drei
  Regeln einen anderen Zielort oder eine andere schreibende Rolle als für die übrigen. Dann wird
  sie ein eigener Slice.
- `in-progress` → `open` (blockiert — Carveout?): Das Verdikt verlangt für eine der Regeln eine
  ADR, und die ist nicht angenommen.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

1. Jede der drei Regeln steht am Zielort, und das `grep` aus §2 findet sie.
2. Die drei `state.md` tragen `verkörpert` mit Zielort und Anker, und `make gates` ist grün.

Dazu kommt ein **Lerneintrag** in einer der drei Formen (§7).

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

1. **Eine Regel ohne Wächter wirkt nicht stärker als heute.** *Absehbar:* weiter offen. Die
   Grenze steht dann in der `state.md` jedes Eintrags. — **Ausgang:** <offen>
2. **Regel 2 wird so weit gefasst, dass sie jede Zahl im Text bindet und neben
   [`MR-025`](../../../../harness/conventions.md#mr-025) eine zweite Fassung derselben Pflicht
   entsteht.** *Absehbar:* entfallen, wenn der Geltungsbereich auf Aussagen über das Verhalten
   eines Werkzeugs begrenzt bleibt. — **Ausgang:** <offen>

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

- **Was hat funktioniert:** offen bis zur Closure.
- **Was ging anders als geplant:** offen bis zur Closure.
- **Steering-Loop-Eintrag:** offen bis zur Closure.
- **Beobachtungs-Register (`../observations/`):** offen bis zur Closure.
- **Folge-Slices:** offen bis zur Closure.
- **Risiken aus §6:** offen bis zur Closure, jedes mit genau einem Ausgang.
- **Drei Paarungen:** offen bis zur Closure.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `AGENTS.md` oder `harness/conventions/` und
das Beobachtungs-Register; alle liegen in `*`. `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`)
sind nicht berührt.

**Vorgelagert — offene Beobachtungen sichten:** Alle Einträge führen die Sub-Area `*`; gesichtet
ist nach Gegenstand. Den Zähler liefert
`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/ | wc -l`, den Stand die erste Zeile
der `state.md`; keine der Zahlen ist ein Erwartungswert.

| Eintrag | Zähler | Stand | Berührung durch diesen Slice |
|---|---|---|---|
| die drei Belege aus §1 | je 3 | geplant, Kennung dieser Slice | Gegenstand |
| [`kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle`](../observations/BEO-ALL/kommentar-nennt-den-vorgang-seiner-entstehung-statt-der-stelle/observation.md) | 13 | verkörpert | Nachbar: Regel 2 darf die Quellen-Klausel aus [`AGENTS.md`](../../../../AGENTS.md) §3.7 nicht aufweichen, denn der Stand einer Messung ist keine Chronik |
| [`zusammenfassung-staerker-als-ihre-quelle`](../observations/BEO-ALL/zusammenfassung-staerker-als-ihre-quelle/observation.md) | 8 | geplant | Nachbar mit eigenem Träger, siehe §1 |
| [`baseline-aussage-ohne-mess-tag`](../observations/BEO-ALL/baseline-aussage-ohne-mess-tag/observation.md) | 4 | verkörpert | Nachbar: dieselbe Stand-Regel für die Baseline statt für ein Werkzeug |

**Modus-Begründungsblock — Umfang.** Pflicht, sobald mindestens eine berührte
Sub-Area BF oder Hybrid ist — einer pro Sub-Area. Bei reinem GF genügt der
Hinweis *"alle berührten Sub-Areas GF"*; bei reinem Refactor ohne neue
Sub-Area-Berührung entfällt **er** — nicht der Abschnitt.

**Alle berührten Sub-Areas GF** ([`harness/conventions.md`](../../../../harness/conventions.md)
§Modus-Deklaration pro Sub-Area).
