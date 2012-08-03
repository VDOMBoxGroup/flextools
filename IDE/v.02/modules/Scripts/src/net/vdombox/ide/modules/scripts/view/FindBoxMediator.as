package net.vdombox.ide.modules.scripts.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.FindBoxEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.scripts.model.GoToPositionProxy;
	import net.vdombox.ide.modules.scripts.view.components.FindBox;
	import net.vdombox.ide.modules.scripts.view.components.FindTreeItemRenderer;
	import net.vdombox.ide.modules.scripts.view.components.ScriptArea;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class FindBoxMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "FindBoxMediator";
		
		private var statesProxy : StatesProxy;
		private var goToDefenitionProxy : GoToPositionProxy;
		
		public function FindBoxMediator( viewComponent : ScriptArea )
		{
			super( NAME, viewComponent );
		}
		
		public function get scriptArea() : ScriptArea
		{
			return viewComponent as ScriptArea;
		}
		
		public function get findBox() : FindBox
		{
			return scriptArea.findBox;
		}
		
		private var selectedScriptAreaComponent : ScriptAreaComponent;
		private var selectedScriptEditor : ScriptEditor;
		
		private var pages : Array;
		
		private var findProgress : Boolean;
		private var pagesCountInput : int;
		
		private var pagesFindInput : int;
		
		private var pagesStructure : XMLList;
		
		override public function onRegister() : void
		{
			addHandlers();
			
			findProgress = false;
			pagesCountInput = 0;
			pagesFindInput = 0;
			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			goToDefenitionProxy = facade.retrieveProxy( GoToPositionProxy.NAME ) as GoToPositionProxy;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.OPEN_FIND_SCRIPT );
			interests.push( Notifications.OPEN_FIND_GLOBAL_SCRIPT );
			interests.push( Notifications.CHANGE_SELECTED_SCRIPT );
			
			interests.push( Notifications.PAGES_GETTED );
			interests.push( Notifications.ALL_SERVER_ACTIONS_GETTED );
			
			interests.push( Notifications.STRUCTURE_FOR_FIND_GETTED );
			interests.push( Notifications.LIBRARIES_GETTED_FOR_FIND );
			interests.push( Notifications.GLOBAL_ACTIONS_GETTED_FOR_FIND );
			
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			switch ( name )
			{
				case Notifications.OPEN_FIND_SCRIPT:
				{
					if ( scriptArea.currentState != "find" )
					{
						scriptArea.currentState = "find";
						
						if ( findBox.currentState == "global" )
							findBox.currentState = "find"
					}
					else
						findBox.findText.setFocus();
					
					break;
				}
					
				case Notifications.OPEN_FIND_GLOBAL_SCRIPT:
				{
					if ( scriptArea.currentState != "findG" )
					{
						scriptArea.currentState = "findG";
						findBox.currentState = "global"
					}
					else
						findBox.findText.setFocus();
					
					break;
				}
					
				case Notifications.CHANGE_SELECTED_SCRIPT:
				{
					selectedScriptEditor = body as ScriptEditor;
					
					if ( selectedScriptEditor.scriptEditor )
					{
						selectedScriptAreaComponent = selectedScriptEditor.scriptEditor.scriptAreaComponent;
						if ( findBox )
							findBox.selectedScriptAreaComponent = selectedScriptAreaComponent;
					}
					else
					{
						selectedScriptEditor.addEventListener( ScriptEditorEvent.SCRIPT_EDITOR_ADDED, setSelectedScriptAreaComponent, false, 0, true );
					}
					
					break;
				}
					
				case Notifications.PAGES_GETTED:
				{
					pages = body as Array;
					
					break;
				}
					
				case Notifications.ALL_SERVER_ACTIONS_GETTED:
				{
					
					findBox.findStringInServerActions( body );
					
					pagesCountInput++;
					
					if ( pagesCountInput == pages.length )
					{
						pagesFindInput = 0;
						pagesStructure = new XMLList();
						
						for each ( var pageVO : PageVO in findBox.containerPages )
						{
							sendNotification( Notifications.GET_STRUCTURE, { pageVO: pageVO, isFind : true } );
						}
						//findBox.findObjectsInStructure( pagesStructure );
					}
					
					/*serverScriptsPanel.scripts = body.serverActions as Array;
					
					
					if ( onloadScriptOpening != "" )
					{
						onloadScriptOpen( onloadScriptOpening );
						onloadScriptOpening = "";
					}*/
					break;
				}
					
				case Notifications.STRUCTURE_FOR_FIND_GETTED:
				{
					pagesStructure += body
					pagesFindInput++;
					if ( pagesFindInput == findBox.lengthContainerPages )
					{
						findBox.findObjectsInStructure( pagesStructure );
						sendNotification( Notifications.GET_LIBRARIES, { applicationVO : statesProxy.selectedApplication, isFind : true } );
					}
					
					break;
				}
					
				case Notifications.LIBRARIES_GETTED_FOR_FIND:
				{
					findBox.findStringInLibraries( body as Array, "Libraries" );
					
					sendNotification( Notifications.GET_SERVER_ACTIONS, { applicationVO : statesProxy.selectedApplication, isFind : true } );
					
					break;
				}
					
				case Notifications.GLOBAL_ACTIONS_GETTED_FOR_FIND:
				{
					findBox.findStringInLibraries( body.globalActions as Array, "Global actions" );
					
					break;
				}
					
			}
		}
		
		private function setSelectedScriptAreaComponent( event : ScriptEditorEvent ) : void
		{
			selectedScriptAreaComponent = selectedScriptEditor.scriptEditor.scriptAreaComponent;
			
			if ( findBox )
				findBox.selectedScriptAreaComponent = selectedScriptAreaComponent;
		}
		
		private function addHandlers() : void
		{
			scriptArea.addEventListener( FindBoxEvent.CREATION_COMPLETE, findBox_creationComplete, true, 0, true );
		}
		
		private function findBox_creationComplete( event : FindBoxEvent ) : void
		{
			findBox.selectedScriptAreaComponent = selectedScriptAreaComponent;
			
			findBox.addEventListener( FindBoxEvent.FIND_TEXT_IN_SELECTED_TYPE, findTextinSelectedTypeHandler, false, 0, true );
			findBox.addEventListener( FindBoxEvent.DOUBLE_CLICK, openScriptHandler, true, 0, true );
		}
		
		private function findTextinSelectedTypeHandler( event : FindBoxEvent ) : void
		{
			findProgress = true;
			pagesCountInput = 0;
			
			var pageVO : PageVO;
			for each ( pageVO in pages )
			{
				sendNotification( Notifications.GET_ALL_SERVER_ACTIONS, pageVO );
			}
			
			//sendNotification( Notifications.GET_PAGES_STRUCTURE );
		}
		
		private function openScriptHandler( event : FindBoxEvent ) : void
		{
			var findTreeCodeItemRenderer : FindTreeItemRenderer = event.target as FindTreeItemRenderer;
			
			var detail : XML = findTreeCodeItemRenderer.data as XML;
			
			var actionVO : Object = findBox.containerActions[ detail.@actionID ];
			
			if ( !actionVO )
				return;
			
			if ( actionVO is ServerActionVO )
			{
				if ( !findBox.containerPages[ actionVO ] )
				{
					var paveVO : PageVO = findBox.containerPages[ detail.@pageID ];
					var objectVO : ObjectVO = new ObjectVO( paveVO, null );
					objectVO.setID( actionVO.containerID );
					actionVO.containerVO = objectVO;
				}
				else
					actionVO.containerVO = findBox.containerPages[ actionVO ];
					
			}
			
			goToDefenitionProxy.add( actionVO, detail.@index, findBox.findText.text.length );
			
			sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : actionVO, check : false } );
		}
		
		
	}
}