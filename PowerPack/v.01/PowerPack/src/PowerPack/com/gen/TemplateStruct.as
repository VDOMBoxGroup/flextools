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
import PowerPack.com.managers.CashManager;

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.filesystem.File;
import flash.filesystem.FileMode;
import flash.filesystem.FileStream;
import flash.utils.ByteArray;

import mx.utils.UIDUtil;

import r1.deval.D;

public class TemplateStruct extends EventDispatcher
{
	public static const MSG_PARSE_ERR:String = "Runtime error.\nGraph: {0}\nState: {1}";
	public static var lib:TemplateLib;
	
	private var tplStructXML:XML;
	private var ID:String;
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

	public static const CNTXT_INSTANCE:String = "_lib_" + UIDUtil.createUID().replace(/-/g, "_");
	
	public var context:Dynamic = new Dynamic();

	//public var parsedNode:ParsedNode;
	private var step:String;
	public	var transition:String;
	
	public var isDebug:Boolean;
	public var isStepDebug:Boolean;
	private var forced:int;
	
	public function TemplateStruct(tplStruct:XML, ID:String)
	{				
		tplStructXML = tplStruct;		
		this.ID = ID;
		var _graphs:Array = [];
		var _nodes:Array = [];
		var _arrows:Array = [];
		var _initGraph:GraphStruct;
		
		for each (var graphXML:XML in tplStructXML.elements("graph"))
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
		
		init();
	}
	
