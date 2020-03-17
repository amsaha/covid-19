#! /bin/bash

set -x         # prints out whatever it is executing
set -o nounset # does not allow unset variables to be used

ARGS=0        # Number of arguments expected.
E_BADARGS=65  # Exit value if incorrect number of args passed.

test $# -ne $ARGS && echo -e "\033[1mUsage: $0  \033[0m" && exit $E_BADARGS

# Get the location of the script no matter where you ran it from
SCRIPT_PATH=$(cd `dirname ${0}`; pwd)
output_dir="uploads"

url="https://www.mohfw.gov.in/"
date=`date`

curl $url -o temp

timestamp=`grep -i "as on" temp | cut -d" " -f6,8,9 |\
sed -e 's/).*P>//' -e 's/ /-/g' -e 's/:/./' -e 's/-PM/PM/' -e 's/-AM/AM/'`

total_cases=`grep "Total number of confirmed COVID 2019 cases across India" temp |\
 cut -d: -f2 | sed -e 's/^ *//g'`

active=`grep "Total number of Active" temp |\
  cut -d: -f2 | sed -e 's/ //g' -e 's/<[^>]*>//g'`
cured=`grep "Total number of Discharged" temp |\
  cut -d: -f2 | sed -e 's/ //g' -e 's/<[^>]*>//g'`
deaths=`grep "Total number of Deaths" temp |\
  cut -d: -f2 | sed -e 's/ //g' -e 's/<[^>]*>//g'`

echo "Active: ${active} Cured: ${cured} Deaths: ${deaths}"

tag=`echo ${timestamp}.A${active}C${cured}D${deaths} | sed -e 's/ //g'`

file="downloads/mohfw.$tag.html"
outfile="uploads/$tag.CSV"

cp temp $file

sed -n '/S. No/,/Total number of confirmed cases/p' $file  |\
grep -v "tr>" |\
sed -e 's/<\/td>/,/g' -e 's/<\/th>/,/g' | sed -e 's/<[^>]*>//g' |\
sed -e 's/Name of//' -e 's/Union Territory of//' -e 's/Ladakh/Leh/' |\
grep "\S" | awk '{printf $0;printf " "}NR % 6 ==0 {print " "}' |\
sed -e 's/Total Confirmed cases//g' -e 's/(//g' -e 's/)//g'|\
grep -v "Total number of confirmed cases in India" | sed -e 's/, *$//g' > $outfile

cat $outfile
