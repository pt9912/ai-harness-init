# Review — `ADR-0012` (Proposed), Konsistenzprüfung nach Architect-Überarbeitung und Kürzung

## Kopf-Metadaten

| Feld | Wert |
|---|---|
| **Rolle** | Reviewer (Modul 10), `.harness/skills/reviewer.md` v1.4.0 |
| **Datum** | 2026-07-31 |
| **Diff/Commit-Range** | `7fc86eb..HEAD` über `docs/plan/adr/` — zwei Commits: `52da26e` (+107/−37 ADR, +1/−1 Index; Architect-Überarbeitung nach Proposed-Review) und `ac06b9a` (+11/−17; Forensik-/Meta-Kürzung) |
| **Prüfgegenstand** | `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md` (262 Zeilen, Status **Proposed**) + `docs/plan/adr/README.md:20` |
| **Modul-8-Auftrag** | `.harness/baseline/v3.5.2/regelwerk/modul-08-agentenrollen.md:70-71` — *„ADR-Änderung: Architect schreibt; Reviewer prüft auf Konsistenz"*. Der Reviewer entscheidet **nicht** über die Annahme und setzt den Status nicht. |
| **`LH-*`** | `LH-QA-01` (in der ADR viermal tragend zitiert, `spec/lastenheft.md:258-261`), `LH-QA-03` (in Alternative E zitiert, `spec/lastenheft.md:268-272`) |
| **Aktive ADRs** | `ADR-0011` (**Accepted**) Festlegung 1 Punkt 4/5, Festlegung 5, Alternative D, Option B, §Re-Evaluierungs-Trigger · `ADR-0003` (**Accepted**, in der Fitness Function zitiert) |
| **Hard Rules** | `AGENTS.md` §3.1 (keine halluzinierten Gates), §3.4 (ADR ab *Accepted* immutabel), §3.5 (Gates nicht ohne ADR lockern), §3.6 (keine Zusage ohne rot gesehenes Gegenbeispiel) |
| **Vorherige Findings am gleichen Modul** | `docs/reviews/2026-07-31-slice-060-dod3-review-runde-2.md` (M-1/M-2 — beide über genau die Einordnung, die diese ADR jetzt leistet; L-1 Zählfehler, L-2 als erschöpfend formulierte Aussage, L-4 Festlegung ohne Träger) · `docs/reviews/2026-07-31-slice-060-dod3-review.md` · `docs/reviews/2026-07-28-adr-0011-proposed-review*.md` (sechs Runden, Präzedenz für die Fitness-Function-Klasse) |
| **Regelwerk on-demand** | `modul-07-carveouts.md` (vollständig, 133 Zeilen), `modul-08-agentenrollen.md` §Rollen-Regeln + §Konflikt-Pfad, `modul-15-observability.md` §Token-Attributions-Regeln + §Cache-Counter-Regeln, `modul-10-review-harness.md` §Ziel-Form (via Skill) |
| **Gate-Lage des Prüfgegenstands** | **Der gesamte Prüfgegenstand liegt außerhalb jedes Gates, das Aussagen prüft.** `make comment-claims` deckt vier Pfad-Familien und kein Markdown; `make docs-check` fährt `[links, anchors, ids, matrix, codepaths, spans]` (`.d-check.yml:18`) plus `codepaths.check-lines` — Existenz und Zeilenspanne eines Pfad-Verweises, keine Sätze. Diese Lektüre ist der einzige Sensor. |

**Prüfmethode.** `ac06b9a` Hunk für Hunk gegen die Frage *„Forensik über den Weg oder Aussage
über die Sache?"* gelesen. Jede in der ADR behauptete Fundstelle am Artefakt nachgelesen, jede
Zahl selbst nachgezählt — **ohne** Wortgrenze dort, wo Bezeichner mit `_` im Spiel sind (siehe
N-4: die Wortgrenzen-Messung liefert hier die *falsche* Zahl). Jede Vollständigkeitsaussage gegen
den vom Text selbst deklarierten Prüfbereich gemessen, einschließlich der 3.383 Zeilen der
vendored Werkzeug-Doku. Die zwei Trägerslices (`slice-066`, `slice-068`) und der Welle-Plan
vollständig gelesen. Kein Gate-Lauf nötig und keiner gefahren — der Gegenstand ist ungegated.

---

## Findings

### H-1 — Die Konsequenz-Zeile schreibt `slice-066` eine Messung zu, die dieselbe ADR als dauerhaft quellenlos entscheidet

