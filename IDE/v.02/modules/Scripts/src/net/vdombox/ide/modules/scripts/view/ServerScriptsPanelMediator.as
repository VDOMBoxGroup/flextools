package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
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

		public var selectedPageVO : PageVO;

		public var selectedObjectVO : ObjectVO;

		public var serverActions : Array;

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
			interests.push( ApplicationFacade.SELECTED_LIBRARY_CHANGED );

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
					serverActions = body as Array;

					serverScriptsPanel.scripts = serverActions;

					break;
				}

				case ApplicationFacade.SELECTED_LIBRARY_CHANGED:
				{
					if ( body )
						serverScriptsPanel.selectedScript = null;

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			serverScriptsPanel.addEventListener( ServerScriptsPanelEvent.CREATE_ACTION, createActionHandler,
												 false, 0, true );
			serverScriptsPanel.addEventListener( ServerScriptsPanelEvent.DELETE_ACTION, deleteActionHandler,
												 false, 0, true );
			serverScriptsPanel.addEventListener( ServerScriptsPanelEvent.SELECTED_SERVER_ACTION_CHANGED,
												 selectedServerActionChangedHandler, false, 0, true );
		}

		private function removeHandlers() : void
		{
			serverScriptsPanel.removeEventListener( ServerScriptsPanelEvent.CREATE_ACTION, createActionHandler );
			serverScriptsPanel.removeEventListener( ServerScriptsPanelEvent.DELETE_ACTION, deleteActionHandler );
			serverScriptsPanel.removeEventListener( ServerScriptsPanelEvent.SELECTED_SERVER_ACTION_CHANGED,
													selectedServerActionChangedHandler );
		}

		private function createActionHandler( event : ServerScriptsPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.OPEN_CREATE_ACTION_WINDOW, ApplicationFacade.ACTION );
		}

		private function deleteActionHandler( event : ServerScriptsPanelEvent ) : void
		{
			var deletedServerActionVO : ServerActionVO = serverScriptsPanel.selectedScript;

			if ( !deletedServerActionVO )
				return;

			for ( var i : uint = 0; i < serverActions.length; i++ )
			{
				if ( serverActions[ i ].name == deletedServerActionVO.name )
				{
					serverActions.splice( i, 1 );
					break;
				}
			}

			if ( selectedObjectVO )
			{
				sendNotification( ApplicationFacade.SET_SERVER_ACTIONS, { objectVO: selectedObjectVO,
									  serverActions: serverActions } );
			}
			else if ( selectedPageVO )
			{
				sendNotification( ApplicationFacade.SET_SERVER_ACTIONS, { pageVO: selectedPageVO, serverActions: serverActions } );
			}

		}

		private function selectedServerActionChangedHandler( event : ServerScriptsPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED, serverScriptsPanel.selectedScript );
		}
	}
}