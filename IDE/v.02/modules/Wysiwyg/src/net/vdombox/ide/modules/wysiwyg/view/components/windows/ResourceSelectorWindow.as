
package net.vdombox.ide.modules.wysiwyg.view.components.windows
{
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.ui.Keyboard;
	
	import mx.collections.ArrayList;
	import mx.controls.ComboBox;
	import mx.controls.Label;
	import mx.controls.List;
	import mx.controls.TextInput;
	
	import net.vdombox.ide.common.vo.ResourceVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.ResourceSelectorWindowEvent;
	import net.vdombox.ide.modules.wysiwyg.view.components.windows.resourceBrowserWindow.SmoothImage;
	import net.vdombox.ide.modules.wysiwyg.view.skins.ResourceSelectorWindowSkin;
	
	import spark.components.ComboBox;
	import spark.components.Label;
	import spark.components.TextArea;
	import spark.components.TextInput;
	import spark.components.TitleWindow;

	public class ResourceSelectorWindow extends TitleWindow
	{
		
		
		[ Bindable ]
		public var totalResources		: int	= 0;
		
		[Bindable]
		public var filteredResources	: int   = 0;
		
		public var deleteResourceID		: String = null;
		
		public var scrollToIndex		: int 	=  -1;
		
		public var selectedResourceIndex : int  = -1;
		
		[Bindable]
		public var _resources : ArrayList;
		
		private var _value : String;	
		
		[SkinPart( required="true" )]
		public var resourcesList : List;
		
		[SkinPart( required="true" )]
		public var imagePreview: SmoothImage;
		
		[SkinPart( required="true" )]
		public var resourceID: mx.controls.Label;
		
		[SkinPart( required="true" )]
		public var resourceName: mx.controls.Label;
		
		[SkinPart( required="true" )]
		public var resourceResolution: mx.controls.Label;
		
		[SkinPart( required="true" )]
		public var resourceType: mx.controls.Label;
		
		[SkinPart( required="true" )]
		public var typeFilter: spark.components.ComboBox;
		
		[SkinPart( required="true" )]
		public var nameFilter: spark.components.TextInput;
		
		public function ResourceSelectorWindow()
		{
			super();
			init();
		}
		
		override public function stylesInitialized():void {
			super.stylesInitialized();
			this.setStyle( "skinClass", ResourceSelectorWindowSkin );
		}
		public function get value() : String
		{
			return resourcesList.selectedItem ? resourcesList.selectedItem.id : "";
		}
		
		public function set value( value : String ) : void
		{
			_value = value;
			setSelectedItem();
		}
		
		public function set resources( value : ArrayList ) : void
		{				
			_resources = value;
			setSelectedItem();
		}
		
		public function get resources() : ArrayList
		{
			return _resources;
		}
		
		private function setSelectedItem() : void
		{
			if ( !_resources || _resources.length == 0 )
				return;
			
			var resourceVO : ResourceVO;
			
			for each ( resourceVO in _resources.source )
			{
				if ( resourceVO.id == _value.substring( 5, _value.length - 1 ) )
				{
					resourcesList.selectedItem = resourceVO;						
					dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.GET_RESOURCE ) )
					
					break;
				}
			}
		}
		
		override protected function commitProperties():void
		{
			super.commitProperties();
			
			if ( deleteResourceID )
			{					
				var selInd : uint = resourcesList.selectedIndex;
				
				resources.source = arrayWithoutResource( deleteResourceID );
				
				totalResources = resources.length-1;					
				
				if ( resources.length > 1 && selInd > 1)
				{
					selInd = ( selInd > 0 ) ? selInd -1 : 0;
					
					selectedResourceIndex	= selInd;
					scrollToIndex			= selInd;						
				}
				else
				{						
					clearPreloaderField();
				}
				
				deleteResourceID = null;
			}
			
			if ( scrollToIndex >= 0 )
			{
				resourcesList.scrollToIndex( scrollToIndex );
				
				scrollToIndex = -1;
			}
			
			if ( selectedResourceIndex >= 0 )
			{
				if ( selectedResourceIndex == 0)
				{
					clearPreloaderField();
				}
				else
				{	
					resourcesList.selectedIndex = selectedResourceIndex;
					selectResource();						
				}
				
				selectedResourceIndex = -1;
			}
		}
		
		private function clearPreloaderField( ) : void
		{
			imagePreview.source		= null;
			resourceID.text			= "";
			resourceName.text		= "";
			resourceResolution.text	= "";
			resourceType.text		= "";
		}
		
		private function arrayWithoutResource( idRes : String ) : Array
		{
			var newArray : Array = new Array();
			for each ( var resVO : ResourceVO in resources.source )
			{
				if ( resVO.id != idRes )
					newArray.push( resVO );
			}
			
			return newArray;
		}
		
		/**
		 * @private
		 * close ResourceSelectorWindow if down ESCAPE or if down button "Apply"
		 * and dispatchEvent Apply
		 */ 
		private function ok_close_window( event: KeyboardEvent = null ) : void
		{
			if ( event != null )
				if ( event.charCode != Keyboard.ESCAPE )
					return
					
					dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.CLOSE ) )
		}		
		
		private function init() : void
		{
			this.setFocus();
			//				dispatchEvent( FlexEvent.CREATION_COMPLETE );
			addEventListener( KeyboardEvent.KEY_DOWN, ok_close_window );					
		}
		
		public function uploadFile(event:MouseEvent):void
		{
			dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.LOAD_RESOURCE ) );			
		}
		
		public function refreshFile(event:MouseEvent):void
		{
			dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.GET_RESOURCES ) );			
		}
		
		public function onApplyClick():void
		{
			dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.APPLY));
		}
		
		public function onCancelClick():void
		{
			dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.CLOSE ))
		}
		
		public function selectResource( event:Event = null ):void
		{				
			if ( event == null )
			{
				dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.GET_RESOURCE ) );
				return;
			}
			
			if ( event.target.selectedIndex == 0 )
				clearPreloaderField();
			else
				dispatchEvent( new ResourceSelectorWindowEvent( ResourceSelectorWindowEvent.GET_RESOURCE ) );
		}
		
		//			protected function resourcesList_changeHandler(event:ListEvent):void
		//			{
		//				// TODO Auto-generated method stub
		//			}

		
	}
}