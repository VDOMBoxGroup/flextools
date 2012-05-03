package net.vdombox.ide.modules.scripts.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.ScriptAreaComponent;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.FindBoxEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.view.components.FindBox;
	import net.vdombox.ide.modules.scripts.view.components.ScriptArea;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class FindBoxMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "FindBoxMediator";
		
		private var statesProxy : StatesProxy;
		
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
		
		private var pagesStructure : XMLList;
		
		
		
		
		override public function onRegister() : void
		{
			addHandlers();
			
			findProgress = false;
			pagesCountInput = 0;
			
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
		}
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.OPEN_FIND_SCRIPT );
			interests.push( Notifications.CHANGE_SELECTED_SCRIPT );
			
			interests.push( Notifications.PAGES_GETTED );
			interests.push( Notifications.ALL_SERVER_ACTIONS_GETTED );
			
			interests.push( Notifications.PAGES_STRUCTURE_GETTED );
			
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
						scriptArea.currentState = "find";
					else
						findBox.findText.setFocus();
					
					break;
				}
					
				case Notifications.CHANGE_SELECTED_SCRIPT:
				{
					selectedScriptEditor = body as ScriptEditor;
					
					if ( selectedScriptEditor.pythonScriptEditor )
					{
						selectedScriptAreaComponent = selectedScriptEditor.pythonScriptEditor.scriptAreaComponent;
						if ( findBox )
							findBox.selectedScriptAreaComponent = selectedScriptAreaComponent;
					}
					else
					{
						selectedScriptEditor.addEventListener( FlexEvent.CREATION_COMPLETE, setSelectedScriptAreaComponent, false, 0, true );
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
					
					findBox.findStringInServerActions( body as Array );
					
					pagesCountInput++;
					
					if ( pagesCountInput == pages.length )
					{
						findBox.findObjectsInStructure( pagesStructure );
					}
					
					/*serverScriptsPanel.scripts = body.serverActions as Array;
					
					
					if ( onloadScriptOpening != "" )
					{
						onloadScriptOpen( onloadScriptOpening );
						onloadScriptOpening = "";
					}*/
					break;
				}
					
				case Notifications.PAGES_STRUCTURE_GETTED:
				{
					pagesStructure = body as XMLList;
					
					var pageVO : PageVO;
					for each ( pageVO in pages )
					{
						sendNotification( Notifications.GET_ALL_SERVER_ACTIONS, pageVO );
					}
					
					break;
				}
					
			}
		}
		
		private function setSelectedScriptAreaComponent( event : FlexEvent ) : void
		{
			selectedScriptAreaComponent = selectedScriptEditor.pythonScriptEditor.scriptAreaComponent;
			
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
		}
		
		private function findTextinSelectedTypeHandler( event : FindBoxEvent ) : void
		{
			findProgress = true;
			pagesCountInput = 0;
			
			sendNotification( Notifications.GET_PAGES_STRUCTURE );
		}
		
		
	}
}