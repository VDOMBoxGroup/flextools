package vdom.components.eventEditor
{
	import mx.collections.XMLListCollection;
	
	import vdom.managers.DataManager;
	import vdom.utils.IconUtil;
	
	public class TreeActions extends DragTree
	{
		private var dataManager:DataManager ;
	/*	
		[Embed(source='/assets/eventEditor/eventEditor.swf', symbol='event')]
		[Bindable]
		public var event:Class;
		*/
		public function TreeActions()
		{
			super();
			iconFunction = getIcon;
			
			dataManager = DataManager.getInstance();
		}
		
		private var dataXML:XML ;
		override public function set dataProvider(value:Object):void
		{
			dataXML  = new XML('<Object/>');
			dataXML.@label 	= value.@label;
			dataXML.@resourceID = value.@resourceID;
			
			var type:XML = dataManager.getTypeByTypeId(value.@Type);
			var curContainerTypeID:String = dataManager.getTypeByObjectId(value.@ID).Information.ID.toString();
			var actions:XML = type.E2vdom.Actions.Container.(@ID == curContainerTypeID)[0];
			var tempXML:XML;
			
			if(actions != null)		
				for each(var child:XML in actions.children() )
				{
				 	tempXML = <Event/>;
					tempXML.@label = child.@MethodName;
					tempXML.@MethodName  = child.@MethodName;
					tempXML.@ObjTgtID = value.@ID;
					tempXML.@containerID = value.@containerID;
					
					dataXML.appendChild(tempXML);
				} 
			
			value = value as XML;
			for each(child in value.children())
			{
				dataXML.appendChild(getChilds(child))
			}
			
			super.dataProvider = dataXML;
			validateNow();
			var item:Object =  XMLListCollection(dataProvider).source[0];
			
		//	super.selectedIndex = 0;
			
			
			expandItem(item, true, false);
			
			
		}
		
		private function getChilds(inXML:XML):XML
		{
			var outXML:XML = new XML(inXML.toXMLString());
			var type:XML = dataManager.getTypeByTypeId(inXML.@Type);
			var curContainerTypeID:String = dataManager.getTypeByObjectId(inXML.@containerID).Information.ID.toString();
			var actions:XML = type.E2vdom.Actions.Container.(@ID == curContainerTypeID)[0]; 
			var tempXML:XML;
			
			if(actions != null)		
				for each(var child:XML in actions.children() )
				{
				 	tempXML = <Event/>;
					tempXML.@label = child.@MethodName;
					tempXML.@MethodName  = child.@MethodName;
					tempXML.@ObjTgtID = inXML.@ID;
					tempXML.@containerID = inXML.@containerID;
					
					outXML.appendChild(tempXML);
				} 
			
			return outXML;
		}
		
		 private function getIcon(value:Object):Class 
		{
			var xmlData:XML = XML(value);
		
			if (xmlData.@resourceID.toXMLString() =='')
				return action;
		
			var data:Object = {typeId:xmlData.@Type, resourceId:xmlData.@resourceID}
		 	
	 		return IconUtil.getClass(this, data, 16, 16);
		}
	}
}