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
	
	public static const CT_OPERATION:int = 1;
	public static const CT_TEST:int = 2;
	public static const CT_FUNCTION:int = 3;		
	
	/**
	 * 
	 * @param nodeText - input string
	 * @param context - instance of dynamic class
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			string: String - parsed string 
	 * 			print: Boolean - print result to output buffer
	 * 
	 */
	public static function ParseText(	text:String, 
										contexts:Array=null ):Object
	{
		var pattern:RegExp;
		var str:String = text.concat();
		var retVal:Object = {result:false, error:null, string:null, print:true};

  		var lexems:Array = Parser.getLexemArray(str, false);
  		lexems = Parser.convertLexemArray(lexems);
		
    	for(var i:int=0; i<lexems.length; i++)
    	{
    		if(lexems[i].error)
    		{
				retVal.result = false;
				retVal.error = lexems[i].error;
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
			retVal.string = lexemObj.string;				
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
			retVal.string = buffer;
			return retVal;
		}
		
		retVal.string = text;
		retVal.result = true;
       	return retVal;
	}
	
	/**
	 * 
	 * @param _nodeText
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			string: String - parsed string
	 * 
	 */
	public static function ParseSubgraphNode( nodeText:String ):Object
	{
		var pattern:RegExp;
		var str:String = nodeText.concat();
		var retVal:Object = {result:false, error:null, string:null, print:false};
		
    	pattern = /[\W]/gi;
		
		if(pattern.test(str))
		{
			retVal.result = false;
			retVal.error = new ValidationError(MSG_SN_SYNTAX_ERR);
        	return retVal;
   		}
		
		retVal.result = true;
		retVal.string = str;
		
       	return retVal;
	}
			
	/**
	 * 
	 * @param nodeText - input text
	 * @param varPrefix - variable prefix for left-part variables
	 * @param context - instance of dynamic class
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			string: String
	 * 			type: String - command type (operation, test or function)
	 * 			program: String - executable as3 script
	 * 
	 * 			print: Boolean - if true then print function result to template buffer
	 * 			func: String - function name
	 * 			variable: String - variable name for storing result
	 * 			array: Array - array of transition alternatives
	 * 
	 */
	public static function ParseCode(	code:String, 
										varPrefix:String = "",
										contexts:Array = null ):Object
	{
		var pattern:RegExp;
		var str:String = code.concat();
		var retVal:Object = new Object();
		
		retVal.result = false;
		retVal.string = null;
		retVal.type = null;
		retVal.program = null;
		retVal.error = null;
		retVal.lexem = null;
		retVal.transition = null;
		
		retVal.print = false;
		retVal.func = null;
		retVal.variable = null;
		retVal.array = null;

		var bTestCommand:Boolean = false;
   		var bOperationCommand:Boolean = false;
   		var bFunctionCommand:Boolean = false;
   			
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
		retVal.result = lexemObj.result;
		retVal.error = lexemObj.error;

		if(!retVal.result)
			return retVal;
		
		lexems = lexemObj.array;
		Parser.processLexemArray(lexems);
  		lexems = Parser.convertLexemArray(lexems);
  	        		
   		/**
   		 * syntax analyzer 
   		 */
   		 
   		var obj:Object;
		var strSentence:String = "";       			
		for(i=0; i<lexems.length; i++)
			strSentence = strSentence + lexems[i].type;

		// parse operations
		obj = Parser.isValidCommand(strSentence);
		strSentence = obj.string;
		
		if(obj.result)
		{
			bOperationCommand = true;
			retVal.result = true;
			retVal.type = CT_OPERATION;
		}
		
		// parse test
		if(!retVal.type)
		{
			obj = Parser.isValidTest(strSentence);
			strSentence = obj.string;			
			
			if(obj.result)
			{
				bTestCommand = true;
				retVal.result = true;
				retVal.type = CT_TEST;
				retVal.array = ["true", "false"];
			}
		}
		
		// parse function
		if(!retVal.type)
		{
			obj = Parser.isValidFunction(strSentence);
			strSentence = obj.string;			
			
			if(obj.result)
			{
				bFunctionCommand = true;
				retVal.type = CT_FUNCTION;
			}				
		}  		     
		
    	var lexemsArr:Array = Parser.sliceLexems(lexems);

		if(contexts && retVal.result)
		{
			for(i=0; i<lexemsArr.length; i++)
			{    			
				// add variable prefix for left-part vars
				for(var j:int=0;j<lexemsArr[i].length;j++)
				{
					if(lexemsArr[i][j].type=='=' && lexemsArr[i][j-1].type=='v')
						lexemsArr[i][j-1].value = varPrefix + lexemsArr[i][j-1].value;							
				}
			}
			
			for(i=0; i<lexemsArr.length; i++)
			{    			
				// resolve advanced techniques
				lexemObj = Parser.processConvertedLexemArray(lexemsArr[i], contexts);
				retVal.result = lexemObj.result;
				retVal.error = lexemObj.error;				
			
				if(!retVal.result)
					return retVal;
										
    			lexemsArr[i] = lexemObj.array;							
			}
   		}

		if(bFunctionCommand && retVal.result)
		{			
			for(i=0; i<lexemsArr.length; i++)
			{
				var func:Object = Parser.isFunctionExists(lexemsArr[i]);
				retVal.result = func.result;
				retVal.error = func.error;
				retVal.variable = func.variable;
				retVal.func = func.func;

				if(!retVal.result)
					return retVal;

				if(func.variable==null)
				{					
					retVal.print = true;
				}
				
				if(retVal.func=='loadDataFrom')
					retVal.array = ["true", "false"];
			}	
		}
		
   		// generate programm code
		if(contexts && retVal.result)
		{
			for(i=0; i<lexemsArr.length; i++)
			{    			
				var program:String = "";
			
    			if(bOperationCommand) // operation
    			{
					for(j=0;j<lexemsArr[i].length;j++) {
						program += lexemsArr[i][j].value;
					}
					retVal.program = program;
				}
				else if(bTestCommand) // test
				{					
					for(j=0;j<lexemsArr[i].length;j++) {
						program += lexemsArr[i][j].value;
					}
					retVal.program = program;
				}
				else if(bFunctionCommand) // function
				{
					retVal.program = func.string;
				}
				
				var evalRes:* = Parser.eval(retVal.program, contexts);
				
				if(evalRes!=null)
					retVal.string = evalRes; 					
			}
		}
		
		if(!retVal.type && !retVal.error) {
			retVal.result = false;
			retVal.error = new CompilerError(null, 9000);
		}
			    		
		return retVal;
	}
}
}