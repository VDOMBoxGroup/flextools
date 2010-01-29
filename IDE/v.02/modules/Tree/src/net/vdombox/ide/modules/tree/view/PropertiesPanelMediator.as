package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.view.components.Properties;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class PropertiesPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "PropertiesPanelMediator";
		
		public function PropertiesPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		private var selectedPageVO : PageVO;
		private var typeVO : TypeVO;
		
		public function get propertiesPanel() : Properties
		{
			return viewComponent as Properties;
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
			
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.PAGE_ATTRIBUTES_GETTED );
			
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
					selectedPageVO = notification.getBody().pageVO as PageVO;
					typeVO = notification.getBody().typeVO as TypeVO;
					
					if ( selectedPageVO )
						sendNotification( ApplicationFacade.GET_PAGE_ATTRIBUTES, selectedPageVO );
					
					break;
				}
					
				case ApplicationFacade.PAGE_ATTRIBUTES_GETTED:
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