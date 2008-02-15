package PowerPack.com.parse
{
	import PowerPack.com.Utils;
	import PowerPack.com.gen.Dynamic;
	
	import com.riaone.deval.D;
		
	import mx.collections.ArrayCollection;
	import PowerPack.com.gen.TemplateStruct;
	
	public class Parser
	{		
		public static function getLexemArray(code:String):Array
		{
      		// [lexem type, substring]
       		var lexem:Array = new Array();
       		    		
    		/**
    		 * lexem types:
    		 * u - undefined
    		 * n - name (function name, graph name, prefix, etc)
    		 * s - string constant (double quotes)
    		 * c - string constant (single quotes)
    		 * v - variable
    		 * i - integer constant
    		 * f - float constant
    		 * o - null
    		 * 9 - open bracer '('
    		 * 0 - close bracer ')'
    		 * 1 - operand (*, /, %)
    		 * 2 - minus '-'
    		 * 3 - operator (>, <, <=, >=, ==, !=)
    		 * 4 - plus '+'
    		 * 5 - logical operator (&&, ||)
    		 * ${ - '{'
    		 * } - '}'
    		 * [ - '['
    		 * ] - ']'
    		 * = - '='
    		 * ; - ';'
    		 */
        		 
    		var i:int = 0; 		// iterator
    		var fix:int; 		// current string position
    		var type:String; 	// lexem type
    		var push:Boolean;	// add or not sequence to lexem array
    		
    		while(i<code.length)
    		{
    			fix=i;
    			type='u'; // undefined
    			push=true;
    			
    			switch(code.charAt(i))
    			{
    				case '"':
						do {
    						i++;
    						if(i>=code.length)
    							break;
    					} while(	code.charAt(i)!='"' || 
    								(code.charAt(i-1)=='\\' && code.charAt(i)=='"') );        						
						
    					if(i<code.length)
    						type = 's'; // string constant
    					break;

    				case "'":
						do {
    						i++;
    						if(i>=code.length)
    							break;
    					} while(	code.charAt(i)!="'" || 
    								(code.charAt(i-1)=='\\' && code.charAt(i)=="'") );        						
						
    					if(i<code.length)
    						type = 'c'; // string constant
    					break;

    				case '$': // variable
    					if(i+1>=code.length)
    						break;

    					if(code.charAt(i+1).search(/\{/)>=0) //advanced variable
    					{	
    						i++;
    						type = '{';
    						break;        					
    					}
    					
    					if(code.charAt(i+1).search(/[^_a-z]/i)>=0)
    						break;
    					
    					do {
    						i++;
    						if(i>=code.length)
    							break;
    					} while(code.charAt(i).search(/[_a-z0-9]/i)>=0);							
						i--;
   						type = 'v'; // variable
    					break;
    					
    				case '}':
   						type = '}'; 
    					break;  

    				case '(':
   						type = '9'; // open bracer
    					break;        
    									
    				case ')':
   						type = '0'; // close bracer
    					break;  
    					      				
    				case '[':
   						type = '['; // [ bracer
    					break;        
    									
    				case ']':
   						type = ']'; // ] bracer
    					break;  

    				case '+':
   						type = '4'; // plus
    					break;
    					
    				case '-':
   						type = '2'; // minus
    					break;
    					
    				case '*':
    				case '/':
    				case '%':
   						type = '1'; // operand
    					break;
    					
    				case ';':
   						type = ';'; // command separator
    					break;	
    					
    				default: 
    					if(code.charAt(i).search(/\d/)>=0) // digit
    					{
    						do {
    							i++;
	    						if(i>=code.length)
        							break;       							
    						} while(code.charAt(i).search(/\d/)>=0);
    						i--;
    						type = 'i'; // integer constant

       						if(i+2>=code.length)
    							break;
    							       						
    						if(code.charAt(i+1)=='.' && code.charAt(i+2).search(/\d/)>=0)
    						{
    							i++;
    							do {
    								i++;	
		    						if(i>=code.length)
	        							break;         								
    							} while(code.charAt(i).search(/\d/)>=0);
    							i--;   
    							type = 'f'; // float constant    						
    						}        						
    						break;
    					}
    					else if(code.charAt(i).search(/[_a-z]/i)>=0) // name or (null)
    					{
    						if(code.indexOf("null", i) == i)
    						{
    							i+=3;
    							type = 'o';    							
    							break;
    						}
    						
    						do {
    							i++;
    							if(i>=code.length)
    								break;
    						} while(code.charAt(i).search(/[_a-z0-9]/i)>=0);
							i--;
       						type = 'n'; // name
       						break;
    					}
    					else if(code.charAt(i).search(/[=!<>\|&]/)>=0) // any operator or '='
    					{
    						if(code.charAt(i).search(/=/)>=0)
    						{
        						type = '='; // '='
    						}        						
    						else if(code.charAt(i).search(/[<>]/)>=0)
    						{
        						type = '3'; // operator
    						}

    						if(i+1<code.length)
    						{
    							if(	code.charAt(i).search(/[=!<>]/)>=0 && code.charAt(i+1).search(/=/)>=0 )
    							{
    								i++;
    								type = '3'; // operator
    							}
    							else if(
        							code.charAt(i).search(/\|/)>=0 && code.charAt(i+1).search(/\|/)>=0 ||
        							code.charAt(i).search(/&/)>=0 && code.charAt(i+1).search(/&/)>=0 )
        						{
    								i++;
    								type = '5'; // logical operator	       						
        						}
    						}        						
    						break;        						
    					}
    					else if(code.charAt(i).search(/\s/)>=0) // any white space
    					{      				
        					push=false;        				        					
        					break;        					
        				}	        				
    			}

				if(i>=code.length)
					i=code.length-1;
				
				if(push)
				{
 					lexem.push([type, code.substring(fix, i+1)]);
 				} 					
    			i++;        			        				
    		} 
    		return lexem;  
		}
		
		public static function getTextLexemArray(text:String):Array
		{
      		// [lexem type, substring]
       		var lexem:Array = new Array();
       		    		
    		/**
    		 * lexem types:
    		 * u - undefined
    		 * t - text
    		 * s - string constant (double quotes)
    		 * c - string constant (single quotes)
    		 * v - variable
    		 * i - integer constant
    		 * f - float constant
    		 * o - null
    		 * 9 - open bracer '('
    		 * 0 - close bracer ')'
    		 * 1 - operand (*, /, %)
    		 * 2 - minus '-'
    		 * 4 - plus '+'
    		 * ${ - '{'
    		 * } - '}'
    		 */
        		 
    		var i:int = 0; 				// iterator
    		var fix:int; 				// current string position
    		var type:String; 			// lexem type
    		var push:Boolean;			// add or not sequence to lexem array
    		var sCode:Array=[];			// inside code
    		
    		while(i<text.length)
    		{
    			fix=i;
    			type='t'; // text
    			push=true;
    			
    			if(sCode.length==0)
    			{
	    			switch(text.charAt(i))
    				{
    					case '$': // variable
	    					if(i+1>=text.length)
	    						break;
	    					
	    					var j:int = i-1;
	    					while(j>=0 && text.charAt(j)=="\\")
	    					{	    						
	    						j--;
	    					}
	    					
	    					if((i-j-1)%2==1)
	    						break;

	    					if(text.charAt(i+1).search(/\{/)>=0) //advanced variable
	    					{	
	    						i++;
	    						type = '{';
	    						sCode.push("");
	    						break;        					
	    					}
	    					
	    					if(text.charAt(i+1).search(/[^_a-z]/i)>=0)
	    						break;
	    					
	    					do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(text.charAt(i).search(/[_a-z0-9]/i)>=0);							
							i--;
	   						type = 'v'; // variable
	    					break;

	    				default:
							do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(text.charAt(i)!="$");        						
							i--;
    				}
    			}
				else
				{    			
	    			type='u'; // undefined

	    			switch(text.charAt(i))
	    			{
	    				case '$': // variable
	    					if(i+1>=text.length)
	    						break;
	
	    					if(text.charAt(i+1).search(/\{/)>=0) //advanced variable
	    					{	
	    						i++;
	    						type = '{';
	    						sCode.push("");
	    						break;        					
	    					}
	    					
	    					if(text.charAt(i+1).search(/[^_a-z]/i)>=0)
	    						break;
	    					
	    					do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(text.charAt(i).search(/[_a-z0-9]/i)>=0);							
							i--;
	   						type = 'v'; // variable
	    					break;
	    					
	    				case '}':
	   						type = '}'; 
	   						sCode.pop();
	    					break;  
	
	    				case '"':
							do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(	text.charAt(i)!='"' || 
	    								(text.charAt(i-1)=='\\' && text.charAt(i)=='"') );        						
							
	    					if(i<text.length)
	    						type = 's'; // string constant
	    					break;
	
	    				case "'":
							do {
	    						i++;
	    						if(i>=text.length)
	    							break;
	    					} while(	text.charAt(i)!="'" || 
	    								(text.charAt(i-1)=='\\' && text.charAt(i)=="'") );        						
							
	    					if(i<text.length)
	    						type = 'c'; // string constant
	    					break;
	
	    				case '(':
	   						type = '9'; // open bracer
	    					break;        
	    									
	    				case ')':
	   						type = '0'; // close bracer
	    					break;  
	    					      				
	    				case '+':
	   						type = '4'; // plus
	    					break;
	    					
	    				case '-':
	   						type = '2'; // minus
	    					break;
	    					
	    				case '*':
	    				case '/':
	    				case '%':
	   						type = '1'; // operand
	    					break;
	    					
	    				default: 
    						if(text.indexOf("null", i) == i)
    						{
    							i+=3;
    							type = 'o';    							
    							break;
    						}
	    					if(text.charAt(i).search(/\d/)>=0) // digit
	    					{
	    						do {
	    							i++;
		    						if(i>=text.length)
	        							break;       							
	    						} while(text.charAt(i).search(/\d/)>=0);
	    						i--;
	    						type = 'i'; // integer constant
	
	       						if(i+2>=text.length)
	    							break;
	    							       						
	    						if(text.charAt(i+1)=='.' && text.charAt(i+2).search(/\d/)>=0)
	    						{
	    							i++;
	    							do {
	    								i++;	
			    						if(i>=text.length)
		        							break;         								
	    							} while(text.charAt(i).search(/\d/)>=0);
	    							i--;   
	    							type = 'f'; // float constant    						
	    						}        						
	    						break;
	    					}
	    					else if(text.charAt(i).search(/\s/)>=0) // any white space
	    					{      				
	        					push=false;        				        					
	        					break;        					
	        				}	        				
	    			}
				}
				
				if(i>=text.length)
					i=text.length-1;
				
				if(push)
				{
 					lexem.push([type, text.substring(fix, i+1)]);
 				} 					
    			i++;        			        				
    		} 
    		return lexem;  
		}
		
		public static function convertLexemArray(lexems:Array):Array
		{
			var converted:Array = lexems.concat();
			
			for(var i:int=0; i<converted.length; i++)
			{
				switch(converted[i][0])
				{
					case "t": // replace special characters from texts						
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\r");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\n");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\t");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\$");
						converted[i][1] = Utils.replaceEscapeSequences(converted[i][1], "\\\\");
						break;
					case "v": // convert variable names to as3 compatible names
						converted[i][1] = String(converted[i][1]).substring(1);
						break;
				}
			}
			return converted;
		}
	
		public static function processConvertedLexemArray(lexems:Array, context:Dynamic):Array
		{
			var arr:Array = lexems.concat();
			
			var index:int = 0;
			
			while(index<arr.length)
			{
				if(arr[index][0]=="{")
				{
					var variable:String = recursiveProcessLexemsArray(arr, context, index);
					
					arr[index][0] = "v";
					arr[index][1] = variable;
					
					if(arr[index][1]==null)
						return null;
				}
				
				index++;
			}		
			
			return arr;
		}
		
		private static function recursiveProcessLexemsArray(lexems:Array, context:Dynamic, index:int):String
		{
			var arrCol:ArrayCollection = new ArrayCollection(lexems);
			var result:String = null;
			var code:String = "";
			var command:String;
			var strLexem:String = "";
				
			arrCol.removeItemAt(index);
			while(index<arrCol.length && lexems[index][0]!="}")
			{
				command = null;
				
				if(String(lexems[index][0]).search(/[scvif90124{]/)<0)
					return null;
				
				if(String(lexems[index][0]).search(/v/)>=0)
				{
					if(context[lexems[index][1]]==null)
						return null;	
				}				
				
				if(lexems[index][0]=="{")
				{
					command = recursiveProcessLexemsArray(lexems, context, index);
					
					if(command == null)
						return null;
					
					code += command;
					strLexem += "V";
				}
				else
				{
					code += lexems[index][1];
					strLexem += lexems[index][0]
				}
				
				arrCol.removeItemAt(index);
			}
			
			if(index>=arrCol.length)
				return null;
				
			if(!isValidOperation(strLexem).result)
				return null;
			
			result = D.eval(code, null, context).toString();
			
			return result;
		}
	
		public static function isValidOperation(lexemString:String):Object
		{
			var strSentence:String = lexemString.concat();  
			var pattern:RegExp;     			

			var prevLen:int;
			
			// parse operations
			do {
				prevLen = strSentence.length;
				
				// remove signs
				pattern = /(^|3|9|=)[24](v|i|f)/g; // '-1...', '...=-2...', '...(-3...'						
				strSentence = strSentence.replace(pattern, "$1$2");

				// split into variable
				pattern = /[Vvifo]1[Vvifo]/g; // (*, /, %)			
				strSentence = strSentence.replace(pattern, "V");
				pattern = /[Vvifo]2[Vvifo]/g; // '-'			
				strSentence = strSentence.replace(pattern, "V");  
				pattern = /[Vvifsco]4[Vvifsco]/g; // '+'				
				strSentence = strSentence.replace(pattern, "V");
				
				pattern = /9(V|v|i|f|s|c|o)0/g;						
				strSentence = strSentence.replace(pattern, "$1");	

				pattern = /\{[Vvsc]\}/g;						
				strSentence = strSentence.replace(pattern, "v");													  

			} while (prevLen != strSentence.length && strSentence.length);
			
			pattern = /^[Vvifsco]$/;

			if(pattern.test(strSentence))
				return {result: true, resultString: strSentence};
			
			return {result: false, resultString: strSentence};
		}
		
		public static function isValidCommand(lexemString:String):Object
		{
			var strSentence:String = isValidOperation(lexemString).resultString;  
			var pattern:RegExp;     			
		
			pattern = /^v=[Vvifsco](;v=[Vvifsco]){0,}$/;

			if(pattern.test(strSentence))
				return {result: true, resultString: strSentence};	
			
			return {result: false, resultString: strSentence};						
		}	
		
		public static function isValidTest(lexemString:String):Object
		{
			var strSentence:String = isValidOperation(lexemString).resultString;
			var pattern:RegExp;     			
			var prevLen:int;
		
			if(strSentence.search(/[35]/)>=0)
			{
				do {
					prevLen = strSentence.length;

					pattern = /[Vvifsco]3[Vvifsco]/g;						
					strSentence = strSentence.replace(pattern, "O"); // operator							

					pattern = /[OL]5[OL]/g;
					strSentence = strSentence.replace(pattern, "L"); // logical operator							

					pattern = /9O0/g;
					strSentence = strSentence.replace(pattern, "O");							  

					pattern = /9L0/g;
					strSentence = strSentence.replace(pattern, "L");							  
					
				} while (prevLen != strSentence.length && strSentence.length);
			}

			if(strSentence=="O" || strSentence=="L")
				return {result: true, resultString: strSentence};	
			
			return {result: false, resultString: strSentence};						
		}			
	
	}
}