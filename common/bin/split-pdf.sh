#!/bin/zsh

if [ -z $1 ]
then
  echo "Missing arg: PDF file to split"
  exit 0
fi
Name=$(echo $1 | cut -f1 -d '.')
mkdir -p $Name
NumberOfPages=$(pdftk $1 dump_data | grep "NumberOfPages" | sed 's/[^0-9]*//')

for Page in {1..$NumberOfPages}
do
    OutputFile=$Name-$Page.pdf
    pdftk $1 cat $Page output $Name/$OutputFile
done

