# Verifikation `slice-stilllegungs-kanten-sind-gemessen`: DoD 1 und 2 erfüllt, DoD 3 für den Risiko-Ausgang offen

**Rolle:** Verifier · **Datum:** 2026-09-17 · **Geprüfter Stand:** `28aaca3d`. Der Arbeitsbaum war
vor diesem Bericht sauber (`git status --short | wc -l` → `0`). Geprüft ist die Kette
`cbb49bf2..28aaca3d`, also der Claim und alles danach (`git log --oneline cbb49bf2..28aaca3d | wc -l`
→ `7`). **Verifikations-Art:** DoD- und ADR-Konformität gegen den tatsächlichen Baum
(`v6.9.0` · `regelwerk/modul-11-verification.md`). Das ist kein Review.

**Eingang:**

- der Slice-Plan `slice-stilllegungs-kanten-sind-gemessen` §1 bis §8, Stand im Pfad `in-progress/`;
- die Umsetzung in [`harness/sensors/slice-mv.md`](../../harness/sensors/slice-mv.md) und
  [`harness/sensors/docs-check.md`](../../harness/sensors/docs-check.md), Commits `b97bc8e1` und
  `3aae5fef`;
- der Review-Report vom 2026-09-17 und seine Nachprüfung (Verdikt: bereit, zwei Übergaben an den
  Planner). Ihre Messungen sind gelesen und nicht wiederholt;
- die Folge-Slices `slice-mv-zieht-praefixlose-geschwister-verweise-nach` und
  `slice-mv-kanten-nach-done-sind-bewacht`, beide in `open/`;
- [ADR-0056](../plan/adr/0056-ziel-fassung-regiert-den-sprung-v690.md) (`Accepted`), §Was diese
  Festlegung nicht tut und §Re-Evaluierungs-Trigger;
