package net.vdombox.components
{
	import flash.events.KeyboardEvent;
	
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
		
		private var _select : Boolean = false;

		[Bindable]
		public function get select():Boolean
		{
			return _select;
		}

		public function set select(value:Boolean):void
		{
			_select = value;
		}

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
