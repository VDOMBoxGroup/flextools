package vdom.components.scriptEditor.containers
{
	import mx.collections.XMLListCollection;
	import mx.events.ListEvent;
	import mx.utils.UIDUtil;
	
	import vdom.components.edit.containers.OTree;
	import vdom.containers.ClosablePanel;
	import vdom.events.DataManagerEvent;
	import vdom.events.ServerScriptsEvent;
	import vdom.managers.DataManager;
	import vdom.utils.IconUtil;
	
	[Event(name="dataChanged", type="vdom.events.ServerScriptsEvent")]


	public class ServerScripts extends ClosablePanel
	{
		private var tree:OTree;
		private var dataManager:DataManager = DataManager.getInstance();
		private var curContainerID:String;
			
		
		
		[Embed(source='/assets/scriptEditor/python.png')]
		[Bindable]
		public var python:Class;
		
		[Embed(source='/assets/scriptEditor/vbscript.png')]
		[Bindable]
		public var vscript:Class;

	
			
		public function ServerScripts()
		{
			super();
			tree = new OTree();
			tree.showRoot = true;
			tree.iconFunction = getIcon;
			tree.percentWidth = 100;
			tree.labelField = '@Name';
			tree.setStyle('borderColor', '0xFFFFFF');
			
			tree.addEventListener(ListEvent.CHANGE, changeHandler);
			
			addChild(tree);
		}
		
		public function set dataProvider(str:String):void
		{
			tree.dataProvider = null;
			curContainerID = str;
			dataManager.addEventListener(DataManagerEvent.GET_SERVER_ACTIONS_COMPLETE, getServerActionsHandler);
			dataManager.getServerActions(str);
			trace("Data asked")
		}
		
		private function getServerActionsHandler(dmEvt:DataManagerEvent):void
		{
			
			dataManager.removeEventListener(DataManagerEvent.GET_SERVER_ACTIONS_COMPLETE, getServerActionsHandler);
	 		creatData(dmEvt.result);
	 		trace('-----------from serve-------------');
	 		trace(curContainerID);
	 		trace("" + dmEvt.result.toXMLString())
		}
		
		private var dataXML:XML;
		private var xmlToServer:XML;
		private function creatData(xmlToTree:XML):void
		{
			xmlToServer = new XML(xmlToTree.toXMLString());
//			delete xmlToServer.Key;

			var object:XML = dataManager.getObject(dataManager.currentObjectId);
			
			dataXML  = new XML('<Object/>');
			dataXML.@Name 	= object.Attributes.Attribute.(@Name == "title")+" ("+ object.@Name +")";// object.@Name;//value.@label;
			dataXML.@resourceID = getSourceID(object.@Type);
			
			var type:XML = dataManager.getTypeByObjectId(dataManager.currentObjectId);
			var	curContainerTypeID:String = dataManager.getTypeByObjectId(dataManager.currentObjectId).Information.ID.toString();
			var actions:XML = type.E2vdom.Actions.Container.(@ID == curContainerTypeID)[0];
			var tempXML:XML;
//			var tempXML:XML;

//			dataXML  = new XML('<Actions/>');
			
			if(xmlToTree.toString() !='' )
			{
				for each(var actID:XML in xmlToTree.children())
				{
					tempXML = <Action/>;
					tempXML.@label = actID.@Name;
					tempXML.@Name = actID.@Name;
					tempXML.@Language =	 actID.@Language;
					tempXML.@ID = actID.@ID;
					
					dataXML.appendChild(tempXML);
				}
				
				tree.dataProvider = dataXML;
				tree.validateNow();
				
				var item:Object =  XMLListCollection(tree.dataProvider).source[0];
			
				tree.expandItem(item, true, false);
				tree.selectedIndex = 1;
				
			}else
			{
				tree.dataProvider = null;
			}
			dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
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
		
		public function set addScript(xml:XML):void
		{
			xml.@ID = UIDUtil.createUID();
			
			dataXML.appendChild(xml);
			
			var temp:XML = new XML(xml.toXMLString());
//				temp.addName = '123'+ Math.random();
			
			xmlToServer.appendChild(temp);	
			
			tree.dataProvider = dataXML;
			tree.validateNow();
			
			var item:Object =  XMLListCollection(tree.dataProvider).source[0];
			tree.expandItem(item, true, false);
				
			tree.selectedItem = xml;
			tree.validateNow();
			dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
		}
		
		public function deleteScript():void
		{
			if(tree.selectedItem)
			{
				var ID:String = tree.selectedItem.@ID;
				
				delete dataXML.Action.(@ID == ID)[0];
				delete xmlToServer.Action.(@ID == ID)[0];
				
				if(dataXML.toXMLString() != "<Actions/>")
				{	
					tree.dataProvider = dataXML;
					tree.validateNow();
					tree.selectedIndex = 1;
					tree.validateNow();
					
				//	var script:String = xmlToServer.E2vdom.ServerActions.Action.(@ID == ID)[0];
					dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
				}else	
				{
					tree.dataProvider = null;
				}
			}
		}
		
		public function set script(str:String):void
		{
			if(tree.selectedItem)
			{
				var ID:String = tree.selectedItem.@ID;
				var tempXML:XML = xmlToServer.Action.(@ID == ID)[0]; 
				var xml:XML = new XML('<Action/>');	
					xml.@ID = tempXML.@ID;
					xml.@Name = tempXML.@Name;
					xml.@Language = tempXML.@Language;
					xml.@Top = tempXML.@Top;
					xml.@Left = tempXML.@Left; 
					xml.@State = tempXML.@State;
					xml.appendChild(XML('<![CDATA[' +str + ']'+']>'));
				
				delete xmlToServer.Action.(@ID == ID)[0];
				xmlToServer.appendChild(xml);
				
				dataManager.setServerActions(xmlToServer,curContainerID);
				trace('******** To server ********');
				trace(curContainerID);
				trace(xmlToServer.toXMLString());
			}
		}
		
		public function get script():String
		{
			if(!tree.selectedItem)
				return '';
				
			var ID:String = tree.selectedItem.@ID;
			
			if (ID == '') 
				return 'null';
				
			return xmlToServer.Action.(@ID == ID)[0].toString();
		}
		
		private function changeHandler(lsEvt:ListEvent):void
		{
			dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
		}
		
		public function get dataEnabled():Object
		{
			return tree.selectedItem;
		}
		
		private function getIcon(value:Object):Class 
		{
			var xmlData:XML = XML(value);
		
			if (xmlData.@Language.toXMLString() =='python')
				return python;
		
			if (xmlData.@Language.toXMLString() =='vscript')
				return vscript;
			
			var data:Object = {typeId:xmlData.@Type, resourceId:xmlData.@resourceID}
		 	
	 		return IconUtil.getClass(this, data, 16, 16);
		}


		
	}
}