-module(ejpet_generators_tests).
-author('nicolas.michel.lava@gmail.com').

-ifdef(TEST).
-include_lib("eunit/include/eunit.hrl").

%%-define(BACKENDS, [jsx, jiffy, mochijson2]).
-define(BACKENDS, [jsx]).
-define(REF_BACKEND, jsx).


basic_test_() ->
    Tests = [
             {"true",
              [{<<"true">>, {true, []}},
               {<<"false">>, {false, []}},
               {<<"42">>, {false, []}},
               {<<"\"foo\"">>, {false, []}},
               {<<"{\"foo\": []}">>, {false, []}}
              ]}
            ],
    generate_test_list(Tests).

object_test_() ->
    Tests = [
             {"{}",
              [{<<"{}">>, {true, []}},
               {<<"{\"foo\": []}">>, {true, []}},
               {<<"{\"foo\": [], \"bar\": {}}">>, {true, []}},
               {<<"[]">>, {false, []}},
               {<<"[{}]">>, {false, []}}
              ]},
             {"{\"foo\": 42}",
              [{<<"{\"foo\": 42}">>, {true, []}},
               {<<"{\"foo\": 41}">>, {false, []}},
               {<<"{\"foo\": []}">>, {false, []}},
               {<<"{\"foo\": \"42\"}">>, {false, []}},
               {<<"{\"neh\": [], \"foo\": 42, \"bar\": {\"neh\": false}}">>, {true, []}},
               {<<"{\"neh\": [], \"foo\": 40, \"bar\": {\"neh\": 42}}">>, {false, []}}
              ]},
             {"{_:{_:42}, _:true}",
              [{<<"{\"foo\": true, \"bar\": {\"neh\": 42}}">>, {true, []}}
              ]}
            ],
    generate_test_list(Tests).

list_test_() ->
    Tests = [
             {"[]",
              [{<<"[]">>, {true, []}},
               {<<"[true]">>, {false, []}}
              ]},
             {"[*]",
              [{<<"[]">>, {true, []}},
               {<<"[true]">>, {true, []}},
               {<<"[true, false, {\"toto\":42}]">>, {true, []}}
              ]},
             {"[true]",
              [{<<"[true]">>, {true, []}},
               {<<"[false]">>, {false, []}},
               {<<"[]">>, {false, []}}]},
             {"[true, false]",
              [{<<"[true, false]">>, {true, []}},
               {<<"[false]">>, {false, []}},
               {<<"[true]">>, {false, []}},
               {<<"[false, true]">>, {false, []}},
               {<<"[42, true, false]">>, {false, []}},
               {<<"[true, false, 42]">>, {false, []}},
               {<<"[true, true, false]">>, {false, []}}]},
             {"[true, *, false]",
              [{<<"[true, false]">>, {true, []}},
               {<<"[false, true]">>, {false, []}},
               {<<"[true, 42, false]">>, {true, []}},
               {<<"[42, true, false]">>, {false, []}},
               {<<"[true, 42, \"foo\", false]">>, {true, []}},
               {<<"[true, 42, false, \"foo\"]">>, {false, []}}]},
             {"[*, [1, *, [*, 42, *]], *]",
              [{<<"[[1, [42]]]">>, {true, []}},
               {<<"[[1, []]]">>, {false, []}},
               {<<"[[42, [42]]]">>, {false, []}},
               {<<"[[1, [42], [\"foo\"]]]">>, {false, []}}]},
             {"[*, {_: [*, 42]}]",
              [{<<"[{\"foo\": [42]}]">>, {true, []}},
               {<<"[42, {\"bar\": 42, \"foo\": [42]}]">>, {true, []}},
               {<<"[42, {\"foo\": [\"neh\", 42]}]">>, {true, []}},
               {<<"[42, {\"foo\": [42, \"neh\"]}]">>, {false, []}},
               {<<"[{\"foo\": [42]}, \"neh\"]">>, {false, []}}
              ]}
            ],
    generate_test_list(Tests).

iterable_test_() ->
    Tests = [
             {"<>",
              [{<<"[]">>, {true, []}},
               {<<"{}">>, {true, []}},
               {<<"{\"foo\":42}">>, {true, []}},
               {<<"{\"bar\": {}, \"foo\": 42}">>, {true, []}},
               {<<"[42]">>, {true, []}},
               {<<"[\"foo\", 42]">>, {true, []}},
               {<<"[{\"foo\":42}]">>, {true, []}}
              ]},
             {"<42>",
              [
               {<<"{\"foo\":42}">>, {true, []}},
               {<<"{\"bar\": {}, \"foo\": 42}">>, {true, []}},
               {<<"[42]">>, {true, []}},
               {<<"[\"foo\", 42, 13]">>, {true, []}},
               {<<"[{\"foo\":42}]">>, {false, []}},
               {<<"[{\"foo\":42}, 42]">>, {true, []}},
               {<<"[41]">>, {false, []}}
              ]},
             {"<42, {_:[*, 42, *]}>",
              [
               {<<"[1, \"foo\", {\"bar\": [42]}, 42]">>, {true, []}},
               {<<"{\"foo\": 42, \"neh\": {\"bar\": [42]}}">>, {true, []}}
              ]},
             {"*/42",
              [
               {<<"{\"foo\":42}">>, {true, []}},
               {<<"{\"bar\": {}, \"foo\": 42}">>, {true, []}},
               {<<"[42]">>, {true, []}},
               {<<"[\"foo\", 42, 13]">>, {true, []}},
               {<<"[{\"foo\":42}]">>, {false, []}},
               {<<"[{\"foo\":42}, 42]">>, {true, []}},
               {<<"[41]">>, {false, []}}
              ]},
             {"<{_:42}>",
              [{<<"[{\"bar\": 42}]">>, {true, []}}
              ]},
             {"<{_:[*, 42, *]}>",
              [
               {<<"[{\"bar\": [42]}]">>, {true, []}}
             ]},
             {"<42>",
              [{<<"[1, \"foo\", {\"bar\": [42]}, 42]">>, {true, []}}
              ]},
             {"<[*, 42, *]>",
              [{<<"[[42]]">>, {true, []}}
              ]},
             {"{_:[*, 42, *]}",
              [{<<"{\"bar\": [42]}">>, {true, []}}
              ]},
             {"<{_:[*, 42, *]}>",
              [{<<"{\"foo\": {\"bar\": [42]}}">>, {true, []}}
              ]},
             {"<{_:[*, 42, *]}>",
              [{<<"[{\"bar\": [42]}]">>, {true, []}}
              ]}
            ],
    generate_test_list(Tests).

