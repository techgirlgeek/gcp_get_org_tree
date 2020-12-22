#!/usr/bin/env bash

: "${ORGANIZATION:?Need to export ORGANIZATION and it must be non-empty}"

printf "Are you parsing the full organization or just folders?\n"
read -p "Enter ORG or FLD: "

if [ ${REPLY} == "ORG" ]; then
  echo "Organization"
  PARSEOPT="organization=${ORGANIZATION}"
else
  echo "Folder"
  read -p "Enter Folder ID #: " folderID
  FID=${folderID}
  echo "FID is ${FID}"
  PARSEOPT="folder=${FID}"
fi

# gcloud format
FORMAT="csv[no-heading](name,displayName.encode(base64))"
FORMAT_PRJ="table[box,title='Folder ${NAME} Project List'] \
(createTime:sort=1,name,projectNumber,projectId:label=ProjectID,parent.id:label=Parent)"

# Enumerates Folders recursively
folders()
{
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
    project=$(gcloud projects list \
      --filter parent.id:${FOLDER} \
      --format="${FORMAT_PRJ}")

    if [ -z "$project" ]
    then
      printf "Folder: ${FOLDER} - ${NAME} has no sub-projects\n\n"
    else
      printf "Parent FolderID: ${FOLDER}\t Parent Name(s): ${NAME}\n${project} \n\n"
    fi

    folders $(gcloud resource-manager folders list \
      --folder=${FOLDER} \
      --format="${FORMAT}")

  done
}

# Start at the Org
printf "Org: ${ORGANIZATION}\n\n"
# LINES=$(gcloud resource-manager folders list \
#   --organization=${ORGANIZATION} \
#   --format="${FORMAT}")

TOPLevelFolder=$(gcloud projects list \
      --filter parent.id:744980836391 \
      --format="${FORMAT_PRJ}")

printf "Folder: 744980836391\n"
    printf "Project: Project info:\n\n"
    printf "${TOPLevelFolder}\n\n"

LINES=$(gcloud resource-manager folders list \
  --"${PARSEOPT}" \
  --format="${FORMAT}")


# Descend
folders ${LINES[0]}

# TODO: Option to run all (organization) OR Decendents of a Folder
# If Organization, start at the top
# If Decendents from a Folder:
# Then parse folder for projects before moving through each folder
