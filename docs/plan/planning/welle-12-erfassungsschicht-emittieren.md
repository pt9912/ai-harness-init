# Welle welle-12: Die Erfassungsschicht geht ins Ziel — der Adopter bekommt den Beleg seiner Läufe

**Lifecycle:** Die aktive Welle liegt flach unter `docs/plan/planning/`; bei
Closure wandert diese Datei per `git mv` nach `done/` (neben ihre
`welle-12-results.md`). Der Zustand ist die Verzeichnis-Position — kein
Status-Feld. Ob eine flache Welle *aktuell* oder *geplant* ist, sagt die Roadmap.

**Zielmeilenstein:** M6 — *die emittierte Ebene belegt ihre eigenen Läufe*. Dieser Meilenstein
existiert bisher nicht; er entsteht mit dieser Welle und ist der erste seit M5, der eine
**Nutzer-Fähigkeit des Werkzeugs** trägt statt eine Konformität des Dogfoods.

**Verantwortlich:** Planner. **Datum:** 2026-08-25.

---

## 1. Welle-Ziel

**Ein frisch gebootstrapptes Zielrepo schreibt je Werkzeug-Aufruf seiner Agenten-Läufe einen Span
mit besetzter Rollen-Achse, sagt in einer lesbaren Feldliste, was es erfasst und was es
ausdrücklich nicht zusagt, und gibt dem Adopter einen Leser samt Aufräum-Kommando — oder es legt
begründet nichts davon ab und bleibt out-of-the-box grün.**

Der Gegenstand ist
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) (Lastenheft
0.19.0, **Rang 1** der Source Precedence), der Weg ist
[`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) (*Accepted*): der
Träger ist das laufende Produkt-Binär, kopiert in den gitignorierten Zustands-Bereich des Ziels;
Schreiber und Auswertung sind seine Unterkommandos, die Rollen-Typen gehen generisch mit. Die
Entscheidung ist **Constraint, nicht Verhandlungsmasse**
([`AGENTS.md`](../../../AGENTS.md) §3.4) — diese Welle setzt sie um und stellt sie nicht neu.

**Der Satz oben trägt seinen eigenen Oder-Zweig, und das ist keine Nachlässigkeit.** Der
Fehlerfall — die Platzierung des Trägers scheitert — ist kein Rand, sondern die Zusage aus
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6): dann wird
**nichts** abgelegt, kein Hook zeigt auf ein fehlendes Programm, und der Bootstrap endet
erfolgreich ([`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Festlegung 5(a)). Eine Welle, die nur den Gelingens-Zweig beschriebe, ließe die Hälfte des
Vertrags unbewacht.

### Die Abdeckungs-Menge: die Akzeptanzkriterien der Anforderung, aufgezählt vor ihrer Zahl

