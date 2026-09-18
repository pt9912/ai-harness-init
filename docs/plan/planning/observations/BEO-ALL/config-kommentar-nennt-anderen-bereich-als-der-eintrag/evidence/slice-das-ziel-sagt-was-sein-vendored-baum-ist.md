**Vorgang:** slice-das-ziel-sagt-was-sein-vendored-baum-ist
**Fund:** Der emittierte Satz ueber den mitgelieferten Baum beruft sich auf `scan.ignore: .harness/**` der emittierten `.d-check.yml`; deren Begruendung nennt allein das gefetchte Sprachskelett-Staging und nicht den vendored Baum, den derselbe Schluessel mit ausnimmt (R2-2).
