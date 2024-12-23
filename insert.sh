#!/bin/bash

# Check if "test" argument is passed to the script
if [[ $1 == "test" ]]; then
  PSQL="psql --username=postgres --dbname=worldcuptest -t --no-align -c"
else
  PSQL="psql --username=freecodecamp --dbname=worldcup -t --no-align -c"
fi

# Function to insert teams into the teams table
insert_teams() {
  echo "Inserting unique teams..."
  # Unique team names from games.csv
  while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
    # Skip the header line
    if [[ "$year" != "year" ]]; then
      # Insert winner and opponent into the teams table if not already present
      for team in "$winner" "$opponent"; do
        # Check if the team already exists, if not insert it
        EXISTS=$($PSQL "SELECT team_id FROM teams WHERE name = '$team'")
        if [[ -z $EXISTS ]]; then
          $PSQL "INSERT INTO teams (name) VALUES ('$team')"
        fi
      done
    fi
  done <games.csv
}

# Function to insert games into the games table
insert_games() {
  echo "Inserting games..."
  # Read the games.csv file and insert each game
  while IFS=',' read -r year round winner opponent winner_goals opponent_goals; do
    # Skip the header line
    if [[ "$year" != "year" ]]; then
      # Get team IDs for the winner and opponent
      winner_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$winner'")
      opponent_id=$($PSQL "SELECT team_id FROM teams WHERE name = '$opponent'")

      # Insert the game into the games table
      $PSQL "INSERT INTO games (year, round, winner_id, opponent_id, winner_goals, opponent_goals) 
             VALUES ($year, '$round', $winner_id, $opponent_id, $winner_goals, $opponent_goals)"
    fi
  done <games.csv
}

# Insert teams and games into the database
insert_teams
insert_games

echo "Data insertion complete!"
