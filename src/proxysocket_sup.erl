%%% -------------------------------------------------------------------
%%% Author  : skruger
%%% Description :
%%%
%%% Created : Oct 30, 2010
%%% -------------------------------------------------------------------
-module(proxysocket_sup).

-behaviour(supervisor).
%% --------------------------------------------------------------------
%% Include files
%% --------------------------------------------------------------------
-include("surrogate.hrl").
%% --------------------------------------------------------------------
%% External exports
%% --------------------------------------------------------------------
-export([start_link/1,proxy_childspecs/1]).

%% --------------------------------------------------------------------
%% Internal exports
%% --------------------------------------------------------------------
-export([
	 init/1
        ]).

%% --------------------------------------------------------------------
%% Macros
%% --------------------------------------------------------------------
-define(SERVER, ?MODULE).

%% --------------------------------------------------------------------
%% Records
%% --------------------------------------------------------------------

%% ====================================================================
%% External functions
%% ====================================================================

start_link(Args) ->
	?DEBUG_MSG("Starting ~p~n",[?MODULE]),
	supervisor:start_link({local,?MODULE},?MODULE,Args).


%% ====================================================================
%% Server functions
%% ====================================================================
%% --------------------------------------------------------------------
%% Func: init/1
%% Returns: {ok,  {SupFlags,  [ChildSpec]}} |
%%          ignore                          |
%%          {error, Reason}
%% --------------------------------------------------------------------
init(ConfName) ->
	CSpecs = proxy_childspecs(ConfName),
    ?DEBUG_MSG("~p supervisor init using config name: ~p.~n~p~n",[?MODULE,ConfName,CSpecs]),
	{ok,{{one_for_one,15,5}, 
		 CSpecs
		 }}.

proxy_childspecs(ConfName) ->
	Conf = proxyconf:get(ConfName,[]),
	proxy_childspec_list(Conf,[]).

proxy_childspec_list([],Acc) ->
	Acc;
proxy_childspec_list([{CName,Props}|R],Acc) ->
	Spec = {CName,
			{CName,start_link,[Props]},
			permanent,
			10000,
			worker,
			[]},
	proxy_childspec_list(R,[Spec|Acc]).

%% ====================================================================
%% Internal functions
%% ====================================================================

