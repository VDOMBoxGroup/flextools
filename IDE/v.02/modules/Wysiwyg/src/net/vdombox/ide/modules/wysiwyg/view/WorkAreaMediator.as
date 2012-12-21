//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.events.WorkAreaEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.view.components.VdomObjectEditor;
	import net.vdombox.ide.modules.wysiwyg.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	/**
	 *
	 * @author andreev ap
	 *
	 */
	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var isActive : Boolean;

		private var statesProxy : StatesProxy;
		
		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();
			
			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );
			
			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );
			
			interests.push( Notifications.OPEN_PAGE_REQUEST );
			interests.push( Notifications.OPEN_OBJECT_REQUEST );
			
			interests.push( Notifications.PAGE_NAME_SETTED);
			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED);
			
			interests.push( Notifications.CLOSE_EDITOR);
			interests.push( Notifications.PAGE_DELETED);
			interests.push( Notifications.PAGE_CREATED);
			
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var vdomObjectVO : IVDOMObjectVO;
			var editor : IEditor;

			if ( !isActive && name != Notifications.BODY_START )
				return;



			switch ( name )
			{
				case Notifications.BODY_START:
				{
					if ( !statesProxy.selectedApplication )
						break;

					// if was opened before 
					if ( !workArea.selectedEditor && statesProxy.selectedPage )
						editor = workArea.openEditor( statesProxy.selectedPage );
					isActive = true;

					break;
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;

					clearData();

					break;
				}

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					vdomObjectVO = body as IVDOMObjectVO;
					
					if ( !vdomObjectVO )
					{
						workArea.closeAllEditors();
						break;
					}
					
					editor = workArea.getEditorByVO( vdomObjectVO );

					if ( editor )
						workArea.selectedEditor = editor;
					else
						editor = workArea.openEditor( vdomObjectVO );

					break;
				}

				case Notifications.OPEN_PAGE_REQUEST:
				{
				}

				case Notifications.OPEN_OBJECT_REQUEST:
				{
					vdomObjectVO = body as IVDOMObjectVO;
					editor = workArea.getEditorByVO( vdomObjectVO );

					if ( !editor )
					{
						editor = workArea.openEditor( vdomObjectVO );
						sendNotification( Notifications.EDITOR_CREATED, editor );
					}
					else
					{
						workArea.selectedEditor = editor;
					}

					break;
				}
					
				case Notifications.PAGE_NAME_SETTED:
				{
					var pageVO : PageVO = body as PageVO;
					
					workArea.selectedTab.label = pageVO.name;
					
					break;
				}
					
				case StatesProxy.SELECTED_APPLICATION_CHANGED:
				{
					workArea.closeAllEditors();
					
					break
				}
					
				case Notifications.CLOSE_EDITOR:
				{
					workArea.closeEditor( body.pageVO as PageVO, false );;
					
					break
				}
					
				case Notifications.PAGE_DELETED:
				{
					workArea.closeEditor( body.pageVO as PageVO );;
					
					break
				}
					
				case Notifications.PAGE_CREATED:
				{
					vdomObjectVO = body.pageVO as IVDOMObjectVO;
					
					if ( vdomObjectVO )
						editor = workArea.openEditor( vdomObjectVO );
					
					break;
					
					break
				}
			}
		}
		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

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

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( Event.ADDED_TO_STAGE, addedToStageHandler, false, 0, true );

			// Alexey Andreev: delete because do not used in outher modules 
//			workArea.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );
			
			workArea.addEventListener( EditorEvent.UNDO, undoHandler, true, 0, true );
			workArea.addEventListener( EditorEvent.REDO, redoHandler, true, 0, true );
			workArea.addEventListener( EditorEvent.REFRESH, refreshHandler, true, 0, true );

			workArea.addEventListener( WorkAreaEvent.CHANGE, changeHandler, false, 0, true );

			workArea.addEventListener( EditorEvent.PREINITIALIZED, editor_preinitializedHandler, true, 0, true );
			workArea.addEventListener( EditorEvent.REMOVED, editor_removedHandler, true, 0, true );
			//workArea.addEventListener( RendererEvent.REMOVED, renderer_removedHandler, true );
		}

		private function addedToStageHandler( event : Event ) : void
		{

		}
		
		private function renderer_removedHandler( event : RendererEvent ) : void
		{
			sendNotification( Notifications.RENDERER_REMOVED, event.target );
			workArea.removeEditor( (event.target as IRenderer).vdomObjectVO );
		}

		private function changeHandler( event : WorkAreaEvent ) : void
		{
			var selectedEditor : IEditor = workArea.selectedEditor;

			if ( selectedEditor && selectedEditor is VdomObjectEditor )
			{
				var selectedRenderer : IRenderer = selectedEditor.selectedRenderer;

				if ( selectedRenderer )
					sendNotification( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, selectedEditor.selectedRenderer.vdomObjectVO );
				else
				{
					sendNotification( StatesProxy.CHANGE_SELECTED_PAGE_REQUEST, selectedEditor.editorVO.vdomObjectVO );
				}
			}
		}

		private function clearData() : void
		{
			workArea.closeAllEditors();
		}

		private function editor_preinitializedHandler( event : EditorEvent ) : void
		{
			sendNotification( Notifications.EDITOR_CREATED, event.target as IEditor );
		}

		private function editor_removedHandler( event : EditorEvent ) : void
		{
			sendNotification( Notifications.EDITOR_REMOVED, event.target as IEditor );
		}

		private function removeHandlers() : void
		{
			workArea.removeEventListener( Event.ADDED_TO_STAGE, addedToStageHandler );
			workArea.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );

			workArea.removeEventListener( WorkAreaEvent.CHANGE, changeHandler );
			
			workArea.removeEventListener( EditorEvent.UNDO, undoHandler, true );
			workArea.removeEventListener( EditorEvent.REDO, redoHandler, true );
			workArea.removeEventListener( EditorEvent.REFRESH, refreshHandler, true );

			workArea.removeEventListener( EditorEvent.PREINITIALIZED, editor_preinitializedHandler, true );
			workArea.removeEventListener( EditorEvent.REMOVED, editor_removedHandler, true );
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			clearData();
		}
		
		private function undoHandler( event : EditorEvent ) : void
		{			
			if ( event.target.skin.currentState == "wysiwyg" || event.target.skin.currentState == "wysiwygDisabled" )
				sendNotification( Notifications.UNDO, statesProxy.selectedPage );
		}
		
		private function redoHandler( event : EditorEvent ) : void
		{			
			if ( event.target.skin.currentState == "wysiwyg" || event.target.skin.currentState == "wysiwygDisabled" )
				sendNotification( Notifications.REDO, statesProxy.selectedPage );
		}
		
		private function refreshHandler( event : EditorEvent ) : void
		{			
			if ( event.target.skin.currentState == "wysiwyg" || event.target.skin.currentState == "wysiwygDisabled" )
			{				
				sendNotification( Notifications.GET_WYSIWYG, statesProxy.selectedPage );
				sendNotification( Notifications.GET_PAGES, statesProxy.selectedApplication );
				
				if ( statesProxy.selectedObject )
					sendNotification( Notifications.GET_OBJECT_ATTRIBUTES, statesProxy.selectedObject );
				else if ( statesProxy.selectedPage )
					sendNotification( Notifications.GET_PAGE_ATTRIBUTES, statesProxy.selectedPage );
			}
		}
	}
}
