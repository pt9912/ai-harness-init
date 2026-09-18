# Architect-Verdikt, Runde 2: `slice-spec-straten-zeigen-nicht-nach-aussen` — 2026-09-18

**Rolle:** Architect (Modul 8). **Anlass:** F-1 (HIGH) des Umsetzungs-Reviews, über die Rückkante,
die das Verdikt der Runde 1 selbst benannt hat (*„weist die Sonde für einen Pfad einen heute
zurückgewiesenen Zustand durch, ist Schluss"*).

**Eingang:** der Review-Befund F-1, der `matrix:`-Block der emittierten Konfiguration im Stand
nach der Umsetzung, und das eigene Verdikt der Runde 1. **Ausgang:** Entscheidung über **eine**
Zeile der emittierten Fassung. **Keine Folge-ADR.**

> **Zitier-Form** wie in Runde 1: Kennung statt Adresse, `MR-*`/`ADR-*` als Inline-Code, ortsfeste
> Ablagen als Pfad (`AGENTS.md` §3.11). Das Verdikt der Runde 1 ist ein eingefrorener
> Rollen-Report; es wird **nicht** nachgebessert, dieser Report tritt daneben.

**Modell:** claude-opus-5 · **Datum:** 2026-09-18 · **Baseline:** `v6.9.0`.

---

## Was in Runde 1 falsch war

Die Antwort zu (b) war an den Klassen des Dogfood gemessen — dort gibt es keine Klasse `welle`,
und die Ausnahme auf die Welle-Dateien in `done/` nimmt deshalb nichts. Der Satz daneben sprach
über *die* Ausnahme, also über beide Ebenen. Das ist genau die Klasse, die `MR-055` Setzung 2
setzt: **eine Messung trägt die Stelle, die sie liest**, und was darüber hinausgeht, steht als
Urteil da oder gar nicht. Der Plan nennt dieselbe Trennung in seinem §2 und führt sie im
Beobachtungs-Register unter `emittierter-stand-laeuft-dem-dogfood-voraus`. Der Beleg dafür gehört
an den Vorgang, der ihn abschließt — die Closure dieses Slice —, nicht in diesen Report.

## Die Messung, die in Runde 1 fehlte

Die Frage ist nicht, ob die Ausnahme in der emittierten Fassung *wirkt*, sondern ob sie dort
**einen Gegenstand hat**. Gemessen am Emissions-Baum:

```sh
find internal/emit/templates -name 'welle-*' | wc -l                                          # 0
grep -rl '^\*\*Status:\*\* \(Superseded\|Deprecated\)' internal/emit/templates | wc -l        # 0
```

**Keine Erwartungswerte** — beide wandern mit dem Emissions-Bestand. Ein frisch gebootstrapptes
Ziel bekommt **keine** Welle-Datei und **keinen** abgelösten Stand; die angelegten
Lifecycle-Verzeichnisse sind leer. Die Status-Prüfung kann auf diesem Pfad dort also keinen Befund
erzeugen, den die Ausnahme verhindern müsste. **Sie nimmt beim Bootstrap nichts weg und verhindert
nichts** — sie entscheidet allein über ein Repo, dessen Bestand an dieser Stelle niemand messen
kann.

Und sobald der Adopter sein erstes Bündel schließt, nimmt sie etwas: Die emittierte Konfiguration
**führt** die Klasse `welle` auf `docs/plan/planning/**/welle-*.md`, und `done/welle-*.md` liegt
darin. Dann ist es die Senkung, die F-1 mit der Zwei-Stand-Sonde zeigt — nur eben in einem Repo,
in dem niemand mehr hinsieht: die emittierte Gate-Konfiguration ist *skip-if-present*, ein
Re-Lauf rührt sie nicht an (`MR-054` Setzung 5).

## Entscheidung

**Der Pfad `docs/plan/planning/done/welle-*.md` fällt aus `exempt-paths` der emittierten
Konfiguration.** Die zwei übrigen bleiben dort: Für den ADR-Index und die Review-Reports führt
auch die emittierte Fassung keine Klasse außer der neuen `aussen` — sie nehmen nur, was diese
hinzufügt, und das ist nach dem Kriterium aus Runde 1 keine Senkung.

**Im Dogfood bleibt der Pfad stehen.** Dort gibt es keine Klasse `welle`; der Review hat die drei
Dogfood-Pfade mit der Sonde über beiden Ständen bestätigt. Die Asymmetrie ist kein Versehen,
sondern die Folge zweier verschiedener Klassen-Sätze — und sie gehört in der emittierten Datei
**benannt**, sonst zieht der nächste Lauf sie glatt.

**Drei Gründe, und der dritte ist der, der über den heutigen Bestand hinaus trägt:**

1. **Kein Gegenstand.** Die Messung oben: nichts, worauf sie am ersten Tag wirken könnte.
2. **Ein unbelegbarer Beleg.** Bliebe sie, wäre sie eine Senkung nach `AGENTS.md` §3.5 und
   bräuchte ihre ADR *mit gemessenem Beleg*. Der ist hier nicht zu nehmen: Er läge im Bestand des
   Adopters, und eine Messung an dieser Stelle trüge ihn nicht (`MR-055` Setzung 2). Eine ADR,
   deren Beleg struktur­bedingt fehlt, ist die teurere **und** die schwächere Antwort.
3. **Die Fehlrichtung ist entschieden.** `MR-017` setzt für unbekannte Adopter den fail-closed
   Default: *„ein zu **strenger** Default wird beim ersten Lauf rot und kostet eine Glob-Zeile in
   einer Datei, die dem Adopter gehört … Ein zu **lascher** Default lässt einen Bereich ungeprüft
   — und meldet sich **nie**."* Eine mitgelieferte Ausnahme ist der lasche Default in Reinform:
   Sie meldet sich nie, und der Adopter erfährt nie, dass er sie hat.

**Keine ADR nötig.** Das Streichen stellt den Zustand her, den die emittierte Fassung ohne diesen
Slice hätte — eine Senkung wird zurückgenommen, nicht eine gesetzt. ADR-pflichtig wäre das
Gegenteil (`AGENTS.md` §3.5 gilt für Senkungen), und für das Gegenteil fehlt der Beleg, siehe
Grund 2.

## Auftrag an den Implementer

Das Template ist dein Artefakt; hier steht, was daran zu ändern ist.

1. **`docs/plan/planning/done/welle-*.md` aus `exempt-paths` der emittierten Konfiguration
   entfernen.** Die zwei übrigen Pfade bleiben.
2. **Den Kommentar darüber nachziehen** — er nennt heute drei Pfade und begründet den dritten mit
   seiner Lifecycle-Rolle. Nach der Änderung sind es zwei.
3. **Die Abwesenheit als begründeten Kommentar stehen lassen, nicht als Leerstelle.** Zwei Sätze:
   dass die Welle-Dateien in `done/` hier **bewusst** keine Ausnahme haben, weil die emittierte
   Fassung die Klasse `welle` führt und eine mitgelieferte Ausnahme dort eine Senkung im
   Adopter-Repo wäre; und dass der Adopter sie selbst setzen kann — die Datei gehört ihm, sie ist
   skip-if-present. Das ist die Form, die `MR-054` Setzung 3 für ausgelassene Positionen führt:
   *„Der Adopter liest damit eine Entscheidung und ihre Bedingung; eine Leerstelle sähe aus wie
   ein Versäumnis."*
4. **Die Sonde je Ebene fahren, mit den Klassen dieser Ebene.** Die Zwei-Stand-Sonde aus Runde 1
   gilt unverändert — aber die Emissions-Sonde misst gegen die **emittierten** Klassen. Eine am
   Dogfood genommene Messung ist keine Aussage über das Ziel und umgekehrt.
5. **`make full-smoke` erneut grün fahren.** Nach der Messung oben trägt ein frisches Ziel weder
   Welle-Datei noch abgelösten Stand; ein Befund aus dem gestrichenen Pfad ist dort nicht zu
   erwarten. *Erwartet* ist nicht *gemessen* — der Lauf entscheidet.
6. **Unverändert bestätigt:** die drei `exempt-paths` des Dogfood und die enge `slice`-Klasse. Die
   macht dieser Report nicht neu auf.

## Grenze, und sie bleibt offen

**Kein Gate fängt die Ebenen-Verwechslung.** Kein Modul der Gate-Konfiguration hält
`exempt-paths` gegen die Klassen derselben Datei, und keines hält die zwei Konfigurationen
gegeneinander — dieselbe Lage, die `MR-054` für sein Kriterium 1 feststellt. Ein solcher Wächter
wäre eine Anforderung an das Werkzeug, kein Gegenstand dieses Slice. Träger ist bis dahin der
Rollen-Wechsel vor der Änderung — in diesem Fall hat er getragen: Der Review fand den Befund, den
der bauende Lauf und das Verdikt der Runde 1 beide nicht sahen.
