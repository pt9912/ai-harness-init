# Slice slice-216: Die eingehenden Verweise auf Review-Reports bekommen ihren Ausgang

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Sein Closure-Trigger fordert nichts, was die DoD unten nicht schon belegt —
kein repo-weiter Beleg, kein Replay; damit fehlt das *Mehr*, an dem sich eine Welle entscheidet
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht). Er ist **Vorbedingung**
der ersten Archivierung, nicht Mitglied einer Welle, die sie vollzieht.

**Bezug:**
[`ADR-0033`](../../adr/0033-wellen-archivierung-als-unterkommando.md) (die Operation, deren Sperre
`[haenger]` diese Frage stellt — Festlegung 1 und 3 bleiben unberührt),
[`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) (die Präzedenz für eine
der vier Alternativen: ein Referenz-Ventil ist eine Senkung mit eigener Entscheidung),
[`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (ein
Ventil, das mehr stumm schaltet als den benannten Fall, erzeugt ein stilles Grün).

**Berührte Spec-Stellen:** `—`. Der Slice entscheidet eine Prozess-Frage; er schreibt keine
Spec-Stelle.

**Verantwortlich:** Implementer (pt9912)

**Autor:** Planner. **Datum:** 2026-09-12.

---

## 1. Ziel und Abgrenzung

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — Schnitt nach Lieferwert, nicht nach Schichten; jeder Slice
ist einzeln lieferbar. **§1 nennt Ziel und Abgrenzung** (Out-of-Scope-Disziplin
des Lastenhefts, auf den Slice-Plan angewandt); die vier Klassen des
Ausschlusses stehen in **eben diesem Abschnitt** des Baseline-Regelwerks,
zusammen mit der Begründungs-Pflicht je Punkt.

**Ziel: Was dieses Repo mit den eingehenden Verweisen auf Review-Reports tut, die die Ziel-Form
nicht vorsieht, steht als angenommene Entscheidung auf Rang 4 der Source Precedence — vor der
ersten Archivierung.**

**Die Regel ist nicht offen, der Bestand weicht von ihr ab.** Der gepinnte Baum entscheidet die
Frage für Slice-Dateien und Welle-Pläne bereits: Ihr Stub bleibt liegen und *„lässt eingehende
Verweise gültig"* (`modul-06-roadmap.md` §Wellen-Closure-Prozedur, Schritt 4), und der
Retirement-Check *„liest die Herkunft dann über den Stub und dessen Archiv-Zeiger statt direkt"*
(`grundlagen-traceability.md`). Für Reports gilt die Gegenrichtung, ebenso ausdrücklich:
*„**Review-Reports bekommen keinen Stub**; sie haben keine Identität jenseits ihres Slice."* Die
Ziel-Form setzt damit voraus, dass niemand einzeln auf einen Report zeigt. In diesem Repo zeigen
**144** von **345**:

```sh
for r in docs/reviews/*.md; do rb="${r##*/}"; \
  git grep -lF -e "]($rb)" -- ':!.harness/baseline' | grep -vxF "$r" | sed "s|.*|$rb|"; \
done | sort -u | wc -l     # 144 Report-Dateien sind Ziel eines Links
ls docs/reviews/*.md | wc -l   # 345
```

**Keine Erwartungswerte**
([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — beide wandern mit dem Bestand.

**Die erste Archivierung bricht daran ab, und das ist gemessen, nicht erwartet.** Die Vorschau des
Werkzeugs (`make host-bin`, dann
`.harness/state/bin/ai-harness-init archive-welle --vorschau welle-13`) meldet vier Sperren; eine
davon ist `[haenger]` mit **44** Fundstellen — Quellen, die den Lauf überleben, während ihr Ziel
im Archiv verschwindet:

```sh
# aus der Vorschau-Ausgabe, Abschnitt [haenger]
#  22 docs/reviews (Reports, die diese Welle nicht einsammelt)
#  11 docs/plan/planning/open (offene Slice-Pläne)
#   3 docs/plan/adr (zwei Dateien, beide Accepted)
#   2 harness/conventions · 2 docs/plan/planning/done · 2 docs/plan/carveouts/done
#   1 spec/lastenheft.md (Rang 1) · 1 observations/…/evidence (ab Merge eingefroren)
```

Das Werkzeug nennt die Alternativen-Menge selbst — *„erst den Verweis aufloesen (oder die Referenz
im Doku-Gate ausnehmen, mit ADR nach AGENTS.md 3.5)"* —, und die Ziel-Form fügt eine dritte und
vierte hinzu: dem Report entgegen ihrem Wortlaut einen Stub geben (eine Abweichung, die einen
Eintrag im Adaptions-Block braucht), oder den Report-Bestand von der Archivierung ausnehmen. Welche
gilt, entscheidet dieser Slice.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der wellenlose Altbestand und seine Zuordnung** — das ist
  [slice-183](../done/slice-183-ausloeser-der-wellenlosen-archivierung.md), eine eigene
  Frage mit eigener Alternativen-Menge (nächste geschlossene Welle oder Sammel-Archiv). Beide sind
  Vorbedingung derselben ersten Archivierung und in beliebiger Reihenfolge lieferbar.
- **Das Umschreiben der 144 Verweise** — es wäre ein anderer Vorgang und hängt am Ausgang: Nur
  eine der vier Alternativen verlangt es überhaupt. Fällt die Entscheidung dorthin, benennt sie
  ihren Folge-Slice mit Kennung; ihn vorab zu schneiden hieße, das Ergebnis vorwegzunehmen.
- **Was der Verweis-Nachzug in einem eingefrorenen Artefakt darf** — dieselbe Berührung, anderer
  Gegenstand: Dort wird ein Artefakt **geschrieben**, hier bricht ein Verweis. Die Frage steht mit
  Zähler im Register
  ([`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md))
  und ist eine Norm-Frage des Architect; sie steht als Risiko in §6, weil eine der vier
  Alternativen sie auslöst.
- **Kein Produkt-Code.** Weder `internal/archive/` noch die Sperre selbst werden angefasst: Die
  Sperre meldet richtig, was sie meldet. Ein Slice, der die Meldung abschaltet, statt ihren
  Gegenstand zu entscheiden, wäre eine Schwellen-Senkung ohne Entscheidung.

## 2. Definition of Done

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Ziel-Form: Slice — **≤ 3 Liefer-Punkte**; mehr heißt: der Slice ist zu groß und
gehört zurück zur Zerlegung. Gezählt wird nur, was mit dem Umfang wächst — die
Gate-Läufe und die fünf Closure-Pflichten darunter zählen nicht mit.

- [x] **Die ADR liegt und entscheidet den Ausgang** — was mit einem eingehenden Verweis auf einen
      Review-Report geschieht, den die Archivierung einsammelt. Die vier Alternativen aus §1 sind
      abgewogen (auflösen · Stub entgegen der Ziel-Form · Referenz-Ventil im Doku-Gate ·
      Report-Bestand ausnehmen), die gewählte nennt ihren **Preis**. Fällt sie auf das Ventil, ist
      sie eine Senkung nach [`AGENTS.md`](../../../../AGENTS.md) §3.5 und hält sich an die
      Aufnahme-Grenze, die
      [`ADR-0039`](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) für dieselbe
      Apparatur gezogen hat. Die Entscheidung nennt ihren `Status`; bei `Proposed` steht der
      Acceptance-Trigger daneben.
- [x] **Die Abweichung vom Wortlaut der Ziel-Form ist ausgesprochen und eingeordnet.** Die
      Ziel-Form gibt Reports keinen Stub, weil sie *„keine Identität jenseits ihres Slice"* haben;
      der Bestand dieses Repos widerspricht dieser Voraussetzung messbar (§1). Ob daraus ein
      Eintrag im Adaptions-Block wird, entscheidet die ADR — eine unerklärte Abweichung wäre ein
      Fork nach
      [`MR-000`](../../../../harness/conventions.md#mr-000--baseline-aussage), keine Adaption.
- [x] **Der Sensor-Stand ist benannt statt behauptet.** Kein Gate dieses Repos hält den Status
      eines Artefakts gegen die Form seiner Adressen; was die Lage meldet, ist die
      `[haenger]`-Sperre der Vorschau, und die ist kein Gate und steht in keiner
      Prerequisite-Kette
      ([`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).
      Wählt die Entscheidung ein Ventil, benennt sie zusätzlich, was es stumm schaltet.
- [x] `make gates` grün.
- [x] Review durchgeführt, Report unter `docs/reviews/` liegt vor
      (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des
      Minimal Agent Workflow ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8);
      er ist zugleich der Beleg, den
      [`ADR-0040`](../../adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2
      für einen Accept-Übergang verlangt.
- [x] Doku-Update: der ADR-Index ([`docs/plan/adr/README.md`](../../adr/README.md)) trägt die neue
      Zeile ([`AGENTS.md`](../../../../AGENTS.md) §5). Ein öffentlicher Vertrag ist nicht berührt.
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
| `docs/plan/adr/` | neu | die Entscheidung, per `cp` aus der vendored ADR-Vorlage |
| [`docs/plan/adr/README.md`](../../adr/README.md) | update | der Index wächst mit der ADR |
| `harness/conventions/` | ggf. neu | **nur**, wenn die Entscheidung die Bestands-Abweichung als Adaption führt — der Eintrag entsteht dann im Architect-Lauf ([`AGENTS.md`](../../../../AGENTS.md) §3.8), nicht nebenbei |

**Was die Entscheidung an Umsetzung nach sich zieht, benennt sie selbst.** Drei der vier
Alternativen verlangen Arbeit am Bestand — Verweise umschreiben, Stubs erzeugen, ein Ventil
eintragen; die Kennung des Folge-Slice steht dann in der ADR, die Datei in `open/` schneidet der
Planner. Vorab geschnitten wird keiner: Welcher es ist, entscheidet erst der Ausgang.

## 4. Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Trigger je Lifecycle-Übergang und WIP-Limit.

**Start** (`next` → `in-progress`): keine Abhängigkeit offen, WIP-Limit frei. Der Gegenstand liegt
vollständig im Baum, und dass er es tut, ist beobachtbar: `make host-bin`, dann
`.harness/state/bin/ai-harness-init archive-welle --vorschau welle-13` meldet die Sperre
`[haenger]`. Die Entscheidung braucht weder einen Pin-Sprung noch einen Vorgänger-Slice —
[slice-183](../done/slice-183-ausloeser-der-wellenlosen-archivierung.md) entscheidet eine
andere Frage und darf vorher oder nachher liegen.

**Rückführungen — vorab benennen, nicht erst im Nachhinein begründen:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn sich die vier Alternativen nicht mit
  **einer** Entscheidung abwägen lassen, weil zwei von ihnen verschiedene Artefakt-Klassen
  regieren (ein Referenz-Ventil gehört in die Gate-Config, ein Report-Stub in die Ablage-Regel).
  Dann trennt der Schnitt nach Artefakt-Klasse, nicht nach Alternative.
- `in-progress` → `open` (blockiert — Carveout?): wenn die Abwägung eine Eigenschaft des gepinnten
  Doku-Gates voraussetzt, die ungemessen ist — etwa das Verhalten eines `ignore-refs`-Paars über
  ein ganzes Verzeichnis statt über ein benanntes Paar. Eine Sonde am gepinnten Werkzeug ist
  Implementer-Arbeit und kein Zwischenschritt in einem Architect-Lauf.

## 5. Closure-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Closure- und Lerneintrag-Regeln — zwei beobachtbare Kriterien **und** ein
Lerneintrag; ohne ihn ist der Slice nur abgelegt.

DoD vollständig; die ADR trägt `Status:` und, falls `Proposed`, ihren Acceptance-Trigger; der
Ausgang der `[haenger]`-Sperre ist entschieden und, wo er Arbeit am Bestand verlangt, als
Folge-Slice mit Kennung benannt; Closure-Notiz mit Steering-Loop-Lerneintrag geschrieben.

## 6. Risiken und offene Punkte

Regeln dieser Sektion: Baseline-Regelwerk `modul-05-planning-harness.md`
§Offene Risiken werden bei Closure aufgelöst — **jedes** Risiko bekommt genau
**einen** Ausgang, und kein Slice geht nach `done/`, während eines ohne Ausgang
dasteht.

- **Die Alternative *auflösen* vollzieht selbst die Klasse, die sie vermeiden soll.** **Neun** der
  44 Fundstellen liegen in Quellen, die niemand mehr überschreibt oder die über dem Plan rangieren
  — zwei `Accepted`-ADRs (3), ein aufgelöster Carveout (2), ein append-only
  `harness/conventions/`-Eintrag (2), eine ab Merge eingefrorene Evidence-Datei (1) und
  [`spec/lastenheft.md`](../../../../spec/lastenheft.md) selbst (1), Rang 1 der Source Precedence.
  Für sie heißt *„den Verweis auflösen"*: das eingefrorene Artefakt schreiben
  ([`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md),
  Stand `offen`). Die Abwägung muss das als Preis führen, nicht übersehen.
  — **Ausgang: entfallen.** Die ADR wählt Alternative b) (Stub am unveränderten Pfad), nicht
  Alternative a) (auflösen); das Risiko war an die nicht gewählte Alternative gebunden und tritt
  für diesen Slice-Ausgang nicht ein. Die Beobachtung
  [`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md)
  bleibt `offen` im Register — sie beschreibt eine Eigenschaft der nicht gewählten Alternative,
  nicht eine Eigenschaft dieses Ausgangs, und wird darum **nicht** als durch diesen Slice
  bewegt gebucht.
- **Die Alternative *Ventil* macht den Text gate-sicher und nimmt ihm die Auskunft**
  ([`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md),
  Stand `offen`). Ein Ventil über ein ganzes Verzeichnis ist zudem breiter als die vier
  bestehenden, die je ein benanntes Paar tragen — es schaltete jede künftige tote Report-Adresse
  stumm, nicht nur die archivierten ([`AGENTS.md`](../../../../AGENTS.md) §3.11, letzter Absatz).
  — **Ausgang: entfallen.** Die ADR wählt Alternative b), nicht Alternative c) (Referenz-Ventil);
  aus demselben Grund wie oben tritt das Risiko für diesen Ausgang nicht ein. Die Beobachtung
  [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
  bleibt `offen` im Register — dieselbe Begründung, angewandt auf die andere nicht gewählte
  Alternative.
- **Der Report-Bestand wächst, während die Entscheidung offen ist.** Jede Review-Runde legt eine
  weitere Datei an, und jede Kreuz-Referenz zwischen Reports erhöht die Fundmenge; eine
  Entscheidung, die auf eine eingefrorene Zahl gestützt wird, ist beim Vollzug falsch. Die
  Kommandos in §1 bleiben darum die Messstelle, nicht ihre heutigen Werte
  ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)).
  — **Ausgang: entfallen.** Die Entscheidung liegt jetzt vor ([ADR-0061](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md),
  Alternative b gewählt); das Risiko betraf nur die Zeit bis zur Entscheidung. Es hat sich während
  der Bearbeitung konkret bestätigt — der Report-Bestand wuchs von 144/345 auf 171/520
  Report-Verweise, die `[haenger]`-Fundstellen von 44 auf 58 — und wurde korrekt behandelt: Der
  Architect zog die ADR-Zahlen nach (`522acc0f`), statt auf der eingefrorenen Ausgangsmessung zu
  bestehen. Der Nachzug selbst deckte einen Folgefehler auf — siehe §7 *Was ging anders als
  geplant* und die neu angelegte Beobachtung
  [`BEO-ALL/adr-korrektur-zieht-parallelen-adaptions-eintrag-nicht-nach`](../observations/BEO-ALL/adr-korrektur-zieht-parallelen-adaptions-eintrag-nicht-nach/observation.md).

## 7. Closure-Notiz

Regeln dieser Sektion: Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register (vorhandene Kennung **zitieren** statt neu
formulieren — sonst zählt das Register zwei Namen getrennt) ·
`grundlagen-traceability.md` §Herkunfts-Anker für Steering-Loop-Regeln (das
Feld `liegt in` steht **nur**, wenn mit diesem Slice wirklich etwas verkörpert
wurde; Feld und Zielort auf **einer** Zeile, Sektionsangabe innerhalb der
Backticks).

**Rolle:** Planner · **Datum:** 2026-09-22.

- **Was hat funktioniert:** Die vier Alternativen (auflösen · Stub entgegen der Ziel-Form ·
  Referenz-Ventil · Report-Bestand ausnehmen) waren im Slice-Plan §1 bereits vollständig
  vorstrukturiert — mit Preis, Register-Verweis und Fundstellen-Zahlen je Alternative. Der
  Architect-Lauf musste nur noch abwägen und entscheiden, keine zusätzliche Erkundung war nötig;
  die Entscheidung für Alternative b (Stub am unveränderten Pfad) fiel entlang genau der Linien,
  die der Plan vorgezeichnet hatte.
- **Was ging anders als geplant:** Der Report-Bestand wuchs während der Bearbeitung spürbar (144
  von 345 Report-Verweisen bei Planung auf 171 von 520 bei Verifikation, die
  `[haenger]`-Fundstellen von 44 auf 58) — Risiko 3 aus §6 bestätigte sich konkret. Die ADR wurde
  daraufhin einmal nachgezogen (`522acc0f`, Reviewer-Finding F-1/F-3), aber dieser Nachzug traf
  zunächst nur die ADR selbst, nicht den parallelen Adaptions-Eintrag
  [`MR-072`](../../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form),
  der dieselbe Entscheidung und dieselbe Messung dokumentiert. Der Verifier fand die Abweichung;
  ein weiterer Commit (`c619f314`) zog
  [`MR-072`](../../../../harness/conventions.md#mr-072--ein-review-report-bekommt-beim-archivieren-einen-stub-entgegen-dem-wortlaut-der-ziel-form)
  nach. **Zwei Norm-Artefakte zur selben Entscheidung sind damit ein eigenes
  Synchronisations-Risiko**, das kein bestehender Sensor hält:
  [`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)/[`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
  prüfen die Form einer Zahl je Kommando, nicht die Übereinstimmung zwischen zwei Kommandos in
  zwei Dateien.
- **Steering-Loop-Eintrag:** Kein neuer — die Beobachtung ist mit diesem Slice ihr erstes
  Auftreten (1×, `offen`), sie erreicht die 3×-Schwelle nicht. Sie ist neu im Register angelegt
  (siehe unten), statt direkt embodied zu werden: Ein einzelnes Auftreten trägt noch keine
  geschärfte Regel und keinen neuen Sensor, und eine Spec-Stelle fehlt ihr als Gegenstand — sie
  ist eine Prozess-Beobachtung, keine Lücke im Vertrags- oder Technik-Stratum.
- **Beobachtungs-Register (`../observations/`):** Drei vorhandene Kennungen **zitiert**, keine mit
  neuer Evidence — die zwei Risiko-Beobachtungen
  ([`BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt`](../observations/BEO-ALL/verweis-nachzug-schreibt-in-eingefrorenes-artefakt/observation.md),
  [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md))
  blieben `offen` ohne neuen Beleg, weil sie an die zwei **nicht** gewählten Alternativen gebunden
  waren (§6) — sie durch diesen Slice als bewegt zu buchen wäre falsch, der Ausgang dieses Slice
  betrifft sie nicht. Ebenso zitiert, mit Ausgang **entfallen**:
  [`BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus`](../observations/BEO-ALL/slice-plan-umfang-waechst-ueber-umsetzung-hinaus/observation.md)
  ist einschlägig für §8, bewegt sich mit diesem Slice aber nicht (er entscheidet eine Frage und
  schneidet die Umsetzung nicht vorweg, wie §1/§3 bereits belegen). **Neu angelegt:**
  [`BEO-ALL/adr-korrektur-zieht-parallelen-adaptions-eintrag-nicht-nach`](../observations/BEO-ALL/adr-korrektur-zieht-parallelen-adaptions-eintrag-nicht-nach/observation.md)
  — die Klasse, die dieser Slice real erlebt hat: eine ADR-Korrektur zieht ihren parallelen
  Adaptions-Eintrag nicht automatisch nach. Beleg ist `evidence/slice-216.md`, Stand `offen`,
  **1×**. Nachgeschlagen statt erfunden: Die naheliegendste Nachbarklasse
  [`BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen`](../observations/BEO-ALL/zusage-neben-geaenderter-ableitung-bleibt-stehen/observation.md)
  trifft eine Zusage neben einer geänderten Ableitung im Allgemeinen (Skript-Ausgabe, Testname,
  Doku-Absatz); hier sind es konkret **zwei Norm-Artefakte, die dieselbe Entscheidung parallel
  tragen** — eine engere, eigene Klasse.
  [`BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten`](../observations/BEO-ALL/werkzeug-messung-und-gemessener-stand-werden-nicht-zusammengehalten/observation.md)
  trifft die Werkzeug-Stand-Kopplung (Commit/Digest gegen Messung), nicht zwei inhaltlich
  identische Zahlen-Aussagen in zwei Norm-Dateien.
- **Folge-Slices:** ein Titel benannt, **keine Datei angelegt** — das Anlegen ist nicht Pflicht
  dieser Closure. [ADR-0061](../../adr/0061-review-report-bekommt-beim-archivieren-einen-stub.md)
  §Konsequenzen, Folgepflicht (Implementer), benennt den Auftrag selbst: `internal/archive/`
  bekommt die Stub-Emission für Reviews (Ablösung von `g.Rm(b.Reviews)`) und eine repo-eigene
  Stub-Vorlage, ohne die 171 bestehenden Verweise nachzuziehen. Titel-Vorschlag als Kennung:
  `slice-review-archivierung-schreibt-einen-stub-statt-zu-loeschen` — die Planung des Slice
  selbst (Zuschnitt, DoD, Trigger) bleibt einem eigenen Planner-Lauf vorbehalten.
- **Risiken aus §6:** drei von drei, jedes **entfallen** — die zwei ersten, weil die ADR
  Alternative b wählt und die Risiken an die je andere, nicht gewählte Alternative gebunden
  waren; das dritte, weil die Entscheidung inzwischen vorliegt, das Risiko sich während der
  Bearbeitung konkret bestätigte und korrekt behandelt wurde (Nachzug statt Ignorieren). Details
  und Begründung je Risiko stehen in §6.
- **Drei Paarungen:** dieses **Repo** fährt Wellen — Anker, Folge-Slice und Register prüft die
  nächste Welle-Closure, auch für diesen Slice ohne Wellen-Zugehörigkeit.

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

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt sind `docs/plan/adr/`, `docs/reviews/` und — nur im
bedingten Fall — `harness/conventions/`. Die Modus-Deklaration in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) führt
`*` (`ALL`), `harness/tools/` (`TOOLS`) und `.codex/` (`CODEX`); keiner der drei Pfade liegt in den
zwei engeren. Die Berührung ist `*` (`ALL`). `harness/tools/` ist **nicht** berührt: Die Sperre
liegt im Produkt-Binär (`internal/archive/`), und der Slice fasst sie nicht an (§1).

**Vorgelagert — offene Beobachtungen sichten:** Das [Register](../observations/README.md) ist
vollständig durchgegangen; jede Beobachtung trägt `*` (gesamtes Repo). Die Stände sind **gemessen**
([`MR-051`](../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
Setzung 2 — ein Zähler-Stand ist eine datierte Messung, kein Wert im Text):

```sh
ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l   # 94  (kein Erwartungswert)
cd docs/plan/planning/observations/BEO-ALL
for d in verweis-nachzug-schreibt-in-eingefrorenes-artefakt \
         gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse \
         vorgeschriebener-ortswechsel-macht-adresse-tot \
         slice-plan-umfang-waechst-ueber-umsetzung-hinaus; do
  printf '%2s  %s\n' "$(ls $d/evidence/*.md | wc -l)" "$d"; done
# 12  verweis-nachzug-schreibt-in-eingefrorenes-artefakt
#  3  gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse
#  4  vorgeschriebener-ortswechsel-macht-adresse-tot
#  2  slice-plan-umfang-waechst-ueber-umsetzung-hinaus
```

**Keine Erwartungswerte** — jeder Stand wandert mit der nächsten Closure. Vier berühren diesen
Slice; **keine** erreicht mit ihm erstmals 3×:

- **`verweis-nachzug-schreibt-in-eingefrorenes-artefakt` (12×, `offen`)** — Risiko 1 in §6; die
  Alternative *auflösen* trägt genau diese Klasse.
- **`gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse` (3×, `offen`)** — Risiko 2 in §6; die
  Alternative *Ventil* trägt sie.
- **`vorgeschriebener-ortswechsel-macht-adresse-tot` (4×, `verkörpert` in
  [`AGENTS.md`](../../../../AGENTS.md) §3.11)** — die verkörperte Regel verlangt die Messung über
  beide Adress-Formen **vor** dem Ortswechsel und stellt damit diesen Slice überhaupt; sie deckt
  ihn aber nicht ab, denn sie bindet den **schreibenden** Lauf, nicht den Bestand.
- **`slice-plan-umfang-waechst-ueber-umsetzung-hinaus` (2×, `offen`)** — bindet diesen Plan: Er
  entscheidet **eine** Frage und schneidet die Umsetzung nicht vorweg (§1, §3).

**Modus-Begründungsblock — Umfang.** Alle berührten Sub-Areas GF; ein Begründungsblock entfällt
damit. Die Sub-Area `*` (`ALL`) ist in
[`harness/conventions.md`](../../../../harness/conventions.md#modus-deklaration-pro-sub-area) als
**Greenfield** deklariert: Doc führt, Code folgt, Graduation `n/a`.
