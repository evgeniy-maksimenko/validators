-module(type_validate).
-compile([export_all]).

main(binary, Param) -> is_binary(Param).