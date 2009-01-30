package PowerPack.com.gen.parse
{
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.gen.*;
import PowerPack.com.gen.errorClasses.CompilerError;
import PowerPack.com.gen.errorClasses.ValidationError;
import PowerPack.com.gen.parse.parseClasses.CodeFragment;
import PowerPack.com.gen.parse.parseClasses.LexemStruct;
import PowerPack.com.gen.parse.parseClasses.ParsedBlock;

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
										contexts:Array=null ):ParsedBlock
	{
		var pattern:RegExp;
		var str:String = text.concat();
		var block:ParsedBlock = Parser.lexemsFragmentation(Parser.getLexemArray(str, false));
		block.print = true;  		
  		
  		//var lexems:Array = Parser.getLexemArray(str, false);
  		//block.lexems = Parser.convertLexemArray(lexems);  		
		//parsedNode.lexemsGroup = [lexems];
		
    	if(block.errFragment)
    		return block; 
		
		Parser.validateFragmentation(block);
		
    	if(block.errFragment)
    		return block; 

		// contexts - instances of dynamic class that contains global/local variables
		if(contexts)
		{
			var context:*;
			//var lexemObj:Object = Parser.processConvertedLexemArray(lexems, contexts);
			//parsedNode.result = lexemObj.result;
			//parsedNode.error = lexemObj.error;
			//parsedNode.value = lexemObj.value;				
			//lexems = lexemObj.array;

			if(!parsedNode.result)
				return parsedNode;
						
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
        	
        	parsedNode.result = true;	
			parsedNode.value = buffer;
			return parsedNode;
		}
		
		parsedNode.result = true;
		parsedNode.value = text;

       	return parsedNode;
	}
	
	public function executeCodeFragment(fragment:CodeFragment, contexts:Array):void
	{
		if(!fragment.validated)
		{
			Parser.validateCodeFragment(fragment);			
		}
		
		if(fragment.errFragment)
			return;
		
		for(var i:int=0; i<fragment.fragments.length; i++)
		{
			executeCodeFragment(fragment.fragments[0] as CodeFragment);
		}
		
		// generate executable code
		var code:String = "";
		switch(fragment.ctype)
		{
			case Parser.CT_OPERATION:
			case Parser.CT_TEST:
				for(i=0; i<fragment.fragments.length; i++) 
				{
					var subfragment:Object = fragment.fragments[i];
					 
					if(subfragment is CodeFragment)
					{
						if((subfragment as CodeFragment).retValue)
							code += (subfragment as CodeFragment).retValue;
						else
							code += 'null';
					}
					else if(subfragment is LexemStruct)
					{
						var value:Object = LexemStruct(subfragment).value;
						if(LexemStruct(subfragment).type == 'v')
							value = String(value).substring(1);
													
						code += value;
					}
				}	
				break;
				
			case Parser.CT_FUNCTION:
				Parser.processOperationGroups(fragment.fragments);				
				
				for(i=2; i<fragment.fragments.length-1; i++)
				{
					subfragment = fragment.fragments[i];
					var tmp:String = 'null';
					
					if(subfragment is CodeFragment)
					{
						if((subfragment as CodeFragment).retValue)
							tmp = (subfragment as CodeFragment).retValue;
						else
							tmp = 'null';
					}
					else if(subfragment is LexemStruct)
					{
						value = LexemStruct(subfragment).value;
						switch(LexemStruct(subfragment).type)
						{
							case 'v':
								value = String(value).substring(1);
								break;
							case 'n':
								value = "{type:'n', value:"+Utils.quotes(String(value))+"}";
								break;							
						}
													
						tmp = value.toString();
					}
										
					code += (fragment.fragments[i-1].operationGroup!=fragment.fragments[i].operationGroup && 
								code.length ? "," : "") + tmp;
				}
				
				code = TemplateStruct.CNTXT_INSTANCE + "." + 
					 fragment.funcName + "(" + code + ")";				
				
				break;
				
			case Parser.CT_ASSIGN:
				for(i=0; i<fragment.fragments.length-1; i+=2)
				{
					subfragment = fragment.fragments[i];
					var nextSubfragment:Object = fragment.fragments[i+1];
					
					tmp = '';
					
					if(nextSubfragment is LexemStruct && LexemStruct(nextSubfragment).type=='=')
					{
						if(subfragment is CodeFragment)
						{
							if((subfragment as CodeFragment).retValue)
								tmp = (subfragment as CodeFragment).retValue;
							else
								tmp = '';
						}
						else if(subfragment is LexemStruct)
						{
							value = LexemStruct(subfragment).value;
							switch(LexemStruct(subfragment).type)
							{
								case 'v':
									value = String(value).substring(1);
									break;
							}
														
							tmp = value.toString();
						}
						
						// add prefix
						tmp += fragment.varPrefix + tmp;
						fragment.varNames.push(tmp);
						
						code += tmp + '=';				
					}
					else					
						break;	
				}
				
				// add rest of code
				for(var j:int=i; j<fragment.fragments.length; j++) 
				{
					subfragment = fragment.fragments[j];
					 
					if(subfragment is CodeFragment)
					{
						if((subfragment as CodeFragment).retValue)
							code += (subfragment as CodeFragment).retValue;
						else
							code += 'null';
					}
					else if(subfragment is LexemStruct)
					{
						var value:Object = LexemStruct(subfragment).value;
						if(LexemStruct(subfragment).type == 'v')
							value = String(value).substring(1);
													
						code += value;
					}
				}				
				break;
				
			default:			
				switch(type)
				{
					case 'W': // advanced var
						for(i=1; i<fragment.fragments.length-1; i++) 
						{
							subfragment = fragment.fragments[i];
							 
							if(subfragment is CodeFragment)
							{
								if((subfragment as CodeFragment).retValue)
									code += (subfragment as CodeFragment).retValue;
								else
									code += 'null';
							}
							else if(subfragment is LexemStruct)
							{
								var value:Object = LexemStruct(subfragment).value;
								if(LexemStruct(subfragment).type == 'v')
									value = String(value).substring(1);
															
								code += value;
							}
						}						
						break;
						
					case 'A': // list
						Parser.processOperationGroups(fragment.fragments);				
						
						for(i=2; i<fragment.fragments.length-1; i++)
						{
							subfragment = fragment.fragments[i];
							var tmp:String = 'null';
							
							if(subfragment is CodeFragment)
							{
								if((subfragment as CodeFragment).retValue)
									tmp = (subfragment as CodeFragment).retValue;
								else
									tmp = 'null';
							}
							else if(subfragment is LexemStruct)
							{
								value = LexemStruct(subfragment).value;
								switch(LexemStruct(subfragment).type)
								{
									case 'v':
										value = String(value).substring(1);
										break;
									case 'n':
										value = "{type:'n', value:"+Utils.quotes(String(value))+"}";
										break;							
								}
															
								tmp = value.toString();
							}
												
							code += (fragment.fragments[i-1].operationGroup!=fragment.fragments[i].operationGroup && 
										code.length ? "," : "") + tmp;
						}
						
						code = TemplateStruct.CNTXT_INSTANCE + "." + 
							 fragment.funcName + "(" + code + ")";				
						break;
					
				}			
		}
		
		// execurte generated code
		fragment.retValue = Parser.eval(code, contexts);
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
		var parsedNode:ParsedNode = new ParsedNode();
		
    	pattern = /[\W]/gi;
		
		if(pattern.test(str))
		{
			parsedNode.result = false;
			parsedNode.error = new ValidationError(MSG_SN_SYNTAX_ERR);
        	return parsedNode;
   		}
		
		parsedNode.result = true;
		parsedNode.value = str;
		
       	return parsedNode;
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
		var parsedNode:ParsedNode = new ParsedNode();
		
   		/**
   		 * lexical analyzer
   		 */
   		 
  		var lexems:Array = Parser.getLexemArray(str);
    	for(var i:int=0; i<lexems.length; i++)
    	{
    		if(lexems[i].error)
    		{
				parsedNode.result = false;
				parsedNode.error = lexems[i].error;
				parsedNode.errLexem = lexems[i];
				return parsedNode;
    		}
    	}
		
		/**
		 *	pack lists to strings 
		 */
		
		var lexemObj:Object = Parser.packLists(lexems);
		if(!lexemObj.result)
		{
			parsedNode.result = lexemObj.result;
			parsedNode.error = lexemObj.error;
			return parsedNode;
		}
		
		///////////////////////////////////////////////
		
		lexems = lexemObj.array;
		Parser.processLexemArray(lexems);
  		lexems = Parser.convertLexemArray(lexems);
  	        		
    	var lexemsArr:Array = Parser.sliceLexems(lexems);
		parsedNode.lexemsGroup = lexemsArr;
		parsedNode.vars = [];
		parsedNode.funcs = [];
		
   		/**
   		 * syntax analyzer 
   		 */
   		 
   		if(lexemsArr.length>1)
   		{
   			parsedNode.type = CT_MULTI;
   		}
   		
		for(i=0; i<lexemsArr.length; i++)
		{    			
	   		parsedNode.vars.push(null);
	   		parsedNode.funcs.push(null);
	   		
	   		var obj:Object;
			var strSentence:String = "";       			
			
			for(var j:int=0; j<lexemsArr[i].length; j++)
				strSentence = strSentence + lexemsArr[i][j].type;
				
			// parse operations
			obj = Parser.isValidCommand(strSentence);
			parsedNode.result = obj.result;			
			if(parsedNode.result && !parsedNode.type)
			{
				parsedNode.type = CT_OPERATION;
			}
			
			// parse test
			if(!parsedNode.result && !parsedNode.error)
			{
				obj = Parser.isValidTest(strSentence);
				parsedNode.result = obj.result;
				if(parsedNode.result && !parsedNode.type)
				{
					parsedNode.type = CT_TEST;
					parsedNode.trans = ["true", "false"];
				}
				else if(parsedNode.result && parsedNode.type==CT_MULTI)
				{
					parsedNode.result = false;
					parsedNode.error = new CompilerError(null, 9000);
				}
			}
			
			// parse function
			if(!parsedNode.result && !parsedNode.error)
			{
				obj = Parser.isValidFunction(strSentence);
				parsedNode.result = obj.result;				
				if(parsedNode.result)
				{
					if(!parsedNode.type)
						parsedNode.type = CT_FUNCTION;
					
					var func:Object = Parser.isFunctionExists(lexemsArr[i]);
					parsedNode.result = func.result;
					parsedNode.error = func.error;
				
					parsedNode.vars[i] = func.variable;
					parsedNode.funcs[i] = func.func;
				}				
			}  		     

			if(!parsedNode.result  && !parsedNode.error) 
			{
				parsedNode.error = new CompilerError(null, 9000);
			}
			
			if(parsedNode.error)
				return parsedNode;
		}  		
		
		return parsedNode;
	}

	public static function executeCode(	node:ParsedNode,
										index:int,
										contexts:Array,			 
										varPrefix:String = "" ):void
	{
		node.value = null;
		node.result = false;
		node.print = false;
		
		node.trans = [];
		//node.transition = null;
		
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
			node.trans = ["true", "false"];
			node.print = false;
		}
		else if(node.funcs[index])
		{
			if(node.funcs[index]=='loadDataFrom')
				node.trans = ["true", "false"];
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