# Spec nennt den Lieferstand statt des Zielbilds

**Sub-Area:** `*` (gesamtes Repo)

Ein Satz in Lastenheft, Spezifikation oder Architektur-Sicht sagt, wann etwas geliefert wird oder wurde
(*folgt*, *real ab v…*, *heute*, *erst mit*), statt was gilt. Die Specs definieren das Zielbild; ein Leser
liest den Zeitbezug als Zusage über den Stand der Lieferung.

## Benannt, nicht gezählt

**Die Lieferstand-Frage gehört nicht in die Specs.** Dass `python`, `java` und `csharp` kein Profil in
`internal/gen/` tragen, während die Sprachliste in [`LH-FA-04`](../../../../../../spec/lastenheft.md#lh-fa-04--sprachskelett-picker-f4) das Zielbild nennt, ist Rückverfolgbarkeit
(`make doc-trace`, `trace:` in der [`.d-check.yml`](../../../../../../.d-check.yml)). `slice-192-rtm-sieht-alle-anforderungen`
trägt den Gegenstand nicht: er richtet die Matrix auf **Anforderungen**, nicht auf Teilabdeckung innerhalb einer Anforderung.
