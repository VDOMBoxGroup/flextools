package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;
	
	public class ActionsVO
	{
		[Bindable]
		public var container			: String = "";
		public var actionsCollection    : ArrayCollection = new ArrayCollection();
					
		public function ActionsVO()
		{
			
		}
	}
}