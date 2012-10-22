package net.vdombox.ide.modules.wysiwyg.model.business
{
	public class PagesManager
	{
		private static var _pages : Array;
		
		public function PagesManager()
		{
		}

		public static function get pages():Array
		{
			return _pages;
		}

		public static function set pages(value:Array):void
		{
			_pages = value;
		}

	}
}