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
3. **Das Schema ist GESCHLOSSEN: erfasst wird, was darin steht — sonst nichts.** Der Grund ist
   **nicht** Geheimhaltung, sondern Kontrolle über die eigene Datenform: bei offener Erfassung
   bestimmt der **Werkzeug-Hersteller**, was in unserem Log landet. Ein neues Feld in einer
   künftigen Payload schriebe sich still mit, und der Auswerter (slice-060) änderte sein
   Ergebnis, ohne dass jemand etwas entschieden hätte — dieselbe Klasse wie eine ungepinnte
   Quelle. `tool.arguments` **wird erfasst** und damit der Modul-15-Mindestsatz **erfüllt**; wie
   die Werte darin aussehen, regelt Festlegung 2.
4. **Ableiten schlägt deklarieren.** Ein Pflicht-Feld, das nicht in der Payload steht, ist
   zuerst auf **Ableitbarkeit** zu prüfen, bevor es zur Abweichung erklärt wird — `slice.id`
   kommt aus dem Lifecycle-Verzeichnis, `requirement.id` aus der `**Bezug:**`-Zeile der
   Slice-Datei (gemessen: jeder Slice führt seine `LH-*`-IDs maschinenlesbar). **Erst wenn keine
   Ableitung trägt**, wird begründet dokumentiert statt weggelassen. Offen ist heute genau ein
   Feld: der **Cache-Status** steht im Transkript, nicht in der Payload; ob ein Span, der den
   `transcript_path` trägt und die Auflösung dem Auswerter überlässt, den Mindestsatz erfüllt
   oder von ihm abweicht, entscheidet der umsetzende Slice — mit Beleg, nicht per Vorab-Freistellung.

**Warum diese Reihenfolge:** eine deklarierte Abweichung ist **billiger zu schreiben als eine
Lösung** und deshalb verdächtig. Von den drei Feldern, für die eine frühere Fassung dieser ADR
sie in Anspruch nahm, löst sich eines durch besseres Erfassen und eines durch eine Ableitung —
übrig bleibt eines, und das ist eine echte offene Frage.
4. **Ein nicht erschließbares Pflicht-Feld wird begründet dokumentiert, nicht weggelassen.**
   Betrifft absehbar `requirement.id` (steht nur im Slice-Plan) und den Cache-Status (steht im
   Transkript, nicht in der Hook-Payload). Eine stillschweigend verkürzte Feldliste ist die
   Fehlerklasse, die der welle-09-Plan-Review als HIGH gefunden hat.

**Festlegung 2 — Argument-Werte werden ABGELEITET erfasst, und die Schärfe ist je Ebene
verschieden.** „Redigiert" im Sinne von Modul 15 heißt nicht *weggelassen*, sondern *abgeleitet
statt roh*. Je Werkzeug wird erfasst, was die Incident-Frage beantwortet — nicht der Rohwert:

| Werkzeug | Incident-Frage | erfasst wird |
|---|---|---|
| Schreib-Werkzeuge | *was wurde **wohin** geschrieben?* | **Pfad** + **Fingerabdruck** (Länge, Hash) — **nie** der Inhalt |
| Kommando-Werkzeug | *welches Programm lief?* | **erstes Token** + Argument-Anzahl — nicht die volle Zeile |
| Lese-Werkzeuge | *worauf wurde zugegriffen?* | Pfad |

Damit wandert **kein Byte fremden Inhalts** ins Log: Massen-Abfluss über die Telemetrie ist
konstruktiv ausgeschlossen, nicht per Regel verboten.

**Das Bedrohungsmodell, benannt statt behauptet** — denn ohne Angabe, *vor wem*, ist „sensibel"
eine Stimmung: die Span-Datei liegt gitignored auf derselben Maschine wie die Quellen, die sie
beschreibt. **Wer sie lesen kann, kann auch die Dateien lesen** — Pfade verraten ihm nichts
Neues. Gemessen: sie ist nie committet, die einzige Stelle, die den Baum kopiert
(`harness/tools/mutate.sh`), schließt den Zustands-Bereich ausdrücklich aus, und ein
Mutations-Fall bewacht genau diese Ausnahme. Es bleiben **drei** reale Gründe, Inhalte dennoch
nicht zu erfassen:

