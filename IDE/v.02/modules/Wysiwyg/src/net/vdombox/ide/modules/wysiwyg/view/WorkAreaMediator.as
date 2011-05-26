package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.WorkAreaEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.view.components.VdomObjectEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.WorkArea;
	
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
			removeHandlers();
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

			var vdomObjectVO : IVDOMObjectVO;
			var editor : IEditor;

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
					vdomObjectVO = body as IVDOMObjectVO;
					editor = workArea.getEditorByVO( vdomObjectVO );

					if ( editor )
					{ 
						workArea.selectedEditor = editor;
				
					}
					else
					{
						editor = workArea.openEditor( vdomObjectVO );
						/*	if ( workArea.selectedEditor )
						{
						trace("workArea.selectedEditor  == true");
						workArea.selectedEditor.editorVO.vdomObjectVO = vdomObjectVO;
						}
						else
						{	trace("workArea.selectedEditor == null");
						editor = workArea.openEditor( vdomObjectVO );
						}*/
					}

					break;
				}

				case ApplicationFacade.OPEN_PAGE_REQUEST:
				{
				}

				case ApplicationFacade.OPEN_OBJECT_REQUEST:
				{
					vdomObjectVO = body as IVDOMObjectVO;
					editor = workArea.getEditorByVO( vdomObjectVO );

					if ( !editor )
					{
						editor = workArea.openEditor( vdomObjectVO );
						sendNotification( ApplicationFacade.EDITOR_CREATED, editor );
					}
					else
					{
						workArea.selectedEditor = editor;
					}

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );
			
			// Alexey Andreev: delete because do not used in outher modules 
//			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			workArea.addEventListener( WorkAreaEvent.CHANGE, changeHandler, false, 0, true );

			workArea.addEventListener( EditorEvent.PREINITIALIZED, editor_preinitializedHandler, true, 0, true );
			workArea.addEventListener( EditorEvent.REMOVED, editor_removedHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			workArea.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			workArea.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );

			workArea.removeEventListener( WorkAreaEvent.CHANGE, changeHandler );

			workArea.removeEventListener( EditorEvent.PREINITIALIZED, editor_preinitializedHandler, true );
			workArea.removeEventListener( EditorEvent.REMOVED, editor_removedHandler, true );
		}

		private function clearData() : void
		{
//			removeHandlers();

			workArea.closeAllEditors();

//			facade.removeMediator( NAME );
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
//			if ( !selectedEditor )
//				sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, null );
			if ( selectedEditor && selectedEditor is VdomObjectEditor )
			{
				var selectedRenderer : IRenderer =  selectedEditor.selectedRenderer; 
				if(selectedRenderer)
				{
					// selected a objectVO 
					sendNotification( ApplicationFacade.CHANGE_SELECTED_OBJECT_REQUEST, selectedEditor.selectedRenderer.vdomObjectVO );
				}
				else
				{
					// select a PageVO
					sendNotification( ApplicationFacade.CHANGE_SELECTED_PAGE_REQUEST, selectedEditor.editorVO.vdomObjectVO );
				}
			}
		}

		private function editor_preinitializedHandler( event : EditorEvent ) : void
		{
			sendNotification( ApplicationFacade.EDITOR_CREATED, event.target as IEditor );
		}

		private function editor_removedHandler( event : EditorEvent ) : void
		{
			sendNotification( ApplicationFacade.EDITOR_REMOVED, event.target as IEditor );
		}
	}
}