package net.vdombox.ide.modules.edit.controller
{
	import net.vdombox.ide.modules.Edit;
	import net.vdombox.ide.modules.edit.view.EditJunctionMediator;
	import net.vdombox.ide.modules.edit.view.EditMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Edit = note.getBody() as Edit;
			
			facade.registerMediator( new EditJunctionMediator() );
			facade.registerMediator( new EditMediator( application ) )
		}
	}
}