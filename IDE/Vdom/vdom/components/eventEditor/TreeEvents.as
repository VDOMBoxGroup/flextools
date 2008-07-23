package vdom.components.eventEditor
{
	import mx.core.ClassFactory;
	
	import vdom.managers.DataManager;
	import vdom.utils.IconUtil;

	public class TreeEvents extends DragTree
	{
		private var dataManager:DataManager ;
		public function TreeEvents()
		{
			super();
			iconFunction = getIcon;
			
			dataManager = DataManager.getInstance();
			var productRenderer:ClassFactory = new ClassFactory(EventItemRender);

			this.itemRenderer  = productRenderer;
	//		addEventListener(MouseEvent.MOUSE_DOWN, changeItemHandler)
			
		}
		
		private var dataXML:XML ;
		override public function set dataProvider(value:Object):void
		{
		/* <Object label="header_image" ID='' Type='' resourceID='' containerID=''/>*/
		  dataXML =  <root/>;	
		  
		  for each(var child:XML in value)
		  {
		  	dataXML.appendChild(getChilds(child))
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
			dataXML.Object.(@ID == obj.ObjSrcID).Event.(@Name == obj.Name).@enabled = 'true';
			selectedItem = dataXML.Object.(@ID == obj.ObjSrcID).Event.(@Name == obj.Name)[0];
		}		
		
		public function  set disabledItem(obj:Object):void
		{
			dataXML.Object.(@ID == obj.ObjSrcID).Event.(@Name == obj.Name).@enabled = 'false';
		}	
		
		private function getIcon(value:Object):Class 
		{
			var xmlData:XML = XML(value);
		
			if (xmlData.@resourceID.toXMLString() =='')
				return event;
		
			var data:Object = {typeId:xmlData.@Type, resourceId:xmlData.@resourceID}
		 	
	 		return IconUtil.getClass(this, data, 16, 16);
		}
	}
}