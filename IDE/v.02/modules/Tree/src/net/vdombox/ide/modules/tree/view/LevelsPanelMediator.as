package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Panel;
	
	public class LevelsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "LevelsPanelMediator";
		
		public function LevelsPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get levelsPanel() : Panel
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
			
			switch ( name )
			{
				case ApplicationFacade.SELECTED_APPLICATION_GETTED:
				{
					
					break;
				}
			}
		}
		
		private function addEventListeners() : void
		{
			
		}
		
		private function removeEventListeners() : void
		{
			
		}
	}
}