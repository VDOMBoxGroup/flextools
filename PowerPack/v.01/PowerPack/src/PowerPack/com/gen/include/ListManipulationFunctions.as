// ActionScript file
import ExtendedAPI.com.utils.Utils;

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
	else if(type==2)
		ret = Utils.replaceQuotes(ret);
	else if(type==4)
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