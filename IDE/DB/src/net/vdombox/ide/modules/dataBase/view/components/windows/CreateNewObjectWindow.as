package net.vdombox.ide.modules.dataBase.view.components.windows
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.KeyboardEvent;

	import mx.collections.ArrayCollection;

	import net.vdombox.ide.common.events.PopUpWindowEvent;
	import net.vdombox.ide.common.model._vo.TypeVO;
	import net.vdombox.ide.modules.dataBase.view.skins.CreateNewObjectWindowSkin;

	import spark.components.DropDownList;
	import spark.components.TextInput;
	import spark.components.Window;

	public class CreateNewObjectWindow extends Window
	{
		private var _dataBases : ArrayCollection;

		[SkinPart( required = "true" )]
		public var objectName : TextInput;

		[SkinPart( required = "true" )]
		public var baseName : DropDownList;

		[Bindable]
		public var typeVO : TypeVO;

		public function CreateNewObjectWindow()
		{
			super();

			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;

			width = 400;
			height = 110;

			minWidth = 400;
			minHeight = 110;

			dataBases = new ArrayCollection();

			this.setFocus();
		}

		[Bindable]
		public function get dataBases() : ArrayCollection
		{
			return _dataBases;
		}

		public function set dataBases( value : ArrayCollection ) : void
		{
			if ( !value )
				return;
			_dataBases = value;
		}

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", CreateNewObjectWindowSkin );
		}

		public function ok_close_window( event : KeyboardEvent = null ) : void
		{
			if ( typeVO.container != 3 )
				dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.APPLY, baseName.selectedItem, objectName.text ) );
			else
				dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.APPLY, null, objectName.text ) );
		}

		public function no_close_window( event : KeyboardEvent = null ) : void
		{
			dispatchEvent( new PopUpWindowEvent( PopUpWindowEvent.CANCEL ) );

		}
	}
}
