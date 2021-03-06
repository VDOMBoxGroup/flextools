package net.vdombox.ide.modules.dataBase.view
{
	import flash.events.Event;
	import flash.utils.Dictionary;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.EditorEvent;
	import net.vdombox.ide.common.events.WorkAreaEvent;
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.model._vo.ApplicationVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.view.components.tabnavigator.Tab;
	import net.vdombox.ide.modules.dataBase.interfaces.IEditor;
	import net.vdombox.ide.modules.dataBase.model.StatesProxy;
	import net.vdombox.ide.modules.dataBase.view.components.DataTable;
	import net.vdombox.ide.modules.dataBase.view.components.WorkArea;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		private var statesProxy : StatesProxy;

		private var applicationVO : ApplicationVO;

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
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;

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

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( Notifications.PAGE_GETTED );
			interests.push( Notifications.TABLE_GETTED );
			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED );

			interests.push( Notifications.OBJECT_DELETED );

			interests.push( Notifications.OBJECT_NAME_SETTED );
			interests.push( Notifications.PAGE_NAME_SETTED );

			interests.push( Notifications.PAGE_DELETED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var objectVO : ObjectVO;
			var editor : DataTable;

			if ( !isActive && name != Notifications.BODY_START )
				return;

			var pageVO : PageVO;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					isActive = true;

					if ( applicationVO && applicationVO.id != statesProxy.selectedApplication.id )
						workArea.closeAllEditors();

					applicationVO = statesProxy.selectedApplication;

					break;
				}

				case Notifications.BODY_STOP:
				{
					clearData();

					isActive = false;

					break;
				}

				case Notifications.PAGE_GETTED:
				{
					pageVO = body as PageVO;
					editor = workArea.getEditorByVO( pageVO ) as DataTable;

					if ( !editor )
					{
						editor = workArea.openEditor( pageVO ) as DataTable;
						if ( facade.retrieveMediator( DataTableMediator.NAME + editor.editorID ) != null )
							facade.removeMediator( DataTableMediator.NAME + editor.editorID );
						facade.registerMediator( new DataTableMediator( editor ) );
					}
					else
						workArea.selectedEditor = editor;
					break;
				}

				case Notifications.TABLE_GETTED:
				{
					objectVO = body as ObjectVO;
					editor = workArea.getEditorByVO( objectVO ) as DataTable;

					if ( !editor )
					{
						editor = workArea.openEditor( objectVO ) as DataTable;
						if ( facade.retrieveMediator( DataTableMediator.NAME + editor.editorID ) != null )
							facade.removeMediator( DataTableMediator.NAME + editor.editorID );
						facade.registerMediator( new DataTableMediator( editor ) );
					}
					else
						workArea.selectedEditor = editor;
					break;
				}

				case StatesProxy.SELECTED_APPLICATION_CHANGED:
				{
					workArea.closeAllEditors();

					break
				}

				case Notifications.OBJECT_DELETED:
				{

					if ( workArea.getEditorByVO( body ) )
					{
						facade.removeMediator( DataTableMediator.NAME + body.id );
						workArea.closeTab( body );
					}

					break
				}

				case Notifications.OBJECT_NAME_SETTED:
				{
					var tab : Tab = workArea.getTabByID( body.id );

					if ( tab )
						tab.label = body.name;

					break;
				}

				case Notifications.PAGE_NAME_SETTED:
				{
					tab = workArea.getTabByID( body.id );

					if ( tab )
						tab.label = body.name;

					break;
				}

				case Notifications.PAGE_DELETED:
				{
					pageVO = body as PageVO;

					var editors : Dictionary = workArea.editors;
					var dataTable : *;
					var closeTabs : Vector.<IVDOMObjectVO> = new Vector.<IVDOMObjectVO>();

					for ( dataTable in editors )
					{
						if ( dataTable.objectVO is PageVO && dataTable.objectVO.id == pageVO.id || dataTable.objectVO is ObjectVO && dataTable.objectVO.pageVO.id == pageVO.id )
						{
							closeTabs.push( dataTable.objectVO );
						}
					}

					for ( var i : int = 0; i < closeTabs.length; i++ )
					{
						var object : IVDOMObjectVO = closeTabs[ i ];
						facade.removeMediator( DataTableMediator.NAME + object.id );
						workArea.closeTab( object );
					}



					break;
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
					sendNotification( StatesProxy.CHANGE_SELECTED_OBJECT_REQUEST, selectedEditor.objectVO );
			}

		}

		private function removedFromStageHandler( event : Event ) : void
		{
			clearData();
		}

		private function editor_removedHandler( event : EditorEvent ) : void
		{
			var editor : IEditor = event.target as IEditor;
			if ( editor is DataTable && workArea.getEditorByVO( editor.objectVO ) )
			{
				facade.removeMediator( DataTableMediator.NAME + editor.editorID );
				workArea.closeEditor( editor.objectVO );
			}
		}

		private function clearData() : void
		{
			//workArea.closeAllEditors();
		}
	}
}
