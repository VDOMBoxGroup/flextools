package net.vdombox.object_editor.model.vo
{
	public class LibraryVO
	{
		public var target :String = "";
		public var text   :String = "";
		
		public function LibraryVO( newTarget:String = "" )
		{
			target = newTarget;
		}
	}
}