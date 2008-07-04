package vdom.components.eventEditor
{
	import mx.collections.XMLListCollection;
	import mx.core.ClassFactory;
	
	import vdom.managers.DataManager;

	public class TreeEvents extends DragTree
	{
		private var dataManager:DataManager ;
		public function TreeEvents()
		{
			super();
			dataManager = DataManager.getInstance();
			var productRenderer:ClassFactory = new ClassFactory(EventItemRender);

			this.itemRenderer  = productRenderer;
	//		addEventListener(MouseEvent.MOUSE_DOWN, changeItemHandler)
			
		}
		
		private var dataXML:XMLListCollection ;
		override public function set dataProvider(value:Object):void
		{
		
		  dataXML = new XMLListCollection();	
		  for each(var child:XML in value)
		  {
		  		dataXML.addItem(getChilds(child))
		  }
			super.dataProvider = dataXML;
		}
		
		private function getChilds(inXML:XML):XML
		{
			var type:XML = dataManager.getTypeByTypeId(inXML.@Type);
			var tempXML:XML;
			var outXML:XML = new XML(inXML.toXMLString())
			
			for each(var child:XML in type.E2vdom.Events.Userinterfaceevents.children() )
			{
			 	tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@Name = child.@Name;
				tempXML.@ObjSrcID = inXML.@ID;
				
				outXML.appendChild(tempXML);
			} 
			
			for each(child in type.E2vdom.Events.Objectevents.children() )
			{
				tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@Name  = child.@Name;
				tempXML.@ObjSrcID = inXML.@ID;
			
				outXML.appendChild(tempXML);
			} 	

			return outXML;
		}
		
		public function  set enabledItem(obj:Object):void
		{
			
			dataXML.source.(@ID == obj.ObjSrcID).Event.(@Name == obj.Name).@enabled = 'true';
			selectedItem = dataXML.source.(@ID == obj.ObjSrcID).Event.(@Name == obj.Name)[0];
		}		
		
		public function  set disabledItem(obj:Object):void
		{
			dataXML.source.(@ID == obj.ObjSrcID).Event.(@Name == obj.Name).@enabled = 'false';
			//selectedItem = dataXML.source.(@ID == obj.ObjSrcID).Event.(@Name == obj.Name)[0];
		}	
	}
}