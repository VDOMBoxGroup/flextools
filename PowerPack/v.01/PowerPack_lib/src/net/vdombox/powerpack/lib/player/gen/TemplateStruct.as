package net.vdombox.powerpack.lib.player.gen
{

import flash.events.Event;
import flash.events.EventDispatcher;
import flash.utils.ByteArray;

import mx.utils.UIDUtil;

import net.vdombox.powerpack.lib.extendedapi.utils.Utils;
import net.vdombox.powerpack.lib.player.events.TemplateLibEvent;
import net.vdombox.powerpack.lib.player.gen.errorClasses.RunTimeError;
import net.vdombox.powerpack.lib.player.gen.errorClasses.ValidationError;
import net.vdombox.powerpack.lib.player.gen.errorClasses.ValidationWarning;
import net.vdombox.powerpack.lib.player.gen.parse.CodeParser;
import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.CodeFragment;
import net.vdombox.powerpack.lib.player.gen.parse.parseClasses.ParsedBlock;
import net.vdombox.powerpack.lib.player.gen.structs.*;
import net.vdombox.powerpack.lib.player.graph.NodeCategory;
import net.vdombox.powerpack.lib.player.graph.NodeType;
import net.vdombox.powerpack.lib.player.managers.ContextManager;
import net.vdombox.powerpack.lib.player.template.Template;

import r1.deval.D;

public class TemplateStruct extends EventDispatcher
{
	public static const EVENT_ERROR					: String = "error";
	public static const EVENT_GENERATION_COMPLETE	: String = "generationComplete";
	public static const EVENT_STEP_COMPLETE			: String = "stepComplete";
	
	public static const MSG_PARSE_ERR : String = "Runtime error.\nGraph: {0}\nState: {1}";
	public static var lib : TemplateLib;

	private var tplStructXML : XML;
	private var ID : String;
	public var error : Error;

	[ArrayElementType("net.vdombox.powerpack.lib.player.gen.structs.GraphStruct")]
	public var graphs : Array = [];

	[ArrayElementType("net.vdombox.powerpack.lib.player.gen.structs.NodeStruct")]
	public var nodes : Array = [];

	[ArrayElementType("net.vdombox.powerpack.lib.player.gen.structs.ArrowStruct")]
	public var arrows : Array = [];

	public var initGraph : GraphStruct;

	public var buffer : String = "";

	[Bindable]
	public var isRunning : Boolean;

	[ArrayElementType("net.vdombox.powerpack.lib.player.gen.GraphContext")]
	public var contextStack : Array = [];

	public var nodeStack : Array = [];

	public static const CNTXT_INSTANCE : String = "_lib_" + UIDUtil.createUID().replace( /-/g, "_" );

	public var context : Dynamic = new Dynamic();

	//public var parsedNode:ParsedNode;
	public var step : String;
	public var transition : String;

	public var isDebug : Boolean;
	public var isStepDebug : Boolean;
	public var forced : int;
	public var terminated : Boolean;

	public function TemplateStruct( tplStruct : XML )
	{
		tplStructXML = tplStruct;
		
		var _graphs : Array = [];
		var _nodes : Array = [];
		var _arrows : Array = [];
		var _initGraph : GraphStruct;

		for each ( var graphXML : XML in tplStructXML.elements( "graph" ) )
		{
			var graphName : String = Utils.getStringOrDefault( graphXML.@name );
			
			var graphStruct : GraphStruct = new GraphStruct(
					graphName,
					graphName,
					graphName == currentTemplate.selectedProject.initialGraphName,
					Utils.getBooleanOrDefault( graphXML.@global ) );

			if ( graphStruct.bInitial )
				_initGraph = graphStruct;

			for each ( var nodeXML : XML in graphXML.states.elements( "state" ) )
			{
				var nodeStruct : NodeStruct = new NodeStruct(
						Utils.getStringOrDefault( nodeXML.@name ),
						Utils.getStringOrDefault( nodeXML.@category ),
						Utils.getStringOrDefault( nodeXML.@type ),
						Utils.getStringOrDefault( nodeXML.text ),
						Utils.getBooleanOrDefault( nodeXML.@enabled, true ),
						Utils.getBooleanOrDefault( nodeXML.@breakpoint ),
						graphStruct );

				if ( nodeStruct.type == NodeType.INITIAL )
				{
					graphStruct.initNode = nodeStruct;
				}

				graphStruct.nodes.push( nodeStruct );
				_nodes.push( nodeStruct );
			}

			for each ( var arrowXML : XML in graphXML.transitions.elements( "transition" ) )
			{
				var arrowStruct : ArrowStruct = new ArrowStruct(
						Utils.getStringOrDefault( arrowXML.@name ),
						Utils.getStringOrDefault( arrowXML.label ),
						null,
						null,
						Utils.getBooleanOrDefault( arrowXML.@enabled, true ),
						graphStruct );

				for each ( var node : NodeStruct in graphStruct.nodes )
				{
					if ( arrowXML.@source == node.id )
					{
						arrowStruct.fromObj = node;
						node.outArrows.push( arrowStruct );
					}

					if ( arrowXML.@destination == node.id )
					{
						arrowStruct.toObj = node;
						node.inArrows.push( arrowStruct );
					}
				}

				graphStruct.arrows.push( arrowStruct );
				_arrows.push( arrowStruct );
			}

			_graphs.push( graphStruct );
		}

		_graphs.sortOn( "name" );

		initGraph = _initGraph;
		graphs = _graphs;
		nodes = _nodes;
		arrows = _arrows;

		init();
	}
	
	private function get currentTemplate() : Template
	{
		return ContextManager.currentTemplate;
	}

	public function get curGraphContext() : GraphContext
	{
		if ( contextStack.length )
			return GraphContext( contextStack[contextStack.length - 1] );
		return null;
	}

	public function get prevGraphContext() : GraphContext
	{
		if ( contextStack.length > 1 )
			return GraphContext( contextStack[contextStack.length - 2] );
		return null;
	}

	public function get curNodeContext() : NodeContext
	{
		if ( curGraphContext.contextStack.length )
			return NodeContext( curGraphContext.contextStack[curGraphContext.contextStack.length - 1] );
		else if ( contextStack.length > 1 )
			return NodeContext( prevGraphContext.contextStack[prevGraphContext.contextStack.length - 1] );
		return null;
	}

	public function validate( options : uint = 0 ) : Object
	{
		var retVal : Object = {result : false, array : []};
		var arr : Array = [];
		var i : int;
		var j : int;
		var k : int;
		var o : int;

		if ( !tplStructXML )
		{
			return retVal;
		}

		if ( !initGraph )
		{
			if ( options & TemplateValidateOptions.SET_INIT_GRAPH )
			{
				if ( graphs.length > 0 )
				{
					initGraph = graphs[0];
					initGraph.bInitial = true;
					contextStack.unshift( new GraphContext( initGraph ) );
				}
			}
			else
				arr.push( { error : new ValidationError( null, 9001 ), graph : null, node : null, arrow : null } );
		}

		// VALIDATE GRAPHS

		var initCount : int = 0;
		var initGraphs : String = "";
		var duplCount : int = 0;
		for ( i = 0; i < graphs.length; i++ )
		{
			var curGraph : GraphStruct = graphs[i] as GraphStruct;

			// validate name

			if ( !curGraph.name )
				arr.push( { error : new ValidationError( null, 9006 ),
					graph : curGraph, node : null, arrow : null } );

			if ( CodeParser.ParseSubgraphNode( curGraph.name ).error )
				arr.push( { error : new ValidationError( null, 9100 ),
					graph : curGraph, node : null, arrow : null } );

			// initial graph count			
			if ( curGraph.bInitial )
			{
				initCount++;
				initGraphs += (initGraphs ? "," : "") + '[' + curGraph.name + ']';
			}

			// check for duplicated graph names
			if ( i < graphs.length - 1 )
			{
				for ( j = i + 1; j < graphs.length; j++ )
				{
					if ( curGraph.name == graphs[j].name )
						arr.push( { error : new ValidationWarning( null, 9005, [graphs[j].name] ),
							graph : graphs[j], node : null, arrow : null } );
				}
			}

			// check for init node for graph
			if ( !curGraph.initNode )
			{
				arr.push( { error : new ValidationWarning( null, 9002, [curGraph.name] ),
					graph : curGraph, node : null, arrow : null } );
			}
		}

		if ( initCount > 1 )
			arr.push( { error : new ValidationError( null, 9003, [initGraphs] ),
				graph : null, node : null, arrow : null } );

		// VALIDATE NODES

		// check for duplicated node ids
		for ( i = 0; i < nodes.length - 1; i++ )
		{
			if ( !nodes[i].id )
				arr.push( { error : new ValidationWarning( null, 9205 ),
					graph : null, node : null, arrow : null } );

			if ( i < nodes.length - 1 )
			{
				for ( j = i + 1; j < nodes.length; j++ )
				{
					if ( nodes[i].id == nodes[j].id )
						arr.push( { error : new ValidationWarning( null, 9200, [nodes[j].id] ),
							graph : null, node : null, arrow : null } );
				}
			}
		}

		for ( i = 0; i < graphs.length; i++ )
		{
			initCount = 0;
			curGraph = graphs[i] as GraphStruct;

			for ( j = 0; j < curGraph.nodes.length; j++ )
			{
				var curNode : NodeStruct = curGraph.nodes[j];

				// initial node count
				if ( curNode.type == NodeType.INITIAL )
				{
					initCount++;
				}

				var parsedBlock : ParsedBlock;

				switch ( curNode.category )
				{
					case NodeCategory.NORMAL:
						parsedBlock = CodeParser.ParseText( curNode.text );
						break;

					case NodeCategory.SUBGRAPH:
						parsedBlock = CodeParser.ParseSubgraphNode( curNode.text );
						break;

					case NodeCategory.COMMAND:
						parsedBlock = CodeParser.ParseCode( curNode.text );
						break;
				}

				if ( parsedBlock && parsedBlock.error )
				{
					arr.push( { error : parsedBlock.error,
						graph : curGraph, node : curNode, arrow : null } );
				}
				else if ( parsedBlock && parsedBlock.errFragment )
				{
					arr.push( { error : parsedBlock.errFragment.error,
						graph : curGraph, node : curNode, arrow : null } );
				}

				switch ( curNode.category )
				{
					case NodeCategory.SUBGRAPH:
						var isExist : Boolean = false;
						for each ( var graph : GraphStruct in graphs )
						{
							if ( graph.name == curNode.text )
							{
								isExist = true;
								break;
							}
						}
						if ( !isExist )
							arr.push( { error : new ValidationWarning( null, 9006, [curNode.text] ),
								graph : curGraph, node : curNode, arrow : null } );
						break;

					case NodeCategory.COMMAND:
						if ( parsedBlock.ctype == CodeFragment.CT_TEST )
						{
							var isIdentTrans : Boolean = true;
							var trans : Object;
							for each ( var outArrow : ArrowStruct in curNode.outArrows )
							{
								if ( !trans )
									trans = outArrow.label;

								if ( trans != outArrow.label )
								{
									isIdentTrans = false;
									break;
								}
							}
							if ( isIdentTrans && curNode.outArrows.length > 1 )
								arr.push( { error : new ValidationWarning( "All transitions have same value" ),
									graph : curGraph, node : curNode, arrow : null } );
						}
						break;
				}

			}

			if ( initCount > 1 )
				arr.push( { error : new ValidationWarning( null, 9004, [curGraph.name] ),
					graph : curGraph, node : null, arrow : null } );
		}

		// VALIDATE ARROWS

		for ( i = 0; i < arrows.length; i++ )
		{
			// undefined id
			if ( !arrows[i].id )
				arr.push( { error : new ValidationWarning( null, 9206 ),
					graph : null, node : null, arrow : null } );

			// self-loop checking
			if ( arrows[i].fromObj && arrows[i].fromObj == arrows[i].toObj )
				arr.push( { error : new ValidationWarning( null, 9203, [arrows[i].id, arrows[i].fromObj.id] ),
					graph : null, node : null, arrow : null } );

			// 
			if ( arrows[i].fromObj && arrows[i].toObj &&
					arrows[i].fromObj.graph != arrows[i].toObj.graph )
				arr.push( { error : new ValidationWarning( 'Transition links states from different graphs', 9204, [arrows[i].id] ),
					graph : null, node : null, arrow : null } );
			//
			if ( !arrows[i].fromObj || !arrows[i].toObj )
				arr.push( { error : new ValidationWarning( 'One of end-point state is not defined', 9204, [arrows[i].id] ),
					graph : null, node : null, arrow : null } );

			if ( i < arrows.length - 1 )
			{
				for ( j = i + 1; j < arrows.length; j++ )
				{
					// check for duplicated arrow ids
					if ( arrows[i].id == arrows[j].id )
						arr.push( { error : new ValidationWarning( null, 9201, [arrows[j].id] ),
							graph : null, node : null, arrow : null } );

					// check for multiple transitions
					if ( arrows[i].fromObj && arrows[i].toObj &&
							(arrows[i].fromObj == arrows[j].fromObj && arrows[i].toObj == arrows[j].toObj ||
									arrows[i].fromObj == arrows[j].toObj && arrows[i].toObj == arrows[j].fromObj)
							)
						arr.push( { error : new ValidationWarning( null, 9202, [arrows[i].fromObj.id, arrows[i].toObj.id] ),
							graph : null, node : null, arrow : null } );
				}
			}
		}

		retVal.result = true;
		retVal.array = arr;
		//retVal.xml = getXML();
		return retVal;
	}

	public function createUID( objects : Object, prop : String = null, prefix : String = "" ) : String
	{
		if ( !prefix )
			prefix = "";

		var elm : Object;

		uidloop:do
		{
			var uid : String = prefix + UIDUtil.createUID().replace( /-/g, "_" );

			if ( objects is Array )
			{
				for each ( elm in objects as Array )
				{
					if ( prop && elm.hasOwnProperty( prop ) )
						elm = elm[prop];

					if ( uid == elm.toString() )
						continue uidloop;
				}
			}
			else
			{
				if ( objects.hasOwnProperty( uid ) )
					continue uidloop;
			}

			break;

		} while ( true );

		return uid;
	}

	public function init() : void
	{
		clear();

		var graphContext : GraphContext;

		if ( initGraph )
		{
			graphContext = new GraphContext( initGraph );
			contextStack.push( graphContext );
		}

		if ( !lib )
			lib = new TemplateLib();

		lib.tplStruct = this;
		context[CNTXT_INSTANCE] = lib;
		
		lib.addEventListener( TemplateLibEvent.PROGRESS, setProgerssHendler);
		
		function setProgerssHendler( event : TemplateLibEvent ):void
		{
			dispatchEvent( event );
		}
	}

	public function clear() : void
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

	public function generate( force : Boolean = false, over : Boolean = false, ret : Boolean = false ) : String
	{
		try 
		{
			if ( terminated )
			{
				return null;
				terminated = false;
			}
	
			if ( isRunning )
			{
				//Application.application.callLater(generate, [force, over, ret]);
				return null;
			}
			isRunning = true;
	
			if ( buffer )
			{
				isRunning = false;
				return buffer;
			}
	
			if ( !initGraph )
			{
				isRunning = false;
				throw new ValidationError( null, 9001 );
			}
			
			if ( over )
				forced = 0;
	
			if ( ret )
				forced = 1;
	
			do
			{
				// check for current node	
				if ( !curGraphContext.curNode )
				{
					isRunning = false;
					throw new ValidationError( null, 9002, [curGraphContext.curGraph.name] );
				}
	
				switch ( step )
				{
					case 'parseNewNode': // parse current node
	
						if ( forced > 0 || over )
							force = true;
	
						dispatchEvent( new Event( "processNode" ) );
	
						if ( isStepDebug && !force )
						{
							dispatchEvent( new Event( EVENT_STEP_COMPLETE ) );
							isRunning = false;
							forced = -1;
							return null;
						}
	
						if ( isDebug && !force && curGraphContext.curNode.breakpoint )
						{
							dispatchEvent( new Event( EVENT_STEP_COMPLETE ) );
							isRunning = false;
							forced = -1;
							return null;
						}
	
						force = false;
						over = false;
	
						////////////////////////////////////////////////////////////////////
	
						if ( curGraphContext.curNode.enabled )
						{
							curGraphContext.contextStack.push( new NodeContext( curGraphContext.curNode, null ) );
	
							switch ( curGraphContext.curNode.category )
							{
								case NodeCategory.NORMAL:
	
									curNodeContext.block = CodeParser.ParseText(
											curGraphContext.curNode.text );
									break;
	
								case NodeCategory.RESOURCE:
	
	//								var resData : ByteArray = CashManager.getObject( ID, curGraphContext.curNode.text ).data;
	//
	//								curNodeContext.block = new ParsedBlock();
	//								curNodeContext.block.print = true;
	//								curNodeContext.block.retValue = resData.readUTFBytes( resData.length );
	//								curNodeContext.block.executed = true;
									break;
	
								case NodeCategory.SUBGRAPH:
	
									curNodeContext.block = CodeParser.ParseSubgraphNode(
											curGraphContext.curNode.text );
	
									if ( curNodeContext.block.error )
									{
										isRunning = false;
										throw new ValidationError( null, 9000 );
									}
									else
									{
										curNodeContext.block = CodeParser.ParseCode(
												'[sub ' + curGraphContext.curNode.text + ']' );
									}
									break;
	
								case NodeCategory.COMMAND:
									curNodeContext.block = CodeParser.ParseCode( curGraphContext.curNode.text );
									break;
	
							}
	
							curNodeContext.block.varPrefix = curGraphContext.varPrefix;
	
							if ( curNodeContext.block.error && curNodeContext.block.errFragment )
							{
								isRunning = false;
								if ( curNodeContext.block.error )
								{
									throw curNodeContext.block.error;
								}
								else if ( curNodeContext.block.errFragment )
								{
									throw curNodeContext.block.errFragment.error;
								}
								else
								{
									throw new RunTimeError( MSG_PARSE_ERR, -1,
											[curGraphContext.curNode.graph.name,
												curGraphContext.curNode.text] );
								}
							}
						}
	
					case 'executeCode':
	
						if ( curNodeContext.block )
						{
							if ( !curNodeContext.block.executed )
							{
								// TODO : block run menu
	//							MenuGeneral.updateMenuState(MenuGeneral.MENU_RUN, false);
								step = 'processExecResult';
	
								CodeParser.executeBlock(
										curNodeContext.block,
										[context, curGraphContext.context],
										true );
	
								if ( curNodeContext.block.lastExecutedFragment.retValue is Function )
								{
									isRunning = false;
									return null;
								}
							}
						}
	
					case 'processExecResult':
	
						if ( curNodeContext.block )
						{
							var lastExecFrag : CodeFragment = curNodeContext.block.lastExecutedFragment;
	
							if ( lastExecFrag )
							{
								if ( lastExecFrag.print )
									curGraphContext.buffer += lastExecFrag.retValue + " ";
	
								transition = lastExecFrag.transition;
	
								if ( lastExecFrag.trans.length )
								{
									if ( !transition )
										transition = lastExecFrag.retValue;
								}
							}
							else
							{
								if ( curNodeContext.block.print )
									curGraphContext.buffer += curNodeContext.block.retValue + " ";
							}
	
							if ( !curNodeContext.block.executed )
							{
								step = 'executeCode';
								continue;
							}
							
							//TODO : unblock
	//						MenuGeneral.updateMenuState(MenuGeneral.MENU_RUN, true);
						}
	
					case 'getNextNode': // transition to next node
	
						var index : int = GetArrowIndex( curGraphContext.curNode.outArrows, transition );
						transition = null;
	
						if ( index == -1 ||
								curGraphContext.curNode.type == NodeType.TERMINAL )
						{
	
							var tmpBuf : String = curGraphContext.buffer;
	
							forced--;
							contextStack.pop();
	
							if ( contextStack.length > 0 )
							{
								curNodeContext.block.lastExecutedFragment.retValue =
										tmpBuf;
	
								context[curNodeContext.block.lastExecutedFragment.retVarName] =
										curNodeContext.block.lastExecutedFragment.retValue;
	
								step = 'processExecResult';
	
								continue;
							}
	
							if ( contextStack.length == 0 )
								break;
						}
						else
						{
							nodeStack.push( curNodeContext );
						}
	
						// select next node
						curGraphContext.curNode =
								ArrowStruct( curGraphContext.curNode.outArrows[index] ).toObj;
	
						step = 'parseNewNode';
				}
			} while ( contextStack.length > 0 );
	
			// replace special sequences
			buffer = Utils.replaceEscapeSequences( tmpBuf, "\\-" );
	
			isRunning = false;
	
			dispatchEvent( new Event( EVENT_GENERATION_COMPLETE ) );
	
			return buffer;

		} 
		catch (e:Error) {
			error = e;
			isRunning = false;
			dispatchEvent(new Event(EVENT_ERROR));
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
	 */
	private static function GetArrowIndex( arrows : Array, transition : String ) : int
	{
		var indexes : Array = new Array();
		var index : int = -1;

		if ( arrows && arrows.length > 0 )
		{
			for ( var i : int = 0; i < arrows.length; i++ )
			{
				if ( (transition && ArrowStruct( arrows[i] ).label == transition
						|| !transition) && ArrowStruct( arrows[i] ).enabled )
					indexes.push( i );
			}
			if ( indexes.length > 0 )
				index = indexes[ Math.round( Math.random() * (indexes.length - 1) ) ];
		}
		return index;
	}

}
}