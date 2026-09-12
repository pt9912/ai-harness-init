# `make hook-overhead` — misst den Aufschlag je Tool-Call

## Vertrag

Misst den Aufschlag je Tool-Call — die Wanduhr-Zeit **eines** Träger-Aufrufs, nicht die des
Tool-Calls, den er beobachtet — und hält ihn gegen die Schwelle aus
[`ADR-0011`](../../docs/plan/adr/0011-telemetrie-erfassung-policy.md) (*50 ms im Median*);
geschuldet von [`ADR-0022`](../../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md)
Folgepflicht 9. Eine Messung, kein Gate — in keiner Prerequisite-Kette: ein Latenz-Gate wäre auf
einem geteilten Runner rot ohne Befund und grün ohne Deckung
([`LH-QA-01`](../../spec/lastenheft.md#lh-qa-01--keine-halluzinierten-gates-f4-f5-f6)).

## Grenze — was das Grün nicht abdeckt

`harness/tools/hook-overhead.sh` spielt eine **reale** Folge von Tool-Calls aus dem
Span-Bestand nach — Ereignis-Art, Werkzeug-Mischung, Reihenfolge und Ergebnis-Größe je Aufruf
stammen aus einem echten Strom, nachgebaut sind Kommando-Text und Ergebnis-Inhalt, die kein
Span trägt; ohne Bestand bricht der Lauf ab, statt eine Folge zu erfinden. Der gemessene
Stand steht mit seinen Bedingungen und seinen Kommandos im Kopf jenes Skripts, nicht hier: die
Zahl gilt dem Host, auf dem sie entstand.

## Bindung

Kein Gate-Versprechen; gebunden an
[`ADR-0011`](../../docs/plan/adr/0011-telemetrie-erfassung-policy.md)/[`ADR-0022`](../../docs/plan/adr/0022-erfassungsschicht-traeger-aus-dem-produkt-binaer.md).
