#!/bin/bash
export LC_ALL=C.UTF-8  # Avoid issues with Perl compatible regexes

# Usage: ./list_github_repos.sh <github_username>

USERNAME=$1  # Hold the username variable
PER_PAGE=100  # Maximum allowed by GitHub API
PAGE=1  # Pagination

if [ -z "$USERNAME" ]; then
  echo "Usage: $0 <github_username>"
  exit 1
fi

echo "Fetching repositories for GitHub user: $USERNAME"
echo

# Clear the output file before writing
> repos.txt

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
  echo "$REPO_NAMES" >> repos.txt  # Append to output file

  PAGE=$((PAGE + 1))  # Increment to fetch the next page
done
