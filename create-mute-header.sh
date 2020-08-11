#!/usr/bin/env bash
##
# Generates USRVMuteSwitchDetectionAiff.h based on the input file

muteSwitchDetectionAiff=$1

if [ ! -f $muteSwitchDetectionAiff ]; then
	echo "Input file $muteSwitchDetectionAiff not found. Exiting";
    exit 1;
fi;

path="UnityServices/Core/Device/USRVMuteSwitchDetectionAiff.h"
if [[ -f $path ]]; then
	rm $path;
fi;

echo "/**" > $path
echo " * This file is auto-generated using \"make generate-mute-detection-header\"." >> $path
echo " * It contains the byte data and length for $muteSwitchDetectionAiff" >> $path
echo " *" >> $path
echo " * Manual changes should NOT be made to this file." >> $path
echo " */" >> $path
echo "" >> $path
xxd -i $muteSwitchDetectionAiff >> $path
