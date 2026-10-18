**Vorgang:** slice-csharp-skelett
**Fund:** Das C#-Skelett pinnt das Image per Tag (`mcr.microsoft.com/dotnet/sdk:10.0.402`); der Restore braucht beim `docker build` des Ziels Netz, und ein Paket ist transitiv ungepinnt (akzeptiertes Negativ der Skelett-ADR). Kein Lauf vergleicht zwei Bauten desselben Tags (§6 Risiko 2 und 6, Ausgang weiter offen).
