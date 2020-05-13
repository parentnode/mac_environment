#!/bin/bash -e
source /srv/sites/parentnode/mac_environment/scripts/functions.sh
deleteAndAppendSection "#section" "/Users/$(echo $(logname))/parentnode/mac_environment/tests/delete_and_append_section_test_files/source" "/Users/$(echo $(logname))/Sites/parentnode/mac_environment/tests/delete_and_append_section_test_files/destination"
