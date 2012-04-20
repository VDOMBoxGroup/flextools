package net.vdombox.powerpack.powerpackscript
{
	import net.vdombox.powerpack.graph.GraphCanvas;
	import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
	import net.vdombox.powerpack.lib.player.connection.SOAPBaseLevel;
	import net.vdombox.powerpack.lib.player.gen.parse.Parser;
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
			
			for (var i:* in Parser.funcDefinition)
			{
				listObject = new Object();
				listObject["data"] = i;
				listObject["label"] = i;
				
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
		
		public static function get functionDetails () : String
		{
			return "111"
		}
		
	}
}