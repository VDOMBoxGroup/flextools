@startuml img/sequence_img001.png

participant ObjectAttributesPanel.mxml
participant ObjectAttributesPanel << (M,#ADD1B2) >>
participant RendererTransformed << (C,#ADD1B2) >>
participant WysiwygJunction << (M,#ADD1B2) >>
box "Core" #LightBlue
	participant Page << (P,#ADD1B2) >>
	participant	VdomObjectAttributesVO
	participant SOAP 	
end box
participant	ProcessPageProxyMessage << (C,#ADD1B2) >>

title:Save Object Attributes in Wisiwyg\n\n( M ) - Mediator\n( C ) - Command\n( P ) - Proxy\n 


ObjectAttributesPanel.mxml -> ObjectAttributesPanel: save
ObjectAttributesPanel -> RendererTransformed: SAVE_ATTRIBUTES_REQUEST\n(objectAttributesPanel.attributesVO)
RendererTransformed -> WysiwygJunction: UPDATE_ATTRIBUTES\n(vdomObjectAttributesVO)

WysiwygJunction -> Page: junction.sendMessage(...)
	
Page -> VdomObjectAttributesVO: getChangedAttributes();
alt number of modified attributes > 0

Page -> SOAP
SOAP -> Page: soap_resultHandler\n("set_attributes")

Page -> WysiwygJunction
WysiwygJunction -> ProcessPageProxyMessage: PROCESS_PAGE_PROXY_MESSAGE
ProcessPageProxyMessage -> ObjectAttributesPanel: PAGE_ATTRIBUTES_GETTED\n(vdomObjectAttributesVO)
ProcessPageProxyMessage -> WysiwygJunction: GET_WYSIWYG(vdomObjectVO)

WysiwygJunction -> SOAP: junction.sendMessage(...)
SOAP -> Page: soap_resultHandler\n("get_child_objects_tree")
 
end
@enduml	