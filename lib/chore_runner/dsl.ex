defmodule ChoreRunner.DSL do
  @moduledoc """
  Macros which enable the chore DSL
  """

  def parse_result_handler(nil), do: &(&1)

  def parse_result_handler({:fn, _, _} = fun) do
    Macro.escape(fun)
  end

  def parse_result_handler(handler) when is_function(handler, 1) do
    handler
  end

  def parse_result_handler(handler) do
    raise "result_handler must be a single arity function, MFA of a single arity function, or nil. Got: #{inspect(handler)}"
  end

  def using(opts) do
    quote do
      alias ChoreRunner.Chore
      @behaviour Chore

      import ChoreRunner.Reporter,
        only: [
          report_failed: 1,
          log: 1,
          set_counter: 2,
          inc_counter: 2
        ]

      import ChoreRunner.Input,
        only: [
          string: 2,
          int: 2,
          float: 2,
          file: 2,
          bool: 2,
          string: 1,
          int: 1,
          float: 1,
          file: 1,
          bool: 1
        ]

      def restriction, do: :self
      def inputs, do: []

      def validate_input(input),
        do: Chore.validate_input(%Chore{mod: __MODULE__}, input)

      def result_handler(chore) do
        result_handler =
          unquote(__MODULE__).parse_result_handler(unquote(opts)[:result_handler])
        # unquote(result_handler).(chore)
        result_handler.(chore)
      end

      defoverridable inputs: 0, restriction: 0, result_handler: 1
    end
  end
end
