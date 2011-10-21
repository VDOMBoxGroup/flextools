package net.vdombox.ide.modules.events.view
{
	import mx.events.FlexEvent;
	
	import net.vdombox.ide.common.vo.ApplicationEventsVO;
	import net.vdombox.ide.modules.events.ApplicationFacade;
	import net.vdombox.ide.modules.events.events.ElementEvent;
	import net.vdombox.ide.modules.events.events.WorkAreaEvent;
	import net.vdombox.ide.modules.events.model.SessionProxy;
	import net.vdombox.ide.modules.events.model.VisibleElementProxy;
	import net.vdombox.ide.modules.events.view.components.ActionElement;
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
					setVisibleElement();
					break;
				}
					
				case ApplicationFacade.APPLICATION_EVENTS_SETTED:
				{
					workArea.skin.currentState = "normal"; //TODO: добавить public свойство для изменения внутреннего state
					break;
				}
			}
		}

		private function addHandlers() : void
		{
			workArea.addEventListener( WorkAreaEvent.SAVE, saveHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.UNDO, undoHandler, false, 0, true );
			workArea.addEventListener( WorkAreaEvent.SHOW_ELEMENTS, showHandler, false, 0, true );
			workArea.addEventListener( ElementEvent.SHOW_ELEMENT, showElementHandler, true );
		}

		private function removeHandlers() : void
		{
			//  addEventListener || remouve ? 
			workArea.removeEventListener( WorkAreaEvent.SAVE, saveHandler );
			workArea.removeEventListener( WorkAreaEvent.UNDO, undoHandler );
			workArea.removeEventListener( WorkAreaEvent.SHOW_ELEMENTS, showHandler );
			workArea.removeEventListener( ElementEvent.SHOW_ELEMENT, showElementHandler, true );
		}
		
		private function setVisibleElement() : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var i : Number;
			var element : Object;
			var actionElement : ActionElement;
			var eventElement : EventElement;
			var showNotVisible : Boolean = visibleElementProxy.getShowNotVisible();
			workArea.showElement.selected = showNotVisible;
			for ( i = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i );
				if ( element is ActionElement )
				{
					actionElement = element as ActionElement;
					actionElement.showElements = visibleElementProxy.getVisible( actionElement.idElement );
					if ( !showNotVisible )
						actionElement.visibleElements = visibleElementProxy.getVisible( actionElement.idElement );
				}
				else if ( element is EventElement )
				{
					eventElement = element as EventElement;
					eventElement.showElements = visibleElementProxy.getVisible( eventElement.idElement );
					if ( !showNotVisible )
						eventElement.visibleElements = visibleElementProxy.getVisible( eventElement.idElement );
				}
			}
			workArea.setVisibleLinkage( showNotVisible );
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
		
		private function showHandler( event : WorkAreaEvent ) : void
		{
			setShow();
		}
		
		private function setShow() : void
		{
			var leng : Number = workArea.contentGroup.numElements;
			var i : Number;
			var element : Object;
			var actionElement : ActionElement;
			var eventElement : EventElement;
			var showNotVisible : Boolean = workArea.showElement.selected;
			visibleElementProxy.setShowNotVisible( showNotVisible );
			for ( i = 0; i < leng; i++ )
			{
				element = workArea.contentGroup.getElementAt( i );
				if ( element is ActionElement )
				{
					actionElement = element as ActionElement;
					actionElement.showElements = visibleElementProxy.getVisible( actionElement.idElement );
					if ( !showNotVisible )
						actionElement.visibleElements = visibleElementProxy.getVisible( actionElement.idElement );
					else
						actionElement.visibleElements = true;
				}
				else if ( element is EventElement )
				{
					eventElement = element as EventElement;
					eventElement.showElements = visibleElementProxy.getVisible( eventElement.idElement );
					if ( !showNotVisible )
						eventElement.visibleElements = visibleElementProxy.getVisible( eventElement.idElement );
					else
						eventElement.visibleElements = true;
				}
			}
			workArea.setVisibleLinkage( showNotVisible );
		}
		
		private function showElementHandler( event : ElementEvent ) : void
		{
			var element : Object = event.target;
			if ( element is ActionElement )
			{
				var actionElement : ActionElement = element as ActionElement;
				visibleElementProxy.setVisible( actionElement.idElement, actionElement.showElements );
			}
			else if ( element is EventElement )
			{
				var eventElement : EventElement = element as EventElement;
				visibleElementProxy.setVisible( eventElement.idElement, eventElement.showElements );
			}
			setShow();
		}
	}
}