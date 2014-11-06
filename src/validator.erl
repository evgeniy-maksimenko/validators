-module(validator).
-compile([export_all]).

%% -record(validators,{
%%   length,
%%   required,
%%   email
%% }).

main() ->
  Rules =
    [
      {<<"username">>, <<"length">>, {<<"max">>,10}},
      {<<"username">>, <<"required">>},
      {<<"email">>, <<"required">>},
      {<<"email">>, <<"email">>}
    ],
  [is_valid_val(Val) || Val<-Rules].

is_valid_val({Attr, Validator, Opts}) -> is_valid_opts(Attr, Validator, Opts, is_tuple(Opts));
is_valid_val({Attr, Validator}) ->
  is_valid_params(
    convert_to_binary(Attr),
    convert_to_binary(Validator),
    empty,
    empty);
is_valid_val(_) -> {error, wrong_rules_structure}.

is_valid_opts(Attr,Validator,{Key,Val}, true) ->
  is_valid_params(
    convert_to_binary(Attr),
    convert_to_binary(Validator),
    convert_to_binary(Key),
    convert_to_binary(Val));
is_valid_opts(_,_,_,false) -> {error, wrong_options_structure}.

is_valid_params(Attr,Validator, empty,empty) -> {Attr,Validator};
is_valid_params(Attr,Validator, Key,Val) -> {Attr,Validator, Key,Val}.

test() ->
  is_valid_val({<<"username">>,<<"length">>,{<<"max">>,10}}).

convert_to_binary(Val) ->
  if  is_list(Val)    -> list_to_binary(Val);
      is_binary(Val)  -> Val;
      is_tuple(Val)   -> list_to_binary(tuple_to_list(Val));
      is_integer(Val) -> integer_to_binary(Val)
  end.