1. **Persistenz über Rotation hinaus** — ein rotiertes Secret ist aus der Quelle raus und stünde
   im Log weiter.
2. **Weitergabe** — wer sein Zustands-Verzeichnis an einen Fehlerbericht hängt, schiebt Inhalte
   über die Vertrauensgrenze; Pfade wären dabei verkraftbar, Zugangsdaten nicht.
3. **Die emittierte Ebene** — und das ist der stärkste: bei einem fremden Adopter kennen wir die
   Vertrauensgrenze **nicht** (geteilter Build-Agent, Image-Schicht, Backup). Genau dafür setzt
   [`MR-017`](../../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed)
   den Default fail-closed.

**Daraus die ebenen-abhängige Schärfe:** im **Repo** dürfen Pfade und Kommando-Tokens roh
stehen — dort ist die Vertrauensgrenze bekannt und identisch mit der des Arbeitsverzeichnisses.
Für alles **Emittierte** gilt die Tabelle oben unverkürzt. *(Eine frühere Fassung begründete
dieselbe Tabelle mit einer leeren Allowlist gegen Secrets und einer Warnung vor Pfaden — die
Allowlist war ein Sicherheits-Instrument ohne benannten Gegner, die Pfad-Warnung eine importierte
Floskel. Beides ist ersetzt.)*

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
- **Lebensdauer: die Sitzung — und der Emitter räumt beim Anlegen auf, nicht beim Beenden.**
  Jede Sitzung schreibt in ihre **eigene, sitzungs-benannte** Datei; **beim ersten Span einer
  Sitzung** entfernt der Emitter ältere Bestände. Damit gibt es keinen Aufräum-Zeitpunkt, der
  bei einem Absturz ausfallen könnte, und keinen Dienst, der laufen müsste. **Er löscht dabei
  niemals die Datei einer *laufenden* fremden Sitzung** (Runde 3): parallele Läufe sind in
  diesem Repo normal — der Aufräum-Schritt muss an der Sitzungs-Kennung erkennen, was er
  anfassen darf, sonst reißt er einer nebenherlaufenden Sitzung den Bestand weg, und die
  entstehende Lücke wäre für den Lücken-Detektor gerade **nicht** sichtbar (es fehlt dann die
  ganze Datei, nicht eine Nummer). *(Runde 2 hatte zu Recht bemängelt, dass „je Sitzung eine
  Datei" ohne Löschenden ein **wachsender** Bestand ist.)* Wer Spans aufheben will, kopiert sie
  bewusst heraus; dann sind es seine Artefakte, nicht unsere.
- **Kein Beleg-Status.** Ein Span ist kein Review-Gegenstand und keine Quelle für eine Zusage im
  Sinne von [`AGENTS.md`](../../../AGENTS.md) §3.6. Was belegt werden muss, wird gemessen — nicht
  aus dem Log gelesen.

**Festlegung 4 — die Randbedingung ist „nichts, das installiert werden muss"; das Werkzeug
entscheidet die Messung.** Welches Hook-Event, welcher Matcher, welches Dateiformat — das
entscheidet der umsetzende Slice **nach** seinen Messungen. Was diese ADR festlegt, ist die
Grenze, und sie verläuft **nicht** zwischen „Shell" und „Sprache", sondern zwischen
**vorhanden** und **zu installieren**:

- **Erlaubt:** was der Harness ohnehin voraussetzt und **was auf einem POSIX-System vorhanden
  ist, ohne installiert zu werden** — `bash`, `awk`, `sed`, `grep`, die übrigen Coreutils, `git`,
  `docker`. Das Kriterium ist die **Eigenschaft**, nicht diese Aufzählung (die sonst beim
  nächsten Werkzeug altert); die Linie stammt von
  [ADR-0004](0004-durchsetzungs-emission.md): *„`awk` ist POSIX-Basis (überall vorhanden…)"*.
  Die 16 Host-Skripte dieses Repos, der Guard und der Stop-Hook liegen darin — sie sind
  **nicht** betroffen. **Eine Einschränkung, die die Erlaubnis nicht aufhebt, aber begrenzt:**
  `docker` ist erlaubt, ein **Container-Start pro Tool-Call** ist es praktisch nicht —
  [ADR-0004](0004-durchsetzungs-emission.md) hat diese Bauart mit 300–700 ms je Aufruf verworfen,
  und gegen Startup-Kosten hilft die Latenz-Schwelle unten nicht (sie senkt den *Umfang*, nicht
  den Prozessstart).
- **Ausgeschlossen:** jede Laufzeit, die ein Adopter **installieren** müsste, um den Harness zu
  betreiben. Ein Hook-Skript in einer solchen Laufzeit fällt damit heraus — auch dann, wenn der
  Command-Guard es heute nicht blockt (sein BLOCKED-Set führt die Paketmanager, nicht jeden
  Interpreter). Toleranz des Guards ist keine Erlaubnis.

**Woher die Grenze kommt — präzise, weil Runde 1 hier zweimal danebenlag.** Sie kommt **nicht**
aus der Bootstrap-Klausel von
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten): die spricht
ausweislich ihrer Messmethode (*„Binary auf frischem System mit nur git + docker → Bootstrap
grün"*) von der **Nutzer**-Laufzeit des Tools, nicht von unseren Skripten. Für die
Durchsetzungsschicht — und die Erfassung gehört dorthin — ist
[ADR-0004](0004-durchsetzungs-emission.md) die bindende Quelle — **für die Bauart der
Durchsetzungsschicht**, nicht für die Frage, was ins Ziel emittiert wird; die entscheidet
Festlegung 5 samt CR. Was
[`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) beisteuert, ist
die Zusage für die **emittierte** Seite: *„Emittierte Ziel-Repos bleiben make/docker-getrieben."*

*(Runde 1 verengte die Anforderung fälschlich aufs Ziel und erweiterte ihren Wortlaut um `bash`;
Runde 2 leitete die Repo-Bindung aus der falschen Klausel ab und geriet dadurch so weit, dass die
Regel wörtlich den eigenen Guard getroffen hätte. Beide Korrekturen stehen hier, statt die
Fehlgriffe zu glätten.)*

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

**Festlegung 6 — Telemetrie ist fail-OPEN, der Guard bleibt fail-closed — und beide teilen sich
kein Entscheidungs-Event.** Ein Erfassungs-Hook läuft an **jedem** Tool-Call. Er darf einen Lauf
niemals blockieren oder spürbar verzögern: kein blockierender Exit-Code, ein **eigener harter
Timeout deutlich unterhalb des Werkzeug-Defaults** (dokumentiert sind 600 s — als Grenze für ein
Audit-Skript unbrauchbar), und bei jedem Fehler gilt *Span verloren, Lauf läuft weiter*.

**Die Trennung ist mechanisch herzustellen, nicht durch Disziplin** (Runde 2) — **und die
Ereignis-Wahl kann sie nicht herstellen** (Runde 3). Der Grund ist gemessen, nicht vermutet:

- Hooks desselben Ereignisses laufen **parallel**, und ihre Ausgabe ist bei Exit 0 ein
  **Entscheidungs-Kanal**; wie das Werkzeug widersprüchliche Antworten aggregiert, ist nicht
  dokumentiert.
- Es gibt **kein entscheidungsfreies Ereignis**, auf das man ausweichen könnte: auch die
  Nach-Ereignisse nehmen ein Top-Level-`decision` entgegen, und `Stop`/`SubagentStop` sind
  blockierbar.
- **Dieses Repo betreibt bereits einen zweiten fail-closed Hook** — `stop-require-gates.sh` auf
  `Stop`, der bei Exit 0 ein `{"decision":"block"}` schreibt. `Stop` ist zugleich eine der
  Lauf-Grenzen, an die eine frühere Fassung dieser ADR die Erfassung schicken wollte. Die
  Kollision wäre also nicht vermieden, sondern nur verlegt worden.

*(Die Runde-3-Fassung behauptete, die Erfassung löse das „durch Konstruktion", indem sie das
Guard-Ereignis meidet. Das war eine zu weite Reichweiten-Aussage über einen real vorhandenen
Mechanismus — vom Proposed-Review am eigenen Repo widerlegt.)*

**Die Konstruktion sitzt deshalb nicht bei der Ereignis-Wahl, sondern beim Emitter selbst: er
wird auf dem Entscheidungs-Kanal sprech-unfähig gemacht.** Zwei Setzungen, beide prüfbar:

1. **Der Emitter gibt auf stdout nichts aus** — sein Ausgabekanal ist die Span-Datei. Auch keine
   Diagnose: was er mitteilen will, schreibt er in seinen eigenen Strom.
2. **Sein Exit-Code ist hart auf 0 geklemmt**, unabhängig davon, was intern geschieht. Das ist
   kein Formalismus: `awk` beendet sich bei einem fatalen Fehler mit **Exit 2** — genau dem Wert,
   mit dem ein Hook blockiert. Ohne Klemme leckte ein Skript-Fehler in den Entscheidungs-Kanal
   und legte den Lauf still, den die Telemetrie nur beobachten soll.

So ist die Trennung wieder **konstruktiv** — sie hängt nicht daran, welches Ereignis gewählt
wird, sondern daran, dass der Emitter auf diesem Kanal gar nicht erst sprechen **kann**. Und sie
ist testbar: ein absichtlich fehlschlagender Emitter muss Exit 0 liefern und stdout leer lassen.

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
| **C — lokale Span-Erfassung mit Policy, Werkzeug offen (gewählt)** | nutzt die **bereits verdrahtete** Hook-Mechanik; nichts zu installieren; die Sicherheitsfrage ist vorab entschieden statt nachträglich gehärtet; die Werkzeug-Wahl bleibt der Messung überlassen | die Auswertung ist Eigenbau (kein Ökosystem); **C erzeugt die Sicherheitsfläche, die A und E gar nicht erst haben** — jede Erweiterung der Allowlist ist eine Einzelfall-Abwägung, und diese Pflege endet nie; die Abdeckung hängt an dem, was das Werkzeug an Ereignissen hergibt |
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
- **Folgepflicht 4 — der Verlust wird beim LESER sichtbar, nicht beim Schreiber.** Fail-open
  heißt „der Lauf geht weiter", nicht „niemand erfährt davon" — sonst entsteht ein Log, das
  lückenhaft ist und vollständig aussieht. Ein vom eigenen Timeout abgebrochener Emitter kann
  seinen Ausfall aber **nicht selbst melden**; eine Sichtbarkeit, die von ihm abhinge, wäre
  genau die Zusage ohne Abdeckung, gegen die [`AGENTS.md`](../../../AGENTS.md) §3.6 steht
  (Proposed-Review Runde 2). Die Setzung ist deshalb: **jeder Span trägt eine je Sitzung monoton
  steigende Folgenummer**, sodass eine Lücke **im Bestand** erkennbar ist — von dem, der ihn
  liest, ohne Zutun dessen, der ihn schreibt. **Die Nummer wird als Erstes vergeben**, vor jeder
  anderen Arbeit des Emitters; stirbt er danach, fehlt der Eintrag und die Lücke ist sichtbar.
  **Ehrlich zur Grenze** (Runde 3): stirbt er *davor*, wurde nie eine Nummer vergeben — dann
  entsteht keine Lücke, und dieser Fall bleibt unsichtbar. Er ist damit **nicht** gedeckt, und
  das steht hier, statt die Folgenummer als Vollschutz auszugeben. Der zugehörige Zahn steht
  unten in der Fitness Function; ohne ihn wäre auch diese Folgepflicht nur eine Absicht.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `test/mutations/` | Ein Span **ohne Pflicht-Feld** färbt seinen Wächter rot | `make mutate` |
| `test/mutations/` | Ein Feld, das **nicht** auf der Allowlist steht, wird nicht durchgelassen — die Mutation setzt ein neues Feld ein und muss rot werden | `make mutate` |
| `test/mutations/` | **Der Ablageort wird auf einen nicht-ignorierten Pfad gezogen** — der Wächter muss rot werden | `make mutate` |
| `test/mutations/` | **Ein Span wird unterschlagen** (der Emitter überspringt einen Aufruf) — die Lücke in der Folgenummer muss auffallen; ohne diesen Fall wäre Folgepflicht 4 eine Absicht | `make mutate` |
| bats (`make test`) | Der Emitter setzt den restriktiven Modus **selbst**: die erzeugte Datei ist `0600`, unabhängig von den Rechten des Verzeichnisses | `make test` |
| bats (`make test`) | **Fail-open, soweit hier prüfbar:** ein Emitter mit Exit ≠ 0 und einer, der auf stdout schreibt, verändern das Ergebnis des aufrufenden Skripts nicht. **Die Wirkung im Werkzeug** (blockt ein Exit-Code den Tool-Call? was tut sein Timeout?) prüft dieser Sensor **nicht** — sie gehört zur Messung im Slice und ist dort zu belegen, nicht hier zu behaupten | `make test` |

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
- **Wenn Spans emittiert werden sollen** (slice-062) *(feedforward — ein CR ist ein menschlicher Vorgang, kein Sensor)*:
  Festlegung 5 wird dort eingelöst, und die Portabilität von 1–4 und 6 ist am realen Ziel zu
  **belegen**, nicht zu behaupten.
- **Wenn dieses Repo selbst Agentenläufe betreibt** (statt in einem fremden Werkzeug zu laufen)
  *(feedforward — kein Sensor)* — dann kippt die Annahme „Audit, kein Betriebs-Monitoring", und
  Option B ist neu zu bewerten.
- **Wenn die Erfassung den Lauf bremst** *(feedforward, bis ein Slice den Sensor baut)*:
  **Schwelle hier festgelegt statt an den Slice delegiert** — überschreitet der Aufschlag je
  Tool-Call **50 ms im Median**, ist nicht die Grenze zu erhöhen, sondern der Umfang zu senken.
  Die Zahl ist eine Setzung, keine Messung: sie liegt unter der Wahrnehmungsschwelle eines
  interaktiven Laufs und weit unter dem Timeout aus Festlegung 6. Wer sie ändert, ändert sie
  **hier** — nicht im Skript.
- **Wenn die Allowlist nach dem ersten Auswertungs-Slice (060) immer noch leer ist**
  *(feedforward — aber an ein Ereignis geknüpft, nicht an ein Gefühl)*: dann erfasst das Audit
  nur IDs und ist faktisch Alternative E. Das ist **kein Fehler**, aber der Anlass, die Wahl
  zwischen C und E ausdrücklich zu wiederholen, statt sie durch Nichtstun zu treffen.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-07-28 | Proposed | welle-09 §4 / slice-059 §6 (der Plan-Review vom 2026-07-28 verlangte die Entscheidung **vor** dem Slice) — auf die Slice-**ID** verwiesen, nicht auf den Pfad: der wandert durch die Lifecycle-Ordner |
| 2026-07-28 | Überarbeitet (Runde 4), weiter **Proposed** | Proposed-Review Runde 3 `docs/reviews/2026-07-28-adr-0011-proposed-review-runde-3.md` (**1 HIGH**, von 3 — Konvergenz messbar: HIGH 2 → 3 → 1). **R3-1, blockierend:** die Zusage, die fail-open/fail-closed-Kollision *durch Ereignis-Wahl* zu lösen, hielt nicht — es gibt **kein entscheidungsfreies Ereignis** (auch die Nach-Ereignisse nehmen ein `decision` entgegen, `Stop`/`SubagentStop` sind blockierbar), und dieses Repo betreibt auf `Stop` bereits einen **zweiten fail-closed Hook**, ausgerechnet auf einer der benannten Lauf-Grenzen. Festlegung 6 verlagert die Konstruktion deshalb an den **Emitter**: kein stdout, Exit-Code hart auf 0 geklemmt (gemessen: `awk` endet bei fatalem Fehler mit Exit 2 — genau dem blockierenden Wert). **Nutzer-Einwand im selben Zug, unabhängig vom Review:** die Allowlist war ein Sicherheits-Instrument ohne benannten Gegner. Festlegung 2 ist ersetzt durch **abgeleitete** Argument-Werte (Pfad + Fingerabdruck statt Inhalt, Programm-Token statt Kommandozeile) mit **benanntem Bedrohungsmodell** und **ebenen-abhängiger** Schärfe; die Warnung vor Pfaden ist ersatzlos gestrichen (sie verrieten niemandem etwas, der nicht ohnehin Lesezugriff hat — gemessen). Damit **entfällt die Abweichung vom Modul-15-Mindestsatz**: `tool.arguments` wird erfasst. Festlegung 1 bekommt die Regel **Ableiten schlägt deklarieren** (`requirement.id` ist aus der Slice-`Bezug:`-Zeile ableitbar — gemessen); offen bleibt genau der Cache-Status. Dazu: Folgenummer-Vergabezeitpunkt samt **ehrlich benannter Lücke** (stirbt der Emitter vor der Vergabe, entsteht keine), Aufräumen ohne fremde Sitzungen zu treffen, `sed`/`grep` in der Erlaubt-Liste samt Eigenschafts-Kriterium statt Aufzählung, Container-Start-pro-Aufruf als Grenze benannt, `ADR-0004` als Quelle auf die Bauart eingegrenzt, welle-09 nachgezogen |
| 2026-07-28 | Überarbeitet (Runde 3), weiter **Proposed** | Proposed-Review Runde 2 `docs/reviews/2026-07-28-adr-0011-proposed-review-runde-2.md` (3 HIGH, 8 MEDIUM, 3 LOW/INFO — **alle drei HIGH von der Runde-2-Fassung selbst erzeugt**, dasselbe Muster wie ADR-0007). **R2-1/R2-10** — die verschärfte Randbedingung war *zu weit*: wörtlich hätte „keine Host-Sprachlaufzeit" die 16 eigenen Host-Skripte, den Guard und den Stop-Hook getroffen, und die Repo-Bindung war aus der **falschen Klausel** abgeleitet (die Bootstrap-Klausel meint ausweislich ihrer Messmethode die *Nutzer*-Laufzeit). Festlegung 4 zieht die Grenze jetzt zwischen **vorhanden** (POSIX-Basis, die Linie aus [ADR-0004](0004-durchsetzungs-emission.md)) und **zu installieren**. **R2-2** — fail-open und fail-closed teilten sich das Entscheidungs-Event; Hooks laufen parallel, und bei Exit 0 ist die Ausgabe ein Entscheidungs-Kanal. Festlegung 6 löst die Kollision jetzt **durch Konstruktion**: die Erfassung meidet das Guard-Event und schreibt nichts auf stdout. **R2-3** — Folgepflicht 4 hing an einem Emitter, der seinen eigenen Timeout-Tod nicht melden kann: jetzt **Folgenummern**, deren Lücke der *Leser* sieht, samt eigenem Mutations-Fall. Dazu: Aufräum-Regel beim Anlegen (statt eines Zeitpunkts, der bei Absturz ausfällt), die leere Allowlist als **erklärte** Abweichung vom Modul-15-Mindestsatz, Quadranten-Korrektur (zwei Trigger waren fälschlich *feedback*), eine **hier** festgelegte Latenz-Schwelle statt eines Verweises auf den Slice, Cs Contra-Spalte um die Sicherheitsfläche ergänzt, Index und slice-059 nachgezogen |
| 2026-07-28 | Überarbeitet (Runde 2), weiter **Proposed** | Proposed-Review `docs/reviews/2026-07-28-adr-0011-proposed-review.md` (2 HIGH, 6 MEDIUM, 3 LOW, nicht annehmbar). **H-1** — eine Fitness Function, die unter keiner Mutation rot werden konnte (`--exclude-standard` schließt gitignorierte Pfade unbedingt aus, die Zusage war per Konstruktion wahr): gestrichen und durch den Fall ersetzt, der die Eigenschaft wirklich bewacht. **H-2** — Hook-Fehlschlag und Timeout waren nirgends entschieden, obwohl der Mechanismus an jedem Tool-Call hängt: neue **Festlegung 6** (Telemetrie fail-**open**, Guard bleibt fail-closed) samt verworfener Gegen-Entscheidung. **M** — [`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten) war falsch zitiert und auf das Ziel verengt (Festlegung 4 korrigiert, Randbedingung dadurch **schärfer**: keine Host-Sprachlaufzeit); Festlegung 1 war Wiedergabe statt Entscheidung (jetzt Schema-**Policy** mit leerer Start-Allowlist); Aufbewahrung, Dateimodus und Leserechte fehlten (Festlegung 3); Festlegung 5 war „portabel gemeint" statt bindend (jetzt: das **Ob** entscheidet der CR, das **Wie** diese ADR); Alternative **E** (Korrelations-Hook ohne Payload) ergänzt — sie ist der Grenzfall von C und durch die leere Start-Allowlist zugleich dessen Startzustand; Re-Evaluierungs-Trigger mit Schwellen und ehrlicher Quadranten-Kennzeichnung |
