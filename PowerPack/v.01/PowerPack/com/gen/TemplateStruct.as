package PowerPack.com.gen
{
	import PowerPack.com.gen.*;
	import PowerPack.com.graph.GraphNodeCategory;
	import PowerPack.com.graph.GraphNodeType;
	import PowerPack.com.parse.NodeParser;	
	import com.riaone.deval.D;
	import mx.managers.PopUpManager;
	import mx.core.Application;
	import flash.display.Sprite;
	import flash.events.Event;
	import mx.controls.Alert;
	import PowerPack.com.Utils;
	import flash.events.EventDispatcher;
	import mx.utils.StringUtil;
	import mx.utils.Base64Encoder;
	
	[Event(name="generationComplete", type="flash.events.Event")]
	public class TemplateStruct extends EventDispatcher
	{
		public static const INSTANCE:String = "___template_struct";
		 
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
			
			context[INSTANCE] = this;
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
						
							GraphContext(contextStack[contextStack.length-1]).buffer += 
								parsedNode.resultString ? parsedNode.resultString :
								GraphContext(contextStack[contextStack.length-1]).curNode.text;					
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
								GraphContext(contextStack[contextStack.length-1]).varPrefix);
									
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
								throw new Error("Undefined command: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
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
								buffer +=
									GraphContext(contextStack[contextStack.length-1]).buffer;
							}
									
							contextStack.pop();							
	
							if(contextStack.length==0)
								break;
							
							step = 1;							
							continue;
						}
							
						//
						GraphContext(contextStack[contextStack.length-1]).curNode = 
							ArrowStruct(GraphContext(contextStack[contextStack.length-1]).curNode.outArrows[index]).toObj;						
						
						step = 0;
				}
			} while(contextStack.length>0);			
			
			dispatchEvent(new Event("generationComplete"));
			return buffer;
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
					event.target.strAnswer;
			
			//if(event.target.arrAnswers && event.target.arrAnswers.length>0)
			//	transition = event.target.strAnswer;
				
			Generate();
		}	
		
		/**
		 * convert function section
		 */
		 
		public function convert(type:String, value:String):void
		{
			Generate();
		}			 
		 		
	}
}