package net.vdombox.ide.modules.wysiwyg.view.components.controls
{
	import mx.controls.Image;
	
	import net.vdombox.ide.modules.wysiwyg.view.skins.ToolbarButtonSkin;
	
	import spark.components.ToggleButton;

	public class ToolbarButton extends ToggleButton
	{
		import mx.core.IFactory;

		public function ToolbarButton()
		{
			super();
			//setStyle( "skinClass", ToolbarButtonSkin );
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ToolbarButtonSkin );
		}


		private var _iconPart : Image;

		[SkinPart( required="true" )]
		public function get iconPart() : Image
		{
			return _iconPart;
		}

		public function set iconPart( value : Image ) : void
		{
			_iconPart = value;
			
			if( _icon )
				_iconPart.source = _icon;
		}

		private var _icon : Class;

		public function get icon() : Class
		{
			return _icon;
		}

		public function set icon( value : Class ) : void
		{
			_icon = value;

			if ( iconPart )
				iconPart.source = value;
		}
	}
}