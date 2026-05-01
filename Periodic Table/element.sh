#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=periodic_table -t --no-align -c"

QUERY_RESULT()
{
  if [[ -z $1 ]]
  then
    echo I could not find that element in the database.
  else
    IFS="|" read TYPE_ID ATOMIC_NUMBER SYMBOL NAME ATOMIC_MASS MELTING_POINT_C BOILING_POINT_C TYPE <<< $1
      echo -e "The element with atomic number $ATOMIC_NUMBER is $NAME ($SYMBOL). It's a $TYPE, with a mass of $ATOMIC_MASS amu. $NAME has a melting point of $MELTING_POINT_C celsius and a boiling point of $BOILING_POINT_C celsius."
  fi
}

if [[ -z $1 ]]
then
  echo Please provide an element as an argument.
else
  if [[ $1 =~ ^[0-9]+$ ]]
  then
    ATOMIC_NUMBER=$1
    RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties USING(atomic_number) INNER JOIN types USING(type_id) WHERE atomic_number = $ATOMIC_NUMBER")
    QUERY_RESULT "$RESULT"
  elif [[ $1 =~ ^[A-Z][a-zA-Z]?$ ]]
  then
    SYMBOL=$1
    RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE symbol='$SYMBOL'")
    QUERY_RESULT "$RESULT"
  else
    NAME=$1
    RESULT=$($PSQL "SELECT * FROM elements INNER JOIN properties USING (atomic_number) INNER JOIN types USING (type_id) WHERE name='$NAME'")
    QUERY_RESULT "$RESULT"
  fi
fi
