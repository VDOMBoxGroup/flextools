// ActionScript file
		
		import flash.events.MouseEvent;
		
		import mx.effects.Move;
		import mx.effects.easing.Exponential;
		
		import vdom.components.treeEditor.Index;
		import vdom.components.treeEditor.TreeElement;
		import vdom.components.treeEditor.TreeVector;
		import vdom.events.DataManagerEvent;
		import vdom.events.IndexEvent;
		import vdom.events.TreeEditorEvent;
	 
   
   
   	[Embed(source='/assets/treeEditor/treeEditor.swf', symbol='rMenu')]
	[Bindable]
	public var rMenu:Class; 

private function removeAllLines():void
{
//	trace('removeAllLines');
	for (var level:String in massLines)
			for (var frsTrElem:String in massLines[level])
				for (var sknTrElem:String in massLines[level][frsTrElem])
				{
					main.removeChild(masIndex[level][frsTrElem][sknTrElem]);
					delete masIndex[level][frsTrElem][sknTrElem];
					
					main.removeChild(massLines[level][frsTrElem][sknTrElem]);
					delete massLines[level][frsTrElem][sknTrElem];
					
					main.validateDisplayList();
				}
}

private function hideLenes():void
{
//	trace('hideLenes');
	for (var level:String in massLines)
			for (var frsTrElem:String in massLines[level])
				for (var sknTrElem:String in massLines[level][frsTrElem])
				{
					masIndex[level][frsTrElem][sknTrElem].visible = false;
					massLines[level][frsTrElem][sknTrElem].visible = false;
//					main.removeChild(masIndex[level][frsTrElem][sknTrElem]);
//					main.removeChild(massLines[level][frsTrElem][sknTrElem]);
					
//					main.validateDisplayList();
				}
}

private function showLenes():void
{
//	trace('showLenes');
	for (var level:String in massLines)
			for (var frsTrElem:String in massLines[level])
				for (var sknTrElem:String in massLines[level][frsTrElem])
				{
					massLines[level][frsTrElem][sknTrElem].updateVector();
					massLines[level][frsTrElem][sknTrElem].visible = colmen2.showLevel(level)
					masIndex[level][frsTrElem][sknTrElem].visible = shSingnature && colmen2.showLevel(level);
					
//					main.addChild(massLines[level][frsTrElem][sknTrElem]);
					
					
//					main.addChild(masIndex[level][frsTrElem][sknTrElem]);
					
					main.validateDisplayList();
				}
}

private function deleteObject(strID:String):void
{
//	trace('deleteObject');
	for (var level:String in massLines)
		for(var ind1:String in massLines[level])
			for(var ind2:String in massLines[level][ind1])
				if (strID == ind1 || strID == ind2)
				{
					var curIndex:int = masIndex[level][ind1][ind2].index;
					
					 masMaxOfIndex[level][ind1] = masMaxOfIndex[level][ind1] - 1;
					 
					 for(var upDate:String in massLines[level][ind1])
					 {
						masIndex[level][ind1][upDate].maxIndex = masMaxOfIndex[level][ind1];
						
						if(masIndex[level][ind1][upDate].index > curIndex)
							 masIndex[level][ind1][upDate].index = masIndex[level][ind1][upDate].index - 1;
					 }
					
					main.removeChild(masIndex[level][ind1][ind2]);
					 delete masIndex[level][ind1][ind2];
					
					 main.removeChild( massLines[level][ind1][ind2]);
					 delete massLines[level][ind1][ind2];
				}
	
	// удаляем сам обьект
	main.removeChild(massTreeElements[strID]);
	delete massTreeElements[strID];

	curTree = null;
	
	saveToServer();
}

