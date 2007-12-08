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
		//	trace(xml);
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
		
	public function dataToXML(massTreeElements:Array, massLines:Array ):XML
	{
		
					/*** оптимизировать!!!**/
		var outXML:XML = <Structure/> ;
		//trace('1 XML to server: ' + outXML.toString());
		
		for (var levels:String in massTreeElements)
		{
			var xmlList:XMLList = new XMLList('<Object/>');
			xmlList.@ID = levels;
					xmlList.@left = massTreeElements[levels].x;
					xmlList.@top = massTreeElements[levels].y;
					xmlList.@ResourceID = massTreeElements[levels].resourceID;
					outXML.appendChild(xmlList.toXMLString());
					

		}
		
	//	trace('1 XML to server: ' + outXML.toString())
		for (var level:String in massLines)
		for(var ind1:String in massLines[level])
			for(var ind2:String in massLines[level][ind1])
			{

				// создаем все елементы дерева
				var object:XMLList = new XMLList('<Object/>');

				if (outXML.Object.(@ID == ind1).@ID != ind1 )
				{
					object.@ID = ind1;
					object.@left = massTreeElements[ind1].x;
					object.@top = massTreeElements[ind1].y;
					object.@ResourceID = massTreeElements[ind1].resourceID;
					outXML.appendChild(object.toXMLString());
				}
				
		//		trace('2 XML to server: ' + outXML.toString());
				var levelXMLList:XMLList = new XMLList('<Level/>');
				if(outXML.Object.(@ID == ind1).Level.(@Index == level).@Index != level)
				{
					levelXMLList.@Index = level;
					outXML.Object.(@ID == ind1).appendChild(levelXMLList);
				}
				
				var myXMLList:XMLList = new XMLList('<Object/>') ;
				myXMLList.@ID = ind2;
				outXML.Object.(@ID == ind1).Level.(@Index == level).appendChild(myXMLList);
				
				
				if (outXML.Object.(@ID == ind2).@ID != ind2 )
				{
					object.@ID = ind2;
					object.@left = massTreeElements[ind2].x;
					object.@top = massTreeElements[ind2].y;
					object.@ResourceID = massTreeElements[ind1].resourceID;
					outXML.appendChild(object.toXMLString());
				}	
			}
			
			trace(' _XML to server: ' + outXML.toString());
			return outXML;
	}
		
		public function drLine(mouseX:Number, mouseY:Number, curTree:Object):Object
		{
			var tX:int = mouseX - curTree.x;
			var tY:int = mouseY - curTree.y;
			
			var pnTo:Object = new Object();
			// чтоб мышка не кликала по своей линии
			
			if((tX>0))	pnTo.x = mouseX - 10;
				else pnTo.x = mouseX + 10;
			
			if( (tY>0))	pnTo.y = mouseY - 10;
				else pnTo.y = mouseY + 10;
				
			return pnTo;
		}
	
	
	}
}