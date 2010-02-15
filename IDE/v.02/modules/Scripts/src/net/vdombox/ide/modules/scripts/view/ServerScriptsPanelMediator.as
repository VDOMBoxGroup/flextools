package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Panel;
	
	public class ServerScriptsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ServerScriptsPanelMediator";
		
		public function ServerScriptsPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		private var selectedPageVO : PageVO;
		private var selectedObjectVO : ObjectVO;
		
		public function get serverScriptsPanel() : Panel
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
			
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			switch ( name )
			{
				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					selectedPageVO = body as PageVO;
					
					break;
				}
					
				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					selectedObjectVO = body as ObjectVO;
					
					break;
				}
			}
		}
		
		private function addHandlers() : void
		{
			
		}
		
		private function removeHandlers() : void
		{
			
		}
	}
}