#!/bin/bash


SCRIPT_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
. "${SCRIPT_DIR}/utils"

cd "${BASE_DIR}"

echo "Activation du virtual env"
source backend/venv/bin/activate


geonature install_packaged_gn_module "${BASE_DIR}/contrib/occtax" OCCTAX --build=false
if [ "$add_sample_data" = true ];
then
    geonature upgrade occtax-samples@head
fi

if [ "$install_module_occhab" = true ]; then
  geonature install_gn_module "${BASE_DIR}/contrib/gn_module_occhab" /occhab --build=false
fi

if [ "$install_module_validation" = true ]; then
    geonature install_gn_module "${BASE_DIR}/contrib/gn_module_validation" /validation --build=false
fi

echo "Désactivation du virtual env"
deactivate
