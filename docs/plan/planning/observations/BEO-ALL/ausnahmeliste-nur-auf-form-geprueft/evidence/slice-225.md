**Vorgang:** slice-225
**Fund:** Der Wechsel von `targets.authority` auf `harness/README.md` hat **17** der **37**
Einträge in `exempt-targets` ihre autoritative Wirkung genommen, ohne dass ein Wächter das
gemeldet hätte — sie stehen seither als Zeile im Index **und** in der Ausnahmeliste:

```sh
comm -12 <(sed -n '/^targets:/,/^ignore-refs:/p' .d-check.yml | grep '^    - ' | sed 's/^    - //' | sort -u) \
         <(grep -E '^\|.*`make [a-z][a-z0-9-]*`.*\|$' harness/README.md | grep -oE '`make [a-z][a-z0-9-]*`' \
           | tr -d '`' | sed 's/^make //' | sort -u) | wc -l
# 17
```

**Kein Erwartungswert** ([`MR-025`](../../../../../../../harness/conventions.md#mr-025--eine-zahl-im-text-steht-neben-dem-kommando-das-sie-liefert)
Setzung 2) — die Zahl wandert mit beiden Listen.

Das Modul prüft die Liste auf Form: Steht ein Rezept nicht in der `authority`-Datei, muss es hier
stehen. Es prüft **nicht**, ob ein Eintrag darin noch etwas bewirkt. Ein Eintrag, der seine
Wirkung verloren hat, ist für den Wächter ununterscheidbar von einem, der trägt — und eine Liste,
in der beide Sorten nebeneinanderliegen, sagt über keinen ihrer Einträge mehr etwas.

Der Slice-Plan hatte die Lage als Risiko vorab benannt (*„17 der 37 `exempt-targets` stehen künftig
als Zeile im Index und brauchen die Ausnahme nicht mehr; sie stehen zu lassen ist still grün"*).
Aufgefallen ist sie trotzdem nicht dem Gate, sondern dem Review. Die Gegenrichtung ist seitdem
bewacht — ein bats-Fall hält fest, dass kein `exempt-targets`-Eintrag zugleich eine
Sensors-Tabellenzeile ist —, und das ist die Kompensation aus
[`ADR-0045`](../../../../../adr/0045-authority-wechsel-senkt-eine-richtung.md) Festlegung 2, nicht
eine inhaltliche Prüfung der Liste.
