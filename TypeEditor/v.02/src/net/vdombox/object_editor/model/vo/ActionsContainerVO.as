package net.vdombox.object_editor.model.vo
{
	import mx.collections.ArrayCollection;
	
	public class ActionsContainerVO
	{
		[Bindable]
		public var containerID			: String = new String();
		[Bindable]
		public var actionsCollection    : ArrayCollection = new ArrayCollection(); 
					
		public function ActionsContainerVO()
		{
			
		}
	}
}