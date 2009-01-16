package vdom.components.eventEditor
{
	import mx.collections.Sort;
	import mx.collections.SortField;
	import mx.collections.XMLListCollection;
	
	import vdom.events.DataManagerEvent;
	import vdom.managers.DataManager;
	import vdom.utils.IconUtil;
	
	public class TreeActions extends DragTree
	{
		private var dataManager:DataManager ;
	/*	
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='event')]
		[Bindable]
		public var event:Class;
		*/
		
		[Embed(source='/assets/scriptEditor/python.png')]
		[Bindable]
		public var python:Class;
		
		[Embed(source='/assets/scriptEditor/vbscript.png')]
		[Bindable]
		public var vscript:Class;
		public function TreeActions()
		{
			super();
			iconFunction = getIcon;
			
			dataManager = DataManager.getInstance();
		}
		
		private var dataXML:XMLListCollection ;
		private var curContainerTypeID:String;
	
		private function getChilds(inXML:XML):XML
		{
			var outXML:XML = new XML(inXML.toXMLString());
			var type:XML = dataManager.getTypeByTypeId(inXML.@Type);
//			var curContainerTypeID:String = dataManager.getTypeByObjectId(curContainerTypeID).Information.ID.toString();
			var actions:XML = type.E2vdom.Actions.Container.(@ID == curContainerTypeID)[0]; 
			var tempXML:XML;
			
			if(actions != null)		
			{
				for each(var child:XML in actions.children() )
				{
				 	tempXML = <Event/>;
					tempXML.@label = child.@MethodName;
					tempXML.@MethodName  = child.@MethodName;
					tempXML.@ObjTgtID = inXML.@ID;
					tempXML.@containerID = inXML.@containerID;
					
					outXML.appendChild(tempXML);
				} 
			}
			
			return outXML;
		}
		
		private function getIcon(value:Object):Class 
		{
			var xmlData:XML = XML(value);
		
			if (xmlData.@Language.toXMLString() =='python')
				return python;
		
			if (xmlData.@Language.toXMLString() =='vscript')
				return vscript;
			
		
			if (xmlData.@resourceID.toXMLString() =='')
				return action;
		
			var data:Object = {typeId:xmlData.@Type, resourceId:xmlData.@resourceID}
		 	
	 		return IconUtil.getClass(this, data, 16, 16);
		}
		
//		currentObjectId
		public function set currentObjectId(value:String):void
		{
//			trace("currentObjectId: "+value);
			
			var object:XML = dataManager.getObject(value);
			
			dataXML  = new XMLListCollection();
//			dataXML.@label 	= object.Attributes.Attribute.(@Name == "title")+" ("+ object.@Name +")";// object.@Name;//value.@label;
//			dataXML.@resourceID = getSourceID(object.@Type);
			
			var type:XML = dataManager.getTypeByObjectId(value);
			
			if (type.Information.Container == '2' || type.Information.Container == '3')
			{
				dataManager.addEventListener(DataManagerEvent.GET_SERVER_ACTIONS_COMPLETE, getServerActionsHandler);
				dataManager.getServerActions(value);
			}
			
				curContainerTypeID = dataManager.getTypeByObjectId(dataManager.currentPageId).Information.ID.toString();
			var actions:XML = type.E2vdom.Actions.Container.(@ID == curContainerTypeID)[0];
			var tempXML:XML;
//			trace('curContainerTypeID: '+ curContainerTypeID);
		
			if(actions != null)		
			{
				for each(var child:XML in actions.children() )
				{
				 	tempXML = <Event/>;
					tempXML.@label = child.@MethodName;
					tempXML.@MethodName  = child.@MethodName;
					tempXML.@ObjTgtID = object.@ID;
					tempXML.@containerID = dataManager.currentObject.@ID;
					
					dataXML.addItem(tempXML);
				}	
			} 
			
			var sort : Sort = new Sort();
				sort.fields = [ new SortField("@MethodName")];
				dataXML.sort = sort;
				dataXML.refresh();
			
			super.dataProvider = dataXML;
			validateNow();
			var item:Object =  XMLListCollection(dataProvider).source[0];
			
//			expandItem(item, true, false);
		}
		
		private function getServerActionsHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.GET_SERVER_ACTIONS_COMPLETE, getServerActionsHandler);
	 		creatData(dmEvt.result);
		}
		
		private function creatData(xmlToTree:XML):void
		{
			var tempXML:XML;
			if(xmlToTree.toString() !='' )
			{
				for each(var container:XML in xmlToTree.children())
				{
					if(container.@ID == dataManager.currentObjectId)
					{
						for each(var actID:XML in container.children())
						{
							tempXML = <Action/>;
							tempXML.@label = actID.@Name;
							tempXML.@Name = actID.@Name;
							tempXML.@Language =	 actID.@Language;
							tempXML.@ID = actID.@ID;
							
							dataXML.addItem(tempXML);
						}
					}
				}
				
				super.dataProvider = dataXML;
				super.validateNow();
				
				var item:Object =  XMLListCollection(super.dataProvider).source[0];
			
//				super.expandItem(item, true, false);
			}
		}
		
		private var masResourceID:Array = new Array();
		private function getSourceID(ID:String):String
		{
			if (masResourceID[ID]) 
				return masResourceID[ID];
				
			var xml:XML = dataManager.getTypeByTypeId(ID);
			var str:String = xml.Information.StructureIcon;
			
			masResourceID[ID] = str.substr(5, 36);
			
			return masResourceID[ID];
		}
		
		
		
	}
}