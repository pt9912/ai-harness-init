**Vorgang:** slice-d-check-pin-macht-den-range-leerfall-laut

**Fund:** Der d-check-Digest `v0.81.0` ist allein über `docker buildx imagetools inspect` und den Release-Text belegt; kein Sensor hält ihn gegen den Tag. Die Kopplungstests halten nur die zwei Pin-Stellen gegeneinander.
