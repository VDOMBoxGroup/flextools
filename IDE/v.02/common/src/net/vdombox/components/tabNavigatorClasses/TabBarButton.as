package net.vdombox.components.tabNavigatorClasses
{
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	import mx.binding.utils.BindingUtils;
	import mx.binding.utils.ChangeWatcher;
	import mx.events.ListEvent;
	
	import net.vdombox.view.skins.TabBarButtonSkin;
	
	import spark.components.Button;
	import spark.components.ButtonBarButton;

	public class TabBarButton extends ButtonBarButton
	{
		public static const CLOSE_TAB : String = "closeTab";

		public function TabBarButton() : void
		{
			setStyle( "skinClass", net.vdombox.view.skins.TabBarButtonSkin );
		}

		[SkinPart( required="true" )]
		public var closeButton : Button;

		private var _closeIncluded : Boolean = true;
		private var cw : ChangeWatcher;

		public function get canClose() : Boolean
		{
			return _closeIncluded;
		}

		public function set canClose( value : Boolean ) : void
		{
			_closeIncluded = value;

			if ( skin )
				skin.invalidateDisplayList();
		}

		override public function set data( value : Object ) : void
		{
			super.data = value;
			
			var tab : Tab = value as Tab;
			
			if( !tab )
				return;
			
			if( cw )
				cw.unwatch();
			
			cw = BindingUtils.bindProperty( this, "canClose", tab, "closable", false, true );
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