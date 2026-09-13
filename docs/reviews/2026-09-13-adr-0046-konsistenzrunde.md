# Review-Report — ADR-0046, Konsistenzrunde

**Art:** ADR-Konsistenzrunde (kein Slice-Review). Gegenstand ist eine einzelne Entscheidung im
Status `Proposed`, geprüft gegen die Quellen, die ihr eigener Acceptance-Trigger nennt.

**Datum:** 2026-09-13 · **Rolle:** Reviewer · **Kontext:** frisch, kein Anteil an der Entstehung
der geprüften Datei.

**Gegenstand:** [`docs/plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md`](../plan/adr/0046-welle-datei-entsteht-mit-der-eroeffnung.md)
· **Status bei Prüfung:** `Proposed` · **Stand:** `2f8ad619`, Arbeitsbaum leer.

**Prüfgrundlage (Acceptance-Trigger der Datei):**
[ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md),
[ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md), die Ziel-Form von
`modul-06-roadmap.md` in der regierenden Fassung `v6.7.2`. Dazu die fünf Pflicht-Punkte des
Reviewer-Skills: Diff/Commit (`2f8ad619`), `LH-QA-01`/`LH-QA-02`, die in der Datei referenzierten
aktiven ADRs, [`AGENTS.md`](../../AGENTS.md) §3, und die vorherigen Findings am gleichen Gegenstand
([`2026-09-13-slice-offene-wellen-liste-hat-einen-waechter.md`](2026-09-13-slice-offene-wellen-liste-hat-einen-waechter.md),
HIGH-2 ist der Auslöser).

**Rollen-Grenze:** Diese Runde ändert nichts. Alle Sonden sind lesend; kein Gate-Lauf, keine
Docker-Stufe ([`AGENTS.md`](../../AGENTS.md) §3.9 — `make gates` fährt der Auftraggeber).

---

## Findings

### HIGH-1 — Die Folgepflicht-Menge ist kleiner als die gemessene Fundmenge: der Anweisungssatz, der den Wellen-Schnitt ausführt, lehrt die beendete Arbeitsweise weiter und hat keine Adresse

- `kategorie`: **HIGH** (MEDIUM *Abdeckungslücke*, eine Stufe hoch nach der Kontext-Eskalation des
  Reviewer-Skills: die Beobachtung liegt im Gate-Pfad)
