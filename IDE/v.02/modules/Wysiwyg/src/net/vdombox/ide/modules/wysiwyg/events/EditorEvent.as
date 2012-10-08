package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;
	
	import net.vdombox.ide.common.model._vo.VdomObjectAttributesVO;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;

	public class EditorEvent extends Event
	{
		public static var PREINITIALIZED : String = "editorPreinitialized";
		public static var REMOVED : String = "editorRemoved";
		
		public static var VDOM_OBJECT_VO_CHANGED : String = "objectChanged";
		
		public static var ATTRIBUTES_CHANGED : String = "attributesChanged";
		
		public static var XML_EDITOR_OPENED : String = "xmlEditorOpened";
		public static var WYSIWYG_OPENED : String = "wysiwygOpened";
		
		public static var XML_SAVE : String = "xmlSave";
		
		public static var UNDO : String = "undo";
		public static var REDO : String = "redo";
		public static var REFRESH : String = "refresh";
		
		public static var RENDERER_TRANSFORMED	: String = "editorRendererTransformed";
		
		public function EditorEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, renderer : IRenderer = null,
									 attributes : Object = null )
		{
			super( type, bubbles, cancelable );
			
			this.renderer = renderer;
			this.attributes = attributes;
		}

		public var renderer : IRenderer;
		public var attributes : Object;
		public var vdomObjectAttributesVO : VdomObjectAttributesVO;
		
		override public function clone() : Event
		{
			return new EditorEvent( type, bubbles, cancelable, renderer, attributes );
		}
	}
}