package PowerPack.com.gen.parse
{
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.gen.TemplateStruct;
import PowerPack.com.gen.errorClasses.CompilerError;
import PowerPack.com.gen.errorClasses.RunTimeError;
import PowerPack.com.gen.parse.parseClasses.LexemStruct;

import mx.collections.ArrayCollection;
import mx.utils.UIDUtil;

import r1.deval.D;

public class Parser
{		
	public static var funcDefinition:Object =
		{			
			/**
			* [ function_pattern, function_name, args_num ] 
			*/
								
			'sub':			{ pattern:/^(v=){0,1}\[nn[nobvscifVNS]*\]$/, argNum:-1 },
			'subPrefix':	{ pattern:/^(v=){0,1}\[nnn[nobvscifVNS]*\]$/, argNum:-2 },
			'question':		{ pattern:/^(v=){0,1}\[n[vscVS][vscVS]\]$/, argNum:2 },
			'convert':		{ pattern:/^(v=){0,1}\[n[vscVS][vsciVNS]\]$/, argNum:2 },
			'loadDataFrom':	{ pattern:/^(v=){0,1}\[n[vscVS]\]$/, argNum:1 },
			'writeTo':		{ pattern:/^(v=){0,1}\[n[vscVS]\]$/, argNum:1 },
			'writeVarTo':	{ pattern:/^(v=){0,1}\[n[vscVS][vscifVNS]\]$/, argNum:2 },
			'GUID':			{ pattern:/^(v=){0,1}\[n\]$/, argNum:0 },
			"mid":			{ pattern:/^(v=){0,1}\[n[viVN][viVN][vscVS]\]$/, argNum:3 },
			"replace":		{ pattern:/^(v=){0,1}\[n[vscVS][vscVS][vscVS][vscVS]\]$/, argNum:4 },
			"split":		{ pattern:/^(v=){0,1}\[n[vscVS][vscVS]\]$/, argNum:2 },
			"random":		{ pattern:/^(v=){0,1}\[n[viVN]\]$/, argNum:1 },
			"imageToBase64":{ pattern:/^(v=)?\[n[v][vscVS]\]$/, argNum:2 },
			
			//*********************
			// List manipulation
			//*********************
			
			"length":		{ pattern:/^(v=){0,1}\[n[vscVSA]\]$/, argNum:1 },
			"get":			{ pattern:/^(v=){0,1}\[n[nviscVNS][vscVSA]\]$/, argNum:2 },
			"put":			{ pattern:/^(v=){0,1}\[n[nviscVNS][nviscVNS][nobvscifVNS][vscVSA]\]$/, argNum:4 },
			"update":		{ pattern:/^(v=){0,1}\[n[nviscVNS][nviscVNS][nobvscifVNS][vscVSA]\]$/, argNum:4 },
			"delete":		{ pattern:/^(v=){0,1}\[n[nviscVNS][vscVSA]\]$/, argNum:2 },
			"getType":		{ pattern:/^(v=){0,1}\[n[nviscVNS][vscVSA]\]$/, argNum:2 },
			"exist":		{ pattern:/^(v=){0,1}\[n[nviscVNS][nobvscifVNS][vscVSA]\]$/, argNum:3 },
			"evaluate":		{ pattern:/^(v=){0,1}\[n[vscVSA]\]$/, argNum:1 },
			"execute":		{ pattern:/^(v=){0,1}\[n[vscVSA]\]$/, argNum:1 },
							
			"addStructure":		{ pattern:/^(v=){0,1}\[n[nvscVSA][nvscVSA][viVN][vscVSA]\]$/, argNum:4 },
			"updateStructure":	{ pattern:/^(v=){0,1}\[n[nvscVSA][nvscVSA][viVN][vscVSA]\]$/, argNum:4 },
			"deleteStructure":	{ pattern:/^(v=){0,1}\[n[nvscVSA][nvscVSA][viVN][vscVSA]\]$/, argNum:4 },

			//*********************
			// Graphic functions
			//*********************

			"loadImage":	{ pattern:/^(v=)?\[n[vscVS]\]$/, argNum:1 },
			"createImage":	{ pattern:/^(v=)?\[n[viVN][viVN][viVN]\]$/, argNum:3 },
			"getWidth":		{ pattern:/^(v=)?\[n[v]\]$/, argNum:1 },
			"getHeight":	{ pattern:/^(v=)?\[n[v]\]$/, argNum:1 },
			"getPixel":		{ pattern:/^(v=)?\[n[v][viVN][viVN]\]$/, argNum:3 },
			"getPixel32":	{ pattern:/^(v=)?\[n[v][viVN][viVN]\]$/, argNum:3 },
			"setPixel":		{ pattern:/^(v=)?\[n[v][viVN][viVN][viVN]\]$/, argNum:4 },
			"getImage":		{ pattern:/^(v=)?\[n[viVN][vscVS]\]$/, argNum:2 }, // ???
			
			"addImage":		{ pattern:/^(v=)?\[n[v]{1,2}[viVN][viVN][viVN][viVN]\]$/, argNum:-5 },
			"mergeImages":	{ pattern:/^(v=)?\[n[v][v][viVN]\]$/, argNum:3 },
			
			"drawLine":		{ pattern:/^(v=)?\[n[v][viVN][viVN][viVN][viVN][vscVSA][viVN]\]$/, argNum:7 },
			"drawPolygon":	{ pattern:/^(v=)?\[n[v][vscVSA][vscVSA][vscVSA][viVN]\]$/, argNum:5 },
			"drawAngleArc":	{ pattern:/^(v=)?\[n[v][viVN][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:9 },
			"drawEllipse":	{ pattern:/^(v=)?\[n[v][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:8 },
			"drawRect":		{ pattern:/^(v=)?\[n[v][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:8 },
			"drawRoundRect":{ pattern:/^(v=)?\[n[v][viVN][viVN][viVN][viVN][viVN][vscVSA][vscVSA][viVN]\]$/, argNum:9 },
			"drawBezier":	{ pattern:/^(v=)?\[n[v][vscVSA][vscVSA][viVN]\]$/, argNum:4 },
			"fillBezier":	{ pattern:/^(v=)?\[n[v][vscVSA][vscVSA][vscVSA][viVN]\]$/, argNum:5 },
			"writeText":	{ pattern:/^(v=)?\[n[v][vscVS][viVN][viVN][viVN][viVN][vscVSA][viVN]\]$/, argNum:8 },

			"cropImage":		{ pattern:/^(v=)?\[n[v][viVN][viVN][viVN][viVN]\]$/, argNum:5 },
			"flipImage":		{ pattern:/^(v=)?\[n[v][viVN]\]$/, argNum:2 },
			"resizeImage":		{ pattern:/^(v=)?\[n[v][viVN][viVN]\]$/, argNum:3 },
			"resizeResampling":	{ pattern:/^(v=)?\[n[v][viVN][viVN]\]$/, argNum:3 }, // ???
			"rotateImage":		{ pattern:/^(v=)?\[n[v][viVN][viVN]\]$/, argNum:3 },

			"brightness":		{ pattern:/^(v=)?\[n[v][viVN]\]$/, argNum:2 },
			"contrast":			{ pattern:/^(v=)?\[n[v][viVN]\]$/, argNum:2 },
			"saturation":		{ pattern:/^(v=)?\[n[v][viVN]\]$/, argNum:2 },
			"createBlackWhite":	{ pattern:/^(v=)?\[n[v]\]$/, argNum:1 },
			"createGrayScale":	{ pattern:/^(v=)?\[n[v]\]$/, argNum:1 },
			"createNegative":	{ pattern:/^(v=)?\[n[v]\]$/, argNum:1 },

			"blur":			{ pattern:/^(v=)?\[n[v][viVN]\]$/, argNum:2 },
			"sharpen":		{ pattern:/^(v=)?\[n[v][viVN]\]$/, argNum:2 },
			"emboss":		{ pattern:/^(v=)?\[n[v]\]$/, argNum:1 }
		};		
	
	public static function getLexemArray(sourceText:String, isCode:Boolean=true):Array
	{
   		var lexems:Array = new Array();
   		    		
		/**
		 * LEXEM TYPES: utnwobvscif12345=90{}[];VNSALO    		  
		 * u - undefined
		 * t - text
		 * n - name (identifier: function name, graph name, prefix, etc)
		 * w - word (any ASCII chars sequence without spaces)
		 * o - 'null'
		 * b - ('true', 'false')
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
		 */
    		 
		var i:int=0; 		// iterator
		var j:int; 			// secondary iterator
		var fix:int; 		// current string position
		var type:String; 	// lexem type
		var err:Error;		// error
		var bPush:Boolean;	// add or not sequence to lexems array
		var braceStack:Array=[];
		
		while(i<sourceText.length)
		{
			fix=i;
			type='u'; // undefined
			err=null;
			bPush=true;
			
			if(braceStack.length==0 && !isCode)
			{
    			type='t';
    			switch(sourceText.charAt(fix))
				{
					case '$': // variable
    					if(i+1>=sourceText.length)
    						break;
    					
    					j = i-1;
    					while(j>=0 && sourceText.charAt(j)=="\\")
    						j--;
    					
    					if((i-j-1)%2==1)
    						break;

    					if(sourceText.charAt(i+1)=='{') //advanced variable
    					{	
    						i++;
    						type = '{';
    						braceStack.push('{');
    						break;        					
    					}
    					
    					if(sourceText.charAt(i+1).search(/[^_a-z]/i)>=0)
    					{
    						err = new CompilerError(null, 9001);
    						break;
    					}
    					
    					do {
    						i++;
    						if(i>=sourceText.length)
    							break;
    					} while(sourceText.charAt(i).search(/[_a-z0-9]/i)>=0);							
						i--;
   						type = 'v'; // variable*/
    					break;

    				default:
						do {
    						i++;
    						if(i>=sourceText.length)
    							break;
    					} while(sourceText.charAt(i)!="$");        						
						i--;
						break;
				}
			}
			else
			{  
				type='u';
    			switch(sourceText.charAt(fix))
    			{
    				case '"':
    				case "'":
						do {
    						i++;
    						if(i>=sourceText.length)
    							break;
    						
    						if(sourceText.charAt(i)==sourceText.charAt(fix))
    						{
    							j = i-1;
								while(j>=0 && sourceText.charAt(j)=="\\")	    						
									j--;
				
								if((i-j)%2==1) 
	    							break;
    						}    						
    					} while( true );        						
						
    					if(i<sourceText.length)
    						type = (sourceText.charAt(fix)=='"' ? 's' : 'c');
    					else
    						err = new CompilerError(null, 9006);
    					
    					break;

    				case '$': // variable
    					if(i+1>=sourceText.length) 
    					{
    						err = new CompilerError(null, 9001);
    						break;
    					}

    					if(sourceText.charAt(i+1)=='{') //advanced variable
    					{	
    						i++;
    						type = '{';
    						braceStack.push('{');
    						break;        					
    					}
    					
    					if(sourceText.charAt(i+1).search(/[^_a-z]/i)>=0)
    					{
    						err = new CompilerError(null, 9001);
    						break;
    					}
    					
    					do {
    						i++;
    						if(i>=sourceText.length)
    							break;
    					} while(sourceText.charAt(i).search(/[_a-z0-9]/i)>=0);							
						i--;
   						type = 'v'; // variable
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
   						var brace:String = 	sourceText.charAt(fix)==')'?'(':
   												sourceText.charAt(fix)=='}'?'{':
   													sourceText.charAt(fix)==']'?'[':'';
   						
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
			    		if(braceStack.length>0)
			    		{
			   				brace =	braceStack[braceStack.length-1]=='('?')':
			   							braceStack[braceStack.length-1]=='{'?'}':
			   								braceStack[braceStack.length-1]=='['?']':'';
			   											    			
			    			err = new CompilerError(null, 9005, ["'"+brace+"'"]);
			    		}	   						
    					break;	
    					
    				default: 
    					if(i+2<sourceText.length && sourceText.substr(i,3).search(/0x[0-9a-f]/i)>=0) // hex
    					{
    						i=i+2;    						
    						do {
    							i++;
	    						if(i>=sourceText.length)
        							break;       							
    						} while(sourceText.charAt(i).search(/[0-9a-f]/i)>=0);
    						i--;
    						type = 'i'; // hex integer constant    						
    					}
    					else if(sourceText.charAt(i).search(/\d/)>=0) // digit
    					{
    						do {
    							i++;
	    						if(i>=sourceText.length)
        							break;       							
    						} while(sourceText.charAt(i).search(/\d/)>=0);
    						i--;
    						type = 'i'; // integer constant

       						if(i+2>=sourceText.length)
    							break;
    							       						
    						if(sourceText.charAt(i+1)=='.' && sourceText.charAt(i+2).search(/\d/)>=0)
    						{
    							i++;
    							do {
    								i++;	
		    						if(i>=sourceText.length)
	        							break;         								
    							} while(sourceText.charAt(i).search(/\d/)>=0);
    							i--;   
    							type = 'f'; // float constant    						
    						}        						
    						break;
    					}
    					else if(sourceText.charAt(i).search(/[_a-z]/i)>=0) // name or (null, true, false)
    					{
    						do {
    							i++;
    							if(i>=sourceText.length)
    								break;
    						} while(sourceText.charAt(i).search(/[_a-z0-9]/i)>=0);
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
        					bPush=false;        				        					
        					break;        					
        				}	        				
    			}			
			}
			
			if(i>=sourceText.length)
				i=sourceText.length-1;
			
			if(bPush)
			{
				if(type=='u' && !err)
					err = new CompilerError(null, 9002, ["("+sourceText.substring(fix, i+1)+")"]);
 				
 				lexems.push(new LexemStruct(sourceText.substring(fix, i+1), type, fix, err));
 			} 					
			i++;        			        				
		} 
		
		if(braceStack.length>0 && lexems.length>0 && !lexems[lexems.length-1].error)
		{
   			brace =	braceStack[braceStack.length-1]=='('?')':
   						braceStack[braceStack.length-1]=='{'?'}':
   							braceStack[braceStack.length-1]=='['?']':'';
   			
   			lexems.push(new LexemStruct('', 'u', sourceText.length, new CompilerError(null, 9005, ["'"+brace+"'"])));				    			
		}
			
		return lexems;  
	}
	
	public static function convertLexemArray(lexems:Array):Array
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
	}
		
	public static function sliceLexems(lexems:Array, lexemType:String=';'):Array
	{
		var arr:Array = [];
		var fix:int = 0;
		
		for(var i:int=0; i<lexems.length; i++)
		{
			if(lexems[i].type==lexemType)
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
	}

	public static function processLexemArray(lexems:Array):void
	{			
		processOperationGroups(lexems);
	}
	
	/**
	 * Divide lexem array into operation groups
	 * 
	 * @param lexems
	 * @return 
	 * 
	 */
	public static function processOperationGroups(lexems:Array):void
	{			
		var checkNext:Boolean = false;
		
		lexems[0].operationGroup = 1;
		lexems[0].listGroup = 1;

		for(var i:int=0; i<lexems.length; i++)
		{
			if(checkNext)
			{
				if(i>0)
					lexems[i].operationGroup = lexems[i-1].operationGroup;
				checkNext = false;
			}
							
			if(lexems[i].operationGroup==0 && i>0)
				lexems[i].operationGroup = lexems[i-1].operationGroup+1;
							
			switch(lexems[i].type)
			{
				case '2':	// -
					if(i>0 && lexems[i-1].type.search(/[vif90}]/g)>=0)
						lexems[i].operationGroup = lexems[i-1].operationGroup;
					checkNext = true;
					break;						
				case '3':	// +					
					if(i>0 && lexems[i-1].type.search(/[vifsc90}]/g)>=0)
						lexems[i].operationGroup = lexems[i-1].operationGroup;
					checkNext = true;
					break;						
				case '1':	// /,%,*
					checkNext = true;
				case '0':	// )
				case '}':	// }
					if(i>0)			
						lexems[i].operationGroup = lexems[i-1].operationGroup;
					break;
				case '{':	// ${
				case '9':	// (
					checkNext = true;
					break;
			}			
		}
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
	public static function processConvertedLexemArray(lexems:Array, contexts:Array):Object
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
	}
	
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
		
		D.eval(_prog, _contexts[0], _contexts[contexts.length-1]);
		
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
	
	public static function isValidOperation(lexemString:String):Object
	{
		var strSentence:String = lexemString.concat();  
		var patterns:Array = 
			[
				[/(^|=|4|5|9|n|\[|\])[23](v|i|f)/g, 	"$1$2"],	// remove signs '-1...', '...=-2...', '...(-3...'
				[/[VNvifo]1[VNvifo]/g, 		"N"],		// (*, /, %)
				[/[VNvifo]2[VNvifo]/g, 		"N"],		// '-'
				[/[Nifo]3[Nifo]/g,			"N"],		// '+'					
				
				[/[Vv]3[VNvifo]/g,			"V"],		// '+'
				[/[VNvifo]3[Vv]/g,			"V"],		// '+'
				
				[/[Ssc]3[VNSvifsco]/g,		"S"],		// '+'
				[/[VNSvifsco]3[Ssc]/g,		"S"],		// '+'
				
				[/9(V|N|S|v|i|f|s|c|o)0/g,	"$1"],		// (x) -> x
				[/\{[VSvsc]\}/g, 			"v"]		// ${x} -> v
			];     			

		// parse operations
		strSentence = rollLexemString(strSentence, patterns);
		
		if(/^[VNSvifsco]$/.test(strSentence))
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}
	
	public static function isValidList(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;  
		var pattern:RegExp;

		var patterns:Array = 
			[
				[/\[[nwobvscifVNSA]*\]/g, "A"]
			];
	
		strSentence = rollLexemString(strSentence, patterns);
		
		if(strSentence=="A")
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}	
	
	public static function isValidFunction(lexemString:String):Object
	{
		var strSentence:String = isValidList(lexemString).value;  
		var pattern:RegExp;     			
	
		pattern = /^(v=)?A$/;

		if(pattern.test(strSentence))
			return {result: true, value: strSentence};	
		
		return {result: false, value: strSentence};						
	}			
	
	public static function isValidCommand(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;  
		var pattern:RegExp;     			
	
		pattern = /^v=[VNSvifscob]$/;

		if(pattern.test(strSentence))
			return {result: true, value: strSentence};
		
		return {result: false, value: strSentence};
	}
			
	public static function isValidTest(lexemString:String):Object
	{
		var strSentence:String = isValidOperation(lexemString).value;

		var patterns:Array = 
			[
				[/[VNSvifscob]4[VNSvifscob]/g, 	"O"],	// operator
				[/[OLb]5[OLb]/g, 				"L"],	// logical operator
				[/9(O|L|b)0/g, 					"$1"]	
			]
		;     			

		// parse operations
		strSentence = rollLexemString(strSentence, patterns);

		if(strSentence=="O" || strSentence=="L" || strSentence=="b")
			return {result: true, value: strSentence};	
		
		return {result: false, value: strSentence};						
	}

	//--------------------------------------------------------------------------
    //
    //  
    //
    //--------------------------------------------------------------------------
    	
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
		
		if(funcDefinition.hasOwnProperty(lexems[sIndex+1].value))
		{
			// get function name
			retVal.func = lexems[sIndex+1].value;					

			var def:Object = funcDefinition[retVal.func];
			
			// check for correct args number
			var argNum:int = strSentence.indexOf("]")-strSentence.indexOf("[")-2;
			if(argNum != def.argNum && def.argNum>=0)
			{
				retVal.error = new CompilerError(null, 9007, [def.argNum]);
				return retVal;
			}
			else if(def.argNum<0 && argNum < Math.abs(def.argNum))
			{
				retVal.error = new CompilerError(null, 9007, [">"+Math.abs(def.argNum)]);
				return retVal;
			} 
		
			if(	RegExp(def.pattern).test(strSentence) )
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
				
				//retVal.value = retVal.func + "(" + String(retVal.value) + ")";
				
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
	
	/**
	 * pack all lists into string on given depth
	 *  
	 * @param lexems
	 * @param depth
	 * @return 
	 * 
	 */
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
		
	/**
	 * convert list-string into array
	 *  
	 * @param list
	 * @return 
	 * 
	 */
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
	
}
}