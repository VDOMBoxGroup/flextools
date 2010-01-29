package net.vdombox.ide.modules.tree.view
{
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Panel;
	
	public class MenuPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "MenuPanelMediator";
		
		public function MenuPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get menuPanel() : Panel
		{
			return viewComponent as Panel;
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
		
		private function addEventListeners() : void
		{
			
		}
		
		private function removeEventListeners() : void
		{
			
		}
	}
}