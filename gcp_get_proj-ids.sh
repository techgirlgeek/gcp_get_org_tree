#!/usr/bin/env bash

# setting CSV gcloud format for script
FORMAT="csv[no-heading](name,displayName.encode(base64))"

printf "Are you parsing the full organization or just folders?\n"
read -p "Enter ORG or FLD: "

echo "Name,ProjectNumber,ProjectID"

# Function to enumerate Folders recursively
folders() {
  LINES=("$@")
  for LINE in ${LINES[@]}
  do
    # Parses lines of the form folder,name
    VALUES=(${LINE//,/ })
    FOLDER=${VALUES[0]}

    # Decodes the encoded name
    NAME=$(echo ${VALUES[1]} | base64 --decode)
    #printf "Folder: ${FOLDER} (${NAME})\n\n"

    #printf "Project info:\n\n"
    projects ${FOLDER}

    #if [ -z "$PROJECT" ]; then
    #  printf "Folder: ${FOLDER} - ${NAME} has no sub-projects\n\n"
    #else
     printf "${PROJECT}\n"
    #fi

    folders $(gcloud resource-manager folders list \
      --folder=${FOLDER} \
      --format="${FORMAT}")

  done
}

# Function to get Folder's Projects
projects() {
  # Format Project information into table
  # FORMAT_PRJ="table[box,title='Folder ${NAME} Project List'] \
  # (createTime:sort=1,name,projectNumber,projectId:label=ProjectID,parent.id:label=Parent)"
  FORMAT_PRJ="table[box] \
  (name,projectNumber,projectId:label=ProjectID)"
  FORMAT_PRJ_CSV="csv[no-heading](name,projectNumber,projectId:label=ProjectID)"

  PROJECT=$(gcloud projects list \
    --filter parent.id:${FOLDER} \
    --format="${FORMAT_PRJ_CSV}")

}

# Request CLI input
# Parse depending on input
# ORG gives all folders and projects
# FLD starts at a specific parent folder
if [ ${REPLY} == "ORG" ]; then
  # Start at the Org
  if [ -z "${ORGANIZATION}" ]; then
    read -p "Enter Organization ID: " ORGID
    ORGANIZATION=${ORGID}
  fi

  printf "Organization: ${ORGANIZATION}\n\n"
  PARSEOPT="organization=${ORGANIZATION}"
else
  read -p "Enter Folder ID #: " folderID
  FOLDER=${folderID}
  PARSEOPT="folder=${FOLDER}"

  projects ${FOLDER}

  # Print out projects information
  printf "${PROJECT}\n\n"
fi

LINES=$(gcloud resource-manager folders list \
  --"${PARSEOPT}" \
  --format="${FORMAT}")

# Descend
folders ${LINES[0]}