Die Eigenschaft, über die gezählt wird: **eine Listenzeile, die im Abschnitt von
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) mit `- **`
beginnt** — also ein benanntes Akzeptanzkriterium, nicht ein Beschreibungs-Absatz. Kommando:
`sed -n '/^### .* — Erfassungsschicht emittieren$/,/^## 4\./p' spec/lastenheft.md | grep -c '^- \*\*'` → **10**; die Zahl
wandert mit dem Lastenheft und ist **kein** Erwartungswert
([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Jedes Kriterium hat in dieser Welle genau einen zuständigen Slice; keines bleibt ohne:

| Akzeptanzkriterium | zuständig | Art der Erfüllung |
|---|---|---|
| Happy Path — Span-Zeile mit voller Pflicht-Spalte | [slice-096](in-progress/slice-096-traeger-liegt-im-ziel.md) | gebaut und im `full-smoke` gesehen |
| Rolle besetzt | [slice-097](open/slice-097-rollen-typen-gehen-mit.md) | gebaut (der Typ ist der Träger der Achse) |
| Betrieb fail-open, Umfang fail-closed | [slice-094](done/slice-094-ein-programm-ein-einstiegspunkt.md) | **konstruktiv geerbt** — dasselbe Programm, dieselbe Klemme; die Zähne wandern auf den neuen Einstiegspunkt |
| Redaktion — was zugesagt ist und was nicht | [slice-098](open/slice-098-feldliste-ist-ausdruck-des-traegers.md) | gebaut (die Feldliste **ist** die geschlossene Liste, die das Kriterium verlangt) |
| Aufbewahrung — Kommando ohne Automatik | [slice-099](open/slice-099-leser-und-aufraeum-kommando.md) | gebaut |
| Leser — Abdeckung zuerst, Leere gemeldet | [slice-099](open/slice-099-leser-und-aufraeum-kommando.md) | gebaut |
| Reproduzierbar ([`LH-QA-02`](../../../spec/lastenheft.md#lh-qa-02--reproduzierbarkeit)) | [slice-096](in-progress/slice-096-traeger-liegt-im-ziel.md) | **konstruktiv** — eine Kopie ist bei gleicher Tool-Version dieselbe Datei; keine Zusicherung, die jemand herstellen muss |
| Minimal/netzlos ([`LH-QA-03`](../../../spec/lastenheft.md#lh-qa-03--minimale-abhängigkeiten)) | [slice-096](in-progress/slice-096-traeger-liegt-im-ziel.md) | **konstruktiv** — kein Netz, kein Bauschritt, kein zweiter Kanal |
| Kein Halluzinat ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)) | [slice-096](in-progress/slice-096-traeger-liegt-im-ziel.md) | gebaut, mit **rot gesehenem Gegenbeispiel** |
| Benannte Grenze — kein Wächter über die Aufrufform | [slice-098](open/slice-098-feldliste-ist-ausdruck-des-traegers.md) | **ausgesprochen**, nicht bewacht — die Grenze steht stehend im Feldlisten-Dokument |

**Zwei Zeilen tragen *konstruktiv geerbt* und eine *ausgesprochen* — das ist eine Aussage über die
Beweislast, keine Ausrede.** Ein konstruktiv geerbtes Kriterium hat keinen eigenen neuen Wächter,
weil es keine neue Zusage ist: dasselbe Programm, das hier seit
[`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) fail-open geklemmt läuft, läuft im Ziel.
Was dabei **wandert**, ist der Einstiegspunkt — und genau der bekommt seinen Zahn
([slice-094](done/slice-094-ein-programm-ein-einstiegspunkt.md) DoD 2). Die *ausgesprochene*
Grenze ist die, die
[`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) §Benannte Grenze
selbst als unbewachbar führt; ein Wächter dafür wäre einer über einem fremden Vertrag.

## 2. Trigger (Welle startet)

Beide Bedingungen sind **beobachtbar und heute erfüllt**; die Welle ist damit startbar.

- **[`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) liegt *Accepted*
  vor.** Ohne Rückfrage prüfbar:
  `grep -m1 '^\*\*Status:\*\*' docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`
  → `**Status:** Accepted`. Tragend, weil die Entscheidung den **Weg** festlegt, den
  [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) ausdrücklich
  offen lässt (*„Der Weg der Emission ist nicht Gegenstand dieser Anforderung"*) — ohne sie hätte
  jeder Slice dieser Welle eine offene Architektur-Frage im Rücken.
- **[slice-093](done/slice-093-mutations-treiber-erreicht-full-smoke.md) liegt in `done/`.** Ohne Rückfrage prüfbar: die Plan-Datei liegt neben den übrigen
  geschlossenen Slices. **Tragend, nicht ordnend:** zwei Fitness-Zeilen der Entscheidung hängen
  ausschließlich an `make full-smoke`, und der Mutations-Treiber führt diesen Modus erst seit
  jenem Slice — `sed -n '/^failure_form()/,/^}/p' harness/tools/mutate.sh | grep -cE '^[[:space:]]+[a-z*-]+\)'`
  → **7** Arme (mitwandernd). Vorher wäre der Fall solcher Zeilen **ungelistet**, und ungelistet
  heißt nach [`AGENTS.md`](../../../AGENTS.md) §3.6 unbewacht.

**Was ausdrücklich *nicht* Trigger ist, und warum — gemessen statt vermutet.** Diese Welle hängt an
**keiner** der drei Wellen in der Reihe
[welle-09](welle-09-modul-15-konformitaet.md) → [welle-10](welle-10-re-baseline.md) →
[welle-11](welle-11-traeger-aussage.md):

- **[welle-10](welle-10-re-baseline.md) (Re-Baseline) nicht**, weil die Entscheidung die beiden
  Modul-15-Ergänzungen der kommenden Regelwerks-Fassung **vorweggenommen statt abgewartet** hat —
  sie stehen in ihrem Kontext-Abschnitt, gegen den Regelwerks-Spiegel des Tags gelesen. Eine Welle,
  die auf einen Tausch wartet, dessen Ergebnis die tragende Entscheidung schon kennt, wartet ohne
  Gegenstand.
- **[welle-11](welle-11-traeger-aussage.md) nicht**, weil ihr Nachzug aus
  [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 5
  bereits vollzogen ist:
  `grep -niE 'permanent nicht emittiert|solange er offen ist' docs/plan/planning/welle-11-traeger-aussage.md | wc -l`
  → **0** (mitwandernd, kein Erwartungswert). Die Richtung ist zudem asymmetrisch: läuft welle-12
  zuerst, tragen die vier Zellen von `slice-092` gleich ihren Endwert statt ihres
  Auflösungs-Triggers — jener Slice hat sich **ausdrücklich** dagegen entschieden, auf diese Welle
  zu warten, und bleibt in beiden Reihenfolgen richtig.
- **[welle-09](welle-09-modul-15-konformitaet.md) nicht.** Der `targets:`-Satz, in den ein neues
  Init-invariantes Fragment nach
  [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 4
  gehörte, existiert heute nicht — `grep -c 'targets' .d-check.yml` → **0** (mitwandernd). Es gibt
  also nichts, dem etwas hinzuzufügen wäre; und die Richtung ist ohnehin verträglich, weil dieselbe
  Festlegung sagt, ein emittierter Doku-Tisch **dürfe** die neuen Ziele nennen — sie sind
  Init-invariant. Was bleibt, ist eine Schuld an die spätere Welle, und sie steht in §5.

## 3. Closure-Trigger (Welle schließt)

**Das gemeinsame Kriterium:** *An einem frisch gebootstrappten Ziel — sprachlos **und** mit
`--lang go` — ist jedes der zehn Akzeptanzkriterien aus §1 wahr oder als ausgesprochene Grenze
lesbar, und der Fehlerzweig ist genauso belegt wie der Gelingens-Zweig.* Es wird erst wahr, wenn
alle sechs Slices liegen: keiner von ihnen erfüllt mehr als drei der zehn Zeilen, und drei Zeilen
(Rolle besetzt · Redaktion · Leser) hängen an Artefakten aus verschiedenen Slices.

- **Alle sechs Slices dieser Welle in `done/`.**
- **Beide Zweige belegt, nicht nur der erste.** (a) Der Gelingens-Zweig im `full-smoke` über beide
  Bootstrap-Varianten; (b) der Zweig aus
  [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(a) mit
  seinem **rot gesehenen** Gegenbeispiel — die Kopplung aufheben, den Hook-Eintrag unbedingt
  schreiben, dann muss der Wächter fallen. Nur (a) wäre die
  [`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Falle mit
  umgekehrtem Vorzeichen ([`AGENTS.md`](../../../AGENTS.md) §3.6).
- **Das frische Ziel ist out-of-the-box grün — in beiden Zweigen.** `make gates` im
  gebootstrappten Ziel, mit Träger und ohne. Das ist die Schranke, an der ein ziel-seitiger
  Anwesenheits-Wächter scheitert (§6) und an der die emittierten Rollen-Typen ihre
  Doku-Gate-Sicherheit beweisen.
- **`make gates` grün · `make full-smoke` grün · `make mutate` grün** einschließlich jedes in
  dieser Welle neu angelegten Falls. Jeder neue Wächter hat seinen `test/mutations/`-Fall; wer
  allein an `make full-smoke` hängt, bekommt einen mit `# verify: full-smoke` (§2).
- **Der Trennungs-Trigger der Entscheidung ist scharf.** Die Messung aus
  [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 9
  liegt vor ([slice-095](done/slice-095-hook-aufschlag-gemessen.md)), mit ihrem Kommando im Text.
  Ohne sie feuert der Re-Evaluierungs-Trigger zu Annahme (c) nie — eine Welle, die den Träger
  ablegt und seinen Preis ungemessen lässt, schließt über einer offenen Annahme.
- **Carveout-Audit (Modul 7)** über den Bestand in `docs/plan/carveouts/` — gelesen wird der
  `Status:`-Kopf, nicht das Verzeichnis (`grep -n '^\*\*Status:' docs/plan/carveouts/CO-*.md`).
- **Closure-Notiz `welle-12-results.md`** mit Steering-Loop-Eintrag.

## 4. Slices in dieser Welle

Der Zustand jedes Slice ist sein Lifecycle-Verzeichnis, hier nicht gespiegelt.

| Slice | Titel | Bezug |
|---|---|---|
| [slice-094](done/slice-094-ein-programm-ein-einstiegspunkt.md) | Ein Programm, ein Einstiegspunkt: Schreiber und Auswertung werden Unterkommandos | [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 2 |
| [slice-095](done/slice-095-hook-aufschlag-gemessen.md) | Der Aufschlag je Tool-Call ist gemessen, und der Trennungs-Trigger kann feuern | [`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) |
| [slice-096](in-progress/slice-096-traeger-liegt-im-ziel.md) | Der Träger liegt im Ziel — oder es liegt begründet nichts | [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| [slice-097](open/slice-097-rollen-typen-gehen-mit.md) | Die Rollen-Typen gehen mit: generisch, Tool-als-Quelle, `skip-if-present` | [`LH-FA-08`](../../../spec/lastenheft.md#lh-fa-08--agenten-workflow-commands-emittieren) |
| [slice-098](open/slice-098-feldliste-ist-ausdruck-des-traegers.md) | Die Feldliste im Ziel ist der Ausdruck des Trägers und führt ihre Grenzen stehend | [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |
| [slice-099](open/slice-099-leser-und-aufraeum-kommando.md) | Der Leser nennt seine Abdeckung zuerst, und der Bestand hat ein Aufräum-Kommando | [`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) |

**Zuerst läuft [slice-094](done/slice-094-ein-programm-ein-einstiegspunkt.md), und der Grund steht
in der Entscheidung selbst.** Ihre Folgepflicht 1 bindet die Emission an den Dogfood: *„ohne diesen
Nachzug emittierte der Beleg einen Einstiegspunkt, den der Dogfood nie ausführt"*. Der
Einstiegspunkt trägt genau die zwei Eigenschaften, die
[`ADR-0011`](../adr/0011-telemetrie-erfassung-policy.md) Festlegung 6 nicht verhandelbar nennt —
Exit-Code hart auf 0, stdout leer —, und ein unerprobter Einstiegspunkt ist die Stelle, an der eine
fail-open-Zusage **still** bricht. Was danach ins Ziel geht, ist hier gefahren.

**Danach [slice-095](done/slice-095-hook-aufschlag-gemessen.md), und diese Stelle ist eine
Entscheidung, keine Reihenfolge-Bequemlichkeit.** Der Aufschlag ist erst messbar, wenn der Hook
dieses Repos das Produkt-Binär ruft — das tut er nach 094. Und er ist **vor** 096 zu messen, weil
sein negativer Ausgang nach
[`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) §Konsequenzen
Alternative F herbeiführt: einen **anderen** Träger. Nach der Emission gemessen wäre dieselbe Zahl
ein Abriss-Trigger statt einer Konstruktions-Eingabe.

**[slice-097](open/slice-097-rollen-typen-gehen-mit.md) hängt an nichts und ist einzeln nützlich.**
Die Rollen-Typen sind nicht bloß der Füllstoff für `agent.role`: die emittierten
Workflow-Commands fahren die Rollen-Sequenz im Ziel bereits, *„was fehlt, ist der **Typ**, unter
dem eine Rolle startbar ist"*. Ein Ziel mit Typen und ohne Träger kann seine Rollen starten; ein
Ziel mit Träger und ohne Typen führt eine Achse, die dauerhaft leer bleibt. Der Slice darf darum
jederzeit laufen — auch parallel zu 094/095.

**[slice-098](open/slice-098-feldliste-ist-ausdruck-des-traegers.md) und
[slice-099](open/slice-099-leser-und-aufraeum-kommando.md) warten auf 096, und der Trigger ist
benannt.** 098 wird **aus** dem Träger erzeugt und teilt seinen Emissions-Zweig; 099 legt ein
Fragment ab, das auf den Träger zeigt. Beide vor 096 gebaut ergäben ein Dokument ohne Quelle und
ein Fragment ohne Ziel — die
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)-Klasse. Die
beiden hängen **nicht** aneinander: 098 ist ein stehendes Dokument an `make test` · `make mutate`,
099 ein laufender Leser an `make full-smoke`. Genau diese Asymmetrie ist der Grund, warum die
Entscheidung die Grenze aus
[`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) Folgepflicht 6 an **zwei** Orte
schreibt und nicht an einen.

**Warum sechs Slices und nicht einer, und warum nicht drei.** Modul 5 §Ziel-Form setzt **≤ 3
DoD-Punkte**, höchstens zwei Schichten und Prüfbarkeit in *einer* Review-Sitzung. Die Eigenschaft,
an der hier geschnitten wird, ist der **Liefergegenstand**, nicht die Schicht: ein Programm mit
einem Einstiegspunkt (094) · eine Zahl gegen eine Schwelle (095) · ein abgelegtes Binär samt
Wrapper und Hook-Eintrag (096) · ein Satz Textdateien (097) · ein erzeugtes Dokument (098) · ein
Leser mit einem Aufräum-Kommando (099). Die Eigenschaft, über die gezählt wird: **eine Listenzeile
in §2 eines dieser Pläne, die mit `- [ ] **(` beginnt** — also ein slice-eigener DoD-Punkt, nicht
eine Standard-Zeile der Vorlage. Kommando:
`grep -h '^- \[ \] \*\*(' docs/plan/planning/open/slice-09[4-9]*.md | wc -l` → **17**
(mitwandernd, kein Erwartungswert
— [`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). In **einem** Slice wären das mehr als das Fünffache dessen, was Modul 5 einem Schnitt
zugesteht. Ein Schnitt nach Schichten
(*…-emit*, *…-test*, *…-doku*) erzeugte dagegen genau die einzeln nutzlosen Zombie-Slices, vor
denen dieselbe Stelle warnt.

## 5. Abhängigkeiten

- **Wird blockiert von:** keiner Welle. Beide Trigger sind erfüllt (§2), und keine der drei Wellen
  in der Reihe liefert etwas, das eine Festlegung dieser Entscheidung braucht — gemessen, nicht
  vermutet (§2).
- **Blockiert:** keine geplante Welle. Sie liegt **neben** der Reihe
  [welle-09](welle-09-modul-15-konformitaet.md) → [welle-10](welle-10-re-baseline.md) →
  [welle-11](welle-11-traeger-aussage.md), nicht hinter ihr; welche der beiden startbaren Wellen
  zuerst läuft, sagt die Roadmap als Sequenzierungs-Autorität.
- **Innerhalb der Welle:** 094 → 095 → 096 → {098, 099}; 097 ohne Vorbedingung.
- **Eine Berührung mit [welle-11](welle-11-traeger-aussage.md), in beide Richtungen tragbar.**
  `slice-092` baut einen Wächter, der rot wird, sobald eines von drei Emit-Präfixen wächst, während
  seine Inventur-Zelle noch Abwesenheit behauptet. Läuft welle-12 **zuerst**, entsteht der Wächter
  über einem Bestand, der die Träger schon führt, und die vier Zellen tragen gleich ihren Endwert.
  Läuft welle-11 zuerst, färbt derselbe Wächter bei 096, 097 und 099 rot — **gewollt**: er zwingt
  den Blick auf die Inventur. Keine Reihenfolge bricht etwas; beide kosten eine bewusste Zeile.
- **Eine Schuld an [welle-09](welle-09-modul-15-konformitaet.md), hier benannt statt später
  entdeckt.** Diese Welle legt ein **Init-invariantes** Gate-Fragment und neue emittierte
  `make`-Ziele ab ([slice-099](open/slice-099-leser-und-aufraeum-kommando.md)). Nach
  [`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 4
  gehören sie in den `targets:`-Satz aus
  [`ADR-0020`](../adr/0020-emittierte-modul-15-regeln.md) Festlegung 4 — **nach dem Kriterium, nicht
  nach der abgeschriebenen Namensliste**. Der Satz existiert heute nicht
  (`grep -c 'targets' .d-check.yml` → **0**, mitwandernd); wer ihn baut, wendet das Kriterium auf
  den dann vorliegenden Bestand an und findet die neuen Ziele von selbst. Diese Welle schuldet
  dafür nichts als diesen Satz.
- **Kein Change Request.** Der emittierte Datei-Satz **wächst** hier — aber die Anforderung, die
  ihn wachsen lässt, ist bereits angenommen
  ([`LH-FA-10`](../../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren), Lastenheft
  0.19.0), und die Aufzählung aus
  [`LH-FA-06`](../../../spec/lastenheft.md#lh-fa-06--durchsetzungsschicht-emittieren) wächst
  ausdrücklich **nicht**
  ([`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) §Konsequenzen).
  [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
  ist damit eingelöst, nicht umgangen.

## 6. Out-of-Scope für diese Welle

Die Entscheidung führt Grenzen, die sie **ausdrücklich nicht schließt**. Sie stehen hier, damit
kein Slice sie versehentlich mitschneidet und kein Review sie als Lücke meldet.

- **Ein ziel-seitiger Wächter über der Anwesenheit des Trägers.** Ausgeschlossen, nicht vergessen:
  der Träger liegt gitignored, ein **frischer Klon des Adopter-Repos hat ihn nicht**, und ein
  solcher Wächter machte jeden Klon out-of-the-box rot — er bräche
  [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen)
  ([`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 5(c)).
  Wiederhergestellt wird der Träger durch einen erneuten Tool-Lauf. **Der Preis ist ausgesprochen:**
  ein Ziel kann still nichts erfassen; sichtbar wird das beim **Leser**, nicht beim Schreiber.
- **Der `span-check`-Wächter dieses Repos geht nicht mit.** Hier heilt ihn ein Bau, im Ziel könnte
  ihn nichts heilen.
- **Eine Verdrahtung der Auswertung im Ziel.** Sie prüft nichts und färbt nichts rot; ein Gate über
  ihr wäre eines über leerem Prüfbereich
  ([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Das
  Ziel bekommt das **Kommando**, nicht die Aufhängung.
- **Eine automatische Rotation über dem Bestand.** Ausdrücklich keine Zusage: *„ein Löschpfad in
  einem fail-open-Hook über fremden Daten wäre der teurere Fehlerfall"*.
- **Eine Token-Bilanz im Ziel.** Emittiert wird der **Leser**, nicht die **Zahl**. Das Zähler-Glied
  bleibt verschlossen; sein Grund liegt in der Mechanik des Agenten-Werkzeugs und wird aus
  [`ADR-0021`](../adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) **nicht** revidiert.
- **Ein Wächter über die Aufrufform des Agenten-Werkzeugs oder über die Rollennamen des Adopters.**
  Benennt ein Adopter seine Typen um, bleibt `agent.role` leer — und leer heißt *unbekannt*, nie
  *rollenlos*. Die Grenze wird gesagt, nicht bewacht.
- **Die Kopie der sechs Rollen-Typ-Dateien dieses Repos.** Sie tragen dessen Slices, Konventionen
  und Befunde; emittiert wird eine generische Fassung
  ([`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Festlegung 3).
- **Alternative H und jede Plattform-Angabe am Bootstrap.** Sie wird erst fällig, wenn Annahme (a)
  fällt — Bootstrap-Host und Hook-Plattform fallen auseinander. Bis dahin ist sie eine neue
  Eingabe, die [`LH-FA-01`](../../../spec/lastenheft.md#lh-fa-01--repo-bootstrappen) in keinem
  seiner Akzeptanzkriterien kennt.
- **Eine Reparatur oder Ergänzung im vendored Baum.** Er ist auf beiden Ebenen byte-verifiziert;
  wer dort schriebe, färbte `make baseline-verify` rot.
- **Der Nachzug des Wellen-Plans der Träger-Aussage**
  ([`ADR-0022`](../adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md) Folgepflicht 5).
  Er ist bereits vollzogen (§2, mit Kommando) und war ohnehin Plan-Arbeit jener Welle.
- **Zeitdokumente** unter `docs/reviews/**` und `docs/plan/planning/done/**` — sie halten den Stand
  ihres Laufs fest und werden nicht nachgezogen
  ([`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  §Geltungsbereich).

## 7. Closure-Notiz

<!-- Erst nach Welle-Abschluss füllen. Verweis auf welle-12-results.md. -->
