package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.modules.tree.events.MenuPanelEvent;
	import net.vdombox.ide.modules.tree.model.StatesProxy;
	
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

		private var statesProxy : StatesProxy;
		
		private var isActive : Boolean;
		
		private var isExpand : Boolean;
		
		public function get menuPanel() : Panel
		{
			return viewComponent as Panel;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			
			isActive = false;
			
			addHandlers();
			
			isExpand = true;
		}

		override public function onRemove() : void
		{
			removeHandlers();
			
			clearData();
			
			isExpand = true;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

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
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						
						break;
					}
				}
					
				case Notifications.BODY_STOP:
				{
					isActive = false;
					
					clearData();
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			menuPanel.addEventListener( MenuPanelEvent.CREATE_PAGE, menuPanel_createPageHandler );
			menuPanel.addEventListener( MenuPanelEvent.AUTO_SPACING, menuPanel_autoSpacingHandler );
			menuPanel.addEventListener( MenuPanelEvent.EXPAND_ALL, menuPanel_expandAllHandler );
			menuPanel.addEventListener( MenuPanelEvent.SHOW_SIGNATURE, menuPanel_showSignatureHandler );
			menuPanel.addEventListener( MenuPanelEvent.UNDO, menuPanel_undoHandler );
			menuPanel.addEventListener( MenuPanelEvent.SAVE, menuPanel_saveHandler );
		}

		private function removeHandlers() : void
		{
			menuPanel.removeEventListener( MenuPanelEvent.CREATE_PAGE, menuPanel_createPageHandler );
			menuPanel.removeEventListener( MenuPanelEvent.AUTO_SPACING, menuPanel_autoSpacingHandler );
			menuPanel.removeEventListener( MenuPanelEvent.EXPAND_ALL, menuPanel_expandAllHandler );
			menuPanel.removeEventListener( MenuPanelEvent.SHOW_SIGNATURE, menuPanel_showSignatureHandler );
			menuPanel.removeEventListener( MenuPanelEvent.UNDO, menuPanel_undoHandler );
			menuPanel.removeEventListener( MenuPanelEvent.SAVE, menuPanel_saveHandler );
		}

		private function clearData() : void
		{
		}
		
		private function menuPanel_createPageHandler( event : MenuPanelEvent ) : void
		{
			sendNotification( Notifications.OPEN_CREATE_PAGE_WINDOW_REQUEST, menuPanel );
		}

		private function menuPanel_autoSpacingHandler( event : MenuPanelEvent ) : void
		{
			sendNotification( Notifications.AUTO_SPACING_REQUEST );
		}

		private function menuPanel_expandAllHandler( event : MenuPanelEvent ) : void
		{
			sendNotification( Notifications.EXPAND_ALL_REQUEST, isExpand );
			isExpand = !isExpand;
		}

		private function menuPanel_showSignatureHandler( event : MenuPanelEvent ) : void
		{
			sendNotification( Notifications.SHOW_SIGNATURE_REQUEST );
		}

		private function menuPanel_undoHandler( event : MenuPanelEvent ) : void
		{

		}

		private function menuPanel_saveHandler( event : MenuPanelEvent ) : void
		{
			sendNotification( Notifications.SAVE_REQUEST );
		}
	}
}