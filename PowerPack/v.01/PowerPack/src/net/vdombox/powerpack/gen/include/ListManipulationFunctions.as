// ActionScript file

import net.vdombox.powerpack.gen.parse.ListParser;

public function length(list:String):int
{
	return ListParser.length(list);
}

public function getValue(position:Object, list:String):Object
{
	var contexts:Array = getContexts();
	var elmValue:Object = ListParser.getElmValue(list, position, contexts);	
	return elmValue;
}

public function getType( position : Object, list : String ): int
{
	var type:int = ListParser.getType(list, position);
	return type;
}

public function exist(type:Object, value:Object, list:String):int
{
	var position:int = ListParser.exists(list, type, value.toString());
	return position;
}

public function remove(position:Object, list:String):String
{
	var newList:String = ListParser.remove(list, position);
	return newList;
}

public function put(type:Object, position:Object, value:Object, list:String):String
{
	var newList:String = ListParser.put(list, position, type, value.toString());
	return newList;
}

public function update(type:Object, position:Object, value:Object, list:String):String
{
	var newList:String = ListParser.update(list, position, type, value.toString());
	return newList;
}

public function evaluate(list:String):String
{
	return ListParser.evaluate(list, getContexts());
}

public function execute(list:String):*
{
	return ListParser.execute(list, getContexts());
}

public function addStructure(src:String, tgt:String, level:int, listStruct:String):String 
{
	var newStruct:String = processStructure(src, tgt, level, listStruct, 'add');
	return newStruct;
}

public function updateStructure(src:String, tgt:String, level:int, listStruct:String):String 
{
	var newStruct:String = processStructure(src, tgt, level, listStruct, 'update');
	return newStruct;
}

public function deleteStructure(src:String, tgt:String, level:int, listStruct:String):String
{
	var newStruct:String = processStructure(src, tgt, level, listStruct, 'delete');
	return newStruct;
}

