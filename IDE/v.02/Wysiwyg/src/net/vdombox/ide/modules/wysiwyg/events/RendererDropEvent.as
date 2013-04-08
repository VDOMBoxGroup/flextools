package net.vdombox.ide.modules.wysiwyg.events
{
	import flash.events.Event;
	import flash.geom.Point;

	import net.vdombox.ide.common.model._vo.TypeVO;

	public class RendererDropEvent extends Event
	{
		public static var DROP : String = "drop";

		public function RendererDropEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = true, typeVO : TypeVO = null, point : Point = null )
		{
			super( type, bubbles, cancelable );

			this.typeVO = typeVO;
			this.point = point;
		}

		public var typeVO : TypeVO;

		public var point : Point;

		override public function clone() : Event
		{
			return new RendererDropEvent( type, bubbles, cancelable, typeVO, point );
		}
	}
}
