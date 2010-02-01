package net.vdombox.ide.modules.tree.view
{
	import net.vdombox.ide.modules.tree.view.components.Arrow;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	public class ArrowMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "ArrowMediator";
		
		public function ArrowMediator( viewComponent : Object )
		{
			super( NAME, viewComponent );
		}
		
		public function get arrow() : Arrow
		{
			return viewComponent as Arrow;
		}
	}
}