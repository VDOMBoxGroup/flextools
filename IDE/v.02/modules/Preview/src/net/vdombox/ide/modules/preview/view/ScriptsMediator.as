package net.vdombox.ide.modules.preview.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.Preview2;
	import net.vdombox.ide.modules.preview.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ScriptsMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ScriptsMediator";

		public function ScriptsMediator( viewComponent : Preview2 )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			scripts.addEventListener( Preview2.TEAR_DOWN, tearDownHandler )
		}

		public function get scripts() : Preview2
		{
			return viewComponent as Preview2;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
