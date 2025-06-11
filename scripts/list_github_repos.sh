#!/bin/bash
export LC_ALL=C.UTF-8 #Avoid  issues with Perl compatible regexes

# Usage: ./list_github_repos.sh <github_username>

USERNAME=$1
PER_PAGE=100
PAGE=1

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <github_username>"
  exit 1
fi

echo "Fetching repositories for GitHub user: $USERNAME"
echo

while :; do
  RESPONSE=$(curl -s "https://api.github.com/users/${USERNAME}/repos?per_page=${PER_PAGE}&page=${PAGE}")

  # Check if response is an array or an error
  if echo "$RESPONSE" | grep -q "Not Found"; then
    echo "User not found or error retrieving data."
    exit 1
  fi

  REPO_NAMES=$(echo "$RESPONSE" | grep -oP '"full_name":\s*"\K[^"]+')

  # Break if no more repositories are found
  if [ -z "$REPO_NAMES" ]; then
    break
  fi

  echo "$REPO_NAMES"

  PAGE=$((PAGE + 1))
done
