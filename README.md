# Überauth SAML

> SAML 2.0 strategy for Überauth.

**Currently in development, not yet functional. Stay tuned for updates!**

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
        saml: {Ueberauth.Strategy.SAML, []}
      ]
    ```

1.  Update your provider configuration:

    ```elixir
    config :ueberauth, Ueberauth.Strategy.SAML,
      idp_url: System.get_env("SAML_IDP_URL"),
      metadata_url: System.get_env("SAML_METADATA_URL"),
      callback_url: System.get_env("SAML_CALLBACK_URL")
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
