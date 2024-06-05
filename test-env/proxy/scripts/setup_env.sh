set -exuo pipefail

source ~/.env
source ~/proxy_env
cat proxy_env >> .bashrc

vim ~/.bashrc -c "set ff=unix" -c ":wq"

set +exuo pipefail