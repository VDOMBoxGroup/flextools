package net.vdombox.components
{
	import net.vdombox.view.skins.VDOMButtonSkin;

	import spark.components.Button;

	public class VDOMButton extends Button
	{
		public function VDOMButton()
		{
			super();
			
			_icon = null;
			
			minHeight = 29;
			height = 29;
		}

		private var _icon : Object;

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();

			this.setStyle( "skinClass", VDOMButtonSkin );
		}

		public function get icon() : Object
		{
			return _icon;
		}

		public function set icon( value : Object ) : void
		{
			_icon = value;
		}

		public function setIcon() : void
		{
			if ( !vdomButtonSkin )
				return;

			if ( _icon )
				vdomButtonSkin.icon.source = _icon;
			else
				vdomButtonSkin.icon.includeInLayout = false;
		}

		private function get vdomButtonSkin() : VDOMButtonSkin
		{
			return skin as VDOMButtonSkin;
		}
	}
}
