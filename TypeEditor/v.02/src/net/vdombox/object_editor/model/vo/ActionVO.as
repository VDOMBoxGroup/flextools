package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;
	
	public class ActionVO extends BaseVO
	{
		[Bindable]
		public var parameters		: ArrayCollection = new ArrayCollection();
//		public var help				: String = "";//lang
		public var interfaceName	: String = "";//lang
		public var methodName		: String = "";
		[Bindable]
		public var code				: String = "";
				
		public function ActionVO()
		{
			super();
		}
	}
}