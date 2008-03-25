package vdom.components.treeEditor
{
	import mx.resources.IResourceManager;
	import mx.resources.ResourceManager;
	
	import vdom.managers.DataManager;

	public class TreeEditorScript 
	{
		private var treeEditor:TreeEditor;
	//	private var languages:Languages;
		private var dataManager:DataManager  = DataManager.getInstance();
		private var topLevelTypes:XMLList;
		private var resourceManager:IResourceManager;
		
		public function TreeEditorScript():void
		{
			resourceManager = ResourceManager.getInstance();
			//languages = Languages.getInstance();
			
		}
		
		public function createTreeArr(xml:XML, xmlTopLevelObjects:XMLList):Array
		{
			topLevelTypes = dataManager.getTopLevelTypes();
			//trace(xml);
			var massTreeElements:Array = new Array();
			//создаем массив с обьектами
			for each(var xmlObj:XML in xml.children())
			{
				var obID:String = xmlObj.@ID.toXMLString();
				var page:XML = xmlTopLevelObjects.(@ID == obID )[0];
		//		trace(obID);
				massTreeElements[obID] =  new TreeElement();
				massTreeElements[obID].ID = xmlObj.@ID.toXMLString();
				massTreeElements[obID].name =  page.Attributes.Attribute.(@Name == 'title' );
				massTreeElements[obID].description = page.Attributes.Attribute.(@Name == 'description' );
				massTreeElements[obID].x = xmlObj.@left.toXMLString();
				massTreeElements[obID].y = xmlObj.@top.toXMLString();	
				massTreeElements[obID].state = xmlObj.@state.toXMLString();	
				massTreeElements[obID].resourceID = xmlObj.@ResourceID.toXMLString();
				
				var typeID:String = page.@Type;
				massTreeElements[obID].type  =  getType(typeID);
			}
			return massTreeElements;		
		}
		
		public function createTreeElement(xmlObj:XML):TreeElement
		{
				var obID:String = xmlObj.Object.@ID;
				var treeElement:TreeElement =  new TreeElement();
				treeElement.ID = obID;
				treeElement.name =  xmlObj.Object.Attributes.Attribute.(@Name == 'title' );
				
				treeElement.description = 'test';
				treeElement.x = 0;
				treeElement.y = 0;	
				treeElement.resourceID = xmlObj.Object.@Type.toXMLString();
				var typeID:String = xmlObj.Object.@Type.toXMLString();
				treeElement.type  =  getType(typeID);
			
			return treeElement;		
		}
	
		private function getType(ID:String):String
		{
			
	
			for each(var lavel:XML in topLevelTypes )
			{																//2330fe83-8cd6-4ed5-907d-11874e7ebcf4 /#Lang(001)
					if( lavel.Information.ID == ID) {
					var strLabel:String = getLanguagePhrase(lavel.Information.Name, lavel.Information.DisplayName);
					return  strLabel;}
			}
			return  'Void';
		}

		public function getLanguagePhrase(name:String, phrase:String):String
		{
			var phraseRE:RegExp = /#Lang\((\w+)\)/;
			var phraseID:String = phrase.match(phraseRE)[1]; //001
			
			return resourceManager.getString(name, phraseID);
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
						xmlList.@state = massTreeElements[levels].state;
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
						object.@state = massTreeElements[ind1].state;
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
						object.@ResourceID = massTreeElements[ind2].resourceID;
						object.@state = massTreeElements[ind2].state;
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
	
	
	}
}