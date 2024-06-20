set -exuo pipefail

source ~/.env
source ~/additional_env
cat additional_env >> .bashrc

vim ~/.bashrc -c "set ff=unix" -c ":wq"

set +exuo pipefail