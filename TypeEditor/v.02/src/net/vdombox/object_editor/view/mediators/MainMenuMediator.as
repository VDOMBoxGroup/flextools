/*
	Class OpenMediator is a wrapper over the openButton in ObjectEditor2.mxml.
*/
package net.vdombox.object_editor.view.mediators
{	
	import flash.events.Event;
    import flash.filesystem.File;

    import flexlib.containers.SuperTabNavigator;

    import mx.controls.MenuBar;
import mx.core.UIComponent;

import mx.events.MenuEvent;
    import mx.utils.UIDUtil;

import net.vdombox.object_editor.Utils.WindowManager;

import net.vdombox.object_editor.model.Item;
    import net.vdombox.object_editor.model.proxy.FileProxy;
    import net.vdombox.object_editor.model.proxy.ObjectsProxy;
    import net.vdombox.object_editor.model.proxy.componentsProxy.ObjectTypeProxy;
    import net.vdombox.object_editor.view.AccordionNavigatorContent;
import net.vdombox.object_editor.view.popups.DocumentationSettingsWindow;
import net.vdombox.object_editor.view.ObjectView;

    import net.vdombox.object_editor.view.ObjectsAccordion;

    import org.puremvc.as3.interfaces.IMediator;
    import org.puremvc.as3.interfaces.INotification;
    import org.puremvc.as3.patterns.mediator.Mediator;
	
	public class MainMenuMediator extends Mediator implements IMediator
	{		
		public static const NAME:String = "MainMenuMediator";

        public static const CREATE_GUIDS	:String = "CreateGUIDs";
		
		public function MainMenuMediator( viewComponent:Object )
		{			
			super( NAME, viewComponent );

            view.addEventListener( MenuEvent.ITEM_CLICK, menuItemClickHandler );
		}

        protected function get view():MenuBar
        {
            return viewComponent as MenuBar;
        }

        override public function listNotificationInterests():Array
        {
            return [ CREATE_GUIDS ];
        }

        override public function handleNotification( note:INotification ):void
        {
            switch ( note.getName() )
            {
                case CREATE_GUIDS:
                {
                    createGUIDs(note.getBody() as File);
                    break;
                }
            }
        }

		private function menuItemClickHandler ( event:MenuEvent = null ) : void
		{
            var itemData : String = event.item.@data;

            switch (itemData)
            {
                case "open_folder" :
                    sendNotification( ApplicationFacade.LOAD_XML_FILES );
                    break;
                case "new_type" :
                    sendNotification( ApplicationFacade.CRAETE_XML_FILE, view.parentApplication );
                    break;
                case "remove_type" :
                    deleteObject();
                    break;
                case "doc_settings" :
                    openDocumentationSettingsWindow();
                    break;
            }


		}

        private function createGUIDs( file:File ) : void
        {
            var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
            var fileData: String	= fileProxy.readFile(file.nativePath);

            if (fileData != "")
            {
                var xmlFile:XML = new XML(fileData);

                //set Name
                xmlFile.Information.Name			=  file.name.split(".")[0];

                //set  DisplayName
                xmlFile.Languages.Language.Sentence[0]	=  file.name.split(".")[0];

                //set ID of Object
                xmlFile.Information.ID 				= UIDUtil.createUID().toLowerCase();

                //add uids
                var uid:String = UIDUtil.createUID().toLowerCase();
                xmlFile.Information.Icon			= "#Res(" + uid + ")";
                xmlFile.Resources.Resource.@ID[0]	= uid;

                uid = UIDUtil.createUID().toLowerCase();
                xmlFile.Information.EditorIcon		= "#Res(" + uid + ")";
                xmlFile.Resources.Resource.@ID[1]	= uid;

                uid = UIDUtil.createUID().toLowerCase();
                xmlFile.Information.StructureIcon	= "#Res(" + uid + ")";
                xmlFile.Resources.Resource.@ID[2]	= uid;

                //save file with new value
                var str:String = xmlFile.toXMLString();
                fileProxy.saveFile( str, file.nativePath );

                addItemToAccordion(file, xmlFile);
            }
        }

        private function addItemToAccordion( file:File, xmlFile:XML ) : void
        {
            //create Item and add it to Accordion
            var itemProxy:ObjectsProxy = facade.retrieveProxy(ObjectsProxy.NAME) as ObjectsProxy;
            var item:Item = itemProxy.getItem(file) ;
            facade.sendNotification(ApplicationFacade.NEW_NAVIGATOR_CONTENT, item);

            //new Tab
            var objTypeProxy:ObjectTypeProxy = facade.retrieveProxy(ObjectTypeProxy.NAME) as ObjectTypeProxy;
            objTypeProxy.newObjectTypeVO(xmlFile, item.path);
        }

        private function deleteObject( ) : void
        {
            var objAcc:ObjectsAccordion = view.parentApplication.objAccordion as ObjectsAccordion;
            var accNav:AccordionNavigatorContent = objAcc.accordion.selectedChild as AccordionNavigatorContent;
            var item:Item	 = accNav.list.selectedItem as Item;
            var selIndex:int = accNav.list.selectedIndex as int;

            if (selIndex >= 0)
            {
                var fileProxy:FileProxy = facade.retrieveProxy(FileProxy.NAME) as FileProxy;
                var file:File = new File();
                file.nativePath = item.path;

                //tab close
                var tabNav:SuperTabNavigator = view.parentApplication.tabNavigator as SuperTabNavigator;
                var obj:ObjectView = tabNav.selectedChild as ObjectView;
                if (obj)
                {
                    obj.dispatchEvent( new Event(ObjectViewMediator.OBJECT_TYPE_VIEW_REMOVED));

                    var fileData: String	= fileProxy.readFile(file.nativePath);
                    var xmlFile:XML = new XML(fileData);
                    var id:String = xmlFile.Information.ID;

                    facade.sendNotification(ObjectViewMediator.CLOSE_OBJECT_TYPE_VIEW, {"objView": obj, "id": id});
                }

                //delete obj from directory
                fileProxy.deleteFile(file.nativePath);

                //delete from accordion
                accNav.removeObject(selIndex);
            }
        }

        private function openDocumentationSettingsWindow () : void
        {
            var docSettingsWindow : DocumentationSettingsWindow = new DocumentationSettingsWindow();

            var docSettingsWindowMediator : DocumentationSettingsWindowMediator = new DocumentationSettingsWindowMediator( docSettingsWindow );
            facade.registerMediator( docSettingsWindowMediator );

            WindowManager.getInstance().addWindow(docSettingsWindow, UIComponent(view.parentApplication), true);
        }

	}
}