private function drawLine(obj:Object):void
{
//	trace('drawLine');
	var fromObj:String = curTree.ID.toString();
	var toObj:String = obj.ID.toString();
	var level:String = colmen2.selectedItem.level;

	if(!massLines[level]) 
	{
		massLines[level] = new Array();
		masIndex[level] = new Array();
		masMaxOfIndex[level] = new Array();
	}
	
	if(!massLines[level][curTree.ID.toString()]) 
	{
		massLines[level][curTree.ID.toString()] = new Array();
		masIndex[level][curTree.ID.toString()] = new Array();
		masMaxOfIndex[level][curTree.ID.toString()] = 0;
	}
	
	// обьект сам на себя
	if(toObj == fromObj)return;
	
	
		// вдруг противоположная линия уже есть..
	
	if(massLines[level])
		if(massLines[level][toObj])
			if(massLines[level][toObj][fromObj])
				return;
		
		// вдруг эта линия уже есть..
	if(massLines[level][fromObj][toObj] == null)
	{
		massLines[level][fromObj][toObj] 	= 
		new TreeVector(massTreeElements[fromObj], massTreeElements[toObj], level);
		
		main.addChildAt(massLines[level][fromObj][toObj], 0);
		massLines[level][fromObj][toObj].addEventListener(MouseEvent.CLICK, markLines);
		
		var index:Index = new Index();
					index.level = level;
					index.fromObjectID = fromObj;
					index.targetLine = massLines[level][fromObj][toObj];
					index.maxIndex = index.index = masMaxOfIndex[level][fromObj] = masMaxOfIndex[level][fromObj]+ 1;
					
					index.addEventListener(IndexEvent.CHANGE, indexChangeHandler);
					index.visible = shSingnature && colmen2.showLevel(level);
				
				masIndex[level][fromObj][toObj] = index;	
				main.addChild(masIndex[level][fromObj][toObj]);
		
//		saveToServer();
		markButton();
	}
	
	for(var upDate:String in massLines[level][fromObj])
		masIndex[level][fromObj][upDate].maxIndex = masMaxOfIndex[level][fromObj];
	
	
}

