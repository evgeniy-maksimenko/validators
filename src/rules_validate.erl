-module(rules_validate).
-compile([export_all]).

-export([main/1]).

-define(ERROR_NUMBER, 1).
-define(TYPE_NUMBER, 2).
-define(PROPERTY_NUMBER, 3).

-include("validator.hrl").

main(List) ->
  [Header|_] = List,
  RulesList = is_check(is_tuple(Header), List),
  get_error(lists:keymember(error, ?ERROR_NUMBER, RulesList), lists:keyfind(error, ?ERROR_NUMBER, RulesList), List).

get_error(true, RulesList, _List) -> RulesList;
get_error(false, false, List) -> {ok, List}.

is_check(true, [FirstList|Options]) ->  {_Name, Type} = FirstList,
  isset_check_many(type, isset_validator(utils:to_atom(Type), ?TYPE_NUMBER), utils:to_atom(Type), FirstList, Options);
is_check(false, List) -> [check_many(L) || L<-List].

check_many([FirstList|Options]) ->
  {_Name, Type} = FirstList,
  [List] = isset_check_many(type, isset_validator(utils:to_atom(Type), ?TYPE_NUMBER), utils:to_atom(Type), FirstList, Options),
  List.

isset_check_many(State, false, Type, _, _) -> [{error, {incorrect, State, Type}}];
isset_check_many(_State, _IssetValidator, _Type, _FirstList, Options) ->
  [ check_property(property, Property, Option, isset_validator(utils:to_atom(Property), ?PROPERTY_NUMBER), is_list(Options)) || {Property, Option}<-Options].

check_property(State, Property, _Option, false, true)             ->
  {error, {incorrect, State, Property}};
check_property(_State, _Property, Options, _IssetValidator, true) ->
  RulesList = [check_option(option, isset_validation_options(utils:to_atom(Key)), Key,Val) || {Key,Val}<-Options ],
  get_error(lists:keymember(error, ?ERROR_NUMBER, RulesList), lists:keyfind(error, ?ERROR_NUMBER, RulesList), []);
check_property(_State, Property, Option, _IssetValidator, false)  ->
  check_option(option, isset_validation_options(utils:to_atom(Property)), Property, Option).

check_option(State, false, Key, _Val) ->  {error, {incorrect, State, Key}};
check_option(_State, true, Key, Val)  ->  {Key, Val}.

isset_validator(What, N) ->
  lists:keyfind(What, N, ?VALIDATORS_LIST).

isset_validation_options(Key) ->
  Lists = [ Options || {_,_,_,Options}<-?VALIDATORS_LIST],
  lists:member(Key, lists:merge(Lists)).