# CO-006: Der Tag-Tausch des vendored Baums macht 36 Adressen in einfrierenden Artefakten tot

**Status:** Aktiv.

**Datum angelegt:** 2026-09-08. **Letzte Prüfung:** 2026-09-08.

**Betroffenes Gate:** `make docs-check` — und über die Prerequisite-Kette `record-gates` damit
`make gates`. Von den sieben Modulen der [`.d-check.yml`](../../../.d-check.yml)
(`grep -n '^modules:' .d-check.yml`) trägt der Befund nur `links`; die neun übrigen Ziele der Kette
(`sed -n 's/^record-gates: \(.*\) ##.*/\1/p' Makefile | wc -w` → 10, davon `docs-check` eines) sind
am Stichtag unten einzeln nachgefahren und grün.

**Geltungsbereich:** die drei einfrierenden Bäume `docs/reviews/**`,
`docs/plan/planning/done/**` und `docs/plan/planning/observations/**`, und darin ausschließlich
Markdown-Links, deren Ziel in `.harness/baseline/**` liegt. Lebende Artefakte liegen außerhalb:
Der Adress-Nachzug hat sie gezogen, und was dort noch den abgelösten Tag nennt, sind die zwei in
[slice-193](../planning/done/slice-193-baum-tausch-v650-pins-ziehen.md) DoD 2 deklarierten
Nicht-Zieh-Klassen — Tree-Operand und datierte Mess-Aussage nach
[`MR-033`](../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist).

**Folge-Slice:** [`slice-197`](../planning/next/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md)

Regeln: Baseline-Regelwerk `modul-07-carveouts.md` §Ziel-Form: Carveout — ein
Carveout braucht immer einen Auflösungs-Trigger **und** einen Folge-Slice.

---

## Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — technische Begründung, keine
„noch nicht geschafft"-Aussagen.

Der vendored Baum trägt genau einen Tag
([`MR-007`](../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)):
Der Sprung legt `.harness/baseline/v6.5.0/` an und löscht den Vorgänger. Jeder Markdown-Link, der
das alte Tag-Segment nennt, zeigt danach ins Leere. Die Ziele liegen in Artefakten, die niemand
mehr anfassen darf — Review-Reports und geschlossene Slice-Pläne sind Zeitdokumente, eine
`observation.md` ist ab Anlage unveränderlich (Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register). Damit ist der Befund **nicht reparierbar**: Die eine Änderung, die ihn
zum Verschwinden brächte, ist die, die [`AGENTS.md`](../../../AGENTS.md) §3.4 und §3.11 sperren.

Der Ausgang ist entschieden und nicht offen —
[ADR-0039](../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md), `Accepted`: ein
Referenz-Ventil in Glob-Form, drei `ignore-refs`-Einträge mit dem baum-weiten `refs`-Wert
`.harness/baseline/**`, dazu ein Breiten-Wächter, der gegen eine je Eintrag deklarierte Zahl misst
statt gegen die Konstante 1. Was fehlt, ist allein die **Umsetzung**, und die liegt in
Implementer-Artefakten ([`.d-check.yml`](../../../.d-check.yml),
[`test/ignore-refs-restbreite.bats`](../../../test/ignore-refs-restbreite.bats)) — geschnitten als
`slice-197`.

Dieser Carveout schaltet damit keinen Befund stumm, sondern hält den Zeitraum zwischen der
angenommenen Entscheidung und ihrer Umsetzung an einen Trigger. Ohne ihn stünde eine
Zirkularität: Das Closure-Kriterium von `slice-193` verlangt ein grünes Gate, `slice-197` stellt
es her, und `slice-193` belegt bis dahin das WIP-Limit desselben Rolleninhabers.

