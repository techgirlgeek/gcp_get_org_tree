#!/usr/bin/env bash

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
    printf "Folder: ${FOLDER} (${NAME})\n"

    # Call function projects with argument folderId
    projects ${FOLDER}

  done
}

# Function to get Folder's Projects
projects() {
  # Format Project information into CSV
  FORMAT_PRJ_CSV="csv[no-heading](projectId:label=ProjectID)"

  PROJECT=$(gcloud projects list \
    --filter parent.id:${FOLDER} \
    --format="${FORMAT_PRJ_CSV}")

  for PROJ in ${PROJECT}
  do
    PROJECT_OWNER=$(gcloud projects get-iam-policy ${PROJ} \
      --flatten="bindings[].members" \
      --filter="bindings.role=roles/owner" \
      --format="value(bindings.members)" \
      | grep user: | sed 's/user://g')

    printf "GCP Listed Owners for Project ${PROJ}:\n${PROJECT_OWNER}\n\n"
  done

}

# setting CSV gcloud format for script
FORMAT="csv[no-heading](name,displayName.encode(base64))"

# Request CLI input
# Parse depending on input
# ORG gives all folders and projects
# FLD starts at a specific parent folder
printf "Are you parsing the full organization or just folders?\n"

while true; do
  read -p "Enter ORG or FLD: " intype

  case $intype in
    ORG)
      # Start at the Org
      if [ -z "${ORGANIZATION}" ]; then
        read -p "Enter Organization ID: " ORGID
        ORGANIZATION=${ORGID}
      fi

      printf "Organization: ${ORGANIZATION}\n\n"
      PARSEOPT="organization=${ORGANIZATION}"

      LINES=$(gcloud resource-manager folders list \
        --"${PARSEOPT}" \
        --format="${FORMAT}")

      folders ${LINES[0]}
      break;;
    FLD)
      read -p "Enter Folder ID #: " folderID
      FOLDER=${folderID}
      PARSEOPT="folder=${FOLDER}"

      projects ${FOLDER}

      # Print out projects information
      printf "${PROJECT}\n\n"

      LINES=$(gcloud resource-manager folders list \
        --"${PARSEOPT}" \
        --format="${FORMAT}")

      # Descend
      folders ${LINES[0]}
      break;;

    * ) echo "Please enter either FLD or ORG.";;
  esac
done
