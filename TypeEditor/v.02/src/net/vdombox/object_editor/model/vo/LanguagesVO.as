package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;

	public class LanguagesVO
	{
		public var currentLocation:String 	= "en_US";
		public var words:ArrayCollection 	= new ArrayCollection();		
		public var locales:ArrayCollection 	= new ArrayCollection();
		
		public function LanguagesVO()
		{
			
		}
	}
}