**Vorgang:** slice-c7-adaptions-nachzuege-v7-0-0

**Fund:** Review [`docs/reviews/2026-11-25-slice-c7-adaptions-nachzuege-v7-0-0.md`](../../../../../../reviews/2026-11-25-slice-c7-adaptions-nachzuege-v7-0-0.md) F-1 (MEDIUM):
der Rot-Lauf des zehnten `ignore-refs`-Paars (Restbreite-Befund über der
Isolationskopie `git archive HEAD`, `sed -i '410s/# Deckung: 1/#
Deckung: 2/'`) war in keinem Übergabe-Artefakt dokumentiert — die
Commit-Meldung `8243ead5` nannte allein den Grün-Lauf, das Plan-§7a trug die
`adr-immutable`-Proben. Healed im Plan-§7a (Commit `612f8ec5`): der Rot-Lauf
steht dort als Text samt beobachteter Befund-Zeile; der Auftrags-Wortlaut des
Laufs („`Deckung: 2` → 4 Befund, revertiert") entspricht an der Form nicht der
beobachteten Ausgabe (ein Paar-Befund je Lauf).

**Klass-Fassung (C5):** *Übergabe-Beleg steht nur im Neben-Kontext* — hier der
Neben-Kontext Commit-Meldung statt Lauf-Kontext; die Form bleibt dieselbe:
der Beleg trägt das Plan-§7 je
[`MR-051`](../../../../../../../harness/conventions.md#mr-051--der-zahl-beleg-bindet-die-commit-message-und-ein-register-zähler-ist-eine-datierte-messung)-Form, nicht die Meldung. Zweites Auftreten
derselben Beobachtung; der Stand des Eintrags (*verkörpert* seit
[`slice-c5-vertrauensgrenzen-v7-0-0`](../../../../done/slice-c5-vertrauensgrenzen-v7-0-0.md)) bleibt.
