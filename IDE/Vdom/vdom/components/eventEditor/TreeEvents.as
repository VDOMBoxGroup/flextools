package vdom.components.eventEditor
{
	import vdom.managers.DataManager;

	public class TreeEvents extends DragTree
	{
		private var dataManager:DataManager ;
		public function TreeEvents()
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
		/*	
			<Object label="header_image" ID='' Type='' resourceID=''>
				<Event label="onmousedown" parentID="" parentType=""/>
				<Event label="onmousedown2"/>
			</Object>		
			*/	
			
			return outXML;
		}
	}
}