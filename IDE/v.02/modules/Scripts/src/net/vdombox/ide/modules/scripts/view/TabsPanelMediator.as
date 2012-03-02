package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.events.TabsPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.TabsPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TabsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TabsPanelMediator";
		
		private var statesProxy : StatesProxy;
		
		public function TabsPanelMediator(viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		private function get tabsPanel() : TabsPanel
		{
			return viewComponent as TabsPanel;
		}
		
		private var isActive : Boolean;
		
		override public function onRegister() : void
		{
			isActive = false;
			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			addHandlers();
		}
		
		override public function onRemove() : void
		{
			removeHandlers();
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			interests.push( Notifications.SELECTED_SERVER_ACTION_CHANGED );
			interests.push( Notifications.SELECTED_LIBRARY_CHANGED );
			interests.push( Notifications.SELECTED_GLOBAL_ACTION_CHANGED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			if ( !isActive && name != Notifications.BODY_START )
				return;
			
			switch ( name )
			{
				case Notifications.BODY_START:
				{
					isActive = true;
					
					break;
				}
					
				case Notifications.BODY_STOP:
				{
					isActive = false;
					
					break;
				}
					
				case Notifications.SELECTED_SERVER_ACTION_CHANGED:
				{
				}
					
				case Notifications.SELECTED_LIBRARY_CHANGED:
				{
				}
					
				case Notifications.SELECTED_GLOBAL_ACTION_CHANGED:
				{
					if ( body is ServerActionVO )
					{
						if ( statesProxy.selectedObject )
							body.containerVO = statesProxy.selectedObject;
						else if ( statesProxy.selectedPage )
							body.containerVO = statesProxy.selectedPage;	
					}
					
					tabsPanel.addAction( body );
					
					break;
				}
					
			}
		}
		
		private function addHandlers() : void
		{
			tabsPanel.addEventListener( TabsPanelEvent.SELECTED_TAB_CHANGED, selectedTabHandler, false, 0 , true );
		}
		
		private function removeHandlers() : void
		{
			tabsPanel.removeEventListener( TabsPanelEvent.SELECTED_TAB_CHANGED, selectedTabHandler );
		}
		
		private function selectedTabHandler( event : TabsPanelEvent ) : void
		{
			sendNotification( Notifications.SELECTED_TAB_CHANGED, tabsPanel.tabs.selectedItem );
		}
	}
}