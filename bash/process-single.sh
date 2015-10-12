#!/bin/bash

FILE="$1"
FILENAME=$(basename $FILE)

dim=`convert "$FILE" -format "%w:%h" info:`
arrDim=(${dim//:/ })

#auto-orient photo to correct rotation
convert "$FILE" -auto-orient ready/"$FILENAME"

f="ready/$FILENAME"

if (( ${arrDim[0]} > ${arrDim[1]} )); then
  size="1167x864"
  orient="landscape"
  convert "$f" -resize $size^ -gravity center -extent $size tmp/$FILENAME.resize.mpc
  #if landscape rotate to fit template
  convert tmp/$FILENAME.resize.mpc -rotate 270 tmp/$FILENAME.resize.mpc
else
  size="864x1167"
  orient="portrait"
  convert "$f" -resize $size^ -gravity center -extent $size tmp/$FILENAME.resize.mpc
fi

echo $orient

#duplicate side by side
composite tmp/$FILENAME.resize.mpc -geometry +18+18 base.png tmp/$FILENAME.temp.mpc
composite tmp/$FILENAME.resize.mpc -geometry +896+18 tmp/$FILENAME.temp.mpc tmp/$FILENAME.temp.mpc

#save to print queue
composite templates/$orient.png  tmp/$FILENAME.temp.mpc printq/$FILENAME

#move original to printed folder
mv "$f" printed/$FILENAME

rm tmp/$FILENAME.resize.mpc tmp/$FILENAME.resize.cache tmp/$FILENAME.temp.mpc tmp/$FILENAME.temp.cache
#send to print
lpr -o landscape -o fit-to-page -o media="Postcard(4x6in)" printq/$FILENAME
echo "Printing $f"