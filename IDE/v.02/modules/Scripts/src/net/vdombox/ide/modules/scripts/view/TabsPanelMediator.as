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
			
			interests.push( Notifications.SERVER_ACTION_GETTED );
			interests.push( Notifications.LIBRARY_GETTED );
			interests.push( Notifications.GLOBAL_ACTION_GETTED );
			
			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED );
			
			interests.push( Notifications.OBJECT_DELETED );
			
			interests.push( Notifications.LIBRARY_DELETED );
			interests.push( Notifications.DELETE_TAB_BY_ACTIONVO );
			
			interests.push( Notifications.SERVER_ACTION_RENAMED );
			
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
					
					if ( tabsPanel.checkTabs( statesProxy.selectedApplication.id ) )
						sendNotification( Notifications.ALL_TABS_DELETED );
					
					break;
				}
					
				case Notifications.BODY_STOP:
				{
					
					isActive = false;
					
					
					break;
				}
					
				case Notifications.SERVER_ACTION_GETTED:
				{
				}
					
				case Notifications.LIBRARY_GETTED:
				{
				}
					
				case Notifications.GLOBAL_ACTION_GETTED:
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
					
					
					
				case StatesProxy.SELECTED_APPLICATION_CHANGED:
				{
					tabsPanel.removeAll();
				}	
					
				case Notifications.OBJECT_DELETED:
				{
					break;
				}
					
				case Notifications.LIBRARY_DELETED:
				{
					
				}
					
				case Notifications.DELETE_TAB_BY_ACTIONVO:
				{
					tabsPanel.RemoveAction( body );
					
					break;
				}
					
				case Notifications.SERVER_ACTION_RENAMED:
				{
					var actionID : String = body.serverActionID as String;
					var newName  :String = body.newName as String;
					
					tabsPanel.renameAction( actionID, newName );
					
					break;
				}
					
			}
		}
		
		private function addHandlers() : void
		{
			tabsPanel.addEventListener( TabsPanelEvent.SELECTED_TAB_CHANGED, selectedTabHandler, false, 0 , true );
			tabsPanel.addEventListener( TabsPanelEvent.TAB_DELETE, tabDeleteHandler, false, 0 , true );
		}
		
		private function removeHandlers() : void
		{
			tabsPanel.removeEventListener( TabsPanelEvent.SELECTED_TAB_CHANGED, selectedTabHandler );
			tabsPanel.removeEventListener( TabsPanelEvent.TAB_DELETE, tabDeleteHandler );
		}
		
		private function selectedTabHandler( event : TabsPanelEvent ) : void
		{
			sendNotification( Notifications.SELECTED_TAB_CHANGED, tabsPanel.tabs.selectedItem );
		}
		
		private function tabDeleteHandler( event : TabsPanelEvent ) : void
		{
			sendNotification( Notifications.DELETE_TAB, { actionVO : event.tab, askBeforeRemove : true } );
		}
	}
}