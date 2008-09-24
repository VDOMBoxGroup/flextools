package vdom.components.scriptEditor.containers
{
	import mx.containers.Canvas;
	import mx.controls.Tree;
	import mx.events.ListEvent;
	import mx.utils.UIDUtil;
	
	import vdom.events.DataManagerEvent;
	import vdom.events.ServerScriptsEvent;
	import vdom.managers.DataManager;
	
	[Event(name="dataChanged", type="vdom.events.ServerScriptsEvent")]

	public class ServerScripts extends Canvas
	{
		private var tree:Tree;
		private var dataManager:DataManager = DataManager.getInstance();
		private var curContainerID:String;

		public function ServerScripts()
		{
			super();
			tree = new Tree();
			tree.showRoot = false;
			tree.percentHeight = 100;
			tree.percentWidth = 100;
			tree.labelField = '@Name';
			tree.addEventListener(ListEvent.CHANGE, changeHandler);
			
			addChild(tree);
		}
		
		public function set dataProvider(str:String):void
		{
			curContainerID = str;
			dataManager.addEventListener(DataManagerEvent.GET_APPLICATION_EVENTS_COMPLETE, applicationEvenLoadedHandler);
			dataManager.getApplicationEvents(str);
			trace("Data asked")
		}
		
		private function applicationEvenLoadedHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.GET_APPLICATION_EVENTS_COMPLETE, applicationEvenLoadedHandler);
	 		creatData(dmEvt.result);
	 		trace("Data geted")
		}
		
		private var dataXML:XML;
		private var xmlToServer:XML;
		private function creatData(xmlToTree:XML):void
		{
			xmlToServer = xmlToTree.E2vdom[0];
//			delete xmlToServer.Key;
			var tempXML:XML;

			dataXML  = new XML('<Actions/>');
			
			if(xmlToTree.E2vdom.ServerActions.toString() !='' )
			{
				for each(var actID:XML in xmlToTree.E2vdom.ServerActions.children())
				{
					tempXML = <Event/>;
					tempXML.@label = actID.@Name;
					tempXML.@Name = actID.@Name;
					tempXML.@Language = actID.@Language;
					tempXML.@ID = actID.@ID;
					
					dataXML.appendChild(tempXML);
				}
				
				tree.dataProvider = dataXML;
				
			}else
			{
				tree.dataProvider = null;
			}
		}
		
		public function set addScript(xml:XML):void
		{
			xml.@ID = UIDUtil.createUID();
			xml.@Language = 'python';
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
			if(!tree.selectedItem)
			{
				var ID:String = tree.selectedItem.@ID;
				xmlToServer.ServerActions.Action.(@ID == ID).appendChild( XML('<![CDATA[' +str + ']'+']>'));
				dataManager.setApplicationEvents(curContainerID, xmlToServer.toXMLString());
				trace(xmlToServer.toXMLString());
			}
		}
		
		public function get script():String
		{
			var ID:String = tree.selectedItem.@ID;
			
			return xmlToServer.ServerActions.Action.(@ID == ID)[0].toString();
		}
		
		private function changeHandler(lsEvt:ListEvent):void
		{
			dispatchEvent(new ServerScriptsEvent(ServerScriptsEvent.DATA_CHANGED));
		}
		
	}
}