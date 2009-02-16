package PowerPack.com.gen.parse
{
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.gen.*;
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
	
	public static function resetCodeFragmentCurrent(fragment:CodeFragment):void
	{
		fragment.executed = false;
		fragment.current = 0;

		for(var i:int=0; i<fragment.fragments.length; i++)
		{
			if(fragment.fragments[i] is CodeFragment)
				resetCodeFragmentCurrent(fragment.fragments[i]);
		}
	}

	public static function resetBlockCurrent(block:ParsedBlock):void
	{
		block.executed = false;
		block.current = 0;		

		for(var i:int=0; i<block.fragments.length; i++)
		{
			if(block.fragments[i] is CodeFragment)
				resetCodeFragmentCurrent(block.fragments[i]);
		}
	}
	
	public static function evaluateLexem(lexem:LexemStruct, contexts:Array):void
	{
		switch(LexemStruct(lexem).type)
		{
			case 'v':
				lexem.code = String(lexem.origValue).substring(1);
				lexem.value = Parser.eval(lexem.code, contexts);
				break;
				
			case 't':
				lexem.value = Utils.replaceEscapeSequences(lexem.origValue.toString(), "\\r");
				lexem.value = Utils.replaceEscapeSequences(lexem.value.toString(), "\\n");
				lexem.value = Utils.replaceEscapeSequences(lexem.value.toString(), "\\t");
				lexem.value = Utils.replaceEscapeSequences(lexem.value.toString(), "\\$");
				lexem.value = Utils.replaceEscapeSequences(lexem.value.toString(), "\\\\");
				lexem.code = lexem.value;
				break;
			
			case 'n':
				lexem.value = Utils.quotes(String(lexem.origValue));
				lexem.code = lexem.value;
				break;
				
			case '[':
			case ']':
			case '{':
			case '}':
			case ';':
				lexem.value = '';
				lexem.code = lexem.value;
				break;
		}		
	}
	
	public static function executeCodeFragment(fragment:CodeFragment, contexts:Array, stepReturn:Boolean=false, evaluate:Boolean=false):void
	{
		if(!fragment.validated)
		{
			Parser.validateCodeFragment(fragment);
		}
		
		if(fragment.errFragment)
			return;
		
		var subfragment:Object;
		for(var i:int=fragment.current; i<fragment.fragments.length; i++)
		{
			subfragment = fragment.fragments[i];
			if(subfragment is CodeFragment && (fragment.ctype!=Parser.CT_LIST || evaluate))
			{
				executeCodeFragment(subfragment as CodeFragment, contexts, stepReturn, evaluate);
				if(CodeFragment(subfragment).executed)
					fragment.current = i+1;	
				
				if(CodeFragment.lastExecutedFragment.ctype == Parser.CT_FUNCTION && 
					(stepReturn || CodeFragment.lastExecutedFragment.retValue is Function))
					return;
			}
			else if(subfragment is LexemStruct)
			{
				evaluateLexem(subfragment as LexemStruct, contexts);
				fragment.current = i+1;
			}
		}

		// generate executable code
		var code:String = '';
		var tmpValue:Object
		fragment.code = '';
		switch(fragment.ctype)
		{
			case Parser.CT_TEXT:
				for(i=0; i<fragment.fragments.length; i++) 
				{
					subfragment = fragment.fragments[i];
					 
					if(subfragment is CodeFragment)
					{
						tmpValue = 'null';
						if((subfragment as CodeFragment).retValue)
							tmpValue = (subfragment as CodeFragment).retValue;
					}
					else if(subfragment is LexemStruct)
					{
						tmpValue = LexemStruct(subfragment).value;
					}

					code += tmpValue;
					fragment.code += LexemStruct(subfragment).code;
				}
				
				fragment.retValue = code;
				CodeFragment.lastExecutedFragment = fragment;
				return;
				
				break;
							
			case Parser.CT_OPERATION:
			case Parser.CT_TEST:
				for(i=0; i<fragment.fragments.length; i++) 
				{
					subfragment = fragment.fragments[i];
					 
					if(subfragment is CodeFragment)
					{
						tmpValue = 'null';
						if((subfragment as CodeFragment).retValue)
							tmpValue = (subfragment as CodeFragment).retValue;
					}
					else if(subfragment is LexemStruct)
					{
						tmpValue = LexemStruct(subfragment).value;							
					}

					code += tmpValue;
					fragment.code += LexemStruct(subfragment).code;
				}	
				break;
				
			case Parser.CT_FUNCTION:
				Parser.processOperationGroups(fragment.fragments);				
				
				for(i=2; i<fragment.fragments.length-1; i++)
				{
					subfragment = fragment.fragments[i];
					tmpValue = 'null';
					
					if(subfragment is CodeFragment)
					{
						if((subfragment as CodeFragment).retValue)
							tmpValue = (subfragment as CodeFragment).retValue;
					}
					else if(subfragment is LexemStruct)
					{
						tmpValue = LexemStruct(subfragment).value;					
					}

					var sep:String = (fragment.fragments[i-1].operationGroup!=fragment.fragments[i].operationGroup && 
								code.length && tmpValue.toString().length ? "," : "");
								 										
					code += sep + tmpValue.toString();
					
					fragment.code += sep + LexemStruct(subfragment).code;
				}
				
				code = TemplateStruct.CNTXT_INSTANCE + "." + 
					 fragment.funcName + "(" + code + ")";				
				
				fragment.code = TemplateStruct.CNTXT_INSTANCE + "." + 
					 fragment.funcName + "(" + fragment.code + ")";	
					 			
				break;
				
			case Parser.CT_ASSIGN:
				for(i=0; i<fragment.fragments.length-1; i+=2)
				{
					subfragment = fragment.fragments[i];
					var nextSubfragment:Object = fragment.fragments[i+1];
					
					tmpValue = '';
					
					if(nextSubfragment is LexemStruct && LexemStruct(nextSubfragment).type=='=')
					{
						if(subfragment is CodeFragment)
						{
							if((subfragment as CodeFragment).retValue)
								tmpValue = (subfragment as CodeFragment).code;
							else
								tmpValue = '';
						}
						else if(subfragment is LexemStruct)
						{
							tmpValue = LexemStruct(subfragment).code;
						}
						
						// add prefix
						tmpValue += fragment.varPrefix + tmpValue.toString();
						fragment.varNames.push(tmpValue);
						
						code += tmpValue + '=';
						fragment.code += tmpValue + '=';
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
						tmpValue = 'null';
						if((subfragment as CodeFragment).retValue)
							tmpValue = (subfragment as CodeFragment).retValue;
					}
					else if(subfragment is LexemStruct)
					{
						tmpValue = LexemStruct(subfragment).value;
					}
						
					code += tmpValue;
					fragment.code += LexemStruct(subfragment).code;
				}
				break;
				
			case Parser.CT_LIST:
				if(!evaluate)
				{
					tmpValue = Utils.quotes(fragment.origValue);
				}
				else
				{
					tmpValue = Utils.quotes(fragment.evalValue);
				}
				
				code = tmpValue.toString();
				fragment.code = tmpValue.toString();
				break;
								
			default:			
				switch(fragment.type)
				{
					case 'W': // advanced var
						for(i=1; i<fragment.fragments.length-1; i++) 
						{
							subfragment = fragment.fragments[i];
							 
							if(subfragment is CodeFragment)
							{
								tmpValue = 'null';
								if((subfragment as CodeFragment).retValue)
									tmpValue = (subfragment as CodeFragment).retValue;
							}
							else if(subfragment is LexemStruct)
							{
								tmpValue = LexemStruct(subfragment).value;
							}

							code += tmpValue;
						}
						code = Parser.eval(code, contexts);
						fragment.code = code;
						break;
				}
		}
		
		// execute generated code
		fragment.retValue = Parser.eval(code, contexts);
		fragment.executed = true;
		CodeFragment.lastExecutedFragment = fragment;
	}

	public static function executeBlock(block:ParsedBlock, contexts:Array, stepReturn:Boolean=false):void
	{
		if(!block.validated)
		{
			Parser.validateFragmentedBlock(block);			
		}

		if(block.errFragment)
			return;
		
		if(block.executed)
			return;
		
		while(block.current<block.fragments.length)
		{
			var curFragment:CodeFragment = block.fragments[block.current];

			executeCodeFragment(curFragment, contexts, stepReturn);
		
			if(curFragment.executed)
				block.current++;
				
			if(stepReturn)
				return;
		}
		
		block.executed = true;
	}

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
		var block:ParsedBlock = Parser.fragmentLexems(Parser.getLexemArray(text.concat(), false), 'text');
  		
    	if(block.errFragment)
    		return block; 
		
		Parser.validateFragmentedBlock(block);
		
    	if(block.errFragment)
    		return block;

		if(contexts)
		{
			executeBlock(block, contexts);
		}
		
       	return block;
	}
		
	/**
	 * 
	 * @param _nodeText
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			value: String - parsed string
	 * 
	 */
	public static function ParseSubgraphNode( nodeText:String ):ParsedBlock
	{
		var pattern:RegExp;
		var str:String = nodeText.concat();
		var block:ParsedBlock = new ParsedBlock();
		
    	pattern = /[\W]/gi;
		block.retValue = str;		
		
		if(pattern.test(str))
		{
			block.error = new ValidationError(MSG_SN_SYNTAX_ERR);
   		}
		
       	return block;
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
	public static function ParseCode( code:String ):ParsedBlock
	{
		var block:ParsedBlock = Parser.fragmentLexems(Parser.getLexemArray(code.concat(), true), 'code');
  		
    	if(block.errFragment)
    		return block;
		
		Parser.validateFragmentedBlock(block);
		
    	if(block.errFragment)
    		return block;

       	return block;
	}

	/*
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
	*/
}
}