package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	import net.vdombox.ide.modules.tree.events.MenuPanelEvent;
	
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
			menuPanel.addEventListener( MenuPanelEvent.CREATE_PAGE, menuPanel_createPageHandler );
			menuPanel.addEventListener( MenuPanelEvent.AUTO_SPACING, menuPanel_autoSpacingHandler );
			menuPanel.addEventListener( MenuPanelEvent.EXPAND_ALL, menuPanel_expandAllHandler );
			menuPanel.addEventListener( MenuPanelEvent.SHOW_SIGNATURE, menuPanel_showSignatureHandler );
			menuPanel.addEventListener( MenuPanelEvent.UNDO, menuPanel_undoHandler );
			menuPanel.addEventListener( MenuPanelEvent.SAVE, menuPanel_saveHandler );
		}

		private function removeEventListeners() : void
		{
			menuPanel.removeEventListener( MenuPanelEvent.CREATE_PAGE, menuPanel_createPageHandler );
			menuPanel.removeEventListener( MenuPanelEvent.AUTO_SPACING, menuPanel_autoSpacingHandler );
			menuPanel.removeEventListener( MenuPanelEvent.EXPAND_ALL, menuPanel_expandAllHandler );
			menuPanel.removeEventListener( MenuPanelEvent.SHOW_SIGNATURE, menuPanel_showSignatureHandler );
			menuPanel.removeEventListener( MenuPanelEvent.UNDO, menuPanel_undoHandler );
			menuPanel.removeEventListener( MenuPanelEvent.SAVE, menuPanel_saveHandler );
		}

		private function menuPanel_createPageHandler( event : MenuPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.CREATE_PAGE_REQUEST );
		}

		private function menuPanel_autoSpacingHandler( event : MenuPanelEvent ) : void
		{

		}

		private function menuPanel_expandAllHandler( event : MenuPanelEvent ) : void
		{

		}

		private function menuPanel_showSignatureHandler( event : MenuPanelEvent ) : void
		{

		}

		private function menuPanel_undoHandler( event : MenuPanelEvent ) : void
		{

		}

		private function menuPanel_saveHandler( event : MenuPanelEvent ) : void
		{

		}
	}
}