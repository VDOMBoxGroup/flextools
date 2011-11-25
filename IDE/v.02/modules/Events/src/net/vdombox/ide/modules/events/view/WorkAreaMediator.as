package net.vdombox.ide.modules.events.view
{
	import flash.desktop.NativeApplication;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
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
			
			
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			
			interests.push( ApplicationFacade.CHILDREN_ELEMENTS_GETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var objectID : String;
			var element : Object;
			var leng : Number;

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
					
				case ApplicationFacade.SELECTED_PAGE_CHANGED:
				{
					setVisibleElementsForAllObjects();
					setElementsCurrentVisibleState();
					break;
				}
					
				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					setVisibleElementsForAllObjects();
					setElementsCurrentVisibleState();
					break;
				}
					
				case ApplicationFacade.CHILDREN_ELEMENTS_GETTED:
				{
					setVisibleElementsForContainer( body as XML );
					break;
				}
			}
		}
		
		private function setVisibleElementsForContainer( item : XML ) : void
		{
			setVisibleElementsForAllObjects();
			var leng : Number = workArea.contentGroup.numElements;
			var element : BaseElement;
			var objectsID : Array = new Array();

			var xmlList : XMLList = item..object;
			objectsID.push( item.@id );
			
			var objectXML : XML;
			
			for each( objectXML in xmlList)
			{
				objectsID.push( objectXML.@id );
			}
			
			for ( var i : int = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i ) as BaseElement;
				element.alpha = 1;
				if ( element && !findIDinArray( element.objectID, objectsID ) )
					element.visible = false;
			}
			
			workArea.setVisibleStateForCurrnetLinkages( objectsID );
		}
		
		private function findIDinArray( objectID : String, arrayID : Array ) : Boolean
		{
			var itemID : String;
			for each ( itemID in arrayID )
			{
				if ( itemID == objectID)
					return true;
			}
			return false;
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( WorkAreaEvent.SAVE, saveHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.UNDO, undoHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.SHOW_HIDDEN_ELEMENTS_STATE_CHANGED, showHiddenElementsStateChanged, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.SHOW_ELEMENTS_STATE_CHANGED, showCurrentElementsStateChanged, true, 0, true );
			workArea.addEventListener( ElementEvent.EYE_CLICKED, elementEyeClicked, true );
			workArea.addEventListener( ElementEvent.CREATE_ELEMENT, createElementHandler, true );
			workArea.addEventListener( WorkAreaEvent.DELETE_ELEMENT, element_deleteHandler );
			NativeApplication.nativeApplication.addEventListener( KeyboardEvent.KEY_DOWN, shiftClickHandler );
			NativeApplication.nativeApplication.addEventListener( KeyboardEvent.KEY_UP, shiftOffHandler );
		}

		private function removeHandlers() : void
		{
			//  addEventListener || remouve ? 
			workArea.removeEventListener( WorkAreaEvent.SAVE, saveHandler );
			workArea.removeEventListener( WorkAreaEvent.UNDO, undoHandler );
			workArea.removeEventListener( WorkAreaEvent.SHOW_HIDDEN_ELEMENTS_STATE_CHANGED, showHiddenElementsStateChanged );
			workArea.removeEventListener( WorkAreaEvent.SHOW_ELEMENTS_STATE_CHANGED, showCurrentElementsStateChanged );
			workArea.removeEventListener( ElementEvent.EYE_CLICKED, elementEyeClicked, true );
			workArea.removeEventListener( ElementEvent.CREATE_ELEMENT, createElementHandler, true );
			workArea.removeEventListener( WorkAreaEvent.DELETE_ELEMENT, element_deleteHandler );
			NativeApplication.nativeApplication.removeEventListener( KeyboardEvent.KEY_DOWN, shiftClickHandler );	
			NativeApplication.nativeApplication.removeEventListener( KeyboardEvent.KEY_UP, shiftOffHandler );
		}
		
		private function set showElementsView ( value : String ) : void
		{
			visibleElementProxy.showCurrent = value;
			workArea.showElementsView = value;
			if ( value == "Full" )
				workArea._showElementsView.toolTip = "ctrl + 1";
			else if ( value == "Middle" )
				workArea._showElementsView.toolTip = "ctrl + 2";
			else if ( value == "Short" )
				workArea._showElementsView.toolTip = "ctrl + 3";
		}
		
		private function shiftClickHandler( event : KeyboardEvent ) : void
		{
			if ( event.keyCode == Keyboard.SHIFT )
			{
				sendNotification( ApplicationFacade.GET_CHILDREN_ELEMENTS );
				return;
			}
			
			if ( !event.ctrlKey )
				return;
				
			if ( event.keyCode == Keyboard.NUMBER_2 )
			{
				showElementsView = "Middle";
				setVisibleElementsForCurrentObject( false );
			}
			else if ( event.keyCode == Keyboard.NUMBER_3 )
			{
				showElementsView = "Short";
				setVisibleElementsForCurrentObject( true );
			}
			else if ( event.keyCode == Keyboard.NUMBER_1 )
			{
				showElementsView = "Full";
				setVisibleElementsForAllObjects();
			} 
		}
		
		private function shiftOffHandler( event : KeyboardEvent ) : void
		{
			setElementsCurrentVisibleState();
		}
		
		private function setVisibleElementsForCurrentObject( altKey : Boolean ) : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var element : BaseElement;
			
			var newTarget : Object = sessionProxy.selectedObject ? sessionProxy.selectedObject : sessionProxy.selectedPage;
			var objectID : String = newTarget.id;

			for ( var i : int = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i ) as BaseElement;
				element.alpha = 1;
				if ( element && element.objectID != objectID )
					element.visible = false;
				
			}
			
			if ( altKey )
				workArea.setVisibleStateForAllLinkages( false );
			else
				workArea.setVisibleStateForCurrnetLinkages( objectID );

		}
		
		private function setVisibleElementsForAllObjects() : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var element : BaseElement;
			
			var newTarget : Object = sessionProxy.selectedObject ? sessionProxy.selectedObject : sessionProxy.selectedPage;
			var objectID : String;
			if ( newTarget is PageVO )
				objectID = newTarget.id;
			else if ( newTarget is BaseElement )
				objectID = newTarget.objectID;

			var showNotVisible : Boolean = visibleElementProxy.showHidden;
			
			for ( var i : int = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i ) as BaseElement;
				if ( element )
				{
					element.alpha = 1;
					if (  !showNotVisible )
						element.visible = visibleElementProxy.getElementEyeOpened( element.uniqueName );
					else
						element.visible = true;
				}
			}
			workArea.setVisibleStateForAllLinkages( false );
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
		
		private function showCurrentElementsStateChanged( event : WorkAreaEvent ) : void
		{
			showElementsView = workArea.showElementsView ;
			setElementsCurrentVisibleState();
		}
		
		private function setElementsCurrentVisibleState() : void
		{
			showElementsView = workArea.showElementsView ;
			if ( workArea.showElementsView == "Middle" )
				setVisibleElementsForCurrentObject( false );
			else if ( workArea.showElementsView == "Short" )
				setVisibleElementsForCurrentObject( true );
			else if ( workArea.showElementsView == "Full" )
				setVisibleElementsForAllObjects();
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
			showElementsView = visibleElementProxy.showCurrent;
			var numElements : Number = workArea.contentGroup.numElements;
			
			var element		: Object;
			
			for ( var i:uint = 0; i < numElements; i++ )
			{
				element = workArea.contentGroup.getElementAt( i );
				
				if (element is BaseElement)
					setElementVisibleState (element as BaseElement);
			}
			
			if ( workArea.showElementsView == "Middle" )
				setVisibleElementsForCurrentObject( false );
			else if ( workArea.showElementsView == "Short" )
				setVisibleElementsForCurrentObject( true );
			else if ( workArea.showElementsView == "Full" )
				setVisibleElementsForAllObjects();
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
			workArea.showHidden= showNotVisible;
			showElementsView = visibleElementProxy.showCurrent;
			
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
			workArea.showHidden = showNotVisible;
			showElementsView = visibleElementProxy.showCurrent;
			
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