# Function: validate_processes
#
# A function to validate processes for the datadog process integration.
# It validates that the input is an array of process hashes, and that each key
# has the correct data type.
#
# This currently has to be done in a custom function because this module
# supports versions of Puppet < 4.0. This could be done with Puppet iterators,
# so if support for < 4.0 is ever dropped, this should be moved into the
# manifests.
#
# Parameters:
#   processes:
#     An array of process hashes
#
#
module Puppet::Parser::Functions
  newfunction(:validate_processes) do |args|
    processes = args[0]

    function_validate_array([processes])

    processes.each do |process|
      function_validate_string([process['name']])
      function_validate_array([process['search_string']])
      function_validate_bool([process['exact_match']])
    end
  end
end
