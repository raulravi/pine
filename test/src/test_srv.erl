-module(test_srv).
-behaviour(gen_server).

-record(state, {
    token,
    username,
    url
  }).

-export([start/0, start/2, stop/1]).
-export([init/1, handle_call/3, handle_cast/2, handle_info/2, code_change/3,
         terminate/2]).

start() ->
  {ok, [Name]} = io:fread("Test name: ", "~s"),
  {ok, [Url]} = io:fread("Server Url: ", "~s"),
  {ok, [Username]} = io:fread("Username: ", "~s"),
  {ok, [Password]} = io:fread("Password: ", "~s"),
  start(list_to_atom(Name), {Url, Username, Password}).

start(Name, {Url, Username, Password}) ->
  gen_server:start({local, Name}, ?MODULE, [Url, Username, Password], []).

stop(Name) ->
  gen_server:cast(Name, stop).

init([Url, Username, Password]) ->
  case test_api:login(Url, Username, Password) of
    {ok, Token} ->
      {ok, #state{token=Token, username=Username, url=Url}};
    {error, Reason} ->
      {stop, Reason}
  end.

handle_call(_Request, _From, State) ->
  {reply, ok, State}.

handle_cast(stop, State) ->
  test_api:logout(State#state.url, State#state.username, State#state.token),
  {stop, normal, State};
handle_cast(_Request, State) ->
  {noreply, State}.

handle_info(_Info, State) ->
  {noreply, State}.

code_change(_OldVsn, State, _Extra) ->
  {ok, State}.

terminate(_Reason, _State) ->
  ok.
