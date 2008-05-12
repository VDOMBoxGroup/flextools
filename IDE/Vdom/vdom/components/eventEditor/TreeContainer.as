package vdom.components.eventEditor
{
	import mx.controls.Tree;
	
	import mx.events.FlexEvent;
	
	import vdom.managers.DataManager;

	public class TreeContainer extends Tree
	{
		private var xmlTreeData:XML;
		private var dataManager:DataManager;
		
		public function TreeContainer()
		{
			super();
			
			dataManager = DataManager.getInstance();
			dataProvider = dataManager.listPages;
			
			dragEnabled = false;
			labelField = "@label";
			showRoot = false;
			percentHeight = 100;//width = 200;
			percentWidth = 100;
	
	//		itemRenderer = new ClassFactory(ItCanvas);
			
		//  	addEventListener(DragEvent.DRAG_COMPLETE, onTreeDragComplete);
		//	addEventListener(FlexEvent.SHOW, showHandler);	
		//	addEventListener(FlexEvent.UPDATE_COMPLETE, treeUpdateComletLister);
		//	addEventListener(Event.CHANGE, treeChangeLister);
		}
	
		override public function set dataProvider(value:Object):void
		 {
		 	
		 	// needed to delete
		 	super.dataProvider = value;
		 	return;
		 		
		 	 if (typeof(value)=="string")
           		 value = new XML(value);
			
			if (value is XML)
			{
				// создаем обьекты верхнего уровня
				 xmlTreeData = <root/>;
				for each(var xmlLabel:XML in value)
				{
					if (xmlLabel.name() == 'Parent') continue;
					
					var xmlList:XMLList = new XMLList('<Object/>');
					xmlList.@label = xmlLabel.@Name;
					xmlList.@showInList = 'true';
					xmlList.@ID = xmlLabel.@ID;
					xmlList.@Type = xmlLabel.@Type;
					
					/// завести массивчик ID-шников.
					
					 xmlList.@resourceID = getSourceID(xmlLabel.@Type); 
				//	xmlList.@icon	= 'accordion_icon';
					
					xmlList.appendChild(findOjects(xmlLabel.Objects));
				//	trace(xmlLabel.Objects)
					
					xmlTreeData.appendChild(xmlList);
			} 
				super.dataProvider = xmlTreeData;
			//getIcons();
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
		
		private function findOjects(xmlIn:XMLList):XMLList
		{
			var xmllReturn:XMLList  = new XMLList();
			for each(var xmlLabel:XML in xmlIn.children())
			{
				var xmlTemp:XML = new XML('<Object/>');
					xmlTemp.@label 	= xmlLabel.@Name;
					xmlTemp.@ID 	= xmlLabel.@ID;
					xmlTemp.@Type 	= xmlLabel.@Type;
					xmlTemp.@resourceID = getSourceID(xmlLabel.@Type); 
					
					xmlTemp.@icon	= 'drag_icon';
				// проверяем есть ли еще обьекты в нутри
				var numObjects:int = xmlLabel.Objects.*.length(); 
				if(numObjects > 0)	xmlTemp.appendChild(findOjects(xmlLabel.Objects));
				
				xmllReturn += xmlTemp;
			}
			return xmllReturn;
		}
		
	/*	
		
		private function onTreeDragComplete(drEvt:DragEvent):void
		{
			drEvt.preventDefault();
		}
		*/
	}
}