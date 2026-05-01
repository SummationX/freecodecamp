#! /bin/bash

PSQL="psql --username=freecodecamp --dbname=postgres -t --no-align -c"

echo Enter your username:
read USERNAME

USER_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
if [[ -z $USER_RESULT ]]
then
  INSERT_USER_RESULT=$($PSQL "INSERT INTO users(username, games_played) VALUES ('$USERNAME', 0)")
  echo Welcome, $USERNAME! It looks like this is your first time here.
  USER_RESULT=$($PSQL "SELECT * FROM users WHERE username='$USERNAME'")
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME USER_ID <<< $USER_RESULT
else
  IFS="|" read USERNAME GAMES_PLAYED BEST_GAME USER_ID <<< $USER_RESULT
  echo Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses.
fi

RANDOM_NUMBER=$(( RANDOM%1000 + 1))
GUESS_COUNT=0

GUESS_NUMBER()
{
  ((GUESS_COUNT++))
  echo $1 
  read ANSWER
  if [[ ! $ANSWER =~ ^[0-9]+$ ]]
  then
    GUESS_NUMBER "That is not an integer, guess again:"
  else
    if (( RANDOM_NUMBER < ANSWER ))
    then
      GUESS_NUMBER "It's lower than that, guess again:"
    elif (( RANDOM_NUMBER > ANSWER ))
    then 
      GUESS_NUMBER "It's higher than that, guess again:"
    else
      echo You guessed it in $GUESS_COUNT tries. The secret number was $RANDOM_NUMBER. Nice job!
      ((GAMES_PLAYED++))
      if [[ $BEST_GAME < $GUESS_COUNT ]]
      then
        UPDATE_GAME_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED, best_game = $GUESS_COUNT WHERE user_id = $USER_ID")
      else
        UPDATE_GAME_RESULT=$($PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE user_id = $USER_ID")
      fi
    fi
  fi
}

GUESS_NUMBER "Guess the secret number between 1 and 1000:"
