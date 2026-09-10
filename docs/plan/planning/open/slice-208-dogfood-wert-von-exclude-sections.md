# Slice slice-208: Der Dogfood-Wert von `exclude-sections` wird entschieden

**Lifecycle:** Der Zustand dieses Slice ist das Verzeichnis, in dem diese
Datei liegt — eines von `open/`, `next/`, `in-progress/`, `done/`. Er
wechselt nur durch `git mv`, siehe
Baseline-Regelwerk `modul-05-planning-harness.md` §Lifecycle als State Machine.

**Welle:** ohne Welle. Es gibt keine Closure-Bedingung, die von der DoD dieses Slice verschieden
wäre — der Trigger-Satz einer Welle wäre hier die Abschrift von DoD (2)
(Baseline-Regelwerk `modul-06-roadmap.md` §Wann Arbeit eine Welle braucht).

**Bezug:** [`LH-QA-01`](../../../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)
(kein Gate über leerem Prüfbereich — hier die Gegenrichtung: ein Ausnahme-Schlüssel, der weiter ist
als sein Anlass, nimmt dem Modul stillschweigend Prüffläche),
[`MR-001`](../../../../harness/conventions.md#mr-001--doc-gate-schärfung-matrix--link-pflicht--anker-ids)
(Gate-*Anheben* → Steering-Loop, kein ADR),
[`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)
(die Personalunion, aus der die Form der Lastenheft-Historie folgt — sie ist der **Grund** des
heutigen Werts, nicht sein Nebeneffekt),
[`AGENTS.md`](../../../../AGENTS.md) §3.5 (jede Schwellen-Senkung ist ein ADR — hier zu prüfen, in
welche Richtung der Schritt geht).

**Berührte Spec-Stellen:** — (kein Zielelement der Spec-Straten wird geändert; die Messung liest
[`spec/lastenheft.md`](../../../../spec/lastenheft.md) §7 Historie, sie schreibt sie nicht).

**Verantwortlich:** —

**Autor:** ai-harness-init-Team (pt9912). **Datum:** 2026-09-10.

---

## 1. Ziel und Abgrenzung

**Ziel:** Für `matrix.exclude-sections` im Dogfood ist entschieden und belegt, ob der Wert auf den
emittierten `[Geschichte]` **konvergiert** oder als benannte, dauerhafte Abweichung **stehen
bleibt** — mit einem Beleg, der die Kosten beider Wege beziffert, statt sie zu schätzen.

Der Anlass ist eine gemessene Divergenz, die heute keine Adresse hat. Die emittierte Vorlage trägt
seit dem Runde-4-Stand von [slice-073](../in-progress/slice-073-emittierte-doc-gate-module.md) den
engeren Wert, der Dogfood den weiteren:

```sh
grep -n 'exclude-sections' internal/emit/templates/d-check.yml   # 59:  exclude-sections: [Geschichte]
sed -n '194p' .d-check.yml   # exclude-sections: [Historie, "7. Historie", Geschichte]
```

**Warum das keine Nachzieh-Arbeit ist, sondern eine Entscheidung.** Die drei übrigen Positionen, in
denen das emittierte `matrix` dem Dogfood vorausläuft, holt
[slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md) ein — sie sind dieselbe Regel in
zwei Bäumen. Diese vierte ist es nicht: Was der weitere Wert im Dogfood deckt, ist eine **andere
Regel-Familie** als die, um die es in slice-072 geht. Gemessen an einer Kopie außerhalb des Repos,
netzlos, Mount `:ro`, gegen den in [`d-check.mk`](../../../../d-check.mk) gepinnten Digest, mit dem
Dogfood-Wert probeweise auf `[Geschichte]` verengt:

```sh
DIGEST=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
git archive HEAD | tar -x -C <kopie>
sed -i 's/^  exclude-sections: \[Historie, "7. Historie", Geschichte\]$/  exclude-sections: [Geschichte]/' <kopie>/.d-check.yml
docker run --rm --network none -v <kopie>:/repo:ro "ghcr.io/pt9912/d-check@$DIGEST" > <lauf>
tail -1 <lauf>                                          # 1071 Datei(en) geprüft, 16 Befund(e)
grep 'matrix-' <lauf> | awk -F: '{print $1}' | sort -u   # spec/lastenheft.md -- und sonst nichts
grep 'matrix-' <lauf> | grep -oE 'matrix-[a-z]+' | sort | uniq -c   # 14 matrix-forbidden, 2 matrix-inactive
```

**Keine Erwartungswerte** ([`MR-025`](../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — alle drei Zahlen wandern mit dem Bestand der Historie-Tabelle. Tragend ist ihre
**Zusammensetzung**: Alle sechzehn liegen in `spec/lastenheft.md` unter `## 7. Historie`, und
vierzehn davon sind `spec-straten → adr` — die Regel, die verbietet, dass das Vertrags-Stratum auf
eine Entscheidung zeigt. slice-072 handelt von `{from: adr, to: slice}` und `{from: adr, to: welle}`,
also der Gegenrichtung; die zwei `matrix-inactive` sind eine dritte Sache (Verweise auf abgelöste
ADRs). Wer diese Position an slice-072 hängt, hängt ihr eine fremde Regel-Familie an.

**Und der Grund der Divergenz sitzt tiefer als die Konfiguration.** Jede CR-Zeile der
Lastenheft-Historie nennt die ADR, die den Vertrag änderte, weil in diesem Repo Auftraggeber und
Entwickler dieselbe Person sind ([`MR-015`](../../../../harness/conventions.md#mr-015--change-request-bei-personalunion-von-auftraggeber-und-entwickler)):
Der „externe Change Request", auf den die Verweis-Spalte der Ziel-Form zeigt, ist hier ein
internes Artefakt. Der Kommentar der emittierten Vorlage sagt genau das über das **Ziel**
(`sed -n '34,37p' internal/emit/templates/d-check.yml` — *„die Spalte 'Verweis' fuehrt nur den
externen Change Request"*); für ein frisches Ziel stimmt das, für dieses Repo nicht. Ob daraus
folgt, dass der Dogfood den weiteren Wert **behalten** muss, oder ob die sechzehn Zeilen wie die
sieben ADRs in slice-072 über eine **vorgeschaltete Klasse** geführt gehören, ist die Frage dieses
Slice.

**Ausdrücklich NICHT in diesem Slice** — je Punkt mit Begründung:

- **Der emittierte Wert `[Geschichte]`.** Er ist in
  [slice-073](../in-progress/slice-073-emittierte-doc-gate-module.md) DoD (1) entschieden und dort
  gegen den frisch emittierten Bestand gemessen; dieser Slice entscheidet die **Dogfood**-Seite und
  fasst die Ziel-Seite nicht an. *(Schicht-Abgrenzung: der emittierte Baum ist ein anderer
  Vertrag als das eigene Gate.)*
- **Die drei übrigen `matrix`-Positionen** — die zwei Lifecycle-Klassen im `token:`-Modus, die zwei
  Regeln `{from: adr, to: …}` und die Richtungs-Prüfung innerhalb der Spec-Straten. Sie sind
  [slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md) DoD (1), und ihre Begründung
  wird nicht zweimal aufgeschrieben. *(Folge-Slice mit Kennung — und diese Adresse nimmt jene drei
  nachweislich an, weil ihre DoD genau diesen Block hebt.)*
- **Jede Änderung an `spec/lastenheft.md` §7 Historie.** Die Historie ist nach
  [`MR-042`](../../../../harness/conventions.md#mr-042--der-anlass-einer-lastenheft-änderung-steht-nicht-in-der-historie-sondern-in-der-closure-notiz)
  ein Vertrags-Artefakt in Rang 1; ihre Zeilen umzuschreiben, um ein Gate grün zu bekommen, hieße
  den Vertrag der Konfiguration anzupassen. *(Bestand bleibt bewusst stehen — die Konfiguration
  folgt dem Vertrag, nicht umgekehrt.)*
- **Die gleichlautende offene Frage am `vcs`-Modul** — ob dessen `exclude-sections` dieselbe Liste
  braucht wie `matrix` ([`harness/README.md`](../../../../harness/README.md) §Sensors, letzter
  Absatz zu `adr-immutable`). Dieselbe Schlüssel-Schreibweise, anderes Modul und anderer
  Prüfgegenstand (ADR-Kern-Unveränderlichkeit statt Referenz-Richtung). *(Es wäre ein anderer
  Vorgang.)*

## 2. Definition of Done

- [ ] **(1) Die Entscheidung steht, und beide Wege sind beziffert.** Für jeden der zwei Wege —
  Konvergenz auf `[Geschichte]` mit vorgeschalteter Klasse für die Historie-Zeilen · benannte,
  dauerhafte Abweichung — liegt eine Messung am gepinnten Digest vor (Kopie außerhalb des Repos,
  netzlos, Mount `:ro`): wie viele Befunde entstehen, welcher Art, und welche Prüffläche der
  jeweils andere Weg verliert. Die Wahl steht mit Begründung im Plan; **welche** Prüffläche der
  weite Wert heute stumm schaltet, ist dabei die tragende Zahl, nicht die Zahl der Befunde.
- [ ] **(2) Der gewählte Weg ist verkörpert und trägt einen Zahn.** Bei Konvergenz: `.d-check.yml`
  trägt den engeren Wert samt Vorschaltung, `make docs-check` grün, und ein Fall in
  `test/mutations/` färbt rot, wenn die Vorschaltung wegfällt — im Modus `docs-check`, den
  [slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md) DoD (2) in
  `harness/tools/mutate.sh` einführt. Bei benannter Abweichung: der Grund steht an **einer** Stelle
  — dem Kommentar über dem Schlüssel in [`.d-check.yml`](../../../../.d-check.yml) — und
  [`harness/README.md`](../../../../harness/README.md) nennt die Divergenz als bekannte Grenze,
  ohne sie ein zweites Mal zu begründen.
- [ ] **(3) `make gates` grün, Review durchgeführt, Report unter `docs/reviews/`**
  (`.harness/skills/reviewer.md`) — Rollenwechsel nach Schritt 8 des Minimal Agent Workflow
  ([`AGENTS.md`](../../../../AGENTS.md) §6), kein Self-Review (Modul 8). Closure-Notiz mit
  Steering-Loop-Lerneintrag; Beobachtungs-Register fortgeschrieben; jedes Risiko aus §6 mit
  Ausgang; die drei Paarungen geprüft.

## 3. Plan (vor Code)

| Datei / Komponente | Änderungs-Art | Begründung |
|---|---|---|
| `.d-check.yml` (`matrix.exclude-sections`, ggf. `matrix.classes`) | update | der Gegenstand der Entscheidung |
| `test/mutations/<NNN>-…sh` | neu (nur bei Konvergenz) | ohne Zahn wäre die Vorschaltung gelistet-aber-unbewacht |
| [`harness/README.md`](../../../../harness/README.md) §Sensors | update | die Zusage über den Prüfbereich von `matrix` wandert mit dem Wert |

**Abhängigkeit, die den Start bindet:** Der Modus `docs-check` in `harness/tools/mutate.sh`
entsteht in [slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md) DoD (2). Ohne ihn
kann DoD (2) dieses Slice im Konvergenz-Zweig keinen Zahn setzen — siehe §4.

## 4. Trigger

**Start** (`next` → `in-progress`): [slice-072](../open/slice-072-adr-verweist-nicht-auf-lifecycle.md)
liegt in `done/` — er bringt den `docs-check`-Modus in `harness/tools/mutate.sh` und die
Klassen-Vorschaltung als erprobte Form mit; beides braucht der Konvergenz-Zweig. Zusätzlich:
Implementer übernimmt, WIP-Limit frei.

**Rückführungen — vorab benannt:**

- `in-progress` → `next` (zu groß, zurück zur Zerlegung): wenn die Messung aus DoD (1) zeigt, dass
  der Konvergenz-Zweig eine Änderung an `spec/lastenheft.md` verlangt — dann sind es zwei Vorgänge
  (Gate-Form und Vertrags-Form), nicht einer, und §1 schließt den zweiten aus.
- `in-progress` → `open` (blockiert — Carveout?): wenn der gepinnte d-check keine Klassen-Form
  anbietet, die die Historie-Zeilen trägt, ohne den `matrix-inactive`-Wächter über die übrigen
  ADR→ADR-Links zu löschen — dieselbe Falle, die slice-072 für `exempt-paths` gemessen hat.

## 5. Closure-Trigger

DoD (1)–(3) abgehakt, PR gemerged, Closure-Notiz geschrieben. Zwei beobachtbare Kriterien:
`make docs-check` grün **und** — im Konvergenz-Zweig — `make mutate` meldet für den neuen Fall
keinen Befund; im Abweichungs-Zweig statt dessen: die Divergenz ist an genau einer Stelle
begründet, gemessen mit
`git grep -c 'exclude-sections' -- '*.md' '*.yml' ':!.harness/baseline' ':!docs/reviews'`.

## 6. Risiken und offene Punkte

- **Die Vorschaltung könnte denselben Wächter löschen, den sie retten soll.** slice-072 hat für
  `exempt-paths` gemessen, dass es den `matrix-inactive`-Wächter über 52 ADR→ADR-Links mitnimmt;
  eine Klasse für `spec/lastenheft.md` könnte dieselbe Wirkung auf die zwei `matrix-inactive` aus
  der Ist-Messung haben, die dann still verschwänden statt gemeldet zu werden. — **Ausgang:**
  <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Der Abweichungs-Zweig ist der bequemere und darum der verdächtigere.** „Bleibt wie es ist" kostet
  nichts und ist genau deshalb die Wahl, die ohne Beleg getroffen wird; DoD (1) verlangt die Zahl
  für **beide** Wege, damit die Bequemlichkeit nicht als Begründung durchgeht. — **Ausgang:**
  <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen: → Beobachtungs-Register>
- **Die Ist-Messung altert mit der Historie-Tabelle.** Jeder neue CR fügt eine Zeile hinzu, die im
  Konvergenz-Zweig ein weiterer Befund wäre; die Zahl 16 ist am Tag des Schnitts gemessen und kein
  Erwartungswert. Wird der Slice erst spät gezogen, ist die Messung vor der Entscheidung zu
  wiederholen. — **Ausgang:** <eingetreten: CO-NNN / slice-NNN | entfallen: Grund | weiter offen:
  → Beobachtungs-Register>

## 7. Closure-Notiz

<!-- Erst nach Abschluss füllen. -->

## 8. Sub-Area-Prüfungen und Modus-Begründung

**Vorgelagert — Sub-Area-Wahl prüfen:** Berührt ist `*` (gesamtes Repo) aus der
Modus-Deklaration in [`harness/conventions.md`](../../../../harness/conventions.md) — die
Gate-Konfiguration ist repo-weit und keine der zwei feineren Sub-Areas (`harness/tools/` wird nur
im Konvergenz-Zweig um einen Mutations-Fall berührt, was die Schwelle ≥ 2 von 3 Achsen allein nicht
erreicht).

**Vorgelagert — offene Beobachtungen sichten:** Das Register
([`observations/`](../observations/)) ist durchgegangen. **Kein Eintrag trifft diesen Slice als
Sub-Area-Risiko**, und das ist die notierte Antwort. Zwei liegen inhaltlich am nächsten, ohne zu
treffen: [`BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse`](../observations/BEO-ALL/gate-sicherer-ausgang-nimmt-die-aufloesbare-adresse/observation.md)
(2×, offen) beschreibt die Wahl zwischen Ausschreiben, Stummschalten und Umformulieren einer
gate-roten Fundstelle — hier steht keine Fundstelle zur Wahl, sondern der Prüfbereich selbst; und
[`BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich`](../observations/BEO-ALL/out-of-scope-und-doku-dod-widersprechen-sich/observation.md)
(1×, offen) betrifft den Anlass dieses Schnitts, nicht seinen Gegenstand. Die Zähler-Stände sind
am Tag des Schnitts abgelesen
(`ls docs/plan/planning/observations/BEO-ALL/<slug>/evidence/*.md | wc -l`) und keine
Erwartungswerte.

**Modus-Begründungsblock:** Alle berührten Sub-Areas GF — die Gate-Konfiguration ist
Greenfield-Bestand, Doc führt und Code folgt; ein Begründungsblock pro Sub-Area entfällt damit
(Baseline-Regelwerk `modul-05-planning-harness.md` §Zwei Schritte vor der Modus-Begründung).
