package net.vdombox.helpeditor.view.itemrenderers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.controls.treeClasses.TreeItemRenderer;
	
	import net.vdombox.helpeditor.controller.events.PagesSyncronizationEvent;
	
	public class TreeItemRenderer extends mx.controls.treeClasses.TreeItemRenderer
	{
		public var pageCheckBox : CheckBox;
		
		public function TreeItemRenderer()
		{
			super();
		}
		
		override protected function commitProperties():void
		{
			if (pageCheckBox)
			{
				removeChild(DisplayObject(pageCheckBox));
				
				pageCheckBox.removeEventListener(Event.CHANGE, selectionChangeHandler);
				pageCheckBox = null;
			}
			
			if (data != null && isPage)
			{
				pageCheckBox = new CheckBox();
				pageCheckBox.width = 10;
				pageCheckBox.height = 10;
				
				pageCheckBox.enabled = pageSyncAvailable;
				pageCheckBox.selected = pageSyncSelected;
				
				addChild(DisplayObject(pageCheckBox));
				
				pageCheckBox.addEventListener(Event.CHANGE, selectionChangeHandler);
			}
				
			super.commitProperties();
		}
		
		private function selectionChangeHandler (event : Event) : void
		{
			xmlData.@selected = pageCheckBox.selected;
			
			//parent.dispatchEvent(new Event("selectionChanged"));
			var syncEvent : PagesSyncronizationEvent = new PagesSyncronizationEvent(PagesSyncronizationEvent.SELECTION_CHANGED);
			syncEvent.pageName		= xmlData.@name;
			syncEvent.pageSelected	=pageCheckBox.selected;
			
			parent.dispatchEvent(syncEvent);
		}
		
		private function get pageSyncAvailable () : Boolean
		{
			if (!data)
				return false;
			
			var pageAvailableStr : String = xmlData.@available;
				
			return pageAvailableStr == "true";
		}

		private function get pageSyncSelected () : Boolean
		{
			if (!data)
				return false;
			
			var pageSelectedStr : String = xmlData.@selected;
			
			return pageSelectedStr == "true";
		}
		
		
		private function get isPage () : Boolean
		{
			if (!data)
				return false;
			
			return xmlData.name() == "page";
			
			return false;
		}
		
		override protected function updateDisplayList(unscaledWidth:Number, unscaledHeight:Number):void
		{
			super.updateDisplayList(unscaledWidth, unscaledHeight);
			
			if (!pageCheckBox)
				return;
			
			pageCheckBox.x = label.x;
			pageCheckBox.y = (height-pageCheckBox.height)/2;
			
			label.x = pageCheckBox.x + pageCheckBox.width + 5;
		}
		
		override public function set data (value:Object) : void
		{
			super.data = value;
		}
		
		private function get xmlData () : XML
		{
			return data as XML;
		}
		
	}
}