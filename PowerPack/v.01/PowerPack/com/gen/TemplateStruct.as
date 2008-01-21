package PowerPack.com.gen
{
	import PowerPack.com.gen.*;
	import PowerPack.com.graph.GraphNodeCategory;
	import PowerPack.com.graph.GraphNodeType;
	import PowerPack.com.parse.NodeParser;	
	import com.riaone.deval.D;
	
	public class TemplateStruct
	{
		public var initGraph:GraphStruct;
		
		private var context:Dynamic;
		
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
		
			Clear();
			Init();
		}
		
		public function Init():void
		{
			var graphContext:GraphContext = new GraphContext(initGraph);
			contextStack.push(graphContext);
		}
		
		public function Clear():void
		{
			buffer = "";
			context = new Dynamic();
						
			contextStack = [];
		}
		
		public function Generate():String
		{		
			var parsedNode:Object;
			var transition:String;
			//var currentContext:GraphContext = contextStack[contextStack.length-1];
			
			do
			{					
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
					
						continue;
					}
					else
					{
						throw new Error("Undefined graph name: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
					}						
				}
				else
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
							D.eval(parsedNode.program, null, context);
						}		

						//GraphContext(contextStack[contextStack.length-1]).buffer += 
						//	GraphContext(contextStack[contextStack.length-1]).curNode.text;
					}
					else
					{
						throw new Error("Undefined command: " + GraphContext(contextStack[contextStack.length-1]).curNode.text);
					}					
				}
				
				var index:int = -1;
				
				while(	(index=GetArrowIndex(GraphContext(contextStack[contextStack.length-1]).curNode.outArrows, transition)) == -1 ||
						GraphContext(contextStack[contextStack.length-1]).curNode.type == GraphNodeType.TERMINAL)
				{
					transition = null;
					
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
				}
				
				transition = null;
				
				if(contextStack.length==0)
					break;
					
				//
				GraphContext(contextStack[contextStack.length-1]).curNode = 
					ArrowStruct(GraphContext(contextStack[contextStack.length-1]).curNode.outArrows[index]).toObj;
																	
			} while(contextStack.length>0);
			
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
						index = indexes[Math.round( Math.random() * (indexes.length-1) )];
						
					transition = null;
				}
				else
				{
					index = Math.round( Math.random() * (arrows.length-1) );
				}
			}
			return index;
		}
		
		
	}
}