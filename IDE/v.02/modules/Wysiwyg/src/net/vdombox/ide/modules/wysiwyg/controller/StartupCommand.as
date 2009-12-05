package net.vdombox.ide.modules.edition.controller
{
	import net.vdombox.ide.modules.Wysiwyg;
	import net.vdombox.ide.modules.edition.view.EditionJunctionMediator;
	import net.vdombox.ide.modules.edition.view.EditionMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;
	
	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Wysiwyg = note.getBody() as Wysiwyg;
			
			facade.registerMediator( new EditionJunctionMediator() );
			facade.registerMediator( new EditionMediator( application ) )
		}
	}
}