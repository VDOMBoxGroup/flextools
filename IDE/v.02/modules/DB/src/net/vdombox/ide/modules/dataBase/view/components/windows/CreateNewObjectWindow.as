package net.vdombox.ide.modules.dataBase.view.components.windows
{
	import flash.events.KeyboardEvent;
	
	import mx.collections.ArrayCollection;
	
	import net.vdombox.ide.common.vo.TypeVO;
	import net.vdombox.ide.modules.dataBase.events.CreateNewObjectEvent;
	import net.vdombox.ide.modules.dataBase.view.skins.CreateNewObjectWindowSkin;
	
	import spark.components.DropDownList;
	import spark.components.TextInput;
	import spark.components.Window;

	public class CreateNewObjectWindow extends Window
	{
		private var _dataBases : ArrayCollection;
		
		[SkinPart( required="true" )]
		public var objectName : TextInput;
		
		[SkinPart( required="true" )]
		public var baseName : DropDownList;
		
		[Bindable]
		public var typeVO : TypeVO;
		
		[Bindable]
		public var types : ArrayCollection;
		
		public function CreateNewObjectWindow()
		{
			super();
			
			width = 500;
			height = 300;
			
			minWidth = 500;
			minHeight = 300;
			
			dataBases = new ArrayCollection();
			
			this.setFocus();
		}
		
		public function setTypes( _types : Array ) : void
		{
			types = new ArrayCollection();
			
			var _typeVO : TypeVO;
			for each ( _typeVO in _types )
			{
				if ( _typeVO.container == 3 )
					types.addItemAt( _typeVO, 0 );
				else
					types.addItem( _typeVO );
			}
		}
		
		[Bindable]
		public function get dataBases():ArrayCollection
		{
			return _dataBases;
		}

		public function set dataBases(value:ArrayCollection):void
		{
			if ( !value )
				return;
			_dataBases = value;
		}

		override public function stylesInitialized():void 
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", CreateNewObjectWindowSkin );
		}
		
		public function ok_close_window(event: KeyboardEvent = null ) : void
		{
			if ( typeVO.container != 3 )
				dispatchEvent( new CreateNewObjectEvent( CreateNewObjectEvent.APPLY, baseName.selectedItem, objectName.text ) );
			else
				dispatchEvent( new CreateNewObjectEvent( CreateNewObjectEvent.APPLY, null, objectName.text ) );
		}
		
		public function no_close_window(event: KeyboardEvent = null ) : void
		{
			dispatchEvent( new CreateNewObjectEvent( CreateNewObjectEvent.CANCEL ) );
			
		}
	}
}