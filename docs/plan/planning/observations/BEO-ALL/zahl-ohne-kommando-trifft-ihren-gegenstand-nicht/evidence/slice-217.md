**Vorgang:** slice-217
**Fund:** Der Adopter-Kopf von [`d-check.mk`](../../../../../../../d-check.mk) führt die Nachpflege
am Generat als abgezählte Liste und stellt das `diff … | grep -c '^[0-9]'`-Kommando daneben, das
die Zahl belegen soll. Mit dem fünften Handgriff schrieb der Umsetzungs-Commit *„NEU-ERZEUGUNG:
FUENF Handgriffe"* fort und ließ die Zahl daneben stehen — das Kommando liefert **8**, weil
Handgriff 5 zwei nicht benachbarte Ziele ändert und je Ziel die unveränderte `docker run`-Zeile
die geänderte Ziel-Zeile von der angehängten `@echo`-Zeile trennt. Zahl und Kommando zählten damit
zwei verschiedene Gegenstände: Handgriffe gegen Hunks. Der Kopf nennt jetzt beide Zahlen mit ihrem
Bezug (*„FUENF Handgriffe, ACHT Diff-Hunks — das Kommando zaehlt HUNKS, nicht Handgriffe"*), und
die Closure hat den Wert unabhängig nachgefahren:

```sh
D=$(grep -oE 'DCHECK_DIGEST \?= sha256:[0-9a-f]+' d-check.mk | cut -d' ' -f3)
diff <(docker run --rm --network none "ghcr.io/pt9912/d-check@$D" --print-mk) d-check.mk \
  | grep -c '^[0-9]'   # 8
```

Kein Sensor erreicht die Stelle: [`d-check.mk`](../../../../../../../d-check.mk) liegt außerhalb des
Prüfbereichs von `make comment-claims` (vier Pfad-Muster, keine `Makefile`-Form), und kein Modul aus
`modules:` der [`.d-check.yml`](../../../../../../../.d-check.yml) hält eine Zahl gegen ihr
Kommando. Träger war das Review.
