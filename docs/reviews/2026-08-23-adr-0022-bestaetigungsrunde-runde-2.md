# ADR-0022 (Proposed) — Bestätigungsrunde 2, nach dem zweiten Nachzug

- **Rolle:** Reviewer (Modul 10), frischer Kontext, anderes Modell als die zwei Vorrunden
- **Datum:** 2026-08-23
- **Gegenstand:** [`docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md`](../plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md),
  Status weiter *Proposed*, samt der ADR-0022-Zeile in [`docs/plan/adr/README.md`](../plan/adr/README.md)
- **Diff:** `0d2b36e..5ac9146` — selbst gemessen: `git diff --stat 0d2b36e..5ac9146` → **2** Dateien,
  **61** Insertionen, **26** Deletionen. `git status --porcelain` → leer; `git rev-parse HEAD` →
  `5ac9146…`.
- **Vorrunden:**
  [`2026-08-23-adr-0022-proposed-review.md`](2026-08-23-adr-0022-proposed-review.md) (1 HIGH · 2
  MEDIUM · 5 LOW · 4 INFO, *blockiert*),
  [`2026-08-23-adr-0022-bestaetigungsrunde.md`](2026-08-23-adr-0022-bestaetigungsrunde.md) (0 HIGH ·
  2 MEDIUM · 5 LOW · 3 INFO, *blockiert*)
- **Was diese Runde ist:** der Nachzug auf die zweite Runde stammt aus dem Haupt-Kontext, nicht von
  einem frischen Architect-Subagenten (im Commit-Text offen benannt). Zulässig nach Modul 8 — die
  Rolle bindet, nicht der Prozess —, aber Anlass zu erhöhter Skepsis dort, wo eine Formulierung
  einen Befund *adressiert*, ohne ihn zu *beheben*. Diese Runde übernimmt keinen der beiden
  Vorrunden-Verdikte ungeprüft und keine der beiden Gate-Aussagen aus der Commit-Message.

## Eingangs-Kontext (die fünf Pflicht-Punkte, Modul 10)

1. **Diff/Commit-Range:** `0d2b36e..5ac9146`, ein Commit, zwei Dateien (oben gemessen).
2. **Betroffene Anforderungen:** [`LH-FA-10`](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren)
   (Rang 1), `LH-FA-01`, `LH-FA-06`, `LH-FA-08`, `LH-FA-09`, `LH-QA-01`, `LH-QA-02`, `LH-QA-03`,
   `LH-QA-04`.
3. **Referenzierte aktive ADRs:** `ADR-0003`, `ADR-0007`, `ADR-0011`, `ADR-0012`, `ADR-0013`,
   `ADR-0016`, `ADR-0020`, `ADR-0021` — alle *Accepted*, alle gelesen.
