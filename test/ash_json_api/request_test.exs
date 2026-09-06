# SPDX-FileCopyrightText: 2019 ash_json_api contributors <https://github.com/ash-project/ash_json_api/graphs/contributors>
#
# SPDX-License-Identifier: MIT

defmodule AshJsonApi.RequestTest do
  use ExUnit.Case, async: true

  alias AshJsonApi.Request

  defmodule Post do
    use Ash.Resource,
      domain: Test.Acceptance.FieldNamesTest.Domain,
      data_layer: Ash.DataLayer.Ets,
      extensions: [AshJsonApi.Resource]

    ets do
      private?(true)
    end

    json_api do
      type "post"

      argument_names fn
        :read, :id -> "post_id"
      end

      routes do
        base "/posts"
        get :read, route: "/:post_id"
      end
    end

    attributes do
      uuid_primary_key(:id)
      attribute(:title, :string, allow_nil?: false, public?: true)
      attribute(:body, :string, public?: true)
      attribute(:view_count, :integer, public?: true, default: 0)
    end

    actions do
      defaults([:read])
    end
  end

  defmodule Domain do
    use Ash.Domain,
      otp_app: :ash_json_api,
      extensions: [AshJsonApi.Domain]

    json_api do
      authorize? false
      log_errors? false
    end

    resources do
      resource Post
    end
  end

  defmodule Router do
    use AshJsonApi.Router, domain: Domain
  end

  import AshJsonApi.Test

  setup do
    Application.put_env(:ash_json_api, Domain, json_api: [test_router: Router])
    :ok
  end

  test "can make a request with renamed path parameter" do
    assert [] = get(Domain, "/posts/#{Ash.UUID.generate()}", status: 200, router: Router)
  end
end
