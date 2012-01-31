package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.common.events.EditorEvent;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.modules.dataBase.interfaces.IEditor;
	import net.vdombox.ide.modules.dataBase.view.components.DataTable;
	import net.vdombox.ide.modules.dataBase.view.components.DataTableEditor;
	import net.vdombox.ide.modules.dataBase.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";
		
		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		private var isActive : Boolean;
		
		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}
		
		override public function onRegister() : void
		{
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
			
			interests.push( ApplicationFacade.PAGE_GETTED);
			interests.push( ApplicationFacade.TABLE_GETTED);
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED);
			
			interests.push( ApplicationFacade.OBJECT_DELETED);
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var objectVO : ObjectVO;
			var editor : DataTable;
			
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
					
				case ApplicationFacade.PAGE_GETTED:
				{
					var pageVO : PageVO = body as PageVO;
					editor = workArea.getEditorByVO( pageVO ) as DataTable;
					
					if ( !editor )
					{
						editor = workArea.openEditor( pageVO ) as DataTable;
						if ( facade.retrieveMediator( DataTableMediator.NAME + editor.editorID ) != null )
							facade.removeMediator( DataTableMediator.NAME + editor.editorID  );
						facade.registerMediator( new DataTableMediator( editor ) );
					}
					else
						workArea.selectedEditor = editor;
					break;
				}
					
				case ApplicationFacade.TABLE_GETTED:
				{
					objectVO = body as ObjectVO;
					editor = workArea.getEditorByVO( objectVO ) as DataTable;
					
					if ( !editor )
					{
						editor = workArea.openEditor( objectVO ) as DataTable;
						if ( facade.retrieveMediator( DataTableMediator.NAME + editor.editorID ) != null )
							facade.removeMediator( DataTableMediator.NAME + editor.editorID  );
						facade.registerMediator( new DataTableMediator( editor ) );
					}
					else
						workArea.selectedEditor = editor;
					break;
				}
					
				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					workArea.closeAllEditors();
					
					break
				}
					
				case ApplicationFacade.OBJECT_DELETED:
				{
					
					if ( workArea.getEditorByVO( body) )
					{
						facade.removeMediator( DataTableMediator.NAME + body.id  );
						workArea.closeTab( body );
					}
					
					break
				}
					
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
		
		private function changeHandler( event : WorkAreaEvent ) : void
		{
			var selectedEditor : IEditor = workArea.selectedEditor;
			
			if ( selectedEditor && selectedEditor is DataTable )
			{
				
				if ( selectedEditor.objectVO )
					sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedEditor.objectVO );
			}
			
		}
		
		private function removedFromStageHandler( event : Event ) : void
		{
			clearData();
		}
		
		private function editor_removedHandler( event : EditorEvent ) : void
		{
			var editor : IEditor = event.target as IEditor;
			if ( editor is DataTable && workArea.getEditorByVO( editor.objectVO) )
			{
				facade.removeMediator( DataTableMediator.NAME + editor.editorID  );
				workArea.closeEditor( editor.objectVO );
			}
		}
		
		private function clearData() : void
		{
			workArea.closeAllEditors();
		}
	}
}