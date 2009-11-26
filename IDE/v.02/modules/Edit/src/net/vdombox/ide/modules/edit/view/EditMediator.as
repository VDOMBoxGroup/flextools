package net.vdombox.ide.modules.edit.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.Edit;
	import net.vdombox.ide.modules.edit.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class EditMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "EditMediator";

		public function EditMediator( viewComponent : Edit )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			edit.addEventListener( Edit.TEAR_DOWN, tearDownHandler )
			
		}

		private function get edit() : Edit
		{
			return viewComponent as Edit;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
