package net.vdombox.PowerPack.com.panel.graphsClasses
{
	import net.vdombox.PowerPack.com.graph.GraphCanvas;
	
	import flash.events.Event;
	
	public class GraphsAccordionEvent extends Event
	{
		public static const GRAPH_VALUE_CHECKED				: String = 'graphValueChecked';
		public static const GRAPH_VALUE_EDITING_COMPLETE	: String = 'graphValueEditingComplete';
		
		public static const SELECTED_GRAPH_CHANGED			: String = 'selectedGraphChanged';
		
		public static const CATEGORY_VALUE_CHECKED		: String = 'categoryValueChecked';
		public static const CATEGORY_EDITING_COMPLETE	: String = 'categoryEditingComplete';
		
		public static const TAB_CLOSING					: String = 'tabClosing';
		public static const TAB_CLOSE					: String = 'tabClose';
		public static const CAPTION_CHANGED				: String = 'captionChanged';
		
		public var graph : GraphCanvas;
		
		public function GraphsAccordionEvent(type:String, aGraph:GraphCanvas=null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			graph = aGraph;
		}
		
		override public function clone():Event
		{
			return new GraphsAccordionEvent( type, graph, bubbles, cancelable );
		}
		
		
	}
}