package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.modules.dataBase.ApplicationFacade;
	import net.vdombox.ide.modules.dataBase.events.EditorEvent;
	import net.vdombox.ide.modules.dataBase.interfaces.IEditor;
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
			
			interests.push( ApplicationFacade.TABLE_GETTED);
			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED);
			
			return interests;
		}
		
		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var objectVO : ObjectVO;
			var editor : IEditor;
			
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
					
				case ApplicationFacade.TABLE_GETTED:
				{
					objectVO = body as ObjectVO;
					editor = workArea.getEditorByVO( objectVO );
					
					if ( !editor )
						editor = workArea.openEditor( objectVO );
					else
						workArea.selectedEditor = editor;
					break;
				}
					
				case ApplicationFacade.SELECTED_APPLICATION_CHANGED:
				{
					workArea.closeAllEditors();
					
					break
				}
					
			}
		}
		
		private function addHandlers() : void
		{
			workArea.addEventListener( EditorEvent.REMOVED, editor_removedHandler, true, 0, true );
			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
		}
		
		private function removeHandlers() : void
		{
			workArea.removeEventListener( EditorEvent.REMOVED, editor_removedHandler, true );
			workArea.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
		}
		
		private function removedFromStageHandler( event : Event ) : void
		{
			clearData();
		}
		
		private function editor_removedHandler( event : EditorEvent ) : void
		{
			//sendNotification( ApplicationFacade.EDITOR_REMOVED, event.target as IEditor );
			//workArea.closeEditor( );
		}
		
		private function clearData() : void
		{
			workArea.closeAllEditors();
		}
		
		
		
		
		
	}
}