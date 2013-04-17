/*
	Class EventMediator is a wrapper over the Events.mxml.
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.FlexEvent;

import net.vdombox.object_editor.event.UpdateDescriptionEvent;

import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.EventParameterVO;
	import net.vdombox.object_editor.model.vo.EventVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Events;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class EventMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "EventMediator";
		private var objectTypeVO:ObjectTypeVO;
		private var currentEventVO: EventVO;
		private var currentParameterVO: EventParameterVO ;

		public function EventMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showEvents );
			view.addEventListener( Event.CHANGE,   validateObjectTypeVO );
		}
		
		private function showEvents(event: FlexEvent): void
		{			
			view.removeEventListener					( FlexEvent.SHOW, 	showEvents );			
			view.addEventButton.addEventListener   	 	( MouseEvent.CLICK, addEvent );
			view.deleteEventButton.addEventListener	 	( MouseEvent.CLICK, deleteEvent );
			view.addParameterButton.addEventListener  	( MouseEvent.CLICK, addParameter );
			view.deleteParameterButton.addEventListener	( MouseEvent.CLICK, deleteParameter );
			view.parametersList.addEventListener 		( Event.CHANGE, 	selectParameter );
			view.eventsList.addEventListener			( Event.CHANGE, 	selectEvent);			
			view.eventName.addEventListener  	 		( Event.CHANGE, 	changeEventName );
			view.parName.addEventListener 	 	 		( Event.CHANGE, 	changeParameterName );
			view.currentLocation.addEventListener		( Event.CHANGE, 	changeCurrentLocation );
			
			compliteEvents(); 
			view.validateNow();
		}
		
		protected function compliteEvents( ):void
		{	
			sortEvents();
			view.eventsList.dataProvider = objectTypeVO.events;
			
			//set currentLocation`s value 
			view.currentLocation.dataProvider = objectTypeVO.languages.locales;
			view.currentLocation.selectedItem = getLocalesItem(objectTypeVO.languages.currentLocation);
			view.currentLocation.validateNow();
			
			setCurrentEvent();
		}
		
		private function getLocalesItem(curLang:String):Object
		{
			for each (var obj:Object in objectTypeVO.languages.locales)
			{
				if (obj["label"] == curLang)
					return obj;
			}
			return {};
		}
		
		private function setCurrentEvent(listIndex:int = 0):void
		{
			if (listIndex < 0)
			{
				listIndex = 0;
			}
			if (objectTypeVO.events.length > 0)
			{				
				currentEventVO = objectTypeVO.events[listIndex].data;
				setCurrentParameter();
				fillEventFilds(currentEventVO);
				view.currentEvent = {label:currentEventVO.name, data:currentEventVO};
				view.eventsList.selectedIndex = listIndex;
				view.eventsList.validateNow();
				view.validateNow();
			}
			else
			{
				view.clearEventFields();
				view.currentEvent		= null;
				view.currentParameter	= null;
				currentEventVO			= null;
				currentParameterVO		= null;
			}
		}
		
		private function setCurrentParameter(listIndex:int = 0):void
		{
			if (listIndex < 0)
			{
				listIndex = 0;
			}
			if (currentEventVO.parameters.length > 0)
			{				
				currentParameterVO = currentEventVO.parameters[listIndex].data;
				view.parametersList.dataProvider = currentEventVO.parameters;
				view.parametersList.validateNow();
				view.parametersList.selectedIndex = listIndex;
				view.currentParameter = {label: currentParameterVO.name, data: currentParameterVO};
				fillParameter( currentParameterVO );
			}			
			else
			{
				view.clearParameterFields();
				view.currentParameter = null;
				currentParameterVO	  = null;
			}
		}

		private function selectEvent(event:Event):void
		{ 
			currentEventVO = view.eventsList.selectedItem.data as EventVO;
			fillEventFilds(currentEventVO);	
			setCurrentParameter();
		}

		private function selectParameter(event:Event):void
		{ 
			currentParameterVO = view.parametersList.selectedItem.data as EventParameterVO;
			fillParameter(currentParameterVO);	
		}
		
		public function validateObjectTypeVO(event:Event):void
		{
			addStar();
			if (currentParameterVO)
			{				
				//currentParameterVO.name	  = view.parName.text;
				currentParameterVO.order  = view.parOrder.text;
				currentParameterVO.vbType = view.parVbType.text;
			}		
		}

		private function changeEventName( event:Event ):void
		{ 		
			view.currentEvent.label = event.target.text;
			currentEventVO.name = view.eventName.text;
			view.eventsList.dataProvider.itemUpdated(view.currentEvent);
			sortEvents();
			view.eventsList.selectedItem = view.currentEvent;
			view.eventsList.ensureIndexIsVisible(view.eventsList.selectedIndex);
		}

		private function changeParameterName( event:Event ):void
		{ 
			languagesProxy.changeWordsOwner(objectTypeVO, [currentParameterVO.help], "Events.Parameter."+event.target.text);
			
			view.currentParameter.label = event.target.text;			
			currentParameterVO.name = view.parName.text;
			view.parametersList.dataProvider.itemUpdated(view.currentParameter.label);
			view.parametersList.validateNow();			
			view.parametersList.selectedItem = view.currentParameter;
			view.parametersList.ensureIndexIsVisible(view.parametersList.selectedIndex);
			view.parametersList.validateNow();
		}	
		
		private function fillEventFilds(eventVO:EventVO):void
		{
			view.eventName.text	= eventVO.name;
			view.eventHelp.completeStructure    ( objectTypeVO.languages, eventVO.help );
			view.parametersList.dataProvider = eventVO.parameters; 
		}

		private function fillParameter(parameterVO:EventParameterVO):void
		{
			view.parName.text	= parameterVO.name;
			view.parOrder.text	= parameterVO.order;
			view.parVbType.text	= parameterVO.vbType;

			view.parHelp.completeStructure( objectTypeVO.languages, parameterVO.help );
		}

		private function addEvent(event:MouseEvent): void
		{	
			addStar();
			var eventVO:EventVO = new EventVO( "newEvent" + objectTypeVO.events.length );
			objectTypeVO.events.addItem( {label:eventVO.name, data:eventVO} );
			view.clearEventFields();
			fillEventFilds(eventVO);
			view.currentEvent = getCurrentEvent(eventVO.name);
			currentEventVO    = view.currentEvent.data;

			view.eventsList.selectedItem = view.currentEvent;
			view.eventHelp.completeStructure   ( objectTypeVO.languages, currentEventVO.help);		
			view.eventsList.validateNow();
			
//todo		view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}
		
		private function addParameter(event:MouseEvent): void
		{								
			addStar();
			var parameterVO:EventParameterVO = new EventParameterVO( "newParameter" + currentEventVO.parameters.length );
			currentEventVO.parameters.addItem( {label:parameterVO.name, data:parameterVO} );
			currentParameterVO = parameterVO;
			parameterVO.help = languagesProxy.newWords(objectTypeVO.languages, "9", "Events."+parameterVO.name+"Parameter",parameterVO.name);
			fillParameter(parameterVO);
			view.currentParameter = getCurrentParameter(parameterVO.name);
			view.parametersList.selectedItem = view.currentParameter;
			view.parametersList.validateNow();
			//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);			
		}
		
		private function deleteEvent(event:MouseEvent): void
		{
			addStar();
			var selectInd:int = view.eventsList.selectedIndex;
			var parsCount:int = currentEventVO.parameters.length;
			for (var i:int; i < parsCount; i++ )
			{	
				view.parametersList.selectedIndex = 0;
				deleteParameter();
			}
			objectTypeVO.events.removeItemAt(selectInd);
			setCurrentEvent(selectInd - 1);
		}
		
		private function deleteParameter(event:MouseEvent = null): void
		{
			addStar();
			var selectInd:int = view.parametersList.selectedIndex;
			languagesProxy.deleteWord(objectTypeVO, currentEventVO.parameters[selectInd].data.help);
			currentEventVO.parameters.removeItemAt(selectInd);
			if (event)
			{
				setCurrentParameter(selectInd - 1);
			}
		}
		
		private function getCurrentEvent(nameEvent:String):Object
		{			
			for each (var event:Object in objectTypeVO.events)
			{
				if (event["label"] == nameEvent)
					return event;
			}
			return {};
		}

		private function getCurrentParameter(nameParam:String):Object
		{			
			for each (var param:Object in currentEventVO.parameters)
			{
				if (param["label"] == nameParam)
					return param;
			}
			return {};
		}

		private  function hideAttributes(event: FlexEvent):void
		{
			view.eventsList.removeEventListener(Event.CHANGE,selectEvent);
		}

		private function sortEvents():void 
		{
			objectTypeVO.events.sort = new Sort();
			objectTypeVO.events.sort.fields = [ new SortField( 'label' ) ];
			objectTypeVO.events.refresh();
		}

		/*	private function sortParameters():void
		   {
		   objectTypeVO.events.sort = new Sort();
		   objectTypeVO.events.sort.fields = [ new SortField( 'label' ) ];
		   objectTypeVO.events.refresh();
		 }*/

		override public function listNotificationInterests():Array 
		{
            var interests : Array = super.listNotificationInterests();

            interests.push( ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED );
            interests.push( ApplicationFacade.CHANGE_CURRENT_LANGUAGE );
            interests.push( UpdateDescriptionEvent.EVENTS_DESCRIPTIONS_UPDATE_COMPLETE );

            return interests;

        }

		override public function handleNotification(note:INotification):void
		{
			switch (note.getName())
			{
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
				{
					if (objectTypeVO == note.getBody())
						view.label = "Events";
					break;
				}

				case ApplicationFacade.CHANGE_CURRENT_LANGUAGE:
				{
					if (view.eventsList)						
						changeFildWithCurrentLanguage(note.getBody() as int);
					break;
				}

                case UpdateDescriptionEvent.EVENTS_DESCRIPTIONS_UPDATE_COMPLETE :
                {
                    if (currentEventVO)
                    {
                        view.eventHelp.apdateFild();
                    }
                    addStar();

                    break;
                }
			}
		}
		
		private function changeFildWithCurrentLanguage( index:int ):void
		{
			if ( currentEventVO )
			{
				view.eventHelp.currentLanguage = objectTypeVO.languages.currentLocation;
				view.eventHelp.apdateFild();
			}
			
			if (view.parHelp.words)
			{
				view.parHelp.currentLanguage = objectTypeVO.languages.currentLocation;
				view.parHelp.apdateFild();				
			}
			view.currentLocation.selectedIndex = index;
			view.currentLocation.validateNow();
		}
		
		public function changeCurrentLocation( event: Event ): void
		{
			objectTypeVO.languages.currentLocation = view.currentLocation.selectedLabel;			
			sendNotification( ApplicationFacade.CHANGE_CURRENT_LANGUAGE, view.currentLocation.selectedIndex );
		}
		
		protected function addStar():void // mark changed
		{
			view.label= "Events*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
		}
		
		private function get languagesProxy():LanguagesProxy
		{
			return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
		}

		protected function get view():Events
		{
			return viewComponent as Events;
		}
	}
}