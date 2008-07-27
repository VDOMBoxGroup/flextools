// ActionScript file
import PowerPack.com.gen.parse.ListParser;
import PowerPack.com.gen.parse.Parser;

 /**
 * length function section
 */		 
public function _length(list:String):int
{
	Application.application.callLater(generate);
	
	return ListParser.length(list);
}

 /**
 * get function section
 */		 
public function _get(position:Object, list:String):*
{
	var type:int = ListParser.getType(list, position);	
	var ret:String = ListParser.getElm(list, position);	
	var contexts:Array = [context, GraphContext(contextStack[contextStack.length-1]).context];
	
	if(!ret)
		ret = '';
	//else if(type==2)
		//ret = Utils.replaceQuotes(ret);
	else if(type==4 || type==2)
		//ret = ret.substr(1);
		ret = ListParser.getElmValue(list, position, contexts);	
		
	Application.application.callLater(generate);
	return ret;
}

 /**
 * getType function section
 */		 
public function _getType(position:Object, list:String):*
{
	var ret:* = ListParser.getType(list, position);

	if(!ret)
		ret = '';
		
	Application.application.callLater(generate);
	return ret;
}

 /**
 * exist function section
 */		 
public function _exist(type:Object, value:Object, list:String):*
{
	var ret:* = ListParser.exists(list, type, value);

	if(!ret)
		ret = '';
		
	Application.application.callLater(generate);
	return ret;
}

 /**
 * delete function section
 */		 
public function _delete(position:Object, list:String):*
{
	var ret:* = ListParser.remove(list, position);

	if(!ret)
		ret = '';
		
	Application.application.callLater(generate);
	return ret;
}

 /**
 * put function section
 */		 
public function _put(type:Object, position:Object, value:Object, list:String):*
{
	var ret:* = ListParser.put(list, position, type, value);

	if(!ret)
		ret = '';
		
	Application.application.callLater(generate);
	return ret;
}

/**
 * update function section
 */		 
public function _update(type:Object, position:Object, value:Object, list:String):*
{
	var ret:* = ListParser.update(list, position, type, value);

	if(!ret)
		ret = '';
		
	Application.application.callLater(generate);
	return ret;
}

 /**
 * evaluate function section
 */		 
public function _evaluate(list:String):*
{
	var contexts:Array = [context, GraphContext(contextStack[contextStack.length-1]).context];
	
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
	
	Application.application.callLater(generate);
	
	return buffer;
}

 /**
 * execute function section
 */		 
public function _execute(list:String):*
{
	var contexts:Array = [context, GraphContext(contextStack[contextStack.length-1]).context];
	
	var parsedList:Object = CodeParser.ParseCode(
		list,
		GraphContext(contextStack[contextStack.length-1]).varPrefix,
		contexts);
							
	if(!parsedList.result) {								
		throw parsedList.error;
	}
	else {
		return parsedList.string;
	}
}

public function _addStructure(src:String, tgt:String, level:int, listStruct:String):* 
{
	var ret:String = _processStructure(src, tgt, level, listStruct, 'add');
	
	Application.application.callLater(generate);
	
	return ret;
}

public function _updateStructure(src:String, tgt:String, level:int, listStruct:String):* 
{
	var ret:String = _processStructure(src, tgt, level, listStruct, 'update');
	
	Application.application.callLater(generate);
	
	return ret;
}

public function _deleteStructure(src:String, tgt:String, level:int, listStruct:String):* 
{
	var ret:String = _processStructure(src, tgt, level, listStruct, 'delete');
	
	Application.application.callLater(generate);
	
	return ret;
}

private function _processStructure(src:String, tgt:String, level:int, listStruct:String, action:String='add'):String
{
	var contexts:Array = [context, GraphContext(contextStack[contextStack.length-1]).context];
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
		var idObjSrc:String = ListParser.getElm(objSrcList, 1);
	
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
			var lvl:int = int(ListParser.getElm(lvlObjTgtList, 1));
			
			if(level == lvl)
				break;
		}
		
		if(j<=lvlLinkListLen)
		{
			var objTgtList:String = ListParser.getElm(lvlObjTgtList, 2);
			var objTgtListLen:int = ListParser.length(objTgtList);
			
			for(var k:int=1; k<=objTgtListLen; k++)
			{
				var idObjTgt:String = ListParser.getElm(objTgtList, k);
				
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
						objTgtList = ListParser.put(objTgtList, 'tail', 'word', idTgt);
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
					objTgtList = ListParser.put('[]', 'tail', 'word', idTgt);
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
					objSrcList = ListParser.update(objSrcList, 4, 'word', ListParser.getElmValue(src, 4, contexts));
					
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
				objTgtList = ListParser.put('[]', 'tail', 'word', idTgt);
				lvlObjTgtList = ListParser.put('[]', 'head', 'word', level);				
				lvlObjTgtList = ListParser.put(lvlObjTgtList, 'tail', 'list', objTgtList);								
				lvlLinkList = ListParser.put('[]', 'tail', 'list', lvlObjTgtList);				
				
				objSrcList = ListParser.put('[]', 'head', 'word', idSrc);
				if(listSrcObj.result)
				{
					objSrcList = ListParser.put(objSrcList, 'tail', 'word', ListParser.getElmValue(src, 2, contexts));
					objSrcList = ListParser.put(objSrcList, 'tail', 'word', ListParser.getElmValue(src, 3, contexts));
					objSrcList = ListParser.put(objSrcList, 'tail', 'word', ListParser.getElmValue(src, 4, contexts));
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