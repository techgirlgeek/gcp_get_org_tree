# GCP Project/Folder Lists

This code will allow the user to get a list of either:

1. All Folders and projects from within an Organization
2. All Folders and Projects from within a specified Folder within an Organization.

To execute the code:
Enter:
`./list_org_folders.sh`

This script will get a list of all project owners, listed out by folder:
`.gcp_get_proj-ids-get-owner.sh`

You will be prompted for either ORG or FLD.

If you choose ORG - All folders and underlying projects will be listed out.
If you choose FLD - You will be prompted for a folder to start the listing from.

Example:

```bash

./list_org_folders.sh
Enter ORG or FLD: FLD
Enter Folder ID #: ########
```
