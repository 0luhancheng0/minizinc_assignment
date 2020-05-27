#!/bin/bash
set -e
model=${1:-'cargoD.mzn'}
out=${2:-'out.txt'}
rm -f $out
timeout=${3:-60}
for dataf in $(ls data/*.dzn);
do
    echo "*********************************************************************************************" | tee -a  $out
    echo "Checking against $dataf" | tee -a  $out
    cat $dataf | tee -a $out
    #minizinc models/${model} models/*.mzc $dataf --solver Chuffed --time-limit 60000  | tee -a  $out
    minizinc models/${model} models/*.mzc $dataf --solver Chuffed --time-limit 60000 --all-solutions  | tee -a  $out
    echo $'*********************************************************************************************\n\n' | tee -a  $out
done
set +e
