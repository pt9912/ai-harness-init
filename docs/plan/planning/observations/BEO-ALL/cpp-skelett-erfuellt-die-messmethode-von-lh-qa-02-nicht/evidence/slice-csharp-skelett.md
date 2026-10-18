**Vorgang:** slice-csharp-skelett
**Fund:** Das C#-Skelett pinnt das Image per Tag (`mcr.microsoft.com/dotnet/sdk:10.0.402`); der Restore braucht beim `docker build` des Ziels Netz, und ein Paket ist transitiv ungepinnt (ADR-0096, akzeptiertes Negativ). Kein Lauf vergleicht zwei Bauten desselben Tags (§6 Risiko 2 und 6, Ausgang weiter offen).
