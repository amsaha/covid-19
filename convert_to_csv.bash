#! /bin/bash

set -x         # prints out whatever it is executing
set -o nounset # does not allow unset variables to be used

ARGS=1        # Number of arguments expected.
E_BADARGS=65  # Exit value if incorrect number of args passed.

test $# -ne $ARGS && echo -e "\033[1mUsage: $0 <input_file>\033[0m" && exit $E_BADARGS

# Get the location of the script no matter where you ran it from
SCRIPT_PATH=$(cd `dirname ${0}`; pwd)
output_dir="uploads"

input_file=$1
file=`basename $input_file`
sed -e 's/	/,/g' -e 's/Name of//' -e 's/Union Territory of//' -e 's/Ladakh/Leh/' -e 's/Total Confirmed cases//g' -e 's/(//g' -e 's/)//g' $input_file | cut -d, -f2,3,4,5,6 > $output_dir/$file.csv
