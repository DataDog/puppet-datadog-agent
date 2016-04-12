require 'spec_helper'

RSpec.describe 'validate_processes' do
  context 'with valid input' do
    it 'is expected to validate all fields and do nothing' do
      params = [
        {
          'name' => 'my_process',
          'search_string' => [
            'my_process',
          ],
          'exact_match' => false,
        }
      ]

      is_expected.to_not run.with_params(params).and_raise_error(Puppet::ParseError)
    end
  end

  context 'with invalid input' do
    it 'is expected to validate all fields and raise Puppet::ParseError' do
      params = [
        {
          'name' => 'my_process',
          'search_string' => [
            'my_process',
          ],
          'exact_match' => false,
        },
        {
          'name' => 'my_other_process',
          'search_string' => 'my_other_process',
          'exact_match' => false,
        }
      ]

      is_expected.to run.with_params(params).and_raise_error(Puppet::ParseError)
    end
  end
end
