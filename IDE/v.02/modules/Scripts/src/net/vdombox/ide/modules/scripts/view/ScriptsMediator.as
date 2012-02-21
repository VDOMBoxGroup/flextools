package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.Scripts;
	import net.vdombox.ide.common.controller.Notifications;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ScriptsMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ScriptsMediator";

		public function ScriptsMediator( viewComponent : Scripts )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			scripts.addEventListener( Scripts.TEAR_DOWN, tearDownHandler )
		}

		public function get scripts() : Scripts
		{
			return viewComponent as Scripts;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( Notifications.TEAR_DOWN );
		}
	}
}
