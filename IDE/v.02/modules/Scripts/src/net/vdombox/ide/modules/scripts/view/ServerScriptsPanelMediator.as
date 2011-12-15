package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ServerScriptsPanelEvent;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
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

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		public function get serverScriptsPanel() : ServerScriptsPanel
		{
			return viewComponent as ServerScriptsPanel;
		}

		public function get serverScripts() : Array
		{	
			if( serverScriptsPanel && serverScriptsPanel.scripts )
				return serverScriptsPanel.scripts.slice();
			else
				return null;
		}
		
		override public function onRegister() : void
		{
			isActive = false;

			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			
			interests.push( ApplicationFacade.PAGES_GETTED );

			interests.push( ApplicationFacade.SELECTED_LIBRARY_CHANGED );

			interests.push( ApplicationFacade.SERVER_ACTIONS_GETTED );
			interests.push( ApplicationFacade.SERVER_ACTIONS_SETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;

			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( ApplicationFacade.GET_PAGES, sessionProxy.selectedApplication );

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );
					trace( "page" )
					
					break;
				}
					
				case ApplicationFacade.PAGES_GETTED:
				{
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );
					
					break;
				}
					
					 

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );
					trace( "object" );

					break;
				}

				case ApplicationFacade.SERVER_ACTIONS_GETTED:
				{
					serverScriptsPanel.scripts = body as Array;
				}
					
				case ApplicationFacade.SERVER_ACTIONS_SETTED:
				{
					serverScriptsPanel.scripts = body as Array;
					
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

		private function clearData() : void
		{
			serverScriptsPanel.scripts = null;
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

			var serverActions : Array = serverScriptsPanel.scripts;

			if ( !serverActions )
				return;

			serverActions = serverActions.slice();

			for ( var i : uint = 0; i < serverActions.length; i++ )
			{
				if ( serverActions[ i ].name == deletedServerActionVO.name )
				{
					serverActions.splice( i, 1 );
					break;
				}
			}
			
			if ( sessionProxy.selectedObject )
			{
				sendNotification( ApplicationFacade.SET_SERVER_ACTIONS, { objectVO: sessionProxy.selectedObject,
					serverActions: serverActions } );
			}
			else if ( sessionProxy.selectedPage )
			{
				sendNotification( ApplicationFacade.SET_SERVER_ACTIONS, { pageVO: sessionProxy.selectedPage, serverActions: serverActions } );
			}
		}

		private function selectedServerActionChangedHandler( event : ServerScriptsPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED, serverScriptsPanel.selectedScript );
		}
	}
}