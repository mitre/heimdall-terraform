#!/bin/bash

find ../terraform/modules/. -type d -exec bash -c 'terraform-docs md "{}" > "{}"/README.md;' \;

printf "\n\033[35;1mUpdating the following READMEs with terraform-docs\033[0m\n\n"
  
find ../terraform/modules/. -name "README.md"