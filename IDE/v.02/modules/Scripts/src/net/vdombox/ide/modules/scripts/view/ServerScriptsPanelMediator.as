package net.vdombox.ide.modules.scripts.view
{
	import mx.resources.ResourceManager;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.windows.NameObjectWindow;
	import net.vdombox.ide.modules.scripts.events.ListItemRendererEvent;
	import net.vdombox.ide.modules.scripts.events.ServerScriptsPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.ListItemRenderer;
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

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );
			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );
			
			interests.push( Notifications.PAGES_GETTED );

			interests.push( Notifications.LIBRARY_GETTED );

			interests.push( Notifications.SERVER_ACTIONS_GETTED );
			interests.push( Notifications.SERVER_ACTIONS_SETTED );
			
			interests.push( Notifications.OPEN_ONLOAD_SCRIPT );
				
			interests.push( Notifications.SERVER_ACTION_CREATED );
			interests.push( Notifications.SERVER_ACTION_DELETED );

			return interests;
		}
		
		private var onloadScriptOpening : String = "";

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

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					
					if ( statesProxy.selectedPage  )
						sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedPage );
					else
						clearData();
					
					break;
				}
					
				case Notifications.PAGES_GETTED:
				{					
					if ( statesProxy.selectedObject )
					{
						onloadScriptOpening = statesProxy.selectedObject.id;
						sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedObject );
					}
					else if ( statesProxy.selectedPage )
					{
						onloadScriptOpening = statesProxy.selectedPage.id;
						sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedPage );
					}
					else
						clearData();
					
					break;
				}
					
					 

				case StatesProxy.SELECTED_OBJECT_CHANGED:
				{
					if ( statesProxy.selectedObject )
						sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedObject );
					else if ( statesProxy.selectedPage )
						sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedPage );
					else
						clearData();
					
					break;
				}

				case Notifications.SERVER_ACTIONS_GETTED:
				{
					serverScriptsPanel.scripts = body.serverActions as Array;
					
					
					if ( onloadScriptOpening != "" )
					{
						onloadScriptOpen( onloadScriptOpening );
						onloadScriptOpening = "";
					}
					
					break;
						
				}
					
				case Notifications.SERVER_ACTIONS_SETTED:
				{
					serverScriptsPanel.scripts = body.serverActions as Array;
					
					break;
				}

				case Notifications.LIBRARY_GETTED:
				{
					if ( body )
						serverScriptsPanel.selectedScript = null;

					break;
				}
					
				case Notifications.OPEN_ONLOAD_SCRIPT:
				{
					onloadScriptOpen( body as String );
					
					break;
				}
					
				case Notifications.SERVER_ACTION_CREATED:
				{
					if ( !serverScriptsPanel.scripts ) 
					{
						var arr : Array = new Array();
						arr.push( body.serverActionVO);
						serverScriptsPanel.scripts = arr;
					}
					else
					{
						serverScriptsPanel.scripts.push( body.serverActionVO );
						serverScriptsPanel.scripts = serverScriptsPanel.scripts;
						
					}
					
					break;
				}
					
				case Notifications.SERVER_ACTION_DELETED:
				{
					var action : ServerActionVO = body.serverActionVO as ServerActionVO;
					var i : int;
					var count : int = serverScriptsPanel.scripts.length;
					for( i = 0; i < count; i++ )
					{
						if ( serverScriptsPanel.scripts[i] == action )
						{
							serverScriptsPanel.scripts.splice( i, 1 );
							serverScriptsPanel.scripts = serverScriptsPanel.scripts;
							
							break;
						}
					}
					
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
			
			serverScriptsPanel.addEventListener( ListItemRendererEvent.NAME_CHANGE,
				serverActionNameChangeHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			serverScriptsPanel.removeEventListener( ServerScriptsPanelEvent.CREATE_ACTION, createActionHandler );
			serverScriptsPanel.removeEventListener( ServerScriptsPanelEvent.DELETE_ACTION, deleteActionHandler );
			serverScriptsPanel.removeEventListener( ServerScriptsPanelEvent.SELECTED_SERVER_ACTION_CHANGED,
				selectedServerActionChangedHandler );
			
			serverScriptsPanel.removeEventListener( ListItemRendererEvent.NAME_CHANGE,
				serverActionNameChangeHandler );
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
				
				sendNotification( Notifications.CREATE_SCRIPT_REQUEST, { name : event.name, target : Notifications.ACTION } );
				
			}
			
			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );
			}
		}

		private function deleteActionHandler( event : ServerScriptsPanelEvent ) : void
		{
			var deletedServerActionVO : ServerActionVO = event.object as ServerActionVO;

			if ( !deletedServerActionVO )
				return;
			
			if ( statesProxy.selectedObject )
			{
				sendNotification( Notifications.DELETE_SERVER_ACTION, { objectVO: statesProxy.selectedObject,
					serverActionVO: deletedServerActionVO } );
			}
			else if ( statesProxy.selectedPage )
			{
				sendNotification( Notifications.DELETE_SERVER_ACTION, { pageVO: statesProxy.selectedPage, serverActionVO: deletedServerActionVO } );
			}
			
			sendNotification( Notifications.DELETE_TAB, { actionVO : deletedServerActionVO, askBeforeRemove : false });
			
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
						sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : serverActionVO, check : false } );
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
			if ( serverScriptsPanel.selectedScript )
				sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : serverScriptsPanel.selectedScript, check : false } );
		}
		
		private function serverActionNameChangeHandler( event : ListItemRendererEvent ) : void
		{
			var action : ServerActionVO =  ListItemRenderer(event.target).data as ServerActionVO;
			if ( statesProxy.selectedObject )  
				sendNotification( Notifications.RENAME_SERVER_ACTION, { objectVO : statesProxy.selectedObject, serverActionVO : action, newName : event.object } );
			else if ( statesProxy.selectedPage )  
				sendNotification( Notifications.RENAME_SERVER_ACTION, { pageVO : statesProxy.selectedPage, serverActionVO : action, newName : event.object } );
			}
		
		
	}
}