#!/bin/bash

PSQL="psql --username=freecodecamp --dbname=number_guessing_game -t --no-align -c"

echo Enter your username:
read USERNAME

LOGIN() {

if [[ $USERNAME -le 22 ]]
then
  IS_USER_NEW=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME';")

  if [[ $IS_USER_NEW -ne 0 ]]
  then 
    GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name = '$USERNAME';")
    BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name = '$USERNAME';")
    echo "Welcome back, $USERNAME! You have played $GAMES_PLAYED games, and your best game took $BEST_GAME guesses."

    GAME
  else
    $PSQL "INSERT INTO users(name, games_played, best_game) VALUES('$USERNAME',0,0);" > /dev/null 2>&1
    echo "Welcome, $USERNAME! It looks like this is your first time here."
    GAMES_PLAYED=0
    BEST_GAME=0

    GAME
  fi
else
  echo Username is too long, try 22 characters!
fi

}

GAME() {

SECRET_NUMBER=$(( ($RANDOM % 1000) + 1 ))
SECRET_NUMBER_RES=$SECRET_NUMBER
NUMBER_OF_GUESSES=0
echo Guess the secret number between 1 and 1000:

while [ $SECRET_NUMBER != 0 ]
do

  read GUESS
  ((NUMBER_OF_GUESSES+=1))

  if [[ $GUESS =~ ^[0-9]+$ ]]
  then
    if [[ $GUESS -eq $SECRET_NUMBER ]]
    then
      SECRET_NUMBER=0
    else
      if [[ $GUESS -lt $SECRET_NUMBER ]]
      then
        echo "It's higher than that, guess again:"
      else
        if [[ $GUESS -gt $SECRET_NUMBER ]]
        then
          echo "It's lower than that, guess again:"
        fi
      fi
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done

echo "You guessed it in $NUMBER_OF_GUESSES tries. The secret number was $SECRET_NUMBER_RES. Nice job!"

GAMES_PLAYED=$($PSQL "SELECT games_played FROM users WHERE name='$USERNAME';")
((GAMES_PLAYED++))
$PSQL "UPDATE users SET games_played = $GAMES_PLAYED WHERE name = '$USERNAME'" > /dev/null 2>&1

FIRST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME';")
if [[ -z $FIRST_GAME ]]
then
  $PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE name = '$USERNAME'" > /dev/null 2>&1
fi
if [[ $FIRST_GAME -eq 0 ]]
then
  $PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE name = '$USERNAME'" > /dev/null 2>&1
fi
BEST_GAME=$($PSQL "SELECT best_game FROM users WHERE name='$USERNAME';")
if [[ $NUMBER_OF_GUESSES -lt $BEST_GAME ]]
then
  $PSQL "UPDATE users SET best_game = $NUMBER_OF_GUESSES WHERE name = '$USERNAME'" > /dev/null 2>&1
fi

}

LOGIN