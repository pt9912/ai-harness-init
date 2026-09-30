# Umbau des Fließtexts von Spec §5 nach ADR-0074 — Bericht der Rolle Implementer

**Art:** Bericht der Rolle Implementer (Eingabe für Review und Verifikation). Zeitdokument; kein Norm-Text.

**Slice:** `slice-spec-5-wird-nach-adr-0074-umgebaut`. **Bezug:** [LH-FA-10](../../spec/lastenheft.md#lh-fa-10--erfassungsschicht-emittieren) ·
[ADR-0074](../plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) ·
[ADR-0075](../plan/adr/0075-begruendungen-zu-spec-5-sammel-adr.md) · [MR-075](../../harness/conventions.md#mr-075) ·
[MR-076](../../harness/conventions.md#mr-076) · [MR-077](../../harness/conventions.md#mr-077).

## 1. Vorher-Messungen (Stufe a)

Stand vor dem Umbau: `git show 85e5ab5b:spec/spezifikation.md` (`git diff 85e5ab5b HEAD -- spec/spezifikation.md | wc -l` → 0, die
Arbeitskopie war bei Beginn identisch). Zahlen sind Messungen, keine Erwartungswerte
([MR-025](../../harness/conventions.md#mr-025)).

```sh
V=<Vorher-Fassung>
sed -n '4,/^## 7\. Historie/p' $V | grep -vc '^|'                                     # 682  Nicht-Tabellenzeilen
sed -n '4,/^## 7\. Historie/p' $V | grep -v '^|' | wc -c                              # 51194 Bytes
wc -c < $V                                                                            # 66691 Bytes gesamt
grep -oE '`Test[A-Za-z0-9_]+`|test/mutations/[0-9]+-[a-z0-9-]+\.sh' $V | sort -u | wc -l   # 50 Namen (24 Tests, 26 Fall-Dateien)
awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' $V | grep -v '^|' | grep -cE 'Negativ-Liste|Dauer des \*\*Aufrufs\*\*|Slice→Rolle|geraten, nicht|falsch geroutetes|EIGENEN'   # 6
sed -n '4,/^## 7\. Historie/p' $V | grep -cE '20[0-9]{2}-[0-9]{2}-[0-9]{2}'            # 12
awk '/^\| `SPEC-034`/{f=1;next} /^## 6\. Externe/{f=0} f' $V | grep -v '^|' | grep -cE 'test/|_test\.go|Fall [0-9]+|\.bats'   # 38
grep -c 'Abweichung [1-6]' $V                                                         # 17
grep -c 'START-KONVENTION' $V                                                         # 1
grep -c '^| ID | Feld | Pflicht | Incident-Frage | Sensor |' $V                       # 1
git grep -nE 'spezifikation\.md' -- internal test cmd harness/tools | wc -l           # 49  Zeiger-Stellen
```

Byte-Bilanz je Klasse am Stand vor dem Umbau (Klassifikationsbericht §2, Bytes des Fließtexts 137 bis 718 = 45889):
a Festlegung 10177 · b Begründung 3293 · c Messprotokoll 13508 · d Abweichung 8245 · e passt in keine (Wächter-Zuordnung) 10666.

**Treffer der Passagen-Namen in eingefrorenen ADRs** (`git grep -c -- '<Name>' -- docs/plan/adr ':!docs/plan/adr/0074-*' ':!docs/plan/adr/0075-*'`),
gemessen vor dem Umbau — sie bestimmen, welche Namen als Text in den übernehmenden Zeilen stehen
([ADR-0074](../plan/adr/0074-spec-5-fliesstext-klassen-ort-und-lh-bezug-spalte.md) Festlegung 10):

| Name | Treffer / Dateien | Name | Treffer / Dateien |
|---|---|---|---|
| START-KONVENTION | 3 / 2 | Abweichung 5 | 10 / 3 |
| Bewacht | 3 / 3 | Abweichung 6 | 8 / 2 |
| Positiv-Liste | 4 / 2 | Splitting-Regel | 3 / 1 |
| Abweichung 1 | 3 / 1 | SubagentStart | 7 / 3 |
| Abweichung 2 | 0 / 0 | Sammelposten | 12 / 4 |
| Abweichung 3 | 0 / 0 | Berichtsgröße | 3 / 1 |
| Abweichung 4 | 2 / 1 | kanonischen Namen | 3 / 2 |
| Lesevorschrift | 0 / 0 | Prüfreihenfolge | 0 / 0 |

**Wächter-Zuordnung je Zusicherung, vorab gemessen** (Kopfkommentare der Fall-Dateien 107 bis 115, 123 bis 138, 154 gelesen):
jede der Zusicherungen der Prosa „Bewacht" wird von der `# expect:`-Zeile und dem Kopfkommentar ihres Falls oder vom Namen ihres Tests
getragen — der Test- bzw. Fallname behauptet die Zusicherung in seinem Namen. Ausgenommen sind die Sätze, die eine **Lücke** benennen
(kein Zahn für die `mustContain`-Gegenproben, sechs ungebundene `mustNotContain`-Einträge, Herkunfts-Achse ohne Zahn, Guard-Verdrahtung
dieses Repos): sie stehen als Zeilen mit Strich in der Spalte `Sensor`. Der Kommentar-Nachzug am Test steht in §5.
