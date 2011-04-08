@startuml img/sequence_img001.png

participant ObjectAttributesPanel.mxml
participant ObjectAttributesPanel << (M,#ADD1B2) >>
	participant RendererTransformed << (C,#ADD1B2) >>
		participant WysiwygJunction << (M,#ADD1B2) >>
			box "Core" #LightBlue
participant SOAP 
	end box
participant	ProcessPageProxyMessage << (C,#ADD1B2) >>
	
	
	title:Save Object Attributes in Wisiwyg\n\n( M ) - Mediator\n( C ) - Command

ObjectAttributesPanel.mxml -> ObjectAttributesPanel: save
ObjectAttributesPanel -> RendererTransformed: SAVE_ATTRIBUTES_REQUEST\n(objectAttributesPanel.attributesVO)
RendererTransformed -> WysiwygJunction: UPDATE_ATTRIBUTES\n(vdomObjectAttributesVO)

WysiwygJunction -> SOAP: "set_attributes"
SOAP -> WysiwygJunction
	
WysiwygJunction -> ProcessPageProxyMessage: PROCESS_PAGE_PROXY_MESSAGE
ProcessPageProxyMessage -> ObjectAttributesPanel: PAGE_ATTRIBUTES_GETTED\n(vdomObjectAttributesVO)
ProcessPageProxyMessage -> WysiwygJunction: GET_WYSIWYG(vdomObjectVO)

WysiwygJunction -> SOAP: "get_child_objects_tree"

@enduml	