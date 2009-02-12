package PowerPack.com.gen.parse
{
import PowerPack.com.gen.TemplateStruct;
import PowerPack.com.gen.errorClasses.CompilerError;
import PowerPack.com.gen.parse.parseClasses.CodeFragment;
import PowerPack.com.gen.parse.parseClasses.LexemStruct;
import PowerPack.com.gen.parse.parseClasses.ParsedBlock;

import flash.utils.describeType;

import mx.utils.UIDUtil;

import r1.deval.D;

public class Parser
{		
	public static const CT_OPERATION:String = 'operation';
	public static const CT_TEST:String = 'test';
	public static const CT_FUNCTION:String = 'function';
	public static const CT_ASSIGN:String = 'assign';
	public static const CT_TEXT:String = 'text';
	public static const CT_LIST:String = 'list';
	
	public static var funcDefinition:Object =
		{			
			/**
			* [ function_pattern, function_name, args_num ] 
			*/
			
			//*********************
			// General functions
			//*********************
								
			'sub':				{ pattern:/^\[nn[nobvscifVNS]*\]$/, 			argNum:-1 },
			'subPrefix':		{ pattern:/^\[nnn[nobvscifVNS]*\]$/, 			argNum:-2 },
			'question':			{ pattern:/^\[n[vscVS][vscVS]\]$/, 				argNum:2 },
			'convert':			{ pattern:/^\[n[vscVS][vsciVNS]\]$/, 			argNum:2 },
			'loadDataFrom':		{ pattern:/^\[n[vscVS]\]$/, 					argNum:1,	trans:['true', 'false'] },
			'writeTo':			{ pattern:/^\[n[vscVS]\]$/, 					argNum:1 },
			'writeVarTo':		{ pattern:/^\[n[vscVS][vscifVNS]\]$/, 			argNum:2 },
			'GUID':				{ pattern:/^\[n\]$/, 							argNum:0 },
			"mid":				{ pattern:/^\[n[viVN][viVN][vscVS]\]$/, 		argNum:3 },
			"replace":			{ pattern:/^\[n[vscVS][vscVS][vscVS][vscVS]\]$/, argNum:4 },
			"split":			{ pattern:/^\[n[vscVS][vscVS]\]$/, 				argNum:2 },
			"random":			{ pattern:/^\[n[viVN]\]$/, 						argNum:1 },
			"imageToBase64":	{ pattern:/^\[n[v][vscVS]\]$/, 					argNum:2 },
			
			//*********************
			// List manipulation
			//*********************
			
			"length":			{ pattern:/^\[n[vscVSA]\]$/, 					argNum:1 },
			"getValue":			{ pattern:/^\[n[nviscVNS][vscVSA]\]$/, 			argNum:2 },
			"getType":			{ pattern:/^\[n[nviscVNS][vscVSA]\]$/, 			argNum:2 },
			"update":			{ pattern:/^\[n[nviscVNS][nviscVNS][nobvscifVNS][vscVSA]\]$/, argNum:4 },
			"put":				{ pattern:/^\[n[nviscVNS][nviscVNS][nobvscifVNS][vscVSA]\]$/, argNum:4 },
			"remove":			{ pattern:/^\[n[nviscVNS][vscVSA]\]$/, 			argNum:2 },
			"exist":			{ pattern:/^\[n[nviscVNS][nobvscifVNS][vscVSA]\]$/, argNum:3 },
			"evaluate":			{ pattern:/^\[n[vscVSA]\]$/, 					argNum:1 },
			"execute":			{ pattern:/^\[n[vscVSA]\]$/, 					argNum:1 },

			"addStructure":		{ pattern:/^\[n[nvscVSA][nvscVSA][viVN][vscVSA]\]$/, argNum:4 },
			"updateStructure":	{ pattern:/^\[n[nvscVSA][nvscVSA][viVN][vscVSA]\]$/, argNum:4 },
			"deleteStructure":	{ pattern:/^\[n[nvscVSA][nvscVSA][viVN][vscVSA]\]$/, argNum:4 },

			//*********************
			// Graphic functions
			//*********************

			"loadImage":		{ pattern:/^\[n[vscVS]\]$/, 					argNum:1 },
			"createImage":		{ pattern:/^\[n[viVN][viVN][viVN]\]$/, 			argNum:3 },
			"getWidth":			{ pattern:/^\[n[v]\]$/, 						argNum:1 },
			"getHeight":		{ pattern:/^\[n[v]\]$/, 						argNum:1 },
			"getPixel":			{ pattern:/^\[n[v][viVN][viVN]\]$/, 			argNum:3 },
			"getPixel32":		{ pattern:/^\[n[v][viVN][viVN]\]$/, 			argNum:3 },
			"setPixel":			{ pattern:/^\[n[v][viVN][viVN][viVN]\]$/, 		argNum:4 },
			"getImage":			{ pattern:/^\[n[viVN][vscVS]\]$/, 				argNum:2 }, // ???
			
			"addImage":			{ pattern:/^\[n[v]{1,2}[viVN][viVN][viVN][viVN]\]$/, argNum:-5 },
			"mergeImages":		{ pattern:/^\[n[v][v][viVN]\]$/, 				argNum:3 },
			
			"drawLine":			{ pattern:/^\[n[v][viVN][viVN][viVN][viVN][vscVSA][viVN]\]$/, argNum:7 },
			"drawPolygon":		{ pattern:/^\[n[v][vscVSA][vscVSA][vscVSA][viVN]\]$/, argNum:5 },
			"drawAngleArc":		{ pattern:/^\[n[v][viVN][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:9 },
			"drawEllipse":		{ pattern:/^\[n[v][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:8 },
			"drawRect":			{ pattern:/^\[n[v][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:8 },
			"drawRoundRect":	{ pattern:/^\[n[v][viVN][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:9 },
			"drawBezier":		{ pattern:/^\[n[v][vscVSA][vscVSA][viVN]\]$/, argNum:4 },
			"fillBezier":		{ pattern:/^\[n[v][vscVSA][vscVSA][vscVSA][viVN]\]$/, argNum:5 },
			"writeText":		{ pattern:/^\[n[v][vscVS][viVN][viVN][viVN][viVN][vscVSA][viVN]\]$/, argNum:8 },

			"cropImage":		{ pattern:/^\[n[v][viVN][viVN][viVN][viVN]\]$/, argNum:5 },
			"flipImage":		{ pattern:/^\[n[v][viVN]\]$/, 				argNum:2 },
			"resizeImage":		{ pattern:/^\[n[v][viVN][viVN]\]$/, 		argNum:3 },
			"resizeResampling":	{ pattern:/^\[n[v][viVN][viVN]\]$/, 		argNum:3 }, // ???
			"rotateImage":		{ pattern:/^\[n[v][viVN][viVN]\]$/, 		argNum:3 },

			"brightness":		{ pattern:/^\[n[v][viVN]\]$/, 				argNum:2 },
			"contrast":			{ pattern:/^\[n[v][viVN]\]$/, 				argNum:2 },
			"saturation":		{ pattern:/^\[n[v][viVN]\]$/, 				argNum:2 },
			"createBlackWhite":	{ pattern:/^\[n[v]\]$/, 					argNum:1 },
			"createGrayScale":	{ pattern:/^\[n[v]\]$/, 					argNum:1 },
			"createNegative":	{ pattern:/^\[n[v]\]$/, 					argNum:1 },

			"blur":				{ pattern:/^\[n[v][viVN]\]$/, 					argNum:2 },
			"sharpen":			{ pattern:/^\[n[v][viVN]\]$/, 					argNum:2 },
			"emboss":			{ pattern:/^\[n[v]\]$/, 						argNum:1 }
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
   						
   						var brace:String = "({[".charAt(")}]".search(sourceText.charAt(fix)));
   						
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
			    			brace = ")}]".charAt("({[".search(braceStack[braceStack.length-1]));
			   											    			
			    			err = new CompilerError(null, 9005, ["'"+brace+"'"]);
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
 				
 				lexems.push(new LexemStruct(sourceText.substring(fix, i+1), type, fix, err));
 				
 				if(lexems.length>1)
 					LexemStruct(lexems[lexems.length-2]).postSpaces = spaceStack;
 				
 				spaceStack = ''; 			
 			} 					
			i++;        			        				
		} 
		
		if(braceStack.length>0 && lexems.length>0 && !lexems[lexems.length-1].error)
		{
			brace = ")}]".charAt("({[".search(braceStack[braceStack.length-1]));
			
   			lexems.push(new LexemStruct('', 'u', sourceText.length, new CompilerError(null, 9005, ["'"+brace+"'"])));				    			
		}
			
		return lexems;
		
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
		
	/*public static function sliceLexems(lexems:Array, separator:String=';'):Array
	{
		var arr:Array = [];
		var fix:int = 0;
		
		for(var i:int=0; i<lexems.length; i++)
		{
			if(lexems[i].type==separator)
			{
				if(fix<i)					
					arr.push(lexems.slice(fix, i));
				fix = i+1;
			}
		}
		
		// push rest of lexems
		if(fix<i)
			arr.push(lexems.slice(fix, i));
													
		return arr;
	}*/
		
	/*public static function convertLexemArray(lexems:Array):Array
	{
		var converted:Array = lexems.concat();
		
		for(var i:int=0; i<converted.length; i++)
		{
			switch(converted[i].type)
			{
				case "t": // replace special characters from texts
					converted[i].value = Utils.replaceEscapeSequences(converted[i].value, "\\r");
					converted[i].value = Utils.replaceEscapeSequences(converted[i].value, "\\n");
					converted[i].value = Utils.replaceEscapeSequences(converted[i].value, "\\t");
					converted[i].value = Utils.replaceEscapeSequences(converted[i].value, "\\$");
					converted[i].value = Utils.replaceEscapeSequences(converted[i].value, "\\\\");
					break;
				case "v": // convert variable names to as3 compatible names
					converted[i].value = String(converted[i].value).substring(1);
					break;
			}
		}
		return converted;
	}*/
	
	/*public static function processLexemArray(lexems:Array):void
	{			
		processOperationGroups(lexems);
	}*/
	
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
			
			if(curFragment.postSpaces)
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
					block.fragments.push(recursiveFragmentLexems(null, "F", block));
					break;	
				
				case 'code':
					block.fragments.push(recursiveFragmentLexems(";", "F", block));
					break;
			}
			index++;
		}
		
		return block;
		
		function recursiveFragmentLexems(_terminal:String, _ftype:String, _parent:Object):CodeFragment {
			var _fragment:CodeFragment = new CodeFragment(_ftype);
			_fragment.parent = _parent; 
			
			if(_terminal!=';')
			{
				_fragment.fragments.push(block.lexems[index]);
				index++;
			}
				
			while(index<block.lexems.length && block.lexems[index].type!=_terminal)
			{
				if(((codeType=='code' || _fragment.parent is CodeFragment) && "[{9".search(block.lexems[index].type)>=0) ||
					(codeType=='text' && "{".search(block.lexems[index].type)>=0))
				{
					var _subfragment:CodeFragment = recursiveFragmentLexems(
							"]}0".charAt("[{9".search(block.lexems[index].type)), 
							"AWE".charAt("[{9".search(block.lexems[index].type)),
							_fragment);
					_fragment.fragments.push(_subfragment);
				}
				else
					_fragment.fragments.push(block.lexems[index]);
					
				index++;
			}
			
			if(_terminal && block.lexems[index].type==_terminal)
				_fragment.fragments.push(block.lexems[index]);

			return _fragment;
		}
	}

	public static function validateTextFragment(fragment:CodeFragment):void
	{
		var lexemObj:Object;
		var strSentence:String = "";
		
		for each(var subfragment:Object in fragment.fragments)
		{
			if(subfragment is CodeFragment)
				validateCodeFragment(subfragment as CodeFragment);
		}
		
		if(fragment.errFragment)
			return; 
		
		fragment.validated = true;

		// start validate current fragment
		
		for(var i:int=0; i<fragment.fragments.length; i++)
			strSentence = strSentence + LexemStruct(fragment.fragments[i]).type;		
		
		lexemObj = isValidText(strSentence);
		if(!lexemObj.result)
		{
			fragment.error = new CompilerError(null, 9000);
			return;
		}
		
		fragment.ctype = CT_TEXT;		
		fragment.print = true;
	}
	
	public static function isFunctionExist(funcName:String):Boolean
	{
		var typeDescr:XML = describeType(TemplateStruct.lib);
		var funcDescr:XMLList = typeDescr..method.(@name == funcName);
		
		return (funcDescr.length()>0);
	}	
	
	public static function validateCodeFragment(fragment:CodeFragment):void
	{
		var lexemObj:Object;
		var strSentence:String = "";
		
		for each(var subfragment:Object in fragment.fragments)
		{
			if(subfragment is CodeFragment)
				validateCodeFragment(subfragment as CodeFragment);
		}
		
		if(fragment.errFragment)
			return; 
		
		fragment.validated = true;

		// start validate current fragment
		
		for(var i:int=0; i<fragment.fragments.length; i++)
			strSentence = strSentence + LexemStruct(fragment.fragments[i]).type;		
		
		strSentence = rollUpSeparator(strSentence);
		
		// check for operation
		lexemObj = isValidOperation(strSentence);
		if(lexemObj.result && lexemObj.strSentence.length==1)
		{
			if(fragment.isTopLevel)
				fragment.print = true;

			fragment.type = lexemObj.strSentence;
			fragment.ctype = CT_OPERATION;
			return;
		}
		
		lexemObj = isValidAdvVar(lexemObj.strSentence);
		
		// check for test
		lexemObj = isValidTest(lexemObj.strSentence);
		if(lexemObj.result && lexemObj.strSentence.length==1)
		{
			if(fragment.isTopLevel)
				fragment.trans = ["true", "false"];
				
			fragment.type = lexemObj.strSentence;
			fragment.ctype = CT_TEST;
			return;
		}
		
		// rollup function
		var argNum:int = lexemObj.strSentence.indexOf("]")-strSentence.indexOf("[")-2;
		lexemObj = isValidFunction(lexemObj.strSentence);
		if(lexemObj.result && lexemObj.strSentence.length==1 && isFunctionExist(fragment.fragments[0]))
		{
			if(fragment.isTopLevel)
				fragment.print = true;
			
			fragment.type = lexemObj.strSentence;
			
			fragment.funcName = fragment.fragments[0];				
			fragment.ctype = CT_FUNCTION;
			
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
				if(!RegExp(funcDef.pattern).test(lexemObj.strSentence))
				{
					fragment.error = new CompilerError(null, 9011);
					return;
				}
				
				fragment.trans = funcDef.trans;
			}
			return;
		}
		
		// rollup list
		lexemObj = isValidList(lexemObj.strSentence);
		if(lexemObj.result && lexemObj.strSentence.length==1)
		{
			if(fragment.isTopLevel)
				fragment.print = true;
				
			fragment.ctype = CT_LIST;							
			fragment.type = lexemObj.strSentence;
			return;			
		}
				
		lexemObj = isValidAssign(lexemObj.strSentence);
		if(lexemObj.result)
		{
			fragment.ctype = CT_ASSIGN;
			return;
		}
		
		fragment.error = new CompilerError(null, 9000);
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
		block.validated = true;
		
		if(block.errFragment)
			return;
	}	
	
	/**
	 * resolve advanced variable definition technique
	 *  
	 * @param lexems
	 * @param context
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			array: Array - processed lexem array
	 * 
	 */
	/*public static function processConvertedLexemArray(lexems:Array, contexts:Array):Object
	{
		var arr:Array = lexems.concat();
		var retVal:Object = {	result:false, 
								error:null, 
								array:null };
		
		var index:int = 0;
		
		while(index<arr.length)
		{
			if(arr[index].type=="{")
			{
				var variable:Object = recursiveProcessLexemsArray(arr, contexts, index);
				
				if(!variable.result) {
					return {	result:false, 
								error:variable.error, 
								array:null };
				}
					
				arr[index].type = "v";
				arr[index].value = variable.value;
				arr[index].origValue = variable.origValue;
			}
			
			index++;
		}		
		
		return {result:true, error:null, array:arr};
	}*/
	
	/**
	 * recursively resolve advanced variable definition technique
	 * 
	 * @param lexems
	 * @param context
	 * @param index
	 * @return 	result: Boolean - valid or not
	 * 			error: Error - error
	 * 			value: String - variable name 
	 * 
	 */
	/*
	private static function recursiveProcessLexemsArray(lexems:Array, contexts:Array, index:int):Object
	{
		var arrColLexems:ArrayCollection = new ArrayCollection(lexems);
		var retVal:Object = { result:false, error:null, value:null, origValue:null };

		var code:String = "";
		var origBuf:String = "";
		var result:Object;
		var strLexem:String = "";
		
		origBuf += lexems[index].origValue;
		
		// remove '{'
		arrColLexems.removeItemAt(index);
		
		while(index<arrColLexems.length && lexems[index].type!="}")
		{
			result = null;
			
			// search for allowable lexem
			if(String(lexems[index].type).search(/[scvif90123{]/)<0)
				return { 	result:false,
							error:new RunTimeError(null, 9002, [lexems[index].value]), 
							value:null };
			
			// get variable value
			if(String(lexems[index].type).search(/v/)>=0 && contexts)
			{
				var value:Object = null;
				 
				for(var j:int=contexts.length-1; j>=0; j--)
				{
					var context:Object = contexts[j];
					
        			if(context.hasOwnProperty(lexems[index].value))
        			{
						value = context[lexems[index].value];        				
	        			break;
	        		}
	        	}					
				
				if(value==null)
					return {	result:false,
								error:new RunTimeError(null, 9008, [lexems[index].value]), 
								value:null };
			}					
			
			if(lexems[index].type=="{")
			{
				result = recursiveProcessLexemsArray(lexems, contexts, index);
				
				if(!result.result)
					return result;
				
				origBuf += result.origValue;
				code += result.value;
				strLexem += "v";
			}
			else
			{
				var srtVal:String;
				
				if(value)
					srtVal = (value is String) ? Utils.quotes(value.toString()) : value.toString();
				
				origBuf += lexems[index].origValue;					 				
				code += (value!=null ? srtVal : lexems[index].value);
				strLexem += lexems[index].type;
			}
			
			arrColLexems.removeItemAt(index);
		}
		
		// '}' not found 
		if(index>=arrColLexems.length)
			return {	result:false,
						error:new RunTimeError(null, 9005, ["'}'"]), 
						value:null };
		
		if(index<arrColLexems.length)
			origBuf += lexems[index].origValue;	
		
		if(!isValidOperation(strLexem).result)
			return {	result:false,
						error:new RunTimeError(null, 9001), 
						value:null };
		
		retVal.result = true;
		retVal.error = null;
		retVal.value = contexts ? eval(code, contexts).toString() : null;
		retVal.origValue = origBuf;
		
		return retVal;
	}
	*/

	public static function eval(prog:String, contexts:Array=null):*
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
		var len:int;
		var prevLen:int;
		var index:int = 0;
		var strSentence:String = lexemString.concat();
		
		// parse operations
		do {
			len = strSentence.length;
			index = 0;
			
			do {
				prevLen = strSentence.length;
				
				strSentence = strSentence.replace(patterns[index][0], patterns[index][1]);
				
				if(prevLen == strSentence.length)
					index++;				
			} while (index<patterns.length && strSentence.length);
			
		} while	(len!=strSentence.length && strSentence.length)
		
		return strSentence;
	}
	
	public static function rollUpSigns(lexemString:String):String
	{
		var strSentence:String = lexemString.concat();
		var patterns:Array = 
			[
				[/(^|=|4|5|9|n|\[|\])[23](v|i|f|F|A|W|E)/g, 	"$1$2"],	// remove signs '-1...', '...=+2...', '...(-3...'
			];     			

		strSentence = rollLexemString(strSentence, patterns);
		
		return strSentence;
	}
	
	public static function rollUpSeparator(lexemString:String):String
	{
		var strSentence:String = lexemString.concat();
		var patterns:Array = 
			[
				[/^(.*)(;)+$/g, "$1"]
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
				[/9(O|L|b)0/g, 							"$1"]	
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
				[/[Wv]+/g, 				""],	// roll up vars
				[/t+/g, 				"t"]	// roll up text
			]
		;     			

		strSentence = rollLexemString(strSentence, patterns);

		if(strSentence=="t")
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}	
	//--------------------------------------------------------------------------
    //
    //  
    //
    //--------------------------------------------------------------------------
    
    /*
	public static function isFunctionExists(lexems:Array):Object
	{			
		var pattern:RegExp;
		var retVal:Object = {result:false, error:null, value:null, variable:null, func:null};
		
		if(lexems[0].operationGroup==0)
			processLexemArray(lexems);   			
		
		var strSentence:String = "";    
		for(var i:int=0; i<lexems.length; i++)
			strSentence = strSentence + lexems[i].type;
				
		strSentence = isValidOperation(strSentence).value;						
		
		// remove []
		var strSubSentence:String = strSentence.substring(
										strSentence.indexOf('[')+1, 
										strSentence.lastIndexOf(']')); 
		
		// pack all lists in one lexem
		strSubSentence = isValidList(strSubSentence).value;
		
		// add []
		strSentence = strSentence.substring(0, strSentence.indexOf('[')+1) +
					  strSubSentence +
					  strSentence.substring(strSentence.lastIndexOf(']'));
		
		// search for '[' index in lexem array
		for(var sIndex:int=0; sIndex<lexems.length; sIndex++)
			if(lexems[sIndex].type=='[')
				break;

		// search for ']' index in lexem array
		for(var eIndex:int=lexems.length-1; eIndex>sIndex; eIndex--)
			if(lexems[eIndex].type==']')
				break;
				
		// search for variable index in lexem array
		for(var vIndex:int=0; vIndex<lexems.length; vIndex++)
		{
			if(lexems[vIndex].type=='=')
			{
				vIndex--;
				break;
			}
		}
		
		// get function name
		retVal.func = lexems[sIndex+1].value;
		var argNum:int = strSentence.indexOf("]")-strSentence.indexOf("[")-2;
							
		//if(funcDefinition.hasOwnProperty(retVal.func))
		{
			var def:Object = funcDefinition[retVal.func];
			
			// check for correct args number
			if(def && argNum != def.argNum && def.argNum>=0)
			{
				retVal.error = new CompilerError(null, 9007, [def.argNum]);
				return retVal;
			}
			else if(def && def.argNum<0 && argNum < Math.abs(def.argNum))
			{
				retVal.error = new CompilerError(null, 9007, [">"+Math.abs(def.argNum)]);
				return retVal;
			} 
		
			if(	def && RegExp(def.pattern).test(strSentence) || !def)
			{
				retVal.result = true;
				
				retVal.value = "";						
				
				for(i=sIndex+2; i<lexems.length && i<eIndex; i++)
					retVal.value += (lexems[i-1].operationGroup!=lexems[i].operationGroup && 
										lexems[i-1].type!='[' && 
										lexems[i].type!=']' && 
										retVal.value.length ? "," : "") +									
									(lexems[i].type=='n' ? "{type:'n', value:"+Utils.quotes(lexems[i].value)+"}" : 
										lexems[i].type=='A'? Utils.quotes(lexems[i].value) : lexems[i].value);
				
				retVal.value = TemplateStruct.CNTXT_INSTANCE + "." + 
					retVal.func + "(" + String(retVal.value) + ")";
			}
		}
		
		if(retVal.result)
		{
			if(/^v=/.test(strSentence))
			{
				retVal.variable = lexems[vIndex].value;
				retVal.value = retVal.variable + "=" + retVal.value;
			}
		}
		else if(retVal.func && !retVal.value)
		{
			retVal.error = new CompilerError(null, 9011);
		}
		else if(!retVal.value)
		{
			retVal.error = new CompilerError(null, 9009, [lexems[sIndex+1].value]);
		}
		
		return retVal;
	}
	*/
	/**
	 * pack all lists into string on given depth
	 *  
	 * @param lexems
	 * @param depth
	 * @return 
	 * 
	 */
	 /*
	public static function packLists(lexems:Array, depth:int=1):Object
	{
		var retVal:Object = { result:false, error:null, array:null };
		
		var arr:Array = lexems.concat();
		var arrColLexems:ArrayCollection = new ArrayCollection(arr);
		
		var index:int = 0;
		var curDepth:int = 0;
		var fix:int = -1;
		
		while(index<arr.length)
		{
			if(arr[index].type=="[")
				curDepth++;
			else if(arr[index].type=="]")
				curDepth--;
			
			if(fix>=0)
			{
				var ws:String = ''; 
				var wsCount:int = 0;
				
				wsCount = LexemStruct(arr[index]).position - 
					(LexemStruct(arr[fix]).position + LexemStruct(arr[fix]).origValue.length); 
				
				while(wsCount>0) {
					ws += ' ';
					wsCount--;
				}
								
				arr[fix].origValue += ws + arr[index].origValue;					
				arr[fix].value += ws + arr[index].value;
				arrColLexems.removeItemAt(index);
				index--;
			}

			if(curDepth>depth && fix<0)
			{
				fix = index;
				arr[fix].type = "A";
			}
			else if(curDepth<=depth && fix>=0)
			{
				fix=-1;
			}
			
			index++;
		}
		
		if(curDepth!=0)
		{
			retVal.result = false;
			retVal.error = new CompilerError(null, 9000);
			return retVal;
		}
						
		retVal.result = true;
		retVal.array = arr;	
		return retVal;			
	}
	*/
	
	/*
	public static function processLexemsLists(lexems:Array):Array
	{
		var arr:Array = [];		
		var braceStack:Array = [];
		var braceList:Array = [];
		var j:int;
		
		for (var i:int=0; i<lexems.length; i++)
		{
			var lexem:LexemStruct = lexems[i] as LexemStruct;			
			
			if(lexem.type=='{')
			{
				for (j=i; j<lexems.length; j++)
				{
					if(lexems[j].type=='{')
						braceStack.push(lexems[j].type);
					else if(lexems[j].type=='}')
						braceStack.pop();
					
					arr.push(lexems[j]);
					
					if(braceStack.length==0)
						break;
				}				
				i=j;
				continue;
			}
			else if(lexem.type=='[' || lexem.type==']')
			{
				if(lexem.type=='[')
					braceList.push(lexem.type);
				else if(lexem.type==']' && braceList.length)
					braceList.pop();
					
				arr.push(lexem);
				
				continue;
			}						
			else if(lexem.type != 's' && lexem.type != 'c' && 
				lexem.type != '{' && lexem.type != 'v' &&
				lexem.type != '[' && lexem.type != ']' && braceList.length)
			{
				var value:String = lexem.origValue;
					
				for (j=i+1; j<lexems.length; j++)
				{
					if(	lexems[j].type == ']' || 
						lexems[j].position > lexems[j-1].position + lexems[j-1].origValue.length )
						break;
					
					value += lexems[j].origValue;
				}
				
				arr.push(new LexemStruct(value, 'w', lexem.position, null));
				
				i = j-1;
			}
			else
			{
				arr.push(lexem);			
			}
		}
				
		return arr;
	}
	*/
		
	/**
	 * convert list-string into array
	 *  
	 * @param list
	 * @return 
	 * 
	 */
	 
	/*
	public static function processList(list:String):Object
	{
		var retVal:Object = {result:false, error:null, value:null, array:null};
					
		var lexems:Array = getLexemArray(list);
		lexems = processLexemsLists(lexems);
		
		// pack lists
    	var lexemObj:Object = packLists(lexems);
    	if(!lexemObj.result)
    	{
    		retVal.result = lexemObj.result;
			retVal.error = lexemObj.error;
			return retVal;
    	}	
    	lexems = lexemObj.array;
		
		processLexemArray(lexems);
		lexems = convertLexemArray(lexems);
		
		// pack variables
    	lexemObj = processConvertedLexemArray(lexems, null);
    	if(!lexemObj.result)
    	{
    		retVal.result = lexemObj.result;
			retVal.error = lexemObj.error;
			return retVal;
    	}    	
    	lexems = lexemObj.array;
    				
    	var strSentence:String = "";
		for(var i:int=0; i<lexems.length; i++)
			strSentence = strSentence + lexems[i].type;				
    	
    	retVal.result = isValidList(strSentence).result;
    	retVal.value = strSentence;
   		retVal.array = lexems;

		return retVal;
	}
	*/
	
}
}