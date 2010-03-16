package net.vdombox.ide.modules.events.view.components
{
	import net.vdombox.ide.modules.events.view.skins.WorkAreaSkin;
	
	import spark.components.SkinnableContainer;
	
	public class WorkArea extends SkinnableContainer
	{
//		[SkinPart( required="true" )]
//		public var treeElementsContainer : Group;
//		
//		[SkinPart( required="true" )]
//		public var linkagesContainer : Group;
//		
//		[SkinPart( required="true" )]
//		public var scroller : Scroller;
		
		public function WorkArea()
		{
			setStyle( "skinClass", WorkAreaSkin );
		}
	}
}