descendant_test_() ->
    Tests = [
             {"**/42",
              [
               {<<"[]">>, {false, []}},
               {<<"{}">>, {false, []}},
               {<<"42">>, {false, []}},
               {<<"[42]">>, {true, []}},
               {<<"{\"foo\":42}">>, {true, []}},
               {<<"{\"bar\": {}, \"foo\": 42}">>, {true, []}},
               {<<"[\"foo\", 42]">>, {true, []}},
               {<<"[[{\"bar\": [{\"foo\": [\"bar\", 42, 13]}]}]]">>, {true, []}}
              ]},
             {"**/[*, 42]",
              [
               {<<"[]">>, {false, []}},
               {<<"{}">>, {false, []}},
               {<<"[42]">>, {false, []}},
               {<<"[\"foo\", [42]]">>, {true, []}},
               {<<"{\"foo\" : [42]}">>, {true, []}},
               {<<"[[{\"bar\": [{\"foo\": [\"this one matches\", 42]}]}], \"next does not match\", 42]">>, {true, []}}
              ]},
             {"**/{_:42}",
              [{<<"[{\"bar\": 42}]">>, {true, []}}
              ]}
            ],
    generate_test_list(Tests).

complex_test_() ->
    Tests = [
             {"{_:[*]}",
              [{<<"{\"foo\": [42]}">>, {true, []}},
               {<<"{\"foo\": []}">>, {true, []}},
               {<<"{\"bar\": [\"neh\", 42, {}]}">>, {true, []}},
               {<<"{\"bar\": 42, \"foo\": {}}">>, {false, []}}
              ]}
            ],
    generate_test_list(Tests).

capture_test_() ->
    Tests = [
             {"(?<value>{_:[*]})",
              [{<<"{\"foo\": [42]}">>, {true, [{"value", <<"{\"foo\":[42]}">>}]}}
              ]},
             {"(?<value>{_:([*])})",
              [{<<"{\"foo\": [42]}">>, {true, [{"value", <<"{\"foo\":[42]}">>}, {positional, <<"[42]">>}]}}
              ]},
             {"(?<full>{_:(?<local>[*])})",
              [{<<"{\"foo\": [42]}">>, {true, [{"full", <<"{\"foo\":[42]}">>}, {"local", <<"[42]">>}]}}
              ]},
             {"
              <
                  {
                      _:[*, (?<found><42>), *]
                  }
              >
              ",
              [{<<"[1, 2, {\"foo\": 42, \"bar\": [{\"neh\": 42}]}, 41, 42]">>, {true, [{"found", <<"{\"neh\":42}">>}]}}
              ]}
            ],
    generate_test_list(Tests).

generate_test_list(TestDescs) ->
    [generate_test_list(TestDescs, Backend) || Backend <- ?BACKENDS].

generate_test_list(TestDescs, Backend) ->
    lists:reverse(
      lists:foldl(fun({Pattern, T}, Acc) ->
                          %% Produce the matcher
                          %% 
                          {[], AST} = ejpet_parser:parse(ejpet_scanner:tokenize(Pattern)),
                          F = (ejpet:generator(Backend)):generate_matcher(AST),

                          lists:foldl(fun ({Node, Expected = {ExpStatus, ExpCaptures}}, Acc) ->
                                              TestName = Pattern ++ " | " ++ binary_to_list(Node) ++ " | " ++ atom_to_list(ExpStatus),

                                              %% Execute the test
                                              %% 
                                              {Status, Captures} = F(Backend:decode(Node)),

                                              %% Transform captures to text
                                              %% 
                                              JSONCaptures = [{VarName, Backend:encode(Cap)} || {VarName, Cap} <- Captures],

                                              %% Parse again and stringify captures using the reference backend
                                              %% 
                                              RefCaptures = [{VarName, ?REF_BACKEND:encode(?REF_BACKEND:decode(Cap))} || {VarName, Cap} <- JSONCaptures],

                                      
                                              [{TestName, ?_test(?assert({Status, JSONCaptures} == Expected))} | Acc]
                                      end, Acc, T)
                  end, [], TestDescs)).

-endif.

