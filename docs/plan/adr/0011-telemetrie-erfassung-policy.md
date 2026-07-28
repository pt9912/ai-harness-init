# ADR-0011: Telemetrie-Erfassung — Policy für Agenten-Spans

**Status:** Proposed

**Datum:** 2026-07-28

**Autor:** ai-harness-init-Team (pt9912)

**Bezug:** [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (die
Randbedingung aus Festlegung 4 — verbatim zitiert, nicht paraphrasiert),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6) (jede
Fitness Function unten muss rot werden **können**; die tautologische ist deshalb gestrichen),
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

**Was die Hook-Oberfläche hergibt** (an der Werkzeug-Doku gemessen, 2026-07-28,
<https://code.claude.com/docs/de/hooks>): ein Nach-Event mit dem Tool-Ergebnis und ein eigenes
Fehlschlag-Event; eine gemeinsame `tool_use_id` über Vor- und Nach-Event (die Span-Identität);
`transcript_path` als Brücke zu den Token-/Cache-Zählern; und — entscheidend für die
Rollen-Achse — Hooks feuern **auch in Subagenten**, mit `agent_id`/`agent_type` in der Payload.
Ein leerer Matcher trifft **alle** Tools; die heutige Bash-Enge ist also eine
Registrierungs-Entscheidung, keine Plattform-Grenze.

*Zur Quelle:* sie ist **Herkunft, nicht Inhalt** — die Aussagen stehen hier ausgeschrieben,
damit diese ADR lesbar bleibt, wenn die Seite sich ändert. Anders als die Kurs-Links ist sie
**nicht gepinnt**, und kein Gate prüft sie (`docs-check` läuft netzlos). Genau deshalb steht ihr
Wandel unten als Re-Evaluierungs-Trigger.

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

**Wir wählen Option C: eine lokale Span-Erfassung mit festgelegter Policy — der Erfassungs-*Umfang*
fail-closed (im Zweifel nichts erfassen), der Erfassungs-*Betrieb* fail-open (im Zweifel den Lauf
nicht behindern) — und ohne Festlegung auf ein Werkzeug.**

**Festlegung 1 — die Schema-POLICY, nicht die Feldtabelle.** Diese ADR entscheidet, *wie* das
Schema zustande kommt und was mit Lücken geschieht; die konkrete Feldtabelle ist ein
`MR-<NNN>`-Artefakt (Folgepflicht 1). Der Grund wird ausgesprochen statt umgangen: die Tabelle
**wächst** mit jedem Feld, das seine Incident-Frage verdient — eine ab *Accepted* immutable ADR
ist der falsche Ort dafür. Die Policy selbst ist bindend:

1. **Beide Listen aus Modul 15 gelten** — die *Mindestfelder eines Tool-Call-Spans* und das
   *Audit-Span-Schema* mit dem Pflicht-Minimum (Slice-ID, Agent-Rolle, Cache-Status,
   `requirement.id`). Keine darf gegen die andere ausgespielt werden.
2. **Ein Feld ohne Incident-Frage wird nicht erfasst** — und die Frage steht neben dem Feld,
   nicht in einem Kommentar.
3. **Die Argument-Allowlist beginnt LEER.** Ein Feld kommt hinein, wenn es seine Incident-Frage
   nachweist — nicht, weil es verfügbar ist. Das ist die operative Fassung von *fail-closed im
   Umfang*.
4. **Ein nicht erschließbares Pflicht-Feld wird begründet dokumentiert, nicht weggelassen.**
   Betrifft absehbar `requirement.id` (steht nur im Slice-Plan) und den Cache-Status (steht im
   Transkript, nicht in der Hook-Payload). Eine stillschweigend verkürzte Feldliste ist die
   Fehlerklasse, die der welle-09-Plan-Review als HIGH gefunden hat.

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
wie der Gate-Stempel — den gitignorierten Zustands-Bereich. Dazu drei Auflagen, die keine
Kosmetik sind:

- **Modus restriktiv (`0600`), vom Emitter selbst gesetzt.** Gemessen 2026-07-28: das
  Zustands-Verzeichnis ist `775`, die Stempeldatei `664` — welt-lesbar. Für einen Gate-Hash ist
  das folgenlos; für ein Audit-Log mit Pfaden und Argumenten nicht.
- **Lebensdauer: die Sitzung.** Spans werden je Sitzung neu angelegt statt fortgeschrieben; ein
  Lauf hinterlässt keinen wachsenden Bestand. Wer sie aufheben will, kopiert sie bewusst heraus
  — dann sind es seine Artefakte, nicht unsere.
- **Kein Beleg-Status.** Ein Span ist kein Review-Gegenstand und keine Quelle für eine Zusage im
  Sinne von [`AGENTS.md`](../../../AGENTS.md) §3.6. Was belegt werden muss, wird gemessen — nicht
  aus dem Log gelesen.

**Festlegung 4 — die Randbedingung ist „keine Host-Sprachlaufzeit"; das Werkzeug entscheidet die
Messung.** Welches Hook-Event, welcher Matcher, welches Dateiformat — das entscheidet der
umsetzende Slice **nach** seinen Messungen. Was diese ADR festlegt, ist die Grenze, und sie ist
schärfer als „keine neue Abhängigkeit":
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) verlangt verbatim
*„die Laufzeit beim Bootstrap braucht nur **git + docker** (keine Host-Sprachlaufzeit, kein
Paketmanager)"* — und das bindet **dieses Repo**, nicht nur das Ziel (*„Emittierte Ziel-Repos
bleiben make/docker-getrieben"*).

