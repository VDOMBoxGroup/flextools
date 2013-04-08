package net.vdombox.ide.modules.wysiwyg.events
{
	import com.zavoo.svg.nodes.SVGImageNode;

	import flash.events.Event;

	public class RendererEvent extends Event
	{
		public static var CREATED : String = "rendererCreated";

		//public static var REMOVED : String = "rendererRemoved";

		public static var RENDER_CHANGING : String = "rendererRenderChanging";

		public static var RENDER_CHANGED : String = "rendererRenderChanged";

		public static var GET_RESOURCE : String = "rendererGetResource";

		public static var MOUSE_DOWN : String = "rendererMouseDown";

		public static var CLICKED : String = "rendererClicked";

		public static var EDITED : String = "rendererEdited";

		public static var MOVE : String = "rendererMove";

		public static var TOOLTIP : String = "toolTip";

		public static var MOVED : String = "rendererMoved";

		public static var MOVE_MEDIATOR : String = "rendererMoveMediator";

		public static var MOUSE_UP_MEDIATOR : String = "rendererMouseUpMediator";

		public static var CLEAR_RENDERER : String = "clearRenderer";

		public static var HTML_ADDED : String = "rendererHTMLAdded";

		public static var COPY_SELECTED : String = "copySelected";

		public static var PASTE_SELECTED : String = "pasteSelected";

		public static var MULTI_SELECTED_MOVE : String = "multiSelectedMove";

		public static var MULTI_SELECTED_MOVED : String = "multiSelectedMoved";

		public static var ATTRIBUTES_REFRESHED : String = "attributesRefreshed";

		public static var TRANSLATE_SVG_TEXT : String = "translateText";

		public var object : Object;

		public var ctrlKey : Boolean;

		public var shiftKey : Boolean;

		public function RendererEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, shift : Boolean = false )
		{
			super( type, bubbles, cancelable );
			shiftKey = shift;
		}

		override public function clone() : Event
		{
			return new RendererEvent( type, bubbles, cancelable );
		}
	}
}