**Der gemessene Zustand**, Stichtag 2026-09-08 (**keine Erwartungswerte** —
[`MR-025`](../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2; die Zahl über `docs/reviews/**` wächst mit jedem Review-Lauf, der in den Baum
verlinkt, und der Review dieses Slice ist selbst einer davon):

```sh
make docs-check     # d-check: 948 Datei(en) geprüft, 36 Befund(e), EXIT 1
make docs-check 2>&1 | awk -F'\t' 'NF>2{print $3}' | sort | uniq -c            # 36 target-missing
make docs-check 2>&1 | awk -F'\t' 'NF>2 && $2 ~ /\.harness\/baseline\//' | wc -l   # 36
make docs-check 2>&1 | awk -F'\t' 'NF>2{split($1,a,":"); print a[1]}' \
  | cut -d/ -f1-4 | sort | uniq -c
#   32 docs/reviews
#    3 docs/plan/planning/done
#    1 docs/plan/planning/observations
```

Die Verteilung ist deckungsgleich mit den drei `in:`-Globs aus
[ADR-0039](../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1, und alle 36
Ziele liegen in `.harness/baseline/**`, dem einen `refs`-Wert derselben Festlegung. Der Carveout
deckt damit genau die Menge, die das beschlossene Ventil aufnimmt — nicht mehr.

**Warum Carveout und nicht BF-Sub-Area-Markierung.** Der Trichter aus
`modul-07-carveouts.md` §Werkzeug-Wahl bei Diskrepanz fragt Granularität vor Temporalität.
*Granularität:* eine einzelne Diskrepanz — ein Gate, ein Modul, ein Grund-Code, eine Ursache, eine
beschlossene Abhilfe. 36 Fundstellen sind die Vorkommen **einer** Diskrepanz und kein Cluster
mehrerer; maßgeblich ist das Symptom-Muster, nicht die Zahl. Eine BF-Markierung setzte zudem
*Code führt, Doku folgt*, und darum geht es hier nicht. *Temporalität:* der Trigger ist ernst
erreichbar — die Entscheidung steht `Accepted`, der Umfang ist bemessen (drei Config-Einträge und
der Umbau eines bestehenden Wächters), der Folge-Slice liegt als Datei im Lifecycle.

## Auflösungs-Trigger

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — konkret und prüfbar. „Wenn Zeit ist" ist kein Trigger.

**`make docs-check` meldet `0 Befund(e)`, ohne dass ein Artefakt in einem der drei einfrierenden
Bäume geändert wurde.**

Beide Hälften sind ohne Rückfrage beurteilbar: Die erste liest der Gate-Lauf selbst ab, die zweite
`git diff --stat <angelegt>..HEAD -- docs/reviews docs/plan/planning/done docs/plan/planning/observations`
— eine leere Ausgabe für die 16 Dateien, die heute die 36 Adressen tragen. Die zweite Hälfte steht
hier, weil ein grünes Gate allein den Trigger auch dann erfüllte, wenn jemand die eingefrorenen
Artefakte repariert hätte; genau das ist der verbotene Weg und kein Auflösungs-Beleg.

Der Träger dieses Triggers ist `slice-197`. Sein Eintreten und die Auflösung fallen nicht zusammen:
Aufgelöst ist der Carveout erst mit dem `git mv` nach `done/` und der Verifikation unten.

## Geltungs-Konfiguration

**Keine Zeile — und das ist die Aussage, nicht ihre Auslassung.** Modul 7 verlangt, dass die
Gate-Konfiguration die `CO-<NNN>` im Gate-Output nennt, damit eine Ausnahme keine stille Senkung
ist. Hier ist **keine Ausnahme konfiguriert**: Der Gate meldet alle 36 Befunde unverkürzt und
endet mit EXIT 1. Die Sichtbarkeits-Pflicht hat damit keinen Gegenstand — es gibt nichts, was
still wäre. Der Preis dafür steht in der Verifikation unten: Solange dieser Carveout liegt, ist
`make gates` rot, und jeder Lauf, der ihn liest, muss die 36 gegen genau diese Datei halten.

| Datei | Zeile/Section | Wert |
|---|---|---|
| — | — | keine konfigurierte Ausnahme; die Senkung ist die **Duldung** eines lauten roten Gates, nicht seine Stummschaltung |

Mit der Auflösung entsteht die Konfiguration, die dieser Abschnitt heute nicht führt: die drei
`ignore-refs`-Einträge aus [ADR-0039](../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
Festlegung 1 samt ihrer Breiten-Deklaration nach Festlegung 2.

## Verifikation (nach Auflösung)

- [ ] Die drei `ignore-refs`-Einträge liegen in [`.d-check.yml`](../../../.d-check.yml), je mit
      der am Lauf-Tag gemessenen Breiten-Deklaration.
- [ ] `make docs-check` meldet `0 Befund(e)`, und die geprüfte Datei-Zahl ist **nicht** gesunken —
      ein Referenz-Ventil nimmt Referenzen aus, keine Dateien.
- [ ] Kein Artefakt in `docs/reviews/**`, `docs/plan/planning/done/**` oder
      `docs/plan/planning/observations/**` ist gegenüber dem Anlage-Stand geändert.
- [ ] `make gates` grün ohne Ausnahme.
- [ ] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`).
- [ ] `slice-197` liegt in `done/`.

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-08 | Angelegt | [slice-193](../planning/done/slice-193-baum-tausch-v650-pins-ziehen.md) §7, Ausgang des zweiten Risikos aus §6 |
