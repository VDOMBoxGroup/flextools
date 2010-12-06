package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;

	public class EditorEvent extends Event
	{
		public static var CREATED : String = "editorCreated";
		public static var REMOVED : String = "editorRemoved";
		
		public static var OBJECT_CHANGED : String = "objectChanged";
		
		public static var XML_EDITOR_OPENED : String = "xmlEditorOpened";
		public static var WYSIWYG_OPENED : String = "wysiwygOpened";
		
		public static var XML_SAVE : String = "xmlSave";
		
		public static var RENDERER_TRANSFORMED : String = "editorRendererTransformed";

		public function EditorEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, renderer : IRenderer = null,
									 attributes : Object = null )
		{
			super( type, bubbles, cancelable );
			
			this.renderer = renderer;
			this.attributes = attributes;
		}

		public var renderer : IRenderer;
		public var attributes : Object;
		
		override public function clone() : Event
		{
			return new EditorEvent( type, bubbles, cancelable, renderer, attributes );
		}
	}
}