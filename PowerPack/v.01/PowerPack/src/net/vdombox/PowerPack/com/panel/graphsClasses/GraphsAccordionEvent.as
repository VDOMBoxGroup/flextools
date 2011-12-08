package net.vdombox.PowerPack.com.panel.graphsClasses
{
	import flash.events.Event;
	
	import net.vdombox.PowerPack.com.graph.GraphCanvas;
	
	public class GraphsAccordionEvent extends Event
	{
		public static const GRAPH_VALUE_ENTERED				: String = 'graphValueEntered';
		public static const GRAPH_VALUE_EDITING_COMPLETE	: String = 'graphValueEditingComplete';
		
		public static const SELECTED_GRAPH_CHANGED			: String = 'selectedGraphChanged';
		
		public static const CATEGORY_VALUE_CHECKED		: String = 'categoryValueChecked';
		public static const CATEGORY_EDITING_COMPLETE	: String = 'categoryEditingComplete';
		
		public static const TAB_CLOSING					: String = 'tabClosing';
		public static const TAB_CLOSE					: String = 'tabClose';
		
		public static const CAPTION_VALUE_ENTERED		: String = 'captionValueEntered';
		public static const CAPTION_CHANGED				: String = 'captionChanged';
		
		public var graph : GraphCanvas;
		public var accordHeader : AccordionHeader;
		
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