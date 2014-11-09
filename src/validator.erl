-module(validator).
-compile([export_all]).

-define(TYPE_NUMBER, 2).
-define(PROPERTY_NUMBER, 3).

-include("validator.hrl").

one() ->
    [{user0, binary}, {length, [{min , 0}, {max , 10}, {allowEmpty, false}] }].

many() ->
  [
    [{user1, binary}, {length, [{min , 0}, {max , 10}, {allowEmpty, false}] }],
    [{user2, binar}, {length, [{min , 0}, {max , 10}, {allowEmpty, false}] }]
  ].

test() ->
  List = many(),
  [Header|_]= List,
  is_check(is_tuple(Header), List).

is_check(true, [FirstList|Options]) ->  {_Name, Type} = FirstList,
  isset_check_many(type, isset_validator(to_atom(Type), ?TYPE_NUMBER), to_atom(Type), FirstList, Options);
is_check(false, List) -> [check_many(L) || L<-List].

check_many([FirstList|Options]) ->
  {_Name, Type} = FirstList,
  isset_check_many(type, isset_validator(to_atom(Type),?TYPE_NUMBER), to_atom(Type), FirstList, Options).

isset_check_many(State, false, Type, _, _) -> {error, {incorrect, State, Type}};
isset_check_many(_State, _IssetValidator, _Type, _FirstList, Options) ->
  [ check_property(property, Property, Option, isset_validator(to_atom(Property), ?PROPERTY_NUMBER), is_list(Options)) || {Property, Option}<-Options].

check_property(State, Property, _Option, false, true)             -> {error, {incorrect, State, Property}};
check_property(_State, _Property, Options, _IssetValidator, true) ->
  [check_option(option, isset_validation_options(to_atom(Key)), Key,Val) || {Key,Val}<-Options ];
check_property(_State, Property, Option, _IssetValidator, false)  -> check_option(option, isset_validation_options(to_atom(Property)), Property, Option).

check_option(State, false, Key, _Val) ->  {error, {incorrect, State, Key}};
check_option(_State, true, Key, Val) ->  {Key, Val}.

isset_validator(What, N) ->
  lists:keyfind(What, N, ?VALIDATORS_LIST).

isset_validation_options(Key) ->
  Lists = [ Options || {_,_,_,Options}<-?VALIDATORS_LIST],
  lists:member(Key, lists:merge(Lists)).
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