**Vorgang:** slice-224
**Fund:** Der Plan trägt 552 Zeilen, davon eine Tabelle mit 42 Beleg-Zeilen, und sein §6 hatte
genau dieses Wachstum vorab als Risiko benannt:

```sh
wc -l docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md
git grep -cE '^\| `lab/' -- docs/plan/planning/done/slice-224-delta-nachweis-und-planungs-nachzug.md
```

**Keine Erwartungswerte** ([`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2). Die vorab benannte Antwort — Rückführung `in-progress → next` — wurde nicht gezogen,
und der Slice ist geliefert; das Wachstum hat sich aber an den **prüfenden** Rollen gezeigt statt
an der Umsetzung. Der zweite Review-Durchgang schnitt sich ausdrücklich eng (*„Kein zweiter
Durchgang über die 42 Posten"*), und die Verifikation nennt ihre Stichprobe selbst: 33 der 42
Posten sind nicht einzeln gegen den Kurs-Diff gelesen worden.

Das ist die Klasse aus der Prüf-Richtung: Nicht die Umsetzung liest weniger, als der Plan trägt —
die Prüfung tut es, und sie sagt es dazu. Ein Plan, dessen Beweisführung nur stichprobenweise
gegengelesen werden kann, verlagert das Urteil von zwei Rollen zurück auf eine.
