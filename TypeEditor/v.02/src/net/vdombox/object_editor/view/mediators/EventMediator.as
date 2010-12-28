package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.collections.Sort;
	import mx.collections.SortField;
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
		private var curentEventVO: EventVO;
		private var curentParameterVO: EventParameterVO ;

		public function EventMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showEvents );
			view.addEventListener( Event.CHANGE, validateObjectTypeVO );
		}

		private function selectEvent(event:Event):void
		{ 

			curentEventVO = view.eventsList.selectedItem.data as EventVO;
			fillFilds(curentEventVO);	
		}

		private function selectParameter(event:Event):void
		{ 
			curentParameterVO = view.parameters.selectedItem.data as EventParameterVO;
			fillParameter(curentParameterVO);	
		}

		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Events*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( curentParameterVO )
			{				
				curentParameterVO.name	 = view.parName.text;
				curentParameterVO.order	 = view.parOrder.text;
				curentParameterVO.vbType = view.parVbType.text;
//todo			curentParameterVO.help	= view.parName.text;
			}
		}

		private function changeName( event:Event ):void
		{ 
			view.currentItem.label = event.target.text;

			curentEventVO.name = view.eventName.text;
			view.eventsList.dataProvider.itemUpdated(view.currentItem);
			sortEvents();
			view.eventsList.selectedItem = view.currentItem;
			view.eventsList.ensureIndexIsVisible(view.eventsList.selectedIndex);//(view.attributesList.selectedIndex);
			//			view.attributesList.selectedItems //scrollRect = view.currentItem;			
		}

		private function fillFilds(eventVO:EventVO):void
		{
			view.eventName.text	= eventVO.name;
			view.parameters.dataProvider	= eventVO.parameters; 
		/*	var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
		   view.help.completeStructure    ( objectTypeVO.languages, attributeVO.help );
		 */	
		}

		private function fillParameter(parameterVO:EventParameterVO):void
		{
			view.parName.text	= parameterVO.name;
			view.parOrder.text	= parameterVO.order;
			view.parVbType.text	= parameterVO.vbType;

			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
			view.parHelp.completeStructure( objectTypeVO.languages, parameterVO.help );
		}

		private function showEvents(event: FlexEvent): void
		{			
			view.removeEventListener( FlexEvent.SHOW, showEvents );

			view.eventsList.addEventListener(Event.CHANGE, selectEvent);

			view.eventName.addEventListener  ( Event.CHANGE, changeName );
			view.addEvent.addEventListener   ( MouseEvent.CLICK, addEvent );
			view.deleteEvent.addEventListener( MouseEvent.CLICK, deleteEvent );
			view.addParameter.addEventListener   ( MouseEvent.CLICK, addParameter );
			view.deleteParameter.addEventListener( MouseEvent.CLICK, deleteParameter );
			view.parameters.addEventListener(Event.CHANGE, selectParameter);

			compliteEvents();
			view.validateNow();
		}

		private function addEvent(event:MouseEvent): void
		{			
			var eventVO:EventVO = new EventVO( "newEvent"+ Math.round(Math.random()*100) );
			objectTypeVO.events.addItem( {label:eventVO.name, data:eventVO} );
			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
//todo			eventVO.help = langsProxy.getNextId(objectTypeVO.languages, "3");
			fillFilds(eventVO);
			view.currentItem = getCurrentItem(eventVO.name);
			curentEventVO = view.currentItem.data;

			view.eventsList.selectedItem = view.currentItem;
			view.eventsList.validateNow();
//todo			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}

		private function addParameter(event:MouseEvent): void
		{			
			var parameterVO:EventParameterVO = new EventParameterVO( "newParameter"+ Math.round(Math.random()*100) );
			curentEventVO.parameters.addItem( {label:parameterVO.name, data:parameterVO} );
			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
//todo			eventVO.help = langsProxy.getNextId(objectTypeVO.languages, "3");
			fillParameter(parameterVO);
			view.currentParameter = getCurrentParameter(parameterVO.name);
			view.parameters.selectedItem = view.currentParameter;
			view.parameters.validateNow();
			//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}

		private function deleteEvent(event:MouseEvent): void
		{
			var selectInd:uint = view.eventsList.selectedIndex;
			objectTypeVO.events.removeItemAt(selectInd);
		}

		private function deleteParameter(event:MouseEvent): void
		{
			var selectInd:uint = view.parameters.selectedIndex;
			curentEventVO.parameters.removeItemAt(selectInd);
		}

		private function getCurrentItem(nameEvent:String):Object
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
			for each(var param:Object in curentEventVO.parameters )
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
		}		
		override public function listNotificationInterests():Array 
		{			
			return [ ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ObjectViewMediator.OBJECT_TYPE_VIEW_SAVED:
					if (objectTypeVO == note.getBody() )
						view.label= "Events";
					break;	
			}
		}

		protected function get view():Events
		{
			return viewComponent as Events;
		}
	}
}

