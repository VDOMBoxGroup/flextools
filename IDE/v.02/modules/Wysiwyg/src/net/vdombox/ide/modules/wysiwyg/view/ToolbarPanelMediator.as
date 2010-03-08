package net.vdombox.ide.modules.wysiwyg.view
{
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.components.ToolbarPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ToolbarPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ToolbarPanelMediator";
		
		public function ToolbarPanelMediator( viewComponent : ToolbarPanel )
		{
			super( NAME, viewComponent );
		}
		
		public function get toolbarPanel() : ToolbarPanel
		{
			return viewComponent as ToolbarPanel;
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
			
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
//			switch ( name )
//			{
//				case ApplicationFacade.it:
//				{
//					var d : * = "";					
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