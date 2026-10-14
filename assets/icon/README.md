# Icône

`ic_launcher.svg` est la source : une page blanche à lignes de texte, sur fond
noir. Noir et blanc comme le reste de l'application, lisible à 48 px, qui évoque
à la fois l'article et le livre.

Régénérer les PNG Android après toute modification :

```bash
for d in mdpi:48 hdpi:72 xhdpi:96 xxhdpi:144 xxxhdpi:192; do
  n=${d%%:*}; s=${d##*:}
  magick -background none -density 400 assets/icon/ic_launcher.svg \
    -resize ${s}x${s} android/app/src/main/res/mipmap-$n/ic_launcher.png
done
```
