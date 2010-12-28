package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.events.FlexEvent;
	import mx.rpc.events.HeaderEvent;
	
	import net.vdombox.object_editor.model.proxy.ItemProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.ActionParameterVO;
	import net.vdombox.object_editor.model.vo.ActionVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Actions;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ActionMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ActionMediator";
		private var objectTypeVO:ObjectTypeVO;
		private var curentActionVO: ActionVO;
		private var curentParameterVO: ActionParameterVO ;

		public function ActionMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showActions );
			view.addEventListener( Event.CHANGE, validateObjectTypeVO );
		}

		private function selectAction(event:Event):void
		{ 
			curentActionVO = view.actionsList.selectedItem.data as ActionVO;
			fillFilds(curentActionVO);	
			if( (curentParameterVO = curentActionVO.parameters.getItemAt(0).data) )
			{
				view.currentParameter = {label: curentParameterVO.defaultValue, data: curentParameterVO};
				fillParameter(curentParameterVO);
				view.parameters.selectedIndex = 0;
				view.validateNow();
			}
		}

		private function selectParameter(event:Event):void
		{ 
			curentParameterVO = view.parameters.selectedItem.data as ActionParameterVO;
			fillParameter(curentParameterVO);	
		}

		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Actions*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( curentParameterVO )
			{				
				curentParameterVO.defaultValue	= view.parDefaultValue.text;
				curentParameterVO.interfacePar	= view.parInterface.text;
				curentParameterVO.interfaceName	= view.parInterfaceName.text;
				curentParameterVO.scriptName	= view.parScriptName.text;
				curentParameterVO.help	 		= view.parHelp.text;
				curentParameterVO.regExp	 	= view.parRegExp.text;
			}
		}
		
		private function changeContainer( event:Event ):void
		{ 
			objectTypeVO.actions.container = event.target.text;
		}

		/*private function changeXZ event:Event ):void
		{ 
			view.currentItem.label = event.target.text;

			curentActionVO.name = view.eventName.text;
			view.eventsList.dataProvider.itemUpdated(view.currentItem);
			sortEvents();
			view.eventsList.selectedItem = view.currentItem;
			view.eventsList.ensureIndexIsVisible(view.eventsList.selectedIndex);//(view.attributesList.selectedIndex);
			//			view.attributesList.selectedItems //scrollRect = view.currentItem;			
		}*/

		private function fillFilds(actVO:ActionVO):void
		{
			view.methodName.text	= actVO.methodName;
			view.sourceCode.text	= actVO.code;
			view.parameters.dataProvider	= actVO.parameters; 
			
			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
		    view.description.completeStructure    ( objectTypeVO.languages, actVO.description );
			view.interfaceName.completeStructure  ( objectTypeVO.languages, actVO.interfaceName );
		}

		private function fillParameter(actParameterVO:ActionParameterVO):void
		{
			view.parDefaultValue.text	= actParameterVO.defaultValue;
			view.parInterface.text		= actParameterVO.interfacePar;
			view.parRegExp.text			= actParameterVO.regExp;
			view.parScriptName.text		= actParameterVO.scriptName;

			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
			view.parHelp.completeStructure( objectTypeVO.languages, actParameterVO.help );
			view.parInterfaceName.completeStructure( objectTypeVO.languages, actParameterVO.interfaceName );
		}

		private function showActions(event: FlexEvent): void
		{			
			view.removeEventListener( FlexEvent.SHOW, showActions );
			view.actionsList.addEventListener(Event.CHANGE, selectAction);
	
			var itemProxy:ItemProxy = facade.retrieveProxy( ItemProxy.NAME ) as ItemProxy;
			view.container.dataProvider = itemProxy.topLevelContainerList;
			view.container.selectedItem = objectTypeVO.actions.container;
			view.container.addEventListener   ( Event.CHANGE, changeContainer );
			view.addAction.addEventListener   ( MouseEvent.CLICK, addAction );
			view.deleteAction.addEventListener( MouseEvent.CLICK, deleteAction );
			view.addParameter.addEventListener   ( MouseEvent.CLICK, addParameter );
			view.deleteParameter.addEventListener( MouseEvent.CLICK, deleteParameter );
			view.parameters.addEventListener(Event.CHANGE, selectParameter);

			compliteActions();
			view.validateNow();
		}

		private function addAction(event:MouseEvent): void
		{			
			var actVO:ActionVO = new ActionVO();// "newAction"+ Math.round(Math.random()*100) );
			objectTypeVO.actions.actionsCollection.addItem( {label:actVO.interfaceName, data:actVO} );
			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
//todo			eventVO.help = langsProxy.getNextId(objectTypeVO.languages, "3");
			fillFilds(actVO);
			view.currentAction = getCurrentItem(actVO.interfaceName);
			curentActionVO = view.currentAction.data;

			view.actionsList.selectedItem = view.currentAction;
			view.actionsList.validateNow();
//todo			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}

		private function addParameter(event:MouseEvent): void
		{			
			var actVO:ActionParameterVO = new ActionParameterVO( );//"newParameter"+ Math.round(Math.random()*100) );
			curentActionVO.parameters.addItem( {label:actVO.interfaceName, data:actVO} );
			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
//todo			eventVO.help = langsProxy.getNextId(objectTypeVO.languages, "3");
			fillParameter(actVO);
			view.currentParameter = getCurrentParameter(actVO.interfaceName);
			view.parameters.selectedItem = view.currentParameter;
			view.parameters.validateNow();
			//			view.attributesList.scrollToIndex(view.languagesDataGrid.selectedIndex);
		}

		private function deleteAction(event:MouseEvent): void
		{
			var selectInd:uint = view.actionsList.selectedIndex;
			objectTypeVO.events.removeItemAt(selectInd);
		}

		private function deleteParameter(event:MouseEvent): void
		{
			var selectInd:uint = view.parameters.selectedIndex;
			curentActionVO.parameters.removeItemAt(selectInd);
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
			for each(var param:Object in curentActionVO.parameters )
			{
				if( param["label"] == nameParam )
				{
					return param;
					break;
				}
			}
			return new Object();
		}

		private function sortActions():void 
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

		protected function compliteActions( ):void
		{	
			sortActions();
			view.actionsList.dataProvider = objectTypeVO.actions.actionsCollection;
//			view.eventsList.selectedIndex = 0;
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
						view.label= "Actions";
					break;	
			}
		}

		protected function get view():Actions
		{
			return viewComponent as Actions;
		}
	}
}