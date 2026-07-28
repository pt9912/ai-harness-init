# ADR-0011: Telemetrie-Erfassung — Policy für Agenten-Spans

**Status:** Proposed

**Datum:** 2026-07-28

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:** [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit),
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten),
[ADR-0003](0003-go-native-binaries.md) (Docker-only im Dogfood),
[ADR-0004](0004-durchsetzungs-emission.md) (die Guard-/Hook-Bauart, an der die Erfassung andockt)

**Schärft:** `—` (Prozess-/Betriebs-ADR ohne Spec-Stratum). Die **emittierte** Seite berührt
[`architecture.md §5`](../../../spec/architecture.md) erst, wenn slice-062 sie entscheidet;
diese ADR entscheidet sie **nicht**.

---

## Kontext

`.harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` verlangt, einen Agentenlauf als
**Trace aus Spans** zu beobachten — einen pro Tool-Call, mit Korrelations-IDs, damit man von
einem Vorgang zur Anforderung zurückfindet. Das Modul ist seit dem 2026-07-17 adoptiert und in
keinem Block umgesetzt; [welle-09](../planning/welle-09-modul-15-konformitaet.md) schließt das.

**Was heute existiert** (gemessen 2026-07-28): Die Hook-Mechanik ist in beiden Agenten-Werkzeugen
verdrahtet und wird sogar ins Ziel-Repo emittiert. Der `PreToolUse`-Guard **sieht** jeden
Bash-Aufruf samt Argumenten, entscheidet — und **behält nichts** (`grep -E "log|tee|>>"` im Guard
ist leer). Es fehlt also nicht die Erfassungsstelle, sondern die Senke.

**Warum eine ADR und nicht nur ein Slice-Plan.** Der Plan-Review zu welle-09 hat es benannt: hier
entstehen eine **neue Artefakt-Klasse** (Spans), ein **neuer Datenfluss** (Agentenlauf →
Dateisystem) und eine **Sicherheitsfläche** (Tool-Argumente können Secrets tragen). Diese
Entscheidungen fallen faktisch im ersten Dogfood-Slice; sie dort implizit zu treffen, wäre genau
der stille Renderer-Entscheid, den dieses Repo bei [ADR-0009](0009-hexslice-arch-realisierung.md)
und [ADR-0010](0010-hexagonal-arch-realisierung.md) vermieden hat.

**Annahme, auf der diese ADR steht:** Telemetrie über Agentenläufe ist für uns ein **Audit- und
Kosten**-Instrument, kein Betriebs-Monitoring. Es gibt keinen Betreiber, kein SLA und kein
Dashboard. Kippt das — etwa weil das Repo selbst Agentenläufe *betreibt* —, kippt der Zuschnitt.

## Entscheidung

**Wir wählen Option C: eine lokale, fail-closed Span-Erfassung mit festgelegter Policy — und
ohne Festlegung auf ein Werkzeug.**

**Festlegung 1 — was ein Span mindestens trägt, und was mit dem passiert, was fehlt.**
Modul 15 führt **zwei** Listen, und beide gelten: die *Mindestfelder eines Tool-Call-Spans*
(`tool.name`, `tool.arguments` redigiert, `tool.result.status` plus Korrelations-IDs zu
Slice/PR/Agent-Rolle) und das *Audit-Span-Schema* mit dem **Pflicht-Minimum** Slice-ID,
Agent-Rolle, Cache-Status, `requirement.id`. Jedes Feld wird als *Pflicht* oder *Optional*
markiert und trägt seine **Incident-Frage**; ein Feld ohne Incident-Frage wird nicht erfasst.

Für jedes Pflicht-Feld, das aus der verfügbaren Quelle **nicht erschließbar** ist, gilt:
**begründet dokumentieren, nicht weglassen.** Das betrifft heute absehbar `requirement.id`
(steht nur im Slice-Plan) und den Cache-Status (steht im Transkript des Werkzeugs, nicht in der
Hook-Payload). Eine stillschweigend verkürzte Feldliste ist die Fehlerklasse, die der
welle-09-Plan-Review als HIGH gefunden hat.