private function adjustmentTree(xml1:XML):void
{
//	trace('adjustmentTree');
	var massMap:Array = new Array();
	var massTreeObj:Array = new Array();

	
	for(var obID:String in massTreeElements)
	{
		massTreeObj[obID] = new TreeObj(obID);
		massTreeObj[obID].parent = null;
		massTreeObj[obID].child = null;
	}
	
	if(!xml1.*.length())
		return;

	
	/*

	for each(var xmlObj:XML in xml1.children())
	{
		var obID:String = xmlObj.@ID.toXMLString();
		 massTreeObj[obID] = new TreeObj(obID);
	}
	*/
	
	
	//--------------- begin -----------
	/*
	for each( var xmlObj:XML in xml1.children())
	{
		var fromObID:String = xmlObj.@ID.toXMLString(); 
		for each(var xmlLavel:XML in xmlObj.children())
		{
			if(colmen2.showLevel(xmlLavel.@Index)) // сортируем только видимые линии
			for each(var xmlLavelObj:XML in xmlLavel.children())
			{
				var toObjID:String = xmlLavelObj.@ID.toXMLString();
				massTreeObj[fromObID].child = massTreeObj[toObjID];
				massTreeObj[toObjID].parent = massTreeObj[fromObID];
			}
		}
	}
	 */
	//--------------------- end --------------
	 for (var level:String in massLines)
			for (var frsTrElem:String in massLines[level])
				for (var sknTrElem:String in massLines[level][frsTrElem])
				{
//					massLines[level][frsTrElem][sknTrElem].updateVector();
					massTreeObj[frsTrElem].child = massTreeObj[sknTrElem];
					massTreeObj[sknTrElem].parent = massTreeObj[frsTrElem];
					
				}
	//----------- 
	var depth:int = 0;
	massMap[depth] = -1;
	var itIsCorrectTree:Boolean = false;
	/*  creating tree for top level conteiner whith child */
	for (var name:String in massTreeObj)
	{
		if (massTreeObj[name].parent == null && massTreeObj[name].childs != null)
		{
			setPosition(name);	
			itIsCorrectTree = true;
		} 
	}
	
	 
	if(!itIsCorrectTree)
	{
		for (name in massTreeObj)
		{
			if (massTreeObj[name].parent != null && massTreeObj[name].childs != null)
			setPosition(name);
		}	
	}
	
	// delete last cycle's
	for (name in massTreeObj)
	{
			if (massTreeObj[name].parent
				&& massTreeObj[name].mapX == massTreeObj[name].parent.mapX
				&& massTreeObj[name].mapY == massTreeObj[name].parent.mapY)
			setPosition(name);
	}	
	
	/*  placement top level conteiner whithout child */ 
	var lavel:int
	if(massMap.length == 1)
	{
		lavel = 0;
	}else 
	{
		lavel = massMap.length;
		
	}
	massMap[lavel] = 0;
		
	for (name in massTreeObj)
		if (massTreeObj[name].parent == null && massTreeObj[name].childs == null)
		{
			massTreeObj[name].mapX = massMap[lavel]++;
			massTreeObj[name].mapY = lavel;
			
			if(massMap[lavel] == 5) massMap[++lavel] = 0;
//			setPosition(name);	
//			itIsCorrectTree = true;
		} 
		
//	if(itIsCorrectTree)
//	{

		for (var str:String in massTreeObj)
		{
		
			var moves:Move = new Move();
				
				moves.target = massTreeElements[str];	
				moves.duration = 1500;
				moves.easingFunction = Exponential.easeInOut; 
//				moves.startDelay = 1000;
				moves.xFrom =  massTreeElements[str].x;
				moves.yFrom = massTreeElements[str].y;
				
				moves.xTo = Number(massTreeObj[str].mapX * 220);
				moves.yTo = Number(massTreeObj[str].mapY * 130 + 20);
			/*
				var treeElement:TreeElement = massTreeElements[str];
				treeElement.xTo  = massTreeObj[str].mapX * 220;
				treeElement.yTo  = massTreeObj[str].mapY * 130 + 20;
				treeElement.play();
				
				*/
				moves.play();
		}
		
		
		
	
	function setPosition(inName:String):Boolean
	{
		//были ли у этого обьекта
		if (massTreeObj[inName].marked == true)
				return false;
		// помечаем что были
		massTreeObj[inName].marked = true;
		
		if (massMap[depth] == null)
		{
			if (depth == 0)massMap[depth] = 0;
				else massMap[depth] = massMap[depth-1];
		}
		else
		{
			massMap[depth] = distension();
		} 
		
		massTreeObj[inName].mapX = massMap[depth];
		massTreeObj[inName].mapY = depth;
		massTreeObj[inName].depth = depth;
	
		
		depth++;
		for (var name:String in massTreeObj[inName].childs)
		{
			if(setPosition(name)== true)
				massTreeObj[inName].correctPosition();;
		}
		depth--;
		
		return true;
	}
	
	function  distension():int
	{
		var maxX:int =  massMap[depth-1];
		for(var i:int = depth; i< massMap.length; i++)
		{
			if (massMap[i] == null)
			{
				return maxX;
			}else
			{
				if 	(massMap[i]>= maxX) maxX = massMap[i]+1;
			}
		}
		return maxX;
	}
}

private function addTreeEditorListeners():void
{
//	trace('addTreeEditorListeners');
	addEventListener(MouseEvent.CLICK, mouseClickHandler);
	colmen2.addEventListener(TreeEditorEvent.HIDE_LINES, hideLines);
	colmen2.addEventListener(TreeEditorEvent.SHOW_LINES, showLines);
	colmen2.addEventListener(TreeEditorEvent.SELECTED_LEVEL, chengeSelectedLevelHandler);
	
	dataManager.addEventListener(DataManagerEvent.GET_APPLICATION_STRUCTURE_COMPLETE, getApplicationStructure);
	
	btLine.addEventListener(MouseEvent.CLICK, lineClikHandler );
}

private function removeTreeEditorListeners():void
{
//	trace('removeTreeEditorListeners');
	removeEventListener(MouseEvent.CLICK, mouseClickHandler);
	
	colmen2.removeEventListener(TreeEditorEvent.HIDE_LINES, hideLines);
	colmen2.removeEventListener(TreeEditorEvent.SHOW_LINES, showLines);
	
	dataManager.removeEventListener(DataManagerEvent.GET_APPLICATION_STRUCTURE_COMPLETE, getApplicationStructure);
	
	btLine.removeEventListener(MouseEvent.CLICK, lineClikHandler);
}

