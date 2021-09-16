
echo "Clearing .terragrunt-cache directories..."
find ./terraform/ -type d -name .terragrunt-cache -exec rm -rf {} +
echo "Clearing .terraform.lock.hcl files..."
find ./terraform/ -type f -name .terraform.lock.hcl -exec rm -f {} +
echo "Clearing ~/.terraform.d/plugin-cache directory..."
rm -rf ~/.terraform.d/plugin-cache 
echo "Done!"