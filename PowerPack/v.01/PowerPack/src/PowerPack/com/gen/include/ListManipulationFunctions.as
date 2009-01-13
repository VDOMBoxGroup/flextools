// ActionScript file
import PowerPack.com.gen.ParsedNode;
import PowerPack.com.gen.parse.CodeParser;
import PowerPack.com.gen.parse.ListParser;
import PowerPack.com.gen.parse.Parser;

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

public function getType(position:Object, list:String):int
{
	var type:int = ListParser.getType(list, position);
	return type;
}

public function exist(type:Object, value:Object, list:String):int
{
	var position:int = ListParser.exists(list, type, value);
	return position;
}

public function remove(position:Object, list:String):String
{
	var newList:String = ListParser.remove(list, position);
	return newList;
}

public function put(type:Object, position:Object, value:Object, list:String):String
{
	var newList:String = ListParser.put(list, position, type, value);
	return newList;
}

public function update(type:Object, position:Object, value:Object, list:String):String
{
	var newList:String = ListParser.update(list, position, type, value);
	return newList;
}

public function evaluate(list:String):String
{
	var contexts:Array = getContexts();
	
	var lexems:Array = Parser.getLexemArray(list);
	Parser.processLexemArray(lexems);
    lexems = Parser.convertLexemArray(lexems);
    var lexemObj:Object = Parser.processConvertedLexemArray(lexems, contexts);
    lexems = lexemObj.array;
    
	var buffer:String = "";
	
	for(var i:int=0; i<lexems.length; i++)
	{
		var value:Object = null;
		 
    	if( lexems[i].type=="v" )
    	{
			for(var j:int=contexts.length-1; j>=0; j--)
			{
				var context:* = contexts[j];
			
    			if( context.hasOwnProperty(lexems[i].value) )
    			{
					value = context[lexems[i].value];
    				break;
    			}
    		}
        }	
		buffer += (buffer?" ":"") + (lexems[i].type=="v" ? (value!=null ? value.toString() : 'null') : lexems[i].value);
	}	
	
	return buffer;
}

public function execute(list:String):*
{
	var contexts:Array = getContexts();
	
	var parsedList:ParsedNode = CodeParser.ParseCode(list);
	
	CodeParser.executeCode(parsedList, 0, contexts, tplStruct.curGraphContext.varPrefix); 
	
	if(!parsedList.result) {								
		throw parsedList.error;
	}
	else {
		return parsedList.value;
	}
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
	var topLevelListLen:int = ListParser.length(listStruct);
	
	var listSrcObj:Object = Parser.processList(src);
	var listTgtObj:Object = Parser.processList(tgt);
	var listStructObj:Object = Parser.processList(listStruct);
	
	if(!listStructObj.result)
		throw new Error('Not valid struct list.');	
	
	var idSrc:String = src;
	if(listSrcObj.result) 
		idSrc = ListParser.getElmValue(src, 1, contexts);
	
	var idTgt:String = tgt;
	if(listTgtObj.result) 
		idTgt = ListParser.getElmValue(tgt, 1, contexts);
	
	for(var i:int=1; i<=topLevelListLen; i++)
	{
		var topLevelList:String = ListParser.getElm(listStruct, i);
		var objSrcList:String = ListParser.getElm(topLevelList, 1);		
		var idObjSrc:String = ListParser.getElmValue(objSrcList, 1, contexts);
	
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
				var idObjTgt:String = ListParser.getElmValue(objTgtList, k, contexts);
				
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
					lvlObjTgtList = ListParser.put('[]', 'head', 'word', level);				
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
					objSrcList = ListParser.update(objSrcList, 2, 'word', ListParser.getElmValue(src, 2, contexts));
					objSrcList = ListParser.update(objSrcList, 3, 'word', ListParser.getElmValue(src, 3, contexts));
					objSrcList = ListParser.update(objSrcList, 4, 'string', ListParser.getElmValue(src, 4, contexts));
					
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
				lvlObjTgtList = ListParser.put('[]', 'head', 'word', level);				
				lvlObjTgtList = ListParser.put(lvlObjTgtList, 'tail', 'list', objTgtList);								
				lvlLinkList = ListParser.put('[]', 'tail', 'list', lvlObjTgtList);				
				
				objSrcList = ListParser.put('[]', 'head', 'string', idSrc);
				if(listSrcObj.result)
				{
					objSrcList = ListParser.put(objSrcList, 'tail', 'word', ListParser.getElmValue(src, 2, contexts));
					objSrcList = ListParser.put(objSrcList, 'tail', 'word', ListParser.getElmValue(src, 3, contexts));
					objSrcList = ListParser.put(objSrcList, 'tail', 'string', ListParser.getElmValue(src, 4, contexts));
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