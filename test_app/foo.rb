require 'sinatra/base'
require 'rest-client'

class FooApp < Sinatra::Application

  configure do
    set :bind, '0.0.0.0'
  end
  
  get '/' do
    password = retrieve_secret(secret_identifier('DB_PASSWORD'))

    "
      <h1>Visit us @ www.conjur.org!</h1>
      <p>Environment: #{ENV['RACK_ENV']}</p>
      <p>Database Username: #{ENV['DB_USERNAME']}</p>
      <p>Database Password: #{password}</p>
      <p>Stripe API Key: #{ENV['STRIPE_API_KEY']}</p>
    "
  end

  protected

  def conjur_api
    @conjur_api ||= begin
      require 'conjur-api'
      require 'conjur/cli'
      Conjur::Config.load
      Conjur::Config.apply

      Conjur::Authn.connect nil, noask: true
    end
  end

  def retrieve_secret(variable)
    conjur_api.resource("#{Conjur.configuration.account}:variable:#{variable}").value
  rescue RestClient::ExceptionWithResponse => e
    "Exception Message: #{ e.message }"
  end

  def secret_identifier(env_secret_id)
    require 'yaml'
    YAML.load_file('/opt/app/secrets.yml')[env_secret_id]
        .to_s
        .gsub(/\$([a-zA-Z_]+[a-zA-Z0-9_]*)|\$\{(.+)\}/) { ENV[$1 || $2] }
  end
end
