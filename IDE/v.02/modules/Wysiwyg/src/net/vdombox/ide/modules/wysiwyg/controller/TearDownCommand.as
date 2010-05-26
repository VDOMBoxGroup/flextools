package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.view.BodyMediator;
	import net.vdombox.ide.modules.wysiwyg.view.ItemMediator;
	import net.vdombox.ide.modules.wysiwyg.view.WorkAreaMediator;
	import net.vdombox.ide.modules.wysiwyg.view.WysiwygJunctionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	import org.puremvc.as3.multicore.patterns.facade.Facade;
	
	public class TearDownCommand extends SimpleCommand
	{
		override public function execute(notification:INotification) : void
		{
			var wysiwygJunctionMediator:WysiwygJunctionMediator =
				facade.retrieveMediator( WysiwygJunctionMediator.NAME ) as WysiwygJunctionMediator;
			
			wysiwygJunctionMediator.tearDown();
			
			facade.removeMediator( WorkAreaMediator.NAME );
			facade.removeMediator( BodyMediator.NAME );
			
			//Definitively removes the PureMVC core used to manage this module.
			Facade.removeCore( multitonKey );
		}
	}
}