#!/bin/bash

FILES="ready/*.jpg"
REPLACE="printq/"
FINISHED="printed/"
count=`find ready/*.jpg -print | wc -l`
if (( $count == 0 )); then
  echo "no pics"
  exit 1
fi
for f in $FILES
do
  dim=`convert "$f" -format "%w:%h" info:`
  arrDim=(${dim//:/ })

  #auto-orient photo to correct rotation
  convert "$f" -auto-orient "$f"
  
  if (( ${arrDim[0]} > ${arrDim[1]} )); then
    size="1167x864"
    orient="landscape"
    convert "$f" -resize $size^ -gravity center -extent $size resize.jpg
    #if landscape rotate to fit template
    convert resize.jpg -rotate 270 resize.jpg
  else
    size="864x1167"
    orient="portrait"
    convert "$f" -resize $size^ -gravity center -extent $size resize.jpg
  fi

  echo $orient
  
  #duplicate side by side
  composite resize.jpg -geometry +18+18 base.png temp.mpc
  composite resize.jpg -geometry +896+18 temp.mpc temp.mpc

  #save to print queue
  filename="${f/ready\//$REPLACE}"
  composite $orient.png  temp.mpc $filename

  #move original to printed folder
  finishedname="${f/ready\//$FINISHED}"
  mv "$f" $finishedname
  
  #send to print
  #lp $finishedname
  echo "Printing $f"
done