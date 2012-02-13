package net.vdombox.ide.modules.scripts.view
{
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.windows.NameObjectWindow;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ServerScriptsPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.ServerScriptsPanel;
	import net.vdombox.utils.WindowManager;
	
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

		private var statesProxy : StatesProxy;

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

			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

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

			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );
			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );
			
			interests.push( ApplicationFacade.PAGES_GETTED );

			interests.push( ApplicationFacade.SELECTED_LIBRARY_CHANGED );

			interests.push( ApplicationFacade.SERVER_ACTIONS_GETTED );
			interests.push( ApplicationFacade.SERVER_ACTIONS_SETTED );
			
			interests.push( ApplicationFacade.OPEN_ONLOAD_SCRIPT );

			return interests;
		}
		
		private var onloadScriptOpening : String = "";

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
					if ( statesProxy.selectedApplication )
					{
						isActive = true;
						sendNotification( ApplicationFacade.GET_PAGES, statesProxy.selectedApplication );

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );
					
					break;
				}
					
				case ApplicationFacade.PAGES_GETTED:
				{
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );
					
					break;
				}
					
					 

				case StatesProxy.SELECTED_OBJECT_CHANGED:
				{
					sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_REQUEST );

					break;
				}

				case ApplicationFacade.SERVER_ACTIONS_GETTED:
				{
					serverScriptsPanel.scripts = body.serverActions as Array;
					if ( onloadScriptOpening != "" )
					{
						onloadScriptOpen( onloadScriptOpening );
						onloadScriptOpening = "";
					}
						
				}
					
				case ApplicationFacade.SERVER_ACTIONS_SETTED:
				{
					serverScriptsPanel.scripts = body.serverActions as Array;
					
					break;
				}

				case ApplicationFacade.SELECTED_LIBRARY_CHANGED:
				{
					if ( body )
						serverScriptsPanel.selectedScript = null;

					break;
				}
					
				case ApplicationFacade.OPEN_ONLOAD_SCRIPT:
				{
					onloadScriptOpen( body as String );
					
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
			var renameWindow : NameObjectWindow = new NameObjectWindow( "" );	
			renameWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
			renameWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );
			
			WindowManager.getInstance().addWindow(renameWindow, serverScriptsPanel.skin, true);
			
			function applyHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );
				
				sendNotification( ApplicationFacade.CREATE_SCRIPT_REQUEST, { name : event.name, target : ApplicationFacade.ACTION } );
				
			}
			
			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );
			}
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
			
			if ( statesProxy.selectedObject )
			{
				sendNotification( ApplicationFacade.SET_SERVER_ACTIONS, { objectVO: statesProxy.selectedObject,
					serverActions: serverActions } );
			}
			else if ( statesProxy.selectedPage )
			{
				sendNotification( ApplicationFacade.SET_SERVER_ACTIONS, { pageVO: statesProxy.selectedPage, serverActions: serverActions } );
			}
		}
		
		private function onloadScriptOpen( containerID : String ) : void
		{
			var serverActionVO : ServerActionVO;
			for each ( serverActionVO in serverScriptsPanel.scripts )
			{
				if ( serverActionVO.name == "onload" )
				{
					if ( serverActionVO.containerID == containerID )
					{
						onloadScriptOpening = "";
						sendNotification( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED, serverActionVO );
					}
					else
					{
						onloadScriptOpening = containerID;
					}
					break;
				}
			}
		}


		private function selectedServerActionChangedHandler( event : ServerScriptsPanelEvent ) : void
		{
			sendNotification( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED, serverScriptsPanel.selectedScript );
		}
	}
}