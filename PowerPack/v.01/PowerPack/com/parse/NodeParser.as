package PowerPack.com.parse
{
	import PowerPack.com.Utils;
	import PowerPack.com.gen.*;
	
	import com.riaone.deval.D;

	public class NodeParser
	{		
		public static const CT_OPERATION:int = 1;
		public static const CT_TEST:int = 2;
		public static const CT_FUNCTION:int = 3;		
		
		/**
		 * 
		 * @param _nodeText - input string
		 * @param _context - instance of dynamic class
		 * @return 	result: Boolean - valid or not
		 * 			resultString: String - parsed string
		 * 
		 */
		public static function NormalNodeParse(	nodeText:String,
												context:Dynamic=null):Object
		{
			var pattern:RegExp;
			var str:String = nodeText.concat();
			var retVal:Object = new Object();
			
			retVal.result = true;
			retVal.resultString = null;

      		var lexem:Array = Parser.getTextLexemArray(str);
      		lexem = Parser.convertLexemArray(lexem);
			
        	for(var i:int=0; i<lexem.length; i++)
        	{
        		if(lexem[i][0]=="u")
					retVal.result = false;
        	}
			
			// context - instance of dynamic class that contains global variables
			if(context && retVal.result)
			{
				lexem = Parser.processConvertedLexemArray(lexem, context);
				
				if(lexem==null)
				{
					retVal.result = false;
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
		        	
					retVal.resultString = buffer;
				}
			}
			
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
			var retVal:Object = new Object();
			
			retVal.result = false;
			retVal.resultString = null;			
			
        	pattern = /[^a-z0-9_]/gi;
			
			if(pattern.test(str))
            	return retVal;
			
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
			var func:String;
			
			retVal.result = false;
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
			if(retVal.result==false)
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
			if(retVal.result==false && strSentence.search(/\[.+\]/)>=0)
			{
				pattern = /^(v=){0,1}\[n[nscvif]{0,}\]$/;
				
				if(pattern.test(strSentence))
				{
					bFunctionCommand = true;
					retVal.type = CT_FUNCTION;
				}
			}  		     
	
			if(!fValidate && context)
			{
    			lexem = Parser.processConvertedLexemArray(lexem, context);
   			} 			
    
    		if(bFunctionCommand && lexem)
    		{				
    			
				// search for function name index in lexem array
				for(i=0;i<lexem.length;i++)
				{
					if(lexem[i][0]=='n')
						break;
				}						
				// search for variable index in lexem array
				for(var j:int=0;j<lexem.length;j++)
				{
					if(lexem[j][0]=='v')
						break;
				}
				
				var bFunc:Boolean = false;
				
				// sub
				pattern = /^(v=){0,1}\[nn\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="sub" )
				{
					bFunc = true;
					func = TemplateStruct.CNTXT_INSTANCE + "." + lexem[i][1] + "(" + 
						Utils.doubleQuotes(lexem[i+1][1]) + ")";
				}	
				// subprefix
				pattern = /^(v=){0,1}\[nnn\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="subprefix" )
				{
					bFunc = true;
					func = TemplateStruct.CNTXT_INSTANCE + "." + lexem[i][1] + "(" + 
						Utils.doubleQuotes(lexem[i+1][1]) + "," + 
						Utils.doubleQuotes(lexem[i+2][1]) + ")";
				}	
				// question
				pattern = /^(v=){0,1}\[ncc\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="question" )
				{
					bFunc = true;
					func = TemplateStruct.CNTXT_INSTANCE + "." + lexem[i][1] + "(" + 
						lexem[i+1][1] + "," + 
						lexem[i+2][1] + ")";
				}
				// convert
				pattern = /^(v=){0,1}\[nc[scvi]\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="convert" )
				{
					bFunc = true;
					func = TemplateStruct.CNTXT_INSTANCE + "." + lexem[i][1] + "(" + 
						lexem[i+1][1] + "," + 
						lexem[i+2][1] + ")";
				}		
				// writeTo
				pattern = /^(v=){0,1}\[n[cv]\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="writeTo" )
				{
					bFunc = true;
					func = TemplateStruct.CNTXT_INSTANCE + "." + lexem[i][1] + "(" + 
						lexem[i+1][1] + ")";
				}			
				// writeVarTo
				pattern = /^(v=){0,1}\[n[cv][scvif]\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="writeVarTo" )
				{
					bFunc = true;
					func = TemplateStruct.CNTXT_INSTANCE + "." + lexem[i][1] + "(" + 
						lexem[i+1][1] + "," + 
						lexem[i+2][1] + ")";
				}					
				// GUID
				pattern = /^(v=){0,1}\[n\]$/;
				if(	pattern.test(strSentence) && 
					lexem[i][1]=="GUID" )
				{
					bFunc = true;
					func = TemplateStruct.CNTXT_INSTANCE + "." + lexem[i][1] + "()";
				}
				
				if(bFunc)
				{					
					retVal.result = true;
					retVal.func = lexem[i][1];					

					if(/^v=/.test(strSentence))
					{
						retVal.variable = varPrefix + lexem[j][1];
						func = retVal.variable + "=" + func;
						retVal.print = false;
					}
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
						if(lexem[i][0]=='=' && lexem[i-1][0]=='v')
							lexem[i-1][1] = varPrefix + lexem[i-1][1];							
					}
					
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
					program = func;
					retVal.program = program;
				}	
    		}		
			
			return retVal;
		}

	}
}