private function processStructure(src:String, tgt:String, level:int, listStruct:String, action:String='add'):String
{
	var contexts:Array = getContexts();
	
	var listSrcObj:Array = ListParser.list2Array(src);
	var listTgtObj:Array = ListParser.list2Array(tgt);
	var listStructObj:Array = ListParser.list2Array(listStruct);
	
	var topLevelListLen:int = ListParser.length(listStructObj);
	
	var idSrc:String = src;
	if(listSrcObj) 
		idSrc = ListParser.getElmValue(listSrcObj, 1, contexts).toString();
	
	var idTgt:String = tgt;
	if(listTgtObj) 
		idTgt = ListParser.getElmValue(listTgtObj, 1, contexts).toString();
	
	for(var i:int=1; i<=topLevelListLen; i++)
	{
		var topLevelList:String = ListParser.getElm(listStruct, i);
		var objSrcList:String = ListParser.getElm(topLevelList, 1);		
		var idObjSrc:String = ListParser.getElmValue(objSrcList, 1, contexts).toString();
	
		if(idObjSrc == idSrc)
			break;		
	}	
	
	if(i<=topLevelListLen)
	{
		var lvlLinkList:String = ListParser.getElm(topLevelList, 2);
		var lvlLinkListLen:int = ListParser.length(lvlLinkList);
		
		for(var j:int=1; j<=lvlLinkListLen; j++)
		{
			var lvlObjTgtList:String = ListParser.getElm(lvlLinkList, j);
			var lvl:int = int(ListParser.getElmValue(lvlObjTgtList, 1, contexts));
			
			if(level == lvl)
				break;
		}
		
		if(j<=lvlLinkListLen)
		{
			var objTgtList:String = ListParser.getElm(lvlObjTgtList, 2);
			var objTgtListLen:int = ListParser.length(objTgtList);
			
			for(var k:int=1; k<=objTgtListLen; k++)
			{
				var idObjTgt:String = ListParser.getElmValue(objTgtList, k, contexts).toString();
				
				if(idObjTgt == idTgt)
					break;
			}
			
			if(k<=objTgtListLen)
			{
				switch(action)
				{
					case 'delete':
						objTgtList = ListParser.remove(objTgtList, k);
						lvlObjTgtList = ListParser.update(lvlObjTgtList, 2, 'list', objTgtList);
						lvlLinkList = ListParser.update(lvlLinkList, j, 'list', lvlObjTgtList);
						topLevelList = ListParser.update(topLevelList, 2, 'list', lvlLinkList);
						listStruct = ListParser.update(listStruct, i, 'list', topLevelList);
						break;
					case 'update':
					case 'add':
					default:
				}
			}	
			else
			{
				switch(action)
				{
					case 'add':
						objTgtList = ListParser.put(objTgtList, 'tail', 'string', idTgt);
						lvlObjTgtList = ListParser.update(lvlObjTgtList, 2, 'list', objTgtList);
						lvlLinkList = ListParser.update(lvlLinkList, j, 'list', lvlObjTgtList);
						topLevelList = ListParser.update(topLevelList, 2, 'list', lvlLinkList);
						listStruct = ListParser.update(listStruct, i, 'list', topLevelList);
						break;
					case 'update':
					case 'delete':
					default:
				}				
			}	
		}
		else
		{
			switch(action)
			{
				case 'add':
					objTgtList = ListParser.put('[]', 'tail', 'string', idTgt);
					lvlObjTgtList = ListParser.put('[]', 'head', 'word', level.toString());				
					lvlObjTgtList = ListParser.put(lvlObjTgtList, 'tail', 'list', objTgtList);				
					lvlLinkList = ListParser.put(lvlLinkList, 'tail', 'list', lvlObjTgtList);
					topLevelList = ListParser.update(topLevelList, 2, 'list', lvlLinkList);
					listStruct = ListParser.update(listStruct, i, 'list', topLevelList);
					break;
				case 'update':
				case 'delete':
				default:
			}				
		}
		
		switch(action)
		{
			case 'update':
				if(listSrcObj.result)
				{
					objSrcList = ListParser.update(objSrcList, 2, 'word', ListParser.getElmValue(src, 2, contexts).toString());
					objSrcList = ListParser.update(objSrcList, 3, 'word', ListParser.getElmValue(src, 3, contexts).toString());
					objSrcList = ListParser.update(objSrcList, 4, 'string', ListParser.getElmValue(src, 4, contexts).toString());
					
					topLevelList = ListParser.update(topLevelList, 1, 'list', objSrcList);
					listStruct = ListParser.update(listStruct, i, 'list', topLevelList);
				}
				break;				
			case 'delete':
			case 'add':
			default:
		}		
	}
	else
	{
		switch(action)
		{
			case 'add':
				objTgtList = ListParser.put('[]', 'tail', 'string', idTgt);
				lvlObjTgtList = ListParser.put('[]', 'head', 'word', level.toString());				
				lvlObjTgtList = ListParser.put(lvlObjTgtList, 'tail', 'list', objTgtList);								
				lvlLinkList = ListParser.put('[]', 'tail', 'list', lvlObjTgtList);				
				
				objSrcList = ListParser.put('[]', 'head', 'string', idSrc);
				if(listSrcObj.result)
				{
					objSrcList = ListParser.put(objSrcList, 'tail', 'word', ListParser.getElmValue(src, 2, contexts).toString());
					objSrcList = ListParser.put(objSrcList, 'tail', 'word', ListParser.getElmValue(src, 3, contexts).toString());
					objSrcList = ListParser.put(objSrcList, 'tail', 'string', ListParser.getElmValue(src, 4, contexts).toString());
				}
								
				topLevelList = ListParser.put('[]', 'head', 'list', objSrcList);
				topLevelList = ListParser.put(topLevelList, 'tail', 'list', lvlLinkList);
				
				listStruct = ListParser.put(listStruct, 'tail', 'list', topLevelList);
				break;
			case 'update':
			case 'delete':
			default:
		}			
	}
	
	return listStruct;
}