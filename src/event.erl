%%%-------------------------------------------------------------------
%%% @author stephenciauri
%%% @copyright (C) 2015, <COMPANY>
%%% @doc
%%%
%%% @end
%%% Created : 01. Dec 2015 12:39 PM
%%%-------------------------------------------------------------------
-module(event).
-author("stephenciauri").

%% API
-export([start_link/2,cancel/1]).
-export([init/3]).


-record(state, {server,
                name="",
                to_go=0}).

loop(S = #state{server=Server, to_go=[T|Next]}) ->
  receive
    {Server, Ref, cancel} ->
      Server ! {Ref, ok}
  after T*1000 ->
    if Next =:= [] ->
      Server ! {done, S#state.name};
      Next =/= [] ->
        loop(S#state{to_go = Next})
    end
  end.

%% Workaround to 49 day limitation for Erlang millisecond limit
normalize(N) ->
  Limit = 49*24*60*60,
  [N rem Limit | lists:duplicate(N div Limit, Limit)].

% Calculates the difference in seconds between now and timeout
time_to_go(TimeOut={{_,_,_}, {_,_,_}})->
  Now = calendar:local_time(),
  ToGo = calendar:datetime_to_gregorian_seconds(TimeOut) - calendar:datetime_to_gregorian_seconds(Now),
  Secs = if ToGo > 0 -> ToGo;
           ToGo =< 0 -> 0
         end,
  normalize(Secs).

%% Standard start function
start(EventName, DateTime) ->
  spawn(?MODULE, init, [self(), EventName, DateTime]).

start_link(EventName, DateTime) ->
  spawn_link(?MODULE, init, [self(),EventName,DateTime]).

%% the guts!
init(Server,EventName,DateTime) ->
  loop(#state{server=Server,
              name=EventName,
              to_go=time_to_go(DateTime)}).

cancel(Pid) ->
  %% Monitor in the case the process is already dead.
  Ref = erlang:monitor(process, Pid),
  Pid ! {self(), Ref, cancel},
  receive
    {Ref, ok} ->
      erlang:demonitor(Ref, [flush]),
      ok;
    {'DOWN', Ref, process, Pid, _Reason} ->
      ok
  end.