-module(utils).
-compile([export_all]).

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
    is_atom(Type)   -> Type;
    is_list(Type)   -> list_to_atom(Type);
    is_binary(Type) -> binary_to_atom(Type, latin1)
  end.

to_integer(Type) ->
  if
    is_atom(Type)     -> list_to_integer(atom_to_list(Type));
    is_list(Type)     -> list_to_integer(Type);
    is_binary(Type)   -> binary_to_integer(Type);
    is_integer(Type)  -> Type
  end.

to_list(Type) ->
  if
    is_list(Type)     -> Type;
    is_atom(Type)     -> atom_to_list(Type);
    is_binary(Type)   -> binary_to_list(Type);
    is_integer(Type)  -> integer_to_list(Type)
  end.