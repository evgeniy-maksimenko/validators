-module(validator).
-compile([export_all]).

-define(TYPES, [<<"binary">>, <<"integer">>, <<"list">>, <<"boolean">>]).
-define(PROPERTIES, [<<"email">>, <<"length">>]).

-record(properties,{
  props  = [
    {<<"length">>,[<<"min">>,<<"max">>]},
    {<<"email">>,[<<"email">>]}
  ]
}).

test() ->
  Rules =
  [
    [{username, binary}, {property, length}, [{max, 100}, {min, 0}]],
    [{email, binary}, {property, email}]
  ],
  valid_rules(Rules).

valid_rules(Rules) when is_list(Rules) ->
  [ valid_rule(Rule) || Rule <- Rules];
valid_rules(Rules) ->
  {error, {incorrect_format, Rules}}.

valid_rule([]) -> {error, incorrect_rules};
valid_rule([Type]) -> valid_tuple(Type, ?TYPES);
valid_rule([Type, Property]) -> valid_type_prop(valid_tuple(Type, ?TYPES), valid_tuple(Property, ?PROPERTIES));
valid_rule([Type, Property | [Options]]) -> valid_type_prop_opts(valid_tuple(Type, ?TYPES), valid_tuple(Property, ?PROPERTIES), Options).

valid_type_prop_opts(_Type, {error, _Reason} = Reason, _Options) -> [Reason];
valid_type_prop_opts(Type, Propperties, Options) ->
  {_,Param} = Propperties,
  ListOpts = [Type, Propperties, valid_opts(Param, Options)],
  is_opt_has_error(true, lists:keyfind(error, 1 , ListOpts), ListOpts).

valid_opts(Param, Options) ->
  ListOpts = [ valid_opt(isset_property(?PROPERTIES, Param), Option) || Option <- Options ],
  is_opt_has_error(false, lists:keyfind(error, 1 , ListOpts), ListOpts).

is_opt_has_error(_, false, ListOpts)  -> ListOpts;
is_opt_has_error(true, Error, _ListOpts) -> [Error];
is_opt_has_error(false, Error, _ListOpts) -> Error.

valid_opt(_Param, {_}) -> {error, {incorrect_options}};
valid_opt({error, _Reason} = Reason, _) -> [Reason];
valid_opt(Param, {Key, Value}) ->
  P=#properties{},
  valid_child_opts(isset_property(proplists:get_value(Param, P#properties.props),to_binary(Key)),Value).

valid_child_opts({error, _Reason} = Reason, _) ->Reason;
valid_child_opts(Key, Value) ->{Key, Value}.

%% =====================================================================================================================
%% Validation types and properties
%% =====================================================================================================================
valid_type_prop({error, _Reason} = Reason, _Property) -> [Reason];
valid_type_prop(_Type, {error, _Reason} = Reason) -> [Reason];
valid_type_prop({KeyType, ValueType}, {KeyParam,ValueParam}) -> [{KeyType, ValueType}, {KeyParam,ValueParam}].

valid_tuple({Param, Type}, List) -> is_member_list(
  lists:member(to_binary(Type), List),
  lists:member(to_binary(Type), List),
  to_binary(Param),
  to_binary(Type)
).
%% =====================================================================================================================
%% Converting types
%% =====================================================================================================================
to_binary(Type) ->
  if
    is_binary(Type) -> Type;
    is_list(Type)   -> list_to_binary(Type);
    is_atom(Type)   -> list_to_binary(atom_to_list(Type))
  end.

to_atom(Type) ->
  if
    is_atom(Type) -> Type;
    is_list(Type) -> list_to_atom(Type);
    is_binary(Type) -> binary_to_atom(Type, latin1)
  end.
%% =====================================================================================================================
%% Returns true if Elem matches some element of List, otherwise error.
%% =====================================================================================================================
is_member_list(undefined, false, Param, _Type) -> {error, {incorrect, Param}};
is_member_list(_, true, Param, Type) -> {Param, Type};
is_member_list(_, false, Param, _Type) -> {error, {incorrect, Param}}.
%% =====================================================================================================================
%% Isset property
%% =====================================================================================================================
isset_property(List, Property)->
  is_member_prop(lists:member(Property, List), Property).

is_member_prop(true, Property) -> Property;
is_member_prop(false, Property) -> {error, {not_exists, Property}}.