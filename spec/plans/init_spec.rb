# frozen_string_literal: true

require 'json'
require 'spec_helper'
require 'bolt_spec/plans'

describe 'secure_env_vars' do
  include BoltSpec::Plans

  let(:env_vars)    { { 'foo' => 'bar' } }
  let(:output)      { { 'stdout' => 'success' } }
  let(:bolt_config) { { 'modulepath' => RSpec.configuration.module_path } }

  let(:command_params) { params.slice('targets', 'command') }
  let(:script_params)  { params.slice('targets', 'script') }

  let(:params) do
    {
      'targets' => 'localhost',
      'command' => 'whoami',
      'script'  => 'spec/script.sh'
    }
  end

  before(:all) do
    BoltSpec::Plans.init
  end

  around(:each) do |example|
    original = ENV['BOLT_ENV_VARS']
    ENV['BOLT_ENV_VARS'] = env_vars.to_json
    example.run
  ensure
    ENV['BOLT_ENV_VARS'] = original
  end

  before(:each) do
    allow_command(params['command']).always_return(output)
    allow_script(params['script']).always_return(output)
  end

  it 'errors when passing command and script' do
    result = run_plan('secure_env_vars', params)
    expect(result.ok?).not_to be
    expect(result.value.msg).to match(/Cannot specify both script and command for secure_env_vars/)
  end

  it 'errors when passing neither command nor script' do
    result = run_plan('secure_env_vars', 'targets' => 'localhost')
    expect(result.ok?).not_to be
    expect(result.value.msg).to match(/Must specify either script or command for secure_env_vars/)
  end

  it 'succeeds with a command' do
    expect_command(params['command']).with_targets([params['targets']]).with_params('_env_vars' => env_vars)
    result = run_plan('secure_env_vars', command_params)
    expect(result.ok?).to be
  end

  it 'succeeds with a script' do
    expect_script(params['script']).with_targets([params['targets']]).with_params('_env_vars' => env_vars)
    result = run_plan('secure_env_vars', script_params)
    expect(result.ok?).to be
  end

  it 'passes an empty hash to env_vars when BOLT_ENV_VARS is not set' do
    ENV.delete('BOLT_ENV_VARS')
    expect_command(params['command']).with_targets([params['targets']]).with_params('_env_vars' => {})
    result = run_plan('secure_env_vars', command_params)
    expect(result.ok?).to be
  end
end
