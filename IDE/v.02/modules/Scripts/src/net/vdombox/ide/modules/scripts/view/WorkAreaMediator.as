package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.EditorEvent;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.GlobalActionVO;
	import net.vdombox.ide.common.model._vo.LibraryVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.scripts.view.components.ScriptEditor;
	import net.vdombox.ide.modules.scripts.view.components.WorkArea;
	
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
			interests.push( Notifications.SELECTED_TAB_CHANGED );
			interests.push( Notifications.DELETE_TAB );
			
			interests.push( Notifications.SCRIPT_CHECKED );
			
			interests.push( Notifications.ALL_TABS_DELETED );
			
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
			
			var actionVO : Object;
			
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
					
				case Notifications.SELECTED_TAB_CHANGED:
				{
					OpenAndFindEditor( body );
					
					break;
				}
					
				case Notifications.DELETE_TAB:
				{
					actionVO = body.actionVO;
					
					editor = workArea.getEditorByVO( actionVO );
					
					if ( !body.askBeforeRemove || editor.actionVO.saved )
					{
						workArea.closeEditor( actionVO );
						
						sendNotification( Notifications.DELETE_TAB_BY_ACTIONVO, actionVO );
					}
					else if ( body.askBeforeRemove )
					{
						Alert.Show( "Script has been modified. Save changes?", AlertButton.OK_No_Cancel, workArea.parentApplication, chackActionRequest );
					}
					
					
					break;
				}
					
				case Notifications.SCRIPT_CHECKED:
				{
					actionVO = body;
					editor = workArea.getEditorByVO( actionVO );
					
					if ( actionVO.script == editor.actionVO.script.replace( /\r/g, "\n" ) )
					{
						var script : String = editor.script;
						while ( script.slice( script.length - 1 ) == "\r" || script.slice( script.length - 1 ) == " " || script.slice( script.length - 1 ) == "\t" )
							script = script.slice( 0, script.length - 1);
						
						editor.actionVO.script = script;
						sendNotification( Notifications.SAVE_SCRIPT_REQUEST, editor.actionVO );
						
						if ( closedScript )
						{
							closedScript = false;
							workArea.closeEditor( actionVO );
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
					
				case Notifications.ALL_TABS_DELETED:
				{
					clearData();
					
					break;
				}
					
			}
			
			function chackActionRequest( event : CloseEvent ) : void 
			{
				if ( event.detail == Alert.YES )
				{
					closedScript = true;
					sendNotification( Notifications.GET_SCRIPT_REQUEST, { actionVO : actionVO, check : true } );
				}
				
				if ( event.detail == Alert.NO )
				{
					workArea.closeEditor( actionVO );
					
					sendNotification( Notifications.DELETE_TAB_BY_ACTIONVO, actionVO );
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
					workArea.selectedEditor = editor;
			}
			
			sendNotification( Notifications.CHANGE_SELECTED_SCRIPT, editor );
		}
		
		private function setMediator( event : FlexEvent ) : void
		{
			var editor : ScriptEditor = event.target as ScriptEditor;
			facade.registerMediator( new ScriptEditorMediator( editor ) );
			editor.enabled = true;
			
			editor.script = editor.actionVO.script;;
		}
		
		private function addHandlers() : void
		{
			workArea.addEventListener( EditorEvent.REMOVED, editor_removedHandler, true, 0, true );
		}
		
		private function removeHandlers() : void
		{
			workArea.removeEventListener( EditorEvent.REMOVED, editor_removedHandler, true );
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
		
		private function clearData() : void
		{
			workArea.closeAllEditors();
		}
	}
}