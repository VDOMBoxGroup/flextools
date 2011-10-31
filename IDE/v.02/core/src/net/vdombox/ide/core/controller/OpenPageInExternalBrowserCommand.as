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

			if ( !canCreateURL )
				return

			navigateToURL( new URLRequest( URL ), '_blank' );
		}

		private function get canCreateURL() : Boolean
		{
			return statesProxy.selectedApplication && statesProxy.selectedPage
		}

		private function get statesProxy() : StatesProxy
		{
			return facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}

		private function get serverProxy() : ServerProxy
		{
			return facade.retrieveProxy( ServerProxy.NAME ) as ServerProxy;
		}

		private function get URL() : String
		{
			return "http://" + serverProxy.server + "/" + statesProxy.selectedApplication.id + "/" + statesProxy.selectedPage.id;
		}
	}
}




