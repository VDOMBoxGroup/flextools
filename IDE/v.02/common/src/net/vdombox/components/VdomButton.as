package net.vdombox.components
{
	import net.vdombox.view.skins.VdomButtonSkin;
	
	import spark.components.Button;

	public class VdomButton extends Button
	{
		public function VdomButton()
		{
			super();
			_icon = null;
			minHeight = 29;
			height = 29;
		}
		
		private var _icon : Object;
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", VdomButtonSkin );
		}

		public function get icon():Object
		{
			return _icon;
		}

		public function set icon(value:Object):void
		{
			_icon = value;
		}
		
		public function setIcon () : void
		{
			if (skin is VdomButtonSkin)
			{
				if ( _icon )
					(skin as VdomButtonSkin).icon.source = _icon;
				else
					(skin as VdomButtonSkin).icon.includeInLayout = false;
			}
		}

		
	}
}