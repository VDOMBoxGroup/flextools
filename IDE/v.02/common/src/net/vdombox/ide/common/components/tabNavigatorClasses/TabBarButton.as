package net.vdombox.ide.common.components.tabNavigatorClasses
{
	import flash.events.Event;
	import flash.events.MouseEvent;

	import mx.events.ListEvent;

	import spark.components.Button;
	import spark.components.ButtonBarButton;

	public class TabBarButton extends ButtonBarButton
	{
		public static const CLOSE_TAB : String = "closeTab";

		[SkinPart( required="true" )]
		public var closeButton : Button;
		
		private var _closeIncluded : Boolean = true;
		
		public function get canClose() : Boolean
		{
			return _closeIncluded;
		}

		public function set canClose( value : Boolean ) : void
		{
			_closeIncluded = value;
			skin.invalidateDisplayList();
		}

		override protected function partAdded( partName : String, instance : Object ) : void
		{
			super.partAdded( partName, instance );

			if ( instance == closeButton )
				closeButton.addEventListener( MouseEvent.CLICK, closeButton_clickHandler, false, 0, true );
		}

		override protected function partRemoved( partName : String, instance : Object ) : void
		{
			super.partRemoved( partName, instance );

			if ( instance == closeButton )
				closeButton.removeEventListener( MouseEvent.CLICK, closeButton_clickHandler, false );
		}

		private function closeButton_clickHandler( event : MouseEvent ) : void
		{
			event.stopImmediatePropagation();
			
			dispatchEvent( new ListEvent( CLOSE_TAB, true, false, -1, itemIndex ) );
		}

	}
}