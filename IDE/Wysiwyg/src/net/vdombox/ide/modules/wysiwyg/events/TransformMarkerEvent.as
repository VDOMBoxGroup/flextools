package net.vdombox.ide.modules.wysiwyg.events
{

	import flash.events.Event;
	
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.vo.RendererCoordinateAndSizeVO;

	public class TransformMarkerEvent extends Event
	{

		public static const TRANSFORM_MARKER_SELECTED : String = "markerSelected";

		public static const TRANSFORM_MARKER_UNSELECTED : String = "markerUnSelected";

		public static const TRANSFORM_CHANGING : String = "transformСhanging";

		public static const TRANSFORM_BEGIN : String = "transformBegin";

		public static const TRANSFORM_COMPLETE : String = "transformComplete";

		public var properties : RendererCoordinateAndSizeVO;

		public var renderer : IRenderer;

		public function TransformMarkerEvent( type : String, bubbles : Boolean = false, cancelable : Boolean = false, renderer : IRenderer = null, properties : RendererCoordinateAndSizeVO = null ) : void
		{

			super( type, bubbles, cancelable );

			this.properties = properties;
			this.renderer = renderer;
		}

		override public function clone() : Event
		{

			return new TransformMarkerEvent( type, bubbles, cancelable, renderer, properties );
		}
	}
}
