package PowerPack.com.gen
{
	import PowerPack.com.Utils;
	import PowerPack.com.graph.GraphNodeCategory;
	import PowerPack.com.graph.GraphNodeType;
	import PowerPack.com.mdm.filesystem.FileToBase64;
	import PowerPack.com.parse.NodeParser;
	
	import com.riaone.deval.D;
	
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.EventDispatcher;
	
	import mdm.FileSystem;
	
	import mx.controls.Alert;
	import mx.core.Application;
	import mx.managers.PopUpManager;
	import mx.utils.Base64Encoder;
	import mx.utils.StringUtil;
	import mx.utils.UIDUtil;
	
	[Event(name="generationComplete", type="flash.events.Event")]
	public class TemplateStruct extends EventDispatcher
	{
		public static const CNTXT_INSTANCE:String = "___template_struct";
		 
		public var initGraph:GraphStruct;
		
		private var context:Dynamic;
		private var parsedNode:Object;
		private	var transition:String;		
		private var step:int;
		
		[ArrayElementType("GraphStruct")]
		public var graphs:Array;		
		
		public var buffer:String;
		
		[ArrayElementType("GraphContext")]
		public var contextStack:Array;
		
		public function TemplateStruct(_xml:XML)
		{						
			var _graphs:Array = new Array();
			var _initGraph:GraphStruct;
			
			for each (var graphXML:XML in _xml.elements("graph"))
			{			
				var graphStruct:GraphStruct = new GraphStruct(
					graphXML.@id,
					graphXML.@name,
					graphXML.@initial.toString().toLowerCase()=="true"?true:false);	
					
				if(graphStruct.bInitial)
				{
					if(_initGraph)
						throw new Error("Duplicated initial graph");
						
					_initGraph = graphStruct;
				}
				
				for each (var nodeXML:XML in graphXML.states.elements("state"))
				{
					var nodeStruct:NodeStruct = new NodeStruct(
						nodeXML.@name,
						nodeXML.@category, 
						nodeXML.@type, 
						nodeXML.text,
						graphStruct);
						
					if(nodeStruct.type == GraphNodeType.INITIAL)
					{
						if(graphStruct.initNode)
							throw new Error("Duplicated initial node");
							
						graphStruct.initNode = nodeStruct;
					}
					
					graphStruct.nodes.push(nodeStruct);
				}
				if(!graphStruct.initNode)
					throw new Error("Undefined initial node for graph: " + graphStruct.name);
				
				for each (var arrowXML:XML in graphXML.transitions.elements("transition"))
				{	
					var arrowStruct:ArrowStruct = new ArrowStruct(
						arrowXML.@name, 
						arrowXML.label,
						arrowXML.data,
						null,
						null,
						graphStruct);
					
					for each (var node:NodeStruct in graphStruct.nodes)
					{
						if(arrowXML.@source == node.id)
						{
							arrowStruct.fromObj = node;
							node.outArrows.push(arrowStruct);
						}
						else if(arrowXML.@destination == node.id)
						{
							arrowStruct.toObj = node;
							node.inArrows.push(arrowStruct);
						}
					}
										
					graphStruct.arrows.push(arrowStruct);
				}					
					
				_graphs.push(graphStruct);
			}
			
			if(!_initGraph)
				throw new Error("Undefined initial graph");
			
			
			initGraph = _initGraph;
			graphs = _graphs;
			
			contextStack = new Array();
		
			Init();
		}
		
		public function Init():void
		{
			Clear();
			var graphContext:GraphContext = new GraphContext(initGraph);
			contextStack.push(graphContext);
			
			context[CNTXT_INSTANCE] = this;
		}
		
		public function Clear():void
		{
			buffer = "";
			context = new Dynamic();
						
			contextStack = [];
			step = 0;
		}
		
		public function Generate():String
		{		
			//var currentContext:GraphContext = contextStack[contextStack.length-1];

			do
			{				
				switch(step)
				{
					case 0:
						if(GraphContext(contextStack[contextStack.length-1]).curNode.category == GraphNodeCategory.NORMAL)
						{
							parsedNode = NodeParser.NormalNodeParse(
								GraphContext(contextStack[contextStack.length-1]).curNode.text,
								context);

							if(parsedNode.result && parsedNode.resultString)
							{
								GraphContext(contextStack[contextStack.length-1]).buffer += 
									(parsedNode.resultString ? parsedNode.resultString :
									GraphContext(contextStack[contextStack.length-1]).curNode.text) +
									" ";
							}
							else
							{
								throw new Error("Parse error: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
							}					
						}
						else if(GraphContext(contextStack[contextStack.length-1]).curNode.category == GraphNodeCategory.SUBGRAPH)
						{
							var subgraph:GraphStruct;
							
							for each (var graphStruct:GraphStruct in graphs)
							{
								if(graphStruct.name == GraphContext(contextStack[contextStack.length-1]).curNode.text)	
									subgraph = graphStruct;
							}
							
							if(subgraph)
							{
								var graphContext:GraphContext = new GraphContext(subgraph);
								contextStack.push(graphContext);
								
								step = 0;						
								continue;
							}
							else
							{
								throw new Error("Undefined graph name: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
							}						
						}
						else if(GraphContext(contextStack[contextStack.length-1]).curNode.category == GraphNodeCategory.COMMAND)
						{
							parsedNode = NodeParser.CommandNodeParse(
								GraphContext(contextStack[contextStack.length-1]).curNode.text,
								false,
								GraphContext(contextStack[contextStack.length-1]).varPrefix,
								context);
									
							if(parsedNode.result && parsedNode.program)
							{		
								if(parsedNode.type==NodeParser.CT_OPERATION)
								{		
									D.eval(parsedNode.program, null, context);				
								}
								else if(parsedNode.type==NodeParser.CT_TEST)
								{
									transition = D.eval(parsedNode.program, null, context).toString();	
								}
								else
								{							
									step = 1;
									D.eval(parsedNode.program, null, context);
									return null;
								}		
							}
							else
							{
								throw new Error("Undefined command or parse error: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
							}					
						}
					
					case 1:
						parsedNode = null;
						
						var index:int = -1;
						index = GetArrowIndex(GraphContext(contextStack[contextStack.length-1]).curNode.outArrows, transition);
						transition = null;
						
						if(	index == -1 ||
							GraphContext(contextStack[contextStack.length-1]).curNode.type == GraphNodeType.TERMINAL )
						{							
							if(GraphContext(contextStack[contextStack.length-1]).resultVar)
							{
								D.eval( GraphContext(contextStack[contextStack.length-1]).resultVar + 
										"=\"" + GraphContext(contextStack[contextStack.length-1]).buffer + "\";", 
										null, context);
							}
							else if(contextStack.length>1)
							{
								GraphContext(contextStack[contextStack.length-2]).buffer +=
									GraphContext(contextStack[contextStack.length-1]).buffer;
							}
							else
							{
								buffer =
									GraphContext(contextStack[contextStack.length-1]).buffer;
							}
									
							contextStack.pop();							
	
							if(contextStack.length==0)
								break;
							
							step = 1;							
							continue;
						}
							
						// select next node
						GraphContext(contextStack[contextStack.length-1]).curNode = 
							ArrowStruct(GraphContext(contextStack[contextStack.length-1]).curNode.outArrows[index]).toObj;						
						
						step = 0;
				}
			} while(contextStack.length>0);			
			
			// replace special sequences
			buffer = replaceSpecialSequences(buffer);
			
			dispatchEvent(new Event("generationComplete"));
			return buffer;
		}
		
		public static function replaceSpecialSequences(buffer:String):String
		{
			var str:String;
			
			str = buffer.concat();
			
			str = str.replace(/\\r/g, "\r");
			str = str.replace(/\\n/g, "\n");
			str = str.replace(/\\t/g, "\t");
			str = str.replace(/ ?\\- ?/g, "");
			str = str.replace(/\\\$/g, "$");

			//str = str.replace(/\\\\/g, "\\");			
			
			return str;
		}
		
		private static function GetArrowIndex(arrows:Array, transition:String):int
		{
			var indexes:Array = new Array();
			var index:int = -1;
			
			if(arrows && arrows.length>0)
			{	
				if(transition)
				{
					for(var i:int=0; i<arrows.length; i++)
					{
						if(ArrowStruct(arrows[i]).data == transition)
							indexes.push(i);
					}
					if(indexes.length>0)
						index = indexes[ Math.round( Math.random() * (indexes.length-1) ) ];
						
					transition = null;
				}
				else
				{
					index = Math.round( Math.random() * (arrows.length-1) );
				}
			}
			return index;
		}

		/**
		 * sub function section
		 */	
		public function sub(graph:String):String
		{
			var subgraph:GraphStruct;
			
			for each (var graphStruct:GraphStruct in graphs)
			{
				if(graphStruct.name == graph)	
					subgraph = graphStruct;
			}
			
			if(subgraph)
			{
				var graphContext:GraphContext = new GraphContext(subgraph);

				if(parsedNode.variable)
					graphContext.resultVar = parsedNode.variable;

				contextStack.push(graphContext);
				
				step = 0;
				
				Generate();
			}
			else
			{
				throw new Error("Undefined graph name: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
			}
				
			return null;
		}
		
		/**
		 * subprefix function section
		 */	
		 
		public function subprefix(graph:String, prefix:String):String
		{
			var subgraph:GraphStruct;
			
			for each (var graphStruct:GraphStruct in graphs)
			{
				if(graphStruct.name == graph)	
					subgraph = graphStruct;
			}
			
			if(subgraph)
			{
				var graphContext:GraphContext = new GraphContext(subgraph);

				if(parsedNode.variable)
					graphContext.resultVar = parsedNode.variable;

				graphContext.varPrefix = prefix;

				contextStack.push(graphContext);
				
				step = 0;
				
				Generate();
			}
			else
			{
				throw new Error("Undefined graph name: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
			}
				
			return null;
		}
				 		
		/**
		 * question function section
		 */		
		 
		public function question(question:String, answers:String):String
		{
			var array:Array = null;

			answers = StringUtil.trim(answers);

			if(answers!="*")
				array = answers.split(/\s*,\s*/);
									
			Dialog.show(question, "Question", array, null, questionCloseHandler);
					
			return null;
		}
		
		private function questionCloseHandler(event:Event):void
		{
			if(parsedNode.variable)
				context[parsedNode.variable] = event.target.strAnswer;
			
			if(parsedNode.print)
				GraphContext(contextStack[contextStack.length-1]).buffer += 
					event.target.strAnswer +
					" ";

			Generate();
		}	
		
		/**
		 * convert function section
		 */
		 
		public function convert(type:String, value:Object):void
		{
			var result:String;
			
			if(type == "HexColor")
			{
				result = int("0x" + value.toString().replace(/^#/g, "")).toString();
				convertComplete(result);
			}
			else if(type == "IntColor")
			{				
				result = int(value).toString(16);
				while(result.length<6)
				{
					result = result + "0";
				}
				result = "#" + result;
					
				convertComplete(result);
			}
			else if(type == "Base64")
			{
				var fileToBase64:FileToBase64 = new FileToBase64(value.toString());
				fileToBase64.addEventListener("dataConverted", completeConvertHandler);
				fileToBase64.loadAndConvert();
			}
			else
			{			
				Generate();
			}
		}
		
		private function completeConvertHandler(event:Event):void
		{
			convertComplete(event.target.data);
		}
		
		private function convertComplete(value:String):void
		{
			if(parsedNode.variable)
				context[parsedNode.variable] = value;
			
			if(parsedNode.print)
				GraphContext(contextStack[contextStack.length-1]).buffer += 
					value +
					" ";

			Generate();
		}		
		/**
		 * writeTo function section
		 */
		
		public function writeTo(filename:String):void
		{			
			var data:String = GraphContext(contextStack[0]).buffer;
			mdm.FileSystem.saveFile(filename, data);
			Generate();
		}			 
		 		
		/**
		 * writeVarTo function section
		 */
		
		public function writeVarTo(filename:String, value:Object):void
		{			
			var data:String = value.toString();
			mdm.FileSystem.saveFile(filename, data);
			Generate();
		}	
		
		/**
		 * GUID function section
		 */
		 
		public function GUID():void
		{
			var guid:String = UIDUtil.createUID();
			
			if(parsedNode.variable)
				context[parsedNode.variable] = guid;
			
			if(parsedNode.print)
				GraphContext(contextStack[contextStack.length-1]).buffer += 
					guid +
					" ";
			
			Generate();
		}			 		
	}
}