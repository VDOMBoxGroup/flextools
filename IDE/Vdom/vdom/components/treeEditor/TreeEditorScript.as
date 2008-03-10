package vdom.components.treeEditor
{
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
		
		public function createTreeElement(xmlObj:XML):TreeElement
		{
				var obID:String = xmlObj.Object.@ID;
				var treeElement:TreeElement =  new TreeElement();
				//massTreeElements[obID].setStyle('backgroundColor', '#ffffff');
				treeElement.ID = obID;
//				massTreeElements[obID].name =  xmlTopLevelObjects.Object.(@ID == obID ).@Name;
				treeElement.name =  xmlObj.Object.Attributes.Attribute.(@Name == 'title' );
				treeElement.description = 'test';
				//treeElement.description = xmlObj.Object.Attributes.Attribute.(@Name == 'description' );
				treeElement.x = 0;
				treeElement.y = 0;	
				treeElement.resourceID = xmlObj.Object.@Type.toXMLString();
				var typeID:String = xmlObj.Object.@Type.toXMLString();
				treeElement.type  =  getType(typeID);
			
			return treeElement;		
		}
/*<Result>
  <Object Name="htmlcontainer_1dc7709a_91ef_4516_be6d_04ddea6aa18a" ID="1dc7709a-91ef-4516-be6d-04ddea6aa18a" Type="2330fe83-8cd6-4ed5-907d-11874e7ebcf4">
    <Attributes>
      <Attribute Name="hierarchy">0</Attribute>
      <Attribute Name="visible">1</Attribute>
      <Attribute Name="zindex">0</Attribute>
      <Attribute Name="description"/>
      <Attribute Name="title">1</Attribute>
    </Attributes>
    <Script/>
  </Object>
  <Parent/>
  <Key>6629904319_38</Key>
</Result>*/
	
			private function getType(ID:String):String
			{
				
			//	var types:XML = dataManager.getTopLevelTypes();
		/****         сделать так чтоб нормально возвращалось значение         **/
				for each(var lavel:XML in topLevelTypes.Type )
				{
				
						var strLabel:String = getLanguagePhrase(ID, topLevelTypes.Type.Information.DisplayName);
						var strID:String = lavel.Information.ID;
						//trace(strID+ ' ! '  +ID );
				//		arrAppl.push({label:strLabel, data:strID});
				}
				return  strLabel;
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