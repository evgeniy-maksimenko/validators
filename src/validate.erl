-module(validate).
-compile([export_all]).

main() ->
  Attrs = [{<<"user0">>,<<"421">>}, {<<"user1">>,<<"231">>}, {<<"user2">>,<<"121">>}],
  Rules =
    [[{user1, binary}, {length, [{min , 0}, {max , 100}] }],
      [{user2, binary}, {length, [{min , 0}, {max , 100}] }]],

  attrs_validate:main(Attrs, Rules).
