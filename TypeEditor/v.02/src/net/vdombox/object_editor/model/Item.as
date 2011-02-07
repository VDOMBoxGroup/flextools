/*
   Class Item need for create structure of Accordions node
 */
package net.vdombox.object_editor.model  
{
	import flash.events.EventDispatcher;

	public class Item extends  EventDispatcher
	{
		private var _groupName	:String;

		[Bindable]
		public var _label		:String;
		private var _img		:String;	
		private var _path		:String;

		public function Item() 
		{}

		public function get groupName():String
		{
			return _groupName;
		}

		public function set groupName(groupName:String):void
		{
			_groupName = groupName;
		}

		[Bindable]
		public function get label():String
		{
			return _label;
		}

		[Bindable]
		public function set label(label:String):void
		{
			_label = label;
		}

		public function get img():String
		{
			return _img;
		}

		public function set img(img:String):void
		{
			_img = img;
		}

		public function get path():String
		{
			return _path;
		}

		public function set path(path:String):void
		{
			_path = path;
		}
	}
}