- **kategorie:** HIGH
- **quelle:** Hard Rule `AGENTS.md` §3.6 (*„benennen, was wirklich deckt — oder dass nichts deckt"*); `AGENTS.md` §3.4 (ab *Accepted* immutabel)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:160-161`
- **befund:** Der Satz lautet: *„wie viel Arbeit in Token im Haupt-Kontext anfällt, ist in diesem Repo nicht gemessen; **die Auswertung, die es messen könnte, liegt in `open/`**"*. Die einzige Auswertung in `open/` ist `slice-066`. Damit behauptet die ADR, `slice-066` könne den Token-Anfall des Haupt-Kontexts messen. Dieselbe ADR entscheidet das Gegenteil, dreifach: `:47-51` (*„Den Haupt-Kontext umschließt **kein** `Agent`-Aufruf; es gibt kein Ereignis, an dem seine Token anfielen, und keine Payload, die sie trüge"*), `:112-114` (*„nicht als Aufschub, sondern als **Grenze**"*) und — zwei Klauseln **vor** dem beanstandeten Satz, im selben Aufzählungspunkt — *„Kein Feld im Span sagt ihr, wie groß der nicht erfasste Teil war — die Größe ist nicht klein, sie ist **unbekannt**"*. `slice-066` liest nach seinem eigenen Plan ausschließlich Spans (`docs/plan/planning/open/slice-066-telemetrie-auswertung.md:111-112`), und keiner trägt Haupt-Kontext-Token. Der letzte Satz desselben Punktes (`:162-163`) schließt eine Größenangabe hier als *„Schätzung"* aus — das Verbot gilt für `slice-066` genauso (`ADR-0011` Festlegung 1 Punkt 4). Der Punkt sagt damit in drei Klauseln: unbekannt · wäre eine Schätzung · `slice-066` könnte es messen.
- **Zweite Fundstelle derselben Klasse:** `:144` (Alternative G, Contra) — *„der Haupt-Kontext bekäme keine Zahl, sondern nur weniger Arbeit — und **wie viel weniger, misst erst `slice-066`**"*. Die Formulierung ist schwächer, die Zuschreibung dieselbe: eine Token-Differenz im Haupt-Kontext ist aus keiner Quelle rechenbar, die diese ADR gelten lässt. Was `slice-066` misst, ist der **Sammelposten-Anteil** (`slice-066:51-54`) — `Agent`-Spans mit unbekannter Rolle, also eine Teilmenge der *erfassten* Token, nicht der Haupt-Kontext.
- **verifizierbar:** nein — kein Gate liest Markdown-Sätze gegeneinander. Belegt durch Lektüre von `:47-51`, `:112-114`, `:158-163`, `:144` gegen `slice-066:107-119` und `harness/conventions.md:1238-1276`.
- **Failure-Szenario:** Die ADR wird angenommen und ist ab da immutabel (`AGENTS.md` §3.4). Wer `slice-066` schneidet oder verifiziert, liest in der maßgeblichen Entscheidung, die Auswertung *könne* den Haupt-Kontext-Anteil messen, und nimmt entweder einen unerfüllbaren DoD-Punkt auf oder — wahrscheinlicher — leitet aus `result_bytes`/`duration_ms` eine Proxy-Zahl ab. Genau diese Umrechnung schließt `:50-52` als *„die Schätzung, die `ADR-0011` Festlegung 1 Punkt 4 ausschließt"* aus. Die Korrektur wäre dann eine Supersedes-ADR über einen Nebensatz.
- **Kategorisierung, offengelegt:** MEDIUM erwogen und verworfen. Der Satz steht nicht in einer Randbemerkung, sondern im Aufzählungspunkt, der den *Preis* der Entscheidung ausspricht, und er widerspricht der Kern-Festlegung, nicht einer Nebenaussage. `AGENTS.md` §3.6 führt als Falsch-Beispiel wörtlich *„‚Byte-Gleichheit belegt `make smoke`', ohne `smoke` gelesen zu haben"* — dieselbe Form: eine Deckung wird benannt, ohne dass sie besteht. Die Immutabilität ab *Accepted* macht aus dem Befund einen blockierenden.

### M-1 — Die zwei Fitness-Function-Zeilen sind „fällig mit `slice-066`", aber `slice-066` hat für sie keinen Träger

- **kategorie:** MEDIUM
- **quelle:** Hard Rule `AGENTS.md` §3.6; Skill-Anker „Bezug-/Abdeckungslücke einer Akzeptanzanforderung"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:200-211` gegen `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:40-103` und `:119`
- **befund:** Beide Zeilen der Fitness-Function-Tabelle sind mit *„fällig mit `slice-066`, existiert heute nicht"* markiert und binden die Nenner-Angabe (Go-Test + `test/mutations/`-Fall). `slice-066` weiß davon nichts: seine DoD führt drei slice-eigene Punkte — Token-Bilanz je Rolle mit Sammelposten- und Abdeckungszahl (1), getrennte Cache-Zähler (2), Splitting-Regel als Festlegung (3) —, **keiner** verlangt, dass die Ausgabe ihren Nenner (*„über Subagenten-Läufe, nicht über den Lauf"*) benennt. Die Plan-Tabelle bindet die Zähne ausdrücklich anders: `slice-066:119` — *„`test/` + `test/mutations/` | neu | **die Zähne aus DoD (1) und (2)**"*. Die ADR grenzt den Nenner zugleich selbst gegen DoD (1) ab (`:218-220`: *„Und der Nenner ist **nicht** der Sammelposten-Anteil aus `slice-066` DoD (1) … Zwei Größen, zwei Angaben, zwei Zähne"*) — sie weiß also, dass der vorhandene DoD-Punkt sie nicht trägt.
- **Zur berufenen Präzedenz (`:222-229`):** Sie trägt nur die halbe Last. `ADR-0011` wurde tatsächlich mit fünf `test/mutations/`-Zeilen angenommen, deren Dateien erst später entstanden (nachgemessen, N-6). Aber diese fünf hatten im umsetzenden Slice einen **DoD-Träger**: `docs/plan/planning/done/slice-059-telemetrie-erfassung-hook.md` DoD (3) — *„Zwei Zähne, rot gesehen"* — nennt zwei davon namentlich, die übrigen wurden im selben Punkt geliefert. Die Präzedenz belegt *„Datei darf fehlen"*, nicht *„Slice muss nichts davon wissen"*.
- **verifizierbar:** nein zum Zeitpunkt der Annahme. Ab `slice-066` **ja, aber falsch herum**: `make mutate` meldet nur *gelistete* Wächter, die ihre Zähne verloren haben (`AGENTS.md` §3.6: *„wer keinen Fall in `test/mutations/` hat, ist unbewacht"*). Ein nie angelegter Fall erzeugt kein Rot — der Sensor kann diese Lücke konstruktiv nicht melden.
- **Failure-Szenario:** `slice-066` läuft, hakt DoD (1)–(3) ab, Review und Verifikation prüfen gegen den Plan (Modul 11: *gegen Plan/DoD*), `make gates` und `make mutate` sind grün, der Slice wandert nach `done/`. Festlegung 2 der dann immutablen ADR hat keinen Zahn, und niemandes Prüfbereich hat je nach ihm gesehen — dieselbe Klasse wie `L-4` aus `docs/reviews/2026-07-31-slice-060-dod3-review-runde-2.md` („Festlegung ohne Träger im Empfänger-Artefakt"), eine Ebene höher, weil das Quell-Artefakt danach nicht mehr änderbar ist.

### M-2 — Die Konsequenz behauptet den Sensor im Präsens, den die Fitness Function zwei Absätze später als „existiert heute nicht" führt

- **kategorie:** MEDIUM
- **quelle:** Hard Rule `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:152-153` gegen `:210-211`
- **befund:** *„die Pflicht, den Nenner zu nennen, **hat ab hier** eine Begründung **und einen Sensor** statt nur einen Ort"*. Die Fitness-Function-Tabelle markiert beide Zeilen fett als *„existiert heute nicht"*. Vor `52da26e` lautete der Satz *„hat ab hier eine Begründung statt nur einen Ort"* und war zutreffend; die Einfügung von *„und einen Sensor"* macht aus einer Aussage über den Text eine über den Bestand. Die zwei Sätze sind nur unter einer Lesart vereinbar, die die ADR selbst nicht anbietet (*„hat ab hier" = „ist ab hier zugesagt"*), und der Folgesatz verstärkt das Präsens: *„Sie ist der Teil dieser Entscheidung, der **überprüfbar** ist"*. Der Index-Eintrag `docs/plan/adr/README.md:20` formuliert es korrekt (*„mit Wächter, **fällig** beim Auswertungs-Slice"*) — die Ehrlichkeit ist also im Index vorhanden und im Entscheidungstext verloren.
- **verifizierbar:** nein.
- **Failure-Szenario:** Ein Verifier, der den welle-09-Closure-Trigger auf die Matrix-Zelle anwendet (`docs/plan/planning/welle-09-modul-15-konformitaet.md:94`: *„**Sensor** | läuft real, mit `test/mutations/`-Fall"*), liest `:152-153` und bucht die Zelle als **Sensor**. `slice-068` DoD (3) verlangt ausdrücklich das Gegenteil (`:75-76`: *„dass die Zelle **deklarierte Entscheidung** trägt und nicht ‚Sensor' — ein Bericht ist kein Wächter"*). Zwei Artefakte, zwei Antworten auf dieselbe Zelle.

### M-3 — Der Verweis „steht … in den Risiken von `slice-066`" zeigt auf die andere Größe, die dieselbe ADR ausdrücklich abgrenzt

- **kategorie:** MEDIUM
- **quelle:** Skill-Anker „Bezug-/Abdeckungslücke"; wiederkehrende Repo-Klasse „unbelegte Fundstelle"
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:125-129` (Klausel auf `:127`) gegen `docs/plan/planning/open/slice-066-telemetrie-auswertung.md:155-157`
- **befund:** Festlegung 2 begründet, dass sie keine zweite Wahrheit schafft: *„Die Pflicht ist **nicht neu** — sie steht in `MR-018` Abweichung 6 **und in den Risiken von `slice-066`**"*. Für `MR-018` stimmt das verbatim (`harness/conventions.md:1271-1274`: *„Jede Token-Bilanz aus diesen Spans ist damit eine Bilanz über **Subagenten-Läufe**; ihr Nenner ist nicht der Verbrauch des Laufs … Wer ihn schreibt, schreibt das dazu"*). Die Risiken von `slice-066` tragen sie nicht: der dortige Aufzählungspunkt lautet *„Der Haupt-Kontext bleibt unerfasst. Seine Token erscheinen in keiner Payload; die Bilanz kann ihn nur über die Splitting-Regel behandeln. **Wie groß dieser Anteil ist**, gehört deshalb in jedes Ergebnis"* — die dort formulierte **Pflicht** ist die Größe des aufgeteilten Anteils, wortgleich mit `slice-066` DoD (1) `:53-54` und DoD (3) `:96-100`. Genau diese Gleichsetzung verbietet die ADR 91 Zeilen später selbst: `:218-220` — *„der Nenner ist **nicht** der Sammelposten-Anteil aus `slice-066` DoD (1) … wer sie zusammenlegt, verliert eine"*. Der Text nennt eine Fundstelle als Beleg und erklärt an anderer Stelle, dass sie die falsche Größe führt.
- **verifizierbar:** nein.
- **Failure-Szenario:** Der Verweis ist der Mechanismus, der M-1 unsichtbar macht: wer prüft, ob die Nenner-Pflicht in `slice-066` verankert ist, folgt ihm, findet dort eine Pflicht mit ähnlichem Wortlaut, hakt ab — und übersieht, dass es die Größe ist, die die ADR ausdrücklich *nicht* meint. Beide Größen fallen in einer Angabe zusammen, was `:220` als Verlust einer von beiden beschreibt.

### M-4 — `LH-QA-01` trägt in dieser ADR drei unvereinbare Rollen

- **kategorie:** MEDIUM
- **quelle:** `LH-QA-01` (`spec/lastenheft.md:258-261`); `AGENTS.md` §3.1; Source Precedence (`AGENTS.md` §2)
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:10-15` · `:195-198` · `:226-229` (dazu die Geschichte-Zeile `:261`)
- **befund:** Der Architect hat den ursprünglichen Dogfood-Fehlgriff korrekt erkannt und `AGENTS.md` §3.6 als tragenden Grund eingesetzt. `LH-QA-01` ist dabei stehengeblieben und sagt jetzt an drei Stellen Verschiedenes:
  1. **`:11-12` (Bezug):** *„der Grund, warum **Festlegung 1** unten keine Fitness Function trägt"*. Die Geschichte-Zeile `:261` sagt zum selben Vorgang *„mit `AGENTS.md` §3.6 **statt** `LH-QA-01` als tragendem Grund"*. „Der Grund" und „statt" schließen einander aus.
  2. **`:14-15` (Bezug):** *„für den Dogfood gilt sie in der Fassung, die `AGENTS.md` §3.1 daraus macht. Hier wird sie **in dieser Fassung** zitiert, **nicht auf die Dogfood-Ebene ausgeweitet**"*. Der Satz bricht in beiden Lesarten: bezieht sich *„dieser Fassung"* auf die §3.1-Dogfood-Fassung, ist der Nachsatz das Gegenteil des Hauptsatzes; bezieht er sich auf den emittierten Originalwortlaut, widerspricht er `:197-198`, wo `LH-QA-01` ausdrücklich *„in der Dogfood-Fassung aus `AGENTS.md` §3.1"* angewendet wird.
  3. **`:195-198` gegen `:226-229`:** Zur selben Frage — *engagiert eine Fitness-Function-Zeile in einer ADR `LH-QA-01`?* — gibt die ADR zwei einander ausschließende Antworten. `:195-198`: eine Tabellenzeile für Festlegung 1 *„wäre ein Gate über leerem Prüfbereich (`LH-QA-01` in der Dogfood-Fassung aus `AGENTS.md` §3.1)"*. `:226-229`: *„`LH-QA-01` ist dadurch **nicht berührt**: hier wird kein Gate in `make gates`, `AGENTS.md` §4 oder `harness/README.md` **behauptet**"*. Das zweite Kriterium — nur in den drei kanonischen Gate-Orten behauptete Gates zählen — gilt für eine Festlegung-1-Zeile genauso wie für die zwei Festlegung-2-Zeilen. Gilt es, trifft `LH-QA-01` in `:195-198` nicht zu; gilt es nicht, ist `:226-229` falsch.
- **verifizierbar:** nein. `LH-QA-01`s Wortlaut und Messmethode selbst nachgelesen (`spec/lastenheft.md:260-261`) — das Zitat in `:12-13` ist verbatim korrekt.
- **Failure-Szenario:** Die ADR ist nach `AGENTS.md` §2 Rang 3 normativ und ab *Accepted* immutabel. Sie friert damit zwei gegenläufige Auslegungen von `LH-QA-01` ein. Der nächste Streit über *„braucht diese ADR-Zeile einen existierenden Sensor?"* lässt sich mit demselben Dokument in beide Richtungen entscheiden — und dieselbe Anforderung stand in dieser ADR schon einmal auf der falschen Ebene (der Befund, den `52da26e` beheben sollte).

### L-1 — Folgepflicht 2 benennt eine Stelle des Welle-Vokabulars; das überholte Vokabular steht an drei Stellen, und `slice-068`s Plan-Tabelle berührt den Welle-Plan nicht

- **kategorie:** LOW
- **quelle:** Skill-Anker „Doku-Drift"; `AGENTS.md` §3.6
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:169-177` gegen `docs/plan/planning/welle-09-modul-15-konformitaet.md:16-18`, `:95`, `:139` und `docs/plan/planning/open/slice-068-rollen-arbeit-laeuft-als-rolle.md:116-119`
- **befund:** Die Folgepflicht ist sachlich richtig und nachgemessen: der Welle-Plan definiert *deklariert* über einen Auflösungs-Trigger (`welle-09:95`), und eine leere Zelle liest er als offenen Closure-Trigger (`:99`). Sie benennt aber nur den **Closure-Trigger**. Dieselbe überholte Formulierung steht zusätzlich im **Welle-Ziel** (`welle-09:16-18`: *„entweder einen laufenden Sensor oder eine deklarierte Entscheidung **mit Auflösungs-Trigger**, und nichts dazwischen"*) und in der **Slice-Tabelle** (`welle-09:139`: `slice-068` *„legt für die Matrix-Zelle Token-Attribution × Repo fest, dass sie ‚deklarierte Entscheidung **mit Trigger**' trägt"*) — Letzteres ist durch `slice-068:72-83` bereits überholt. Der benannte Träger trägt die Ergänzung außerdem nicht: `slice-068` DoD (3) schreibt die Festlegung, aber seine Plan-Tabelle (`:116-119`) führt nur `harness/conventions.md` und `slice-066` — der Welle-Plan ist dort keine berührte Datei.
- **verifizierbar:** nein.
- **Failure-Szenario:** `slice-068` läuft plan-konform, ergänzt `MR-018`, und der Welle-Plan behält an drei Stellen ein Vokabular, das den ADR-Pfad nicht kennt — inklusive einer Zeile, die `slice-068` eine Festlegung zuschreibt, die er so nicht mehr trifft.

### L-2 — „bisher überwiegend" ist eine Mengenaussage über den ganzen Repo-Bestand, belegt an einem Slice

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6; die Klasse, die `52da26e` an zwei anderen Stellen bereinigt hat
- **pfad:** `docs/plan/adr/0012-haupt-kontext-ohne-token-bilanz.md:39-42`
- **befund:** *„er ist der Ort, an dem die Rollen-Arbeit dieses Repos **bisher überwiegend** gelaufen ist (an `slice-060` belegt: Planner und Implementation über weite Strecken in **einem** Kontextfenster)"*. Der Beleg ist eine Beobachtung an einem Slice (`slice-068:153-157`, dort korrekt als *„Belegt an der Arbeit an `slice-060`"* geführt). *„Überwiegend"* über den bisherigen Bestand ist daraus nicht abgeleitet; Spans entstehen erst seit `slice-059`, die Rollen-Achse ist erst mit `slice-060` gefüllt, und die Verteilung ist an keiner Stelle ausgezählt. Der Nachsatz *„**Wie viele Token** das sind, weiß niemand"* nimmt die Token-Aussage zurück, nicht die Mengenaussage über den Ort. `52da26e` hat zwei Aussagen genau dieser Klasse gestrichen (*„der Ort, an dem der größte Teil der Arbeit anfällt"*, *„misst damit dauerhaft die kleinere Hälfte"*) — diese dritte ist umformuliert stehengeblieben.
- **verifizierbar:** nein heute; ab `slice-066` teilweise (Verhältnis von `Agent`-Spans zu Haupt-Strom-Spans ist auszählbar — das ist aber eine Aufruf-, keine Arbeitsmenge).
- **Failure-Szenario:** Die Aussage wird als gemessener Repo-Befund weiterzitiert, wie es der ADR-Kontext nahelegt, und stützt später eine Priorisierung („die Rollen-Konvention bewegt den größten Anteil"), für die es keine Zahl gibt.

### L-3 — Die Commit-Message von `ac06b9a` nennt eine Zeilenzahl, die um eins danebenliegt

- **kategorie:** LOW
- **quelle:** `AGENTS.md` §3.6 (Commit-Message ist dort ausdrücklich als Zusage geführt)
- **pfad:** Commit `ac06b9a`, Message-Zeile *„268 -> 263 Zeilen"*
- **befund:** Gemessen mit drei unabhängigen Zählern (`wc -l`, `grep -c ''`, `awk 'END{print NR}'`, alle drei 262; Datei endet mit `0a`): `git show 52da26e:…` = **268**, `git show ac06b9a:…` = **262**. Der `--numstat` bestätigt es unabhängig: +11/−17 = netto −6. Die Message sagt −5. Das ist der zwölfte Zählfehler dieser Familie und der erste, der in einer Commit-Message steht statt in einem Doku-Satz.
- **verifizierbar:** ja — `git show <commit>:<pfad> | wc -l` bzw. `git show --numstat ac06b9a`. Beides gefahren.
- **Failure-Szenario:** Gering: die Historie ist nicht normativ. Gemeldet, weil die Zahl ausdrücklich als Messergebnis präsentiert wird (*„GEMESSEN STATT GESCHAETZT"* im selben Text) und die Klasse in dieser Familie die häufigste ist.

### I-1 — `ac06b9a` hat genau eine gemessene, zutreffende Eigenschaft der Normquelle mitentfernt — ohne Substanzverlust für die Aussagen der ADR

- **kategorie:** INFO
- **quelle:** `.harness/baseline/v3.5.2/regelwerk/modul-07-carveouts.md`
- **pfad:** Commit `ac06b9a`, entfernter Absatz (vormals nach `:99`)
- **befund:** Von den fünf entschärften Meta-Rahmungen und den acht Forensik-Zeilen enthielt genau **ein** Satz eine Messung: *„‚Aufwand' steht in Modul 7 an genau einer Stelle, und sie entscheidet *Carveout gegen ADR*, nicht *Träger gegen kein Träger*."* Nachgemessen: `grep -c "Aufwand" modul-07-carveouts.md` = **1**, Zeile 64, in Frage 2 des Trichters — die Aussage war **wahr**. Sie ist trotzdem kein Substanzverlust der ADR: sie war die Prämisse einer Widerlegung, deren Gegenstand (eine frühere Entwurfsfassung) mitentfernt wurde, und ihre Anwendung steht unverändert im Trichter (`:85-89`: *„Kein Aufwand dieses Repos bringt die Bedingung herbei"*) samt dem verbatim zitierten `:63-67`. Keine Aussage, die die ADR heute noch trifft, hängt an ihr.
- **verifizierbar:** ja (`grep` gegen die vendored Normquelle, gefahren).
- **Failure-Szenario:** Schwach: wer die verworfene Gegenposition erneut vorbringt (*„der Trigger ist nur beobachtbar, also weder Folge-Slice noch ADR"*), findet ihre Widerlegung nicht mehr ausgeschrieben, sondern muss sie aus dem zitierten Modul-Ausschnitt neu herleiten. Das ist zumutbar; das Zitat trägt sie.

### I-2 — Nebenbefund außerhalb des Prüfgegenstands: `welle-09:90` sagt „drei Werte", die Tabelle darunter führt vier

- **kategorie:** INFO
- **quelle:** Skill-Anker „Doku-Drift"
- **pfad:** `docs/plan/planning/welle-09-modul-15-konformitaet.md:89-90` gegen `:94-97`
- **befund:** *„jede Zelle mit genau einem von **drei** Werten"* — die Tabelle direkt darunter führt **Sensor** (`:94`), **deklariert** (`:95`), **emittiert** (`:96`), **nicht emittiert** (`:97`), also vier. Eigenständig nachgezählt, nicht aus der Beauftragung übernommen. Der Befund liegt außerhalb des Diffs, ist aber der Ort, an den Folgepflicht 2 der ADR schreibt: wer dort eine vierte Belegart ergänzt, findet einen Satz vor, der schon die dritte nicht mitzählt.
- **verifizierbar:** nein.
- **Failure-Szenario:** Die Ergänzung aus Folgepflicht 2 wird eingetragen und der Zählsatz erneut nicht mitgezogen — dann sagt der Plan „drei", wo fünf stehen.

---

## Negativbefunde

Je Bereich eine „geprüft, ohne Befund"-Zeile.

| # | Bereich | Ergebnis |
|---|---|---|
| **N-1** | **`ac06b9a` Hunk 1** (`:44-46`, *„hier nicht verdoppelt — zwei Stellen mit derselben Messung driften auseinander"*) | Reine Schreibentscheidungs-Verteidigung. Keine Eigenschaft entfernt; der Verweis auf `MR-018` Abweichung 6 steht unverändert. **Ohne Befund.** |
| **N-2** | **`ac06b9a` Hunk 2a** (Rahmung *„gehört in denselben Punkt, weil das ganze Verdikt an ihr hängt"* → *„Die Grenze dieser Antwort:"*) | Meta über die Platzierung. Die Sache — *herbeiführen* gegen *nachsehen*, „gelesen, nicht gemessen", Sonde beobachtet statt herbeizuführen — steht vollständig weiter. **Ohne Befund.** |
| **N-3** | **`ac06b9a` Hunk 2b** (*„steht deshalb unten … und nicht hier als abgeschlossene Prüfung"* → *„und die Fläche steht unten als Re-Evaluierungs-Trigger"*) | Der epistemische Status ist im vorangehenden Satz erhalten (*„Entscheidung unter benannter Unsicherheit"*), der Re-Evaluierungs-Trigger existiert (`:239-247`). **Ohne Befund.** |
| **N-4** | **`ac06b9a` Hunk 2c** (acht Zeilen Gegenpositions-Widerlegung) | Acht Zeilen entfernt, drei davon als das erhaltene, verbatim korrekte `:129`-Zitat wieder eingesetzt (netto fünf); der Rest ist Widerlegung eines früheren Entwurfs; der Schlusssatz ist zu *„Ein Zustand ohne Träger ist nach Modul 7 kein temporärer"* verkürzt, ohne Aussageverlust (die zweite Hälfte *„nichts zu planen"* trägt Festlegung 1 `:116-118`). Die einzige mitentfernte Messung ist **I-1**. **Sonst ohne Befund.** |
| **N-5** | **`ac06b9a` Hunk 3** (*„damit niemand mehr hineinliest"*) | Meta. Die Abgrenzung Anwesenheit/Wahrheit und die Trennung Nenner ≠ Sammelposten-Anteil stehen vollständig. **Ohne Befund.** |
| **N-6** | **`ac06b9a` Hunk 4** (*„ist die Form dieses Repos und keine Ausnahme"* → *„Die Zeilen nennen einen Sensor, den es noch nicht gibt —"*) | Verallgemeinerung aus **einem** Präzedenzfall entfernt; der Präzedenzfall und seine Zahlen bleiben. Nachgemessen: `ADR-0011` führt genau **fünf** `test/mutations/`-Zeilen (`0011-…:328,329,330,331,335`); `test/mutations/` endet vor den Span-Fällen bei `106-archgate-kanten-zyklus.sh`, die Span-Fälle beginnen bei `107-span-klemme-entfernt.sh`. Beide Zahlen korrekt. Die Kürzung ist hier eine **Verschärfung**. **Ohne Befund.** |
| **N-7** | **Gesamtbilanz `ac06b9a`** | Eine gemessene Eigenschaft entfernt (I-1, ohne Wirkung auf heutige Aussagen), null Festlegungen, null Alternativen, null Trigger, null Fitness-Function-Zeilen berührt; `git diff 52da26e ac06b9a` bestätigt es Hunk für Hunk. **Die Kürzung hat der ADR keine Substanz genommen.** |
| **N-8** | **Modul-7-Zitate und Zeilenverweise** (`:26-29`, `:46-93`, `:48`, `:48-67`, `:63-67`, `:105-110`, `:129`, `:130`, `:21`) | Alle neun am vollständig gelesenen Modul (133 Zeilen) geprüft: die drei Blockzitate sind verbatim, die Spannen decken genau das Behauptete (`:46-93` = §Werkzeug-Wahl von Überschrift bis Schlusssatz; `:48-67` = beide Fragen; `:130` nennt tatsächlich beide BF-Symptome; `:21` trägt die Dateikonvention `docs/plan/carveouts/CO-<NNN>-…`). **Ohne Befund.** |
| **N-9** | **Die Zahlen der ADR** | *sechs erklärte Abweichungen* (`harness/conventions.md:1066-1067` sagt es selbst) · *neun lebende Plandateien* (5 `open/` + 1 `next/` + 2 `in-progress/` inkl. Roadmap + 1 Welle-Plan = 9) · *ein Carveout* (`docs/plan/carveouts/` führt `CO-001` und ein README) · *vier `usage`-Zähler und drei `total*`-Werte* (`docs/user/claude-hooks-referenz.md:1571-1574`) · *vier gemessene Aufrufe, fünf undokumentierte Schlüssel* (`conventions.md:912-913`). Alle selbst nachgezählt. **Ohne Befund.** |
| **N-10** | **„die fünf, die überhaupt von Token sprechen" (`:60`)** | **Hier hätte die Wortgrenzen-Messung den falschen Befund erzeugt:** `grep -rilE '\btoken'` liefert **vier** Dateien, weil `\b` vor `tokens` in `input_tokens` nicht greift (`_` ist Wortzeichen). Ohne Wortgrenze sind es **fünf** — der fünfte ist `docs/plan/planning/open/slice-069-zahn-bindet-zusicherung.md:41` (`input_tokens`, Kontext Wächter-Bindung, also genau eine der drei in `:60-61` genannten „anderen Fragen"). An `7fc86eb`, `52da26e`, `ac06b9a` und `HEAD` identisch. **Die Zahl der ADR stimmt.** |
| **N-11** | **Vollständigkeitsaussage über die vendored Werkzeug-Doku (`:141`, Alternative C)** | *„nennt in ihrer ganzen Länge ein `usage`-Objekt und ein `totalTokens` **nur** für die `tool_response` des `Agent`-Werkzeugs (`:1571-1574`), für kein anderes Ereignis ein Nutzungsfeld"* — über alle **3.383** Zeilen gemessen: `usage` als Feldname genau einmal (`:1574`; die zwei weiteren Treffer sind `/docs/de/monitoring-usage`-URLs), `totalTokens` genau einmal (`:1571`), kein weiteres Token-Feld irgendwo. Die Zeilenspanne `1571-1574` trifft exakt `totalTokens`/`totalDurationMs`/`totalToolUseCount`/`usage`. **Ohne Befund — und die einzige echte Vollständigkeitsaussage der ADR hält.** |
| **N-12** | **Alternative E, Exporter-Detail** | *„das Werkzeug entfernt die Exporter-Variablen aus jedem Unterprozess, den es spawnt, einschließlich Hooks"* — `docs/user/claude-hooks-referenz.md:655`, sinngleich. **Ohne Befund.** |
| **N-13** | **Re-Evaluierungs-Trigger, zweiter Punkt (`:239-247`)** | *„auch die des verdrahteten `Stop`-Hooks nicht: der greift genau ein Feld heraus und protokolliert nichts"* — `.claude/hooks/stop-require-gates.sh:20-21` liest stdin und prüft genau `stop_hook_active`; keine Protokollierung der Payload in 60 Zeilen. **Ohne Befund.** |
| **N-14** | **Gate-Aussagen der Fitness Function (`:193-195`)** | `make comment-claims` deckt vier Pfad-Familien und kein Markdown (`Makefile:135`; die dort geführten fünf Globs `internal/*.go` und `internal/**/*.go` treffen unter git-Pathspec dieselbe Familie, die Aussage bleibt korrekt). `make docs-check` fährt genau `[links, anchors, ids, matrix, codepaths, spans]` (`.d-check.yml:18`); `check-lines` ist additive Härtung an `codepaths` (Zeilenspanne eines Pfad-Verweises), `citations` ist opt-out. **„Keine Behauptungen" trifft zu. Ohne Befund.** |
| **N-15** | **`ADR-0011`-Zitate** | Festlegung 1 Punkt 4 (*„leer und als leer erkennbar, nicht geraten"*, `0011-…:82-92`), Punkt 5 (*„begründet dokumentiert"*, `:93-95`), Festlegung 5 (*„das **Ob** … entscheidet der Change Request"*, `:211-221`), Alternative D (Transkripte, `:275`), Option B (OTel-Stack, `LH-QA-03`, *„ein Backend ohne Betreiber"*, `:271`), §Re-Evaluierungs-Trigger (Hook-Oberfläche, *„Audit, kein Betriebs-Monitoring"*). Alle sechs am Original geprüft. `ADR-0011` und `ADR-0003` sind **Accepted** (`docs/plan/adr/README.md:11,19`) — keine superseded Referenz. **Ohne Befund.** |
| **N-16** | **`LH-QA-01`-Wortlaut** | `spec/lastenheft.md:260-261`: *„Jeder emittierte Gate-Target läuft auf frischem Checkout; make gates grün out-of-the-box. Messmethode: Smoke-Test — Bootstrap in tmp-Repo, make gates, Exit 0."* Das Zitat in `:12-13` ist verbatim, die Messmethoden-Angabe korrekt. (Die *Rolle*, die die ADR der Anforderung gibt, ist **M-4** — nicht das Zitat.) **Ohne Befund.** |
| **N-17** | **Modul-15-Bezug** | `modul-15-observability.md:36-44` verlangt *„Summiere Input- und Output-Token pro `agent.role`"* samt Splitting-Regel für den Sammelposten — die ADR gibt das als *„Token-Bilanz je Rolle"* korrekt wieder, und Festlegung 3 (`:130-133`) hält die Splitting-Pflicht ausdrücklich offen statt sie mitzuentscheiden. **Ohne Befund.** |
| **N-18** | **Annahmen ↔ Re-Evaluierungs-Trigger** | `:105-108` nennt (a) Hook-Oberfläche, (b) Transkript-Ausschluss, (c) kein eigener Empfänger und sagt *„Alle drei stehen unten als Re-Evaluierungs-Trigger, jeder mit seiner ehrlichen Wirksamkeit"*. Geprüft: (a) → `:233-238`, (b) → `:248-251`, (c) → `:252-255`, jeder mit `*(feedforward — …)*`-Kennzeichnung. Der vierte Trigger (`:239-247`, ungemessene Fläche) ist die Einlösung der Zusage aus `:97-99`. **Vollständig, ohne Befund.** |
| **N-19** | **Trichter-Frage 1 (`:77-84`)** | *„dieses Repo führt genau **einen** Carveout, und mit dem teilt diese Abweichung keinen Geltungsbereich"* — `CO-001-bats-shell-lint.md` betrifft `shell-lint`/bats, kein Geltungsbereichs-Überschnitt. Die Nachbar-Abweichung 5 hat tatsächlich einen eigenen, durch Arbeit erreichbaren Trigger (`conventions.md:1225-1229`: die Abdeckungszahl aus `slice-066`) und ist per Guard verkleinert (`:1187-1195`). **Ohne Befund.** |
| **N-20** | **Alternative A (`:139`)** | *„sein Gegenstand sind nach `:105-110` die Carveouts, die nach `:21` unter `docs/plan/carveouts/` liegen, und der Closure-Trigger dieser Welle setzt genau diesen Umfang"* — geprüft gegen `modul-07:105-110`, `:21` und `welle-09:108-109`. Deckungsgleich mit M-2 des Vorgänger-Reviews, dort als Befund erhoben und hier korrekt eingearbeitet. **Ohne Befund.** |
| **N-21** | **Folgepflicht 1 und `MR-018`-Ist-Zustand** | *„trägt statt eines Auflösungs-Triggers das Verdikt permanent"* — `harness/conventions.md:1277-1282` trägt es bereits (*„Status: PERMANENT — übergeführt in `ADR-0012`"*, *„Hier steht deshalb kein Auflösungs-Trigger mehr"*). Modul 7 `:88` deckt das (*„ADR: Trigger fällt weg"*). **Ohne Befund.** |
| **N-22** | **Hard Rules und Formalia** | §3.2 (Lint-Suppression) und §3.3 (`git mv`) nicht berührt. §3.4: der Status bleibt **Proposed** in beiden Commits, keine Accepted-ADR überschrieben, keine Supersedes-Kette angefasst. §3.5: keine Gate-Lockerung — die ADR **fügt** zwei Wächter-Zeilen hinzu. Template-Konformität gegen `.harness/baseline/v3.5.2/templates/docs/plan/adr/NNNN-titel.template.md`: alle Pflicht-Abschnitte vorhanden, ≥ 3 Alternativen (sieben), `Schärft: —` mit Prozess-ADR-Begründung, Geschichte-Tabelle geführt, Index aktualisiert (`docs/plan/adr/README.md:20`). **Ohne Befund.** |

---

## Kategorie-Summary

| Kategorie | Anzahl | IDs |
|---|---|---|
| **HIGH** | **1** | H-1 |
| **MEDIUM** | **4** | M-1, M-2, M-3, M-4 |
| **LOW** | **3** | L-1, L-2, L-3 |
| **INFO** | **2** | I-1, I-2 |
| **Negativbefunde** | **22** | N-1 … N-22 |

**Zur Eskalations-Regel des Skills.** H-1, M-1, M-2 und M-3 sind **dieselbe Klasse**: eine
Deckung oder Messbarkeit wird benannt, die der benannte Träger nicht leistet — bei H-1 eine
Auswertung, die nicht messen kann; bei M-1 ein Slice, dessen DoD den Zahn nicht kennt; bei M-2
ein Sensor im Präsens, den es nicht gibt; bei M-3 eine Fundstelle, die die andere Größe führt.
Dieselbe Klasse ist in dieser Familie zuvor als `MEDIUM-1`/`M-1`/`M-2`/`L-4` aufgetreten
(`docs/reviews/2026-07-31-slice-060-dod3-review.md` und `…-runde-2.md`). Das ist die **vierte
Wiederholung** und damit deutlich über der Steering-Loop-Schwelle des Skills. Der Grund ist
strukturell und benannt: für Zuschreibungen in Markdown existiert in diesem Repo **kein** Sensor
— `comment-claims` deckt kein Markdown, `d-check` prüft Links und Zeilenspannen, keine Sätze —,
und `slice-070` weitet zwar den Prüfbereich, prüft aber weiterhin die *Existenz* des genannten
Sensors, nicht die *Wahrheit* des Satzes. Für ADR-Text kommt die Immutabilität ab *Accepted*
hinzu: hier ist die Prüfung nicht nur der einzige, sondern auch der **letzte** Sensor.

Bemerkenswert und ausdrücklich festgehalten: die vier zählbaren Vollständigkeits- und
Mengenaussagen der ADR (N-9, N-10, N-11) halten **alle** — einschließlich der schwierigsten,
einer Aussage über 3.383 Zeilen fremder Doku. Die Befunde liegen nicht in der Arithmetik,
sondern durchweg in Zuschreibungen an Träger.

---

## Verdikt

**NICHT KONFORM.**

Ein HIGH und vier MEDIUM blockieren nach Skill (*„HIGH und MEDIUM blockieren typischerweise"*).

Die Überarbeitung `52da26e` löst den blockierenden Vorgänger-Befund sauber: die Fitness Function
ist zweigeteilt, Festlegung 1 steht ohne Wächter auf `AGENTS.md` §3.6 statt auf einem
Dogfood-Fehlgriff, und Festlegung 2 bekommt zwei Zeilen mit benanntem Gegenbeispiel. Der
Modul-7-Trichter ist vollständig, in der Reihenfolge des Moduls und mit verbatim korrekten
Zitaten durchlaufen; Alternative G schließt die Lücke, die die Konsequenz sonst als „daran ist
nichts zu machen" gelesen hätte; die `Schärft`-Präzisierung und die Analogie-Kennzeichnung des
`:26-29`-Zitats sind beide zutreffend. Die Kürzung `ac06b9a` hat der ADR **keine Substanz
genommen** (N-1 … N-7): fünf verteidigende Rahmungen und eine Entwurfs-Forensik sind gefallen,
mitgefallen ist genau eine gemessene — und wahre — Eigenschaft der Normquelle, deren Anwendung
im Text unverändert steht (I-1).

Was der Annahme im Weg steht, ist **eine** Sache, und sie hat zwei Gesichter: **die ADR
verspricht Deckung, die ihre benannten Träger nicht leisten.** Am schärfsten in
`0012-haupt-kontext-ohne-token-bilanz.md:160-161`, wo die Entscheidung „der Haupt-Kontext hat
dauerhaft keine Zahl" im selben Aufzählungspunkt durch *„die Auswertung, die es messen könnte,
liegt in `open/`"* aufgehoben wird (H-1) — ein Satz, der ab *Accepted* nur noch per Supersedes
zu korrigieren wäre. Am folgenreichsten in der Fitness Function, deren zwei Zeilen auf
`slice-066` zeigen, während dessen DoD und Plan-Tabelle sie nicht führen (M-1) und der
stützende Verweis auf die dortigen Risiken die andere Größe trifft (M-3).

Über die Annahme entscheide ich nicht; ich stelle den Zustand fest. Die drei vom Architect selbst
als offen benannten Punkte **tragen** — mit einer Verschärfung und einer Ergänzung: die
`slice-066`-DoD-Pflicht ist keine Folgearbeit, sondern die Bedingung, unter der Festlegung 2
überhaupt eine Zusage im Sinne von `AGENTS.md` §3.6 ist (M-1); die vierte Belegart betrifft im
Welle-Plan drei Stellen statt einer, und der benannte Träger `slice-068` führt den Welle-Plan
nicht in seiner Plan-Tabelle (L-1); der Nebenbefund „drei gegen vier" ist unabhängig
nachgezählt und bestätigt (I-2).
