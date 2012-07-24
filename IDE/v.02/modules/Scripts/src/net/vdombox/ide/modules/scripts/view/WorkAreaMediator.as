package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import net.vdombox.editors.PythonScriptEditor;
	import net.vdombox.editors.VScriptEditor;
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.EditorEvent;
	import net.vdombox.ide.common.events.TabEvent;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.events.ScriptEditorEvent;
	import net.vdombox.ide.modules.scripts.model.GoToPositionProxy;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	import net.vdombox.ide.modules.scripts.view.components.WorkArea;
	import net.vdombox.utils.StringUtils;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";
		
		private var isActive : Boolean;
		
		private var serverActionVO : ServerActionVO;
		private var libraryVO : LibraryVO;
		private var globalActionVO : GlobalActionVO;
		private var statesProxy : StatesProxy;

		private var closedScript : Boolean = false;
		
		private var goToDefenitionProxy : GoToPositionProxy;
		
		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}
		
		override public function onRegister() : void
		{
			addHandlers();
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			goToDefenitionProxy = facade.retrieveProxy( GoToPositionProxy.NAME ) as GoToPositionProxy;
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
			interests.push( Notifications.LIBRARY_GETTED );
			interests.push( Notifications.SERVER_ACTION_GETTED );
			interests.push( Notifications.GLOBAL_ACTION_GETTED );

			interests.push( Notifications.SCRIPT_CHECKED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			//var objectVO : ObjectVO;
			var editor : ScriptEditor;
			
			if ( !isActive && name != Notifications.BODY_START )
				return;
			
			
			
			switch ( name )
			{
				case Notifications.BODY_START:
				{
					isActive = true;
					
					break;
				}
					
				case Notifications.BODY_STOP:
				{
					isActive = false;
					
					break;
				}
					
				case Notifications.SERVER_ACTION_GETTED:
				{
					serverActionVO = body as ServerActionVO;
					
					if ( statesProxy.selectedObject )
						serverActionVO.containerVO = statesProxy.selectedObject;
					else if ( statesProxy.selectedPage )
						serverActionVO.containerVO = statesProxy.selectedPage;	
					
					OpenAndFindEditor( serverActionVO );
					break;
				}
					
				case Notifications.LIBRARY_GETTED:
				{
					libraryVO = body as LibraryVO
					OpenAndFindEditor( libraryVO );
					
					break;
				}
					
				case Notifications.GLOBAL_ACTION_GETTED:
				{
					globalActionVO = body as GlobalActionVO;
					OpenAndFindEditor( globalActionVO );
					
					
					break;
				}

				case Notifications.SCRIPT_CHECKED:
				{
					var actionVO : Object = body;
					editor = workArea.getEditorByVO( actionVO );
					var editorScript : String = editor.actionVO.script.replace( /\r/g, "\n" );
					var index : int = editorScript.indexOf( "]]]]><![CDATA[>" );
					while ( index != -1 )
					{
						editorScript = editorScript.slice( 0, index + 2 ) + editorScript.slice( index + 14) ;
						index = editorScript.indexOf( "]]]]><![CDATA[>" );
					}
					
					if ( actionVO.script == editorScript )
					{
						var script : String = editor.script;
						script = StringUtils.getCDataParserString( script );
						while ( script.slice( script.length - 1 ) == "\r" || script.slice( script.length - 1 ) == " " || script.slice( script.length - 1 ) == "\t" )
							script = script.slice( 0, script.length - 1);
						
						editor.actionVO.script = script;
						sendNotification( Notifications.SAVE_SCRIPT_REQUEST, editor.actionVO );
						
						if ( closedScript )
						{
							closedScript = false;
							workArea.closeTabByAction( actionVO );
							sendNotification( Notifications.DELETE_TAB_BY_ACTIONVO, actionVO );
						}
					}
					else
					{
						Alert.setPatametrs( "Save", "Load" );
						Alert.Show(	"Server action 'Maks' has been modified on the server and is in the conflict with your changes.\nDo you want to load from server or save your modification?", AlertButton.OK_No_Cancel, workArea.parentApplication, saveActionRequest );
					}
					
					break;
				}
					
			}

			function saveActionRequest( event : CloseEvent ) : void 
			{
				if ( event.detail == Alert.NO )
				{
					editor.script = actionVO.script;
					editor.actionVO = actionVO;
				}
				
				if ( event.detail == Alert.YES )
				{
					var script : String = editor.script;
					script = script.replace(/]]>/g, "]]]]><![CDATA[>");
					while ( script.slice( script.length - 1 ) == "\r" || script.slice( script.length - 1 ) == " " || script.slice( script.length - 1 ) == "\t" )
						script = script.slice( 0, script.length - 1);
					
					editor.actionVO.script = script;
					sendNotification( Notifications.SAVE_SCRIPT_REQUEST, editor.actionVO );
				}
			}
		}
		
		private function OpenAndFindEditor( objectVO : Object ) : void
		{
			var editor : ScriptEditor;
			if ( objectVO ) 
			{
				editor = workArea.getEditorByVO( objectVO ) as ScriptEditor;
				if ( !editor )
				{
					if ( statesProxy.selectedObject )
						editor = workArea.openEditor( statesProxy.selectedObject, objectVO ) as ScriptEditor;
					else
						editor = workArea.openEditor( statesProxy.selectedPage, objectVO ) as ScriptEditor;
					
					if ( facade.retrieveMediator( ScriptEditorMediator.NAME + editor.editorID ) != null )
						facade.removeMediator( ScriptEditorMediator.NAME + editor.editorID  );
					
					editor.addEventListener( FlexEvent.CREATION_COMPLETE, setMediator, false, 0 , true );
				}
				else
				{
					workArea.selectedEditor = editor;
					goToPos( editor );
				}
			}
		
			sendNotification( Notifications.CHANGE_SELECTED_SCRIPT, editor );

		}

		private function setMediator( event : FlexEvent ) : void
		{			
			var editor : ScriptEditor = event.target as ScriptEditor;
			
			switch(statesProxy.selectedApplication.scriptingLanguage)
			{
				case "vscript":
				{
					editor.scriptEditor = new VScriptEditor();
					break;
				}
					
				default:
				{
					editor.scriptEditor = new PythonScriptEditor();
					break;
				}
			}
			
			editor.addScriptEditor();
			
			editor.scriptEditor.scriptAreaComponent.scriptLang = statesProxy.selectedApplication.scriptingLanguage;
			
			facade.registerMediator( new ScriptEditorMediator( editor ) );
			editor.enabled = true;
			
			editor.script = editor.actionVO.script;
			
			goToPos( editor );
			
			editor.scriptEditor.scriptAreaComponent.setFocus();
		}
		
		private function goToPos( editor : ScriptEditor ) : void
		{
			var detail : Object = goToDefenitionProxy.getPosition( editor.actionVO );
			if ( detail && editor.script.length > detail.position )
			{
				editor.scriptEditor.scriptAreaComponent.goToPos( detail.position, detail.length );
			}
		}
		
		private function addHandlers() : void
		{
			workArea.addEventListener( EditorEvent.REMOVED, editor_removedHandler, true, 0, true );
			workArea.addEventListener( WorkAreaEvent.CHANGE, changeHandler, false, 0, true );
			workArea.addEventListener( TabEvent.ELEMENT_REMOVE, removeTabHandler, false, 0, true );
		}
		
		private function removeHandlers() : void
		{
			workArea.removeEventListener( EditorEvent.REMOVED, editor_removedHandler, true );
			workArea.removeEventListener( WorkAreaEvent.CHANGE, changeHandler );
			workArea.removeEventListener( TabEvent.ELEMENT_REMOVE, removeTabHandler );
		}
		
		private function editor_removedHandler( event : EditorEvent ) : void
		{
			var editor : ScriptEditor = event.target as ScriptEditor;
			if ( editor is ScriptEditor )
			{
				facade.removeMediator( ScriptEditorMediator.NAME + editor.editorID  );
				workArea.closeEditor( editor.actionVO );
			}
		}
		
		private function changeHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.CHANGE_SELECTED_SCRIPT, workArea.selectedEditor );
		}
		
		private function removeTabHandler( event : TabEvent ) : void
		{
			Alert.Show( "Script has been modified. Save changes?", AlertButton.OK_No_Cancel, workArea.parentApplication, chackActionRequest );
			
			var actionVO : Object = ScriptEditor( event.element ).actionVO;
			var index : int = event.index;
			
			function chackActionRequest( event : CloseEvent ) : void 
			{
				if ( event.detail == Alert.YES )
				{
					closedScript = true;
					sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : actionVO, check : true } );
				}
				
				if ( event.detail == Alert.NO )
				{
					workArea.closeTab( index );
				}
			}
		}
		
		private function clearData() : void
		{
			workArea.closeAllEditors();
		}
	}
}