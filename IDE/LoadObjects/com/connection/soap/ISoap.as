package com.connection.soap
{
	import mx.rpc.events.ResultEvent;
	
	public interface ISoap 
	{
		function execute():void;
		//function completeListener():void;
		function getResult():void;
		function dispatchEvent():void;
		
	}
}