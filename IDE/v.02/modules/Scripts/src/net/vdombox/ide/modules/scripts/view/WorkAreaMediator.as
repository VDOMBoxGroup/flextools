package net.vdombox.ide.modules.scripts.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.events.EditorEvent;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.vo.GlobalActionVO;
	import net.vdombox.ide.common.vo.LibraryVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.modules.scripts.ApplicationFacade;
	import net.vdombox.ide.modules.scripts.model.SessionProxy;
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
		private var sessionProxy : SessionProxy;
		
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
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
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
			interests.push( ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED );
			interests.push( ApplicationFacade.SELECTED_LIBRARY_CHANGED );
			interests.push( ApplicationFacade.SELECTED_GLOBAL_ACTION_CHANGED );
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			//var objectVO : ObjectVO;
			var editor : ScriptEditor;
			
			if ( !isActive && name != ApplicationFacade.BODY_START )
				return;
			
			
			
			switch ( name )
			{
				case ApplicationFacade.BODY_START:
				{
					isActive = true;
					
					break;
				}
					
				case ApplicationFacade.BODY_STOP:
				{
					clearData();
					
					isActive = false;
					
					break;
				}
					
				case ApplicationFacade.SELECTED_SERVER_ACTION_CHANGED:
				{
					serverActionVO = body as ServerActionVO;
					OpenAndFindEditor( serverActionVO );
					
					break;
				}
					
				case ApplicationFacade.SELECTED_LIBRARY_CHANGED:
				{
					libraryVO = body as LibraryVO
					OpenAndFindEditor( libraryVO );
					
					break;
				}
					
				case ApplicationFacade.SELECTED_GLOBAL_ACTION_CHANGED:
				{
					globalActionVO = body as GlobalActionVO;
					OpenAndFindEditor( globalActionVO );
					
					
					break;
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
					if ( sessionProxy.selectedObject )
						editor = workArea.openEditor( sessionProxy.selectedObject, objectVO ) as ScriptEditor;
					else
						editor = workArea.openEditor( sessionProxy.selectedPage, objectVO ) as ScriptEditor;
					if ( facade.retrieveMediator( ScriptEditorMediator.NAME + editor.editorID ) != null )
						facade.removeMediator( ScriptEditorMediator.NAME + editor.editorID  );
					facade.registerMediator( new ScriptEditorMediator( editor ) );
					editor.enabled = true;
					editor.script = objectVO.script;
				}
				else
					workArea.selectedEditor = editor;
				
				
				
			}
		}
		
		private function addHandlers() : void
		{
			workArea.addEventListener( EditorEvent.REMOVED, editor_removedHandler, true, 0, true );
			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			workArea.addEventListener( WorkAreaEvent.CHANGE, changeHandler, false, 0, true );
		}
		
		private function removeHandlers() : void
		{
			workArea.removeEventListener( EditorEvent.REMOVED, editor_removedHandler, true );
			workArea.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			workArea.addEventListener( WorkAreaEvent.CHANGE, changeHandler, false, 0, true );
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
			var selectedEditor : ScriptEditor = workArea.selectedEditor;
			
			if ( selectedEditor && selectedEditor is ScriptEditor )
			{
				if ( selectedEditor.objectVO && selectedEditor.objectVO is PageVO &&  selectedEditor.objectVO.id != sessionProxy.selectedPage.id )
					sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, selectedEditor.objectVO );
				else if ( !sessionProxy.selectedObject || selectedEditor.objectVO && selectedEditor.objectVO is ObjectVO && selectedEditor.objectVO.id != sessionProxy.selectedObject.id )
				{
					sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedEditor.objectVO );
					/*if ( selectedEditor.objectVO.pageVO.id != sessionProxy.selectedPage.id )
						sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, sessionProxy. );*/
				}
			}
		}	
		
		private function removedFromStageHandler( event : Event ) : void
		{
			clearData();
		}
		
		private function clearData() : void
		{
			workArea.closeAllEditors();
		}
	}
}