#!/bin/sh

#echo "start info"

old_modules_list=(
"CPCSP_Pr.dll"
"QMargin.dll"
"OpenSSL_Pr.dll"
"QCtrls.dll"
"QHtmlRep.dll"
"MP_Pr.dll"
)

for module in ${old_modules_list[@]};
do
 #   echo "process $module"
	if [ -f ./$module ]; then
		module_name="./$module"
		lower_case_module=`echo $module_name | tr '[:upper:]' '[:lower:]'`
#		echo "lower case module $lower_case_module"
	    if [ -f ./$lower_case_module ]; then
		if ! [ -d "./old_modules" ]; then
		    mkdir "./old_modules"
		fi
	    	mv ./$module ./old_modules/$module
	    else
		mv ./$module ./$lower_case_module
	    fi 
#	    echo "module $module exist"
	fi
done

LANG=ru_RU.UTF8 wine info.exe

