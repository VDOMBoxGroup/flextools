package net.vdombox.ide.modules.tree.view
{
	import mx.events.FlexEvent;

	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.components.CreatePageWindow;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class CreatePageWindowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "CreatePageWindowMediator";

		public function CreatePageWindowMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		public function get createPageWindow() : CreatePageWindow
		{
			return viewComponent as CreatePageWindow;
		}

		override public function onRegister() : void
		{
			addEventListeners();
		}

		override public function onRemove() : void
		{
			removeEventListeners();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.TOP_LEVEL_TYPES_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case ApplicationFacade.TOP_LEVEL_TYPES_GETTED:
				{

					break;
				}
			}
		}

		private function addEventListeners() : void
		{
			createPageWindow.addEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function removeEventListeners() : void
		{
			createPageWindow.removeEventListener( FlexEvent.CREATION_COMPLETE, creationCompleteHandler );
		}

		private function creationCompleteHandler( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_TOP_LEVEL_TYPES );
		}
	}
}