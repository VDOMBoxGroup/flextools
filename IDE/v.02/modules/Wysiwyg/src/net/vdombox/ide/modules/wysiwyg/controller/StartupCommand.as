package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.Wysiwyg;
	import net.vdombox.ide.modules.wysiwyg.view.WysiwygJunctionMediator;
	import net.vdombox.ide.modules.wysiwyg.view.WysiwygMediator;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class StartupCommand extends SimpleCommand
	{
		override public function execute( note : INotification ) : void
		{
			var application : Wysiwyg = note.getBody() as Wysiwyg;

			facade.registerMediator( new WysiwygJunctionMediator() );
			facade.registerMediator( new WysiwygMediator( application ) )
		}
	}
}