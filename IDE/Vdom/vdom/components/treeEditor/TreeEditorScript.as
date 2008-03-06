package vdom.components.treeEditor
{
	import mx.containers.Canvas;
	import vdom.Languages;
	import vdom.managers.DataManager;

	public class TreeEditorScript 
	{
		private var treeEditor:TreeEditor;
		private var languages:Languages;
		private var dataManager:DataManager  = DataManager.getInstance();
		private var topLevelTypes:XML;
		
		public function TreeEditorScript():void
		{
			languages = Languages.getInstance();
			
		}
		
		public function createTreeArr(xml:XML, xmlTopLevelObjects:XML):Array
		{
			topLevelTypes = dataManager.getTopLevelTypes();
		//	trace(xml);
			var massTreeElements:Array = new Array();
			//создаем массив с обьектами
			for each(var xmlObj:XML in xml.children())
			{
				var obID:String = xmlObj.@ID.toXMLString();
				massTreeElements[obID] =  new TreeElement();
				//massTreeElements[obID].setStyle('backgroundColor', '#ffffff');
				massTreeElements[obID].ID = xmlObj.@ID.toXMLString();
//				massTreeElements[obID].name =  xmlTopLevelObjects.Object.(@ID == obID ).@Name;
				massTreeElements[obID].name =  xmlTopLevelObjects.Object.(@ID == obID ).Attributes.Attribute.(@Name == 'title' );
				massTreeElements[obID].description = xmlTopLevelObjects.Object.(@ID == obID ).Attributes.Attribute.(@Name == 'description' );
				massTreeElements[obID].x = xmlObj.@left.toXMLString();
				massTreeElements[obID].y = xmlObj.@top.toXMLString();	
				massTreeElements[obID].resourceID = xmlObj.@ResourceID.toXMLString();
				
				var typeID:String = xmlTopLevelObjects.Object.(@ID == obID ).@Type;
				massTreeElements[obID].type  =  getType(typeID);
				
			/*	trace('********************')
				trace(obID)
			//	var tempObj:* = xmlTopLevelObjects.Object.(@ID == obID ).Attribute;
				trace(xmlTopLevelObjects.Object.(@ID == obID ).Attributes.Attribute.(@Name == 'description' ))*/
			}
			return massTreeElements;		
		}
		
	
			private function getType(ID:String):String
			{
				
			//	var types:XML = dataManager.getTopLevelTypes();
		
				for each(var lavel:XML in topLevelTypes.Type )
				{
						var strLabel:String = getLanguagePhrase(lavel.Information.ID, lavel.Information.DisplayName);
						var strID:String = lavel.Information.ID;
				//		arrAppl.push({label:strLabel, data:strID});
				}
				return ID;
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
			
		//	trace(' _XML to server: ' + outXML.toString());
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
	public function getLanguagePhrase(typeID:String, phraseID:String):String {
		
		var phraseRE:RegExp = /#Lang\((\w+)\)/;
		phraseID = phraseID.match(phraseRE)[1];
		var languageID:String = typeID + '-' + phraseID;
		
		return languages.language.(@ID == languageID)[0];
	}
	
	}
}