**Vorgang:** slice-sprung-auf-v680-wird-vollzogen
**Fund:** `docs/migrations/v6.8.0.md` berichtete *„alle 25 Vorlagen sind über die zwei Tags
byte-gleich"* und belegte damit den Ausgang *schon erfüllt* für jede Zeile. Die Messung stammte
aus [`ADR-0047`](../../../../../../../docs/plan/adr/0047-ziel-fassung-regiert-den-sprung-v680.md) §Kein Vorlagen-Delta und war am Kurs-Klon genommen
(`git -C "$K" diff --name-only v6.7.2..v6.8.0 -- lab/templates | wc -l` → **0**); über die zwei
**vendorten** Bäume dieses Repos trifft sie für **2** von **25** Vorlagen nicht zu:

```sh
for rel in $(git ls-tree -r --name-only f8e602b7 -- .harness/baseline/v6.8.0/templates \
             | sed 's#^\.harness/baseline/v6\.8\.0/templates/##'); do
  a=$(git show "f8e602b7^:.harness/baseline/v6.7.2/templates/$rel" | sha256sum)
  b=$(git show "f8e602b7:.harness/baseline/v6.8.0/templates/$rel"  | sha256sum)
  [ "$a" = "$b" ] || echo "$rel"
done
# -> AGENTS.template.md
# -> harness/conventions.template.md
```

Beide unterscheiden sich in **einer** Zeile, dem Beispiel-Link auf das Release-Asset. Gefunden hat
es die Verifikation, kein Sensor — die Zeilen-Klassifikation blieb richtig, der zitierte Beleg
nicht; er ist in `c9e23496` auf die präzise Aussage gezogen.
