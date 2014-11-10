-module(length_validator).
-compile([export_all]).

%% =====================================================================================================================
%% Validates the attribute of the object.
%% =====================================================================================================================
main(min, AttribName, AttribBase, AttribClient)  ->
  is_validate(
    utils:to_integer(AttribClient) > utils:to_integer(AttribBase),
    utils:to_list(AttribName)++ " is too short (minimum is " ++ utils:to_list(AttribBase)++" characters)."
  );

main(max, AttribName, AttribBase, AttribClient) ->
  is_validate(
    utils:to_integer(AttribClient) < utils:to_integer(AttribBase),
    utils:to_list(AttribName)++ " is too long (maximum is " ++ utils:to_list(AttribBase)++" characters)."
  );

main(is, AttribName, AttribBase, AttribClient) ->
  is_validate(
    utils:to_integer(AttribClient) == utils:to_integer(AttribBase),
    utils:to_list(AttribName)++ " is of wrong length (should be is " ++ utils:to_list(AttribBase)++" characters)."
  );

main(_, _AttribName, AttribBase, AttribClient) ->
  {error, incorrect_type,{AttribBase, AttribClient}}.

is_validate(true, _Message) -> ok;
is_validate(false, Message) -> {error, utils:to_binary(Message)}.


