package PowerPack.com.gen
{
import ExtendedAPI.com.utils.Utils;

import PowerPack.com.gen.errorClasses.RunTimeError;
import PowerPack.com.gen.errorClasses.ValidationError;
import PowerPack.com.gen.errorClasses.ValidationWarning;
import PowerPack.com.gen.parse.CodeParser;
import PowerPack.com.gen.structs.*;
import PowerPack.com.graph.NodeCategory;
import PowerPack.com.graph.NodeType;

import flash.events.Event;
import flash.events.EventDispatcher;

import mx.core.Application;
import mx.utils.UIDUtil;

public class Template extends EventDispatcher
{
	include "include/GeneralFunctions.as";
	include "include/ListManipulationFunctions.as";
	include "include/GraphicFunctions.as";
	include "include/ImageProcessingFunctions.as";

	public static const MSG_PARSE_ERR:String = "Runtime error.\nGraph: {0}\nState: {1}";
	
	private var templateXML:XML;
	public var error:Error;
	
	[ArrayElementType("GraphStruct")]
	public var graphs:Array = [];
	[ArrayElementType("NodeStruct")]
	public var nodes:Array = [];
	[ArrayElementType("ArrowStruct")]
	public var arrows:Array = [];
	
	public var initGraph:GraphStruct;
	
	public var buffer:String = "";
	
	public var isRunning:Boolean;

	[ArrayElementType("GraphContext")]
	public var contextStack:Array = [];

	public var nodeStack:Array = [];

	public static const CNTXT_INSTANCE:String = "_template_" + UIDUtil.createUID().replace(/-/g, "_");
	
	public var context:Dynamic = new Dynamic();

	public var parsedNode:Object;
	private var step:int;
	public	var transition:String;	
	
	public var isDebug:Boolean;
	public var isStepDebug:Boolean;			
	private var forced:int;
	
	public function Template(_xml:XML)
	{				
		templateXML = _xml;		
		var _graphs:Array = [];
		var _nodes:Array = [];
		var _arrows:Array = [];
		var _initGraph:GraphStruct;
		
		for each (var graphXML:XML in _xml.elements("graph"))
		{			
			var graphStruct:GraphStruct = new GraphStruct(
				Utils.getStringOrDefault(graphXML.@name),
				Utils.getStringOrDefault(graphXML.@name),					
				Utils.getBooleanOrDefault(graphXML.@initial),
				Utils.getBooleanOrDefault(graphXML.@global));	
				
			if(graphStruct.bInitial)
			{
				_initGraph = graphStruct;
			}
			
			for each (var nodeXML:XML in graphXML.states.elements("state"))
			{
				var nodeStruct:NodeStruct = new NodeStruct(
					Utils.getStringOrDefault(nodeXML.@name),
					Utils.getStringOrDefault(nodeXML.@category), 
					Utils.getStringOrDefault(nodeXML.@type), 
					Utils.getStringOrDefault(nodeXML.text),
					Utils.getBooleanOrDefault(nodeXML.@enabled, true),
					Utils.getBooleanOrDefault(nodeXML.@breakpoint),
					graphStruct);
					
				if(nodeStruct.type == NodeType.INITIAL)
				{
					graphStruct.initNode = nodeStruct;
				}
				
				graphStruct.nodes.push(nodeStruct);
				_nodes.push(nodeStruct);
			}
			
			for each (var arrowXML:XML in graphXML.transitions.elements("transition"))
			{	
				var arrowStruct:ArrowStruct = new ArrowStruct(
					Utils.getStringOrDefault(arrowXML.@name), 
					Utils.getStringOrDefault(arrowXML.label),
					null,
					null,
					Utils.getBooleanOrDefault(arrowXML.@enabled, true),
					graphStruct);
				
				for each (var node:NodeStruct in graphStruct.nodes)
				{
					if(arrowXML.@source == node.id)
					{
						arrowStruct.fromObj = node;
						node.outArrows.push(arrowStruct);
					}
					
					if(arrowXML.@destination == node.id)
					{
						arrowStruct.toObj = node;
						node.inArrows.push(arrowStruct);
					}
				}
									
				graphStruct.arrows.push(arrowStruct);
				_arrows.push(arrowStruct);
			}					
				
			_graphs.push(graphStruct);
		}
		
		_graphs.sortOn("name");
		
		initGraph = _initGraph;
		graphs = _graphs;
		nodes = _nodes;
		arrows = _arrows;
		
		genInit();
	}
	
	public function validate(options:uint=0):Object
	{
		var retVal:Object = {result:false, array:[]};
		var arr:Array = [];
		var i:int;
		var j:int;
		var k:int;
		var o:int;
		
		if(!templateXML)
		{
			return retVal; 
		}		
		
		if(!initGraph)
		{
			if(options & TemplateValidateOptions.SET_INIT_GRAPH) {
				if(graphs.length>0) {
					initGraph = graphs[0];
					initGraph.bInitial = true;
					contextStack.unshift(new GraphContext(initGraph));					
				}
			}				
			else
				arr.push( { error:new ValidationError(null, 9001), graph:null, node:null, arrow:null } );
		}
		
		// VALIDATE GRAPHS
		
		var initCount:int = 0;
		var initGraphs:String = "";
		var duplCount:int = 0;
		for(i=0;i<graphs.length;i++)
		{
			var curGraph:GraphStruct = graphs[i] as GraphStruct;
			 
			// validate name
			
			if(!curGraph.name)
				arr.push( { error:new ValidationError(null, 9006), 
					graph:curGraph, node:null, arrow:null } );
			
			if(!CodeParser.ParseSubgraphNode(curGraph.name).result)
				arr.push( { error:new ValidationError(null, 9100), 
					graph:curGraph, node:null, arrow:null } );
			
			// initial graph count			
			if(curGraph.bInitial)
			{
				initCount++;
				initGraphs += (initGraphs?",":"")+'['+curGraph.name+']';
			}
				
			// check for duplicated graph names
			if(i<graphs.length-1)
			{
				for(j=i+1;j<graphs.length;j++)
				{
					if(curGraph.name==graphs[j].name)
						arr.push( { error:new ValidationWarning(null, 9005, [graphs[j].name]), 
							graph:graphs[j], node:null, arrow:null } );
				}
			}
			
			// check for init node for graph
			if(!curGraph.initNode)
			{
				arr.push( { error:new ValidationWarning(null, 9002, [curGraph.name]), 
					graph:curGraph, node:null, arrow:null } );				
			}
		}			

		if(initCount>1)
			arr.push( { error:new ValidationError(null, 9003, [initGraphs]),
				graph:null, node:null, arrow:null } );
		
		// VALIDATE NODES

		// check for duplicated node ids
		for(i=0; i<nodes.length-1; i++)
		{	
			if(!nodes[i].id)
				arr.push( { error:new ValidationWarning(null, 9205), 
					graph:null, node:null, arrow:null } );
			
			if(i<nodes.length-1) {
				for(j=i+1; j<nodes.length; j++)
				{
					if(nodes[i].id==nodes[j].id)
						arr.push( { error:new ValidationWarning(null, 9200, [nodes[j].id]), 
							graph:null, node:null, arrow:null } );
				}
			}
		}
		
		for(i=0;i<graphs.length;i++)
		{
			initCount = 0;
			curGraph = graphs[i] as GraphStruct;
			
			for(j=0;j<curGraph.nodes.length;j++)
			{
				var curNode:NodeStruct = curGraph.nodes[j];
				 
				// initial node count
				if(curNode.type == NodeType.INITIAL) {
					initCount++;
				}
			
				var parsedNode:Object;
				
				switch(curNode.category)
				{
					case NodeCategory.NORMAL:
					 	parsedNode = CodeParser.ParseText(curNode.text);
						break;
						
					case NodeCategory.SUBGRAPH:
						parsedNode = CodeParser.ParseSubgraphNode(curNode.text);
						break;
						
					case NodeCategory.COMMAND:
						parsedNode = CodeParser.ParseCode(curNode.text);						
						break;
				}
				
				if(parsedNode && parsedNode.result==false)
	    		{
					arr.push( { error:parsedNode.error,
						graph:curGraph, node:curNode, arrow:null } );	    			
       			}				

				switch(curNode.category)
				{
					case NodeCategory.SUBGRAPH:
						var isExist:Boolean = false;
						for each (var graph:GraphStruct in graphs) {
							if(graph.name==curNode.text) {
								isExist = true;
								break;	
							}							
						}
						if(!isExist)
							arr.push( { error:new ValidationWarning(null, 9006, [curNode.text]),
								graph:curGraph, node:curNode, arrow:null } );				
						break;
						
					case NodeCategory.COMMAND:
						if(parsedNode.type == CodeParser.CT_TEST) {							
							var isIdentTrans:Boolean = true;
							var trans:Object;
							for each (var outArrow:ArrowStruct in curNode.outArrows)
							{
								if(!trans) 
									trans = outArrow.label;
									
								if(trans!=outArrow.label) {
									isIdentTrans = false;
									break;
								}
							}
							if(isIdentTrans)
								arr.push( { error:new ValidationWarning("All transitions have same value"),
									graph:curGraph, node:curNode, arrow:null } );				
						}						
						break;
				}
				
								
			}
			
			if(initCount>1)
				arr.push( { error:new ValidationWarning(null, 9004, [curGraph.name]),
					graph:curGraph, node:null, arrow:null } );	
		}
		
		// VALIDATE ARROWS

		for(i=0; i<arrows.length; i++)
		{
			// undefined id
			if(!arrows[i].id) 	
				arr.push( { error:new ValidationWarning(null, 9206), 
					graph:null, node:null, arrow:null } );

			// self-loop checking
			if(arrows[i].fromObj && arrows[i].fromObj == arrows[i].toObj) 	
				arr.push( { error:new ValidationWarning(null, 9203, [arrows[i].id, arrows[i].fromObj.id]), 
					graph:null, node:null, arrow:null } );

			// 
			if(	arrows[i].fromObj && arrows[i].toObj && 
				arrows[i].fromObj.graph != arrows[i].toObj.graph) 	
				arr.push( { error:new ValidationWarning('Transition links states from different graphs', 9204, [arrows[i].id]), 
					graph:null, node:null, arrow:null } );
			//
			if(!arrows[i].fromObj || !arrows[i].toObj) 	
				arr.push( { error:new ValidationWarning('One of end-point state is not defined', 9204, [arrows[i].id]), 
					graph:null, node:null, arrow:null } );

			if(i<arrows.length-1) {
				for(j=i+1; j<arrows.length; j++)
				{
					// check for duplicated arrow ids
					if(arrows[i].id==arrows[j].id)
						arr.push( { error:new ValidationWarning(null, 9201, [arrows[j].id]), 
							graph:null, node:null, arrow:null } );
					
					// check for multiple transitions
					if(	arrows[i].fromObj && arrows[i].toObj && 
						(arrows[i].fromObj == arrows[j].fromObj && arrows[i].toObj == arrows[j].toObj ||
						arrows[i].fromObj == arrows[j].toObj && arrows[i].toObj == arrows[j].fromObj)
					)
						arr.push( { error:new ValidationWarning(null, 9202, [arrows[i].fromObj.id, arrows[i].toObj.id]), 
							graph:null, node:null, arrow:null } );							
				}
			}
		}
			
		retVal.result = true;
		retVal.array = arr;
		//retVal.xml = getXML();
		return retVal;
	}		
	
	public function createUID(objects:Object, prop:String=null, prefix:String=""):String
	{
		if(!prefix)
			prefix="";
			
		var elm:Object;
		
		uidloop:do
		{
			var uid:String = prefix + UIDUtil.createUID().replace(/-/g, "_");
			
			if(objects is Array)
			{
				for each (elm in objects as Array)
				{
					if(prop && elm.hasOwnProperty(prop))
						elm = elm[prop];
						
					if(uid==elm.toString())
						continue uidloop;
				}
			}
			else
			{
				if(objects.hasOwnProperty(uid))
					continue uidloop;
			}

			break;

		} while(true);
		
		return uid;
	}	
	
	public function genInit():void
	{
		genClear();
		
		var graphContext:GraphContext;
		
		if(initGraph) {
			graphContext = new GraphContext(initGraph);
			contextStack.push(graphContext);			
		}		
		
		context[CNTXT_INSTANCE] = this;
	}
	
	public function genClear():void
	{
		buffer = "";
		context = new Dynamic();
					
		contextStack = [];
		nodeStack = [];
		step = 0;
		transition = null;
		parsedNode = null;
		isRunning = false;
		forced = -1;
		
		isDebug = false;
		isStepDebug = false;			
	}
	
	public function generate(force:Boolean=false, over:Boolean=false, ret:Boolean=false):String
	{
		try {
			
		//var currentContext:GraphContext = contextStack[contextStack.length-1];
		
		if(isRunning)
		{				
			Application.application.callLater(generate, [force, over]);
			return null;
		}
		isRunning = true;
		
		if(buffer) {
			isRunning = false;
			return buffer;
		}
		
		if(!initGraph) {
			isRunning = false;			
			throw new ValidationError(null, 9001);
		}
		
		if(over)
			forced=0;
			
		if(ret)
			forced=1;
			
		do
		{				
			if(!GraphContext(contextStack[contextStack.length-1]).curNode) {
				isRunning = false;
				throw new ValidationError(null, 9002, 
					[GraphContext(contextStack[contextStack.length-1]).curGraph.name]);
			}
								
			switch(step)
			{
				case 0: // parse current node
					step = 0;
					
					if((forced>0 || over) && !force)
						force = true;
					
					dispatchEvent(new Event("processNode"));
						
					if(isStepDebug && !force) {
						dispatchEvent(new Event("stepComplete"));
						isRunning = false;
						forced = -1;
						return null;
					}
	
					if(isDebug && !force && GraphContext(contextStack[contextStack.length-1]).curNode.breakpoint) {
						dispatchEvent(new Event("stepComplete"));
						isRunning = false;
						forced = -1;
						return null;
					}
						
					force = false;
					over = false;
					
					parsedNode = new Object();
					
					switch(GraphContext(contextStack[contextStack.length-1]).curNode.category)
					{
						case NodeCategory.NORMAL:
						
							parsedNode = CodeParser.ParseText(
								GraphContext(contextStack[contextStack.length-1]).curNode.text,
								[context, GraphContext(contextStack[contextStack.length-1]).context] );	
							break;
							
						case NodeCategory.SUBGRAPH:
						
							var subgraph:GraphStruct;
							parsedNode = CodeParser.ParseSubgraphNode(
								GraphContext(contextStack[contextStack.length-1]).curNode.text );
							
							if(parsedNode.result)
							{
								for each (var graphStruct:GraphStruct in graphs)
								{
									if(graphStruct.name == GraphContext(contextStack[contextStack.length-1]).curNode.text)	
										subgraph = graphStruct;
								}
								
								if(subgraph)
								{
									GraphContext(contextStack[contextStack.length-1]).curNode['parsedNode'] = parsedNode;
									nodeStack.push(new NodeContext(GraphContext(contextStack[contextStack.length-1]).curNode));	
									
									var graphContext:GraphContext = new GraphContext(subgraph);
									contextStack.push(graphContext);
									
									step = 0;
									if(forced>=0)
										forced++;
									continue;
								}
								else
								{
									isRunning = false;
									throw new ValidationError(null, 9006, 
											[GraphContext(contextStack[contextStack.length-1]).curNode.text]);
								}
							}
							break;
							
						case NodeCategory.COMMAND:
												
							step = 1;
							
							parsedNode = CodeParser.ParseCode(
								GraphContext(contextStack[contextStack.length-1]).curNode.text,
								GraphContext(contextStack[contextStack.length-1]).varPrefix,
								[context, GraphContext(contextStack[contextStack.length-1]).context] );
									
							if(parsedNode.result)
							{		
								if(parsedNode.type==CodeParser.CT_FUNCTION)
								{							
									isRunning = false;										
									return null;
								}		
							}
							
							break;
					}					
				
				case 1: // append data to buffer
					step = 1;
				
					if(!parsedNode.result)
					{
						isRunning = false;
						if(parsedNode.error && parsedNode.error.message) {
							throw parsedNode.error;
						}
						else {
							throw new RunTimeError( MSG_PARSE_ERR, -1, 
								[GraphContext(contextStack[contextStack.length-1]).curNode.graph.name,
								GraphContext(contextStack[contextStack.length-1]).curNode.text] );
						}  
					}			
					else
					{
						if(parsedNode.print && parsedNode.string)
							GraphContext(contextStack[contextStack.length-1]).buffer += 
								parsedNode.string + 
								" ";
						
						if(parsedNode.variable!=null)
							context[parsedNode.variable] = parsedNode.string;

						if(parsedNode.type==CodeParser.CT_TEST)
							transition = parsedNode.string;							
						else if(parsedNode.transition)
							transition = parsedNode.transition;
					}
					
					GraphContext(contextStack[contextStack.length-1]).curNode['parsedNode'] = parsedNode;

				case 2: // transition to next node						
					step = 2;
					
					var index:int = -1;
					index = GetArrowIndex(GraphContext(contextStack[contextStack.length-1]).curNode.outArrows, transition);
					transition = null;
					
					if(	index == -1 ||
						GraphContext(contextStack[contextStack.length-1]).curNode.type == NodeType.TERMINAL )
					{			
						var tmpPrint:Boolean = false;
										
						if(GraphContext(contextStack[contextStack.length-1]).variable!=null)
						{
							context[GraphContext(contextStack[contextStack.length-1]).variable] =
								Utils.replaceEscapeSequences(
									GraphContext(contextStack[contextStack.length-1]).buffer, 
									"\\-");
						}
						else if(contextStack.length>1)
						{
							tmpPrint = true;
							GraphContext(contextStack[contextStack.length-2]).buffer +=
								GraphContext(contextStack[contextStack.length-1]).buffer;
						}
						else
						{
							buffer =
								GraphContext(contextStack[contextStack.length-1]).buffer;
						}
						
						var tmpBuf:String = GraphContext(contextStack[contextStack.length-1]).buffer;
						contextStack.pop();
						
						if(contextStack.length>0) {
							GraphContext(contextStack[contextStack.length-1]).curNode.parsedNode.string = 
								tmpBuf;
							
							GraphContext(contextStack[contextStack.length-1]).curNode.parsedNode.print = tmpPrint;
							
							if(GraphContext(contextStack[contextStack.length-1]).curNode.category == NodeCategory.SUBGRAPH)
								GraphContext(contextStack[contextStack.length-1]).curNode.parsedNode.print = true; 	
								
							nodeStack.push(new NodeContext(GraphContext(contextStack[contextStack.length-1]).curNode));
						}
						
						forced--;							

						if(contextStack.length==0)
							break;
						
						// exit subgraph
						step = 2;							
						continue;
					}
					else
					{
						nodeStack.push(new NodeContext(GraphContext(contextStack[contextStack.length-1]).curNode));
					}
					
					// select next node
					GraphContext(contextStack[contextStack.length-1]).curNode = 
						ArrowStruct(GraphContext(contextStack[contextStack.length-1]).curNode.outArrows[index]).toObj;						
					
					step = 0;
			}
		} while(contextStack.length>0);
		
		// replace special sequences
		buffer = Utils.replaceEscapeSequences(buffer, "\\-");
		
		dispatchEvent(new Event("generationComplete"));
		isRunning = false;
		return buffer;

		} catch (e:Error) {
			error = e;
			dispatchEvent(new Event("error"));
		}
		
		return null;		
	}
	
	/**
	 * This function determine which way to go from current state by
	 * choosing arrow index in out-arrows array
	 * 
	 * @param arrows - out arrows array
	 * @param transition - transition string
	 * @return - out arrows array index for transition
	 * 
	 */
	private static function GetArrowIndex(arrows:Array, transition:String):int
	{
		var indexes:Array = new Array();
		var index:int = -1;
		
		if(arrows && arrows.length>0)
		{	
			if(transition)
			{
				for(var i:int=0; i<arrows.length; i++) {
					if(( transition && ArrowStruct(arrows[i]).label == transition 
						|| !transition ) && 
						ArrowStruct(arrows[i]).enabled)
						indexes.push(i);
				}
				if(indexes.length>0)
					index = indexes[ Math.round( Math.random() * (indexes.length-1) ) ];
			}
		}
		return index;
	}
	
}
}