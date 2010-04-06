package net.vdombox.ide.modules.tree.view
{
	import flash.events.Event;
	
	import net.vdombox.ide.modules.Tree;
	import net.vdombox.ide.modules.tree.ApplicationFacade;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;

	public class TreeMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "TreeMediator";

		public function TreeMediator( viewComponent : Tree )
		{
			super( NAME, viewComponent );
		}

		override public function onRegister() : void
		{
			tree.addEventListener( Tree.TEAR_DOWN, tearDownHandler )
		}

		public function get tree() : Tree
		{
			return viewComponent as Tree;
		}

		private function tearDownHandler( event : Event ) : void
		{
			sendNotification( ApplicationFacade.TEAR_DOWN );
		}
	}
}
