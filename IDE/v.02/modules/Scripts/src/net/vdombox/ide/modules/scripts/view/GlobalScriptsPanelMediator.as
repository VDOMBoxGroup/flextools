package net.vdombox.ide.modules.scripts.view
{
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.modules.scripts.events.GlobalScriptsPanelEvent;
	import net.vdombox.ide.modules.scripts.view.components.GlobalScriptsPanel;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class GlobalScriptsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "GlobalScriptsPanelMediator";
		
		public function GlobalScriptsPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		private var statesProxy : StatesProxy;
		
		private var isActive : Boolean;
		
		private var _globalActions : Object;
		
		public function get globalScriptsPanel() : GlobalScriptsPanel
		{
			return viewComponent as GlobalScriptsPanel;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			interests.push( Notifications.GLOBAL_ACTIONS_GETTED );
			
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
						globalScriptsPanel.actions = null;
						_globalActions = new Object();
						sendNotification( Notifications.GET_SERVER_ACTIONS, statesProxy.selectedApplication );
						
						break;
					}
				}
					
				case Notifications.BODY_STOP:
				{
					globalScriptsPanel.actions = null;
					_globalActions = new Object();
					
					isActive = false;
					
					break;
				}
					
				case Notifications.GLOBAL_ACTIONS_GETTED:
				{
					
					var serverActionsXML : XML = body.serverActionsXML as XML;
					var _applicationVO : ApplicationVO = body.applicationVO as ApplicationVO;
					//globalScriptsPanel.actions
					
					var pagesXMLList : XMLList = globalScriptsPanel.actions;
					if ( !pagesXMLList )
						pagesXMLList = new XMLList();
					
					var groupName : String = serverActionsXML.ServerActions.Container.@ID;
					
					pagesXMLList += <page Name={groupName} />;
					pagesXMLList.children();
					
					globalScriptsPanel.actions = pagesXMLList;
					
					var _action : XML;
					
					var _actions : XMLList = serverActionsXML.ServerActions.Container..Action;
					var _actionsXML : XMLList = new XMLList();
					
					var _globalAction : GlobalActionVO;
						
					for each( _action in _actions )
					{
						_actionsXML += < Action id={_action.@ID} Name={_action.@Name} parent={groupName}/>
						_globalAction = new GlobalActionVO( _action.@ID, groupName, _applicationVO );
						_globalAction.script = _action[ 0 ];
						_globalActions[ _action.@ID ] = _globalAction;
					}
					
					
					var pageXML : XML = globalScriptsPanel.actions.( @Name == groupName )[ 0 ];
					pageXML.setChildren( new XMLList() ); //TODO: strange construction
					pageXML.appendChild( _actionsXML );
					break;
					
				}
					
			}
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
		}
		
		private function addHandlers() : void
		{
			globalScriptsPanel.addEventListener( GlobalScriptsPanelEvent.SCRIPTS_CHANGE, selectedGlobalScriptChangedHandler, false, 0, true);
		}
		
		private function removeHandlers() : void
		{
			
		}
		
		private function selectedGlobalScriptChangedHandler( event : GlobalScriptsPanelEvent ) : void
		{
			var _globalScript : GlobalActionVO = _globalActions[ globalScriptsPanel.selectedScript.@id ];
			if ( _globalScript )
				sendNotification( Notifications.SELECTED_GLOBAL_ACTION_CHANGED, _globalScript );
		}
	}
}