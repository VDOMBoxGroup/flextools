package vdom.components.scriptEditor.containers
{
	import mx.collections.XMLListCollection;
	import mx.events.ListEvent;
	import mx.events.TreeEvent;
	
	import vdom.components.edit.containers.OTree;
	import vdom.containers.ClosablePanel;
	import vdom.managers.DataManager;
	import vdom.utils.IconUtil;

	public class ContainersBranch extends ClosablePanel
	{
		private var tree:OTree;
		private var dataManager:DataManager = DataManager.getInstance();
		
		public function ContainersBranch()
		{
			super();
			
			tree = new OTree();
			tree.iconFunction = getIcon;
			tree.showRoot = true;
			tree.labelField = "@label";
			tree.percentWidth = 100;
			tree.percentHeight = 100;
			tree.setStyle('borderColor', '0xFFFFFF');
			tree.setStyle('openDuration', '0');
			addChild(tree);
			
			tree.addEventListener(TreeEvent.ITEM_OPEN, itemOpenHandler);
			tree.addEventListener(TreeEvent.ITEM_CLOSE, itemCloseHandler);
			tree.addEventListener(ListEvent.CHANGE, itemChangeHandler);
		}
		
		public function set currentPageID(value:String):void
		{
			if(value == "session")
			{
				tree.dataProvider = null;
				return;
			}
				var xmlTreeData:XMLListCollection = new XMLListCollection();
				var xmlList:XML = new XML('<Object/>');
				var xmlLabel:XML = dataManager.listPages.(@ID == dataManager.currentPageId)[0];
				
				xmlList.@label = xmlLabel.Attributes.Attribute.(@Name == "title")+" ("+ xmlLabel.@Name +")";
				xmlList.@showInList = 'true';
				xmlList.@ID = xmlLabel.@ID;
				xmlList.@Type = xmlLabel.@Type;
				
				 xmlList.@resourceID = getSourceID(xmlLabel.@Type); 
					
				xmlList.appendChild(findOjects(xmlLabel.Objects));
				
				dataManager.changeCurrentObject(value);
			

			xmlTreeData.addItem(xmlList);
			tree.dataProvider = xmlTreeData;	
//			xmlTreeData.addItem(xmlList);
			tree.validateNow();
			var item:Object =  XMLListCollection(tree.dataProvider).source[0];
			
			tree.expandItem(item, true, false);
			tree.selectedIndex = 0;
			
			var ID:String = XML(tree.selectedItem).@ID;
			
			
		}
		
		
		
		private function findOjects(xmlIn:XMLList):XMLList
		{
//			trace('findOjects');
			var xmllReturn:XMLList  = new XMLList();
			for each(var xmlLabel:XML in xmlIn.children())
			{
				// проверяем есть ли еще обьекты в нутри
				var numObjects:int = xmlLabel.Objects.*.length(); 
				if(numObjects > 0)	
				{
					var type:XML = dataManager.getTypeByTypeId(xmlLabel.@Type);
					
					if (type.Information.Container == '2' || 
						type.Information.Container == '3')
					{	
						var xmlTemp:XML = new XML('<Object/>');
						xmlTemp.@label 	= xmlLabel.@Name;
						xmlTemp.@ID 	= xmlLabel.@ID;
						xmlTemp.@Type 	= xmlLabel.@Type;
						xmlTemp.@resourceID = getSourceID(xmlLabel.@Type); 
					//	trace('2 || 3')	
						xmlTemp.appendChild(findOjects(xmlLabel.Objects));
						xmllReturn += xmlTemp;
					}
//					xmlTemp.appendChild(findOjects(xmlLabel.Objects));
				}
				
			}
		
			
			return xmllReturn;
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
		
		private function getIcon(value:Object):Class 
		{
			var xmlData:XML = XML(value);
			var data:Object = {typeId:xmlData.@Type, resourceId:xmlData.@resourceID}
		 	
	 		return IconUtil.getClass(this, data, 16, 16);
		}
		
		private function itemOpenHandler(trEvt:TreeEvent):void
		{
			var ID:String = XML(tree.selectedItem).@ID;
			
			dataManager.changeCurrentObject(ID);
		}
		
		private function itemCloseHandler(trEvt:TreeEvent):void
		{
			tree.validateNow();

			if(tree.selectedItem)
			{
//				trace("Close: "+tree.selectedIndex);
//				trace(XML(tree.selectedItem).@ID);
				var ID:String = XML(tree.selectedItem).@ID;
			
				dataManager.changeCurrentObject(ID);
			} 
//			trace("---"+tree.selectedItem);
		}
		
		private function itemChangeHandler(lsEvt:ListEvent):void
		{
			var ID:String = XML(tree.selectedItem).@ID;
			
			dataManager.changeCurrentObject(ID);
		}
		
	}
}