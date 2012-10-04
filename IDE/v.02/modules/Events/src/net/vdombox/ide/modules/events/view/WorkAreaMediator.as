package net.vdombox.ide.modules.events.view
{
	import flash.desktop.NativeApplication;
	import flash.display.NativeWindow;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.controller.Notifications;
	import net.vdombox.ide.common.interfaces.IEventBaseVO;
	import net.vdombox.ide.common.model.StatesProxy;
	import net.vdombox.ide.common.model._vo.ApplicationEventsVO;
	import net.vdombox.ide.common.model._vo.ClientActionVO;
	import net.vdombox.ide.common.model._vo.EventVO;
	import net.vdombox.ide.common.model._vo.ObjectVO;
	import net.vdombox.ide.common.model._vo.PageVO;
	import net.vdombox.ide.common.view.components.button.AlertButton;
	import net.vdombox.ide.common.view.components.windows.Alert;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	import net.vdombox.ide.modules.events.events.WorkAreaEvent;
	import net.vdombox.ide.modules.events.model.MessageStackProxy;
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
		private var statesProxy : StatesProxy;
		private var visibleElementProxy : VisibleElementProxy;
		private var treePanelCreateCompleted : Boolean = false;
		private var sendChildrenQuery : Boolean = false;

		public function get workArea() : WorkArea
		{
			return viewComponent as WorkArea;
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

			interests.push( Notifications.APPLICATION_EVENTS_GETTED );
			interests.push( Notifications.APPLICATION_EVENTS_SETTED );
			
			interests.push( StatesProxy.SELECTED_PAGE_CHANGED );
			interests.push( StatesProxy.SELECTED_OBJECT_CHANGED );
			
			interests.push( Notifications.CHILDREN_ELEMENTS_GETTED );
			interests.push( Notifications.STRUCTURE_GETTED );
			
			interests.push( Notifications.CHECK_SAVE_IN_WORKAREA );
			
			interests.push( Notifications.SAVE_CHANGED );
			
			interests.push( Notifications.UNDO_REDO_GETTED );
			
			interests.push( Notifications.SET_SELECTED_ACTION );
			interests.push( Notifications.SET_SELECTED_ACTION );
			
			interests.push( Notifications.GET_USED_ACTIONS );
			
			interests.push( Notifications.CREATE_SELECTED_ACTION );
			
			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();
			
			var objectID : String;
			var element : Object;
			var leng : Number;

			if ( !isActive && name != Notifications.BODY_START )
				return;

			switch ( name )
			{
				case Notifications.BODY_START:
				{
					isActive = true;
					treePanelCreateCompleted = false;
					break;
				}

				case Notifications.BODY_STOP:
				{
					isActive = false;
					workArea.dataProvider = null;

					break;
				}

				case StatesProxy.SELECTED_PAGE_CHANGED:
				{
					if ( statesProxy.selectedApplication && statesProxy.selectedPage )
					{
						workArea.removeAllElements();
						workArea.linkagesLayer.removeAllElements();
						workArea.pageName.text = body.name;
						sendNotification( Notifications.GET_APPLICATION_EVENTS,
										  { applicationVO: statesProxy.selectedApplication, pageVO: statesProxy.selectedPage } );
						
						workArea.skin.currentState = "normal"; 
					}
					break;
				}
					
				case Notifications.APPLICATION_EVENTS_GETTED:
				{
					workArea.dataProvider = body as ApplicationEventsVO;
					showElementsView = visibleElementProxy.showCurrent;
					setElementsCurrentVisibleState();
					
					
					var messageStackProxy : MessageStackProxy = facade.retrieveProxy( MessageStackProxy.NAME + workArea.dataProvider.pageVO.id ) as MessageStackProxy;
					if ( !messageStackProxy || messageStackProxy.length == 0 )
						setMessageHandler();
						
					break;
				}
					
				case Notifications.APPLICATION_EVENTS_SETTED:
				{
					workArea.skin.currentState = "normal"; //TODO: добавить public свойство для изменения внутреннего state
					
					break;
				}
					
				case StatesProxy.SELECTED_OBJECT_CHANGED:
				{
					setVisibleElementsForAllObjects();
					setElementsCurrentVisibleState();
					
					sendActions();
					break;
				}
					
				case Notifications.CHILDREN_ELEMENTS_GETTED:
				{
					setVisibleElementsForContainer( body as XML );
					break;
				}
					
				case Notifications.STRUCTURE_GETTED:
				{
					treePanelCreateCompleted = true;
					if ( sendChildrenQuery )
					{
						sendChildrenQuery = false;
						sendNotification( Notifications.GET_CHILDREN_ELEMENTS );
					}
					
					break;
				}
					
				case Notifications.CHECK_SAVE_IN_WORKAREA:
				{
					if ( workArea.skin.currentState == "unsaved" )
						sendNotification( Notifications.SAVE_IN_WORKAREA_CHECKED, { applicationVO : statesProxy.selectedApplication, object : body , saved : false } );
					else
						sendNotification( Notifications.SAVE_IN_WORKAREA_CHECKED, { applicationVO : statesProxy.selectedApplication, object : body , saved : true } );
					
					break;
				}
					
				case Notifications.SAVE_CHANGED:
				{
					saveHandler();
					
					break;
				}
					
				case Notifications.UNDO_REDO_GETTED:
				{
					workArea.dataProvider = body as ApplicationEventsVO;
					
					workArea.skin.currentState = "unsaved"; 
					
					break;
				}
					
				case Notifications.SET_SELECTED_ACTION:
				{
					workArea.showSelectedAction( body as String );
					
					break;
				}
					
				case Notifications.GET_USED_ACTIONS:
				{
					sendActions();
					
					break;
				}
					
				case Notifications.CREATE_SELECTED_ACTION:
				{
					workArea.createBaseAction( body as IEventBaseVO );
					
					break;
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
			workArea.addEventListener( WorkAreaEvent.REDO, redoHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.CHANGE_ACTIONS, sendActions, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.SET_MESSAGE, setMessageHandler, false, 0, true );
			workArea.addEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, true, 0, true );
			NativeApplication.nativeApplication.addEventListener( KeyboardEvent.KEY_DOWN, appKeyDownHandler, true, 0, true );
			workArea.addEventListener( WorkAreaEvent.SHOW_ELEMENTS_STATE_CHANGED, showCurrentElementsStateChanged, true, 0, true );
		}

		private function removeHandlers() : void
		{
			//  addEventListener || remouve ? 
			workArea.removeEventListener( WorkAreaEvent.SAVE, saveHandler );
			workArea.removeEventListener( WorkAreaEvent.UNDO, undoHandler );
			workArea.removeEventListener( WorkAreaEvent.REDO, redoHandler );
			workArea.removeEventListener( WorkAreaEvent.SET_MESSAGE, setMessageHandler );
			workArea.removeEventListener( KeyboardEvent.KEY_DOWN, keyDownHandler, true );
			NativeApplication.nativeApplication.removeEventListener( KeyboardEvent.KEY_DOWN, appKeyDownHandler, true );
			workArea.removeEventListener( WorkAreaEvent.SHOW_ELEMENTS_STATE_CHANGED, showCurrentElementsStateChanged );
		}
		
		private function set showElementsView ( value : String ) : void
		{
			visibleElementProxy.showCurrent = value;
			workArea.showElementsView = value;
			if ( value == "Full view" )
				workArea._showElementsView.toolTip = "ctrl + 1";
			else if ( value == "Active + embedded" )
				workArea._showElementsView.toolTip = "ctrl + 2";
			else if ( value == "Active" )
				workArea._showElementsView.toolTip = "ctrl + 3";
		}
		
		private function setVisibleElementsForCurrentObject() : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var element : BaseElement;
			
			var newTarget : Object = statesProxy.selectedObject ? statesProxy.selectedObject : statesProxy.selectedPage;
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
		
		private function saveHandler( event : WorkAreaEvent = null) : void
		{
			sendNotification( Notifications.SET_APPLICATION_EVENTS, { applicationEventsVO : workArea.dataProvider, needForUpdate: false } );
		}
		
		private function undoHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.UNDO, statesProxy.selectedPage );
		}
		
		private function redoHandler( event : WorkAreaEvent ) : void
		{
			sendNotification( Notifications.REDO, statesProxy.selectedPage );
		}
		
		private function setMessageHandler( event : WorkAreaEvent = null) : void
		{
			sendNotification( Notifications.SET_MESSAGE, workArea.dataProvider );
		}
		
		private function showCurrentElementsStateChanged( event : WorkAreaEvent ) : void
		{
			showElementsView = workArea.showElementsView ;
			setElementsCurrentVisibleState();
			sendActions();
		}
		
		private function setElementsCurrentVisibleState() : void
		{
			showElementsView = workArea.showElementsView ;
			if ( workArea.showElementsView == "Full view" )
				setVisibleElementsForAllObjects();
			else if ( workArea.showElementsView == "Active + embedded" )
			{
				if ( treePanelCreateCompleted )
					sendNotification( Notifications.GET_CHILDREN_ELEMENTS );
				else
					sendChildrenQuery = true;
			}
			else if ( workArea.showElementsView == "Active" )
				setVisibleElementsForCurrentObject();
		}
		
		private function keyDownHandler( event : KeyboardEvent ) : void
		{			
			if( !event.ctrlKey )
				return;
			
			if ( event.keyCode == Keyboard.Z )
				sendNotification( Notifications.UNDO, statesProxy.selectedPage );
			else if ( event.keyCode == Keyboard.Y )
				sendNotification( Notifications.REDO, statesProxy.selectedPage );
			else if ( event.keyCode == Keyboard.S )
				saveHandler();
			
		}
		
		private function appKeyDownHandler( event : KeyboardEvent ) : void
		{
			if( !isActive )
				return;
			
			if ( event.keyCode == Keyboard.F5 )
			{
				if ( workArea.skin.currentState == "unsaved" )
				{
					Alert.setPatametrs( "Ok" );
					Alert.Show( "Attention!", "First press to Save!!", AlertButton.OK, workArea.parentApplication, null );
				}
				else
				{
					sendNotification( Notifications.GET_APPLICATION_EVENTS,
						{ applicationVO: statesProxy.selectedApplication, pageVO: statesProxy.selectedPage } );
				}
			}
			
			if( !event.ctrlKey )
				return;
			
			if ( event.keyCode == Keyboard.NUMBER_1 )
			{
				showElementsView = "Full view";
				setVisibleElementsForAllObjects();
			} 
			else if ( event.keyCode == Keyboard.NUMBER_2 )
			{
				showElementsView = "Active + embedded";
				sendNotification( Notifications.GET_CHILDREN_ELEMENTS );
			}
			else if ( event.keyCode == Keyboard.NUMBER_3 )
			{
				showElementsView = "Active";
				setVisibleElementsForCurrentObject();
			}
		}
		
		private function sendActions( event : WorkAreaEvent = null ) : void
		{
			var clientActions : Object = [];
			var serverActions : Object = [];
			var events : Object = [];
			
			var leng : int = workArea.contentGroup.numElements;
			var baseElement : BaseElement;
				
			for ( var i : int = 0; i < leng; i++ )
			{
				baseElement = workArea.contentGroup.getElementAt( i ) as BaseElement;
				
				if ( baseElement.data is EventVO )
					events[ baseElement.uniqueName ] = baseElement;
				else if ( baseElement.data is ClientActionVO )
					clientActions[ baseElement.data.name + baseElement.data.objectID ] = baseElement;
				else
					serverActions[ baseElement.data.name + baseElement.data.objectID ] = baseElement;
			}
			
			sendNotification( Notifications.SET_USED_ACTIONS, { events : events, clientActions : clientActions, serverActions : serverActions } );
				
		}
	}
}