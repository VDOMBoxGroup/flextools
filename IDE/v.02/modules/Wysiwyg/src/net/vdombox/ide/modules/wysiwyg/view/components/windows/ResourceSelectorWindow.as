//------------------------------------------------------------------------------
//
//   Copyright 2011 
//   VDOMBOX Resaerch  
//   All rights reserved. 
//
//------------------------------------------------------------------------------

package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import flash.display.NativeWindowSystemChrome;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;

	import mx.collections.ArrayList;

	import net.vdombox.ide.common.events.ResourceVOEvent;
	import net.vdombox.ide.common.model._vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ResourceSelectorWindowSkin;
	import net.vdombox.utils.WindowManager;

	import spark.components.List;
	import spark.components.TextInput;
	import spark.components.Window;

	public class ResourceSelectorWindow extends Window
	{

		public function ResourceSelectorWindow()
		{
			super();

			systemChrome = NativeWindowSystemChrome.NONE;
			transparent = true;

			width = 790;
			height = 550;

			minWidth = 600;
			minHeight = 330;

			addHandlers();

		}

		[Bindable]
		public var _resources : ArrayList;

		public var deleteResourceID : String = null;

		[Bindable]
		public var filteredResources : int = 0;

		[Bindable]
		public var multiSelect : Boolean = false;

		[SkinPart( required = "true" )]
		public var nameFilter : TextInput;

		[SkinPart( required = "true" )]
		public var resourcesList : List;

		public var scrollToIndex : int = -1;

		public var selectedResourceIndex : int = -1;

		[Bindable]
		public var totalResources : int = 0;

		private var _value : String;

		public function addHandlers() : void
		{
			addEventListener( KeyboardEvent.KEY_DOWN, keyDownWindowHendler );
			addEventListener( Event.CLOSE, closeHandler );
		}

		public function addResource( resourceVO : ResourceVO ) : void
		{
			totalResources++;

			resources.addItem( resourceVO );

			selectedResourceIndex = scrollToIndex = resources.length - 1;

			invalidateProperties();
		}

		public function closeHandler( event : Event ) : void
		{
			removeEventListener( Event.CLOSE, closeHandler );
			WindowManager.getInstance().removeWindow( this );
		}

		public function apply( event : Event = null ) : void
		{
			dispatchEvent( new Event( Event.CHANGE ) );

			close();
		}



		public function previewResource( event : Event ) : void
		{
			dispatchEvent( new Event( ResourceVOEvent.PREVIEW_RESOURCE ) );
		}


		public function refreshFile( event : MouseEvent ) : void
		{
			dispatchEvent( new ResourceVOEvent( ResourceVOEvent.GET_RESOURCES ) );
		}

		public function removeKeyEvents() : void
		{
			removeEventListener( KeyboardEvent.KEY_DOWN, keyDownWindowHendler );
		}

		public function get resources() : ArrayList
		{
			return _resources;
		}

		public function set resources( value : ArrayList ) : void
		{
			_resources = value;

			setSelectedItem();
		}

		override public function stylesInitialized() : void
		{
			super.stylesInitialized();
			this.setStyle( "skinClass", ResourceSelectorWindowSkin );
		}




		public function uploadFile( event : MouseEvent ) : void
		{
			dispatchEvent( new ResourceVOEvent( ResourceVOEvent.LOAD_RESOURCE ) );
		}

		override public function validateDisplayList() : void
		{
			super.validateDisplayList();
			setFocus();
		}

		public function get value() : String
		{
			var resources : Array = [];

			for each ( var item : ResourceVO in resourcesList.selectedItems )
			{
				if ( item != null )
					resources.push( "#Res(" + item.id + ")" );
			}

			return resources.toString();
		}

		public function set value( value : String ) : void
		{
			_value = value;
			setSelectedItem();

		}

		override protected function commitProperties() : void
		{
			super.commitProperties();

			if ( deleteResourceID )
			{
				var selInd : uint = resourcesList.selectedIndex;

				resources.source = arrayWithoutResource( deleteResourceID );

				//totalResources = resources.length-1;					

				if ( resources.length > 1 && selInd > 1 )
				{
					selInd = ( selInd > 0 ) ? selInd - 1 : 0;

					selectedResourceIndex = selInd;
					scrollToIndex = selInd;
				}

				deleteResourceID = null;
			}

			if ( selectedResourceIndex >= 0 )
			{
				if ( selectedResourceIndex != 0 )
					resourcesList.selectedIndex = selectedResourceIndex;

				selectedResourceIndex = -1;
			}
		}

		private function arrayWithoutResource( idRes : String ) : Array
		{
			var newArray : Array = new Array();

			for each ( var resVO : ResourceVO in resources.source )
			{
				if ( !resVO || resVO.id != idRes )
					newArray.push( resVO );
			}

			return newArray;
		}

		/**
		 * @private
		 * close ResourceSelectorWindow if down ESCAPE or if down button "Apply"
		 * and dispatchEvent Apply
		 */
		private function keyDownWindowHendler( event : KeyboardEvent ) : void
		{
			if ( event.charCode == Keyboard.ESCAPE )
				close();
		}

		private function setSelectedItem() : void
		{
			if ( !_resources || _resources.length == 0 || _value == null )
				return;

			var resourceVO : ResourceVO;
			var requiredID : String;

			//TODO: need regexp
			requiredID = _value.substring( 5, _value.length - 1 );

			var i : int = -1;

			var array : Array = new Array();
			var idd : String = "";

			for each ( resourceVO in _resources.source )
			{
				i++;

				if ( !resourceVO )
					continue;

				if ( resourceVO.id == requiredID )
				{
					resourcesList.selectedItem = resourceVO;
					array.push( resourceVO );
					idd = resourceVO.id;

					break;
				}
			}

			for each ( resourceVO in _resources.source )
			{
				if ( resourceVO.id != idd )
					array.push( resourceVO );
			}

			_resources.source = array;


		}
		//		public function set 
	}
}
