package net.vdombox.ide.modules.wysiwyg.view
{
	import flash.display.DisplayObject;
	import flash.events.Event;
	import flash.events.IEventDispatcher;
	import flash.events.KeyboardEvent;
	import flash.ui.Keyboard;
	
	import mx.events.CloseEvent;
	
	import net.vdombox.ide.common.interfaces.IVDOMObjectVO;
	import net.vdombox.ide.common.vo.AttributeVO;
	import net.vdombox.ide.common.vo.ObjectVO;
	import net.vdombox.ide.common.vo.VdomObjectAttributesVO;
	import net.vdombox.ide.common.vo.VdomObjectXMLPresentationVO;
	import net.vdombox.ide.modules.wysiwyg.ApplicationFacade;
	import net.vdombox.ide.modules.wysiwyg.events.EditorEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererDropEvent;
	import net.vdombox.ide.modules.wysiwyg.events.RendererEvent;
	import net.vdombox.ide.modules.wysiwyg.events.SkinPartEvent;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IEditor;
	import net.vdombox.ide.modules.wysiwyg.interfaces.IRenderer;
	import net.vdombox.ide.modules.wysiwyg.model.RenderProxy;
	import net.vdombox.ide.modules.wysiwyg.model.SessionProxy;
	import net.vdombox.ide.modules.wysiwyg.model.vo.EditorVO;
	import net.vdombox.ide.modules.wysiwyg.view.components.RendererBase;
	import net.vdombox.ide.modules.wysiwyg.view.components.VdomObjectEditor;
	import net.vdombox.view.Alert;
	import net.vdombox.view.AlertButton;
	
	import org.puremvc.as3.multicore.interfaces.IMediator;
	import org.puremvc.as3.multicore.interfaces.INotification;
	import org.puremvc.as3.multicore.patterns.mediator.Mediator;
	
	import spark.components.Application;


	public class VdomObjectEditorMediator extends Mediator implements IMediator
	{
		public static const NAME : String = "VdomObjectEditorMediator";

		public static var instancesNameList : Object = {};

		public function VdomObjectEditorMediator( editor : IEditor )
		{
			var instanceName : String = NAME + "/" + editor.editorVO.vdomObjectVO.id;

			super( instanceName, editor );

			instancesNameList[ instanceName ] = true;
		}

		private var sessionProxy : SessionProxy;
		
		public function get component() : VdomObjectEditor
		{
			return viewComponent as VdomObjectEditor;
		}

		public function get editor() : IEditor
		{
			return viewComponent as IEditor;
		}

		public function get editorVO() : EditorVO
		{
			return editor ? editor.editorVO : null;
		}

		public function get vdomObjectXMLPresentationVO() : VdomObjectXMLPresentationVO
		{
			return editor.xmlPresentation;
		}
		
		public function set vdomObjectXMLPresentationVO( value : VdomObjectXMLPresentationVO ) : void
		{
			editor.xmlPresentation = value;
		}


		override public function onRegister() : void
		{
			sessionProxy = facade.retrieveProxy( SessionProxy.NAME ) as SessionProxy;

			addHandlers();
		}

		override public function onRemove() : void
		{
			removeHandlers();

			clearData();

			sessionProxy = null;
		}

		override public function listNotificationInterests() : Array
		{
			var interests : Array = super.listNotificationInterests();

			interests.push( ApplicationFacade.BODY_STOP );

			interests.push( ApplicationFacade.XML_PRESENTATION_GETTED );

			interests.push( ApplicationFacade.SELECTED_OBJECT_CHANGED );

			interests.push( ApplicationFacade.XML_PRESENTATION_SETTED );

			return interests;
		}

		override public function handleNotification( notification : INotification ) : void
		{
			var name : String = notification.getName();
			var body : Object = notification.getBody();

			var pageXML : XML;

			switch ( name )
			{
				case ApplicationFacade.BODY_STOP:
				{
					clearData();

					break;
				}

				case ApplicationFacade.SELECTED_OBJECT_CHANGED:
				{
					//  set transformMarker to selected page

					var editor : IEditor = viewComponent as IEditor;
					var selectedPage : IVDOMObjectVO = sessionProxy.selectedPage as IVDOMObjectVO;
					var selectedObject : IVDOMObjectVO = sessionProxy.selectedObject as IVDOMObjectVO;
					var selRenderer : RendererBase;

					if ( !selectedPage )
						break;


					if ( selectedPage.id != editor.editorVO.vdomObjectVO.id )
						break;

					if ( editor.state.substr( 0, 7 ) == "wysiwyg")
					{
						if ( selectedObject )
						{
							var renderProxy : RenderProxy = facade.retrieveProxy( RenderProxy.NAME ) as RenderProxy;
							var renderers : Array = renderProxy.getRenderersByVO( selectedObject );

							// find nesesary renderer

							for each ( var renderer : RendererBase in renderers )
							{
								if ( renderer.renderVO.vdomObjectVO.id == selectedObject.id )
								{
									selRenderer = renderer;
									break;
								}
							}
						}
						// mark object
						editor.selectedRenderer = selRenderer;
						if (editor.selectedRenderer != null)
							editor.selectedRenderer.setFocus();
					}
					else if (editor.state.substr( 0, 3 ) == "xml")
					{
						if (selectedObject == null)
							sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { pageVO: editor.editorVO.vdomObjectVO } );
						else
							sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { objectVO: selectedObject } );
					}

					break;
				}

				case ApplicationFacade.XML_PRESENTATION_SETTED:
				{
//					if ( editor.vdomObjectVO && body.hasOwnProperty( "pageVO" ) && body.pageVO && body.pageVO.id == editor.vdomObjectVO.id )
//					{
//						editor.status = PageEditor.STATUS_SAVING_OK;
//					}

					break;
				}
			}
		}

		private function addHandlers() : void
		{
			var editor : IEventDispatcher = editor as IEventDispatcher;

			if ( !editor )
				return;
			
			editor.addEventListener( KeyboardEvent.KEY_DOWN, keyDownDeleteHandler, true);

			editor.addEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler, false, 0, true );

			editor.addEventListener( SkinPartEvent.PART_ADDED, partAddedHandler, false, 0, true );
			editor.addEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler, false, 0, true );
			editor.addEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler, false, 0, true );

			editor.addEventListener( EditorEvent.XML_SAVE, xmlSaveHandler, false, 0, true );

			editor.addEventListener( EditorEvent.VDOM_OBJECT_VO_CHANGED, vdomObjectVOChangedHandler, false, 0, true );

			editor.addEventListener( EditorEvent.RENDERER_TRANSFORMED, rendererTransformedHandler, false, 0, true );

			editor.addEventListener( RendererEvent.CREATED, renderer_createdHandler, true, 0, true );
			editor.addEventListener( RendererEvent.REMOVED, renderer_removedHandler, true, 0, true );
			editor.addEventListener( RendererEvent.CLICKED, renderer_clickedHandler, true, 0, true );

			editor.addEventListener( RendererEvent.GET_RESOURCE, renderer_getResourseHandler, true, 0, true );

			editor.addEventListener( RendererDropEvent.DROP, renderer_dropHandler, true, 0, true );

			editor.addEventListener( EditorEvent.ATTRIBUTES_CHANGED, attributesChangeHandler, true, 0, true );
		}

		private function removeHandlers() : void
		{
			var editor : IEventDispatcher = editor as IEventDispatcher;

			if ( !editor )
				return;

			editor.removeEventListener( Event.REMOVED_FROM_STAGE, removedFromStageHandler );

			editor.removeEventListener( SkinPartEvent.PART_ADDED, partAddedHandler );
			editor.removeEventListener( EditorEvent.WYSIWYG_OPENED, partOpenedHandler );
			editor.removeEventListener( EditorEvent.XML_EDITOR_OPENED, partOpenedHandler );

			editor.removeEventListener( EditorEvent.XML_SAVE, xmlSaveHandler );

			editor.removeEventListener( EditorEvent.VDOM_OBJECT_VO_CHANGED, vdomObjectVOChangedHandler );

			editor.removeEventListener( EditorEvent.RENDERER_TRANSFORMED, rendererTransformedHandler );

			editor.removeEventListener( RendererEvent.CREATED, renderer_createdHandler, true );
			editor.removeEventListener( RendererEvent.REMOVED, renderer_removedHandler, true );
			editor.removeEventListener( RendererEvent.CLICKED, renderer_clickedHandler, true );

			editor.removeEventListener( RendererDropEvent.DROP, renderer_dropHandler, true );

			editor.removeEventListener( EditorEvent.ATTRIBUTES_CHANGED, attributesChangeHandler, true );

			editor.removeEventListener( RendererEvent.GET_RESOURCE, renderer_getResourseHandler, true );


		}
		
		private function keyDownDeleteHandler(event : KeyboardEvent) : void
		{
			if (event.keyCode == Keyboard.DELETE && sessionProxy.selectedObject != null)
			{
				var componentName : String = sessionProxy.selectedObject.typeVO.displayName;
				
				Alert.noLabel = "Cancel";
				Alert.yesLabel = "Delete";
				
				Alert.Show( "Are you sure want to delete " + componentName + " ?",AlertButton.OK_No, component.parentApplication, closeHandler);
			}
		}

		private function closeHandler(event : CloseEvent) : void
		{
			if (event.detail == Alert.YES)
			{
				if ( sessionProxy.selectedPage && sessionProxy.selectedObject )
					sendNotification( ApplicationFacade.DELETE_OBJECT, { pageVO: sessionProxy.selectedPage, objectVO: sessionProxy.selectedObject } );
			}
		}
		
		private function clearData() : void
		{
			editor.editorVO.vdomObjectVO = null;
		}

		private function removedFromStageHandler( event : Event ) : void
		{
			facade.removeMediator( mediatorName );
			delete instancesNameList[ mediatorName ];
		}

		private function partAddedHandler( event : SkinPartEvent ) : void
		{
		}

		private function partOpenedHandler( event : EditorEvent ) : void
		{
			if ( event.type == EditorEvent.WYSIWYG_OPENED && editor.editorVO.vdomObjectVO )
				sendNotification( ApplicationFacade.GET_WYSIWYG, editor.editorVO.vdomObjectVO );
			else if ( event.type == EditorEvent.XML_EDITOR_OPENED )
			{
				var selectedPage : IVDOMObjectVO = sessionProxy.selectedPage as IVDOMObjectVO;
				var selectedObject : IVDOMObjectVO = sessionProxy.selectedObject as IVDOMObjectVO;
				
				if (selectedObject == null)
					sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { pageVO: editor.editorVO.vdomObjectVO } );
				else
					sendNotification( ApplicationFacade.GET_XML_PRESENTATION, { objectVO: selectedObject } );
			}
		}

		private function xmlSaveHandler( event : EditorEvent ) : void
		{
			editor.status = VdomObjectEditor.STATUS_SAVING;
			sendNotification( ApplicationFacade.SET_XML_PRESENTATION, editor.xmlPresentation );
		}

		private function vdomObjectVOChangedHandler( event : EditorEvent ) : void
		{
			if ( editor.editorVO.vdomObjectVO )
				sendNotification( ApplicationFacade.GET_WYSIWYG, editor.editorVO.vdomObjectVO );
		}

		private function renderer_createdHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.RENDERER_CREATED, event.target as IRenderer );
		}

		private function renderer_removedHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.RENDERER_REMOVED, event.target as IRenderer );
		}

		private function renderer_clickedHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.RENDERER_CLICKED, event.target as IRenderer );
		}

		private function renderer_getResourseHandler( event : RendererEvent ) : void
		{
			sendNotification( ApplicationFacade.GET_RESOURCE_REQUEST, event.object );
		}

		private function renderer_dropHandler( event : RendererDropEvent ) : void
		{
			sendNotification( ApplicationFacade.CREATE_OBJECT_REQUEST, { vdomObjectVO: ( event.target as IRenderer ).vdomObjectVO, typeVO: event.typeVO, point: event.point } )
		}

		private function rendererTransformedHandler( event : EditorEvent ) : void
		{
			var attributeVO : AttributeVO;
			var attributeName : String;
			var attributeValue : String;

			var attributes : Array = [];
			var vdomObjectAttributesVO : VdomObjectAttributesVO = new VdomObjectAttributesVO( event.renderer.vdomObjectVO );

			for ( attributeName in event.attributes )
			{
				if ( attributeName == "x" )
				{
					attributeValue = event.attributes[ attributeName ];
					attributeName = "left";
				}
				else if ( attributeName == "y" )
				{
					attributeValue = event.attributes[ attributeName ];
					attributeName = "top"
				}
				else
				{
					attributeValue = event.attributes[ attributeName ];
				}

				attributeVO = new AttributeVO( attributeName );
				attributeVO.value = attributeValue;

				attributes.push( attributeVO );
			}

			vdomObjectAttributesVO.attributes = attributes;

			sendNotification( ApplicationFacade.RENDERER_TRANSFORMED, vdomObjectAttributesVO );
		}

		private function attributesChangeHandler( event : EditorEvent ) : void
		{

			sendNotification( ApplicationFacade.SAVE_ATTRIBUTES_REQUEST, event.vdomObjectAttributesVO );
		}
	}
}
