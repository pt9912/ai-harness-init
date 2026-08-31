# ADR-0029: `.claude/agents/*.md` ist ein derivatives Register mit gemischten Originalen

**Status:** Proposed

**Datum:** 2026-08-31

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:**
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) (deren Festlegung 2
diese Frage für ein anderes Artefakt ausdrücklich offen lässt und deren Re-Evaluierungs-Trigger sie
hier fällig stellt), [ADR-0025](0025-register-mit-gemischten-originalen.md) (dieselbe Bewegung —
Ableitung je Aussage statt je Datei — an einem anderen Register, `Proposed`; diese ADR hängt nicht
an ihrer Annahme, siehe §Kontext), [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
(die Nachbarfrage für `.claude/commands/*.md`, deren Festlegung 3 `.claude/agents/*.md` ausdrücklich
ausnimmt — diese ADR füllt genau die Lücke, ohne die dortige Ableitung zu übernehmen),
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) (die Grenze „Norm-Aussage ohne Original →
Architect", die Festlegung 1 unten anwendet),
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(der Auftraggeber-Pfad, den Festlegung 3 unten als sanktionierte Alternative bestätigt),
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
(jede Zahl unten steht neben dem Kommando, das sie liefert)

**Schärft:** — Prozess-ADR ohne Spec-Stratum.

---

## Kontext

### Der Trigger ist eingetreten, gemessen — und zweimal

[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 2 lässt die
Frage für Register mit **gemischten Originalen** ausdrücklich offen und nennt als
Re-Evaluierungs-Trigger *„der erste Lauf, der [ein solches Register] anfasst"*.
[ADR-0025](0025-register-mit-gemischten-originalen.md) hat diesen Trigger für
`docs/plan/carveouts/README.md` bereits ausgelöst. `.claude/agents/*.md` löst ihn ein zweites Mal
aus — mit einer zusätzlichen Wendung: der jüngste Lauf, der die sechs Dateien geändert hat, benennt
die offene Eigentumsfrage in seiner eigenen Commit-Message:

```sh
git log --format='%H' -- .claude/agents/ | wc -l                                   # 4
git log --format='%s' -- .claude/agents/ | grep -c '^Rolle '                       # 0
for h in $(git log --format='%H' -- .claude/agents/); do
  git show --stat --format= "$h" -- .claude/agents/ | grep -c '\.claude/agents/.*\.md'
done   # 6, 6, 2, 6 — kein einziger Commit berührt nur eine der sechs Dateien
```

**Vier Commits, keiner rollen-präfigiert, keiner mit nur einer Datei.** Der Bestand bestätigt, was
[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Kontext bereits an zwei Fällen
zeigte (Gründungs-Commit `e30e0fd`: sechs Dateien, Cross-Check gegen drei externe Quellen;
Cross-Role-Commit `b39d4ff`: zwei Dateien für eine gemeinsame Struktur-Ergänzung) und erweitert es
um einen dritten und vierten Beleg: `3df35f3` zieht einen Link-Fix über alle sechs Dateien nach
demselben Lifecycle-Move nach; `abe6e3b` (heutiger Stand, `HEAD`) streicht denselben Absatz aus
allen sechs. Seine eigene Botschaft benennt die Lücke, die diese ADR schließt, wörtlich:

> *„Geschrieben auf ausdrückliche Anweisung des Auftraggebers. Wer `.claude/agents/` schreiben
> DARF, sagt weiterhin keine Quelle — ADR-0028 Festlegung 3 nimmt die Klasse ausdrücklich aus, das
> ist `BEO-007`. Ein Architect-Lauf entscheidet die Frage gerade; fällt sein Verdikt gegen den hier
> schreibenden Kontext, ist das ein legitimes Ergebnis und nachträglich zu tragen."*

### Was `abe6e3b` tatsächlich geändert hat — und warum es kein Formfehler war

Der ursprüngliche Auftrag an diesen Lauf war eine reine Anker-Form-Korrektur: die sechs Dateien
zitierten `slice-060` als
`([slice-060](../../docs/plan/planning/done/slice-060-rollen-achse.md))` — ein Verweis in ein
Zeitdokument, das in keinem Rang der Source Precedence steht
([`AGENTS.md`](../../../AGENTS.md) §3.7). Die naheliegende Korrektur — den Anker durch
`· seit slice-060` ersetzen — wäre selbst falsch gewesen: dieser Anker ist für **verkörperte
Regeln** sanktioniert, die aus dem Steering Loop kamen und auf ihr eigenes §7 zurückzeigen
(`modul-06-roadmap.md` §Das Beobachtungs-Register); der gestrichene Satz war keine solche Regel,
sondern die Erzählung einer Design-Entscheidung. `AGENTS.md` §3.7 selbst benennt das
Leser-Modell, das die Erzählung ausschließt: ein Kommentar *„schreibt an den, der die Stelle
ändert, nicht an den, der die Entscheidung trifft"* — der gestrichene Absatz bediente den zweiten
Leser. Was blieb, ist eine Aussage der Klasse **Kopplung**, im Präsens formuliert (der Typname
trägt die Rolle in den Span, `general-purpose` landet im Sammelposten).

**Das ist keine Formkorrektur mehr, sobald man es genau nimmt — es ist eine Anwendung einer
Baseline-Regel (§3.7, deren fünf Kommentar-Klassen) auf eine neue Textstelle, uniform über alle
sechs Dateien.** Genau diese Art Urteil — *ob eine Textstelle eine Baseline-Regel korrekt anwendet*
— ordnet [ADR-0025](0025-register-mit-gemischten-originalen.md) Festlegung 2 dem **Architect** zu
(*„gibt sie eine Baseline-Regel wieder, gehört sie dem Architect — ob eine Abweichung von der
Baseline besteht, ist eine Architektur-Frage"*), und
[ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) hatte diese Zuordnung zuerst für §3.7 selbst
getroffen. `abe6e3b` traf diese Entscheidung außerhalb dieser Rolle — und benennt das selbst.

### Was `.claude/agents/*.md` strukturell sind, gemessen an der Original-Definition

[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1 definiert
*derivativ* als Eigenschaft der Aussage: *„eine Register-Zeile gibt Felder eines Originals wieder,
und das Original muss existieren."* An den sechs Dateien selbst geprüft, Zeile für Zeile:

| Passage (Beispiel) | Original | Existiert |
|---|---|---|
| `description:`-Frontmatter, „Du bist der/die X (Modul Y)…" | Modul 8, Rollenbeschreibung | ja |
| Architects Blockzitat *„ADR-Änderung: Architect schreibt; Reviewer prüft…"* | Modul 8 §Rollen-Regeln, **wörtlich** | ja |
| Verifiers Zitat *„Behauptung ohne Bestätigung ist die häufigste Verifier-Lücke"* | Modul 11 | ja |
| Validators Zitat *„Gefährlichster Fall: Verifikation grün, Validation rot…"* | Modul 8 §Rollen-Regeln | ja |
| „Dein Anweisungssatz steht in `.claude/commands/implement-slice.md`" | dieser Command | ja |
| „Deine Anweisungssätze stehen in `plan-welle.md`/`close-welle.md`" | diese Commands | ja |
| „Dein Anweisungssatz steht in `.harness/skills/reviewer.md`" | dieser Skill | ja |
| Reviewer/Verifier: „Die Report-Datei ist dein Werkstück…" (`b39d4ff`) | kein benanntes Original — neue Norm | — |
| gestrichen (`abe6e3b`): „Warum es diesen Typ gibt… (`slice-060`)" | `slice-060` (war: `done/`) | ja, aber Zeitdokument |

**Jede Zeile bis auf eine projiziert ein existierendes Original — und die Originale sind
verschieden**: Modul 8 (Baseline), sechs unterschiedliche Command-/Skill-Dateien (je einer anderen
Rolle nach [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1
zugeordnet), und — bis heute — ein Slice-Plan. Das ist exakt die Konstellation, die
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 2 als
*gemischte Originale* benennt und unbeantwortet lässt: *„Projiziert ein Register Originale, die
verschiedene schreibende Rollen haben, liefert die Ableitung keine eindeutige Antwort."*

### Warum [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) diese Klasse nicht trifft

[ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Kontext prüft `.claude/agents/*.md`
unter seiner **eigenen** Ableitung — *wer führt den Ablauf aus, den das Artefakt operationalisiert*
— und verwirft sie zu Recht: Die sechs Dateien operationalisieren keinen eigenen Ablauf, sie zeigen
auf ihn. Das ist aber nicht dieselbe Frage wie *welche Rolle schreibt eine gegebene Aussage in
dieser Datei* — genau die Frage, die
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)/[ADR-0025](0025-register-mit-gemischten-originalen.md)
stellen. [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) hat die passende Frage
nie gestellt, weil sein eigener Gegenstand (Commands) durchgehend **einheitliche** Originale hat —
ein Command hat eine ausführende Rolle, nicht sechs gemischte. Diese ADR ersetzt seine Festlegung 3
nicht; sie beantwortet die Frage, die jene bewusst offen ließ, mit einem anderen, hier passenderen
Werkzeug.

## Entscheidung

**Wir wählen Option C: Bei gemischten Originalen wird die Ableitung eine Ebene tiefer angesetzt —
je Aussage statt je Datei.** Dieselbe Bewegung wie
[ADR-0025](0025-register-mit-gemischten-originalen.md), hier direkt aus
[ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1
hergeleitet — diese ADR hängt an keiner noch nicht angenommenen Fassung. Drei Festlegungen:

**1. Eine Passage in `.claude/agents/*.md` gehört der Rolle, die ihr Original schreibt.**

- **Gibt eine Passage Modul 8 (oder ein anderes Baseline-Modul) wieder** — als Paraphrase oder als
  wörtliches Zitat —, **gehört sie dem Architect.** Begründung wie in
  [ADR-0025](0025-register-mit-gemischten-originalen.md) Festlegung 2: ob eine Textstelle eine
  Baseline-Regel korrekt (und vollständig) wiedergibt, ist dieselbe Art Urteil, die
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) für Baseline-Abweichungsfragen dem
  Architect zuweist. Das schließt Passagen ein, die eine bereits an anderer Stelle geltende
  Baseline-Regel — etwa `AGENTS.md` §3.7 — auf eine **neue** Textstelle in diesen sechs Dateien
  anwenden: genau das war `abe6e3b`s Streichung, §Kontext oben.
- **Gibt eine Passage die eigene ausführende Rolle-Datei wieder** — den Zeiger auf
  `.claude/commands/implement-slice.md`, auf `plan-welle.md`/`close-welle.md`, auf
  `.harness/skills/reviewer.md` —, **gehört sie der Rolle, der dieses Artefakt nach
  [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 1 gehört**:
  Implementer, Planner beziehungsweise Reviewer. Diese Zuordnung ist bereits gelebte Praxis — jede
  der drei betroffenen Dateien trägt den Zeiger seit dem Gründungs-Commit unverändert.
- **Trägt eine Passage eine bindende Setzung ohne benennbares Original** — wie die
  Reviewer-/Verifier-Ergänzung aus `b39d4ff` (*„Die Report-Datei ist dein Werkstück"*, dort neu
  eingeführt, nicht aus einem existierenden Text zitiert) —, **gehört sie dem Architect**, dieselbe
  Grenze wie in [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md) und
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1 für
  Aussagen ohne Original.

**2. Die Datei bekommt keinen Eigentümer; nur ihre Änderungen.** Wie
[ADR-0025](0025-register-mit-gemischten-originalen.md) Festlegung 1 es für
`docs/plan/carveouts/README.md` festhält: *„wer wissen will, wer sie insgesamt pflegt, bekommt
keine Antwort — nur je Änderung eine."* Das ist der Preis der gemischten Originale, kein Defekt
dieser Entscheidung.

**3. Der Auftraggeber-Pfad aus [`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
bleibt unverändert bestehen — parallel, nicht ausgeschlossen.** Bei Personalunion von Auftraggeber
und Entwickler-Rolle ersetzt ein angenommener Change Request, der in einem eigenen Commit landet,
der die Anweisung als Quelle nennt, den rollen-gebundenen Weg. `abe6e3b` erfüllt diese Form: eigener
Commit, ausschließlich `.claude/agents/*.md` berührt, Herkunft in der Message benannt
(*„Geschrieben auf ausdrückliche Anweisung des Auftraggebers"*). **Das macht die Änderung
nachträglich legitim** — nicht weil sie zufällig die richtige Rolle getroffen hätte (nach
Festlegung 1 wäre sie Architect-Territorium gewesen), sondern weil der Auftraggeber-Pfad ein
eigenständiger, in diesem Repo bereits sanktionierter zweiter Weg ist. Festlegung 1 regelt den
**rollen-geführten** Weg; wo eine Änderung stattdessen den Auftraggeber-Pfad nimmt, prüft sich diese
ADR nicht selbst — sie prüft nur, ob die Commit-Konstruktion aus
[`MR-015`](../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
eingehalten ist.

**Was hier NICHT entschieden ist:** der Inhalt der sechs Dateien über die geprüften Passagen
hinaus; ob eine künftige Passage in eine der drei Festlegungs-1-Zweige fällt, ist am Text zu lesen,
nicht hier vorwegzunehmen ([`AGENTS.md`](../../../AGENTS.md) §3.6); und die emittierte Ebene.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — **nichts tun**, die Frage bleibt offen wie in [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) Festlegung 3 | kein neuer Norm-Text | der Trigger ist **zweimal** eingetreten (`e30e0fd`/`b39d4ff`/`3df35f3` vor, `abe6e3b` mit offenem Bekenntnis dazu), und der jüngste Commit benennt die Lücke selbst als ungelöst — weiter nichts tun verlängert genau den Zustand, den der schreibende Lauf als *„nachträglich zu tragen"* auswies |
| B — dieselbe Ableitung wie [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) anwenden: eine Rolle „führt" die Typkarten aus | eine Ableitung für beide Klassen | genau die Fehllesart, vor der [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) §Kontext selbst warnt: die sechs Dateien operationalisieren keinen eigenen Ablauf, sie zeigen darauf — es gibt keine „ausführende Rolle" der Typkarte als Ganzes |
| **C — je Aussage ableiten, aus [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 1 (gewählt)** | beantwortet jede Passage eindeutig, ohne die Datei zuzuweisen; liest eine Struktur, die am Text selbst ablesbar ist (jede geprüfte Zeile projiziert ein Original); steht auf einer bereits `Accepted`-ADR, nicht auf einer `Proposed` | die Vorfrage ist je Passage ein Urteil, kein Muster; für eine vierte Passagen-Art (falls sie entsteht) liefert die Tabelle in §Kontext keine Antwort auf Vorrat |
| D — Architect als **alleiniger** Eigentümer der ganzen Datei | kürzeste Regel; deckt den akuten Fall (`abe6e3b`) korrekt | trifft die drei Zeiger-Passagen falsch: sie projizieren Command-/Skill-Dateien, die nach [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) namentlich anderen Rollen gehören — der Implementer, der `implement-slice.md` umbenennt, dürfte den eigenen Zeiger in `implementer.md` nicht nachziehen |
| E — auf [ADR-0025](0025-register-mit-gemischten-originalen.md)s Annahme warten und dann direkt referenzieren | ein Norm-Text weniger | [ADR-0025](0025-register-mit-gemischten-originalen.md) ist `Proposed`; eine ADR, die an der Annahme einer anderen `Proposed`-ADR hängt, überträgt deren Unsicherheit unnötig — die Methode ist bereits vollständig aus der `Accepted`-Festlegung 1 von [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) herleitbar |

## Konsequenzen

- **Positiv:** die Frage *„durfte dieser Lauf das schreiben?"* ist für `.claude/agents/*.md` vor
  der Änderung beantwortbar, je Passage statt geraten.
- **Positiv:** `abe6e3b` bekommt eine nachträgliche, aber vollständige Bewertung: die Streichung war
  inhaltlich korrekt angewendetes §3.7, aber Architect-Territorium (Festlegung 1, erster Spiegel-
  strich) und ist über den Auftraggeber-Pfad (Festlegung 3) legitim, nicht über den rollen-geführten
  Weg.
- **Positiv:** `BEO-007` bekommt für `.claude/agents/*.md` einen echten Ausgang, statt ein zweites
  Mal *„umgangen, nicht gelöst"* zu bleiben.
- **Negativ, und das ist der Preis:** die Datei hat weiterhin keinen einzelnen Eigentümer — wer eine
  neue Passage hinzufügt, muss zuerst ihr Original identifizieren, bevor er weiß, wer sie schreiben
  darf.
- **Negativ:** **kein Wächter**, siehe unten.
- **Folgepflicht 1 — der Zeiger im Briefing, fällig erst mit der Annahme.**
  [`AGENTS.md`](../../../AGENTS.md) §3.8 spricht heute nur von den zwei dort benannten Artefakten;
  `.claude/agents/*.md` fällt nicht darunter (§3.8 selbst: *„Über andere Norm-Artefakte sagt diese
  Regel nichts"*). Ein Zeiger dorthin ist **nicht** nötig — §3.8 bleibt bewusst auf seine zwei
  Artefakte begrenzt, wie [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0025](0025-register-mit-gemischten-originalen.md) es für ihre Artefakte ebenfalls nicht
  fordern. Der **ADR-Index** trägt die Auffindbarkeit.
- **Folgepflicht 2 — `BEO-007` bekommt seinen Ausgang für die Agenten-Hälfte.** Der **Planner**
  trägt bei der nächsten Slice-Closure, die die Zeile berührt, den Vermerk *„für `.claude/agents/*.md`
  entschieden durch [ADR-0029](0029-agenten-typkarten-derivativ-gemischte-originale.md)"* nach —
  diese ADR schreibt das Register nicht selbst (Modul 6: *„Eingetragen wird bei der
  Slice-Closure"*).
- **Folgepflicht 3 — kein Eintrag im Adaptions-Block.** Dieselbe Begründung wie
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0025](0025-register-mit-gemischten-originalen.md): die Regel füllt eine von der Baseline
  offen gelassene Lücke, sie weicht nicht ab
  ([`MR-000`](../../../harness/conventions.md#mr-000--baseline-aussage)).
- **Folgepflicht 4 — die emittierte Ebene bleibt unberührt.** Ob ein erzeugtes Repo eine
  Eigentums-Aussage über seine Agenten-Typkarten bekommt, entscheidet der Slice, der die Tool-Ebene
  entscheidet — nicht diese ADR.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| — | **keine.** Der prüfbare Teil wäre *„eine Passage in `.claude/agents/*.md` ändert sich, ohne dass derselbe Commit ihr Original berührt oder als Auftraggeber-Change-Request gekennzeichnet ist"* — eine **Commit**-Bedingung, so wenig gebaut wie bei [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md), [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und [ADR-0025](0025-register-mit-gemischten-originalen.md) | — |

**Was hier bewusst NICHT steht.** Ein Sensor müsste **Commits** lesen; kein Modul der heutigen
`.d-check.yml`-Konfiguration tut das (`grep -m1 '^modules:' .d-check.yml` führt `links, anchors,
ids, matrix, codepaths, spans`), und `make mutate` kennt zwei Fehlschlag-Formen — `--- FAIL:` der
Go-Stufe, `not ok N` der bats-Stufe —, keine, in der ein Commit-Zuschnitt rot wird. Auch die
Vorfrage aus Festlegung 1 ist unbewacht: welches Original eine Passage wiedergibt, sieht kein
`grep`. Behauptet wird hier **kein** Gate
([`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)). Träger
ist der Rollen-Wechsel vor der Änderung — oder, nach Festlegung 3, der dokumentierte
Auftraggeber-Pfad.

## Re-Evaluierungs-Trigger

- **Wenn ein künftiger Baseline-Stand eine schreibende Rolle für Agenten-Typkarten oder für
  derivative Register mit gemischten Originalen allgemein benennt** *(feedforward — eine
  Textänderung upstream, kein Sensor)*: dann ist diese ADR gegenstandslos und wird durch eine
  Nachfolge-ADR mit *Supersedes* auf den Baseline-Abschnitt zurückgeführt. `v5.12.0` benennt keine.
- **Wenn [ADR-0025](0025-register-mit-gemischten-originalen.md) angenommen oder verworfen wird**
  *(feedforward)*: dann ist zu prüfen, ob diese ADR ihre Formulierung angleicht — inhaltlich ändert
  sich nichts, weil diese ADR unabhängig aus [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md)
  hergeleitet ist (§Kontext, §Verglichene Alternativen Option E).
- **Wenn eine Passage in `.claude/agents/*.md` entsteht, die in keinen der drei Zweige aus
  Festlegung 1 fällt** *(feedforward — beim Lesen, nicht durch ein Kommando)*: dann ist ein vierter
  Zweig fällig, und diese ADR beantwortet den neuen Fall nicht rückwirkend.
- **Wenn die Klasse ein weiteres Mal ohne Rollen-Zuordnung UND ohne den Auftraggeber-Pfad aus
  Festlegung 3 auftritt, obwohl diese Entscheidung angenommen ist** *(feedforward — am
  Commit-Bestand ablesbar, dieselbe Probe wie
  [ADR-0015](0015-rollen-eigentum-an-norm-artefakten.md),
  [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) und
  [ADR-0025](0025-register-mit-gemischten-originalen.md) an sich selbst anlegen)*: dann trägt der
  Ort nicht, und die Trägerwahl ist der Befund, nicht die Wiederholung.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-08-31 | **Proposed** | Architect-Lauf; Anlass ist der zweite Eintritt des in [ADR-0024](0024-derivatives-register-gehoert-der-rolle-seines-originals.md) Festlegung 2 benannten Re-Evaluierungs-Triggers, ausgelöst durch den Commit `abe6e3b` (Auftraggeber-Change-Request, während dieser Lauf die Eigentumsfrage bereits bearbeitete) und die offen gebliebene Festlegung 3 aus [ADR-0028](0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md) (`Proposed`, Annahme-Trigger `slice-145`) |

Nach `Accepted` wird diese Datei **nicht mehr inhaltlich überschrieben**.
Spätere Korrekturen oder Schärfungen entstehen als neue ADR mit
`Supersedes ADR-0029` (Baseline-Regelwerk `modul-04-adrs.md`
§Hard Rule für Accepted-ADRs).
