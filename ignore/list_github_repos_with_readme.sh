#!/bin/bash

# Check for username argument
if [ -z "$1" ]; then
  echo "Usage: $0 github_username"
  exit 1
fi

USERNAME="$1"
OUTPUT_FILE="${USERNAME}_repos_and_readmes.md"
GITHUB_API="https://api.github.com"
HEADER="Accept: application/vnd.github.v3+json"

# Clear the output file
> "$OUTPUT_FILE"

# Fetch repo names using sed (no jq)
repos=$(curl -s -H "$HEADER" "$GITHUB_API/users/$USERNAME/repos?per_page=100" | sed -n 's/.*"name": "\([^"]*\)".*/\1/p')

# Loop through each repo
for repo in $repos; do
  echo "Fetching README for: $repo"

  echo "## 📁 $repo" >> "$OUTPUT_FILE"
  echo "**URL**: https://github.com/$USERNAME/$repo" >> "$OUTPUT_FILE"
  echo -e "\n\`\`\`markdown" >> "$OUTPUT_FILE"

  # Get decoded README content directly
  readme_text=$(curl -s -H "Accept: application/vnd.github.v3.raw" "$GITHUB_API/repos/$USERNAME/$repo/readme")

  if [[ -n "$readme_text" && "$readme_text" != *"Not Found"* ]]; then
    echo "$readme_text" >> "$OUTPUT_FILE"
  else
    echo "(No README found)" >> "$OUTPUT_FILE"
  fi

  echo -e "\n\`\`\`\n" >> "$OUTPUT_FILE"
done

echo "Output saved to: $OUTPUT_FILE"
