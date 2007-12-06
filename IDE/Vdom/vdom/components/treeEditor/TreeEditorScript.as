package vdom.components.treeEditor
{
	import mx.containers.Canvas;

	public class TreeEditorScript 
	{
		private var treeEditor:TreeEditor;
		
		public function TreeEditorScript():void
		{
			
		}
		
		public function createTreeArr(xml:XML):Array
	{
		var massTreeElements:Array = new Array();
		//создаем массив с обьектами
		for each(var xmlObj:XML in xml.children())
		{
			var obID:String = xmlObj.@ID.toXMLString();
			massTreeElements[obID] =  new TreeElement();
			//massTreeElements[obID].setStyle('backgroundColor', '#ffffff');
			massTreeElements[obID].name = xmlObj.@ID.toXMLString();
			massTreeElements[obID].x = xmlObj.@left.toXMLString();
			massTreeElements[obID].y = xmlObj.@top.toXMLString();	
			massTreeElements[obID].resourceID = xmlObj.@ResourceID.toXMLString();
		}
		return massTreeElements;		
	}
	
	
	
	}
}