- als Maßstab `v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Ein Slice, dessen Gegenstand ein
  anderer übernimmt, und §Offene Risiken werden bei Closure aufgelöst.

---

## 1. Ergebnis je DoD-Punkt

| DoD-Punkt | Status | Beleg |
|---|---|---|
| **1** — `make slice-mv` für beide Kanten gemessen | **erfüllt** | Die Tabelle in `slice-mv.md` §Kanten nennt je Kante den Exit-Code, den Move-Commit, die eingehenden und die ausgehenden Verweise sowie die präfixlosen Verweise von Geschwistern. Jede Kante ist in zwei Kontexten gemessen: `open → done` vom Implementer und in diesem Bericht (§2), `next → done` vom Implementer und im Review. Die Werte stimmen überein. |
| **2** — `make docs-check` über der Ziel-Form gemessen, mit Gegenbeispiel | **erfüllt, wie geschrieben** | Die Tabelle in `docs-check.md` §Ein stillgelegter Slice in `done/` nennt die Grund-Codes `closure-note-thin` und `closure-note-placeholder`. Das Gegenbeispiel ohne `Gegenstand:`-Zeile bleibt still und ist als Lücke benannt. Der Digest `e31a372b…` ist genannt und gleicht dem Pin (`grep -n 'DCHECK_DIGEST' d-check.mk` → Z. 66, derselbe Wert). `closure-note-placeholder` ist in §2 nachgemessen. Die Lage „Risiko ohne Ausgang" fehlt; das verlangt der DoD-Punkt nicht, wohl aber DoD 3 (§3). |
| **3** — jede Kante hat ihren Ausgang in der Sensor-Datei, jede Lücke eine Adresse | **teilweise** | Erfüllt für die Ausführung durch das Werkzeug, für `Gegenstand:` und für den Wächter (§4). **Offen für das dritte Element der Form, den Risiko-Ausgang:** Die Tabelle führt es nicht, und für die Lücke steht keine Adresse da (§3). |
| `make gates` grün über dem Liefer-Stand | **erfüllt** | `make gates` über dem sauberen Stand `28aaca3d` → EXIT 0, `d-check: 1527 Datei(en) geprüft, 0 Befund(e)`. |
| Review durchgeführt, Report liegt vor | **erfüllt** | zwei Reports vom 2026-09-17 unter `docs/reviews/`, beide aus einem Reviewer-Kontext |
| Doku-Update nur in Liefer-Punkt 3 | **erfüllt** | `git diff --stat cbb49bf2..28aaca3d` nennt außer den zwei Sensor-Dateien nur Planungs-Artefakte (Plan, zwei Folge-Slices, Ruhe-Marker der Roadmap) und die zwei Reports. |
| Closure-Notiz, Register, Risiko-Ausgänge, Paarungen | **offen, Planner** | Das sind Closure-Pflichten ([`AGENTS.md`](../../AGENTS.md) §3.10). §7 steht auf „offen bis zur Closure". |
| Reconciliation-Register | entfällt | wie im Plan begründet |

## 2. Eigene Messung (bewusstes Brechen an einer Wegwerf-Kopie)

**Aufbau.** `git archive HEAD` am Stand `28aaca3d` in eine Kopie außerhalb des Repos, dort
`git init`, `user.name`/`user.email` lokal gesetzt, kein `core.hooksPath`
(`git config --get core.hooksPath` → Exit 1). Gemessen ist gegen d-check
`@sha256:e31a372b66dbde26305982424854cfce7c9ab7ce555a94debeee7ee26e6d4641`.

**Kante:** `open → done`. Diese Kante hat allein der Implementer gemessen, der Review nahm die andere.
**Geber:** `slice-072-adr-verweist-nicht-auf-lifecycle`, aus dieser Zählung gewählt:

```sh
P=docs/plan/planning; S=slice-072-adr-verweist-nicht-auf-lifecycle
grep -n -F "]($S.md" $P/open/*.md                        # 3 Treffer, alle in slice-075-regelwerk-verweis-linkpflicht
git grep -l -F "open/$S.md" -- docs | wc -l             # 7 Dateien mit Präfix-Verweis
```

Der Geber hat außerdem zwei präfixlose Ziele auf Geschwister in `open/`.

Vor dem Wechsel ist in §7 der Stilllegungs-Inhalt committet: `Gegenstand:` *übernommen von*, fünf
Risiken mit Ausgang und vier Satzenden. Die Liefer-Punkte bleiben leer.

| Lage | Kommando | Ergebnis |
|---|---|---|
| Ausgangsstand der Kopie | `make docs-check; echo $?` | `0`, `1527 Datei(en) geprüft, 0 Befund(e)` |
| Kante über das Werkzeug | `make slice-mv SLICE=$S TO=done; echo $?` | `0`; `eingehend: 7 Datei(en) mit Verweisen nachgezogen`, `ausgehend: 2 präfixloses Ziel(e) in der bewegten Datei auf ../open/ umgehängt` |
| Move-Commit | `git show --numstat --format='%s' -M HEAD~1` | `0	0	docs/plan/planning/{open => done}/…`, also ein reiner Rename |
| Nachzugs-Commit | `git show --numstat --format='%s' HEAD` | 8 Dateien, darunter `done/**`, `open/**` und `docs/reviews/**`; die zwei Ziele lauten danach `../open/slice-069-…` und `../open/slice-070-…` |
| nach dem Werkzeug | `make docs-check; echo $?` | **`2`** (`d-check.mk:79 … Fehler 1`), `3 Befund(e)`: `slice-075-…:113`, `:176` und `:240`, jeweils `target-missing` mit dem blanken Dateinamen des Gebers |
| **Lage R1:** die Risiko-Zeile in §7 ohne Ausgang | `make docs-check` | dieselben 3 Befunde, `diff` der Befundlisten leer, **keiner** zum Geber |
| **Lage R2:** die Risiko-Zeile in §7 fehlt ganz | `make docs-check` | dieselben 3 Befunde, `diff` leer, **keiner** zum Geber |
| die 3 präfixlosen Verweise von Hand auf `../done/` gesetzt | `make docs-check; echo $?` | **`0`**, `1527 Datei(en) geprüft, 0 Befund(e)` |
| **Lage D:** `Gegenstand:` als Vorlagen-Platzhalter, `placeholder` aus | `make docs-check; echo $?` | `0`, `0 Befund(e)` |
| **Lage E:** derselbe Platzhalter, `placeholder: true` in der `.d-check.yml` der Kopie | `make docs-check; echo $?` | `2`, `2 Befund(e)`; einer davon auf dem Geber: `…:202  docs/plan/planning/done  closure-note-placeholder  Closure-Notiz trägt einen unausgefüllten Platzhalter <Grund>` |

**Was das bestätigt.**

- Die Zeile `open → done` der Tabelle in `slice-mv.md` gilt am Stand `004335cc` von
  `harness/tools/slice-mv.sh` (`git log -1 --format=%h -- harness/tools/slice-mv.sh` → `004335cc`).
- „Nach dem Werkzeug bleiben **allein** die präfixlosen Verweise … rot" gilt: Ohne sie ist der Lauf
  grün.
- Die Aussage in `docs-check.md` „Ziel-Form vollständig → keine Meldung" gilt, ebenso die zwei
  Platzhalter-Zeilen (D, E). `(<Grund>)` in der Tabelle ist die gelesene Meldung.
- **Neu gemessen sind R1 und R2:** Einen fehlenden Risiko-Ausgang meldet kein aktives Modul.

## 3. F-7: Trägt die DoD die fehlende Lage „Risiko ohne Ausgang"?

**DoD 2 trägt es.** Der Punkt verlangt eine Messung über der vollständigen Ziel-Form, die
Risiken mit Ausgang einschließt. Als Gegenbeispiel verlangt er ausdrücklich nur die fehlende
`Gegenstand:`-Zeile. Beides steht in der Tabelle.

**DoD 3 trägt es nicht.** Nach dem Punkt steht die Grenze in der Sensor-Datei, wenn ein Werkzeug
die Kante nicht trägt, und die Lücke hat eine Adresse. Zwei Dinge fehlen:

1. **Die Aussage ist breiter als ihre Tabelle.** `docs-check.md` definiert die Form der Stilllegung
   mit drei Elementen: leere Liefer-Punkte, `Gegenstand:` und ein Ausgang für jedes Risiko. Dann
   folgert die Datei: *„Die Form der Stilllegung liest dagegen kein aktives Modul."* Gemessen sind
   in der Tabelle aber nur zwei der drei Elemente. Für das dritte war die Folgerung unbelegt
   ([`AGENTS.md`](../../AGENTS.md) §3.6). Sie stimmt, das zeigen R1 und R2 in §2. Der Beleg steht
   aber hier und nicht an dem Ort, den der nächste Lauf liest.
2. **Die Lücke hat keine Adresse.** Die Ziel-Fassung nennt es urteilsfrei, dass zu jedem Risiko ein
   Ausgang dasteht. Welches Werkzeug das prüft, überlässt sie dem Repo, nicht aber, *dass* eines
   prüft (`v6.9.0` · `regelwerk/modul-05-planning-harness.md` §Offene Risiken werden bei Closure
   aufgelöst). Im gepinnten Stand prüft es kein aktives Modul (R1, R2). `docs-check.md` gibt
   Adressen für `Gegenstand:` (den CR) und nennt zwei Punkte als Grenzen: die Auflösung der
   Kennung und die Frage, ob ein abgehakter Punkt ein Liefer-Punkt ist. Der Risiko-Ausgang steht
   in keiner der beiden Gruppen. Der CR im d-check-Repo erwähnt keine Risiken
   (`grep -n -i 'risik'` über die CR-Datei → kein Treffer). Eine Suche nach einer Adresse im Repo
   (`git grep -i -E 'Risiko[- ]?Ausg(a|ä)ng'` über `harness/`, `AGENTS.md`, ADRs, `open/`, `next/`
   und Register) fand keine. Das ist eine Trefferliste, keine Vollständigkeitsaussage.

**Wer nachträgt, in dieser Reihenfolge:**

- **Planner:** Er entscheidet die Adresse, wie bei F-2. Möglich sind ein Nachtrag zum eingehenden
  CR im d-check-Repo (der Stand dort ist „offen"), ein Folge-Slice oder ein Eintrag im
  Beobachtungs-Register. Die Lücke betrifft jede Closure, nicht nur die Stilllegung. Der Planner
  prüft darum zuerst, ob ein vorhandener Eintrag sie schon führt; gelesen habe ich keinen.
- **Implementer:** Er trägt in `docs-check.md` die Lage „ein Risiko ohne Ausgang → keine" ein, mit
  Kommando, nachgemessen nach dem Rezept der Datei. Dazu kommt die Einordnung mit der Adresse des
  Planners. Das ist Liefer-Punkt 3 und damit sein Artefakt.

## 4. Wächter-Aussagen (`AGENTS.md` §3.1)

Beide Dateien sagen, dass kein Wächter ihre Tabelle hält. Das stimmt, und nirgends sonst wird einer
behauptet:

- `grep -rn -E 'open → done|next → done|open->done|next->done'` über `harness/`, `AGENTS.md`,
  `README.md`, `test/`, `Makefile` und `.github/`, ohne die zwei Sensor-Dateien → kein Treffer.
- `grep -n 'slice-mv SLICE' harness/tools/full-smoke.sh` → vier Aufrufe (Z. 1452, 1527, 1569,
  1596). Die Einordnung „`TO=done` nur in den zwei Sperr-Fällen" hat der Review gelesen; sie ist
  hier nicht wiederholt.
- Der Kopfkommentar von `test/slice-mv.bats` sagt, dass die Selbsttests die Ersetzung ohne
  Repository aufrufen und der `git grep`-Teil darum fehlt.
- `grep -rl slice-mv test/mutations/` → sechs Fälle. Sie bewachen die Ersetzungs-Funktionen und die
  Lifecycle-Anleitung, keinen erfolgreichen Wechsel über eine Kante. Die Aussage „kein Wächter hält
  die zwei Kanten" ist damit nicht zu eng.

Die Adresse für den Wächter nimmt an: Das Ziel von `slice-mv-kanten-nach-done-sind-bewacht` ist
*„Ein erfolgreicher Wechsel `open → done` und `next → done` mit `make slice-mv` ist …"* bewacht, und
seine Datei liegt in `open/`.

## 5. Plan-vs-Code-Diff

**Geplant und geliefert:**

- beide Sensor-Dateien (§3 des Plans);
- die Messung an einer Kopie außerhalb des Repos;
- je Lücke eine Adresse:
  - `slice-mv-zieht-praefixlose-geschwister-verweise-nach` in `open/`. Sein Ziel nimmt die Lücke an:
    *„Nach einem Wechsel mit `make slice-mv` löst jeder Verweis auf die bewegte Datei auf"*.
  - der eingehende CR im d-check-Repo, *„`planning.closure` liest die Stilllegungs-Form nicht"*,
    Commit `d8e30b7d`.

**F-5 ist erledigt:** `git -C <d-check> branch -r --contains d8e30b7d` → `origin/main`. Der Kopf
des Remotes liegt bei `6e464c73` (`git ls-remote origin refs/heads/main`), und
`git merge-base --is-ancestor d8e30b7d 6e464c73` endet mit 0. Kriterium 2 des Closure-Triggers
ist für diese Adresse erfüllt.

**Geliefert, aber im ursprünglichen Plan nicht vorgesehen:**

- **Die Verfeinerung in §3** (Implementer, `b97bc8e1`): Messungen statt bewachter Zusagen, der
  Wächter als eigener Vorgang. Sie ist zulässig (`v6.9.0` · `regelwerk/modul-09-implementierung.md`,
  „Plan verfeinern"). Ihre Umfangsfolge hat der Planner in §1 übernommen (siehe unten). Ein
  Abnahmekriterium ist dadurch nicht umgeschrieben: §2 ist seit dem Claim unverändert
  (`git diff cbb49bf2..28aaca3d` über den Plan berührt nur §1 und §3).
- **Der Ausschluss in §1 und `slice-mv-kanten-nach-done-sind-bewacht`** (Planner, `d6bd222c`).
  §3 sah Folge-Slices „nur bei Lücke" vor. Dieser hier ist die Adresse eines Ausschlusses, keine
  Lücke. Den Schnitt trägt die Rolle, der die Umfangsgrenze gehört.
- **Die geänderte DoD 1 und der Closure-Trigger von
  `slice-mv-zieht-praefixlose-geschwister-verweise-nach`** (Planner, `d6bd222c`). Das betrifft
  ein anderes Artefakt; der Plan dieses Slice nennt es nicht.

**Geplant, aber offen:**

- das Element *Risiko-Ausgang* in Liefer-Punkt 3 (§3);
- „Festgehalten sind je Kante Exit-Code **und Ausgabe**" (DoD 1): Die Tabelle gibt die gelesene
  Wirkung wieder, nicht die Ausgabezeile des Werkzeugs (`eingehend: … Datei(en)`). Ich werte das
  als erfüllt, weil Kriterium 1 des Closure-Triggers „die gelesene Meldung" verlangt. Die Stelle
  ist nachrangig und blockiert nichts.

## 6. ADR-0056

Die Aussage in §Was diese Festlegung nicht tut lautet: *„Ob die Planungs-Werkzeuge und das
Doku-Gate diese Kanten tragen, ist hier nicht gemessen."*

**Die Frage ist beantwortet, die ADR bleibt, wie sie ist.** Die Aussage grenzt ab, was die
Festlegung selbst entscheidet („hier"), und bleibt darum wahr. Die ADR ist `Accepted` und nach
[`AGENTS.md`](../../AGENTS.md) §3.4 unveränderlich. Die Antwort steht in den zwei Sensor-Dateien,
mit zwei Einschränkungen:

- Gemessen sind `make slice-mv` und `make docs-check`. `make archive-welle` schließt §1 des Plans
  mit Begründung aus: Das Repo hat noch keine Welle archiviert.
- Beim Doku-Gate ist das Element Risiko-Ausgang erst mit §2 dieses Berichts gemessen und in der
  Sensor-Datei noch nicht eingetragen (§3).

Keiner der vier Re-Evaluierungs-Trigger der ADR ist durch diesen Slice berührt; eine Folge-ADR ist
nicht nötig. Die Entscheidung, ob das Repo die Kanten nimmt, bleibt offen. §1 schließt sie als
Vorgang einer anderen Rolle aus.

## 7. Risiken aus §6: Stand für die Closure

Die Ausgänge setzt der Planner. Hier steht nur, was ich beobachtet habe:

| Risiko | Beobachtung |
|---|---|
| 1 — `make slice-mv` committet selbst | Alle Messungen liefen an Kopien. Der Hauptzweig trägt keinen `slice-mv:`-Commit zu einem Geber dieser Messung (`git log --oneline cbb49bf2..28aaca3d` nennt keinen). |
| 2 — Grün ohne Gegenbeispiel | Rot gesehen sind `closure-note-thin` (Implementer, Review), `closure-note-placeholder` (Implementer, hier) und der bloße `git mv` (Implementer, Review). Die still bleibenden Lagen sind als Grenze oder Lücke benannt; beim Risiko-Ausgang fehlt das noch (§3). |
| 3 — der d-check-Pin wandert | Seit dem Claim nicht: `git log --format=%h 5655d3a0..HEAD -- d-check.mk \| wc -l` → `0`. |
| 4 — Commit-Träger und benannte Slices | unverändert offen. Die Kopie lief ohne `core.hooksPath`. Die Adresse `slice-werkzeug-commits-tragen-eine-kennung` liegt in `next/`. |

Die übrigen Übergaben an die Closure stehen im Review: F-6 (undeklarierte Setzung „Urteil"), N-1
(die Bedingung braucht einen Träger im Gruppierungs-Lauf) und die Klasse *Stellen-Messung als
Kanten-Eigenschaft ausgegeben*.

## 8. Offengelegt

- **Nicht nachgemessen:** die Kante `next → done`, weil der Review sie gemessen hat. Ebenso die
  Lagen „§7 auf einen Satz", „`Gegenstand:` fehlt", „Kennung, die es nicht gibt", „Liefer-Punkt
  abgehakt" und der bloße `git mv` als Gegenbeispiel. Die Lagen „§7 auf einen Satz",
  „`Gegenstand:` fehlt" und der bloße `git mv` sind zweifach gemessen, die Lagen „Kennung, die es
  nicht gibt" und „Liefer-Punkt abgehakt" nur vom Implementer.
- **Beobachtet, nicht Gegenstand:** Mit `placeholder: true` meldet d-check auch eine Datei des
  Bestands (`slice-087-emittierte-doku-tische-init-invariant`, Z. 353, `<make-target>`). Das
  betrifft nur, wer die Fähigkeit einschaltet.
- **Beobachtet, nicht gemessen:** Lage E meldet den Platzhalter `<Grund>`; der Platzhalter
  `slice-<Kennung>` steht in einem Code-Span. Ob eine halb ausgefüllte Zeile mit dem Platzhalter
  nur im Code-Span eine Meldung auslöst, ist offen.
- **Ablauf:** Mein erster Aufruf zum Anlegen des Stilllegungs-Inhalts enthielt einen überflüssigen
  `python3`-Rest und wurde vom PreToolUse-Guard abgewiesen, bevor er etwas tat. Der zweite Aufruf
  lief ohne ihn.

## 9. Verdikt

**DoD nicht vollständig erfüllt. Liefer-Punkte 1 und 2 sind erfüllt, Liefer-Punkt 3 ist für das
Element *Risiko-Ausgang* offen.** Alles andere trägt:

- beide Kanten laufen über das Werkzeug mit reinem Rename;
- `closure` liest den stillgelegten Slice;
- die Adressen der zwei übrigen Lücken lösen auf, F-5 eingeschlossen;
- kein Wächter ist behauptet, der nicht existiert.

**Vor der Closure fehlt:**

| # | Was | Adressat |
|---|---|---|
| 1 | eine Adresse für die Lücke „kein aktives Modul prüft, dass jedes Risiko einen Ausgang trägt" (CR-Nachtrag, Folge-Slice oder Registereintrag; vorher einen vorhandenen Eintrag prüfen) | Planner |
| 2 | in `docs-check.md` die Lage „ein Risiko ohne Ausgang → keine", mit Kommando, dazu die Einordnung mit der Adresse aus Punkt 1 | Implementer |
| 3 | N-1 aus der Nachprüfung: ein Träger für die Bedingung im Gruppierungs-Lauf | Planner |
| 4 | F-6 aus dem Review: die Setzung „Urteil" für die Auflösung der Kennung als Setzung ausweisen | Planner, bei Bedarf Architect |
| 5 | die Closure selbst: §7, Risiko-Ausgänge (§7 oben als Eingang), Register mit der wiederkehrenden Klasse aus dem Review, DoD-Häkchen | Planner |

Punkt 2 ist eine Nacharbeit an einem Liefer-Punkt. Danach genügt eine Nachprüfung dieser einen
Stelle; eine neue Verifikation ist nicht nötig.
