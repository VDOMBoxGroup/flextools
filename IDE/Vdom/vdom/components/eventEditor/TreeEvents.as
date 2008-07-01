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
		//	this.itemRenderer = EventItemRender;
	//		addEventListener(MouseEvent.MOUSE_DOWN, changeItemHandler)
			
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

			return outXML;
		}
		
		/*
		public class MyTIR extends TreeItemRenderer
		{
			public function MyTIR()
			{
				super();
			}
			
			public override function set enabled(value:Boolean):void {
				
				if(!data) {
					super.enabled = value;
					return;
				}
				
				var val:XML = XML(data);
				
				if(val.@enabled[0] && val.(@enabled == false))
					super.enabled = false;
				else
					super.enabled = value;
			}
		}
		}
*/


	/*	
		private var _selectedItem:Object;
		private function changeItemHandler(evt:Event):void
		{
			_selectedItem = evt.currentTarget;
		}
		
		public function enabledItem():void
		{
			_selectedItem.enabled = false;
		}
		*/
		
	}
}