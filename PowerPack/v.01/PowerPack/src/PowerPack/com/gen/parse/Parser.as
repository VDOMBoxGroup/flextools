package PowerPack.com.gen.parse
{
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.gen.TemplateStruct;
import PowerPack.com.gen.errorClasses.CompilerError;
import PowerPack.com.gen.parse.parseClasses.CodeFragment;
import PowerPack.com.gen.parse.parseClasses.LexemStruct;
import PowerPack.com.gen.parse.parseClasses.ParsedBlock;
import PowerPack.com.managers.LanguageManager;

import flash.utils.describeType;

import mx.utils.UIDUtil;

import r1.deval.D;
import r1.deval.rt.FunctionDef;

public class Parser
{		
	public static var funcDefinition:Object =
		{			
			/**
			* [ function_pattern, function_name, args_num ] 
			*/
			
			//*********************
			// General functions
			//*********************
								
			'sub':				{ pattern:/^\[nn[nobvscifVNSA]*\]$/, 				argNum:-1 },
			'subPrefix':		{ pattern:/^\[nnn[nobvscifVNSA]*\]$/, 				argNum:-2 },
			'question':			{ pattern:/^\[n[vscVSA][nvscVSA]*\]$/, 				argNum:-1 },
			'qSwitch':			{ pattern:/^\[n[vscVSA][nsc]*\]$/,					argNum:-2,	trans:[] },
			"_switch":			{ pattern:/^\[n[nvscVSA][nsc]*\]$/, 				argNum:-2,	trans:[] },
			'convert':			{ pattern:/^\[n[vscVSA][vsciVNSA]\]$/, 				argNum:2 },
			'loadDataFrom':		{ pattern:/^\[n[vscVSA]\]$/, 						argNum:1,	trans:['true', 'false'] },
			'writeTo':			{ pattern:/^\[n[vscVSA]\]$/, 						argNum:1 },
			'writeVarTo':		{ pattern:/^\[n[vscVSA][vscifVNSA]\]$/, 			argNum:2 },
			'GUID':				{ pattern:/^\[n\]$/, 								argNum:0 },
			"mid":				{ pattern:/^\[n[viVNA][viVNA][vscVSA]\]$/, 			argNum:3 },
			"replace":			{ pattern:/^\[n[vscVSA][vscVSA][vscVSA][vscVSA]\]$/, argNum:4 },
			"split":			{ pattern:/^\[n[vscVSA][vscVSA]\]$/, 				argNum:2 },
			"random":			{ pattern:/^\[n[viVNA]\]$/, 						argNum:1 },
			"imageToBase64":	{ pattern:/^\[n[v][vscVSA]\]$/, 					argNum:2 },
			
			//*********************
			// List manipulation
			//*********************
			
			"length":			{ pattern:/^\[n[vscVSA]\]$/, 						argNum:1 },
			"getValue":			{ pattern:/^\[n[nviscVNSA][vscVSA]\]$/, 			argNum:2 },
			"getType":			{ pattern:/^\[n[nviscVNSA][vscVSA]\]$/, 			argNum:2 },
			"update":			{ pattern:/^\[n[nviscVNSA][nviscVNSA][nobvscifVNSA][vscVSA]\]$/, argNum:4 },
			"put":				{ pattern:/^\[n[nviscVNSA][nviscVNSA][nobvscifVNSA][vscVSA]\]$/, argNum:4 },
			"remove":			{ pattern:/^\[n[nviscVNSA][vscVSA]\]$/, 				argNum:2 },
			"exist":			{ pattern:/^\[n[nviscVNSA][nobvscifVNSA][vscVSA]\]$/, 	argNum:3 },
			"evaluate":			{ pattern:/^\[n[vscVSA]\]$/, 							argNum:1 },
			"execute":			{ pattern:/^\[n[vscVSA]\]$/, 							argNum:1 },

			"addStructure":		{ pattern:/^\[n[nvscVSA][nvscVSA][viVNA][vscVSA]\]$/, argNum:4 },
			"updateStructure":	{ pattern:/^\[n[nvscVSA][nvscVSA][viVNA][vscVSA]\]$/, argNum:4 },
			"deleteStructure":	{ pattern:/^\[n[nvscVSA][nvscVSA][viVNA][vscVSA]\]$/, argNum:4 },

			//*********************
			// Graphic functions
			//*********************

			"loadImage":		{ pattern:/^\[n[vscVSA]\]$/, 						argNum:1 },
			"createImage":		{ pattern:/^\[n[viVNA][viVNA][viVNA]\]$/, 			argNum:3 },
			"getWidth":			{ pattern:/^\[n[vA]\]$/, 							argNum:1 },
			"getHeight":		{ pattern:/^\[n[vA]\]$/, 							argNum:1 },
			"getPixel":			{ pattern:/^\[n[vA][viVNA][viVNA]\]$/, 				argNum:3 },
			"getPixel32":		{ pattern:/^\[n[vA][viVNA][viVNA]\]$/, 				argNum:3 },
			"setPixel":			{ pattern:/^\[n[vA][viVNA][viVNA][viVNA]\]$/, 		argNum:4 },
			"getImage":			{ pattern:/^\[n[viVNA][vscVSA]\]$/, 				argNum:2 }, // ???
			
			"addImage":			{ pattern:/^\[n[vA]{1,2}[viVNA][viVNA][viVNA][viVNA]\]$/, 	argNum:-5 },
			"mergeImages":		{ pattern:/^\[n[vA][vA][viVNA]\]$/, 						argNum:3 },
			
			"drawLine":			{ pattern:/^\[n[vA][viVNA][viVNA][viVNA][viVNA][vscVSA][viVNA]\]$/, 				argNum:7 },
			"drawPolygon":		{ pattern:/^\[n[vA][vscVSA][vscVSA][vscVSA][viVNA]\]$/, 							argNum:5 },
			"drawAngleArc":		{ pattern:/^\[n[vA][viVNA][viVNA][viVNA][viVNA][viVNA][vscVSA][vscVSA][viVNA]\]$/, 	argNum:9 },
			"drawEllipse":		{ pattern:/^\[n[vA][viVNA][viVNA][viVNA][viVNA][vscVSA][vscVSA][viVNA]\]$/, 		argNum:8 },
			"drawRect":			{ pattern:/^\[n[vA][viVNA][viVNA][viVNA][viVNA][vscVSA][vscVSA][viVNA]\]$/, 		argNum:8 },
			"drawRoundRect":	{ pattern:/^\[n[vA][viVNA][viVNA][viVNA][viVNA][viVNA][vscVSA][vscVSA][viVNA]\]$/, 	argNum:9 },
			"drawBezier":		{ pattern:/^\[n[vA][vscVSA][vscVSA][viVNA]\]$/, 									argNum:4 },
			"fillBezier":		{ pattern:/^\[n[vA][vscVSA][vscVSA][vscVSA][viVNA]\]$/, 							argNum:5 },
			"writeText":		{ pattern:/^\[n[vA][vscVSA][viVNA][viVNA][viVNA][viVNA][vscVSA][viVNA]\]$/, 		argNum:8 },

			"cropImage":		{ pattern:/^\[n[vA][viVNA][viVNA][viVNA][viVNA]\]$/, 	argNum:5 },
			"flipImage":		{ pattern:/^\[n[vA][viVNA]\]$/, 						argNum:2 },
			"resizeImage":		{ pattern:/^\[n[vA][viVNA][viVNA]\]$/, 					argNum:3 },
			"resizeResampling":	{ pattern:/^\[n[vA][viVNA][viVNA]\]$/, 					argNum:3 }, // ???
			"rotateImage":		{ pattern:/^\[n[vA][viVNA][viVNA]\]$/, 					argNum:3 },

			"brightness":		{ pattern:/^\[n[vA][viVNA]\]$/, 				argNum:2 },
			"contrast":			{ pattern:/^\[n[vA][viVNA]\]$/, 				argNum:2 },
			"saturation":		{ pattern:/^\[n[vA][viVNA]\]$/, 				argNum:2 },
			"createBlackWhite":	{ pattern:/^\[n[vA]\]$/, 					argNum:1 },
			"createGrayScale":	{ pattern:/^\[n[vA]\]$/, 					argNum:1 },
			"createNegative":	{ pattern:/^\[n[vA]\]$/, 					argNum:1 },

			"blur":				{ pattern:/^\[n[vA][viVNA]\]$/, 					argNum:2 },
			"sharpen":			{ pattern:/^\[n[vA][viVNA]\]$/, 					argNum:2 },
			"emboss":			{ pattern:/^\[n[vA]\]$/, 							argNum:1 }
		};		
	
	public static function getLexemArray(sourceText:String, isCode:Boolean=true):Array
	{
   		var lexems:Array = new Array();
   		    		
		/**
		 * LEXEM TYPES: utwnobifvsc12345=90{}[];VNSOLFAWE
		 * 
		 * ----------------Lexems-------------------  		  
		 * u - undefined symbol
		 * t - text
		 * w - word (any ASCII chars sequence without spaces. USED IN LISTS)
		 * n - name (identifier: function name, graph name, prefix, etc)
		 * o - keyword 'null'
		 * b - keyword ('true', 'false')
		 * v - variable
		 * i - integer constant
		 * f - float constant
		 * s - string constant (double quotes)
		 * c - string constant (single quotes)
		 * 1 - multiplicative operator (*, /, %)
		 * 2 - subtraction (-)
		 * 3 - addition (+)
		 * 4 - equality or relation operator (>, <, <=, >=, ==, !=)
		 * 5 - logical operator (&&, ||)
		 * = - (=)
		 * 9 - open bracer '('
		 * 0 - close bracer ')'
		 * { - '${'
		 * } - '}'
		 * [ - '['
		 * ] - ']'
		 * ; - command separator ';'
		 * 
		 * -------------Advanced Lexem Structures---------------
		 * V - any expression
		 * N - expression with numbers only
		 * S - expression that contains string
		 * O - expression with equality or relation operator
		 * L - expression with logical operators
		 * F - complete executable expression
		 * A - list
		 * W - advanced variable definition
		 * E - expression in '()' bracers
		 */
    		 
		var i:int=0; 		// iterator
		var j:int; 			// secondary iterator
		var fix:int; 		// current string position
		var type:String; 	// lexem type
		var err:Error;		// error
		var bPush:Boolean;	// add or not sequence to lexems array
		var braceStack:Array=[];
		var braceLexemStack:Array=[];
		var spaceStack:String='';
		
		while(i<sourceText.length)
		{
			fix=i;
			type='u'; // undefined lexem
			err=null;
			bPush=true;
			
			// if text block
			if(braceStack.length==0 && !isCode)
			{
    			type='t'; // text lexem
    			switch(sourceText.charAt(fix))
				{
					case '$': // variable
						parseVar();
    					break;

    				default: // text lexem
						do {
    						i++;
    					} while(i<sourceText.length && sourceText.charAt(i)!="$");        						
						i--;
						break;
				}
			}
			// if code block
			else
			{  
				type='u';
    			
    			switch(sourceText.charAt(fix))
    			{
    				case '"': // string
    				case "'":
						while(i+1<sourceText.length)
						{
	   						i++;    						
    						if(sourceText.charAt(i)==sourceText.charAt(fix))
    						{
    							// check for escape sequence
    							j = i-1;
								while(j>=0 && sourceText.charAt(j)=="\\")	    						
									j--;
				
								if((i-j)%2==1) 
	    							break;
    						}
    					}        						
						
    					if(i<sourceText.length)
    						type = (sourceText.charAt(fix)=='"' ? 's' : 'c');
    					else
    						err = new CompilerError(null, 9006);
    						    					
    					break;

    				case '$': // variable
   						parseVar();
    					break;

    				case '(':
   						type = '9'; // open bracer
						braceStack.push('(');
    					break;        
    				
    				case '[':
   						type = '['; // [ bracer
    					braceStack.push('[');	   						
    					break;        

    				case '}':
    				case ')':
    				case ']':
   						type = sourceText.charAt(fix)==')'?'0':sourceText.charAt(fix);   						   						
   						
   						var brace:String = "({[".charAt(")}]".indexOf(sourceText.charAt(fix)));
   						
   						if(braceStack.length>0 && braceStack[braceStack.length-1]==brace)
   							braceStack.pop(); 
   						else
   							err = new CompilerError(null, 9003, ["'"+sourceText.charAt(fix)+"'"]);
    					break;  
    									
    				case '*':
    				case '/':
    				case '%':
   						type = '1'; // multiplicative operator
    					break;
    					
    				case '-':
   						type = '2'; // minus
    					break;
    					
    				case '+':
   						type = '3'; // plus
    					break;
    					
    				case ';':
   						type = ';'; // command separator
   						
   						do {
   							i++;
   						} while(sourceText.charAt(i)==';' || sourceText.charAt(i).search(/\s/)>=0)
			    		i--;
			    		
			    		if(braceStack.length>0)
			    		{
			    			brace = ")}]".charAt("({[".indexOf(braceStack[braceStack.length-1]));
			   				LexemStruct(braceLexemStack[braceLexemStack.length-1]).error = new CompilerError(null, 9005, ["'"+brace+"'"]);							    			
			    		}	   						
    					break;	
    					
    				default: 
    					if(i+2<sourceText.length && sourceText.substr(i,3).search(/0x[0-9a-f]/i)>=0) // hex
    					{
    						i=i+2;
    						do {
    							i++;
    						} while(i<sourceText.length && sourceText.charAt(i).search(/[0-9a-f]/i)>=0);
    						i--;
    						type = 'i'; // hex integer constant    						
    					}
    					else if(sourceText.charAt(i).search(/\d/)>=0) // digit
    					{
    						do {
    							i++;
    						} while(i<sourceText.length && sourceText.charAt(i).search(/\d/)>=0);
    						i--;
    						type = 'i'; // integer constant

       						if(i+2>=sourceText.length)
    							break;
    							       						
    						if(sourceText.charAt(i+1)=='.' && sourceText.charAt(i+2).search(/\d/)>=0)
    						{
    							i++;
    							do {
    								i++;	
    							} while(i<sourceText.length && sourceText.charAt(i).search(/\d/)>=0);
    							i--;   
    							type = 'f'; // float constant
    						}        						
    						break;
    					}
    					else if(sourceText.charAt(i).search(/[_a-z]/i)>=0) // name or keyword (null, true, false)
    					{
    						do {
    							i++;
    						} while(i<sourceText.length && sourceText.charAt(i).search(/[_a-z0-9]/i)>=0);
							i--;
       						type = 'n'; // name
       						
       						switch(sourceText.substring(fix, i+1))
       						{
       							case "null":
       								type = 'o';
       								break;
       							case "true":
       							case "false":
       								type = 'b';
       								break;
       						}	       						
       						break;
    					}
    					else if(sourceText.charAt(i).search(/[=!<>\|&]/)>=0) // any operator or '='
    					{
    						if(sourceText.charAt(i).search(/=/)>=0)
    						{
        						type = '='; // '='
    						}        						
    						else if(sourceText.charAt(i).search(/[<>]/)>=0)
    						{
        						type = '4'; // operator
    						}

    						if(i+1<sourceText.length)
    						{
    							if(	sourceText.charAt(i).search(/[=!<>]/)>=0 && sourceText.charAt(i+1).search(/=/)>=0 )
    							{
    								i++;
    								type = '4'; // operator
    							}
    							else if(
        							sourceText.charAt(i).search(/\|/)>=0 && sourceText.charAt(i+1).search(/\|/)>=0 ||
        							sourceText.charAt(i).search(/&/)>=0 && sourceText.charAt(i+1).search(/&/)>=0 )
        						{
    								i++;
    								type = '5'; // logical operator	       						
        						}
    						}        						
    						break;        						
    					}
    					else if(sourceText.charAt(i).search(/\s/)>=0) // any white space
    					{
    						spaceStack += sourceText.charAt(i);
        					bPush=false;        				        					
        					break;        					
        				}	        				
    			}			
			}
			
			if(i>=sourceText.length)
				i=sourceText.length-1;
			
			if(bPush)
			{
				if(braceStack[braceStack.length-1]=='[' && type=='u' && !err)
					type = 'w';
				
				if(type=='u' && !err)
					err = new CompilerError(null, 9002, ["("+sourceText.substring(fix, i+1)+")"]);
 				
 				if(lexems.length && LexemStruct(lexems[lexems.length-1]).type=='t' && type=='t')
 				{
 					var substr:String = sourceText.substring(fix, i+1);
 					var lastLexem:LexemStruct = LexemStruct(lexems[lexems.length-1]); 
 					
 					lastLexem.origValue += substr;  
 					lastLexem.value = lastLexem.origValue; 
 					lastLexem.code = lastLexem.origValue;  
 				}
 				else
 				{
 					lexems.push(new LexemStruct(sourceText.substring(fix, i+1), type, fix, err));
 					
 					if(type=='n')
 					{
	 					lastLexem = LexemStruct(lexems[lexems.length-1]); 
 						lastLexem.value = Utils.quotes(String(lastLexem.origValue));
 						lastLexem.code = lastLexem.value; 						
 					}
 				}
 				
 				if(lexems.length>1)
 					LexemStruct(lexems[lexems.length-2]).tailSpaces = spaceStack;
 				
 				if("9{[".indexOf(LexemStruct(lexems[lexems.length-1]).type)>=0)
 					braceLexemStack.push(lexems[lexems.length-1]);
 				else if("0}]".indexOf(LexemStruct(lexems[lexems.length-1]).type)>=0 && braceLexemStack.length)
 				{
 					LexemStruct(lexems[lexems.length-1]).relative = LexemStruct(braceLexemStack[braceLexemStack.length-1]); 
 					LexemStruct(braceLexemStack[braceLexemStack.length-1]).relative = LexemStruct(lexems[lexems.length-1]);
 					braceLexemStack.pop();
 				}
 				
 				spaceStack = '';		
 			} 					
			i++;        			        				
		} 
		
		if(braceStack.length>0 && lexems.length>0 && !lexems[lexems.length-1].error)
		{
			brace = ")}]".charAt("({[".indexOf(braceStack[braceStack.length-1]));
			LexemStruct(braceLexemStack[braceLexemStack.length-1]).error = new CompilerError(null, 9005, ["'"+brace+"'"]);
		}
			
		return lexems;
		
		// ------------------------------------------------------------------------
		
		function parseVar():void {
			i++;
			// check '$' is not last  symbol
			if(i>=sourceText.length) 
			{
				err = new CompilerError(null, 9001);
				return;
			}
			
			if(!isCode) 
			{
				// check for escape sequence
				j = fix-1;
	    		while(j>=0 && sourceText.charAt(j)=="\\")
	    			j--;
	    					
				if((fix-j)%2==0)
					return;
			}

			if(sourceText.charAt(i)=='{') //advanced variable begin
			{	
				type = '{';
				braceStack.push('{');
				return;
			}
			
			// check for not valid symbol in var name
			if(sourceText.charAt(i).search(/[^_a-z]/i)>=0)
			{
				err = new CompilerError(null, 9001);
				return;
			}
			
			do {
				i++;
			} while(i<sourceText.length && sourceText.charAt(i).search(/[_a-z0-9]/i)>=0);
										
			i--;
   			type = 'v'; // variable			
		}		
	}
	
	/**
	 * Divide lexem array into operation groups
	 * 
	 * @param lexems
	 * @return 
	 * 
	 */
	public static function processOperationGroups(fragments:Array):void
	{			
		var checkNext:Boolean = false;
		var prevLexem:LexemStruct;
		var curLexem:LexemStruct;
		
		LexemStruct(fragments[0]).operationGroup = 1;

		for(var i:int=0; i<fragments.length; i++)
		{
			curLexem = LexemStruct(fragments[i]);
			
			if(prevLexem)
			{
				// check current lexem
				if(checkNext)
					curLexem.operationGroup = prevLexem.operationGroup;

				checkNext = false;
			
				// increase group num and check current lexem
				if(curLexem.operationGroup==0)
					curLexem.operationGroup = prevLexem.operationGroup+1;
			}
			
			// check operands
			switch(curLexem.type)
			{
				case '2':	// -
				case '3':	// +					
				case '1':	// /,%,*
					checkNext = true;
				case '0':	// )
				case '}':	// }
				case ']':	// ]
					if(prevLexem)			
						curLexem.operationGroup = prevLexem.operationGroup;
					break;
				case '9':	// (
				case '{':	// ${
				case '[':	// [
					checkNext = true;
					break;
			}
			
			prevLexem = curLexem;
		}
	}		

	public static function processListGroups(fragments:Array):void
	{
		var increaseNext:Boolean = false;
				
		var prevFragment:LexemStruct;
		var curFragment:LexemStruct;

		for (var i:int=0; i<fragments.length; i++)
		{			
			curFragment = fragments[i];			
			
			if(prevFragment)
				curFragment.listGroup = prevFragment.listGroup + (increaseNext?1:0);
			else if(curFragment is CodeFragment && CodeFragment(curFragment).parent is CodeFragment)
				curFragment.listGroup = CodeFragment(CodeFragment(curFragment).parent).listGroup;
			else
			 	curFragment.listGroup = 1;
			
			increaseNext = false;
			
			if(curFragment.tailSpaces)
			{
				increaseNext = true;
			}
			
			if(curFragment is CodeFragment)
			{
				processListGroups(CodeFragment(curFragment).fragments);
				prevFragment = CodeFragment(curFragment).lastLexem;
			}	
			else
				prevFragment = curFragment;
		}	
	}
	
	/**
	 * All non top level subfragments starts with ( or [ or {
	 *  
	 * @param lexems
	 * @param codeType
	 * @return 
	 * 
	 */
	public static function fragmentLexems(lexems:Array, codeType:String):ParsedBlock
	{
		var block:ParsedBlock = new ParsedBlock();
		
		block.type = codeType;
		block.lexems = lexems.concat();
		
		var index:int = 0;				
		while(index<block.lexems.length)
		{
			switch(codeType)
			{
				case 'text':
					break;	
				
				case 'code':
					break;
			}
			
			block.fragments.push(recursiveFragmentLexems(";", "F", block));
			
			var lastFragm:CodeFragment = block.fragments[block.fragments.length-1] as CodeFragment;
			if(	lastFragm.fragments.length==1 && lastFragm.fragments[0] is CodeFragment ||
				lastFragm.fragments.length==2 && lastFragm.fragments[0] is CodeFragment && LexemStruct(lastFragm.fragments[1]).type==';')
			{
				block.fragments[block.fragments.length-1] = lastFragm.fragments[0];
				CodeFragment(lastFragm.fragments[0]).parent = block;
			}
			
			index++;
		}
		
		return block;
		
		//-------------------------------------------------------------------------------------------------
		
		function recursiveFragmentLexems(_terminal:String, _ftype:String, _parent:Object):CodeFragment {
			var _fragment:CodeFragment = new CodeFragment(_ftype);
			_fragment.parent = _parent; 
			
			if(_parent is CodeFragment)
			{
				_fragment.fragments.push(block.lexems[index]);
				index++;
			}
				
			while(index<block.lexems.length && block.lexems[index].type!=_terminal)
			{
				if("[{9".indexOf(block.lexems[index].type)>=0)
				{
					var _subfragment:CodeFragment = recursiveFragmentLexems(
							"]}0".charAt("[{9".indexOf(block.lexems[index].type)), 
							"AWE".charAt("[{9".indexOf(block.lexems[index].type)),
							_fragment);
					_fragment.fragments.push(_subfragment);
				}
				else
					_fragment.fragments.push(block.lexems[index]);
					
				index++;
			}
			
			if(index<block.lexems.length && block.lexems[index].type==_terminal)
				_fragment.fragments.push(block.lexems[index]);

			return _fragment;
		}
	}
	
	public static function isFunctionExist(funcName:String):Boolean
	{
		var typeDescr:XML = describeType(TemplateStruct.lib);
		var funcDescr:XMLList = typeDescr..method.(@name == funcName);
		return (funcDescr.length()>0 || TemplateStruct.lib[funcName] is FunctionDef);		
	}	
	
	public static function getFunctionTrans(fragment:CodeFragment, paramOffset:int=3):Array
	{
		var arr:Array = [];
		var tmpValue:String = '';
		var concat:String = '';
		var prevGrp:int = -1;
		
		if(fragment.ctype != CodeFragment.CT_FUNCTION)
			return null;
		
		Parser.processOperationGroups(fragment.fragments);				
		
		for(var i:int=paramOffset; i<fragment.fragments.length-1; i++)
		{
			var subfragment:LexemStruct = fragment.fragments[i];
			
			if(subfragment is CodeFragment)
			{
				switch(subfragment.type)
				{
					case 'c':
					case 's':
					case 'n':
						tmpValue = Utils.replaceAllBracers((subfragment as CodeFragment).origValue);
						break;
					default:
						tmpValue = (subfragment as CodeFragment).origValue;
				}
				
			}
			else if(subfragment is LexemStruct)
			{
				tmpValue = Utils.replaceQuotes(LexemStruct(subfragment).value);
			}
			
			if(prevGrp!=-1 && prevGrp!=subfragment.operationGroup)
			{
				arr.push(concat);
				concat = '';
			}
			
			concat += tmpValue;
			prevGrp = subfragment.operationGroup;
		}
		
		if(concat)
			arr.push(concat);
			
		return arr; 		
	}
	
	public static function validateCodeFragment(fragment:CodeFragment):void
	{
		var lexemObj:Object;
		var strSentence:String = "";
		
		// validate current subfragments
		
		for each(var subfragment:Object in fragment.fragments)
		{
			if(subfragment is CodeFragment)
				validateCodeFragment(subfragment as CodeFragment);
		
			if(fragment.errFragment)
				return; 
		}		

		// validate current fragment
		
		for(var i:int=0; i<fragment.fragments.length; i++)
			strSentence = strSentence + LexemStruct(fragment.fragments[i]).type;		
		
		strSentence = rollUpSeparator(strSentence);
		
		// check for operation
		lexemObj = isValidOperation(strSentence);
		if(lexemObj.result && lexemObj.value.length==1)
		{
			//if(fragment.isTopLevel)
			//	fragment.print = true;

			fragment.type = lexemObj.value;
			fragment.ctype = CodeFragment.CT_OPERATION;
			fragment.validated = true;
			return;
		}
		
		// check for test
		lexemObj = isValidTest(lexemObj.value);
		if(lexemObj.result && lexemObj.value.length==1)
		{
			if(fragment.isTopLevel)
				fragment.trans = ["true", "false"];
				
			fragment.type = lexemObj.value;
			fragment.ctype = CodeFragment.CT_TEST;
			fragment.validated = true;
			return;
		}
		
		// check for advanced variable
		lexemObj = isValidAdvVar(lexemObj.value);
		if(lexemObj.result && lexemObj.value.length==1)
		{
			//if(fragment.isTopLevel)
			//	fragment.print = true;
				
			fragment.type = lexemObj.value;
			fragment.ctype = CodeFragment.CT_ADV_VAR;
			fragment.validated = true;
			return;
		}

		// check for function
		var funcObj:Object = isValidFunction(lexemObj.value);
		var funcName:String;
		if(funcObj.result && funcObj.value.length==1)
		{ 
			var argNum:int = lexemObj.value.indexOf("]") - lexemObj.value.indexOf("[")-2;
			funcName = LexemStruct(fragment.fragments[1]).origValue;
		
			switch(funcName)
			{
				case 'get':
					funcName = 'getValue';
					break;
					
				case 'switch':
					funcName = '_switch';
					break;
			}
				
			if(isFunctionExist(funcName))
			{
				//if(fragment.isTopLevel)
				//	fragment.print = true;
				
				fragment.type = funcObj.value;
				fragment.ctype = CodeFragment.CT_FUNCTION;			
				fragment.funcName = funcName;				
				
				var funcDef:Object = funcDefinition[fragment.funcName];
	
				// check for correct args number
				if(funcDef)
				{
					if(argNum!=funcDef.argNum && funcDef.argNum>=0)
					{
						fragment.error = new CompilerError(null, 9007, [funcDef.argNum]);
						return;
					}
					else if(funcDef.argNum<0 && argNum<Math.abs(funcDef.argNum))
					{
						fragment.error = new CompilerError(null, 9007, [">"+Math.abs(funcDef.argNum)]);
						return;
					}
					if(!RegExp(funcDef.pattern).test(lexemObj.value))
					{
						fragment.error = new CompilerError(null, 9011);
						return;
					}
					
					if(funcDef.trans)
					{ 
						if(funcDef.trans.length)
							fragment.trans = funcDef.trans;
						else
						{
							fragment.trans = getFunctionTrans(fragment);
							
							if(funcName=='_switch')
								fragment.trans.push(LanguageManager.sentences['other']+'...');
						}
					}
					
				}
				fragment.validated = true;
				return;
			}
		}
		
		// check for list
		lexemObj = isValidList(lexemObj.value);
		if(lexemObj.result && lexemObj.value.length==1)
		{
			//if(fragment.isTopLevel)
			//	fragment.print = true;
				
			fragment.ctype = CodeFragment.CT_LIST;							
			fragment.type = lexemObj.value;
			fragment.validated = true;
			return;			
		}
		
		// check for assign
		lexemObj = isValidAssign(lexemObj.value);
		if(lexemObj.result)
		{
			fragment.ctype = CodeFragment.CT_ASSIGN;
			fragment.validated = true;
			return;
		}
		
		fragment.error = new CompilerError(null, 9000);
	}

	public static function validateTextFragment(fragment:CodeFragment):void
	{
		var lexemObj:Object;
		var strSentence:String = "";
		
		// validate current subfragments
				
		for each(var subfragment:Object in fragment.fragments)
		{
			if(subfragment is CodeFragment)
				validateCodeFragment(subfragment as CodeFragment);
		
			if(fragment.errFragment)
				return; 
		}		

		// validate current fragment
		
		for(var i:int=0; i<fragment.fragments.length; i++)
			strSentence = strSentence + LexemStruct(fragment.fragments[i]).type;		
		
		lexemObj = isValidText(strSentence);
		if(!lexemObj.result)
		{
			fragment.error = new CompilerError(null, 9000);
			return;
		}
		
		fragment.ctype = CodeFragment.CT_TEXT;		
		fragment.print = true;
		fragment.validated = true;
	}
		
	public static function validateFragmentedBlock(block:ParsedBlock):void
	{
		for each (var fragment:Object in block.fragments)
		{
			switch(block.type)
			{
				case "code":
					validateCodeFragment(fragment as CodeFragment);
					break;
				
				case "text":
					validateTextFragment(fragment as CodeFragment);
					break;
			}
		}
		
		if(block.errFragment)
			return;
		
		block.validated = true;
	}	

	public static function eval(prog:String, contexts:Array):*
	{
		var _res:String = "_result_" + UIDUtil.createUID().replace(/-/g, "_"); 
		var _contexts:Array = [null, null];
		var _prog:String = _res + "=" + prog;
		var ret:*;
		
		if(contexts && contexts.length>0)
		{
			_contexts[0] = contexts[0];		
			if(contexts.length>1)
				_contexts[1] = contexts[1];		
		}
		
		D.eval(_prog, _contexts[0], _contexts[_contexts.length-1]);
		
		ret = _contexts[0][_res];
		delete _contexts[0][_res];
		return ret;
	}
	
	//--------------------------------------------------------------------------
    //
    //  Validation methods
    //
    //--------------------------------------------------------------------------
    	
	public static function rollLexemString(lexemString:String, patterns:Array):String
	{
		//var len:int;
		var prevLen:int;
		var index:int = 0;
		var strSentence:String = lexemString.concat();
		
		// parse operations
		//do {
		//	len = strSentence.length;
		//	index = 0;
			
			do {
				prevLen = strSentence.length;
				
				strSentence = strSentence.replace(patterns[index][0], patterns[index][1]);
				
				if(prevLen == strSentence.length)
					index++;
				else
					index=0;
			} while (index<patterns.length && strSentence.length);
			
		//} while	(len!=strSentence.length && strSentence.length)
		
		return strSentence;
	}
	
	public static function rollUpSigns(lexemString:String):String
	{
		var strSentence:String = lexemString.concat();
		var patterns:Array = 
			[
				[/(^|=|4|5|9|n|\[|\])[23](v|i|f|F|A|W|E)/g, 	"$1$2"]	// remove signs '-1...', '...=+2...', '...(-3...'
			];     			

		strSentence = rollLexemString(strSentence, patterns);
		
		return strSentence;
	}
	
	public static function rollUpSeparator(lexemString:String):String
	{
		var strSentence:String = lexemString.concat();
		var patterns:Array = 
			[
				[/^(.*)(;)+$/g, "$1"]	// remove ';' from tail
			];     			

		strSentence = rollLexemString(strSentence, patterns);
		
		return strSentence;
	}
		
	public static function isValidOperation(lexemString:String):Object
	{
		var strSentence:String = rollUpSigns(lexemString);
		var patterns:Array = 
			[
				[/[Nifo]1[Nifo]/g,	 		"N"],		// (*, /, %)

				[/[WVAv]1[WVANvifo]/g,		"V"],		// (*, /, %)				
				[/[WVANvifo]1[WVAv]/g,		"V"],		// (*, /, %)				

				[/[Nifo]2[Nifo]/g,	 		"N"],		// '-'
				[/[Nifo]3[Nifo]/g,			"N"],		// '+'					
				
				[/[Ssc]3[WVANSvifsco]/g,	"S"],		// '+'
				[/[WVANSvifsco]3[Ssc]/g,	"S"],		// '+'

				[/[WVAv]3[WVANvifo]/g,		"V"],		// '+'
				[/[WVANvifo]3[WVAv]/g,		"V"],		// '+'
				
				[/[WVAv]2[WVANvifo]/g,		"V"],		// '-'				
				[/[WVANvifo]2[WVAv]/g,		"V"],		// '-'				

				[/9(W|V|A|N|S|v|i|f|s|c|o)0/g,	"$1"]		// (x) -> x				
			];     			

		strSentence = rollLexemString(strSentence, patterns);
		
		if(/^[WVANSvifsco]$/.test(strSentence))
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}
			
	public static function isValidTest(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;

		var patterns:Array = 
			[
				[/[AWVNSvifscob]4[AWVNSvifscob]/g, 		"O"],	// operator
				[/[OLb]5[OLb]/g, 						"L"],	// logical operator
				[/9(O|L|b)0/g, 							"$1"]	// (x) -> x			
			]
		;     			

		strSentence = rollLexemString(strSentence, patterns);

		if(strSentence=="O" || strSentence=="L" || strSentence=="b")
			return {result: true, value: strSentence};	
		
		return {result: false, value: strSentence};						
	}

	public static function isValidAdvVar(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;  
		var pattern:RegExp;

		var patterns:Array = 
			[
				[/\{[WVASvsc]\}/g,		"W"]		// ${x} -> W
			];
	
		strSentence = rollLexemString(strSentence, patterns);
		
		if(strSentence=="W")
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}	

	public static function isValidFunction(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;  
		var pattern:RegExp;

		var patterns:Array = 
			[
				[/\[n[OLWVANSvifscobn]*\]/g, "A"]
			];
	
		strSentence = rollLexemString(strSentence, patterns);
		
		if(strSentence=="A")
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}	
			
	public static function isValidList(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;  
		var pattern:RegExp;

		var patterns:Array = 
			[
				[/\[[OLWVANSvifscobnwu]*\]/g, "A"]
			];
	
		strSentence = rollLexemString(strSentence, patterns);
		
		if(strSentence=="A")
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}
	
	public static function isValidAssign(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;
		
		var patterns:Array = 
			[
				[/^(v=)+[OLFWVANSvifscob]$/g,		"V"],				
				[/^(W=)+[OLFWVANSvifscob]$/g,		"V"]
			];     			

		strSentence = rollLexemString(strSentence, patterns);
		
		if(strSentence=="V")
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}
			
	public static function isValidText(lexemString:String):Object
	{
		var strSentence:String = lexemString.concat();

		var patterns:Array = 
			[
				[/[Wv]+/g, 				"t"],	// roll up vars
				[/t+/g, 				"t"]	// roll up text
			]
		;     			

		strSentence = rollLexemString(strSentence, patterns);

		if(strSentence=="t")
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}	
	
}
}