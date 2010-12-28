package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;
	
	public class ActionVO
	{
		[Bindable]
		public var parameters		: ArrayCollection = new ArrayCollection();
		public var description		: String = "";
		public var interfaceName	: String = "";
		public var methodName		: String = "";
		public var code				: String = "";
				
		public function ActionVO()
		{
			
		}
	}
}