4. **Hard Rules:** [`AGENTS.md`](../../AGENTS.md) §3.4 (Immutabilität ab *Accepted*), §3.6 (keine
   Zusage ohne rot gesehenes Gegenbeispiel), §3.7, §3.8 (Architect-Commit); [`MR-025`](../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert),
   [`MR-017`](../../harness/conventions.md#mr-017--default-regel-für-emittierte-prüfbereiche-fail-closed).
5. **Vorherige Findings am gleichen Modul:** die zwei MEDIUM, fünf LOW und drei INFO der
   Bestätigungsrunde, einzeln an ihrem Gegenstand nachgeprüft (nicht an der Ankündigung im
   Commit-Text), plus die Frage, ob der Nachzug irgendwo **gewachsen** ist statt **ersetzt** zu
   haben.
6. **Plan:** kein Slice — der Gegenstand ist eine Entscheidung. Der Plan-Bezug läuft über
   Folgepflicht 5 der ADR (Wellen-Plan nachziehen).

---

## Findings

### MEDIUM-1 — Die Fitness-Function hat zwei Zeilen, die exklusiv an `make full-smoke` hängen; die Mutate-Lücke ist nur an einer benannt

- **kategorie:** MEDIUM
- **quelle:** [`AGENTS.md`](../../AGENTS.md) §3.6 (*„gelistet heißt: wer keinen Fall in
  `test/mutations/` hat, ist unbewacht"*); Rest von MEDIUM-2 der Bestätigungsrunde
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:666`
  (Fitness-Zeile *„Der Träger schreibt im Ziel"*) gegen `:671` (Fitness-Zeile *„Die Auswertung
  meldet ihre Leere"*, die Zeile, die MEDIUM-2 der Vorrunde adressierte)
- **befund:** Die Vorrunde verlangte, dass die Zeile, die `[ADR-0021]` Folgepflicht 6 einlöst
  (`:671`), ihre eigene Unerreichbarkeit über `make mutate` nennt, *weil* der Mutations-Treiber für
  `full-smoke` kein Fehlschlag-Muster kennt. Der Nachzug tut das — und tut es **nur dort**. Die
  Schwester-Zeile `:666` (*„Der Träger schreibt im Ziel … Geschuldet, nicht geliefert"*) hängt
  strukturell identisch: ihre Make-Target-Spalte trägt ebenfalls ausschließlich `make full-smoke`
  (`sed -n '666p;671p' docs/plan/adr/0022-*.md` — beide Zeilen enden auf `` `make full-smoke` ``
  in der letzten Spalte, gelesen), und die Regel selbst kann nur an einem frisch gebootstrappten
  Ziel geprüft werden (Bootstrap → `git check-ignore` im Ziel), also ebenso wenig auf eine niedrigere
  Sensor-Stufe (`test`/`test-go`/`test-bats`) ausweichen wie `:671`. Der Mutations-Treiber
  (`sed -n '227,236p' harness/tools/mutate.sh`, gelesen) unterscheidet dabei nicht nach *Grund* der
  Zeile, sondern ausschließlich nach dem `# verify:`-String; die Lücke ist eine **Eigenschaft des
  Ziels** `full-smoke`, nicht der einen adressierten Zeile — exakt die Unterscheidung, die dieser
  Nachzug selbst für Folgepflicht 5 und Folgepflicht 7 nachträgt (*„Eigenschaft statt Adresse"*).
  Hier wendet er sie nicht auf sein eigenes MEDIUM-2 an.
- **gegenbeispiel:** Ein späterer Lauf implementiert den Träger-schreibt-Test aus `:666`, sieht das
  Rot einmal von Hand (Bootstrap in ein tmp-Repo) und versucht, einen Mutations-Fall mit
  `# verify: full-smoke` anzulegen — derselbe Abbruch wie bei `:671` vor diesem Nachzug
  (*„unbekanntes '# verify: full-smoke' — kein Fehlschlag-Muster definiert"*), nur ohne die
  Vorwarnung, die `:671` jetzt trägt. Der Fall bleibt ungelistet, `make mutate` meldet nichts, und
  niemand hat die ADR-Zeile als Grund dafür gelesen.
- **verifizierbar:** ja — `sed -n '666p;671p' docs/plan/adr/0022-*.md`,
  `sed -n '227,236p' harness/tools/mutate.sh`, `sed -n 's/^# verify: //p' test/mutations/*.sh | sort
  | uniq -c` (→ je einmal `ci-lint`, `smoke`), alle selbst gefahren; kein Gate deckt ADR-Semantik.

### INFO-1 — Die Kopplungs-Berufung auf ADR-0020 Folgepflicht 1 ist eine plausible, aber ausgedehnte Lesart

- **kategorie:** INFO
- **quelle:** [ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md) Folgepflicht 1
- **pfad:** `docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md:525-527`
- **befund:** Festlegung 8 schreibt jetzt: *„Was hier und dort zusammenhängt, hält
  [ADR-0020] Folgepflicht 1: der Beleg emittiert nichts, was der Dogfood nicht selbst fährt."*
  Folgepflicht 1 bindet wörtlich einen **Beleg** — ein emittiertes Artefakt/einen Report — an das,
  was hier erprobt ist (`sed -n '694,697p' docs/plan/adr/0020-*.md`, gelesen: *„Was ins Ziel geht,
  ist hier erprobt"*). Die Berufung hier trägt sie auf eine andere Ebene: nicht ein Artefakt,
  sondern eine **Aussage der ADR selbst** (*„diese Entscheidung sagt … nichts zu, was jene nicht
  schon über die Mechanik gesagt hat"*) wird an dieselbe Disziplin gebunden. Die Richtung der
  Argumentation ist in sich stimmig — beide Ebenen benutzen dasselbe Agenten-Werkzeug, und die
  Beschränkung auf das, was der Dogfood belegt, ist plausibel dieselbe Disziplin auf einer anderen
  Flughöhe —, aber es ist eine Analogie, kein wörtliches Zitat, das die behauptete Kopplung trägt.
- **verifizierbar:** ja — Folgepflicht 1 gelesen; keine Gate-Prüfung für ADR-Semantik.

---

## Negativbefunde (geprüft, ohne Befund)

- **MEDIUM-1 der Bestätigungsrunde (Preis statt Ersparnis) — echt geschlossen, nicht nur
  umformuliert.** Der neue tragende Grund (*„Der tragende Grund ist der Preis"*, `:311-320`) trennt
  G von F entlang eines **echten** Unterschieds: F kostet einen committeten Platzhalter je Blob
  (zwei Blobs wegen Schreiber+Auswertung aus `LH-FA-10`) und bindet den Produkt-Bau an den
  Emitter-Bau derselben Plattform — Kosten, die G nicht trägt. Gegen die Alternativen-Tabelle
  gehalten (`sed -n '563,564p'`, gelesen): der F-Zeilen-Contra (*„der Produkt-Bau hängt am
  Emitter-Bau derselben Plattform, und die Einbettung verlangt die Datei zur Übersetzungszeit
  jeder Stufe … Gleiche Eigenschaften, höherer Preis"*) und der G-Zeilen-Contra (*„der abgelegte
  Träger trägt die Bootstrap-Fähigkeit mit sich, die Alternative F konstruktiv ausschlösse"*)
  decken die neue Formulierung Wort für Wort; die Index-Zeile trägt dieselbe Aussage
  wortgleich. Kein *„kein Aufwandsvergleich"* mehr im Text (`grep -n
  'Aufwandsvergleich\|Ersparnis\|keine Einzigkeit' docs/plan/adr/0022-*.md docs/plan/adr/README.md`
  → leer, selbst gefahren). Die Trigger-Korrektur (*„fällt Annahme (a), fällt sie für F ebenso"*,
  `:322-326`) ist an F's eigener Pro-Spalte belegt (*„dieselben vier Konstruktions-Eigenschaften
  wie G"*, `:563`): ein zur Produkt-Übersetzungszeit eingebettetes Binär teilt zwangsläufig die
  Plattform-Bindung des Produkts, also auch die Verwundbarkeit derselben Annahme. Der Trigger unten
  (`:701-707`) und die Konsequenzen-Zeile (`:578-579`, ein **anderer** Trigger — Latenz statt
  Plattform) widersprechen sich nicht: verschiedene Auslöser, verschiedene Antworten, beide intern
  konsistent. Kein Quellen-Zwang für „Aufwand ist kein legitimer tragender Grund" gefunden
  (Modul 4 verlangt nur *„jede Alternative mit Trade-off"*, keine Rangfolge unter Trade-off-Arten).
- **MEDIUM-2 der Bestätigungsrunde — das „Benennen" ist als Muster in Ordnung, nur nicht
  vollständig.** Siehe MEDIUM-1 oben: die Form (Sensor-Lücke im Fließtext der Fitness-Zeile
  benennen statt sie stillschweigend vorauszusetzen) folgt demselben Muster, das die ADR bereits an
  anderer Stelle für fehlende Sensoren fährt (`:637`: *„ein Sensor darüber existiert nicht"*, ohne
  eigene Folgepflicht) — als Dokument-Konvention für eine *Proposed*-ADR tragfähig. Der Rest ist
  Vollständigkeit, nicht Form, und dafür siehe MEDIUM-1.
- **LOW-1 der Bestätigungsrunde (Prämisse „vier Regelblöcke" ohne Reproduzierbarkeits-Klammer) —
  behoben.** `:137-140` trägt jetzt Tag (`v3.5.2`), Dateiname (`modul-15-observability.md`), die
  vier Abschnittsnamen und ein Kommando. Selbst gefahren:
  `grep -n '^### ' .harness/baseline/v3.5.2/regelwerk/modul-15-observability.md` → **sieben**
  Treffer, davon genau die vier benannten (`Span-/Audit-Attribut-Regeln`, `Token-Attributions-Regeln`,
  `Cache-Counter-Regeln`, `Doku-Konsistenz-Drift-Regeln`) mit Regelblock-Charakter — die Aussage
  stimmt und ist jetzt gegen einen Tag nachprüfbar.
- **LOW-2 der Bestätigungsrunde (Abwesenheits-Wächter-Zuschreibung zu breit) — behoben.** `:333-337`
  schreibt jetzt nur noch das erste Glied (Sprach-Fragment/`blocked/`) dem bestehenden Wächter zu
  und sagt explizit, dass für Manifest und Skelett nichts hält. Selbst gefahren:
  `grep -rn 'go\.mod\|Skelett\|Manifest' internal/emit/*_test.go` → leer, Exit 1;
  `sed -n '1,57p' internal/emit/enforce_test.go` bestätigt, dass `TestEnforce_EmitsAllMechanicFiles`
  ausschließlich `blocked/`-Abwesenheit prüft.
- **LOW-3 der Bestätigungsrunde (zwei komplementäre Fitness-Zeilen ohne genannten Zweig) —
  behoben.** `:669` benennt jetzt den Zweig aus Festlegung 5(a) explizit und ordnet die Feldliste
  diesem Zweig zu (*„Die Feldliste entsteht mit dem Träger … und teilt darum seinen Zweig"*) — gegen
  Festlegung 5(a) (`sed -n '419-426p'`) und Festlegung 7 (*„aus dem Träger erzeugt"*) gehalten,
  beide stimmen mit der neuen Zeile überein.
- **LOW-4 der Bestätigungsrunde (Folgepflicht 5 zählt die Plan-Stellen zu klein) — behoben, und das
  mitgegebene Kommando trägt.** Selbst gefahren:
  `grep -niE 'permanent nicht emittiert|solange er offen ist'
  docs/plan/planning/welle-11-traeger-aussage.md` → **4** Treffer an genau den vier Zeilen, die die
  Vorrunde gemessen hatte (`:44` Modul 15, `:46` Modul 8/Rollen-Trennung, `:127` §1, `:261` §6). Die
  neue Fassung (*„Betroffen ist **jede** Zeile … also auch die Rollen-Trennung aus Festlegung 2 …
  und **jede** Stelle …"*) ist eine Eigenschaft, keine Adresse, und die Zahl steht mit ihrem
  Kommando nach `MR-025` neben sich, ausdrücklich als *„kein Erwartungswert"* deklariert.
- **LOW-5 der Bestätigungsrunde (Folgepflicht 7 nennt nur eine Index-Zeile) — behoben.** Die neue
  Fassung (*„Betroffen ist **jede** Index-Zeile, deren Zusammenfassung eine hier revidierte Aussage
  trägt"*) nennt die ADR-0021-Zeile jetzt namentlich als Beispiel und zitiert ihren Schluss-Satz.
  Verbatim-Gegenprobe (nach [ADR-0016](../plan/adr/0016-verweis-traegt-tag-und-zitat.md) Festlegung
  2 — Wortlaut ohne Auszeichnung, Whitespace normalisiert, nicht die Roh-Bytes): der Satz *„Die
  emittierte Ebene ist nicht berührt"* trägt in `docs/plan/adr/README.md` das Markdown-Fettungs-Sternchen
  **innerhalb** der Phrase (*„Die **emittierte Ebene ist nicht berührt**"*) — ein roher `grep -qF`
  ohne Normalisierung fände ihn darum **nicht**; nach Sternchen-Entfernung und
  Whitespace-Normalisierung ist er `True` (selbst mit einem kleinen Python-Snippet nachgefahren).
  Kein neues Mess-Kommando dieser Runde ist an einem fehlgeschlagenen Glob oder einer zu kurzen
  Liste gescheitert (LOW-4s Kommando lief sauber, Exit 0, 4 Treffer).
- **INFO-1 der Bestätigungsrunde (Rückrichtungs-Äquivalenz zu eng gefasst) — sachlich behoben, die
  neue Berufung selbst ist jetzt INFO-1 dieser Runde.** Die beiden zitierten Trigger-Phrasen (*„wirkt
  nur, wenn jemand sie liest"*, *„der Slice, der ein weiteres Ereignis verdrahtet"*) sind gegen
  [ADR-0021](../plan/adr/0021-verbrauchs-achse-je-rolle-ohne-quelle.md) `:759-767` verbatim geprüft
  und stimmen; die Kopplungs-Berufung selbst ist oben als eigenständiges INFO geführt.
- **Neue Klassen: gewachsen statt ersetzt, Review-Geschichte im Text.** `git diff 0d2b36e..5ac9146`
  über beide Dateien nach Befund-IDs/Runden-Verweisen durchsucht
  (`grep -E '^\+' | grep -niE 'runde|HIGH-[0-9]|MEDIUM-[0-9]|LOW-[0-9]|INFO-[0-9]|hier stand'`) →
  ein Treffer, *„der Nachzug"* in Folgepflicht 7 (*„dort kostet der Nachzug eine Zeile, keine
  Folge-ADR"*) — dieselbe generische Verwendung von *nachziehen/Nachzug* für „downstream Artefakt
  korrigieren", die die ADR an mehreren vorbestehenden Stellen schon führt (Folgepflicht 3, 5, 8);
  kein Verweis auf diesen oder einen früheren Review-Lauf. 61 Insertionen gegen 26 Deletionen an
  acht zusammenhängenden Blöcken, keine Stelle mit unverändert stehen gebliebenem Fehl-Text neben
  neuem Text (jede korrigierte Passage ersetzt, keine daneben gestellt) — außer dem oben
  gemeldeten MEDIUM-1, wo die Korrektur an einer von zwei betroffenen Stellen fehlt, statt dort
  auch zu wachsen.
- **§3.4 — ADR-0020 und ADR-0021 byte-identisch zum Vorzustand.** `git diff --stat 0d2b36e..5ac9146
  -- docs/plan/adr/0020-*.md docs/plan/adr/0021-*.md` → leer; Blob-Hashes vor/nach je identisch
  (`1bf3152…`, `99b2480…`), selbst gefahren.
- **§3.8 — nur Architect-Artefakte.** `git diff --name-status 0d2b36e..5ac9146` → `M` auf genau zwei
  Dateien, beide `docs/plan/adr/**`; Commit-Message nennt die Rolle in der ersten Zeile.
- **Keine Slice-/Wellen-IDs als normativer Anker.** `grep -niE 'slice-[0-9]|welle-[0-9]|slice [0-9]'`
  über beide geänderten Dateien → ein Treffer, ein Dateipfad
  (`docs/plan/planning/welle-11-traeger-aussage.md`) innerhalb des Folgepflicht-5-Kommandos — ein
  Verweis auf das nachzuziehende Plan-Artefakt, keine Slice-ID als Entscheidungs-Anker.
- **Fitness-Zeilen-Menge — die ADR hat genau zwei `full-smoke`-Zeilen, geprüft.**
  `grep -n 'full-smoke' docs/plan/adr/0022-*.md` → zwei Treffer (`:666`, `:671`); die Lücke
  betrifft strukturell beide (MEDIUM-1 oben), die ADR sagt das nur für eine.
- **`make gates` und `make docs-check` — selbst gefahren, beide bestätigt, nichts aus der
  Commit-Message übernommen.** `make docs-check` → `d-check: 353 Datei(en) geprüft, 0 Befund(e)`,
  Exit 0. `make gates` → Exit 0 (`echo $?` nach dem Lauf geprüft), `ok 143` als letzte bats-Zeile,
  `grep -c '^ok '` über den vollen Log → **143**, Go-Test-Pakete alle `ok`, letzter Schritt
  `span-check: Emitter vorhanden, ein Span geschrieben, Ablageort git-ignoriert`.
- **Verbatim-Gegenprobe auf alle Zitate, per Here-String, nicht per Pipe.** Stichprobenweise
  gegengeprüft: die Rollen-Regeln-Quote (`modul-08-agentenrollen.md:62`, unverändert seit Runde 1,
  weiterhin korrekt), die beiden ADR-0021-Trigger-Phrasen, der Folgepflicht-7-Index-Satz (nach
  ADR-0016-Normalisierung). Kein Zitat mit abweichendem Wortlaut gefunden.
- **Festlegungen 1–8 vollständig und sequenziell, keine Nummern-Lücke durch den Nachzug.**
  `grep -nE '^\*\*[0-9]\.' docs/plan/adr/0022-*.md` → acht Treffer, 1 bis 8, an denselben
  Zeilen-Bereichen wie vor dem Diff.

---

## Summary

| Kategorie | Anzahl |
|---|---|
| HIGH | 0 |
| MEDIUM | 1 |
| LOW | 0 |
| INFO | 1 |

Stand gegenüber der Bestätigungsrunde: HIGH 0 → **0**, MEDIUM 2 → **1** (eines echt geschlossen,
eines als Rest wiedereröffnet — nicht dasselbe Argument wie vorher, sondern eine unvollständige
Anwendung des eigenen Nachzug-Musters), LOW 5 → **0** (alle fünf behoben, keine neuen), INFO 3 → 1
(zwei sachlich erledigt, eine neue Beobachtung zur neu eingesetzten Formulierung).

## Verdikt

**Nicht frei für die Annahme — blockiert.**

Der zweite Nachzug ist überwiegend eine echte Reparatur, keine Umformulierung. Das ehemalige
MEDIUM-1 (Preis-Grund unterscheidet G nicht von F) ist tatsächlich behoben — der neue tragende
Grund ist ein echter, an der Alternativen-Tabelle gedeckter Trade-off, und kein Quellen-Zwang
verbietet einen Preis-Grund an dieser Stelle. Alle fünf LOW sind an ihrem Gegenstand geprüft und
behoben, einschließlich der beiden Mess-Kommandos, die in den Vorrunden je einmal gescheitert
waren (Glob-Fehler, zu kurze Liste) — die diesmal mitgegebenen Kommandos laufen sauber und liefern
die gemeinte Menge, nicht nur eine Zahl.

**Was die Sperre hält, ist der Rest von MEDIUM-2.** Der Nachzug benennt die
Mutations-Treiber-Lücke für `full-smoke` — korrekt und mit funktionierendem Kommando — aber nur an
der einen Fitness-Zeile, die die Vorrunde geprüft hatte. Die zweite, strukturell identische
`full-smoke`-Zeile (*„Der Träger schreibt im Ziel"*) trägt exakt dieselbe Einschränkung und bleibt
stumm. Das ist dieselbe Fehlerklasse — *Adresse statt Eigenschaft* —, die dieser Nachzug an zwei
anderen Stellen (Folgepflicht 5, Folgepflicht 7) gerade selbst korrigiert hat, hier aber nicht auf
sein eigenes MEDIUM-2 angewandt. Der Befund ist eng: ein Satz an der `:666`-Zeile (oder eine
gemeinsame Anmerkung über beide `full-smoke`-Zeilen) schließt ihn.

**Das eine INFO trägt keine Sperre.** Die neu eingesetzte Berufung auf [ADR-0020](../plan/adr/0020-emittierte-modul-15-regeln.md)
Folgepflicht 1 zur Begründung der Kopplung zwischen Dogfood- und Adopter-Ebene ist eine plausible,
aber ausgedehnte Lesart einer Regel, die wörtlich einen anderen Gegenstand (Belege, nicht
ADR-Aussagen) bindet — dokumentationswürdig, nicht blockierend.
