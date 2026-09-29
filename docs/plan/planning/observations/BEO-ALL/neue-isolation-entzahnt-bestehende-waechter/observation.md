# Neue Isolation entzahnt bestehende Wächter

**Sub-Area:** `*` (gesamtes Repo)

Eine Isolations-Änderung an einer Ausführungsstelle (Netz-Ausschluss, Dateisystem-Sperre,
Ressourcen-Deckel) kann einen bestehenden Wächter stumm machen, ohne ihn anzufassen: der mutierte
Pfad scheitert an der Isolation, **bevor** er das Verhalten erreicht, dessen Abwesenheit der
Wächter messen soll. Der Wächter bleibt grün und der Mutations-Fall färbt nicht — nicht, weil die
Mutation wirkungslos ist, sondern weil die Differenz unter der Isolation nicht mehr entsteht. Am
geprüften Code ist nichts falsch, und kein Test fällt. Nach jedem Isolations-Umbau sind die
Wächter der betroffenen Stelle gegen ihre Mutations-Fälle neu zu fahren, bevor ihr Grün als
unverändert gelesen wird.