*(Diese Fassung korrigiert Runde 1, die dieselbe Anforderung auf das Ziel verengt und ihren
Wortlaut um `bash` erweitert hatte — beides falsch, vom Proposed-Review nachgewiesen.)*

**Konkrete Folge, damit die Regel nicht abstrakt bleibt:** ein Hook-Skript in einer
Host-Sprachlaufzeit ist damit **ausgeschlossen** — auch dann, wenn der Command-Guard es heute
nicht blockt (sein BLOCKED-Set führt die Paketmanager, nicht jeden Interpreter). Toleranz des
Guards ist keine Erlaubnis der Anforderung. Die vorhandene Durchsetzungsschicht ist zero-dep
bash+awk ([ADR-0004](0004-durchsetzungs-emission.md)); die Erfassung bleibt in derselben Klasse.

**Festlegung 5 — das OB der Emission entscheidet der Change Request, das WIE entscheidet diese
ADR.** Ob ein Ziel-Repo überhaupt einen Span-Emitter bekommt, ist eine Vertragsänderung und
gehört slice-062 samt CR
([`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)).
**Wird emittiert, gelten die Festlegungen 1–4 und 6 unverändert** — leere Start-Allowlist, Ablage
außerhalb des versionierten Baums mit restriktivem Modus, keine Host-Sprachlaufzeit, fail-open im
Betrieb. Das nimmt dem CR nichts vorweg: er entscheidet das **Ob**, nicht das **Wie**. Eine
laxere Fassung für fremde Repos wäre die Umkehrung unserer eigenen Begründung — und nach
[`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
ist der Default für unbekannte Adopter ohnehin die strengere Seite.

**Festlegung 6 — Telemetrie ist fail-OPEN, der Guard bleibt fail-closed.** Ein Erfassungs-Hook
läuft an **jedem** Tool-Call. Er darf einen Lauf niemals blockieren oder spürbar verzögern: kein
blockierender Exit-Code, ein **eigener harter Timeout deutlich unterhalb des Werkzeug-Defaults**
(dokumentiert sind 600 s — als Grenze für ein Audit-Skript unbrauchbar), und bei jedem Fehler
gilt *Span verloren, Lauf läuft weiter*.

Die Gegen-Entscheidung ist real und wird **bewusst verworfen**: ein fail-closed Audit („kein
Span, keine Aktion") ist in regulierten Umgebungen richtig — dort wiegt der fehlende Nachweis
schwerer als der ausgefallene Arbeitsschritt. Bei uns wäre er ein Selbsttor: ein defektes
Audit-Skript legte die gesamte Arbeit still, und der erste Reflex wäre, den Hook abzuschalten —
womit die Erfassung ganz verschwände. **Der Unterschied zum Guard liegt in der Aufgabe:** der
Guard *verhindert* etwas und muss im Zweifel blockieren; die Telemetrie *beobachtet* und darf im
Zweifel nur sich selbst verlieren. Beide Richtungen sind begründet, keine ist Nachlässigkeit —
und der Verlust wird **sichtbar gemacht**, nicht verschluckt (Folgepflicht 4).

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun** (Status quo) | kein Aufwand, keine neue Sicherheitsfläche; die Transkripte des Werkzeugs existieren ohnehin | Modul 15 bleibt in allen vier Blöcken unumgesetzt; die Transkripte tragen **keine** Korrelations-IDs (`agent.role` steht dort als `general-purpose`, `slice.id` gar nicht — gemessen), also ist weder Token-Attribution je Rolle noch Slice-Bezug möglich; die Nicht-Umsetzung bliebe undiskutiert |
| B — **OTel-Stack** (SDK, Collector, Backend, Dashboard) | Standard-Format, Werkzeug-Ökosystem, beliebig auswertbar | verletzt [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) (neue Laufzeit-Abhängigkeit) und wäre im emittierten Ziel gar nicht tragbar; ein Backend ohne Betreiber ist Infrastruktur ohne Abnehmer — genau das, was Modul 15 mit *„ein Attribut ohne Incident-Frage fliegt raus"* ausschließt |
| **C — lokale Span-Erfassung mit Policy, Werkzeug offen (gewählt)** | nutzt die **bereits verdrahtete** Hook-Mechanik; keine neue Abhängigkeit; die Sicherheitsfrage ist vorab entschieden (Allowlist) statt nachträglich gehärtet; die Werkzeug-Wahl bleibt der Messung überlassen | die Auswertung ist Eigenbau (kein Ökosystem); die Abdeckung hängt an dem, was das Agenten-Werkzeug an Hook-Events hergibt — möglicherweise weniger als „jeder Tool-Call" |
| E — **Korrelations-Hook ohne Payload**: der Span trägt nur IDs (`tool_use_id`, Tool-Name, Slice, Agent, Status), die Argumente bleiben im Transkript | löst die Sicherheitsfläche **fast vollständig** auf — was nie erfasst wird, kann nicht leaken; minimaler Hook, minimale Kosten | die Incident-Frage *„was wurde wohin geschrieben?"* ist dann nur über das Transkript beantwortbar, also über eine Quelle außerhalb des Repos — und `tool.arguments` (redigiert) steht im Modul-15-Mindestsatz, das Weglassen wäre eine begründungspflichtige Abweichung. **Wichtig:** E ist der **Grenzfall von C** — mit leerer Allowlist *ist* C genau E. Festlegung 1.3 macht E damit zum **Startzustand**, aus dem heraus jedes Feld sich einzeln rechtfertigen muss |
| D — **nur Transkripte auswerten**, gar nicht erfassen | null Erfassungs-Aufwand, keine neue Sicherheitsfläche, die Daten liegen schon vor | die Datenquelle liegt **außerhalb** des Repos, gehört uns nicht und kann sich mit dem Werkzeug ändern; ohne Korrelations-IDs bleibt die Rollen- und Slice-Zuordnung Rekonstruktion statt Messung (real erlebt: die Rollen-Zuordnung dieser Sitzung stammte aus dem Gedächtnis, nicht aus den Daten) |

## Konsequenzen

- **Positiv:** die Erfassung entsteht dort, wo die Mechanik schon sitzt — kein neuer Baustein im
  Bootstrap-Pfad. Die Sicherheitsentscheidung fällt **vor** dem ersten Span, nicht nach dem
  ersten Vorfall. Und die Werkzeug-Wahl bleibt dort, wo sie hingehört: bei der Messung.
- **Negativ:** die Auswertung ist Eigenbau; wer OTel-Werkzeuge erwartet, findet keine. Die
  Allowlist kostet laufende Pflege — jedes neue Feld, das erfasst werden soll, muss ausdrücklich
  freigegeben werden (das ist der Preis von fail-closed, und er ist gewollt).
- **Zur Abdeckung — am 2026-07-28 geklärt, und zwar in die gute Richtung:** die erste Fassung
  dieser ADR hielt für möglich, dass die Erfassung **kleiner** ausfällt als „jeder Tool-Call",
  weil der registrierte Matcher (`Bash`) keine `Write`/`Edit`-Aufrufe sieht — gerade die
  Schreibzugriffe, nach denen die Incident-Frage zu `slice.id` fragt. Die Doku-Messung zeigt: ein
  leerer Matcher trifft **alle** Tools. Die Enge ist unsere Registrierung, keine Grenze des
  Werkzeugs. **Die Regel bleibt trotzdem stehen**, weil sie allgemeiner gilt als dieser Fall:
  wird eine Abdeckung *doch* unvollständig, ist die **Zusage** einzuschränken, nicht die Lücke zu
  verschweigen.
- **Negativ, und jetzt der schärfere Punkt:** volle Abdeckung heißt, der Hook sieht auch
  `Write`/`Edit`-Payloads — also **Datei-Inhalte**. Die Erfassungsfläche wächst damit genau um
  das, was am ehesten Secrets trägt. Festlegung 2 (Allowlist) ist deshalb nicht Beiwerk, sondern
  die Bedingung, unter der volle Abdeckung überhaupt vertretbar ist.
- **Folgepflicht 1:** das Span-Schema (Feld · Pflicht/Optional · Incident-Frage) wird als
  `MR-<NNN>` in [`harness/conventions.md`](../../../harness/conventions.md) geführt — es ist eine
  Strukturregel, kein Implementierungsdetail, und der nächste Leser muss es ohne Code finden.
- **Folgepflicht 2:** jede begründete Abweichung vom Pflicht-Minimum (Festlegung 1) steht in
  diesem `MR`-Eintrag, nicht in einem Kommentar.
- **Folgepflicht 3:** die Nutzer-Doku bleibt unberührt, **solange nicht emittiert wird** — Spans
  sind bis dahin ein Dogfood-Werkzeug ohne Adopter-Wirkung.
- **Folgepflicht 4:** der **Verlust** eines Spans wird sichtbar (Festlegung 6). Fail-open heißt
  „der Lauf geht weiter", nicht „niemand erfährt davon" — sonst entsteht ein Log, das lückenhaft
  ist und vollständig aussieht. Wie die Sichtbarkeit aussieht (Zähler, Marker im Span-Strom),
  entscheidet der umsetzende Slice; **dass** es sie gibt, entscheidet diese ADR.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `test/mutations/` | Ein Span **ohne Pflicht-Feld** färbt seinen Wächter rot | `make mutate` |
| `test/mutations/` | Ein Feld, das **nicht** auf der Allowlist steht, wird nicht durchgelassen — die Mutation setzt ein neues Feld ein und muss rot werden | `make mutate` |
| `test/mutations/` | **Der Ablageort wird auf einen nicht-ignorierten Pfad gezogen** — der Wächter muss rot werden | `make mutate` |
| bats (`make test`) | Der Emitter setzt den restriktiven Modus **selbst**: die erzeugte Datei ist `0600`, unabhängig von den Rechten des Verzeichnisses | `make test` |
| bats (`make test`) | **Fail-open belegt:** ein absichtlich fehlschlagender Emitter (Exit ≠ 0, und getrennt: Überschreiten des eigenen Timeouts) lässt den Tool-Call **durch** | `make test` |

**Was hier bewusst NICHT steht, und warum** (Proposed-Review-Befund, Runde 1): die Zeile
*„ein Lauf mit Spans lässt den Working-Tree-Hash unverändert"* ist **gestrichen**. Sie war unter
keiner Mutation rot zu bekommen: `working-tree-hash.sh` listet mit `--exclude-standard`, schließt
gitignorierte Pfade also **unbedingt** aus — die Zusage war per Konstruktion wahr. Was die
Eigenschaft wirklich bewacht, ist die dritte Zeile oben (Ablageort verschieben ⇒ rot); die
gestrichene Zeile hätte im Gate nur Sicherheit vorgetäuscht ([`AGENTS.md`](../../../AGENTS.md)
§3.6). Ebenso gestrichen: *„`git status --porcelain` unverändert"* — dieselbe Konstruktion,
dieselbe Tautologie.

## Re-Evaluierungs-Trigger

- **Wenn das Agenten-Werkzeug seine Hook-Oberfläche ändert** (neue Events, andere Payload) —
  dann ist die Abdeckung neu zu messen und die Zusage aus Festlegung 1 nachzuziehen. Die Quelle
  (<https://code.claude.com/docs/de/hooks>) ist **nicht gepinnt** und wird von keinem Gate
  geprüft; dieser Trigger lebt daher im *inferential-feedforward*-Quadranten und wirkt nur, wenn
  ihn jemand liest — dieselbe ehrliche Einordnung wie beim Referenz-Repo-Trigger in
  [ADR-0010](0010-hexagonal-arch-realisierung.md).
- **Wenn `agent_type` nicht auf unsere Rollen abbildbar bleibt** *(feedforward — kein Sensor;
  wirkt nur, wenn ihn jemand liest)*. Die Payload liefert den *Subagent-Typ* (bei unseren
  Review-/Verify-Läufen `general-purpose`), nicht die Harness-Rolle. Solange wir keine
  rollen-benannten Agenten-Typen spawnen, ist die Rollen-Achse ein **Sammelposten** — Modul 15
  verlangt, ihn als solchen zu benennen und begründet aufzuteilen, statt eine Zuordnung zu
  behaupten. **Schwelle:** sobald ein Auswertungs-Slice (060) eine Zahl *je Rolle* ausweisen
  soll, ist die Abbildung zu entscheiden — vorher nicht.
- **Wenn Spans emittiert werden sollen** (slice-062) *(feedback — der CR ist der Auslöser)*:
  Festlegung 5 wird dort eingelöst, und die Portabilität von 1–4 und 6 ist am realen Ziel zu
  **belegen**, nicht zu behaupten.
- **Wenn dieses Repo selbst Agentenläufe betreibt** (statt in einem fremden Werkzeug zu laufen)
  *(feedforward — kein Sensor)* — dann kippt die Annahme „Audit, kein Betriebs-Monitoring", und
  Option B ist neu zu bewerten.
- **Wenn die Erfassung den Lauf messbar bremst** *(feedback — die Messung liegt im Slice)*:
  **Schwelle** ist der im Slice gemessene Aufschlag je Tool-Call; überschreitet er den dort
  festgelegten Wert, ist nicht die Grenze zu erhöhen, sondern der Umfang zu senken (Festlegung 6
  verlangt ohnehin einen harten Timeout).
- **Wenn die leere Start-Allowlist dauerhaft leer bleibt** *(feedforward)* — dann erfasst das
  Audit nur IDs, ist also faktisch Alternative E. Das ist **kein Fehler**, aber der Anlass, die
  Wahl zwischen C und E ausdrücklich zu wiederholen, statt sie durch Nichtstun zu treffen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-28 | Proposed | welle-09 §4 / slice-059 §6 (der Plan-Review vom 2026-07-28 verlangte die Entscheidung **vor** dem Slice) — auf die Slice-**ID** verwiesen, nicht auf den Pfad: der wandert durch die Lifecycle-Ordner |
| 2026-07-28 | Überarbeitet (Runde 2), weiter **Proposed** | Proposed-Review `docs/reviews/2026-07-28-adr-0011-proposed-review.md` (2 HIGH, 6 MEDIUM, 3 LOW, nicht annehmbar). **H-1** — eine Fitness Function, die unter keiner Mutation rot werden konnte (`--exclude-standard` schließt gitignorierte Pfade unbedingt aus, die Zusage war per Konstruktion wahr): gestrichen und durch den Fall ersetzt, der die Eigenschaft wirklich bewacht. **H-2** — Hook-Fehlschlag und Timeout waren nirgends entschieden, obwohl der Mechanismus an jedem Tool-Call hängt: neue **Festlegung 6** (Telemetrie fail-**open**, Guard bleibt fail-closed) samt verworfener Gegen-Entscheidung. **M** — [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) war falsch zitiert und auf das Ziel verengt (Festlegung 4 korrigiert, Randbedingung dadurch **schärfer**: keine Host-Sprachlaufzeit); Festlegung 1 war Wiedergabe statt Entscheidung (jetzt Schema-**Policy** mit leerer Start-Allowlist); Aufbewahrung, Dateimodus und Leserechte fehlten (Festlegung 3); Festlegung 5 war „portabel gemeint" statt bindend (jetzt: das **Ob** entscheidet der CR, das **Wie** diese ADR); Alternative **E** (Korrelations-Hook ohne Payload) ergänzt — sie ist der Grenzfall von C und durch die leere Start-Allowlist zugleich dessen Startzustand; Re-Evaluierungs-Trigger mit Schwellen und ehrlicher Quadranten-Kennzeichnung |
