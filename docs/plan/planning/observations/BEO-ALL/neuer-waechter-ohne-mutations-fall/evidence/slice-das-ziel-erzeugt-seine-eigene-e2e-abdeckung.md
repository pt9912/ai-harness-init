**Vorgang:** slice-das-ziel-erzeugt-seine-eigene-e2e-abdeckung
**Fund:** Der Slice fügt in `test/e2e-abdeckung.bats` zwölf Fälle hinzu; in
`test/mutations/` liegt davon **einer** —
`363-ziel-e2e-stufe-ohne-deklaration.sh`, vom Verifier gefahren und rot gesehen
(`not ok 122`, Ursache gelesen). §6 Risiko 4 des Plans führte den Posten im **Singular**
(*„Der neue Wächter"*) und traf damit die gebaute Menge nicht.

```sh
grep -c '^@test' test/e2e-abdeckung.bats                             # 17
grep -l 'e2e-abdeckung\|e2e_abdeckung' test/mutations/*.sh | wc -l   #  2
```

**Keine Erwartungswerte** — beide wandern mit dem Baum.

Namentlich ungelistet bleiben: der Hinweis auf die fehlende Spec-Datei (der Fall, den
`ac814e63` überhaupt erst herstellte), die Lenkung der vier Marker, die Trennlinie
Code-Span gegen Verweis, der Halter auf die Spaltenfolge und die zwei Kopplungs-Träger,
die §6 Risiko 3 den Ausgang *entfallen* geben. Die Wächter laufen und sind grün;
ungemessen ist ihre **Haltbarkeit** — `make mutate` urteilt über seinen eigenen Fall-Satz,
und wer keinen Fall darin hat, ist unbewacht (`AGENTS.md` §3.6).
