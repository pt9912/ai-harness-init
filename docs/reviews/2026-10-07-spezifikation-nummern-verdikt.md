# Verdikt: Abschnittsnummern der Spezifikation gegen die Gliederung der Vorlage

**Rolle:** Architect · **Bezug:** [ADR-0078](../plan/adr/0078-ziel-fassung-regiert-den-sprung-v6160.md)
(Zeile Welle 158) · `spec/spezifikation.md` §Aufnahme-Regel, Formregel *„Abschnittsnummern werden nie
neu vergeben"* · Commit `7978f3ca`.

## Befund

Die Regel ist **verletzt, nicht unanwendbar**: §7 trug die Historie und trägt jetzt *Festlegungen der
Harness-Werkzeuge*; die Historie ist §8. Die Vorlage `v6.16.0` setzt genau diese Gliederung
(`grep -n '^## ' .harness/baseline/v6.16.0/templates/spec/spezifikation.template.md` → `7. Festlegungen
der Harness-Werkzeuge`, `8. Historie`), und ADR-0078 hat den Umzug ausdrücklich entschieden. Die Regel
steht in Rang 2, die ADR in Rang 4 — die ADR deckt den Bruch nicht.

Gemessen, was der Grund der Regel schützt (Zeiger von außen):

```sh
git grep -c '7-historie' -- .                                   # (keine Ausgabe) — 0 Links, auch eingefroren
git grep -ohE 'spezifikation\.md#[a-z0-9-]+' -- . ':!.harness/baseline' | sort -u
# #3-defaults-und-konstanten  #5-metriken  #5-metriken-und-tracing-felder  #aufnahme-regel
```

Kein Markdown-Link trifft den verschobenen Anker; der einzige (intern) ist auf `#8-historie` gezogen.
Bare Text-Nennungen „§7" für die Historie stehen in drei Zeitdokumenten
(`slice-193-baum-tausch-v650-pins-ziehen`, `slice-spec-straten-zeigen-nicht-nach-aussen`, Verifikation
vom 2026-09-18 samt `sed -n '/^## 7\. Historie/,$p'`, das heute leer ausgibt).
`.d-check.yml` `matrix.exclude-sections` behält `"7. Historie"` zu Recht: `spec/lastenheft.md:644`
und die Lastenheft-Vorlage führen die Historie weiter als §7.

## Verdikt — (b) Die Regel wird geändert, nicht die Gliederung

1. **Nicht (c).** Historie auf §7 zu halten widerspricht der Ziel-Form, die ADR-0078 übernimmt, und
   verlangte einen dauerhaften `MR` (Abweichung von der Vorlage) plus abweichende Kommentare in der
   Emission — mehr Aufwand für einen Schutz, dem nach der Messung kein Link gegenübersteht.
2. **Neue Fassung der Formregel** (Vorschlag, Bedeutung bindend, Wortlaut frei):
   *„Abschnittsnummern werden nicht neu vergeben, außer die Gliederung der adoptierten Vorlage setzt
   sie neu. Dann misst der Lauf vor der Umnummerierung über beide Adress-Formen (Link und Code-Span),
   ob ein eingefrorenes Artefakt den Anker nennt; findet er einen, gehört die Entscheidung vor die
   Umnummerierung."* — die Linie aus [`AGENTS.md`](../../AGENTS.md) §3.11, auf Anker angewandt.
   Dazu eine Zeile in §8 Historie.
3. **Wer schreibt.** Für `spec/spezifikation.md` benennt keine Quelle eine schreibende Rolle
   (§3.8 lässt das offen; ADR-0015 nennt sie nicht). Fortgeschrieben wird sie im Slice — hier
   `slice-werkzeug-festlegungen-ziehen-in-die-spezifikation`, dessen Kopf die Aufnahme-Regel nicht
   als berührte Stelle führt. Darum: **Planner** nimmt die Stelle in Kopf und Liefer-Punkt 2 auf
   (dieses Verdikt ist das Übergabe-Artefakt), **Implementer** schreibt den Satz. Kein ADR, kein `MR`:
   die Regel ist repo-eigen, die Änderung folgt ADR-0078.

## Akzeptiertes Negativ

Die drei bloßen „§7"-Nennungen in Zeitdokumenten bleiben stehen: sie sind datiert, kein Sensor liest
sie, und `git` hält die damalige Gliederung. Kein Register-Eintrag, kein Folge-Slice.
