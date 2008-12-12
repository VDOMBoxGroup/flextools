package PowerPack.com.gen.parse
{
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.gen.*;
import PowerPack.com.gen.errorClasses.CompilerError;
import PowerPack.com.gen.errorClasses.ValidationError;

public class CodeParser
{		
	public static const MSG_NN_SYNTAX_ERR:String = "Normal state syntax error.";
	public static const MSG_SN_SYNTAX_ERR:String = "Subgraph state syntax error.";
	public static const MSG_CN_SYNTAX_ERR:String = "Command state syntax error.";
	public static const MSG_CN_UNKNOWN_TYPE:String = "Unrecognized command state type.";
	
	public static const CT_OPERATION:String = 'operation';
	public static const CT_TEST:String = 'test';
	public static const CT_FUNCTION:String = 'function';
	public static const CT_MULTI:String = 'multi';			
	public static const CT_NONE:String = 'none';			
	
	/**
	 * 
	 * @param nodeText - input string
	 * @param context - instance of dynamic class
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			value: String - parsed string 
	 * 			print: Boolean - print result to output buffer
	 * 
	 */
	public static function ParseText(	text:String, 
										contexts:Array=null ):ParsedNode
	{
		var pattern:RegExp;
		var str:String = text.concat();
		var retVal:ParsedNode = new ParsedNode(); 
		
		retVal.result = false;
		retVal.print = true;
		
  		var lexems:Array = Parser.getLexemArray(str, false);
  		lexems = Parser.convertLexemArray(lexems);
		retVal.lexemsGroup = [lexems]; 
		
    	for(var i:int=0; i<lexems.length; i++)
    	{
    		if(lexems[i].error)
    		{
				retVal.result = false;
				retVal.error = lexems[i].error;
				retVal.lexem = lexems[i];
				return retVal;
    		}
    	}
		
		// contexts - instances of dynamic class that contains global/local variables
		if(contexts)
		{
			var context:*;
			var lexemObj:Object = Parser.processConvertedLexemArray(lexems, contexts);
			retVal.result = lexemObj.result;
			retVal.error = lexemObj.error;
			retVal.value = lexemObj.value;				
			lexems = lexemObj.array;

			if(!retVal.result)
				return retVal;
						
			var buffer:String = "";
			
        	for(i=0; i<lexems.length; i++)
        	{
				var value:Object = null;
				 
	        	if( lexems[i].type=="v" )
	        	{
					for(var j:int=contexts.length-1; j>=0; j--)
					{
						context = contexts[j];
					
	        			if( context.hasOwnProperty(lexems[i].value) )
	        			{
							value = context[lexems[i].value];
	        				break;
	        			}
	        		}
	        		
	        		buffer += (value!=null ? Utils.replaceEscapeSequences(value.toString(), "\\n") : lexems[i].origValue);
		        }
		        else		        	
					buffer += lexems[i].value;
			}
        	
        	retVal.result = true;	
			retVal.value = buffer;
			return retVal;
		}
		
		retVal.result = true;
		retVal.value = text;

       	return retVal;
	}
	
	/**
	 * 
	 * @param _nodeText
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			value: String - parsed string
	 * 
	 */
	public static function ParseSubgraphNode( nodeText:String ):ParsedNode
	{
		var pattern:RegExp;
		var str:String = nodeText.concat();
		var retVal:ParsedNode = new ParsedNode();
		
    	pattern = /[\W]/gi;
		
		if(pattern.test(str))
		{
			retVal.result = false;
			retVal.error = new ValidationError(MSG_SN_SYNTAX_ERR);
        	return retVal;
   		}
		
		retVal.result = true;
		retVal.value = str;
		
       	return retVal;
	}
			
	/**
	 * 
	 * @param nodeText - input text
	 * @param varPrefix - variable prefix for left-part variables
	 * @param context - instance of dynamic class
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			value: String
	 * 			type: String - command type (operation, test or function)
	 * 			program: String - executable as3 script
	 * 
	 * 			print: Boolean - if true then print function result to template buffer
	 * 			func: String - function name
	 * 			variable: String - variable name for storing result
	 * 			array: Array - array of transition alternatives
	 * 
	 */
	public static function ParseCode( code:String ):ParsedNode
	{
		var pattern:RegExp;
		var str:String = code.concat();
		var retVal:ParsedNode = new ParsedNode();
		
   		/**
   		 * lexical analyzer
   		 */
   		 
  		var lexems:Array = Parser.getLexemArray(str);
    	for(var i:int=0; i<lexems.length; i++)
    	{
    		if(lexems[i].error)
    		{
				retVal.result = false;
				retVal.error = lexems[i].error;
				retVal.lexem = lexems[i];
				return retVal;
    		}
    	}
		
		var lexemObj:Object = Parser.packLists(lexems);
		if(!lexemObj.result)
		{
			retVal.result = lexemObj.result;
			retVal.error = lexemObj.error;
			return retVal;
		}
		
		lexems = lexemObj.array;
		Parser.processLexemArray(lexems);
  		lexems = Parser.convertLexemArray(lexems);
  	        		
    	var lexemsArr:Array = Parser.sliceLexems(lexems);
		retVal.lexemsGroup = lexemsArr;
		retVal.vars = [];
		retVal.funcs = [];
		
   		/**
   		 * syntax analyzer 
   		 */
   		 
   		if(lexemsArr.length>1)
   		{
   			retVal.type = CT_MULTI;
   		}
   		
		for(i=0; i<lexemsArr.length; i++)
		{    			
	   		retVal.vars.push(null);
	   		retVal.funcs.push(null);
	   		
	   		var obj:Object;
			var strSentence:String = "";       			
			
			for(var j:int=0; j<lexemsArr[i].length; j++)
				strSentence = strSentence + lexemsArr[i][j].type;
				
			// parse operations
			obj = Parser.isValidCommand(strSentence);
			retVal.result = obj.result;			
			if(retVal.result && !retVal.type)
			{
				retVal.type = CT_OPERATION;
			}
			
			// parse test
			if(!retVal.result && !retVal.error)
			{
				obj = Parser.isValidTest(strSentence);
				retVal.result = obj.result;
				if(retVal.result && !retVal.type)
				{
					retVal.type = CT_TEST;
				}
				else if(retVal.result && retVal.type==CT_MULTI)
				{
					retVal.result = false;
					retVal.error = new CompilerError(null, 9000);
				}
			}
			
			// parse function
			if(!retVal.result && !retVal.error)
			{
				obj = Parser.isValidFunction(strSentence);
				retVal.result = obj.result;				
				if(retVal.result)
				{
					if(!retVal.type)
						retVal.type = CT_FUNCTION;
					
					var func:Object = Parser.isFunctionExists(lexemsArr[i]);
					retVal.result = func.result;
					retVal.error = func.error;
				
					retVal.vars[i] = func.variable;
					retVal.funcs[i] = func.func;
				}				
			}  		     

			if(!retVal.result  && !retVal.error) 
			{
				retVal.error = new CompilerError(null, 9000);
			}
			
			if(retVal.error)
				return retVal;
		}  		
		
		return retVal; 
	}

	public static function executeCode(	node:ParsedNode,
										index:int,
										contexts:Array,			 
										varPrefix:String = "" ):void
	{
		node.value = null;
		node.result = false;
		node.print = false;
		
		node.array = null;
		node.transition = null;
		
		if(node.vars[index] == null)
			node.print = true;
		
		// add variable prefix for left-part vars
		if(node.vars[index])
			node.vars[index] = varPrefix + node.vars[index]; 
		for(var j:int=0; j<node.lexemsGroup[index].length; j++)
		{
			if(node.lexemsGroup[index][j].type=='=' && node.lexemsGroup[index][j-1].type=='v')
				node.lexemsGroup[index][j-1].value = varPrefix + node.lexemsGroup[index][j-1].value;							
		}		
			
		// resolve advanced techniques
		var lexemObj:Object = Parser.processConvertedLexemArray(node.lexemsGroup[index], contexts);
		node.result = lexemObj.result;
		node.error = lexemObj.error;				
	
		if(!node.result)
			return;
								
		node.lexemsGroup[index] = lexemObj.array;							
		
		/////////////////////////////////
		
		if(node.type == CT_TEST)
		{
			node.array = ["true", "false"];
			node.print = false;
		}
		else if(node.funcs[index])
		{
			if(node.funcs[index]=='loadDataFrom')
				node.array = ["true", "false"];			
		}

   		// generate and execute code
		var code:String = "";
		if(node.type == CT_TEST)
		{
			for(j=0; j<node.lexemsGroup[index].length; j++) 
			{
				code += node.lexemsGroup[index][j].value;
			}			
		}
		else if(node.funcs[index])
		{
			var func:Object = Parser.isFunctionExists(node.lexemsGroup[index]);
			node.result = func.result;
			node.error = func.error;
		
			if(!node.result)
				return;
			
			code = func.value;
		}
		else
		{
			for(j=0; j<node.lexemsGroup[index].length; j++) 
			{
				code += node.lexemsGroup[index][j].value;
			}			
		}
			
		var evalRes:* = Parser.eval(code, contexts);
		node.value = evalRes;	
	}

}
}