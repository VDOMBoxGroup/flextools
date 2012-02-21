package net.vdombox.ide.modules.resourceBrowser.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.ResourceBrowser;
	import net.vdombox.ide.common.controller.Notifications;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ResourceBrowserMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ResourceBrowserMediator";

		public function ResourceBrowserMediator( vObject : ResourceBrowser )
		{
			trace("ResourceBrowserMediator");
			super( NAME, vObject );
		}

		override public function onRegister() : void
		{
			resourceBrowser.addEventListener( ResourceBrowser.TEAR_DOWN, tearDownHandler )
			
		}

		public function get resourceBrowser() : ResourceBrowser
		{
			return viewComponent as ResourceBrowser;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( Notifications.TEAR_DOWN );
		}
	}
}
