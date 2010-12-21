/*
   Class ApplicationMediator register all Mediators
 */
package net.vdombox.object_editor.view.mediators
{
	import net.vdombox.object_editor.view.mediators.ObjectsAccordionMediator;
	import net.vdombox.object_editor.view.popups.ChangeWord;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME			:String = "ChangeWordMediator";				
//		public static const LOAD_INFORMATION:String = "LoadInformation";

		public function ApplicationMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );	

			facade.registerMediator( new OpenMediator( view.openButton ) ); 		
			facade.registerMediator( new ObjectsAccordionMediator( view.objAccordion ) );
		}

		public function newObjectView( objTypeVO:ObjectTypeVO ) : void
		{			
			var objView:ObjectView = new ObjectView();
			objView.label = objTypeVO.name;					

			view.tabNavigator.addChild(objView);
			facade.registerMediator( new ObjectViewMediator( objView, objTypeVO ) );	

			view.tabNavigator.selectedChild = objView;
		}

		override public function listNotificationInterests():Array 
		{			
			return [ ApplicationFacade.OBJECT_COMPLIT, ApplicationFacade.OBJECT_EXIST ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationFacade.OBJECT_COMPLIT:
					newObjectView(note.getBody() as ObjectTypeVO);
					break;	

				case ApplicationFacade.OBJECT_EXIST:
					var toSelectedOjectName:String = note.getBody() as String;
					view.tabNavigator.selectedChild = view.tabNavigator.getChildByName( toSelectedOjectName) as ObjectView;
					break;	
			}
		}

		protected function get view():ChangeWord
		{
			return viewComponent as ChangeWord
		}
	}
}
