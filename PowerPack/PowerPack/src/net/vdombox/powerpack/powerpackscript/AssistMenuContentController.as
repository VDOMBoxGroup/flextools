package net.vdombox.powerpack.powerpackscript
{
	import net.vdombox.powerpack.graph.GraphCanvas;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.connection.SOAPBaseLevel;
	import net.vdombox.powerpack.lib.player.gen.parse.Parser;
	import net.vdombox.powerpack.lib.player.popup.Answers.AnswerCreator;
	import net.vdombox.powerpack.panel.Graphs;

	public class AssistMenuContentController
	{
		public function AssistMenuContentController()
		{
		}
		
		public static function get allFunctions () : Array
		{
			var functions : Array =  [];
			var listObject : Object;
			
			for (var func:String in Parser.funcDefinition)
			{
				listObject = new Object();
				listObject["data"] = func;
				listObject["label"] = func;
				listObject["description"] = getFunctionDetails(func);
				
				functions.push(listObject);
			}
			
			return functions;
		}
		
		public static function get wholeMethodFunctions () : Array
		{
			var wholefunctions : Array =  [];
			var listObject : Object;
			
			for each (var func:String in SOAPBaseLevel.wholeMethodFunctions)
			{
				listObject = new Object();
				listObject["data"] = func;
				listObject["label"] = func;
				listObject["description"] = getWholeFunctionDetails(func);
				
				wholefunctions.push(listObject);
			}
			
			return wholefunctions;
		}
		
		public static function get allVariables () : Array
		{
			var variablesNames : Array =  [];
			var listObject : Object;
			
			for each (var variable : String in Graphs.allVariables)
			{
				listObject = new Object();
				listObject["data"] = variable.charAt(0) == "$" ? variable.substr(1) : variable;
				listObject["label"] = variable;
				
				variablesNames.push(listObject);
			}
			
			return variablesNames;
		}
		
		public static function get allGraphs () : Array
		{
			var graphsNames : Array =  [];
			var listObject : Object;
			
			for each (var graph : GraphCanvas in Graphs.graphs)
			{
				listObject = new Object();
				listObject["data"] = graph.name;
				listObject["label"] = graph.name;
				
				graphsNames.push(listObject);
			}
			
			return graphsNames;
		}
		
		public static function get allDialogTypes () : Array
		{
			var dialogAnswerTypes : Array =  [];
			var listObject : Object;
			
			for each (var ansType:String in AnswerCreator.answer_types)
			{
				listObject = new Object();
				listObject["data"] = ansType;
				listObject["label"] = ansType;
				listObject["description"] = getDialogTypesDetails(ansType);
				
				dialogAnswerTypes.push(listObject);
			}
			
			return dialogAnswerTypes;
		}
		
		public static function getFunctionDetails (functionName : String) : String
		{
			return FunctionsDescription.funcDetails[functionName] || "";
		}
		
		public static function getWholeFunctionDetails (functionName : String) : String
		{
			return FunctionsDescription.wholeMethodFunctionsDescription[functionName] || "";
		}
		
		public static function getDialogTypesDetails (dialogType : String) : String
		{
			return FunctionsDescription.dialogAnswerTypesDescription[dialogType] || "";
		}
		
	}
}