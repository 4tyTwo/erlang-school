-module(markov_node).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API EXPORT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export([create    /1]).
-export([get_random/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TYPE EXPORT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-export_type([markov_node/1]).
-export_type([event_possibility_map/1]).

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% TYPES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-type event_possibility_map(T) :: #{
    T := float(),
    T => float()
}.

-type markov_node(T) :: #{
    0       := T,
    float() => T
}.

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% API %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

-spec create(EventMap :: event_possibility_map(T)) ->
    markov_node(T) | {error, sum_is_not_1}.

create(EventMap) ->
    Possibilities = maps:values(EventMap),
    case lists:sum(Possibilities) of
        1.0 ->
            create_node(EventMap);
        _ ->
            {error, sum_is_not_1}
    end.

-spec get_random(MarkovNode :: markov_node(T)) ->
    T.

get_random(MarkovNode) ->
    Value = rand:uniform(),
    Keys = maps:keys(MarkovNode),
    ok = lager:debug("Keys: ~p, Value: ~p", [Keys, Value]),
    maps:get(lists:max([Item || Item <- Keys, Item =< Value]), MarkovNode).

%%%%%%%%%%%%%%%%%%%%%%%%%% PRIVATE FUNCTIONS %%%%%%%%%%%%%%%%%%%%%%%%%%

create_node(EventMap) ->
    create_node(maps:keys(EventMap), EventMap, 0, #{}).

create_node([], _, _, Result) ->
    Result;

create_node([Event | Rest] = _Events, EventMap, Acc, Result) ->
    Possibility = maps:get(Event, EventMap),
    create_node(Rest, EventMap, Acc + Possibility, Result#{Acc => Event}).
