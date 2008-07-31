package vdom.components.eventEditor
{
	import flash.events.Event;
	
	import mx.controls.Tree;
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
			selectedNode = null;
			dataManager.addEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED,  changeCurrentPageListener);
            dataManager.changeCurrentPage(dataManager.currentPageId);
		}
		
		
		public function hideHandler():void
		{
			if(selectedNode)
				dataManager.changeCurrentPage(selectedNode.@ID);
		}
		
		private function changeCurrentPageListener(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED,  changeCurrentPageListener);
			dataManager.addEventListener(DataManagerEvent.CURRENT_OBJECT_CHANGED,  changeCurrentObjectListener);
			
		}
		
		private function treeChangeLister(evt:Event):void
		{
			 selectedNode = Tree(evt.target).selectedItem as XML;
			 trace('------------------')
			  trace('selectedNode ID: '+selectedNode.@ID)
			 containerChange(selectedNode.@ID);
			
		}
		
		private var selectedNode:XML;
		private var loadedPages:Array = []; /*of XML*/
		private function containerChange(ID:String):void
		{
			if(!xmlTreeData)
				return;
				
			 if(loadedPages[ID])
			 {
			 	dispatchEvent(new EventEditorEvent(EventEditorEvent.DATA_CHANGED, loadedPages[ID], ID))
			 	return;
			 }
			 
			_data = _data as XMLList;
			
			 if(xmlTreeData.Object.(@ID == ID).toXMLString() != "" )
              {
          		   		dataManager.addEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED,  changeCurrentPageListener)
              	   		dataManager.changeCurrentPage(ID);
              } else
              {
              		loadedPages[ID] = craetTreeData(_data..*.Object.(@ID == ID).Objects);
			
					dispatchEvent(new EventEditorEvent(EventEditorEvent.DATA_CHANGED, loadedPages[ID], ID))
              }
              
		}
		private var curId:String;
		private function changeCurrentObjectListener(dmEvt:DataManagerEvent):void
		{
			dataManager.removeEventListener(DataManagerEvent.CURRENT_PAGE_CHANGED,  changeCurrentPageListener);
			
			//var ID:String;
			if(selectedNode)
				curId = selectedNode.@ID;
			else
				curId = dataManager.currentPageId;
				
			
			loadedPages[curId] = craetTreeData(_data.(@ID == curId).Objects);
			
			dispatchEvent(new EventEditorEvent(EventEditorEvent.DATA_CHANGED, loadedPages[curId], curId))
		}
		
		private function treeUpdateComletLister(evt:Event):void
		{	
				var topLevelObjectId:String = dataManager.currentPageId //publicData.topLevelObjectId;
				if(topLevelObjectId && xmlTreeData) 
				{
					selectedItem = xmlTreeData.Object.(@ID == topLevelObjectId)[0];
//					trace('selectedItem ID: '+selectedItem.@ID);
					this.scrollToIndex(getItemIndex(selectedItem));
				}
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
//				trace('***********************');
//				trace(xmlTreeData.toXMLString());
				
				if(selectedNode)
				{
					this.selectedItem = selectedNode;
					this.scrollToIndex(getItemIndex(selectedItem));
//					trace('selectedItem: '+selectedItem.toXMLString());
				}
			}
		}
		
		public function removeItem(remXML:XML):void
		{
			
			//super.dataProvider = xmlTreeData;
		//	super.removeChild(remXML);
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
					
					if (type.Information.Container == '2' || 
						type.Information.Container == '3')
					{	
					//	trace('2 || 3')	
						xmlTemp.appendChild(findOjects(xmlLabel.Objects));
						xmllReturn += xmlTemp;
					}
				}
			}
			
			return xmllReturn;
		}
		
		private function craetTreeData(xmlIn:XMLList):XML
		{
			var ID:String;
			
			if(selectedNode)
				ID = selectedNode.@ID;
			else
				ID = curId;
				
			var xmllReturn:XML  = new XML('<Object/>');
				xmllReturn.@label 	= xmlTreeData..Object.(@ID == ID).@label;
				xmllReturn.@ID 		= ID;
				xmllReturn.@Type 	= xmlTreeData..Object.(@ID == ID).@Type;
				xmllReturn.@resourceID = xmlTreeData..Object.(@ID == ID).@resourceID;
			
			for each(var xmlLabel:XML in xmlIn.children())
			{
				var xmlTemp:XML = new XML('<Object/>');
		
					xmlTemp.@label 	= xmlLabel.@Name;
					xmlTemp.@ID 	= xmlLabel.@ID;
					xmlTemp.@Type 	= xmlLabel.@Type;
					xmlTemp.@resourceID = getSourceID(xmlLabel.@Type);
					 
					xmlTemp.@containerID = curId;
					
					xmllReturn.appendChild(xmlTemp)	;
			}
			
			return xmllReturn;
		}
	}
}