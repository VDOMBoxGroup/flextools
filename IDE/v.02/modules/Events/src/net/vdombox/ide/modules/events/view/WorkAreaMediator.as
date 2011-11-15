package net.vdombox.ide.modules.events.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationEventsVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.PageVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	import net.vdombox.ide.modules.events.events.WorkAreaEvent;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.model.VisibleElementProxy;
	import net.vdombox.ide.modules.events.view.components.ActionElement;
	import net.vdombox.ide.modules.events.view.components.BaseElement;
	import net.vdombox.ide.modules.events.view.components.EventElement;
	import net.vdombox.ide.modules.events.view.components.WorkArea;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class WorkAreaMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "WorkAreaMediator";

		public function WorkAreaMediator( viewComponent : Object = null )
		{
			super( NAME, viewComponent );
		}

		private var isActive : Boolean;
		private var sessionProxy : SessionProxy;
		private var visibleElementProxy : VisibleElementProxy;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
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

			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );

			interests.push( ApplicationFacade.APPLICATION_EVENTS_GETTED );
			interests.push( ApplicationFacade.APPLICATION_EVENTS_SETTED );
			
			interests.push( ApplicationFacade.SET_VISIBLE_ELEMENTS_FOR_OBJECT );
			interests.push( ApplicationFacade.SET_VISIBLE_ELEMENT_WORK_AREA );
			interests.push( ApplicationFacade.GET_EXISTING_ELEMENTS_IN_WORK_AREA );

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
					isActive = true;

					break;
				}

				case ApplicationFacade.BODY_STOP:
				{
					isActive = false;

					break;
				}

				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					if ( sessionProxy.selectedApplication && sessionProxy.selectedPage )
					{
						workArea.dataProvider = null;
						sendNotification( ApplicationFacade.GET_APPLICATION_EVENTS,
										  { applicationVO: sessionProxy.selectedApplication, pageVO: sessionProxy.selectedPage } );
					}
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_GETTED:
				{
					workArea.dataProvider = body as ApplicationEventsVO;
					getElementsVisibleState();
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_SETTED:
				{
					workArea.skin.currentState = "normal"; //TODO: добавить public свойство для изменения внутреннего state
					break;
				}
					
				case ApplicationFacade.SET_VISIBLE_ELEMENTS_FOR_OBJECT:
				{
					setVisibleElementsForObject( body );
					break;
				}
					
				case ApplicationFacade.SET_VISIBLE_ELEMENT_WORK_AREA:
				{
					setVisibleElementInObject( body );
					break;
				}
					
				case ApplicationFacade.GET_EXISTING_ELEMENTS_IN_WORK_AREA:
				{
					sendElementsList();
					break;
				}	
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( WorkAreaEvent.SAVE, saveHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.UNDO, undoHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.SHOW_HIDDEN_ELEMENTS_STATE_CHANGED, showHiddenElementsStateChanged, false, 0, true );
			workArea.addEventListener( ElementEvent.EYE_CLICKED, elementEyeClicked, true );
			workArea.addEventListener( ElementEvent.CREATE_ELEMENT, createElementHandler, true );
			workArea.addEventListener( WorkAreaEvent.DELETE_ELEMENT, element_deleteHandler );
		}

		private function removeHandlers() : void
		{
			//  addEventListener || remouve ? 
			workArea.removeEventListener( WorkAreaEvent.SAVE, saveHandler );
			workArea.removeEventListener( WorkAreaEvent.UNDO, undoHandler );
			workArea.removeEventListener( WorkAreaEvent.SHOW_HIDDEN_ELEMENTS_STATE_CHANGED, showHiddenElementsStateChanged );
			workArea.removeEventListener( ElementEvent.EYE_CLICKED, elementEyeClicked, true );
			workArea.removeEventListener( ElementEvent.CREATE_ELEMENT, createElementHandler, true );
			workArea.removeEventListener( WorkAreaEvent.DELETE_ELEMENT, element_deleteHandler );
		}
		
		private function saveHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( ApplicationFacade.SET_APPLICATION_EVENTS, { applicationVO: sessionProxy.selectedApplication,
				pageVO : sessionProxy.selectedPage, applicationEventsVO : workArea.dataProvider } );
		}
		
		private function undoHandler( event : WorkAreaEvent ) : void
		{
			workArea.dataProvider = null;
			
			sendNotification( ApplicationFacade.GET_APPLICATION_EVENTS,
				{ applicationVO: sessionProxy.selectedApplication, pageVO: sessionProxy.selectedPage } );
		}
		
		private function createElementHandler( event : ElementEvent ) : void
		{
			var newTarget : Object;
			
			newTarget = sessionProxy.selectedObject ? sessionProxy.selectedObject : sessionProxy.selectedPage;  
			
			sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_OBJECT_TREE, newTarget.id as String );
			
			sendElementsList();
			
		}
		
		private function element_deleteHandler( event : WorkAreaEvent ) : void
		{
			sendElementsList();
		}
		
		private function sendElementsList() : void
		{
			var listElements : Array = new Array();
			var leng : Number = workArea.contentGroup.numElements;
			for ( var i : int = 0; i < leng; i++ )
			{
				listElements.push( workArea.contentGroup.getElementAt( i ) ); 
			}
			
			sendNotification( ApplicationFacade.EXISTING_ELEMENTS_IN_WORK_AREA_GETTED, listElements);
		}
		
		private function showHiddenElementsStateChanged( event : WorkAreaEvent ) : void
		{
			setElementsVisibleState();
		}
		
		private function setElementsVisibleState() : void
		{
			var numElements : Number = workArea.contentGroup.numElements;
			
			var element		: Object;
			
			visibleElementProxy.showHidden = workArea.showHidden ;
			
			for ( var i:uint = 0; i < numElements; i++ )
			{
				element = workArea.contentGroup.getElementAt( i );
				
				if (element is BaseElement)
					setElementVisibleState (element as BaseElement);
			}
			
			workArea.setVisibleStateForAllLinkages();
		}
		
		private function getElementsVisibleState() : void
		{
			workArea.showHidden = visibleElementProxy.showHidden;
			var numElements : Number = workArea.contentGroup.numElements;
			
			var element		: Object;
			
			for ( var i:uint = 0; i < numElements; i++ )
			{
				element = workArea.contentGroup.getElementAt( i );
				
				if (element is BaseElement)
					setElementVisibleState (element as BaseElement);
			}
			
			workArea.setVisibleStateForAllLinkages();
		}
		
		private function setElementVisibleState(element : BaseElement):void
		{
			var eyeOpened : Boolean = visibleElementProxy.getElementEyeOpened( element.uniqueName );
			
			element.eyeOpened = eyeOpened;
			element.visibleState = visibleElementProxy.showHidden;
		}
		
		private function elementEyeClicked( event : ElementEvent ) : void
		{
			var element	: Object = event.target;
			
			var newTarget : Object = sessionProxy.selectedObject ? sessionProxy.selectedObject : sessionProxy.selectedPage;
			
			if ( element is BaseElement )
			{
				var baseElement : BaseElement = element as BaseElement;
				
				visibleElementProxy.setElementEyeOpened( baseElement.uniqueName, baseElement.eyeOpened );
				
				// TODO : см. комменты в ApplicationFacade
				sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_OBJECT_TREE, baseElement.objectID );
				
				if ( baseElement.objectID == newTarget.id )
					sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_PANEL, { element: baseElement, eyeOpened: baseElement.eyeOpened } );
			}
			
			setElementsVisibleState();
			
		}
		
		// TODO :  убрать дублирование (базовый класс BaseElement)
		// TODO :  переименовать newTarget
		// TODO :  переименовать showNotVisible -> showHidden
		// TODO :  название функции мне тоже не особо нравится 
		private function setVisibleElementsForObject( body : Object ) : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var i : Number;
			var element : Object;
			var actionElement : ActionElement;
			var eventElement : EventElement;
			var showNotVisible : Boolean = visibleElementProxy.showHidden;
			workArea.showHiddenElements.selected = showNotVisible;
			
			var showElement : Boolean = body.visible as Boolean;
			var objectID : String = body.objectID as String;
			
			var newTarget : Object;
			
			if ( sessionProxy.selectedObject )
				newTarget = sessionProxy.selectedObject;
			else if ( sessionProxy.selectedPage )
				newTarget = sessionProxy.selectedPage;
			
			for ( i = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i );
				if ( element is ActionElement )
				{
					actionElement = element as ActionElement;
					if ( actionElement.objectID == objectID )
					{
						visibleElementProxy.setElementEyeOpened( actionElement.uniqueName, showElement );
						actionElement.eyeOpened = visibleElementProxy.getElementEyeOpened( actionElement.uniqueName );
						if ( !showNotVisible )
							actionElement.visibleState = visibleElementProxy.getElementEyeOpened( actionElement.uniqueName );
						
						if ( actionElement.objectID == newTarget.id )
							sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_PANEL, { element: actionElement, visible: actionElement.eyeOpened } );
						
					}
				}
				else if ( element is EventElement )
				{
					eventElement = element as EventElement;
					if ( eventElement.objectID== objectID )
					{
						visibleElementProxy.setElementEyeOpened( eventElement.uniqueName, showElement );
						eventElement.eyeOpened = visibleElementProxy.getElementEyeOpened( eventElement.uniqueName );
						if ( !showNotVisible )
							eventElement.visibleState = visibleElementProxy.getElementEyeOpened( eventElement.uniqueName );
						if ( eventElement.objectID == newTarget.id )
							sendNotification( ApplicationFacade.SET_VISIBLE_ELEMENT_IN_PANEL, { element: eventElement, visible: eventElement.eyeOpened } );
					}
				}
			}
			
			workArea.setVisibleStateForAllLinkages();
			
		}
		
		// TODO :  убрать дублирование (базовый класс BaseElement)
		// TODO :  переименовать newTarget
		// TODO :  переименовать showNotVisible -> showHidden
		// TODO :  название функции мне тоже не особо нравится 
		private function setVisibleElementInObject( body : Object ) : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var i : Number;
			var element : Object;
			var actionElement : ActionElement;
			var eventElement : EventElement;
			var showNotVisible : Boolean = visibleElementProxy.showHidden;
			workArea.showHiddenElements.selected = showNotVisible;
			
			var showElement : Boolean = body.eyeOpened as Boolean;
			var nameElement : String = body.name as String;
			var objectID : String = body.objectID as String;
			
			
			for ( i = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i );
				if ( element is ActionElement )
				{
					actionElement = element as ActionElement;
					if ( actionElement.objectID == objectID && actionElement.data.name == nameElement )
					{
						visibleElementProxy.setElementEyeOpened( actionElement.uniqueName, showElement );
						actionElement.eyeOpened = visibleElementProxy.getElementEyeOpened( actionElement.uniqueName );
						if ( !showNotVisible )
							actionElement.visibleState = visibleElementProxy.getElementEyeOpened( actionElement.uniqueName );
					}
				}
				else if ( element is EventElement )
				{
					eventElement = element as EventElement;
					if ( eventElement.objectID== objectID && eventElement.data.name == nameElement )
					{
						visibleElementProxy.setElementEyeOpened( eventElement.uniqueName, showElement );
						eventElement.eyeOpened = visibleElementProxy.getElementEyeOpened( eventElement.uniqueName );
						if ( !showNotVisible )
							eventElement.visibleState = visibleElementProxy.getElementEyeOpened( eventElement.uniqueName );
					}
				}
			}
			workArea.setVisibleStateForAllLinkages();
		}
	}
}