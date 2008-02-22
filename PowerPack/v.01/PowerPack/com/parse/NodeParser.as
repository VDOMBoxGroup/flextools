package PowerPack.com.parse
{
	import PowerPack.com.Utils;
	import PowerPack.com.gen.*;
	
	import com.riaone.deval.D;

	public class NodeParser
	{		
		public static const MSG_NN_SYNTAX_ERR:String = "Normal node syntax error";
		public static const MSG_CN_SYNTAX_ERR:String = "Command node syntax error";
		public static const MSG_CN_UNKNOWN_TYPE:String = "Unrecognized command node type";
		public static const MSG_SN_SYNTAX_ERR:String = "Subgraph node syntax error";
		
		public static const CT_OPERATION:int = 1;
		public static const CT_TEST:int = 2;
		public static const CT_FUNCTION:int = 3;		
		
		/**
		 * 
		 * @param _nodeText - input string
		 * @param _context - instance of dynamic class
		 * @return 	result: Boolean - valid or not
		 * 			resultString: String - parsed string or error msg
		 * 
		 */
		public static function NormalNodeParse(	nodeText:String,
												context:Dynamic=null):Object
		{
			var pattern:RegExp;
			var str:String = nodeText.concat();
			var retVal:Object = {result:false, resultString:null};

      		var lexem:Array = Parser.getTextLexemArray(str);
      		lexem = Parser.convertLexemArray(lexem);
			
        	for(var i:int=0; i<lexem.length; i++)
        	{
        		if(lexem[i][0]=="u")
        		{
					retVal.result = false;
					retVal.resultString = MSG_NN_SYNTAX_ERR;					
					return retVal;
        		}
        	}
			
			// context - instance of dynamic class that contains global variables
			if(context && !retVal.resultString)
			{
				var lexemObj:Object = Parser.processConvertedLexemArray(lexem, context);
				retVal.result = lexemObj.result;
				retVal.resultString = lexemObj.resultString;				
				lexem = lexemObj.resultArray;
				
				if(!retVal.result)
				{
					return retVal;
				}
				else				
				{
					var buffer:String = "";
					
		        	for(i=0; i<lexem.length; i++)
		        	{
		        		if(lexem[i][0]=="v")
							lexem[i][1] = context[lexem[i][1]];

						buffer += lexem[i][1];
		        	}
		        	
		        	retVal.result = true;
					retVal.resultString = buffer;
					return retVal;
				}
			}
			
			retVal.result = true;
           	return retVal;
		}
		
		/**
		 * 
		 * @param _nodeText
		 * @return 	result: Boolean - valid or not
		 * 			resultString: String - parsed string
		 * 
		 */
		public static function SubgraphNodeParse( nodeText:String ):Object
		{
			var pattern:RegExp;
			var str:String = nodeText.concat();
			var retVal:Object = {result:false, resultString:null};
			
        	pattern = /[^a-z0-9_]/gi;
			
			if(pattern.test(str))
			{
				retVal.result = false;
				retVal.resultString = MSG_SN_SYNTAX_ERR;
            	return retVal;
   			}
			
			retVal.result = true;
			retVal.resultString = str;
			
           	return retVal;
		}
				
		/**
		 * 
		 * @param nodeText - input text
		 * @param fValidate - if true then executes only syntax validation
		 * @param varPrefix - variable prefix for left-part variables
		 * @param context - instance of dynamic class
		 * @return 	result: Boolean - valid or not
		 * 			resultString: String - error code
		 * 			type: String - command type (operation, test or function)
		 * 			program: String - executable as3 script
		 * 
		 * 			print: Boolean - if true then print function result to template buffer
		 * 			func: String - function name
		 * 			variable: String - variable name for storing result
		 * 			resultArray: Array - array of transition alternatives
		 * 
		 */
		public static function CommandNodeParse(	nodeText:String, 
													fValidate:Boolean = true,
													varPrefix:String = "",
													context:Dynamic = null):Object
		{
			var pattern:RegExp;
			var str:String = nodeText.concat();
			var retVal:Object = new Object();
			
			retVal.result = false;
			retVal.resultString = null;
			retVal.type = null;
			retVal.program = null;
			
			retVal.print = true;
			retVal.func = null;
			retVal.variable = null;
			retVal.resultArray = null;
					
       		var bTestCommand:Boolean = false;
       		var bOperationCommand:Boolean = false;
       		var bFunctionCommand:Boolean = false;
       			
       		/**
       		 * lexical analyzer 
       		 */
       		 
      		var lexem:Array = Parser.getLexemArray(str);
      		lexem = Parser.convertLexemArray(lexem);
  		        		
       		/**
       		 * syntax analyzer 
       		 */
       		 
       		var obj:Object;
			var strSentence:String = "";       			
			for(var i:int=0; i<lexem.length; i++)
				strSentence = strSentence + lexem[i][0];

			// parse operations
			obj = Parser.isValidCommand(strSentence);
			strSentence = obj.resultString;
			
			if(obj.result)
			{
				bOperationCommand = true;
				retVal.result = true;
				retVal.type = CT_OPERATION;
			}
			
			var prevLen:int;
			
			// parse test
			if(!retVal.type)
			{
				obj = Parser.isValidTest(strSentence);
				strSentence = obj.resultString;			
				
				if(obj.result)
				{
					bTestCommand = true;
					retVal.result = true;
					retVal.type = CT_TEST;
					retVal.resultArray = ["true", "false"];
				}
			}
			
			// parse function
			if(!retVal.type)
			{
				obj = Parser.isValidFunction(strSentence);
				strSentence = obj.resultString;			
				
				if(obj.result)
				{
					bFunctionCommand = true;
					retVal.type = CT_FUNCTION;
				}				
			}  		     
			
			if(!fValidate && context)
			{
				// process variable definition advanced technique
				var lexemObj:Object = Parser.processConvertedLexemArray(lexem, context);
				retVal.result = lexemObj.result;
				retVal.resultString = lexemObj.resultString;				
    			lexem = lexemObj.resultArray;
				
				// add variable prefix for left-part vars
				for(i=0;i<lexem.length;i++)
				{
					if(lexem[i][0]=='=' && lexem[i-1][0]=='v')
						lexem[i-1][1] = varPrefix + lexem[i-1][1];							
				}
   			} 			
    
    		if(bFunctionCommand && lexem)
    		{			
				var func:Object = Parser.isFunctionExists(lexem, fValidate);
				retVal.result = func.result;
				retVal.variable = func.resultVar;
				retVal.func = func.resultFunc;

				if(func.resultVar)
				{					
					retVal.print = false;
				}	

				if(!retVal.result)
				{
					retVal.resultString = func.resultString;
				}	
    		}
    		
   			// generate programm code
    		if(fValidate==false && retVal.result)
    		{
    			var program:String = "";
    			
    			if(bOperationCommand) // operation
    			{
					for(i=0;i<lexem.length;i++)
					{
						program += lexem[i][1];
					}
					retVal.program = program;
				}
				else if(bTestCommand) // test
				{					
					for(i=0;i<lexem.length;i++)
					{
						program += lexem[i][1];
					}
					retVal.program = program;
				}
				else if(bFunctionCommand) // function
				{
					retVal.program = func.resultString;
				}
    		}
    		
    		if(!retVal.type)
				retVal.resultString = MSG_CN_SYNTAX_ERR;
				    		
			return retVal;
		}
	}
}