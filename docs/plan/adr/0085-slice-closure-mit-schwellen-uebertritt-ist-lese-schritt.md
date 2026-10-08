# ADR-0085: Die Slice-Closure, die einen Eintrag über die 3×-Schwelle hebt, ist für ihn ein Lese-Schritt

**Status:** Proposed

**Datum:** 2026-10-08

**Autor:** Architect (ai-harness-init-Team, pt9912)

**Bezug:** [ADR-0049](0049-ausgang-traegt-die-benannte-luecke.md) (Festlegung 3: `offen` über der
Schwelle ist **zwischen zwei Lese-Schritten** zulässig),
[ADR-0069](0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
(Folgepflicht 2: gezählt werden Dateien `evidence/*.md`),
[`LH-QA-01`](../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6),
[`MR-051`](../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)
(Setzung 2).

**Schärft:** — Prozess-ADR ohne Spec-Stratum: sie legt den Zeitpunkt eines Lese-Schritts fest, nicht
den Inhalt eines Spec-Dokuments.

**Regeln:** Baseline-Regelwerk `modul-04-adrs.md` §Ziel-Form: ADR (MADR); `modul-06-roadmap.md`
§Das Beobachtungs-Register und §Wann Arbeit eine Welle braucht; `modul-08-agentenrollen.md`
§Rollen-Sequenz für eine Welle (Zeile 3b); `modul-11-verification.md` §Fitness Function ohne
Standard-Tool.

---

## Kontext

[ADR-0049](0049-ausgang-traegt-die-benannte-luecke.md) Festlegung 3 lässt `offen` über der Schwelle
bis zum nächsten Lese-Schritt zu. Wann der stattfindet, sagt `modul-06-roadmap.md`: in einem Repo
**mit** Wellen die Welle-Closure, in einem **ohne** die Slice-Closure; *wellenlos* ist eine Eigenschaft
des Repos, nicht des Slice. Dieses Repo führt Wellen (`ls docs/plan/planning/welle-*.md` → zwei offene
Welle-Dateien, gelesen 2026-10-08, keine Erwartung) und daneben wellenlose Slices. Der Bestand liest
den Zeitpunkt zweifach: `BEO-ALL/mutations-fall-nennt-einen-test-die-mutation-faerbt-mehrere/state.md`
nennt die Slice-Closure als Lese-Schritt, `BEO-ALL/span-feld-bedeutung-wechselt-ohne-fassungs-angabe/state.md`
die nächste Welle-Closure.

Der Wächter `make register-ausgang` meldet jeden Eintrag ab drei Belegen mit `offen`:

```sh
bash harness/tools/register-ausgang.sh   # 233 Eintraege, 65 ueber der Schwelle, 8 Befund(e) — rc=1
```

Gelesen 2026-10-08, keine Erwartung. Als Gate wäre er schärfer als ADR-0049, solange eine
Slice-Closure einen dritten Beleg anlegen darf, ohne den Ausgang zu setzen. `modul-11` nennt ein
solches Gate falsch, weil es eine Entscheidung prüft, die niemand getroffen hat.

## Entscheidung

**1. Eine Slice-Closure ist ein Lese-Schritt für jeden Eintrag, dem sie einen Beleg anlegt, wenn der
Eintrag danach mindestens drei Belege hat und `offen` steht.** Der Ausgang (ADR-0049 Festlegung 1/2)
steht im selben Commit wie der Beleg, vor dem `git mv`. Den Ausgang entscheidet der Zug
Planner → Architect → Planner (`modul-08` Zeile 3b) bei dieser Closure und nicht erst bei der
nächsten Welle-Closure. Der Anker heißt `seit slice-<Kennung>`.

**2. Die Welle-Closure bleibt Lese-Schritt über alle Einträge** (ADR-0049 Festlegung 3 gilt
unverändert). Nach Festlegung 1 findet sie nur noch Einträge, die ein Vorgang ohne Slice-Closure über
die Schwelle gehoben hat.

**3. Damit kennt `offen` über der Schwelle kein Fenster, das über einen Commit hinausreicht.**
`make register-ausgang` darf ohne Zeit-Bedingung urteilen und in `make gates` laufen. Seine Bindung
nennt [ADR-0049](0049-ausgang-traegt-die-benannte-luecke.md) für die Regel, diese ADR für den
Zeitpunkt und [ADR-0069](0069-beleglose-register-verzeichnisse-sind-ein-befund-der-paarung-keine-ausnahme.md)
nur für die Zählung.

**Kein Supersedes.** ADR-0049 legt fest, *dass* `offen` zwischen zwei Lese-Schritten zulässig ist.
Sie sagt nicht, *wann* die Lese-Schritte stattfinden. Diese ADR fügt einen Zeitpunkt hinzu und
widerspricht keinem Satz.

## Verglichene Alternativen

| Option | Pro | Contra |
|---|---|---|
| A — Wächter mit Übergangsfenster: Befund erst, wenn nach dem dritten Beleg eine Welle-Closure lag | trifft ADR-0049 wörtlich | liest git-Historie und Welle-Datum; das ist nicht hermetisch. In wellenarmen Phasen bleibt das Fenster offen, und so ist der heutige Bestand von acht entstanden |
| B — Wächter bleibt Werkzeug, die Welle-Closure fährt ihn | keine neue Norm | kein Gate, obwohl die DoD des Slice eines verlangt; offene Ausgänge liegen bis zur nächsten Welle |
| C — Ausnahmeliste der zulässig offenen Einträge | sofort grün | eine zweite Fassung des Bestands, und der Plan schließt eine solche Liste aus |
| **D — gewählt: die Slice-Closure mit Schwellen-Übertritt ist Lese-Schritt** | ein einziger Zeitpunkt; der Wächter kann gaten; der Zug ist derselbe wie im wellenlosen Repo | jede solche Closure braucht den Architect-Zug |

## Konsequenzen

- Positiv: Der Zeitpunkt hat eine einzige Lesart. Der Register-Wächter wird ein Gate, ohne schärfer
  als seine Entscheidung zu sein.
- Negativ: Eine Slice-Closure mit Schwellen-Übertritt kostet einen Architect-Zug. Ein Commit, der
  den Beleg ohne Ausgang anlegt, färbt `make gates` rot. Das ist gewollt.

## Fitness Function (falls maschinell prüfbar)

| Tooling | Regel | Make-Target |
|---|---|---|
| `harness/tools/register-ausgang.sh`, Fälle in `test/register-ausgang.bats` | ein Eintrag mit drei Dateien `evidence/*.md` und `**Stand:** offen` → Exit 1 mit seinem Namen; ein Ausgang → still | `make register-ausgang`, nach Accept und bereinigtem Bestand in `make gates` |

**Lücke:** Kein Sensor prüft, ob der Ausgang im **selben** Commit wie der Beleg steht. Der Gate-Lauf
auf dem Closure-Commit prüft nur dessen Endstand.

## Re-Evaluierungs-Trigger

- Das Repo gibt den Wellen-Betrieb auf. Dann ist Festlegung 1 der Default der Baseline, und diese
  ADR entfällt.
- Eine Beobachtung *„Slice-Closure wartet auf den Architect-Zug"* erreicht 3× im Register. Dann
  Option A neu prüfen.
- Ein Baseline-Stand legt den Zeitpunkt des Lese-Schritts anders fest.

### Der Acceptance-Trigger

Der Auftraggeber nimmt an ([ADR-0040](0040-accept-uebergang-nennt-den-beleg-seines-triggers.md) Festlegung 1). Bis dahin bleibt `make register-ausgang` ein
Werkzeug (`kein Gate`).
