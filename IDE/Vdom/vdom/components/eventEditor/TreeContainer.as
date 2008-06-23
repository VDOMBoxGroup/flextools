package vdom.components.eventEditor
{
	import flash.events.Event;
	
	import mx.controls.Tree;
	import mx.core.ClassFactory;
	import mx.events.FlexEvent;
	

	import vdom.events.DataManagerEvent;
	import vdom.events.EventEditorEvent;
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
	
			//itemRenderer = new ClassFactory(IconTreeItemRenderer);
			
		//  	addEventListener(DragEvent.DRAG_COMPLETE, onTreeDragComplete);
			addEventListener(FlexEvent.SHOW, showHandler);	
			addEventListener(FlexEvent.HIDE, hideHandler);	
			addEventListener(FlexEvent.UPDATE_COMPLETE, treeUpdateComletLister);
			addEventListener(Event.CHANGE, treeChangeLister);
		}
		
		public function showHandler():void
		{
			loadedPages = [];
		}
		
		
		public function hideHandler():void
		{
			dataManager.changeCurrentPage(selectedNode.@ID);
		}
		
		private var selectedNode:XML;
		private var loadedPages:Array = []; /*of Boolean*/
		private function treeChangeLister(evt:Event):void
		{
			
			 selectedNode = Tree(evt.target).selectedItem as XML;
			 var ID:String = selectedNode.@ID;
			 
			 if(loadedPages[ID])
			 {
			 	dispatchEvent(new EventEditorEvent(EventEditorEvent.DATA_CHANGED, loadedPages[ID]))
			 	return;
			 }
			 
			_data = _data as XMLList;
			
			 if(xmlTreeData.Object.(@ID == ID).toXMLString() != "" )
              {
              	   		dataManager.changeCurrentPage(ID);
          		   		dataManager.addEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED,  changeCurrentPageListener)
              } else
              {
              		loadedPages[ID] = craetTreeData(_data..*.Object.(@ID == ID).Objects);
			
					dispatchEvent(new EventEditorEvent(EventEditorEvent.DATA_CHANGED, loadedPages[ID]))
              }
		}
		
		private function changeCurrentPageListener(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED,  changeCurrentPageListener);
			
			var ID:String = selectedNode.@ID;
			
			loadedPages[ID] = craetTreeData(_data.(@ID == ID).Objects);
			
			dispatchEvent(new EventEditorEvent(EventEditorEvent.DATA_CHANGED, loadedPages[ID]))
		}
		
		private function treeUpdateComletLister(evt:Event):void
		{	
				var topLevelObjectId:String = dataManager.currentPageId //publicData.topLevelObjectId;
				if(topLevelObjectId && xmlTreeData) 
					selectedItem = xmlTreeData.Object.(@ID == topLevelObjectId)[0];
		}
		
		private var _data:Object;
		override public function set dataProvider(value:Object):void
		 {
			if (value )
			{
				_data = Object(value);
				
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
					
					xmlList.@resourceID = getSourceID(xmlLabel.@Type); 
					
					var type:XML = dataManager.getTypeByTypeId(xmlLabel.@Type);
					
					xmlList.appendChild(findOjects(xmlLabel.Objects));
					xmlTreeData.appendChild(xmlList);
			} 
				super.dataProvider = xmlTreeData;
				
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
				
			
					xmlTemp.@label 	= xmlLabel.@Name;
					xmlTemp.@ID 	= xmlLabel.@ID;
					xmlTemp.@Type 	= xmlLabel.@Type;
					xmlTemp.@resourceID = getSourceID(xmlLabel.@Type); 
					
				// проверяем есть ли еще обьекты в нутри
				var numObjects:int = xmlLabel.Objects.*.length(); 
				
				
				if(numObjects > 0)
				{
					var type:XML = dataManager.getTypeByTypeId(xmlLabel.@Type);
					
					if (type.Information.Container == '2' || type.Information.Container == '3')
					{	
					//	trace('2 || 3')	
						xmlTemp.appendChild(findOjects(xmlLabel.Objects));
						xmllReturn += xmlTemp;
					}
				}
			}
			return xmllReturn;
		}
		
		private function craetTreeData(xmlIn:XMLList):XMLList
		{
			var xmllReturn:XMLList  = new XMLList();
			
			for each(var xmlLabel:XML in xmlIn.children())
			{
				var xmlTemp:XML = new XML('<Object/>');
		
					xmlTemp.@label 	= xmlLabel.@Name;
					xmlTemp.@ID 	= xmlLabel.@ID;
					xmlTemp.@Type 	= xmlLabel.@Type;
					xmlTemp.@resourceID = getSourceID(xmlLabel.@Type); 
					
					xmllReturn += xmlTemp;
			}
			return xmllReturn;
		}
	}
}