package PowerPack.com.validators
{
	import ExtendedAPI.com.utils.Utils;
	
	import PowerPack.com.gen.parse.CodeParser;
	import PowerPack.com.gen.parse.parseClasses.CodeFragment;
	import PowerPack.com.gen.parse.parseClasses.ParsedBlock;
	import PowerPack.com.graph.Node;
	import PowerPack.com.graph.NodeCategory;
	import PowerPack.com.managers.LanguageManager;
	
	import mx.validators.ValidationResult;
	import mx.validators.Validator;

	public class NodeTextValidator extends Validator
	{
		static private var defaultCaptions:Object = {
			test_command: "test command",
			operation_command: "operation command",
			function_command: "function command",
			
			msg_not_valid_source: "Not valid source object.",
			msg_normal_node_syntax_error: "State syntax error.",
			msg_graph_node_syntax_error: "Subgraph state syntax error.",
			msg_command_node_syntax_error: "Command state syntax error."
		}
		
		static private var _classConstructed:Boolean = classConstruct(); 
		
		static private function classConstruct():Boolean
		{
			LanguageManager.setSentences(defaultCaptions);
			return true;
		}
							
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
			
			var node:Node;
			
			var category:String;

            // Clear results Array.
            results = [];
			
            // Call base class doValidation().
            results = super.doValidation(value);
                    
            // Return if there are errors.
            if (results.length > 0)
                return results;
        	
        	if(!(source is Node))
            {
                results.push(new ValidationResult(true, null, "invalidSource", 
                    LanguageManager.sentences.msg_not_valid_source));
                return results;
            }      
            
            node = Node(source);
            var arrTrans:Array = [];
        	node.toolTip = null;
        	
        	category = node.category;
       		var pattern:RegExp;
        	
        	var parseResult:ParsedBlock;
        	
        	if (category == NodeCategory.NORMAL)
        	{
        		parseResult = CodeParser.ParseText(str);
        		
				if(parseResult.error)
            	{
                	results.push(new ValidationResult(true, null, "invalidVarName", 
                    	(parseResult.error ? parseResult.error.message : LanguageManager.sentences.msg_normal_node_syntax_error)));
            	}       
        	}
        	else if (category == NodeCategory.SUBGRAPH)
        	{
        		parseResult = CodeParser.ParseSubgraphNode(str);

	        	if(parseResult.error)
            	{
                	results.push(new ValidationResult(true, null, "invalidSubgraph", 
                    	(parseResult.error ? parseResult.error.message : LanguageManager.sentences.msg_graph_node_syntax_error)));
            	}
         	}
        	else if (category == NodeCategory.COMMAND)
        	{        		
       			// check for command
       			       			
       			parseResult = CodeParser.ParseCode(str);
				
				node.toolTip = "";
				
				if(parseResult.trans)
					arrTrans = parseResult.trans;
        		
        		switch(parseResult.type)
        		{
        			case CodeFragment.CT_TEST:
	        			node.toolTip = LanguageManager.sentences.test_command;
        				break;
        				 
        			case CodeFragment.CT_OPERATION:
	        			node.toolTip = LanguageManager.sentences.operation_command;
        				break;

        			case CodeFragment.CT_FUNCTION:
	        			node.toolTip = LanguageManager.sentences.function_command;
        				break;
        		}
        			
	    		if(parseResult.error)
	    		{
	    			results.push(new ValidationResult(true, null, "invalidCommand", 
                    	(parseResult.error ? parseResult.error.message : LanguageManager.sentences.msg_command_node_syntax_error)));
       			}
        		//node.toolTip += node.text;
        	}
        	
            if(parseResult.errFragment)
            	node.nodeTextArea.setSelection(parseResult.errFragment.position, 
            		parseResult.errFragment.position + parseResult.errFragment.origValue.length);
            
            if(!Utils.isEqualArrays(node.arrTrans, arrTrans))
	   			node.arrTrans = arrTrans;
   			
            return results;
        }
	}
}