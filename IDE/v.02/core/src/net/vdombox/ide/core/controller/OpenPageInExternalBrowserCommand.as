package net.vdombox.ide.core.controller
{
	import flash.net.URLRequest;
	import flash.net.navigateToURL;
	
	import net.vdombox.ide.core.model.ServerProxy;
	import net.vdombox.ide.core.model.StatesProxy;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class OpenPageInExternalBrowserCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var statesProxy : StatesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			var serverProxy : ServerProxy = facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
			
			var url : String;
			
			url = "http://" + serverProxy.server + "/" + statesProxy.selectedApplication.id 
				+ "/" +	statesProxy.selectedPage.id;
			
				navigateToURL(new URLRequest(url), '_blank');
			
			
		}
	}
}


	
	