**Festlegung 2 — Redaktion ist eine Allowlist, nicht eine Denylist.**
Erfasst werden **nur** ausdrücklich freigegebene Felder und Muster; alles andere wird redigiert.
Begründung, und sie ist der Kern dieser ADR: eine Denylist prüft die Muster, die dem Autor
eingefallen sind, und kann unter keiner **realen** Lücke rot werden — sie sieht genau die
Secrets nicht, die niemand vorhergesehen hat. Ein Audit-Log, das Secrets sammelt, ist schlimmer
als kein Audit-Log: es verlagert das Risiko, statt es zu senken. Dieselbe Linie wie der
gebackene Guard-Boden ([`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed):
*laut falsch schlägt leise falsch*).

**Festlegung 3 — Spans liegen außerhalb des versionierten Baums, und das ist Korrektheit, nicht
Ordnung.** Der Gate-Nachweis hasht **getrackte und untrackte** Dateien
([`MR-003`](../../../harness/conventions.md#mr-003--härtung-inhaltsbasierter-nachweis-und-sub-shell-prüfung)).
Ein Span-File im Arbeitsbaum ginge in diesen Hash ein: jeder Tool-Call änderte den Nachweis, den
der Stop-Hook prüft, und der Hook blockierte sich selbst. Spans gehören daher an denselben Ort
wie der Gate-Stempel — den gitignorierten Zustands-Bereich. **Sie sind flüchtig**: kein Artefakt
des Repos, kein Review-Gegenstand, keine Beleg-Quelle für eine Zusage.

**Festlegung 4 — die Mechanik ist Ergebnis der Messung, nicht dieser ADR.**
Welches Hook-Event, welcher Matcher, welche Sprache, welches Dateiformat — all das entscheidet
der umsetzende Slice **nach** seinen Messungen (u. a.: trägt die Payload einen Ergebnis-Status?
feuern Hooks in Subagenten? welche Tool-Calls sieht der registrierte Matcher überhaupt?). Diese
ADR legt die **Randbedingung** fest: *keine neue Abhängigkeit*. Die Grenzen sind je Ebene
verschieden — im Repo Docker-only ([ADR-0003](0003-go-native-binaries.md)), im emittierten Ziel
zusätzlich [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)
(`bash + git + docker`). Eine ADR, die hier ein Werkzeug festschriebe, entschiede gegen eine
Messung, die noch aussteht.

**Festlegung 5 — diese ADR gilt für das Repo; die Emission ist eine eigene Entscheidung.**
Ob ein Ziel-Repo einen Span-Emitter bekommt, entscheidet slice-062 samt Change Request
([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)):
es ändert den Adopter-Vertrag. **Festlegung 2 und 3 sind dabei jedoch portabel gemeint** — wenn
emittiert wird, dann mit Allowlist und außerhalb des versionierten Baums. Eine laxere Fassung
für fremde Repos wäre die Umkehrung unserer eigenen Begründung.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun** (Status quo) | kein Aufwand, keine neue Sicherheitsfläche; die Transkripte des Werkzeugs existieren ohnehin | Modul 15 bleibt in allen vier Blöcken unumgesetzt; die Transkripte tragen **keine** Korrelations-IDs (`agent.role` steht dort als `general-purpose`, `slice.id` gar nicht — gemessen), also ist weder Token-Attribution je Rolle noch Slice-Bezug möglich; die Nicht-Umsetzung bliebe undiskutiert |
| B — **OTel-Stack** (SDK, Collector, Backend, Dashboard) | Standard-Format, Werkzeug-Ökosystem, beliebig auswertbar | verletzt [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (neue Laufzeit-Abhängigkeit) und wäre im emittierten Ziel gar nicht tragbar; ein Backend ohne Betreiber ist Infrastruktur ohne Abnehmer — genau das, was Modul 15 mit *„ein Attribut ohne Incident-Frage fliegt raus"* ausschließt |
| **C — lokale Span-Erfassung mit Policy, Werkzeug offen (gewählt)** | nutzt die **bereits verdrahtete** Hook-Mechanik; keine neue Abhängigkeit; die Sicherheitsfrage ist vorab entschieden (Allowlist) statt nachträglich gehärtet; die Werkzeug-Wahl bleibt der Messung überlassen | die Auswertung ist Eigenbau (kein Ökosystem); die Abdeckung hängt an dem, was das Agenten-Werkzeug an Hook-Events hergibt — möglicherweise weniger als „jeder Tool-Call" |
| D — **nur Transkripte auswerten**, gar nicht erfassen | null Erfassungs-Aufwand, keine neue Sicherheitsfläche, die Daten liegen schon vor | die Datenquelle liegt **außerhalb** des Repos, gehört uns nicht und kann sich mit dem Werkzeug ändern; ohne Korrelations-IDs bleibt die Rollen- und Slice-Zuordnung Rekonstruktion statt Messung (real erlebt: die Rollen-Zuordnung dieser Sitzung stammte aus dem Gedächtnis, nicht aus den Daten) |

## Konsequenzen

- **Positiv:** die Erfassung entsteht dort, wo die Mechanik schon sitzt — kein neuer Baustein im
  Bootstrap-Pfad. Die Sicherheitsentscheidung fällt **vor** dem ersten Span, nicht nach dem
  ersten Vorfall. Und die Werkzeug-Wahl bleibt dort, wo sie hingehört: bei der Messung.
- **Negativ:** die Auswertung ist Eigenbau; wer OTel-Werkzeuge erwartet, findet keine. Die
  Allowlist kostet laufende Pflege — jedes neue Feld, das erfasst werden soll, muss ausdrücklich
  freigegeben werden (das ist der Preis von fail-closed, und er ist gewollt).
- **Negativ, ehrlich benannt:** die Abdeckung ist womöglich **kleiner** als „jeder Tool-Call".
  Der heute registrierte Matcher (`Bash`) sähe keinen `Write`/`Edit`-Aufruf — also gerade die
  Schreibzugriffe, nach denen die Incident-Frage zu `slice.id` fragt. Wird die Abdeckung nicht
  vollständig, ist die **Zusage** einzuschränken, nicht die Lücke zu verschweigen.
- **Folgepflicht 1:** das Span-Schema (Feld · Pflicht/Optional · Incident-Frage) wird als
  `MR-<NNN>` in [`harness/conventions.md`](../../../harness/conventions.md) geführt — es ist eine
  Strukturregel, kein Implementierungsdetail, und der nächste Leser muss es ohne Code finden.
- **Folgepflicht 2:** jede begründete Abweichung vom Pflicht-Minimum (Festlegung 1) steht in
  diesem `MR`-Eintrag, nicht in einem Kommentar.
- **Folgepflicht 3:** die Nutzer-Doku bleibt unberührt, **solange nicht emittiert wird** — Spans
  sind bis dahin ein Dogfood-Werkzeug ohne Adopter-Wirkung.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `test/mutations/` | Ein Span **ohne Pflicht-Feld** färbt seinen Wächter rot | `make mutate` |
| `test/mutations/` | Ein Feld, das **nicht** auf der Allowlist steht, wird nicht durchgelassen — die Mutation setzt ein neues Feld ein und muss rot werden | `make mutate` |
| bats (`make test`) | Der Ablageort liegt **außerhalb** des versionierten Baums: nach einem Lauf mit Spans ist `git status --porcelain` unverändert | `make test` |
| `make gates` | Der Gate-Nachweis bleibt heil: ein Lauf mit geschriebenen Spans lässt den Working-Tree-Hash unverändert (sonst blockierte der Stop-Hook sich selbst) | `make gates` |

## Re-Evaluierungs-Trigger

- **Wenn das Agenten-Werkzeug seine Hook-Oberfläche ändert** (neue Events, andere Payload) —
  dann ist die Abdeckung neu zu messen und die Zusage aus Festlegung 1 nachzuziehen.
- **Wenn Hooks in Subagenten nicht feuern** und die Rollen-Zuordnung dauerhaft am Transkript
  hängt — dann ist Option D für den Rollen-Teil erneut zu prüfen, diesmal mit Messung.
- **Wenn Spans emittiert werden sollen** (slice-062): Festlegung 5 wird dort eingelöst, und die
  Portabilität von Festlegung 2/3 ist am realen Ziel zu belegen, nicht zu behaupten.
- **Wenn dieses Repo selbst Agentenläufe betreibt** (statt in einem fremden Werkzeug zu laufen) —
  dann kippt die Annahme „Audit, kein Betriebs-Monitoring", und Option B ist neu zu bewerten.
- **Wenn die Allowlist in der Praxis mehr blockiert als sie schützt** — messbar daran, dass
  Spans regelmäßig ohne verwertbaren Inhalt entstehen. Dann ist die Feld-Auswahl falsch
  geschnitten, nicht das Prinzip.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-28 | Proposed | welle-09 §4 / slice-059 §6 (der Plan-Review vom 2026-07-28 verlangte die Entscheidung **vor** dem Slice) — auf die Slice-**ID** verwiesen, nicht auf den Pfad: der wandert durch die Lifecycle-Ordner |
