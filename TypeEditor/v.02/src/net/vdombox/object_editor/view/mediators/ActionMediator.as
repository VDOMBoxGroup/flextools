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
	import net.vdombox.object_editor.model.vo.ActionsContainerVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Actions;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;
	
	import spark.components.ComboBox;
	import spark.components.List;

	public class ActionMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ActionMediator";
		private var objectTypeVO:ObjectTypeVO;
		private var currentContainerVO: ActionsContainerVO;
		private var currentActionVO   : ActionVO;
		private var currentParameterVO: ActionParameterVO ;

		public function ActionMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showActions );
			view.addEventListener( Event.CHANGE, validateObjectTypeVO );
		}
		
		private function showActions(event: FlexEvent): void
		{			
			view.removeEventListener( FlexEvent.SHOW, showActions );
			view.containersList.dataProvider = objectTypeVO.actionContainers;
			view.containersList.selectedIndex = 0;
			currentContainerVO = objectTypeVO.actionContainers[0].data;
			
			var itemProxy:ItemProxy = facade.retrieveProxy( ItemProxy.NAME ) as ItemProxy;
			//			view.containersList.dataProvider = objectTypeVO.actionContainers.container
			//			view.container.dataProvider = itemProxy.topLevelContainerList;
			//			view.container.selectedItem = getItemContainerOnID(objectTypeVO.actions.container);//itemProxy.topLevelContainerList//objectTypeVO.actions.container;
			//			view.container.addEventListener   	 ( Event.CHANGE, changeContainer );
			view.addContainer.addEventListener   ( MouseEvent.CLICK, addContainer );
			view.deleteContainer.addEventListener( MouseEvent.CLICK, deleteContainer );
			view.addAction.addEventListener   	 ( MouseEvent.CLICK, addAction );
			view.deleteAction.addEventListener	 ( MouseEvent.CLICK, deleteAction );
			view.addParameter.addEventListener   ( MouseEvent.CLICK, addParameter );
			view.deleteParameter.addEventListener( MouseEvent.CLICK, deleteParameter );
			view.actionsList.addEventListener    (Event.CHANGE, selectAction);
			view.parametersList.addEventListener (Event.CHANGE, selectParameter);
			view.containersList.addEventListener (Event.CHANGE, selectContainer);
			
			view.methodName.addEventListener     (Event.CHANGE, changeMethodName);
			view.parScriptName.addEventListener  (Event.CHANGE, changeScriptName);
			
			compliteActions();
			view.validateNow();
		}
		
		private function selectContainer(event:Event):void
		{ 
			currentContainerVO = view.containersList.selectedItem.data as ActionsContainerVO;
			fillContainerFilds(currentContainerVO);	
		}

		private function selectAction(event:Event):void
		{ 
			currentActionVO = view.actionsList.selectedItem.data as ActionVO;
			fillActionFilds(currentActionVO);	
		}

		private function selectParameter(event:Event):void
		{ 
			currentParameterVO = view.parametersList.selectedItem.data as ActionParameterVO;
			fillParameter(currentParameterVO);	
		}

		public function validateObjectTypeVO(event:Event):void
		{
			view.label= "Actions*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
			if( currentParameterVO )
			{				
				currentParameterVO.defaultValue	= view.parDefaultValue.text;
				currentParameterVO.interfacePar	= view.parInterface.text;
				currentParameterVO.interfaceName= view.parInterfaceName.text;
				currentParameterVO.scriptName	= view.parScriptName.text;
				currentParameterVO.help	 		= view.parHelp.text;
				currentParameterVO.regExp	 	= view.parRegExp.text;
			}
		}

		private function changeMethodName ( event:Event ):void
		{ 
			view.currentAction.label   = event.target.text;
			currentActionVO.methodName = view.methodName.text;
			view.actionsList.dataProvider.itemUpdated(view.currentAction);
			sortActions();
			view.actionsList.selectedItem = view.currentAction;
			view.actionsList.ensureIndexIsVisible(view.actionsList.selectedIndex);
		}
		
		private function changeScriptName ( event:Event ):void
		{ 
			view.currentParameter.label   = event.target.text;
			currentParameterVO.scriptName = view.parScriptName.text;
			view.parametersList.dataProvider.itemUpdated(view.currentParameter);
			sortParameters();
			view.parametersList.selectedItem = view.currentParameter;
			view.parametersList.ensureIndexIsVisible(view.parametersList.selectedIndex);
		}
		
		private function changeField ( event:Event ):void
		{ 
			//todo добавить слушателя на view и реализовать метод для все полей оставшихся
		}
		
		private function fillContainerFilds(actConVO:ActionsContainerVO):void
		{
			view.actionsList.dataProvider = actConVO.actionsCollection;
		}
		
		private function fillActionFilds(actVO:ActionVO):void
		{
			view.methodName.text			= actVO.methodName;
			view.sourceCode.text			= actVO.code;
			view.parametersList.dataProvider	= actVO.parameters; 
			
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
		
		/*private function getItemContainerOnID(id:String): Object
		{
			for each(var container:Object in view.actionsList.dataProvider )
			{
				if( container["data"] == id )
				{
					return container;
					break;
				}
			}
			return new Object();
		}*/
		
		private function addContainer(event:MouseEvent): void
		{			
			var actsContVO:ActionsContainerVO = new ActionsContainerVO();
			actsContVO.containerID = "0";//todo выбор из comboBox
			objectTypeVO.actionContainers.addItem( {label:actsContVO.containerID, data:actsContVO} );
				
			currentContainerVO  = actsContVO;
			currentActionVO		= null;
			currentParameterVO	= null;
			
			view.clearContainerFields();
			
			view.containersList.selectedItem = view.currentContainer;
			view.containersList.validateNow();
		}

		private function addAction(event:MouseEvent): void
		{			
			currentActionVO = new ActionVO();
			currentActionVO.methodName = ( "methodName" + currentContainerVO.actionsCollection.length );
			
			currentContainerVO.actionsCollection.addItem( {label:currentActionVO.methodName, data:currentActionVO} );
			currentParameterVO	= null;
			
			fillActionFilds(currentActionVO);
			view.currentAction = getCurrentAction(currentActionVO.methodName);
//			view.actionsList.dataProvider.addItem( {label: currentActionVO.methodName, data: currentActionVO} );
//			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
//todo			eventVO.help = langsProxy.getNextId(objectTypeVO.languages, "3");
			view.actionsList.selectedItem = view.currentAction;
			view.actionsList.validateNow();
		}
		
		private function addParameter(event:MouseEvent): void
		{			
			currentParameterVO = new ActionParameterVO();
			currentParameterVO.scriptName = ( "scriptName" + currentActionVO.parameters.length );
			
			currentActionVO.parameters.addItem( {label:currentParameterVO.scriptName, data:currentParameterVO} );
//			var langsProxy:LanguagesProxy = facade.retrieveProxy( LanguagesProxy.NAME ) as LanguagesProxy;
//todo			eventVO.help = langsProxy.getNextId(objectTypeVO.languages, "3");
			fillParameter(currentParameterVO);
			view.currentParameter = getCurrentParameter(currentParameterVO.scriptName);
			view.parametersList.selectedItem = view.currentParameter;
			view.parametersList.validateNow();
		}
		
		private function deleteContainer(event:MouseEvent): void
		{
			var selectInd:uint = view.containersList.selectedIndex;
			objectTypeVO.actionContainers.removeItemAt(selectInd);
		}

		private function deleteAction(event:MouseEvent): void
		{
			var selectInd:uint = view.actionsList.selectedIndex;
			currentContainerVO.actionsCollection.removeItemAt(selectInd);
		}

		private function deleteParameter(event:MouseEvent): void
		{
			var selectInd:uint = view.parametersList.selectedIndex;
			currentActionVO.parameters.removeItemAt(selectInd);
		}

		private function getCurrentAction(methodName:String):Object
		{			
			for each(var act:Object in currentContainerVO.actionsCollection )
			{
				if( act["label"] == methodName )
				{
					return act;
					break;
				}
			}
			return new Object();
		}

		private function getCurrentParameter(nameParam:String):Object
		{			
			for each(var param:Object in currentActionVO.parameters )
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
			currentContainerVO.actionsCollection.sort 		 = new Sort();
			currentContainerVO.actionsCollection.sort.fields = [ new SortField( 'label' ) ];
			currentContainerVO.actionsCollection.refresh();
		}

		private function sortParameters():void
		{
		   currentActionVO.parameters.sort 		  = new Sort();
		   currentActionVO.parameters.sort.fields = [ new SortField( 'label' ) ];
		   currentActionVO.parameters.refresh();
		 }

		protected function compliteActions( ):void
		{	
			sortActions();
			view.actionsList.dataProvider = currentContainerVO.actionsCollection;
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