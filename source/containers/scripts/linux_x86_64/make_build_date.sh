#!/usr/bin/env bash

set -o errexit
set -o errtrace
set -o pipefail
set -o nounset

BUILD_DATE="${1}"

    cat << EOF > /usr/bin/build_date.bat
#!/usr/bin/env bash
echo -n "${BUILD_DATE}"
EOF
    chmod +x /usr/bin/build_date.bat
