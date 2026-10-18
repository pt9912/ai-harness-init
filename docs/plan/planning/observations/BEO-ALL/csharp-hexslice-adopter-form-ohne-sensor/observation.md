# C#-hexslice: Adopter-Form, die das Arch-Gate nicht sieht, ohne Sensor

**Sub-Area:** `*` (gesamtes Repo)

Das emittierte C#-Arch-Gate hängt an Schreibweisen und Formen, die beim Adopter kein Sensor hält: die kleine Schreibweise des Richtungs-Segments
(`inbound`/`outbound`; groß geschrieben bleibt `make gates` grün und `port-locality` geht für den Port verloren), die Gegenrichtung
(Verzeichnis klein, Namensraum groß — rot nur, wenn ein Adapter den Port importiert), ein voll qualifizierter Name ohne `using`, `<Using>` im
`.csproj` und Reflection (Grenze von a-check am Pin). Der Renderer ist durch Text-Wächter und Lauf-Zahn gehalten, der Adopter-Code nicht;
die Grenze steht in Config-Kommentar und Abdeckungs-Zeile. Auflösung der Klasse wäre eine Anforderung an a-check
(Alternative C der [`ADR-0097`](../../../../adr/0097-csharp-hexslice-richtungs-ordner-klein.md), Re-Evaluierungs-Trigger 1).
