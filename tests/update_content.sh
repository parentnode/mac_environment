#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
updateContent "# enable_git_prompt" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/source" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/destination"
updateContent "# alias" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/source" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/destination"