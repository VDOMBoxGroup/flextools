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
		  	dataXML  = new XML('<Object/>');
			dataXML.@label 	= value.@label;
			dataXML.@resourceID = value.@resourceID;
		  
		  
		  	var type:XML = dataManager.getTypeByTypeId(value.@Type);
			var tempXML:XML;
			
			for each(var child:XML in type.E2vdom.Events.Userinterfaceevents.children() )
			{
			 	tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@Name = child.@Name;
				tempXML.@ObjSrcID = value.@ID;
				tempXML.@ContainerID = 
				dataXML.appendChild(tempXML);
			} 
			
			for each(child in type.E2vdom.Events.Objectevents.children() )
			{
				tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@Name  = child.@Name;
				tempXML.@ObjSrcID = value.@ID;
			
				dataXML.appendChild(tempXML);
			} 	
		  
		 value = value as XML;
		  for each(child in value.children())
		  {
		  	dataXML.appendChild(getChilds(child));
		  }
		  
		  super.dataProvider = dataXML;
		  
		  validateNow();
	//		var item:Object =  XMLListCollection(dataProvider).source[0];
			
		//	super.selectedIndex = 0;
			
			
			expandItem(dataProvider.source[0], true, false);
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
			
			if(!selectedItem)
			{
				dataXML.Event.(@Name == obj.Name).@enabled = 'true';
				selectedItem = dataXML.Event.(@Name == obj.Name)[0];
			}
		}		
		
		public function  set disabledItem(obj:Object):void
		{

			dataXML.Event.(@Name == obj.Name).@enabled = 'false';
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
		
		public function set currentObjectId(value:String):void
		{
			trace("currentObjectId: "+value);
			
			var object:XML = dataManager.getObject(value);
			dataXML  = new XML('<Object/>');
			dataXML.@label 	= object.Attributes.Attribute.(@Name == "title")+" ("+ object.@Name +")";// object.@Name;//value.@label;
			dataXML.@resourceID = getSourceID(object.@Type);
//			dataXML.@resourceID = value.@resourceID;
		  
		  	trace("ID: "+dataXML.@ID);
		  	
		  	var type:XML = dataManager.getTypeByObjectId(value);
			var tempXML:XML;
			
			for each(var child:XML in type.E2vdom.Events.Userinterfaceevents.children() )
			{
			 	tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@Name = child.@Name;
				tempXML.@ObjSrcID = value;
				tempXML.@ContainerID = _currentContainerId;
				
				dataXML.appendChild(tempXML);
			} 
			
			for each(child in type.E2vdom.Events.Objectevents.children() )
			{
				tempXML = <Event/>;
				tempXML.@label = child.@Name;
				tempXML.@Name  = child.@Name;
				tempXML.@ObjSrcID = value;
				tempXML.@ContainerID = _currentContainerId;
			
				dataXML.appendChild(tempXML);
			} 	
			
			super.dataProvider = dataXML;
			
			validateNow();
			
			expandItem(dataProvider.source[0], true, false);
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
		
		private var _currentContainerId:String;
		public function set currentContainerId(value:String):void
		{
			_currentContainerId = value;
		}
		
	}
}