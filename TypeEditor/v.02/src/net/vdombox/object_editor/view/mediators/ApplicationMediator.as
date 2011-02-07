/**
  * Class ApplicationMediator register all Mediators
 **/
package net.vdombox.object_editor.view.mediators
{
	import flash.events.Event;
	
	import mx.events.ChildExistenceChangedEvent;
	
	import net.vdombox.object_editor.controller.OpenDirectoryCommand;
	import net.vdombox.object_editor.model.vo.ObjectTypeVO;
	import net.vdombox.object_editor.view.ObjectView;
	import net.vdombox.object_editor.view.mediators.ObjectsAccordionMediator;
	
	import org.puremvc.as3.interfaces.IMediator;
	import org.puremvc.as3.interfaces.INotification;
	import org.puremvc.as3.patterns.facade.Facade;
	import org.puremvc.as3.patterns.mediator.Mediator;

	public class ApplicationMediator extends Mediator implements IMediator
	{
		public static const NAME			:String = "ApplicationMediator";				
		public static const LOAD_INFORMATION:String = "LoadInformation";

		public function ApplicationMediator( viewComponent:Object ) 
		{			
			super( NAME, viewComponent );	

			facade.registerMediator( new OpenMediator( view.openButton ) ); 		
			facade.registerMediator( new ObjectsAccordionMediator( view.objAccordion ) );

			//view.tabNavigator.addEventListener(ChildExistenceChangedEvent.CHILD_REMOVE, objViewRemoved);
		}

		public function newObjectView( objTypeVO:ObjectTypeVO ) : void
		{	
			var objView:ObjectView = new ObjectView();
			objView.label = objTypeVO.name;					
			objView.name  = objTypeVO.name;

			view.tabNavigator.addChild(objView);
			facade.registerMediator( new ObjectViewMediator( objView, objTypeVO ) );	

			view.tabNavigator.selectedChild = objView;
			endProgress();
			view.validateNow();
		}
		
		private var progress:uint=10;
		
		// Event handler function to set the value of the 
		// ProgressBar control.
		private function runProgress():void
		{
			trace("1 RUN_PROGRESS");
			view.enabled = false;
			view.progressBar.visible = true;
			if (progress <= 100)
			{
				view.progressBar.setProgress(progress,100);
				view.progressBar.label= "CurrentProgress" + " " + progress + "%";
				progress += 10;
			}
			if (progress>100)
			{
				progress=0;
			}
			view.validateNow();
		}
		
		private function endProgress():void
		{
			trace("3 endProgress");
			view.enabled = true;
			view.progressBar.visible = false;
		}
		
		public function reopenObjectView( objTabIndex:int, selTab:int) : void
		{			
			var countChilds:uint = view.tabNavigator.length;
			var objView:ObjectView = view.tabNavigator.getChildAt( countChilds - 1 ) as ObjectView;
			view.tabNavigator.removeChild( objView );
			view.tabNavigator.addChildAt( objView, objTabIndex );
						
			view.tabNavigator.selectedChild = objView;
			objView.tabNavigator.selectedIndex = selTab;
		}

		/**
		 * remove:
		 *   - ObjectViewMediator
		 *   - ObjectView
		 *   - objTypeVO
		 **/
		public function removeObjectView( objView:ObjectView, objTypeVO:ObjectTypeVO ) : void
		{				
			facade.removeMediator( "ObjectViewMediator" + objTypeVO.id );	
			view.tabNavigator.removeChild(objView);
		}

		override public function listNotificationInterests():Array 
		{			
			return [ ApplicationFacade.OBJECT_COMPLIT, ApplicationFacade.REOPEN_TAB, ApplicationFacade.OBJECT_EXIST, ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW, ApplicationFacade.RUN_PROGRESS ];
		}

		override public function handleNotification( note:INotification ):void 
		{
			switch ( note.getName() ) 
			{				
				case ApplicationFacade.OBJECT_COMPLIT:
				{
					newObjectView(note.getBody() as ObjectTypeVO);
					break;	
				}
				
				case ApplicationFacade.REOPEN_TAB:
				{
					reopenObjectView(note.getBody()["ViewInd"] as int, note.getBody()["SelectTab"] as int);
					break;	
				}
					
				case ApplicationFacade.OBJECT_EXIST:
				{
					var toSelectedOjectName:String = note.getBody() as String;
					view.tabNavigator.selectedChild = view.tabNavigator.getChildByName( toSelectedOjectName) as ObjectView;
					endProgress();
					break;	
				}
					
				case ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW:
				{
					removeObjectView(note.getBody()["objView"], note.getBody()["objVO"]);
					break;	
				}
					
				case ApplicationFacade.RUN_PROGRESS:
				{
					runProgress();
					break;	
				}
			}
		}

		private function  objViewRemoved( event : ChildExistenceChangedEvent ):void
		{
			var objView:ObjectView = event.relatedObject as ObjectView;
			objView.dispatchEvent( new Event(ObjectViewMediator.OBJECT_TYPE_VIEW_REMOVED));
		}

		protected function get view():ObjectEditor2
		{
			return viewComponent as ObjectEditor2
		}
	}
}