package net.vdombox.ide.modules.events.view
{
	import mx.collections.ArrayList;
	import mx.core.DragSource;
	import mx.events.DragEvent;
	import mx.managers.DragManager;
	import mx.resources.ResourceManager;

	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ClientActionVO;
	import net.vdombox.ide.common.model._vo.EventVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.model._vo.ServerActionVO;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.common.view.components.windows.NameObjectWindow;
	import net.vdombox.ide.modules.events.events.EventsPanelEvent;
	import net.vdombox.ide.modules.events.model.VisibleElementProxy;
	import net.vdombox.ide.modules.events.view.components.BaseItemRenderer;
	import net.vdombox.ide.modules.events.view.components.EventsPanel;
	import net.vdombox.utils.WindowManager;

	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	import spark.components.List;

	public class EventsPanelMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "EventsPanelMediator";

		public function EventsPanelMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}

		private var statesProxy : StatesProxy;

		private var currentTarget : Object;

		private var currentTypeVO : TypeVO;

		private var isActive : Boolean;

		private var elements : Array;

		public var scripts : Array;

		private var visibleElementProxy : VisibleElementProxy;

		public function get eventsPanel() : EventsPanel
		{
			return viewComponent as EventsPanel;
		}

		override public function onRegister() : void
		{
			statesProxy = facade.retrieveProxy( StatesProxy.NAME ) as StatesProxy;
			visibleElementProxy = facade.retrieveProxy( VisibleElementProxy.NAME ) as VisibleElementProxy;
			isActive = false;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( Notifications.BODY_START );
			interests.push( Notifications.BODY_STOP );

			interests.push( StatesProxy.SELECTED_APPLICATION_CHANGED );
			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );
			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );

			interests.push( Notifications.SERVER_ACTIONS_LIST_GETTED );
			interests.push( Notifications.SERVER_ACTIONS_GETTED );
			interests.push( Notifications.SERVER_ACTIONS_SETTED );

			interests.push( Notifications.SAVE_IN_WORKAREA_CHECKED );

			interests.push( Notifications.SET_USED_ACTIONS );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( name )
			{
				case Notifications.BODY_STOP:
				{
					isActive = false;

					break;
				}

				case Notifications.BODY_START:
				{
					isActive = true;

					break;
				}

				case Notifications.SERVER_ACTIONS_LIST_GETTED:
				{
					showActions( body as Array );

					break;
				}

				case Notifications.SERVER_ACTIONS_GETTED:
				{
					scripts = body.serverActions as Array;
					sendNotification( Notifications.GET_SERVER_ACTIONS_LIST, currentTarget );

					return;

				}

				case Notifications.SERVER_ACTIONS_SETTED:
				{
					scripts = body.serverActions as Array;
					sendNotification( Notifications.GET_SERVER_ACTIONS_LIST, currentTarget );
					sendNotification( Notifications.GET_SERVER_ACTIONS, currentTarget );
					return;
				}

				case Notifications.SAVE_IN_WORKAREA_CHECKED:
				{
					if ( body.object != this )
						return;

					if ( ( body.saved as Boolean ) )
						openCreateServerActionWindow();
					else
					{
						Alert.setPatametrs( "Ok" );
						Alert.Show( "Attantion!", "First press to Save!!", AlertButton.OK, eventsPanel.parentApplication, null );
					}
					return;
				}

				case Notifications.SET_USED_ACTIONS:
				{
					var clientActions : Object = body.clientActions as Array;
					var serverActions : Object = body.serverActions as Array;
					var events : Object = body.events as Array;

					var event : EventVO;
					var list : Array = ( eventsPanel.eventsList.dataProvider as ArrayList ).source;

					var selectedID : String;
					var i : int;

					if ( statesProxy.selectedObject )
						selectedID = statesProxy.selectedObject.id;
					else
						selectedID = statesProxy.selectedPage.id;

					for ( i = 0; i < list.length; i++ )
					{
						if ( events.hasOwnProperty( list[ i ].name + selectedID ) )
							list[ i ].used = true;
						else
							list[ i ].used = false;
					}

					list = ( eventsPanel.actionsList.dataProvider as ArrayList ).source;

					for ( i = 0; i < list.length; i++ )
					{
						if ( list[ i ] is ClientActionVO )
						{
							if ( clientActions.hasOwnProperty( list[ i ].name + selectedID ) )
								list[ i ].used = true;
							else
								list[ i ].used = false;
						}
						else
						{

							if ( serverActions.hasOwnProperty( list[ i ].name + selectedID ) )
								list[ i ].used = true;
							else
								list[ i ].used = false;
						}
					}

					return;
				}

			}

			commitProperties();
		}

		private function commitProperties() : void
		{
			var newTarget : Object;

			if ( statesProxy.selectedObject )
				newTarget = statesProxy.selectedObject;
			else if ( statesProxy.selectedPage )
				newTarget = statesProxy.selectedPage;

			if ( !isActive || !newTarget )
			{
				clearData();
				return;
			}

			if ( currentTarget && currentTarget.id == newTarget.id )
				return;

			currentTarget = newTarget;
			currentTypeVO = currentTarget.typeVO;

			if ( currentTarget is PageVO || currentTarget as ObjectVO && currentTypeVO.container != 1 )
				eventsPanel.createServerAction.visible = true;
			else
				eventsPanel.createServerAction.visible = false;

			eventsPanel.eventsList.dataProvider = new ArrayList( currentTypeVO.events );

			sendNotification( Notifications.GET_SERVER_ACTIONS_LIST, currentTarget );
			sendNotification( Notifications.GET_SERVER_ACTIONS, currentTarget );
		}

		private function showActions( serverActions : Array ) : void
		{
			serverActions.sortOn( "name", Array.CASEINSENSITIVE );

			var allActions : Array = currentTypeVO.actions;

			allActions = allActions.concat( serverActions );

			eventsPanel.actionsList.dataProvider = new ArrayList( allActions );

			sendNotification( Notifications.GET_USED_ACTIONS );
		}

		private function clearData() : void
		{
			eventsPanel.eventsList.dataProvider = null;
			eventsPanel.actionsList.dataProvider = null;

			currentTarget = null;
		}

		private function addHandlers() : void
		{
			eventsPanel.eventsList.addEventListener( DragEvent.DRAG_START, dragStartHandler );
			eventsPanel.actionsList.addEventListener( DragEvent.DRAG_START, dragStartHandler );
			eventsPanel.addEventListener( EventsPanelEvent.CREATE_SERVER_ACTION_CLICK, createServerActionHandler, true );

			eventsPanel.addEventListener( EventsPanelEvent.RENDERER_CLICK, sendActionClicked, true, 0, true );
			eventsPanel.addEventListener( EventsPanelEvent.RENDERER_DOUBLE_CLICK, createActionClicked, true, 0, true );
		}



		private function removeHandlers() : void
		{
			eventsPanel.eventsList.removeEventListener( DragEvent.DRAG_START, dragStartHandler );
			eventsPanel.actionsList.removeEventListener( DragEvent.DRAG_START, dragStartHandler );
			eventsPanel.removeEventListener( EventsPanelEvent.CREATE_SERVER_ACTION_CLICK, createServerActionHandler, true );

			eventsPanel.removeEventListener( EventsPanelEvent.RENDERER_CLICK, sendActionClicked, true );
			eventsPanel.removeEventListener( EventsPanelEvent.RENDERER_DOUBLE_CLICK, createActionClicked, true );
		}

		private function dragStartHandler( event : DragEvent ) : void
		{
			var list : List;

			if ( event.target == eventsPanel.eventsList )
				list = eventsPanel.eventsList;
			else if ( event.target == eventsPanel.actionsList )
				list = eventsPanel.actionsList;

			if ( !list )
				return;

			event.preventDefault();

			var dragSource : DragSource = new DragSource();
			list.addDragData( dragSource );

			var containerID : String = statesProxy.selectedPage.id;
			var objectID : String = statesProxy.selectedObject ? statesProxy.selectedObject.id : containerID;
			var objectName : String = statesProxy.selectedObject ? statesProxy.selectedObject.name : statesProxy.selectedPage.name;

			var elementVO : Object = list.selectedItem;

			if ( elementVO is EventVO )
			{
				elementVO = elementVO.copy();
				EventVO( elementVO ).setObjectID( objectID );
				EventVO( elementVO ).setContainerID( containerID );
				EventVO( elementVO ).setObjectName( objectName );
			}
			else if ( elementVO is ClientActionVO )
			{
				elementVO = elementVO.copy();
				ClientActionVO( elementVO ).setObjectID( objectID );
				ClientActionVO( elementVO ).setObjectName( objectName );
			}
			else if ( elementVO is ServerActionVO )
			{
				ServerActionVO( elementVO ).setObjectName( statesProxy.selectedPage.name );
			}

			if ( elementVO )
				dragSource.addData( elementVO, "elementVO" );

			DragManager.doDrag( list, dragSource, event, list.createDragIndicator(), 0 /*xOffset*/, 0 /*yOffset*/, 0.5 /*imageAlpha*/, list.dragMoveEnabled );
		}

		private function sendActionClicked( event : EventsPanelEvent ) : void
		{
			var stringID : String = BaseItemRenderer( event.target ).data.name;

			stringID += statesProxy.selectedObject ? statesProxy.selectedObject.id : statesProxy.selectedPage.id;

			sendNotification( Notifications.SET_SELECTED_ACTION, stringID );
		}

		private function createActionClicked( event : EventsPanelEvent ) : void
		{
			var elementVO : Object = BaseItemRenderer( event.target ).data;

			var containerID : String = statesProxy.selectedPage.id;
			var objectID : String = statesProxy.selectedObject ? statesProxy.selectedObject.id : containerID;
			var objectName : String = statesProxy.selectedObject ? statesProxy.selectedObject.name : statesProxy.selectedPage.name;

			if ( elementVO is EventVO )
			{
				elementVO = elementVO.copy();
				EventVO( elementVO ).setObjectID( objectID );
				EventVO( elementVO ).setContainerID( containerID );
				EventVO( elementVO ).setObjectName( objectName );
			}
			else if ( elementVO is ClientActionVO )
			{
				elementVO = elementVO.copy();
				ClientActionVO( elementVO ).setObjectID( objectID );
				ClientActionVO( elementVO ).setObjectName( objectName );
			}
			else if ( elementVO is ServerActionVO )
			{
				ServerActionVO( elementVO ).setObjectName( statesProxy.selectedPage.name );
			}

			sendNotification( Notifications.CREATE_SELECTED_ACTION, elementVO );
		}

		private function createServerActionHandler( event : EventsPanelEvent ) : void
		{
			sendNotification( Notifications.CHECK_SAVE_IN_WORKAREA, this );
		}

		private function openCreateServerActionWindow() : void
		{
			var renameWindow : NameObjectWindow = new NameObjectWindow( "", ResourceManager.getInstance().getString( "Scripts_General", "create_action_window_action_title" ) );
			renameWindow.title = ResourceManager.getInstance().getString( "Scripts_General", "create_action_window_action_title" );
			renameWindow.addEventListener( PopUpWindowEvent.APPLY, applyHandler );
			renameWindow.addEventListener( PopUpWindowEvent.CANCEL, cancelHandler );

			WindowManager.getInstance().addWindow( renameWindow, eventsPanel.skin, true );

			function applyHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );

				sendNotification( Notifications.CREATE_SCRIPT_REQUEST, { name: event.name, target: Notifications.ACTION } );

			}

			function cancelHandler( event : PopUpWindowEvent ) : void
			{
				WindowManager.getInstance().removeWindow( renameWindow );
			}
		}
	}
}
