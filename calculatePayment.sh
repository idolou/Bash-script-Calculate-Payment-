#!/bin/bash
# will close the script in case err accured
set -e


#function to round number 
round()
{
echo $(printf %.$2f $(echo "scale=$2;(((10^$2)*$1)+0.5)/(10^$2)" | bc))
};

err=false

#checck if there are more than 2 parameters 
if [ ${#} -lt 2 ];
then 1>&2 echo "Number of parameters received : ${#}"
echo "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>"
exit 1
fi


#check if the last arg(the number) is valid)

#first check if it contains somthing other then numbers
check2=true
re='^[0-9]+([.][0-9]+)?$'
if ! [[ ${!#} =~ $re ]]; then
1>&2 echo "Not a valid number : ${!#}"
echo "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>"
check2=false
exit 1
fi

#second check if its greater then 0
if $check2; then
    if [ $(echo "${!#}>0" | bc) -eq 0 ]; then
    1>&2 echo "Not a valid number : ${!#}"
    echo "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>"
    exit 1
fi
fi


#check if all files exist
for ((i=1; i<$#; i++)); do
     if [ ! -f "${!i}" ]; then
     err=true
     1>&2 echo "File does not exist : ${!i}" 
     fi
     done

#after all checks done if there was an error print help massege
if  $err; then
    echo "Usage : calculatePayment.sh <valid_file_name> [More_Files] ... <money>"
    exit 1
    fi




#sum all the numbers from files
SUM=''
for ((i=1; i<$#; i++)); do
    if [[ -s "${!i}" ]]; then
        if  grep -q -o '[0-9]' "${!i}" ; then
    adder="`grep -Eo "?[0-9]+([.][0-9]+)?" "${!i}" | paste -sd+ | bc`"
    SUM+="$adder+"
    fi
    fi
done
SUM+="0"

res=$(echo $SUM | bc)
res=$(echo $(round $res 2))
echo "Total purchase price : $res"



if [ $(echo "$res==${!#}" | bc) -eq 1 ]; then
echo "Exact payment"
fi

if [ $(echo "$res<${!#}" | bc) -eq 1 ]; then
change=$(echo "${!#}-$res" | bc)
change=$(echo $(round $change 2))
echo "Your change is $change shekel"
fi


if [ $(echo "$res>${!#}" | bc) -eq 1 ]; then
to_add=$(echo "$res-${!#}" | bc)
to_add=$(echo $(round $to_add 2))
echo "You need to add $to_add shekel to pay the bill"
#echo "You need to add $(echo "$res-${!#}" | bc) shekel to pay the bill"
fi


