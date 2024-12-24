defmodule DropsWeb.Components.NestedForm do
  @moduledoc """
  HTML spec explicitly states that `<form>` tags can not be nested.

  There are cases where we have a "main" form and we'd like to
  have it include other unrelated "nested" inputs.

  While we can't nest a `<form>`, we can generate `<form>` tag outside
  our "main" form, associate the "nested" inputs using the `form` attribute.

  This component makes it easy to create a "nested" form on the fly that will target the
  nested component.

  1) Instead of using `form/1` helper, use `nested_form/1` and provide a unique ID.
  2) Associate all your inputs using an attribute `form` refering to that ID

  ```
    <.nested_form id="my-nested-form" phx-target={@myself} phx-change="validate" phx-submit="save" />
    <input name="my_input" form={@form_dom_id} />
    <...>
  end
  ```

  Important note: our inputs currently do not support outputing a `form` attribute;
  the `form` assign is normally used for the `HTMLForm` struct.
  Adapt the helper by adding the `form_dom_id` assign if need be.

  Limitation: `phx-hook` is not supported
  (see https://github.com/phoenixframework/phoenix_live_view/issues/2563)

  Implementation note:
  An alternative approach would be to have a LiveComponent that would hold the forms needed,
  received via `send_update`.
  The upside is that it would support `phx-hook` for these `<form>`.
  The downsides are that it can't cleanup the forms when the components are removed,
  it requires adding that component on all pages that might need it,
  and it's a slightly more complex solution.
  Also, the wrapping `div` makes it easier to intercept events if it becomes necessary
  """

  use Phoenix.Component
  attr :id, :string, required: true
  attr :rest, :global
  slot(:inner_block)

  def nested_form(assigns) do
    if Map.has_key?(assigns.rest, :"phx-hook"),
      do: raise("phx-hook is not supported for nested forms")

    ~H"""
    <div
      id={"nested-form-#{@id}"}
      phx-hook="NestedForm"
      data-nested-form={
        @rest
        |> Map.put(:id, @id)
        |> transform_values(&Phoenix.HTML.Safe.to_iodata/1)
        |> Jason.encode!()
      }
    >
      {render_slot(@inner_block)}
    </div>
    """
  end

  @doc """
  This generates the `<div>` that will hold all the "nested forms".

  This is included in the app's layout, there is no need to add it anywhere else
  """
  def nested_form_holder(assigns) do
    ~H"""
    <div id="all-nested-forms" phx-update="ignore" />
    """
  end

  @doc """
  Transforms the values of a map using a function
  iex> %{a: 1, b: 2} |> transform_values(&to_string/1)
  %{a: "1", b: "2"}
  """
  @spec transform_values(Enum.t(), (any -> any)) :: map
  def transform_values(source, transform) do
    :maps.map(fn _key, value -> transform.(value) end, source)
  end
end
