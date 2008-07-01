package vdom.components.eventEditor
{
	import vdom.managers.DataManager;
	
	public class TreeActions extends DragTree
	{
		private var dataManager:DataManager ;
		
		public function TreeActions()
		{
			super();
			
			dataManager = DataManager.getInstance();
		}
		
		override public function set dataProvider(value:Object):void
		{
			var dataXML:XML = <root/>;	
			
			for each(var child:XML in value)
			{
				dataXML.appendChild(getChilds(child))
			}
			
			super.dataProvider = dataXML;
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
	}
}