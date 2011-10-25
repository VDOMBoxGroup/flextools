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
	import net.vdombox.ide.modules.events.events.PanelsEvent;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.model.VisibleElementProxy;
	import net.vdombox.ide.modules.events.view.components.ActionElement;
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
			interests.push( ApplicationFacade.SET_VISIBLE_NAME_ELEMENT_IN_WORK_AREA );
			interests.push( ApplicationFacade.SET_VISIBLE_ELEMENTS_IN_WORK_AREA );
			

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
					
				case ApplicationFacade.SET_VISIBLE_NAME_ELEMENT_IN_WORK_AREA:
				{
					setEye( body );
					return;
				}
					
				case ApplicationFacade.SET_VISIBLE_ELEMENTS_IN_WORK_AREA:
				{
					newEye( body );
					return;
				}
			}

			commitProperties();
		}
		
		private function setEye( body : Object ) : void
		{
			var i : int;
			var element : Object = body.element as Object;
			var visibleElement : Boolean = body.visible as Boolean;
			var dataProvaider : ArrayList;
			
			if ( element is EventElement )
			{
				dataProvaider = new ArrayList( eventsPanel.eventsList.dataProvider.toArray());
				var elementEvent : EventElement = element as EventElement;
				for each(var eventVO : EventVO in dataProvaider.source )
				{
					if ( eventVO.name == elementEvent.data.name )
					{
						eventVO.visibleEvent = visibleElement;
						break;
					}
				}
				eventsPanel.eventsList.dataProvider = dataProvaider;
				eventsPanel.eventsList.invalidateProperties();
			}
			else
			{
				dataProvaider = new ArrayList( eventsPanel.actionsList.dataProvider.toArray());
				var elementAction : ActionElement = element as ActionElement;
				for each(var object : Object in dataProvaider.source )
				{
					if ( object.name == elementAction.actionName )
					{
						object.visibleEvent = visibleElement;
						break;
					}
				}
				eventsPanel.actionsList.dataProvider = dataProvaider;
				eventsPanel.actionsList.invalidateProperties();
			}
						

		}
		
		private function newEye( body : Object ) : void
		{
			elements = body as Array;
			var dataProvaider : ArrayList;
			
			if ( eventsPanel.eventsList.dataProvider )
			{
				dataProvaider = new ArrayList( eventsPanel.eventsList.dataProvider.toArray());
				eventsPanel.eventsList.dataProvider = dataProvaider;
			}
			
			if ( eventsPanel.actionsList.dataProvider )
			{
				dataProvaider = new ArrayList( eventsPanel.actionsList.dataProvider.toArray());
				eventsPanel.actionsList.dataProvider = dataProvaider;
			}
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
			sendNotification( ApplicationFacade.GET_SERVER_ACTIONS_LIST, currentTarget );
			sendNotification( ApplicationFacade.GET_VISIBLE_ELEMENTS_IN_WORK_AREA );
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
			eventsPanel.eventsList.addEventListener( FlexEvent.CREATION_COMPLETE, createList, true );
			eventsPanel.eventsList.addEventListener( PanelsEvent.DATE_SETTED, createEyeItemRenderer, true );
			eventsPanel.actionsList.addEventListener( PanelsEvent.DATE_SETTED, createEyeItemRenderer, true );
			eventsPanel.eventsList.addEventListener( PanelsEvent.EYES_CLICK, eyesClickHandler, true );
			eventsPanel.actionsList.addEventListener( PanelsEvent.EYES_CLICK, eyesClickHandler, true );
		}
		
		

		private function removeHandlers() : void
		{
			eventsPanel.eventsList.removeEventListener( DragEvent.DRAG_START, dragStartHandler );
			eventsPanel.actionsList.removeEventListener( DragEvent.DRAG_START, dragStartHandler );
			eventsPanel.eventsList.removeEventListener( PanelsEvent.DATE_SETTED, createEyeItemRenderer, true );
			eventsPanel.actionsList.removeEventListener( PanelsEvent.DATE_SETTED, createEyeItemRenderer, true );
			eventsPanel.eventsList.removeEventListener( PanelsEvent.EYES_CLICK, eyesClickHandler, true );
			eventsPanel.actionsList.removeEventListener( PanelsEvent.EYES_CLICK, eyesClickHandler, true );
		}
		
		private function createList( event : FlexEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_VISIBLE_ELEMENTS_IN_WORK_AREA );
		}
		
		private function eyesClickHandler( event : PanelsEvent ) : void
		{
			var newTarget : Object;
			
			if ( sessionProxy.selectedObject )
				newTarget = sessionProxy.selectedObject;
			else if ( sessionProxy.selectedPage )
				newTarget = sessionProxy.selectedPage;
			
			sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_WORK_AREA, newTarget.id );
			if ( event.target is EventItemRenderer )
				sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_PANEL, { name: event.target.eventName, objectID: newTarget.id , visible: event.target.eyeOpened } );
			else
				sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_PANEL, { name: event.target.actionName, objectID: newTarget.id , visible: event.target.eyeOpened } );
		}
		
		
		private function createEyeItemRenderer( event : PanelsEvent ) : void
		{
			var newTarget : Object;
			
			if ( sessionProxy.selectedObject )
				newTarget = sessionProxy.selectedObject;
			else if ( sessionProxy.selectedPage )
				newTarget = sessionProxy.selectedPage;
			if ( event.target is EventItemRenderer )
			{
				var nameEvent : String = event.target.eventName as String;
				
			
				nameEvent += ( newTarget.id as String );
			
				if ( findInElementsEvent( nameEvent ) )
					event.target.setEyeState( visibleElementProxy.getVisible( nameEvent ) );
				else
					event.target.setEyeNull();
			}
			else
			{
				var actionName : String = event.target.actionName as String;
				var actionElement : ActionElement = findInElementsAction( actionName, newTarget.id as String );
				if ( actionElement )
				{
					if ( actionElement.idElement )
						event.target.setEyeState( visibleElementProxy.getVisible( actionElement.idElement ) );
					else
						event.target.setEyeState( true );
				}
				else
					event.target.setEyeNull();
			}

		}
		
		private function findInElementsEvent( value : String ) : Boolean
		{
			if ( !elements )
				return false;
			var i : int;
			for ( i = 0; i < elements.length; i++ )
			{
				if ( elements[i] is EventElement )
				{
					if ( elements[i].idElement == value )
						return true;
				}
			}
			return false;
		}
		
		private function findInElementsAction( value : String, objectID : String ) : ActionElement
		{
			if ( !elements )
				return null;
			var i : int;
			var actionList : Array = new Array();
			for ( i = 0; i < elements.length; i++ )
			{
				if ( elements[i] is ActionElement )
				{
					if ( elements[i].actionName == value && elements[i].objectID == objectID )
						actionList.push( elements[ i ] );
				}
			}
			
			var actionElement : ActionElement;
			
			if ( actionList.length == 0 )
					return null;
			var flag : Boolean = (actionList[ 0 ] as ActionElement).showElements;
			
			for each ( actionElement in actionList )
			{
				if ( flag != actionElement.showElements )
					return new ActionElement();
			}
	
			return actionElement;
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