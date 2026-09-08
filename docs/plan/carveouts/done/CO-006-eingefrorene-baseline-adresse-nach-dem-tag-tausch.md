# CO-006: Der Tag-Tausch des vendored Baums macht 36 Adressen in einfrierenden Artefakten tot

**Status:** **Aufgelöst** — der Modul-7-Übergang ist vollzogen, und der Ort sagt es: diese Datei
liegt in `done/`, der Index führt sie unter *Aufgelöst*. Beide Hälften des Auflösungs-Triggers sind
gemessen: `make docs-check` meldet `0 Befund(e)`, und keine der 16 Dateien, die die 36 Adressen
tragen, ist seit der Anlage angefasst worden. Die Verifikations-Checkliste unten ist vollständig
gehakt.

**Datum angelegt:** 2026-09-08. **Letzte Prüfung:** 2026-09-08 (Auflösung durch
[slice-197](../../planning/done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md): drei
`ignore-refs`-Einträge in Glob-Form mit dem baum-weiten `refs`-Wert `.harness/baseline/**`, die
Breiten-Deklaration an allen sieben Einträgen und der neue Maßstab des Wächters — `genau N` statt
`höchstens 1`).

**Betroffenes Gate:** `make docs-check` — und über die Prerequisite-Kette `record-gates` damit
`make gates`. Von den sieben Modulen der [`.d-check.yml`](../../../../.d-check.yml)
(`grep -n '^modules:' .d-check.yml`) trägt der Befund nur `links`; die neun übrigen Ziele der Kette
(`sed -n 's/^record-gates: \(.*\) ##.*/\1/p' Makefile | wc -w` → 10, davon `docs-check` eines) sind
am Stichtag unten einzeln nachgefahren und grün.

