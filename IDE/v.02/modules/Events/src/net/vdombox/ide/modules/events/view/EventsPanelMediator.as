package net.vdombox.ide.modules.events.view
{
	import flash.display.DisplayObject;
	import flash.filters.DisplacementMapFilter;
	
	import mx.collections.ArrayList;
	import mx.core.DragSource;
	import mx.events.DragEvent;
	import mx.events.FlexEvent;
	import mx.managers.DragManager;
	
	import net.vdombox.ide.common.vo.ClientActionVO;
	import net.vdombox.ide.common.vo.EventVO;
	import net.vdombox.ide.common.vo.ServerActionVO;
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.model.VisibleElementProxy;
	import net.vdombox.ide.modules.events.view.components.ActionElement;
	import net.vdombox.ide.modules.events.view.components.BaseElement;
	import net.vdombox.ide.modules.events.view.components.BaseItemRenderer;
	import net.vdombox.ide.modules.events.view.components.EventElement;
	import net.vdombox.ide.modules.events.view.components.EventItemRenderer;
	import net.vdombox.ide.modules.events.view.components.EventsPanel;
	
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

		private var sessionProxy : SessionProxy;

//		private var currentPage : PageVO;
//		private var currentObject : ObjectVO;

		private var currentTarget : Object;
		private var currentTypeVO : TypeVO;

		private var isActive : Boolean;
		
		private var elements : Array;
		
		private var visibleElementProxy : VisibleElementProxy;

		public function get eventsPanel() : EventsPanel
		{
			return viewComponent as EventsPanel;
		}

		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;
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

			interests.push( ApplicationFacade.BODY_START );
			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.SELECTED_APPLICATION_CHANGED );
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );

			interests.push( ApplicationFacade.SERVER_ACTIONS_LIST_GETTED );
			

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
				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					break;
				}

				case ApplicationFacade.BODY_START:
				{
					isActive = true;

					break;
				}

				case ApplicationFacade.SERVER_ACTIONS_LIST_GETTED:
				{
					showActions( body as Array );
					break;
				}
					
			}

			commitProperties();
		}

		private function commitProperties() : void
		{
			var newTarget : Object;

			if ( sessionProxy.selectedObject )
				newTarget = sessionProxy.selectedObject;
			else if ( sessionProxy.selectedPage )
				newTarget = sessionProxy.selectedPage;

			if ( !isActive || !newTarget )
			{
				clearData();
				return;
			}

			if ( currentTarget && currentTarget.id == newTarget.id )
				return;

			currentTarget = newTarget;
			currentTypeVO = currentTarget.typeVO;
			
			eventsPanel.eventsList.dataProvider = new ArrayList( currentTypeVO.events );
		}

		private function showActions( serverActions : Array ) : void
		{
			var allActions : Array = currentTypeVO.actions;

			allActions = allActions.concat( serverActions );

			eventsPanel.actionsList.dataProvider = new ArrayList( allActions );
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
		}
		
		

		private function removeHandlers() : void
		{
			eventsPanel.eventsList.removeEventListener( DragEvent.DRAG_START, dragStartHandler );
			eventsPanel.actionsList.removeEventListener( DragEvent.DRAG_START, dragStartHandler );
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

			var containerID : String = sessionProxy.selectedPage.id;
			var objectID : String = sessionProxy.selectedObject ? sessionProxy.selectedObject.id : containerID;
			var objectName : String = sessionProxy.selectedObject ? sessionProxy.selectedObject.name : sessionProxy.selectedPage.name;
			
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
				ServerActionVO( elementVO ).setObjectName( sessionProxy.selectedPage.name );
			}

			if ( elementVO )
				dragSource.addData( elementVO, "elementVO" );

			DragManager.doDrag( list,
				dragSource,
				event,
				list.createDragIndicator(),
				0 /*xOffset*/,
				0 /*yOffset*/,
				0.5 /*imageAlpha*/,
				list.dragMoveEnabled );
		}
	}
}