private  function removeMassTreeElements():void
{
//	trace('removeMassTreeElements');
		for (var obID:String in massTreeElements)
		{
			main.removeChild(massTreeElements[obID]);
			delete massTreeElements[obID];
		}
}

private var topLevelTypes:XMLList;


private function createTreeArr(xml:XML):void
{
//	trace('createTreeArr');
	topLevelTypes = dataManager.getTopLevelTypes();
	var xmlTopLevelObjects:XMLList = dataManager.listPages;
	
	for each(var page:XML in xmlTopLevelObjects)
	{
		var ID:String = page.@ID.toXMLString();
		var xmlObj:XML = xml.Object.(@ID == ID)[0];
		var treeElement:TreeElement = new TreeElement();
		
		treeElement.ID 	= ID;
		treeElement.name =  page.Attributes.Attribute.(@Name == 'title' );
		treeElement.description = page.Attributes.Attribute.(@Name == 'description' );
		
		var typeID:String = page.@Type;
		treeElement.type  =  getType(typeID);
		treeElement.typeID =  getIcon(typeID);
		treeElement = addEventListenerToTreeElement(treeElement);
		
		/*  проверить если они есть */
		if(xmlObj)
		{
			treeElement.x 			= xmlObj.@left.toXMLString();
			treeElement.y 			= xmlObj.@top.toXMLString();	
			treeElement.state 		= xmlObj.@state.toXMLString();	
			treeElement.resourceID 	= xmlObj.@ResourceID.toXMLString();
			
			if (treeElement.resourceID!='') 
					fileManager.loadResource(dataManager.currentApplicationId, treeElement.resourceID, treeElement);
		} else
		{
			treeElement.x = 0;
			treeElement.y = 0;	
		}
		
		massTreeElements[ID] =  treeElement;
//		main.addChild(massTreeElements[ID]);
	}
	
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
/***
 *  аккорды
 * -------------------------------------------------
 * 
 * ***/
private var massIconResouceID:Array = new Array(); 
private function getIcon(ID:String):String
{
	if (massIconResouceID[ID])
		return massIconResouceID[ID]
		
	for each(var lavel:XML in topLevelTypes )
	{																//2330fe83-8cd6-4ed5-907d-11874e7ebcf4 /#Lang(001)
			if( lavel.Information.ID == ID) 
			{
				var strLabel:String = lavel.Information.Icon;
				return  massIconResouceID[ID] = strLabel.substr(5, 36);
			}
	}
	return  '';
}

private function get needCreatTree():Boolean
	{
		var flag:Boolean = false;
		// x,y == 0;
//		var calc:int = 0;
		for(var strID:String in massTreeElements)
		{		
			if ( massTreeElements[strID].y == 0) 
			{
				flag = true;
				massTreeElements[strID].y = 15;
			}
		}	
	
		return flag;
	}
	


private function addEventListenerToTreeElement(treEl:TreeElement):TreeElement
{
			treEl.addEventListener(TreeEditorEvent.REDRAW_LINES , treeElementLinesReDrawHandler);
			treEl.addEventListener(TreeEditorEvent.START_DRAW_LINE , startDrawLine);
			treEl.addEventListener(TreeEditorEvent.DELETE , deleteTreeElement);
			treEl.addEventListener(TreeEditorEvent.START_REDRAW_LINES, startReDrawLineHandler);
			treEl.addEventListener(TreeEditorEvent.STOP_REDRAW_LINES, stopReDrawLineHandler);
			treEl.addEventListener(TreeEditorEvent.CHANGE_START_PAGE, changeStartPageHandler);
			treEl.addEventListener(TreeEditorEvent.SAVE_TO_SERVER, saveToServerHandler);

			treEl.addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			treEl.addEventListener(MouseEvent.MOUSE_OUT, treeElementMouseOutHandler);
			treEl.addEventListener(MouseEvent.MOUSE_OVER, treeElementMouseOverHandler);
			
			return treEl;
}

private function drawLines(xml1:XML):void
{
//	trace('drawLines');
	for each(var xmlObj:XML in xml1.children())
	{
		var obID:String = xmlObj.@ID.toXMLString();
		
		//создаем массив с Направляю`щими между обьектами
		for each(var xmlLavel:XML in xmlObj.children())
		{
			var level:String = xmlLavel.@Index.toXMLString();
			// mass of levels where  level  consist of numbers betvin 0-9
			if (!massLines[level])
			{
				massLines[level] = new Array();
				masIndex[level] = new Array();
				masMaxOfIndex[level] = new Array();
			} 
			if (!massLines[level][obID])
			{	 
				massLines[level][obID] = new Array();	
				masIndex[level][obID] = new Array();
				
			}
			
			masMaxOfIndex[level][obID] = 0;
			for each(var xmlLavelObj:XML in xmlLavel.children())
			{
					masMaxOfIndex[level][obID]++;
			}
			
			var counter:int = 0;
			for each(xmlLavelObj in xmlLavel.children())
			{
				var toObjID:String = xmlLavelObj.@ID.toXMLString();
				if (obID != toObjID && massTreeElements[obID] && massTreeElements[toObjID])// избавляемся от зацикливающихся обьектов
				{
					
					massLines[level][obID][toObjID] = new TreeVector(massTreeElements[obID], massTreeElements[toObjID], level);
					massLines[level][obID][toObjID].addEventListener(MouseEvent.CLICK, markLines);
					massLines[level][obID][toObjID].visible = colmen2.showLevel(level);
					main.addChildAt(massLines[level][obID][toObjID], 0);
					
					
					var index:Index = new Index();
						index.level = level;
						index.fromObjectID = obID;
						if(xmlLavelObj.@Index[0])
							index.index = xmlLavelObj.@Index.toXMLString();
						else
							index.index = ++counter;
						
							
						index.maxIndex = masMaxOfIndex[level][obID];	
						index.targetLine = massLines[level][obID][toObjID];
						index.visible = shSingnature && colmen2.showLevel(level);
//						trace(index.visible);
						index.addEventListener(IndexEvent.CHANGE, indexChangeHandler);
						
				
					masIndex[level][obID][toObjID] = index;	
					main.addChild(masIndex[level][obID][toObjID]);
				}
			}
		}
	}
	// tree Elements to top	
	for (var ID:String in massTreeElements)
	{
		if(!main.contains(massTreeElements[ID]))
			main.addChild(massTreeElements[ID]);
	}
//	drawIndex();
}


/***
	* 
	* ---------- перерисовываем необходимые линии -----------------
	*
	*/
	
private function redrawLines(strID:String):void
{
	if (main.contains(btLine))
	{
			main.removeChild(btLine);
			curLine.mark = false;
	}
			
	//trace(strID);
	for (var level:String in massLines)
		for(var ind1:String in massLines[level])
			for(var ind2:String in massLines[level][ind1])
				if (strID == ind1 || strID == ind2)
					massLines[level][ind1][ind2].updateVector();
}

private function  removeLine():void
{
	for (var level:String in massLines)
			for (var frsTrElem:String in massLines[level])
				for (var sknTrElem:String in massLines[level][frsTrElem])
					if(curLine  == massLines[level][frsTrElem][sknTrElem] )
					{
						masMaxOfIndex[level][frsTrElem] = masMaxOfIndex[level][frsTrElem] - 1;
						
						var curIndex:int = masIndex[level][frsTrElem][sknTrElem].index;
					
						
						 for(var upDate:String in massLines[level][frsTrElem])
						 {
							masIndex[level][frsTrElem][upDate].maxIndex = masMaxOfIndex[level][frsTrElem];
							
							if(masIndex[level][frsTrElem][upDate].index > curIndex)
								 masIndex[level][frsTrElem][upDate].index = masIndex[level][frsTrElem][upDate].index - 1;
						 }
						
						main.removeChild(massLines[level][frsTrElem][sknTrElem]);
						delete massLines[level][frsTrElem][sknTrElem];
						
						main.removeChild(masIndex[level][frsTrElem][sknTrElem]);
						delete masIndex[level][frsTrElem][sknTrElem];
						//btLine.visible = false;
					}
					
	if (main.contains(btLine))
	{
		main.removeChild(btLine);
		curLine.mark = false;
	}
	
	markButton();	
//	saveToServer();
}

private function markButton():void
{
	btSave.mark = true;
//	btSave.setStyle("color", "0xCC0000");
//	btSave.setStyle("borderColor", "0xEE0000");
}


private function unMarkButton():void
{
	btSave.mark = false;
	/*
	btSave.setStyle("color", "0x000000");
	btSave.setStyle("borderColor", "0xAAB3B3");
	*/
}


private function saveToServer():void
{
	unMarkButton();
				
	var dataToServer:XML =  dataToXML(massTreeElements, massLines);
	xmlApplicationStructure = dataToServer;
//	if(dataToServer.*.length() > 0)
	
											
	 	dataManager.addEventListener(DataManagerEvent.SET_APPLICATION_STRUCTURE_COMPLETE, dataManagerListenner)
		dataManager.setApplicationStructure(dataToServer);
		
	
        
//		dataManager.addEventListener(DataManagerEvent.DELETE_OBJECT_COMPLETE, deleteObjectHandler)
        
	trace('********  Data saved  ********\n' + dataToServer.toXMLString());
}

private function revert():void
{
		removeAllLines();
		removeMassTreeElements();
//		removeTreeEditorListeners();
		
		if(curTree)
			dataManager.changeCurrentPage(curTree.ID);

		if (main.contains(btLine))
		{
			main.removeChild(btLine);
			curLine.mark = false;
		}
			
		masIndex = [];
		masMaxOfIndex = [];
		massLines = [];
	
		dataManager.getApplicationStructure();
}

public function dataToXML(massTreeElements:Array, massLines:Array ):XML
{
//	trace('dataToXML');
	var outXML:XML = <Structure/> ;
	
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
			myXMLList.@Index = masIndex[level][ind1][ind2].index;
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
		
//		trace(' _XML to server: \n' + outXML.toString());
		return outXML;
}
		
private function calculatePointTo(mouseX:Number, mouseY:Number, curTree:Object):Object
{
	var tX:int = mouseX - curTree.x;
	var tY:int = mouseY - curTree.y;
	
	var pnTo:Object = new Object();
	// чтоб мышка не кликала по своей линии
	
	if((tX>0))	pnTo.x = mouseX - 4;
		else pnTo.x = mouseX + 4;
	
	if( (tY>0))	pnTo.y = mouseY - 4;
		else pnTo.y = mouseY + 4;
		
	return pnTo;
}

private function get randomTreeElement():String
{
//	trace('randomTreeElement');
	for (var ID:String in massTreeElements)
	{
		return ID;
	}	
	
	return '';
}

private function setStartPage():void
{
//	trace('setStartPage');
	if(!massTreeElements[startPage])
	{
		startPage = randomTreeElement;
		if(startPage)
			massTreeElements[startPage].selected = true;
	} else
	{
		massTreeElements[startPage].selected = true;
	}
}


/*

private function drawIndex():void
{
//	trace('DrawIndex');
	for (var level:String in massLines)
	{
		if(!masIndex[level]) masIndex[level] = new Array();
		
		for(var ind1:String in massLines[level])
		{
			 if(!masIndex[level][ind1]) masIndex[level][ind1] = new Array();
			
			for(var ind2:String in massLines[level][ind1])
			{
				
			}
		}
	}
}
*/
private function indexChangeHandler(inEvt:IndexEvent):void
{
//	trace('indexChangeHandler');
//	trace('work');
	
		for(var toID:String in masIndex[inEvt.level][inEvt.fromObjectID])
		{  
			var index:Index = masIndex[inEvt.level][inEvt.fromObjectID][toID];
			
			if(inEvt.newIndex < inEvt.lastIndex)
			{
				if (index.index >= inEvt.newIndex &&  index.index <= inEvt.lastIndex)
				{
					index.index = index.index + 1;
				}
			} else
			{
				if (index.index <= inEvt.newIndex &&	index.index >= inEvt.lastIndex)
				{
					index.index = index.index - 1;
				}
			}
		}
		
//		trace('indexChangeHandler');
//		saveToServer();
		markButton();
	
}
//data.@Top[0]



