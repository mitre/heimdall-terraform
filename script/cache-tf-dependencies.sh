
cd terraform/modules/

for d in ./*/ ; do (cd "$d" && terraform get); done
