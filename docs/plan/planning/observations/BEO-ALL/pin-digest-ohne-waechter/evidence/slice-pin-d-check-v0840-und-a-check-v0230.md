**Vorgang:** slice-pin-d-check-v0840-und-a-check-v0230

**Fund:** Die Index-Digests von d-check `v0.84.0` und a-check `v0.23.0` sind allein über `docker buildx imagetools inspect` belegt; kein Sensor hält einen Digest gegen seinen Tag, die Kopplungstests halten nur die Pin-Stellen gegeneinander.