	public static function loadLib():void
	{
		lib = new TemplateLib();
		 
		var libFolder:File = File.applicationDirectory.resolvePath('libs');
		
		if(!libFolder.exists)
			return;		
		
		var libs:Array = libFolder.getDirectoryListing(); 
		for each(var libFile:File in libs)
		{
			var stream:FileStream = new FileStream();
			var strData:String;
			
			if(!libFile.isDirectory && !libFile.isPackage && !libFile.isSymbolicLink && libFile.exists &&
				(libFile.extension=='as' || libFile.extension=='txt'))
			{
				stream.open(libFile, FileMode.READ);
				strData = stream.readUTFBytes(stream.bytesAvailable);
    			stream.close();
    			D.setOutput(evalHandler);
    			strData = strData + ';\n;' 
    			D.eval(strData, lib);
			}
		}
		
		function evalHandler(value:String):void {
			trace(value);
		}
	}
	
		
	public function validate(options:uint=0):Object
	{
		var retVal:Object = {result:false, array:[]};
		var arr:Array = [];
		var i:int;
		var j:int;
		var k:int;
		var o:int;
		
		if(!tplStructXML)
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
							if(isIdentTrans && curNode.outArrows.length>1)
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
	
	public function init():void
	{
		clear();
		
		var graphContext:GraphContext;
		
		if(initGraph) {
			graphContext = new GraphContext(initGraph);
			contextStack.push(graphContext);			
		}		
		
		if(!lib)
			lib = new TemplateLib();
		
		lib.tplStruct = this;
		context[CNTXT_INSTANCE] = lib;
	}
	
	public function clear():void
	{
		buffer = "";
		context = new Dynamic();
					
		contextStack = [];
		nodeStack = [];
		step = 'parseNewNode';
		transition = null;
		//parsedNode = null;
		isRunning = false;
		forced = -1;
		
		isDebug = false;
		isStepDebug = false;			
	}
	
	public function generate(force:Boolean=false, over:Boolean=false, ret:Boolean=false):String
	{
		//try {
			
		if(isRunning)
		{				
			//Application.application.callLater(generate, [force, over, ret]);
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
			forced = 0;
			
		if(ret)
			forced = 1;
			
		do
		{			
			// check for current node	
			if(!curGraphContext.curNode) {
				isRunning = false;
				throw new ValidationError(null, 9002, 
					[curGraphContext.curGraph.name]);
			}
								
			switch(step)
			{
				case 'parseNewNode': // parse current node
				
					if((forced>0 || over) && !force)
						force = true; 
					
					dispatchEvent(new Event("processNode"));
						
					if(isStepDebug && !force) {
						dispatchEvent(new Event("stepComplete"));
						isRunning = false;
						forced = -1;
						return null;
					}
	
					if(isDebug && !force && curGraphContext.curNode.breakpoint) {
						dispatchEvent(new Event("stepComplete"));
						isRunning = false;
						forced = -1;
						return null;
					}
						
					force = false;
					over = false;

					////////////////////////////////////////////////////////////////////
					
					if(curGraphContext.curNode.enabled)
					{
						curGraphContext.curNode.parsedNode = new ParsedNode();
	
						switch(curGraphContext.curNode.category)
						{
							case NodeCategory.NORMAL:
							  
								curGraphContext.curNode.parsedNode = CodeParser.ParseText(
									curGraphContext.curNode.text,
									[context, curGraphContext.context] );	
								break;

							case NodeCategory.RESOURCE:
							
								var resData:ByteArray = CashManager.getObject(ID, curGraphContext.curNode.text).data;
								curGraphContext.curNode.parsedNode.result = true;
								curGraphContext.curNode.parsedNode.print = true;
								curGraphContext.curNode.parsedNode.value = resData.readUTFBytes(resData.length);
								break;
																
							case NodeCategory.SUBGRAPH:
							
								curGraphContext.curNode.parsedNode = CodeParser.ParseSubgraphNode(
									curGraphContext.curNode.text );
								
								if(curGraphContext.curNode.parsedNode.result)
								{
									var subgraph:GraphStruct;
									
									for each (var graphStruct:GraphStruct in graphs)
									{
										if(graphStruct.name == curGraphContext.curNode.text)
										{	
											subgraph = graphStruct;
											break;
										}
									}
									
									if(subgraph)
									{
										nodeStack.push(new NodeContext(curGraphContext.curNode));	
										
										var graphContext:GraphContext = new GraphContext(subgraph);
										contextStack.push(graphContext);
										
										step = 'parseNewNode';
										if(forced>=0)
											forced++;
										continue;
									}
									else
									{
										isRunning = false;
										throw new ValidationError(null, 9006, 
												[curGraphContext.curNode.text]);
									}
								}
								break;
								
							case NodeCategory.COMMAND:
													
								curGraphContext.curNode.parsedNode = CodeParser.ParseCode(curGraphContext.curNode.text);
								break;

						}					
					}
									
				case 'executeCode':
				
					if(curGraphContext.curNode.parsedNode)
					{
						if(curGraphContext.curNode.parsedNode.result)
						{
							if(curGraphContext.curNode.parsedNode.type)
							{
								CodeParser.executeCode(	curGraphContext.curNode.parsedNode,
									curGraphContext.curNode.parsedNode.current,
									[context, curGraphContext.context],			 
									curGraphContext.varPrefix );						
							
									if(curGraphContext.curNode.parsedNode.value is Function)
									{
										isRunning = false;
										curGraphContext.curNode.parsedNode.current++;
										step = 'processExecResult';
										return null;
									}
								}
						}
					}								

				case 'processExecResult': 

					if(curGraphContext.curNode.parsedNode)
					{
						if(curGraphContext.curNode.parsedNode.result)
						{
							if(curGraphContext.curNode.parsedNode.type)
							{							
								if(curGraphContext.curNode.parsedNode.print && curGraphContext.curNode.parsedNode.value)
									curGraphContext.buffer += 
										curGraphContext.curNode.parsedNode.value + 
										" ";
							
								if(curGraphContext.curNode.parsedNode.type==CodeParser.CT_TEST)
									transition = curGraphContext.curNode.parsedNode.value;
								else if(curGraphContext.curNode.parsedNode.trans.length)
									transition = curGraphContext.curNode.parsedNode.value;
								
							}
							else
							{
								if(curGraphContext.curNode.parsedNode.print && curGraphContext.curNode.parsedNode.value)
									curGraphContext.buffer += 
										curGraphContext.curNode.parsedNode.value + 
										" ";
							}
						}
						
						if(!curGraphContext.curNode.parsedNode.result)
						{
							isRunning = false;
							if(curGraphContext.curNode.parsedNode.error && curGraphContext.curNode.parsedNode.error.message) {
								throw curGraphContext.curNode.parsedNode.error;
							}
							else {
								throw new RunTimeError( MSG_PARSE_ERR, -1, 
									[curGraphContext.curNode.graph.name,
									curGraphContext.curNode.text] );
							}
						}			
						
						curGraphContext.curNode.parsedNode.current++;
						
						if(curGraphContext.curNode.parsedNode.lexemsGroup && 
							curGraphContext.curNode.parsedNode.current < curGraphContext.curNode.parsedNode.lexemsGroup.length)
						{
							step = 'executeCode';
							continue;
						}
					}
					
				case 'getNextNode': // transition to next node
				
					var index:int = GetArrowIndex(curGraphContext.curNode.outArrows, transition);
					transition = null;
					
					if(	index == -1 ||
						curGraphContext.curNode.type == NodeType.TERMINAL )
					{			
						var tmpPrint:Boolean = false;
										
						if(curGraphContext.variable!=null)
						{
							context[curGraphContext.variable] =
								Utils.replaceEscapeSequences(
									curGraphContext.buffer, 
									"\\-");
						}
						else if(contextStack.length>1)
						{
							tmpPrint = true;
							GraphContext(contextStack[contextStack.length-2]).buffer +=
								curGraphContext.buffer;
						}
						else
						{
							buffer =
								curGraphContext.buffer;
						}
						
						var tmpBuf:String = curGraphContext.buffer;
						contextStack.pop();
						
						//////////////////////////////////////////////////////
						
						curGraphContext.curNode.parsedNode.current++;
						
						if(curGraphContext.curNode.parsedNode.lexemsGroup && 
							curGraphContext.curNode.parsedNode.current < curGraphContext.curNode.parsedNode.lexemsGroup.length)
						{
							step = 'executeCode';
							continue;
						}							
						else if(contextStack.length>0) 
						{
							curGraphContext.curNode.parsedNode.value = 
								tmpBuf;
							
							curGraphContext.curNode.parsedNode.print = tmpPrint;
							
							if(curGraphContext.curNode.category == NodeCategory.SUBGRAPH)
								curGraphContext.curNode.parsedNode.print = true; 	
								
							nodeStack.push(new NodeContext(curGraphContext.curNode));
						}
						
						forced--;

						if(contextStack.length==0)
							break;
						
						// exit subgraph
						step = 'getNextNode';							
						continue;
					}
					else
					{
						nodeStack.push(new NodeContext(curGraphContext.curNode));
					}
					
					// select next node
					curGraphContext.curNode = 
						ArrowStruct(curGraphContext.curNode.outArrows[index]).toObj;						
					
					step = 'parseNewNode';
			}
		} while(contextStack.length>0);
		
		// replace special sequences
		buffer = Utils.replaceEscapeSequences(buffer, "\\-");
		
		isRunning = false;
 
		dispatchEvent(new Event("generationComplete"));

		return buffer;

		//} catch (e:Error) {
		//	error = e;
		//	isRunning = false;
		//	dispatchEvent(new Event("error"));
		//}
		
		return null;
		
	}
	
	public function get curGraphContext():GraphContext 
	{
		if(contextStack.length)
			return GraphContext(contextStack[contextStack.length-1]);
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
			for(var i:int=0; i<arrows.length; i++) 
			{
				if( (transition && ArrowStruct(arrows[i]).label == transition 
					|| !transition) && ArrowStruct(arrows[i]).enabled )
					indexes.push(i);
			}
			if(indexes.length>0)
				index = indexes[ Math.round( Math.random() * (indexes.length-1) ) ];			
		}
		return index;
	}
	
}
}