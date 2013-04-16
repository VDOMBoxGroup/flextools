package net.vdombox.powerpack.graph
{

import flash.events.Event;

public class GraphCanvasEvent extends Event
{
	public static const DISPOSED : String = "disposed";
	public static const ADDING_TRANSITION : String = "addingTransition";

	public static const NAME_CHANGED : String = "nameChanged";
	public static const INITIAL_CHANGED : String = "initialChanged";
	public static const CATEGORY_CHANGED : String = "categoryChanged";
	public static const GRAPH_CHANGED : String = "graphChanged";
	
	public static const JUMP_TO_GRAPH : String = "jumpToGraph";
	
	public static const SELECT_ALL : String = "selectAll";
	
	public static const SELECTION_CHANGED : String = "selectionChanged";
	
	
	public var graphToJumpName : String = "";
	
	public function GraphCanvasEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false )
	{
		super( type, bubbles, cancelable );
	}

}
}