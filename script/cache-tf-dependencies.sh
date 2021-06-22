
cd terraform/modules/

for d in ./*/ ; do (cd "$d" && terraform get); done


cd saf-heimdall-ecr
./pull-image

if [ ! -f lambda/ConfigToHdf/function.zip ]; then
    echo "lambda/ConfigToHdf/function.zip was not found! Ensure that you get this file before deploying!"
fi
