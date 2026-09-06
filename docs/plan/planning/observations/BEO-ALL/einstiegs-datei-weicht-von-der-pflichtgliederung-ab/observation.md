# Einstiegs-Datei weicht von der Pflichtgliederung ab

**Sub-Area:** `*` (gesamtes Repo)

Die Pflichtgliederung für die Einstiegs-Datei (Baseline-Regelwerk
[`grundlagen-harness-dateien.md`](../../../../../../.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md)
§harness/README.md als Einstiegspunkt) nennt **acht** Sektionen;
[`harness/README.md`](../../../../../../harness/README.md) führt sieben, und die ohne Gegenstück
ist `## Safety and scope boundaries` (*repo-spezifische Hard Rules*). Dieselbe Quelle schreibt
`## Sensors` als **Tabelle** der Feedback-Gates vor; hier läuft die Sektion als Fließtext-Fläche
um eine kleine Tabelle herum. Beides zusammen ist plausibel die **Ursache** der Nachbar-Klasse
[`benannte-luecke-ohne-ausgang`](../benannte-luecke-ohne-ausgang/observation.md): Der Inhalt, der
sich dort ablagert, hatte keinen vorgesehenen Ort.

## Benannt, nicht gezählt

Aufgefallen in einer Koordinations-Sitzung, nicht in einem abgeschlossenen Vorgang. Der Bestand
ist am eingefrorenen Stand `c43a759` erhoben, die Baseline-Seite am vendored Tag `v6.0.0` — beide
Adressen sind fest, die Zahlen darum keine Erwartungswerte über den lebenden Baum:

```sh
B=.harness/baseline/v6.0.0/regelwerk/grundlagen-harness-dateien.md
awk '/^### harness\/README.md als Einstiegspunkt/,/^### harness\/conventions.md/' "$B" \
  | grep -c '^## '                                                          # 8  vorgeschriebene Sektionen
grep -c '^## Sensors  *# Tabelle der Feedback-Gates (nur real existierende!)$' "$B"   # 1  Sensors ist als Tabelle vorgeschrieben

git show c43a759:harness/README.md | grep -c '^## '                                  # 7  vorhandene Sektionen
git show c43a759:harness/README.md | grep -c '^## Safety and scope boundaries'       # 0  (Exit 1) — die fehlende
```

Die sieben vorhandenen tragen die vorgeschriebenen Inhalte unter leicht erweiterten Überschriften
(`## Guides (Feedforward)`, `## Sensors (Feedback-Gates)`, `## Traceability`); die Differenz von
acht zu sieben hängt an der einen fehlenden Sektion, nicht an diesen Zusätzen. Wie weit die
Sensors-Sektion über ihre Tabelle hinausgewachsen ist, misst die Nachbar-Klasse.

**Offen und hier nicht entschieden:** ob das eine erklärungsbedürftige Baseline-Abweichung ist,
die nach [`MR-000`](../../../../../../harness/conventions.md#mr-000--baseline-aussage) einen
Eintrag im Adaptions-Block verlangt, oder eine Form-Schuld ohne Adaptions-Charakter. Diese Frage
liegt beim Architect ([`AGENTS.md`](../../../../../../AGENTS.md) §3.8); dieser Eintrag
registriert sie, er beantwortet sie nicht.
