defmodule Omise.Event do
  @moduledoc ~S"""
  Provides Event API interfaces.

  https://www.omise.co/events-api
  """

  import Omise.HTTP

  defstruct [
    object:   "event",
    id:       nil,
    livemode: nil,
    location: nil,
    key:      nil,
    created:  nil,
    data:     nil
  ]

  @type t :: %__MODULE__{
    object:   String.t,
    id:       String.t,
    livemode: boolean,
    location: String.t,
    key:      String.t,
    created:  String.t,
    data:     Omise.Charge.t | Omise.Customer.t | Omise.Card.t | Omise.Dispute.t |
              Omise.Recipient.t | Omise.Refund.t | Omise.Transfer.t
  }

  @endpoint "events"

  @doc ~S"""
  List all events.

  Returns `{:ok, events}` if the request is successful, `{:error, error}` otherwise.

  ## Query Parameters:
    * `offset` - (optional, default: 0) The offset of the first record returned.
    * `limit` - (optional, default: 20, maximum: 100) The maximum amount of records returned.
    * `from` - (optional, default: 1970-01-01T00:00:00Z, format: ISO 8601) The UTC date and time limiting the beginning of returned records.
    * `to` - (optional, default: current UTC Datetime, format: ISO 8601) The UTC date and time limiting the end of returned records.

  ## Examples

      Omise.Event.list

      Omise.Event.list(limit: 10)

  """
  @spec list(Keyword.t, Keyword.t) :: {:ok, Omise.List.t} | {:error, Omise.Error.t}
  def list(params \\ [], opts \\ []) do
    opts = Keyword.merge(opts, as: %Omise.List{data: [%__MODULE__{}]})
    get(@endpoint, params, opts)
  end

  @doc ~S"""
  Retrieve an event.

  Returns `{:ok, event}` if the request is successful, `{:error, error}` otherwise.

  ## Examples

      Omise.Event.retrieve("evnt_test_5285sfiqfo8t32x6h5h")

  """
  @spec retrieve(String.t, Keyword.t) :: {:ok, t} | {:error, Omise.Error.t}
  def retrieve(id, opts \\ []) do
    opts = Keyword.merge(opts, as: %__MODULE__{})
    get("#{@endpoint}/#{id}", [], opts)
  end

  defimpl Poison.Decoder do
    def decode(%{data: %{"object" => object} = raw_data} = event, _) do
      module = Module.concat(Omise, String.capitalize(object))
      data   = Poison.Decode.decode(raw_data, as: struct(module))
      %{event | data: data}
    end
    def decode(event, _) do
      event
    end
  end
end
