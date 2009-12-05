package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.Wysiwyg;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WysiwygMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WysiwygMediator";

		public function WysiwygMediator( viewComponent : Wysiwyg )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			wysiwyg.addEventListener( Wysiwyg.TEAR_DOWN, tearDownHandler )
			
		}

		private function get wysiwyg() : Wysiwyg
		{
			return viewComponent as Wysiwyg;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