**Geltungsbereich:** die drei einfrierenden Bäume `docs/reviews/**`,
`docs/plan/planning/done/**` und `docs/plan/planning/observations/**`, und darin ausschließlich
Markdown-Links, deren Ziel in `.harness/baseline/**` liegt. Lebende Artefakte liegen außerhalb:
Der Adress-Nachzug hat sie gezogen, und was dort noch den abgelösten Tag nennt, sind die zwei in
[slice-193](../../planning/done/slice-193-baum-tausch-v650-pins-ziehen.md) DoD 2 deklarierten
Nicht-Zieh-Klassen — Tree-Operand und datierte Mess-Aussage nach
[`MR-033`](../../../../harness/conventions.md#mr-033--eine-aussage-über-die-baseline-nennt-den-tag-gegen-den-sie-gemessen-ist).

**Folge-Slice:** [`slice-197`](../../planning/done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md)

Regeln: Baseline-Regelwerk `modul-07-carveouts.md` §Ziel-Form: Carveout — ein
Carveout braucht immer einen Auflösungs-Trigger **und** einen Folge-Slice.

---

## Begründung

Regeln dieser Sektion: Baseline-Regelwerk `modul-07-carveouts.md`
§Ziel-Form: Carveout — technische Begründung, keine
„noch nicht geschafft"-Aussagen.

Der vendored Baum trägt genau einen Tag
([`MR-007`](../../../../harness/conventions.md#mr-007--baseline-committet-vendored-statt-gefetchter-cache)):
Der Sprung legt `.harness/baseline/v6.5.0/` an und löscht den Vorgänger. Jeder Markdown-Link, der
das alte Tag-Segment nennt, zeigt danach ins Leere. Die Ziele liegen in Artefakten, die niemand
mehr anfassen darf — Review-Reports und geschlossene Slice-Pläne sind Zeitdokumente, eine
`observation.md` ist ab Anlage unveränderlich (Baseline-Regelwerk `modul-06-roadmap.md`
§Das Beobachtungs-Register). Damit ist der Befund **nicht reparierbar**: Die eine Änderung, die ihn
zum Verschwinden brächte, ist die, die [`AGENTS.md`](../../../../AGENTS.md) §3.4 und §3.11 sperren.

Der Ausgang ist entschieden und nicht offen —
[ADR-0039](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md), `Accepted`: ein
Referenz-Ventil in Glob-Form, drei `ignore-refs`-Einträge mit dem baum-weiten `refs`-Wert
`.harness/baseline/**`, dazu ein Breiten-Wächter, der gegen eine je Eintrag deklarierte Zahl misst
statt gegen die Konstante 1. Was fehlt, ist allein die **Umsetzung**, und die liegt in
Implementer-Artefakten ([`.d-check.yml`](../../../../.d-check.yml),
[`test/ignore-refs-restbreite.bats`](../../../../test/ignore-refs-restbreite.bats)) — geschnitten als
`slice-197`.

Dieser Carveout schaltet damit keinen Befund stumm, sondern hält den Zeitraum zwischen der
angenommenen Entscheidung und ihrer Umsetzung an einen Trigger. Ohne ihn stünde eine
Zirkularität: Das Closure-Kriterium von `slice-193` verlangt ein grünes Gate, `slice-197` stellt
es her, und `slice-193` belegt bis dahin das WIP-Limit desselben Rolleninhabers.

**Der gemessene Zustand**, Stichtag 2026-09-08 (**keine Erwartungswerte** —
[`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
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
[ADR-0039](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) Festlegung 1, und alle 36
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
`ignore-refs`-Einträge aus [ADR-0039](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
Festlegung 1 samt ihrer Breiten-Deklaration nach Festlegung 2.

## Verifikation (nach Auflösung)

- [x] Die drei `ignore-refs`-Einträge liegen in [`.d-check.yml`](../../../../.d-check.yml), je mit
      der am Lauf-Tag gemessenen Breiten-Deklaration. Alle drei tragen den `in:`-Wert und den
      `refs`-Wert aus [ADR-0039](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md)
      Festlegung 1 wörtlich, die Deklarationen lauten `33 · 3 · 2`, und
      `grep -c '^  - in: ' .d-check.yml` → **7** belegt Festlegung 3: kein vierter Baum.
- [x] `make docs-check` meldet `0 Befund(e)`, und die geprüfte Datei-Zahl ist **nicht** gesunken —
      ein Referenz-Ventil nimmt Referenzen aus, keine Dateien. Belegt durch **zwei Läufe über
      derselben Kopie** außerhalb des Arbeitsbaums, gegen den in
      [`d-check.mk`](../../../../d-check.mk) gepinnten Digest: mit den drei Einträgen
      `0 Befund(e)`, ohne sie `36 Befund(e)` — bei **identischer** Datei-Zahl in beiden Läufen.
      Der Vergleich läuft über demselben Baum und nicht gegen eine notierte Zahl; die 36 sind
      dieselben, die dieser Carveout deckt.
- [x] Kein Artefakt in `docs/reviews/**`, `docs/plan/planning/done/**` oder
      `docs/plan/planning/observations/**` ist gegenüber dem Anlage-Stand geändert. **Gemessen
      über die Menge, die der Trigger meint** — die Dateien, die die Adressen *tragen*, nicht die
      drei Bäume als Ganze: `git diff --stat` über die 16 Träger vom Anlage-Commit bis heute ist
      leer. Die Bäume selbst haben legitim Dateien **aufgenommen** (die Reports dieses Slice, den
      Slice-Plan von `slice-193` und die Register-Belege), und eine Datei ist vom Verweis-Nachzug
      eines Lifecycle-Moves geändert — keine davon trägt eine der 36 Adressen.
- [x] `make gates` grün ohne Ausnahme. Gefahren über dem Baum dieser Auflösung, EXIT **0**; es ist
      keine Ausnahme konfiguriert, die zurückzunehmen wäre (§Geltungs-Konfiguration).
- [x] Datei wird nach `docs/plan/carveouts/done/` bewegt (reiner `git mv`) — der Move als eigener
      Commit, der Verweis-Nachzug als zweiter ([`AGENTS.md`](../../../../AGENTS.md) §3.3).
- [x] `slice-197` liegt in `done/`. Sein Zustand ist sein Verzeichnis, und kein DoD-Punkt steht
      mehr offen
      (`grep -c '^- \[ \]' docs/plan/planning/done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md`
      → **0**).

## Geschichte

| Datum | Ereignis | Verweis |
|---|---|---|
| 2026-09-08 | Angelegt | [slice-193](../../planning/done/slice-193-baum-tausch-v650-pins-ziehen.md) §7, Ausgang des zweiten Risikos aus §6 |
| 2026-09-08 | **Aufgelöst.** [ADR-0039](../../adr/0039-eingefrorene-adresse-in-den-vendored-baum.md) autorisiert das Referenz-Ventil in Glob-Form, [`.d-check.yml`](../../../../.d-check.yml) trägt die drei Einträge mit ihrer Breiten-Deklaration, und `test/ignore-refs-restbreite.bats` misst sie in `make gates` gegen `genau N` statt gegen die Konstante 1. Zwei Läufe über derselben Kopie belegen den Trigger: mit den Einträgen `0 Befund(e)`, ohne sie `36 Befund(e)`, bei identischer Datei-Zahl — kein geschrumpfter Prüfbereich. Die 16 Träger-Dateien sind seit der Anlage unverändert | [slice-197](../../planning/done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md) |
| 2026-09-08 | **Vollzogen**: `git mv` nach `done/` als eigener Commit, der Verweis-Nachzug als zweiter, Index-Zeile unter *Aufgelöst*. Status-Kopf, Checkliste und Index-Zelle sagen seither dasselbe wie der Ort | [slice-197](../../planning/done/slice-197-eingefrorene-baseline-adresse-bekommt-ihr-ventil.md) |
