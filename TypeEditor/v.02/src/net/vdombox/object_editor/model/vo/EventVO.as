package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;

	public class EventVO
	{
		[Bindable]
		public var parameters	: ArrayCollection = new ArrayCollection();
		public var name			: String = "";
		public var help			: String = "";
		
		public function EventVO( eventName:String = "" )
		{
			name = eventName;
		}
		
		public function newParameter(name:String):void
		{
		}
	}
}