- `quelle`: [ADR-0028](../plan/adr/0028-anweisungssatz-gehoert-der-ausfuehrenden-rolle.md)
  Festlegung 1 · [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
  · Festlegung 1 der geprüften Datei
- `pfad`: [`.claude/commands/plan-welle.md:7,9,84`](../../.claude/commands/plan-welle.md); in der
  geprüften Datei §Verglichene Alternativen Option E (*„drei fremde Artefakte müssen nachgezogen
  werden, bevor das Repo widerspruchsfrei ist"*) und der Folgepflicht-Block in §Konsequenzen
- `befund`: Der Planner-Anweisungssatz, der den Wellen-Schnitt ausführt, setzt die flache Datei
  ausdrücklich mit *geplant* gleich — Zeile 7 *„die **aktive bzw. geplante** Welle liegt **flach**
  in `docs/plan/planning/<welle-id>.md`"*, Zeile 9 *„Ob eine flache Welle *aktuell* oder *geplant*
  ist, sagt die Roadmap"*, Zeile 84 *„die neue Welle entsteht flach = aktiv/geplant"*. Sein
  Schritt 9 führt beide Zweige nebeneinander: *„die Welle-Zeile in *Nächste Wellen* pflegen —
  **oder**, wenn ihr Trigger bereits erfüllt ist, sie … heben"* — der erste Zweig erzeugt genau
  Lage 1 bzw. 2 der Sensor-Tabelle, die die geprüfte Datei selbst zitiert. Die Datei nennt drei
  nachzuziehende Artefakte (`welle-13`, Roadmap, Sensor-Text); dieses vierte nennt sie nicht,
  und keine offene Arbeitseinheit deckt es: `slice-153` zieht in derselben Datei den abgelösten
  Abschnittsnamen nach und berührt die Prämisse nicht, `slice-226` schließt sie ausdrücklich aus.

  ```sh
  git grep -cE 'geplant' -- .claude/commands/plan-welle.md                                   # 4
  git grep -cE 'geplant' -- docs/plan/planning/open/slice-153-wellen-commands-nennen-die-roadmap-abschnitte.md   # (keine Ausgabe = 0)
  ```

  Keine Erwartungswerte ([`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
  Setzung 2). Von den vier Treffern tragen drei (7, 9, 84) die Gleichsetzung; der vierte (Zeile 6)
  ist gewöhnliche Sprache.
- `verifizierbar`: **geteilt.** Der Widerspruch selbst: **nein** — kein Modul der
  [`.d-check.yml`](../../.d-check.yml) hält einen Anweisungssatz gegen eine ADR. Seine Wirkung:
  **ja** — `make docs-check`, sobald ein Lauf dem ersten Zweig von Schritt 9 folgt
  (`wave-preview-exists`, bei fehlendem Zeiger zusätzlich `wave-drift`).
- `klasse`: **Folgepflicht-Menge kleiner als die gemessene Fundmenge**
- **Failure-Szenario:** Der nächste Wellen-Schnitt ruft `/plan-welle`, liest im Kopf, eine flache
  Datei dürfe *geplant* sein, legt sie nach Schritt 7 an und pflegt nach Schritt 9 die Zeile unter
  *Nächste Wellen* weiter. `docs-check` färbt rot. Der Lauf findet dann zwei Quellen vor, die
  einander widersprechen — die angenommene ADR und seinen eigenen Anweisungssatz —, und die ADR
  ist ab `Accepted` nach [`AGENTS.md`](../../AGENTS.md) §3.4 nicht mehr korrigierbar. Zweite
  Variante: `slice-153` wird nach der Annahme ausgeführt und schreibt Schritt 9 auf *Offene
  Wellen* um, während die Kopf-Prämisse stehen bleibt — der Widerspruch überlebt seine eigene
  Reparatur.
- **Warum das die Annahme berührt:** Die Datei erklärt die Folgepflicht zur Roadmap-Zeile
  *„unabhängig vom Status dieser Datei fällig"*, weil sie *„schon heute eine Anleitung in ein rotes
  Gate"* ist. Genau dieselbe Eigenschaft hat der Anweisungssatz, in stärkerer Form — er ist die
  Anleitung und nicht eine Notiz daneben. §Konsequenzen ist der Ort, an dem diese Adressen liegen,
  und sie friert mit dem Accept ein.

### MEDIUM-1 — [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) wird als Quelle einer Eigentums-Aussage geführt, die sie ausdrücklich nicht trifft

- `kategorie`: **MEDIUM**
- `quelle`: [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1
- `pfad`: `docs/plan/adr/0046-…:19-20` (§Bezug), `:200-202` (§Was diese Entscheidung nicht tut),
  `:238-239` (Folgepflicht 1)
- `befund`: Die Datei führt ADR-0015 mit *„der Wortlaut eines Welle-Plans und der Roadmap ist
  Planner-Eigentum"*. ADR-0015 Festlegung 1 sagt das Gegenteil über ihre eigene Reichweite: *„Über
  die übrigen Norm-Artefakte trifft diese ADR **keine** Aussage — sie bestätigt keine fremde
  Zuordnung und setzt keine neue"*, und ihr Abschnitt *Was hier NICHT entschieden ist* nennt
  ausdrücklich *„eine Eigentums-Aussage über irgendein drittes Artefakt"*. Ihr Geltungsbereich ist
  [`AGENTS.md`](../../AGENTS.md) §3 und der Adaptions-Block, sonst nichts. Die Zuordnung selbst ist
  richtig — sie steht in `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle (Schritt 6
  *Roadmap fortschreiben · Planner*, Eröffnung als Planner-Arbeit) und in
  [`AGENTS.md`](../../AGENTS.md) §3.10 —, nur nicht in der genannten Quelle.
- `verifizierbar`: **nein** — kein Modul prüft, ob eine zitierte ADR die zitierte Aussage trägt.
- `klasse`: **Eigentums-Aussage auf eine ADR gestützt, die sie ausschließt**
- **Failure-Szenario:** Ein künftiger Lauf schlägt ADR-0015 auf, um zu klären, wem ein drittes
  Artefakt gehört, findet dort die Verweigerung und hält die hier getroffene Adressierung für
  unbelegt — obwohl sie belegbar ist.
- **Wiederholung, gemessen:** Dies ist die fünfte Instanz derselben Zuschreibung; vier davon
  stehen in bereits eingefrorenen Dateien.

  ```sh
  git grep -n 'Planner-Eigentum' -- 'docs/plan/adr/*.md' | grep -c '0015-rollen-eigentum'   # 5
  ```

  Kein Erwartungswert. Drei Wiederholungen sind nach dem Reviewer-Skill ein Steering-Loop-Signal:
  Der Träger gehört ins Beobachtungs-Register, nicht allein in die Korrektur dieser Datei.

### MEDIUM-2 — Die Fitness Function sagt „Festlegung 1 ist maschinell geprüft"; ein Drittel von Festlegung 1 hat keinen Wächter

- `kategorie`: **MEDIUM**
- `quelle`: [`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
- `pfad`: `docs/plan/adr/0046-…:277-285` (§Fitness Function) gegen `:164-166` (Festlegung 1,
  zweiter Aufzählungspunkt)
- `befund`: Festlegung 1 trägt drei Aufzählungspunkte. Die Kopplung *Datei ⟺ Zeiger ⟺ nicht in der
  Vorschau* deckt `waves`; die Aussage *„keine zwei von ihnen liegen sinnvoll in verschiedenen
  Commits"* deckt nichts — kein Modul der [`.d-check.yml`](../../.d-check.yml) liest Commits, und
  `make mutate` kennt für einen Commit-Zuschnitt keine Fehlschlag-Form. Dieselbe Lage stellen
  [`AGENTS.md`](../../AGENTS.md) §3.8 und §3.10 für sich selbst ausdrücklich fest. Die Datei nennt
  die Wächter-Lücke für Festlegung 2 sorgfältig und für die zwei Spalten-Grenzen von `waves`
  ebenso; für diesen Punkt nicht.
- `verifizierbar`: **nein** — die Lücke ist gerade, dass kein Lauf sie meldet.
- `klasse`: **Deckungs-Aussage greift über den genannten Wächter hinaus**
- **Failure-Szenario:** Ein Lauf legt Datei und Roadmap-Änderung in zwei Commits, hält die
  Festlegung für maschinell gedeckt und schließt aus dem grünen Gate, er habe sie eingehalten.

### MEDIUM-3 — Option B verwirft einen Bedarf als „nicht benannt", den dieselbe Datei an anderer Stelle als benannt führt

- `kategorie`: **MEDIUM**
- `quelle`: Maintainability · `modul-08-agentenrollen.md` §Konflikt-Pfad (*„die abweichende Position
  steht dokumentiert in §Verglichene Alternativen"*)
- `pfad`: `docs/plan/adr/0046-…:217` (Option B, Contra) und `:147-151` (§Was den Ausschlag gibt),
  gegen `:68` (Verweis auf `1be6be03`)
- `befund`: Option B schließt mit *„sie erkaufte eine Arbeitsweise, für die kein Bedarf benannt
  ist: Was der frühe Schnitt festhält, hält die Vorschau-Zeile auch"*. Der Bedarf **war** benannt,
  und zwar in dem Block, den dieselbe Datei in §Kontext als Fundort zitiert: *„Der Zeiger folgt dem
  **eingetretenen** Start-Trigger, nicht dem Schnitt: eine Welle ohne eingetretene Beginn-Bedingung
  zu eröffnen, hebt die Trigger-Disziplin auf, die dieselbe Roadmap einfordert"*
  (``git show 1be6be03 -- docs/plan/planning/in-progress/roadmap.md``). Das ist kein
  **Inhalts**-Argument, das die Vorschau-Zeile beantwortet, sondern ein **Disziplin**-Argument:
  Die flache Datei ohne Zeiger war das Artefakt, das *geschnitten* von *eröffnet* unterschied. Die
  Datei widerlegt es nicht, sie erwähnt es nicht.
- `verifizierbar`: **nein**
- `klasse`: **Abwesenheits-Behauptung gegen ein Dokument, das die Datei selbst zitiert**
- **Failure-Szenario:** Eine spätere Runde, die den zweiten Re-Evaluierungs-Trigger auslöst
  (*„ein Welle-Plan muss nachweislich vor der Eröffnung geschrieben werden"*), schlägt
  §Verglichene Alternativen auf und findet die Gegenposition dort nicht — sie muss die Abwägung
  aus `git` rekonstruieren, was der Abschnitt gerade ersparen soll.
- **Hinweis zur Substanz:** Der benannte Bedarf ist durch Festlegung 1 sachlich aufgefangen — wer
  nicht früh schneiden darf, eröffnet auch nicht früh. Der Befund betrifft die Vollständigkeit der
  Abwägung, nicht ihr Ergebnis.

### LOW-1 — Die dritte Folgepflicht adressiert eine Rolle, die für dieses Artefakt keine Quelle benennt

- `kategorie`: **LOW**
- `quelle`: [ADR-0015](../plan/adr/0015-rollen-eigentum-an-norm-artefakten.md) Festlegung 1
  (*„wo keine sie benennt, bleibt das eine offene Frage"*) · [`AGENTS.md`](../../AGENTS.md) §3.8
- `pfad`: `docs/plan/adr/0046-…:247` (*„Folgepflicht (Implementer)"* für
  [`harness/sensors/docs-check.md`](../../harness/sensors/docs-check.md))
- `befund`: Für `harness/sensors/**` benennt keine Quelle dieses Repos eine schreibende Rolle; die
  Datei setzt „Implementer" ohne Beleg. Bei den zwei anderen Folgepflichten steht wenigstens eine
  (wenn auch nach MEDIUM-1 die falsche) Quelle daneben.
- `verifizierbar`: **nein**
- `klasse`: **Rolle benannt, ohne dass eine Quelle sie zuweist**
- **Failure-Szenario:** Der Nachzug wird in einem Lauf gemacht, der sich auf die hier gesetzte
  Zuweisung beruft, und begründet damit eine Eigentums-Aussage, die keine Quelle trägt.

### LOW-2 — „Der Fall ist **einmal** gemessen" ist eine Zahl ohne Kommando und steht gegen die eigene Einordnung zwei Absätze weiter

- `kategorie`: **LOW**
- `quelle`: [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
- `pfad`: `docs/plan/adr/0046-…:196` gegen `:255-257`
- `befund`: §Was diese Entscheidung nicht tut sagt *„Der Fall ist **einmal** gemessen"*.
  §Konsequenzen sagt über dieselbe Klasse: *„das ist ein Urteil über eine Klasse und keine Messung;
  gemessen ist allein der Umfang des Registers"*. Beide Sätze können nicht zugleich gelten; der
  zweite ist der genauere, und neben dem ersten steht kein Kommando.
- `verifizierbar`: **nein** — keine Markdown-Datei liegt im Prüfbereich von `make comment-claims`.
- `klasse`: **Zählaussage über eine Klasse ohne Kommando**

### LOW-3 — Die erste Folgepflicht nennt eine von zwei überholten Aussagen in demselben Absatz von `welle-13` §1

- `kategorie`: **LOW**
- `quelle`: Maintainability
- `pfad`: `docs/plan/adr/0046-…:235-240`; in `welle-13` §1 Punkt 2 die Zeilen 82 und 84
- `befund`: Die Folgepflicht nennt den Satz *„Ein Sensor nach `slice-125` muss diese Abweichung
  tragen"* (Zeile 84). Zwei Zeilen darüber steht ein zweiter überholter Satz: die vier
  `waves`-Befunde *„benennen genau die repo-eigene Abweichung, die `roadmap.md` unter *Offene
  Wellen* erklärt"* — diese Erklärung ist mit `1be6be03` entfernt, der Verweis zeigt seit dem
  ins Leere. Der Planner, der die Folgepflicht ausführt, liest zwar denselben Absatz; benannt ist
  nur die eine Hälfte.
- `verifizierbar`: **nein** — der Verweis ist Prosa, kein Link; `links` sieht ihn nicht.
- `klasse`: **Befund nennt einen Fundort statt der Fundmenge**

### INFO-1 — „eine unerklärte Abweichung ist ein Fork" läuft in der Baseline in die andere Richtung

- `kategorie`: **INFO**
- `quelle`: `grundlagen-source-precedence.md` §Source Precedence ·
  `templates/harness/conventions/MR-NNN-titel.template.md`
- `pfad`: `docs/plan/adr/0046-…:25-27` (§Bezug) und `:181-183` (Festlegung 2)
- `befund`: Die Datei führt [`MR-000`](../../harness/conventions.md#mr-000--baseline-aussage) mit
  *„eine unerklärte Abweichung ist ein Fork"* und *„`MR-000` verlangt, dass eine Abweichung
  **erklärt** wird"*. Beide Quellen formulieren das Kriterium umgekehrt: *„Ein Eintrag, der keine
  benannte Regel ersetzt, ist ein **Fork**, keine Adaption"* (Eintrags-Vorlage), und die
  Fork-Grenze der Baseline greift die `MR`, die *„die Baseline **pauschal für nicht anwendbar**
  erklärt"*. `MR-000` selbst wendet den Begriff an, statt ihn zu setzen. Die umgekehrte Lesart ist
  ein eingeführtes Repo-Idiom (drei weitere lebende Fundorte), und sie zeigt hier in dieselbe
  Richtung wie das echte Kriterium: Ein Eintrag ohne ersetzte Baseline-Regel wäre nach dem
  Vorlagen-Wortlaut selbst der Fork. Die Folgerung von Festlegung 2 wird davon nicht getroffen,
  sondern gestützt.

### INFO-2 — Keine Geltungsbereichs-Klausel; auf der emittierten Ebene steht ein Rest derselben Formulierung

- `kategorie`: **INFO**
- `quelle`: Maintainability (Dogfood ggü. emittierter Ebene)
- `pfad`: die geprüfte Datei insgesamt; [`internal/emit/templates/commands/plan-welle.md:91`](../../internal/emit/templates/commands/plan-welle.md)
- `befund`: [`AGENTS.md`](../../AGENTS.md) §3.7, §3.8, §3.10 und §3.11 tragen je einen Satz
  *„Geltungsbereich: dieses Repo"*; die geprüfte Datei trägt keinen. Gemessen entsteht daraus kein
  Defekt — die emittierte Fassung des Anweisungssatzes führt die Ziel-Form bereits (*„mit dem
  Anlegen der flachen Welle-Datei verlässt die Welle-Zeile *Nächste Wellen*"*, Zeile 87) —, aber
  Zeile 91 trägt dieselbe Gleichsetzung wie die repo-lokale Fassung
  (``git grep -cE 'geplant' -- internal/emit/templates/commands/plan-welle.md`` → **3**). Welche
  Regeln die emittierte Ebene bekommt, entscheidet diese Datei nicht — und sagt es auch nicht.

### INFO-3 — „Zwei normative Aussagen dieses Repos" überträgt einem Welle-Plan einen Rang, den die Source Precedence ihm nicht gibt

- `kategorie`: **INFO**
- `quelle`: [`AGENTS.md`](../../AGENTS.md) §2
- `pfad`: `docs/plan/adr/0046-…:129-134`
- `befund`: Rang 5 der Source Precedence ist `docs/plan/planning/in-progress/roadmap.md`, nicht ein
  Welle-Plan; ein solcher steht in keinem der neun Ränge. Zwischen einer ADR (Rang 4) und einem
  Welle-Plan entscheidet §2 und nicht der Zufall. Das praktische Argument der Datei — ein
  stehengebliebener Satz wird gelesen — bleibt gültig; die Rang-Zuschreibung ist es nicht.

### INFO-4 — „war nach ihr **immer** die Abweichung" ist gegen genau einen Tag gemessen

- `kategorie`: **INFO**
- `quelle`: [`MR-033`](../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist)
- `pfad`: `docs/plan/adr/0046-…:94-95`
- `befund`: Die Datei nennt den Messtag `v6.7.2` ordnungsgemäß. Das Wort *immer* reicht darüber
  hinaus; belegt ist die Aussage für die regierende Fassung, nicht für frühere. Für die
  Entscheidung ist das folgenlos — regierend ist die Ziel-Fassung.

---

## Negativbefunde — geprüft, ohne Befund

**Punkt 1 — trägt die Entscheidung gegen die Ziel-Fassung?** Ja, und mit mehr Stellen, als die
Datei anführt. Die drei zitierten Sätze stehen je genau einmal:

```sh
B=".harness/baseline/$(grep -m1 '^BASELINE_TAG ?= ' Makefile | cut -d' ' -f3)/regelwerk/modul-06-roadmap.md"
grep -c 'ihre Zeile verlässt \*Nächste Wellen\*, unter \*Offene Wellen\* steht der' "$B"   # 1
grep -c 'Die \*Liste\* folgt den Dateien (ein Zeiger je offener Welle-Datei)' "$B"         # 1
grep -c 'ein Zeiger ohne Datei und eine Datei ohne Zeiger sind derselbe Defekt' "$B"       # 1
```

Zwei weitere Stellen desselben Moduls sagen dasselbe direkter und werden von der Datei nicht
genutzt: Closure-Schritt 6 *„**Befördert wird niemand**: Welche Wellen offen sind, sagen die
flachen Dateien"* und, im selben Schritt 3 der Closure, *„Offene Wellen flach, geschlossene in
`done/`"*. Die Gleichsetzung *flache Datei = offene Welle* ist damit nicht abgeleitet, sondern
ausgesprochen; Eröffnungs-Schritt 3 legt die Datei genau dort an.

**Der Vorlagen-Beleg trägt ebenfalls, und zwar stärker als behauptet.** Die Datei nennt nur den
unverlinkten Platzhalter der Vorschau. Der Kontrast dazu steht in derselben Vorlage: *Offene
Wellen* führt ihren Platzhalter **als Link** (Listenpunkt mit Link-Syntax auf `../<welle-id>.md`), *Nächste Wellen*
als blanken Text (`| <welle-id-a> | …`). Die Form ist also gewollt und kein Vorlagen-Artefakt.

**Punkt 2 — Festlegung 2, beide Messungen nachgefahren**, Ergebnis identisch:

```sh
ls harness/conventions/MR-*.md | wc -l                                                   # 55
git grep -l 'waves' -- harness/conventions harness/conventions.md | wc -l                 # 0
git grep -lE 'Welle-Datei|Start-Trigger|Offene Wellen|Nächste Wellen' \
  -- harness/conventions harness/conventions.md | wc -l                                   # 0
```

**Und über ein breiteres Vokabular gegengeprüft**, weil zwei Suchbegriffe eine Menge nicht
schließen: 19 Einträge nennen *Welle*, *Roadmap* oder *Vorschau*
(``git grep -licE 'welle|roadmap|vorschau' -- harness/conventions harness/conventions.md | wc -l``
→ **19**, kein Erwartungswert); keiner bucht die Arbeitsweise
(``git grep -n -iE 'schneid|geschnitten|vor dem (Start-)?Trigger|Bijektion|flache' -- harness/conventions harness/conventions.md``
liefert dreizehn Treffer, alle in anderer Sache). Die Aussage *nie gebucht* trägt.

**Punkt 3 — `welle-13` §1.** Der Wortlaut ist bestätigt (Zeile 84), und die Auflösung trägt
sachlich: Eine Anforderung, die verlangt, dass ein Sensor eine Abweichung trägt, wird mit dem Ende
der Abweichung gegenstandslos und nicht offen. Dass ein lebendes Planungs-Artefakt bis zum Nachzug
das Gegenteil sagt, benennt die Datei in §Konsequenzen als *Negativ*. Ergänzend siehe LOW-3 und
INFO-3; der Kern der Auflösung ist ohne Befund.

**Punkt 4 — die zweite Folgepflicht.** Die Aussage stimmt, geprüft am Bestand:
[`roadmap.md:32`](../plan/planning/in-progress/roadmap.md) trägt den Satz wörtlich, und `waves`
läuft seit `2f8ad619` scharf (`.d-check.yml:64-66`, `mode: many`). Wer der Anleitung folgt,
erzeugt Lage 2 der Sensor-Tabelle. Die Fälligkeit *„unabhängig vom Status dieser Datei"* trägt
damit, und die Adresse *Planner* ist richtig — belegt allerdings nicht durch ADR-0015 (MEDIUM-1),
sondern durch `modul-08-agentenrollen.md` §Rollen-Sequenz für eine Welle, Schritt 6.

**Punkt 5 — beide Abgrenzungen sind sauber, keine verdeckte Lieferung.**
Die Gate-Aktivierungs-Frage bleibt ausdrücklich ungeregelt, die Route ins Beobachtungs-Register ist
benannt, die Zuständigkeit der Closure ist korrekt beim Planner ([`AGENTS.md`](../../AGENTS.md)
§3.10), und die Klassen-Einordnung ist ausdrücklich als Urteil und nicht als Messung markiert
(Einschränkung nur in LOW-2). Die Start-Trigger der drei offenen Wellen sind nicht entschieden —
und brauchten es auch nicht: Nach der bis `1be6be03` geltenden Eigen-Regel (*„ist sie leer, hat
jede geschnittene Welle ihre Beginn-Bedingung erfüllt"*) sagt der gemessene Zustand die Antwort
bereits.

```sh
ls docs/plan/planning/welle-*.md | wc -l                                                      # 3
sed -n '/^## Offene Wellen/,/^## Nächste Wellen/p' \
  docs/plan/planning/in-progress/roadmap.md | grep -c '^- \[welle-'                           # 3
sed -n '/^## Nächste Wellen/,/^## Meilensteine/p' \
  docs/plan/planning/in-progress/roadmap.md | grep -cE '^\| \[?welle-'                        # 0
```

**Weitere Bereiche, geprüft ohne Befund:**

- **Zitat-Treue gegenüber [ADR-0044](../plan/adr/0044-ziel-fassung-regiert-den-sprung-v672.md):**
  Das Zitat steht verbatim (`0044-…:706-707`), und die Einschränkung der Datei — die Vorgabe sei
  auf den Adaptions-Durchgang geschnitten und binde diesen Fall *nicht wörtlich* — ist korrekt und
  ungewöhnlich sorgfältig: Sie nutzt das stärkste verfügbare Argument, ohne seine Reichweite zu
  dehnen.
- **[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md):**
  Festlegung 3 wird richtig verwendet — die Substanz-/Darstellungs-Unterscheidung wird in den
  eigenen Trigger geschrieben, solange die Datei `Proposed` ist. Festlegung 1 (Kennung statt Pfad
  in der Accept-Zeile) ist angekündigt. Festlegung 2 greift nach diesem Report (siehe Verdikt).
- **Referenzierte ADRs — alle acht `Accepted`**, keine superseded Quelle
  (`grep -n '^\*\*Status' docs/plan/adr/00{15,16,24,28,30,40,44,45}-*.md`).
- **[`AGENTS.md`](../../AGENTS.md) §3.11:** Kein Pfad-Link auf ein Artefakt, das der Prozess
  bewegt. `welle-13` steht durchgehend als Kennung; die Pfade in den Kommando-Blöcken sind
  Verzeichnisse und Globs und damit ortsfest
  (``grep -nE '\]\([^)]*planning[^)]*\)' docs/plan/adr/0046-*.md`` trifft nur den ADR-Dateinamen).
- **[`AGENTS.md`](../../AGENTS.md) §3.5:** Die Abgrenzung Verschärfung/Senkung trägt — die
  Aktivierung ist eine Verschärfung, die Rücknahme wäre die Senkung, und genau so steht es in
  §Re-Evaluierungs-Trigger.
- **[`AGENTS.md`](../../AGENTS.md) §3.4:** Keine `Accepted`-ADR ist berührt; der Commit `2f8ad619`
  legt eine neue Datei an.
- **ADR-Index** ([`docs/plan/adr/README.md`](../plan/adr/README.md)): ADR-0046 ist eingetragen,
  Titel und Status stimmen, Zeilen- und Dateizahl decken sich
  (``ls docs/plan/adr/0*.md | wc -l`` → **46**, Index-Zeilen → **46**).
- **Sensor-Tabelle:** Die zwei in der Datei zitierten Lagen decken sich wörtlich mit den Zeilen 1
  und 2 der Fünf-Lagen-Tabelle in
  [`harness/sensors/docs-check.md`](../../harness/sensors/docs-check.md); die zwei genannten
  Wächter-Grenzen (Spalte 3, toter Vorschau-Zeiger) entsprechen Lage 4 und 5 dort.
- **Innere Kohärenz von Festlegung 1:** Die Vorgabe *„Ihre Kennung steht dort **unverlinkt**"* ist
  mit dem Sensor verträglich — ohne Datei meldet `waves` nichts (Lage 5), und ein *verlinkter*
  Name ohne Datei fiele über `links` (`target-missing`).
- **Register-Umfang:** ``ls -d docs/plan/planning/observations/BEO-ALL/*/ | wc -l`` → **101**,
  wie angegeben.

---

## Was diese Runde nicht geprüft hat

- **Keinen Gate-Lauf.** `make gates`, `make docs-check`, `make mutate` und jede Docker-Stufe sind
  nicht gefahren ([`AGENTS.md`](../../AGENTS.md) §3.9; der Auftraggeber fährt sie). Die Auflösung
  der Links und Anker dieser ADR ist damit **nicht** unabhängig bestätigt.
- **Die fünf Lagen der `waves`-Fähigkeit nicht nachgemessen.** Sie sind aus
  `harness/sensors/docs-check.md` übernommen; geprüft ist allein, dass die zwei zitierten Zeilen
  dort wörtlich so stehen. Ein Trockenlauf gegen eine Kopie außerhalb des Repos hat nicht
  stattgefunden.
- **Keine DoD-Abhakung und keine Plan-vs-Code-Prüfung** des auslösenden Slice — das ist
  Verifikation, nicht Review.
- **Die übrigen Findings des auslösenden Reports** (HIGH-1, HIGH-3, die zwei MEDIUM) sind nicht
  nachgeprüft; diese Runde prüft die ADR, nicht den Slice.
- **Nicht beurteilt**, ob die Closure-Trigger von `welle-09`, `welle-11` und `welle-13` erreichbar
  sind, und nicht, ob `slice-153` in seinem jetzigen Zuschnitt richtig geschnitten ist.

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| HIGH | 1 | HIGH-1 |
| MEDIUM | 3 | MEDIUM-1, MEDIUM-2, MEDIUM-3 |
| LOW | 3 | LOW-1, LOW-2, LOW-3 |
| INFO | 4 | INFO-1, INFO-2, INFO-3, INFO-4 |

**Klassen für den Steering-Loop-Zähler** (Eintragung entscheidet die Closure, nicht dieser Report):
*Eigentums-Aussage auf eine ADR gestützt, die sie ausschließt* (MEDIUM-1) ist mit fünf Instanzen
über der 3×-Schwelle und die einzige Klasse dieser Runde, die über den Einzelfall hinausreicht.
*Folgepflicht-Menge kleiner als die gemessene Fundmenge* (HIGH-1) ist verwandt mit der
Korrektur-an-allen-Vorkommen-Klasse; ob eine vorhandene Kennung passt, ist ein Urteil und steht
hier nicht.

---

## Verdikt

**Der Beleg trägt in dieser Fassung nicht — ein HIGH steht.**

Die zwei Hälften getrennt, weil der Acceptance-Trigger sie trennt:

1. **Die Substanz der beiden Festlegungen ist ohne blockierenden Befund.** Festlegung 1 gibt die
   Ziel-Form der regierenden Fassung unverändert wieder — sie ist dort nicht abgeleitet, sondern
   an drei Stellen ausgesprochen, und der frühe Schnitt war nach ihr die Abweichung. Festlegung 2
   trägt ebenfalls: Die Abweichung war im Adaptions-Block nie gebucht, ein retirierender Eintrag
   hätte nach dem Muster von `MR-047`/`MR-041` keinen Vorgänger aufzulösen, und der Träger für
   einen künftigen Lauf existiert dreifach — diese Datei, der ADR-Index und der scharfgestellte
   Sensor. Ein Eintrag im Register **aktiver** Abweichungen wäre für eine Nicht-Abweichung falsch
   am Platz. *Beide Punkte des Auftrags sind damit bejaht.*
2. **Blockierend ist HIGH-1, und er liegt weder an der Substanz der Festlegungen noch an der
   Darstellung** — er liegt an der **Folgepflicht-Menge** in §Konsequenzen. Die Datei erklärt das
   Repo nach drei Nachzügen für widerspruchsfrei; gemessen lehrt ein viertes, unbenanntes Artefakt
   die beendete Arbeitsweise weiter, und es ist gerade der Anweisungssatz, den der nächste
   Wellen-Schnitt ausführt. §Konsequenzen friert mit dem Accept ein
   ([`AGENTS.md`](../../AGENTS.md) §3.4).

**Damit ist zugleich eine Lücke im Trigger selbst benannt:** Seine Zweiteilung — *Substanz der
beiden Festlegungen* gegen *Darstellung (Adressform, Zahl ohne Kommando, Zitat-Stelle)* — hat für
einen Befund an den Folgepflichten kein Fach. Solange die Datei `Proposed` ist, darf der Architect
das nach [ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md)
Festlegung 3 schärfen.

**Was nach diesem Verdikt gilt:** Ist ein blockierender Befund gemeldet, ist der Beleg nach
[ADR-0040](../plan/adr/0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 2 die
**nächste Runde derselben prüfenden Rolle** — nicht die Nachmessung des Laufs, der den Befund
auflöst. Der einschlägige Präzedenzfall steht in
[ADR-0042](../plan/adr/0042-verweis-nachzug-im-eingefrorenen-artefakt.md) §Geschichte, wo genau
diese Bestätigungsrunde ausblieb und der Accept-Eintrag es festhalten musste.

Die drei MEDIUM und die drei LOW blockieren nicht; sie sind vor dem Umschlag zu beheben, weil sie
danach nach [`AGENTS.md`](../../AGENTS.md) §3.4 nur noch per Folge-ADR korrigierbar sind. Die vier
INFO sind Notizen ohne Handlungspflicht.
