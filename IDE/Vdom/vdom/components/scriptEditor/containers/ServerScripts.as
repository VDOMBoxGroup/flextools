package vdom.components.scriptEditor.containers
{
	import mx.events.ListEvent;
	import mx.utils.UIDUtil;
	
	import vdom.components.edit.containers.OTree;
	import vdom.containers.ClosablePanel;
	import vdom.events.DataManagerEvent;
	import vdom.events.ServerScriptsEvent;
	import vdom.managers.DataManager;
	
	[Event(name="dataChanged", type="vdom.events.ServerScriptsEvent")]

	public class ServerScripts extends ClosablePanel
	{
		private var tree:OTree;
		private var dataManager:DataManager = DataManager.getInstance();
		private var curContainerID:String;

		public function ServerScripts()
		{
			super();
			tree = new OTree();
			tree.showRoot = false;
//			tree.percentHeight = 100;
			tree.percentWidth = 100;
			tree.labelField = '@Name';
			tree.addEventListener(ListEvent.CHANGE, changeHandler);
			
			addChild(tree);
		}
		
		public function set dataProvider(str:String):void
		{
			tree.dataProvider = null;
			curContainerID = str;
			dataManager.addEventListener(DataManagerEvent.GET_APPLICATION_EVENTS_COMPLETE, applicationEvenLoadedHandler);
			dataManager.getApplicationEvents(str);
			trace("Data asked")
		}
		
		private function applicationEvenLoadedHandler(dmEvt:DataManagerEvent):void
		{
			
			dataManager.removeEventListener(DataManagerEvent.GET_APPLICATION_EVENTS_COMPLETE, applicationEvenLoadedHandler);
	 		creatData(dmEvt.result);
	 		trace('-----------from serve-------------');
	 		trace(curContainerID);
	 		trace("" + dmEvt.result.toXMLString())
		}
		
		private var dataXML:XML;
		private var xmlToServer:XML;
		private function creatData(xmlToTree:XML):void
		{
			xmlToServer = new XML(xmlToTree.E2vdom.toXMLString());
//			delete xmlToServer.Key;
			var tempXML:XML;

			dataXML  = new XML('<Actions/>');
			
			if(xmlToTree.E2vdom.ServerActions.toString() !='' )
			{
				for each(var actID:XML in xmlToTree.E2vdom.ServerActions.children())
				{
					tempXML = <Action/>;
					tempXML.@label = actID.@Name;
					tempXML.@Name = actID.@Name;
					tempXML.@Language = actID.@Language;
					tempXML.@ID = actID.@ID;
					
					dataXML.appendChild(tempXML);
				}
				
				tree.dataProvider = dataXML;
				tree.validateNow();
				tree.selectedIndex = 0;
				
			}else
			{
				tree.dataProvider = null;
			}
			dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
		}
		
		public function set addScript(xml:XML):void
		{
			xml.@ID = UIDUtil.createUID();
			
			dataXML.appendChild(xml);
			
			var temp:XML = new XML(xml.toXMLString());
//				temp.addName = '123'+ Math.random();
			
			xmlToServer.ServerActions.appendChild(temp);	
			
			tree.dataProvider = dataXML;
			tree.validateNow();
			
			tree.selectedItem = xml;
			dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
		}
		
		public function deleteScript():void
		{
			if(tree.selectedItem)
			{
				var ID:String = tree.selectedItem.@ID;
				
				delete dataXML.Action.(@ID == ID)[0];
				delete xmlToServer.ServerActions.Action.(@ID == ID)[0];
				
				if(dataXML.toXMLString() != "<Actions/>")
				{	
					tree.dataProvider = dataXML;
					tree.validateNow();
					tree.selectedIndex = 0;
					
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
				var tempXML:XML = xmlToServer.ServerActions.Action.(@ID == ID)[0]; 
				var xml:XML = new XML('<Action/>');	
					xml.@ID = tempXML.@ID;
					xml.@Name = tempXML.@Name;
					xml.@Language = tempXML.@Language;
					xml.@Top = tempXML.@Top;
					xml.@Left = tempXML.@Left;
					xml.@State = tempXML.@State;
					xml.appendChild(XML('<![CDATA[' +str + ']'+']>'));
				
				delete xmlToServer.ServerActions.Action.(@ID == ID)[0];
				xmlToServer.ServerActions.appendChild(xml);
				
				dataManager.setApplicationEvents(curContainerID, xmlToServer.toXMLString());
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
			
			return xmlToServer.ServerActions.Action.(@ID == ID)[0].toString();
		}
		
		private function changeHandler(lsEvt:ListEvent):void
		{
			dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
		}
		
		public function get dataEnabled():Object
		{
			return tree.selectedItem;
		}
		
	}
}