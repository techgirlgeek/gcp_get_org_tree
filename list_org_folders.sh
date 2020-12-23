#!/usr/bin/env bash

# setting gcloud formats for script
FORMAT="csv[no-heading](name,displayName.encode(base64))"
FORMAT_PRJ="table[box,title='Folder ${NAME} Project List'] \
(createTime:sort=1,name,projectNumber,projectId:label=ProjectID,parent.id:label=Parent)"

printf "Are you parsing the full organization or just folders?\n"
read -p "Enter ORG or FLD: "

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
  printf "Folder: ${FOLDER}\n\n"
  PARSEOPT="folder=${FOLDER}"

  PROJECT=$(gcloud projects list \
        --filter parent.id:${FOLDER} \
        --format="${FORMAT_PRJ}")

  printf "Folder: ${FOLDER}\n"
      printf "Project: Project info:\n\n"
      printf "${TOPLevelFolder}\n\n"
fi

# Enumerates Folders recursively
folders() {
  LINES=("$@")
  for LINE in ${LINES[@]}
  do
    # Parses lines of the form folder,name
    VALUES=(${LINE//,/ })
    FOLDER=${VALUES[0]}

    # Decodes the encoded name
    NAME=$(echo ${VALUES[1]} | base64 --decode)
    printf "Folder: ${FOLDER} (${NAME})\n\n"

    printf "Project: Project info:\n\n"
    PROJECT=$(gcloud projects list \
      --filter parent.id:${FOLDER} \
      --format="${FORMAT_PRJ}")

    if [ -z "$project" ]; then
      printf "Folder: ${FOLDER} - ${NAME} has no sub-projects\n\n"
    else
      printf "Parent FolderID: ${FOLDER}\t Parent Name(s): ${NAME}\n${PROJECT} \n\n"
    fi

    folders $(gcloud resource-manager folders list \
      --folder=${FOLDER} \
      --format="${FORMAT}")

  done
}

LINES=$(gcloud resource-manager folders list \
  --"${PARSEOPT}" \
  --format="${FORMAT}")

# Descend
folders ${LINES[0]}
