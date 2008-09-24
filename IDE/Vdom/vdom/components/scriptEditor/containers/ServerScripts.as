package vdom.components.scriptEditor.containers
{
	import mx.containers.Canvas;
	import mx.controls.Tree;
	
	import vdom.events.DataManagerEvent;
	import vdom.managers.DataManager;

	public class ServerScripts extends Canvas
	{
		private var tree:Tree;
		private var dataManager:DataManager = DataManager.getInstance();
		
		public function ServerScripts()
		{
			super();
			tree = new Tree();
			tree.showRoot = false;
			tree.percentHeight = 100;
			tree.percentWidth = 100;
			tree.labelField = '@label';
			addChild(tree);
		}
		
		public function set dataProvider(str:String):void
		{
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
		private function creatData(xmlToTree:XML=null):void
		{
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
			dataXML.appendChild(xml);
			
			tree.dataProvider = dataXML;
		}
		
		public function deleteScript():void
		{
			tree
		}
	}
}