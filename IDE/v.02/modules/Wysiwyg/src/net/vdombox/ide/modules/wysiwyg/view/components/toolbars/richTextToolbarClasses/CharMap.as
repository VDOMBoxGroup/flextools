package net.vdombox.ide.modules.wysiwyg.view.components.toolbars.richTextToolbarClasses
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.containers.Grid;
	import mx.containers.GridItem;
	import mx.containers.GridRow;
	import mx.controls.Label;
	import mx.controls.Text;
	import mx.managers.PopUpManager;
	
	import spark.components.TitleWindow;
	


	public class CharMap extends TitleWindow
	{
		public static const EVENT_CHAR_SELECTED : String = "charSelected";
		
		
		public function CharMap()
		{
		}
		

		[SkinPart( required="true" )]
		public var charGrid : Grid;
		
		[SkinPart( required="true" )]
		public var preview : Label;
		
		[SkinPart( required="true" )]
		public var description : Text;
		
		[SkinPart( required="true" )]
		public var htmlCode : Label;
		
		[SkinPart( required="true" )]
		public var numCode : Label;
		
		
		include 'charMapArray.as'
		
		private var _charCode : String;
		
		private var selectedItem : GridItem;
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", CharMapSkin );
		}
		
		public function get charCode() : String
		{
			
			return _charCode;
		}
		
		public function init() : void
		{
			setFocus();
			addHandlers();
			
			var charsPerRow : uint = 20, tdWidth : uint = 20, tdHeight : uint = 20;
			var gridRow : GridRow, gridItem : GridItem;
			var charMapLength : uint = charmap.length;
			
			gridRow = new GridRow();
			charGrid.addChild( gridRow );
			
			var cols : uint = 0;
			var charLabel : Label;
			for ( var i : uint = 0; i < charMapLength; i++ )
			{
				
				if ( !charmap[ i ][ 2 ] )
					continue;
				
				gridItem = new GridItem();
				gridItem.width = tdWidth;
				gridItem.height = tdHeight;
				gridItem.setStyle( 'backgroundColor', '#ffffff' );
				gridItem.setStyle( 'backgroundAlpha', .4 );
				gridItem.buttonMode = true;
				gridItem.data = charmap[ i ];
				
				gridRow.addChild( gridItem );
				
				charLabel = new Label();
				charLabel.percentWidth = 100;
				charLabel.htmlText = charmap[ i ][ 1 ];
				charLabel.setStyle( 'fontFamily', 'Courier' );
				charLabel.setStyle( 'fontSize', '13' );
				charLabel.setStyle( "textAlign", "center" );
				
				gridItem.addChild( charLabel );
				
				cols++;
				
				if ( cols % charsPerRow == 0 )
				{
					
					gridRow = new GridRow();
					charGrid.addChild( gridRow );
				}
			}
			
		}
		
		private function addHandlers() : void
		{
			addEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function removeHandlers() : void
		{
			removeEventListener(KeyboardEvent.KEY_DOWN, onKeyDown);
		}
		
		private function onKeyDown(keyEvent : KeyboardEvent):void
		{
			switch(keyEvent.keyCode)
			{
				case Keyboard.ESCAPE:
				{
					keyEvent.stopImmediatePropagation();
					
					closeHandler();
					break;
				}
			}
			
		}
		
		public function getElementByClass( target : DisplayObject, classElement : Class, container : DisplayObjectContainer ) : DisplayObject
		{
			
			var returnObject : DisplayObject;
			
			while ( target )
			{
				
				if ( returnObject == container )
					break;
				
				if ( target is classElement )
				{
					
					returnObject = target;
					break;
				}
				
				if ( target.parent )
					target = target.parent;
				else
					target = null;
			}
			
			return returnObject;
		}
		
		public function mouseOverHandler( event : MouseEvent ) : void
		{
			
			var target : DisplayObject = DisplayObject( event.target );
			
			if ( selectedItem )
			{
				
				selectedItem.setStyle( 'backgroundColor', '#ffffff' );
				preview.htmlText = '';
				description.text = '';
				htmlCode.text = '';
				numCode.text = '';
			}
			
			selectedItem = GridItem( getElementByClass( target, GridItem, charGrid ) );
			
			if ( selectedItem )
			{
				
				selectedItem.setStyle( 'backgroundColor', '#606085' );
				preview.htmlText = selectedItem.data[ 1 ];
				description.text = selectedItem.data[ 3 ];
				htmlCode.text = selectedItem.data[ 0 ];
				numCode.text = selectedItem.data[ 1 ];
			}
			
			
		}
		
		public function mouseClickHandler( event : MouseEvent ) : void
		{
			
			var target : DisplayObject = DisplayObject( event.target );
			
			var currentElement : GridItem = GridItem( getElementByClass( target, GridItem, charGrid ) );
			
			if ( currentElement )
			{
				
				_charCode = currentElement.data[ 1 ].toString();
				dispatchEvent( new Event( EVENT_CHAR_SELECTED ) );
				
				closeHandler();
			}
		}
		
		public function closeHandler(event:Event = null) : void
		{
			removeHandlers();
			
			PopUpManager.removePopUp( this );
		}
		
	}
}