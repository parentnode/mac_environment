#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
deleteAndAppendSection "# enable_git_prompt" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/source" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/destination"
deleteAndAppendSection "# alias" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/source" "/Users/davidjessen/Sites/parentnode/mac_environment/tests/update_content_test_files/destination"