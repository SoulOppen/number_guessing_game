#!/bin/bash
SECRET_NUMBER=$(($RANDOM%1000+1))
PSQL="psql --username=freecodecamp --dbname=number_guess -t --no-align -c"
echo -e "\nEnter your username:"
read USERNAME
USERNAME_RESULT="$($PSQL "SELECT COUNT(game_id), MIN(plays) FROM games INNER JOIN users USING(user_id) WHERE name='$USERNAME' GROUP BY name")"
if [[ -z $USERNAME_RESULT ]]
then
  echo -e "\nWelcome, $USERNAME! It looks like this is your first time here."
  INSERT_NAME="$($PSQL "INSERT INTO users(name) VALUES('$USERNAME')")"
else
  echo $USERNAME_RESULT | while IFS="|" read GAMES BEST_GAME
  do
    echo -e "Welcome back, $USERNAME! You have played $GAMES games, and your best game took $BEST_GAMES guesses."
  done
fi
USERNAME_ID="$($PSQL "SELECT user_id FROM users WHERE name='$USERNAME'")"
NUMBER=0
PLAY=0
while [[ SECRET_NUMBER -ne NUMBER ]] 
do
  echo -e "\nGuess the secret number between 1 and 1000:"
  PLAY=$(($PLAY+1))
  read NUMBER
  if [[ $NUMBER =~ ^[0-9]+$ ]]
  then
    if [[ $SECRET_NUMBER == $NUMBER ]]
    then
        INSERT_GAME="$($PSQL "INSERT INTO games(plays,user_id) VALUES('$PLAY',$USERNAME_ID)")"
        break
    elif [[ $SECRET_NUMBER -gt $NUMBER ]]
    then
        echo "It's higher than that, guess again:"
    elif [[ $SECRET_NUMBER -lt $NUMBER ]] 
    then
        echo "It's lower than that, guess again:."
    fi
  else
    echo "That is not an integer, guess again:"
  fi
done
echo  "You guessed it in $PLAY tries. The secret number was $SECRET_NUMBER. Nice job!"