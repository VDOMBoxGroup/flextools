package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ServerScriptsPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.ServerScriptsPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class ServerScriptsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ServerScriptsPanelMediator";

		public function ServerScriptsPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var selectedPageVO : PageVO;

		private var selectedObjectVO : ObjectVO;

		public function get serverScriptsPanel() : ServerScriptsPanel
		{
			return viewComponent as ServerScriptsPanel;
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

			interests.push( ApplicationFacade.SERVER_ACTIONS_GETTED );

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

					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					selectedObjectVO = body as ObjectVO;

					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );

					break;
				}

				case ApplicationFacade.SERVER_ACTIONS_GETTED:
				{
					serverScriptsPanel.scripts = body as Array;

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			serverScriptsPanel.addEventListener( ServerScriptsPanelEvent.SELECTED_SERVER_ACTION_CHANGED,
												 selectedServerActionChangedHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			serverScriptsPanel.removeEventListener( ServerScriptsPanelEvent.SELECTED_SERVER_ACTION_CHANGED,
													selectedServerActionChangedHandler );
		}

		private function selectedServerActionChangedHandler( event : ServerScriptsPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED, serverScriptsPanel.selectedScript );
		}
	}
}