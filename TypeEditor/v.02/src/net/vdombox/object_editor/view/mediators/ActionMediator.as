/*
	Class ActionMediator is a wrapper over the Actions.mxml
*/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.collections.ArrayCollection;
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.controls.Alert;
	import mx.events.CloseEvent;
	import mx.events.FlexEvent;
	import mx.managers.PopUpManager;
	import mx.rpc.events.HeaderEvent;

	import net.vdombox.object_editor.model.proxy.ObjectsProxy;
	import net.vdombox.object_editor.model.proxy.componentsProxy.LanguagesProxy;
	import net.vdombox.object_editor.model.vo.ActionParameterVO;
	import net.vdombox.object_editor.model.vo.ActionVO;
	import net.vdombox.object_editor.model.vo.ActionsContainerVO;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.essence.Actions;
	import net.vdombox.object_editor.view.popups.ChangeWord;
	import net.vdombox.object_editor.view.popups.Containers;

	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.mediator.Mediator;

	import spark.components.ComboBox;
	import spark.components.List;
	import spark.effects.SetAction;

	public class ActionMediator extends Mediator implements IMediator
	{
		public static const NAME:String = "ActionMediator";
		private var objectTypeVO:ObjectTypeVO;
		private var currentContainerVO: ActionsContainerVO;
		private var currentActionVO   : ActionVO;
		private var currentParameterVO: ActionParameterVO ;
		private var isActionsSort:   Boolean = false;
		private var isParametersSort:Boolean = false;

		public function ActionMediator( viewComponent:Object, objTypeVO:ObjectTypeVO ) 
		{			
			super( NAME+objTypeVO.id, viewComponent );
			this.objectTypeVO = objTypeVO;	
			view.addEventListener( FlexEvent.SHOW, showActions );
			view.addEventListener( Event.CHANGE,   validateObjectTypeVO );
		}

		private function showActions(event: FlexEvent): void
		{			
			view.removeEventListener( FlexEvent.SHOW, showActions );
			setCurrentContainer();

			view.addContainerButton.addEventListener   	( MouseEvent.CLICK, addContainer );
			view.deleteContainerButton.addEventListener	( MouseEvent.CLICK, deleteContainer );
			view.addAction.addEventListener   	 		( MouseEvent.CLICK, addAction );
			view.deleteAction.addEventListener	 		( MouseEvent.CLICK, deleteAction );
			view.addParameter.addEventListener   		( MouseEvent.CLICK, addParameter );
			view.deleteParameter.addEventListener		( MouseEvent.CLICK, deleteParameter );
			view.actionsList.addEventListener    		( Event.CHANGE, 	selectAction );
			view.parametersList.addEventListener 		( Event.CHANGE, 	selectParameter );
			view.containersList.addEventListener 		( Event.CHANGE, 	selectContainer );

			view.methodName.addEventListener     		( Event.CHANGE, 	changeMethodName );
			view.parScriptName.addEventListener  		( Event.CHANGE, 	changeScriptName );

			view.validateNow();
		}

		private function selectContainer(event:Event):void
		{ 
			currentContainerVO = view.containersList.selectedItem.data as ActionsContainerVO;
			if (currentContainerVO)
			{
				fillContainerFilds(currentContainerVO);
				setCurrentAction();
			}
			else
			{
				currentActionVO    = null;
				currentParameterVO = null;
				view.clearContainerFields();
			}
		}

		private function selectAction(event:Event):void
		{ 
			currentActionVO = view.actionsList.selectedItem.data as ActionVO;
			fillActionFilds(currentActionVO);
			setCurrentParameter();
		}

		private function selectParameter(event:Event):void
		{ 
			currentParameterVO = view.parametersList.selectedItem.data as ActionParameterVO;
			fillParameter(currentParameterVO);	
		}

		public function validateObjectTypeVO(event:Event):void
		{
			addStar();
			if (currentParameterVO)
			{				
				currentParameterVO.defaultValue		= view.parDefaultValue.text;
				currentParameterVO.interfacePar		= view.parInterface.text;
				//currentParameterVO.scriptName		= view.parScriptName.text;
				currentParameterVO.regExp	 		= view.parRegExp.text;
			}
			if (currentActionVO)
			{
				currentActionVO.code				= view.sourceCode.text;				
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

		//всегда ведь текущее событие! можно и без параметров сдеать функцию
		private function fillContainerFilds(actConVO:ActionsContainerVO):void
		{
			view.actionsList.dataProvider = actConVO.actionsCollection;			
		}

		private function fillActionFilds(actVO:ActionVO):void
		{
			view.methodName.text			 = actVO.methodName;
			view.sourceCode.text			 = actVO.code;
			view.parametersList.dataProvider = actVO.parameters; 

			view.description.completeStructure    ( objectTypeVO.languages, actVO.description );
			view.interfaceName.completeStructure  ( objectTypeVO.languages, actVO.interfaceName );
		}

		private function fillParameter(actParameterVO:ActionParameterVO):void
		{
			view.parDefaultValue.text	= actParameterVO.defaultValue;
			view.parInterface.text		= actParameterVO.interfacePar;
			view.parRegExp.text			= actParameterVO.regExp;
			view.parScriptName.text		= actParameterVO.scriptName;

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
			addStar();
			var popup:Containers = Containers(PopUpManager.createPopUp(view, Containers, true));
			popup.addEventListener(FlexEvent.CREATION_COMPLETE, setListWord);
			popup.addEventListener(CloseEvent.CLOSE, closeHandler);

			function setListWord(event:FlexEvent):void
			{				
				popup.showContainersList( objectsProxy.topLevelContainerList );	
			}
			
			function closeHandler(event:CloseEvent):void
			{
				var container:Object = event.target.container;					
				if (container == null)
					return;

				var actsContVO:ActionsContainerVO = new ActionsContainerVO();

				if (container)
				{
					actsContVO.containerID = container.data;
					objectTypeVO.actionContainers.addItem( {label:actsContVO.containerID, data:actsContVO} );

					currentContainerVO  = actsContVO;
					currentActionVO		= null;
					currentParameterVO	= null;

					view.clearContainerFields();					
					view.currentContainer = actsContVO;					
					setLabel( objectTypeVO.actionContainers );/*
					   if(view.containersList.dataProvider == null)
					   {
					   setLabel( objectTypeVO.actionContainers );
					   }
					   else
					   {
					   view.containersList.dataProvider.addItem( getContObj(container));
					 }*/				
					view.containersList.selectedIndex = view.containersList.dataProvider.length - 1;
					view.containersList.validateNow();
					view.actionsList.dataProvider = currentContainerVO.actionsCollection;
					view.validateNow();				
				}					
			}		
		}	

		private function addAction(event:MouseEvent): void
		{				
			if (currentContainerVO)
			{
				addStar();
				currentActionVO = new ActionVO();
				currentActionVO.methodName 	  = ( "methodName" + currentContainerVO.actionsCollection.length );
				currentActionVO.description   = languagesProxy.getNextId(objectTypeVO.languages, "6", currentActionVO.methodName+"description");
				currentActionVO.interfaceName = languagesProxy.getNextId(objectTypeVO.languages, "7", currentActionVO.methodName+"interfaceName");

				currentContainerVO.actionsCollection.addItem( {label:currentActionVO.methodName, data:currentActionVO} );
				currentParameterVO	= null;

				fillActionFilds(currentActionVO);
				view.currentAction = getCurrentAction(currentActionVO.methodName);
				view.actionsList.selectedItem = view.currentAction;
				view.description.completeStructure   ( objectTypeVO.languages, currentActionVO.description);		
				view.interfaceName.completeStructure ( objectTypeVO.languages, currentActionVO.interfaceName);

				view.actionsList.validateNow();
			}
			else
			{
				Alert.show("Add container");
			}
		}

		private function addParameter(event:MouseEvent): void
		{				
			if (currentActionVO == null)
			{
				Alert.show("Add action");
			}
			else
			{
				addStar();
				currentParameterVO = new ActionParameterVO();
				currentParameterVO.scriptName = ( "scriptName" + currentActionVO.parameters.length );

				currentActionVO.parameters.addItem( {label:currentParameterVO.scriptName, data:currentParameterVO} );
				currentParameterVO.help = languagesProxy.getNextId(objectTypeVO.languages, "8", currentParameterVO.scriptName+"help");
				currentParameterVO.interfaceName = languagesProxy.getNextId(objectTypeVO.languages, "9", currentParameterVO.scriptName+"interfaceName"); 

				fillParameter(currentParameterVO);
				view.currentParameter = getCurrentParameter(currentParameterVO.scriptName);
				view.parametersList.selectedItem = view.currentParameter;
				view.parHelp.completeStructure ( objectTypeVO.languages, currentParameterVO.help);		
				view.parInterfaceName.completeStructure ( objectTypeVO.languages, currentParameterVO.interfaceName);
				view.parametersList.validateNow();
			}
		}

		private function deleteContainer(event:MouseEvent): void
		{
			addStar();
			var selectInd:uint = view.containersList.selectedIndex;
			var actsCount:int = currentContainerVO.actionsCollection.length;
			for (var i:int; i < actsCount; i++)
			{	
				view.actionsList.selectedIndex = 0;
				deleteAction();
			}
			objectTypeVO.actionContainers.removeItemAt(selectInd);
			view.containersList.dataProvider.removeItemAt(selectInd);
			setCurrentContainer(selectInd - 1);
		}

		private function deleteAction(event:MouseEvent = null): void
		{
			addStar();
			var selectInd:uint = view.actionsList.selectedIndex;
			languagesProxy.deleteWord(objectTypeVO, currentActionVO.description);
			languagesProxy.deleteWord(objectTypeVO, currentActionVO.interfaceName);
			var parsCount:int = currentActionVO.parameters.length
			for (var i:int; i < parsCount; i++)
			{	
				view.parametersList.selectedIndex = 0;
				deleteParameter();
			}
			currentContainerVO.actionsCollection.removeItemAt(selectInd);
			setCurrentAction( selectInd - 1);
		}

		private function deleteParameter(event:MouseEvent = null): void
		{
			addStar();
			var selectInd:uint = view.parametersList.selectedIndex;
			languagesProxy.deleteWord(objectTypeVO, currentActionVO.parameters[selectInd].data.help);
			languagesProxy.deleteWord(objectTypeVO, currentActionVO.parameters[selectInd].data.interfaceName);
			currentActionVO.parameters.removeItemAt(selectInd);
			if (event)
			{
				setCurrentParameter(selectInd - 1);
			}
		}

		private function getCurrentAction(methodName:String):Object
		{			
			for each (var act:Object in currentContainerVO.actionsCollection )
			{
				if (act["label"] == methodName)
				{
					return act;
					break;
				}
			}
			return {};
		}

		private function getCurrentParameter(nameParam:String):Object
		{			
			for each (var param:Object in currentActionVO.parameters)
			{
				if ( param["label"] == nameParam )
				{
					return param;
					break;
				}
			}
			return {};
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

		protected function compliteActions():void
		{	
			if (objectTypeVO.actionContainers.length > 0)
			{
				sortActions();
				view.actionsList.dataProvider = currentContainerVO.actionsCollection;
			}
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
				{
					if (objectTypeVO == note.getBody() )
						view.label= "Actions";
					break;
				}
					
				case ApplicationFacade.CHANGE_CURRENT_LANGUAGE:
				{
					if( view.description) 
						changeFildWithCurrentLanguage( );
					break;
				}
			}
		}

		private function changeFildWithCurrentLanguage( ):void
		{
			view.description.currentLanguage = objectTypeVO.languages.currentLocation;
			view.description.apdateFild();

			view.interfaceName.currentLanguage = objectTypeVO.languages.currentLocation;
			view.interfaceName.apdateFild();

			view.parHelp.currentLanguage = objectTypeVO.languages.currentLocation;
			view.parHelp.apdateFild();

			view.parInterfaceName.currentLanguage = objectTypeVO.languages.currentLocation;
			view.parInterfaceName.apdateFild();
		}		

		private function setLabel(actionContainers:ArrayCollection):void
		{
			var arr:ArrayCollection = new ArrayCollection();
			for each (var obj:Object in actionContainers)
			{
				arr.addItem(getContObj(obj));
				view.containersList.dataProvider = arr;
			}
		}

		private function getContObj (obj:Object):Object
		{
			var containerName:String = "";
			for each (var item:Object in objectsProxy.topLevelContainerList)
			{
				if (item.data == obj.label)
				{
					containerName = item.label;
					break;	
				}						
			}
			if(containerName != "")
			{
				return {label: containerName, data: obj.data}
			}
			else
			{
				return obj
			}
		}

		private function setCurrentContainer(listIndex:int = 0):void
		{		
			if (listIndex < 0)
			{
				listIndex = 0;
			}
			if (objectTypeVO.actionContainers.length > 0)
			{
				currentContainerVO	= objectTypeVO.actionContainers[listIndex].data;
				view.containersList.validateNow();
				setLabel( objectTypeVO.actionContainers );
				view.containersList.validateNow();
				view.containersList.selectedIndex = listIndex;
				view.currentContainer = view.containersList.dataProvider[listIndex];

				if (!isActionsSort)
				{
					compliteActions();
					isActionsSort = true;
				}
				setCurrentAction();
			}
			else
			{
				view.clearContainerFields();
			}
			view.validateNow();
			view.containersList.validateNow();
		}	

		private function setCurrentAction(listIndex:int = 0):void
		{
			if (listIndex < 0)
			{
				listIndex = 0;
			}
			if (currentContainerVO.actionsCollection.length > 0)
			{
				currentActionVO		= currentContainerVO.actionsCollection[listIndex].data;
				view.actionsList.dataProvider  = currentContainerVO.actionsCollection;
				view.actionsList.validateNow();
				view.actionsList.selectedIndex = listIndex;
				view.currentAction = view.actionsList.dataProvider[listIndex];
				fillActionFilds( currentActionVO );
				setCurrentParameter();
			}
			else
			{
				view.clearActionFields();
				view.currentAction	  = null;
				view.currentParameter = null;
				currentActionVO		  = null;
				currentParameterVO	  = null;
			}
		}

		private function setCurrentParameter(listIndex:int = 0):void
		{
			if (!isParametersSort)
			{
				sortParameters();	
				isParametersSort = true;
			}
			if (listIndex < 0)
			{
				listIndex = 0;
			}
			if (currentActionVO.parameters.length > 0)
			{				
				currentParameterVO  = currentActionVO.parameters[listIndex].data;
				view.parametersList.dataProvider  = currentActionVO.parameters;
				view.parametersList.validateNow();
				view.parametersList.selectedIndex = listIndex;
				view.currentParameter = view.parametersList.dataProvider[0];
				fillParameter( currentParameterVO );
			}
			else
			{
				view.clearParameterFields();
				view.currentParameter = null;
				currentParameterVO	  = null;
			}
		}				

		protected function addStar():void
		{
			view.label= "Actions*";			
			facade.sendNotification( ObjectViewMediator.OBJECT_TYPE_CHAGED, objectTypeVO);
		}
		
		protected function get view():Actions
		{
			return viewComponent as Actions;
		}

		private function get languagesProxy():LanguagesProxy
		{
			return facade.retrieveProxy(LanguagesProxy.NAME) as LanguagesProxy;
		}

		private function get objectsProxy():ObjectsProxy
		{
			return facade.retrieveProxy(ObjectsProxy.NAME) as ObjectsProxy;
		}
	}
}

