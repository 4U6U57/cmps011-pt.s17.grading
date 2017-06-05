#!/././././bin/./.././bin/././././bash

# csvify.sh
# generates export csv file for a specific assignment to import to eCommons
# Usage: csvify.sh [$ASG] [$GRADEFILE] [$OUTFILE]
#        ASG: Assignment to mail, defaults to current directory name if valid
#        GRADEFILE: Grade file to read from
#        OUTFILE: csv file to output to
# Expects a line in $GRADEFILE of format "SCORE: $POINTS / $TOTAL"
# August Valera <avalera>

Exe="csvify"
MailWait=3
PwdDir=$(pwd)
Pwd=$(basename $PwdDir)
ClassDir=$(echo $PwdDir | cut -d "/" -f -5)
Class=$(basename $ClassDir)
Asg=""
GradeFile=""
BinDir="$ClassDir/bin"

[[ ! -d $BinDir ]] && mkdir $BinDir

if [[ -d "$ClassDir/$Pwd" && "$Pwd" != "bin" ]]; then
  Asg=$Pwd
  echo "$Exe: Asg $Asg taken from basename of current directory"
elif [[ "$1" != "" && -d "$ClassDir/$1" ]]; then
  Asg=$1
  echo "$Exe: Asg $Asg taken from first argument of script"
  shift
else
  echo "$Exe: ERROR - Invalid or no asg provided"
  exit
fi
AsgDir=$ClassDir/$Asg
if [[ ! -d "$AsgDir" ]]; then
  echo "$Exe: ERROR - Invalid asg $Asg"
  exit
fi

AsgBinDir="$BinDir/$Asg"
[[ ! -d $AsgBinDir ]] && mkdir $AsgBinDir

MailDir="$AsgBinDir/$Exe"
[[ ! -d $MailDir ]] && mkdir $MailDir

GradeFile="GRADE.txt"
[[ "$1" != "" ]] && GradeFile="$1" && shift

OutFile="$AsgBinDir/$Class.$Asg.csv"
[[ "$1" != "" ]] && OutFile="$Pwd/$1"

AllFile="$AsgBinDir/$Class.$Asg.$GradeFile"

echo "student,$Asg" > $OutFile
cd $AsgDir
for Student in $(ls -d */); do
  Student="$(basename $Student)"
  StudentDir="$AsgDir/$Student"
  StudentGrade="$StudentDir/$GradeFile"
  StudentScore=$(grep "SCORE:" $StudentGrade | cut -d ':' -f 2 | cut -d "/" -f 1 | sed 's/\s//g')
  if [[ -z $StudentScore ]]; then
    echo "$Exe: ERROR - Score not found: $StudentGrade"
  else
    echo "$Student,$StudentScore" >>$OutFile
    cat $StudentGrade >>$AllFile
  fi
done
