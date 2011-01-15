% Handle constants in Elixir. There are two kind of constants:
%
%   - Stored constants
%   - Compiled constants
%
% Stored constants are store in an ETS table and are explicitly
% assigned in the source code:
%
%    const Foo = 2
%
% Compiled constants are constants that are compiled to erlang
% modules and consequently are not stored in the ets table.
-module(elixir_constants).
-export([boot/0, lookup/1, store/2]).
-include("elixir.hrl").

% Boot constants by setting ETS table.
boot() ->
  ets:new(ex_constants, [ordered_set, public, named_table]).

% Lookup a constant with the given name in the ETS table. Raises
% an error if the constant does not exist.
lookup(Name) ->
  case code:ensure_loaded(Name) of
    {module, Name} -> #elixir_object{name=Name, parent="Module"};
    _ ->
      case ets:lookup(ex_constants, Name) of
        []   -> erlang:error({badarg, "No constant " ++ atom_to_list(Name) ++ " defined"});
        Else -> element(2, hd(Else))
      end
  end.

% Store a given constant in the lookup table. Raises an error
% if the constant was already stored.
store(Name, Value) ->
  case ets:member(ex_constants, Name) of
    true  -> erlang:error({badarg, "Constant " ++ atom_to_list(Name) ++ " is already defined"});
    false -> ets:insert(ex_constants, {Name, Value})
  end.