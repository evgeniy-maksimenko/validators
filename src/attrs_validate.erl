-module(attrs_validate).
-compile([export_all]).

-define(MODULE_PARTICAL, "_validator").

main(Attrs, Rules)->
  List = rules_validate:main(Rules),
  is_rules_correct(List, Attrs).

is_rules_correct({ok, SuccessList}, Attrs) ->
  [Header|_] = SuccessList,
  is_has_tuple(is_tuple(Header), SuccessList, Attrs);
is_rules_correct({error, _} = Reason, _) -> Reason.

is_has_tuple(true, [{Key,Val}|Rules], Attrs) ->
  is_rule_set
  (
    lists:keymember(utils:to_binary(Key),1,Attrs),
    Val,
    utils:to_binary(Key),
    proplists:get_value(utils:to_binary(Key), Attrs),
    Rules
  );
is_has_tuple(false, SuccessList, Attrs) ->
  List = [
    is_rule_set
    (
      lists:keymember(utils:to_binary(Key),1,Attrs),
      Val,
      utils:to_binary(Key),
      proplists:get_value(utils:to_binary(Key), Attrs),
      Rules
    )
    || [{Key,Val}|Rules]<-SuccessList],
  lists:merge(List).

is_rule_set(true, ValRule, KeyClient, ValClient, Rules) ->
  List = [ get_property(ValRule, KeyClient, ValClient, Propperty, Options) || {Propperty, Options} <-Rules],
  lists:merge(List);
is_rule_set(false, _ValRule, _KeyClient, _ValClient, _Rules) -> [].

get_property(ValRule, KeyClient, ValClient, Propperty, Options) ->
  [ get_option(type_validate:main(ValRule, ValClient), KeyClient, ValClient, Propperty, KeyOpt, ValOpt) || {KeyOpt, ValOpt}<-Options].

get_option(true, KeyClient, ValClient, Propperty, KeyOpt, ValOpt) ->
  Module = utils:to_atom(utils:to_list(Propperty) ++ ?MODULE_PARTICAL),
  Module:main(KeyOpt, KeyClient, ValOpt, ValClient);
get_option(false, _KeyClient, ValClient, _Propperty, _KeyOpt, _ValOpt) ->
  {error, utils:to_binary(utils:to_list(ValClient) ++ " is invalid type.")}.

