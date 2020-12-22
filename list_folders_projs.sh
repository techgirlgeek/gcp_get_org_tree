#!/usr/bin/env bash

# Playground script for testing 

roj_name=$(printf $(gcloud projects list --filter parent.id:666286480658 --format 'value(PROJECT_ID)'))
echo $proj_name
