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
		private var treePanelCreateCompleted : Boolean = false;
		private var sendChildrenQuery : Boolean = false;

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

			interests.push( ApplicationFacade.APPLICATION_EVENTS_GETTED );
			interests.push( ApplicationFacade.APPLICATION_EVENTS_SETTED );
			
			interests.push( ApplicationFacade.SELECTED_PAGE_CHANGED );
			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );
			
			interests.push( ApplicationFacade.CHILDREN_ELEMENTS_GETTED );
			interests.push( ApplicationFacade.STRUCTURE_GETTED );
			
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
						workArea.pageName.text = body.name;
						sendNotification( ApplicationFacade.GET_APPLICATION_EVENTS,
										  { applicationVO: sessionProxy.selectedApplication, pageVO: sessionProxy.selectedPage } );
					}
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_GETTED:
				{
					workArea.dataProvider = body as ApplicationEventsVO;
					showElementsView = visibleElementProxy.showCurrent;
					setElementsCurrentVisibleState();
					
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_SETTED:
				{
					workArea.skin.currentState = "normal"; //TODO: добавить public свойство для изменения внутреннего state
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
					
				case ApplicationFacade.STRUCTURE_GETTED:
				{
					if ( !treePanelCreateCompleted )
					{
						treePanelCreateCompleted = true;
						if ( sendChildrenQuery )
						{
							sendChildrenQuery = false;
							sendNotification( ApplicationFacade.GET_CHILDREN_ELEMENTS );
						}
							
					}
				}
			}
		}
		
		private function setVisibleElementsForContainer( item : XML ) : void
		{
			if ( !item )
				return;
			
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
			workArea.addEventListener( WorkAreaEvent.SHOW_ELEMENTS_STATE_CHANGED, showCurrentElementsStateChanged, true, 0, true );
			NativeApplication.nativeApplication.addEventListener( KeyboardEvent.KEY_DOWN, shiftClickHandler );
			NativeApplication.nativeApplication.addEventListener( KeyboardEvent.KEY_UP, shiftOffHandler );
		}

		private function removeHandlers() : void
		{
			//  addEventListener || remouve ? 
			workArea.removeEventListener( WorkAreaEvent.SAVE, saveHandler );
			workArea.removeEventListener( WorkAreaEvent.UNDO, undoHandler );
			workArea.removeEventListener( WorkAreaEvent.SHOW_ELEMENTS_STATE_CHANGED, showCurrentElementsStateChanged );
			NativeApplication.nativeApplication.removeEventListener( KeyboardEvent.KEY_DOWN, shiftClickHandler );	
			NativeApplication.nativeApplication.removeEventListener( KeyboardEvent.KEY_UP, shiftOffHandler );
		}
		
		private function set showElementsView ( value : String ) : void
		{
			visibleElementProxy.showCurrent = value;
			workArea.showElementsView = value;
			if ( value == "Full View" )
				workArea._showElementsView.toolTip = "ctrl + 1";
			else if ( value == "Active + Embedded" )
				workArea._showElementsView.toolTip = "ctrl + 2";
			else if ( value == "Active" )
				workArea._showElementsView.toolTip = "ctrl + 3";
		}
		
		private function shiftClickHandler( event : KeyboardEvent ) : void
		{
			if ( !event.ctrlKey )
				return;
				
			if ( event.keyCode == Keyboard.NUMBER_1 )
			{
				showElementsView = "Full View";
				setVisibleElementsForAllObjects();
			} 
			else if ( event.keyCode == Keyboard.NUMBER_2 )
			{
				showElementsView = "Active + Embedded";
				sendNotification( ApplicationFacade.GET_CHILDREN_ELEMENTS );
			}
			else if ( event.keyCode == Keyboard.NUMBER_3 )
			{
				showElementsView = "Active";
				setVisibleElementsForCurrentObject();
			}
		}
		
		private function shiftOffHandler( event : KeyboardEvent ) : void
		{
			setElementsCurrentVisibleState();
		}
		
		private function setVisibleElementsForCurrentObject() : void
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
			
			workArea.setVisibleStateForCurrnetLinkages( objectID );

		}
		
		private function setVisibleElementsForAllObjects() : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var element : BaseElement;
			
			for ( var i : int = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i ) as BaseElement;
				if ( element )
				{
					element.alpha = 1;
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
		
		private function showCurrentElementsStateChanged( event : WorkAreaEvent ) : void
		{
			showElementsView = workArea.showElementsView ;
			setElementsCurrentVisibleState();
		}
		
		private function setElementsCurrentVisibleState() : void
		{
			showElementsView = workArea.showElementsView ;
			if ( workArea.showElementsView == "Full View" )
				setVisibleElementsForAllObjects();
			else if ( workArea.showElementsView == "Active + Embedded" )
			{
				if ( treePanelCreateCompleted )
					sendNotification( ApplicationFacade.GET_CHILDREN_ELEMENTS );
				else
					sendChildrenQuery = true;
			}
			else if ( workArea.showElementsView == "Active" )
				setVisibleElementsForCurrentObject();
		}
	}
}