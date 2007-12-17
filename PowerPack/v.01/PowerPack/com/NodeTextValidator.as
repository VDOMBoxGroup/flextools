package PowerPack.com
{
	import mx.validators.Validator;
    import mx.validators.ValidationResult;
    import PowerPack.com.graph.GraphNodeCategory;
    import PowerPack.com.graph.GraphNode;

	public class NodeTextValidator extends Validator
	{
        // Define Array for the return value of doValidation().
        private var results:Array;
		
		public function NodeTextValidator()
		{
			super();
		}
		
        // Override the doValidation() method.
        override protected function doValidation(value:Object):Array 
        {
			var str:String = value.toString();
			
			var node:GraphNode;
			
			var category:String;

            // Clear results Array.
            results = [];
			
            // Call base class doValidation().
            results = super.doValidation(value);        
            // Return if there are errors.
            if (results.length > 0)
                return results;
        	
        	if(!(this.source is GraphNode))
            {
                results.push(new ValidationResult(true, null, "invalidSource", 
                    "Not valid source object."));
                return results;
            }      
            
            node = GraphNode(this.source);
            var arrTrans:Array = [];
        	
        	category = (this.source as GraphNode).category;
       		var pattern:RegExp;
        	
        	if (category == GraphNodeCategory.NORMAL)
        	{
        		pattern = /(\$[^_a-z]|\$$)/gi;
			
				if(pattern.test(str))
            	{
                	results.push(new ValidationResult(true, null, "invalidVarName", 
                    	"Not valid variable name."));
                	return results;
            	}       
        	}
        	else if (category == GraphNodeCategory.SUBGRAPH)
        	{
	        	pattern = /[^a-z0-9_]/gi;
				if(pattern.test(str))
            	{
                	results.push(new ValidationResult(true, null, "invalidSubgraph", 
                    	"Not valid graph name."));
                	return results;
            	}
         	}
        	else if (category == GraphNodeCategory.COMMAND)
        	{        		
       			// check for test command
       			var bTestCommand:Boolean = true;
        		var lexem:Array = new Array();

        		// lexical analyzer 
        		/**
        		 * lexem types:
        		 * u - undefined
        		 * s - string constant
        		 * v - variable
        		 * i - integer constant
        		 * f - float constant
        		 * 9 - open bracer
        		 * 0 - close bracer
        		 * 1 - operand
        		 * 2 - minus
        		 * 3 - operator 
        		 * 4 - plus
        		 * 5 - logical operator
        		 * ${ - {
        		 * } - }
        		 */
        		 
        		var i:int = 0;
        		var fix:int;
        		var type:String;
        		var push:Boolean;
        		
        		while(i<str.length)
        		{
        			fix=i;
        			type='u';
        			push=true;
        			
        			switch(str.charAt(i))
        			{
        				case '"':
    						do {
        						i++;
        						if(i>=str.length)
        							break;
        					} while(	str.charAt(i)!='"' || 
        								(str.charAt(i-1)=='\\' && str.charAt(i)=='"') );        						
    						
        					if(i<str.length)
        						type = 's'; //string constant
        					break;

        				case '$':
        					if(i+1>=str.length)
        						break;

        					if(str.charAt(i+1).search(/\{/)>=0)
        					{	
        						i++;
        						type = '{';
        						break;        					
        					}
        					
        					if(str.charAt(i+1).search(/[^_a-z]/i)>=0)
        						break;
        					
        					do {
        						i++;
        						if(i>=str.length)
        							break;
        					} while(str.charAt(i).search(/[_a-z0-9]/i)>=0);							
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
        					      				
        				case '+':
       						type = '4'; // plus
        					break;
        				case '-':
       						type = '2'; // sign
        					break;
        				case '*':
        				case '/':
        				case '%':
       						type = '1'; // operand
        					break;
        				case '':
        				default: 
        					if(str.charAt(i).search(/\d/)>=0) // digit
        					{
        						do {
        							i++;
    	    						if(i>=str.length)
	        							break;       							
        						} while(str.charAt(i).search(/\d/)>=0)
        						i--;
        						type = 'i'; // integer constant

   	    						if(i+2>=str.length)
        							break;
        							       						
        						if(str.charAt(i+1)=='.' && str.charAt(i+2).search(/\d/)>=0)
        						{
        							i++;
        							do {
        								i++;	
    		    						if(i>=str.length)
		        							break;         								
        							} while(str.charAt(i).search(/\d/)>=0)
        							i--;   
        							type = 'f'; // float constant    						
        						}        						
        						break;
        					}
        					else if(str.charAt(i).search(/[=!<>\|&]/)>=0) // any operator
        					{
        						if(str.charAt(i).search(/[<>]/)>=0)
        						{
	        						type = '3'; // operator
        						}
        						
        						if(i+1<str.length)
        						{
        							if(	str.charAt(i).search(/[=!<>]/)>=0 && str.charAt(i+1).search(/=/)>=0 )
        							{
        								i++;
        								type = '3'; // operator
        							}
        							else if(
	        							str.charAt(i).search(/\|/)>=0 && str.charAt(i+1).search(/\|/)>=0 ||
	        							str.charAt(i).search(/&/)>=0 && str.charAt(i+1).search(/&/)>=0 )
	        						{
        								i++;
        								type = '5'; // logical operator	       						
	        						}
        						}        						
        						break;        						
        					}
        					else if(str.charAt(i).search(/\s/)>=0) // any white space
        					{      				
	        					push=false;        				        					
	        					break;        					
	        				}	        				
        			}

					if(i>=str.length)
						i=str.length-1;
					
					if(push)
					{
						if(type=='u')
						{
							bTestCommand = false;
	 						break;
	 					}
	 					lexem.push([type, str.substring(fix, i+1)]);
	 				} 					
        			i++;        			        				
        		}        	
        		
        		if(bTestCommand)
        		{
        			// syntax analyzer 
        			var strSentence:String = "";       			
        			for(i=0; i<lexem.length; i++)
        				strSentence = strSentence + lexem[i][0];

					if(strSentence.search(/[35]/)==-1)
					{
						bTestCommand = false;
					}
					else
					{					
						var prevLen:int;
						do {
							prevLen = strSentence.length;
							
							// remove signs
							pattern = /^[24][vif]/g;						
							strSentence = strSentence.replace(pattern, "v");  
							pattern = /3[24][vif]/g;						
							strSentence = strSentence.replace(pattern, "3v");  
							pattern = /9[24][vif]/g;						
							strSentence = strSentence.replace(pattern, "9v");  

							// split into variable
							pattern = /[vif]1[vif]/g;						
							strSentence = strSentence.replace(pattern, "v");  
							pattern = /[vif]2[vif]/g;						
							strSentence = strSentence.replace(pattern, "v");  
							pattern = /[vifs]4[vifs]/g;						
							strSentence = strSentence.replace(pattern, "v");
							
							pattern = /9[vifs]0/g;						
							strSentence = strSentence.replace(pattern, "v");	

							pattern = /\{[vifs]\}/g;						
							strSentence = strSentence.replace(pattern, "v");													  

						} while (prevLen != strSentence.length && strSentence.length);
						
						trace(strSentence);
						
						do {
							prevLen = strSentence.length;

							pattern = /[ifs]/g;						
							strSentence = strSentence.replace(pattern, "v");

							pattern = /v3v/g;						
							strSentence = strSentence.replace(pattern, "o"); // operator							

							pattern = /[oL]5[oL]/g;						
							strSentence = strSentence.replace(pattern, "L"); // logical operator							

							pattern = /9o0/g;						
							strSentence = strSentence.replace(pattern, "o");							  

							pattern = /9L0/g;						
							strSentence = strSentence.replace(pattern, "L");							  
							
						} while (prevLen != strSentence.length && strSentence.length);
						
						trace(strSentence);
						
						if(strSentence!="o" && strSentence!="L")
							bTestCommand = false;
     				} 
        		}     
        		if(bTestCommand)
        		{
	    			arrTrans = ["true", "false"];
	    		}
	    		
	    		//check for command
        	}
   			node.arrTrans = arrTrans;
            return results;
        }
	}
}