package net.vdombox.components.xmldialogeditor.events
{
	import flash.events.Event;
	
	import net.vdombox.components.xmldialogeditor.model.vo.components.base.ComponentBase;
	
	public class VisualItemRendererEvent extends Event
	{
		public static const CLICK : String = "visualItemRendererClick";
		public static const REMOVE : String = "visualItemRendererRemove";
		
		private var _componentBase : ComponentBase;
		
		public function VisualItemRendererEvent(type:String, componentBase : ComponentBase, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			
			this.componentBase = componentBase;
		}

		public function get componentBase():ComponentBase
		{
			return _componentBase;
		}

		public function set componentBase(value:ComponentBase):void
		{
			_componentBase = value;
		}

	}
}