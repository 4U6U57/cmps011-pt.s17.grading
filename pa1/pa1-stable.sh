#!/bin/bash

GRADEFILE="grade.txt"
PWD="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CLASSDIR="$(echo $PWD | cut -d '/' -f 1-5)"
CLASS="$(basename $CLASSDIR)"
ASG="$(basename $PWD)"
ASGBIN="$CLASSDIR/bin/$ASG"
ASGDIR="$CLASSDIR/$ASG"
ASGTABLE="$ASGBIN/student"
[ ! -e $ASGTABLE ] && mkdir --parents $ASGTABLE
SEPARATE="=================================================="

forall() {
  CLASSNUM=$(echo $CLASS | cut -d '0' -f 2 | cut -d '-' -f 1)
  cd $ASGDIR
  for STUDENT in $(ls -d */); do
    STUDENTDIR=$ASGDIR/$STUDENT
    STUDENT=$(basename $STUDENT /)
    STUDENTNAME=$(getent passwd $STUDENT | cut -d ":" -f 5)
    cd $STUDENTDIR
    #echo "$SEPARATE"
    #pwd
    $@
  done
}

declare -A STUDENTTABLE
readtable() {
  cleartable
  if [[ -e $1 ]]; then
    while read LINE; do
      STUDENTTABLE["$(echo $LINE | cut -d ':' -f 1)"]="$(echo $LINE | cut -d ':' -f 2-)"
    done < $1
  else
    echo "TABLE: $STUDENT does not have a table"
  fi
}
writetable() {
  rm -f $1
  touch $1
  for KEY in ${!STUDENTTABLE[@]}; do
    echo $KEY: ${STUDENTTABLE["$KEY"]} >> $1
  done
  cat $1 | sort > $1.swp
  mv $1.swp $1
}
cleartable() {
  for KEY in ${!STUDENTTABLE[@]}; do
    unset STUDENTTABLE["$KEY"]
  done
}
settable() {
  STUDENTTABLE["$1.$2"]="$3"
}

backup() {
  if [[ ! -e $1 ]]; then
    mkdir $1
  fi
  for FILE in *; do
    [[ $FILE != "*" ]] && cp -n $FILE $1/$FILE
  done
}
restore() {
  for FILE in *; do
    if [[ $FILE != "*" && ! -e $1/$FILE ]]; then
      echo "RESTORE: $FILE created during grading, deleting"
      rm -f ./$FILE
    fi
  done
  for FILE in $1/*; do
    FILE=$(basename $FILE)
    if [[ $FILE != "*" ]]; then
      if [[ ! -e $FILE ]]; then
        echo "RESTORE: $FILE deleted during grading, restoring"
        cp $1/$FILE $FILE
      elif ! diff -q $FILE $1/$FILE > /dev/null; then
        echo "RESTORE: $FILE modified during grading, restoring"
        cp $1/$FILE $FILE
      fi
    fi
  done
}

grade() {
  # Actual grading code here

  # File name (#8)
  UserSourceFile="Lawn.java"
  if [[ ! -e $UserSourceFile ]]; then
    JavaFiles=( *.java )
    if [[ ! -e ${JavaFiles[0]} ]]; then
      UserSourceFile=""
      settable grade 8 P
      settable notes 8 "Lawn.java not submitted, cannot grade name"
    else
      UserSourceFile="${JavaFiles[0]}"
      settable grade 8 C
      settable notes 8 "Lawn.java named incorrectly: $UserSourceFile"
    fi
  else
    settable grade 8 P
    settable notes 8 "Lawn.java named correctly"
  fi

  # Comment block (#7)
  if [[ ! -z $UserSourceFile ]]; then
    CommentBlock="$(head -n 10 $UserSourceFile | grep "^\s*[/#*]")"
    if [[ ! -z $CommentBlock ]]; then
      Score=5
      Note="$UserSourceFile contained comment block"
      StudentFirstName=$(echo $STUDENTNAME | cut -d " " -f 1)
      if ! grep "$UserSourceFile" <(echo "$CommentBlock") >/dev/null; then
        Note+=", missing filename ($UserSourceFile)"
        Score=$((Score - 1))
      fi
      if ! grep "$StudentFirstName" <(echo "$CommentBlock") >/dev/null; then
        Note+=", missing your name ($StudentFirstName)"
        Score=$((Score - 1))
      fi
      if ! grep -i "$STUDENT" <(echo "$CommentBlock") >/dev/null; then
        Note+=", missing CruzID ($STUDENT)"
        Score=$((Score - 1))
      fi
      if ! grep -i "pa\s*1" <(echo "$CommentBlock") >/dev/null; then
        Note+=", missing assignment name (pa1)"
        Score=$((Score - 1))
      fi
      settable grade 7 P
      settable notes 7 "$Note"
    else
      settable grade 7 C
      settable notes 7 "$UserSourceFile did not contain a comment block"
    fi
  else
    settable grade 7 C
    settable notes 7 "Lawn.java not submitted, cannot grade comment block"
  fi

  # Class name (#6)
  if [[ ! -z $UserSourceFile ]]; then
    ClassName="$(grep -P '^\s*(public\s+)?class\s+' $UserSourceFile | head -n 1 | sed 's#public##g;s#class##g;s#{##g;s#^\s*##g;s#\s.*$##g')"
    if [[ $ClassName == "Lawn" ]]; then
      settable grade 6 P
      settable notes 6 "Class Lawn named correctly"
    else
      settable grade 6 C
      settable notes 6 "Class Lawn named incorrectly: $ClassName"
    fi
  fi

  # Performance tests (#1)
  rm -f $EXE *.class out
}

main() {
  BACKUP=".backup"
  pwd
  backup $BACKUP
  readtable $ASGTABLE/student_$STUDENT.autotable
  grade
  restore $BACKUP
  writetable $ASGTABLE/student_$STUDENT.autotable # Comment this one out
  # writetable $ASGTABLE/student_$STUDENT.autotable # Uncomment to deploy
  cleartable
}
forall main