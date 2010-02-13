package net.vdombox.ide.modules.scripts.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Panel;

	public class LibrariesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LibrariesPanelMediator";

		public function LibrariesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		public function get librariesPanel() : Panel
		{
			return viewComponent as Panel;
		}

		override public function onRegister() : void
		{
			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

//			interests.push( ApplicationFacade. );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

//			switch ( name )
//			{
//				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
//				{
//					
//					break;
//				}
//			}
		}

		private function addHandlers() : void
		{

		}

		private function removeHandlers() : void
		{

		}
	}
}