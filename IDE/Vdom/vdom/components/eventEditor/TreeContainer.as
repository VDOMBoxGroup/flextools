package vdom.components.eventEditor
{
	import flash.events.Event;
	
	import mx.controls.Tree;
	import mx.core.ClassFactory;
	
	import vdom.controls.IconTreeItemRenderer;
	import vdom.managers.DataManager;

	public class TreeContainer extends Tree
	{
		private var xmlTreeData:XML;
		private var dataManager:DataManager;
		
		public function TreeContainer()
		{
			super();
			
			dataManager = DataManager.getInstance();
		//	dataProvider = dataManager.listPages;
			
			dragEnabled = false;
			labelField = "@label";
			showRoot = false;
			percentHeight = 100;//width = 200;
			percentWidth = 100;
	
			itemRenderer = new ClassFactory(IconTreeItemRenderer);
			
		//  	addEventListener(DragEvent.DRAG_COMPLETE, onTreeDragComplete);
		//	addEventListener(FlexEvent.SHOW, showHandler);	
		//	addEventListener(FlexEvent.HIDE, hideHandler);	
		//	addEventListener(FlexEvent.UPDATE_COMPLETE, treeUpdateComletLister);
			addEventListener(Event.CHANGE, treeChangeLister);
		}
	/*	
		private function showHandler(evt:FlexEvent):void
		{
			addEventListener(Event.CHANGE, treeChangeLister);
		}
		
		
		private function hideHandler(evt:FlexEvent):void
		{
			removeEventListener(Event.CHANGE, treeChangeLister);
		}
		*/
		private var selectedNode:XML;
		private function treeChangeLister(evt:Event):void
		{
			
			 selectedNode = Tree(evt.target).selectedItem as XML;
			 var ID:String = selectedNode.@ID;
			 //trace('--- '+ID);
			 if(xmlTreeData.Object.(@ID == ID).toXMLString() != "" )
              {
          		   	dataManager.changeCurrentPage(ID);
          		   
              } else
              {
              		//dataManager.changeCurrentObject(ID);
              }
           //   this.selectedItem = xmlTreeData..*.Object.(@ID == ID)[0];
		}
	
		override public function set dataProvider(value:Object):void
		 {
			if (value )
			{
				//trace('*********\n' + value)
				value = value as XMLList;
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
					var type:XML = dataManager.getTypeByTypeId(xmlLabel.@Type);
					
					xmlList.appendChild(findOjects(xmlLabel.Objects));
				//	trace(xmlLabel.Objects)
					
					xmlTreeData.appendChild(xmlList);
			} 
				super.dataProvider = xmlTreeData;
				
				//*********************************
			//	trace(xmlTreeData.Object.(@ID == dataManager.currentPageId)[0])
			if(selectedNode)
				this.selectedItem = selectedNode;
				
				
				
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
				var type:XML = dataManager.getTypeByTypeId(xmlLabel.@Type);
			
					xmlTemp.@label 	= xmlLabel.@Name;
					xmlTemp.@ID 	= xmlLabel.@ID;
					xmlTemp.@Type 	= xmlLabel.@Type;
					xmlTemp.@resourceID = getSourceID(xmlLabel.@Type); 
					
				//	xmlTemp.@icon	= 'drag_icon';
				// проверяем есть ли еще обьекты в нутри
				var numObjects:int = xmlLabel.Objects.*.length(); 
				if(numObjects > 0)
				if (type.Information.Container == '2' || type.Information.Container == '3')
				{	
				//	trace('2 || 3')	
					xmlTemp.appendChild(findOjects(xmlLabel.Objects));
					xmllReturn += xmlTemp;
				}
				
			}
			return xmllReturn;
		}
	}
}