package net.vdombox.helpeditor.view.itemrenderers
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	
	import mx.controls.CheckBox;
	import mx.controls.treeClasses.TreeItemRenderer;
	import mx.events.FlexEvent;
	
	import net.vdombox.helpeditor.controller.events.PagesSyncronizationEvent;
	import net.vdombox.helpeditor.model.proxy.SQLProxy;
	import net.vdombox.helpeditor.view.components.SyncPagesSelector;
	
	public class CheckBoxesTreeItemRenderer extends mx.controls.treeClasses.TreeItemRenderer
	{
		private var sqlProxy : SQLProxy = new SQLProxy();
		
		public var pageCheckBox : CheckBox;
		
		private var syncGroupName : String;
		
		public function CheckBoxesTreeItemRenderer()
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
			
			var syncEvent : PagesSyncronizationEvent = new PagesSyncronizationEvent(PagesSyncronizationEvent.SELECTION_CHANGED);
			
			dispatchEvent(syncEvent);
		}
		
		private function get pageSyncAvailable () : Boolean
		{
			if (!data)
				return false;
			
			var pageAvailableStr : String = xmlData.@available;
				
			return pageAvailableStr == "true";
		}

		public function get pageSyncSelected () : Boolean
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
			
			syncGroupName = sqlProxy.getPageSyncGroup(xmlData.@name);
			
			xmlData.@selected = syncGroupName != null && syncGroupName != "";
			
			if (!syncGroupName)
			{
				xmlData.@available = true;
				return;
			}
			
			xmlData.@available = false;
			
			requestCurrentSyncGroupName();
		}
		
		public function requestCurrentSyncGroupName () : void
		{
			dispatchEvent(new PagesSyncronizationEvent(PagesSyncronizationEvent.GET_CUR_SYNC_GROUP_NAME));
		}
		
		public function set currentSyncGroupName (curGroupName : String) : void
		{
			xmlData.@available = !syncGroupName || syncGroupName == curGroupName;
		}
		
		private function get xmlData () : XML
		{
			return data as XML;
		}
		
		public function get pageName () : String
		{
			if (!xmlData)
				return "";
			
			return xmlData.@name;
		}
		
	}
}