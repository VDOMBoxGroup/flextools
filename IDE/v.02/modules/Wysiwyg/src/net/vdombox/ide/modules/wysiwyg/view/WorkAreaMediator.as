package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import mx.events.DragEvent;
	
	import net.vdombox.components.tabNavigatorClasses.Tab;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.events.TransformMarkerEvent;
	import net.vdombox.ide.modules.wysiwyg.events.WorkAreaEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.ObjectRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.PageEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.TypeItemRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Group;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var sessionProxy : SessionProxy;

		private var isActive : Boolean;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();

//			isSelectedPageVOChanged = true;
//			
//			if( workArea && workArea.stage )
//				isAddedToStage = true;
//
//			commitProperties();
		}

		override public function onRemove() : void
		{
			clearData();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			
			interests.push( ApplicationFacade.OPEN_PAGE_REQUEST );
			interests.push( ApplicationFacade.OPEN_OBJECT_REQUEST );

			return interests;
		}

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
					if ( sessionProxy.selectedApplication )
					{
						isActive = true;

						break;
					}
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					var pageVO : PageVO = body as PageVO;
					var pageEditor : IEditor = workArea.getEditorByVO( pageVO );
					
					if( !pageEditor )
						pageEditor = workArea.openEditor( pageVO );
					
					workArea.selectedEditor = pageEditor;
						
					break;
				}
					
				case ApplicationFacade.OPEN_PAGE_REQUEST:
				{
				}
					
				case ApplicationFacade.OPEN_OBJECT_REQUEST:
				{
					var vdomObjectVO : IVDOMObjectVO = body as IVDOMObjectVO;
					var editor : IEditor = workArea.getEditorByVO( vdomObjectVO );
					
					if( !editor )
						editor = workArea.openEditor( vdomObjectVO );
					else
						workArea.selectedEditor = editor;
					
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
			
			workArea.addEventListener( WorkAreaEvent.CHANGE, changeHandler, false, 0, true );
			
			workArea.addEventListener( EditorEvent.CREATED, editor_createdHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			workArea.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			workArea.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );
			
			workArea.removeEventListener( WorkAreaEvent.CHANGE, changeHandler );
			
			workArea.removeEventListener( EditorEvent.CREATED, editor_createdHandler, true  );
		}

		private function clearData() : void
		{
			removeHandlers();
			
			facade.removeMediator( NAME );
		}

		private function addedToStageHandler( event : Event ) : void
		{
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			clearData();
		}
		
		private function changeHandler( event : WorkAreaEvent ) : void
		{
			var selectedEditor : IEditor = workArea.selectedEditor;
			
			if( !selectedEditor )
				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, null );
			else if( selectedEditor is PageEditor )
				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, selectedEditor.vdomObjectVO );
			else if( selectedEditor is ObjectEditor )
				sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedEditor.vdomObjectVO );
			
		}
		
		private function editor_createdHandler( event : EditorEvent ) : void
		{
			sendNotification( ApplicationFacade.EDITOR_CREATED, event.target as IEditor );
		}
	}
}