package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Label;
	import mx.events.FlexEvent;
	
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
			view.addEventListener( Event.CHANGE, validateObjectTypeVO );
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
		
		private function setCurrentParameter(listIndex:int = 0):void
		{
			if ( listIndex < 0 )
			{
				listIndex = 0;
			}
			if( currentEventVO.parameters.length > 0 )
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

		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Events*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( currentParameterVO )
			{				
				currentParameterVO.name	  = view.parName.text;
				currentParameterVO.order  = view.parOrder.text;
				currentParameterVO.vbType = view.parVbType.text;
//todo			currentParameterVO.help	  = view.parName.text;
			}
		}

		private function changeName( event:Event ):void
		{ 
			view.currentEvent.label = event.target.text;

			currentEventVO.name = view.eventName.text;
			view.eventsList.dataProvider.itemUpdated(view.currentEvent);
			sortEvents();
			view.eventsList.selectedItem = view.currentEvent;
			view.eventsList.ensureIndexIsVisible(view.eventsList.selectedIndex);//(view.attributesList.selectedIndex);
			//			view.attributesList.selectedItems //scrollRect = view.currentItem;			
		}

		private function fillEventFilds(eventVO:EventVO):void
		{
			view.eventName.text	= eventVO.name;
			view.parametersList.dataProvider = eventVO.parameters; 
		}

		private function fillParameter(parameterVO:EventParameterVO):void
		{
			view.parName.text	= parameterVO.name;
			view.parOrder.text	= parameterVO.order;
			view.parVbType.text	= parameterVO.vbType;

			view.parHelp.completeStructure( objectTypeVO.languages, parameterVO.help );
		}

		private function showEvents(event: FlexEvent): void
		{			
			view.removeEventListener( FlexEvent.SHOW, showEvents );
			view.eventsList.addEventListener(Event.CHANGE, selectEvent);

			view.eventName.addEventListener  	 ( Event.CHANGE, changeName );
			view.addEvent.addEventListener   	 ( MouseEvent.CLICK, addEvent );
			view.deleteEvent.addEventListener	 ( MouseEvent.CLICK, deleteEvent );
			view.addParameter.addEventListener   ( MouseEvent.CLICK, addParameter );
			view.deleteParameter.addEventListener( MouseEvent.CLICK, deleteParameter );
			view.parametersList.addEventListener ( Event.CHANGE, selectParameter );

			compliteEvents();
			view.validateNow();
		}

		private function addEvent(event:MouseEvent): void
		{			
			var eventVO:EventVO = new EventVO( "newEvent" + objectTypeVO.events.length );
			objectTypeVO.events.addItem( {label:eventVO.name, data:eventVO} );
			view.clearEventFields();
			fillEventFilds(eventVO);
			view.currentEvent = getCurrentEvent(eventVO.name);
			currentEventVO    = view.currentEvent.data;

			view.eventsList.selectedItem = view.currentEvent;
			view.eventsList.validateNow();
			
//todo		view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}

		private function addParameter(event:MouseEvent): void
		{			
			var parameterVO:EventParameterVO = new EventParameterVO( "newParameter" + currentEventVO.parameters.length );
			currentEventVO.parameters.addItem( {label:parameterVO.name, data:parameterVO} );
			parameterVO.help = languagesProxy.getNextId(objectTypeVO.languages, "3", "help for "+parameterVO.name);
			fillParameter(parameterVO);
			view.currentParameter = getCurrentParameter(parameterVO.name);
			view.parametersList.selectedItem = view.currentParameter;
			view.parametersList.validateNow();
//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}

		private function deleteEvent(event:MouseEvent): void
		{
			var selectInd:int = view.eventsList.selectedIndex;
			objectTypeVO.events.removeItemAt(selectInd);
			selectInd --;
			setCurrentEvent(selectInd - 1);
		}
		 
		private function setCurrentEvent(listIndex:int = 0):void
		{
			if (listIndex < 0)
			{
				listIndex = 0;
			}
			if ( objectTypeVO.events.length > 0 )
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

		private function deleteParameter(event:MouseEvent): void
		{
			var selectInd:int = view.parametersList.selectedIndex;
			currentEventVO.parameters.removeItemAt(selectInd);
			setCurrentParameter(selectInd - 1);
		}

		private function getCurrentEvent(nameEvent:String):Object
		{			
			for each(var event:Object in objectTypeVO.events )
			{
				if( event["label"] == nameEvent )
				{
					return event;
					break;
				}
			}
			return new Object();
		}

		private function getCurrentParameter(nameParam:String):Object
		{			
			for each(var param:Object in currentEventVO.parameters )
			{
				if( param["label"] == nameParam )
				{
					return param;
					break;
				}
			}
			return new Object();
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

		protected function compliteEvents( ):void
		{	
			sortEvents();
			view.eventsList.dataProvider = objectTypeVO.events;
			setCurrentEvent();
		}		
		override public function listNotificationInterests():Array 
		{			
			return [ ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED, ApplicationFacade.CHANGE_CURRENT_LANGUAGE ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
					if (objectTypeVO == note.getBody() )
						view.label= "Events";
					break;	
				case ApplicationFacade.CHANGE_CURRENT_LANGUAGE:
					if( view.eventsList ) 
						changeFildWithCurrentLanguage( );
					break;
			}
		}
		
		private function changeFildWithCurrentLanguage( ):void
		{
			view.parHelp.currentLanguage = objectTypeVO.languages.currentLocation;
			view.parHelp.apdateFild();
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