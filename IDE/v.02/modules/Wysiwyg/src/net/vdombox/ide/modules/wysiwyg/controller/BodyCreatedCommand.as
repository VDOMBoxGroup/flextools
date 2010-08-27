package net.vdombox.ide.modules.wysiwyg.controller
{
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.view.HelpPanelMediator;
	import net.vdombox.ide.modules.wysiwyg.view.ObjectAttributesPanelMediator;
	import net.vdombox.ide.modules.wysiwyg.view.ObjectsTreePanelMediator;
	import net.vdombox.ide.modules.wysiwyg.view.ToolbarPanelMediator;
	import net.vdombox.ide.modules.wysiwyg.view.TypesAccordionMediator;
	import net.vdombox.ide.modules.wysiwyg.view.VDOMXMLEditorMediator;
	import net.vdombox.ide.modules.wysiwyg.view.WorkAreaMediator;
	import net.vdombox.ide.modules.wysiwyg.view.components.main.Body;
	
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.command.SimpleCommand;

	public class BodyCreatedCommand extends SimpleCommand
	{
		override public function execute( notification : INotification ) : void
		{
			var body : Body = notification.getBody() as Body;

			facade.registerMediator( new TypesAccordionMediator( body.typesAccordion ) );
			facade.registerMediator( new ObjectsTreePanelMediator( body.objectsTreePanel ) );
			facade.registerMediator( new HelpPanelMediator( body.helpPanel ) );
			facade.registerMediator( new ObjectAttributesPanelMediator( body.objectAttributesPanel ) );
		}
	}
}