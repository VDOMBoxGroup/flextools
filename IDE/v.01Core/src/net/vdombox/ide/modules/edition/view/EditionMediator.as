package net.vdombox.ide.modules.edition.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.Edition;
	import net.vdombox.ide.modules.edition.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class EditionMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "EditionMediator";

		public function EditionMediator( viewComponent : Edition )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			edition.addEventListener( ApplicationFacade.TEAR_DOWN, tearDownHandler )
		}

		private function get edition() : Edition
		{
			return viewComponent as Edition;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
