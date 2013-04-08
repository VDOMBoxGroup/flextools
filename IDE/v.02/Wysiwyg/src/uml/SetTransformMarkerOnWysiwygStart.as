import net.vdombox.ide.modules.wysiwyg.view.components.PageRenderer;

@startuml img/sequence_img001.png

autonumber

box "Wysiwyg" #LightGreen
participant	BodyMediator << (M,#ADD1B2) >>
participant	WorkAreaMediator << (M,#ADD1B2) >>
participant	WorkArea << (V,#AD00B2) >>
participant	VdomObjectEditorMediator << M,#ADD1B2) >>
participant	VdomObjectEditor << (V,#AD00B2) >>
participant	EditorVO
participant WysiwygGettedCommand << (C,#ADD1B2) >>
participant RendererCreatedCommand << (C,#ADD1B2) >>
participant RenderProxy << (P,#ADD1B2) >>
end box

box "FLEX" #cccccc
participant BindingUtils
end box

box "Core" #LightBlue
participant	Core
end box


BodyMediator -> WorkAreaMediator : BODY_START
WorkAreaMediator -> WorkArea : openEditor( sessionProxy.selectedPage )

create VdomObjectEditor
WorkArea -> VdomObjectEditor : new
note over of VdomObjectEditor: new PageRenderer, id="renderer"

WorkArea -> VdomObjectEditor : get editorVO
VdomObjectEditor -> VdomObjectEditor : createEditorVO

create EditorVO
VdomObjectEditor -> EditorVO : new

EditorVO -> BindingUtils : bindSetter\n(vdomObjectChanged, newEditorVO, "vdomObjectVO", true, true)
BindingUtils --> EditorVO : vdomObjectChanged (null)
EditorVO -> BindingUtils : bindSetter\n(renderVOChanged, newEditorVO, "renderVO")
BindingUtils --> EditorVO : renderVOChanged (null)
EditorVO -> BindingUtils : bindSetter\n(xmlPresentationChanged, newEditorVO, "vdomObjectXMLPresentationVO", true, true)
BindingUtils --> EditorVO : xmlPresentationChanged (null)

WorkArea -> VdomObjectEditor : set editor.editorVO.vdomObjectVO (vdomObjectVO)
BindingUtils --> EditorVO : vdomObjectChanged (vdomObjectVO)
note over of EditorVO: isVdomObjectVOChanged = true;\ninvalidateProperties();
[-> EditorVO : commitProperties 
note over of EditorVO: dispatchEvent:\nEditorEvent.VDOM_OBJECT_VO_CHANGED

[-> VdomObjectEditorMediator : vdomObjectVOChangedHandler

VdomObjectEditorMediator -> Core : GET_WYSIWYG

...<b>getting wysiwyg...

Core --> WysiwygGettedCommand : WYSIWYG_GETTED
...
note over of EditorVO: [PageRenderer]\ncommitProperties
note over of EditorVO: [PageRenderer]\ncreationComplete
VdomObjectEditorMediator -> RendererCreatedCommand : RENDERER_CREATED
RendererCreatedCommand -> RenderProxy : addRenderer (null)

alt selectedObject.id == renderer.vdomObjectVO.id
RendererCreatedCommand -> VdomObjectEditorMediator : SELECTED_OBJECT_CHANGED (selectedObject)
note over of VdomObjectEditorMediator: <b><color:red>set transform marker for selected object</color>
end

@enduml	
	