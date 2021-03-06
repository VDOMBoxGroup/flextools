package net.vdombox.ide.common.view.components.button
{
	import net.vdombox.ide.common.view.skins.button.WorkAreaButtonSkin;

	import spark.components.Button;

	public class WorkAreaButton extends Button
	{
		public function WorkAreaButton()
		{
			super();

			setStyle( "skinClass", net.vdombox.ide.common.view.skins.button.WorkAreaButtonSkin );
		}

		[Bindable]
		public var icon : Object;

		[Bindable]
		public var backgroundDownColor : uint = 0xd2d2d2;

		[Bindable]
		public var iconDown : Class;

		[Bindable]
		public var textDownColor : uint = 0x000000;

		private var _highlighted : Boolean;

		public function get highlighted() : Boolean
		{
			return _highlighted;
		}

		public function set highlighted( value : Boolean ) : void
		{
			_highlighted = value;

			invalidateSkinState();
		}

		override protected function getCurrentSkinState() : String
		{
			if ( !_highlighted )
				return super.getCurrentSkinState();
			else
				return super.getCurrentSkinState() + "AndHighlighted";
		}
	}
}
