# Überauth SAML

> SAML 2.0 strategy for Überauth.

Currently Überauth SAML parses the IDP response and pulls a static set of attributes from the included Subject assertion:

* User.FirstName  -> auth.info.first_name
* User.LastName   -> auth.info.last_name
* User.email      -> auth.info.email

Future versions of this strategy will allow mappings from attribute keys to fields in the info struct, for now this version is 
tailored to work against OneLogin.

## Installation

1. Add `:ueberauth_saml` to your list of dependencies in `mix.exs`:

    ```elixir
    def deps do
      [{:ueberauth_saml, "~> 0.1"}]
    end
    ```

1. Add the strategy to your applications:

    ```elixir
    def application do
      [applications: [:ueberauth_saml]]
    end
    ```

1. Add SAML to your Überauth configuration:

    ```elixir
    config :ueberauth, Ueberauth,
      providers: [
        saml: {Ueberauth.Strategy.SAML, [
          callback_methods:       ["POST"],
          idp_metadata_url:       "https://app.onelogin.com/saml/metadata/1",
          private_key:            "priv/saml/saml.pem",
          trusted_fingerprints:   ['ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab:ab'],
          verify_recipient:       false,
          verify_audience:        false
        ]}
      ]
    ```

1.  Include the Überauth plug in your controller:

    ```elixir
    defmodule MyApp.AuthController do
      use MyApp.Web, :controller
      plug Ueberauth
      ...
    end
    ```

1.  Create the request and callback routes if you haven't already:

    ```elixir
    scope "/auth", MyApp do
      pipe_through :browser

      get "/:provider", AuthController, :request
      get "/:provider/callback", AuthController, :callback
    end
    ```

1. Your controller needs to implement callbacks to deal with `Ueberauth.Auth` and `Ueberauth.Failure` responses.

For an example implementation see the [Überauth Example](https://github.com/ueberauth/ueberauth_example) application.

## Calling

Depending on the configured url you can initial the request through:

    /auth/saml

## License

Please see [LICENSE](https://github.com/ueberauth/ueberauth_saml/blob/master/LICENSE) for licensing details.
