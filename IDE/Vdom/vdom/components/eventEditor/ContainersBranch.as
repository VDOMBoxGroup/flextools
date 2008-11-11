package vdom.components.eventEditor
{
	import mx.controls.Tree;
	import mx.events.FlexEvent;
	
	import vdom.containers.ClosablePanel;
	import vdom.events.DataManagerEvent;
	import vdom.managers.DataManager;
	import vdom.utils.IconUtil;

	public class ContainersBranch extends ClosablePanel
	{
		private var tree:Tree
		private var dataManager:DataManager = DataManager.getInstance();
		
		public function ContainersBranch()
		{
			super();
			
			tree = new Tree();
			tree.iconFunction = getIcon;
			
			addEventListener(FlexEvent.SHOW, showHandler);
			addEventListener(FlexEvent.HIDE, hideHandler);
		}
		
		private function showHandler(flEvt:FlexEvent):void
		{
			dataManager.addEventListener(DataManagerEvent.PAGE_CHANGED, pageChangeHandler);
		}
		
		private function hideHandler(flEvt:FlexEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.PAGE_CHANGED, pageChangeHandler);
		}
		
		private function pageChangeHandler(dmEvt:DataManagerEvent):void
		{
			dataManager.listPages.(@ID == dataManager.currentPageId);
		}
		
		private function findOjects(xmlIn:XMLList):XMLList
		{
//			trace('findOjects');
			var xmllReturn:XMLList  = new XMLList();
			for each(var xmlLabel:XML in xmlIn.children())
			{
				var xmlTemp:XML = new XML('<Object/>');
					xmlTemp.@label 	= xmlLabel.@Name;
					xmlTemp.@ID 	= xmlLabel.@ID;
					xmlTemp.@Type 	= xmlLabel.@Type;
					xmlTemp.@resourceID = getSourceID(xmlLabel.@Type); 
					
				// проверяем есть ли еще обьекты в нутри
				var numObjects:int = xmlLabel.Objects.*.length(); 
				if(numObjects > 0)	xmlTemp.appendChild(findOjects(xmlLabel.Objects));
				
				xmllReturn += xmlTemp;
			}
			return xmllReturn;
		}
		
		private var masResourceID:Array = new Array();
		private function getSourceID(ID:String):String
		{
//			trace('getSourceID');
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
		
//			if (xmlData.@resourceID.toXMLString() =='')
//				return action;
		
			var data:Object = {typeId:xmlData.@Type, resourceId:xmlData.@resourceID}
		 	
	 		return IconUtil.getClass(this, data, 16, 16);
		}
		
		
	}
}